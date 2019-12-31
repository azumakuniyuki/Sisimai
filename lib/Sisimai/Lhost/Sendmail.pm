package Sisimai::Lhost::Sendmail;
use parent 'Sisimai::Lhost';
use feature ':5.10';
use strict;
use warnings;

my $MarkingsOf = {
    # Content-Type: message/rfc822 OR text/rfc822-headers
    'rfc822' => qr{^Content-Type:\s*(?:message|text)/rfc822(?:-headers)?}ms,
};
my $StartingOf = {
    # Error text regular expressions which defined in sendmail/savemail.c
    #   savemail.c:1040|if (printheader && !putline("   ----- Transcript of session follows -----\n",
    #   savemail.c:1041|          mci))
    #   savemail.c:1042|  goto writeerr;
    #   savemail.c:1360|if (!putline(
    #   savemail.c:1361|    sendbody
    #   savemail.c:1362|    ? "   ----- Original message follows -----\n"
    #   savemail.c:1363|    : "   ----- Message header follows -----\n",
    'rfc822'  => ['Content-Type: message/rfc822', 'Content-Type: text/rfc822-headers'],
    'message' => ['   ----- Transcript of session follows -----'],
    'error'   => ['... while talking to '],
};

sub description { 'V8Sendmail: /usr/sbin/sendmail' }
sub make {
    # Parse bounce messages from Sendmail
    # @param         [Hash] mhead       Message header of a bounce email
    # @options mhead [String] from      From header
    # @options mhead [String] date      Date header
    # @options mhead [String] subject   Subject header
    # @options mhead [Array]  received  Received headers
    # @options mhead [String] others    Other required headers
    # @param         [String] mbody     Message body of a bounce email
    # @return        [Hash, Undef]      Bounce data list and message/rfc822 part
    #                                   or Undef if it failed to parse or the
    #                                   arguments are missing
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;

    return undef unless $mhead->{'subject'} =~ /(?:see transcript for details\z|\AWarning: )/;
    unless( lc($mhead->{'subject'}) =~ /\A[ \t]*fwd?:/ ) {
        # Fwd: Returned mail: see transcript for details
        # Do not execute this code if the bounce mail is a forwarded message.
        return undef unless index($mhead->{'from'}, 'Mail Delivery Subsystem') > -1;
    }

    require Sisimai::RFC1894;
    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $permessage = {};    # (Hash) Store values of each Per-Message field

    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $dsmessages = '';    # (String) Inside of $StartingOf, $MarkingsOf
    my $rfc822text = '';    # (String) message/rfc822 part string
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $commandtxt = '';    # (String) SMTP Command name begin with the string '>>>'
    my $esmtpreply = [];    # (Array) Reply from remote server on SMTP session
    my $sessionerr = 0;     # (Integer) Flag, 1 if it is SMTP session error
    my $anotherset = {};    # (Hash) Another error information
    my $v = undef;
    my $p = '';

    ($dsmessages, $rfc822text) = split($MarkingsOf->{'rfc822'}, $$mbody, 2);
    $dsmessages =~ s/\A.+$StartingOf->{'message'}->[0]//ms;

    for my $e ( split("\n", $dsmessages) ) {
        # Read each line of message/delivery-status part and error messages
        next unless length $e;

        if( my $f = Sisimai::RFC1894->match($e) ) {
            # $e matched with any field defined in RFC3464
            next unless my $o = Sisimai::RFC1894->field($e);
            $v = $dscontents->[-1];

            if( $o->[-1] eq 'addr' ) {
                # Final-Recipient: rfc822; kijitora@example.jp
                # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                if( $o->[0] eq 'final-recipient' ) {
                    # Final-Recipient: rfc822; kijitora@example.jp
                    if( $v->{'recipient'} ) {
                        # There are multiple recipient addresses in the message body.
                        push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                        $v = $dscontents->[-1];
                    }
                    $v->{'recipient'} = $o->[2];
                    $recipients++;

                } else {
                    # X-Actual-Recipient: rfc822; kijitora@example.co.jp
                    $v->{'alias'} = $o->[2];
                }
            } elsif( $o->[-1] eq 'code' ) {
                # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                $v->{'spec'} = $o->[1];
                $v->{'diagnosis'} = $o->[2];

            } else {
                # Other DSN fields defined in RFC3464
                next unless exists $fieldtable->{ $o->[0] };
                $v->{ $fieldtable->{ $o->[0] } } = $o->[2];

                next unless $f == 1;
                $permessage->{ $fieldtable->{ $o->[0] } } = $o->[2];
            }
        } else {
            # The line does not begin with a DSN field defined in RFC3464
            #
            # ----- Transcript of session follows -----
            # ... while talking to mta.example.org.:
            # >>> DATA
            # <<< 550 Unknown user recipient@example.jp
            # 554 5.0.0 Service unavailable
            if( substr($e, 0, 1) ne ' ') {
                # Other error messages
                if( $e =~ /\A[>]{3}[ ]+([A-Z]{4})[ ]?/ ) {
                    # >>> DATA
                    $commandtxt = $1;

                } elsif( $e =~ /\A[<]{3}[ ]+(.+)\z/ ) {
                    # <<< Response
                    push @$esmtpreply, $1 unless grep { $1 eq $_ } @$esmtpreply;

                } else {
                    # Detect SMTP session error or connection error
                    next if $sessionerr;
                    if( index($e, $StartingOf->{'error'}->[0]) == 0 ) {
                        # ----- Transcript of session follows -----
                        # ... while talking to mta.example.org.:
                        $sessionerr = 1;
                        next;
                    }

                    if( $e =~ /\A[<](.+)[>][.]+ (.+)\z/ ) {
                        # <kijitora@example.co.jp>... Deferred: Name server: example.co.jp.: host name lookup failure
                        $anotherset->{'recipient'} = $1;
                        $anotherset->{'diagnosis'} = $2;

                    } else {
                        # ----- Transcript of session follows -----
                        # Message could not be delivered for too long
                        # Message will be deleted from queue
                        if( $e =~ /\A[45]\d\d[ \t]([45][.]\d[.]\d)[ \t].+/ ) {
                            # 550 5.1.2 <kijitora@example.org>... Message
                            #
                            # DBI connect('dbname=...')
                            # 554 5.3.0 unknown mailer error 255
                            $anotherset->{'status'} = $1;
                            $anotherset->{'diagnosis'} .= ' '.$e;

                        } elsif( index($e, 'Message: ') == 0 || index($e, 'Warning: ') == 0 ) {
                            # Message could not be delivered for too long
                            # Warning: message still undelivered after 4 hours
                            $anotherset->{'diagnosis'} .= ' '.$e;
                        }
                    }
                }
            } else {
                # Continued line of the value of Diagnostic-Code field
                next unless index($p, 'Diagnostic-Code:') == 0;
                next unless $e =~ /\A[ \t]+(.+)\z/;
                $v->{'diagnosis'} .= ' '.$1;
            }
        } # End of message/delivery-status
    } continue {
        # Save the current line for the next loop
        $p = $e;
    }
    return undef unless $recipients;

    for my $e ( @$dscontents ) {
        # Set default values if each value is empty.
        $e->{'lhost'}    ||= $permessage->{'rhost'};
        map { $e->{ $_ } ||= $permessage->{ $_ } || '' } keys %$permessage;
        $e->{'agent'}      = __PACKAGE__->smtpagent;
        $e->{'command'}  ||= $commandtxt || '';
        $e->{'command'}  ||= 'EHLO' if scalar @$esmtpreply;

        if( exists $anotherset->{'diagnosis'} && $anotherset->{'diagnosis'} ) {
            # Copy alternative error message
            $e->{'diagnosis'}   = $anotherset->{'diagnosis'} if $e->{'diagnosis'} =~ /\A[ \t]+\z/;
            $e->{'diagnosis'} ||= $anotherset->{'diagnosis'};
            $e->{'diagnosis'}   = $anotherset->{'diagnosis'} if $e->{'diagnosis'} =~ /\A\d+\z/;
        }
        if( scalar @$esmtpreply ) {
            # Replace the error message in "diagnosis" with the ESMTP Reply
            my $r = join(' ', @$esmtpreply);
            $e->{'diagnosis'} = $r if length($r) > length($e->{'diagnosis'});
        }
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'});

        if( exists $anotherset->{'status'} && $anotherset->{'status'} ) {
            # Check alternative status code
            if( ! $e->{'status'} || $e->{'status'} !~ /\A[45][.]\d[.]\d\z/ ) {
                # Override alternative status code
                $e->{'status'} = $anotherset->{'status'};
            }
        }

        # @example.jp, no local part
        # Get email address from the value of Diagnostic-Code header
        next if $e->{'recipient'} =~ /\A[^ ]+[@][^ ]+\z/;
        $e->{'recipient'} = $1 if $e->{'diagnosis'} =~ /[<]([^ ]+[@][^ ]+)[>]/;
    }
    return { 'ds' => $dscontents, 'rfc822' => $rfc822text };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::Sendmail - bounce mail parser class for v8 Sendmail.

=head1 SYNOPSIS

    use Sisimai::Lhost::Sendmail;

=head1 DESCRIPTION

Sisimai::Lhost::Sendmail parses a bounce email which created by v8 Sendmail.
Methods in the module are called from only Sisimai::Message.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Sendmail->description;

=head2 C<B<smtpagent()>>

C<smtpagent()> returns MTA name.

    print Sisimai::Lhost::Sendmail->smtpagent;

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
