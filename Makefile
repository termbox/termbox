prefix?=/usr/local

termbox_cflags:=-std=c99 -Wall -Wextra -pedantic -fPIC -g -O3 -D_XOPEN_SOURCE $(CFLAGS)
termbox_objects:=$(patsubst src/%.c,src/%.o,$(wildcard src/*.c))
termbox_demos:=$(patsubst src/demo/%.c,src/demo/%,$(wildcard src/demo/*.c))
termbox_so_version_abi:=1
termbox_so_version_minor:=1
termbox_so:=src/libtermbox.so
termbox_soname=libtermbox.so.$(termbox_so_version_abi)
termbox_so_x:=src/$(termbox_soname)
termbox_so_x_y:=src/libtermbox.so.$(termbox_so_version_abi).$(termbox_so_version_minor)
termbox_a:=src/libtermbox.a
termbox_h:=src/termbox.h

all: $(termbox_a) $(termbox_so_x_y) $(termbox_demos)

$(termbox_a): $(termbox_objects)
	$(AR) rcs $@ $(termbox_objects)

$(termbox_so_x_y): $(termbox_objects)
	$(CC) -shared -Wl,-h,$(termbox_soname) $(termbox_objects) -o $@

$(termbox_demos): %: %.c src/libtermbox.a
	$(CC) $(termbox_cflags) $< src/libtermbox.a -o $@

$(termbox_objects): %.o: %.c
	$(CC) -c $(termbox_cflags) $< -o $@

install: $(termbox_a) $(termbox_so_x_y)
	install -d $(DESTDIR)$(prefix)/lib
	install -d $(DESTDIR)$(prefix)/include
	install -p -m 644 $(termbox_a) $(DESTDIR)$(prefix)/lib/libtermbox.a
	install -p -m 755 $(termbox_so_x_y) $(DESTDIR)$(prefix)/lib/libtermbox.so.$(termbox_so_version_abi).$(termbox_so_version_minor)
	ln -sf libtermbox.so.$(termbox_so_version_abi).$(termbox_so_version_minor) $(DESTDIR)$(prefix)/lib/libtermbox.so.$(termbox_so_version_abi)
	ln -sf libtermbox.so.$(termbox_so_version_abi).$(termbox_so_version_minor) $(DESTDIR)$(prefix)/lib/libtermbox.so
	install -p -m 644 $(termbox_h) $(DESTDIR)$(prefix)/include/termbox.h

clean:
	rm -f src/libtermbox.* $(termbox_objects) $(termbox_demos)

.PHONY: all clean install
