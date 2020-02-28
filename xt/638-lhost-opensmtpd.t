use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'OpenSMTPD';
my $samplepath = sprintf("./set-of-emails/private/lhost-%s", lc $enginename);
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01001', 'r' => qr/userunknown/  },
    { 'n' => '01002', 'r' => qr/filtered/     },
    { 'n' => '01003', 'r' => qr/mailboxfull/  },
    { 'n' => '01004', 'r' => qr/filtered/     },
    { 'n' => '01005', 'r' => qr/filtered/     },
    { 'n' => '01006', 'r' => qr/expired/      },
    { 'n' => '01007', 'r' => qr/userunknown/  },
    { 'n' => '01008', 'r' => qr/(?:mailboxfull|userunknown)/ },
    { 'n' => '01009', 'r' => qr/hostunknown/  },
    { 'n' => '01010', 'r' => qr/networkerror/ },
    { 'n' => '01011', 'r' => qr/userunknown/  },
    { 'n' => '01012', 'r' => qr/(?:mailboxfull|userunknown)/ },
    { 'n' => '01013', 'r' => qr/hostunknown/  },
    { 'n' => '01014', 'r' => qr/expired/ },
    { 'n' => '01015', 'r' => qr/networkerror/ },
];

plan 'skip_all', sprintf("%s not found", $samplepath) unless -d $samplepath;
$enginetest->($enginename, $isexpected, 1, 0);
done_testing;

