library(xml2)
library(dplyr)
library(purrr)

unzip("letters.zip")
my_xmls <- list.files("letters/", full.names = TRUE)

test_xml <- my_xmls[1]
doc <- read_xml(test_xml)
ns <- xml_ns(doc)

# дата письма
date <- xml_find_first(doc,"//d1:correspAction[@type = 'sending']//d1:date", ns) |>
  xml_attr("when")

print(date)
# адресат письма
corresp <- xml_find_first(doc,"//d1:correspAction[@type = 'receiving']//d1:persName", ns) |>
  xml_text() |>
  trimws()
print(corresp)

#том
vol <- xml_find_first(doc,"//d1:biblScope[@unit = 'vol']", ns) |>
  xml_text() |>
  trimws()
print(vol)

## Когда все получится, оберните свое решение в функцию read_letter().

read_letter <- function(xml_path) {
  doc <- read_xml(xml_path)
  ns <- xml_ns(doc)
  
  date <- xml_find_first(doc,"//d1:correspAction[@type = 'sending']//d1:date", ns) |>
    xml_attr("when")
  
  corresp <- xml_find_first(doc,"//d1:correspAction[@type = 'receiving']//d1:persName", ns) |>
    xml_text() |>
    trimws()
  
  vol <- xml_find_first(doc,"//d1:biblScope[@unit = 'vol']", ns) |>
    xml_text() |>
    trimws()
  
  # записываем в тиббл
  res <- tibble(
    date = date,
    corresp = corresp,
    vol = vol
  )
  
  return(res)
}

# Прочтите все письма в один тиббл при помощи map_dfr(). 
letters_tbl <- map_dfr(my_xmls, read_letter)

