//+------------------------------------------------------------------+
//|                                                      nothing.mq4 |
//|                                 Copyright 2021, Benedict Thekkel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Benedict Thekkel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
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
input double               InpOGOrderSize      =  0.01;             //Order size - start small
input double               InpOrderSizeInc      =  0.02;             //Order size - start small
input string               InpTradeComment   =  "indices_1";   //Trade comment - for information
input int                  InpMagicNumber    =  100101;           //Magic number - identifies these

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

double upper = 100,lower = 100;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   StopLoss = (max(90) - min(90));
   print_details();

   if(!StringCompare(Symbol(), "SPX500"))
     {
      upper = 20;
      lower = 20;
     }
   if(!StringCompare(Symbol(), "AUS200"))
     {
      upper = 50;
      lower = 50;
     }
   if(!StringCompare(Symbol(), "UK100"))
     {
      upper = 45;
      lower = 45;
     }

   Alert("upper:", upper,"  lower:", lower);
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
      StopLoss = (max(90) - min(90));
      timer = 0;
      runaway(StopLoss * 1.5);
     }

   if(timer2 >= 2)
     {
      timer2=0;
      tradecondition[time_gap] = 1;
     }

///////////////////////real/////////////////////////////////////

   if((tradecondition[time_gap] == 1))
     {
      ApplyTrailingStopRSI(StopLoss * 0.5);
      CalculateCurrentOrders(); //update buycount and sellcount
      CalculateCurrentOrdersSize(InpOGOrderSize, InpOrderSizeInc);

      int ticket = 0;

      tradecondition[rsi1] = RSI_check2(rsi1, 15, 20, 80, tradecondition[rsi1]);

      tradecondition[rsi2] = RSI_check1(rsi2, 30, 33, 65, 0);  //return if in buy or sell region

      tradecondition[rsi3] = RSI_check1(rsi3, 30, 45, 55, 0);  //return if in buy or sell region

      tradecondition[stoch2] = STOCH_check2(stoch2, 7, 5, 3, 20, 80, tradecondition[stoch2]);

      //tradecondition[avg1] = AVG_check1(15, 0);

      tradecondition[ao1] = AO_check1(upper, lower);

      if(((tradecondition[ao1] == buy) && (tradecondition[rsi3] == buy)) ||
         ((tradecondition[rsi2] == buy) &&
          ((tradecondition[rsi1] == buytrigger) || (tradecondition[stoch2] == buytrigger))))
        {
         double size = buysize;
         ticket = buy_trade(size, 1);
         Alert(Symbol(), "buy trade:", buycount, " ordersize:", size);
         tradecondition[time_gap] = 0;
         timer2=0;
        }

      if(((tradecondition[ao1] == sell) && (tradecondition[rsi3] == sell)) ||
         ((tradecondition[rsi2] == sell) &&
          ((tradecondition[rsi1] == selltrigger) || (tradecondition[stoch2] == selltrigger))))
        {
         double size = sellsize;
         //ticket = sell_trade(size, 0);
         Alert(Symbol(), "sell trade:", sellcount, " ordersize:", size);
         tradecondition[time_gap] = 0;
         timer2=0;
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {

   if(id==CHARTEVENT_CLICK)
     {
      //Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
     }

  }
//+------------------------------------------------------------------+
