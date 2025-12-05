/-  sur=nostrill, nsur=nostr, feed=trill-feed, post=trill-post
|%
::  Pokes are used to notify users of engagement. There is no data requests through pokes
+$  poke
  $%  [%eng engagement]
      [%dbug *]
  ==
+$  engagement
  $%  [%reply parent=@da child=post:post]
      [%mention =post:post]
      [%quote src=@da =post:post]
      [%del-quote src=@da quote=@da]
      [%del-reply parent=@da child=@da]
      [%del-parent parent=@da child=@da]
      [%rp src=@da target=@da]
      [%reaction post=@da reaction=@t]
  ==
::  Data requests is done through subscriptions
+$  res
  $:  req-msg=@t
      p=res-type
  ==
+$  res-type
$%  [%begs beg-res]
    [%fols fols-res]
==
+$  beg-res
  $:  msg=@t
  $=  p
  $%  [%feed p=(approval:sur feed-data)]
      [%thread id=@da p=(approval:sur thread-data)]
  ==
  ==

+$  thread-data
  $:  node=full-node:post
      thread=(list full-node:post)  ::  list of all the users consecutive posts, as in long form thread
  ==

+$  feed-data  [=fc:feed profile=(unit user-meta:nsur)]
::  Only follow results are given as proper facts to be handled in the backend
::  Begs are requested by threads, and passed directly as json to be sent to the frontend
+$  fols-res  [msg=@t p=(approval:sur feed-data)]

::  Sent to followers when we update stuff
+$  fact
  $%  [%prof prof-fact]
      [%post post-fact]
  ==

+$  post-fact
$%  [%add post-wrapper:sur]
    [%del post-wrapper:sur]
    [%changes post-wrapper:sur]
==
:: +$  fols-fact
:: $%  [%new =user:sur =fc:tf meta=(unit user-meta:nostr)]
::     [%quit =user:sur]
:: ==
+$  prof-fact  user-meta:nsur


--
