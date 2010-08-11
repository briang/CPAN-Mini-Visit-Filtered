#!/home/bin/perl

use strict;
use warnings FATAL => 'all';

use Data::Dump 'pp';

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib"; # assumes we're in examples/
}

use CPAN::Mini::Visit::Filtered;
use File::Slurp;

$| = 1;

my $visitor = CPAN::Mini::Visit::Filtered->new(
    action => sub {
        my $info = shift;

        print $info->dist;

        my $file;
        -e $_ and $file = $_ and last
          for qw(META.yml Makefile.PL Build.PL);

        return unless $file;

        print "===================Found: ", $info->dist
          if read_file($file) =~ m/MooseX::App/;
        print "\n"
    },
    filter => sub {
        my $info = shift;
        return $info->dist =~ /^app/i
    },
);

$visitor->visit_distributions;
