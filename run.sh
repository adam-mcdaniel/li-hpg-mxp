#!/bin/bash

HPG_ROOT=$(pwd)

source ../setup-run-env.sh
if [ -f ../profiler-injector.sh ]; then
    source ../profiler-injector.sh
fi

srun -A csc688 -t10 -N1 -c7 --ntasks-per-node=8 --gpu-bind=closest $HPG_ROOT/install/bin/xhpgmp 128 128 128 --run_type=standalone_ref
