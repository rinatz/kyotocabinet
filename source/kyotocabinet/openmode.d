module kyotocabinet.openmode;

import kyotocabinet.c.kclangc;

enum OpenMode
{
    read = KCOREADER,
    write = KCOWRITER,
    create = KCOCREATE,
    truncate = KCOTRUNCATE,
    autoTran = KCOAUTOTRAN,
    autoSync = KCOAUTOSYNC,
    noLock = KCONOLOCK,
    tryLock = KCOTRYLOCK,
    noRepair = KCONOREPAIR
}
