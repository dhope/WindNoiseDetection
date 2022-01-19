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
write_rds(jsons_rds, "C:/Users/hoped/OneDrive - EC-EC/NL_retreive/WindTests/2021-12-20_WindSummary_NL.rds")

basedir <- "D:/WindDetection/NL_outputs/"
completed_2021_12_20 <- list.files("D:/WindDetection/NL_outputs", pattern = ".json$") #|> 
  # stringr::str_remove(".json")

jsons_rds <-  map_df(completed_2021_12_20, ~{sum_json(jsonlite::read_json(paste0(basedir,.x))) |> 
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


library(tidyverse)

# Corrupted files
full_list <- list.files("D:/WindDetection/outputs", pattern = "^P.+json")
basedir <- "D:/WindDetection/outputs/"
jsons_rds <-  map_df(full_list, ~{sum_json(jsonlite::read_json(paste0(basedir,.x))) |> 
    mutate(fileabv = stringr::str_remove(.x, ".json"))})

full_json_NL <- map(full_list, ~jsonlite::read_json(paste0(basedir,.x)))
names_json <- map_chr(1:length(full_list), ~full_json_NL[[.x]]$FileName)
names(full_json_NL) <- names_json#stringr::str_extract(names_json[[1000]], "\\/[S,2021]\\w+")

df <- 
jsons_rds |> 
  separate(fileabv, into = c("site", "wave_filename"), sep = "__", remove = F) |> 
  separate(wave_filename, sep = "-", into = c("DateTime", "SampleGroup"), remove=F) |> 
  separate(DateTime, sep = "T", into = c( "YYYYMMDD", "HHMMSS"), remove=F) |> 
  mutate(ymd = lubridate::ymd(YYYYMMDD),
         hour = str_sub(HHMMSS, start = 1, end = 2),
         minute = str_sub(HHMMSS, start = 3, end = 4),
         hm = lubridate::hm(glue::glue("{hour}:{minute}") ) ,
         time_s = lubridate::ymd("2019-05-05", tz = "America/Toronto") + hm,
         timestamp = ymd + hm) 



ggplot(df, aes(ymd, time_s, colour = pwindless)) + 
  geom_point()+
  scale_colour_viridis_c() +
  facet_wrap(~site, scales = 'free_x') +
  theme_dark()

p1 <- 
df[df$pwindless<0.6,] |> select(pwindless, mean_windless, site,wave_filename) |> 
  arrange(site, pwindless)

set.seed(1324)
p2 <- 

df[df$pwindless==1,] |> 
  slice_sample(n=3) |> 
  select(pwindless, mean_windless, site,wave_filename) |> 
  arrange(site, pwindless)
p3 <- 
d |> janitor::clean_names() |> 
   dplyr::select(site_aru_id :interpreter_id, noise_level:skipped, fileabv) |> 
  distinct() |> 
  left_join(jsons_rds, by = "fileabv") |> 
  filter(!is.na(pwindless)) |> 
  select(pwindless, mean_windless, site=site_aru_id,wave_filename=fileabv) |> 
  arrange(site, pwindless)
pall <- 
bind_rows(list(p1, p2, p3)) |> 
  separate(wave_filename, sep = "-", into = c("A", "B"), remove = F) |> 
  mutate(Filename = case_when(is.na("B")~wave_filename,
                              TRUE~A))

details_df <- map_df(pall$Filename, ~{full_json_NL[[grep(.x, names(full_json_NL))]] |> 
    pluck( "Time History") |> 
    transpose() |> as_tibble() |> 
         unnest(cols = everything()) |> 
    mutate(Filename = .x)
    })


rr <- readxl::read_excel("C:/Users/hoped/OneDrive - EC-EC/NL_retreive/WindTests/Copy of WindTests_RR.xlsx")

left_join(rr, pall, by = c("Filename" )) |> 
  ggplot(aes(Wind_scale_RR, pwindless,shape = Interprable_RR )) + geom_point() +
  labs(y = "Proportion Windless - WindDet.exe") + 
  ggrepel::geom_text_repel(aes(label = Filename))


left_join(rr, pall, by = c("Filename" )) |> 
  ggplot(aes(Wind_scale_RR, mean_windless,shape = Interprable_RR )) + geom_point() +
  labs(y = "Proportion Windless - WindDet.exe") 


res_raw <- 
left_join(details_df, rr) |> 
  filter(!is.na(Wind_scale_RR)) |> 
  group_by(Filename) |> 
  arrange(Ts) |> 
  mutate(QDeg_sum = cumsum(QDeg/100)) |> 
  ungroup() 
max_res <- res_raw |> 
  group_by(Filename) |> 
  summarize(Qdeg_max =max(QDeg_sum))
res_raw |> 
  ggplot(aes(Ts, QDeg_sum, group = Filename, colour = Interprable_RR)) + 
  geom_line() +
  # facet_wrap(~Interprable_RR) + 
    ggrepel::geom_text_repel(data = max_res,
               aes(label = Filename, 
                   x = 300, y = Qdeg_max), colour = "Black")



details_df |> 
  filter(QDeg<10) |> 
  mutate(total_time = Te-Ts) |> 
  group_by(Filename) |> 
  summarize(nodeg = sum(total_time)) |> 
  left_join(x=rr) |>
  ggplot(aes(Wind_scale_RR, nodeg,shape = Interprable_RR )) + geom_point() +
  labs(y = "Proportion Windless - WindDet.exe") 







