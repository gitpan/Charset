package Charset;

use 5.007003;
use strict;
#use warnings;
our $VERSION =  do {my @r=(q$Revision: 0.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r};
our $DEBUG = 0;
use Encode;
use Carp;

our $Charset;
our $header;

sub import 
{
   my $class    = shift;
   $Charset     = shift;
   my %arg = @_;
   $DEBUG = $arg{DEBUG} if $arg{DEBUG};
   exists $arg{STDIN}  or $arg{STDIN}  = $Charset;
   exists $arg{STDOUT} or $arg{STDOUT} = $Charset;
   $arg{STDIN} ||= $Charset;
   find_encoding($Charset) or croak("$class:$Charset unsupported\n");
   if ($DEBUG){
       my ($pkg, $filename, $line) = caller;
       warn "Filtering $filename, line $line\n";
   }
   $header  = qq{use utf8;\n};
   $header .= qq{use open "encoding($arg{IO})";\n}       if $arg{IO};
   $header .= qq{use open "encoding($arg{IN})";\n}       if $arg{IN};
   $header .= qq{use open "encoding($arg{OUT})";\n}      if $arg{OUT};
   $header .= 
       qq{binmode STDIN  => "encoding($arg{STDIN})";\n}  if $arg{STDIN};
   $header .= 
       qq{binmode STDOUT => "encoding($arg{STDOUT})";\n} if $arg{STDOUT};
}

use Filter::Simple;
FILTER{
    $DEBUG >= 2 and warn $_;
    Encode::from_to($_, $Charset, 'utf8');
    $DEBUG >= 3 and warn $_;
    $_ = $header . $_;
};

1;
__END__

=head1 NAME

Charset - write perl codes in any encodings you like

=head1 SYNOPSIS

  use Charset "euc-jp"; # Jperl!
  #...
  sub tricky_part{
     no Charset;
     #...
  }
  use Charset "euc-jp"; # restore the state; Filter::Simple bug.
  # Handy for EUC-JP => UTF-8 converter 
  # when your text editor only supports Shift_JIS !
  use Charset "shiftjis", IN => "euc-jp", OUT => "utf8";
  # If your shell supports EUC-JP, you can even do this!
  perl -MCharset=euc-jp 'print "Nihongo\n" x 4'

=head1 ABSTRACT

This module allows you to write your perl codes in not only ASCII (or
EBCDIC where your environment allows) or UTF-8 but any character
encodings that Encode module supports.

=head1 USAGE

First argument to the C<use> line must be the name of encoding which
matches your script.  It croaks if none specified or the one specified
is unsupported by the Encode module.

You can optionally feed the argument in hash.  The followin options
are supported.

=over 4

=item STDIN =E<gt> I<enc_name>

Sets the discipline of STDIN to C<:encoding(I<enc_name>)>.  By default,
the same encoding as the caller script is used.

=item STDOUT =E<gt> I<enc_name>

Sets the discipline of STDOUT to C<:encoding(I<enc_name>)>.  By default,
the same encoding as the caller script is used.

=item IN =E<gt> I<enc_name>

Internally does C<use open IN =E<gt> ":encoding(I<enc_name>)">.  No
default is set.  See L<open>.

=item OUT =E<gt> I<enc_name>

Internally does C<use open OUT =E<gt> ":encoding(I<enc_name>)">.  No
default is set.  See L<open>.

=item IO =E<gt> I<enc_name>

Internally does C<use open IO =E<gt> ":encoding(I<enc_name>)">.  No
default is set. IN or OUT overrides this setting.

=back

=head1 DESCRIPTION

This is a technology demonstrator of Perl 5.8.0.  It uses Encode and
Filter::Util::Call, both of which will be inlucuded in perl
distribution.

Before perl 5.6.0, a character means a byte.  Though it was possible
to include literals in multibyte characters in certain encodings (such
as EUC-JP), You needed to handle them with care.  Some encodings
didn't even allow this (such as Shift_JIS) and you needed things like 
F<Jperl> to do that.  If your multibyte encoding was not Japanese, you
were out of luck.

As of Perl 5.6.0, you could use UTF-8 strings internally so you could
apply everything you wanted to do to multilingual string, including
regexes.  You could even use UTF-8 string for identifiers you could 
go like 

  my $Ren++; #   "Ren" is really a U+4EBA

to make a child :) But there was one precondition.  Your source file
must be in UTF-8.  With decent text editors and environments that can
handle UTF-8 was rare (and still is to some extent), You still needed
character encoding converters like Jcode.pm

With perl 5.8.0 and this module, this will all change.  Your old
script in your regional character encoding suddenly starts working
just by adding

  use Charset qw(your-encoding);

=head1 BUGS

This modules uses Filter::Simple.  So it is subject to the limitation
of Filter::Simple.  Filter::Simple and Text::Balance which
Filter::Simple uses does a pretty good job for block detection

=head1 SEE ALSO

L<Encode>, L<Filter::Simple>, L<open>, L<PerlIO>

=head1 AUTHOR

Dan Kogai E<lt>dankogai@dan.co.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Dan Kogai, all rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
