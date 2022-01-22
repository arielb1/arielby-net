all:
	rbenv install 2.7.2
	gem install bundler jekyll
	cd blog && bundle exec jekyll build
	rm -fr www
	mkdir www
	cp index.html www
	cp -r blog/_site www/blog
	
.PHONY: all

