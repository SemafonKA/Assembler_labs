#include <iostream>

using namespace std;

extern "C"
float Compute(float x);

int main() {
   setlocale(LC_ALL, "ru-RU");
   float x;
   cout << "������� ����� �: ";
   cin >> x;
   float y = Compute(x);
   cout << "���������� ��������: " << y << endl;
   return 0;
}