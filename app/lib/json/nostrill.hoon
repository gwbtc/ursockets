/-  sur=nostrill, nsur=nostr, feed=trill-feed, comms=nostrill-comms
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
    following2+(feed-with-cursor:en:trill following2 ~ ~)
    ['followGraph' (engraph follow-graph)]
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
  |=  m=(map user:sur feed:feed)
  ^-  json
    %-  pairs  %+  turn  ~(tap by m)  |=  [key=user:sur f=feed:feed]
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
  ++  fact  |=  f=fact:ui:sur  ^-  json
    %+  frond  %fact
    %+  frond  -.f
    ?-  -.f
      %nostr   (en-nostr-feed +.f)
      %post    (postfact +.f)
      %enga    (enga +.f)
      %fols    (fols +.f)
      %hark    (hark +.f)
    ==
  ++  fols  |=  ff=fols-fact:ui:sur  ^-  json
    %+  frond  -.ff
    ?-  -.ff
      %quit  (user +.ff)
      %new  %:  pairs
              user+(user user.ff)
              feed+(feed-with-cursor:en:trill fc.ff)
              :-  'profile'  ?~  meta.ff  ~  (user-meta:en:nostr u.meta.ff)
            ~
        ==
    ==
  ++  tedfact  |=  pf=post-fact:ui:sur  ^-  json
    %+  frond  -.pf
    (post-wrapper +.pf)
  ++  postfact  |=  pf=post-fact:ui:sur  ^-  json
    %+  frond  -.pf
    (post-wrapper +.pf)

  ++  enga  |=  [pw=post-wrapper:sur reaction=*]
     :: TODO
    ^-  json
    ~
  ++  hark  |=  =notif:sur
    ^-  json
    %+  frond  -.notif
    ?-  -.notif
      %prof  (prof-notif +.notif)
      %fols  (pairs :~(['user' (user user.notif)] ['accepted' %b accepted.notif] ['msg' %s msg.notif]))
      %fans  (user p.notif)
      %beg   (beg-notif +.notif)
      %post  (post-notif +.notif)
    ==
  ++  prof-notif  |=  [u=user:sur prof=user-meta:nsur]
    %-  pairs
    :~  user+(user u)
        profile+(user-meta:en:nostr prof)
    ==
  ++  beg-notif  |=  [beg=begs-poke:ui:sur accepted=? msg=@t]
    ^-  json
    %+  frond  -.beg
    %-  pairs
      :~  ['accepted' %b accepted]
          ['msg' %s msg]
        ?-  -.beg
          %feed    ['ship' %s (scot %p +.beg)]
          %thread  ['post' (pid:en:trill +.beg)]
        ==
      ==

  ++  post-notif  |=  [pid=[@p @da] u=user:sur p=post-notif:sur]
    ^-  json
    %-  pairs
      :~  ['post' (pid:en:trill pid)]
          ['user' (user u)]
          :-  -.p
          ?-  -.p
            %reply  (poast:en:trill +.p)
            %quote  (poast:en:trill +.p)
            %reaction  [%s +.p]
            %rp    ~
            %del   ~
          ==
      ==
  ++  post-wrapper  |=  p=post-wrapper:sur
    %-  pairs
    :~  post+(poast:en:trill post.p)
        ['nostrMeta' (nostr-meta nostr-meta.p)]
    ==
  ++  nostr-meta  |=  p=nostr-meta:sur
    =|  l=(list [@t json])
    =.  l  ?~  pub.p    l  :_  l  ['pubkey' (hex:en:common u.pub.p)]
    =.  l  ?~  ev-id.p  l  :_  l  ['eventId' (hex:en:common u.ev-id.p)]
    =.  l  ?~  relay.p  l  :_  l  ['relay' %s u.relay.p]
    =.  l  ?~  pr.p     l  :_  l  ['profile' (user-meta:en:nostr u.pr.p)]
    %-  pairs  l

  ++  beg-res  |=  =res:comms  ^-  json
    %+  frond  %begs  %+  frond  -.res
    ?-  -.res
      %ok  (resd +.res)
      %ng  [%s msg.res]
    ==
  ++  resd  |=  rd=res-data:comms  ^-  json
    ?-  -.rd
      %feed     (user-data +.rd)
      :: TODO wrap it for nostr shit
      %thread   (frond -.rd (full-node:en:trill +.rd))
    ==
  ++  user-data
    |=  ud=[=fc:feed profile=(unit user-meta:nsur)]
    %:  pairs
      feed+(feed-with-cursor:en:trill fc.ud)
      :-  %profile  ?~  profile.ud  ~  (user-meta:en:nostr u.profile.ud)
      ~
    ==
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
    host+(se:de:common %p)
    id+de-atom-id
    thread+de-atom-id
  ==
++  quote
  %-  ot  :~
    content+so
    host+(se:de:common %p)
    id+de-atom-id
  ==
++  pid
  %-  ot  :~
    host+(se:de:common %p)
    id+de-atom-id
  ==
++  reaction
  %-  ot  :~
    host+(se:de:common %p)
    id+de-atom-id
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
    del+de-atom-id
    sync+ul
    send+de-relay-send
  ==
++  de-relay-send  %-  ot  :~
    host+(se:de:common %p)
    id+de-atom-id
    relays+(ar so)
  ==
++  de-atom-id
  |=  jon=json  ^-  (unit @)
  ?.  ?=([%s @t] jon)  ~
  (rush p.jon dem)

  --
      
--

