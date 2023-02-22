#!/usr/bin/perl -w
use strict;

use DBI;
use DBI qw(:sql_types);
use POSIX;

$ENV{"ORACLE_HOME"} = "/opt/oracle/product/11.1.0";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\11.1.0\\client1";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\10.2.0\\db_2";
#$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

volume_pool();

$dbh->disconnect;


#-------------
sub volume_pool
{
  my (@VPfile, $nVP);
  
  my $sDriveName;
  my $i;
  my ($sPoolName, $sPoolDescr);

  open (VP, "/usr/openv/volmgr/bin/vmpool -list_all |");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 1; $i < $nVP; $i += 7 ) {
    ($sPoolName) = ($VPfile[$i+1] =~ /:\s+(.+)/);  
    ($sPoolDescr) = ($VPfile[$i+2] =~ /:\s+(.+)/);
    save_volume_pool($sPoolName, $sPoolDescr);
  };

  open (VP, "/usr/openv/volmgr/bin/vmpool -list_scratch |");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 2; $i < $nVP; $i++ ) {
    $sPoolName = $VPfile[$i];  
    set_scratch_pool($sPoolName);
  };

  open (VP, "/usr/openv/volmgr/bin/vmpool -list_catalog_backup |");  
  @VPfile = <VP>;
  close (VP);
  
  $nVP = @VPfile;
  chomp(@VPfile);

  for ($i = 2; $i < $nVP; $i++ ) {
    $sPoolName = $VPfile[$i];  
    set_catalog_pool($sPoolName);
  };
 
}

#-------------
sub save_volume_pool
{
  my $RC;
 
  $sth = $dbh->prepare(
                 "BEGIN :rc :=
                    NetBackup.SetVolumePool(
                      pName => :pname, 
                      pDescr => :pdescr);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pdescr', $_[1]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
};

#-------------
sub set_scratch_pool
{
  my $RC;
 
  $sth = $dbh->prepare(
                 "BEGIN :rc :=
                    NetBackup.SetScratchPool(
                      pName => :pname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
};

#-------------
sub set_catalog_pool
{
  my $RC;
 
  $sth = $dbh->prepare(
                 "BEGIN :rc :=
                    NetBackup.SetCatalogPool(
                      pName => :pname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
};
