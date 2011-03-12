use strict;
use warnings;
use XML::Parser;
use File::Slurp;

my $prefix = '';
while (<DATA>) {
	$prefix .= $_;
}

mkdir "temp", 0777 unless -d "temp";

my %counties;

my $p2 = new XML::Parser(Handlers => {
	Start => sub {
		my ($parser, $tag, %attrs) = @_;

		if ($tag eq 'path' && defined $attrs{'id'}) {
			$counties{$attrs{'id'}} = $attrs{'d'};
		}
	},
	End   => sub {
		my ($parser, $tag) = @_;
	},
	Char  => sub {
		my ($parser, $text) = @_;
	}});
$p2->parsefile('data/counties.svg');

my $p1 = new XML::Parser(Handlers => {
	Start => sub {
		my ($parser, $tag, %attrs) = @_;

		if ($tag eq 'path' && defined $attrs{'id'} && defined $attrs{'d'}) {
			$counties{$attrs{'id'}} = $attrs{'d'};
		}
	},
	End   => sub {
		my ($parser, $tag) = @_;
	},
	Char  => sub {
		my ($parser, $text) = @_;
	}});
$p1->parsefile('data/split.svg');

my $style='font-size:12px;fill:#0000ff;fill-rule:nonzero;stroke:#000000;stroke-opacity:1;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-linecap:butt;marker-start:none;stroke-linejoin:bevel';

my $diocese;
my $p3 = new XML::Parser(Handlers => {
	Start => sub {
		my ($parser, $tag, %attrs) = @_;

		if ($tag eq 'province') {
			open PROVINCE, ">temp/$attrs{id}.svg" or die "$!";
			print PROVINCE $prefix;
		} elsif ($tag eq 'diocese') {
			open DIOCESE, ">temp/$attrs{id}.svg" or die "$!";
			print DIOCESE $prefix;
			$diocese = $attrs{id};
		} elsif ($tag eq 'county') {
			my $fips = $attrs{'fips'};
			die "FIPS code $fips is unknown\n" unless defined $counties{$fips};
			my $split = $attrs{'split'};

			my $id = $fips;
			my $tempstyle = $style;

			if ($split) {
				$id = "$fips-$diocese";
				print "Split: new name is $id\n";
				$tempstyle =~ s/0000ff/ff0000/;
			}

			my $tag = "<path id=\"$id\" style=\"$tempstyle\" d=\"$counties{$id}\" />\n";

			print PROVINCE $tag;
			print DIOCESE $tag;
		}
	},
	End   => sub {
		my ($parser, $tag) = @_;

		if ($tag eq 'province') {
			print PROVINCE "</svg>\n";
			close PROVINCE or die;
		} elsif ($tag eq 'diocese') {
			print DIOCESE "</svg>\n";
			close DIOCESE or die;
		}
	},
	Char  => sub {
		my ($parser, $text) = @_;
	}});
$p3->parsefile('data/dioceses-counties.xml');

__DATA__
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   version="1.0"
   width="555.22198"
   height="351.66797">

