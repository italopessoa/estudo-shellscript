#!/usr/bin/python
# /usr/lib/lo/get-clipboard.py

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Link Organizer is a simple software to organize links.                    #
#                                                                           #
# Copyright (C) 2012  Italo Pessoa<italoneypessoa@gmail.com>                #
# This file is part of the program Link Organizer.                          #
#                                                                           #
# Link Organizer is a free software: you can redistribute it and/or modify  #
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

import pygtk
pygtk.require('2.0')
import gtk

# get the clipboard
clipboard = gtk.clipboard_get()

# read the clipboard text data
text = clipboard.wait_for_text()
print text