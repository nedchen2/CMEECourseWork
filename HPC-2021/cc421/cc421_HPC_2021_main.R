# CMEE 2021 HPC excercises R code main pro forma
# you don't HAVE to use this but it will be very helpful.  If you opt to write everything yourself from scratch please ensure you use EXACTLY the same function and parameter names and beware that you may loose marks if it doesn't work properly because of not using the proforma.

name <- "congjia chen"
preferred_name <- "Ned"
email <- "congjia.chen21@imperial.ac.uk"
username <- "cc421"

# please remember *not* to clear the workspace here, or anywhere in this file. If you do, it'll wipe out your username information that you entered just above, and when you use this file as a 'toolbox' as intended it'll also wipe away everything you're doing outside of the toolbox.  For example, it would wipe away any automarking code that may be running and that would be annoying!

# Question 1
species_richness <- function(community){
  return(length(unique(community)))
}

# Question 2
init_community_max <- function(size){
  return(seq(size))
}

# Question 3
init_community_min <- function(size){
  return(rep(1,size))
}

# Question 4
choose_two <- function(max_value){
  return(sample(seq(1:max_value), size = 2, replace = F))
}

# Question 5
neutral_step <- function(community){
  index <- choose_two(length(community))
  community[index[1]] <- community[index[2]]
  #community <- replace(x=community,list=index[1],community[index[2]]) alternative
  #replace(x=community,list = choose_two(length(community))[1],community[choose_two(length(community))[2]]) same species to die and reproduce
  return(community)
}

# Question 6
neutral_generation <- function(community){
  if (length(community)%%2 == 0){
    step_number <- length(community) / 2 
  }else{
    step_number <- sample(c((length(community) + 1) / 2, (length(community) - 1) /2 ),size = 1)
  }
  #print (step_number) the number for one generation that neutral_step will take place
  for (i in seq(step_number)){
    #print (i) # the vector for octaves to sumtime when looping
    community = neutral_step(community)
    #print (community) 
  }
  return(community)
}

# Question 7
neutral_time_series <- function(community,duration)  {
  #pre-allocation
  time_series_richness <- rep(NA,duration + 1)
  for (i in seq(duration + 1)){ # when the generation going on, add the richness to the time series vecter
    time_series_richness[i] <- species_richness(community)
    community <- neutral_generation(community)
  }
  return(time_series_richness )
}

# Question 8
question_8 <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  richness <- neutral_time_series(init_community_max(100),duration=200)
  plot(richness, type = "l",xlab = "Time of Generations", ylab = "Richness",
       main = "Time Series of Neutral Model Simulation Based on Initial Maximal Diversity")

  return(paste0("The system will converge to richness = 2.The reason is that in each generation, there is a probability to lose richness (species extinction) . With the decreasing of the richness across the generations, the probability to lose richness became lower. Finally,the time when only two species were left, given the equal probability of reproduction, led to the fixation of the richness (2) ."))
    
}

# Question 9
neutral_step_speciation <- function(community,speciation_rate)  {
  index1 <- sample(seq(length(community)), size = 1) # get the index randomly for old species
  if (runif(1,min  = 0, max = 1) <= speciation_rate){
    community[index1] <- max(community) + 1 #use max() to create new species
  }else{
    community <- neutral_step(community)
  }
  return(community)
}

# Question 10
neutral_generation_speciation <- function(community,speciation_rate)  {
  len <- length(community)
  if (len %% 2 == 0){ # when the number is even
    step_number <- len / 2 
  }else{ # when the number is odd, pick the step number randomly
    step_number <- sample(c((len + 1) / 2, (len - 1) /2 ),size = 1) 
  }
  for (i in seq(step_number)){
    community = neutral_step_speciation(community,speciation_rate)
  }
  return(community)
}

# Question 11
neutral_time_series_speciation <- function(community,speciation_rate,duration)  {
  #pre-allocation
  time_series_richness <- rep(NA,duration + 1)
  for (i in seq(duration + 1)){
    time_series_richness[i] <- species_richness(community) # store each generations richness in the time_series
    community <- neutral_generation_speciation(community,speciation_rate) # generate new community 
  }
  return(time_series_richness )
}

