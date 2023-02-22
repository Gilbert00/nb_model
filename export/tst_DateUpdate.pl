#!/usr/bin/perl -w
#
# tst_DateUpdate.pl
#
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


set_date_update();

my $DateUpdate;

$DateUpdate = get_date_update();
print "DateUpdate:$DateUpdate\n";

$dbh->disconnect;

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
sub get_date_update
{
  my $RC;
  
  $sth = $dbh->prepare(
                 "BEGIN :rc :=
                    NetBackup.GetDateUpdate;
                  END;") || die $dbh->errstr;
  
  $sth->bind_param_inout(':rc', \$RC, 24, SQL_NUMERIC) || die $dbh->errstr;
   
  $sth->execute() || die $dbh->errstr;

  print "DateUpdate:$RC\n";
  return $RC;
}
