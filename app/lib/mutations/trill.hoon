/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui, notif=nostrill-notif,
    post=trill-post, gate=trill-gate, feed=trill-feed
    
/+  appjs=json-nostrill,
    lib=nostrill,
    harklib=hark,
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
    %reply     [%reply id.poke p]
    %quote     [%quote id.poke p]
    %rp        [%rp [host.poke id.poke] id.p]
    %del       [%del-reply [host.poke id.poke] id.p]
    %reaction  [%reaction [host.poke id.poke] reaction.poke]
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
            :: TODO
            %nostr  `state
            ::
            %urbit
          ?~  pos=(get:orm:feed feed.state id.poke)  `state
          =/  p  u.pos
          =.  feed.state  =<  +  (del:orm:feed feed.state id.poke)
          =.  feed.state  (delete-children:feedlib feed.state p)
          =/  pw  (wrap-post p)
          =/  eng-cards=(list card)  
            (del-parent-cards host.poke children.p id.p)
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
              =/  eng-poke=engagement:comms  [%del-parent [host.poke u.parent.p] id.p]
              %+  welp  cards
              :~
                (poke-host:crds author.p [%eng eng-poke])
                (update-followers:cards:lib [%post %upd (wrap-post u.poast)])
              ==
            =/  ref  u.is-ref
            =/  eng-poke  [%eng [%del-quote [host.poke +.ref] id.p]]
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

        =/  mentions  (extract-mentions:postlib p)
        =/  mention-cards  %+  turn  mentions  |=  s=@p
          %+  poke-host:crds  s  [%eng %mention p]
        :_  state
          %+  weld  mention-cards
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

        =/  mentions  (extract-mentions:postlib p)
        =/  mention-cards  %+  turn  mentions  |=  s=@p
          %+  poke-host:crds  s  [%eng %mention p]
        
        :_  state
          %+  weld  mention-cards
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

        =/  mentions  (extract-mentions:postlib p)
        =/  mention-cards  %+  turn  mentions  |=  s=@p
          %+  poke-host:crds  s  [%eng %mention p]
        
        :_  state
          %+  weld  mention-cards
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
    |=  [host=user:sur children=(set id:post) parent=@da]
    =/  c  ~(tap in children)
    =/  crds  ~(. cards:lib bowl)
    |-  ^-  (list card)
    ?~  c  ~
    =/  child=(unit post:post)  (get:orm:feed feed.state i.c)
    ?~  child  $(c t.c)
    :_  $(c t.c)
    =/  eng-poke=engagement:comms  [%del-parent [host parent] id.u.child]
    =/  host=@p  author.u.child
    (poke-host:crds host [%eng eng-poke])
  --


  ++  handle-eng
    |=  e=engagement:comms
    ^-  (quip card:agent:gall _state)
    =/  user  [%urbit src.bowl]
    =/  n=notif:notif  [%post [user now.bowl e]]
    =/  hark-card=card:agent:gall  (send-hark:harklib n bowl)
    =/  cards  :~(hark-card)
    ::  We send the notification always.
    ::  Only update state if we are the host. Else we wait for the fact from the actual host
    ?-  -.e
      %mention  [cards state]
      %reply
        =/  poast  (get:orm:feed feed.state parent.e)
        ?~  poast  ~&  "parent of reply doesnt exist"  [cards state]
        =.  state  (add-reply child.e)
        ::  now the parent should be updated 
        =/  poast  (get:orm:feed feed.state parent.e)
        ?~  poast  ~&  "parent of reply doesnt exist"  [cards state]
        =/  f=fact:comms   [%post %add (wrap-post child.e)]
        =/  f2=fact:comms  [%post %upd (wrap-post u.poast)]
        :_  state
        :~  (update-followers:cards:lib f)
            (update-followers:cards:lib f2)
            hark-card
        ==
      %quote
        =/  poast  (get:orm:feed feed.state src.e)
        ?~  poast  [cards state]
        ::
        =/  pid  [our.bowl src.e]
        =/  spid  [*signature:post src.bowl id.post.e]
        =.  quoted.engagement.u.poast  (~(put in quoted.engagement.u.poast) spid)
        =.  state  (add-to-feed u.poast)
        =/  f=fact:comms  [%post %upd (wrap-post u.poast)]
        :_  state
        :~  (update-followers:cards:lib f)
            hark-card
        ==
      %rp
        =/  poast  (get:orm:feed feed.state id.src.e)
        ?~  poast  [cards state]
        =/  pid  [our.bowl src.e]
        =/  spid  [*signature:post src.bowl target.e]
        =.  shared.engagement.u.poast  
          ?:  (~(has in shared.engagement.u.poast) spid)
            (~(del in shared.engagement.u.poast) spid)
          (~(put in shared.engagement.u.poast) spid)
        =.  state  (add-to-feed u.poast)
        =/  f=fact:comms  [%post %upd (wrap-post u.poast)]
        :_  state
        :~  (update-followers:cards:lib f)
             hark-card
        ==
      %reaction
        =/  poast  (get:orm:feed feed.state id.pid.e)
        ?~  poast  [cards state]
        :: TODO signatures et al.
        =/  pid  [our.bowl id.pid.e]
        =/  sign  *signature:post
        =.  q.sign  src.bowl
        =.  reacts.engagement.u.poast  (~(put by reacts.engagement.u.poast) src.bowl [reaction.e sign])
        =.  state  (add-to-feed u.poast)
        =/  f=fact:comms  [%post %upd (wrap-post u.poast)]
        :_  state
        :~  (update-followers:cards:lib f)
            hark-card
        ==
      %del-reply 
        ?~  p=(get:orm:feed feed.state child.e)  [cards state]
        =/  parent  (get:orm:feed feed.state id.parent.e)
        ?~  parent  [cards state]
        ::
        =/  pid  [our.bowl id.parent.e]
        =.  state  (del-from-feed u.p)
        ::  get the updated parent
        =/  parent  (get:orm:feed feed.state id.parent.e)
        ?~  parent  ~&  "parent failed to update!!"  [cards state]
        :_  state
        :~  (update-followers:cards:lib [%post %upd (wrap-post u.parent)])
            (update-followers:cards:lib [%post %del (wrap-post u.p)])
            hark-card
        ==
      
      %del-parent  ::  this is always going to be external
        [cards state]
      %del-quote
        =/  poast  (get:orm:feed feed.state id.src.e)
        ?~  poast  [cards state]
        ::
        =/  pid  [our.bowl src.e]

        =/  spid  [*signature:post src.bowl quote.e]
        =.  quoted.engagement.u.poast  (~(del in quoted.engagement.u.poast) spid)
        =.  state  (add-to-feed u.poast)
        =/  f=fact:comms  [%post %upd (wrap-post u.poast)]
        :_  state
        :~  (update-followers:cards:lib f)
            hark-card
        ==
    ==







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
