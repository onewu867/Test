#ifndef MYLIB_H
#define MYLIB_H

#ifdef MYLIB_EXPORTS
#define MYLIB_API __declspec(dllexport)
#else
#define MYLIB_API __declspec(dllimport)
#endif

#ifdef MYLIB_STATIC
#define MYLIB_API
#endif

class MYLIB_API MyLib {
public:
    static int add(int a, int b);
    static int multiply(int a, int b);
    static const char* getVersion();
};

#endif // MYLIB_H

