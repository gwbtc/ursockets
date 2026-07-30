::  app/n-relay.hoon
::
::  A Nostr relay, in Gall, that only relays events from keys grounded in Jael.
::
::  It is a first-class relay: external Nostr clients dial wss://<ship>/nostr-relay
::  (the same inbound-WebSocket path %nostrill already uses), send REQ/EVENT/CLOSE,
::  and get EVENT/EOSE/OK/NOTICE back.  What makes it a *Groundwire* relay is the
::  admission gate: an event is only stored and rebroadcast if its author npub is
::  bound to a real, on-chain-confirmed Groundwire comet.
::
::  Two event classes:
::    * a binding (kind=bind-kind:jael) proves npub<->@p: verify-binding checks the
::      @p's ed25519 signature over the npub against Jael's pass, and that OUR jael
::      holds a verified point for that @p (which the %gw-btc verifier only stores
::      after confirming the satpoint on-chain).  On success we whitelist npub->@p.
::    * any other event is relayed only if its npub is already whitelisted.
::
::  Every event is also integrity-checked first: id == hash(raw) and a valid
::  BIP-340 signature.  This is the spam filter a dumb relay structurally cannot do.
::
::  Depends on lib/nostr/jael.hoon (PR: "derive the Nostr key from Jael").
::  DRAFT: sig verification assumes x-only (32-byte) pubkeys; see notes.
::
/-  nsur=nostr
/+  default-agent, dbug,
    nostr-keys, jael=nostr-jael,
    nreq=nostr-req, ws=websockets, sr=sortug
|%
+$  card  card:agent:gall
+$  sub-key  [wid=@ sub=@t]                       ::  one subscription
+$  state-0
  $:  %0
      subs=(map sub-key (list filter:nsur))        ::  live REQ filters
      events=(map @ux event:nsur)                  ::  stored, admitted events
      bound=(map @ux @p)                           ::  npub -> verified comet
  ==
--
%-  agent:dbug
^-  agent:gall
=|  state-0
=*  state  -
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    cor   ~(. raw bowl)
::
++  on-init   ^-((quip card _this) =^(cards state abet:init:cor [cards this]))
++  on-save   !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  =^  cards  state  abet:(load:cor old)
  [cards this]
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state  abet:(poke:cor mark vase)
  [cards this]
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =^  cards  state  abet:(peer:cor path)
  [cards this]
