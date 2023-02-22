#!/usr/bin/perl -w
use strict;

use DBI;
use DBI qw(:sql_types);
use POSIX;
$ENV{"ORACLE_HOME"} = "/opt/oracle/product/11.2.0";
$ENV{"LD_LIBRARY_PATH"} = "/opt/oracle/product/11.2.0/lib";
$ENV{"NLS_LANG"} = "AMERICAN_AMERICA.CL8MSWIN1251"; 
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\10.2.0\\db_2";
#$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

host();

$dbh->disconnect;


#-------------
sub host
{
  my ($sHostName, $sFld, $sIP);
  my ($sOS, $sOSType);
  my ($sHostType, $sNBVersion, $sHostStatus);
  my $cBpConf = "/usr/openv/netbackup/bp.conf";
  my $sMD = "^MEDIA_SERVER";
  my $sMDGrep= "'" . $sMD . "'";
  my $cClientsDir = "/usr/openv/netbackup/db/images/";
  my (@FlStr, $nStr);

  open (HS, "bpclient -All -L |");
  while (<HS>) {
    $FlStr[0] = $_;
    for (my $i=1; $i<20; $i++) {
      $FlStr[$i] = <HS>;
    };
    ($sHostName) = ($FlStr[2] =~ /Hostname: (.*)/) ;
    ($sHostName, $sIP) = get_hostname_ip($sHostName);
#    print "HostName:$sHostName\n";
		save_host($sHostName, $sIP, "client");
  };
  close (HS);
 
  opendir(DIR0, $cClientsDir) || die "can't opendir $cClientsDir !";
  while (defined($sHostName = readdir(DIR0))) {
#    print "HostName:$sHostName\n";
    next if ($sHostName =~ /^\.\.?$/);
    ($sHostName, $sIP) = get_hostname_ip($sHostName);
    save_host($sHostName, $sIP, "client");
  }
  closedir(DIR0);

# nbemmcmd -listhosts -nbservers : masters & media
  open (MD, "nbemmcmd -listhosts -nbservers |");
  @FlStr = <MD>;
  close (MD);
  chomp(@FlStr);

  $nStr = @FlStr;
  for (my $i=2; $i<$nStr-1; $i++) {
    ($sHostType, $sHostName) = split(/\s+/, $FlStr[$i]);
#		print "$FlStr[$i]\n";
#    print "HostType:$sHostType HostName:$sHostName\n";
    ($sHostName, $sIP) = get_hostname_ip($sHostName);
#    print "HostName:$sHostName\n";
    save_host($sHostName, $sIP, $sHostType);
  };

  open (HS, "bpplclients -allunique -l |");
  @FlStr = <HS>;
  close (HS);
  chomp(@FlStr);

  $nStr = @FlStr;
  for (my $i=0; $i<$nStr; $i++) {
    (undef, $sHostName, $sOSType, $sOS) = split(/ /, $FlStr[$i]);
    ($sHostName) = get_hostname_ip($sHostName);
    set_host($sHostName, $sOS, $sOSType);
  };
  
};

#-------------
# = get_hostname_ip($sClient);
sub get_hostname_ip
{
  my ($oldName, @newNames);
  
    if (!defined($_[0]) or ($_[0] eq '') or ($_[0] =~ /\s+/)) {return ''};
    $oldName = $_[0];
    
    open (DIP, "bpclntcmd -hn $oldName |");
    my $sDIP = <DIP>;
    close (DIP);
    @newNames =  $sDIP =~ /.+: (.*) at (.*)/;
#    @newNames =  $sDIP =~ /.+: (.*) at (.*) \((.*)/;    
    if (defined($newNames[0])) {
#      print "oldName:$oldName newName:$newNames[0]\n";
			return @newNames
		}
    else {return ($oldName) };
}

#-------------
sub save_host
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetHost(
                      pName => :pname, 
                      pIP => :pip, 
                      pHostType => :phosttype);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pip', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':phosttype', $_[2]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  print "HostID:$RC\n";
}
#-------------
sub set_host
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetHost(
                      pName => :pname, 
                      pOS => :pos, 
                      pOSType => :postype);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pos', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':postype', $_[2]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  print "HostID:$RC\n";

};
