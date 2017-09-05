all:
	R CMD BATCH tut1plot.r 
	pdflatex walshtut.tex
	pdflatex walshtut-soln.tex
	bibtex walshtut
	bibtex walshtut-soln
	pdflatex walshtut.tex
	pdflatex walshtut-soln.tex
	pdflatex walshtut.tex
	pdflatex walshtut-soln.tex

walsh:
	gcc -o walsh walsh.c

clean:
	-rm -f *.aux *.log *.bbl *.blg walsh
