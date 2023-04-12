#!/bin/bash
echo "WARNING"
echo "Runing this script will delete all generated sequences in the output directory."
echo "Send an interupt within the next 5 seconds to cancel."
sleep 5
echo "Proceding with script."
sleep 1
rm /home/$USER/GEN_SP/*
echo "How many proteins to generate?"
read loops
echo "Fold proteins after? (y/n)"
read exec_bool
while [[ $loops -gt 0 ]];
do
#This creates the N region of the protein.
 N_arr=(0 1 2 3 4)
 tN_in=0
 for i in ${N_arr[@]}
 do
  if [[ $tN_in != 1 ]];
  then
   #generate a random number for each AA
   NRAND=($(shuf -i 1-15))
   N_arr[$tN_in]=$NRAND
  else
   #place a lysine at pos 2, for structure.
   N_arr[$tN_in]=3
   N_arr[$tN_in-1]=12

  fi
  ((tN_in++))
  echo "Fixing N-Domain Residue: "$tN_in
 done
echo "N-Domain of protein: "$loops "completed"
 phob=0
 while [[ $phob -le 3 || $phob -ge 8 ]];
 do
  phob=0
  H_arr=(0 1 2 3 4 5 6 7 8 9)
  H_in=0
  for i in ${H_arr[@]}
  do
   echo "Fixing H-Domain Residue: "$H_in
   HRAND=($(shuf -i 4-12))
   H_arr[$H_in]=$HRAND
   ((H_in++))
   #echo $HRAND
   case $HRAND in
   4)
        ((phob++))
        ;;
   5)
        ((phob++))
        ;;
   6)
        ((phob++))
        ;;
   7)
        ((phob++))
        ;;
   *)
        ;;
   esac
  done
  if [[ $phob -le 3 || $phob -ge 8 ]]
  then
   echo "Out of Hydrophobic range. Retrying H-domain residue fixture."
  else
   echo "H-Domain of protein: "$loops "completed"
  fi
 done
 C_arr=(0 1 2 3 4)
 C_in=0
 for i in ${C_arr[@]}
 do
  if [[ $C_in = 0 || $C_in = 2 ]]
  then
   C_arr[$C_in]=8
   ((C_in++))
  else
   CRAND=($(shuf -i 1-18))
   C_arr[$C_in]=$CRAND
   ((C_in++))
  fi
 done
 echo "C-Domain of protein: "$loops "completed"
 I_arr=()
# I_arr+=${H_arr[@]}
# I_arr+=${C_arr[@]}
 I_in=0
 for element in ${N_arr[@]}
 do
  I_arr[I_in]=${element}
  ((I_in++))
 done
 for element in ${H_arr[@]}
 do
  I_arr[I_in]=${element}
  ((I_in++))
 done
 for element in ${C_arr[@]}
 do
  I_arr[I_in]=${element}
  ((I_in++))
 done
echo "Domains appended."
#convert random numbers to FASTA AAs
 F_in=0
 F_arr=()
for i in ${I_arr[@]}
do
 case ${i} in
    1)
        F_arr[$F_in]="R"
        ((F_in++)) ;;
    2)
        F_arr[$F_in]="H"
        ((F_in++)) ;;
    3)
        F_arr[$F_in]="K"
        ((F_in++)) ;;
    4)
        F_arr[$F_in]="S"
        ((F_in++)) ;;
    5)
        F_arr[$F_in]="T"
        ((F_in++)) ;;
    6)
        F_arr[$F_in]="N"
        ((F_in++)) ;;
    7)
        F_arr[$F_in]="Q"
        ((F_in++)) ;;
    8)
        F_arr[$F_in]="A"
        ((F_in++)) ;;
    9)
        F_arr[$F_in]="V"
        ((F_in++)) ;;
    10)
        F_arr[$F_in]="I"
        ((F_in++)) ;;
    11)
        F_arr[$F_in]="L"
        ((F_in++)) ;;
    12)
        F_arr[$F_in]="M"
        ((F_in++)) ;;
    13)
        F_arr[$F_in]="F"
        ((F_in++)) ;;
    14)
        F_arr[$F_in]="Y"
        ((F_in++)) ;;
    15)
        F_arr[$F_in]="W"
        ((F_in++)) ;;
    16)
        F_arr[$F_in]="C"
        ((F_in++)) ;;
    17)
        F_arr[$F_in]="C" # Would be U if it were supported by AF, C should have same structure.
        ((F_in++)) ;;
    18)
        F_arr[$F_in]="G"
        ((F_in++)) ;;
    19)
        F_arr[$F_in]="P"
        ((F_in++)) ;;
    20)
        F_arr[$F_in]="D"
        ((F_in++)) ;;
    21)
        F_arr[$F_in]="E"
        ((F_in++)) ;;
    *)
        echo "ERROR: Array append failed. Check lines 70-84."
        ((F_in++)) ;;
 esac
echo "Residue "$F_in" decoded."
done
 ((loops--))
 pre_aa="${F_arr[*]}"
 AA_string=$(sed "s/ //g" <<< $pre_aa)
 write=("> Generated Protein Number: "$loops" # of Hydrophobic residues in H-Region: "$phob $AA_string)
mkdir -p /home/$USER/GEN_SP
printf '%s\n' "${write[@]}" > /home/$USER/GEN_SP/protein_$loops.fasta
 #echo ${N_arr[*]}
 #echo ${H_arr[*]}
 #echo "total" $phob
 #echo $NRAND
 #echo ${I_arr[*]}
 #echo ${F_arr[*]}
 #echo $AA_string
echo "Protein" $loops "completed"


done

if [[ $exec_bool == "y" ]]
then
 echo "Creating Command"
 exec ./run-af.sh -b -t 0
else
 echo "Check /home/$USER/GEN_SP"
fi

