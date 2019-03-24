library(dplyr)
library(ggparliament)
library(ggplot2)

combined=read.csv("combined.csv")
combined$party=gsub("^(\\S+).*","\\1", combined$resultOfElection)
summary(lm(revoke_sign_count/electorate~party+euref,combined))
summary(lm(nodeal_sign_count/electorate~party+euref,combined))
uk_data <- election_data %>%
  filter(country == "UK") %>%
  filter(year == 2017) %>% #parliament_data() can be called in a dplyr chain.
  parliament_data(election_data = ., 
                  party_seats = .$seats,
                  #need to include grouping for opposing benches by definition
                  group = .$government,
                  parl_rows = 12,
                  type = "opposing_benches")
party_colours=unique(uk_data[,c("party_short","colour")])
party_colours=rbind(party_colours, data.frame(party_short="LD", colour=party_colours[party_colours=="LibDem","colour"]))
combined=merge(combined,party_colours,by.x = "party",by.y="party_short")
p1=ggplot(combined,aes(x=euref,y=revoke_sign_count/electorate,colour=party))+geom_point()+ggtitle("Signatures to revoke A50/electorate by EU referendum result")+xlab("%leave in 2016 EU referendum")+ylab("Signatures/electorate")+scale_colour_manual(values = combined$colour, limits = combined$party)
p2=ggplot(combined,aes(x=euref,y=nodeal_sign_count/electorate,colour=party))+geom_point()+ggtitle("Signatures for no-deal Brexit/electorate by EU referendum result")+xlab("%leave in 2016 EU referendum")+ylab("Signatures/electorate")+scale_colour_manual(values = combined$colour, limits = combined$party)
grid.arrange(p1,p2,ncol=2)