# Question 12
question_12 <- function()  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  richness <- neutral_time_series_speciation(init_community_max(100),0.1,200) # max
  richness2 <- neutral_time_series_speciation(init_community_min(100),speciation_rate = 0.1,duration=200) # min
  
  plot(richness, type = "l",xlab = "Time of Generations", ylab = "Richness",
         main = "Time Series of Neutral Model Simulation with Speciation Based on Different Initial Diversity",col = "blue", ylim = c(0,100)) #like ggplot() --- can not use add
  lines(richness2,col="red") # add line 
  legend_names <- c("Max initialized richness","Min initialized richness")
  legend("topright", legend_names,
         col = c("blue", "red"), lty = 1, bty = "n") # add legend
  return("Regardless of the initialized richness status, the richness tends to converge to the fluctuation within a similar constraints range. This is because of the dynamic equilibrium between speciation (leads to increase of richness) and extinction (leads to decrease of richness)")
}

# Question 13
species_abundance <- function(community)  { # calculate the species abundance
  return(sort(as.vector(table(community)),decreasing = T))
}

# Question 14
octaves <- function(abundance_vector) { # bin and calculate the 
  # original between 2^n and 2 ^n-1
  # log2(original) between n (not include) and n-1 (include), i.e. the bin were transformed to two adjacent integer, thats why we need tabulate()
  trans = floor(log2(abundance_vector)) + 1 # 0 will be ignored, therefore,we need to add 1 to original data.
  return(tabulate(trans))  #?tabulate() count integer 
}

# Question 15
sum_vect <- function(x, y) {
  if (length(x) <= length(y)){ #change the order as short and long
    short_vector = x
    long_vector = y}
  else{
    short_vector = y
    long_vector = x}
  short_vector = c(short_vector, rep(0, length(long_vector)-length(short_vector))) 
  return(short_vector+long_vector)
}

# Question 16 
question_16 <- function()  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  #burn in period
  
  min_start <- neutral_generation_speciation(init_community_min(100),speciation_rate = 0.1) # min
  max_start <- neutral_generation_speciation(init_community_max(100),speciation_rate =0.1)  # initialize_max
  for (i in seq(200-1)){
    max_start <- neutral_generation_speciation(max_start,speciation_rate = 0.1)
    min_start <- neutral_generation_speciation(min_start,speciation_rate = 0.1)
  }
  
  octaves_max <-octaves(species_abundance(max_start))# initialize the 1 st octaves
  octaves_min <-octaves(species_abundance(min_start))# initialize the 1 st octaves
  
  for (i in seq(2000)){ # for every 20 generations calculate the octaves and record  it as the 1 + i/20 th octaves
    max_start <- neutral_generation_speciation(max_start,0.1)
    min_start <- neutral_generation_speciation(min_start,0.1)
    if ( i %% 20 == 0) {octaves_max <- sum_vect(octaves(species_abundance(max_start)), octaves_max) 
                        octaves_min <- sum_vect(octaves(species_abundance(min_start)), octaves_min)    
    }
  }
  octaves_max_final <- octaves_max/101 # (2000/20 + 1)
  octaves_min_final <- octaves_min/101
  
  colname <- sapply(seq(length(octaves_max_final))-1, function(x) ifelse(x == 0, paste0("1"),paste0(2^x,"-",2^(x+1)-1))) # create the x-axis 
  test1 <- as.data.frame(rbind(octaves_max_final,octaves_min_final)) # t to data frame
  colnames(test1) <- colname # set the colnames
  
  barplot(as.matrix(test1), 
          xlab = "Number of individuals per species", ylab = "Counts of Species", beside = T, ylim = c(0,12),
          main = "Mean Species Abundance Distribution of Neutral Model Simulation of Different Initial Diversity",col = c("blue","red"))
  legend("topright",cex = 1, c("max", "min"),adj = c(1.2,2),
         col = c("blue", "red"), lty = 1,lwd=10, bty = "n",ncol = 2,
         text.width = 0.4)
  
  return("The initial status of the richness showed no significant influence to the final result. The reason is that, in the neutral model, the extinction and speciation account for the abundance dynamic. Extinction decreases species richness, while speciation increase diversity in the community. Finally, two factors leads a diversity dynamic equilibrium which is not effected by the initial richness")
}
#End for neutral model

