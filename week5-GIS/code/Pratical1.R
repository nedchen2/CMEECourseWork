install.packages('raster') # Core raster GIS data package
install.packages('sf') # Core vector GIS data package
install.packages('sp') # Another core vector GIS package
install.packages('rgeos') # Extends vector data functionality
install.packages('rgdal') # Interface to the Geospatial Data Abstraction Library
install.packages('lwgeom') # Extends vector data functionality

library(rgdal)
library(raster)
library(sf)
library(sp)
library(units)

library(rgdal)
library(raster)
library(sf)
library(sp)
library(units)

pop_dens <- data.frame(n_km2 = c(260, 67,151, 4500, 133), 
                       country = c('England','Scotland', 'Wales', 'London', 'Northern Ireland'))
print(pop_dens)

# Create coordinates  for each country 
# - this creates a matrix of pairs of coordinates forming the edge of the polygon. 
# - note that they have to _close_: the first and last coordinate must be the same.
scotland <- rbind(c(-5, 58.6), c(-3, 58.6), c(-4, 57.6), 
                  c(-1.5, 57.6), c(-2, 55.8), c(-3, 55), 
                  c(-5, 55), c(-6, 56), c(-5, 58.6))
england <- rbind(c(-2,55.8),c(0.5, 52.8), c(1.6, 52.8), 
                 c(0.7, 50.7), c(-5.7,50), c(-2.7, 51.5), 
                 c(-3, 53.4),c(-3, 55), c(-2,55.8))
wales <- rbind(c(-2.5, 51.3), c(-5.3,51.8), c(-4.5, 53.4),
               c(-2.8, 53.4),  c(-2.5, 51.3))
ireland <- rbind(c(-10,51.5), c(-10, 54.2), c(-7.5, 55.3),
                 c(-5.9, 55.3), c(-5.9, 52.2), c(-10,51.5))

# Convert these coordinates into feature geometries
# - these are simple coordinate sets with no projection information ### The simple coordinate sets with no projection information
scotland <- st_polygon(list(scotland))
england <- st_polygon(list(england))
wales <- st_polygon(list(wales))
ireland <- st_polygon(list(ireland))

# Combine geometries into a simple feature column
uk_eire <- st_sfc(wales, england, scotland, ireland, crs=4326) #combine the feature into one, crs has special meaning
plot(uk_eire, asp=1) #an aspect ratio of one (asp=1). plot the 


#We can easily turn a data frame with coordinates in columns into a point vector data source. 
uk_eire_capitals <- data.frame(long= c(-0.1, -3.2, -3.2, -6.0, -6.25),
                               lat=c(51.5, 51.5, 55.8, 54.6, 53.30),
                               name=c('London', 'Cardiff', 'Edinburgh', 'Belfast', 'Dublin'))
uk_eire_capitals <- st_as_sf(uk_eire_capitals, coords=c('long','lat'), crs=4326) #into a point vector data source

print(uk_eire_capitals)

st_pauls <- st_point(x=c(-0.098056, 51.513611))#设置圣保罗大教堂的地址
london <- st_buffer(st_pauls, 0.25)#buffer operation 可以帮忙，0.25代表a quarter

#we can set different population densities for the two regions. This uses the difference operation.
#Note that the order of the arguments to this function matter: we want the bits of England that are different from London.
england_no_london <- st_difference(england, london) #英格兰去掉伦敦

#Note that the resulting feature now has a different structure. The lengths function allows us to see the number of components in a polygon and how many points are in each component. If we look at the polygon for Scotland:
lengths(scotland)
lengths(england_no_london)

#
wales <- st_difference(wales, england)#wales 去掉england的部分
length(wales)
###
# A rough polygon that includes Northern Ireland and surrounding sea.
# - not the alternative way of providing the coordinates
ni_area <- st_polygon(list(cbind(x=c(-8.1, -6, -5, -6, -8.1), y=c(54.4, 56, 55, 54, 54.4)))) #这个区域包括了一部分海洋
northern_ireland <- st_intersection(ireland, ni_area) #intersection可以用来取交集。取地区之间的交集
eire <- st_difference(ireland, ni_area)#继续用difference 来去除掉一部分不需要的地区

# Combine the final geometries
uk_eire <- st_sfc(wales, england_no_london, scotland, london, northern_ireland, eire, crs=4326)
print (uk_eire)

# make the UK into a single feature
# 简单来说就是合并图形
uk_country <- st_union(uk_eire[-6]) #union operation: We can create a single feature that contains all of those geometries in one MULTIPOLYGON geometry by using the union operation
print(uk_country)

