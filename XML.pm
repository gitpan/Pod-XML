# $Id: XML.pm,v 1.1.1.1 2000/11/27 11:38:20 matt Exp $

package Pod::XML;
use strict;
use vars qw(@ISA $VERSION %head2sect %xmlchars);

use Pod::Parser;
@ISA = ('Pod::Parser');

$VERSION = '0.90';

%head2sect = (
    1 => "section",
    2 => "subsection",
    3 => "subsubsection",
    4 => "subsubsubsection",
);

%xmlchars = (
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
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
<?xml version='1.0'?>
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

        $parser->{headlevel} = $headlevel;
        print $fh "<$head2sect{$headlevel}>\n";
        print $fh "<title>", xmlescape($paragraph), "</title>\n";
    }
    elsif ($command eq "over") {
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
    print $fh "<verbatim>\n", xmlescape($paragraph), "\n</verbatim>\n";
}

sub textblock {
    my ($parser, $paragraph, $line_num) = @_;
    my $fh = $parser->output_handle();

    $paragraph =~ s/^\s*//;
    $paragraph =~ s/\s*$//;
    
    my $text = $parser->interpolate($paragraph);
    $text = xmlescape($text);
    $text =~ s/\{(\/?)tag:(\w+)\}/<$1$2>/g;
    
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
    elsif ($seq_command eq 'L') {
        return "\{tag:link\}$seq_argument\{\/tag:link\}";
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
    <section>
    <title>Subsequent =head1's create a section</title>
      <para>
      Ordinary paragraphs of text create a para tag.
      </para>
      <verbatim>
      Indented verbatim sections go in verbatim tags.
      </verbatim>
      <subsection>
      <title>=head2's go in subsections</title>
        <para>
        Up to =head4 is supported (despite not really being 
        supported by pod), producing subsubsection and 
        subsubsubsection respectively for =head3 and =head4.
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
      </subsection>
    </section>
  </pod>

If the first =head1 is "NAME" (like standard perl modules are supposed
to be) it takes the next paragraph as the document title. Other standard
head elements of POD are left unchanged (particularly, the SYNOPSIS and
DESCRIPTION elements of standard POD).

Pod::XML tries to be careful about nesting sections based on the head
level in the original POD. Let me know if this doesn't work for you.

=head1 AUTHOR

Matt Sergeant, matt@sergeant.org

=head1 SEE ALSO

Pod::Parser

=head1 BUGS

There is no xml2pod.

=head1 LICENSE

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut
