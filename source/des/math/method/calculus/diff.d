module des.math.method.calculus.diff;

import des.math.linear;
import std.traits;

import des.ts;

///
auto df(size_t N, size_t M, T, E=T)
    ( Vector!(M,T) delegate( in Vector!(N,T) ) f, in Vector!(N,T) p, E step=E.epsilon*10 )
    if( isFloatingPoint!T && isFloatingPoint!E )
in { assert( f !is null ); } body
{
    Matrix!(M,N,T) ret;
    Vector!(N,T) p1, p2;
    T dstep = 2.0 * step;

    foreach( i; 0 .. N )
    {
        p1 = p2 = p;
        p1[i] -= step;
        p2[i] += step;
        ret.setCol( i, ( f(p2) - f(p1) ) / dstep );
    }

    return ret;
}

///
unittest
{
    import std.math : sqrt;
    auto func( in dvec2 p ) { return dvec3( p.x^^2, sqrt(p.y) * p.x, 3 ); }

    auto res = df( &func, dvec2(18,9), 1e-5 );
    auto must = Matrix!(3,2,double)( 36, 0, 3, 3, 0, 0 );

    assertEqApprox( res.asArray, must.asArray, 1e-5 );
}

///
auto df(T,K,E=T)( T delegate(T) f, K p, E step=E.epsilon*2 )
    if( isFloatingPoint!T && isFloatingPoint!E && is( K : T ) )
{
    alias V1 = Vector!(1,T);
    V1 f_vec( in V1 p_vec ) { return V1( f( p_vec[0] ) ); }
    return df( &f_vec, V1(p), step )[0][0];
}

///
unittest
{
    auto pow2( double x ){ return x^^2; }
    assertEqApprox( df( &pow2,  1 ), 2.0, 2e-6 );
    assertEqApprox( df( &pow2,  3 ), 6.0, 2e-6 );
    assertEqApprox( df( &pow2, -2 ), -4.0, 2e-6 );
}
