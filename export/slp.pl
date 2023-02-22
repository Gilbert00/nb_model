#!/usr/bin/perl -w
use strict;
use warnings;

use DBI;
use DBI qw(:sql_types);
use POSIX;

$ENV{"ORACLE_HOME"} = "/opt/oracle/product/11.2.0";
$ENV{"NLS_LANG"} = "AMERICAN_AMERICA.CL8MSWIN1251";
#$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

slp();

$dbh->disconnect;

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
  
  open (SLP, "nbstl -L |");
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
