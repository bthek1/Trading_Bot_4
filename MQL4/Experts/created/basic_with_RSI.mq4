//+------------------------------------------------------------------+
//|                                               basic_with_RSI.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//RSI levels are from 0-100, select levels for overbrought and oversold
//and the inputs to RSI
input int                  InpRSIPeriods     =  10;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

// The levels
input double               InpOversoldLevel  = 30.0;           //Oversold level
input double               InpOverboughLevel = 70.0;           //Overbought level

//Take profit and stop loss as each criteria for each trade
//A simple way to exit
input double               InpTakeProfit     =  0.01;          //Take profit in currency value
input double               InpStopLoss       =  0.01;          //Stop loss in currency value


//Standard inputs - you should have something like this in every EA
input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  111111;           //Magic number - identifies these


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(checkInput() != INIT_SUCCEEDED)
      return (INIT_FAILED);

//--- create timer
   EventSetTimer(60);

   Alert("INIT_SUCCEEDED");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   Alert("OnDeinit");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static bool oversold    = false;
   static bool overbought  = false;

   if(!newBar())
      return;  //only trade on a new bar


//Bar 0 is currently open , bar 1 is the most recent closed bar hence 1 at the end
   double rsi = iRSI(Symbol(), Period(), InpRSIPeriods, InpRSIPRICE, 1);

//get the direction of the last bar. This will just give a positive number
// for up and a negative number for down
   double direction = iClose(Symbol(), Period(), 1) - iOpen(Symbol(), Period(), 1);

// If RSI has crossed the midpoint, then clear any old flags
   if(rsi > 50)
     {
      oversold = false;
     }

   if(rsi < 50)
     {
      overbought = false;
     }

//Next check if the flags should be set
//Note not just assigning the comparison to the value.
//This keeps any flags already set intact
   if(rsi > InpOverboughLevel)
      overbought = true; //80
   if(rsi < InpOversoldLevel)
      oversold = true;    //20


   int ticket = 0;
   if(oversold && (rsi > InpOversoldLevel) && (direction > 0))
     {
      ticket = OrderOpen(ORDER_TYPE_BUY, InpStopLoss, InpTakeProfit);
      oversold = false;
      Alert("Buy trade");
     }

   if(overbought && (rsi > InpOverboughLevel) && (direction < 0))
     {
      ticket = OrderOpen(ORDER_TYPE_SELL, InpStopLoss, InpTakeProfit);
      overbought = false;
      Alert("Sell trade");
     }

///////////////////Finished//////////////////

   int tradeCount = CalculateCurrentOrders();
   Alert("new data  : ", Open[1], " : ", Close[1], "   rsi: ", rsi, "   trades: ", tradeCount);

   return;

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
//|  input check                                                                |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE checkInput()
  {

//put some code her to check any inpout rules
//periods must be positive
   if(InpRSIPeriods <= 0)
      return (INIT_PARAMETERS_INCORRECT);


   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//|   new bar from time passing                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {
   datetime currentTime = iTime(Symbol(), Period(), 0);  //Gets the opening time of bar
   static datetime priorTime =  currentTime;    //Initialised to prevent trading on trhe first bar after
   bool result = (currentTime != priorTime);    //
   priorTime =  currentTime;
   return (result);
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit)
  {

   int ticket = 0;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

//calculate the open price, take profit and stop loss prices based on the order type

   if(orderType == ORDER_TYPE_BUY)
     {
      openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice - stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice + takeProfit, Digits());
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, stopLossPrice, takeProfitPrice, InpTradeComment, InpMagicNumber);

     }
   if(orderType == ORDER_TYPE_SELL)
     {
      openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());

      stopLossPrice = (stopLoss == 0.0) ? 0.0 : NormalizeDouble(openPrice + stopLoss, Digits());
      takeProfitPrice = (takeProfit == 0.0) ? 0.0 : NormalizeDouble(openPrice - takeProfit, Digits());
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, stopLossPrice, takeProfitPrice, InpTradeComment, InpMagicNumber);
     }
   return ticket;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int CalculateCurrentOrders()
  {
   int buys=0,sells=0;
//---
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber)
        {
         if(OrderType()==OP_BUY)
            buys++;
         if(OrderType()==OP_SELL)
            sells++;
        }
     }
//--- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
