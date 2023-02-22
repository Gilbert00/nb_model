#!/usr/bin/perl -w
#
# version 2.8.3
#

use strict;
use Tie::IxHash;

my $All = "all";
my ($Rj, $dbg);

if (! defined($ARGV[0])) {
  $Rj = $All;
  $dbg = 0;
}
else {
  $Rj = $ARGV[0];
  $dbg = 1;
};


my %Procs;
tie %Procs, "Tie::IxHash";
%Procs =  (
  "set_date_update" => \&set_date_update,
  "retention" => \&retention,
  "host" => \&host,
  "robot_drive" => \&robot_drive,
  "path" => \&path,
  "volume_pool" => \&volume_pool,
  "media" => \&media,
  "storage_unit" => \&storage_unit,
  "slp" => \&slp,
  "policy" => \&policy,
  "scheduler" => \&scheduler,
  "job" => \&job

);

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

proc_one("set_date_update");

#print "\nProcedure:set_date_update\n";
#set_date_update();

if ($dbg) {
  proc_one($Rj);
}
else {
  foreach my $Ind (keys %Procs) {
	next if $Ind eq "set_date_update";
	proc_one($Ind);
  }
}

#if ($Rj == $All)  {
#  print "\nProcedure:retention\n";
#  retention();
#  print "\nProcedure:host\n";
#  host();
#  print "\nProcedure:robot_drive\n";
#  robot_drive();
#  print "\nProcedure:path\n";
#  path();
#  print "\nProcedure:volume_pool\n";
#  volume_pool();
#  print "\nProcedure:media\n";
#  media();
#  print "\nProcedure:storage_unit\n";
#  storage_unit();
#  print "\nProcedure:slp\n";
#  slp();
#  print "\nProcedure:policy\n";
#  policy();
#  print "\nProcedure:scheduler\n";
#  scheduler();
#  print "\nProcedure:job\n";
#  job();
##TO-DO image();
#}
#elsif ($Rj == "retention") {
#  print "\nProcedure:retention\n";
#  retention();
#}
#elsif ($Rj == "host") {
#  print "\nProcedure:host\n";
#  host();
#}
#elsif ($Rj == "robot_drive") {
#  print "\nProcedure:robot_drive\n";
#  robot_drive();
#}
#elsif ($Rj == "path") {
#  print "\nProcedure:path\n";
#  path();
#}
#elsif ($Rj == "volume_pool") {
#  print "\nProcedure:volume_pool\n";
#  volume_pool();
#}
#elsif ($Rj == "media") {
#  print "\nProcedure:media\n";
#  media();
#}
#elsif ($Rj == "storage_unit") {
#  print "\nProcedure:storage_unit\n";
#  storage_unit();
#}
#elsif ($Rj == "slp") {
#  print "\nProcedure:slp\n";
#  slp();
#}
#elsif ($Rj == "policy") {
#  print "\nProcedure:policy\n";
#  policy();
#}
#elsif ($Rj == "scheduler") {
#  print "\nProcedure:scheduler\n";
#  scheduler();
#}
#elsif ($Rj == "job") {
#  print "\nProcedure:job\n";
#  job();
#}
#else {
#  print "\nError rejim: $Rj";
#  print "\nValid rejims: '' retention host robot_drive path volume_pool media storage_unit slp policy scheduler job";
##  exit 1;
#}


$dbh->disconnect;

#-------------
sub proc_one
{ my $Proc = $_[0];
  print "\nProcedure:$Proc\n";
  $Procs{$Proc}->();
}

#-------------
sub set_date_update
{
  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetDateUpdate;
                  END;") || die $dbh->errstr;
  
  $sth->execute() || die $dbh->errstr;

}

#-------------
sub retention
{
  my $sRetentionFile = "/usr/openv/netbackup/db/config/user_retention";
#  my $sRetentionFile = "D:\\Kemper\\GVC\\Servers\\uxbkp\\netbackup\\To_Oracle\\user_retention";
  my ($sLine, $nMaxR, $kOne);
  my @Flds;
  my ($nInd, $nSecs, $nKvo, $sPeriod);
  my $iInd = 1;
  my $iSecs = 2;
  my $iKvo = 3;
  my $iPeriod = 5;
  my %hOne = (86400,"day", 604800,"week", 2678400,"month", 31536000, "year");
  
  open (RF, "$sRetentionFile") || die "Cannot open $sRetentionFile !";
  
  $sLine = <RF>;
  $sLine = <RF>;
  chomp($sLine);
  @Flds = split(/\s+/, $sLine);
  $nMaxR = $Flds[1]; 
  
  while (<RF>) {
    chomp;
    @Flds = split(/\s+/, $_);
    if (($Flds[0] ne "") && ($Flds[0] == 10)) {
      $iInd--;
      $iSecs--;
      $iKvo--;
      $iPeriod--;
    }
    $nInd = $Flds[$iInd];
    if ($nInd > $nMaxR) {last};
    $nSecs = $Flds[$iSecs];
    $nKvo = $Flds[$iKvo];
    if ($nKvo == -1) {
      $sPeriod = "infinity";
#      $sPeriod = $Flds[$iPeriod];      
    }
    elsif ($nKvo == 0) {
      $sPeriod = "expires immediately";
#      $sPeriod = $Flds[$iPeriod+1];
    }
    else {
      $kOne = $nSecs / $nKvo;
      $sPeriod = $hOne{$kOne};       
#      $sPeriod = $Flds[$iPeriod+1];    
    };
    
#    if (($sPeriod eq "day") || ($sPeriod eq "week") || ($sPeriod eq "month") || ($sPeriod eq "year"))
#      $sPeriod = $sPeriod . "s";
#    };
    
    save_retention($nInd, $nSecs, $nKvo, $sPeriod);
  }
    
  close (RF);
};

