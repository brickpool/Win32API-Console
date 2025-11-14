use strict;
use warnings;
use utf8;

use Test::More tests => 6;

BEGIN {
  use_ok 'Win32API::Console', qw(
    GetStdHandle
    GetConsoleScreenBufferInfo
    SetConsoleScreenBufferSize
    ScrollConsoleScreenBufferA
    ScrollConsoleScreenBufferW
    STD_ERROR_HANDLE
  );
}

my $hConsole = GetStdHandle(STD_ERROR_HANDLE);
ok(defined $hConsole, 'STD_ERROR_HANDLE is defined');

my %size;
subtest 'GetConsoleScreenBufferInfo' => sub {
  my %info;
  ok(
    GetConsoleScreenBufferInfo($hConsole, \%info), 
    'Retrieved original screen buffer info'
  );
  diag "$^E" if $^E;

  %size = %{ $info{dwSize} };
  ok(
    $size{X} > 0 && $size{Y} > 0, 
    'Original buffer size is valid'
  );
};

subtest 'SetConsoleScreenBufferSize and restore' => sub {
  my %new_size = (
    X => $size{X},
    Y => $size{Y} + 50,  # increase height
  );

  # Set new and restore size
  ok(
    SetConsoleScreenBufferSize($hConsole, \%new_size), 
    'SetConsoleScreenBufferSize applied new size'
  );
  diag "$^E" if $^E;
  ok(
    SetConsoleScreenBufferSize($hConsole, \%size), 
    'Restored original buffer size'
  );
  diag "$^E" if $^E;
};

subtest 'ScrollConsoleScreenBuffer' => sub {
  my %rect = ( Left => 0, Top => 0, Right => 10, Bottom => 10 );
  my %coord = ( X => 0, Y => -1 );    # scroll up
  my $fill = unpack('L', pack('CxS', ord('*'), 0x07));

  select(undef, undef, undef, 0.5);
  my $ok = ScrollConsoleScreenBufferA($hConsole, \%rect, undef, \%coord, $fill);
  diag "$^E" if $^E;
  ok($ok, 'ScrollConsoleScreenBufferA ok region');

  $fill = unpack('L', pack('SS', ord("ö"), 0x07));

  select(undef, undef, undef, 0.5);
  $ok = ScrollConsoleScreenBufferW($hConsole, \%rect, undef, \%coord, $fill);
  diag "$^E" if $^E;
  ok($ok, 'ScrollConsoleScreenBufferW ok region');
};

subtest 'Wrapper for the Unicode and ANSI functions' => sub {
  can_ok('Win32API::Console', 'ScrollConsoleScreenBuffer');
};

done_testing();
