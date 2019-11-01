requires 'perl', '5.010001';

requires 'Math::BigInt', '1.999818';
recommends 'Math::BigInt::GMP', '1.6007';

on test => sub {
  requires 'Test::More', '0.88';
  requires 'Test::Deep', '0';
  requires 'LCS', '0';
};

on 'develop' => sub {
  requires 'Test::Spelling';
  requires 'Test::MinimumVersion';
  requires 'Test::Pod::Coverage';
  requires 'Test::PureASCII';
};
