# INITIAL PHYLOGENETIC ANALYSIS

### run MAFFT

mafft 6taxa.innexins.fa > 6taxa.innexins.fa.mafft

### run IQ-TREE 1.5.5

iqtree-omp -s 6taxa.innexins.fa.mafft -nt AUTO -bb 1000 -m TEST -pre 6taxa.iqtree > iq.out 2> iq.err

### run RaxML with random starting trees

raxmlHPC-PTHREADS-SSE3 -f a -T 100 -p 1113 -x 9843 -# 100 -m PROTGAMMALG -s 6taxa.innexins.fa.mafft -n RAxML_All_rt > rax.out 2> rax.err

### run Mr. Bayes

mpirun -np 170 mb 6taxa.innexins.fa.mafft.nex


