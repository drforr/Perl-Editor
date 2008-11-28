package Pane;

use warnings;
use strict;
use Carp;
use List::Util qw(min max);

use version;
our $VERSION = q{0.0.3};

# {{{ new

=head2 new({ .. })

=cut

sub new
  {
  my ( $proto, $args ) = @_;
  my $class = ref $proto || $proto;

  croak q{viewport width too small} if
    $args->{viewport_width} and $args->{viewport_width} <= 0;
  croak q{viewport height too small} if
    $args->{viewport_height} and $args->{viewport_height} <= 0;

  croak q{pane width too small} if
    $args->{pane_width} and $args->{pane_width} <= 0;
  croak q{pane height too small} if
    $args->{pane_height} and $args->{pane_height} <= 0;

# {{{ Self
  my $self =
    {
    top => 0,
    left => 0,

    viewport_width  => $args->{viewport_width} || 80,
    viewport_height => $args->{viewport_height} || 24,

    pane_width  => $args->{pane_width} || 80,
    pane_height => $args->{pane_height} || 24,

    cursor_h => 0,
    cursor_v => 0,
    };

# }}}

  return bless $self, $class;
  }

# }}}

# {{{ viewport_width

=head2 viewport_width

=cut

sub viewport_width
  {
  my ( $self ) = @_;
  return $self->{viewport_width}
  } 

# }}}

# {{{ viewport_height

=head2 viewport_height

=cut

sub viewport_height
  {
  my ( $self ) = @_;
  return $self->{viewport_height}
  } 

# }}}

# {{{ set_viewport_width({ width => 31 })

=head2 set_viewport_width

=cut

sub set_viewport_width
  {
  my ( $self, $args ) = @_;

  croak q{viewport width not specified!} if
    !defined $args->{width};
  croak q{viewport width too small!} if
    $args->{width} <= 0;

  $self->{viewport_width} = $args->{width};
  } 

# }}}

# {{{ set_viewport_height({ height => 31 })

=head2 set_viewport_height

=cut

sub set_viewport_height
  {
  my ( $self, $args ) = @_;

  croak q{viewport height not specified!} if
    !defined $args->{height};
  croak q{viewport height too small!} if
    $args->{height} <= 0;

  $self->{viewport_height} = $args->{height};
  } 

# }}}

# {{{ set_pane_width({ width => 31 })

=head2 set_pane_width

=cut

sub set_pane_width
  {
  my ( $self, $args ) = @_;

  croak q{pane width not specified!} if
    !defined $args->{width};
  croak q{pane width too small!} if
    $args->{width} <= 0;

  $self->{pane_width} = $args->{width};
  } 

# }}}

# {{{ set_pane_height({ height => 31 })

=head2 set_pane_height

=cut

sub set_pane_height
  {
  my ( $self, $args ) = @_;

  croak q{pane height not specified!} if
    !defined $args->{height};
  croak q{pane height too small!} if
    $args->{height} <= 0;

  $self->{pane_height} = $args->{height};
  } 

# }}}

# {{{ _min_width

=head2 _min_width

=cut

sub _min_width
  {
  my ( $self ) = @_;
  return min( $self->{viewport_width}, $self->{pane_width} );
  } 

# }}}

# {{{ _min_height

=head2 _min_height

=cut

sub _min_height
  {
  my ( $self ) = @_;
  return min( $self->{viewport_height}, $self->{pane_height} );
  } 

# }}}

# {{{ _max_width

=head2 _max_width

=cut

sub _max_width
  {
  my ( $self ) = @_;
  return max( $self->{viewport_width}, $self->{pane_width} );
  } 

# }}}

# {{{ _max_height

=head2 _max_height

=cut

sub _max_height
  {
  my ( $self ) = @_;
  return max( $self->{viewport_height}, $self->{pane_height} );
  } 

# }}}

# {{{ global_cursor_v

=head2 global_cursor_v

Return the cursor's vertical position relative to the viewport

=cut

sub global_cursor_v
  {
  my ( $self ) = @_;
  return $self->{cursor_v} + $self->{top};
  }

# }}}

# {{{ global_cursor_h

=head2 global_cursor_h

Return the cursor's horizontal position relative to the viewport

=cut

sub global_cursor_h
  {
  my ( $self ) = @_;
  return $self->{cursor_h} + $self->{left};
  }

# }}}

# {{{ cursor routines

# {{{ cursor_v

=head2 cursor_v

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_v
  {
  my ( $self ) = @_;
  return $self->{cursor_v};
  }

# }}}

# {{{ cursor_h

=head2 cursor_h

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_h
  {
  my ( $self ) = @_;
  return $self->{cursor_h};
  }

# }}}

# {{{ set_cursor_v({ pos => 1 })

=head2 set_cursor_v

Set the cursor's vertical position

=cut

