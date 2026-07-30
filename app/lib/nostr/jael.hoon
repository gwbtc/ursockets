::  lib/nostr/jael.hoon
::
::  Bind a ship's Nostr identity to its Groundwire/Jael identity.
::
::  A Groundwire comet's Bitcoin (secp256k1/BIP-340) key lives OFF-SHIP in the
::  wallet, derived from the master ticket; Jael holds only the ship's ed25519
::  "suite-C" (cric) material.  So rather than the npub BEING the Bitcoin key
::  (impossible from inside a ship), we:
::
::    1. derive a deterministic secp256k1 Nostr keypair from the ship's own
::       ed25519 secret (scryable, our-only, via %vein), and
::    2. publish a *binding attestation*: a Nostr event, signed by the npub,
::       that carries the ship's @p and an ed25519 signature by that @p over the
::       npub.  Anyone can verify the ed25519 signature against Jael's `pass`
::       for the @p -- and since the %gw-btc verifier only lets Jael store that
::       point after confirming the comet's satpoint on-chain, a valid binding
::       makes the npub *transitively* Bitcoin-anchored.
::
::  This lib is the shared home for both halves: ships produce bindings
::  (+make-binding), relays verify them (+verify-binding).
::
::  XX  ursockets does not vendor jael.hoon/zuse; the scry paths, molds, and
::  XX  cric acru arm names below are pinned to gwbtc/urbit@cyc/cc from research
::  XX  and MUST be re-checked against the booting pill before merge.  Every such
::  XX  spot is flagged `XX pin`.
::
/-  sur=nostr
/+  nostr-keys
|%
::  binding event kind (replaceable range: one current binding per npub)
::
++  bind-kind  `@ud`13.337
::
::  +unix-secs: @da -> nostr `created_at` (unix seconds)
::
++  unix-secs
  |=  t=@da  ^-  @ud
  (div (sub t ~1970.1.1) ~s1)
::  ===========================================================================
::  own identity
::  ===========================================================================
::  +own-life: our current key life
::
++  own-life
  |=  =bowl:gall  ^-  life
  ::  XX pin: standard own-life scry into jael
  .^(life %j /(scot %p our.bowl)/life/(scot %da now.bowl)/(scot %p our.bowl))
::
::  +our-ring: our suite-C secret for a life (embeds the 64-byte ed25519 seed).
::  %vein is guarded to `our` only (jael.hoon:1449-1459, gwbtc/urbit@cyc/cc).
::
++  our-ring
  |=  [=bowl:gall =life]  ^-  ring
  ::  XX pin
  .^(ring %j /(scot %p our.bowl)/vein/(scot %da now.bowl)/(scot %ud life))
::
::  +nostr-seed: stable 256-bit secret for the Nostr key, domain-separated from
::  every other use of the ring so it can never be confused with @p signing.
::
++  nostr-seed
  |=  =bowl:gall  ^-  @
  (shas %nostr-key-v0 (our-ring bowl (own-life bowl)))
::
::  +derive-keys: THE deterministic Nostr keypair for this ship.  Same body as
::  gen-keys (rejection-sampled secp256k1 scalar) but seeded from Jael instead
::  of `eny`, so it survives reinstall and is bound to the ship's identity.
::
++  derive-keys
  |=  =bowl:gall  ^-  keys:sur
  (gen-keys:nostr-keys (nostr-seed bowl))
::
::  +xonly: 32-byte x-only pubkey (the npub) for a secp256k1 private key.
::  NB: keys:sur `pub` is a 33-byte *compressed* point (a pre-existing Nostrill
::  quirk); Nostr wants x-only, so binding/verify use this, not keys.pub.
::
++  xonly
  |=  priv=@  ^-  @ux
  x:(priv-to-pub:secp256k1:secp:crypto priv)
::  ===========================================================================
::  producing a binding (ship side, PR 1)
::  ===========================================================================
::  +sign-as-ship: ed25519-sign a message with our @p (tweaked suite-C) key.
::
++  sign-as-ship
  |=  [=bowl:gall msg=@]  ^-  @
  =/  =ring  (our-ring bowl (own-life bowl))
  ::  XX pin: confirm the cric acru signing arm (suite-C replaces crub/crua).
  (sign:as:(nol:nu:cric:crypto ring) msg)
