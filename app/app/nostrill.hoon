/-  sur=nostrill, nsur=nostr, tf=trill-feed, comms=nostrill-comms
/+  lib=nostrill, nostr-keys, sr=sortug, scri,
    ws=websockets,
    nreq=nostr-req,
    shim, dbug,
    evlib=nostr-events,
    mutations-nostr,
    mutations-trill,
    jsonlib=json-nostrill,
    trill=trill-post, commlib=nostrill-comms, followlib=nostrill-follows
/=  web  /web/router
|%
+$  versioned-state  $%(state-0:sur)
--
=|  versioned-state
=*  state  -
%-  agent:dbug
^-  agent:gall
|_  =bowl:gall
+*  this  .
    rout  ~(. router:web [state bowl])
    cards  ~(. cards:lib bowl)
    mutan  ~(. mutations-nostr [state bowl])
    mutat  ~(. mutations-trill [state bowl])
    shimm  ~(. shim [state bowl])
    scry   ~(. scri [state bowl])
    coms   ~(. commlib [state bowl])
    fols   ~(. followlib [state bowl])
++  on-init
  ^-  (quip card:agent:gall agent:gall)
  =/  default  (default-state:lib bowl)
  :_  this(state default)
  :~  shim-binding:cards
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |~  old-state=vase
  ^-  (quip card:agent:gall agent:gall)
  =/  old-state  !<(versioned-state old-state)
  ?-  -.old-state
    %0  `this(state old-state)
  ==
  :: `this(state (default-state:lib bowl))
