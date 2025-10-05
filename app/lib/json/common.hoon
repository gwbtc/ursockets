/+  sr=sortug
|%
++  en
=,  enjs:format
  |%
  ++  cord  |=  s=@t   ^-  json  s+s
  ++  hex   |=  h=@ux  ^-  json
    =/  scoww  scow:sr
    [%s (crip (scoww(min-chars 64) %ux h))]
  ++  b64   |=  h=@uv  ^-  json  
    [%s (crip (scow:sr %uv h))]
  ++  ud    |=  n=@  ^-  json  
    [%s (crip (scow:sr %ud n))]
  ++  patp  |=  p=@p  ^-  json
    [%s (scot %p p)]
  --
++  de
=,  dejs-soft:format
  |%
  ++  hex  |=  jon=json  ^-  (unit @ux)
    ?.  ?=(%s -.jon)  ~
    =/  atom=(unit @)  (slaw:sr %ux p.jon)
    ?~  atom  ~
    atom
  ++  se  |=  aur=@tas  |=  jon=json
    ?.  ?=(%s -.jon)  ~
    (slaw aur p.jon)
  --

--
