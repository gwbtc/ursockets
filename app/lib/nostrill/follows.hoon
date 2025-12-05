/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, feed=trill-feed, ui=nostrill-ui, noti=nostrill-noti
/+  lib=nostrill, js=json-nostr, nostr-client, sr=sortug, constants, gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill, mutations-nostr, harklib=hark
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
    :: =/  =fact:ui  [%fols %quit user]
    :: =/  c1  (update-ui:cards:lib fact)
    :: ?.  ?=(%urbit -.user)  :~(c1)
    ~&  >>  leaving=user
    =/  ship  (user-to-atom:lib user)
    =/  c2   (urbit-leave ship)
    :: :~(c1 c2)
    :~(c2)

:: follow-responses
++  handle-follow-res  |=  fr=fols-res:comms
  ^-  (quip card:agent:gall _state)
  =/  =user:sur  [%urbit src.bowl]
  =?  state  ?=(^ p.fr)
    =.  following.state   (~(put by following.state) user feed.fc.p.p.fr)
    =.  following2.state  (add-new-feed:feedlib following2.state feed.fc.p.p.fr)
    =?  profiles.state  ?=(^ profile.p.p.fr)  (~(put by profiles.state) user u.profile.p.p.fr)
    =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
    =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
    =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
    state
  ::
  =/  =res:comms  ['' %fols fr]
  =/  =fact:ui    [%fols user now.bowl fr]
  =/  n=notif:noti  [%res [user now.bowl res]]
  =/  hark-card  (send-hark:harklib n bowl)
  =/  ui-card    (update-ui:cards:lib fact)
  :_  state
  :~  hark-card
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
  ~
  :: TODO quit or not to quit
    :: =/  =fact:ui  [%fols %quit %urbit src.bowl]
    :: =/  c  (update-ui:cards:lib fact)  :~(c)


:: TODO pass actual path, may vary
++  urbit-leave  |=  sip=@p   ^-  card:agent:gall
  [%pass /follow %agent [sip dap.bowl] %leave ~]
  
++  urbit-watch  |=  sip=@p   ^-  card:agent:gall
  [%pass /follow %agent [sip dap.bowl] %watch /follow]

--
