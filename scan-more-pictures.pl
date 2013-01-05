# tool for collecting all the pictures shown on a blogspot
# author: Sylvain 'Pype' Martin (http://sylvainhb.blogspot.com)
#   free for use, no guarantees of any kind. Improvements and feedbacks
#   are welcome at pype_1999.geo@yahoo.com

# usage :
# perl scan-for-pictures.pl blog-content.xml : just list them

# perl ../scan-for-pictures.pl ../blog-content-01-06-2010.xml | sort | cut -d "}" -f 2 | fe - "wget %"
# ^ that one also download them.
# fe (foreach) could be replaced with xarg or downloaded from
#  http://sylvainhb.blogspot.com/2009/02/script-powaa.html

# only download pictures it doesn't already have locally.
# pictures are prefixed with line_number-image_number- to produce unique filenames.

# note: before line numbers are used, rather than post IDs, you should "freeze" 
# edition on the xml file (e.g. don't add content, strip things or split lines)

while (<>) {
  $lno++;
  $imno=1;
  while (/http:/) {
    if (m=(http://[a-z0-9.]+.flickr.com/[^"]+)/([^"/]+)(.*)=) {
      -r "$lno-$imno-$2" or 
	print "{flick, $lno} $1/$2 --output-document=\"$lno-$imno-$2\"\n";
      $_=$3;
      $imno++; next;
    }
    if (m=(http://photos[0-9]+.blogger.com/[^".]+)/([^"/]+)(.*)=) {
      -r "$lno-$imno-$2" or 
	print "{bl0gger, $lno} '$1/$2' --output-document=\"$lno-$imno-$2\"\n";
      $_ = $3;
      $imno++; next;
    }
    # this one will catch all pictures, but not hlinks.
    if (m#src="(http://[^"]+.[a-z]+)/([^"/]+)(.*)"#) {
      -r "$lno-$imno-$2" or 
	print "{external, $lno} '$1/$2' --output-document=\"$lno-$imno-$2\"\n";
      $_=$3;
      $imno++; next;
    }
    last; # we didn't found any match. Let's process the next line.
  }
}
