|%
+$  keys  [pub=@ priv=@]
+$  event
$:  id=@ux           :: 32bytes
    pubkey=@ux       ::  32bytes
    created-at=@ud   :: seconds
    kind=@ud
    tags=(list tag)
    content=@t
    sig=@ux          ::  64bytes
==
+$  raw-event
$:  pubkey=@ux       ::  32bytes
    created-at=@ud   :: seconds
    kind=@ud
    tags=(list tag)
    content=@t
==
+$  tag  (list @t)
:: $:  key=@t
::     value=@t
::     rest=(list @t)
:: ==
+$  user-meta  :: NIP-1
$:  name=@t
    about=@t
    picture=@t
    other=(map @t json)
==
+$  relay-stats
$:  start=@da
    url=@t
    reqs=(map sub-id event-stats)
==
+$  event-stats
  ::  if not ongoing we kill the subscription on %eose
  ::  if chunked we trigger a new subscription on %eose
  [filters=(list filter) received=event-count ongoing=? chunked=(list filter)]
+$  sub-id  @t
+$  event-count  @ud

+$  relay-req
$:  sub-id=@t
    filters=(list filter)
==
::  Relay comms
+$  filter
$:  ids=(unit (set @ux))
    authors=(unit (set @ux))
    kinds=(unit (set @ud))
    tags=(unit (map @t (set @t)))
    since=(unit @da)
    until=(unit @da)
    limit=(unit @ud)
==
:: messages from relay
++  relay-msg
$%  [%event sub-id=@t =event]
    [%ok id=@ux accepted=? msg=@t]
    [%eose sub-id=@t]
    [%closed sub-id=@t msg=@t]
    [%notice msg=@t]
    [%auth challenge=@t]
==
+$  client-msg
$%  [%req relay-req]
    [%event =event]
    [%auth =event]
    [%close sub-id=@t]
==
:: https://github.com/sesseor/nostr-relays-list/blob/main/relays.txt
++  public-relays  ^-  (list @t)
  :~
      'wss://n.urbit.cloud'
      'wss://nos.lol'
      'wss://relay.damus.io'
      'wss://nostr.wine'
      'wss://offchain.pub'
  ==
      :: 'wss://knostr.neutrine.com'
--
:: event: {
::     content: "😂",
::     created_at: 1758049319,
::     id: "36c8a0bb6a9a1ff3ca3e6868fdf2c055a09aea39b1c078b75c38f5a7b580da87",
::     kind: 7,
::     pubkey: "26d6a946675e603f8de4bf6f9cef442037b70c7eee170ff06ed7673fc34c98f1",
::     sig: "7b5a9c799776935f959eccfd311af6152db6a1360296c9790b35544d0b83a8d75f8937ad1ad6f5da3e0d3e2bdb1bfb92686adbde42c3ef53ca06771080d08153",
::     tags: [
::       [ "e", "091d00811bb9a57088ab7c1d39697b0ed9bbbe05dae135b406f3560290fba311",
::         "wss://relay.nostr.band/", "root", "26d6a946675e603f8de4bf6f9cef442037b70c7eee170ff06ed7673fc34c98f1"
::       ], [ "e", "1cd926b58a1bac70adcedf38212d72ee1380e17dad1aef6bbc18782c5c540236",
::         "wss://relay.nostr.band/", "reply", "3252715543f6e43be086465129b030d47d76cf8cead4798e48864563c3375083"
::       ], [ "p", "26d6a946675e603f8de4bf6f9cef442037b70c7eee170ff06ed7673fc34c98f1",
::         "wss://nostr.bitcoiner.social/"
::       ], [ "p", "3252715543f6e43be086465129b030d47d76cf8cead4798e48864563c3375083",
::         "ws://relay.snort.social/"
::       ], [ "e", "b9a0c3b28a291d80bcb41ee730f2c48366fd2fefba0e68f9fb928bb9ca96f757" ], [ "p", "3252715543f6e43be086465129b030d47d76cf8cead4798e48864563c3375083" ]
::     ],
::   },
