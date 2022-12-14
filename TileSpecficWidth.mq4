//+------------------------------------------------------------------+
//|                                             TileSpecficWidth.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <WinUser32.mqh>

#define MT4_MSG_WIN_TILE  38259
#define GA_ROOT       2
#define SW_MAXIMIZE 3
#define SC_MAXIMIZE 0xF030
//https://fai-fx.hatenadiary.org/entry/20090913/1252768099
//https://fai-fx.hatenadiary.org/entry/20090914/1252854024

#import "user32.dll"
//int  RegisterWindowMessageW(string MessageName); // For Start custom indicator
//int  PostMessageW(int hwnd,int msg,int wparam,uchar &Name[]); // For Start custom indicator
//int  FindWindowW(string lpszClass,string lpszWindow); // For Start custom indicator
// int  keybd_event(int bVk, int bScan, int dwFlags, int dwExtraInfo); // For Start custom indicator
//int GetCursor(void);
int PostMessageA(int hWnd, int Msg, int wParam, int lParam);
int GetParent(int hWnd);
int GetAncestor(int, int);
int GetClientRect(int hWnd, int &lpRect[]);
int GetWindowRect(int hWnd, int &lpRect[]);

//uint SendInput(uint cInputs, LPINPUT pInputs, int cbSize);
#import "kernel32.dll"
void Sleep(int dwMilliseconds);
#import

input ENUM_TIMEFRAMES tf_win0=PERIOD_H1;
input ENUM_TIMEFRAMES tf_win1=PERIOD_M15;
input ENUM_TIMEFRAMES tf_win2=PERIOD_M5;
input ENUM_TIMEFRAMES tf_win3=PERIOD_M1;
input double w_percent_win0=40;
input double w_percent_win1=20;
input double w_percent_win2=20;
input double w_percent_win3=20;

//#define WM_MDIGETACTIVE 0x00000229

struct RECT {
  long left;
  long top;
  long right;
  long bottom;
};
int g_ClientHandle = 0; //クライアントウィンドウハンドル保持用
int g_ThisWinHandle = 0; //Thisウィンドウハンドル保持用
int g_ParentWinHandle = 0; //Parentウィンドウハンドル保持用
long g_lChartID=0;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---

  int rect[4];
  int hwin_tmp0;
  int hwin_tmp1;
  int hwin_tmp2;
  int hwin_tmp3;
  int EntireWidth=0;
  int EntireHeight=0;
 
  g_ClientHandle = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE);
  Print("SyncMain OnTimer ClientHandle0: "+IntegerToString(g_ClientHandle));
  if(g_ClientHandle != 0)
    g_ThisWinHandle = GetParent(g_ClientHandle);
  Print("SyncMain OnTimer g_ThisWinHandle: "+IntegerToString(g_ThisWinHandle));
  if(g_ThisWinHandle != 0)
    g_ParentWinHandle = GetParent(g_ThisWinHandle);
  Print("SyncMain OnTimer g_ParentWinHandle: "+IntegerToString(g_ParentWinHandle));
  int wTopHandle = GetAncestor((int)ChartGetInteger(0, CHART_WINDOW_HANDLE), GA_ROOT);
  Print("SyncMain OnTimer wTopHandle: "+IntegerToString(wTopHandle));

  user32::GetClientRect(g_ClientHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  user32::GetClientRect(g_ThisWinHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  user32::GetClientRect(g_ParentWinHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  EntireWidth = rect[2];
  EntireHeight = rect[3];

  user32::GetClientRect(wTopHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);
   
  user32::GetWindowRect(g_ClientHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  user32::GetWindowRect(g_ThisWinHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  user32::GetWindowRect(g_ParentWinHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  user32::GetWindowRect(wTopHandle, rect);
  Print ("RECT="+rect[0]+"  "+rect[1]+"  "+rect[2]+"  "+rect[3]);

  g_lChartID=ChartFirst();

  while(0<g_lChartID){
    hwin_tmp0 = (int)ChartGetInteger(g_lChartID, CHART_WINDOW_HANDLE);
    //int period_tmp = (int)ChartGetInteger(g_lChartID, CHART_PERIOD);
    //Print("g_lChartID="+g_lChartID);
    ENUM_TIMEFRAMES tf_local = ChartPeriod(g_lChartID);
    Print("g_lChartID,tf_local="+g_lChartID+"  "+tf_local);
    hwin_tmp1 = GetParent(hwin_tmp0);
    hwin_tmp2 = GetParent(hwin_tmp1);
    hwin_tmp3 = wTopHandle;

    switch (tf_local) {
    case PERIOD_H1:
      MoveWindow(hwin_tmp1, 0, 0, w_percent_win0*EntireWidth/100, EntireHeight, true);
      break;
    case PERIOD_M15:
      MoveWindow(hwin_tmp1, w_percent_win0*EntireWidth/100, 0, w_percent_win1*EntireWidth/100, EntireHeight,  true);
      break;
    case PERIOD_M5:
      MoveWindow(hwin_tmp1, (w_percent_win0+w_percent_win1)*EntireWidth/100, 0, w_percent_win2*EntireWidth/100,EntireHeight, true);
      break;
    case PERIOD_M1:
      MoveWindow(hwin_tmp1, (w_percent_win0+w_percent_win1+w_percent_win2)*EntireWidth/100, 0, w_percent_win3*EntireWidth/100,EntireHeight, true);
      break;
    default:
      break;
    }

    g_lChartID=ChartNext(g_lChartID);
  }

}
//+------------------------------------------------------------------+
