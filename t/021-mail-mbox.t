use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::Mail::Mbox;

my $PackageName = 'Sisimai::Mail::Mbox';
my $MethodNames = {
    'class'  => ['new'],
    'object' => ['path', 'dir', 'file', 'size', 'handle', 'offset', 'read'],
};
my $SampleEmail = './set-of-emails/mailbox/mbox-0';
my $NewInstance = $PackageName->new($SampleEmail);

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };
isa_ok $NewInstance, $PackageName;
can_ok $NewInstance, @{ $MethodNames->{'object'} };

MAKE_TEST: {
    MAILBOX: {
        my $mailbox = $PackageName->new($SampleEmail);
        my $emindex = 0;

        isa_ok $mailbox, $PackageName;
        can_ok $mailbox, @{ $MethodNames->{'object'} };
        is $mailbox->dir, './set-of-emails/mailbox', '->dir = ./set-of-emails/mailbox';
        is $mailbox->path, $SampleEmail, '->path = '.$SampleEmail;
        is $mailbox->file, 'mbox-0', '->file = mbox-0';
        is $mailbox->size, -s $SampleEmail, '->size = 96906';
        isa_ok $mailbox->handle, 'IO::File';
        is $mailbox->offset, 0, '->offset = 0';

        while( my $r = $mailbox->read ) {
            ok length $r, 'mailbox->read('.($emindex + 1).')';
            ok $mailbox->offset, '->offset = '.$mailbox->offset;
            $emindex++;
        }
        is $mailbox->offset, -s $SampleEmail;
        is $emindex, 37;
    }
}

done_testing;

