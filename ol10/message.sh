#!/bin/bash
# message
# script para centralizar mensagens de alerta e erro
# "Italo Pessoa"<italoneypessoa@gmail.com>
# 3 de julho de 2012

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
