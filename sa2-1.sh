ls -ARl | grep '^[-|d]' | sort -n -r -k 5 | awk '$1 ~ /^[-|d]/{all++}{if(all<= 5) {print all ":" $5,$9};} $1 ~ /^d/{dir++} END{print "Dir num:" dir} $1 ~ /^-/{file++} END{print "File num:" file} END{print "Total:" NR}' 

