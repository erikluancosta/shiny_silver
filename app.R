# app.R — com aba "Donas do Negócio"

# Carregamento de scripts e credenciais
source('global.R')
source("conectar/credenciais.R")
print(credentials)

# >>> NOVO: módulo Donas do Negócio
source("R/donas_negocio.R")  # ajuste o caminho se seu arquivo estiver em outro lugar

# Tema customizado (fresh para bs4Dash - Bootstrap 4)
tema <- fresh::create_theme(
  fresh::bs4dash_status(
    info = "#6fc836",
    secondary = "#3d8212",
    danger = "#ffffff",
    primary = "#30660c",
    warning = "#121E54"
  )
)

# UI principal
app_ui <- bs4DashPage(
  header = dashboardHeader(
    title = bs4DashBrand(
      title = "Sicredi Associados",
      color = "info",
      image = "https://yt3.googleusercontent.com/ytc/AIdro_mX0Dsx4mnkCSatUSSs_1X64KqC3LTAbyQrLo-aK3qaC-0=s900-c-k-c0x00ffffff-no-rj"
    )
  ),
  
  sidebar = bs4DashSidebar(
    status = "secondary",
    bs4SidebarMenu(
      bs4SidebarMenuItem("Mapa de Associados PJ", tabName = "tela_clientes", icon = icon("map")),
      bs4SidebarMenuItem("Mapa de Associados PF", tabName = "tela_pf", icon = icon("map")),
      
      # >>> NOVO
      bs4SidebarMenuItem("Donas do Negócio", tabName = "tela_donas", icon = icon("person-dress")),
      
      bs4SidebarMenuItem(
        "Análises Descritivas", icon = icon("chart-column"),
        bs4SidebarMenuSubItem("Análise geral", tabName = "tela_geral")
      )
    )
  ),
  
  body = bs4DashBody(
    fresh::use_theme(tema),
    
    # ===== Estilos customizados =====
    tags$head(
      tags$style(HTML("
        .irs-bar { background-color: transparent !important; }
        .irs-bar-edge { background-color: transparent !important; }
        .irs-slider { background-color: #337ab7 !important; }
      ")),
      
      # ===== HOTFIX dropdowns: fundo branco + HOVER #F8F9F7 =====
      tags$style(HTML("
        .bootstrap-select .dropdown-menu { background-color: #fff !important; }
        .bootstrap-select .dropdown-menu .dropdown-item,
        .bootstrap-select .dropdown-menu li a {
          background-color: #fff !important;
          color: #222 !important;
        }
        .bootstrap-select .dropdown-menu .dropdown-item:hover,
        .bootstrap-select .dropdown-menu .dropdown-item:focus,
        .bootstrap-select .dropdown-menu li a:hover,
        .bootstrap-select .dropdown-menu li a:focus {
          background-color: #F8F9F7 !important;
          color: #111 !important;
        }
        .bootstrap-select .dropdown-menu .dropdown-item.active,
        .bootstrap-select .dropdown-menu li a.active {
          background-color: #30660c !important;
          color: #fff !important;
        }

        .selectize-dropdown,
        .selectize-dropdown .option { background-color:#fff !important; color:#222 !important; }
        .selectize-dropdown .option:hover,
        .selectize-dropdown .option:focus { background-color:#F8F9F7 !important; color:#111 !important; }
        .selectize-dropdown .option.active { background-color:#30660c !important; color:#fff !important; }
      "))
    ),
    
    bs4TabItems(
      bs4TabItem(tabName = "tela_clientes", clientes_ui("clientes")),
      bs4TabItem(tabName = "tela_pf", pf_ui("pf")),
      
      # >>> NOVO
      bs4TabItem(tabName = "tela_donas", donas_ui("donas")),
      
      bs4TabItem(tabName = "tela_geral", geral_ui("geral")),
      bs4TabItem(tabName = "tela_meisilver", meisilver_ui("meisilver"))
    )
  ),
  
  footer = dashboardFooter(left = "© Construnet, 2025 | Protótipo 1")
)

# Autenticação — alinhar bslib ao Bootstrap 4 (bs4Dash)
ui <- shinymanager::secure_app(
  app_ui,
  language = "pt-BR",
  enable_admin = FALSE,
  theme = bslib::bs_theme(
    version = 4,
    base_font = bslib::font_google("Inter"),
    primary   = "#30660c",
    success   = "#6fc836",
    secondary = "#3d8212",
    warning   = "#FFC73B",
    light     = "#f7f8fa",
    dark      = "#121E54"
  ),
  tags_top = tags$head(
    tags$style(HTML("
      body {
        background: radial-gradient(1200px 800px at 10% 10%, rgba(111,200,54,0.10), transparent 60%),
                    radial-gradient(1000px 600px at 90% 20%, rgba(48,102,12,0.10), transparent 60%),
                    linear-gradient(135deg, #f7f9fb 0%, #eef4ee 100%);
        min-height: 100vh;
      }
      .auth-content, .panel, .card, .panel-default {
        background: rgba(255,255,255,0.92) !important;
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        border: 1px solid rgba(48,102,12,0.10) !important;
        border-radius: 16px !important;
        box-shadow: 0 16px 50px rgba(18,30,84,0.10) !important;
      }
      .sm-brand-wrap { text-align: center; margin-bottom: 18px; }
      .sm-brand-wrap img {
        width: 68px; height: 68px; object-fit: contain; margin-bottom: 10px;
        filter: drop-shadow(0 2px 6px rgba(0,0,0,0.05));
      }
      .sm-title { font-weight: 800; letter-spacing: .2px; color:#30660c; margin: 0; }
      .sm-subtitle { color:#3d8212; margin-top: 6px; font-size: 14px; }
      .form-control, .form-select {
        border-radius: 12px !important; border:1px solid #e5ebea !important;
        box-shadow: none !important; padding: 10px 12px !important;
      }
      .form-control:focus, .form-select:focus {
        border-color:#6fc836 !important;
        box-shadow: 0 0 0 3px rgba(111,200,54,0.20) !important;
      }
      .btn-primary {
        background:#30660c !important; border-color:#30660c !important;
        border-radius: 12px !important; font-weight: 700; padding: 10px 14px;
      }
      .btn-primary:hover { background:#3d8212 !important; border-color:#3d8212 !important; }
      .sm-login-footer { text-align:center; color:#6b7370; font-size:12px; margin-top: 16px; }
      .password-wrapper { position: relative; }
      .password-toggle {
        position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
        border: none; background: transparent; cursor: pointer; padding: 4px;
        color:#30660c; opacity:.8;
      }
      .password-toggle:hover { opacity: 1; }
    "))
  ),
  tags_bottom = tagList(
    tags$div(
      class = "sm-brand-wrap",
      tags$img(src = "https://yt3.googleusercontent.com/ytc/AIdro_mX0Dsx4mnkCSatUSSs_1X64KqC3LTAbyQrLo-aK3qaC-0=s900-c-k-c0x00ffffff-no-rj"),
      tags$h3(class = "sm-title", "Sicredi Associados"),
      tags$div(class = "sm-subtitle", "Acesso restrito · | Construnet")
    ),
    tags$script(HTML("
      (function(){
        function ensureToggle(){
          var pwd = document.querySelector('input[type=\"password\"], #password');
          if(!pwd) return;
          if(pwd.closest('.password-wrapper')) return;

          var wrap = document.createElement('div');
          wrap.className = 'password-wrapper';
          pwd.parentNode.insertBefore(wrap, pwd);
          wrap.appendChild(pwd);

          var btn = document.createElement('button');
          btn.className = 'password-toggle';
          btn.type='button';
          btn.setAttribute('aria-label','Mostrar/ocultar senha');
          btn.innerHTML = '👁️';
          btn.addEventListener('click', function(){
            var t = pwd.getAttribute('type') === 'password' ? 'text' : 'password';
            pwd.setAttribute('type', t);
          });
          wrap.appendChild(btn);
        }
        document.addEventListener('DOMContentLoaded', ensureToggle);
        document.addEventListener('shiny:connected', ensureToggle);
        setInterval(ensureToggle, 700);
      })();
    ")),
    tags$style(HTML("
      .auth-content .panel, .auth-content .card, .panel-default {
        max-width: 560px;
        margin: 48px auto !important;
      }
      .auth-content .panel-body {
        padding: 22px 26px !important;
        display: flex; flex-direction: column; align-items: center;
      }
      .auth-content .panel-body .form-group,
      .auth-content .panel-body .shiny-input-container {
        width: 100% !important; max-width: 440px;
        margin-left: auto; margin-right: auto;
      }
      .auth-content .panel-body .btn-primary {
        width: 100%; max-width: 440px; margin-left: auto; margin-right: auto;
      }
      .auth-content label { margin-bottom: 6px; }
      @media (max-width: 480px) {
        .auth-content .panel, .auth-content .card, .panel-default { max-width: 94vw; }
        .auth-content .panel-body .form-group,
        .auth-content .panel-body .shiny-input-container,
        .auth-content .panel-body .btn-primary { max-width: 92%; }
      }
    ")),
    tags$div(class = "sm-login-footer",
             HTML("© Construnet — ", format(Sys.Date(), '%Y'), " · Análises"))
  )
)

# Server
server <- function(input, output, session) {
  res_auth <- secure_server(check_credentials = check_credentials(credentials))
  clientes_server("clientes")
  geral_server("geral")
  pf_server("pf")
  meisilver_server("meisilver")
  
  # >>> NOVO
  donas_server("donas")
}

shinyApp(ui, server)
