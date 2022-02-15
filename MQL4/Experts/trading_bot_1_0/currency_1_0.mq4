//+------------------------------------------------------------------+
//|                                                      nothing.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "AO_reader.mqh";
#include "AVG_reader.mqh";
#include "MOCH_reader.mqh";
#include "Print.mqh";
#include "RSI_reader.mqh";
#include "STOCH_reader.mqh";
#include "Technical.mqh";
#include "TrailingStoploss.mqh";
#include "Runawaytrade.mqh";
#include "warning_system.mqh";


input int                  InpRSIPeriods     =  30;            //RSI Periods
input ENUM_APPLIED_PRICE   InpRSIPRICE       =  PRICE_CLOSE;   //RSI Applied price

input double               InpSellLevel      = 70.0;           //Sell level
input double               InpBuyLevel       = 30.0;           //Buy level

input int                  InpMAPeriods      =  15;         //MovingAvg Periods
input int                  InpMAShift        =  0;          //MovingAvg Rightshift

input int                  Tradelimit        =  15;         //Number of trades allowed
input int                  InpTrailingStop   =  1;          //trailing stop points
//Standard inputs - you should have something like this in every EA
input double               InpOGOrderSize      =  0.01;        //Order size - start small
input double               InpOrderSizeInc      =  0.015;       //Order size increase with no. of order
input string               InpTradeComment   =  "currency_1";  //Trade comment - for information
input int                  InpMagicNumber    =  100999;        //Magic number - identifies these

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int tradecondition[12];
double conditionvalues[12];
double warning[5];
double memory;

double timer, timer2, timer3;

enum status {rsi1, rsi2, rsi3, stoch1, stoch2, moch1, moch2, avg1, ao1, ac1, margin1, time_gap};
enum region {notrade, buy, sell, trade};
enum trigger {reset, buyarmed, buytrigger, sellarmed, selltrigger, buywait, sellwait};

int buycount, sellcount;
double buysize, sellsize, StopLoss;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   print_details();
   StopLoss = (max(90) - min(90));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   internet_connection();
   trade_margin_calc();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   internet_connection();

   trade_margin_calc();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(memory != Open[0])
     {
      memory = Open[0];
      timer++;
      timer2++;
     }
   if(timer >= 5)
     {
      timer = 0;
      StopLoss = (max(90) - min(90));
      //runaway(StopLoss * 1.5);
      //ApplyTrailingStop(StopLoss * 0.3);
     }

   if(timer2 >= 2)
     {
      ApplyTrailingStop(StopLoss * 0.3);
      timer2=0;
      tradecondition[time_gap] = 1;
     }
//Alert(Close[0]);

   CalculateCurrentOrders(); //update buycount and sellcount
   CalculateCurrentOrdersSize(InpOGOrderSize, InpOrderSizeInc);
///////////////////////real/////////////////////////////////////


   if((tradecondition[time_gap] == 1))
     {
      int ticket = 0;

      //tradecondition[rsi1] = RSI_check2(rsi1, 15, 20, 80, tradecondition[rsi1]);

      tradecondition[rsi2] = RSI_check1(rsi2, 30, 45, 55, 0);  //return if in buy or sell region

      //tradecondition[stoch2] = STOCH_check2(stoch2, 7, 5, 3, 20, 80, tradecondition[stoch2]);

      //tradecondition[avg1] = AVG_check1(15, 0);

      tradecondition[ao1] = AO_check1(0, 0);

      if((tradecondition[ao1] == buy) && (tradecondition[rsi2] == buy))
        {
         double size = buysize;
         ticket = buy_trade(size, 1);
         Alert(Symbol(), "buy trade:", buycount, " ordersize:", size);
         tradecondition[time_gap] = 0;
         timer2=0;
        }


      if((tradecondition[ao1] == sell) && (tradecondition[rsi2] == sell))
        {
         double size = sellsize;
         ticket = sell_trade(size, 1);
         Alert(Symbol(), "sell trade:", sellcount, " ordersize:", size);
         tradecondition[time_gap] = 0;
         timer2=0;
        }
     }

  }
//+------------------------------------------------------------------+
