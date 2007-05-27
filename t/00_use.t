use strict;
use Test::More tests => 3;
BEGIN {
  use_ok('CGI::Carp::DebugScreen');
  use_ok('CGI::Carp::DebugScreen::DefaultView');
  use_ok('CGI::Carp::DebugScreen::Dumper');
}

