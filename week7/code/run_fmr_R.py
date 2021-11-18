

import subprocess
p = subprocess.Popen("Rscript fmr.R", shell=True).wait()

if p == 0:
    print ("Congratulation! Succeed!")
else:
    print ("Error! Please check the script")