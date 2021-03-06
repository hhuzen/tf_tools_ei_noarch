use strict;
use Data::UUID;
use Cwd;
use File::Copy;
use File::Path;
use File::Basename;

my $cwd=getcwd();
my $editdir="$cwd/edit";
my $cssdir="$cwd/css";
my $htmldir="$cwd/html";
my $imagedir="$cwd/image";
my $abcdir="$cwd/abc";
my $suzdir="$cwd/suzuki";
my @htmls=();
my @images=();
my $suzimgwidth=50;

#-----------------------------------------------------
# abc2svg
# convert abc to svg
sub abc2svg() {
	if ( ! -d $abcdir ) {
		die "Sorry no abc dir" ;
	}	 
	if ( ! -d "$editdir/abc") { mkpath( [ "$editdir/abc"], 1, 0755) || die; }
	if ( ! -d $imagedir) { mkpath( [ $imagedir], 1, 0755) || die; }
	opendir( MYDIR,$abcdir) || die;
	my @abcfiles=readdir(MYDIR);
	closedir MYDIR;
	for my $e (@abcfiles) {
	    next if ($e =~ /^\./ );
	    next if ( ! -f "$abcdir/$e" );
	    if ($e =~  /\.(abc)$/i ) {
		_doAbc2Svg($e);
		next;
            }
	}
	return 0;
}
my $height=800;
my $width=600;
my $gheight=50;
my $gwidth=50;
my $ixgheight=80;
my $ixgwidth=80;
sub _doAbc2Svg {
	my ($abcfile) = @_;
	my $svg=$abcfile; $svg =~ s/.abc$/-.svg/;
	my $svg001=$abcfile; $svg001 =~ s/.abc$/-001.svg/;
	my $abcpngA=$abcfile; $abcpngA =~ s/.abc$/-A.png/;
	my $abcpng=$abcfile; $abcpng =~ s/.abc$/-.png/;
	my $name=$abcfile; $name =~ s/.abc$//;

	my $need_update=0;
	if ( -f "$imagedir/$name-md.png" ) {
	  my $mod_time_abc = (stat ("$abcdir/$name.abc"))[9];
	  my $mod_time_md = (stat ("$imagedir/$name-md.png"))[9];
	  if ( $mod_time_md > $mod_time_abc ) { 
		  print "$name-md.png: up to date\n";
		  return 0; 
	  }
	} 

	print "abcm2ps: abc/x.abc -> x-.svg\n";
	#
	my $info=`abcm2ps -g \"$abcdir/$abcfile\" -g -i -O \"$imagedir/$svg\" 2>&1` ;
	if ( $? ne 0 ) {
		die "=abcm2ps=error==\n$info\n=\n" ;
	}

	#print "rsvg-convert x.svg -> x-A.png\n";
	system( "rsvg-convert \"$imagedir/$svg001\" > \"$imagedir/$abcpngA\"" ) ;
	if ( $? ne 0 ) {
		die "=convertA=error==\n$info\n=\n" ;
	}

	system( "convert -resize ${height}X${width} -rotate 270 \"$imagedir/$abcpngA\" \"$imagedir/$abcpng\"" ) ;
	if ( $? ne 0 ) {
		die "=convert=error==\n$info\n=\n" ;
	}

	unlink "$imagedir/$abcpngA"; 

	my $imgfile="";
	my $imgext;
	for my $e ( qw (png jpg)) {
		if ( -f "$abcdir/$name.$e" ) {
			$imgfile="$abcdir/$name.$e" ;
			$imgext=$e;
			last;
		}
	}
	if ( -f "$imgfile" ) {
		print "convert abc/x.$imgext -> x.png +270\n";
		system( "convert -resize ${gheight}X${gwidth} -rotate 270 \"$imgfile\" \"$imagedir/$name.png\"" ) ;
		if ( $? ne 0 ) { die; }
		system( "convert -resize ${ixgheight}X${ixgwidth} -rotate 270 \"$imgfile\" \"$imagedir/ix-$name.png\"" ) ;
		if ( $? ne 0 ) { die; }
	}

	if ( -f "$imagedir/$name.png" ) { 
		print "composite x.png + x-.png -> x-md.png\n";
		system( " composite -geometry +10+10 -gravity SouthWest \"$imagedir/$name.png\" \"$imagedir/$name-.png\" \"$imagedir/$name-md.png\" " );
		if ( $? ne 0 ) { die; }
	} else {
		print "copy x-.png -> x-md.png\n";
		system( " cp \"$imagedir/$name-.png\" \"$imagedir/$name-md.png\" " );
		if ( $? ne 0 ) { die; }
	} 

	open( MYFILE, ">$editdir/abc/$name.md" ) || die;

	#print MYFILE "<a href=\"./index.html\">index</a><br/>\n"; 
	#print MYFILE "<img src=\"$name-md.png\" style=\"width:${width}px;height:${height}px;\">\n"; 
print MYFILE "<a href=\"./index.html\"><img src=\"$name-md.png\" style=\"width:${width}px;height:${height}px;\"></a>\n"; 
	close MYFILE;
}


