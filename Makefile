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
	# compass watch --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/assets/css/ &
	# compass watch --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$(TRG_DIR)/$(SEC_LANG)/assets/css/ &

serve:
	mynt serve --base-url=/ ./$(TRG_DIR)

serve-sec:
	mynt serve --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)

watch:
	mynt watch --base-url=/ ./$(TRG_DIR)

watch-sec:
	mynt watch --base-url=/$(SEC_LANG)/ ./$(TRG_DIR)/$(SEC_LANG)
