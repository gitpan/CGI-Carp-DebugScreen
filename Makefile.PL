use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CGI::Carp::DebugScreen',
    VERSION_FROM      => 'lib/CGI/Carp/DebugScreen.pm', # finds $VERSION
    PREREQ_PM         => {
       CGI::Carp => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CGI/Carp/DebugScreen.pm', # retrieve abstract from module
       AUTHOR         => 'Kenichi Ishigaki <ishigaki@cpan.org>') : ()),
);
