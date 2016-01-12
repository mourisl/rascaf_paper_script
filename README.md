# rascaf_paper_script
The scripts used in rascaf paper

### Simulted data set
The simulted read are from "Rcorrector: efficient and accurate error correction for Illumina RNA-seq reads" (http://www.gigasciencejournal.com/content/4/1/48/abstract). Then you can use "grep" to obtain the reads from chr1 or 12. 

To obtain the feasible connection set:

	perl Tools/FluxCoordToRefCoord.pl tmp_read1.fq ~/data/rcorrector/simulate/simulate_pair_100M.gtf > sim_chr1+12.coords
	perl /Tools/FindTrueConnections.pl ref.fa sim_chr1+12.coords > tmp.true

Evaluate the connection result:
	./rascaf -b ~/data/rascaf/chr1+12/sim_chr1+12.sorted.bam -f ~/data/rascaf/chr1+12/ref.fa 
	perl ../Tools/EvaluateRascaf.pl ~/data/rascaf/chr1+12/tmp.true rascaf.out

### Arabidopsis data sets

