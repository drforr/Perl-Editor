package Packer;

use warnings;
use strict;
use Carp;

use version;
our $VERSION = q{0.0.3};

# {{{ new

=head2 new({ .. })

=cut

sub new
  {
  my ( $proto, $args ) = @_;
  my $class = ref $proto || $proto;

  croak q{top required} unless defined $args->{top};
  croak q{height required} unless defined $args->{height};
  croak q{top cannot be negative} if
    $args->{top} and $args->{top} <= 0;
  unless ( $args->{height} eq 'stretchy' )
    {
    croak q{height too small} if
      $args->{height} and $args->{height} <= 0;
    }

  croak q{top above screen top} if
    $args->{top} and $args->{top} <= 0;

# {{{ Self
  my $self =
    {
    top  => $args->{top}  || 0,
    height => $args->{height} || 24,

    accum_height => 0,
    };

# }}}

  return bless $self, $class;
  }

# }}}

# {{{ add

=head2 add({ .. })

=cut

sub add
  {
  my ( $self, $args ) = @_;

  croak q{height required} unless defined $args->{height};
  croak q{height is not a number or stretchy}
    unless $args->{height} =~ m{^\d+|stretchy$};
  unless ( $args->{height} eq 'stretchy' )
    {
    croak q{height cannot be negative} if $args->{height} < 0;
    croak qq{pane of height $args->{height} exceeds viewport size}
      unless $self->{accum_height} + $args->{height} <= $self->{height};
    }

  $self->{accum_height} += $args->{height} if $args->{height} ne 'stretchy';

  push @{$self->{panes}}, $args->{height};
  }

# }}}

# {{{ finalize

=head2 finalize({ .. })

=cut

sub finalize
  {
  my ( $self ) = @_;
  my @panes;

  my $fixed_heights = 0;
  my $stretchy_count = 0;

  for my $height ( @{$self->{panes}} )
    {
    if ( $height eq 'stretchy' ) { $stretchy_count++; }
    else { $fixed_heights += $height }
    }

  my $stretchy_height = 0;
  if ( $stretchy_count > 0 )
    {
    $stretchy_height = ( $self->{height} - $fixed_heights ) / $stretchy_count;
    }

  my $cur_top = $self->{top};
  for my $height ( @{$self->{panes}} )
    {
    if ( $height eq q{stretchy} )
      {
      push @panes,
        {
        viewport_top => $cur_top,
        viewport_height => $stretchy_height,
        };
      $cur_top += $stretchy_height;
      }
    else
      {
      push @panes,
        {
        viewport_top => $cur_top,
        viewport_height => $height,
        };
      $cur_top += $height;
      }
    }

  return @panes;
  }

# }}}

1;
__END__

=head1 NAME

Packer - Pack panes into a viewport.

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
