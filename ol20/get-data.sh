#!/bin/bash
# get-data
# script para capturar os dados dos videos
# "Italo Pessoa" <italoneypessoa@gmail.com>

# remover todos os arquivos
getData_clearData(){
	for fileVar in $NAMES_FILE $LINKS_FILE $LIST_VIDEOS_FILE $AVAILABLE_VIDEO $SELECTED_VIDEOS; do
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
	youtubeLink=$(utils_youtubeRegex $1)
	echo "$number $youtubeLink" >> $LINKS_FILE
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
	dialog                                 \
		--title "Vídeo adicionado a lista de downloads - [Esc] para parar."\
		--backtitle "$BACK_TITLE" \
		--yesno "$@\nEste arquivo deve permanecer?"  \
		0 0 

	if [ "$?" -eq "1" ]; then
		# remover video do arquivo de links e nomes
		_removeVideoOfFile
	else
		# adicionar titulo ao arquivo nomes.video
		_sendNameForFile $TITULO
		# adicionar url ao arquivo links.video
		_sendLinkForFile $LINK
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
	#_nameAlreadyExists "$TITULO"
	while _nameAlreadyExists "$TITULO"; do
		TITULO=$( dialog  --stdout \
				--title 'Dados do vídeo' \
				--backtitle "$BACK_TITLE" \
				--inputbox 'Título do vídeo:' \
				0 100 )
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
			linkorganizer_showMenu "Erro" "Opção desconhecida";;
		2) echo  HELP ;;
		255) echo sairE ;;
		*) utils_showErrorMessage;;
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
		#adicioanr acima para melhorar
		#--and-widget \
       	#--yesno '\nVocê aceita os Termos da Licença?' 8 30

	continuar=$?

	case "$continuar" in
		0) 
			if [ -z "$LINK" ]; then
				# exibir mensagem
				utils_showInfoMessage "Dados incompletos" "Insira o link do vídeo!"
				_getLink
			else
				# enviar link para arquivo de links
				#_sendLinkForFile $link
				# exibir mensagem de sucesso no cadastro do video
				_sucess "$titulo"
			fi
		;;
		1)	# reexibir menu principal
			linkorganizer_showMenu ;;
		2) echo  HELP ;;
		255) echo sairE ;;
		*) utils_showErrorMessage "Erro" "Opção desconhecida";;
	esac
}

# verificar se o nome do vídeo já é existe
_nameAlreadyExists(){
	echo "$@" > par
	# o arquivo possui alguns caracteres antes do nome
	# eles devem ser considerados apenas para comparar
	#grep -x "[0-9]\{0,\}\ -\ @[0-9]\{0,\}\ $@" "$NAMES_FILE" >> namesalread
	grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $@" "$NAMES_FILE" > namesalread
	#grep -x "$@" "$NAMES_FILE" >> namesalread
}

# verificar se o do vídeo já é utilizado
_videoAlreadyExists(){
	grep -x "$1" "$LINKS_FILE"
}

# funcao principal
getData_Main(){
	# importar script com menu principal
	#source link-organizer-2.0.sh

	# importar funcao do script para limpar url do youtube
	#source youtubeRegex.sh

	if [ ! -e "$NAMES_FILE" ]; then
		# criar arquivos necessarios para armazenar e gerenciar videos
		_createFiles
	fi	

	continuar=0

	# laco para adicionar videos
	while [ "$continuar" -eq "0" ]
	do
		# recuperar titulo do video
		_getTitulo
	done
}

#tail  -1 log | cut -d' ' -f4,5,6,7,10,11,12 | sed 's/\[download\]//g'
