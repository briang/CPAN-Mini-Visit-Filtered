#!/home/bin/perl

use strict;
use warnings FATAL => 'all';

use Data::Dump; # XXX

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib"; # assumes we're in examples/
}

use Parse::CPAN::Meta;
use CPAN::Mini::Visit::Filtered;
#use File::Slurp;

$| = 1;

my %tests;
my $visitor = CPAN::Mini::Visit::Filtered->new(
    cpan_base => '/mirrors/cpan',
    action    => sub {
        my $info = shift;
        return unless -e 'META.yml';

        print $info->dist, "\n";

        my @yaml = Parse::CPAN::Meta::LoadFile( 'META.yml' );
        die dd \@yaml if @yaml > 1;
        my %reqs;
        for my $k (keys %{$yaml[0]}) {
            if ($k =~ /req/) {
                my $v = $yaml[0]->{$k};
                next unless defined $v;
                /^Test/ and $reqs{$_} = 1
                  for values %$v;
            }
        }
        $tests{$_}++ for keys %reqs;
        #dd @{$yaml[0]}{qw/build_requires requires/};
    },
    filter => sub {
        #return $_[0]->dist =~ /ZZip$/; # XXX
        return rand() < 0.005;
    },
);

$visitor->visit_distributions;

dd \%tests;
