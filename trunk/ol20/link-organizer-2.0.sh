#!/bin/bash
# link-organizer-2.0
# interface aprimorada para utilização do script
# ol-1.1.0, para organizacao dos videos para download
# "Italo Pessoa" <italoneypessoa@gmail.com>

#trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP 255

# exibir videos adicionados na lista
_showVideos(){

	# verificar se o arquivo existe e se contem algum video
	if [ -s "$1" ];then
		dialog \
			--title "$2" \
			--backtitle "$BACK_TITLE" \
			--textbox "$1" \
			20 70

	else
		# exibir mensagem informando que nao existe nenhum video na lista
		message_showInfo "Atenção" "Não existem vídeos na lista."
	#	dialog \
	#		--title 'Atenção' \
	#		--backtitle "$BACK_TITLE" \
	#		--sleep "2" \
	#		--infobox "Não existem vídeos na lista."  \
	#		3 40

	fi

	# reexibir menu principal
	linkorganizer_showMenu
}

# criar script para download dos videos
_createGeralLinksFile(){
	# importar script original de criação do script para
	# organizcao dos links
	source ol-1.1.0.sh
	ol_createLinksFile
}

#exibir menu principal
linkorganizer_showMenu(){
	# importar script para obtenção das informacoes dos videos
	#source get-data.sh
	#source checkVideos.sh

	# items do menu pricipal
	menuItems=(
		"Adicionar Adicionar\\ novo\\(s\\)\\ vídeo\\(s\\)"
		"Vídeos Vídeos\\ disponíveis"
		"Gerar Gerar\\ script\\ para\\ download"
		"Selecionar Selecionar\\ vídeos\\ para\\ download"
		"Listar Vídeos\\ selecionados\\ para\\ download"
		"Limpar Remover\\ todos\\ os\\ dados\\ CUIDADO"
		"Download Executar\\ download\\ de\\ todos\\ os\\ vídeos"
		"Sair Encerrar\\ programa"
	)


	if [ ! -e "$NAMES_FILE" ]; then
		# remover todos os itens de menu que necessitam de dados
		unset menuItems[1]
		unset menuItems[2]
		unset menuItems[3]
		unset menuItems[4]
		unset menuItems[5]

	# remover item Limpar, caso não exista pelo menos um dos arquivo de dados
	# verificado apenas um arquivo pois todos são criados juntos
	# unset menuItems[4]
	else if [ ! -s "$AVAILABLE_VIDEO" ]; then
			unset menuItems[3]
			unset menuItems[6]
			else if [ ! -s "$SELECTED_VIDEOS" ]; then
				unset menuItems[4]
			fi
		fi
	fi

	# armazenar item escolhido
	res=$( eval \ dialog --stdout \
           --title \"Vídeos cadastrados\" \
           --backtitle \"$BACK_TITLE\" \
           --menu \"Selecione o vídeos para download\"  \
           0 0 0 ${menuItems[@]} 
		)

	case "$res" in
		"Adicionar" )
			# adicionar um novo video
			getData_Main
			;;
		"Vídeos" )
			# exibir videos adicioandos a lista
			_showVideos "$LIST_VIDEOS_FILE" "Lista de vídeos"
			;;
		"Gerar" )
			#source ol-1.1.0.sh
			_createGeralLinksFile
			;;
		"Selecionar" )
			# selecionar videos para download
			checkVideos_Main
			;;
		"Limpar" )
			# remover todos os arquivos
			getData_clearData
			;;
		"Listar" )
			# vídeos selecionados para download
			_showVideos "$SELECTED_VIDEOS" "Vídeos selecionado para download"
			;;
		"Download" )
			# executar script para download dos videos
			./links.sh
			;;
		"Sair" )
			# encerrar programa
			#export STOP_PROCESSES="1"
			p=$(top -b -n1 | grep bash | cut -d' ' -f1)
			kill -9 $$
			exit 0;
			;;
	esac
}