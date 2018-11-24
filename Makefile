
serve:
	jekyll serve --watch --trace --drafts

draft:
	git add _posts files && git commit -m "post" && git push staging master

post:
	git fetch origin
	git fetch staging
	git push origin staging/master:master
