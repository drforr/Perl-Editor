use Test::More tests => 10;

BEGIN
  {
  use_ok( q{Packer} );
  }

diag( "Testing Packer $Packer::VERSION" );

{
  my $packer = Packer->new({ top => 0, height => 2 });
  eval
    {
    $packer->add;
    };
  ok($@ and $@ =~ /height required/, q{Height required});
  eval
    {
    $packer->add({ height => -3 });
    };
  ok($@ and $@ =~ /height cannot be negative/, q{Height cannot be negative});
  eval
    {
    $packer->add({ height => q{foo} });
    };
  ok($@ and $@ =~ /height is not a number/, q{Height must be a number or stretchy});
  eval
    {
    $packer->add({ height => 5 });
    };
  ok($@ and $@ =~ /exceeds viewport/, q{Height must fit within window});
}

{
  my $packer = Packer->new({ top => 0, height => 2 });

  $packer->add({ height => 1 });
  $packer->add({ height => 1 });

  is_deeply
    (
    [$packer->finalize],
    [
      { viewport_top => 0, viewport_height => 1 },
      { viewport_top => 1, viewport_height => 1 }
    ],
    q{Two narrow panes},
    );
}

{
  my $packer = Packer->new({ top => 0, height => 2 });

  $packer->add({ height => q{stretchy} });
  $packer->add({ height => q{stretchy} });

  is_deeply
    (
    [$packer->finalize],
    [
      { viewport_top => 0, viewport_height => 1 },
      { viewport_top => 1, viewport_height => 1 }
    ],
    q{Two narrow panes, both stretchy},
    );
}

{
  my $packer = Packer->new({ top => 0, height => 2 });

  $packer->add({ height => 1 });
  $packer->add({ height => q{stretchy} });

  is_deeply
    (
    [$packer->finalize],
    [
      { viewport_top => 0, viewport_height => 1 },
      { viewport_top => 1, viewport_height => 1 }
    ],
    q{Two narrow panes, one stretchy},
    );
}

{
  my $packer = Packer->new({ top => 0, height => 3 });

  $packer->add({ height => 1 });
  $packer->add({ height => 1 });
  $packer->add({ height => q{stretchy} });

  is_deeply
    (
    [$packer->finalize],
    [
      { viewport_top => 0, viewport_height => 1 },
      { viewport_top => 1, viewport_height => 1 },
      { viewport_top => 2, viewport_height => 1 }
    ],
    q{Three narrow panes, one stretchy},
    );
}

{
  my $packer = Packer->new({ top => 0, height => 3 });

  $packer->add({ height => 1 });
  $packer->add({ height => q{stretchy} });
  $packer->add({ height => q{stretchy} });

  is_deeply
    (
    [$packer->finalize],
    [
      { viewport_top => 0, viewport_height => 1 },
      { viewport_top => 1, viewport_height => 1 },
      { viewport_top => 2, viewport_height => 1 }
    ],
    q{Three narrow panes, two stretchy},
    );
}
