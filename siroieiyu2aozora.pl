#!/usr/bin/perl
# last updated : 2017/06/10 17:17:12 JST
#
# 白衣の英雄を 取得して青空文庫形式に変換する。
# Copyright (c) 2017 ◆.nITGbUipI
# license GPLv2
#
# Usage
# ./siroieiyu2aozora.pl > 出力ファイル名
#


use strict;
use warnings;
use LWP::UserAgent;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $url = "http://nemuiyon.blog72.fc2.com/blog-category-2.html"; #index
my $separator = "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";

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
  $item = $1;
  $item =~ tr/０-９/0-9/;
  return $item;
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
  print "白衣の英雄\n";
  print "九重十造\n\n\n";
}

#
{
  &ins_header;
  my @index = split('\n', &get_index($url));
  my $count = $#index;
  for ( my $i = 0; $i < $count; $i++) {
	my $bun = &get_contents($index[$i]);
	utf8::decode($bun);
	my $title =  &get_title($bun);
	print "［＃改ページ］\n";
	print $separator;
	print "\n［＃中見出し］" . $title . "［＃中見出し終わり］\n\n\n";
	print STDERR $title . " ::取得完了\n";
	print &get_honbun($bun);
	print $separator;
	sleep 1; # 負荷をかけないように。
  }
}
