grafico_idade <- function(df){
  
  grafico <- df |> 
    filter(
      faixa_etaria_padrao %in% input$filtro_idade,
      ds_raca %in% input$filtro_raca
    ) |> 
    tab_1(ano) |>
    filter(ano != "Total") |>
    ggplot(aes(
      x = ano, 
      y = `n`, 
      group = 1,
      color = "#9ba2cb",
      text = paste("Ano:", ano, "\nProporção: ", `%`,"%", "\nRegistros: ", n)
    )) +
    geom_line(size = 1) +
    scale_color_identity() +
    scale_y_continuous(limits = c(5000, 9000)) +
    labs(x = "Ano", y = "Frequência") +
    theme_minimal() +
    theme(legend.position = "none")
  
  ggplotly(a, tooltip = "text") |> layout(
    hoverlabel = list(
      bgcolor = "#FAF4F0",
      font = list(color = "black")
    )
  )
  
}