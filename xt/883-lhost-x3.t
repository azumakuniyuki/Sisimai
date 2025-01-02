use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X3';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '1001'  => [['5.3.0',   '553', 'userunknown',     1]],
    '1002'  => [['5.0.900', '',    'undefined',       0]],
    '1003'  => [['5.0.947', '',    'expired',         0]],
    '1004'  => [['5.3.0',   '553', 'userunknown',     1]],
    '1005'  => [['5.0.900', '',    'undefined',       0]],
    '1006'  => [['5.3.0',   '553', 'userunknown',     1]],
    '1007'  => [['5.0.947', '',    'expired',         0]],
    '1008'  => [['5.3.0',   '553', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

