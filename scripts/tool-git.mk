# Git
git-push: ## push to both gitlab and github
	$(PREFIX_CMD) git push github ${GIT_BRANCH}
	$(PREFIX_CMD) git push gitlab ${GIT_BRANCH}