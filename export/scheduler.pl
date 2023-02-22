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

scheduler();

$dbh->disconnect;


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

      open(SA, "bpplsched $sPolicyName -L -label $sSchedulerName |");
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
