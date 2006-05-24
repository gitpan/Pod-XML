package Pod::XML;

# $Id: XML.pm 13 2006-05-24 19:19:54Z matt $

use strict;
use warnings;
use vars qw(@ISA $VERSION %head2sect %HTML_Escapes);

use Pod::Parser;

@ISA = ( 'Pod::Parser' );

$VERSION = '0.95';

# I'm not sure why Matt Sergeant did this in this way but I'll leave it for
# the time being
%head2sect = (
  1 => "sect1",
  2 => "sect2",
  3 => "sect3",
  4 => "sect4",
);

# a hash array of HTML escape codes
# NOTE that ampersand is not included here as when escaping we MUST do
# ampersand first!
%HTML_Escapes = (
  # '&'     =>  'amp',        #   ampersand
  '<'     =>  'lt',         #   left chevron, less-than
  '>'     =>  'gt',         #   right chevron, greater-than
  '"'     =>  'quot',       #   double quote
  "\xC1"  =>  "Aacute",     #   capital A, acute accent
  "\xE1"  =>  "aacute",     #   small a, acute accent
  "\xC2"  =>  "Acirc",      #   capital A, circumflex accent
  "\xE2"  =>  "acirc",      #   small a, circumflex accent
  "\xC6"  =>  "AElig",      #   capital AE diphthong (ligature)
  "\xE6"  =>  "aelig",      #   small ae diphthong (ligature)
  "\xC0"  =>  "Agrave",     #   capital A, grave accent
  "\xE0"  =>  "agrave",     #   small a, grave accent
  "\xC5"  =>  "Aring",      #   capital A, ring
  "\xE5"  =>  "aring",      #   small a, ring
  "\xC3"  =>  "Atilde",     #   capital A, tilde
  "\xE3"  =>  "atilde",     #   small a, tilde
  "\xC4"  =>  "Auml",       #   capital A, dieresis or umlaut mark
  "\xE4"  =>  "auml",       #   small a, dieresis or umlaut mark
  "\xC7"  =>  "Ccedil",     #   capital C, cedilla
  "\xE7"  =>  "ccedil",     #   small c, cedilla
  "\xC9"  =>  "Eacute",     #   capital E, acute accent
  "\xE9"  =>  "eacute",     #   small e, acute accent
  "\xCA"  =>  "Ecirc",      #   capital E, circumflex accent
  "\xEA"  =>  "ecirc",      #   small e, circumflex accent
  "\xC8"  =>  "Egrave",     #   capital E, grave accent
  "\xE8"  =>  "egrave",     #   small e, grave accent
  "\xD0"  =>  "ETH",        #   capital Eth, Icelandic
  "\xF0"  =>  "eth",        #   small eth, Icelandic
  "\xCB"  =>  "Euml",       #   capital E, dieresis or umlaut mark
  "\xEB"  =>  "euml",       #   small e, dieresis or umlaut mark
  "\xCD"  =>  "Iacute",     #   capital I, acute accent
  "\xED"  =>  "iacute",     #   small i, acute accent
  "\xCE"  =>  "Icirc",      #   capital I, circumflex accent
  "\xEE"  =>  "icirc",      #   small i, circumflex accent
  "\xCD"  =>  "Igrave",     #   capital I, grave accent
  "\xED"  =>  "igrave",     #   small i, grave accent
  "\xCF"  =>  "Iuml",       #   capital I, dieresis or umlaut mark
  "\xEF"  =>  "iuml",       #   small i, dieresis or umlaut mark
  "\xD1"  =>  "Ntilde",     #   capital N, tilde
  "\xF1"  =>  "ntilde",     #   small n, tilde
  "\xD3"  =>  "Oacute",     #   capital O, acute accent
  "\xF3"  =>  "oacute",     #   small o, acute accent
  "\xD4"  =>  "Ocirc",      #   capital O, circumflex accent
  "\xF4"  =>  "ocirc",      #   small o, circumflex accent
  "\xD2"  =>  "Ograve",     #   capital O, grave accent
  "\xF2"  =>  "ograve",     #   small o, grave accent
  "\xD8"  =>  "Oslash",     #   capital O, slash
  "\xF8"  =>  "oslash",     #   small o, slash
  "\xD5"  =>  "Otilde",     #   capital O, tilde
  "\xF5"  =>  "otilde",     #   small o, tilde
  "\xD6"  =>  "Ouml",       #   capital O, dieresis or umlaut mark
  "\xF6"  =>  "ouml",       #   small o, dieresis or umlaut mark
  "\xDF"  =>  "szlig",      #   small sharp s, German (sz ligature)
  "\xDE"  =>  "THORN",      #   capital THORN, Icelandic
  "\xFE"  =>  "thorn",      #   small thorn, Icelandic
  "\xDA"  =>  "Uacute",     #   capital U, acute accent
  "\xFA"  =>  "uacute",     #   small u, acute accent
  "\xDB"  =>  "Ucirc",      #   capital U, circumflex accent
  "\xFB"  =>  "ucirc",      #   small u, circumflex accent
  "\xD9"  =>  "Ugrave",     #   capital U, grave accent
  "\xF9"  =>  "ugrave",     #   small u, grave accent
  "\xDC"  =>  "Uuml",       #   capital U, dieresis or umlaut mark
  "\xFC"  =>  "uuml",       #   small u, dieresis or umlaut mark
  "\xDD"  =>  "Yacute",     #   capital Y, acute accent
  "\xFD"  =>  "yacute",     #   small y, acute accent
  "\xFF"  =>  "yuml",       #   small y, dieresis or umlaut mark
  "\xAB"  =>  "lchevron",   #   left chevron (double less than)
  "\xBB"  =>  "rchevron",   #   right chevron (double greater than)
);

