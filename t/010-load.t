use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

my @mods = qw{
   CPAN::Mini::Visit::Filtered
};

use Test::More;
plan tests => 1+ @mods;

use_ok $_ for @mods;
is $mods[0]->VERSION, '0.01_06', "Testing correct version";

diag "testing $mods[0] ", $mods[0]->VERSION,
     " on perl $]";
