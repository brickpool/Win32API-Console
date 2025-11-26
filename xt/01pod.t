use strict;
use warnings;

use Test::More;

BEGIN {
  eval "use Test::Pod";
  plan skip_all => "Test::Pod required for testing POD" if $@;
}

plan skip_all => "AUTHOR_TESTING required for testing POD" 
  unless $ENV{AUTHOR_TESTING};

my @poddirs = qw( blib );

all_pod_files_ok( all_pod_files( @poddirs ) );
