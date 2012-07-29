#!/bin/bash
# setup
# script principal para execucao do aplicativo
# .:OBS funcoes que comecao com "_" sao utilzadas apenas localmente
# funcoes que comecam com o nome do arquivo do script como "linkorganizer_showMenu"
# indicam funcoes que sao utilizadas em outros scripts

# "Italo Pessoa" <italoneypessoa@gmail.com>

#export DIALOGRC=~/Documentos/shell-script/estudo-sehllscript/tema-verde.cfg
export BACK_TITLE="Organizador de Links - 2.0 BETA"

# arquivos utilizados pelo script
export VIDEOS_DOWNLOADED_LIST_FILE="downloaded"
export LIST_VIDEOS_FILE="videos"
export VIDEO_SCRIPT="videos.sh"
export LIST_SCRIPT="list.sh"
export NAMES_FILE="nomes.video"
export LINKS_FILE="links.video"
export NAMES_LIST="nomes.list"
export LINKS_LIST="links.list"
export AVAILABLE_VIDEO="available"
export SELECTED_VIDEOS="selected_videos"
export DOWNLOAD_STATUS_LOG="download_status.log"
export PROCESS_KILL=""

# scripts utilizados
# centralizados em variaveis para que possam ser utilizados em qualquer  diretorio
export LINK_ORGANIZER_SCRIPT="link-organizer-2.0.sh"
export CHECK_VIDEOS_SCRIPT="checkVideos.sh"
export GET_DATA_SCRIPT="get-data.sh"
export UTILS_SCRIPT="utils.sh"
export DOWNLOAD_PROCESS_SCRIPT="download_process.sh"
export GENERATE_SCRIPT_DOWNLOAD_SCRIPT="ol-1.1.0.sh"
export GET_VIDEO_FORMAT_SCRIPT="getFmt.sh"

# scripts que contem funcoes utilizadas em diversos scripts
# centralizada a importação
source "$LINK_ORGANIZER_SCRIPT"
source "$GET_DATA_SCRIPT"
source "$CHECK_VIDEOS_SCRIPT"
source "$UTILS_SCRIPT"
source "$DOWNLOAD_PROCESS_SCRIPT"
source "$GENERATE_SCRIPT_DOWNLOAD_SCRIPT"
#source "$GENERAE_SCRIPT_DOWNLOAD_SCRIPT"


#trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP


# exibir menu principal
linkorganizer_showMenu
