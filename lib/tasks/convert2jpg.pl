#!/usr/bin/perl

use strict;

my $path1 = "/home/apache_user/chronos-data/adl-facsimiles/adl";                    
my $path2 = "/home/apache_user/chronos-jp2/adl";                
my $kakadubin = "/home/apache_user/converter/kakadu-bin";
my $extension = "jp2";
 
traverse($path1,$path2);
 
sub traverse {
    my ($file,$jp) = @_;
 
    return if not -d $file;
    opendir my $dh, $file or die;
    while (my $sub = readdir $dh) {
        next if $sub eq '.' or $sub eq '..';
         
        system("mkdir $jp/$sub")  unless ((-d "$jp/$sub") || ($sub =~ /(.*)(\.)(tif)/)) ;
        if ($sub =~ /(.*)(\.)(tif)/){
            my @filename = split(/\./, $sub);
            system("$kakadubin/kdu_compress -i $file/$sub -o $jp/$filename[0].$extension -rate 1.0");  
        }
        else {
           traverse("$file/$sub","$jp/$sub");
        }
    }
    close $dh;
    return;
}



