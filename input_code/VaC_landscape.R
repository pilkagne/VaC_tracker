### COVID-19 vaccine tracker
### Vaccine Centre, London School of Hygiene & Tropical Medicine
### Contact: Edward Parker, edward.parker@lshtm.ac.uk

### Landscape feature inputs



### Timeline --------------------------------------------------------------------

# load input data
landscape = read.csv("input_data/VaC_LSHTM_landscape.csv", stringsAsFactors = FALSE)
trials = read.csv("input_data/VaC_LSHTM_trials.csv",  stringsAsFactors = FALSE)

# combine other/unknown platforms
landscape$Platform[landscape$Platform=="Other" | landscape$Platform=="Unknown"] = "Other/Unknown"

# create timeline input dataframe
timeline_preclinical = data.frame(group = landscape$Institutes %>% str_replace_all(., "/", "<br>"),
                                  subgroup = landscape$Platform,
                                  content = paste0("<b>",landscape$Name,"</b><br>Pre-clinical development"),
                                  start = landscape$Date.started, end = NA,
                                  country = landscape$Country,
                                  stage = landscape$Phase, 
                                  use = landscape$In.use)
timeline_clinical = data.frame(group = trials$Institutes %>% str_replace_all(., "/", "<br>"),
                               subgroup = trials$Platform,
                               content = paste0("<b>",trials$Name,"</b><br>",trials$Phase,", ",trials$Location, " <i>(", trials$Status,")</i><br>",
                                                '<a href="',trials$Link,'" target="_blank">',trials$Trial.number,"</a>"),
                               start = trials$Start.date, end = trials$Primary.completion.date)
timeline_clinical$group = as.character(timeline_clinical$group)
timeline_clinical = merge(timeline_clinical, timeline_preclinical[,c("group", "country", "stage", "use")], by = "group")
timeline = data.frame(rbind(timeline_preclinical, timeline_clinical))

# add separate timeline inputs for combined Wuhan/Beijing/Sinopharm trials
timeline = timeline %>% 
  add_row(group = "Wuhan Institute of Biological Products<br>Sinopharm", subgroup = "Inactivated", 
          content = '<b>WIBP/BIBP vaccines</b><br>Phase III, UAE, Bahrain, Jordan, Egypt <i>(Recruiting)</i><br><a href="https://clinicaltrials.gov/ct2/show/NCT04510207" target="_blank">NCT04510207</a>', 
          start = '16/07/2020', end = '16/03/2021', country = 'China', stage = "Phase III", use="Yes") %>% 
  add_row(group = "Wuhan Institute of Biological Products<br>Sinopharm", subgroup = "Inactivated", 
          content = '<b>WIBP/BIBP vaccines</b><br>Phase III, Peru <i>(Recruiting)</i><br><a href="https://clinicaltrials.gov/ct2/show/NCT04612972" target="_blank">NCT04612972</a>', 
          start = '10/09/2020', end = '31/12/2020', country = 'China', stage = "Phase III", use="Yes") %>%
# add separate timeline inputs for combined Oxford/Gamaleya trials
  add_row(group = "Gamaleya Research Institute", subgroup = "Vector (non-replicating)", 
          content = '<b>Oxford/Gamaleya vaccines</b><br>Phase I/II, Pending <i>(Not yet recruiting)</i><br><a href="https://clinicaltrials.gov/ct2/show/NCT04684446" target="_blank">NCT04684446</a>', 
          start = '16/03/2021', end = '16/11/2021', country = 'Russia', stage = "Phase III", use="Yes") %>% 
  add_row(group = "Gamaleya Research Institute", subgroup = "Vector (non-replicating)", 
          content = '<b>Oxford/Gamaleya vaccines</b><br>Phase II, Azerbaijan <i>(Not yet recruiting)</i><br><a href="https://clinicaltrials.gov/ct2/show/NCT04686773" target="_blank">NCT04686773</a>', 
          start = '10/02/2021', end = '09/04/2021', country = 'Russia', stage = "Phase III", use="Yes") %>% 
# add timeline input for terminated candidate
add_row(group = "University of Queensland<br>CSL<br>Seqirus", subgroup = "Protein subunit", 
        content = '<b>Molecular clamp vaccine</b><br>Programme halted<br><a href="https://www.csl.com/news/2020/20201211-update-on-the-university-of-queensland-covid-19-vaccine" target="_blank">11 Dec 2020</a>', 
        start = '11/12/2020', country = 'Australia/UK/USA', stage = "Terminated", use = "No")

# set factor levels
timeline$subgroup = factor(timeline$subgroup, levels=c("RNA", "DNA", "Vector (non-replicating)", "Vector (replicating)", "Inactivated", "Live-attenuated",
                                                       "Protein subunit", "Virus-like particle", "Other/Unknown"))

# convert start and end columns to Date format
timeline$start = format(as.Date(timeline$start, format="%d/%m/%Y"),"%Y-%m-%d") 
timeline$end = format(as.Date(timeline$end, format="%d/%m/%Y"),"%Y-%m-%d") 

