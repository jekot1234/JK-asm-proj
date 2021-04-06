// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the SOBELFILTERASM_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see
// SOBELFILTERASM_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef SOBELFILTERASM_EXPORTS
#define SOBELFILTERASM_API __declspec(dllexport)
#else
#define SOBELFILTERASM_API __declspec(dllimport)
#endif
#include <windows.h>

extern "C" SOBELFILTERASM_API void fnSobelFilter(BYTE* data, BYTE* result, UINT64 start, UINT64 stop, UINT64 row_size);

