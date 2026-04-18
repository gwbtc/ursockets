/-  sur=nostrill, nsur=nostr
/+  js=json-nostr, sr=sortug, seq, nostr-keys, constants, server, ws=websockets, evlib=nostr-events, lib=nostrill
/=  web  /web/router
|_  [=state:sur =bowl:gall]
+$  card  card:agent:gall
::  general utils
++  parse-msg
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (unit relay-msg:nsur)
  ?~  body.request.req  ~
  =/  jstring  q.u.body.request.req
  (parse-body jstring)
++  parse-body  |=  jstring=@t
  =/  ures  (de:json:html jstring)
  ?~  ures  ~
  =/  ur  (relay-msg:de:js u.ures)
  ?~  ur  ~&  >>>  relay-msg-parsing-failed=jstring  ~
  ur
++  close-sub-req  |=  [sub-id=@t wid=@ud relay=relay-stats:nsur]
  ^-  [client-msg:nsur relay-stats:nsur]
  =.  reqs.relay  (~(del by reqs.relay) sub-id)
  =/  req=client-msg:nsur  [%close sub-id]
  [req relay]

++  build-req
|=  fs=(list filter:nsur)
^-  [%req relay-req:nsur]
  =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
  =/  msg  [%req sub-id fs]
  msg
++  init-req
|=  [name=@t fs=(list filter:nsur) ongoing=(unit ?) chunked=(list filter:nsur)]
  ^-  req-state:nsur
  =/  req=req-state:nsur  [name fs 0 ongoing chunked]
  req

