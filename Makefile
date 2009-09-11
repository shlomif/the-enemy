FILES = The-Enemy-Hebrew.xhtml The-Enemy-English.xhtml 

all:

upload:
	rsync -v --progress -a $(FILES) $${HOMEPAGE_SSH_PATH}/the-enemy-prantemp/
	
