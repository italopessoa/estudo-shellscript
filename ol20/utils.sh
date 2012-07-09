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
utils_youtubeRegex(){
	echo "$@" | sed 's/?.*[^v]v=/?v=/g; s/&.*//g'
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
		sed -i "s|$cdVideo|$cdVideo \\&|g"  "links.sh"
	fi	
done < links.sh
}

# funcao para verificar se download ainda esta ocorrendo
utils_running(){
    # $1 é o PID do processo
    ps $1 | grep $1 >/dev/null;
}