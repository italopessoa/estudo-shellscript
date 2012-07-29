#!/bin/bash
# get-data
# script para capturar os dados dos videos
# "Italo Pessoa" <italoneypessoa@gmail.com>

# remover todos os arquivos
getData_clearData(){
	for fileVar in $NAMES_FILE $LINKS_FILE $LIST_VIDEOS_FILE $AVAILABLE_VIDEO $SELECTED_VIDEOS $NAMES_LIST $LINKS_LIST; do
		if [ -e "$fileVar" ]; then
			rm "$fileVar"
		fi

		# remover arquivos de copia
		if [ -e "$fileVar~" ]; then
			rm "$fileVar~"
		fi
	done
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
	linha=$(wc -l titulos | cut -d' ' -f1)
	sed -i "$linha"d $NAMES_FILE
	sed -i "$linha"d $AVAILABLE_VIDEO
	sed -i "$linha"d $LIST_VIDEOS_FILE
	sed -i "$linha"d $LINKS_FILE
}

# mensagem de sucesso ao adicionar um novo video
_sucess(){
	dialog \
		--title "Vídeo adicionado a lista de downloads - [Esc] para parar."\
		--backtitle "$BACK_TITLE" \
		--yesno "$@\nEste arquivo deve permanecer?"  \
		0 0 

	if [ "$?" -eq "1" ]; then
		# remover video do arquivo de links e nomes
		_removeVideoOfFile
	else
		# criar arquivos necessarios para armazenar e gerenciar videos
		if [ ! -e "$NAMES_FILE" ]; then
			_createFiles
		fi

		#TODO adicionar esse trecho de codigo na captura do link do video e nao no suecsso
		./"$GET_VIDEO_FORMAT_SCRIPT" "$LINK"
		format=$(cut -d":" -f1 format)
		ext=$(cut -d":" -f2 format)


		# adicionar titulo ao arquivo nomes.video
		_sendNameForFile "$TITULO$ext"
		# adicionar url ao arquivo links.video
		_sendLinkForFile "$LINK -f$format"

		ol_Main "$NAMES_FILE" "$LINKS_FILE" "$VIDEO_SCRIPT"
	fi
}

# recuperar nome do video
_getTitulo(){
	# armazenar titulo do video
	TITULO=""
	TITULO=$( dialog  --stdout \
		--title 'Dados do vídeo' \
		--backtitle "$BACK_TITLE" \
		--inputbox 'Título do vídeo:' \
		0 100 
	)

	continuar=$?
	# enquanto o nome digitado já existir
	# exibir alerta e pedir o nome novamente
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