package Sisimai::Lhost::Exim;
use parent 'Sisimai::Lhost';
use v5.26;
use strict;
use warnings;

sub description { 'Exim' }
sub inquire {
    # Detect an error from Exim Internet Mailer
    # @param    [Hash] mhead    Message headers of a bounce email
    # @param    [String] mbody  Message body of a bounce email
    # @return   [Hash]          Bounce data list and message/rfc822 part
    # @return   [undef]         failed to decode or the arguments are missing
    # @since v4.0.0
    my $class = shift;
    my $mhead = shift // return undef;
    my $mbody = shift // return undef;
    return undef if index($mhead->{'from'}, '.mail.ru') > 0;

    # Message-Id: <E1P1YNN-0003AD-Ga@example.org>
    # X-Failed-Recipients: kijitora@example.ed.jp
    my $match = 0;
    my $msgid = $mhead->{'message-id'} || '';
    $match++ if index($mhead->{'from'}, 'Mail Delivery System') == 0;
    $match++ if index($msgid, '<') == 0 && index($msgid, '-') == 8 && index($msgid, '@') == 18;
    $match++ if grep { index($mhead->{'subject'}, $_) > -1 } ( 'Delivery Status Notification',
                                                               'Mail delivery failed',
                                                               'Mail failure',
                                                               'Message frozen',
                                                               'Warning: message ',
                                                               'error(s) in forwarding or filtering');
    return undef if $match < 2;

    state $indicators = __PACKAGE__->INDICATORS;
    state $boundaries = [
        # deliver.c:6423|          if (bounce_return_body) fprintf(f,
        # deliver.c:6424|"------ This is a copy of the message, including all the headers. ------\n");
        # deliver.c:6425|          else fprintf(f,
        # deliver.c:6426|"------ This is a copy of the message's headers. ------\n");
        '------ This is a copy of the message, including all the headers. ------',
        'Content-Type: message/rfc822',
    ];
    state $startingof = {
        # Error text strings which defined in exim/src/deliver.c
        #
        # deliver.c:6292| fprintf(f,
        # deliver.c:6293|"This message was created automatically by mail delivery software.\n");
        # deliver.c:6294|        if (to_sender)
        # deliver.c:6295|          {
        # deliver.c:6296|          fprintf(f,
        # deliver.c:6297|"\nA message that you sent could not be delivered to one or more of its\n"
        # deliver.c:6298|"recipients. This is a permanent error. The following address(es) failed:\n");
        # deliver.c:6299|          }
        # deliver.c:6300|        else
        # deliver.c:6301|          {
        # deliver.c:6302|          fprintf(f,
        # deliver.c:6303|"\nA message sent by\n\n  <%s>\n\n"
        # deliver.c:6304|"could not be delivered to one or more of its recipients. The following\n"
        # deliver.c:6305|"address(es) failed:\n", sender_address);
        # deliver.c:6306|          }
        'deliverystatus' => ['Content-Type: message/delivery-status'],
        'frozen'         => [' has been frozen', ' was frozen on arrival'],
        'message'        => [
            'This message was created automatically by mail delivery software.',
            'A message that you sent was rejected by the local scannning code',
            'A message that you sent contained one or more recipient addresses ',
            'A message that you sent could not be delivered to all of its recipients',
            ' has been frozen',
            ' was frozen on arrival',
            ' router encountered the following error(s):',
        ],
    };
    state $markingsof = { 'alias' => ' an undisclosed address' };
    state $recommands = [
        # transports/smtp.c:564|  *message = US string_sprintf("SMTP error from remote mail server after %s%s: "
        # transports/smtp.c:837|  string_sprintf("SMTP error from remote mail server after RCPT TO:<%s>: "
        qr/SMTP error from remote (?:mail server|mailer) after ([A-Za-z]{4})/,
        qr/SMTP error from remote (?:mail server|mailer) after end of ([A-Za-z]{4})/,
        qr/LMTP error after ([A-Za-z]{4})/,
        qr/LMTP error after end of ([A-Za-z]{4})/,
    ];
    state $messagesof = {
        # find exim/ -type f -exec grep 'message = US' {} /dev/null \;
        # route.c:1158|  DEBUG(D_uid) debug_printf("getpwnam() returned NULL (user not found)\n");
        'userunknown' => ['user not found'],
        # transports/smtp.c:3524|  addr->message = US"all host address lookups failed permanently";
        # routers/dnslookup.c:331|  addr->message = US"all relevant MX records point to non-existent hosts";
        # route.c:1826|  uschar *message = US"Unrouteable address";
        'hostunknown' => [
            'all host address lookups failed permanently',
            'all relevant MX records point to non-existent hosts',
            'Unrouteable address',
        ],
        # transports/appendfile.c:2567|  addr->user_message = US"mailbox is full";
        # transports/appendfile.c:3049|  addr->message = string_sprintf("mailbox is full "
        # transports/appendfile.c:3050|  "(quota exceeded while writing to file %s)", filename);
        'mailboxfull' => [
            'mailbox is full',
            'error: quota exceed',
        ],
        # routers/dnslookup.c:328|  addr->message = US"an MX or SRV record indicated no SMTP service";
        # transports/smtp.c:3502|  addr->message = US"no host found for existing SMTP connection";
        'notaccept' => [
            'an MX or SRV record indicated no SMTP service',
            'no host found for existing SMTP connection',
        ],
        # parser.c:666| *errorptr = string_sprintf("%s (expected word or \"<\")", *errorptr);
        # parser.c:701| if(bracket_count++ > 5) FAILED(US"angle-brackets nested too deep");
        # parser.c:738| FAILED(US"domain missing in source-routed address");
        # parser.c:747| : string_sprintf("malformed address: %.32s may not follow %.*s",
        'syntaxerror' => [
            'angle-brackets nested too deep',
            'expected word or "<"',
            'domain missing in source-routed address',
            'malformed address:',
        ],
        # deliver.c:5614|  addr->message = US"delivery to file forbidden";
        # deliver.c:5624|  addr->message = US"delivery to pipe forbidden";
        # transports/pipe.c:1156|  addr->user_message = US"local delivery failed";
        'systemerror' => [
            'delivery to file forbidden',
            'delivery to pipe forbidden',
            'local delivery failed',
            'LMTP error after ',
        ],
        # deliver.c:5425|  new->message = US"Too many \"Received\" headers - suspected mail loop";
        'contenterror' => ['Too many "Received" headers'],
    };
    state $delayedfor = [
        # retry.c:902|  addr->message = (addr->message == NULL)? US"retry timeout exceeded" :
        # deliver.c:7475|  "No action is required on your part. Delivery attempts will continue for\n"
        # smtp.c:3508|  US"retry time not reached for any host after a long failure period" :
        # smtp.c:3508|  US"all hosts have been failing for a long time and were last tried "
        #                 "after this message arrived";
        # deliver.c:7459|  print_address_error(addr, f, US"Delay reason: ");
        # deliver.c:7586|  "Message %s has been frozen%s.\nThe sender is <%s>.\n", message_id,
        # receive.c:4021|  moan_tell_someone(freeze_tell, NULL, US"Message frozen on arrival",
        # receive.c:4022|  "Message %s was frozen on arrival by %s.\nThe sender is <%s>.\n",
        'retry timeout exceeded',
        'No action is required on your part',
        'retry time not reached for any host after a long failure period',
        'all hosts have been failing for a long time and were last tried',
        'Delay reason: ',
        'has been frozen',
        'was frozen on arrival by ',
    ];

    my $fieldtable = Sisimai::RFC1894->FIELDTABLE;
    my $dscontents = [__PACKAGE__->DELIVERYSTATUS];
    my $emailparts = Sisimai::RFC5322->part($mbody, $boundaries);
    my $readcursor = 0;     # (Integer) Points the current cursor position
    my $nextcursor = 0;
    my $recipients = 0;     # (Integer) The number of 'Final-Recipient' header
    my $boundary00 = '';    # (String) Boundary string
    my $v = undef;

    if( $mhead->{'content-type'} ) {
        # Get the boundary string and set regular expression for matching with the boundary string.
        $boundary00 = Sisimai::RFC2045->boundary($mhead->{'content-type'});
    }

    my $p1 = -1; my $p2 = -1;
    for my $e ( split("\n", $emailparts->[0]) ) {
        # Read error messages and delivery status lines from the head of the email to the previous
        # line of the beginning of the original message.
        unless( $readcursor ) {
            # Beginning of the bounce message or message/delivery-status part
            if( grep { index($e, $_) > -1 } $startingof->{'message'}->@* ) {
                $readcursor |= $indicators->{'deliverystatus'};
                next unless grep { index($e, $_) > -1 } $startingof->{'frozen'}->@*;
            }
        }
        next unless $readcursor & $indicators->{'deliverystatus'};
        next unless length $e;

        # This message was created automatically by mail delivery software.
        #
        # A message that you sent could not be delivered to one or more of its
        # recipients. This is a permanent error. The following address(es) failed:
        #
        #  kijitora@example.jp
        #    SMTP error from remote mail server after RCPT TO:<kijitora@example.jp>:
        #    host neko.example.jp [192.0.2.222]: 550 5.1.1 <kijitora@example.jp>... User Unknown
        $v = $dscontents->[-1];

        my $cv = '';
        my $ce = 0;
        while(1) {
            # Check if the line matche the following patterns:
            last unless index($e, '  ')        ==  0;   # The line should start with "  " (2 spaces)
            last unless index($e, '@' )         >  1;   # "@" should be included (email)
            last unless index($e, '.' )         >  1;   # "." should be included (domain part)
            last unless index($e, 'pipe to |') == -1;   # Exclude "pipe to /path/to/prog" line

            my $cx = substr($e, 2, 1);
            last unless $cx ne ' ';
            last unless $cx ne '<';

            $ce = 1; last;
        }

        if( $ce == 1 || index($e, $markingsof->{'alias'}) > 0 ) {
            # The line is including an email address
            if( $v->{'recipient'} ) {
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
                $v = $dscontents->[-1];
            }

            if( index($e, $markingsof->{'alias'}) > 0 ) {
                # The line does not include an email address
                # deliver.c:4549|  printed = US"an undisclosed address";
                #   an undisclosed address
                #     (generated from kijitora@example.jp)
                $cv = substr($e, 2,);

            } else {
                #   kijitora@example.jp
                #   sabineko@example.jp: forced freeze
                #   mikeneko@example.jp <nekochan@example.org>: ...
                $p1 = index($e, ' <');
                $p2 = index($e, '>:');

                if( $p1 > 1 && $p2 > 1 ) {
                    # There are an email address and an error message in the line
                    # parser.c:743| while (bracket_count-- > 0) if (*s++ != '>')
                    # parser.c:744|   {
                    # parser.c:745|   *errorptr = s[-1] == 0
                    # parser.c:746|     ? US"'>' missing at end of address"
                    # parser.c:747|     : string_sprintf("malformed address: %.32s may not follow %.*s",
                    # parser.c:748|     s-1, (int)(s - US mailbox - 1), mailbox);
                    # parser.c:749|   goto PARSE_FAILED;
                    # parser.c:750|   }
                    $cv = Sisimai::Address->s3s4(substr($e, $p1 + 1, $p2 - $p1 - 1));
                    $v->{'diagnosis'} = Sisimai::String->sweep(substr($e, $p2 + 1,));

                } else {
                    # There is an email address only in the line
                    #   kijitora@example.jp
                    $cv = Sisimai::Address->s3s4(substr($e, 2,));
                }
            }
            $v->{'recipient'} = $cv;
            $recipients++;

        } elsif( index($e, ' (generated from ') > 0 || index($e, ' generated by ') > 0 ) {
            #     (generated from kijitora@example.jp)
            #  pipe to |/bin/echo "Some pipe output"
            #    generated by userx@myhost.test.ex
            $v->{'alias'} = Sisimai::Address->s3s4(substr($e, rindex($e, ' ') + 1,));

        } else {
            next unless length $e;

            if( grep { index($e, $_) > -1 } $startingof->{'frozen'}->@* ) {
                # Message *** has been frozen by the system filter.
                # Message *** was frozen on arrival by ACL.
                $v->{'alterrors'} .= $e.' ';

            } elsif( $boundary00 ) {
                # --NNNNNNNNNN-eximdsn-MMMMMMMMMM
                # Content-type: message/delivery-status
                # ...
                if( Sisimai::RFC1894->match($e) ) {
                    # $e matched with any field defined in RFC3464
                    next unless my $o = Sisimai::RFC1894->field($e);

                    if( $o->[-1] eq 'addr' ) {
                        # Final-Recipient: rfc822;|/bin/echo "Some pipe output"
                        next unless $o->[0] eq 'final-recipient';
                        $v->{'spec'} ||= rindex($o->[2], '@') > -1 ? 'SMTP' : 'X-UNIX';

                    } elsif( $o->[-1] eq 'code' ) {
                        # Diagnostic-Code: SMTP; 550 5.1.1 <userunknown@example.jp>... User Unknown
                        $v->{'spec'} = uc $o->[1];
                        $v->{'diagnosis'} = $o->[2];

                    } else {
                        # Other DSN fields defined in RFC3464
                        next unless exists $fieldtable->{ $o->[0] };
                        $v->{ $fieldtable->{ $o->[0] } } = $o->[2];
                    }
                } else {
                    # Error message ?
                    next if $nextcursor;
                    # Content-type: message/delivery-status
                    $nextcursor = 1 if index($e, $startingof->{'deliverystatus'}) == 0;
                    $v->{'alterrors'} .= $e.' ' if index($e, ' ') == 0;
                }
            } else {
                # There is no boundary string in $boundary00
                if( scalar @$dscontents == $recipients ) {
                    # Error message
                    next unless length $e;
                    $v->{'diagnosis'} .= $e.' ';

                } else {
                    # Error message when email address above does not include '@' and domain part.
                    if( index($e, ' pipe to |/') > -1 ) {
                        # pipe to |/path/to/prog ...
                        #   generated by kijitora@example.com
                        $v->{'diagnosis'} = $e;

                    } else {
                        next unless index($e, '    ') == 0;
                        $v->{'alterrors'} .= $e.' ';
                    }
                }
            }
        }
    }

    if( $recipients ) {
        # Check "an undisclosed address", "unroutable address"
        for my $q ( @$dscontents ) {
            # Replace the recipient address with the value of "alias"
            next unless $q->{'alias'};
            if( ! $q->{'recipient'} || rindex($q->{'recipient'}, '@') == -1 ) {
                # The value of "recipient" is empty or does not include "@"
                $q->{'recipient'} = $q->{'alias'};
            }
        }
    } else {
        # Fallback for getting recipient addresses
        if( defined $mhead->{'x-failed-recipients'} ) {
            # X-Failed-Recipients: kijitora@example.jp
            my @rcptinhead = split(',', $mhead->{'x-failed-recipients'});
            for my $e ( @rcptinhead ) { s/\A[ ]+//, s/[ ]+\z// for $e }
            $recipients = scalar @rcptinhead;

            for my $e ( @rcptinhead ) {
                # Insert each recipient address into @$dscontents
                $dscontents->[-1]->{'recipient'} = $e;
                next if scalar @$dscontents == $recipients;
                push @$dscontents, __PACKAGE__->DELIVERYSTATUS;
            }
        }
    }
    return undef unless $recipients;

    # Get the name of the local MTA
    # Received: from marutamachi.example.org (c192128.example.net [192.0.2.128])
    my $receivedby = $mhead->{'received'} || [];
    my $recvdtoken = Sisimai::RFC5322->received($receivedby->[-1]);

    for my $e ( @$dscontents ) {
        # Check the error message, the rhost, the lhost, and the smtp command.
        if( ! $e->{'diagnosis'} && length($boundary00) > 0 ) {
            # Empty Diagnostic-Code: or error message
            # --NNNNNNNNNN-eximdsn-MMMMMMMMMM
            # Content-type: message/delivery-status
            #
            # Reporting-MTA: dns; the.local.host.name
            #
            # Action: failed
            # Final-Recipient: rfc822;/a/b/c
            # Status: 5.0.0
            #
            # Action: failed
            # Final-Recipient: rfc822;|/p/q/r
            # Status: 5.0.0
            $e->{'diagnosis'} = $dscontents->[0]->{'diagnosis'} || '';
            $e->{'spec'}    ||= $dscontents->[0]->{'spec'};

            if( $dscontents->[0]->{'alterrors'} ) {
                # The value of "alterrors" is also copied
                $e->{'alterrors'} = $dscontents->[0]->{'alterrors'};
            }
        }

        if( exists $e->{'alterrors'} && $e->{'alterrors'} ) {
            # Copy alternative error message
            $e->{'diagnosis'} ||= $e->{'alterrors'};

            if( index($e->{'diagnosis'}, '-') == 0 || substr($e->{'diagnosis'}, -2, 2) eq '__' ) {
                # Override the value of diagnostic code message
                $e->{'diagnosis'} = $e->{'alterrors'} if $e->{'alterrors'};

            } elsif( length($e->{'diagnosis'}) < length($e->{'alterrors'}) ) {
                # Override the value of diagnostic code message with the value of alterrors because
                # the latter includes the former.
                $e->{'alterrors'} =~ y/ //s;
                $e->{'diagnosis'} = $e->{'alterrors'} if index(lc $e->{'alterrors'}, lc $e->{'diagnosis'}) > -1;
            }
            delete $e->{'alterrors'};
        }
        $e->{'diagnosis'} = Sisimai::String->sweep($e->{'diagnosis'}); $p1 = index($e->{'diagnosis'}, '__');
        $e->{'diagnosis'} = substr($e->{'diagnosis'}, 0, $p1)       if $p1 > 1;

        unless( $e->{'rhost'} ) {
            # Get the remote host name
            # host neko.example.jp [192.0.2.222]: 550 5.1.1 <kijitora@example.jp>... User Unknown
            $p1 = index($e->{'diagnosis'}, 'host ');
            $p2 = index($e->{'diagnosis'}, ' ', $p1 + 5);
            $e->{'rhost'}   = substr($e->{'diagnosis'}, $p1 + 5, $p2 - $p1 - 5) if $p1 > -1;
            $e->{'rhost'} ||= $recvdtoken->[1];
        }
        $e->{'lhost'} ||= $recvdtoken->[0];

        unless( $e->{'command'} ) {
            # Get the SMTP command name for the session
            SMTP: for my $r ( @$recommands ) {
                # Verify each regular expression of SMTP commands
                next unless $e->{'diagnosis'} =~ $r;
                $e->{'command'} = uc $1;
                last;
            }

            # Detect the reason of bounce
            if( $e->{'command'} eq 'HELO' || $e->{'command'} eq 'EHLO' ) {
                # HELO | Connected to 192.0.2.135 but my name was rejected.
                $e->{'reason'} = 'blocked';

            } elsif( $e->{'command'} eq 'MAIL' ) {
                # MAIL | Connected to 192.0.2.135 but sender was rejected.
                $e->{'reason'} = 'onhold';

            } else {
                # Verify each regular expression of session errors
                SESSION: for my $r ( keys %$messagesof ) {
                    # Check each regular expression
                    next unless grep { index($e->{'diagnosis'}, $_) > -1 } $messagesof->{ $r }->@*;
                    $e->{'reason'} = $r;
                    last;
                }

                unless( $e->{'reason'} ) {
                    # The reason "expired", or "mailererror"
                    $e->{'reason'}   = 'expired' if grep { index($e->{'diagnosis'}, $_) > -1 } @$delayedfor;
                    $e->{'reason'} ||= 'mailererror' if index($e->{'diagnosis'}, 'pipe to |') > -1;
                }
            }
        }

        STATUS: {
            # Prefer the value of smtp reply code in Diagnostic-Code: field
            # See set-of-emails/maildir/bsd/exim-20.eml
            #
            #   Action: failed
            #   Final-Recipient: rfc822;userx@test.ex
            #   Status: 5.0.0
            #   Remote-MTA: dns; 127.0.0.1
            #   Diagnostic-Code: smtp; 450 TEMPERROR: retry timeout exceeded
            #
            # The value of "Status:" indicates permanent error but the value of SMTP reply code in
            # Diagnostic-Code: field is "TEMPERROR"!!!!
            my $cs = $e->{'status'}    || Sisimai::SMTP::Status->find($e->{'diagnosis'}) || '';
            my $cr = $e->{'replycode'} || Sisimai::SMTP::Reply->find($e->{'diagnosis'})  || '';
            my $s1 = 0; # First character of Status as integer
            my $r1 = 0; # First character of SMTP reply code as integer
            my $v1 = 0;

            FIND_CODE: while(1) {
                # "Status:" field did not exist in the bounce message
                last if $cs;
                last unless $cr;

                # Check SMTP reply code, Generate pseudo DSN code from SMTP reply code
                $r1 = substr($cr, 0, 1);
                if( $r1 == 4 ) {
                    # Get the internal DSN(temporary error)
                    $cs = Sisimai::SMTP::Status->code($e->{'reason'}, 1) || '';

                } elsif( $r1 == 5 ) {
                    # Get the internal DSN(permanent error)
                    $cs = Sisimai::SMTP::Status->code($e->{'reason'}, 0) || '';
                }
                last;
            }

            $s1  = substr($cs, 0, 1) if $cs;
            $v1  = $s1 + $r1;
            $v1 += substr($e->{'status'}, 0, 1) if $e->{'status'};

            if( $v1 > 0 ) {
                # Status or SMTP reply code exists, Set pseudo DSN into the value of "status" accessor
                $e->{'status'} = $cs if $r1 > 0;

            } else {
                # Neither Status nor SMTP reply code exist
                if( $e->{'reason'} eq 'expired' || $e->{'reason'} eq 'mailboxfull' ) {
                    # Set pseudo DSN (temporary error)
                    $cs = Sisimai::SMTP::Status->code($e->{'reason'}, 1) || '';

                } else {
                    # Set pseudo DSN (permanent error)
                    $cs = Sisimai::SMTP::Status->code($e->{'reason'}, 0) || '';
                }
            }
            $e->{'status'} ||= $cs;
        }
        $e->{'command'} ||= '';
    }
    return { 'ds' => $dscontents, 'rfc822' => $emailparts->[1] };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Lhost::Exim - bounce mail decoder class for Exim Internet Mailer L<https://www.exim.org/>.

=head1 SYNOPSIS

    use Sisimai::Lhost::Exim;

=head1 DESCRIPTION

C<Sisimai::Lhost::Exim> decodes a bounce email which created by Exim Internet Mailer L<https://www.exim.org/>.
Methods in the module are called from only C<Sisimai::Message>.

=head1 CLASS METHODS

=head2 C<B<description()>>

C<description()> returns description string of this module.

    print Sisimai::Lhost::Exim->description;

=head2 C<B<inquire(I<header data>, I<reference to body string>)>>

C<inquire()> method decodes a bounced email and return results as a array reference.
See C<Sisimai::Message> for more details.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014-2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

