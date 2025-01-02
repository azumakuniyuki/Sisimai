use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Activehunter';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '1001'  => [['5.0.910', '550', 'filtered',        0]],
    '1002'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1003'  => [['5.3.0'  , '553', 'filtered',        0]],
    '1004'  => [['5.7.17',  '550', 'filtered',        0]],
    '1005'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1006'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1007'  => [['5.0.910', '550', 'filtered',        0]],
    '1008'  => [['5.0.910', '550', 'filtered',        0]],
    '1009'  => [['5.1.1',   '550', 'userunknown',     1]],
    '1010'  => [['5.3.0',   '553', 'filtered',        0]],
    '1011'  => [['5.7.17',  '550', 'filtered',        0]],
    '1012'  => [['5.1.1',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

