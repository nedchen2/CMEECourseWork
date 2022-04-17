groupID = "Infection" ##############################

metadata <- read.table("./sample-metadata.tsv",header = T,row.names = 1)

sampFile = as.data.frame(metadata[, groupID],row.names = row.names(metadata))

# read the file from the alpha diversity result
alpha_div <- read.table("../results/4.Alpha_result/alpha_diversity_vector/observed_features/alpha-diversity.tsv")


index = colnames(alpha_div) #########################



# cross-filtering
idx = rownames(metadata) %in% rownames(alpha_div)
metadata = metadata[idx,,drop=F]
#alpha_div = as.data.frame(alpha_div[rownames(metadata),],row.names = rownames(metadata))



# combine alpha diversity and meta table
df = cbind(alpha_div[rownames(sampFile),index], sampFile)
colnames(df) = c("alpha","group")


# aov
model = aov(df[[index]] ~ group, data=df)
# Tukey-significance test
Tukey_HSD = TukeyHSD(model, ordered = TRUE, conf.level = 0.95)

Tukey_HSD_table = as.data.frame(Tukey_HSD$group)

#save the result from the tukey test
write.table(paste(date(), "\nGroup\t", groupID, "\n\t", sep=""), file=paste("alpha_boxplot_TukeyHSD.txt",sep=""),append = T, quote = F, eol = "", row.names = F, col.names = F)
suppressWarnings(write.table(Tukey_HSD_table, file=paste("alpha_boxplot_TukeyHSD.txt",sep=""), append = T, quote = F, sep="\t", eol = "\n", na = "NA", dec = ".", row.names = T, col.names = T))


# 函数：将Tukey检验结果P值转换为显著字母分组
# 输入文件为图基检验结果和分组
generate_label_df = function(TUKEY, variable){
  library(multcompView)
  # 转换P值为字母分组
  ## 提取图基检验中分组子表的第4列P adjust值
  Tukey.levels = TUKEY[[variable]][,4]
  ## multcompLetters函数将两两p值转换为字母，data.frame并生成列名为Letters的数据框
  Tukey.labels = data.frame(multcompLetters(Tukey.levels)['Letters'])
  
  # 按分组名字母顺序
  ## 提取字母分组行名为group组名
  Tukey.labels$group = rownames(Tukey.labels)
  # 按组名的字母顺序排列，默认的Levels
  Tukey.labels=Tukey.labels[order(Tukey.labels$group), ]
  return(Tukey.labels)
}

# 当只有两组时，用LSD标注字母
if (length(unique(df$group)) == 2){
  # LSD检验，添加差异组字母
  library(agricolae)
  out = LSD.test(model, "group", p.adj="none")
  stat = out$groups
  # 分组结果添入Index
  df$stat=stat[as.character(df$group),]$groups
  # 当大于两组时，用multcompView标注字母
}else{
  # library(multcompView)
  LABELS = generate_label_df(Tukey_HSD , "group")
  df$stat=LABELS[as.character(df$group),]$Letters
}

# 设置分组位置为各组y最大值+高的5%
max=max(df[,c(index)])
min=min(df[,index])
x = df[,c("group",index)]
y = x %>% group_by(group) %>% summarise_(Max=paste('max(',index,')',sep=""))
y=as.data.frame(y)
rownames(y)=y$group
df$y=y[as.character(df$group),]$Max + (max-min)*0.05
# head(df)

# ================== calculate the sd and mean


went = df %>% group_by(group) %>% summarize(mean = mean(alpha),SD = sd(alpha),label = unique(stat)) 
#or
#wen1 = as.data.frame(tapply(as.vector(as.matrix(df[1])), df$group, mean, na.rm=TRUE))
#wen2 = as.data.frame(tapply(as.vector(as.matrix(df[1])), df$group, sd, na.rm=TRUE))
#went = cbind(wen1, wen2)
#colnames(went) = c("mean","SD")
#aa = distinct(df, group, .keep_all = TRUE)
#went$label = aa$stat[match(row.names(went),aa$group)]
#went$Groups = row.names(went)

a = max(went$mean + went$SD)*1.1

# =========== barplot
p = ggplot(went, aes(x = group, y = mean, colour= group)) +
  geom_bar(aes(colour= group, fill = group), stat = "identity", width = 0.4, position = "dodge") +
  scale_y_continuous(expand = c(0,0),limits = c(0,a)) +
  geom_errorbar(aes(ymin = mean-SD, ymax=mean+SD), colour="black", width=0.1, size = 1) +
  geom_text(aes(label = label,y = mean+SD, x = group, vjust = -0.3), color = "black") +
  theme_classic() +
  theme(text=element_text(family="sans", size=7))
p

# other significant visualization format

p_value_one <- data.frame(
  group = c("Infected", "Infected", "Uninfected", "Uninfected"),
  alpha = c(50, 60, 60, 50))


p + geom_line(data = p_value_one, aes(x = group, y =alpha, group = 1)) +
  annotate("text", x = 1.5, y = 60, label = "*",size = 8, color = "#22292F")




# ========== boxplot
#df[[index]]  can be used to aes variable to the ggplot

p = ggplot(df, aes(x=group, y=alpha, color=group)) +
  geom_boxplot(alpha=1, outlier.shape = NA, outlier.size=0, size=0.7, width=0.5, fill="transparent") +
  labs(x="Groups", y=paste(index, "index"), color=groupID) + theme_classic() +
  geom_text(data=df, aes(x=group, y=y, color=group, label=stat)) +
  geom_jitter(position=position_jitter(0.17), size=1, alpha=0.7)+
  theme(text=element_text(family="sans", size=7))
p





