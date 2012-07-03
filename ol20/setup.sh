#!/bin/bash
# setup
# script principal para execucao do aplicativo
# .:OBS funcoes que comecao com "_" sao utilzadas apenas localmente
# funcoes que comecam com o nome do arquivo do script como "linkorganizer_showMenu"
# indicam funcoes que sao utilizadas em outros scripts

# "Italo Pessoa" <italoneypessoa@gmail.com>

#export DIALOGRC=~/Documentos/shell-script/estudo-sehllscript/tema-verde.cfg
export BACK_TITLE="Organizador de Links - 2.0"
#files
export VIDEOS_DOWNLOADED_LIST_FILE="downloaded"
export LIST_VIDEOS_FILE="videos"
export DOWNLOADED_FILE="downloaded"
export VIDEO_SCRIPT_FILE="links.sh"
export NAMES_FILE="nomes.video"
export LINKS_FILE="links.video"

trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP 255

# funcoes utilziadas em diversos scripts
# centralizada a importação
source link-organizer-2.0.sh
source message.sh
source get-data.sh
source checkVideos.sh
source youtubeRegex.sh

# exibir menu principal
linkorganizer_showMenu
