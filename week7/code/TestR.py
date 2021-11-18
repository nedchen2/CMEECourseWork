"""
Language: python3
Author: congjia chen (congjia.chen21@imperial.ac.uk)
"""

import subprocess
subprocess.Popen("Rscript --verbose TestR.R > ../results/TestR.Rout 2> ../results/TestR_errFile.Rout", shell=True).wait()
#subprocess.Popen("Rscript --verbose NonExistScript.R > ../results/outputFile.Rout 2> ../results/errorFile.Rout", shell=True).wait()
#--verbose amazing 
