# termbox tests

Integration tests for termbox are written in PHP 7.4+. Library calls to
libtermbox are made via PHP's FFI extension. Input is simulated via [`xvkbd`][1].
Test scripts run inside an [`xterm`][2] terminal emulator running inside an
[`Xvfb`][3] X server running inside a container. The terminal contents are
captured via `xterm`'s `print-immediate` action. In the future, we could support
other terminal emulators and capture terminal contents graphically via, e.g.,
[`xwd`][4]. This is not a very simple setup, but it makes it easy to add new
tests.

To add a new test, make a test script at `tests/test_<your_test>/test.php`. Use
`$test->ffi->tb_*` to make library calls. There is a helper method available
`$test->printf(...)` for convenience. Use `$test->xvkbd(...)` for simulating
input. See `man 1 xvkbd` for notes on its syntax. Make sure your test ends with
a call to `$test->screencap()`. See `tests/test_basic/test.php` for an example.

Run `tests/run.sh` (requires local PHP 7.4+, xvfb, xterm, xvkbd, etc) or
`make test` (requires Docker). This will generate a screen capture at
`tests/test_<your_test>/observed.ansi`. If it looks good (`cat` to view), copy
it to `tests/test_<your_test>/expected.ansi` and commit that along with your PHP
script. If you're running the test via Docker, you can either base64-decode the
diff output labeled `observed.ansi.b64` to generate an `expected.ansi` locally,
or if you have the container id handy (`docker ps -a`), copy it from the
container directly:

    docker cp <container_id>:/termbox/tests/test_<your_test>/observed.ansi tests/test_<your_test>/expected.ansi

Tests run on [Travis CI][5].

[1]: http://t-sato.in.coocan.jp/xvkbd/
[2]: https://invisible-island.net/xterm/
[3]: https://www.x.org/releases/current/doc/man/man1/Xvfb.1.xhtml
[4]: https://en.wikipedia.org/wiki/Xwd
[5]: https://travis-ci.org/github/termbox/termbox
