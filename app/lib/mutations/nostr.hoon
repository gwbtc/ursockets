/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    nreq=nostr-req,
    server,
    evlib=nostr-events,
    nostr-client,
    njs=json-nostr,
    postlib=trill-post,
    nostr-client,
    sr=sortug,
    scri,
    ws=websockets

|_  [=state:sur =bowl:gall]
+*  cardslib  ~(. cards:lib bowl)
+$  card  card:agent:gall
::  relay state
++  get-relay  ^-  (unit [wid=@ud relay=relay-stats:nsur])
  =/  rls  ~(tap by relays.state)
  ?~  rls  ~
  `i.rls

++  set-relay  |=  wid=@ud
  ^-  (quip card _state)
  =/  socket  (get-url:ws wid bowl)
  ?~  socket  ~&  "socket wid not in iris"  !!
  ?.  ?=(%accepted status.u.socket)  ~&  "socket status in iris unsync"  !!
  =/  relay=relay-stats:nsur  [now.bowl url.u.socket ~]
  =.  relays.state  (~(put by relays.state) wid relay)
  :_  state
  =/  ui-card  (update-ui:cardslib [%nostr %relays relays.state])
  :~(ui-card)

++  unset-relay  |=  wid=@ud
  ^-  (quip card _state)
  =.  relays.state  (~(del by relays.state) wid)
  =/  ui-card  (update-ui:cardslib [%nostr %relays relays.state])
  :_  state
  :~  (disconnect:ws wid)
      ui-card
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

++  handle-ws  |=  [wid=@ud relay=relay-stats:nsur msg=relay-msg:nsur]
  =/  nclient  ~(. nostr-client [state bowl wid relay])
  |^
  =^  cards  state
    ~&  >  handle-ws=-.msg
    ?-  -.msg
      ::  This gets returned when we post a message to a relay
      %ok     (handle-ok url.relay +.msg)
      %event  (handle-event sub-id.msg event.msg)
      %eose   (handle-eose +.msg)
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
    ::  increment event count in relay state
    ~&  >>  parsing-nostr-event=kind.event
    ~&  >>  sub-id=sub-id
    :: ~&  >   relay-subs=~(key by reqs.relay)
    =/  req  (~(get by reqs.relay) sub-id)
    ?~  req  ~&  >>>  "sub id not found in relay state"  `state
    
    =.  received.u.req  +(received.u.req)
    =.  reqs.relay  (~(put by reqs.relay) sub-id u.req)
    =.  relays.state  (~(put by relays.state) wid relay)
    ::
    |^
  :: https://nostrdata.github.io/kinds/
    =/  cs1=(list card)
      ?~  ongoing.u.req    ~
      ?.  u.ongoing.u.req  ~
      ::  If it's an ongoing request and %eose has been reached we pass the individual event to the UI as is
      =/  c  (update-ui:cardslib [%nostr %event event])
      :~(c)
    =^  cs  state
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
    [(weld cs1 cs) state]

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
      =/  user-feed  (~(get by following.state) [%nostr pubkey.event])
      =?  following.state  ?=(^ user-feed)
        =/  pw  (event-to-post:evlib event ~ ~)
        =/  poast=post:post  -.pw
        =/  nf  (put:orm:feed u.user-feed id.poast poast)
        (~(put by following.state) [%nostr pubkey.event] nf)
      :_  state
      ~
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
    --

    ++  handle-eose  |=  sub-id=@t
    ~&  >>>  "HANDLING-EOSE-FROM-SERVER"
    ~&  sub-id
      :: TODO better UI facts
      =/  creq  (~(get by reqs.relay) sub-id)
      ?~  creq  ~&  >>>  "sub id not found! on eose"  `state
      ~&  >>  eose=u.creq
    ~&  >>>  "**************"
      :: 
      ::  if there's a queue we setup the next subscription
      =^  cards  relay
        ?:  (is-feed:evlib filters.u.creq)
          ~&  >>  "eose on global feed request"
          =/  c  (update-ui:cardslib [%nostr %feed nostr-feed.state])
          =^  mc  relay  get-profiles:nclient
          [[c mc] relay]
        ::
        =/  users=(set @ux)  (user-req:evlib filters.u.creq)
        ?:  (gth ~(wyt in users) 0)
          ~&  >>>  "eose on user feed request"
          =/  poasts  (tap:norm:sur nostr-feed.state)
          =/  subset  %+  skim  poasts  |=  [* ev=event:nsur]  (~(has in users) pubkey.ev)
          =/  f  (gas:norm:sur *nostr-feed:sur subset)
          =/  c  (update-ui:cardslib [%nostr %user f])
          [:~(c) relay]
        =/  thread-id  (thread-req:evlib filters.u.creq)
        ?^  thread-id
          ~&  >>>  "eose on thread request"
          =/  poasts  (tap:norm:sur nostr-feed.state)
          =/  subset  %+  skim  poasts  |=  [* ev=event:nsur]
            ?|  .=(u.thread-id id.ev)
                =/  refs  (get-references:evlib ev)
                (~(has in refs) u.thread-id)
            ==
          =/  f  (gas:norm:sur *nostr-feed:sur subset)
          =/  c  (update-ui:cardslib [%nostr %thread f])
          [:~(c) relay]
        ::
        ?:  (profs-req:evlib filters.u.creq)
        =/  c  (update-ui:cardslib [%prof profiles.state])
        [:~(c) relay]
        ::
        [~ relay] 
        ::
      =^  cards2  relay
        ?~  chunked.u.creq  [~ relay]
          =/  head  i.chunked.u.creq
          =/  tail  t.chunked.u.creq
          =/  ncreq=event-stats:nsur  [filters.u.creq received.u.creq ongoing.u.creq ~]
          =.  reqs.relay  (~(put by reqs.relay) sub-id ncreq)
         (send-req:nclient :~(head) ongoing.u.creq tail)
      ::
      =^  cards3  relay
        ?~  ongoing.u.creq
          ~&  >>>  closing-relay-sub=[sub-id filters.u.creq]
          (close-sub:nclient sub-id wid relay)
        =/  ncreq=event-stats:nsur  [filters.u.creq received.u.creq `.y ~]
        =.  reqs.relay  (~(put by reqs.relay) sub-id ncreq)
        [~ relay]
      ::
      =.  relays.state  (~(put by relays.state) wid relay)
      :_  state  (weld (weld cards cards2) cards3)

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
  ++  handle-rela  |=  rh=relay-handling:ui
    ^-  (quip card _state)
    =/  rl  get-relay
    ?~  rl  ~&  >>>  "no relay!!!!"  `state
    =/  wid=@ud  -.u.rl
    =/  relay=relay-stats:nsur  +.u.rl
    =/  nclient  ~(. nostr-client [state bowl wid relay])
    ?:  ?=(%send -.rh)
      =/  scry   ~(. scri [state bowl])
      =/  upoast  (get-poast:scry host.rh id.rh)
      ?~  upoast  `state
      =/  event  (post-to-event:evlib i.keys.state eny.bowl u.upoast)
      =/  cs  :~((send:nclient url.relay [%event event]))
      [cs state]
    =^  cs  relay
      ?-  -.rh
          %sync    get-posts:nclient
          %user    (get-user-feed:nclient +.rh)
          %thread  (get-thread:nclient +.rh)
          %prof    get-profiles:nclient
          ::
      ==
     =.  relays.state  (~(put by relays.state) -.u.rl relay)
    [cs state]
--
