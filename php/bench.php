<?php

if (PHP_MAJOR_VERSION < 5 || (PHP_MAJOR_VERSION === 5 && PHP_MINOR_VERSION < 6)) {
    echo 'This script requires PHP 5.6 or higher.';
    exit(1);
}

$defaultArgs = [
    // Increase the multiplier if you want to benchmark longer
    'multiplier' => 1.0,
];

$args = get_args($defaultArgs);
$args = array_merge($defaultArgs, $args);

/** @var array<string, callable> $benchmarks */
// the benchmarks!
$benchmarks = [
    'math' => function ($multiplier = 1, $count = 200000) {
        $x = 0;
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            $x += $i + $i;
            $x += $i * $i;
            $x += $i ** $i;
            $x += $i / (($i + 1) * 2);
            $x += $i % (($i + 1) * 2);
            abs($i);
            acos($i);
            acosh($i);
            asin($i);
            asinh($i);
            atan2($i, $i);
            atan($i);
            atanh($i);
            ceil($i);
            cos($i);
            cosh($i);
            decbin($i);
            dechex($i);
            decoct($i);
            deg2rad($i);
            exp($i);
            expm1($i);
            floor($i);
            fmod($i, $i);
            hypot($i, $i);
            is_infinite($i);
            is_finite($i);
            is_nan($i);
            log10($i);
            log1p($i);
            log($i);
            pi();
            pow($i, $i);
            rad2deg($i);
            sin($i);
            sinh($i);
            sqrt($i);
            tan($i);
            tanh($i);
        }

        return $i;
    },
    'loops' => function ($multiplier = 1, $count = 20000000) {
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; ++$i) {
            $i;
        }
        $i = 0;
        while ($i < $count) {
            ++$i;
        }
        return $i;
    },
    'ifelse' => function ($multiplier = 1, $count = 10000000) {
        $a = 0;
        $b = 0;
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            $k = $i % 4;
            if ($k === 0) {
                $i;
            } elseif ($k === 1) {
                $a = $i;
            } elseif ($k === 2) {
                $b = $i;
            } else {
                $i;
            }
        }
        return $a - $b;
    },
    'switch' => function ($multiplier = 1, $count = 10000000) {
        $a = 0;
        $b = 0;
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            switch ($i % 4) {
                case 0:
                    $i;
                    break;
                case 1:
                    $a = $i;
                    break;
                case 2:
                    $b = $i;
                    break;
                default:
                    break;
            }
        }
        return $a - $b;
    },
    'string' => function ($multiplier = 1, $count = 50000) {
        $string = '<i>the</i> quick brown fox jumps over the lazy dog  ';
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            addslashes($string);
            bin2hex($string);
            chunk_split($string);
            convert_uudecode(convert_uuencode($string));
            count_chars($string);
            explode(' ', $string);
            htmlentities($string);
            md5($string);
            metaphone($string);
            ord($string);
            rtrim($string);
            sha1($string);
            soundex($string);
            str_getcsv($string);
            str_ireplace('fox', 'cat', $string);
            str_pad($string, 50);
            str_repeat($string, 10);
            str_replace('fox', 'cat', $string);
            str_rot13($string);
            str_shuffle($string);
            str_word_count($string);
            strip_tags($string);
            strpos($string, 'fox');
            strlen($string);
            strtolower($string);
            strtoupper($string);
            substr_count($string, 'the');
            trim($string);
            ucfirst($string);
            ucwords($string);
        }
        return $string;
    },
    'array' => function ($multiplier = 1, $count = 50000) {
        $a = range(0, 100);
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            array_keys($a);
            array_values($a);
            array_flip($a);
            array_map(function ($e) {
            }, $a);
            array_walk($a, function ($e, $i) {
            });
            array_reverse($a);
            array_sum($a);
            array_merge($a, [101, 102, 103]);
            array_replace($a, [1, 2, 3]);
            array_chunk($a, 2);
        }
        return $a;
    },
    'regex' => function ($multiplier = 1, $count = 1000000) {
        for ($i = 0; $i < $count * $multiplier; $i++) {
            preg_match("#http[s]?://\w+[^\s\[\]\<]+#",
                'this is a link to https://google.com which is a really popular site');
            preg_replace("#(^|\s)(http[s]?://\w+[^\s\[\]\<]+)#i", '\1<a href="\2">\2</a>',
                'this is a link to https://google.com which is a really popular site');
        }
        return $i;
    },
    'is_{type}' => function ($multiplier = 1, $count = 2500000) {
        $o = new stdClass();
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            is_array([1]);
            is_array('1');
            is_int(1);
            is_int('abc');
            is_string('foo');
            is_string(123);
            is_bool(true);
            is_bool(5);
            is_numeric('hi');
            is_numeric('123');
            is_float(1.3);
            is_float(0);
            is_object($o);
            is_object('hi');
        }
        return $o;
    },
    'hash' => function ($multiplier = 1, $count = 10000) {
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            md5($i);
            sha1($i);
            hash('sha256', $i);
            hash('sha512', $i);
            hash('ripemd160', $i);
            hash('crc32', $i);
            hash('crc32b', $i);
            hash('adler32', $i);
            hash('fnv132', $i);
            hash('fnv164', $i);
            hash('joaat', $i);
            hash('haval128,3', $i);
            hash('haval160,3', $i);
            hash('haval192,3', $i);
            hash('haval224,3', $i);
            hash('haval256,3', $i);
            hash('haval128,4', $i);
            hash('haval160,4', $i);
            hash('haval192,4', $i);
            hash('haval224,4', $i);
            hash('haval256,4', $i);
            hash('haval128,5', $i);
            hash('haval160,5', $i);
            hash('haval192,5', $i);
            hash('haval224,5', $i);
            hash('haval256,5', $i);
        }
        return $i;
    },
    'json' => function ($multiplier = 1, $count = 100000) {
        $data = [
            'foo' => 'bar',
            'bar' => 'baz',
            'baz' => 'qux',
            'qux' => 'quux',
            'quux' => 'corge',
            'corge' => 'grault',
            'grault' => 'garply',
            'garply' => 'waldo',
            'waldo' => 'fred',
            'fred' => 'plugh',
            'plugh' => 'xyzzy',
            'xyzzy' => 'thud',
            'thud' => 'end',
        ];
        $count = $count * $multiplier;
        for ($i = 0; $i < $count; $i++) {
            json_encode($data);
            json_decode(json_encode($data));
        }
        return $data;
    },
];

