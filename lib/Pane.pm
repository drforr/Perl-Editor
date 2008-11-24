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

    my $pane = Pane->new
        ({
        pane_height     => scalar(@{$heap->{file}}),
        viewport_height => $Curses::LINES - $row_starts{list},
        pane_width      => $total_width,
        viewport_width  => $Curses::COLS - (5 + 2),
        content         => [],
        });

    $pane->viewport_left;

=head1 FUNCTIONS

# {{{ _default({ self => $args })

=head2 _default

Internal method, specifies defaults for missing arguments.

=cut

sub _default
  {
  my ( $args ) = @_;
  my $self     = $args->{self};

  $self->{viewport_width}  = 80  unless defined $self->{viewport_width};
  $self->{pane_width}      = 132 unless defined $self->{pane_width};
  $self->{viewport_height} = 52  unless defined $self->{viewport_height};
  $self->{pane_height}     = 24  unless defined $self->{pane_height};
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

  _default({ self => \%args });

# {{{ $self
  my $self =
    {
    viewport_height => $args{viewport_height},
    pane_height     => $args{pane_height},
    viewport_width  => $args{viewport_width},
    pane_width      => $args{pane_width},

    top  => 0,
    left => 0,

    cursor_v => 0,
    cursor_h => 0,

    content => $args{content},
    mode    => q{normal},

    num => 5,
    undo_stack => [],
    };

# }}}

  return bless $self, $class;
  }

# }}}

# {{{ _excess_width
sub _excess_width
  {
  my ( $self ) = @_;
  return $self->{pane_width} - $self->{viewport_width}
  }

# }}}

# {{{ _excess_height
sub _excess_height
  {
  my ( $self ) = @_;
  $self->{pane_height} - $self->{viewport_height}
  }

# }}}

# XXX THIS MUST CHANGE...
# {{{ _deep_copy_content
sub _deep_copy_content
  {
  my ( $self ) = @_;
  my $content = [];

  for my $line ( @{$self->{content}} )
    {
    push @$content, $line;
    }
  return $content;
  }

# }}}

# {{{ set_mode({ mode => $mode })
sub set_mode
  {
  my ( $self, $args ) = @_;
  my $mode            = $args->{mode};

  if ( $mode eq 'insert' )
    {
    push @{$self->{undo_stack}}, $self->_deep_copy_content;
    }
  $self->{mode} = $mode;
  }

# }}}

sub _global_v { my ( $self ) = @_; $self->{top} + $self->{cursor_v} }
sub _global_h { my ( $self ) = @_; $self->{left} + $self->{cursor_h} }

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
#  $self->{top} = $self->_excess_height if
#    $self->{top} > $self->_excess_height;
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

  $self->{top} = $self->_excess_height;
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
#  $self->{top} = 0 if
#    $self->{top} < 0;
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
#  $self->{left} = 0 if
#    $self->{left} < 0;
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
#  $self->{left} = $self->_excess_width if
#    $self->{left} > $self->_excess_width;
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

  $self->{left} = $self->_excess_width;
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

  $self->{cursor_h} = $self->{viewport_width} - $self->{num} - 1;
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
  if ( $self->{cursor_h} >= $self->{viewport_width} - $self->{num} )
    {
    $self->{cursor_h} = $self->{viewport_width} - $self->{num} - 1;
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

# {{{ insert({ keystroke => $ch })
sub insert
  {
  my ( $self, $args ) = @_;
  my $ch              = $args->{keystroke};

  substr
    (
    $self->{content}->[ $self->_global_v ],
    $self->_global_h,
    0
    ) = $ch;
  }

# }}}

# {{{ insert_line
sub insert_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->_global_v + 1, 0, '';
  }

# }}}

# {{{ delete
sub delete
  {
  my ( $self ) = @_;

  substr
    (
    $self->{content}->[ $self->_global_v ],
    $self->_global_h,
    1
    ) = '';
  }

# }}}

# {{{ delete_line
sub delete_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->_global_v + 1, 1;
  }

# }}}

# {{{ update
#
# Update the code display area.  This sort of handles the highlight bar and
# scrolling, although it's really kind of cheezy.
#
sub update
  {
  my ( $self )   = @_;
  my $file_lines = $self->{content};
  my $width      = $self->{viewport_width} - $self->{num};

# {{{ Display visible rows
  for my $cur_row ( 0 .. $self->{viewport_height} - 1 )
    {
    my $cur_offset = $cur_row + $self->{top};
    my $remainder = '';
    if ( length($file_lines->[$cur_offset]) > $self->{left} )
      {
      $remainder =
        substr
          (
          $file_lines->[$cur_offset],
          $self->{left},
          $self->{viewport_width} - $self->{num}
          );
      $remainder .=
        ' ' x ( $width - length($remainder) ) if length($remainder) < $width;
      }

    move( $cur_row, 0 );
    clrtoeol();

    addstr
      (
      sprintf( "%$self->{num}d: %s", $cur_offset + 1, $remainder )
      );
    }

# }}}

  $self->_update_modeline;
  $self->_update_cursor;
  }

# }}}

# {{{ undo
sub undo
  {
  my ( $self ) = @_;

  $self->{content} = pop @{$self->{undo_stack}};
  }

# }}}

# {{{ _update_modeline
#
# Update the modeline
#
sub _update_modeline
  {
  my ( $self ) = @_;

  attrset(A_REVERSE);
  addstr( $self->{viewport_height}, 0, uc($self->{mode}) );
  attrset(A_NORMAL);
  addstr( $self->{cursor_v}, $self->{num} + 2 + $self->{cursor_h}, '' );
  }

# }}}

# {{{ _update_cursor
#
# Update the cursor position
#
sub _update_cursor
  {
  my ( $self ) = @_;

  addstr( $self->{cursor_v}, $self->{num} + 2 + $self->{cursor_h}, '' );
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
