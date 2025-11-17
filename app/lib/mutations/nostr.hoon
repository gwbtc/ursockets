/-  sur=nostrill, nsur=nostr, comms=nostrill-comms,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    nreq=nostr-req,
    server,
    njs=json-nostr,
    postlib=trill-post,
    nostr-client,
    sr=sortug,
    ws=websockets

|_  [=state:sur =bowl:gall]
+$  card  card:agent:gall
::  relay state
++  set-relay  |=  wid=@ud
  ^-  (quip card _state)
  =/  socket  (get-url:ws wid bowl)
  ?~  socket  ~&  "socket wid not in iris"  !!
  ?.  ?=(%accepted status.u.socket)  ~&  "socket status in iris unsync"  !!
  =/  relay=relay-stats:nsur  [now.bowl url.u.socket ~]
  =.  relays.state  (~(put by relays.state) wid relay)
  `state

++  unset-relay  |=  wid=@ud
  ^-  (quip card _state)
  =.  relays.state  (~(del by relays.state) wid)
  :_  state
  :~  (disconnect:ws wid)
  ==
  

:: events
++  handle-client-event  |=  [wid=@ =event:nsur]  ^-  (quip card _state)
  ~&  handling-client-event=event
  =.  nostr-feed.state  (put:norm:sur nostr-feed.state created-at.event event)
  =/  profile  (~(get by profiles.state) [%nostr pubkey.event])
  :: TODO save if we're following?
  :: =/  pw  (event-to-post:nlib event profile)
  =/  response  (ok-client-event:nreq event .n 'we\'re full')
  =/  cs  (ws-response:nreq wid response)
  [cs state]
  :: =/  l  events.state
  :: =|  cards=(list card:agent:gall)
  :: |-  ?~  l  [cards state]
  :: =/  n  (event-parsing i.l)
  :: $(cards -.n, state +.n, l t.l)

++  process-events  ^-  (quip card _state)
  :: =/  l  events.state
  :: =|  cards=(list card:agent:gall)
  :: |-  ?~  l  [cards state]
  :: =/  n  (event-parsing i.l)
  :: $(cards -.n, state +.n, l t.l)
  :: TODO
  `state
  
:: ++  parse-events
::   |=  evs=(list event:nsur)
::   ^-  (quip card _state)
::   =|  cards=(list card)
::   =^  cards  state
::   |-  ?~  evs  [cards state]
::     =^  cards  state  (handle-event i.evs)
::     $(evs t.evs)
::   [cards state]

++  populate-profiles
  |=  pubkeys=(set @ux)
  ^-  (quip card _state)
  =/  nclient  ~(. nostr-client [state bowl])
  =^  cards  state  (get-profiles:nclient pubkeys)
  [cards state]


