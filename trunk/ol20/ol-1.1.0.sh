#!/bin/bash
# ol_1.0.1.sh
#
# Organizar links para download de vídeos do youtube com youtube-dl
# Obs.: os arquivos videos.nome e links.nome devem existir no diretótio atual

#
# Versão 1: organiza os links e gera o script para download
# Versão 2: adicionada verificações dos arquivos necessários
#	adicionado notify
#
# Italo Pessoa, Fevereiro de 2012 - ol_1.0.0.sh
# Italo Pessoa, Fevereiro de 2012 - ol_1.1.0.sh

ALERT=$(which 'notify-send'); # aplicativo para alerta

ol_createLinksFile(){
	
	#ALERT=$(which 'notify-send'); # aplicativo para alerta
	# remover \ dos nomes
	cat nomes.video | tr '/' '-' > tmpBarra
	#passar conteudo de volta para nomes.video
	mv tmpBarra nomes.video

	#unir arquivos
	join -j1 nomes.video links.video > teste 

	#remover numeracao
	sed 's/.\{0,\}@/%r%/' teste > tmp

	#mudar espaços por valor aleatório expecífico
	sed 's/ /@123/g' tmp > teste

	#modificar valor aleatório expecífico por 'vazio'
	sed 's/@123/\\ /g' teste > teste2

	#remover '/' antes de http
	sed 's/\\ http/ http/' teste2 > teste

	#substituir valor aleatório controladp pelo comando
	sed 's/%r%/youtube-dl -o /' teste2 > result

	#escrever script para download
	echo '#!/bin/sh' > links.sh
	echo '' >> links.sh
	echo '#script para fazer download dos vídeos' >> links.sh
	echo '' >> links.sh

	#remover ultima barra e envia para result,tratar parenteses
	sed 's/..http/ http/ ; s/(/\\(/g ; s/)/\\)/g' result >> links.sh

	#sed 's/\\ http/ http/' tmp > result # remover ultima barra e envia para result
	echo "clear" >> links.sh
	#cat links.sh | sed 's/(/\\(/g ; s/)/\\)/g' > tmp

	echo "echo \"------------------FIM---------------------------------\"" >>links.sh
	echo "#GERADO POR ITALO NEY - italoneypessoa@gmail.com" >> links.sh
	rm teste tmp teste2 result
	chmod +x links.sh

	if [ ! -z $ALERT ]; then
		$ALERT -u critical "Sucesso!" "Arquivo 'links.sh' criado.";
		exit 0;
	else
		echo "Sucesso!\nArquivo 'links.sh' criado.";
		exit 0;
	fi
}

# verificar se os arquivos existem NOMES.VIDEO
if [ ! -e 'nomes.video' ]; then 

	if [ ! -z $ALERT ]; then
		$ALERT -u critical "Erro na execução!" "Arquivo 'nomes.video' não existe!" ;
		exit 1;
	else
		echo "Erro na execução!\nArquivo nomes.video não existe!" ;
		exit 1;
	fi
# verificar se os arquivos existem LINKS.VIDEO
elif [ ! -e 'links.video' ]; then 
	if [ ! -z $ALERT ]; then
		$ALERT -u critical "Erro na execução!" "Arquivo 'links.video' não existe!" ;
		exit 1;
	else
		echo "Erro na execução!\nArquivo links.video não existe!" ;
		exit 1;
	fi
fi

#exit 0;
