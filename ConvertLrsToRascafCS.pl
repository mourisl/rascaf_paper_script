#!/bin/perl

use strict ;

die "a.pl final.path guider trinity.fa" if ( @ARGV != 3 ) ;

my %rc ;
$rc{'+'} = "-" ;
$rc{'-'} = "+" ;

my $key = "" ;
my $prevLine = "" ;
my $line ;
my %connection ;
open FP1, $ARGV[0] ;
# store the information from path
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

		my $key = $c1."_".$s1."_".$c2."_".$s2 ;
		#print "$key\n" ;
		$connection{ $key } = 0 ;
	}
	
}
close FP1 ;

# read in the sequence
my %trinity ;
open FP1, $ARGV[2] ;
my $id = "" ;
my $seq = "" ;
while ( <FP1> )
{
	chomp ;
	my $line = $_ ;
	if ( /^>/ )
	{
		if ( $id ne "" )
		{
			$trinity{ $id } = $seq ;
		}
		$id = substr( ( split /\s+/, $line )[0], 1 ) ;
		$seq = "" ;
	}
	else
	{
		$seq .= $line ;
	}
}
$trinity{ $id } = $seq if ( $id ne "" ) ;
close FP1 ;

open FP1, $ARGV[1] ;  
my @guides ;
my $headerIdCnt = 0 ;
my $oneMore = 0 ;
while ( <FP1> ) #|| $oneMore == 0 )
{
	chomp ;
	my $line = $_ ;
	my @cols1 = split /\s+/, $prevLine ;
	my @cols2 = split /\s+/, $line ;
	
	if ( $line == "" )
	{
		++$oneMore ;
	}

	if ( $prevLine eq "" || $cols1[0] eq $cols2[0] )
	{
		push @guides, $line ;
	}
	elsif ( scalar( @guides ) != 0 )
	{
#comp1028_c0_seq2        19      2749    2730    27.12   4336    chr1_451:39752547-39979341      226795  408     36133   0.629613        100     -	
		my $size = scalar( @guides ) ;
		my @chosen ;
		my $trinityId ;
		# note that lrs might skip some alignment	
		for ( my $i = 0 ; $i < $size - 1 ; ++$i )
		{
			for ( my $j = $i + 1 ; $j < $size ; ++$j )
			{
				@cols1 = split /\s+/, $guides[$i] ;
				@cols2 = split /\s+/, $guides[$j] ;
				$trinityId = $cols1[0] ;
				my $found = 0 ;

				my $c1 = $cols1[6] ;
				my $s1 = $cols1[12] ;
				my $c2 = $cols2[6] ;
				my $s2 = $cols2[12] ;

				my $key1 = $c1."_".$s1."_".$c2."_".$s2 ;
#print "$key1\n" ;
				#print "$key1\n" if ( $trinityId eq "TR2|c0_g1_i1" ) ;
				if ( defined $connection{ $key1 } && $connection{ $key1 } == 0 )
				{
					$connection{ $key1 } = 1 ;
					push @chosen, $i ;
					$found = 1 ;
				}
				else
				{

					$key1 = $c2."_".$rc{$s2}."_".$c1."_".$rc{$s1} ;
					#print "$key1\n" if ( $trinityId eq "TR2|c0_g1_i1" ) ;
					if ( defined $connection{ $key1 } && $connection{ $key1 } == 0 )
					{
						$connection{ $key1 } = 1 ;
						push @chosen, $i ;
						$found = 1 ;
					}
				}

				if ( $found == 1 )
				{
					$i = $j ;
					next ;
				}
			}
		}
		
		#print $guides[0], "\n", $guides[1], "\n" ;
		my $header = ">LRS_CS_$headerIdCnt ($trinityId) 1" ;
		my $seq = "" ;
		my $blockCnt = 0 ;
		my @len ;
		for ( my $i = 0 ; $i < scalar( @chosen ) ; ++$i )
		{
			if ( $i == 0 || $chosen[ $i ] != $chosen[ $i - 1 ] + 1 )
			{
				++$blockCnt ;
				my @cols1 = split /\s+/, $guides[ $chosen[$i] ] ;
				my $l = $cols1[2] - $cols1[1] + 1 ;
				$seq .= substr( $trinity{ $cols1[0] }, $cols1[1], $l ) ;
				push @len, $l ;
			}
			++$blockCnt ;
			my @cols1 = split /\s+/, $guides[ $chosen[$i] + 1 ] ;
			my $l = $cols1[2] - $cols1[1] + 1 ;
			$seq .= substr( $trinity{ $cols1[0] }, $cols1[1], $l ) ;
			push @len, $l ;
		}
		$header .= " $blockCnt" ;
		for ( my $i = 0 ; $i < @len ; ++$i )
		{
			$header .= " ".$len[$i] ;
		}
		if ( $seq ne "" )
		{
			print "$header\n$seq\n" ;
			++$headerIdCnt ;
		}

		undef @guides ;
		push @guides, $line ;
	}

	$prevLine = $line ;
}

