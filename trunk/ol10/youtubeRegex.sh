#!/bin/bash
# youtubeRegex.sh
# script simples para remover dados desnecessários da
# url dos vídeos do youtube
# "Italo Pessoa" <italoneypessoa@gmail.com>
youtubeRegex(){
	echo "$@" | sed 's/?.*[^v]v=/?v=/g; s/&.*//g'
}
