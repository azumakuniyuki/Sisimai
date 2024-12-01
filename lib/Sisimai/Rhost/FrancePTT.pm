package Sisimai::Rhost::FrancePTT;
use v5.26;
use strict;
use warnings;

sub find {
    # Detect bounce reason from Orange and La Poste
    # @param    [Sisimai::Fact] argvs   Decdoed email object
    # @return   [String]                The bounce reason for Orange, La Poste
    # @see      https://www.postmastery.com/orange-postmaster-smtp-error-codes-ofr/
    #           https://smtpfieldmanual.com/provider/orange
    # @since v4.22.3
    my $class = shift;
    my $argvs = shift // return undef; return "" unless $argvs->{'diagnosticcode'};

    state $errorcodes = {
        # - 550 5.7.1 Service unavailable; client [192.0.2.1] blocked using Spamhaus
        #   Les emails envoyes vers la messagerie Laposte.net ont ete bloques par nos services.
        #   Afin de regulariser votre situation, nous vous invitons a cliquer sur le lien ci-dessous
        #   et a suivre la procedure.
        # - The emails sent to the mail host Laposte.net were blocked by our services. To regularize
        #   your situation please click on the link below and follow the procedure
        #   https://www.spamhaus.org/lookup/ LPNAAA_101 (in reply to RCPT TO command))
        '101' => 'blocked',

        # - 550 mwinf5c04 ME Adresse IP source bloquee pour incident de spam.
        # - Client host blocked for spamming issues. OFR006_102 Ref http://csi.cloudmark.com ...
        # - 550 5.5.0 Les emails envoyes vers la messagerie Laposte.net ont ete bloques par nos
        #   services. Afin de regulariser votre situation, nous vous invitons a cliquer sur le lien
        #   ci-dessous et a suivre la procedure.
        # - The emails sent to the mail host Laposte.net were blocked by our services. To regularize
        #   your situation please click on the link below and follow the procedure
        #   https://senderscore.org/blacklistlookup/  LPN007_102
        '102' => 'blocked',

        # - 550 mwinf5c10 ME Service refuse. Veuillez essayer plus tard.
        # - Service refused, please try later. OFR006_103 192.0.2.1 [103]
        '103' => 'blocked',

        # - 421 mwinf5c79 ME Trop de connexions, veuillez verifier votre configuration.
        # - Too many connections, slow down. OFR005_104 [104]
        # - Too many connections, slow down. LPN105_104
        '104' => 'toomanyconn',

        '105' => undef, # Veuillez essayer plus tard.
        '107' => undef, # Service refused, please try later. LPN006_107
        '108' => undef, # service refused, please try later. LPN001_108
        '109' => undef, # Veuillez essayer plus tard. LPN003_109
        '201' => undef, # Veuillez essayer plus tard. OFR004_201

        # - 550 5.7.0 Code d'authentification invalide OFR_305
        '305' => 'securityerror',

        # - 550 5.5.0 SPF: *** is not allowed to send mail. LPN004_401
        '401' => 'authfailure',

        # - 550 5.5.0 Authentification requise. Authentication Required. LPN105_402
        '402' => 'securityerror',

        # - 5.0.1 Emetteur invalide. Invalid Sender.
        '403' => 'rejected',

        # - 5.0.1 Emetteur invalide. Invalid Sender. LPN105_405
        # - 501 5.1.0 Emetteur invalide. Invalid Sender. OFR004_405 [405] (in reply to MAIL FROM command))
        '405' => 'rejected',

        # Emetteur invalide. Invalid Sender. OFR_415
        '415' => 'rejected',

        # - 550 5.1.1 Adresse d au moins un destinataire invalide.
        # - Invalid recipient. LPN416 (in reply to RCPT TO command)
        # - Invalid recipient. OFR_416 [416] (in reply to RCPT TO command)
        '416' => 'userunknown',

        # - 552 5.1.1 Boite du destinataire pleine.
        # - Recipient overquota. OFR_417 [417] (in reply to RCPT TO command))
        '417' => 'mailboxfull',

        # - Adresse d au moins un destinataire invalide

        # - 550 5.5.0 Boite du destinataire archivee.
        # - Archived recipient. LPN007_420 (in reply to RCPT TO command)
        '420' => 'suspend',

        # - 5.5.3 Mail from not owned by user. LPN105_421.
        '421' => 'rejected',

        '423' => undef, # Service refused, please try later. LPN105_423
        '424' => undef, # Veuillez essayer plus tard. LPN105_424

        # - 550 5.5.0 Le compte du destinataire est bloque. The recipient account isblocked.
        #   LPN007_426 (in reply to RCPT TO command)
        '426' => 'suspend',

        # - 421 4.2.0 Service refuse. Veuillez essayer plus tard. Service refused, please try later.
        #   OFR005_505 [505] (in reply to end of DATA command)
        # - 421 4.2.1 Service refuse. Veuillez essayer plus tard. Service refused, please try later.
        #   LPN007_505 (in reply to end of DATA command)
        '505' => 'systemerror',

        # - Mail rejete. Mail rejected. OFR_506 [506]
        '506' => 'spamdetected',

        # - 550 5.5.0 Service refuse. Veuillez essayer plus tard. service refused, please try later.
        #   LPN005_510 (in reply to end of DATA command)
        '510' => 'blocked',

        '513' => undef, # Mail rejete. Mail rejected. OUK_513

        # - Taille limite du message atteinte
        '514' => 'mesgtoobig',

        # - 571 5.7.1 Message refused, DMARC verification Failed.
        # - Message refuse, verification DMARC en echec LPN007_517
        '517' => 'authfailure',

        # - 554 5.7.1 Client host rejected LPN000_630
        '630' => 'policyviolation',

        # - 421 mwinf5c77 ME Service refuse. Veuillez essayer plus tard. Service refused, please try
        #   later. OFR_999 [999]
        '999' => 'blocked',
    };
    state $messagesof = {
        'authfailure' => [
            # - 421 smtp.orange.fr [192.0.2.1] Emetteur invalide, Veuillez verifier la configuration
            #   SPF/DNS de votre nom de domaine. Invalid Sender. SPF check failed, please verify the
            #   SPF/DNS configuration for your domain name.
            'spf/dns de votre nom de domaine',
        ],
    };
    my $issuedcode = $argvs->{'diagnosticcode'};
    my $reasontext = '';

    if( $issuedcode =~ /\b(LPN|LPNAAA|OFR|OUK)(_[0-9]{3}|[0-9]{3}[-_][0-9]{3})\b/i ) {
        # OUK_513, LPN105-104, OFR102-104, ofr_506
        my $v = sprintf("%03d", substr($1.$2, -3, 3));
        $reasontext = $errorcodes->{ $v } || 'undefined';
    }
    return $reasontext if length $reasontext;

    $issuedcode = lc $issuedcode;
    for my $e ( keys %$messagesof ) {
        # Try to find the error message matches with the given error message string
        next unless grep { index($issuedcode, $_) > -1 } $messagesof->{ $e }->@*;
        $reasontext = $e;
        last;
    }
    return $reasontext;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Rhost::FrancePTT - Detect the bounce reason returned from Orange and La Poste.

=head1 SYNOPSIS

    use Sisimai::Rhost::FrancePTT;

=head1 DESCRIPTION

C<Sisimai::Rhost::FrancePTT> detects the bounce reason from the content of C<Sisimai::Fact> object
as an argument of C<find()> method when the value of C<rhost> of the object end with C<laposte.net>
or C<orange.fr>. This class is called only C<Sisimai::Fact> class.

=head1 CLASS METHODS

=head2 C<B<find(I<Sisimai::Fact Object>)>>

C<find()> method detects the bounce reason.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2017-2021,2023,2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

