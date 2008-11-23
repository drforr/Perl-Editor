package Pane;

use warnings;
use strict;
use Curses;

=head1 NAME

Pane - Pane creation and manipulation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Handles the basic mechanics of scrolling a viewport in 2-D around a pane of text

    use Pane;

    my $foo = Pane->new
        ({
        pane_height     => scalar(@{$heap->{file}}),
        viewport_height => $Curses::LINES - $row_starts{list},
        pane_width      => $total_width,
        viewport_width  => $Curses::COLS - (5 + 2),
        content         => [],
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

# {{{ new({ ... })

=head2 new({ ... })

Create a new pane, by default the viewport starts in the TL corner of the pane.
You can specify both the height and width of the viewport and enclosing pane.
Also you can pass in content at this point.

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
    viewport_height => $args{viewport_height},
    pane_height     => $args{pane_height},
    viewport_width  => $args{viewport_width},
    pane_width      => $args{pane_width},

    excess_width  => $args{pane_width}  - $args{viewport_width},
    excess_height => $args{pane_height} - $args{viewport_height},

    top  => 0,
    left => 0,

    cursor_v => 0,
    cursor_h => 0,

    content => $args{content},
    };

# }}}

  return bless $self, $class;
  }
 

# }}}

# {{{ viewport movement

# {{{ viewport_down

=head2 viewport_down

Move the viewport down one unit, if possible. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_down
  {
  my ( $self ) = @_;

  $self->{top}++;
  $self->{top} = $self->{excess_height} if
    $self->{top} > $self->{excess_height};
  }

# }}}

# {{{ viewport_flush_bottom

=head2 viewport_flush_bottom

Move the viewport to the bottom of the pane. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_flush_bottom
  {
  my ( $self ) = @_;

  $self->{top} = $self->{excess_height};
  }

# }}}

# {{{ viewport_up

=head2 viewport_up

Move the viewport up one unit, if possible. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_up
  {
  my ( $self ) = @_;

  $self->{top}--;
  $self->{top} = 0 if
    $self->{top} < 0;
  }

# }}}

# {{{ viewport_flush_top

=head2 viewport_flush_top

Move the viewport to the top of the pane. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_flush_top
  {
  my ( $self ) = @_;

  $self->{top} = 0;
  }

# }}}

# {{{ viewport_left

=head2 viewport_left

Move the viewport left one unit, if possible. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_left
  {
  my ( $self ) = @_;

  $self->{left}--;
  $self->{left} = 0 if
    $self->{left} < 0;
  }

# }}}

# {{{ viewport_flush_left

=head2 viewport_flush_left

Move the viewport to the left edge of the pane. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_flush_left
  {
  my ( $self ) = @_;

  $self->{left} = 0;
  }

# }}}

# {{{ viewport_right

=head2 viewport_right

Move the viewport right one unit, if possible. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_right
  {
  my ( $self ) = @_;

  $self->{left}++;
  $self->{left} = $self->{excess_width} if
    $self->{left} > $self->{excess_width};
  }

# }}}

# {{{ viewport_flush_right

=head2 viewport_flush_right

Move the viewport to the right edge of the pane. This moves the entire viewport
without affecting the cursor's location.

=cut

sub viewport_flush_right
  {
  my ( $self ) = @_;

  $self->{left} = $self->{excess_width};
  }

# }}}

# }}}

# {{{ cursor movement

# {{{ cursor_flush_bottom

=head2 cursor_flush_bottom

Move the cursor to the bottom of the pane. This moves the cursor along with
the viewport.

=cut

sub cursor_flush_bottom
  {
  my ( $self ) = @_;

  $self->{cursor_v} = $self->{viewport_height} - 1;
  $self->viewport_flush_bottom();
  }

# }}}

# {{{ cursor_down

=head2 cursor_down

Move the cursor down one unit. This may move the viewport if the cursor is at
the bottom.

=cut

sub cursor_down
  {
  my ( $self ) = @_;

  $self->{cursor_v}++;
  if ( $self->{cursor_v} >= $self->{viewport_height} )
    {
    $self->{cursor_v} = $self->{viewport_height} - 1;
    $self->viewport_down();
    }
  }

# }}}

# {{{ cursor_up

=head2 cursor_up

Move the cursor up one unit. This may move the viewport if the cursor is at the top.

=cut

sub cursor_up
  {
  my ( $self ) = @_;

  $self->{cursor_v}--;
  if ( $self->{cursor_v} < 0 )
    {
    $self->{cursor_v} = 0;
    $self->viewport_up();
    }
  }

# }}}

# {{{ cursor_flush_top

=head2 cursor_flush_top

Move the cursor to the top of the pane. This moves the cursor along with
the viewport.

=cut

