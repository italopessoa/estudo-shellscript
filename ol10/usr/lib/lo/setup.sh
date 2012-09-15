#!/bin/bash
# setup.sh
# script principal para execucao do aplicativo
# .:OBS funcoes que comecao com "_" sao utilzadas apenas localmente
# funcoes que comecam com o nome do arquivo do script como "linkorganizer_showMenu"
# indicam funcoes que sao utilizadas em outros scripts

# "Italo Pessoa" <italoneypessoa@gmail.com>

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LinkOrganizer is a simple software to organize links.						#
#																			#
# Copyright (C) 2010  Italo Pessoa<italoneypessoa@gmail.com>				#
# This file is part of the program LinkOrganizer. 							#
#																			#
# LinkOrganizer is a free software: you can redistribute it and/or modify	#
# it under the terms of the GNU General Public License as published by		#
# the Free Software Foundation, either version 3 of the License, or 		#
# (at your option) any later version.										#
#																			#
# This program is distributed in the hope that it will be useful,			#
# but WITHOUT ANY WARRANTY; without even the implied warranty of 			#
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 		 	#
# GNU General Public License for more details. 								#
#																			#
# You should have received a copy of the GNU General Public License 		#
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 	#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# export DIALOGRC=~/Documentos/shell-script/estudo-sehllscript/tema-verde.cfg
export BACK_TITLE="Organizador de Links - 2.0 BETA"

# arquivos utilizados pelo script
export VIDEOS_DOWNLOADED_LIST_FILE=".downloaded"
export LIST_VIDEOS_FILE=".videos"
export VIDEO_SCRIPT=".videos.sh"
export LIST_SCRIPT=".list.sh"
export NAMES_FILE=".nomes.video"
export LINKS_FILE=".links.video"
export NAMES_LIST=".nomes.list"
export LINKS_LIST=".links.list"
export AVAILABLE_VIDEO=".available"
export SELECTED_VIDEOS=".selected_videos"
export ONE_VIDEO_DOWNLOAD=".one.sh"
export DOWNLOAD_STATUS_LOG=".download_status.log"
export PROCESS_KILL=""
export GETDATA_CLIPBOARD_STANDARD="standard-clipboard"
export GETDATA_CLIPBOARD_FULL="full-clipboard"
export GETDATA_STANDARD="standard"
export SETTINGS="$HOME/.config/linkOrganizer/settings/settings"
export BACKUP_DIR="$HOME/.linkOrganizer/data/backup"
export BACKUP_INF_FILE="README"
export FORMAT_FILE=".format"

# scripts utilizados
# centralizadosscripts  variaveis para que possam ser utilizados em qualquer  diretorio
export LINK_ORGANIZER_SCRIPT="link-organizer-2.0.sh"
export CHECK_VIDEOS_SCRIPT="checkVideos.sh"
export GET_DATA_SCRIPT="get-data.sh"
export UTILS_SCRIPT="utils.sh"
export DOWNLOAD_PROCESS_SCRIPT="download_process.sh"
export GENERATE_SCRIPT_DOWNLOAD_SCRIPT="ol-1.1.0.sh"
export GET_VIDEO_FORMAT_SCRIPT="get-format.sh"

# scripts que contem funcoes utilizadas em diversos scripts
# centralizada a importação
source "$LINK_ORGANIZER_SCRIPT"
source "$GET_DATA_SCRIPT"
source "$CHECK_VIDEOS_SCRIPT"
source "$UTILS_SCRIPT"
source "$DOWNLOAD_PROCESS_SCRIPT"
source "$GENERATE_SCRIPT_DOWNLOAD_SCRIPT"
source "$SETTINGS"
source "$GET_VIDEO_FORMAT_SCRIPT"
#source "$GENERAE_SCRIPT_DOWNLOAD_SCRIPT"

#trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP

# exibir menu principal
linkorganizer_showMenu
