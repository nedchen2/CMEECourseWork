"""
Language: Python3
   Author: Congjia chen (congjia.chen21@imperial.ac.uk)
"""

import numpy as np
import scipy.integrate as integrate
import matplotlib.pylab as p

def dCR_dt(pops, t=0):
    """
    Cauculate dR/dt and dC/dt, where t is time, 
       R and C :densities of resource and consumer. 
    """
    R = pops[0]
    C = pops[1]
    dRdt = r * R - a * R * C 
    dCdt = -z * C + e * a * R * C
    
    return np.array([dRdt, dCdt])

# assign some parameter values
r = 1.
a = 0.1 
z = 1.5
e = 0.75

#generate the time series
t = np.linspace(0, 15, 1000)

#Set the initial conditions for the two populations (10 resources and 5 consumers per unit area)
R0 = 10
C0 = 5 
RC0 = np.array([R0, C0])

#Integration
pops, infodict = integrate.odeint(dCR_dt, RC0, t, full_output=True)
#from integrate.odeint()  it returns two things.one of it is the infodict which contains several information about the integration
#RC0 is an array, in this function.it acts as the initial value of y,and t in this case as the x

#pops.shape 
#pops contains the pop situation calculated by integration in different time point

#infodict.keys()

#Plotting
f1 = p.figure()
p.plot(t, pops[:,0], 'g-', label='Resource density') # Plot
p.plot(t, pops[:,1]  , 'b-', label='Consumer density')
p.grid()
p.legend(loc='best')
p.xlabel('Time')
p.ylabel('Population density')
p.title('Consumer-Resource population dynamics')
#p.show()# To display the figure
f1.savefig('../results/LV_model.pdf') #Save figure

f2 = p.figure()
p.plot(pops[:,0], pops[:,1], "r-")
p.grid()
p.xlabel("Resource density")
p.ylabel("Consumer density")
p.title("Consumer-Resource population dynamics")
f2.savefig("../results/LV_model2.pdf")