++  req-to-msg  |=  req=client-msg:nsur  ^-  websocket-message:eyre
  =/  req-body=json  (req:en:js req)
  =/  octs  (json-to-octs:server req-body)
  =/  wmsg=websocket-message:eyre  [1 `octs]
  wmsg

++  set-req
  |=  [relay=relay-stats:nsur name=@t fs=(list filter:nsur) ongoing=(unit ?) chunked=(list filter:nsur)]
  ^-  [[%req relay-req:nsur] relay-stats:nsur]
    =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
    =/  msg  [%req sub-id fs]
    =/  req=req-state:nsur  [name fs 0 ongoing chunked]
    =.  reqs.relay  (~(put by reqs.relay) sub-id req)
    [msg relay]

++  global
  |%
  ++  get-wid  ^-  (unit @)
    =/  usocket  (check-connected:ws global-relay:constants bowl)
    ?~  usocket  ~
    %-  some  -.u.usocket
    :: ?~  global-relay-conn.state  ~&  >>>  "not connected to global relay"  !!
    :: u.global-relay-conn.state
  ::
  :: TODO not fucking working
  :: guess it doesn't await for %pending to resolve properly
  ++  send-and-close  |=  req=client-msg:nsur  ^-  card
    =/  wmsg  (req-to-msg req)
    (one-off:ws global-relay:constants wmsg bowl)    


  ++  send-card  |=  req=client-msg:nsur  ^-  card
    =/  wmsg  (req-to-msg req)
    =/  wid  get-wid
    ?~  wid  ~&  >>>  "not connected to global relay, running thread"
             (send-and-close req)
             (give-ws-payload-client:ws u.wid wmsg)

  ::  filter builders
  ++  get-profiles-from-global
    ^-  (list card)
    ~&  >>>  "getting profiles from global"
    =/  kinds  (silt ~[0])
    =/  =filter:nsur  [~ ~ `kinds ~ ~ ~ ~]
    :: =/  req-name  'fetch all user profiles'
    =/  req  (build-req ~[filter])
    :~  (send-card req)
    ==
    :: Doing this directly from frontend as relaying ws messages through backend is rather pointless
    :: global feed
    :: ++  get-global
    ::     =/  kinds  (silt ~[667])
    ::     =/  since  ~
    ::     =/  =filter:nsur  [~ ~ `kinds ~ ~ ~ ~]
    ::     =/  req-name  'global feed'
    ::
  
  --
++  relay
  |_  [wid=@ud relay=relay-stats:nsur]  
  :: ++  test-connection
  ::   =/  kinds  (silt ~[1])
  ::   =/  since  (sub now.bowl ~m10)
  ::   =/  =filter:nsur  [~ ~ `kinds ~ `since ~ ~]
  ::   =/  sub-id  (gen-sub-id:nostr-keys eny.bowl)
  ::   =/  req=client-msg:nsur  [%req sub-id ~[filter]]
  ::   :-  :~  (send url.relay req)  ==  relay

  ++  send-card  |=  req=client-msg:nsur  ^-  card
    =/  wmsg  (req-to-msg req)
    (give-ws-payload-client:ws wid wmsg)
  ::
  ++  get-posts
    =/  kinds  (silt ~[1])
    =/  from::  look in settings agent
      ?.  .^(? %gx /(scot %p our.bowl)/settings/(scot %da now.bowl)/has-entry/nostrill/relay/backlog-size/noun)
      ~h1
      =/  res  .^(* %gx /(scot %p our.bowl)/settings/(scot %da now.bowl)/entry/nostrill/relay/backlog-size/noun)
      =/  hours  ?>  ?=(@ +>.res)  +>.res
      (mul hours ~h1)
    ~&  >>>  from=from
    :: =/  since  (sub now.bowl from)
    =/  since  (sub now.bowl ~m10)


    =/  =filter:nsur  [~ ~ `kinds ~ `since ~ ~]
    =/  filters  ~[filter]
    =/  req-name  'timeline'
    |%
    ++  ted
      ^-  [sub-id=@t rs=req-state:nsur =card]
      =/  req  (build-req filters)
      =/  sub-id=@t  sub-id.req
      ~&  get-posts-ted=sub-id
      =/  card  (send-card req)
      =/  rs=req-state:nsur  (init-req req-name filters ~ ~)
      [sub-id rs card]
    ++  sub
      =^  req  relay  (set-req relay req-name ~[filter] ~ ~)
      ~&  get-posts-sub=req
      :_  relay
      :~  (send-card req)
      ==
    --

  ++  get-user-feed
    |=  pubkey=@ux
    =/  kinds  (silt ~[1])
    :: =/  since  (sub now.bowl ~d30)
    =/  since  (sub now.bowl ~d1)
    =/  pubkeys  (silt ~[pubkey])
    =/  =filter:nsur  [~ `pubkeys `kinds ~ `since ~ ~]
    =/  req-name  'user sub'
    =^  req  relay  (set-req relay req-name ~[filter] `.n ~)
    :_  relay
    :~  (send-card req)
    ==
  ++  unfollow-user
    |=  pubkey=@ux
    =/  reqs  ~(tap by reqs.relay)
    |-  ?~  reqs  `relay
      =/  sub-id=@t  -.i.reqs
      =/  rs=req-state:nsur  +.i.reqs
      ?.  (is-specific-user-sub:evlib pubkey filters.rs)
        $(reqs t.reqs)
      ::
      =^  req  relay  (close-sub-req sub-id wid relay)
      :_  relay
      :~  (send-card req)
      ==

  ++  get-thread  |=  id=@ux
    =/  kinds  (silt ~[1])
    =/  ids  (silt :~(id))
    =/  f1=filter:nsur  [`ids ~ `kinds ~ ~ ~ ~]
    =/  ids=(list @t)  :~((crip (scow:parsing:sr %ux id)))
    =/  tag  ['e' ids]
    =/  tags=(map @t (list @t))  (malt :~(tag))
    =/  f2=filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
    ~&  >>>  getting-thread=[f1 f2]
    =/  req-name  'thread sub'
    =^  req  relay  (set-req relay req-name ~[f1 f2] `.n ~)
    :_  relay
    :~  (send-card req)
    ==

  ++  get-post  |=  id=@ux
    =/  kinds  (silt ~[1])
    =/  ids  (silt :~(id))
    =/  =filter:nsur  [`ids ~ `kinds ~ ~ ~ ~]
    =/  req-name  'fetch post'
    =^  req  relay  (set-req relay req-name ~[filter] ~ ~)
    :_  relay
    :~  (send-card req)
    ==

  ++  get-replies  |=  id=@ux
    =/  kinds  (silt ~[1])
    =/  ids=(list @t)  :~((crip (scow:parsing:sr %ux id)))
    =/  tag  ['e' ids]
    =/  tags=(map @t (list @t))  (malt :~(tag))
    =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
    =/  req-name  'post replies sub'
    =^  req  relay  (set-req relay req-name ~[filter] `.n ~)
    :_  relay
    :~  (send-card req)
    ==
  ::
  ++  get-profile  |=  pubkey=@ux
    =/  kinds  (silt ~[0])
    =/  pubkeys  (silt ~[pubkey])
    =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
    =/  req-name  'user profile fetch'
    =^  req  relay  (set-req relay req-name ~[filter] ~ ~)
    :_  relay
    :~  (send-card req)
    ==

  ++  get-profiles
    ^-  (quip card relay-stats:nsur)
    ~&  >>>  "getting profiles"
    =/  npoasts  (tap:norm:sur nostr-feed.state)
    =/  req-name  'user profiles fetch'
    =|  missing-profs=(set @ux)
    =/  pubkeys=(set @ux)
      |-  ?~  npoasts  missing-profs
        =/  poast=event:nsur  +>.i.npoasts
        =/  have  (~(has by profiles.state) [%nostr pubkey.poast])
        =?  missing-profs  !have  (~(put in missing-profs) pubkey.poast)
      $(npoasts t.npoasts)
    =/  kinds  (silt ~[0])
    =/  chunk-size  300
    ~&  >>  fetching-profiles=~(wyt in pubkeys)
    =^  req  relay
    ?.  (gth ~(wyt in pubkeys) chunk-size)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (set-req relay req-name ~[filter] ~ ~)
      ::
      =/  chunks=(list (list @ux))  (chunk-by-size:seq ~(tap in pubkeys) chunk-size)
      ?~  chunks  ~&  >>>  "error chunking pubkeys"  !!
      =/  queue=(list filter:nsur)
        %+  turn  t.chunks  |=  l=(list @ux)  ^-  filter:nsur
        =/  pubkeys=(set @ux)  (silt l)
        [~ `pubkeys `kinds ~ ~ ~ ~]
      =/  pubkeys=(set @ux)  (silt i.chunks)
      =/  =filter:nsur  [~ `pubkeys `kinds ~ ~ ~ ~]
      (set-req relay req-name ~[filter] ~ queue)

    =/  sub-id=@t  sub-id.req
    ~&  >>>  profiles-sub-id=sub-id
    :_  relay
    :~  (send-card req)
    ==


  ++  get-engagement
    |=  post-ids=(set @ux)
      =/  post-strings  %+  turn  ~(tap in post-ids)  |=  id=@ux  (crip (scow:sr %ux id))
      =/  =filter:nsur
        =/  kinds  (silt ~[6 7])
        =/  tags  (malt :~([%e post-strings]))
        [~ ~ `kinds `tags ~ ~ ~]
    =/  req-name  'post engagement sub'
    =^  req  relay  (set-req relay req-name ~[filter] `.n ~)
    :_  relay
    :~  (send-card req)
    ==

  ++  get-quotes
    |=  post-id=@ux
      =/  post-string  (crip (scow:sr %ux post-id))
      =/  kinds  (silt ~[1])
      =/  tags  (malt :~([%q ~[post-string]]))
      =/  =filter:nsur  [~ ~ `kinds `tags ~ ~ ~]
    =/  req-name  'post quotes sub'
    =^  req  relay  (set-req relay req-name ~[filter] `.n ~)
    :_  relay
    :~  (send-card req)
    ==

  ++  get-follows
    |=  pubkey=@ux
      =/  =filter:nsur
        =/  kinds  (silt ~[3])
        =/  authors  (silt ~[pubkey])
        [~ `authors `kinds ~ ~ ~ ~]
      =/  req-name  'user follows fetch'
      =^  req  relay  (set-req relay req-name ~[filter] ~ ~)
      :_  relay
      :~  (send-card req)
      ==

    
  ++  get-followers
    |=  pubkey=@ux
      =/  pubkeys  (crip (scow:parsing:sr %ux pubkey))
      =/  =filter:nsur
        =/  kinds  (silt ~[3])
        =/  tags  (malt :~([%p ~[pubkeys]]))
        [~ ~ `kinds `tags ~ ~ ~]
    ::  TODO probably will need to chunk?
    =/  req-name  'user followers sub'
    =^  req  relay  (set-req relay req-name ~[filter] `.n ~)
    :_  relay
    :~  (send-card req)
    ==
  --
--
