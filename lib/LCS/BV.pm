package LCS::BV;

use 5.010001;
use strict;
use warnings;
our $VERSION = '0.06';
#use utf8;

sub new {
  my $class = shift;
  # uncoverable condition false
  bless @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}, ref $class || $class;
}

# H. Hyyroe. A Note on Bit-Parallel Alignment Computation. In
# M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
# of Computer Science and Engineering, Faculty of Electrical
# Engineering, Czech Technical University, 2004.

sub LLCS {
  my ($self,$a,$b) = @_;

  use integer;
  no warnings 'portable'; # for 0xffffffffffffffff

  my ($amin, $amax, $bmin, $bmax) = (0, $#$a, 0, $#$b);

  while ($amin <= $amax and $bmin <= $bmax and $a->[$amin] eq $b->[$bmin]) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and $a->[$amax] eq $b->[$bmax]) {
    $amax--;
    $bmax--;
  }

  my $positions;
  $positions->{$a->[$_]} |= 1 << $_ for $amin..$amax;

  my $v = ~0;
  my ($p,$u);

  for my $j ($bmin..$bmax) {
    $p = $positions->{$b->[$j]} // 0;
    $u = $v & $p;
    $v = ($v + $u) | ($v - $u);
  }
  $v = ~$v;

  #$v = $v - (($v >> 1) & 0x5555555555555555);
  #$v = ($v & 0x3333333333333333) + (($v >> 2) & 0x3333333333333333);
  ## (bytesof($v) -1) * bitsofbyte = (8-1)*8 = 56 ----------------------vv
  #$v = (($v + ($v >> 4) & 0x0f0f0f0f0f0f0f0f) * 0x0101010101010101) >> 56;
  #return $amin + $v + scalar(@$a) - ($amax+1);

  return $amin + _count_bits($v) + scalar(@$a) - ($amax+1);
}


#int count_bits(uint64_t bits) {
#  bits = (bits & 0x5555555555555555ull) + ((bits & 0xaaaaaaaaaaaaaaaaull) >> 1);
#  bits = (bits & 0x3333333333333333ull) + ((bits & 0xccccccccccccccccull) >> 2);
#  bits = (bits & 0x0f0f0f0f0f0f0f0full) + ((bits & 0xf0f0f0f0f0f0f0f0ull) >> 4);
#  bits = (bits & 0x00ff00ff00ff00ffull) + ((bits & 0xff00ff00ff00ff00ull) >> 8);
#  bits = (bits & 0x0000ffff0000ffffull) + ((bits & 0xffff0000ffff0000ull) >>16);
#  return (bits & 0x00000000ffffffffull) + ((bits & 0xffffffff00000000ull) >>32);
#}



sub _count_bits {
  my $v = shift;

  use integer;
  no warnings 'portable'; # for 0xffffffffffffffff

  $v = $v - (($v >> 1) & 0x5555555555555555);
  $v = ($v & 0x3333333333333333) + (($v >> 2) & 0x3333333333333333);
  # (bytesof($v) -1) * bitsofbyte = (8-1)*8 = 56 ----------------------vv
  $v = (($v + ($v >> 4) & 0x0f0f0f0f0f0f0f0f) * 0x0101010101010101) >> 56;
  return $v;
}




