use strict;
use warnings;

use Test::More;

BEGIN {
  eval "use Test::Pod::Links";
  plan skip_all => "Test::Pod::Links required for testing POD" if $@;
}

plan skip_all => "AUTHOR_TESTING required for testing POD" 
  unless $ENV{AUTHOR_TESTING};

my $tpl = Test::Pod::Links->new(
  ignore => 'https://github.com/microsoft/terminal/issues/14885',
);
$tpl->pod_file_ok('lib/Win32API/Console.pod');
$tpl->pod_file_ok('samples/clear-screen2.pl');
$tpl->pod_file_ok('samples/clear-screen3.pl');
$tpl->pod_file_ok('samples/ctrl-handler.pl');
$tpl->pod_file_ok('samples/high-level.pl');
$tpl->pod_file_ok('samples/read-input-buffer.pl');
$tpl->pod_file_ok('samples/read-write-blocks.pl');
$tpl->pod_file_ok('samples/scroll-screen-window.pl');

done_testing();
