FILES = Makefile $(DOCS_FICTION_XHTML) \
		$(DOCS_FICTION_TEXT) $(DOCS_FICTION_DB5) \
		$(ENG_EPUB) $(ENG_DB_PROCESSED) $(ENG_DB_SOURCE) $(ENG_XHTML) \
		style.css style-heb.css \
		README.html

# The-Enemy-English.xhtml \

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
DOCBOOK5_XSL_CUSTOM_XSLT_STYLESHEET := $(HOMEPAGE)/lib/sgml/shlomif-docbook/xsl-5-stylesheets/shlomif-essays-5-xhtml-onechunk.xsl

ENG_DB_DIR = English-Docbook

ENG_EPUB = $(ENG_DB_DIR)/The-Enemy-English.epub
ENG_XHTML = $(ENG_DB_DIR)/The-Enemy-English.xhtml

all: $(DOCS_FICTION_XHTML) $(ENG_EPUB) $(ENG_XHTML) $(ENG_HTML_FOR_OOO)

odt: $(DOCS_FICTION_ODT)

upload:
	rsync -v --progress -a $(FILES) $${HOMEPAGE_SSH_PATH}/$(THE_ENEMY_DEST)/

$(DOCS_FICTION_DB5): %.db5.xml: %.fiction-xml.xml 
	perl -MXML::Grammar::Fiction::App::ToDocBook -e 'run()' -- \
		-o $@ $<

$(DOCS_FICTION_XML): %.fiction-xml.xml: %.fiction-text.txt
	perl -MXML::Grammar::Fiction::App::FromProto -e 'run()' -- \
	-o $@ $<

$(DOCS_FICTION_XHTML): %.fiction-text.xhtml: %.db5.xml
	xsltproc --stringparam root.filename $@ \
		--stringparam html.stylesheet "style-heb.css" \
		--path $(DOCBOOK5_XSL_STYLESHEETS_XHTML_PATH) \
		-o $@ \
		$(DOCBOOK5_XSL_CUSTOM_XSLT_STYLESHEET) $<
	mv -f $@.html $@

$(DOCS_FICTION_ODT): $(DOCS_FICTION_DB5)
	docbook2odf $< -o $@

ENG_DB_PROCESSED = $(ENG_DB_DIR)/PROCESSED_The-Enemy-English.db5.xml
ENG_DB_XSLT = $(ENG_DB_DIR)/docbook-epub-preproc.xslt
ENG_DB_SOURCE = $(ENG_DB_DIR)/The-Enemy-English.db5.xml
ENG_HTML_FOR_OOO = $(ENG_DB_DIR)/The-Enemy-English.for-openoffice.html

$(ENG_DB_PROCESSED) : $(ENG_DB_XSLT) $(ENG_DB_SOURCE)
	xsltproc --output $@ $(ENG_DB_XSLT) $(ENG_DB_SOURCE)

$(ENG_EPUB) : $(ENG_DB_PROCESSED)
	jing http://www.docbook.org/xml/5.0/rng/docbook.rng $<
	ruby $(HOME)/Download/unpack/file/docbook/docbook-xsl-ns-snapshot/epub/bin/dbtoepub -o $@ $<

$(ENG_XHTML) : $(ENG_DB_PROCESSED)
	jing http://www.docbook.org/xml/5.0/rng/docbook.rng $<
	xsltproc --stringparam root.filename $@ --path $(DOCBOOK5_XSL_STYLESHEETS_XHTML_PATH) -o $@ $(DOCBOOK5_XSL_CUSTOM_XSLT_STYLESHEET) $<
	mv -f English-Docbook/English-Docbook/The-Enemy-English.xhtml.html $@

$(ENG_HTML_FOR_OOO): $(ENG_XHTML)
	cat $< | perl -lne 'print unless m{\A<\?xml}' > $@

openoffice: $(ENG_HTML_FOR_OOO)
	ooffice3.2 $<

.PHONY: epub_ff

epub: $(ENG_EPUB)

epub_ff: epub
	firefox $(ENG_EPUB)
