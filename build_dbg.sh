#!/bin/bash
# debug flag forces localhost:5173 server
odin build . -debug

if [ $? -eq 0 ]; then
    cp opm_cli ~/tools/opm
    if [ $? -eq 0 ]; then
        echo "Built & copied to ~/tools/opm"
    else
        echo "Error occurred while copying opm_cli to ~/tools/opm"
    fi
else
    echo "Build failed"
fi
