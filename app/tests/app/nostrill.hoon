/-  sur=nostrill, nostr, tf=trill-feed,
    comms=nostrill-comms, post=trill-post,
    tg=trill-gate
/+  *test, test-agent, sr=sortug, nostr-keys,
    jsonlib=json-nostrill, json-nostr, server,
    common=json-common, nostr-events,
    gate=trill-gate, feedlib=trill-feed, tp=trill-post
/=  agent  /app/nostrill
|%
+$  card  card:agent:gall
++  bowl-our
  |=  run=@ud
  ^-  bowl:gall
  :*  [~zod ~bus %nostrill ~]
      [~ ~ ~]
      [run `@uvJ`(shax run) (add (mul run ~s1) *time) [~zod %nostrill ud+run]]
  ==
::
++  bowl-bus
  |=  run=@ud
  ^-  bowl:gall
  :*  [~bus ~zod %nostrill ~]
      [~ ~ ~]
      [run `@uvJ`(shax run) (add (mul run ~s1) *time) [~zod %nostrill ud+run]]
  ==
::
++  state  $%(state-0:sur)
--
|%
::
++  scry-gate
  |=  =path
  ^-  (unit vase)
  ?+  path  ~
    [%j ship=@ %sein now=@ get=@ *]  
    `!>((slav %p get.i.t.t.t.t.path))
    [%e ship=@ %host now=@ *]
    `!>(`hart:eyre`[| ~ [%.y ~[%localhost]]])
  ==
::
++  ex-update
  |=  =fact:comms  
  %+  ex-fact:test-agent
    ~[/follow]
  noun+!>(fact)
::
++  ex-ui-update
  |=  =fact:ui:sur
  %+  ex-fact:test-agent
    ~[/ui]
  json+!>((fact:en:jsonlib fact))
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
  |=  [post-poke=?([%add ~] [%reply id=@da] [%quote id=@da] [%rp id=@da]) state=state-0:sur =bowl:gall]
  =/  profile  (~(get by profiles.state) [%urbit our.bowl])
  =/  pubkey  pub.i.keys.state
  ::  XX: for now host is our, can be changed if post we replying/quoting etc. is other @p
  =/  host  our.bowl
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
  :~  (ex-ui-update [%post %add [p (some pubkey) ~ ~ profile]])
      (ex-update [%post %add p])
  ==
::
++  test-poke-ui-post
  =|  run=@ud
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  caz=(list card)  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  post-id  now.bowl
  ;<  saved-1=vase  bind:m  get-save:test-agent
  =/  state-1  !<(state-0:sur saved-1)
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
    (ex-cards-post-poke [%add ~] state-1 bowl)
  :: poke reply to post 
  ;<  saved-2=vase  bind:m  get-save:test-agent
  =/  state-2  !<(state-0:sur saved-2)
  ;<  ~  bind:m  (wait:test-agent ~h1)  ::  preventing id duplication(post overwrite)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  reply-id  now.bowl
  =/  json-reply
    =,  enjs:format
    %-  pairs 
    :~  :-  'post'
        %+  frond  'reply'
        %-  pairs
        :~  ['content' s+'Reply']
            ['host' s+(scot %p our.bowl)]
            ['id' (ud:en:common post-id)]
            ['thread' (ud:en:common post-id)]
        ==
    ==
  ;<  caz-reply=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  json-reply
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-reply
    (ex-cards-post-poke [%reply post-id] state-2 bowl)
  ::  quote reply
  ;<  saved-3=vase  bind:m  get-save:test-agent
  =/  state-3  !<(state-0:sur saved-3)
  ;<  ~  bind:m  (wait:test-agent ~h1)  ::  preventing id duplication(post overwrite)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  quote-id  now.bowl
  :: 
  ;<  caz-quote=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  :-  'post'
        %+  frond  'quote'
        %-  pairs
        :~  ['content' s+'Quote']
            ['host' s+(scot %p our.bowl)]
            ['id' (ud:en:common reply-id)]
        ==
    ==
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-quote
    (ex-cards-post-poke [%quote reply-id] state-3 bowl)
  ::  repost quote post
  ;<  saved-4=vase  bind:m  get-save:test-agent
  =/  state-4  !<(state-0:sur saved-4)
  ;<  ~  bind:m  (wait:test-agent ~h1)  ::  preventing id duplication(post overwrite)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  caz-rp=(list card)  bind:m  
    %+  do-on-ui-poke  bowl  
    =,  enjs:format
    %-  pairs
    :~  :-  'post'
        %+  frond  'rp'
        %-  pairs
        :~  ['host' s+(scot %p our.bowl)]
            ['id' (ud:en:common quote-id)]
        ==
    ==
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-rp
    (ex-cards-post-poke [%rp quote-id] state-3 bowl)
  ;<  saved-fin=vase  bind:m  get-save:test-agent
  =/  state-fin  !<(state-0:sur saved-fin)
  =/  feed-size  (wyt:orm:tf feed:state-fin)
  ::;<  ~  bind:m
    (ex-equal:test-agent !>(feed-size) !>(4))
  ::
  ::  TODO: add case for reply from foreign ship, that is rejected by our ship
  ::  flow:  1. reply from src to our, feed.state post added 
  ::         2a. src ship isn't allowed to reply to our, send rejection
  ::         2b. reply allowed, send %ok fact
  ::         3a. src ship removes post from feed.state, with some ui card
  ::         3b.  if reply wasn't rejected should recieve %ok fact and send update to followers 
  ::
  ::;<  ~  bind:m  (set-src:test-agent ~bus)
  ::;<  caz-reply-2=(list card)  bind:m  
  ::  %+  do-on-ui-poke  bowl  json-reply
  ::;<  ~  bind:m
  ::  %+  ex-cards:test-agent  caz-reply-2
  ::  :~  (ex-ui-update [%post %add [p (some pubkey) ~ ~ profile]])
  ::  ::  poke card to src with likely engagement:comms data type 
  ::  ==