$mtime = microtime(true);
// workaround for https://www.php.net/manual/en/datetime.createfromformat.php#128901
if (fmod($mtime, 1) === .0000) {
    $mtime += .0001;
}
$now = DateTime::createFromFormat('U.u', $mtime);

$V = '2.0';
$isCli = PHP_SAPI === 'cli';
$lf = $isCli ? PHP_EOL : '<br>';
$w = 55;
$multiplier = $args['multiplier'];
$additionalBenchmarks = loadAdditionalBenchmarks();

$p = function ($str, $endStr = '', $pad = '.', $mode = STR_PAD_RIGHT) use ($w, $lf) {
    if (!empty($endStr)) {
        $endStr = " $endStr";
    }
    $length = max(0, $w - strlen($endStr));
    echo str_pad($str, $length, $pad, $mode) . $endStr . $lf;
};

echo $isCli ? '' : '<pre>';
$p('', '', '-');
printf('|%s|%s', str_pad(sprintf("PHP BENCHMARK SCRIPT v.%s by @SergiX44", $V), $w - 2, ' ', STR_PAD_BOTH), $lf);
$p('', '', '-');
$p('PHP', PHP_VERSION);
$p('Platform', PHP_OS);
$p('Arch', php_uname('m'));
if ($isCli) {
    $p('Server', gethostname());
} else {
    $name = @$_SERVER['SERVER_NAME'] ?: 'null';
    $addr = @$_SERVER['SERVER_ADDR'] ?: 'null';
    $p('Server', "{$name}@{$addr}");
}
$p('Max memory usage', ini_get('memory_limit'));
$opStatus = function_exists('opcache_get_status') ? opcache_get_status() : false;
$p('OPCache status', is_array($opStatus) && @$opStatus['opcache_enabled'] ? 'enabled' : 'disabled');
$p('OPCache JIT', is_array($opStatus) && @$opStatus['jit']['enabled'] ? 'enabled' : 'disabled/unavailable');
$p('PCRE JIT', ini_get('pcre.jit') ? 'enabled' : 'disabled');
$p('XDebug extension', extension_loaded('xdebug') ? 'enabled' : 'disabled');
$p('Difficulty multiplier', "{$multiplier}x");
$p('Started at', $now->format('d/m/Y H:i:s.v'));
$p('', '', '-', STR_PAD_BOTH);

