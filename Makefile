# Example -*- makefile -*- for building a site using DocBook Website
#
# $Id: Makefile-example.txt,v 1.2 2005/04/18 18:58:58 xmldoc Exp $
#
# ------------------------------------------------------------------
# The default value DOCBOOK_WEBSITE below is the canonical URI for
# the current DocBook Website distribution. If you have SGML or
# XML catalogs correctly set up for DocBook Website in your
# environment, and have the DocBook Website distribution installed
# locally on your system, the URI will automatically be resolved
# to the appropriate local path on your system.
# ------------------------------------------------------------------
#                        IMPORTANT!
# ------------------------------------------------------------------
# IF YOU DO NOT HAVE SGML OR XML CATALOGS SET UP ON YOUR SYSTEM,
# change the value of DOCBOOK_WEBSITE to the appropricate local
# pathname for your system. OR, run "make" like this:
#
#  make DOCBOOK_WEBSITE=/foo/bar/website
#
# Note that DOCBOOK_WEBSITE SHOULD NOT BE THE URI FOR YOUR SITE!
# There is nowhere in this makefile where you need to specify that.
# ------------------------------------------------------------------
#
DOCBOOK_WEBSITE=http://docbook.sourceforge.net/release/xsl/current/website
#DOCBOOK_WEBSITE=/usr/share/xml/docbook/custom/website/current

# generate non-tabular output instead of tabular? 1=Yes 0=No
MAKENONTAB=0

# use HTML Tidy to pretty-print HTML? 1=Yes 0=No
USETIDY=0
# specifies how to call tidy
TIDY=tidy
# specifies options to feed to tidy
TIDYOPTS=-iq -latin1 -mn

# specifies command for calling your XSLT engine
XSLT=xsltproc --stringparam output-root $(DESTDIR)

# XMLPARSER specifies command for calling your preferred XML
# parser for validating the DocBook XML sources for your site
XMLPARSER=xmllint --valid --noout

DESTDIR=html_out

# the following is empty by default; put any custom DocBook
# stylesheet params you want here; they will be applied globally
# to all HTML transformations from your DocBook XML sources
STYLEOPT=

# name of directory to use if chunking output with "make chunk"
DESTPATH=.

MY_STYLESHEET=config.xsl

#TABSTYLE      =  $(DOCBOOK_WEBSITE)/xsl/tabular.xsl
# Use our custom stylesheet
TABSTYLE      =  $(MY_STYLESHEET)
TABCHUNK      =  $(DOCBOOK_WEBSITE)/chunk-tabular.xsl
AUTOLAYOUT    =  $(DOCBOOK_WEBSITE)/autolayout.xsl 
MAKEDEPENDS   =  $(DOCBOOK_WEBSITE)/makefile-dep.xsl
MAKETARGETSDB =  $(DOCBOOK_WEBSITE)/website-targets.xsl

XMLDEPENDS    = autolayout.xml website.database.xml

.PHONY : clean

all: style images
	$(MAKE) website

STYLESHEET=$(TABSTYLE)
STYLECHUNK=$(TABCHUNK)
NONTAB_OPT=
-include depends.tabular

autolayout.xml: layout.xml
	$(XMLPARSER) $(filter-out $(XMLDEPENDS),$^)
	$(XSLT) $(AUTOLAYOUT) $< > $@

chunk: autolayout.xml
	$(XSLT) --param output-root $(DESTPATH) $(STYLECHUNK) autolayout.xml

%.html: autolayout.xml website.database.xml
	$(XMLPARSER) $(filter-out $(XMLDEPENDS),$^)
	$(XSLT) $(NONTAB_OPT) $(STYLEOPT) $(STYLESHEET) $(filter-out $(XMLDEPENDS),$^) > $@
ifeq ($(USETIDY),1)
	-$(TIDY) -iq -latin1 -mn $@
endif

# RDDL gets its own rule because we never want to call tidy on it
rddl.html: autolayout.xml
	$(XMLPARSER) $(filter-out $(XMLDEPENDS),$^)
	$(XSLT) $(NONTAB_OPT) $(STYLEOPT) $(STYLESHEET) $(filter-out $(XMLDEPENDS),$^) > $@

depends.tabular depends.nontabular: autolayout.xml
	$(XSLT) --stringparam depends-file $@ $(NONTAB_OPT) $(MAKEDEPENDS) $< > $@

website.database.xml: autolayout.xml
	$(XSLT) $(MAKETARGETSDB) $< > $@


style: $(DESTDIR)/docbook-website.css

$(DESTDIR)/docbook-website.css:
	mkdir -p $(DESTDIR)
	cp docbook-website.css $(DESTDIR)

$(DESTDIR)/graphics:
	mkdir -p $(DESTDIR)/graphics

images: $(DESTDIR)/graphics
	cp -r graphics $(DESTDIR)/

sync:
	rsync -avz --whole-file --progress -e ssh  $(DESTDIR)/* ddswww@lxi001.gsi.de:~/web-docs/



depends: autolayout.xml website.database.xml depends.tabular

clean-all: clean
	rm -f autolayout.xml depends.tabular website.database.xml
	rm -rf $(DESTDIR)
