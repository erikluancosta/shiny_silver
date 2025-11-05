source('conectar/conectar.R')

# Base de dados agrupada por empresa
agg_rfb <- dbGetQuery(
  con,
  "select * from mv_empresas_canon_agg"
)

agg_empresas <- agg_rfb |> mutate(
  div_cnae = ifelse(div_cnae %in% agg_agencias$div_cnae, div_cnae, '99'
  )) |>
  group_by(municipio_cooperativa, uf_cooperativa, div_cnae, 
           area_influ, assoc_flag, porte_recriado, sexo_final,
           classificacao_socios) |> 
  summarise(
    freq = sum(empresas), .groups = 'drop'
  )


agg_empresas <- agg_empresas |> 
  mutate(
    sexo_final = case_when(
      sexo_final == 'M' ~ 'Masculino',
      sexo_final == 'F' ~ 'Feminino',
      TRUE ~ 'Indefinido'
    ),
    classificacao_socios = case_when(
      classificacao_socios == "Não classificado" ~ "Indefinido",
      classificacao_socios == "Não silver" ~ "Não-Silver",
      classificacao_socios == "Pré-silver" ~ "Pré-Silver",
      TRUE ~ classificacao_socios
    )
  )

save(agg_empresas, file = "dados/agg_empresas_rfb.Rda")


