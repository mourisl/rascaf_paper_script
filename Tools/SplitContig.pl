#!/bin/perl

# split the file based on the distribution of some contig file.

die "a.pl contigs.fa yyy.fa"  if ( @ARGV == 0 ) ;

my %contigs ;
open FP1, $ARGV[0] ; 
open FP2, $ARGV[1] ;

my @sizes ;
my $size = 0 ; 
while ( <FP2> )
{
	if ( /^>/ ) 
	{
		push @sizes, $size if ( $size > 0 ) ;
		$size = 0 ;
	}
	else
	{
		$size += length( $_ ) - 1 ;
	}
}
push @sizes, $size if ( $size > 0 ) ;
close ( FP2 ) ;

die "no size\n" if ( @sizes == 0 ) ;

my $seq = "" ;
my $id ;
while ( <FP1> )
{
	chomp ;
	if ( />/ )
	{
		if ( $seq ne "" )
		{
			$contigs{ $id }	= $seq ;
		}

		$seq = "" ;
		$id = $_ ;
	}
	else
	{
		$seq .= $_ ;
	}
}
if ( $seq ne "" )
{
	$contigs{ $id }	= $seq ;
}

foreach my $key (keys %contigs)
{
	my $i = 0 ;
	my $j = 0 ;
	my $contigL = length( $contigs{ $key } ) ;

	for ( $i = 0, $j = 0 ; $i < $contigL ; ++$j )
	{
		#printf "$i $j\n" ;
		my $l = $sizes[ int( rand( scalar( @sizes ) ) ) ] ;
		if ( $i + $l > $contigL )
		{
			$l = $contigL - $i ;
		}
		my $t = substr( $contigs{$key}, $i, $l ) ;
		if ( $t =~ /[^Nn]/ ) 
		{
			print $key, "_", "$j:$i-". ($i + $l - 1)."\n" ;
			print substr( $contigs{$key}, $i, $l ), "\n" ;
			$i += $l ;
		}
		else
		{
			$i += $l ;
			next ;
		}
	}
}
