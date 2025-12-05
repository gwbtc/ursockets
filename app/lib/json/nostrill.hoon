/-  sur=nostrill, nsur=nostr, feed=trill-feed, post=trill-post, comms=nostrill-comms, noti=nostrill-noti, ui=nostrill-ui
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
    perms+(gate:en:trill feed-perms)
    nostr+(en-nostr-feed nostr-feed)
    following+(enfollowing following)
    following2+(global-with-cursor following2 ~ ~)
    ['followGraph' (engraph follow-graph)]
  ~
  ==
  ++  en-global  |=  gf=global-feed:sur  ^-  json
    %-  pairs
    %+  turn  (tap:uorm:sur gf)
    |=  [=upid:sur p=post:post]
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
  ++  fact  |=  f=fact:ui  ^-  json
    %+  frond  %fact
    %+  frond  -.f
    ?-  -.f
      %nostr   (en-nostr +.f)
      %post    (postfact +.f)
      %prof    (en-profiles +.f)
      %fols    (fols +.f)
      %keys    (hex:en:common +.f)
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
  ++  fols  |=  a=(enbowl:sur fols-res:comms)  ^-  json
    %-  pairs
    :~  user+(user user.a)
        :-  %data  (en-fols p.a)
    ==

  ++  postfact  |=  pf=post-fact:comms  ^-  json
    %+  frond  -.pf
    (post-wrapper +.pf)

  ++  hark  |=  =notif:noti
    ^-  json
    ::  TODO remove as we're using %hark instead
    ~
  ::   %+  frond  -.notif
  ::   ?-  -.notif
  ::     %prof  (prof-notif +.notif)
  ::     %fols  (pairs :~(['user' (user user.notif)] ['accepted' %b accepted.notif] ['msg' %s msg.notif]))
  ::     %fans  (pairs :~(['user' (user user.notif)] ['msg' %s msg.notif]))
  ::     %beg   (beg-notif +.notif)
  ::     %post  (post-notif +.notif)
  ::   ==
  :: ++  prof-notif  |=  [u=user:sur prof=user-meta:nsur]
  ::   %-  pairs
  ::   :~  user+(user u)
  ::       profile+(user-meta:en:nostr prof)
  ::   ==
  :: ++  beg-notif  |=  [beg=begs-poke:ui accepted=? msg=@t]
  ::   ^-  json
  ::   %+  frond  -.beg
  ::   %-  pairs
  ::     :~  ['accepted' %b accepted]
  ::         ['msg' %s msg]
  ::       ?-  -.beg
  ::         %feed    ['ship' %s (scot %p +.beg)]
  ::         %thread  ['post' (pid:en:trill +.beg)]
  ::       ==
  ::     ==

  :: ++  post-notif  |=  [pid=[@p @da] u=user:sur p=post-notif:sur]
  ::   ^-  json
  ::   %-  pairs
  ::     :~  ['post' (pid:en:trill pid)]
  ::         ['user' (user u)]
  ::         :-  -.p
  ::         ?-  -.p
  ::           %reply  (poast:en:trill +.p)
  ::           %quote  (poast:en:trill +.p)
  ::           %reaction  [%s +.p]
  ::           %rp    ~
  ::           %del   ~
  ::         ==
  ::     ==
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

  ++  res  |=  =res:comms  ^-  json
    %+  frond  %res  %-  pairs
    :~  :-  %req-msg  [%s req-msg.res]
        :-  -.p.res  ?-  -.p.res
                         %begs  (en-beg +.p.res)
                         %fols  (en-fols +.p.res)
                       ==
    ==

  ++  en-fols  |=  p=fols-res:comms  ^-  json
    %-  pairs
    :~  msg+s+msg.p
        :-  %data  ?@  p.p  ~  (feed-data p.p.p)
    ==
  ++  en-beg   |=  p=beg-res:comms  ^-  json
    %-  pairs
    :~  msg+s+msg.p
       :-  %data  ?-  -.p.p
                    %feed     ?@  p.p.p  (frond -.p.p ~)  (feed-data p.p.p.p)  
                    %thread   %+  frond  -.p.p
                      %-  pairs
                      :~  ['id' (ud:en:common id.p.p)]
                          :-  %data  ?@  p.p.p  ~  (thread:en:trill p.p.p.p)
                      ==

                ==
    ==

  ++  feed-data
    |=  fd=feed-data:comms
    %:  pairs
      feed+(feed-with-cursor:en:trill fc.fd)
      :-  %profile  ?~  profile.fd  ~  (user-meta:en:nostr u.profile.fd)
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
    fols+ui-fols
    begs+ui-begs
    prof+ui-prof
    keys+ul
    post+ui-post
    rela+ui-relay
    reqs+ui-reqs
  ==
++  ui-reqs
%-  of  :~
  handle+ui-req-handle
  del+de-atom-id
  ==
++  ui-req-handle
%-  ot  :~
  id+de-atom-id
  approve+bo
  msg+so
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
|=  j=json   ~ 
  :: %-  of  :~
  ::   add+postadd
  ::   reply+reply
  ::   quote+quote
  ::   rp+upid
  ::   :: rt+de-rt
  ::   reaction+reaction
  ::   del+upid
  ::   perms+perms-poke
  :: ==
++  perms-poke
  %-  ot  :~
    pid+de-pid
    perms+perms:de:trill
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
++  upid
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

