/-  nostr, trill=trill-feed, tp=trill-post, gate=trill-gate
|%
+$  state  state-0
+$  state-0
  $:  %0
      :: nostr config
      relays=(map @t relay-stats:nostr)
      keys=(lest keys:nostr)  :: cycled, i.keys is current one
      ::  own feed
      feed=feed:trill
      feed-perms=gate:gate
      ::  nostr feed from relays
      :: TODO deprecate and parse properly into a feed:trill
      =nostr-feed
      ::  profiles
      profiles=(map user user-meta:nostr)
      following=(map user =feed:trill)
      follow-graph=(map user (set user))
    :: TODO global feed somehow?

  ==
+$  nostr-feed  ((mop @ud event:nostr) gth)
++  norm        ((on @ud event:nostr) gth)
+$  nfc         [feed=nostr-feed start=cursor:trill end=cursor:trill]

+$  post-wrapper  [=post:tp nostr-meta=nostr-meta]
+$  nostr-meta
$:  pub=(unit @ux)
    ev-id=(unit @ux)
    relay=(unit @t)
    pr=(unit user-meta:nostr)
==
+$  user  $%([%urbit p=@p] [%nostr p=@ux])

+$  follow  [pubkey=@ux name=@t relay=(unit @t)]
++  ui
  |%
  +$  poke
  $%  [%fols fols-poke]
      [%begs begs-poke]
      [%post post-poke]
      :: [%reac reac-poke]
      [%prof prof-poke]
      [%keys ~]  ::  cycle-keys
      [%rela relay-poke]
  ==
  +$  begs-poke
  $%  [%feed p=@p]
      [%thread p=@p id=@da]
  ==
  +$  post-poke
  $%  [%add content=@t]
      [%reply content=@t host=@p id=@ thread=@]
      [%quote content=@t host=@p id=@]
      [%rp host=@p id=@]  :: NIP-18
      :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
      :: [%del pubkey=@ux]
  ==
  +$  fols-poke
  $%  [%add =user]
      [%del =user]
  ==
  +$  prof-poke
  $%  [%add meta=user-meta:nostr]
      [%del ~]
  ==
  +$  relay-poke
  $%  [%add p=@t]
      [%del p=@t]
      ::
      [%sync ~]
      ::  send event for... relaying
      [%send host=@p id=@ relays=(list @t)]
  ==
  :: facts
  +$  fact
  $%  [%nostr feed=nostr-feed]
      [%post post-fact]
      [%enga p=post-wrapper reaction=*]
      [%fols fols-fact]
  ==
  +$  post-fact
  $%  [%add post-wrapper]
      [%del post-wrapper]
  ==
  +$  fols-fact
  $%  [%new =user =fc:trill meta=(unit user-meta:nostr)]
      [%quit =user]
  ==
  --
--
