/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#include "gui.h"
#include <QtWidgets/QApplication>

int main(int argc, char *argv[])
{

    QApplication a(argc, argv);
    gui w;
    w.show();
    return a.exec();
}

