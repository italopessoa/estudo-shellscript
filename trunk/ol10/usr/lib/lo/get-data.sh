#!/bin/bash
# get-data.sh
# script para capturar os dados dos videos
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


# remover todos os arquivos
getData_clearData(){
	# verificar se deve ser feito o backup
	if [ "$MAKE_BACKUP" ]; then
		_dataBackup
	fi

	for fileVar in $NAMES_FILE $LINKS_FILE $LIST_VIDEOS_FILE $AVAILABLE_VIDEO $SELECTED_VIDEOS $NAMES_LIST $LINKS_LIST $DOWNLOAD_STATUS_LOG $ONE_VIDEO_DOWNLOAD $FORMAT_FILE; do
		if [ -e "$fileVar" ]; then
			rm "$fileVar"
		fi

		# remover arquivos de copia
		if [ -e "$fileVar~" ]; then
			rm "$fileVar~"
		fi
	done
}

#TODO verificar se possui bzip2 ou gzip para compactar o backup
_dataBackup(){

	# filtrar caminho completo do diretorio e armazenar em array
	dirArray=$(pwd | sed "s/\//\n/g")
	# diretorio utilizado para armazenar dados
	localDir=""
	for dir in ${dirArray[@]} ; do
		 localDir="$dir"
	done

	localDir="$localDir"
	data_hora_random=$(date +%d-%m-%Y_%H-%M-%S).$RANDOM
	mkdir "$BACKUP_DIR/$localDir"
	echo "The original path of these files was: $(pwd)" > "$BACKUP_DIR/$localDir/$BACKUP_INF_FILE"

	files=($LIST_VIDEOS_FILE $NAMES_FILE $LINKS_FILE $NAMES_LIST $LINKS_LIST $AVAILABLE_VIDEO $SELECTED_VIDEOS)
	for file in ${files[@]} ; do
		if [ -e "$file" ]; then
			cp "$file" "$BACKUP_DIR/$localDir/$file"
		fi
	done
	
	atualDir=$(pwd)
	cd "$BACKUP_DIR"
	tar -cf "$localDir""_$data_hora_random.tar" "$localDir"
	gzip "$localDir""_$data_hora_random.tar"
	rm -rf "$localDir"
	cd "$atualDir"
}

# criar arquivos necessarios para armazenar e gerenciar videos
_createFiles(){
	for fileVar in $NAMES_FILE $LINKS_FILE $LIST_VIDEOS_FILE $AVAILABLE_VIDEO; do
		if [ ! -e "$fileVar" ]; then
			touch "$fileVar"
		fi
	done
}

# enviar nome do video digitado para arquivo de nomes
_sendNameForFile(){
	number=$(wc -l $NAMES_FILE | cut -d' ' -f1)
	number=$(( $number +1 ))
	echo "$number - @$number $@" >> $NAMES_FILE
	echo "'$@'" " '' " "off" >> $AVAILABLE_VIDEO
	echo $@ >> $LIST_VIDEOS_FILE
}

# enviar link do video digitado para arquivo de links
_sendLinkForFile(){
	number=$(wc -l $LINKS_FILE | cut -d' ' -f1)
	number=$(( $number +1 ))
	echo "$number $1" >> $LINKS_FILE
}

# remover video do arquiov de links e nomes
_removeVideoOfFile(){
	linha=$(wc -l "$LIST_VIDEOS_FILE" | cut -d' ' -f1)
	sed -i "$linha"d $NAMES_FILE
	sed -i "$linha"d $AVAILABLE_VIDEO
	sed -i "$linha"d $LIST_VIDEOS_FILE
	sed -i "$linha"d $LINKS_FILE
}

# mensagem de sucesso ao adicionar um novo video
_sucess(){
	dialog \
		--title "Vídeo adicionado a lista de downloads."\
		--backtitle "$BACK_TITLE" \
		--yesno "$@\nEste arquivo deve permanecer?"  \
		0 0 

	if [ "$?" -eq "0" ]; then
		# criar arquivos necessarios para armazenar e gerenciar videos
		if [ ! -e "$NAMES_FILE" ]; then
			_createFiles
		fi

		# adicionar titulo ao arquivo nomes.video
		_sendNameForFile "$TITULO"
		# adicionar url ao arquivo links.video
		_sendLinkForFile "$LINK"

		ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
	fi

	# caso o modo de captura seja full, exibir opcao de cancelamento 
	# da obtencao dos dados
	if [ ! "$GET_DATA_METHOD" = "$GETDATA_STANDARD" ]; then
		dialog \
		--title "Essa configuração não possui opção de cancelamento."\
		--backtitle "$BACK_TITLE" \
		--yesno "Deseja continuar?"  \
		0 0

		if [ $? -eq 1 ]; then
			linkorganizer_showMenu
		fi
	fi
}

