use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Notes';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '1001'  => [['5.0.911', '',    'userunknown',     1]],
    '1002'  => [['5.0.901', '',    'onhold',          0]],
    '1003'  => [['5.0.901', '',    'onhold',          0]],
    '1004'  => [['5.0.911', '',    'userunknown',     1]],
    '1005'  => [['5.0.901', '',    'onhold',          0]],
    '1006'  => [['5.0.911', '',    'userunknown',     1]],
    '1007'  => [['5.0.911', '',    'userunknown',     1]],
    '1008'  => [['5.0.911', '',    'userunknown',     1]],
    '1009'  => [['5.0.911', '',    'userunknown',     1]],
    '1010'  => [['5.0.944', '',    'networkerror',    0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

