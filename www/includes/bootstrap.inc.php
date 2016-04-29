<?php
/**
 * This makes our life easier when dealing with paths. Everything is relative
 * to the application root now.
 */
$baseDir = dirname(dirname(__FILE__));
chdir($baseDir);

require 'includes/EnergyWatchdog/vendor/autoload.php';

//Set the default timezone
date_default_timezone_set('America/Sao_Paulo');

/*
use Psr\Log\LogLevel;
use HostWatchdog\LoggerFactory;
use HostWatchdog\HostWatchdog;

$dataPath = $baseDir . DIRECTORY_SEPARATOR . 'data';

LoggerFactory::init($dataPath, LogLevel::INFO, array(
    'filename' => 'events.log',
    'logFormat' => '[{date}] [{level}] {message}',
    'dateFormat' => 'Y-m-d H:i:s.u'
));

return new HostWatchdog($dataPath);
*/
