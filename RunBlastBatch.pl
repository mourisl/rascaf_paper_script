#!/bin/perl

use strict ;

use threads ;
use threads::shared ;

die "usage: a.pl xxx.fa threads" if ( @ARGV == 0 ) ;

sub system_call {
	print STDERR "SYSTEM CALL: ".join(" ",@_)."\n";
	system(@_) == 0
		or print STDERR "system @_ failed: $?";
	print STDERR " finished\n";
}

my $fa = $ARGV[0] ;
my $T = $ARGV[1] ;
my $i ;
system_call( "perl ~/Tools/DistributeFasta.pl $fa $T" ) ;

sub solveOneBatch
{
	my $bid = threads->tid() - 1 ;
	return if ( $bid >= $ARGV[1] ) ;
	my $fname = $fa."_$bid" ;
	system_call( "blastn -db refseq_rna -task dc-megablast -query $fname -out blast_$bid.out -outfmt 6 -remote -max_target_seqs 20" ) ;
}

my @threads ;
for ( $i = 0 ; $i < $T ; ++$i )
{
	push @threads, $i ;
}

foreach (@threads)
{
	$_ = threads->create( \&solveOneBatch ) ;
}

foreach (@threads)
{
	$_->join() ;
}
