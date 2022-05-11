#!/bin/sh
#Script created by Chase Cobb

ShouldPerformIVTC () {
    while true
    do
        echo "Perform experimental IVTC on all files? y/n :"
        read shoudlDetelecine

        #Get user input
        if [[ "$shoudlDetelecine" == "y" ]] || [[ "$shoudlDetelecine" == "Y" ]]
        then
            return 1
        elif [[ "$shoudlDetelecine" == "n" ]] || [[ "$shoudlDetelecine" == "N" ]]
        then
            return 0
        fi
    done
}

# TEST
#ShouldPerformIVTC