#-----------------------------------------------------
# edit2html
# convert *.md in /edit dir to *html in /html dir
sub edit2html() {
        if ( ! -d $editdir ) {
		print "ERROR: no dir $editdir\n";
		return 1;
	}
	opendir( MYDIR,$editdir ) || die;
	my @editsub=readdir(MYDIR);
	closedir MYDIR;
	for my $e (sort @editsub) {
	  next if ($e =~ /^\./ );

	  next if ( ! -d "$editdir/$e" );
	
	  opendir( MYDIR,"$editdir/$e" ) || die;
	  my @ee= readdir(MYDIR);
	  closedir MYDIR;
	  for my $ee (sort @ee) {
	    next if ($ee =~ /^\./ );
	    next if ( ! -f "$editdir/$e/$ee" );
	    if ($ee =~  /\.(md|markdown)$/i ) {
	        my $base = $ee;
		$base =~ s/\.(md|markdown)$//;

		if ( -f "$htmldir/$base.html" ) {
		  my $mod_time_html = (stat ("$htmldir/$base.html"))[9];
		  my $mod_time_md = (stat ("$editdir/$e/$ee"))[9];
		  if ( $mod_time_html > $mod_time_md ) { 
			  print "$base.html: up to date\n";
			  next;
		  }
		} 
                my $pt="$base" ;	
                #print " HHHHH do pandoc $e/$ee\n" ;
		system "pandoc --metadata pagetitle=\"$pt\" -s \"$editdir/$e/$ee\" -t html -o \"$htmldir/$base.html\"" ;
	        push @htmls, "$htmldir/$base.html;$e" ;
		next;
            }

	    next if ( $ee !~ /.txt$/ );
	    $ee =~ s/.txt$//;
	    copy2html("$editdir/$e/$ee.txt", "$htmldir/$ee.html");
	  }
	}

	if ( ! -d $imagedir) { mkpath( [ $imagedir], 1, 0755) || die; }

	opendir( MYDIR,$imagedir ) || die;
	my @imagesub=readdir(MYDIR);
	closedir MYDIR;
	for my $e (@imagesub) {
	  next if ($e =~ /^\./ );
	  if ( -f "$imagedir/$e" ) {
	    	copy("$imagedir/$e", "$htmldir/$e");
		next;
	  };
	
	  next if ( ! -d "$imagedir/$e" );
	
	  opendir( MYDIR,"$imagedir/$e" ) || die;
	  my @ee= readdir(MYDIR);
	  closedir MYDIR;
	  for my $ee (@ee) {
	    next if ($ee =~ /^\./ );
	    next if ( ! -f "$imagedir/$e/$ee" );
	    copy("$imagedir/$e/$ee", "$htmldir/$ee");
	  }
	}

	copy("$cssdir/style.css", "$htmldir/style.css");
	copy("$cssdir/blitz.css", "$htmldir/blitz.css");
	return 0;
}


