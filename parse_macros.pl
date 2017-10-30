use strict;
use warnings;
use Text::ParseWords;

my $generated_perl = '
my $content = <<\'END_CONTENT\';
';

while ( <> ) {
    if ( /^\s*<Macro\s+(\S+)\s+(.*?)>/ ) {
        $generated_perl .= "END_CONTENT
        
sub Macro_$1 {
    my \@params = qw($2);
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
}

$content .= <<\'END_CONTENT\';
';
    } elsif ( /^\s*Use\s+(\S+)\s+(.*)/ ) {
        $generated_perl .= "END_CONTENT
\$content .= Macro_$1(shellwords(q{$2}));
\$content .= <<'END_CONTENT';
";
    } else {
        $generated_perl .= $_;
    }
}
$generated_perl .= '
END_CONTENT

print $content;
';

eval $generated_perl;