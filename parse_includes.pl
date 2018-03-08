use strict;
use warnings;
use File::Basename;

sub loadfile {
    my ($filename) = @_;
    open(my $fh, '<', $filename) 
        or die "Could not open file '$filename' $!";
    my $dirname = dirname($filename);
    my $parent_dir = dirname($dirname);
    
    while (<$fh>) {
        if ( /^\s*Include\s+(\S+)/ ) {
            my $next_file = $1;
            $next_file =~ s#^./#$dirname/#;
            $next_file =~ s#^../#$parent_dir/#;
            
            die "Infinite recursion of '$filename' detected"
                if $next_file eq $filename;
            loadfile($next_file);
        } else {
            print;
        }
    }
}

my $initial_filename = shift;
loadfile($initial_filename);
