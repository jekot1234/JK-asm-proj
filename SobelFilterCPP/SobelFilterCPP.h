// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the SOBELFILTERCPP_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see
// SOBELFILTERCPP_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef SOBELFILTERCPP_EXPORTS
#define SOBELFILTERCPP_API __declspec(dllexport)
#else
#define SOBELFILTERCPP_API __declspec(dllimport)
#endif
#include <windows.h>

extern "C" SOBELFILTERCPP_API void fnSobelFilter(BYTE* data, BYTE* result, UINT64 start, UINT64 stop, UINT64 row_size); //argumenty
