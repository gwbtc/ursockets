/-  wrap, sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui, noti=nostrill-notif,
    tf=trill-feed, tp=trill-post,
    wrap
/+  sr=sortug, common=json-common, trill=json-trill, nostr=json-nostr
|%
++  en
=,  enjs:format
|%
  ::  UI comms
  ++  state  |=  state-0:sur  ^-  json
  %+  frond  %state
  %:  pairs
    relays+(en-relays relays)
    key+(hex:en:common pub.i.keys)
    profiles+(en-profiles profiles)
    :: TODO proper cursors
    feed+(feed-with-cursor:en:trill feed ~ ~)
    nostr+(en-nostr-feed nostr-feed)
    following+(enfollowing following)
    following2+(global-with-cursor following2 ~ ~)
    ['followGraph' (engraph follow-graph)]
  ~
  ==

  ++  en-global  |=  gf=global-feed:sur  ^-  json
    %-  pairs
    %+  turn  (tap:uorm:sur gf)
    |=  [=upid:sur p=post:tp]
      ^-  [@ta json]
    :-  (crip (scow:sr %ud `@ud`id.upid))
        (poast:en:trill p)

  ++  global-with-cursor
    |=  [gf=global-feed:sur start=(unit @da) end=(unit @da)]  ^-  json
    %:  pairs
      global+(en-global gf)
      start+(cursor:en:trill start)
      end+(cursor:en:trill end)
    ~
    ==
  ++  en-nostr-feed
  |=  feed=nostr-feed:sur  ^-  json
    :-  %a  %+  turn  (tap:norm:sur feed)  |=  [id=@ud wev=wevent:nsur]
      (wevent:en:nostr wev)

  ++  en-relays
  |=  r=(map @ relay-stats:nsur)  ^-  json
    %-  pairs  %+  turn  ~(tap by r)
    |=  [wid=@ud rs=relay-stats:nsur]
      :-  url.rs  %-  pairs
        :~  :-  %start  (time start.rs)
            :-  %wid    (numb wid)
            :-  %reqs   (relay-stats reqs.rs)
        ==
  ++  relay-stats  |=  rm=(map @t req-state:nsur)
    %-  pairs  %+  turn  ~(tap by rm)  |=  [sub-id=@t rq=req-state:nsur]
      :-  sub-id
        %-  pairs
        :~  :+  'name'     %s  name.rq
            :+  'filters'  %a  (turn filters.rq filter:en:nostr)
            :: ::  TODO  chunks...
            :-  'eventsReceived'  (numb received.rq)
            :-  'ongoing'  ?~  ongoing.rq  ~  [%b u.ongoing.rq]
        ==

  ++  en-profiles  |=  m=(map user:sur user-profile:comms)
    %-  pairs
      %+  turn  ~(tap by m)  |=  [key=user:sur p=user-profile:comms]
        =/  jkey  (user-string key)
      ?>  ?=(%s -.jkey)
        :-  +.jkey  (en-profile p)

  ++  en-profile  |=  prof=user-profile:comms
    %-  pairs  %+  weld
    :~
      :-  'pubkey'  (hex:en:common pubkey.prof)
      :+  'following'  %a  %+  turn  ~(tap in following.prof)  user
      :-  'followingCount'  (numb following-count.prof)
      :+  'followers'  %a  %+  turn  ~(tap in followers.prof)  user
      :-  'followerCount'  (numb follower-count.prof)      
    ==
  (user-meta-pairs:en:nostr +>+>+:prof)

  ++  enfollowing
  |=  m=(map user:sur feed:tf)
  ^-  json
    %-  pairs  %+  turn  ~(tap by m)  |=  [key=user:sur f=feed:tf]
      =/  jkey  (user-string key)
      ?>  ?=(%s -.jkey)
      :: TODO proper cursor stuff
      :-  +.jkey  (feed-with-cursor:en:trill f ~ ~)

  ++  engraph
  |=  m=(map user:sur (set user:sur))
    ^-  json
    %-  pairs  %+  turn  ~(tap by m)  |=  [key=user:sur s=(set user:sur)]
      =/  jkey  (user-string key)
      ?>  ?=(%s -.jkey)
      :-  +.jkey
      :-  %a   %+  turn  ~(tap in s)  user

  ++  follow  
    |=  f=follow:sur
    %-  pairs
      :~  pubkey+(hex:en:common pubkey.f)
          name+s+name.f
          :-  %relay  ?~  relay.f  ~  s+u.relay.f
      ==
  ++  user  |=  u=user:sur  ^-  json
    %+  frond  -.u
    ?-  -.u
      %urbit  (patp:en:common +.u)
      %nostr  (hex:en:common +.u)
    ==
  ++  user-string  |=  u=user:sur  ^-  json
    ?-  -.u
      %urbit  (patp:en:common +.u)
      %nostr  (hex:en:common +.u)
    ==
  ::  ui facts
  ++  fact  |=  f=fact:ui  ^-  json
    %+  frond  %fact
    %+  frond  -.f
    ?-  -.f
      %nostr   (en-nostr +.f)
      %post    (postfact +.f)
      %prof    (en-profiles +.f)
      %fols    (folsfact +.f)
      %keys    (hex:en:common +.f)
    ==
  ++  folsfact  |=  f=fols-fact:ui  ^-  json
    %+  frond  -.f
    ?-  -.f
      %new-urbit  (fols +.f)
      %new-nostr  (en-followed +.f)
      %quit  (user-string +.f)
    ==
  ++  en-nostr  |=  nf=nostr-fact:ui  ^-  json
    %+  frond  -.nf
    ?-  -.nf
      %feed    (en-nostr-feed +.nf)
      %user    (en-nostr-feed +.nf)
      %thread  (en-nostr-feed +.nf)
      %event   (event:en:nostr +.nf)
      %eose    (cord:en:common +.nf)
      %relays  (en-relays +.nf)
      ::
      %sent-post  (en-nostr-sent-post +.nf)
      %sent-prof  [%a (turn relays.nf cord:en:common)]
    ==
  ++  en-followed  |=  [pubkey=@ux profile=(unit user-profile:comms) relays=(list @t)]
    %-  pairs  :~
      pubkey+(hex:en:common pubkey)
      :-  %profile  ?~  profile  ~  (en-profile u.profile)
      relays+a+(turn relays cord:en:common)
    ==
  ++  en-nostr-sent-post  |=  [host=@p id=@ urls=(list @t) ev=event:nsur]  ^-  json
    %-  pairs  :~
      host+s+(scot %p host)
      id+(ud:en:common id)
      relays+a+(turn urls cord:en:common)
      event+(event:en:nostr ev)
    ==
  ++  user-data
    |=  ud=[=fc:tf profile=(unit user-meta:nsur)]
    %:  pairs
      feed+(feed-with-cursor:en:trill fc.ud)
      :-  %profile  ?~  profile.ud  ~  (user-meta:en:nostr u.profile.ud)
      ~
    ==
