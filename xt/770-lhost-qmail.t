use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'qmail';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.910', '',    'filtered',        0]],
    '01002' => [['5.0.900', '',    'undefined',       0]],
    '01003' => [['5.0.912', '550', 'hostunknown',     1]],
    '01004' => [['5.1.1',   '',    'userunknown',     1]],
    '01005' => [['5.0.912', '550', 'hostunknown',     1]],
    '01006' => [['5.1.1',   '',    'userunknown',     1]],
    '01007' => [['5.0.912', '550', 'hostunknown',     1]],
    '01008' => [['5.1.1',   '',    'userunknown',     1]],
    '01009' => [['5.1.1',   '',    'userunknown',     1]],
    '01010' => [['5.0.912', '550', 'hostunknown',     1]],
    '01011' => [['5.0.912', '550', 'hostunknown',     1]],
    '01012' => [['5.0.911', '',    'userunknown',     1]],
    '01013' => [['5.1.1',   '',    'userunknown',     1]],
    '01014' => [['5.0.918', '550', 'rejected',        0]],
    '01015' => [['5.7.1',   '550', 'rejected',        0]],
    '01016' => [['5.1.2',   '',    'hostunknown',     1]],
    '01017' => [['5.1.1',   '550', 'userunknown',     1]],
    '01018' => [['5.1.1',   '511', 'userunknown',     1]],
    '01019' => [['5.0.922', '',    'mailboxfull',     0]],
    '01020' => [['5.0.910', '554', 'filtered',        0]],
    '01021' => [['5.1.1',   '',    'userunknown',     1]],
    '01022' => [['5.1.1',   '550', 'userunknown',     1]],
    '01023' => [['5.0.911', '550', 'userunknown',     1]],
    '01024' => [['5.0.911', '550', 'userunknown',     1]],
    '01025' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.2.1',   '550', 'userunknown',     1]],
    '01026' => [['5.0.934', '552', 'mesgtoobig',      0]],
    '01027' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01028' => [['5.1.1',   '550', 'userunknown',     1]],
    '01029' => [['5.0.910', '550', 'filtered',        0]],
    '01030' => [['5.1.1',   '550', 'userunknown',     1]],
    '01031' => [['5.0.911', '550', 'userunknown',     1]],
    '01032' => [['4.4.1',   '',    'networkerror',    0]],
    '01033' => [['5.0.922', '',    'mailboxfull',     0]],
    '01034' => [['4.2.2',   '450', 'mailboxfull',     0]],
    '01035' => [['5.0.922', '552', 'mailboxfull',     0]],
    '01036' => [['5.1.1',   '',    'userunknown',     1]],
    '01037' => [['5.1.2',   '',    'hostunknown',     1]],
    '01038' => [['5.0.910', '550', 'filtered',        0]],
    '01039' => [['5.0.922', '',    'mailboxfull',     0]],
    '01040' => [['5.1.1',   '',    'mailboxfull',     0]],
    '01041' => [['5.5.0',   '550', 'userunknown',     1]],
    '01042' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.2.1',   '550', 'userunknown',     1]],
    '01043' => [['5.7.1',   '550', 'rejected',        0]],
    '01044' => [['5.0.0',   '501', 'blocked',         0]],
    '01045' => [['4.4.3',   '',    'systemerror',     0]],
    '01046' => [['4.2.2',   '450', 'mailboxfull',     0]],
    '01047' => [['5.5.0',   '550', 'userunknown',     1]],
    '01048' => [['5.2.2',   '',    'mailboxfull',     0]],
    '01049' => [['5.2.2',   '',    'mailboxfull',     0]],
    '01050' => [['5.1.1',   '',    'userunknown',     1]],
    '01051' => [['5.0.900', '',    'undefined',       0]],
    '01052' => [['5.0.921', '554', 'suspend',         0]],
    '01053' => [['5.0.910', '554', 'filtered',        0]],
    '01054' => [['5.0.911', '550', 'userunknown',     1]],
    '01055' => [['5.0.922', '',    'mailboxfull',     0]],
    '01056' => [['5.1.1',   '',    'userunknown',     1]],
    '01057' => [['5.0.911', '550', 'userunknown',     1]],
    '01058' => [['5.1.1',   '550', 'userunknown',     1]],
    '01059' => [['5.0.910', '',    'filtered',        0]],
    '01060' => [['5.0.921', '',    'suspend',         0]],
    '01061' => [['5.0.910', '554', 'filtered',        0]],
    '01062' => [['5.0.910', '554', 'filtered',        0]],
    '01063' => [['5.1.1',   '',    'userunknown',     1]],
    '01064' => [['5.1.1',   '',    'userunknown',     1]],
    '01065' => [['5.0.922', '',    'mailboxfull',     0]],
    '01066' => [['5.1.1',   '',    'userunknown',     1]],
    '01067' => [['5.1.0',   '550', 'userunknown',     1]],
    '01068' => [['5.0.911', '550', 'userunknown',     1]],
    '01069' => [['5.0.910', '',    'filtered',        0]],
    '01070' => [['5.0.912', '',    'hostunknown',     1],
                ['5.0.912', '',    'hostunknown',     1]],
    '01071' => [['5.7.1',   '554', 'norelaying',      0]],
    '01072' => [['5.0.912', '',    'hostunknown',     1]],
    '01073' => [['5.0.921', '',    'suspend',         0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;
