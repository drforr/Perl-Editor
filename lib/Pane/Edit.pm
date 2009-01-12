package Pane::Edit;

use List::Util qw(min max);
use base q{Pane};

use warnings;
use strict;
use Curses;

=head1 NAME

Pane::Edit - Pane creation and manipulation

=head1 VERSION

Version 0.01

=cut

our $VERSION = q{0.0.3};

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

# {{{ Superclass
  my $self = $class->SUPER::new
    ({
    pane_width      => $args->{pane_width},
    pane_height     => $args->{pane_height},
    viewport_width  => $args->{viewport_width},
    viewport_height => $args->{viewport_height},
    });

# }}}

  $self->{content}    = $args->{content};
  $self->{mode}       = q{normal};
  $self->{undo_stack} = [];

  $self->{normal_buffer} = '';

  return $self;
  }

# }}}

# XXX THIS MUST CHANGE...
# {{{ _deep_copy_content

=head2 _deep_copy_content

Return a deep copy of the pane's content for the undo stack. Q&D solution

=cut

sub _deep_copy_content
  {
  my ( $self ) = @_;
  my $content  = [];

  for my $line ( @{$self->{content}} )
    {
    push @$content, $line;
    }
  return $content;
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

  if ( $mode eq q{insert} )
    {
    push @{$self->{undo_stack}}, $self->_deep_copy_content;
    }
  $self->{mode} = $mode;
  }

# }}}

# {{{ cursor_beginning_line

=head2 cursor_beginning_line

Move the cursor to the beginning of a line

=cut

sub cursor_beginning_line
  {
  my ( $self ) = @_;
  my $line     = $self->{content}->[ $self->global_cursor_v ];
  delete $self->{cursor_eol};

  if ( $line =~ m{ ^ (\s+) }mx )
    {
    $self->set_cursor_h({ pos => length($1) });
    }
  else
    {
    $self->cursor_flush_left;
    }
  }

# }}}

# {{{ cursor_end_line

=head2 cursor_end_line

Move the cursor to the end of the line

=cut

sub cursor_end_line
  {
  my ( $self ) = @_;
  my $line     = $self->{content}->[ $self->global_cursor_v ];
  $self->{cursor_eol} = 1;

  if ( $line )
    {
    $self->set_cursor_h({ pos => length($line) - 1 });
    }
  else
    {
    $self->cursor_flush_left;
    }
  $self->{cursor_eol} = 1;
  }

# }}}

# {{{ swap_case

=head2 swap_case

Insert the specified keystroke at the current cursor position

=cut

sub swap_case
  {
  my ( $self ) = @_;
  my $ch = substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    1
    );

  $ch = ( $ch =~ m{ ^ [a-z] $ }mx ) ? uc($ch) : lc($ch);

  substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    1
    ) = $ch;
  }

# }}}

# {{{ insert_character({ keystroke => $ch })

=head2 insert_character({ keystroke => $ch })

Insert the specified keystroke at the current cursor position

=cut

sub insert_character
  {
  my ( $self, $args ) = @_;

  substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    0
    ) = $args->{keystroke};
  }

# }}}

# {{{ insert_line

=head2 insert_line

Insert a new line

=cut

sub insert_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->global_cursor_v + 1, 0, q{};
  }

# }}}

# {{{ delete_character

=head2 delete_character

Delete the character at the cursor position

=cut

sub delete_character
  {
  my ( $self ) = @_;

  substr
    (
    $self->{content}->[ $self->global_cursor_v ],
    $self->global_cursor_h,
    1
    ) = q{};
  }

# }}}

# {{{ delete_line

=head2 delete_line

Delete the line at the current position

=cut

sub delete_line
  {
  my ( $self ) = @_;

  splice @{$self->{content}}, $self->global_cursor_v, 1;
  }

# }}}

# {{{ update

=head2 update

Update the screen contents

=cut

sub update
  {
  my ( $self )   = @_;
  my $file_lines = $self->{content};

# {{{ Calculate the actual cursor h-position based on the extant text.
  my $cursor_h = min
    (
    $self->{cursor_h},
    length( $self->{content}->[ $self->global_cursor_v ] ) - 1
    );
  $cursor_h = length( $self->{content}->[ $self->global_cursor_v ] ) - 1
    if $self->{cursor_eol};
  $cursor_h = max( $cursor_h, 0 );

# }}}

# {{{ Display visible rows
  for my $cur_row ( 0 .. $self->_min_height - 1 )
    {
    my $cur_offset = $cur_row + $self->viewport_v;
    my $cur_line   = $file_lines->[$cur_offset];
    my $remainder  = q{};
    if ( length($cur_line) > $self->viewport_h )
      {
      $remainder =
        substr( $cur_line, $self->viewport_h, $self->viewport_width );
      $remainder .= q{ } x ( $self->viewport_width - length($remainder) ) if
        length($remainder) < $self->viewport_width;
      }

    move( $cur_row, 0 );
    clrtoeol();

    addstr( $remainder );
    }

# }}}

  addstr( $self->{cursor_v}, $cursor_h, q{} );
  }

# }}}

# {{{ undo

=head2 undo

Undo the effects of the last edit action

=cut

sub undo
  {
  my ( $self ) = @_;

  $self->{content} = pop @{$self->{undo_stack}};
  }

# }}}

# {{{ set_cursor_h({ pos => 1 })

=head2 set_cursor_h

Set the cursor's horizontal position

=cut

sub set_cursor_h
  {
  my ( $self, $args ) = @_;
  delete $self->{cursor_eol};

  $self->SUPER::set_cursor_h($args);
  }

# }}}

# {{{ add_cursor_h({ delta => 1 })

=head2 add_cursor_h

Set the cursor's horizontal deltaition

=cut

sub add_cursor_h
  {
  my ( $self, $args ) = @_;
  delete $self->{cursor_eol};

  $self->SUPER::add_cursor_h($args);
  }

# }}}

# {{{ cursor_left

=head2 cursor_left

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_left
  {
  my ( $self ) = @_;
  delete $self->{cursor_eol};

  $self->SUPER::cursor_left;
  }

# }}}

# {{{ cursor_right

=head2 cursor_right

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_right
  {
  my ( $self ) = @_;
  delete $self->{cursor_eol};

  $self->SUPER::cursor_right;
  }

# }}}

# {{{ cursor_flush_left

=head2 cursor_flush_left

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_flush_left
  {
  my ( $self ) = @_;
  delete $self->{cursor_eol};

  $self->SUPER::cursor_flush_left;
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