sub set_cursor_v
  {
  my ( $self, $args ) = @_;

  croak q{cursor above viewport} if
    $args->{pos} < 0;
  croak q{cursor below viewport} if
    $args->{pos} >= $self->{viewport_height};
  $self->{cursor_v} = $args->{pos};
  }

# }}}

# {{{ set_cursor_h({ pos => 1 })

=head2 set_cursor_h

Set the cursor's horizontal position

=cut

sub set_cursor_h
  {
  my ( $self, $args ) = @_;

  croak q{cursor left of viewport} if
    $args->{pos} < 0;
  croak q{cursor right of viewport} if
    $args->{pos} >= $self->{viewport_width};
  $self->{cursor_h} = $args->{pos};
  }

# }}}

# {{{ cursor_up

=head2 cursor_up

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_up
  {
  my ( $self ) = @_;

  $self->{cursor_v}--;
  if ( $self->{cursor_v} < 0 )
    {
    $self->{cursor_v} = 0;
    $self->{top}--;
    }

  if ( $self->{top} < 0 )
    {
    $self->{top} = 0;
    }
  }

# }}}

# {{{ cursor_left

=head2 cursor_left

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_left
  {
  my ( $self ) = @_;

  $self->{cursor_h}--;
  if ( $self->{cursor_h} < 0 )
    {
    $self->{cursor_h} = 0;
    $self->{left}--;
    }

  if ( $self->{left} < 0 )
    {
    $self->{left} = 0;
    }
  }

# }}}

# {{{ cursor_down

=head2 cursor_down

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_down
  {
  my ( $self ) = @_;
  return if $self->{cursor_v} >= $self->_min_height;

  $self->{cursor_v}++;
  if ( $self->{cursor_v} >= $self->_min_height )
    {
    $self->{cursor_v} = $self->_min_height - 1;
    $self->{top}++;
    }

  my $bottom = $self->_max_height - $self->{viewport_height};
  if ( $self->{top} >= $bottom )
    {
    $self->{top} = $bottom;
    }
  }

# }}}

# {{{ cursor_right

=head2 cursor_right

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_right
  {
  my ( $self ) = @_;
  return if $self->{cursor_h} >= $self->_min_width;

  $self->{cursor_h}++;
  if ( $self->{cursor_h} >= $self->_min_width )
    {
    $self->{cursor_h} = $self->_min_width - 1;
    $self->{left}++;
    }

  my $right = $self->_max_width - $self->{viewport_width};
  if ( $self->{left} >= $right )
    {
    $self->{left} = $right;
    }
  }

# }}}

# {{{ Cursor flush movements

# {{{ cursor_flush_top

=head2 cursor_flush_top

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_flush_top
  {
  my ( $self ) = @_;

  $self->{cursor_v} = 0;
  $self->{top} = 0;
  }

# }}}

# {{{ cursor_flush_left

=head2 cursor_flush_left

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_flush_left
  {
  my ( $self ) = @_;

  $self->{cursor_h} = 0;
  $self->{left} = 0;
  }

# }}}

# {{{ cursor_flush_bottom

=head2 cursor_flush_bottom

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_flush_bottom
  {
  my ( $self ) = @_;

  $self->{cursor_v} = $self->_min_height - 1;
  if ( $self->{viewport_height} < $self->{pane_height} )
    {
    $self->{top} = $self->{pane_height} - $self->{viewport_height};
    }
  else
    {
    $self->{top} = 0;
    }
  }

# }}}

# {{{ cursor_flush_right

=head2 cursor_flush_right

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_flush_right
  {
  my ( $self ) = @_;

  $self->{cursor_h} = $self->_min_width - 1;
  if ( $self->{viewport_width} < $self->{pane_width} )
    {
    $self->{left} = $self->{pane_width} - $self->{viewport_width};
    }
  else
    {
    $self->{left} = 0;
    }
  }

# }}}

# }}}

# {{{ Cursor viewport movements

# {{{ cursor_viewport_top

=head2 cursor_viewport_top

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_viewport_top
  {
  my ( $self ) = @_;

  $self->{cursor_v} = 0;
  }

# }}}

# {{{ cursor_viewport_left

=head2 cursor_viewport_left

Return the cursor's horizontal position relative to the viewport

=cut

sub cursor_viewport_left
  {
  my ( $self ) = @_;

  $self->{cursor_h} = 0;
  }

# }}}

# {{{ cursor_viewport_bottom

=head2 cursor_viewport_bottom

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_viewport_bottom
  {
  my ( $self ) = @_;

  $self->{cursor_v} = $self->_min_height - 1;
  }

# }}}

# {{{ cursor_viewport_right

=head2 cursor_viewport_right

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_viewport_right
  {
  my ( $self ) = @_;

  $self->{cursor_h} = $self->_min_width - 1;
  }

# }}}

# {{{ cursor_viewport_vertical_center

