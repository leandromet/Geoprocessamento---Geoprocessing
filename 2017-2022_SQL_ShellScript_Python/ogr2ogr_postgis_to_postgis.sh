postgres@cepostgispd01:~$ ogr2ogr -f "PostGreSQL" -update -append  PG:"host= 172.16.32.0 user=postgres dbname=car_nac password=*******" PG:"host= 172.16.32.0 user=postgres dbname=car_nacional201903 password=*geocad20
17"  -sql "SELECT idt_municipio  FROM   usr_geocar_aplicacao.municipio;" -nln teste_ogr_municipios
postgres@cepostgispd01:~$ ogr2ogr -f "PostGreSQL" -update -append  PG:"host= 172.16.32.0 user=postgres dbname=car_nac password=***********" PG:"host= 172.16.32.0 user=postgres dbname=car_nacional201903 password=*geocad20
17"  -sql "SELECT idt_municipio  FROM   usr_geocar_aplicacao.municipio;" -nln proc_sfb.teste_ogr_municipios
