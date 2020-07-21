#!/bin/bash

main() {
    local x_display=':1000'
    local test_dir="$(cd $(dirname "${BASH_SOURCE[0]}") &>/dev/null && pwd)/"
    local test_bin="$test_dir/test"
    local test_sock="$test_dir/test.sock"
    local xterm_geom='80x24+0+0'
    local xterm_bg='grey3'
    local xterm_fg='grey93'
    tb_retval='-1'

    # loop through each 'test_*' dir
    for tdir in $(find $test_dir -type d -name 'test_*'); do
        tsh="$tdir/test.sh"
        tname="$(basename $tdir)"

        # run virtual x
        Xvfb -screen 0 800x600x24 $x_display &
        xvfb_pid=$!

        # remove unix domain socket
        rm -f $test_sock

        # run test_bin in xterm in Xvfb
        sleep 1
        xterm -display $x_display \
            -u8 -geometry $xterm_geom -bg $xterm_bg -fg $xterm_fg \
            -xrm 'xterm*metaSendsEscape:true' \
            -e "$test_bin $test_sock" &
        xterm_pid=$!

        # start coproc with test_bin over test_sock
        sleep 1
        coproc test_coproc (ncat -U $test_sock)

        sleep 1
        [ -n "$test_coproc" ] || echo "fuck"

        # run test
        source $tsh
        tsh_ec=$?

        # take screenshot and diff
        xwd -root -display $x_display -out $tdir/observed.xwd
        convert $tdir/observed.xwd $tdir/observed.gif
        diff $tdir/observed.gif $tdir/expected.gif
        diff_ec=$?

        # kill procs
        kill $xterm_pid
        kill $xvfb_pid
        kill $test_coproc_PID

        # print result
        if [ "$tsh_ec" -eq 0 -a "$diff_ec" -eq 0 ]; then
            echo -e "  \x1b[32mOK  \x1b[0m $tname"
        else
            echo -e "  \x1b[31mERR \x1b[0m $tname tsh_ec=$tsh_ec diff_ec=$diff_ec"
            echo -e "  ERR  $tname tsh_ec=$tsh_ec diff_ec=$diff_ec"
            if [ "$diff_ec" -ne 0 ]; then
                echo '       diff_gif_b64='
                compare $tdir/observed.gif $tdir/expected.gif $tdir/diff.gif
                xz -c $tdir/diff.gif | base64
            fi
        fi
    done
}

ord() {
    LC_CTYPE=C printf '%d' "'$1"
}

tb_call() {
    local call="$1:${2:-}"
    echo -n $call >&"${test_coproc[1]}"
    read -r tb_retval <&"${test_coproc[0]}"
}

main
