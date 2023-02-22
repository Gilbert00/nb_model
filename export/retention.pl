#!/usr/bin/perl -w
use strict;

use DBI;
use DBI qw(:sql_types);
use POSIX;

$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\11.1.0\\client1";
#$ENV{"ORACLE_HOME"} = "d:\\oracle\\product\\10.2.0\\db_2";
$ENV{"PATH"} = "D:\\Perl\\bin;" . $ENV{"ORACLE_HOME"}. "\\bin;" . $ENV{"PATH"};

use vars qw($dbh $sth $sql);

$dbh = DBI->connect('dbi:Oracle:', 'netbackup@COD', 'NB', {RaiseError => 1, PrintError =>1, AutoCommit => 0})
         || die $dbh->errstr;

retention();

$dbh->disconnect;


#-------------
sub retention
{
#my $sRetentionFile = "/usr/openv/netbackup/db/config/user_retention";
  my $sRetentionFile = "D:\\Kemper\\GVC\\Servers\\uxbkp\\netbackup\\To_Oracle\\user_retention";
  my ($sLine, $nMaxR);
  my @Flds;
  my ($nInd, $nSecs, $nKvo, $sPeriod);
  my $iInd = 1;
  my $iSecs = 2;
  my $iKvo = 3;
  my $iPeriod = 5;
  
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
      $sPeriod = $Flds[$iPeriod];
    }
    elsif ($nKvo == 0) {
      $sPeriod = $Flds[$iPeriod+1];
    }
    else {
      $sPeriod = $Flds[$iPeriod+1];    
    };
    
    if (($sPeriod eq "day") || ($sPeriod eq "week") || ($sPeriod eq "month") || ($sPeriod eq "year")) {
      $sPeriod = $sPeriod . "s";
    };
    
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
