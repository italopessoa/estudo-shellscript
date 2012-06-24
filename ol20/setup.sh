#!/bin/bash
# setup
# script principal para execucao do aplicativo
# .:OBS funcoes que comecao com "_" sao utilzadas apenas localmente
# funcoes que comecam com o nome do arquivo do script como "linkorganizer_showMenu"
# indicam funcoes que sao utilizadas em outros scripts

# Italo Pessoa - italoneypessoa@gmail.com
export DIALOGRC=~/Documentos/shell-script/estudo-sehllscript/tema-verde.cfg
export BACK_TITLE="Organizador de Links - 2.0"
#files
export NAMES_FILE="nomes.video"
export LINKS_FILE="links.video"
export VIDEOS_DOWNLOADED_LIST_FILE="downloaded"
export LIST_VIDEOS_FILES="videos"

source link-organizer-2.0.sh
linkorganizer_showMenu
