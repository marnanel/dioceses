package common;
use strict;
use warnings;
use XML::Parser;

my $_prefix;

sub prefix {
	unless (defined $_prefix) {
		$_prefix = '';

		while (<DATA>) {
			$_prefix .= $_;
		}
	}

	return $_prefix;
}

sub suffix {
	return "</svg>\n";
}

sub single_path {
	my ($pathname, $dir) = @_;

	$dir = 'data' unless defined $dir;
	my $result;
	my $filename = "$dir/$pathname.svg";

	if (!-e $filename) {
		warn "File $filename not found\n";
		return undef;
	}

	my $p = new XML::Parser(Handlers => {
	Start => sub {
		my ($parser, $tag, %attrs) = @_;

		if ($tag eq 'path' && defined $attrs{'d'}) {
			$result = $attrs{'d'};
		}
	},
	});
	
	$p->parsefile($filename);

	warn "Single path $pathname not found\n" unless $result;

	return $result;
}

1;
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