#TODO verificar se o titulo ja nao foi utilizado
#TODO um link nao pode ser o titulo do video
#TODO na parte do link fazer a verificaçao se é realmente um link do youtube válido
# validar o titulo capturado da area de tranferencia(clipboard)
_validClipboardTitle(){
	
	# se estiver utilizando o copiar, fazer esse teste
	while [ "$TITULO" == "None" ] || [ ! "$TITULO" ]; do
		#verificar se está utilizando o script de copiar para exibir msg diferente
		utils_showInfoMessage "Valor inválido" "Cópie o  titulo novamente"
		getClipboardTitle
	done

	if [ -e "$LIST_VIDEOS_FILE" ]; then
		while utils_nameAlreadyExists "$TITULO" "$LIST_VIDEOS_FILE"; do
			dialog \
		    --title "Atenção" \
		    --backtitle "$BACK_TITLE" \
		    --msgbox "Esse nome já é utilizado"  \
		    5 35

	    	continuar=$?
			if [ $continuar -eq 0 ]; then
				getClipboardTitle
			fi
		done
	fi
}

# validar o link capturado da area de tranferencia(clipboard)
_validClipboardLink(){
	while ! utils_isUTubeLink "$LINK" ; do
		dialog \
	        --title "Atenção" \
	        --backtitle "$BACK_TITLE" \
	        --msgbox "Esse não é um link do YouTube" \
	        5 35

	        if [ $continuar -eq 0 ]; then
				_getClipboardLink
			fi
	        
	done

	if [ -e "$LINKS_FILE" ]; then
		while utils_videoAlreadyExists "$LINK" "$LINKS_FILE"; do
				dialog \
		        --title "Atenção" \
		        --backtitle "$BACK_TITLE" \
		        --msgbox "Esse link já é utilizado" \
		        5 35

		        if [ $continuar -eq 0 ]; then
					_getClipboardLink
				fi
		done
	fi
}

# recuperar titulo da area de transferencia(clipboard)
_getClipboardTitle(){
	dialog \
	--title "Copie o texto desejado" \
	--backtitle "$BACK_TITLE" \
	--msgbox "Ao copiar selecione a opção para recuperar os dados" \
	5 70
	continuar=$?
	if [ $continuar -eq 0 ]; then
		TITULO=$(python /usr/lib/lo/get-clipboard.py)
		_validClipboardTitle
	fi
}

# recuperar link da area de transferencia(clipboard)
_getClipboardLink(){
	dialog \
	--title "Copie o link desejado" \
	--backtitle "$BACK_TITLE" \
	--msgbox "Ao copiar selecione a opção para recuperar os dados" \
	5 70
	LINK=$(python /usr/lib/lo/get-clipboard.py)
	_validClipboardLink
}

#recuperar dados do video utilizando a url do vídeo
_getDataFromUrl(){
	
	dialog \
		--title "Copie o link desejado" \
		--backtitle "$BACK_TITLE" \
		--msgbox "Ao copiar selecione a opção para recuperar os dados.
	 	\nAguarde o processamento dos dados." \
	 6 70

	LINK=$(python /usr/lib/lo/get-clipboard.py)
	while ! utils_isUTubeLink "$LINK" ; do
		dialog \
	        --title "Atenção" \
	        --backtitle "$BACK_TITLE" \
	        --msgbox "Esse não é um link do YouTube" \
	        5 35

		dialog \
			--title "Copie o link desejado" \
			--backtitle "$BACK_TITLE" \
			--msgbox "Ao copiar selecione a opção para recuperar os dados.
	 		\nAguarde o processamento dos dados." \
	 		6 70

		_getDataFromUrl
	done

	youTubeFile=$(tempfile)
	wget -O "$youTubeFile" -o $(tempfile) "$LINK"
	LINK=$1
	TITLE_REGEX="<meta property=\"og:title"
	LINK_REGEX="<meta property=\"og:url"

	LINK=$(grep "$LINK_REGEX" "$youTubeFile" | sed 's/.*="// ;s/">//')
	TITULO=$(grep "$TITLE_REGEX" "$youTubeFile" | sed 's/.*="// ;s/">//')

	if [ -e "$LIST_VIDEOS_FILE" ]; then
		while utils_nameAlreadyExists "$TITULO" "$LIST_VIDEOS_FILE"; do
			TITULO=$( dialog --stdout \
		    --title "Atenção" \
		    --backtitle "$BACK_TITLE" \
		    --inputbox "Esse nome já é utilizado, forneça outro" 7 75 )

	    	continuar=$?
		done
	fi

	case "$continuar" in
		0) 
			if [ -z "$TITULO" ]; then
				# exibir mensagem
				while [ -z "$TITULO" ]; do
					TITULO=""
					TITULO=$( dialog --stdout \
					    --title "Dados incompletos" \
					    --backtitle "$BACK_TITLE" \
					    --inputbox "Insira o título do vídeo!"  \
					    7 75 )
					continuar=$?
				done
			else
				if [ $continuar -eq 0 ]; then
					if [ -e "$LINKS_FILE" ]; then
						if utils_videoAlreadyExists "$LINK" "$LINKS_FILE" ; then
							dialog \
						        --title "Atenção" \
						        --backtitle "$BACK_TITLE" \
						        --msgbox "Esse link já é utilizado" \
						        5 35

					        if [ $continuar -eq 0 ]; then
								_getDataFromUrl
							fi
						fi
					fi
				fi
			fi 
		;;
		1)	# reexibir menu principal
			linkorganizer_showMenu
		;;
	esac
}