#-------------
sub save_retention
{
  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetRetention(
                      pInd => :pind, 
                      pSecs => :psecs, 
                      pKvo => :pkvo, 
                      pPeriod => :pperiod);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pind', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':psecs', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pkvo', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pperiod', $_[3]) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
};

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

  open (HS, "/usr/openv/netbackup/bin/admincmd/bpclient -All -L |");
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
  open (MD, "/usr/openv/netbackup/bin/admincmd/nbemmcmd -listhosts -nbservers |");
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

  open (HS, "/usr/openv/netbackup/bin/admincmd/bpplclients -allunique -l |");
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
# = get_robot_name($sRobotType, $iRobotNumber);
sub get_robot_name
{
  return $_[0]."(".$_[1].")" ;
}

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

  for ($i = 1; $i < $nVP; $i += 5 ) {
    ($sPoolName) = ($VPfile[$i+1] =~ /:\s+(.+)/);  
    ($sPoolDescr) = ($VPfile[$i+2] =~ /:\s+(.+)/);
#    print "sPoolName:$sPoolName sPoolDescr:$sPoolDescr\n";
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

#-------------
sub media
{
  my (@MDstr, $nRD);
  
  my $sDriveName;
  my $i;
  my ($sMediaID, $OP, $sMediaType, $sBarcode, $BP, $RobotHost, $RobotType, $RobotNumber, $iSlot,
      $SF, $sVolumeGroupName, $sVolumePoolName, $PoolN, $PrevPool, $iMounts, $MaxMounts, $Clean,
      $dCreated, $tCreated, $dTimeAss, $tTimeAss, $dFMount, $tFMount, $dLMount, $tLMount,
      $dExpir, $tExpir);
  my ($sMediaServerName,
      $iRetention, $iImage, $dLWrite, $tLWrite, $iKB, $iRestores,
      $iValidImage, $dLRead, $tLRead, $sStatus);
  my $iVolumeGroupID;
  my $blank = "-";
  my $nullDate = "00/00/0000";
  my ($sMH, $sMD);
  my $sStatus2;

  open (MD, "/usr/openv/volmgr/bin/vmquery -a -w |");
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
    
    if ($iSlot eq $blank) {$iSlot = ""};
    if ($RobotNumber eq $blank) {$RobotNumber = ""};
    if ($iMounts eq $blank) {$iMounts = 0};
    $iVolumeGroupID = save_volume_group($sVolumeGroupName, $sMediaType, $RobotNumber);
   
    save_media($sMediaID, $sBarcode, $iSlot, $iMounts, $dTimeAss, $tTimeAss, $dFMount, $tFMount, $dLMount, $tLMount,
               $dCreated, $tCreated, $dExpir, $tExpir, $iVolumeGroupID, $sVolumePoolName);
  }
  
  close (MD);
  
  open (MH, "/usr/openv/volmgr/bin/vmoprcmd -devmon |");
  while (defined($sMH = <MH>)) {
    for ($i=0; $i<4; $i++) {$sMH = <MH>;};
    chomp $sMH;
    
    while ($sMH !~ /^$/) {
      ($sMediaServerName) = ($sMH =~ /(\S*)/);
      ($sMediaServerName) = get_hostname_ip($sMediaServerName);    
#      print "MediaServerName:$sMediaServerName\n";
       
      open (MD, "/usr/openv/netbackup/bin/admincmd/bpmedialist -mlist -h $sMediaServerName |"); 
      while (defined ($sMD = <MD>)) {
        if ($sMD =~ /^Server Host/) {
          for ($i=0; $i<6; $i++) {$sMD = <MD>;};
        }
        chomp $sMD; 
#        print "MD0:$sMD\n";        
        ($sMediaID, $iRetention, $iImage, undef, undef, $dLWrite, $tLWrite, undef, $iKB, $iRestores ) = split(/\s+/, $sMD);
#        print "MediaID:$sMediaID, Retention:$iRetention, Image:$iImage, dLWrite:$dLWrite, tLWrite:$tLWrite, Restores:$iRestores\n";
        if ($dLWrite eq "N/A") {
          $dLWrite = $nullDate;
          $iKB = 0;
          $iRestores = 0;
        }  
        $sMD = <MD>;
        chomp $sMD;
#        print "MD1:$sMD\n";                
        (undef, $iValidImage, $dExpir, $tExpir, $dLRead, $tLRead, $sStatus) = split(/\s+/, $sMD);
# TODO  ($iValidImage, undef, undef, $dLRead, $tLRead, $sStatus) = ($sMD =~ /^\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(.+)/);
        if ($iValidImage eq "MPX") {$iValidImage = 0};
        if ($dExpir eq "INFINITY") {
          $sStatus = $dLRead if defined $dLRead;
          $sStatus2 = $tLRead if defined $tLRead;
          $tLRead = $dLRead;
          $dLRead = $tExpir;
          $dExpir = "01/19/2038";
          $tExpir = "06:14";
        }
        elsif ($dExpir eq "N/A") {
          $sStatus = $dLRead if defined $dLRead;
          $sStatus2 = $tLRead if defined $tLRead;
          $tLRead = $dLRead;          
          $dLRead = $tExpir;
          $dExpir = $nullDate;
          $tExpir = "";
        };

        if ($dLRead eq "N/A") {
          $dLRead = $nullDate;
          $sStatus2 = $sStatus if defined $sStatus;
          $sStatus = $tLRead;
          $tLRead = "";
        };
        $sStatus = "" unless defined $sStatus;
        $sStatus = "$sStatus $sStatus2" if defined $sStatus2;
#        $sStatus =~ s/^\s+(.*?)\s+$/$1/;
        
        set_media($sMediaID, $iRetention, $iImage, $dLWrite, $tLWrite, $iKB, $iRestores,
                  $iValidImage, $dLRead, $tLRead, $sStatus, $sMediaServerName,
                  $dExpir, $tExpir);
                   
        $sMD = <MD>;
        $sMD = <MD>;        
      };  
      close (MD);
      
      $sMH = <MH>;
      chomp $sMH;
    };
    last;
  };
  
  close (MH);

  
}

#-------------
sub save_volume_group
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetVolumeGroup(
                      pName => :pname, 
                      pMediaType => :pmediatype, 
                      pRobotNumber => :probotnumber);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pmediatype', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':probotnumber', $_[2]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  return $RC;
}

#-------------
sub save_media
{
  my $nullDate = "'00/00/0000'";
  
  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SaveMedia(
                      pMediaID => :pmediaid, 
                      pBarcode => :pbarcode, 
                      pSlot => :pslot, 
                      pMounts => :pmounts, 
                      pTimeassigned => CASE :pdtimeassigned WHEN $nullDate THEN null ELSE to_date(:pdtimeassigned||:pttimeassigned, 'MM/DD/YYYYHH24:MI') END,
                      pFirstMount => CASE :pdfirstmount WHEN $nullDate THEN null ELSE to_date(:pdfirstmount||:ptfirstmount, 'MM/DD/YYYYHH24:MI') END, 
                      pLastMount => CASE :pdlastmount WHEN $nullDate THEN null ELSE to_date(:pdlastmount||:ptlastmount, 'MM/DD/YYYYHH24:MI') END,
                      pCreated => CASE :pdcreated WHEN $nullDate THEN null ELSE to_date(:pdcreated||:ptcreated, 'MM/DD/YYYYHH24:MI') END,
                      pDateExpiration => CASE :pddateexpiration WHEN $nullDate THEN null ELSE to_date(:pddateexpiration||:ptdateexpiration, 'MM/DD/YYYYHH24:MI') END,
                      pVolumeGroupID => :pvolumegroupid, 
                      pVolumePoolName => :pvolumepoolname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pmediaid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pbarcode', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pslot', $_[2]) || die $dbh->errstr;
  $sth->bind_param(':pmounts', $_[3]) || die $dbh->errstr;
  $sth->bind_param(':pdtimeassigned', $_[4]) || die $dbh->errstr;
  $sth->bind_param(':pttimeassigned', $_[5]) || die $dbh->errstr;
  $sth->bind_param(':pdfirstmount', $_[6]) || die $dbh->errstr;
  $sth->bind_param(':ptfirstmount', $_[7]) || die $dbh->errstr;
  $sth->bind_param(':pdlastmount', $_[8]) || die $dbh->errstr;
  $sth->bind_param(':ptlastmount', $_[9]) || die $dbh->errstr;
  $sth->bind_param(':pdcreated', $_[10]) || die $dbh->errstr;
  $sth->bind_param(':ptcreated', $_[11]) || die $dbh->errstr;
  $sth->bind_param(':pddateexpiration', $_[12]) || die $dbh->errstr;
  $sth->bind_param(':ptdateexpiration', $_[13]) || die $dbh->errstr;
  $sth->bind_param(':pvolumegroupid', $_[14]) || die $dbh->errstr;
  $sth->bind_param(':pvolumepoolname', $_[15]) || die $dbh->errstr;
  
  $sth->execute() || die $dbh->errstr;

#  print "MediaID:$_[0]\n";
};

