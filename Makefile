all:
	cd blog && jekyll build
	rm -fr www/blog
	cp -r blog/_site www/blog
	
.PHONY: all

