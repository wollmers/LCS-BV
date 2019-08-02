package LCS::BV;

use 5.010001;
use strict;
use warnings;
our $VERSION = '0.06';
#use utf8;
use Data::Dumper;

our $width = int 0.999+log(~0)/log(2);

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

  my ($amin, $amax, $bmin, $bmax) = (0, length($a)-1, 0, length($b)-1);

  while ($amin <= $amax and $bmin <= $bmax and substr($a,$amin,1) eq substr($b,$bmin,1)) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and substr($a,$amax,1) eq substr($b,$bmax,1)) {
    $amax--;
    $bmax--;
  }

  my $positions;
  $positions->{substr($a,$_,1)} |= 1 << ($_ % $width) for $amin..$amax;

  my $v = ~0;
  my ($p,$u);

  for ($bmin..$bmax) {
    $p = $positions->{substr($b,$_,1)} // 0;
    $u = $v & $p;
    $v = ($v + $u) | ($v - $u);
  }
  $v = ~$v;

  $v = $v - (($v >> 1) & 0x5555555555555555);
  $v = ($v & 0x3333333333333333) + (($v >> 2) & 0x3333333333333333);
  # (bytesof($v) -1) * bitsofbyte = (8-1)*8 = 56 ----------------------vv
  $v = (($v + ($v >> 4) & 0x0f0f0f0f0f0f0f0f) * 0x0101010101010101) >> 56;

  return $amin + $v + length($a) - ($amax+1);
}

sub LCS {
  my ($self, $a, $b) = @_;

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
  my @lcs;

  if ($amax < $width ) {
    $positions->{$a->[$_]} |= 1 << ($_ % $width) for $amin..$amax;

    my $S = ~0;

    my $Vs = [~0];
    my ($y,$u);

    # outer loop
    for my $j ($bmin..$bmax) {
      $y = $positions->{$b->[$j]} // 0;
      $u = $S & $y;               # [Hyy04]
      $S = ($S + $u) | ($S - $u); # [Hyy04]
      $Vs->[$j] = $S;
    }

    # recover alignment
    my $i = $amax;
    my $j = $bmax;

    while ($i >= $amin && $j >= $bmin) {
      if ($Vs->[$j] & (1<<$i)) {
        $i--;
      }
      else {
        unless ($j && ~$Vs->[$j-1] & (1<<$i)) {
           unshift @lcs, [$i,$j];
           $i--;
        }
        $j--;
      }
    }
  }
  else {
    $positions->{$a->[$_]}->[$_ / $width] |= 1 << ($_ % $width) for $amin..$amax;

    my $S;
    my $Vs = [];
    my ($y,$u,$carry);
    my $kmax = $amax / $width + 1;

    # outer loop
    for my $j ($bmin..$bmax) {
      $carry = 0;

      for (my $k=0; $k < $kmax; $k++ ) {
        $S = ($j) ? $Vs->[$j-1]->[$k] : ~0;
        $S //= ~0;
        $y = $positions->{$b->[$j]}->[$k] // 0;
        $u = $S & $y;             # [Hyy04]
        $Vs->[$j]->[$k] = $S = ($S + $u + $carry) | ($S & ~$y);
        $carry = (($S & $u) | (($S | $u) & ~($S + $u + $carry))) >> 63; # TODO: $width-1
      }
    }

    # recover alignment
    my $i = $amax;
    my $j = $bmax;

    while ($i >= $amin && $j >= $bmin) {
      my $k = $i / $width;
      if ($Vs->[$j]->[$k] & (1<<($i % $width))) {
        $i--;
      }
      else {
        unless ($j && ~$Vs->[$j-1]->[$k] & (1<<($i % $width))) {
           unshift @lcs, [$i,$j];
           $i--;
        }
        $j--;
      }
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

Copyright 2014-2015 by Helmut Wollmersdorfer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
