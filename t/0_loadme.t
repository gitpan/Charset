#
# $Id: 0_loadme.t,v 0.1 2002/03/29 19:15:22 dankogai Exp dankogai $
#
use strict;
use Test::More tests => 2;
eval "use Charset qw(latin1);" ; ok(!$@);
eval "use Charset qw(bogus); " ; ok( $@);

