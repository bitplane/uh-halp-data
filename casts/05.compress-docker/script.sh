#!/bin/bash

echo "download the image" | figlet
sleep 2
clear

asciinema play 1.* -i1
sleep 2
clear

echo "save working binaries" | figlet
sleep 2
clear
asciinema play 2.* -i1
sleep 2
clear

echo "extract docker image" | figlet
sleep 2
clear
asciinema play 3.* -i1
sleep 2
clear

echo "extract tar layers" | figlet
sleep 2
clear
asciinema play 4.* -i1
sleep 2
clear

echo "reset atimes" | figlet
sleep 2
clear
asciinema play 5.* -i1
sleep 2
clear

echo "re-run --help" | figlet
sleep 2
clear
asciinema play 6.* -i1
sleep 2
clear

echo "delete unused files" | figlet
sleep 2
clear
asciinema play 7.* -i1
sleep 2
clear

echo "upx everything" | figlet
sleep 2
asciinema play 8.* -i1
sleep 2
clear

echo "rebuild docker image" | figlet
sleep 2
clear
asciinema play 9.* -i1
sleep 2
clear


