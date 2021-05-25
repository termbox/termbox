prefix?=/usr/local

termbox_cflags:=-std=c99 -Wall -Wextra -pedantic -Wno-unused-result -fPIC -g -O3 -D_XOPEN_SOURCE $(CFLAGS)
termbox_objects:=$(patsubst %.c,%.o,$(wildcard *.c))
termbox_demos:=$(patsubst demo/%.c,demo/%,$(wildcard demo/*.c))
termbox_so_version_abi:=1
termbox_so_version_minor_patch:=0.0
termbox_so:=libtermbox.so
termbox_so_x:=$(termbox_so).$(termbox_so_version_abi)
termbox_so_x_y_z:=$(termbox_so_x).$(termbox_so_version_minor_patch)
termbox_ld_soname:=soname
termbox_a:=libtermbox.a
termbox_h:=termbox.h

ifeq ($(shell $(CC) -dumpmachine | grep -q apple && echo 1), 1)
	termbox_so:=libtermbox.dylib
	termbox_so_x:=libtermbox.$(termbox_so_version_abi).dylib
	termbox_so_x_y_z:=libtermbox.$(termbox_so_version_abi).$(termbox_so_version_minor_patch).dylib
	termbox_ld_soname:=install_name
endif

all: $(termbox_a) $(termbox_so_x_y_z) $(termbox_demos)

$(termbox_a): $(termbox_objects)
	$(AR) rcs $@ $(termbox_objects)

$(termbox_so_x_y_z): $(termbox_objects)
	$(CC) -shared -Wl,-$(termbox_ld_soname),$(termbox_so_x) $(termbox_objects) -o $@
	ln -sf $@ $(termbox_so)

$(termbox_demos): %: %.c $(termbox_a)
	$(CC) $(termbox_cflags) $^ -o $@

$(termbox_objects): %.o: %.c
	$(CC) -c $(termbox_cflags) $< -o $@

test: all
	docker build -f tests/Dockerfile .

install: $(termbox_a) $(termbox_so_x_y_z)
	install -d $(DESTDIR)$(prefix)/lib
	install -d $(DESTDIR)$(prefix)/include
	install -p -m 644 $(termbox_a) $(DESTDIR)$(prefix)/lib/$(termbox_a)
	install -p -m 755 $(termbox_so_x_y_z) $(DESTDIR)$(prefix)/lib/$(termbox_so_x_y_z)
	ln -sf $(termbox_so_x_y_z) $(DESTDIR)$(prefix)/lib/$(termbox_so_x)
	ln -sf $(termbox_so_x_y_z) $(DESTDIR)$(prefix)/lib/$(termbox_so)
	install -p -m 644 $(termbox_h) $(DESTDIR)$(prefix)/include/$(termbox_h)

clean:
	rm -f $(termbox_so_x_y_z) $(termbox_a) $(termbox_objects) $(termbox_demos)

.PHONY: all test install clean
