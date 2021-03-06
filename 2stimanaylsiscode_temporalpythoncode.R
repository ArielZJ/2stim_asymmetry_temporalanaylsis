# Code from Ariel and Yusuke 

# import data frame

`dfraw_201` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5db43b6a2f45e7000bb7ab5c_Colour_Similarity_Experiment_2020-11-19_05h15.33.032.csv")
`dfraw_202` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5ac56ef9fa3b4e0001737190_Colour_Similarity_Experiment_2020-11-19_01h15.45.795.csv")
`dfraw_203` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5f813d7e8973881f63254341_Colour_Similarity_Experiment_2020-11-18_23h40.09.657.csv")
`dfraw_204` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5ea5a65ce9c797598273b3ba_Colour_Similarity_Experiment_2020-11-19_04h34.10.630.csv")
`dfraw_205` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5f40c462ff2ee620d5bc5acd_Colour_Similarity_Experiment_2020-11-18_20h52.02.060.csv")
`dfraw_206` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5f3eae2b3dd0a010c0002168_Colour_Similarity_Experiment_2020-11-19_04h38.25.830.csv")
`dfraw_207` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5eadd6d03dcdd00d2aea4c72_Colour_Similarity_Experiment_2020-11-18_20h50.28.028.csv")
`dfraw_208` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5b3937c57bc6be00010caf12_Colour_Similarity_Experiment_2020-11-18_20h38.33.652.csv")
`dfraw_209` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5b99c0a6a9c8150001d33bbc_Colour_Similarity_Experiment_2020-11-18_18h43.25.664.csv")
`dfraw_210` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5eac66ab9334300f4c37121b_Colour_Similarity_Experiment_2020-11-19_03h32.57.276.csv")
`dfraw_211` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5b2b03070ec82d0001d28898_Colour_Similarity_Experiment_2020-11-18_23h36.36.213.csv")
`dfraw_212` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5f514e2a5552dd37bc2060f3_Colour_Similarity_Experiment_2020-11-19_02h34.00.585.csv")
`dfraw_213` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5cf80c2ccbe8f10016dba137_Colour_Similarity_Experiment_2020-11-18_20h34.49.712.csv")
`dfraw_214` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5fa27915a7a32b44f3b2f44a_Colour_Similarity_Experiment_2020-11-19_03h31.31.209.csv")
`dfraw_215` <- read.csv("/Users/bethfisher/Documents/Pilotdata_simcolour/5d4857023c661b0001653a5d_Colour_Similarity_Experiment_2020-11-20_01h01.24.749.csv")


trial_vars<- c( "participant",
                "Colour_1", "Colour_2", "Colour1", "Colour2", 
                "similarity", "response_time", "catchnumber", "Ecc", "catchnumberprac", "catchresponse", "catchtrialorder", "screen_size_x","screen_size_y","viewerdistancecm", 'viewer_distance',"trialnumber")

dftrials_201 <- dfraw_201[trial_vars]
dftrials_202 <- dfraw_202[trial_vars]
dftrials_203 <- dfraw_203[trial_vars]
dftrials_204 <- dfraw_204[trial_vars]
dftrials_205 <- dfraw_205[trial_vars]
dftrials_206 <- dfraw_206[trial_vars]
dftrials_207 <- dfraw_207[trial_vars]
dftrials_208 <- dfraw_208[trial_vars]
dftrials_209 <- dfraw_209[trial_vars]
dftrials_210 <- dfraw_210[trial_vars]
dftrials_211 <- dfraw_211[trial_vars]
dftrials_212 <- dfraw_212[trial_vars]
dftrials_213 <- dfraw_213[trial_vars]
dftrials_214 <- dfraw_214[trial_vars]
dftrials_215 <- dfraw_215[trial_vars]

# Create one data frame with all participants  
dftrials <- rbind(dftrials_201, dftrials_202, dftrials_203, dftrials_204, dftrials_205, dftrials_206, dftrials_207, dftrials_208, dftrials_209, dftrials_210, dftrials_211, dftrials_212, dftrials_213, dftrials_214, dftrials_215)

# Save dataframe
setwd("/Users/bethfisher/Documents/Pilotdata_simcolour")
save(dftrials, file="dftrials_pilotdata.Rdata")

# LOAD DATA
setwd("/Users/bethfisher/Documents/Pilotdata_simcolour")
load("dftrials_pilotdata.Rdata") 

