#!/usr/bin/perl
###################################################################
## Form-To-EMail Version 1.4 - 07/22/98                          ##
## ------------------------------------------------------------- ##
## Copyright (C) 1998 Dimension's CGI Workshop                   ##
## http://www.thenetnow.com/dimension                            ##
## dimension@cybered.net                                         ##
## ------------------------------------------------------------- ##
## This script is freeware and may not be sold in any way.  If   ##
## you would like to make changes to this script, please EMail   ##
## me and ask for my permission before doing so.  Once recieving ##
## my permission, this notice must remain in place.              ##
###################################################################

###############################################
### ****** CUSTOMIZE THESE VARIABLES ****** ###
###############################################
# Name (and location if necessary) of the server's mail program
$mailprog = 'sendmail';
###############################################

###############################################
### ***** DO NOT EDIT BELOW THIS LINE ***** ###
###############################################

# Get the input
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

# Split the name-value pairs
@pairs = split(/&/, $buffer);

foreach $pair (@pairs) {
   ($name, $value) = split(/=/, $pair);
   $name =~ tr/+/ /;
   $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $name =~ s/<!--(.|\n)*-->//g;
   $name =~ s/<([^>]|\n)*>//g;
   $value =~ tr/+/ /;
   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $value =~ s/<!--(.|\n)*-->//g;
   $value =~ s/<([^>]|\n)*>//g;
   $FORM{$name} = $value;
}

# READ HIDDEN VARIABLES FROM FORM

$subject = $FORM{subject};
$to = $FORM{to};
$from = $FORM{from};
$followupurl = $FORM{followupurl};

# Open the mail program
open(MAIL,"|$mailprog -t");

# Send the mail program the EMail message
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n";
print MAIL "\n";
print MAIL "---------------------------------------------------------------------\n";

foreach $key (keys(%FORM)) {
   if ($key ne "subject" && $key ne "to" && $key ne "from" && $key ne "followupurl") {
      print MAIL "$key: $FORM{$key}\n";
   }
}

print MAIL "---------------------------------------------------------------------\n";
print MAIL "Form-To-EMail version 1.4\n";
print MAIL "(C) Dimension's CGI Workshop - http://www.thenetnow.com/dimension/\n";

# Close the mail program
close(MAIL);

# Forward to the Follow-up URL
print "Location: $followupurl\n\n";
