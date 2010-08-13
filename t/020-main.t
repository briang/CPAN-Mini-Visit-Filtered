use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
#use Data::Dump 'pp'; # XXX

my $MOD = "CPAN::Mini::Visit::Filtered";

use Test::More tests => 11;

use File::Spec;
use Test::Exception;

eval "use $MOD; 1"
  or BAIL_OUT "'use $MOD' failed: $@";

my $cpan_base = File::Spec->catdir($FindBin::Bin, 'cpan');

{   my $foo = CPAN::Mini::Visit::Filtered->new(action => sub{}, cpan_base => $cpan_base);
    ok $foo,           "$MOD returned something";
    ok ref $foo,       "... a reference";
    isa_ok $foo, $MOD, "...";
}

throws_ok {
    CPAN::Mini::Visit::Filtered->new( cpan_base => $cpan_base );
} qr/^Attribute \Q(action)\E is required/, "action is a required parameter of new()";

{   my @expected = sort qw(
        A/AC/ACALPINI/Lingua-IT-Conjugate-0.50.tar.bz2
        A/AC/ACALPINI/Lingua-IT-Hyphenate-0.14.zip
        A/AC/ACALPINI/Lingua-Stem-It-0.02.tgz
        A/AC/ACME/MojoX-UserAgent-0.21.tar.gz
    );

    {   my $foo = CPAN::Mini::Visit::Filtered->new(
            action    => sub {},
            cpan_base => $cpan_base,
        );

        my @archs = find_archives($foo);

        is @archs, 0+@expected, "find_archives() found " . @expected . " non-acme archives";
        is_deeply \@archs, \@expected, "... as expected";
    }

    @expected = sort @expected, "A/AC/ACALPINI/Acme-CPANAuthors-Italian-0.01.tar.gz";

    {   my $foo = CPAN::Mini::Visit::Filtered->new(
            action       => sub {},
            cpan_base => $cpan_base,
            include_acme => 1,
        );

        my @archs = find_archives($foo);

        is @archs, 0+@expected, "find_archives() found " . @expected . " archives";
        is_deeply \@archs, \@expected, "... as expected";
    }

    @expected = grep { /-IT-/ } @expected;
    my $count;

    {   my $foo = CPAN::Mini::Visit::Filtered->new(
            action       => sub {},
            cpan_base => $cpan_base,
            filter       => sub { ++$count; /-IT-/ },
            include_acme => 1,
        );

        my @archs = find_archives($foo);

        is $count, 5, "filter was called 5 times";
        is @archs, 0+@expected, "find_archives() found " . @expected . " filtered archives";
        is_deeply \@archs, \@expected, "... as expected";
    }
}

sub find_archives {
    my $V = shift;
    my @archs = map {
        my ($vol, $path, $file) = File::Spec->splitpath($_);
        my @dirs = File::Spec->splitdir($path);
        shift @dirs until $dirs[0] eq 'id';
        shift @dirs;
        $_ = File::Spec->catdir(@dirs, $file);
    } sort $V->find_archives;

    return @archs;
}

#pp $foo->visit_distributions;