# live dangerously, get rid of pesky warnings
oldw <- getOption("warn")
options(warn = -1)

shhh <- suppressPackageStartupMessages # stops annoying warnings when loading libraries
library(tidyr)
library(plyr)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(MASS)
library(Matrix)
library(reshape2)
library(ape) # stats
library(vegan) # stats
library(RColorBrewer)
library(cocor)
library(DescTools)
library(reshape2)
library(grid)
library(ggplotify)



# Screen parameters 

# Screen size function 

screen_size <- function(dftrials){
  
  dftrials<- subset(dftrials, !is.na(screen_size_x), !is.na(screen_size_y))

  width <- as.numeric(substr(as.character(dftrials$screen_size_x)[1],1,6))
  height <- as.numeric(substr(as.character(dftrials$screen_size_y)[1],1,6))
  
  # use pythagoras to just get the hypotenuse. Subjects have a fixed 16/9 aspect ratio so these are all comparable
  return(sqrt(width*width + height*height))
}

# View distance function 

view_distance <- function(datadf){
  return(as.numeric(substr(as.character(datadf$viewer_distance)[1],1,6)))
}

# Calculate screen parameters for each participant 

screen_parameters <- function(dftrials,individual=FALSE){
  
  subjectlist <- sort(unique(dftrials$participant))
  print("Screen Parameters")
  screen_fail = 0
  viewing_fail = 0
  for (participant in subjectlist){

    subjectdf <- dftrials[which(dftrials$participant == participant),] 
    
    
    screen_size <- round(screen_size(subjectdf)/10,1)
    viewing_distance <- round(view_distance(subjectdf)/10,1)
    
    if(screen_size < 20){screen_fail = screen_fail + 1}
    if(viewing_distance < 30){viewing_fail = viewing_fail + 1}
    
    if(individual){
      print(paste("Subject",participant,":"))
      print(paste("Screen size:",screen_size,"cm"))
      print(paste("Viewing distance:",viewing_distance,"cm"))
      print("")
    }
    
    
  }
  print("")
  print(paste("Screen size issues:",screen_fail,"/",length(subjectlist)))
  print(paste("Viewing distance issues:",viewing_fail,"/",length(subjectlist)))
}  


screen_parameters(dftrials,individual=TRUE)

## HELP NEEDED CATCH TRIAL ORDER INTO VECTOR ##

library(stringr)

# Create data frame with catch trial order 

dfcatch <- dftrials[which(!is.na(dftrials$trialnumber)),] 

# Creates numeric vector but the first and last numbers are NA

dfcatch$catchtrialnumeric <- lapply(str_split(dfcatch$catchtrialorder,","), as.numeric)

# Does not work only NAs
dfcatch$catchtrialnum <- as.numeric(dfcatch$catchtrialorder)



# My attempt 

subjectdf <- dfcatch[which(dfcatch$participant == '5db43b6a2f45e7000bb7ab5c'),] 
catchtrialorderv <- c(194,66,46,191,122,18,180,70,148,30,165,120,117,196,248,111,12,28,121,190)
subjectdf$catchtrialo <- NA
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[1]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[2]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[3]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[4]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[5]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[6]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[7]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[8]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[9]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[10]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[11]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[12]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[13]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[14]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[15]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[16]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[17]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[18]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[19]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[20]] <-1
subjectdf <- subjectdf[which(subjectdf$catchtrialo==1),] 
subjectdf$correct <- ifelse(subjectdf$catchresponse == subjectdf$catchnumber,1,0)
score <- sum(subjectdf$correct)/nrow(subjectdf)
print(score)



subjectdf <- dfcatch[which(dfcatch$participant == '5f813d7e8973881f63254341'),] 
subjectdf$catchtrialo <- NA
subjectdf$catchtrialo[subjectdf$trialnumber == subjectdf$catchtrialorder[1]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[2]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[3]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[4]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[5]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[6]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[7]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[8]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[9]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[10]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[11]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[12]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[13]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[14]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[15]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[16]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[17]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[18]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[19]] <-1
subjectdf$catchtrialo[subjectdf$trialnumber == catchtrialorderv[20]] <-1
subjectdf <- subjectdf[which(subjectdf$catchtrialo==1),] 
subjectdf$correct <- ifelse(subjectdf$catchresponse == subjectdf$catchnumber,1,0)
score <- sum(subjectdf$correct)/nrow(subjectdf)
print(score)



