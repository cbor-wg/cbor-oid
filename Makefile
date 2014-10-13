SOURCES?=${wildcard *.mkd}
DRAFTS=${SOURCES:.mkd=.txt}

all:	$(DRAFTS)

%.xml:	%.mkd
	kramdown-rfc2629 $< >$@.new
	mv $@.new $@

%.txt:	%.xml
	xml2rfc $< $@
