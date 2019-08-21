depois de subir a versão nova de banco com os procedimentos conhecidos (criar banco car_nacional, executar create extension postgis e topology) :

perl /usr/share/postgresql/9.5/contrib/postgis-2.2/postgis_restore.pl /rede/image01/car_nacional_2019-01-04.dump  |  PGPASSWORD=*****  psql -v ON_ERROR_STOP=1 -h localhost -p 5432 -W -U postgres car_nacional201811 2> /dados/pg_data/erros201901.txt

​


Conectar no servidor 172.16.32.248, iniciar uma seção do tmux (para a consulta continuar mesmo que a conexão seja perdida) alternar para usuário postgres, inicias o psql, conectar ao banco car_nacional201903 ou o mais atual, executar as consultas seguintes.

gecaf@cepostgispd01: tmux a -t 0
gecaf@cepostgispd01:~$ sudo su postgres
[sudo] password for gecaf:
postgres@cepostgispd01:/home/gecaf$ psql
psql (9.5.8)
Type "help" for help.

postgres=# \c car_nacional201903
You are now connected to database "car_nacional201903" as user "postgres".
car_nacional201903=#

para sair:
\q
exit
exit
exit





------------------------------------


CREATE SCHEMA geoserver
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA geoserver TO postgres;
GRANT USAGE ON SCHEMA geoserver TO public;

-----------------------------------------

create table geoserver.tema_simp_26_imovel as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 round(rel_tema_imovel_poligono.num_area::numeric, 4) as area_ha,
 imovel.cod_imovel,
 imovel.idt_municipio as municipio_ibge,
cod_estado,
 round(imovel.num_modulo_fiscal, 2) as mod_fiscal,
 imovel.dat_criacao as data_ref,
 imovel.ind_tipo_imovel as tipo_imovel,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where idt_tema = 26 and imovel.idt_municipio=municipio.idt_municipio and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;



---------------------------------------------


create table geoserver.tema_simp_2_rvn as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 imovel.cod_imovel,
  imovel.idt_municipio as municipio_ibge,
cod_estado,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where idt_tema = 2 and imovel.idt_municipio=municipio.idt_municipio and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;



---------------------------------------------


create table geoserver.tema_simp_30_app as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 imovel.cod_imovel,
  imovel.idt_municipio as municipio_ibge,
cod_estado,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where idt_tema = 30 and imovel.idt_municipio=municipio.idt_municipio and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;


---------------------------------------------


create table geoserver.tema_simp_32_rl as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 imovel.cod_imovel,
  imovel.idt_municipio as municipio_ibge,
cod_estado,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where idt_tema = 32 and imovel.idt_municipio=municipio.idt_municipio and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;


---------------------------------------------


create table geoserver.tema_simp_1_consolidado as select 

idt_rel_tema_imovel,
 rel_tema_imovel_poligono.idt_imovel,
 imovel.cod_imovel,
  imovel.idt_municipio as municipio_ibge,
cod_estado,
ST_SimplifyPreserveTopology( rel_tema_imovel_poligono.the_geom, 0.00002)

 from usr_geocar_aplicacao.rel_tema_imovel_poligono 
,usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where idt_tema = 1 and imovel.idt_municipio=municipio.idt_municipio and
imovel.ind_status_imovel in ('AT', 'PE') and flg_ativo is true and
 rel_tema_imovel_poligono.idt_imovel = imovel.idt_imovel;
 
 
 
 
 -----------------------------------------------
 
 
create table geoserver.atlas_nascentes as select

idt_rel_tema_imovel, rel_tema_imovel_ponto.idt_imovel, 
cod_imovel, imovel.idt_municipio as municipio_ibge, ind_tipo_imovel,  cod_estado as cod_uf, the_geom as geom
from usr_geocar_aplicacao.imovel,  usr_geocar_aplicacao.rel_tema_imovel_ponto,
usr_geocar_aplicacao.municipio
where 

idt_tema = 15 and ind_status_imovel in ( 'AT', 'PE') and
municipio.idt_municipio = imovel.idt_municipio
and imovel.idt_imovel = rel_tema_imovel_ponto.idt_imovel



