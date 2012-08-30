#!/bin/bash
# get-data
# script para capturar os dados dos videos
# "Italo Pessoa" <italoneypessoa@gmail.com>

# remover todos os arquivos
getData_clearData(){

	if [ "$MAKE_BACKUP" ]; then
		_dataBackup
	fi

	for fileVar in $NAMES_FILE $LINKS_FILE $LIST_VIDEOS_FILE $AVAILABLE_VIDEO $SELECTED_VIDEOS $NAMES_LIST $LINKS_LIST $DOWNLOAD_STATUS_LOG; do
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

	localDir="$localDir"_$(date +%d-%m-%Y_%H-%M-%S)
	mkdir "$BACKUP_DIR/$localDir"
	echo "The original path of these files was: $(pwd)" > "$BACKUP_DIR/$localDir/$BACKUP_INF_FILE"

	files=($LIST_VIDEOS_FILE $NAMES_FILE $LINKS_FILE $NAMES_LIST $LINKS_LIST $AVAILABLE_VIDEO $SELECTED_VIDEOS)
	for file in ${files[@]} ; do
		cp "$file" "$BACKUP_DIR/$localDir/$file"_$(date +%d-%m-%Y_%H-%M-%S).$RANDOM
	done

# date +%d-%m-%Y_%H-%M-%S
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
	#youtubeLink=$(utils_youtubeRegex $1)
	echo "$number $1" >> $LINKS_FILE
}

# remover video do arquiov de links e nomes
_removeVideoOfFile(){
	linha=$(wc -l "$LIST_VIDEOS_FILE" | cut -d' ' -f1)
	echo "linha" >fff
	sed -i "$linha"d $NAMES_FILE
	sed -i "$linha"d $AVAILABLE_VIDEO
	sed -i "$linha"d $LIST_VIDEOS_FILE
	sed -i "$linha"d $LINKS_FILE
}



#TODO verificar se o titulo ja nao foi utilizado
#TODO um link nao pode ser o titulo do video
#TODO na parte do link fazer a verificaçao se é realmente um link do youtube válido
# _validTitle(){
	
# 	# se estiver utilizando o copiar, fazer esse teste
# 	if [ "$VAR" ]; then
# 		while [ "$TITULO" == "None" ] || [ ! "$TITULO" ]; do
# 			#verificar se está utilizando o script de copiar para exibir msg diferente
# 			utils_showInfoMessage "Valor não válido" "Cópie o  titulo novamente"
# 			#_validTitle
# 			dialog --title "Copie o texto desejado" --msgbox "Ao copiar selecione a opcao para recuperar os dados" 5 70
# 			TITULO=$(python get-clipboard.py)
# 			_validTitle
# 		done
# 	fi

# 	if [ -e "$LIST_VIDEOS_FILE" ]; then
# 		echo "$TITULO" > macumba
# 		while utils_nameAlreadyExists "$TITULO" "$LIST_VIDEOS_FILE"; do
# 			dialog \
# 		    --title "Atenção" \
# 		    --backtitle "$BACK_TITLE" \
# 		    --msgbox "Esse nome já é utilizado"  \
# 		    5 35

# 		    # if nao estiver utilizadno o copiar, pedir novamente o titulo
# 		    if [ "$VAR" ]; then
# 		    	dialog --title "Copie o texto desejado" --msgbox "Ao copiar selecione a opcao para recuperar os dados" 5 70
# 				TITULO=$(python get-clipboard.py)
# 				_validTitle
# 		    else
# 		    	TITULO=$( dialog  --stdout \
# 					--title 'Dados do vídeo' \
# 					--backtitle "$BACK_TITLE" \
# 					--inputbox 'Título do vídeo:' \
# 					0 100 )
# 				continuar=$?
# 		    fi
# 		done
# 	fi
# }

#testando
# mensagem de sucesso ao adicionar um novo video
_sucess(){
	dialog \
		--title "Vídeo adicionado a lista de downloads - [Esc] para parar."\
		--backtitle "$BACK_TITLE" \
		--yesno "$@\nEste arquivo deve permanecer?"  \
		0 0 

	if [ "$?" -eq "1" ]; then
		# remover video do arquivo de links e nomes
		#_removeVideoOfFile
		#nao fazer nada
		echo "x" >/dev/null
	else
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

	    	#dialog --title "Copie o texto desejado" --msgbox "Ao copiar selecione a opcao para recuperar os dados" 5 70
	    	continuar=$?
			if [ $continuar -eq 0 ]; then
				getClipboardTitle
			fi
		done
	fi
}

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

