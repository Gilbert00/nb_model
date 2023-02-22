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

path();

$dbh->disconnect;


#-------------
sub path
{
  my (@RDfile, $nRD);
  
  my $sDriveName;
  my $i;
  my ($sFict,$sHostName, $sDrivePath, $sStatus, $sType);

  open (RD, "/usr/openv/volmgr/bin/vmoprcmd -devmon |");  
  @RDfile = <RD>;
  close (RD);
  
  $nRD = @RDfile;
  chomp(@RDfile);

  $i = 0;
  while ($RDfile[$i] !~ /^Drive Name/) {$i++};
  
  $i += 3;
  while ($i < $nRD) {
    ($sDriveName, undef, undef, undef, $sType) = split(/\s+/, $RDfile[$i]);
    $i++;
    while (nvl($RDfile[$i], "") ne "") {
      (undef, $sHostName, $sDrivePath, $sStatus) = split(/\s+/, $RDfile[$i]);
      ($sHostName) = get_hostname_ip($sHostName);
      save_path ($sDriveName,  $sHostName, $sDrivePath, $sStatus, $sType);
      $i++;          
    };
    $i++;
  };
}

#-------------
sub get_hostname_ip
{
  my ($oldName, @newNames);
  
    if (!defined($_[0]) or ($_[0] eq '') or ($_[0] =~ /\s+/)) {return ''};
    $oldName = $_[0];
    
    open (DIP, "bpclntcmd -hn $oldName |");
    my $sDIP = <DIP>;
    close (DIP);
    @newNames =  $sDIP =~ /.+: (.*) at (.*) \((.*)/;
    if (defined($newNames[0])) {return @newNames}
    else {return ($oldName) };
}

#-------------
sub save_path
{
  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetPath(
                      pDriveName => :pdrivename, 
                      pHostName => :phostname, 
                      pDrivePath => :pdrivepath, 
                      pStatus => :pstatus,
                      pType => :ptype);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pdrivename', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':phostname', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pdrivepath', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pstatus', $_[3]) || die $dbh->errstr;
  $sth->bind_param(':ptype', $_[4]) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
};

#------------
sub nvl
{
  if (defined $_[0]) {return $_[0]}
  else {return $_[1]};
}
