package Sisimai::Lhost::DragonFly;
use parent 'Sisimai::Lhost';
use v5.26;
use strict;
use warnings;

sub description { 'DragonFly' }
sub inquire {
    # Detect an error from DMA: DragonFly Mail Agent
    # @param    [Hash] mhead    Message headers of a bounce email
    # @param    [String] mbody  Message body of a bounce email
    # @return   [Hash]          Bounce data list and message/rfc822 part
    # @return   [undef]         failed to parse or the arguments are missing
    # @since v5.0.4
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless index($mhead->{'subject'}, 'Mail delivery failed') > -1;
    return undef unless grep { rindex($_, ' (DragonFly Mail Agent') > -1 } $mhead->{'received'}->@*;

    state $indicators = __PACKAGE__->INDICATORS;
    state $boundaries = ['Original message follows.', 'Message headers follow'];
    state $startingof = {
        # https://github.com/corecode/dma/blob/ffad280aa40c242aa9a2cb9ca5b1b6e8efedd17e/mail.c#L84
        'message' => ['This is the DragonFly Mail Agent '],
    };
    state $messagesof = {
        'expired'     => [
            # https://github.com/corecode/dma/blob/master/dma.c#L370C1-L374C19
            # dma.c:370| if (gettimeofday(&now, NULL) == 0 &&
            # dma.c:371|     (now.tv_sec - st.st_mtim.tv_sec > MAX_TIMEOUT)) {
            # dma.c:372|     snprintf(errmsg, sizeof(errmsg),
            # dma.c:373|          "Could not deliver for the last %d seconds. Giving up.",
            # dma.c:374|          MAX_TIMEOUT);
            # dma.c:375|     goto bounce;
            # dma.c:376| }
            'Could not deliver for the last ',
        ],
        'hostunknown' => [
            # net.c:663| snprintf(errmsg, sizeof(errmsg), "DNS lookup failure: host %s not found", host);
            'DNS lookup failure: host ',
        ],
    };

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailparts = Sisimai::RFC5322->part($mbody, $boundaries);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $v = undef;

    require Sisimai::Address;
    require Sisimai::SMTP::Command;

    for my $e ( split("\n", $emailparts->[0]) ) {
        # Read error messages and delivery status lines from the head of the email to the previous
        # line of the beginning of the original message.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            $readcursor |= $indicators->{'deliverystatus'} if index($e, $startingof->{'message'}->[0]) == 0;
            next;
        }
        next unless $readcursor & $indicators->{'deliverystatus'};
        next unless length $e;

        # This is the DragonFly Mail Agent v0.13 at df.example.jp.
        #
        # There was an error delivering your mail to <kijitora@example.com>.
        #
        # email.example.jp [192.0.2.25] did not like our RCPT TO:
        # 552 5.2.2 <kijitora@example.com>: Recipient address rejected: Mailbox full
        #
        # Original message follows.
        $v = $dscontents->[-1];

        if( index($e, 'There was an error delivering your mail to <') == 0 ) {
            # email.example.jp [192.0.2.25] did not like our RCPT TO:
            # 552 5.2.2 <kijitora@example.com>: Recipient address rejected: Mailbox full
            if( $v->{'recipient'} ) {
                # There are multiple recipient addresses in the message body.
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }
            $v->{'recipient'} = Sisimai::Address->s3s4(substr($e, index($e, '<'), -1));
            $recipients++;

        } else {
            # Pick the error message
            $v->{'diagnosis'} .= $e;

            # Pick the remote hostname, and the SMTP command
            # net.c:500| snprintf(errmsg, sizeof(errmsg), "%s [%s] did not like our %s:\n%s",
            next if index($e, ' did not like our ') < 0;
            next if length $v->{'rhost'} > 0;

            my $p = [split(' ', $e, 3)];
            $v->{'rhost'}   = index($p->[0], '.') > 1 ? $p->[0] : $p->[1];
            $v->{'command'} = Sisimai::SMTP::Command->find($e) || '';
        }
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        SESSION: for my $r ( keys %$messagesof ) {
            # Verify each regular expression of session errors
            next unless grep { index($e->{'diagnosis'}, $_) > -1 } $messagesof->{ $r }->@*;
            $e->{'reason'} = $r;
            last;
        }
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailparts->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::DragonFly - bounce mail parser class for C<DMA: DragonFly Mail Agent>.

=head1 SYNOPSIS

    use Sisimai::Lhost::DragonFly;

=head1 DESCRIPTION

C<Sisimai::Lhost::DragonFly> parses a bounce email which created by C<DMA: DragonFly Mail Agent>.
Methods in the module are called from only C<Sisimai::Message>.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::DragonFly->description;

=head2 C<B<inquire(I<header data>, I<reference to body string>)>>

C<inquire()> method parses a bounced email and return results as an array reference.
See C<Sisimai::Message> for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

