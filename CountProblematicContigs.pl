#!/bin/perl

use strict ;

die "usage: a.pl assembly.fa quast_out\n" if ( @ARGV != 2 ) ;

my %origMisassembled ;
my %origUnaligned ;
my %origShowedup ;
#foreach my $key (keys %rascafToOrig )
#{
#	foreach my $key2 (keys %{ $rascafToOrig{$key} } )
#	{
#		print $key, " ", $key2, "\n" ;
#	}
#}

my %origIds ; 
open FP1, $ARGV[0] ;
while ( <FP1> )
{
	if ( /^>/ )
	{
		my @cols = split ;
		my $scafId = substr( $cols[1], 1 ) ;
		if ( $scafId =~ /\./ )
		{
			my @cols2 = split /_/, $scafId ;
			$scafId = $cols2[0] ;
		}
		$origIds{ $scafId } = 1 ;
	}
}
close FP1 ;

open FP1, $ARGV[1] ;
my $scafId = "--" ;
while ( <FP1> )
{
	if ( /^CONTIG/ )
	{
		my @cols = split ;
		$scafId = $cols[1] ;
		if ( $scafId =~ /\./ )
		{
			my @cols2 = split /_/, $scafId ;
			$scafId = $cols2[0] ;
		}
		#print $scafId, "\n" ;
		$origMisassembled{ $scafId } = 0 ;
		$origShowedup{$scafId} = 1 ;
		$origUnaligned{ $scafId } = 0 ;
	}
	elsif ( /^Analyzing coverage.../ )
	{
		last ;
	}
	elsif ( $scafId ne "--" )
	{
		if ( /Extensive misassembly/ )
		{
			my $flag = 1 ;
			if ( /relocation, inconsistency = ([\-0-9]+)?/ )
			{
				my $insert = $1 ;
#print "$insert: $_" if ( $insert < 0 ) ;
				if ( $insert < 10000 && $insert >= 0 )
				{
					$flag = 0 ;
				}
			}
			$origMisassembled{ $scafId } = $flag ;
		}
		if ( /Warning! This contig is more unaligned than misassembled/ )
		{
			$origUnaligned{ $scafId } = 1 ;
		}
		elsif ( /This contig is partially unaligned./ )
		{
			if ( /\(([0-9]+)?\sout of\s([0-9]+)?\)/ )
			{
				my $a = $1 ;
				my $l = $2 ;
#print "$scafId $a $l $_\n" ;
				if ( $a < $l / 2 )
				{
					$origUnaligned{ $scafId } = 1 ;
				}
			}
			else
			{
				die "Wrong format.\n" ;
			}
		}
	}
}
close FP1 ;

my $origCnt = 0 ;
foreach my $key (keys %origShowedup)
{
	if ( $origMisassembled{$key} == 1 || $origUnaligned{ $key } == 1 )
	{
		++$origCnt ;
	}
}

print "Problematic count: $origCnt\n" ;


