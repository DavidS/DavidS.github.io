
TEX=${wildcard *.tex}
PDF=${shell for i in $(TEX) ; do echo `basename $$i .tex`.pdf; done}
PS=${shell for i in $(TEX) ; do echo `basename $$i .tex`.ps; done}

all: $(PDF) $(PS) clean

%.pdf: %.tex
	pdflatex $<
	chmod 0644 $@

%.dvi: %.tex 
	latex $<

%.ps: %.dvi 
	dvips $< -o $@
	chmod 0644 $@

clean:
	rm -f *aux *log *dvi

dist-clean: clean
	rm -f *.ps *.pdf *.toc

clean-home: dist-clean

