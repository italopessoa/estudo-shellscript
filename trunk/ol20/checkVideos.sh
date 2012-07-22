#!/bin/bash
# checkVideos
# script para selecionar videos(que ainda não foram baixados) para download
# Italo Pessoa - italoneypessoa@gmail.com

checkVideos_Main(){
	# recuperar valores selecionados
    items=$( eval \ dialog --stdout --separate-output \
        --title \"Vídeos cadastrados\" \
        --checklist \"Selecione o vídeos para download\" \
        0 0 0 $(cat $AVAILABLE_VIDEO) 
    )
    
    # se selecionar cancelar, retornar para tela inicial
    if [ -n "$items" ]; then
        echo "$items" | while read item; do
            #numberLine=$( grep "$item" nomes.video | cut -d' ' -f1 )
            #sed -n "$numberLine"p nomes.video
            #echo $item >> "$SELECTED_VIDEOS"

            # verificar se algum video ja foi selecionado
            if [ -e "$SELECTED_VIDEOS" ]; then
                # caso tenha sido, verificar se não é o mesmo
                if [ "$(utils_nameAlreadyExists "$item" "$SELECTED_VIDEOS")" = "" ]; then
                    # caso nao seja, adicionar normalmente
                    echo $item >> "$SELECTED_VIDEOS"
                    _addVideo2List
                fi
            else
                # caso nao tenha, adicionar normalmente
                echo $item >> "$SELECTED_VIDEOS"
                _addVideo2List
            fi
        done
    fi
    # retornar para menu inicial
    linkorganizer_showMenu
}

#funcao para unifica o processo de bbuscar e adicionar o video à lista personlaizada
_addVideo2List(){
    # variavel que armazenara a linha atual que comeca na linha 1 claro
    nl=1
    while read LINHA; do
        # video é a linha do arquivo com o nome do video
        video=$(echo "$LINHA" | grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $item")
        if [ "$video" ]; then
            # se o valor nao for nulo significa que a liha foi encontrada
            # e ja pode ser interrompido
            break;
        else
            # senão a linha deve ser incrementada
            nl=$(( nl +1 ))
        fi
    done < nomes.video

    # link correspondente ao video, recuperado a partir da variave $nl
    # que guarda a linha atual do arquivo, os quais devem estar sincronizados
    # em relação a disposição dos dados dos videos(nome e link)
    link=$(sed -n "$nl"p $LINKS_FILE)

    # guardar valores nos arquivos correspondentes a lista de videos para download
    # caso não exista ainda na lista de video selecionados
    echo "$video" >> "$NAMES_LIST"
    echo "$link" >> "$LINKS_LIST"

    # gerar script para download de videos selecionados
    ol_Main "$NAMES_LIST" "$LINKS_LIST" "$LIST_SCRIPT"
}