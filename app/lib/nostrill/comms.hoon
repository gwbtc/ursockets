/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed, post=trill-post, noti=nostrill-noti
/+  js=json-nostr, sr=sortug,constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, lib=nostrill, mutations-trill, harklib=hark
|_  [=state:sur =bowl:gall]

++  handle-req  |=  [=req:sur pat=path]
  ^-  (quip card:agent:gall _state)
  =/  =user:sur  [%urbit src.bowl]
  =/  enreq=(enbowl:sur req.sur)  [user now.bowl req]
  |^
  ?@  req.req  ::  %fans
    (handle-feed-req %follow)
    ?@  p.req.req
      (handle-feed-req %beg)
    (handle-thread-req +.p.req.req)

::
++  handle-thread-req  |=  id=@da
  ^-  (quip card:agent:gall _state)
  =/  ted  (get:orm:feed feed.state id)
  ?~  ted  ::  invalid request, no notifications or response recording here  :: TODO do we wanna record spam?
    =/  =beg-res:comms  ['no such thread' %thread id %ng]
    =/  =res:comms  [msg.req %begs beg-res]
    :_  state  (send-fact res)
  ::
  =/  can  (can-access:gatelib src.bowl read.perms.u.ted msg.req bowl)
  =/  =decision:sur  ?:  can
    [now.bowl .y .n 'どうぞ']
    [now.bowl .n .n 'not allowed']
  =/  =ruling:sur  [enreq read.perms.u.ted decision]
  =.  responses.state  (put:ors:sur responses.state now.bowl ruling)
  ::
  =/  n=notif:noti  [%req enreq `decision]
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
  ::
  ?.  can
    =/  =beg-res:comms  [msg.decision %thread id %ng]
    =/  =res:comms  [msg.req %begs beg-res]
    =/  crds  (send-fact res)
    :_  state  [hark-card crds]
    ::
    :: 
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    =/  =beg-res:comms  [msg.decision %thread id %ok fn ~]
    =/  =res:comms  [msg.req %begs beg-res]
    =/  crds  (send-fact res)
    :_  state  [hark-card crds]
:: 
  ++  handle-feed-req  |=  t=$?(%follow %beg)
    ^-  (quip card:agent:gall _state)
    ?:  manual.feed-perms.state  ::  don't decide now, save it in requests and defer
      defer-ruling
    ::

    =/  can  (can-access:gatelib src.bowl feed-perms.state msg.req bowl)  
    =/  =decision:sur  ?:  can
      [now.bowl .y .n 'どうぞ']
      [now.bowl .n .n 'not allowed']

    =/  =ruling:sur  [enreq feed-perms.state decision]
    =.  responses.state  (put:ors:sur responses.state now.bowl ruling)
    ::
    =/  n  [%req enreq `decision]
    =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)

    |^
      ?:  can  give-feed  deny-feed
  
      ++  give-feed
      ::
        =/  lp  latest-page:feedlib
        =/  lp2  lp(count backlog.feed-perms.state)
        =/  =fc:feed  (lp2 feed.state)
        =/  prof  (~(get by profiles.state) [%urbit our.bowl])
        =/  =res:comms  :-  msg.req  ?:  ?=(%follow t)
          [%fols msg.decision %ok fc prof]
          [%begs msg.decision %feed %ok fc prof]
        =/  crds  (send-fact res)
        :_  state  [hark-card crds]
      ::
      ++  deny-feed
        =/  =res:comms  :-  msg.req  ?:  ?=(%follow t)
          [%fols msg.decision %ng]
          [%begs msg.decision %feed %ng]
        
        =/  crds  (send-fact res)
        :_  state  [hark-card crds]
    --
  
  ++  send-fact  |=  =res:comms   ^-  (list card:agent:gall)
    =/  paths  :~(pat)
    ?:  ?=(%fols -.p.res)
      =/  f=fols-res:comms  +.p.res
      =/  cage  [%noun !>([%fols f])]
      =/  c1  [%give %fact paths cage]
      :~(c1)
    ::
      =/  jon  (res:en:jsonlib res)
      =/  cage  [%json !>(jon)]
      =/  c1  [%give %fact paths cage]
      =/  c2  [%give %kick paths ~]
      :~(c1 c2)
  ::
  ++  defer-ruling
    =.  requests.state  (put:orq:sur requests.state now.bowl req)
    =/  n=notif:noti  [%req enreq ~]
    =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
    :_  state  :~(hark-card)
  
      
--

