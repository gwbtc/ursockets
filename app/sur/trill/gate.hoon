|%
+$  gate
$:  =lock
    begs=(set @p)          :: follow requests
    post-begs=(set post-beg)   :: read requests for specific posts
    :: TODO include whole thread?
    mute=lock      :: mute list to prevent request spamming
    backlog=$~(50 @)       :: size of backlog sent to followers by default
==
+$  post-beg  [=ship id=@da]

+$  lock
$:  rank=[caveats=(set rank:title) locked=_| public=?]
    luk=[caveats=(set ship) locked=_| public=?]
    ship=[caveats=(set ship) locked=_| public=?]
    tags=[caveats=(set @t) locked=_| public=?]
    custom=[fn=(unit $-(@p ?)) public=?]
==
+$  change
$%  [%set-rank set=(set rank:title) locked=? public=?] 
    [%set-luk set=(set ship) locked=? public=?] 
    [%set-ship set=(set ship) locked=? public=?] 
    [%set-tags set=(set @t) locked=? public=?] 
    [%set-custom term] :: Handle this and set in hoon
==
--
