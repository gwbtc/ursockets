/-  sur=nostrill, nsur=nostr, feed=trill-feed, post=trill-post
|%
::  TODO have requests and responses carry messages
+$  poke
  $%  [%req req]
      [%res res]
      [%eng engagement]
      [%dbug *]
  ==
+$  engagement
  $%  [%reply parent=@da child=post:post]
      [%del-reply parent=@da child=@da]
      [%del-parent parent=@da child=@da]
      [%quote src=@da =post:post]
      [%del-quote src=@da quote=@da]
      [%rp src=@da rt=@da]
      [%reaction post=@da reaction=@t]
  ==
+$  req
  $%  [%feed msg=@t]
      [%thread id=@da msg=@t]
  ==
+$  res
  $%  [%ok p=res-data msg=@t]
      [%ng =req msg=@t]
  ==
+$  res-data
  $%  [%feed =fc:feed profile=(unit user-meta:nsur)]
      [%thread p=full-node:post q=(list full-node:post)]
  ==
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