::  en-CMMS
  ++  deferred  |*  [p=(deferred:wrap) fn=$-(* json)]
    ^-  json
    %-  pairs  :~  msg+s+msg.p
      :-  'data'  ?@  p.p  [%s 'maybe']
                           (approval +.p.p fn)
    ==
  ++  approval  |*  [p=(approval:wrap) fn=$-(* json)]
    ^-  json
    ?@  p  ~  (fn data.p)

  ++  enbowl  |*  [p=(enbowl:wrap) fn=$-(* json)]
    ^-  json
    %-  pairs
    :~  user+(user user.p)
        ts+(time ts.p)
        data+(fn p.p)
    ==

  ++  res  |=  =res:comms  ^-  json
    %+  frond  -.res
    ?-  -.res
      %feed  (deferred +.res feed-data)
      %thread  %-  pairs
        :~  id+(ud:en:common id.res)
            data+(deferred +>.res thread:en:trill)
        ==
    ==
  ++  en-fols  |=  p=fols-res:comms  ^-  json
    (deferred p feed-data)

  ++  fols  |=  a=(enbowl:wrap fols-res:comms)  ^-  json
    (enbowl a en-fols)

  ++  postfact  |=  pf=post-fact:comms  ^-  json
    %+  frond  -.pf
    (post-wrapper +.pf)

  ++  feed-data
    |=  fd=feed-data:comms
    %:  pairs
      feed+(feed-with-cursor:en:trill fc.fd)
      profile+(en-profile profile.fd)
      ~
    ==

  ++  post-wrapper  |=  p=post-wrapper:comms
    %-  pairs
    :~  post+(poast:en:trill post.p)
        ['nostrMeta' (nostr-meta nostr-meta.p)]
    ==
  ++  nostr-meta  |=  p=nostr-meta:comms  ^-  json
    %-  pairs
    :~  ['pubkey' (hex:en:common pub.p)]
        :-  'profile'  ?~  prof.p  ~  (en-profile u.prof.p)
        :-  'eventId'  ?~  ev-id.p  ~  (hex:en:common u.ev-id.p)
        :+  'relay'  %a  %+  turn  relays.p  cord:en:common
    ==
    
