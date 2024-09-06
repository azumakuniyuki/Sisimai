use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'RFC3464';
my $samplepath = sprintf("./set-of-emails/private/%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->makeinquiry;
my $isexpected = {
    # INDEX => [['D.S.N.', 'replycode', 'REASON', 'hardbounce'], [...]]
    '01001' => [['5.0.947', '',    'expired',         0]],
    '01002' => [['5.0.911', '550', 'userunknown',     1]],
    '01003' => [['5.0.934', '553', 'mesgtoobig',      0]],
    '01004' => [['5.0.910', '550', 'filtered',        0]],
    '01005' => [['5.0.944', '554', 'networkerror',    0]],
    '01007' => [['5.0.901', '',    'onhold',          0]],
    '01008' => [['5.0.947', '',    'expired',         0]],
    '01009' => [['5.1.1',   '550', 'userunknown',     1]],
    '01011' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01013' => [['5.1.0',   '550', 'userunknown',     1]],
    '01014' => [['5.1.1',   '550', 'userunknown',     1]],
    '01015' => [['5.0.912', '',    'hostunknown',     1]],
    '01016' => [['5.1.1',   '',    'userunknown',     1]],
    '01017' => [['5.1.1',   '550', 'userunknown',     1]],
    '01018' => [['5.0.922', '',    'mailboxfull',     0]],
    '01020' => [['5.1.1',   '550', 'userunknown',     1]],
    '01021' => [['5.2.0',   '',    'filtered',        0]],
    '01022' => [['5.1.1',   '550', 'userunknown',     1]],
    '01024' => [['5.1.0',   '550', 'userunknown',     1]],
    '01025' => [['5.0.910', '',    'filtered',        0]],
    '01026' => [['5.0.910', '',    'filtered',        0]],
    '01031' => [['5.1.1',   '550', 'userunknown',     1]],
    '01033' => [['5.1.1',   '',    'userunknown',     1]],
    '01035' => [['5.1.1',   '550', 'userunknown',     1]],
    '01036' => [['5.2.0',   '',    'filtered',        0]],
    '01037' => [['5.5.0',   '554', 'systemerror',     0]],
    '01038' => [['5.2.0',   '',    'filtered',        0]],
    '01039' => [['5.1.2',   '550', 'hostunknown',     1]],
    '01040' => [['5.4.6',   '554', 'networkerror',    0]],
    '01041' => [['5.2.0',   '',    'filtered',        0]],
    '01042' => [['5.2.0',   '',    'filtered',        0]],
    '01043' => [['5.0.901', '',    'onhold',          0],
                ['5.0.911', '550', 'userunknown',     1]],
    '01044' => [['5.1.1',   '550', 'userunknown',     1]],
    '01045' => [['5.0.911', '550', 'userunknown',     1]],
    '01046' => [['5.1.1',   '550', 'userunknown',     1]],
    '01047' => [['5.0.900', '',    'undefined',       0]],
    '01048' => [['5.2.0',   '',    'filtered',        0]],
    '01049' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01050' => [['5.2.0',   '',    'filtered',        0]],
    '01051' => [['5.1.1',   '550', 'userunknown',     1],
                ['5.1.1',   '550', 'userunknown',     1]],
    '01052' => [['5.0.900', '',    'undefined',       0]],
    '01053' => [['5.0.0',   '554', 'mailererror',     0]],
    '01054' => [['5.0.900', '',    'undefined',       0]],
    '01055' => [['5.0.910', '',    'filtered',        0]],
    '01056' => [['5.0.922', '554', 'mailboxfull',     0]],
    '01057' => [['5.2.0',   '',    'filtered',        0]],
    '01058' => [['5.0.900', '',    'undefined',       0]],
    '01059' => [['5.1.1',   '550', 'userunknown',     1]],
    '01060' => [['5.2.0',   '',    'filtered',        0]],
    '01062' => [['5.1.1',   '550', 'userunknown',     1]],
    '01063' => [['5.2.0',   '',    'filtered',        0]],
    '01064' => [['5.2.0',   '',    'filtered',        0]],
    '01065' => [['5.7.1',   '550', 'spamdetected',    0]],
    '01066' => [['5.2.0',   '',    'filtered',        0]],
    '01067' => [['5.0.930', '',    'systemerror',     0]],
    '01068' => [['5.0.900', '',    'undefined',       0]],
    '01069' => [['4.4.7',   '',    'expired',         0]],
    '01070' => [['5.5.0',   '',    'userunknown',     1]],
    '01071' => [['5.0.922', '',    'mailboxfull',     0]],
    '01072' => [['5.2.0',   '',    'filtered',        0]],
    '01073' => [['5.0.911', '550', 'userunknown',     1]],
    '01074' => [['5.2.0',   '',    'filtered',        0]],
    '01075' => [['5.0.910', '',    'filtered',        0]],
    '01076' => [['5.5.0',   '554', 'systemerror',     0]],
    '01077' => [['5.2.0',   '',    'filtered',        0]],
    '01078' => [['5.1.1',   '550', 'userunknown',     1]],
    '01079' => [['5.0.910', '',    'filtered',        0]],
    '01083' => [['5.2.0',   '',    'filtered',        0]],
    '01085' => [['5.2.0',   '',    'filtered',        0]],
    '01087' => [['5.2.0',   '',    'filtered',        0]],
    '01089' => [['5.2.0',   '',    'filtered',        0]],
    '01090' => [['5.2.0',   '',    'filtered',        0]],
    '01091' => [['5.0.900', '',    'undefined',       0]],
    '01092' => [['5.0.900', '',    'undefined',       0]],
    '01093' => [['5.2.0',   '',    'filtered',        0]],
    '01095' => [['5.1.0',   '550', 'userunknown',     1]],
    '01096' => [['5.2.0',   '',    'filtered',        0]],
    '01097' => [['5.1.0',   '550', 'userunknown',     1]],
    '01098' => [['5.2.0',   '',    'filtered',        0]],
    '01099' => [['4.7.0',   '',    'securityerror',   0]],
    '01100' => [['4.7.0',   '',    'securityerror',   0]],
    '01101' => [['5.2.0',   '',    'filtered',        0]],
    '01102' => [['5.3.0',   '553', 'userunknown',     1]],
    '01103' => [['5.0.947', '',    'expired',         0]],
    '01104' => [['5.2.0',   '',    'filtered',        0]],
    '01105' => [['5.0.910', '',    'filtered',        0]],
    '01106' => [['5.0.947', '',    'expired',         0]],
    '01107' => [['5.2.0',   '',    'filtered',        0]],
    '01108' => [['5.0.900', '',    'undefined',       0]],
    '01111' => [['5.0.922', '',    'mailboxfull',     0]],
    '01112' => [['5.1.0',   '550', 'userunknown',     1]],
    '01113' => [['5.2.0',   '',    'filtered',        0]],
    '01114' => [['5.0.930', '',    'systemerror',     0]],
    '01117' => [['5.0.934', '553', 'mesgtoobig',      0]],
    '01118' => [['4.4.1',   '',    'expired',         0]],
    '01120' => [['5.2.0',   '',    'filtered',        0]],
    '01121' => [['4.4.0',   '',    'expired',         0]],
    '01122' => [['5.0.911', '550', 'userunknown',     1]],
    '01123' => [['4.4.1',   '',    'expired',         0]],
    '01124' => [['4.0.0',   '',    'mailererror',     0]],
    '01125' => [['5.0.944', '',    'networkerror',    0]],
    '01126' => [['5.1.1',   '550', 'userunknown',     1]],
    '01127' => [['5.2.0',   '',    'filtered',        0]],
    '01128' => [['5.0.930', '',    'systemerror',     0],
                ['5.0.901', '',    'onhold',          0]],
    '01129' => [['5.1.1',   '',    'userunknown',     1]],
    '01130' => [['5.0.930', '',    'systemerror',     0]],
    '01131' => [['5.1.1',   '550', 'userunknown',     1]],
    '01132' => [['5.0.930', '',    'systemerror',     0]],
    '01133' => [['5.0.930', '',    'systemerror',     0]],
    '01134' => [['5.2.0',   '',    'filtered',        0]],
    '01135' => [['5.1.1',   '550', 'userunknown',     1]],
    '01136' => [['5.0.900', '',    'undefined',       0]],
    '01138' => [['5.1.1',   '550', 'userunknown',     1]],
    '01139' => [['4.4.1',   '',    'expired',         0]],
    '01140' => [['5.2.0',   '',    'filtered',        0]],
    '01142' => [['5.2.0',   '',    'filtered',        0]],
    '01143' => [['5.0.900', '',    'undefined',       0]],
    '01146' => [['5.0.922', '',    'mailboxfull',     0]],
    '01148' => [['5.0.922', '',    'mailboxfull',     0]],
    '01149' => [['4.4.7',   '',    'expired',         0]],
    '01150' => [['5.0.922', '',    'mailboxfull',     0]],
    '01153' => [['5.0.972', '',    'policyviolation', 0]],
    '01154' => [['5.1.1',   '',    'userunknown',     1]],
    '01155' => [['5.4.6',   '554', 'networkerror',    0]],
    '01156' => [['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0],
                ['5.7.1',   '550', 'spamdetected',    0]],
    '01157' => [['5.3.0',   '',    'filtered',        0]],
    '01158' => [['5.0.947', '',    'expired',         0],
                ['5.0.901', '',    'onhold',          0]],
    '01159' => [['5.1.1',   '550', 'mailboxfull',     0]],
    '01160' => [['5.0.910', '',    'filtered',        0]],
    '01163' => [['5.1.1',   '550', 'mesgtoobig',      0]],
    '01164' => [['5.1.1',   '550', 'userunknown',     1]],
    '01165' => [['5.0.944', '554', 'networkerror',    0]],
    '01166' => [['5.0.930', '',    'systemerror',     0]],
    '01167' => [['5.0.912', '',    'hostunknown',     1]],
    '01168' => [['5.0.922', '',    'mailboxfull',     0]],
    '01169' => [['5.0.911', '550', 'userunknown',     1]],
    '01170' => [['5.0.901', '',    'onhold',          0]],
    '01171' => [['5.0.901', '',    'onhold',          0]],
    '01172' => [['5.0.922', '552', 'mailboxfull',     0]],
    '01173' => [['5.0.944', '554', 'networkerror',    0]],
    '01175' => [['5.0.910', '',    'filtered',        0]],
    '01177' => [['5.0.918', '',    'rejected',        0],
                ['5.0.901', '',    'onhold',          0]],
    '01179' => [['5.1.1',   '550', 'userunknown',     1]],
    '01180' => [['5.0.922', '',    'mailboxfull',     0]],
    '01181' => [['5.0.910', '550', 'filtered',        0]],
    '01182' => [['5.0.901', '',    'onhold',          0]],
    '01183' => [['5.0.922', '',    'mailboxfull',     0]],
    '01184' => [['5.0.901', '',    'onhold',          0],
                ['5.0.901', '',    'onhold',          0]],
    '01212' => [['4.2.2',   '',    'mailboxfull',     0]],
    '01213' => [['5.0.0',   '501', 'spamdetected',    0]],
    '01216' => [['5.0.901', '',    'onhold',          0]],
    '01217' => [['5.1.1',   '550', 'userunknown',     1]],
    '01218' => [['5.0.945', '',    'toomanyconn',     0]],
    '01219' => [['5.0.901', '',    'onhold',          0]],
    '01220' => [['5.2.0',   '',    'filtered',        0]],
    '01222' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01223' => [['4.0.0',   '',    'mailboxfull',     0]],
    '01224' => [['5.1.1',   '550', 'authfailure',     0]],
    '01225' => [['4.4.7',   '',    'expired',         0]],
    '01227' => [['5.5.0',   '',    'userunknown',     1],
                ['5.5.0',   '',    'userunknown',     1]],
    '01228' => [['5.0.901', '',    'onhold',          0]],
    '01229' => [['5.2.0',   '',    'filtered',        0]],
    '01230' => [['5.2.0',   '',    'filtered',        0]],
    '01232' => [['5.0.944', '554', 'networkerror',    0]],
    '01233' => [['5.5.0',   '554', 'mailererror',     0]],
    '01234' => [['5.0.901', '',    'onhold',          0],
                ['5.0.911', '550', 'userunknown',     1],
                ['5.0.911', '550', 'userunknown',     1]],
    '01235' => [['5.0.0',   '550', 'filtered',        0],
                ['5.0.0',   '550', 'filtered',        0],
                ['5.0.0',   '550', 'filtered',        0],
                ['5.0.0',   '550', 'filtered',        0]],
    '01236' => [['5.1.1',   '',    'userunknown',     1]],
    '01237' => [['5.1.1',   '',    'userunknown',     1]],
    '01238' => [['5.1.1',   '',    'userunknown',     1]],
    '01239' => [['5.1.1',   '',    'userunknown',     1]],
    '01240' => [['5.1.1',   '',    'userunknown',     1]],
    '01241' => [['5.1.1',   '',    'userunknown',     1]],
    '01242' => [['5.1.1',   '',    'userunknown',     1]],
    '01243' => [['5.5.0',   '503', 'syntaxerror',     0]],
    '01244' => [['5.2.2',   '',    'mailboxfull',     0]],
    '01245' => [['5.2.2',   '',    'mailboxfull',     0]],
    '01246' => [['5.1.1',   '',    'userunknown',     1]],
    '01247' => [['5.1.1',   '',    'userunknown',     1],
                ['5.1.1',   '',    'userunknown',     1]],
    '01248' => [['5.2.2',   '',    'mailboxfull',     0]],
    '01249' => [['5.5.0',   '503', 'syntaxerror',     0]],
    '01250' => [['5.0.922', '',    'mailboxfull',     0]],
    '01251' => [['5.2.2',   '552', 'mailboxfull',     0]],
    '01252' => [['5.0.944', '554', 'networkerror',    0]],
    '01253' => [['5.0.912', '',    'hostunknown',     1]],
    '01255' => [['4.4.7',   '',    'expired',         0]],
    '01260' => [['5.0.945', '',    'toomanyconn',     0]],
    '01262' => [['5.0.947', '',    'expired',         0]],
    '01263' => [['4.4.1',   '',    'networkerror',    0]],
    '01265' => [['5.0.0',   '554', 'policyviolation', 0]],
    '01266' => [['4.7.0',   '',    'policyviolation', 0]],
    '01267' => [['5.1.6',   '550', 'hasmoved',        1]],
    '01268' => [['5.7.1',   '554', 'spamdetected',    0]],
    '01271' => [['5.1.1',   '550', 'userunknown',     1]],
    '01272' => [['5.0.980', '554', 'spamdetected',    0]],
    '01273' => [['4.3.0',   '',    'mailboxfull',     0]],
    '01274' => [['4.2.2',   '',    'mailboxfull',     0]],
    '01275' => [['5.0.971', '',    'virusdetected',   0]],
    '01276' => [['5.0.910', '',    'filtered',        0]],
    '01277' => [['5.0.0',   '550', 'rejected',        0],
                ['4.0.0',   '',    'expired',         0],
                ['5.0.0',   '550', 'filtered',        0]],
    '01278' => [['4.0.0',   '',    'expired',         0]],
    '01279' => [['4.4.6',   '',    'networkerror',    0]],
    '01280' => [['5.4.0',   '',    'networkerror',    0]],
    '01282' => [['5.1.1',   '550', 'userunknown',     1]],
    '01283' => [['5.0.947', '',    'expired',         0]],
    '01284' => [['5.0.972', '',    'policyviolation', 0]],
    '01285' => [['5.7.0',   '554', 'spamdetected',    0]],
    '01286' => [['5.5.0',   '550', 'rejected',        0]],
    '01287' => [['5.0.0',   '550', 'filtered',        0]],
    '01288' => [['5.3.0',   '552', 'exceedlimit',     0]],
    '01289' => [['4.0.0',   '',    'notaccept',       0]],
    '01290' => [['4.3.0',   '451', 'onhold',          0]],
};

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

