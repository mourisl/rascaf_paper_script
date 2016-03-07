#!/bin/perl

# intersect the rascaf, lrs and agouti.

use strict ;

die "usage: a.pl rascaf.out lrs.final.path agouti.path" if ( @ARGV == 0 ) ;

my %rc ;

$rc{'+'} = "-" ;
$rc{'-'} = "+" ;
my %rascafConnection ;
my %lrsConnection ;
my %agoutiConnection ;
my %connection ;

# rascaf
my $start ;
open FP1, $ARGV[0] ;
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

	my @contigs ;
	my @strand ;
	my $line = $_ ;

#3: (chr1_1993:175747999-175965799 217801 1 +) (chr1_1994:175965800-176132443 166644 2 +) (chr1_1996:176133195-176390208 257014 3 +) 
	for ( my $i = 1 ; $i < @cols ; $i += 4 )
	{
		my $c = substr( $cols[$i], 1 ) ;
		push @contigs, $c ;
	}

	for ( my $i = 4 ; $i < @cols ; $i += 4 )
	{
		my $c = substr( $cols[$i], 0, 1 ) ;
		push @strand, $c ;
	}

	for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )		
	{
		my $c1 = $contigs[ $i ] ;
		my $c2 = $contigs[ $i + 1 ]  ;
		my $s1 = $strand[ $i ] ;
		my $s2 = $strand[ $i + 1 ] ;

		next if ( $c1 eq $c2 ) ;

		if ( $c1 gt $c2 )	
		{
			($c1, $c2)=($c2, $c1) ;
			($s1, $s2)=($s2, $s1) ;
			$s1 = $rc{ $s1 } ;
			$s2 = $rc{ $s2 } ; 
		}

		my $key = $c1."_".$c2 ;

		$rascafConnection{ $key } = 0 ;
		$connection{ $key } = 0 ;
	}
}
close FP1 ;


open FP1, $ARGV[1] ;
while ( <FP1> )
{
	chomp ;
	my @cols = split /->/ ;

	#print $cols[0], $cols[1], "\n" ;

	my @contigs ;
	my @strand ;
	my $line = $_ ;

	for ( my $i = 0 ; $i < @cols ; $i += 2 )
	{
		my $c = $cols[$i] ;
		$c =~ s/\/r//g ;
		push @contigs, $c ;
	}

	for ( my $i = 0 ; $i < @cols ; $i += 2 )
	{
		if ( $cols[$i] =~ /\/r/ )
		{
			push @strand, "-" ;	
		}
		else
		{
			push @strand, "+" ;
		}
	}

	for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )		
	{
		my $c1 = $contigs[ $i ] ;
		my $c2 = $contigs[ $i + 1 ]  ;
		my $s1 = $strand[ $i ] ;
		my $s2 = $strand[ $i + 1 ] ;
		
		next if ( $c1 eq $c2 ) ;

		if ( $c1 gt $c2 )	
		{
			($c1, $c2)=($c2, $c1) ;
			($s1, $s2)=($s2, $s1) ;
			$s1 = $rc{ $s1 } ;
			$s2 = $rc{ $s2 } ; 
		}

		my $key = $c1."_".$c2 ;
		
		$lrsConnection{ $key } = 0 ;
		$connection{ $key } = 0 ;
	}
	
}
close FP1 ;

if ( defined $ARGV[2] )
{
	open FP1, $ARGV[2] ;
	while ( <FP1> )
	{
		chomp ;
		next if ( /^>/ ) ;
		my @cols = split /,/ ;

		my @contigs ;
		my @strand ;
		my $line = $_ ;

#chr1_2841:243024177-243229600,chr1_2550:223971141-224189072
		for ( my $i = 0 ; $i < @cols ; ++$i )
		{
			push @contigs, $cols[$i] ;
		}

		for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )		
		{
			#my $c1 = ( split /:/, $contigs[ $i ] )[0] ;
			#my $c2 = ( split /:/, $contigs[ $i + 1 ]  ) [0] ;

			my $c1 = $contigs[$i] ;
			my $c2 = $contigs[$i + 1] ;

			if ( $c1 gt $c2 )	
			{
				($c1, $c2)=($c2, $c1) ;
			}

			my $key = $c1."_".$c2 ;
			$agoutiConnection{ $key } = 0 ;
			$connection{ $key } = 0 ;
		}
	}

	close FP1 ;
}

my %used ;
foreach my $key ( keys %connection )
{
	my $flag = 0 ;
	$flag |= 1 if ( defined $rascafConnection{ $key } ) ;
	$flag |= 2 if ( defined $lrsConnection{ $key } ) ;
	$flag |= 4 if ( defined $agoutiConnection{ $key } ) ;
	
	print "$key $flag\n" ;
}
