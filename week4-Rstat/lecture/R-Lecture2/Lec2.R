> setwd("/cloud/project/SwS02")
> d <- read.table("SparrowSize.txt", header =  T)
> str(d)
'data.frame':	1770 obs. of  8 variables:
  $ BirdID: int  1 2 2 2 2 2 2 2 2 2 ...
$ Year  : int  2002 2001 2002 2003 2004 2004 2004 2004 2004 2005 ...
$ Tarsus: num  16.9 16.8 17.2 17.5 17.8 ...
$ Bill  : num  NA NA NA 13.5 13.4 ...
$ Wing  : num  76 76 76 76 77 78 77 77 77 77 ...
$ Mass  : num  23.6 27.5 28.1 27.8 26.5 ...
$ Sex   : int  0 1 1 1 1 1 1 1 1 1 ...
$ Sex.1 : chr  "female" "male" "male" "male" ...
> names(d)
[1] "BirdID" "Year"   "Tarsus" "Bill"   "Wing"   "Mass"   "Sex"    "Sex.1" 
> head(d)
BirdID Year Tarsus Bill Wing  Mass Sex  Sex.1
1      1 2002   16.9   NA   76 23.60   0 female
2      2 2001   16.8   NA   76 27.50   1   male
3      2 2002   17.2   NA   76 28.10   1   male
4      2 2003   17.5 13.5   76 27.75   1   male
5      2 2004   17.8 13.4   77 26.50   1   male
6      2 2004   17.7 13.1   78 26.00   1   male
> length(d$Tarsus)
[1] 1770
> hist(d$Tarsus)
> mean(d$Tarsus)
[1] NA
> mean(d$Tarsus, na.rm = TRUE)
[1] 18.52335
> median(d$Tarsus, na.rm = TRUE)
[1] 18.6
> mode(d$Tarsus)
[1] "numeric"
> par(mfrow = c(2,2))
> hist(d$Tarsus, breaks = 3, col ="grey")
> hist(d$Tarsus, breaks = 10, col = "grey")
> hist(d$Tarsus, breaks = 30, col = "grey")
> hist(d$Tarsus, breaks = 100, col = "grey")
> head(table(d$Tarsus))

15 15.39999962 15.69999981 15.80000019 15.89999962          16 
1           1           1           5           1           7 
> d$Tarsus.rounded <- round(d$Tarsus,digits = 1)
> head(d$Tarsus.rounded)
[1] 16.9 16.8 17.2 17.5 17.8 17.7

> require(dplyr)
Loading required package: dplyr

Attaching package: ‘dplyr’

The following objects are masked from ‘package:stats’:
  
  filter, lag

The following objects are masked from ‘package:base’:
  
  intersect, setdiff, setequal, union

