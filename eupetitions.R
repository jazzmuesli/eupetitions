library(dplyr)
library(ggparliament)
library(ggplot2)

combined=read.csv("combined.csv")
combined$party=gsub("^(\\S+).*","\\1", combined$resultOfElection)
rev_model=lm(revoke_sign_count~euref+electorate,combined)
nod_model=lm(nodeal_sign_count~euref+electorate,combined)
combined$rev_predicted=predict(rev_model, combined[,c("euref","electorate")])
combined$nod_predicted=predict(nod_model, combined[,c("euref","electorate")])
summary(nod_model)
summary(rev_model)
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
p1=ggplot(combined,aes(x=euref,y=revoke_sign_count/electorate,colour=party))+geom_point()+ggtitle("Signatures to revoke A50/electorate by EU referendum result")+xlab("%leave in 2016 EU referendum")+ylab("Signatures/electorate")+scale_colour_manual(values = combined$colour, limits = combined$party)+theme(legend.position = "none") 
p2=ggplot(combined,aes(x=euref,y=nodeal_sign_count/electorate,colour=party))+geom_point()+ggtitle("Signatures for no-deal Brexit/electorate by EU referendum result")+xlab("%leave in 2016 EU referendum")+ylab("Signatures/electorate")+scale_colour_manual(values = combined$colour, limits = combined$party)
ggsave(filename = "charts.png", grid.arrange(p1,p2,ncol=2),dpi = 320, width = 297,height = 210,units="mm")
combined$party=gsub("^(\\S+).*","\\1", combined$resultOfElection)
write.csv(combined,"combined.csv",row.names = F)

data=read.csv("vcombined.csv")
data$party=gsub("^(\\S+).*","\\1", data$resultOfElection)
library(nnet)
model=nnet::nnet(mv3~mv1+mv2+party+euref+majority+electorate+turnout+revoke_sign_count+nodeal_sign_count+iv2_c+iv2_d+iv2_e+iv2_g, data,size=30)
# simpler network provides more realistic results
model=nnet::nnet(mv3~mv2+mv1+euref+party+iv2_d+iv2_c+iv2_e, data,size=10)
data$pred_mv3=predict(model, data,type = "class")
data$pred_mv3_yes=predict(model, data,type = "raw")[,2]
data$pred_mv3_no=predict(model, data,type = "raw")[,3]
# defeated by 22 votes
table(data$pred_mv3_yes>0.5)[2]-table(data$pred_mv3_no>0.5)[2]
vote_f=function(x) {ifelse(x=="AyeVote",1,ifelse(x=="NoVote",-1,0))}
cor(sapply(data[,grep("^[im]v[123]", names(data),value=T)], vote_f))
x=sapply(data[,grep("^[im]v[123]", names(data),value=T)], vote_f)
m=cbind(x,data[,c("euref","nodeal_sign_count","revoke_sign_count")])
corrplot::corrplot(cor(m))