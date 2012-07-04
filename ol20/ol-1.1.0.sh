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

ol_createLinksFile(){
        
    #ALERT=$(which 'notify-send'); # aplicativo para alerta
    # remover \ dos nomes
    cat "$NAMES_FILE" | tr '/' '-' > tmpBarra
    #passar conteudo de volta para nomes.video
    mv tmpBarra "$NAMES_FILE"

    #unir arquivos
    join -j1 "$NAMES_FILE" "$LINKS_FILE" > teste 

    #remover numeracao
    sed 's/.\{0,\}@/%r%/' teste > tmp

    #mudar espaços por valor aleatório expecífico
    sed 's/ /@123/g' tmp > teste

    #modificar valor aleatório expecífico por 'vazio'
    sed 's/@123/\\ /g' teste > teste2

    #remover '/' antes de http
    sed 's/\\ http/ http/' teste2 > teste

    #substituir valor aleatório controlado pelo comando
    sed 's/%r%/youtube-dl -o /' teste2 > result

    #escrever script para download
    echo '#!/bin/sh' > "$VIDEO_SCRIPT_FILE"
    echo '' >> "$VIDEO_SCRIPT_FILE"
    echo '#script para fazer download dos vídeos' >> "$VIDEO_SCRIPT_FILE"
    echo '' >> "$VIDEO_SCRIPT_FILE"

    #remover ultima barra e envia para result,tratar parenteses
    sed 's/..http/ http/ ; s/(/\\(/g ; s/)/\\)/g' result >> "$VIDEO_SCRIPT_FILE"

    #sed 's/\\ http/ http/' tmp > result # remover ultima barra e envia para result
    echo "clear" >> "$VIDEO_SCRIPT_FILE"
    #cat links.sh | sed 's/(/\\(/g ; s/)/\\)/g' > tmp

    echo "echo \"------------------FIM---------------------------------\"" >> "$VIDEO_SCRIPT_FILE"
    echo "#GERADO POR ITALO NEY - italoneypessoa@gmail.com" >> "$VIDEO_SCRIPT_FILE"
    rm teste tmp teste2 result
    chmod +x "$VIDEO_SCRIPT_FILE"

    if [ ! -z $ALERT ]; then
        #$ALERT -u critical "Sucesso!" "Arquivo '$VIDEO_SCRIPT_FILE' criado.";
        message_showInfo "Sucesso!" "\nArquivo '$VIDEO_SCRIPT_FILE' criado.";
        exit 0;
    else
        echo "Sucesso!\nArquivo '$VIDEO_SCRIPT_FILE' criado.";
        exit 0;
    fi
}

# verificar se os arquivos existem NOMES.VIDEO
if [ ! -e "$NAMES_FILE" ]; then 

    if [ ! -z $ALERT ]; then
        #$ALERT -u critical "Erro na execução!" "Arquivo '$NAMES_FILE' não existe!" ;
        message_showError "Erro na execução!" "Arquivo '$NAMES_FILE' não existe!";
        exit 1;
    else
        echo "Erro na execução!\nArquivo $NAMES_FILE não existe!" ;
        exit 1;
    fi
    # verificar se os arquivos existem LINKS.VIDEO
    elif [ ! -e "$LINKS_FILE" ]; then 
        if [ ! -z $ALERT ]; then
        #$ALERT -u critical "Erro na execução!" "Arquivo '$LINKS_FILE' não existe!" ;
        message_showError "Erro na execução!" "Arquivo '$LINKS_FILE' não existe!";
        exit 1;
    else
        echo "Erro na execução!\nArquivo $LINKS_FILE não existe!" ;
        exit 1;
    fi
fi

#exit 0;
