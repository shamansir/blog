It is the [mynt](http://mynt.mirroredwhite.com/) sources of my 'No Word about Onion' blog: [English version](http://shamansir.github.com/blog) | [Russian version](http://shamansir.github.com/blog/ru).

In fact, this one is implemented with [a bit modified version](https://github.com/shamansir/mynt) of [mynt](http://mynt.mirroredwhite.com/).

If you (ever) want to run this locally, you'll need to:

1. Clone this blog repository:

        git clone git@github.com:shamansir/blog.git

1. Then clone my fork of mynt:

        git clone git@github.com:shamansir/mynt.git

1. Run there this command:

        cd ./mynt
        python setup.py install

1. Run `make` from the blog directory at least once (if it won't find `sass` binary, that's ok, just procced to next step):

        cd ./blog
        make

1. Install [Compass](http://compass-style.org/), to use it from command-line (or [CodeKit](https://incident57.com/codekit/) to compile SASS files on the fly)

    * Configure it to compile `.sass`-files from `./blog/shared/_assets/css/_sass/` directory to both:
        * `./blog/.site/assets/css` directory
        * `./blog/.site/ru/assets/css` directory

1. Run `make serve` or `make watch` from the blog directory, so it will host a version of blog at `http://127.0.0.1:8080/`, and Compass/CodeKit will be watching for changes of `.sass`-files

        cd ./blog
        make serve
