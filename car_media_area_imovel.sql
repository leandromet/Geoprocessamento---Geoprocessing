select avg(num_area_imovel), count (imovel.idt_imovel) from 
usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio where 
--num_modulo_fiscal <= 4 and
cod_estado = 'SC' and ind_status_imovel in ('AT', 'PE') and imovel.idt_municipio = municipio.idt_municipio
