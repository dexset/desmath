module des.math.combin;

import des.ts;

version(unittest) import std.string : format;

/// factorial
long fact( long n ) pure nothrow
in { assert( n >= 0 ); }
out(res) { assert( res >= 0 ); }
body
{
    if( n <= 2 ) return n;
    long res = 1;
    foreach( i; 2 .. n+1 ) res *= i;
    return res;
}

unittest
{
    assertEq( fact(0), 0 );
    assertEq( fact(1), 1 );
    assertEq( fact(2), 2 );
    assertEq( fact(3), 6 );
    assertEq( fact(4), 24 );
    assertEq( fact(5), 120 );
    assertEq( fact(6), 720 );
    assertEq( fact(7), 5040 );
    assertEq( fact(8), 40320 );
    assertEq( fact(9), 362880 );
    assertEq( fact(10), 3628800 );
}

/// equals to fact(n) / ( fact(k) * fact( n-k ) )
long combination( long n, long k ) pure nothrow
in
{
    assert( k > 0 );
    assert( n >= 0 );
}
out(res) { assert( res >= 0 ); }
body
{
    if( k == 1 || k == n-1 ) return n;
    long a = n * (n-1);
    long b = k;

    foreach( i; 2 .. k )
    {
        a *= (n-i);
        b *= i;
    }

    return a / b;
}

unittest
{
    static pure nothrow long comb2( long n, long k )
    { return fact(n) / ( fact(k) * fact( n-k ) ); }

    foreach( k; 1 .. 10 )
        assertEq( combination(10,k), comb2(10,k),
                  format( "equal test fails with k==%d, %%s != %%s", k ) );
}

/// equals to fact(n) / fact(n-k)
long partialPermutation( long n, long k ) pure nothrow
in
{
    assert( k > 0 );
    assert( n >= k );
}
out(res) { assert( res >= 0 ); }
body
{
    if( k == 1 ) return n;

    long res = n * (n-1);

    foreach( i; 2 .. k )
        res *= (n-i);

    return res;
}

unittest
{
    static pure nothrow long perm2( long n, long k )
    { return fact(n) / fact( n-k ); }

    foreach( k; 1 .. 10 )
        assertEq( partialPermutation(10,k), perm2(10,k),
                  format( "equal test fails with k==%d, %%s != %%s", k ) );
}
