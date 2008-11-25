package Pane::Edit;

use base 'Pane';

use warnings;
use strict;
use Curses;
use List::Util qw(min);

=head1 NAME

Pane::Edit - Pane creation and manipulation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Handles the basic mechanics of scrolling a viewport in 2-D around a pane of text

    use Pane::Edit;

    my $pane = Pane::Edit->new
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

  my $self = $class->SUPER::new
    ({
    pane_width      => $args{pane_width},
    pane_height     => $args{pane_height},
    viewport_width  => $args{viewport_width},
    viewport_height => $args{viewport_height},
    });

  $self->{content}    = $args{content};
  $self->{mode}       = q{normal};
  $self->{undo_stack} = [];

  return $self;
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

# {{{ insert({ keystroke => $ch })
sub insert
  {
  my ( $self, $args ) = @_;
  my $ch              = $args->{keystroke};

  substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    0
    ) = $ch;
  }

# }}}

# {{{ insert_line
sub insert_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->global_cursor_v + 1, 0, '';
  }

# }}}

# {{{ delete
sub delete
  {
  my ( $self ) = @_;

  substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    1
    ) = '';
  }

# }}}

# {{{ delete_line
sub delete_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->global_cursor_v + 1, 1;
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
  my $height     = $self->_min_height;

# {{{ Display visible rows
  for my $cur_row ( 0 .. $height - 1 )
    {
    my $cur_offset = $cur_row + $self->viewport_v;
    my $cur_line   = $file_lines->[$cur_offset];
    my $remainder = '';
    if ( length($cur_line) > $self->viewport_h )
      {
      $remainder =
        substr( $cur_line, $self->viewport_h, $self->viewport_width );
      $remainder .= ' ' x ( $self->viewport_width - length($remainder) ) if
        length($remainder) < $self->viewport_width;
      }

    move( $cur_row, 0 );
    clrtoeol();

    addstr( $remainder );
    }

# }}}

  $self->_update_modeline;
  $self->_update_cursor;
  noutrefresh();
  doupdate;
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
  addstr( $self->viewport_height, 0, uc($self->{mode}) );
  attrset(A_NORMAL);
  }

# }}}

# {{{ _update_cursor
#
# Update the cursor position
#
sub _update_cursor
  {
  my ( $self ) = @_;

  addstr( $self->{cursor_v}, $self->{cursor_h}, '' );
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
