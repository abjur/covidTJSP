## Código utilizado para baixar pela primeira vez

library(magrittr)

progressr::with_progress({
  res <- lex::pvec(
    unique(da_cjpg_covid$n_processo),
    lex::tjsp_cpopg_download,
    dir = "data-raw/cpopg"
  )
})

progressr::with_progress({
  da_cpopg_covid_raw <- fs::dir_ls("data-raw/cpopg") %>%
    lex::pvec(lex::tjsp_cpopg_parse)
})

da_cpopg_covid <- da_cpopg_covid_raw %>%
  purrr::map_dfr("result", .id = "arq") %>%
  dplyr::filter(is.na(erro)) %>%
  dplyr::select(
    arq, id_processo, status, assunto, classe,
    foro, juiz, vara, distribuicao, local_fisico,
    controle, area, outros_assuntos, cdp,
    digital, valor_da_acao, processo_principal,
    recebido_em, apensado_ao
  )

usethis::use_data(da_cpopg_covid, compress = "xz")
