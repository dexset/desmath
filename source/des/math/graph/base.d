module des.math.graph.base;

struct WTable(T)
{
private:
    T[] data;
    size_t _width;

public:

    this( size_t sz, T init_value=T.init )
    {
        _width = sz;
        data.length = sz * sz;
        data[] = init_value;
    }

    size_t size() pure const @property { return _width; }

    T opIndex( size_t from, size_t to ) const pure
    { return data[ from*size + to ]; }

    ref T opIndex( size_t from, size_t to ) pure
    { return data[ from*size + to ]; }

    int opApply( int delegate(size_t, size_t, T) dlg ) const
    {
        foreach( i, w; data )
            if( auto r = dlg( i/size, i%size, w ) )
                return r;
        return 0;
    }

    int opApply( int delegate(size_t, size_t, ref T) dlg )
    {
        foreach( i, ref w; data )
            if( auto r = dlg( i/size, i%size, w ) )
                return r;
        return 0;
    }
}

struct Path(T)
{
    T cost;
    size_t[] nodes;
}
