/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui,
    feed=trill-feed
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
    =/  =fact:ui  [%fols %quit user]
    =/  c1  (update-ui:cards:lib fact)
    ?.  ?=(%urbit -.user)  :~(c1)
    ~&  >>  leaving=user
    =/  c2   (urbit-leave +.user)
    :~(c1 c2)

++  handle-follow-res  |=  fr=fols-res:comms
  ^-  (quip card:agent:gall _state)
  =/  =user:sur  [%urbit src.bowl]
  =?  state  ?=(^ fr)
    =.  following.state   (~(put by following.state) user feed.fc.data.fr)
    =.  following2.state  (add-new-feed:feedlib following2.state feed.fc.data.fr)
    =?  profiles.state  ?=(^ profile.data.fr)  (~(put by profiles.state) user u.profile.data.fr)
    =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
    =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
    =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
    state
  ::
  =/  =res:comms  ['' %fols fr]
  =/  =fact:ui      [%fols %new user now.bowl fr]
  :: =/  n=notif:noti  [%res [user now.bowl res]]
  :: =/  hark-card  (send-hark:harklib n bowl)
  =/  ui-card    (update-ui:cards:lib fact)
  :_  state
  :~
     :: hark-card
      ui-card
  ==

++  handle-refollow  |=  sip=@p
  :_  state  :_   ~
  :: (urbit-watch sip)
  [%pass /follow %agent [sip dap.bowl] %watch /follow]
    

++  handle-kick-nack  |=  p=@p
  ^-  (quip card:agent:gall _state)
  =.  following.state  (~(del by following.state) [%urbit p])
  =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
  ?~  graph  `state
  =/  ngraph  (~(del in u.graph) [%urbit p])
  =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] ngraph)
  :_  state
    =/  =fact:ui  [%fols %quit %urbit src.bowl]
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
