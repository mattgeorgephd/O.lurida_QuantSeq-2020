# read in data 
histology <- read.csv("raw-data/histology_data.csv", header=T, stringsAsFactors = T, na.strings = "NA") %>%
    mutate_at(c("Female.Stage", "Male.Stage", "Sex.redo", "Dom.Stage.redo"), funs(factor(.))) %>% droplevels()

# Relevel a couple columns 
histology$Sex.redo <- factor(histology$Sex.redo, levels=c("I", "M", "HPM", "H", "HPF", "F"))
histology$PCO2 <- factor(histology$PCO2, levels = c("Pre","High","Amb")) 

# make an empty dataframe for test statistic results 

View(histology)
# ------- Compare pH treatments - effect of pH? 
histology <- histology %>% filter(TEMPERATURE==6)

# Prepare contingency tables 
CT.sex <- table(histology$PCO2, histology$Sex.redo)
CT.sex.pop <- table(histology$PCO2, histology$Sex.redo, histology$POPULATION)
CT.sex.pop.plots <- table(histology$PCO2, histology$Sex.redo, histology$POPULATION)
CT.domsex.stage <- table(histology$PCO2, histology$Dom.Stage.redo)
CT.domsex.stage.pop <- table(histology$PCO2, histology$Dom.Stage.redo, histology$POPULATION)
CT.malestage <- table(histology$PCO2, histology$Male.Stage)
CT.malestage.pop <- table(histology$PCO2, histology$Male.Stage, histology$POPULATION)
CT.femstage <- table(histology$PCO2, histology$Female.Stage)
CT.femstage.pop <- table(histology$PCO2, histology$Female.Stage, histology$POPULATION)


# SEX RATIOS