dfcatch$trialnumber[dfcatch$participant == '5db43b6a2f45e7000bb7ab5c']	



# Catch trial results 

# calculate the catch trial score for a subject
catch_score <- function(dftrials){
  dftrials <- subset(dftrials,  catchtrialorder[1] == trialnumber, trialnumber == catchtrialorder[2], trialnumber == catchtrialorder[3], trialnumber == catchtrialorder[4], trialnumber == catchtrialorder[5], trialnumber == catchtrialorder[6], trialnumber == catchtrialorder[7], trialnumber == catchtrialorder[8], trialnumber == catchtrialordrer[9], trialnumber == catchtrialorder[10], trialnumber == catchtrialorder[11], trialnumber == catchtrialorder[12], trialnumber == catchtrialorder[13], trialnumber == catchtrialorder[14], trialnumber == catchtrialorder[15],trialnumber == catchtrialorder[16], trialnumber == catchtrialorder[17], trialnumber == catchtrialordrer[18], trialnumber == catchtrialorder[19],trialnumber == catchtrialorder[20])
  dftrials$correct <- ifelse(dftrials$catchnumber == dftrials$catchresponse, 1, 0) # determine whether they got the catch trials right
  score <- sum(datadf$correct)/nrow(datadf) # get the score
  return(score)
}
catch_score(dftrials)


catch_score <- function(dftrials_201){
  dftrials_201 <- subset(dftrials_201,  catchtrialorder[1] == trialnumber, trialnumber == catchtrialorder[2], trialnumber == catchtrialorder[3], trialnumber == catchtrialorder[4], trialnumber == catchtrialorder[5], trialnumber == catchtrialorder[6], trialnumber == catchtrialorder[7], trialnumber == catchtrialorder[8], trialnumber == catchtrialordrer[9], trialnumber == catchtrialorder[10], trialnumber == catchtrialorder[11], trialnumber == catchtrialorder[12], trialnumber == catchtrialorder[13], trialnumber == catchtrialorder[14], trialnumber == catchtrialorder[15],trialnumber == catchtrialorder[16], trialnumber == catchtrialorder[17], trialnumber == catchtrialordrer[18], trialnumber == catchtrialorder[19],trialnumber == catchtrialorder[20])
  dftrials_201$correct <- ifelse(dftrials_201$catchnumber == dftrials_201$catchresponse, 1, 0) # determine whether they got the catch trials right
  score <- sum(dftrials_201$correct)/nrow(dftrials_201) # get the score
  return(score)
}
catch_score(dftrials_201)
# catch trial checker
catch_trial_checker <- function(datadf){
  
  subjectlist <- sort(unique(dftrials$participant))
  print("Catch scores")
  for (participant in subjectlist){
    subjectdf <- dftrials[which(dftrials$participant == participant),] 
    
    catch_trials <- subset(dftrials, trialnumber == catchtrialorder[1], trialnumber == catchtrialorder[2], trialnumber == catchtrialorder[3], trialnumber == catchtrialorder[4], trialnumber == catchtrialorder[5], trialnumber == catchtrialorder[6], trialnumber == catchtrialorder[7], trialnumber == catchtrialorder[8], trialnumber == catchtrialordrer[9], trialnumber == catchtrialorder[10], trialnumber == catchtrialorder[11], trialnumber == catchtrialorder[12], trialnumber == catchtrialorder[13], trialnumber == catchtrialorder[14], trialnumber == catchtrialorder[15],trialnumber == catchtrialorder[16], trialnumber == catchtrialorder[17], trialnumber == catchtrialordrer[18], trialnumber == catchtrialorder[19],trialnumber == catchtrialorder[20])
    catch_num = nrow(catch_trials)
    catch_correct = nrow(subset(catch_trials, catchnumber == catchresponse))
    
    print(paste("Subject",participant,":",catch_correct,"/",catch_num))
  }
}

catch_trial_checker(dftrials)


trace_cutoff = 2 # mean dissimilarity for physically identical colours must be below this
antitrace_cutoff = 3.5 # mean dissimilarity accepted for maximally physically different colours must be above this
rt_cutoff = 700 # mean reaction times must be above this

exclude_noncompliant = FALSE

plotsubjects = FALSE
plot_within_between = FALSE
plotexpsummary = FALSE
across = FALSE
population = FALSE



