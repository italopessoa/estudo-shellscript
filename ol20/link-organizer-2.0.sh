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
	#source "$GENERATE_SCRIPT_DOWNLOAD_SCRIPT"
	#ol_createLinksFile
	ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
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
			else if [ ! -s "$SELECTED_VIDEOS" ]; then
				unset menuItems[4]
			fi
		fi
	fi

	# remover item Download caso nao exista o script
	if [ ! -e "$VIDEO_SCRIPT" ]; then
		if [ ! -e "$LIST_SCRIPT" ];then
			unset menuItems[6]
		fi
	fi
x="$mi"
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
			linkorganizer_showMenu
			;;
		"Listar" )
			# vídeos selecionados para download
			_showVideos "$SELECTED_VIDEOS" "Vídeos selecionado para download"
			;;
		"Download" )
			# executar script para download dos videos
			#./"$VIDEO_SCRIPT" 2> /dev/null
			#$LIST_SCRIPT

			#se o arquivo padrão existir
			if [ -e "$VIDEO_SCRIPT" ]; then
				# verificar se possui a lista de videos personalizada
				if [ -e "$LIST_SCRIPT" ]; then
					# se possuir exibir msg informando que pode escolher os vídeos que serão baixados
					ITEM=$( dialog --stdout \
							--title 'Selecione' \
							--radiolist 'Quais vídeos deseja baixar?'  \
							0 0 0  \
							Padrão  'Todos os vídeos'      on  \
							Lista 'Vídeos Selecionados'  off ) 

					case "$ITEM" in
						"Padrão" )
							EXECUTE="$VIDEO_SCRIPT"
						;;
						"Lista" )
							EXECUTE="$LIST_SCRIPT"
						;;
						*)
							linkorganizer_showMenu
						;;
					esac

				else
					# se não possuir executar download com o script padrão	
					EXECUTE="$VIDEO_SCRIPT"
				fi
			# se o arquivo padrão não existir pode existir uma lista
			else
				# se existir o arquivo a ser execuado será ele
				if [ -e "$LIST_SCRIPT" ]; then
					EXECUTE="$LIST_SCRIPT"
					#exibir msg  informando que os vídeos baixados serão os da lista
				fi
			fi

			./"$EXECUTE" 2> /dev/null
			;;
		"Sair" )

			vet=($PROCESS_KILL)
			#foreach
			#for key in ${!vet[*]}; do
			#	echo ${vet[$key]};
			#done

			# encerrar programa
			#export STOP_PROCESSES="1"
			#p=$(top -b -n1 | grep bash | cut -d' ' -f1)
			#kill -9 $$
			clear
			killall "$VIDEO_SCRIPT"
			clear
			exit 0;
			;;
		*)
			clear
		;;
	esac
}