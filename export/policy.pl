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

policy();

$dbh->disconnect;


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

  open (PL, "bppllist |");
  while (<PL>) {
    chomp;
    $sPolicyName = $_;
  
    open (PA, "bpplinfo $sPolicyName -L |");      
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
  $sth = $dbh->prepare(
                 "BEGIN 
                    NetBackup.SetStorageUnit(
                      pSUName => :psuname,
											pISGroup => :pisgroup
                      pIsSLP => :pisslp);
                  END;") || die $dbh->errstr;

  $sth->bind_param(':psuname', $_[0]) || die $dbh->errstr;    
  $sth->bind_param(':pisgroup', 0) || die $dbh->errstr;    
  $sth->bind_param(':pisslp', 1) || die $dbh->errstr;    
   
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