# Question 17
cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name)  {

  #Start with a community with size given by the input size and minimal diversity
  
  ptm <- proc.time() #start clock
  community <- init_community_min(size)
  time_series = c(species_richness(community)) # predefined for store the richness
  octaves_list <- list(octaves(species_abundance(community))) # predefined list for octaves
  
  count_of_generation <- 0 # predefined for counts of generation

  while (unname((proc.time() - ptm)[3]) <= 60 * wall_time){ # limit the time running # while loop work better than for
    community = neutral_generation_speciation(community,speciation_rate)
    count_of_generation = count_of_generation + 1
    if (count_of_generation <= burn_in_generations & count_of_generation %% interval_rich == 0){# if the generation meet the requirement,we will reccord the richness
      time_series = c(time_series, species_richness(community)) #store it in the predefined vector
    }
    if (count_of_generation %% interval_oct == 0){ # the index of the list
      octaves_list[[length(octaves_list)+1]] = octaves(species_abundance(community)) # Only the generation based on certain interval will be stored
    }
  }
  #total time
  Final_time = paste(unname((proc.time() - ptm)[3]), " s"," or " , unname((proc.time() - ptm)[3])/60 , " min")
  
  save(speciation_rate, size, wall_time, interval_rich, interval_oct, 
       burn_in_generations, community, time_series , octaves_list, Final_time, 
       file = output_file_name)
}

# Questions 18 and 19 involve writing code elsewhere to run your simulations on the cluster

# Question 20 

function_for_process20 <- function(range){
  # save results to an .rda file
  # use load to load the .rda file
  # we want to calculate the mean of different size.
  # It should only use data of the abundance octaves after the burn in time is up.
  # store the four result vectors to the combined_results
  
  #Load results of cluster and calculate average abundances

  octaves_sum <- c() # predefined vector for octaves to sum
  counts_of_repeats <- 0 # predefined counts
  
  for (i in range){
    load(paste0("SimulationOutput_",i,".rda"))
    
    for (index in seq(length(octaves_list))){
      generations = (index -1) * interval_oct # convert the index of list into actual generations
      if (generations > burn_in_generations){ # we only need the octaves after the burn in period
        octaves_list_post_burn_in <- octaves_list[[index]] # get the octaves
        octaves_sum <-sum_vect(octaves_sum,octaves_list_post_burn_in)
        counts_of_repeats =  counts_of_repeats+1}}
  }
  mean_average <- octaves_sum/counts_of_repeats
  return(mean_average)
}  
#Load results of cluster and calculate average abundances

process_cluster_results <- function()  {
  combined_results <- list() #create your list output here to return
  mean_octaves_500 <- function_for_process20(1:25)
  mean_octaves_1000 <- function_for_process20(26:50)
  mean_octaves_2500 <- function_for_process20(51:75)
  mean_octaves_5000 <- function_for_process20(76:100)
  
  combined_results <- list(mean_octaves_500,mean_octaves_1000,
                           mean_octaves_2500, mean_octaves_5000)
  save(combined_results, file = "Processed_cluster_results.rda")
}
#process_cluster_results()
#create the name for barplot

Forming_colname <- function(octaves_vector) { 
  return (sapply(seq(length(octaves_vector))-1, function(x) ifelse(x == 0, paste0("1"),paste0(2^x,"-",2^(x+1)-1))) )
}

ploting_for_question20 <- function(data,size,lab=" Neutral Model"){
  barplot(data, names.arg = Forming_colname(data),
          xlab = paste0("Number of individuals per Species (Community Size: ", size,")"), ylab = "Species richness", 
          main = paste0("Mean Species Abundance Distribution of",lab),
          ylim = c(0, ceiling(max(data))))
}

plot_cluster_results <- function()  {
    # clear any existing graphs and plot your graph within the R window
    # load combined_results from your rda file
    # plot the graphs
  graphics.off()
  load("Processed_cluster_results.rda") # load combined_results from your rda file
  # plot the graphs
  
  par(mfrow = c(2,2))
  par(mar=c(4,4,3,0))
  ploting_for_question20(combined_results[[1]],500)
  ploting_for_question20(combined_results[[2]],1000)
  ploting_for_question20(combined_results[[3]],2500)
  ploting_for_question20(combined_results[[4]],5000)
    return(combined_results)
}

# Question 21
question_21 <- function()  {
  result = list(log(8)/log(3), "Given 3 times wider than the original shape, we can count that we need 8 small materials (The size should be 8). Therefore, 8 = 3^x, and x = log(8)/log(3)")
  return(result)
}

# Question 22
question_22 <- function()  {
  result = list(log(20)/log(3),
                "Given 3 times wider than the original shape, we can count that we need 20 small materials(The size should be 20). Therefore, 20 = 3^x, and x = log(20)/log(3)")
  return(result)
}