#-------------
sub set_media
#$sMediaID, $iRetention, $iImage, $dLWrite, $tLWrite, $iKB, $iRestores,
#$iValidImage, $dLRead, $tLRead, $sStatus, $sMediaServerName
{
  my $nullDate = "'00/00/0000'";

  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetMedia1(
                      pMediaID => :pmediaid, 
                      pRetention => :pretention, 
                      pImages => :pimages, 
                      pLastWritten => CASE :pdlastwritten WHEN $nullDate THEN null ELSE to_date(:pdlastwritten||:ptlastwritten, 'MM/DD/YYYYHH24:MI') END, 
                      pKilobytes => :pkilobytes,
                      pRestores => :prestores, 
                      pValidImages => :pvalidimages,
                      pLastRead => CASE :pdlastread WHEN $nullDate THEN null ELSE to_date(:pdlastread||:ptlastread, 'MM/DD/YYYYHH24:MI') END,
                      pMediaStatus => :pmediastatus,
                      pMediaServerName => :pmediaservername,
                      pDateExpiration => CASE :pdexpir WHEN $nullDate THEN null ELSE to_date(:pdexpir||:ptexpir, 'MM/DD/YYYYHH24:MI') END);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pmediaid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pretention', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pimages', $_[2]) || die $dbh->errstr;
  $sth->bind_param(':pdlastwritten', $_[3]) || die $dbh->errstr;
  $sth->bind_param(':ptlastwritten', $_[4]) || die $dbh->errstr;
  $sth->bind_param(':pkilobytes', $_[5]) || die $dbh->errstr;
  $sth->bind_param(':prestores', $_[6]) || die $dbh->errstr;
  $sth->bind_param(':pvalidimages', $_[7]) || die $dbh->errstr;
  $sth->bind_param(':pdlastread', $_[8]) || die $dbh->errstr;
  $sth->bind_param(':ptlastread', $_[9]) || die $dbh->errstr;
  $sth->bind_param(':pmediastatus', $_[10]) || die $dbh->errstr;
  $sth->bind_param(':pmediaservername', $_[11]) || die $dbh->errstr;
  $sth->bind_param(':pdexpir', $_[12]) || die $dbh->errstr;
  $sth->bind_param(':ptexpir', $_[13]) || die $dbh->errstr;
  
  $sth->execute() || die $dbh->errstr;
  
#  print "MediaID:$_[0]\n";
};

#-------------
sub storage_unit
{
  my (@SUstr, $nSU);
  
  my ($sSUName, $iIsGroup, $sDensity, $iFragSize, $iMaxDrives, $iMultiplex,
      $iRobot, $sMediaServerName, $sSUType);
  my ($sSUSubType, $sPath, $iCJobs, $iHWMark, $iLWMark, $sDiskPool);
  my ($i, $iStep);
  my $blank = "-";

  open (SU, "/usr/openv/netbackup/bin/admincmd/bpstulist -L |");
  @SUstr = <SU>;
  close (SU);
  chomp(@SUstr);
  $nSU = @SUstr;
#  print "nSU:$nSU\n";  
  
  $iIsGroup = 0;
  
	$i=0;
  while ($i < $nSU) {
#		print "i0:$i\n";
		($sSUName) = ($SUstr[$i+1] =~ /:\s+(\S*)/);
    ($sSUType) = ($SUstr[$i+2] =~ /:\s+(\S*)/);
#    print "i:$i; SUName:$sSUName; SUType:$sSUType\n";
		if ($sSUType eq "Disk") {
#        print "$SUstr[$i+3]\n";
				($sSUSubType) = ($SUstr[$i+3] =~ /:\s*(\w+)\s*\(\d+\)/);
#        print "SUSubType:$sSUSubType\n";
			if ($sSUSubType eq "Basic") {
#			if ($sSUSubType =~ /Basic/) {			
					$iStep = 17;
#					print "i:$i; Step:$iStep\n";
					($sMediaServerName) = ($SUstr[$i+4] =~ /:\s+(\S*)/);
					($sMediaServerName) = get_hostname_ip($sMediaServerName);
					($iCJobs) = ($SUstr[$i+5] =~ /:\s+(\S*)/);
					($sPath) = ($SUstr[$i+7] =~ /:\s+(\S*)/);
					($iFragSize) = ($SUstr[$i+9] =~ /:\s+(\w*)/);
					($iMultiplex) = ($SUstr[$i+10] =~ /:\s+(\w*)/);
					($iHWMark) = ($SUstr[$i+14] =~ /:\s+(\S*)/);
					($iLWMark) = ($SUstr[$i+15] =~ /:\s+(\S*)/);

					save_storage_unit10($sSUName, $iIsGroup, $sMediaServerName, $sSUType, $sSUSubType, $sPath, $iCJobs, $iFragSize, $iMultiplex, $iHWMark, $iLWMark);
			}
			elsif ($sSUSubType eq "DiskPool") {
#			elsif ($sSUSubType =~ /DiskPool/) {			
					$iStep = 20;
#					print "i:$i\n";
					($sMediaServerName) = ($SUstr[$i+4] =~ /:\s+(\S*)/);
					($sMediaServerName) = get_hostname_ip($sMediaServerName);
					($iCJobs) = ($SUstr[$i+5] =~ /:\s+(\S*)/);
					($iFragSize) = ($SUstr[$i+8] =~ /:\s+(\w*)/);
					($iMultiplex) = ($SUstr[$i+9] =~ /:\s+(\w*)/);
					($sDiskPool) = ($SUstr[$i+13] =~ /:\s+(\w*)/);

					save_storage_unit11($sSUName, $iIsGroup, $sMediaServerName, $sSUType, $sSUSubType, $iCJobs, $iFragSize, $iMultiplex, $sDiskPool);
			}
			else {print "Unknown SUSubType:$sSUSubType\n"};
		}
		elsif ($sSUType =~ /Media/) {
				$iStep = 10;
				($sMediaServerName) = ($SUstr[$i+3] =~ /:\s+(\S*)/);
				($sMediaServerName) = get_hostname_ip($sMediaServerName);
				($iMaxDrives) = ($SUstr[$i+4] =~ /:\s+(\w*)/);
				($sDensity) = ($SUstr[$i+6] =~ /:\s+(\w*)/);
				($iRobot) = ($SUstr[$i+7] =~ /.+\/\s*(\d+)/);
				($iFragSize) = ($SUstr[$i+8] =~ /:\s+(\w*)/);
				($iMultiplex) = ($SUstr[$i+9] =~ /:\s+(\w*)/);
				save_storage_unit0($sSUName, $iIsGroup, $sMediaServerName, $iMaxDrives, $sDensity, $iRobot, $iFragSize, $iMultiplex, $sSUType);
			}
		else {print "Unknown SUType:$sSUType\n"};

		$i += $iStep;
#		print "i1:$i\n";
	};

  my ($sGroupName, @Group, $nGR, $iGroupID);

  $iIsGroup = 1;

  open (SG, "/usr/openv/netbackup/bin/admincmd/bpstulist -go |");
  while (<SG>) {
    ($sGroupName, undef, @Group) = split;
    $iGroupID = save_storage_group($sGroupName, $iIsGroup);
    delete_storage_group($iGroupID);    
    
    $nGR = @Group;
    for ($i=0; $i<$nGR; $i++) {
      save_group_member($iGroupID, $Group[$i]);
    };
  };
  close (SG);
}

