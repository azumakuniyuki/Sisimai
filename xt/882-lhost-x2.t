use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X2';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '1001'  => [['5.7.1',   '554', 'norelaying',      0]],
    '1002'  => [['5.0.910', '',    'filtered',        0]],
    '1003'  => [['5.0.910', '',    'filtered',        0]],
    '1004'  => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '1005'  => [['5.0.947', '',    'expired',         0]],
    '1006'  => [['5.1.2',   '',    'hostunknown',     1]],
    '1007'  => [['5.0.947', '',    'expired',         0]],
    '1008'  => [['4.4.1',   '',    'expired',         0]],
    '1009'  => [['5.0.922', '',    'mailboxfull',     0]],
    '1010'  => [['5.0.921', '',    'suspend',         0]],
    '1011'  => [['5.0.922', '',    'mailboxfull',     0],
                ['5.0.922', '',    'mailboxfull',     0]],
    '1012'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1013'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1014'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1015'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1016'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1017'  => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '1018'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1019'  => [['5.0.922', '',    'mailboxfull',     0]],
    '1020'  => [['5.0.910', '',    'filtered',        0]],
    '1021'  => [['5.0.910', '',    'filtered',        0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.910', '',    'filtered',        0]],
    '1022'  => [['5.0.910', '',    'filtered',        0]],
    '1023'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1024'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1025'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1026'  => [['5.0.921', '',    'suspend',         0],
                ['5.0.921', '',    'suspend',         0]],
    '1027'  => [['5.0.922', '',    'mailboxfull',     0],
                ['5.0.922', '',    'mailboxfull',     0]],
    '1028'  => [['4.4.1',   '',    'expired',         0]],
    '1029'  => [['4.1.9',   '',    'expired',         0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

