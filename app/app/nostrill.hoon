/-  sur=nostrill, nsur=nostr, tf=trill-feed, comms=nostrill-comms
/+  lib=nostrill, nostr-keys, sr=sortug, scri,
    ws=websockets,
    bip-b173,
    nreq=nostr-req,
    nostr-client,
    dbug,
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
    rout   ~(. router:web [state bowl])
    cards  ~(. cards:lib bowl)
    mutan  ~(. mutations-nostr [state bowl])
    mutat  ~(. mutations-trill [state bowl])
    scry   ~(. scri [state bowl])
    coms   ~(. commlib [state bowl])
    fols   ~(. followlib [state bowl])
++  on-init
  ^-  (quip card:agent:gall agent:gall)
  =/  default  (default-state:lib bowl)
  :_  this(state default)
      bindings:cards

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
    %0   :_  this(state old-state)
         bindings:cards
  
  ==
  :: `this(state (default-state:lib bowl))
::
++  on-poke
  |~  [=mark =vase]
  ^-  (quip card:agent:gall agent:gall)
  |^
  ~&  nostrill-on-poke=mark
  ?+  mark  `this
    %noun  handle-comms
    %json  on-ui
    %websocket-client-message    handle-relay-ws
    %websocket-handshake         handle-ws-handshake
    %websocket-server-message    handle-ws-msg
    :: %websocket-thread            handle-ws-thread
    :: :: %handle-http-request         handle-shim
  ==  
  +$  ws-msg  [@ud websocket-message:eyre]
  ++  handle-ws-thread
    ~&  >>  "proxying ws thread"
    =/  msg  !<(ws-msg vase)
    :_  this
    ~&  "giving payload"
    :~  (give-ws-payload-client:ws msg)
    ==
  ++  handle-relay-ws
    ^-  (quip card:agent:gall agent:gall)
    =/  msg  !<(ws-msg vase)
    =/  wid  -.msg
    =/  relay  (~(get by relays) wid)
    ?~  relay  ~&  >>>  "wid not found in relays state"  `this
    =/  m=websocket-message:eyre  +.msg
    ?~  message.m  ~&  "empty message"  `this
    =/  =octs  u.message.m
    =/  urelay-msg  (parse-body:nostr-client q.octs)
    ?~  urelay-msg  ~&  "msg parse error"  `this
    =^  cards  state  (handle-ws:mutan wid u.relay u.urelay-msg)
    [cards this]

  ++  handle-ws-handshake
    ^-  (quip card:agent:gall agent:gall)
    =/  order  !<([@ inbound-request:eyre] vase)
    ~&  >>  nostrill-ws-handshake=order
    =/  url  url.request.order
    =/  pat=(unit path)  (rush url stap)
    ?~  pat  ~&  "pat-parsing-failed"  `this
    =/  ok=?  ?+  u.pat  .n
      [%nostrill-ui ~]   authenticated.order
      [%nostrill ~]     .y  :: TODO which nostr clients do we filter
    ==
    :_  this
    ?:  ok  (accept-handshake:ws -.order)  (refuse-handshake:ws -.order)
  ::  we behave like a Server here, mind you. messages from clients, not relays
  ++  handle-ws-msg
    ^-  (quip card:agent:gall agent:gall)
    =/  order  !<([wid=@ =path msg=websocket-message:eyre] vase)
    :: ~&  opcode=op=opcode.msg.order  ::  0 for continuation, 1 for text, 2 for binary, 9 for ping 0xa for pong
    =/  msg  message.msg.order
    ?~  msg  `this
    =/  wsdata=@t  q.data.u.msg
    ~&  >>  ws-msg-data=[path.order wsdata]
    |^
    ?+  path.order  `this
      [%nostrill-ui ~]  handle-ui-ws
      [%nostrill ~]     handle-nostr-client-ws
    ==
  ::
    ++  handle-ui-ws  
      ^-  (quip card:agent:gall agent:gall)
      =/  cs  (ui-ws-res:lib -.order wsdata)  
      [cs this]

    ++  handle-nostr-client-ws 
      ::  We are the server here
      ^-  (quip card:agent:gall agent:gall)
      =/  jsonm  (de:json:html wsdata)
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
  --
  ++  handle-comms
    =/  pok  (cast-poke:coms q.vase)
    ?:  ?=(%dbug -.pok)  (debug +.pok)
    =^  cs  state
      ?-  -.pok
        %req  (handle-req:coms +.pok)
        %res  (handle-res:coms +.pok)
        %eng  (handle-eng:coms +.pok)
      ==
    [cs this]
  ::
  ++  on-ui
    =/  jon=json  !<(json vase)
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
      %fetch
        ::  TODO
        `this
    ==
  ++  handle-rela  |=  poke=relay-poke:ui:sur
    ::  TODO fix this somehow
    =^  cs  state
    ?+  -.poke  (handle-rela:mutan poke)
      %add  :_  state
            :~  (connect:ws +.poke bowl)
            ==
      %del  (unset-relay:mutan +.poke)
    ==
    [cs this]
  ::
  ++  debug  |=  noun=*
    =/  rl  get-relay:mutan
    ?~  rl  ~&  >>>  "no relay!!!!"  `this
    =/  wid  -.u.rl
    =/  relay  +.u.rl
    =/  nclient  ~(. nostr-client [state bowl wid relay])
    ?+  noun  `this
      %iris
        =/  endpoint  'ws://localhost:8888'
        :_  this
        :~  (connect:ws endpoint bowl)
        ==
      %iris2
        =/  endpoint  'wss://nos:lol'
        :_  this
        :~  (connect:ws endpoint bowl)
        ==
      %wstest
        :: =/  url  'ws://localhost:8888'
        :: =/  url  'wss://nos.lol'
        =^  cs  relay  test-connection:nclient
        =.  relays  (~(put by relays) wid relay)
        [cs this]
      %wsl
        =/  l  (list-connected:ws bowl)
        ~&  >  ws-connections=l
        `this
      %wsc
        =.  relays  ~
        =.  nostr-feed  ~
        =/  sockets  .^((map @ud websocket-connection:iris) %ix /(scot %p our.bowl)/ws/(scot %da now.bowl))
        ~&  iris-sockets=sockets
        =/  wids  ~(key by sockets)
        =/  ws-paths  %+  turn  ~(tap in wids)  |=  wid=@  ^-  path  /websocket-client/(scot %ud wid)
        ~&  ws-paths=ws-paths
        :_  this
        ?~  ws-paths  ~
        :~  [%give %fact ws-paths %disconnect !>(~)]
        ==
      %ws-close
        :_  this
        =/  inc-subs  ~(tap by sup.bowl)
        =/  ws-paths  %+  roll  inc-subs  |=  [i=[=duct =ship =path] acc=(list path)]
          ?.  ?=([%websocket-client *] path.i)  acc
          ~&  bitt=i
          [path.i acc]
        ?~  ws-paths  ~
        :~  [%give %fact ws-paths %disconnect !>(~)]
        ==
      %irisf
        :_  this
        =/  inc-subs  ~(tap by sup.bowl)
        =/  ws-paths  %+  roll  inc-subs  |=  [i=[=duct =ship =path] acc=(list path)]
          ~&  bitt=i
          ?.  ?=([%websocket-client *] path.i)  acc
          [path.i acc]
        =/  jon  [%s 'lolazo']
        =/  octs  (as-octs:mimes:html (en:json:html jon))
        =/  msg=websocket-message:eyre  [1 `octs]
        :~  [%give %fact ws-paths %message !>(msg)]
        ==
      [%iris @]
        :_  this
        =/  =task:iris  [%websocket-event +.noun %message 1 `(as-octs:mimes:html 'heyhey')]
        :~  [%pass /iris-test2 %arvo %i task]
        ==
      %iriss
      =/  res  (check-connected:ws 'ws://localhost:8888' bowl)
      ~&  res
      `this
      %nostr
        =/  rls  ~(tap by relays)
        =/  m  |-  ?~  rls  ~
          =/  stats=relay-stats:nsur  +.i.rls
          ~&  >  ws-endpoint=url.stats
          ~&  >>  conn=start.stats
          =/  reqs  ~(tap by reqs.stats)
          =/  mm  |-  ?~  reqs  ~
            =/  sub  -.i.reqs
            ~&  event-stats=[sub-id=sub +.i.reqs]
            $(reqs t.reqs)
          $(rls t.rls)
        ~&  >  "nostr feed"
      `this
      %nf
        =/  nf  (tap:norm:sur nostr-feed)
        =/  nff  |-  ?~  nf  ~
          =/  ev=event:nsur  +.i.nf
          ~&  meta=[kind=kind.ev id=id.ev pubkey=pubkey.ev ts=created-at.ev]
          ~&  >>  ev-txt=content.ev
          
          $(nf t.nf)
        
        `this
      %profs
        =/  pfs  ~(tap by profiles)
        ~&  stored-profiles=(lent pfs)
        =/  nff  |-  ?~  pfs  ~
          =/  u=user:sur  -.i.pfs
          =/  prof=user-meta:nsur  +.i.pfs
          ~&  >>  user=u
          ~&  >  profile=prof
          $(pfs t.pfs)
        
        `this
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
            =/  npub  (encode-pubkey:bip-b173 %main [33 -.key])
            ~&  npub=npub
            :: =/  nsec
            :: ~&  nsec=nsec
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
        =^  cards  relay  get-posts:nclient
        =.  relays  (~(put by relays) wid relay)
        [cards this]
      %rt0
          =^  cards  relay  get-profiles:nclient
          =.  relays  (~(put by relays) wid relay)
        [cards this]
    %ui
      =/  =fact:ui:sur  [%post %add *post-wrapper:sur]
      =/  card     (update-ui:cards fact)
      :_  this  :~(card)
    %kick
      :_  this   =/  subs  ~(tap by sup.bowl)
        %+  turn  subs  |=  [* p=@p pat=path]
        [%give %kick ~[pat] ~]
    %leave
      :_  this   =/  subs  ~(tap by wex.bowl)
        %+  turn  subs  |=  [[wire sip=@p term] q=*]
        (urbit-leave:fols sip)
    %comms
     :_  this
     :~  (urbit-watch:fols ~zod)
         [%pass /foldbug %agent [~zod dap.bowl] %poke %bitch !>(~)]
     ==


    ==
      
  ::
  --
