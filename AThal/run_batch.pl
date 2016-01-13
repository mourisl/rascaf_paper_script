#!/bin/perl

use strict ;

die "usage: a.pl prefix_of_assembly sra_run_info index\n" if ( @ARGV == 0 ) ;

sub system_call {
    print STDERR "SYSTEM CALL: ".join(" ",@_);
	system(@_) == 0
	  or die "system @_ failed: $?";
    print STDERR " finished\n";
}

my $prefix = $ARGV[0] ;
my $index = $ARGV[2] ;
open FP1, $ARGV[1] ;
my $ind = 1 ;
my $fasta = "$prefix.fa" ;
while ( <FP1> )
{
	# download the SRA
	my $line = $_ ;
	s/, /-/g ;
	my @cols = split /,/ ;
	
	my $ftp = $cols[9] ;
	my $sra = $cols[0] ;

	if ( !(-e $sra ) )
	{
		system_call( "wget $ftp" ) ;
		system_call( "fastq-dump --split-files $sra") ;
	}

	my $file1 = $sra."_1.fastq" ;
	my $file2 = $sra."_2.fastq" ;
	if ( !( -e $file1 ) || !( -e $file2 ) ) 
	{
		next ;		
	}
	
	# build the index
	if ( !( -e "$sra.sorted.bam" ) ) 
	{
		system_call( "~/Softwares/hisat/hisat -p 8 -x $index -1 $file1 -2 $file2 2>> hisat_log | samtools view -bS - > $sra.bam" ) ;
		system_call( "samtools sort $sra.bam $sra.sorted" ) ;

		#system_call( "rm $sra $sra*.fastq" ) ;
	}

	# Use rascaf
	if ( !(-e "rascaf_$ind.out" ) )
	{
		system_call( "~/rascaf/rascaf/rascaf -b $sra.sorted.bam -f $fasta -o rascaf_$ind" ) ;
	}
	++$ind ;
	#my $nextFasta = $ARGV[0]."_".($ind + 1).".fa" ;
	#system_call( "~/rascaf/rascaf/join $fasta rascaf_$ind.out > $nextFasta" ) ;
}
close FP1 ;

my $cnt = $ind ;
my $cmd = "~/rascaf/rascaf/rascaf_join" ;
system_call( "cp $prefix.fa ". $prefix."_0.fa" ) ;
for ( my $i = 1 ; $i < $cnt ; ++$i )
{
	$cmd .= " -r rascaf_$i.out" ;
	system_call( $cmd."> $prefix"."_".$i.".fa" ) ;
	system_call( "cp rascaf_scaffold.info rascaf_scaffold_$i.info") ;
}
