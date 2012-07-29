#!/bin/bash
# utils.sh
# script que contém funcinalidades diversas para utilizar
# no orgganizador de links
# 8 de julho de 2012
# "Italo Pessoa"<italoneypessoa@gmail.com>

# exibir informacao
utils_showInfoMessage(){
    dialog \
        --title "$1" \
        --backtitle "$BACK_TITLE" \
        --sleep "3" \
        --infobox "$2"  \
        10 40
}

# exibir mensagem de erro
utils_showErrorMessage(){
    dialog \
        --title "$1" \
        --backtitle "$BACK_TITLE" \
        --msgbox "$2"  \
        0 0
}

# script simples para remover dados desnecessários da
# url dos vídeos do youtube
#corrigido para nao remover o formato do video
utils_youtubeRegex(){
	#echo "$@" | sed 's/?.*[^v]v=/?v=/g; s/&.*[^ -f[0-9]\{1,2\}]//g'
    echo "$@" | sed 's/?.*[^v]v=/?v=/g; s/&.*[^ -f]//g'
}

# função para corrigir script de donwnload
# e por os downloads em background, para que se possa verificar o status do processo
utils_putOnBackground(){
    while read linha; do
    	# verificar se linha possui vídeo
    	video=$(echo "$linha" | sed 's/[\\\/\\]//g' |  grep "www.youtube.com" )
    	# recuperar codigo do video
    	cdVideo=$(echo $video | grep -o "\=.*" | sed -e 's/=//')
    	if [ ! -z "$video" ]; then
    		echo $cdVideo
    		#echo "$linha &"
    		cdVideoBck="$cdVideo \\&"
    		# adicionar simbolo de background no processo do video
    		sed -i "s|$cdVideo|$cdVideo \\&|g"  "$LINKS_VIDEO_DOWNLOAD"
    	fi	
    done < links.sh
}

# funcao para verificar se download ainda esta ocorrendo
utils_running(){
    # $1 é o PID do processo
    ps $1 | grep $1 >/dev/null;
}

# verificar se o nome do vídeo já é existe
utils_nameAlreadyExists(){
    # $1 valor a ser procurado
    # $2 arquivo onde deve ser procurado
    #echo "$@" > par
    # o arquivo possui alguns caracteres antes do nome
    # eles devem ser considerados apenas para comparar
    #grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $1" "$2" > /dev/null
    #solucao mais simples
    grep -x "$1" "$2" > /dev/null
}

# verificar se o do vídeo já é utilizado
utils_videoAlreadyExists(){
    # $1 valor a ser procurado
    # $2 arquivo onde deve ser procurado
    L=$(utils_youtubeRegex "$1")
    grep -x "[1-9]\{0,\} *$1" "$2" > /dev/null
}

# verificar se realmente é um link do youTube
utils_isUTubeLink(){
    # $1 valor a ser procurado
    # $2 arquivo onde deve ser procurado
    if [ -n "$1" ]; then
        L=$(utils_youtubeRegex "$1")
        echo "$L" > aaa
        echo "$L" | grep -x ".*.youtube.com/watch?v=.*" > assd
    fi
}