# sort by platform (subgroup) then Institutes (group)
timeline = timeline %>% arrange(subgroup, group)

# create group- and subgroup-specific dataframes
groups_df = data.frame(id = unique(timeline$group), content = unique(timeline$group))
subgroups_df = data.frame(id = unique(timeline$subgroup), content = unique(timeline$subgroup))

# set colour palettes for each platform
pal_1 = brewer.pal(9, "Blues")[c(3:6,9)] # RNA
pal_2 = brewer.pal(9, "Blues")[c(6:9,3)] # DNA
pal_3 = brewer.pal(9, "Oranges")[c(3:6,9)] # Vector (non-replicating)
pal_4 = brewer.pal(9, "Oranges")[c(6:9,3)] # Vector (replicating)
pal_5 = brewer.pal(9, "Greens")[c(3:6,9)] # Inactivated 
pal_6 = brewer.pal(9, "Greens")[c(6:9,3)] # Live-attenuated
pal_7 = brewer.pal(9, "Purples")[c(3:6,9)] # Protein subunit
pal_8 = brewer.pal(9, "Purples")[c(6:9,3)] # Virus-like particle
pal_9 = brewer.pal(9, "Greys")[c(3:6,9)] # Other/unknown

# add styles for preclinical timeline rows
timeline$style = NA
timeline$style[timeline$subgroup=="RNA"] = paste0("font-size:12px;border-color:",pal_1[5],";background-color:",pal_1[1],";color:",pal_1[5],";")
timeline$style[timeline$subgroup=="DNA"] = paste0("font-size:12px;border-color:",pal_2[5],";background-color:",pal_2[1],";color:",pal_2[5],";")
timeline$style[timeline$subgroup=="Vector (non-replicating)"] = paste0("font-size:12px;border-color:",pal_3[5],";background-color:",pal_3[1],";color:",pal_3[5],";")
timeline$style[timeline$subgroup=="Vector (replicating)"] = paste0("font-size:12px;border-color:",pal_4[5],";background-color:",pal_4[1],";color:",pal_4[5],";")
timeline$style[timeline$subgroup=="Inactivated"] = paste0("font-size:12px;border-color:",pal_5[5],";background-color:",pal_5[1],";color:",pal_5[5],";")
timeline$style[timeline$subgroup=="Live-attenuated"] = paste0("font-size:12px;border-color:",pal_6[5],";background-color:",pal_6[1],";color:",pal_6[5],";")
timeline$style[timeline$subgroup=="Protein subunit"] = paste0("font-size:12px;border-color:",pal_7[5],";background-color:",pal_7[1],";color:",pal_7[5],";")
timeline$style[timeline$subgroup=="Virus-like particle"] = paste0("font-size:12px;border-color:",pal_8[5],";background-color:",pal_8[1],";color:",pal_8[5],";")
timeline$style[timeline$subgroup=="Other/Unknown"] = paste0("font-size:12px;border-color:",pal_9[5],";background-color:",pal_9[1],";color:",pal_9[5],";")

# add style for phase I timeline rows
timeline$style[timeline$subgroup=="RNA" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_1[5],";background-color:",pal_1[2],";color:",pal_1[5],";")
timeline$style[timeline$subgroup=="DNA" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_2[5],";background-color:",pal_2[2],";color:",pal_2[5],";")
timeline$style[timeline$subgroup=="Vector (non-replicating)" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_3[5],";background-color:",pal_3[2],";color:",pal_3[5],";")
timeline$style[timeline$subgroup=="Vector (replicating)" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_4[5],";background-color:",pal_4[2],";color:",pal_4[5],";")
timeline$style[timeline$subgroup=="Inactivated" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_5[5],";background-color:",pal_5[2],";color:",pal_5[5],";")
timeline$style[timeline$subgroup=="Live-attenuated" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_6[5],";background-color:",pal_6[2],";color:",pal_6[5],";")
timeline$style[timeline$subgroup=="Protein subunit" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_7[5],";background-color:",pal_7[2],";color:",pal_7[5],";")
timeline$style[timeline$subgroup=="Virus-like particle" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_8[5],";background-color:",pal_8[2],";color:",pal_8[5],";")
timeline$style[timeline$subgroup=="Other/Unknown" & grepl("Phase I", timeline$content)] = paste0("font-size:12px;border-color:",pal_9[5],";background-color:",pal_9[2],";color:",pal_9[5],";")

