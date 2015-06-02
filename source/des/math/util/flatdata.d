module des.math.util.flatdata;

import std.traits;
import std.string;
import std.typetuple;

import des.ts;
import des.stdx.traits;
import des.math.linear.vector;
public import des.stdx.range : flatData;

///
template hasIterableData(T)
{ enum hasIterableData = is( typeof( isIterable!(typeof(T.init.data)) ) ); }

///
template hasStaticIterableData(T)
{
    static if( hasIterableData!T )
        enum hasStaticIterableData = isStaticArray!(typeof(T.init.data));
    else
        enum hasStaticIterableData = false;
}

bool canStaticFill(size_t N,T,E...)() pure @property
if( E.length > 0 )
{ return hasNoDynamic!E && N == getElemCount!E && isConvertable!(T,E); }

bool hasNoDynamic(E...)() pure @property
{
    static if( E.length == 1 ) return !hasIndirections!(E[0]);
    else return hasNoDynamic!(E[0]) && hasNoDynamic!(E[1..$]);
}

size_t getElemCount(E...)() pure @property
{
    static if( E.length == 0 ) return 0;
    else static if( E.length >= 1 )
        return getTypeElemCount!(E[0]) + getElemCount!(E[1..$]);
}

size_t getTypeElemCount(E)() pure @property
{
    static if( isStaticArray!E ) return E.length;
    else static if( hasStaticIterableData!E ) return E.data.length;
    else return 1;
}

bool isConvertable(T,E...)() pure @property
{
    static if( E.length == 1 )
    {
        alias E[0] X;
        static if( is( typeof( T(X.init) ) ) ) return true;
        else static if( isComplex!T && ( isNumeric!X || isImaginary!X ) ) return true;
        else static if( isNumeric!X && isNumeric!T ) return true;
        else static if( isStaticArray!X ) return isConvertable!(T,typeof(X.init[0]));
        else static if( isStaticVector!X )
        {
            static if( isStaticVector!T )
                return T.length == X.length && isConvertable!(T.datatype,X.datatype);
            else
                return isConvertable!(T,X.datatype);
        }
        else return false;
    }
    else return isConvertable!(T,E[0]) && isConvertable!(T,E[1..$]);
}

string vectorStaticFill(string type, string data, string vals, T, E...)() pure @property
if( E.length > 0 )
{
    string[] ret;
    static if( isStaticVector!T )
    {
        ret ~= convertValues!(T.datatype,E)( type~".datatype", data, vals );
        foreach( i, ref r; ret )
            r = format( "%1$s[%2$s/%3$s][%2$s%%%3$s] = %4$s;", data, i, T.length, r );
    }
    else
    {
        ret ~= convertValues!(T,E)( type, data, vals );
        foreach( i, ref r; ret )
            r = format( "%s[%s] = %s;", data, i, r );
    }
    return ret.join("\n");
}

string matrixStaticFill(string type, string data, string vals, size_t W, T, E...)() pure @property
if( E.length > 0 )
{
    string[] ret;
    ret ~= convertValues!(T,E)( type, data, vals );
    foreach( i, ref r; ret )
        r = format( "%s[%s][%s] = %s;", data, i/W, i%W, r );
    return ret.join("\n");
}

string[] convertValues(T,E...)( string type, string data, string vals, size_t valno=0 ) pure
{
    static if( E.length == 1 )
        return convertValue!(T,E[0])(type,data,vals,valno);
    else
        return convertValue!(T,E[0])(type,data,vals,valno) ~ 
               convertValues!(T,E[1..$])(type,data,vals,valno+1); 

}

string[] convertValue(T, E)( string type, string data, string vals, size_t valno ) pure
{
    static if( isStaticArray!E || isStaticVector!E )
    {
        string[] ret;
        foreach( i; 0 .. E.length )
            ret ~= format( convertRule!(T,typeof(E.init[0])), type, format( "%s[%d][%d]", vals, valno, i ) );
        return ret;
    }
    else
        return [ format( convertRule!(T,E), type, format( "%s[%d]", vals, valno ) ) ];
}

string convertRule(T,E)() pure @property
{
    static if( isNumeric!E && isNumeric!T )
        return "cast(%s)(%s)";
    else static if( isComplex!T && ( isNumeric!E || isImaginary!E ) )
        return "%s(0+0i+%s)";
    else static if( is( typeof( T(E.init) ) ) )
        return "%s(%s)";
    else static assert( 0, "uncompatible types [convertRule]" );
}
