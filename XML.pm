# $Id: XML.pm,v 1.2 2000/11/28 15:36:22 matt Exp $

package Pod::XML;
use strict;
use vars qw(@ISA $VERSION %head2sect %xmlchars %HTML_Escapes);

use Pod::Parser;
@ISA = ('Pod::Parser');

$VERSION = '0.91';

%head2sect = (
    1 => "sect1",
    2 => "sect2",
    3 => "sect3",
    4 => "sect4",
);

%xmlchars = (
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
);

%HTML_Escapes = (
    'amp'       =>      '&',    #   ampersand
    'lt'        =>      '<',    #   left chevron, less-than
    'gt'        =>      '>',    #   right chevron, greater-than
    'quot'      =>      '"',    #   double quote

    "Aacute"    =>      "\xC1", #   capital A, acute accent
    "aacute"    =>      "\xE1", #   small a, acute accent
    "Acirc"     =>      "\xC2", #   capital A, circumflex accent
    "acirc"     =>      "\xE2", #   small a, circumflex accent
    "AElig"     =>      "\xC6", #   capital AE diphthong (ligature)
    "aelig"     =>      "\xE6", #   small ae diphthong (ligature)
    "Agrave"    =>      "\xC0", #   capital A, grave accent
    "agrave"    =>      "\xE0", #   small a, grave accent
    "Aring"     =>      "\xC5", #   capital A, ring
    "aring"     =>      "\xE5", #   small a, ring
    "Atilde"    =>      "\xC3", #   capital A, tilde
    "atilde"    =>      "\xE3", #   small a, tilde
    "Auml"      =>      "\xC4", #   capital A, dieresis or umlaut mark
    "auml"      =>      "\xE4", #   small a, dieresis or umlaut mark
    "Ccedil"    =>      "\xC7", #   capital C, cedilla
    "ccedil"    =>      "\xE7", #   small c, cedilla
    "Eacute"    =>      "\xC9", #   capital E, acute accent
    "eacute"    =>      "\xE9", #   small e, acute accent
    "Ecirc"     =>      "\xCA", #   capital E, circumflex accent
    "ecirc"     =>      "\xEA", #   small e, circumflex accent
    "Egrave"    =>      "\xC8", #   capital E, grave accent
    "egrave"    =>      "\xE8", #   small e, grave accent
    "ETH"       =>      "\xD0", #   capital Eth, Icelandic
    "eth"       =>      "\xF0", #   small eth, Icelandic
    "Euml"      =>      "\xCB", #   capital E, dieresis or umlaut mark
    "euml"      =>      "\xEB", #   small e, dieresis or umlaut mark
    "Iacute"    =>      "\xCD", #   capital I, acute accent
    "iacute"    =>      "\xED", #   small i, acute accent
    "Icirc"     =>      "\xCE", #   capital I, circumflex accent
    "icirc"     =>      "\xEE", #   small i, circumflex accent
    "Igrave"    =>      "\xCD", #   capital I, grave accent
    "igrave"    =>      "\xED", #   small i, grave accent
    "Iuml"      =>      "\xCF", #   capital I, dieresis or umlaut mark
    "iuml"      =>      "\xEF", #   small i, dieresis or umlaut mark
    "Ntilde"    =>      "\xD1",         #   capital N, tilde
    "ntilde"    =>      "\xF1",         #   small n, tilde
    "Oacute"    =>      "\xD3", #   capital O, acute accent
    "oacute"    =>      "\xF3", #   small o, acute accent
    "Ocirc"     =>      "\xD4", #   capital O, circumflex accent
    "ocirc"     =>      "\xF4", #   small o, circumflex accent
    "Ograve"    =>      "\xD2", #   capital O, grave accent
    "ograve"    =>      "\xF2", #   small o, grave accent
    "Oslash"    =>      "\xD8", #   capital O, slash
    "oslash"    =>      "\xF8", #   small o, slash
    "Otilde"    =>      "\xD5", #   capital O, tilde
    "otilde"    =>      "\xF5", #   small o, tilde
    "Ouml"      =>      "\xD6", #   capital O, dieresis or umlaut mark
    "ouml"      =>      "\xF6", #   small o, dieresis or umlaut mark
    "szlig"     =>      "\xDF",         #   small sharp s, German (sz ligature)
    "THORN"     =>      "\xDE", #   capital THORN, Icelandic
    "thorn"     =>      "\xFE", #   small thorn, Icelandic
    "Uacute"    =>      "\xDA", #   capital U, acute accent
    "uacute"    =>      "\xFA", #   small u, acute accent
    "Ucirc"     =>      "\xDB", #   capital U, circumflex accent
    "ucirc"     =>      "\xFB", #   small u, circumflex accent
    "Ugrave"    =>      "\xD9", #   capital U, grave accent
    "ugrave"    =>      "\xF9", #   small u, grave accent
    "Uuml"      =>      "\xDC", #   capital U, dieresis or umlaut mark
    "uuml"      =>      "\xFC", #   small u, dieresis or umlaut mark
    "Yacute"    =>      "\xDD", #   capital Y, acute accent
    "yacute"    =>      "\xFD", #   small y, acute accent
    "yuml"      =>      "\xFF", #   small y, dieresis or umlaut mark

    "lchevron"  =>      "\xAB", #   left chevron (double less than)
    "rchevron"  =>      "\xBB", #   right chevron (double greater than)
);

