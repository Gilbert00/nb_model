#!/usr/bin/perl -w
#
# pool_change.pl <PoolTo> [<PoolFrom>]
#
use strict;

  my $nArgs = scalar @ARGV;
  my $sPoolTo;
  my (@MDstr, $nRD);
  
  my $sDriveName;
  my $i;
  my ($sMediaID, $OP, $sMediaType, $sBarcode, $BP, $RobotHost, $RobotType, $RobotNumber, $iSlot,
      $SF, $sVolumeGroupName, $sVolumePoolName, $PoolN, $PrevPool, $iMounts, $MaxMounts, $Clean,
      $dCreated, $tCreated, $dTimeAss, $tTimeAss, $dFMount, $tFMount, $dLMount, $tLMount,
      $dExpir, $tExpir);
  my ($sMH, $sMD);
  my $sStatus2;

  if ($nArgs >= 1) {
  	$sPoolTo = $ARGV[0];
		print "PoolTo:$sPoolTo\n";
	}
  else {
		print "All pools\n";
	}

  open (MD, "vmquery.out");
	for ($i=0; $i<3; $i++) {
    <MD>;
  }

  while (<MD>) {
    chomp;
    ($sMediaID, $OP, $sMediaType, $sBarcode, $BP, $RobotHost, $RobotType, $RobotNumber, $iSlot,
     $SF, $sVolumeGroupName, $sVolumePoolName, $PoolN, $PrevPool, $iMounts, $MaxMounts, $Clean,
     $dCreated, $tCreated, $dTimeAss, $tTimeAss, $dFMount, $tFMount, $dLMount, $tLMount,
     $dExpir, $tExpir)
    = split(/\s+/);
    
    next if $RobotType eq "NONE";
    
    if (($nArgs == 0) || ($sPoolTo eq $sVolumePoolName)) {
      print "PoolTo:$sVolumePoolName Media:$sMediaID\n";
      pool_change($PoolN, $sMediaID);
    };
  }
  
  close (MD);

#-------------
sub pool_change
# pool_change($nPool, $sMedia);
{
  my $RC;
  my ($nPool, $sMedia); 
  
  $nPool = $_[0];
  $sMedia = $_[1];
  ($RC = system("/usr/openv/volmgr/bin/vmchange -p $nPool -m $sMedia")) && die "Cannot change pool to $nPool for media $sMedia!";
};
