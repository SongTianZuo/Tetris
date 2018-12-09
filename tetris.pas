{$APPTYPE GUI}
{$MODE DELPHI}
program WinPiece;


uses
  Windows;

const
	AppName = 'WinPiece';
	pm	= 25;

var
  flat :boolean;
	dc : hdc;
	AMessage : Msg;
	hWindow: HWnd;
	hPen ,hBrush : longword;
	intNextPiece, intCurPiece,intTempPiece : longint;
	BigMap : array [0..11,-4..20] of boolean;	
	NextPiece,CurPiece,TempPiece : array [0..3,0..3] of boolean;
	isGameing : boolean;
	Piece : array [0..18] of longint;
	scoreString, levelString: string;
	xPos, yPos : integer;
	score,level : longint;	//分数,关卡
	speed : integer;

	//2015年多彩版添加以下代码，开始
	BigMapColor : array [0..11,-4..20] of 0..7;		
	NextPieceColor,CurPieceColor : 0..7;
	mem_dc: hdc; //内存dc，防闪屏
	WINDOW_WIDTH: long=400;
	WINDOW_HEIGHT: long=615;
	midBMP:hBitmap;
	//全局变量段添加加结束

procedure TimerProc(Window:HWND;uMsg:UINT;idEvent:UINT;Time:DWORD);stdcall;
FORWARD;

//2015年多彩版添加以下代码，开始
{ 取方块转颜色 }
function getColor(intPiece:longint):integer;
var
	reInt:integer;
begin
	case intPiece of
		13056: reInt:=1;
		8738,3840:  reInt:=2;
		25344,4896: reInt:=3;
		13824,8976: reInt:=4;
		29184,17984,9984,4880:reInt:=5;
		25120,29696,17504,5888: reInt:=6;
		12832,18176,8800,28928: reInt:=7;
		else reInt:=0;
	end;
	getColor:=reInt;
end;
//全局变量段添加加结束

Procedure IntToNextPiece ( );
var
	i,j : integer;
	t: longint;
begin
	
	t:=intNextPiece;
	NextPieceColor:=getColor(t);
	
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
		begin
			If (t mod 2=1) Then
				NextPiece[j][i] := true
			else
				NextPiece[j][i] := false ;

			t := t div 2;
		end;

end;

Procedure IntToCurPiece ( );
var
	i,j : integer;
	t : longint;
begin
	t:=intCurPiece;
	CurPieceColor:=getColor(t);
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
		begin
			If (t mod 2=1) Then
				CurPiece[j][i] := true
			else
				CurPiece[j][i] := false ;
			t := t div 2;
		end;
end;

Procedure IntToTempPiece ( );
var
	i,j : integer;
	t : longint;
begin
	t:=intTempPiece;
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
		begin
			If (t mod 2=1) Then
				TempPiece[j][i] := true
			else
				TempPiece[j][i] := false ;
			t := t div 2;
		end;
end;

Procedure DrawPiece(x,y:integer;piececolor:integer);
begin
	SelectObject (mem_dc,GetStockObject (NULL_PEN)) ;		//选择空画笔
	
	//2015年多彩版修改以下代码，开始	
	case piececolor of
		0:	hBrush := CreateSolidBrush (RGB(0,0,0));
		1:	hBrush := CreateSolidBrush (RGB(241,26,26));
		2:	hBrush := CreateSolidBrush (RGB(0,240,240));
		3:	hBrush := CreateSolidBrush (RGB(26,26,241));
		4:	hBrush := CreateSolidBrush (RGB(241,169,26));
		5:	hBrush := CreateSolidBrush (RGB(241,241,26));
		6:	hBrush := CreateSolidBrush (RGB(26,241,26));
		7:	hBrush := CreateSolidBrush (RGB(169,26,241));
	end;
	//添加段结束
	
	SelectObject (mem_dc,hBrush) ;					//选择我们创建的粉色笔刷
	Rectangle(mem_dc,x,y,x+pm,y+pm);				//画粉色矩形
	DeleteObject(hBrush);						//删除刚创建的粉色笔刷
	
	SelectObject (mem_dc,GetStockObject (WHITE_PEN)) ;	//选择白色画笔
	MoveToEx (mem_dc, x+24,y, nil);
	LineTo(mem_dc,x,y);
	LineTo(mem_dc,x,y+24);
	hPen:=CreatePen(PS_SOLID,1, RGB(100,100,100));	//创建灰色画笔
	SelectObject (mem_dc,hPen) ;					//选择我们刚创建的灰色画笔
	LineTo(mem_dc,x+24,y+24);
	LineTo(mem_dc,x+24,y);
	DeleteObject(hPen);						//删除我们刚创建的灰色画笔
