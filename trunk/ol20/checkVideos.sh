#!/bin/bash
# checkVideos
# script para selecionar videos(que ainda não foram baixados) para download
# Italo Pessoa - italoneypessoa@gmail.com

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LinkOrganizer is a simple software to organize links.                     #
#                                                                           #
# Copyright (C) 2010  Italo Pessoa<italoneypessoa@gmail.com>                #
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
                value=$(echo "$item" | sed 's/.mp4\|.flv//')
                utils_nameAlreadyExists "$value" "$SELECTED_VIDEOS"
                #echo $? > macumba
                if [ $? -eq 1 ]; then
                    # caso nao seja, adicionar normalmente
                    echo "$item" >> "$SELECTED_VIDEOS"
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
        # video=$(echo "$LINHA" | grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $item")
        # remover aplicar regex para substituir [ e ] por \[ \], pois impossibilita a captura do video com regex
        video=$(echo "$LINHA" | grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $(echo "$item" | sed 's/\[/\\\[/; s/\]/\\\]/')")
        echo "$LINHA" >> macumba
        echo "$item" >> macumba
        # echo "$video" >> macumba  
        # echo "$LINHA" | grep -x "[0-9]\{0,\} - @[0-9]\{0,\} $item" >> macumba
        if [ "$video" ]; then
            # se o valor nao for nulo significa que a liha foi encontrada
            # e ja pode ser interrompido

            # link correspondente ao video, recuperado a partir da variave $nl
            # que guarda a linha atual do arquivo, os quais devem estar sincronizados
            # em relação a disposição dos dados dos videos(nome e link)
            link=$(sed -n "$nl"p $LINKS_FILE)

            # guardar valores nos arquivos correspondentes a lista de videos para download
            # caso não exista ainda na lista de video selecionados
            # echo "$video" > "$macumba"
            # echo "$link" >> "macumba"
            echo "$video" >> "$NAMES_LIST"
            echo "$link" >> "$LINKS_LIST"

            # gerar script para download de videos selecionados
            ol_Main "$NAMES_LIST" "$LINKS_LIST" "$LIST_SCRIPT"

            break;
        else
            # senão a linha deve ser incrementada
            nl=$(( nl +1 ))
        fi
    done < nomes.video

}