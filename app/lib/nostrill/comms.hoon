/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed
/+  js=json-nostr, sr=sortug,constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill
|_  [=state:sur =bowl:gall]
++  cast-poke
  |=  raw=*  ^-  poke:comms
  ;;  poke:comms  raw
::  Req
++  handle-req  |=  =req:comms
  ?-  -.req
    %feed    handle-feed
    %thread  (handle-thread +.req)
  ==
++  handle-feed
  =/  can  (can-access:gatelib src.bowl lock.feed-perms.state bowl)  
  ?.  can
   :: TODO keep track of the requests at the feed-perms struct
    =/  crd  (res-poke [%ng 'not allowed'])
    :_  state  :~(crd)
    ::
    =/  lp  latest-page:feedlib
    =/  lp2  lp(count backlog.feed-perms.state)
    =/  =fc:feed  (lp2 feed.state)
    =/  prof  (~(get by profiles.state) [%urbit our.bowl])
    =/  crd  (res-poke [%ok %feed fc prof])
    :_  state  :~(crd)

++  give-feed   
  |=  pat=path
  ~&  give-feed=src.bowl
  =/  can  (can-access:gatelib src.bowl lock.feed-perms.state bowl)  
  ?.  can
   :: TODO keep track of the requests at the feed-perms struct
    (res-fact [%ng 'not allowed'] pat)
    ::
    =/  lp  latest-page:feedlib
    =/  lp2  lp(count backlog.feed-perms.state)
    =/  =fc:feed  (lp2 feed.state)
    =/  prof  (~(get by profiles.state) [%urbit our.bowl])
    (res-fact [%ok %feed fc prof] pat)


++  give-ted  |=  [id=@ pat=path]
  =/  ted  (get:orm:feed feed.state id)
  ?~  ted
    (res-fact [%ng 'no such thread'] pat)
  =/  can  (can-access:gatelib src.bowl read.u.ted bowl)
  ?.  can
    (res-fact [%ng 'not allowed'] pat)
    ::
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    (res-fact [%ok %thread fn] pat)
::
++  handle-thread  |=  id=@da
  =/  ted  (get:orm:feed feed.state id)
  ?~  ted
    =/  crd  (res-poke [%ng 'no such thread'])
    :_  state  :~(crd)
  =/  can  (can-access:gatelib src.bowl read.u.ted bowl)
  ?.  can
    =/  crd  (res-poke [%ng 'not allowed'])
    :_  state  :~(crd)
    ::
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    =/  crd  (res-poke [%ok %thread fn])
    :_  state  :~(crd)
:: res
++  handle-res  |=  =res:comms
  `state
::
++  res-poke  |=  =res:comms   ^-  card:agent:gall
  =/  =poke:comms  [%res res]
  =/  cage  [%noun !>(poke)]
  [%pass /poke %agent [src.bowl dap.bowl] %poke cage]

++  res-fact  |=  [=res:comms pat=path]   ^-  (list card:agent:gall)
  =/  beg  ?=([%beg *] pat)
  =/  paths  ~[pat]
  ~&  >  giving-res-fact=pat
  ?:  beg  :: for the thread that goes directly to the frontend
    =/  jon  (beg-res:en:jsonlib res)
    =/  cage  [%json !>(jon)]
    =/  c1  [%give %fact paths cage]
    =/  c2  [%give %kick paths ~]
    :~(c1 c2)
  ::  for the follow flow
    =/  cage  [%noun !>([%init res])]
    =/  c1  [%give %fact paths cage]
    :~(c1)



--
