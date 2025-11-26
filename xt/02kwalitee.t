use strict;
use warnings;

use Test::More;

BEGIN {
  eval "require Test::Kwalitee";
  plan skip_all => "Test::Kwalitee required for testing POD" if $@;
  use_ok 'Test::Kwalitee', qw( kwalitee_ok );
} 

plan skip_all => "AUTHOR_TESTING required for testing Kwalitee" 
  unless $ENV{AUTHOR_TESTING};

kwalitee_ok();

done_testing;
