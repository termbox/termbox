# termbox

*New projects should consider using [termbox2][0], a rewrite of termbox with
stricter error checking and some additional features.*

termbox is a minimal, legacy-free alternative to ncurses, suitable for building
text-based user interfaces.

This repo represents an effort to recentralize termbox development as the
original repo is no longer maintained.

### Building

Use `make` to build and `make install` to install.

The `install` target supports `prefix` and `DESTDIR` if needed.

### Usage

The termbox API consists of the following functions.

```
tb_init() // initialization
tb_shutdown() // shutdown

tb_width() // width of the terminal screen
tb_height() // height of the terminal screen

tb_clear() // clear buffer
tb_present() // sync internal buffer with terminal

tb_put_cell()
tb_change_cell()
tb_blit() // drawing functions

tb_select_input_mode() // change input mode
tb_peek_event() // peek a keyboard event
tb_poll_event() // wait for a keyboard event
```

See termbox.h for more details.

### Links

Make a pull request if you would like your termbox project listed here.

##### Language bindings

- https://github.com/nsf/termbox - Python
- https://github.com/adsr/termbox-php - PHP
- https://github.com/gchp/rustbox - Rust
- https://github.com/cl-fui/cl-termbox - Common Lisp
- https://github.com/zyedidia/termbox-d - D
- https://github.com/dduan/Termbox - Swift
- https://github.com/andrewsuzuki/termbox-crystal - Crystal
- https://github.com/jgoldfar/Termbox.jl - Julia
- https://github.com/termbox/termbox-haskell - Haskell
- https://github.com/dom96/nimbox - Nim
- https://github.com/ndreynolds/ex_termbox - Elixir
- https://github.com/bmsauer/termbox-ada - Ada
- https://github.com/luxint/termbox - newLISP

##### Other implementations

- https://github.com/nsf/termbox-go - Go pure termbox implementation

##### Applications

- https://github.com/adsr/mle - a small, flexible terminal-based text editor
- https://github.com/colinta/Ashen - framework for building terminal applications based on the Elm architecture
- https://github.com/afify/sfm - simple file manager for unix-like systems

### Changes

v1.1.3:

- Tagging master as v1.1.3 before forking

v1.1.2:

- Properly include changelog into the tagged version commit. I.e. I messed up
  by tagging v1.1.1 and describing it in changelog after tagged commit. This
  commit marked as v1.1.2 includes changelog for both v1.1.1 and v1.1.2. There
  are no code changes in this minor release.

v1.1.1:

- Ncurses 6.1 compatibility fix. See https://github.com/nsf/termbox-go/issues/185.

v1.1.0:

- API: tb_width() and tb_height() are guaranteed to be negative if the termbox
  wasn't initialized.
- API: Output mode switching is now possible, adds 256-color and grayscale color
  modes.
- API: Better tb_blit() function. Thanks, Gunnar Zötl <gz@tset.de>.
- API: New tb_cell_buffer() function for direct back buffer access.
- API: Add new init function variants which allow using arbitrary file
  descriptor as a terminal.
- Improvements in input handling code.
- Calling tb_shutdown() twice is detected and results in abort() to discourage
  doing so.
- Mouse event handling is ported from termbox-go.
- Paint demo port from termbox-go to demonstrate mouse handling capabilities.
- Bug fixes in code and documentation.

v1.0.0:

- Remove the Go directory. People generally know about termbox-go and where
  to look for it.
- Remove old terminfo-related python scripts and backport the new one from
  termbox-go.
- Remove cmake/make-based build scripts, use waf.
- Add a simple terminfo database parser. Now termbox prefers using the
  terminfo database if it can be found. Otherwise it still has a fallback
  built-in database for most popular terminals.
- Some internal code cleanups and refactorings. The most important change is
  that termbox doesn't leak meaningless exported symbols like 'keys' and
  'funcs' now. Only the ones that have 'tb_' as a prefix are being exported.
- API: Remove unsigned ints, use plain ints instead.
- API: Rename UTF-8 functions 'utf8_*' -> 'tb_utf8_*'.
- API: TB_DEFAULT equals 0 now, it means you can use attributes alones
  assuming the default color.
- API: Add TB_REVERSE.
- API: Add TB_INPUT_CURRENT.
- Move python module to its own directory and update it due to changes in the
  termbox library.


[0]: https://github.com/termbox/termbox2