::
++  on-poke
  |~  [=mark =vase]
  ^-  (quip card:agent:gall agent:gall)
  |^
  ~&  nostrill-on-poke=mark
  ?+  mark  `this
    %noun    handle-comms
    %json    on-ui
    %handle-http-request         handle-shim
    %websocket-handshake         handle-ws-handshake
    %websocket-server-message    handle-ws-msg
  ==  
  ++  handle-ws-handshake
    =/  order  !<([@ inbound-request:eyre] vase)
    :_  this
    ::  TODO refuse if...?
    (accept-handshake:ws -.order)
  ::  we behave like a Server here, mind you. messages from clients, not relays
  ++  handle-ws-msg
    =/  order  !<([wid=@ msg=websocket-message:eyre] vase)
    :: ~&  opcode=op=opcode.msg.order  ::  0 for continuation, 1 for text, 2 for binary, 9 for ping 0xa for pong
    =/  msg  message.msg.order
    ?~  msg  `this
    =/  jsons=@t  q.data.u.msg
    ~&  >>  ws-msg-jsons=jsons
    =/  jsonm  (de:json:html jsons)
    ?~  jsonm  `this
    =/  client-msg  (parse-client-msg:nreq u.jsonm)
    ?~  client-msg  ~&  "wrong nostr ws msg from client"  `this
    :: TODO de-json thing and handle whatever
    =^  cs  state  ?-  -.u.client-msg
      %req    `state
      %event  (handle-client-event:mutan -.order event.u.client-msg)
      %auth   `state
      %close  `state
    ==
    [cs this]
  ::
  :: 
  ++  handle-comms
    =/  pok  (cast-poke:coms q.vase)
    ?:  ?=(%dbug -.pok)  (debug +.pok)
    =^  cs  state
      ?-  -.pok
        %req  (handle-req:coms +.pok)
        %res  (handle-res:coms +.pok)
      ==
    [cs this]
  ++  handle-shim
    =/  order  !<(order:web vase)
    ~&  request.req.order
    ?:  .=(url.request.req.order '/nostr-shim')
      =/  msg  (parse-msg:shim order)
      ?~  msg  `this
      ?>  ?=(%ws -.u.msg)
      :: =^  cards  state  (handle-shim-msg:mutat u.msg)
      =^  cards  state  (handle-ws:mutan +.u.msg)
      [cards this]

    ::
    =/  cards  (rout:rout order)
    [cards this]
  
  ::
  ++  on-ui
    =/  jon=json  !<(json vase)
    ~&  >  on-ui-jon=jon
    =/  upoke=(unit poke:ui:sur)  (ui:de:jsonlib jon)
    ?~  upoke  ~&  bad-ui-poke=jon  `this
    ?-  -.u.upoke
      %keys  handle-cycle-keys
      %fols  (handle-fols +.u.upoke)
      %begs  (handle-begs +.u.upoke)
      %prof  (handle-prof +.u.upoke)
      %rela  (handle-rela +.u.upoke)
      %post  =^  cs  state
             (handle-post:mutat +.u.upoke)
            [cs this]
    ==
  ++  handle-cycle-keys
        =/  ks  (gen-keys:nostr-keys eny.bowl)
        =.  keys  [ks keys]
        :: =/  nkeys  keys(i ks, t `(list keys:nsur)`keys)
        :: :: =.  keys  nkeys
        ~&  new-keys=keys
        `this

  ++  handle-begs  |=  poke=begs-poke:ui:sur
  ?-  -.poke
    %feed
      =/  cs  ~
      [cs this]
    %thread
      =/  cs  ~
      [cs this]
  ==
  ++  handle-fols  |=  poke=fols-poke:ui:sur
    =^  cs  state
      ?-  -.poke
        %add  (handle-add:fols +.poke)
    
        %del   (handle-del:fols +.poke)
      ==
      [cs this]

  ++  handle-prof  |=  poke=prof-poke:ui:sur
    ?-  -.poke
      %add
        =.  profiles  (~(put by profiles) [%urbit our.bowl] +.poke)
        `this
      %del
        =.  profiles  (~(del by profiles) [%urbit our.bowl])
        `this
    ==
  ++  handle-rela  |=  poke=relay-poke:ui:sur
    ?-  -.poke
      %add  =.  relays  (~(put by relays) +.poke *relay-stats:nsur)
            `this
      %del  =.  relays  (~(del by relays) +.poke)
            `this
      ::
      %sync  =^  cs  state  get-posts:shimm
             [cs this]
      ::
      %send
          =/  upoast  (get-poast:scry host.poke id.poke)
          ?~  upoast  `this
          =/  event  (post-to-event:evlib i.keys eny.bowl u.upoast)
          =/  req=bulk-req:shim:nsur  [relays.poke %event event]
          =/  cards  :~((send:shimm req))
          [cards this]
    ==

    
  ::
  ++  debug  |=  noun=*
    ?+  noun  `this
      %wtf
        =/  lol=(unit @)  ~
        =/  l  ~|  "wtf"  (need lol)
        `this
      %genkey
        =/  keys  (gen-keys:nostr-keys eny.bowl)
        ~&  pub=(scow:sr %ux -.keys)
        ~&  priv=(scow:sr %ux +.keys)
        `this
      %printkey
          =/  ks  `(list keys:nsur)`keys
          |-  ?~  ks  `this
            =/  key  i.ks
            ~&  pub=(scow:sr %ux -.key)
            ~&  priv=(scow:sr %ux +.key)
            $(ks t.ks)
      %feed
        :: =/  lol  debug-own-feed:mutat
        ~&  pry=(pry:orm:tf feed)
        ~&  ram=(ram:orm:tf feed)
        `this
      %nstats
        ~&  nostr-feed=~(wyt by nostr-feed)
        ~&  profiles=~(wyt in ~(key by profiles))
        =/  lol  (print-relay-stats:lib relays)

      `this
      %http
      `this
      %rt  ::  relay test
        =^  cards  state  get-posts:shimm
        [cards this]
      %rt0
        =/  ids
          %+  roll  (tap:norm:sur nostr-feed)  |=  [[@ ev=event:nsur] acc=[(set @ux) (set @ux)]]
            ?.  .=(kind.ev 1)  acc
            %=  acc
              -  (~(put in -.acc) id.ev)
              +  (~(put in +.acc) pubkey.ev)
            ==
          =^  cards  state  (populate-profiles:mutan -.ids)
          :: (get-profiles:shimm +.ids)
          :: (get-engagement:shimm -.ids)
        [cards this]
      :: %rt1
      ::     =|  cards=(list card:agent:gall)
      ::     |-
      ::     ?~  l
      ::         ~&  cards=(lent cards)  [cards this]
      ::       =/  [sub-id=@t pf=filter:nsur done=filter:nsur]  i.l
      ::       =/  diff  (diff-filters:nlib pf done)
      ::       :: ~&  >  diff=diff
      ::       ?~  authors.pf  $(l t.l)
      ::       =^  cs  state  (populate-profiles:mutat u.authors.pf)
            
      ::       $(l t.l, cards (weld cards cs))
    %rt2

      =/  poasts  (tap:norm:sur nostr-feed)
      =/  pcount  (lent poasts)
      =|  invalid=(list @t)
      |-  ?~  poasts
        ~&  >>>  invalid=invalid
        `this
        =/  p=event:nsur  +.i.poasts
        =/  valid  (validate-pubkey:nostr-keys pubkey.p)
        ?.  valid
          =/  ids  (crip (scow:sr %ux id.p))
          ~&  ids
          ~&  content.p
          $(invalid [ids invalid], poasts t.poasts)
        $(poasts t.poasts)
    %rt3
      =/  poasts  (tap:norm:sur nostr-feed)
      =|  pubkeys=(set @ux)
      =/  pks=(set @ux)
        |-  ?~  poasts  pubkeys
          =/  p=event:nsur  +.i.poasts
          =/  npks  (~(put in pubkeys) pubkey.p)
          $(poasts t.poasts, pubkeys npks)
      ::
      =^  cards  state  (populate-profiles:mutan pks)
      [cards this]
    %ui
      =/  =fact:ui:sur  [%post %add *post-wrapper:sur]
      =/  card     (update-ui:cards fact)
      :_  this  :~(card)
    %kick
      :_  this   =/  subs  ~(tap by sup.bowl)
        %+  turn  subs  |=  [* p=@p pat=path]
        [%give %kick ~[pat] ~]

    ==
      
  ::
  --
::
++  on-watch
|=  =(pole knot)  
  ~&  on-watch=`path`pole
  ?+  pole  !!
  [%http-response *]  `this
  [%websocket-server *]  `this
  [%follow ~]  :_  this  (give-feed:coms pole)
  [%beg %feed ~]
    :_  this  (give-feed:coms pole)
  [%beg %thread ids=@t ~]
    =/  id  (slaw:sr %uw ids.pole)
    ?~  id  ~&  error-parsing-ted-id=pole  `this
    :_  this  (give-ted:coms u.id pole)
  [%ui ~]
    ?>  .=(our.bowl src.bowl)
    :_  this
    =/  jon  (state:en:jsonlib state)
    [%give %fact ~[/ui] [%json !>(jon)]]^~
  ==
