/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui, notif=nostrill-notif,
    feed=trill-feed
/+  lib=nostrill, js=json-nostr, nostr-client, sr=sortug, constants, harklib=hark,
    gatelib=trill-gate, feedlib=trill-feed, jsonlib=json-nostrill,
    mutations-nostr
|_  [=state:sur =bowl:gall]
::
++  handle-add  |=  =user:sur
  ^-  (quip card:agent:gall _state)
  ?-  -.user
    %urbit  =/  c  (urbit-watch +.user)
            :-  :~(c)  state
    %nostr  =/  mutan  ~(. mutations-nostr [state bowl])
            =/  rl  get-relay:mutan
            ?~  rl  ~&   >>>  "no relay!"  `state
            =/  wid  -.u.rl
            =/  relay=relay-stats:nsur  +.u.rl
            =/  relay-url=@t  url.relay
            =/  nclient  ~(. nostr-client [state bowl])  
            =/  rclient  ~(. relay.nclient [wid relay])  
            :: TODO now or on receival?
            =.  following.state  (~(put by following.state) user *feed:feed)
            =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
            =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
            =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
            =^  cards  relay  (get-user-feed:rclient +.user)
            =.  relays.state  (~(put by relays.state) wid relay)
            ::  ui
            =/  profile  (~(get by profiles.state) user)
            =/  =fact:ui  [%fols %new-nostr +.user profile ~[relay-url]]
            =/  ui-card   (update-ui:cards:lib fact)
            :_  state
            [ui-card cards]
  ==
++  handle-del  |=  =user:sur
  ^-  (quip card:agent:gall _state)
  =.  following.state  (~(del by following.state) user)
  =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
  ?~  graph  `state
  =/  nset  (~(del in u.graph) user)
  =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] nset)
  =/  =fact:ui  [%fols %quit user]
  =/  c1  (update-ui:cards:lib fact)
  ?:  ?=(%urbit -.user)
    ~&  >>  leaving=user
    =/  c2   (urbit-leave +.user)
    :_  state
    :~(c1 c2)

  ::  nostr
  =/  mutan  ~(. mutations-nostr [state bowl])
  =/  rl  get-relay:mutan
  ?~  rl  ~&   >>>  "no relay!"  `state
  =/  wid  -.u.rl
  =/  relay=relay-stats:nsur  +.u.rl
  =/  relay-url=@t  url.relay
  =/  nclient  ~(. nostr-client [state bowl])  
  =/  rclient  ~(. relay.nclient [wid relay])  
  =^  cards  relay  (unfollow-user:rclient +.user)
  :_  state
  :-  c1  cards

++  handle-res  |=  fr=fols-res:comms
  ^-  (quip card:agent:gall _state)
  ~&  >>  handling-follow-res=fr
  =/  =user:sur  [%urbit src.bowl]
  =/  enfr  [user now.bowl fr]
  =/  n=notif:notif  [%fol-res enfr]
  =/  hark-card  (send-hark:harklib n bowl)
  =.  state
  ?@  p.fr  state     ::  deferred
  ?@  +.p.fr  state   ::  approval denied
    ::  =.  requests.state
    =/  fd=feed-data:comms  data.p.fr
    =.  following.state   (~(put by following.state) user feed.fc.fd)
    =.  following2.state  (add-new-feed:feedlib following2.state feed.fc.fd)
    =.  profiles.state  (~(put by profiles.state) user profile.fd)
    =/  graph  (~(get by follow-graph.state) [%urbit our.bowl])
    =/  follows  ?~  graph  (silt ~[user])  (~(put in u.graph) user)
    =.  follow-graph.state  (~(put by follow-graph.state) [%urbit our.bowl] follows)
    state
  ::
  =/  =fact:ui  [%fols %new-urbit enfr]
  =/  ui-card   (update-ui:cards:lib fact)
  :_  state
  :~
      hark-card
      ui-card
  ==

++  handle-refollow  |=  sip=@p
  :_  state
  ::  TODO man this API sucks
  :: :~  (urbit-watch sip)
  :: ==
  ~
    

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

--
