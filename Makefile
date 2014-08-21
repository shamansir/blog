ROOT_DIR=`pwd`
DEF_LANG=en
SEC_LANG=ru
TRG_DIR=.site
# SRC_DIR=.cache

build:
	cd $(ROOT_DIR)
	rm -Rf ./$(TRG_DIR)
	mkdir -p ./$(TRG_DIR)
	mkdir ./$(TRG_DIR)/_site
	mkdir ./$(TRG_DIR)/_site/$(SEC_LANG)
	mkdir ./$(TRG_DIR)/_subsites
	mkdir ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	cp -R ./$(DEF_LANG)/* ./$(TRG_DIR)
	cp -R ./shared/* ./$(TRG_DIR)
	cp -R ./$(SEC_LANG)/* ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	cp -R ./shared/* ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	mynt gen -f --locale=$(DEF_LANG) --base-url=/ ./$(TRG_DIR) ./$(TRG_DIR)/_site
	mynt gen -f --locale=$(SEC_LANG) --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/_subsites/$(SEC_LANG) ./$(TRG_DIR)/_site/$(SEC_LANG)
	# compass watch --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/_site/assets/css/ &
	# compass watch --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/_site/$(SEC_LANG)/assets/css/ &

serve:
	mynt serve --base-url=/ ./$(TRG_DIR)/_site

watch:
	mynt watch --base-url=/ ./$(TRG_DIR)/_site

deploy:
	cd $(ROOT_DIR)
	rm -Rf ./$(TRG_DIR)
	mkdir -p ./$(TRG_DIR)
	mkdir ./$(TRG_DIR)/_site
	mkdir ./$(TRG_DIR)/_site/$(SEC_LANG)
	mkdir ./$(TRG_DIR)/_subsites
	mkdir ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	cp -R ./$(DEF_LANG)/* ./$(TRG_DIR)
	cp -R ./shared/* ./$(TRG_DIR)
	cp -R ./$(SEC_LANG)/* ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	cp -R ./shared/* ./$(TRG_DIR)/_subsites/$(SEC_LANG)
	mynt gen -f ./$(TRG_DIR) ./$(TRG_DIR)/_site
	mynt gen -f ./$(TRG_DIR)/_subsites/$(SEC_LANG) ./$(TRG_DIR)/_site/$(SEC_LANG)
	compass compile --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/_site/assets/css/
	compass compile --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/_site/$(SEC_LANG)/assets/css/
	CUR_BRANCH=$(git symbolic-ref -q HEAD)
	CUR_BRANCH=${CUR_BRANCH##refs/heads/}
	CUR_BRANCH=${CUR_BRANCH:-HEAD}
	echo "moving away from branch $CUR_BRANCH"
	echo "..."
	sleep 3
	#git stash
	git checkout gh-pages
	rm -Rf ./*
	cp -R ./$(TRG_DIR)/_site/* .
	git add -A
	git status
	echo "..."
	sleep 6
	git commit -m "update from $(date)"
	echo "..."
	sleep 6
	git push origin gh-pages
	git checkout $CUR_BRANCH
	#git stash apply
