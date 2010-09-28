#!/usr/bin/env awk
BEGIN {

	# tex and bibtex files
	TEX   = ""
	BIB   = ""
	# used pictures
	PICS  = ""
	# sty and cls
	STY   = ""

	CONTENT  = ""

	TARGET= ""

	LASTFILE=""
}

#LASTFILE!=FILENAME {
	#print "#f NEW FILE:", FILENAME
	#LASTFILE=FILENAME
#}

TARGET=="" { TARGET=FILENAME }

#entferne kommentare
/%/ {  sub("%.*","") }

# sammle tex;
{ 
	#CONTENT = CONTENT  " " $0
}



{ 
	CONTENT = $0 "\n"

#\bibliography{bib-datei}
#\include{tex-datei}
#\input{tex-datei}
#\includegraphics{bild}
	bibs  = "^bibliography$"
	texs  = "^include$|^input"
	lsts  = "^lstinputlisting$"
	pics  = "^includegraphics$|^picx$|^scalepicx$"
	
	# entferne optionale parameter
	opt = "\\[[^][]*\\]"
	while ( match( CONTENT, opt) != 0 )
	{
		gsub( opt, "", CONTENT )
	}

	split (CONTENT, arr, "\\")
	
	#iterate over all tex commands  (without \, mwith {})
	for ( i in arr)
	{

		# skip empty lines
		if(arr[i] ~ "^[ \t]*$")
			continue;

		cmd[0]=""
		splitTex(arr[i], cmd)

		# expr is bib reference?
		if ( match(cmd[0], bibs) == 1)
		{
			#print "#b", FILENAME ":found bib " cmd[1]
			split(cmd[1], bibAr, ",")
			for (i in bibAr) {
			  #BIB = BIB " " bibAr[i]
			  #print "J " i "K " bibAr[i] " L" BIB "M"
			  if (i>0) { 
				BIB = BIB " " bibAr[i] ".bib"
			  }
			  print bibAr[i] ".bib:"
			}
			continue
		}
	#print "ZZ " BIB " QQ"

		# expr is tex include
		if ( match(cmd[0], texs) == 1)
		{
			_filename = cmd[1];
			if (match(_filename, ".tex$") == 0 ) {
			  _filename = _filename ".tex"
			}
			#print "#t",FILENAME ":found incl", cmd[1]
			TEX = TEX "\t" _filename "\\\n"
			print _filename ":"
			callfile(_filename)
			continue
		}
		# expr is lstlisting include
		if ( match(cmd[0], lsts) == 1)
		{
			_filename = cmd[1];
			#print "#t",FILENAME ":found incl", cmd[1]
			TEX = TEX "\t" _filename "\\\n"
			print _filename ":"
			continue
		}

		# expr is a picture
		if ( match(cmd[0], pics) == 1)
		{
			pdffile = cmd[1] ".pdf"
			if (system("test -f " pdffile) == 0) {
				TEX = TEX "\t" pdffile "\\\n"
			}
			PICS = PICS " " cmd[1] 
			print cmd[1] ".pdf:"
			continue
		}

		# expr is documentclass
		if ( match(cmd[0], "^documentclass$") == 1)
		{
			clsfile = cmd[1] ".cls"
			if (system("test -f " clsfile) == 0) {
				#print "#cls", clsfile
				TEX = TEX "\t" clsfile "\\\n"
				print clsfile ":"
			}
			continue
		}
	}



}

END {
	#gsub("^ *","", BIB)
#	if(BIB != "")
#	{
#		gsub(" +|$", ".bib ", BIB)
#	}
	gsub( ".tex", "", TARGET )
	# ergebnisse ausgeben
	print TARGET ".pdf : " TARGET ".tex " BIB " \\"
	print   TEX "\n"
	print  "PICS +=", PICS
}

function splitTex(s, ret)  {
	i=index(s,"{")
	if(i==0) {
		ret[0]=s
		args=""
	} else {
		ret[0]=substr(s,1,i-1)
		args=substr(s,length(ret[0])+1)
	}
	
	#print "#! scanning"
	count = 0
	brack=0
	for (i = 1; i <= length(args); ++i ) {
		c = substr(args,i,1)
		#print "#!", i, c
		if(c == "{" ) {
			if (brack==0) {
				count++
				splitpoints[count]=i+1
				#print "#! split"
			}
			brack++
		}
		else if (c=="}") {
			brack--
			if (brack==0) {
				count++
				splitpoints[count]=i
				#print "#! split"
			}
		}
	}
	#print "#! splitting"
	argc = 0
	argv =""
	for ( i = 1; i <= count; i+=2 ) {
		argc++
		p1 = splitpoints[i]
		p2 = splitpoints[i+1]
		ret[argc]=substr(args, p1, p2-p1)
		#print "#! arg: ", ret[argc]
		argv = argv " " ret[argc]
	}
	ret["argc"]=argc

	#print "#! ", s, ":"  ret[0],  argv

}

function callfile(f) {
	#print "#cf", ARGC
	if (system("test -f " f) == 0) {
		ARGV[ARGC]=f
		ARGC++
		#print "#cf", ARGC, f
		
	} else {
		#print "#cf File " f "does not exist."
	}
}
