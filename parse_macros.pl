use strict;
use warnings;
use Text::ParseWords;

my $generated_perl = '
our %subs;
my $content = <<\'END_CONTENT\';
';

while ( <> ) {
    if ( /^\s*<Macro\s+(\S+)\s*(.*?)>/ ) {
        $generated_perl .= "END_CONTENT
        
\$subs{'$1'} = sub {
    my \@params = qw($2);
    
    if ( scalar(\@_) != scalar(\@params) ) {
        print \"ERROR: Macro $1 invoked with \", scalar(\@_), \" argument(s) but defined with \", scalar(\@params), \"\n\";
        print \"> Use $1 \@_\n\";
        die;
    }
    
    my \$content = <<'END_CONTENT';
";
    }
    elsif ( /^\s*<\/Macro>/ ) {
        $generated_perl .= 'END_CONTENT
    
    foreach my $param ( @params ) {
        my $replacement = shift;
        $content =~ s/\Q$param\E/$replacement/g;
    }
        
    return $content;
};

$content .= <<\'END_CONTENT\';
';
    } elsif ( /^\s*Use\s+(\S+)\s*(.*)/ ) {
        $generated_perl .= "END_CONTENT
if ( ! defined \$subs{'$1'} ) { print \"ERROR: Undefined Macro '$1'\n\"; die; }
\$content .= &{ \$subs{'$1'} }( shellwords(q{$2}) );
\$content .= <<'END_CONTENT';
";
    } elsif ( /^\s*UndefMacro\s+(\S+)/ ) {
        $generated_perl .= "END_CONTENT
if ( ! defined \$subs{'$1'} ) { print \"ERROR: Undefined Macro '$1'\n\"; die; }
delete \$subs{'$1'};
\$content .= <<'END_CONTENT';
";
    } else {
        $generated_perl .= $_;
    }
}
$generated_perl .= '
END_CONTENT

print $content;

my $remaining_macros = keys %subs;

if ($remaining_macros > 0) {
	print "\n\n# $remaining_macros macros defined at end of input (you might want to UndefMacro them).\n";
	print "# UndefMacro ", (join "\n# UndefMacro ", sort keys %subs), "\n";
}
';

eval $generated_perl;
