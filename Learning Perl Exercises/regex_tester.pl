#!/usr/bin/perl
use strict;
use warnings;

print "Enter a string>> ";
chomp( $_ = <STDIN> );

if( m/PATTERN/ ) {
	print "Before: $`\nName:  $&\nAfter: $'\n";
	}
else {
	print "The string did not match\n";
	}
