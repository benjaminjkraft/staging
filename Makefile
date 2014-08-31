
serve:
	jekyll serve --watch --trace

post:
	git add _posts && git commit -m "post" && git push origin master
