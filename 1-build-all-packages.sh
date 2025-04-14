#!/bin/bash
#https://wiki.archlinux.org/index.php/DeveloperWiki:Building_in_a_Clean_Chroot

#tput setaf 0 = black
#tput setaf 1 = red
#tput setaf 2 = green
#tput setaf 3 = yellow
#tput setaf 4 = dark blue
#tput setaf 5 = purple
#tput setaf 6 = cyan
#tput setaf 7 = gray
#tput setaf 8 = light blue
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# Website 	: 	http://www.erikdubois.be
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

count=0
total_repos=$(ls -d */ | wc -l)

echo
tput setaf 12
echo "################################################################"
echo "We are going to build $total_repos packages"
echo "################################################################"
tput sgr0
echo

for name in $(ls -d */ | cut -f1 -d'/'); do
    count=$((count + 1))
    cd "$name" || { echo "Failed to enter directory $name"; continue; }
    tput setaf 3
    echo "Github nr : " $count " - git pull of " $name - of total $total_repos
    tput sgr0
    echo "#############################################################################################"
    
    git pull

    if [ $? -eq 0 ]; then
        sleep 2
        # Check if build script exists before running
        if compgen -G "./build*" > /dev/null; then
            sh ./build*
        else
            echo "No build script found for $name"
            echo "Error: The project $name has no build script" | tee -a /tmp/failed
        fi
    else
        sleep 2
        tput setaf 1
        echo "Git pull failed for $name"
        echo "Error: Git pull failed for $name" | tee -a /tmp/failed
        tput sgr0
    fi
    
    cd ..
done

