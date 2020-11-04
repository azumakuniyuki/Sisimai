use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-lhost-code';

my $enginename = 'X3';
my $enginetest = Sisimai::Lhost::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]3[.]0\z/,    'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.]0[.]\d+\z/,  'r' => qr/expired/,     'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]3[.]0\z/,    'r' => qr/userunknown/, 'b' => qr/\A0\z/ },
    { 'n' => '05', 's' => qr/\A5[.]0[.]\d+\z/,  'r' => qr/undefined/,   'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]2[.]2\z/,    'r' => qr/mailboxfull/, 'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;

