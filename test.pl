#!/usr/bin/env perl
use strict;
use warnings;

use POSIX 'strftime';
use File::Copy 'copy';
use File::Copy::Recursive 'rcopy';
use File::Find 'find';
use File::Temp 'tempdir';
use File::Path 'remove_tree';

sub show_mtimes {
    my @file;
    for my $e (@_) {
        if (-f $e) {
            push @file, $e;
        } elsif (-d $e) {
            find({wanted => sub { push @file, $_ if -f }, no_chdir => 1}, $e);
        }
    }
    map {
        my $file = $_;
        my @stat = stat $file;
        warn sprintf "atime %s, mtime %s, ctime %s %s\n",
            strftime("%H:%M:%S", localtime $stat[8]),
            strftime("%H:%M:%S", localtime $stat[9]),
            strftime("%H:%M:%S", localtime $stat[10]),
            $file;
    } sort @file;
}
sub touch_now {
    my @file;
    for my $e (@_) {
        if (-f $e) {
            push @file, $e;
        } elsif (-d $e) {
            find({wanted => sub { push @file, $_ if -f }, no_chdir => 1}, $e);
        }
    }
    utime $^T, $^T, @file;
}
sub info {
    warn "--> @_\n";
}

remove_tree "share_copy" if -d "share_copy";
unlink "file_copy.txt" if -f "file_copy.txt";

info "START \$^T =", strftime("%H:%M:%S", localtime $^T), "($^T)";

for (1..2) {
    info "====== $_ time ======";
    info "1. first";
    show_mtimes "share";
    info "2. sleep 2";
    sleep 2;
    info "3. copy share";
    rcopy "share", "share_copy" or die $!;
    info "3-1. touch now";
    touch_now "share_copy";
    show_mtimes "share", "share_copy";

    info "4. sleep 2";
    sleep 2;
    info "5. copy share/file.txt";
    copy "share/file.txt", "file_copy.txt" or die $!;
    info "5-1. touch now";
    touch_now "file_copy.txt";
    show_mtimes "share/file.txt", "file_copy.txt";
}