end;

Procedure DrawNextMap( );
var
	i, j : integer;
begin
	SelectObject (mem_dc,GetStockObject (BLACK_PEN));		//选择黑色画笔
	SelectObject (mem_dc,GetStockObject (BLACK_BRUSH));	//选择黑色画笔
	Rectangle(mem_dc,277,66,277+pm*4,66+pm*4);		//先画BigMap黑色矩形背景
	IntToNextPiece();
	SelectObject (mem_dc,GetStockObject (WHITE_PEN)) ;
	For  i:= 0 to 3 DO
	begin
		For j:=0 TO 3 DO
		begin
			If NextPiece[i][j] Then
			begin
				DrawPiece(277+pm*i,66+pm*j,NextPieceColor);
				
			end;
		end;
	end;				
end;
	
Procedure DrawBigMap( );
var
	i, j:integer;
begin
	For i:= 1 TO 10 DO
	begin
		For j:= 0 TO 19 DO
		begin
			If BigMap[i][j] Then begin
				DrawPiece(12+(i-1)*pm,66+j*pm,BigMapColor[i][j]);
				
			end
			else
			begin
				SelectObject (mem_dc, GetStockObject (BLACK_PEN)) ;
				SelectObject (mem_dc, GetStockObject (BLACK_BRUSH)) ;
				Rectangle(mem_dc,12+(i-1)*pm,66+j*pm,12+(i-1)*pm+pm,66+j*pm+pm);
			end;
		end;
	end;
end;

Procedure DrawCurMap();
var
	i, j : integer;
begin
	IntToCurPiece();
	For i:=0 TO 3 DO
		For j:= 0 TO 3 DO
			If (CurPiece[i][j]) and (yPos+j>=0) Then begin
				DrawPiece(12+(xPos+i-1)*pm,66+(yPos+j)*pm,CurPieceColor);
			end;
end;

Procedure DrawScore ( );
begin
	SetBkColor(dc,RGB(200,200,200));	//设置字体的背景色为灰色，以与窗口背景保持一致
	TextOut(dc,277,210,PChar(scoreString),length(scoreString));		//输出分数
	TextOut(dc,277,260, PChar(levelString),length(levelString));	//输出过关数
	TextOut(dc,277,310, PChar('中考fighting！'),length('中考fighting！'));	//输出过关数
	//MessageBox(0,'','',MB_OK);
end;

function NewPiece ( ):longint;
var
	//2015修改 方块的随机出现的概率
	song: array[0..27] of integer=(0,0,0,0,  1,2,1,2,  3,4,3,4,  5,6,5,6,
		7,8,9,10,11,12,13,14,15,16,17,18);
begin
	NewPiece:=Piece[song[trunc(random*28)]];
end;

Procedure init ( );
var
	i, j : integer;
begin
	For i:=0 TO 11 DO
		For j:=-4 TO 20 DO
			If (i=0) or (i=11) or (j=20) Then begin
				BigMap[i][j] := true;
			  end
			else
			  begin	
				BigMap[i][j] := false ;
				BigMapColor[i][j] :=0;
			  end;

	score:=0;
	str(score,scoreString);
	scoreString:='分数:'+ scoreString + '        ';
	level:=0;
	str(level,levelString);
	levelString:='级别:'+ levelString +'        ';
	xPos:=4;
	yPos:=-4;