::
++  test-poke-ui-prof
  =|  run=@ud
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  caz=(list card)  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =/  post-id  now.bowl
  ;<  saved-1=vase  bind:m  get-save:test-agent
  =/  state-1  !<(state-0:sur saved-1)
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
  ;<  saved-2=vase  bind:m  get-save:test-agent
  =/  state-2  !<(state-0:sur saved-2)
  =/  ex-data
    :*  'zod'
        'about me'
        ''
        (malt ~[['location' s+'Urbit'] ['status' s+'testing']])
    == 
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add  
    ::  TODO: currently app/nostrill doesn't send any update to followers or UI on %prof poke
    :::~  (ex-update [%prof %add ex-data])
    ::    (ex-ui-update [%prof ex-data])
    ::==
    ~
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
    :::~  (ex-update [%prof %prof *user-meta:nostr])
    ::    (ex-ui-update [%prof *user-meta:nostr])
    ::==
    ~
  ;<  saved-3=vase  bind:m  get-save:test-agent
  =/  state-3  !<(state-0:sur saved-3)
  %+  ex-equal:test-agent
    !>((~(get by profiles.state-3) [%urbit our.bowl]))
    !>(~)
::
++  fol  ~bus
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
    :~  
      :-  'fols'
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
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state  !<(state-0:sur saved)
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
  ;<  caz-add-2=(list card)  bind:m  (do-fols-add-urbit bowl)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-add-2
    :~  (ex-follow-task [fol dap.bowl])
    ==
  ;<  caz-ng=(list card)  bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>([%init `res:comms`[%ng 'not allowed']])
  ::  In %nostrill agent leaving subscribtion on %ng fact isn't implemented yet. Test will crush 
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-ng
    :~((ex-leave-task fol))
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
  ;<  caz-ok=(list card)  bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>([%init `res:comms`[%ok [%feed fc `mock-profile]]])
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state  !<(state-0:sur saved)
  ;<  ~  bind:m  (ex-fols & &)
  ;<  ~  bind:m
    %+  ex-equal:test-agent
      !>((~(get by profiles.state) urbit+fol))
      !>(`mock-profile)
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-ok
    :~  (ex-ui-update [%fols %new urbit+fol fc `mock-profile])
    ==
  ::  update from subscribtion
  ::
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =+  mock-post=*post:post
  =.  id.mock-post  now.bowl
  =.  author.mock-post  ~bus
  ;<  caz-post=(list card)  bind:m
    %-  do-agent-follow
    :-  %fact
    noun+!>([%post [%add mock-post]])
  ;<  saved-4=vase  bind:m  get-save:test-agent
  =/  state-4  !<(state-0:sur saved-4)
  =/  bus-post  (has:orm:tf (~(got by following.state-4) urbit+fol) now.bowl)
  ;<  ~  bind:m
    %+  ex-equal:test-agent
      !>(bus-post)
      !>(&)
  ::  %kick from subscribtion, auto resubscribed
  ::
  ;<  ~  bind:m  (wait:test-agent ~h1)
  ;<  caz-kick=(list card)  bind:m
    (do-agent-follow [%kick ~])
  ;<  ~  bind:m
    %+  ex-cards:test-agent  caz-kick
    :~  (ex-follow-task [fol dap.bowl])
    ==
  ::  state unchanged
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
++  do-arvo-ws
  |=  msg=@t
  %+  do-arvo:test-agent 
    /ws/to-nostr-relay 
  :+  %khan  %arow 
  :-  %&  :-  %$
  !>('done')
::   !>  :+  %websocket-response  %message
::   %-  need 
::   (as-octs:mimes:html msg)
::
++  do-poke-ws-client
  |=  [=keys:nostr =bowl:gall sub-id=@t content=@t]
  =/  m  (mare:test-agent ,[(list card) event:nostr])
  ^-  form:m
  =/  e=event:nostr  
    %^  post-to-event:nostr-events  keys  eny.bowl
    %^  build-post:tp  ~2010.10.10  -.keys 
    (build-sp:tp our.bowl our.bowl content ~ ~)
  =/  data-octs=octs
    %-  json-to-octs:server
    %-  relay-msg:en:json-nostr 
    [%event sub-id e]
  ;<  caz=(list card)  bind:m
    %-  do-poke:test-agent
    websocket-client-message+!>([*@ud [1 `data-octs]])
  (pure:m [caz e])
::
++  test-poke-ui-fols-nostr-user
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  saved-1=vase  bind:m  get-save:test-agent
  =/  state-1  !<(state-0:sur saved-1)
  =/  fol-keys  (gen-keys:nostr-keys eny.bowl)
  =/  fol-pub  -:fol-keys
  =/  sub-id=@t  (gen-sub-id:nostr-keys eny.bowl)
  ::  send req to websockets to fol
  =/  filters  ~[[~ `(silt ~[fol-pub]) `(silt ~[1]) ~ ~ ~ ~]]
  =/  url  ~(tap by relays.state-1)
  =/  ex-ev=[@t websocket-event:eyre]
    :-   ?~  url  ''  -.i:url  
    :*  %message  1
    %-  some
    %-  json-to-octs:server
    %-  req:en:json-nostr
    [%req sub-id filters]
    ==
  ;<  caz-fol-nostr=(list card)  bind:m
    (do-fols-add-nostr bowl fol-pub)
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-fol-nostr
    :~  (ex-arvo:test-agent /ws/to-nostr-relay [%k %fard dap.bowl %ws noun+!>(ex-ev)])
    ==
  ::  check state if nostr user was added to follow 
  ;<  saved-2=vase  bind:m  get-save:test-agent
  =/  state-2  !<(state-0:sur saved-2)
  ~&  our.bowl
  ~&  nostr+(hex:de:common (hex:en:common fol-pub))
  ~&  follow-graph.state-2
  =/  has-fol  
    =/  follow  (~(get by follow-graph.state-2) urbit+our.bowl) 
    ?~  follow  %|
    (~(has in u.follow) nostr+(need (hex:de:common (hex:en:common fol-pub))))
  ;<  ~  bind:m  (ex-equal:test-agent !>(has-fol) !>(&))
  ::
  ::   get on-arvo 'done' from ws ted 
  ::  ;<  caz-on-arvo=(list card)  bind:m  (do-arvo-ws '')
  ::  got on-poke from iris with ws-msg 'EVENT', check in test if event been parsed and added to state
  ::
  ;<  [caz-poke-event=(list card) e=event:nostr]  bind:m  (do-poke-ws-client fol-keys bowl sub-id 'you got post')
  ;<  saved-3=vase  bind:m  get-save:test-agent
  =/  state-3  !<(state-0:sur saved-3)
  =/  relay-url  'wss://relay.damus.io'  :: temp
  =/  relay-state  (~(get by relays.state-3) relay-url)
  =/  created-at  (to-unix-secs:jikan:sr ~2010.10.10)
  =/  nostr-feed  (get:norm:sur nostr-feed.state-3 created-at)
  =/  ex-state
    :_  (put:norm:sur nostr-feed.state-2 created-at e)
    %+  %~  put  by  relays.state-2
      relay-url
    =/  stats  (~(got by relays.state-2) relay-url)
    =/  =event-stats:nostr  (~(got by reqs.stats) sub-id)
    =/  reqs  
      %+  ~(put by reqs.stats)  sub-id
      :-  filters.event-stats
          +(+.event-stats)
    [`now.bowl reqs]
  ::  check if event in state
  ~&  >>  state-match/=([relay-state nostr-feed] ex-state)
  ;<  ~  bind:m  (ex-equal:test-agent !>([relay-state nostr-feed]) !>(ex-state))
  %+  ex-cards:test-agent  caz-poke-event  ~

  ::  if response is successful we want to know we follow user to store parsed ws-messages in state
  ::  if response is auth msg we should handle auth and proceed from there
  ::  if response is notice or just eose without event prior our req to follow was declined, remove from state send ui update
::
++  test-beg-feed-ok
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m  (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  ;<  *  bind:m
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs
    :~  'post'^(frond 'add' (frond 'content' s+'Test post'))
    ==
  ::  ~bus subscribes to /beg/feed
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  caz=(list card)  bind:m
    (do-watch:test-agent /beg/feed)
  ::  Verify response cards
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state  !<(state-0:sur saved)
  =/  profile  (~(get by profiles.state) urbit+our.bowl)
  =/  lp  latest-page:feedlib
  =/  lp2  lp(count backlog.feed-perms.state)
  =/  =fc:tf  (lp2 feed.state)
  =/  jon  (beg-res:en:jsonlib [%ok %feed fc profile])
  %+  ex-cards:test-agent  caz
  :~  (ex-fact:test-agent ~[/beg/feed] json+!>(jon))
      (ex-card:test-agent %give %kick ~[/beg/feed] ~)
  ==
::
++  test-beg-feed-not-allowed
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m  (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m  (do-init:test-agent %nostrill agent)
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state-1  !<(state-0:sur saved)
  =/  lock-state  state-1(lock.feed-perms (lock-all:gate lock.feed-perms.state-1))
  ;<  *  bind:m  (do-load:test-agent agent `!>(lock-state))
  ;<  ~  bind:m  (set-src:test-agent ~bus)
  ;<  caz=(list card)  bind:m
    (do-watch:test-agent /beg/feed)
  =/  jon  (beg-res:en:jsonlib [%ng 'not allowed'])
  %+  ex-cards:test-agent  caz
  :~  (ex-fact:test-agent ~[/beg/feed] json+!>(jon))
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
  ;<  saved=vase  bind:m  get-save:test-agent
  =/  state-1  !<(state-0:sur saved)
  ::  on-watch beg thread missing id in path
  ::
  ::  TODO:  should we get kick card instead ? or it's so unlikely to happened that it's fine ?
  ::
  ;<  ~  bind:m    (set-src:test-agent ~bus)
  ;<  caz=(list card)  bind:m  (do-watch:test-agent /beg/thread/(scot %da now.bowl))
  ;<  ~  bind:m    (ex-cards:test-agent caz ~)
  ::  on-watch beg thread with non existant id 
  ::
  ;<  caz-ng-thread=(list card)  bind:m  
    (do-watch:test-agent /beg/thread/(crip (scow:sr %uw `@`~2010.1.1)))
  =/  jon-ng-thread  (beg-res:en:jsonlib [%ng 'no such thread'])
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
    %-  beg-res:en:jsonlib
    :*  %ok 
        %thread 
        (node-to-full:feedlib p.thread feed.state-1)
    ==
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-ok
    :~  (ex-fact:test-agent ~[/beg/thread/[thread-id]] json+!>(jon-ok))
      (ex-card:test-agent %give %kick ~[/beg/thread/[thread-id]] ~)
    ==
  =/  lock-state
    %=    state-1
        feed  
      %+  put:orm:tf  feed.state-1 
      %=  thread  
        ship.read.p  [~ & |]
      ==
    ==
  ::  on-watch beg thread with locked permissions
  ::
  ;<  *  bind:m  (do-load:test-agent agent `!>(lock-state))
  ;<  caz-ng-na=(list card)  bind:m  
    (do-watch:test-agent /beg/thread/[thread-id])
  =/  jon-ng-na  (beg-res:en:jsonlib [%ng 'not allowed'])
  %+  ex-cards:test-agent  caz-ng-na
    :~  (ex-fact:test-agent ~[/beg/thread/[thread-id]] json+!>(jon-ng-na))
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
  ;<  ~  bind:m    (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m    (do-init:test-agent %nostrill agent)
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
::  websocket-message on nostrill path
::  recieve event from client 
::  
::
++  test-ws-server-message-nostrill-event
  %-  eval-mare:test-agent
  =/  m  (mare:test-agent ,~)
  ^-  form:m
  ;<  ~  bind:m    (set-scry-gate:test-agent scry-gate)
  ;<  *  bind:m    (do-init:test-agent %nostrill agent)
  ;<  =bowl:gall  bind:m  get-bowl:test-agent
  =+  order=[wid=*@ path=*path *websocket-message:eyre]
  ::  case: message can't be parsed to JSON
  ::
  =.  path.order  /nostrill
  =.  message.order  `(as-octs:mimes:html '{data: 10)')
  ;<  caz-not-json=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  ;<  ~  bind:m  (ex-cards:test-agent caz-not-json ~)
  ::  case: unrecognised message from nostr
  ::
  =.  message.order  `(as-octs:mimes:html '["OK", "b1a649ebe8", true, ""]')
  ;<  caz-not-recognised-event=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  ;<  ~  bind:m  (ex-cards:test-agent caz-not-recognised-event ~)
  ::  case: handle %event client message
  ::
  =/  keys  (gen-keys:nostr-keys eny.bowl)
  =/  p=post:post
    %^  build-post:tp  now.bowl  -.keys
    (build-sp:tp our.bowl our.bowl 'Hello world' ~ ~)
  =/  =event:nostr
    (post-to-event:nostr-events keys eny.bowl p)
  =.  message.order  `(as-octs:mimes:html (en:json:html (req:en:json-nostr [%event event])))
  ;<  caz-json-event=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  =/  ex-msg-octs
    %-  json-to-octs:server 
    %-  relay-msg:en:json-nostr
    ::  currently implemented flow, indicates that we can't store recieved event 
    ::
    [%ok id.event | 'we\'re full']
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-json-event
    (ex-fact-ws-response -.order [%message 1 `ex-msg-octs])
  ::  case: following nostr user and recieving event mesage
  ::
  ;<  *  bind:m  
    %+  do-on-ui-poke  bowl
    =,  enjs:format
    %-  pairs  
    :~  
      :-  'fols'
      (frond 'add' (frond 'nostr' s+(crip (scow:sr %ux -.keys))))
    ==
  ;<  caz-json-event-2=(list card)  bind:m
    (do-poke:test-agent websocket-server-message+!>(order))
  ;<  ~  bind:m  
    %+  ex-cards:test-agent  caz-json-event-2
    (ex-fact-ws-response -.order [%message 1 `ex-msg-octs])
  ;<  saved-1=vase  bind:m  get-save:test-agent
  =/  state  !<(state-0:sur saved-1)
  =/  ex-feed  (put:orm:tf *feed:tf [id.p p])
  %+  ex-equal:test-agent
    !>((~(get by following.state) [%nostr -.keys]))
    !>(`ex-feed) 
::
::  there are few other cases that will come as client message, they aren't handled just yet 
::  ++ test-ws-server-message-req - stores subscription, with filters 
::  Upon receiving a REQ message, sending matching events back to the client
::  send eose to indicate that all relevant events has been sent
::  when new event arrives send to matching req subscription
::
::  ++ test-ws-server-message-auth -  verify auth, mark connection as valid(if valid), send OK response true/false depending on auth verification.
::
::  ++ test-ws-server-message-close - close subscriptions, remove from state
::
::  Recieved ok from ws on event id, send update to UI
::
:: ++  test-http-req-handle-ws-ok 
::   if OK message is true event at id suceeded
::   if FALSE rejected send error message to UI
::  ++ test-http-req-handle-ws-event - got event on subscription, handle it depending on event kind 
  ::  0 - user metadata 
  ::  check if following, if following store in state 
  ::  send to UI 
  ::  1 - text post
  ::  check if following, if following store in follows.state 
  ::  temporary store in state
  ::  
  ::  2 - relay recomendations(?)
  ::  3 - following/preference list 
  ::  Send update to UI 
  ::  5 - req to delete event
  ::  If following delete from state 
  ::  Send update to UI
  ::  6 - repost event
  ::  If following store in state
  ::  Send update to UI
  ::  7 - reaction event
  ::  Send update to UI(?)
::  ++ test-http-req-handle-ws-eose - recieved all existing events on sub-id from relay 
::  send full event log from temp state to UI
::  there are notes on handling close after event if needed 
::  ++ test-http-req-handle-ws-closed - subscription ended, removing from relay.state
::  ++ test-http-req-handle-ws-auth - respond with signed auth event to relay
::  ++ test-http-req-handle-ws-notice - error message or notification 
::  ++ test-http-req-handle-ws-error - ??
--