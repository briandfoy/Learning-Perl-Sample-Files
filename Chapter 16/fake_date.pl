#!/usr/bin/perl

# fake_date - fake like the system's date command

# If you don't have a Unix system with the "date" command, you may
# wish to install this one which will produce similar output. 

# Generally, you can make this executable and change the top line
# (as you would for any Perl program) and keep it in your current 
# working directory. (Calling commands from backticks doesn't work
# on MacPerl unless you have ToolServer or something similar; see
# the macperl POD file. Under Mac OS X and later, you should have
# a true date command, and shouldn't be using MacPerl.)

# This program is intended to be called from within backticks, as
# if it were the real date command, perhaps with code looking
# something like this:

#        chomp(my $date = `fake_date`);

my $date = localtime;

print "$date\n";
