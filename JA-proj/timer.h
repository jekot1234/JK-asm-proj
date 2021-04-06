/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#ifndef TIMER_H
#define TIMER_H

#include <time.h>
#include <string>
#include <sstream>
class timer {
	int start_clocks;
	int curr_clocks;
	double clocks_per_sec;
	bool on;
public:
	timer() {
		clocks_per_sec = double(CLOCKS_PER_SEC);
		start_clocks = 0;
		curr_clocks = 0;
		on = false;
	};
	void start() {
		on = true;
		start_clocks = clock();
	};
	void check() {
		if (on) {
			curr_clocks = clock();
		}
	}
	void stop() {
		on = false;
	}

	std::string to_string() {

		long mils = (curr_clocks - start_clocks) / (clocks_per_sec / 1000);
		int min = mils / 60000;
		mils -= min * 60000;
		int sec = mils / 1000;
		mils -= sec * 1000;
		std::string time;
		time.append(std::to_string(min));
		time.append(":");
		if (sec > 10) {
			time.append(std::to_string(sec));
		}
		else {
			time.append("0");
			time.append(std::to_string(sec));
		}

		time.append(".");
		if (mils > 100) {
			time.append(std::to_string(mils));

		}
		else if (mils > 10) {
			time.append("0");
			time.append(std::to_string(mils));
		}
		else {
			time.append("00");
			time.append(std::to_string(mils));
		}
		return time;
	}

	int get_sec() {
		long mils = (curr_clocks - start_clocks) / (clocks_per_sec / 1000);
		int min = mils / 60000;
		mils -= min * 60000;
		return mils / 1000;
	}

};
#endif // !TIMER_H

