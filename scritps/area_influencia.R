source('conectar/conectar.R')
library(sf)
# Lendo a tabela com geometrias
agencias_influencia <- st_read(con, query = "
  -- Calculando os raios da área de influência
WITH percentis AS (
    SELECT 
        sa.cod_ua,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY ST_Distance(
            ST_SetSRID(ST_MakePoint(ss.lon, ss.lat), 4326)::geography,
            sa.geometry::geography
        )) / 1000 AS dist_50km,
        percentile_cont(0.9) WITHIN GROUP (ORDER BY ST_Distance(
            ST_SetSRID(ST_MakePoint(ss.lon, ss.lat), 4326)::geography,
            sa.geometry::geography
        )) / 1000 AS dist_90km
    FROM sicredi_silver_t ss
    LEFT JOIN silver_agencias_uniao sa 
        ON ss.cod_ua::numeric = sa.cod_ua::numeric
    where ss.status_associado ='ATIVO' and
    ss.estado_y in ('MS','TO','BA')
    GROUP BY sa.cod_ua
)
-- Cria os buffers a partir da geometria da agência
SELECT 
    sa.cod_ua,
    sa.geometry,
    sa.nome_cooperativa,
    p.dist_50km,
    p.dist_90km,
    ST_Buffer(sa.geometry::geography, p.dist_50km * 1000)::geometry AS area_influencia_50km,
    ST_Buffer(sa.geometry::geography, p.dist_90km * 1000)::geometry AS area_influencia_90km
FROM silver_agencias_uniao sa
JOIN percentis p 
    ON sa.cod_ua::numeric = p.cod_ua::numeric;
")


library(leaflet)
library(sf)

leaflet() |>
  addTiles() |>
  addPolygons(
    data = agencias_influencia |> st_set_geometry("area_influencia_90km"),
    color = "red", weight = 1, fillOpacity = 0.2, group = "90 km"
  ) |>
  addPolygons(
    data = agencias_influencia |> st_set_geometry("area_influencia_50km"),
    color = "blue", weight = 1, fillOpacity = 0.3, group = "50 km"
  ) |>
  addCircleMarkers(
    data = agencias_influencia |> st_set_geometry("geometry"),
    radius = 3, color = "black", group = "Agências"
  ) |>
  addLayersControl(
    overlayGroups = c("90 km", "50 km", "Agências"),
    options = layersControlOptions(collapsed = FALSE)
  )

saveRDS(agencias_influencia, "dados/agencias_influencia_completo.RDS")


