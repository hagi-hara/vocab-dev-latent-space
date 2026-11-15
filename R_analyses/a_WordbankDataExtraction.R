# references:
# https://github.com/langcog/wordbankr
# https://github.com/langcog/wordbank-book/blob/9db9683f17864fd71f0ed740f542bc92be177c30/_grammar.Rmd#L135

# install.packages("wordbankr")
# Or use this instead:  devtools::install_github("langcog/wordbankr")
# install.packages("tidyverse")
library(wordbankr)
library(tidyverse)


#####################################################################
### Obtain the full data
#####################################################################

# Use wordbankr
eng_ws <- get_instrument_data(language="English (American)", form="WS", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-04-11
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% 
  mutate(value=case_when(value=="understands"~"", TRUE~value)) %>% arrange(data_id)

eng_wg <- get_instrument_data(language="English (American)", form="WG", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-04-11
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% arrange(data_id)

man_ws <- get_instrument_data(language="Mandarin (Beijing)", form="WS", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-04-11
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% 
  mutate(value=case_when(value=="understands"~"", TRUE~value)) %>% arrange(data_id)

# Alternative method
# 1. Go http://wordbank.stanford.edu/data
# 2. Select "Data Export Tools" and "Full Child-by-Word Data"
# 3. Select the dataset you want to obtain
#    In our case...
#       - English (American) - WS
#       - English (American) - WG
#       - Mandarin (Beijing) - WS
# 4. Put the obtained csv files in the "Data_wordbank/rawdata" folder



#####################################################################
### Data Shaping & Decriptive Stats - English (American) - WS form
#####################################################################

# Import the full data
# eng_ws <- read.csv("Data_wordbank/rawdata/EnglishAmerican_WS_20230907.csv", header=TRUE) %>% 
#   subset(item_kind=="word")

# Confirm the number of word items
eng_ws %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 680 items
eng_ws %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=22) # 22 categories

# confirm the number of data points and children
unique(eng_ws$data_id) %>% length() # N_data = 9093
unique(eng_ws$child_id) %>% length() # N_child = 6960 

# eng_ws %>% subset(value=="understands") %>% select(data_id, child_id, age) %>% unique() ->tmp
# write.csv(tmp, file="Data_wordbank/shapeddata/EnglishAmerican_WS_Understands.csv", row.names=FALSE)

eng_ws_childsum <- eng_ws %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

eng_ws_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 5307
eng_ws_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 1653

# age description (overall)
eng_ws %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  scale_x_continuous(breaks=16:30)+
  theme_bw()

# age description (longitudinal)
eng_ws %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="produces")) %>% ungroup() %>% 
  left_join(eng_ws_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  group_by(N) %>% 
  summarize(N2 = n()) %>% 
  mutate(N2=N2/N) %>% 
  ggplot(aes(x=N, y=N2))+
  geom_bar(stat="identity")+
  theme_bw()

eng_ws %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="produces")) %>% ungroup() %>% 
  left_join(eng_ws_childsum, by="child_id") %>% 
  subset(N>=3) %>% 
  ggplot(aes(x=age, y=VocabSize, color=N))+
  geom_point()+
  geom_line(aes(group=child_id))+
  theme_bw()

# export the data
write.csv(eng_ws, file="Data_wordbank/shapeddata/EnglishAmerican_WS_20240411_shaped.csv", row.names=FALSE)

eng_ws_item <- eng_ws %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(eng_ws_item, file="Data_wordbank/shapeddata/EnglishAmerican_WS_WordItems.csv", row.names=FALSE)

eng_ws_wide <- eng_ws %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(eng_ws_wide, file="Data_wordbank/shapeddata/EnglishAmerican_WS_20240411_shaped_wide.csv", row.names=FALSE)



#####################################################################
### Data Shaping & Decriptive Stats - English (American) - WG form
#####################################################################

