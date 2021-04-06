/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#include "gui.h"
#include <QFileDialog>
#include "execution.h"


gui::gui(QWidget* parent)
    : QMainWindow(parent)
{
    
    asmlib = false;
    threadnum = 1;
    elapsed_time = new timer();
    hist = false;
    ready = false;
    qtimer = new QTimer(this);
    ui.setupUi(this);
    ui.pushButton_start->setDisabled(true);
    ui.label_status->setText(QString("Oczekiwanie"));
    ui.spinBox_thread->setMaximum(std::thread::hardware_concurrency());
    ui.spinBox_thread->setMinimum(1);
    ui.radioButton_cpplib->setChecked(true);
    ui.checkBox_savehist->setChecked(false);
    ui.label_time->setText(QString("0:00.000"));
    ui.label_infile->setText(QString(" "));
    ui.label_outfile->setText(QString(" "));
}

void gui::update() {

    //wyswietlenie aktualnego czasu przetwarzania
    elapsed_time->check();
    ui.label_time->setText(QString((elapsed_time->to_string()).c_str()));
    ui.label_time->update();

    if (ready) {
        //jezeli program skonczyl prace
        ui.pushButton_start->setDisabled(false);
        main_execution_thread->join();
        qtimer->stop();
        ready = false;
    }
    else {
        //ustaw zegar odswiezania
        qtimer->start(4);
    }
}

//Metoda zamykaj¹ca okno
void gui::on_pushButton_exit_clicked() {
    close();
}

//Metoda s³u¿¹ca do aktualizacji pola status
void gui::update_status_text(QString status) {
    ui.label_status->setText(status);
    ui.label_status->update();
}

//Metoda s³u¿¹ca do sprawdzenia czy zosta³ wybrany zarówno plik zapisu jak i odczytu
bool gui::check_file_input() {

    if (!out_fspath.string().empty() && !in_fspath.string().empty()) {
        return true;
    }
    else {
        return false;
    }
}

//Metoda wywo³ana po uruchomieniu przetwarzania
void gui::on_pushButton_start_clicked() {
    ui.label_time->setText(QString((elapsed_time->to_string()).c_str()));
    ui.label_time->update();
    //tworzenie watku zarzadzajacego przetwarzaniem pliku
    main_execution_thread = new std::thread(execution, this);
    //polaczenie zegara odswiezania z metoda odswiezania interfejsu graficznego
    connect(qtimer, &QTimer::timeout, this, &gui::update);
    qtimer->start(4);
    ui.pushButton_start->setDisabled(true);
}

//Metoda wywo³ywana po wybraniu biblioteki C++
void gui::on_radioButton_cpplib_clicked() {
    asmlib = false;
}

//Metoda wywo³ywana po wybraniu biblioteki asemblera
void gui::on_radioButton_asmlib_clicked() {
    asmlib = true;
}

/*Metoda wywo³ywana po zmianie iloœci wybranych w¹tków
@param arg1 wybrana wartoœæ
*/
void gui::on_spinBox_thread_valueChanged(int arg1) {
    threadnum = arg1;
}

//Metoda wywo³ywana po wybraniu opcji wskazania pliku docelowego
void gui::on_pushButton_filein_clicked() {
    //otwarcie okna dialogowego
    QString qpath = QFileDialog::getOpenFileName(this, "Wybierz plik", "C://", "Bitmapa (*.bmp)");
    //ustawienie sciezki pliku
    ui.label_infile->setText(qpath);
    std::u16string stdpath(qpath.toStdU16String());
    in_fspath =  std::filesystem::path (stdpath);
    if (this->check_file_input()) {
        ui.pushButton_start->setDisabled(false);
    }
}

//Metoda wywo³ywana po wybraniu opcji wskazania pliku docelowego
void gui::on_pushButton_fileout_clicked() {
    //otwarcie okna dialogowego
    QString qpath = QFileDialog::getSaveFileName(this, "Wybierz miejsce zapisu", "C://", "Bitmapa (*.bmp)");
    //ustawienie sciezki pliku
    ui.label_outfile->setText(qpath);
    std::u16string stdpath(qpath.toStdU16String());
    out_fspath = std::filesystem::path(stdpath);
    if (this->check_file_input()) {
        ui.pushButton_start->setDisabled(false);
    }
}

//Metoda wywo³ywana przy wybraniu opcji zapisu histogramu
void gui::on_checkBox_savehist_clicked(bool arg1) {
    hist = arg1;
}

