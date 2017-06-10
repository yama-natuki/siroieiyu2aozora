#!/usr/bin/perl
# last updated : 2017/06/10 12:05:25 JST
#
#
#
use strict;
use warnings;
use LWP::UserAgent;
use utf8;
binmode STDOUT, ":utf8";

my $url = "http://nemuiyon.blog72.fc2.com/blog-category-2.html"; #index

sub get_contents {
  my $address = shift;
  my $http = LWP::UserAgent->new;
  my $res = $http->get($address);
  my $content = $res->content;
  return $content;
}

#my $index = &get_contents( $url );
use Perl6::Slurp; # http://d.hatena.ne.jp/minesouta/20071204/p1
my $index = slurp('/tmp/test.html');
utf8::decode($index);
$index =~ s|^.+第一部</span>|第一部|s;
$index =~ s|<div class=\"fc2_footer.+$||s;
my $mokuji = $index;
# 見出し list
$index =~ s|<br />　<br />|<br />|g;
$index =~ s|<br />|\n|g;
$index =~ s| +<br>||g;
$index =~ s|<a href=.+?>||g;
$index =~ s|<span style=\"font-size:large;\">||g;
$index =~ s|</span>||g;
$index =~ s|</a>||g;
$index =~ s|\n\n|\n|g;
$index =~ tr/０-９/0-9/;
print $index . "\n";

# url list
$mokuji =~ s|<a href|\n<a href|g;
$mokuji =~ s|第一部.+\n||;
$mokuji =~ s|<a href=\"([^\"]*)\".*|$1|g;
#print $mokuji;

my $book = slurp('/tmp/book.html');
utf8::decode($book);

sub get_title {
  my $item = shift;
  $item =~  m|.*entry_title\">(.+)</td>.*|;
  return $1;
}

sub get_honbun {
  my $item = shift;
  $item =~  m|.+main_txt\">(.+)<div class.+|;
  my $honbun = $1;
  $honbun =~  s|<br />|\n|g;
  $honbun =~  s|\t\t\t<br>\t\t\t\t<a name=\"more\" id=\"more\"></a>||g;
  $honbun =~  s|《|<<|g; #青空用に置換
  $honbun =~  s|》|>>|g; #青空用に置換
  return $honbun;
}

sub ins_header {
  printf( "%s",  "［＃５字下げ］［＃窓大見出し］白衣の英雄［＃窓大見出し終わり］\n");
  printf( "%s", "■■■■■■■■■■■■■■■■■■■■■■■■■■\n\n");
#insert $s2;
  printf( "%s", "■■■■■■■■■■■■■■■■■■■■■■■■■■\n");
}

#
{
  print "\n";
  print &ins_header;
  print "［＃改ページ］\n";
  print "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";
  print "\n［＃中見出し］" . &get_title($book) . "［＃中見出し終わり］\n\n\n";
  print &get_honbun($book);
  print "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";
}
