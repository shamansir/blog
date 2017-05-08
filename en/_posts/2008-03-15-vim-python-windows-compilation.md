---
layout: post.html
title: "[g]Vim in Python mode : Recompilation in Windows"
datetime: 15 Mar 2008 17:32
tags: [ gvim, python ]
---

Vim editor is best known between the developers who work on Unix systems -- it's a `emacs` competitor, something to call IDE-in-a-terminal -- this editor, with proper dexterity and tuning (it seems to me, the amount of required dexterity is a little less and the required efforts for tuning are more obvious than in `emacs`, but the last has the real powerful functionality -- it's a programmer's choice what to use) can make most of development processes faster and easier not in the expense of such advantages like auto-completion and project navigation. But if you plan to use it for Python development in Windows with all the advantages like these -- you''ll need to make some efforts, and the main effort is recompilation...

### Links

Let me present you some links to read about the subject:

* [Vim How-To](http://mgul.ac.ru/~t-alex/Linux/Vim-Color-Editor-HOW-TO/Vim-9.html) — _(rus.)_ About working in Vim. Short, but very good tutorial for beginners. ([full contents](http://mgul.ac.ru/~t-alex/Linux/Vim-Color-Editor-HOW-TO/Vim.html), has [a commands reference](http://mgul.ac.ru/~t-alex/Linux/Vim-Color-Editor-HOW-TO/Vim-10.html) inside)
* [Cheatsheets](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html) to learn key combinations easily and fast.
* [An article about Vim usage](http://cachealot.habrahabr.ru/blog/45414.html#habracut) _(rus.)_
* [Setting up Vim to work with Python](http://allaboutvim.blogspot.com/2007/12/vim-python.html) - _(rus.)_ an article with a detailed description about setting up with all the required plugins.
* [Compiling (g)Vim in Windows](http://users.skynet.be/antoine.mechelynck/vim/compile.htm) - the article that was a basis for the article you read.
* [An alternative article](http://people.smu.edu/jrobinet/howto/compile-vim-on-windows.asp) about the same - a shorten one, but focusing on Python 2.5.
* [Some notes](http://www.petersblog.org/node/461) about working with Python in Vim editor.

### Versions

A compilation was performed with `[g]Vim 7.1`, `Python 2.5.2`, `Tcl 8.5.1`, `Cygwin 1.5.25-11` on `Windows XP SP2` but the scenario, in fact, might be mostly independent from any versions numbers.

### Installing required software

So let's prepare. We need to install the language first -- [Python](http://www.python.org/download/) (if it is not installed) and, in you plan to use Tcl -- [Tcl/Tk](http://www.tcl.tk/software/tcltk/) (starting at some moment the Tcl language became a property of ActiveState: you can [download a free ActiveTcl package](http://www.activestate.com/store/activetcl)). The dynamic libraries of these languages are used through the compilation process.

To work with archives and to make a compilation process possible you'll need a Unix-utilities emulator running under Windows - it is [Cygwin](http://cygwin.com/). It includes the the `gcc` compiler, the our "boss" of compilation (there is a way to make it with Borland compiler, but please believe me, this way is much more complicated) and all the secondary stuff that will be required for it. [The installer](http://cygwin.com/setup.exe) works in not habitual way -- it downloads files and packages only just after you have selected them (and just if you choose to set everything up using Internet, but it is required for the first time anyway) -- herewith you, possibly, will return to installer to update or reinstall or install some more packages quite often. However, to install just the minimal set of stuff required in our case -- you need to select only several items: just after choosing a way of setting up (for current moment the most stable mirror was `ftp://mirror.switch.ch` (but literally in these seconds it was removed from the list of official mirrors): if you'll get download errors -- you will be returned to the mirror selection screen automatically) in the list of the packages, ensure that you are in `Category` mode (switch it with `View` button at the top, if required), and near the `All` item, click `Default` label several times to get it read as `Uninstall` (not to install the packages you don't need) and select the next items: `Utils/patch`, `Devel/gcc-g++`, `Devel/make`, `System/man` and `Devel/gcc-mingw` (the last is already selected, may be, and if it's true, then they have fixed the major problem that affected the whole compilation process :) ) -- now some other items will be automatically selected (let's re-check): `Shells/bash`, `Utils/bzip2` and `Devel/mingw-runtime` (the last is immensely important). Also I recommend to install `Web/wget` to make the further downloading of patches easier. That's all about `Cygwin` at the moment, you can press install.

Now we need to install [gVim](http://www.vim.org/download.php#pc) to dissect. You can tune it up for Python using [this article](http://allaboutvim.blogspot.com/2007/12/vim-python.html) I've mentioned before - but when you'll try to get auto-complete working, Vim will say that it requires to be recompiled with `+python` key and it is exactly what we plan to do.

### Preparation

Run `cmd` and ensure that you have your name and your computer name set in your `USERNAME` and `USERDOMAIN` environment variables (`echo %username%@%userdomain%`) and your `PATH` contains a path to `bin` of Cygwin.
`HOME` may be set to your "My documents" folder (the place where your Vim configuration file `vimrc` is stored), and `VIM` shoul point to the installed working Vim editor, preferrably in `8.3` format (i.e.: ``C:\PROGRA~1\VIM`). You can change variables values in the dialog located here: _My computer → Options → Advanced → Environment Variables_.

It is also important to get the sources, so we [download them](ftp://ftp.vim.org/pub/vim/unix/) for the current installed version (be careful -- namely the sources for Unix, even when you compile under Win32) (using the previous link you ca also download the debug files, but debugging is not covered in this article so it is not very required). Along with that sources you need to get language (`-lang`) and extra files for Windows (`-extra`) for the corresponding version [from here](ftp://ftp.vim.org/pub/vim/extra/).

Also, if you use a stable release and you want to install the newest patches -- follow [this link](ftp://ftp.vim.org/pub/vim/patches/7.1/) (correct the version number if you need) to get them. There is a problem gere, because they pack the patches only when their count reaches one hundred (001-100, 101-200 and so on), so for example if their count is 275 - you'll need to download the late 75 files manually or by creating a batch-script which uses `telnet`. However, we have Cygwin installed, so we can make an `.sh`-script, executing the same functions using `wget`, it can look something like this:

``` bash

PATCHES_DOWNLOAD_PATH=ftp://ftp.vim.org/pub/vim/patches
PATCHES_VER=7.1
wget $PATCHES_DOWNLOAD_PATH/$PATCHES_VER/$PATCHES_VER.001-100.gz
wget $PATCHES_DOWNLOAD_PATH/$PATCHES_VER/$PATCHES_VER.101-200.gz

for i in `seq 201 278`;
do
    wget $PATCHES_DOWNLOAD_PATH/$PATCHES_VER/$PATCHES_VER.$i
done

```

Now let's sort the sources in order that is required for compilation.

Source archive, `-extra` and `-lang` archives are required to be unpacked one by one (replacing the old files, though) in some directory, keeping the structure (let it be `C:/devel/vim-src/vim71` in our case): there inside the `/doc`,  `/nsis`, `/src`, `/farsi` and s.o. directories must be placed. You can use `bzip2` from Cygwin to unpack, or an internal archives plugin of [Total Commander](http://www.ghisler.com/) file manager, or a [7-zip](http://www.7-zip.org/) archivator or any other archive manager that copes well with `.tar.gz`/`tar.bz` :).

In `/runtime` subdirectory you can place `.vim` files, `/doc` and `/plugins` from your working version of Vim editor - so the patches will also be applied to them accordingly, if you plan to use the patches way. Patches can be placed to `/patches` directory, by the way.

### Compilation

To install patches, you need to execute `patch` command from Cygwin set over every one of them, unpacking the archives with bunches of hundreds of patches, provisionally. In this case I've used `.bat`-files instead of `.sh`-script (you need to correct the numbers of patches to apply your variant, of course):

``` batch

@ECHO off
ECHO changing directory to parent...

CD ..

ECHO -------------------- %Date% -------------------- >> patching-src.log

ECHO %CD%: applying first 200 patches

patch -p0 < patches/7.1.001-100 >> patching-src.log 2>&1
patch -p0 < patches/7.1.101-200 >> patching-src.log 2>&1

ECHO %CD%: applying the last patches

FOR /L %%B IN (201,1,278) DO
    patch -p0 < patches/7.1.%%B >> patching-src.log 2>&1

ECHO Finished

PAUSE

@ECHO on

```

Place this file in `/patches` directory, ensure the directories structure matches the one described above, correct numbers and execute it. In the sources root there will be a `patching-src.log` file created, where you can monitor the results of patching procedure. If `patch` utility wasn't found, ensure Cygwin path is in you `PATH`. If some (small amount of) files has not been found and patched - there is nothing to worry about, they may relate to XWindow-version.

Now we go directly to the compilation process, from Cygwin console. There is only execution of three commands required -- change to the source directory (Cygwin mounts your drives in `/cygdrive/` point: correct the paths to you Python and Tcl installation folder and their concrete versions, but if you compiling a version without Tcl support -- just remove the coinciding parameters) and create `vim.exe` (console version) and `gvim.exe` (GUI-version) files:

``` bash

$ cd /cygdrive/c/devel/vim-src/vim71
$ make -B -f Make_cyg.mak GUI=no \
    PYTHON=/cygdrive/c/devel/Python PYTHON_VER=25 DYNAMIC_PYTHON=yes \
    TCL=/cygdrive/c/devel/Tcl TCL_VER=85 DYNAMIC_TCL=yes vim.exe
$ make -B -f Make_cyg.mak OLE=yes \
    PYTHON=/cygdrive/c/devel/Python PYTHON_VER=25 DYNAMIC_PYTHON=yes \
    TCL=/cygdrive/c/devel/Tcl TCL_VER=85 DYNAMIC_TCL=yes gvim.exe

```

You can ignore warnings and even some of the errors if they relate to Python or Tcl, if process is still going and `.exe`-files are created in the end. If everything has ended up successfully, then you'll find both `.exe` files in `src` directory. Make a backup of existing files in working version of Vim (i.e. `vim.exe.bak` and `gvim.exe.bak`) and replace them with the ones just compiled. If you've applied the pathces, then place the `*.vim` files, `/doc/` and `/plugins` directories back from `/runtime` directory, making a backup before, replacing the old versions. Now launch Vim or gVim from the working Vim directory and re-check the version and the compilation options in the same place to have `+python` key -- it must be ok in most cases.

### Possible drawbacks

During the process of compiltion I've met two errors: `cannot exec cc1: No such file or directory` and `ld: cannot fin -lgcc`. Both of them are [known to the authors](http://www.mail-archive.com/cygwin@cygwin.com/msg10910.html) of Cygwin, however in mine versions the were not yet solved. The first one is temporary solved by adding a directory with `cc1.exe` executable file in local Cygwin `PATH` prior to compilation:

    $ PATH=$PATH:/cygdrive/c/devel/cygwin/lib/gcc/i686-pc-cygwin/3.4.4

The second one is solved the same way the first must to -- by installing `Devel/gcc-mingw` (they promised to make it automatically when user chooses `gcc` in future) while installing Cygwin. It is important to install the packages in same time, so if the error reappears still -- try to select `Reinstall` mode in Cygwin installer just in the same place where you've selected `Uninstall` before and re-install all packages again.

### Tuning up Vim for Python

(**Upd.**)

Basing on [this article](http://allaboutvim.blogspot.com/2007/12/vim-python.html) I've created a pack (you can take it [here](http://shaman-sir.by.ru/files/vimfiles.zip)) collected from the last versions of plugins mentioned there ([Project](http://allaboutvim.blogspot.com/2007/07/projecttargz-ide.html), PythonComplete, NERD_Commenter, [VCSCommand](http://allaboutvim.blogspot.com/2007/08/vcscommandvim-svn_09.html), RunScript and TagList plus, over them — [PyDiction](http://www.vim.org/scripts/script.php?script_id=850)) + minimal setting (in `ftplugin/python.vim`, practically identical to the one mention in the article (TabWrapper function changed + another way to include dictionary) -- _omni completion_ is set to `Tab`). You need to extract the contents to the `<path_to_installed_vim>\vimfiles`. For taglist plugin you'll need to download ctags [from here](http://prdownloads.sourceforge.net/ctags/ec57w32.zip), after unpacking to any directory, add its path to the `PATH` environment variable. Then you need to run `vim` and execute the command:

    :helptags $VIM\vimfiles\doc

Then you'll have a possibility to use `:help <plugin_name>` to get documentation of the corresponding plugin.

The default auto-completion, if you use this package settings, is called with `Tab` key, context-completion (_omni completion_) -- by `Ctrl+Enter` and `Ctrl+Space`, and completing keywords and modules -- by `Ctrl+Tab` (when you have a lot of variants, dictionary is loaded slow, so I've set it to a not-so-easy combination).

To include the [proposed](http://www.python.org/dev/peps/pep-0263/) by specification first lines in python files header automatically when created, add the code below to the `<path_to_installed_vim>\_vimrc` (filename line is added to demonstrate a possibilities to add a file name):

```

function! BufNewFile_PY()
   0put = '#!/usr/bin/env python'
   1put = '#-*- coding: utf-8 -*-'
   $put = '#-*- filename: ' . expand('') . ' -*-'
   $put = ''
   $put = ''
   normal G
endfunction

autocmd BufNewFile *.py call BufNewFile_PY()

```

…So now you can program in Python with comfort.
