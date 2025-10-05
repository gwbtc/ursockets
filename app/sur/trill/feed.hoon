/-  post=trill-post
|%
+$  feeds       (map ship feed)
+$  feed        ((mop id:post post:post) gth)
+$  index       (map @t (set pid:post))
++  orm         ((on id:post post:post) gth)
+$  full-graph  ((mop id:post full-node:post) gth)
++  form        ((on id:post full-node:post) gth)
+$  global      ((mop pid:post post:post) ggth)
++  ggth        |=([[ship a=time] [ship b=time]] (gth a b))
++  gorm        ((on pid:post post:post) ggth)

+$  cursor    (unit @da)
+$  fc  [=feed:feed start=cursor end=cursor]
+$  gc  [mix=global:feed start=cursor end=cursor]
--
