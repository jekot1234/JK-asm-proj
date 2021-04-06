/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#include "execution.h"
#include "histogram.h"
#include <filesystem>
#include <string>

typedef void(*fnSobelFilterCPP)(BYTE*, BYTE*, UINT64, UINT64, UINT64);

void wrap_fun(BYTE* data, BYTE* result, UINT64 start, UINT64 stop, UINT64 row_size, fnSobelFilterCPP DllFunction) {

    DllFunction(data, result, start, stop, row_size);

}

void execution(gui* user_interface) {

    user_interface->update_status_text(QString("Wczytywanie pliku"));
    bitmap* bmp;
    try {
        bmp = new bitmap(user_interface->in_fspath, user_interface->out_fspath);
    }
    catch (...) {
        user_interface->update_status_text(QString("Niepoprawny format pliku!"));
        user_interface->ready = true;
        return;
    }
    

    HMODULE DllLib = NULL;
    fnSobelFilterCPP DllFunction = NULL;

    if (!user_interface->asmlib) {
        try {
            DllLib = LoadLibraryA("..\\x64\\Debug\\SobelFilterCpp.dll");
            if (DllLib == NULL) {
                DllLib = LoadLibraryA("..\\x64\\Release\\SobelFilterCpp.dll");
                if (DllLib == NULL)
                    throw std::exception();
            }

        }
        catch (...) {
            user_interface->update_status_text(QString("B³¹d biblioteki!"));
            user_interface->ready = true;
            return;
        }
    }
    else {
        try {
            DllLib = LoadLibraryA("..\\x64\\Debug\\SobelFilterAsm.dll");
            if (DllLib == NULL) {
                DllLib = LoadLibraryA("..\\x64\\Release\\SobelFilterAsm.dll");
                if (DllLib == NULL)
                    throw std::exception();
            }

        }
        catch (...) {
            user_interface->update_status_text(QString("B³¹d biblioteki!"));
            user_interface->ready = true;
            return;
        }
    }


    if (user_interface->hist) {
        user_interface->update_status_text(QString("Tworzenie i zapisywanie histogramu"));
        createhistogram(bmp);
    }


    user_interface->update_status_text(QString("Przygotowywanie obrazu"));
    bmp->prepare();

    std::vector<std::thread> threads;
    user_interface->update_status_text(QString("Przetwarzanie obrazu"));


    int interval = (bmp->height) / user_interface->threadnum;
    int start = 1;
    int end = interval;
    int modulo = (bmp->height) % user_interface->threadnum;


    user_interface->elapsed_time->start();

    for (int i = 1; i <= user_interface->threadnum; i++) {

        if (i == user_interface->threadnum) {
            end += modulo - 1;
        }

        DllFunction = (fnSobelFilterCPP)GetProcAddress(DllLib, "fnSobelFilter");

        threads.emplace_back(wrap_fun, bmp->data, bmp->result, start, end, (UINT64)bmp->row_size, DllFunction);
        start += interval - 1;
        end += interval;

    }

    for (auto& t : threads) {
        t.join();
    }

    user_interface->elapsed_time->stop();

    FreeLibrary(DllLib);
    user_interface->update_status_text(QString("Zapisywanie obrazu"));
	bmp->save_result();


    user_interface->update_status_text(QString("Gotowe"));
	user_interface->ready = true;

    delete bmp;
}