sub html_escape
{
  my $text = shift || '';

  # ampersand MUST be done first!
  $text =~ s/&/\&amp;/g;

  # now go through the full list
  while ( my ( $raw, $escaped ) = each %HTML_Escapes )
  {
    $text =~ s/$raw/\&$escaped;/g;
  }

  $text =~ s/{tag:escape ref='([^']*)'}/\&$1;/g;

  return $text;
}

sub xml_output
{
  my ( $parser, @strings ) = @_;
  
  if ( $parser->{send_to_string} )
  {
    $parser->{xml_string} .= join('', @strings);
  }
  else
  {
    my $fh = $parser->output_handle ();

    print $fh @strings;
  }
}

sub begin_pod
{
  my ( $parser ) = @_;

  $parser->{headlevel} = 0;
  $parser->{seentitle} = 0;
  $parser->{closeitem} = 0;
  $parser->{waitingfortitle} = 0;

  $parser->xml_output (<<EOT);
<?xml version='1.0' encoding='iso-8859-1'?>
<pod xmlns="http://axkit.org/ns/2000/pod2xml">
EOT
}

sub end_pod
{
  my ( $parser ) = @_;
  my $fh = $parser->output_handle ();

  while ( $parser->{headlevel} )
  {
    $parser->xml_output ( "</$head2sect{$parser->{headlevel}}>\n" );
    $parser->{headlevel}--;
  }

  $parser->xml_output(<<EOT);
</pod>
EOT
}

sub command
{
  my ( $parser, $command, $paragraph ) = @_;
  my $fh = $parser->output_handle ();

  $paragraph =~ s/\s*$//;
  $paragraph =~ s/^\s*//;

  $paragraph = $parser->interpolate ( $paragraph );
  $paragraph = uri_find ( $paragraph );
  $paragraph = html_escape ( $paragraph );
  $paragraph =~ s/\{(\/?)tag:(.*?)\}/<$1$2>/g;
  $paragraph =~ s/\{code:(\d+)\}/&#$1/g;

  if ( $command =~ /^head(\d+)/ )
  {
    my $headlevel = $1;
    
    if ( ! $parser->{title} )
    {
      $parser->xml_output ( "<head>\n\t<title>" );

      return if $paragraph eq 'NAME';
      
      $parser->{title} = $paragraph;
      $parser->xml_output ( $paragraph, "</title>\n</head>\n" );

      return;
    }

    if ( $headlevel <= $parser->{headlevel} )
    {
      while ( $headlevel <= $parser->{headlevel} )
      {
        $parser->xml_output ( "</$head2sect{$parser->{headlevel}}>\n" );
        $parser->{headlevel}--;
      }
    }

    while ( $headlevel > ( $parser->{headlevel} + 1 ) )
    {
      $parser->{headlevel}++;
      $parser->xml_output ( "<$head2sect{$parser->{headlevel}}>\n" );
    }

    $parser->{headlevel} = $headlevel;
    $parser->xml_output ( "<$head2sect{$headlevel}>\n",
        "<title>", $paragraph, "</title>\n" );
  }
  elsif ( $command eq "over" )
  {
    if ( $parser->{closeitem} )
    {
      $parser->xml_output ( "</item>\n" );
      $parser->{closeitem} = 0;
    }

    $parser->xml_output ( "<list>\n" );
  }
  elsif ( $command eq "back" )
  {
    if ( $parser->{closeitem} )
    {
      $parser->xml_output ( "</item>\n" );
      $parser->{closeitem} = 0;
    }

    $parser->xml_output ( "</list>\n" );
  }
  elsif ( $command eq "item" )
  {
    if ( $parser->{closeitem} )
    {
      $parser->xml_output ( "</item>\n" );
      $parser->{closeitem} = 0;
    }

    $parser->xml_output ( "<item>" );

    if ( $paragraph ne '*' )
    {
      $paragraph =~ s/^\*\s+//;
      $parser->xml_output ( "<itemtext>", $paragraph, "</itemtext>\n" );
    }

    $parser->{closeitem}++;
  }
}