_getClipboardTitle(){
	dialog --title "Copie o texto desejado" --msgbox "Ao copiar selecione a opção para recuperar os dados" 5 70
	continuar=$?
	if [ $continuar -eq 0 ]; then
		TITULO=$(python get-clipboard.py)
		_validClipboardTitle
	fi
}

_getClipboardLink(){
	dialog --title "Copie o link desejado" --msgbox "Ao copiar selecione a opção para recuperar os dados" 5 70
	LINK=$(python get-clipboard.py)
	_validClipboardLink
}

_getDataFromUrl(){
	
	dialog --title "Copie o link desejado" --msgbox "Ao copiar selecione a opção para recuperar os dados.
	 \nAguarde o processamento dos dados." 6 70

	LINK=$(python get-clipboard.py)
	while ! utils_isUTubeLink "$LINK" ; do
		dialog \
	        --title "Atenção" \
	        --backtitle "$BACK_TITLE" \
	        --msgbox "Esse não é um link do YouTube" \
	        5 35

		dialog --title "Copie o link desejado" --msgbox "Ao copiar selecione a opção para recuperar os dados.
		 \nAguarde o processamento dos dados." 6 70
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

	    	#dialog --title "Copie o texto desejado" --msgbox "Ao copiar selecione a opcao para recuperar os dados" 5 70
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
			#ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
			linkorganizer_showMenu #
		;;
	esac
}

# recuperar nome do video
_getTitulo(){
	# armazenar titulo do video
	TITULO=""

	case "$GET_DATA_METHOD" in

		"$GETDATA_STANDARD" )
			TITULO=$( dialog  --stdout \
					--title 'Dados do vídeo' \
					--backtitle "$BACK_TITLE" \
					--inputbox 'Título do vídeo:' \
					0 100 
				)

				continuar=$?
				# if [ "$continuar" -eq "0" ]; then
				# 	_validTitle
				# fi
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
				_getTitulo
			else
				# enviar nome do video para arquivo de nomes
				#_sendNameForFile $titulo
				# recuperar link do video
				_getLink
			fi 
		;;
		1)	# reexibir menu principal
			#ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
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
				#adicionar acima para melhorar
				#--and-widget \
		       	#--yesno '\nVocê aceita os Termos da Licença?' 8 30

			continuar=$?
			# enquanto o link digitado já existir
			# exibir alerta e pedir o link novamente
			#TODO verificar se é link do you tube
			#FIXME não está funcionando
			#FIXME CORRIGIR BUG AO ADICIONAR UM LINK REPETIDO
			if [ "$continuar" ];then
				while ! utils_isUTubeLink "$LINK" ; do
					dialog \
				        --title "Atenção" \
				        --backtitle "$BACK_TITLE" \
				        --msgbox "Esse não é um link do YouTube" \
				        5 35
				        #_getLink
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
					        #_getLink
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
				#_sendLinkForFile $link
				# deixar o link com o formato correto para diminuir a chamada de funcoes
				LINK=$(utils_youtubeRegex "$LINK")

				./"$GET_VIDEO_FORMAT_SCRIPT" "$LINK"
				format=$(cut -d":" -f1 format)
				ext=$(cut -d":" -f2 format)

				TITULO="$TITULO$ext"
				LINK="$LINK -f$format"

				# exibir mensagem de sucesso no cadastro do video
				_sucess #"$titulo"
			fi
		;;
		1)	# reexibir menu principal
			#ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
			linkorganizer_showMenu 
		;;
		2) echo  HELP ;;
		255) echo sairE ;;
		*) utils_showErrorMessage "Erro" "Opção desconhecida";;
	esac
}

# verificar se o nome do vídeo já é existe
#_nameAlreadyExists(){
	#echo "$@" > par
	# o arquivo possui alguns caracteres antes do nome
	# eles devem ser considerados apenas para comparar
	#grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $@" "$NAMES_FILE" > /dev/null
	#solucao mais simples
#	grep -x "$@" "$LIST_VIDEOS_FILE"
#}

# verificar se o do vídeo já é utilizado
#_videoAlreadyExists(){
#	L=$(utils_youtubeRegex "$@")
#	grep -x ".*$L" "$LINKS_FILE"
#}

# funcao principal
getData_Main(){
	# importar script com menu principal
	#source link-organizer-2.0.sh

	# importar funcao do script para limpar url do youtube
	#source youtubeRegex.sh

	#if [ ! -e "$NAMES_FILE" ]; then
		# criar arquivos necessarios para armazenar e gerenciar videos
	#	_createFiles
	#fi	

	continuar=0

	# laco para adicionar videos
	while [ "$continuar" -eq "0" ]
	do
		# recuperar titulo do video
		_getTitulo
	done

	#ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
}

#tail  -1 log | cut -d' ' -f4,5,6,7,10,11,12 | sed 's/\[download\]//g'