end;

function CanTurn(): boolean;
var
	i,j: integer;
	r: boolean;
begin
	r:=true ;
	For i:=0 TO 18 DO
		If intCurPiece=Piece[i] Then
		begin
			break ;
		end;
	case i of
		0: intTempPiece := Piece[0];     //方块
		1: intTempPiece := Piece[2];     //i
		2: intTempPiece := Piece[1];     //i
		3: intTempPiece := Piece[4];     //z
		4: intTempPiece := Piece[3];     //z
		5: intTempPiece := Piece[6];     //反z
		6: intTempPiece := Piece[5];     //反z
		7: intTempPiece := Piece[10];    //T
		8, 9, 10: intTempPiece := Piece[i - 1]; //T
		11: intTempPiece := Piece[14];   //L
		12, 13, 14: intTempPiece := Piece[i - 1]; //L
		15: intTempPiece := Piece[18];   //反L
		16, 17, 18: intTempPiece := Piece[i - 1]; //反L
	end;

	IntToTempPiece ( );
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
			If (((xPos+i)>=0) and ((xPos+i)<12)  and (BigMap[xPos+i][yPos+j]) and (TempPiece[i][j]))  Then //当有重合的格子都为1时，表示表不能变形
			begin
				CanTurn:=false ;
				r:=false;
				exit ;
			end;
	intCurPiece:=intTempPiece;
	intToCurPiece();
	CanTurn:=r;
end;

Function CanRight ( ) : boolean;
var
	i,j: integer;
begin
	inc(xPos);			//假设方块继续右
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
			If (((xPos+i)>=0) and ((xPos+i)<12)  and (BigMap[xPos+i][yPos+j]) and (CurPiece[i][j]))  Then //当有重合的格子都为1时，表示不能右移
			begin
				dec(xPos);
				CanRight:=false ;
				exit ;
			end;
	dec(xPos);
	CanRight := true ;
end;

Function CanLeft ( ) : boolean;
var
	i,j: integer;
begin
	dec(xPos);			//假设方块继续左
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
			If (((xPos+i)>=0) and ((xPos+i)<12)  and (BigMap[xPos+i][yPos+j]) and (CurPiece[i][j]))  Then //当有重合的格子都为1时，表示不能左移
			begin
				inc(xPos);
				CanLeft:=false ;
				exit ;
			end;
	inc(xPos);
	CanLeft := true ;
end;

Function CanDown ( ) : boolean;		//判断CurPiece能否继续下落
var
	i,j: integer;
begin
	inc(yPos);			//假设方块继续下落
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
			If (((xPos+i)>=0) and ((xPos+i)<12)  and (yPos+j>=0) and (BigMap[xPos+i][yPos+j]) and (CurPiece[i][j]))  Then //当有重合的格子都为1时，不能表示表能下落了
			begin
				dec(yPos);
				CanDown:=false ;
				exit ;
			end;
	dec(yPos);
	CanDown := true ;
end;

Procedure FillBigMap ( );		//记录大图
var
	i, j : integer;
begin
	For i:=0 TO 3 DO
		For j:=0 TO 3 DO
			If CurPiece[i][j] Then begin
				BigMap[xPos+i][yPos+j]:=true;
				BigMapColor[xPos+i][yPos+j]:=CurPieceColor;
			end;
end;

Function IsGameOver ( ) : boolean;	//游戏是过否结束
var
	i:integer;
	r:boolean;
begin
	r:=false ;
	For i:=1 TO 10 DO		
		If BigMap[i][0] Then	//当 最上一行有小格为1，返回真
		begin
			r:=true ;
			break
		end;
	IsGameOver := r ;
end;

Procedure ClearLine ( ); //消行
var
	linesCount, count, i, j, k, m: integer;