# Import the full data
# eng_wg <- read.csv("Data_wordbank/rawdata/EnglishAmerican_WG_20230907.csv", header=TRUE) %>% 
#   subset(item_kind=="word")

# Confirm the number of word items
eng_wg %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 396 items
eng_wg %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) # 19 categories

# confirm the number of data points and children
unique(eng_wg$data_id) %>% length() # N_data = 5123
unique(eng_wg$child_id) %>% length() # N_child = 4345 

eng_wg_childsum <- eng_wg %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

eng_wg_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 3570
eng_wg_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 775

# age description (overall)
eng_wg %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  theme_bw()

# age description (longitudinal)
eng_wg %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="understands" | value=="prodces")) %>% ungroup() %>% 
  left_join(eng_wg_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  group_by(N) %>% 
  summarize(N2 = n()) %>% 
  mutate(N2 = N2/N) %>% 
  ggplot(aes(x=N, y=N2))+
  geom_bar(stat="identity")+
  theme_bw()

eng_wg %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="understands" | value=="produces")) %>% ungroup() %>% 
  left_join(eng_wg_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  ggplot(aes(x=age, y=VocabSize, color=N))+
  geom_point()+
  geom_line(aes(group=child_id))+
  theme_bw()

# export the data
write.csv(eng_wg, file="Data_wordbank/shapeddata/EnglishAmerican_WG_20240411_shaped.csv", row.names=FALSE)

eng_wg_item <- eng_wg %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(eng_wg_item, file="Data_wordbank/shapeddata/EnglishAmerican_WG_WordItems.csv", row.names=FALSE)

eng_wg_wide <- eng_wg %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(eng_wg_wide, file="Data_wordbank/shapeddata/EnglishAmerican_WG_20240411_shaped_wide.csv", row.names=FALSE)



#####################################################################
### Data Shaping & Decriptive Stats - Mandarin (Beijing) - WS form
#####################################################################

# Import the full data
# man_ws <- read.csv("Data_wordbank/rawdata/MandarinBeijing_WS_20230907.csv", header=TRUE) %>% 
#   subset(item_kind=="word")

# Confirm the number of word items
man_ws %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 799 items
man_ws %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=24) # 24 categories

# confirm the number of data points and children
unique(man_ws$data_id) %>% length() # N_data = 1056
unique(man_ws$child_id) %>% length() # N_child = 1056 

man_ws_childsum <- man_ws %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

man_ws_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 1056
man_ws_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 0

# age description (overall)
man_ws %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  theme_bw()

# age description (longitudinal)
# NA

# export the data
write.csv(man_ws, file="Data_wordbank/shapeddata/MandarinBeijing_WS_20240411_shaped.csv", row.names=FALSE)

man_ws_item <- man_ws %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(man_ws_item, file="Data_wordbank/shapeddata/MandarinBeijing_WS_WordItems.csv", row.names=FALSE)

man_ws_wide <- man_ws %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(man_ws_wide, file="Data_wordbank/shapeddata/MandarinBeijing_WS_20240411_shaped_wide.csv", row.names=FALSE)



#####################################################################
### Obtain the basic info about the datasets
#####################################################################
eng_ws_admin <- get_administration_data(language = "English (American)", form = "WS")
eng_wg_admin <- get_administration_data(language = "English (American)", form = "WG")
man_ws_admin <- get_administration_data(language = "Mandarin (Beijing)", form = "WS")

write.csv(eng_ws_admin, file="Data_wordbank/shapeddata/EnglishAmerican_WS_admin_20240411.csv", row.names=FALSE)
write.csv(eng_wg_admin, file="Data_wordbank/shapeddata/EnglishAmerican_WG_admin_20240411.csv", row.names=FALSE)
write.csv(man_ws_admin, file="Data_wordbank/shapeddata/MandarinBeijing_WS_admin_20240411.csv", row.names=FALSE)



# Japanese data ------------------------------------------------------------------------------------------------

#####################################################################
### Obtain the full data
#####################################################################

