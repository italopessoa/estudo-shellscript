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
# Copyright (C) 2012  Italo Pessoa<italoneypessoa@gmail.com>				#
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
export BACK_TITLE="Organizador de Links"
VERSION="1.0.3"
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
export LINK_ORGANIZER_SCRIPT="/usr/lib/lo/link-organizer-2.0.sh"
export CHECK_VIDEOS_SCRIPT="/usr/lib/lo/checkVideos.sh"
export GET_DATA_SCRIPT="/usr/lib/lo/get-data.sh"
export UTILS_SCRIPT="/usr/lib/lo/utils.sh"
export DOWNLOAD_PROCESS_SCRIPT="/usr/lib/lo/download_process.sh"
export GENERATE_SCRIPT_DOWNLOAD_SCRIPT="/usr/lib/lo/ol-1.1.0.sh"
export GET_VIDEO_FORMAT_SCRIPT="/usr/lib/lo/get-format.sh"
export FISRT_ACESS_FILE="/usr/lib/lo/1A"
export COPYING="/usr/lib/lo/COPYING"

# scripts que contem funcoes utilizadas em diversos scripts
# centralizada a importação
source "$LINK_ORGANIZER_SCRIPT"
source "$GET_DATA_SCRIPT"
source "$CHECK_VIDEOS_SCRIPT"
source "$UTILS_SCRIPT"
source "$DOWNLOAD_PROCESS_SCRIPT"
source "$GENERATE_SCRIPT_DOWNLOAD_SCRIPT"
test -e "$SETTINGS" && source "$SETTINGS"
source "$GET_VIDEO_FORMAT_SCRIPT"
#source "$GENERAE_SCRIPT_DOWNLOAD_SCRIPT"

#trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP

if [ "$1" ]; then
	case "$1" in
		"-v" | "--version" )
			if [ "$2" ]; then
				case "$2" in
					"--verbose" )
						echo "Link Organizer $VERSION"
						echo "bash 4.1"
						echo "youtube-dl 2011.08.04"
						echo "python 2.6.5"
						echo "sed 4.2.1"
						echo "grep 2.5.4"
						echo "coreutils 7.4"
						echo ""
						;;
				esac
			else
				echo $VERSION
			fi
		;;
		"-l" | "--license")
			echo "
Copyright (C) 2012  Italo Pessoa

LinkOrganizer is a free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,	
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
		;;
		"--verbose")
			echo "Esta opção não é utilzada sozinha."
		;;
		*)
			echo "Opção desconhecida."
		;;
	esac
else
	#verificar se é o primeiro acesso
	if [ ! -e "$HOME/.config/linkOrganizer" ]; then
		dialog --title 'LinkOrganizer' --textbox "$FISRT_ACESS_FILE" 8 68 \
			--and-widget \
			--yesno 'Deseja continuar?' 5 23 
		
		# exibir a licença
	  	if [ $? -eq 0 ]; then
			dialog --title 'LICENÇA do Software' --textbox "$COPYING" 26 76 \
				--and-widget \
				--yesno 'Você aceita os Termos da Licença?' 5 38 

				if [ $? -eq 0 ]; then
					mkdir -p "$HOME/.config/linkOrganizer/settings"
					echo "export GET_DATA_METHOD=\"$GETDATA_STANDARD\"" > "$HOME/.config/linkOrganizer/settings/settings"
					echo "export MAKE_BACKUP=\"0\"" >> "$HOME/.config/linkOrganizer/settings/settings"
					linkorganizer_showMenu
				else
					exit 0;
				fi
		else
			exit 0;
		fi
	else
		# exibir menu principal
		linkorganizer_showMenu
	fi
fi