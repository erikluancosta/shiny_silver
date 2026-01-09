# =========================================================
# MÓDULO: Donas do Negócio (Somente Mulheres) — PJ vs PF
# - Corrige ausência de area_tipo/area_influ
# - Corrige bases PF sem cod_ua (não quebra KPI)
# - Padroniza visual PJ e PF (mesma grade e mini-cards)
# =========================================================

donas_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    shinyjs::useShinyjs(),
    
    # ------------------ CSS PADRONIZADO ------------------
    tags$style(HTML(paste0("
      /* container geral */
      .dn-wrap { margin-top: 6px; }

      /* filtros */
      #", ns("filtro_card"), " .form-group{ margin-bottom:10px; }

      /* títulos internos */
      .dn-subtitle{
        font-size:12px; color:#6b7370; margin-top:-6px;
      }

      /* grade igual para PJ e PF */
      .dn-kpi-grid{
        display:grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        align-items: stretch;
      }
      @media (max-width: 992px){
        .dn-kpi-grid{ grid-template-columns: 1fr; }
      }

      /* mini-card KPI */
      .dn-kpi{
        background:#fff;
        border-radius: 14px;
        border: 1px solid rgba(0,0,0,0.04);
        border-left: 6px solid #6fc836;
        box-shadow: 0 10px 22px rgba(18,30,84,0.08);
        padding: 14px 16px;
        display:flex;
        gap: 12px;
        align-items:center;
        min-height: 86px;
      }
      .dn-kpi .ico{
        width: 46px; height: 46px;
        border-radius: 14px;
        display:flex; align-items:center; justify-content:center;
        background: rgba(111,200,54,0.12);
        color:#30660c;
        font-size: 20px;
        flex: 0 0 46px;
      }
      .dn-kpi .txt{ display:flex; flex-direction:column; }
      .dn-kpi .lbl{ font-size: 13px; color:#444; font-weight: 700; line-height:1.1; }
      .dn-kpi .val{ font-size: 22px; color:#30660c; font-weight: 900; line-height:1.1; margin-top: 3px; }
      .dn-kpi .sub{ font-size: 12px; color:#6b7370; margin-top: 2px; }

      /* cards principais (PJ/PF) */
      .dn-panel .card-body{ padding-top: 14px; }
    "))),
    # ------------------ UI ------------------
    
    div(
      class = "dn-wrap",
      
      # ---------- filtros ----------
      bs4Dash::bs4Card(
        id = ns("filtro_card"),
        title = "Parâmetros — Donas do Negócio (Somente mulheres)",
        status = "primary",
        collapsible = TRUE,
        width = 12,
        
        fluidRow(
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
          ),
          column(
            2,
            selectInput(
              ns("filtro_categoria"), "Grupo etário:",
              choices = c("Todas","Silver","Pré-Silver","Não-Silver","Indefinido"),
              selected = "Todas"
            )
          )
        ),
        fluidRow(
          column(
            6,
            selectInput(
              ns("filtro_porte_pj"), "Porte (PJ):",
              choices  = c("MEI"="2","Micro"="1","Pequeno Porte"="3","Média"="4","Grande"="6"),
              selected = c("2","1","3","4","6"),
              multiple = TRUE
            )
          ),
          column(
            6,
            tags$div(class="dn-subtitle",
                     "Observação: PF não possui porte. Sexo está fixo em Feminino neste módulo.")
          )
        )
      ),
      
      # ---------- PAINÉIS PADRONIZADOS: PJ e PF ----------
      fluidRow(
        column(
          6,
          bs4Dash::bs4Card(
            class = "dn-panel",
            title = "Mulheres — Pessoa Jurídica (PJ)",
            status = "secondary",
            width = 12,
            div(
              class = "dn-kpi-grid",
              div(class="dn-kpi",
                  div(class="ico", icon("users")),
                  div(class="txt", div(class="lbl","Associadas"), div(class="val", textOutput(ns("kpi_pj_assoc"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("briefcase")),
                  div(class="txt", div(class="lbl","Universo"), div(class="val", textOutput(ns("kpi_pj_univ"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("percent")),
                  div(class="txt", div(class="lbl","Penetração (%)"), div(class="val", textOutput(ns("kpi_pj_pen"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("bullseye")),
                  div(class="txt", div(class="lbl","Raio P (km)"), div(class="val", textOutput(ns("kpi_pj_raio_p"))), div(class="sub","Média"))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("crosshairs")),
                  div(class="txt", div(class="lbl","Raio S (km)"), div(class="val", textOutput(ns("kpi_pj_raio_s"))), div(class="sub","Média"))
              ),
              # slot vazio pra manter grid 2x3 mais equilibrada em telas largas
              div(style="display:none;")
            )
          )
        ),
        
        column(
          6,
          bs4Dash::bs4Card(
            class = "dn-panel",
            title = "Mulheres — Pessoa Física (PF)",
            status = "secondary",
            width = 12,
            div(
              class = "dn-kpi-grid",
              div(class="dn-kpi",
                  div(class="ico", icon("users")),
                  div(class="txt", div(class="lbl","Associadas"), div(class="val", textOutput(ns("kpi_pf_assoc"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("id-card")),
                  div(class="txt", div(class="lbl","Universo"), div(class="val", textOutput(ns("kpi_pf_univ"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("percent")),
                  div(class="txt", div(class="lbl","Penetração (%)"), div(class="val", textOutput(ns("kpi_pf_pen"))))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("bullseye")),
                  div(class="txt", div(class="lbl","Raio P (km)"), div(class="val", textOutput(ns("kpi_pf_raio_p"))), div(class="sub","Média"))
              ),
              div(class="dn-kpi",
                  div(class="ico", icon("crosshairs")),
                  div(class="txt", div(class="lbl","Raio S (km)"), div(class="val", textOutput(ns("kpi_pf_raio_s"))), div(class="sub","Média"))
              ),
              div(style="display:none;")
            )
          )
        )
      ),
      
      # ---------- comparativo ----------
      bs4Dash::bs4Card(
        title = "Comparativo — Penetração PJ vs PF (Mulheres)",
        status = "warning",
        width = 12,
        plotly::plotlyOutput(ns("plot_comp"), height = "340px")
      )
    )
  )
}

donas_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # ------------------ deps ------------------
    requireNamespace("dplyr")
    requireNamespace("tidyr")
    requireNamespace("tibble")
    requireNamespace("plotly")
    requireNamespace("sf")
    
    SEXO_FIXO <- "Feminino"
    
    # ------------------ helpers ------------------
    `%||%` <- function(a, b) if (!is.null(a)) a else b
    
    fmt_int <- function(x) format(as.integer(round(x)), big.mark=".", decimal.mark=",")
    fmt_num <- function(x, digs=1) format(round(as.numeric(x), digs), big.mark=".", decimal.mark=",")
    
    pick_col <- function(df, candidates){
      candidates <- candidates[candidates %in% names(df)]
      if (length(candidates) == 0) return(NULL)
      candidates[1]
    }
    
    make_univ_base <- function(df){
      if (is.null(df) || nrow(df) == 0) return(numeric(0))
      if ("empresas_distintas" %in% names(df)) return(as.numeric(df$empresas_distintas))
      if ("freq" %in% names(df))               return(as.numeric(df$freq))
      if ("n" %in% names(df))                  return(as.numeric(df$n))
      rep(0, nrow(df))
    }
    
    or_default <- function(x, default) if (is.null(x)) default else x
    
    # ------------------ meta agências (para filtros + raios) ------------------
    agencias_meta <- reactive({
      # tenta primeiro PJ (agencias)
      if (exists("agencias")) {
        base <- agencias
        return(tibble::tibble(
          cod_ua = base$cod_ua,
          agencia = base$nome_cooperativa,
          uf = base$uf_municipio,
          municipio = base$municipio_cooperativa
        ) |> dplyr::distinct())
      }
      
      # fallback: PF influencia
      if (exists("agencias_influencia_pf")) {
        base <- sf::st_drop_geometry(agencias_influencia_pf)
        return(tibble::tibble(
          cod_ua = base$cod_ua,
          agencia = base$nome_cooperativa,
          uf = base$uf_agencia,
          municipio = base$municipio_agencia
        ) |> dplyr::distinct())
      }
      
      tibble::tibble(cod_ua=integer(), agencia=character(), uf=character(), municipio=character())
    })
    
    # ------------------ UI dinâmico ------------------
    output$ui_uf <- renderUI({
      meta <- agencias_meta()
      selectInput(session$ns("filtro_uf"), "UF:", choices = c("Todos", sort(unique(meta$uf))), selected = "Todos")
    })
    
    output$ui_municipio <- renderUI({
      meta <- agencias_meta()
      if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos") meta <- dplyr::filter(meta, uf == input$filtro_uf)
      selectInput(session$ns("filtro_municipio"), "Município:", choices = c("Todos", sort(unique(meta$municipio))), selected = "Todos")
    })
    
    output$ui_agencia <- renderUI({
      meta <- agencias_meta()
      if (!is.null(input$filtro_uf) && input$filtro_uf != "Todos") meta <- dplyr::filter(meta, uf == input$filtro_uf)
      if (!is.null(input$filtro_municipio) && input$filtro_municipio != "Todos") meta <- dplyr::filter(meta, municipio == input$filtro_municipio)
      meta <- dplyr::arrange(meta, agencia)
      selectInput(session$ns("filtro_agencia"), "Agência:", choices = c("Todos"="Todos", stats::setNames(meta$cod_ua, meta$agencia)), selected = "Todos")
    })
    
    # ------------------ filtros território comuns ------------------
    filtros_territorio <- reactive({
      list(
        uf = input$filtro_uf %||% "Todos",
        municipio = input$filtro_municipio %||% "Todos",
        agencia = input$filtro_agencia %||% "Todos",
        areas = or_default(input$filtro_area, c("P","S")),
        etario = input$filtro_categoria %||% "Todas",
        porte = or_default(input$filtro_porte_pj, c("2","1","3","4","6"))
      )
    })
    
    # =========================================================
    # PJ — ASSOCIADAS (silver)
    # =========================================================
    assoc_pj <- reactive({
      if (!exists("silver")) return(0L)
      f <- filtros_territorio()
      df <- silver
      
      # sexo fixo
      sexo_col <- pick_col(df, c("sexo_final_sicredi","sexo_final","sexo"))
      if (!is.null(sexo_col)) df <- dplyr::filter(df, .data[[sexo_col]] == SEXO_FIXO)
      
      # território
      if (f$uf != "Todos" && "uf_municipio" %in% names(df)) df <- dplyr::filter(df, uf_municipio == f$uf)
      if (f$municipio != "Todos" && "municipio_cooperativa" %in% names(df)) df <- dplyr::filter(df, municipio_cooperativa == f$municipio)
      if (f$agencia != "Todos" && "cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(f$agencia))
      
      # etário
      if (f$etario != "Todas" && "idade_sicredi" %in% names(df)) df <- dplyr::filter(df, idade_sicredi == f$etario)
      
      # porte
      if (!is.null(f$porte) && "porte_recriado" %in% names(df)) df <- dplyr::filter(df, porte_recriado %in% as.integer(f$porte))
      
      # área (associadas PJ normalmente usa area_influ)
      area_col <- pick_col(df, c("area_influ","area_tipo"))
      if (!is.null(area_col)) df <- dplyr::filter(df, .data[[area_col]] %in% f$areas)
      
      nrow(df)
    })
    
    # =========================================================
    # PJ — UNIVERSO (agg_agencias / agg_empresas)
    # - corrige area_tipo inexistente usando area_influ
    # - não quebra se não houver cod_ua (agg_empresas)
    # =========================================================
    univ_pj <- reactive({
      f <- filtros_territorio()
      ag_sel <- isTRUE(f$agencia != "Todos")
      
      if (ag_sel) {
        if (!exists("agg_agencias")) return(0L)
        df <- agg_agencias
        if ("cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(f$agencia))
      } else {
        if (!exists("agg_empresas")) return(0L)
        df <- agg_empresas
      }
      
      # território
      if (f$uf != "Todos") {
        col_uf <- pick_col(df, c("uf_cooperativa","uf_municipio","uf_agencia"))
        if (!is.null(col_uf)) df <- dplyr::filter(df, .data[[col_uf]] == f$uf)
      }
      if (f$municipio != "Todos") {
        col_m <- pick_col(df, c("municipio_cooperativa","municipio_agencia"))
        if (!is.null(col_m)) df <- dplyr::filter(df, .data[[col_m]] == f$municipio)
      }
      
      # sexo fixo
      sexo_col <- pick_col(df, c("sexo_me","sexo_final","sexo"))
      if (!is.null(sexo_col)) df <- dplyr::filter(df, .data[[sexo_col]] == SEXO_FIXO)
      
      # etário
      if (f$etario != "Todas") {
        et_col <- pick_col(df, c("classificacao_socios","idade_sicredi"))
        if (!is.null(et_col)) df <- dplyr::filter(df, .data[[et_col]] == f$etario)
      }
      
      # porte
      if (!is.null(f$porte) && "porte_recriado" %in% names(df)) df <- dplyr::filter(df, porte_recriado %in% as.integer(f$porte))
      
      # área (area_tipo ou area_influ)
      area_col <- pick_col(df, c("area_tipo","area_influ"))
      if (!is.null(area_col)) df <- dplyr::filter(df, .data[[area_col]] %in% f$areas)
      
      if (nrow(df) == 0) return(0L)
      df[["__u__"]] <- make_univ_base(df)
      sum(df[["__u__"]], na.rm = TRUE)
    })
    
    # =========================================================
    # PF — ASSOCIADAS (pf_sicredi)
    # =========================================================
    assoc_pf <- reactive({
      if (!exists("pf_sicredi")) return(0L)
      f <- filtros_territorio()
      df <- pf_sicredi
      
      # sexo fixo
      sexo_col <- pick_col(df, c("sexo","sexo_final"))
      if (!is.null(sexo_col)) df <- dplyr::filter(df, .data[[sexo_col]] == SEXO_FIXO)
      
      # território
      col_uf <- pick_col(df, c("uf_agencia","uf_municipio"))
      if (f$uf != "Todos" && !is.null(col_uf)) df <- dplyr::filter(df, .data[[col_uf]] == f$uf)
      
      col_m <- pick_col(df, c("municipio_cooperativa","municipio_agencia"))
      if (f$municipio != "Todos" && !is.null(col_m)) df <- dplyr::filter(df, .data[[col_m]] == f$municipio)
      
      if (f$agencia != "Todos") {
        cod_col <- pick_col(df, c("cod_ua"))
        if (!is.null(cod_col)) df <- dplyr::filter(df, .data[[cod_col]] == as.numeric(f$agencia))
      }
      
      # etário
      if (f$etario != "Todas") {
        et_col <- pick_col(df, c("classificacao_idade","idade_sicredi"))
        if (!is.null(et_col)) df <- dplyr::filter(df, .data[[et_col]] == f$etario)
      }
      
      # área
      area_col <- pick_col(df, c("area_tipo","area_influ"))
      if (!is.null(area_col)) df <- dplyr::filter(df, .data[[area_col]] %in% f$areas)
      
      # PF pode estar agregado (coluna "associados")
      if ("associados" %in% names(df)) return(sum(df$associados, na.rm = TRUE))
      nrow(df)
    })
    
    # =========================================================
    # PF — UNIVERSO (pf_agregados_ibge / pf_agg_ibge_muni)
    # - não quebra se pf_agg_ibge_muni não tiver cod_ua
    # =========================================================
    univ_pf <- reactive({
      f <- filtros_territorio()
      ag_sel <- isTRUE(f$agencia != "Todos")
      
      if (ag_sel) {
        if (!exists("pf_agregados_ibge")) return(0L)
        df <- pf_agregados_ibge
        if ("cod_ua" %in% names(df)) df <- dplyr::filter(df, cod_ua == as.numeric(f$agencia))
      } else {
        if (!exists("pf_agg_ibge_muni")) return(0L)
        df <- pf_agg_ibge_muni
      }
      
      # território
      col_uf <- pick_col(df, c("uf_agencia","uf_municipio"))
      if (f$uf != "Todos" && !is.null(col_uf)) df <- dplyr::filter(df, .data[[col_uf]] == f$uf)
      
      col_m <- pick_col(df, c("municipio_agencia","municipio_cooperativa"))
      if (f$municipio != "Todos" && !is.null(col_m)) df <- dplyr::filter(df, .data[[col_m]] == f$municipio)
      
      # sexo fixo
      sexo_col <- pick_col(df, c("sexo","sexo_final"))
      if (!is.null(sexo_col)) df <- dplyr::filter(df, .data[[sexo_col]] == SEXO_FIXO)
      
      # etário
      if (f$etario != "Todas") {
        et_col <- pick_col(df, c("classificacao_idade"))
        if (!is.null(et_col)) df <- dplyr::filter(df, .data[[et_col]] == f$etario)
      }
      
      # área (geralmente area_tipo)
      area_col <- pick_col(df, c("area_tipo","area_influ"))
      if (!is.null(area_col)) df <- dplyr::filter(df, .data[[area_col]] %in% f$areas)
      
      if (nrow(df) == 0) return(0L)
      if ("populacao" %in% names(df)) return(sum(df$populacao, na.rm = TRUE))
      0L
    })
    
    # =========================================================
    # Raios PJ / PF (média)
    # =========================================================
    raios_pj <- reactive({
      f <- filtros_territorio()
      
      # se tiver agencias_influencia (PJ)
      if (!exists("agencias_influencia")) return(list(p=NA_real_, s=NA_real_))
      base <- agencias_influencia
      if (!inherits(base, "sf")) return(list(p=NA_real_, s=NA_real_))
      
      # filtra agências pelo território selecionado
      meta <- agencias_meta()
      if (f$uf != "Todos") meta <- dplyr::filter(meta, uf == f$uf)
      if (f$municipio != "Todos") meta <- dplyr::filter(meta, municipio == f$municipio)
      if (f$agencia != "Todos") meta <- dplyr::filter(meta, cod_ua == as.numeric(f$agencia))
      
      if (nrow(meta) == 0) return(list(p=NA_real_, s=NA_real_))
      
      x <- sf::st_drop_geometry(base)
      x <- dplyr::semi_join(x, meta, by = "cod_ua")
      
      if (nrow(x) == 0) return(list(p=NA_real_, s=NA_real_))
      list(
        p = mean(x$dist_50km, na.rm = TRUE),
        s = mean(x$dist_90km, na.rm = TRUE)
      )
    })
    
    raios_pf <- reactive({
      f <- filtros_territorio()
      
      if (!exists("agencias_influencia_pf")) return(list(p=NA_real_, s=NA_real_))
      x <- sf::st_drop_geometry(agencias_influencia_pf)
      
      meta <- tibble::tibble(
        cod_ua = x$cod_ua,
        uf = x$uf_agencia,
        municipio = x$municipio_agencia
      ) |> dplyr::distinct()
      
      if (f$uf != "Todos") meta <- dplyr::filter(meta, uf == f$uf)
      if (f$municipio != "Todos") meta <- dplyr::filter(meta, municipio == f$municipio)
      if (f$agencia != "Todos") meta <- dplyr::filter(meta, cod_ua == as.numeric(f$agencia))
      
      if (nrow(meta) == 0) return(list(p=NA_real_, s=NA_real_))
      
      x <- dplyr::semi_join(x, meta, by = "cod_ua")
      if (nrow(x) == 0) return(list(p=NA_real_, s=NA_real_))
      
      list(
        p = mean(x$dist_50pf, na.rm = TRUE),
        s = mean(x$dist_90pf, na.rm = TRUE)
      )
    })
    
    # =========================================================
    # Outputs KPIs
    # =========================================================
    output$kpi_pj_assoc  <- renderText({ fmt_int(assoc_pj()) })
    output$kpi_pj_univ   <- renderText({ fmt_int(univ_pj()) })
    output$kpi_pj_pen    <- renderText({
      den <- univ_pj()
      if (!is.finite(den) || den <= 0) return("0,0")
      fmt_num(100 * assoc_pj() / den, 1)
    })
    output$kpi_pj_raio_p <- renderText({ fmt_num(raios_pj()$p, 1) })
    output$kpi_pj_raio_s <- renderText({ fmt_num(raios_pj()$s, 1) })
    
    output$kpi_pf_assoc  <- renderText({ fmt_int(assoc_pf()) })
    output$kpi_pf_univ   <- renderText({ fmt_int(univ_pf()) })
    output$kpi_pf_pen    <- renderText({
      den <- univ_pf()
      if (!is.finite(den) || den <= 0) return("0,0")
      fmt_num(100 * assoc_pf() / den, 1)
    })
    output$kpi_pf_raio_p <- renderText({ fmt_num(raios_pf()$p, 1) })
    output$kpi_pf_raio_s <- renderText({ fmt_num(raios_pf()$s, 1) })
    
    # =========================================================
    # Plot comparativo
    # =========================================================
    output$plot_comp <- plotly::renderPlotly({
      pen_pj <- { den <- univ_pj(); if (is.finite(den) && den > 0) 100*assoc_pj()/den else 0 }
      pen_pf <- { den <- univ_pf(); if (is.finite(den) && den > 0) 100*assoc_pf()/den else 0 }
      
      df <- tibble::tibble(
        segmento = c("PJ", "PF"),
        penetracao = c(pen_pj, pen_pf)
      )
      
      plotly::plot_ly(
        data = df,
        x = ~segmento,
        y = ~penetracao,
        type = "bar",
        hoverinfo = "text",
        text = ~paste0("<b>", segmento, "</b><br>Penetração: ", fmt_num(penetracao, 1), " %")
      ) |>
        plotly::layout(
          yaxis = list(title = "Penetração (%)", rangemode = "tozero", gridcolor = "#e9ecef"),
          xaxis = list(title = ""),
          margin = list(l = 60, r = 20, t = 10, b = 40),
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff"
        )
    })
    
  })
}
