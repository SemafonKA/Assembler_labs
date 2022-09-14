//#include <iostream>
//#include <cstring>
//#include <cmath>
//
//using namespace std;
//
//int HexToDecimal(char* hexNumStr);
//
//void rmain()
//{
//   char a[10];
//   char b[10];
//   cin >> a >> b;
//
//   // Первое число
//   int a1 = HexToDecimal(a);
//   int b1 = HexToDecimal(b);
//
//   a1 -= b1;
//   cout << a1 << endl;
//}
//
//int HexToDecimal(char* hexNumStr)
//{
//   int a1 = 0;
//   int p = strlen(hexNumStr) - 1;
//   for (int i = 0; i < strlen(hexNumStr); i++)
//   {
//      int k = hexNumStr[i] - '0';
//      if (k > 9)
//      {
//         k = hexNumStr[i] - 'A' + 10;
//      }
//      a1 += k * pow(16, p);
//      p--;
//   }
//   return a1;
//}