/-  sur=nostrill, nsur=nostr, comms=nostrill-comms, tp=trill-post
|%
+$  notif
      ::  TODO where do we get profs?
  $%  [%prof =user:sur prof=user-meta:nsur]               :: profile change
      ::
      [%req (enbowl:sur req:sur) solved=(unit decision:sur)]  ::  requests received
      ::
      [%res (enbowl:sur res:comms)]                           ::  responses received to our requests
      ::
      [%post (enbowl:sur engagement:comms)]          :: someone replied, reacted etc.
      ::
      [%nostr nostr-notif]
  ==
+$  nostr-notif
$%   [%relay-down url=@t]
     [%new-relay url=@t]  ::  idk
==
--
