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
    :-  %a  %+  turn  (tap:norm:sur feed)  |=  [id=@ud ev=event:nsur]
      (event:en:nostr ev)

  ++  en-relays
  |=  r=(map @ relay-stats:nsur)  ^-  json
    %-  pairs  %+  turn  ~(tap by r)
    |=  [wid=@ud rs=relay-stats:nsur]
      :-  url.rs  %-  pairs
        :~  :-  %start  (time start.rs)
            :-  %wid    (numb wid)
            :-  %reqs   (relay-stats reqs.rs)
        ==
  ++  relay-stats  |=  rm=(map @t event-stats:nsur)
    %-  pairs  %+  turn  ~(tap by rm)  |=  [sub-id=@t es=event-stats:nsur]
      :: TODO do we even need this
      :-  sub-id  (numb received.es)

  ++  en-profiles  |=  m=(map user:sur user-meta:nsur)
    %-  pairs
      %+  turn  ~(tap by m)  |=  [key=user:sur p=user-meta:nsur]
        =/  jkey  (user key)
      ?>  ?=(%s -.jkey)
        :-  +.jkey  (user-meta:en:nostr p)

  ++  enfollowing
  |=  m=(map user:sur feed:tf)
  ^-  json
    %-  pairs  %+  turn  ~(tap by m)  |=  [key=user:sur f=feed:tf]
      =/  jkey  (user key)
      ?>  ?=(%s -.jkey)
      :: TODO proper cursor stuff
      :-  +.jkey  (feed-with-cursor:en:trill f ~ ~)

  ++  engraph
  |=  m=(map user:sur (set user:sur))
    ^-  json
    %-  pairs  %+  turn  ~(tap by m)  |=  [key=user:sur s=(set user:sur)]
      =/  jkey  (user key)
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
      %new   (fols +.f)
      %quit  (user +.f)
    ==
  ++  en-nostr  |=  nf=nostr-fact:ui  ^-  json
    %+  frond  -.nf
    ?-  -.nf
      %feed    (en-nostr-feed +.nf)
      %user    (en-nostr-feed +.nf)
      %thread  (en-nostr-feed +.nf)
      %event   (event:en:nostr +.nf)
      %relays  (en-relays +.nf)
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
      :-  %profile  ?~  profile.fd  ~  (user-meta:en:nostr u.profile.fd)
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
        :-  'profile'  ?~  prof.p  ~  (user-meta:en:nostr u.prof.p)
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
    thread+de-pid
  ==
++  de-pid
  %-  ot  :~
    host+(se:de:common %p)
    id+de-atom-id
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
    other+other-meta
  ==
++  other-meta  |=  jon=json
  ?.  ?=(%o -.jon)  ~  (some p.jon)
++  ui-post
  %-  of  :~
    add+postadd
    reply+reply
    quote+quote
    rp+pid
    :: rt+de-rt
    reaction+reaction
    del+pid
  ==
++  postadd
  %-  ot  :~
    content+so
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
++  pid
  %-  ot  :~
    host+user
    id+de-atom-id
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
    sync+ul
    prof+ul
    user+hex:de:common
    thread+hex:de:common
    send+de-relay-send
  ==
++  de-relay-send  %-  ot  :~
    host+(se:de:common %p)
    id+de-atom-id
    relays+(ar so)
  ==

++  de-post-id
  |=  jon=json  ^-  (unit @)
  ?.  ?=([%s @t] jon)  ~
  =/  tryatom  (rush p.jon dem)
  ?^  tryatom  tryatom
  ^-  (unit @)  (hex:de:common jon)

++  de-atom-id
  |=  jon=json  ^-  (unit @)
  ?.  ?=([%s @t] jon)  ~
  (rush p.jon dem)

  --
      
--

