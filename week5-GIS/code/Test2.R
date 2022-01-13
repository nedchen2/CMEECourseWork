#Rasters are the other major type of spatial data. 
#They consist of a regular grid in space, defined by a coordinate system, an origin point, a resolution and a number of rows and columns. 
#They effectively hold a matrix of data. We will use the raster package to handle raster data.

# Create an empty raster object covering UK and Eire
# 设置一个raster对象，设置一些参数
uk_raster_WGS84 <- raster(xmn=-11,  xmx=2,  ymn=49.5, ymx=59, 
                          res=0.5, crs="+init=EPSG:4326")
hasValues(uk_raster_WGS84)

# Add data to the raster: just the number 1 to number of cells
values(uk_raster_WGS84) <- seq(length(uk_raster_WGS84))
print(uk_raster_WGS84)

plot(uk_raster_WGS84)
plot(st_geometry(uk_eire), add=TRUE, border='black', lwd=2, col='#FFFFFF44')

# define a mateix
m <- matrix(c(1, 1, 3, 3,
              1, 2, 4, 3,
              5, 5, 7, 8,
              6, 6, 7, 7), ncol=4, byrow=TRUE)
square <- raster(m)

# Average values
square_agg_mean <- aggregate(square, fact=2, fun=mean)
as.matrix(square_agg_mean)

# Maximum values
square_agg_max <- aggregate(square, fact=2, fun=max)
as.matrix(square_agg_max)

# Modal values for categories
square_agg_modal <- aggregate(square, fact=2, fun=modal)
as.matrix(square_agg_modal)

# Copy parents
square_disagg <- disaggregate(square, fact=2)
as.matrix(square_disagg)
# Interpolate
square_disagg_interp <- disaggregate(square, fact=2, method='bilinear')
as.matrix(square_disagg_interp)

# make two simple `sfc` objects containing points in  the
# lower left and top right of the two grids
uk_pts_WGS84 <- st_sfc(st_point(c(-11, 49.5)), st_point(c(2, 59)), crs=4326)
uk_pts_BNG <- st_sfc(st_point(c(-2e5, 0)), st_point(c(7e5, 1e6)), crs=27700)

#  Use st_make_grid to quickly create a polygon grid with the right cellsize
# 创建不同类型的格子
uk_grid_WGS84 <- st_make_grid(uk_pts_WGS84, cellsize=0.5)
uk_grid_BNG <- st_make_grid(uk_pts_BNG, cellsize=1e5)

# Reproject BNG grid into WGS84
# 用transform 转换不同格式的grid
uk_grid_BNG_as_WGS84 <- st_transform(uk_grid_BNG, 4326)

# Plot the features
plot(uk_grid_WGS84, asp=1, border='grey', xlim=c(-13,4))
plot(st_geometry(uk_eire), add=TRUE, border='darkgreen', lwd=2)
plot(uk_grid_BNG_as_WGS84, border='red', add=TRUE)

# Create the target raster 先创建一个靶子
uk_raster_BNG <- raster(xmn=-200000, xmx=700000, ymn=0, ymx=1000000,
                        res=100000, crs='+init=EPSG:27700')
# 然后用projectRaster来重投影
# Interpolated： method="bilinear"
uk_raster_BNG_interp <- projectRaster(uk_raster_WGS84, uk_raster_BNG, method='bilinear')

# Nearest Neighbour： method="ngb"
uk_raster_BNG_ngb <- projectRaster(uk_raster_WGS84, uk_raster_BNG, method='ngb')

# compare the values in the top row
round(values(uk_raster_BNG_interp)[1:9], 2)
values(uk_raster_BNG_ngb)[1:9]

# We will use the projectRaster function, which gives us the choice of interpolating a representative value from the source data (method='bilinear') or picking the cell value from the nearest neighbour to the new cell centre (method='ngb'). We first create the target raster - we don’t have to put any data into it - and use that as a template for the reprojected data.
par(mfrow=c(1,2), mar=c(1,1,2,1))
plot(uk_raster_BNG_interp, main='Interpolated', axes=FALSE, legend=FALSE)
plot(uk_raster_BNG_ngb, main='Nearest Neighbour',axes=FALSE, legend=FALSE)

# Create the target raster 
uk_20km <- raster(xmn=-200000, xmx=650000, ymn=0, ymx=1000000, 
                  res=20000, crs='+init=EPSG:27700')

# Rasterizing polygons
# rasterize 只接受 older Spatial data type from the sp package. 
# 因此可以用as(uk_eire_BNG, 'Spatial')来转换
uk_eire_poly_20km  <- rasterize(as(uk_eire_BNG, 'Spatial'), uk_20km, field='name')

# Rasterizing lines
uk_eire_BNG_line <- st_cast(uk_eire_BNG, 'LINESTRING')





uk_eire_BNG$name <- as.factor(uk_eire_BNG$name)

# st_agr可以设置参数类型
st_agr(uk_eire_BNG) <- 'constant'

# Rasterizing lines.
uk_eire_BNG_line <- st_cast(uk_eire_BNG, 'LINESTRING')
uk_eire_line_20km <- rasterize(as(uk_eire_BNG_line, 'Spatial'), uk_20km, field='name')

# Rasterizing points 
# - This isn't quite as neat. You need to take two steps in the cast and need to convert 
#   the name factor to numeric.
uk_eire_BNG_point <- st_cast(st_cast(uk_eire_BNG, 'MULTIPOINT'), 'POINT')
uk_eire_BNG_point$name <- as.numeric(uk_eire_BNG_point$name)
uk_eire_point_20km <- rasterize(as(uk_eire_BNG_point, 'Spatial'), uk_20km, field='name')

