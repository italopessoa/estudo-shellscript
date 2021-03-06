#!/bin/bash
# download_process.sh
# script para monitorar o download dos videos
# utilizando o gauge(dialog)
# "Italo Pessoa" <italoneypessoa@gmail.com>
# 3 de julho de 2012
# Versao 1 apenas a porcentagem do download
#	Para a versão 2 pretendo exibir o nome do video sendo baixado

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Link Organizer is a simple software to organize links.                    #
#                                                                           #
# Copyright (C) 2012  Italo Pessoa<italoneypessoa@gmail.com>                #
# This file is part of the program Link Organizer.                          #
#                                                                           #
# Link Organizer is a free software: you can redistribute it and/or modify  #
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


#trap '_downloadCancel' SIGINT
source "/usr/lib/lo/utils.sh"

# cancelar download
_downloadCancel(){
	dialog --stdout \
        --title "Cancelar download atual" \
        --backtitle "$BACK_TITLE" \
        --yesno "Deseja realmente cancelar?"  \
        5 30
	if [ "$?" == "0" ]; then
		kill -9 $DOWNLOAD 2> /dev/null
		#exit 10
	else
		_downloadMonitor $DOWNLOAD
	fi
}

# funcao para remover espacos que atrapalham a regex
# para recuperar o percentual de download
_removeSpaces(){
	# remover conjuntos de espaços, trocando por TABs do maior para o menor
	# pois se remover do menor para o menor os maiores contem os menores
	# e isso pode dar problema
	text=$(echo $1 | unexpand -t4 | unexpand -t3 | unexpand -t2 | expand -t1)
	# depois transformo todos em em apenas um espaço
	text=$(echo $text | expand -t1 )
	echo $text
}

_videoIsAlreadyDownloaded(){
	ls | grep -x "$1" > /dev/null
}

#exibir progresso do download
_showProgressGauge(){
trap '_downloadCancel' SIGINT
	# loop para checar o andamento do download
	(
		# enquanto o download estiver sendo executado a verificação será feita
		while utils_running $DOWNLOAD 2> /dev/null; do

			# exibir a ultima linha do arquivo de log do download
			# pegar o campo que possui a porcentagem do download
			# recuperar a quantidade de caracteres que foram encontrado com a regex
			# os caracteres representam cada entrada do youtube-dl no arquivo
			QTD_DOWNLOAD_ENTRIES=$(tail -1 "$DOWNLOAD_STATUS_LOG" | grep -o "\[download\]" | wc -w)

			# o primeiro campo da regex será vazio,  por isso é preciso incrementar mais um no total
			(( QTD_DOWNLOAD_ENTRIES++ ))

			# recuperar apenas a ultima linha e o ultimo trecho de código
			# recuperar a porcentagem e remover o caractere %
			TEXT=$(tail -1 "$DOWNLOAD_STATUS_LOG" | cut -d'[' -f$QTD_DOWNLOAD_ENTRIES)
			# remover espaços e recuperar a porcentagem sem casas decimais
			PORCENTAGEM=$(_removeSpaces "$TEXT" | cut -d' ' -f2 | sed 's/\.[0-9]\{0,\}%//')

			# enviar valor de porcentagem para o dialog
			echo $PORCENTAGEM

			# aguardar a proxima verificação
			sleep 1
		done

		# aqui o download ja foi concluido, exibir a porcentagem final
		echo 100
		echo "$ACTUAL_VIDEO" >> "$VIDEOS_DOWNLOADED_LIST_FILE"

		# remover arquivos criados durante o processo
		test -e "$DOWNLOAD_STATUS_LOG" && rm "$DOWNLOAD_STATUS_LOG"

		# redirecioanr valores para o gauge
	) | dialog --title "Baixando vídeo" --backtitle "$BACK_TITLE" --gauge "$STATUS_DOWNLOAD$ACTUAL_VIDEO" 8 80 0
}

# funcao para exibir o gauge com o processo de download
_downloadMonitor(){
	trap '' SIGINT
	# PID do processo
	DOWNLOAD=$1
	# pegar a linha que contém o nome do arquivo
	# separar apenas o nome
	# remover o espaço que fica no início
	STATUS_DOWNLOAD="Download em progresso\n"
	#ACTUAL_VIDEO=$(sed -n 5p status | cut -d':' -f2 | sed 's/\ //')
	ACTUAL_VIDEO=$(grep "Destination" "$DOWNLOAD_STATUS_LOG" | cut -d':' -f2- | sed 's/\ //')
	utils_showInfoMessage "Aguarde" "Carregando informações!"
	while [ -z "$ACTUAL_VIDEO" ]; do
		ACTUAL_VIDEO=$(grep "Destination" $DOWNLOAD_STATUS_LOG | cut -d':' -f2- | sed 's/\ //')	
	done

	#verificar se arquivo com videos baixados existe
	if [ -e "$VIDEOS_DOWNLOADED_LIST_FILE" ];then
		# se existir verificar se o vídeo atual ja foi baixado
		if [ -z $(grep -x "$ACTUAL_VIDEO" "$VIDEOS_DOWNLOADED_LIST_FILE") ]; then
			# se não tiver sido baixado continuar processo normal
			_showProgressGauge
		else
			# se tiver sido baixado exibir msg para o usuario e terminar processo
			# remover arquivos restantes
			utils_showInfoMessage "Vídeo não pode ser baixado" "O vídeo \"$ACTUAL_VIDEO\" já foi baixado"
			kill -9 "$1"

			# remover arquivos criados durante o processo
			test -e "$DOWNLOAD_STATUS_LOG" && rm "$DOWNLOAD_STATUS_LOG"
			test -e "$ACTUAL_VIDEO".part && rm "$ACTUAL_VIDEO".part
		fi
	else
		_showProgressGauge
	fi
}

# exibir processo de download do video atual
# recebe o PID do processo
downloadProcess_Show(){
	# $1 é o PID do processo que esta fazeno o download
	_downloadMonitor $1
}