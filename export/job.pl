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

my $dbg = 1;

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

job();

$dbh->disconnect;


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
#  my $fixEnd = 42;   
  my ($fileCount, $fileBeg, $fileEnd, $tryCount);
  my ($tryBeforeLine, @tryBeg, @tryLines, @tryEnd, @tryStartTime);
  my ($oldNLine, $oldState, $oldStatus);

  open (JB, "/usr/openv/netbackup/bin/admincmd/bpdbjobs -all_columns |");
#  open (JB, "<job-710308.out");
#  open (JB, "<job-711000.out");  
#  open (JB, "<job-713390.out");    
#  @JBstr = <JB>;
#  foreach (reverse @JBstr) {
  while (<JB>) {
#   search , with before isn't \ or is \\
		@JBflds = split(/(?<=[^\\]),|(?<=[^\\][\\]{2}),/);     

#    foreach  $i (@JBflds) { print "\n$i"}
    for($i=1; $i<=(scalar @JBflds); $i++) {print "$i:$JBflds[$i-1]\n"} if ($dbg);
    
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
  
  print "JobID:$_[0]\n";
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

  print "JobID:$_[0] Try:$_[1] NLine:$_[2] Str:$_[3]\n";
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
#	@newNames =  $sDIP =~ /.+: (.*) at (.*) \((.*)/;
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
