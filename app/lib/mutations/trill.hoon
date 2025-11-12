/-  sur=nostrill, nsur=nostr, comms=nostrill-comms,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    trill-feed,
    trill=trill-post,
    njs=json-nostr,
    postlib=trill-post,
    sr=sortug

|_  [=state:sur =bowl:gall]
+$  card  card:agent:gall
++  debug-own-feed
  =/  postlist  (tap:orm:feed feed.state)  
  =/  lol
  |-  ?~  postlist  ~
    ~&  >>  poast=+.i.postlist
    $(postlist t.postlist)
  ~
  
:: state
++  add-to-feed  |=  p=post:post
  =.  feed.state  (put:orm:feed feed.state id.p p)
  state
++  headsup-poke
  |=  [poke=post-poke:ui:sur p=post:post]  ^-  (unit engagement:comms)
  ?-  -.poke
    %add  ~
    ::: TODO del-reply
    %del  ~
    %quote     `[%quote id.poke p]
    %reply     `[%reply id.poke p]
    %rp        `[%rp id.poke id.p]
    %reaction  `[%reaction id.poke reaction.poke]
  ==
  
++  handle-post  |=  poke=post-poke:ui:sur
  ^-  (quip card _state)
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
  ?:  ?=(%del -.poke)
    =.  feed.state  =<  +  (del:orm:feed feed.state id.poke)
    :: TODO
    `state 
  =/  p=post:post
    ?-  -.poke
      %add
        =/  sp     (build-sp:trill our.bowl our.bowl content.poke ~ ~)
        (build-post:trill now.bowl pubkey sp)
      %quote
        =/  sp     (build-sp:trill our.bowl our.bowl content.poke ~ ~)
        =/  quote  [%ref %trill host.poke /(crip (scow:sr %ud id.poke))]
        =.  contents.sp  (snoc contents.sp quote)
        (build-post:trill now.bowl pubkey sp)
      %reply
        =/  sp     (build-sp:trill host.poke our.bowl content.poke `id.poke `thread.poke)
        (build-post:trill now.bowl pubkey sp)
      %rp
        =/  quote  [%ref %trill host.poke /(crip (scow:sr %ud id.poke))]
        =/  sp     (build-sp:trill host.poke our.bowl '' ~ ~)
        =.  contents.sp  ~[quote]
        (build-post:trill now.bowl pubkey sp)
      %reaction
        =/  p  (got:orm:feed feed.state id.poke)
        =.  reacts.engagement.p  %+  ~(put by reacts.engagement.p)
          our.bowl  [reaction.poke *signature:post]
        p
    ==
    =.  state  (add-to-feed p)
    =/  pw  [p (some pubkey) ~ ~ profile]
    =/  jfact=fact:ui:sur  [%post %add pw]
    =/  ui-card    (update-ui:cards:lib jfact)
    =/  crds  ~(. cards:lib bowl)
    =/  engagement-poke  (headsup-poke poke p)
    =/  base-cards
      ?~  engagement-poke  :~(ui-card)  
        =/  poke  [%eng u.engagement-poke]
        =/  eng-card  (poke-host:crds host.p poke)
        :~(ui-card eng-card)
    ::  if our own post we update followers, if someone elses post we send an engagement poke
    :_  state
    ?:  .=(our.bowl host.p)
     ::
      =/  =fact:comms  [%post %add p]
      =/  fact-card  (update-followers:cards:lib fact)
      :-  fact-card  base-cards
      ::
      base-cards

++  handle-post-fact  |=  pf=post-fact:comms
  ^-  (quip card _state)
  ~&  handle-post-fact=pf
  =/  =user:sur  [%urbit src.bowl]
  =/  fed  (~(get by following.state) user)
  ?~  fed  ~&  "emmm not following ya"  `state
  =/  nf=feed:feed
  ?:  ?=(%del -.pf)
        =<  +  (del:orm:feed u.fed id.pf)
    ::mmm people aren't supposed to update if its not their own feeds
    :: =/  =user:nsur  [%urbit host.p.pdf]
    (put:orm:feed u.fed id.p.pf p.pf)
  =.  following.state  (~(put by following.state) user nf)
  =.  following2.state
    ?:  ?=(%del -.pf)
    =<  +  (del:orm:feed following2.state id.pf)
    (insert-to-global:trill-feed nf p.pf)
   :: TODO update the ui with the changes 
   :_  state  ~
--
