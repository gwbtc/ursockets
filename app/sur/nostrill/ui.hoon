/-  *nostrill, nsur=nostr, feed=trill-feed, post=trill-post, comms=nostrill-comms
|%
  +$  poke
  $%  [%fols fols-poke]
      [%begs begs-poke]
      [%post post-poke]
      [%prof prof-poke]
      [%keys ~]  ::  cycle-keys
      [%rela relay-poke]
      [%reqs reqs-poke]
  ==
  +$  begs-poke
  $%  [%feed p=@p]
      [%thread p=@p id=@da]
  ==
  +$  post-poke
  $%  [%add content=@t]
      [%reply content=@t host=user id=@da thread=@da]
      [%quote content=@t host=user id=@da]
      [%rp host=user id=@da]  :: NIP-18
      [%reaction host=user id=@da reaction=@t]
      :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
      [%del host=user id=@da]
      ::
      [%perms =pid:tp =perms:tp]
  ==
  +$  fols-poke
  $%  [%add =user]
      [%del =user]
  ==
  +$  prof-poke
  $%  [%add meta=user-meta:nostr]
      [%del ~]
      [%fetch p=(list user)]
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
  +$  reqs-poke
  $%  [%handle id=@da approve=? msg=@t]
      [%del id=@da]
  ==
  :: facts
  +$  fact
  $%  [%nostr nostr-fact]
      [%prof (map user user-meta:nsur)]
      [%post post-fact:comms]
      [%fols (enbowl fols-res:comms)]
      [%keys pub=@ux]
  ==
  +$  nostr-fact
  $%  [%feed feed=nostr-feed]
      [%user feed=nostr-feed]
      [%thread feed=nostr-feed]
      [%event event:nostr]
      [%relays (map @ relay-stats:nostr)]
  ==
--
