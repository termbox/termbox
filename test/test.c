#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/socket.h>
#include <sys/un.h>

#include "../termbox.h"

int main(int argc, char **argv) {
    struct sockaddr_un addr;
    char *sockpath;
    int listenfd, sockfd;
    char buf[1024];
    ssize_t iorv;
    int rv, x, y, mode, timeout;
    int inited;
    struct tb_cell cell;
    struct tb_event event;

    listenfd = -1;
    sockfd = -1;
    inited = 0;

    (void)argc;

    if ((listenfd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        perror("socket error");
        goto main_error;
    }
    sockpath = argc > 1 ? argv[1] : "termbox.sock";

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, sockpath, sizeof(addr.sun_path) - 1);
    if (bind(listenfd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind error");
        goto main_error;
    }

    if (listen(listenfd, 1) < 0) {
        perror("listen error");
        goto main_error;
    }

    if (listen(listenfd, 1) < 0) {
        perror("listen error");
        goto main_error;
    }

    if ((sockfd = accept(listenfd, NULL, NULL)) < 0) {
        perror("accept error");
        goto main_error;
    }

    while (1) {
        iorv = read(sockfd, buf, sizeof(buf) - 1);
        if (iorv < 0) {
            perror("read error");
            exit(1);
        } else if (iorv == 0) {
            break;
        }

        buf[iorv] = '\0';

        rv = 0;
        memset(&cell, 0, sizeof(cell));
        memset(&event, 0, sizeof(event));
        x = 0;
        y = 0;
        mode = 0;
        timeout = 0;

        if (0) {
        } else if (strncmp(buf, "tb_init:",                 8) == 0) {
            rv = tb_init();
            if (rv == 0) inited = 1;
        } else if (strncmp(buf, "tb_init_file:",            13) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_init_fd:",              11) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_shutdown:",             12) == 0) {
            tb_shutdown();
            inited = 0;
        } else if (strncmp(buf, "tb_width:",                9) == 0) {
            rv = tb_width();
        } else if (strncmp(buf, "tb_height:",               10) == 0) {
            rv = tb_height();
        } else if (strncmp(buf, "tb_clear:",                9) == 0) {
            tb_clear();
        } else if (strncmp(buf, "tb_set_clear_attributes:", 24) == 0) {
            sscanf(buf + 24, "%" SCNu16 ",%" SCNu16, &cell.fg, &cell.bg);
            tb_set_clear_attributes(cell.fg, cell.bg);
        } else if (strncmp(buf, "tb_present:",              11) == 0) {
            tb_present();
        } else if (strncmp(buf, "tb_set_cursor:",           14) == 0) {
            sscanf(buf + 14, "%d,%d", &x, &y);
            tb_set_cursor(x, y);
        } else if (strncmp(buf, "tb_put_cell:",             12) == 0) {
            sscanf(buf + 12, "%d,%d,%" SCNu32 ",%" SCNu16 ",%" SCNu16, &x, &y, &cell.ch, &cell.fg, &cell.bg);
            tb_put_cell(x, y, &cell);
        } else if (strncmp(buf, "tb_change_cell:",          15) == 0) {
            sscanf(buf + 15, "%d,%d,%" SCNu32 ",%" SCNu16 ",%" SCNu16, &x, &y, &cell.ch, &cell.fg, &cell.bg);
            tb_change_cell(x, y, cell.ch, cell.fg, cell.bg);
        } else if (strncmp(buf, "tb_blit:",                 8) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_cell_buffer:",          15) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_select_input_mode:",    21) == 0) {
            sscanf(buf + 21, "%d", &mode);
            rv = tb_select_input_mode(mode);
        } else if (strncmp(buf, "tb_select_output_mode:",   22) == 0) {
            sscanf(buf + 22, "%d", &mode);
            rv = tb_select_input_mode(mode);
        } else if (strncmp(buf, "tb_peek_event:",           14) == 0) {
            sscanf(buf + 14, "%d", &timeout);
            rv = tb_peek_event(&event, timeout);
        } else if (strncmp(buf, "tb_poll_event:",           14) == 0) {
            rv = tb_poll_event(&event);
        } else if (strncmp(buf, "tb_utf8_char_length:",     20) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_utf8_char_to_unicode:", 24) == 0) {
            rv = 1; // TODO
        } else if (strncmp(buf, "tb_utf8_unicode_to_char:", 24) == 0) {
            rv = 1; // TODO
        } else {
            fprintf(stderr, "unrecognized function: %s", buf);
            goto main_error;
        }

        if (rv != -1 && event.type != 0) {
            sprintf(buf,
                "%d:"       // rv
                "%" PRIu8   // type
                ",%" PRIu8  // mod
                ",%" PRIu16 // key
                ",%" PRIu32 // ch
                ",%" PRId32 // w
                ",%" PRId32 // h
                ",%" PRId32 // x
                ",%" PRId32 // y
                "\n",
                rv,
                event.type, event.mod, event.key, event.ch, event.w, event.h, event.x, event.y
            );
        } else {
            sprintf(buf, "%d\n", rv);
        }
        if (write(sockfd, buf, strlen(buf)) != (ssize_t)strlen(buf)) {
            fprintf(stderr, "write error\n");
            goto main_error;
        }
    }
    rv = 0;

main_done:
    if (inited) tb_shutdown();
    if (sockfd >= 0) close(sockfd);
    if (listenfd >= 0) close(listenfd);
    return rv;

main_error:
    rv = 1;
    goto main_done;
    return 1;
}
