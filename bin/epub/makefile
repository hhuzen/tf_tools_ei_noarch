EPUBTOOLS?=$(TOOLS_DIR)/epub

all:
	@echo "c (clean)"
	@echo "b (build epub pdf docx)"
	@echo "be (build epub)"
	@echo "bp (build pdf)"
	@echo "bd (build docx)"
	@echo "e (epub read)"
	@echo "h (html read)"
	@echo "a (abc to svg)"

dirs:
	@[ -d output ] || mkdir output
	@[ -d html ] || mkdir html

md2html:
	@export EPUB_TITLE="$(EPUB_TITLE)"; \
	export EPUB_AUTHOR="$(EPUB_AUTHOR)"; \
	export EPUB_NAMESPACE="$(EPUB_NAMESPACE)"; \
	export EPUB_LANGUAGE="$(EPUB_LANGUAGE)"; \
	export EPUB_COVER="$(EPUB_COVER)"; \
	export INDEX_TYPE="$(INDEX_TYPE)"; \
	perl $(EPUBTOOLS)/mkbook.pl edit2html; 

html2epub:
	export EPUB_TITLE="$(EPUB_TITLE)"; \
	export EPUB_AUTHOR="$(EPUB_AUTHOR)"; \
	export EPUB_NAMESPACE="$(EPUB_NAMESPACE)"; \
	export EPUB_LANGUAGE="$(EPUB_LANGUAGE)"; \
	export EPUB_COVER="$(EPUB_COVER)"; \
	echo " -- ebook-convert -- " ; \
        export COVER_OPT="" ; \
        [ ! -z "$$EPUB_COVER" ] && COVER_OPT=" --cover $$EPUB_COVER" ; \
	ebook-convert html/index.html "output/$$EPUB_TITLE.epub"  --level1-toc //h:h1 --level2-toc //h:h2 $$COVER_OPT --authors "$(EPUB_AUTHOR)" --title  "$(EPUB_TITLE)" --language "$EPUB_LANGUAGE" ; \
	echo " -- ebook-convert epub -- OK -- " ; 

html2pdf:
	export EPUB_TITLE="$(EPUB_TITLE)"; \
	export EPUB_AUTHOR="$(EPUB_AUTHOR)"; \
	export EPUB_NAMESPACE="$(EPUB_NAMESPACE)"; \
	export EPUB_LANGUAGE="$(EPUB_LANGUAGE)"; \
	export EPUB_COVER="$(EPUB_COVER)"; \
	echo " -- ebook-convert -- " ; \
        export COVER_OPT="" ; \
        [ ! -z "$$EPUB_COVER" ] && COVER_OPT=" --cover $$EPUB_COVER" ; \
	ebook-convert html/index.html "output/$$EPUB_TITLE.pdf"  --level1-toc //h:h1 --level2-toc //h:h2 $$COVER_OPT --authors "$(EPUB_AUTHOR)" --title  "$(EPUB_TITLE)" --language "$EPUB_LANGUAGE" ; \
	echo " -- ebook-convert pdf -- OK -- " ; 

html2docx:
	export EPUB_TITLE="$(EPUB_TITLE)"; \
	export EPUB_AUTHOR="$(EPUB_AUTHOR)"; \
	export EPUB_NAMESPACE="$(EPUB_NAMESPACE)"; \
	export EPUB_LANGUAGE="$(EPUB_LANGUAGE)"; \
	export EPUB_COVER="$(EPUB_COVER)"; \
	echo " -- ebook-convert -- " ; \
        export COVER_OPT="" ; \
        [ ! -z "$$EPUB_COVER" ] && COVER_OPT=" --cover $$EPUB_COVER" ; \
	ebook-convert html/index.html "output/$$EPUB_TITLE.docx"  --level1-toc //h:h1 --level2-toc //h:h2 $$COVER_OPT --authors "$(EPUB_AUTHOR)" --title  "$(EPUB_TITLE)" --language "$EPUB_LANGUAGE" ; \
	echo " -- ebook-convert docx -- OK -- " ; 

a: a_abc b

a_abc:
	perl $(EPUBTOOLS)/mkbook.pl abc2svg;

b build: dirs md2html html2epub 
be build: dirs md2html html2epub 
bp build: dirs md2html html2pdf 
bd build: dirs md2html html2docx 

e epub: dirs
	@echo "using Calibre ebook-viewer" 
	@ebook-viewer output/*.epub &

h html: dirs
	@(cd html; firefox ./index.html)

c clean:
	@rm -rf html
	@rm -rf epub
	@rm -rf edit/abc
	@rm -rf image/*-md.png
	@echo $@ done


