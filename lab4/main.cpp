#include <iostream>

using namespace std;

extern "C"
float Compute(float x);

int main() {
   setlocale(LC_ALL, "ru-RU");
   float x;
   cout << "Введите число х: ";
   cin >> x;
   float y = Compute(x);
   cout << "Полученное значение: " << y << endl;
   return 0;
}