::
::  +make-binding: build the signed binding event tying our npub to our @p.
::    tags: ['gw' @p]  ['ed' @p's-ed25519-sig-over-npub]  ['life' life]
::
++  make-binding
  |=  [=bowl:gall priv=@ eny=@]  ^-  event:sur
  =/  npub=@ux  (xonly priv)
  =/  =life     (own-life bowl)
  =/  edsig     (sign-as-ship bowl npub)
  =/  =tags:sur
    :~  ~['gw'^~ (scot %p our.bowl)]
        ~['ed'^~ (scot %ux edsig)]
        ~['life'^~ (scot %ud life)]
    ==
  =/  raw=raw-event:sur  [npub (unix-secs now.bowl) bind-kind tags '']
  =/  id=@ux    (hash-event:nostr-keys raw)
  =/  sig=@ux   (sign-event:nostr-keys priv id eny)
  [id npub (unix-secs now.bowl) bind-kind tags '' sig]
::  ===========================================================================
::  verifying a binding / an identity (relay side, PR 2 imports these)
::  ===========================================================================
::  +peer-pass: a ship's suite-C [crypto-suite pass] at a life, from Jael.
::
++  peer-pass
  |=  [=bowl:gall who=@p =life]  ^-  (unit [suite=@ud =pass])
  ::  XX pin: %puby (jael.hoon:1593-1603, gwbtc/urbit@cyc/cc)
  .^  (unit [@ud pass])  %j
      /(scot %p our.bowl)/puby/(scot %da now.bowl)/(scot %p who)/(scot %ud life)
  ==
::
::  +is-comet: does OUR jael hold a verified point for `who`?  Jael stores a
::  point only after the %gw-btc verifier confirms the on-chain satpoint, so a
::  present point == a real, confirmed Groundwire comet.  (Also require the
::  comet clan, i.e. self-sponsoring, to exclude planets/stars.)
::
++  is-comet
  |=  [=bowl:gall who=@p]  ^-  ?
  ::  %pynt gives a (unit point) for a locally-known ship; we need only its
  ::  presence, so scry loosely as (unit *) rather than depend on jael's mold.
  ::  XX pin: confirm %pynt is the right care and that a present point implies
  ::  a %gw-btc-verified comet.
  =/  pt=(unit *)
    .^  (unit *)  %j
        /(scot %p our.bowl)/pynt/(scot %da now.bowl)/(scot %p who)
    ==
  ?~  pt  |
  ?=(%pawn (clan:title who))
::
::  +ed-verify: is `sig` a valid @p ed25519 signature over `msg`, per `pass`?
::
++  ed-verify
  |=  [=pass msg=@ sig=@]  ^-  ?
  ::  XX pin: confirm the cric acru verify arm; +sure returns (unit @) = the
  ::  signed message when valid.
  =/  res=(unit @)  (sure:as:(com:nu:cric:crypto pass) msg sig)
  ?~  res  |
  =(u.res msg)
::
::  +verify-binding: given a (already sig+id-checked) binding event, confirm the
::  npub really belongs to a Jael-verified comet.  Returns the bound @p on
::  success.  Steps: parse tags -> fetch the @p's pass -> check the ed25519
::  signature over the npub -> confirm the @p is a real comet in our Jael.
::
++  verify-binding
  |=  [=bowl:gall =event:sur]  ^-  (unit @p)
  ?.  =(kind.event bind-kind)  ~
  =/  m  (malt (turn tags.event |=(t=tag:sur [-.t t])))  :: XX guard empty tags
  =/  gw    (~(get by m) 'gw')
  =/  ed    (~(get by m) 'ed')
  =/  lyf   (~(get by m) 'life')
  ?.  &(?=(^ gw) ?=(^ ed) ?=(^ lyf))  ~
  =/  who=(unit @p)   (slaw %p +>-.u.gw)   :: tag = ['gw' <@p>]
  =/  sig=(unit @ux)  (slaw %ux +>-.u.ed)
  =/  lif=(unit @ud)  (slaw %ud +>-.u.lyf)
  ?.  &(?=(^ who) ?=(^ sig) ?=(^ lif))  ~
  ?.  (is-comet bowl u.who)  ~
  =/  pp  (peer-pass bowl u.who u.lif)
  ?~  pp  ~
  ?.  (ed-verify pass.u.pp pubkey.event u.sig)  ~
  `u.who
--
