#!/bin/perl

use strict ;

die "usage: a.pl agouti.fa origin_quast_out agouti_quast_out\n" if ( @ARGV != 3 ) ;

my %agoutiToOrig ;
my %origMisassembled ;
my %origUnaligned ;
my %origShowedup ;
my %agoutiMisassembled ;
open FP1, $ARGV[0] ;
while ( <FP1> )
{
	next if ( !/^>/ ) ;	
	chomp ;
	my $line = $_ ;
	my @cols = split ;
	#>scaffold_1 (scaffold2 7 +) (scaffold2 8 +)
	my $prevScafId = "--" ;
	my $agoutiId = substr( $cols[0], 1 ) ;
	
	if ( $agoutiId =~ /agouti/ )
	{
		#print $agoutiId, "\n" ;
		$agoutiId =~ s/,/_/g ;
		my @cols2 = split /\|/, $line ;
		@cols = split /,/, $cols2[2] ;
		#print $agoutiId, "\n" ;
		for ( my $i = 0 ; $i < @cols ; $i += 1 )
		{
			my $scafId = $cols[$i] ;
			#print "\t", $scafId, "\n" ;
			${ $agoutiToOrig{ $agoutiId } }{ $scafId } = 1 ; 
		}
	}
	else
	{
		${ $agoutiToOrig{ $agoutiId } }{ $agoutiId } = 1 ;
	}
}
close FP1 ;
#foreach my $key (keys %agoutiToOrig )
#{
#	foreach my $key2 (keys %{ $agoutiToOrig{$key} } )
#	{
#		print $key, " ", $key2, "\n" ;
#	}
#}

for ( my $i = 1 ; $i <= 2 ; ++$i )
{
	open FP1, $ARGV[$i] ;
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
			if ( $i == 1 )
			{
				$origMisassembled{ $scafId } = 0 ;
				$origShowedup{$scafId} = 1 ;
				$origUnaligned{ $scafId } = 0 ;
			}
			else
			{
				$agoutiMisassembled{ $scafId } = 0 ;
			}
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
				if ( $i == 1 )
				{
					#print $scafId, "\n" ;
					$origMisassembled{ $scafId } = $flag ;
				}
				else
				{
					$agoutiMisassembled{ $scafId } = $flag ;
				}
			}
			if ( $i == 1 && /Warning! This contig is more unaligned than misassembled/ )
			{
				$origUnaligned{ $scafId } = 1 ;
			}
			elsif ( $i == 1 && /This contig is partially unaligned./ )
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
}

my $origCnt = 0 ;
my $agoutiCnt = 0 ;
my $effectiveCnt = 0 ;
foreach my $key (keys %origMisassembled )
{
	if ( $origMisassembled{$key} == 1 )
	{
		++$origCnt ;
	}
}

foreach my $key (keys %agoutiMisassembled )
{
	if ( $agoutiMisassembled{$key} == 1 )
	{
		++$agoutiCnt ;
	}
}

foreach my $key (keys %agoutiMisassembled )
{
	if ( $agoutiMisassembled{ $key } == 1 )
	{
		my $flag = 0 ;
		my $origList ;
		foreach my $key2 (keys %{ $agoutiToOrig{$key} } )
		{
			#print "$key $key2\n" ;
			$origList .= "$key2 " ;
			#if ( !(defined $origShowedup{$key2} ) || $origMisassembled{$key2} == 1 || $origUnaligned{$key2} == 1 )
			if ( $origMisassembled{$key2} == 1 || $origUnaligned{$key2} == 1 )
			{
				$flag = 1 ;
			}
		}
		if ( $flag == 0 )	
		{
			++$effectiveCnt ;
			print "$key: $origList\n" ;
		}
	}
}

print "$origCnt $agoutiCnt $effectiveCnt\n" ;