::
++  on-leave
  |~  =(pole knot)
  ^-  (quip card:agent:gall agent:gall)
  `this
::
++  on-peek
  |~  =(pole knot)
  ^-  (unit (unit cage))
  ~&  >  on-peek=pole
  ?+  pole  ~
   [%x %j %feed host=@ start=@ end=@ count=@ newest=@ replies=@ *]
     (sfeed:scry host.pole start.pole end.pole count.pole newest.pole replies.pole)
   [%x %j %thread host=@ id=@ *]  (thread:scry host.pole id.pole)
  ==
  
::
++  on-agent
  |~  [wire=(pole knot) =sign:agent:gall]
  ^-  (quip card:agent:gall agent:gall)
  ~&  on-agent=[wire -.sign]
  ::  if p.sign  is  not ~ here that means it's intentional
  ?+  wire  `this
    [%follow ~]
      ?:  ?=(%watch-ack -.sign) 
        ?~  p.sign  `this
        =^  cs  state  (handle-kick-nack:fols src.bowl)  [cs this]
      ?:  ?=(%kick -.sign)
        =^  cs  state  (handle-refollow:fols src.bowl)
        [cs this]
      ?.  ?=(%fact -.sign)  `this

        =/  =fact:comms  ;;  fact:comms  q.q.cage.sign
        =^  cs  state  
          ?-  -.fact
            %init  (handle-follow-res:fols +.fact)
            %post  (handle-post-fact:mutat +.fact)
            %prof  (handle-prof-fact:mutan +.fact)
          ==
        [cs this]
        
  ==
::
++  on-arvo
  |~  [wire=(pole knot) =sign-arvo]
  ^-  (quip card:agent:gall agent:gall)
  ?+  wire  `this
    [%http sub-id=@t *]  
      ?>  ?=([%khan %arow *] sign-arvo)
      ?:  ?=(%| -.p.sign-arvo)  `this
      =/  jstring  !<(@ +>.p.sign-arvo)
      =/  msg  (parse-body:shimm jstring)
      ?~  msg  ~&  `@t`jstring  `this
      ?>  ?=(%http -.u.msg)
      =^  cards  state  (handle-http:mutan sub-id.wire +.u.msg)
      `this
  ==
::
++  on-fail
  |~  [term tang]
  ^-  (quip card:agent:gall agent:gall)
  `this
--
