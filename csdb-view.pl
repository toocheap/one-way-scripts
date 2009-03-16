$dbfile = $ARGV[0];
$file_size = -s $dbfile;

$data_point = 18;	#バイトセット バージョンID(10) + データサイズ(4) + レコード数(4)

#DBファイルオープン
open(fp, "< $dbfile");

binmode fp;
read fp, $buf, $file_size;

#バージョンID(10) + データサイズ(4) + レコード数(4) 取得
$version = &version_get;
$data_size = &data_size_get;
$record_cnt = &record_cnt_get;


$head_size = $record_cnt * 3 + 18;
$head_point = 0;
$data_buf = substr($buf, $head_size, $file_size);


#変換マップ 16進
%map = (
'00','',  '01','a', '02','b', '03','c', '04','d', '05','e', '06','f', '07','g', '08','h', '09','i',
'0a','j', '0b','k', '0c','l', '0d','m', '0e','n', '0f','o', '10','p', '11','q', '12','r', '13','s',
'14','t', '15','u', '16','v', '17','w', '18','x', '19','y', '1a','z', '1b','-', '1c','/', '1d','\\',
'1e','_', '1f','.', '20','!', '21','~', '22','*', '23','\'', '24','(', '25',')', '26','%', '27',';',
'28',':', '29','&', '2a','=', '2b','+', '2c','$', '2d',',', '2e','@', '2f','?', '30','0', '31','1',
'32','2', '33','3', '34','4', '35','5', '36','6', '37','7', '38','8', '39','9', '3a','#', '3b','[',
'3c',']', '3d','<', '3e','>', '3f','^', '40','`', '41','"', '42','{', '43','}', '44','|'
);

print "DB VERSION   : $version\n";
print "DATA SIZE    : $data_size\n";
print "TOTAL RECORDS: $record_cnt\n";

for $i (1..$record_cnt){
	($dom_size, $phead_size, $path_size) = unpack "x$data_point C C C", $buf;
	$data_head_out = "$dom_size".","."$phead_size".","."$path_size";
	$data_point += 3;
	
	($cate_no,$proto,$dom1,$dom2,$dom3,$dom4,$port) = unpack "x$head_point v c c c c c v", $data_buf;
	$head_point += 9;

	$bits_tmp = $dom_size * 8;

	&bit_hex;
	$hostname = "";
	for $a (@hex){
		$hostname .= $map{$a};
	}
	&dom_split;
	$head_point += $dom_size;



	@path_head = unpack "x$head_point C$phead_size", $data_buf;
	$path_head_out = "";
	for( 0..@path_head -1 ){
		if(@path_head -1 eq $_){
			$path_head_out .= "$path_head[$_]";
		}
		else{
			$path_head_out .= "$path_head[$_]".",";
		}
	}
	$head_point += $phead_size;

	$bits_tmp = $path_size * 8;
	&bit_hex;
	$pathname = "";
	for $a (@hex){
		$pathname .= $map{$a};
	}
	&path_split;


	$head_point += $path_size;


	print "$data_head_out\t$cate_no\t$proto\t$dom1\t$dom2\t$dom3\t$dom4\t$port\t$fqdn\t$path\t$path_head_out\n";
}


close(fp);


sub path_split{
	$path_len = length("$pathname");
	$sp_point = 0;
	$path = "";
	for(1..$phead_size){
		if($path_head[$_] gt 0){
			$path .= "/" . substr($pathname,$sp_point,$path_head[$_]);
			$sp_point += $path_head[$_];
		}
		elsif($path_head[$_] eq 0){
			if("$path_head[0]" > "$_"){
				$path .= "/";
			}
		}
	}
	$hoge = $path_head[$phead_size - 1];

	$amari = $path_len - $sp_point;
	$tmp = substr($pathname,$sp_point,$amari);
	if($tmp =~ /\.||\?/){
	#	if($tmp){
		$path .= "/" . "$tmp";
	#	}
	}
	elsif($path_len ne $sp_point){
		$path .= "/" . "$tmp";
	}
	if($path eq "/"){
		$path = "";
	}
	if($hoge ne 0){ $path =~ s/\/$//g; }

#	if($path_len ne $sp_point){
#		$amari = $path_len - $sp_point;
#		$path .= "/" . substr($pathname,$sp_point,$amari);
#	}
}
		

sub dom_split {
	$fqdn = "";

	$sp_point = $dom1 + $dom2 + $dom3 + $dom4;
	$end = length($hostname) - $sp_point;
	$other = substr($hostname,$sp_point,$end);
	if($other){
		@dom_tmp = split(/\./,$other);
		$x = @dom_tmp;
		$z = $x - 1;
		for(1..$x){
			if($dom_tmp[$z] ne ""){
				$fqdn .= "$dom_tmp[$z]" . ".";
				$z--;
			}
		}
	}
	if($dom4){
		$sp_point = $dom1 + $dom2 + $dom3;
		$fqdn .= substr($hostname,$sp_point,$dom4) . ".";
	}
	if($dom3){
		$sp_point = $dom1 + $dom2;
		$fqdn .= substr($hostname,$sp_point,$dom3) . ".";
	}
	if($dom2){
		$sp_point = $dom1;
		$fqdn .= substr($hostname,$sp_point,$dom2) . ".";
	}
	if($dom1){
		$sp_point = 0;
		$fqdn .= substr($hostname,$sp_point,$dom1);
	}
	
}

sub bit_hex {
	$bits = unpack "x$head_point B$bits_tmp", $data_buf;
	$dom_len = int ($bits_tmp / 7);
	@hex = "";
	$bit_point = 0;
	for (1..$dom_len){
		$sin = "0" . substr($bits,$bit_point,7);
		$bit_point += 7;
		push @hex, unpack "H2", pack "B8", $sin;
	}
	
}

sub version_get {
	return unpack "a10", $buf;
}

sub data_size_get {
	return unpack "x10 V", $buf;
}

sub record_cnt_get {
	return unpack "x14 V", $buf;
}

