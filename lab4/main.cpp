#include <iostream>

using namespace std;

extern "C"
int Compute(float x, float* y);

int main() {
   setlocale(LC_ALL, "ru-RU");
   float x, y;
   cout << "������� ����� �: ";
   cin >> x;

   if (Compute(x, &y))
   {
      cout << "������ �� ����� ����������: ������� �� ����." << endl;
   }
   else
   {
      cout << "���������� ��������: " << y << endl;
   }
   return 0;
}