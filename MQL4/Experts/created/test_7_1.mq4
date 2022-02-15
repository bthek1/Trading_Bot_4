//+------------------------------------------------------------------+
//|                                                      nothing.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int                  InpRSIPeriods     =  30;            //RSI Periods
ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

double               InpSellLevel      = 70.0;           //Sell level
double               InpBuyLevel       = 30.0;           //Buy level

int                  InpMAPeriods      =  15;         //MovingAvg Periods
int                  InpMAShift        =  0;          //MovingAvg Rightshift

int                  Tradelimit        =  15;         //Number of trades allowed
int                  InpTrailingStop   =  1;          //trailing stop points
//Standard inputs - you should have something like this in every EA
double               InpOrderSize      =  0.01;             //Order size - start small
string               InpTradeComment   =  "test_7_indics";   //Trade comment - for information
int                  InpMagicNumber    =  000071;           //Magic number - identifies these


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int tradecondition[6];
int previous;

int timer, timer2;
double StopLoss;

enum status {rsi, stoch, time_gap, rsi2};
enum region {buy, sell, notrade};
enum trigger {reset, buyarmed, buytrigger, sellarmed, selltrigger};



int buycount, sellcount;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   timer++;
   timer2++;
   if(timer >= 200)
     {
      timer = 0;
      StopLoss = (max() - min())*0.3;
      runaway(StopLoss * 4);
      ApplyTrailingStop(StopLoss);
     }

   if(timer2 >= 5000)
     {
      timer2=0;
      tradecondition[time_gap] = 1;
     }

   CalculateCurrentOrders(); //update buycount and sellcount

///////////////////////real////////////////////////////////////////a
   int ticket = 0;

   tradecondition[rsi] = RSI_check(InpRSIPeriods, 35, 60, 1.5);  //return if in buy or sell region

   tradecondition[stoch] = STOCH_check(7, 5, 3, tradecondition[stoch]); //return if should trade or not

   tradecondition[rsi2] = RSI_check(15, 20, 80, 0);  //return if in buy or sell region
   
  // double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 1);
   //iMACD(Symbol(), Period(), 15, 30, 5, PRICE_CLOSE, 

   if(((tradecondition[rsi] == buy && tradecondition[stoch] == buytrigger) || (previous == buy && tradecondition[rsi2] == notrade))
      && tradecondition[time_gap] == 1)
     {
      ticket = buy_trade(InpOrderSize + 0.005 * buycount);
      Alert(Symbol(), "buy trade:", buycount, " ordersize:", InpOrderSize + 0.005 * buycount);
      //ticket = buy_trade(ordSize);
      tradecondition[stoch] = reset;
      tradecondition[time_gap] = 0;
     }
   if(((tradecondition[rsi] == sell && tradecondition[stoch] == selltrigger) || (previous == sell && tradecondition[rsi2] == notrade))
      && tradecondition[time_gap] == 1)
     {
      ticket = sell_trade(InpOrderSize + 0.005 * sellcount);
      Alert(Symbol(), "sell trade:", sellcount, " ordersize:", InpOrderSize + 0.005 * sellcount);
      //ticket = sell_trade(ordSize);
      tradecondition[stoch] = reset;
      tradecondition[time_gap] = 0;
     }


   previous = tradecondition[rsi2];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RSI_check(int period, int less_than, int greater_than, double multi)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 1);
//Alert(RSI, "  ", buycount, "  ", sellcount);
   if(RSI <= (less_than-(multi*buycount)))
     {
      //printf("buy %f  \n", RSI);
      return buy;
     }
   else
     {
      if(RSI > (greater_than+(multi*sellcount)))
        {
         //printf("sell %f \n ",RSI);
         return sell;
        }
     }
   return notrade;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int STOCH_check(int k, int d, int slowing, int stoch_status)
  {
   double STOCH = iStochastic(Symbol(), 0, k, d, slowing, MODE_SMA, 0, MODE_MAIN, 0);

   if(STOCH < 20)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH >= 20 && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH > 80)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
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
      if(sellcount < Tradelimit) {}
         //return Order_open(OP_SELL, orderSize);
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
      if(OrderSymbol()!=Symbol())
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
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCurrentOrders()
  {
   int buys=0,sells=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol())
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
void ApplyTrailingStop(double retrade)
  {
   double RSI = iRSI(Symbol(), Period(), InpRSIPeriods, PRICE_CLOSE, 1);
   bool check;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {
         if(RSI > 60)
           {
            double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - retrade, digits);
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
               //Alert(Symbol(), "buy stoploss adjust  ", buystoploss);
               check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrLightCyan);
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(RSI <= 40)
           {
            double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + retrade, digits);
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
               check = OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, clrMistyRose);
            //Alert(Symbol(), "sell stoploss adjust  ", sellstoploss);

           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void runaway(double retrade)
  {
   int ticket;
   double currentbuyprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double currentsellprice = SymbolInfoDouble(Symbol(), SYMBOL_BID);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()!=Symbol())
         continue;

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==OP_BUY)
        {
         if(OrderOpenPrice() > (currentbuyprice + retrade))
           {
            double size = OrderLots();

            if(OrderClose(OrderTicket(), size, currentsellprice, 0, clrLightCyan))
              {
               Alert("retrade buy");
               ticket = OrderSend(Symbol(), OP_BUY, size, currentbuyprice, 0, 0, 0, "retrade buy", InpMagicNumber, 0, clrAqua);
              }
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(OrderOpenPrice() < (currentsellprice - retrade))
           {
            double size = OrderLots();
            if(OrderClose(OrderTicket(),size, currentbuyprice, 0, clrMistyRose))
              {
               Alert("retrade sell trade");
               ticket = OrderSend(Symbol(), OP_SELL, size, currentsellprice, 0, 0, 0, "retrade sell", InpMagicNumber, 0, clrOrangeRed);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double max()
  {
   double maximum = 0.0;
   for(int i=0; i<90; i++)
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
   for(int i=0; i<90; i++)
     {
      if(Open[i] < minimum || minimum == 0.0)
        {
         minimum = Open[i];
        }
     }
   return minimum;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
