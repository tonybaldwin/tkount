#!/usr/bin/env wish

# by marc prior
# contributor tony baldwin

global DIR
set DIR [pwd]
bind . <Escape> exit

# Sets window title
wm title . {TKount File Count Utility}

# Creates and packs a main frame for the GUI
frame .mf
pack .mf -expand true -fill both

# Creates and packs menubar
frame .mf.mbar
pack .mf.mbar -side top -fill x

# Creates menu buttons
button .mf.mbar.select -relief raised -text {Select file(s) for counting} -underline 0 -command select
button .mf.mbar.totals -relief raised -text {Calculate totals} -underline 0 -command totals
button .mf.mbar.cleard -relief raised -text {Clear display} -underline 0 -command cleard
button .mf.mbar.exit -relief raised -text {Quit} -underline 0 -command exit

pack .mf.mbar.select -side left
pack .mf.mbar.totals -side left
pack .mf.mbar.cleard -side left
pack .mf.mbar.exit -side left

# Text widget (text field) for output of results
text .mf.t -bg white
# text .mf.t -width 80 -height 20 -bg white
pack .mf.t -expand true -fill both


# Procedure for clearing display
proc cleard {} {

global alinecount
global awordcount

# Clears display
.mf.t delete 1.0 end

# Clears arrays
unset alinecount
unset awordcount

}

# Procedure for converting selected file to 
# plain-text file using Abiword/pdftotext
proc convert { fn } {

global file4charcnt

# Detects file extension
# Converts file to plain text using Abiword or 
# pdftotext, depending upon file extension
set fnext [file extension $fn]

if { $fnext == ".pdf" } then {

exec pdftotext $fn } else {

# was: exec abiword -v=2 --to=txt $fn
exec abiword --to=txt $fn

	}

set fileroot [file rootname $fn]
set extns {.txt}

set file4charcnt $fileroot$extns

}

# Procedure for counting number of keystrokes
# or multiples thereof
proc countks { file4charcnt } {

global keystrokes
global nz
global selfile
global alinecount

# Reads created plain-text file, counts number of characters, 
set filnm [open $file4charcnt r+]
set filtxt [read $filnm]
set keystrokes [string length $filtxt]

# divides by selected factor (default: 55 for 
# standard German lines)
# Change 55 for a different count number
# e.g. 60 for standard lines (Belgium)
# 1500 for cartelle (Italy)
# 1800 for cartelle commerciali (Italy)

set nz [expr $keystrokes / 55]

# Stores line count in array
set alinecount($selfile) $nz

}

# Procedure for counting number of words
proc countwords { file4charcnt } {

global wrds
global wordstext
global selfile
global awordcount

set filnm [open $file4charcnt r+]
set filtxt1 [read $filnm]

# Removes spaces within numbers
# (e.g. 123 456 789 becomes 123456789)
set pat1 {([0-9])([.,\s])+([0-9])}
regsub -all $pat1 $filtxt1 {\1\3} filtxt2

# Deletes all punctuation
set pat1 {([[:punct:]])}
regsub -all $pat1 $filtxt2 {} wordstext

# Counts words (tcl/tk "\M" definition of "word")
set wrds [regsub -all {\M} $wordstext subspec blank]

# Stores word count in array
set awordcount($selfile) $wrds

}

# Produces a file upon which the wordcount was based
# for verification or documentation purposes
proc documentwords {wcountfile} {

global wordstext

# Creates empty file
# Defines name of file
regsub {tkount_chars_} $wcountfile {tkount_words_} file4wordcnt

# Opens file, inserts stripped word text
set fileID [open $file4wordcnt w]
puts $fileID $wordstext
close $fileID

}

# Procedure for calculating total counts
# (launched by user from UI)
proc totals {} {

global akeystrokes
global alinecount
global awordcount
global awords
global totallinecount
global totalwordcount

set count 0

foreach {key value} [array get alinecount] {

set count [expr $count + $value]

}

set totallinecount $count

set count 0

foreach {key value} [array get awordcount] {

set count [expr $count + $value]

}

set totalwordcount $count

# Inserts totals into display
.mf.t insert end "\n   Total line count: $totallinecount\n"
.mf.t insert end "   Total word count: $totalwordcount\n\n"

}

# Procedure for launching file selection dialog
proc select {} {

global DIR
global prefs
global selfile
global keystrokes
global file4charcnt
global nz
global wrds
global wordstext

global akeystrokes
global awords

set fltyp {
{ "MS Word"	{ *.doc *.docx *.dot }	} 
{ "HTML"	{ *.html *.htm }	} 
{ "OpenOffice Writer"	{ *.sxw *.odt }	} 
{ "PDF"	{ *.pdf }	}  
{ "Plain Text"	{ *.txt }	}  
}

set selfiles [tk_getOpenFile -multiple 1 -filetypes $fltyp -parent .]

# Procedure for launching routines for converting and counting 
# selected files; prints results in text field
foreach selfile $selfiles {

# Renames copy of selected file "tk_chars_selected file"
# There has to be a neater way of doing this...
set tkdirname [file dirname $selfile]
set tkmarkerchars {tkount_chars_}
set tktail [file tail $selfile]
set charstktail $tkmarkerchars$tktail
set tkselfile [file join $tkdirname $charstktail]

file copy $selfile $tkselfile

# Converts file to plain text using convert procedure
convert $tkselfile

# Counts characters of plain text file using count procedure
countks $file4charcnt

# Counts words using countwords procedure
countwords $file4charcnt

# Creates array of filenames/keystroke & word counts
set akeystrokes($selfile) $keystrokes
set awords($selfile) $wrds

# Launches optional documentwords procedure, which
# produces  a plain-text file containing the text used
#  for the word (not character) count
# This slows the count down considerably so is 
# commented out by default - 
# Uncomment out (remove "# " in the next line to activate
# documentwords $file4charcnt

# Inserts the name(s) (with path) of the selected file(s) into the text area
# .mf.t insert end "$selfile\n"
.mf.t insert end "$selfile\n"

# Insert the number of standard lines
# Edit the text "Lines of 55 keystrokes" as desired/
# according to changes made to the division factor
.mf.t insert end "   Lines of 55 keystrokes: $nz\n"

# Insert the number of words
.mf.t insert end "   Words: $wrds\n"

# Deletes renamed "original" file
file delete $tkselfile

# Deletes text file on which character 
# count is based
# This file may be useful for documentation 
# - uncomment out this line if it is to be kept
file delete $file4charcnt

	}
}
