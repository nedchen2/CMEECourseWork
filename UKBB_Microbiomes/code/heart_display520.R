heart_display <- function(){
  plot(1:10,1:10,xlim=c(0,10),ylim=c(0,10),type = "n")
  
  for (i in 1:180){
    arrows(5,7,5,7.1,col="red",length=i/100,angle=180-i)
    Sys.sleep(0.1)
  }
  
  for (i in 1:180){
    arrows(7,6,7,6.1,col="red",length=i/100,angle=180-i)
    Sys.sleep(0.1)
  }
  

  k=-0.8
  for (i in 1:25){
    len=i/10
    arrows(2,8,2+len,8-0.8*len,col="red")
    Sys.sleep(0.1)
  }

  arrows(2,8,8,3.2,col="white",lwd=2)
  Sys.sleep(0.1)
  arrows(8,3.2,5,4.5,col="white",lwd=2)
  Sys.sleep(0.1)
  
  segments(4,5,4.5,5,col="white",lwd=2)
  Sys.sleep(0.1)
  segments(4.25,5,4.25,4,col="white",lwd=2)
  Sys.sleep(0.1)
  segments(4.1,4.5,4.4,4.5,col="white",lwd=2)
  Sys.sleep(0.1)
  segments(4,4,4.5,4,col="white",lwd=2)
  Sys.sleep(0.1)
}


heart_display()


# =============== firework 

suppressPackageStartupMessages(library(tidyverse))
library(gganimate)

# Firework colours
colours <- c(
  'lawngreen',
  'gold',
  'white',
  'orchid',
  'royalblue',
  'yellow',
  'orange'
)
# Produce data for a single blast
blast <- function(n, radius, x0, y0, time) {
  u <- runif(n, -1, 1)
  rho <- runif(n, 0, 2*pi)
  x <- radius * sqrt(1 - u^2) * cos(rho) + x0
  y <- radius * sqrt(1 - u^2) * sin(rho) + y0
  id <- sample(.Machine$integer.max, n + 1)
  data.frame(
    x = c(x0, rep(x0, n), x0, x),
    y = c(0, rep(y0, n), y0, y),
    id = rep(id, 2),
    time = c((time - y0) * runif(1), rep(time, n), time, time + radius + rnorm(n)),
    colour = c('white', rep(sample(colours, 1), n), 'white', rep(sample(colours, 1), n)),
    stringsAsFactors = FALSE
  )
}
# Make 20 blasts
n <- round(rnorm(20, 30, 4))
radius <- round(n + sqrt(n))
x0 <- runif(20, -30, 30)
y0 <- runif(20, 40, 80)
time <- runif(20, max = 100)
fireworks <- Map(blast, n = n, radius = radius, x0 = x0, y0 = y0, time = time)
fireworks <- dplyr::bind_rows(fireworks)

p = fireworks %>% ggplot() + 
  geom_point(aes(x, y, colour = colour, group = id), size = 0.5, shape = 20) + 
  scale_colour_identity() + 
  coord_fixed(xlim = c(-65, 65), expand = FALSE, clip = 'off') +
  theme_void() + 
  theme(plot.background = element_rect(fill = 'black', colour = NA), 
        panel.border = element_blank()) + 
  # Here comes the gganimate code
  transition_components(time, exit_length = 20) + 
  ease_aes(x = 'sine-out', y = 'sine-out') + 
  shadow_wake(0.05, size = 3, alpha = TRUE, wrap = FALSE, 
              falloff = 'sine-in', exclude_phase = 'enter') + 
  exit_recolour(colour = 'black') 

p
#sudo apt-get install -y libmagick++-dev
#install.packages("magick")

library(magick)

imgs <- list.files("./",pattern = "*.png",full.names = T)

img_list <- lapply(imgs, image_read)

img_joined <- image_join(img_list)

img_animated <- image_animate(img_joined,fps = 2,delay = 0.01)

image_write(image = img_animated,
            path = "./firework.gif")

file.remove(imgs)
file.remove("./firework.gif")

# ========================== predict 



time_list = c("2022-2-10","2022-3-19","2022-4-22","2022-5-24")


predict_menstruation <- function(timelist = time_list){
  library(lubridate)
  time_list2 = as.Date(timelist)
  interval = c()
  for (i in seq(length(time_list2)-1)){
    
    date_obj = interval(start = time_list2[i],end = time_list2[i+1])
    
    interval = c(interval,time_length(date_obj,unit = "day"))
  }
  
  time = seq(length(interval))
  
  data = as.data.frame(cbind(interval,time))
  
  model = lm(interval ~ time ,data=data)
  
  point <- data.frame(time=length(time)+1)
  
  # predict the interval next time
  next_interval = round(unlist(predict(model,point,interval = "prediction",level = 0.7)))
  
  # = predict
  
  next_date = time_list2[length(time_list2)] + next_interval[1]
  
  lower_nextdate =  time_list2[length(time_list2)] + next_interval[2]
  higher_nextdate =   time_list2[length(time_list2)] + next_interval[3]
  
  print (paste0("Honey's next menstruation:",next_date))
  
  print (paste0("70% Confidence Interval: ",  lower_nextdate, " to ", higher_nextdate))
  
}

predict_menstruation()








