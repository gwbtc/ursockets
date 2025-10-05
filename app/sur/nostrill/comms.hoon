/-  sur=nostrill, nsur=nostr, feed=trill-feed, post=trill-post
|%
+$  poke
  $%  [%req req]
      [%res res]
      [%dbug *]
  ==
+$  emgagement
  $%  [%reply host=@p id=@da]
      [%del-reply host=@p id=@da]
      [%reaction host=@p id=@da reaction=@t]
  ==
+$  req
  $%  [%feed ~]
      [%thread id=@da]
  ==
+$  res
  $%  [%ok p=res-data]
      [%ng msg=@t]
  ==
+$  res-data
  $%  [%feed =fc:feed profile=(unit user-meta:nsur)]
      [%thread p=full-node:post]
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
