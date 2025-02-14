//+------------------------------------------------------------------+
//|                                                VR---STEALS-3.mq4 |
//|                     "Copyright 2014, www.trading-go.ru Project." |
#property version     "3.3"
#property description "Virtual StopLoss, TakeProfit, Breakeven, Traling stop, OrderClose, OrderDelete "
#property strict
#import "shell32.dll"
int ShellExecuteW(int hwnd,string lpOperation,string lpFile,string lpParameters,string lpDirectory,int nShowCmd);
#import
#define  NLL    "\n"



/**
* MT4/experts/scripts/one_tick.mq4
* send exactly one fake tick to the chart and
* all its indicators and EA and then exit.
*/

#property copyright "© Bernd Kreuss"

#import "user32.dll"
int PostMessageA(int hWnd, int Msg, int wParam, int lParam);
int RegisterWindowMessageA(string lpString);
int      GetWindow(int hWnd,int uCmd);
int      GetParent(int hWnd);
#import

#import "Account Protector.dll"
#import

input string LogFileName = "log.txt"; // Log file name

/*
void   tick4(){
   int hwnd = WindowHandle(Symbol(), Period());
   int msg = RegisterWindowMessageA("MetaTrader4_Internal_Message");
   PostMessageA(hwnd, msg, 2, 1);
}
 */


// #include "../../include/mt4gui2.mqh"
/*
#import "user32.dll"
int      PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int      GetWindow(int hWnd,int uCmd);
int      GetParent(int hWnd);
#import
*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern bool             CurrencySymbolRight=True;              //is your currency symbol (€ $ Ł) at the Right?
extern ENUM_LINE_STYLE  MMLineStyle=STYLE_DASHDOTDOT;          //Style of Lines
extern int              MMLinewidth=1;                         //Choose the width of the line

//+------------------------------------------------------------------+
//|                                               |
//+------------------------------------------------------------------+
extern double    Hsuma     = -100 ;           //  hedge suma
extern double    LHsuma     = -200 ;           //  hedge suma
extern double    Vsuma2     = 200 ;           //  virtualna suma2
extern  bool notification    = true ;  //// notification  za razlikata !!!

extern  double     kk = 10 ;  //коеф kalk
extern double    Vsuma     = 600 ;           //  virtualna suma  za DELTA ot EQ !!!
extern double    VEQ     = 50000 ;           //  virtualno EQ
extern  bool mynotification    = true ;  /// notification  za DELTA ot EQ !!!
input double StartLots=0.10;
extern int    TakeProfit= 900 ;  // TakeProfit
extern  int    StopLoss= 200;   ///StopLoss  = + 2*СПРЕДА  в ПОЙНТ
extern  double     koef = 1 ;  //коеф * спреда
extern int    TralingStop= 100;
input int    Breakeven= 160;  // по голямо от СПРЕДА
extern  double    Hedge= 100;
extern  double    risksuma= 2;  // риск на позиция в сума
extern  double    inSN= 140 ;  //  снайпер пипсове
extern bool   intersection_touch = false;//пересечение или касание
extern int    Stop_Limit=300;
extern  int    Magic = 101;   ///  MAGIC   OPEN
extern int    MagicALL = -1;  ///  MAGIC   MANAGE ALL
extern int    calMG = -1;  ///  MAGIC   CALCULATE ALL
extern int    calMG2 = -1;  ///  MAGIC   CALCULATE ALL
input int    Slip=20;
extern  double    SP =1;  //spread
extern double koefATR= 2;  // koef ATR
double price,OSL,OTP,OOP, wp;

color  cvit[], colorframe;
int    w=-1,x=0,y=0,ButX=17,BuyY=15,Coment=10;
string Puti="",InpFileName="",info[],prefix="zr";
double tp=0,sl=0,tr=0,br=0,wlot=0,glot=0,lotMG,SumMG,savecalMG, HH ,lotMG2,SumMG2;
double TA[100];   ///tickarray
int it =1;   //itick counter
double NLoss=0,NLb=0,NLs=0,  NL750loss=0,NL750p=0 ;
double tval = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tsize= MarketInfo(Symbol(), MODE_TICKSIZE);
   double pval =SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) ;
   double accEQ ;
   int z=0;  // nomer A line
   string LineIdA="" ;
   int csize = 1;  /// contract size    SYMBOL_TRADE_CALC_MODE 
   double rezult =0 ;
   double winrate = 0 ;
   double  Vkoef  = 0.5 ;
   double  LVkoef  = 0.5 ;
  // double LHsuma = Hsuma;
  


input color    Color1     = clrBlack;          // цвет
input color    Color2     = clrWhite;          // цвет
input color    Color3     = clrAqua;           // цвет  BUY
input color    Color4     = clrRed;            // цвет   SELL
input color    Color5     = clrYellow;          // цвет   PIVOT Profit
input color    Color6     = clrLemonChiffon;   // цвет
input color    Color7     = clrLightGray;      // цвет
input color    Color8     = clrSnow;           // цвет
input color    Color9     = clrGray;           // цвет
input color    colorBreak     = clrYellow;           // цвет colorBreak
input color    colorBreakS     = clrYellow;           // цвет colorBreakS
input color    colorBreakB    = clrBlue;           // цвет colorBreakB

string Font        = "Times New Roman"; // Шрифт
int    Width       = 8;                // размер
int    fontsize       = 5;                // размер
int    fontsizeEQ       = 30;                // размер
long   X=300;
long   Y=500;
///int hwnd = 0;
int x3 =0;

int tik=-1,typ=-1, ttyp= -100;
color  colorprofit = clrYellow ;
bool WiewOrdersLine=ObjectGetInteger(0,"d50",OBJPROP_STATE);


string nameX="",nameTP="",nameSL="",nameBR="",nameTR="",nameTI="",nameSN="",nameTPV="",nameSLV="",nameBRV="",nameSNV="",nameTRV="", nameHH="", nameHHV="",name="" ;
string namex="",nameLTP="",nameLSL="",nameLBR="",nameLTR="",nameLTI="",nameLSN="",nameLHH="",nameLTPtxt="",nameLSLtxt="",nameLSNtxt="", nameLHHtxt="",nameLTRtxt="",nameLBRtxt="" ;
string nameTH="",nameTHV="",name2THV="",nameLTH="",nameLTHtxt="",name2LTH="",name2LTHtxt="" ;
string namePNV="",nameLPN="",nameLPNtxt="", name2HHV="",name2LHH="",name2LHHtxt="",name7LHH="", name7LHHtxt ;
string nameLQP="",nameLQPtxt="";
string nameLAP="",nameLAPtxt="";
string nameLHP="",nameLHPtxt="";

string nameLEQ="",nameLEQtxt="";

double op=0;
string ti="";
double ss=0;
double snsn=0;
double sn=0;
double tt=0;
double th=0;
datetime ti2 ;
double SNprice, PNprice,TPprice, HHprice, HM1,LM1,LSize =0,HM5,LM5,HM15,LM15,ATR5=0,ATR15=0 ;

//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
int OnInit()
  {


GlobalVariableSet("EA_Name_" + IntegerToString(ChartID()), __FILE__);
   EventSetTimer(1);
//init99();

   BuyLine=StringChangeToUpperCase(BuyLine);
   SellLine=StringChangeToUpperCase(SellLine);
   point = _Point;
   PipValuesonelot=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*1);
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   riskmoney=double(AccountInfoDouble(accounttype))/100*Risk;
 //  LSize  = MarketInfo(Symbol(), MODE_LOTSIZE);

//  OnTick99();

// ArrayResize(TA,100);
   ArrayInitialize(TA,EMPTY_VALUE);


//  ObjectsDeleteAll();
//hwnd = WindowHandle(Symbol(),Period());
// Lets remove all gui Objects from chart
//guiRemoveAll(hwnd);
   Comment("");
   if(EventSetMillisecondTimer(100)==true)
      pr("Expert startet OK!!!");
   else
      pr("Error start");

   if(StartLots<MarketInfo(_Symbol,MODE_MINLOT))
      wlot=MarketInfo(_Symbol,MODE_MINLOT);
   else
      wlot= StartLots;

   if(StartLots>MarketInfo(_Symbol,MODE_MAXLOT))
      wlot=MarketInfo(_Symbol,MODE_MAXLOT);
   else
      wlot= StartLots;

   glot=wlot;
   SP = MathAbs(NormalizeDouble(MarketInfo(_Symbol,MODE_SPREAD),_Digits));
//  pr( SP );
   SP = MathAbs(NormalizeDouble(MarketInfo(_Symbol,MODE_SPREAD)*koef,_Digits));        //spppp

//    pr( SP );
// SP = ( NormalizeDouble( MarketInfo(_Symbol,MODE_SPREAD)*koef,_Digits) );
   tp=   NormalizeDouble((TakeProfit) *_Point,_Digits);
   sl=   NormalizeDouble((StopLoss *_Point) + SP,_Digits);
   snsn=   NormalizeDouble((inSN *_Point) + SP,_Digits);
//  tp=  sl ; ////rexi
   tr=NormalizeDouble(TralingStop*_Point,_Digits);
   br=NormalizeDouble(Breakeven  *_Point,_Digits);
   HH=NormalizeDouble(Hedge  *_Point,_Digits);


//  OnTimer ();
   dimi2();
  // but2 (); //rexi  bar day
//but();
// OnInit2() ;
//   OnInit4() ;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {



//  OnTick2() ;
/// Comment("0ntick5  \n", NL);
//if (  show_data )
     {
      // OnInit2() ;
      if(IsOptimization())
        {
         Print("Error !");
         return;
        }
      if(!IsTesting() && !IsOptimization())
        {
        //  while(!IsStopped())
           {


            it = it+1 ;
            // for(int i=1;i<=99;i++)
            if(it == 100)
              {
               // it=1;
               // ArraySetAsSeries (TA, true);
              }
              {
               //   TA[it]= Bid;

              }
            dimi2();
            WindowRedraw();
             Sleep(100);
           //  OnChartEvent();
            
            //  but2();
            ///         Sleep(100);
           }
        }
      else
        {
         // Comment("OnTimer ---but \n" ,NL);
         dimi2();
         // but2();
        }
     }
//  return ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void proverca_br_tr(int wtik) ///snnnnn
  {
   int tik2=-1;
 //  Alert (" proverca ");
   double bb=0,rr=0,sn=0,  pn =0, th=0, hh=0, lockh,Lh, PsumaOR=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || MagicALL==-1)
            if(OrderSymbol()==_Symbol)
              {
               sn =0;
               pn=0;
               th=0 ;
               hh=0 ;
               tik2=OrderTicket();
               PsumaOR +=  OrderProfit()  ; ///+(OrderCommission()+OrderSwap())*Point; ;
              // if (PsumaOR >0)
               bb=NormalizeDouble(get_object(StringConcatenate(prefix,"LBR",tik2)),_Digits);  ///nameLBR=StringConcatenate(prefix,"LBR",tik);
               rr=NormalizeDouble(get_object(StringConcatenate(prefix,"LTR",tik2)),_Digits);
               sn=NormalizeDouble(get_object(StringConcatenate(prefix,"LSN",tik2)),_Digits);
               pn=NormalizeDouble(get_object(StringConcatenate(prefix,"LPN",tik2)),_Digits);
               th=NormalizeDouble(get_object(StringConcatenate(prefix,"2LTH",wtik)),_Digits);
               hh=NormalizeDouble(get_object(StringConcatenate(prefix,"2LHH",wtik)),_Digits);  ///  hhhh7
               lockh=NormalizeDouble(get_object(nameLHPtxt+LineId),_Digits);  ///  hhhh7
               Lh=NormalizeDouble(get_object(nameLHPtxt+LineId+1),_Digits);  ///  hhhh7
              
              
               //    Alert ( "sn  nameSN ", nameSN,  "  tik " ,tik  , "  order ", OrderTicket() );

               /// double nsn=NormalizeDouble(get_object(StringConcatenate("nSN",tik)),_Digits);
               
               //   ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrYellow); 
              
      
               double  pnpn = sn ;
               string  nameLPNPN = StringConcatenate(prefix,"LPNPN",tik2);
               RefreshRates();
               if(OrderType()==0)
             //  Alert (" proverca bb ", bb  , " " , rr);
                  if ((bb>0))  /// && (PsumaOR >0))
                     if(Bid<=bb)
                       {
                        closeorders(tik2); 
                         button_off(nameHH);
                        button_off(nameTH);
                        obj_del(nameLHH);
                         obj_del(nameLTH);
                        
                        obj_del(StringConcatenate(prefix+"Re",tik2)) ;
                  obj_del(StringConcatenate("MG4",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TH",tik2)) ;
                  obj_del(StringConcatenate(prefix+"SL",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TP",tik2)) ;
                  obj_del(StringConcatenate(prefix+"BR",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TR",tik2)) ;
                  obj_del(StringConcatenate(prefix+"Ti",tik2)) ;
                  obj_del(StringConcatenate(prefix+"SN",tik2)) ;
                  obj_del(StringConcatenate(prefix+"HH",tik2)) ;
                  obj_del(StringConcatenate(prefix+"Xx",tik2)) ;
                  obj_del(StringConcatenate(prefix+"LOT",tik2)) ;
                  obj_del(StringConcatenate("Profit",tik2)) ;
                  obj_del(StringConcatenate("MG",tik2)) ; // BRHH
                       
                        //  ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               if(OrderType()==1)
                  if ((bb>0) ) /// && (PsumaOR >0))
                     if(Ask>=bb)
                       {
                        closeorders(tik2);
                        
                        button_off(nameTH);
                        button_off(nameHH);
                        obj_del(nameLHH);
                         obj_del(nameLTH);
                         
                       obj_del(StringConcatenate(prefix+"Re",tik2)) ;
                  obj_del(StringConcatenate("MG4",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TH",tik2)) ;
                  obj_del(StringConcatenate(prefix+"SL",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TP",tik2)) ;
                  obj_del(StringConcatenate(prefix+"BR",tik2)) ;
                  obj_del(StringConcatenate(prefix+"TR",tik2)) ;
                  obj_del(StringConcatenate(prefix+"Ti",tik2)) ;
                  obj_del(StringConcatenate(prefix+"SN",tik2)) ;
                  obj_del(StringConcatenate(prefix+"HH",tik2)) ;
                  obj_del(StringConcatenate(prefix+"Xx",tik2)) ;
                  obj_del(StringConcatenate(prefix+"LOT",tik2)) ;
                  obj_del(StringConcatenate("Profit",tik2)) ;
                  obj_del(StringConcatenate("MG",tik2)) ; 
                  
                        //   ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               if((OrderType()==0 || OrderType()==2 || OrderType()==4) && (wtik ==tik2))        //// thhhhh  provercaaaa
                  if(th>0)
                     if((Bid<=th) && (th<HM1)
                         || ((Ask>=th) && (th>LM1))
                         )
                       {
                        if(OrderSend(Symbol(),OP_SELL, Lot,Bid,50,0,0,StringConcatenate("5TH",wtik),Magic,0,clrRed) !=-1)
                          {
                           Alert("OPEN sell 5 ", tik," tik2 ",tik2)  ;

                        /*  if(((High[0]  > th) && (Bid < th)) || ((Open[0]  < th) && (Close[1] > th)))
                              if(openorders(_Symbol,1,Lot,Bid,StringConcatenate("4TH",wtik))== true)
                                {
                                 button_off(nameTH);
                                }*/
                           // openorders(_Symbol,0,Lot,Bid);
                           button_off(nameTH);
                           ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
                           obj_del(nameLTH);
                           obj_del(name2LTH);


                          }
                        //  button_off( prefix+nameTH);

                       }

               if( (OrderType()==1 || OrderType()==3 || OrderType()==5) && (wtik ==tik2))  //  will open  BUY
                  if(th>0)
                     if( ((Ask>=th) && (th>LM1))
                           || ((Bid<=th) && (th<HM1))
                         ) 
                       {
                        if(OrderSend(Symbol(),OP_BUY, Lot,Ask,50,0,0,StringConcatenate("5TH",wtik),Magic,0,clrRed) !=-1)
                          {
                           Alert("OPEN  buy 5 ", tik, " tik2 ",tik2);
                      /*     if(((Low[0]  < th) && (Ask > th))  || ((Open[0]  > th) && (Close[1] < th)))
                              if(openorders(_Symbol,0,Lot,Ask,StringConcatenate("4TH",wtik)) == true)
                                {
                                 button_off(nameTH);
                                }*/
                           // openorders(_Symbol,1,Lot,Ask);

                           button_off(nameTH);
                           ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
                           obj_del(nameLTH);
                           obj_del(name2LTH);


                          }
                        // button_off( prefix+nameTH);
                       }





               if((OrderType()==0) && (wtik ==tik2))        //// hh hhhh7  provercaaaa
                  if(hh>0)
                     if(Bid<=hh)
                       {
                        if(OrderSend(Symbol(),OP_SELL, Lot,Bid,50,0,0,StringConcatenate("6TH",wtik),Magic,0,clrRed) !=-1)
                          {
                           Alert("OPEN sell 6 ", tik," tik2 ",tik2)  ;

                           if(((High[0]  > tt) && (Bid < tt)) || ((Open[0]  < tt) && (Close[1] > tt)))
                              if(openorders(_Symbol,1,Lot,Bid,StringConcatenate("4TH",wtik))== true)
                                {
                                 button_off(nameHH);
                                }
                           // openorders(_Symbol,0,Lot,Bid);
                           button_off(nameHH);
                           ObjectSetInteger(0,nameHH,OBJPROP_STATE,false);
                           obj_del(nameLHH);
                           obj_del(name2LHH);


                          }
                        //  button_off( prefix+nameTH);

                       }

               if((OrderType()==1)&& (wtik ==tik2))
                  if(hh>0)
                     if(Ask>=hh)
                       {
                        if(OrderSend(Symbol(),OP_BUY, Lot,Ask,50,0,0,StringConcatenate("6TH",wtik),Magic,0,clrRed) !=-1)
                          {
                           Alert("OPEN  buy 5 ", tik, " tik2 ",tik2);
                           if(((Low[0]  < tt) && (Ask > tt))  || ((Open[0]  > tt) && (Close[1] < tt)))
                              if(openorders(_Symbol,0,Lot,Ask,StringConcatenate("4TH",wtik)) == true)
                                {
                                 button_off(nameHH);
                                }
                           // openorders(_Symbol,1,Lot,Ask);

                           button_off(nameHH);
                           ObjectSetInteger(0,nameHH,OBJPROP_STATE,false);
                           obj_del(nameLHH);
                           obj_del(name2LHH);


                          }
                        // button_off( prefix+nameTH);
                       }
               //-----------------------------//  snnn
               if((OrderType()==0) && (sn>0))
                  //  sn=NormalizeDouble(get_object(StringConcatenate("SN",tik)),_Digits);
                  if(sn>0)
                     if(Bid<=sn)

                       {
                        Alert("CLOSE 0 nameSN ", nameLSN,  "  tik ",tik, "  order ", OrderTicket());

                        closeordersSN(tik2, sn);   // snnnnn buy
                        //  obj_del(namesN);
                        //   nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);

                        obj_cre(nameLSL,(op-sn),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);
                        // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                        obj_cre_trend(nameSLV,ti2,op-sn,ti2,op,clrMagenta);
                        nameSL= ObjectSetInteger(0,StringConcatenate(prefix,"SL",tik2),OBJPROP_STATE,true);
                        button_on(nameSL);
                        obj_del(nameLSN);
                        obj_del(nameLPN);
                        //    obj_cre(nameLSN,op-pn,clrRed);

                        button_off(nameSN);
                        button_off(nameHH);
                        //   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);
                        //   nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);
                        //   obj_del(StringConcatenate("HH",tik));
                        //  ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               if((OrderType()==1) && (sn>0))
                  // sn=NormalizeDouble(get_object(StringConcatenate("SN",tik)),_Digits);
                  if(sn>0)
                     if(Ask>=sn)
                       {
                        Alert("CLOSE 1 nameSN ", nameLSN,  "  tik ",tik, "  order ", OrderTicket());

                        closeordersSN(tik2,sn);

                        // nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);
                        obj_cre(nameLSL,(op+sn),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);
                        // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                        obj_cre_trend(nameSLV,ti2,op+sn,ti2,op,clrMagenta);

                        nameSL= ObjectSetInteger(0,StringConcatenate(prefix,"SL",tik2),OBJPROP_STATE,true);
                        button_on(nameSL);
                        obj_del(nameLSN);
                        obj_del(nameLPN);
                        //  obj_cre(nameLSN,op+pn,clrRed);


                        button_off(nameSN);
                        button_off(nameHH);

                        //  obj_del(StringConcatenate("HH",tik));
                        // ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               //-----------------------------//  pnnnnnn

               if((OrderType()==0) && (pn>0))
                  //  sn=NormalizeDouble(get_object(StringConcatenate("SN",tik)),_Digits);
                  if(pn>0)
                     if(Bid>=pn)

                       {
                        Alert("CLOSE 0 namePN ", nameLPN,  "  tik ",tik, "  order ", OrderTicket());

                        closeordersSN(tik2, pn);   // snnnnn buy
                        //  obj_del(namesN);
                        //   nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);
                        obj_cre(nameLSL,(op-pn),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);
                        // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                        obj_cre_trend(nameSLV,ti2,op-pn,ti2,op,clrMagenta);

                        nameSN= ObjectSetInteger(0,nameSN,OBJPROP_STATE,false);
                        button_on(nameSL);
                        obj_del(nameLSN);
                        obj_cre(nameLSN,op-pn,clrRed);

                        button_off(nameSN);
                        button_off(nameHH);
                        //   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);
                        //   nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);
                        //   obj_del(StringConcatenate("HH",tik));
                        //  ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               if((OrderType()==1) && (pn>0))
                  // sn=NormalizeDouble(get_object(StringConcatenate("SN",tik)),_Digits);
                  if(pn>0)
                     if(Ask<=pn)
                       {
                        Alert("CLOSE 1 nameLPN ", nameLPN,  "  tik ",tik, "  order ", OrderTicket());

                        closeordersSN(tik2, pn);

                        // nameSL= ObjectSetInteger(0,StringConcatenate("SL",tik),OBJPROP_STATE,true);
                        obj_cre(nameLSL,(op+pn),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);
                        // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                        obj_cre_trend(nameSLV,ti2,op+pn,ti2,op,clrMagenta);

                        nameSN= ObjectSetInteger(0,nameSL,OBJPROP_STATE,false);
                        button_on(nameSL);
                        obj_del(nameLSN);
                        obj_cre(nameLSN,op+pn,clrRed);


                        button_off(nameSN);
                        button_off(nameHH);

                        //  obj_del(StringConcatenate("HH",tik));
                        // ObjectDelete (StringConcatenate("HH",tik)+" n");
                       }

               //-----------------------------// trrr
               if(OrderType()==0)
                  if(rr>0)
                    {
                     if((Bid-tr)>rr)
                        set_object(nameLTR,(Ask-tr));
                     if(Bid<=rr)
                        closeorders(tik2);
                    }
               if(OrderType()==1)
                  if(rr>0)
                    {
                     if((Ask+tr)<rr)
                        set_object(nameLTR,(Bid+tr));
                     if(Ask>=rr)
                        closeorders(tik2);
                    }
                    
                    
                          if  ((but_stat(prefix+"lock h2")==true) )  /// lock hhhh
       {
       
    //   if((Bid<=th) && (th<HM1)
        //                 || ((Ask>=th) && (th>LM1))
              
       
   //     if ((lotMG < 0) && (Hsuma > 0))
   //  if (((Ask>lockh) && (Bid<lockh)&& (lotMG > 0) ) ||((Ask<lockh) && (Bid<lockh)&& (lotMG > 0) ))
     
     if  (lotMG > 0)
         if (((Bid<=lockh) && (lockh<HM1)&& (Hsuma < 0))
                         || ((Ask>=lockh) && (lockh>LM1)&& (Hsuma > 0))
                         )
              
     { if (OrderSend(Symbol(),OP_SELL, MathAbs(lotMG*Vkoef) ,Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrPink)!=-1)  
       { ObjectDelete (0, nameLHPtxt+LineId);
     button_off("lock h2");}
     }
    /*  if ((Bid<lockh) && ((lotMG > 0) && (Hsuma > 0)) ) 
     { if (OrderSend(Symbol(),OP_SELL, MathAbs(lotMG) ,Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrPink)!=-1)  
       { ObjectDelete (0, nameLHPtxt+LineId);
     button_off("lock h");}
     }*/
  //  if ((lotMG < 0) && (Hsuma > 0))
   // if ((( Ask>lockh) && (Bid<lockh) && ( lotMG < 0) ) ||((Ask>lockh) && (Bid>lockh)&& (lotMG < 0) ))
   if  (lotMG < 0)
      if  (((Ask>=lockh) && (lockh>LM1)&& (Hsuma < 0))
                           || ((Bid<=lockh) && (lockh<HM1)&& (Hsuma > 0))
                         ) 
              
    
    {  if (OrderSend(Symbol(),OP_BUY, MathAbs(lotMG*Vkoef) ,Ask,50,0,0,StringConcatenate("Lock B",tik),Magic,0,clrWhite)!=-1 )
         {   ObjectDelete (0, nameLHPtxt+LineId);
   button_off("lock h2");}
    }
    
    }
    
                            if  ((but_stat(prefix+"Lh2")==true) )  /// lock Lh hhh
       {
       
    //   if((Bid<=th) && (th<HM1)
        //                 || ((Ask>=th) && (th>LM1))
              
       
   //     if ((lotMG < 0) && (Hsuma > 0))
   //  if (((Ask>lockh) && (Bid<lockh)&& (lotMG > 0) ) ||((Ask<lockh) && (Bid<lockh)&& (lotMG > 0) ))
     
     if  (lotMG > 0)
         if (((Bid<=Lh) && (Lh<HM1)&& (LHsuma < 0))
                         || ((Ask>=Lh) && (Lh>LM1)&& (LHsuma > 0))
                         )
              
     { if (OrderSend(Symbol(),OP_SELL, MathAbs(lotMG*LVkoef) ,Bid,50,0,0,StringConcatenate("L S",tik),Magic,0,clrPink)!=-1)  
       { ObjectDelete (0, nameLHPtxt+LineId+1);
     button_off("Lh2");}
     }
    /*  if ((Bid<lockh) && ((lotMG > 0) && (Hsuma > 0)) ) 
     { if (OrderSend(Symbol(),OP_SELL, MathAbs(lotMG) ,Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrPink)!=-1)  
       { ObjectDelete (0, nameLHPtxt+LineId);
     button_off("lock h");}
     }*/
  //  if ((lotMG < 0) && (Hsuma > 0))
   // if ((( Ask>lockh) && (Bid<lockh) && ( lotMG < 0) ) ||((Ask>lockh) && (Bid>lockh)&& (lotMG < 0) ))
   if  (lotMG < 0)
      if  (((Ask>=Lh) && (Lh>LM1)&& (LHsuma < 0))
                           || ((Bid<=Lh) && (Lh<HM1)&& (LHsuma > 0))
                         ) 
              
    
    {  if (OrderSend(Symbol(),OP_BUY, MathAbs(lotMG*LVkoef) ,Ask,50,0,0,StringConcatenate("L B",tik),Magic,0,clrWhite)!=-1 )
         {   ObjectDelete (0, nameLHPtxt+LineId+1);
   button_off("Lh2");}
    }
    }
     // WindowRedraw ();
             
               WindowRedraw ();      
              }
  }
//+------------------------------------------------------------------+
//|                |
//+------------------------------------------------------------------+
bool set_object(string name,double pri)
  {
   return ObjectSetDouble(0,name,OBJPROP_PRICE,pri);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool proverca_sl_tp_ti()
  {
// int tik=-1;
   string ti="";
   double tt=0,ss=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || MagicALL==-1)
            if(OrderSymbol()==_Symbol)
              {
               tik=OrderTicket();
               tt=NormalizeDouble(get_object(StringConcatenate(prefix,"LTP",tik)),_Digits);
               ss=NormalizeDouble(get_object(StringConcatenate(prefix,"LSL",tik)),_Digits);
               ti=StringConcatenate("ti",tik);   ////StringConcatenate(prefix,"LTI",tik);   ///nameLTI;
               RefreshRates();
               if(OrderType()==0)
                 {
                  if(tt>0)
                     if(Bid>tt)
                        closeorders(tik);

                  if(ss>0)
                     if(Bid<ss)
                        closeorders(tik);

                  if(ObjectFind(ti)==0)
                     if((int)TimeCurrent()>(int)get_object_ti(ti))
                        closeorders(tik);
                 }
               if(OrderType()==1)
                 {
                  if(tt>0)
                     if(Ask<tt)
                        closeorders(tik);

                  if(ss>0)
                     if(Ask>ss)
                        closeorders(tik);

                  if(ObjectFind(ti)==0)
                     if((int)TimeCurrent()>(int)get_object_ti(ti))
                        closeorders(tik);
                 }
               if(OrderType()>1)
                  if(ObjectFind(ti)==0)
                     if((int)TimeCurrent()>(int)get_object_ti(ti))
                        closeorders(tik);
              }
   return false;
  }
//+------------------------------------------------------------------+
//|              |
//+------------------------------------------------------------------+
datetime get_object_ti(string name)
  {
   return (datetime)ObjectGetInteger(0,name,OBJPROP_TIME);
  }
//+------------------------------------------------------------------+
//|                                   |
//+------------------------------------------------------------------+
double get_object(string name)
  {
   double rez=0;
   ObjectGetDouble(0,name,OBJPROP_PRICE,0,rez);
   return rez;
  }
//+------------------------------------------------------------------+
//|            |
//+------------------------------------------------------------------+
void his_del_obj()
  {
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderMagicNumber()==Magic || MagicALL==-1)
            if(OrderSymbol()==_Symbol)
              {
               ObjectDelete(0,StringConcatenate(prefix,"TH",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"SL",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"TP",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"BR",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"TR",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Ti",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Ti",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"SN",OrderTicket()));

               ObjectDelete(0,StringConcatenate(prefix,"Re",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Xx",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"HH",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"LOT",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"Op",OrderTicket()));
               ObjectDelete(0,StringConcatenate("Op",OrderTicket()));

               ObjectDelete(0,StringConcatenate("TH",OrderTicket()));
               ObjectDelete(0,StringConcatenate("SL",OrderTicket()));
               ObjectDelete(0,StringConcatenate("TP",OrderTicket()));
               ObjectDelete(0,StringConcatenate("BR",OrderTicket()));
               ObjectDelete(0,StringConcatenate("TR",OrderTicket()));
               ObjectDelete(0,StringConcatenate("ti",OrderTicket()));
               ObjectDelete(0,StringConcatenate("HH",OrderTicket()));
               ObjectDelete(0,StringConcatenate("SN",OrderTicket())) ;


               ObjectDelete(0,StringConcatenate("LTH",OrderTicket()));
               ObjectDelete(0,StringConcatenate("2LTH",OrderTicket()));

               ObjectDelete(0,StringConcatenate("LSN",OrderTicket()));
               ObjectDelete(0,StringConcatenate("LSL",OrderTicket()));
               ObjectDelete(0,StringConcatenate("LTP",OrderTicket()));
               ObjectDelete(0,StringConcatenate(prefix,"LBR",OrderTicket())); /// LBRLBR
                ObjectDelete(0,StringConcatenate("LBR",OrderTicket()));
               ObjectDelete(0,StringConcatenate("LTR",OrderTicket()));
               ObjectDelete(0,StringConcatenate("Lti",OrderTicket()));
               ObjectDelete(0,StringConcatenate("LHH",OrderTicket()));
               ObjectDelete(0,StringConcatenate("LOT",OrderTicket()));
               ObjectDelete(0,StringConcatenate("MG",OrderTicket()));
               ObjectDelete(0,StringConcatenate("Profit",OrderTicket()));

              }
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void obj_cre_v_line(string txt,color col)
  {
   if(ObjectFind(0,txt)==-1)
     {
      ObjectCreate(0,txt,OBJ_VLINE,0,Time[0]+_Period*10*60,0);
      ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]+_Period*10*60);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,2);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void obj_cre(string txt,double pri,color col)
  {

   double ss ;
   if(ObjectFind(0,txt)==-1)
     {

      ObjectCreate(0,txt,OBJ_HLINE,0,Time[0],pri);
      ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]);
      ObjectSetDouble(0,txt,OBJPROP_PRICE,pri);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,2);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,"       "+txt);
      ObjectSetInteger(0,txt,OBJPROP_SELECTED,true);
       ObjectSetInteger(0,txt,OBJPROP_BACK,false);  ///foreground  contract
      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obj_cre_trend(string txt,datetime ti,double pri, datetime ti2, double pri2,color col)
  {

   double ss ;
   if(ObjectFind(0,txt)==-1)
     {
      /*ss=NormalizeDouble(get_object(StringConcatenate("< >")),_Digits);
       double rez=0;
       ObjectGetDouble(0,name,OBJPROP_PRICE,0,rez);
       //Comment ("ss= ",  ss);/ */
      ObjectCreate(0,txt,OBJ_TREND,0,ti,pri,ti2,pri2);
      // ObjectSetInteger(0,txt,OBJPROP_TIME,Time[0]);
      // ObjectSetDouble(0,txt,OBJPROP_PRICE,pri);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,1);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      ObjectSetInteger(0,txt,OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0,txt,OBJPROP_HIDDEN, false);
      ObjectSetInteger(0,txt,OBJPROP_SELECTED,true);


      WindowRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                |
//+------------------------------------------------------------------+
void obj_del(string txt)
  {
   ObjectDelete(0,txt);
  }
//+------------------------------------------------------------------+
//|                           |
//+------------------------------------------------------------------+
bool closeorders(int tik)
  {
   string sy="";
   if(OrderSelect(tik,SELECT_BY_TICKET))
      if(OrderMagicNumber()==Magic || MagicALL==-1)
         if(OrderSymbol()==_Symbol)
            if(OrderTicket()==tik)
              {
               sy=OrderSymbol();
               if(OrderType()==0)
                  if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(sy,MODE_BID),Slip,clrRed)==true)
                     pr("Order close Ok!!!");
                  else
                     pr("Order close Error !!!"+Error(GetLastError()),clrRed);

               if(OrderType()==1)
                  if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(sy,MODE_ASK),Slip,clrRed)==true)
                     pr("Order close Ok!!!");
                  else
                     pr("Order close Error !!!"+Error(GetLastError()),clrRed);
               if(OrderType()>1)
                  if(OrderDelete(tik,clrRed)==true)
                     pr("Order delete Ok!!!");
                  else
                     pr("Order delete Error !!!"+Error(GetLastError()),clrRed);
              }
   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool closeordersSN(int tik,  double pn)
  {
   string sy="";
   if(OrderSelect(tik,SELECT_BY_TICKET))
      if(OrderMagicNumber()==Magic || MagicALL==-1)

         //   Alert ( "CLOSE nameLPN ", nameLPN,  "  tik " ,tik  , "  order ", OrderTicket() );

         if(OrderSymbol()==_Symbol)
            if(OrderTicket()==tik)
              {
               int tik4=0, tik5=0 ;
               sy=OrderSymbol();
               if(OrderType()==0)
                  if(OrderClose(OrderTicket(),OrderLots()/2,MarketInfo(sy,MODE_BID),Slip,clrRed)==true)
                    {
                     pr("Order close Ok!!!");
                     obj_del(nameLPN);
                     obj_del(nameLSN);
                     int total=OrdersTotal();
                     for(int i=OrdersTotal()-1; i>=0; i--)
                       {
                        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                           tik4 = OrderSelect(total-1,SELECT_BY_POS) ;
                        //  Alert ( "CLOSE i ", i,  "  new pos " , OrderSelect(i,SELECT_BY_POS ) , "  order ", tik4 );


                       }
                     if(OrderSelect(total-1,SELECT_BY_POS)== true)
                       {
                        tik5= OrderTicket() ;
                        Alert("CLOSE total ", total,  "  new pos ", OrderSelect(0,SELECT_BY_POS), "  order ", OrderTicket(), " tik4 ", tik4, " tik5 ", tik5);
                        //  nameSL = StringConcatenate(prefix,"SL",tik5);
                        //     nameLSL = StringConcatenate(prefix,"LSL",tik5);
                        //   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);
                        // obj_del(nameLSN );
                        string   name55BSL = StringConcatenate(prefix,"55BSL",tik5);
                        name55BSL= ObjectSetInteger(0,name55BSL,OBJPROP_STATE,true);
                        obj_del(StringConcatenate(prefix,"55LBSL",tik5));
                        obj_cre(StringConcatenate(prefix,"55LBSL",tik5),op-pn,clrYellow);
                       }

                     obj_del(nameLPN);
                     obj_del(nameLSN);
                    }
                  else
                     pr("Order close Error !!!"+Error(GetLastError()),clrRed);


               if(OrderType()==1)
                  if(OrderClose(OrderTicket(),OrderLots()/2,MarketInfo(sy,MODE_ASK),Slip,clrRed)==true)
                    {
                     pr("Order delete Ok!!!");
                     obj_del(nameLPN);
                     obj_del(nameLSN);
                     int total=OrdersTotal();
                     for(int i=OrdersTotal()-1; i>=0; i--)
                       {
                        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                           tik4 = OrderSelect(total-1,SELECT_BY_POS) ;
                        //  Alert ( "CLOSE i ", i,  "  new pos " , OrderSelect(i,SELECT_BY_POS ) , "  order ", tik4 );


                       }
                     if(OrderSelect(total-1,SELECT_BY_POS)== true)
                       {
                        tik5= OrderTicket() ;
                        //   Alert ( "CLOSE total ", total,  "  new pos " , OrderSelect(0,SELECT_BY_POS ) , "  order ", OrderTicket() , " tik4 ", tik4, " tik5 ", tik5);
                        //  nameSL = StringConcatenate(prefix,"SL",tik5);
                        //     nameLSL = StringConcatenate(prefix,"LSL",tik5);
                        //   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);
                        // obj_del(nameLSN );
                        string   name55SSL = StringConcatenate(prefix,"55SSL",tik5);
                        name55SSL= ObjectSetInteger(0,name55SSL,OBJPROP_STATE,true);
                        obj_del(StringConcatenate(prefix,"55LSSL",tik5));
                        obj_cre(StringConcatenate(prefix,"55LSSL",tik5),op+pn,clrYellow);
                       }

                     obj_del(nameLPN);
                     obj_del(nameLSN);
                    }
                  else
                     pr("Order delete Error !!!"+Error(GetLastError()),clrRed);
              }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetX(const string name,int xx)
  {
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,xx);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openorders(string sy="",int typ=0,double lot=0,double price=0,string com="")
  {
   int tik=-2,p=0;
   if(sy=="")
      sy=_Symbol;
   if(lot<MarketInfo(sy,MODE_MINLOT))
      lot=MarketInfo(sy,MODE_MINLOT);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(price==0) // Если цена не указана
     {
      if(typ==0)
         price=MarketInfo(sy,MODE_ASK);
      else
         price=MarketInfo(sy,MODE_BID);
     }
   if(com=="")
      com=StringConcatenate(WindowExpertName(),"  ",Magic);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsTradeContextBusy())
     {
      if(typ==0 || typ==2 || typ==4)
        {
         tik=OrderSend(sy,typ,NormalizeDouble(lot,2),NormalizeDouble(price,(int)MarketInfo(sy,MODE_DIGITS)),Slip,0,0,com,Magic,0,clrBlue);
        }
      if(typ==1 || typ==3 || typ==5)
        {
         tik=OrderSend(sy,typ,NormalizeDouble(lot,2),NormalizeDouble(price,(int)MarketInfo(sy,MODE_DIGITS)),Slip,0,0,com,Magic,0,clrRed);
        }
      if(tik>=0)
        {
         pr("Order Open Ok !!!");
         return true;
        }
      else
        {
         p++;
         pr(__FUNCTION__+"_Error_"+Error(GetLastError()));
         Sleep(500);
         if(p>=5)
           {
            pr(__FUNCTION__+" Order open error ");
            return false;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|Функция ошибок                                                    |
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   bool Lan=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
   switch(error_code)
     {
      case 0:
         if(Lan)
            error_string="Нет ошибки.";
         break;
         error_string="No error returned.";
         break;
      case 1:
         if(Lan)
            error_string="Нет ошибки, но результат неизвестен.";
         break;
         error_string="No error returned, but the result is unknown.";
         break;
      case 2:
         if(Lan)
            error_string="Общая ошибка.";
         break;
         error_string="Common error.";
         break;
      case 3:
         if(Lan)
            error_string="Неправильные параметры.";
         break;
         error_string="Invalid trade parameters.";
         break;
      case 4:
         if(Lan)
            error_string="Торговый сервер занят.";
         break;
         error_string="Trade server is busy.";
         break;
      case 5:
         if(Lan)
            error_string="Старая версия клиентского терминала.";
         break;
         error_string="Old version of the client terminal.";
         break;
      case 6:
         if(Lan)
            error_string="Нет связи с торговым сервером.";
         break;
         error_string="No connection with trade server.";
         break;
      case 7:
         if(Lan)
            error_string="Недостаточно прав.";
         break;
         error_string="Not enough rights.";
         break;
      case 8:
         if(Lan)
            error_string="Слишком частые запросы.";
         break;
         error_string="Too frequent requests.";
         break;
      case 9:
         if(Lan)
            error_string="Недопустимая операция нарушающая функционирование сервера.";
         break;
         error_string="Malfunctional trade operation.";
         break;
      case 64:
         if(Lan)
            error_string="Счет заблокирован.";
         break;
         error_string="Account disabled.";
         break;
      case 65:
         if(Lan)
            error_string="Неправильный номер счета.";
         break;
         error_string="Invalid account.";
         break;
      case 128:
         if(Lan)
            error_string="Истек срок ожидания совершения сделки.";
         break;
         error_string="Trade timeout.";
         break;
      case 129:
         if(Lan)
            error_string="Неправильная цена.";
         break;
         error_string="Invalid price.";
         break;
      case 130:
         if(Lan)
            error_string="Неправильные стопы.";
         break;
         error_string="Invalid stops.";
         break;
      case 131:
         if(Lan)
            error_string="Неправильный объем.";
         break;
         error_string="Invalid trade volume.";
         break;
      case 132:
         if(Lan)
            error_string="Рынок закрыт.";
         break;
         error_string="Market is closed.";
         break;
      case 133:
         if(Lan)
            error_string="Торговля запрещена.";
         break;
         error_string="Trade is disabled.";
         break;
      case 134:
         if(Lan)
            error_string="Недостаточно денег для совершения операции.";
         break;
         error_string="Not enough money.";
         break;
      case 135:
         if(Lan)
            error_string="Цена изменилась.";
         break;
         error_string="Price changed.";
         break;
      case 136:
         if(Lan)
            error_string="Нет цен.";
         break;
         error_string="Off quotes.";
         break;
      case 137:
         if(Lan)
            error_string="Брокер занят.";
         break;
         error_string="Broker is busy.";
         break;
      case 138:
         if(Lan)
            error_string="Новые цены.";
         break;
         error_string="Requote.";
         break;
      case 139:
         if(Lan)
            error_string="Ордер заблокирован и уже обрабатывается.";
         break;
         error_string="Order is locked.";
         break;
      case 140:
         if(Lan)
            error_string="Разрешена только покупка.";
         break;
         error_string="Long positions only allowed.";
         break;
      case 141:
         if(Lan)
            error_string="Слишком много запросов.";
         break;
         error_string="Too many requests.";
         break;
      case 145:
         if(Lan)
            error_string="Модификация запрещена, так как ордер слишком близок к рынку.";
         break;
         error_string="Modification denied because an order is too close to market.";
         break;
      case 146:
         if(Lan)
            error_string="Подсистема торговли занята.";
         break;
         error_string="Trade context is busy.";
         break;
      case 147:
         if(Lan)
            error_string="Использование даты истечения ордера запрещено брокером.";
         break;
         error_string="Expirations are denied by broker.";
         break;
      case 148:
         if(Lan)
            error_string="Количество открытых и отложенных ордеров достигло предела, установленного брокером.";
         break;
         error_string="The amount of opened and pending orders has reached the limit set by a broker.";
         break;
      case 4000:
         if(Lan)
            error_string="Нет ошибки.";
         break;
         error_string="No error.";
         break;
      case 4001:
         if(Lan)
            error_string="Неправильный указатель функции.";
         break;
         error_string="Wrong function pointer.";
         break;
      case 4002:
         if(Lan)
            error_string="Индекс массива - вне диапазона.";
         break;
         error_string="Array index is out of range.";
         break;
      case 4003:
         if(Lan)
            error_string="Нет памяти для стека функций.";
         break;
         error_string="No memory for function call stack.";
         break;
      case 4004:
         if(Lan)
            error_string="Переполнение стека после рекурсивного вызова.";
         break;
         error_string="Recursive stack overflow.";
         break;
      case 4005:
         if(Lan)
            error_string="На стеке нет памяти для передачи параметров.";
         break;
         error_string="Not enough stack for parameter.";
         break;
      case 4006:
         if(Lan)
            error_string="Нет памяти для строкового параметра.";
         break;
         error_string="No memory for parameter string.";
         break;
      case 4007:
         if(Lan)
            error_string="Нет памяти для временной строки.";
         break;
         error_string="No memory for temp string.";
         break;
      case 4008:
         if(Lan)
            error_string="Неинициализированная строка.";
         break;
         error_string="Not initialized string.";
         break;
      case 4009:
         if(Lan)
            error_string="Неинициализированная строка в массиве.";
         break;
         error_string="Not initialized string in an array.";
         break;
      case 4010:
         if(Lan)
            error_string="Нет памяти для строкового массива.";
         break;
         error_string="No memory for an array string.";
         break;
      case 4011:
         if(Lan)
            error_string="Слишком длинная строка.";
         break;
         error_string="Too long string.";
         break;
      case 4012:
         if(Lan)
            error_string="Остаток от деления на ноль.";
         break;
         error_string="Remainder from zero divide.";
         break;
      case 4013:
         if(Lan)
            error_string="Деление на ноль.";
         break;
         error_string="Zero divide.";
         break;
      case 4014:
         if(Lan)
            error_string="Неизвестная команда.";
         break;
         error_string="Unknown command.";
         break;
      case 4015:
         if(Lan)
            error_string="Неправильный переход.";
         break;
         error_string="Wrong jump.";
         break;
      case 4016:
         if(Lan)
            error_string="Неинициализированный массив.";
         break;
         error_string="Not initialized array.";
         break;
      case 4017:
         if(Lan)
            error_string="Вызовы DLL не разрешены.";
         break;
         error_string="DLL calls are not allowed.";
         break;
      case 4018:
         if(Lan)
            error_string="Невозможно загрузить библиотеку.";
         break;
         error_string="Cannot load library.";
         break;
      case 4019:
         if(Lan)
            error_string="Невозможно вызвать функцию.";
         break;
         error_string="Cannot call function.";
         break;
      case 4020:
         if(Lan)
            error_string="Вызовы внешних библиотечных функций не разрешены.";
         break;
         error_string="EA function calls are not allowed.";
         break;
      case 4021:
         if(Lan)
            error_string="Недостаточно памяти для строки, возвращаемой из функции.";
         break;
         error_string="Not enough memory for a string returned from a function.";
         break;
      case 4022:
         if(Lan)
            error_string="Система занята.";
         break;
         error_string="System is busy.";
         break;
      case 4050:
         if(Lan)
            error_string="Неправильное количество параметров функции.";
         break;
         error_string="Invalid function parameters count.";
         break;
      case 4051:
         if(Lan)
            error_string="Недопустимое значение параметра функции.";
         break;
         error_string="Invalid function parameter value.";
         break;
      case 4052:
         if(Lan)
            error_string="Внутренняя ошибка строковой функции.";
         break;
         error_string="String function internal error.";
         break;
      case 4053:
         if(Lan)
            error_string="Ошибка массива.";
         break;
         error_string="Some array error.";
         break;
      case 4054:
         if(Lan)
            error_string="Неправильное использование массива-таймсерии.";
         break;
         error_string="Incorrect series array using.";
         break;
      case 4055:
         if(Lan)
            error_string="Ошибка пользовательского индикатора.";
         break;
         error_string="Custom indicator error.";
         break;
      case 4056:
         if(Lan)
            error_string="Массивы несовместимы.";
         break;
         error_string="Arrays are incompatible.";
         break;
      case 4057:
         if(Lan)
            error_string="Ошибка обработки глобальныех переменных.";
         break;
         error_string="Global variables processing error.";
         break;
      case 4058:
         if(Lan)
            error_string="Глобальная переменная не обнаружена.";
         break;
         error_string="Global variable not found.";
         break;
      case 4059:
         if(Lan)
            error_string="Функция не разрешена в тестовом режиме.";
         break;
         error_string="Function is not allowed in testing mode.";
         break;
      case 4060:
         if(Lan)
            error_string="Функция не подтверждена.";
         break;
         error_string="Function is not confirmed.";
         break;
      case 4061:
         if(Lan)
            error_string="Ошибка отправки почты.";
         break;
         error_string="Mail sending error.";
         break;
      case 4062:
         if(Lan)
            error_string="Ожидается параметр типа string.";
         break;
         error_string="String parameter expected.";
         break;
      case 4063:
         if(Lan)
            error_string="Ожидается параметр типа integer.";
         break;
         error_string="Integer parameter expected.";
         break;
      case 4064:
         if(Lan)
            error_string="Ожидается параметр типа double.";
         break;
         error_string="Double parameter expected.";
         break;
      case 4065:
         if(Lan)
            error_string="В качестве параметра ожидается массив.";
         break;
         error_string="Array as parameter expected.";
         break;
      case 4066:
         if(Lan)
            error_string="Запрошенные исторические данные в состоянии обновления.";
         break;
         error_string="Requested history data in updating state.";
         break;
      case 4067:
         if(Lan)
            error_string="Ошибка при выполнении торговой операции.";
         break;
         error_string="Some error in trade operation execution.";
         break;
      case 4099:
         if(Lan)
            error_string="Конец файла.";
         break;
         error_string="End of a file.";
         break;
      case 4100:
         if(Lan)
            error_string="Ошибка при работе с файлом.";
         break;
         error_string="Some file error.";
         break;
      case 4101:
         if(Lan)
            error_string="Неправильное имя файла.";
         break;
         error_string="Wrong file name.";
         break;
      case 4102:
         if(Lan)
            error_string="Слишком много открытых файлов.";
         break;
         error_string="Too many opened files.";
         break;
      case 4103:
         if(Lan)
            error_string="Невозможно открыть файл.";
         break;
         error_string="Cannot open file.";
         break;
      case 4104:
         if(Lan)
            error_string="Несовместимый режим доступа к файлу.";
         break;
         error_string="Incompatible access to a file.";
         break;
      case 4105:
         if(Lan)
            error_string="Ни один ордер не выбран.";
         break;
         error_string="No order selected.";
         break;
      case 4106:
         if(Lan)
            error_string="Неизвестный символ.";
         break;
         error_string="Unknown symbol.";
         break;
      case 4107:
         if(Lan)
            error_string="Неправильный параметр цены для торговой функции.";
         break;
         error_string="Invalid price param.";
         break;
      case 4108:
         if(Lan)
            error_string="Неверный номер тикета.";
         break;
         error_string="Invalid ticket.";
         break;
      case 4109:
         if(Lan)
            error_string="Торговля не разрешена.";
         break;
         error_string="Trade is not allowed.";
         break;
      case 4110:
         if(Lan)
            error_string="Длинные позиции не разрешены.";
         break;
         error_string="Longs are not allowed.";
         break;
      case 4111:
         if(Lan)
            error_string="Короткие позиции не разрешены.";
         break;
         error_string="Shorts are not allowed.";
         break;
      case 4200:
         if(Lan)
            error_string="Объект уже существует.";
         break;
         error_string="Object already exists.";
         break;
      case 4201:
         if(Lan)
            error_string="Запрошено неизвестное свойство объекта.";
         break;
         error_string="Unknown object property.";
         break;
      case 4202:
         if(Lan)
            error_string="Объект не существует.";
         break;
         error_string="Object does not exist.";
         break;
      case 4203:
         if(Lan)
            error_string="Неизвестный тип объекта.";
         break;
         error_string="Unknown object type.";
         break;
      case 4204:
         if(Lan)
            error_string="Нет имени объекта.";
         break;
         error_string="No object name.";
         break;
      case 4205:
         if(Lan)
            error_string="Ошибка координат объекта.";
         break;
         error_string="Object coordinates error.";
         break;
      case 4206:
         if(Lan)
            error_string="Не найдено указанное подокно.";
         break;
         error_string="No specified subwindow.";
         break;
      case 4207:
         if(Lan)
            error_string="Ошибка при работе с объектом.";
         break;
         error_string="ERR_SOME_OBJECT_ERROR.";
         break;
      default:
         if(Lan)
            error_string="Не известная ошибка.";
         error_string="Error is not known.";
     }
   return(error_string);
  }
//+------------------------------------------------------------------+
//|                             |
//+------------------------------------------------------------------+
void pr(string txt,color cvet=C'80,80,80')
  {
   txt=StringConcatenate(StringSubstr(TimeS(),11,8))+" - "+txt;
   ArrayResize(info,Coment,1000);
   ArrayResize(cvit,Coment,1000);
   for(int i=Coment-1; i>0; i--)
     {
      if(info[i]!=info[i-1])
         info[i]=info[i-1];
      if(cvit[i]!=cvit[i-1])
         cvit[i]=cvit[i-1];
     }
   if(info[0]!=txt && txt!="")
     {
      info[0]=txt;
      cvit[0]=cvet;
     }
   for(int i=0; i<Coment; i++)
      ButtonCreate(0,StringConcatenate("Error",i),0,250+252*i,16,250,16,3,info[i],"Arial",10,cvit[i],C'236,233,216');
  }
//+------------------------------------------------------------------+
//|                                                 |
//+------------------------------------------------------------------+
string TimeS()
  {
   datetime Cur=0;
   Cur=TimeCurrent();
   RefreshRates();
   return StringFormat("%02d.%02d.%02d %02d-%02d-%02d",TimeYear(Cur),TimeMonth(Cur),TimeDay(Cur),TimeHour(Cur),TimeMinute(Cur),TimeSeconds(Cur));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit5(const int reason)
  {
   EventKillTimer();
   Comment(WindowExpertName()+" successfully deinitialized !   "+getUninitReasonText(_UninitReason));
  }
//+------------------------------------------------------------------+
//|                          |
//+------------------------------------------------------------------+
void del()
  {
   obj_del("clock");
   for(int k=ObjectsTotal()-1; k>=0; k--)
      if(StringSubstr(ObjectName(k),0,2)==prefix)
         ObjectDelete(ObjectName(k));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,
                  string                  name="Button",
                  const int               sub_window=0,
                  const int               xx=0,
                  const int               yy=0,
                  const int               width=50,
                  const int               height=18,
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,
                  const string            text="Button",
                  const string            font="Arial",
                  const int               font_size=10,
                  const color             clr=clrBlack,
                  const color             back_clr=C'236,233,216',
                  const color             border_clr=clrNONE,
                  const bool              state=false,
                  const bool              back=false,
                  const bool              selection=false,
                  const bool              hidden=true,
                  const long              z_order=999,
                  const string            toltip="")
  {
   ResetLastError();
   name=StringConcatenate(prefix,name);
   if(ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);

      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,"          "+toltip);
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreateR(const long              chart_ID=0,
                   string                  name="Button",
                   const int               sub_window=0,
                   const int               xx=0,
                   const int               yy=0,
                   const int               width=50,
                   const int               height=18,
                   const ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER,
                   const string            text="Button",
                   const string            font="Arial",
                   const int               font_size=10,
                   const color             clr=clrBlack,
                   const color             back_clr=C'236,233,216',
                   const color             border_clr=clrNONE,
                   const bool              state=false,
                   const bool              back=false,
                   const bool              selection=false,
                   const bool              hidden=true,
                   const long              z_order=999,
                   const string            toltip="")
  {
   ResetLastError();
   name=StringConcatenate(prefix,name);
   if(ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);

      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,toltip);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                          |
//+------------------------------------------------------------------+
long IntGetX(const string name)
  {
   return ObjectGetInteger(0,prefix+name,OBJPROP_XDISTANCE);
  }
//+------------------------------------------------------------------+
//|                                          |
//+------------------------------------------------------------------+
long IntGetY(const string name)
  {
   return ObjectGetInteger(0,prefix+name,OBJPROP_YDISTANCE);
  }
//+------------------------------------------------------------------+
//|             |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
   bool Lan=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
   switch(reasonCode)
     {
      case 0:
         if(Lan)
            text="Эксперт прекратил свою работу, вызвав функцию ExpertRemove()";
         break;
         text="Account was changed";
         break;
      case 1:
         if(Lan)
            text="Программа удалена с графика";
         del();
         break;
         text="Program "+__FILE__+" was removed from chart";
         del();
         break;
      case 2:
         if(Lan)
            text="Программа перекомпилирована";
         del();
         break;
         text="Program "+__FILE__+" was recompiled";
         del();
         break;
      case 3:
         if(Lan)
            text="Символ или период графика был изменен";
         break;
         text="Symbol or timeframe was changed";
         break;
      case 4:
         if(Lan)
            text="График закрыт";
         break;
         text="Chart was closed";
         break;
      case 5:
         if(Lan)
            text="Входные параметры были изменены пользователем";
         break;
         text="Input-parameter was changed";
         break;
      case 6:
         if(Lan)
            text="Переподключение к торговому серверу ";
         break;
         text="Reconnect to the trading server";
         break;
      case 7:
         if(Lan)
            text="Применен другой шаблон графика";
         break;
         text="New template was applied to chart";
         break;
      case 8:
         if(Lan)
            text="Признак того, что обработчик OnInit() вернул ненулевое значение";
         break;
         text="A sign that the handler OnInit() returned non-zero value";
         break;
      case 9:
         if(Lan)
            text="Терминал был закрыт";
         break;
         text="The terminal was closed";
         break;
      default:
         if(Lan)
            text="Причина деинициализации программы не известна";
         text="Another reason";
     }
   return text;
  }
//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+
bool but_stat(string name)
  {
   if(ObjectGetInteger(0,name,OBJPROP_STATE)==true)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                           |
//+------------------------------------------------------------------+
bool button_off(string name)
  {
   name=StringConcatenate(prefix,name);
   if(ObjectSetInteger(0,name,OBJPROP_STATE,false)==true)
      return true;
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool button_on(string name)
  {
   name=StringConcatenate(prefix,name);
   if(ObjectSetInteger(0,name,OBJPROP_STATE,false)==false)
      return true;
   return true;
  }
//+-----------

//|                               |
//+------------------------------------------------------------------+
void tim()
  {
   RefreshRates();
   string h=DoubleToStr(((int)Time[0]+PeriodSeconds(PERIOD_CURRENT)-(int)TimeCurrent())/60,0);
   string m=DoubleToStr((60-TimeSeconds(TimeCurrent())),0);
   if(StringLen(m)<2)
      m="0"+m;
   string time=StringConcatenate(h," : ",m);
//   TextCreate(0,"clock",0,Time[0]+_Period*10*60,Bid,time);
   TextCreate(0,"clock",0,Time[0]+(Time[0]-Time[15]),Bid,time);
   string h2=DoubleToStr(((int)Time[0]+PeriodSeconds(PERIOD_H1)-(int)TimeCurrent())/60,0);
   string m2=DoubleToStr((60-TimeSeconds(TimeCurrent())),0);
   string time2=StringConcatenate(h2," : ",m2);
// TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[WindowFirstVisibleBar()])/10 ,Bid,time2);
// TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[10]),Bid,time2);

   switch(_Period)
     {
      case PERIOD_M1 :
         TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[30]),Bid,time2);
      case PERIOD_M5 :
         TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[30]),Bid,time2);
      case PERIOD_M15 :
         TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[30]),Bid,time2);
      case PERIOD_M30:
         TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[60]),Bid,time2);
      case PERIOD_H1:
         TextCreate(0,"clockH",0,Time[0]+(Time[0]-Time[120]),Bid,time2);
     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,
                const string            name="Text",
                const int               sub_window=0,
                datetime                time=0,
                double                  price=0,
                const string            text="Text",
                const string            font="Arial",
                const int               font_size=15,
                const color             clr=clrRed,
                const double            angle=0.0,
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER,
                const bool              back=false,
                const bool              selection=true,
                const bool              hidden=true,
                const long              z_order=0)
  {
   ResetLastError();
   if(ObjectFind(0,name)==-1)
      ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                               SendCloseOrder.mq4 |
//|                               Copyright © 2009, Vladimir Hlystov |
//|  v 1.00 Устанавливает или закрывает ордера при пересечении линий |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Hlystov"
#property link      "cmillion@narod.ru"
string ver=" 2.0";
#property strict
#property description "Устанавливает или закрывает ордера когда закрытая свеча пересечет линию или коснется ее"
/*Советник открывает позиции по трендовым линиям.
На графике кнопки – бай, сел, стоп, профит
Алгоритм на примере короткой сделки;
1. Выбираем  Sell. После этого появляется линия и нам нужно установить ее так как нужно.
2. Жмем кнопку стоп лосс, выбираем и ставим нужную линию.
3. Жмем кнопку т.профит и строим нужную линию.
Открытие ордера происходит, если свеча закрывается ниже линии. Если установлено только касание, то позиция откроется не дожидаясь закрытия свечи в тот момент, когда цена коснется линии.
Можно производить доливки по новым линиям, стоп и профит, в этом случае, привязывается к тем же линиям SL или TP. Если установлено размещать стопы у брокера, то советник выставляет реальный SL и TP по линии и перемещает его, если линия наклонная.
Возможно открытие ордеров вручную. Чтобы советник их подхватил, установите магик = 0.
Линии стоп лосс и тейк профит можно перемещать вручную.

https://youtu.be/jN7BDORmPz0


*/
//-------------------------------------------------------------------

// Rexi2

extern int    levelOpen    = 50;     //начальное расстояние до линии открытия
extern int    levelClose   = 100;     //начальное расстояние до линии закрытия
//extern double lot          = 0.10;   //лот
///extern bool   intersection_touch = true;//пересечение или касание
extern bool   BrokerStop = false;//установить реальные стопы у брокера
extern int    Magic1        = 0;
extern int    MaxOrdersCandl = 1;  //на одной свече открывать не более
extern color  colorBuy     = clrAqua;
extern color  colorSell    = clrOrangeRed;
extern color  clorClose    = clrDarkRed;
int slippage = 20;
extern double  Lot               = 0.10;  //лот первого ордера от цены, далее по формуле
extern double  LotPlus           = 0.10;  //добавка к начальному лоту
double STOPLEVEL;
double StopProfit=0;
string val,GV_kn_BS,GV_kn_SS,GV_kn_BL,GV_kn_SL,GV_kn_TrP,GV_kn_CBA,GV_kn_CSA,GV_kn_CA;
bool D,LANGUAGE;

//-------------------------------------------------------------------
int OnInit2()
  {
   int X=50,Y=150;
// RectLabelCreate(0,"LINES _fon0",0,X-3,Y,916,320,clrGray,clrLightGray);Y+=5;
   LabelCreate(0,"LINES intersection_touch",0,X+5,Y,CORNER_LEFT_UPPER,intersection_touch?"intersection":"touch","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   Y+=20;
//  RectLabelCreate(0,"LINES _fon",0,X,Y,910,290,clrGray,clrLightGray);
   X+=5;
   Y+=5;


   ButtonCreate(0,"LINES Buy",0,X,Y,50,40,"BUY",Font,Width,Color1,Color8,Color7,false);            //   ButtonCreate(0,"LOCK Buy" ,0,X+150,Y,500,40,"LOCK BUY",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"LINES SL B",0,X+50,Y,50,20,"SL",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"LOCK SL B",0,X+100,Y,100,20,"LOCK SL",Font,Width,Color1,Color8,Color7,false);
   Y+=20;
   ButtonCreate(0,"LINES TP B",0,X+50,Y,50,20,"TP",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"LOCK TP B",0,X+100,Y,100,20,"LOCK TP",Font,Width,Color1,Color8,Color7,false);
   Y+=20;

   ButtonCreate(0,"LINES Sell",0,X,Y,50,40,"SELL",Font,Width,Color1,Color8,Color7,false);         //     ButtonCreate(0,"LOCK Sell",0,X+150,Y,500,40,"LOCK SELL");
   ButtonCreate(0,"LINES SL S",0,X+50,Y,50,20,"SL",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"LOCK SL S",0,X+100,Y,100,20,"LOCK SL",Font,Width,Color1,Color8,Color7,false);
   Y+=20;
   ButtonCreate(0,"LINES TP S",0,X+50,Y,50,20,"TP",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"LOCK TP S",0,X+100,Y,100,20,"LOCK TP",Font,Width,Color1,Color8,Color7,false);
   Y+=20;
   /*
   ButtonCreate(0,"LINES Buy" ,0,X,Y,50,40,"BUY");           //   ButtonCreate(0,"LOCK Buy" ,0,X+150,Y,500,40,"LOCK BUY");
   ButtonCreate(0,"LINES SL B",0,X+50,Y,50,20,"SL");     ButtonCreate(0,"LOCK SL B",0,X+100,Y,50,20,"LOCK SL");  Y+=20;
   ButtonCreate(0,"LINES TP B",0,X+50,Y,50,20,"TP");     ButtonCreate(0,"LOCK TP B",0,X+100,Y,50,20,"LOCK TP"); Y+=20;

   ButtonCreate(0,"LINES Sell",0,X,Y,50,40,"SELL");         //     ButtonCreate(0,"LOCK Sell",0,X+150,Y,500,40,"LOCK SELL");
   ButtonCreate(0,"LINES SL S",0,X+50,Y,50,20,"SL"); ButtonCreate(0,"LOCK SL S",0,X+100,Y,100,20,"LOCK SL"); Y+=20;
   ButtonCreate(0,"LINES TP S",0,X+50,Y,50,20,"TP"); ButtonCreate(0,"LOCK TP S",0,X+100,Y,100,20,"LOCK TP"); Y+=20;*/
//   X+=15;  Y+=15;


//  ButtonCreate(0,"LOCK TP S",0,X+300,Y,300,20,"LOCK TP");Y+=20;
//   ButtonCreate(0,"LOT",0,X+200,Y+100,500,20,"LOT");Y+=20;


//  RectLabelCreate(0,"cm F",0,229,19,220,225);

   DrawLABEL("cm lot",Text(LANGUAGE,"Лот","Lot"),200,138,clrGray,ANCHOR_LEFT);
   DrawLABEL("cm +Plus",Text(LANGUAGE,"+ доливка","+ lot"),120,138,clrGray,ANCHOR_LEFT);
   EditCreate(0,"cm Lot",0,175,128,50,20,DoubleToString(Lot,2),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm LotPlus",0,65,128,50,20,DoubleToString(LotPlus,2),"Arial",8,ALIGN_CENTER,false);
   EventSetTimer(1);
//  OnTick();
   Comment("Start ",WindowExpertName());
   return(INIT_SUCCEEDED);
  }
//-------------------------------------------------------------------
void OnDeinit2(const int reason)
  {

   ObjectsDeleteAll(0,"LOT");
   switch(reason)
     {
      case REASON_ACCOUNT: //Активирован другой счет либо произошло переподключение к торговому серверу вследствие изменения настроек счета
         ObjectsDeleteAll(0,"LINES");
         break;
      case REASON_CHARTCHANGE: //Символ или период графика был изменен
         break;
      case REASON_CHARTCLOSE: //График закрыт
         ObjectsDeleteAll(0,"LINES");
         break;
      case REASON_PARAMETERS: //Входные параметры были изменены пользователем
         ObjectsDeleteAll(0,"LINES");
         break;
      case REASON_RECOMPILE: //Программа перекомпилирована
         break;
      case REASON_REMOVE: //Программа удалена с графика
         ObjectsDeleteAll(0,"LINES");
         break;
      case REASON_TEMPLATE: //Применен другой шаблон графика
         ObjectsDeleteAll(0,"LINES");
         break;
      case REASON_PROGRAM://Эксперт прекратил свою работу, вызвав функцию ExpertRemove()
         ObjectsDeleteAll(0,"LINES");
         break;
      default:
         ObjectsDeleteAll(0,"LINES");
         ObjectsDeleteAll(0,"LOCK");
     }
  }
//-------------------------------------------------------------------
void OnTick8888()
  {
//  if (  show_data )
     {

      //    OnTimer();



      OnTimer();

      // OnTick99();
     }
//show_data=False ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer4444()
  {

   Lot=StringToDouble(ObjectGetString(0,"cm Lot",OBJPROP_TEXT));
   LotPlus=StringToDouble(ObjectGetString(0,"cm LotPlus",OBJPROP_TEXT));


   int i,b=0,s=0,tip;
// double price,OSL,OTP,OOP;
   double SLB=ObjectGetValueByShift("LINES BUY SL",0);
   double SLS=ObjectGetValueByShift("LINES SELL SL",0);
   double TPB=ObjectGetValueByShift("LINES BUY TP",0);
   double TPS=ObjectGetValueByShift("LINES SELL TP",0);

//  LabelCreate(0,"LINES SLB",0,400,40,CORNER_LEFT_UPPER,DoubleToString(SLB,Digits),"Arial",10,clrRed);

   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
           {
            tip = OrderType();
            OSL = NormalizeDouble(OrderStopLoss(),Digits);
            OTP = NormalizeDouble(OrderTakeProfit(),Digits);
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            if(OTP = 0)
              {
               OTP =OOP+OOP ;
               OrderModify(OrderTicket(),OOP,OSL,OTP,0,clrNONE) ;
              }
            if(tip==OP_BUY)
              {
               if(OrderOpenTime()>=Time[0])
                  b++; //MaxOrdersCandl
               if(Bid<=SLB && SLB!=0)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE))
                     continue;
                 }
               if(Bid>=TPB && TPB!=0)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE))
                     continue;
                 }
               if(BrokerStop)
                 {
                  if(OSL != SLB || OTP != TPB)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SLB,TPB,0,clrNONE))
                        Print("Error OrderModifyB <<",GetLastError(),">> ");
                    }
                 }
               else
                 {
                  if(OSL != 0 || OTP != 0)
                    {
                     //// stop rexi            if (!OrderModify(OrderTicket(),OOP,0,0,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
              }
            if(tip==OP_SELL)
              {
               if(OrderOpenTime()>=Time[0])
                  s++;
               if(Ask>=SLS && SLS!=0)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE))
                     continue;
                 }
               if(Ask<=TPS && TPS!=0)
                 {
                  if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE))
                     continue;
                 }
               if(BrokerStop)
                 {
                  if(OSL != SLS || OTP != TPS)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SLS,TPS,0,clrNONE))
                        Print("Error OrderModifyS <<",GetLastError(),">> ");
                    }
                 }
               else
                 {
                  if(OSL != 0 || OTP != 0)
                    {
                     ///     ///         if (!OrderModify(OrderTicket(),OOP,0,0,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
              }
           }
        }
     }
   bool BUY=ObjectGetInteger(0,"LINES Buy",OBJPROP_STATE);
   bool SELL=ObjectGetInteger(0,"LINES Sell",OBJPROP_STATE);
   bool SLb=ObjectGetInteger(0,"LINES SL B",OBJPROP_STATE);
   bool TPb=ObjectGetInteger(0,"LINES TP B",OBJPROP_STATE);
   bool SLs=ObjectGetInteger(0,"LINES SL S",OBJPROP_STATE);
   bool TPs=ObjectGetInteger(0,"LINES TP S",OBJPROP_STATE);

//---

   if(BUY)
     {
      if(ObjectFind("LINES _BUY")==-1)
        {
         price=MathMax(Ask,High[1])+levelOpen*Point;
         TrendCreate(0,"LINES _BUY",0,Time[10],price,Time[0],price,colorBuy,STYLE_SOLID,3);
        }
     }
   else
      ObjectsDeleteAll(0,"LINES _BUY");
   if(SLb)
     {
      price=MathMin(Bid,Low[1])-levelClose*Point;
      if(ObjectFind("LINES BUY SL")==-1)
         TrendCreate(0,"LINES BUY SL",0,Time[10],price,Time[0],price+Point,clorClose,STYLE_SOLID,2);
      TrendCreate(0,"LINES BUY HEDGE",0,Time[10],price+Point+(DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)),Time[0],price+Point,clorClose,STYLE_SOLID,2);
     }
   else
      ObjectsDeleteAll(0,"LINES BUY SL");
   if(TPb)
     {
      price=MathMax(Ask,High[1])+levelClose*Point;
      if(ObjectFind("LINES BUY TP")==-1)
         TrendCreate(0,"LINES BUY TP",0,Time[10],price,Time[0],price+Point,clorClose,STYLE_SOLID,2);
     }
   else
      ObjectsDeleteAll(0,"LINES BUY TP");

//---

   if(SELL)
     {
      if(ObjectFind("LINES _SELL")==-1)
        {
         price=MathMin(Bid,Low[1])-levelOpen*Point;
         TrendCreate(0,"LINES _SELL",0,Time[10],price,Time[0],price,colorSell,STYLE_SOLID,3);
        }
     }
   else
      ObjectsDeleteAll(0,"LINES _SELL");
   if(SLs)
     {
      price=MathMax(Ask,High[1])+levelClose*Point;
      if(ObjectFind("LINES SELL SL")==-1)
         TrendCreate(0,"LINES SELL SL",0,Time[10],price,Time[0],price-Point,clorClose,STYLE_SOLID,2);
     }
   else
      ObjectsDeleteAll(0,"LINES SELL SL");
   if(TPs)
     {
      price=MathMin(Bid,Low[1])-levelClose*Point;
      if(ObjectFind("LINES SELL TP")==-1)
         TrendCreate(0,"LINES SELL TP",0,Time[10],price,Time[0],price-Point,clorClose,STYLE_SOLID,2);
     }
   else
      ObjectsDeleteAll(0,"LINES SELL TP");

//---

   int order = checkapp();
   if(order==0)
      CLOSEORDER();
   if(order== 1 && b<MaxOrdersCandl)
     {
      if(OrderSend(Symbol(),OP_BUY, Lot,Ask,50,0,0,"LINES BUY",Magic,0,clrBlue)!=-1)
         ObjectSetInteger(0,"LINES Buy",OBJPROP_STATE,false);
      Sleep(2000);
     }
   if(order==-1 && s<MaxOrdersCandl)
     {
      if(OrderSend(Symbol(),OP_SELL,Lot,Bid,50,0,0,"LINES SELL",Magic,0,clrRed)!=-1)
         ObjectSetInteger(0,"LINES Sell",OBJPROP_STATE,false);
      Sleep(2000);
     }
  }
//-------------------------------------------------------------------------
void CLOSEORDER()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         //   if (OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
         if(OrderSymbol()==Symbol() && (MagicALL==-1 || Magic==OrderMagicNumber()))
           {
            if(OrderType()==OP_BUY)
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,30,CLR_NONE))
                  Print("Error close buy");
            if(OrderType()==OP_SELL)
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,30,CLR_NONE))
                  Print("Error close sell");
           }
        }
     }
  }
//-------------------------------------------------------------------------
bool TrendCreate(const long            chart_ID=0,        // ID графика
                 const string          name="TrendLine",  // имя линии
                 const int             sub_window=0,      // номер подокна
                 datetime              time1=0,           // время первой точки
                 double                price1=0,          // цена первой точки
                 datetime              time2=0,           // время второй точки
                 double                price2=0,          // цена второй точки
                 const color           clr=clrRed,        // цвет линии
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии
                 const int             width=1,           // толщина линии
                 const bool            back=false,        // на заднем плане
                 const bool            selection=true,    // выделить для перемещений
                 const bool            ray_right=false,   // продолжение линии вправо
                 const bool            hidden=true,       // скрыт в списке объектов
                 const long            z_order=0)         // приоритет на нажатие мышью
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать линию тренда! Код ошибки = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
int checkapp()
  {
   datetime X_1;
   double Y_1,Y_2,PriceLine;
   double shift_Y = (WindowPriceMax()-WindowPriceMin()) / 50;
   color col;
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Name=ObjectName(n);
      if(ObjectType(Name)!=OBJ_TREND)
         continue;
      if(StringFind(Name,"LINES ",0)!=-1)
        {
         X_1 = (datetime)ObjectGetInteger(0,Name, OBJPROP_TIME1);
         //X_2 = (datetime)ObjectGetInteger(0,Name, OBJPROP_TIME2);
         ObjectDelete(Name+" n");
         //if (X_1>X_2 ||  X_2<Time[0]) {continue;}
         Y_1 = ObjectGet(Name, OBJPROP_PRICE1);
         Y_2 = ObjectGet(Name, OBJPROP_PRICE2);
         col = (color)ObjectGetInteger(0,Name, OBJPROP_COLOR);
         ObjectCreate(Name+" n", OBJ_TEXT,0,X_1-Period()*60,Y_1+shift_Y,0,0,0,0);
         ObjectSetText(Name+" n",StringSubstr(Name,6),7,"Arial");
         ObjectSet(Name+" n", OBJPROP_COLOR, col);
         //if (X_1<=Time[0] && X_2>=Time[0])//попадает во временной диапазон
         //{
         PriceLine=ObjectGetValueByShift(Name,0);
         if(PriceLine==0)
            continue;
         if(intersection_touch)
           {
            if(PriceLine>=Low[1] && PriceLine<=High[1])
              {
               //if (StringFind(Name,"LINES CLOSE",0)!=-1) return(0);
               Comment(Name);
               if(Name=="LINES _BUY")
                  return(1);
               if(Name=="LINES _SELL")
                  return(-1);

              }
           }
         else
           {
            if(Ask>=PriceLine && Name=="LINES _BUY")
               return(1);
            if(Bid<=PriceLine && Name=="LINES _SELL")
               return(-1);
           }
         //}
        }
     }
   return(100);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const long               x=0,                      // координата по оси X
                  const long               y=0,                      // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=8,// размер шрифта
                  const color             clr=clrBlack,// цвет текста
                  const color             clrON=clrLightGray,// цвет фона
                  const color             clrOFF=clrLightGray,// цвет фона
                  const color             border_clr=clrNONE,// цвет границы
                  const bool              state=false,       //
                  const ENUM_BASE_CORNER  CORNER=CORNER_RIGHT_UPPER)
  {
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   color back_clr;
   if(ObjectGetInteger(chart_ID,name,OBJPROP_STATE))
      back_clr=clrON;
   else
      back_clr=clrOFF;
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }


//-------------------------------------------------------------------------------------------
bool ButtonCreate1(const long              chart_ID=0,               // ID графика
                   const string            name="Button",            // имя кнопки
                   const int               sub_window=0,             // номер подокна
                   const long               x=0,                     // координата по оси X
                   const long               y=0,                     // координата по оси y
                   const int               width=50,                 // ширина кнопки
                   const int               height=18,                // высота кнопки
                   const string            text="Button",            // текст
                   const string            font="Arial",             // шрифт
                   const int               font_size=10,             // размер шрифта
                   const color             clr=clrBlack,
                   const color             back_clr=clrLightGray,
                   const bool              state=false)              // нажата/отжата
  {
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrNONE);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//--------------------------------------------------------------------
bool RectLabelCreate(const long             chart_ID=0,               // ID графика
                     const string           name="RectLabel",         // имя метки
                     const int              sub_window=0,             // номер подокна
                     const long              x=0,                     // координата по оси X
                     const long              y=0,                     // координата по оси y
                     const int              width=50,                 // ширина
                     const int              height=18,                // высота
                     const color            back_clr=clrNONE,         // цвет фона
                     const color            clr=clrNONE,              //цвет плоской границы (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы
                     const int              line_width=1,             // толщина плоской границы
                     const bool             back=false,               // на заднем плане
                     const bool             selection=false,          // выделить для перемещений
                     const bool             hidden=true,              // скрыт в списке объектов
                     const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//--------------------------------------------------------------------
bool LabelCreate(const long              chart_ID=0,               // ID графика
                 const string            name="Label",             // имя метки
                 const int               sub_window=0,             // номер подокна
                 const long              x=0,                      // координата по оси X
                 const long              y=0,                      // координата по оси y
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                 const string            text="Label",             // текст
                 const string            font="Arial",             // шрифт
                 const int               font_size=10,             // размер шрифта
                 const color             clr=clrNONE,
                 const double            angle=0.0,                // наклон текста
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки
                 const bool              back=false,               // на заднем плане
                 const bool              selection=false,          // выделить для перемещений
                 const bool              hidden=true,              // скрыт в списке объектов
                 const long              z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,": не удалось создать текстовую метку! Код ошибки = ",GetLastError());
         return(false);
        }
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   return(true);
  }
//--------------------------------------------------------------------
bool EditCreate(const long             chart_ID=0,               // ID графика
                const string           name="Edit",              // имя объекта
                const int              sub_window=0,             // номер подокна
                const long              x=0,                      // координата по оси X
                const long              y=0,                      // координата по оси Y
                const int              width=50,                 // ширина
                const int              height=18,                // высота
                const string           text="Text",              // текст
                const string           font="Arial",             // шрифт
                const int              font_size=8,             // размер шрифта
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // способ выравнивания
                const bool             read_only=true,// возможность редактировать
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER,// угол графика для привязки
                const color            clr=clrBlack,             // цвет текста
                const color            back_clr=clrWhite,        // цвет фона
                const color            border_clr=clrNONE,       // цвет границы
                const bool             back=false,               // на заднем плане
                const bool             selection=false,          // выделить для перемещений
                const bool             hidden=true,              // скрыт в списке объектов
                const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)!=-1)
      ObjectDelete(chart_ID,name);
//{
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//}
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//+------------------------------------------------------------------+

/////======================================================
//--------------------------------------------------------------------
color Color(double P)
  {
   if(P>0)
      return(clrGreen);
   if(P<0)
      return(clrRed);
   return(clrGray);
  }
//------------------------------------------------------------------
void DrawLABEL(string name,string Name,int X,int Y,color clr,ENUM_ANCHOR_POINT align=ANCHOR_RIGHT,int CORNER=1)
  {
   if(ObjectFind(name)==-1)
     {
      ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_CORNER,CORNER);
      ObjectSet(name,OBJPROP_XDISTANCE,X);
      ObjectSet(name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,align);
     }
   ObjectSetText(name,Name,8,"Arial",clr);
  }
//--------------------------------------------------------------------
void DrawHLINE(string name,double p,color clr=clrGray)
  {
   if(ObjectFind(name)!=-1)
      ObjectDelete(name);
   ObjectCreate(name,OBJ_HLINE,0,0,p);
   ObjectSetInteger(0,name,OBJPROP_STYLE,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
//--------------------------------------------------------------------
/*void OnDeinit(const int reason)
  {
   if(!IsTesting())
     {
      ObjectsDeleteAll(0,"cm");
     }
   Comment("");
   EventKillTimer();
  }*/
//+------------------------------------------------------------------+
bool CloseByOrders()
  {
   bool error=true;
   int b=0,s=0,TicketApponent=0,Ticket,OT,j,LaslApp=-1;
   while(!IsStopped())
     {
      for(j=OrdersTotal()-1; j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS))
           {
            if(OrderSymbol()==Symbol() && (MagicALL==-1 || Magic==OrderMagicNumber()))
              {
               OT=OrderType();
               Ticket=OrderTicket();
               if(OT>1)
                 {
                  error=OrderDelete(Ticket);
                  continue;
                 }
               if(TicketApponent==0)
                 {
                  TicketApponent=Ticket;
                  LaslApp=OT;
                 }
               else
                 {
                  if(LaslApp==OT)
                     continue;
                  if(OrderCloseBy(Ticket,TicketApponent,Green))
                     TicketApponent=0;
                  else
                     Print("Ошибка ",GetLastError()," закрытия ордера N ",Ticket," <-> ",TicketApponent);
                 }
              }
           }
        }
      b=0;
      s=0;
      for(j=OrdersTotal()-1; j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && (Magic==-1 || Magic==OrderMagicNumber()))
              {
               OT=OrderType();
               if(OT==OP_BUY)
                  b++;
               if(OT==OP_SELL)
                  s++;
              }
           }
        }
      if(b==0 || s==0)
         break;
     }
   CloseAll(-1);
   return(1);
  }
//-------------------------------------------------------------------
bool CloseAll(int tip)
  {
   bool error=true;
   int j,err,nn=0,OT;
   while(true)
     {
      for(j=OrdersTotal()-1; j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS))
           {
            if(OrderSymbol()==Symbol() && (Magic==-1 || Magic==OrderMagicNumber()))
              {
               OT=OrderType();
               if(tip!=-1 && tip!=OT)
                  continue;
               if(OT==OP_BUY)
                 {
                  error=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,Blue);
                 }
               if(OT==OP_SELL)
                 {
                  error=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,Red);
                 }
               if(!error)
                 {
                  err=GetLastError();
                  if(err<2)
                     continue;
                  if(err==129)
                    {
                     RefreshRates();
                     continue;
                    }
                  if(err==146)
                    {
                     if(IsTradeContextBusy())
                        Sleep(2000);
                     continue;
                    }
                  Print("Ошибка ",err," закрытия ордера N ",OrderTicket(),"     ",TimeToStr(TimeCurrent(),TIME_SECONDS));
                 }
              }
           }
        }
      int n=0;
      for(j= 0; j<OrdersTotal(); j++)
        {
         if(OrderSelect(j,SELECT_BY_POS))
           {
            if(OrderSymbol()==Symbol() && (MagicALL==-1 || Magic==OrderMagicNumber()))
              {
               OT=OrderType();
               if(OT>1)
                 {
                  int Ticket=OrderTicket();
                  if(tip==-1)
                     error=OrderDelete(Ticket);
                  else
                    {
                     if(tip==OP_BUY && (OT==OP_BUYLIMIT || OT==OP_BUYSTOP))
                        error=OrderDelete(Ticket);
                     if(tip==OP_SELL && (OT==OP_SELLLIMIT || OT==OP_SELLSTOP))
                        error=OrderDelete(Ticket);
                    }
                  continue;
                 }
               if(tip!=-1 && tip!=OT)
                  continue;
               n++;
              }
           }
        }
      if(n==0)
         break;
      nn++;
      if(nn>10)
        {
         Alert(Symbol()," Не удалось закрыть все сделки, осталось еще ",n);
         return(0);
        }
      Sleep(1000);
      RefreshRates();
     }
   return(1);
  }

string Error2(int code)
  {
   switch(code)
     {
      case 0:
         return("Нет ошибок");
      case 1:
         return("Нет ошибки, но результат неизвестен");
      case 2:
         return("Общая ошибка");
      case 3:
         return("Неправильные параметры");
      case 4:
         return("Торговый сервер занят");
      case 5:
         return("Старая версия клиентского терминала");
      case 6:
         return("Нет связи с торговым сервером");
      case 7:
         return("Недостаточно прав");
      case 8:
         return("Слишком частые запросы");
      case 9:
         return("Недопустимая операция нарушающая функционирование сервера");
      case 64:
         return("Счет заблокирован");
      case 65:
         return("Неправильный номер счета");
      case 128:
         return("Истек срок ожидания совершения сделки");
      case 129:
         return("Неправильная цена");
      case 130:
         return("Неправильные стопы");
      case 131:
         return("Неправильный объем");
      case 132:
         return("Рынок закрыт");
      case 133:
         return("Торговля запрещена");
      case 134:
         return("Недостаточно денег для совершения операции");
      case 135:
         return("Цена изменилась");
      case 136:
         return("Нет цен");
      case 137:
         return("Брокер занят");
      case 138:
         return("Новые цены");
      case 139:
         return("Ордер заблокирован и уже обрабатывается");
      case 140:
         return("Разрешена только покупка");
      case 141:
         return("Слишком много запросов");
      case 145:
         return("Модификация запрещена, так как ордер слишком близок к рынку");
      case 146:
         return("Подсистема торговли занята");
      case 147:
         return("Использование даты истечения ордера запрещено брокером");
      case 148:
         return("Количество открытых и отложенных ордеров достигло предела, установленного брокером.");
      default:
         return(StringConcatenate("Ошибка ",code," неизвестна "));
     }
  }
//--------------------------------------------------------------------
bool EditCreate7(const long             chart_ID=0,               // ID графика
                 const string           name="Edit",              // имя объекта
                 const int              sub_window=0,             // номер подокна
                 const int              x=0,                      // координата по оси X
                 const int              y=0,                      // координата по оси Y
                 const int              width=50,                 // ширина
                 const int              height=18,                // высота
                 const string           text="Text",              // текст
                 const string           font="Arial",             // шрифт
                 const int              font_size=8,             // размер шрифта
                 const ENUM_ALIGN_MODE  align=ALIGN_RIGHT,       // способ выравнивания
                 const bool             read_only=true,// возможность редактировать
                 const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER,// угол графика для привязки
                 const color            clr=clrBlack,             // цвет текста
                 const color            back_clr=clrWhite,        // цвет фона
                 const color            border_clr=clrNONE,       // цвет границы
                 const bool             back=false,               // на заднем плане
                 const bool             selection=false,          // выделить для перемещений
                 const bool             hidden=true,              // скрыт в списке объектов
                 const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": не удалось создать объект ",name,"! Код ошибки = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
string Text(bool P,string a,string b)
  {
   if(P)
      return(a);
   else
      return(b);
  }
//------------------------------------------------------------------
void drawtext(string Name,datetime T1,double Y1,string lt,color c)
  {
   ObjectDelete(Name);
   ObjectCreate(Name,OBJ_TEXT,0,T1,Y1,0,0,0,0);
   ObjectSetText(Name,lt,8,"Arial");
   ObjectSetInteger(0,Name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,Name,OBJPROP_ANCHOR,ANCHOR_LOWER);
  }
//--------------------------------------------------------------------


//--------------------------------------------------------------------
bool LabelCreate2(const long              chart_ID=0,                // ID графика
                  const string            name="Label",             // имя метки
                  const int               sub_window=0,             // номер подокна
                  const long              x=0,                      // координата по оси X
                  const long              y=0,                      // координата по оси y
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                  const string            text="Label",             // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrNONE,
                  const double            angle=0.0,                // наклон текста
                  const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки
                  const bool              back=false,               // на заднем плане
                  const bool              selection=false,          // выделить для перемещений
                  const bool              hidden=true,              // скрыт в списке объектов
                  const long              z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,": не удалось создать текстовую метку! Код ошибки = ",GetLastError());
         return(false);
        }
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,fontsizeEQ);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   return(true);
  }
//--------------------------------------------------------------------

//+------------------------------------------------------------------+
//| CurrencyFormat                                                   |
//+------------------------------------------------------------------+
string CurrencyFormat(const double Number=0,
                      const string IsoCurrency="EUR",
                      const bool   CurrencyPosition=true)
  {
   string CurFormat;
   if(IsoCurrency=="ALL")
     {
      CurFormat="\x4c"+"\x65"+"\x6b";
     }
   if(IsoCurrency == "AFN")
     {
      CurFormat ="\x60b";
      CurFormat ="AFN";
     }
   if(IsoCurrency == "ARS")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "AWG")
     {
      CurFormat ="\x192";
     }
   if(IsoCurrency == "AUD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "AZN")
     {
      CurFormat ="\x43c"+"\x430"+"\x43d";
      CurFormat ="AZN";
     }
   if(IsoCurrency == "BSD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "BBD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "BYR")
     {
      CurFormat ="\x70"+"\x2e";
     }
   if(IsoCurrency == "BZD")
     {
      CurFormat ="\x42"+"\x5a"+"\x24";
     }
   if(IsoCurrency == "BMD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "BOB")
     {
      CurFormat ="\x24"+"\x62";
     }
   if(IsoCurrency == "BAM")
     {
      CurFormat ="\x4b"+"\x4d";
     }
   if(IsoCurrency == "BWP")
     {
      CurFormat ="\x50";
     }
   if(IsoCurrency == "BGN")
     {
      CurFormat ="\x43b"+"\x432";
      CurFormat ="BGN";
     }
   if(IsoCurrency == "BRL")
     {
      CurFormat ="\x52"+"\x24";
     }
   if(IsoCurrency == "BND")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "KHR")
     {
      CurFormat ="\x17db";
      CurFormat ="KHR";
     }
   if(IsoCurrency == "CAD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "KYD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "CLP")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "CNY")
     {
      CurFormat ="\xa5";
     }
   if(IsoCurrency == "COP")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "CRC")
     {
      CurFormat ="\x20a1";
     }
   if(IsoCurrency == "HRK")
     {
      CurFormat ="\x6b"+"\x6e";
     }
   if(IsoCurrency == "CUP")
     {
      CurFormat ="\x20b1";
      CurFormat ="CUP";
     }
   if(IsoCurrency == "CZK")
     {
      CurFormat ="\x4b"+"\x10d";
     }
   if(IsoCurrency == "DKK")
     {
      CurFormat ="\x6b"+"\x72";
     }
   if(IsoCurrency == "DOP")
     {
      CurFormat ="\x52"+"\x44"+"\x24";
     }
   if(IsoCurrency == "XCD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "EGP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "SVC")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "EEK")
     {
      CurFormat ="\x6b"+"\x72";
     }
   if(IsoCurrency == "EUR")
     {
      CurFormat ="\x20ac";
     }
   if(IsoCurrency == "FKP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "FJD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "GHC")
     {
      CurFormat ="\xa2";
     }
   if(IsoCurrency == "GIP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "GTQ")
     {
      CurFormat ="\x51";
     }
   if(IsoCurrency == "GGP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "GYD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "HNL")
     {
      CurFormat ="\x4c";
     }
   if(IsoCurrency == "HKD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "HUF")
     {
      CurFormat ="\x46"+"\x74";
     }
   if(IsoCurrency == "ISK")
     {
      CurFormat ="\x6b"+"\x72";
     }
   if(IsoCurrency == "INR")
     {
      CurFormat ="\x20B9";
      CurFormat ="INR";
     }
   if(IsoCurrency == "IDR")
     {
      CurFormat ="\x52"+"\x70";
     }
   if(IsoCurrency == "IRR")
     {
      CurFormat ="\xfdfc";
     }
   if(IsoCurrency == "IMP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "ILS")
     {
      CurFormat ="\x20aa";
      CurFormat ="ILS";
     }
   if(IsoCurrency == "JMD")
     {
      CurFormat ="\x4a"+"\x24";
     }
   if(IsoCurrency == "JPY")
     {
      CurFormat ="\xa5";
     }
   if(IsoCurrency == "JEP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "KZT")
     {
      CurFormat ="\x43b"+"\x432";
      CurFormat ="KZT";
     }
   if(IsoCurrency == "KPW")
     {
      CurFormat ="\x20a9";
      CurFormat ="KPW";
     }
   if(IsoCurrency == "KRW")
     {
      CurFormat ="\x20a9";
      CurFormat ="KRW";
     }
   if(IsoCurrency == "KGS")
     {
      CurFormat ="\x43b"+"\x432";
      CurFormat ="KGS";
     }
   if(IsoCurrency == "LAK")
     {
      CurFormat ="\x20ad";
      CurFormat ="LAK";
     }
   if(IsoCurrency == "LVL")
     {
      CurFormat ="\x4c"+"\x73";
     }
   if(IsoCurrency == "LBP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "LRD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "LTL")
     {
      CurFormat ="\x4c"+"\x74";
     }
   if(IsoCurrency == "MKD")
     {
      CurFormat ="\x434"+"\x435"+"\x43d";
      CurFormat ="MKD";
     }
   if(IsoCurrency == "MYR")
     {
      CurFormat ="\x52"+"\x4d";
     }
   if(IsoCurrency == "MUR")
     {
      CurFormat ="\x20a8";
     }
   if(IsoCurrency == "MXN")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "MNT")
     {
      CurFormat ="\x20ae";
      CurFormat ="MNT";
     }
   if(IsoCurrency == "MZN")
     {
      CurFormat ="\x4d"+"\x54";
     }
   if(IsoCurrency == "NAD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "NPR")
     {
      CurFormat ="\x20a8";
      CurFormat ="NPR";
     }
   if(IsoCurrency == "ANG")
     {
      CurFormat ="\x192";
     }
   if(IsoCurrency == "NZD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "NIO")
     {
      CurFormat ="\x43"+"\x24";
     }
   if(IsoCurrency == "NGN")
     {
      CurFormat ="\x20a6";
      CurFormat ="NGN";
     }
   if(IsoCurrency == "NOK")
     {
      CurFormat ="\x6b"+"\x72";
     }
   if(IsoCurrency == "OMR")
     {
      CurFormat ="\xfdfc";
      CurFormat ="OMR";
     }
   if(IsoCurrency == "PKR")
     {
      CurFormat ="\x20a8";
      CurFormat ="PKR";
     }
   if(IsoCurrency == "PAB")
     {
      CurFormat ="\x42"+"\x2f"+"\x2e";
     }
   if(IsoCurrency == "PYG")
     {
      CurFormat ="\x47"+"\x73";
     }
   if(IsoCurrency == "PEN")
     {
      CurFormat ="\x53"+"\x2f"+"\x2e";
     }
   if(IsoCurrency == "PHP")
     {
      CurFormat ="\x20b1";
      CurFormat ="PHP";
     }
   if(IsoCurrency == "PLN")
     {
      CurFormat ="\x7a"+"\x142";
     }
   if(IsoCurrency == "QAR")
     {
      CurFormat ="\xfdfc";
      CurFormat ="QAR";
     }
   if(IsoCurrency == "RON")
     {
      CurFormat ="\x6c"+"\x65"+"\x69";
     }
   if(IsoCurrency == "RUB")
     {
      CurFormat ="\x440"+"\x443"+"\x431";
      CurFormat ="RUB";
     }
   if(IsoCurrency == "SHP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "SAR")
     {
      CurFormat ="\xfdfc";
      CurFormat ="SAR";
     }
   if(IsoCurrency == "RSD")
     {
      CurFormat ="\x414"+"\x438"+"\x43d"+"\x2e";
      CurFormat ="RSD";
     }
   if(IsoCurrency == "SCR")
     {
      CurFormat ="\x20a8";
      CurFormat ="SCR";
     }
   if(IsoCurrency == "SGD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "SBD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "SOS")
     {
      CurFormat ="\x53";
     }
   if(IsoCurrency == "ZAR")
     {
      CurFormat ="\x52";
     }
   if(IsoCurrency == "LKR")
     {
      CurFormat ="\x20a8";
      CurFormat ="LKR";
     }
   if(IsoCurrency == "SEK")
     {
      CurFormat ="\x6b"+"\x72";
     }
   if(IsoCurrency == "CHF")
     {
      CurFormat ="\x43"+"\x48"+"\x46";
     }
   if(IsoCurrency == "SRD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "SYP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "TWD")
     {
      CurFormat ="\x4e"+"\x54"+"\x24";
     }
   if(IsoCurrency == "THB")
     {
      CurFormat ="\xe3f";
      CurFormat ="THB";
     }
   if(IsoCurrency == "TTD")
     {
      CurFormat ="\x54"+"\x54"+"\x24";
     }
   if(IsoCurrency == "TRL")
     {
      CurFormat ="\x20a4";
     }
   if(IsoCurrency == "TVD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "UAH")
     {
      CurFormat ="\x20b4";
      CurFormat ="UAH";
     }
   if(IsoCurrency == "GBP")
     {
      CurFormat ="\xa3";
     }
   if(IsoCurrency == "USD")
     {
      CurFormat ="\x24";
     }
   if(IsoCurrency == "UYU")
     {
      CurFormat ="\x24"+"\x55";
     }
   if(IsoCurrency == "UZS")
     {
      CurFormat ="\x43b"+"\x432";
      CurFormat ="UZS";
     }
   if(IsoCurrency == "VEF")
     {
      CurFormat ="\x42"+"\x73";
     }
   if(IsoCurrency == "VND")
     {
      CurFormat ="\x20ab";
      CurFormat ="VND";
     }
   if(IsoCurrency == "YER")
     {
      CurFormat ="\xfdfc";
      CurFormat ="YER";
     }
   if(IsoCurrency == "ZWD")
     {
      CurFormat ="\x5a"+"\x24";
     }
   if(CurrencyPosition)
     {
      CurFormat=DoubleToStr(Number,2)+CurFormat;
     }
   else
     {
      CurFormat=CurFormat+DoubleToStr(Number,2);
     }
   return CurFormat;
  }


//+------------------------------------------------------------------+
//| HLineCreate                                                      |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID
                 const string          name="HLine_max",// line name
                 const int             sub_window=0,// subwindow index
                 double                hprice=0,// line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0,         // priority for mouse click
                 const string          tooltip="")
  {

/// if(ObjectFind(0,name)!=-1)
   ObjectDelete(chart_ID,name);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,hprice))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| HLineMove                                                        |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,// chart's ID
               const string name="HLine",// line name
               double       pricel=0) // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!pricel)
      pricel=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,pricel))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int checkappRexi()
  {
   datetime X_1;
   double Y_1,Y_2,PriceLine;
   double shift_Y = (WindowPriceMax()-WindowPriceMin()) / 50;
   color col;
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Name=ObjectName(n);
      if(ObjectType(Name)!=OBJ_TREND)
         continue;
      if(StringFind(Name,StringConcatenate("HH",tik),0)!=-1)
        {
         X_1 = (datetime)ObjectGetInteger(0,Name, OBJPROP_TIME1);
         //X_2 = (datetime)ObjectGetInteger(0,Name, OBJPROP_TIME2);
         ObjectDelete(Name+" n");
         //if (X_1>X_2 ||  X_2<Time[0]) {continue;}
         Y_1 = ObjectGet(Name, OBJPROP_PRICE1);
         Y_2 = ObjectGet(Name, OBJPROP_PRICE2);
         col = (color)ObjectGetInteger(0,Name, OBJPROP_COLOR);
         ObjectCreate(Name+" n", OBJ_TEXT,0,X_1-Period()*600,Y_1+shift_Y,0,0,0,0);
         ObjectSetText(Name+" n",StringSubstr(Name,0),7,"Arial");
         ObjectSet(Name+" n", OBJPROP_COLOR, col);
         //if (X_1<=Time[0] && X_2>=Time[0])//попадает во временной диапазон
         //{
         PriceLine=ObjectGetValueByShift(Name,0);
         if(PriceLine==0)
            continue;
         if(intersection_touch)
           {
            if(PriceLine>=Low[1] && PriceLine<=High[1])
              {
               //if (StringFind(Name,"LINES CLOSE",0)!=-1) return(0);
               Comment(Name);
               if(Name==StringConcatenate("HH",tik))
                  return(1);
               if(Name==StringConcatenate("HH",tik))
                  return(-1);

              }
           }
         else
           {
            if((Ask>=PriceLine) && (ttyp ==1 ||  ttyp ==3 ||  ttyp ==5))
               return (1); // && Name==StringConcatenate("HH",tik)
            if((Bid<=PriceLine) && (ttyp ==0 ||  ttyp ==2 ||  ttyp ==4))
               return (0);   //&& Name==StringConcatenate("HH",tik)
           }
         //}
        }
     }
   return(100);
  }





//| Move the anchor point                                            |
//+------------------------------------------------------------------+
bool TextMove(const long   chart_ID=0,  // chart's ID
              const string name="Text", // object name
              datetime     time=0,      // anchor point time coordinate
              double       price=0)     // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool TextChange(const long   chart_ID=0,  // chart's ID
                const string name="Text", // object name
                const string text="Text") // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete Text object                                               |
//+------------------------------------------------------------------+
bool TextDelete(const long   chart_ID=0,  // chart's ID
                const string name="Text") // object name
  {
//--- reset the error value
   ResetLastError();
//--- delete the object
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }

/**
* MT4/experts/scripts/one_tick.mq4
* send exactly one fake tick to the chart and
* all its indicators and EA and then exit.
*/

//+------------------------------------------------------------------+
//|                                Copyright 2014, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+

//#define  NLL    "\n"
//  #include <mt4gui2.mqh>  ///// infooooo


//extern double    Vsuma2     = 5400 ;           //  virtualna suma2
////extern  bool notification    = false ;  //// notification 2
//extern  int    Magic = 0;   ///  MAGIC   calculate


input color    Color99     = clrMagenta;           // цвет 750l  loss
input color    Color88     = clrWhite;           // цвет 750p  profit
input color    Color77     = clrLime;           // цвет average point  profit


double  VVsuma=0, Psuma =0, Csuma=0;;
double сегодня=0,вчера=0,неделя=0,месяц=0;

double pOOP ;
double    pSTOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
double stoplevel=STOPLEVEL*Point;
//  int b=0,s=0,pbs=0,pss=0,bl=0,psl=0,tip;
//   double OL=0,LB=0,LS=0,ProfitB=0,ProfitS=0 ;
//  double price_b=0,price_s=0;


double dLB=0,dLS=0,dProfitB=0,dProfitS=0, LNL=0,difflot=0, diffL =0,  diffb =0, diffs=0 ;
double dprice_b=0,dprice_s=0;

double  pLot=0,  pLB=0, pLS=0, TLOT=0,PriceBuyStop=0,PriceSellStop=0;

int b=0,s=0,pbs=0,pss=0,bl=0,psl=0;
double OL=0,LB=0,LS=0;
double ProfitB=0, ProfitS=0 ;
double price_b=0,price_s=0;
double Profit =0;

// double ProfitB=0,ProfitS=0 ;
int tip ;
int Ticket;
string NameLine;
datetime OOT;
//  bool WiewOrdersLine=ObjectGetInteger(0,"cm__kn Orders Line",OBJPROP_STATE);




double    Vsumap        = 10 ;           //  virtualna suma

//string Font        = "Times New Roman"; // Шрифт
//int    Width       = 12;                // размер
long   pX=300;
long   pY=50;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string InpName="*" ; //DoubleToStr(Vsuma2,2)+" Info";
//double STOPLEVEL;
string AC;

double  днес, Today  ;
int i = 0,  totalHistoryorder =0 ;
datetime OCT;
double  totorders =0;




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  dnes()
  {


   if(totalHistoryorder != OrdersHistoryTotal())
     {
      днес=0;
      Today=0 ;
      i=0;

      calcC();

      Today = сегодня ;
      днес  = сегодня ;

      /*
      for (i=OrdersHistoryTotal()-1; i>=0; i--)
        {


          if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
           {
              OCT = OrderCloseTime();
              Today  = OrderProfit()+OrderSwap()+OrderCommission();
               if (OCT>=iTime(NULL,1440,0)) днес+=Today ;
               totalHistoryorder = OrdersHistoryTotal() ;
               }


         }*/
     }

  }



/*

 void OnTick()
{

   if ((  totorders != OrdersTotal() ) || ( totorders ==0) )
   {
   dnes();
   totorders = OrdersTotal() ;
   Redraw();
  // Vsuma2 = ProfitB+ProfitS+ сегодня ;
   }
}
*/

//+------------------------------------------------------------------+
int OnInit777()
  {
   AC=" "+AccountCurrency();
   return(INIT_SUCCEEDED);

// dnes();

  }
//+------------------------------------------------------------------+
void OnDeinit123(const int reason)
  {
   Del();
  }
//--------------------------------------------------------------------
void Del()
  {
   ObjectDelete(0,InpName);

   ObjectDelete(0,"cm__+750p");
   ObjectDelete(0,"cm__-750l");
   ObjectDelete(0,"cm__fon1_");
   ObjectDelete(0,"cm__Csuma");
   ObjectDelete(0,"cm__kn Orders Line");
   ObjectDelete(0,"cm__kn History");
   ObjectDelete(0,"cm__kn MarketInfo");
   ObjectDelete(0,"cm__kn NL");
   ObjectDelete(0,"cm__NoLoss_NLb");
   ObjectDelete(0,"cm__NoLoss_NLs");
   ObjectDelete(0,"cm__NoLoss_NL");

   ObjectDelete(0,"cm__kn ProfitB");
   ObjectDelete(0,"cm__kn ProfitS");
   ObjectDelete(0,"cm__kn Profit");

   ObjectDelete(0,"cm__kn price_b");
   ObjectDelete(0,"cm__kn price_s");
   ObjectDelete(0,"price_b");
   ObjectDelete(0,"price_s");
   ObjectDelete(0,"cm__kn TLOT");
   ObjectDelete(0,"cm__kn Tprof");
// ObjectDelete(0,"cm__kn Orders Line");

   ObjectDelete(0,"cm__Vsuma");

   ObjectDelete(0,"cm__Buy");
   ObjectDelete(0,"cm__Sell");
   ObjectDelete(0,"cm__BL");
   ObjectDelete(0,"cm__SL");
   ObjectDelete(0,"cm__00_");
   ObjectDelete(0,"cm__0_");
   ObjectDelete(0,"cm__1_");
   ObjectDelete(0,"cm__2_");
   ObjectDelete(0,"cm__3_");
   ObjectDelete(0,"cm__4_");
   ObjectDelete(0,"cm__5_");
   ObjectDelete(0,"cm__6_");
   ObjectDelete(0,"cm__60_");
// ObjectsDeleteAll(0,OBJ_TREND);
   ObjectDelete(0,"cm__ сегодня");
   ObjectDelete(0,"cm__ днес");
   ObjectDelete(0,"cm__ вчера");
   ObjectDelete(0,"cm__ неделя");
   ObjectDelete(0,"cm__ месяц");
   ObjectDelete(0,"cm__ сегодн1");
   ObjectDelete(0,"cm__ сегодн2");
   ObjectDelete(0,"cm__ сегодн3");
   ObjectDelete(0,"cm__ сегодн4");
   ObjectDelete(0,"cm__ сегодн5");
   ObjectDelete(0,"cm__ сегодн6");
   ObjectDelete(0,"cm__ сегодн7");
   ObjectDelete(0,"cm__ сегодн8");
   ObjectDelete(0,"cm__+750p");
   ObjectDelete(0,"cm__-750l");
   ObjectDelete(0,"cm__NoLoss_LNL");

  }
//--------------------------------------------------------------------
int start()
  {
   сегодня =0 ;
   вчера =0 ;
   неделя =0 ;
   месяц =0 ;
   Vsuma2 =0;
   Redraw();

   return(0);
  }
//--------------------------------------------------------------------

/*
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

//  calcC();

  return(rates_total);
  }*/

//--------------------------------------------------------------------





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Redraw()
  {
// Vsuma2 =0;
//сегодня =0 ;
// Csuma =0 ;
// Redraw44() ;
   if(Vsuma2 ==0)
     {
      dnes();
      calcC() ;

      RefreshRates();
      calcPN(calMG);
      //   Csuma = ProfitB+ProfitS+ сегодня ;
      //   Vsuma2 = ProfitB+ProfitS+ сегодня ;
     }

   Redraw55();
// Vsuma2 = ProfitB+ProfitS+ сегодня ;
// Csuma =0 ;
   Redraw44() ;
// Vsuma2 = ProfitB+ProfitS+ сегодня ;
//if (OCT>=iTime(NULL,1440,0)) Csuma +=сегодня ;
// Vsuma2 = ProfitB+ProfitS+ Csuma ;
/// Redraw55();
   /*
   if (ObjectFind(InpName)==0)
     {
        ObjectGetInteger(0,InpName,OBJPROP_XDISTANCE,0,X);
        ObjectGetInteger(0,InpName,OBJPROP_YDISTANCE,0,Y);
        ObjectDelete(0,InpName);
       InpName=DoubleToStr(Vsuma2,2)+" Info";
     }
     else
     {
        //X=30; Y=30;
     //   InpName=DoubleToStr(Vsuma2,2)+" Info";
        RectLabelCreate(0,InpName,0,X,Y,200,135,Color2,Color1,STYLE_SOLID,3,true,true,true,0);


        ObjectGetInteger(0,InpName,OBJPROP_XDISTANCE,0,X);
        ObjectGetInteger(0,InpName,OBJPROP_YDISTANCE,0,Y);
     }
    // ObjectDelete(0,InpName);*/

///   ObjectGetInteger(0,InpName,OBJPROP_XDISTANCE,0,X);
///   ObjectGetInteger(0,InpName,OBJPROP_YDISTANCE,0,Y);
// InpName=DoubleToStr(Vsuma2,2)+" Info";

   return(0) ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Redraw55()
  {

   if(ObjectFind(InpName)==0)
     {
      ObjectGetInteger(0,InpName,OBJPROP_XDISTANCE,0,X);
      ObjectGetInteger(0,InpName,OBJPROP_YDISTANCE,0,Y);
     }
   else
     {
      //X=30; Y=30;
      // Vsuma2 = ProfitB+ProfitS+ сегодня ;
      // InpName=DoubleToStr(Vsuma2,2)+" Info";
      RectLabelCreate(0,InpName,0,X,Y,200,135,Color2,Color1,STYLE_SOLID,3,true,true,true,0);
      //  ButtonCreate(0,"cm__Csuma"  ,0,X+2  ,Y,190,18 ,StringConcatenate(DoubleToString(Vsuma2,2)," ",Symbol()),Font,Width,Color1,Color8,Color7,false);
     }
// Vsuma2 = ProfitB+ProfitS+ сегодня ;
//  InpName=DoubleToStr(Vsuma2,2)+" Info";
   RectLabelCreate(0,InpName,0,X,Y,200,135,Color2,Color1,STYLE_SOLID,3,true,true,true,0);


   RectLabelCreate(0,"cm__fon1_",0,X+1,Y+1,198,103,Color6,Color7,STYLE_SOLID,1,true,false,true,0);
   LabelCreate(0,"cm__00_",0,X+10,Y+10,CORNER_LEFT_UPPER,InpName,Font,Width+0,Color1,0,ANCHOR_LEFT,false,false,true,0);
////   ButtonCreate(0,"cm__Csuma"  ,0,X+2  ,Y,190,18 ,StringConcatenate(DoubleToString(Vsuma2,2)," ",Symbol()),Font,Width,Color1,Color8,Color7,false);
// LabelCreate(0    ,"cm__00_",0 ,X+10,Y+10,CORNER_LEFT_UPPER,StringConcatenate(InpName," ",Symbol()),Font,Width+0,Color1,0,ANCHOR_LEFT,false,false,true,0);

   ButtonCreate(0,"cm__kn Orders Line",0,X+2,Y+22,88,18,"Orders",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn NL",0,X+2,Y+40,88,18,"NL",Font,Width,Color1,Color8,Color7,false);
//  ButtonCreate(0,"cm__kn Tprof"           ,0,X+2  ,Y+60,188,18 ,"Tprof",Font,Width,Color1,Color8,Color7,false);
// LabelCreate(0    ,"cm__Tprof" ,0 ,X+120,Y+64,CORNER_LEFT_UPPER,StringConcatenate("EQ= ",DoubleToStr(AccountEquity(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);


   ButtonCreate(0,"cm__kn ProfitB",0,X+100,Y+10,95,18,"ProfitB",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn ProfitS",0,X+100,Y+40,95,18,"ProfitS",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn Profit",0,X+200,Y+92,95,18,"Profit",Font,Width,Color1,Color8,Color7,false);

   ButtonCreate(0,"cm__kn price_b",0,X+520,Y+10,88,18,"price_b",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn price_s",0,X+520,Y+40,88,18,"price_s",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn TLOT",0,X+520,Y+92,88,18,"TLOT",Font,Width,Color1,Color8,Color7,false);
/// ButtonCreate(0,"cm__kn pendingS"           ,0,X+500  ,Y+70,148,28 ,"pLS  "+DoubleToStr(pLB,2),Font,30,Color1,Color8,Color7,false);

   RectLabelCreate(0,"cm__0_",0,X+1,Y+1,198,18,Color3,Color7,STYLE_SOLID,1,true,false,true,0);
// LabelCreate(0    ,"cm__00_",0 ,X+10,Y+10,CORNER_LEFT_UPPER,StringConcatenate(InpName," ",Symbol()),Font,Width+0,Color1,0,ANCHOR_LEFT,false,false,true,0);


   LabelCreate(0,"cm__AccEQ",0,X+100,Y+70,CORNER_LEFT_UPPER,StringConcatenate("EQ= ",DoubleToStr(AccountEquity(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__Tprof",0,X+100,Y+90,CORNER_LEFT_UPPER,StringConcatenate("Profit= ",DoubleToStr(AccountProfit(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

   LabelCreate(0,"cm__ днес",0,X+100,Y+110,CORNER_LEFT_UPPER,StringConcatenate("Close = ",DoubleToStr(днес,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

   RefreshRates();

   bool WiewOrdersLine=ObjectGetInteger(0,"cm__kn Orders Line",OBJPROP_STATE);


// }
// Vsuma2 +=  сегодня ;

   RectLabelCreate(0,"cm__1_",0,X+91,Y+22,58,18,Color2,Color7,STYLE_SOLID,1,true,false,true,0);
   RectLabelCreate(0,"cm__2_",0,X+150,Y+22,48,18,Color2,Color7,STYLE_SOLID,1,true,false,true,0);
   LabelCreate(0,"cm__Buy",0,X+120,Y+32,CORNER_LEFT_UPPER,StringConcatenate("Buy ",DoubleToStr(b,0)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__BL",0,X+175,Y+32,CORNER_LEFT_UPPER,DoubleToStr(LB,2),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   RectLabelCreate(0,"cm__3_",0,X+91,Y+42,58,18,Color2,Color7,STYLE_SOLID,1,true,false,true,0);
   RectLabelCreate(0,"cm__4_",0,X+150,Y+42,48,18,Color2,Color7,STYLE_SOLID,1,false,false,true,0);
   LabelCreate(0,"cm__Sell",0,X+120,Y+52,CORNER_LEFT_UPPER,StringConcatenate("Sell ",DoubleToStr(s,0)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__SL",0,X+175,Y+52,CORNER_LEFT_UPPER,DoubleToStr(LS,2),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

   LabelCreate(0,"cm__kn price_b",0,X+520,Y+32,CORNER_LEFT_UPPER,StringConcatenate("pB ",DoubleToStr(pLB,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__kn price_s",0,X+520,Y+52,CORNER_LEFT_UPPER,StringConcatenate("pS ",DoubleToStr(pLS,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__kn ProfitB",0,X+320,Y+32,CORNER_LEFT_UPPER,StringConcatenate("B ",DoubleToStr(ProfitB,2)),Font,Width+0,Color1,0,ANCHOR_RIGHT,false,false,true,0);
   LabelCreate(0,"cm__kn ProfitS",0,X+320,Y+52,CORNER_LEFT_UPPER,StringConcatenate("S ",DoubleToStr(ProfitS,2)),Font,Width+0,Color1,0,ANCHOR_RIGHT,false,false,true,0);
   LabelCreate(0,"cm__kn Profit",0,X+320,Y+92,CORNER_LEFT_UPPER,StringConcatenate("All ",DoubleToStr((ProfitB+ProfitS),2)),Font,Width+0,Color1,0,ANCHOR_RIGHT,false,false,true,0);

   LabelCreate(0,"cm__AccEQ",0,X+100,Y+70,CORNER_LEFT_UPPER,StringConcatenate("EQ= ",DoubleToStr(AccountEquity(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   LabelCreate(0,"cm__Tprof",0,X+100,Y+90,CORNER_LEFT_UPPER,StringConcatenate("Profit= ",DoubleToStr(AccountProfit(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
//  Vsuma2=StringToDouble(ObjectGetString(0,"cm__Vsuma",OBJPROP_TEXT));

//  ObjectCreate(0,"cm__Vsuma",OBJ_TEXT,0,"10");
// EditCreate(0,"cm__Vsuma",0,175,128,50,20,DoubleToString(Vsuma2,0),"Arial",8,ALIGN_CENTER,false);
//Vsuma2=VVsuma ;

   TLOT =LS-LB-pLB+pLS  ;
   if(TLOT > 0)
      LabelCreate(0,"cm__kn TLOT",0,X+520,Y+92,CORNER_LEFT_UPPER,StringConcatenate("Buy ",DoubleToStr(TLOT,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
   if(TLOT < 0)
      LabelCreate(0,"cm__kn TLOT",0,X+520,Y+92,CORNER_LEFT_UPPER,StringConcatenate("Sell ",DoubleToStr(-(TLOT),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
//   if ( TLOT = 0  )  LabelCreate(0    ,"cm__kn TLOT" ,0 ,X+520,Y+92,CORNER_LEFT_UPPER,StringConcatenate("hedge is" +" OK  "),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);


//   if ( TLOT > 0  )  LabelCreate(0    ,"cm__kn TLOT" ,0 ,X+520,Y+92,CORNER_LEFT_UPPER,StringConcatenate("Buy ",DoubleToStr(TLOT,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
///  if (!WiewOrdersLine) ObjectsDeleteAll(0,"pozi",OBJ_TREND);
//---



//   InpName=DoubleToStr(Vsuma2,2)+" Info";

//---

// Csuma = сегодня ;
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int calcC()
  {
   Csuma =0 ;
   сегодня=0 ;
   вчера=0 ;
   неделя=0;
   месяц=0;
   for(i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()!=Symbol())
            continue;
         Profit = OrderProfit()+OrderSwap()+OrderCommission();
         //  Csuma = Profit ;
         OOP = OrderOpenPrice();
         OOT = OrderOpenTime();
         OCT = OrderCloseTime();
         Ticket=OrderTicket();
         tip = OrderType();
         OL = OrderLots();
         if(tip==OP_BUY)
           {
            NameLine=StringConcatenate("poziBay, Lot ",DoubleToStr(OL,2),"  Ticket ",DoubleToStr(Ticket,0));
            ObjectDelete(NameLine);
            ObjectCreate(NameLine,OBJ_TREND,0,OOT,OOP,OCT,OrderClosePrice());
            ObjectSetInteger(0,NameLine, OBJPROP_COLOR,Color3);
           }
         if(tip==OP_SELL)
           {
            NameLine=StringConcatenate("poziSell, Lot ",DoubleToStr(OL,2),"  Ticket ",DoubleToStr(Ticket,0));
            ObjectDelete(NameLine);
            ObjectCreate(NameLine,OBJ_TREND,0,OOT,OOP,OCT,OrderClosePrice());
            ObjectSetInteger(0,NameLine, OBJPROP_COLOR,Color4);
           }
         ObjectSetInteger(0,NameLine, OBJPROP_STYLE, STYLE_DASHDOT);
         ObjectSetInteger(0,NameLine, OBJPROP_RAY,   false);
         ObjectSetInteger(0,NameLine,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,NameLine,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,NameLine,OBJPROP_HIDDEN,true);
         //---
         if(OCT>=iTime(NULL,1440,0))
           {
            сегодня+=Profit;   ////rexiiiiii
           }
         if(OCT>=iTime(NULL,1440,1) && OCT<iTime(NULL,1440,0))
            вчера+=Profit;
         if(OCT>=iTime(NULL,PERIOD_W1,0))
            неделя+=Profit;
         if(OCT>=iTime(NULL,PERIOD_MN1,0))
            месяц+=Profit;
        }
     }

   return (0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Redraw44()
  {

//Vsuma2 =0 ;


// Redraw55()  ;

// RectLabelCreate(0,"cm__5_" ,0 ,X+1,Y+201,198,18,Color2,Color7,STYLE_SOLID,1,false,false,true,0);
   ButtonCreate(0,"cm__kn History",0,X+2,Y+122,98,18,"HistoryProfit",Font,Width,Color1,Color8,Color7,false);
   ButtonCreate(0,"cm__kn MarketInfo",0,X+100,Y+122,98,18,"MarketInfo",Font,Width,Color1,Color8,Color7,false);
// double Profit=0;

// double сегодня=0,вчера=0,неделя=0,месяц=0;
   if(ObjectGetInteger(0,"cm__kn History",OBJPROP_STATE))
     {
      dnes();

      calcC();


      //  Y=Y+40;
      //  RectLabelCreate(0,InpName,0,X,Y,200,265,Color2,Color1,STYLE_SOLID,3,false,true,true,0);
      RectLabelCreate(0,"cm__fon1_",0,X+1,Y+121,198,223,Color6,Color7,STYLE_SOLID,1,true,false,true,0);
      //   RectLabelCreate(0,"cm__6_" ,0 ,X+1,Y+104,198,18,Color2,Color7,STYLE_SOLID,1,false,false,true,0);
      // LabelCreate(0    ,"cm__60_",0 ,X+100,Y+132,CORNER_LEFT_UPPER,"Profit",Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

      LabelCreate(0,"cm__AccEQ",0,X+100,Y+70,CORNER_LEFT_UPPER,StringConcatenate("EQ= ",DoubleToStr(AccountEquity(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__Tprof",0,X+100,Y+90,CORNER_LEFT_UPPER,StringConcatenate("Profit= ",DoubleToStr(AccountProfit(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

      LabelCreate(0,"cm__ сегодня",0,X+100,Y+155,CORNER_LEFT_UPPER,StringConcatenate("сегодня ",DoubleToStr(сегодня,2),AC),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__ вчера",0,X+100,Y+175,CORNER_LEFT_UPPER,StringConcatenate("вчера ",DoubleToStr(вчера,2),AC),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__ неделя",0,X+100,Y+195,CORNER_LEFT_UPPER,StringConcatenate("неделя ",DoubleToStr(неделя,2),AC),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__ месяц",0,X+100,Y+215,CORNER_LEFT_UPPER,StringConcatenate("месяц ",DoubleToStr(месяц,2),AC),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__ dnes",0,X+100,Y+235,CORNER_LEFT_UPPER,StringConcatenate("dnes ",DoubleToStr(днес,2),AC),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

     }   // Csuma= сегодня ;
//---
   if(ObjectGetInteger(0,"cm__kn MarketInfo",OBJPROP_STATE))
     {
      //  Y=Y+40;
      //   RectLabelCreate(0,InpName,0,X,Y,200,385,Color2,Color1,STYLE_SOLID,3,false,true,true,0);
      RectLabelCreate(0,"cm__fon1_",0,X+1,Y+121,198,343,Color6,Color7,STYLE_SOLID,1,true,false,true,0);
      //    RectLabelCreate(0,"cm__6_" ,0 ,X+1,Y+104,198,18,Color2,Color7,STYLE_SOLID,1,false,false,true,0);
      //   LabelCreate(0    ,"cm__60_",0 ,X+100,Y+132,CORNER_LEFT_UPPER,"MarketInfo",Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

      LabelCreate(0,"cm__AccEQ",0,X+100,Y+70,CORNER_LEFT_UPPER,StringConcatenate("EQ= ",DoubleToStr(AccountEquity(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__Tprof",0,X+100,Y+90,CORNER_LEFT_UPPER,StringConcatenate("Profit= ",DoubleToStr(AccountProfit(),2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);

      LabelCreate(0,"cm__ сегодня",0,X+100,Y+155,CORNER_LEFT_UPPER,StringConcatenate("SPREAD ",MarketInfo(Symbol(),MODE_SPREAD)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      LabelCreate(0,"cm__ вчера",0,X+100,Y+175,CORNER_LEFT_UPPER,StringConcatenate("STOPLEVEL ",MarketInfo(Symbol(),MODE_STOPLEVEL)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);        //+" 14 Минимально допустимый уровень стоп-лосса/тейк-профита в пунктах  "+"\n"+
      LabelCreate(0,"cm__ неделя",0,X+100,Y+195,CORNER_LEFT_UPPER,StringConcatenate("LOTSIZE ",MarketInfo(Symbol(),MODE_LOTSIZE)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);       //+" 15 Размер контракта в базовой валюте инструмента  "+"\n"+
      LabelCreate(0,"cm__ месяц",0,X+100,Y+215,CORNER_LEFT_UPPER,StringConcatenate("TICKVALUE ",MarketInfo(Symbol(),MODE_TICKVALUE)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);        //+" 16 Размер минимального изменения цены инструмента в валюте депозита  "+"\n"+
      LabelCreate(0,"cm__ сегодн1",0,X+100,Y+235,CORNER_LEFT_UPPER,StringConcatenate("TICKSIZE ",MarketInfo(Symbol(),MODE_TICKSIZE)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 17 Минимальный шаг изменения цены инструмента в валюте котировки  "+"\n"+
      LabelCreate(0,"cm__ сегодн2",0,X+100,Y+255,CORNER_LEFT_UPPER,StringConcatenate("SWAPLONG ",MarketInfo(Symbol(),MODE_SWAPLONG)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 18 Размер свопа для длинных позиций  "+"\n"+
      LabelCreate(0,"cm__ сегодн3",0,X+100,Y+275,CORNER_LEFT_UPPER,StringConcatenate("SWAPSHORT ",MarketInfo(Symbol(),MODE_SWAPSHORT)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 19 Размер свопа для коротких позиций  "+"\n"+
      LabelCreate(0,"cm__ сегодн4",0,X+100,Y+295,CORNER_LEFT_UPPER,StringConcatenate("MINLOT ",MarketInfo(Symbol(),MODE_MINLOT)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 23 Минимальный размер лота  "+"\n"+
      LabelCreate(0,"cm__ сегодн5",0,X+100,Y+315,CORNER_LEFT_UPPER,StringConcatenate("LOTSTEP ",MarketInfo(Symbol(),MODE_LOTSTEP)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 24 Шаг изменения размера лота  "+"\n"+
      LabelCreate(0,"cm__ сегодн6",0,X+100,Y+335,CORNER_LEFT_UPPER,StringConcatenate("MAXLOT ",MarketInfo(Symbol(),MODE_MAXLOT)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 25 Максимальный размер лота  "+"\n"+
      LabelCreate(0,"cm__ сегодн7",0,X+100,Y+355,CORNER_LEFT_UPPER,StringConcatenate("MARGINREQUIRED ",MarketInfo(Symbol(),MODE_MARGINREQUIRED)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);      //+" 32 Размер свободных средств, необходимых для открытия 1 лота на покупку  "+"\n"+
     }
   return(0);
  }
//+------------------------------------------------------------------+
void ARROW(string Name, double Price, int ARROWCODE, color c)
  {
   ObjectDelete(Name);
   ObjectCreate(Name,OBJ_ARROW,0,Time[0]+ Period()*300,Price,0,0,0,0);   // position Arrow
   ObjectSetInteger(0,Name,OBJPROP_ARROWCODE,ARROWCODE);
   ObjectSetInteger(0,Name,OBJPROP_COLOR, c);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH, 3);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ARROW1(string Name, double Price, int ARROWCODE, color c)
  {
   ObjectDelete(Name);
   ObjectCreate(Name,OBJ_ARROW,0,Time[0]+ Period()*500,Price,0,0,0,0);
   ObjectSetInteger(0,Name,OBJPROP_ARROWCODE,ARROWCODE);
   ObjectSetInteger(0,Name,OBJPROP_COLOR, c);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH, 4);
  }
//--------------------------------------------------------------------
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const long               x=0,                     // координата по оси X
                  const long               y=0,                     // координата по оси y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrNONE,      //цвет текста
                  const color             clrON=clrNONE,    //цвет фона
                  const color             clrOFF=clrNONE,   //цвет фона
                  const bool              state=false)              // нажата/отжата
  {
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrNONE);
     }
   color back_clr;
   if(ObjectGetInteger(chart_ID,name,OBJPROP_STATE))
      back_clr=clrON;
   else
      back_clr=clrOFF;
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//--------------------------------------------------------------------
bool RectLabelCreate777(const long             chart_ID=0,               // ID графика
                        const string           name="RectLabel",         // имя метки
                        const int              sub_window=0,             // номер подокна
                        const long              x=0,                     // координата по оси X
                        const long              y=0,                     // координата по оси y
                        const int              width=10,                 // ширина
                        const int              height=18,                // высота
                        const color            back_clr=clrNONE,         // цвет фона
                        const color            clr=clrNONE,              //цвет плоской границы (Flat)
                        const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы
                        const int              line_width=1,             // толщина плоской границы
                        const bool             back=false,               // на заднем плане
                        const bool             selection=false,          // выделить для перемещений
                        const bool             hidden=true,              // скрыт в списке объектов
                        const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//--------------------------------------------------------------------
bool LabelCreate777(const long              chart_ID=0,               // ID графика
                    const string            name="Label",             // имя метки
                    const int               sub_window=0,             // номер подокна
                    const long              x=0,                      // координата по оси X
                    const long              y=0,                      // координата по оси y
                    const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                    const string            text="Label",             // текст
                    const string            font="Arial",             // шрифт
                    const int               font_size=10,             // размер шрифта
                    const color             clr=clrNONE,
                    const double            angle=0.0,                // наклон текста
                    const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки
                    const bool              back=false,               // на заднем плане
                    const bool              selection=false,          // выделить для перемещений
                    const bool              hidden=true,              // скрыт в списке объектов
                    const long              z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,": не удалось создать текстовую метку! Код ошибки = ",GetLastError());
         return(false);
        }
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   return(true);
  }
//--------------------------------------------------------------------

//--------------------------------------------------------------------
bool EditCreate777(const long             chart_ID=0,               // ID графика
                   const string           name="Edit",              // имя объекта
                   const int              sub_window=0,             // номер подокна
                   const long              x=0,                      // координата по оси X
                   const long              y=0,                      // координата по оси Y
                   const int              width=50,                 // ширина
                   const int              height=18,                // высота
                   const string           text="Text",              // текст
                   const string           font="Arial",             // шрифт
                   const int              font_size=8,             // размер шрифта
                   const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // способ выравнивания
                   const bool             read_only=true,// возможность редактировать
                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER,// угол графика для привязки
                   const color            clr=clrBlack,             // цвет текста
                   const color            back_clr=clrWhite,        // цвет фона
                   const color            border_clr=clrNONE,       // цвет границы
                   const bool             back=false,               // на заднем плане
                   const bool             selection=false,          // выделить для перемещений
                   const bool             hidden=true,              // скрыт в списке объектов
                   const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)!=-1)
      ObjectDelete(chart_ID,name);
//{
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//}
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/////======================================================

extern string           text1="Global Information";            //Description
//extern bool             CurrencySymbolRight=True;              //is your currency symbol (€ $ Ł) at the Right?
extern double           LotSize=1;                             //your default Lot Size
extern double           LotSizestep= 0.1;                             //your default Lot Size step
extern string           MasterHide="H";                        //hide or show the tool
extern bool             IndicatorValue=true;                   //show indicator information
extern bool             ShowGrid=false;                         //show horizontal grid
extern int              PipInterval=10;                        //default 10 interval for grid
extern int              ColorVariation=1;                      //1 to 8, smaller the grid color is close to the background color
extern string           MasterToolConf="O";                    //show the option tool
extern bool             ShowDailyOpen=true;                   //show DailyOpen
extern bool             ShowPivot=false;                       //show Pivot
extern bool             ShowPivotFibo=false;                   //show Pivot based on Fibonacci
extern bool             SLTPalert=false;                       //sound alert when TP or SL is close to be touch
extern int              SLTPalertPips=5;                       //pips before alert TP or SL
extern int              koefPoint=10;                       //koef na point

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum filename  // enumeration of sound filename
  {
   none,               //no sound
   pong,               //pong sound
   tone,               //tone sound
   spacial,            //spacial sound
   blop,               //blop sound
   startrek,           //startrek sound
   scan                //scan sound
  };
extern string           textc="";                              //====================================
extern string           text2="Support & Resistance Management Tool";  //Description
extern string           text3="==First Line";                    //Description
extern string           LineHorizontal="A";                    //Key to Create a SR Line (1)
extern color            LineResistcolor=clrDodgerBlue;         //Resistance Line Color (1)
extern color            LineSupportcolor=clrDarkOrange;        //Support Line Color (1)
extern ENUM_LINE_STYLE  LineStyle=STYLE_SOLID;                 //Style of SR Lines (1)
extern int              Linewidth=2;                           //Choose the width of the line (1)
extern bool             AlarmCrossWhithAlert=true;             //Send an Alert
extern bool             AlarmCrossWhithPushSmartphone=false;   //Send a Notification
extern filename         soundname=none;                        //Choose a pair of Sound (high/deep tone)
extern string           text4="==Second Line";                   //Description
extern string           LineHorizontalSecond="Q";              //Key to Create a SR Line (2)
extern color            LineResistcolorSecond=clrDodgerBlue;   //Resistance Line Color (2)
extern color            LineSupportcolorSecond=clrDarkOrange;  //Support Line Color (2)
extern ENUM_LINE_STYLE  LineStyleSecond=STYLE_DOT;             //Style of SR Lines (2)
extern int              LinewidthSecond=1;                     //Choose the width of the line (2)
extern bool             AlarmCrossWhithAlertSecond=true;             //Send an Alert
extern bool             AlarmCrossWhithPushSmartphoneSecond=false;   //Send a Notification
extern filename         soundnameSecond=none;                        //Choose a pair of Sound (high/deep tone)
extern string           text5="==TrendLine";                     //Description
extern bool             TakecareManualTrendline=true;          //Take care of your Trendline added manually
extern string           text6="==Other";                       //Description
extern string           DeleteLastLine="X";                    //Key to Delete Last Line
extern int              history=200;                           //Check on the last x candles
extern int              MaxDeviation=10;                       //Pips deviation for history

extern string           texta="";                              //====================================
extern string           text7="Money Management Tool";         //Description


extern string           HedgeLine="J";                           //Key to Create a Hedge Line
extern string           BuyLine="B";                           //Key to Create a Buy Line
extern string           SellLine="S";                          //Key to Create a Sell Line
extern double           Risk=0.25;                                //Your Percentage Risk
extern double           Riskstep= 0.02;                                //Your Percentage Risk  step
extern double           DefaultSL=30000;                          //Default SL in Pips
extern double           DefaultTP=90000;                          //Default TP in Pips
extern color            ColorBuySell=clrAqua;                 //Color of the Buy or Sell line
extern color            ColorSL=clrRed;                        //Color of the SL line
extern color            ColorTP=clrLawnGreen;                  //Color of the TP line
extern color            ColorTextBox=clrWhite;                 //Color of text in the toolbox
//extern ENUM_LINE_STYLE  MMLineStyle=STYLE_DASHDOTDOT;          //Style of Lines
//extern int              MMLinewidth=1;                         //Choose the width of the line
extern bool             Account=false;                          //Choose Balance [true] or Equity [false]
extern bool             CreateTP=false;                         //Create a Take Profit line
extern bool             CreateSL=true;                         //Create a Stop Loss line
extern int              MagicNumber=777;                    //Magic Number
extern bool             ShowAskLine=True;                      //Show Ask Line
int  size10 = 14 ; ///font size  oder;
//double    SP =30;  //spread
//input double     koef = 3 ;  //коеф * спреда


extern double            LotSize1 = 0.1 ;
int               intParent;
int               intChild;
double            PipValues;
double            point;
double            SwapLong;
double            SwapShort;
double            SpreadPipValue;
double            SpreadPip;
double            ClickValue;
double            ClickPip;
double            ClickPrice;
double            MousePrice;
datetime          MouseDate;
string            CountDown;
double            SLTPbrokerLimit;
double            MaximumLot;
double            MinimumLotSize;
double            LotStep;
color             TextColor=clrWhite;
color             BackgroundColor=clrBlack;
color             BorderColor=clrWhite;
double            riskmoney;
bool              objectclick=false;
datetime          labelposition;                 // label position on screen
datetime          orderlabelposition;
double            ratioposition=0.70;
string            linehistory="";
string            LineId="";
string            objectline;
double            PipGap;
double            PipGapValue;
color             tempalertcolor;
color             tempshowcolor;
bool              showlineA=true;
bool              showlineQ=true;
bool              showmaster=true;
double            PipValuesonelot;
string            onoff;
color             onoffcolor;
bool              followprice=false;
string            YesNo;
color             YesNocolor;
double            SLPips;
double            TPPips;
string            ratio;
double            lotsizemaximum;
long              chartheight=-1;
long              periodmouseover=Period();
int               BullCount;
int               BearCount;
int               MiddleCount;
int               OverSell;
int               OverBuy;
double            Meter[];
datetime          OldCandelTime;
double            DailyOpenArray[];
bool              ShowPrice=true;
double            PPBuffer[];
double            R1Buffer[];
double            R2Buffer[];
double            R3Buffer[];
double            R4Buffer[];
double            S1Buffer[];
double            S2Buffer[];
double            S3Buffer[];
double            S4Buffer[];
double            FPPBuffer[];
double            FR1Buffer[];
double            FR2Buffer[];
double            FR3Buffer[];
double            FS1Buffer[];
double            FS2Buffer[];
double            FS3Buffer[];
double            GridLow;
double            GridHigh;
double            SLTPbrokerLimitnotzero;
long              ColorBidLine;
int               Timer;

ENUM_ACCOUNT_INFO_DOUBLE         accounttype=  ACCOUNT_EQUITY   ; //////ACCOUNT_BALANCE ;


//| calculatesell                                                    |
//+------------------------------------------------------------------+
void calculatesell()
  {

   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
      if(!SLPips==0)
        {
         ratio="1:"+DoubleToString((TPPips/SLPips),1);
        }
     }
   else
     {
      ratio="";
     }
   if(SLPips!=0)
     {
      LotSize=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);
      LotSize=MathRound(LotSize/LotStep)*LotStep;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   if(LotSize>MaximumLot || LotSize<MinimumLotSize)
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
     }
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot :        "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

   ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLFRACTAL",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   if(GlobalVariableGet("MasIN_MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

   string OrderButtonText="";

   if(followprice)
     {
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
           }
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
         HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
         if(CreateTP)
           {
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_BID)-TPPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)-TPPips);
           }
        }
     }
   else
     {
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         if(MathRound(MathAbs((ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_ASK))/Point))<SLTPbrokerLimit)
           {
            //errorlimit=errorlimit+"Pending ";
            //    ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
           }
         else
           {
            //  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
           }
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         if(MathRound(MathAbs((ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID))/Point))<SLTPbrokerLimit)
           {
            //      errorlimit=errorlimit+"Pending ";
            //   ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
           }
         else
           {
            //  if(StringLen(errorlimit)>1)
              {
               //  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit+" in Broker Limit");
              }
            //else
              {
               //  ObjectSetString(0,"MasIN_L3C1-error",OBJPROP_TEXT,errorlimit);
              }
           }
        }
     }

   /*  if(followprice)
       {
        OrderButtonText="Order Sell "+DoubleToString(LotSize,2)+" Lot";
       }
     else
       {
        if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))
          {
           OrderButtonText="Order Sell Limit "+DoubleToString(LotSize,2)+" Lot";
          }
        else
          {
           OrderButtonText="Order Sell Stop "+DoubleToString(LotSize,2)+" Lot";
          }
       }
       */
   ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
  }
//+------------------------------------------------------------------+
//| StringChangeToUpperCase                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringChangeToUpperCase(string sText)
  {
   int iLen=StringLen(sText),i;
   ushort iChar;
   for(i=0; i<iLen; i++)
     {
      iChar=StringGetChar(sText,i);
      if(iChar>=97 && iChar<=122)
         sText=StringSetChar(sText,i,ushort(iChar-32));
     }
   return(sText);
  }
//+----------------------------------------

//+------------------------------------------------------------------+
//| calculatebuy                                                     |
//+------------------------------------------------------------------+
void calculatebuy()
  {
   if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_TP_Line")>-1)
     {
      CreateTP=true;
     }
   else
     {
      CreateTP=false;
     }

   SLPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
//if(SLPips==0)
//  {
//   HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)-(DefaultSL));
//  }
   if(CreateTP)
     {
      TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
      //if(TPPips==0)
      //  {
      //   HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)+(DefaultTP));
      //  }

      if(!SLPips==0)
        {
         ratio="1:"+DoubleToString((TPPips/SLPips),1);
        }
     }
   else
     {
      ratio="";
     }
   if(SLPips!=0)
     {
      LotSize=NormalizeDouble(riskmoney/((SLPips/point))/PipValuesonelot,2);;
      LotSize=MathRound(LotSize/LotStep)*LotStep;
     }
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   if(LotSize>MaximumLot || LotSize<MinimumLotSize)
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,clrRed);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_L1C1",OBJPROP_COLOR,TextColor);
     }
   ObjectSetString(0,"MasIN_L1C1",OBJPROP_TEXT,"Lot :        "+DoubleToStr(LotSize,2)+" / "+CurrencyFormat(PipValues,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));

   ObjectSetInteger(0,"MasIN_L3C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_TPButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_SLButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonPlus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_RiskButtonMinus",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_MMGTbox_CloseButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4C1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLM5",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLATR",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BSLFRACTAL",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
   ObjectSetInteger(0,"MasIN_L4_BTPRR1",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR2",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR3",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L4_BTPRR4",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetInteger(0,"MasIN_L3C1-error",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

   if(GlobalVariableGet("MasIN_MMGT_EA")==1)
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
     }
   else
     {
      ObjectSetInteger(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     }

   string OrderButtonText="";
   if(followprice)
     {
      OrderButtonText="Order Buy "+DoubleToString(LotSize,2)+" Lot";
     }
   else
     {
      if(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_ASK))
        {
         OrderButtonText="Order Buy Stop "+DoubleToString(LotSize,2)+" Lot";
        }
      else
        {
         OrderButtonText="Order Buy Limit "+DoubleToString(LotSize,2)+" Lot";
        }
     }
   ObjectSetString(0,"MasIN_MMGTbox_OrderButton",OBJPROP_TEXT,OrderButtonText);
  }
//+---------------------



void OnTick()

  {
  
   tval = MarketInfo(Symbol(), MODE_TICKVALUE);
    tsize = MarketInfo(Symbol(), MODE_TICKSIZE);
  //   csize = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_CALC_MODE);
     csize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE );
      LSize  = MarketInfo(Symbol(), MODE_LOTSIZE);      /// ????    LSize  === csize ??
   
    pval=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) ;
    accEQ = AccountInfoDouble(ACCOUNT_EQUITY);
     SpreadPip=MarketInfo(Symbol(),MODE_SPREAD)/point*Point;
   
 double UnitCost = MarketInfo(Symbol(), MODE_TICKVALUE);
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   //if ((StopLoss != 0) && (UnitCost != 0) && (TickSize != 0))
    double PositionSize = 1000 / (StopLoss * UnitCost / TickSize);
   double PositionSuma =  (StopLoss / UnitCost * TickSize)  *  0.10;
    double PositionStop =  (1000 * UnitCost / TickSize)  /  0.10;
  

 double   PipValues3=MarketInfo(_Symbol,MODE_TICKVALUE)/(MarketInfo(_Symbol,MODE_TICKSIZE)/MarketInfo(_Symbol,MODE_POINT)); //cost of point
   double PipValues=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) ;
   double   PipValues4=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
  

   OnTimer();

  }



//| DailyOpen                                                        |
//+------------------------------------------------------------------+
int DailyOpen()
  {
   int i;
   double openat= iOpen(Symbol(),PERIOD_D1,0);
   int BarsCount=iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,0));
   ObjectCreate("MasIN_Daily_"+Symbol()+"_DO_label",OBJ_TEXT,0,Time[2],openat);
   ObjectMove(0,"MasIN_Daily_"+Symbol()+"_DO_label",0,Time[2],openat);
   ObjectSetText("MasIN_Daily_"+Symbol()+"_DO_label","Daily Open",7,"Courier New",clrGray);

   for(i=1; i<BarsCount; i++)
     {
      DailyOpenArray[i]=openat;
     }
   return(0);
  }
//+--------------------------


datetime       time_f1,time_f2;
double         buy_lots,buy_sum_price,buy_sum_comission;
double         sell_lots,sell_sum_price,sell_sum_comission;
double         sell_avg_price,buy_avg_price,price_buy_line,price_sell_line, price_total_line,total_lots;
double         summ_stoplimit_price;
string         Label_prefix="lp2_";
int            totalOrders,how_StopLimit;
int            TICKETS_StopLimit[];
enum   choice1 {cash,points};
input  choice1 summ_in=cash;              //To count in money or in pips
enum   choice0 {yes,no};
input  choice0 add_pending=no;           //Add pending orders to calculate
double Tick_Value=NormalizeDouble(MarketInfo(_Symbol,MODE_TICKVALUE),_Digits);
double  Hprice=0,  dLotSize, wLotSize;
double znak =0;

//+------------------------------------------------------------------+
void CalcPosition()
  {
   totalOrders=OrdersTotal();
   buy_lots=buy_sum_price=buy_sum_comission=0;
   sell_lots=sell_sum_price=sell_sum_comission=0;

   how_StopLimit=0;
   ArrayResize(TICKETS_StopLimit,0);

   if(totalOrders>0)
     {
      for(int i=0; i<totalOrders; i++)
        {
         bool i2=false;
         while(i2==false && !IsStopped())
            i2=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==_Symbol && (MagicNumber==0 || MagicNumber==OrderMagicNumber()) && (add_pending==yes || OrderType()<2))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
              {
               buy_lots+=OrderLots();
               buy_sum_price+=OrderOpenPrice()*OrderLots();
               buy_sum_comission+=OrderSwap()+OrderCommission();

               if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
                 {
                  how_StopLimit++;
                  ArrayResize(TICKETS_StopLimit,how_StopLimit);
                  TICKETS_StopLimit[how_StopLimit-1]=OrderTicket();
                 }

              }
            if(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
              {
               sell_lots+=OrderLots();
               sell_sum_price+=OrderOpenPrice()*OrderLots();
               sell_sum_comission+=OrderSwap()+OrderCommission();

               if(OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                 {
                  how_StopLimit++;
                  ArrayResize(TICKETS_StopLimit,how_StopLimit);
                  TICKETS_StopLimit[how_StopLimit-1]=OrderTicket();
                 }
              }
           }
        }
     }
   total_lots=buy_lots-sell_lots;
   if(sell_lots==0)
     {
      ObjectDelete(0,Label_prefix+"lsell");
      ObjectDelete(0,Label_prefix+"fsell");
      price_sell_line=0;
     }
   if(buy_lots==0)
     {
      ObjectDelete(0,Label_prefix+"lbuy");
      ObjectDelete(0,Label_prefix+"fbuy");
      price_buy_line=0;
     }
   if(total_lots==0)
     {
      ObjectDelete(0,Label_prefix+"ltotal");
      ObjectDelete(0,Label_prefix+"ftotal");
      price_total_line=0;
     }
   WindowRedraw() ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calcAlert()
  {

//inlot();
   glot =Lot;

   labelposition= Time[WindowFirstVisibleBar()/3*2] ;

   if(how_StopLimit>0)
     {
      double summ=0;
      for(int i=0; i<how_StopLimit; i++)
        {
         OrderSelectbyTicket(TICKETS_StopLimit[i]);
         summ+=OrderOpenPrice();
        }
      if(summ_stoplimit_price!=summ)
        {
         summ_stoplimit_price=summ;
         //CreateLines();
        }
     }

   if(totalOrders!=OrdersTotal())
      //CreateLines();

      int i;
   string result[];
   bool lineexist=false;
   string            objectline;
   for(i=ObjectsTotal() -1; i>=0; i--)
     {

      if(StringFind(ObjectName(i),prefix+"LPL2_"+Symbol())>-1)
        {

         if(StringFind(ObjectName(i),"_Hedge_Lab2")>-1)
           {
            lineexist=true;
            objectline=ObjectName(i);
            StringReplace(objectline,"_Hedge_Lab2","_Hedge_Lin2");

            //    Alert(objectline ," / ",ObjectName(i), " / ");
            znak=0;
            CalcPosition();
            if(buy_lots > sell_lots)
               znak=+1;
            if(buy_lots < sell_lots)
               znak=-1;
            //    ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",OBJPROP_SELECTED);
            Hprice = ObjectGet(objectline,OBJPROP_PRICE1);
            double   PGV=(buy_lots - sell_lots)*znak*(Hprice-MarketInfo(Symbol(),MODE_BID))*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE);
            double ppggvv =znak*((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value);

            ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1)); /// TimeCurrent()  labelposition
            //   Hprice  = OBJPROP_PRICE1 ;
            ObjectSetText(ObjectName(i),
                          "Ц "+DoubleToString(Hprice,Digits)+
                          " / "+DoubleToString(PipGap/Point,1)
                          +"P Hlot= "+DoubleToString(znak*(buy_lots - sell_lots),2)
                          +" Hsuma= "+DoubleToString(znak*((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value),2)+" "+
                          DoubleToString(ppggvv- PGV,2),14,"Courier New",clrAqua);

            //   ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",SHprice)); /// TimeCurrent()  labelposition

            //  TextMove(0,prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",0,Hprice);


            // ObjectDelete(0,objectline);
            /*           PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*Point)/MarketInfo(Symbol(),MODE_TICKSIZE))*dLotSize);

            PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
            PipGapValue=dLotSize*znak*PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE);
            ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString( dLotSize,2) + " k / "+DoubleToString(PipGap/point,1)+" Pips 2/ "+DoubleToString(PipGapValue,2));
            ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString( dLotSize,2) + " k / "+DoubleToString(PipGap/point,1)+" Pips 2/ "+DoubleToString(PipGapValue,2));
            ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString( dLotSize,2) + " k / "+DoubleToString(PipGap/point,1)+" Pips3 / "+DoubleToString(PipGapValue,2));

            */
            // StringReplace(objectline,"_Hedge_Lin2","_Hedge_Lab2");
            //  ObjectDelete(0,objectline);
            ///   ObjectCreate(objectline,OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],OBJPROP_PRICE1) ; //,ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lin2",OBJPROP_PRICE1));

            //    Alert(objectline ," / ",ObjectName(i), " / ");

            //   StringReplace(objectline,"_Hedge_Lin2","_Hedge_Lab2");
            //     TextMove(0,objectline,0,OBJPROP_PRICE1) ;

            /*  StringReplace(objectline,"_label","_RS");
              ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1));
              PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
              PipGapValue=PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*LotSize;
              ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+DoubleToString(PipGapValue,2));
              ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+DoubleToString(PipGapValue,2));
              ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips / "+DoubleToString(PipGapValue,2));
              */
           }

        }



      if(StringFind(ObjectName(i),prefix+"LPL2_"+Symbol())>-1)
        {
         if(StringFind(ObjectName(i),"_label")>-1)
           {
            if(buy_lots > sell_lots)
               znak=+1;
            if(buy_lots < sell_lots)
               znak=-1;

            lineexist=true;
            objectline=ObjectName(i);
            dLotSize = wLotSize ;
            dLotSize = lotMG ;
            StringReplace(objectline,"_label","_RS_line");
            ObjectMove(0,ObjectName(i),0,labelposition,ObjectGet(objectline,OBJPROP_PRICE1)); /// TimeCurrent()  labelposition
            PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*Point)/MarketInfo(Symbol(),MODE_TICKSIZE))*dLotSize);

            PipGap=MathAbs(MarketInfo(Symbol(),MODE_BID)-ObjectGet(objectline,OBJPROP_PRICE1));
            PipGapValue=dLotSize*znak*PipGap*MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE);
            ObjectSetString(0,ObjectName(i),OBJPROP_TEXT,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(dLotSize,2) + " L / "+DoubleToString(PipGap/point,1)+" Pips 2/ razlika"+DoubleToString(PipGapValue,2));
            ObjectSetString(0,ObjectName(i),OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(dLotSize,2) + " L / "+DoubleToString(PipGap/point,1)+" Pips 2/razlika "+DoubleToString(PipGapValue,2));
            ObjectSetString(0,objectline,OBJPROP_TOOLTIP,DoubleToString(ObjectGet(objectline,OBJPROP_PRICE1),Digits)+" / "+DoubleToString(dLotSize,2) + " L / "+DoubleToString(PipGap/point,1)+" Pips3 / "+DoubleToString(PipGapValue,2));
           }

         if(StringFind(ObjectName(i),"_A_RS")>-1)
           {


            if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)<MarketInfo(Symbol(),MODE_BID))
              {
               //is support
               if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineSupportcolor)
                 {
                  //is already support
                 }
               else
                 {
                  //was resistance
                  ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineSupportcolor);
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_RS","_label");
                  ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineSupportcolor);
                  if(AlarmCrossWhithAlert)
                    {
                     //send alarm
                     StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                     Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                     if(1>0)
                       {
                        PlaySound("Beep-"+IntegerToString(1)+"-up.wav ");
                       }
                    }
                  if(AlarmCrossWhithPushSmartphone)
                    {
                     //send alarm
                     StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                     SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Over");
                    }
                 }
              }
            if(ObjectGet(ObjectName(i),OBJPROP_PRICE1)>MarketInfo(Symbol(),MODE_BID))

              {
               if(ObjectGet(ObjectName(i),OBJPROP_COLOR)==LineResistcolor)
                 {
                  //is already resistance
                 }
               else
                 {
                  //was support
                  ObjectSetInteger(0,ObjectName(i),OBJPROP_COLOR,LineResistcolor);
                  objectline=ObjectName(i);
                  StringReplace(objectline,"_RS","_label");
                  ObjectSetInteger(0,objectline,OBJPROP_COLOR,LineResistcolor);
                  if(AlarmCrossWhithAlert)
                    {
                     //send alarm
                     StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                     Alert(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                     if(1>0)
                       {
                        PlaySound("Beep-"+IntegerToString(1)+"-down.wav ");
                       }
                    }
                  if(AlarmCrossWhithPushSmartphone)
                    {
                     //send alarm
                     StringSplit(ObjectName(i),StringGetCharacter("_",0),result);
                     SendNotification(result[2]+" Crossed "+DoubleToString(ObjectGet(ObjectName(i),OBJPROP_PRICE1),Digits)+" - Under");
                    }
                 }
              }
           }


        }
     }



   return ;
  }

//+------------------------------------------------------------------+
void OrderSelectbyTicket(int ord_ticket)
  {
   bool i2=false;
   while(i2==false && !IsStopped())
     {
      i2=OrderSelect(ord_ticket,SELECT_BY_TICKET);
     }
  }
//+---------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void dimi()
  {

//   but2 ();
   dimi2() ;

  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
                                                          
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment(WindowExpertName()+" successfully deinitialized !   "+getUninitReasonText(_UninitReason));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void uroven()
  {
//Comment("   uroven \n", NL); //   ver1  cviat1
   /*string ti="";double ss=0; double tt=0;
         string nameX="",nameTP="",nameSL="",nameBR="",nameTR="",nameTI="",nameTPV="",nameSLV="", nameHH="";

      int typ=-1,tik=-1;   double op=0;   string name="";
      */
   if(1==1)
     {


      for(int i=0; i<OrdersTotal(); i++) //int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            //  if(OrderSymbol()== _Symbol )
           {
            //if(OrderMagicNumber() == Magic)
              {
               typ=OrderType();
               tik=OrderTicket();
               // ObjectDelete(0,"Op"+tik) ;

               op=NormalizeDouble(OrderOpenPrice(),_Digits);
               //sl=NormalizeDouble(OrderOpenPrice(),_Digits);
               tt=NormalizeDouble(get_object(nameLTP),_Digits);
               ss=NormalizeDouble(get_object(nameLSL),_Digits);
               //  nameTPV=StringConcatenate(prefix,"TP",tik,"V");
               // rexiii nameSLV=StringConcatenate(prefix,"SL",tik,"V");
               name=StringConcatenate("Op",tik);
               ti=StringConcatenate("ti",tik);
               ti= OrderOpenTime() ;

               //  ObjectSet(name,OBJPROP_COLOR,clrOrange);
               // ObjectDelete(name);
               color cviat1;
               ObjectGetInteger(0,CHART_COLOR_BACKGROUND,0,cviat1);
               obj_cre_h_line(name,op,clrBlack);
               //WindowRedraw();
              }
            /*  else
              {

              obj_cre_h_line(name,op,clrRed);
               WindowRedraw();
               }*/
           }
         else
           {
            //  ObjectSet(name,OBJPROP_COLOR,clrNONE);
            obj_cre_h_line(name,op,clrMagenta);
            // WindowRedraw();
           }
        }
     }     // */

   if(2==2)
     {
      for(int i=0; i<OrdersTotal(); i++)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==_Symbol)
              {
               typ=OrderType();
               tik=OrderTicket();
               op=NormalizeDouble(OrderOpenPrice(),_Digits);
               //sl=NormalizeDouble(OrderOpenPrice(),_Digits);
               tt=NormalizeDouble(get_object(nameLTP),_Digits);
               ss=NormalizeDouble(get_object(nameLSL),_Digits);
               //  nameTPV=StringConcatenate(prefix,"TP",tik,"V");
               // rexiii nameSLV=StringConcatenate(prefix,"SL",tik,"V");
               name=StringConcatenate("Op",tik);
               ti=StringConcatenate("ti",tik);
               ti= OrderOpenTime() ;


               //if(OrderMagicNumber()==Magic || MagicALL!=-1)
               if(OrderMagicNumber()== Magic)  /// || MagicALL==-1)
                 {

                  if(OrderSymbol()==_Symbol)


                     if(typ==0 || typ==2 || typ==4)
                       {
                        // if(ObjectFind(0,name)==-1)
                          {
                           //   DrawHLINE(name,op,clrAqua);
                           obj_cre_h_line(name,op,clrAqua);
                           // obj_cre_trend(nameTPV,ti,tt,ti,op,clrBlue);
                          }
                       }
                  if(typ==1 ||typ==3 || typ==5)
                    {
                     //  if(ObjectFind(0,name)==-1)
                       {
                        // DrawHLINE(name,op,clrOrangeRed);
                        obj_cre_h_line(name,op,clrOrangeRed);
                        // obj_cre_trend(nameSLV,ti,ss,ti,op,clrOrangeRed);
                       }
                    }
                  if(ObjectFind(0,name)==0)
                     if(op!=NormalizeDouble(get_object(name),_Digits))
                        if(OrderModify(OrderTicket(),NormalizeDouble(get_object(name),_Digits),OrderStopLoss(),OrderTakeProfit(),0,clrGreen)==true)
                          {
                           pr(" OrderModify Ok !");


                           // ObjectDelete(0,StringConcatenate("Op",OrderTicket()));
                           // obj_del(name);
                           // ObjectDelete(0,name);
                           //   obj_del(StringConcatenate("Re",OrderTicket()));    ///moverexi
                           //    ObjectDelete(0,StringConcatenate(prefix,"Re",OrderTicket()));
                           ChartTimePriceToXY(0,0,Time[0],OrderOpenPrice(),x,y);
                           SetX(StringConcatenate(prefix+"Re",OrderTicket()),y);
                           int x2=(int)IntGetX(StringConcatenate("Re",OrderTicket()));
                           //    int x2=(int)IntGetX (StringConcatenate("Re",OrderTicket()));
                           //   int y2=(int)IntGetY (StringConcatenate("Re",OrderTicket()));
                           WindowRedraw();

                           datetime dt    =0;
                           double   price =0;
                           int      window=0;
                           //--- Convert the X and Y coordinates in terms of date/time
                           ChartXYToTimePrice(0,x2-10,y,window,dt,price) ;
                           datetime ti2=dt ;
                           //      tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits); /// obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
                           //     ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);   ///  obj_cre_trend(nameSLV,ti2,ss,ti2,op,clrMagenta);

                           /////   TextCreate(0,"L44",0,ti2,tt,StringConcatenate(IntegerToString(i) + "len "+  OrderType() +"  = "+ DoubleToStr(OrderLots(),2)  +"   Magic = ",OrderMagicNumber(),"    Profit = ",DoubleToStr(OrderProfit(),2)),"Arial",10,OrderProfit()<0? clrYellowGreen:clrWhiteSmoke);



                          }
                        else
                           pr(__FUNCTION__+"OrderModify Error !");
                 }
               else
                 {
                  // if(ObjectFind(0,name)==-1)
                    {

                     //  obj_cre_h_line(name,op,clrBlack);   WindowRedraw();

                    }
                 }

              } // WindowRedraw();
     } //// */


   if(43==3)
     {


      for(int i=0; i<OrdersTotal(); i++) //int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            //  if(OrderSymbol()== _Symbol )
           {
            if(OrderMagicNumber() == Magic)
              {
               typ=OrderType();
               tik=OrderTicket();
               // ObjectDelete(0,"Op"+tik) ;

               op=NormalizeDouble(OrderOpenPrice(),_Digits);
               //sl=NormalizeDouble(OrderOpenPrice(),_Digits);
               tt=NormalizeDouble(get_object(nameLTP),_Digits);
               ss=NormalizeDouble(get_object(nameLSL),_Digits);
               //  nameTPV=StringConcatenate(prefix,"TP",tik,"V");
               // rexiii nameSLV=StringConcatenate(prefix,"SL",tik,"V");
               name=StringConcatenate("Op",tik);
               ti=StringConcatenate("ti",tik);
               ti= OrderOpenTime() ;

               ObjectSet(name,OBJPROP_COLOR,clrOrange);
               // ObjectDelete(name);
               //  obj_cre_h_line(name,op,clrMagenta);
               if(typ==0 || typ==2 || typ==4)
                 {
                  //  if(ObjectFind(0,name)==-1)
                    {
                     //   DrawHLINE(name,op,clrAqua);
                     obj_cre_h_line(name,op,clrAqua);
                     // obj_cre_trend(nameTPV,ti,tt,ti,op,clrBlue);
                    }
                 }
               if(typ==1 ||typ==3 || typ==5)
                 {
                  //  if(ObjectFind(0,name)==-1)
                    {
                     // DrawHLINE(name,op,clrOrangeRed);
                     obj_cre_h_line(name,op,clrOrangeRed);
                     // obj_cre_trend(nameSLV,ti,ss,ti,op,clrOrangeRed);
                    }
                 }

               WindowRedraw();
              }
            /*  else
              {

              obj_cre_h_line(name,op,clrRed);
               WindowRedraw();
               }*/
           }
         else
           {
            //  ObjectSet(name,OBJPROP_COLOR,clrNONE);
            obj_cre_h_line(name,op,clrMagenta);
            WindowRedraw();
           }
        }
     }     // */
  }
//+------------------------------------------------------------------+
//|                        |
//+------------------------------------------------------------------+
void obj_cre_h_line(string txt,double pri,color col)    //hide price  sl, tp, on chart rexi
  {
// if(ObjectFind(0,txt)==-1 && OrderMagicNumber()==Magic)
     {
      ObjectCreate(0,txt,OBJ_HLINE,0,0,0);
      ObjectSetDouble(0,txt,OBJPROP_PRICE1,pri);
      ObjectSetInteger(0,txt,OBJPROP_COLOR,col);
      ObjectSetInteger(0,txt,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,txt,OBJPROP_STYLE,3);
      ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
      WindowRedraw();
     }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything in this function
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   datetime dt    =0;
   double   price =0;
   int      window=0;
   int      k=1;
   int      i=1;
   double   SLprice=0;
   double   TPprice=0;
   CreateSL=true;
   CreateTP=true;

   point =_Point;
   Lot = glot ;    ////eventt R
   
   
  
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      string clickedChartObject=sparam;
      
      Alert ( "e  natisnato " , clickedChartObject  );
      }
      
   
   //+------------------------------------------------------------------+
//| CHARTEVENT_CLICK                                                 |
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_CLICK)  ////clikkk
     {
  //    Alert("myclick ", MousePrice );
      if(objectclick)
        {
         objectclick=false;
        }
      else
        {
         ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
         MousePrice = price;
         MouseDate=dt;
         if(price>MarketInfo(Symbol(),MODE_ASK))
           {
          //  ClickValue=PipValues*((price-MarketInfo(Symbol(),MODE_ASK))/point);
         //   ClickPip=NormalizeDouble(((price-MarketInfo(Symbol(),MODE_ASK))*lotMG),1);
           }
         else
           {
           // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-price)/point);
           // ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-price)*lotMG),1);
           }
         ClickPrice=price;
         ObjectSetString(0,"MasIN_MMGT_",OBJPROP_TEXT,"Click : "+DoubleToStr(ClickPrice,Digits)+" | "+DoubleToStr(ClickPip,2)+" R/ "+CurrencyFormat(ClickValue,AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight));
        }
     }
     
     
      if(sparam=="FN")
        {
        
        }
      if((but_stat(prefix+"2NL")==true))
     {
Alert ("  2NL  tuka  eeee");
      calcC () ;  ///tuk e History
       // Alert("bbnnll");  /tuk e bnl
     // CalcPosition();
      //  dimi();

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();

      //  handleButtonClicks();
     }
   
     
      if(id==12345 ) //CHARTEVENT_MOUSE_MOVE)
     {
     // ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
//MousePrice=NormalizeDouble(price,Digits);
//MouseDate =dt;
       Alert("mymove", MousePrice );
      // ObjectSetString(0,"MasIN_MMGT_",OBJPROP_TEXT,"Mouse : "+DoubleToStr(MousePrice,Digits)+" / "+TimeToStr(MouseDate,TIME_DATE|TIME_SECONDS));
      periodmouseover=Period();
     }
   
   
  // if(id==CHARTEVENT_OBJECT_CLICK)
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      string clickedChartObject=sparam;
      Alert(clickedChartObject);
      if(but_stat(prefix+"bNL")==true)
         Alert("bNL 2");
         
         
         int i =0 ;
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
                 
           if(StringFind(ObjectName(i)," zz")>-1 )
              {
              
               Alert(clickedChartObject, "namerix " ,ObjectName(i) );
              // ObjectDelete(0,ObjectName(i));
              // labelerase=true;
              
       string  worknameA = clickedChartObject  ;
        //  string   worknameA  = StringConcatenate(nameLAP+LineIdA  );
      if(clickedChartObject==(ObjectName(i)) )
        {
        
    
         Alert("LAP ",clickedChartObject,"  work " ,ObjectName(i) );
         
          if ( ObjectFind(clickedChartObject)>=0)
     {
      
      Alert("A move", MousePrice);
     // string worknameA = clickedChartObject  ;
    // // ObjectDelete(clickedChartObject);
      
   double   PipValues3=MarketInfo(_Symbol,MODE_TICKVALUE)/(MarketInfo(_Symbol,MODE_TICKSIZE)/MarketInfo(_Symbol,MODE_POINT)); //cost of point
   double PipValues=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) ;
   double   PipValues4=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
      obj_cre(worknameA,(MousePrice),clrOrange);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
      tt = NormalizeDouble(get_object(worknameA),_Digits)  ;

      ObjectDelete(worknameA+"txt");
 ObjectCreate(0,worknameA+"txt",OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],tt) ;

   //   ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,ti2,ti2);
      // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);
      if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, worknameA+"txt",OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(lotMG,2) + "## EQqq= "
                         +DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

           ObjectSetString(0, worknameA,OBJPROP_TOOLTIP,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $$ /  "+ DoubleToString(lotMG,2) + "## EQqq= "
                         +DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2));

        }

      else   ////
  //     PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   ////   double   ClickValue1=PipValues1*((op-ClickPrice)/point); 
   ///// SYMBOL_TRADE_TICK_VALUE
        {
         znak=1 ;
         ObjectSetString(0, worknameA+"txt",OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(lotMG,2) + "## EQqq= "
                         +DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
                         
        ObjectSetString(0, worknameA,OBJPROP_TOOLTIP,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $$ /  "+ DoubleToString(lotMG,2) + "## EQqq= "
                         +DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2));
      
        
        
        }

     }
         
        }
     }
     }
     }
     


if(lparam==(StringGetChar("X",0)))
     {
      bool labelerase=false;
      bool lineerase=false;
      int i =0 ;
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
        
         if(StringFind(ObjectName(i),"zz")>-1 && !labelerase)
              {
               ObjectDelete(0,ObjectName(i));
               labelerase=true;
              }
         if(StringFind(ObjectName(i),prefix+"LPL2_"+Symbol())>-1)
           {
           
          
            if(StringFind(ObjectName(i),"_Label")>-1 && !labelerase)
              {
               ObjectDelete(0,ObjectName(i));
               labelerase=true;
              }
            //   if(StringFind(ObjectName(i),"_Hedge_Lin2")>-1 && !lineerase)  //  all delete
            if(StringFind(ObjectName(i),"_Hedge_")>-1 && !lineerase)  //  all delete
              {
               ObjectDelete(0,ObjectName(i));
               //     SaveSupportResistanceToFile();
               lineerase=true;
              }
            if(StringFind(ObjectName(i),"_line")>-1 && !lineerase)  //  all delete
              {
               ObjectDelete(0,ObjectName(i));
               //     SaveSupportResistanceToFile();
               lineerase=true;
              }
           }
        }
     }

//+------------------------------------------------------------------+
//| CHARTEVENT_OBJECT_DRAG                                           |
//+------------------------------------------------------------------+
  // if(id==CHARTEVENT_OBJECT_DRAG)
     {
//  if(lparam==(StringConcatenate(nameLAP+LineIdA) ))
  {
  
  
  }

 
     }
   
   
    if(lparam==(StringGetChar("A",0)))  /// qqqq
  // if ( ObjectFind(nameLQP+LineId)>=0)
     {
      //  ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      // //   MousePrice=NormalizeDouble(price,Digits);
      //  MouseDate=dt;

      //  MousePrice=NormalizeDouble(price,Digits);
      //  MousePrice=MarketInfo(Symbol(),MODE_BID)  ;
      //  MouseDate=dt;
      /*  CalcPosition();

        dLotSize = buy_lots - sell_lots;
        if(buy_lots > sell_lots)
        znak=+1;
      if(buy_lots < sell_lots)
        znak=-1;
      wLotSize = znak*MathAbs(buy_lots-sell_lots) ;
      if(znak !=  0)
        ObjectSetText(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",
                      "Price "+DoubleToString(ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lin2",OBJPROP_PRICE1),Digits)+
                      " / "+DoubleToString(PipGap/Point,1)
                      +" Pips Away3 Hlot= "+DoubleToString(dLotSize,2)
                      +" Hsuma = "+DoubleToString(((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value)/(buy_lots-sell_lots),8)+"          ",14,"Courier New",clrAqua);

        WindowRedraw();
      //   TextMove(0,prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",Time[WindowFirstVisibleBar()/3*2],Hprice);
      */

      PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotMG);
      // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
      ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
      ClickValue=PipValues*((NLoss-ClickPrice)/Point);

      /*if(ClickPrice>MarketInfo(Symbol(),MODE_ASK))
         {
          ClickValue=PipValues*((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point);
          ClickPip=NormalizeDouble(((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point),1);
         }
       else
         {
          ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
          ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
         }*/

      Alert("AAAA", MousePrice);
      
       z=z+1;
      LineIdA=TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeToString(TimeCurrent(),TIME_SECONDS)+" "+IntegerToString( z )+" zz";

      obj_cre(nameLAP+LineIdA,(MousePrice),clrOrange);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
      tt = NormalizeDouble(get_object(nameLAP+LineIdA),_Digits)  ;
      
     //  ObjectCreate(objectline,OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],OBJPROP_PRICE1) ;

      ObjectDelete(nameLAP+LineIdA+"txt");
      
     ObjectCreate(0,nameLAP+LineIdA+"txt",OBJ_TEXT,0,Time[0],tt) ;

      //ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,ti2,tt);
      // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);
      if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLAP+LineIdA+"txt",OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $ / " + "# EQ= "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" "+ DoubleToString(lotMG,2)+"                                .");
                      
             ObjectSetString(0,nameLAP+LineIdA,OBJPROP_TOOLTIP,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $ / " + "# EQ= "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" "+ DoubleToString(lotMG,2)+" .");
      

        }

      else   ////
  //     PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   ////   double   ClickValue1=PipValues1*((op-ClickPrice)/point); 
   ///// SYMBOL_TRADE_TICK_VALUE
        {
         znak=1 ;
         ObjectSetString(0, nameLAP+LineIdA+"txt",OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $ / " + "# EQ= "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" "+ DoubleToString(lotMG,2)+"                                .");
        
             ObjectSetString(0,nameLAP+LineIdA,OBJPROP_TOOLTIP,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize/csize),2)
                         +" $ / " + "# EQ= "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize)
                         +AccountInfoDouble(ACCOUNT_EQUITY),2)+" "+ DoubleToString(lotMG,2)+" .");
      
        
        
        }  //// okkk
        
              
        
     }
      if(lparam==(StringGetChar("J",0)))  /// jjjj
  // if ( ObjectFind(nameLQP+LineId)>=0)
     {
      //  ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      // //   MousePrice=NormalizeDouble(price,Digits);
      //  MouseDate=dt;

      //  MousePrice=NormalizeDouble(price,Digits);
      //  MousePrice=MarketInfo(Symbol(),MODE_BID)  ;
      //  MouseDate=dt;
      /*  CalcPosition();

        dLotSize = buy_lots - sell_lots;
        if(buy_lots > sell_lots)
        znak=+1;
      if(buy_lots < sell_lots)
        znak=-1;
      wLotSize = znak*MathAbs(buy_lots-sell_lots) ;
      if(znak !=  0)
        ObjectSetText(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",
                      "Price "+DoubleToString(ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lin2",OBJPROP_PRICE1),Digits)+
                      " / "+DoubleToString(PipGap/Point,1)
                      +" Pips Away3 Hlot= "+DoubleToString(dLotSize,2)
                      +" Hsuma = "+DoubleToString(((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value)/(buy_lots-sell_lots),8)+"          ",14,"Courier New",clrAqua);

        WindowRedraw();
      //   TextMove(0,prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",Time[WindowFirstVisibleBar()/3*2],Hprice);
      */

      PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotMG);
      // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
      ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
      ClickValue=PipValues*((NLoss-ClickPrice)/Point);

      /*if(ClickPrice>MarketInfo(Symbol(),MODE_ASK))
         {
          ClickValue=PipValues*((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point);
          ClickPip=NormalizeDouble(((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point),1);
         }
       else
         {
          ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
          ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
         }*/

      Alert("jjjj", MousePrice);
      int j =1;
      obj_cre(nameLHP+LineId+j,(MousePrice),clrYellow);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
      tt = NormalizeDouble(get_object(nameLHP+LineId+j),_Digits)  ;
      
     //  ObjectCreate(objectline,OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],OBJPROP_PRICE1) ;

      ObjectDelete(nameLHPtxt+LineId+j);
      
     ObjectCreate(0,nameLHPtxt+LineId+j,OBJ_TEXT,0,Time[0],tt) ;

      //ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,ti2,tt);
      // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);
      if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLHPtxt+LineId+j,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / H "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $$ /                lotMG "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else
        {
         znak=1 ;
         ObjectSetString(0, nameLHPtxt+LineId+j,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / H "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $$ /                lotMG "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }
     }
    
   
   
   if(lparam==(StringGetChar("Q",0)))  /// qqqq
  // if ( ObjectFind(nameLQP+LineId)>=0)
     {
      //  ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      // //   MousePrice=NormalizeDouble(price,Digits);
      //  MouseDate=dt;

      //  MousePrice=NormalizeDouble(price,Digits);
      //  MousePrice=MarketInfo(Symbol(),MODE_BID)  ;
      //  MouseDate=dt;
      /*  CalcPosition();

        dLotSize = buy_lots - sell_lots;
        if(buy_lots > sell_lots)
        znak=+1;
      if(buy_lots < sell_lots)
        znak=-1;
      wLotSize = znak*MathAbs(buy_lots-sell_lots) ;
      if(znak !=  0)
        ObjectSetText(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",
                      "Price "+DoubleToString(ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lin2",OBJPROP_PRICE1),Digits)+
                      " / "+DoubleToString(PipGap/Point,1)
                      +" Pips Away3 Hlot= "+DoubleToString(dLotSize,2)
                      +" Hsuma = "+DoubleToString(((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value)/(buy_lots-sell_lots),8)+"          ",14,"Courier New",clrAqua);

        WindowRedraw();
      //   TextMove(0,prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",Time[WindowFirstVisibleBar()/3*2],Hprice);
      */

      PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotMG);
      // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
      ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
      ClickValue=PipValues*((NLoss-ClickPrice)/Point);

      /*if(ClickPrice>MarketInfo(Symbol(),MODE_ASK))
         {
          ClickValue=PipValues*((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point);
          ClickPip=NormalizeDouble(((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point),1);
         }
       else
         {
          ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
          ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
         }*/

      Alert("QQQQ ", MousePrice);
      obj_cre(nameLQP+LineId,(MousePrice),clrPink);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
      tt = NormalizeDouble(get_object(nameLQP+LineId),_Digits)  ;
      
     //  ObjectCreate(objectline,OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],OBJPROP_PRICE1) ;

      ObjectDelete(nameLQPtxt+LineId);
      
     ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,Time[0],tt) ;

      //ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,ti2,tt);
      // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);
      if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLQPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $$ /                lotMG "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else
        {
         znak=1 ;
         ObjectSetString(0, nameLQPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $$ /                lotMG "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }
     }

   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      MousePrice=NormalizeDouble(price,Digits);
      MouseDate=dt;
      //  Alert("move", MousePrice );
      // ObjectSetString(0,"MasIN_MMGT_",OBJPROP_TEXT,"Mouse : "+DoubleToStr(MousePrice,Digits)+" / "+TimeToStr(MouseDate,TIME_DATE|TIME_SECONDS));
      periodmouseover=Period();
     }

  // if(lparam==(StringGetChar("M",0)))  /// qqqq
   if ( ObjectFind(nameLQP+LineId)>=0)
     {
      //  ChartXYToTimePrice(0,int(lparam),int(dparam),window,dt,price);
      // //   MousePrice=NormalizeDouble(price,Digits);
      //  MouseDate=dt;

      //  MousePrice=NormalizeDouble(price,Digits);
      //  MousePrice=MarketInfo(Symbol(),MODE_BID)  ;
      //  MouseDate=dt;
      /*  CalcPosition();

        dLotSize = buy_lots - sell_lots;
        if(buy_lots > sell_lots)
        znak=+1;
      if(buy_lots < sell_lots)
        znak=-1;
      wLotSize = znak*MathAbs(buy_lots-sell_lots) ;
      if(znak !=  0)
        ObjectSetText(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",
                      "Price "+DoubleToString(ObjectGet(prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lin2",OBJPROP_PRICE1),Digits)+
                      " / "+DoubleToString(PipGap/Point,1)
                      +" Pips Away3 Hlot= "+DoubleToString(dLotSize,2)
                      +" Hsuma = "+DoubleToString(((Hprice-buy_avg_price)/_Point*buy_lots*Tick_Value-(Hprice-sell_avg_price)/_Point*sell_lots*Tick_Value)/(buy_lots-sell_lots),8)+"          ",14,"Courier New",clrAqua);

        WindowRedraw();
      //   TextMove(0,prefix+"LPL2_"+Symbol()+"_"+LineId+"_Hedge_Lab2",Time[WindowFirstVisibleBar()/3*2],Hprice);
      */

      PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotMG);
      // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
      ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
      ClickValue=PipValues*((NLoss-ClickPrice)/Point);

      /*if(ClickPrice>MarketInfo(Symbol(),MODE_ASK))
         {
          ClickValue=PipValues*((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point);
          ClickPip=NormalizeDouble(((ClickPrice-MarketInfo(Symbol(),MODE_ASK))/point),1);
         }
       else
         {
          ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
          ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
         }*/

    ///  Alert("QQQ", MousePrice);
      
   double   PipValues3=MarketInfo(_Symbol,MODE_TICKVALUE)/(MarketInfo(_Symbol,MODE_TICKSIZE)/MarketInfo(_Symbol,MODE_POINT)); //cost of point
   double PipValues=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) ;
   double   PipValues4=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
      obj_cre(nameLQP+LineId,(MousePrice),clrPink);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
      tt = NormalizeDouble(get_object(nameLQP+LineId),_Digits)  ;

      ObjectDelete(nameLQPtxt+LineId);
 ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,Time[WindowFirstVisibleBar()/3*2],tt) ;

   //   ObjectCreate(0,nameLQPtxt+LineId,OBJ_TEXT,0,ti2,ti2);
      // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);
      if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLQPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString(znak*kk*(double((-tt+Ask))*lotMG*tval/tsize)+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else   ////
  //     PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   ////   double   ClickValue1=PipValues1*((op-ClickPrice)/point); 
   ///// SYMBOL_TRADE_TICK_VALUE
        {
         znak=1 ;
         ObjectSetString(0, nameLQPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(lotMG,2) + "## EQqq= "+DoubleToString(znak*kk*(double((tt-Bid))*lotMG*tval/tsize)+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }

     }
     
     


   if ((but_stat(prefix+"d50")==true))
     {
     
     int i =0 ;
      for(i=ObjectsTotal() -1; i>=0; i--)
        {
        
         if(StringFind(ObjectName(i),"zz")>-1 )
              {
               ObjectDelete(0,ObjectName(i));
               ObjectDelete(0,ObjectName(i)+"txt");
             }
         }

      /*     SaveSettingsOnDisk();
           MathSrand(GetTickCount() + 2202051901); // Used by CreateInstanceId() in Dialog.mqh (standard library). Keep the second number unique across other panel indicators/EAs.
      if ((!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) || (!MQLInfoInteger(MQL_TRADE_ALLOWED)))
      {
       Alert("AutoTrading is disabled! EA will be not able to perform trading operations!");
       sets.ClosePos = false;
       sets.DeletePend = false;
       sets.DisAuto = false;
       }
           if (!ExtDialog.LoadSettingsFromDisk())
      {
           sets.DisAuto = true;
           }*/
   //   WiewOrdersLine=true*-1;
      ///   Alert("bbnnll");
      // CalcPosition();
      // calcP();;

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();
     }
     
  /*    if((but_stat(prefix+"mNL")==true)) ///  minava ot tuk
     {
   Alert ("  mmmNL  eeee");
      calcC () ;  ///tuk e History   ne se polzva
       // Alert("bbnnll");  /tuk e bnl
     // CalcPosition();
      //  dimi();

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();

      //  handleButtonClicks();
     }
     else
     Alert ("  mmmNL  OFFF");
//
*/
     
     
   if((but_stat(prefix+"bbNL")==true)) ///  minava ot tuk
     {
  // Alert ("  bbNL  eeee");
      calcC () ;  ///tuk e History   ne se polzva
       // Alert("bbnnll");  /tuk e bnl
     // CalcPosition();
      //  dimi();

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();

      //  handleButtonClicks();
     }
//



   if((but_stat(prefix+"CLEAN ALL")==true))
     {

    //  ObjectsDeleteAll();
      button_off(prefix+"CLEAN ALL");
      // tick4();
     }
     // if(sparam=="MasIN_MMGTbox_FollowButton")
   if(lparam==(StringGetChar("F",0)))
     {
      // Alert ("folow" );
      ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
      if(followprice)
        {
         followprice=false;
        }
      else
        {
         followprice=true;
        }
      if(followprice)
        {
         YesNocolor=clrGreen;
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_BORDER_COLOR,YesNocolor);
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
           {
            TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",MarketInfo(Symbol(),MODE_ASK));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK));
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_ASK)-SLPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)-SLPips);
            if(CreateTP)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_ASK)+TPPips);
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_ASK)+TPPips);
              }
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            TPPips=MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",MarketInfo(Symbol(),MODE_BID));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID));
            HLineMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",MarketInfo(Symbol(),MODE_BID)+SLPips);
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)+SLPips);
            if(CreateTP)
              {
               HLineMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",MarketInfo(Symbol(),MODE_BID)-TPPips);
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,MarketInfo(Symbol(),MODE_BID)-TPPips);
              }
           }
        }
      else
        {
         YesNocolor=clrRed;
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_STATE,false);
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_COLOR,YesNocolor);
         ObjectSetInteger(0,"MasIN_MMGTbox_FollowButton",OBJPROP_BORDER_COLOR,YesNocolor);
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
        {
         calculatebuy();
        }
      if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
        {
         calculatesell();
        }


     }
     
      if(id==CHARTEVENT_KEYDOWN)
     {


      if(lparam==(StringGetChar("B",0)))
        {
         //  Alert( "B key " ,BuyLine );
         //OnTick888() ;
        }
      if(lparam==(StringGetChar(BuyLine,0)))
        {
         labelposition = datetime(ObjectGet(sparam,OBJPROP_TIME1));
         labelposition = ti2 ;
         // Alert( "B " ,BuyLine );
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line")>-1)
           {
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label");
           }
         if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Line")>-1)
           {
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Line");
            ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Label");
           }
         //Buy Line
         if(MathMod(MousePrice,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
           {
            MousePrice=MathRound(MousePrice/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
           }
         // labelposition = datetime(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         labelposition = datetime(Time[0]);
         ///
         ///    obj_cre(StringConcatenate(prefix,"88LSSL",tik),MousePrice,clrYellow);

         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line",0,MousePrice,ColorBuySell,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_Buy_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_Buy_Label",DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/Point,1)+" Pips from actual price"+ " Lot " +DoubleToString(Lot,2),10,"Courier New",ColorBuySell);
         //SL Line
         SLprice=MousePrice -(DefaultSL*point);
         PipGap=(SLprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
         HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
         ObjectCreate("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
         ObjectSetText("MasIN_MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),size10,"Courier New",ColorSL);
         //TakeProfit
         //SL Line
         TPprice=MousePrice+(DefaultTP*point);
         if(CreateTP)
           {
            PipGap=(TPprice-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Buy / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),size10,"Courier New",ColorTP);
           }
         if(CreateTP)
           {
            SLPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            TPPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Buy_Line",OBJPROP_PRICE1));
            ratio="1:"+DoubleToString((TPPips/SLPips),1);
           }
         else
           {
            ratio="no TP";
           }

         calculatebuy();
        }
        }

      if(lparam==(StringGetChar("S",0)))
        {
         //    Alert( "S key " ,BuyLine );
         ///OnTick888();

         if(lparam==(StringGetChar(SellLine,0)))
           {
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line")>-1)
              {
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Line");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_TP_Label");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Line");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_SL_Label");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Line");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Buy_Label");
              }
            if(ObjectFind(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Line")>-1)
              {
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Line");
               ObjectDelete(0,"MasIN_MMGT_"+Symbol()+"_Hedge_Label");
              }
            //Sell Line
            if(MathMod(MousePrice,MarketInfo(Symbol(),MODE_TICKSIZE))>0)
              {
               MousePrice=MathRound(MousePrice/MarketInfo(Symbol(),MODE_TICKSIZE))*MarketInfo(Symbol(),MODE_TICKSIZE);
              }
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_Sell_Line",0,MousePrice,ColorBuySell,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_Sell_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_Sell_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
            PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Label",OBJPROP_PRICE1)-MarketInfo(Symbol(),MODE_BID));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_Sell_Label",DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from actual price",10,"Courier New",ColorBuySell+ " Lot " +DoubleToString(Lot,2));
            //SL Line
            SLprice=MousePrice+(DefaultSL*point);
            PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-SLprice);
            HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_SL_Line",0,SLprice,ColorSL,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
            ObjectCreate("MasIN_MMGT_"+Symbol()+"_SL_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_SL_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1));
            ObjectSetText("MasIN_MMGT_"+Symbol()+"_SL_Label","SL at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),size10,"Courier New",ColorSL);
            //TakeProfit
            //SL Line
            TPprice=MousePrice-(DefaultTP*point);
            if(CreateTP)
              {
               PipGap=(ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1)-TPprice);
               HLineCreate(0,"MasIN_MMGT_"+Symbol()+"_TP_Line",0,TPprice,ColorTP,MMLineStyle,MMLinewidth,false,true,false,0,TimeToString(TimeCurrent(),TIME_DATE));
               ObjectCreate("MasIN_MMGT_"+Symbol()+"_TP_Label",OBJ_TEXT,0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
               ObjectMove(0,"MasIN_MMGT_"+Symbol()+"_TP_Label",0,labelposition,ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1));
               ObjectSetText("MasIN_MMGT_"+Symbol()+"_TP_Label","TP at "+DoubleToString(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1),Digits)+" / "+DoubleToString(PipGap/point,1)+" Pips from Sell / "+CurrencyFormat((PipValues*(PipGap/point)),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),size10,"Courier New",ColorTP);
              }
            if(CreateTP)
              {
               SLPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_SL_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               TPPips = MathAbs(ObjectGet("MasIN_MMGT_"+Symbol()+"_TP_Line",OBJPROP_PRICE1)-ObjectGet("MasIN_MMGT_"+Symbol()+"_Sell_Line",OBJPROP_PRICE1));
               ratio="1:"+DoubleToString((TPPips/SLPips),1);
              }
            else
              {
               ratio="no TP";
              }

            calculatesell();
           }
           }
     
  }
  
  
  

///   endOnChartEvent


int calcP()     /// calcpppp
  {
   return (0) ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int calcPN(int mycalMG )     /// calcpppp
  {
   pLot=0;
   pLB=0 ;
   pLS=0 ;
   TLOT=0 ;
   PriceBuyStop=0;
   PriceSellStop=0;
   WiewOrdersLine=ObjectGetInteger(0,"d50",OBJPROP_STATE);
   WiewOrdersLine=true;
   b=0;
   s=0;
   pbs=0;
   pss=0;
   bl=0;
   psl=0;
   OL=0;
   LB=0;
   LS=0;
  double TLB=0;
  double  TLS=0;
   ProfitB=0;
   ProfitS=0 ;
   price_b=0;
   price_s=0;

   /* double  Lot=0,  pLB=0 , pLS=0 , TLOT=0 ,PriceBuyStop=0,PriceSellStop=0;

      int b=0,s=0,pbs=0,pss=0,bl=0,psl=0;
      double OL=0,LB=0,LS=0;
      ProfitB=0;ProfitS=0 ;
      double price_b=0,price_s=0; */
   Psuma =0 ;

//   int OT, TicketBuyStop,TicketSellStop;

///  Vsuma2 -0 ;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(((OrderSymbol()==Symbol()) && (OrderMagicNumber() == mycalMG))  || ((OrderSymbol()==Symbol()) &&(mycalMG ==-1)))
           {
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            OOT = OrderOpenTime();
            Ticket=OrderTicket();
            tip = OrderType();
            OL = OrderLots();
            Psuma +=  OrderProfit()+(OrderCommission()+OrderSwap())*Point; ;
            if(tip==OP_BUY)
              {
               b++;
               LB+=OL;
               price_b+=(Bid-OOP)*OL+(OrderCommission()+OrderSwap())*Point;
               ProfitB+=OrderProfit()+OrderCommission()+OrderSwap();
               if(WiewOrdersLine)
                 {
                  NameLine=StringConcatenate("poziBay, Lot ",DoubleToStr(OL,2),"  Ticket ",DoubleToStr(Ticket,0));
                  ObjectDelete(NameLine);
                  ObjectCreate(NameLine,OBJ_TREND,0,OOT,OOP,Time[0],Bid);
               //   ObjectSetInteger(0,NameLine, OBJPROP_COLOR,clrYellow);  ///tuk 
                 }
              }
            if(tip==OP_SELL)
              {
               s++;
               LS+=OL;
               price_s+=(OOP-Ask)*OL+(OrderCommission()+OrderSwap())*Point;
               ProfitS+=OrderProfit()+OrderCommission()+OrderSwap();
               if(WiewOrdersLine)
                 {
                  NameLine=StringConcatenate("poziSell, Lot ",DoubleToStr(OL,2),"  Ticket ",DoubleToStr(Ticket,0));
                  ObjectDelete(NameLine);
                  ObjectCreate(NameLine,OBJ_TREND,0,OOT,OOP,Time[0],Ask);
             //     ObjectSetInteger(0,NameLine, OBJPROP_COLOR,Color4);
                 }
              }
           if(WiewOrdersLine)
            if(ObjectGetInteger(0,prefix+"2NL",OBJPROP_STATE)==true)
              {
               ObjectSetInteger(0,NameLine, OBJPROP_STYLE, STYLE_DOT);
               ObjectSetInteger(0,NameLine,OBJPROP_COLOR,clrNONE);
               ObjectSetInteger(0,NameLine, OBJPROP_RAY,   false);
               ObjectSetInteger(0,NameLine,OBJPROP_SELECTABLE,false);
               ObjectSetInteger(0,NameLine,OBJPROP_SELECTED,false);
               ObjectSetInteger(0,NameLine,OBJPROP_HIDDEN,true);
             //  WiewOrdersLine = false ;
              }
            if(tip==OP_BUYLIMIT || tip==OP_BUYSTOP)
              {
               pLB+=OrderLots();
              }
            if(tip==OP_SELLLIMIT || tip==OP_SELLSTOP)
              {
               pLS+=OrderLots();
              }


           }
          
        }



      //   Vsuma2 = ProfitB+ProfitS+ сегодня ;
      //   Comment("del  ",  NLL);
     // WiewOrdersLine = WiewOrdersLine*-1;
    //  if(!WiewOrdersLine)
    
       
    
    
      if (ObjectGetInteger(0,prefix+"2NL",OBJPROP_STATE)==false)
        {

            //calcC () ;

         ObjectsDeleteAll(0,"pozi",0, OBJ_TREND);
         //   Comment("del pozi ",  NLL);
        }
     }  ///lotMG =LB-LS;
   SumMG  = Psuma ;
//   double NL=0,NLb=0,NLs=0,  NL750loss=0,NL750p=0 ;
   if(ObjectGetInteger(0,prefix+"bbNL",OBJPROP_STATE))
     {

      if(LB>0)
         NLb=Bid-price_b/LB;
      ARROW("cm__NoLoss_NLb", NLb, 6, clrAqua);
      if(LS>0)
         NLs=Ask+price_s/LS;
      ARROW("cm__NoLoss_NLs", NLs, 6, clrRed);
      if(LB-LS>0)
        {
         NLoss=Bid-(price_b+price_s)/(LB-LS);
         //  if (ProfitB != 0 ) NL750p = Bid-((price_b*Vsuma2)/ProfitB)/(LB-LS);
         //  if (ProfitS != 0 ) NL750loss =   Ask+((price_s*Vsuma2)/ProfitS)/(LB-LS);
         NL750p =Bid+ ((Vsuma2))/(LB-LS)/csize;
         NL750loss =Bid- ((Vsuma2))/(LB-LS)/csize;
         // NL750p =Bid+ ((Vsuma2))/LSize;
         //  NL750loss =Bid- ((Vsuma2))/LSize;
         // NL750loss =   Bid-((price_s+Vsuma2)/ProfitS)/(LB-LS);
        }
      if(LB-LS<0)
        {
         NLoss=Ask-(price_b+price_s)/(LB-LS);
         // if (ProfitS != 0 )  NL750loss = Ask+((price_s*Vsuma2)/ProfitS)/(LB-LS);
         // if (ProfitB != 0 ) NL750p = Bid-((price_b*Vsuma2)/ProfitB)/(LB-LS);
         NL750p = Ask+((Vsuma2))/(LB-LS)/csize;
         NL750loss =Ask- ((Vsuma2))/(LB-LS)/csize;
        }

      ARROW("cm__NoLoss_NL", NLoss, 6, clrYellow);

      ARROW("cm__+750p", NL750p, 6, clrWhite);

      ARROW("cm__-750l", NL750loss, 6, clrMagenta);


      OL=0 ;
      ///     double dLB=0,dLS=0,dProfitB=0,dProfitS=0, LNL=0  ,difflot=0 , diffL =0,  diffb =0, diffs=0 ;
      //      double dprice_b=0,dprice_s=0;
      dLB=0;
      dLS=0;
      dProfitB=0;
      dProfitS=0;
      LNL=0  ;
      difflot=0 ;
      diffL =0;
      diffb =0;
      diffs=0 ;
      dprice_b=0;
      dprice_s=0;


      if(LB-LS>0)
        {
         difflot= LB-LS ;
         diffb= difflot ;
        }
      if(LB-LS<0)
        {
         difflot= LS-LB ;
         diffs= difflot ;
        }
         
         

  

      ///    ARROW("cm__+750p", NL750p, 6, clrMagenta);
      // ObjectDelete(NameLine);
      if (ObjectFind("cm__Vsuma_p")<0)
           {
               ObjectCreate("cm__Vsuma_p",OBJ_HLINE,0,Time[10],NL750p,Time[0],NL750p);
               ObjectSetString(0,"cm__Vsuma_p",OBJPROP_TOOLTIP,DoubleToString(accEQ+Vsuma2,2)+" USD");
           ObjectSetInteger(0,"cm__Vsuma_p", OBJPROP_STYLE,STYLE_DOT); 
               ObjectSetInteger(0,"cm__Vsuma_p", OBJPROP_COLOR,Color3); 
               }
       if (ObjectFind("cm__Vsuma_loss")<0)
           {
               ObjectCreate("cm__Vsuma_loss",OBJ_HLINE,0,Time[10],NL750loss,Time[0],NL750loss);
               ObjectSetString(0,"cm__Vsuma_loss",OBJPROP_TOOLTIP,DoubleToString(accEQ-Vsuma2,2)+" USD");
               ObjectSetInteger(0,"cm__Vsuma_loss", OBJPROP_STYLE,DRAW_SECTION ); 
                   ObjectSetInteger(0,"cm__Vsuma_loss", OBJPROP_STYLE,STYLE_DOT); 
               ObjectSetInteger(0,"cm__Vsuma_loss", OBJPROP_COLOR,Color4); 
               }
               
               if (ObjectFind("cm__Vsuma_NLoss")<0)
           {
               ObjectCreate("cm__Vsuma_NLoss",OBJ_HLINE,0,Time[10],NLoss,Time[0],NLoss);
               ObjectSetString(0,"cm__Vsuma_NLoss",OBJPROP_TOOLTIP,DoubleToString(accEQ+(ProfitB-ProfitS),2)+" USD");
               ObjectSetInteger(0,"cm__Vsuma_NLoss", OBJPROP_STYLE,DRAW_SECTION ); 
                   ObjectSetInteger(0,"cm__Vsuma_NLoss", OBJPROP_STYLE,STYLE_DOT); 
               ObjectSetInteger(0,"cm__Vsuma_NLoss", OBJPROP_COLOR,clrYellow); 
               }
      // LabelCreate(0    ,"cm__Vsuma" ,0 ,X+520,Y+92,CORNER_LEFT_UPPER,StringConcatenate("Buy ",DoubleToStr(TLOT,2)),Font,Width+0,Color1,0,ANCHOR_CENTER,false,false,true,0);
      //      ARROW("cm__+750p5", NL750p, , clrBeige);
      //     ARROW("cm__+750p4", NL750p, 7, clrGreen);
      ///  ARROW("cm__-750l", NL750loss, 6, clrWhite);



     }
   else
     {

      ObjectDelete("cm__Vsuma_p");
       ObjectDelete("cm__Vsuma_loss");
        ObjectDelete("cm__Vsuma_NLoss");


      ObjectDelete(0,"cm__NoLoss_NLb");
      ObjectDelete(0,"cm__NoLoss_NLs");
      ObjectDelete(0,"cm__NoLoss_NL");
      ObjectDelete(0,"cm__+750p");
      ObjectDelete(0,"cm__-750l");
      ObjectDelete(0,"cm__NoLoss_LNL");

      //        ObjectDelete(0,"cm__kn ProfitB");
      // ObjectDelete(0,"cm__kn ProfitS");
      // ObjectDelete(0,"cm__kn Profit");

      // ObjectDelete(0,"cm__kn price_b");
      //   ObjectDelete(0,"cm__kn price_S");
      // ObjectDelete(0,"cm__kn TLOT");

      // ObjectDelete(0,"cm__kn TLOT");
     }
     
     
      if   ((totorders != OrdersTotal())  || ( LB != LS) )    //  TUKA E razlika v lota i notification main !!!
        {
         
         for(i= OrdersTotal(); i>0 ; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol()==Symbol())
                 {
                  OOP = NormalizeDouble(OrderOpenPrice(),Digits);
                  OOT = OrderOpenTime();
                  Ticket=OrderTicket();
                  tip = OrderType();
                  OL = OrderLots();
                  
                  if(tip==OP_BUY)
                   TLB+=OL;
                  if(tip==OP_BUY &&  diffb > 0)
                    {
                     if(diffb > OL)
                       {
                        // b++;
                        dLB+=OL;
                        dprice_b+=(Bid-OOP)*OL+(OrderCommission()+OrderSwap())*Point;
                        diffb = diffb -OL;
                       }
                     else
                       {
                        dLB+=OL;
                        dprice_b+=(Bid-OOP)*diffb+(OrderCommission()+OrderSwap())*Point;
                        LNL=Bid  - ((dprice_b)/ diffL)  ;  //// ;
                        diffb = diffb -diffb;
                        break;
                       }
                    }
                    if(tip==OP_SELL)
                   TLS+=OL;
                  if(tip==OP_SELL  &&  diffs>0)
                    {
                     if(diffs > OL)
                       {
                        //  s++;
                        dLS+=OL;
                        dprice_s+=(OOP-Ask)*OL+(OrderCommission()+OrderSwap())*Point;
                        diffs = diffs -OL;
                       }
                     else
                       {
                        dLS+=OL;
                        dprice_s+=(OOP-Ask)*diffs+(OrderCommission()+OrderSwap())*Point;
                        LNL=Ask + ((dprice_s) / diffL);      /// diffL  ;
                        diffs = diffs -diffs;
                        break;
                       }

                    }
                 }
              }
           }
           
           diffL = difflot ;   ///  OrderCloseBy(order_id,opposite_id);  array
         if ((notification == true) &&  (totorders != OrdersTotal()) )
            SendNotification(Symbol() +" buy "+ DoubleToString(LB,2)+ " sell " +DoubleToString(LS,2)+
                             " raz all" + DoubleToString((TLB-TLS),2)
                             +" Sum all="+ DoubleToString (SumMG2,2)
                             +" MG all="+IntegerToString(calMG2)
                             +" EQ " +DoubleToString(AccountEquity(),2)
                             +"   MG="+IntegerToString(calMG)
                             +"  lot MG="+DoubleToString( (LB-LS),2)
                             +" SumMG="+ DoubleToString (SumMG,2)) ;
         totorders = OrdersTotal() ;
         //     ARROW("cm__NoLoss_LNL1", LNL, 5, Color5);
           
         ARROW("cm__NoLoss_LNL", LNL, 5, clrLime);  ///  nulata na razlikata
        }
     
//  Vsuma2 = ProfitB+ProfitS+ сегодня ;
   return (0) ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trademenu22()
  {
   if(ObjectFind(0,prefix+"TradeLine")!=0)
      ButtonCreate(0,"TradeLine",0,1600,350,90,16,0,"----MENU------","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,true);
//  ButtonCreate(0,"TradeLine",0,1400,350,90,16,0,"----MENU------","Arial",10,clrBlack,C'236,233,216',colorframe,false,false,true,true,0,"Move ");

   int x0=(int)IntGetX("TradeLine");
   int y0=(int)IntGetY("TradeLine");

//  Lot=0.10;
   int   xx=1300, yy=CORNER_RIGHT_UPPER+20, lo =80;

   ButtonCreate(0,"CLEAN",0,CORNER_RIGHT_UPPER+400,CORNER_RIGHT_UPPER,90,16,0,"CLEAN H "+DoubleToStr(Hedge,2),"Arial",Width,clrBlack,C'236,233,216');

   ButtonCreate(0,"CLEAN ALL",0,CORNER_RIGHT_UPPER+600,CORNER_RIGHT_UPPER,90,16,0,"CLEAN ALL "+DoubleToStr(Vsuma2,2),"Arial",Width,clrBlack,C'236,233,216');


   ButtonCreate(0,"d50",0,CORNER_RIGHT_UPPER+500,CORNER_RIGHT_UPPER,90,16,0,"d50","Arial",Width,clrBlack,C'236,233,216');
  
  
 
  if(ObjectFind("Vsuma")==-1)
      EditCreate(0,"Vsuma",0,CORNER_RIGHT_UPPER+900,0,lo,16,DoubleToString(Vsuma,0),"Arial",8,ALIGN_CENTER,false);
   Vsuma = StringToDouble(ObjectGetString(0,"Vsuma",OBJPROP_TEXT));
    ButtonCreateR(0,"lock h2",0,CORNER_RIGHT_UPPER+800,0,lo,16,0,"lock h2","Arial",Width,clrBlack,C'236,233,216');

   // ButtonCreateR(0,"lock H",0,CORNER_RIGHT_UPPER+800,lo,16,0,"lock H","Arial",Width,clrBlack,C'236,233,216');
//  ButtonCreate(0,"CLEAN ALL",0,CORNER_RIGHT_UPPER+600,CORNER_RIGHT_UPPER,90,16,0,"CLEAN ALL "+DoubleToStr(Hedge,2),"Arial",Width,clrBlack,C'236,233,216');
// if  ((but_stat(prefix+"bNL")==true) )
     {
      // Alert("bnl");
      ///   calcP();
      ///   WindowRedraw();
      //  button_off(prefix+"CLEAN ALL");
      // tick4();
     }
//

  ButtonCreateR(0,"bNL",0,CORNER_RIGHT_UPPER+xx,0,lo,16,0,"bNL","Arial",Width,clrBlack,C'236,233,216');
//  ButtonCreate(0,"CLEAN ALL",0,CORNER_RIGHT_UPPER+600,CORNER_RIGHT_UPPER,90,16,0,"CLEAN ALL "+DoubleToStr(Hedge,2),"Arial",Width,clrBlack,C'236,233,216');
// if  ((but_stat(prefix+"bNL")==true) )
     {
      // Alert("bnl");
      ///   calcP();
      ///   WindowRedraw();
      //  button_off(prefix+"CLEAN ALL");
      // tick4();
     }
//

  if(ObjectFind("Vsuma2")==-1)
      EditCreate(0,"Vsuma2",0,CORNER_RIGHT_UPPER+xx+200,0,lo,16,DoubleToString(Vsuma2,0),"Arial",8,ALIGN_CENTER,false);
   Vsuma2 = StringToDouble(ObjectGetString(0,"Vsuma2",OBJPROP_TEXT));


   LabelCreate(0,"labTP",0,xx-20,yy+80,CORNER_LEFT_UPPER,"TP","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("TakeProfit")==-1)
      EditCreate(0,"TakeProfit",0,CORNER_RIGHT_UPPER+xx,yy+80,lo,16,DoubleToString(TakeProfit,0),"Arial",8,ALIGN_CENTER,false);
   TakeProfit = StringToDouble(ObjectGetString(0,"TakeProfit",OBJPROP_TEXT));


   LabelCreate(0,"labSL",0,xx-20,yy+100,CORNER_LEFT_UPPER,"SL","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("StopLoss")==-1)
      EditCreate(0,"StopLoss",0,CORNER_RIGHT_UPPER+xx,yy+100,lo,16,DoubleToString(StopLoss,0),"Arial",8,ALIGN_CENTER,false);
   StopLoss = StringToDouble(ObjectGetString(0,"StopLoss",OBJPROP_TEXT));
//SL= NormalizeDouble(StopLoss,_Digits);
//  if (ObjectFind("koef")==-1)
///EditCreate(0,"koef",0,CORNER_RIGHT_UPPER+xx,yy+120,lo,16,DoubleToString(koef,2),"Arial",8,ALIGN_CENTER,false);
////koef = StringToDouble(ObjectGetString(0,"koef",OBJPROP_TEXT));

   LabelCreate(0,"labTR",0,xx-20,yy+120,CORNER_LEFT_UPPER,"TR","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("TR")==-1)
      EditCreate(0,"TR",0,CORNER_RIGHT_UPPER+xx,yy+120,lo,16,DoubleToString(TralingStop,0),"Arial",8,ALIGN_CENTER,false);
   TralingStop = StringToDouble(ObjectGetString(0,"TR",OBJPROP_TEXT));


///LabelCreate(0,"inSN",0,CORNER_RIGHT_UPPER+150,CORNER_RIGHT_UPPER+140,80,16,DoubleToString(inSN,0),"Arial",8,ALIGN_CENTER,false);

// LabelCreate(0,StringConcatenate("labSN",OrderTicket()),0,x2+295,y2,CORNER_LEFT_UPPER,DoubleToString( OrderMagicNumber(),0)+"","Arial",10,clrBeige,0,ANCHOR_LEFT_UPPER);

   LabelCreate(0,StringConcatenate("labSN",OrderTicket()),0,xx-20,yy+140,CORNER_LEFT_UPPER,"SN","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("inSN")==-1)
      EditCreate(0,"inSN",0,CORNER_RIGHT_UPPER+xx,yy+140,lo,16,DoubleToString(inSN,0),"Arial",8,ALIGN_CENTER,false);
   inSN = StringToDouble(ObjectGetString(0,"inSN",OBJPROP_TEXT));

   LabelCreate(0,StringConcatenate("labTH",OrderTicket()),0,xx-30,yy+160,CORNER_LEFT_UPPER,"TH $","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("Hedge")==-1)
      EditCreate(0,"Hedge",0,CORNER_RIGHT_UPPER+xx,yy+160,lo,16,DoubleToString(Hedge,0),"Arial",8,ALIGN_CENTER,false);
   Hedge = StringToDouble(ObjectGetString(0,"Hedge",OBJPROP_TEXT));


   LabelCreate(0,"labRisk",0,xx-30,yy+60,CORNER_LEFT_UPPER,"Risk","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("risksuma")==-1)
      EditCreate(0,"risksuma",0,CORNER_RIGHT_UPPER+xx,yy+60,lo,16,DoubleToString(risksuma,0),"Arial",8,ALIGN_CENTER,false);
   risksuma = StringToDouble(ObjectGetString(0,"risksuma",OBJPROP_TEXT));
//  Hedge =  risksuma/MarketInfo(Symbol(),MODE_TICKVALUE)* Lot ; //MarketInfo(Symbol(),MODE_TICKVALUE)/100 ;


   if(ObjectFind("Vsuma")==-1)
      EditCreate(0,"Vsuma",0,CORNER_RIGHT_UPPER+xx,yy+180,lo,16,DoubleToString(Vsuma,0),"Arial",8,ALIGN_CENTER,false);
   Vsuma = StringToDouble(ObjectGetString(0,"Vsuma",OBJPROP_TEXT));

    // accEQ  = AccountInfoDouble(ACCOUNT_EQUITY);

   LabelCreate(0,StringConcatenate("labVEQ",OrderTicket()),0,xx-90,yy+200,CORNER_LEFT_UPPER,DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2)+"EQ","Arial",10,clrBeige,0,ANCHOR_LEFT_UPPER);

   if(ObjectFind("VEQ")==-1)
      EditCreate(0,"VEQ",0,CORNER_RIGHT_UPPER+xx,yy+200,lo,16,DoubleToString(VEQ,0),"Arial",8,ALIGN_CENTER,false);
   VEQ = StringToDouble(ObjectGetString(0,"VEQ",OBJPROP_TEXT));

   if((VEQ -Vsuma > (AccountInfoDouble(ACCOUNT_EQUITY))) ||(VEQ +Vsuma < (AccountInfoDouble(ACCOUNT_EQUITY))))
      if(mynotification == true)
        {
         VEQ = (AccountInfoDouble(ACCOUNT_EQUITY)) ;
         ObjectDelete(StringConcatenate("VEQ")) ;

         EditCreate(0,"VEQ",0,CORNER_RIGHT_UPPER+xx,yy+200,lo,16,DoubleToString(VEQ,0),"Arial",8,ALIGN_CENTER,false);

         SendNotification(Symbol()+" = "+DoubleToString(lotMG,2) +" V "+ DoubleToString(Vsuma,2)+ " EQ " +DoubleToString(AccountEquity(),2)) ;

         //  SendNotification ( Symbol() +" buy "+ DoubleToString(LB,2)+ " sell " +DoubleToString(LS,2)+
         //  " raz " + DoubleToString((LB-LS),2)+" EQ " +DoubleToString(AccountEquity(),2 ) ) ;
        }



   ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",Width,clrBlack,C'236,233,216'); ///+DoubleToStr(glot,2)



   if(ObjectFind("Lot1")==-1)
      EditCreate(0,"Lot1",0,CORNER_RIGHT_UPPER+xx,yy,lo,16,DoubleToString(glot,2),"Arial",8,ALIGN_CENTER,false);


// EditCreate(0,"Lot1",0,x0+40,y0+14,60,16,DoubleToString(glot,2),"Arial",8,ALIGN_RIGHT,false);
//  ObjectSetText("Lot2"+ CurrencyFormat(double(OrderTakeProfit()),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",clrBeige);
//   TextCreate(0,"Lot3",0,ti2,ss, DoubleToStr(OrderLots(),2)  ,"Arial",10,OrderLots()<0? clrYellowGreen:clrWhiteSmoke);

   Lot=StringToDouble(ObjectGetString(0,"Lot1",OBJPROP_TEXT));
   glot=Lot;

   LabelCreate(0,"labMAG1",0,xx-70,yy+20,CORNER_LEFT_UPPER,"open MG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("MAG1")==-1)
      EditCreate(0,"MAG1",0,CORNER_RIGHT_UPPER+xx,yy+20,lo,16,DoubleToString(Magic,0),"Arial",8,ALIGN_CENTER,false);
   Magic=  StringToDouble(ObjectGetString(0,"MAG1",OBJPROP_TEXT));

   LabelCreate(0,"labMAG2",0,xx-90,yy+40,CORNER_LEFT_UPPER,"manage MG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
   if(ObjectFind("MAG2")==-1)
      EditCreate(0,"MAG2",0,CORNER_RIGHT_UPPER+xx,yy+40,lo,16,DoubleToString(MagicALL,0),"Arial",8,ALIGN_CENTER,false);
   MagicALL=  StringToDouble(ObjectGetString(0,"MAG2",OBJPROP_TEXT));





/////         errrr }
//  Alert( "lot  "+ i + "  " +DoubleToString( LB,2 )+ " " +DoubleToString( LS,2 )+ " " +DoubleToString( lotMG,2 ));
   obj_del("lotMG");
   if(ObjectFind("lotMG")==-1)
     {
      //  EditCreate(0,"lotMG",0,CORNER_RIGHT_UPPER+xx,yy+240,lo,16,DoubleToString(lotMG,2),"Arial",8,ALIGN_CENTER,false);

      EditCreate(0,"lotMG",0,x0,y0+204,90,16,DoubleToString(lotMG,2),"Arial",8,ALIGN_CENTER,false);

      // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
     }
   obj_del("SumMG");
   if(ObjectFind("SumMG")==-1)
     {
      //   EditCreate(0,"SumMG",0,CORNER_RIGHT_UPPER+xx,yy+260,lo,16,DoubleToString(SumMG,2),"Arial",8,ALIGN_CENTER,false);
      // ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",Width,clrBlack,C'236,233,216'); ///+DoubleToStr(glot,2)

      EditCreate(0,"SumMG",0,x0,y0+244,90,16,DoubleToString(SumMG,2),"Arial",8,ALIGN_CENTER,false);


      // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
     }

///  LabelCreate(0,StringConcatenate("calMG",OrderTicket()),0,xx-40,yy+120,CORNER_LEFT_UPPER,"CalMG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
// calMG = savecalMG ;
//// calMG = StringToDouble(ObjectGetString(0,"MAG1",OBJPROP_TEXT));
// obj_del("calMG");
   LabelCreate(0,StringConcatenate("textcalMG",OrderTicket()),0,x0-150,y0-110,CORNER_LEFT_UPPER,"CalMG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);

   if(ObjectFind("calMG")==-1)

      EditCreate(0,"calMG",0,x0-100,y0-110,90,16,DoubleToString(calMG,0),"Arial",8,ALIGN_CENTER,false);
   calMG = StringToDouble(ObjectGetString(0,"calMG",OBJPROP_TEXT));
//  savecalMG = calMG ;
//  ObjectFind("calMG");
// ObjectSetDouble( 0,"calMG",OBJPROP_PRICE, calMG);

// calMG = 4 ;
   LB=0;
   LS=0;
   calcP();
   lotMG= LB-LS ;

   WindowRedraw();






   ButtonCreateR(0,"Lock",0,CORNER_RIGHT_UPPER+xx,CORNER_RIGHT_UPPER+yy+280,lo,16,0,"Lock","Arial",Width,clrBlack,C'236,233,216');

   if(but_stat(prefix+"Lock")==true)
     {
      if(lotMG > 0)
         OrderSend(Symbol(),OP_SELL, MathAbs(lotMG),Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrRed) ;
      if(lotMG < 0)
         OrderSend(Symbol(),OP_BUY, MathAbs(lotMG),Ask,50,0,0,StringConcatenate("Lock B",tik),Magic,0,clrRed) ;
      button_off("Lock");
     }
   int x4=(int)IntGetX("Lots");
   int y4=(int)IntGetY("Lots");
   ButtonCreate(0,"Buy",0,x0,y0+34,90,16,0,"BUY","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"Sel",0,x0,y0+54,90,16,0,"SELL","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"BuyL",0,x0,y0+74,90,16,0,"BUY LIMIT","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"SelL",0,x0,y0+94,90,16,0,"SELL LIMIT","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"BuyS",0,x0,y0+114,90,16,0,"BUY STOP","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"SelS",0,x0,y0+134,90,16,0,"SELL STOP","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"ScreenShot",0,x0,y0+154,90,16,0,"SCREENSHOT","Arial",Width,clrBlack,C'236,233,216');
   ButtonCreate(0,"TimeT",0,x0,y0+174,90,16,0,"Time","Arial",Width,clrBlack,C'236,233,216');
   WindowRedraw();
//ChartRedraw(0);

   double Dist=NormalizeDouble(Stop_Limit*_Point,_Digits);
   if(but_stat(prefix+"Buy")==true)
      if(openorders(_Symbol,0,glot)==true)
         button_off("Buy");
//   if(but_stat(nameSL)==false)
   /*                       {      nameSL=StringConcatenate(prefix,"SL",tik);
     nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);
               ////        button_on(nameSL); // (nameSL)=true ;


                          }   */
   if(but_stat(prefix+"Sel")==true)
      if(openorders(_Symbol,1,glot)==true)
         button_off("Sel");

   nameSL= ObjectSetInteger(0,StringConcatenate(prefix,"SL",tik),OBJPROP_STATE,true);
   button_on(nameSL);

// button_on("SL");
//   if(but_stat(nameSL)==false)
//                         {    nameSL=StringConcatenate(prefix,"SL",tik);
//   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);

//                          }
   if(but_stat(prefix+"BuyL")==true)
      if(openorders(_Symbol,2,glot,Ask-Dist)==true)
         button_off("BuyL");
   if(but_stat(prefix+"SelL")==true)
      if(openorders(_Symbol,3,glot,Bid+Dist)==true)
         button_off("SelL");
   if(but_stat(prefix+"BuyS")==true)
      if(openorders(_Symbol,4,glot,Ask+Dist)==true)
         button_off("BuyS");
   if(but_stat(prefix+"SelS")==true)
      if(openorders(_Symbol,5,glot,Bid-Dist)==true)
         button_off("SelS");



   if(but_stat(prefix+"TimeT")==true)
      tim();
   else
      obj_del("clock");

   /*    if  ((but_stat(prefix+"CLEAN ALL")==true) )
            {

                   ObjectsDeleteAll();
            button_off(prefix+"CLEAN ALL");
          // tick4();
            }

   if  ((but_stat(prefix+"bNL")==true) )
            {// ObjectsDeleteAll();
           // calcP();
                 //
                // but_stat(prefix+"bNL")=false ;
           // button_off(prefix+"bNL");
          // tick4();
            }*/
  }
//+------------------------------------------------------------------+





void dimi2()
{  
  int tik=-1,typ=-1;
// Comment("    dimi2    \n", NL);
   HM1 =(iHigh(Symbol(), PERIOD_M1,1));
   LM1 = (iLow(Symbol(), PERIOD_M1,1)) ;
    HM15 =(iHigh(Symbol(), PERIOD_M1,15));
   LM15 = (iLow(Symbol(), PERIOD_M1,15)) ;
     HM5 =(iHigh(Symbol(), PERIOD_M1,5));
   LM5 = (iLow(Symbol(), PERIOD_M1,5)) ;
   ATR5 =(iATR(Symbol(), PERIOD_M5,14,0));
   ATR15 = (iATR(Symbol(), PERIOD_M15,14,0)) ;
   
    HM1 =(iHigh(Symbol(), PERIOD_M1,1));
   LM1 = (iLow(Symbol(), PERIOD_M1,1)) ;
   double midM1 =(iHigh(Symbol(), PERIOD_M1,1)+iLow(Symbol(), PERIOD_M1,1))/2;
   double midM5 =(iHigh(Symbol(), PERIOD_M5,1)+iLow(Symbol(), PERIOD_M5,1))/2;
   double midM15 =(iHigh(Symbol(), PERIOD_M15,1)+iLow(Symbol(), PERIOD_M15,1))/2;
   double midH1 =(iHigh(Symbol(), PERIOD_H1,1)+iLow(Symbol(), PERIOD_H1,1))/2;
   double midD1 =(iHigh(Symbol(), PERIOD_D1,1)+iLow(Symbol(), PERIOD_D1,1))/2;
   double midD0 =(iHigh(Symbol(), PERIOD_D1,0)+iLow(Symbol(), PERIOD_D1,0))/2;
   double midD2 =(iHigh(Symbol(), PERIOD_D1,2)+iLow(Symbol(), PERIOD_D1,2))/2;
   double D0High =(iHigh(Symbol(), PERIOD_D1,0));
   double D0Low =(iLow(Symbol(), PERIOD_D1,0));
   double H0High =(iHigh(Symbol(), PERIOD_H1,0));
   double H0Low =(iLow(Symbol(), PERIOD_H1,0));
   double H1High =(iHigh(Symbol(), PERIOD_H1,1));
   double H1Low =(iLow(Symbol(), PERIOD_H1,1));
   double H2High =(iHigh(Symbol(), PERIOD_H1,2));
   double H2Low =(iLow(Symbol(), PERIOD_H1,2));
   double M50High =(iHigh(Symbol(), PERIOD_M5,0));
   double M50Low =(iLow(Symbol(), PERIOD_M5,0));
   double M150High =(iHigh(Symbol(), PERIOD_M15,0));
   double M150Low =(iLow(Symbol(), PERIOD_M15,0));
   double M151High =(iHigh(Symbol(), PERIOD_M15,1));
   double M151Low =(iLow(Symbol(), PERIOD_M15,1));
   double D1High =(iHigh(Symbol(), PERIOD_D1,1));
   double D1Low =(iLow(Symbol(), PERIOD_D1,1));
   double D2High =(iHigh(Symbol(), PERIOD_D1,2));
   double D2Low =(iLow(Symbol(), PERIOD_D1,2));
   double W1High =(iHigh(Symbol(), PERIOD_W1,1));
   double W1Low =(iLow(Symbol(), PERIOD_W1,1));
   double W0High =(iHigh(Symbol(), PERIOD_W1,0));
   double W0Low =(iLow(Symbol(), PERIOD_W1,0));
   double H4High =(iHigh(Symbol(), PERIOD_H4,1));
   double H4Low =(iLow(Symbol(), PERIOD_H4,1));
   double H1Open =(iOpen(Symbol(), PERIOD_H1,1));
   double H1Close =(iClose(Symbol(), PERIOD_H1,1));
   double H4Open =(iOpen(Symbol(), PERIOD_H4,1));
   double H4Close =(iClose(Symbol(), PERIOD_H4,1));
   double WorkTime = 0;
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES );//BARS ); //CANDLES); 
   

   double midM5MA = iMA(NULL,0,13,8,MODE_SMMA,PRICE_MEDIAN,1);
   double midM15MA = iMA(NULL,PERIOD_M15,13,8,MODE_SMMA,PRICE_MEDIAN,1);
// double midM15MA =(iMA(Symbol(), PERIOD_M15,1)+iMA(Symbol(), PERIOD_M15,1))/2;
///Alert ("Test m15  " , DoubleToString( midM15,2) );  ///m15
   double  tik5 = 1111 ;

   if((but_stat(prefix+"d50")==false)
//   &&  ( tik== OrderTicket() )
     )
     {
      ObjectDelete(StringConcatenate("W1High",tik5)) ;
      TrendCreate(0,StringConcatenate("W1High",tik5),0,Time[100],W1High,Time[0]+PERIOD_W1*3,W1High,clrRed,STYLE_DASH,1);
     // ObjectSetInteger(0,"W1High"+Symbol()+"_DO_label",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS,EMPTY);
     // LabelCreate(0,StringConcatenate("W1High"),0,Time[110],Time[0]+PERIOD_D1*3,CORNER_LEFT_UPPER,"w1","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);

        //          LabelCreate(0,"W1High",0,Time[110],Time[0]+PERIOD_D1*4,CORNER_LEFT_UPPER,CORNER_LEFT_UPPER,"w1w1","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
                
  //     ObjectSetInteger(0,StringConcatenate("W1High",tik5),OBJPROP_COLOR,clrPink);
      ObjectDelete(StringConcatenate("W1Low",tik5)) ;
      TrendCreate(0,StringConcatenate("W1Low",tik5),0,Time[100],W1Low,Time[0]+PERIOD_W1*3,W1Low,clrRed,STYLE_DASH,1);
     
     ObjectDelete(StringConcatenate("W0High",tik5)) ;
      TrendCreate(0,StringConcatenate("W0High",tik5),0,Time[100],W0High,Time[0]+PERIOD_W1*3,W0High,clrYellow,STYLE_DASH,1);
      ObjectDelete(StringConcatenate("W0Low",tik5)) ;
      TrendCreate(0,StringConcatenate("W0Low",tik5),0,Time[100],W0Low,Time[0]+PERIOD_W1*3,W0Low,clrYellow,STYLE_DASH,1);


      ObjectDelete(StringConcatenate("D0High",tik5)) ;
      TrendCreate(0,StringConcatenate("D0High",tik5),0,Time[100],D0High,Time[0]+PERIOD_D1*3,D0High,clrOrange,STYLE_DASH,1);
      ObjectDelete(StringConcatenate("D0Low",tik5)) ;
      TrendCreate(0,StringConcatenate("D0Low",tik5),0,Time[100],D0Low,Time[0]+PERIOD_D1*3,D0Low,clrOrange,STYLE_DASH,1);

      ObjectDelete(StringConcatenate("M5bar",tik5)) ;
      TrendCreate(0,StringConcatenate("M5bar",tik5),0,Time[0]+PERIOD_D1*6.4,M50Low,Time[0]+PERIOD_D1*6.4,M50High,clrYellow,STYLE_DASH,2);
      ObjectDelete(StringConcatenate("M150bar",tik5)) ;
      TrendCreate(0,StringConcatenate("M150bar",tik5),0,Time[0]+PERIOD_D1*5.8,M150Low,Time[0]+PERIOD_D1*5.8,M150High,clrLime,STYLE_DASH,2);
      ObjectDelete(StringConcatenate("M151bar",tik5)) ;
      TrendCreate(0,StringConcatenate("M151bar",tik5),0,Time[0]+PERIOD_D1*5,M151Low,Time[0]+PERIOD_D1*5,M151High,clrLime,STYLE_DASH,4);
      ObjectDelete(StringConcatenate("H0bar",tik5)) ;
      TrendCreate(0,StringConcatenate("H0bar",tik5),0,Time[0]+PERIOD_D1*4.4,H0Low,Time[0]+PERIOD_D1*4.4,H0High,clrRed,STYLE_DASH,2);
      ObjectDelete(StringConcatenate("H1bar",tik5)) ;
       if (H4Open < H4Close ) 
      TrendCreate(0,StringConcatenate("H1bar",tik5),0,Time[0]+PERIOD_D1*3.2,H1Low,Time[0]+PERIOD_D1*3.8,H1High,clrRed,STYLE_DASH,4);
       else
        TrendCreate(0,StringConcatenate("H1bar",tik5),0,Time[0]+PERIOD_D1*3.8,H1Low,Time[0]+PERIOD_D1*3.2,H1High,clrRed,STYLE_DASH,4);
     
      ObjectDelete(StringConcatenate("H2bar",tik5)) ;
      TrendCreate(0,StringConcatenate("H2bar",tik5),0,TimeCurrent()+1*3*55*60,H2Low,TimeCurrent()+1*3*55*60,H2High,clrRed,STYLE_DASH,4);
      
      
      ObjectDelete(StringConcatenate("D0bar",tik5)) ;
      TrendCreate(0,StringConcatenate("D0bar",tik5),0,Time[0]+PERIOD_D1*3.2,D0Low,Time[0]+PERIOD_D1*3.2,D0High,clrOrange,STYLE_DASH,2);
       Text("D0Low",0,"D0Low",10,"Arial",clrOrange,(Time[0]+PERIOD_D1*3.2),D0Low,true);
   Text("D0High" ,0,"D0High",10,"Arial",clrOrange,(Time[0]+PERIOD_D1*3.2),D0High,true);
  
       
       ObjectSetInteger(0,StringConcatenate("D0bar",tik5),OBJPROP_DIRECTION,100);
       //  do ObjectGetObjectGetDouble(0,StringConcatenate("D0bar",tik5),OBJPROP_PRICE,0,rez);
          int y7=(int)IntGetY(StringConcatenate("D0bar",tik5));

          ButtonCreate(0,"D0",0,Time[0]+100,y7,ButX,BuyY,0,"D0","Arial",fontsize,clrPink,C'236,233,216',colorframe,false,false,false,true,0,"D0"); 
      ObjectDelete(StringConcatenate("D1bar",tik5)) ;
      TrendCreate(0,StringConcatenate("D1bar",tik5),0,Time[0]+PERIOD_D1*2.8,D1Low,Time[0]+PERIOD_D1*2.8,D1High,clrWhite,STYLE_DASH,2);
      ObjectDelete(StringConcatenate("D2bar",tik5)) ;
      TrendCreate(0,StringConcatenate("D2bar",tik5),0,Time[0]+PERIOD_D1*2.3,D2Low,Time[0]+PERIOD_D1*2.3,D2High,clrAqua,STYLE_DASH,2);
      
      ObjectDelete(StringConcatenate("H4bar",tik5)) ;
      if (H4Open < H4Close ) 
      TrendCreate(0,StringConcatenate("H4bar",tik5),0,TimeCurrent()+1*3*65*60,H4Low,TimeCurrent()+1*3*70*60,H4High,clrMagenta,STYLE_DASH,2);
   else 
      TrendCreate(0,StringConcatenate("H4bar",tik5),0,TimeCurrent()+1*3*70*60,H4Low,TimeCurrent()+1*3*65*60,H4High,clrMagenta,STYLE_DASH,2);
  


     }
   
   
   
  calcPN(calMG);
  
  // but2();
   //  OnTimer();
//Redraw55();
//Redraw44();


for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic || MagicALL==-1)
            if(OrderSymbol()==_Symbol)
              {
            ///   x=y=0;ChartTimePriceToXY(0,0,(OrderOpenTime()),OrderOpenPrice(),x,y); 
               x=y=0;ChartTimePriceToXY(0,0, Time[0],OrderOpenPrice(),x,y); 
           
                  tik=OrderTicket();
                  if ( ti2!= OrderOpenTime() )  ti2= ti2;   /// ti222222
                   else ti2=  OrderOpenTime() ;
                   x3 = 0; 
                      colorframe = ( OrderType()==1 || OrderType()==3 || OrderType()==5)   ?clrRed:clrAqua     ;  
                     if ( OrderType()==1 || OrderType()==3 || OrderType()==5)  x3=-525;
                      if ( OrderType()==0 || OrderType()==2 || OrderType()==4)  x3=+125;
               if(ObjectFind(StringConcatenate(prefix+"Re",OrderTicket()))!=0)      
                  ButtonCreate(0,StringConcatenate("Re",OrderTicket()),0,x+100+x3,y,ButX+5,BuyY,0,"<.>","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,true,true,0,"Move the menu");     
               SetX(StringConcatenate(prefix+"Re",OrderTicket()),y);                                                                                                                    
               int x2=(int)IntGetX (StringConcatenate("Re",OrderTicket()));                                                                                                           
               int y2=(int)IntGetY (StringConcatenate("Re",OrderTicket()));                                         
              
            //   Magic=  StringToDouble(ObjectGetString(0,StringConcatenate("MG4",OrderTicket()),OBJPROP_TEXT));
   
              obj_del(StringConcatenate("MG4",OrderTicket()));
                if (ObjectFind(StringConcatenate("MG4",OrderTicket()))==-1)
         ///err        LabelCreate(0,StringConcatenate("MG4",OrderTicket()),0,x2+25,y2,ButX+20,BuyY,"open MG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
     EditCreate(0,StringConcatenate("MG4",OrderTicket()),0,x2-40,y2,ButX+20,BuyY,DoubleToString( OrderMagicNumber(),0),"Arial",8,ALIGN_CENTER,false); 
    //  Magic=  StringToDouble(ObjectGetString(0,StringConcatenate("MG4",OrderTicket()),OBJPROP_TEXT));
     Magic=  StringToDouble(ObjectGetString(0,StringConcatenate("MG4",OrderTicket()),OBJPROP_TEXT));
   
           //  ButtonCreate(0,StringConcatenate("MG4",OrderTicket()),0,x2+25,y2,ButX+20,BuyY,0,DoubleToString( OrderMagicNumber(),0),"Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"MG");       
               
            ButtonCreate(0,StringConcatenate("TH",OrderTicket()),0,x2+25,y2,ButX,BuyY,0,"TH","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"TH");       
               ButtonCreate(0,StringConcatenate("SL",OrderTicket()),0,x2+45,y2,ButX,BuyY,0,"SL","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"StopLoss");       
               ButtonCreate(0,StringConcatenate("TP",OrderTicket()),0,x2+65 ,y2,ButX,BuyY,0,"TP","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"TakeProfit");      
               ButtonCreate(0,StringConcatenate("BR",OrderTicket()),0,x2+85 ,y2,ButX,BuyY,0,"BR","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"Breakeven");       
               ButtonCreate(0,StringConcatenate("TR",OrderTicket()),0,x2+105 ,y2,ButX,BuyY,0,"TR","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"Ttrailing Stop");  
               ButtonCreate(0,StringConcatenate("Ti",OrderTicket()),0,x2+125,y2,ButX,BuyY,0,"Ti","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"Time Close");   
               ButtonCreate(0,StringConcatenate("SN",OrderTicket()),0,x2+145,y2,ButX,BuyY,0,"SN","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"SN");   
              
                ButtonCreate(0,StringConcatenate("HH",OrderTicket()),0,x2+165,y2,ButX,BuyY,0," H ","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"HH Order");   
           
            
              ButtonCreate(0,StringConcatenate("Xx",OrderTicket()),0,x2+185,y2,ButX,BuyY,0," X ","Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,"Close Order");  
                
               
                ButtonCreate(0,StringConcatenate("LOT",OrderTicket()),0,x2+205,y2,ButX+20,BuyY,0,DoubleToString( OrderLots(),2),"Arial",fontsize,clrBlack,C'236,233,216',colorframe,false,false,false,true,0,DoubleToString( OrderLots(),2));   
                
                  // LabelCreate(0,StringConcatenate("LOT",OrderTicket()),0,x2+205,y2,CORNER_LEFT_UPPER,True ?DoubleToString( OrderLots(),2)+"Lot":"touch","Arial",10,OrderType()>0 ?clrRed:clrAqua,0,ANCHOR_LEFT_UPPER);
                    LabelCreate(0,StringConcatenate("MG",OrderTicket()),0,x2+195,y2,CORNER_LEFT_UPPER,DoubleToString( OrderMagicNumber(),0)+"","Arial",10,clrBeige,0,ANCHOR_LEFT_UPPER);
                colorprofit= clrYellow ;
                 if (OrderProfit()>0 )  colorprofit= clrAqua;
                   if (OrderProfit()<0 )   colorprofit= clrRed ;
                   
                    LabelCreate(0,StringConcatenate("Profit",OrderTicket()),0,x2+250,y2,CORNER_LEFT_UPPER,True ?DoubleToString( OrderProfit(),2)+"$":"touch","Arial",10,colorprofit,0,ANCHOR_LEFT_UPPER);
     
      }   WindowRedraw();  ChartRedraw(0);
      
       for(int i=ObjectsTotal()-1; i>=0; i--)
      if(ObjectType(ObjectName(i))== OBJ_BUTTON)
         if(but_stat(ObjectName(i))== true)
            ObjectSetInteger(0,ObjectName(i),OBJPROP_BGCOLOR,clrLightGreen);   //selectedcolor
   else
      ObjectSetInteger(0,ObjectName(i),OBJPROP_BGCOLOR,C'236,233,216'); 

  

 string txt="";
   for(int i=0;i<OrdersTotal();i++)                                                          
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                                               
         if(OrderMagicNumber()==Magic || MagicALL==-1)                                              
            if(OrderSymbol()==_Symbol)                                                     
              {
                                                                       
               op=NormalizeDouble(OrderOpenPrice(),Digits);  
               Lot = OrderLots() ;
         double      tprofit = OrderProfit ();
               
               ti2=  OrderOpenTime() ;
               ChartTimePriceToXY(0,0,Time[0],OrderOpenPrice(),x,y); 
                SetX(StringConcatenate(prefix+"Re",OrderTicket()),y);                                                                                                                    
               int x2=(int)IntGetX (StringConcatenate("Re",OrderTicket()));      
               int y2=(int)IntGetY (StringConcatenate("Re",OrderTicket()));         
    
      datetime dt    =0; 
      datetime dt2    =0; 
      datetime ti2sl    =0; 
      datetime ti2th    =0;
      datetime ti2hh    =0;
      double   price =0; 
      int      window=0; 
      datetime  tik4;
                  double  th4;
      //--- Convert the X and Y coordinates in terms of date/time 
      ChartXYToTimePrice(0,x2-10,y,window,dt,op) ;
      ti2=dt ;
      ChartXYToTimePrice(0,x2-18,y,window,dt,op) ; 
                ti2th=dt ;
                ChartXYToTimePrice(0,x2-16,y,window,dt,op) ; 
                ti2hh=dt ;
                  tt=OrderTakeProfit();
                  //  tt=TakeProfit;   ???
                  
              ///   tt= 10 ;
                         
                ss= OrderStopLoss();                                       
                    op=NormalizeDouble(OrderOpenPrice(),Digits);  
                 Lot = OrderLots() ;
         
         th=NormalizeDouble(Hedge,_Digits);// 
      //  th=NormalizeDouble(0,_Digits);
                 tr=NormalizeDouble(TralingStop,_Digits); 
                  LSize  = MarketInfo(Symbol(), MODE_LOTSIZE);   /// lsize
                   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   SpreadPip=MarketInfo(Symbol(),MODE_SPREAD)/point*Point;
   SpreadPipValue=(MarketInfo(Symbol(),MODE_SPREAD)/point*Point)*PipValues;
   
/*th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                 ObjectGetDouble(0,nameLTH,OBJPROP_PRICE,0,th4);
                  ObjectGetDouble(0,nameLTH,OBJPROP_PRICE,0,th);
        */  
                      //// if (tt = 0)  {  tt =op+op ; OrderModify(OrderTicket(),op,ss,tt,0,clrNONE) ;}
                    
                    tik=OrderTicket();                                                         
               typ=OrderType();  
               
               
                ti=StringConcatenate("ti",tik);               //// nameeee  
               name=StringConcatenate("Op",tik);                                                  
                                                          
               nameX =StringConcatenate(prefix,"Xx",tik);                                  
               nameSL=StringConcatenate(prefix,"SL",tik);  
               nameTP=StringConcatenate(prefix,"TP",tik);                                  
               nameBR=StringConcatenate(prefix,"BR",tik);        
                 nameSN=StringConcatenate(prefix,"SN",tik);  
                 nameHH=StringConcatenate(prefix,"HH",tik);                                   
               nameTR=StringConcatenate(prefix,"TR",tik);                                    
               nameTI=StringConcatenate(prefix,"Ti",tik);  
                nameTH=StringConcatenate(prefix,"TH",tik);    
               
               
                                               
                       nameTPV=StringConcatenate(prefix,"TPV",tik);                      
                     nameSLV=StringConcatenate(prefix,"SLV",tik);                                
                   nameBRV=StringConcatenate(prefix,"BRV",tik);      
             nameSNV=StringConcatenate(prefix,"SNV",tik);
             namePNV=StringConcatenate(prefix,"PNV",tik);
                   nameHHV=StringConcatenate(prefix,"HHV",tik);                                 
              nameTRV=StringConcatenate(prefix,"TRV",tik);  
               nameTHV=StringConcatenate(prefix,"THV",tik);                                
               name2THV=StringConcatenate(prefix,"2THV",tik); 
                name2HHV=StringConcatenate(prefix,"2HHV",tik); 
                     
                     nameLTP=StringConcatenate(prefix,"LTP",tik);   nameLTPtxt=StringConcatenate(prefix,"LTPtxt",tik);                      
               nameLSL=StringConcatenate(prefix,"LSL",tik);         nameLSLtxt=StringConcatenate(prefix,"LSLtxt",tik);                                
               nameLBR=StringConcatenate(prefix,"LBR",tik);         nameLBRtxt=StringConcatenate(prefix,"LBRtxt",tik);      
                 nameLSN=StringConcatenate(prefix,"LSN",tik);       nameLSNtxt=StringConcatenate(prefix,"LSNtxt",tik);
                 nameLPN=StringConcatenate(prefix,"LPN",tik);       nameLPNtxt=StringConcatenate(prefix,"LPNtxt",tik);
                 nameLHH=StringConcatenate(prefix,"LHH",tik);       nameLHHtxt=StringConcatenate(prefix,"LHHtxt",tik);                                 
               nameLTR=StringConcatenate(prefix,"LTR",tik);         nameLTRtxt=StringConcatenate(prefix,"LTRtxt",tik);  
                 nameLTH=StringConcatenate(prefix,"LTH",tik);       nameLTHtxt=StringConcatenate(prefix,"LTHtxt",tik);                                              
                
                name2LTH=StringConcatenate(prefix,"2LTH",tik);       name2LTHtxt=StringConcatenate(prefix,"2LTHtxt",tik);                                              
                 name2LHH=StringConcatenate(prefix,"2LHH",tik);       name2LHHtxt=StringConcatenate(prefix,"2LHHtxt",tik);                                              
                 name7LHH=StringConcatenate(prefix,"7LHH",tik);       name7LHHtxt=StringConcatenate(prefix,"7LHHtxt",tik);                                              
                nameLQP=StringConcatenate(prefix,"LQP",tik);   nameLQPtxt=StringConcatenate(prefix,"LQPtxt",tik);         
                 nameLAP=StringConcatenate(prefix,"LAP",tik);   nameLAPtxt=StringConcatenate(prefix,"LAP",tik,"txt");         
                nameLHP=StringConcatenate(prefix,"LHP",tik);   nameLHPtxt=StringConcatenate(prefix,"LHP",tik,"txt");  
                
                nameLEQ=StringConcatenate(prefix,"LEQ",tik);   nameLEQtxt=StringConcatenate(prefix,"LEQ",tik,"txt");          
               
                     
             if(ObjectGetInteger(0,nameX,OBJPROP_STATE)==true) 
             {closeorders(tik);    ///delllll
             obj_del(StringConcatenate(prefix+"Re",tik)) ;
                  obj_del(StringConcatenate("MG4",tik)) ;
                  obj_del(StringConcatenate(prefix+"TH",tik)) ;
                  obj_del(StringConcatenate(prefix+"SL",tik)) ;
                  obj_del(StringConcatenate(prefix+"TP",tik)) ;
                  obj_del(StringConcatenate(prefix+"BR",tik)) ;
                  obj_del(StringConcatenate(prefix+"TR",tik)) ;
                  obj_del(StringConcatenate(prefix+"Ti",tik)) ;
                  obj_del(StringConcatenate(prefix+"SN",tik)) ;
                  obj_del(StringConcatenate(prefix+"HH",tik)) ;
                  obj_del(StringConcatenate(prefix+"Xx",tik)) ;
                  obj_del(StringConcatenate(prefix+"LOT",tik)) ;
                  obj_del(StringConcatenate("Profit",tik)) ;
                  obj_del(StringConcatenate("MG",tik)) ;
             // ObjectDelete( OrderTicket())  ;
           //   if(ObjectFind(StringConcatenate(prefix+tik)>-1 ))
             // {
             ///  ObjectDelete(0,tik);
             // }
              ObjectDelete(name); 
              calcPN (calMG);
            // uroven();
           // WindowRedraw(); 
             // Redraw();
             //ChartRedraw(0);
             }
                  proverca_sl_tp_ti();   
                  proverca_br_tr(tik);    //tuka provercaa
                     
                  if (702==701)    ///  find702
                   if (but_stat(nameTH)==false  )
                   
                   {
                   if  ((  typ==0) || (typ==2 || typ==4)  )
                 { 
                 
                 if (tt == 0   ) 
                      th =  (op- NormalizeDouble(ATR15*140/Lot/LSize,_Digits) ) ;///+Point+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0))  ;
             double th51 =  (op- NormalizeDouble(ATR15*140*1.6/Lot/LSize,_Digits) ) ;
               double th52 =  (op- NormalizeDouble(ATR15*140*2.6/Lot/LSize,_Digits) ) ;
                double th61 =  (op- NormalizeDouble((LM5+LM15)/2/Lot/LSize,_Digits) ) ;
                  obj_cre(nameLTH,(th),clrYellow);  
                    th4 = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                     tik4 = ObjectGetTimeByValue(0, nameLTH,th,nameLTH);
                 //   ObjectGetTimeByValue(0, nameLTH,th4,tik4);
                 
                    ObjectDelete (nameLTH) ;
                 if(ObjectFind(0,nameLTH) == -1) 
                     {
                   HLineCreate(0,nameLTH,0,th4,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                   HLineCreate(0,nameLTH+"1",0,th51,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                   HLineCreate(0,nameLTH+"2",0,th52,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   HLineCreate(0,nameLTH+"3",0,th61,clrWhite,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                    th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                
                 
                       rezult= kk*(th-op)/_Point*Lot*PipValues ;
                       winrate = tprofit / rezult  ; //OrderProfit() ;
                       ObjectDelete (nameLTHtxt);
                                       
            ObjectCreate(0,nameLTHtxt,OBJ_TEXT,0,ti2th,th);
         ObjectSetString(0, nameLTHtxt ,OBJPROP_TEXT,DoubleToString((int(th/Point)*Point),Digits)
         +" /  "+DoubleToString(rezult,2)
         +"  $ /  "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" S "+ DoubleToString(Lot,2)
         +" WR "+ DoubleToString(winrate,2) 
          +" cl lot "+ DoubleToString(Lot*winrate,2));
           ObjectSetString(0, nameLTH ,OBJPROP_TOOLTIP,DoubleToString((int(th/Point)*Point),Digits)
         +" / "+DoubleToString(rezult,2)
         +"  $ / "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" B "+ DoubleToString(Lot,2)
           +" WR "+ DoubleToString(winrate,2) 
            +" cl lot "+ DoubleToString(Lot*winrate,2));
         
            //   obj_del(nameTHV) ;
            
          // tik4 = ObjectGetTimeByValue(0, nameLTH,th,0);
             ObjectDelete (name2LTH) ;
               // if (ObjectFind(name2LTH)==-1)
              TrendCreate(0,name2LTH,0,Time[12],th,Time[0]+PERIOD_D1*1,th,clrMagenta,STYLE_SOLID,2);
              
           
                  obj_cre_trend(nameTHV,tik4,th,tik4,op,clrOrange);
                  ObjectMove(0, nameTHV,th4,tik4);
            }
                 
                 }
                   if  ((  typ==1) || (typ==3 || typ==5)  )
                 { 
                 
                 
                 
                      if (tt == 0   ) 
                      th =  (op+ NormalizeDouble(ATR15*140/Lot/LSize,_Digits) ) ;///+Point+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0))  ;
             
             /*   th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                 ObjectGetDouble(0,nameLTH,OBJPROP_PRICE,0,th4);
                  ObjectGetDouble(0,nameLTH,OBJPROP_PRICE,0,th);
                 */ 
                 obj_cre(nameLTH,(th),clrYellow);  
                 
               
                th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
               
                   
                     tik4 = ObjectGetTimeByValue(0, nameLTH,th,nameLTH);
                 //   ObjectGetTimeByValue(0, nameLTH,th4,tik4);
                 
                       rezult= kk*(-th+op)/_Point*Lot*PipValues ;
                       winrate = tprofit / rezult  ; //OrderProfit() ;
                       ObjectDelete (nameLTHtxt);
                                       
            ObjectCreate(0,nameLTHtxt,OBJ_TEXT,0,ti2th,th);
         ObjectSetString(0, nameLTHtxt ,OBJPROP_TEXT,DoubleToString((int(th/Point)*Point),Digits)
         +" /  "+DoubleToString(rezult,2)
         +"  $ /  "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" S "+ DoubleToString(Lot,2)
         +" WR "+ DoubleToString(winrate,2)
         +" cl lot "+ DoubleToString(Lot*winrate,2));
           ObjectSetString(0, nameLTH ,OBJPROP_TOOLTIP,DoubleToString((int(th/Point)*Point),Digits)
         +" / "+DoubleToString(rezult,2)
         +"  $ / "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" B "+ DoubleToString(Lot,2)
           +" WR "+ DoubleToString(winrate,2)
            +" cl lot "+ DoubleToString(Lot*winrate,2));
         
            //   obj_del(nameTHV) ;
            
          // tik4 = ObjectGetTimeByValue(0, nameLTH,th,0);
             ObjectDelete (name2LTH) ;
               // if (ObjectFind(name2LTH)==-1)
              TrendCreate(0,name2LTH,0,Time[12],th,Time[0]+PERIOD_D1*1,th,clrMagenta,STYLE_SOLID,2);
              
           
                  obj_cre_trend(nameTHV,tik4,th,tik4,op,clrOrange);
                  ObjectMove(0, nameTHV,th4,tik4);
            
                 
                 }
                   
                   }
                   
                   
                  
                               if ((but_stat(nameTH)==true  )  // thhhhh  linee
            //  &&  ( tik== OrderTicket() )
              )
               { // ChartXYToTimePrice(0,x2-18,y,window,dt,op) ; 
               // ti2th=dt ;
               
                 ttyp= typ ;
                 //th=0;
                  //     Alert  (txt + " tt " + tt+ " ta1 " + TA[1] +" ta20 " + TA[20]+" ta80 " + TA[80], NL );  
          
                               //  int orderR = checkappRexi();
               //  Alert (txt + " ---- " + nameHH , NL );
                // if (orderR==0) CLOSEORDER(); 
                 
                 if  ((  typ==0) || (typ==2 || typ==4)  )
                 { 
              //  Alert (txt + " b " + nameHH , NL );
                 // obj_cre(StringConcatenate("HH",tik),price -HH,clrMagenta); 
              //    if (th == 0)      th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
              
                   if (tt == 0   ) 
                       th =  (op- NormalizeDouble(Hedge/Lot/LSize,_Digits) ) ;///+Point+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0))  ;
               
                 obj_cre(nameLTH,(th),clrYellow);  th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
               
               ObjectDelete (name2LTH) ;
                if (ObjectFind(name2LTH)==-1)
              TrendCreate(0,name2LTH,0,Time[12],th,Time[0]+PERIOD_D1*1,th,clrMagenta,STYLE_SOLID,2);
                
                ObjectDelete (nameLTH) ;
                 if(ObjectFind(0,nameLTH) == -1) 
                     {
                   HLineCreate(0,nameLTH,0,th,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                    th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                       
                        rezult= kk*(th-op)/_Point*Lot*PipValues ;
                       winrate = tprofit / rezult  ; //OrderProfit() ;
                        ObjectDelete (nameLTHtxt);
                                       
            ObjectCreate(0,nameLTHtxt,OBJ_TEXT,0,ti2th,th);
         ObjectSetString(0, nameLTHtxt ,OBJPROP_TEXT,DoubleToString((int(th/Point)*Point),Digits)
         +" /  "+DoubleToString(rezult,2)
         +"  $ /  "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" S "+ DoubleToString(Lot,2)
         +" WR "+ DoubleToString(winrate,2) );
           ObjectSetString(0, nameLTH ,OBJPROP_TOOLTIP,DoubleToString((int(th/Point)*Point),Digits)
         +" / "+DoubleToString(rezult,2)
         +"  $ / "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" B "+ DoubleToString(Lot,2)
           +" WR "+ DoubleToString(winrate,2) );
         
         obj_del(nameTHV) ;
                  obj_cre_trend(nameTHV,ti2th,th,ti2th,op,clrWhite);
            
                 
                       }
                else 
                  {

       }
              
        // checkappRexi () ;
        
        
                 //      if (orderR== 0 )  /// && b<MaxOrdersCandl) 
   {     //Comment (txt + " sell rexi" );  
   
     //  if ((StringConcatenate("THH",tik)) ==-1)
        
        
        //  ObjectDelete (StringConcatenate("TT1",tik)) ;
           /*      if(ObjectFind(0,StringConcatenate("TT1",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("TT1",tik),0,TA[1],clrMagenta,STYLE_DOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                  }
             //      ObjectDelete (StringConcatenate("TT80",tik)) ;
                 if(ObjectFind(0,StringConcatenate("TT80",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("TT80",tik),0,TA[80],clrMagenta,STYLE_DASHDOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                  }*/
       //    Alert  (txt + "s tt " + tt+ " ta1 " + TA[1] +"      high  " + High[0]+" t     low " + Low[0], NL );  
          
     if  (
       ( (High[0]  > th ) && ( Bid < th )) ||
      ( (Open[0]  < th ) && ( Close[1] > th )) 
      )
     
     {
     // Alert  (txt + "sell tt " + tt+ " lot  " + Lot +" TH     high  " + High[0]+" t     low " + Low[0], NL );  
      
     
  //   openorders(_Symbol,1,Lot,Bid,StringConcatenate("2TH",tik));
     // if(OrderSend(Symbol(),OP_SELL, Lot ,Bid,50,0,0,StringConcatenate("TH",tik),Magic,0,clrRed)!=-1) 
      {
        //  button_off( nameTH); 
           obj_del(nameLTH);  
              obj_del(name2LTH); 
               ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
               }
     }

     // ObjectsDeleteAll(0);
    //   button_off( StringConcatenate("HH",tik));
      //  obj_del(StringConcatenate("THH",tik));  
                   
         
      
      // obj_del(StringConcatenate("HH",tik));  
             
     
      
     
      //ObjectDelete (StringConcatenate("HH",tik)+" n");
     //   obj_del(StringConcatenate("THH",tik));  
     // ObjectDelete (StringConcatenate("THH",tik)+" n");
            
            
      // ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
    //  Sleep(2000);
   }
  /*                if (orderR==-1 ) ///&& s<MaxOrdersCandl) 
   {
      if(OrderSend(Symbol(),OP_BUY,Lot,Bid,50,0,0,StringConcatenate("HH",tik),Magic,0,clrRed)!=-1) 
         ObjectSetInteger(0,StringConcatenate("HH",tik),OBJPROP_STATE,false);
      Sleep(2000);
   }*/
  
      //  obj_del(StringConcatenate("HH",tik)); 
                 // openorders(_Symbol,0,glot) ;
              //    obj_cre(StringConcatenate("HH2",tik),price -2*HH,clrBrown); 
                //  openorders(_Symbol,0,glot);
                 }  
               
               if  ((  typ==1) || (typ==3 || typ==5)  )
                 { 
              //  Alert (txt + " b " + nameHH , NL );
                 // obj_cre(StringConcatenate("HH",tik),price -HH,clrMagenta); 
                  if (tt == 0)   th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
              
                   if (tt == 0)  
                      th =  (op+NormalizeDouble(Hedge/Lot/LSize,_Digits)) ; //+Point+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0))  ;
                obj_cre(nameLTH,(th),clrYellow);  th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
              
               
               ObjectDelete (name2LTH) ;
                if (ObjectFind(name2LTH)==-1)
              TrendCreate(0,name2LTH,0,Time[12],th,Time[0]+PERIOD_D1*1,th,clrAqua,STYLE_SOLID,2);
                
                ObjectDelete (nameLTH) ;
                 if(ObjectFind(0,nameLTH) == -1) 
                     {
                   HLineCreate(0,nameLTH,0,th,clrAqua,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                    th = NormalizeDouble(get_object(nameLTH),_Digits)  ;
                   
                        rezult= kk*(-th+op)/_Point*Lot*PipValues ;
                        winrate = tprofit / rezult  ; //OrderProfit() ;
                        ObjectDelete (nameLTHtxt);
            ObjectCreate(0,nameLTHtxt,OBJ_TEXT,0,ti2th,th);
         ObjectSetString(0, nameLTHtxt ,OBJPROP_TEXT,DoubleToString((int(th/Point)*Point),Digits)
         +" / "+DoubleToString(rezult,2)
         +"  $ / "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" B "+ DoubleToString(Lot,2)
           +" WR "+ DoubleToString(winrate,4) );
            ObjectSetString(0, nameLTH ,OBJPROP_TOOLTIP,DoubleToString((int(th/Point)*Point),Digits)
         +" / "+DoubleToString(rezult,2)
         +"  $ / "+StringSubstr(nameLTH,StringFind(nameLTH,"H"))+" B "+ DoubleToString(Lot,2)
           +" WR "+ DoubleToString(winrate,4) );
                          
                  obj_del(nameTHV) ;
                  obj_cre_trend(nameTHV,ti2th,th,ti2th,op,clrWhite);
                 
                       }
                else 
                  {

       }
              
        // checkappRexi () ;
        
        
                 //      if (orderR== 0 )  /// && b<MaxOrdersCandl) 
   {     //Comment (txt + " sell rexi" );  
   
     //  if ((StringConcatenate("THH",tik)) ==-1)
        
        
        //  ObjectDelete (StringConcatenate("TT1",tik)) ;
           /*      if(ObjectFind(0,StringConcatenate("TT1",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("TT1",tik),0,TA[1],clrMagenta,STYLE_DOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                  }
             //      ObjectDelete (StringConcatenate("TT80",tik)) ;
                 if(ObjectFind(0,StringConcatenate("TT80",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("TT80",tik),0,TA[80],clrMagenta,STYLE_DASHDOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                  }*/
       //    Alert  (txt + "s tt " + tt+ " ta1 " + TA[1] +"      high  " + High[0]+" t     low " + Low[0], NL );  
          
     if  (
     ( (Low[0]  < th ) && ( Ask > th )) ||
      ( (Open[0]  > th ) && ( Close[1] < th )) 
      )
     
     {
     
      // Alert  (txt + "buy tt " + tt+ " lot  " + Lot +" TH     high  " + High[0]+" t     low " + Low[0], NL );  
       
    //  openorders(_Symbol,0,Lot,Ask,StringConcatenate("2TH",tik));
    ///  if(OrderSend(Symbol(),OP_BUY, Lot ,Ask,50,0,0,StringConcatenate("TH",tik),Magic,0,clrRed)!=-1) 
      {
         //button_off( nameTH); 
          obj_del(nameLTH);  
              obj_del(name2LTH);  
               ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
     }

      }
     // ObjectsDeleteAll(0);
    //   button_off( StringConcatenate("HH",tik));
      //  obj_del(StringConcatenate("THH",tik));  
                   
         
      
      // obj_del(StringConcatenate("HH",tik));  
             
     
      
     
      //ObjectDelete (StringConcatenate("HH",tik)+" n");
     //   obj_del(StringConcatenate("THH",tik));  
     // ObjectDelete (StringConcatenate("THH",tik)+" n");
            
      //  ObjectSetInteger(0,nameTH,OBJPROP_STATE,false);
      //Sleep(2000);
   }
  /*                if (orderR==-1 ) ///&& s<MaxOrdersCandl) 
   {
      if(OrderSend(Symbol(),OP_BUY,Lot,Bid,50,0,0,StringConcatenate("HH",tik),Magic,0,clrRed)!=-1) 
         ObjectSetInteger(0,StringConcatenate("HH",tik),OBJPROP_STATE,false);
      Sleep(2000);
   }*/
  
      //  obj_del(StringConcatenate("HH",tik)); 
                 // openorders(_Symbol,0,glot) ;
              //    obj_cre(StringConcatenate("HH2",tik),price -2*HH,clrBrown); 
                //  openorders(_Symbol,0,glot);
                 }  
               
               
               
               
               }
               else 
               {
                  obj_del(name2LTH); 
                  obj_del(nameTHV) ; 
               }
               
               
             // string  name2LHH7  = name2LHH+"7";
               // string  name2LHH  = nameLHH+"7";
               // string  name1LHH  = nameLHH+"7";
            if ((but_stat(nameHH)==true  )    /// nameHHHH   sell  hhhh7
            // &&  ( tik== OrderTicket() )
              )
              { //ChartXYToTimePrice(0,x2-16,y,window,dt,op) ;                // ti2hh=dt ;
                      
              
           //   if ((  typ==1 ) || (typ==3 || typ==5)  )  //)(((Bid+HH)<op) && typ==1){
                if ((  typ==0 ) || (typ==2 || typ==4 )  )  //)(((Bid+HH)<op) && typ==1){
                 {                               
              
                 //  Alert ( " 1 ss " ,tt );
                  SP = 0;
                 //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
                 if ( ss ==0 )
                    ss= Bid - NormalizeDouble((StopLoss + SP) ,_Digits);  //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                            
                     obj_cre(nameLSL,(ss),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits); 
                    // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                      obj_cre_trend(nameSLV,ti2hh,ss,ti2hh,op,clrMagenta);
                   
            
                      //    ObjectDelete (name2LHH) ;
                if (ObjectFind(name2LHH)==-1)
              TrendCreate(0,name2LHH,0,Time[12],ss,Time[0]+PERIOD_D1*1,ss,clrMagenta,STYLE_DASH,1);
            //  ObjectDelete (nameLHH) ;
            obj_del(nameLHH);
                 if(ObjectFind(0,nameLHH) == -1) 
                    // {
                   HLineCreate(0,nameLHH,0,ss,clrMagenta,STYLE_DOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                
               tt = NormalizeDouble(get_object(nameLHH),_Digits)  ;
                
              
                        ObjectDelete (nameLHHtxt);
            ObjectCreate(0,nameLHHtxt,OBJ_TEXT,0,ti2hh,tt);
         ObjectSetString(0, nameLHHtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(tt-op)/Point*Lot*PipValues,2)
         +"  $  / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" SL B "+ DoubleToString(Lot,2) );
                 
              //   obj_cre(name2LHH,(ss),clrWheat);  
                  tt = NormalizeDouble(get_object(name2LHH),_Digits)  ;
                 obj_del(nameHHV);
                 obj_cre_trend(nameHHV,ti2hh,ss,ti2hh,op,clrRed);
                 
             //    }
                      
                  }
             
                 
                 if ((  typ==1 ) || (typ==3 || typ==5)  )  //)(((Bid+HH)<op) && typ==1){ 
           //    if  ((  typ==0) || (typ==2 || typ==4)  )
                // {   if(but_stat(nameHH)==true)      //buy hh
                 {                
                //   tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
               //   ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);   
                if ( ss ==0 )
                    ss= Ask + NormalizeDouble((StopLoss+ SP ) ,_Digits);   //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                                        
                     obj_cre(nameLSL,(ss),clrRed);   //    ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                   
                     obj_cre_trend(nameSLV,ti2hh,ss,ti2hh,op,clrMagenta);
                   
             //    ObjectDelete (name2LHH) ;
                if (ObjectFind(name2LHH)==-1)
              TrendCreate(0,name2LHH,0,Time[12],ss,Time[0]+PERIOD_D1*1,ss,clrAqua,STYLE_DASH,1);
           //    ObjectDelete (nameLHH) ;
                 if(ObjectFind(0,nameLHH) == -1) 
                     {
                   HLineCreate(0,nameLHH,0,ss,clrAqua,STYLE_DOT,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                
                                       
                       tt = NormalizeDouble(get_object(nameLHH),_Digits)  ;
                        ObjectDelete (nameLHHtxt);
            ObjectCreate(0,nameLHHtxt,OBJ_TEXT,0,ti2hh,tt);
         ObjectSetString(0, nameLHHtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(-tt+op)*Lot,2)
         +"  $  / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" SL S "+ DoubleToString(Lot,2) );
                 
             //     obj_cre(name2LHH,(ss),clrBlue);  
                 tt = NormalizeDouble(get_object(name2LHH),_Digits)  ;
                 obj_del(nameHHV);
                 obj_cre_trend(nameHHV,ti2hh,ss,ti2hh,op,clrAqua);
                     
                     
                     }
                  }
                
                 
                 }
               else                                                                          
                  { //obj_del(nameLHH);                                         
                   //obj_del(nameHHV);
                   obj_del(nameLSLtxt);
               //  obj_del(name7LHH);
                  //obj_del(name2LHH);
                  }
              
              /*
          //  && ((OrderMagicNumber() !=0 )   )) ////  && (StringConcatenate(prefix,"HH",tik)!=-1 ))  ////  hhhh
                 {  
                       ttyp= typ ;
                  //     Alert  (txt + " tt " + tt+ " ta1 " + TA[1] +" ta20 " + TA[20]+" ta80 " + TA[80], NL );  
          
                                 int orderR = checkappRexi();
               //  Alert (txt + " ---- " + nameHH , NL );
                // if (orderR==0) CLOSEORDER(); 
                 
                 if  ((  typ==0) || (typ==2 || typ==4)  )
                 { 
              //  Alert (txt + " b " + nameHH , NL );
                 // obj_cre(StringConcatenate("HH",tik),price -HH,clrMagenta); 
                  if (tt == 0)    tt =  tt = NormalizeDouble(get_object(StringConcatenate("LHH",tik)),_Digits)  ;
              
                    if (tt == 0)    tt =  (Bid- Hedge/Lot+Point+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0))  ;
               
              
               
               ObjectDelete (StringConcatenate("HH",tik)) ;
                if (ObjectFind(StringConcatenate("HH",tik))==-1)
              TrendCreate(0,StringConcatenate("HH",tik),0,Time[12],tt,Time[0]+PERIOD_D1*1,tt,clrMagenta,STYLE_SOLID,2);
                
                ObjectDelete (StringConcatenate("LHH",tik)) ;
                 if(ObjectFind(0,StringConcatenate("LHH",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("LHH",tik),0,tt,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                   
                    tt = NormalizeDouble(get_object(StringConcatenate("HH",tik)),_Digits)  ;
                        ObjectDelete (StringConcatenate("HHt",tik));
            ObjectCreate(0,StringConcatenate("HHt",tik),OBJ_TEXT,0,ti2,tt);
         ObjectSetString(0, StringConcatenate("HHt",tik) ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString((tt-op)*Lot,2)
         +"  $ / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" HH B "+ DoubleToString(Lot,2)+" OL "+ DoubleToString(OrderLots(),2) );
                 
                       }
                else 
                  {

       }
              
        // checkappRexi () ;
        
        
                       if (orderR== 0 )  /// && b<MaxOrdersCandl) 
   {     //Comment (txt + " sell rexi" );  
   
     //  if ((StringConcatenate("THH",tik)) ==-1)
        
        
        //  ObjectDelete (StringConcatenate("TT1",tik)) ;
           
       //    Alert  (txt + "s tt " + tt+ " ta1 " + TA[1] +"      high  " + High[0]+" t     low " + Low[0], NL );  
          
     if  ( (High[0]  > tt ) && ( Bid < tt ))
      if(OrderSend(Symbol(),OP_SELL, Lot ,Bid,50,0,0,StringConcatenate("HH",tik),Magic,0,clrRed)!=-1) {
       Alert  (txt + "s tt " + tt+ " lot  " + OrderLots() +"      high  " + High[0]+" t     low " + Low[0], NL );  
          
     // ObjectsDeleteAll(0);
    //   button_off( StringConcatenate("HH",tik));
      //  obj_del(StringConcatenate("THH",tik));  
                   
         
      
      // obj_del(StringConcatenate("HH",tik));  
 button_off( StringConcatenate("HH",tik));       
     
      obj_del(StringConcatenate("HH",tik));  
      ObjectDelete (StringConcatenate("HH",tik)+" n");
        obj_del(StringConcatenate("THH",tik));  
      ObjectDelete (StringConcatenate("THH",tik)+" n");
            
             }
         ObjectSetInteger(0,StringConcatenate("HH",tik),OBJPROP_STATE,false);
      Sleep(2000);
   }
 
  
      //  obj_del(StringConcatenate("HH",tik)); 
                 // openorders(_Symbol,0,glot) ;
              //    obj_cre(StringConcatenate("HH2",tik),price -2*HH,clrBrown); 
                //  openorders(_Symbol,0,glot);
                 }  
                 
                 
                  if ((  typ==1 ) || (typ==3 || typ==5)  )  //)(((Bid+HH)<op) && typ==1){
                 { pr (txt + "   s" + nameHH );
                 
                // int orderRs = checkappRexi();
               int orderR = checkappRexi();
               
                 if (tt == 0)    tt =  tt = NormalizeDouble(get_object(StringConcatenate("LHH",tik)),_Digits)  ;
              
                if (tt == 0)     tt = Ask+Hedge/Lot+Point+(DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)) ;
              
                ObjectDelete (StringConcatenate("HH",tik)) ;
                if (ObjectFind(StringConcatenate("HH",tik))==-1)
                   TrendCreate(0,StringConcatenate("HH",tik),0,Time[12],tt,Time[0]+PERIOD_D1*1,tt,clrAqua,STYLE_SOLID,2);
                   
                    ObjectDelete (StringConcatenate("LHH",tik)) ;
                if(ObjectFind(0,StringConcatenate("LHH",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("LHH",tik),0,tt,clrAqua,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                      tt = NormalizeDouble(get_object(StringConcatenate("HH",tik)),_Digits)  ;
                        ObjectDelete (StringConcatenate("HHt",tik));
            ObjectCreate(0,StringConcatenate("HHt",tik),OBJ_TEXT,0,ti2,tt);
         ObjectSetString(0, StringConcatenate("HHt",tik) ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString((tt-op)*Lot,2)
         +"  $ / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" HH S "+ DoubleToString(Lot,2)+" OL "+ DoubleToString(OrderLots(),2) );
                 
                      
                       }
                else 
                  {
                   }
                    
                   
  
                  if (orderR== 1 ) ///&& s<MaxOrdersCandl) 
   {   //Comment (txt + " buy rexi" );
  // pr (txt + "   s" + nameHH ,NL );
    //   if ((StringConcatenate("THH",tik)) ==-1)
    
        Alert  (txt + "b tt " + tt+ " ta1 " + TA[1] +"      high  " + High[0]+" t     low " + Low[0], NL );  
          
     if  ( ( Ask  > tt ) && (Low[0] < tt ))
      if(OrderSend(Symbol(),OP_BUY,Lot ,Ask,50,0,0,StringConcatenate("HH",tik),Magic,0,clrBlue)!=-1) {
      
      //       ObjectsDeleteAll(0);
  
    
 button_off( StringConcatenate("HH",tik));       
   //  obj_del(StringConcatenate("THH",tik)); 
    ////  obj_del(StringConcatenate("HH",tik));  
     ObjectDelete (StringConcatenate("HH",tik)+" n");
        obj_del(StringConcatenate("THH",tik));  
      ObjectDelete (StringConcatenate("THH",tik)+" n");
           //  ButtonCreate(0,StringConcatenate("HH",OrderTicket()),0,x2+125,y2,ButX,BuyY,0,"HH","Arial",8,clrBlack,C'236,233,216',clrNONE,false,false,false,true,0,"HH Order");   
          }
         ObjectSetInteger(0,StringConcatenate("HH",tik),OBJPROP_STATE,false);
      Sleep(2000);
   }
     
                 } 
                 }
               else {  // delete OFF trend hedge
               obj_del(StringConcatenate("HH",tik));          
               ObjectDelete (StringConcatenate("HH",tik)+" n");
               obj_del(StringConcatenate("THH",tik));          
               //ObjectDelete (StringConcatenate("THH",tik)+" n");
             //  ObjectDelete (StringConcatenate("VHH",tik));
                     //return;
                 }
                 
                 
                 */   // hh
                 
               /*   if (((but_stat(nameHH)== "false"  )&& (but_stat(nameBR)== "false"  ) )  ///&& (but_stat(nameSL)== "false"  ) && (but_stat(nameTP)== "false"  && (but_stat(nameSN)== "false"  )))
              && ((OrderMagicNumber() ==1111 )   ))  ///|| (OrderMagicNumber() ==Magic )) ) /// && (but_stat(nameBR)== "false"  ))   ////  hhhh
                 {
                 
             //    nameTP=StringConcatenate(prefix,"TP",tik); 
             // nameTP= ObjectSetInteger(0,nameTP,OBJPROP_STATE,true);      
                          
                 
                //      if   (StringConcatenate(prefix,"HH",tik) !=-1 )                 
                     {    nameHH=StringConcatenate(prefix,"HH",tik); 
              nameHH= ObjectSetInteger(0,nameHH,OBJPROP_STATE,true);   
                 nameSL=StringConcatenate(prefix,"SL",tik); 
              nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true); 
              
              if (ObjectFind(StringConcatenate("THH",tik))==-1)
              TrendCreate(0,StringConcatenate("THH",tik),0,Time[10],tt,Time[0],tt,clrMagenta,STYLE_SOLID,2);
                
                 if(ObjectFind(0,StringConcatenate("LHH",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("LHH",tik),0,tt,clrMagenta,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                       }
                 
                         }}
                         
                         */
                         
                 
     /*         if (((but_stat(nameHH)== "false"  )&& (but_stat(nameBR)== "false"  ) && (but_stat(nameSL)== "false"  ) && (but_stat(nameTP)== "false" ) && (but_stat(nameSN)== "false") )
              && ((OrderMagicNumber() ==0 )   )
            )  
           //   || (OrderMagicNumber() ==Magic ))  /// && (but_stat(nameBR)== "false"  ))   ////  hhhh
                 {
                 
             //    nameTP=StringConcatenate(prefix,"TP",tik); 
             // nameTP= ObjectSetInteger(0,nameTP,OBJPROP_STATE,true);      
                          
                 
                //      if   (StringConcatenate(prefix,"HH",tik) !=-1 )                 
                     {  
                     
          
               ////             nameHH=StringConcatenate(prefix,"HH",tik); 
           ///nameHH= ObjectSetInteger(0,nameHH,OBJPROP_STATE,true);      
                           
              //    nameSL=StringConcatenate(prefix,"SL",tik); 
          //   nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true); 
              
            ///  nameSN=StringConcatenate(prefix,"SN",tik); 
          //   nameSN= ObjectSetInteger(0,nameSN,OBJPROP_STATE,true); 
            //        nameBR=StringConcatenate(prefix,"BR",tik); 
          //    nameBR= ObjectSetInteger(0,nameBR,OBJPROP_STATE,true); 
             // if(but_stat(nameHH)== "true"  )
                  {  
                   // nameBR=StringConcatenate(prefix,"BR",tik); 
                   // nameBR= ObjectSetInteger(0,nameBR,OBJPROP_STATE,true); 
             // nameHH= ObjectSetInteger(0,nameHH,OBJPROP_STATE,false);  
                  }
                  }
               //  return ;
                  if (tt == 0)    tt =  tt = NormalizeDouble(get_object(StringConcatenate("LHH",tik)),_Digits)  ;
              
                if (tt == 0)     tt = Ask+Hedge/OrderLots()+Point+(DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)) ;
                
                  if(ObjectFind(0,StringConcatenate("LHH",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("LHH",tik),0,tt,clrAqua,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                       }
                else 
                  {
              
              tt = NormalizeDouble(get_object(StringConcatenate("LHH",tik)),_Digits)  ;
                        ObjectDelete (StringConcatenate("HH",tik));
            ObjectCreate(0,StringConcatenate("LHHt",tik),OBJ_TEXT,0,ti2,tt);
         ObjectSetString(0, StringConcatenate("LHHt",tik) ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString((op-tt)*Lot,2)
         +"  $  Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" HH S "+ Lot );
                 }
                    /////  
                  }   
            */
                   wp=0;
               if(typ==0 )    ///BUY
                 {
                   if (price>op ) wp = price ;
                   else wp= op;
                   
               
                      
                   
                   
                 
           if(but_stat(nameTP)==true)          //tppppp            ///BUY                                   
                  {
                //     Alert ( " 1 tt " ,tt );
                  //     tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
             //     ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);  
          //   Comment (  tt );
              if (tt == 0)    tt =  Ask + NormalizeDouble((TakeProfit)/Lot/LSize ,_Digits);  //NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits); ; ////OrderModify(OrderTicket(),op,ss,tt,0,clrNONE) 
           ;
                   
     /*       //        int x2=(int)IntGetX (StringConcatenate("Re",OrderTicket()));                                                                                                           
             //  int y2=(int)IntGetY (StringConcatenate("Re",OrderTicket()));      
         
                   
                  /// obj_cre(StringConcatenate("TP",tik),(tt),clrGreen);  // tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);                       
                     
              //    if(ObjectFind(0,nameLTP) == -1) 
                     {
                   HLineCreate(0,nameLTP,0,tt,clrOrange,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                 //   double  tt22 = NormalizeDouble(get_object(nameTP+"L"),_Digits)  ;
                  tt = NormalizeDouble(get_object(nameLTP),_Digits)  ;
                       }
              //  else 
                  {
     // double  tt22 = NormalizeDouble(get_object(nameTP+"L"),_Digits)  ;
         
                        ObjectDelete (nameLTPtxt);
            ObjectCreate(0,nameLTPtxt,OBJ_TEXT,0,ti2,tt);
         ObjectSetString(0, nameLTPtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(tt-op)*Lot,2)
         +"  $  Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" ### "+ Lot );
       
        datetime  ti3 = PeriodSeconds();
       
           obj_cre_trend(nameTPV,ti2+ti3,tt,ti2+ti3,op,clrOrange);
       
               obj_del(nameTPV);
         
          
               obj_cre_trend(nameTPV,ti2+ti3,tt,ti2+ti3,op,clrOrange);
                  }
         
                   
                     
                    */ 
                    
                 //   Alert ( " tt " ,tt );
                    
                 //  obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
         obj_cre(nameLTP,(tt),clrGreen);  // tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);     
              
       
              tt = NormalizeDouble(get_object(nameLTP),_Digits)  ;
                        ObjectDelete (nameLTPtxt);
                  
                  ObjectCreate(0,nameLTPtxt,OBJ_TEXT,0,ti2,tt);
    // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua);  
       
         ObjectSetString(0, nameLTPtxt,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(double(-tt+op)/_Point*Lot*PipValues),2)
         +" $$ / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" $$ "+ Lot );
     //    ObjectMove(0,nnname,0,ti2,OrderTakeProfit());      
          
          
           //obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
           obj_del(nameTPV);
           obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
          
                
                      
                     }
                  else                                                                             
                  {
                  obj_del(nameLTP);                                           
                  obj_del(nameTPV);
                // string nnnameLV =       StringConcatenate("TP",tik)+"_2LV" ;
            
              //  obj_del(nnnameLV);
                  
           
                  
                  }

                  if  (
                      (but_stat(nameSL)==true)     ///  slllll   ///BUY
                    //  && (but_stat(nameHH)== false  )
                 //   &&  (tik ==  StringSubstr( nameLSL, StringFind(nameSL, "SL",0)))
                    )
                  
                  {      // ChartXYToTimePrice(0,x2-14,y,window,dt,op) ; 
                       //  ti2=dt ;                    
                 //  Alert ( " 1 ss " ,tt );
                  SP = 0;
                 //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
                 if ( ss ==0 )
                 //   ss= Bid - NormalizeDouble(((StopLoss+ SP )*Point),_Digits)/Lot ;  //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                            
                      ss= Bid - (NormalizeDouble((StopLoss )/Lot/LSize,_Digits)) ; ////csize ;  //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                            
                   obj_cre(nameLSL,(ss),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits); 
                    // ss = NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits)  ;
                      obj_cre_trend(nameSLV,ti2,ss,ti2,op,clrMagenta);
                          
              tt = NormalizeDouble(get_object(nameLSL),_Digits)  ;
                        ObjectDelete (nameLSLtxt);
            ObjectCreate(0,nameLSLtxt,OBJ_TEXT,0,ti2,tt);
            
         double   PipValues1=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*lotMG);
  // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
    //  ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
  double   ClickValue1=PipValues1*((op-ClickPrice)/point); 
         string   
         //Ssl = DoubleToString((int(tt/Point)*Point),Digits)
          // +" / "+DoubleToString(kk*(tt-op)/_Point*Lot,2) 
      ///   +"  $  Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" SL B "+ DoubleToString(Lot,2) ;
           Sslbb = DoubleToString(ClickValue1);
           
          //  DoubleToString(NormalizeDouble((kk*(tt-op)/_Point)*Lot,2) )       ;
       //   DoubleToString(  NormalizeDouble((((MarketInfo(Symbol(),MODE_TICKVALUE)*_Point)/MarketInfo(Symbol(),MODE_TICKSIZE))*Lot*(tt-op)/_Point),2));
      // " | "+DoubleToString(  NormalizeDouble((((MarketInfo(Symbol(),MODE_TICKVALUE)*_Point))+DoubleToString(MarketInfo(Symbol(),MODE_TICKSIZE))+DoubleToString(tt-op)),2));
        
      //   ObjectSetString(0, nameLSLtxt ,OBJPROP_TEXT,(Sslbb ));
                 
                  tt = NormalizeDouble(get_object(nameLSL),_Digits)  ;
                 obj_del(nameSLV);
                 obj_cre_trend(nameSLV,ti2,tt,ti2,op,clrBlue);
                      
                  }
                  else                                                                              
                  {obj_del(nameLSL);                                           
                   obj_del(nameSLV);
                  }
                 }
             if(typ==1 )    ///SELL
                 {
                   if (price<op ) wp = price ;
                   else wp= op;
                  if(but_stat(nameTP)==true)  
                  {  
                  
               //    if (tt = 0)  {  tt =op-(op/2) ; OrderModify(OrderTicket(),op,ss,tt,0,clrNONE) ;}
              
               //   tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
                 // ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);    
                  if (tt == 0)    tt =  Bid - NormalizeDouble((TakeProfit)/Lot/LSize ,_Digits);   ; //NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits); //OrderModify(OrderTicket(),op,ss,tt,0,clrNONE) 
                    
          /*            if(ObjectFind(0,nameLTP) == -1) 
                     {
                   HLineCreate(0,nameLTP,0,tt,clrOrange,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                       }
                else 
                  {
      
        datetime  ti3 = PeriodSeconds();
       
           obj_cre_trend(nameTPV,ti2+ti3,tt,ti2+ti3,op,clrOrange);
       
               obj_del(nameTPV);
         
          
               obj_cre_trend(nameTPV,ti2+ti3,tt,ti2+ti3,op,clrOrange);
                  }
         */
              
                              
                    
                     obj_cre(nameLTP,(tt),clrGreen);    //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);                   
                       tt = NormalizeDouble(get_object(nameLTP),_Digits)  ;
                      
                       ObjectDelete (nameLTPtxt);
                  
                  ObjectCreate(0,nameLTPtxt,OBJ_TEXT,0,ti2,tt);
    // ObjectSetText(nnnametxt, DoubleToString((int(tt-op/Point)*Point),Digits)+"  // ",12," nn " ,clrAqua); 
    
       
         ObjectSetString(0, nameLTPtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(double(-tt+op)/_Point*Lot*PipValues),2)
         +" $$ / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" $$ "+ Lot ); 
                      
                      obj_del(nameTPV);
                     
                     obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
                     }
                  else                                                                             
                  { 
                  obj_del(nameLTP);                                         
                   obj_del(nameTPV);
                  }
                 }
                  if ((but_stat(nameSL)==true)      ///  SELL
                //  && (but_stat(nameHH)== false  )
                 )
                  {    // ChartXYToTimePrice(0,x2-14,y,window,dt,op) ; 
                      //   ti2=dt ;
                             
                //   tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
               //   ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);   
                if ( ss ==0 )
                    ss= Ask + NormalizeDouble((StopLoss )/Lot/csize ,_Digits) ;///  SP   e goliamo//csize;   //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                                        
                     obj_cre(nameLSL,(ss),clrRed);   //    ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                   
                     obj_cre_trend(nameSLV,ti2,ss,ti2,op,clrMagenta);
                     
                       tt = NormalizeDouble(get_object(nameLSL),_Digits)  ;
                        ObjectDelete (nameLSLtxt);
            ObjectCreate(0,nameLSLtxt,OBJ_TEXT,0,ti2,tt);
            
             double   PipValues2=(((MarketInfo(Symbol(),MODE_TICKVALUE)*_Point)/MarketInfo(Symbol(),MODE_TICKSIZE)));
  // ClickValue=PipValues*((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point);
    //  ClickPip=NormalizeDouble(((MarketInfo(Symbol(),MODE_BID)-ClickPrice)/point),1);
  double   ClickValue2=PipValues2*((op-ClickPrice)/point); 
   PipValues=(((MarketInfo(Symbol(),MODE_TICKVALUE)*point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize);
   SpreadPip=MarketInfo(Symbol(),MODE_SPREAD)/point*Point;
   SpreadPipValue=(MarketInfo(Symbol(),MODE_SPREAD)/point*Point)*PipValues;
             
            // op=NormalizeDouble(OrderOpenPrice(),Digits);  
             
            
    //  Alert ( " 1 tt " ,tt," 1 op " ,op," 1 = " ,-tt+op );
             string   
         //Ssl = DoubleToString((int(tt/Point)*Point),Digits)
          // +" / "+DoubleToString(kk*(tt-op)/_Point*Lot,2) 
      ///   +"  $  Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" SL B "+ DoubleToString(Lot,2) ;
           Ssls = 
            //   "              "+  DoubleToString(kk*(-tt+op+SP)/_Point*Lot,2)        ;
                "              "+  DoubleToString(kk*(1*(-tt+op)/_Point*PipValues*Lot),2)        ;
            
         ObjectSetString(0, nameLSLtxt ,OBJPROP_TEXT,Ssls );
                 
                 
                 tt = NormalizeDouble(get_object(nameLSL),_Digits)  ;
                 obj_del(nameSLV);
                 obj_cre_trend(nameSLV,ti2,tt,ti2,op,clrBlueViolet);
                     
                  }
                  else                                                                          
                  {obj_del(nameLSL);                                         
                   obj_del(nameSLV);
                  }
               //  }
                 
               if(typ==2 || typ==4)  ///BUY pending
                 {
                  if(but_stat(nameTP)==true)                                                     
                    { 
                  if (tt == 0)    tt = op +tp   ;///+ NormalizeDouble((300) *_Point,_Digits); 
                     obj_cre(StringConcatenate("TP",tik),(tt),clrGreen);                     
                     obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
                    }
                  else                                                                         
                  {obj_del(StringConcatenate("TP",tik));                                         
                   obj_del(nameTPV);
                  }                               

                  if(but_stat(nameSL)==true)                                                    
                    { 
                     if ( ss ==0 )
                     ss=op- sl ;//// NormalizeDouble((250 *_Point) + SP,_Digits);  ////  
                     obj_cre(StringConcatenate("SL",tik),(ss),clrRed);  
                     obj_cre_trend(nameSLV,ti2,ss,ti2,op,clrMagenta);
                    }
                  else                                                                         
                  {obj_del(StringConcatenate("SL",tik));                                         
                   obj_del(nameSLV);
                  }                                   
                 }
               if(typ==3 || typ==5)          ///SELL  pending
                 {
               
                  if(but_stat(nameTP)==true)                                                      
                     {   
                      if (tt == 0)    tt =  op - tp  ;/// NormalizeDouble((700) *_Point,_Digits); 
                      obj_cre(StringConcatenate("TP",tik),(tt),clrGreen);                    
                      obj_cre_trend(nameTPV,ti2,tt,ti2,op,clrBlue);
                     }
                  else                                                                             
                  {obj_del(StringConcatenate("TP",tik));                                         
                   obj_del(nameTPV);
                  }                                     

                  if(but_stat(nameSL)==true)                                                     
                     {
                       if ( ss ==0 )
                    ss= op+  sl ;/// NormalizeDouble((200 *_Point) + SP,_Digits); 
                       obj_cre(StringConcatenate("SL",tik),(ss),clrRed);                    
                       obj_cre_trend(nameSLV,ti2,ss,ti2,op,clrMagenta);
                     }
                  else                                                                  
                  {obj_del(StringConcatenate("SL",tik));                                         
                   obj_del(nameSLV);
                  }                        
                 }
                 
             if(but_stat(nameBR)==true)      ///  brrrrr
                 {
                  if(((Ask-br)>op) && typ==0)   //+SP
                  {obj_cre(nameLBR,op,colorBreakB);    ///  colorBreak22
                     button_off( nameHH);       
                     obj_del(nameLHH);  
                    // ObjectDelete (StringConcatenate("HH",tik)+" n");
                  } 
                  if(((Bid+br)<op) && typ==1)   ///-SP
                  { obj_cre(nameLBR,op,colorBreakS);   
                     button_off( nameHH);       
                     obj_del(nameLHH);  
                   //  ObjectDelete (StringConcatenate("HH",tik)+" n");
                  }  
                 }
               else 
               {
               obj_del(nameLBR);                                         
                obj_del(nameLHH); 
                 }
                 

  
                    
              
                 
        //  if ((but_stat(nameSN)==true) &&  (tik==OrderTicket()))    ///  snnnnnnnnn
            if (ObjectGetInteger(0,nameSN,OBJPROP_STATE)==true)
          
                  {    
                  
            //      Alert ( " nameSN ", nameSN,  "  tik " ,tik  , "  order ", OrderTicket() );
               //   int orderR = checkapp();
                  
                 //   if (ObjectFind(StringConcatenate("TSN",tik))==-1)
          /*    TrendCreate(0,StringConcatenate("TSN",tik),0,Time[10],tt,Time[0],tt,clrLime,STYLE_SOLID,2);
                
                 if(ObjectFind(0,StringConcatenate("LSN",tik)) == -1) 
                     {
                   HLineCreate(0,StringConcatenate("LSN",tik),0,tt,clrLime,STYLE_DASH,1,false,true,false,100,TimeToString(TimeCurrent(),TIME_DATE));
                       }
                                     */   
                 //  tt=NormalizeDouble(get_object(StringConcatenate("TP",tik)),_Digits);
                    sn=NormalizeDouble(inSN *_Point/Lot/LSize,_Digits);
                   //  sn=inSN *_Point  ;
                 if ( sn !=0 )
                 {
                    if( typ==0)  //if(((Ask-sn)>op) && typ==0)    /// BUY
                  {
                  // obj_del(StringConcatenate("SN",tik)) ;
                  obj_cre(nameLPN,op+sn,clrCadetBlue); 
             // obj_cre(StringConcatenate("nSN",tik),op+sn,clrLime);
                
             //      tt = NormalizeDouble(get_object(nameLSN),_Digits)  ;
              // SNprice  = NormalizeDouble(get_object(nameLSN),_Digits)  ;
                  obj_del(namePNV) ;
                  obj_cre_trend(namePNV,ti2,op+sn,ti2,op,clrMagenta);
                    tt = NormalizeDouble(get_object(nameLPN),_Digits)  ;
                        ObjectDelete (nameLPNtxt);
            ObjectCreate(0,nameLPNtxt,OBJ_TEXT,0,ti2,tt); 
            ObjectSetInteger(0,nameLPNtxt,OBJPROP_COLOR,clrCadetBlue); 
         ObjectSetString(0, nameLPNtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(_Point*(tt-op)*Lot*PipValues,2)
         +"  $   /  "+ StringSubstr(nameLPN,StringFind(nameLPN,"N")) +" SN B "+ DoubleToString(Lot,2) );
                
            PNprice  = NormalizeDouble(get_object(nameLPN),_Digits)  ;
            obj_del(namePNV) ;
                  obj_cre_trend(namePNV,ti2,PNprice,ti2,op,clrMagenta);
                  // button_off( nameSL);
                 //  button_off( StringConcatenate("SN",tik));
                 //  obj_del(StringConcatenate("SL",tik));
                    
                   button_off( StringConcatenate("HH",tik));
                  obj_cre(nameLSN,op-sn,clrRed); 
                  
                       obj_del(nameSNV) ;
                   obj_cre_trend(nameSNV,ti2,op-sn,ti2,op,clrMagenta);
                 
                  tt = NormalizeDouble(get_object(nameLSN),_Digits)  ;
                        ObjectDelete (nameLSNtxt);
            ObjectCreate(0,nameLSNtxt,OBJ_TEXT,0,ti2,tt);
             ObjectSetInteger(0,nameLSNtxt,OBJPROP_COLOR,clrRed);
         ObjectSetString(0, nameLSNtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(_Point*(tt-op)*Lot*PipValues,2)
         +"  $  /  "+ StringSubstr(nameLSN,StringFind(nameLSN,"N")) +" SL B "+ DoubleToString(Lot,2) );
                 
                   SNprice = NormalizeDouble(get_object(nameLSN),_Digits)  ;
                   obj_del(nameSNV) ;
                   obj_cre_trend(nameSNV,ti2,SNprice,ti2,op,clrMagenta);
               //   if (orderR== 1 ) ///&& s<MaxOrdersCandl) 
      //  if(OrderSend(Symbol(),OP_SELL,OrderLots()/2 ,Ask,50,0,0,StringConcatenate("SN",tik),Magic,0,clrBlue)!=-1) 
       {}
                  
                    } 
                  if (typ==1)   ///if(((Bid+sn)<op) && typ==1)
                  {
                  // obj_del(StringConcatenate("SN",tik)) ;
                   obj_cre(nameLPN,op-sn,clrOrange);
              // obj_cre(StringConcatenate("nSN",tik),op-sn,clrOrange);
                 //   tt = NormalizeDouble(get_object(StringConcatenate("SN",tik)),_Digits)  ;
                 /// ti2 = NormalizeDouble(get_object(StringConcatenate("SNV",tik)),_Digits)  ;
                   
                        obj_del(namePNV) ;
                    obj_cre_trend(namePNV,ti2,op-sn,ti2,op,clrMagenta);
                     
                      tt = NormalizeDouble(get_object(nameLPN),_Digits)  ;
                        ObjectDelete (nameLPNtxt);
            ObjectCreate(0,nameLPNtxt,OBJ_TEXT,0,ti2,tt);
             ObjectSetInteger(0,nameLPNtxt,OBJPROP_COLOR,clrOrange);
         ObjectSetString(0, nameLPNtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(_Point*(-tt+op)*Lot*PipValues,2)
         +"  $   / "+StringSubstr(nameLPN,StringFind(nameLPN,"N"))+" SN S "+ DoubleToString(Lot,2) );
                 
                     
            PNprice  = NormalizeDouble(get_object(nameLPN),_Digits)  ;
            obj_del(namePNV) ;
                  obj_cre_trend(namePNV,ti2,PNprice,ti2,op,clrMagenta);
                 
                   // button_off( nameSL);
                   // button_off( StringConcatenate("SN",tik));
                //    obj_del(StringConcatenate("SL",tik)) ;
                   button_off( nameHH) ;
                   
                  obj_cre(nameLSN,op+sn,clrRed); 
                   tt = NormalizeDouble(get_object(nameLSN),_Digits)  ;  
                       obj_del(nameSNV) ;
                    obj_cre_trend(nameSNV,ti2,op+sn,ti2,op,clrMagenta);
                      
                        ObjectDelete (nameLSNtxt);
            ObjectCreate(0,nameLSNtxt,OBJ_TEXT,0,ti2,tt);
              ObjectSetInteger(0,nameLSNtxt,OBJPROP_COLOR,clrRed);
         ObjectSetString(0, nameLSNtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(_Point*(-tt+op)*Lot*PipValues,2)
         +"  $   /  "+ StringSubstr(nameLSN,StringFind(nameLSN,"N")) +" SL S "+ DoubleToString(Lot,2) );
                 
                   
                   SNprice = NormalizeDouble(get_object(nameLSN),_Digits)  ;
                   obj_del(nameSNV) ;
                   obj_cre_trend(nameSNV,ti2,SNprice,ti2,op,clrMagenta);
                 
                 
               //     if (orderR== 1 ) ///&& s<MaxOrdersCandl) 
     //  if(OrderSend(Symbol(),OP_BUY,OrderLots()/2 ,Ask,50,0,0,StringConcatenate("SN",tik),Magic,0,clrBlue)!=-1) 
           {}
                   
                    }
                    
              
                
                 
                    }   
                    
                  //  ss= Bid - NormalizeDouble((StopLoss *_Point) + SP,_Digits);  //NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits);                            
                   //  obj_cre(StringConcatenate("SN",tik),(ss),clrRed);// ss=NormalizeDouble(get_object(StringConcatenate("SL",tik)),_Digits); 
                    //  obj_cre_trend(nameSNV,ti2,op-sn,ti2,op,clrMagenta);
                  }
                  
                  else                                                                              
                  {
                  obj_del(nameLSN);                                           
                   obj_del(nameSNV);
                    obj_del(nameLPN);                                           
                   obj_del(namePNV);
                   
                    obj_del(nameLSNtxt);                                           
                  // obj_del(nameSNV);
                    obj_del(nameLPNtxt);                                           
                  // obj_del(namePNV);
                 
                  // obj_del(nameLSL);                                           
                 /// obj_del(nameSLV);
                 //   obj_cre_trend(nameSNV,ti2,SNprice,ti2,op,clrYellow);
                 //   obj_cre_trend(nameSLV,ti2,SLprice,ti2,op,clrYellow);
                    
                   
                  }
                        
                 
               
               if(but_stat(nameTR)==true)    /// trrrrr
                 {
                 tr=NormalizeDouble(TralingStop,_Digits); 
                  if(((Ask-tr)>op) && typ==0) 
                  {
                  obj_cre(nameLTR,Ask-tr,clrLime); 
                 //     nnname =       StringConcatenate("TR",tik) ;
             //    nnnametxt =       StringConcatenate("TR",tik)+"_txt" ;
      /*         
                  ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(tt-op)*Lot*PipValues,0)
         +" Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" ### "+ Lot+" #" +Point );
         */
              tt = NormalizeDouble(get_object(nameLTR),_Digits)  ;
                        ObjectDelete (nameLTRtxt);
                  
                  ObjectCreate(0,nameLTRtxt,OBJ_TEXT,0,ti2,tt);
     ObjectSetText(nameLTRtxt, DoubleToString((int(tt-op)/Point),Digits)+"  // ",12," nn " ,clrAqua);
   //      ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
      //   +" / "+DoubleToString(kk*(tt-op)/Point*Lot,0)
     //    +" Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" ///$ "+ Lot );
      ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(tt-op)*Lot*PipValues,2)
         +"  $ /  "+StringSubstr(nameLTR,StringFind(nameLTR,"T"))+" S "+ DoubleToString(Lot,2) );
         
         obj_del(nameTRV) ;
                  obj_cre_trend(nameTRV,ti2,tt,ti2,op,clrLime);
            
       
                   
                  }    
                  if(((Bid+tr)<op) && typ==1)
                  {
                   obj_cre(nameLTR,Bid+tr,clrLime);
                //    nameTR =       StringConcatenate("TR",tik) ;
               ///  nameTRLtxt" =       StringConcatenate("TR",tik)+"_txt" ;
               
      ///            ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
     ////    +" / "+DoubleToString(kk*(tt-op)*Lot,0)
     ///    +" Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" ### "+ Lot+" #" +Point );
         
              tt = NormalizeDouble(get_object(nameLTR),_Digits)  ;
                        ObjectDelete (nameLTRtxt);
                  
                  ObjectCreate(0,nameLTRtxt,OBJ_TEXT,0,ti2,tt);
     ObjectSetText(nameLTRtxt, DoubleToString((int(tt-op)/Point),Digits)+"  // ",12," nn " ,clrAqua);
     ///    ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
      ///   +" / "+DoubleToString(kk*(tt-op)/Point*Lot,0)
        /// +" Pips / EQ= "+DoubleToString(AccountInfoDouble (ACCOUNT_EQUITY),2)+" ///$ "+ Lot );
                    ObjectSetString(0, nameLTRtxt ,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
         +" / "+DoubleToString(kk*(op-tt)*Lot*PipValues,2)
         +"  $ /  "+StringSubstr(nameLTR,StringFind(nameLTR,"T"))+" S "+ DoubleToString(Lot,2) );
         
         obj_del(nameTRV) ;
                  obj_cre_trend(nameTRV,ti2,tt,ti2,op,clrLime);
            
                   
                   
                   }    
                 }
               else {
               obj_del(nameLTR); 
                obj_del(nameLTRtxt);
                obj_del(nameTRV);   
                ///obj_del(nameTRVtxt);                                        
                    }
               if(but_stat(nameTI)==true)                                                          
                  obj_cre_v_line(StringConcatenate("ti",tik),clrGreen);                   
               else                                                                           
               obj_del(StringConcatenate("ti",tik));     
              
                     
     
               }     
             
          //   OnTick  ,  OnTimer
             
               if(ObjectFind(0,prefix+"TradeLine")!=0) 
      ButtonCreate(0,"TradeLine",0,1400,350,90,16,0,"----MENU------","Arial",10,clrBlack,C'236,233,216',clrNONE,false,false,true); 

   int x0=(int)IntGetX ("TradeLine");         
   int y0=(int)IntGetY ("TradeLine");  
   
 //  Lot=0.10;   
 int   xx=1300, yy=CORNER_RIGHT_UPPER+20, lo =80;
 
  ButtonCreate(0,"CLEAN",0,CORNER_RIGHT_UPPER+300,CORNER_RIGHT_UPPER,60,16,0,"CL "+DoubleToStr(ATR5,2),"Arial",Width,clrBlack,C'236,233,216'); 
  
   ButtonCreate(0,"nCLEAN ALL",0,CORNER_RIGHT_UPPER+500,CORNER_RIGHT_UPPER,90,16,0,"nCL ALL "+DoubleToStr(ATR15,2),"Arial",Width,clrBlack,C'236,233,216'); 
   
   ObjectDelete(0,"labPrice");
          if (ObjectFind(0,"labPrice")==-1)  
           LabelCreate2(0,StringConcatenate("labPrice"),0,xx,yy+270,CORNER_LEFT_UPPER,DoubleToString( (Bid),2)+"$","Arial",fontsizeEQ,clrMagenta,0,ANCHOR_LEFT_UPPER);
      
 
  if  ((but_stat(prefix+"Lh2")==false) )
       {
   ObjectDelete(0 ,nameLHPtxt+LineId+1);
   if (ObjectFind(nameLHPtxt+LineId+1)<0)
           {
           double LHsumaP;
          if ((lotMG < 0) && (LHsuma > 0))
            LHsumaP = Bid-MathAbs(((LHsuma))/(LB-LS)/csize);
            if  ((lotMG < 0) && (LHsuma < 0))
            LHsumaP = Ask+MathAbs(((LHsuma))/(LB-LS)/csize);
           
          if ((lotMG > 0) && (LHsuma >0))
            LHsumaP = Ask+MathAbs(((LHsuma))/(LB-LS)/csize) ;
            if    ((lotMG > 0) && (LHsuma <0))
            LHsumaP = Bid-MathAbs(((LHsuma))/(LB-LS)/csize);
           
        /*   if  (Hsuma >0)
           { HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
             if (lotMG < 0)
            HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
           }
          if  (Hsuma <0)
           { HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
         
            if  ( lotMG > 0 ) 
            HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
           }*/
            if  ((but_stat(prefix+"d50")!=true)  )   ///findAtr
            if (Time[1] != iBars(Symbol(),0) ) // newbar
            {
              if (ObjectFind(0,"atr0")==-1)
            obj_del ("atr0");
               obj_cre_trend("atr0",Time[10] ,Ask+NormalizeDouble(koefATR*ATR15,2),Time[1] ,Ask+NormalizeDouble(ATR15,2),clrYellow );
              if (ObjectFind(0,"atr1")==-1)
              obj_del ("atr1");
               obj_cre_trend("atr1",Time[10] ,Ask+NormalizeDouble(koefATR*ATR5,2),Time[1] ,Ask+NormalizeDouble(ATR5,2),clrRed );
                if (ObjectFind(0,"atr2")==-1)
                 obj_del ("atr2");
               obj_cre_trend("atr2",Time[10] ,Bid-NormalizeDouble(koefATR*ATR5,2),Time[1] ,Bid-NormalizeDouble(ATR5,2),clrRed );
        if (ObjectFind(0,"atr3")==-1)
          obj_del ("atr3");
               obj_cre_trend("atr3",Time[10] ,Bid-NormalizeDouble(koefATR*ATR15,2),Time[1] ,Bid-NormalizeDouble(ATR15,2),clrYellow );
         }
         //   ObjectCreate("atr2",OBJ_TREND,0,Time[10],Bid+NormalizeDouble(ATR5,2),Time[1],Bid+NormalizeDouble(ATR5,2));
              
               ObjectCreate(nameLHPtxt+LineId+1,OBJ_HLINE,0,Time[10],LHsumaP,Time[0],LHsumaP);
               
              // ObjectSetString(0,"cm__Vsuma_p",OBJPROP_TOOLTIP,DoubleToString(accEQ+Hsuma,2)+" USD");
          ObjectSetInteger(0,nameLHPtxt+LineId+1, OBJPROP_STYLE,STYLE_DOT); 
         //   ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_SELECTED,true); 
           //    ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrYellow); 
               ObjectSetInteger(0,nameLHPtxt+LineId+1, OBJPROP_WIDTH,3); 
            ObjectSetInteger(0,nameLHPtxt+LineId+1, OBJPROP_SELECTED,true); 
               ObjectSetInteger(0,nameLHPtxt+LineId+1, OBJPROP_COLOR,clrBlueViolet); 
             //  calcP();
             
           //  tt=HsumaP; 
              tt = NormalizeDouble(get_object(nameLHPtxt+LineId+1),_Digits)  ;
                LHsumaP=tt ;
             
              if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLHPtxt+LineId+1,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Bid))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "## EQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else
        {
         znak=1 ;
         ObjectSetString(0, nameLHPtxt+LineId+1,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Ask))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "## EQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }

     }
     }
     
     
  //    ButtonCreate(0,"EEQ",0,CORNER_RIGHT_UPPER+1400,200,50,16,0,"EEQ","Arial",Width,clrBlack,C'236,233,216');
  //     ButtonCreate(0,"lotEQ",0,CORNER_RIGHT_UPPER+1470,200,50,16,0, 
  //     DoubleToString((lotMG*(VEQ - AccountInfoDouble(ACCOUNT_EQUITY))/Hsuma),2),"Arial",Width,clrBlack,C'236,233,216');
      
  // ButtonCreate(0,"mylotEQ",0,CORNER_RIGHT_UPPER+1400,150,50,16,0, 
  // DoubleToString(((VEQ - AccountInfoDouble(ACCOUNT_EQUITY))/SumMG*lotMG),2),"Arial",Width,clrBlack,C'236,233,216');
      
  
      if  ((but_stat(prefix+"EEQ")==false) )
         {
   ObjectDelete(0 ,nameLEQtxt+LineId);
   if (ObjectFind(nameLEQtxt+LineId)<0)
           {
           double HsumaP;
           double EQsumaP;
           EQsumaP  =  VEQ - AccountInfoDouble(ACCOUNT_EQUITY) ;
          if ((lotMG < 0) && (EQsumaP > 0))
            HsumaP = Bid-MathAbs(((EQsumaP))/(LB-LS)/csize);
            if  ((lotMG < 0) && (EQsumaP < 0))
            HsumaP = Ask+MathAbs(((EQsumaP))/(LB-LS)/csize);
           
          if ((lotMG > 0) && (EQsumaP >0))
            HsumaP = Ask+MathAbs(((EQsumaP))/(LB-LS)/csize) ;
            if    ((lotMG > 0) && (EQsumaP <0))
            HsumaP = Bid-MathAbs(((EQsumaP))/(LB-LS)/csize);
           
           
           
             // HsumaP =    HsumaP+100;
        /*   if  (Hsuma >0)
           { HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
             if (lotMG < 0)
            HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
           }
          if  (Hsuma <0)
           { HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
         
            if  ( lotMG > 0 ) 
            HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
           }*/
           
               ObjectCreate(nameLEQtxt+LineId,OBJ_HLINE,0,Time[10],HsumaP,Time[0],HsumaP);
               
              // ObjectSetString(0,"cm__Vsuma_p",OBJPROP_TOOLTIP,DoubleToString(accEQ+Hsuma,2)+" USD");
          ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_STYLE,STYLE_DASHDOTDOT); 
         //   ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_SELECTED,true); 
           //    ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_COLOR,clrYellow); 
               ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_WIDTH,1); 
            ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_SELECTED,true); 
               ObjectSetInteger(0,nameLEQtxt+LineId, OBJPROP_COLOR,clrLime); 
             //  calcP();
             
           //  tt=HsumaP; 
              tt = NormalizeDouble(get_object(nameLEQtxt+LineId),_Digits)  ;
                HsumaP=tt ;
             
              if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLEQtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Bid))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(HsumaP,2) + "## EEQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else
        {
         znak=1 ;
         ObjectSetString(0, nameLEQtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Ask))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(HsumaP,2) + "## EEQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }

     }
    
   }
     
  if  ((but_stat(prefix+"lock h2")==false) )
       {
   ObjectDelete(0 ,nameLHPtxt+LineId);
   if (ObjectFind(nameLHPtxt+LineId)<0)
           {
           double HsumaP;
          if ((lotMG < 0) && (Hsuma > 0))
            HsumaP = Bid-MathAbs(((Hsuma))/(LB-LS)/csize);
            if  ((lotMG < 0) && (Hsuma < 0))
            HsumaP = Ask+MathAbs(((Hsuma))/(LB-LS)/csize);
           
          if ((lotMG > 0) && (Hsuma >0))
            HsumaP = Ask+MathAbs(((Hsuma))/(LB-LS)/csize) ;
            if    ((lotMG > 0) && (Hsuma <0))
            HsumaP = Bid-MathAbs(((Hsuma))/(LB-LS)/csize);
           
        /*   if  (Hsuma >0)
           { HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
             if (lotMG < 0)
            HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
           }
          if  (Hsuma <0)
           { HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
         
            if  ( lotMG > 0 ) 
            HsumaP = Ask+((Hsuma))/(LB-LS)/csize;
           }*/
           
               ObjectCreate(nameLHPtxt+LineId,OBJ_HLINE,0,Time[10],HsumaP,Time[0],HsumaP);
               
              // ObjectSetString(0,"cm__Vsuma_p",OBJPROP_TOOLTIP,DoubleToString(accEQ+Hsuma,2)+" USD");
          ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_STYLE,STYLE_DOT); 
         //   ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_SELECTED,true); 
           //    ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrYellow); 
               ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_WIDTH,3); 
            ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_SELECTED,true); 
               ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrLime); 
             //  calcP();
             
           //  tt=HsumaP; 
              tt = NormalizeDouble(get_object(nameLHPtxt+LineId),_Digits)  ;
                HsumaP=tt ;
             
              if(lotMG < 0)
        {
         znak=-1;
         ObjectSetString(0, nameLHPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Bid))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "## EQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);

        }

      else
        {
         znak=1 ;
         ObjectSetString(0, nameLHPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Ask))*lotMG/_Point),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "## EQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
        }

     }
    
   }
   // double  Vkoef = 1;
   
    if(ObjectFind("koefATR")==-1)
      EditCreate(0,"koefATR",0,CORNER_RIGHT_UPPER+460,0,30,16,DoubleToString(koefATR,2),"Arial",8,ALIGN_CENTER,false);
   koefATR = StringToDouble(ObjectGetString(0,"koefATR",OBJPROP_TEXT));
   
  if(ObjectFind("LVkoef")==-1)
      EditCreate(0,"LVkoef",0,CORNER_RIGHT_UPPER+640,0,30,16,DoubleToString(LVkoef,2),"Arial",8,ALIGN_CENTER,false);
   LVkoef = StringToDouble(ObjectGetString(0,"LVkoef",OBJPROP_TEXT));
  
   if(ObjectFind("LHsuma")==-1)
         EditCreate(0,"LHsuma",0,CORNER_RIGHT_UPPER+680,0,lo,16,DoubleToString(LHsuma,0),"Arial",8,ALIGN_CENTER,false);
   LHsuma = StringToDouble(ObjectGetString(0,"LHsuma",OBJPROP_TEXT));
   //ObjectDelete(0 ,nameLHPtxt+LineId);
   // button_off("lock h");
   
   
    ButtonCreateR(0,"Lh2",0,CORNER_RIGHT_UPPER+600,0,30,16,0," 2Lh ","Arial",Width,clrBlack,C'236,233,216');
      
     
   
  // double  Vkoef = 1;
  if(ObjectFind("Vkoef")==-1)
      EditCreate(0,"Vkoef",0,CORNER_RIGHT_UPPER+860,0,30,16,DoubleToString(Vkoef,2),"Arial",8,ALIGN_CENTER,false);
   Vkoef = StringToDouble(ObjectGetString(0,"Vkoef",OBJPROP_TEXT));
  
   if(ObjectFind("Hsuma")==-1)
         EditCreate(0,"Hsuma",0,CORNER_RIGHT_UPPER+900,0,lo,16,DoubleToString(Hsuma,0),"Arial",8,ALIGN_CENTER,false);
   Hsuma = StringToDouble(ObjectGetString(0,"Hsuma",OBJPROP_TEXT));
   //ObjectDelete(0 ,nameLHPtxt+LineId);
   // button_off("lock h");
   
   
    ButtonCreateR(0,"lock h2",0,CORNER_RIGHT_UPPER+800,0,50,16,0," lock2 ","Arial",Width,clrBlack,C'236,233,216');
      
       if  ((but_stat(prefix+"lock h2")==true) )
       {
        // ObjectDelete(0 ,nameLHPtxt+LineId);
     //  if (ObjectFind(nameLHPtxt+LineId)<0)
           {
           double HsumaP;
         /*  if ((lotMG < 0))
            HsumaP = Bid-((Hsuma))/(LB-LS)/csize;
            
           
            if  (( lotMG > 0 ))
            HsumaP = Ask+((Hsuma))/(LB-LS)/csize;*/
       
          if ((lotMG < 0) && (Hsuma > 0))
            HsumaP = Bid-MathAbs(((Hsuma))/(LB-LS)/csize);
            if  ((lotMG < 0) && (Hsuma < 0))
            HsumaP = Ask+MathAbs(((Hsuma))/(LB-LS)/csize);
           
          if ((lotMG > 0) && (Hsuma >0))
            HsumaP = Ask+MathAbs(((Hsuma))/(LB-LS)/csize) ;
            if    ((lotMG > 0) && (Hsuma <0))
            HsumaP = Bid-MathAbs(((Hsuma))/(LB-LS)/csize);
            
            ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrYellow); 
           
               ObjectCreate(nameLHPtxt+LineId,OBJ_HLINE,0,Time[10],HsumaP,Time[0],HsumaP);
               
              // ObjectSetString(0,"cm__Vsuma_p",OBJPROP_TOOLTIP,DoubleToString(accEQ+Hsuma,2)+" USD");
        tt = NormalizeDouble(get_object(nameLHPtxt+LineId),_Digits)  ;
        // ObjectDelete(nameLHPtxt+LineId);

     // ObjectCreate(0,nameLHPtxt+LineId,OBJ_HLINE,0,tt,tt);
                       
        
          ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_STYLE,STYLE_DOT); 
           ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_WIDTH,4); 
            ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_SELECTED,true); 
               ObjectSetInteger(0,nameLHPtxt+LineId, OBJPROP_COLOR,clrYellow); 
        ObjectCreate(0,nameLHPtxt+LineId,OBJ_TEXT,0,tt,tt);
    
               // tt=HsumaP; 
               
               
                // HsumaP=tt ;
                 
                 if(lotMG < 0)
        {
         znak=-1;  //---
        // ObjectSetString(0,txt,OBJPROP_TOOLTIP,txt);
        ObjectSetString(0,nameLHPtxt+LineId,OBJPROP_TEXT,"                "+HsumaP); 
         ObjectSetString(0, nameLHPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((-tt+Bid))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "# EQqq= "+DoubleToString((znak*kk*(double((-tt+Bid))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
                
        }

      else
        {
         znak=1 ;
           ObjectSetString(0,nameLHPtxt+LineId,OBJPROP_TEXT,"                "+HsumaP); 
        
         ObjectSetString(0, nameLHPtxt+LineId,OBJPROP_TEXT,DoubleToString((int(tt/Point)*Point),Digits)
                         +" / "+DoubleToString(znak*kk*(double((tt-Ask))*lotMG*tval/tsize),2)
                         +" $$ /                  "+ DoubleToString(-ClickValue,2) + "# EQqq= "+DoubleToString((znak*kk*(double((tt-Ask))*lotMG/_Point))+AccountInfoDouble(ACCOUNT_EQUITY),2)+" $$ lot "+ lotMG);
       
          
        }

     
               
             //  SetIndexStyle(0,DRAW_SECTION,2,clrRed);
          //   Hsuma =Hsuma-((HsumaP-Bid)*csize*(LB-LS)) ;
               }
       
    //   if ( lotMG > 0)  OrderSend(Symbol(),OP_SELL, MathAbs(lotMG) ,Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrRed) ; 
  //  if ( lotMG < 0)  OrderSend(Symbol(),OP_BUY, MathAbs(lotMG) ,Ask,50,0,0,StringConcatenate("Lock B",tik),Magic,0,clrRed) ; 
    // button_off("lock h");
    
     ObjectDelete("Hsuma") ;  
    if(ObjectFind("Hsuma")==-1)
       EditCreate(0,"Hsuma",0,CORNER_RIGHT_UPPER+900,0,lo,16,DoubleToString(Hsuma,0),"Arial",8,ALIGN_CENTER,false);
   Hsuma = StringToDouble(ObjectGetString(0,"Hsuma",OBJPROP_TEXT));
   
     WindowRedraw();  
   //ObjectDelete(0 ,nameLHPtxt+LineId);
   // button_off("lock h");
       }
   
   ButtonCreate(0,"d50",0,CORNER_RIGHT_UPPER+400,CORNER_RIGHT_UPPER,40,16,0,"d50","Arial",Width,clrBlack,C'236,233,216'); 
       ButtonCreateR(0,"bbNL",0,CORNER_RIGHT_UPPER+xx,0,lo,16,0,"bbNL","Arial",Width,clrBlack,C'236,233,216');   
   //    ButtonCreateR(0,"mNL",0,CORNER_RIGHT_UPPER+xx-150,0,lo-100,16,0,"myNL","Arial",Width,clrBlack,C'236,233,216');   
      
     ButtonCreate(0,"2NL",0,CORNER_RIGHT_UPPER+1250,CORNER_RIGHT_UPPER,40,16,0,"2NL","Arial",Width,clrBlack,C'236,233,216'); 
     
     // button_on("NF") ;
       ButtonCreate(0,"NF",0,CORNER_RIGHT_UPPER+1200,CORNER_RIGHT_UPPER,40,16,0,"NF","Arial",Width,clrBlack,C'236,233,216');
       
        if((but_stat(prefix+"NF")==true))
        notification = true;
        else
        notification = false;
        
     // button_on(prefix+"bbNL");
      if((but_stat(prefix+"2NL")==true))
     {
    // Alert ( " 2NL minava ");
      calcC () ;  ///tuk e History
       // Alert("bbnnll");  /tuk e bnl
     // CalcPosition();
      //  dimi();

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();

      //  handleButtonClicks();
     }    
     if((but_stat(prefix+"bbNL")==true))
     {

      calcC() ;  ///tuk e History
       // Alert("bbnnll");  /tuk e bnl
     // CalcPosition();
      //  dimi();

      //     WindowRedraw();
      // button_off(prefix+"bNL");
      // tick4();

      //  handleButtonClicks();
     }                    
      //  ButtonCreate(0,"CLEAN ALL",0,CORNER_RIGHT_UPPER+600,CORNER_RIGHT_UPPER,90,16,0,"CLEAN ALL "+DoubleToStr(Hedge,2),"Arial",Width,clrBlack,C'236,233,216'); 
    /* if  ((but_stat(prefix+"bNL")==true) )
            {
           // Alert("bnl");
               calcP(); 
                WindowRedraw();
          //  button_off(prefix+"CLEAN ALL");
          // tick4();
            }
  */
  
    if(ObjectFind("Vsuma2")==-1)
      EditCreate(0,"Vsuma2",0,CORNER_RIGHT_UPPER+xx+100,0,lo,16,DoubleToString(Vsuma2,0),"Arial",8,ALIGN_CENTER,false);
   Vsuma2 = StringToDouble(ObjectGetString(0,"Vsuma2",OBJPROP_TEXT));

  
  ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",Width,clrBlack,C'236,233,216'); ///+DoubleToStr(glot,2)
  
  
    LabelCreate(0,"labLot1",0,xx-70,yy+0,CORNER_LEFT_UPPER,"Lot1","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
   
   if (ObjectFind("Lot1")==-1)  
  EditCreate(0,"Lot1",0,CORNER_RIGHT_UPPER+xx,yy,lo,16,DoubleToString(glot,2),"Arial",8,ALIGN_CENTER,false); 
 
  
 // EditCreate(0,"Lot1",0,x0+40,y0+14,60,16,DoubleToString(glot,2),"Arial",8,ALIGN_RIGHT,false); 
 //  ObjectSetText("Lot2"+ CurrencyFormat(double(OrderTakeProfit()),AccountInfoString(ACCOUNT_CURRENCY),CurrencySymbolRight),10,"Courier New",clrBeige);
   //   TextCreate(0,"Lot3",0,ti2,ss, DoubleToStr(OrderLots(),2)  ,"Arial",10,OrderLots()<0? clrYellowGreen:clrWhiteSmoke);
      
 Lot=StringToDouble(ObjectGetString(0,"Lot1",OBJPROP_TEXT));
  glot=Lot; 
  
     LabelCreate(0,"labMAG1",0,xx-70,yy+20,CORNER_LEFT_UPPER,"open MG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
     if (ObjectFind("MAG1")==-1)
  EditCreate(0,"MAG1",0,CORNER_RIGHT_UPPER+xx,yy+20,lo,16,DoubleToString(Magic,0),"Arial",8,ALIGN_CENTER,false); 
      Magic=  StringToDouble(ObjectGetString(0,"MAG1",OBJPROP_TEXT));
    
     LabelCreate(0,"labMAG2",0,xx-90,yy+40,CORNER_LEFT_UPPER,"manage MG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
      if (ObjectFind("MAG2")==-1)
  EditCreate(0,"MAG2",0,CORNER_RIGHT_UPPER+xx,yy+40,lo,16,DoubleToString(MagicALL,0),"Arial",8,ALIGN_CENTER,false); 
      MagicALL=  StringToDouble(ObjectGetString(0,"MAG2",OBJPROP_TEXT));
      
      
               LabelCreate(0,"labTP",0,xx-20,yy+80,CORNER_LEFT_UPPER,"TP","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
     if (ObjectFind("TakeProfit")==-1)   
 EditCreate(0,"TakeProfit",0,CORNER_RIGHT_UPPER+xx,yy+80,lo,16,DoubleToString(TakeProfit,0),"Arial",8,ALIGN_CENTER,false); 
 TakeProfit = StringToDouble(ObjectGetString(0,"TakeProfit",OBJPROP_TEXT));
    
    
      LabelCreate(0,"labSL",0,xx-20,yy+100,CORNER_LEFT_UPPER,"SL","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
     if (ObjectFind("StopLoss")==-1)   
 EditCreate(0,"StopLoss",0,CORNER_RIGHT_UPPER+xx,yy+100,lo,16,DoubleToString(StopLoss,0),"Arial",8,ALIGN_CENTER,false); 
 StopLoss = StringToDouble(ObjectGetString(0,"StopLoss",OBJPROP_TEXT));
 //SL= NormalizeDouble(StopLoss,_Digits);
   /*  if (ObjectFind("koef")==-1)   
 EditCreate(0,"koef",0,CORNER_RIGHT_UPPER+xx,yy+120,lo,16,DoubleToString(koef,2),"Arial",8,ALIGN_CENTER,false); 
 koef = StringToDouble(ObjectGetString(0,"koef",OBJPROP_TEXT));
 */
 LabelCreate(0,"labTR",0,xx-20,yy+120,CORNER_LEFT_UPPER,"TR","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
   if (ObjectFind("TR")==-1)   
 EditCreate(0,"TR",0,CORNER_RIGHT_UPPER+xx,yy+120,lo,16,DoubleToString(TralingStop,0),"Arial",8,ALIGN_CENTER,false); 
 TralingStop = StringToDouble(ObjectGetString(0,"TR",OBJPROP_TEXT)); 
 
 
 ///LabelCreate(0,"inSN",0,CORNER_RIGHT_UPPER+150,CORNER_RIGHT_UPPER+140,80,16,DoubleToString(inSN,0),"Arial",8,ALIGN_CENTER,false); 
    
    // LabelCreate(0,StringConcatenate("labSN",OrderTicket()),0,x2+295,y2,CORNER_LEFT_UPPER,DoubleToString( OrderMagicNumber(),0)+"","Arial",10,clrBeige,0,ANCHOR_LEFT_UPPER);
     
   LabelCreate(0,StringConcatenate("labSN",OrderTicket()),0,xx-20,yy+140,CORNER_LEFT_UPPER,"SN","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
       if (ObjectFind("inSN")==-1)   
 EditCreate(0,"inSN",0,CORNER_RIGHT_UPPER+xx,yy+140,lo,16,DoubleToString(inSN,0),"Arial",8,ALIGN_CENTER,false); 
 inSN = StringToDouble(ObjectGetString(0,"inSN",OBJPROP_TEXT));
   
      LabelCreate(0,StringConcatenate("labTH",OrderTicket()),0,xx-30,yy+160,CORNER_LEFT_UPPER,"TH $","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
        if (ObjectFind("Hedge")==-1)  
       EditCreate(0,"Hedge",0,CORNER_RIGHT_UPPER+xx,yy+160,lo,16,DoubleToString(Hedge,0),"Arial",8,ALIGN_CENTER,false); 
      Hedge = StringToDouble(ObjectGetString(0,"Hedge",OBJPROP_TEXT));
     
     
      LabelCreate(0,"labRisk",0,xx-30,yy+60,CORNER_LEFT_UPPER,"Risk","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER); 
      if (ObjectFind("risksuma")==-1) 
         EditCreate(0,"risksuma",0,CORNER_RIGHT_UPPER+xx,yy+60,lo,16,DoubleToString(risksuma,0),"Arial",8,ALIGN_CENTER,false); 
 risksuma = StringToDouble(ObjectGetString(0,"risksuma",OBJPROP_TEXT));
    //  Hedge =  risksuma/MarketInfo(Symbol(),MODE_TICKVALUE)* Lot ; //MarketInfo(Symbol(),MODE_TICKVALUE)/100 ;
     
     
      if (ObjectFind("Vsuma")==-1)  
       EditCreate(0,"Vsuma",0,CORNER_RIGHT_UPPER+xx,yy+180,lo,16,DoubleToString(Vsuma,0),"Arial",8,ALIGN_CENTER,false); 
      Vsuma = StringToDouble(ObjectGetString(0,"Vsuma",OBJPROP_TEXT));
         
         
      LabelCreate2(0,StringConcatenate(prefix+"labVEQ",OrderTicket()),0,xx+30,yy+210,CORNER_LEFT_UPPER,DoubleToString( AccountInfoDouble (ACCOUNT_EQUITY),2)+"EQ","Arial",fontsizeEQ,clrBeige,0,ANCHOR_LEFT_UPPER);
      
         if (ObjectFind("VEQ")==-1)  
       EditCreate(0,"VEQ",0,CORNER_RIGHT_UPPER+xx,yy+200,lo,16,DoubleToString(VEQ,0),"Arial",8,ALIGN_CENTER,false); 
      VEQ = StringToDouble(ObjectGetString(0,"VEQ",OBJPROP_TEXT));
      
      if ( ( VEQ -Vsuma > (AccountInfoDouble (ACCOUNT_EQUITY)) ) ||( VEQ +Vsuma < (AccountInfoDouble (ACCOUNT_EQUITY)) ) )
           if ( mynotification == true )
        {  
        VEQ = (AccountInfoDouble (ACCOUNT_EQUITY)) ;
         ObjectDelete (StringConcatenate("VEQ")) ;
           
         EditCreate(0,"VEQ",0,CORNER_RIGHT_UPPER+xx,yy+200,lo,16,DoubleToString(VEQ,0),"Arial",8,ALIGN_CENTER,false); 
    
        SendNotification ( Symbol()+" = "+DoubleToString(lotMG,2) +" V "+ DoubleToString(Vsuma,2)+ " EQ " +DoubleToString(AccountEquity(),2 ) ) ;
        
           //  SendNotification ( Symbol() +" buy "+ DoubleToString(LB,2)+ " sell " +DoubleToString(LS,2)+ 
           //  " raz " + DoubleToString((LB-LS),2)+" EQ " +DoubleToString(AccountEquity(),2 ) ) ;
        }
     
               

        /////         errrr }
    //  Alert( "lot  "+ i + "  " +DoubleToString( LB,2 )+ " " +DoubleToString( LS,2 )+ " " +DoubleToString( lotMG,2 ));
    
     LB=0; LS=0;
     calcPN (calMG2);
     
    //  lotMG= LB-LS ;
      lotMG2= LB-LS   ;/// lotMG;
      SumMG2= SumMG;
     
      
             
      obj_del("lotMG2");
        if (ObjectFind("lotMG2")==-1)  
        {
     //  EditCreate(0,"lotMG",0,CORNER_RIGHT_UPPER+xx,yy+240,lo,16,DoubleToString(lotMG,2),"Arial",8,ALIGN_CENTER,false); 
    
     EditCreate(0,"lotMG2",0,x0-100,y0+204,90,16,DoubleToString(lotMG2,2),"Arial",8,ALIGN_CENTER,false); 
    
     // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
        }
         obj_del("SumMG2");
        if (ObjectFind("SumMG2")==-1)  
        {
    //   EditCreate(0,"SumMG",0,CORNER_RIGHT_UPPER+xx,yy+260,lo,16,DoubleToString(SumMG,2),"Arial",8,ALIGN_CENTER,false); 
   // ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",Width,clrBlack,C'236,233,216'); ///+DoubleToStr(glot,2)
  
       EditCreate(0,"SumMG2",0,x0-100,y0+244,90,16,DoubleToString(SumMG2,2),"Arial",8,ALIGN_CENTER,false); 
    
    
     // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
        }
    
    
     calcPN (calMG);
    
        obj_del("lotMG");
        if (ObjectFind("lotMG")==-1)  
        {
     //  EditCreate(0,"lotMG",0,CORNER_RIGHT_UPPER+xx,yy+240,lo,16,DoubleToString(lotMG,2),"Arial",8,ALIGN_CENTER,false); 
    
     EditCreate(0,"lotMG",0,x0,y0+204,90,16,DoubleToString(lotMG,2),"Arial",8,ALIGN_CENTER,false); 
    
     // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
        }
         obj_del("SumMG");
        if (ObjectFind("SumMG")==-1)  
        {
    //   EditCreate(0,"SumMG",0,CORNER_RIGHT_UPPER+xx,yy+260,lo,16,DoubleToString(SumMG,2),"Arial",8,ALIGN_CENTER,false); 
   // ButtonCreate(0,"Lots",0,x0,y0+14,90,16,0,"LOTS "+DoubleToStr(glot,2),"Arial",Width,clrBlack,C'236,233,216'); ///+DoubleToStr(glot,2)
  
       EditCreate(0,"SumMG",0,x0,y0+244,90,16,DoubleToString(SumMG,2),"Arial",8,ALIGN_CENTER,false); 
    
    
     // lotMG = StringToDouble(ObjectGetString(0,"lotMG",OBJPROP_TEXT));
        }
  
  ///  LabelCreate(0,StringConcatenate("calMG",OrderTicket()),0,xx-40,yy+120,CORNER_LEFT_UPPER,"CalMG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
  // calMG = savecalMG ;
 //// calMG = StringToDouble(ObjectGetString(0,"MAG1",OBJPROP_TEXT));
   // obj_del("calMG");
   LabelCreate(0,StringConcatenate("textcalMG",OrderTicket()),0,x0-150,y0,CORNER_LEFT_UPPER,"1789CalMG","Arial",10,clrWhite,0,ANCHOR_LEFT_UPPER);
  
      //  ObjectDelete( 0,"calMG" ); 
        
        obj_del("calMG"); //calMG= 0 ;
      if (ObjectFind("NcalMG")==-1)  
     // { 
       EditCreate(0,"NcalMG",0,x0-100,y0,90,16,DoubleToString(calMG,0),"Arial",8,ALIGN_CENTER,false); 
      calMG = StringToDouble(ObjectGetString(0,"NcalMG",OBJPROP_TEXT));
   //  savecalMG = calMG ;
     //  ObjectFind("calMG");
     // ObjectSetDouble( 0,"calMG",OBJPROP_PRICE, calMG);
       
      // calMG = 4 ;
     
      LB=0; LS=0;
      calcPN( calMG);
              lotMG= LB-LS ;
         // }    
    /*
      }
      else
      {
        //   ObjectFind("ncalMG");
     // calMG = ObjectGetDouble( 0,"ncalMG",OBJPROP_DEVIATION, savecalMG);
   // obj_del("ncalMG");
      
     // ObjectFind("calMG");
    //  ObjectSetDouble( 0,"calMG",OBJPROP_PRICE, calMG);
      //savecalMG = calMG ;
    // calMG = savecalMG ;
       // obj_del("calMG");
      }  */
       WindowRedraw();  
      
      
     
     
  
    
  ButtonCreateR(0,"Lock",0,CORNER_RIGHT_UPPER+xx-300,0,lo,16,0,"Lock calMG","Arial",Width,clrBlack,C'236,233,216'); 
 
 // ButtonCreateR(0,"Lock",0,CORNER_RIGHT_UPPER+xx,CORNER_RIGHT_UPPER+yy+280,lo,16,0,"Lock","Arial",Width,clrBlack,C'236,233,216'); 
 
 if(but_stat(prefix+"Lock")==true) 
  {
    if ( lotMG > 0)  OrderSend(Symbol(),OP_SELL, MathAbs(lotMG) ,Bid,50,0,0,StringConcatenate("Lock S",tik),Magic,0,clrRed) ; 
    if ( lotMG < 0)  OrderSend(Symbol(),OP_BUY, MathAbs(lotMG) ,Ask,50,0,0,StringConcatenate("Lock B",tik),Magic,0,clrRed) ; 
     button_off("Lock");  
      WindowRedraw();  
  }
  
  
  
  
  
  
    int x4=(int)IntGetX ("Lots");         
   int y4=(int)IntGetY ("Lots");                
   ButtonCreate(0,"Buy",0,x0,y0+34,90,16,0,"BUY","Arial",Width,clrBlack,C'236,233,216');                    
   ButtonCreate(0,"Sel",0,x0,y0+54,90,16,0,"SELL","Arial",Width,clrBlack,C'236,233,216');                      
    ButtonCreate(0,"BuyL",0,x0,y0+74,90,16,0,"BUY LIMIT","Arial",Width,clrBlack,C'236,233,216');              
   ButtonCreate(0,"SelL",0,x0,y0+94,90,16,0,"SELL LIMIT","Arial",Width,clrBlack,C'236,233,216');         
   ButtonCreate(0,"BuyS",0,x0,y0+114,90,16,0,"BUY STOP","Arial",Width,clrBlack,C'236,233,216');            
   ButtonCreate(0,"SelS",0,x0,y0+134,90,16,0,"SELL STOP","Arial",Width,clrBlack,C'236,233,216');           
   ButtonCreate(0,"ScreenShot",0,x0,y0+154,90,16,0,"SCREENSHOT","Arial",Width,clrBlack,C'236,233,216');      
   ButtonCreate(0,"TimeT",0,x0,y0+174,90,16,0,"Time","Arial",Width,clrBlack,C'236,233,216');     
   WindowRedraw();
   //ChartRedraw(0);
   
    double Dist=NormalizeDouble(Stop_Limit*_Point,_Digits);
   if(but_stat(prefix+"Buy")==true) 
      if(openorders(_Symbol,0,glot)==true) 
         button_off("Buy");  
      //   if(but_stat(nameSL)==false)    
         /*                       {      nameSL=StringConcatenate(prefix,"SL",tik); 
           nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);      
                     ////        button_on(nameSL); // (nameSL)=true ;
                                   
                                   
                                }   */   
   if(but_stat(prefix+"Sel")==true) 
      if(openorders(_Symbol,1,glot)==true) 
         button_off("Sel");   
     //   if(but_stat(nameSL)==false)    
       /*                          {    nameSL=StringConcatenate(prefix,"SL",tik); 
           nameSL= ObjectSetInteger(0,nameSL,OBJPROP_STATE,true);          
                                 
                                 }*/
   if(but_stat(prefix+"BuyL")==true) 
      if(openorders(_Symbol,2,glot,Ask-Dist)==true) 
         button_off("BuyL");                     
   if(but_stat(prefix+"SelL")==true) 
      if(openorders(_Symbol,3,glot,Bid+Dist)==true)
         button_off("SelL");                     
   if(but_stat(prefix+"BuyS")==true) 
      if(openorders(_Symbol,4,glot,Ask+Dist)==true) 
         button_off("BuyS");                         
   if(but_stat(prefix+"SelS")==true) 
      if(openorders(_Symbol,5,glot,Bid-Dist)==true) 
         button_off("SelS");                         

   

   if(but_stat(prefix+"TimeT")==true)
      tim();
   else
      obj_del("clock");
      
     if  ((but_stat(prefix+"CLEAN")==true) )
            {
               
              // Alert ("CLEAN" );
              ObjectDelete(0 ,nameLHPtxt+LineId);
              ObjectDelete(0 ,nameLHPtxt+LineId+"1");
              obj_del(nameLTH);
              obj_del(name2LTH); 
            // obj_del(nameLHP); 
           //  obj_del(nameLHP); // prefix
              WindowRedraw ();
           // ChartRedraw(0);
                 
                 //  ObjectsDeleteAll();
          //  button_off("CLEAN");
          // tick4();
            }
            
            if  ((but_stat(prefix+"nCLEAN ALL")==true) )   //// nCLEAN ALL
            {
            
            ObjectsDeleteAll(0,prefix,-1,OBJ_TEXT);
            ObjectsDeleteAll(0,prefix,-1,OBJ_EDIT);
       //     ObjectsDeleteAll(0,prefix,-1,OBJ_BUTTON);
            ObjectsDeleteAll(0,prefix,-1,OBJ_LABEL);
           // ObjectsDeleteAll(0,-1,OBJ_LABEL);
            ObjectsDeleteAll(0,-1,OBJ_TREND);
            ObjectsDeleteAll(0,prefix,-1,OBJ_HLINE);
            ObjectsDeleteAll(0,prefix,-1,OBJ_VLINE);
               // ObjectsDeleteAll(0,prefix,0);
                
           
            
                   //ObjectsDeleteAll();
            button_off(prefix+"CLEAN ALL");
          // tick4();
            }
            
            
   if  ((but_stat(prefix+"d50")==true) )
            {// ObjectsDeleteAll();
           // calcP();
           obj_del ("atr0");
              // obj_cre_trend("atr0",Time[10] ,Ask+NormalizeDouble(koefATR*ATR15,2),Time[0] ,Ask+NormalizeDouble(ATR15,2),clrYellow );
             
              obj_del ("atr1");
              // obj_cre_trend("atr1",Time[10] ,Ask+NormalizeDouble(koefATR*ATR5,2),Time[0] ,Ask+NormalizeDouble(ATR5,2),clrRed );
                 obj_del ("atr2");
             //  obj_cre_trend("atr2",Time[10] ,Bid-NormalizeDouble(koefATR*ATR5,2),Time[0] ,Bid-NormalizeDouble(ATR5,2),clrRed );
       
          obj_del ("atr3");
          
                    
                 // 
                // but_stat(prefix+"bNL")=false ;
          // button_off("d50");
          // tick4();
            } 
            if((but_stat(prefix+"d50")==true)
                  //   &&  ( tik== OrderTicket() )
                 )
                  //    if ((but_stat("CLEAN")==true  ))
                 {

                  ObjectDelete(StringConcatenate("W0High",tik5)) ;
                  ObjectDelete(StringConcatenate("W0Low",tik5)) ;
                  ObjectDelete(StringConcatenate("W1High",tik5)) ;
                  ObjectDelete(StringConcatenate("W1Low",tik5)) ;


                  ObjectDelete(StringConcatenate("D0High",tik5)) ;
                  ObjectDelete(StringConcatenate("D0Low",tik5)) ;

                  ObjectDelete(StringConcatenate("M5bar",tik5)) ;
                  ObjectDelete(StringConcatenate("M150bar",tik5)) ;
                  ObjectDelete(StringConcatenate("M151bar",tik5)) ;
                  ObjectDelete(StringConcatenate("H0bar",tik5)) ;
                  ObjectDelete(StringConcatenate("H1bar",tik5)) ;
                  ObjectDelete(StringConcatenate("H2bar",tik5)) ;
                  ObjectDelete(StringConcatenate("H4bar",tik5)) ;
                  ObjectDelete(StringConcatenate("D1bar",tik5)) ;
                  ObjectDelete(StringConcatenate("D0bar",tik5)) ;
                  ObjectDelete(StringConcatenate("D2bar",tik5)) ;
                  
                  }

  
 
///OnTimer();

  // calcP ();
 uroven();  //   slaga cvetovete

}   // enddimi2



//+------------------------------------------------------------------+
//| Text                                                             |
//+------------------------------------------------------------------+
void Text(string TextName,int Window,string LabelText,int FontSize,string FontName,color TextColor,datetime Time1,double Price1,bool del)
  {
   if(del) ObjectDelete(TextName);
   if(ObjectFind(TextName)!=0)
     {
      ObjectCreate(TextName,OBJ_TEXT,Window,Time1,Price1);
      ObjectSetText(TextName,LabelText,FontSize,FontName,TextColor);
      ObjectSet(TextName,OBJPROP_BACK,true);
     }
   else
      ObjectMove(TextName,0,Time1,Price1);
  }
