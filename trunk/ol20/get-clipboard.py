import pygtk
pygtk.require('2.0')
import gtk

# get the clipboard
clipboard = gtk.clipboard_get()

# read the clipboard text data. you can also read image and
# rich text clipboard data with the
# wait_for_image and wait_for_rich_text methods.
text = clipboard.wait_for_text()
print text

# set the clipboard text data
#clipboard.set_text('Hello!')

# make our data available to other applications
#clipboard.store()
