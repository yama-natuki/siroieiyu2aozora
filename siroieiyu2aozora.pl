#!/usr/bin/perl
# last updated : 2017/06/10 13:40:50 JST
#
#
#
use strict;
use warnings;
use LWP::UserAgent;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $url = "http://nemuiyon.blog72.fc2.com/blog-category-2.html"; #index

sub get_contents {
  my $address = shift;
  my $http = LWP::UserAgent->new;
  my $res = $http->get($address);
  my $content = $res->content;
  return $content;
}

sub get_index {
  my $address = shift;
  my $index = &get_contents( $address );
  #my $index = slurp($address);
  utf8::decode($index);
  $index =~ s|^.+第一部</span>|第一部|s;
  $index =~ s|<div class=\"fc2_footer.+$||s;
  $index =~ s|<a href|\n<a href|g;
  $index =~ s|第一部.+\n||;
  $index =~ s|<a href=\"([^\"]*)\".*|$1|g;
  return $index;
}

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
  $honbun =~  s|、\n|、|g; #読点での余計な改行を削除
  $honbun =~  s|《|<<|g; #青空用に置換
  $honbun =~  s|》|>>|g; #青空用に置換
  return $honbun;
}

sub ins_header {
  printf( "%s", "白衣の英雄\n");
  printf( "%s", "九重十造\n\n\n");
}

#
{
  print &ins_header;
  my @index = split('\n', &get_index($url)); # url list
  for ( my $i = 0; $i < 5; $i++) {
	my $bun = &get_contents($index[$i]);
	utf8::decode($bun);
	my $title =  &get_title($bun);
	print "［＃改ページ］\n";
	print "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";
	print "\n［＃中見出し］" . $title . "［＃中見出し終わり］\n\n\n";
	print STDERR $title . " ::取得完了\n";
	print &get_honbun($bun);
	print "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";
	sleep 1; # 負荷をかけないように。
  }
}
