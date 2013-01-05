#!/usr/bin/perl
$blogname=$ARGV[0];

# TODO:
#  single '%' character in filenames (for pictures) needs to be escaped into %25.


open BLOG,"sed -e 's:<category:\\n<category:g;' $blogname|" or die "no $blogname file around?";

%tags=();

print STDERR "grepping $blogname for categories ...\n";
while (<BLOG>) {
  m{<category scheme='http://www.blogger.com/atom/ns#' term='([a-z0-9A-Z&;% ]+)'} or next;
  next if exists $tags{$1};
  print STDERR "[$1]";
  $tags{$1}=$.;
}

close BLOG;
@tags = keys %tags;
print STDERR "$#tags tags identified.\n";

foreach (@tags) {
  $tagname=$_;
  s/[ '%]+/_/g;
  s/&[^;]+;/_/g;
  $ENV{WEBSIZES}=1;
  system "perl list-posts.pl $blogname pictures.data '$tagname' > $_.html";
}
