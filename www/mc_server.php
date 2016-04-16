<?php
//Set output header
header('Content-Type: application/json');

$rawData = file_get_contents('php://input');

//print_r(json_decode($rawData, true));
//print_r(dirname(__FILE__));


//$file = "compress.zlib://client_info.txt.gz";
$file = "file:///tmp/client_info.txt";
$fp = fopen($file, "wb");
if (!$fp) {
    die("Unable to create file.");
}
fwrite($fp, $rawData);
fclose($fp);
