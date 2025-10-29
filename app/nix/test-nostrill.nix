{ click, pierBus, pierFun, pkgs, urbitBin }:

let
  poke = ''
    =>
    |%
    ++  take-poke-ack
      |=  =wire
      =/  m  (strand ,?)
      ^-  form:m
      |=  tin=strand-input:strand
      ?+  in.tin  `[%skip ~]
          ~  `[%wait ~]
          [~ %agent * %poke-ack *]
        ?.  =(wire wire.u.in.tin)
          `[%skip ~]
        ?~  p.sign.u.in.tin
          `[%done %.y]
        `[%done %.n]
      ==
    ++  poke
      |=  [=dock =cage]
      =/  m  (strand ,?)
      ^-  form:m
      =/  =card:agent:gall  [%pass /poke %agent dock %poke cage]
      ;<  ~  bind:m  (send-raw-card card)
      (take-poke-ack /poke)
    --

  '';

  pokeHood = mark: hoon:
    pkgs.writeTextFile {
      name = "${mark}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        ;<  ok=?  bind:m  (poke [ship %hood] ${mark}+!>(${hoon}))
        (pure:m !>(ok))
      '';
    };

  pokePost = app:
    pkgs.writeTextFile {
      name = ":${app}-json-post.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~  ['post' (frond:enjs:format 'add' (frond:enjs:format 'content' s+'Hello world'))]
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %${app}] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  pokeReply = ship:
    pkgs.writeTextFile {
      name = ":nostrill-json-post.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        =/  pax  /(scot %p ship)/nostrill/(scot %da now)/feed/(scot %p ~${ship})/noun
        =/  id=@t  
          %-  crip
          %-  a-co:co
          %-  rear
          ;;  (list @da)  .^(noun %gx pax)
        =/  dat=json
          %-  pairs:enjs:format
          :~  :-  'post' 
              %-  frond:enjs:format  :-  'reply' 
              %-  pairs:enjs:format 
                :~  ['content' s+'Reply']
                    ['host' s+'~${ship}']
                    ['id' s+id]
                    ['thread' s+id]
                ==
          ==
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  pokeProfile = app:
    pkgs.writeTextFile {
      name = ":${app}-json-profile.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~  :-  'prof'
              %-  frond:enjs:format  :-  'add'
              %-  pairs:enjs:format
              :~  ['name' s+'zod']
                  ['about' s+'about me']
                  ['picture' s+'pic']
                  ['other' (pairs:enjs:format ~[['location' s+'Urbit'] ['status' s+'testing']])]
              ==
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %${app}] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  pokeFollow = ship:
    pkgs.writeTextFile {
      name = ":nostrill-json-follow-${ship}.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        =/  dat=json
          %-  pairs:enjs:format
          :~
            :-  'fols'
            (frond:enjs:format 'add' (frond:enjs:format 'urbit' s+(scot %p ~${ship})))
          ==
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  ok=?  bind:m  (poke [ship %nostrill] %json !>(dat))
        (pure:m !>(ok))
      '';
    };

  scryFeed = ship: res:
    pkgs.writeTextFile {
      name = "scry-${ship}-feed.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        =/  pax  /(scot %p ship)/nostrill/(scot %da now)/feed/(scot %p ~${ship})/noun
        =/  result  
        %-  lent  
        .^((list @da) %gx pax)
        ~&  >>  result/result
        =/  got  =(result ${res})
        (pure:m !>(got))
      '';
    };

  scryThread = ship:
    pkgs.writeTextFile {
      name = "scry-${ship}-feed.hoon";
      text = ''
        ${poke}
        =/  m  (strand ,vase)
        ;<  [=ship =desk =case]  bind:m  get-beak
        ;<  now=@da  bind:m  get-time
        =/  pax-feed  /(scot %p ship)/nostrill/(scot %da now)/feed/(scot %p ~${ship})/noun
        =/  id=@t
          %-  crip 
          %-  (w-co:co 1)
          %-  rear
          ^.((list @da) %gx pax-feed)
        =/  pax  /(scot %p ship)/nostrill/(scot %da now)/thread/(scot %p ~${ship})/[id]/json
        =/  result  .^(json %gx pax)
        ~&  >>  result 
        (pure:m !>(result))
      '';
    };

  vatsThread = pkgs.writeTextFile {
    name = "vats.hoon";
    text = ''
      ${poke}
      =/  m  (strand ,vase)
      ;<  =bowl:gall  bind:m  get-bowl
      ;<  our=@p  bind:m  get-our  
      ;<  now=@da  bind:m  get-time
      =/  report=tang  (report-vats our now [%nostril ~] %$ |)
      (pure:m !>((crip ~(ram re [%rose [~ ~ ~] report]))))
    '';
  };


in pkgs.stdenvNoCC.mkDerivation {
  name = "test-nostrill";

  phases = [ "buildPhase" "checkPhase" ];

  nativeBuildInputs = [ pkgs.netcat ];

  buildPhase = ''
    set -x
    set -e

    cp -R ${pierBus} ./bus
    chmod -R u+rw ./bus

    cp -R ${pierFun} ./fun
    chmod -R u+rw ./fun


    # Boot ships in daemon mode
    ${urbitBin} -d ./bus 2>&1 | tee bus.log &
    BUS_PID=$!

    ${urbitBin} -d ./fun 2>&1 | tee fun.log &
    FUN_PID=$!

    tail -F bus.log >&2 &
    tail -F fun.log >&2 &

    echo "Booting ~bus"
    for i in {1..120}; do
      if grep -q "ames: live" bus.log 2>/dev/null || grep -q "http: live" bus.log 2>/dev/null; then
        echo "~bus is ready!"
        break
      fi
      sleep 1
    done

    echo "Booting ~fun"
    for i in {1..120}; do
      if grep -q "ames: live" fun.log 2>/dev/null || grep -q "http: live" fun.log 2>/dev/null; then
        echo "~fun is ready!"
        break
      fi
      sleep 1
    done


    # Extra buffer
    sleep 5

    # Nostrill is already installed in the pill, ready to test

    # Poking ~bus with post and profile data
    echo ">>> TEST: bus-poke-nostrill-json-post" | tee -a test-output.log
    ${click} -kp -i ${pokePost "nostrill"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    echo ">>> TEST: bus-poke-nostrill-json-profile" | tee -a test-output.log
    ${click} -kp -i ${pokeProfile "nostrill"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    # Poking ~fun with subscription to ~bus feed
    echo ">>> TEST: fun-poke-nostrill-json-follow-bus" | tee -a test-output.log
    ${click} -kp -i ${pokeFollow "bus"} ./fun 2>&1 | tee -a test-output.log
    sleep 5

    # Poking ~bus with another post data
    echo ">>> TEST: bus-poke-nostrill-json-post-2" | tee -a test-output.log
    ${click} -kp -i ${pokePost "nostrill"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    #  Scrying ~bus feed on ~bus, should be equal to 2 posts 
    echo ">>> TEST: bus-scry-nostrill-our-feed" | tee -a test-output.log
    ${click} -kp -i ${scryFeed "bus" "2"} ./bus 2>&1 | tee -a test-output.log
    sleep 1

    #  Scrying ~bus feed on ~fun, should be equal to 2 posts after update 
    echo ">>> TEST: fun-scry-nostrill-bus-feed" | tee -a test-output.log
    ${click} -kp -i ${scryFeed "bus" "2"} ./fun 2>&1 | tee -a test-output.log
    sleep 1

    #  Poking ~fun with reply post to ~bus
    echo ">>> TEST: fun-poke-nostrill-json-reply" | tee -a test-output.log
    ${click} -kp -i ${pokeReply "bus"} ./fun 2>&1 | tee -a test-output.log
    sleep 1

    #  Scrying thread on ~bus
    ${click} -kp -i ${scryThread "bus"} ./bus 2>&1 | tee -a test-output.log
    sleep 1


    # Exit both ships
    echo "Shut down ~bus"
    ${click} -kp -i ${pokeHood "drum-exit" "~"} ./bus 2>&1
    echo "Shut down ~fun"
    ${click} -kp -i ${pokeHood "drum-exit" "~"} ./fun 2>&1
    sleep 5

    pkill -P $$ tail || true

    set +x

    # Combine all logs
    {
      echo "=== TEST OUTPUT ==="
      if [ -f test-output.log ]; then
        cat test-output.log
      else
        echo "test-output.log not found"
      fi
      echo ""

      echo "=== BUS LOG ==="
      if [ -f bus.log ]; then
        cat bus.log
      else
        echo "bus.log not found"
      fi
      echo ""

      echo "=== FUN LOG ==="
      if [ -f fun.log ]; then
        cat fun.log
      else
        echo "fun.log not found"
      fi
    } > $out
  '';

  checkPhase = ''

    # Check for all types of failures
    has_app_errors=$(grep -E "(bad-ui-poke)" $out >/dev/null && echo "yes" || echo "no")

    has_crashes=$(grep -E "(bail:|mote:|crud:|gall:.*failed|%lost)" $out >/dev/null && echo "yes" || echo "no")

    has_errors=$(grep -E "(FAILED|CRASHED|Failed|warn:)" $out >/dev/null && echo "yes" || echo "no")

    has_failed_acks=$(grep -F "[0 %avow 0 %noun 1]" $out >/dev/null && echo "yes" || echo "no")

    if [ "$has_app_errors" = "yes" ] || [ "$has_crashes" = "yes" ] || [ "$has_errors" = "yes" ] || [ "$has_failed_acks" = "yes" ]; then

      echo ""
      echo "TESTS FAILED"
      echo "=============================="
      echo ""

      # Show agent crashes
      if [ "$has_crashes" = "yes" ]; then
        echo "--- Agent Crashes ---"
        echo ""
        grep -B 5 -A 10 -E "(bail:|mote:|crud:|gall:.*failed|%lost)" $out | head -100
        echo ""
      fi

      # Show general errors
      if [ "$has_errors" = "yes" ]; then
        echo "--- Error Keywords Found ---"
        echo ""
        grep -E "(FAILED|CRASHED|Failed|warn:)" $out | head -10
        echo ""
      fi

      # Show detailed failed tests
      echo "--- Failed Tests ---"
      echo ""

      # Process failed acks
      if [ "$has_failed_acks" = "yes" ]; then
        grep -B 20 "\[0 %avow 0 %noun 1\]" $out | grep -E "(>>> TEST:|avow.*noun 1)" | while read line; do
          if echo "$line" | grep -q ">>> TEST:"; then
            current_test=$(echo "$line" | sed 's/>>> TEST: //')
          elif echo "$line" | grep -q "avow.*noun 1"; then
            echo "  - $current_test failed with: [0 %avow 0 %noun 1]"
          fi
        done
      fi

      # Process app errors (bad-ui-poke)
      if [ "$has_app_errors" = "yes" ]; then
        grep -n "bad-ui-poke" $out | while IFS=: read line_num error_text; do
          # Find the most recent test before this line
          test_name=$(sed -n "1,''${line_num}p" $out | grep ">>> TEST:" | tail -1 | sed 's/>>> TEST: //')
          # Get logs around the error
          context=$(sed -n "''${line_num},$((line_num + 5))p" $out | head -6)
          echo "  - $test_name failed with: bad-ui-poke"
          echo "$context" | sed 's/^/      /'
          echo ""
        done
      fi

      echo ""
      echo "======================================"
      exit 1
    fi

    echo "Tests passed!"
  '';

  doCheck = true;

  # Fix 'bind: operation not permitted' on macOS
  __darwinAllowLocalNetworking = true;
}