# Use wordbankr
jpn_ws <- get_instrument_data(language="Japanese", form="WS", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-04-11
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% 
  mutate(value=case_when(value=="understands"~"", TRUE~value)) %>% arrange(data_id)

jpn_wg <- get_instrument_data(language="Japanese", form="WG", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-04-11
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% arrange(data_id)



#####################################################################
### Data Shaping & Decriptive Stats - Japanese - WS form
#####################################################################

# Confirm the number of word items
jpn_ws %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 711 items
jpn_ws %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=25) # 24 categories

# confirm the number of data points and children
unique(jpn_ws$data_id) %>% length() # N_data = 615
unique(jpn_ws$child_id) %>% length() # N_child = 530 

jpn_ws_childsum <- jpn_ws %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

jpn_ws_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 460
jpn_ws_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 70

# age description (overall)
jpn_ws %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  scale_x_continuous(breaks=16:36)+
  theme_bw()

# age description (longitudinal)
jpn_ws %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="produces")) %>% ungroup() %>% 
  left_join(jpn_ws_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  group_by(N) %>% 
  summarize(N2 = n()) %>% 
  mutate(N2=N2/N) %>% 
  ggplot(aes(x=N, y=N2))+
  geom_bar(stat="identity")+
  theme_bw()

jpn_ws %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="produces")) %>% ungroup() %>% 
  left_join(jpn_ws_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  ggplot(aes(x=age, y=VocabSize, color=N))+
  geom_point()+
  geom_line(aes(group=child_id))+
  theme_bw()

# export the data
write.csv(jpn_ws, file="Data_wordbank/shapeddata/Japanese_WS_20240411_shaped.csv", row.names=FALSE)

jpn_ws_item <- jpn_ws %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(jpn_ws_item, file="Data_wordbank/shapeddata/Japanese_WS_WordItems.csv", row.names=FALSE)

jpn_ws_wide <- jpn_ws %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(jpn_ws_wide, file="Data_wordbank/shapeddata/Japanese_WS_20240411_shaped_wide.csv", row.names=FALSE)



#####################################################################
### Data Shaping & Decriptive Stats - Japanese - WG form
#####################################################################

# Confirm the number of word items
jpn_wg %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 448 items
jpn_wg %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=25) # 22 categories

# confirm the number of data points and children
unique(jpn_wg$data_id) %>% length() # N_data = 483
unique(jpn_wg$child_id) %>% length() # N_child = 316 

jpn_wg_childsum <- jpn_wg %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

jpn_wg_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 208
jpn_wg_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 108

# age description (overall)
jpn_wg %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  theme_bw()

