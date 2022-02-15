//+------------------------------------------------------------------+
//|                                               basic_with_RSI.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


//fix count
//make it so that buy and sell only trigger if the rsi go from above 70 to less than 70
//calculate strength using difference between mv and value

//change lot with available amount and risk tolerance

//SYMBOL_ASK = buy price
//SYMBOL_BID = sell price

#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//RSI levels are from 0-100, select levels for overbrought and oversold
//and the inputs to RSI
input int                  InpRSIPeriods     =  30;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

// The levels
input double               InpSellLevel  = 70.0;           //Sell level
input double               InpBuyLevel = 30.0;           //Buy level

input int                  InpMAPeriods      =  15;         //MovingAvg Periods
input int                  InpMAShift        =  0;          //MovingAvg Rightshift

input int                  Tradelimit        =  15;         //Number of trades allowed
input int                  InpTrailingStop   =  1;     //trailing stop points
//Standard inputs - you should have something like this in every EA
input double               InpOrderSize      =  0.01;             //Order size - start small
input string               InpTradeComment   =  "Beginner RSI";   //Trade comment - for information
input int                  InpMagicNumber    =  000030;           //Magic number - identifies these


bool buycriteria = true;
bool sellcriteria = true;


bool buyallow = true;
bool sellallow = true;

int buycondition[3];
int sellcondition[3];

enum status {RSI, Stoch, Avg};

int timer, timer2;

double StopLoss = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //StopLoss = SymbolInfoDouble(Symbol(), SYMBOL_POINT)*InpTrailingStop;
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
   Alert("tear down");
  }
