#!/bin/perl

use strict ;

die "usage: a.pl rascaf.out\n" if ( @ARGV == 0 ) ;

open FP1, $ARGV[0] ;
my $start = 0 ;
my %gbSpanLen ;

while ( <FP1> )
{
	chomp ;
	last if ( /WARNING/ ) ;
	if ( /command/ )
	{
		$start = 1 ;
	}
	elsif ( $start == 0 ) 
	{
		next ;
	}
	next if ( !/^[0-9]+:/ ) ;
	my @cols = split ;

	my $n ;
	if ( $cols[0] =~ /([0-9]+)?:/ )
	{
		$n = $1 ;	
	}
	
	for ( my $i = 0 ; $i < $n - 1 ; ++$i )
	{
		my $line = <FP1> ;
		$line =~ s/[\(\)]/ /g ;
		@cols = split /\s+/, $line ;

		my $scafName = "" ;
		my $span = "" ;
		my $scafName1 ;
		my $scafName2 ;
		my $len1 ;
		my $len2 ;

		for ( my $j = 2 ; $j <= 3 ; ++$j )
		{
			my @subCols = split /:/, $cols[$j] ;
			my $k ;
			$scafName = $subCols[0] ;
			for ( $k = 1 ; $k < @subCols - 1 ; ++$k )
			{
				$scafName .= ":".$subCols[$k] ;
			}
			$span = $subCols[$k] ;
			if ( $span =~ /([0-9]+)?-([0-9]+)?/ )
			{
				#print "$span $2 $1\n" ;
				my $len = $2 - $1 + 1 ;
				#$gbSpanLen{ $scafName } = $len ;

				if ( $j == 2 )
				{
					$len1 = $len ;
					$scafName1 = $scafName ;
				}
				else
				{
					$len2 = $len ;
					$scafName2 = $scafName ;
				}
			}
			else
			{
				die "Wrong format $span\n" ;
			}
		}
		
		if ( $len1 < $len2 )
		{
			$gbSpanLen{ $scafName1 } = $len1 ;
		}
		else
		{
			$gbSpanLen{ $scafName2 } = $len2 ;
		}
	}
}
close FP1 ;

foreach my $key (keys %gbSpanLen )
{
	print "$key ", $gbSpanLen{ $key }, "\n" ;
}