sub LCS {
  my ($self, $a, $b) = @_;

  use Math::BigInt try => 'GMP';

  my ($amin, $amax, $bmin, $bmax) = (0, $#$a, 0, $#$b);

  while ($amin <= $amax and $bmin <= $bmax and $a->[$amin] eq $b->[$bmin]) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and $a->[$amax] eq $b->[$bmax]) {
    $amax--;
    $bmax--;
  }

  my $positions;
  my @lcs;

  my $mask = Math::BigInt->bone();
  $mask->blsft($amin);
  for ($amin..$amax) {
    my $p = $a->[$_];
    unless (defined $positions->{$p}) {
      $positions->{$p} = Math::BigInt->new(0);
    }
    $positions->{$p}->bior($mask);
    $mask->blsft(1);
  }

  # cannot do a simple NOT with bnot here as it will turn the integer into
  # a negative value
  my $S = Math::BigInt->bone()->blsft($amax + 1)->bdec();

  my $b0 = Math::BigInt->new(0)->accuracy($S->accuracy());

  my $Vs = [];
  my ($y,$u);

  # outer loop
  for my $j ($bmin..$bmax) {
    $y = $positions->{$b->[$j]} // $b0;
    # [Hyy04]
    # $u = $S & $y
    $u = $S->copy()->band($y);
    # $S = ($S + $u) | ($S - $u)
    $S->badd($u)->bior($S->copy->bsub($u));
    $Vs->[$j] = $S->copy();
  }

  # recover alignment
  my $i = $amax;
  my $j = $bmax;

  # really: $mask = 1 << $i
  # this is faster than creating a new object with value = 1 and then shift
  $mask->bxor($mask)->binc()->blsft($i);

  while ($i >= $amin && $j >= $bmin) {
    my $Vm = $Vs->[$j]->copy()->band($mask);
    unless ($Vm->is_zero()) {
      $i--;
      $mask->brsft(1);
    }
    else {
      my $m = $j > 0 ? exists $Vs->[$j-1] : 0;
      if ($m) {
        $m = !($Vs->[$j - 1]->copy()->bnot()->band($mask)->is_zero());
      }
      unless ($m) {
        unshift @lcs, [$i,$j];
        $i--;
        $mask->brsft(1);
      }
      $j--;
    }
  }

  return [
    map([$_ => $_], 0 .. ($bmin-1)),
    @lcs,
    map([++$amax => $_], ($bmax+1) .. $#$b)
  ];
}


1;

__END__

=head1 NAME

LCS::BV - Bit Vector (BV) implementation of the
                 Longest Common Subsequence (LCS) Algorithm

=begin html

<a href="https://travis-ci.org/wollmers/LCS-BV"><img src="https://travis-ci.org/wollmers/LCS-BV.png" alt="LCS-BV"></a>
<a href='https://coveralls.io/r/wollmers/LCS-BV?branch=master'><img src='https://coveralls.io/repos/wollmers/LCS-BV/badge.png?branch=master' alt='Coverage Status' /></a>
<a href='http://cpants.cpanauthors.org/dist/LCS-BV'><img src='http://cpants.cpanauthors.org/dist/LCS-BV.png' alt='Kwalitee Score' /></a>
<a href="http://badge.fury.io/pl/LCS-BV"><img src="https://badge.fury.io/pl/LCS-BV.svg" alt="CPAN version" height="18"></a>

=end html

=head1 SYNOPSIS

  use LCS::BV;

  $alg = LCS::BV->new;
  @lcs = $alg->LCS(\@a,\@b);

=head1 ABSTRACT

LCS::BV implements Algorithm::Diff using bit vectors and
is faster in most cases, especially on strings with a length shorter
than the used wordsize of the hardware (32 or 64 bits).

=head1 DESCRIPTION

=head2 CONSTRUCTOR

=over 4

=item new()

Creates a new object which maintains internal storage areas
for the LCS computation.  Use one of these per concurrent
LCS() call.

=back

=head2 METHODS

=over 4

=item LLCS(\@a,\@b)

Return the length of a Longest Common Subsequence, taking two arrayrefs as method
arguments. It returns an integer.

=item LCS(\@a,\@b)

Finds a Longest Common Subsequence, taking two arrayrefs as method
arguments. It returns an array reference of corresponding
indices, which are represented by 2-element array refs.

=back

=head2 EXPORT

None by design.

=head1 SEE ALSO

Algorithm::Diff

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=begin html

<a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>

=end html

=head1 COPYRIGHT AND LICENSE

Copyright 2014-2019 by Helmut Wollmersdorfer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
