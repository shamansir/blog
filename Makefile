ROOT_DIR=`pwd`

DEF_LANG=en
SEC_LANG=ru
DEF_LANG_LOCALE=en_EN.UTF-8
SEC_LANG_LOCALE=ru_RU.UTF-8

TRG_DIR=.site
SRC_DIR=.cache

all: build

build:
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

	ln -sf ../.fonts/ ./$(TRG_DIR)/.fonts

serve:
	mynt serve --base-url=/ ./$(TRG_DIR)

serve-sec:
	mynt serve --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)

watch:
	mynt watch -f --base-url=/ ./$(TRG_DIR)

watch-sec:
	mynt watch -f --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)

update-sec-styles:
	cp ./$(TRG_DIR)/assets/css/* ./$(TRG_DIR)/$(SEC_LANG)/assets/css/
