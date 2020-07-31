ls -ARl | grep '^[-|d]' | sort -n -r -k 5 | awk '$1 ~ /^[-|d]/{all++}{if(all<= 5) {print all ":" $5,$9};} $1 ~ /^d/{dir++}END{if(dir==0) print "Dir num:" 0;else print "Dir num:" dir;} $1 ~ /^-/{{file++;}{total=total+$5;}}END{if(file==0) print "File num:" 0;else print "File num" file;} END{print "Total:" total}' 

