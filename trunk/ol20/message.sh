#!/bin/bash
# message
# script para centralizar mensagens de alerta e erro
# "Italo Pessoa"<italoneypessoa@gmail.com>
# 3 de julho de 2012

# exibir informacao
message_showInfo(){
	dialog \
		--title "$1" \
		--backtitle "$BACK_TITLE" \
		--sleep "3" \
		--infobox "$2"  \
		10 40
}

# exibir mensagem de erro
message_showError(){
	dialog \
		--title "$1" \
		--backtitle "$BACK_TITLE" \
		--msgbox "$2"  \
		0 0
}
