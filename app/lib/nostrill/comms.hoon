/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed, post=trill-post
/+  js=json-nostr, sr=sortug,constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, lib=nostrill, mutations-trill
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

::  engagement pokes, heads up when replying etc. to a post on your feed
++  handle-eng
  |=  e=engagement:comms
  ?-  -.e
    %reply
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      =.  children.u.poast  (~(put in children.u.poast) id.child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      =.  feed.state  (put:orm:feed feed.state id.child.e child.e)
      =/  f=fact:comms  [%post %add child.e]
      =/  f2=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
          (update-followers:cards:lib f2)
      ==
    %del-parent
      ?~  p=(get:orm:feed feed.state child.e)  `state
      =.  host.u.p  our.bowl  ::  parent already deleted no need to send update to them, handle localy 
      =.  feed.state  (put:orm:feed feed.state child.e u.p)
      =/  mutat  ~(. mutations-trill state bowl)
      (handle-post:mutat [%del our.bowl child.e])
    %del-reply 
      ?~  p=(get:orm:feed feed.state child.e)  `state
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      =.  feed.state  =<  +  (del:orm:feed feed.state child.e)
      =.  children.u.poast  (~(del in children.u.poast) child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      :_  state
      :~  (update-followers:cards:lib [%post %changes u.poast])
          (update-followers:cards:lib [%post %del child.e])
          ::  XX: update-ui:cards:lib
      ==
    :: TODO ideally we want the full quote to display it within the post engagement. So do we change quoted.engagement.post? What if the quoter edits the quote down the line, etc.
    %quote
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      =/  spid  [*signature:post src.bowl id.post.e]
      =.  quoted.engagement.u.poast  (~(put in quoted.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
      ==
    %del-quote
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      =/  spid  [*signature:post src.bowl quote.e]
      =.  quoted.engagement.u.poast  (~(del in quoted.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
      ::  TODO: update %ui card
      ==
    %rp
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      =/  spid  [*signature:post src.bowl rt.e]
      =.  shared.engagement.u.poast  
        ?:  (~(has in shared.engagement.u.poast) spid)
          (~(del in shared.engagement.u.poast) spid)
        (~(put in shared.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
      ::  TODO: update %ui card
      ==
    %reaction
      =/  poast  (get:orm:feed feed.state post.e)
      ?~  poast  `state
      :: TODO signatures et al.
      =/  sign  *signature:post
      =.  q.sign  src.bowl
      =.  reacts.engagement.u.poast  (~(put by reacts.engagement.u.poast) src.bowl [reaction.e sign])
      =.  feed.state  (put:orm:feed feed.state post.e u.poast)
      =/  f=fact:comms  [%post %changes u.poast]
      :_  state
      :~  (update-followers:cards:lib f)
      ::  TODO: update %ui card
      ==
  ==


--
