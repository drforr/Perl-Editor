package Pane::Edit;

use base q{Pane};

use warnings;
use strict;
use Curses;
use List::Util qw(min);

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

# {{{ Superclass
  my $self = $class->SUPER::new
    ({
    pane_width      => $args{pane_width},
    pane_height     => $args{pane_height},
    viewport_width  => $args{viewport_width},
    viewport_height => $args{viewport_height},
    });

# }}}

  $self->{content}        = $args{content};
  $self->{mode}           = q{normal};
  $self->{undo_stack}     = [];
  $self->{command_buffer} = q{};

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

  my $line = $self->{content}->[ $self->global_cursor_v ];
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

  my $line = $self->{content}->[ $self->global_cursor_v ];
  $line =~ s{ \s+ $ }{}mx;
  if ( $line )
    {
    $self->set_cursor_h({ pos => length($line) - 1 });
    }
  else
    {
    $self->cursor_flush_left;
    }
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

# {{{ insert_command_character({ keystroke => $ch })

=head2 insert_command_character({ keystroke => $ch })

Insert the specified keystroke at the current cursor position

=cut

sub insert_command_character
  {
  my ( $self, $args ) = @_;

  $self->{command_buffer} .= $args->{keystroke};
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

# {{{ delete_command_character

=head2 delete_command_character

Delete the character at the cursor position

=cut

sub delete_command_character
  {
  my ( $self ) = @_;

  substr
    (
    $self->{command_buffer},
    -1,
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

  splice @{$self->{content}}, $self->global_cursor_v + 1, 1;
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

  $self->_update_modeline;
  $self->_update_cursor;
  noutrefresh();
  doupdate;
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

# {{{ _update_modeline

=head2 _update_modeline

Update the modeline at the bottom of the screen

=cut

sub _update_modeline
  {
  my ( $self ) = @_;
  my %modes =
    (
    q{normal} => 1,
    q{insert} => 1,
    q{visual} => 1,
    );

  move( $self->viewport_height, 0 );
  clrtoeol();

  if ( defined $modes{$self->{mode}} )
    {
    attrset(A_BOLD);
    addstr( q{-- } . uc($self->{mode}) . q{ --} );
    attrset(A_NORMAL);
    }
  else
    {
    addstr( q{:} . $self->{command_buffer} );
    }
  }

# }}}

# {{{ _update_cursor

=head2 _update_cursor

Update the cursor position

=cut

sub _update_cursor
  {
  my ( $self ) = @_;

  addstr( $self->{cursor_v}, $self->{cursor_h}, q{} );
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
