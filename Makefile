all:
	cd blog && jekyll build
	rm -fr www
	mkdir www
	cp index.html www
	cp -r blog/_site www/blog
	
.PHONY: all