# Question 23
chaos_game <- function()  {
  graphics.off()# clear any existing graphs and plot your graph within the R window

  list = list(A = c(0,0),B = c(3,4),C = c(4,1))
  X = c(0,0)
  #Initialize the plot
  plot(X[1],X[2],cex=0.1, xlim = c(0,5), ylim = c(0,5), xlab = "", ylab = "",
       main = "Chaos Game")
  for (i in 1:5000){
    random_choice = sample(c(1,2,3),1) # choose index randomly
    target <- list[[random_choice]] #get target point
    X = X + 0.5*(target-X)
    points(X[1],X[2])
  }
  text(x=0,y=0.5,"A")
  text(x=3,y=4.5,"B")
  text(x=4,y=1.5,"C")
  return("A triangle constructed by A, B, C three points. It is also a Sierpinski gasket. The dimension here is log(3)/log(2).")
}

# Question 24
turtle <- function(start_position, direction, length)  {
  end_point = start_position + c(length*cos(direction), length*sin(direction)) #cal the end_point
  segments(x0=start_position[1],y0=start_position[2],x1=end_point[1],y1=end_point[2])  
  return(end_point) # you should return your endpoint here.
}

# Question 25
elbow <- function(start_position, direction, length)  {
  turtle(turtle(start_position,direction,length),direction - pi/4,length*0.95)
}

# Question 26
spiral <- function(start_position, direction, length)  {
  
  if (length >= 0.001){
  first_end_point <- turtle(start_position,direction,length) #get the first line

  spiral(first_end_point, direction - pi/4 , length*0.95) #run in function
  }
  return("Because of the limitation of the stack size, the cpu can not let the infinite iterative function go on. Therefore, computer gave us an error and break the function")
}

# Question 27
draw_spiral <- function(start_position=c(0,0), direction=pi/2, length=1)  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  
  plot(NULL, NULL,
       xlim = c(start_position[1],start_position[1]+2.5*length),
       ylim = c(start_position[2]-2.5*length, start_position[2]+2.5*length),
       main = "Show Spiral", xlab = "", ylab = "")
  text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  spiral(start_position, direction, length)
}

# Question 28
tree <- function(start_position, direction, length,threshold = 0.01)  {
  if (length >= threshold){
    first_end_point <- turtle(start_position,direction,length) #get the first line
    tree(first_end_point, direction + pi/4 , length*0.65) #draw to the left
    tree(first_end_point, direction - pi/4 , length*0.65) #draw to the right 
  }
}

draw_tree <- function(start_position=c(0,0), direction=pi/2, length=1)  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  plot(NULL, NULL,
       xlim = c(start_position[1]-2.5*length,start_position[1]+2.5*length),
       ylim = c(start_position[2], start_position[2]+2.5*length),
       main = "", xlab = "", ylab = "", axes=F)
  text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  tree(start_position, direction, length)
}

# Question 29
fern <- function(start_position, direction, length)  {
  if (length >= 0.005){
    first_end_point <- turtle(start_position,direction,length) #get the first line
    fern(first_end_point, direction + pi/4 , length*0.38) #draw to the left
    fern(first_end_point, direction , length*0.87) #no change in direction
  }
}

draw_fern <- function(start_position=c(0,0), direction=pi/2, length=1)  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  plot(NULL, NULL,
       xlim = c(start_position[1]-2.5*length,start_position[1]+2.5*length),
       ylim = c(start_position[2], start_position[2]+8*length),
       main = "", xlab = "", ylab = "",axes=F)
  text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  fern(start_position, direction, length)
}

# Question 30
fern2 <- function(start_position, direction, length, dir)  {
  if (length >= 0.005){
    first_end_point <- turtle(start_position,direction,length) #get the first line
 
    fern2(first_end_point, direction , length*0.87,  -1 * dir) # The first dir we give is 1
    fern2(first_end_point, direction + dir*pi/4 , length*0.38, dir) # when dir = 1, left, when dir = -1, right . left first and right next.
  }
}
draw_fern2 <- function(start_position=c(0,0), direction=pi/2, length=1,dir=1)  {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  plot(NULL, NULL,
       xlim = c(start_position[1]-2.5*length,start_position[1]+2.5*length),
       ylim = c(start_position[2], start_position[2]+8*length),
       main = "", xlab = "", ylab = "", axes=F)
  #text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  fern2(start_position, direction, length,dir)
}

# Challenge questions - these are optional, substantially harder, and a maximum of 16% is available for doing them.  

# Challenge question A
confid_Interval = function(data, alpha=0.028){# function for calculate the confidence interval
  n <- length(data)
  mean <- mean(data)
  tmp = sd(data)/sqrt(n)*qt(1-alpha/2, n-1)
  return(c(mean-tmp, mean+tmp))
}


