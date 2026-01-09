options(bitmapType = "cairo")
library(DBI)
library(RPostgres)
library(tidyverse)
library(shiny)
library(bs4Dash)
library(ciTools)
library(vitaltable)
library(leaflet)
library(dplyr)
library(shinythemes)
library(janitor)
library(plotly)
library(reshape2)
library(forcats)
library(sf)
library(tidyr)
library(DT)
library(haven)
library(writexl)
library(fresh)
library(leaflet.extras)
library(shinymanager)
library(shinyWidgets)
library(colourpicker)
library(shinyjs)
library(bslib)
library(fontawesome)
library(tibble)

load('dados/silver_rfb.rda')

# filtrando o que interessa
silver <- silver |> 
  filter(
    status_associado_sicredi=="ATIVO",
    estado_associado %in% c('MS','TO','BA')
  )
# carregando a base de agências
agencias <- readxl::read_excel("dados/cooperativas_uniao_geo.xlsx")

# Ajustes no latlong
agencias <- agencias |> 
  mutate(
    Latitude=as.numeric(Latitude),
    Longitude=as.numeric(Longitude)
  )

# Complementando a base
silver <- silver |> 
  mutate(
    cod_ua = as.numeric(cod_ua)
  ) |> 
  left_join(agencias, by='cod_ua') 

# Diminuindo a base
silver<-silver |> 
  select(-Latitude, -Longitude, -contato) |> 
  mutate(sexo_final_sicredi = case_when(
    sexo_final_sicredi == "Ambos" ~ "Indefinido",
    TRUE ~ sexo_final_sicredi
  )) |> 
  rename("porte_recriado" = porte_recriado_rfb)


silver <- silver |> 
  mutate(
    porte_recriado = case_when(
      porte_padrao_sicredi == 'MEI' & is.na(porte_recriado) ~ 2,
      porte_padrao_sicredi == 'E1' & is.na(porte_recriado) ~ 1,
      porte_padrao_sicredi == 'E2' & is.na(porte_recriado) ~ 1,
      porte_padrao_sicredi == 'E3' & is.na(porte_recriado) ~ 3,
      porte_padrao_sicredi == 'E4' & is.na(porte_recriado) ~ 4,
      porte_padrao_sicredi == 'E5' & is.na(porte_recriado) ~ 6,
      TRUE ~ porte_recriado
    )
  )


# Camada dos raios
agencias_influencia <- readRDS("dados/agencias_influencia_completo.RDS")



# Bases para o índice de penetração
# visão agência
load('dados/agg_agencias_rfb.Rda')

# visão empresa
load('dados/agg_empresas_rfb.Rda')


####### PF
# Dados oriundos do sicredi
load('dados/pf_sicredi.Rda')

# Áreas de influência
agencias_influencia_pf <- readRDS('dados/agencias_influencia_completo_pf.RDS')


# Base agregada de PF no IBGE com agencia
load('dados/pf_agregados_ibge.Rda')

# Base agregada de PF no IBGE sem agencia
load('dados/pf_agregados_ibge_muni_uf.Rda')


renda <- readRDS('dados/pf_setores_renda.rds')

# DADOS DE APOSENTADORIA
aposentadoria <- readxl::read_excel('dados/aposentadoria_sicredi_uniao.xlsx')
