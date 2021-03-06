module des.math.method.calculus.integ;

import des.ts;
import des.stdx.traits;

import std.math;
import std.meta;

///
T euler(T,E1,E2,E3)( in T x, T delegate(in T,E1) f, E2 time, E3 h )
    if( hasBasicMathOp!T && allSatisfy!(isFloatingPoint,E1,E2,E3) )
{
    return x + f( x, time ) * h;
}

///
T runge(T,E1,E2,E3)( in T x, T delegate(in T,E1) f, E2 time, E3 h )
    if( hasBasicMathOp!T && allSatisfy!(isFloatingPoint,E1,E2,E3) )
{
    T k1 = f( x, time ) * h;
    T k2 = f( x + k1 * 0.5, time + h * 0.5 ) * h;
    T k3 = f( x + k2 * 0.5, time + h * 0.5 ) * h;
    T k4 = f( x + k3, time + h ) * h;
    return cast(T)( x + ( k1 + k2 * 2.0 + k3 * 2.0 + k4 ) / 6.0 );
}

unittest
{
    double a1 = 0, a2 = 0, pa = 5;
    double time = 0, ft = 10, step = .01;

    auto rpart( in double A, double time ) { return pa; }

    foreach( i; 0 .. 1000 )
    {
        a1 = euler( a1, &rpart, time+=step, step );
        a2 = runge( a1, &rpart, time+=step, step );
    }

    auto va = ft * pa;

    assertEqApprox( va, a1, step * pa * 2 );
    assertEqApprox( va, a2, step * pa );

    auto rpart2( in float A, double time ) { return pa; }

    static assert( !is(typeof( euler( a1, &rpart2, 0, 0 ) )));
}

unittest
{
    import des.math.util.mathstruct;

    static struct Pos
    {
        double x=0, y=0;
        mixin( BasicMathOp!"x y" );
    }

    static struct Point
    {
        Pos pos, vel;
        mixin( BasicMathOp!"pos vel" );
    }

    Pos acc( in Pos p )
    { return Pos( -(p.x * abs(p.x)), -(p.y * abs(p.y)) ); }

    Point rpart( in Point p, double time )
    { return Point( p.vel, acc(p.pos) ); }

    auto state1 = Point( Pos(50,10), Pos(5,15) );
    auto state2 = Point( Pos(50,10), Pos(5,15) );

    double t = 0, ft = 10, dt = 0.01;

    foreach( i; 0 .. 1000 )
    {
        state1 = euler( state1, &rpart, t+=dt, dt );
        state2 = runge( state2, &rpart, t+=dt, dt );
    }
}

///
unittest
{
    import des.math.linear.vector;
    import des.math.util.mathstruct;

    static struct Point
    {
        vec3 pos, vel;
        mixin( BasicMathOp!"pos vel" );
    }

    Point rpart( in Point p, double time )
    { return Point( p.vel, vec3(0,0,0) ); }

    auto v = Point( vec3(10,3,1), vec3(5,4,3) );

    double time = 0, ft = 10, step = .01;
    foreach( i; 0 .. 1000 )
        v = runge( v, &rpart, time+=step, step );

    assert( eq_approx( v.pos, vec3(60,43,31),  1e-3 ) );
}
