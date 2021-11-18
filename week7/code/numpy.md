# Numpy, Scipy and metplotlib
Numpy: creating and manipulating data 
Scipy: complex numerical operations.

some overlap between,but will be phased out in the future

# Numpy
## Numpy indexing
1.start from 0
2.use[]
3.can accept negative values

## Function
numpy.arange(5.) #create a 1-d array
np.array()
np.append()
np.delete()
np.concatenate((mat, mat0), axis = 0)
np.transpose()

t = np.linspace(0, 15, 1000) #sing 1000 sub-divisions of time



numpy.random.normal()#this is also well to create the normal number from the distribution.But stick to Scipy for statistical problem.

## Flattening or reshaping arrays¶
np.reshape()
np.ravel()

## Pre-allocating arrays
np.ones((4,2)) #(4,2) are the (row,col) array dimensions
m = np.identity(4) #create an identity matrix
m
m.fill(16) #fill the matrix with 16
m
np.zeros((4,2)) # or zeros

## numpy matrices¶ (May be not used in the future)
1.Subset of numpy array(same in function use)
2.convenient notation for matrix
numpy.matrix()


## Matrix operation¶
+ - *(np.dot()) /

# Scipy

## Scipy stats
`import scipy as sc` or
`from scipy import stats`


### Scipy - distribution

sc.stats.norm.rvs(size = 10) #numbers from the standard normal distribution

np.random.seed(1234) #seeding for global
sc.stats.norm.rvs(size = 10)

sc.stats.norm.rvs(size=5, random_state=1234) #seeding for local (more robust)

sc.stats.randint.rvs(0, 10, size = 7, random_state=1234) #random set of the scipy

### Scipy - integrate

`import scipy.integrate as integrate`


1. Caculate the area:
Using composite trapezoidal rule
The argument `dx` defines the spacing between points of the curve
`area = integrate.trapz(y, dx = 2)`
Using Simpson’s rule
`area = integrate.simps(y, dx = 2)`

