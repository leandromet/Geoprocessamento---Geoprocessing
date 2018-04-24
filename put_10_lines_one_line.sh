exec 5< brasil_munic_in.txt 


while read line1 <&5; do read line2 <&5; read line3 <&5; read line4 <&5; read line5 <&5; read line6 <&5; read line7 <&5; read line8 <&5; read line9 <&5;  read line10 <&5; echo "$line1 , $line2 , $line3 , $line4 , $line5 , $line6 , $line7 , $line8 , $line9 , $line10" >> brasil_munic10.txt ;  done


exec 5<&-