# Plotting those different outcomes
# - Use the hcl.colors function to create a nice plotting palette
color_palette <- hcl.colors(6, palette='viridis', alpha=0.5)

# - Plot each raster
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(uk_eire_poly_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')

plot(uk_eire_line_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')

plot(uk_eire_point_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')




# ========Raster to vector
# rasterToPolygons returns a polygon for each cell and returns a Spatial object
poly_from_rast <- rasterToPolygons(uk_eire_poly_20km)
poly_from_rast <- as(poly_from_rast, 'sf')


# but can be set to dissolve the boundaries between cells with identical values
poly_from_rast_dissolve <- rasterToPolygons(uk_eire_poly_20km, dissolve=TRUE)
poly_from_rast_dissolve <- as(poly_from_rast_dissolve, 'sf')

# rasterToPoints returns a matrix of coordinates and values.
points_from_rast <- rasterToPoints(uk_eire_poly_20km)
points_from_rast <- st_as_sf(data.frame(points_from_rast), coords=c('x','y'))

# Plot the outputs - using key.pos=NULL to suppress the key and
# reset=FALSE to avoid plot.sf altering the par() options
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(poly_from_rast['layer'], key.pos = NULL, reset = FALSE)
plot(poly_from_rast_dissolve, key.pos = NULL, reset = FALSE)
plot(points_from_rast, key.pos = NULL, reset = FALSE)

#==================Using data in files
# st_write
# Saving vector data
#  a shapefile is not a single file.


st_write(uk_eire, 'data/uk_eire_WGS84.shp')
st_write(uk_eire_BNG, 'data/uk_eire_BNG.shp')

# a shapefile is not a single file

# Other file formats are increasingly commonly used in place of the shapefile. 
# GeoJSON
# GeoPackage
st_write(uk_eire, 'data/uk_eire_WGS84.geojson')
st_write(uk_eire, 'data/uk_eire_WGS84.gpkg')

# Saving raster data
# Save a GeoTiff
writeRaster(uk_raster_BNG_interp, 'data/uk_raster_BNG_interp.tif')
# Save an ASCII format file: human readable text. 
# Note that this format does not contain the projection details!
writeRaster(uk_raster_BNG_ngb, 'data/uk_raster_BNG_ngb.asc', format='ascii')

# Loading Vector data

# Load a vector shapefile
ne_110 <- st_read('data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp')
# Also load some WHO data on 2016 life expectancy
# see: http://apps.who.int/gho/athena/api/GHO/WHOSIS_000001?filter=YEAR:2016;SEX:BTSX&format=csv
life_exp <- read.csv(file = "data/WHOSIS_000001.csv")

# Loading XY data

# Read in Southern Ocean example data
so_data <- read.csv('data/Southern_Ocean.csv', header=TRUE)
head(so_data)
# Convert the data frame to an sf object
so_data <- st_as_sf(so_data, coords=c('long', 'lat'), crs=4326)
head(so_data)

# Loading Raster data

etopo_25 <- raster('data/etopo_25.tif')
# Look at the data content
print(etopo_25)
plot(etopo_25)

# Raster Stacks



# Cropping data

so_extent <- extent(-60, -20, -65, -45)
# The crop function for raster data...
so_topo <- crop(etopo_25, so_extent)
# ... and the st_crop function to reduce some higher resolution coastline data
ne_10 <- st_read('data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.shp')
st_agr(ne_10) <- 'constant'
so_ne_10 <- st_crop(ne_10, so_extent)


# contours can help make the data a bit clearer or replace a legend and are easy to add using the contour function with a raster object
sea_pal <- colorRampPalette(c('grey30', 'grey50', 'grey70'))
plot(so_topo, col=sea_pal(100), asp=1, legend=FALSE)
contour(so_topo, levels=c(-2000, -4000, -6000), add=TRUE, col='grey80')
plot(st_geometry(so_ne_10), add=TRUE, col='grey90', border='grey40')


plot(so_data['chlorophyll'], add=TRUE, logz=TRUE, pch=20, cex=2, pal=hcl.colors, border='white', reset=FALSE)
.image_scale(log10(so_data$chlorophyll), col=hcl.colors(18), key.length=0.8, key.pos=4, logz=TRUE)

# Spatial joining
set.seed(1)
# extract Africa from the ne_110 data and keep the columns we want to use
africa <- subset(ne_110, CONTINENT=='Africa', select=c('ADMIN', 'POP_EST'))

# transform to the Robinson projection
africa <- st_transform(africa, crs=54030)
# create a random sample of points
mosquito_points <- st_sample(africa, 1000)

# Create the plot
plot(st_geometry(africa), col='khaki')
plot(mosquito_points, col='firebrick', add=TRUE)

# 
mosquito_points <- st_sf(mosquito_points)
mosquito_points <- st_join(mosquito_points, africa['ADMIN'])

plot(st_geometry(africa), col='khaki')
plot(mosquito_points['ADMIN'], add=TRUE)

mosquito_points_agg <- aggregate(mosquito_points, by=list(country=mosquito_points$ADMIN), FUN=length)
names(mosquito_points_agg)[2] <-'n_outbreaks'
head(mosquito_points_agg)

africa <- st_join(africa, mosquito_points_agg)
africa$area <- as.numeric(st_area(africa))
head(africa)

par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1, 0))
plot(n_outbreaks ~ POP_EST, data=africa, log='xy', 
     ylab='Number of outbreaks', xlab='Population size')
plot(n_outbreaks ~ area, data=africa, log='xy',
     ylab='Number of outbreaks', xlab='Area (m2)')


#Extracting data from Rasters
uk_eire_etopo <- raster('data/etopo_uk.tif')
