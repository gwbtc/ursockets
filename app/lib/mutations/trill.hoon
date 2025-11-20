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
  |=  [poke=post-poke:ui:sur p=post:post]  ^-  engagement:comms
  ?-  -.poke
    %add  !!
    %del       [%del-reply id.poke id.p]
    %quote     [%quote id.poke p]
    :: TODO del-reply
    %reply     [%reply id.poke p]
    %rp        [%rp id.poke id.p]
    %reaction  [%reaction id.poke reaction.poke]
  ==
  
++  handle-post  |=  poke=post-poke:ui:sur
  ^-  (quip card _state)
  ~&  handle-post-ui=poke
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
  =/  crds  ~(. cards:lib bowl)
  ::  TODO UI notifications  [%hark ]
    ?-  -.poke
      %del  
        =/  pos  (get:orm:feed feed.state id.poke)
        ?~  pos  `state
        =.  feed.state  =<  +  (del:orm:feed feed.state id.poke)
        ::  TODO cascade children, from our state and propagate it down to repliers 
        =/  p  u.pos
        =/  pw  [p (some pubkey) ~ ~ profile]
        =/  jfact=fact:ui:sur  [%post %del pw]
        =/  ui-card    (update-ui:cards:lib jfact)
        =/  =fact:comms  [%post %del id.poke]
        =/  fact-card  (update-followers:cards:lib fact)
        :_  state
        ?:  .=(our.bowl host.p)
          ?~  ~(tap in children.p)
            :~  ui-card
                fact-card
            ==
          =/  c  ~(tap in children.p)
          =/  eng-cards=(list card)
            |-  ^-  (list card)
            ?~  c  ~
            =/  child=(unit post:post)  (get:orm:feed feed.state i.c)
            ?~  child  $(c t.c)
            :_  $(c t.c)
            ::  [%del-reply p.poke id.child]
            =/  eng-poke  [%eng (headsup-poke poke u.child)]
            ~&  send-heads-up-to/(headsup-poke poke u.child)
            (poke-host:crds author.u.child eng-poke)
          %+  welp  eng-cards
          :~    ui-card
                fact-card
          ==
        ::  poking host with %del post 
        ::  [%del-reply parent.p p.poke]
        ::  XX:
        ::  we are poking: delete my post(~zod) with id=1 and host ~bus
        ::  parent.post is empty so it's not a reply! 
        ::  what kind of behaviour should be expected ?
        ?~  parent.p
          :~  ui-card
          ==
        =/  eng-poke  [%eng (headsup-poke [%del host.poke u.parent.p] p)]
        =/  eng-card  (poke-host:crds host.poke eng-poke)
        ::
        :~  ui-card
            fact-card
            eng-card
        ==
      %add
        =/  sp     (build-sp:trill our.bowl our.bowl content.poke ~ ~)
        =/  p=post:post
          (build-post:trill now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  [p (some pubkey) ~ ~ profile]
        =/  jfact=fact:ui:sur  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib jfact)
        :_  state
          =/  =fact:comms  [%post %add p]
          =/  fact-card  (update-followers:cards:lib fact)
          :~  ui-card
              fact-card
          ==
      %quote
        =/  sp     (build-sp:trill our.bowl our.bowl content.poke ~ ~)
        =/  quote  [%ref %trill host.poke /(crip (scow:sr %ud id.poke))]
        =.  contents.sp  (snoc contents.sp quote)
        =/  p=post:post
          (build-post:trill now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  [p (some pubkey) ~ ~ profile]
        =/  jfact=fact:ui:sur  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib jfact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          =/  =fact:comms  [%post %add p]
          =/  fact-card  (update-followers:cards:lib fact)
          :~  ui-card
              fact-card
              eng-card
          ==
      %reply
        =/  sp     (build-sp:trill host.poke our.bowl content.poke `id.poke `thread.poke)
        =/  p=post:post
          (build-post:trill now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  [p (some pubkey) ~ ~ profile]
        =/  jfact=fact:ui:sur  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib jfact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          =/  =fact:comms  [%post %add p]
          =/  fact-card  (update-followers:cards:lib fact)
          :~  ui-card
              fact-card
              eng-card
          ==
      %rp
        =/  quote  [%ref %trill host.poke /(crip (scow:sr %ud id.poke))]
        =/  sp     (build-sp:trill host.poke our.bowl '' ~ ~)
        =.  contents.sp  ~[quote]
        =/  p=post:post
          (build-post:trill now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  [p (some pubkey) ~ ~ profile]
        =/  jfact=fact:ui:sur  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib jfact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          =/  =fact:comms  [%post %add p]
          =/  fact-card  (update-followers:cards:lib fact)
          :~  ui-card
              fact-card
              eng-card
          ==
      %reaction
        ?:  .=(host.poke our.bowl)
          =/  p  (got:orm:feed feed.state id.poke)
          =.  reacts.engagement.p  %+  ~(put by reacts.engagement.p)
            our.bowl  [reaction.poke *signature:post]
          =.  state  (add-to-feed p)
          =/  pw  [p (some pubkey) ~ ~ profile]
          =/  jfact=fact:ui:sur  [%post %add pw]
          =/  ui-card    (update-ui:cards:lib jfact)
          =/  eng-poke  [%eng (headsup-poke poke p)]
          =/  eng-card  (poke-host:crds host.poke eng-poke)
          :_  state
            =/  =fact:comms  [%post %add p]
            =/  fact-card  (update-followers:cards:lib fact)
            :~  ui-card
                fact-card
                eng-card
            ==
            ::
          =/  up  (get:orm:feed following2.state id.poke)
          ?~  up
            =/  eng-poke  [%eng (headsup-poke poke *post:post)]
            =/  eng-card  (poke-host:crds host.poke eng-poke)
            :_  state  :~(eng-card)
            ::
            =/  p  u.up 
            =.  reacts.engagement.p  %+  ~(put by reacts.engagement.p)
              our.bowl  [reaction.poke *signature:post]
            =.  state  (add-to-feed p)
            =/  pw  [p (some pubkey) ~ ~ profile]
            =/  jfact=fact:ui:sur  [%post %add pw]
            =/  ui-card    (update-ui:cards:lib jfact)
            =/  eng-poke  [%eng (headsup-poke poke p)]
            =/  eng-card  (poke-host:crds host.p eng-poke)
            :_  state
              =/  =fact:comms  [%post %add p]
              =/  fact-card  (update-followers:cards:lib fact)
              :~  ui-card
                  fact-card
                  eng-card
              ==
    ==

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
    :_  state
    =/  profile  (~(get by profiles.state) user)
    =/  pubkey  0  :: TODO
    =/  jfact=fact:ui:sur
      ?:  ?=(%del -.pf)
        =/  p  *post:post
        =/  p  p(host src.bowl, id id.pf)
        =/  pw  [p ~ ~ ~ profile]
        [%post %del pw]
        =/  pw  [p.pf ~ ~ ~ profile]
        [%post %add pw]
    =/  ui-card  (update-ui:cards:lib jfact)
    :~  ui-card
    ==
--