::  /en-COMMS
  --
++  de
=,  dejs-soft:format
|%
++  user
  %-  of  :~
    urbit+(se:de:common %p)
    nostr+hex:de:common
  ==
  :: ui
++  ui
  %-  of  :~
    keys+ul
    fols+ui-fols
    begs+ui-begs
    prof+ui-prof
    post+ui-post
    rela+ui-relay
  ==
++  ui-fols
  %-  of  :~
    add+user
    del+user
  ==
++  ui-begs
  %-  of  :~
    feed+(se:de:common %p)
    thread+pid:de:trill
  ==
++  ui-prof
  %-  of  :~
    add+ui-meta
    del+ul
    fetch+(ar user)
  ==
++  ui-meta
  %-  ot  :~
    name+so
    about+so
    picture+so
    patp+de-unit-patp
    other+other-meta
  ==
++  de-unit-patp  |=  jon=json  ^-  (unit (unit @p))
  ?.  ?=(%s -.jon)  ~
  %-  some  ((se:de:common %p) jon)
  ::  we have this for type economy but a user does not get to change their profile's @p in the UI

++  other-meta  |=  jon=json
  ?.  ?=(%o -.jon)  ~  (some p.jon)
++  ui-post
  %-  of  :~
    add+postadd
    reply+reply
    quote+quote
    rp+upid
    :: rt+de-rt
    reaction+reaction
    del+upid
  ==
++  postadd
  %-  ot  :~
    content+so
    global+bo
    anon+bo
  ==
++  reply
  %-  ot  :~
    content+so
    host+user
    id+de-post-id
    id+de-post-id
  ==
++  quote
  %-  ot  :~
    content+so
    host+user
    id+de-post-id
  ==
++  upid
  %-  ot  :~
    host+user
    id+string-ud:de:common
  ==
++  reaction
  %-  ot  :~
    host+user
    id+de-post-id
    reaction+so
  ==
++  rt
  %-  ot  :~
    id+hex:de:common
    pubkey+hex:de:common
    relay+so
  ==
++  ui-relay
  %-  of  :~
    add+so
    del+ni
    do+de-relay-do
  ==
++  de-relay-do
  %-  ot
  :~  relays+(ar ni)
      action+de-relay-action
  ==

  ++  de-relay-action
    %-  of  :~
      sync+ul
      prof+ul
      user+hex:de:common
      thread+hex:de:common
      send-post+pid:de:trill
      send-prof+ul
      ==
++  de-post-id
  |=  jon=json  ^-  (unit @)
  ?.  ?=([%s @t] jon)  ~
  =/  tryatom  (rush p.jon dem)
  ?^  tryatom  tryatom
  ^-  (unit @)  (hex:de:common jon)

  --
      
--

