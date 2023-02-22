#!/usr/bin/perl -w
use strict;

my ($secs, $min, $hour, $day, $month, $year, $date);

($secs, $min, $hour, $day, $month, $year) = localtime(1267812016);
$year += 1900;
$month += 1;

$date = sprintf("%04d%02d%02d_%02d:%02d:%02d", $year, $month, $day, $hour, $min, $secs);

print "$date\n";

