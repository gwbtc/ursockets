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
    =/  =res:comms  [%thread id 'no such thread' %done %ng]
    :_  state  (send-res res)
  ::
  ?:  manual.read.perms.u.ted  (defer-ruling [%thread id])

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
    =/  =res:comms  [%thread id msg.decision %done %ng]
    =/  crds  (send-res res)
    :_  state  [hark-card crds]
    ::
    :: 
    =/  fn  (node-to-full:feedlib u.ted feed.state)
    =/  =res:comms  [%thread id msg.decision %done %ok fn ~]
    =/  crds  (send-res res)
    :_  state  [hark-card crds]
:: 
  ++  handle-feed-req  |=  t=$?(%follow %beg)
    ^-  (quip card:agent:gall _state)
    ?:  manual.feed-perms.state  ::  don't decide now, save it in requests and defer
      (defer-ruling %feed)
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
        =/  fd=feed-data:comms  [fc prof]
        =/  fr=fols-res:comms  [msg.decision %done %ok fd]
        :_  state
        :-  hark-card
            ?:  ?=(%follow t)
              (send-feed fr)
              (send-res [%feed fr])
      ::
      ++  deny-feed
        =/  fr=fols-res:comms  [msg.decision %done %ng]        
        =/  crds  (send-res [%feed fr])
        :_  state  [hark-card crds]
    --
  
  ++  send-feed  |=  fr=fols-res:comms   ^-  (list card:agent:gall)
    =/  paths  :~(pat)
    =/  =fact:comms  [%feed fr]
    =/  cage  [%noun !>(fact)]
    =/  c1  [%give %fact paths cage]
    :~(c1)

  ++  send-res  |=  =res:comms   ^-  (list card:agent:gall)
    =/  paths  :~(pat)
    =/  jon  (res:en:jsonlib res)
    =/  cage  [%json !>(jon)]
    =/  c1  [%give %fact paths cage]
    =/  c2  [%give %kick paths ~]
    :~(c1 c2)
  ::
  ++  defer-ruling  |=  t=beg-type:comms  ^-  (quip card:agent:gall _state)
    =.  requests.state  (put:orq:sur requests.state now.bowl req)
    =/  n=notif:notif  [%req enreq ~]
    =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
    =/  =res:comms  ?:  ?=(%feed t)
      [%feed 'thinking' %thinking]
      [%thread id.t 'thinking' %thinking]
    =/  fact-cards  (send-res res)
    :_  state  :-  hark-card  fact-cards
  --
--
