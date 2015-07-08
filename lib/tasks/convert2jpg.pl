#!/usr/bin/perl

use strict;

my $user = "USER_NAME";
my $server = "SERVER_NAME";
my $extdir = "EXTERNAL_SERVER_DIRECTORY";
my $tifdir = "DIRECTORY_FOR_TIFF_FILES";
my $jpgdir = "DIRECTORY_FOR_JPEG2000_FILE";
my $kakadubin = "KAKADU_BIN_DIRECTORY";
my $extension = "JPEG2000_FILE_EXTENSION";

# This will copy all files in external server directory which start with "dalgas200". "$extdir/* will copy all file in 
# external server directory and "scp -r" will copy all under directory and files in "$extdir".
system("scp $user\@$server://$extdir/dalgas200*  $tifdir/.");

my @dirlist;
opendir(DIR,"$tifdir");
  @dirlist =  grep {-f "$tifdir/$_" } readdir(DIR);
close DIR;

my @filename;
if ($#dirlist >= 0) {
   for (my $z=0;$z<=$#dirlist;$z++){
      @filename = split(/\./, $dirlist[$z]);  
      system("$kakadubin/kdu_compress -i $tifdir/$dirlist[$z] -o $jpgdir/$filename[0].$extension -rate 1.0");
      system("rm -f $tifdir/$dirlist[$z]");
   }
}
