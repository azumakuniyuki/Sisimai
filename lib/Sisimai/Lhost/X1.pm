package Sisimai::Lhost::X1;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $Indicators = __PACKAGE__->INDICATORS;
my $MarkingsOf = {
    'message' => qr/\AThe original message was received at (.+)\z/,
    'rfc822'  => qr/\AReceived: from \d+[.]\d+[.]\d+[.]\d/,
};

sub description { 'Unknown MTA #1' }
sub make {
    # Detect an error from Unknown MTA #1
    # @param         [Hash] mhead       Message headers of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.1.3
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless index($mhead->{'subject'}, 'Returned Mail: ') == 0;
    return undef unless index($mhead->{'from'}, '"Mail Deliver System" ') == 0;

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $rfc822list = [];    # (Array) Each line in message/rfc822 part string
    my $blanklines = 0;     # (Integer) The number of blank lines
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $datestring = '';    # (String) Date string
    my $v = undef;

    for my $e ( split("\n", $$mbody) ) {
        # Read each line between the start of the message and the start of rfc822 part.
        unless( $readcursor ) {
            # Beginning of the bounce message or delivery status part
            if( $e =~ $MarkingsOf->{'message'} ) {
                $readcursor |= $Indicators->{'deliverystatus'};
                next;
            }
        }

        unless( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Beginning of the original message part
            if( $e =~ $MarkingsOf->{'rfc822'} ) {
                $readcursor |= $Indicators->{'message-rfc822'};
                next;
            }
        }

        if( $readcursor & $Indicators->{'message-rfc822'} ) {
            # Inside of the original message part
            unless( length $e ) {
                last if ++$blanklines > 1;
                next;
            }
            push @$rfc822list, $e;

        } else {
            # Error message part
            next unless $readcursor & $Indicators->{'deliverystatus'};
            next unless length $e;

            # The original message was received at Thu, 29 Apr 2010 23:34:45 +0900 (JST)
            # from shironeko@example.jp
            #
            # ---The following addresses had delivery errors---
            #
            # kijitora@example.co.jp [User unknown]
            $v = $dscontents->[-1];

            if( $e =~ /\A([^ ]+?[@][^ ]+?)[ \t]+\[(.+)\]\z/ ) {
                # kijitora@example.co.jp [User unknown]
                if( $v->{'recipient'} ) {
                    # There are multiple recipient addresses in the message body.
                    push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                    $v = $dscontents->[-1];
                }
                $v->{'recipient'} = $1;
                $v->{'diagnosis'} = $2;
                $recipients++;

            } elsif( $e =~ $MarkingsOf->{'message'} ) {
                # The original message was received at Thu, 29 Apr 2010 23:34:45 +0900 (JST)
                $datestring = $1;
            }
        } # End of error message part
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});
        $e->{'date'}      = $datestring || '';
        $e->{'agent'}     = __PACKAGE__->smtpagent;
    }
    return { 'ds' => $dscontents, 'rfc822' => ${ Sisimai::RFC5322->weedout($rfc822list) } };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::X1 - bounce mail parser class for C<X1>.

=head1 SYNOPSIS

    use Sisimai::Lhost::X1;

=head1 DESCRIPTION

Sisimai::Lhost::X1 parses a bounce email which created by Unknown MTA #1.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::X1->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::X1->smtpagent;

=head2 C<B<make(I<header data>, I<reference to body string>)>>

C<make()> method parses a bounced email and return results as a array reference.
See Sisimai::Message for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2019 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

