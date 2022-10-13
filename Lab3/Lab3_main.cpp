#include <iostream>
#include <string>
using namespace std;

extern "C" 
void __fastcall DublStr(const char* inpStrPtr, uint32_t intStrSize, char* outStrPtr, uint32_t * outStrSizePtr, uint32_t repeats);

int main() {
   setlocale(LC_ALL, "ru-Ru");

   char inpStr[256];
   char outStr[512];
   uint32_t outStrLen = 512;
   uint32_t repeats = 0;
   cout << "������� ������ ��� ������������: ";
   cin >> inpStr;

   cout << "������� ����� ��������: ";
   cin >> repeats;
   if (repeats == 0) {
      cout << "������� �������� ����� ��������. ���������� ���������." << endl;
      return -1;
   }

   DublStr(inpStr, strlen(inpStr), outStr, &outStrLen, repeats);

   cout << "���������� ������: " << outStr << endl;
   return 0;
}