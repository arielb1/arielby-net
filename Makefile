all:
	git submodule update --init --recursive
	cat /etc/*release
	which hugo
	:
	
.PHONY: all

