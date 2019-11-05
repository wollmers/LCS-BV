#!perl
use 5.006;
use open qw(:locale);
use strict;
use warnings;
#use utf8;

use lib qw(../lib/);

#use Test::More;

use LCS::BV;
use LCS;
use Algorithm::Diff;
use Algorithm::Diff::XS;
use String::Similarity;
#use Algorithm::LCS;

use Benchmark qw(:all) ;

#use LCS::Tiny;
#use LCS;
use LCS::BV;

#my $align = Align::Sequence->new;

#my $align_bv = LCS::Tiny->new;
#my $traditional = LCS->new();

#my $A_LCS = Algorithm::LCS->new();

my @data = (
  [split(//,'Chrerrplzon')],
  [split(//,'Choerephon')]
);

my @strings = qw(Chrerrplzon Choerephon);

my @data2 = (
  [split(//,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY')],
  [split(//, 'bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')]
);

my @strings2 = qw(
abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY
bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
);

my @data3 = ([qw/a b d/ x 50], [qw/b a d c/ x 50]);

my @strings3 = map { join('',@$_) } @data3;

print "\n",'LCS: Algorithm::Diff, Algorithm::Diff::XS, LCS, LCS::BV',"\n","\n";

print 'LCS: [Chrerrplzon] [Choerephon]',"\n","\n";

if (1) {
    cmpthese( -1, {
        'AD:LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data)
        },
        'AD:XS:LCSidx' => sub {
            Algorithm::Diff::XS::LCSidx(@data)
        },
        'LCS:BV:LCS' => sub {
            LCS::BV->LCS(@data)
        },
        'LCS:LCS' => sub {
            LCS::->LCS(@data)
        },
    });
}

print "\n",'LCS: [qw/a b d/ x 50], [qw/b a d c/ x 50]',"\n","\n";

if (1) {
    cmpthese( -1, {
        'AD:LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data3)
        },
        'AD:XS:LCSidx' => sub {
            Algorithm::Diff::XS::LCSidx(@data3)
        },
        'LCS:BV:LCS' => sub {
            LCS::BV->LCS(@data3)
        },
        'LCS:LCS' => sub {
            LCS::->LCS(@data3)
        },
    });
}

print "\n",'LLCS: [Chrerrplzon] [Choerephon]',"\n","\n";

if (1) {
    cmpthese( -1, {
        'AD:LCS_length' => sub {
            Algorithm::Diff::LCS_length(@data)
        },
        'AD:XS:LCS_length' => sub {
            Algorithm::Diff::XS::LCS_length(@data)
        },
        'LCS:BV:LLCS' => sub {
            LCS::BV->LLCS(@data)
        },
        'LCS:LLCS' => sub {
            LCS->LLCS(@data)
        },
    });
}

print "\n",'LLCS: [qw/a b d/ x 50], [qw/b a d c/ x 50]',"\n","\n";

if (1) {
    cmpthese( -1, {
        'AD:LCS_length' => sub {
            Algorithm::Diff::LCS_length(@data3)
        },
        'AD:XS:LCS_length' => sub {
            Algorithm::Diff::XS::LCS_length(@data3)
        },
        'LCS:BV:LLCS' => sub {
            LCS::BV->LLCS(@data3)
        },
        'LCS:LLCS' => sub {
            LCS->LLCS(@data3)
        },
    });
}


if (0) {
    cmpthese( -1, {
       #'LCS' => sub {
            #$traditional->LCS(@data)
        #},
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data)
        },
#        'LCSXS' => sub {
#            Algorithm::Diff::XS::LCSidx(@data)
#        },
        'LCSbv' => sub {
            LCS::BV->LCS(@data)
        },
        #'LCStiny' => sub {
            #LCS::Tiny->LCS(@data)
        #},
        'S::Sim' => sub {
            similarity(@strings)
        },
    });
}

if (0) {
    cmpthese( -1, {
       'LCS' => sub {
            #$traditional->LCS(@data2)
        },
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data2)
        },
        'LCSXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data2)
        },
        'LCSbv' => sub {
            LCS::BV->LCS(@data2)
        },
        'S::Sim' => sub {
            similarity(@strings2)
        },
    });
}

if (0) {
    cmpthese( -1, {
       'LCS' => sub {
            #$traditional->LCS(@data3)
       },
       'LCSidx' => sub {
            Algorithm::Diff::LCSidx(@data3)
        },
        'LCSXS' => sub {
            Algorithm::Diff::XS::LCSidx(@data3)
        },
        'LCSbv' => sub {
            LCS::BV->LCS(@data3)
        },
        'LCStiny' => sub {
            LCS::Tiny->LCS(@data3)
        },
    });
}

if (0) {
    timethese( 100_000, {
        'S::Sim' => sub {
            similarity(@strings3)
        },
    });
}

=pod

LCS-BV/xt$ perl 50_diff_bench.t

LCS: Algorithm::Diff, Algorithm::Diff::XS, LCS, LCS::BV

LCS: [Chrerrplzon] [Choerephon]

                Rate      LCS:LCS    AD:LCSidx AD:XS:LCSidx   LCS:BV:LCS
LCS:LCS       9225/s           --         -72%         -87%         -88%
AD:LCSidx    33185/s         260%           --         -53%         -58%
AD:XS:LCSidx 70447/s         664%         112%           --         -12%
LCS:BV:LCS   79644/s         763%         140%          13%           --

LCS: [qw/a b d/ x 50], [qw/b a d c/ x 50]

               Rate      LCS:LCS    AD:LCSidx   LCS:BV:LCS AD:XS:LCSidx
LCS:LCS      49.5/s           --         -37%         -96%         -99%
AD:LCSidx    79.0/s          60%           --         -94%         -98%
LCS:BV:LCS   1255/s        2434%        1488%           --         -69%
AD:XS:LCSidx 4073/s        8124%        5052%         224%           --

LLCS: [Chrerrplzon] [Choerephon]

                     Rate    LCS:LLCS AD:LCS_length AD:XS:LCS_length LCS:BV:LLCS
LCS:LLCS          11270/s          --          -70%             -70%        -92%
AD:LCS_length     37594/s        234%            --              -1%        -75%
AD:XS:LCS_length  38059/s        238%            1%               --        -74%
LCS:BV:LLCS      148945/s       1222%          296%             291%          --

LLCS: [qw/a b d/ x 50], [qw/b a d c/ x 50]

                   Rate     LCS:LLCS AD:LCS_length AD:XS:LCS_length  LCS:BV:LLCS
LCS:LLCS         50.0/s           --          -37%             -37%         -98%
AD:LCS_length    79.2/s          58%            --              -1%         -97%
AD:XS:LCS_length 79.8/s          60%            1%               --         -97%
LCS:BV:LLCS      2357/s        4614%         2874%            2853%           --

=cut

