# Alignment construction and Phylogeny

### Downloaded the following from Ensembl, adjusted deflines, and put in a directory called dir
    ftp ftp.ensemblgenomes.org
    cd /pub/metazoa/release-51/fasta/nematostella_vectensis/pep
    get Nematostella_vectensis.ASM20922v1.pep.all.fa
    cd /pub/metazoa/release-51/fasta/capitella_teleta/pep
    get Capitella_teleta.Capitella_teleta_v1.0.pep.all.fa
    cd /pub/metazoa/release-51/fasta/branchiostoma_lanceolatum
    get Branchiostoma_lanceolatum.BraLan2.pep.all.fa
    cd /pub/metazoa/release-51/fasta/schistosoma_mansoni
    get Schistosoma_mansoni.ASM23792v2.pep.all.fa
    cd /pub/metazoa/release-51/fasta/lottia_gigantea
    get Lottia_gigantea.Lotgi1.pep.all.fa

### Identify innexins and build alignment from Ensembl FASTA files (also ../04-INITIAL_PHYLOGENY/6taxa.innexins.fa was included in dir)

`hmm2aln.pl --fasta_dir=dir --hmm=PF00876.hmm --name=hmm2aln.output --threads=48 --nofillcnf=nofill.conf > hmm2aln.out 2> hmm2aln.err`

###  Create 11taxa.fa by removing the following redundant isoforms from hmm2aln.out: Hcv1.av93.c10.g192, Hcv1.av93.c10.g247 Hcv1.av93.c9.g355 Hcv1.av93.c1.g681 Hcv1.av93.c1.g857

### Run RaxML version 8.2.12 (outputs: RAxML_bestTree.6taxa_plus_hcal_genome_plus_bilat RAxML_bipartitionsBranchLabels.6taxa_plus_hcal_genome_plus_bilat)

`raxmlHPC-PTHREADS-SSE3 -f a -T 255 -p 1114 -x 9844 -# 100 -m PROTGAMMALG -s 11taxa.fa -n 6taxa_plus_hcal_genome_plus_bilat`

### Prune additional sequences with phyutility version 2.7.1

`phyutility -pr -in ../08-RAXML_RT_NZINGA/RAxML_bestTree.6taxa_plus_hcal_genome_plus_bilat -out 6taxa_plus_hcal_genome_plus_bilat.pruned.tre -names Hcal.34274 Hcal.17616 Hcal.11083 Hcal.10515 Hcal.09714 Hcal.05992 Hcal.33641 Hcal.06076 Hcal.25081 Bova4.100819.t2 Hcal.06846 Hcal.28663 Bova4.221716.t2 Hcal.11392.2 Hcal.11392.1 Hcal.63932 Pbac.3465979.2 Hcal.05202 Hcal.26016 Hcal.13342 Hcal.29546`


