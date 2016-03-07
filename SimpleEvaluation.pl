#!/bin/perl

# Just test the precision by testing whether two connected contigs should be adjacent
use strict ;

die "usage: a.pl rascaf.out" if ( @ARGV == 0 ) ;

my %rc ;

$rc{'+'} = "-" ;
$rc{'-'} = "+" ;

open FP1, $ARGV[0] ;
my $P = 0 ;
my $FP = 0 ;

while ( <FP1> )
{
	last if ( /WARNING/ ) ;
	next if ( !/^[0-9]+:/ ) ;
	my @cols = split ;

	my @contigs ;
	my @strand ;

	#3: (chr1_1993:175747999-175965799 217801 +) (chr1_1994:175965800-176132443 166644 +) (chr1_1996:176133195-176390208 257014 +) 
	for ( my $i = 1 ; $i < @cols ; $i += 3 )
	{
		my $c = substr( $cols[$i], 1 ) ;
		$c = ( split /:/, $c )[0] ;
	
		push @contigs, $c ;
	}

	for ( my $i = 3 ; $i < @cols ; $i += 3 )
	{
		my $c = substr( $cols[$i], 0, 1 ) ;
		push @strand, $c ;
	}

	for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )		
	{
		++$P ;

		my $c1 = $contigs[ $i ] ;
		my $c2 = $contigs[ $i + 1 ]  ;
		my $s1 = $strand[ $i ] ;
		my $s2 = $strand[ $i + 1 ] ;
		
		my @cols1 = split /_/, $c1 ;
		my @cols2 = split /_/, $c2 ;
		
		my $chrId1 = "" ;
		for ( my $j = 0 ; $j < scalar( @cols1 ) - 1 ; ++$j )
		{
			$chrId1 .= "_".$cols1[$j] ;
		}
		my $chrId2 = "" ;
		for ( my $j = 0 ; $j < scalar( @cols2 ) - 1 ; ++$j )
		{
			$chrId2 .= "_".$cols2[$j] ;
		}

		if ( $cols1[0] ne $cols2[0] )	
		{
			++$FP ;
			next ;
		}
		my $ind1 = $cols1[-1] ;
		my $ind2 = $cols2[-1] ;
		if ( $ind1 > $ind2 )
		{
			($ind1, $ind2) = ($ind2, $ind1) ;
			($s1, $s2)=($s1, $s2) ;
			$s1 = $rc{ $s1 } ;
			$s2 = $rc{ $s2 } ; 
		}
		if ( $ind2 - $ind1 >= 5 )
		{
			print "$c1 $c2\n" ;
			++$FP ;
			next ;
		}
		if ( ( $s1 ne $s2 ) || ( $s1 ne "+" ) )
		{
			++$FP ;
			next ;
		}
	}
}

print "P=$P FP=$FP precision=", 1-$FP/$P, "\n" ;
