
create table proc_sfb.cnfp_2_sigef_select as
 SELECT
   cnfp_sigef_cert_reg_tit_part.id,
   st_makevalid(cnfp_sigef_cert_reg_tit_part.geom),
   cnfp_sigef_cert_reg_tit_part.parcela_co,
   cnfp_sigef_cert_reg_tit_part.situacao_i,
   cnfp_sigef_cert_reg_tit_part.codigo_imo,
   cnfp_sigef_cert_reg_tit_part.status,
   "cnfp2019_Tipob_inicial".idcf
 FROM
   proc_sfb."cnfp2019_Tipob_inicial",
   proc_sfb.cnfp_sigef_cert_reg_tit_part
 WHERE
   st_intersects(st_makevalid("cnfp2019_Tipob_inicial".geom), st_makevalid(cnfp_sigef_cert_reg_tit_part.geom));
