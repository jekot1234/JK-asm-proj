/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania kraw�dzi w obrazie. Warto�� piksela wyznaczana jest na podstawie
 * przemno�enia masek z pikselami s�siaduj�cymi i obliczenie pierwiastka sumy kwadrat�w
 * z sumy wynik�w otrzymanych z mno�enia ka�dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#pragma once

#ifndef GUI_H
#define GUI_H

#include <filesystem>
#include <thread>
#include <QtWidgets/QMainWindow>
#include <qtimer.h>
#include "ui_gui.h"
#include "timer.h"


class gui : public QMainWindow
{
    Q_OBJECT

private:
    //w�tek odpowiadaj�cy za zarzadzanie przetwarzaniem obrazu
    std::thread* main_execution_thread;
    //zegar odpowiedzialny za od�wie�anie interfejsu graficznego
    QTimer* qtimer;
    //sprawdzenie czy podane zosta�y obie �cie�ki plik�w
    bool check_file_input();
public:
    //pole okre�laj�ce wybran� bibliotek�
    bool asmlib;
    //pole przechowuj�ce informacj� o zapisie hitogramu
    bool hist;
    //pole przechowuj�ce informacj� o ilo�ci wybranych w�tk�w
    int threadnum;
    //pole informuj�ce czy program skonczyl przetwarzac plik
    bool ready;
    //zegar czasu przetwarzania
    timer* elapsed_time;
    //klasa interfejsu
    Ui::guiClass ui;
    //sciezki do plikow zapisu, odczytu
    std::filesystem::path in_fspath;
    std::filesystem::path out_fspath;

    //konstruktor
    gui(QWidget* parent = Q_NULLPTR);
    void update_status_text(QString status);

    //metody interfejsu graficznego
private slots:
    void on_checkBox_savehist_clicked(bool arg1);
    void on_pushButton_start_clicked();
    void on_pushButton_exit_clicked();
    void on_radioButton_cpplib_clicked();
    void on_radioButton_asmlib_clicked();
    void on_spinBox_thread_valueChanged(int arg1);
    void on_pushButton_filein_clicked();
    void on_pushButton_fileout_clicked();
public slots:
    void update();
    void start_execution() {};


};

#endif // !GUI_H


