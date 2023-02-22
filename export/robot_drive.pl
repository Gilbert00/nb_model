#!/usr/bin/perl -w
use strict;

use DBI;
use DBI qw(:sql_types);
use POSIX;

$ENV{"ORACLE_HOME"} = "/opt/oracle/product/11.2.0";
$ENV{"LD_LIBRARY_PATH"} = "/opt/oracle/product/11.2.0/lib";
$ENV{"NLS_LANG"} = "AMERICAN_AMERICA.CL8MSWIN1251";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\11.1.0\\client1";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\10.2.0\\db_2";
#$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

robot_drive();

$dbh->disconnect;


#-------------
sub robot_drive
{
  my (@RDfile, $nRD, $s);
  my $sHostName;
  my ($sRobotName, $sRobotType, $sRobotPath);
  my $iRobotNumber;
  my ($i, $j, $iStep, $iLastDriveStr);
  my ($sName, $sType, $iRDNumber, $sSerial, $sInquiry, $sDrivePath);

# /usr/openv/volmgr/bin/tpconfig -emm_dev_list
# /usr/openv/volmgr/bin/tpconfig -emm_dev_list -noverbose
	
	open (RD, "/usr/openv/volmgr/bin/tpconfig -emm_dev_list |");  
  @RDfile = <RD>;
  close (RD);

  $nRD = @RDfile;
  chomp(@RDfile);

	$i=0;
  while ($i < $nRD){
    $j = $i+1;
		if ($RDfile[$j] =~ /^Robot:/) {
			$iStep = 22;
  		($iRobotNumber) = ($RDfile[$j+1] =~ /:\s+(\S*)/);
  		($sRobotType) = ($RDfile[$j+2] =~ /:\s+(\S*)\(/);
  		($sHostName) = ($RDfile[$j+3] =~ /:\s+(\S*)/);
      ($sRobotPath) = ($RDfile[$j+11] =~ /:\s+(\S*)/);
			($sSerial) = ($RDfile[$j+14] =~ /:\s+(\S*)/);
			($sInquiry) = ($RDfile[$j+15] =~ /:\s+(\S*)/);
      $sRobotName = get_robot_name($sRobotType, $iRobotNumber);
			if ($sRobotPath ne "-") {
   	    ($sHostName) = get_hostname_ip($sHostName);
        save_robot($iRobotNumber, $sRobotName, $sRobotType, $sHostName, $sRobotPath);
			}
		}
		elsif ($RDfile[$j] =~ /^Drive:/) {
			$iStep = 50;
  		($sName) = ($RDfile[$j] =~ /:\s+(\S*)/);
			($iRDNumber) = ($RDfile[$j+1] =~ /:\s+(\S*)/);
      ($sType) = ($RDfile[$j+2] =~ /:\s+(\S*)\(/);
			($sHostName) = ($RDfile[$j+3] =~ /:\s+(\S*)/);
	    ($sHostName) = get_hostname_ip($sHostName);
  		($sRobotType) = ($RDfile[$j+9] =~ /:\s+(\S*)\(/);
 			($iRobotNumber) = ($RDfile[$j+10] =~ /:\s+(\S*)/);
			($sDrivePath) = ($RDfile[$j+33] =~ /:\s+(\S*)/);
			($sSerial) = ($RDfile[$j+40] =~ /:\s+(\S*)/);
      $sRobotName = get_robot_name($sRobotType, $iRobotNumber);
      save_drive($sRobotName, $sName, $sType, $iRDNumber, $sSerial, $sHostName, $sDrivePath);
		}
    else {last};

		$i += $iStep;
  }
};

#-------------
sub save_robot
{
  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetRobot(
                      pRobotNumber => :probotnumber,
                      pRobotName => :probotname,
                      pRobotType => :probottype,
                      pHostName => :phostname,
                      pRobotPath => :probotpath);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':probotnumber', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':probotname', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':probottype', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':phostname', $_[3]) || die $dbh->errstr;
  $sth->bind_param(':probotpath', $_[4]) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  print "RobotN:$_[0]\n";

};

#-------------
sub save_drive
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetDrive(
                      pRobotName => :probotname,
                      pName => :pname,
                      pType => :ptype,
                      pRDNumber => :prdnumber,
                      pSerial => :pserial,
                      pHostName => :phostname,
                      pDrivePath => :pdrivepath);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':probotname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pname', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':prdnumber', $_[3]) || die $dbh->errstr;
  $sth->bind_param(':pserial', $_[4]) || die $dbh->errstr;
  $sth->bind_param(':phostname', $_[5]) || die $dbh->errstr;
  $sth->bind_param(':pdrivepath', $_[6]) || die $dbh->errstr;
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  print "DriveID:$RC\n";

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
# = get_robot_name($sRobotType, $iRobotNumber);
sub get_robot_name
{
  return $_[0]."(".$_[1].")" ;
}