Challenge_A <- function() { # this question is about the species in 
  graphics.off()# clear any existing graphs and plot your graph within the R window
  
  Richness_max_matrix = matrix(NA, nrow = 100, ncol = 100)#pre allocation
  Richness_min_matrix = matrix(NA, nrow = 100, ncol = 100)#store the richness data
  
  for (i in seq (100)){ # repeat for 100 times
    Richness_max_matrix[i,] = neutral_time_series_speciation(init_community_max(100), 0.1, 99) # because the function will return a vector of length 100
    Richness_min_matrix[i,] = neutral_time_series_speciation(init_community_min(100), 0.1, 99)
  }
  
  #calculate the mean
  Richness_max_mean <- apply(Richness_max_matrix,2,mean)
  Richness_min_mean <- apply(Richness_min_matrix,2,mean)
  #calculate the CI
  Richness_max_CI <- rbind(apply(Richness_max_matrix,2,confid_Interval),seq(100)) 
  Richness_min_CI <- rbind(apply(Richness_min_matrix,2,confid_Interval),seq(100))
  
  #plotting
  plot(Richness_max_mean, type = "l",xlab = "Time (generations)", ylab = "Species Richness",
       main = "Averaged Species Richness Time Series of Repeated Neutral Model Simulation  ",col = "blue", ylim = c(0,100)) #like ggplot() --- can not use add
  lines(Richness_min_mean,col="red")
  legend_names <- c("Maximal initial diversity","Minimal initial diversity")
  legend("topright", legend_names,
         col = c("blue", "red"), lty = 1, bty = "n")
  
  
  legend_names2 <- c("Confidence interval of maximal initial diversity","Confidence interval of minimal initial diversity")
  legend("topright", legend_names,
         col = c("blue", "red"), lty = 1, bty = "n")

  
  # confidence value
  lines(Richness_max_CI[1,],lty = "dashed", col = "blue")
  lines(Richness_max_CI[2,],lty = "dashed", col = "blue")
  
  lines(Richness_min_CI[1,],lty = "dashed", col = "red")
  lines(Richness_min_CI[2,],lty = "dashed", col = "red")
  
  legend(x=60,y=90 , legend_names2,
         col = c("blue", "red"), lty = "dashed", bty = "n")
  #segment
  #segments(x0 =  Richness_max_CI[3,], y0 = Richness_max_CI[1,], x1 =  Richness_max_CI[3,], y1 = Richness_max_CI[2,],col="black")
  #segments(x0 =  Richness_min_CI[3,], y0 = Richness_min_CI[1,], x1 =  Richness_min_CI[3,], y1 = Richness_min_CI[2,],col="green")
  
  #  Estimate generations needed for reaching dynamic equilibrium ?
  # The first time when the max_initialized_richness fall into the CI of min_initialized_richness
  i = min(Richness_max_CI[3,Richness_max_mean - Richness_min_CI[2,] < 0]) #&& Richness_max_mean > Richness_min_CI[,1]
  segments(x0 = i, y0 = 0, x1 = i, y1 = 100, col = "steelblue")#steelblue line indicates when equilibrium reached
  text(x = i + 2, y = i ,labels = paste0("Reach dynamic equilibrium in ",i,"th generation"))
  
}

# Challenge question B

# we want a function to return commuity with given richness and size with same identity (replace = T)
init_community_random <- function(size,def_richness){ # size will be predefined larger than the richness
  init_random <- seq(def_richness) # first create a community with given richness.
  supply_comunity <- sample(seq(def_richness),size-def_richness,replace = T) #create a supply community with FUNCTION sample
  init_community_random <- c(init_random,supply_comunity)
  return(init_community_random)
}

Challenge_B <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  #init a plot
  
  plot(x =NULL, y = NULL, xlim = c(0,100), ylim = c(0,100),
       main = "Neutral Model Simulation with Different Initialized Diversity",
       xlab = "Time (generations)", ylab =  "Species Richness")
  
  #define a test vector with richness 
  test_vector <- c(1,2,4,8,16,32,64,100)
  col_vector <-rainbow(length(test_vector))

  for (i in test_vector){ # have some sample richness
    location = match(i,test_vector) # get the location for colour
    
    init_community <- init_community_random(100,i) # or use replicate(100,sample(i,1)) However, defect for that is the number i can not determine the final richness.
    
    Richness_matrix = matrix(NA, nrow = 10, ncol = 100)#store the richness data
  
    for (j in seq (10)){ # repeat for 10 times
      Richness_matrix[j,] = neutral_time_series_speciation(init_community, 0.1, 99) # because the function will return a vector of length 100
    }
    
    Richness_mean = apply(Richness_matrix,2,mean) # calculate the mean
    lines(Richness_mean,col=col_vector[location]) # draw each line 
    #print (paste0("finished",i))
  }
  legend("topright",legend = test_vector,fill = col_vector,bty = "n",title = "Initialized richness",cex = 0.9)
}

