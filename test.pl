#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Tiny;
use Path::Tiny;

my $res = HTTP::Tiny->new->mirror(
    "https://cpan.metacpan.org/authors/id/M/MS/MSTROUT/App-FatPacker-0.010007.tar.gz",
    "App-FatPacker-0.010007.tar.gz",
);
warn "$res->{status} $res->{reason}";

system "tar", "xf", "App-FatPacker-0.010007.tar.gz";
warn $?;

chdir "App-FatPacker-0.010007" or die;

path("hoge.patch")->spew(<<'___');
diff --git Makefile.PL Makefile.PL
index 1077f48..8a8c7d9 100644
--- Makefile.PL
+++ Makefile.PL
@@ -6,6 +6,8 @@ use 5.008000;
 
 (do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';
 
+warn "HOOKED";
+
 WriteMakefile(
   NAME => 'App::FatPacker',
   VERSION_FROM => 'lib/App/FatPacker.pm',
___

system "patch", "--batch", "-p0", "-i", "hoge.patch";

warn $?;

warn path("Makefile.PL")->slurp;
