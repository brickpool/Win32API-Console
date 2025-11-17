use strict;
use warnings;
use utf8;

use Test::More tests => 6;
use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
  use_ok 'TestConsole', qw( GetConsoleOutputHandle );
  use_ok 'Win32API::Console', qw(
    WriteConsoleOutputCharacterA
    WriteConsoleOutputCharacterW
    ReadConsoleOutputCharacterA
    ReadConsoleOutputCharacterW
    WriteConsoleOutputAttribute
    ReadConsoleOutputAttribute
    SetConsoleCursorPosition
    INVALID_HANDLE_VALUE
    COORD
  );
}

# Get a handle to the current console output
my $hConsole = GetConsoleOutputHandle();
diag "$^E" if $^E;

SKIP: {
  skip "No real console output handle available" => 4 unless $hConsole;

  ok(
    SetConsoleCursorPosition($hConsole, COORD(0,0)), 
    'SetConsoleCursorPosition call succeeded'
  );

  subtest 'WriteConsoleOutputAttribute / ReadConsoleOutputAttribute' => sub {
    my $attr = 0x0e;  # Yellow on black
    my $coord = { X => 0, Y => 0 };
    my $written;

    my $ok = WriteConsoleOutputAttribute($hConsole, pack('S*', ($attr) x 3), 
      $coord, \$written);
    diag "$^E" if $^E;
    ok($ok, 'WriteConsoleOutputCharacter call succeeded');
    ok($written == 3, 'WriteConsoleOutputAttribute wrote 3 attributes');

    my $read_attr;
    my $read;
    $ok = ReadConsoleOutputAttribute($hConsole, \$read_attr, 3, $coord, \$read);
    diag "$^E" if $^E;
    ok($ok, 'ReadConsoleOutputAttribute call succeeded');
    is(
      $read_attr,
      pack('S*', ($attr) x 3),
      'ReadConsoleOutputAttribute returned expected attributes'
    );
  };

  subtest 'WriteConsoleOutputCharacterA / ReadConsoleOutputCharacterA' => sub {
    my $text = "Hallöchen";
    my $coord = { X => 0, Y => 0 };
    my $written;

    my $ok = WriteConsoleOutputCharacterA($hConsole, $text, $coord, \$written);
    diag "$^E" if $^E;
    ok($ok, 'WriteConsoleOutputCharacterA call succeeded');
    is(
      $written, 
      length($text), 
      'WriteConsoleOutputCharacterA wrote correct number of characters'
    );

    my $chars;
    my $read;
    $ok = ReadConsoleOutputCharacterA($hConsole, \$chars, $written, 
      $coord, \$read);
    diag "$^E" if $^E;
    ok($ok, 'ReadConsoleOutputCharacterA call succeeded');
    is($chars, $text, 'ReadConsoleOutputCharacterA returned expected text');
  };

  subtest 'WriteConsoleOutputCharacterW / ReadConsoleOutputCharacterW' => sub {
    my $text = "Olá";
    my $coord = { X => 0, Y => 1 };
    my $written;

    my $ok = WriteConsoleOutputCharacterW($hConsole, $text, $coord, \$written);
    diag "$^E" if $^E;
    ok($ok, 'WriteConsoleOutputCharacterW call succeeded');
    is(
      $written, 
      length($text), 
      'WriteConsoleOutputCharacterW wrote correct number of characters'
    );

    my $chars;
    my $read;
    $ok = ReadConsoleOutputCharacterW($hConsole, \$chars, length($text), 
      $coord, \$read);
    diag "$^E" if $^E;
    ok($ok, 'ReadConsoleOutputCharacterW call succeeded');
    is($chars, $text, 'ReadConsoleOutputCharacterW returned expected text');
  };
}

done_testing();
