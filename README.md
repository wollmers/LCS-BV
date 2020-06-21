# NAME

LCS::BV - Bit Vector (BV) implementation of the
                 Longest Common Subsequence (LCS) Algorithm

<div>
    <a href="https://travis-ci.org/wollmers/LCS-BV"><img src="https://travis-ci.org/wollmers/LCS-BV.png" alt="LCS-BV"></a>
    <a href='https://coveralls.io/r/wollmers/LCS-BV?branch=master'><img src='https://coveralls.io/repos/wollmers/LCS-BV/badge.png?branch=master' alt='Coverage Status' /></a>
    <a href='http://cpants.cpanauthors.org/dist/LCS-BV'><img src='http://cpants.cpanauthors.org/dist/LCS-BV.png' alt='Kwalitee Score' /></a>
    <a href="http://badge.fury.io/pl/LCS-BV"><img src="https://badge.fury.io/pl/LCS-BV.svg" alt="CPAN version" height="18"></a>
</div>

# SYNOPSIS

    use LCS::BV;

    $object = LCS::BV->new;
    @lcs    = $object->LCS(\@a,\@b);

    $llcs   = $object->LLCS(\@a,\@b);

    $positions = $object->prepare(\@a);
    $llcs      = $object->LLCS_prepared($positions,\@b);

# ABSTRACT

LCS::BV implements Algorithm::Diff using bit vectors and
is faster in most cases, especially on strings with a length shorter
than the used wordsize of the hardware (32 or 64 bits).

# DESCRIPTION

## CONSTRUCTOR

- new()

    Creates a new object which maintains internal storage areas
    for the LCS computation. Use one of these per concurrent
    LCS() call.

## METHODS

- LLCS(\\@a,\\@b)

    Return the length of a Longest Common Subsequence, taking two arrayrefs as method
    arguments. It returns an integer.

- LCS(\\@a,\\@b)

    Finds a Longest Common Subsequence, taking two arrayrefs as method
    arguments. It returns an array reference of corresponding
    indices, which are represented by 2-element array refs.

- prepare(\\@a)

    For comparison of the same sequence @a many times against different sequences @b
    it can be faster to prepare @a. It returns a hashref of positions.
    This works only on object mode.

- LLCS\_prepared($positions,\\@a)

    Return the length of a Longest Common Subsequence, with one side prepared.
    It returns an integer. It is two times faster than LLCS().

## EXPORT

None by design.

# STABILITY

Until release of version 1.00 the included methods, names of methods and their
interfaces are subject to change.

Beginning with version 1.00 the specification will be stable, i.e. not changed between
major versions.

# REFERENCES

H. Hyyroe. A Note on Bit-Parallel Alignment Computation.
In M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
of Computer Science and Engineering, Faculty of Electrical
Engineering, Czech Technical University, 2004.

# SPEED COMPARISON

    Intel Core i7-4770HQ Processor
    Intel® SSE4.1, Intel® SSE4.2, Intel® AVX2
    4 Cores, 8 Threads
    2.20 - 3.40 GHz
    6 MB Cache
    16 GB DDR3 RAM

LCS-BV/xt$ perl 50\_diff\_bench.t

LCS: Algorithm::Diff, Algorithm::Diff::XS, LCS, LCS::BV

LCS: \[Chrerrplzon\] \[Choerephon\]

                Rate      LCS:LCS    AD:LCSidx AD:XS:LCSidx   LCS:BV:LCS
LCS:LCS       9225/s           --         -72%         -87%         -88%
AD:LCSidx    33185/s         260%           --         -53%         -58%
AD:XS:LCSidx 70447/s         664%         112%           --         -12%
LCS:BV:LCS   79644/s         763%         140%          13%           --

LCS: \[qw/a b d/ x 50\], \[qw/b a d c/ x 50\]

               Rate      LCS:LCS    AD:LCSidx   LCS:BV:LCS AD:XS:LCSidx
LCS:LCS      49.5/s           --         -37%         -96%         -99%
AD:LCSidx    79.0/s          60%           --         -94%         -98%
LCS:BV:LCS   1255/s        2434%        1488%           --         -69%
AD:XS:LCSidx 4073/s        8124%        5052%         224%           --

LLCS: \[Chrerrplzon\] \[Choerephon\]

                     Rate    LCS:LLCS AD:LCS_length AD:XS:LCS_length LCS:BV:LLCS
LCS:LLCS          11270/s          --          -70%             -70%        -92%
AD:LCS_length     37594/s        234%            --              -1%        -75%
AD:XS:LCS_length  38059/s        238%            1%               --        -74%
LCS:BV:LLCS      148945/s       1222%          296%             291%          --

LLCS: \[qw/a b d/ x 50\], \[qw/b a d c/ x 50\]

                   Rate     LCS:LLCS AD:LCS_length AD:XS:LCS_length  LCS:BV:LLCS
LCS:LLCS         50.0/s           --          -37%             -37%         -98%
AD:LCS_length    79.2/s          58%            --              -1%         -97%
AD:XS:LCS_length 79.8/s          60%            1%               --         -97%
LCS:BV:LLCS      2357/s        4614%         2874%            2853%           --

# SOURCE REPOSITORY

[http://github.com/wollmers/LCS-BV](http://github.com/wollmers/LCS-BV)

# SEE ALSO

Algorithm::Diff
LCS
LCS::Tiny

# AUTHOR

Helmut Wollmersdorfer <helmut.wollmersdorfer@gmail.com>

<div>
    <a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>
</div>

# COPYRIGHT AND LICENSE

Copyright 2014-2020 by Helmut Wollmersdorfer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
