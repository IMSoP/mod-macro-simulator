use strict;
use warnings;
use Text::ParseWords;

my $output = '
print <<\'END_NON_MACRO_OUTPUT\';
';

while ( <> ) {
    if ( /^\s*<Macro\s+(\S+)\s+(.*?)>/ ) {
        $output .= "END_NON_MACRO_OUTPUT
        
sub Macro_$1 {
    my \@params = qw($2);
    my \$content = <<'END_MACRO_CONTENT';
";
    }
    elsif ( /^\s*<\/Macro>/ ) {
        $output .= 'END_MACRO_CONTENT
        
    foreach my $param ( @params ) {
        my $replacement = shift;
        $content =~ s/\Q$param\E/$replacement/g;
    }
        
    print $content;
}

print <<\'END_NON_MACRO_OUTPUT\';
';
    } elsif ( /^\s*Use\s+(\S+)\s+(.*)/ ) {
        $output .= "END_NON_MACRO_OUTPUT
Macro_$1(shellwords(q{$2}));
print <<'END_NON_MACRO_OUTPUT';
";
    } else {
        $output .= $_;
    }
}
$output .= '
END_NON_MACRO_OUTPUT
';

eval $output;