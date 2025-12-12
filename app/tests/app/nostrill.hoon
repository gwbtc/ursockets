/-  sur=nostrill, nostr, tf=trill-feed,
    comms=nostrill-comms, post=trill-post,
    tg=trill-gate, ui=nostrill-ui
/+  *test, test-agent, lib=nostrill, sr=sortug, nostr-keys,
    jsonlib=json-nostrill, json-nostr, server,
    common=json-common, nostr-events, hark,
    gate=trill-gate, feedlib=trill-feed, tp=trill-post
/=  agent  /app/nostrill
|%
+$  card  card:agent:gall
++  state  $%(state-0:sur)
--
|%
::
++  get-state
  =/  m  (mare:test-agent ,state-0:sur)
  ^-  form:m
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state  !<(state-0:sur saved)
  (pure:m state)
::
++  scry-gate
  |=  =path
  ^-  (unit vase)
  ?+  path  ~
      [%j ship=@ %sein now=@ get=@ *]  
    `!>((slav %p get.i.t.t.t.t.path))
    ::
      [%e ship=@ %host now=@ *]
    `!>(`hart:eyre`[| ~ [%.y ~[%localhost]]])
    ::
      [%ix ship=@ %ws now=@tas %id id=@t ~]
    =/  url=@t  'wss://nos.lol' 
    `!>(`websocket-connection:iris`[%nostrill ~ *@ud url %accepted])
  ==
::
++  ex-update
  |=  =fact:comms  
  %+  ex-fact:test-agent
    ~[/follow]
  noun+!>(fact)
::
++  ex-ui-update
  |=  =fact:ui
  %+  ex-fact:test-agent
    ~[/ui]
  json+!>((fact:en:jsonlib fact))
::
++  ex-eng
  |=  [host=@p eng=engagement:comms]
  %^  ex-poke:test-agent  /heads-up 
  [host %nostrill] 
  noun+!>([%eng eng])
::
++  wrap-post
  |=  [p=post:post state=state-0:sur =bowl:gall]
  ^-  post-wrapper:comms
  =/  pubkey  ?:  .=(author.p our.bowl)  pub.i.keys.state  0x0
  =/  user  (atom-to-user:lib author.p)
  =/  profile  (~(get by profiles.state) user)
  [p pubkey profile ~ ~]
::
++  ex-follow-task
  |=  =gill:gall 
  %^  ex-task:test-agent  /follow
  gill  [%watch /follow]
::
++  ex-leave-task
  |=  =ship
  %^  ex-task:test-agent  /follow
  [ship %nostrill]  [%leave ~]
::
++  do-on-ui-poke 
  |=  [=bowl:gall data=json]
  =/  m  (mare:test-agent ,(list card))
  ^-  form:m
  ;<  caz=(list card)  bind:m
    (do-poke:test-agent %json !>(data))
  (pure:m caz)
::
++  ex-cards-post-poke
  |=  [post-poke=?([%add ~] [%reply id=@da] [%quote id=@da] [%rp id=@da]) state=state-0:sur =bowl:gall host=@p]
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
  =/  p=post:post
    ?-  -.post-poke
      ::
        %add
      %^  build-post:tp  now.bowl  pubkey
      (build-sp:tp our.bowl our.bowl 'Hello world' ~ ~)
      ::
        %reply
      %^  build-post:tp  now.bowl  pubkey
      (build-sp:tp host our.bowl 'Reply' `id.post-poke `id.post-poke)
      ::
        %quote
      =+  sp=(build-sp:tp our.bowl our.bowl 'Quote' ~ ~)
      =.  contents.sp  
        %+  snoc  contents.sp 
        [%ref %trill host /(crip (scow:sr %ud `@ud`id.post-poke))]
      (build-post:tp now.bowl pubkey sp)
      ::
        %rp 
      =+  sp=(build-sp:tp host our.bowl '' ~ ~)
      =.  contents.sp
        ~[[%ref %trill host /(crip (scow:sr %ud id.post-poke))]]
      (build-post:tp now.bowl pubkey sp)
    ==
  =/  upd-card  (ex-update [%post %add (wrap-post p state bowl)])
  %+  welp
    :~  (ex-ui-update [%post %add (wrap-post p state bowl)])
    ==
  ?+  -.post-poke  :~(upd-card)
      %reply 
    :~  upd-card
        (ex-eng host [%reply id.post-poke p])
    ==
      %quote
    ?:  =(host our.bowl)  
      :~  upd-card
          (ex-eng host [%quote id.post-poke p])
      ==
    :~  (ex-eng host [%quote id.post-poke p])
    ==
      %rp
    =/  eng-poke=engagement:comms
        [%rp [user=urbit+host id=id.post-poke] target=id.p]
    ?:  =(host our.bowl)  
      :~  upd-card
          (ex-eng host eng-poke)
      ==
    :~  (ex-eng host eng-poke)
    ==
  ==
::
++  make-json-reply 
  |=  [post-id=@da host=@p]
  =,  enjs:format
  %-  pairs 
  :~  :-  'post'
      %+  frond  'reply'
      %-  pairs
      :~  ['content' s+'Reply']
          ['host' (frond 'urbit' s+(scot %p host))]
          ['id' (ud:en:common post-id)]
          ['id' (ud:en:common post-id)]
      ==
  ==
::
++  test-poke-ui-post
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  caz=(list card)  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall       bind:m  get-bowl:test-agent
  =/  post-id  now.bowl
  ;<  state-1=state-0:sur  bind:m  get-state
  ::  poke add-post
  ;<  caz-add=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  
      'post'^(frond 'add' (frond 'content' s+'Hello world'))
    ==
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add
    (ex-cards-post-poke [%add ~] state-1 bowl our.bowl)
  :: poke reply to post 
  ;<  state-2=state-0:sur  bind:m  get-state
  ;<  ~                    bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall           bind:m  get-bowl:test-agent
  =/  reply-id  now.bowl
  ;<  caz-rep=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  (make-json-reply post-id our.bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-rep
    (ex-cards-post-poke [%reply post-id] state-2 bowl our.bowl)
  ::  quote reply
  ;<  state-3=state-0:sur  bind:m  get-state
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall           bind:m  get-bowl:test-agent
  =/  quote-id  now.bowl
  :: 
  ;<  caz-qot=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  :-  'post'
        %+  frond  'quote'
        %-  pairs
        :~  ['content' s+'Quote']
            ['host' (frond 'urbit' s+(scot %p our.bowl))]
            ['id' (ud:en:common reply-id)]
        ==
    ==
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-qot
    (ex-cards-post-poke [%quote reply-id] state-3 bowl our.bowl)
  ::  repost quote post
  ;<  state-4=state-0:sur  bind:m  get-state
  ;<  ~  bind:m  (wait:test-agent ~h1)  ::  preventing id duplication(post overwrite)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz-rp=(list card)   bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  :-  'post'
        %+  frond  'rp'
        %-  pairs
        :~  ['host' (frond 'urbit' s+(scot %p our.bowl))]
            ['id' (ud:en:common quote-id)]
        ==
    ==
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-rp
    (ex-cards-post-poke [%rp quote-id] state-3 bowl our.bowl)
  ;<  state-5=state-0:sur  bind:m  get-state
  =/  feed-size  (wyt:orm:tf feed:state-5)
  ;<  ~  bind:m
    (ex-equal:test-agent !>(feed-size) !>(4))
  ::
  ::  reply from our ship to foreign ship
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  json-rep-2  (make-json-reply quote-id ~bus)
  ;<  caz-rep-2=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  json-rep-2
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-rep-2
    (ex-cards-post-poke [%reply quote-id] state-2 bowl ~bus)
  ;<  state-fin=state-0:sur  bind:m  get-state
  =/  feed-size-2  (wyt:orm:tf feed.state-fin)
  (ex-equal:test-agent !>(feed-size-2) !>(4))
::
++  test-poke-eng
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ;<  caz=(list card)  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall       bind:m  get-bowl:test-agent
  =/  post-id  now.bowl
  ;<  caz-add=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  
      'post'^(frond 'add' (frond 'content' s+'Hello world'))
    ==
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  state=state-0:sur  bind:m  get-state
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  ~  bind:m  (poke-eng-reply post-id)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  reply-id  now.bowl
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  ~  bind:m  (poke-eng-del-rep state reply-id)
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  ~  bind:m  (poke-eng-quote post-id)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  quote-id  now.bowl
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  ~  bind:m  (poke-eng-del-quote state post-id quote-id)
  ;<  ~  bind:m  (poke-eng-rp post-id)
  ;<  ~  bind:m  (poke-eng-reaction post-id)
  (ex-equal:test-agent !>(~) !>(~))
::
++  hark-card-eng  
  |=  [e=engagement:comms =bowl:gall]
  =/  notif  [%post [urbit+src.bowl now.bowl e]]
  (send-hark:hark notif bowl)
::
++  poke-eng-reply
  |=  post-id=@da
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  state=state-0:sur  bind:m  get-state
  ;<  =bowl:gall         bind:m  get-bowl:test-agent
  =/  child=post:post
    %^  build-post:tp  now.bowl  pub.i.keys.state
    ::  post is made by ~bus and host-post made by ~zod 
    (build-sp:tp our.bowl src.bowl 'Reply' `post-id `post-id)
  =/  eng  [%reply post-id child]
  ;<  caz=(list card)    bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ::
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  p  (got:orm:tf feed.state post-id)
  =.  children.p  (~(put in children.p) id.child)
  =.  feed.state  (put:orm:tf feed.state post-id p)
  =.  feed.state  (put:orm:tf feed.state id.child child)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %add (wrap-post child state bowl)])
        (ex-ui-update [%post %add (wrap-post child state bowl)])
        (ex-update [%post %upd (wrap-post p state bowl)])
        (ex-ui-update [%post %add (wrap-post p state bowl)])
        (ex-card:test-agent (hark-card-eng eng bowl))
    ==
  (ex-equal:test-agent !>(state-2) !>(state))
::
++  poke-eng-del-rep
  |=  [ex-state=state-0:sur post-id=@da]
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall         bind:m  get-bowl:test-agent
  ;<  state=state-0:sur  bind:m  get-state
  =/  eng  [%del-reply [urbit+our.bowl *@da] post-id]
  ;<  caz=(list card)    bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  del-post  (got:orm:tf feed.state post-id)
  =/  p  
    ?~  parent.del-post  !!
  (got:orm:tf feed.ex-state u.parent.del-post)
  =/  wp-del  (wrap-post del-post ex-state bowl)
  =/  wp  (wrap-post p ex-state bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %del wp-del])
        (ex-ui-update [%post %del wp-del])
        (ex-update [%post %upd wp])
        (ex-ui-update [%post %add wp])
        ::  TODO: hark-upd
    ==
  (ex-equal:test-agent !>(state-2) !>(ex-state))
::
++  poke-eng-quote
  |=  post-id=@da
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  state=state-0:sur  bind:m  get-state
  =/  quote-id  now.bowl
  =/  quote=post:post  *post:post
  =.  id.quote  now.bowl
  =/  eng  [%quote post-id quote]
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  p  (got:orm:tf feed.state post-id)
  =.  quoted.engagement.p  
    %-  ~(put in quoted.engagement.p)
    [*signature:post src.bowl quote-id]
  =.  feed.state  (put:orm:tf feed.state post-id p)
  ::
  =/  wp  (wrap-post p state bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %upd wp])
        (ex-ui-update [%post %add wp])
        (ex-card:test-agent (hark-card-eng eng bowl))
    ==
  (ex-equal:test-agent !>(state-2) !>(state))
::
++  poke-eng-del-quote
  |=  [ex-state=state-0:sur post-id=@da quote-id=@da]
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  eng  [%del-quote [urbit+our.bowl post-id] quote-id]
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ;<  state=state-0:sur  bind:m  get-state
  =/  p   (got:orm:tf feed.ex-state post-id)
  =/  wp  (wrap-post p ex-state bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %upd wp])
        (ex-ui-update [%post %add wp])
        (ex-card:test-agent (hark-card-eng eng bowl))
    ==
  (ex-equal:test-agent !>(state) !>(ex-state))
::
++  poke-eng-rp
  |=  post-id=@da
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  state=state-0:sur  bind:m  get-state
  =/  rp-id  now.bowl
  =/  eng-err  [%rp [urbit+our.bowl rp-id] rp-id]
  ;<  caz-err=(list card)  bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng-err])
  =/  hark-card  (ex-card:test-agent (hark-card-eng eng-err bowl))
  ;<  ~  bind:m  (ex-cards:test-agent caz-err :~(hark-card))
  =/  eng  [%rp [urbit+our.bowl post-id] rp-id]
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  p  (got:orm:tf feed.state post-id)
  =.  shared.engagement.p
    %-  ~(put in shared.engagement.p) 
    [*signature:post src.bowl rp-id]
  =.  feed.state  (put:orm:tf feed.state post-id p)
  =/  wp  (wrap-post p state bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %upd wp])
        (ex-ui-update [%post %add wp])
        (ex-card:test-agent (hark-card-eng eng bowl))
    ==
  (ex-equal:test-agent !>(state-2) !>(state))
::
++  poke-eng-reaction
  |=  post-id=@da
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  state=state-0:sur  bind:m  get-state
  =/  eng  [%reaction [urbit+our.bowl post-id] 'wow']
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    noun+!>([%eng eng])
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  p  (got:orm:tf feed.state post-id)
  =/  sign  *signature:post
  =.  q.sign  src.bowl
  =.  reacts.engagement.p
    %-  ~(put by reacts.engagement.p)  
    ::  TODO:  signature
    [src.bowl ['wow' sign]]
  =.  feed.state  (put:orm:tf feed.state post-id p)
  =/  wp  (wrap-post p state bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz
    :~  (ex-update [%post %upd wp])
        (ex-ui-update [%post %add wp])
        (ex-card:test-agent (hark-card-eng eng bowl))
    ==
  (ex-equal:test-agent !>(state-2) !>(state))
::
++  test-poke-ui-prof
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  caz=(list card)  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  post-id  now.bowl
  ;<  state-1=state-0:sur  bind:m  get-state
  ;<  caz-add=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  :-  'prof' 
        %+  frond  'add' 
        %-  pairs
        :~  ['name' s+'zod']
            ['about' s+'about me']
            ['picture' s+'']
            ['other' (pairs ~[['location' s+'Urbit'] ['status' s+'testing']])]
        ==
    ==
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  ex-data
    :*  'zod'
        'about me'
        ''
        (malt ~[['location' s+'Urbit'] ['status' s+'testing']])
    == 
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add  
    ::  XX: currently app/nostrill doesn't send any update to followers or UI on %prof poke
    :~  (ex-update [%prof %prof ex-data])
        ::(ex-ui-update [%prof ex-data])
    ==
  =/  data  (~(get by profiles.state-2) urbit+our.bowl)
  ;<  ~  bind:m  
    %+  ex-equal:test-agent
      !>(data)
      !>(`ex-data)
  ;<  caz-del=(list card)  bind:m  
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs  :~('prof'^(frond 'del' ~))
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add
    ::  TODO: same issue as the above 
    :~  (ex-update [%prof %prof *user-meta:nostr])
        (ex-ui-update [%prof *user-meta:nostr])
    ==
  ;<  state-3=state-0:sur  bind:m  get-state
  %+  ex-equal:test-agent
    !>((~(get by profiles.state-3) [%urbit our.bowl]))
    !>(~)
