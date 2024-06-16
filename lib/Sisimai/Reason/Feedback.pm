package Sisimai::Reason::Feedback;
use v5.26;
use strict;
use warnings;

sub text  { 'feedback' }
sub description { 'Email forwarded to the sender as a complaint message from your mailbox provider' }
sub match { return undef }
sub true  { return undef }
1;

__END__

=encoding utf-8

=head1 NAME

Sisimai::Reason::Feedback - Email forwarded as a complaint message

=head1 SYNOPSIS

    use Sisimai::Reason::Feedback;
    print Sisimai::Reason::Feedback->text; # feedback

=head1 DESCRIPTION

C<Sisimai::Reason::Feedback> is for only returning the text and the description. This class is called
only from C<Sisimai->reason()> method and C<Sisimai::ARF> class.

=head1 CLASS METHODS

=head2 C<B<text()>>

C<text()> method returns the fixed string C<feedback>.

    print Sisimai::Reason::Feedback->text;  # feedback

=head2 C<B<match(I<string>)>>

C<match()> method always return C<undef>

=head2 C<B<true(I<Sisimai::Fact>)>>

C<true()> method always return C<undef>

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2016,2021,2024 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

