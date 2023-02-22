#!/usr/bin/perl -w

      use Net::OpenSSH;

use strict;
my $host = 'root:ertydfgh@uxbkp.datacenter.cnt';
my $host = 'uxbkp.datacenter.cnt';

      my $ssh = Net::OpenSSH->new($host, user => 'root', password => 'ertydfgh');
      $ssh->error and
        die "Couldn't establish SSH connection: ". $ssh->error;

      $ssh->system("ls /tmp") or
        die "remote command failed: " . $ssh->error;

      my @ls = $ssh->capture("ls");
      $ssh->error and
        die "remote ls command failed: " . $ssh->error;

      my ($out, $err) = $ssh->capture2("find /root");
      $ssh->error and
        die "remote find command failed: " . $ssh->error;

      my ($rin, $pid) = $ssh->pipe_in("cat >/tmp/foo") or
        die "pipe_in method failed: " . $ssh->error;

      print $rin, "hello\n";
      close $rin;

      my ($rout, $pid) = $ssh->pipe_out("cat /tmp/foo") or
        die "pipe_out method failed: " . $ssh->error;

      while (<$rout>) { print }
      close $rout;

      my ($in, $out ,$pid) = $ssh->open2("foo");
      my ($pty, $pid) = $ssh->open2pty("foo");
      my ($in, $out, $err, $pid) = $ssh->open3("foo");
      my ($pty, $err, $pid) = $ssh->open3pty("login");

      my $sftp = $ssh->sftp();
      $sftp->error and die "SFTP failed: " . $sftp->error;

