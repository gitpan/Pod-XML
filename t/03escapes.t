#!/usr/local/bin/perl

use File::Basename;

chdir dirname ( $0 );

use Test::More tests => 4;

BEGIN
{
  use_ok ( "Pod::XML" );
  use_ok ( "IO::Scalar" );
  use_ok ( "Test::File::Contents" );
}

my $parser = new Pod::XML ();
my $xml = '';

# because Pod::XML automatically outputs to STDOUT
tie *STDOUT, 'IO::Scalar', \$xml;

$parser->parse_from_file ( "escapes.pod" );

untie *STDOUT;

file_contents_is ( 'escapes.pod.xml', $xml, 'XML generated correctly' );
