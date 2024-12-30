#!/bin/sh

username="bitplane1"
repo="uh-halp-data-binaries"


docker image ls $repo --format "docker tag {{.ID}} $username/{{.Repository}}:{{.Tag}}" | tac |
    while IFS= read -r line; do 
        $line
    done

docker image ls $repo --format "docker push $username/{{.Repository}}:{{.Tag}}" | tac |
    while IFS= read -r line; do 
        $line
    done


