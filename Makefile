SOURCES?=${wildcard *.mkd}
DRAFTS=${SOURCES:.mkd=.txt}

all:	$(DRAFTS)

%.xml:	%.mkd
	kramdown-rfc2629 $< >$@.new1
	sed '/\<section anchor="examples"/,/\<section anchor="discussion\"/ s/\<spanx style\=\"verb\"\>/\<spanx style\=\"vbare\"\>/' $@.new1 > $@.new2
	mv $@.new2 $@

%.txt:	%.xml
	xml2rfc $< $@
