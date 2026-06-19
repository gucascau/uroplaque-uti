#!/bin/sh
#SBATCH --time=48:00:00
#SBATCH --partition=himem
#SBATCH --cpus-per-task=12
#SBATCH --job-name=LargeD
#SBATCH --output=slurm_%j.out

set -e


ml GCC/7.3.0-2.30
ml OpenMPI/3.1.1
ml GCCcore/7.3.0
ml Python/2.7.15
ml Perl/5.28.0
#ml  GCC/7.3.0-2.30


module load TopHat/2.1.2
module load Cufflinks/2.2.1
module load  SAMtools/1.15
module load Trim_Galore/0.6.0-Python-2.7.15
module load  HTSeq/0.12.4
module load Bowtie2/2.3.4.2



### set up the enviroment (GRCm38.p6)
mm10=/home/gdbecknelllab/xxw004/Projects/GenomeIndex/Mus_musculus/UCSC/latest/mm10
gtf=/home/gdbecknelllab/xxw004/Projects/GenomeIndex/Mus_musculus/UCSC/genes/mm10.ensGene.gtf

in1=/home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/230308_Becknell_GSL-AJ-3279
in2=/home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/230308_Becknell_GSL-AJ-3279_run2

in=/home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/SampleCombined
out=/home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/SampleCombined


### set up the sample information

id=Sample_6_GSL-AJ-3279
Substr=_S6


# Generate the inputs of reads substring

# the first run in /home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/230308_Becknell_GSL-AJ-3279/
# the first part in the first run
read1In1=_L001_R1_001.fastq
read2In1=_L001_R2_001.fastq

# second part in the first run
read1In2=_L002_R1_001.fastq
read2In2=_L002_R2_001.fastq

# the second run in /home/gdbecknelllab/xxw004/Projects/Ashley/Upk1bProject/Datasets/230308_Becknell_GSL-AJ-3279
# they generated another run that contains the 
read1In3=_L002_R1_001.fastq
read2In3=_L002_R2_001.fastq

# we combined the reads for each run and sub-runs
read1=_Combined_R1_001.fastq
read2=_Combined_R2_001.fastq

cut1=_Combined_R1_001_val_1.fq
cut2=_Combined_R2_001_val_2.fq

date

echo "start anlyzing the sequence ...."

# unzip the first run for read1 read2 in In1 and In2
# gunzip $in1/${id}/${id}${Substr}${read1In1}.gz
# gunzip $in1/${id}/${id}${Substr}${read2In1}.gz
#
# gunzip $in1/${id}/${id}${Substr}${read1In2}.gz
# gunzip $in1/${id}/${id}${Substr}${read2In2}.gz
#
# gunzip $in2/${id}/${id}${Substr}${read1In2}.gz
# gunzip $in2/${id}/${id}${Substr}${read2In2}.gz


# # cat the zipped files
#
# cat $in1/${id}/${id}${Substr}${read1In1}.gz $in1/${id}/${id}${Substr}${read1In2}.gz $in2/${id}/${id}${Substr}${read1In2}.gz >${in}/${id}${read1}.gz
# cat $in1/${id}/${id}${Substr}${read2In1}.gz $in1/${id}/${id}${Substr}${read2In2}.gz $in2/${id}/${id}${Substr}${read2In2}.gz >${in}/${id}${read2}.gz
#
# # then unzip the files
# gunzip ${in}/${id}${read1}.gz
# gunzip ${in}/${id}${read2}.gz
#
# # Evaluate the raw reads
#
# fastqc $in/${id}${read1}
# fastqc $in/${id}${read2}
#
# # meaure the raw reads number:
# wc -l $in/${id}${read1} |awk '{ave=2*$1/4;print "RawReadnumber\t"ave}' >${in}/${id}_FinalReadStat.txt
#
# # remove the bad sequences
# echo "start remove the bad sequence"
# trim_galore --paired --retain_unpaired  --dont_gzip -o $out --fastqc_args "-d ~/scratch" $in/${id}${read1}   $in/${id}${read2}
# wc -l $in/${id}${cut1} |awk '{ave=2*$1/4;print "HighQualityReadnumber\t"ave}' >>${in}/${id}_FinalReadStat.txt
#
# #trim_galore -o $out $in/${id}${read}
#
# echo "trim_galore finished"

## Run the tophat
echo "tophat started"

tophat  -p 12  -G $gtf -o $out/${id} $mm10 $in/${id}${cut1} $in/${id}${cut2}   2>$out/${id}.tophat.err


echo "tophat finished"

date
### run cufflinks

echo "tophat started"
cufflinks -o $out/${id} -G $gtf $out/${id}/accepted_hits.bam

echo "cufflinks finished"
date

# check the mapping rate:
grep "concordant pair alignment rate" $out/${id}/align_summary.txt | perl -ne '{my $mappped= (split/\s+/,$_)[0]; print "MappingRate\t$mapped\n"}' >>${in}/${id}_FinalReadStat.txt

### only retain the the uniqu maping
echo "samtools started"
samtools sort -n  $out/$id/accepted_hits.bam  -o $out/$id/accepted.sort_n.bam
samtools view -b -F 1548 -q 30 $out/$id/accepted.sort_n.bam  -o $out/${id}.srt.filtered.bam
echo "samtools finished"
date
echo "count by htseq-count"
echo  "ID       $id" >$out/${id}_ssout
htseq-count -f bam -q -r name  -m union -s reverse  $out/${id}.srt.filtered.bam  $gtf >>$out/$id\_ssout
echo  "ID       $id" >$out/${id}_count
htseq-count -f bam -q -r name  -m union -s no  $out/${id}.srt.filtered.bam  $gtf >>$out/$id\_count


### finished

echo "congratulation your task has done to get the read count for each gene!"


echo "Remove redundant files and gzip the fastq file...."

gzip $in/*.fq
gzip $in/*.fastq



