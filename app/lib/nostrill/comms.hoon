/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed, post=trill-post
/+  js=json-nostr, sr=sortug,constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, lib=nostrill, harklib=hark
|_  [=state:sur =bowl:gall]
++  cast-poke
  |=  raw=*  ^-  poke:comms
  ;;  poke:comms  raw
::  Req
++  handle-req  |=  =req:comms
::  TODO keep this in some inbox, don't respond immediately
  ?-  -.req
    %feed    (handle-feed +.req)
    %thread  (handle-thread +.req)
  ==
++  handle-feed  |=  beg-msg=@t
  =/  n=notif:sur  [%beg-req [%urbit src.bowl] [%feed our.bowl] beg-msg]
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)

  =/  can  (can-access:gatelib src.bowl lock.feed-perms.state bowl)  
  ?.  can
   :: TODO keep track of the requests at the feed-perms struct
    =/  crd  (res-poke [%ng [%feed beg-msg] 'not allowed'])
    :_  state  :~(hark-card crd)
    ::
    =/  lp  latest-page:feedlib
    =/  lp2  lp(count backlog.feed-perms.state)
    =/  =fc:feed  (lp2 feed.state)
    =/  prof  (~(get by profiles.state) [%urbit our.bowl])
    :: TODO
    =/  msg  ''
    =/  crd  (res-poke [%ok [%feed fc prof] msg])
    :_  state  :~(hark-card crd)

++  give-feed   
  |=  pat=path
  ~&  give-feed=src.bowl
  =/  user  [%urbit src.bowl]
  =/  n=notif:sur  [%fans user '']
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
  :-  hark-card
  ::  TODO keep this in some inbox?
  =/  can  (can-access:gatelib src.bowl lock.feed-perms.state bowl)  
  ?.  can
   :: TODO keep track of the requests at the feed-perms struct
    (res-fact [%ng [%feed ''] 'not allowed'] pat)
    ::
    =/  lp  latest-page:feedlib
    =/  lp2  lp(count backlog.feed-perms.state)
    =/  =fc:feed  (lp2 feed.state)
    =/  prof  (~(get by profiles.state) [%urbit our.bowl])
    ::  TODO
    =/  msg  ''
    (res-fact [%ok [%feed fc prof] msg] pat)


++  give-ted  |=  [id=@ pat=path]
  =/  ted  (get:orm:feed feed.state id)
  ?~  ted
    (res-fact [%ng [%thread id ''] 'no such thread'] pat)
  =/  can  (can-access:gatelib src.bowl read.u.ted bowl)
  ?.  can
    (res-fact [%ng [%thread id ''] 'not allowed'] pat)
    ::
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    (res-fact [%ok [%thread fn ~] ''] pat)
::
++  handle-thread  |=  [id=@da beg-msg=@t]
  =/  n=notif:sur  [%beg-req [%urbit src.bowl] [%thread our.bowl id] beg-msg]
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)

  =/  ted  (get:orm:feed feed.state id)
  ?~  ted
    =/  crd  (res-poke [%ng [%thread id beg-msg] 'no such thread'])
    :_  state  :~(hark-card crd)
  =/  can  (can-access:gatelib src.bowl read.u.ted bowl)
  ?.  can
    =/  crd  (res-poke [%ng [%thread id beg-msg] 'not allowed'])
    :_  state  :~(hark-card crd)
    ::
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    ::  TODO
    =/  msg  'どうぞ'
    =/  crd  (res-poke [%ok [%thread fn ~] msg])
    :_  state  :~(hark-card crd)
:: res
:: TODO URGENT the whole msg thing is a mess I kinda lost track
++  handle-res  |=  =res:comms
  =/  n=notif:sur
    :-  %beg-res
    ?-  -.res
      %ok
        ?-  -.p.res
          %feed    [[%feed src.bowl] .y msg.res]
          %thread  [[%thread src.bowl id.p.p.res] .y msg.res]
        ==
      %ng
        ?-  -.req.res
          %feed    [[%feed src.bowl] .n msg.res]
          %thread  [[%thread src.bowl id.req.res] .n msg.res]
        ==
    ==
  =/  hark-card  (send-hark:harklib n bowl)
  :_  state
  :~  hark-card
  ==
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
    ::
    =/  jon  (beg-res:en:jsonlib res)
    =/  cage  [%json !>(jon)]
    =/  c1  [%give %fact paths cage]
    =/  c2  [%give %kick paths ~]
    :~(c1 c2)
  ::  for the follow flow
    =/  cage  [%noun !>([%init res])]
    =/  c1  [%give %fact paths cage]
    :~(c1)

::  engagement pokes, heads up when replying etc. to a post on your feed
++  handle-eng
  |=  e=engagement:comms
  =/  user  [%urbit src.bowl]
  ?-  -.e
    %reply
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl parent.e]
      =/  n=notif:sur  [%post pid user %reply child.e]
      =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
      ::
      =.  children.u.poast  (~(put in children.u.poast) id.child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      =.  feed.state  (put:orm:feed feed.state id.child.e child.e)
      =/  f=fact:comms  [%post %add child.e]
      =/  f2=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
          (update-followers:cards:lib f2)
          hark-card
      ==
    %del-reply
      =.  feed.state  =<  +  (del:orm:feed feed.state child.e)
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl parent.e]
      ::  TODO kinda wrong
      =/  n=notif:sur  [%post pid user %del ~]
      =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
      =.  children.u.poast  (~(del in children.u.poast) child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      :_  state
      :~  (update-followers:cards:lib [%post %changes u.poast])
          (update-followers:cards:lib [%post %del child.e])
          hark-card
      ==
    :: TODO ideally we want the full quote to display it within the post engagement. So do we change quoted.engagement.post? What if the quoter edits the quote down the line, etc.
    %quote
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl src.e]
      =/  n=notif:sur  [%post pid user %quote post.e]
      =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
      =/  spid  [*signature:post src.bowl id.post.e]
      =.  quoted.engagement.u.poast  (~(put in quoted.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ==
    %rp
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl src.e]
      =/  n=notif:sur  [%post pid user %rp ~]
      =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
      
      =/  spid  [*signature:post src.bowl rt.e]
      =.  shared.engagement.u.poast  (~(put in shared.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ==
    %reaction
      =/  poast  (get:orm:feed feed.state post.e)
      ?~  poast  `state
      :: TODO signatures et al.
      :: 
      =/  pid  [our.bowl post.e]
      =/  n=notif:sur  [%post pid user %reaction reaction.e]
      =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
      =.  reacts.engagement.u.poast  (~(put by reacts.engagement.u.poast) src.bowl [reaction.e *signature:post])
      =.  feed.state  (put:orm:feed feed.state post.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ==
  ==


--
