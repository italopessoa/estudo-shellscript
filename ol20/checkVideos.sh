#!/bin/bash
# checkVideos
# script para selecionar videos(que ainda não foram baixados) para download
# Italo Pessoa - italoneypessoa@gmail.com

checkVideos_main(){
	# recuperar valores selecionados
  valores=$( eval \ dialog --stdout --separate-output \
    --title \"Vídeos cadastrados\" \
    --checklist \"Selecione o vídeos para download\" \
    0 0 0 $(cat $DOWNLOADED_FILE) 
  )

  echo "$valores" | while read linha; do
  numberLine=$( grep "$linha$" nomes.video | cut -d' ' -f1 )
  #sed -n "$numberLine"p nomes.video
  echo $linha

  done
}
