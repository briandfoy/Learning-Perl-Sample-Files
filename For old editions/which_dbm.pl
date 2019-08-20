#!/usr/bin/perl -w

# which_dbm - attempts to determine which DBM implementation is being used

# Copyright (C) 2001 Tom Phoenix <rootbeer@redcat.com>
# This program is intended to be used with Perl. It may be distributed
# under the same licensing terms as Perl itself.

use strict;
use Cwd;

my $VERSION = 1.1;

# This fetches a list of possible DBM implementations, like NDBM
sub possibles {
    my %hash;
    for my $dir (@INC) {
        opendir DIR, $dir or next;     # if it's not easy, it's not worth doing.
        for (readdir DIR) {
            $hash{$1}++ if /(.*?)_File\.pm$/;
        }
    }
    closedir DIR;
    delete $hash{AnyDBM};
    keys %hash;
}

# Since MacPerl can't easily use @ARGV
BEGIN {
    if (!@ARGV and $^O eq 'MacOS') {
        my @list = &possibles;
        my $choice = MacPerl::Pick(
            "Attempt which implementation?",
            "-default-", @list);
        # This should quit upon "cancel", but there doesn't
        # seem to be a way to distinguish that from making
        # no selection. So, tough.
        return unless defined $choice;
        return if $choice eq "-default-";
        @ARGV = $choice;
    }
}

# Command-line arg may be the name of a DBM implementation, such as GDBM,
# and that one will be used instead of the default if possible.
BEGIN {
    return unless @ARGV;
    my $requested = $ARGV[0];
    $requested =~ s/(.*?)(?:_File)?(?:\.pm)?$/\U$1\E_File/;
    @AnyDBM_File::ISA = ($requested);
    eval 'use AnyDBM_File;';
    if ($@) {
        # Figure that the requested one wasn't available
	# so we'll take what we can get.
        @AnyDBM_File::ISA = ();
        eval 'use AnyDBM_File;';
    }
}

my $original_dir = getcwd;
my $temp_dir = "temp$$.$^T";

mkdir $temp_dir, 0755 or die "Can't mkdir: $!";
chdir $temp_dir or die "Can't chdir: $!";

{
    my %HASH;
    dbmopen %HASH, 'fred', 0644;
    $HASH{fred} = 'barney';
    dbmclose %HASH;
}

die "This program can't determine the DBM mode in use.\n"
    unless @AnyDBM_File::ISA == 1;
print <<"MESSAGE";
You seem to be using @AnyDBM_File::ISA.

To always request this implementation when you use dbmopen(),
add this line near the top of your programs:

        use @AnyDBM_File::ISA;

MESSAGE

my @extensions = sort map {
    (my $copy = $_) =~ s/^fred//;
    $copy eq '' ? "[no extension]" : $copy;
} glob 'fred*';

if (@extensions == 0) {
    print "There seems to be something wrong with the DBM file.\n";
} elsif (@extensions == 1) {
    print "The file extension seems to be: @extensions\n\n";
} else {
    print "The file extensions seem to be: @extensions\n\n";
}

unlink glob 'fred*';
chdir $original_dir or die "Can't change back to original dir: $!";
rmdir $temp_dir;

print "You might have these implementations available:\n",
    map "    $_\n", &possibles();
print "\n";
print "See the AnyDBM_File manpage for more information.\n";

exit;
