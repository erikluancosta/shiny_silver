# =========================================================
# UI — Análises Gerais (Rankings PF & PJ, sem mapa)
# =========================================================
geral_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    shinyjs::useShinyjs(),
    
    # ---------- estilos ----------
    tags$style(HTML(paste0("
      /* Cards iguais (flex) */
      #", ns("kpi_wrap"), "{
        display:flex; gap:14px; align-items:stretch; margin-bottom:10px;
      }
      #", ns("kpi_wrap"), " .kpi-card{
        flex:1; background:#fff; border-left:5px solid #6fc836; border-radius:10px;
        box-shadow:0 2px 12px rgba(0,0,0,0.15); padding:14px 16px; display:flex; gap:12px; align-items:center;
      }
      .kpi-icon{ font-size:24px; color:#6fc836; }
      .kpi-title{ font-size:13px; color:#444; font-weight:600; margin-bottom:2px; }
      .kpi-value{ font-size:22px; color:#30660c; font-weight:800; line-height:1; }
      .kpi-sub{ font-size:12px; color:#666; }

      /* controles */
      #", ns("filtro_card"), " .form-group{ margin-bottom:10px; }
      #", ns("rank_card"), " .card-body{ padding-top:10px; }
      .rank-controls .form-group{ margin-bottom:8px; }
    "))),
    
    # ---------- filtros ----------
    bs4Dash::bs4Card(
      id = ns("filtro_card"), title = "Parâmetros da análise",
      status = "primary", collapsible = TRUE, width = 12,
      fluidRow(
        column(
          2,
          radioButtons(
            ns("segmento"), "Segmento:",
            choices = c("Pessoa Jurídica"="PJ","Pessoa Física"="PF"),
            selected = "PJ", inline = TRUE
          )
        ),
        column(2, uiOutput(ns("ui_uf"))),
        column(3, uiOutput(ns("ui_municipio"))),
        column(3, uiOutput(ns("ui_agencia"))),
        column(
          2,
          selectInput(
            ns("filtro_area"), "Área de influência:",
            choices  = c("Primária"="P","Secundária"="S"),
            selected = c("P","S"), multiple = TRUE
          )
        )
      ),
      fluidRow(
        column(3, uiOutput(ns("ui_sexo"))),
        column(3, uiOutput(ns("ui_etario"))),
        column(
          6,
          conditionalPanel(
            condition = sprintf("input['%s'] == 'PJ'", ns("segmento")),
            selectInput(
              ns("filtro_porte"), "Porte da empresa (PJ):",
              choices  = c("MEI"="2","Micro"="1","Pequeno Porte"="3","Média"="4","Grande"="6"),
              selected = c("2","1","3","4","6"), multiple = TRUE
            )
          )
        )
      )
    ),
    
    # ---------- KPIs (todos iguais) ----------
    div(
      id = ns("kpi_wrap"),
      div(class="kpi-card",
          icon("users", class="kpi-icon"),
          div(div("Associados", class="kpi-title"), div(textOutput(ns("kpi_associados")), class="kpi-value"))
      ),
      div(class="kpi-card",
          icon("id-card", class="kpi-icon"),
          div(div("Universo", class="kpi-title"), div(textOutput(ns("kpi_universo")), class="kpi-value"))
      ),
      div(class="kpi-card",
          icon("percent", class="kpi-icon"),
          div(div("Penetração (%)", class="kpi-title"), div(textOutput(ns("kpi_penetracao")), class="kpi-value"))
      ),
      div(class="kpi-card",
          icon("bullseye", class="kpi-icon"),
          div(div("Raio P (km)", class="kpi-title"), div(textOutput(ns("kpi_raio_p")), class="kpi-value"), div("Média", class="kpi-sub"))
      ),
      div(class="kpi-card",
          icon("crosshairs", class="kpi-icon"),
          div(div("Raio S (km)", class="kpi-title"), div(textOutput(ns("kpi_raio_s")), class="kpi-value"), div("Média", class="kpi-sub"))
      )
    ),
    
    # ---------- ranking ----------
    bs4Dash::bs4Card(
      id = ns("rank_card"), title = "Ranking por agência",
      status = "secondary", width = 12,
      fluidRow(
        class = "rank-controls",
        column(3, selectInput(
          ns("rank_metric"), "Ordenar por:",
          choices = c("Gap (Universo − Associados)"="gap",
                      "Penetração (%)"="pen",
                      "Associados (Total)"="assoc",
                      "Universo (Total)"="univ",
                      "Raio Primário (km)"="raio_p",
                      "Raio Secundário (km)"="raio_s"),
          selected = "gap")),
        # >>> ALTERADO: Top N de 0 a 50
        column(3, sliderInput(ns("top_n"), "Top N:", min=0, max=50, value=20, step=1, width="100%"))
      ),
      DT::dataTableOutput(ns("tabela_agencia"))
    ),
    
    bs4Dash::bs4Card(
      title = "Top oportunidades (Gap) – gráfico",
      status = "warning", width = 12,
      plotly::plotlyOutput(ns("grafico_top"), height = "420px")
    )
  )
}

# =========================================================
# SERVER — Análises Gerais
# =========================================================
geral_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    requireNamespace("dplyr"); requireNamespace("tidyr"); requireNamespace("tibble")
    requireNamespace("DT"); requireNamespace("plotly"); requireNamespace("sf")
    
    or_default <- function(x, default) if (is.null(x)) default else x
    fmt_int <- function(x) format(as.integer(x), big.mark=".", decimal.mark=",")
    fmt_num <- function(x, digs=1) format(round(x, digs), big.mark=".", decimal.mark=",")
    
    make_univ_base <- function(df){
      if (is.null(df) || nrow(df) == 0) return(numeric(0))
      v <- if ("empresas_distintas" %in% names(df)) df$empresas_distintas
      else if ("freq" %in% names(df))               df$freq
      else if ("n" %in% names(df))                  df$n
      else rep(0, nrow(df))
      as.numeric(v)
    }
    
    # ---------- metadados das agências e raios ----------
    agencias_meta <- reactive({
      if (identical(input$segmento, "PJ")) {
        if (!exists("agencias")) return(tibble::tibble(cod_ua=integer(), agencia=character(), uf=character(), municipio=character(), dist_p_km=numeric(), dist_s_km=numeric()))
        meta <- agencias |>
          dplyr::transmute(cod_ua, agencia = nome_cooperativa, uf = uf_municipio, municipio = municipio_cooperativa)
        if (exists("agencias_influencia")) {
          dist <- sf::st_drop_geometry(agencias_influencia) |>
            dplyr::select(cod_ua, dist_50km, dist_90km) |>
            dplyr::group_by(cod_ua) |>
            dplyr::summarise(dist_p_km = dplyr::first(dist_50km), dist_s_km = dplyr::first(dist_90km), .groups = "drop")
          meta <- dplyr::left_join(meta, dist, by = "cod_ua")
        } else { meta$dist_p_km <- NA_real_; meta$dist_s_km <- NA_real_ }
        return(meta)
      } else {
        if (!exists("agencias_influencia_pf")) return(tibble::tibble(cod_ua=integer(), agencia=character(), uf=character(), municipio=character(), dist_p_km=numeric(), dist_s_km=numeric()))
        base <- sf::st_drop_geometry(agencias_influencia_pf)
        tibble::tibble(
          cod_ua = base$cod_ua, agencia = base$nome_cooperativa,
          uf = base$uf_agencia, municipio = base$municipio_agencia,
          dist_p_km = base$dist_50pf, dist_s_km = base$dist_90pf
        )
      }
    })
    
    # ---------- UI dinâmico ----------
    output$ui_uf <- renderUI({
      meta <- agencias_meta(); selectInput(ns("filtro_uf"), "UF:", choices = c("Todos", sort(unique(meta$uf))), selected = "Todos")
    })
    output$ui_municipio <- renderUI({
      base <- agencias_meta()
      if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos") base <- dplyr::filter(base, uf == input$filtro_uf)
      selectInput(ns("filtro_municipio"), "Município:", choices = c("Todos", sort(unique(base$municipio))), selected = "Todos")
    })
    output$ui_agencia <- renderUI({
      base <- agencias_meta()
      if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos") base <- dplyr::filter(base, uf == input$filtro_uf)
      if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos") base <- dplyr::filter(base, municipio == input$filtro_municipio)
      base <- dplyr::arrange(base, agencia)
      selectInput(ns("filtro_agencia"), "Agência:", choices = c("Todos"="Todos", stats::setNames(base$cod_ua, base$agencia)), selected = "Todos")
    })
    output$ui_sexo <- renderUI({
      if (identical(input$segmento, "PJ"))
        selectInput(ns("filtro_sexo"), "Sexo:", choices = c("Todos","Feminino","Masculino","Indefinido"), selected = "Todos")
      else
        selectInput(ns("filtro_sexo"), "Sexo:", choices = c("Todos","Feminino","Masculino"), selected = "Todos")
    })
    output$ui_etario <- renderUI({
      if (identical(input$segmento, "PJ"))
        selectInput(ns("filtro_categoria"), "Grupo etário:", choices = c("Todas","Silver","Pré-Silver","Não-Silver","Indefinido"), selected = "Todas")
      else
        selectInput(ns("filtro_categoria"), "Grupo etário:", choices = c("Todas","Silver","Pré-Silver","Não-Silver"), selected = "Todas")
    })
    
    # ---------- filtros comuns ----------
    meta_filtrada <- reactive({
      base <- agencias_meta()
      if (nrow(base) == 0) return(base)
      if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos") base <- dplyr::filter(base, uf == input$filtro_uf)
      if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos") base <- dplyr::filter(base, municipio == input$filtro_municipio)
      if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos") base <- dplyr::filter(base, cod_ua == as.numeric(input$filtro_agencia))
      base
    })
    
    # ---------- associados por UA/área (para tabela e KPIs) ----------
    associados_ua_area <- reactive({
      areas_sel <- or_default(input$filtro_area, c("P","S"))
      if (identical(input$segmento, "PJ")) {
        if (!exists("silver")) return(dplyr::tibble(cod_ua=integer(), area=character(), associados=integer()))
        df <- silver
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_municipio" %in% names(df)) df <- dplyr::filter(df, uf_municipio == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) df <- dplyr::filter(df, municipio_cooperativa == input$filtro_municipio)
        if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos" && "cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo_final_sicredi" %in% names(df)) df <- dplyr::filter(df, sexo_final_sicredi == input$filtro_sexo)
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "idade_sicredi" %in% names(df)) df <- dplyr::filter(df, idade_sicredi == input$filtro_categoria)
        if (!is.null(input$filtro_porte) && length(input$filtro_porte) > 0 && "porte_recriado" %in% names(df)) df <- dplyr::filter(df, porte_recriado %in% as.integer(input$filtro_porte))
        if ("area_influ" %in% names(df)) df <- dplyr::filter(df, area_influ %in% areas_sel)
        if (nrow(df) == 0) return(dplyr::tibble(cod_ua=integer(), area=character(), associados=integer()))
        df |>
          dplyr::group_by(cod_ua, area = area_influ) |>
          dplyr::summarise(associados = dplyr::n(), .groups = "drop")
      } else {
        if (!exists("pf_sicredi")) return(dplyr::tibble(cod_ua=integer(), area=character(), associados=integer()))
        df <- pf_sicredi
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_agencia" %in% names(df)) df <- dplyr::filter(df, uf_agencia == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) df <- dplyr::filter(df, municipio_cooperativa == input$filtro_municipio)
        if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos" && "cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo" %in% names(df)) df <- dplyr::filter(df, sexo == input$filtro_sexo)
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_idade" %in% names(df)) df <- dplyr::filter(df, classificacao_idade == input$filtro_categoria)
        if ("area_tipo" %in% names(df)) df <- dplyr::filter(df, area_tipo %in% areas_sel)
        if (nrow(df) == 0) return(dplyr::tibble(cod_ua=integer(), area=character(), associados=integer()))
        df |>
          dplyr::group_by(cod_ua, area = area_tipo) |>
          dplyr::summarise(associados = sum(associados, na.rm = TRUE), .groups = "drop")
      }
    })
    
    # ---------- universo por UA/área (para tabela) ----------
    universo_ua_area <- reactive({
      areas_sel <- or_default(input$filtro_area, c("P","S"))
      if (identical(input$segmento, "PJ")) {
        if (!exists("agg_agencias")) return(dplyr::tibble(cod_ua=integer(), area=character(), universo=integer()))
        df <- agg_agencias
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_cooperativa" %in% names(df)) df <- dplyr::filter(df, uf_cooperativa == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) df <- dplyr::filter(df, municipio_cooperativa == input$filtro_municipio)
        if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos" && "cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo_me" %in% names(df)) df <- dplyr::filter(df, sexo_me == input$filtro_sexo)
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_socios" %in% names(df)) df <- dplyr::filter(df, classificacao_socios == input$filtro_categoria)
        if (!is.null(input$filtro_porte) && length(input$filtro_porte) > 0 && "porte_recriado" %in% names(df)) df <- dplyr::filter(df, porte_recriado %in% as.integer(input$filtro_porte))
        if ("area_tipo" %in% names(df)) df <- dplyr::filter(df, area_tipo %in% areas_sel)
        if (nrow(df) == 0) return(dplyr::tibble(cod_ua=integer(), area=character(), universo=integer()))
        df[["__univ__"]] <- make_univ_base(df)
        df |>
          dplyr::group_by(cod_ua, area = area_tipo) |>
          dplyr::summarise(universo = sum(`__univ__`, na.rm = TRUE), .groups = "drop")
      } else {
        if (!exists("pf_agregados_ibge")) return(dplyr::tibble(cod_ua=integer(), area=character(), universo=integer()))
        df <- pf_agregados_ibge
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_agencia" %in% names(df)) df <- dplyr::filter(df, uf_agencia == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_agencia" %in% names(df)) df <- dplyr::filter(df, municipio_agencia == input$filtro_municipio)
        if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos" && "cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo" %in% names(df)) df <- dplyr::filter(df, sexo == input$filtro_sexo)
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_idade" %in% names(df)) df <- dplyr::filter(df, classificacao_idade == input$filtro_categoria)
        if ("area_tipo" %in% names(df)) df <- dplyr::filter(df, area_tipo %in% or_default(input$filtro_area, c("P","S")))
        if (nrow(df) == 0) return(dplyr::tibble(cod_ua=integer(), area=character(), universo=integer()))
        df |>
          dplyr::group_by(cod_ua, area = area_tipo) |>
          dplyr::summarise(universo = sum(populacao, na.rm = TRUE), .groups = "drop")
      }
    })
    
    # ---------- medidas por agência (para ranking) ----------
    medidas_agencia <- reactive({
      meta <- meta_filtrada()
      assoc <- associados_ua_area()
      univ  <- universo_ua_area()
      
      assoc_w <- tidyr::pivot_wider(assoc, names_from = area, values_from = associados, values_fill = 0)
      names(assoc_w) <- gsub("^P$", "assoc_P", names(assoc_w)); names(assoc_w) <- gsub("^S$", "assoc_S", names(assoc_w))
      univ_w  <- tidyr::pivot_wider(univ,  names_from = area, values_from = universo,  values_fill = 0)
      names(univ_w)  <- gsub("^P$", "univ_P",  names(univ_w)); names(univ_w)  <- gsub("^S$", "univ_S",  names(univ_w))
      
      df <- meta |>
        dplyr::left_join(assoc_w, by="cod_ua") |>
        dplyr::left_join(univ_w,  by="cod_ua")
      
      for (nm in c("assoc_P","assoc_S","univ_P","univ_S")) { if (!nm %in% names(df)) df[[nm]] <- 0; df[[nm]][is.na(df[[nm]])] <- 0 }
      
      df |>
        dplyr::mutate(
          assoc_total = assoc_P + assoc_S,
          univ_total  = univ_P  + univ_S,
          pen = dplyr::if_else(univ_total > 0, 100 * assoc_total / univ_total, 0),
          gap = pmax(univ_total - assoc_total, 0)
        )
    })
    
    # ---------- KPIs ----------
    output$kpi_associados <- renderText({
      df <- associados_ua_area(); fmt_int(sum(df$associados, na.rm = TRUE))
    })
    
    universo_kpi <- reactive({
      areas_sel <- or_default(input$filtro_area, c("P","S"))
      
      if (identical(input$segmento, "PJ")) {
        ag_sel <- isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos"
        if (ag_sel) {
          if (!exists("agg_agencias")) return(0L)
          df <- agg_agencias
          if (!is.null(input$filtro_agencia) && input$filtro_agencia != "Todos" && "cod_ua" %in% names(df))
            df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        } else {
          if (!exists("agg_empresas")) return(0L)
          df <- agg_empresas
        }
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_cooperativa" %in% names(df)) df <- dplyr::filter(df, uf_cooperativa == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) df <- dplyr::filter(df, municipio_cooperativa == input$filtro_municipio)
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && ("sexo_me" %in% names(df) || "sexo_final" %in% names(df))) {
          col <- intersect(c("sexo_me","sexo_final"), names(df))[1]
          df <- dplyr::filter(df, .data[[col]] == input$filtro_sexo)
        }
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_socios" %in% names(df)) df <- dplyr::filter(df, classificacao_socios == input$filtro_categoria)
        if (!is.null(input$filtro_porte) && length(input$filtro_porte) > 0 && "porte_recriado" %in% names(df)) df <- dplyr::filter(df, porte_recriado %in% as.integer(input$filtro_porte))
        if ("area_tipo" %in% names(df)) df <- dplyr::filter(df, area_tipo %in% areas_sel)
        df[["__u__"]] <- make_univ_base(df)
        sum(df[["__u__"]], na.rm = TRUE)
        
      } else {
        ag_sel <- isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos"
        if (ag_sel) {
          if (!exists("pf_agregados_ibge")) return(0L)
          df <- pf_agregados_ibge
          if ("cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(input$filtro_agencia))
        } else {
          if (!exists("pf_agg_ibge_muni")) return(0L)
          df <- pf_agg_ibge_muni
        }
        if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_agencia" %in% names(df)) df <- dplyr::filter(df, uf_agencia == input$filtro_uf)
        if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_agencia" %in% names(df)) df <- dplyr::filter(df, municipio_agencia == input$filtro_municipio)
        if (!is.null(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo" %in% names(df)) df <- dplyr::filter(df, sexo == input$filtro_sexo)
        if (!is.null(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_idade" %in% names(df)) df <- dplyr::filter(df, classificacao_idade == input$filtro_categoria)
        if ("area_tipo" %in% names(df))  df <- dplyr::filter(df, area_tipo  %in% areas_sel)
        if ("area_influ" %in% names(df)) df <- dplyr::filter(df, area_influ %in% areas_sel)
        if ("populacao" %in% names(df)) sum(df$populacao, na.rm = TRUE) else 0L
      }
    })
    
    output$kpi_universo <- renderText({ fmt_int(universo_kpi()) })
    
    output$kpi_penetracao <- renderText({
      num <- sum(associados_ua_area()$associados, na.rm = TRUE)
      den <- universo_kpi()
      if (!is.finite(den) || den <= 0) return("0,0")
      fmt_num(100 * num / den)
    })
    
    output$kpi_raio_p <- renderText({ fmt_num(mean(meta_filtrada()$dist_p_km, na.rm = TRUE)) })
    output$kpi_raio_s <- renderText({ fmt_num(mean(meta_filtrada()$dist_s_km, na.rm = TRUE)) })
    
    # ---------- Tabela (com Excel configurado) ----------
    output$tabela_agencia <- DT::renderDataTable({
      df <- medidas_agencia()
      ord <- switch(input$rank_metric,
                    "gap"    = dplyr::arrange(df, dplyr::desc(gap)),
                    "pen"    = dplyr::arrange(df, dplyr::desc(pen)),
                    "assoc"  = dplyr::arrange(df, dplyr::desc(assoc_total)),
                    "univ"   = dplyr::arrange(df, dplyr::desc(univ_total)),
                    "raio_p" = dplyr::arrange(df, dplyr::desc(dist_p_km)),
                    "raio_s" = dplyr::arrange(df, dplyr::desc(dist_s_km)),
                    dplyr::arrange(df, dplyr::desc(gap)))
      
      top_n <- or_default(input$top_n, 20L)
      ord <- utils::head(ord, top_n)
      
      out <- ord |>
        dplyr::transmute(
          `UF`=uf, `Município`=municipio, `Agência`=agencia,
          `Raio P (km)`=round(dist_p_km,2), `Raio S (km)`=round(dist_s_km,2),
          `Associados P`=assoc_P, `Associados S`=assoc_S, `Associados (Total)`=assoc_total,
          `Universo P`=univ_P, `Universo S`=univ_S, `Universo (Total)`=univ_total,
          `Penetração (%)`=round(pen,1), `Gap`=gap
        )
      
      # >>> Inteiros para exportação
      cols_int <- c("Associados P","Associados S","Associados (Total)",
                    "Universo P","Universo S","Universo (Total)","Gap")
      for (nm in cols_int) {
        if (nm %in% names(out)) out[[nm]] <- as.integer(round(out[[nm]]))
      }
      
      DT::datatable(
        out, rownames = FALSE, extensions = "Buttons",
        options = list(
          dom = "Bfrtip",
          pageLength = min(max(top_n, 1L), 50L),
          buttons = list(
            list(
              extend = "excel",
              title = NULL,
              filename = "analise_penetracao_sicredi",    # <<< Nome do arquivo
              exportOptions = list(
                modifier = list(page = "all")             # <<< Exporta todas as linhas do 'out'
              )
            ),
            "copy"#, "csv"
          ),
          scrollX = TRUE
        )
      ) |>
        DT::formatCurrency(columns = cols_int, currency = "", mark = ".", digits = 0) |>
        DT::formatRound(c("Raio P (km)","Raio S (km)","Penetração (%)"), digits = c(2,2,1), mark = ",")
    })
    
    # ---------- Gráfico ----------
    output$grafico_top <- plotly::renderPlotly({
      df <- medidas_agencia()
      if (nrow(df) == 0) return(NULL)
      
      col_primary   <- "#30660c"
      col_info      <- "#6fc836"
      col_secondary <- "#3d8212"
      col_warning   <- "#121E54"
      col_bg        <- "#ffffff"
      
      top_n <- input$top_n %||% 20
      top_gap <- df |>
        dplyr::arrange(dplyr::desc(.data$gap)) |>
        utils::head(top_n) |>
        dplyr::mutate(lbl = paste0(.data$agencia, " (", .data$uf, ")"))
      
      plotly::plot_ly(
        data = top_gap,
        x = ~gap, y = ~reorder(lbl, gap),
        type = "bar", orientation = "h",
        marker = list(
          color = col_info,
          line  = list(color = col_primary, width = 1.2)
        ),
        hoverinfo = "text",
        text = ~paste0(
          "<b>", agencia, " (", uf, ")</b><br>",
          "Gap: ", fmt_int(gap), "<br>",
          "Associados: ", fmt_int(assoc_total), "<br>",
          "Universo: ", fmt_int(univ_total), "<br>",
          "Penetração: ", fmt_num(pen, 1), " %"
        ),
        hoverlabel = list(
          bgcolor = col_bg,
          bordercolor = col_secondary,
          font = list(color = col_primary)
        )
      ) |>
        plotly::layout(
          paper_bgcolor = col_bg,
          plot_bgcolor  = col_bg,
          xaxis = list(title = "Gap (Universo − Associados)", color = col_warning, gridcolor = "#e9ecef"),
          yaxis = list(title = "", color = col_warning),
          margin = list(l = 160, r = 20, t = 20, b = 50)
        )
    })
  })
}