# rainbowcloud theme for plotting, stolen from: 
# https://micahallen.org/2018/03/15/introducing-raincloud-plots/?utm_campaign=News&utm_medium=Community&utm_source=DataCamp.com
raincloud_theme = theme(
text = element_text(size = 10),
axis.title.x = element_text(size = 16),
axis.title.y = element_text(size = 16),
axis.text = element_text(size = 14),
axis.text.x = element_text(angle = 45, vjust = 0.5),
legend.title=element_text(size=16),
legend.text=element_text(size=16),
legend.position = "right",
plot.title = element_text(lineheight=.8, face="bold", size = 16),
panel.border = element_blank(),
panel.grid.minor = element_blank(),
panel.grid.major = element_blank(),
axis.line.x = element_line(colour = 'black', size=0.5, linetype='solid'),
axis.line.y = element_line(colour = 'black', size=0.5, linetype='solid'))

# stealing ability to make flat violin plots
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")


# Similarity judgment histogram
simhistplot <- function(datadf){
    
   plot <- ggplot(dftrials, aes(x = similarity)) + geom_bar(aes(y = ..prop..)) +
    scale_x_discrete(limits=c(0,1,2,3,4,5,6,7), name = 'Dissimilarity') +
    ylab('Frequency') + ylim(0,0.8)
    return(plot)
}

simhistplot(dftrials)

simhistplot_summary <- function(datadf){
    
    datadf$subject <- as.character(datadf$subject) # necessary for visualisation
    
    plot <- ggplot(dftrials, aes(x = similarity)) + 
    geom_line(stat='count',aes(y = ..prop..,group = subject),color='#CC9933') +
    geom_line(stat='count',aes(y = ..prop..),size=1.5) +
    scale_x_discrete(limits=c(0,1,2,3,4,5,6,7), name = 'Dissimilarity') +
    ylab('Frequency') + ylim(0,0.8)
    return(plot)
    
}

simhistplot_summary(dftrials)

# reaction time for each similarity
rsplot <- function(datadf){
    
    plot <- ggplot(dftrials, aes(x= similarity, y=response_time)) + 
    stat_summary(fun.y = mean, geom = "bar") + 
    stat_summary(fun.data = mean_se, geom = "errorbar", size =0.5, aes(width=0.5)) +
    scale_x_discrete(limits=c(0,1,2,3,4,5,6,7), name = 'Dissimilarity') + ylab('Reaction Time (s)') +
    theme(legend.position = "none") +
    ylim(0,4) # anyone taking more than 4 seconds has probably mindwandered
    
    return(plot)
}

rsplot(dftrials)

rsplot_summary <- function(datadf){
    
    datadf$subject <- as.character(datadf$subject) # necessary for visualisation
    
    plot <- ggplot(datadf, aes(x= similarity, y=response_time,group = subject, color = subject)) + 
    stat_summary(fun.y = mean, geom = "line", size=0.8) + 
    #stat_summary(fun.data = mean_se, geom = "errorbar", size =0.5, aes(width=0.5)) +
    scale_x_discrete(limits=c(0,1,2,3,4,5,6,7), name = 'Dissimilarity') + ylab('Mean Reaction Time (ms)') +
    theme(legend.position = "none") +
    ylim(0,4000) # anyone taking more than 4 seconds has probably mindwandered 
    
    return(plot)
    
}

# reaction time raincloud plot
rsplot_raincloud <- function(datadf,xtype='linear'){
    
    datadf$subject <- as.character(datadf$subject) # necessary for visualisation  
    datadf$similarity <- as.character(datadf$similarity) # necessary for visualisation
    
    ylabtext = 'Reaction Time (ms)'
    
    plot <- ggplot(datadf, aes(y = response_time, x = similarity, fill = similarity)) +
            geom_flat_violin(position = position_nudge(x = .2, y = 0), alpha = .8) +
            geom_point(aes(y = response_time, color = similarity),
                   position = position_jitter(width = .15), size = .5, alpha = 0.8) +
            geom_boxplot(width = .1, guides = FALSE, outlier.shape = NA, alpha = 0.5) +
            expand_limits(x = 5.25) +
            guides(fill = FALSE) +
            guides(color = FALSE) +
            scale_color_brewer(palette = "Spectral") +
            scale_fill_brewer(palette = "Spectral") +
            xlab('Dissimilarity') + ylab("Reaction Time (ms)")
            # coord_flip() +
            theme_bw() +
            raincloud_theme
    
    if(xtype == 'log'){
        plot <- plot + scale_y_continuous(trans='log10')
    } else{
        plot <- plot + ylim(0,5000)
    }
    
    return(plot)
}

