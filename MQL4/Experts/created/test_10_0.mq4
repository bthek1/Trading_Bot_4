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
int tradecondition[10];
double conditionvalues[10];


double timer, timer2;
double StopLoss;

enum status {rsi1, rsi2, rsi3, stoch1, stoch2, moch1, moch2, avg1, time_gap};
enum region {notrade, buy, sell, trade};
enum trigger {reset, buyarmed, buytrigger, sellarmed, selltrigger, buywait, sellwait};



int buycount, sellcount;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   Print("Symbol name of the current chart=",_Symbol);
   Print("Timeframe of the current chart=",_Period);
   Print("The latest known seller's price (ask price) for the current symbol=",Ask);
   Print("The latest known buyer's price (bid price) of the current symbol=",Bid);
   Print("Number of decimal places=",Digits);
   Print("Number of decimal places=",_Digits);
   Print("Size of the current symbol point in the quote currency=",_Point);
   Print("Size of the current symbol point in the quote currency=",Point);
   Print("Number of bars in the current chart=",Bars);
   Print("Open price of the current bar of the current chart=",Open[0]);
   Print("Close price of the current bar of the current chart=",Close[0]);
   Print("High price of the current bar of the current chart=",High[0]);
   Print("Low price of the current bar of the current chart=",Low[0]);
   Print("Time of the current bar of the current chart=",Time[0]);
   Print("Tick volume of the current bar of the current chart=",Volume[0]);
   Print("Last error code=",_LastError);
   Print("Random seed=",_RandomSeed);
   Print("Stop flag=",_StopFlag);
   Print("Uninitialization reason code=",_UninitReason);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   timer++;
   timer2++;
   if(timer >= 200)
     {
      timer = 0;
      StopLoss = (max() - min())*0.3;
      runaway(StopLoss * 5);
      ApplyTrailingStop(StopLoss);
     }

   if(timer2 >= 5000)
     {
      timer2=0;
      tradecondition[time_gap] = 1;
     }
   CalculateCurrentOrders(); //update buycount and sellcount

///////////////////////real/////////////////////////////////////
   int ticket = 0;

   tradecondition[rsi1] = RSI_check2(rsi1, 10, 25, 75, tradecondition[rsi1]);

   tradecondition[rsi2] = RSI_check1(rsi2, 30, 40, 60, 1.5);  //return if in buy or sell region

   tradecondition[moch1] = MOCH_check1(moch1, 5, 10, 5, tradecondition[moch1]);

   tradecondition[avg1] = AVG_check1(30, 0);

   if(
      (tradecondition[rsi2] == buy) &&
      (tradecondition[avg1] == trade) &&
      (tradecondition[time_gap] == 1) &&
      (
         (tradecondition[rsi1] == buytrigger)
      //   || (tradecondition[moch1] == buytrigger)
      ))
     {
      double size = InpOrderSize + 0.01 * buycount;
      ticket = buy_trade(size);
      Alert(Symbol(), "buy trade:", buycount, " ordersize:", size);
      tradecondition[time_gap] = 0;
      timer2=0;
     }


   if(
      (tradecondition[rsi2] == sell) &&
      (tradecondition[avg1] == trade) &&
      (tradecondition[time_gap] == 1) &&
      (
         (tradecondition[rsi1] == selltrigger)
      //   || (tradecondition[moch1] == selltrigger)
      ))
     {
      double size = InpOrderSize + 0.01 * sellcount;
      ticket = sell_trade(size);
      Alert(Symbol(), "sell trade:", sellcount, " ordersize:", size);
      tradecondition[time_gap] = 0;
      timer2=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RSI_check1(int item, int period, int less_than, int greater_than, double multi)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 0);
//Alert(RSI, "  ", buycount, "  ", sellcount);
   if(RSI <= (less_than-(multi*buycount)))
     {
      conditionvalues[item] = less_than - RSI;
      return buy;
     }
   else
     {
      if(RSI > (greater_than+(multi*sellcount)))
        {
         conditionvalues[item] = RSI - greater_than;
         return sell;
        }
     }
   conditionvalues[rsi1] = 0;
   return notrade;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int RSI_check2(int item, int period, int less_than, int greater_than, int rsi2_status)
  {
   double RSI = iRSI(Symbol(), Period(), period, PRICE_CLOSE, 0);
   if(RSI < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(RSI >= less_than && rsi2_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(RSI > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(RSI <= greater_than && rsi2_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int STOCH_check1(int item, int k, int d, int slowing, int less_than, int greater_than, int stoch_status)
  {
   double STOCH_MAIN = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double STOCH_SIG = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_SIGNAL, 0);

   if(STOCH_MAIN < STOCH_SIG && STOCH_MAIN < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH_MAIN > STOCH_SIG && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH_MAIN > STOCH_SIG && STOCH_MAIN > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(STOCH_MAIN < STOCH_SIG && stoch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int STOCH_check2(int item, int k, int d, int slowing, int less_than, int greater_than, int stoch_status)
  {
   double STOCH = iStochastic(Symbol(), Period(), k, d, slowing, MODE_SMA, 0, MODE_MAIN, 0);

   if(STOCH < less_than)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(STOCH >= less_than && stoch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(STOCH > greater_than)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(STOCH <= greater_than && stoch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }
//printf("reset %f \n ", STOCH);
   return reset;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MOCH_check1(int item, int fast, int slow, int sma, int moch_status)
  {
   double MAIN=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_MAIN, 0);
   double SIGNAL=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_SIGNAL, 0);

   if(MAIN < SIGNAL)
     {
      //Print(Symbol(), "  buyarmed ", STOCH);
      return buyarmed;
     }
   if(MAIN >= SIGNAL && moch_status == buyarmed)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buytrigger;
     }
   if(MAIN > SIGNAL)
     {
      //Print(Symbol(), "  sellarmed  ", STOCH);
      return sellarmed;
     }
   if(MAIN <= SIGNAL && moch_status == sellarmed)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return selltrigger;
     }

   return notrade;
//printf("reset %f \n ", STOCH);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MOCH_check2(int item, int fast, int slow, int sma)
  {
   double main=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_MAIN, 0);
   double signal=iMACD(Symbol(), Period(), fast, slow, sma, PRICE_CLOSE, MODE_SIGNAL, 0);

   if(main > signal && main < 0)
     {
      //Print(Symbol(), "  buytrigger ", STOCH);
      return buy;
     }

   if(main < signal && main > 0)
     {
      //Print(Symbol(), "  selltrigger  ", STOCH);
      return sell;
     }

   return notrade;
//printf("reset %f \n ", STOCH);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AVG_check1(int period, int shift)
  {
   double AVG1 = iMA(Symbol(),Period(),period,shift,MODE_SMA,PRICE_CLOSE,1);
   double AVG2 = iMA(Symbol(),Period(),period,shift,MODE_SMA,PRICE_CLOSE,5);

   if(fabs(AVG1 - AVG2) < (AVG2*0.0005))
     {
      //Alert(fabs(AVG1 - AVG2), "  trade  ",(AVG2*0.0005));
      return trade;
     }
   //Alert("no");
   return notrade;
  }


//+------------------------------------------------------------------+
//|                                                                  |
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
               ticket = OrderSend(Symbol(), OP_BUY, size*1.5, currentbuyprice, 0, 0, 0, "retrade buy", InpMagicNumber, 0, clrAqua);
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
               ticket = OrderSend(Symbol(), OP_SELL, size*1.5, currentsellprice, 0, 0, 0, "retrade sell", InpMagicNumber, 0, clrOrangeRed);
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

//+------------------------------------------------------------------+
