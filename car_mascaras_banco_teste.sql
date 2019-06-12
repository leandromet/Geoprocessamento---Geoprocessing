update portal_seguranca.pessoa
set nm_pessoa = left(nm_pessoa, 10),
    tx_cpf_cnpj = translate(tx_cpf_cnpj, '1,2', '*,.'),
	tx_email = translate(tx_email, 'm,b,c,e,i,o,u,r', 'a,a,a,a,a,a,a,a'),
	tx_telefone = translate(tx_telefone, '7,8,9,6', '1,1,1,1'),
	tx_celular = translate(tx_celular, '7,8,9,6', '1,1,1,1')
  
  update portal_seguranca.pessoa_fisica
set nm_mae = translate(nm_mae, 'm,b,c,e,i,o,u,r', 'a,a,a,a,a,a,a,a'),
    nm_conjuge = translate(nm_conjuge, 'm,b,c,e,i,o,u,r', 'a,a,a,a,a,a,a,a'),
	tx_cpf_conjuge = translate(tx_cpf_conjuge, '1,2', '*,.'),
	tx_rg = translate(tx_rg, '1,2', '*,.')
  
  
  update portal_seguranca.pessoa_juridica
set nm_fantasia = left(nm_fantasia, 10)


