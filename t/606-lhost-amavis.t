use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'Amavis';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]1[.]1\z/, 'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '03', 's' => qr/\A5[.]7[.]0\z/, 'r' => qr/spamdetected/,'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

