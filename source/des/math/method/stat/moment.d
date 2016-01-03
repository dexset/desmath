module des.math.method.stat.moment;

import std.algorithm;
import std.traits;
import std.range;
import std.string : format;

import des.ts;

/// expected value
auto mean(R)( R r ) pure nothrow @property @nogc
if( isInputRange!R )
in { assert( !r.empty ); } body
{
    alias T = Unqual!(ElementType!R);

    static assert( canSumWithSelfAndMulWithFloat!T,
            "range elements must can sum with selfs and mul with float" );

    size_t cnt = 0;
    T res = r.front * 0.0f; // neitral value for summate ( a + b*0 == a )
    foreach( v; r )
    {
        res = res + v;
        cnt++;
    }
    assert( cnt > 0, "no elements in range" );
    return res * ( 1.0f / cnt );
}

template canSumWithSelfAndMulWithFloat(T)
{
    enum canSumWithSelfAndMulWithFloat = is( typeof( T.init + T.init ) == T ) &&
                                         is( typeof( T.init * 0.0f ) == T );
}

///
unittest
{
    auto a = [ 1.0f, 2, 3 ];
    assertEq( a.mean, 2.0f );

    static assert( !__traits(compiles,mean(a[0])) );
    static assert( !__traits(compiles,[1,2,3].mean) );
    static assert(  __traits(compiles,[1.0f,2,3].mean) );

    import std.conv : to;

    assertEq( iota(11).map!(a=>to!float(a)).mean, 5 );
}

///
unittest
{
    import des.math.linear.vector;

    auto a = [ vec3(1,2,3), vec3(2,3,4), vec3(3,4,5) ];
    assertEq( a.mean, vec3(2,3,4) );
}

///
auto variance(bool return_mean=false,R)( R r ) pure nothrow @property @nogc
if( isInputRange!R )
{
    alias T = Unqual!(ElementType!R);

    static assert( canSumWithSelfAndMulWithFloat!T,
            "range elements must can sum with selfs and mul with float" );

    T res = r.front * 0.0f; // neitral value for summate ( a + b*0 == a )
    size_t cnt = 0;
    auto m = r.mean;
    T buf;
    foreach( val; r )
    {
        static if( is( typeof( T.init - T.init ) == T ) )
            buf = m - val;
        else
            buf = m + val * (-1.0f);

        res = res + buf * buf;
        cnt++;
    }

    assert( cnt > 1, "only one elements in range, must be greater 1" );

    static if( return_mean )
        return cast(T[2])[ m, res * ( 1.0f / (cnt-1) ) ];
    else
        return res * ( 1.0f / (cnt-1) );
}

///
unittest
{
    auto a = [ 1.0f, 1, 1 ];
    assertEq( a.variance, 0.0f );

    auto b = [ 1.0f, 2, 3 ];
    assertEq( b.variance, 1.0f );
}

///
unittest
{
    import des.math.linear.vector;

    auto a = [ vec3(1,2,3), vec3(2,3,4), vec3(3,4,5) ];
    assertEq( a.variance, vec3(1,1,1) );
}

/++ returns:
    mean (0 element), variance (1 element)
+/
auto mean_variance(R)( R r ) pure nothrow @property @nogc
if( isInputRange!R ) { return variance!true(r); }

///
unittest
{
    auto a = [ 1.0f, 1, 1 ];
    assertEq( a.mean_variance, [ 1.0f, 0.0f ] );

    auto b = [ 1.0f, 2, 3 ];
    assertEq( b.mean_variance, [ 2.0f, 1.0f ] );
}

///
unittest
{
    import des.math.linear.vector;

    auto a = [ vec3(1,2,3), vec3(2,3,4), vec3(3,4,5) ];
    assertEq( a.mean_variance, [ vec3(2,3,4), vec3(1,1,1) ] );
}

