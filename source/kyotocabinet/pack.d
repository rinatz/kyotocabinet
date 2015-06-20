module kyotocabinet.pack;

import std.traits;

package struct Pack(T)
{
    const(char)* ptr;
    size_t size;

    this(T)(ref const(T) v)
    {
        ptr = v.pack();
        size = v.size;
    }
}

package const(char)* pack(T)(ref const(T) v) @trusted nothrow pure
{
    static if (isBasicType!T)
    {
        return cast(const(char)*)&v;
    }
    else static if (is(T == struct))
    {
        return cast(const(char)*)&v;
    }
    else static if (isArray!T)
    {
        return cast(const(char)*)v.ptr;
    }
    else static if (isPointer!T)
    {
        return pack(*v);
    }
    else
    {
        static assert("can't instantiate pack!" ~ T.stringof);
    }
}

package size_t size(T)(ref const(T) v) @safe nothrow pure
{
    static if (isBasicType!T)
    {
        return v.sizeof;
    }
    else static if (is(T == struct))
    {
        return v.sizeof;
    }
    else static if (isArray!T)
    {
        return ForeachType!T.sizeof * v.length;
    }
    else static if (isPointer!T)
    {
        return size(*v);
    }
    else
    {
        static assert("can't instantiate pack!" ~ T.stringof);
    }
}

T as(T)(const(char)[] v) nothrow
in
{
    assert(v !is null);
}
body
{
    static if (isArray!T)
    {
        return cast(T)v;
    }
    else
    {
        return *cast(const(T)*)v.ptr;
    }
}
