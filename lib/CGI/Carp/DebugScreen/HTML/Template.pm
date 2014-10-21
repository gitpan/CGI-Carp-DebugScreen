package CGI::Carp::DebugScreen::HTML::Template;
{
  use strict;
  use warnings;
  use HTML::Template;

  our $VERSION = '0.02';

  my $DebugTemplate =<<'EOT';
<html>
<head>
<title>Debug Screen</title>
<TMPL_IF NAME="style">
<TMPL_VAR NAME="style">
</TMPL_IF>
</head>
<body>
<a name="top"></a>
<div id="page">
<h1><TMPL_VAR NAME="error_at" ESCAPE=HTML></h1>
<TMPL_IF NAME="show_raw_error">
<pre class="raw_error"><TMPL_VAR NAME="raw_error"></pre>
<TMPL_ELSE>
<div class="box">
<TMPL_VAR NAME="error_message">
</div>
</TMPL_IF>
<div class="navi">[<a href="#top">top</a>] [<a href="#traces">traces</a>]<TMPL_IF NAME="modules"> [<a href="#modules">modules</a>]</TMPL_IF><TMPL_IF NAME="environment"> [<a href="#environment">environment</a>]</TMPL_IF></div>
<div class="box">
<h2><a name="traces">Stack Traces</a></h2>
<ul id="traces">
<TMPL_LOOP NAME="traces">
<li><TMPL_VAR NAME="caller" ESCAPE=HTML> LINE : <TMPL_VAR NAME="line"></li>
<table class="code">
<TMPL_LOOP NAME="contents">
<TMPL_IF NAME="hit"><tr class="hit"><TMPL_ELSE><tr></TMPL_IF>
<td class="num"><TMPL_VAR NAME="no" ESCAPE=HTML>:</td><td><TMPL_VAR NAME="line" ESCAPE=HTML></td>
</tr>
</TMPL_LOOP>
</table>
</TMPL_LOOP>
</ul>
</div>
<TMPL_IF NAME="modules">
<div class="navi">[<a href="#top">top</a>] [<a href="#traces">traces</a>]<TMPL_IF NAME="modules"> [<a href="#modules">modules</a>]</TMPL_IF><TMPL_IF NAME="environment"> [<a href="#environment">environment</a>]</TMPL_IF></div>
<div class="box">
<h2><a name="modules">Included Modules</a></h2>
<ul id="modules">
<TMPL_LOOP NAME="modules">
<li><TMPL_VAR NAME="package" ESCAPE=HTML> (<TMPL_VAR NAME="file" ESCAPE=HTML>)</li>
</TMPL_LOOP>
</ul>
</div>
</TMPL_IF>
<TMPL_IF NAME="environment">
<div class="navi">[<a href="#top">top</a>] [<a href="#traces">traces</a>]<TMPL_IF NAME="modules"> [<a href="#modules">modules</a>]</TMPL_IF><TMPL_IF NAME="environment"> [<a href="#environment">environment</a>]</TMPL_IF></div>
<div class="box">
<h2><a name="environment">Environmental Variables</a></h2>
<table id="environment">
<TMPL_LOOP NAME="environment">
<tr>
<td><TMPL_VAR NAME="key" ESCAPE=HTML></td><td><div class="scrollable"><TMPL_VAR NAME="value" ESCAPE=HTML></div><//td>
</tr>
</TMPL_LOOP>
</table>
</div>
</TMPL_IF>
</div>
</body>
</html>
EOT

  my $ErrorTemplate =<<'EOT';
<html>
<head>
<title>An unexpected error has been detected</title>
<TMPL_IF NAME="style">
<TMPL_VAR NAME="style">
</TMPL_IF>
</head>
<body>
<div id="page">
<h1>An unexpected error has been detected</h1>
<p>Sorry for inconvenience.</p>
</div>
</body>
</html>
EOT

  sub show {
    my ($pkg, %options) = @_;

    $options{error_tmpl} ||= $ErrorTemplate;
    $options{debug_tmpl} ||= $DebugTemplate;

    my $tmpl = $options{debug} ? $options{debug_tmpl} : $options{error_tmpl};

    my $t = HTML::Template->new(
      scalarref => \$tmpl,
      die_on_bad_params => 0,
    );

    $t->param(%options);

    print $t->output;
  }
}

1;
__END__

=head1 NAME

CGI::Carp::DebugScreen::HTML::Template - CGI::Carp::DebugScreen View Class with HTML::Template

=head1 SYNOPSIS

  use CGI::Carp::DebugScreen (
    engine => 'HTML::Template', # CGI::Carp::DebugScreen::HTML::Template
                                # will be called internally
  );

=head1 DESCRIPTION

One of the ready-made view classes for CGI::Carp::DebugScreen.

=head1 SEE ALSO

CGI::Carp::DebugScreen, HTML::Template

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kenichi Ishigaki

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
