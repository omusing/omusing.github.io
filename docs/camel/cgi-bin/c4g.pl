#!/usr/bin/perl
#
# modified to output graphical tiles rather than a numeric value
# set "digit_path" to be the directory where the numeric images
# are stored.  It is assumed that you will have graphics such as
# "0.gif", "1.gif", "2.gif", etc. in this directory.  Also indicate
# the height and width of the images.  If the height and width of
# the digits is variable, then define then comment out the width
# and height lines, by placing a "#" as the first character in 
# each of the lines.
# Some digit sets require the use of a "$left_image" and a
# "$right_image" (such as the real abacus).  If you are using a
# digit set that requires a right and left image, uncomment out
# the "$left_image" and "$right_image" lines by removeing the
# leading comment character, "#".  These images must reside in
# the "$digit_path" directory (unless you want to hack up the
# script for your own liking).  It is assumed that the right
# and left images have the same height and width as the digit
# images.

$digit_path = "/images/digits/bluecali/";
$digit_width = 24;
$digit_height = 24;
# $left_image = "left.gif";
# $right_image = "right.gif";

#
#
#-------------------------------------------------
# c4.pl
# Copyright (C) 1995 Jonathan A. Lewis
#
# Permission to use, copy, and distribute this software and its documentation
# for any non-commercial purpose and without fee is granted
# provided that the above copyright notice appears in all copies.
# Commercial use will likely be granted but requires explicit permission,
# which may be gotten via email to jlewis@inorganic5.chem.ufl.edu.
# 
# This, and the accompanying scripts, is provided "as is" without any express 
# or implied warranty.
#
# Use this script at your own risk.  It's guaranteed to do nothing but
# occupy space...unless your disk crashes, in which case it does nothing
# at all.
#------------------------------------------------
# Version history:
#  c2.pl  First version publicly made available.
#  c3.pl  Same as c2, except instead of hardcoding the user home dir
#	  getpwnam is used to find the user's home dir if the page is a user
#	  page.  This makes c3 much more portable...assuming getpwnam is
#	  supported on the target platform.
#  c3.pl  Just a minor change...get $HTROOT from the envrionment so virtual
#	  servers work properly.  Only known to work in Apache...hardcode
#	  for other servers.
#  c4.pl  c4 now finds and swaps the last .extension for .count...so this
#	  counter can be used for .html, .htm, .whatever files. 	
#
	
require 'lock.pl';

# On larger systems, you may have to actually write code to find 
# exactly where a user's home dir is if getpwnam isn't supported.

$HTROOT=$ENV{'DOCUMENT_ROOT'};		# root dir of current httpd server docs
#$HTROOT='/usr/local/etc/httpd/htdocs'; # use for NCSA
$USERPUB='/usr/local/etc/httpd/htdocs'; # name of html dir in user dirs 
$EXT='.count';          	        # extension to use for count files

### Hopefully, no editing beyond this point will be needed. ###

# If called as an 'exec cmd' server include, you can pass the name 
# of the counter file.  exec cmd is a potential big security hole
# so it's disabled on my server and I use exec cgi.
#
# If called as an 'exec cgi' server include, the script will do its best to
# find the counter file that has the same name as the document, swapping 
# .count for .html 

print "Content-type: text/html \n\n";
if ($ARGV[0] eq "") {
	$file = $ENV{'DOCUMENT_URI'};

	# Convert URI path into a proper path.  The following convert
	#   /dir/doc.html -> $HTROOT/dir/doc.count
	#   /~user/doc.html -> ~user/$USERPUB/doc.count
	#
	if (substr($file,1,1) ne "~") {
		$file = $HTROOT . $file;
	}
	else {
		$file =~m#^/~([^/]+)/(.*)#;
		@user=getpwnam($1);  #may not work on NIS 
		($homedir) = $user[7];
		$file=~s#^(/~[^/]+)(/.*)#$homedir$USERPUB$2#; 
	}

	# resolve symlinks to real files.  There must be a count file 
	# for the real file...not for the symlink name
	# Only resolves one symlink deep.
	# If you don't like this, remove this loop and create a corresponding 
	# symlink for count files for each symlink to a real html file.  
	# This could get messy with lots of symlinks.

	if (-l $file) {
		$dir = $file;
		$dir =~ s#(.*/)[^/]*#$1#;
		$file = $dir . readlink($file);
	}

	# swap extensions
	$file =~ m#.*(\.[^\.]*)$#;
	$file =~ s#$1$#$EXT#;
}

# The counter file must already exist and be writable.  This script won't 
# create new files.
 
if ( -w "$file" ) {  		#is the file writable?
	open (INFILE,"+<$file");
	&lock(INFILE,0); 	#lock and seek to beginning
	$num=<INFILE>;
	seek(INFILE, 0, 0); 	#move back to beginning
	$num++;
	print INFILE "$num            ";
	&unlock(INFILE);
#	print "\n$num\n";
        if ($left_image ne "") {
	  print "<img src=\"$digit_path$left_image\"";
          if (($digit_width ne "") && ($digit_height ne "")) {
	    print " width=$digit_width height=$digit_height ";
          }
          print ">";
        }
        $len = length($num);
        for ($i=0;$i<$len;++$i){
          # $i is indexed to 0 then incremented until the
          # number of digits in $num is reached.
          # then $str is set to 0 and incremented by on digit
          # until $len is reached.
          # Then the .gif extentions is appended to the end os $str.
          # What this relies on is numbered gifs in some accessible
          # directory (ie. 0.gif, 1.gif, 2.gif, ...).
          $str = substr($num,$i,1);
          $str.= ".gif";
	  print "<img src=\"$digit_path$str\"";
          if (($digit_width ne "") && ($digit_height ne "")) {
	    print " width=$digit_width height=$digit_height ";
          }
          print ">";
        }
        if ($right_image ne "") {
	  print "<img src=\"$digit_path$right_image\"";
          if (($digit_width ne "") && ($digit_height ne "")) {
	    print " width=$digit_width height=$digit_height ";
          }
          print ">";
        }
}
else {
        print STDERR "\nError. Count file \"$file\" not writable or non-existant.\n";
}
# Let INFILE close itself when the script terminates