# recuperar nome do video
_getTitle(){
	# armazenar titulo do video
	TITULO=""
	# correcao para a primeira execucao
	if [ ! "$GET_DATA_METHOD" ]; then
		GET_DATA_METHOD="$GETDATA_STANDARD"
	fi
	case "$GET_DATA_METHOD" in

		"$GETDATA_STANDARD" )
			TITULO=$( dialog  --stdout \
					--title 'Dados do vídeo' \
					--backtitle "$BACK_TITLE" \
					--inputbox 'Título do vídeo:' \
					0 100 
				)

				continuar=$?
				# enquanto o nome digitado já existir
				# exibir alerta e pedir o nome novamente
				if [ -e "$LIST_VIDEOS_FILE" ]; then
					while utils_nameAlreadyExists "$TITULO" "$LIST_VIDEOS_FILE"; do
						dialog \
				       --title "Atenção" \
				       --backtitle "$BACK_TITLE" \
				       --msgbox "Esse nome já é utilizado"  \
				       5 35

						TITULO=$( dialog  --stdout \
								--title 'Dados do vídeo' \
								--backtitle "$BACK_TITLE" \
								--inputbox 'Título do vídeo:' \
								0 100 )
						continuar=$?
					done
				fi
		;;

		"$GETDATA_CLIPBOARD_STANDARD")
			_getClipboardTitle
		;;

		"$GETDATA_CLIPBOARD_FULL")
			_getLink
		;;
	esac
	

	case "$continuar" in
		0) 
			if [ -z "$TITULO" ]; then
				# exibir mensagem
				utils_showInfoMessage "Dados incompletos" "Insira o título do vídeo!"
				_getTitle
			else
				# enviar nome do video para arquivo de nomes
				# recuperar link do video
				_getLink
			fi 
		;;
		1)	# reexibir menu principal
			linkorganizer_showMenu #
		;;
		2) echo  HELP ;;
		255) echo sairE ;;
		*)
			utils_showErrorMessage "Erro" "Opção desconhecida"
		;;
	esac
}

# recuperar link do video
_getLink(){
	# armazenar url do video
	LINK=""

	case "$GET_DATA_METHOD" in

		"$GETDATA_STANDARD" )
			LINK=$( dialog  --stdout \
				--title 'Dados do vídeo' \
				--backtitle "$BACK_TITLE" \
				--inputbox 'Link do youtube:' \
				0 100 
			)

			continuar=$?
			# enquanto o link digitado já existir
			# exibir alerta e pedir o link novamente
			if [ "$continuar" ];then
				while ! utils_isUTubeLink "$LINK" ; do
					dialog \
				        --title "Atenção" \
				        --backtitle "$BACK_TITLE" \
				        --msgbox "Esse não é um link do YouTube" \
				        5 35

				        LINK=$( dialog  --stdout \
								--title 'Dados do vídeo' \
								--backtitle "$BACK_TITLE" \
								--inputbox 'Link do youtube:' \
								0 100 )
						continuar=$?
				done

				if [ -e "$LINKS_FILE" ]; then
					while utils_videoAlreadyExists "$LINK" "$LINKS_FILE"; do
							dialog \
					        --title "Atenção" \
					        --backtitle "$BACK_TITLE" \
					        --msgbox "Esse link já é utilizado" \
					        5 35

							LINK=$( dialog  --stdout \
									--title 'Dados do vídeo' \
									--backtitle "$BACK_TITLE" \
									--inputbox 'Link do youtube:' \
									0 100 )
							continuar=$?
					done
				fi
			fi
		;;
		"$GETDATA_CLIPBOARD_STANDARD")
			_getClipboardLink
		;;

		"$GETDATA_CLIPBOARD_FULL")
			_getDataFromUrl
		;;
	esac


	case "$continuar" in
		0) 
			if [ -z "$LINK" ]; then
				# exibir mensagem
				utils_showInfoMessage "Dados incompletos" "Insira o link do vídeo!"
				_getLink
			else
				# enviar link para arquivo de links
				# deixar o link com o formato correto para diminuir a chamada de funcoes
				LINK=$(utils_youtubeRegex "$LINK")

				videoFormat_Main "$LINK"
				format=$(cut -d":" -f1 "$FORMAT_FILE")
				ext=$(cut -d":" -f2 "$FORMAT_FILE")

				TITULO="$TITULO$ext"
				LINK="$LINK -f$format"

				# exibir mensagem de sucesso no cadastro do video
				_sucess
			fi
		;;
		1)	# reexibir menu principal
			linkorganizer_showMenu 
		;;
		2) echo  HELP ;;
		255) echo sairE ;;
		*) utils_showErrorMessage "Erro" "Opção desconhecida";;
	esac
}

# funcao principal
getData_Main(){

	continuar=0

	# laco para adicionar videos
	while [ "$continuar" -eq "0" ]
	do
		# recuperar titulo do video
		_getTitle
	done
}