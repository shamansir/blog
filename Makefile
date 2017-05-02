ROOT_DIR=`pwd`

DEF_LANG=en
SEC_LANG=ru
DEF_LANG_LOCALE=en_EN.UTF-8
SEC_LANG_LOCALE=ru_RU.UTF-8

TRG_DIR=.site
SRC_DIR=.cache

all: build-local

build-local:
	cd $(ROOT_DIR)

	rm -Rf ./$(SRC_DIR)
	rm -Rf ./$(TRG_DIR)

	mkdir ./$(SRC_DIR)
	mkdir ./$(SRC_DIR)/$(DEF_LANG)
	mkdir ./$(SRC_DIR)/$(SEC_LANG)

	mkdir ./$(TRG_DIR)
	mkdir ./$(TRG_DIR)/$(SEC_LANG)

	cp -R ./$(DEF_LANG)/* ./$(SRC_DIR)/$(DEF_LANG)
	cp -R ./shared/* ./$(SRC_DIR)/$(DEF_LANG)

	cp -R ./$(SEC_LANG)/* ./$(SRC_DIR)/$(SEC_LANG)
	cp -R ./shared/* ./$(SRC_DIR)/$(SEC_LANG)

	mynt gen -f --base-url=/ ./$(SRC_DIR)/$(DEF_LANG) ./$(TRG_DIR)
	mynt gen -f --locale=$(SEC_LANG_LOCALE) --base-url=/$(SEC_LANG)/ ./$(SRC_DIR)/$(SEC_LANG) ./$(TRG_DIR)/$(SEC_LANG)

	sass ./shared/_assets/css/_sass/print.sass ./$(TRG_DIR)/assets/css/print.css
	sass ./shared/_assets/css/_sass/screen.sass ./$(TRG_DIR)/assets/css/screen.css
	sass ./shared/_assets/css/_sass/pygments.trac.sass ./$(TRG_DIR)/assets/css/pygments.trac.css

	sass ./shared/_assets/css/_sass/print.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/print.css
	sass ./shared/_assets/css/_sass/screen.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/screen.css
	sass ./shared/_assets/css/_sass/pygments.trac.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/pygments.trac.css

	ln -sf ../.fonts/ ./$(TRG_DIR)/.fonts

build-prod:
	cd $(ROOT_DIR)

	rm -Rf ./$(SRC_DIR)
	rm -Rf ./$(TRG_DIR)

	mkdir ./$(SRC_DIR)
	mkdir ./$(SRC_DIR)/$(DEF_LANG)
	mkdir ./$(SRC_DIR)/$(SEC_LANG)

	mkdir ./$(TRG_DIR)
	mkdir ./$(TRG_DIR)/$(SEC_LANG)

	cp -R ./$(DEF_LANG)/* ./$(SRC_DIR)/$(DEF_LANG)
	cp -R ./shared/* ./$(SRC_DIR)/$(DEF_LANG)

	cp -R ./$(SEC_LANG)/* ./$(SRC_DIR)/$(SEC_LANG)
	cp -R ./shared/* ./$(SRC_DIR)/$(SEC_LANG)

	mynt gen -f ./$(SRC_DIR)/$(DEF_LANG) ./$(TRG_DIR)
	mynt gen -f --locale=$(SEC_LANG_LOCALE) ./$(SRC_DIR)/$(SEC_LANG) ./$(TRG_DIR)/$(SEC_LANG)

	sass ./shared/_assets/css/_sass/print.sass ./$(TRG_DIR)/assets/css/print.css
	sass ./shared/_assets/css/_sass/screen.sass ./$(TRG_DIR)/assets/css/screen.css
	sass ./shared/_assets/css/_sass/pygments.trac.sass ./$(TRG_DIR)/assets/css/pygments.trac.css

	sass ./shared/_assets/css/_sass/print.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/print.css
	sass ./shared/_assets/css/_sass/screen.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/screen.css
	sass ./shared/_assets/css/_sass/pygments.trac.sass ./$(TRG_DIR)/$(SEC_LANG)/assets/css/pygments.trac.css

serve:
	mynt serve --base-url=/ ./$(TRG_DIR)

serve-sec:
	mynt serve --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)

watch:
	mynt watch -f --base-url=/ ./$(TRG_DIR)

watch-sec:
	mynt watch -f --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)

share-styles:
	rm -Rf ./$(TRG_DIR)/$(SEC_LANG)/assets/css
	mkdir ./$(TRG_DIR)/$(SEC_LANG)/assets/css
	cp -R ./$(TRG_DIR)/assets/css/* ./$(TRG_DIR)/$(SEC_LANG)/assets/css/
