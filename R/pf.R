# =========================================================
# MÓDULO UI: Mapa de Associados Sicredi - Pessoa Física
# =========================================================
pf_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    useShinyjs(),
    
    # ------------------ ESTILOS ------------------
    tags$style(HTML(paste0("
      #", ns("mapa_pf_container"), " { position:absolute; top:0; left:0; right:0; bottom:0; }
      #", ns("mapa_pf_container"), " .leaflet-container { height: 100vh !important; width: 100% !important; }

      .control-btn {
        min-width: 180px; height: 38px; border-radius: 10px !important;
        background:#fff; border:1px solid #e4e7ec; box-shadow:0 2px 8px rgba(0,0,0,0.08);
        color:#2b2b2b; font-weight:600; text-align:left; padding-left:14px;
      }
      .control-btn:hover { background:#f7f8fa; }
      .control-btn:focus { outline:none; box-shadow:0 0 0 3px rgba(111,200,54,0.25); }

      #", ns("filtros_agencia"), ", #", ns("filtros_pf"), ", #", ns("camadas"), " {
        background:#fff; padding:14px; border-radius:10px; box-shadow:0 2px 12px rgba(0,0,0,0.15);
        display:none; width:300px; z-index:1100;
      }
      #", ns("filtros_agencia"), " h4, #", ns("filtros_pf"), " h4, #", ns("camadas"), " h4 { margin:0 0 10px 0; }

      /* Cards */
      #", ns("contador_box"), ", #", ns("potencial_box"), ", #", ns("penetracao_box"), ",
      #", ns("apos_idade_box"), ", #", ns("apos_invalidez_box"), ", #", ns("apos_temp_box"), ", #", ns("apos_total_box"), " {
        position: fixed; left: 120px; width: 200px; min-height: 75px;
        background: rgba(255,255,255,0.97); padding: 12px 20px; border-radius: 10px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.25); color: #30660c; z-index: 1020;
        border-left: 5px solid #6fc836; display: flex; align-items: center; gap: 12px;
        transition: left 0.0s ease;
      }
      #", ns("contador_box"), "       { top:  80px; }
      #", ns("potencial_box"), "      { top: 160px; }
      #", ns("penetracao_box"), "     { top: 240px; }
      #", ns("apos_idade_box"), "     { top: 320px; }
      #", ns("apos_invalidez_box"), " { top: 400px; }
      #", ns("apos_temp_box"), "      { top: 480px; }
      #", ns("apos_total_box"), "     { top: 560px; }

      #", ns("contador_icon"), ", #", ns("potencial_icon"), ", #", ns("penetracao_icon"), ",
      #", ns("apos_idade_icon"), ", #", ns("apos_invalidez_icon"), ", #", ns("apos_temp_icon"), ", #", ns("apos_total_icon"), " {
        font-size:24px; color:#6fc836;
      }

      #", ns("contador_label"), ", #", ns("potencial_label"), ", #", ns("penetracao_label"), ",
      #", ns("apos_idade_label"), ", #", ns("apos_invalidez_label"), ", #", ns("apos_temp_label"), ", #", ns("apos_total_label"), " {
        font-size:13px; font-weight:500; color:#444; margin-bottom:-2px;
      }

      #", ns("contador_valor"), ", #", ns("potencial_valor"), ", #", ns("penetracao_valor"), ",
      #", ns("apos_idade_valor"), ", #", ns("apos_invalidez_valor"), ", #", ns("apos_temp_valor"), ", #", ns("apos_total_valor"), " {
        font-size:20px; font-weight:800; color:#30660c;
      }
    "))),
    
    # ------------------ MAPA ------------------
    div(
      id = ns("mapa_pf_container"),
      leaflet::leafletOutput(ns("mapa_pf"), height = "100vh")
    ),
    
    # Cards
    div(
      id = ns("contador_box"),
      icon("users", id = ns("contador_icon")),
      div(div("Pessoas associadas", id = ns("contador_label")), textOutput(ns("contador_valor")))
    ),
    div(
      id = ns("potencial_box"),
      icon("id-card", id = ns("potencial_icon")),
      div(div("Pessoas registradas", id = ns("potencial_label")), textOutput(ns("potencial_valor")))
    ),
    div(
      id = ns("penetracao_box"),
      icon("chart-pie", id = ns("penetracao_icon")),
      div(div("Penetração Sicredi", id = ns("penetracao_label")), textOutput(ns("penetracao_valor")))
    ),
    
    # 4 cards aposentadoria
    div(
      id = ns("apos_idade_box"),
      icon("user", id = ns("apos_idade_icon")),
      div(div("Apos. por idade", id = ns("apos_idade_label")), textOutput(ns("apos_idade_valor")))
    ),
    div(
      id = ns("apos_invalidez_box"),
      icon("wheelchair", id = ns("apos_invalidez_icon")),
      div(div("Apos. por invalidez", id = ns("apos_invalidez_label")), textOutput(ns("apos_invalidez_valor")))
    ),
    div(
      id = ns("apos_temp_box"),
      icon("hourglass-half", id = ns("apos_temp_icon")),
      div(div("Apos. por tempo", id = ns("apos_temp_label")), textOutput(ns("apos_temp_valor")))
    ),
    div(
      id = ns("apos_total_box"),
      icon("users", id = ns("apos_total_icon")),
      div(div("Aposentados (total)", id = ns("apos_total_label")), textOutput(ns("apos_total_valor")))
    ),
    
    # Botões
    absolutePanel(top = 80,  right = 20, actionButton(ns("toggle_agencia"), "Filtros territórios",   class = "control-btn")),
    absolutePanel(top = 120, right = 20, actionButton(ns("toggle_pf"),      "Filtros pessoa física", class = "control-btn")),
    absolutePanel(top = 160, right = 20, actionButton(ns("toggle_camadas"), "Camadas",               class = "control-btn")),
    
    # Painéis
    absolutePanel(top = 120, right = 20, id = ns("filtros_agencia"),
                  h4("Filtros territórios"),
                  uiOutput(ns("filtro_uf_pf_ui")),
                  uiOutput(ns("filtro_municipio_pf_ui")),
                  uiOutput(ns("filtro_agencia_pf_ui")),
                  selectInput(ns("filtro_area_pf"), "Área de influência:",
                              choices = c("Primária"="P", "Secundária"="S", "Fora"="F"),
                              selected = c("P","S","F"), multiple = TRUE
                  )
    ),
    absolutePanel(top = 160, right = 20, id = ns("filtros_pf"),
                  h4("Filtros pessoa física"),
                  selectInput(ns("filtro_sexo_pf"), "Sexo:", choices = c("Todos", "Feminino", "Masculino"), selected = "Todos"),
                  selectInput(ns("filtro_categoria_pf"), "Grupo etário:", choices = c("Todas", "Silver", "Pré-Silver", "Não-Silver"), selected = "Todas")
    ),
    absolutePanel(top = 200, right = 20, id = ns("camadas"),
                  h4("Camadas"),
                  checkboxInput(ns("mostrar_influencia_90pf"), "Exibir área de influência (P90 PF)", TRUE),
                  checkboxInput(ns("mostrar_influencia_50pf"), "Exibir área de influência (P50 PF)", TRUE),
                  checkboxInput(ns("mostrar_agencias_pf"),     "Exibir marcadores das agências",      TRUE),
                  checkboxInput(ns("mostrar_renda_cv_pf"),     "Exibir desigualdade (CV renda)",     FALSE), # <<< NOVO (desmarcado)
                  checkboxInput(ns("mostrar_renda_media_pf"),  "Exibir renda média (setores IBGE)",  FALSE)  # <<< NOVO (desmarcado)
    ),
    
    # Ancoragem dos cards
    tags$script(HTML(sprintf("
      (function(){
        const IDS = ['%s','%s','%s','%s','%s','%s','%s'], OFFSET = 20;
        function positionCards(){
          var s = document.querySelector('.main-sidebar');
          var w = s ? (s.getBoundingClientRect().width||0) : 0;
          IDS.forEach(function(id){ var el=document.getElementById(id); if(el) el.style.left=(w+OFFSET)+'px'; });
        }
        document.addEventListener('DOMContentLoaded', positionCards);
        document.addEventListener('shiny:connected', positionCards);
        window.addEventListener('resize', positionCards);
        if (window.jQuery){
          var $ = window.jQuery;
          $(document).on('collapsed.lte.pushmenu shown.lte.pushmenu', function(){ setTimeout(positionCards,10); });
        }
        if (window.ResizeObserver){
          var el = document.querySelector('.main-sidebar'); if (el){ new ResizeObserver(function(){ positionCards(); }).observe(el); }
        } else { setInterval(positionCards, 500); }
      })();
    ",
                             ns("contador_box"), ns("potencial_box"), ns("penetracao_box"),
                             ns("apos_idade_box"), ns("apos_invalidez_box"), ns("apos_temp_box"), ns("apos_total_box")
    )))
  )
}