# add style for phase II timeline rows
timeline$style[timeline$subgroup=="RNA" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_1[5],";background-color:",pal_1[3],";color:",pal_1[5],";")
timeline$style[timeline$subgroup=="DNA" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_2[5],";background-color:",pal_2[3],";color:",pal_2[5],";")
timeline$style[timeline$subgroup=="Vector (non-replicating)" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_3[5],";background-color:",pal_3[3],";color:",pal_3[5],";")
timeline$style[timeline$subgroup=="Vector (replicating)" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_4[5],";background-color:",pal_4[3],";color:",pal_4[5],";")
timeline$style[timeline$subgroup=="Inactivated" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_5[5],";background-color:",pal_5[3],";color:",pal_5[5],";")
timeline$style[timeline$subgroup=="Live-attenuated" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_6[5],";background-color:",pal_6[3],";color:",pal_6[5],";")
timeline$style[timeline$subgroup=="Protein subunit" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_7[5],";background-color:",pal_7[3],";color:",pal_7[5],";")
timeline$style[timeline$subgroup=="Virus-like particle" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_8[5],";background-color:",pal_8[3],";color:",pal_8[5],";")
timeline$style[timeline$subgroup=="Other/Unknown" & grepl("II", timeline$content)] = paste0("font-size:12px;border-color:",pal_9[5],";background-color:",pal_9[3],";color:",pal_9[5],";")

# add style for phase III timeline rows
timeline$style[timeline$subgroup=="RNA" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_1[5],";background-color:",pal_1[4],";color:",pal_1[5],";")
timeline$style[timeline$subgroup=="DNA" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_2[5],";background-color:",pal_2[4],";color:",pal_2[5],";")
timeline$style[timeline$subgroup=="Vector (non-replicating)" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_3[5],";background-color:",pal_3[4],";color:",pal_3[5],";")
timeline$style[timeline$subgroup=="Vector (replicating)" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_4[5],";background-color:",pal_4[4],";color:",pal_4[5],";")
timeline$style[timeline$subgroup=="Inactivated" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_5[5],";background-color:",pal_5[4],";color:",pal_5[5],";")
timeline$style[timeline$subgroup=="Live-attenuated" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_6[5],";background-color:",pal_6[4],";color:",pal_6[5],";")
timeline$style[timeline$subgroup=="Protein subunit" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_7[5],";background-color:",pal_7[4],";color:",pal_7[5],";")
timeline$style[timeline$subgroup=="Virus-like particle" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_8[5],";background-color:",pal_8[4],";color:",pal_8[5],";")
timeline$style[timeline$subgroup=="Other/Unknown" & grepl("III", timeline$content)] = paste0("font-size:12px;border-color:",pal_9[5],";background-color:",pal_9[4],";color:",pal_9[5],";")

# add style for terminated timeline row
timeline$style[grepl("Programme halted", timeline$content)] = paste0("font-size:12px;border-color:",pal_9[5],";background-color:",pal_9[1],";color:",pal_9[5],";")

# summary inputs for ui
total_count = nrow(landscape)
clinical_count = sum(landscape$Phase!="Pre-clinical")



### Summary plot --------------------------------------------------------------------

# combine phases II/III with phase III for plotting purposes
landscape$Phase[landscape$Phase=="Phase II/III"] = "Phase III"

# create summary dataframe with one row per platform/phase/status
ntypes = length(levels(timeline$subgroup))
summary = data.frame(Group = rep(levels(timeline$subgroup),6),
                     Phase = c(rep("Pre-clinical",ntypes),rep("Phase I",ntypes),rep("Phase I/II",ntypes),rep("Phase II",ntypes),rep("Phase III",ntypes),rep("In use",ntypes)),
                     N = 0)
summary$Stage = "Testing"
summary$Stage[summary$Phase=="In use"] = "Use"
summary$Stage = factor(summary$Stage, levels = c("Testing", "Use"))
for (i in 1:nrow(summary)) { summary$N[i] = nrow(subset(landscape, Platform==as.character(summary$Group[i]) & Phase==as.character(summary$Phase[i]))) }
for (i in 1:ntypes) { summary$N[summary$Phase=="In use"][i] = nrow(subset(landscape, Platform==as.character(summary$Group[i]) & In.use=="Yes")) }
summary$N[summary$N==0] = NA

# set levels
summary$Group = factor(summary$Group, levels=rev(c("RNA", "DNA", "Vector (non-replicating)", "Vector (replicating)", "Inactivated", "Live-attenuated",
                                                   "Protein subunit", "Virus-like particle", "Other/Unknown")))
summary$Phase = factor(summary$Phase, levels=c("Pre-clinical", "Phase I", "Phase I/II", "Phase II", "Phase III", "In use"))

# generate summary plot
summary_plot = ggplot(summary, aes(x=Phase, y=Group, colour=Group, label=N)) + geom_point(alpha = 0.8, aes(size=N)) + theme_bw() +
  scale_colour_manual(values = c("RNA" = pal_1[1], "DNA" = pal_2[1], "Vector (non-replicating)" = pal_3[1], "Vector (replicating)" = pal_4[1], 
                                 "Inactivated" = pal_5[1], "Live-attenuated" = pal_6[1], "Protein subunit" = pal_7[1], "Virus-like particle" = pal_8[1],
                                 "Other/Unknown" = pal_9[1])) +
  xlab("") + ylab("") + 
  scale_size(range = c(1, 12)) + geom_text(color="black", size=5) +
  facet_grid(.~Stage,  scales = "free", space='free') + theme(strip.background = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "", text = element_text(size=15), 
        axis.text = element_text(size=15), strip.text = element_text(size=15))
