/-  *wrap, sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed, post=trill-post, notif=nostrill-notif
/+  js=json-nostr, sr=sortug,constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, lib=nostrill, mutations-trill, harklib=hark
|_  [=state:sur =bowl:gall]

++  handle-req  |=  [=req:comms pat=path]
  ^-  (quip card:agent:gall _state)
  =/  =user:sur  [%urbit src.bowl]
  =/  enreq=(enbowl req:comms)  [user now.bowl req]
  |^
  ?@  p.req  ::  %fans
    (handle-feed-req %follow)
    ?@  +.p.req
      (handle-feed-req %beg)
      (handle-thread-req id.+.p.req)

::
++  handle-thread-req  |=  id=@da
  ^-  (quip card:agent:gall _state)
  =/  ted  (get:orm:feed feed.state id)
  ?~  ted  ::  invalid request, no notifications or response recording here  :: TODO do we wanna record spam?
    =/  =beg-res:comms  [%thread id %ng]
    =/  =res:comms  ['no such thread' %begs beg-res]
    :_  state  (send-fact res)
  ::
  =/  can  (can-access:gatelib src.bowl read.perms.u.ted msg.req bowl)
  =/  =decision:sur  ?:  can
    [now.bowl .y .n 'どうぞ']
    [now.bowl .n .n 'not allowed']
  =/  =ruling:sur  [enreq read.perms.u.ted decision]
  =.  responses.state  (put:ors:sur responses.state now.bowl ruling)
  ::
  =/  n=notif:notif  [%req enreq `decision]
  =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
  ::
  ?.  can
    =/  =beg-res:comms  [%thread id %ng]
    =/  =res:comms  [msg.decision %begs beg-res]
    =/  crds  (send-fact res)
    :_  state  [hark-card crds]
    ::
    :: 
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    =/  =beg-res:comms  [%thread id %ok fn ~]
    =/  =res:comms  [msg.decision %begs beg-res]
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
        =/  =res:comms  :-  msg.decision  ?:  ?=(%follow t)
          [%fols %ok fc prof]
          [%begs %feed %ok fc prof]
        =/  crds  (send-fact res)
        :_  state  [hark-card crds]
      ::
      ++  deny-feed
        =/  =res:comms  :-  msg.decision  ?:  ?=(%follow t)
          [%fols %ng]
          [%begs %feed %ng]
        
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
    =/  n=notif:notif  [%req enreq ~]
    =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
    :_  state  :~(hark-card)    
  --
--
