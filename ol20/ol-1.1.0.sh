#!/bin/bash
# ol_1.0.1.sh
#
# Organizar links para download de vídeos do youtube com youtube-dl
# Obs.: os arquivos videos.nome e links.nome devem existir no diretótio atual

#
# Versão 1: organiza os links e gera o script para download
# Versão 2: adicionada verificações dos arquivos necessários
#       adicionado notify
#
# Italo Pessoa, Fevereiro de 2012 - ol_1.0.0.sh
# Italo Pessoa, Fevereiro de 2012 - ol_1.1.0.sh

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

ALERT=$(which 'notify-send'); # aplicativo para alerta

# corrigir arquivo para que os downloads sejam executados em background e possam ser
# monitorados pelo gauge
_insertBackgroundProcesses(){
    while read linha; do
        video=$(echo "$linha" | sed 's/[\\\/\\]//g' |  grep "www.youtube.com" )
        cdVideo=$(echo $video | grep -o "\=.*" | sed -e 's/=//')
        if [ ! -z "$video" ]; then
            echo $cdVideo
            #echo "$linha &"
            cdVideoBck="$cdVideo \\&"
            sed -i "s|$cdVideo|$cdVideo > \"\$DOWNLOAD_STATUS_LOG\" \\&|g"  "$SCRIPTOUT"
        fi
        
    done < "$SCRIPTOUT"
}

_createLinksFile(){
    #remover script caso ja exista, para evitar problemas
    if [ -e "$SCRIPTOUT" ]; then
        rm "$SCRIPTOUT"
    fi

    #ALERT=$(which 'notify-send'); # aplicativo para alerta
    # remover \ dos nomes
    cat "$VIDEOS" | tr '/' '-' > tmpBarra
    #passar conteudo de volta para nomes.video
    mv tmpBarra "$VIDEOS"

    #unir arquivos
    join -j1 "$VIDEOS" "$LINKS" > teste 

    # adaptação para inserir chamada de funcao wait
    # no script de download
    while read linha; do
            if [ "$linha" != "clear" ]; then
                    echo "$linha" >> file
                    echo "_showProgress" >> file
            fi
    done < teste

    #remover numeracao de linahs e numeração do vídeo
    #sed 's/.\{0,\}@/%r%/' file > abc
    #sed 's/.\{0,\}@[0-9]\{0,\} /%r%/' file > tmp
    sed  -i 's/.\{0,\}@[0-9]\{0,\} /%r%/' file

    #mudar espaços por valor aleatório expecífico
    #sed 's/ /@123/g' tmp > teste
    sed -i 's/ /@123/g' file

    #modificar valor aleatório expecífico por 'vazio'
    #sed 's/@123/\\ /g' teste > teste2
    sed -i 's/@123/\\ /g' file

    # remover '\' o final do link por vazio
    # TODO adicinaor -i em todos os sed
    #sed -i 's/\\ -f/ -f/' teste2
    sed -i 's/\\ -f/ -f/' file

    #remover '/' antes de http | www | youtube.com
    #sed 's/\\ http/ http/' teste2 > teste
    sed -i 's/\\ http/ http/' file
    sed -i 's/\\ www/ www/' file
    sed -i 's/\\ youtube.com/ youtube.com/' file

    #substituir valor aleatório controlado pelo comando
    #sed 's/%r%/youtube-dl -o /' teste2 > result
    sed -i 's/%r%/youtube-dl -o /' file

    #escrever script para download
    echo '#!/bin/bash' > "$SCRIPTOUT"
    echo '' >> "$SCRIPTOUT"
    echo '#script para fazer download dos vídeos' >> "$SCRIPTOUT"
    echo '' >> "$SCRIPTOUT"

    echo "source $DOWNLOAD_PROCESS_SCRIPT" >> "$SCRIPTOUT"
    echo "source $LINK_ORGANIZER_SCRIPT" >> "$SCRIPTOUT"
    echo "_showProgress(){" >> "$SCRIPTOUT"
    echo "  # monitorar status download" >> "$SCRIPTOUT"
    echo "  downloadProcess_Show \$!" >> "$SCRIPTOUT"
    echo "  # vericiar se o download foi conluido com interrupcao" >> "$SCRIPTOUT"
    echo "  if [ \"\$?\" != \"0\" ];then" >> "$SCRIPTOUT"
    echo "      ./setup.sh" >> "$SCRIPTOUT"
    #echo "      echo \$\$" >> "$SCRIPTOUT"
    echo "      killall \$\$" >> "$SCRIPTOUT"
    echo "  fi" >> "$SCRIPTOUT"
    echo "}" >> "$SCRIPTOUT"
    echo "" >>"$SCRIPTOUT"

    #remover ultima barra e envia para result,tratar parenteses
    #sed 's/..http/ http/ ; s/(/\\(/g ; s/)/\\)/g' result >> "$SCRIPTOUT"
    #sed 's/..http/ http/ ; s/(/\\(/g ; s/)/\\)/g' file >> "$SCRIPTOUT"
    sed 's/.http/ http/ ; s/(/\\(/g ; s/)/\\)/g' file >> "$SCRIPTOUT"
    
    _insertBackgroundProcesses
    
    #sed 's/\\ http/ http/' tmp > result # remover ultima barra e envia para result
    #echo "clear" >> "$SCRIPTOUT"
    #cat links.sh | sed 's/(/\\(/g ; s/)/\\)/g' > tmp

    #echo "echo \"------------------FIM---------------------------------\"" >> "$SCRIPTOUT"
    #echo "#GERADO POR ITALO NEY - italoneypessoa@gmail.com" >> "$SCRIPTOUT"
    rm teste tmp teste2 result file
    chmod +x "$SCRIPTOUT"
    if [ ! -z $ALERT ]; then
        $ALERT -u critical "Sucesso!" "Arquivo '$SCRIPTOUT' criado.";
        utils_showInfoMessage "Sucesso!" "\nArquivo '$SCRIPTOUT' criado.";
        #exit 0;
    else
        echo "Sucesso!\nArquivo '$SCRIPTOUT' criado.";
        #exit 0;
    fi
}

ol_Main(){
    VIDEOS="$1"
    LINKS="$2"
    SCRIPTOUT="$3"
    # verificar se os arquivos existem NOMES.VIDEO
    if [ ! -e "$VIDEOS" ]; then 
        if [ ! -z $ALERT ]; then
            #$ALERT -u critical "Erro na execução!" "Arquivo '$VIDEOS' não existe!" ;
            utils_showInfoMessage "Erro na execução!" "Arquivo '$VIDEOS' não existe!";
            #exit 1;
        else
            echo "Erro na execução!\nArquivo $VIDEOS não existe!";
            #exit 1;
        fi
        # verificar se os arquivos existem LINKS.VIDEO
        elif [ ! -e "$LINKS" ]; then 
            if [ ! -z $ALERT ]; then
            #$ALERT -u critical "Erro na execução!" "Arquivo '$LINKS' não existe!" ;
            utils_showErrorMessage "Erro na execução!" "Arquivo '$LINKS' não existe!";
            #exit 1;
        else
            echo "Erro na execução!\nArquivo $LINKS não existe!" ;
            #exit 1;
        fi
    fi

    _createLinksFile
}

#exit 0;