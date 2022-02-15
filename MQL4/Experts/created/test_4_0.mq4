//+------------------------------------------------------------------+
//|                                               basic_with_RSI.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//SYMBOL_ASK = buy price
//SYMBOL_BID = sell price

//buy and sell depending on the availble funds

//change stoploss distance

#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int                  InpRSIPeriods     =  30;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

input double               InpSellLevel  = 70.0;           //Sell level
input double               InpBuyLevel = 30.0;           //Buy level

input int                  InpMAPeriods      =  15;         //MovingAvg Periods
input int                  InpMAShift        =  0;          //MovingAvg Rightshift

input int                  Tradelimit        =  15;         //Number of trades allowed
input int                  InpTrailingStop   =  1;     //trailing stop points
//Standard inputs - you should have something like this in every EA
input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  100040;           //Magic number - identifies these

int timer, timer2, timer3;
int tradecondition[3];
int buycount, sellcount;
double StopLoss;

enum status {rsi, stoch, time_gap};
enum region {buy, sell, notrade};
enum trigger {reset, buyarmed, buytrigger, sellarmed, selltrigger};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   StopLoss = (max() - min())*0.1;
   EventSetTimer(1);
   printf("Success alert");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   printf("tear down alert");
  }
//+------------------------------------------------------------------+
//|  On timer                                                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
//Alert(max(), "   ", min(), "diff:  ", (max() - min())*0.05);
//Alert(Open[0], "asdf  ", SymbolInfoDouble(Symbol(), SYMBOL_ASK),  "asdf  ", SymbolInfoDouble(Symbol(), SYMBOL_BID));

   timer++;
   timer2++;
   timer3++;

   if(timer >= 5)
     {
      timer = 0;
      ApplyTrailingStop(StopLoss);
     }

   if(timer2 >= 60)
     {
      timer2 = 0;
      tradecondition[time_gap] = 1;
     }
   if(timer3 >= 60)
     {
      StopLoss = (max() - min())*0.1;
      timer3 = 0;
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int RSIPeriod = 30;
   double ordSize = 0.01;

   CalculateCurrentOrders(); //update buycount and sellcount

///////////////////////real////////////////////////////////////////a
   int ticket = 0;

   tradecondition[rsi] = RSI_check(RSIPeriod);  //return if in buy or sell region

   tradecondition[stoch] = STOCH_check(7, 5, 3, tradecondition[stoch]); //return if should trade or not

   if(tradecondition[rsi] == buy && tradecondition[stoch] == buytrigger && tradecondition[time_gap] == 1)
     {
      ticket = buy_trade(ordSize + 0.0025 * buycount);
      Alert(Symbol(), "buy trade:", buycount, " ordersize:", ordSize + 0.0025 * buycount);
      //ticket = buy_trade(ordSize);
      tradecondition[stoch] = reset;
      tradecondition[time_gap] = 0;
     }
   if(tradecondition[rsi] == sell && tradecondition[stoch] == selltrigger && tradecondition[time_gap] == 1)
     {
      ticket = sell_trade(ordSize + 0.0025 * sellcount);
      Alert(Symbol(), "sell trade:", sellcount, " ordersize:", ordSize + 0.0025 * sellcount);
      //ticket = sell_trade(ordSize);
      tradecondition[stoch] = reset;
      tradecondition[time_gap] = 0;
     }

   return;
  }
//+------------------------------------------------------------------+
//|  RSI_check                                                       |
//+------------------------------------------------------------------+
int RSI_check(int RSIperiod)
  {
   double RSI = iRSI(Symbol(), Period(), RSIperiod, PRICE_CLOSE, 1);
//Alert(RSI, "  ", buycount, "  ", sellcount);
   if(RSI <= (40-(1*buycount)))
     {
      //printf("buy %f  \n", RSI);
      return buy;
     }
   else
     {
      if(RSI > (60+(1*sellcount)))
        {
         //printf("sell %f \n ",RSI);
         return sell;
        }
     }
   return notrade;
  }
