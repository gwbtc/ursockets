/-  sur=nostrill, nsur=nostr, tf=trill-feed, tp=trill-post, comms=nostrill-comms, hark, noti=nostrill-noti, ui=nostrill-ui
/+  lib=nostrill, nostr-keys, sr=sortug, scri,
    ws=websockets,
    bip-b173,
    nreq=nostr-req,
    nostr-client,
    dbug,
    seq,
    evlib=nostr-events,
    mutations-nostr,
    mutations-trill,
    jsonlib=json-nostrill,
    feedlib=trill-feed, postlib=trill-post,
    seed,
    harklib=hark,
    commlib=nostrill-comms, followlib=nostrill-follows
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
    =/  pok  !<(poke:comms vase)
    ?:  ?=(%dbug -.pok)  (debug +.pok)
    =^  cs  state  (handle-eng:coms +.pok)
    [cs this]
  ::
  ++  on-ui
    =/  jon=json  !<(json vase)
    =/  upoke=(unit poke:ui)  (ui:de:jsonlib jon)
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
      %reqs  ::  TODO
      `this
    ==
  ++  handle-cycle-keys
        =/  ks  (gen-keys:nostr-keys eny.bowl)
        =.  keys  [ks keys]
        :: =/  nkeys  keys(i ks, t `(list keys:nsur)`keys)
        :: :: =.  keys  nkeys
        ~&  new-keys=keys
        `this

  ++  handle-begs  |=  poke=begs-poke:ui
  ?-  -.poke
    %feed
      =/  cs  ~
      [cs this]
    %thread
      =/  cs  ~
      [cs this]
  ==
  ++  handle-fols  |=  poke=fols-poke:ui
    =^  cs  state
      ?-  -.poke
        %add  (handle-add:fols +.poke)
    
        %del  (handle-del:fols +.poke)
      ==
      [cs this]

  ++  handle-prof  |=  poke=prof-poke:ui
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
  ++  handle-rela  |=  poke=relay-poke:ui
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
    ?+  noun  `this
      %hark
        =/  content=(list content:hark)
          :~  'Lol hi'
          ==
        =/  =req:sur  ['uhmmm uhhh basically... i followed you' %fans] 
        =/  enreq     [[%urbit ~sorreg-namtyv] now.bowl req]
        =/  n=notif:noti  [%req enreq ~]
        =/  =yarn:hark  (to-hark:harklib n bowl)
        =/  c  (poke-hark:harklib yarn bowl)
        :_  this  :~(c)
      %seed-threads
        ~&  >>  "seeding threads"
        =/  pubkey  pub.i.keys
        =/  baseda  ~2020.1.1
        =/  basedate  (yore baseda)
        =/  l  (gulf 0 10)
        =.  feed  |-  ?~  l  feed
          =/  i  +(i.l)
          =/  eny  (scow %p (add i (end 5 eny.bowl)))
          =/  content=@t  %-  crip  "THREAD OP \0a{eny}"
          =/  sp=sent-post:tp  (build-sp:postlib our.bowl our.bowl content ~ ~)
          =/  basemonth  (add i m.basedate)
          =/  opdate  basedate(m basemonth)
          =/  opid  (year opdate)
          =/  op=post:tp        (build-post:postlib opid pubkey sp)
          =.  feed  (put:orm:tf feed id.op op)
          =/  nests  10
          =/  nnests  nests
          =/  rng  ~(. og eny.bowl)
          =/  parent-id  id.op
          =/  new-parent  parent-id
          =.  feed
            |-  ?:  .=(nests 0)  feed
          ::     ::  For each level of nested replies
              =/  parent  (get:orm:tf feed parent-id)
              ?~  parent  ~&  >>>  ["parent wasn't set in feed??\0a" parent-id]  !!
            
              =^  reply-count  rng  (rads:rng 10)  ::  number of replies at this level
              =.  reply-count  +(reply-count)
              =/  rcount  reply-count
              ~&  >>>  [reply-count=reply-count at-level=nests]

              =/  new-state=[_feed @da]  |-  ?:  .=(reply-count 0)  [feed new-parent]
                ::  Well the pubkey would be the actual author's here but w/e
                =^  author-atom  rng  (rads:rng (bex 32))  ::  author of reply
                =/  author  `@p`author-atom
                =/  pubkey  pub.i.keys
                =/  reny  (scow %p (add eny.bowl (add nests reply-count)))
                =/  reply-content  %-  crip  "Reply to \0a{(scow %da parent-id)}\0a on thread {(scow %da id.op)}\0a{reny}"
                =/  sp=sent-post:tp  (build-sp:postlib host.u.parent author reply-content `parent-id `id.op)
                :: =/  reply-id  (add now.bowl (mul +(nests) +(reply-count)))
                =/  months  +((sub nnests nests))
                =/  days    +((sub rcount reply-count))
                =/  t=tarp  [days 0 0 0 ~]
                =/  d=date  [[.y 0] months t]
                =/  reply-id  %-  year  (add-to-date:jikan:sr opdate d)
                =/  reply=post:tp  (build-post:postlib reply-id pubkey sp)            
                =.  new-parent  id.reply
                =.  children.u.parent  (~(put in children.u.parent) id.reply)
                :: ~&  post-count-pre=(lent (tap:orm:tf feed))
                =.  feed       (put:orm:tf feed id.u.parent u.parent)
                =.  feed       (put:orm:tf feed id.reply reply)
                $(reply-count (dec reply-count))

              =.  feed  -.new-state
              =.  parent-id  +.new-state
          :: ::     ::
              $(nests (dec nests))
            $(l t.l)
       !!
      :: `this
      %seed-thread
        =/  eny  (scow %p (end 5 eny.bowl))
        =/  content=@t  %-  crip  "THREAD OP \0a{eny}"
        =/  sp=sent-post:tp  (build-sp:postlib our.bowl our.bowl content ~ ~)
        =/  pubkey  pub.i.keys
        =/  opid  ~2020.1.1
        =/  opdate  (yore opid)
        =/  op=post:tp        (build-post:postlib opid pubkey sp)
        =.  feed  (put:orm:tf feed id.op op)
        =/  nests  10
        =/  nnests  nests
        =/  rng  ~(. og eny.bowl)
        =|  total-count=@
        =/  parent-id  id.op
        =/  new-parent  parent-id
        =/  new-state=[_feed @]
          |-  ?:  .=(nests 0)  [feed total-count]
        ::     ::  For each level of nested replies
            =/  parent  (get:orm:tf feed parent-id)
            ?~  parent  ~&  >>>  ["parent wasn't set in feed??\0a" parent-id]  !!
            
            =^  reply-count  rng  (rads:rng 10)  ::  number of replies at this level
            =.  reply-count  +(reply-count)
            =/  rcount  reply-count
            :: ?:  .=(reply-count 0)  $(nests (dec nests))
            ~&  >>>  [reply-count=reply-count at-level=nests]

            =/  new-state=[_feed @da @]  |-  ?:  .=(reply-count 0)  [feed new-parent total-count]
              ::  Well the pubkey would be the actual author's here but w/e
              =^  author-atom  rng  (rads:rng (bex 32))  ::  author of reply
              =/  author  `@p`author-atom
              =/  pubkey  pub.i.keys
              =/  reny  (scow %p (add eny.bowl (add nests reply-count)))
              =/  reply-content  %-  crip  "Reply to \0a{(scow %da parent-id)}\0a on thread {(scow %da id.op)}\0a{reny}"
              =/  sp=sent-post:tp  (build-sp:postlib host.u.parent author reply-content `parent-id `id.op)
              :: =/  reply-id  (add now.bowl (mul +(nests) +(reply-count)))
              =/  months  (add m.opdate +((sub nnests nests)))
              =/  days    (add d.t.opdate +((sub rcount reply-count)))
              =/  reply-id  %-  year  opdate(m months, d.t days)
              =/  reply=post:tp  (build-post:postlib reply-id pubkey sp)            
              =.  total-count  +(total-count)
              =.  new-parent  id.reply
              =.  children.u.parent  (~(put in children.u.parent) id.reply)
              :: ~&  post-count-pre=(lent (tap:orm:tf feed))
              =.  feed       (put:orm:tf feed id.u.parent u.parent)
              =.  feed       (put:orm:tf feed id.reply reply)
              $(reply-count (dec reply-count))

            =.  feed  -.new-state
            =.  parent-id  +<.new-state
            =.  total-count  +>.new-state
        ::     ::
            $(nests (dec nests))
        =.  feed  -.new-state
        =.  total-count  +.new-state
        ~&  >  seeded-thread=[id.op count=total-count]
      :: !!
    `this
    %seed-own
        =/  text  long-text:seed
        =/  chunks  (chunk-by-size:seq text 256)
        ?~  chunks  ~&  "wtf"  !!
        =/  rest=(list tape)  t.chunks
        =/  pubkey  pub.i.keys
        =/  content  (crip i.chunks)
        =/  sp=sent-post:tp  (build-sp:postlib our.bowl our.bowl content ~ ~)
        =/  op=post:tp       (build-post:postlib now.bowl pubkey sp)
        ~&  "thread id"
        ~&  >>  id.op
        =/  parent-id  id.op
        =.  feed  (put:orm:tf feed id.op op)
        =/  idx  1
        =.  feed
          |-  ?~  rest  feed
            =/  parent  (get:orm:tf feed parent-id)
            ?~  parent  ~&  >>>  ["parent wasn't set in feed??\0a" parent-id]  !!
            =/  content  (crip i.rest)
            =/  sp=sent-post:tp  (build-sp:postlib our.bowl our.bowl content `parent-id `id.op)
            =/  reply-id   (add now.bowl (mul idx ~s10))
            =/  p=post:tp  (build-post:postlib reply-id pubkey sp)
            ::
            =.  children.u.parent  (~(put in children.u.parent) id.p)
            =.  feed       (put:orm:tf feed id.u.parent u.parent)
            ::
            =.  feed  (put:orm:tf feed id.p p)
            $(rest t.rest, parent-id id.p, idx +(idx))        
      `this
      %feed-stats
        =/  posts  (tap:orm:tf feed)
        |-  ?~  posts  `this
          =/  post=post:tp  +.i.posts
          =/  full-node  (node-to-full:feedlib post feed)
          =/  count  (print-full-node:feedlib full-node)
          ~&  >  [post=id.full-node tree=count]
           $(posts t.posts)
      %threads-inspect
        =/  posts  (tap:orm:tf feed)
        =/  ignore  |-  ?~  posts  ~
          =/  p=post:tp  +.i.posts
          ?^  parent.p  $(posts t.posts)
          ~&  id=id.p
          =/  content  (content-map-to-md:postlib contents.p)
          ~&  >>  content
          ~&  children.p
          =/  ignore  ?~  children.p  ~
            =/  full-node  (node-to-full:feedlib p feed)
            =/  count  (print-full-node:feedlib full-node)
            ~

          $(posts t.posts)
          
        `this
      %feed-inspect
        =/  posts  (tap:orm:tf feed)
        =/  ignore  |-  ?~  posts  ~
          =/  p=post:tp  +.i.posts
          ~&  id=id.p
          =/  content  (content-map-to-md:postlib contents.p)
          ~&  >>  content
          =/  ign  ?^  parent.p
                      ~&  >  par=u.parent.p
                      ~&  >>>  ted=thread.p
                      ~  ~
          $(posts t.posts)
          
        `this
      [%ted-own @]
        =/  op  (got:orm:tf feed +.noun)
        =/  full-node  (node-to-full:feedlib op feed)
        =/  ted  (extract-thread:feedlib full-node)
        ~&  lent=(lent ted)
        =/  ignore  |-  ?~  ted  ~
                      =/  content  (content-map-to-md:postlib contents.i.ted)
                      ~&  id=id.i.ted
                      ~&  >>  content
                    $(ted t.ted)
        `this
      [%ted-inspect @]

        =/  posts  (tap:orm:tf feed)
        =|  ted-count=@
        =|  child-sum=@
        =/  c=[@ @]
        |-  ?~  posts  [ted-count child-sum]
          =/  p=post:tp  +.i.posts
          =/  nc  ?.  .=(thread.p +.noun)  [ted-count child-sum]
                       ~&  >  parent=parent.p
                       ~&  >>  id=id.p
                       ~&    children=children.p
                       ~&   >>>  ~(wyt in children.p)
                      [+(ted-count) (add child-sum ~(wyt in children.p))]
          $(posts t.posts, ted-count -.nc, child-sum +.nc)
        ~&  >>  posts-under-ted=c
       ~&  >>>  "**********************************************************"
       ~&  >>>  "**********************************************************"
        =/  op  (got:orm:tf feed +.noun)
        =/  full-node  (node-to-full:feedlib op feed)
        =/  count  (print-full-node:feedlib full-node)
        ~&  >>  descendants=count
        `this
      [%del-ted @]
        =/  posts  (tap:orm:tf feed)
        =.  feed
          |-  ?~  posts  feed
            =/  p=post:tp  +.i.posts
            =.  feed  ?.  .=(thread.p +.noun)  feed
            =<  +  (del:orm:tf feed id.p)
            $(posts t.posts)

        `this
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
      %ui
        =/  =fact:ui  [%post %add *post-wrapper:sur]
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
      ::  requires a relay
      :: 
      %rt0
          =/  rl  get-relay:mutan
          ?~  rl  ~&  >>>  "no relay!!!!"  `this
          =/  wid  -.u.rl
          =/  relay  +.u.rl
          =/  nclient  ~(. nostr-client [state bowl wid relay])
          =^  cards  relay  get-profiles:nclient
          =.  relays  (~(put by relays) wid relay)
        [cards this]
      %wstest
        :: =/  url  'ws://localhost:8888'
        :: =/  url  'wss://nos.lol'
        =/  rl  get-relay:mutan
        ?~  rl  ~&  >>>  "no relay!!!!"  `this
        =/  wid  -.u.rl
        =/  relay  +.u.rl
        =/  nclient  ~(. nostr-client [state bowl wid relay])
        =^  cs  relay  test-connection:nclient
        =.  relays  (~(put by relays) wid relay)
        [cs this]
      %rt  ::  relay test
        =/  rl  get-relay:mutan
        ?~  rl  ~&  >>>  "no relay!!!!"  `this
        =/  wid  -.u.rl
        =/  relay  +.u.rl
        =/  nclient  ~(. nostr-client [state bowl wid relay])
        =^  cards  relay  get-posts:nclient
        =.  relays  (~(put by relays) wid relay)
        [cards this]
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
  [%follow rest=*]
    =/  msg  ?~  rest.pole  ''  -.rest.pole
    =^  cs  state  (handle-req:coms [msg %fans] pole)
    [cs this]
  [%beg %feed rest=*]
    =/  msg  ?~  rest.pole  ''  -.rest.pole
    =^  cs  state  (handle-req:coms [msg %beg %feed] pole)
    [cs this]

  [%beg %thread ids=@t rest=*]
    =/  id  (slaw:sr %uw ids.pole)
    ?~  id  ~&  error-parsing-ted-id=pole  `this
    =/  msg  ?~  rest.pole  ''  -.rest.pole
    =^  cs  state  (handle-req:coms [msg %beg %thread u.id] pole)
    [cs this]

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
  ==
  
::
++  on-agent
  |~  [wire=(pole knot) =sign:agent:gall]
  ^-  (quip card:agent:gall agent:gall)
  ~&  on-agent=[wire -.sign]
  ::  if p.sign  is  not ~ here that means it's intentional
  ?+  wire  `this
    [%follow *]
      ?:  ?=(%watch-ack -.sign) 
        ?~  p.sign  `this
        =^  cs  state  (handle-kick-nack:fols src.bowl)  [cs this]
      ?:  ?=(%kick -.sign)
        =^  cs  state  (handle-refollow:fols src.bowl)
        [cs this]
      ?.  ?=(%fact -.sign)  `this

        ::  TODO why won't it unvase come on
        :: =/  =fact:comms  ;;  fact:comms  q.q.cage.sign
        =/  fact  !<([%fols fols-res:comms] q.cage.sign)
        =^  cs  state  (handle-follow-res:fols +.fact)
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
     :: ?>  ?=(%http -.u.msg)
     :: =^  cards  state  (handle-http:mutan sub-id.wire +.u.msg)
     :: `this
  ==
::
++  on-fail
  |~  [term tang]
  ^-  (quip card:agent:gall agent:gall)
  `this
--
