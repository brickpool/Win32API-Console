use strict;
use warnings;

use Test::More tests => 7;
use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
  use_ok 'TestConsole', qw( GetConsoleOutputHandle );
  use_ok 'Win32API::Console', qw(
    GetConsoleCursorInfo
    SetConsoleCursorInfo
    INVALID_HANDLE_VALUE
  );
}

# Get a handle to the current console output
my $hConsole = GetConsoleOutputHandle();
diag "$^E" if $^E;
unless ($hConsole) {
  plan skip_all => "No real console output handle available";
  exit;
}
isnt($hConsole, INVALID_HANDLE_VALUE, 'Obtained console handle');

# Get current cursor info
my %cursor_info;
my $got = GetConsoleCursorInfo($hConsole, \%cursor_info);
diag "$^E" if $^E;
ok($got, 'GetConsoleCursorInfo returned true');
ok($cursor_info{dwSize} > 0, 'Cursor size is greater than 0');

# Toggle cursor visibility
my %new_cursor_info = (
  dwSize   => $cursor_info{dwSize},
  bVisible => $cursor_info{bVisible} ? 0 : 1,  # invert visibility
);

my $set = SetConsoleCursorInfo($hConsole, \%new_cursor_info);
diag "$^E" if $^E;
ok($set, 'SetConsoleCursorInfo successfully changed visibility');

$set = SetConsoleCursorInfo($hConsole, \%cursor_info);
diag "$^E" if $^E;
ok($set, 'Cursor info successfully restored');

done_testing();