begin
	linesCount := 0;	//一次消行的行数
	j:=19;
	while j>=0 do
	begin
		count:=0;
		For i:=1 TO 10 DO
			If BigMap[i][j] Then
				inc(count);
		If count=10 Then	//count=10，表明该行已满
		begin
			inc(linesCount);
			For k:= j downTO 1 DO
				For m:= 1 TO 10 DO begin
					BigMap[m][k]:=BigMap[m][k-1];
					BigMapColor[m][k]:=BigMapColor[m][k-1];
				end;
			//inc(j);
			//这个怎么办????
			//此问题由Recano解决
		end else dec(j);
	end;
	if(linesCount>0) then
		begin
		  k := 0;
		  for i := 1 to linesCount do
			begin
			  k := k + 10;
		          score:=score+k;
			end;
			str(score,scoreString);
			scoreString:='分数:'+ scoreString + '        ';
  		if( level<>(score div 1000) ) then
	 		begin
	 			level := score div 1000;
				str(level,levelString);
				levelString:='级别:'+ levelString + '        ';
				KillTimer(hwindow,11);
				speed:=speed div 2;
				SetTimer(hWindow,11,speed,@TimerProc);
			end;
		end;
end;

{ 定时处理 }
procedure TimerProc(Window:HWND;uMsg:UINT;idEvent:UINT;Time:DWORD);stdcall;
begin
	If (CanDown()) then		//如果能继续下落
		yPos := yPos + 1	//则CurPiece下落（纵坐标加1 ）
	else				//如果不能下落
	begin
		FillBigMap();	 //将CurPiece填入BigMap
		intCurPiece:=intNextPiece;
		IntToCurPiece();

		intNextPiece:=NewPiece();		//随机产生新方块，并复制给NextPiece
		IntToNextPiece();
		xPos:=4;			//横坐标初始化为4
		yPos:=-4;		//纵坐标初始化为-1
		ClearLine();		//消行
		if(IsGameOver()) then
		begin
			KillTimer(window,11);
			isGameing:=false ;
			MessageBox(window,'游戏结束！','提示',MB_OK);
		end;

	end;
	PostMessage(window, WM_PAINT, 0, 0);
end;

Procedure BeginGame ( );
begin
  flat := true; //此处由Recano修改，表示游戏开始
	init();
	randomize;
	intCurPiece:=NewPiece();		//随机产生新方块，并复制给NextPiece
	IntToCurPiece();
	intNextPiece:=NewPiece();		//随机产生新方块，并复制给NextPiece
	IntToNextPiece();
	isGameing:=true;
	speed:=1000;
	SetTimer(hWindow,11,speed,@TimerProc);	//定时器id为11，时间间隔为1000ms，时间回调函数是TimerProc()
end;

{ 消息处理 }
function WindowProc(Window: HWnd; AMessage: UINT; WParam : WPARAM;
                    LParam: LPARAM): LRESULT; stdcall; export;

var
	nrmenu : longint;
	aboutString : String;
