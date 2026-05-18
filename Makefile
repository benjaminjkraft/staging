
serve:
	jekyll serve --watch --trace --drafts

post:
	-git add _posts files
	-git commit -m "post"

staging:
	git cherry-pick 87709b0
	git push -f staging master
	git reset --hard HEAD^
