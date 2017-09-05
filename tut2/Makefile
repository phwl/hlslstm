all:	dwttut.pdf dwttut-soln.pdf

dwttut-soln.pdf: dwttut-soln.tex dwttut-body.tex
	pdflatex dwttut-soln.tex
	bibtex dwttut-soln
	pdflatex dwttut-soln.tex
	pdflatex dwttut-soln.tex

dwttut.pdf: dwttut.tex dwttut-body.tex
	pdflatex dwttut.tex
	bibtex dwttut
	pdflatex dwttut.tex
	pdflatex dwttut.tex

clean:
	-rm -f *.aux *.log *.bbl *.blg 
