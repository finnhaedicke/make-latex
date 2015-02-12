# make-latex
Makefile snippet to compile LaTeX to PDF with dependencies

Calls pdflatex, bibtex, makeindex (and repeats pdflatex).
Scans for dependencies inside the .tex to manage reruns.
The following commands are supported:
* `\include{}`
* `\input{}`
* `\includegraphics{}`
* `\bibliography{}`
* `\lstinputlisting{}`

If images do not exist, the Makefile will try to generate a pdflatex compatible format.
Supported image formats are PDF, PNG, JPG which are not converted and SVG, Dia, EPS, Xfig and gnuplot. 

Add this block to your Makefile to build _main.pdf_

```make
all: main.pdf

include path/to/Makefile.tex
$(eval $(call build_latex,main))
```
