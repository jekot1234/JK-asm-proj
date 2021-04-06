/**
 * Projekt JA filtr Sobela
 * @author Jeremi Kot, grupa 2, rok III SSI
 * @version 1.0
 */
#include "bitmap.h"

//konwersja 4 bajtów w liczbê ca³kowit¹ bez znaku
inline unsigned int get_int(BYTE* data, int offset) {

	int value; //wartoœæ zwracana
	std::memcpy(&value, &data[offset], sizeof(int)); //kopiowanie pamiêci z tablicy do zmiennej

	return value;
}

bitmap::bitmap(std::filesystem::path in_file_path, std::filesystem::path out_file_path_) {

	file_path = in_file_path;	//przypisanie scie¿ki pliku

	file_stream = new std::ifstream(in_file_path, std::ios::binary);

	if (file_stream->fail()) {
		throw file_exception();
	}

	filesize = (UINT64)std::filesystem::file_size(file_path);
	if (filesize < BITMAP_FILE_HEADER_SIZE || !file_stream->is_open()) {		//Plik za ma³y aby za³adowaæ nag³ówek BMP
		throw file_exception();
	}

	//WCZTYTYWANIE BMP_HEADER
	char* char_bitmap_header = new char[BITMAP_FILE_HEADER_SIZE];		//Zaalokowanie pamiêci dla nag³ówka BMP
	file_stream->read(char_bitmap_header, BITMAP_FILE_HEADER_SIZE);	//Wczytanie nag³owka BMP

	if (!check_file_type(char_bitmap_header)) {		//B³¹d w podpisie nag³ówka BMP
		throw file_exception();
	}

	bitmap_header = (BYTE*)char_bitmap_header;

	//WCZYTYWANIE DIB_HEADER
	int offset_to_pixel_array = get_int(bitmap_header, OFF_TO_PIXELS_BYTE);

	DIB_header_szie = offset_to_pixel_array - BITMAP_FILE_HEADER_SIZE;

	char* char_DIB_header = new char[DIB_header_szie];
	file_stream->read(char_DIB_header, DIB_header_szie);	//Wczytanie reszty nag³ówka
	DIB_header = (BYTE*)char_DIB_header;

	width = get_int(DIB_header, OFF_TO_WIDTH_BYTE);
	height = get_int(DIB_header, OFF_TO_HEIGHT_BYTE);	//Wyznaczanie szerokoœci i wysokoœci pliku

	padding = (4 - (width * 3 % 4)) % 4;
	row_size = width * 3 + padding;

	data_size = filesize - DIB_header_szie - BITMAP_FILE_HEADER_SIZE;

	char* buffer = new char[filesize];
	file_stream->read(buffer, filesize);
	data = (BYTE*)buffer;

	file_stream->close();
	delete file_stream;
	file_stream = nullptr;
	out_file_path = out_file_path_;
	out_file_stream = new std::ofstream(out_file_path_, std::ios::binary);
	out_file_stream->write((char*)bitmap_header, BITMAP_FILE_HEADER_SIZE);
	out_file_stream->write((char*)DIB_header, DIB_header_szie);
}

void bitmap::save_result() {
	delete[] data;
	data = nullptr;
	out_file_stream->write((char*)result, filesize);
	delete[] result;
	result = nullptr;
	out_file_stream->close();
	delete out_file_stream;
	out_file_stream = nullptr;
}

void bitmap::gray_scale() {

	BYTE* bw_data = new BYTE[data_size / 3];
	int bw_data_i = 0;
	int pixel_sum;

	for (int i = 0; i < height; i++) {
		for (int j = 0; j < row_size; j+=3) {

			pixel_sum = (data[i * row_size + j] + data[i * row_size + j + 1] + data[i * row_size + j + 2])/3;

			bw_data[bw_data_i] = (BYTE)pixel_sum;

			bw_data_i++;
		}
	}

	delete[] data;
	data = bw_data;
	row_size /= 3;
}

void bitmap::prepare() {
	result = new BYTE[data_size];
	this->gray_scale();
}




