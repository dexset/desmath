module des.math.graph.fw;

import std.range;
import std.math;
import std.traits;
import std.algorithm;

import des.math.graph.base;

bool hasValue(T)( T v ) @property
if( isFloatingPoint!T )
{ return abs(v) !is T.nan && abs(v) !is T.infinity; }

bool hasValue(T)( T v ) @property
if( isIntegral!T ) { return v != -1; }

/// Floyd–Warshall algorithm
auto findGraphShortestPathsFW(T)( WTable!T link_table )
{
    static struct Result
    {
        WTable!T W;
        WTable!ptrdiff_t H;

        auto opIndex( size_t from, size_t to ) const
        {
            Path!T ret;
            if( !W[from,to].hasValue ) return ret;
            
            ret.cost = W[from,to];
            auto s = from;
            while( s != to )
            {
                ret.nodes ~= s;
                s = H[s,to];
            }
            ret.nodes ~= to;
            return ret;
        }
    }

    auto N = link_table.size;
    auto W = WTable!T( N, T.infinity );
    auto H = WTable!ptrdiff_t( N, -1 );

    foreach( from, to, w; link_table )
    {
        if( w.hasValue )
        {
            W[from,to] = w;
            H[from,to] = to;
        }
    }

    foreach( C; iota(N) )
        foreach( A; iota(N) )
        {
            if( C == A ) continue;
            foreach( B; iota(N) )
            {
                if( B == C || B == A ) continue;
                if( W[A,B] > W[A,C] + W[C,B] )
                {
                    W[A,B] = W[A,C] + W[C,B];
                    H[A,B] = H[A,C];
                }
            }
        }

    return Result( W, H );
}

unittest
{
    auto lt = WTable!float( 8, float.nan );

    lt[0,1] = lt[1,0] = 6.0;
    lt[0,2] = lt[2,0] = 3.0;
    lt[0,3] = lt[3,0] = 2.0;

    lt[1,2] = lt[2,1] = 3.0;
    lt[1,3] = lt[3,1] = 1.0;
    lt[1,4] = lt[4,1] = 1.0;

    lt[2,5] = lt[5,2] = 7.0;
    lt[2,7] = lt[7,2] = 6.0;

    lt[3,4] = lt[4,3] = 3.0;

    lt[4,5] = lt[5,4] = 2.0;

    lt[5,7] = lt[7,5] = 1.0;
    lt[5,6] = lt[6,5] = 3.0;

    lt[6,7] = lt[7,6] = 1.0;

    auto fwr = findGraphShortestPathsFW( lt );

    auto path = fwr[0,6];

    assert( equal( path.nodes, [0,3,1,4,5,7,6] ) );
}
