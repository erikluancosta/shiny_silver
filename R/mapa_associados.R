# =========================================================
# MÓDULO UI: Mapa de Associados Sicredi (com áreas de influência)
# =========================================================
clientes_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    useShinyjs(),
    
    # ------------------ ESTILOS ------------------
    tags$style(HTML(paste0("
      #mapa_container { position: absolute; top: 0; left: 0; right: 0; bottom: 0; }
      .leaflet-container { height: 100vh !important; width: 100vw !important; }

      .control-btn {
        min-width: 180px; height: 38px; border-radius: 10px !important;
        background:#fff; border:1px solid #e4e7ec; box-shadow:0 2px 8px rgba(0,0,0,0.08);
        color:#2b2b2b; font-weight:600; text-align:left; padding-left:14px;
      }
      .control-btn:hover { background:#f7f8fa; }
      .control-btn:focus { outline:none; box-shadow:0 0 0 3px rgba(111,200,54,0.25); }

      #", ns("filtros_agencia"), ", #", ns("filtros_associados"), ", #", ns("camadas"), " {
        background:#fff; padding:14px; border-radius:10px; box-shadow:0 2px 12px rgba(0,0,0,0.15);
        display:none; width:300px; z-index:1100;
      }
      #", ns("filtros_agencia"), " h4, #", ns("filtros_associados"), " h4, #", ns("camadas"), " h4 { margin:0 0 10px 0; }
      #", ns("filtros_agencia"), " .form-group, #", ns("filtros_associados"), " .form-group { margin-bottom:10px; }

      /* ----- CARDS com mesma dimensão e espaçamento ----- */
      #", ns("contador_box"), ",
      #", ns("potencial_box"), ",
      #", ns("penetracao_box"), " {
        position: fixed;
        left: 120px;                        
        width: 200px;                       
        min-height: 75px;                   
        background: rgba(255,255,255,0.97);
        padding: 12px 20px;
        border-radius: 10px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.25);
        color: #30660c;
        z-index: 1020;
        border-left: 5px solid #6fc836;
        display: flex;
        align-items: center;
        gap: 12px;
        transition: left 0.0s ease;
      }
      #", ns("contador_icon"), ", #", ns("potencial_icon"), ", #", ns("penetracao_icon"), " { font-size: 24px; color: #6fc836; }
      #", ns("contador_texto"), ", #", ns("potencial_texto"), ", #", ns("penetracao_texto"), " { display: flex; flex-direction: column; }
      #", ns("contador_label"), ", #", ns("potencial_label"), ", #", ns("penetracao_label"), " { font-size: 13px; font-weight: 500; color: #444; margin-bottom: -2px; }
      #", ns("contador_valor"), ", #", ns("potencial_valor"), ", #", ns("penetracao_valor"), " { font-size: 20px; font-weight: 800; color: #30660c; }

      /* posições verticais individuais */
      #", ns("contador_box"), "   { top:  80px; }
      #", ns("potencial_box"), "  { top: 160px; }
      #", ns("penetracao_box"), " { top: 240px; }

      .bootstrap-select .dropdown-menu li a:hover,
      .bootstrap-select .dropdown-menu li a:focus,
      .bootstrap-select .dropdown-menu li a.active {
        background-color: #FFC73B !important;
        border-color: #FFC73B !important;
      }
      .irs-bar { background-color: transparent !important; }
      .irs-bar-edge { background-color: transparent !important; }
      .irs-slider { background-color: #337ab7 !important; }
    "))),
    
    # ------------------ MAPA ------------------
    div(id = "mapa_container", leaflet::leafletOutput(ns("mapa"))),
    
    # Card 1: Empresas associadas (silver)
    div(
      id = ns("contador_box"),
      icon("building", id = ns("contador_icon")),
      div(
        id = ns("contador_texto"),
        div("Empresas associadas", id = ns("contador_label")),
        textOutput(ns("contador_valor"))
      )
    ),
    
    # Card 2: Empresas existentes (RFB - agregadas)
    div(
      id = ns("potencial_box"),
      icon("briefcase", id = ns("potencial_icon")),
      div(
        id = ns("potencial_texto"),
        div("Empresas registradas", id = ns("potencial_label")),
        textOutput(ns("potencial_valor"))
      )
    ),
    
    # Card 3: Penetração (associadas / existentes)
    div(
      id = ns("penetracao_box"),
      icon("chart-pie", id = ns("penetracao_icon")),
      div(
        id = ns("penetracao_texto"),
        div("Penetração Sicredi", id = ns("penetracao_label")),
        textOutput(ns("penetracao_valor"))
      )
    ),
    
    # Botões
    absolutePanel(top = 80,  right = 20, actionButton(ns("toggle_agencia"),    "Filtros territórios", class = "control-btn")),
    absolutePanel(top = 120, right = 20, actionButton(ns("toggle_associados"), "Filtros empreendedor", class = "control-btn")),
    absolutePanel(top = 160, right = 20, actionButton(ns("toggle_camadas"),    "Camadas", class = "control-btn")),
    
    # Painéis
    absolutePanel(top = 120, right = 20, id = ns("filtros_agencia"),
                  h4("Filtros territórios"),
                  uiOutput(ns("filtro_uf_ui")),
                  uiOutput(ns("filtro_municipio_ui")),
                  uiOutput(ns("filtro_agencia_ui")),
                  selectInput(ns("filtro_area"), "Área de influência:",
                              choices  = c("Primária"="P", "Secundária"="S", "Fora"="F"),
                              selected = c("P","S","F"), multiple = TRUE)
    ),
    absolutePanel(top = 160, right = 20, id = ns("filtros_associados"),
                  h4("Filtros empreendedor"),
                  #textInput(ns("filtro_cnpj"), "CNPJ Associado:", placeholder = "Digite parte ou todo o CNPJ"),
                  selectInput(ns("filtro_sexo"), "Sexo:", choices = c("Todos", "Feminino", "Masculino", "Indefinido"), selected = "Todos"),
                  selectInput(ns("filtro_categoria"), "Grupo etário:", choices = c("Todas", "Silver", "Pré-Silver", "Não-Silver", "Indefinido"), selected = "Todas"),
                  # Porte (multi)
                  selectInput(
                    ns("filtro_porte"),
                    "Porte da empresa:",
                    choices = c(
                      #"Todos"                      = "Todos",
                      "MEI"                        = "2",
                      "Micro"                      = "1",
                      "Pequeno Porte"   = "3",
                      "Média"                      = "4",
                      "Grande"                     = "6"
                    ),
                    selected = c("MEI"                        = "2",
                                 "Micro"                      = "1",
                                 "Pequeno Porte"   = "3",
                                 "Média"                      = "4",
                                 "Grande"                     = "6"),
                    multiple = TRUE
                  )
    ),
    absolutePanel(top = 200, right = 20, id = ns("camadas"),
                  h4("Camadas"),
                  checkboxInput(ns("mostrar_influencia_90"), "Exibir área de influência (P90)", value = TRUE),
                  checkboxInput(ns("mostrar_influencia_50"), "Exibir área de influência (P50)", value = TRUE),
                  checkboxInput(ns("mostrar_clientes"),      "Exibir pontos de associados",     value = TRUE),
                  checkboxInput(ns("mostrar_agencias"),      "Exibir marcadores das agências",  value = TRUE)
    ),
    
    # --- Script: ancora os 3 cards à largura da sidebar ---
    tags$script(HTML(sprintf("
      (function(){
        const IDS = ['%s','%s','%s'];
        const OFFSET = 20;
        function positionCards() {
          var sidebar = document.querySelector('.main-sidebar');
          var w = sidebar ? (sidebar.getBoundingClientRect().width || 0) : 0;
          IDS.forEach(function(id){
            var el = document.getElementById(id);
            if (el) el.style.left = (w + OFFSET) + 'px';
          });
        }
        document.addEventListener('DOMContentLoaded', positionCards);
        document.addEventListener('shiny:connected', positionCards);
        window.addEventListener('resize', positionCards);
        if (window.jQuery) {
          var $ = window.jQuery;
          $(document).on('collapsed.lte.pushmenu shown.lte.pushmenu', function(){ setTimeout(positionCards, 10); });
        }
        if (window.ResizeObserver) {
          var el = document.querySelector('.main-sidebar');
          if (el) { new ResizeObserver(function(){ positionCards(); }).observe(el); }
        } else { setInterval(positionCards, 500); }
      })();
    ", ns("contador_box"), ns("potencial_box"), ns("penetracao_box"))))
  )
}

# =========================================================
# MÓDULO SERVER: Mapa de Associados Sicredi (com áreas de influência)
# =========================================================
clientes_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ---------- ESTADO INICIAL DO MAPA ----------
    init <- reactiveValues(center_lng = NA_real_, center_lat = NA_real_, center_zoom = 5)
    
    # ---------- TOGGLES (só um aberto por vez) ----------
    painel_aberto <- reactiveVal(NULL)
    abrir_painel <- function(id) {
      shinyjs::hide("filtros_agencia"); shinyjs::hide("filtros_associados"); shinyjs::hide("camadas")
      shinyjs::show(id); painel_aberto(id)
    }
    fechar_todos <- function() {
      shinyjs::hide("filtros_agencia"); shinyjs::hide("filtros_associados"); shinyjs::hide("camadas")
      painel_aberto(NULL)
    }
    observeEvent(input$toggle_agencia,    { if (identical(painel_aberto(),"filtros_agencia")) fechar_todos()    else abrir_painel("filtros_agencia") })
    observeEvent(input$toggle_associados, { if (identical(painel_aberto(),"filtros_associados")) fechar_todos() else abrir_painel("filtros_associados") })
    observeEvent(input$toggle_camadas,    { if (identical(painel_aberto(),"camadas")) fechar_todos()             else abrir_painel("camadas") })
    
    # ---------- UI DINÂMICO ----------
    output$filtro_uf_ui <- renderUI({
      req(exists("agencias"), "uf_municipio" %in% names(agencias))
      ufs <- sort(unique(agencias$uf_municipio))
      selectInput(ns("filtro_uf"), "UF da agência:", choices = c("Todos", ufs), selected = "Todos")
    })
    output$filtro_municipio_ui <- renderUI({
      req(exists("agencias"), all(c("municipio_cooperativa","uf_municipio") %in% names(agencias)))
      base <- agencias
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos")
        base <- base[base$uf_municipio == input$filtro_uf, , drop = FALSE]
      municipios <- sort(unique(base$municipio_cooperativa))
      selectInput(ns("filtro_municipio"), "Município da agência:", choices = c("Todos", municipios), selected = "Todos")
    })
    output$filtro_agencia_ui <- renderUI({
      req(exists("agencias"), all(c("cod_ua","nome_cooperativa","Latitude","Longitude","municipio_cooperativa","uf_municipio") %in% names(agencias)))
      base <- agencias |> dplyr::filter(!is.na(Latitude), !is.na(Longitude))
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos")
        base <- base[base$uf_municipio == input$filtro_uf, , drop = FALSE]
      if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos")
        base <- base[base$municipio_cooperativa == input$filtro_municipio, , drop = FALSE]
      base <- base[order(base$nome_cooperativa), , drop = FALSE]
      choices <- stats::setNames(base$cod_ua, base$nome_cooperativa)
      sel_atual <- isolate(input$filtro_agencia)
      if (!isTruthy(sel_atual) || !(sel_atual %in% as.character(base$cod_ua))) sel_atual <- "Todos"
      selectInput(ns("filtro_agencia"), "Agência:", choices = c("Todos"="Todos", choices), selected = sel_atual)
    })
    observeEvent(list(input$filtro_uf, input$filtro_municipio), {
      base <- agencias
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos")
        base <- base[base$uf_municipio == input$filtro_uf, , drop = FALSE]
      if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos")
        base <- base[base$municipio_cooperativa == input$filtro_municipio, , drop = FALSE]
      base <- base[order(base$nome_cooperativa), , drop = FALSE]
      choices <- stats::setNames(base$cod_ua, base$nome_cooperativa)
      sel <- isolate(input$filtro_agencia); if (!isTruthy(sel) || !(sel %in% as.character(base$cod_ua))) sel <- "Todos"
      updateSelectInput(session, "filtro_agencia", choices = c("Todos"="Todos", choices), selected = sel)
    }, ignoreInit = TRUE)
    
    # ---------- REACTIVES BASES PRINCIPAIS ----------
    agencias_validas <- reactive({
      req(exists("agencias"), agencias)
      agencias |> dplyr::filter(!is.na(Longitude), !is.na(Latitude))
    })
    agencias_filtradas <- reactive({
      ag <- agencias_validas()
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos")
        ag <- ag[ag$uf_municipio == input$filtro_uf, , drop = FALSE]
      if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos")
        ag <- ag[ag$municipio_cooperativa == input$filtro_municipio, , drop = FALSE]
      if (isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos")
        ag <- ag[ag$cod_ua == as.numeric(input$filtro_agencia), , drop = FALSE]
      ag
    })
    dados_filtrados <- reactive({
      req(exists("silver"), silver)
      data <- silver
      # Sexo
      if (isTruthy(input$filtro_sexo) && input$filtro_sexo != "Todos") {
        data <- data[data$sexo_final_sicredi == input$filtro_sexo, ]
      }
      # Grupo etário (silver)
      if (isTruthy(input$filtro_categoria) && input$filtro_categoria != "Todas" && "idade_sicredi" %in% names(data)) {
        data <- data[data$idade_sicredi == input$filtro_categoria, ]
      }
      # Porte (múltipla seleção)
      if (isTruthy(input$filtro_porte) &&
          !("Todos" %in% input$filtro_porte) &&
          "porte_recriado" %in% names(data)) {
        vals <- as.integer(input$filtro_porte)
        data <- data[data$porte_recriado %in% vals, , drop = FALSE]
      }
      # CNPJ
      if (isTruthy(input$filtro_cnpj) && nzchar(input$filtro_cnpj)) {
        data <- data[grepl(input$filtro_cnpj, data$cnpj_associado), ]
      }
      # Área de influência
      if ("area_influ" %in% names(data)) {
        sel_area <- input$filtro_area
        if (length(sel_area) == 0) {
          data <- data[FALSE, , drop = FALSE]
        } else {
          data <- data[data$area_influ %in% sel_area, , drop = FALSE]
        }
      }
      # Território
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_municipio" %in% names(data)) data <- data[data$uf_municipio == input$filtro_uf, ]
      if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(data)) data <- data[data$municipio_cooperativa == input$filtro_municipio, ]
      if (isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos") data <- data[data$cod_ua == as.numeric(input$filtro_agencia), ]
      data
    })
    
    # ---------- REACTIVES: BASES AGREGADAS (usando o mesmo filtro de UF) ----------
    agg_empresas_filtradas <- reactive({
      if (!exists("agg_empresas")) return(NULL)
      df <- agg_empresas
      
      # Sexo
      if (isTruthy(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo_final" %in% names(df)) {
        df <- df[df$sexo_final == input$filtro_sexo, , drop = FALSE]
      }
      # Grupo etário (via classificacao_socios)
      if (isTruthy(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_socios" %in% names(df)) {
        df <- df[df$classificacao_socios == input$filtro_categoria, , drop = FALSE]
      }
      # Porte (múltipla seleção)
      if (isTruthy(input$filtro_porte) &&
          !("Todos" %in% input$filtro_porte) &&
          "porte_recriado" %in% names(df)) {
        vals <- as.integer(input$filtro_porte)
        df <- df[df$porte_recriado %in% vals, , drop = FALSE]
      }
      # Área (P/S — ignora F)
      if ("area_influ" %in% names(df)) {
        sel_ps <- intersect(input$filtro_area, c("P","S"))
        if (length(sel_ps) > 0) df <- df[df$area_influ %in% sel_ps, , drop = FALSE] else df <- df[FALSE, , drop = FALSE]
      }
      # UF da agência aplicada em uf_cooperativa (e uf_municipio se existir)
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_cooperativa" %in% names(df)) {
        df <- df[df$uf_cooperativa == input$filtro_uf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_municipio" %in% names(df)) {
        df <- df[df$uf_municipio == input$filtro_uf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) {
        df <- df[df$municipio_cooperativa == input$filtro_municipio, , drop = FALSE]
      }
      df
    })
    
    agg_agencias_filtradas <- reactive({
      if (!exists("agg_agencias")) return(NULL)
      df <- agg_agencias
      
      # Agência (se houver seleção)
      if (isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos") {
        if ("cod_ua" %in% names(df)) {
          df <- df[df$cod_ua == as.numeric(input$filtro_agencia), , drop = FALSE]
        } else if ("nome_cooperativa" %in% names(df) && exists("agencias")) {
          nm <- agencias$nome_cooperativa[agencias$cod_ua == as.numeric(input$filtro_agencia)][1]
          df <- df[df$nome_cooperativa == nm, , drop = FALSE]
        }
      } else {
        # Sem agência: respeita UF/Município se presentes
        if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_municipio" %in% names(df)) {
          df <- df[df$uf_municipio == input$filtro_uf, , drop = FALSE]
        }
        if (isTruthy(input$filtro_municipio) && input$filtro_municipio != "Todos" && "municipio_cooperativa" %in% names(df)) {
          df <- df[df$municipio_cooperativa == input$filtro_municipio, , drop = FALSE]
        }
      }
      # UF aplicada também em uf_cooperativa
      if (isTruthy(input$filtro_uf) && input$filtro_uf != "Todos" && "uf_cooperativa" %in% names(df)) {
        df <- df[df$uf_cooperativa == input$filtro_uf, , drop = FALSE]
      }
      # Sexo
      if (isTruthy(input$filtro_sexo) && input$filtro_sexo != "Todos" && "sexo_me" %in% names(df)) {
        df <- df[df$sexo_me == input$filtro_sexo, , drop = FALSE]
      }
      # Grupo etário (via classificacao_socios)
      if (isTruthy(input$filtro_categoria) && input$filtro_categoria != "Todas" && "classificacao_socios" %in% names(df)) {
        df <- df[df$classificacao_socios == input$filtro_categoria, , drop = FALSE]
      }
      # Porte (múltipla seleção)
      if (isTruthy(input$filtro_porte) &&
          !("Todos" %in% input$filtro_porte) &&
          "porte_recriado" %in% names(df)) {
        vals <- as.integer(input$filtro_porte)
        df <- df[df$porte_recriado %in% vals, , drop = FALSE]
      }
      # Área (P/S)
      if ("area_tipo" %in% names(df)) {
        sel_ps <- intersect(input$filtro_area, c("P","S"))
        if (length(sel_ps) > 0) df <- df[df$area_tipo %in% sel_ps, , drop = FALSE] else df <- df[FALSE, , drop = FALSE]
      }
      df
    })
    
    # Soma segura de empresas (usa empresas_distintas > freq > n)
    safe_sum_empresas <- function(df) {
      if (is.null(df) || nrow(df) == 0) return(0)
      if ("empresas_distintas" %in% names(df)) return(sum(df$empresas_distintas, na.rm = TRUE))
      if ("freq" %in% names(df))               return(sum(df$freq, na.rm = TRUE))
      if ("n" %in% names(df))                  return(sum(df$n, na.rm = TRUE))
      0
    }
    
    # Potencial total dependendo da seleção de agência
    potencial_total <- reactive({
      if (isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos") {
        safe_sum_empresas(agg_agencias_filtradas())
      } else {
        safe_sum_empresas(agg_empresas_filtradas())
      }
    })
    
    # ---------- ÁREAS DE INFLUÊNCIA ----------
    areas_influencia_filtradas <- reactive({
      if (!exists("agencias_influencia")) return(list(inf90 = NULL, inf50 = NULL))
      base <- agencias_influencia
      if (!inherits(base, "sf")) return(list(inf90 = NULL, inf50 = NULL))
      agf <- agencias_filtradas()
      if (nrow(agf) == 0) return(list(inf90 = NULL, inf50 = NULL))
      base <- merge(base, agf["cod_ua"], by = "cod_ua", all = FALSE)
      if (nrow(base) == 0) return(list(inf90 = NULL, inf50 = NULL))
      sfc_cols <- names(base)[vapply(base, function(x) inherits(x, "sfc"), logical(1))]
      if (length(sfc_cols) == 0) return(list(inf90 = NULL, inf50 = NULL))
      col90 <- sfc_cols[grepl("90|p90", sfc_cols, ignore.case = TRUE)]
      col50 <- sfc_cols[grepl("50|p50", sfc_cols, ignore.case = TRUE)]
      col90 <- if (length(col90) > 0) col90[1] else NA_character_
      col50 <- if (length(col50) > 0) col50[1] else NA_character_
      inf90 <- if (!is.na(col90)) sf::st_set_geometry(base, col90) else NULL
      inf50 <- if (!is.na(col50)) sf::st_set_geometry(base, col50) else NULL
      list(inf90 = inf90, inf50 = inf50)
    })
    
    # ---------- CARDS ----------
    output$contador_valor <- renderText({
      format(nrow(dados_filtrados()), big.mark = ".", decimal.mark = ",")
    })
    output$potencial_valor <- renderText({
      v <- potencial_total()
      format(as.integer(v), big.mark = ".", decimal.mark = ",")
    })
    output$penetracao_valor <- renderText({
      num <- nrow(dados_filtrados())
      den <- potencial_total()
      if (!is.finite(den) || den <= 0) return("0 %")
      perc <- (num / den) * 100
      paste0(format(round(perc, 1), big.mark = ".", decimal.mark = ","), " %")
    })
    
    # ---------- ÍCONE PNG PERSONALIZADO PARA AGÊNCIAS ----------
    agenciaIcon <- leaflet::makeIcon(
      iconUrl     = "placeholder.png",
      iconWidth   = 25, iconHeight = 25,
      iconAnchorX = 0,  iconAnchorY = 5
    )
    
    # ---------- MAPA INICIAL ----------
    output$mapa <- leaflet::renderLeaflet({
      req(exists("silver"), nrow(silver) > 0)
      init$center_lng <- mean(silver$longitude_associado, na.rm = TRUE)
      init$center_lat <- mean(silver$latitude_associado, na.rm = TRUE)
      init$center_zoom <- 5
      
      leaflet::leaflet(silver) %>%
        leaflet::addProviderTiles("CartoDB.Positron") %>%
        leaflet::setView(lng = init$center_lng, lat = init$center_lat, zoom = init$center_zoom) %>%
        leaflet::addCircleMarkers(
          lng = ~longitude_associado, lat = ~latitude_associado,
          color = "#30660c", radius = 1, fillOpacity = 0.7,
          popup = ~paste0(
            "<b>CNPJ:</b> ", cnpj_associado, "<br>",
            #"<b>Razão Social:</b> ", razao_social_rfb, "<br>",
            "<b>Sexo:</b> ", sexo_final_sicredi, "<br>",
            "<b>Grupo etário:</b> ", idade_sicredi, "<br>",
            "<b>Agência:</b> ", nome_cooperativa, "<br>",
            #"<b>Endereço:</b> ", endereco_associado, ", ", numero_associado, "<br>",
            "<b>Município:</b> ", municipio_associado
          ),
          group = "clientes"
        ) %>%
        leaflet::addMarkers(
          data = agencias_validas(),
          lng = ~Longitude, lat = ~Latitude,
          icon = agenciaIcon,
          label = ~nome_cooperativa,
          labelOptions = leaflet::labelOptions(
            noHide = FALSE, direction = "auto", offset = c(0, -10),
            opacity = 0.9, textsize = "12px",
            style = list(
              "font-weight" = "600", "color" = "#30660c",
              "background" = "rgba(255,255,255,0.95)",
              "border" = "1px solid #6fc836",
              "padding" = "2px 6px",
              "border-radius" = "6px",
              "box-shadow" = "0 1px 6px rgba(0,0,0,0.15)"
            )
          ),
          popup = ~paste0(
            "<b>UA:</b> ", cod_ua, "<br>",
            "<b>Agência:</b> ", nome_cooperativa, "<br>",
            "<b>Local:</b> ", municipio_cooperativa, " - ", uf_municipio
          ),
          group = "agencias",
          layerId = ~as.character(cod_ua)
        )
    })
    
    # ---------- ATUALIZA CAMADAS ----------
    observe({
      df  <- dados_filtrados()
      ag  <- agencias_filtradas()
      ai  <- areas_influencia_filtradas()
      
      show90 <- isTRUE(input$mostrar_influencia_90)
      show50 <- isTRUE(input$mostrar_influencia_50)
      showC  <- isTRUE(input$mostrar_clientes)
      showA  <- isTRUE(input$mostrar_agencias)
      
      prox <- leaflet::leafletProxy("mapa") %>%
        leaflet::clearGroup("influencia_90") %>%
        leaflet::clearGroup("influencia_50") %>%
        leaflet::clearGroup("clientes") %>%
        leaflet::clearGroup("agencias")
      
      if (show90 && !is.null(ai$inf90) && inherits(ai$inf90, "sf") && nrow(ai$inf90) > 0) {
        prox <- prox %>% leaflet::addPolygons(
          data = ai$inf90,
          color = "#d62728", weight = 1, fillOpacity = 0.15,
          popup = ~paste0("<b>UA:</b> ", cod_ua, "<br>",
                          "<b>Agência:</b> ", nome_cooperativa, "<br>",
                          "<b>P90 (km):</b> ", round(dist_90km,2)),
          group = "influencia_90"
        )
      }
      if (show50 && !is.null(ai$inf50) && inherits(ai$inf50, "sf") && nrow(ai$inf50) > 0) {
        prox <- prox %>% leaflet::addPolygons(
          data = ai$inf50,
          color = "#1f77b4", weight = 1, fillOpacity = 0.25,
          popup = ~paste0("<b>UA:</b> ", cod_ua, "<br>",
                          "<b>Agência:</b> ", nome_cooperativa, "<br>",
                          "<b>P50 (km): </b>", round(dist_50km,2)),
          group = "influencia_50"
        )
      }
      if (showC && nrow(df) > 0) {
        prox <- prox %>% leaflet::addCircleMarkers(
          data = df,
          lng = ~longitude_associado, lat = ~latitude_associado,
          color = "#30660c", radius = 1, fillOpacity = 0.7,
          popup = ~paste0(
            "<b>CNPJ:</b> ", cnpj_associado, "<br>",
            #"<b>Razão Social:</b> ", razao_social_rfb, "<br>",
            "<b>Sexo:</b> ", sexo_final_sicredi, "<br>",
            "<b>Grupo etário:</b> ", idade_sicredi, "<br>",
            "<b>Agência:</b> ", nome_cooperativa, "<br>",
            #"<b>Endereço:</b> ", endereco_associado, ", ", numero_associado, "<br>",
            "<b>Município:</b> ", municipio_associado
          ),
          group = "clientes"
        )
      }
      if (showA && nrow(ag) > 0) {
        prox %>% leaflet::addMarkers(
          data = ag,
          lng = ~Longitude, lat = ~Latitude,
          icon = agenciaIcon,
          label = ~nome_cooperativa,
          labelOptions = leaflet::labelOptions(
            noHide = FALSE, direction = "auto", offset = c(0, -10),
            opacity = 0.9, textsize = "12px",
            style = list(
              "font-weight" = "600", "color" = "#30660c",
              "background" = "rgba(255,255,255,0.95)",
              "border" = "1px solid #6fc836",
              "padding" = "2px 6px",
              "border-radius" = "6px",
              "box-shadow" = "0 1px 6px rgba(0,0,0,0.15)"
            )
          ),
          popup = ~paste0(
            "<b>UA:</b> ", cod_ua, "<br>",
            "<b>Agência:</b> ", nome_cooperativa, "<br>",
            "<b>Local:</b> ", municipio_cooperativa, " - ", uf_municipio
          ),
          group = "agencias",
          layerId = ~as.character(cod_ua)
        )
      }
    })
    
    # ---------- ZOOM POR AGÊNCIA ----------
    zoom_para_agencia <- function(cod_ua_sel) {
      ag <- agencias_validas() |> dplyr::filter(cod_ua == as.numeric(cod_ua_sel))
      if (nrow(ag) == 0) return(invisible(NULL))
      leaflet::leafletProxy("mapa", session = session) %>%
        leaflet::setView(lng = ag$Longitude[1], lat = ag$Latitude[1], zoom = 13)
    }
    reset_view_inicial <- function() {
      leaflet::leafletProxy("mapa", session = session) %>%
        leaflet::setView(lng = init$center_lng, lat = init$center_lat, zoom = init$center_zoom)
    }
    observeEvent(input$filtro_agencia, {
      if (isTruthy(input$filtro_agencia) && input$filtro_agencia != "Todos") zoom_para_agencia(input$filtro_agencia)
      else reset_view_inicial()
    }, ignoreInit = TRUE)
    
    # Clique no marcador de agência (sincroniza com select)
    observeEvent(input$mapa_marker_click, {
      click <- input$mapa_marker_click
      if (!is.null(click$id) && nzchar(click$id)) {
        if (click$id %in% as.character(agencias_validas()$cod_ua)) {
          updateSelectInput(session, "filtro_agencia", selected = click$id)
          zoom_para_agencia(click$id)
        }
      }
    })
  })
}
