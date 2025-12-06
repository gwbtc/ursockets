/-  *wrap, nostr, comms=nostrill-comms,
    trill=trill-feed, tp=trill-post, gate=trill-gate
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
      following2=global-feed
      =global-feed
      follow-graph=(map user (set user))
      ::  Save incoming requests to handle async
      =requests
      ::  Save our given responses
      =responses
  ==

+$  global-feed  ((mop upid post:tp) ugth)
++  uorm         ((on upid post:tp) ugth)
::
+$  upid  [=user id=@da]
++  ugth        |=  [a=[[* id=@] =time] b=[[* id=@] =time]]  ?:  .=(time.a time.b)  (gth id.a id.b)  (gth time.a time.b)

+$  nostr-feed  ((mop @ud event:nostr) gth)
++  norm        ((on @ud event:nostr) gth)
+$  nfc         [feed=nostr-feed start=cursor:trill end=cursor:trill]
+$  user  $%([%urbit p=@p] [%nostr p=@ux])

+$  follow  [pubkey=@ux name=@t relay=(unit @t)]
::  request handling
:: 
::  TODO  save responses to requests?
::  we need to pass request timestamp to responses too
+$  requests    ((mop @da req:comms) gth)
+$  responses   ((mop @da ruling) gth)
++  orq         ((on @da req:comms) gth)
++  ors         ((on @da ruling) gth)
+$  ruling  ::  my responses to received requests
  $:  req=(enbowl req:comms)
      =gate:gate
      =decision
  ==
+$  decision  [time=@da approved=? manual=? msg=@t]
--
