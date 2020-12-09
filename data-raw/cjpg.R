## Código utilizado para baixar pela primeira vez

library(magrittr)

lex::tjsp_cjpg_download(
  busca = "covid OU pandemia OU corona",
  dir = "data-raw/cjpg",
  data_ini = "2020-03-01",
  data_fim = Sys.Date()
)

progressr::with_progress({
  da_cjpg <- fs::dir_ls("data-raw/cjpg", regexp = "pag_") %>%
    lex::pvec(lex::tjsp_cjpg_parse) %>%
    purrr::map_dfr("result")
})

re_covid <- stringr::regex("corona ?v[ií]rus|covid|sars-cov-?2", TRUE)
da_cjpg_covid <- da_cjpg %>%
  dplyr::mutate(date = lubridate::dmy(data_de_disponibilizacao)) %>%
  dplyr::filter(stringr::str_detect(resumo, re_covid)) %>%
  dplyr::select(-resumo) %>%
  dplyr::arrange(date)

usethis::use_data(da_cjpg_covid, overwrite = TRUE, compress = "xz")

