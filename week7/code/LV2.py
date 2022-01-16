"""
Language: python3
Author: congjia chen (congjia.chen21@imperial.ac.uk)
Dep: sys,numpy,scipy,matplotlib
Description: Command line interface of LV1
"""
import sys
import numpy as np
import scipy.integrate as integrate
import matplotlib.pylab as p

# assign some parameter values
print (len(sys.argv))
if len(sys.argv) == 6:
    print ("We are running ",sys.argv[0])
    try:
        r = float(sys.argv[1])
        a = float(sys.argv[2])
        z = float(sys.argv[3])
        e = float(sys.argv[4])
        K = float(sys.argv[5])
    except IndexError:
        print ("Your args provided are not sufficient, We will use default value here")
    except ValueError:
        print ("Please provide number for every args")
else:
    print ("Your args provided are not sufficient, We will use default value here")
    r = 1
    a = 0.1
    z = 1.5
    e = 0.75
    K = 1000000

print("r = %f, a = %f, z= %f, e = %f, K = %f" % (r,a,z,e,K))

def dCR_dt(pops, t = 0):
    """LV model"""
    R = pops[0]
    C = pops[1]
    dRdt = r * R * (1 - R/K) - a * R * C 
    dCdt = -z * C + e * a * R * C
    
    return np.array([dRdt, dCdt])


#generate the time series
t = np.linspace(0, 15, 1000)

#Set the initial conditions for the two populations (10 resources and 5 consumers per unit area)
R0 = 10
C0 = 5 
RC0 = np.array([R0, C0])

#Integration
pops, infodict = integrate.odeint(dCR_dt, RC0, t, full_output=True)

#print(pops[-1,:])

#Plotting
f1 = p.figure(figsize=(8,6))
p.plot(t, pops[:,0], 'g-', label='Resource density') # Plot
p.plot(t, pops[:,1]  , 'b-', label='Consumer density')
p.grid()
p.legend(loc='upper left')
p.text(0,35,"r = " + str(r))
p.text(0,33.5,"a = " + str(a))
p.text(0,32,"z = " + str(z))
p.text(0,30.5,"e = " + str(e))
p.text(0,29,"K = " + str(int(K)))
p.xlabel('Time')
p.ylabel('Population density')
p.title('Consumer-Resource population dynamics')
#p.show()# To display the figure
f1.savefig('../results/LV2_model.pdf') #Save figure

f2 = p.figure()
p.plot(pops[:,0], pops[:,1], "r-")
p.grid()
p.text(35,23,"r = " + str(r))
p.text(35,22,"a = " + str(a))
p.text(35,21,"z = " + str(z))
p.text(35,20,"e = " + str(e))
p.text(35,19,"K = " + str(int(K)))
p.xlabel("Resource density")
p.ylabel("Consumer density")
p.title("Consumer-Resource population dynamics")
f2.savefig("../results/LV2_model2.pdf")


