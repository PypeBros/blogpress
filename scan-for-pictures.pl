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
  $line=$_;
  while ($line =~ m#([a-z]+=["']http:[^"']+)(.*)#) {
    $url=$1; $next=$2;
    $preview=substr($next,0,40);
#    print STDERR "$` [$url] [$preview...\n";

    if ($url=~ m=(http://[a-z0-9.]+blogspot.com/[-_][0-9a-zA-Z/_-]+)/s([0-9]+)(\-?h?/)([^".]+.[a-z]+)(.*)=) {
      -r "$lno-$imno-$4" or 
	print "{local, $2px, $lno} '$1/s$2/$4' --output-document=\'$lno-$imno-$4\'\n";
      $imno++; $line=$next; next;
    }

    if ($url=~ m=(http://photos[0-9]+.blogger.com/[^".]+)/([^"/]+)(.*)=) {
      print STDERR "[$1//$2]\n";
      -r "$lno-$imno-$2" or 
	print "{bl0gger, $lno} '$1/$2' --output-document=\"$lno-$imno-$2\"\n";
      $imno++; $line=$next; next;
    }

    # 1600-h are html version (setting title) of 1600 (that is, non-resized) pictures.
    if ($url=~ m=(http://[a-z0-9.]+blogger.com/[-_][0-9a-zA-Z/_-]+)/s([0-9]+)(\-?h?/)([^".]+.[a-z]+)(.*)=) {
      -r "$lno-$imno-$4" or 
	print "{blogger, $2px, $lno} $1/s$2/$4 --output-document=\"$lno-$imno-$4\"\n";
      $imno++; $line=$next; next;
    }
    if ($url=~ m=(http://[a-z0-9.]+.flickr.com/[^"]+)/([^"/]+)(.*)=) {
      -r "$lno-$imno-$2" or 
	print "{flick, $lno} $1/$2 --output-document=\"$lno-$imno-$2\"\n";
      $imno++; $line=$next; next;
    }
    # this one will catch all pictures, but not hlinks.
    if ($url=~ m#src="(http://[^"]+.[a-z]+)/([^"/]+)(.*)"#) {
      -r "$lno-$imno-$2" or 
	print "{external, $lno} '$1/$2' --output-document=\"$lno-$imno-$2\"\n";
      $imno++; $line=$next; next;
    }
    $line=$next;
  }
}