::
++  fol  ~bus
::
++  relay-url  'wss://nos.lol'  :: temp
::
++  dec-ok  'どうぞ'
::
++  do-fols-add-urbit
  |=  =bowl:gall
  =/  m  (mare:test-agent ,(list card))
  ^-  form:m
  ;<  caz=(list card)  bind:m  
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs  
    :~  
      :-  'fols'
      (frond 'add' (frond 'urbit' s+(scot %p fol)))
    ==
  (pure:m caz)
::
++  do-fols-add-nostr
  |=  [=bowl:gall pub=@]
  =/  m  (mare:test-agent ,(list card))
  ^-  form:m
  ;<  caz=(list card)  bind:m  
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs  
    :~  :-  'fols'
        (frond 'add' (frond 'nostr' (hex:en:common pub)))
    ==
  (pure:m caz)
::
++  do-agent-follow
  |=  =sign:agent:gall
  =/  m  (mare:test-agent ,(list card))
  ^-  form:m
  ;<  caz=(list card)  bind:m
    (do-agent:test-agent /follow [fol %nostrill] sign)
  (pure:m caz)
::
++  ex-fols
  |=  [ex-bowl=? ex-state=?]
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ~&  >>  %in-bowl
  ;<  ~  bind:m
    %+  ex-equal:test-agent
      !>((~(has by wex.bowl) [/follow fol %nostrill]))
      !>(ex-bowl)
  ~&  >>  %in-state
  ;<  state=state-0:sur  bind:m  get-state
  %+  ex-equal:test-agent
    !>((~(has by following.state) urbit+fol))
    !>(ex-state)
