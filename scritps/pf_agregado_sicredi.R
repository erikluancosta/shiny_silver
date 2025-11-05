source('conectar/conectar.R')

pf_sicredi <- dbGetQuery(
  con,
  "WITH base AS (
    SELECT
      g.cd_setor,
      g.area_tipo,
      o.cod_ua,
      o.classificacao_idade,
      o.sexo_final AS sexo
    FROM silver_pf_geo g
    LEFT JOIN silver_pf_o o ON g.id_associado = o.id_associado
    WHERE g.status_associado = 'ATIVO'
      AND g.estado_y IN ('TO','BA','MS') and o.estado_x in ('TO', 'BA', 'MS')
  )
  SELECT
    --cd_setor,
    b.cod_ua::numeric,
    sau.nome_cooperativa as nome_agencia,
    sau.uf_municipio as uf_agencia,
    sau.municipio_cooperativa  as municipio_cooperativa,
    b.area_tipo,
    b.classificacao_idade,
    b.sexo,
    COUNT(1) AS associados
  FROM base b
  LEFT JOIN silver_agencias_uniao sau on sau.cod_ua::numeric = b.cod_ua::numeric
  GROUP BY 1,2,3,4,5,6,7"
)

save(pf_sicredi, file = "dados/pf_sicredi.Rda")
