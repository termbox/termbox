<?php
declare(strict_types=1);

$test = new class() {
    public object $ffi;
    public array $defines = [];
    private string $test_log;

    public function __construct() {
        mb_internal_encoding('UTF-8');
        $this->ffi = $this->makeFfi();
        $this->test_log = $GLOBALS['argv'][1] ?? '';
    }

    private function makeFfi(): object {
        $repo_dir = dirname(__DIR__);
        $termbox_h = "$repo_dir/termbox.h";
        $libtermbox_so = "$repo_dir/libtermbox.so";
        $header_data = file_get_contents($termbox_h);

        // Extract #define values
        $matches = [];
        preg_match_all('/^#define\s+(TB_\S+)\s+(.+)$/m', $header_data, $matches, PREG_SET_ORDER);
        foreach ($matches as $match) {
            $define_name = $match[1];
            $define_value = $match[2];

            // Remove comments
            $define_value = trim(preg_replace('|/\*.*$|', '', $define_value));

            // Special case for evaluating `(0xFFFF - ...)` values
            $match2 = [];
            if (preg_match('/^\(0xFFFF - (\d+)\)$/', $define_value, $match2)) {
                $define_value = 0xFFFF - (int)$match[2];
            } else if (substr($define_value, 0, 2) === '0x') {
                $define_value = hexdec(substr($define_value, 2));
            }
            $this->defines[$define_name] = (int)$define_value;
        }

        // Make FFI
        $header_data = preg_replace('/#ifdef __cplusplus\n(.*?)#endif/sm', '', $header_data);
        $header_data = preg_replace('/^SO_IMPORT\s+/m', '', $header_data);
        $ffi = FFI::cdef($header_data, $libtermbox_so);

        // Return wrapper that logs FFI calls
        return new class($ffi, $this) {
            private FFI $ffi;
            private object $test;
            public function __construct($ffi, $test) {
                $this->ffi = $ffi;
                $this->test = $test;
            }
            public function __call(string $name, array $args) {
                if ($name !== 'tb_change_cell') {
                    $this->test->log("ffi $name " . json_encode($args));
                }
                return $this->ffi->$name(...$args);
            }
        };
    }

    public function printf(int $x, int $y, int $fg, int $bg, string $fmt, ...$args): void {
        $str = vsprintf($fmt, $args);
        for ($i = 0; $i < mb_strlen($str); $i++) {
            $wide_char = mb_substr($str, $i, 1);
            $this->ffi->tb_change_cell($x, $y, mb_ord($wide_char), $fg, $bg);
            $x += 1;
        }
    }

    public function xvkbd(string $xvkbd_cmd): int {
        $this->log("xvkbd $xvkbd_cmd");
        $cmd = sprintf(
            "DISPLAY=:1000 xvkbd -remote-display :1000 -window xterm -text %s",
            escapeshellarg($xvkbd_cmd)
        );
        $sh_cmd = sprintf(
            'sh -c %s >/dev/null 2>&1',
            escapeshellarg($cmd)
        );
        $output = [];
        $exit_code = 1;
        exec($sh_cmd, $output, $exit_code);
        return $exit_code;
    }

    public function log(string $str): void {
        $lines = explode("\n", $str);
        foreach ($lines as $line) {
            file_put_contents($this->test_log, "  $line\n", FILE_APPEND);
        }
    }

    public function screencap(): void {
        $this->log('screencap');
        sleep(PHP_INT_MAX);
    }
};
