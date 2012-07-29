#!/bin/bash
# exibir opções de formato de video
# "Italo Pessoa" <italoneypessoa@gmail.com>
youTubeFile=$(tempfile)
wget -O "$youTubeFile" -o $(tempfile) "$1"

dialog \
        --title "aaaaaaaaaaaaa" \
        --backtitle "$BACK_TITLE" \
        --sleep "5" \
        --infobox "6666666666666666"  \
        10 40

fmtList=("1080" "720" "480" "360" "240")
STRING="<meta property=\"og:video:height"
fmt=$(grep "$STRING" "$youTubeFile" | sed 's/.*="// ;s/">//')
for key in ${!fmtList[*]}; do
	#echo "${fmtList[$key]}"
	if [ "$fmt" -lt "${fmtList[$key]}" ]; then
		#echo "${fmtList[$key]}"
		unset fmtList[$key]
	fi
done


#op=("Lista 'Vídeos Selecionados'  on " " Lista 'Vídeos Selecionados'  off" )
tmpFmtList=$(tempfile)
test -e "$tmpFmtList" && rm "$tmpFmtList"

for key in ${!fmtList[*]}; do
	echo "${fmtList[$key]} ${fmtList[$key]}p off" >> "$tmpFmtList"
done



fmtValue=$(dialog  --stdout \
	--title 'Selecione' \
	--radiolist 'Quais vídeos deseja baixar?'  \
	0 0 0  \
	$(cat "$tmpFmtList")) 
#echo "$fmt"

#TODO criar variavel para armazenar valor do arquivo utilizado
case "$fmtValue" in
	"1080")
		#echo "escolheu 1080 = 37(.mp4)"
		echo "37:.mp4" >format
	;;
	"720")
		#echo "escolheu 720 = 22(.mp4)"
		echo "22:.mp4" >format
	;;
	"480")
		#echo "escolheu 480 = 18(.mp4)"
		echo "18:.mp4" >format
	;;
	"360")
		#echo "escolheu 360 = 34(.flv)"
		echo "34:.flv" >format
	;;
	"240")
		#echo "escolheu 240 = 5(.flv)"
		echo "5:.flv" >format 
	;;
esac