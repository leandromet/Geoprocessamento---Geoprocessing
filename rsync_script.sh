#!/bin/sh


while read line 
	do 

	echo $line

rsync -avzh --progress /image_2/rapideye/cob4_2014/NORTE/$line /home/gecaf/hduf2/cob4



done < rsync_faltam_norte_ufla.txt

