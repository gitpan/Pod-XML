#!/usr/local/bin/perl

# most useless test ever.
#
use Test::Assertions qw(test);

plan tests => 1;

eval
{
  require Pod::XML;
};

ASSERT ( ! $@, "Pod::XML::Version available." );
