source('conectar/conectar.R')

silver <- dbGetQuery(con,
  "
  -- BASE SICREDI INCREMENTADA COM RECEITA FEDERAL
-- 1) Associados filtrados (para cálculo dos percentis)
WITH pontos AS (
  SELECT
    ss.*,
    ST_SetSRID(ST_MakePoint(ss.lon, ss.lat), 4326)::geography AS geom_ponto
  FROM sicredi_silver_t ss
  WHERE ss.status_associado = 'ATIVO'
    AND ss.estado_y IN ('MS','TO','BA')
),
-- 2) Agências (geography para distâncias/buffer em metros)
agencias AS (
  SELECT
    sa.cod_ua,
    sa.geometry,
    sa.geometry::geography AS geom_agencia
  FROM silver_agencias_uniao sa
),
-- 3) Distâncias (km) de cada associado para sua agência
dists AS (
  SELECT
    a.cod_ua,
    ST_Distance(p.geom_ponto, a.geom_agencia) / 1000.0 AS dist_km
  FROM pontos p
  JOIN agencias a
    ON p.cod_ua::numeric = a.cod_ua::numeric
),
-- 4) Percentis por agência
percentis AS (
  SELECT
    cod_ua,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY dist_km) AS dist_50km,
    percentile_cont(0.9) WITHIN GROUP (ORDER BY dist_km) AS dist_90km
  FROM dists
  GROUP BY cod_ua
),
-- 5) Buffers por agência (P50 e P90) gerados a partir da geometria da agência
buffers AS (
  SELECT
    a.cod_ua,
    a.geometry,  -- geometry original da agência
    p.dist_50km,
    p.dist_90km,
    ST_Buffer(a.geom_agencia, p.dist_50km * 1000)::geometry AS area_influencia_50km,
    ST_Buffer(a.geom_agencia, p.dist_90km * 1000)::geometry AS area_influencia_90km
  FROM agencias a
  JOIN percentis p USING (cod_ua)
),
-- 6) Base SICREDI com chaves de CNPJ (como na sua query original)
ss_base AS (
  SELECT
    ss.*,
    SUBSTRING(ss.cnpj_associado FROM 1 FOR 8) AS cnpj_basico,
    SUBSTRING(ss.cnpj_associado FROM 9 FOR 4) AS cnpj_ordem,
    SUBSTRING(ss.cnpj_associado FROM 13 FOR 2) AS cnpj_dv,
    ST_SetSRID(ST_MakePoint(ss.lon, ss.lat), 4326) AS geom_pt -- geometry (não geography) p/ ST_Intersects
  FROM sicredi_silver_t ss
)
-- 7) SELECT final com RFB + classificação da área de influência + distância em km
SELECT 
    ss.cnpj_associado,
    em.natureza_juridica AS nat_ju_rfb,
    em.capital_social AS capital_social_rfb,
    em.porte_empresa AS porte_empresa_rfb,
    sc.porte_recriado as porte_recriado_rfb,
    ss.porte_padrao AS porte_padrao_sicredi,
    ss.status_associado AS status_associado_sicredi,
    ss.nom_associado AS nom_associado_sicredi,
    em.razao_social as razao_social_rfb,
    es.nome_fantasia as nome_fantasia_rfb,
    ss.nivel_risco AS nivel_risco_sicredi,
    ss.publico_estrategico AS publico_estrategico_sicredi,
    ss.isa AS isa_sicredi,
    ss.cod_ua::numeric,
    ss.faixa_principalidade AS faixa_principalidade_sicredi,
    ss.ultimo_contato AS ultimo_contato_sicredi,
    ss.estado_x AS estado_agencia,
    ss.municipio_x AS municipio_agencia,
    ss.sistema_abertura_conta AS sistema_abertura_conta_sicredi,
    ss.endereco AS endereco_associado,
    ss.numero AS numero_associado,
    ss.bairro AS bairro_associado,
    ss.municipio_y AS municipio_associado,
    ss.cep AS cep_associado,
    ss.estado_y AS estado_associado,
    ss.lat AS latitude_associado,
    ss.lon AS longitude_associado,
    ss.precisao AS precisao_associado,
    ss.sexo_final AS sexo_final_sicredi,
    sc.sexo_final as sexo_final_rfb,
    ss.predominancia AS predominancia_sicredi,
    ss.tempo_relacionamento AS tempo_relacionamento_sicredi,
    es.situacao_cadastral AS situacao_cadastral_rfb,
    es.motivo_situacao_cadastral AS motivo_situacao_cadastral_rfb,
    es.data_situacao_cadastral AS data_situacao_cadastral_rfb,
    es.data_inicio_atividade AS data_inicio_atividade_rfb,
    es.cnae_fiscal_principal AS cnae_rfb,
    es.ddd_1 as ddd_1_rfb,
    es.telefone_1 as telefone_1_rfb,
    es.correio_eletronico as email_rfb,
    TRIM(es.tipo_logradouro || ' ' || es.logradouro) AS endereco_rfb,
    es.numero AS numero_rfb,
    es.complemento AS complemento_rfb,
    es.bairro AS bairro_rfb,
    es.cep::numeric AS cep_rfb,
    es.uf AS uf_rfb,
    mc.cd_mun_7 as cd_ibge_rfb,
    mc.descricao_ibge as muni_ibge_rfb,
    sc.classificacao_socios as idade_rfb,  
    ss.idade_classificada AS idade_sicredi,
    -- Classificação da área de influência
    CASE
      WHEN COALESCE(ST_Intersects(b.area_influencia_50km, ss.geom_pt), false) THEN 'P'
      WHEN COALESCE(ST_Intersects(b.area_influencia_90km, ss.geom_pt), false) THEN 'S'
      ELSE 'F'
    END AS area_influ,
    -- Distância reta (km) do associado até a agência
    ST_Distance(ss.geom_pt::geography, a.geom_agencia) / 1000.0 AS distancia_percorrida
FROM ss_base ss
LEFT JOIN estabelecimento es
  ON ss.cnpj_basico = es.cnpj_basico
 AND ss.cnpj_ordem  = es.cnpj_ordem
 AND ss.cnpj_dv     = es.cnpj_dv
LEFT JOIN empresa em
  ON ss.cnpj_basico = em.cnpj_basico
LEFT JOIN munic_comp mc
  ON es.municipio = mc.codigo
LEFT JOIN quali_cnpj qc
  ON qc.cnpj_basico = es.cnpj_basico
LEFT JOIN silver_cnpjs_porte_recriado sc 
  ON ss.cnpj_associado = sc.cnpj 
-- junta geometrias da agência para distância
LEFT JOIN agencias a
  ON ss.cod_ua::numeric = a.cod_ua::numeric
-- junta buffers calculados no voo
LEFT JOIN buffers b
  ON ss.cod_ua::numeric = b.cod_ua::numeric;
                     ")

silver |> filter(is.na(latitude_associado)) |> nrow()

save(silver, file = "dados/silver_rfb.rda")

