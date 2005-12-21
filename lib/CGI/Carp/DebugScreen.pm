package CGI::Carp::DebugScreen;
{
  use strict;
  use warnings;
  use Exporter;
  use CGI::Carp qw/fatalsToBrowser/;

  our $VERSION = '0.02';

  BEGIN {
    my $MyDebug = 0;
    CGI::Carp::set_message(
      sub { __PACKAGE__->show(@_) }
    ) unless $MyDebug;
  }

  $Carp::Verbose = 1;   # for stack traces

  my $Debug  = 1;
  my $Engine = 'DefaultView';
  my $ShowLines = 3;
  my $ShowMod;
  my $ShowEnv;
  my $ShowRawError;
  my $DebugTemplate;
  my $ErrorTemplate;

  my $Style =<<'EOS';
<style type="text/css">
<!--
  body {
    font-family: "Bitstream Vera Sans", "Trebuchet MS", Verdana,
    Tahoma, Arial, helvetica, sans-serif;
    color: #000;
    background-color: #f60;
    margin: 0px;
    padding: 0px;
  }
  :link, :link:hover, :visited, :visited:hover {
    color: #333;
  }
  div#page {
    position: relative;
    background-color: #fff;
    border: 1px solid #600;
    padding: 10px;
    margin: 10px;
    -moz-border-radius: 10px;
  }
  div.navi {
    color: #333;
    padding: 0 4px;
  }
  div.box {
    background-color: #fff;
    border: 3px solid #fc9;
    padding: 8px;
    margin: 4px;
    margin-bottom: 10px;
    -moz-border-radius: 10px;
  }
  h1 {
    margin: 0;
    color: #666;
  }
  h2 {
    margin-top: 0;
    margin-bottom: 10px;
    font-size: medium;
    font-weight: bold;
    text-decoration: underline;
  }
  table.code {
    font-size: .8em;
    line-height: 120%;
    font-family: 'Courier New', Courier, monospace;
    background-color: #fc9;
    color: #333;
    border: 1px dotted #600;
    margin: 8px;
    width: 90%;
    border-collapse: collapse;
  }
  table.code tr.hit {
    font-weight: bold;
    color: #000;
    background-color: #f90;
  }
  table.code td {
    padding-left: 1em;
    line-height: 130%;
  }
  table.code td.num {
    width: 4em;
    text-align:right
  }
  div.scrollable {
    font-size: .8em;
    overflow: auto;
    margin-left: 1em;
  }
  pre.raw_error {
    background-color: #fff;
    border: 3px solid #fc9;
    padding: 8px;
    margin: 4px;
    margin-bottom: 10px;
    -moz-border-radius: 10px;
    font-size: .8em;
    line-height: 120%;
    font-family: 'Courier New', Courier, monospace;
    overflow: auto;
  }
  ul#traces, ul#modules {
    margin: 1em 1em;
    padding: 0 1em;
  }
  table#environment {
    margin: 0 1em;
  }
-->
</style>
EOS

  sub import {
    my $pkg = shift;
    my %options = @_;
    while(my ($key, $value) = each %options) {
      next unless defined $value;
      $key = lc $key;
      $Debug         = $value if $key =~ /^d(?:ebug)?$/;
      $Engine        = $value if $key =~ /^e(?:ngine)?$/;
      $ShowLines     = $value if $key =~ /^l(?:ines)?$/;
      $ShowMod       = $value if $key =~ /^m(?:od(?:ules)?)?$/;
      $ShowEnv       = $value if $key =~ /^env(?:ironment)?$/;
      $ShowRawError  = $value if $key =~ /^raw(?:_error)?$/;
      $DebugTemplate = $value if $key =~ /^d(?:ebug_)?t(?:emplate)?$/;
      $ErrorTemplate = $value if $key =~ /^e(?:rror_)?t(?:emplate)?$/;
      $Style         = $value if $key =~ /^s(?:tyle)?$/;
    }
  }

  sub debug              { shift; $Debug    = shift; }
  sub set_debug_template { shift; $DebugTemplate = shift; }
  sub set_error_template { shift; $ErrorTemplate = shift; }
  sub set_style          { shift; $Style = shift; }
  sub show_modules       { shift; $ShowMod = shift; }
  sub show_environment   { shift; $ShowEnv = shift; }
  sub show_raw_error     { shift; $ShowRawError = shift; }

  sub show {
    my ($pkg, $errstr) = @_;

    my $first_message = '';
    my @traces = grep {
        my $caller = $_->{caller};
        (
          $caller eq $INC{'Carp.pm'} or     # ignore Carp;
          $caller eq $INC{'CGI/Carp.pm'}    # ignore CGI::Carp;
        ) ? 0 : 1;
      }
      map {
      my $line = $_;
      my ($message, $caller, $line_no) = $line =~ /^(?:\s*)(.*?)(?: called)? at (\S+) line (\d+)\.?$/;
      $first_message = $message unless $first_message && defined $message;
      my $contents = _get_contents($caller,$line_no);
      +{
         message  => $message,
         caller   => $caller,
         contents => $contents,
         line     => $line_no,
       }
    } split(/\n/,$errstr);

    my $error_at = $traces[$#traces]->{caller};

    my @modules = ();
    @modules = map {
      my $key = $_;
      (my $package = $key) =~ s|/|::|g;
      +{
        package => $package,
        file    => $INC{$key},
      }
    } sort {$a cmp $b} keys %INC if $ShowMod;

    my @environment = ();
    @environment = map {
      +{
        key   => $_,
        value => $ENV{$_},
      }
    } sort {$a cmp $b} keys %ENV if $ShowEnv;

    my $viewer = __PACKAGE__.'::'.$Engine;

    eval "require $viewer";
    if ($@) {
      require CGI::Carp::DebugScreen::DefaultView;
      $viewer = 'CGI::Carp::DebugScreen::DefaultView';
    }

    $viewer->show(
      debug          => $Debug,
      debug_tmpl     => $DebugTemplate,
      error_tmpl     => $ErrorTemplate,
      style          => $Style,
      error_at       => $error_at,
      error_message  => $first_message.' at '.$traces[0]->{caller}.' line '.$traces[0]->{line},
      raw_error      => $errstr,
      show_raw_error => $ShowRawError,
      traces         => \@traces,
      modules        => \@modules,
      environment    => \@environment,
    );
  }

  sub _get_contents {
    my ($file, $line_no) = @_;

    my @contents;
    if (open my $fh, '<'.$file) {
      my $ct = 0;
      while(my $line = <$fh>) {
        $ct++;
        next if $ct < $line_no - $ShowLines;
        last if $ct > $line_no + $ShowLines;
        push @contents, {
          no   => $ct,
          line => $line,
          hit  => ($ct == $line_no),
        };
      }
    }
    \@contents;
  }
}
__END__

