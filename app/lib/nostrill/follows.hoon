/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed
/+  lib=nostrill, js=json-nostr, nostr-client, sr=sortug, constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, mutations-nostr
|_  [=state:sur =bowl:gall]
++  handle-add  |=  =user:sur
  ^-  (quip card:agent:gall _state)
  ?-  -.user
    %urbit  =/  c  (urbit-watch +.user)
            :-  :~(c)  state
    %nostr  =/  mutan  ~(. mutations-nostr [state bowl])
            =/  rl  get-relay:mutan
            ?~  rl  ~&   >>>  "no relay!"  `state
            =/  wid  -.u.rl
            =/  relay  +.u.rl
            =/  nclient  ~(. nostr-client [state bowl wid relay])  
            :: TODO now or on receival?
            =.  following.state  (~(put by following.state) user *feed:feed)
            =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
            =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
            =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
            
            =^  cards  relay  (get-user-feed:nclient +.user)
            =.  relays.state  (~(put by relays.state) wid relay)
            [cards state]
  ==
++  handle-del  |=  =user:sur
  ^-  (quip card:agent:gall _state)
  =.  following.state  (~(del by following.state) user)
  =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
  ?~  graph  `state
  =/  nset  (~(del in u.graph) user)
  =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] nset)
  :_  state
    =/  =fact:ui:sur  [%fols %quit user]
    =/  c1  (update-ui:cards:lib fact)
    ?.  ?=(%urbit -.user)  :~(c1)
    ~&  >>  leaving=user
    =/  c2   (urbit-leave +.user)
    :~(c1 c2)

++  handle-follow-res  |=  =res:comms
  ?-  -.res
    %ng   
          :_  state
          =/  =fact:ui:sur  [%hark %fols [%urbit src.bowl] .n msg.res]
          =/  c  (update-ui:cards:lib fact)  :~(c)
    %ok
      ?-  -.p.res
        %feed  (handle-follow-ok [%urbit src.bowl] fc.+.p.res profile.+.p.res)
        %thread  `state
      ==
  ==
++  handle-refollow  |=  sip=@p
  :_  state  :_   ~
  :: (urbit-watch sip)
  [%pass /follow %agent [sip dap.bowl] %watch /follow]

++  handle-follow-ok  |=  [=user:sur =fc:feed profile=(unit user-meta:nsur)]
  ^-  (quip card:agent:gall _state)
  =.  following.state   (~(put by following.state) user feed.fc)
  =.  following2.state  (add-new-feed:feedlib following2.state feed.fc)
  =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
  =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
  =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
  =.  profiles.state  ?~  profile  profiles.state  (~(put by profiles.state) user u.profile)
  :_  state
    =/  =fact:ui:sur  [%fols %new [%urbit src.bowl] fc profile]
    =/  c  (update-ui:cards:lib fact)  :~(c)
    

++  handle-kick-nack  |=  p=@p
  ^-  (quip card:agent:gall _state)
  =.  following.state  (~(del by following.state) [%urbit p])
  =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
  ?~  graph  `state
  =/  ngraph  (~(del in u.graph) [%urbit p])
  =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] ngraph)
  :_  state
    =/  =fact:ui:sur  [%fols %quit %urbit src.bowl]
    =/  c  (update-ui:cards:lib fact)  :~(c)


++  urbit-leave  |=  sip=@p   ^-  card:agent:gall
  [%pass /follow %agent [sip dap.bowl] %leave ~]
  
++  urbit-watch  |=  sip=@p   ^-  card:agent:gall
  [%pass /follow %agent [sip dap.bowl] %watch /follow]

:: ++  res-fact  |=  =res:comms   ^-  (list card:agent:gall)
::   =/  paths  ~[/beg/feed]
::   =/  =poke:comms  [%res res]
::   ~&  >  giving-res-fact=res
::   =/  jon  (beg-res:en:jsonlib res)
::   =/  cage  [%json !>(jon)]
::   :~
::     [%give %fact paths cage]
::     [%give %kick paths ~]
::   ==

--