//+------------------------------------------------------------------+
//|  On timer                                                                |
//+------------------------------------------------------------------+
void OnTimer()
  {
//Alert(Open[0], "asdf  ", SymbolInfoDouble(Symbol(), SYMBOL_ASK),  "asdf  ", SymbolInfoDouble(Symbol(), SYMBOL_BID));
   timer++;
   timer2++;
   
   if(timer >= 60)
     {
      if(!buyallow)
         buyallow = true;
      if(!sellallow)
         sellallow = true;
      timer = 0;
     }
     
   
   if(timer2 >= 30)
     {
      timer2 = 0;
      ApplyTrailingStop(StopLoss);
     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int tradeCount = CalculateCurrentOrders();
   double rsiValue = iRSI(Symbol(), Period(), 25, PRICE_CLOSE, 1);

   double maValue = iMA(Symbol(), 0, 15, 0, MODE_SMA, PRICE_CLOSE, 0);
  
   double stochValue = iStochastic(Symbol(), 0, 7, 5, 3, MODE_SMA, 0, MODE_MAIN, 0);

   if(!sellallow && !buyallow)
      return;  //only trade on a new bar

///////////////////////real////////////////////////////////////////a
   int ticket = 0;

   if(((tradeCount < 0 && rsiValue < 30) || (tradeCount >= 0 && rsiValue < (30-tradeCount))) && !buycriteria)
     {
      buycriteria = true;
      Alert("buy criteria allowed");
     }

   if(((tradeCount > 0 && rsiValue > 70) || (tradeCount <= 0 && rsiValue > (70+tradeCount*-1))) && !sellcriteria)
     {
      sellcriteria = true;
      Alert("sell criteria allowed");
     }


   if((maValue*0.9998 > Open[0]) && buyallow)
     {
      if(tradeCount < 0 && (rsiValue > 30) && buycriteria)
        {
         Order_close(ORDER_TYPE_SELL);
         Alert("Close sell trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
         buyallow = false;
         buycriteria = false;
        }
      else
        {
         if(tradeCount <= Tradelimit && tradeCount >= 0 && (rsiValue > (30-tradeCount)) && buycriteria)
           {
            ticket = Order_open(ORDER_TYPE_BUY);
            Alert("Buy trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
            buyallow = false;
            buycriteria = false;
           }
        }
     }
   else
     {
      if((maValue*1.0002 < Open[0]) && sellallow)
        {
         if(tradeCount > 0 && (rsiValue < 70) && sellcriteria)
           {
            Order_close(ORDER_TYPE_BUY);
            Alert("Close buy trade", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
            sellallow = false;
            sellcriteria = false;
           }
         else
           {
            if((tradeCount*-1) <= Tradelimit && tradeCount <= 0 && rsiValue < (70+(tradeCount*-1)) && sellcriteria)
              {
               ticket = Order_open(ORDER_TYPE_SELL);
               Alert("Sell trade, ", ticket, "   ", Open[0],  "   rsi: ", rsiValue, "   trades: ", CalculateCurrentOrders());
               sellallow = false;
               sellcriteria = false;
              }
           }
        }
      else
        {
         //Alert("new data  : ", Open[0], " : ", Close[0], "   rsi: ", rsi, "   trades: ", CalculateCurrentOrders());
        }
     }
///////////////////Finished//////////////////
   return;
  }
//+------------------------------------------------------------------+
//| Other functions-->Order Open                                                                 |
//+------------------------------------------------------------------+
int Order_open(ENUM_ORDER_TYPE orderType)
  {

   int ticket = 0;
   double openPrice;

   if(orderType == ORDER_TYPE_BUY)
     {
      openPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Blue);

     }
   if(orderType == ORDER_TYPE_SELL)
     {
      openPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, Red);

     }
   return ticket;
  }

//+------------------------------------------------------------------+
//| Order Close                                                                 |
//+------------------------------------------------------------------+
void Order_close(ENUM_ORDER_TYPE orderType)
  {

   double closeprice;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;

      if(orderType==ORDER_TYPE_SELL)
        {
         closeprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         if(!OrderClose(OrderTicket(),OrderLots(), closeprice, 0, Green))
            Print("OrderClose error ",GetLastError());
        }
      if(orderType==ORDER_TYPE_BUY)
        {
         closeprice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
         if(!OrderClose(OrderTicket(),OrderLots(), closeprice, 0,Orange))
            Print("OrderClose error ",GetLastError());
        }
      break;
     }
  }
//+------------------------------------------------------------------+
//|     ApplyTrailingStop                                                             |
//+------------------------------------------------------------------+
void ApplyTrailingStop(double stoploss)
  {
   int ticket;
   static int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double price = Open[0];

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=InpMagicNumber || OrderSymbol()!=Symbol())
         continue;

      double buystoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID) - stoploss, digits);
      double sellstoploss = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK) + stoploss, digits);

      buystoploss = buystoploss-((buystoploss- OrderOpenPrice())*0.3);
      sellstoploss = sellstoploss+((OrderOpenPrice()- sellstoploss)*0.3);

      //Alert(buystoploss, "  ", sellstoploss);
      if(OrderType()==ORDER_TYPE_BUY)
         if(buystoploss > OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || buystoploss > OrderStopLoss())
              {
               ticket = OrderModify(OrderTicket(), OrderOpenPrice(), buystoploss, OrderTakeProfit(), OrderExpiration(), Yellow);
               //if(ticket != 0)
               //Alert("buy ticket modified  ", ticket, "  ", buystoploss);
              }
           }
         else
           {
            ticket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderTakeProfit(), OrderExpiration(), Yellow);
           }
      if(OrderType()==ORDER_TYPE_SELL)
         if(sellstoploss < OrderOpenPrice())
           {
            if(OrderStopLoss() == 0 || sellstoploss < OrderStopLoss())
              {
               ticket = OrderModify(OrderTicket(), OrderOpenPrice(), sellstoploss, OrderTakeProfit(), OrderExpiration(), White);
               //if(ticket != 0)
               //Alert("sell ticket modified  ", ticket, "  ", sellstoploss);
              }
           }
         else
           {
            ticket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderTakeProfit(), OrderExpiration(), White);
           }
     }
  }

//+------------------------------------------------------------------+
//|    CalculateCurrentOrders                                                              |
//+------------------------------------------------------------------+
int CalculateCurrentOrders()
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
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