# Challenge question C

process_result_for_ChallengeC <- function(range){ 
  # save results to an .rda file
  # use load to load the .rda file
  # we want to calculate the mean of different size.
  # It should only use data of the abundance octaves after the burn in time is up.
  # store the four result vectors to the combined_results
  
  #Load results of cluster and calculate average abundances
  richness_sum <- c() #predefined vector for richness to sum
  counts_of_repeats <- 0 #predefined value for counts
  
  for (i in range){
    load(paste0("SimulationOutput_",i,".rda")) # load the rda
    
    richness_sum <-sum_vect(richness_sum,time_series)
    
    counts_of_repeats =  counts_of_repeats+1 # count
  }
  mean_average <- richness_sum/counts_of_repeats # average
  return(mean_average)
}

Challenge_C <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  mean_richness_500 <- process_result_for_ChallengeC(1:25) # get the mean by predefined function
  mean_richness_1000 <- process_result_for_ChallengeC(26:50)
  mean_richness_2500 <- process_result_for_ChallengeC(51:75)
  mean_richness_5000 <-process_result_for_ChallengeC(76:100)
  
  col <- rainbow(4)
  plot(mean_richness_500, type = "l",xlab = "Time of Generations", ylab = "Richness",
       main = "Time Series of Neutral Model Simulation with Different Community Size",col = col[1],xlim = c(0,2000), ylim = c(0,250)) 
  # Because we need to study the burn in period, therefore, I limit the x axis c(0,2000)
  lines(mean_richness_1000,col=col[2])
  lines(mean_richness_2500,col=col[3])
  lines(mean_richness_5000,col=col[4])
  legend_names <-  c("500","1000","2500","5000")
  legend("topright", legend = legend_names,title = "Community Size",
         col = col, lty = 1, bty = "n",lwd = 2)
}

# Challenge question D

simulation_coalesence <- function (J,v) { # J :size, v: speciation_rate
  lineages <- init_community_min(J) # with 1 
  abundances <- c()
  N <- J
  seta <- v*(J-1)/(1-v)
  
  while (N > 1){ #  N - 1 times loop
    index_vector <- choose_two(length(lineages)) # i, j not identical
    j <- index_vector[1]
    i <- index_vector[2]
    randnum <- runif(1)

    if (randnum < seta/(seta + N - 1)){
      abundances <- c(abundances,lineages[j])
    }else{
      lineages[i] <- lineages[i] + lineages[j]
    }
    lineages = lineages[-j]
    N <- N - 1
  }
  
  abundances <-  c(abundances,lineages)
  return(abundances)
}


Challenge_D <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  v =  0.0055649 #sr
  octaves_sum_500 = c()
  octaves_sum_1000 = c()
  octaves_sum_2500 = c()
  octaves_sum_5000 = c()
  
  for (i in seq(1:25)){ #simulate as the one in the cluster for 25 times
    octaves_sum_500 <-  sum_vect(octaves_sum_500, octaves(simulation_coalesence(500, v) ))
    octaves_sum_1000 <-  sum_vect(octaves_sum_1000, octaves(simulation_coalesence(1000, v) ))
    octaves_sum_2500 <-  sum_vect(octaves_sum_2500, octaves(simulation_coalesence(2500, v) ))
    octaves_sum_5000 <-  sum_vect(octaves_sum_5000, octaves(simulation_coalesence(5000, v) ))
  
  }
  octaves_mean_500 <- octaves_sum_500/25 # average
  octaves_mean_1000 <- octaves_sum_1000/25
  octaves_mean_2500 <- octaves_sum_2500/25
  octaves_mean_5000 <- octaves_sum_5000/25
  
  load("Processed_cluster_results.rda") 
  
  #ptw = proc.time()
  #simulation_coalesence(5000, v)
  #proc.time()-ptw
  
  par(mfrow = c(4,2))#plot
  par(mar=c(4,4,3,0))
  ploting_for_question20(octaves_mean_500,500," Coalesence")
  ploting_for_question20(combined_results[[1]],500," Neutral Model")
  
  ploting_for_question20(octaves_mean_1000,1000," Coalesence")
  ploting_for_question20(combined_results[[2]],1000," Neutral Model")
  
  ploting_for_question20(octaves_mean_2500,2500," Coalesence")
  ploting_for_question20(combined_results[[3]],2500," Neutral Model")
  
  ploting_for_question20(octaves_mean_5000,5000," Coalesence")
  ploting_for_question20(combined_results[[4]],5000," Neutral Model")
  
  #plotting with 

  return("Cluster takes 11.5 hours per simulation. Coalesence takes 0.15 second per simulation. The reason is that Coalensence does not need a burn in period which would waste a lot of time in cluster simulation. Coalesence do not simulate some conditions like some species may extinct.")
}