rsplot_raincloud(dftrials,xtype='linear')

# correlation between reaction times and similarity judgements
# grouping at individual trial, individual participant, experiment or entire population level
rt_similarity_cor <- function(datadf,level='participant'){
        
    if(level=="participant"){
        datadf <- datadf %>% 
                group_by(subject) %>% 
                mutate(rt_similarity_correlation = cor(similarity,response_time))
        datadf <- aggregate(datadf, by=list(datadf$subject), FUN = mean)

                
    }
    return(datadf)
    
}
rt_similarity_cor(dftrials,level='participant')

rt_similarity_plot <- function(datadf,xlabel='BLANK'){
    
    datadf <- rt_similarity_cor(datadf)
    
    datadf[xlabel] = xlabel
    
    plot <- ggplot(datadf,aes(x=xlabel,y=rt_similarity_correlation)) + 
                geom_boxplot() + 
                geom_dotplot(binaxis='y',stackdir='center',dotsize=0.75) +
                theme(text = element_text(size=15)) + xlab("")
                ggtitle(title)
    
    plot <- plot + ylab("Correlation (Spearman)") + ylim(-1,1)
    plot <- plot + geom_hline(yintercept=0, linetype="dashed", color = "blue")
    return(plot)
}

rt_similarity_plot(dftrials,xlabel='BLANK')


# subject info
sumplot <- function(datadf){
    
    # change ms to s, add the delay for each trial
    datadf$response_time <- ((datadf$response_time + 0.125*nrow(datadf)) / 1000)
    
    plot <- ggplot(datadf, aes(x=subject, y = response_time)) + 
    stat_summary(fun.y = sum, geom = "bar") + ylim(0,1000) +
    ylab('Response Time Total') + theme(axis.title.x=element_blank(), axis.text.x = element_text(size=20))
    
    return(plot)
}


# get median reaction time
rt_avg <- function(datadf){
    return(median(datadf$response_time))
}


# function to aggregate everyone's data together
aggregate_df <- function(datadf,dependent='color'){

    # aggregate everyone's data together for the matrices
    everyonedata <- aggregate(datadf, by=list(
        datadf$Color_1,
        datadf$Color_2,
        datadf$Circle_1,
        datadf$Circle_2,
        datadf$bin1,
        datadf$bin2
        ), FUN=mean, 
    )

    # correct the column names
    everyonedata$Color_1 <- everyonedata$Group.1
    everyonedata$Color_2 <- everyonedata$Group.2
    everyonedata$Circle_1 <- everyonedata$Group.3
    everyonedata$Circle_2 <- everyonedata$Group.4
    everyonedata$bin1 <- everyonedata$Group.5
    everyonedata$bin2 <- everyonedata$Group.6
    
    return(everyonedata)
}

# Data analysis 
datadf = read.csv(filename)
savestr <- substr(filename,1,nchar(filename)-4) # for saving related files later

# Remove practice trial data
datadf <- subset(datadf, trial_number != 0)
# changing color values from RGB to hex for graphing purpose
dftrials$Colour1 <- as.character(dftrials$Colour1)
dftrials$Colour1 <- revalue(dftrials$Colour1, 
                                                    c(  "1" = '#FF0000',
                                                        "2" = '#FFAA00',
                                                        "3" = '#AAFF00',
                                                        "4" = '#00FF00',
                                                        "5" = '#00FFA9',
                                                        "6" = '#00A9FF',
                                                        "7" = '#0000FF',
                                                        "8" = '#AA00FF',
                                                        "9" = '#FF00AA'))
dftrials$Colour2 <- as.character(dftrials$Colour2)
dftrials$Colour2 <- revalue(dftrials$Colour2, 
                                                    c(  "1" = '#FF0000',
                                                        "2" = '#FFAA00',
                                                        "3" = '#AAFF00',
                                                        "4" = '#00FF00',
                                                        "5" = '#00FFA9',
                                                        "6" = '#00A9FF',
                                                        "7" = '#0000FF',
                                                        "8" = '#AA00FF',
                                                        "9" = '#FF00AA'))

