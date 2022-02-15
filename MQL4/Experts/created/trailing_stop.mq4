//+------------------------------------------------------------------+
//|                                                trailing_stop.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


input int      InpTrailingStop      =  500;     //trailing stop points

input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  111115;           //Magic number - identifies these


double StopLoss;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   StopLoss = SymbolInfoDouble(Symbol(), SYMBOL_POINT)*InpTrailingStop;
//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {


   ApplyTrailingStop(Symbol(), InpMagicNumber, StopLoss);

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTrailingStop(string symbol, int magicNumber, double stoploss)
  {
   static int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   double buystoploss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID) - stoploss, digits);
   double sellstoploss = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK) + stoploss, digits);


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;
      //--- check order type
      if(OrderType()==ORDER_TYPE_BUY
         && buystoploss > OrderOpenPrice()
         && (OrderStopLoss() == 0 || buystoploss > OrderStopLoss()))
        {
         if(OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, OrderTakeProfit(), OrderExpiration(), Yellow)) {}
        }
      if(OrderType()==ORDER_TYPE_BUY
         && sellstoploss < OrderOpenPrice()
         && (OrderStopLoss() == 0 || sellstoploss < OrderStopLoss()))
        {
         if(OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, OrderTakeProfit(), OrderExpiration(), White)) {}
        }
     }
  }
//+------------------------------------------------------------------+