> TarsusTally <- d %>% count(Tarsus.rounded,sort=TRUE)
> TarsusTally
Tarsus.rounded   n
1            19.0 121
2            18.5 112
3            18.0  95
4            18.8  87
5              NA  85
6            18.2  83
7            18.9  73
8            18.3  70
9            18.4  68
10           18.7  68
11           19.2  67
12           19.5  59
13           18.6  56
14           19.1  52
15           19.4  52
16           17.5  48
17           19.3  46
18           17.8  44
19           18.1  44
20           17.9  35
21           17.0  34
22           17.6  32
23           17.7  32
24           19.7  32
25           17.3  27
26           19.8  27
27           20.0  26
28           17.4  20
29           19.9  19
30           19.6  18
31           17.2  16
32           16.9  14
33           17.1  13
34           20.1  12
35           20.2  12
36           16.8  10
37           16.0   7
38           16.5   6
39           16.6   6
40           20.3   6
41           15.8   5
42           16.4   5
43           16.2   4
44           16.1   3
45           16.7   3
46           20.4   3
47           20.8   3
48           20.5   2
49           21.0   2
50           15.0   1
51           15.4   1
52           15.7   1
53           15.9   1
54           16.3   1
55           21.1   1
> d2 <- subset(d,d$Tarsus!="NA")
> length(d$Tarsus)-length(d2$Tarsus)
[1] 85
> TarsusTally <- d2 %>% count(Tarsus.rounded,sort=TRUE)
> TarsusTally
Tarsus.rounded   n
1            19.0 121
2            18.5 112
3            18.0  95
4            18.8  87
5            18.2  83
6            18.9  73
7            18.3  70
8            18.4  68
9            18.7  68
10           19.2  67
11           19.5  59
12           18.6  56
13           19.1  52
14           19.4  52
15           17.5  48
16           19.3  46
17           17.8  44
18           18.1  44
19           17.9  35
20           17.0  34
21           17.6  32
22           17.7  32
23           19.7  32
24           17.3  27
25           19.8  27
26           20.0  26
27           17.4  20
28           19.9  19
29           19.6  18
30           17.2  16
31           16.9  14
32           17.1  13
33           20.1  12
34           20.2  12
35           16.8  10
36           16.0   7
37           16.5   6
38           16.6   6
39           20.3   6
40           15.8   5
41           16.4   5
42           16.2   4
43           16.1   3
44           16.7   3
45           20.4   3
46           20.8   3
47           20.5   2
48           21.0   2
49           15.0   1
50           15.4   1
51           15.7   1
52           15.9   1
53           16.3   1
54           21.1   1
> TarsusTally[2]
n
1  121
2  112
3   95
4   87
5   83
6   73
7   70
8   68
9   68
10  67
11  59
12  56
13  52
14  52
15  48
16  46
17  44
18  44
19  35
20  34
21  32
22  32
23  32
24  27
25  27
26  26
27  20
28  19
29  18
30  16
31  14
32  13
33  12
34  12
35  10
36   7
37   6
38   6
39   6
40   5
41   5
42   4
43   3
44   3
45   3
46   3
47   2
48   2
49   1
50   1
51   1
52   1
53   1
54   1
> TarsusTally[1]
Tarsus.rounded
1            19.0
2            18.5
3            18.0
4            18.8
5            18.2
6            18.9
7            18.3
8            18.4
9            18.7
10           19.2
11           19.5
12           18.6
13           19.1
14           19.4
15           17.5
16           19.3
17           17.8
18           18.1
19           17.9
20           17.0
21           17.6
22           17.7
23           19.7
24           17.3
25           19.8
26           20.0
27           17.4
28           19.9
29           19.6
30           17.2
31           16.9
32           17.1
33           20.1
34           20.2
35           16.8
36           16.0
37           16.5
38           16.6
39           20.3
40           15.8
41           16.4
42           16.2
43           16.1
44           16.7
45           20.4
46           20.8
47           20.5
48           21.0
49           15.0
50           15.4
51           15.7
52           15.9
53           16.3
54           21.1
> TarsusTally[[1]]
[1] 19.0 18.5 18.0 18.8 18.2 18.9 18.3 18.4 18.7 19.2 19.5 18.6 19.1 19.4 17.5 19.3
[17] 17.8 18.1 17.9 17.0 17.6 17.7 19.7 17.3 19.8 20.0 17.4 19.9 19.6 17.2 16.9 17.1
[33] 20.1 20.2 16.8 16.0 16.5 16.6 20.3 15.8 16.4 16.2 16.1 16.7 20.4 20.8 20.5 21.0
[49] 15.0 15.4 15.7 15.9 16.3 21.1
> TarsusTally[[1]][1]
[1] 19
> range(d$Tarsus, na.rm = TRUE)
[1] 15.0 21.1
> range(d2$Tarsus, na.rm = TRUE)
[1] 15.0 21.1
> var(d$Tarsus, na.rm =TRUE)
[1] 0.7404059
> var(d2$Tarsus, na.rm =TRUE)
[1] 0.7404059
> sum((d2$Tarsus-mean(d2$Tarsus))^2)/(length(d2$Tarsus)-1)
[1] 0.7404059
> sqrt(var(d2$Tarsus))
[1] 0.8604684
> sd(d2$)
Error: unexpected ')' in "sd(d2$)"
> sd(d2$Tarsus)
[1] 0.8604684
> zTarsus <- (d2$Tarsus - mean(d2$Tarsus))/sd(d2$Tarsus)
> var(zTarsus)
[1] 1
> sd(zTarsus)
[1] 1
> mean(zTarsus)
[1] 7.039887e-16
> hist(zTarsus)
> znormal <- rnorm(1e+06)
> hist(znormal,breaks = 100)
> summary(znormal)
Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
-5.121056 -0.676143 -0.001955 -0.001806  0.671466  5.005672 
> qnorm(c(0.025,0.975))
[1] -1.959964  1.959964
> pnorm(.Last.value)
[1] 0.025 0.975
> pnorm(.Last.value)
[1] 0.5099725 0.8352199
> pnorm(.Last.value)
[1] 0.6949646 0.7982030
> par(mfrow=c(1,2))
> hist(znormal, breaks = 100)
> abline(v= qnorm(c(0.25,0.5,0.75)), lwd =2)
> abline(v = qnorm(c(0.025, 0.975)), lwd = 2, lty = "dashed")
> plot(density(znormal))
> abline(v = qnorm(c(0.25, 0.5, 0.75)), col = "gray")
> abline(v = qnorm(c(0.025, 0.975)), lty = "dotted", col = "black")
> abline(h = 0, lwd = 3, col = "blue")
> text(2, 0.3, "1.96", col = "red", adj = 0)
> text(-2, 0.3, "-1.96", col = "red", adj = 1)