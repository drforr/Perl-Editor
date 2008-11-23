package Pane::HashMarker;

use warnings;
use strict;
use Curses; # XXX

=head1 NAME

Pane - Pane creation and manipulation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Handles the basic mechanics of scrolling a viewport in 2-D around a pane of text

    use Pane::HashMarker;

    my $foo = Pane::HashMarker->new
        ({
        pane_height     => scalar(@{$heap->{file}}),
        viewport_height => $Curses::LINES - $row_starts{list},
        pane_width      => $total_width,
        viewport_width  => $Curses::COLS - (5 + 2),
        });

    $foo->viewport_left;

=head1 FUNCTIONS

# {{{ _default({ args => $args })

=head2 _default

Internal method, specifies defaults for missing arguments.

=cut

sub _default
  {
  my ( $arglist ) = @_;
  my $args = $arglist->{args};

  $args->{viewport_width}  = 80  unless defined $args->{viewport_width};
  $args->{pane_width}      = 132 unless defined $args->{pane_width};
  $args->{viewport_height} = 52  unless defined $args->{viewport_height};
  $args->{pane_height}     = 24  unless defined $args->{pane_height};
  }

# }}}

# {{{ new({ pane_width=>72, total_height=>17, total_width=>80 })

=head2 new({ pane_width=>72, total_height=>17, total_width=>80 })

Create a new pane, by default the viewport starts in the TL corner of the pane

=cut

sub new
  {
  my ( $proto, $args ) = @_;
  my $class = ref $proto ? ref($proto) : $proto;
  my %args = %$args;

  _default({ args => \%args });

# {{{ $self
  my $self =
    {
    viewport_height => 1,
    pane_height     => 1,
    viewport_width  => $args{viewport_width},
    pane_width      => $args{pane_width},

    excess_width  => $args{pane_width}  - $args{viewport_width},
    excess_height => $args{pane_height} - $args{viewport_height},

    marker => 0,
    };

# }}}

  return bless $self, $class;
  }

# }}}

# {{{ update
sub update
  {
  my ( $self, $args ) = @_;
  my $marker   = $self->{marker};
  my $row      = $row_starts{time};
  my $str      = '-' x $self->{viewport_width};

  substr($str,$marker,1) = '#';
  move( $row++, 0 );
  addstr($str);
  }

# }}}

=head1 AUTHOR

Jeffrey Goff, C<< <drforr at pobox.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-editor at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pane>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Pane


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pane>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Pane>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Pane>

=item * Search CPAN

L<http://search.cpan.org/dist/Pane>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Jeffrey Goff, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Pane