++  on-peek   peek:cor
++  on-agent  |=([=wire =sign:agent:gall] `this)
++  on-arvo   |=([=wire =sign-arvo] `this)
++  on-leave  |=(=path `this)
++  on-fail   on-fail:def
--
::
|%
++  raw
  =|  out=(list card)
  |_  =bowl:gall
  ++  abet  [(flop out) state]
  ++  cor   .
  ++  emit  |=(c=card cor(out [c out]))
  ++  emil  |=(c=(list card) cor(out (weld (flop c) out)))
  ++  give  |=(=gift:agent:gall (emit %give gift))
  ++  pass  |=([=wire =note:agent:gall] (emit %pass wire note))
  ::
  ::  +init: bind the relay's inbound-WebSocket endpoint
  ::
  ++  init
    ^+  cor
    (emit %pass /binding %arvo %e %connect [~ /nostr-relay] dap.bowl)
  ::
  ++  load
    |=  old=vase
    ^+  cor
    =.  state  !<(state-0 old)     ::  XX single version for now
    cor
  ::
  ::  +peer: Eyre subscribes here per live client connection
  ::
  ++  peer
    |=  =path
    ^+  cor
    ?+  path  ~|(bad-watch+path !!)
      [%websocket-server *]  cor
      [%http-response *]     cor
    ==
  ::
  ++  peek  |=(=(pole knot) ^-((unit (unit cage)) [~ ~]))
  ::
  ++  poke
    |=  [=mark =vase]
    ^+  cor
    ?+  mark  ~|(bad-mark+mark !!)
      %websocket-handshake       (handshake vase)
      %websocket-server-message  (message vase)
    ==
  ::
  ::  +handshake: accept only the /nostr-relay path
  ::
  ++  handshake
    |=  =vase
    ^+  cor
    =/  order  !<([@ inbound-request:eyre] vase)
    =/  pat=(unit path)  (rush url.request.order stap)
    ?:  ?&(?=(^ pat) ?=([%nostr-relay ~] u.pat))
      (emil (accept-handshake:ws -.order))
    (emil (refuse-handshake:ws -.order))
  ::
  ::  +message: a frame from a connected client (we are the server)
  ::
  ++  message
    |=  =vase
    ^+  cor
    =/  order  !<([wid=@ =path msg=websocket-message:eyre] vase)
    =/  msg  message.msg.order
    ?~  msg  cor
    =/  wsdata=@t  q.data.u.msg
    =/  jon  (de:json:html wsdata)
    ?~  jon  (emil (ws-response:nreq wid.order [%notice 'bad json']))
    =/  cm  (parse-client-msg:nreq u.jon)
    ?~  cm  (emil (ws-response:nreq wid.order [%notice 'unparseable']))
    ?-  -.u.cm
      %event  (take-event wid.order event.u.cm)
      %req    (take-req wid.order +.u.cm)
      %close  =.  subs  (~(del by subs) [wid.order sub-id.u.cm])
              cor
      %auth   cor
    ==
  ::
  ::  +take-event: integrity-check, gate on Jael, then store + broadcast
  ::
  ++  take-event
    |=  [wid=@ =event:nsur]
    ^+  cor
    =/  raw=raw-event:nsur
      [pubkey created-at kind tags content]:event
    ?.  =(id.event (hash-event:nostr-keys raw))
      (reply-ok wid id.event | 'invalid: id')
    ?.  (verify-event:nostr-keys pubkey.event id.event sig.event)
      (reply-ok wid id.event | 'invalid: sig')
    ?:  =(kind.event bind-kind:jael)
      ::  a binding attestation: verify against Jael and whitelist
      =/  who  (verify-binding:jael bowl event)
      ?~  who
        (reply-ok wid id.event | 'binding: not a verified groundwire comet')
      =.  bound  (~(put by bound) pubkey.event u.who)
      =.  cor  (admit event)
      (reply-ok wid id.event & 'bound')
    ::  a data event: require a prior, still-valid binding
    ?.  (~(has by bound) pubkey.event)
      (reply-ok wid id.event | 'blocked: npub not a grounded groundwire identity')
    =.  cor  (admit event)
    (reply-ok wid id.event & '')
  ::
  ::  +admit: store the event and fan it out to matching live subscriptions
  ::
  ++  admit
    |=  =event:nsur
    ^+  cor
    ?:  (~(has by events) id.event)  cor       ::  dedup
    =.  events  (~(put by events) id.event event)
    %-  emil
    %-  zing
    %+  turn  ~(tap by subs)
    |=  [key=sub-key fils=(list filter:nsur)]
    ^-  (list card)
    ?.  (match-any fils event)  ~
    (ws-response:nreq wid.key [%event sub.key event])
  ::
  ::  +take-req: register a subscription, replay matching history, then EOSE
  ::
  ++  take-req
    |=  [wid=@ req=relay-req:nsur]
    ^+  cor
    =.  subs  (~(put by subs) [wid sub-id.req] filters.req)
    =/  hits=(list event:nsur)
      %+  skim  ~(val by events)
      |=(=event:nsur (match-any filters.req event))
    =.  cor
      %-  emil
      %-  zing
      %+  turn  hits
      |=(=event:nsur (ws-response:nreq wid [%event sub-id.req event]))
    (emil (ws-response:nreq wid [%eose sub-id.req]))
  ::
  ++  reply-ok
    |=  [wid=@ id=@ux ok=? msg=@t]
    ^+  cor
    (emil (ws-response:nreq wid [%ok id ok msg]))
  ::
  ::  +match-any / +match: minimal NIP-01 filter matching (ids/authors/kinds/
  ::  since/until; tags and limit are TODO for the draft)
  ::
  ++  match-any
    |=  [fils=(list filter:nsur) =event:nsur]  ^-  ?
    ?~  fils  |
    ?:  (match i.fils event)  &
    $(fils t.fils)
  ::
  ++  match
    |=  [f=filter:nsur =event:nsur]  ^-  ?
    ?&  ?|(?=(~ ids.f) (~(has in u.ids.f) id.event))
        ?|(?=(~ authors.f) (~(has in u.authors.f) pubkey.event))
        ?|(?=(~ kinds.f) (~(has in u.kinds.f) kind.event))
        ?|(?=(~ since.f) (gte created-at.event (unix-secs:jael u.since.f)))
        ?|(?=(~ until.f) (lte created-at.event (unix-secs:jael u.until.f)))
    ==
  --
--
