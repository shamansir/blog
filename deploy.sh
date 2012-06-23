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
mynt gen -f ./$TMP_DIR ./$TMP_DIR/_site
mynt gen -f ./$TMP_DIR/_subsites/$SEC_LANG ./$TMP_DIR/_site/$SEC_LANG
compass compile --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$TMP_DIR/_site/assets/css/
compass compile --config shared/_assets/css/_sass/config.rb --sass-dir ./shared/_assets/css/_sass --css-dir ./$TMP_DIR/_site/$SEC_LANG/assets/css/
CUR_BRANCH=$(git symbolic-ref -q HEAD)
CUR_BRANCH=${CUR_BRANCH##refs/heads/}
CUR_BRANCH=${CUR_BRANCH:-HEAD}
echo "moving away from branch $CUR_BRANCH"
echo "..."
sleep 3
git stash
git checkout gh-pages
rm -Rf ./*
cp -R ./$TMP_DIR/_site/* . 
git add -A
git status
echo "..."
sleep 6
git commit -m "update from $(date)"
echo "..."
sleep 6
git push origin gh-pages
git checkout $CUR_BRANCH
git stash apply

