meisilver_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Análises - Não Silver (em construção)")
  )
}

meisilver_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Servidor Não Silver - por enquanto vazio
  })
}