# colors for the labels
# red, orange, yellow, green, cyan, cyan-blue, blue, purple, pink
colors <- c('#FF0000','#FFAA00','#AAFF00','#00FF00','#00FFA9','#00A9FF','#0000FF','#AA00FF','#FF00AA')
# can change the way the plot line up
# red, pink, orange, purple, yellow, blue, green, cyan-blue, cyan
#colors <- c('#FF0000','#FF00AA','#FFAA00','#AA00FF','#AAFF00','#0000FF','#00FF00','#00A9FF','#00FFA9')
abcolors <- sort(colors) # this was messing up the asymmetry plot, maybe useful for some other stuff

# changing from int indicators in the .csv file to more readable labels for eccentricity
foveal = -1
peripheral = 1

# set the maximum and minimum dissimilarity values for later analysis
min_val = 0
max_val = 6

# calculate the catch trial score for a subject
catch_score <- function(datadf){
  datadf <- subset(datadf, trial_type == 'catch')
  datadf$correct <- ifelse(datadf$similarity == datadf$catch_vals, 1, 0) # determine whether they got the catch trials right
  score <- sum(datadf$correct)/nrow(datadf) # get the score
  return(score)
}


# catch trial checker
catch_trial_checker <- function(datadf){
  
  subjectlist <- sort(unique(datadf$subject))
  print("Catch scores")
  for (subjectid in subjectlist){
    subjectdf = subset(datadf, subject == subjectid)
    
    catch_trials <- subset(subjectdf, trial_type == 'catch')
    catch_num = nrow(catch_trials)
    catch_correct = nrow(subset(catch_trials, catch_vals == similarity))
    
    print(paste("Subject",subjectid,":",catch_correct,"/",catch_num))
  }
}

# Remove catch trials 
datadf <- subset(datadf, trial_type != 'catch')

# screen parameters
screen_parameters <- function(datadf,individual=FALSE){
  
  subjectlist <- sort(unique(datadf$subject))
  print("Screen Parameters")
  screen_fail = 0
  viewing_fail = 0
  for (subjectid in subjectlist){
    subjectdf = subset(datadf, subject == subjectid)
    
    screen_size <- round(screen_size(subjectdf)/10,1)
    viewing_distance <- round(view_distance(subjectdf)/10,1)
    
    if(screen_size < 20){screen_fail = screen_fail + 1}
    if(viewing_distance < 30){viewing_fail = viewing_fail + 1}
    
    if(individual){
      print(paste("Subject",subjectid,":"))
      print(paste("Screen size:",screen_size,"cm"))
      print(paste("Viewing distance:",viewing_distance,"cm"))
      print("")
    }
    
    
  }
  print("")
  print(paste("Screen size issues:",screen_fail,"/",length(subjectlist)))
  print(paste("Viewing distance issues:",viewing_fail,"/",length(subjectlist)))
}


# factor the dataframes for the plot function
dissimdata2 <- function(datadf, colors){
    
    # refactor the levels so they can be plotted properly later if need be
    dftrials$Colour1 <- with(dftrials, factor(Colour1, levels = colors))
    dftrials$Colour2 <- with(dftrials, factor(Colour2, levels = colors))
    
    return(dftrials)
}

quantify_asymmetry <- function(datadf){
    
    dftrials <- dissimdata2(dftrials, colors)
    
    # aggregate over the remaining columns of interest
    nmdsdata <- aggregate(dftrials, by = list(dftrials$Colour1, dftrials$Colour2),FUN=mean)
    nmdsdata$Colour1 <- nmdsdata$Group.1
    nmdsdata$Colour2 <- nmdsdata$Group.2

    nmdsdata = subset(nmdsdata, select = c("Colour1","Colour2","similarity"))  # get rid of unnecessary columns
    
    nmdsmatrix <- spread(nmdsdata, Colour1, similarity) # convert the dataframe to a matrix
    nmdsmatrix <- data.matrix(nmdsmatrix) # change first column from colour to number (just some label stuff) 
    nmdsmatrix <- nmdsmatrix[,-1] # get rid of the labels in the first column, it messes up the code
    nmdsmatrix[is.na(nmdsmatrix)] <- 0  # change NA to 0 so sum can be calculated.
    
    matdf <- as.data.frame(as.vector(abs(nmdsmatrix - t(nmdsmatrix)))) # calculate the asymmetry
    asymmery_value <- sum(matdf)/2 # need to divide by 2 to get rid of the duplicates

    return(asymmery_value)
}

