/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    feedlib=trill-feed,
    postlib=trill-post,
    njs=json-nostr,
    postlib=trill-post,
    sr=sortug,
    ::
    mutations-nostr,
    nostr-client,
    evlib=nostr-events

|_  [=state:sur =bowl:gall]
+$  card  card:agent:gall
++  debug-own-feed
  =/  postlist  (tap:orm:feed feed.state)  
  =/  lol
  |-  ?~  postlist  ~
    ~&  >>  poast=+.i.postlist
    $(postlist t.postlist)
  ~
++  wrap-post  |=  p=post:post  ^-  post-wrapper:comms
  =/  pubkey  ?:  .=(author.p our.bowl)  pub.i.keys.state  0x0
  =/  user  (atom-to-user:lib author.p)
  =/  profile  (~(get by profiles.state) user)
  [p pubkey profile ~ ~]

  
:: state
++  add-to-feed  |=  p=post:post
  ?:  .=(our.bowl host.p)
    =.  feed.state  (put:orm:feed feed.state id.p p)
    state
    ::
    =/  host  (atom-to-user:lib host.p)
    =/  uf  (~(get by following.state) host)
    ?~  uf  state
    =/  nf  (put:orm:feed u.uf id.p p)
    =.  following.state  (~(put by following.state) host nf)
    =/  =upid:sur  [host id.p]
    =.  following2.state  (put:uorm:sur following2.state upid p)
    state
++  add-reply  |=  p=post:post  ^+  state
    ?~  parent.p  ~&  ["not a reply!!" p]  !!
    ?:  .=(our.bowl host.p)
      =/  parent  (get:orm:feed feed.state u.parent.p)
      ?~  parent  ~&  ["op not found!!" p]  !!
      =.  children.u.parent  (~(put in children.u.parent) id.p)
      =.  feed.state  (put:orm:feed feed.state id.u.parent u.parent)
      =.  feed.state  (put:orm:feed feed.state id.p p)
      state
      ::
      =/  host  (atom-to-user:lib host.p)
      =/  uf  (~(get by following.state) host)
      ?~  uf  state
      =/  parent  (get:orm:feed u.uf u.parent.p)
      ?~  parent  ~&  ["op not found!!" p]  !!
      =.  children.u.parent  (~(put in children.u.parent) id.p)
      =/  nf  (put:orm:feed u.uf id.u.parent u.parent)
      =/  nf  (put:orm:feed nf id.p p)
      =.  following.state  (~(put by following.state) host nf)

      =/  ppid=upid:sur  [host id.u.parent]      
      =.  following2.state  (put:uorm:sur following2.state ppid u.parent)
      =/  =upid:sur  [host id.p]
      =.  following2.state  (put:uorm:sur following2.state upid p)
      state

++  del-from-feed  |=  p=post:post
  ?:  .=(our.bowl host.p)
    =.  feed.state  (delete-with-children:feedlib feed.state p)
    state
    ::
    =/  host  (atom-to-user:lib host.p)
    =/  uf  (~(get by following.state) host)
    ?~  uf  state
    =/  nf  (delete-with-children:feedlib u.uf p)
    =.  following.state  (~(put by following.state) host nf)
    =.  following2.state  (delete-from-global:feedlib following2.state p)
    state

      
    
  
++  headsup-poke
  |=  [poke=post-poke:ui p=post:post]  ^-  engagement:comms
  ?-  -.poke
    %add  !!
    %del       [%del-reply id.poke id.p]
    %quote     [%quote id.poke p]
    %reply     [%reply id.poke p]
    %rp        [%rp id.poke id.p]
    %reaction  [%reaction id.poke reaction.poke]
  ==