# Challenge question E
plot_function_for_Challenge_E <- function(A=c(0,0),B=c(2,4),C=c(4,0),X=c(0,0),N=100,lab = "X c(0,0)"){
  list = list(A = A,B = B,C = C)
  X = X
  #plot
  plot(X[1],X[2],cex=0.1, xlim = c(0,6), ylim = c(0,6), xlab = "", ylab = "",
       main =paste0("Chaos Game -- ",lab))
  #text(x=X[1],y=X[2]+1,"X")
  for (i in 1:2000){
    random_choice = sample(c(1,2,3),1)
    target <- list[[random_choice]]
    if (i <= N){ # add different color to the first n step
      points(X[1],X[2],col=rgb(1,0,0,1))
    }else{
      points(X[1],X[2],col=rgb(0,0,1,0.2))
    }     
    X = X + 0.5*(target-X)
  }
  text(x=A[1],y=A[2]+0.5,"A") #add some text
  text(x=B[1],y=B[2]+0.5,"B")
  text(x=C[1],y=C[2]+0.5,"C")
  legend("topright",legend ="First 100 point",col="red", lty = 1, bty = "n")
}

Challenge_E <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  
  par(mfrow = c(2,2))
  par(mar=c(4,4,3,0))
  plot_function_for_Challenge_E(A = c(0,0),
                                B = c(3,4),
                                C = c(4,1),
                                X = c(0,0),lab = "X c(0,0)") # The first plot
  
  plot_function_for_Challenge_E(A = c(0,0), # The plot with initial X c(1,1)
                                B = c(3,4),
                                C = c(4,1),
                                X = c(1,1),lab = "X c(1,1) Within the Triangle")
  
  plot_function_for_Challenge_E(A = c(0,0), # The plot with initial X c(5,5)
                                B = c(3,4),
                                C = c(4,1),
                                X = c(5,5),lab = "X c(5,5) Out of the Triangle")
  
  plot_function_for_Challenge_E(lab = "equilateral triangle ") #equilateral triangle 
  
  
  return("Regardless of the initial position of X, a Sierpinski gasket with the outer triangle ABC is created.  Regardless of the distance between X and A,B,C, The algorithm will always make the next point closer to either A,B,or C. Therefore, Given the identical probability of that, the location within triangle ABC will be the only region where the points can exist after a certain period")
}

# Challenge question F

turtle2 <- function(start_position, direction, length,col="red",lwd=5)  {
  end_point = start_position + c(length*cos(direction), length*sin(direction))
  segments(x0=start_position[1],y0=start_position[2],x1=end_point[1],y1=end_point[2],col = col,lwd = lwd)  
  
  list1 <-list(end_point,lwd,col) # store last lwd and col value 
  return(list1) # you should return your endpoint here.
}


tree2 <- function(start_position, direction, length,threshold = 0.01,col="red",lwd = 5)  {
  if (length >= threshold){
    first_end_point <- turtle2(start_position,direction,length,col="red",lwd)[[1]]#get the first line
    lwd <- turtle2(start_position,direction,length,col="red",lwd)[[2]] # get the lwd used before
    col <- turtle2(start_position,direction,length,col="red",lwd)[[3]] # get the colour used before
    tree2(first_end_point, direction + pi/4 , length*0.65,lwd=0.75*lwd) # function
    tree2(first_end_point, direction - pi/4 , length*0.65,lwd=0.75*lwd)
  }
}

