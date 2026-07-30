/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, ui=nostrill-ui,
    post=trill-post, gate=trill-gate
/+  trill=trill-post, nostr-keys, jael=nostr-jael, sr=sortug,
    jsonlib=json-nostrill,
    constants,
    ws=websockets
|%
::
++  default-state  |=  =bowl:gall  ^-  state:sur
  =/  s  *state:sur
  :: =/  l  ~['wss://relay.damus.io' 'wss://nos.lol']
  ::  the Nostr key is now DERIVED from our Groundwire/Jael identity (deterministic,
  ::  survives reinstall, bound to our @p) rather than random `eny`.
  =/  key  (derive-keys:jael bowl)
  =/  keyl  [key ~]
  s(keys keyl)

++  print-relay-stats
  |=  rm=(map @ relay-stats:nsur)
  =/  l  ~(tap by rm)
  |-  ?~  l  ~
    =/  [wid=@ rs=relay-stats:nsur]  i.l
    ~&  relay-url=url.rs
    ~&  connected=start.rs
    ~&  sub-count=~(wyt by reqs.rs)
    =/  total-received
      %+  roll  ~(tap by reqs.rs)
        |=  [[* rs=req-state:nsur] acc=@ud]
          %+  add  acc  received.rs
    ~&  >>  total=total-received  
    $(l t.l)
  
++  ui-ws-res  |=  [wid=@ msg=@t]
  
  =/  octs  (as-octs:mimes:html msg)
  =/  res-event=websocket-event:eyre  [%message 1 `octs]
  :~  (give-ws-payload-server:ws wid res-event)
  ==

++  user-to-path  |=  u=user:sur  ^-  path
  ?-  -.u
    %urbit  /urbit/(scot %p +.u)
    %nostr  /nostr/(crip (scow:sr %ux +.u))
  ==
++  user-to-atom  |=  u=user:sur  ^-  @
  ?-  -.u
    %urbit  +.u
    %nostr  +.u
  ==
++  cord-to-user  |=  c=@t  ^-  (unit user:sur)
    =/  upk  (slaw:sr %ux c)
    ?~  upk 
      ::  not hex
      =/  up  (slaw %p c)
      ::  not @p either
      ?~  up  ~
      ::  yes @p, not hex
      `[%urbit u.up]
      ::  yes hex
    ?.  (validate-pubkey:nostr-keys u.upk)  ~
    `[%nostr u.upk]


++  atom-to-user  |=  p=@  ^-  u=user:sur
  ?:  (validate-pubkey:nostr-keys p)
    [%nostr p]  
    [%urbit p]
::

++  cards
|_  =bowl:gall
  ++  init  ^-  (list card:agent:gall)
    :: :-  global-relay-card
        bindings
  ++  global-relay-card  ^-  card:agent:gall
    (connect:ws global-relay:constants bowl)

  ++  relay-binding  ^-  card:agent:gall
    [%pass /binding %arvo %e %connect [~ /nostrill] dap.bowl]
  ++  ui-binding  ^-  card:agent:gall
    [%pass /binding %arvo %e %connect [~ /nostrill-ui] dap.bowl]
  ++  bindings
    :~  relay-binding
        ui-binding
    ==
  ++  update-ui  |=  =fact:ui  ^-  card:agent:gall
    =/  jon  (fact:en:jsonlib fact)
    [%give %fact ~[/ui] %json !>(jon)]
  :: ++  update-followers  |=  =fact:comms  ^-  card:agent:gall
  ++  update-followers  |=  =fact:comms  ^-  card:agent:gall
    [%give %fact ~[/follow] %noun !>(fact)]
  ::
  ++  poke-host  |=  [sip=@p =poke:comms]  ^-  card:agent:gall
    [%pass /heads-up %agent [sip dap.bowl] %poke %noun !>(poke)]

  ++  poke-thread  |=  [tid=@ta body=*]  ^-  card:agent:gall
    =/  ta-now  (scot %ud `@`now.bowl)
    [%pass /ted-res/[ta-now] %agent [our.bowl %spider] %poke %spider-input !>([tid %noun !>(body)])]

  ++  poke-ui-thread  |=  [tid=@ta sub-id=@t]  ^-  card:agent:gall
    ~&  >>>  poke-ui-ted=tid
    =/  ta-now  (scot %ud `@`now.bowl)
    =/  payload=ted:ui  [%res sub-id]
    [%pass /ted-res/[ta-now] %agent [our.bowl %spider] %poke %spider-input !>([tid %nostrill-ted !>(payload)])]
  --
--
