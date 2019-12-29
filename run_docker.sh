#!/bin/bash

IMG="repo/image:tag"

CODE="-v=`pwd`:/app:rw"

BIN="-v=`pwd`/bin:/app/bin:rw"
DATA="-v=`pwd`/data:/app/data:rw"
MAPR="-v=/opt/mapr:/opt/mapr:ro"
POSIX="-v=/zeta:/zeta:rw"

CMD="/app/bin/run_pyetl.sh"
#CMD="/bin/bash"

# Alternatively, you can just set the environmental variables set in ./bin/runscripts.sh then call ./pyetl.py directly

sudo docker run -it --rm $POSIX $BIN $CODE $MAPR $IMG $CMD
