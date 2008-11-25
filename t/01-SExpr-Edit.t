#!perl -T

use Test::More tests => 1;

BEGIN
  {
  use_ok( 'Editor' );
  }

diag( "Testing Editor $Editor::VERSION, Perl $], $^X" );