++  handle-ws  |=  [wid=@ud relay=relay-stats:nsur msg=relay-msg:nsur]
  |^
  =^  cards  state
    ~&  >>>  "HANDLING-WS-FROM-SERVER"
    ~&  >  handle-ws=-.msg
    ~&  >>>  "**************"
    ?-  -.msg
      ::  This gets returned when we post a message to a relay
      %ok     (handle-ok url.relay +.msg)
      %event  (handle-event sub-id.msg event.msg)
      %eose
               :: TODO do unsub for replaceable/addressable events
               =/  creq  (~(get by reqs.relay) +.msg)
               ?~  creq  `state
               :: =.  reqs.u.rs  (~(del by reqs.u.rs) +.msg)
               :: =.  relays.state  (~(put by relays.state) relay u.rs)
               =/  cardslib  ~(. cards:lib bowl)
               =/  c  (update-ui:cardslib [%nostr nostr-feed.state])
               :_  state  :~(c)
      %closed  =.  reqs.relay  (~(del by reqs.relay) sub-id.msg)
               =.  relays.state  (~(put by relays.state) wid relay)
               `state
      %auth    ~&  >>  auth=+.msg  :: TODO handle auth challenges?
                `state
      %notice  ~&  >>  notice=+.msg  :: TODO pass to UI?
                `state
    ==
  [cards state]


    :: =^  cards  state  (handle-event:mutat url.u.msg sub-id.u.msg event.u.msg)
    :: ::  TODO not just stash events
    :: =/  relay  (~(get by relays) url.u.msg)
    :: =/  nevents=(list event:nsur)  ?~  relay  [event.u.msg ~]  [event.u.msg u.relay]
    :: =/  nevents2  (scag 100 nevents)

    :: =.  relays  (~(put by relays) url.u.msg nevents2)
    :: :: TODO respond better
    :: =/  response  (ebail:rout id.order)
    :: =/  ncards  (weld cards response)
    
    ::  [ncards this]
  :: `state
    
  ++  handle-ok  |=  [relay=@t event-id=@ux accepted=? msg=@t]
    ^-  (quip card _state)
    :: TODO pass to UI
    `state


  ++  handle-event
    |=  [sub-id=@t =event:nsur]
    ^-  (quip card _state)
    ~&  >  handle-event-sub=sub-id
    =/  req  (~(get by reqs.relay) sub-id)
    ?~  req  ~&  "sub id not found in relay state"  `state
    =.  received.u.req  +(received.u.req)
    =.  reqs.relay  (~(put by reqs.relay) sub-id u.req)
    |^
    ~&  parsing-nostr-event=kind.event
  :: https://nostrdata.github.io/kinds/
    ?:  .=(kind.event 666)  :: one_off subs eose  cf. 999
      parse-relay-oneose
    ?:  .=(kind.event 0)  ::  user metadata
      parse-metadata
    ?:  .=(kind.event 1)  ::  apparently a poast
      parse-poast
    ?:  .=(kind.event 3)  ::  follow list
      parse-follow
    :: ?:  .=(kind.event 5)  ::  delete
    ?:  .=(kind.event 6)  ::  RT
      parse-follow
    ?:  .=(kind.event 7)  ::  Reaction
      parse-follow

      `state

    ++  parse-metadata
    ^-  (quip card _state)
      =/  jstring  content.event
      =/  ujon  (de:json:html jstring)
      ?~  ujon  ~&  failed-parse-metadata=ujon  `state
      =/  umeta  (user-meta:de:njs u.ujon)
      ?~  umeta  ~&  >>  failed-dejs-metadata=ujon  `state
      =.  profiles.state  (~(put by profiles.state) [%nostr pubkey.event] u.umeta)
      `state


    ++  parse-poast
    ^-  (quip card _state)
      =.  nostr-feed.state  (put:norm:sur nostr-feed.state created-at.event event)
      :: =/  uprof  (~(get by profiles.state) pubkey.event)
      :: ?~  uprof
      ::   =/  shimm  ~(. shim [state bowl])
      ::   =^  cards  state  (get-profiles:shimm (silt ~[pubkey.event]))
      ::   [cards state]


      :: =/  fid  (~(get by following.state) pubkey.event)
      :: ?~  fid  `state  ::  don't save post if we don't follow the fucker

      :: =/  cl  (tokenize:postlib content.event)

      :: =/  ts  (from-unix:jikan:sr created-at.event)
      :: :: TODO wtf
      :: =/  cm=content-map:post  (init-content-map:postlib cl ts)

      :: =/  p=post:post  :*
      ::   id=ts
      ::   host=`@p`pubkey.event
      ::   author=`@p`pubkey.event
      ::   thread=ts
      ::   parent=~
      ::   children=~
      ::   contents=cm
      ::   read=*lock:gate
      ::   write=*lock:gate
      ::   *engagement:post
      ::   0v0
      ::   *signature:post
      ::   tags=~
      :: ==  
      :: =/  nfid  (put:orm:feed u.fid ts p)
      :: =.  following.state  (~(put by following.state) pubkey.event nfid)
    `state
    ++  parse-follow
    ^-  (quip card _state)
      =/  following  (~(get by follow-graph.state) [%nostr pubkey.event])
      =/  follow-set  ?~  following  *(set follow:sur)  u.following
      |-  ?~  tags.event  `state
        =/  t=tag:nsur  i.tags.event
        :: ?.  .=('p' key.t)  $(tags.event t.tags.event)
        :: =/  pubkeys  value.t
        :: =/  pubkey  (slaw:sr %ux pubkeys)
        :: ?~  pubkey  ~&  "parsing hex error"  $(tags.event t.tags.event)
        :: =/  relay  (snag 0 rest.t)
        :: =/  rel  ?:  .=(relay '')  ~  (some relay)
        :: =/  nickname  (snag 1 rest.t)
        :: =/  meta=follow:sur  [u.pubkey nickname rel]
        :: =.  follow-set  (~(put in follow-set) meta)
        :: =.  follow-graph.state  (~(put by follow-graph.state) pubkey.event follow-set)
        $(tags.event t.tags.event)
    ::
    ++  parse-relay-oneose
    ^-  (quip card _state)
      =.  reqs.relay  (~(del by reqs.relay) sub-id)
      =.  relays.state  (~(put by relays.state) wid relay)
    `state
    --
  --
  ++  handle-prof-fact  |=  pf=prof-fact:comms
    ^-  (quip card _state)
    =/  =user:sur  [%urbit src.bowl]
    ?-  -.pf
      %prof  =.  profiles.state  (~(put by profiles.state) user +.pf)
             :: TODO kinda wanna send it to the UI
             `state
      %keys  `state
      :: TODO really need a way to keep track of everyone's pubkeys
    ==
--
