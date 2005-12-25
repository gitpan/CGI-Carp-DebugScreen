package CGI::Carp::DebugScreen::DefaultView;
{
  use strict;
  use warnings;

  our $VERSION = '0.02';

  sub show {
    my ($pkg, %options) = @_;

    delete $options{debug_tmpl};
    delete $options{error_tmpl};

    $options{debug} ? $pkg->_debug(%options) : $pkg->_error(%options);
  }

  sub _escape {
    my $str = shift;

    $str =~ s/&/&amp;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/"/&quot;/g;

    $str;
  }

  sub _navi {
    my %options = @_;

    print <<"EOT";
<div class="navi">
[<a href="#top">top</a>]
[<a href="#traces">traces</a>]
EOT
    if ($options{modules}) {
      print <<"EOT";
[<a href="#modules">modules</a>]
EOT
    }
    if ($options{environment}) {
      print <<"EOT";
[<a href="#environment">environment</a>]
EOT
    }
    print <<"EOT";
</div>
EOT
}

  sub _debug {
    my ($pkg, %options) = @_;

    my $error_at = _escape($options{error_at});

    print <<"EOT";
<html>
<head>
<title>Debug Screen</title>
$options{style}
</head>
<body>
<div id="page">
<a name="top"></a>
<h1>$error_at</h1>
EOT

    if ($options{show_raw_error}) {
      print <<"EOT";
<pre class="raw_error">$options{raw_error}</pre>
EOT
    }
    else {
      print <<"EOT";
<div class="box">
$options{error_message}
</div>
EOT
    }

    _navi(%options);

    print <<"EOT";
<div class="box">
<h2><a name="traces">Stack Traces</a></h2>
<ul id="traces">
EOT

    foreach my $trace (@{ $options{traces} }) {
      my $caller = _escape($trace->{caller});
      my $line   = _escape($trace->{line});
      print <<"EOT";
<li>$caller LINE : $line</li>
<table class="code">
EOT

      foreach my $line (@{ $trace->{contents} }) {
        if ($line->{hit}) {
          print <<"EOT";
<tr class="hit">
EOT
        }
        else {
          print <<"EOT";
<tr>
EOT
        }
        my $line_no   = _escape($line->{no});
        my $line_body = _escape($line->{line});
        print <<"EOT";
<td class="num">$line_no:</td><td>$line_body</td>
</tr>
EOT
      }
      print <<"EOT";
</table>
EOT
    }

    print <<"EOT";
</ul>
</div>
EOT

    if ($options{modules}) {
      _navi(%options);

      print <<"EOT";
<div class="box">
<h2><a name="modules">Included Modules</a></h2>
<ul id="modules">
EOT

      foreach my $module (@{ $options{modules} }) {
        my $package = _escape($module->{package});
        my $file    = _escape($module->{file});

        print <<"EOT";
<li>$package ($file)</li>
EOT
      }
      print <<"EOT";
</ul>
</div>
EOT
    }

    if ($options{environment}) {
      _navi(%options);

      print <<"EOT";
<div class="box">
<h2><a name="environment">Environmental Variables</a></h2>
<table id="environment">
EOT

      foreach my $env (@{ $options{environment} }) {
        my $key   = _escape($env->{key});
        my $value = _escape($env->{value});
        print <<"EOT";
<tr>
<td>$key</td><td><div class="scrollable">$value</div><//td>
</tr>
EOT
      }
      print <<"EOT";
</table>
</div>
EOT
    }

    print <<"EOT";
</div>
</body>
</html>
EOT
  }

  sub _error {
    my ($pkg, %options) = @_;

    my %escaped = map {
      ( $_, _escape($options{$_}) )
    } keys %options;

    print <<"EOT";
<html>
<head>
<title>An unexpected error has been detected</title>
$options{style}
</head>
<body>
<div id="page">
<h1>An unexpected error has been detected</h1>
<p>Sorry for inconvenience.</p>
</div>
</body>
</html>
EOT
  }

}

1;
__END__


=head1 NAME

CGI::Carp::DebugScreen::DefaultView - CGI::Carp::DebugScreen View Class without template engines

=head1 SYNOPSIS

  use CGI::Carp::DebugScreen (
    engine => 'DefaultView',  # CGI::Carp::DebugScreen::DefaultView
                              # will be called internally; you can
                              # omit this.
  );

=head1 DESCRIPTION

One of the ready-made view classes for CGI::Carp::DebugScreen.

This is default.

=head1 SEE ALSO

CGI::Carp::DebugScreen

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Kenichi Ishigaki

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
