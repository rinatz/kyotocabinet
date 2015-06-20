module kyotocabinet.polydb;

import std.string;

debug import std.conv;
debug import std.stdio;

import kyotocabinet.exception;
import kyotocabinet.openmode;
import kyotocabinet.pack;

import kyotocabinet.c.kclangc;


class PolyDB
{
    private KCDB* _db;

    invariant()
    {
        assert(_db !is null);
    }

    this()
    {
        _db = kcdbnew();
    }

    this(string path, OpenMode mode)
    {
        _db = kcdbnew();
        open(path, mode);
    }

    ~this()
    {
        close();
        kcdbdel(_db);
    }

    bool open(string path, OpenMode mode) @safe nothrow
    {
        return cast(bool)_db.kcdbopen(path.toStringz, mode);
    }

    void close() @safe nothrow
    {
        _db.kcdbclose();
    }

    string errorString() @trusted nothrow
    {
        import std.c.string;
        auto msg = _db.kcdbemsg;
        return msg[0 .. msg.strlen].idup;
    }

    bool set(K, V)(K key, V value) @safe nothrow
    {
        auto p = Pack!K(key);
        return cast(bool)_db.kcdbset(p.ptr, p.size,
                                     value.pack, value.size);
    }

    V opIndexAssign(K, V)(V value, K key)
    {
        auto ok = set(key, value);
        if (!ok)
        {
            throw new KyotoCabinetException(errorString);
        }
        return value;
    }

    const(char)[] get(K)(K key) nothrow
    {
        size_t size;
        auto buf = _db.kcdbget(key.pack, key.size, &size);
        scope(success) kcfree(buf);

        if (buf is null)
        {
            return null;
        }

        return buf[0 .. size].dup;
    }

    const(char)[] opIndex(K)(K key) nothrow
    {
        return get(key);
    }

    bool hasKey(T)(T key) nothrow
    {
        auto p = Pack!T(key);
        return _db.kcdbcheck(p.ptr, p.size) != -1;
    }

    template opBinaryRight(string op) if (op == "in")
    {
        auto opBinaryRight(T)(T key) nothrow
        {
            return get(key);
        }
    }
}

version (unittest):

import std.file;
import std.typecons;

private enum path = "__test__polydb__.kch";

void main() {}

unittest
{
    auto db = new PolyDB(path, OpenMode.write | OpenMode.create);
    scope(exit)
    {
        db.close();
        std.file.remove(path);
    }

    auto key = "Hello";
    auto value = "KyotoCabinet!";

    db[key] = value;

    assert(key in db);
    assert(db[key].as!string == value);
}

unittest
{
    auto db = scoped!PolyDB(path, OpenMode.write | OpenMode.create);
    scope(exit)
    {
        db.close();
        std.file.remove(path);
    }

    struct Foo
    {
        int foo1;
        int foo2;
    }

    auto key = Foo(10, 20);
    auto value = Foo(100, 200);

    db[key] = value;

    assert(key in db);
    assert(db[key].as!Foo == value);
}