quantify_asymmetry(dftrials)


# return a list of the asymmetrical values for each subject
asymValues_list2 <- function(datadf){
    
    subjectlist <- sort(unique(datadf$subject)) # obtain a list of all the subjects
    
    asymValues_list <- vector() # array to store the values in
    
    for (ID in subjectlist){ # go through subject by subject
        subjectdf = subset(datadf, subject == ID) # select the ID for subject of interest
        asymValues_list <- c(asymValues_list, quantify_asymmetry(subjectdf))
    }
    return(asymValues_list)
}


# Dissimplot for all data 
datadf <- aggregate(datadf, by = list(datadf$Color_1, datadf$Color_2),FUN=mean)
datadf$Color_1 <- datadf$Group.1
datadf$Color_2 <- datadf$Group.2
datatemp <- dissimdata2(dftrials, colors)
datatemp <- aggregate(datatemp, by = list(datatemp$Colour1, datatemp$Colour2),FUN=mean)


dissimplot_temporal <- function(datadf,colors,dependent='color'){
    
    # refine data using function "dissimdata2 "
    datatemp <- dissimdata2(dftrials, colors)
    datatemp <- aggregate(datatemp, by = list(datatemp$Colour1, datatemp$Colour2),FUN=mean)
    
    plot <- ggplot(datatemp, aes(x = Group.1, y = Group.2)) +
    theme(axis.text.x = element_text(colour = colors), axis.text.y = element_text(colour = colors),
                      axis.title.x = element_blank(), axis.title.y = element_blank(),
                      plot.title = element_text(hjust = 0.5))
    
    # stuff that's standard across plot types
        plot <- plot + geom_raster(aes(fill = similarity)) +
                labs(title = 'Presented - Response Screen') +
                scale_fill_gradientn(colours = c("white","black")) +
                guides(fill=guide_legend(title="Dissimilarity"))
    return(plot)
}

dissimplot_temporal(dftrials,colors,dependent='color')

# Plot a dissmiliarity matrix for each subject manually 
dissimplot_temporal_subject <- function(datadf, colors, ID){
  
  #Subset data for the subject 
  subjectdf = subset(datadf, subject == ID) 
  
  # labeling the types
  label1 <- "Subject ID:"
  label2 <- ID
  
  # refine data using function "dissimdata2 "
  datatemp <- dissimdata2(subjectdf, colors)
  
  plot <- ggplot(datatemp, aes(x = Color_1, y = Color_2)) +
    theme(axis.text.x = element_text(colour = colors), axis.text.y = element_text(colour = colors),
          axis.title.x = element_blank(), axis.title.y = element_blank(),
          plot.title = element_text(hjust = 0.5))
  
  # stuff that's standard across plot types
  plot <- plot + geom_raster(aes(fill = similarity)) +
    labs(title = label1, label2, sep = " to ") +
    scale_fill_gradientn(colours = c("white","black")) +
    guides(fill=guide_legend(title="Dissimilarity"))
  return(plot)
}

# Plot a dissimilarity matrix for each subject by going through a list 

temp_dissim <- function(datadf){
  subjectlist <- sort(unique(datadf$subject)) # obtain a list of all the subjects
  plot_list <- list()
  k = 0
  
  for (ID in subjectlist){ # go through subject by subject
    k = k + 1
    subjectdf = subset(datadf, subject == ID) # select the ID for subject of interest
    plot <- dissimplot_temporal_subject(subjectdf,colors,ID)
    plot_list[[k]] <- as.grob(plot) # add it to the plot_list
    
  }
  g <- marrangeGrob(plot_list, nrow=2,ncol=2) # need to manually change layout
  return(g)
}

# Asymmtery matrix temporal

