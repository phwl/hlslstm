all:	fwttut.pdf fwttut-soln.pdf

fwttut-soln.pdf: fwttut-soln.tex fwttut-body.tex
	pdflatex fwttut-soln.tex
	bibtex fwttut-soln
	pdflatex fwttut-soln.tex
	pdflatex fwttut-soln.tex

fwttut.pdf: fwttut.tex fwttut-body.tex
	pdflatex fwttut.tex
	bibtex fwttut
	pdflatex fwttut.tex
	pdflatex fwttut.tex

clean:
	-rm -f *.aux *.log *.bbl *.blg 
