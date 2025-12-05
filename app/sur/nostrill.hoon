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
      ::  TODO where do we get profs?
  $%  [%prof =user prof=user-meta:nostr]              :: profile change
      [%fans =user msg=@t]                            :: someone folowed me
      [%fols =user accepted=? msg=@t]                 :: follow response 
      [%beg-req =user beg=begs-poke:ui msg=@t]        :: feed/post data request request
      [%beg-res beg=begs-poke:ui accepted=? msg=@t]   :: feed/post data request response
      [%post =pid:tp =user action=post-notif]         :: someone replied, reacted etc.
  ==
+$  post-notif
$%   [%reply p=post:tp]
     [%quote p=post:tp]
     [%reaction reaction=@t]
     :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
     [%rp ~]  :: NIP-18
     [%del ~]
==
--