=head1 NAME

CGI::Carp::DebugScreen - provides a decent debug screen for Web 
applications

=head1 SYNOPSIS

  use CGI::Carp::DebugScreen(
    debug       => 1,
    engine      => 'HTML::Template',
    lines       => 5,
    modules     => 1,
    environment => 1,
    raw_error   => 0,
  );

  croak "let's see";

=head1 DESCRIPTION

CGI::Carp qw/fatalsToBrowser/ is very useful for debugging. 
But the error screen it provides is a bit too plain; something 
you don't want to see, and you don't want your boss and 
colleagues and users to see. You might know CGI::Carp has a 
wonderful set_message() function but, hey, you don't want to 
repeat yourself, right?

Hence this module.

This module calls CGI::Carp qw/fatalsToBrowser/ and set_message() 
function internally. If something dies or croaks, this confesses 
stack traces, included modules (optional), environmental variables
(optional, too) in a more decent way.

When you finish debugging, set debug option to false. Then, more 
limited, less informative error screen appears when dies or croaks.
If something goes wrong and your users might see the screen, they 
only know something has happened. They'll never know where your 
modules are and they'll never see the awkward 500 Internal Server 
Error -- hopefully.

You can, and are suggested to, customize both debug and error 
screens, and some style settings, in harmony with your application.

Enjoy.

=head1 OPTIONS

  use CGI::Carp::DebugScreen (
    debug       => 1,
    engine      => 'HTML::Template',
    lines       => 5,
    modules     => 1,
    environment => 1,
    raw_error   => 0,
    debug_template => $DebugTemplate,
    error_template => $ErrorTemplate,
    style       => $Style,
  );

=over 4

=item debug (or d)

If set true, debug screen appears; if false, error screen does.
Default value is 1.

=item engine (or e)

Sets the name of a view subclass. Default value is 'DefaultView',
which uses no template engines. 'HTML::Template' and 'TT' are also
available.

=item lines (or l)

Sets the number of lines shown before and after the traced line.
Default value is 3.

=item modules (or m / mod)

If set true, debug screen shows a list of included modules.
Default value is undef.

=item environment (or env)

If set true, debug screen shows a table of environmental variables.
Default value is undef.

=item raw_error (or raw)

If set true, debug screen shows a raw error (CGI::Carp::confessed) 
message.
Default value is undef.

=item debug_template (or dt)

=item error_template (or et)

=item style (or s)

Overload default templates and style if defined. But you may want 
to set these templates through correspondent methods.

=back

=head1 PACKAGE METHODS

=over 4

=item debug

=item show_modules

=item show_environment

=item show_raw_error

=item set_debug_template

=item set_error_template

=item set_style

Do the same as the correspondent options. e.g.

  CGI::Carp::DebugScreen->debug(1); # debug screen appears

=back

=head1 TODO

I'm going to implement some watchdog functions, and support 
encoding (though CGI::Carp qw/fatalsToBrowser/ sends no charset 
header). And some more tests. Any ideas?

=head1 SEE ALSO

CGI::Carp, CGI::Application::Plugin::DebugScreen

=head1 ACKNOWLEDGMENT

The concept, debug screen template and style are based on several
Japanese hackers' blog articles. You might not be able to read
Japanese pages but I thank:

=over 4

=item tokuhirom at L<http://tokuhirom.dnsalias.org/~tokuhirom/tokulog/>

L<Sledge::Plugin::DebugScreen|http://tokuhirom.dnsalias.org/~tokuhirom/tokulog/2181.html>

=item nipotan at L<http://blog.livedoor.jp/nipotan/>

L<patch|http://blog.livedoor.jp/nipotan/archives/50342811.html> and
L<2nd patch|http://blog.livedoor.jp/nipotan/archives/50342898.html>
for Sledge::Plugin::DebugScreen

=item nekokak at L<http://www.border.jp/nekokak/blog/>

L<CGI::Application::Plugin::DebugScreen|http://search.cpan.org/dist/CGI-Application-Plugin-DebugScreen/> articles
L<1|http://www.border.jp/nekokak/blog/archives/2005/12/cgiappdebugscre.html>,
L<2|http://www.border.jp/nekokak/blog/archives/2005/12/cgiappdebugscre_1.html>,
L<3|http://www.border.jp/nekokak/blog/archives/2005/12/cgiappdebugscre_2.html>,
L<4|http://www.border.jp/nekokak/blog/archives/2005/12/cgiappdebugscre_3.html>

=back

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kenichi Ishigaki

This library is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut
