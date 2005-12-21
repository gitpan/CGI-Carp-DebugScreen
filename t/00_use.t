use strict;
use Test::More tests => 4;
BEGIN {
  use_ok('CGI::Carp::DebugScreen');
  use_ok('CGI::Carp::DebugScreen::DefaultView');
  use_ok('CGI::Carp::DebugScreen::TT');
  use_ok('CGI::Carp::DebugScreen::HTML::Template');
}

