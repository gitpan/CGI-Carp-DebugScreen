use strict;
use Test::More tests => 1;
BEGIN {

SKIP: {
  eval 'require Template';
  skip('skip; no Template Toolkit',1) if $@;

  use_ok('CGI::Carp::DebugScreen::TT');
}

}

