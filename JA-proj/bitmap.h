/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#ifndef BITMAP_H
#define BITMAP_H

#include <fstream>
#include <iostream>
#include <memory>
#include <filesystem>
#include <exception>
#include <Windows.h>
#include <cstddef>
#define BITMAP_FILE_HEADER_SIZE 14
#define OFF_TO_PIXELS_BYTE 10
#define OFF_TO_WIDTH_BYTE 4
#define OFF_TO_HEIGHT_BYTE 8

struct file_exception : public std::exception
{
	const char* what() const throw ()
	{
		return "File error";
	}
};

inline bool check_file_type(char* header) {
	if (header[0] == 'B' && header[1] == 'M')
		return true;
	else
		return false;
}
inline UINT64 get_avaiable_memory() {
	MEMORYSTATUSEX status;
	status.dwLength = sizeof(status);
	GlobalMemoryStatusEx(&status);
	return status.ullAvailPhys;
}

unsigned int get_int(BYTE* data, int offset);

class bitmap {
public:
	BYTE* bitmap_header;
	BYTE* DIB_header;
	
	UINT64 filesize;
	int padding;
	std::ifstream* file_stream;
	std::ofstream* out_file_stream;
	int DIB_header_szie;
	std::filesystem::path file_path;
	std::filesystem::path out_file_path;

	bitmap() = default;
	bitmap(std::filesystem::path in_file_path, std::filesystem::path out_file_path);
	UINT64 data_size;
	void gray_scale();
	void prepare();
	void save_result();
	int row_size;
	int width;
	int height;
	BYTE* data;
	BYTE* result;

};
#endif