#!/bin/bash

tb_call tb_init
[ $tb_retval -eq 0 ] || return 1

tb_call tb_width
[ $tb_retval -eq 80 ] || return 1

tb_call tb_height
[ $tb_retval -eq 24 ] || return 1

tb_call tb_put_cell "0,0,$(ord A),0,0"
[ $tb_retval -eq 0 ] || return 1

tb_call tb_present
[ $tb_retval -eq 0 ] || return 1
