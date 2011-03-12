use strict;
use warnings;
use lib 'src';
use common;

# print common::single_path('navajoland');

mkdir "navajo" unless -d "navajo";

my %changes;

my $p = new XML::Parser(Handlers => {
	Start => sub {
		my ($parser, $tag, %attrs) = @_;

		if (defined $attrs{'navajo'}) {
			$changes{$attrs{'id'}} = $attrs{'navajo'};
		}
	},
});
$p->parsefile('data/dioceses-counties.xml');

my $navajoland = common::single_path('navajoland');

for my $change (keys %changes) {

	print "$change\n";

	my $diocese = common::single_path($change, 'shapes');

	my $filename = "navajo/$change.svg";

	open SVG, ">$filename" or die;

	print SVG common::prefix();
	print SVG "<path style=\"fill:#00ff00\" d=\"$diocese\" />\n";
	print SVG "<path style=\"fill:#ff00ff\" d=\"$navajoland\" />\n";
	print SVG common::suffix();

	close SVG or die;

	my $verb = 'SelectionDiff';
	$verb = 'SelectionUnion' if $changes{$change} eq 'add';

	system("inkscape $filename --verb EditSelectAll --verb $verb --verb FileSave --verb FileClose");
}

