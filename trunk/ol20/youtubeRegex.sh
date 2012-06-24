youtubeRegex(){
	echo "$@" | sed 's/?.*[^v]v=/?v=/g; s/&.*//g'
}