#-------------
# save_storage_unit0($sSUName, $iIsGroup, $sMediaServerName, $iMaxDrives, $sDensity, $iRobot, $iFragSize, $iMultiplex, $sSUType);
sub save_storage_unit0
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname, 
                      pISGroup => :pisgroup, 
                      pMediaServerName => :pmediaservername,
                      pMaxDrives => :pmaxdrives,
                      pDensity => :pdensity,
                      pRobot => :probot,
                      pFragSize => :pfragsize,
                      pMultiplex => :pmultiplex,
          					  pType => :ptype	); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pmediaservername', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pmaxdrives', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':pdensity', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':probot', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':pfragsize', $_[6]) || die $dbh->errstr;    
  $sth->bind_param(':pmultiplex', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[8]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  print "StorageUnitID:$RC\n";
 
  return $RC;
}

#-------------
# save_storage_unit10($sSUName, $iIsGroup, $sMediaServerName, $sSUType, $sSUSubType, $sPath, $iCJobs, $iFragSize, $iMultiplex, $iHWMark, $iLWMark);
sub save_storage_unit10
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname, 
                      pISGroup => :pisgroup, 
                      pMediaServerName => :pmediaservername,
					            pType => :ptype,
                      pSubType => :psubtype,
                      pPath => :ppath,
          					  pConcJobs => :pconcjobs,
					            pFragSize => :pfragsize,
                      pMultiplex => :pmultiplex,
                      pHighWMark => :phighwmark,
											pLowWMark => :plowwmark); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pmediaservername', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':psubtype', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':ppath', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':pconcjobs', $_[6]) || die $dbh->errstr;    
	$sth->bind_param(':pfragsize', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':pmultiplex', $_[8]) || die $dbh->errstr;    
  $sth->bind_param(':phighwmark', $_[9]) || die $dbh->errstr;    
  $sth->bind_param(':plowwmark', $_[10]) || die $dbh->errstr;    
	$sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  print "StorageUnitID:$RC\n";
 
  return $RC;
}

#-------------
# save_storage_unit11($sSUName, $iIsGroup, $sMediaServerName, $sSUType, $sSUSubType, $iCJobs, $iFragSize, $iMultiplex, $sDiskPool);
sub save_storage_unit11
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname, 
                      pISGroup => :pisgroup, 
                      pMediaServerName => :pmediaservername,
					            pType => :ptype,
                      pSubType => :psubtype,
          					  pConcJobs => :pconcjobs,
					            pFragSize => :pfragsize,
                      pMultiplex => :pmultiplex,
											pDiskPool => :pdiskpool); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pmediaservername', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':psubtype', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pconcjobs', $_[5]) || die $dbh->errstr;    
	$sth->bind_param(':pfragsize', $_[6]) || die $dbh->errstr;    
  $sth->bind_param(':pmultiplex', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':pdiskpool', $_[8]) || die $dbh->errstr;    
	$sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  print "StorageUnitID:$RC\n";
 
  return $RC;
}

#-------------
sub save_storage_group
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname, 
                      pISGroup => :pisgroup); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', $_[1]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  print "StorageGroupID:$RC\n";

  return $RC;
}

#-------------
sub save_group_member
{
#  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetStorageUnitInGroup(
                      pGroupID => :pgroupid, 
                      pMemberName => :pmembername); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pgroupid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pmembername', $_[1]) || die $dbh->errstr;    
#  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
#  return $RC;
}

#-------------
sub delete_storage_group
{
#  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelStorageUnitGroup(
                      pGroupID => :pgroupid); 
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pgroupid', $_[0]) || die $dbh->errstr;    
#  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
#  return $RC;
}

#-------------
sub slp 
{
  my (@SLPstr, $nSLP);

  my ($jStep, $iStep, $i, $j, $k);
  my ($iSLPID, $sSLPName, $iDupPriority, $sSLPState, $iSLPVersion);
	my ($sOperName, $sOperStorage, $sOperVolPool, $iRetentionType, $iRetentionID, $sReadServer, $sMultiplex, $sRemoteImport, 
		  $sOperState, $iOperSource, $iOperIndex, $sWindowName, $sWindowClose, $sDefDupl);

  $jStep = 16;
  $iStep = $jStep * 2 + 6;
  
  open (SLP, "/usr/openv/netbackup/bin/admincmd/nbstl -L |");
  @SLPstr = <SLP>;
  close (SLP);
  chomp(@SLPstr);
  $nSLP = @SLPstr;
#  print "nSLP:$nSLP\n";  

  for ($i = 0; $i < $nSLP; $i += $iStep) {
    ($sSLPName) = ($SLPstr[$i] =~ /:\s+(\S*)/);
    ($iDupPriority) = ($SLPstr[$i+2] =~ /:\s+(\d*)/);
    ($sSLPState) = ($SLPstr[$i+3] =~ /:\s+(\w*)/);
    ($iSLPVersion) = ($SLPstr[$i+4] =~ /:\s+(\d*)/);

    $iSLPID = save_slp($sSLPName, $iDupPriority, $sSLPState, $iSLPVersion);

    $k = $i + 5;

    del_slp_detail($iSLPID);

    for ($j = 0; $j < $jStep * 2; $j += $jStep) {
      ($sOperName) = ($SLPstr[$k+$j] =~ /:\s+\d+\s\((\w*)\)/);
      ($sOperStorage) = ($SLPstr[$k+$j+1] =~ /:\s+(\S*)/);
      ($sOperVolPool) = ($SLPstr[$k+$j+2] =~ /:\s+(\S*)/);
      ($iRetentionType) = ($SLPstr[$k+$j+4] =~ /:\s+(\d*)/);
      ($iRetentionID) = ($SLPstr[$k+$j+5] =~ /:\s+(\d*)/);
      ($sReadServer) = ($SLPstr[$k+$j+6] =~ /:\s+(\S*)|:\s\((.*)\)/);
      ($sMultiplex) = ($SLPstr[$k+$j+7] =~ /:\s+(\w*)/);
      ($sRemoteImport) = ($SLPstr[$k+$j+8] =~ /:\s+(\w*)/);
      ($sOperState) = ($SLPstr[$k+$j+9] =~ /:\s+(\w*)/);
      ($iOperSource) = ($SLPstr[$k+$j+10] =~ /:\s+(\d*)/);
      ($iOperIndex) = ($SLPstr[$k+$j+12] =~ /:\s+(\d*)/);
      ($sWindowName) = ($SLPstr[$k+$j+13] =~ /:\s+(\S*)/);
      ($sWindowClose) = ($SLPstr[$k+$j+14] =~ /:\s+(\S*)/);
      ($sDefDupl) = ($SLPstr[$k+$j+15] =~ /:\s+(\w*)/);

      $sReadServer = "" if $sReadServer eq "none specified";
			$sMultiplex = ($sMultiplex eq "false" ? 0 : 1);
      $sRemoteImport = ($sRemoteImport eq "false" ? 0 : 1);
      $sDefDupl = ($sDefDupl eq "no" ? 0 : 1);

      save_slp_detail($iSLPID, $sOperName, $sOperStorage, $sOperVolPool, $iRetentionType, $iRetentionID, $sReadServer, $sMultiplex, $sRemoteImport, 
		                  $sOperState, $iOperSource, $iOperIndex, $sWindowName, $sWindowClose, $sDefDupl);
		}
  }
}

#-------------
#    $iSLPID = save_slp($sSLPName, $iDupPriority, $sSLPState, $iSLPVersion);
sub save_slp
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetSLP(
                      pSLPName => :pslpname, 
                      pDupPriority => :pduppriority,
                      pState => :pstate,
                      pVersion => :pversion);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pslpname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pduppriority', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pstate', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pversion', $_[3]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

#  print "PolicyID:$RC\n";
  
  return $RC;
}

