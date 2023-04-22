objects := $(shell find . -name '*tex')
objects += bib/bib.bib

# Set to "pdf" for pdf output
PDF_PREFIX="pdf"

all: clean $(objects)
	make -C img
	$(PDF_PREFIX)latex Diplomarbeit
	bibtex Diplomarbeit
	$(PDF_PREFIX)latex Diplomarbeit
	$(PDF_PREFIX)latex Diplomarbeit

# Define Diplomarbeit.pdf as PHONY to generate .pdf always
.PHONY: Diplomarbeit.pdf

fast:
	$(PDF_PREFIX)latex Diplomarbeit

view: Diplomarbeit.pdf
	acroread Diplomarbeit.pdf

clean:
	find . -name '*aux' | xargs --no-run-if-empty rm
	find . -name '*bak' | xargs --no-run-if-empty rm
	rm -f Diplomarbeit.bbl
	rm -f Diplomarbeit.blg
	rm -f Diplomarbeit.lof
	rm -f Diplomarbeit.lot
	rm -f Diplomarbeit.log
	rm -f Diplomarbeit.out
	rm -f Diplomarbeit.pdf
	rm -f Diplomarbeit.dvi
	rm -f Diplomarbeit.toc