:: TODO this is... not very useful yet
++  wrap-post  |=  p=post:post  ^-  post-wrapper:sur
  =/  pubkey  ?:  .=(author.p our.bowl)  `pub.i.keys.state  ~
  =/  user  (atom-to-user:lib author.p)
  =/  profile  (~(get by profiles.state) user)
  [p pubkey ~ ~ profile]
::  engagement pokes, heads up when replying etc. to a post on your feed
++  handle-eng
  |=  e=engagement:comms
  ^-  (quip card:agent:gall _state)
  =/  user  [%urbit src.bowl]
  =/  n=notif:noti  [%post [user now.bowl e]]
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)

  ?-  -.e
    %reply
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl parent.e]
      ::
      =.  children.u.poast  (~(put in children.u.poast) id.child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      =.  feed.state  (put:orm:feed feed.state id.child.e child.e)
      =/  f=fact:comms  [%post %add (wrap-post child.e)]
      =/  f2=fact:comms  [%post %changes (wrap-post u.poast)]
      :_  state
      :~  (update-followers:cards:lib f)
          (update-followers:cards:lib f2)
          hark-card
      ==
    %mention
      =/  poast  (get:orm:feed feed.state id.post.e)
      ?~  poast  `state
      `state
      ::  TODO
      :: =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      :: =.  feed.state  (put:orm:feed feed.state id.child.e child.e)
      :: =/  f=fact:comms  [%post %add child.e]
      :: =/  f2=fact:comms  [%post %changes u.poast]
      :: :_  state
      :: :~  (update-followers:cards:lib f)
      ::     (update-followers:cards:lib f2)
      ::     hark-card
      :: ==
    %del-parent
      ?~  p=(get:orm:feed feed.state child.e)  `state
      =.  host.u.p  our.bowl  ::  parent already deleted no need to send update to them, handle localy 
      =.  feed.state  (put:orm:feed feed.state child.e u.p)
      =/  mutat  ~(. mutations-trill state bowl)
      (handle-post:mutat [%del urbit+our.bowl child.e])
    %del-reply 
      ?~  p=(get:orm:feed feed.state child.e)  `state
      =/  poast  (get:orm:feed feed.state parent.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl parent.e]
      ::  TODO kinda wrong
      =.  feed.state  =<  +  (del:orm:feed feed.state child.e)
      =.  children.u.poast  (~(del in children.u.poast) child.e)
      =.  feed.state  (put:orm:feed feed.state parent.e u.poast)
      :_  state
      :~  (update-followers:cards:lib [%post %changes (wrap-post u.poast)])
          :: (update-followers:cards:lib [%post %del (wrap-post child.e)])
          hark-card
      ==
    :: TODO ideally we want the full quote to display it within the post engagement. So do we change quoted.engagement.post? What if the quoter edits the quote down the line, etc.
    %quote
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl src.e]
      =/  spid  [*signature:post src.bowl id.post.e]
      =.  quoted.engagement.u.poast  (~(put in quoted.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes (wrap-post u.poast)]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ==
    %del-quote
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl src.e]

      =/  spid  [*signature:post src.bowl quote.e]
      =.  quoted.engagement.u.poast  (~(del in quoted.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes (wrap-post u.poast)]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ::  TODO: update %ui card
      ==
    %rp
      =/  poast  (get:orm:feed feed.state src.e)
      ?~  poast  `state
      ::
      =/  pid  [our.bowl src.e]
      
      =/  spid  [*signature:post src.bowl target.e]
      =.  shared.engagement.u.poast  
        ?:  (~(has in shared.engagement.u.poast) spid)
          (~(del in shared.engagement.u.poast) spid)
        (~(put in shared.engagement.u.poast) spid)
      =.  feed.state  (put:orm:feed feed.state src.e u.poast)
      =/  f=fact:comms  [%post %changes (wrap-post u.poast)]
      :_  state
      :~  (update-followers:cards:lib f)
           hark-card
      ::  TODO: update %ui card
      ==
    %reaction
      =/  poast  (get:orm:feed feed.state post.e)
      ?~  poast  `state
      :: TODO signatures et al.
      =/  pid  [our.bowl post.e]
      =/  sign  *signature:post
      =.  q.sign  src.bowl
      =.  reacts.engagement.u.poast  (~(put by reacts.engagement.u.poast) src.bowl [reaction.e sign])
      =.  feed.state  (put:orm:feed feed.state post.e u.poast)
      =/  f=fact:comms  [%post %changes (wrap-post u.poast)]
      :_  state
      :~  (update-followers:cards:lib f)
          hark-card
      ::  TODO: update %ui card
      ==
  ==


--
