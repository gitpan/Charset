#
# $Id: 1_jperl.t,v 0.1 2002/03/29 19:15:22 dankogai Exp dankogai $
#
# This script is written in euc-jp

use strict;
use Test::More tests => 7;
my $Debug = shift;
use Charset "euc-jp", DEBUG => $Debug;
my $Namae = "¾®»ô ÃÆ";   # in Japanese, in euc-jp
my $Name  = "Dan Kogai"; # in English
my $str = $Namae; $str =~ s/¾®»ô ÃÆ/Dan Kogai/o;
is($str, $Name); 
is(length($Namae), 4);
{
    use bytes;
    is(length($Namae), 10); # 3*3+1
    my $euc = Encode::encode('euc-jp', $Namae);
    is(length($euc),   7); # 2*3+1    
}
{
    no Charset;
    my $str = "\xbe\xae\xbb\xf4\x20\xc3\xc6";
    isnt($str, $Namae); 
    is($str, Encode::encode('euc-jp', $Namae)); 
}
#
#  You need to explicitly set Charset back on!
#
use Charset "euc-jp", DEBUG => $Debug;
$str = "¾®»ô ÃÆ";
is($str, $Namae); 


1;
__END__


