use 5.012;
use strict;
use warnings;
use utf8;

use Test::More tests => 8;
use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
  use_ok 'TestConsole', qw( GetConsoleOutputHandle );
  use_ok 'Win32API::Console', qw(
    FillConsoleOutputCharacterW
    FillConsoleOutputCharacterA
    INVALID_HANDLE_VALUE
  );
}

# Get a handle to the current console output
my $handle = GetConsoleOutputHandle();
diag "$^E" if $^E;
unless ($handle) {
  plan skip_all => "No real console output handle available";
  exit;
}
isnt($handle, INVALID_HANDLE_VALUE, 'Obtained console handle');

# Define the write position and length
my %coord = (X => 0, Y => 0);
my $length = 10;
my $written = 0;

# Define the Unicode character to write (e.g., U+2592: Medium Shade Block)
my $char = "\N{U+2592}";

# Call the wrapper functions for FillConsoleOutputCharacter
my $ok = FillConsoleOutputCharacterW(
    $handle,
    $char,
    $length,
    \%coord,
    \$written
);
diag "$^E" unless $ok;

ok($ok, 'FillConsoleOutputCharacterW call succeeded');
is($written, $length, 'Correct number of characters written');

$char = 'ö';
$coord{X} = $written;

$ok = FillConsoleOutputCharacterA(
    $handle,
    $char,
    $length,
    \%coord,
    \$written
);
diag "$^E" unless $ok;

ok($ok, 'FillConsoleOutputCharacterA call succeeded');
is($written, $length, 'Correct number of characters written');

subtest 'Wrapper for the Unicode and ANSI functions' => sub {
  can_ok('Win32API::Console', 'FillConsoleOutputCharacter');
};

done_testing();
