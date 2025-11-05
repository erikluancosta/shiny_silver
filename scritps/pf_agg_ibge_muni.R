source('conectar/conectar.R')

pf_agg_ibge_muni <- dbGetQuery(
  con,
  "
select sau.municipio_cooperativa as municipio_agencia,
	   sau.uf_municipio as uf_agencia, 
	   s.area_influ, ssc.classificacao_idade,
	   ssc.sexo,
	   sum(freq) as populacao
from \"BR_setores_CD2022\" s 
left join silver_setor_censitario ssc on ssc.cd_setor = s.cd_setor 
left join silver_agencias_uniao sau on s.cod_ua_ref = sau.cod_ua
where area_influ is not null
group by 1,2,3,4,5

")


save(pf_agg_ibge_muni, file = "dados/pf_agregados_ibge_muni_uf.Rda")