# =========================================================
# MÓDULO SERVER: Mapa de Associados Sicredi - Pessoa Física
# =========================================================
pf_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ---------- TOGGLES ----------
    painel_aberto <- reactiveVal(NULL)
    abrir_painel <- function(id){ shinyjs::hide("filtros_agencia"); shinyjs::hide("filtros_pf"); shinyjs::hide("camadas"); shinyjs::show(id); painel_aberto(id) }
    fechar_todos <- function(){ shinyjs::hide("filtros_agencia"); shinyjs::hide("filtros_pf"); shinyjs::hide("camadas"); painel_aberto(NULL) }
    observeEvent(input$toggle_agencia, { if (identical(painel_aberto(),"filtros_agencia")) fechar_todos() else abrir_painel("filtros_agencia") })
    observeEvent(input$toggle_pf,      { if (identical(painel_aberto(),"filtros_pf"))      fechar_todos() else abrir_painel("filtros_pf") })
    observeEvent(input$toggle_camadas, { if (identical(painel_aberto(),"camadas"))         fechar_todos() else abrir_painel("camadas") })
    
    # ---------- BASE PF (buffers) ----------
    agencias_pf_validas <- reactive({
      if (!exists("agencias_influencia_pf")) return(NULL)
      base <- agencias_influencia_pf
      if (!inherits(base, "sf")) return(NULL)
      if (!"geometry" %in% names(base)) return(NULL)
      base
    })
    
    # ---------- BASE RENDA (setores) ----------
    renda_setores_validos <- reactive({
      if (!exists("renda")) return(NULL)   # objeto já carregado (ex: readRDS)
      base <- renda
      if (!inherits(base, "sf")) return(NULL)
      base <- tryCatch({
        if (is.na(sf::st_crs(base))) sf::st_set_crs(base, 4326) else sf::st_transform(base, 4326)
      }, error = function(e) base)
      base
    })
    
    norm_txt <- function(x) {
      x <- as.character(x)
      x <- trimws(tolower(x))
      x
    }
    
    renda_filtrada <- reactive({
      base <- renda_setores_validos()
      if (is.null(base) || nrow(base) == 0) return(NULL)
      
      uf_col  <- if ("uf" %in% names(base)) "uf" else if ("uf_agencia" %in% names(base)) "uf_agencia" else NA_character_
      mun_col <- if ("descricao_ibge" %in% names(base)) "descricao_ibge" else if ("municipio" %in% names(base)) "municipio" else if ("nm_mun" %in% names(base)) "nm_mun" else NA_character_
      
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos" && !is.na(uf_col)) {
        base <- base[norm_txt(base[[uf_col]]) == norm_txt(input$filtro_uf_pf), , drop = FALSE]
      }
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && !is.na(mun_col)) {
        base <- base[norm_txt(base[[mun_col]]) == norm_txt(input$filtro_municipio_pf), , drop = FALSE]
      }
      base
    })
    
    # ---------- UI DINÂMICO (territórios) ----------
    output$filtro_uf_pf_ui <- renderUI({
      base <- agencias_pf_validas(); req(!is.null(base), "uf_agencia" %in% names(base))
      ufs <- sort(unique(base$uf_agencia))
      selectInput(ns("filtro_uf_pf"), "UF da agência:", choices = c("Todos", ufs), selected = "Todos")
    })
    output$filtro_municipio_pf_ui <- renderUI({
      base <- agencias_pf_validas(); req(!is.null(base), all(c("municipio_agencia","uf_agencia") %in% names(base)))
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos")
        base <- base[base$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      munis <- sort(unique(base$municipio_agencia))
      selectInput(ns("filtro_municipio_pf"), "Município da agência:", choices = c("Todos", munis), selected = "Todos")
    })
    output$filtro_agencia_pf_ui <- renderUI({
      base <- agencias_pf_validas(); req(!is.null(base), all(c("cod_ua","nome_cooperativa","uf_agencia","municipio_agencia") %in% names(base)))
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos")
        base <- base[base$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos")
        base <- base[base$municipio_agencia == input$filtro_municipio_pf, , drop = FALSE]
      base <- base[order(base$nome_cooperativa), , drop = FALSE]
      choices <- stats::setNames(base$cod_ua, base$nome_cooperativa)
      sel_atual <- isolate(input$filtro_agencia_pf)
      if (!isTruthy(sel_atual) || !(sel_atual %in% as.character(base$cod_ua))) sel_atual <- "Todos"
      selectInput(ns("filtro_agencia_pf"), "Agência:", choices = c("Todos"="Todos", choices), selected = sel_atual)
    })
    observeEvent(list(input$filtro_uf_pf, input$filtro_municipio_pf), {
      base <- agencias_pf_validas(); req(!is.null(base))
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos")
        base <- base[base$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos")
        base <- base[base$municipio_agencia == input$filtro_municipio_pf, , drop = FALSE]
      base <- base[order(base$nome_cooperativa), , drop = FALSE]
      choices <- stats::setNames(base$cod_ua, base$nome_cooperativa)
      sel <- isolate(input$filtro_agencia_pf); if (!isTruthy(sel) || !(sel %in% as.character(base$cod_ua))) sel <- "Todos"
      updateSelectInput(session, "filtro_agencia_pf", choices = c("Todos"="Todos", choices), selected = sel)
    }, ignoreInit = TRUE)
    
    # ---------- DADOS PF (associados) ----------
    pf_sicredi_filtrada <- reactive({
      if (!exists("pf_sicredi")) return(NULL)
      df <- pf_sicredi
      
      if (isTruthy(input$filtro_sexo_pf) && input$filtro_sexo_pf != "Todos" && "sexo" %in% names(df)) {
        df <- df[df$sexo == input$filtro_sexo_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_categoria_pf) && input$filtro_categoria_pf != "Todas" && "classificacao_idade" %in% names(df)) {
        df <- df[df$classificacao_idade == input$filtro_categoria_pf, , drop = FALSE]
      }
      if ("area_tipo" %in% names(df)) {
        sel_area <- input$filtro_area_pf
        if (length(sel_area) == 0) df <- df[FALSE, , drop = FALSE] else df <- df[df$area_tipo %in% sel_area, , drop = FALSE]
      }
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos" && "uf_agencia" %in% names(df)) {
        df <- df[df$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && "municipio_cooperativa" %in% names(df)) {
        df <- df[df$municipio_cooperativa == input$filtro_municipio_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos") {
        if ("cod_ua" %in% names(df)) {
          df <- df[df$cod_ua == as.numeric(input$filtro_agencia_pf), , drop = FALSE]
        } else if ("nome_agencia" %in% names(df)) {
          base_ag <- agencias_pf_validas()
          if (!is.null(base_ag)) {
            nm <- base_ag$nome_cooperativa[base_ag$cod_ua == as.numeric(input$filtro_agencia_pf)][1]
            df <- df[df$nome_agencia == nm, , drop = FALSE]
          }
        }
      }
      df
    })
    
    # ---------- DADOS PF (agregados IBGE - nível agência) ----------
    pf_ibge_filtrada <- reactive({
      if (!exists("pf_agregados_ibge")) return(NULL)
      df <- pf_agregados_ibge
      
      if (isTruthy(input$filtro_sexo_pf) && input$filtro_sexo_pf != "Todos" && "sexo" %in% names(df)) {
        df <- df[df$sexo == input$filtro_sexo_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_categoria_pf) && input$filtro_categoria_pf != "Todas" && "classificacao_idade" %in% names(df)) {
        df <- df[df$classificacao_idade == input$filtro_categoria_pf, , drop = FALSE]
      }
      if ("area_tipo" %in% names(df)) {
        sel_ps <- intersect(input$filtro_area_pf, c("P","S"))
        if (length(sel_ps) > 0) df <- df[df$area_tipo %in% sel_ps, , drop = FALSE] else df <- df[FALSE, , drop = FALSE]
      }
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos" && "uf_agencia" %in% names(df)) {
        df <- df[df$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && "municipio_agencia" %in% names(df)) {
        df <- df[df$municipio_agencia == input$filtro_municipio_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos") {
        if ("cod_ua" %in% names(df)) {
          df <- df[df$cod_ua == as.numeric(input$filtro_agencia_pf), , drop = FALSE]
        } else if ("nome_cooperativa" %in% names(df)) {
          base_ag <- agencias_pf_validas()
          if (!is.null(base_ag)) {
            nm <- base_ag$nome_cooperativa[base_ag$cod_ua == as.numeric(input$filtro_agencia_pf)][1]
            df <- df[df$nome_cooperativa == nm, , drop = FALSE]
          }
        }
      }
      df
    })
    
    # ---------- DADOS PF agregados por município (pf_agg_ibge_muni) ----------
    pf_ibge_muni_filtrada <- reactive({
      if (!exists("pf_agg_ibge_muni")) return(NULL)
      df <- pf_agg_ibge_muni
      
      if (isTruthy(input$filtro_sexo_pf) && input$filtro_sexo_pf != "Todos" && "sexo" %in% names(df)) {
        df <- df[df$sexo == input$filtro_sexo_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_categoria_pf) && input$filtro_categoria_pf != "Todas" && "classificacao_idade" %in% names(df)) {
        df <- df[df$classificacao_idade == input$filtro_categoria_pf, , drop = FALSE]
      }
      if ("area_influ" %in% names(df)) {
        sel_ps <- intersect(input$filtro_area_pf, c("P","S"))
        if (length(sel_ps) > 0) df <- df[df$area_influ %in% sel_ps, , drop = FALSE] else df <- df[FALSE, , drop = FALSE]
      }
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos" && "uf_agencia" %in% names(df)) {
        df <- df[df$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
      }
      if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && "municipio_agencia" %in% names(df)) {
        df <- df[df$municipio_agencia == input$filtro_municipio_pf, , drop = FALSE]
      }
      df
    })
    
    # ---------- DADOS APOSENTADORIA (nível município) ----------
    aposentadoria_filtrada <- reactive({
      if (!exists("aposentadoria")) return(NULL)
      df <- aposentadoria
      
      if (exists("pf_agg_ibge_muni")) {
        map <- pf_agg_ibge_muni
        keep <- c("municipio_agencia","uf_agencia")
        if ("area_influ" %in% names(map)) keep <- c(keep, "area_influ")
        map <- map[, keep, drop = FALSE]
        names(map)[names(map) == "municipio_agencia"] <- "nome_munic"
        names(map)[names(map) == "uf_agencia"] <- "uf"
        if ("area_influ" %in% names(map)) {
          ord <- match(map$area_influ, c("P","S"))
          map <- map[order(ord, map$nome_munic, map$uf, na.last = TRUE), , drop = FALSE]
          key <- paste0(map$nome_munic, "|", map$uf)
          map <- map[!duplicated(key), , drop = FALSE]
          df <- merge(df, map, by = c("nome_munic","uf"), all.x = TRUE)
        }
      }
      
      if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos" && "uf" %in% names(df)) {
        df <- df[df$uf == input$filtro_uf_pf, , drop = FALSE]
      }
      
      ag_sel <- isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos"
      if (ag_sel) {
        base_ag <- agencias_pf_validas()
        if (!is.null(base_ag)) {
          muni_ag <- base_ag$municipio_agencia[base_ag$cod_ua == as.numeric(input$filtro_agencia_pf)][1]
          uf_ag   <- base_ag$uf_agencia[base_ag$cod_ua == as.numeric(input$filtro_agencia_pf)][1]
          df <- df[df$nome_munic == muni_ag & df$uf == uf_ag, , drop = FALSE]
        } else {
          if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && "nome_munic" %in% names(df)) {
            df <- df[df$nome_munic == input$filtro_municipio_pf, , drop = FALSE]
          }
        }
      } else {
        if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos" && "nome_munic" %in% names(df)) {
          df <- df[df$nome_munic == input$filtro_municipio_pf, , drop = FALSE]
        }
      }
      
      if ("area_influ" %in% names(df)) {
        sel_ps <- intersect(input$filtro_area_pf, c("P","S"))
        if (length(sel_ps) > 0) df <- df[df$area_influ %in% sel_ps, , drop = FALSE] else df <- df[FALSE, , drop = FALSE]
      }
      
      df
    })
    
    # ---------- MAPA INICIAL ----------
    output$mapa_pf <- leaflet::renderLeaflet({
      center_lng <- -55; center_lat <- -14; zoom0 <- 4
      base <- agencias_pf_validas()
      if (!is.null(base)) {
        bbox <- sf::st_bbox(base)
        center_lng <- mean(c(bbox["xmin"], bbox["xmax"]), na.rm = TRUE)
        center_lat <- mean(c(bbox["ymin"], bbox["ymax"]), na.rm = TRUE)
        zoom0 <- 5
      }
      leaflet::leaflet(options = leaflet::leafletOptions(preferCanvas = TRUE)) %>%
        leaflet::addProviderTiles("CartoDB.Positron") %>%
        leaflet::addTiles() %>%
        leaflet::setView(lng = center_lng, lat = center_lat, zoom = zoom0)
    })
    outputOptions(output, "mapa_pf", suspendWhenHidden = FALSE)
    
    # ---------- ÍCONE ----------
    agenciaIconPF <- leaflet::makeIcon(
      iconUrl     = "placeholder.png",
      iconWidth   = 25, iconHeight = 25,
      iconAnchorX = 0,  iconAnchorY = 5
    )
    
    # ---------- DESENHO DE CAMADAS ----------
    observe({
      # base buffers (agências)
      base <- agencias_pf_validas()
      if (!is.null(base)) {
        if (isTruthy(input$filtro_uf_pf) && input$filtro_uf_pf != "Todos")
          base <- base[base$uf_agencia == input$filtro_uf_pf, , drop = FALSE]
        if (isTruthy(input$filtro_municipio_pf) && input$filtro_municipio_pf != "Todos")
          base <- base[base$municipio_agencia == input$filtro_municipio_pf, , drop = FALSE]
        if (isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos")
          base <- base[base$cod_ua == as.numeric(input$filtro_agencia_pf), , drop = FALSE]
      }
      
      show90    <- isTRUE(input$mostrar_influencia_90pf)
      show50    <- isTRUE(input$mostrar_influencia_50pf)
      showA     <- isTRUE(input$mostrar_agencias_pf)
      showCV    <- isTRUE(input$mostrar_renda_cv_pf)
      showMedia <- isTRUE(input$mostrar_renda_media_pf)
      
      prox <- leaflet::leafletProxy("mapa_pf") %>%
        leaflet::clearGroup("pf_influencia_90") %>%
        leaflet::clearGroup("pf_influencia_50") %>%
        leaflet::clearGroup("pf_agencias") %>%
        leaflet::clearGroup("pf_renda_cv") %>%
        leaflet::clearGroup("pf_renda_media") %>%
        leaflet::clearControls()
      
      # buffers/markers
      if (!is.null(base) && nrow(base) > 0) {
        if (show90 && "buffer_90pf" %in% names(base)) {
          shp90 <- tryCatch(sf::st_set_geometry(base, "buffer_90pf"), error = function(e) NULL)
          if (!is.null(shp90) && inherits(sf::st_geometry(shp90), c("sfc_POLYGON","sfc_MULTIPOLYGON"))) {
            prox <- prox %>% leaflet::addPolygons(
              data = shp90, color = "#1f77b4", weight = 1, fillOpacity = 0.20,
              popup = ~paste0(
                "<b>UA:</b> ", cod_ua, "<br>",
                "<b>Agência:</b> ", nome_cooperativa, "<br>",
                "<b>UF:</b> ", uf_agencia, " &nbsp; <b>Município:</b> ", municipio_agencia, "<br>",
                "<b>Buffer:</b> P90 (PF)<br>",
                "<b>Área primária (km):</b> ", round(dist_50pf, 2), "<br>",
                "<b>Área secundária (km):</b> ", round(dist_90pf, 2)
              ),
              group = "pf_influencia_90"
            )
          }
        }
        
        if (show50 && "buffer_50pf" %in% names(base)) {
          shp50 <- tryCatch(sf::st_set_geometry(base, "buffer_50pf"), error = function(e) NULL)
          if (!is.null(shp50) && inherits(sf::st_geometry(shp50), c("sfc_POLYGON","sfc_MULTIPOLYGON"))) {
            prox <- prox %>% leaflet::addPolygons(
              data = shp50, color = "#d62728", weight = 1, fillOpacity = 0.15,
              popup = ~paste0(
                "<b>UA:</b> ", cod_ua, "<br>",
                "<b>Agência:</b> ", nome_cooperativa, "<br>",
                "<b>UF:</b> ", uf_agencia, " &nbsp; <b>Município:</b> ", municipio_agencia, "<br>",
                "<b>Buffer:</b> P50 (PF)<br>",
                "<b>Área primária (km):</b> ", round(dist_50pf, 2), "<br>",
                "<b>Área secundária (km):</b> ", round(dist_90pf, 2)
              ),
              group = "pf_influencia_50"
            )
          }
        }
        
        if (showA) {
          prox <- prox %>% leaflet::addMarkers(
            data = base, icon = agenciaIconPF,
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
              "<b>Local:</b> ", municipio_agencia, " - ", uf_agencia, "<br>",
              "<b>Área primária (km):</b> ", round(dist_50pf, 2), "<br>",
              "<b>Área secundária (km):</b> ", round(dist_90pf, 2)
            ),
            group = "pf_agencias",
            layerId = ~as.character(cod_ua)
          )
        }
      }
      
      # renda (mesma base filtrada por UF/Município)
      shp <- renda_filtrada()
      if (!is.null(shp) && nrow(shp) > 0) {
        uf_txt  <- if ("uf" %in% names(shp)) shp$uf else if ("uf_agencia" %in% names(shp)) shp$uf_agencia else NA
        mun_txt <- if ("descricao_ibge" %in% names(shp)) shp$descricao_ibge else if ("municipio" %in% names(shp)) shp$municipio else NA
        
        # Camada 1: CV (cap 6)
        if (showCV && "coef_variacao_renda" %in% names(shp)) {
          cv_cap <- pmin(shp$coef_variacao_renda, 6)
          pal_cv <- leaflet::colorNumeric("YlOrRd", domain = c(0, 6), na.color = "#00000000")
          
          prox <- prox %>%
            leaflet::addPolygons(
              data = shp,
              fillColor = pal_cv(cv_cap),
              fillOpacity = 0.65,
              color = "#3a3a3a", weight = 0.2, opacity = 1,
              popup = paste0(
                "<b>Município:</b> ", mun_txt, "<br>",
                "<b>UF:</b> ", uf_txt, "<br>",
                "<b>Renda média:</b> R$ ", format(round(shp$media_renda_mensal, 0), big.mark=".", decimal.mark=","), "<br>",
                "<b>Coef. variação:</b> ", sprintf("%.2f", shp$coef_variacao_renda)
              ),
              group = "pf_renda_cv"
            ) %>%
            leaflet::addLegend(
              position = "bottomright",
              pal = pal_cv,
              values = c(0, 6),
              title = "Desigualdade (CV 0–6)",
              opacity = 1
            )
        }
        
        # Camada 2: Renda média (cap 20000)
        if (showMedia && "media_renda_mensal" %in% names(shp)) {
          renda_cap <- pmin(shp$media_renda_mensal, 20000)
          pal_renda <- leaflet::colorNumeric("Blues", domain = c(0, 20000), na.color = "#00000000")
          
          prox <- prox %>%
            leaflet::addPolygons(
              data = shp,
              fillColor = pal_renda(renda_cap),
              fillOpacity = 0.65,
              color = "#3a3a3a", weight = 0.2, opacity = 1,
              popup = paste0(
                "<b>Município:</b> ", mun_txt, "<br>",
                "<b>UF:</b> ", uf_txt, "<br>",
                "<b>Renda média:</b> R$ ", format(round(shp$media_renda_mensal, 0), big.mark=".", decimal.mark=","), "<br>",
                "<b>Coef. variação:</b> ", sprintf("%.2f", shp$coef_variacao_renda)
              ),
              group = "pf_renda_media"
            ) %>%
            leaflet::addLegend(
              position = "bottomleft",
              pal = pal_renda,
              values = c(0, 20000),
              title = "Renda média (R$ 0–20.000)",
              opacity = 1
            )
        }
      }
    })
    
    # ---------- Zoom ao selecionar agência ----------
    observeEvent(input$filtro_agencia_pf, {
      base <- agencias_pf_validas()
      req(!is.null(base))
      
      if (isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos") {
        ag <- base[base$cod_ua == as.numeric(input$filtro_agencia_pf), , drop = FALSE]
        if (nrow(ag) > 0) {
          ag4326 <- tryCatch({
            if (is.na(sf::st_crs(ag))) ag else sf::st_transform(ag, 4326)
          }, error = function(e) ag)
          
          geom <- ag4326$geometry
          if (!inherits(sf::st_geometry(geom), c("sfc_POINT"))) geom <- sf::st_centroid(geom)
          xy <- sf::st_coordinates(geom)[1, ]
          lon <- as.numeric(xy[1]); lat <- as.numeric(xy[2])
          if (is.finite(lon) && is.finite(lat)) {
            leaflet::leafletProxy("mapa_pf", session = session) %>%
              leaflet::setView(lng = lon, lat = lat, zoom = 13)
          }
        }
      }
    }, ignoreInit = TRUE)
    
    # ---------- AUXILIARES PARA OS CARDS ----------
    tot_associados <- reactive({
      df <- pf_sicredi_filtrada()
      if (!is.null(df) && "associados" %in% names(df)) sum(df$associados, na.rm = TRUE) else 0
    })
    
    tot_registrados <- reactive({
      ag_sel <- isTruthy(input$filtro_agencia_pf) && input$filtro_agencia_pf != "Todos"
      ibge <- if (ag_sel) pf_ibge_filtrada() else pf_ibge_muni_filtrada()
      if (!is.null(ibge) && "populacao" %in% names(ibge)) sum(ibge$populacao, na.rm = TRUE) else 0
    })
    
    # ---------- TOTAIS APOSENTADORIA ----------
    tot_apos_idade <- reactive({
      df <- aposentadoria_filtrada()
      if (!is.null(df) && "idade" %in% names(df)) sum(df$idade, na.rm = TRUE) else 0
    })
    tot_apos_invalidez <- reactive({
      df <- aposentadoria_filtrada()
      if (!is.null(df) && "invalidez" %in% names(df)) sum(df$invalidez, na.rm = TRUE) else 0
    })
    tot_apos_temp <- reactive({
      df <- aposentadoria_filtrada()
      if (!is.null(df) && "temp_contribuicao" %in% names(df)) sum(df$temp_contribuicao, na.rm = TRUE) else 0
    })
    tot_apos_total <- reactive({
      df <- aposentadoria_filtrada()
      if (!is.null(df) && "total" %in% names(df)) sum(df$total, na.rm = TRUE) else 0
    })
    
    # ---------- CARDS ----------
    output$contador_valor <- renderText({
      format(as.integer(tot_associados()), big.mark = ".", decimal.mark = ",")
    })
    output$potencial_valor <- renderText({
      format(as.integer(tot_registrados()), big.mark = ".", decimal.mark = ",")
    })
    output$penetracao_valor <- renderText({
      num <- tot_associados()
      den <- tot_registrados()
      if (!is.finite(den) || den <= 0) return("0 %")
      perc <- (num / den) * 100
      paste0(format(round(perc, 1), big.mark = ".", decimal.mark = ","), " %")
    })
    
    # ---------- CARDS APOSENTADORIA ----------
    output$apos_idade_valor <- renderText({
      format(as.integer(tot_apos_idade()), big.mark = ".", decimal.mark = ",")
    })
    output$apos_invalidez_valor <- renderText({
      format(as.integer(tot_apos_invalidez()), big.mark = ".", decimal.mark = ",")
    })
    output$apos_temp_valor <- renderText({
      format(as.integer(tot_apos_temp()), big.mark = ".", decimal.mark = ",")
    })
    output$apos_total_valor <- renderText({
      format(as.integer(tot_apos_total()), big.mark = ".", decimal.mark = ",")
    })
  })
}