sub cursor_flush_top
  {
  my ( $self ) = @_;

  $self->{cursor_v} = 0;
  $self->viewport_flush_top();
  }

# }}}

# {{{ cursor_flush_right

=head2 cursor_flush_right

Move the cursor to the right edge of the pane. This moves the cursor along with
the viewport.

=cut

sub cursor_flush_right
  {
  my ( $self ) = @_;

  $self->{cursor_h} = $self->{viewport_width} - 1;
  $self->viewport_flush_right();
  }

# }}}

# {{{ cursor_right

=head2 cursor_right

Move the cursor right one unit. This may move the viewport if the cursor is at the right edge.

=cut

sub cursor_right
  {
  my ( $self ) = @_;

  $self->{cursor_h}++;
  if ( $self->{cursor_h} >= $self->{viewport_width} )
    {
    $self->{cursor_h} = $self->{viewport_width} - 1;
    $self->viewport_right();
    }
  }

# }}}

# {{{ cursor_left

=head2 cursor_left

Move the cursor left one unit. This may move the viewport if the cursor is at the left edge.

=cut

sub cursor_left
  {
  my ( $self ) = @_;

  $self->{cursor_h}--;
  if ( $self->{cursor_h} < 0 )
    {
    $self->{cursor_h} = 0;
    $self->viewport_left();
    }
  }

# }}}

# {{{ cursor_flush_left

=head2 cursor_flush_left

Move the cursor to the left edge of the pane. This moves the cursor along with
the viewport.

=cut

sub cursor_flush_left
  {
  my ( $self ) = @_;

  $self->{cursor_h} = 0;
  $self->viewport_flush_left();
  }

# }}}

# }}}

# {{{ insert($ch)
sub insert
  {
  my ( $self, $ch ) = @_;

  substr
    (
    $self->{content}->[$self->{top}+$self->{cursor_v}],
    $self->{left}+$self->{cursor_h},
    0
    ) = $ch;
  }

# }}}

# {{{ delete
sub delete
  {
  my ( $self ) = @_;

  substr
    (
    $self->{content}->[$self->{top}+$self->{cursor_v}],
    $self->{left}+$self->{cursor_h},
    1
    ) = '';
  }

# }}}

# {{{ update({ mode => $mode })
#
# Update the code display area.  This sort of handles the highlight bar and
# scrolling, although it's really kind of cheezy.
#
sub update
  {
  my ( $self, $args )   = @_;
  my $mode       = $args->{mode};
  my $file_lines = $self->{content};
  my $cur_row    = 0;
  my $cur_line   = $self->{top};

# {{{ Display visible rows
  while ( $cur_row < $self->{viewport_height} )
    {
    my $remainder = '';
    if ( length($file_lines->[$cur_line]) > $self->{left} )
      {
      $remainder =
        substr
          (
          $file_lines->[$cur_line],
          $self->{left},
          $self->{viewport_width}
          );
      $remainder .= ' ' x ($self->{viewport_width} - length($remainder) ) if
        length($remainder) < $self->{viewport_width};
      }

    my $highlighted = $cur_line == $self->{cursor_v} + $self->{top};
    move( $cur_row, 0 );
    clrtoeol();

    addstr( sprintf( "%5d: ", $cur_line ) );

# {{{ Display row
    if ( 0 )
      {
# {{{ Highlight the row appropriately
      if ( $highlighted )
        {
        attrset(A_REVERSE);
        addstr( $remainder );
        attrset(A_NORMAL);
        }
      else
        {
        addstr( substr( $remainder, 0, $self->{cursor_h} ) );
        attrset(A_REVERSE);
        addstr( substr( $remainder, $self->{cursor_h}, 1 ) );
        attrset(A_NORMAL);
        addstr( substr( $remainder, $self->{cursor_h} + 1 ) );
        }

# }}}
      }
    else
      {
      addstr( $remainder );
      }

# }}}

    $cur_row++;
    $cur_line++;
    }

# }}}

  $self->_update_modeline({ mode => $mode });
  $self->_update_cursor;
  }

# }}}

# {{{ _update_modeline({ mode => $mode })
#
# Update the modeline
#
sub _update_modeline
  {
  my ( $self, $args ) = @_;
  my $mode            = $args->{mode};

  attrset(A_REVERSE);
  addstr( $self->{viewport_height}, 0, uc($mode) );
  attrset(A_NORMAL);
  addstr( $self->{cursor_v}, 5+2+$self->{cursor_h}, '' );
  }

# }}}

# {{{ _update_cursor()
#
# Update the cursor position
#
sub _update_cursor
  {
  my ( $self ) = @_;

  addstr( $self->{cursor_v}, 5+2+$self->{cursor_h}, '' );
  noutrefresh();
  doupdate;
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
