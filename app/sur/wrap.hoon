|%
::  generic type wrappers
::  A Result type of sorts.
++  approval
  |$  t
  $^  [%ok data=t]
       %ng
::  +enbowl adds bowl information (source, timestamp) to a type
::  Useful to pass around data received on pokes on different context,
:: helps avoid defining duplicate types for essentially the same data
++  enbowl
  |$  t
  $:  =user
      ts=@da
      p=t
  ==
+$  user  $%([%urbit p=@p] [%nostr p=@ux])
--
