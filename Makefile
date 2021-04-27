#!/usr/bin/make -f
#
# Converts a CVS repository to Git.
# Requires cvs-fast-export <http://www.catb.org/~esr/cvs-fast-export/>.
#

CVS_REPOSITORY ?= amficom.cvs
GIT_REPOSITORY ?= amficom.git
GIT_ORIGIN ?= git@github.com:syrus-ru/amficom.git
DESCRIPTION ?= AMFICOM Optic

AUTHORMAP = authormap
REMOTE = origin

.PHONY: help
help: ## Display this help text
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: convert
convert: $(GIT_REPOSITORY) ## Convert CVS repository to Git

.PHONY: push
push: $(GIT_REPOSITORY) ## Push the converted repository to the specified remote
# Ignore if remote already exists.
	cd "$(GIT_REPOSITORY)"
	-git remote add "$(REMOTE)" "$(GIT_ORIGIN)"
	git push --force "$(REMOTE)" --all
	git push --force "$(REMOTE)" --tags

$(GIT_REPOSITORY): $(AUTHORMAP) $(CVS_REPOSITORY)
	git init --bare "$(GIT_REPOSITORY)"
	find -H "$(CVS_REPOSITORY)" -name '*,v' | cvs-fast-export -A $< -k kv -P | (cd "$(GIT_REPOSITORY)" && git fast-import)
	echo "$(DESCRIPTION)" > "$(GIT_REPOSITORY)/description"

.ONESHELL:
$(AUTHORMAP):
	@cat <<- EOF | sed -e 's/\s\+at\s\+/@/g' -e 's/\s\+dot\s\+/./g' >$@
	arseniy=Arseniy Tashoyan <tashoyan at gmail dot com> Europe/Moscow
	bass=Andrey \`\`Bass'' Shcheglov <andrewbass at gmail dot com> Europe/Moscow
	bob=Vladimir Dolzhenko <vladimir.dolzhenko at gmail dot com> Europe/Moscow
	cvsadmin=cvsadmin <cvsadmin at science dot syrus dot ru> Europe/Moscow
	krupenn=Andrey Kroupennikov <andrei.kroupennikov at gmail dot com> Europe/Moscow
	max=Maxim Selivanov <max.selivanov at gmail dot com> Europe/Moscow
	peskovsky=Peter Peskovsky <peskovsky at gmail dot com> Europe/Moscow
	root=root <root at science dot syrus dot ru> Europe/Moscow
	saa=Alexey Stratonnikov <alexsaa at gmail dot com> Europe/Moscow
	stas=Stanislav Kholshin <kholshin at gmail dot com> Europe/Moscow
	vit=Vitaliy Shiryaev <miptsu at gmail dot com> Europe/Moscow
	EOF

.PHONY: clean
clean: ## Delete the generated files (incl. Git repository)
	$(RM) -r "$(GIT_REPOSITORY)" "$(AUTHORMAP)"
