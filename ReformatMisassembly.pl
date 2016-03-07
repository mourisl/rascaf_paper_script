# output the number of misassemblies for each scaffold from quast. 
# This script is able to rename the scaffold based on the rascaf result(Not work if the contigs of a scaffold are assigned to different scaffolds)

#!/bin/perl

use strict ;

die "usage: a.pl quast_contigs_report [rascaf_scaffold.info]" if ( @ARGV == 0 ) ;

my %rename ;

if ( @ARGV == 2 )
{
	#>scaffold_1 (scaffold2 7 +) (scaffold2 8 +)
	open FP1, $ARGV[1] ;
	while ( <FP1> )
	{
		my @cols = split ;
		my $parent = substr( $cols[0], 1 ) ;

		for ( my $i = 1 ; $i < @cols ; $i += 3 )
		{
			my $scafId = substr( $cols[$i], 1 ) ;
			$rename{ $scafId } = $parent ;
		}
	}
	close FP1 ;
}

open FP1, $ARGV[0] ;
my $scafId ;
my %misassembleCnt ;
while ( <FP1> )
{
	my $line = $_ ;
	if ( /^CONTIG/ )
	{
		my @cols = split ;
		$scafId = $cols[1] ;
		if ( $scafId =~ /\./ )
		{
			$scafId = (split /_/, $cols[1] )[0] ;
		}

		if ( defined $rename{ $scafId } )
		{
			$scafId = $rename{ $scafId } ;
		}
	}
	else
	{
		if ( /Extensive/ )
		{
			$misassembleCnt{ $scafId } += 1 ;
		}
	}
}

foreach my $key (sort keys %misassembleCnt )
{
	print $key, " ", $misassembleCnt{ $key }, "\n" ;
}