=head2 cursor_viewport_vertical_center

Return the cursor's vertical position relative to the viewport

=cut

sub cursor_viewport_vertical_center
  {
  my ( $self ) = @_;

  $self->{cursor_v} = ( $self->_min_height / 2 ) - 1;
  }

# }}}

# }}}

# }}}

# {{{ viewport routines

# {{{ viewport_h

=head2 viewport_h

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_h
  {
  my ( $self ) = @_;
  return $self->{left};
  }

# }}}

# {{{ viewport_v

=head2 viewport_v

Return the cursor's horizontal position relative to the viewport

=cut

sub viewport_v
  {
  my ( $self ) = @_;
  return $self->{top};
  }

# }}}

# {{{ viewport_up

=head2 viewport_up

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_up
  {
  my ( $self ) = @_;
  return if $self->{top} <= 0;

  $self->{top}--;
  }

# }}}

# {{{ viewport_left

=head2 viewport_left

Return the cursor's horizontal position relative to the viewport

=cut

sub viewport_left
  {
  my ( $self ) = @_;
  return if $self->{left} <= 0;

  $self->{left}--;
  }

# }}}

# {{{ viewport_down

=head2 viewport_down

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_down
  {
  my ( $self ) = @_;
  return unless $self->{viewport_height} < $self->{pane_height} and
    $self->{top} + $self->{viewport_height} < $self->{pane_height};

  $self->{top}++;
  }

# }}}

# {{{ viewport_right

=head2 viewport_right

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_right
  {
  my ( $self ) = @_;
  return unless $self->{viewport_width} < $self->{pane_width} and
    $self->{left} + $self->{viewport_width} < $self->{pane_width};

  $self->{left}++;
  }

# }}}

# {{{ viewport_flush_top

=head2 viewport_flush_top

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_flush_top
  {
  my ( $self ) = @_;

  $self->{top} = 0;
  }

# }}}

# {{{ viewport_flush_left

=head2 viewport_flush_left

Return the cursor's horizontal position relative to the viewport

=cut

sub viewport_flush_left
  {
  my ( $self ) = @_;

  $self->{left} = 0;
  }

# }}}

# {{{ viewport_flush_bottom

=head2 viewport_flush_bottom

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_flush_bottom
  {
  my ( $self ) = @_;

  if ( $self->{viewport_height} < $self->{pane_height} )
    {
    $self->{top} = $self->{pane_height} - $self->{viewport_height};
    }
  else
    {
    $self->{top} = 0;
    }
  }

# }}}

# {{{ viewport_flush_right

=head2 viewport_flush_right

Return the cursor's vertical position relative to the viewport

=cut

sub viewport_flush_right
  {
  my ( $self ) = @_;

  if ( $self->{viewport_width} < $self->{pane_width} )
    {
    $self->{left} = $self->{pane_width} - $self->{viewport_width};
    }
  else
    {
    $self->{left} = 0;
    }
  }

# }}}

# }}}

1;
__END__

=head1 NAME

Pane - Scroll a virtual viewport around a 2-d pane of text

=head1 VERSION

This document describes Pane version 0.0.3

=head1 SYNOPSIS

    use Pane;

    $pane = Pane->new;
    $pane->viewport_left;
    $pane->cursor_down; 
  
=head1 DESCRIPTION

A straightforward implementation of a 2-d viewport capable of scrolling around
in a 2-d pane of text. The pane can be larger or smaller than the viewport, the
code is meant to DTRT in either case.

=head1 INTERFACE 

Instantiate the module with C<< $pane = Pane->new({ pane_height => 100 }) >>.
You can set the pane and viewport boundaries with C<pane_height>,
C<pane_width>, C<viewport_height> and C<viewport_width>. These members can be 
altered at any time through the appropriate accessors C<set_pane_width> etc.

C<cursor_v> and C<cursor_h> are always relative to the viewport's top-left
corner, and will never stray outside the boundaries of the viewport. If you need
to obtain the cursor's coordinates relative to the pane, you can use the
C<global_cursor_v> and C<global_cursor_h> functions to obtain the cursor's
position within the underlying pane.

Moving the cursor around with the supplied C<cursor_left> etc. routines will
move the cursor relative to the viewport. Also, if the cursor happens to be at
an edge of the viewport, the entire viewport itself may scroll, if there is
sufficient room to move the viewport.

You can also move the viewport itself with the supplied C<viewport_up> etc.
routines. These will not affect the cursor's location within the viewport.

=head1 DIAGNOSTICS

viewport width too small

  Viewport width must be > 0

viewport height too small

  Viewport height must be > 0

pane width too small

  Pane width must be > 0

pane height too small

  Pane height must be > 0

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Pane requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-pane@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Jeffrey Goff  C<< <jgoff@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Jeffrey Goff C<< <jgoff@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
