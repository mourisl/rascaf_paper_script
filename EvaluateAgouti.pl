#!/bin/perl

# The script to evaluate the output of rascaf for the synthetic simulated data set

use strict ;

die "usage: a.pl true_connection agouti_paths\n" if ( @ARGV == 0 ) ;

my %trueConnection ;
my %agoutiConnection ;
my %quadAgoutiConnection ;

my %rc ;

# Read in the true connections
open FP1, $ARGV[0] ;
while ( <FP1> )
{
	chomp ;
	my @cols = split ;

	#my $key = $cols[1]." ".$cols[2]." ".$cols[3] ;
	my $c1 = $cols[1]."_".$cols[2] ;
	my $c2 = $cols[1]."_".$cols[3]  ;

	if ( $c1 gt $c2 )	
	{
		($c1, $c2)=($c2, $c1) ;
	}

	my $key = $c1."_".$c2 ;

	$trueConnection{$key} = 0 ;
}
close FP1 ;

# Read in the agouti information
open FP2, $ARGV[1] ;
while ( <FP2> )
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
		my $c1 = ( split /:/, $contigs[ $i ] )[0] ;
		my $c2 = ( split /:/, $contigs[ $i + 1 ]  ) [0] ;
			
		if ( $c1 eq $c2 )
		{
			print "hi\n" ;
		}

		if ( $c1 gt $c2 )	
		{
			($c1, $c2)=($c2, $c1) ;
		}

		my $key = $c1."_".$c2 ;
		$agoutiConnection{ $key } = 0 ;
	}
	
	# contain all the connection including non-adjacent ones
	for ( my $i = 0 ; $i < scalar( @contigs ) - 1 ; ++$i )	
	{
		for ( my $j = $i + 1 ; $j < scalar( @contigs ) ; ++$j )
		{
			my $c1 = ( split /:/, $contigs[ $i ] )[0] ;
			my $c2 = ( split /:/, $contigs[ $j ]  ) [0] ;

			if ( $c1 gt $c2 )	
			{
				($c1, $c2)=($c2, $c1) ;
			}

			my $key = $c1."_".$c2 ;

			$quadAgoutiConnection{ $key } = 0 ;
		}
			
	}
}
close FP2 ;

my $T = 0 ; # feasible
my $TP = 0 ;
my %tt ;
foreach my $key (keys %trueConnection )
{
	if ( defined $quadAgoutiConnection{ $key } ) 
	{
		++$TP ;
	}
	else
	{
		#print $key, "\n" ;
	}
	++$T ;
}

# weak feasible
my $FP = 0 ; 
my $P = 0 ; 
foreach my $key (keys %agoutiConnection )
{
	if ( !(defined $trueConnection{ $key } ) ) 
	{
		++$FP ;
		print $key, "\n" ;
	}
	++$P ;
}

print "T=$T P=$P TP=$TP FP=$FP\n" ;
print "Sensitivity=". $TP/$T." Precision=". (1-$FP/$P) ."\n" ;
