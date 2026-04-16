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
  $%  [%add content=@t global=? anon=?]
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
      ::  add or remove relays
  $%  [%add p=@t]  
      [%del p=@ud]
      ::  data to send/receive from relays
      [%do relay-handling]
  ==
+$  relay-handling
  $:  relays=(list @ud)  ::  list of wids
      action=relay-order
  ==
+$  relay-order
    $%  relay-get
        [%send-post host=@p id=@da]
        [%send-prof ~]
    ==
+$  relay-get
  $%  [%sync ~]
      [%prof ~]
      [%user pubkey=@ux]
      [%thread id=@ux]
  ==
:: facts
+$  fact
  $%  [%nostr nostr-fact]
      [%post post-fact:comms]
      [%fols fols-fact]
      [%prof (map user:sur user-profile:comms)]
      :: our own keys!
      [%keys pub=@ux]
  ==
+$  fols-fact
  $%  [%new-urbit (enbowl fols-res:comms)]
      [%new-nostr pubkey=@ux profile=(unit user-profile:comms) relays=(list @t)]
      ::  UI feedback that the backend handled the click
      [%quit =user:sur]
  ==
+$  nostr-fact
  $%  [%feed feed=nostr-feed:sur]
      [%user feed=nostr-feed:sur]    ::  a user feed we requested
      [%thread feed=nostr-feed:sur]  ::  a specific thread we requested
      [%event event:nsur]            ::  some specific event
      [%eose sub-id=@t]              ::  end of data or backlog
      [%relays (map @ relay-stats:nsur)]
      [%sent-post host=@p id=@ relays=(list @t) event:nsur]  ::  confirmation that a post of ours was sent to a relay
      [%sent-prof relays=(list @t)]
  ==
+$  ted
    $%  [%req tid=@t relays=(list @ud) p=relay-get]
        [%res sub-id=@t]
    ==
--
