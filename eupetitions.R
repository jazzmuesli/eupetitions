library(ggplot2)

combined=read.csv("combined.csv")
combined$sig_over_electorate=combined$signature_count/combined$electorate
combined$sig_over_turnout=combined$signature_count/combined$turnout
cor(combined$sig_over_electorate, combined$euref)
cor(combined$sig_over_turnout, combined$euref)
summary(lm(signature_count~electorate+turnout+euref,combined))
head(combined)
combined$conservative=FALSE
combined$labour=FALSE
combined[grep("Con", combined$resultOfElection),"conservative"]=T
combined[grep("Lab", combined$resultOfElection),"labour"]=T
combined$party=gsub("^(\\S+).*","\\1", combined$resultOfElection)
summary(combined[combined$labour==T,"sig_over_turnout"])
ggplot(combined,aes(x=euref,y=sig_over_turnout,colour=party))+geom_point()+ggtitle("Signatures/last GE turnout by EU referendum result")
