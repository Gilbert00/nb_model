#!/usr/bin/perl -w
use strict;
#my $gr = "  Residence:       uxbkp-hcart3-robot-tld-0 uxbkp-hcart3-robot-tld-0";
#my $Pattern = "Residence";
my $gr = "  Volume Pool:     Archive Archive";
my $Pattern = "Volume Pool";
my (@iFail, $str);

($str) = $gr =~ /$Pattern:(.*)/;
(undef, @iFail) = split(/\s+/, $str);
print @iFail;

