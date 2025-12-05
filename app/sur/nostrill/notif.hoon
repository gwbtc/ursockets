/-  *wrap, sur=nostrill, nsur=nostr, comms=nostrill-comms, tp=trill-post
|%
+$  notif
::   profile change
  $%  [%prof =user:sur prof=user-meta:nsur]               
::  requests received  
      [%req (enbowl req:comms) solved=(unit decision:sur)]  
::  responses received to our requests
      [%res (enbowl res:comms)]
:: someone replied, reacted etc.
      [%post (enbowl engagement:comms)]
      ::
      [%nostr nostr-notif]
  ==
+$  nostr-notif
$%   [%relay-down url=@t]
     [%new-relay url=@t]  ::  TODO
==
--
