#!/usr/bin/perl -w
use strict;

use POSIX;

volume_pool_set();

#-------------
sub volume_pool_set
{
  my (@VPfile, $nVP);
  
  my $sDriveName;
  my $i;
  my ($sPoolName, $sPoolDescr);

  open (VP, "vmpool_all.out");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 1; $i < $nVP; $i += 5 ) {
    ($sPoolName) = ($VPfile[$i+1] =~ /:\s+(.+)/);  
    ($sPoolDescr) = ($VPfile[$i+2] =~ /:\s+(.+)/);
    $sPoolDescr = "" if ! defined $sPoolDescr;
    print "PoolName:$sPoolName PoolDescr:$sPoolDescr\n";
    save_volume_pool($sPoolName, $sPoolDescr);
  };

  open (VP, "vmpool_scratch.out");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 2; $i < $nVP; $i++ ) {
    $sPoolName = $VPfile[$i];  
    print "PoolScratch:$sPoolName\n";    
    set_scratch_pool($sPoolName);
  };

  open (VP, "vmpool_catalog.out");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 2; $i < $nVP; $i++ ) {
    $sPoolName = $VPfile[$i];  
    print "PoolCatalog:$sPoolName\n";        
    set_catalog_pool($sPoolName);
  };
 
}

#-------------
#    save_volume_pool($sPoolName, $sPoolDescr);
sub save_volume_pool
{
  my $RC;
  my ($sPoolName, $sPoolDescr); 
  
  $sPoolName = $_[0];
  $sPoolDescr = $_[1];
  ($RC = system("/usr/openv/volmgr/bin/vmpool -create -pn $sPoolName -description \"$sPoolDescr\"")) && die "Cannot create pool $sPoolName!";

};

#-------------
#    set_scratch_pool($sPoolName);
sub set_scratch_pool
{
  my $RC;
  my $sPoolName; 

  $sPoolName = $_[0];
  ($RC = system("/usr/openv/volmgr/bin/vmpool -set_scratch $sPoolName")) && die "Cannot set scratch pool $sPoolName!";
 
};

#-------------
#    set_catalog_pool($sPoolName);
sub set_catalog_pool
{
  my $RC;
  my $sPoolName; 
 
  $sPoolName = $_[0];
  ($RC = system("/usr/openv/volmgr/bin/vmpool -set_catalog_backup $sPoolName")) && die "Cannot set catalog pool $sPoolName!";

};
