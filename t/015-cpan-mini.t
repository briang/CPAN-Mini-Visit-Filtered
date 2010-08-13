use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
#use Data::Dump 'pp'; # XXX

my $MOD = "CPAN::Mini::Visit::Filtered";

use Test::More tests => 4;

use File::Spec;
use Test::Exception;
#use Test::MockObject;

eval "use $MOD; 1"
  or BAIL_OUT "'use $MOD' failed: $@";

# Need better tests for location of mirror.
# Particularly regarding CPAN::Mini.
#
# - cpan_base is supplied
#   - it exists                 --> PASS
#   - it doesn't exist          --> FAIL
# - CPAN::Mini not installed    --> FAIL
# - CPAN::Mini installed
#   - no config                 --> FAIL
#   - config
#     - local                   --> PASS
#
# XXX Just make it mandatory!

lives_ok {
    my $visitor = $MOD->new(
        action => sub {},
        cpan_base => '.',
    );
} "cpan_base given && exists";

throws_ok {
    my $visitor = $MOD->new(
        action => sub {},
    );
} qr/^Attribute \(cpan_base\) is required/, "cpan_base not given";

throws_ok {
    my $visitor = $MOD->new(
        action => sub {},
        cpan_base => 'blurgle',
    );
} qr/^Attribute \(cpan_base\) does not exist:/, "cpan_base given but doesn't exists";

throws_ok {
    my $visitor = $MOD->new(
        action => sub {},
        cpan_base => __FILE__,
    );
} qr/^Attribute \(cpan_base\) is not a directory/, "cpan_base given but isn't a directory";
