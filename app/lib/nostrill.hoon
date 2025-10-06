/-  post=trill-post, nsur=nostr, sur=nostrill, gate=trill-gate, comms=nostrill-comms
/+  trill=trill-post, nostr-keys, sr=sortug, jsonlib=json-nostrill,
    ws=websockets
|%
::
++  default-state  |=  =bowl:gall  ^-  state:sur
  =/  s  *state-0:sur
  =/  l  public-relays:nsur
  :: =/  l  (scag 1 l)
  :: =/  l  ~['wss://relay.damus.io' 'wss://nos.lol']
  =/  rl  %+  turn  l  |=  t=@t  [t *relay-stats:nsur]
  :: =/  l  ~[['wss://relay.damus.io' ~]]
  =/  key  (gen-keys:nostr-keys eny.bowl)
  =/  keyl  [key ~]
  s(relays (malt rl), keys keyl) 

++  print-relay-stats
  |=  rm=(map @t relay-stats:nsur)
  =/  l  ~(tap by rm)
  |-  ?~  l  ~
    =/  [url=@t rs=relay-stats:nsur]  i.l
    ~&  relay=url
    ~&  connected=connected.rs
    ~&  sub-count=~(wyt by reqs.rs)
    =/  total-received
      %+  roll  ~(tap by reqs.rs)
        |=  [[* es=event-stats:nsur] acc=@ud]
          %+  add  acc  received.es
    ~&  >>  total=total-received  
    $(l t.l)
  
++  ui-ws-res  |=  [wid=@ msg=@t]
  
  =/  resmsg  (cat 3 msg (cat 3 msg msg))
  =/  octs  (as-octs:mimes:html resmsg)
  =/  res-event=websocket-event:eyre  [%message 1 `octs]
  (give-ws-payload:ws wid res-event)
::

++  cards
|_  =bowl:gall
  ++  shim-binding  ^-  card:agent:gall
    [%pass /binding %arvo %e %connect [~ /nostr-shim] dap.bowl]

  ++  relay-binding  ^-  card:agent:gall
    [%pass /binding %arvo %e %connect [~ /nostrill] dap.bowl]
  ++  ui-binding  ^-  card:agent:gall
    [%pass /binding %arvo %e %connect [~ /nostrill-ui] dap.bowl]
  ++  bindings
    :~  shim-binding
        relay-binding
        ui-binding
    ==
  ++  update-ui  |=  =fact:ui:sur  ^-  card:agent:gall
    =/  jon  (fact:en:jsonlib fact)
    [%give %fact ~[/ui] %json !>(jon)]
  :: ++  update-followers  |=  =fact:comms  ^-  card:agent:gall
  ++  update-followers  |=  =fact:comms  ^-  card:agent:gall
    [%give %fact ~[/follow] %noun !>(fact)]
  --
--
