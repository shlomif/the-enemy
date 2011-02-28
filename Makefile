FILES = Makefile $(DOCS_FICTION_XHTML) \
		The-Enemy-English.xhtml \
		$(DOCS_FICTION_TEXT) $(DOCS_FICTION_DB5) \
		style.css \
		README.html

DOCS_BASE = The-Enemy-Hebrew

DOCS_FICTION_TEXT = $(patsubst %,%.fiction-text.txt,$(DOCS_BASE))
DOCS_FICTION_XML = $(patsubst %,%.fiction-xml.xml,$(DOCS_BASE))
DOCS_FICTION_DB5 = $(patsubst %,%.db5.xml,$(DOCS_BASE))
DOCS_FICTION_XHTML = $(patsubst %,%.fiction-text.xhtml,$(DOCS_BASE))
DOCS_FICTION_ODT = $(patsubst %,%.odt,$(DOCS_BASE))

DOCBOOK5_XSL_STYLESHEETS_PATH := $(HOME)/Download/unpack/file/docbook/docbook-xsl-ns-snapshot

HOMEPAGE := $(HOME)/Docs/homepage/homepage/trunk
DOCBOOK5_XSL_STYLESHEETS_XHTML_PATH := $(DOCBOOK5_XSL_STYLESHEETS_PATH)/xhtml
DOCBOOK5_XSL_STYLESHEETS_FO_PATH := $(DOCBOOK5_XSL_STYLESHEETS_PATH)/fo
DOCBOOK5_XSL_CUSTOM_XSLT_STYLESHEET := $(HOMEPAGE)/lib/sgml/shlomif-docbook/xsl-5-stylesheets/shlomif-essays-5-xhtml.xsl

all: $(DOCS_FICTION_XHTML)

odt: $(DOCS_FICTION_ODT)

upload:
	rsync -v --progress -a $(FILES) $${HOMEPAGE_SSH_PATH}/the-enemy-prantemp/

$(DOCS_FICTION_DB5): %.db5.xml: %.fiction-xml.xml 
	perl -MXML::Grammar::Fiction::App::ToDocBook -e 'run()' -- \
		-o $@ $<

$(DOCS_FICTION_XML): %.fiction-xml.xml: %.fiction-text.txt
	perl -MXML::Grammar::Fiction::App::FromProto -e 'run()' -- \
	-o $@ $<

$(DOCS_FICTION_XHTML): %.fiction-text.xhtml: %.db5.xml
	xsltproc --path $(DOCBOOK5_XSL_STYLESHEETS_XHTML_PATH) -o $@ $(DOCBOOK5_XSL_CUSTOM_XSLT_STYLESHEET) $<

$(DOCS_FICTION_ODT): $(DOCS_FICTION_DB5)
	docbook2odf $< -o $@