df2mat_asymmetry_temporal <- function(datadf){
    
    datatemp <- dissimdata2(dftrials, colors)
    
    # aggregate over the remaining columns of interest
    nmdsdata <- aggregate(datatemp, by = list(datatemp$Colour1, datatemp$Colour2),FUN=mean)
    nmdsdata$Colour1 <- nmdsdata$Group.1
    nmdsdata$Colour2 <- nmdsdata$Group.2

    nmdsdata = subset(nmdsdata, select = c("Colour1","Colour2","similarity"))  # get rid of unnecessary columns
    nmdsmatrix <- spread(nmdsdata, Colour1, similarity) # convert the dataframe to a matrix
    #nmdsmatrix[is.na(nmdsmatrix)] <- 0  # change NA to 0 
    nmdsmatrix <- data.matrix(nmdsmatrix) # change first column from colour to number(just some label stuff) 
    nmdsmatrix <- nmdsmatrix[,-1] # get rid of the labels in the first column, it messes up the code
    matdf <- as.data.frame(nmdsmatrix - t(nmdsmatrix)) # calculate the asymmetry
    #matdf$colorset <- c(abcolors) # adding additional column "colorset"
    matdf$colorset <- c(colors) # adding additional column "colorset"
    num_colors <- length(colors)
    matdf <- matdf %>% gather(othercolor,asymmetry ,1:num_colors) # convert the matrix back to the data frame which has the 
                                                                  # column "colortset", "othercolor", "asymmetry"
    return(matdf)
}


df2mat_asymmetry_temporal(dftrials)

# plot an asymmetry matrix for all data
asymmetry_plot_temporal <- function(datadf, colors){

  datatemp <- df2mat_asymmetry_temporal(dftrials)
  
  # refactor the levels so they can be plotted properly later if need be
  datatemp$colorset <- with(datatemp, factor(colorset, levels = colors))
  datatemp$othercolor <- with(datatemp, factor(othercolor, levels = colors))
  
  plot <- ggplot(datatemp, aes(x = colorset, y = othercolor)) +
    theme(axis.text.x = element_text(colour = colors), axis.text.y = element_text(colour = colors),
          axis.title.x = element_blank(), axis.title.y = element_blank(),
          #axis.title.x = element_text("left"), axis.title.y = element_text("right"),
          plot.title = element_text(hjust = 0.5))
  
  # stuff that's standard across plot types
  plot <- plot + geom_raster(aes(fill = asymmetry)) +
    labs(title = 'Presented - Response Screen') +
    scale_fill_gradientn(colours = c("blue","white","red"), limits = c(-4,4)) +
    guides(fill=guide_legend(title="Dissimilarity\nAsymmetry"))
  return(plot)
}

asymmetry_plot_temporal(dftrials, colors)

# Plot an asymmetry matrix for each subject manually 
asymmetry_plot_temporal_subject <- function(datadf, colors, ID){
  
  subjectdf = subset(datadf, subject == ID) 
  
  # labeling the types
  label1 <- "Subject ID:"
  label2 <- ID
  
  datatemp <- df2mat_asymmetry_temporal(subjectdf)
  
  # refactor the levels so they can be plotted properly later if need be
  datatemp$colorset <- with(datatemp, factor(colorset, levels = colors))
  datatemp$othercolor <- with(datatemp, factor(othercolor, levels = colors))
  
  plot <- ggplot(datatemp, aes(x = colorset, y = othercolor)) +
    theme(axis.text.x = element_text(colour = colors), axis.text.y = element_text(colour = colors),
          axis.title.x = element_blank(), axis.title.y = element_blank(),
          #axis.title.x = element_text("left"), axis.title.y = element_text("right"),
          plot.title = element_text(hjust = 0.5))
  
  # stuff that's standard across plot types
  plot <- plot + geom_raster(aes(fill = asymmetry)) +
    labs(title = paste(label1, label2, sep = " to ")) +
    scale_fill_gradientn(colours = c("blue","white","red"), limits = c(-4,4)) +
    guides(fill=guide_legend(title="Dissimilarity\nAsymmetry"))
  return(plot)
}
  
# Plot asymmetry plot for each subject by going through list 

temp_asymplot <- function(datadf){
  # matrix to use to define the plot layout, specified manually for now
  subjectlist <- sort(unique(datadf$subject)) # obtain a list of all the subjects
  plot_list <- list()
  k = 0
    
    for (ID in subjectlist){ # go through subject by subject
      k = k + 1
      subjectdf = subset(datadf, subject == ID) # select the ID for subject of interest
      plot <- asymmetry_plot_temporal_subject(subjectdf,colors,ID)
      plot_list[[k]] <- as.grob(plot) # add it to the plot_list
      
    }
    g <- marrangeGrob(plot_list, nrow=2,ncol=2)
    return(g)
  }











