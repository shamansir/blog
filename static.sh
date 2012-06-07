ROOT_DIR=`pwd`
DEF_LANG=en
SEC_LANG=ru
TMP_DIR=.tmp

cd $ROOT_DIR
rm -Rf ./$TMP_DIR
mkdir -p ./$TMP_DIR
mkdir ./$TMP_DIR/_site
mkdir ./$TMP_DIR/_site/$SEC_LANG
mkdir ./$TMP_DIR/_subsites
mkdir ./$TMP_DIR/_subsites/$SEC_LANG
cp -R ./$DEF_LANG/* ./$TMP_DIR
cp -R ./shared/* ./$TMP_DIR
cp -R ./$SEC_LANG/* ./$TMP_DIR/_subsites/$SEC_LANG
cp -R ./shared/* ./$TMP_DIR/_subsites/$SEC_LANG
mynt gen -f --base-url=/ ./$TMP_DIR ./$TMP_DIR/_site
mynt gen -f --base-url=/$SEC_LANG/ ./$TMP_DIR/_subsites/$SEC_LANG ./$TMP_DIR/_site/$SEC_LANG
#mynt watch -f --base-url=/ ./$TMP_DIR ./$TMP_DIR/_site &
#mynt watch -f --base-url=/$SEC_LANG/ ./$TMP_DIR/_subsites/$SEC_LANG ./$TMP_DIR/_site/$SEC_LANG &
mynt serve --base-url=/ ./$TMP_DIR/_site
#echo "=== Don't forget to kill: ==="
#ps x | grep watch

