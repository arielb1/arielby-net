nothing:
	which jekyll || true
	true # give up and build locally -

all:
	which jekyll || true
	gem install bundler jekyll
	cd blog && bundle exec jekyll build
	rm -fr www
	mkdir www
	cp index.html www
	cp -r blog/_site www/blog
	
.PHONY: all

