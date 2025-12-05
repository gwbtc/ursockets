/-  *wrap, sur=nostrill, nsur=nostr, comms=nostrill-comms
|%
+$  poke
  $%  [%fols fols-poke]
      [%begs begs-poke]
      [%post post-poke]
      [%prof prof-poke]
      [%keys ~]  ::  cycle-keys
      [%rela relay-poke]
      :: [%notif @da]  :: dismiss notification
  ==
+$  begs-poke
  $%  [%feed p=@p]
      [%thread p=@p id=@da]
  ==
+$  post-poke
  $%  [%add content=@t]
      [%reply content=@t host=user:sur id=@da thread=@da]
      [%quote content=@t host=user:sur id=@da]
      [%rp host=user:sur id=@da]  :: NIP-18
      [%reaction host=user:sur id=@da reaction=@t]
      :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
      [%del host=user:sur id=@da]
  ==
+$  fols-poke
  $%  [%add =user:sur]
      [%del =user:sur]
  ==
+$  prof-poke
  $%  [%add meta=user-meta:nsur]
      [%del ~]
      [%fetch p=(list user:sur)]
  ==
+$  relay-poke
  $%  [%add p=@t]
      [%del p=@ud]
      ::
      relay-handling
  ==
+$  relay-handling
  $%  [%sync ~]
      [%prof ~]
      [%user pubkey=@ux]
      [%thread id=@ux]
      ::  send event for... relaying
      [%send host=@p id=@ relays=(list @t)]
  ==
:: facts
+$  fact
  $%  [%nostr nostr-fact]
      [%post post-fact:comms]
      [%fols fols-fact]
      [%prof (map user:sur user-meta:nsur)]
      :: our own keys!
      [%keys pub=@ux]
  ==
+$  fols-fact
  $%  [%new (enbowl fols-res:comms)]
      ::  UI feedback that the backend handled the click
      [%quit =user:sur]
  ==
+$  nostr-fact
  $%  [%feed feed=nostr-feed:sur]
      [%user feed=nostr-feed:sur]
      [%thread feed=nostr-feed:sur]
      [%event event:nsur]
      [%relays (map @ relay-stats:nsur)]
  ==
--
