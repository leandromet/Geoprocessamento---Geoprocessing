--GPL Leandro Biondo 2016

---find duplicated lines

select o.gid from sfb_topo.mt_iru o
 where exists ( select 'x' 
                  from sfb_topo.mt_iru  i
                 where 
                   i.idt_imovel = o.idt_imovel and
                   i.gid < o.gid
             );

--remove them


--delete from sfb_topo.mt_iru
--  where exists ( select 'x' 
--                  from sfb_topo.mt_iru i
--                 where i.idt_imovel = sfb_topo.mt_iru.idt_imovel
--                   and i.gid > sfb_topo.mt_iru.gid
--             );
