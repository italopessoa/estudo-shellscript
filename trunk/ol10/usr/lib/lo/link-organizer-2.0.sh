#!/bin/bash
# link-organizer-2.0
# interface aprimorada para utilização do script
# ol-1.1.0, para organizacao dos videos para download
# "Italo Pessoa" <italoneypessoa@gmail.com>

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LinkOrganizer is a simple software to organize links.                     #
#                                                                           #
# Copyright (C) 2012  Italo Pessoa<italoneypessoa@gmail.com>                #
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

	fi

	# reexibir menu principal
	linkorganizer_showMenu
}

# criar script para download dos videos
_createGeralLinksFile(){
	ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
}

# menu de configurações
_configMenu(){
	res=$( dialog --stdout \
		--title "Configurações" \
		--backtitle "$BACK_TITLE" \
		--menu "Selecione o item para configurar"  \
		0 0 0  \
		"Dados" 'Configurar o modo de obtenção dos dados do vídeo' \
		"Backup" 'Fazer backup sempre que dados forem apagados'
		)

	case "$res" in
		"Dados" )
			res=$( dialog --stdout \
				--title "Como obter os dados?" \
				--backtitle "$BACK_TITLE" \
				--menu "Selecione opção deseja"  \
				0 0 0  \
				"Standard" 'Todos os dados serão informados pelo usuário.' \
				"Easy" 'Os dados serão informados pelo usuário através da área de tranferência.' \
				"Full" 'Os dados serão obtidos através da url do vídeo, informada pelo usuário através da área de tranferência.'
				)

			case "$res" in
				"Standard" )
					utils_changeGetDaMethod "$GETDATA_STANDARD"
					;;
				"Easy" )
					utils_changeGetDaMethod "$GETDATA_CLIPBOARD_STANDARD"
					;;
				"Full" )
					utils_changeGetDaMethod "$GETDATA_CLIPBOARD_FULL"
					;;
			esac
		;;
		
		"Backup")
			dialog  \
				--title "Backup" \
				--backtitle "$BACK_TITLE" \
				--yesno "Deseja que o backup dos dados seja feito ao limpar as informações atuais?"  \
				5 76
			
			case "$?" in
				"0" )
					utils_changeMakeBackup "0"
					;;
				"1" )
					utils_changeMakeBackup "1"
					;;
			esac
			;;
	esac
	source "$SETTINGS"	
}

#exibir menu principal
linkorganizer_showMenu(){
	#trap '' SIGHUP SIGINT SIGQUIT SIGTERM SIGSTOP
	# importar script para obtenção das informacoes dos videos
	#source get-data.sh
	#source checkVideos.sh

	# items do menu pricipal
	menuItems=(
		"Adicionar Adicionar\\ novo\\(s\\)\\ vídeo\\(s\\)"
		"Vídeos Vídeos\\ disponíveis"
		"Selecionar Selecionar\\ vídeos\\ para\\ download"
		"Listar Vídeos\\ selecionados\\ para\\ download"
		"Limpar Remover\\ todos\\ os\\ dados\\ CUIDADO"
		"Download Executar\\ download\\ de\\ todos\\ os\\ vídeos"
		"Configurações Modificar\\ configurações"
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
			unset menuItems[2]
			else if [ ! -s "$SELECTED_VIDEOS" ]; then
				unset menuItems[3]
			fi
		fi
	fi

	# remover item Download caso nao exista o script
	if [ ! -e "$VIDEO_SCRIPT" ]; then
		if [ ! -e "$LIST_SCRIPT" ];then
			unset menuItems[5]
		fi
	fi

	# armazenar item escolhido
	res=$( eval \ dialog --stdout \
           --title \"Vídeos cadastrados\" \
           --backtitle \"$BACK_TITLE\" \
           --menu \"Selecione o vídeos para download\"  \
           0 0 0 ${menuItems[@]} 
		)

	if [ $? -eq 0 ];then
		case "$res" in
			"Adicionar" )
				# adicionar um novo video
				getData_Main
				;;
			"Vídeos" )
				# exibir videos adicioandos a lista
				_showVideos "$LIST_VIDEOS_FILE" "Lista de vídeos"
				;;
			# "Gerar" )
			# 	#source ol-1.1.0.sh
			# 	_createGeralLinksFile
			# 	;;
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
				OPCAO=$( dialog --stdout \
								--title 'Selecione' \
								--backtitle "$BACK_TITLE" \
								--radiolist 'Opção de download'  \
								0 0 0  \
								Todos  'Baixar todos os vídeos'      on  \
								Selecionar 'Baixar um único vídeo'  off )

				EXECUTE=""
				case "$OPCAO" in
					"Todos" )
						#se o arquivo padrão existir
						if [ -e "$VIDEO_SCRIPT" ]; then
							# verificar se possui a lista de videos personalizada
							if [ -e "$LIST_SCRIPT" ]; then
								# se possuir exibir msg informando que pode escolher os vídeos que serão baixados
								ITEM=$( dialog --stdout \
										--title 'Selecione' \
										--backtitle "$BACK_TITLE" \
										--radiolist 'Quais vídeos deseja baixar?'  \
										0 0 0  \
										Padrão  'Todos os vídeos'      on  \
										Lista 'Vídeos Selecionados'  off ) 

								case "$ITEM" in
									"Padrão" )
										export EXECUTE="$VIDEO_SCRIPT"
									;;
									"Lista" )
										export EXECUTE="$LIST_SCRIPT"
									;;
									*)
										linkorganizer_showMenu
									;;
								esac

							else
								# se não possuir executar download com o script padrão	
								export EXECUTE="$VIDEO_SCRIPT"
							fi
						# se o arquivo padrão não existir pode existir uma lista
						else
							# se existir o arquivo a ser execuado será ele
							if [ -e "$LIST_SCRIPT" ]; then
								export EXECUTE="$LIST_SCRIPT"
								#exibir msg  informando que os vídeos baixados serão os da lista
							fi
						fi
						;;
					"Selecionar" )
						checkVideos_OneVideo
						export EXECUTE="$ONE_VIDEO_DOWNLOAD"
						;;
					*)
						linkorganizer_showMenu
						;;
				esac
				./"$EXECUTE" 2> /dev/null
				;;

			"Configurações")
				_configMenu
				linkorganizer_showMenu
				;;

			"Sair" )
				clear
				killall "$VIDEO_SCRIPT" "$LIST_SCRIPT"
				test ! "$1" && killall "$EXECUTE"
				clear
				exit 0;
				;;
			*)
				clear
			;;
		esac
	else
		clear
		killall "$VIDEO_SCRIPT" "$LIST_SCRIPT"
		test ! "$1" && killall "$EXECUTE"
		clear
		exit 1;
	fi
}