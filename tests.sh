#!/bin/bash
# arquivo de LOGs
arq_log="scripts_`date +\%Y\%m\%d`.log"

rm $arq_log

                #"localhost:/dados/dpl.fdb"

declare -a bancos=(
                 "localhost:/dados/store.fdb"
                )
usuario="SYSDBA"
senha="masterkey"

#loop bancos
for bco in "${bancos[@]}"
   do
     echo "$bco"
#loop scripts
  for arq_sql in ./*.sql; do
    echo $bco "$(basename "$arq_sql")"
    #sudo 
    ./isql.exe $bco  -u $usuario -p $senha -s 1  -i $arq_sql -ch utf8
    echo "========================================="
  done
done

#cat $arq_log



echo "'q' para terminar"
count=0
while : ; do
read -n 1 k <&1
if [[ $k = q ]] ; then
printf "\nEncerrando\n"
break
else
((count=$count+1))
printf "\n $count vezes\n"
echo "'q' para sair"
fi
done