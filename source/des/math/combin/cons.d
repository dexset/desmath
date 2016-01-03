module des.math.combin.cons;

import std.algorithm;
import std.typecons;
import std.range;

auto partialPermutationS(R...)( R rngs )
{
    static if( R.length == 1 )
    {
        alias RF = R[0];
        static if( !isTuple!RF ) return rngs[0];
        else return partialPermutationS( rngs[0].expand );
    }
    else static if( R.length > 2 )
        return partialPermutationS( partialPermutationS( rngs[0] ),
                                    partialPermutationS( rngs[1..$] ) );
    else static if( R.length == 2 )
    {
        alias A = typeof( partialPermutationS( rngs[0] ) );
        alias B = typeof( partialPermutationS( rngs[1] ) );

        static struct Result
        {
            A a; B b, orig;

            this( A a, B b ) { this.a = a; this.b = b; orig = b; }

            bool empty() @property { return a.empty; }

            void popFront()
            {
                b.popFront();
                if( b.empty )
                {
                    a.popFront();
                    b = orig;
                }
            }

            auto front() @property
            {
                return tuple( wrapTuple(a.front).expand,
                              wrapTuple(b.front).expand );
            }
        }

        return Result( partialPermutationS(rngs[0]), partialPermutationS(rngs[1]) );
    }
    else static assert(0, "zero ranges can not be permutated" );
}

unittest
{
    auto pp = partialPermutationS( iota(2), iota(3) );
    auto exp = [ tuple(0,0), tuple(0,1), tuple(0,2),
                 tuple(1,0), tuple(1,1), tuple(1,2) ];
    assert( equal( pp, exp ) );
}

unittest
{
    auto pp1 = partialPermutationS( hCube!2(iota(3)), ["alpha","beta","gamma"], hCube!2(iota(6)) );
    auto pp2 = partialPermutationS( iota(3), iota(3), ["alpha","beta","gamma"], iota(6), iota(6) );
    assert( equal( pp1, pp2 ) );
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
{
    static struct Result
    {
        R[] r, orig;

        this( R[] r ) { this.r = r; orig = r.dup; }

        bool empty() @property { return r[0].empty; }

        void popFront()
        {
            auto N = r.length;
            ptrdiff_t t = N - 1;
            r[t].popFront();
            if( r[t].empty )
            {
                while( r[t].empty && t > 0 )
                {
                    t--;
                    r[t].popFront;
                }
                foreach( i; t+1 .. N )
                    r[i] = orig[i];
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
