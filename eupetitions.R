library(dplyr)
library(ggparliament)
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
uk_data <- election_data %>%
  filter(country == "UK") %>%
  filter(year == 2017) %>% #parliament_data() can be called in a dplyr chain.
  parliament_data(election_data = ., 
                  party_seats = .$seats,
                  #need to include grouping for opposing benches by definition
                  group = .$government,
                  parl_rows = 12,
                  type = "opposing_benches")
combined=merge(combined,unique(uk_data[,c("party_short","colour")]),by.x = "party",by.y="party_short")
ggplot(combined,aes(x=euref,y=sig_over_turnout,colour=party))+geom_point()+ggtitle("Signatures/last GE turnout by EU referendum result")+xlab("%leave in 2016 EU referendum")+ylab("Signatures/last general election turnout")+scale_colour_manual(values = combined$colour, limits = combined$party)