#-----------------------------------------------------
# copy2html
sub copy2html {
	my $txt=shift;
	my $html=shift;
	open( TXT, "$txt") || die;
	push @htmls, $html;
	open( HTML, ">$html") || die;
	print HTML "<html>\n";
 	print HTML "<head>\n";
	print HTML "<meta charset=\"utf-8\" />\n";
	print HTML "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"/>\n";
	print HTML "<link rel=\"stylesheet\" type=\"text/css\" href=\"blitz.css\"/>\n";
	print HTML "</head>\n";
	print HTML "<body>\n";
	my $cnt=0;
	while (my $line = <TXT>) {
		$cnt++;
		chomp $line;
		# conversions
		## pap-vertel-eens
		if ($line =~ /^\[.*\]/) {
			my $class=$line;
			$class =~ s/.*\[//;
			$class =~ s/\].*//;
			$line =~ s/.*\]\s*//;
			my $htxt="h3";
			if ($class eq "hoofdstuk" ) { $htxt="h1"; }
			if ($class eq "onderwerp" ) { $htxt="h2"; }
			if ($class eq "voorwoord" ) { $htxt="h1"; }

			$line = "<$htxt class=\"$class\">$line</$htxt>";
		}
		my $line_prefix='';
		my $line_suffix='';
	
my $kill=100;	
		if ($line =~ /\{(plaatje|linkje).*\}/) {
		   my $oline=$line;
		   $line='';
		   while ($oline =~ /\{(plaatje|linkje).*\}/) {
if ( $kill-- <0 ) { die "runaway!"; }
			my $pre=$oline; $pre =~ s/\{.*//;
			my $mid=$oline; $mid =~ s/^[^\{]*\{//; $mid =~ s/\}.*//;
			my $suf=$oline; $suf =~ s/^[^\{]*\{[^\}]*\}//; 
			$line.=$pre;
			$oline=$suf;

#print ("HH pre=$pre mid=$mid suf=$suf\n");

			my $class=$mid;	$class =~ s/:.*//g;
			my $nline='';	
			my $eline='';	
			if ( $class =~ /plaatje/ ) {
				my $img = $mid;
				$img=~ s/^[^:]*:\s*//; $img =~ s/\s*$//;
		   		$line_prefix ="<div class=\"images\">"; 
		   		$line_suffix ="</div>"; 
				if ( ! -e "$imagedir/$img" ) {
					print "Missing image: $img\n";
				}
				push @images, $img;
				$img =~ s/.*\///;
				$nline = "<img class=\"$class\" alt=\"$img\" src=\"$img\" />";
			} elsif ( $class =~ /linkje/ ) {
				my $ref = $mid;
				$ref=~ s/^[^:]*:\s*//; $ref =~ s/\s*$//;
				my $href=$ref;
				my $htxt=$ref;
				if ( $htxt =~ /\|/ ) {
					$htxt=~ s/.*\|//;
					$href=~ s/\|.*//;
				} else { 
					print "Missing linktxt: {$mid}\n";
					$htxt=$ref;
				}
				#$nline = "<a class=\"linkje\" href=\"$href\" />$htxt</a>";
				$nline = "<a class=\"linkje\" href=\"$href\" />&lt;&lt;$htxt&gt;&gt;</a>";
			} else {
				$eline = "Unknown class in {$mid}";
				print "$txt\[$cnt\] $eline\n";
			}
			$line .= $nline;
#			print "$txt\[$cnt\] $nline\n";
		   }
		}
		$line = $line_prefix.$line.$line_suffix;
		#
		if ( $line ) { 
			print HTML  "$line<br/>\n"  
		} else {
			print HTML "<p>";
		} 
	}
	print HTML "</body>\n";
	print HTML "</html>\n";
	close HTML;
	close TXT;
}
	

my @ix_files=();
my %ix_file_to_key=();
my %ix_file_to_level=();
my %ix_file_to_title=();
my @act_files=();
my %act_file_to_key=();
my %act_file_to_level=();
my %act_file_to_title=();

#-----------------------------------------------------
# make index.html
# mkIndex
sub mkIndex() {
	open ( CMD, "find edit -type f|") || die " $!" ;
  	my @list=<CMD>;
	close CMD;
	for my $md (sort @list) {
		next if ( $md !~ /\.md$/);	
		chomp $md;
		_mkIndexDoFile( $md );
 	} 
	open ( INDEX, ">index.lst") || die " $!" ;
	my $lastdir=""; 
	for my $f ( sort @act_files ) {
		my $dir= dirname($f);
		if ( $dir ne $lastdir ) { print INDEX "\n" ; }
		$lastdir=$dir;
		printf INDEX "%-80s;%-4s;%-4s;%s\n", $f, 
			$act_file_to_key{$f},
			$act_file_to_level{$f},
			$act_file_to_title{$f},
			;	
	}
	close INDEX;
	system "cat index.lst" ;
	_mkIndexHtml();
	unlink "index.lst" ;
}
sub getTime {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime();
    my $nice_timestamp = sprintf ( "%d-%d-%04d",
                                   $mday, $mon + 1, $year+1900);
    return $nice_timestamp;
}

# _mkIndexHtml
sub _mkIndexHtml {
	my $date=getTime();
	my $cwd=getcwd();
        my $cssdir="$cwd/css";
        my $htmldir="$cwd/html";
        my $imagedir="$cwd/image";
	open( HTML, ">$htmldir/index.html") || die;
	print HTML "<html>\n";
 	print HTML "<head>\n";
	print HTML "<meta charset=\"utf-8\"\n";
	print HTML "<link rel=\"stylesheet\" type=\"text/css\" href=\"blitz.css\"></link>\n";
	print HTML "<title>Inhoud</title>\n";
	print HTML "</head>\n";
	print HTML "<body>\n";
	print HTML "<h1>Inhoud</h1>\n";

	my $lix="" ;
	my $cnt=0;
	my $subcnt=0;

	print HTML "<ul>\n";

	for my $f ( sort @act_files ) {
		my $indeximage="";
		my $html=$f;
		my $title=$act_file_to_title{$f};
	
		$cnt++;
		my $dir=dirname($html); 
		$html =~ s/;.*//;
		my $base=basename($html);
		$base =~ s/.html$//;
		my $png=$base.".png" ; 
		$png =~ s/\.md\./\./g;
		$base =~ s/[_-]/ /g;
                #print " HH $png\n" ;
		if ( -f "$imagedir/ix-$png"  ) {
                  #print " HH bingo ix-$png\n" ;
			$indeximage="./ix-$png" ;
		}
		my @f= split / /,$base;
		my @t=@f;
		while ( $t[0] && $t[0] =~ /^\d/) { shift @t; }

		my $xtitle="$title";
		my $xpand="";
		my $l=length($title);
		my $SIZE=20;
		if ($l > $SIZE ) { $xtitle = substr($title,0,$SIZE); }
		while ($l < $SIZE) { $xpand .= "&nbsp;"; $l++; }

		$html=basename($html);
		$html=~ s/.md$/.html/;
	        if ( $lix ne $dir ) {  # new main
		  if ($cnt > 1) { print HTML "</ul></li>\n"; }
		  if ($indeximage) {
		    print HTML "<li><a href=\"$html\">$xtitle<a>$xpand<a href=\"$html\"><img src=\"$indeximage\"><a>\n"; 
	    	  } else {
		     print HTML "<li><a href=\"$html\">$title<a>\n";
	          }
	          print HTML "<br/>\n";
	          print HTML "<ul>\n";
		  if ( ! $ENV{INDEX_TYPE} || $ENV{INDEX_TYPE} != "flat" ) {
		  	$lix= $dir;
	          } 
		   
		} else { 		 # continue main
		     print HTML "<li><a href=\"$html\">$title<a></li>\n";
		}
	}	

	if ($cnt > 1) { print HTML "</ul></li>\n"; }
	print HTML "</ul>\n";
	print HTML "<p>\n";
	print HTML "<small>versie datum: $date</small>\n";
	print HTML "</body>\n";
	print HTML "</html>\n";
	close HTML;
}
	
sub _mkIndexDoFile($) {
	my ($f)=@_;
	push @act_files,$f;
	open(FILE,$f)|| die;
	my @e=<FILE>;
	close FILE;
	for my $e (@e) {
		if ($e =~ /^#/) {
			chomp $e;
			$e =~ s/!.*[\)\}]//;
			my $level=$e;
			$level=~ s/^\s*//;
			$level=~ s/[^#].*//;
			my $title=$e;
			$title=~ s/#//g;
			$title=~ s/^\s*//;
			my $key="?";
			if ( $act_file_to_title{$f} )  {
				print "double!\n";
			} else {
				$act_file_to_key{$f}=$key;
				$act_file_to_level{$f}=$level;
				$act_file_to_title{$f}=$title;
			}
			last;
		}
	}
	if ( !$act_file_to_title{$f} ) {
	   	my $title=$f; 
	   	$title=~ s/.*\///g;
	   	$title=~ s/\..*//g;
		$act_file_to_key{$f}="?";
		$act_file_to_level{$f}="?";
	   	$act_file_to_title{$f}=$title;
	}
}

#-----------------------------------------------------
# abc2suz
# convert abc to suzuki mouthharp
sub abc2suz() {
	if ( ! -d $abcdir ) {
		die "Sorry no abc dir" ;
	}	 
        system( "rm -rf $suzdir" );
	if ( ! -d "$suzdir") { mkpath( [ "$suzdir"], 1, 0755) || die; }
	opendir( MYDIR,$abcdir) || die;
	my @abcfiles=readdir(MYDIR);
	closedir MYDIR;
	for my $e (@abcfiles) {
	    next if ($e =~ /^\./ );
	    next if ( ! -f "$abcdir/$e" );
	    if ($e =~  /\.(abc)$/i ) {
		_doAbc2Suz("$e");
		next;
            }
	}
	return 0;
}

my %l2h=(
  "A" => "a",
  "B" => "b",
  "C" => "c",
  "D" => "d",
  "E" => "e",
  "F" => "f",
  "G" => "g",
  "a" => "ax",
  "b" => "bx",
  "c" => "cx",
  "d" => "dx",
  "e" => "ex",
  "f" => "fx",
  "g" => "gx",
  "ax" => "axx",
  "bx" => "bxx",
  "cx" => "cxx",
  "dx" => "dxx",
  "ex" => "exx",
  "fx" => "fxx",
  "gx" => "gxx",
);

sub _doAbc2Suz($) {
  my ($bare)=@_;
  $bare=~ s/.abc$//;
  my $abc="$abcdir/$bare.abc"; 
  my $ltag="OK";
  my $htag="OK";
  our @suzLow=();
  our @suzHigh=();
  my $intable=0;

  my $imageext="";
  for my $e ( qw( png PNG jpg JPG jpeg JPEG svg SVG )) {
   if ( -f "$abcdir/$bare.$e" ) { $imageext=$e; last; }
  }

  sub addline($) {
      my $xl=shift;
      push @suzLow, $xl;
      push @suzHigh, $xl;
  }

  sub addnote($$) {
      my $notelow=shift;
      my $notehigh=shift;
      push @suzLow, "<td><img src=\"../suzuki-images/suzuki-$notelow.png\" height=\"32px\" ></td>";
      push @suzHigh, "<td><img src=\"../suzuki-images/suzuki-$notehigh.png\" height=\"32px\" ></td>";
  }
  addline "<html>\n";
  addline "<body>\n";

  open ABC,$abc || die "cannot open $abc : $!" ;
  my @abc = <ABC>;
  close ABC;
  my $key="?";
  for my $l (@abc) {
    chomp $l;
    #print "l $l\n" ;
    next if ( $l =~ /^[\%MLXS]/i );
    if ( $l =~ /^K:/i) {
      $key=$l;
      $key =~ s/\%.*//i;
      $key =~ s/^K: *//i;
      next;
    }
    if ( $l =~ /^T:/i ) {
      $l =~ s/^T: *//i;
      addline ("<h1>$l") ;
      if ( $imageext ) {
        addline ("&nbsp;&nbsp;<img src=\"../abc/$bare.$imageext\" height=\"${suzimgwidth}px\"/>" );
      }
      addline ("</h1>\n") ;
      next;
    }
    if ( $l =~ /^w:/i ) {
      $l =~ s/^w: *//i;
      $l =~ s/-/- /g;
      if ( $l =~ /^[ ~]*$/ ) { next; } 
      addline ("<tr>\n")  ;
      for my $c ( split / +/,$l) {
        addline ("<td align=\"center\">$c</td>") ;
      }
      addline ("</tr>\n") ;
      next;
    }

    # must be line of notes
    #
    $l=~ s/[ \|`\/]//g;
    $l=~ s/"[^"]*"//g;
    $l=~ s/![^!]*!//g;
    $l=~ s/[0-9]//g;
    #print " HHH $l\n" ;
    $l=~ s/[^a-g,A-G,']//g;
    #print " HHHo $l\n" ;

    next if ( $l =~ /^[ \|]*$/ );
    my @c=( split //,$l);
    my @notes=();
    my $i=0;
    my $j=-1;
    while ( $i < @c ) {
      if ( $c[$i] =~ /^ *$/) {

      } elsif ( $c[$i] eq "'" ) {
        $notes[$j] .= "x";
      } else {
        $j++;
        $notes[$j] = $c[$i];
      }
      $i++;
    }
    if ($intable) { addline ("</table>\n") ; }
    addline ("<br/>\n") ;
    addline ("<table>\n") ;
    $intable=1;
    addline ("<tr>\n") ;
    for my $c ( @notes ) {
      if ( $c =~ /^(x|F|A|bx|dxx|exx|fxx|gxx|axx|bxx)$/ ) { $ltag="NOK"; };
      my $hc=$l2h{$c} || 'x' ;
      if ( $hc =~ /^(x|F|A|bx|dxx|exx|fxx|gxx|axx|bxx)$/ ) { $htag="NOK"; };
      addnote $c, $hc;
    }
    addline ("</tr>\n") ;
  }
  if ($intable) { addline ("</table>\n") ; }
  addline "</body>\n" ;
  addline "</html>\n" ;

  my $html="$suzdir/$ltag-$bare-$key-low.html" ;
  open HTML,">$html"  || die "cannot open $html : $!" ;
  print HTML @suzLow;
  close HTML;

  $html="$suzdir/$htag-$bare-$key-high.html" ;
  open HTML,">$html"  || die "cannot open $html : $!" ;
  print HTML @suzHigh;
  close HTML;
}


### main
my $command=$ARGV[0];
if ($command eq "edit2html") { edit2html(); mkIndex(); exit();}
if ($command eq "abc2svg") { exit abc2svg; }
if ($command eq "abc2suz") { exit abc2suz; }
print "H??h? What $command\n";
exit(1);


