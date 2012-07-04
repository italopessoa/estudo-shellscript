#!/bin/bash
# download_bash
# script para monitorar o download dos videos
# utilizando o gauge(dialog)
# "Italo Pessoa" <italoneypessoa@gmail.com>
# 3 de julho de 2012
# Versao 1 apenas a porcentagem do download
#	Para a versão 2 pretendo exibir o nome do video sendo baixado

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
	ACTUAL_VIDEO=$(sed -n 6p status | cut -d':' -f2 | sed 's/\ //')
	
	# loop para checar o andamento do download
	(
		# enquanto o download estiver sendo executado a verificação será feita
		while _running $DOWNLOAD; do

			# exibir a ultima linha do arquivo de log do download
			# pegar o campo que possui a porcentagem do download
			# remover o caractere %
			#PORCENTAGEM=$(tail -1 "$DOWNLOAD_STATUS_LOG" | cut -d' ' -f 1 | sed 's/%//')
			#tail -1 status | cut -d' ' -f3 | sed 's/%//'
			PORCENTAGEM=$(tail -1 status | cut -d' ' -f3 | sed 's/\.[0-9]\{0,\}%//')
			#PORCENTAGEM=1.1

			# enviar valor de porcentagem para o dialog
			echo $PORCENTAGEM

			# aguardar a proxima verificação
			sleep 1
		done

		# aqui o download ja foi concluido, exibir a porcentagem final
		echo 100

		# redirecioanr valores para o gauge
	) | dialog --title "Baixando vídeo" --gauge "Download em progresso\n$ACTUAL_VIDEO" 8 40 0
}

# exibir processo de download do video atual
# recebe o PID do processo
downloadProcess_Show(){
	# $1 é o PID do processo que esta fazeno o download
	_downloadMonitor $1
}