tree3 <- function(start_position, direction, length,threshold = 0.01,col=1,lwd = 5)  {
  if (length >= threshold){
    first_end_point <- turtle2(start_position,direction,length,col=col,lwd)[[1]]#get the first line
    lwd <- turtle2(start_position,direction,length,col=col,lwd)[[2]]# get the lwd used before
    col <- turtle2(start_position,direction,length,col=col,lwd)[[3]]# get the colour used before
    tree3(first_end_point, direction + pi/4 , length*0.65,col=col+1,lwd=0.75*lwd)
    tree3(first_end_point, direction - pi/4 , length*0.65,col=col+1,lwd=0.75*lwd)
  }
}

fern3 <- function(start_position, direction, length, dir,col="brown",lwd=5)  {
  if (length >= 0.01){
    first_end_point <- turtle2(start_position,direction,length,col=col,lwd)[[1]]
    lwd <- turtle2(start_position,direction,length,col=col,lwd)[[2]]#get the first line
    fern3(first_end_point, direction , length*0.87,-dir,col="brown",lwd=0.75*lwd)
    fern3(first_end_point, direction + dir*pi/4 , length*0.38, dir,lwd=0.75*lwd)
  }
}

fern4 <- function(start_position, direction, length, dir,col=1,lwd=5)  {
  if (length >= 0.01){
    first_end_point <- turtle2(start_position,direction,length,col=col,lwd)[[1]]
    lwd <- turtle2(start_position,direction,length,col=col,lwd)[[2]]# get the lwd used before
    col <- turtle2(start_position,direction,length,col=col,lwd)[[3]]# get the colour used before
    fern4(first_end_point, direction , length*0.87,-dir,col= col+1,lwd=0.75*lwd)
    fern4(first_end_point, direction + dir*pi/4 , length*0.38, dir,col = col + 1,lwd=0.75*lwd)
  }
}


plot_window_grilles <- function(start_position=c(0,0),length=1) {
  #Chinese Window grilles 
  plot(NULL,NULL,xlim = c(start_position[1]-2.5*length,start_position[1]+2.5*length),ylim = c(start_position[2]-2.5*length, start_position[2]+2.5*length),main ="Chinese Window Paper-cutting" , xlab = "", ylab = "",axes = F)
  #Plot four trees
  tree2(start_position, direction = pi/2, length,threshold=0.01)
  tree2(start_position, direction = -pi/2, length,threshold=0.01)
  tree2(start_position, direction = 0, length,threshold=0.01)
  tree2(start_position, direction = pi, length,threshold=0.01)
}


plot_colourful_grilles <- function(start_position=c(0,0),length=1) {
  #Chinese Window grilles 
  plot(NULL,NULL,xlim = c(start_position[1]-2.5*length,start_position[1]+2.5*length),ylim = c(start_position[2]-2.5*length, start_position[2]+2.5*length),main ="Chinese Window Paper-cutting" , xlab = "", ylab = "",axes = F)
  #Plot four trees
  tree3(start_position, direction = pi/2, length,threshold=0.01)
  tree3(start_position, direction = -pi/2, length,threshold=0.01)
  tree3(start_position, direction = 0, length,threshold=0.01)
  tree3(start_position, direction = pi, length,threshold=0.01)
}

plot_realistic_fern2 <- function(start_position=c(0,0),length=1){
  # plot the fern with different width
  plot(NULL, NULL,
            xlim = c(-2.5,2.5),
            ylim = c(0,7.5),
            main = "Fern with different line width", xlab = "", ylab = "",axes = F)
  #text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  fern3(start_position=c(0,0), direction=pi/2, length=1,dir=1)
}

plot_colourful_fern2 <- function(start_position=c(0,0),length=1){
  # plot collourful
  plot(NULL, NULL,
       xlim = c(-2.5,2.5),
       ylim = c(0,7.5),
       main = "Colourful Fern", xlab = "", ylab = "",axes = F)
  #text(x=start_position[1],y=start_position[2],"Start point",cex=0.8)
  #Plot
  fern4(start_position=c(0,0), direction=pi/2, length=1,dir=1,col = 1)
}

Challenge_F <- function() {
  graphics.off()# clear any existing graphs and plot your graph within the R window
  #Initialize the plot
  par(mfrow = c(2,2))
  plot_window_grilles()
  plot_colourful_grilles()
  plot_realistic_fern2()
  plot_colourful_fern2()
  return("Generally,the line size limitation will shorten the time for plotting. Therefore, the samller the line size threshold, the more fractals will be plotted in the graph. Plotting more fractals costs more time and computer memory")
}

# Challenge question G should be written in a separate file that has no dependencies on any functions here.