::
++  on-watch
|=  =(pole knot)  
  ~&  on-watch=`path`pole
  ?+  pole  !!
  [%http-response *]  `this
  [%websocket-client wids=@t ~]
    =^  cs  state  (set-relay:mutan (slav %ud wids.pole))
    [cs this]
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
  ~&  >>>  on-leave=pole
  ::  TODO fix the relays when we doing this
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
    ::  test scry
    ::
      [%x %feed host=@ *]  (sfeedids:scry host.pole)
    ::
      [%x %children host=@ id=@ *]  (schildren:scry host.pole id.pole)
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
  ~&  >>  on-arvo=[`path`wire -.sign-arvo +<.sign-arvo]
  ?:  ?=(%iris -.sign-arvo)
    :: ~&  >  +.sign-arvo
    `this
  ?+  wire  `this
    [%ws %to-nostr-relay *]  
      ?>  ?=([%khan %arow *] sign-arvo)
      ?:  ?=(%| -.p.sign-arvo)  `this
      =/  =cage  +.p.sign-arvo
      =/  v=vase  q.cage
      =/  gift  !<(gift:iris v)
      ?.  ?=(%websocket-response -.gift)  `this
      ~&  m5=+.gift
      =/  wid=@  +<.gift
      =/  ev=websocket-event:eyre  +>.gift
      ?.  ?=(%message -.ev)  `this
      ?~  message.message.ev  `this
      =/  =octs  u.message.message.ev
      =/  jstring=@t  q.octs
      ~&  >>  jstring=jstring
      
      :: =/  msg  (parse-body:nclient jstring)
    :: ~&  "m5"
    ::   ?~  msg  ~&  badparse=`@t`jstring  `this
    ::   ~&  >>  ws-relay-msg=msg
      :: ?>  ?=(%http -.u.msg)
      :: =^  cards  state  (handle-http:mutan sub-id.wire +.u.msg)
      `this
    :: [%ws sub-id=@t *]  
    ::   ?>  ?=([%khan %arow *] sign-arvo)
    ::   ?:  ?=(%| -.p.sign-arvo)  `this
    ::   =/  jstring  !<(@ +>.p.sign-arvo)
    ::   =/  msg  (parse-body:nclient jstring)
    ::   ?~  msg  ~&  `@t`jstring  `this
    ::   ~&  >>  ws-ui-msg=msg
    ::   :: ?>  ?=(%http -.u.msg)
    ::   :: =^  cards  state  (handle-http:mutan sub-id.wire +.u.msg)
    ::   `this
  ==
::
++  on-fail
  |~  [term tang]
  ^-  (quip card:agent:gall agent:gall)
  `this
--