par(mfrow=c(1, 2), mar=c(3,3,1,1))
plot(uk_eire, asp=1, col=rainbow(6))
plot(st_geometry(uk_eire_capitals), add=TRUE) #加上首都的点
plot(uk_country, asp=1, col='lightblue')#画出整个英国

#sf是一个类似于dataframe 的对象
uk_eire <- st_sf(name=c('Wales', 'England','Scotland', 'London', 
                        'Northern Ireland', 'Eire'),
                 geometry=uk_eire)

plot(uk_eire, asp=1)


#在原来的对象里可以进行一些更换类似dataframe 的操作
uk_eire$capital <- c('Cardiff', 'London', 'Edinburgh', 
                     NA, 'Belfast','Dublin')
print(uk_eire)

#这边使用merge可能会更好
uk_eire <- merge(uk_eire, pop_dens, by.x='name', by.y='country', all.x=TRUE)
print(uk_eire)

#centroid operation to cal the centroid
uk_eire_centroids <- st_centroid(uk_eire)
st_coordinates(uk_eire_centroids)
#这并不是一个计算的好方法

#st_area 可以用来计算球面的面积
uk_eire$area <- st_area(uk_eire)
# To calculate a 'length' of a polygon, you have to 
# 用st_cast convert it to a LINESTRING or a MULTILINESTRING
# 具体这些有什么区别，我不清楚
# Using MULTILINESTRING will automatically 
# include all perimeter of a polygon (including holes).
uk_eire$length <- st_length(st_cast(uk_eire, 'MULTILINESTRING'))
# Look at the result
print(uk_eire)

# You can change units in a neat way 很直观
uk_eire$area <- set_units(uk_eire$area, 'km^2')
uk_eire$length <- set_units(uk_eire$length, 'km')
print(uk_eire)

# And it won't let you make silly error like turning a length into weight
uk_eire$area <- set_units(uk_eire$area, 'kg')

# Or you can simply convert the `units` version to simple numbers
uk_eire$length <- as.numeric(uk_eire$length)

#A final useful example is the distance between objects: sf gives us the closest distance between geometries, which might be zero if two features overlap or touch, 
#as in the neighbouring polygons in our data.
st_distance(uk_eire)


st_distance(uk_eire_centroids)

#If you plot an sf object, the default is to plot a map for every attribute.
#默认是给所有attribute绘制
plot(uk_eire['n_km2'], asp=1)

#这里颜色不太对劲，用？
?plot.sf


#reprojection代表同一数据转换成不太坐标系的映射过程

# British National Grid (EPSG:27700)
uk_eire_BNG <- st_transform(uk_eire, 27700)
# UTM50N (EPSG:32650)
uk_eire_UTM50N <- st_transform(uk_eire, 32650)
# The bounding boxes of the data shows the change in units
st_bbox(uk_eire)

par(mfrow=c(1, 3), mar=c(3,3,1,1))
plot(st_geometry(uk_eire), asp=1, axes=TRUE, main='WGS 84')
plot(st_geometry(uk_eire_BNG), axes=TRUE, main='OSGB 1936 / BNG')
plot(st_geometry(uk_eire_UTM50N), axes=TRUE, main='UTM 50N')

# Set up some points separated by 1 degree latitude and longitude from St. Pauls
st_pauls <- st_sfc(st_pauls, crs=4326)
one_deg_west_pt <- st_sfc(st_pauls - c(1, 0), crs=4326) # near Goring
one_deg_north_pt <-  st_sfc(st_pauls + c(0, 1), crs=4326) # near Peterborough
# Calculate the distance between St Pauls and each point
st_distance(st_pauls, one_deg_west_pt)
st_distance(st_pauls, one_deg_north_pt)
st_distance(st_transform(st_pauls, 27700), 
            st_transform(one_deg_west_pt, 27700))



# transform St Pauls to BNG and buffer using 25 km
london_bng <- st_buffer(st_transform(st_pauls, 27700), 25000)
#st_buffer 的作用就是绕点画圈

# In one line, transform england to BNG and cut out London
england_not_london_bng <- st_difference(st_transform(st_sfc(england, crs=4326), 27700), london_bng)
# project the other features and combine everything together
others_bng <- st_transform(st_sfc(eire, northern_ireland, scotland, wales, crs=4326), 27700)
corrected <- c(others_bng, london_bng, england_not_london_bng)
# Plot that and marvel at the nice circular feature around London
par(mar=c(3,3,1,1))
plot(corrected, main='25km radius London', axes=TRUE)
