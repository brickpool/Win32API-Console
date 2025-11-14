use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
  use_ok 'Win32API::Console', qw(
    GetStdHandle
    GetConsoleDisplayMode
    GetConsoleScreenBufferInfo
    GetLargestConsoleWindowSize
    SetConsoleDisplayMode
    STD_ERROR_HANDLE
    :DISPLAY_MODE_
  );
}

use constant ERROR_CALL_NOT_IMPLEMENTED => 120;

# Get handle for STDOUT
my $hConsole = GetStdHandle(STD_ERROR_HANDLE);
ok(defined $hConsole, 'STD_ERROR_HANDLE is defined');

# Get current display mode (may fail depending on environment)
my $mode = 0;
my $r = GetConsoleDisplayMode(\$mode);
diag "$^E" if $^E;
SKIP: {
  skip 'GetConsoleDisplayMode not supported', 2 
    if $^E == ERROR_CALL_NOT_IMPLEMENTED;
  ok($r, 'GetConsoleDisplayMode returned true');
  ok(
    $mode >= 0 || $mode <= 2,
    "Display mode is either 0 (windowed) or 1,2 (fullscreen): $mode"
  );
};

# Get screen buffer info
my %buffer_info;
$r = GetConsoleScreenBufferInfo($hConsole, \%buffer_info);
diag "$^E" if $^E;
ok($r, 'GetConsoleScreenBufferInfo returned true');

# Get largest possible window size
my $largest = GetLargestConsoleWindowSize($hConsole);
diag "$^E" if $^E;
ok($largest->{X} > 0 && $largest->{Y} > 0, 'Largest window size is valid');

# Attempt to set display mode (may fail depending on environment)
my %dimension;
my $flags = $mode ? CONSOLE_WINDOWED_MODE : CONSOLE_FULLSCREEN_MODE;
$r = SetConsoleDisplayMode($hConsole, $flags, \%dimension);
diag "$^E" if $^E;
SKIP: {
  skip 'SetConsoleDisplayMode not supported', 3 
    if $^E == ERROR_CALL_NOT_IMPLEMENTED;
  ok($r, 'SetConsoleDisplayMode reapplied current mode');
  ok(
    $buffer_info{dwSize}{X} != $dimension{X} 
      ||
    $buffer_info{dwSize}{Y} != $dimension{Y},
    'SetConsoleDisplayMode changed the current mode'
  );
  $r = SetConsoleDisplayMode(
    $hConsole, 
    $mode ? CONSOLE_FULLSCREEN_MODE : CONSOLE_WINDOWED_MODE,
    \%dimension
  );
  diag "$^E" if $^E;
  ok($r, 'Display mode successfully restored');
}

done_testing();
