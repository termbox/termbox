prefix?=/usr/local

termbox_cflags:=-std=c99 -Wall -Wextra -pedantic -fPIC -g -O3 -D_XOPEN_SOURCE $(CFLAGS)
termbox_objects:=$(patsubst %.c,%.o,$(wildcard *.c))
termbox_demos:=$(patsubst demo/%.c,demo/%,$(wildcard demo/*.c))
termbox_so_version_abi:=1
termbox_so_version_minor_patch:=0.0
termbox_so:=libtermbox.so
termbox_so_x:=$(termbox_so).$(termbox_so_version_abi)
termbox_so_x_y_z:=$(termbox_so_x).$(termbox_so_version_minor_patch)
termbox_a:=libtermbox.a
termbox_h:=termbox.h

all: $(termbox_a) $(termbox_so_x_y_z) $(termbox_demos)

$(termbox_a): $(termbox_objects)
	$(AR) rcs $@ $(termbox_objects)

$(termbox_so_x_y_z): $(termbox_objects)
	$(CC) -shared -Wl,-h,$(termbox_so_x) $(termbox_objects) -o $@

$(termbox_demos): %: %.c $(termbox_a)
	$(CC) $(termbox_cflags) $^ -o $@

$(termbox_objects): %.o: %.c
	$(CC) -c $(termbox_cflags) $< -o $@

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

.PHONY: all install clean
