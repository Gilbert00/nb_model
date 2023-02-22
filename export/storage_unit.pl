#!/usr/bin/perl -w
use strict;

use DBI;
use DBI qw(:sql_types);
use POSIX;

$ENV{"ORACLE_HOME"} = "/opt/oracle/product/11.2.0";
$ENV{"NLS_LANG"} = "AMERICAN_AMERICA.CL8MSWIN1251";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\11.1.0\\client1";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\10.2.0\\db_2";
#$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

storage_unit();

$dbh->disconnect;


#-------------
sub storage_unit
{
  my (@SUstr, $nSU);
  
  my ($sSUName, $iIsGroup, $sDensity, $iFragSize, $iMaxDrives, $iMultiplex,
      $iRobot, $sMediaServerName, $sSUType);
  my ($sSUSubType, $sPath, $iCJobs, $iHWMark, $iLWMark, $sDiskPool);
  my ($i, $iStep);
  my $blank = "-";

  open (SU, "bpstulist -L |");
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

  open (SG, "bpstulist -go |");
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
    if (defined($newNames[0])) {return @newNames}
    else {return ($oldName) };
}

#-------------