sub verbatim
{
  my ( $parser, $paragraph ) = @_;

  my $fh = $parser->output_handle ();

  if ( $paragraph =~ s/^(\s*)// )
  {
    my $indent = $1;

    $paragraph =~ s/\s*$//;

    return unless length $paragraph;
  
    $paragraph =~ s/^$indent//mg; # un-indent
    $paragraph =~ s/\]\]>/\]\]>\]\]&gt;<!\[CDATA\[/g;
    $parser->xml_output ( "<verbatim><![CDATA[\n", $paragraph, "\n]]></verbatim>\n" );
  }
}

sub textblock
{
  my ( $parser, $paragraph, $line_num ) = @_;
  my $fh = $parser->output_handle ();

  $paragraph =~ s/^\s*//;
  $paragraph =~ s/\s*$//;

  my $text = $parser->interpolate ( $paragraph );

  $text = uri_find ( $text );
  $text = html_escape ( $text );
  $text =~ s/\{(\/?)tag:(.*?)\}/<$1$2>/g;
  $text =~ s/\{code:(\d+)\}/&#$1/g;

  if ( ! $parser->{title} )
  {
    $parser->{title} = $text;
    $parser->xml_output ( $text, "</title>\n</head>\n" );
  }
  else
  {
    if ( $parser->{headlevel} == 0 )
    {
      $parser->xml_output ( "<sect1>\n<title>", $parser->{title},
        "</title>\n" );
      $parser->{headlevel}++;
    }

    $parser->xml_output ( "<para>\n", $text, "\n</para>\n" );
  }
}

sub uri_find
{
  my $text = shift || '';

  # Code from the Perl Cookbook
  my $urls = '(https|http|telnet|gopher|file|wais|ftp|mailto)';
  my $ltrs = '\w';
  my $gunk = '/#~:.?+=&%@!\-';
  my $punc = '.:?\-!,';
  my $any = "${ltrs}${gunk}${punc}";

  my $new;

  while (
      $text =~ m{
        \G          # anchor to last match place
        (.*?)       # catch stuff before match in $1
        \b          # start at word boundary
        (           # BEGIN $2
          $urls :   # http:
          (?![:/])  # negative lookahead for : or /
          [$any]+?  # followed by 1 or more allowed charact
        )           # END $2
        (?=         # look ahead after $2
          [$punc]*  #  for 0 or more punctuation characters
          (
            [^$any] #  followed by a non-URL character
            | \Z    #  or alternatively the end of the html
          )
        )           # end of look ahead
        }igcsox )
  {
    my ( $pre, $url ) = ( $1, $2 );
    $new .= $pre;
    $new .= "\{tag:xlink uri='$url'\}$url\{/tag:xlink\}";
  }

  $text =~ /\G(.*)/gcs;
  $new .= $1 if defined $1;

  return $new;
}