::
::  Testing %fols (follow) poke flow:
::
++  test-poke-ui-fols-urbit-user
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m  (do-init:test-agent %nostrill agent)
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ::  a ship get's nack on following watch
  ::
  ;<  caz-add=(list card)  bind:m  (do-fols-add-urbit bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add
    :~  (ex-follow-task [fol dap.bowl])
    ==
  ;<  ~  bind:m  (ex-fols & |)
  ;<  caz-nack=(list card)  bind:m
    (do-agent-follow [%watch-ack `['subscription denied']~])
  ;<  ~  bind:m  (ex-cards:test-agent caz-nack ~)
  ;<  ~  bind:m  (ex-fols | |)
  ::  A ship gets %ng fact on following 
  ::
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz-add-2=(list card)  bind:m  (do-fols-add-urbit bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add-2
    :~  (ex-follow-task [fol dap.bowl])
    ==
  =/  fact  [%feed msg='not allowed' p=[%done %ng]]
  ;<  caz-ng=(list card)  bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>(fact)
  ;<  caz-kick=(list card)  bind:m
    (do-agent-follow [%kick ~])
  ::  In %nostrill agent on %ng fact 
  =/  notif  [%fol-res [urbit+src.bowl now.bowl +.fact]]
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-ng
    :~  (ex-card:test-agent (send-hark:hark notif bowl))
        (ex-ui-update [%fols %new +.notif])
    ==
  ;<  ~  bind:m  (ex-fols | |)
  ::  %ok fact on following
  ::  
  ;<  caz-add-3=(list card)  bind:m  (do-fols-add-urbit bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add-3
    :~  (ex-follow-task [fol dap.bowl])
    ==
  =/  mock-profile
    :*  'bus'
        'Hello from bus'
        ''
        (malt ~[['location' s+'Urbit']])
    ==
  =/  =fc:tf  [*feed:tf `*@da `*@da]
  =/  fact-ok  [%feed dec-ok p=[%done %ok data=[fc `mock-profile]]]
  ;<  caz-ok=(list card)  bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>(fact-ok)
  ;<  state=state-0:sur  bind:m  get-state
  ;<  ~  bind:m  (ex-fols & &)
  =/  notif  [%fol-res [urbit+src.bowl now.bowl +.fact-ok]]
  ;<  ~  bind:m
    %+  ex-equal:test-agent
      !>((~(get by profiles.state) urbit+fol))
      !>(`mock-profile)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-ok
    :~  (ex-card:test-agent (send-hark:hark notif bowl))
        (ex-ui-update [%fols %new +.notif])
    ==
  ::  update from subscribtion
  ::
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall             bind:m  get-bowl:test-agent
  ;<  state-fol=state-0:sur  bind:m  get-state
  =+  mock-post=*post:post
  =.  id.mock-post      now.bowl
  =.  author.mock-post  fol
  =.  host.mock-post    fol
  ;<  caz-post=(list card)   bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>([%post [%add (wrap-post mock-post state-fol bowl)]])
  ;<  state-2=state-0:sur  bind:m  get-state
  =/  bus-post  (has:orm:tf (~(got by following.state-2) urbit+fol) now.bowl)
  ;<  ~  bind:m
    %+  ex-equal:test-agent
      !>(bus-post)
      !>(&)
  ;<  ~  bind:m  (ex-fols & &)
  ::  a ship sends %fols %del and unsubscribes
  ::
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz-del=(list card)  bind:m  
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs  
    :~  :-  'fols'
        (frond 'del' (frond 'urbit' s+(scot %p fol)))
    ==
  ;<  ~  bind:m  (ex-fols | |)
  %+  ex-cards:test-agent  caz-del
    :~  (ex-ui-update [%fols %quit urbit+fol])
        (ex-leave-task fol)
    ==
::
++  do-poke-ws-client
  |=  [=keys:nostr =bowl:gall sub-id=@t content=@t msg=@tas]
  =/  m  (mare:test-agent ,[(list card) event:nostr])
  ^-  form:m
  =/  e=event:nostr  
    %^  post-to-event:nostr-events  keys  eny.bowl
    %^  build-post:tp  ~2010.10.10  -.keys 
    (build-sp:tp our.bowl our.bowl content ~ ~)
  =/  data-octs=octs
    %-  json-to-octs:server
    %-  relay-msg:en:json-nostr 
    ?+  msg  [%notice 'wrong msg']
        %event
      [%event sub-id e]
      ::
        %eose  
      [%eose sub-id]
    ==
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    websocket-client-message+!>([*@ud [1 `data-octs]])
  (pure:m [caz e])
