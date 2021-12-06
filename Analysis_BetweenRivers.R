library(tidyverse)
d <- readxl::read_excel("E:/InGEO_local/AtlasNorth/AcousticInterp/BetweenRivers2019ARUDawnDuskObservations_Feb05_2021.xlsx", sheet = "BirdDetections") %>% 
  dplyr::rename(SegSeq = `Segment\r\nSequence`)
sum_json <- function(jsonfile){
  nm <- pluck(jsonfile, "FileName")
  dets <- pluck(jsonfile, "Time History") |> 
    transpose() |> pluck("Te") |>unlist() |>  max()
  if(is_empty(jsonfile$`Wind free regions`)){
    return(tibble(name = nm, totalwindless = 0,
                  length=dets,
                  pwindless   =0,
                  n=0, mean_windless=0))
  }
  
  tmp <- pluck(jsonfile, "Wind free regions") %>% transpose()
  nm <- pluck(jsonfile, "FileName")
  tibble(s = unlist(pluck(tmp, "s")),
         e = unlist(flatten(pluck(tmp, "e")))) %>%
    mutate(t=e-s) %>% summarize(totalwindless = sum(t),
                                pwindless = totalwindless/dets,
                                n=n(),
                                length = dets,
                                mean_windless = mean(t),
                                name = nm)
}

full_list <- list.files("D:/WindDetection/outputs", pattern = ".json")
d$fileabv <- files <- d$Filename |> stringr::str_remove(".wav")
partial <- map(files, ~full_list[grepl(.x, full_list)])

fp <- flatten(partial) |> unlist()
basedir <- "D:/WindDetection/outputs/"

jsons_rds <-  map_df(fp, ~{sum_json(jsonlite::read_json(paste0(basedir,.x))) |> 
                       mutate(fileabv = stringr::str_remove(.x, ".json"))})

d |> left_join(jsons_rds, by = "fileabv") |> filter(!is.na(totalwindless)) |> 
  ggplot(aes(factor(Skipped), pwindless)) +
  geom_point(position = 
               position_jitter(width = 0.1,
                               height = 0))



d |> janitor::clean_names() |> 
  dplyr::select(site_aru_id :interpreter_id, noise_level:skipped, fileabv) |> 
  distinct() |> 
  left_join(jsons_rds, by = "fileabv") |> 
  filter(!is.na(pwindless)) |> 
  write_csv("D:/WindDetection/Interpreted_files.csv")


d |> left_join(jsons_rds, by = "fileabv") |> filter(!is.na(totalwindless))     |>
  filter(Skipped==1 & pwindless>0.75) |> dplyr::select(fileabv,Skipped,matches("Noise"))
  
  filter(grepl("wind", `Noise\r\nSource`)) |> 
  ggplot(aes(factor(`Noise\r\nLevel`), pwindless, colour = factor(Skipped))) +
  geom_point(position = 
               position_jitter(width = 0.1,
                               height = 0))


full_json_outputs <- map(fp, ~jsonlite::read_json(paste0(basedir,.x)))

quantil_res <-                          
map_df(fp,
       ~{jsonlite::read_json(paste0(basedir,.x)) |> 
         pluck( "Global Stats") |> 
           purrr::set_names(glue::glue("q{1:6}")) |> 
           as_tibble() |> 
           mutate(name = pluck(.x, "FileName"),
                  file = stringr::str_remove(.x, ".json"))
       } ) 


quantil_res |> left_join(d, by = c("file"="fileabv")) |> 
  janitor::clean_names() |> 
  ggplot(aes(factor(noise_level), q6, colour = factor(skipped))) +
  geom_point(position = 
               position_jitter(width = 0.1,
                               height = 0))


full_list
jsons_rds_full <-  map_df(full_list, ~{sum_json(jsonlite::read_json(paste0(basedir,.x))) |> 
    mutate(fileabv = stringr::str_remove(.x, ".json"))})
p <- 
jsons_rds_full |> separate(fileabv, sep = "_", into = c("SMID", "YYYYMMDD", "HHMMSS")) |> 
  mutate(ymd = lubridate::ymd(YYYYMMDD),
         hour = str_sub(HHMMSS, start = 1, end = 2),
         minute = str_sub(HHMMSS, start = 3, end = 4),
         hm = lubridate::hm(glue::glue("{hour}:{minute}") ) ,
         time_s = lubridate::ymd("2019-05-05") + hm,
         timestamp = ymd + hm) 
p |> 
  filter(hour<12 & hour>0) |> 
ggplot( aes(ymd, time_s, colour = pwindless))  + geom_point() + 
  scale_colour_viridis_c(direction = -1) +
  theme_dark()
ggplot(p, aes(timestamp,   pwindless))  + geom_line()
ggplot(p, aes(time_s,   pwindless))  + geom_smooth()

ggplot(p, aes(timestamp,   pwindless))  + geom_line()


mutate(Date_l = lubridate::ymd(Date),
       doy = yday(Date_l),
      
       t_ = paste(hour, minute, sep = ":"),
       # time_formatted = hm(t_),
       fulltime = ymd_hm(paste(Date, t_)),
       Month = month(Date_l,label =T),
       obs = ifelse(Count == 0,0,1))


full_json_outputs[[10]]$`Time History` |> transpose() |> as_tibble() |> 
  unnest(cols = everything())
full_json_outputs[[10]]$`Global Stats`
full_json_outputs[[10]]$FileName
jsons_rds_full[jsons_rds_full$name==full_json_outputs[[10]]$FileName,]
