#!/bin/bash

echo "download the image" | figlet | lolcat
sleep 2
clear

asciinema play 1.* -i1
sleep 2
clear

echo "save working binaries" | figlet | lolcat
sleep 2
clear
asciinema play 2.* -i1
sleep 2
clear

echo "extract docker image" | figlet | lolcat
sleep 2
clear
asciinema play 3.* -i1
sleep 2
clear

echo "extract tar layers" | figlet | lolcat
sleep 2
clear
asciinema play 4.* -i1
sleep 2
clear

echo "reset atimes" | figlet | lolcat
sleep 2
clear
asciinema play 5.* -i1
sleep 2
clear

echo "re-run --help" | figlet | lolcat
sleep 2
clear
asciinema play 6.* -i1
sleep 2
clear

echo "delete unused files" | figlet | lolcat
sleep 2
clear
asciinema play 7.* -i1
sleep 2
clear

echo "upx everything" | figlet | lolcat
sleep 2
asciinema play 8.* -i1
sleep 2
clear

echo "rebuild docker image" | figlet | lolcat
sleep 2
clear
asciinema play 9.* -i1
sleep 2
clear

echo "upload it" | figlet | lolcat
sleep 2
clear
asciinema play a.* -i1
sleep 2
clear

echo "celebrate" | figlet | lolcat
sleep 2
clear
asciinema play b.* -i1
sleep 2
