use strict;
use warnings;

for my $file (glob('temp/*.svg')) {
	print "$file\n";
	system("inkscape $file --verb EditSelectAll --verb SelectionCombine --verb FileSave --verb FileClose");
}
