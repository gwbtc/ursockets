/-  sur=nostrill, nsur=nostr, comms=nostrill-comms,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    trill=trill-post,
    njs=json-nostr,
    postlib=trill-post,
    shim,
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
  
++  handle-post  |=  poke=post-poke:ui:sur
  ^-  (quip card _state)
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
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
    ==
    =/  pw  [p (some pubkey) ~ ~ profile]
    =/  jfact=fact:ui:sur  [%post %add pw]
    =/  ui-card    (update-ui:cards:lib jfact)
    ::  only update followers when we are updating our own feed
    ?.  .=(our.bowl host.p)  [~[ui-card] state]
    =.  state  (add-to-feed p)
    =/  =fact:comms  [%post %add p]
    =/  fact-card  (update-followers:cards:lib fact)
    :_  state
    :~  ui-card
        fact-card
    ==


++  handle-post-fact  |=  pf=post-fact:comms
  ^-  (quip card _state)
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
   :: TODO update the ui with the changes 
   :_  state  ~
--
