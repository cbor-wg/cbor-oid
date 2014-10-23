OPEN=$(word 1, $(wildcard /usr/bin/xdg-open /usr/bin/open /bin/echo))
SOURCES?=${wildcard *.mkd}
DRAFTS=${SOURCES:.mkd=.txt}

all:	$(DRAFTS)

%.xml:	%.mkd
	kramdown-rfc2629 $< >$@.new1
	mv $@.new1 $@
	$(OPEN) $@

%.txt:	%.xml
	xml2rfc $< $@
	$(OPEN) $@