# age description (longitudinal)
jpn_wg %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="understands" | value=="prodces")) %>% ungroup() %>% 
  left_join(jpn_wg_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  group_by(N) %>% 
  summarize(N2 = n()) %>% 
  mutate(N2 = N2/N) %>% 
  ggplot(aes(x=N, y=N2))+
  geom_bar(stat="identity")+
  theme_bw()

jpn_wg %>% group_by(data_id, child_id, age) %>% 
  summarize(VocabSize = sum(value=="understands" | value=="produces")) %>% ungroup() %>% 
  left_join(jpn_wg_childsum, by="child_id") %>% 
  subset(N>=2) %>% 
  ggplot(aes(x=age, y=VocabSize, color=N))+
  geom_point()+
  geom_line(aes(group=child_id))+
  theme_bw()

# export the data
write.csv(jpn_wg, file="Data_wordbank/shapeddata/Japanese_WG_20240411_shaped.csv", row.names=FALSE)

jpn_wg_item <- jpn_wg %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(jpn_wg_item, file="Data_wordbank/shapeddata/Japanese_WG_WordItems.csv", row.names=FALSE)

jpn_wg_wide <- jpn_wg %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(jpn_wg_wide, file="Data_wordbank/shapeddata/Japanese_WG_20240411_shaped_wide.csv", row.names=FALSE)



# Mandarin (Taiwanese) data ------------------------------------------------------------------------------------------------

#####################################################################
### Obtain the full data
#####################################################################

# Use wordbankr
mant_ws <- get_instrument_data(language="Mandarin (Taiwanese)", form="WS", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-08-08
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% 
  mutate(value=case_when(value=="understands"~"", TRUE~value)) %>% arrange(data_id)

mant_wg <- get_instrument_data(language="Mandarin (Taiwanese)", form="WG", administration_info=TRUE, item_info=TRUE) %>% 
  subset(item_kind=="word") %>% 
  mutate(downloaded=Sys.Date()) %>% # 2024-08-08
  select(downloaded, data_id, item_kind, category, item_id, item_definition, english_gloss, uni_lemma, child_id, age, value) %>% arrange(data_id)



#####################################################################
### Data Shaping & Decriptive Stats - Mandarin (Taiwanese) - WS form
#####################################################################

# Confirm the number of word items
mant_ws %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 696 items
mant_ws %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=25) # 19 categories

# confirm the number of data points and children
unique(mant_ws$data_id) %>% length() # N_data = 1897
unique(mant_ws$child_id) %>% length() # N_child = 1897 

mant_ws_childsum <- mant_ws %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

mant_ws_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 1897
mant_ws_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 0

# age description (overall)
mant_ws %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  scale_x_continuous(breaks=16:36)+
  theme_bw()

# export the data
write.csv(mant_ws, file="Data_wordbank/shapeddata/Taiwanesee_WS_20240808_shaped.csv", row.names=FALSE)

mant_ws_item <- mant_ws %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(mant_ws_item, file="Data_wordbank/shapeddata/Taiwanese_WS_WordItems.csv", row.names=FALSE)

mant_ws_wide <- mant_ws %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(mant_ws_wide, file="Data_wordbank/shapeddata/Taiwanese_WS_20240808_shaped_wide.csv", row.names=FALSE)



#####################################################################
### Data Shaping & Decriptive Stats - Mandarin (Taiwanese) - WG form
#####################################################################

# Confirm the number of word items
mant_wg %>% group_by(data_id) %>% summarize(N = n()) %>% select(N) %>% summary()  # 354 items
mant_wg %>% select(category, item_id) %>% unique() %>% 
  group_by(category) %>% summarize(N = n()) %>% print(n=25) # 17 categories

# confirm the number of data points and children
unique(mant_wg$data_id) %>% length() # N_data = 757
unique(mant_wg$child_id) %>% length() # N_child = 757 

mant_wg_childsum <- mant_wg %>% select(data_id, child_id) %>% 
  unique() %>% 
  group_by(child_id) %>% summarize(N = n())

mant_wg_childsum %>% subset(N==1) %>% nrow() # N_cross-sectional-only = 757
mant_wg_childsum %>% subset(N>=2) %>% nrow() # N_longitudinal = 0

# age description (overall)
mant_wg %>% select(data_id, child_id, age) %>% unique() %>% ungroup() %>% 
  group_by(age) %>% 
  summarize(N = n()) %>% 
  ggplot(aes(x=age, y=N))+
  geom_bar(stat="identity")+
  theme_bw()

# export the data
write.csv(mant_wg, file="Data_wordbank/shapeddata/Taiwanese_WG_20240808_shaped.csv", row.names=FALSE)

mant_wg_item <- mant_wg %>% select(item_id, item_kind, category, item_definition, english_gloss, uni_lemma) %>% unique()
write.csv(mant_wg_item, file="Data_wordbank/shapeddata/Taiwanese_WG_WordItems.csv", row.names=FALSE)

mant_wg_wide <- mant_wg %>% select(-item_kind, -category, -item_definition, -english_gloss, -uni_lemma) %>%
  pivot_wider(names_from=item_id, values_from=value)
write.csv(mant_wg_wide, file="Data_wordbank/shapeddata/Taiwanese_WG_20240808_shaped_wide.csv", row.names=FALSE)


