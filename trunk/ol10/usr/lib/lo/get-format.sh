#!/bin/bash
# get-format.sh
# exibir opções de formato de video
# "Italo Pessoa" <italoneypessoa@gmail.com>

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LinkOrganizer is a simple software to organize links.                     #
#                                                                           #
# Copyright (C) 2010  Italo Pessoa<italoneypessoa@gmail.com>                #
# This file is part of the program LinkOrganizer.                           #
#                                                                           #
# LinkOrganizer is a free software: you can redistribute it and/or modify   #
# it under the terms of the GNU General Public License as published by      #
# the Free Software Foundation, either version 3 of the License, or         #
# (at your option) any later version.                                       #
#                                                                           #
# This program is distributed in the hope that it will be useful,           #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU General Public License for more details.                              #
#                                                                           #
# You should have received a copy of the GNU General Public License         #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.     #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#exibir opcoes de recolucao do video
videoFormat_Main(){
	echo "asd" >> teste
	youTubeFile=$(tempfile)
	wget -O "$youTubeFile" -o $(tempfile) "$1"

	dialog \
	        --title "Aguarde" \
	        --backtitle "$BACK_TITLE" \
	        --sleep "5" \
	        --infobox "Coletando informações do vídeo"  \
	        3 40

	fmtList=("1080" "720" "480" "360" "240")
	STRING="<meta property=\"og:video:height"
	fmt=$(grep "$STRING" "$youTubeFile" | sed 's/.*="// ;s/">//')
	for key in ${!fmtList[*]}; do
		if [ "$fmt" -lt "${fmtList[$key]}" ]; then
			unset fmtList[$key]
		fi
	done

	tmpFmtList=$(tempfile)
	test -e "$tmpFmtList" && rm "$tmpFmtList"

	for key in ${!fmtList[*]}; do
		echo "${fmtList[$key]} ${fmtList[$key]}p off" >> "$tmpFmtList"
	done



	fmtValue=$(dialog  --stdout \
		--title 'Selecione' \
		--backtitle "$BACK_TITLE" \
		--radiolist 'Quais vídeos deseja baixar?'  \
		0 0 0  \
		$(cat "$tmpFmtList")) 

	case "$fmtValue" in
		"1080")
			#echo "escolheu 1080 = 37(.mp4)"
			echo "37:.mp4" >"$FORMAT_FILE"
		;;
		"720")
			#echo "escolheu 720 = 22(.mp4)"
			echo "22:.mp4" >"$FORMAT_FILE"
		;;
		"480")
			#echo "escolheu 480 = 18(.mp4)"
			echo "18:.mp4" >"$FORMAT_FILE"
		;;
		"360")
			#echo "escolheu 360 = 34(.flv)"
			echo "34:.flv" >"$FORMAT_FILE"
		;;
		"240")
			#echo "escolheu 240 = 5(.flv)"
			echo "5:.flv" >"$FORMAT_FILE" 
		;;
	esac
}