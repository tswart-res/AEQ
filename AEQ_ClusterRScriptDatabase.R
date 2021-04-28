# written Windows 10 using RStudio (1.3; R 4+). Requires MATLAB for processing body heatmap plots (tested in 2018b), with the image processing toolbox.

# AEQ K-Means Clustering Program. All required packages should be automatically acquired and loaded.

# clear all vars, console, plots
rm(list=ls())
cat("\014")  
dev.off(dev.list()["RStudioGD"])

# Importing the dataset
setwd("C:/Users/Administrator/OneDrive - Goldsmiths College/Udemy/Machine Learning A-Z Template Folder/Part 4 - Clustering/Section 24 - K-Means Clustering")

if (!require('ggpubr')) install.packages('ggpubr'); library('ggpubr')
if (!require('dplyr')) install.packages('dplyr'); library('dplyr')
if (!require('factoextra')) install.packages('factoextra'); library('factoextra')
if (!require('Rmisc')) install.packages('Rmisc'); library('Rmisc')
if (!require('tidyverse')) install.packages('tidyverse'); library('tidyverse')


# Data cleaning + prep -----------------------------------------------------------

tempdf = read.csv('AEQ_ClusterMasterDatabase.csv')
tempdf <- tempdf %>% dplyr::mutate(OGIndex = row_number())

dataset <- tempdf %>%
  select(OGIndex, everything())

columnindices = 4:9

X = dataset[, c(columnindices)]
X <- na.exclude(X)
X = scale(X) # crucial for non-biased clustering


# Gap Statistic  ----------------------------------------------------------- # calculates gap statistic to aid in k (number of clusters) identification


gap_stat <- clusGap(X, FUN = hcut, K.max = 10, B = 500) 

fviz_gap_stat(gap_stat)+
  labs(title = "Optimal number of clusters determined by
  the Gap statistic
       ") +
  
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"),
        title = element_text(size=22, face="bold"),
        plot.title = element_text(hjust = 0.5))



# NbClust ----------------------------------------------------------------- # computationally heavy so disabled by default. to aid in k (number of clusters) identification


# if (!require('NbClust')) install.packages('NbClust'); library('NbClust') 
# nb <- NbClust(X, diss=NULL, distance = "euclidean",
#               method = "kmeans", min.nc=2, max.nc=15,
#               index = "alllong", alphaBeale = 0.1)
# hist(nb$Best.nc[1,], breaks = max(na.omit(nb$Best.nc[1,])))
# 
# d_dist <- dist(as.matrix(X))   # find distance matrix
# plot(hclust(d_dist))
# clusters <- identify(hclust(d_dist))


# Elbow ------------------------------------------------------------------- # to aid in k (number of clusters) identification


wcss <- vector()
for (i in 1:10) wcss[i] <- sum(kmeans(X, i)$withinss)
plot(1:10,
     wcss,
     type = 'b',
     main = paste('The Elbow Method'),
     xlab = 'Number of clusters',
     ylab = 'WCSS')


# Dendrogram fit (look for intersection at 10)    ------------------------- # to aid in k (number of clusters) identification

