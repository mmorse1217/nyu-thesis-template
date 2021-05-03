###
## generic makefile for latex projects
## Author: Abtin Rahimian
###

###
## Plain 'make' should work most of the time, other useful patterns are
##  $ make help              #to see this
##  $ make PROJ=name         #for project with different name from the dir
##  $ make OUTEXT=dvi        #for dvi output with latex compiler (default pdf)
##  $ make OUTOFSRC=no       #make in the same directory, otherwise inside ${BIULDDIR}
##
###

## user flags
PROJ     ?= $(notdir $(shell pwd))#defaults to dirname
OUTEXT   ?= pdf
SUMMARY  ?= grep -in --color=always "\(error\|warn\|warning\|repeated\|skipping\)"
POSTSUM  ?= awk '{ gsub("undefined", "\033[1;33m&\033[0m"); gsub("multiply defined", "\033[1;36m&\033[0m"); print }'
SYNC     ?= -synctex=1
OUTOFSRC ?= yes
BUILDDIR ?= ${_BUILDDIR}

ifeq ($(strip ${SCRATCH}),)
  _BUILDDIR = _build
else
  _BUILDDIR = ${SCRATCH}/$(strip ${PROJ})/_build
endif

ifeq ($(strip ${OUTOFSRC}),no)
  _BUILDDIR = ${CURDIR}
endif

## programs
LXX      ?= latexmk
PDFLATEX ?= pdflatex
LATEX	 ?= latex
BIBTEX	 ?= bibtex
DVI	 ?= dvipdf
PS	 ?= ps2pdf
MKDIR    ?= mkdir
OPEN     ?= open

## internal flag
LXFLAG 	 ?= -g -file-line-error -halt-on-error -shell-escape ${SYNC}
TEXFILES ?= $(shell ls -b *.tex *.bib)

ifeq (${OUTEXT},pdf)
  LXFLAG += -pdf
endif

BIBINPUTS:="..;${CURDIR};${BIBINPUTS};"
TEXINPUTS:="..;${CURDIR};${TEXINPUTS};;"

export

all: ${BUILDDIR}/$(addsuffix .${OUTEXT}, ${PROJ})

help:
	@head -14 ${MAKEFILE_LIST}

${BUILDDIR}:
	${MKDIR} -p ${BUILDDIR}
	${MKDIR} -p ${BUILDDIR}/figs

%.${OUTEXT}:${TEXFILES} ${BUILDDIR}
	@echo "building out of source in ${BUILDDIR} for $(notdir $*)"
	cd ${BUILDDIR} && ${LXX} ${LXFLAG} ${CURDIR}/$(addsuffix .tex, $(notdir $*))
	${SUMMARY} ${BUILDDIR}/*.log ${BUILDDIR}/*.blg | ${POSTSUM}

open:
	@echo "opening ${BUILDDIR}/$(addsuffix .${OUTEXT}, ${PROJ})"
	@${OPEN} -a /Applications/TeX/TeXShop.app ${BUILDDIR}/$(addsuffix .${OUTEXT}, ${PROJ})

dir:
	@echo "${BUILDDIR}"

info:
	@echo "Build directory is ${BUILDDIR}"

archive:
	hg archive --include "../exclude/*" --exclude "*response.tex" $(addsuffix .tgz, ${PROJ})

clean:
	@echo "removing build directory ${BUILDDIR}"
	${RM} -r ${BUILDDIR}

image-build: Dockerfile
	docker build -f Dockerfile -t latex .
container-create: 
	echo "making container...";
	docker create -it -v `pwd`:/latex --name thesis-dev latex
container-start:
	echo "starting container...";
	docker start thesis-dev
container-stop:
	echo "stopping container...";
	docker stop thesis-dev
container-exec:
	echo "exec-ing into container...";
	docker exec -it thesis-dev bash

.PHONY: clean open all
