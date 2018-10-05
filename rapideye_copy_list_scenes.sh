#!/bin/sh


while read line 
	do 
        cp /rede/image02/rapideye/cob3_2013/SUL/*/*/*$line* /rede/image03/extracoes/2018/pr_ufla_falta/
	echo $line



done < /rede/image03/extracoes/2018/tiles_ufla_pr.txt
