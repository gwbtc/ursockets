/-  nostr, trill=trill-feed, tp=trill-post, gate=trill-gate
|%
+$  state  state-0
+$  state-0
  $:  %0
      :: nostr config
      relays=(map @ud relay-stats:nostr)  ::  key is the websocket id
      :: ws-msg-queue=(list websocket-event:eyre)
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
      following2=feed:trill
      follow-graph=(map user (set user))
    :: TODO global feed somehow?
    :: TODO use %hark agent instead?
      :: notifications=((mop @da notif) gth)

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
+$  notif
  $%  [%prof =user prof=user-meta:nostr]      :: profile change
      [%fols =user accepted=? msg=@t]             :: follow response 
      [%beg beg=begs-poke:ui accepted=? msg=@t]   :: feed/post data request response
      [%fans p=user]                       :: someone folowed me
      [%post =pid:tp =user action=post-notif]               :: someone replied, reacted etc.
  ==
+$  post-notif
$%   [%reply p=post:tp]
     [%quote p=post:tp]
     [%reaction reaction=@t]
     :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
     [%rp ~]  :: NIP-18
     [%del ~]
==
++  ui
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
      [%reply content=@t host=@p id=@da thread=@da]
      [%quote content=@t host=@p id=@da]
      [%rp host=@p id=@da]  :: NIP-18
      [%reaction host=@p id=@da reaction=@t]
      :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
      [%del host=@p id=@da]
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
      [%del p=@ud]
      ::
      relay-handling
  ==
  +$  relay-handling
  $%  [%sync ~]
      [%user pubkey=@ux]
      [%thread id=@ux]
      ::  send event for... relaying
      [%send host=@p id=@ relays=(list @t)]
  ==
  :: facts
  +$  fact
  $%  [%nostr nostr-fact]
      [%post post-fact]
      [%enga p=post-wrapper reaction=*]
      [%fols fols-fact]
      [%hark =notif]
  ==
  +$  nostr-fact
  $%  [%feed feed=nostr-feed]
      [%user feed=nostr-feed]
      [%thread feed=nostr-feed]
      [%event event:nostr]
      [%relays (map @ relay-stats:nostr)]
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
