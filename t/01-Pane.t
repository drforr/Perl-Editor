use Test::More tests => 181;

BEGIN
  {
  use_ok( 'Pane' );
  }

diag( "Testing Pane $Pane::VERSION" );

# {{{ Pane and viewport the same size
{
my $pane = Pane->new;

ok($pane->cursor_v == 0);
ok($pane->cursor_h == 0);

ok($pane->viewport_v == 0);
ok($pane->viewport_h == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_down;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_right;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_up;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_left;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_bottom;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_right;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_top;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);
}

# }}}

# {{{ Pane larger than viewport by 1 in both dimensions
{
my $pane = Pane->new({ pane_width => 81, pane_height => 25 });

ok($pane->cursor_v == 0);
ok($pane->cursor_h == 0);

ok($pane->viewport_v == 0);
ok($pane->viewport_h == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_down;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 1);

for ( 0 ... 100 )
  {
  $pane->cursor_right;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 1);

for ( 0 ... 100 )
  {
  $pane->cursor_up;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_left;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_bottom;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 1);

$pane->cursor_flush_right;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 1);

$pane->cursor_flush_top;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 0);

$pane->cursor_flush_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);
}

# }}}

# {{{ Viewport larger than pane by 1 in both dimensions
{
my $pane = Pane->new({ viewport_width => 81, viewport_height => 25 });

ok($pane->cursor_v == 0);
ok($pane->cursor_h == 0);

ok($pane->viewport_v == 0);
ok($pane->viewport_h == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_down;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_right;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_up;
  }
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

for ( 0 ... 100 )
  {
  $pane->cursor_left;
  }
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_bottom;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_right;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 23);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_top;
ok($pane->cursor_h == 79);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->cursor_flush_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);
}

# }}}

# {{{ Viewport larger than pane by 1 in both dimensions, move viewport around
{
my $pane = Pane->new({ viewport_width => 81, viewport_height => 25 });

ok($pane->cursor_v == 0);
ok($pane->cursor_h == 0);

ok($pane->viewport_v == 0);
ok($pane->viewport_h == 0);

$pane->viewport_down;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_right;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_up;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_flush_bottom;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_flush_right;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_flush_top;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_flush_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);
}

# }}}

# {{{ Pane larger than viewport by 1 in both dimensions, move viewport
{
my $pane = Pane->new({ pane_width => 81, pane_height => 25 });

ok($pane->cursor_v == 0);
ok($pane->cursor_h == 0);

ok($pane->viewport_v == 0);
ok($pane->viewport_h == 0);

$pane->viewport_down;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 1);

$pane->viewport_right;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 1);

$pane->viewport_up;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 0);

$pane->viewport_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);

$pane->viewport_flush_bottom;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 1);

$pane->viewport_flush_right;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 1);

$pane->viewport_flush_top;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 1);
ok($pane->viewport_v == 0);

$pane->viewport_flush_left;
ok($pane->cursor_h == 0);
ok($pane->cursor_v == 0);
ok($pane->viewport_h == 0);
ok($pane->viewport_v == 0);
}

# }}}
