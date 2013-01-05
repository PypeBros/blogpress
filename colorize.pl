#suited for Weka .xml graph output.


$norm="\x1b[0m"; # normal rendering.
$ign ="\x1b[00;37m"; # grey (discard/ignore)
$high="\x1b[01;32m";
$blink="\x1b[01;33m";
$low="\x1b[01;34m"; # darkblue (low importance)
$ceil="\x1b[01;31m";

while (<>) {
  s:<(/?entry)>:${blink}{$1}$norm:g;
  s:(<[^>]+>):$ign$1$norm:g; # hide structure, focus on content
#  s:&([a-z]+);:$high!$1!$norm:g;
  s:src="([^ ]*)":${high}src="$1"$norm:g;
#  s:&apos;:$high'$norm:g;    # render escaped '
  s:&lt;img([^&]*)&gt;:$high<img$1>$norm:g;   
  s:&lt;e[mn]&gt;(.*?)&lt;/e[mn]&gt;:$low$1$norm:g; # visually truncate long floats
  s:(\.\d\d\d)([5-9]\d+):$1$ceil$2$norm:g;# and help floor/ceiling 
  # s/^(#.*[|]\@.@ FAST[|]\-?\d+)$/$high$1$norm/;
  # s/^(#.*[|]REDIR)$/$low$1$norm/;
  # s/("POST [^"]+)/$blink$1$norm/;
  print;
}
