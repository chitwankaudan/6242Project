library(tidyverse)
library(migest)

##
##read data in and filter
##
d0 <- read_csv("./data-input/stock.csv", guess_max = 1e6)
d1 <- read_csv("./data-input/demog.csv")
d2 <- read_csv("./data-input/pop.csv")

##
## find common set of countries
##
c_pob <- d0 %>%
  select(pob) %>%
  distinct() %>%
  mutate(alpha3 = pob)

c_por <- d0 %>%
  select(por) %>%
  distinct() %>%
  mutate(alpha3 = por)

c_demog <- d1 %>%
  select(alpha3, b, d) %>%
  drop_na() %>%
  select(-b, -d) %>%
  distinct() %>%
  mutate(demog = alpha3)

c_pop <- d2 %>%
  select(alpha3, pop, name) %>%
  drop_na() %>%
  select(-pop) %>%
  distinct() %>%
  mutate(pop = alpha3)
  
d3 <- c_pop %>%
  full_join(c_demog) %>%
  full_join(c_por) %>%
  full_join(c_pob)

# dropped countries
d3 %>% 
  filter(!complete.cases(.)) %>% 
  print(n = 50) 

# store country codes where all data available
cc <- d3 %>% 
  drop_na() %>% 
  pull(alpha3)

##
## work out native born
##
d4 <- d0 %>%
  filter(pob %in% cc,
         por %in% cc) %>%
  group_by(por, year) %>%
  summarise(fb = sum(stock)) %>%
  ungroup() %>%
  rename(alpha3 = por) %>%
  left_join(d2) %>%
  mutate(pop = pop * 1e03,
         nb = pop - fb)

##
## estimate
##
d5 <- NULL
for(i in seq(1990, 2010, 5)){
  message(i)
  ##
  ## period specific data
  ##
  s1 <- d0 %>% 
    filter(year == i,
           pob %in% cc,
           por %in% cc) %>%
    select(pob, por, stock) %>%
    spread(key = por, value = stock) %>%
    as.matrix() %>%
    {'rownames<-'(.[,-1], .[,1])} %>%
    apply(FUN = as.numeric, MARGIN = c(1, 2)) %>%
    .[cc,cc]

  s2 <- d0 %>% 
    filter(year == i + 5,
           pob %in% cc,
           por %in% cc) %>%
    select(pob, por, stock) %>%
    spread(key = por, value = stock) %>%
    as.matrix() %>%
    {'rownames<-'(.[,-1], .[,1])} %>%
    apply(FUN = as.numeric, MARGIN = c(1, 2)) %>%
    .[cc,cc]
  
  births <- d1 %>%
    filter(year0 == i,
           alpha3 %in% cc) %>%
    mutate(b = b*1e03) %>%
    {'names<-'(.$b, .$alpha3)} %>%
    .[cc]

  deaths <- d1 %>%
    filter(year0 == i,
           alpha3 %in% cc) %>%
    mutate(d = d*1e03) %>%
    {'names<-'(.$d, .$alpha3)} %>%
    .[cc]

  net <- d1 %>%
    filter(year0 == i,
           alpha3 %in% cc) %>%
    mutate(net = net*1e03) %>%
    {'names<-'(.$net, .$alpha3)} %>%
    .[cc] %>%
    rescale_net() 
  
  nb0 <- d4 %>%
    filter(year == i,
           alpha3 %in% cc) %>%
    {'names<-'(.$nb, .$alpha3)} %>%
    .[cc]
  
  nb1 <- d4 %>%
    filter(year == i + 5,
           alpha3 %in% cc) %>%
    {'names<-'(.$nb, .$alpha3)} %>%
    .[cc]
  
  ##
  ## estimation
  ##
  # stock differencing
  e1 <- ffs_diff(m1 = s1, m2 = s2, decrease = "zero")
  e2 <- ffs_diff(m1 = s1, m2 = s2, decrease = "return")
  
  # migration rates
  e3 <- ffs_rates(m1 = s1, M = sum(abs(net)), method = "dennett")
  
  # demographic accounting
  #add native borns to diagonal
  diag(s1) <- nb0
  diag(s2) <- nb1
  
  # open
  e4 <- ffs_demo(m1 = s1, m2 = s2, d_por = deaths, b_por = births, 
                 match_pob_tot_method = "open-dr", verbose = FALSE) %>%
    .[["od_flow"]] %>%
    round() %>%
    .[-nrow(.), -ncol(.)]

  # closed
  e5 <- ffs_demo(m1 = s1, m2 = s2, d_por = deaths, b_por = births,
                 verbose = FALSE) %>%
    .[["od_flow"]] %>%
    round() %>%
    .[-nrow(.), -ncol(.)]
  
  # indepenence
  e6_ind <- ffs_demo(m1 = s1, m2 = s2, d_por = deaths, b_por = births, 
                     stayer_assumption = FALSE, verbose = FALSE) %>%
    .[["od_flow"]] %>%
    .[-nrow(.), -ncol(.)]
  
  # pseudo-bayesian
  e6 <- 0.87 * e5 + (1-0.87) *e6_ind
  
  # save all estimates for period in data frame
  d6 <- e1 %>%
    as.data.frame.table() %>%
    tbl_df() %>%
    rename(sd_drop_neg = Freq) %>%
    mutate(year0 = i, 
           sd_rev_neg = c(e2),
           mig_rate = round(c(e3)),
           da_min_open = c(e4),
           da_min_closed = c(e5),
           da_pb_closed = c(round(e6))) %>%
    select(year0, everything())
  
  # add data frame for the period to data frame for all periods
  d5 <- bind_rows(d5, d6)
}
write_excel_csv(d5, "./est/gf_od.csv")