begin
	WindowProc := 0;

	case AMessage of

		wm_paint:
		begin
			DefWindowProc(Window, AMessage, WParam, LParam);
			dc:= GetDC(window);
			
			DrawBigMap();
			DrawNextMap();
			DrawCurMap();
			DrawScore();
			//2015多彩版增加以下代码
			BitBlt(dc,12,66,pm*10,pm*20,mem_DC,12,66,SRCCOPY);
			BitBlt(dc,277,66,pm*4,pm*4,mem_DC,277,66,SRCCOPY);
			
			//增加段结束
			ReleaseDC(window, dc) ;
		end;

		wm_Destroy:
		begin
			//2015多彩版增加以下代码
			DeleteDC(mem_dc);
			//增加段结束
			PostQuitMessage(0);
			Exit;
		end;

		wm_Create:
		begin
			CreateWindowEx(0,'button','开始',
				ws_child or ws_visible or bs_pushbutton,
				20,10,75,40,
				Window,
				0,system.MainInstance,nil);

			CreateWindowEx(0,'button','暂停',
				ws_child or ws_visible or bs_pushbutton,
				110,10,75,40,
				Window,
				1,system.MainInstance,nil);

			CreateWindowEx(0,'button','继续',
				ws_child or ws_visible or bs_pushbutton,
				200,10,75,40,
				Window,
				2,system.MainInstance,nil);
		
			CreateWindowEx(0,'button','关于',
				ws_child or ws_visible or bs_pushbutton,
				290,10,75,40,
				Window,
				3,system.MainInstance,nil);
				
			CreateWindowEx(0,'button','修复说明',
				ws_child or ws_visible or bs_pushbutton,
				275,460,100,100,
				Window,
				4,system.MainInstance,nil);
			
			
			//2015多彩版增加以下代码
			scoreString:='分数:0        ';
			levelString:='级别:0        ';

			dc:=GetDC(window);
			mem_DC:=CreateCompatibleDC (0);
			midBMP:=CreateCompatibleBitmap(dc,WINDOW_WIDTH,WINDOW_HEIGHT);
			SelectObject(mem_DC,midBMP);
			ReleaseDC(window,dc);
			//增加段结束
		end;

		wm_command:
		begin
			NrMenu := WParam And $FFFF;
			case NrMenu of
				0:
				begin
				  flat := true;
					BeginGame();
				end;
				1:
				begin
				If (flat) and (not isGameOver()) and (isGameing) Then  //此处由Recano修改，游戏未开始前点击此按钮错误
					begin
						isGameing:=false ;
						killTimer(window,11);
					end;
				end;
				2:
				begin
					If (flat) and (not isGameOver()) and (not isGameing) Then  //此处由Recano修改，游戏未开始前点击此按钮错误
					begin
						isGameing:=true ;
						SetTimer(hWindow,11,speed,@TimerProc);
					end;
				end;
				3:
				begin
					PostMessage(window,wm_command,1,0);
					aboutString := '作者：狼妹宋天琢'+ chr(13) + chr(10);
					aboutString :=aboutString + 'Blog: hi.baidu.com/lmstz' + chr(13) + chr(10);
					aboutString :=aboutString + 'QQ: 1559846698';
					messagebox(window,pchar(aboutString),'俄罗斯方块',mb_ok);
					PostMessage(window,wm_command,2,0);
				end;
				4:
				begin
					PostMessage(window,wm_command,1,0);
					aboutString := '修复: Recano（海胖子）' + chr(13) + chr(10);
					aboutString :=aboutString + 'Blog: www.cnblogs.com/recano' + chr(13) + chr(10);
					aboutString :=aboutString + 'QQ: 573315002' + chr(13) + chr(10);
					aboutString :=aboutString + '修复内容: ' + chr(13) + chr(10);
					aboutString :=aboutString + '1. 修改“开始”、“暂停”、“继续”、“关于”的位置' + chr(13) + chr(10);
					aboutString :=aboutString + '2. 修复游戏未开始时点击“暂停”、“继续”按钮产生的错误' + chr(13) + chr(10);
					aboutString :=aboutString + '3. 修复游戏无法同时消去多行的Bug' + chr(13) + chr(10);
					aboutString :=aboutString + '4. 修改“分数”、“级别”的位置' + chr(13) + chr(10);
					aboutString :=aboutString + '5. 修改“关于”内容' + chr(13) + chr(10);
					aboutString :=aboutString + '6. 添加“修复说明”' + chr(13) + chr(10);
					aboutString :=aboutString + '7. 修改分数统计函数' + chr(13) + chr(10);
					aboutString :=aboutString + '' + chr(13) + chr(10);;
					aboutString :=aboutString + '修复 狼妹宋天琢 （lmstz）2015年5月' + chr(13) + chr(10);
					aboutString :=aboutString + 'QQ: 1559846698' + chr(13) + chr(10);
					aboutString :=aboutString + '中考fighting！人品大爆发！' + chr(13) + chr(10);
					aboutString :=aboutString + '1. 修复 闪烁问题' + chr(13) + chr(10);
					aboutString :=aboutString + '2. 添加 多彩的方块，不再一种颜色了' + chr(13) + chr(10);
					aboutString :=aboutString + '3. 修改 各种方块出现的概率' + chr(13) + chr(10);
					messagebox(window,pchar(aboutString),'修复说明',mb_ok);
					PostMessage(window,wm_command,2,0);
				end;
			end;
			SetFocus(window);	//把焦点归还给主窗口
		end;

		WM_KEYDOWN:
		begin
			if(isGameing) then
				begin
				NrMenu := WParam And $FFFF;
				case NrMenu of
					VK_UP:
						If CanTurn() Then
						begin
							PostMessage(window,WM_PAINT,0,0);
						end;
					VK_LEFT:
						If CanLeft() Then
						begin
							dec(xpos);
							PostMessage(window,WM_PAINT,0,0);
						end;
					VK_RIGHT:
						If CanRight() Then
						begin
							inc(xpos);
							PostMessage(window,WM_PAINT,0,0);
						end;
					VK_DOWN:
						If CanDown() Then
						begin
							TimerProc(window,11,0,0);
						end;
				end;
			end;
		end;
	end;
	
	WindowProc := DefWindowProc(Window, AMessage, WParam, LParam);
