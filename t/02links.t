#!/usr/local/bin/perl

chdir ( $1 ) if ( $0 =~ m/(.*)(\\|\/)(.*)/ );

# change into the t/ directory
use Test::Assertions qw(test);
use Pod::XML;
use IO::Scalar;

plan tests => 2;

ASSERT ( $Pod::XML::VERSION, "Loaded Pod::XML version $Pod::XML::VERSION." );

my $parser = new Pod::XML ();
my $xml = '';

# because Pod::XML automatically outputs to STDOUT
tie *STDOUT, 'IO::Scalar', \$xml;

$parser->parse_from_file ( "links.pod" );

untie *STDOUT;

ASSERT ( EQUALS_FILE ( $xml, "links.pod.xml" ), "XML generated correctly." );
