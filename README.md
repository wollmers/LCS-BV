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

    $alg = LCS::BV->new;
    @lcs = $alg->LCS(\@a,\@b);

# ABSTRACT

LCS::BV implements Algorithm::Diff using bit vectors and
is faster in most cases, especially on strings with a length shorter
than the used wordsize of the hardware (32 or 64 bits).

# DESCRIPTION

## CONSTRUCTOR

- new()

    Creates a new object which maintains internal storage areas
    for the LCS computation.  Use one of these per concurrent
    LCS() call.

## METHODS

- LLCS(\\@a,\\@b)

    Return the length of a Longest Common Subsequence, taking two arrayrefs as method
    arguments. It returns an integer.

- LCS(\\@a,\\@b)

    Finds a Longest Common Subsequence, taking two arrayrefs as method
    arguments. It returns an array reference of corresponding
    indices, which are represented by 2-element array refs.

## EXPORT

None by design.

# SEE ALSO

Algorithm::Diff

# AUTHOR

Helmut Wollmersdorfer <helmut.wollmersdorfer@gmail.com>

<div>
    <a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>
</div>

# COPYRIGHT AND LICENSE

Copyright 2014-2019 by Helmut Wollmersdorfer (Österreich)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
