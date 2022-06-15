
alter table geoserver.tema_simp_26_imovel add column municipio_ibge int

update geoserver.tema_simp_26_imovel
set municipio_ibge = right(left(cod_imovel, 10 ),7)::int


alter table geoserver.tema_simp_1_consolidado add column municipio_ibge int;

update geoserver.tema_simp_1_consolidado
set municipio_ibge = right(left(cod_imovel, 10 ),7)::int;


alter table geoserver.tema_simp_2_rvn add column municipio_ibge int;

update geoserver.tema_simp_2_rvn
set municipio_ibge = right(left(cod_imovel, 10 ),7)::int;

alter table geoserver.tema_simp_30_app add column municipio_ibge int;

update geoserver.tema_simp_30_app
set municipio_ibge = right(left(cod_imovel, 10 ),7)::int;

alter table geoserver.tema_simp_32_rl add column municipio_ibge int;

update geoserver.tema_simp_32_rl
set municipio_ibge = right(left(cod_imovel, 10 ),7)::int;
