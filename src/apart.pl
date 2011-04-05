use strict;
use warnings;
use lib 'src';
use common;
use File::Slurp;
use XML::Parser;

my $dioceses_file = 'data/dioceses-counties.xml';
my $counties_file = 'data/counties.svg';
my $split_file = 'data/split.svg';

sub get_split {
	my ($county, $diocese) = @_;

	my $style = common::style();
	$style =~ s/0000ff/ff0000/;

	my $want = "$county-$diocese";
	my $result;

        my $p4 = new XML::Parser(Handlers => {
		Start => sub {
			my ($parser, $tag, %attrs) = @_;

			if ($tag eq 'path' && $attrs{'id'} eq $want) {
				$result = "<path style=\"$style\" d=\"$attrs{'d'}\" />\n";
			}
		},
	});
        $p4->parsefile($split_file);

	return $result if $result;
	die "Split county $want not found\n";
}

sub apart {
	my ($filename, $root) = @_;

	my $content = '';
	my $state = 0;
	my %counties;

	my $style = common::style();

	$content .= common::prefix();
        my $p2 = new XML::Parser(Handlers => {
		Start => sub {
			my ($parser, $tag, %attrs) = @_;

			if ($tag eq 'diocese' && $attrs{'id'} eq $root) {
				$state = 1;
			} elsif ($tag eq 'county' && $state==1) {
				if (defined $attrs{'split'}) {
					$content .= get_split($attrs{'fips'}, $root);
				} else {
					$counties{$attrs{'fips'}} = 1;
				}
			}
		},
		End => sub {
			my ($parser, $tag) = @_;

			if ($tag eq 'diocese' && $state==1) {
				$state = 2;
			}
		},
	});
        $p2->parsefile($dioceses_file);
	die "ID '$root' not found!\n" if $state==0;

        my $p3 = new XML::Parser(Handlers => {
		Start => sub {
			my ($parser, $tag, %attrs) = @_;

			if ($tag eq 'path' && defined $counties{$attrs{'id'}}) {
				$content .= "<path style=\"$style\" d=\"$attrs{'d'}\" />\n";
			}
		},
	});
        $p3->parsefile($counties_file);

	$content .= common::suffix();

	write_file($filename, $content);
}

mkdir 'intermediate' unless -d 'intermediate';

for my $filename (@ARGV) {
	my $root = $filename;
	$root =~ s/\.apart\.svg$//;
	$root =~ s/^.*\///;
	print "Creating $filename...";
	apart($filename, $root);
	print "done.\n";
}