sub interior_sequence
{
  my ( $parser, $seq_command, $seq_argument ) = @_;
  my $fh = $parser->output_handle ();

  if ( $seq_command eq 'C' )
  {
    return "\{tag:code\}$seq_argument\{\/tag:code\}";
  }
  elsif ( $seq_command eq 'I' )
  {
    return "\{tag:emphasis\}$seq_argument\{\/tag:emphasis\}";
  }
  elsif ( $seq_command eq 'B' )
  {
    return "\{tag:strong\}$seq_argument\{\/tag:strong\}";
  }
  elsif ( $seq_command eq 'S' )
  {
    $seq_argument =~ s/ /\{char:160\}/g;

    return $seq_argument;
  }
  elsif ( $seq_command eq 'F' )
  {
    return "\{tag:filename\}$seq_argument\{\/tag:filename\}";
  }
  elsif ( $seq_command eq 'X' )
  {
    return "\{tag:index\}$seq_argument\{\/tag:index\}";
  }
  elsif ( $seq_command eq 'L' )
  {
    # parse L<>, can be any of:
    #  L<name> or L<sect> (other page or section in this page)
    #  L<name/ident> (item in a other page)
    #  L<name/"sect"> (section in other page)
    #  L<"sect"> (same as L<sect>)
    #  L</"sect"> (same as L<sect>)
    #  L</sect> (same as L<sect>)
    # plus any of the above can be prefixed with text| to use
    # that text as the link text.

    # Additionally, there can also be;
    #  L<scheme:...>
    # which SHOULD NOT be prepended label|
    my $text = $seq_argument;

    if ( $seq_argument =~ /^([^|]+)\|(.*)$/ )
    {
      $text = $1;
      $seq_argument = $2;
    }

    if ( $seq_argument =~ /^[a-z]+:\//i )
    {
      $text ||= $seq_argument;
    }
    elsif ( $seq_argument =~ /^(.*?)\/(.*)$/ )
    {
      # name/ident or name/"sect"
      my $ident_or_sect = $2;
      $seq_argument = $1;

      if ( $ident_or_sect =~ /^\"(.*)\"$/ )
      {
        my $sect = $1;
        $sect = substr ( $sect, 0, 30 );
        $sect =~ s/\s/_/g;
        $seq_argument .= '#' . $sect;
      }
      else 
      {
        $seq_argument .= '#' . $ident_or_sect;
      }
    }
    elsif ( $seq_argument =~ /^\\?\"(.*)\"$/ )
    {
      my $sect = $1;
      $sect = substr ( $sect, 0, 30 );
      $sect =~ s/\s/_/g;
      $seq_argument = '#' . $sect;
    }

    return "\{tag:link xref='$seq_argument'\}$text\{\/tag:link\}";
  }
  elsif ( $seq_command eq 'E' )
  {
    # E<> codes can be numerical!
    if ( $seq_argument =~ m/^0x([0-9A-Fa-f]{2,4})$/ ||
         $seq_argument =~ m/^0[0-7]*$/ ||
         $seq_argument =~ m/^[0-9]*$/ )
    {
      # convert hex and octal values to decimal
      $seq_argument = oct ( $seq_argument ) if $seq_argument =~ /^0/;
      $seq_argument = chr ( $seq_argument );
    }
    else
    {
      # probably a HTML escape code
      $seq_argument = "{tag:escape ref='$seq_argument'}";
    }

    return $seq_argument;
  }
}

1;

__END__

=head1 NAME

Pod::XML - Module to convert POD to XML

=head1 SYNOPSIS

  use Pod::XML;
  my $parser = Pod::XML->new();
  $parser->parse_from_file("foo.pod");

=head1 DESCRIPTION

This module uses Pod::Parser to parse POD and generates XML from the
resulting parse stream. It uses its own format, described below.

=head1 XML FORMAT

The XML format is not a standardised format - if you wish to generate
some standard XML format such as docbook, please use a tool such as XSLT
to convert between this and that format.

The format uses the namespace "http://axkit.org/ns/2000/pod2xml". Do not
try and request this URI - it is virtual. You will get a 404.

The best way to describe the format is to show you:

  <pod xmlns="http://axkit.org/ns/2000/pod2xml">
    <head>
      <title>The first =head1 goes in here</title>
    </head>
    <sect1>
    <title>Subsequent =head1's create a sect1</title>
      <para>
      Ordinary paragraphs of text create a para tag.
      </para>
      <verbatim><![CDATA[
      Indented verbatim sections go in verbatim tags using a CDATA
      section rather than XML escaping.
      ]]></verbatim>
      <sect2>
      <title>=head2's go in sect2</title>
        <para>
        Up to =head4 is supported (despite not really being 
        supported by pod), producing sect3 and 
        sect4 respectively for =head3 and =head4.
        </para>
        <para>
        Bold text goes in a <strong>strong</strong> tag.
        </para>
        <para>
        Italic text goes in a <emphasis>emphasis</emphasis> tag.
        </para>
        <para>
        Code goes in a <code>code</code> tag.
        </para>
        <para>
        Lists (=over, =item, =back) go in list/item/itemtext 
        tags. The itemtext element is only present if the 
        =item text is <strong>not</strong> the "*" character.
        </para>
      </sect2>
    </sect1>
  </pod>

If the first =head1 is "NAME" (like standard perl modules are supposed
to be) it takes the next paragraph as the document title. Other standard
head elements of POD are left unchanged (particularly, the SYNOPSIS and
DESCRIPTION elements of standard POD).

Pod::XML tries to be careful about nesting sects based on the head
level in the original POD. Let me know if this doesn't work for you.

=head1 AUTHOR

Original version by Matt Sergeant, matt@sergeant.org

Version 0.95+ by Matt Wilson E<lt>matt@mattsscripts.co.ukE<gt>

=head1 MAINTAINER

Matt Wilson E<lt>matt@mattsscripts.co.ukE<gt>

=head1 SEE ALSO

L<Pod::Parser>

=head1 LICENSE

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut
