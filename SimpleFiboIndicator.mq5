//+------------------------------------------------------------------+
//|                                       SimpleFiboIndicator.mq5    |
//|                        Copyright 2023, MetaQuotes Ltd.           |
//|                                       https://www.mql5.com       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

//--- Nazwa obiektu Fibonacci na wykresie
#define FIB_OBJ "FibonacciRetracementDaily"

//--- Zmienna globalna przechowująca liczbę słupków, aby wykryć nowy słupek dzienny
int barsTotal;

//+------------------------------------------------------------------+
//| Funkcja inicjalizacji wskaźnika niestandardowego                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Inicjalizacja zmiennej barsTotal
   barsTotal = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Funkcja iteracji wskaźnika niestandardowego                      |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Pobranie liczby dostępnych słupków na wykresie dziennym
   int bars = iBars(_Symbol, PERIOD_D1);

//--- Sprawdzenie, czy pojawił się nowy słupek dzienny i czy minęła określona godzina (np. 5 minut po północy)
//--- aby upewnić się, że dane świecy dziennej są kompletne
   if(barsTotal != bars && TimeCurrent() > StringToTime("00:05"))
     {
      //--- Aktualizacja liczby słupków
      barsTotal = bars;

      //--- Usunięcie poprzedniego obiektu Fibonacci, jeśli istnieje
      ObjectDelete(0, FIB_OBJ);

      //--- Pobranie cen Open, Close, High, Low dla poprzedniej świecy dziennej (shift = 1)
      double openPrice  = iOpen(_Symbol, PERIOD_D1, 1);
      double closePrice = iClose(_Symbol, PERIOD_D1, 1);
      double highPrice  = iHigh(_Symbol, PERIOD_D1, 1);
      double lowPrice   = iLow(_Symbol, PERIOD_D1, 1);

      //--- Pobranie czasu otwarcia poprzedniej świecy dziennej i czasu zakończenia (dla rysowania obiektu)
      datetime startTime = iTime(_Symbol, PERIOD_D1, 1);
      datetime endTime   = iTime(_Symbol, PERIOD_D1, 0) - 1; // Koniec poprzedniej świecy [cite: 2]

      //--- Sprawdzenie, czy świeca była bycza (Close > Open)
      if(closePrice > openPrice)
        {
         //--- Utworzenie obiektu Fibonacci od Low do High dla świecy byczej
         ObjectCreate(0, FIB_OBJ, OBJ_FIBO, 0, startTime, lowPrice, endTime, highPrice);
         //--- Ustawienie koloru obiektu na zielony
         ObjectSetInteger(0, FIB_OBJ, OBJPROP_COLOR, clrGreen);
         //--- Ustawienie koloru poziomów Fibonacciego na zielony
         for(int i = 0; i < ObjectGetInteger(0, FIB_OBJ, OBJPROP_LEVELS); i++)
           {
            ObjectSetInteger(0, FIB_OBJ, OBJPROP_LEVELCOLOR, i, clrGreen);
           }

         //--- Obliczenie poziomów zniesienia Fibonacciego
         double fibLevel0   = highPrice;
         double fibLevel236 = NormalizeDouble(highPrice - (highPrice - lowPrice) * 0.236, _Digits);
         double fibLevel382 = NormalizeDouble(highPrice - (highPrice - lowPrice) * 0.382, _Digits);
         double fibLevel500 = NormalizeDouble(highPrice - (highPrice - lowPrice) * 0.500, _Digits);
         double fibLevel618 = NormalizeDouble(highPrice - (highPrice - lowPrice) * 0.618, _Digits);
         double fibLevel100 = lowPrice;
         
         //--- Wyświetlenie informacji na wykresie
         Comment("Poprzedni dzień (Bycza):\n",
                 "Open = ", openPrice, "\n",
                 "Close = ", closePrice, "\n",
                 "Fib 0.0% (High) = ", fibLevel0, "\n",
                 "Fib 23.6% = ", fibLevel236, "\n",
                 "Fib 38.2% = ", fibLevel382, "\n",
                 "Fib 50.0% = ", fibLevel500, "\n",
                 "Fib 61.8% = ", fibLevel618, "\n",
                 "Fib 100.0% (Low) = ", fibLevel100);
        }
      //--- W przeciwnym razie świeca była niedźwiedzia (Close < Open) lub doji (Close == Open)
      else
        {
         //--- Utworzenie obiektu Fibonacci od High do Low dla świecy niedźwiedziej
         ObjectCreate(0, FIB_OBJ, OBJ_FIBO, 0, startTime, highPrice, endTime, lowPrice);
         //--- Ustawienie koloru obiektu na czerwony
         ObjectSetInteger(0, FIB_OBJ, OBJPROP_COLOR, clrRed);
         //--- Ustawienie koloru poziomów Fibonacciego na czerwony
         for(int i = 0; i < ObjectGetInteger(0, FIB_OBJ, OBJPROP_LEVELS); i++)
           {
            ObjectSetInteger(0, FIB_OBJ, OBJPROP_LEVELCOLOR, i, clrRed);
           }

         //--- Obliczenie poziomów zniesienia Fibonacciego
         double fibLevel0   = lowPrice;
         double fibLevel236 = NormalizeDouble(lowPrice + (highPrice - lowPrice) * 0.236, _Digits);
         double fibLevel382 = NormalizeDouble(lowPrice + (highPrice - lowPrice) * 0.382, _Digits);
         double fibLevel500 = NormalizeDouble(lowPrice + (highPrice - lowPrice) * 0.500, _Digits);
         double fibLevel618 = NormalizeDouble(lowPrice + (highPrice - lowPrice) * 0.618, _Digits);
         double fibLevel100 = highPrice;

         //--- Wyświetlenie informacji na wykresie
         Comment("Poprzedni dzień (Niedźwiedzia):\n",
                 "Open = ", openPrice, "\n",
                 "Close = ", closePrice, "\n",
                 "Fib 0.0% (Low) = ", fibLevel0, "\n",
                 "Fib 23.6% = ", fibLevel236, "\n",
                 "Fib 38.2% = ", fibLevel382, "\n",
                 "Fib 50.0% = ", fibLevel500, "\n",
                 "Fib 61.8% = ", fibLevel618, "\n",
                 "Fib 100.0% (High) = ", fibLevel100);
        }
     }
  }
//+------------------------------------------------------------------+
//| Funkcja deinicjalizacji wskaźnika                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Usunięcie obiektu Fibonacci przy usuwaniu wskaźnika z wykresu
   ObjectDelete(0, FIB_OBJ);
//--- Usunięcie komentarza
   Comment("");
  }
//+------------------------------------------------------------------+