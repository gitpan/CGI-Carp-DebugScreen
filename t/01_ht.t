use strict;
use Test::More tests => 1;
BEGIN {

SKIP: {
  eval 'require HTML::Template';
  skip('skip; no HTML::Template',1) if $@;

  use_ok('CGI::Carp::DebugScreen::HTML::Template');
}

}

