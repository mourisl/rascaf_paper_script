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
The scripts are in the folder AThal.

Assembly: We used SOAPdenovo2, with the config file in soap.config.

To do the assembly and run quast:

	perl run_batch.pl AThal AThal_SraRunInfo ../SRR1810274_assembly/AThal_sd2_hisat
	nohup ~/Softwares/quast-2.3/quast.py -o quast_out -R ~/data/AThal/TAIR10.fa -T 8 AThal_0.fa AThal_1.fa AThal_2.fa AThal_6.fa AThal_11.fa &

To get the problematic scaffolds and effective misassembly: run it under the folder in quast_out/contigs_report/ . For example, to get the information of the assembly using 1 RNA-seq data example.

	perl ~/rascaf/Tools/CountProblematicContigs.pl ../../AThal_0.fa contigs_report_AThal_0.stdout
	perl ~/rascaf/Tools/FindEffectiveMisassembly.pl ../../rascaf_scaffold_1.info contigs_report_AThal_0.stdout contigs_report_AThal_1.stdout