if ( scalar( @guides ) > 0 )
{
#comp1028_c0_seq2        19      2749    2730    27.12   4336    chr1_451:39752547-39979341      226795  408     36133   0.629613        100     -	
		my $size = scalar( @guides ) ;
		my @chosen ;
		my $trinityId ;
		# note that lrs might skip some alignment	
		for ( my $i = 0 ; $i < $size - 1 ; ++$i )
		{
			for ( my $j = $i + 1 ; $j < $size ; ++$j )
			{
				my @cols1 = split /\s+/, $guides[$i] ;
				my @cols2 = split /\s+/, $guides[$j] ;
				$trinityId = $cols1[0] ;

				my $found = 0 ;

				my $c1 = $cols1[6] ;
				my $s1 = $cols1[12] ;
				my $c2 = $cols2[6] ;
				my $s2 = $cols2[12] ;

				my $key1 = $c1."_".$s1."_".$c2."_".$s2 ;
				if ( defined $connection{ $key1 } && $connection{ $key1 } == 0 )
				{
					$connection{ $key1 } = 1 ;
					push @chosen, $i ;
					$found = 1 ;
				}
				else
				{

					$key1 = $c2."_".$rc{$s2}."_".$c1."_".$rc{$s1} ;
					if ( defined $connection{ $key1 } && $connection{ $key1 } == 0 )
					{
						$connection{ $key1 } = 1 ;
						push @chosen, $i ;
						$found = 1 ;
					}
				}

				if ( $found == 1 )
				{
					$i = $j ;
					next ;
				}
			}
		}
		
		#print $guides[0], "\n", $guides[1], "\n" ;
		my $header = ">LRS_CS_$headerIdCnt ($trinityId) 1" ;
		my $seq = "" ;
		my $blockCnt = 0 ;
		my @len ;
		for ( my $i = 0 ; $i < scalar( @chosen ) ; ++$i )
		{
			if ( $i == 0 || $chosen[ $i ] != $chosen[ $i - 1 ] + 1 )
			{
				++$blockCnt ;
				my @cols1 = split /\s+/, $guides[ $chosen[$i] ] ;
				my $l = $cols1[2] - $cols1[1] + 1 ;
				$seq .= substr( $trinity{ $cols1[0] }, $cols1[1], $l ) ;
				push @len, $l ;
			}
			++$blockCnt ;
			my @cols1 = split /\s+/, $guides[ $chosen[$i] + 1 ] ;
			my $l = $cols1[2] - $cols1[1] + 1 ;
			$seq .= substr( $trinity{ $cols1[0] }, $cols1[1], $l ) ;
			push @len, $l ;
		}
		$header .= " $blockCnt" ;
		for ( my $i = 0 ; $i < @len ; ++$i )
		{
			$header .= " ".$len[$i] ;
		}
		if ( $seq ne "" )
		{
			print "$header\n$seq\n" ;
			++$headerIdCnt ;
		}

		undef @guides ;
		push @guides, $line ;
	}
