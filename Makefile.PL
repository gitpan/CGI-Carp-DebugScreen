use strict;
use ExtUtils::MakeMaker;

my %args;
$args{NAME}          = 'CGI::Carp::DebugScreen';
$args{AUTHOR}        = 'Kenichi Ishigaki <ishigaki@cpan.org>';
$args{VERSION_FROM}  = 'lib/CGI/Carp/DebugScreen.pm';
$args{ABSTRACT_FROM} = 'lib/CGI/Carp/DebugScreen.pm';
$args{PREREQ_PM}     = {
  'CGI::Carp' => 0,
};
$args{LICENSE} = 'perl' if $ExtUtils::MakeMaker::VERSION >= 6.31;

WriteMakefile( %args );
