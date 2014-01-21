#!/usr/bin/perl -w
use strict;

my $t1 = time;
my $numArgs = $#ARGV + 1;
my $fname_in;
if ($numArgs != 0) {
    $fname_in = $ARGV[0];
} else {
    die "You must give a filename to process! ";
}

my $extension = substr $fname_in, -4;
my $fname_out = substr $fname_in, 0, -4;
$fname_out .= "_label_define_commands".$extension;

open IPF, "< $fname_in" or die "Can not open file: $fname_in.  $!";
open OPF, "> $fname_out" or die "Can not open file: $fname_out. $!";

while (<IPF>) {
    chomp;
    # print $_."\n";
    # advance to the next non-blank line
    if (/^\s*$/) {
        while (<IPF>) {
            last if !(/^\s*$/)
        }
    }
    chomp;
    my $var = $_;
    my $statacommand = "label define $var ";
    print "------- START: $var ---------\n";
    while (<IPF>) {
        last if (/^\s*$/);
        print $_."\n";
        
        #/(?<CODE>\d+)\s*$/ or die "No code!";
        # print "CODE: $+{CODE} \n";
        /^(?<VALUE>[A-Za-z0-9,()].*[A-Za-z,()])(?<WHAT>.*?)(?<CODE>\d+)\s*$/ or die "No code!";
        #print "CODE: $+{CODE} \n";
        #print "VALUE: $+{VALUE}\n";
        print "$+{VALUE} $+{CODE} \n";
        print "WHAT: $+{WHAT}\n";
        my $code = $+{CODE};
        
        $statacommand = $statacommand." $+{CODE} \"$+{VALUE}\"";
    }
    $statacommand = $statacommand.", replace";
    print "statacommand: $statacommand\n";
    print "------- END ---------\n";
    print OPF "$statacommand\n";
}

close IPF;
close OPF;
