module kyotocabinet.exception;

import std.exception;

class KyotoCabinetException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}
