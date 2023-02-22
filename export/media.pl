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

media();

$dbh->disconnect;


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
      print "MediaServerName:$sMediaServerName\n";
       
      open (MD, "bpmedialist -mlist -h $sMediaServerName |"); 
      while (defined ($sMD = <MD>)) {
        if ($sMD =~ /^Server Host/) {
          for ($i=0; $i<5; $i++) {$sMD = <MD>;};
        }
        chomp $sMD; 
        ($sMediaID, $iRetention, $iImage, undef, undef, $dLWrite, $tLWrite, undef, $iKB, $iRestores ) = split(/\s+/, $sMD);
        if ($dLWrite eq "N/A") {
          $dLWrite = $nullDate;
          $iKB = 0;
          $iRestores = 0;
        }  
        $sMD = <MD>;
        chomp $sMD;
        (undef, $iValidImage, $dExpir, $tExpir, $dLRead, $tLRead, $sStatus) = split(/\s+/, $sMD);
# TODO  ($iValidImage, undef, undef, $dLRead, $tLRead, $sStatus) = ($sMD =~ /^\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(.+)/);
        if ($dExpir eq "INFINITY") {
          $sStatus = $dLRead if defined $dLRead;
          $sStatus2 = $tLRead if defined $tLRead;
          $dLRead = $tExpir;
          $dExpir = "01/19/2038";
          $tExpir = "06:14";
        }
        elsif ($dExpir eq "N/A") {
          $sStatus = $dLRead if defined $dLRead;
          $sStatus2 = $tLRead if defined $tLRead;
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
                    NetBackup.SetMedia(
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

  print "MediaID:$_[0]\n";
};

#-------------
sub set_media
#$sMediaID, $iRetention, $iImage, $dLWrite, $tLWrite, $iKB, $iRestores,
#$iValidImage, $dLRead, $tLRead, $sStatus, $sMediaServerName
{
  my $nullDate = "'00/00/0000'";

  $sth = $dbh->prepare(
                 "BEGIN
                    NetBackup.SetMedia(
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
  
  print "MediaID:$_[0]\n";
};

#-------------
sub get_hostname_ip
{
  my ($oldName, @newNames);
  
    $oldName = $_[0];
    open (DIP, "bpclntcmd -hn $oldName |");
    my $sDIP = <DIP>;
    close (DIP);
    @newNames =  $sDIP =~ /.+: (.*) at (.*) \((.*)/;
    if (defined($newNames[0])) {return @newNames}
    else {return ($oldName) };
}

