use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Pod::XML',
    'VERSION_FROM' => 'XML.pm', # finds $VERSION
    'EXE_FILES' => [qw(pod2xml)],
    'PREREQ_PM' => { Pod::Parser => 1.0 },
);
