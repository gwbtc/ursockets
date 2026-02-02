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
    constants,
    ws=websockets

|_  [=state:sur =bowl:gall]
+*  cardslib  ~(. cards:lib bowl)
+$  card  card:agent:gall

++  empty-nostr-profile  |=  [pubkey=@ux meta=user-meta:nsur]  ^-  user-profile:comms
  :-  pubkey
  :-  ~
  :-  0
  :-  ~
  :-  0
      meta

::  relay state
++  get-relay  ^-  (unit [wid=@ud relay=relay-stats:nsur])
  =/  rls  ~(tap by relays.state)
  ?~  rls  ~
  `i.rls
++  get-nostrill-relay  ^-  (unit [wid=@ud relay=relay-stats:nsur])
  =/  rls  ~(tap by relays.state)
  |-  ?~  rls  ~
    =/  relay=relay-stats:nsur  +.i.rls
    ?:   .=  url.relay  global-relay:constants
      `i.rls
      $(rls t.rls)

++  set-relay  |=  wid=@ud
  ^-  (quip card _state)
  =/  socket  (get-url:ws wid bowl)
  ?~  socket  ~&  "socket wid not in iris"  !!
  ?.  ?=(%accepted status.u.socket)  ~&  "socket status in iris unsync"  !!
  :: Don't add to relays state if it's the global-feed relay
  ?:  .=  url.u.socket  global-relay:constants
    =.  global-relay-conn.state  `wid
    :: TODO ui card?
    `state
    ::
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
  =/  nclient  ~(. nostr-client [state bowl])
  =/  rclient  ~(. relay.nclient [wid relay])
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
      :: ?:  .=(kind.event 667)  ::  Reaction
      ::   parse-global
      `state
    [(weld cs1 cs) state]

    ++  parse-metadata
    ^-  (quip card _state)
      =/  jstring  content.event
      =/  ujon  (de:json:html jstring)
      ?~  ujon  ~&  failed-parse-metadata=ujon  `state
      =/  umeta  (user-meta:de:njs u.ujon)
      ?~  umeta  ~&  >>  failed-dejs-metadata=ujon  `state
      =/  prof  (empty-nostr-profile pubkey.event u.umeta)
      =.  profiles.state  (~(put by profiles.state) [%nostr pubkey.event] prof)
      :_  state
      ~

  
    ++  parse-poast
    ^-  (quip card _state)
    
      =.  nostr-feed.state  (put:norm:sur nostr-feed.state created-at.event event)
      =/  user  [%nostr pubkey.event]
      =/  user-feed  (~(get by following.state) user)
      =/  profile  (~(get by profiles.state) user)
      =?  following.state  ?=(^ user-feed)
        =/  pw  (event-to-post:evlib event profile `url.relay)
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
      =/  ureq=(unit req-state:nsur)  (~(get by reqs.relay) sub-id)
      ?~  ureq  ~&  >>>  "sub id not found! on eose"  `state
      =/  reqs=req-state:nsur  u.ureq
      ~&  >>  eose=reqs
      ~&  >>>  "**************"
      :: 
      ::  if there's a queue we setup the next subscription
      =^  cards  relay
        ?:  (is-feed:evlib filters.reqs)
          ~&  >>  "eose on global feed request"
          =/  c  (update-ui:cardslib [%nostr %feed nostr-feed.state])
          =^  mc  relay  get-profiles:rclient
          [[c mc] relay]
        ::
        =/  users=(set @ux)  (user-req:evlib filters.reqs)
        ?:  (gth ~(wyt in users) 0)
          ~&  >>>  "eose on user feed request"
          =/  poasts  (tap:norm:sur nostr-feed.state)
          =/  subset  %+  skim  poasts  |=  [* ev=event:nsur]  (~(has in users) pubkey.ev)
          =/  f  (gas:norm:sur *nostr-feed:sur subset)
          =/  c  (update-ui:cardslib [%nostr %user f])
          [:~(c) relay]
        =/  thread-id  (thread-req:evlib filters.reqs)
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
        ?:  (profs-req:evlib filters.reqs)
        =/  c  (update-ui:cardslib [%prof profiles.state])
        [:~(c) relay]
        ::
        [~ relay] 
      ::  if chunked request we move the queue and send the new request
      =^  cards2  relay
        ?~  chunked.reqs  [~ relay]
          =/  head  i.chunked.reqs
          =/  tail  t.chunked.reqs
          =/  d  (set-req:nclient relay name.reqs :~(head) ongoing.reqs tail)
          :_  +.d
          :~  (send-card:rclient -.d)
          ==
      ::  if ongoing request we mark it as backlog received and keep it alive, else we cloe it
      =^  cards3  relay
        ?~  ongoing.reqs
          ~&  >>>  closing-relay-sub=[sub-id filters.reqs]
          =/  d  (close-sub-req:nclient sub-id wid relay)
          :_  +.d
          :~  (send-card:rclient -.d)
          ==
        =.  ongoing.reqs  `.y
        =.  reqs.relay  (~(put by reqs.relay) sub-id reqs)
        [~ relay]

      =/  eose-card  (update-ui:cardslib [%nostr %eose sub-id])
      =/  carrds  :-  eose-card  %+  weld  cards  %+  weld  cards2  cards3
      
      =.  relays.state  (~(put by relays.state) wid relay)
      :_  state  carrds

  --
  ++  handle-prof-fact  |=  prof=(unit user-profile:comms)
    ^-  (quip card _state)
    =.  profiles.state  ?~  prof
      (~(del by profiles.state) [%urbit src.bowl])
      (~(put by profiles.state) [%urbit src.bowl] u.prof)
         :: TODO kinda wanna send it to the UI
         `state


  ++  call-relay  |=  [wid=@ud relay-url=@t ro=relay-order:ui]
    ^-  (quip card _state)
    =/  urelay  (~(get by relays.state) wid)
    ?~  urelay
      ~&  >>>  not-connected-to-relay=wid
      (test-reconnection relay-url ro)
      ::
    =/  relay  u.urelay
    =/  rclient  ~(. relay.nclient [wid relay])
    ::
    =/  d=[(list card) _relay]
    ?-  -.action.rh
      %user      (get-user-feed:rclient +.action.rh)
      %thread    (get-thread:rclient +.action.rh)
      %sync       get-posts:rclient
      %prof       get-profiles:rclient      
    ==
    =.  relays.state  (~(put by relays.state) wid +.d)
    [-.d state]
    
  ++  test-reconnection  |=  [relay-url=@t ro=relay-order:ui]
    ^-  (quip card _state)
    =/  d  (wait-for-connection relay-url bowl)
    `state`
    


  ++  handle-ted  |=  r=ted:ui
    ^-  (quip card _state)
    ?.  ?=(%req -.r)  `state
    (relay-get +.r)

  ++  relay-get  |=  [tid=@ta wids=(list @ud) rg=relay-get:ui]
    ^-  (quip card _state)
    ~&  >>  got-tid=tid
    =/  nclient  ~(. nostr-client [state bowl])
    =^  cards  state
    =|  css=(list card)
    |-  ?~  wids  [css state]
      =/  wid=@ud  i.wids
      =/  urelay  (~(get by relays.state) wid)      
      ?~  urelay
        ~&  >>>  not-connected-to-relay=wid
        $(wids t.wids)
      =/  relay  u.urelay
      =/  rclient  ~(. relay.nclient [wid relay])
      ::
    
      =/  d
      ?+  -.rg  !!
        %sync       get-posts-ted:rclient
      ==
      =.  reqs.relay  (~(put by reqs.relay) sub-id.d rs.d)
      =.  relays.state  (~(put by relays.state) wid relay)
      =/  cs=(list card)
        :~  (poke-thread:cards:lib tid sub-id.d)
            card.d
        ==
      =/  ncss  (weld cs css)
      $(wids t.wids, css ncss)
    [cards state]  
  
  ::  Handle pokes from UI related to relay interaction
  ++  handle-rela  |=  rh=relay-handling:ui
    ^-  (quip card _state)
    ~&  handle-rela-mutan=rh
    =/  nclient  ~(. nostr-client [state bowl])
    =/  wids  relays.rh
    |^
      ?:  ?=(%send-prof -.action.rh)  :_  state  (send-prof relays.rh)
      ?:  ?=(%send-post -.action.rh)  :_  state  (send-post relays.rh +.action.rh)
      =^  cards  state
      
      =|  css=(list card)
      |-  ?~  wids  [css state]
        =/  wid=@ud  i.wids
        =/  urelay  (~(get by relays.state) wid)      
        ?~  urelay
          ~&  >>>  not-connected-to-relay=wid
          $(wids t.wids)
        =/  relay  u.urelay
        =/  rclient  ~(. relay.nclient [wid relay])
        ::
        =/  d=[(list card) _relay]
        ?-  -.action.rh
          %user      (get-user-feed:rclient +.action.rh)
          %thread    (get-thread:rclient +.action.rh)
          %sync       get-posts:rclient
          %prof       get-profiles:rclient      
        ==
        =.  relays.state  (~(put by relays.state) wid +.d)
        $(wids t.wids, css (weld css -.d))      
      [cards state]    


    ++  send-post  |=  [wids=(list @ud) host=@p id=@da]
      ^-  (list card)
      =/  scry   ~(. scri [state bowl])
      =/  upoast  (get-poast:scry host id)
      ?~  upoast  ~&  >>>  post-to-relay-not-found=[host id]  ~
      =/  event  (post-to-event:evlib i.keys.state eny.bowl u.upoast 1)
      ~&  >>>  sending=id
      =|  urls=(list @t)
      =/  cards=(list card)
        =|  cs=(list card)
        |-  ?~  wids  cs
          =/  wid=@ud  i.wids
          =/  urelay  (~(get by relays.state) wid)      
          ?~  urelay
            ~&  >>>  not-connected-to-relay=wid
            $(wids t.wids)
          =/  relay  u.urelay
  
          =/  rclient  ~(. relay.nclient [wid relay])
          =/  ncs  :_  cs  (send-card:rclient [%event event])
          =/  nurls  :_  urls  url.relay
          $(wids t.wids, cs ncs, urls nurls)
      :-  (update-ui:cardslib [%nostr %sent-post host id urls event])
          cards
        
    
    ++  send-prof
      |=  wids=(list @ud)
      ^-  (list card)
      =/  prof  (~(get by profiles.state) [%urbit src.bowl])
      ?~  prof  ~&  "send-prof failed"  ~
      =/  event  (profile-to-event:evlib i.keys.state u.prof eny.bowl now.bowl)
      =|  urls=(list @t)
      =/  cards=(list card)
        =|  cs=(list card)
        |-  ?~  wids  cs
          =/  wid=@ud  i.wids
          =/  urelay  (~(get by relays.state) wid)      
          ?~  urelay
            ~&  >>>  not-connected-to-relay=wid
            $(wids t.wids)
          =/  relay  u.urelay
  
          =/  rclient  ~(. relay.nclient [wid relay])
          =/  ncs    :_  cs  (send-card:rclient [%event event])
          =/  nurls  :_  urls  url.relay
          $(wids t.wids, cs ncs, urls nurls)
      :-  (update-ui:cardslib [%nostr %sent-prof urls])
      :-  (send-card:global:nclient [%event event])
          cards
  --
--
