import distutils.sysconfig
import sys
import os
import traceback

plib = distutils.sysconfig.get_python_lib()
mod_path="%s/cobbler" % plib
sys.path.insert(0, mod_path)

from utils import _
import sys
import cobbler.templar as templar
from cobbler.cexceptions import CX
import utils

def register():
   # this pure python trigger acts as if it were a legacy shell-trigger, but is much faster.
   # the return of this method indicates the trigger type
   return "/var/lib/cobbler/triggers/add/system/post/*"

def run(api, args, logger):
    # This will set the default to "node" after the first master is provisioned.
    # Need better logic for setting number of masters.
    default_system = api.find_system("default")
    default_system.set_profile("kubernetes-node")

    api.sync()

    return 0




