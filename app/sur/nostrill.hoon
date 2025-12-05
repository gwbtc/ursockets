/-  nostr, tf=trill-feed, tp=trill-post, gate=trill-gate
|%
+$  state  state-0
+$  state-0
  $:  %0
      :: nostr config
      relays=(map @ud relay-stats:nostr)  ::  key is the websocket id
      :: ws-msg-queue=(list websocket-event:eyre)
      keys=(lest keys:nostr)  :: cycled, i.keys is current one
      ::  own feed
      =feed:tf
      feed-perms=gate:gate
      ::  nostr feed from relays
      :: TODO deprecate and parse properly into a feed:trill
      =nostr-feed
      ::  profiles
      profiles=(map user user-meta:nostr)
      following=(map user =feed:tf)
      following2=global-feed
      =global-feed
      follow-graph=(map user (set user))
    :: TODO global feed somehow?
    :: TODO use %hark agent instead?
      =requests
      =responses

  ==
+$  global-feed  ((mop upid post:tp) ugth)
++  uorm         ((on upid post:tp) ugth)
+$  upid        [=user id=@da]
++  ugth        |=  [a=[[* id=@] =time] b=[[* id=@] =time]]  ?:  .=(time.a time.b)  (gth id.a id.b)  (gth time.a time.b)
+$  nostr-feed  ((mop @ud event:nostr) gth)
++  norm        ((on @ud event:nostr) gth)
+$  nfc         [feed=nostr-feed start=cursor:tf end=cursor:tf]

+$  post-wrapper  [=post:tp nostr-meta=nostr-meta]
+$  nostr-meta
$:  pub=(unit @ux)
    ev-id=(unit @ux)
    relay=(unit @t)
    pr=(unit user-meta:nostr)
==
+$  user  $%([%urbit p=@p] [%nostr p=@ux])

+$  follow  [pubkey=@ux name=@t relay=(unit @t)]



+$  requests    ((mop @da req) gth)
+$  responses   ((mop @da ruling) gth)
++  orq         ((on @da req) gth)
++  ors         ((on @da ruling) gth)

++  enbowl
  |$  t
  $:  =user
      ts=@da
      p=t
  ==
++  approval
  |$  t
  $^  [%ok p=t]
       %ng

::  Requests that a user can perhaps reject
::  %beg are one-off data requests
::  %fans is a follow, an ames subscription
+$  req
  $:  msg=@t
  $=  req
  $^  [%beg p=beg-type]
      %fans
  ==
+$  beg-type
  $^  [%thread @da]
      %feed
  :: $?  %feed
  ::     %prof
+$  ruling  ::  my responses to received requests
  $:  req=(enbowl req)
      =gate:gate
      =decision
  ==
+$  decision  [time=@da approved=? manual=? msg=@t]
--
