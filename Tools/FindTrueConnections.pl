#!/bin/perl

use strict ;

die "usage: a.pl contigs.fa yyy.coords\n" if ( @ARGV == 0 ) ;

open FP1, $ARGV[0] ;

# NOTE: the coordinates in the contigs file are 0-based, and the coordinates in coords file are 1-based

my %chroms ;
my %connection ;

while ( <FP1> )
{
	next if ( !( /^>/ ) ) ;

	# Find the chr id and coordindates
	#>chr12_1:333372-339149
	if ( /^>(.*?)_([0-9]+?):([0-9]+?)-([0-9]+?)$/ )
	{
		my $chrId = $1 ;
		my $contigInd = $2 ;
		my $start = $3 ;
		my $end = $4 ;

		my $chrom = \@{ $chroms{ $chrId } } ;
		for ( my $i = $start ; $i <= $end ; ++$i )
		{
			$chrom->[$i] = int($contigInd) ;
		}
		#print "$chrId $contigInd $end\n" ;
	}
	else
	{
		die "wrong format\n" ;
	}
}
close FP1 ;


open FP2, $ARGV[1] ;
while ( <FP2> )
{
	my @cols = split ;
	my $chrom = \@{ $chroms{ $cols[0] } } ;

	my $left = $chrom->[$cols[1] - 1] ;
	my $right = $chrom->[ $cols[2] - 1 ] ;
	if ( $left ne $right )
	{
		my $key = $cols[0]." $left $right" ;
		++$connection{ $key } ; 
	}
}
close FP2 ;

foreach my $key (keys %connection)
{
	print $connection{$key}, " $key\n" ;
}
