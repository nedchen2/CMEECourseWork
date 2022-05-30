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