X.hclust.wardD2 = hclust(dist(X),method="ward.D2")
par(cex=1.5)
plot(X.hclust.wardD2,main="Optimal number of clusters determined
     by Ward's method",sub="",xlab="", ylab="Linkage Distance (squared Euclidean distances)", labels = FALSE, font.lab =2)


# Silhouette Score for determining cluster number -------------------------------------------------------- # to aid in k (number of clusters) identification

silhouette_score <- function(k){
  km <- kmeans(X, centers = k, nstart=10)
  ss <- silhouette(km$cluster, dist(X))
  mean(ss[, 3])
}
k <- 2:10
avg_sil <- sapply(k, silhouette_score)
plot(k, type='b', avg_sil, xlab='Number of clusters', ylab='Average Silhouette Scores', frame=FALSE)



# another visualisation of silhouette
fviz_nbclust(X, kmeans, method='silhouette')
fviz_nbclust(X, kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)

# k-means -----------------------------------------------------------------



clusternumber <- 7 # set k here

kmeans1 <- kmeans(X, clusternumber, iter.max = 50, nstart = 10)

# visualising clusters

if (!require('cluster')) install.packages('cluster'); library('cluster')
clusplot(X,
         kmeans1$cluster,
         lines = 0,
         shade = TRUE,
         color = TRUE,
         labels = 2,
         plotchar = FALSE,
         span = TRUE,
         main = paste('AEQ Clusters'),
         xlab = 'PCA X',
         ylab = 'PCA Y')


excludedrowindices = dataset[!complete.cases(dataset[, c(1, columnindices)]), ] # identifies CaseNo for any cases excluded due to missing data to facilitate k-means clustering


datasetmeanstemp = dataset
datasetmeans = datasetmeanstemp[-c(excludedrowindices[,1]),]

datasetmeans <- cbind(datasetmeans, clustermeans = kmeans1[["cluster"]])

# Convert it to long format
if (!require('reshape2')) install.packages('reshape2'); library('reshape2')

data_long <- melt(data=datasetmeans, id.var=c("CaseNo", "clustermeans"),
                  measure.vars=c("Head", "Body", "HeadBody", "Pleasant", "Intensity", "Calm"),
                  variable.name="ClusterVar")
names(data_long)[names(data_long)=="value"] <- "Score"
data_long$ClusterVar <- factor(data_long$ClusterVar)


# The palette with black:
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")# To use for fills, add

Maindata_bar1 <- ddply(data_long,~clustermeans ~ClusterVar,summarise,mean=mean(Score),sd=sd(Score), n = length(Score))
byintensity <- with(Maindata_bar1, reorder(clustermeans, mean))


Maindata_bar1$se <- Maindata_bar1$sd / sqrt(Maindata_bar1$n)



groupsamplesize = datasetmeans %>% dplyr::count(clustermeans)
dodge <- position_dodge(width = 0.9)
limits <- aes(ymax= Maindata_bar1$mean + Maindata_bar1$se,
              ymin = Maindata_bar1$mean - Maindata_bar1$se)
p1 <- ggplot(Maindata_bar1, aes(x = ClusterVar, y = mean, fill = byintensity))
clusterlegend <- table(datasetmeans$clustermeans)
plot1 <- p1 + geom_bar(stat = "identity", position = dodge) +
  geom_errorbar(limits, position = dodge, width = 0.25) +
  labs(x = "Cluster Variable", y = "Group Mean", fill = "Group Label") +
  # ylim(0, 1) +
  theme(axis.title=element_text(size=11, face="bold"),
        axis.text=element_text(size=11, face="bold")) +
  scale_fill_manual(values=cbbPalette,
                    labels = paste0(levels(byintensity), " (n=",groupsamplesize$n[(as.integer(levels(byintensity)))],")")) + # adds in sample size to legeend) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
plot1
#   scale_fill_discrete(labels = paste0(groupsamplesize$x, " (n=",groupsamplesize$freq,")")) + # adds in sample size to legeend



bodymapclustered = datasetmeans[, c(2, 10:length(datasetmeans))]
bodymapclustered <- na.exclude(bodymapclustered)

data_long_body <- melt(data=bodymapclustered, id.var=c("CaseNo", "clustermeans"),
                  measure.vars=c("T_FJaw_Mean", "T_FNeck_Mean",	"T_FUTorso_Mean",	"T_FShoulders_Mean",	"T_FUArms_Mean", "T_FForearms_Mean",	"T_FMTorso_Mean",	"T_FLTorso_Mean",	"T_FCrotch_Mean",	"T_FThighs_Mean",	"T_FHands_Mean",	"T_FKnees_Mean",	"T_FLegs_Mean",	"T_FFeet_Mean",	"T_BHeadTop_Mean",	"T_BNeck_Mean",	"T_BUTorso_Mean",	"T_BShoulders_Mean",	"T_BMTorso_Mean",	"T_BUArms_Mean",	"T_BForearms_Mean",	"T_BHands_Mean",	"T_BLTorso_Mean",	"T_BButtocks_Mean",	"T_BThighs_Mean",	"T_BKnees_Mean",	"T_BLegs_Mean",	"T_BFeet_Mean",	"T_FMFace_Mean",	"T_FForehead_Mean",	"T_BHeadMid_Mean",	"T_BHeadBot_Mean"),
                  variable.name="BodyLab")
names(data_long_body)[names(data_long_body)=="value"] <- "Score"
data_long_body$ClusterVar <- factor(data_long_body$ClusterVar)

data_long_bodymean <- ddply(data_long_body,~clustermeans ~BodyLab,summarise,mean=mean(Score))

data_wide_bodymean  <- spread(data_long_bodymean, BodyLab, mean)
data_wide_bodymean

# call matlab bodymap plot function and plot AEQ MK3 body maps for all clusters in separate plots

if (!require('matlabr')) install.packages('matlabr'); library('matlabr')
if (have_matlab()) {get_matlab()}

# bodymapdataset = dataset[, c(9:length(dataset))]
# bodymapdataset <- na.exclude(bodymapdataset)
# 
# bodymapdatasetcase = dataset[, c(1, 9:length(dataset))]
# bodymapdatasetcase <- na.exclude(bodymapdatasetcase)
# bodymapindex = (match(dataset$CaseNo, bodymapdatasetcase$CaseNo))

# matrix(t(bodymapindex)[t(bodymapindex) != 0], nrow = nrow(bodymapindex), byrow = TRUE)

# bodymapindex = (which(!is.na(bodymapindex)))
# 
# dataset[bodymapindex[], (length(dataset)+1] = 

# bodymapdatasetmeans = as.data.frame(t(colMeans(bodymapdataset[sapply(bodymapdataset, is.numeric)])))

BodyDataOUT = read.csv('C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/Heatmap/heatmapmatlab/AEQBodydata.csv',fileEncoding="UTF-8-BOM") # read temp body region data file
BodyDataOUT = BodyDataOUT[-c((clusternumber+1):(nrow(BodyDataOUT))),] # delete excess rows if previous cluster number was higher than current k
BodyDataOUT[1:clusternumber,1:32] = data_wide_bodymean[1:clusternumber,2:32] # overwrite data rows with current data values


row.names(BodyDataOUT) <- 1:clusternumber
write.csv(BodyDataOUT,"C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/Heatmap/heatmapmatlab/AEQBodydata.csv", row.names = FALSE)
run_matlab_script('C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/Heatmap/heatmapmatlab/RunHeatMapR.m', verbose = TRUE, desktop = TRUE, splash = FALSE, display = FALSE, wait = TRUE, single_thread = FALSE)


if (!require('png')) install.packages('png'); library('png')
img <- readPNG(paste0("C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/Heatmap/heatmapmatlab/clusteroutput/",clusternumber,"-Cluster-BodyMap.png"))
dev.new();grid::grid.raster(img)


# Assign group labels based on plots --------------------------------------



ASMRS <- c(3, 4)
ASMRW <- c(1)
ControlPos <- c(2)
ControlNeg <- c(7, 5)
FalsePos <- c(6)

datasetmeans$Group_5[datasetmeans$clustermeans %in% ASMRS] = "ASMRS" # %in% will look at each value in the array/matrix separately
datasetmeans$Group_5[datasetmeans$clustermeans %in% ASMRW] = "ASMRW"
datasetmeans$Group_5[datasetmeans$clustermeans %in% ControlPos] = "ControlPos"
datasetmeans$Group_5[datasetmeans$clustermeans %in% ControlNeg] = "ControlNeg"
datasetmeans$Group_5[datasetmeans$clustermeans %in% FalsePos] = "FalsePos"

datasetmeans$Group_2[datasetmeans$clustermeans %in% ASMRS] = "ASMRR" # %in% will look at each value in the array/matrix separately
datasetmeans$Group_2[datasetmeans$clustermeans %in% ASMRW] = "ASMRR"
datasetmeans$Group_2[datasetmeans$clustermeans %in% ControlPos] = "non-Responder"
datasetmeans$Group_2[datasetmeans$clustermeans %in% ControlNeg] = "non-Responder"
datasetmeans$Group_2[datasetmeans$clustermeans %in% FalsePos] = "FalsePos"


datasetmeans[datasetmeans$CaseNo >= 6000, ]  %>% #  square brackets allow you to index based on a logical expression.
  dplyr::count(clustermeans, Group_2)



# Append group labels back to original dataset with NA's re-integrated --------

excludedrowindices$clustermeans = NA
excludedrowindices$Group_5 = NA
excludedrowindices$Group_2 = NA
  
ClusteredFullOutput = rbind(datasetmeans, excludedrowindices)
ClusteredFullOutput = ClusteredFullOutput[order(ClusteredFullOutput$OGIndex),]


# Save Output to csv ------------------------------------------------------

write.csv(ClusteredFullOutput,"C:/Users/Administrator/OneDrive - Goldsmiths College/Studies/AEQ/MK3 (short) (prolific)/AEQData_MK3_Prolific.csv", row.names = FALSE)


## affix data long

# for (i in 1:length(data_long$clustermeans)) {
#   
#   for (o in 1:length(ASMRS[])) {
#     if (data_long$clustermeans[i] == ASMRS[o]) {
#       data_long$Group[i] <- "ASMR-S"
#       data_long$ASMRGroup[i] <- "ASMR-R"
#       data_long$ASMRGroupNoFalsePos[i] <- "ASMR-R"
#     }
#   }
#   for (o in 1:length(ASMRW[])) {
#     if (data_long$clustermeans[i] == ASMRW[o]) {
#       data_long$Group[i] <- "ASMR-W"
#       data_long$ASMRGroup[i] <- "ASMR-R"
#       data_long$ASMRGroupNoFalsePos[i] <- "ASMR-R"    
#     }
#   }
#   for (o in 1:length(ControlPos[])) {
#     if (data_long$clustermeans[i] == ControlPos[o]) {
#       data_long$Group[i] <- "Control+"
#       data_long$ASMRGroup[i] <- "non-Responder"
#       data_long$ASMRGroupNoFalsePos[i] <- "non-Responder"    
#     }
#   }
#   for (o in 1:length(ControlNeg[])) {
#     if (data_long$clustermeans[i] == ControlNeg[o]) {
#       data_long$Group[i] <- "Control-"
#       data_long$ASMRGroup[i] <- "non-Responder"
#       data_long$ASMRGroupNoFalsePos[i] <- "non-Responder"    
#     }
#   }
#   for (o in 1:length(FalsePos[])) {
#     if (data_long$clustermeans[i] == FalsePos[o]) {
#       data_long$Group[i] <- "FalsePos"
#       data_long$ASMRGroup[i] <- "non-Responder"
#       data_long$ASMRGroupNoFalsePos[i] <- NA 
#     }
#   }
# }
# 
# ## affix datameans 
# for (i in 1:length(datasetmeans$clustermeans)) {
#   
#   for (o in 1:length(ASMRS[])) {
#     if (datasetmeans$clustermeans[i] == ASMRS[o]) {
#       datasetmeans$Group[i] <- "ASMR-S"
#       datasetmeans$ASMR_YN[i] <- "ASMR-R"
#       datasetmeans$ASMR_YN_NoFalsePos[i] <- "ASMR-R"
#     }
#   }
#   for (o in 1:length(ASMRW[])) {
#     if (datasetmeans$clustermeans[i] == ASMRW[o]) {
#       datasetmeans$Group[i] <- "ASMR-W"
#       datasetmeans$ASMR_YN[i] <- "ASMR-R"
#       datasetmeans$ASMR_YN_NoFalsePos[i] <- "ASMR-R"    
#     }
#   }
#   for (o in 1:length(ControlPos[])) {
#     if (datasetmeans$clustermeans[i] == ControlPos[o]) {
#       datasetmeans$Group[i] <- "Control+"
#       datasetmeans$ASMR_YN[i] <- "non-Responder"
#       datasetmeans$ASMR_YN_NoFalsePos[i] <- "non-Responder"    
#     }
#   }
#   for (o in 1:length(ControlNeg[])) {
#     if (datasetmeans$clustermeans[i] == ControlNeg[o]) {
#       datasetmeans$Group[i] <- "Control-"
#       datasetmeans$ASMR_YN[i] <- "non-Responder"
#       datasetmeans$ASMR_YN_NoFalsePos[i] <- "non-Responder"    
#     }
#   }
#   for (o in 1:length(FalsePos[])) {
#     if (datasetmeans$clustermeans[i] == FalsePos[o]) {
#       datasetmeans$Group[i] <- "FalsePos"
#       datasetmeans$ASMR_YN[i] <- "non-Responder"
#       datasetmeans$ASMR_YN_NoFalsePos[i] <- NA 
#     }
#   }
# }
# 



