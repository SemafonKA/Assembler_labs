#include <iostream>

using namespace std;

extern "C"
int Compute(float x, float* y);

int main() {
   setlocale(LC_ALL, "ru-RU");
   float x, y;
   cout << "Введите число х: ";
   cin >> x;

   if (Compute(x, &y))
   {
      cout << "Ошибка во время вычислений: деление на ноль." << endl;
   }
   else
   {
      cout << "Полученное значение: " << y << endl;
   }
   return 0;
}