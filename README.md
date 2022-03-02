
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidTJSP <img src='man/figures/logo.png' align="right" height="138" />

<!-- badges: start -->

[![R build
status](https://github.com/abjur/covidTJSP/workflows/update-data/badge.svg)](https://github.com/abjur/covidTJSP/actions)
<!-- badges: end -->

Baixa e estrutura dados de covid do TJSP.

``` r
library(covidTJSP)
```

**Última atualização:** 02/03/2022.

Os dados podem ser baixados nos links abaixo.

-   [Consulta de Julgados do Primeiro
    Grau](https://storage.googleapis.com/covid-tjsp/da_cjpg_covid.csv)
-   [Consulta de Processos do Primeiro
    Grau](https://storage.googleapis.com/covid-tjsp/da_cpopg_covid.csv)

## Exemplo de aplicação

``` r
covidTJSP::da_cjpg_covid %>% 
  dplyr::arrange(dplyr::desc(date)) %>% 
  dplyr::distinct(n_processo, .keep_all = TRUE) %>% 
  dplyr::mutate(
    mes = lubridate::floor_date(date, "month"),
    ano = as.character(lubridate::year(date))
  ) %>% 
  dplyr::count(ano, mes) %>% 
  dplyr::arrange(ano, mes) %>% 
  dplyr::mutate(acu = cumsum(n)) %>% 
  dplyr::mutate(tipo = dplyr::case_when(
    mes == lubridate::floor_date(Sys.Date(), "month") ~ "incompleto",
    TRUE ~ "completo"
  )) %>% 
  ggplot2::ggplot(ggplot2::aes(mes, n, fill = tipo)) +
  ggplot2::geom_col() +
  ggplot2::scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b"
  ) +
  ggplot2::scale_y_continuous(labels = scales::number_format(
    big.mark = ".", decimal.mark = ","
  )) +
  ggplot2::scale_fill_viridis_d(begin = .2, end = .8) +
  ggplot2::guides(fill = "none") +
  ggplot2::facet_wrap(~ano, scales = "free_x", ncol = 2) +
  ggplot2::theme_minimal(12) +
  ggplot2::labs(
    title = "Quantidade de decisões no 1º grau",
    subtitle = "Citando termos relacionados a Covid-19",
    x = "Mês",
    y = "Quantidade de decisões",
    caption = paste(
      "Fonte: Consulta de Julgados 1º Grau TJSP",
      "Extração de dados: Pacote {lex} - Terranova Consultoria",
      "Gráfico: Associação Brasileira de Jurimetria",
      sep = "\n"
    )
  )
```

<img src="man/figures/README-simple-plot-1.png" width="100%" />

# Licença

MIT