end;

 { Register the Window Class }
function WinRegister: Boolean;
var
WindowClass: WndClass;
begin
	WindowClass.Style := cs_hRedraw or cs_vRedraw;
	WindowClass.lpfnWndProc := WndProc(@WindowProc);
	WindowClass.cbClsExtra := 0;
	WindowClass.cbWndExtra := 0;
	WindowClass.hInstance := system.MainInstance;
	WindowClass.hIcon := LoadIcon(0, idi_Application);
	WindowClass.hCursor := LoadCursor(0, idc_Arrow);
	WindowClass.hbrBackground := GetStockObject(WHITE_BRUSH);
	WindowClass.lpszMenuName := nil;
	WindowClass.lpszClassName := AppName;

	WinRegister := RegisterClass(WindowClass) <> 0;
end;

 { Create the Window Class }
function WinCreate: HWnd;

begin
	hWindow := CreateWindow(AppName, '俄罗斯方块',
		ws_OverlappedWindow, cw_UseDefault, cw_UseDefault,
		400, 615, 0, 0, system.MainInstance, nil);

	if hWindow <> 0 then
	begin
		ShowWindow(hWindow, CmdShow);
		ShowWindow(hWindow, SW_SHOW);
		UpdateWindow(hWindow);
	end;

	WinCreate := hWindow;
end;

procedure  VarInit( );
begin
	Piece[0]:=13056;
	Piece[1]:=8738;
	Piece[2]:=3840;
	Piece[3]:=25344;
	Piece[4]:=4896;
	Piece[5]:=13824;
	Piece[6]:=8976;
	Piece[7]:=29184;
	Piece[8]:=17984;
	Piece[9]:=9984;
	Piece[10]:=4880;
	Piece[11]:=25120;
	Piece[12]:=29696;
	Piece[13]:=17504;
	Piece[14]:=5888;
	Piece[15]:=12832;
	Piece[16]:=18176;
	Piece[17]:=8800;
	Piece[18]:=28928;
end;

{ main }
begin
	VarInit();
	if not WinRegister then
	begin
		MessageBox(0, 'Register failed', nil, mb_Ok);
		Exit;
	end;
	hWindow := WinCreate;
	if longint(hWindow) = 0 then
	begin
		MessageBox(0, 'WinCreate failed', nil, mb_Ok);
		Exit;
	end;

	while GetMessage(@AMessage, 0, 0, 0) do
	begin
		TranslateMessage(AMessage);
		DispatchMessage(AMessage);
	end;
	Halt(AMessage.wParam);
end.
