SOURCES?=${wildcard *.mkd}
DRAFTS=${SOURCES:.mkd=.txt}

all:	$(DRAFTS)

%.xml:	%.mkd
	kramdown-rfc2629 $< >$@.new1
	mv $@.new1 $@

%.txt:	%.xml
	xml2rfc $< $@