sub xmlescape {
    my $text = shift;
    $text =~ s/([&<>])/$xmlchars{$1}/eg;
    return $text;
}

sub begin_pod {
    my ($parser) = @_;
    my $fh = $parser->output_handle();

    $parser->{headlevel} = 0;
    $parser->{seentitle} = 0;
    $parser->{closeitem} = 0;
    $parser->{waitingfortitle} = 0;

    print $fh <<EOT;
<?xml version='1.0' encoding='iso-8859-1'?>
<pod xmlns="http://axkit.org/ns/2000/pod2xml">
EOT
    }

    sub end_pod {
    my ($parser) = @_;
    my $fh = $parser->output_handle();

    while ($parser->{headlevel}) {
        print $fh "</$head2sect{$parser->{headlevel}}>\n";
        $parser->{headlevel}--;
    }

    print $fh <<EOT;
</pod>
EOT
}

sub command {
    my ($parser, $command, $paragraph) = @_;
    my $fh = $parser->output_handle();

    $paragraph =~ s/\s*$//;
    $paragraph =~ s/^\s*//;

    if ($command =~ /^head(\d+)/) {
        my $headlevel = $1;
        if (!$parser->{seentitle}) {
            $parser->{seentitle}++;
            print $fh "<head>\n\t<title>";
            if ($paragraph eq 'NAME') {
                $parser->{waitingfortitle} = 1;
                return;
            }
            print $fh xmlescape($paragraph), "</title>\n</head>\n";
            return;
        }

        if ($headlevel <= $parser->{headlevel}) {
            while ($headlevel <= $parser->{headlevel}) {
                print $fh "</$head2sect{$parser->{headlevel}}>\n";
                $parser->{headlevel}--;
            }
        }

	while ($headlevel > ($parser->{headlevel} + 1)) {
		$parser->{headlevel}++;
		print $fh "<$head2sect{$parser->{headlevel}}>\n";
	}

        $parser->{headlevel} = $headlevel;
        print $fh "<$head2sect{$headlevel}>\n";
        print $fh "<title>", xmlescape($paragraph), "</title>\n";
    }
    elsif ($command eq "over") {
        if ($parser->{closeitem}) {
            print $fh "</item>\n";
            $parser->{closeitem} = 0;
        }
        print $fh "<list>\n";
    }
    elsif ($command eq "back") {
        if ($parser->{closeitem}) {
            print $fh "</item>\n";
            $parser->{closeitem} = 0;
        }
        print $fh "</list>\n";
    }
    elsif ($command eq "item") {
        if ($parser->{closeitem}) {
            print $fh "</item>\n";
            $parser->{closeitem} = 0;
        }
        print $fh "<item>";
        if ($paragraph ne '*') {
            $paragraph =~ s/^\*\s+//;
            print $fh "<itemtext>", xmlescape($paragraph), "</itemtext>\n";
        }
        $parser->{closeitem}++;
    }
}

