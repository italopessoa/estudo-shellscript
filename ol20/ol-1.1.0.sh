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
            sed -i "s|$cdVideo|$cdVideo > \"\$DOWNLOAD_STATUS_LOG\" \\&|g"  "$VIDEO_SCRIPT"
        fi
        
    done < "$VIDEO_SCRIPT"
}

ol_createLinksFile(){
    
    #remover script caso ja exista, para evitar problemas
    if [ -e "$VIDEO_SCRIPT" ]; then
        rm "$VIDEO_SCRIPT"
    fi

    #ALERT=$(which 'notify-send'); # aplicativo para alerta
    # remover \ dos nomes
    cat "$NAMES_FILE" | tr '/' '-' > tmpBarra
    #passar conteudo de volta para nomes.video
    mv tmpBarra "$NAMES_FILE"

    #unir arquivos
    join -j1 "$NAMES_FILE" "$LINKS_FILE" > teste 

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
    sed 's/.\{0,\}@[0-9]\{0,\} /%r%/' file > tmp

    #mudar espaços por valor aleatório expecífico
    sed 's/ /@123/g' tmp > teste

    #modificar valor aleatório expecífico por 'vazio'
    sed 's/@123/\\ /g' teste > teste2

    #remover '/' antes de http
    sed 's/\\ http/ http/' teste2 > teste

    #substituir valor aleatório controlado pelo comando
    sed 's/%r%/youtube-dl -o /' teste2 > result

    #escrever script para download
    echo '#!/bin/bash' > "$VIDEO_SCRIPT"
    echo '' >> "$VIDEO_SCRIPT"
    echo '#script para fazer download dos vídeos' >> "$VIDEO_SCRIPT"
    echo '' >> "$VIDEO_SCRIPT"

    echo "source $DOWNLOAD_PROCESS_SCRIPT" >> "$VIDEO_SCRIPT"
    echo "_showProgress(){" >> "$VIDEO_SCRIPT"
    echo "  # monitorar status download" >> "$VIDEO_SCRIPT"
    echo "  downloadProcess_Show \$!" >> "$VIDEO_SCRIPT"
    echo "  # vericiar se o download foi conluido com interrupcao" >> "$VIDEO_SCRIPT"
    echo "  if [ \"\$?\" != \"0\" ];then" >> "$VIDEO_SCRIPT"
    echo "      ./setup.sh" >> "$VIDEO_SCRIPT"
    #echo "      echo \$\$" >> "$VIDEO_SCRIPT"
    echo "      killall \$\$" >> "$VIDEO_SCRIPT"
    echo "  fi" >> "$VIDEO_SCRIPT"
    echo "}" >> "$VIDEO_SCRIPT"
    echo "" >>"$VIDEO_SCRIPT"

    #remover ultima barra e envia para result,tratar parenteses
    sed 's/..http/ http/ ; s/(/\\(/g ; s/)/\\)/g' result >> "$VIDEO_SCRIPT"
    _insertBackgroundProcesses
    #sed 's/\\ http/ http/' tmp > result # remover ultima barra e envia para result
    #echo "clear" >> "$VIDEO_SCRIPT"
    #cat links.sh | sed 's/(/\\(/g ; s/)/\\)/g' > tmp

    #echo "echo \"------------------FIM---------------------------------\"" >> "$VIDEO_SCRIPT"
    #echo "#GERADO POR ITALO NEY - italoneypessoa@gmail.com" >> "$VIDEO_SCRIPT"
    rm teste tmp teste2 result file
    chmod +x "$VIDEO_SCRIPT"

    if [ ! -z $ALERT ]; then
        $ALERT -u critical "Sucesso!" "Arquivo '$VIDEO_SCRIPT' criado.";
        utils_showInfoMessage "Sucesso!" "\nArquivo '$VIDEO_SCRIPT' criado.";
        exit 0;
    else
        echo "Sucesso!\nArquivo '$VIDEO_SCRIPT' criado.";
        exit 0;
    fi
}

# verificar se os arquivos existem NOMES.VIDEO
if [ ! -e "$NAMES_FILE" ]; then 

    if [ ! -z $ALERT ]; then
        #$ALERT -u critical "Erro na execução!" "Arquivo '$NAMES_FILE' não existe!" ;
        utils_showInfoMessage "Erro na execução!" "Arquivo '$NAMES_FILE' não existe!";
        exit 1;
    else
        echo "Erro na execução!\nArquivo $NAMES_FILE não existe!" ;
        exit 1;
    fi
    # verificar se os arquivos existem LINKS.VIDEO
    elif [ ! -e "$LINKS_FILE" ]; then 
        if [ ! -z $ALERT ]; then
        #$ALERT -u critical "Erro na execução!" "Arquivo '$LINKS_FILE' não existe!" ;
        utils_showErrorMessage "Erro na execução!" "Arquivo '$LINKS_FILE' não existe!";
        exit 1;
    else
        echo "Erro na execução!\nArquivo $LINKS_FILE não existe!" ;
        exit 1;
    fi
fi

#exit 0;
