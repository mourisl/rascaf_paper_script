#!/bin/perl

# The script to evaluate the output of rascaf for the synthetic simulated data set

use strict ;

die "usage: a.pl true_connection rascaf.out\n" if ( @ARGV == 0 ) ;

my %trueConnection ;
my %rascafConnection ;
my %quadRascafConnection ;

my %rc ;

$rc{'+'} = "-" ;
$rc{'-'} = "+" ;

# Read in the true connections
open FP1, $ARGV[0] ;
while ( <FP1> )
{
	chomp ;
	my @cols = split ;

	#my $key = $cols[1]." ".$cols[2]." ".$cols[3] ;
	my $c1 = $cols[1]."_".$cols[2] ;
	my $c2 = $cols[1]."_".$cols[3]  ;
	my $s1 = '+' ;
	my $s2 = '+' ;

	if ( $c1 gt $c2 )	
	{
		($c1, $c2)=($c2, $c1) ;
		($s1, $s2)=($s1, $s2) ;
		$s1 = $rc{ $s1 } ;
		$s2 = $rc{ $s2 } ; 
	}

	my $key = $c1."_".$s1."_".$c2."_".$s2 ;

	$trueConnection{$key} = 0 ;
}
close FP1 ;

# Read in the rascaf information
open FP2, $ARGV[1] ;
while ( <FP2> )
{
	chomp ;
	my @cols = split ;

	my @contigs ;
	my @strand ;
	my $line = $_ ;

#3: (chr1_1993:175747999-175965799 217801 1 +) (chr1_1994:175965800-176132443 166644 2 +) (chr1_1996:176133195-176390208 257014 3 +)
#>scaffold_99 (chr12_115:7295129-7362908 118 +) (chr12_116:7362909-7389542 119 +)
	for ( my $i = 1 ; $i < @cols ; $i += 3 )
	{
		my $c = substr( $cols[$i], 1 ) ;
		if ( $c =~ /(.*?):[0-9]/ )
		{
			$c = $1 ;
		}
		else
		{
			die "Wrong format $line: $c\n" ;
		}
		push @contigs, $c ;
	}

	for ( my $i = 3 ; $i < @cols ; $i += 3 )
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
			($s1, $s2)=($s1, $s2) ;
			$s1 = $rc{ $s1 } ;
			$s2 = $rc{ $s2 } ; 
		}

		my $key = $c1."_".$s1."_".$c2."_".$s2 ;
		$rascafConnection{ $key } = 0 ;
	}
	
	# contain all the connection including non-adjacent ones
	for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )	
	{
		for ( my $j = $i + 1 ; $j < scalar( @contigs ) ; ++$j )
		{
			my $c1 = $contigs[ $i ] ;
			my $c2 = $contigs[ $j ]  ;
			my $s1 = $strand[ $i ] ;
			my $s2 = $strand[ $j ] ;

			if ( $c1 gt $c2 )	
			{
				($c1, $c2)=($c2, $c1) ;
				($s1, $s2)=($s1, $s2) ;
				$s1 = $rc{ $s1 } ;
				$s2 = $rc{ $s2 } ; 
			}

			my $key = $c1."_".$s1."_".$c2."_".$s2 ;

			$quadRascafConnection{ $key } = 0 ;
		}
			
	}
}
close FP2 ;

my $T = 0 ;
my $TP = 0 ;
my %tt ;
foreach my $key (keys %trueConnection )
{
	if ( defined $quadRascafConnection{ $key } ) 
	{
		++$TP ;
	}
	else
	{
		#print $key, "\n" ;
	}
	++$T ;
}

my $FP = 0 ;
my $P = 0 ;
foreach my $key (keys %rascafConnection )
{
	if ( !(defined $trueConnection{ $key } ) ) 
	{
		++$FP ;
		#print $key, "\n" ;
	}
	++$P ;
}

print "T=$T P=$P TP=$TP FP=$FP\n" ;
print "Sensitivity=". $TP/$T." Precision=". (1-$FP/$P) ."\n" ;
