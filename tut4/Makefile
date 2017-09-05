all:	freetut.pdf 

freetut.pdf: freetut.tex freetut-body.tex
	# pdflatex freetut.tex
	# bibtex freetut
	pdflatex freetut.tex
	pdflatex freetut.tex

clean:
	-rm -f *.aux *.log *.bbl *.blg 
