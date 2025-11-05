source('conectar/conectar.R')
library(sf)
# Lendo a tabela com geometrias
area_influencia_pf <- st_read(con, query = "
    SELECT cod_ua, 
           nome_cooperativa,
           municipio_cooperativa as municipio_agencia,
           uf_municipio as uf_agencia,
           dist_50pf, 
           dist_90pf, 
           geometry,
           buffer_50pf, 
           buffer_90pf
    FROM silver_agencias_uniao where cod_ua is not null
    ")



# buffer 90 (p90)
area_influencia_pf <- area_influencia_pf |>
  st_set_geometry("buffer_90pf") |>
  st_make_valid() |>
  st_transform(4326) 

# buffer 50 (mediana)
area_influencia_pf <- area_influencia_pf |>
  st_set_geometry("buffer_50pf") |>
  st_make_valid() |>
  st_transform(4326) 

# pontos das agências
area_influencia_pf <- area_influencia_pf |>
  st_set_geometry("geometry") |>
  st_transform(4326) 


leaflet() |>
  addTiles() |>
  addPolygons(
    data = area_influencia_pf |> st_set_geometry("buffer_90pf"),
    color = "red", weight = 1, fillOpacity = 0.2, group = "90 km"
  ) |>
  addPolygons(
    data = area_influencia_pf |> st_set_geometry("buffer_50pf"),
    color = "blue", weight = 1, fillOpacity = 0.3, group = "50 km"
  ) |>
  addCircleMarkers(
    data = area_influencia_pf |> st_set_geometry("geometry"),
    radius = 3, color = "black", group = "Agências"
  ) |>
  addLayersControl(
    overlayGroups = c("90 km", "50 km", "Agências"),
    options = layersControlOptions(collapsed = FALSE)
  )

saveRDS(area_influencia_pf, "dados/agencias_influencia_completo_pf.RDS")
