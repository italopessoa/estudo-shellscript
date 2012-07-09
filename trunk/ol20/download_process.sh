#!/bin/bash
# download_bash
# script para monitorar o download dos videos
# utilizando o gauge(dialog)
# "Italo Pessoa" <italoneypessoa@gmail.com>
# 3 de julho de 2012
# Versao 1 apenas a porcentagem do download
#	Para a versão 2 pretendo exibir o nome do video sendo baixado

trap 'teste' SIGINT
source utils.sh
teste(){
	dialog --stdout \
                --title "asdasdadasd" \
                --backtitle "$BACK_TITLE" \
                --yesno "Deseja realmente cancelar?"  \
                0 0
	if [ "$?" == "0" ]; then
		kill -9 $DOWNLOAD 2> nada
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

# funcao para verificar se download ainda esta ocorrendo
_running(){
	# $1 é o PID do processo
	ps $1 | grep $1 >/dev/null;
}

# funcao para exibir o gauge com o processo de download
_downloadMonitor(){

	# PID do processo
	DOWNLOAD=$1
	# pegar a linha que contém o nome do arquivo
	# separar apenas o nome
	# remover o espaço que fica no início
	STATUS_DOWNLOAD="Download em progresso\n"
	#ACTUAL_VIDEO=$(sed -n 5p status | cut -d':' -f2 | sed 's/\ //')
	ACTUAL_VIDEO=$(grep "Destination" status | cut -d':' -f2 | sed 's/\ //')
	utils_showInfoMessage "Aguarde" "Carregando informações!"
	while [ -z "$ACTUAL_VIDEO" ]; do
		ACTUAL_VIDEO=$(grep "Destination" status | cut -d':' -f2 | sed 's/\ //')
	done
	
	# loop para checar o andamento do download
	(
		# enquanto o download estiver sendo executado a verificação será feita
		while utils_running $DOWNLOAD 2> nada; do

			# exibir a ultima linha do arquivo de log do download
			# pegar o campo que possui a porcentagem do download
			# recuperar a quantidade de caracteres que foram encontrado com a regex
			# os caracteres representam cada entrada do youtube-dl no arquivo
			QTD_DOWNLOAD_ENTRIES=$(tail -1 status | grep -o "\[download\]" | wc -w)
	
			# o primeiro campo da regex será vazio,  por isso é preciso incrementar mais um no total
			(( QTD_DOWNLOAD_ENTRIES++ ))

			# recuperar apenas a ultima linha e o ultimo trecho de código
			# recuperar a porcentagem e remover o caractere %
			TEXT=$(tail -1 status | cut -d'[' -f$QTD_DOWNLOAD_ENTRIES)
			# remover espaços e recuperar a porcentagem sem casas decimais
			PORCENTAGEM=$(_removeSpaces "$TEXT" | cut -d' ' -f2 | sed 's/\.[0-9]\{0,\}%//')

			# enviar valor de porcentagem para o dialog
			echo $PORCENTAGEM

			# aguardar a proxima verificação
			sleep 1
		done

		# aqui o download ja foi concluido, exibir a porcentagem final
		echo 100

		# redirecioanr valores para o gauge
	) | dialog --title "Baixando vídeo" --gauge "$STATUS_DOWNLOAD$ACTUAL_VIDEO" 8 40 0
}

# exibir processo de download do video atual
# recebe o PID do processo
downloadProcess_Show(){
	# $1 é o PID do processo que esta fazeno o download
	_downloadMonitor $1
}