/=  gwid  /gwid/mnemonyms
/*  english       %txt   /gwid/wordlists/english/txt
/*  test-vectors  %json  /gwid/wordlists/test-vectors/json
|%
+$  output
  $:  nym=@t
      abridged=@t
      foreshortened=@t
      encoded=@ux
      width=@ud
  ==
++  make
  |=  our=@p  ^-  output
  =/  width  128
  (make-c our width .n)
++  make-c
  |=  [our=@p width=@ud tweak=?]  ^-  output
  =/  me  ~(. me:gwid [tweak width english])
  =/  nym  (name:me our)
  =/  abridged  (abridge:me nym)
  =/  foreshortend  (foreshorten:me nym)
  =/  encoded  (encode:me nym)
  :: encode just outputs the same as `@ux`our which is nice I guess
  [nym abridged foreshortend encoded width]
+$  misc-data
  $:  ship=@p
      nym=@t
      hex=@ux
      width=@ud
  ==
++  misc
  |=  d=misc-data
    =/  me  ~(. me:gwid [.n width.d english])
    =/  decoded    (decode:me hex.d)
    =/  validated  (validate:me nym.d)
    [decoded validated]
--
