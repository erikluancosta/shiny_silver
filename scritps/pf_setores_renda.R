source('conectar/conectar.R')
library(sf)

renda <- st_read(
  con,
  query="WITH buf AS (
  SELECT
    ST_UnaryUnion(
      ST_Collect(
        ST_MakeValid(ST_Transform(buffer_50pf, 4326))
      )
    ) AS geom
  FROM silver_agencias_uniao
),
setores AS (
  SELECT
      bsc.cd_setor,
      bsc.cd_mun,
      mc.descricao_ibge,
      mc.uf,
      bsc.situacao,
      bsc.nm_aglom,
      srri.num_pess_respon,
      srri.num_moradores,
      srri.media_renda_mensal,
      srri.\"Desv_pad\" AS desv_pad,
      srri.\"Desv_pad\" / NULLIF(srri.media_renda_mensal, 0) AS coef_variacao_renda,
      ST_MakeValid(ST_Transform(bsc.geom, 4326)) AS geom
  FROM \"BR_setores_CD2022\" bsc
  LEFT JOIN silver_renda_responsavel_ibge srri
    ON srri.cd_setor = bsc.cd_setor
	LEFT JOIN munic_comp mc
  ON substring(bsc.cd_setor::text, 1, 7) = mc.cd_mun_7::text
)
SELECT
    s.cd_setor,
    s.cd_mun,
    s.descricao_ibge,
    s.uf,
    s.situacao,
    s.nm_aglom,
    s.num_pess_respon,
    s.num_moradores,
    s.media_renda_mensal,
    s.desv_pad,
    s.coef_variacao_renda,
    s.geom
FROM setores s
CROSS JOIN buf b
WHERE
  ST_Intersects(s.geom, b.geom)
  AND (
    ST_Area(ST_Intersection(s.geom, b.geom)::geography)
    /
    NULLIF(ST_Area(s.geom::geography), 0)
  ) >= 0.5;")


# Salvar o shapefile em RDS
saveRDS(renda, file = "dados/pf_setores_renda.rds")



library(dplyr)
library(leaflet)

renda <- st_transform(renda, 4326)

# variáveis "capadas" só para cor
renda <- renda %>%
  mutate(
    renda_cap = pmin(media_renda_mensal, 20000),
    cv_cap    = pmin(coef_variacao_renda, 6)
  )

# paletas com limites fixos
pal_renda <- colorNumeric(
  palette = "Blues",
  domain  = c(0, 20000),
  na.color = "#00000000"
)

pal_cv <- colorNumeric(
  palette = "YlOrRd",
  domain  = c(0, 6),
  na.color = "#00000000"
)

# labels
renda <- renda %>%
  mutate(
    renda_txt = ifelse(is.na(media_renda_mensal), "NA",
                       paste0("R$ ", format(round(media_renda_mensal, 0),
                                            big.mark = ".", decimal.mark = ","))),
    cv_txt = ifelse(is.na(coef_variacao_renda), "NA",
                    sprintf("%.2f", coef_variacao_renda)),
    label = paste0(
      "Setor: ", cd_setor,
      "<br>Mun: ", cd_mun,
      "<br>Renda média: ", renda_txt,
      "<br>Coef. variação: ", cv_txt,
      "<br>Moradores: ", ifelse(is.na(num_moradores), "NA", num_moradores)
    )
  )

leaflet(renda) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  
  # Desigualdade
  addPolygons(
    group = "Desigualdade (coef. variação)",
    fillColor = ~pal_cv(cv_cap),
    fillOpacity = 0.7,
    color = "#444444", weight = 0.2,
    popup = ~label
  ) %>%
  addLegend(
    pal = pal_cv,
    values = c(0, 6),
    title = "Coef. variação (0–6)",
    position = "bottomright",
    group = "Desigualdade (coef. variação)"
  ) %>%
  
  # Renda média
  addPolygons(
    group = "Renda média (R$)",
    fillColor = ~pal_renda(renda_cap),
    fillOpacity = 0.7,
    color = "#444444", weight = 0.2,
    popup = ~label
  ) %>%
  addLegend(
    pal = pal_renda,
    values = c(0, 20000),
    title = "Renda média mensal (R$)",
    position = "bottomleft",
    group = "Renda média (R$)"
  ) %>%
  
  addLayersControl(
    overlayGroups = c("Desigualdade (coef. variação)", "Renda média (R$)"),
    options = layersControlOptions(collapsed = FALSE)
  )