#-------------
sub del_slp_detail
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelSLPDetail(
                      pSLPID => :pslpid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pslpid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
#     save_slp_detail($iSLPID, $sOperName, $sOperStorage, $sOperVolPool, $iRetentionType, $iRetentionID, $sReadServer, $sMultiplex, $sRemoteImport, 
#		                  $sOperState, $iOperSource, $iOperIndex, $sWindowName, $sWindowClose, $sDefDupl);
sub save_slp_detail
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetSLPDetail(
											pSLPID => :pslpid, 
											pOperIndex => :poperindex, 
											pStorageName => :pstoragename, 
											pVolumePoolName => :pvolumepoolname, 
											pRetentionType => :pretentiontype, 
											pRetentionID => :pretentionid, 
											pAltReadName => :paltreadname, 
											pMultiplex => :pmultiplex, 
											pRemoteImport => :premoteimport, 
											pSourceIndex => :psourceindex, 
											pDefDuplication => :pdefduplication, 
											pOperName => :popername, 
											pState => :pstate, 
											pWindowName => :pwindowname, 
											pWindowClose => :pwindowclose);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pslpid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':popername', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pstoragename', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pvolumepoolname', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':pretentiontype', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pretentionid', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':paltreadname', $_[6]) || die $dbh->errstr;    
  $sth->bind_param(':pmultiplex', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':premoteimport', $_[8]) || die $dbh->errstr;    
  $sth->bind_param(':pstate', $_[9]) || die $dbh->errstr;    
  $sth->bind_param(':psourceindex', $_[10]) || die $dbh->errstr;    
  $sth->bind_param(':poperindex', $_[11]) || die $dbh->errstr;    
  $sth->bind_param(':pwindowname', $_[12]) || die $dbh->errstr;    
  $sth->bind_param(':pWindowClose', $_[13]) || die $dbh->errstr;    
  $sth->bind_param(':pdefduplication', $_[14]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub policy
{
  my (@PAstr, $nPA);
  
  my ($sType, $iJobpriority, $iMaxJobs, $iActive, $dActiveStart, $tActiveStart, $sKeyword,
      $iCompression, $iEncryption, $sVolumePoolName, $sStorageUnitName, $iBlockIncr, $iShapshotBK,
		  $sSnapshotMethod, $iOffshotBK, $sAltClientName, $iUseVM, $iIsSLP);
  my @Patterns = ("Policy Type", "Active", "Effective", "Client Compress", "Policy Priority", "Keyword",
                  "Client Encrypt", "Max Jobs\/Policy", "Residence", "Volume Pool", "Block Level Incremental", "Perform Snapshot Backup",
		              "Snapshot Method", "Perform Offhost Backup", "Alternate Client Name", "Use Virtual Machine", "Residence is storage lifecycle policy");
  my ($sPolicyName, $iPolicyID);
  my ($i, $d);
  my $blank = "-";
  my $sPolicyDir = "/usr/openv/netbackup/db/class/";
  my $sFileClients = "/clients";
  my $sFileSelection = "/includes";
  my $sSubdirSchedule = "schedule/";
  my ($sFullFileClients, $sClient, $sFullFileSelection, $sSelection);
  my $gr;

  open (PL, "/usr/openv/netbackup/bin/admincmd/bppllist |");
  while (<PL>) {
    chomp;
    $sPolicyName = $_;
  
    open (PA, "/usr/openv/netbackup/bin/admincmd/bpplinfo $sPolicyName -L |");      
    @PAstr = <PA>;
    close (PA);
    chomp(@PAstr);
#    $nPA = @PAstr;
#    for ($i=0; $i<$nPA; $i++) {
    ($gr) = (grep{/^$Patterns[0]:/} @PAstr);
    ($sType) = $gr =~ /^$Patterns[0]:\s+(\S+)/;

    ($gr) = (grep{/^$Patterns[1]:/} @PAstr);
    ($iActive) = $gr =~ /^$Patterns[1]:\s+(\S+)/;
    $iActive = ($iActive eq "yes" ? 1 : 0);

    ($gr) = (grep{/^$Patterns[2]:/} @PAstr);
    ($dActiveStart, $tActiveStart) = $gr =~ /^$Patterns[2]:\s+(\S+) (\S+)/;

    ($gr) = (grep{/^$Patterns[3]:/} @PAstr);
    ($iCompression) = $gr =~ /^$Patterns[3]:\s+(\S+)/;
    $iCompression = ($iCompression eq "no" ? 0 : 1);

    ($gr) = (grep{/^$Patterns[4]:/} @PAstr);
    ($iJobpriority) = $gr =~ /^$Patterns[4]:\s+(\S+)/;

    ($gr) = (grep{/^$Patterns[5]:/} @PAstr);
    if (defined $gr) {($sKeyword) = $gr =~ /^$Patterns[5]:\s+(\S+)/;}
    else {$sKeyword = "";};

    ($gr) = (grep{/^$Patterns[6]:/} @PAstr);
    ($iEncryption) = $gr =~ /^$Patterns[6]:\s+(\S+)/;
    $iEncryption = ($iEncryption eq "no" ? 0 : 1);

    ($gr) = (grep{/^$Patterns[7]:/} @PAstr);
    ($iMaxJobs) = $gr =~ /^$Patterns[7]:\s+(\S+)/;
    if ($iMaxJobs eq "Unlimited") {$iMaxJobs = 0};

    ($gr) = (grep{/^$Patterns[8]:/} @PAstr);
    ($sStorageUnitName) = $gr =~ /^$Patterns[8]:\s+(\S+)/;
    $sStorageUnitName = "" if $sStorageUnitName eq "-";
    
    ($gr) = (grep{/^$Patterns[9]:/} @PAstr);
    ($sVolumePoolName) = $gr =~ /^$Patterns[9]:\s+(\S+)/;

    ($gr) = (grep{/^$Patterns[16]:/} @PAstr);
    ($iIsSLP) = $gr =~ /^$Patterns[16]:\s+(\S+)/;
    $iIsSLP = ($iIsSLP eq "no" ? 0 : 1);
 #   }
    
    if ($sType eq "VMware") {
      ($gr) = (grep{/^$Patterns[10]:/} @PAstr);
      ($iBlockIncr) = $gr =~ /^$Patterns[10]:\s+(\S+)/;
      $iBlockIncr = ($iBlockIncr eq "no" ? 0 : 1);

      ($gr) = (grep{/^$Patterns[11]:/} @PAstr);
      ($iShapshotBK) = $gr =~ /^$Patterns[11]:\s+(\S+)/;
      $iShapshotBK = ($iShapshotBK eq "no" ? 0 : 1);

      ($gr) = (grep{/^$Patterns[12]:/} @PAstr);
      ($sSnapshotMethod) = $gr =~ /^$Patterns[12]:\s+(\S+)/;

      ($gr) = (grep{/^$Patterns[13]:/} @PAstr);
      ($iOffshotBK) = $gr =~ /^$Patterns[13]:\s+(\S+)/;
      $iOffshotBK = ($iOffshotBK eq "no" ? 0 : 1);

      ($gr) = (grep{/^$Patterns[14]:/} @PAstr);
      ($sAltClientName) = $gr =~ /^$Patterns[14]:\s+(\S+)/;

      ($gr) = (grep{/^$Patterns[15]:/} @PAstr);
      ($iUseVM) = $gr =~ /^$Patterns[15]:\s+(\S+)/;
    }
		
		$iPolicyID = save_policy($sPolicyName, $sType, $iActive, $dActiveStart, $tActiveStart, $iCompression, $iJobpriority, $iEncryption,
                             $sKeyword, $iMaxJobs, $sStorageUnitName, $sVolumePoolName, $iBlockIncr, $iShapshotBK,
                             $sSnapshotMethod, $iOffshotBK, $sAltClientName, $iUseVM);

    if ($iIsSLP == 1) {
      save_slp_as_su($sStorageUnitName);
    }

#  };
#  close (PL);

#  opendir(PL, $sPolicyDir) || die "can't opendir $sPolicyDir !";
#  while (defined($sPolicyName = readdir(PL))) {
#    next if ($sPolicyName =~ /^\.\.?$/);
#    $iPolicyID = get_policy_id($sPolicyName);

    del_client($iPolicyID);
    $sFullFileClients = $sPolicyDir . $sPolicyName . $sFileClients;
    if (open(CL, "$sFullFileClients")) {
      while (<CL>) {
        if (/^#/) {last};
        chomp;
        ($sClient) = (/^(\S+) /);
        ($sClient) = get_hostname_ip($sClient);
        save_client($iPolicyID, $sClient);
      }
      close(CL);
    }
    
    del_selection($iPolicyID);
    $sFullFileSelection = $sPolicyDir . $sPolicyName . $sFileSelection;
    if (open(SL, "$sFullFileSelection")) {
      $i = 0;
      while (<SL>) {
        chomp;
        $sSelection = $_;
        save_selection($iPolicyID, $i, $sSelection);
        $i++;
      }
      close(SL);
    }
  }
#  closedir(PL);
  close (PL);
  
}

#-------------
#		$iPolicyID = save_policy($sPolicyName, $sType, $iActive, $dActiveStart, $tActiveStart, $iCompression, $iJobpriority, $iEncryption,
#                             $sKeyword, $iMaxJobs, $sStorageUnitName, $sVolumePoolName, $iBlockIncr, $iShapshotBK
#                             $sSnapshotMethod, $iOffshotBK, $sAltClientName, $iUseVM);
sub save_policy
{
  my $nullDate = "'00/00/0000'";
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetPolicy(
                      pPolicyName => :ppolicyname, 
                      pType => :ptype,
                      pActive => :pactive,
                      pStarted => CASE :pdstarted WHEN $nullDate THEN null ELSE to_date(:pdstarted||:ptstarted, 'MM/DD/YYYYHH24:MI:SS') END,
                      pCompression => :pcompression,
                      pJobPriority => :pjobpriority,
                      pEncryption => :pencryption,
                      pKeyword => :pkeyword,
                      pMaxJobs => :pmaxjobs,
                      pStorageUnitName => :pstorageunitname,
                      pVolumePoolName => :pvolumepoolname,
                      pBlockIncr => :pblockincr,
                      pSnapshotBK => :psnapshotbk,
                      pSnapshotMethod => :psnapshotmethod,
                      pOffshotBK => :poffshotbk,
										  pAltClientName => :paltclientname,
                      pUseVM => :pusevm);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pactive', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pdstarted', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':ptstarted', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pcompression', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':pjobpriority', $_[6]) || die $dbh->errstr;    
  $sth->bind_param(':pencryption', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':pkeyword', $_[8]) || die $dbh->errstr;    
  $sth->bind_param(':pmaxjobs', $_[9]) || die $dbh->errstr;    
  $sth->bind_param(':pstorageunitname', $_[10]) || die $dbh->errstr;    
  $sth->bind_param(':pvolumepoolname', $_[11]) || die $dbh->errstr;    
  $sth->bind_param(':pblockincr', $_[12]) || die $dbh->errstr;    
  $sth->bind_param(':psnapshotbk', $_[13]) || die $dbh->errstr;    
  $sth->bind_param(':psnapshotmethod', $_[14]) || die $dbh->errstr;    
  $sth->bind_param(':poffshotbk', $_[15]) || die $dbh->errstr;    
  $sth->bind_param(':paltclientname', $_[16]) || die $dbh->errstr;    
  $sth->bind_param(':pusevm', $_[17]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

#  print "PolicyID:$RC\n";
  
  return $RC;
}

#-------------
#      save_slp_as_su($sStorageUnitName);
sub save_slp_as_su
{
  my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname,
		      pISGroup => :pisgroup,
                      pIsSLP => :pisslp);
                  END;") || die $dbh->errstr;

  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', 0) || die $dbh->errstr;    
  $sth->bind_param(':pisslp', 1) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub save_client
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetClient(
                      pPolicyID => :ppolicyid,
                      pClientName => :pclientname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pclientname', $_[1]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;

#  print "PolicyID:$_[0] ClientName:$_[1]\n";

}

#-------------
sub del_client
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelClient(
                      pPolicyID => :ppolicyid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub save_selection
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetSelection(
                      pPolicyID => :ppolicyid,
                      pLineID => :plineid,
                      pLine => :pline);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':plineid', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pline', $_[2]) || die $dbh->errstr;
  
  $sth->execute() || die $dbh->errstr;

#  print "PolicyID:$_[0] NLine:$_[1] Line:$_[2]\n";
}

#-------------
sub del_selection
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelSelection(
                      pPolicyID => :ppolicyid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub scheduler
{
  my (@SAstr, $nSA);
  
  my $iDuplPriority;
  
  my ($sBackupType, $iIsCalendar, $iFreqCount, @iRetention, $iMediaMult, $iCopies,
      @iFail, @sStorageUnitName, @sVolumePoolName);
  my @Patterns = ("Type", "Calendar sched", "Frequency", "Retention Level", "Maximum MPX", "Number Copies",
                  "Fail on Error", "Residence", "Volume Pool");

  my ($sPolicyName, $iPolicyID);
  my ($sSchedulerName, $iSchedulerID);
  my ($i, $d);
  my $blank = "-";
  my $sPolicyDir = "/usr/openv/netbackup/db/class/";
  my $sSubdirSchedule = "/schedule/";
  my $sFileCalendar = "/Calendar";
  my $sFileWindow = "/days";
  my $sFileInfo = "/info";
  my @sFailConst =  ('continue', 'fail all copies');

  my ($sFullDirScheduler, $sFullFileWindow, $sFullFileInfo);
  my ($iDay, $iStartSecs, $iDurationSecs);
  my ($gr, $str);

  opendir(PL, $sPolicyDir) || die "can't opendir $sPolicyDir !";
  while (defined($sPolicyName = readdir(PL))) {
    next if ($sPolicyName =~ /^\.\.?$/);
    $iPolicyID = get_policy_id($sPolicyName);

    $sFullDirScheduler = "$sPolicyDir$sPolicyName$sSubdirSchedule";
    if (! opendir(SC, "$sFullDirScheduler")) {next};
    while (defined($sSchedulerName = readdir(SC))) {
      next if ($sSchedulerName =~ /^\.\.?$/);

      open(SA, "/usr/openv/netbackup/bin/admincmd/bpplsched $sPolicyName -L -label $sSchedulerName |");
      @SAstr = <SA>;
      close(SA);    
      chomp(@SAstr);
      
      ($gr) = (grep{/$Patterns[0]:/} @SAstr);
      ($sBackupType) = $gr =~ /$Patterns[0]:\s+(\w+)/;

      ($gr) = (grep{/$Patterns[1]:/} @SAstr);
      if (defined $gr) {($iIsCalendar) = $gr =~ /$Patterns[1]:\s+(\w+)/}
      else {$iIsCalendar = undef};
      $iIsCalendar = defined($iIsCalendar);

      ($gr) = (grep{/$Patterns[2]:/} @SAstr);
      if (defined $gr) {($iFreqCount) = $gr =~ /$Patterns[2]:.+\((\d+) sec/}
      else {$iFreqCount = 0};

      ($gr) = (grep{/$Patterns[3]:/} @SAstr);
      @iRetention = $gr =~ /(?:$Patterns[3]:)?\s+(\d+) \(.+?\)/g;

      ($gr) = (grep{/$Patterns[4]:/} @SAstr);
      ($iMediaMult) = $gr =~ /$Patterns[4]:\s+(\d+)/;

      ($gr) = (grep{/$Patterns[5]:/} @SAstr);
      ($iCopies) = $gr =~ /$Patterns[5]:\s+(\d+)/;

      ($gr) = (grep{/$Patterns[6]:/} @SAstr);
      if (defined $gr) {@iFail = $gr =~ /(?:$Patterns[6]:)?\s+(\d+)/g}
      else {$iFail[0] = 0};

      ($gr) = (grep{/$Patterns[7]:/} @SAstr);
      ($str) = $gr =~ /$Patterns[7]:(.*)/;
      (undef, @sStorageUnitName) = split(/\s+/, $str);
      if ($sStorageUnitName[0] =~ /^\(/) {
        @sStorageUnitName = undef;
        $sStorageUnitName[0] = "";
      };

      ($gr) = (grep{/$Patterns[8]:/} @SAstr);
      ($str) = $gr =~ /$Patterns[8]:(.*)/;
      (undef, @sVolumePoolName) = split(/\s+/, $str);
      if ($sVolumePoolName[0] =~ /^\(/) {
        @sVolumePoolName = undef;
        $sVolumePoolName[0] = "";
      };

      $iSchedulerID = save_scheduler($iPolicyID, $sSchedulerName, $sBackupType, $iIsCalendar, $iFreqCount,
                                     $iMediaMult, $iCopies);

      del_copy($iSchedulerID);      
      for ($i=0; $i < $iCopies; $i++) {
        $iFail[$i] = @sFailConst[$iFail[$i]];
        save_copy($iSchedulerID, $i+1, $iRetention[$i], $iFail[$i], $sStorageUnitName[$i], $sVolumePoolName[$i]);
      }
      
      del_window($iSchedulerID);
      $sFullFileWindow = "$sFullDirScheduler$sSchedulerName$sFileWindow";
      if (open (WN, $sFullFileWindow)) {
        while (<WN>) {
          chomp; 
          ($iDay, $iStartSecs, $iDurationSecs) = split(/ /);  
          save_window($iSchedulerID, $iDay, $iStartSecs, $iDurationSecs);
        }
        close (WN);
      }

#TO-DO Calendar
#TO-DO ExcludeDate
    }
    closedir(SC);
  }
  closedir(PL);
  
}

#-------------
sub save_scheduler
{
   my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.SetScheduler(
                      pPolicyID => :ppolicyid,
                      pSchedulerName => :pschedulername,
                      pBackupType => :pbackuptype,
                      pIsCalendar => :piscalendar,
                      pFreqCount => :pfreqcount,
                      pMediaMult => :pmediamult,
                      pCopies => :pcopies);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pschedulername', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pbackuptype', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':piscalendar', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':pfreqcount', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pmediamult', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':pcopies', $_[6]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  print "SchedulerID:$RC\n";
  
  return $RC;
}

#-------------
sub save_copy
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetCopy(
                      pSchedulerID => :pschedulerid, 
                      pNumb => :pnumb,
                      pRetention => :pretention,
                      pFail => :pfail,
                      pStorageUnitName => :pstorageunitname,
                      pVolumePoolName => :pvolumepoolname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pschedulerid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pnumb', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pretention', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pfail', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':pstorageunitname', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pvolumepoolname', $_[5]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub del_copy
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelCopy(
                      pSchedulerID => :pschedulerid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pschedulerid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub save_window
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetWindow(
                      pSchedulerID => :pschedulerid, 
                      pDay => :pday,
                      pStartSecs => :pstartsecs,
                      pDurationsecs => :pdurationsecs);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pschedulerid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pday', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pstartsecs', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pdurationsecs', $_[3]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub del_window
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelWindow(
                      pSchedulerID => :pschedulerid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pschedulerid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
sub get_policy_id
{
   my $RC;

  $sth = $dbh->prepare(
                 "BEGIN  :rc :=
                    NetBackup.GetPolicyID(
                      pPolicyName => :ppolicyname);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':ppolicyname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;
  
  return $RC;
}

#-------------
sub job
{
  my @sJobTypes = qw (backup archive restore verify duplication import dbbackup vault label erase tpreq tpclean
                     tpformat vmphyinv dqts dbrecover mcontents image_cleanup LiveUpdate  empty0 AIR_Replication AIR_Import
		                 snap_Backup snap_Replication snap_Import appl_state_capture indexing index_cleanup Snapshot SnapIndex
		                 ActivateInstantRecovery DeactivateInstantRecovery ReactivateInstantRecovery StopInstantRecovery InstantRecovery);
  my @sJobStates =  ("queued", "active", "awaiting resources", "done", "suspended", "incomplete");
  my @sJobSubTypes = qw (immediate_backup scheduled_backup user-initiated_backup quick_erase_tape long_erase_tape database_backup_staging);
#TO-DO	my $sOperations =
  my (@JBstr, @JBflds, $nJB);
  my ($iID, $sType, $sState, $iStatus, $dStartTime, $dEndTime, $dActiveStart, $dActiveElapsed,
      $iAttempt, $iKilobytes, $iPID, $iKBsecs, $iFiles, $sOwner, $iCopy, $iParent, $sSubType, 
      $iSessionID, $iMediaEject, $sVaultProfileName,
      $sMediaServerName, $sClientName, $sPolicyName, $sSchedulerName, $sMasterName);
  
#  my $iDuplPriority;
  
#  my ($sBackupType, $iIsCalendar, $iFreqCount, @iRetention, $iMediaMult, $iCopies,
#      @iFail, @sStorageUnitName, @sVolumePoolName);
#  my @Patterns = ("Type", "Calendar sched", "Frequency", "Retention Level", "Maximum MPX", "Number Copies",
#                  "Fail on Error", "Residence", "Volume Pool");

  my $iPolicyID;
  my $iSchedulerID;
  my ($i, $j, $d, $nLine, $k, @LineSplit, $l);
  my $blank = "-";

  my ($sFullDirScheduler, $sFullFileWindow, $sFullFileInfo);
  my ($iDay, $iStartSecs, $iDurationSecs);
  my $fixEnd = 31; 
  my ($fileCount, $fileBeg, $fileEnd, $tryCount);
  my ($tryBeforeLine, @tryBeg, @tryLines, @tryEnd, @tryStartTime);
  my ($oldNLine, $oldState, $oldStatus);

  open (JB, "/usr/openv/netbackup/bin/admincmd/bpdbjobs -all_columns |");
#  @JBstr = <JB>;
#  foreach (reverse @JBstr) {
  while (<JB>) {
#   search , with before isn't \ or is \\
		@JBflds = split(/(?<=[^\\]),|(?<=[^\\][\\]{2}),/);     
    
    $iID = $JBflds[0];
    $sType =  $JBflds[1];
    $sState = $JBflds[2];
    $iStatus = $JBflds[3];
    $sPolicyName = $JBflds[4];
    $sSchedulerName = $JBflds[5];
    $sClientName = $JBflds[6];
    $sMediaServerName = $JBflds[7];
    $dStartTime = $JBflds[8];
    $dEndTime = $JBflds[10];
#    $dActiveStart
#    $dActiveElapsed,
    $iAttempt = $JBflds[12];
#TO-DO   $sOperation = $JBflds[13];
    $iKilobytes = $JBflds[14];
#    $iKBsecs,
    $iFiles = $JBflds[15];
    $iPID = $JBflds[18];
    $sOwner = $JBflds[19];
    $sSubType = $JBflds[20];
#TO-DO    $sScheduleType = $JBflds[22];
#TO-DO    $iCopy = $JBflds[0];
#    $iParent, 
#    $iSessionID,
#    $iMediaEject,
#    $sVaultProfileName,
    $sMasterName = $JBflds[25];

    $sType = $sJobTypes[$sType];
    $sState = $sJobStates[$sState];
    $sSubType = $sJobSubTypes[$sSubType] if ($sSubType ne '');
    $dStartTime = ctime_date($dStartTime);
    $dEndTime = ctime_date($dEndTime);
    ($sMediaServerName) = get_hostname_ip($sMediaServerName);
    ($sClientName) = get_hostname_ip($sClientName);
    ($sMasterName) = get_hostname_ip($sMasterName);

    $fileCount = $JBflds[$fixEnd];
    $fileBeg = $fixEnd + 1;
    $fileEnd = $fixEnd + $fileCount;
    $tryCount = $JBflds[$fileEnd + 1];

    $nLine = 0;
    $tryBeforeLine = $fileEnd;
    for ($i=0; $i<$tryCount; $i++) {
      if ($i == 0) {$tryBeforeLine += 10}
      else {$tryBeforeLine += 11};
      
      $tryStartTime[$i] = $JBflds[$tryBeforeLine - 5];  
      $tryLines[$i] = $JBflds[$tryBeforeLine];
      $nLine += $tryLines[$i];
      $tryBeg[$i] = $tryBeforeLine + 1;
      $tryEnd[$i] = $tryBeg[$i] + $tryLines[$i] - 1;

      if ($i == $tryCount-1) {$iKBsecs = $JBflds[$tryEnd[$i] + 4]};     
      
      $tryBeforeLine = $tryEnd[$i];     
    };
    
    $iKBsecs = 0 if (!defined($iKBsecs) or ($iKBsecs eq ''));
    
    ($oldNLine, $oldState, $oldStatus) = split(/\s+/, get_job_state($iID));
    save_job($iID, $sType, $sState, $iStatus, $dStartTime, $dEndTime, 
             $iAttempt, $iKilobytes, $iPID, $iFiles, $sOwner, 
             $sMediaServerName, $sClientName, $sPolicyName, $sSchedulerName, $sMasterName, $iKBsecs);

#!!!    if (($nLine != $oldNLine) or ($sState ne nvl($oldState, '')) or ($iStatus != nvl($oldStatus, -1))) {
      del_job_detail($iID);
      
      for ($i=0; $i<$tryCount; $i++) {
		$k = 0;
        for ($j=0; $j < $tryLines[$i]; $j++) {
		  @LineSplit = split(/ ?(?=(?:dd\/dd\/dddd))/g, $JBflds[$tryBeg[$i] + $j]);
		  for ($l=0; $l < scalar(@LineSplit); $l++) {
  			if (defined($LineSplit[$l]) and $LineSplit[$l] ne '') {
              save_job_detail($iID, $i+1, $k, $LineSplit[$l]); 
		      $k++;
			}
		  }
        }
      }
#!!!    }
  }
  close (JB);
}

#-------------
sub save_job
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetJob(
                      paramID => :pid, 
                      pType => :ptype,
                      pState => :pstate,
                      pStatus => :pstatus,
                      pStartTime => to_date(:pstarttime, 'YYYYMMDD_HH24:MI:SS'),
                      pEndTime => to_date(:pendtime, 'YYYYMMDD_HH24:MI:SS'),
                      pAttempt => :pattempt,
                      pKilobytes => :pkilobytes,
                      pPID => :ppid,
                      pFiles => :pfiles,
                      pOwner => :powner,
                      pMediaServerName => :pmediaservername, 
                      pClientName => :pclientname,
                      pPolicyName => :ppolicyname,
                      pSchedulerName => :pschedulername,
                      pMasterName => :pmastername,
                      pKBsecs => :pkbsecs);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':ptype', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pstate', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':pstatus', $_[3]) || die $dbh->errstr;    
  $sth->bind_param(':pstarttime', $_[4]) || die $dbh->errstr;    
  $sth->bind_param(':pendtime', $_[5]) || die $dbh->errstr;    
  $sth->bind_param(':pattempt', $_[6]) || die $dbh->errstr;    
  $sth->bind_param(':pkilobytes', $_[7]) || die $dbh->errstr;    
  $sth->bind_param(':ppid', $_[8]) || die $dbh->errstr;    
  $sth->bind_param(':pfiles', $_[9]) || die $dbh->errstr;    
  $sth->bind_param(':powner', $_[10]) || die $dbh->errstr;    
  $sth->bind_param(':pmediaservername', $_[11]) || die $dbh->errstr;    
  $sth->bind_param(':pclientname', $_[12]) || die $dbh->errstr;    
  $sth->bind_param(':ppolicyname', $_[13]) || die $dbh->errstr;    
  $sth->bind_param(':pschedulername', $_[14]) || die $dbh->errstr;    
  $sth->bind_param(':pmastername', $_[15]) || die $dbh->errstr;    
  $sth->bind_param(':pkbsecs', $_[16]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
  
#  print "JobID:$_[0]\n";
}

#-------------
sub get_job_state
{
   my $RC;

  $sth = $dbh->prepare(
                 "BEGIN :rc :=
                    NetBackup.GetJobState(
                      pJobID => :pjobid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pjobid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param_inout(':rc', \$RC, 64, SQL_VARCHAR) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  return $RC;
}

#-------------
sub save_job_detail
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetJobDetail(
                      pJobID => :pjobid,
                      pTry => :ptry,
                      pNLine => :pnline,
                      pLineStr => :plinestr);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pjobid', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':ptry', $_[1]) || die $dbh->errstr;    
  $sth->bind_param(':pnline', $_[2]) || die $dbh->errstr;    
  $sth->bind_param(':plinestr', $_[3]) || die $dbh->errstr;
  
  $sth->execute() || die $dbh->errstr;

#  print "JobID:$_[0] Try:$_[1] NLine:$_[2] Str:$_[3]\n";
}

#-------------
sub del_job_detail
{
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.DelJobDetail(
                      pJobID => :pjobid);
                  END;") || die $dbh->errstr;
  
  $sth->bind_param(':pjobid', $_[0]) || die $dbh->errstr;    
   
  $sth->execute() || die $dbh->errstr;
}

#-------------
# = get_hostname_ip($sClient);
sub get_hostname_ip
{
  my ($oldName, @newNames);
  
    if (!defined($_[0]) or ($_[0] eq '') or ($_[0] =~ /\s+/)) {return ''};
    $oldName = $_[0];
    
    open (DIP, "/usr/openv/netbackup/bin/bpclntcmd -hn $oldName |");
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
sub ctime_date
{
  my ($secs, $min, $hour, $day, $month, $year, $date);

  ($secs, $min, $hour, $day, $month, $year) = localtime($_[0]);
  $year += 1900;
  $month += 1;

  $date = sprintf("%04d%02d%02d_%02d:%02d:%02d", $year, $month, $day, $hour, $min, $secs);

  return $date; 
}

#------------
sub nvl
{
  if (defined $_[0]) {return $_[0]}
  else {return $_[1]};
}