//+------------------------------------------------------------------+
//| STOCH_check                                                      |
//+------------------------------------------------------------------+
int STOCH_check(int k, int d, int slowing, int stoch_status)
  {
   double STOCH = iStochastic(Symbol(), 0, k, d, slowing, MODE_SMA, 0, MODE_MAIN, 0);

   if(STOCH < 20)
     {
      Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH >= 20 && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH > 80)
     {
      Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(STOCH <= 80 && stoch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }

//+------------------------------------------------------------------+
//|  buy_trade                                                       |
//+------------------------------------------------------------------+
int buy_trade(double orderSize)
  {
   if(sellcount > 0)
      Order_close(OP_SELL);
   else
      if(buycount < Tradelimit)
         return Order_open(OP_BUY, orderSize);
   return 0;
  }
//+------------------------------------------------------------------+
//| sell_trade                                                       |
//+------------------------------------------------------------------+
int sell_trade(double orderSize)
  {
   if(buycount > 0)
      Order_close(OP_BUY);
   else
      if(sellcount < Tradelimit)
         return Order_open(OP_SELL, orderSize);
   return 0;
  }
//+------------------------------------------------------------------+
//| Order Open                                                       |
//+------------------------------------------------------------------+
int Order_open(ENUM_ORDER_TYPE orderType, double orderSize)
  {
   if(orderType == OP_BUY)
     {
      double openPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      return OrderSend(Symbol(), orderType, orderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, clrBlue);
     }
   if(orderType == OP_SELL)
     {
      double openPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      return OrderSend(Symbol(), orderType, orderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, clrRed);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Order Close                                                      |
//+------------------------------------------------------------------+
void Order_close(ENUM_ORDER_TYPE orderType)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;

      if(orderType==OP_BUY)
        {
         double closeprice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         if(!OrderClose(OrderTicket(),OrderLots(), closeprice, 0, clrGreenYellow))
            Print("OrderClose error ",GetLastError());
        }
      if(orderType==OP_SELL)
        {
         double closeprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         if(!OrderClose(OrderTicket(),OrderLots(), closeprice, 0, clrGold))
            Print("OrderClose error ",GetLastError());
        }

      break;
     }
  }
//+------------------------------------------------------------------+
//|   ApplyTrailingStop                                              |
//+------------------------------------------------------------------+
void ApplyTrailingStop(double stoploss)
  {
   bool check;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {
         double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - stoploss, digits);
         buystoploss = buystoploss+((buystoploss- OrderOpenPrice())*0.05);
         if(buystoploss > OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || buystoploss > OrderStopLoss())
              {
               //Alert("buy stoploss applied");
               check = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, 0, 0, clrAqua);
              }
           }
         else
            if(OrderStopLoss() == 0 || (buystoploss * 0.998) > OrderStopLoss())
              {
               //Alert(Symbol(), "buy stoploss adjust  ", buystoploss);
               check = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss * 0.998, 0, 0, clrLightCyan);
              }
        }
      if(OrderType()==OP_SELL)
        {
         double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + stoploss, digits);
         sellstoploss = sellstoploss-((OrderOpenPrice()- sellstoploss)*0.05);
         if(sellstoploss < OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || sellstoploss < OrderStopLoss())
              {
               //Alert("sell stoploss applied");
               check = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, 0, 0, clrOrangeRed);
              }
           }
         else
            if(OrderStopLoss() == 0 || (sellstoploss* 1.001) < OrderStopLoss())
              {
               check = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss * 1.001, 0, 0, clrMistyRose);
               //Alert(Symbol(), "sell stoploss adjust  ", sellstoploss);
              }
        }
     }
  }

//+------------------------------------------------------------------+
//|    CalculateCurrentOrders                                                              |
//+------------------------------------------------------------------+
void CalculateCurrentOrders()
  {
   int buys=0,sells=0;
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
   buycount = buys;
   sellcount = sells;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double max()
  {
   double maximum = 0.0;
   for(int i=0; i<200; i++)
     {
      if(Open[i] > maximum || maximum == 0.0)
        {
         maximum = Open[i];
        }
     }

   return maximum;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double min()
  {
   double minimum = 0.0;
   for(int i=0; i<200; i++)
     {
      if(Open[i] < minimum || minimum == 0.0)
        {
         minimum = Open[i];
        }
     }
   return minimum;
  }
//+------------------------------------------------------------------+