# DABOB BAY
fisher.test(CT.sex.pop[-1,,"HL"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <--- 
fisher.test(CT.sex.pop[-2,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? NO diff 
fisher.test(CT.sex.pop[-3,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

# FIDALGO BAY
fisher.test(CT.sex.pop[-1,,"NF"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <--- 
fisher.test(CT.sex.pop[-2,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? YES diff
fisher.test(CT.sex.pop[-3,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

# OYSTER BAY
fisher.test(CT.sex.pop[-1,,"SN"], simulate.p.value = T, B = 10000) # ambient vs high? YES diff <--- 
fisher.test(CT.sex.pop[-2,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? YES diff 
fisher.test(CT.sex.pop[-3,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

#CONCLUSION: OYSTER BAY SEX DIFFERENT BETWEEN PCO2 EXPOSURE. MORE FEMALES. FIDALGO BAY AND OYSTER BAY SEX RATIO BOTH CHANGED IN AMBIENT PCO2, BUT DABOB BAY DID NOT CHANGE.  

## SPERM DEVELOPMENT 

# Stage of sperm differ by pCO2, by each population 

# DABOB BAY
fisher.test(CT.malestage.pop[-1,,"HL"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <---  
fisher.test(CT.malestage.pop[-2,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? NO diff 
fisher.test(CT.malestage.pop[-3,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. high? YES diff

# FIDALGO BAY
fisher.test(CT.malestage.pop[-1,,"NF"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <---  
fisher.test(CT.malestage.pop[-2,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? NO diff 
fisher.test(CT.malestage.pop[-3,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

# OYSTER BAY
fisher.test(CT.malestage.pop[-1,,"SN"], simulate.p.value = T, B = 10000) # ambient vs high? YES diff <---  
0.0049*9
fisher.test(CT.malestage.pop[-2,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? YES diff 
fisher.test(CT.malestage.pop[-3,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

# CONCLUSION: Oyster Bay sperm development differed between pCO2 treatments -

## EGG DEVELOPMENT 

# Stage of sperm differ by pCO2, by each population 

# DABOB BAY
fisher.test(CT.femstage.pop[-1,,"HL"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <--- 
fisher.test(CT.femstage.pop[-2,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? NO diff 
fisher.test(CT.femstage.pop[-3,,"HL"], simulate.p.value = T, B = 10000)  #Pre vs. high? YES diff

# FIDALGO BAY
fisher.test(CT.femstage.pop[-1,,"NF"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <--- 
fisher.test(CT.femstage.pop[-2,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? YES diff
fisher.test(CT.femstage.pop[-3,,"NF"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

# OYSTER BAY
fisher.test(CT.femstage.pop[-1,,"SN"], simulate.p.value = T, B = 10000) # ambient vs high? NO diff <--- 
fisher.test(CT.femstage.pop[-2,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. ambient? NO diff 
fisher.test(CT.femstage.pop[-3,,"SN"], simulate.p.value = T, B = 10000)  #Pre vs. high?  NO diff

CT.femstage.pop[,,"NF"]

### PLOTS 

# Rename columns 
colnames(CT.sex.pop.plots) <- c("Indeterminate", "Male", "Male dominant", "Hermaphroditic", "Female dominant", "Female")
colnames(CT.sex.plots) <- c("Indeterminate", "Male", "Male dominant", "Hermaphroditic", "Female dominant", "Female")
#colnames(CT.domsex.stage) <- c("Empty/No Follicles (0)", "Early (1)", "Advanced (2)", "Ripe (3)", "Spawned/Regressing (4)")
#colnames(CT.domsex.stage.pop) <- c("Empty/No Follicles (0)", "Early (1)", "Advanced (2)", "Ripe (3)", "Spawned/Regressing (4)")

plot.cohort <- c("HL","NF","SN")
plot.names <- c("Dabob Bay","Fidalgo Bay", "Oyster Bay C1")

# ----  Gonad sex for each cohort 

#pdf(file="Figures/gonad-sex-by-cohort", height = 5.75, width = 7.6)
par(mfrow=c(1,3), oma=c(5,3,0,2), mar=c(0,3,5,0), mgp=c(2.6,0.6,0))
for (i in 1:3) {
    barplot(t(prop.table(CT.sex.pop.plots[,,plot.cohort[i]], 1)), xlab=F, las=1, col=c("#f7f7f7", "#67a9cf", "#d1e5f0","gray85", "#fddbc7","#ef8a62" ), cex.lab=1.4, cex.axis = 1.2, col.axis = "gray30", col.lab = "gray30", legend.text = F)
    title(plot.names[i], line = 1, cex.main=1.5, col.main = "gray30", font.main = 1)
}
mtext(side=1,text=(expression(paste(pCO[2], " treatment"))), outer=T,line=3.5, col="gray30", font=1, cex=1.1)
mtext(side=2,text="Proportion Sampled", outer=T,line=0, col="gray30", font=1, cex=1, at=0.5)
mtext(side=3,outer=T,line=-2, col="gray30", font=3, cex=1.2, text=expression(paste("Gonad sex ratio cohort & ", pCO[2])))
#dev.off()

# ---- Sperm stage by each cohort, treatment

#pdf(file="Figures/male-gonad-stage-by-cohort", height = 5.75, width = 7.6)
par(mfrow=c(1,3), oma=c(5,3,0,2), mar=c(0,3,5,0), mgp=c(2.6,0.6,0))
for (i in 1:3) {
    barplot(t(prop.table(CT.malestage.pop[,,plot.cohort[i]], 1)), xlab=F, las=1, col=c("#f7f7f7", "#cccccc", "#636363", "#252525",  "#969696"), cex.lab=1.4, cex.axis = 1.2, col.axis = "gray30", col.lab = "gray30", legend.text = F)
    title(plot.names[i], line = 1, cex.main=1.5, col.main = "gray30", font.main = 1)

}
mtext(side=1,text=(expression(paste(pCO[2], " treatment"))), outer=T,line=3.5, col="gray30", font=1, cex=1.1)
mtext(side=2,text="Proportion Sampled", outer=T,line=0, col="gray30", font=1, cex=1, at=0.5)
mtext(side=3,outer=T,line=-2, col="gray30", font=3, cex=1.2, text=expression(paste("Sperm stage by cohort & ", pCO[2])))
#dev.off()

# Egg stage by each cohort, treatment

#pdf(file="Figures/female-gonad-stage-by-cohort", height = 5.75, width = 7.6)
par(mfrow=c(1,3), oma=c(5,3,0,2), mar=c(0,3,5,0), mgp=c(2.6,0.6,0))
for (i in 1:3) {
    barplot(t(prop.table(CT.femstage.pop[,,plot.cohort[i]], 1)), xlab=F, las=1, col=c("#f7f7f7", "#cccccc", "#636363", "#252525",  "#969696"), cex.lab=1.4, cex.axis = 1.2, col.axis = "gray30", col.lab = "gray30", legend.text = F)
    title(plot.names[i], line = 1, cex.main=1.5, col.main = "gray30", font.main = 1)
    
}
mtext(side=1,text=(expression(paste(pCO[2], " treatment"))), outer=T,line=3.5, col="gray30", font=1, cex=1.1)
mtext(side=2,text="Proportion Sampled", outer=T,line=0, col="gray30", font=1, cex=1, at=0.5)
mtext(side=3,outer=T,line=-2, col="gray30", font=3, cex=1.2, text=expression(paste("Egg stage by cohort ", pCO[2])))
#dev.off()