///
auto rawMoment(R)( R r, size_t k=1 ) pure nothrow @property @nogc
if( isInputRange!R )
in { assert( !r.empty ); } body
{
    alias T = Unqual!(ElementType!R);

    static assert( canSumWithSelfAndMulWithFloat!T,
            "range elements must can sum with selfs and mul with float" );

    T res = r.front * 0.0f;
    size_t cnt = 0;
    foreach( v; r )
    {
        res = res + spow( v, k );
        cnt++;
    }
    return res * ( 1.0f / cnt );
}

///
unittest
{
    auto a = [ 1.0f, 2 ];
    assertEq( a.rawMoment, 1.5 );
    assertEq( a.rawMoment(2), 2.5 );
}

/// power ( works with vectors )
T spow(T)( in T val, size_t k )
if( is( typeof( T.init / T.init ) == T ) && is( typeof( T.init * T.init ) == T ) )
{
    if( k == 0 ) return val / val;
    if( k == 1 ) return val;
    if( k == 2 ) return val * val;

    /+ small types (numbers,vectors)
     + recursion is faster
     + on BigInt logarifmic is faster
     +/

    // recursion
    T ret = spow( val*val, k/2 );
    if( k % 2 ) ret = ret * val;
    return ret;

    // logarifmic
    //auto n = k;
    //T buf = val / val;
    //T ret = val;
    //while( n > 1 )
    //{
    //    if( n % 2 ) buf = buf * ret;
    //    ret = ret * ret;
    //    n /= 2;
    //}
    //return ret * buf;
}

///
unittest
{
    import des.math.linear.vector;
    assertEq( spow( vec3( 1, 2, 3 ), 3 ), vec3( 1, 8, 27 ) );
    foreach( i; 0 .. 16 ) assertEq( spow( 10, i ), 10 ^^ i,
            format( "spow fails (%%s != %%s) with i: %s",  i ) );
}

///
auto centralMoment(R)( R r, size_t k=1 ) pure nothrow @property @nogc
if( isInputRange!R )
{
    alias T = Unqual!(ElementType!R);

    static assert( canSumWithSelfAndMulWithFloat!T,
            "range elements must can sum with selfs and mul with float" );

    T res = r.front * 0.0f; // neitral value for summate ( a + b*0 == a )
    size_t cnt = 0;
    auto m = r.mean;
    T buf;
    foreach( val; r )
    {
        static if( is( typeof( T.init - T.init ) == T ) )
            buf = val - m;
        else
            buf = val + m * (-1.0f);

        res = res + spow( buf, k );
        cnt++;
    }

    return res * ( 1.0f / cnt );
}

///
unittest
{
    auto a = [ 1.0f, 2, 3, 4 ];
    assertEq( a.centralMoment(1), 0 );
    assertEq( a.centralMoment(2), 1.25 );
    assertEq( a.centralMoment(3), 0 );
}

///
class MovingAverage(T) if( is(typeof(T[].init.mean)) )
{
    ///
    T[] array;

    size_t cur = 0;
    size_t fill = 0;

    ///
    this( size_t mlen ) { array.length = mlen; }

    invariant()
    {
        assert( array.length > 0 );
        assert( array.length >= fill );
    }

    ///
    void put( in T val )
    {
        if( array.length > fill )
        {
            array[fill] = val;
            cur++;
            fill++;
        }
        else array[cur++%$] = val;
    }

    ///
    T avg() const @property
    { return array[0..fill].mean; }
}

///
unittest
{
    auto ma = new MovingAverage!float( 3 );
    assertThrown!AssertError( ma.avg );
    ma.put( 1 );
    assertEq( ma.avg, 1 );
    ma.put( 1 );
    assertEq( ma.avg, 1 );
    ma.put( 4 );
    assertEq( ma.avg, 2 );
    ma.put( 4 );
    ma.put( 4 );
    assertEq( ma.avg, 4 );
    assertEq( ma.array.length, 3 );
}