sub verbatim {
    my ($parser, $paragraph) = @_;
    my $fh = $parser->output_handle();
    $paragraph =~ s/^\s*//;
    $paragraph =~ s/\s*$//;
    return unless length $paragraph;
    $paragraph =~ s/\]\]>/\]\]>\]\]&gt;<!\[CDATA\[/g;
    print $fh "<verbatim><![CDATA[\n", $paragraph, "\n]]></verbatim>\n";
}

sub textblock {
    my ($parser, $paragraph, $line_num) = @_;
    my $fh = $parser->output_handle();

    $paragraph =~ s/^\s*//;
    $paragraph =~ s/\s*$//;
    
    my $text = $parser->interpolate($paragraph);
    $text = xmlescape($text);
    $text =~ s/\{(\/?)tag:(\w+)\}/<$1$2>/g;
    $text =~ s/\{code:(\d+)\}/&#$1/g;
    
    if ($parser->{waitingfortitle}) {
        $parser->{waitingfortitle} = 0;
        print $fh $text, "</title>\n</head>\n";
    }
    else {
        print $fh "<para>\n";
        print $fh $text;
        print $fh "\n</para>\n";
    }
}

sub interior_sequence {
    my ($parser, $seq_command, $seq_argument) = @_;
    my $fh = $parser->output_handle();

    if ($seq_command eq 'C') {
        return "\{tag:code\}$seq_argument\{\/tag:code\}";
    }
    elsif ($seq_command eq 'I') {
        return "\{tag:emphasis\}$seq_argument\{\/tag:emphasis\}";
    }
    elsif ($seq_command eq 'B') {
        return "\{tag:strong\}$seq_argument\{\/tag:strong\}";
    }
    elsif ($seq_command eq 'S') {
        $seq_argument =~ s/ /\{char:160\}/g;
        return $seq_argument;
    }
    elsif ($seq_command eq 'F') {
        return "\{tag:filename\}$seq_argument\{\/tag:filename\}";
    }
    elsif ($seq_command eq 'X') {
        return "\{tag:index\}$seq_argument\{\/tag:index\}";
    }
    elsif ($seq_command eq 'L') {
        # parse L<>, can be any of:
        #  L<name> or L<sect> (other page or section in this page)
        #  L<name/ident> (item in a other page)
        #  L<name/"sect"> (section in other page)
        #  L<"sect"> (same as L<sect>)
        #  L</"sect"> (same as L<sect>)
        # plus any of the above can be prefixed with text| to use
        # that text as the link text.
        
       # THE FOLLOWING IS THE CODE FROM Pod::Text.
       # I'm keeping it here for the regexps so that I know I'm at
       # least parsing this stuff right.
       
       # Can you say "ugh", ladies and gents?
       
# 	# LREF: a la HREF L<show this text|man/section>
# 	s:L<([^|>]+)\|[^>]+>:$1:g;
# 
# 	# LREF: a manpage(3f)
# 	s:L<([a-zA-Z][^\s\/]+)(\([^\)]+\))?>:the $1$2 manpage:g;
# 	# LREF: an =item on another manpage
# 	s{
# 	    L<
# 		([^/]+)
# 		/
# 		(
# 		    [:\w]+
# 		    (\(\))?
# 		)
# 	    >
# 	} {the "$2" entry in the $1 manpage}gx;
# 
# 	# LREF: an =item on this manpage
# 	s{
# 	   ((?:
# 	    L<
# 		/
# 		(
# 		    [:\w]+
# 		    (\(\))?
# 		)
# 	    >
# 	    (,?\s+(and\s+)?)?
# 	  )+)
# 	} { internal_lrefs($1) }gex;
# 
# 	# LREF: a =head2 (head1?), maybe on a manpage, maybe right here
# 	# the "func" can disambiguate
# 	s{
# 	    L<
# 		(?:
# 		    ([a-zA-Z]\S+?) / 
# 		)?
# 		"?(.*?)"?
# 	    >
# 	}{
# 	    do {
# 		$1 	# if no $1, assume it means on this page.
# 		    ?  "the section on \"$2\" in the $1 manpage"
# 		    :  "the section on \"$2\""
# 	    }
# 	}sgex;
        
        my ($text, $link, $file);
        if ($seq_argument =~ /^([^|]+)\|(.*)$/) {
            $text = $1;
            $seq_argument = $2;
        }
        
        return "\{tag:link\}$seq_argument\{\/tag:link\}";
    }
    elsif ($seq_command eq 'E') {
        return $HTML_Escapes{$seq_argument};
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

Matt Sergeant, matt@sergeant.org

=head1 SEE ALSO

Pod::Parser

=head1 BUGS

There is no xml2pod.

POD LE<lt>> sections are barely implemented. Expect to see the E<lt>link>
tag contents change as I get more of a hang of how to parse it.

=head1 LICENSE

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut
