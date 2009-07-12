package Pane::StatusLine;

use base q{Pane};

use warnings;
use strict;
use Curses;

=head1 NAME

Pane::StatusLine - Status line pane

=head1 VERSION

Version 0.01

=cut

our $VERSION = q{0.0.3};

=head1 SYNOPSIS

Displays the rough equivalent of a vim breakline in a pane.

    use Pane::StatusLine;

    my $pane = Pane::StatusLine->new
        ({
        pane_height     => scalar(@{$heap->{file}}),
        viewport_height => $Curses::LINES - $row_starts{list},
        pane_width      => $total_width,
        viewport_width  => $Curses::COLS - (5 + 2),
        content         => [],
        });

    $pane->viewport_left;

=head1 FUNCTIONS

# {{{ new({ ... })

=head2 new({ ... })

Create a new pane, by default the viewport starts in the TL corner of the pane.
You can specify both the height and width of the viewport and enclosing pane.
Also you can pass in content at this point.

=cut

sub new
  {
  my ( $proto, $args ) = @_;
  my $class            = ref( $proto ) ? ref( $proto ) : $proto;
  my %args             = %$args;

# {{{ Superclass
  my $self = $class->SUPER::new
    ({
    pane_width      => $args{pane_width},
    pane_height     => $args{pane_height},
    viewport_width  => $args{viewport_width},
    viewport_height => $args{viewport_height},
    viewport_top    => $args{viewport_top} || 0,
    viewport_left   => $args{viewport_left} || 0,
    });

# }}}

  $self->{file_name} = $args{file_name};
  $self->{mode}      = q{clean};

  return $self;
  }

# }}}

# {{{ set_mode({ mode => $mode })

=head2 set_mode({ mode => $mode })

Set the current editing mode

=cut

sub set_mode
  {
  my ( $self, $args ) = @_;
  my $mode            = $args->{mode};

  $self->{mode} = $mode;
  }

# }}}

# {{{ update

=head2 update

Update the screen contents

=cut

sub update
  {
  my ( $self ) = @_;
  my $file_name = $self->{file_name};

  move( $self->viewport_top_edge, 0 );
  clrtoeol();
  attrset(A_REVERSE);
  addstr($file_name . '-' x ($Curses::COLS - length($file_name)));
  attrset(A_NORMAL);
  }

# }}}

=head1 AUTHOR

Jeffrey Goff, C<< <drforr at pobox.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-editor at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pane-Edit>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Pane::Edit

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pane-Edit>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Pane-Edit>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Pane-Edit>

=item * Search CPAN

L<http://search.cpan.org/dist/Pane-Edit>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Jeffrey Goff, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Pane-Edit
