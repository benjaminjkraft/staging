
serve:
	jekyll serve --watch --trace --drafts

staging:
	git add _posts files
	git commit -m "post"
	git cherry-pick 87709b0
	git push -f staging master
	git reset --hard HEAD^
