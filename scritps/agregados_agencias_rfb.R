source('conectar/conectar.R')

# Base de dados agrupada por empresa
agg_agencias <- dbGetQuery(
  con,
  "
select sau.nome_cooperativa,agg.* from mv_agencias_canon_agg agg
 left join silver_agencias_uniao sau on agg.cod_ua = sau.cod_ua 
")


agg_agencias <- agg_agencias |> 
  mutate(
    sexo_me = case_when(
      sexo_me == 'M' ~ 'Masculino',
      sexo_me == 'F' ~ 'Feminino',
      TRUE ~ 'Indefinido'
    ),
    grupo_etario = case_when(
      grupo_etario == "Não classificado" ~ "Indefinido",
      grupo_etario == "Não silver" ~ "Não-Silver",
      grupo_etario == "Pré-silver" ~ "Pré-Silver",
      TRUE ~ grupo_etario
    )
  ) |> 
  rename(
    "classificacao_socios" = grupo_etario
  )
    
save(agg_agencias, file = "dados/agg_agencias_rfb.Rda")


silver$sexo_final_sicredi
