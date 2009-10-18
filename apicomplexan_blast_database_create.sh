#!/bin/bash

cd /blastdb

PLASMODB_VERSION='6.1'
TOXODB_VERSION='5.2'
CRYPTODB_VERSION='4.2'

# soft link the necessary files to the /blastdb folder
# still missing a few species from this section
ln -s ~/phd/data/berghei/genome/plasmodb/$PLASMODB_VERSION/PbergheiAllTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta
ln -s ~/phd/data/berghei/genome/plasmodb/$PLASMODB_VERSION/PbergheiAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta

ln -s ~/phd/data/vivax/genome/plasmodb/$PLASMODB_VERSION/PvivaxAnnotatedTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta
ln -s ~/phd/data/vivax/genome/plasmodb/$PLASMODB_VERSION/PvivaxAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta

ln -s ~/phd/data/falciparum/genome/plasmodb/$PLASMODB_VERSION/PfalciparumGenomic_PlasmoDB-$PLASMODB_VERSION.fasta
ln -s ~/phd/data/falciparum/genome/plasmodb/$PLASMODB_VERSION/PfalciparumAnnotatedTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta
ln -s ~/phd/data/falciparum/genome/plasmodb/$PLASMODB_VERSION/PfalciparumAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta

ln -s ~/phd/data/yoelii/genome/plasmodb/$PLASMODB_VERSION/PyoeliiAllTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta 
ln -s ~/phd/data/yoelii/genome/plasmodb/$PLASMODB_VERSION/PyoeliiAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta 

# ToxoDB entries
ln -s "/home/ben/phd/data/Toxoplasma gondii/ToxoDB/$TOXODB_VERSION/TgondiiME49Genomic_ToxoDB-$TOXODB_VERSION.fasta"
ln -s "/home/ben/phd/data/Toxoplasma gondii/ToxoDB/$TOXODB_VERSION/TgondiiME49AnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta"
ln -s "/home/ben/phd/data/Toxoplasma gondii/ToxoDB/$TOXODB_VERSION/TgondiiME49AnnotatedProteins_ToxoDB-$TOXODB_VERSION.fasta"

ln -s "/home/ben/phd/data/Neospora caninum/genome/ToxoDB/$TOXODB_VERSION/NeosporaCaninumAnnotatedProteins_ToxoDB-$TOXODB_VERSION.fasta"
ln -s "/home/ben/phd/data/Neospora caninum/genome/ToxoDB/$TOXODB_VERSION/NeosporaCaninumAnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta"
ln -s "/home/ben/phd/data/Neospora caninum/genome/ToxoDB/$TOXODB_VERSION/NeosporaCaninumGenomic_ToxoDB-$TOXODB_VERSION.fasta"

# CrytpoDB
ln -s ~/phd/data/Cryptosporidium\ parvum/genome/cryptoDB/$CRYPTODB_VERSION/CparvumAnnotatedProteins_CryptoDB-$CRYPTODB_VERSION.fasta
ln -s ~/phd/data/Cryptosporidium\ parvum/genome/cryptoDB/$CRYPTODB_VERSION/CparvumAnnotatedTranscripts_CryptoDB-$CRYPTODB_VERSION.fasta
ln -s ~/phd/data/Cryptosporidium\ parvum/genome/cryptoDB/$CRYPTODB_VERSION/CparvumGenomic_CryptoDB-$CRYPTODB_VERSION.fasta



# concatenate the databases together
echo "Concatenating the fasta files.."
cat\
 PfalciparumAnnotatedTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta\
 TgondiiAnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta\
 NeosporaCaninumAnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta\
 GeneDB_Etenella_Genes\
 PbergheiAllTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta\
 PvivaxAnnotatedTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta\
 PyoeliiAllTranscripts_PlasmoDB-$PLASMODB_VERSION.fasta\
 >apicomplexa.nucleotide.fa
cat\
 PfalciparumAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta\
 TgondiiAnnotatedProteins_ToxoDB-$TOXODB_VERSION.fasta\
 NeosporaCaninumAnnotatedProteins_ToxoDB-$TOXODB_VERSION.fasta\
 GeneDB_Etenella_Proteins\
 PbergheiAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta\
 PvivaxAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta\
 PyoeliiAnnotatedProteins_PlasmoDB-$PLASMODB_VERSION.fasta\
 BabesiaWGS.fasta_with_names\
 >apicomplexa.protein.fa 
cat\
 PfalciparumGenomic_PlasmoDB-$PLASMODB_VERSION.fasta\
 TgondiiME49Genomic_ToxoDB-$TOXODB_VERSION.fasta\
 >apicomplexa.genome.fa


# Create Blast databases
echo "formating apicomplexan-wide databases.."
formatdb -p F -i apicomplexa.nucleotide.fa
formatdb -i apicomplexa.protein.fa
formatdb -p F -i apicomplexa.genome.fa

#species-specific blast databases
echo "formating toxo databases.."
formatdb -i TgondiiME49AnnotatedProteins_ToxoDB-$CRYPTODB_VERSION.fasta
formatdb -p F -i TgondiiME49AnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta
formatdb -p F -i TgondiiME49Genomic_ToxoDB-$TOXODB_VERSION.fasta

echo "formating neospora databases.."
formatdb -i NeosporaCaninumAnnotatedProteins_ToxoDB-$TOXODB_VERSION.fasta
formatdb -p F -i NeosporaCaninumAnnotatedTranscripts_ToxoDB-$TOXODB_VERSION.fasta
formatdb -p F -i NeosporaCaninumGenomic_ToxoDB-$TOXODB_VERSION.fasta

echo "formating crypto databases.."
formatdb -i CparvumAnnotatedProteins_CryptoDB-$CRYPTODB_VERSION.fasta
formatdb -p F -i CparvumAnnotatedTranscripts_CryptoDB-$CRYPTODB_VERSION.fasta
formatdb -p F -i CparvumGenomic_CryptoDB-$CRYPTODB_VERSION.fasta

# Create Blat databases
#faToTwoBit apicomplexa.protein.fa apicomplexa.protein.fa.2bit
#faToTwoBit apicomplexa.nucleotide.fa apicomplexa.nucleotide.fa.2bit
#faToTwoBit apicomplexa.genome.fa apicomplexa.genome.fa.2bit