::
++  test-beg-feed-not-allowed
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m  (do-init:test-agent %nostrill agent)
  ;<  state=state-0:sur  bind:m  get-state
  =/  lock-state  state(lock.feed-perms (lock-all:gate lock.feed-perms.state))
  ;<  *  bind:m  (do-load:test-agent agent `!>(lock-state))
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz=(list card)  bind:m
    (do-watch:test-agent /beg/feed)
  =/  enreq  
    :*  urbit+src.bowl 
        now.bowl
        ['' %begs %feed]
    ==
  =/  decision  [now.bowl .n .n 'not allowed']
  =/  hark-card  (send-hark:hark [%req enreq `decision] bowl)
  =/  jon  (res:en:jsonlib [%feed msg='not allowed' p=[%done %ng]])
  %+  ex-cards:test-agent  caz
  :~  (ex-card:test-agent hark-card)
      (ex-fact:test-agent ~[/beg/feed] json+!>(jon))
      (ex-card:test-agent %give %kick ~[/beg/feed] ~)
  ==
::
++  test-beg-thread
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m    (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m    (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  *  bind:m
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs
    :~  'post'^(frond 'add' (frond 'content' s+'Test post'))
    ==
  ;<  state-1=state-0:sur  bind:m  get-state
  ::  on-watch beg thread missing id in path
  ::
  ::
  ;<  ~  bind:m    (set-src:test-agent ~bus)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz=(list card)  bind:m  (do-watch:test-agent /beg/thread/(scot %da now.bowl))
  ;<  ~  bind:m    (ex-cards:test-agent caz ~)
  ::  on-watch beg thread with non existant id 
  ::
  ;<  caz-ng-thread=(list card)  bind:m
    (do-watch:test-agent /beg/thread/(crip (scow:sr %uw `@`~2010.1.1)))
  =/  jon-ng-thread  (res:en:jsonlib [%thread `@da`~2010.1.1 msg='no such thread' p=[%done %ng]])
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-ng-thread
    :~  (ex-fact:test-agent ~[/beg/thread/(crip (scow:sr %uw `@`~2010.1.1))] json+!>(jon-ng-thread))
        (ex-card:test-agent %give %kick ~[/beg/thread/(crip (scow:sr %uw `@`~2010.1.1))] ~)
    ==
  =/  thread=[id:post p=post:post]  head:(pop:orm:tf feed.state-1)
  =/  thread-id  (crip (scow:sr %uw `@`-.thread))
  ::  on-watch beg thread ok
  ::
  ;<  caz-ok=(list card)  bind:m
    (do-watch:test-agent /beg/thread/[thread-id])
  =/  jon-ok=json
    %-  res:en:jsonlib
    ;;  res:comms
    :*  %thread
        id=-.thread
        msg=dec-ok
        p=[%done %ok data=(node-to-full:feedlib p.thread feed.state-1) ~]
    ==
  =/  enreq
    :*  urbit+src.bowl 
        now.bowl
        ['' [%begs [%thread -.thread]]]
    ==
  =/  decision  [now.bowl .y .n dec-ok]
  =/  hark-card  (send-hark:hark [%req enreq `decision] bowl)
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-ok
    :~  (ex-card:test-agent hark-card)
        (ex-fact:test-agent ~[/beg/thread/[thread-id]] json+!>(jon-ok))
        (ex-card:test-agent %give %kick ~[/beg/thread/[thread-id]] ~)
    ==
  =/  lock-state  state-1(lock.feed-perms (lock-all:gate lock.feed-perms.state-1))
  ::  on-watch beg thread with locked permissions
  ::
  ;<  *  bind:m  (do-load:test-agent agent `!>(lock-state))
  ;<  state-2=state-0:sur  bind:m  get-state
  ;<  caz-ng-na=(list card)  bind:m
    (do-watch:test-agent /beg/thread/[thread-id])
  =/  jon-ng-na  (res:en:jsonlib [%thread -.thread msg='not allowed' p=[%done %ng]])
  =/  enreq-ng  
    :*  urbit+src.bowl 
        now.bowl
        ['' [%begs [%thread -.thread]]]
    ==
  =/  decision-ng  [now.bowl .n .n 'not allowed']
  =/  hark-card-ng  (send-hark:hark [%req enreq-ng `decision-ng] bowl)
  ::  
  %+  ex-cards:test-agent  caz-ng-na
    :~  (ex-card:test-agent hark-card-ng)
        (ex-fact:test-agent ~[/beg/thread/[thread-id]] json+!>(jon-ng-na))
        (ex-card:test-agent %give %kick ~[/beg/thread/[thread-id]] ~)
    ==
::  websockets pokes
::
++  ex-fact-ws-response
  |=  [wid=@ event=websocket-event:eyre]
  :~  (ex-fact:test-agent ~[/websocket-server/(scot %ud wid)] websocket-response+!>([wid event]))
  ==
++  test-ws-handshake
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m    (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m    (do-init:test-agent %nostrill agent)
  =+  order=[*@ *inbound-request:eyre]
  ::  can't parse request url path 
  ::
  ;<  caz-parsing-fail=(list card)  bind:m
    (do-poke:test-agent websocket-handshake+!>(order))
  ;<  ~  bind:m    (ex-cards:test-agent caz-parsing-fail ~)
  ::  unrecognised url path for ws handshake
  ::
  =.  url.request.order  '/some/path'
  ;<  caz-refuse=(list card)  bind:m
    (do-poke:test-agent websocket-handshake+!>(order))
  ;<  ~  bind:m    
    %+  ex-cards:test-agent  caz-refuse
    (ex-fact-ws-response -.order [%reject ~])
  ::  correct handshake on /nostrill url path 
  ::
  =.  url.request.order  '/nostrill'
  ;<  caz-accept=(list card)  bind:m
    (do-poke:test-agent websocket-handshake+!>(order))  
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-accept
    (ex-fact-ws-response -.order [%accept ~])
  ::  not authenticated handahke request on /nostrill-ui
  ::
  =.  url.request.order  '/nostrill-ui'
  =.  authenticated.order  %.n
  ;<  caz-refuse-on-auth-check=(list card)  bind:m
    (do-poke:test-agent websocket-handshake+!>(order))
  ;<  ~  bind:m    
    %+  ex-cards:test-agent  caz-refuse-on-auth-check
    (ex-fact-ws-response -.order [%reject ~])
  ::  authenticated handshake request on /nostrill-ui
  :: 
  =.  authenticated.order  %.y
  ;<  caz-accept-nostrill-ui=(list card)  bind:m
    (do-poke:test-agent websocket-handshake+!>(order))  
  %+  ex-cards:test-agent  caz-accept-nostrill-ui
  (ex-fact-ws-response -.order [%accept ~])
::
++  test-ws-server-message-nostrill-ui
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~           bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *           bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =+  order=[wid=*@ path=*path *websocket-message:eyre]
  ::  websocket-message with empty message
  ::
  ;<  caz-null-msg=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  ;<  ~  bind:m  (ex-cards:test-agent caz-null-msg ~)
  ::  websocket-message on nostrill-ui path
  ::
  =.  path.order  /nostrill-ui
  =.  message.order  `(as-octs:mimes:html 9.845.520.452.860.477.235.337.509.658.680.638.164.556.884.843.497.220.435.169.503.289.947)
  ;<  caz-nostrill-ui=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  =/  ex-event=websocket-event:eyre
    :*  %message  1
      =/  msg  q.data:(need message.order)
      `(as-octs:mimes:html (cat 3 msg (cat 3 msg msg)))
    ==
  %+  ex-cards:test-agent  caz-nostrill-ui
  (ex-fact-ws-response -.order ex-event)
::
--