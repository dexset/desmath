module des.math.combin.cons;

import std.algorithm;
import std.typecons;
import std.range;
import std.meta;

auto combinations(T...)( T tpls )
{
    auto result(R...)( R rrr )
        if( allSatisfy!(isInputRange,R) )
    {
        static struct Result
        {
            R r, orig; // храним текущее состояние и исходное

            this( R r ) { this.r = r; orig = r; }

            bool empty() @property { return r[0].empty; }

            void popFront()
            {
                foreach_reverse( ref x; r )
                {
                    x.popFront();
                    if( !x.empty ) break;
                }

                foreach( i, ref x; r[1..$] )
                {
                    if( x.empty )
                        x = orig[i+1];
                }
            }

            auto front() @property { return getFronts( r ); }
        }

        return Result(rrr);
    }

    auto wrapTuples(X...)( X t ) pure
    {
        static if( X.length == 1 )
        {
            static if( isTuple!(X[0]) )
                return wrapTuples( t[0].expand );
            else
                return tuple( t[0] );
        }
        else static if( X.length > 1 )
            return tuple( wrapTuples(t[0]).expand, wrapTuples(t[1..$]).expand );
    }

    return result( wrapTuples(tpls).expand );
}

unittest
{
    auto pp = combinations( iota(2), iota(3) );
    auto exp = [ tuple(0,0), tuple(0,1), tuple(0,2),
                 tuple(1,0), tuple(1,1), tuple(1,2) ];
    assert( equal( pp, exp ) );
}

unittest
{
    auto pp1 = combinations( hCube!2(iota(3)), ["alpha","beta","gamma"], hCube!2(iota(6)) );
    auto pp2 = combinations( iota(3), iota(3), ["alpha","beta","gamma"], iota(6), iota(6) );
    assert( equal( pp1, pp2 ) );
}

auto getFronts(R...)( R r )
    if( allSatisfy!(isInputRange,R) )
{
    static if( R.length == 1 ) return tuple( r[0].front );
    else static if( R.length > 1 )
        return tuple( getFronts(r[0]).expand, getFronts(r[1..$]).expand );
    else static assert(0, "no ranges - no fronts" );
}

auto hCube(size_t N,R)( R r )
{
    static if( N == 0 ) return tuple();
    static if( N == 1 ) return tuple(r);
    else return tuple( r, hCube!(N-1)(r).expand );
}

unittest
{
    auto hc = hCube!3(iota(5));
    static assert( hc.length == 3 );
    assert( equal( hc[0], iota(5) ) );
    assert( equal( hc[1], iota(5) ) );
    assert( equal( hc[2], iota(5) ) );
}

auto wrapTuple(T)( T val )
{
    static if( isTuple!T ) return val;
    else return tuple(val);
}

auto partialPermutation(R)( R r, size_t k )
    if( isInputRange!R )
{
    static struct Result
    {
        R[] r, orig; // храним текущее состояние и исходное

        this( R[] r ) { this.r = r; orig = r.dup; }

        bool empty() @property { return r[0].empty; }

        void popFront()
        {
            foreach_reverse( ref x; r )
            {
                x.popFront();
                if( !x.empty ) break;
            }

            foreach( i, ref x; r[1..$] )
            {
                if( x.empty )
                    x = orig[i+1];
            }
        }

        auto front() @property { return r.map!(a=>a.front); }
    }

    auto rr = new R[](k);
    rr[] = r;

    return Result( rr );
}

unittest
{
    auto pp = partialPermutation( iota(2), 3 );
    auto exp = [[0,0,0], [0,0,1], [0,1,0], [0,1,1],
                [1,0,0], [1,0,1], [1,1,0], [1,1,1]];
    assert( equal!equal( pp, exp ) );
}

auto uniqPartialPermutation(R)( R r, size_t k )
{
    bool noDups(T)( T v ) pure
    {
        foreach( i; 0 .. v.length )
            if( v[i+1..$].canFind( v[i] ) ) return false;
        return true;
    }
    return partialPermutation(r,k).filter!(a=>noDups(a));
}

unittest
{
    auto upp = uniqPartialPermutation( iota(3), 2 );
    auto exp = [[0,1],[0,2],[1,0],[1,2],[2,0],[2,1]];
    assert( equal!equal( upp, exp ) );
}

unittest
{
    auto upp = uniqPartialPermutation( iota(4), 3 );

    auto exp = [ [0, 1, 2], [0, 1, 3], [0, 2, 1], [0, 2, 3],
                 [0, 3, 1], [0, 3, 2], [1, 0, 2], [1, 0, 3],
                 [1, 2, 0], [1, 2, 3], [1, 3, 0], [1, 3, 2],
                 [2, 0, 1], [2, 0, 3], [2, 1, 0], [2, 1, 3],
                 [2, 3, 0], [2, 3, 1], [3, 0, 1], [3, 0, 2],
                 [3, 1, 0], [3, 1, 2], [3, 2, 0], [3, 2, 1] ];

    assert( equal!equal( upp, exp ) );
}
