#!/usr/bin/perl
# last updated : 2017/06/12 17:22:37 JST
#
# 白衣の英雄を 取得して青空文庫形式に変換する。
# 512kbごとにファイルを分割して保存します。
# Copyright (c) 2017 ◆.nITGbUipI
# license GPLv2
#
# Usage
# ./siroieiyu2aozora.pl
#


use strict;
use warnings;
use LWP::UserAgent;
use utf8;
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $bunkatu = 1; # 512kbごとに分割する。1ファイルで標準出力に出したい場合は 0 にする。

my $url = "http://nemuiyon.blog72.fc2.com/blog-category-2.html"; #index
my $separator = "▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼\n";
my $kaipage = "［＃改ページ］\n";
my $main_title= "白衣の英雄";
my $author = "九重十造";
my $header =  $main_title . "\n" . $author . "\n\n\n";
my $base_name = 'hakui-';
my $bangai_name = "hakui_bangaihen-";
my $title;

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
  $item =   $1;
  $item =~  s|<br />|\n|g;
  $item =~  s|\t\t\t<br>\t\t\t\t<a name=\"more\" id=\"more\"></a>||g;
  $item =~  s|、\n|、|g; #読点での余計な改行を削除
  $item =~  s|《|<<|g; #青空用に置換
  $item =~  s|》|>>|g; #青空用に置換
  $item =~  s|！！|!!|g;
  $item =~  s|！？|!\?|g;
  return $item;
}

sub replace_bangai {
  my $item = shift;
  my @ban;
  foreach my $x (split("\n", $item)) {
	if ($x =~ /^　番外編/) {
	  $x =~ tr/０-９/0-9/;
	  $x =~  s/^(　番外編.+)$/［＃小見出し］$1［＃小見出し終わり］/;
	}
	push(@ban, $x);
  }
  return join("\n", @ban);
}

sub get_book {
  my $i = shift;
  my $base = &get_contents($i);
  utf8::decode($base);
  $title = &get_title($base);
  my $honbun = &get_honbun;
  if ($title =~ /番外編.*/) {
	$honbun = &replace_bangai($honbun);
  }
  my $midasi = "\n［＃中見出し］" . $title . "［＃中見出し終わり］\n\n\n";
  my $item = $kaipage . $separator . $midasi . $honbun . $separator;
  print STDERR $title . " ::取得完了\n";
  return $item ;
}

sub get_all {
  my @index = split('\n', &get_index($url));
  my $count = $#index;
#  my $count = 4; # debug
  for ( my $i = 0; $i < $count; $i++) {
	my $x = &get_book( $index[$i]);
	print $x;
	&split_write( $i, $x);
	sleep 2;
  }
}

sub get_write_all {
  my @index = split('\n', &get_index($url));
  my $count = $#index;
  my $fcount = 1;
  my $bcount = 1;
  my ($FILE, $fh);
  for ( my $i = 0; $i < $count; $i++) {
	my $x = &get_book( $index[$i]);
	if ($title =~ /白衣の英雄.*/) {
	  my $fname = $base_name . sprintf("%03d", $fcount) . ".txt";
	  if ( -f $fname) {
		print $FILE $x;
	  } else {
		open ( $FILE, ">>:utf8" ,"$fname") or die "$!";
		if ($i == 0) { print $FILE $header;}
		print $FILE $x;
	  }
	  my $size = (-s $FILE);
	  if ($size > 512000) {
		close( $FILE );
		$fcount++;
	  }
	} else { # 番外編は別ファイルに書き込む。
	  my $fname = $bangai_name . sprintf("%03d", $bcount) . ".txt";
	  if ( -f $fname) {
		print $fh $x;
	  } else{
		open ( $fh, ">>:utf8" ,"$fname") or die "$!";
		print $fh $x;
	  }
	  my $size = (-s $fh);
	  if ($size > 512000) {
		close( $fh );
		$bcount++;
	  }
	}
	sleep 2;
  }
  close( $FILE );
  close( $fh );
}

#
{
  if ($ARGV[0] =~ m|https?://nemuiyon.blog72.fc2.com/|){
  	print &get_book( $ARGV[0]);
  	exit 0;
  }
  
  if ( $bunkatu == 0 ){
	print $header;
	&get_all;
  } else {
	&get_write_all;
  }
}
