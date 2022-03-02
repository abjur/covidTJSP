## Atualização dos dados

library(magrittr)

# CJPG ----
message("cjpg download...")

dir.create("inst/extdata", FALSE, TRUE)

res <- lex::tjsp_cjpg_download(
  busca = "covid OU pandemia OU corona",
  dir = "data-raw/cjpg_new",
  data_ini = Sys.Date() - 10,
  data_fim = Sys.Date()
)

message("cjpg parse...")
da_cjpg <- fs::dir_ls("data-raw/cjpg_new", regexp = "pag_") %>%
  lex::pvec(lex::tjsp_cjpg_parse) %>%
  purrr::map_dfr("result")

re_covid <- stringr::regex("corona ?v[ií]rus|covid|sars-cov-?2", TRUE)
da_cjpg_covid_new <- da_cjpg %>%
  dplyr::mutate(date = lubridate::dmy(data_de_disponibilizacao)) %>%
  dplyr::filter(stringr::str_detect(resumo, re_covid)) %>%
  dplyr::select(-resumo) %>%
  dplyr::arrange(date)

old <- unique(covidTJSP::da_cjpg_covid$n_processo)
da_cjpg_covid <- covidTJSP::da_cjpg_covid %>%
  dplyr::bind_rows(da_cjpg_covid_new) %>%
  dplyr::distinct(codigo, .keep_all = TRUE)

usethis::use_data(da_cjpg_covid, overwrite = TRUE, compress = "xz")
readr::write_csv(da_cjpg_covid, "inst/extdata/da_cjpg_covid.csv")

# CPOPG ----

message("cpopg download...")
p_baixar <- setdiff(unique(da_cjpg_covid$n_processo), old)
res <- purrr::map(
  p_baixar,
  lex::tjsp_cpopg_download,
  dir = "data-raw/cpopg_new"
)

message("cpopg parse...")
da_cpopg_covid_raw <- fs::dir_ls("data-raw/cpopg_new") %>%
  lex::pvec(lex::tjsp_cpopg_parse)

da_cpopg_covid_new <- da_cpopg_covid_raw %>%
  purrr::map_dfr("result", .id = "arq") %>%
  dplyr::select(dplyr::any_of(c(
    "arq", "id_processo", "status", "assunto", "classe",
    "foro", "juiz", "vara", "distribuicao", "local_fisico",
    "controle", "area", "outros_assuntos", "cdp",
    "digital", "valor_da_acao", "processo_principal",
    "recebido_em", "apensado_ao"
  )))

da_cpopg_covid <- covidTJSP::da_cpopg_covid %>%
  dplyr::bind_rows(da_cpopg_covid_new) %>%
  dplyr::distinct(cdp, .keep_all = TRUE)

usethis::use_data(da_cpopg_covid, compress = "xz", overwrite = TRUE)
readr::write_csv(da_cpopg_covid, "inst/extdata/da_cpopg_covid.csv")

# readme ----
message("updating README")

remotes::install_local(".")
rmarkdown::render("README.Rmd", "github_document")
fs::file_delete("README.html")
