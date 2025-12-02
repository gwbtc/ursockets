/-  sur=nostrill, nsur=nostr, feed=trill-feed, post=trill-post
|%
::  TODO have requests and responses carry messages
+$  poke
  $%  [%req =req:sur]
      [%res res]
      [%eng engagement]
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
+$  res
  $:  msg=@t
      res=res-type
  ==
+$  res-type
  $%  [%begs beg-type]
      [%fols (approval:sur feed-data)]
  ==
+$  beg-type
  $%  [%feed (approval:sur feed-data)]
      [%thread id=@da (approval:sur thread-data)]
  ==

+$  thread-data
  $:  node=full-node:post
      thread=(list full-node:post)  ::  list of all the users consecutive posts, as in long form thread
  ==
+$  feed-data  [=fc:feed profile=(unit user-meta:nsur)]
:: TODO there's some overlap between what we send to the UI and we send to our followers
:: but it's not exactly the same
+$  fact
  $%  [%post post-fact]
      [%prof prof-fact]
      [%init res]
  ==
+$  post-fact
  $%  [%add p=post:post]
      [%del id=@da]
      [%changes p=post:post]
  ==
+$  prof-fact
  $%  [%prof =user-meta:nsur]
      [%keys pub=@ux]
  ==
--
