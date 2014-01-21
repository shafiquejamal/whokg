#!/usr/bin/perl -w
use strict;

my $_ = "Other relatives…………10";

/^(?<VALUE>[A-Za-z0-9,()].*[A-Za-z,()])(?<WHAT>.*?)(?<CODE>\d+)\s*$/ or die "No code!";
print $_."\n";
print "$+{VALUE} $+{CODE} \n";
print "WHAT: $+{WHAT}\n";
        

