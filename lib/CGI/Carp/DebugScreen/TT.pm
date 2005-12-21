package CGI::Carp::DebugScreen::TT;
{
  use strict;
  use warnings;
  use Template;

  our $VERSION = '0.01';

  my $DebugTemplate =<<'EOT';
<html>
<head>
<title>Debug Screen</title>
[% IF style %]
[% style %]
[% END %]
</head>
<body>
<a name="top"></a>
<div id="page">
<h1>[% error_at | html %]</h1>
[% IF show_raw_error %]
<pre class="raw_error">[% raw_error %]</pre>
[% ELSE %]
<div class="box">
[% error_message %]
</div>
[% END %]
<div class="navi">
[<a href="#top">top</a>]
[<a href="#traces">traces</a>]
[% IF modules %]
[<a href="#modules">modules</a>]
[% END %]
[% IF environment %]
[<a href="#environment">environment</a>]
[% END %]
</div>
<div class="box">
<h2><a name="traces">Stack Traces</a></h2>
<ul id="traces">
[% FOREACH trace = traces %]
<li>[% trace.caller | html %] LINE : [% trace.line | html %]</li>
<table class="code">
[% FOREACH content = trace.contents %]
[% IF content.hit %]<tr class="hit">[% ELSE %]<tr>[% END %]
<td class="num">[% content.no | html %]:</td><td>[% content.line | html %]</td>
</tr>
[% END %]
</table>
[% END %]
</ul>
</div>
[% IF modules %]
<div class="navi">
[<a href="#top">top</a>]
[<a href="#traces">traces</a>]
[% IF modules %]
[<a href="#modules">modules</a>]
[% END %]
[% IF environment %]
[<a href="#environment">environment</a>]
[% END %]
</div>
<div class="box">
<h2><a name="modules">Included Modules</a></h2>
<ul id="modules">
[% FOREACH module = modules %]
<li>[% module.package | html %] ([% module.file | html %])</li>
[% END %]
</ul>
</div>
[% END %]
[% IF environment %]
<div class="navi">
[<a href="#top">top</a>]
[<a href="#traces">traces</a>]
[% IF modules %]
[<a href="#modules">modules</a>]
[% END %]
[% IF environment %]
[<a href="#environment">environment</a>]
[% END %]
</div>
<div class="box">
<h2><a name="environment">Environmental Variables</a></h2>
<table id="environment">
[% FOREACH env = environment %]
<tr>
<td>[% env.key | html %]</td><td><div class="scrollable">[% env.value | html %]</div><//td>
</tr>
[% END %]
</table>
</div>
[% END %]
</div>
</body>
</html>
EOT

  my $ErrorTemplate =<<'EOT';
<html>
<head>
<title>An unexpected error has been detected</title>
[% IF style %]
[% style %]
[% END %]
</head>
<body>
<div id="page">
<h1>An unexpected error has been detected</h1>
<p>Sorry for inconvenience.</p>
</div>
</body>
</html>
EOT

  sub _escape {
    my $str = shift;

    $str =~ s/&/&amp;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/</&gt;/g;
    $str =~ s/"/&quot;/g;

    $str;
  }

  sub show {
    my ($pkg, %options) = @_;

    $options{error_tmpl} ||= $ErrorTemplate;
    $options{debug_tmpl} ||= $DebugTemplate;

    my $tmpl = $options{debug} ? $options{debug_tmpl} : $options{error_tmpl};

    my $t = Template->new(
      FILTERS => {
        html => sub { _escape(@_) }
      } ,
    );

    $t->process(\$tmpl, \%options) || print $t->error();
  }
}

1;
__END__

=head1 NAME

CGI::Carp::DebugScreen::TT - CGI::Carp::DebugScreen View Class with Template Toolkit

=head1 SYNOPSIS

  use CGI::Carp::DebugScreen (
    engine => 'TT',  # CGI::Carp::DebugScreen::TT will be called internally
  );

=head1 DESCRIPTION

One of the ready-made view classes for CGI::Carp::DebugScreen.

=head1 SEE ALSO

CGI::Carp::DebugScreen, Template

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kenichi Ishigaki

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
