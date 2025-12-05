/-  sur=nostrill, nsur=nostr, tp=trill-post
|%
+$  notif
  $%  [%prof =user prof=user-meta:nostr]              :: profile change
      [%fans =user:sur msg=@t]                            :: someone folowed me
      [%fols =user:sur accepted=? msg=@t]                 :: follow response 
      :: [%beg-req =user beg=begs-poke:ui msg=@t]        :: feed/post data request request
      :: [%beg-res beg=begs-poke:ui accepted=? msg=@t]   :: feed/post data request response
      [%post =pid:tp =user action=post-notif]         :: someone replied, reacted etc.
  ==
+$  post-notif
$%   [%reply p=post:tp]
     [%quote p=post:tp]
     [%reaction reaction=@t]
     :: [%rt id=@ux pubkey=@ux relay=@t]  :: NIP-18
     [%rp ~]  :: NIP-18
     [%del ~]
==
--
