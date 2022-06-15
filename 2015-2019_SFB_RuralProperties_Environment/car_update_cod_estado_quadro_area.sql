update relatorio.quadro_area set cod_uf = cod_estado from usr_geocar_aplicacao.imovel, usr_geocar_aplicacao.municipio
where quadro_area.idt_imovel = imovel.idt_imovel and imovel.idt_municipio = municipio.idt_municipio