$stopwatch = new StopWatch();

foreach ($benchmarks as $name => $benchmark) {
    $time = runBenchmark($stopwatch, $name, $benchmark, $multiplier);
    $p($name, $time);
}

if (!empty($additionalBenchmarks)) {
    $p('Additional Benchmarks', '', '-', STR_PAD_BOTH);
    foreach ($additionalBenchmarks as $name => $benchmark) {
        $time = runBenchmark($stopwatch, $name, $benchmark, $multiplier);
        $p($name, $time);
    }
}

$p('', '', '-');
$p('Total time', number_format($stopwatch->totalTime, 4) . ' s');
$p('Peak memory usage', round(memory_get_peak_usage(true) / 1024 / 1024, 2) . ' MiB');

echo $isCli ? '' : '</pre>';


class StopWatch
{
    /**
     * @var float
     */
    public $totalTime = .0;

    private $start;


    /**
     * @return float
     */
    public function start()
    {
        return $this->start = $this->t();
    }

    /**
     * @return float
     */
    public function stop()
    {
        $time = $this->t() - $this->start;
        $this->totalTime += $time;

        return $time;
    }

    /**
     * @return float
     */
    private function t()
    {
        return function_exists('hrtime') ? hrtime(true) / 1e9 : microtime(true);
    }
}

function get_args($expectedArgs)
{
    $args = [];

    if (PHP_SAPI === 'cli') {
        $cleanedArgs = array_map(function ($arg) {
            return strpos($arg, '--') !== 0 ? null : str_replace('--', '', $arg);
        }, $GLOBALS['argv']);

        parse_str(implode('&', array_filter($cleanedArgs)), $args);
    } else {
        parse_str($_SERVER['QUERY_STRING'], $args);
    }

    $args = array_intersect_key($args, array_flip(array_keys($expectedArgs)));

    // cast the type to the original type if needed
    foreach ($expectedArgs as $key => $value) {
        if (isset($args[$key])) {
            settype($args[$key], gettype($value));
        }
    }

    return $args;
}

function loadAdditionalBenchmarks()
{
    $benchmarks = [];
    $benchFiles = glob(__DIR__ . '/./*.bench.php');
    foreach ($benchFiles as $benchFile) {
        $benchName = basename($benchFile, '.bench.php');
        $newBenchmark = require $benchFile;
        if (is_callable($newBenchmark)) {
            $benchmarks[$benchName] = $newBenchmark;
            continue;
        }

        if (is_array($newBenchmark)) {
            $newBenchmark = array_filter($newBenchmark, 'is_callable');
            $newBenchmark = array_combine(array_map(function ($name) use ($benchName) {
                return "{$benchName}::{$name}";
            }, array_keys($newBenchmark)), $newBenchmark);

            $benchmarks = array_merge($benchmarks, $newBenchmark);
            continue;
        }

        throw new RuntimeException("Invalid benchmark file: {$benchFile}");
    }

    return $benchmarks;
}

function runBenchmark($stopwatch, $name, $benchmark, $multiplier = 1)
{
    $r = null;
    try {
        $stopwatch->start();
        $r = $benchmark($multiplier);
    } catch (Exception $e) {
        return 'ERROR: ' . $e->getMessage();
    } finally {
        $time = $stopwatch->stop();
    }

    if ($r === INF) {
        return 'SKIPPED';
    }

    return number_format($time, 4) . ' s';
}