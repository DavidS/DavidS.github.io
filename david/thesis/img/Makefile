
all: overview.pdf webbook_use_cases.pdf folderstruct.pdf orm.pdf klassisch.pdf NzuM.pdf concrete.pdf per-class.pdf per-hierarchy.pdf integrierteDatenschicht.pdf externeDatenschicht.pdf
	
%.pdf: %.eps
	epstopdf $<


include Makefile.transfig

Makefile.transfig: Makefile
	transfig -L pstex -M Makefile.transfig

Article.fig: Article.dia
	dia -t fig --export Article.fig Article.dia

