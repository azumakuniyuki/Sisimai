use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Sendmail';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.1.1',   '550', 'suspend',         0]],
    '01002' => [['4.4.1',   '',    'blocked',         0]],
    '01003' => [['4.4.1',   '',    'expired',         0]],
    '01004' => [['2.0.0',   '',    'delivered',       0],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01005' => [['4.4.1',   '',    'expired',         0]],
    '01006' => [['4.4.3',   '',    'expired',         0]],
    '01007' => [['4.4.1',   '',    'expired',         0]],
    '01008' => [['5.2.0',   '550', 'filtered',        0]],
    '01009' => [['4.4.1',   '',    'expired',         0]],
    '01010' => [['4.4.1',   '',    'blocked',         0],
                ['4.4.1',   '',    'blocked',         0]],
    '01011' => [['4.7.1',   '450', 'blocked',         0]],
    '01012' => [['4.2.0',   '451', 'systemerror',     0]],
    '01013' => [['5.1.1',   '550', 'userunknown',     1]],
    '01014' => [['4.4.7',   '',    'expired',         0]],
    '01015' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01016' => [['4.4.7',   '',    'expired',         0]],
    '01017' => [['4.4.7',   '',    'expired',         0]],
    '01018' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01019' => [['4.7.1',   '450', 'blocked',         0]],
    '01020' => [['4.4.7',   '',    'expired',         0]],
    '01021' => [['4.4.7',   '',    'expired',         0]],
    '01022' => [['4.4.7',   '',    'expired',         0]],
    '01023' => [['4.4.7',   '',    'expired',         0]],
    '01024' => [['5.0.0',   '554', 'filtered',        0]],
    '01025' => [['5.0.0',   '534', 'mesgtoobig',      0]],
    '01026' => [['5.0.0',   '517', 'blocked',         0]],
    '01027' => [['5.0.0',   '517', 'rejected',        0]],
    '01028' => [['5.7.1',   '554', 'norelaying',      0]],
    '01029' => [['5.2.0',   '550', 'spamdetected',    0]],
    '01030' => [['5.0.0',   '',    'suspend',         0]],
    '01031' => [['5.0.0',   '',    'suspend',         0]],
    '01032' => [['5.0.0',   '554', 'mailererror',     0]],
    '01033' => [['5.0.0',   '554', 'mailererror',     0]],
    '01034' => [['5.0.0',   '554', 'mailererror',     0]],
    '01035' => [['5.1.1',   '511', 'userunknown',     1]],
    '01036' => [['5.0.0',   '554', 'filtered',        0]],
    '01037' => [['5.0.0',   '554', 'filtered',        0]],
    '01038' => [['5.1.1',   '550', 'userunknown',     1]],
    '01039' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01040' => [['5.1.1',   '550', 'userunknown',     1]],
    '01041' => [['5.7.1',   '550', 'filtered',        0]],
    '01042' => [['5.1.1',   '550', 'userunknown',     1]],
    '01043' => [['5.1.1',   '550', 'userunknown',     1]],
    '01044' => [['5.1.1',   '550', 'userunknown',     1]],
    '01045' => [['5.1.1',   '550', 'userunknown',     1]],
    '01046' => [['5.1.1',   '550', 'userunknown',     1]],
    '01047' => [['5.1.1',   '550', 'blocked',         0]],
    '01048' => [['5.1.1',   '550', 'userunknown',     1]],
    '01049' => [['5.1.1',   '550', 'userunknown',     1]],
    '01050' => [['5.1.1',   '550', 'userunknown',     1]],
    '01051' => [['5.1.1',   '550', 'userunknown',     1]],
    '01052' => [['5.1.1',   '550', 'userunknown',     1]],
    '01053' => [['5.1.1',   '550', 'userunknown',     1]],
    '01054' => [['5.1.1',   '550', 'userunknown',     1]],
    '01055' => [['5.1.1',   '550', 'userunknown',     1]],
    '01056' => [['5.1.1',   '550', 'userunknown',     1]],
    '01057' => [['5.1.1',   '550', 'userunknown',     1]],
    '01058' => [['5.1.1',   '550', 'norelaying',      0]],
    '01059' => [['5.1.1',   '550', 'userunknown',     1]],
    '01060' => [['5.1.1',   '550', 'userunknown',     1]],
    '01061' => [['5.1.1',   '550', 'blocked',         0]],
    '01062' => [['5.1.1',   '550', 'userunknown',     1]],
    '01063' => [['5.1.1',   '550', 'userunknown',     1]],
    '01064' => [['5.1.1',   '550', 'userunknown',     1]],
    '01065' => [['5.1.1',   '550', 'userunknown',     1]],
    '01066' => [['5.1.1',   '550', 'userunknown',     1]],
    '01067' => [['5.1.1',   '550', 'userunknown',     1]],
    '01068' => [['5.1.1',   '550', 'userunknown',     1]],
    '01069' => [['5.1.1',   '550', 'userunknown',     1]],
    '01070' => [['5.1.1',   '550', 'userunknown',     1]],
    '01071' => [['5.1.1',   '550', 'userunknown',     1]],
    '01072' => [['5.1.1',   '550', 'userunknown',     1]],
    '01073' => [['5.1.1',   '550', 'userunknown',     1]],
    '01074' => [['5.1.1',   '550', 'userunknown',     1]],
    '01075' => [['5.1.1',   '550', 'userunknown',     1]],
    '01076' => [['5.1.1',   '550', 'userunknown',     1]],
    '01077' => [['5.1.1',   '550', 'userunknown',     1]],
    '01078' => [['5.1.1',   '550', 'userunknown',     1]],
    '01079' => [['5.1.1',   '550', 'userunknown',     1]],
    '01080' => [['5.1.1',   '550', 'userunknown',     1]],
    '01081' => [['5.1.1',   '550', 'userunknown',     1]],
    '01082' => [['5.1.1',   '550', 'userunknown',     1]],
    '01083' => [['5.1.1',   '550', 'userunknown',     1]],
    '01084' => [['5.1.2',   '550', 'filtered',        0]],
    '01085' => [['5.1.2',   '550', 'filtered',        0]],
    '01086' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01087' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01088' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01089' => [['5.7.1',   '553', 'norelaying',      0]],
    '01090' => [['5.2.0',   '550', 'filtered',        0]],
    '01091' => [['5.2.0',   '550', 'filtered',        0]],
    '01092' => [['5.2.0',   '550', 'filtered',        0]],
    '01093' => [['5.2.1',   '550', 'suspend',         0]],
    '01094' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01095' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01096' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01097' => [['5.2.2',   '550', 'mailboxfull',     0]],
    '01098' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '01099' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '01100' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '01101' => [['5.3.0',   '550', 'systemerror',     0]],
    '01102' => [['5.3.0',   '553', 'filtered',        0]],
    '01103' => [['5.3.0',   '553', 'filtered',        0]],
    '01104' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01105' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01106' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01107' => [['5.3.5',   '553', 'systemerror',     0]],
    '01108' => [['5.3.5',   '553', 'systemerror',     0]],
    '01109' => [['5.4.1',   '550', 'filtered',        0]],
    '01110' => [['5.4.1',   '550', 'filtered',        0]],
    '01111' => [['5.4.6',   '554', 'networkerror',    0]],
    '01112' => [['5.5.0',   '554', 'mailererror',     0]],
    '01113' => [['5.6.0',   '550', 'contenterror',    0]],
    '01114' => [['5.7.0',   '552', 'policyviolation', 0]],
    '01115' => [['5.7.0',   '554', 'policyviolation', 0]],
    '01116' => [['5.7.0',   '550', 'spamdetected',    0]],
    '01117' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01118' => [['5.1.1',   '550', 'userunknown',     1]],
    '01119' => [['5.2.0',   '550', 'filtered',        0]],
    '01120' => [['5.2.0',   '550', 'filtered',        0]],
    '01121' => [['5.2.0',   '550', 'filtered',        0]],
    '01122' => [['5.1.1',   '550', 'userunknown',     1]],
    '01124' => [['4.4.1',   '',    'expired',         0]],
    '01125' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01127' => [['5.1.1',   '550', 'userunknown',     1]],
    '01129' => [['5.1.6',   '',    'hasmoved',        1]],
    '01130' => [['5.1.1',   '550', 'userunknown',     1]],
    '01131' => [['5.2.0',   '550', 'filtered',        0],
                ['5.2.0',   '550', 'filtered',        0],
                ['5.2.0',   '550', 'filtered',        0]],
    '01132' => [['5.2.0',   '550', 'filtered',        0]],
    '01133' => [['5.3.0',   '553', 'filtered',        0]],
    '01134' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01135' => [['5.1.1',   '550', 'userunknown',     1]],
    '01136' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01137' => [['5.2.2',   '550', 'mailboxfull',     0],
                ['5.2.2',   '550', 'mailboxfull',     0]],
    '01138' => [['5.2.0',   '550', 'filtered',        0]],
    '01139' => [['5.2.0',   '550', 'filtered',        0]],
    '01140' => [['5.2.0',   '550', 'filtered',        0]],
    '01141' => [['5.1.1',   '550', 'userunknown',     1]],
    '01142' => [['5.7.0',   '552', 'policyviolation', 0]],
    '01143' => [['5.7.1',   '550', 'userunknown',     1]],
    '01144' => [['5.1.1',   '550', 'userunknown',     1]],
    '01145' => [['5.1.1',   '550', 'userunknown',     1]],
    '01146' => [['5.1.1',   '550', 'userunknown',     1]],
    '01147' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01148' => [['5.1.1',   '550', 'userunknown',     1]],
    '01149' => [['5.1.1',   '550', 'userunknown',     1]],
    '01150' => [['5.1.1',   '550', 'userunknown',     1]],
    '01151' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01152' => [['5.3.0',   '550', 'systemerror',     0]],
    '01153' => [['5.0.0',   '554', 'mailererror',     0]],
    '01154' => [['5.1.1',   '550', 'userunknown',     1]],
    '01155' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01156' => [['5.1.1',   '550', 'userunknown',     1]],
    '01158' => [['4.5.0',   '',    'expired',         0]],
    '01159' => [['4.2.2',   '452', 'mailboxfull',     0]],
    '01160' => [['5.3.0',   '553', 'filtered',        0]],
    '01161' => [['5.1.1',   '550', 'userunknown',     1]],
    '01162' => [['5.2.1',   '550', 'filtered',        0],
                ['5.2.1',   '550', 'filtered',        0]],
    '01163' => [['5.1.1',   '550', 'userunknown',     1]],
    '01164' => [['5.1.8',   '553', 'rejected',        0]],
    '01165' => [['5.2.3',   '552', 'exceedlimit',     0]],
    '01166' => [['5.6.9',   '550', 'contenterror',    0]],
    '01167' => [['5.7.1',   '554', 'norelaying',      0]],
    '01168' => [['4.7.1',   '450', 'blocked',         0]],
    '01169' => [['5.7.9',   '554', 'policyviolation', 0]],
    '01170' => [['4.7.1',   '450', 'blocked',         0]],
    '01171' => [['4.4.7',   '',    'expired',         0]],
    '01172' => [['5.3.0',   '550', 'systemerror',     0]],
    '01173' => [['5.1.1',   '550', 'userunknown',     1]],
    '01174' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01175' => [['5.5.0',   '554', 'blocked',         0]],
    '01176' => [['5.1.6',   '',    'hasmoved',        1]],
    '01177' => [['5.0.0',   '554', 'mailererror',     0]],
    '01178' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01179' => [['5.1.1',   '550', 'userunknown',     1]],
    '01181' => [['5.3.4',   '552', 'mesgtoobig',      0]],
    '01182' => [['5.1.1',   '550', 'userunknown',     1]],
    '01183' => [['5.0.0',   '554', 'suspend',         0]],
    '01184' => [['5.0.0',   '554', 'filtered',        0]],
    '01185' => [['4.4.7',   '',    'expired',         0]],
    '01186' => [['5.7.0',   '552', 'policyviolation', 0]],
    '01187' => [['5.7.0',   '',    'blocked',         0]],
    '01188' => [['5.1.1',   '550', 'userunknown',     1]],
    '01189' => [['4.4.7',   '',    'expired',         0]],
    '01190' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01191' => [['5.2.1',   '550', 'suspend',         0]],
    '01192' => [['5.1.1',   '550', 'userunknown',     1]],
    '01193' => [['5.1.1',   '550', 'userunknown',     1]],
    '01194' => [['5.2.1',   '550', 'suspend',         0]],
    '01195' => [['5.7.0',   '552', 'policyviolation', 0]],
    '01196' => [['5.2.1',   '550', 'suspend',         0]],
    '01197' => [['5.1.1',   '550', 'userunknown',     1]],
    '01198' => [['5.1.1',   '550', 'userunknown',     1]],
    '01199' => [['5.7.1',   '550', 'blocked',         0]],
    '01200' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01201' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01202' => [['4.4.5',   '452', 'systemfull',      0]],
    '01203' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01204' => [['5.2.1',   '550', 'suspend',         0]],
    '01205' => [['5.1.1',   '550', 'userunknown',     1]],
    '01206' => [['5.3.5',   '553', 'systemerror',     0]],
    '01207' => [['5.1.1',   '550', 'userunknown',     1]],
    '01208' => [['4.4.7',   '451', 'expired',         0]],
    '01209' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01210' => [['5.1.1',   '550', 'userunknown',     1]],
    '01211' => [['5.1.1',   '550', 'userunknown',     1]],
    '01212' => [['5.2.0',   '550', 'filtered',        0]],
    '01213' => [['5.2.0',   '550', 'filtered',        0]],
    '01214' => [['5.1.1',   '550', 'userunknown',     1]],
    '01215' => [['5.1.1',   '550', 'userunknown',     1]],
    '01216' => [['5.1.1',   '550', 'userunknown',     1]],
    '01217' => [['5.5.0',   '554', 'blocked',         0]],
    '01218' => [['5.5.0',   '554', 'blocked',         0]],
    '01219' => [['5.7.27',  '550', 'notaccept',       1]],
    '01220' => [['5.7.1',   '550', 'policyviolation', 0]],
    '01221' => [['5.6.0',   '552', 'contenterror',    0]],
    '01222' => [['5.7.1',   '550', 'policyviolation', 0]],
    '01223' => [['5.7.1',   '550', 'policyviolation', 0]],
    '01224' => [['5.7.1',   '550', 'policyviolation', 0]],
    '01225' => [['5.7.1',   '550', 'policyviolation', 0]],
    '01226' => [['5.7.1',   '550', 'rejected',        0]],
    '01227' => [['5.7.1',   '550', 'rejected',        0]],
    '01228' => [['5.1.1',   '550', 'userunknown',     1]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

