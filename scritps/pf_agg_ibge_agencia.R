source('conectar/conectar.R')

pf_agregados_ibge <- dbGetQuery(
  con,
"
select s.cod_ua, 
	   sau.nome_cooperativa, 
	   sau.municipio_cooperativa as municipio_agencia,
	   sau.uf_municipio as uf_agencia,
	   s.area_tipo,
	   s.classificacao_idade,
	   s.sexo,
	   sum(s.pop) as populacao
from silver_pf_area_influencia_det s
left join silver_agencias_uniao sau on sau.cod_ua::numeric = s.cod_ua::numeric 
group by 1, 2, 3, 4, 5, 6, 7;
")


save(pf_agregados_ibge, file = "dados/pf_agregados_ibge.Rda")