::
++  handle-post  |=  poke=post-poke:ui
  ^-  (quip card _state)
  |^
  ~&  handle-post-ui=poke
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
  =/  crds  ~(. cards:lib bowl)
  ::  TODO UI notifications  [%hark ]
    ?-  -.poke
      %del  
        ?-  -.host.poke  
            %nostr  `state
            ::
            %urbit
          ?~  pos=(get:orm:feed feed.state id.poke)  `state
          =/  p  u.pos
          =.  feed.state  =<  +  (del:orm:feed feed.state id.poke)
          =.  feed.state  (delete-children:feedlib feed.state p)
          =/  pw  (wrap-post p)
          =/  eng-cards=(list card)  
            (del-parent-cards children.p id.p)
          =/  fact  [%post %del pw]
          :: IMPORTANT  no need to send one card per children, just have followers handle that logic
          :: =/  upd-fol-cards
          ::   %+  turn  ~(tap in children.p)
          ::   |=(c=id:post (update-followers:cards:lib [%post %del c]))
          =/  cards=(list card)
            ;:  welp
              eng-cards
              :~  (update-ui:cards:lib fact)
                  (update-followers:cards:lib fact)
              ==
            ==
          =/  is-ref=(unit [ship @da])  (get-ref:postlib p)
          =/  host=@p  +.host.poke
          ?:  .=(our.bowl host)  
            ?~  is-ref  
              ?~  parent.p  
                ::  case: delete our post
                [cards state]
              =/  poast  (get:orm:feed feed.state u.parent.p)
              ?~  poast  
                ::  case:  handle %del-parent
                [cards state]
              =.  children.u.poast  (~(del in children.u.poast) id.p)
              =.  feed.state  (put:orm:feed feed.state u.parent.p u.poast)
              :_  state
              ?:  .=(our.bowl author.p)
                ::  case: delete our reply to our post
                %+  snoc  cards
                (update-followers:cards:lib [%post %upd (wrap-post u.poast)])
              ::  case:  delete reply to our post
              ::  send %del-parent to deleted reply 
              =/  eng-poke=engagement:comms  [%del-parent u.parent.p id.p]
              %+  welp  cards
              :~
                (poke-host:crds author.p [%eng eng-poke])
                (update-followers:cards:lib [%post %upd (wrap-post u.poast)])
              ==
            =/  ref  u.is-ref
            =/  eng-poke  [%eng [%del-quote +.ref id.p]]
            ::  case: delete quote
            :_  state
            %+  snoc  cards
            (poke-host:crds `@p`-.ref eng-poke)
          ?~  parent.p
            ?~  is-ref
              ~&  'unexpected post structure'
              !!
            =/  ref=[ship @da]  u.is-ref
            =/  eng-poke  (headsup-poke [%rp host.poke +.ref] p)
            =/  eng-card  (poke-host:crds `@p`-.ref [%eng eng-poke])
            ::  case: delete rp
            :_  state
            (snoc cards eng-card)
          =/  eng-poke  (headsup-poke [%del host.poke u.parent.p] p)
          =/  eng-card  (poke-host:crds host [%eng eng-poke])
          ::  case: delete our reply
          :_  state
          (snoc cards eng-card)
        ==
      %add
        =/  sp     (build-sp:postlib our.bowl our.bowl content.poke ~ ~)
        =/  p=post:post
          (build-post:postlib now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  (wrap-post p)
        =/  fact  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib fact)
        =/  fact-card  (update-followers:cards:lib fact)
        :_  state
          :~  ui-card
              fact-card
          ==
      %quote
        =/  host  (user-to-atom:lib host.poke)
        =/  sp     (build-sp:postlib our.bowl our.bowl content.poke ~ ~)
        =/  quote  [%ref %trill host /(crip (scow:sr %ud id.poke))]
        =.  contents.sp  (snoc contents.sp quote)
        =/  p=post:post
          (build-post:postlib now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  (wrap-post p)
        =/  fact  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib fact)
        =/  fact-card  (update-followers:cards:lib fact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          :~  ui-card
              fact-card
              eng-card
          ==
      %reply
        ?:  ?=(%nostr -.host.poke)  
          =/  mutan  ~(. mutations-nostr [state bowl])
          =/  rl  get-relay:mutan
          ?~  rl  ~&  >>>  "no-relay!"  `state
          =/  wid=@  -.u.rl
          =/  relay=relay-stats:nsur  +.u.rl
          =/  nclient  ~(. nostr-client [state bowl wid relay])
          =/  ev  (build-event:evlib i.keys.state eny.bowl now.bowl content.poke)
          =/  parent-id  (crip (scow:parsing:sr %ux id.poke))
          =/  reply-tag=(list @t)  ['e' parent-id url.relay 'reply' ~]
          =.  tags.ev  ~[reply-tag]
          :_  state
          :~  (send:nclient url.relay [%event ev])
          ==
        ::
        =/  host  (user-to-atom:lib host.poke)
        =/  sp     (build-sp:postlib host our.bowl content.poke `id.poke `thread.poke)
        =/  p=post:post
          (build-post:postlib now.bowl pubkey sp)
        =.  state  (add-reply p)
        =/  pw  (wrap-post p)
        =/  fact  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib fact)
        =/  fact-card  (update-followers:cards:lib fact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          :~  ui-card
              fact-card
              eng-card
          ==
      %rp
        =/  host  (user-to-atom:lib host.poke)
        =/  quote  [%ref %trill host /(crip (scow:sr %ud id.poke))]
        =/  sp     (build-sp:postlib host our.bowl '' ~ ~)
        =.  contents.sp  ~[quote]
        =/  p=post:post
          (build-post:postlib now.bowl pubkey sp)
        =.  state  (add-to-feed p)
        =/  pw  (wrap-post p)
        =/  fact  [%post %add pw]
        =/  ui-card    (update-ui:cards:lib fact)
        =/  fact-card  (update-followers:cards:lib fact)
        =/  eng-poke  [%eng (headsup-poke poke p)]
        =/  eng-card  (poke-host:crds host.p eng-poke)
        :_  state
          :~  ui-card
              fact-card
              eng-card
          ==
      %reaction
        =/  host  (user-to-atom:lib host.poke)
        ?:  .=(host our.bowl)
          =/  p  (got:orm:feed feed.state id.poke)
          =.  reacts.engagement.p  %+  ~(put by reacts.engagement.p)
            our.bowl  [reaction.poke *signature:post]
          =.  state  (add-to-feed p)
          =/  pw  (wrap-post p)
          =/  fact  [%post %add pw]
          =/  fact-card  (update-followers:cards:lib fact)
          =/  ui-card    (update-ui:cards:lib fact)
          =/  eng-poke  [%eng (headsup-poke poke p)]
          =/  eng-card  (poke-host:crds host eng-poke)

          :_  state
            :~  ui-card
                fact-card
                eng-card
            ==
            ::
            =/  default-eng  [%eng (headsup-poke poke *post:post)]
            :: TODO we kinda should use following2 for this
            :: If we have the relevant post in our state somewhere we want to update the UI too. Else we just send the headsup poke to the post host
          :: =/  up  (get:orm:feed following2.state id.poke)
            =/  uf  (~(get by following.state) host.poke)
            ?~  uf  :_  state  :~((poke-host:crds host default-eng))
            =/  up  (get:orm:feed u.uf id.poke)
            ?~  up  :_  state  :~((poke-host:crds host default-eng))
            =/  p  u.up 
            =.  reacts.engagement.p  %+  ~(put by reacts.engagement.p)
              our.bowl  [reaction.poke *signature:post]
            =.  state  (add-to-feed p)
            =/  pw  (wrap-post p)
            =/  fact  [%post %add pw]
            =/  ui-card    (update-ui:cards:lib fact)
            =/  eng-poke  [%eng (headsup-poke poke p)]
            =/  eng-card  (poke-host:crds host.p eng-poke)
            :_  state
              :~  ui-card
                  eng-card
              ==
    ==
  ::
  ++  del-parent-cards
    |=  [children=(set id:post) parent=@da]
    =/  c  ~(tap in children)
    =/  crds  ~(. cards:lib bowl)
    |-  ^-  (list card)
    ?~  c  ~
    =/  child=(unit post:post)  (get:orm:feed feed.state i.c)
    ?~  child  $(c t.c)
    :_  $(c t.c)
    =/  eng-poke=engagement:comms  [%del-parent parent id.u.child]
    =/  host=@p  author.u.child
    (poke-host:crds host [%eng eng-poke])
  --

++  handle-post-fact  |=  pf=post-fact:comms
  ^-  (quip card _state)
  ~&  handle-post-fact=pf
  ?-  -.pf
    %add  :_  (add-to-feed post.pf)
          :~  (update-ui:cards:lib [%post pf])  
          ==
    %upd  :_  (add-to-feed post.pf)
          :~  (update-ui:cards:lib [%post pf])  
          ==
    %del  :_  (del-from-feed post.pf)
          :~  (update-ui:cards:lib [%post pf])  
          ==
  ==
--
