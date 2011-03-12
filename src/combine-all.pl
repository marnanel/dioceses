use strict;
use warnings;

for my $file (glob('temp/*.svg')) {
	print "$file\n";
	# XXX FIXME: I think this should be SelectionUnion
	system("inkscape $file --verb EditSelectAll --verb SelectionCombine --verb FileSave --verb FileClose");
}
