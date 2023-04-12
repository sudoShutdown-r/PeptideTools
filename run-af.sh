#!/bin/bash
bulk_mode=""
type_pref=0
while getopts 'bt:' flag;
do
 case "${flag}" in
  b) bulk_mode='true' ;;
  t) type_pref="${OPTARG}" ;;
  *) ;;
 esac
done
# Check if the user has a config and if they want to change it, if the user doesn't have one, generate one.
cd /home/$USER/
 Se_arr=()
 while IFS= read -r line; do
    Se_arr+=( "$line" )
 done < <( ls -a )
RUNCHECK=0
for i in ${Se_arr[@]}
do
 if [[ ${Se_arr[*]} =~ '.spconfig.config' ]]
 then
  echo "Do you want to change your settings? (y/n)"
  read spconfig
  if [[ $spconfig == 'y' ]]
  then
   RUNCHECK=1
   echo "Output directory? (Include full path with a slash at the end!)"
   read OUTPUTDIR
   echo "Default directory for amino acid sequences? (Full path with a slash at the end!)"
   read AADIR
   echo "Alphafolds directory. (no slash)"
   read ALPHADIR
   echo "Path to Alphafold's databases? (no slash)"
   read DATADIR
   else
   break
  fi
 else
  spconfig='y'
 fi
done
if [[ $spconfig == 'y' && $RUNCHECK = 0 ]]
then
   echo "Output directory? (Include full path with a slash at the end!)"
   read OUTPUTDIR
   echo "Default directory for amino acid sequences? (Full path with a slash at the end!)"
   read AADIR
   echo "Alphafolds directory. (no slash)"
   read ALPHADIR
   echo "Path to Alphafolds databases? (no slash)"
   read DATADIR
   RUNCHECK=1
else
 echo "Nothing to do."
fi
# if a config has been generated or modified then save it to a config file in home
if [[ $RUNCHECK = 1 ]]
then
 write=($OUTPUTDIR $AADIR $ALPHADIR $DATADIR)
 printf '%s\n' "${write[@]}" > /home/$USER/.spconfig.config
fi
#read from the config to obtain paths for files
cfg=()
while IFS= read -r line; do
   cfg+=("$line")
done <.spconfig.config
echo ${cfg[*]}
output_directory=${cfg[0]}
aminos=${cfg[1]}
alphafold_directory=${cfg[2]}
data_directory=${cfg[3]}
# use the bulk preset
if [[ $bulk_mode == 'true' ]]
then
 cd /home/$USER/GEN_SP
 arr=()
 while IFS= read -r line; do
    arr+=( "$line" )
 done < <( ls )
 echo "Files extracted from directory"
 aminos="/home/$USER/GEN_SP/"
else
#Get number of files being used if this script is being used on its own
echo "Number of files?"
read file_amnt
# ask for new path to proteins
echo "Use the default path for Peptides?"
echo "yes/no"
read boolean_path
if [[ ${#boolean_path} -ge 3 ]];
then
 echo "Using Default"
else
  echo "path?"
  read aminos
fi
#init vars
arr=()
file_string=""
#Create the acutal string at used in command argument
if [[ $file_amnt -gt 1 ]];
then
 for (( i=1; i<=$file_amnt; i++))
 do
   echo "Name of file" $i"?"
   read arr[$i-1]
 done
else
 echo "Name?"
 read name
 file_string=$aminos$name".fasta"
fi
fi
# if bulk mode is being used fasta ending doesn't need to be added.
if [[ $bulk_mode == 'true' ]]
then
 index=0
 for i in "${arr[@]}"
 do
   arr[$index]=$aminos$i
   ((index++))
 done
else
 index=0
 for i in "${arr[@]}"
 do
   arr[$index]=$aminos$i".fasta"
   ((index++))
 done
fi
# chain together each array element adding commas in between.
 for i in "${arr[@]}"
 do
   file_string=$file_string$i","
 done
# take all of the string except for the uneeded comma at the end.
len=${#file_string}
file_string=${file_string:0:$len-1}
echo "file argument pre-processing completed"
#determine what batch the run is
cd $output_directory
 barr=()
 while IFS= read -r line; do
    barr+=( "$line" )
 done < <( ls )
batch=${#barr[*]}
((batch++))

if [[ $bulk_mode != 'true' ]]
then
echo "Enter type: monomer(0) or multimer(1)"
read type_pref
fi
if [[ $type_pref = 0 ]];
then
 type="monomer"
else
 type="multimer"
fi
echo
echo "Changing Directory to alphafold's directory."
cd $alphafold_directory
echo
mkdir -p $output_directory"Batch:"$batch
echo "Running alphafold"
sudo python3 docker/run_docker.py \
  --fasta_paths=$file_string \
  --max_template_date=2020-05-14 \
  --model_preset=$type \
  --db_preset=reduced_dbs \
  --data_dir=$data_directory \
  --output_dir=$output_directory"Batch:"$batch \
  --enable_gpu_relax=false
echo
mv  -v /home/$USER/GEN_SP/* $output_directory"Batch:"$batch
echo
echo "Job finished. Check your output directory."
