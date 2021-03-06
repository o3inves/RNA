//+------------------------------------------------------------------+
//|                                                          RNA.mq4 |
//|                                                          O3 Inc. |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict

double nrtr_value_b1, nrtr_value_b2, nrtr_value_1, nrtr_value_2,
             ma_100_value_b1, 
             ma_50_value_b1, ma_50_value_b2;
             
bool trade_stop = false;
         
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      switch( NewBar() )
        {
         case  true:
               if( getNRTR(1) == "up" )
                 {
                     nrtr_value_b1 = getNrtrValue(1, 0);
                     nrtr_value_b2 = getNrtrValue(2, 0);
                     
                     ma_100_value_b1 = getMAValue(1, 100);
                     ma_50_value_b1 = getMAValue(1, 50);
                     ma_50_value_b2 = getMAValue(2, 50);
                     
                     if(
                        ma_50_value_b1 > ma_100_value_b1 && 
                        nrtr_value_b2 < ma_50_value_b2 && nrtr_value_b1 >= ma_50_value_b1 &&
                        trade_stop == false 
                       )
                       {
                           trade_stop = true; // Proibe novas operações; 
                           Print("BUY");
                       }
                 }
               else if( getNRTR(1) == "down" )
                 {
                     nrtr_value_b1 = getNrtrValue(1, 1);
                     nrtr_value_b2 = getNrtrValue(2, 1);
                     
                     ma_100_value_b1 = getMAValue(1, 100);
                     ma_50_value_b1 = getMAValue(1, 50);
                     ma_50_value_b2 = getMAValue(2, 50);
                     
                     if(
                        ma_50_value_b1 < ma_100_value_b1 && 
                        nrtr_value_b2 > ma_50_value_b2 && nrtr_value_b1 <= ma_50_value_b1 &&
                        trade_stop == false
                       )
                       {
                           trade_stop = true; // Proibe novas operações;
                           Print("SELL");
                       }
                 }
               else
                 {
                     ma_100_value_b1 = getMAValue(1, 100);
                     ma_50_value_b1 = getMAValue(1, 50);
                     
                     if(ma_50_value_b1 > ma_100_value_b1)
                       {
                           nrtr_value_b1 = getNrtrValue(1, 0);  // Stream - Buy
                           nrtr_value_2 = getNrtrValue(1, 1);  // Stream - Sell
                           
                           if(nrtr_value_b1 >= ma_50_value_b1 && Bid > nrtr_value_2 && trade_stop == false)
                             {
                                 trade_stop = true; // Proibe novas operações;
                                 Print("BUY B");
                             }
                       }
                     else if(ma_50_value_b1 < ma_100_value_b1)
                       {
                          nrtr_value_1 = getNrtrValue(1, 0);  // Stream - Buy
                          nrtr_value_b1 = getNrtrValue(1, 1);  // Stream - Sell
                          
                          if(nrtr_value_b1 <= ma_50_value_b1  && Bid < nrtr_value_1 && trade_stop == false)
                             {
                                 trade_stop = true; // Proibe novas operações;
                                 Print("SELL B");
                             }
                       }
                 }
           break;
         default:
           break;
        }
  }
//+------------------------------------------------------------------+
bool NewBar()
   {
      static datetime lastbar;
      datetime curbar = Time[0];
      
      if(lastbar != curbar)
         {
            lastbar = curbar;
            return (true);
         }
      else
         {
            return (false);
         }
   }

string getNRTR(int bar)
   {
      double nrtr_up =   iCustom(NULL, 0, "NRTR_ATR_STOP",200,3,0,bar);
      double nrtr_down = iCustom(NULL, 0, "NRTR_ATR_STOP",200,3,1,bar);
      
      if(nrtr_up != 0 && nrtr_down != 0)
        {
            trade_stop = false; // Habilita novas operações;
            return "break";
        }
      else if(nrtr_up > 0 && nrtr_down == 0)
        {
            return "up";
        }
      else if(nrtr_up == 0 && nrtr_down > 0)
        {
            return "down";
        }
       return "";
   }
   
double getNrtrValue(int bar, int stream) {
      double value = 0;
      
      // 0 - Stream 0 - UP
      // 1 - Stream 1 - DOWN
      
      switch(stream)
        {
         case  0:
               value = iCustom(NULL, 0, "NRTR_ATR_STOP",200,3,0,bar);
           break;
         case  1:
               value =  iCustom(NULL, 0, "NRTR_ATR_STOP",200,3,1,bar);
            break;
         default:
           break;
        }
        
        return value;
   }
   
double getMAValue(int bar, int period) {
      double value = iMA(Symbol(), NULL, period, 0, MODE_EMA, PRICE_CLOSE, bar);
      
      return value;
   }
   
bool sendOrderBuy(double volume, double stop_loss, double take_profit) {
      int ticket = OrderSend(Symbol(), OP_BUY, volume, Ask, 5, stop_loss, take_profit, NULL, 100, 0, clrBlue);
      
      if( ticket < 0 )
        {
            return false;
            Print("Order Buy failed with error #",GetLastError());
        }
      else
         {
            return true;
            Print("Order Buy placed successfully");
         }
   }
   
bool sendOrderSell(double volume, double stop_loss, double take_profit) {
      int ticket = OrderSend(Symbol(), OP_SELL, volume, Bid, 5, stop_loss, take_profit, NULL, 100, 0, clrRed);
      
      if( ticket < 0 )
        {
            return false;
            Print("Order Sell failed with error #",GetLastError());
        }
      else
         {
            return true;
            Print("Order Sell placed successfully");
         }
   }