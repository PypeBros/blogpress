# tool for rendering blog posts from a .xml backup into HTML documents, 
#  name the different tags you want to extract.
# author: Sylvain 'Pype' Martin (http://sylvainhb.blogspot.com)
#   free for use, no guarantees of any kind. Improvements and feedbacks
#   are welcome at pype_1999.geo@yahoo.com
use Date::Format;
use Date::Parse;


print <<___
<html><head>
<meta content='text/html; charset=UTF-8' http-equiv='Content-Type'/>
</head><body>
___
;

$mode='OR';
#$mode='AND';
@title=@ARGV;
shift @title;
shift @title;
print "<h1> @title </h1>\n";

$#ARGV>=2 or die "usage: list-posts.pl <blog.xml> <pictures.data> <tag> [more tags] > output.html\n((@ARGV))";
# pictures.data is the output of scan-for-pictures.pl and tells which URLs are images 
#  that need embedding in the document.

$blogname=shift @ARGV;
open PIXMAP,"<$ARGV[0]";
while (<PIXMAP>) {
  /\{[^,]+, (\d*)p?x?,? ?\d+\} '?([^' ]+)'? --output-document=['"](\d+-\d+-)([^'"]+)['"]/
    or die "cannot parse $_";
  my (       $sz,                 $url,                             $pfx,    $pn)=
    ($1,$2,$3,$4);
  $pn=~s/%/%25/g;
  $pix{$url}="$pn";
  $larger{$pn}=$pfx if $1==1600;
  $larger{$pn}=$pfx unless (exists $larger{$pn} && !exists $ENV{WEBSIZES});

  # associate "large" pictures with "smaller" pictures whenever possible.
}
close PIXMAP;


# blogger's exported content has no 'newline'. Let's create some, one per entry, exactly.
# (that assumes no <entry> tag appears recursively in the structure).
open BLOG,"sed -e 's:<entry>:\\n<entry>:g;' $blogname|" or die "no $blogname file around?";

foreach my $key (1..$#ARGV) {
  $wanted{$ARGV[$key]}=$key;
}

%esc=(lt=>'<',gt=>'>',amp=>'&',quot=>'"',apos=>"'"
      );

while ($_=<BLOG>) {
  $lno++;
  $imno=1;
  $match=0;
  $all=$_;
  $tags='';
  $title=$1 if m:<title [^<>]*>([^<]+)</title>:;
  @trucs=split /</;
  foreach $t (@trucs){
    next if $t=~ /term='http/;
    next unless $t=~ /^category/;
    $t =~ s:category [^ ]* term='(.*)'/>:$1:;
    $alltags{$t}=$title;
    $tf = $t;
    $tf =~ s/[ '%]+/_/g;
    $tf =~ s/&[^;]+;/_/g;
    $tags.= "[<a href=\"$tf.html\">$t</a>]";
    $match++ if exists $wanted{$t};
  }

  print STDERR "#" unless $matches==0;
  if ($mode eq 'AND') {
    next unless $match==$#ARGV; #&& $mode eq 'AND';
  } else {
    next unless $match>0; # && $mode eq 'OR';
  }
  $date=$1 if m:<published>([^<]+)</published>:;
  $time=str2time($date);
  $date=~ s/(.*)T(.*)/$1/;

  $all=~ m:<content type='html'>(.*)</content>:;
  $post=$1;
#   foreach(keys %esc){
#     $post=~s/&$_;/$esc{$_}/g;
#   }
  $post=~s/&([a-z]+);/$esc{$1}/g;
  $post=~s/src=\"([^"]+)"/src="$larger{$pix{$1}}$pix{$1}" alt="$1 ; $pix{$1}"/g;
  $post=~s/width: \d+px//g;
  $post=~s/height: \d+px//g;
  $post=~s/width=['"]\d+['"]//g;
  $post=~s/height=['"]\d+['"]//g;
  
  # comment out all content between <en>...</en> tags or <em>...</em>
  # (alternate language)  
  if (! exists $ENV{WITHENGISH}) {
    $post=~s:<e[mn]>:<!--:g;
    $post=~s:</e[mn]>:-->:g;
  }
  $post{$time}="<h3>$title</h3>\n$post\n<hr><small>($date) $tags</small>\n";
}

@keys=sort {$a <=> $b} keys(%post);
foreach (@keys){
  print $post{$_};
}

if (!@keys) {
  @keys=keys(%alltags);
  print "no post found for tags @ARGV\n";
  print "available tags: @keys\n";
}

print "</body></html>\n";
print STDERR "done with @title\n";
