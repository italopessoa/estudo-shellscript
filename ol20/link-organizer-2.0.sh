#!/bin/bash
# link-organizer-2.0
# interface aprimorada para utilização do script
# ol-1.1.0, para organizacao dos videos para download
# Italo Pessoa - italoneypessoa@gmail.com

# exibir videos adicionados na lista

_showVideos(){

# verificar se o arquivo existe e se contem algum video
if [ -s "videos" ];then
	dialog \
		--title 'Lista de vídeos' \
		--backtitle "$BACK_TITLE" \
		--textbox "videos" \
		20 70

else
	# exibir mensagem informando que nao existe nenhum video na lista
	dialog \
		--title 'Atenção' \
		--backtitle "$BACK_TITLE" \
		--sleep "2" \
		--infobox "Não existem vídeos na lista."  \
		3 40

fi

}

# criar script para download dos videos
_createGeralLinksFile(){
	# importar script original de criação do script para
	# organizcao dos links
	source ol-1.1.0.sh
	ol_createLinksFile
}

#exibir menu principal
linkorganizer_showMenu(){
	# importar script para obetnção das informacoes dos videos
	source get-data.sh
	source checkVideos.sh

	# items do menu pricipal
	menuItems=(
		"Adicionar Adicionar\\ novo\\(s\\)\\ vídeo\\(s\\)"
		"Vídeos Vídeos\\ Disponíveis"
		"Gerar Gerar\\ script\\ para\\ download"
		"Selecionar Selecionar\\ vídeos\\ para\\ download"
		"Lista Vídeos\\ selecionados\\ para\\ download"
		)

	# remover ultimo item do menu
	# unset menus[4] 


	# armazenar item escolhido
	res=$( eval \ dialog --stdout \
           --title \"Vídeos cadastrados\" \
           --backtitle \"$BACK_TITLE\" \
           --menu \"Selecione o vídeos para download\"  \
           0 0 0 ${menuItems[@]} )

	case "$res" in
		"Adicionar" )
			# adicionar um novo video
			getData_main
			;;
		"Vídeos" )
			# exibir videos adicioandos a lista
			_showVideos
			;;
		"Gerar" )
			#source ol-1.1.0.sh
			_createGeralLinksFile
			;;
		"Selecionar" )
			# selecionar videos para download
			checkVideos_main
			;;
	esac
}
