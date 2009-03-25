unit lab7;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkpropag, Grids, StdCtrls, Spin, ExtCtrls, TeEngine, Series, TeeProcs,
  Chart, Menus;

type
  TForm1 = class(TForm)
    SpinEdit1: TSpinEdit;
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    StringGrid2: TStringGrid;
    SpinEdit2: TSpinEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Chart1: TChart;
    Series1: TBarSeries;
    Series2: TBarSeries;
    CheckBox1: TCheckBox;
    Panel2: TPanel;
    Button2: TButton;
    Button1: TButton;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    Label2: TLabel;
    Label5: TLabel;
    SpinEdit5: TSpinEdit;
    Label6: TLabel;
    Button3: TButton;
    Edit1: TEdit;
    Label7: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    RANDOM1: TMenuItem;
    N21: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    CheckBox2: TCheckBox;
    Edit2: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    N7: TMenuItem;
    N8: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure RANDOM1Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
  private
    { Private declarations }
    neuro:TBackPropagation; //объект нейросети
    CountNeuro:TVesCountNeuro; //количество нейронов в слоях
    trend:TTrend; //временной ряд
    normal:double;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var j:word;
al,da:double;
begin
//инициализация
StringGrid2.ColCount:=SpinEdit2.Value+1;
for j:=1 to SpinEdit2.Value+1 do
 StringGrid2.Cells[j,0]:=IntToStr(j);
StringGrid2.Cells[0,1]:='Ряд';
StringGrid2.Cells[0,2]:='Прогноз';
//Задание ряда
Randomize;
da:=3*pi/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(sqr(sin(al)));
 al:=al+da;
 end;

//количество нейронов
StringGrid1.RowCount:=SpinEdit1.Value+1;
for j:=1 to SpinEdit1.Value+1 do
 StringGrid1.Cells[0,j]:=IntToStr(j);
StringGrid1.Cells[1,0]:='Нейронов';
StringGrid1.Cells[1,1]:='4';
StringGrid1.Cells[1,2]:='5';
StringGrid1.Cells[1,3]:='1';

//нормирование
normal:=1;

end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
var j:word;
begin
if SpinEdit2.Value>MAXTRAND then SpinEdit2.Value:=MAXTRAND;
StringGrid2.ColCount:=SpinEdit2.Value+1;
for j:=1 to SpinEdit2.Value+1 do
 StringGrid2.Cells[j,0]:=IntToStr(j);
StringGrid2.Cells[0,1]:='Ряд';
StringGrid2.Cells[0,2]:='Прогноз';
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
var j:word;
begin
if SpinEdit1.Value>MAXLAYERS then SpinEdit1.Value:=MAXLAYERS-1; 
StringGrid1.RowCount:=SpinEdit1.Value+1;
for j:=1 to SpinEdit1.Value+1 do
begin
 StringGrid1.Cells[1,j]:='3';
 StringGrid1.Cells[0,j]:=IntToStr(j);
end;
StringGrid1.Cells[1,SpinEdit1.Value]:='1';
StringGrid1.Cells[1,0]:='Нейронов';
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
var i:integer;
begin
for i:=1 to 2 do
 Chart1.Series[i-1].Marks.Visible:=CheckBox1.Checked;
 end;

procedure TForm1.Button1Click(Sender: TObject);
var i,j:word;
    AValue:double;
begin
for i:=1 to 2 do
 begin
 Chart1.SeriesList[i-1].Clear;
 for j:=1 to SpinEdit2.Value do
  begin
  if StringGrid2.Cells[j,i]='' then AValue:=0 else AValue:=StrToFloat(StringGrid2.Cells[j,i]);
  if (j>SpinEdit4.Value) and (i=2) then Chart1.SeriesList[i-1].Add(AValue,'',rgb(0,200,0))
  else Chart1.SeriesList[i-1].Add(AValue,'',Chart1.Series[i-1].SeriesColor);
  end;
 end;
end;

procedure TForm1.Button3Click(Sender: TObject);
//обучение
var i,j:word;
    Save_Cursor:TCursor;
    maxn:double;
begin
Save_Cursor := Screen.Cursor;
Screen.Cursor := crHourglass;    { Show hourglass cursor }
try
neuro.free;
neuro:=TBackPropagation.Create; //создали нейросеть
//задаем количество слоев в нейросети и количество нейронов в каждом слое
//а также размер входного окна
for i:=1 to SpinEdit1.Value do CountNeuro[i]:=StrToInt(StringGrid1.Cells[1,i]);
if SpinEdit4.Value>=SpinEdit2.Value then SpinEdit4.Value:=SpinEdit2.Value-1;
if SpinEdit3.Value>=SpinEdit4.Value then SpinEdit3.Value:=SpinEdit4.Value div 3;
neuro.SetArrayVesCount(SpinEdit1.Value,SpinEdit3.Value,CountNeuro);
//задаем временной ряд
for j:=1 to SpinEdit4.Value do if StringGrid2.Cells[j,1]='' then trend[j]:=0 else trend[j]:=StrToFloat(StringGrid2.Cells[j,1]);
//выполняем нормализацию временного ряда
maxn:=trend[1];
for j:=2 to SpinEdit4.Value do if trend[j]>maxn then maxn:=trend[j];
if maxn>1 then normal:=1.2*maxn else normal:=1;
if (not CheckBox2.Checked)
        then
        begin
        if (MessageDlg('Обучение будет выполняться без нормализации'#13+
                   'временного ряда. Это может вызвать проблемы,'#13+
                   'если существуют элементы ряда, абсолютное'#13+
                   'значение которых больше единицы!'#13+
                   'Желаете ли вы включить нормализацию?', mtConfirmation, [mbYes, mbNo], 0) = mrYes )
                   then CheckBox2.Checked:=true;
        end;

if CheckBox2.Checked then for j:=1 to SpinEdit4.Value do trend[j]:=trend[j]/normal;


neuro.SetTrend(SpinEdit4.Value,trend);
neuro.Education(StrToFloat(Edit1.text),StrToFloat(Edit2.text)); //обучение
Button2.Enabled:=true;
finally
    Screen.Cursor := Save_Cursor;  { Always restore to normal }
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
neuro.free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var X:TTrend; i,j:word;
begin
//прогнозирование
SpinEdit2.Value:=SpinEdit4.Value+SpinEdit5.Value;
StringGrid2.ColCount:=SpinEdit4.Value+SpinEdit5.Value+1;
for i:=1 to StringGrid2.ColCount do StringGrid2.Cells[i,2]:='';
if RadioButton1.Checked then
begin //одношаговое предсказание
for i:=1 to SpinEdit4.Value+(SpinEdit5.Value-SpinEdit3.Value) do
 begin
 for j:=1 to SpinEdit3.Value do
 if StringGrid2.Cells[i+j-1,1]='' then x[j]:=0 else x[j]:=StrToFloat(StringGrid2.Cells[i+j-1,1])/normal;
 StringGrid2.Cells[i+SpinEdit3.Value,2]:=FloatToStr(neuro.doprognoz(x)*normal);
 end;
end
else //многошаговое прогнозирование
begin
//переписываем реальные данные в начало
for i:=1 to SpinEdit3.Value do  StringGrid2.Cells[SpinEdit4.Value-i+1,2]:=StringGrid2.Cells[SpinEdit4.Value-i+1,1];
for i:=SpinEdit4.Value-SpinEdit3.Value+1 to SpinEdit4.Value+SpinEdit5.Value-SpinEdit3.Value do
 begin
 for j:=1 to SpinEdit3.Value do
 if StringGrid2.Cells[i+j-1,2]='' then x[j]:=0 else x[j]:=StrToFloat(StringGrid2.Cells[i+j-1,2])/normal;
 StringGrid2.Cells[i+SpinEdit3.Value,2]:=FloatToStr(neuro.doprognoz(x)*normal);
 end;
end;

end; //procedure

procedure TForm1.N1Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=pi/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(sqr(sin(al)));
 al:=al+da;
 end;
Button1Click(sender);
end;

procedure TForm1.RANDOM1Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=3*pi/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(sqr(sin(al)));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N21Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=2*pi/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(abs(sin(al)));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N2Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=1/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(1-sqr(al));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N3Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=1/(SpinEdit2.Value); al:=0;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(sqrt(al));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N4Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=1/(SpinEdit2.Value); al:=1;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(ln(al));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N5Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=1/(SpinEdit2.Value); al:=-1;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(exp(al));
 al:=al+da;
 end;
 Button1Click(sender);
end;

procedure TForm1.N6Click(Sender: TObject);
begin
StringGrid2.Cells[1,1]:='20,494';
StringGrid2.Cells[2,1]:='20,46';
StringGrid2.Cells[3,1]:='20,366';
StringGrid2.Cells[4,1]:='20,248';
StringGrid2.Cells[5,1]:='20,148';
StringGrid2.Cells[6,1]:='20,06';
StringGrid2.Cells[7,1]:='19,99';
StringGrid2.Cells[8,1]:='19,904';
StringGrid2.Cells[9,1]:='19,908';
StringGrid2.Cells[10,1]:='19,828';
StringGrid2.Cells[11,1]:='19,15';
StringGrid2.Cells[12,1]:='18,87';
StringGrid2.Cells[13,1]:='18,268';
StringGrid2.Cells[14,1]:='19,4892';
StringGrid2.Cells[15,1]:='18,972';
StringGrid2.Cells[16,1]:='18,848';
StringGrid2.Cells[17,1]:='18,69';
StringGrid2.Cells[18,1]:='18,58';
StringGrid2.Cells[19,1]:='18,402';
StringGrid2.Cells[20,1]:='18,24';
StringGrid2.Cells[21,1]:='18,216';
StringGrid2.Cells[22,1]:='18,542';
StringGrid2.Cells[23,1]:='18,148';
StringGrid2.Cells[24,1]:='17,146';
StringGrid2.Cells[25,1]:='15,778';
StringGrid2.Cells[26,1]:='15,222';
StringGrid2.Cells[27,1]:='15,062';
StringGrid2.Cells[28,1]:='14,16';
StringGrid2.Cells[29,1]:='13,852';
StringGrid2.Cells[30,1]:='12,574';
StringGrid2.Cells[31,1]:='12,194';
StringGrid2.Cells[32,1]:='12,014';
StringGrid2.Cells[33,1]:='11,658';
StringGrid2.Cells[34,1]:='10,878';
StringGrid2.Cells[35,1]:='10,986';
StringGrid2.Cells[36,1]:='11,094';
StringGrid2.Cells[37,1]:='11,17';
StringGrid2.Cells[38,1]:='10,69';
StringGrid2.Cells[39,1]:='10,144';
StringGrid2.Cells[40,1]:='9,204';
StringGrid2.Cells[41,1]:='8,03';
StringGrid2.Cells[42,1]:='6,924';
StringGrid2.Cells[43,1]:='6,426';
StringGrid2.Cells[44,1]:='6,638';
StringGrid2.Cells[45,1]:='6,34';
StringGrid2.Cells[46,1]:='5,0729';
StringGrid2.Cells[47,1]:='0';
StringGrid2.Cells[48,1]:='0';
StringGrid2.Cells[49,1]:='0';
StringGrid2.Cells[50,1]:='0';
StringGrid2.Cells[51,1]:='0';
StringGrid2.Cells[52,1]:='0';
StringGrid2.Cells[53,1]:='0';
StringGrid2.Cells[54,1]:='0';
StringGrid2.Cells[55,1]:='0';
StringGrid2.Cells[56,1]:='0';
StringGrid2.Cells[57,1]:='0';
StringGrid2.Cells[58,1]:='0';
StringGrid2.Cells[59,1]:='0';
Button1Click(sender);
end;

procedure TForm1.N7Click(Sender: TObject);
begin
StringGrid2.Cells[1,1]:='543,494';
StringGrid2.Cells[2,1]:='543,46';
StringGrid2.Cells[3,1]:='543,366';
StringGrid2.Cells[4,1]:='543,248';
StringGrid2.Cells[5,1]:='543,148';
StringGrid2.Cells[6,1]:='543,06';
StringGrid2.Cells[7,1]:='542,99';
StringGrid2.Cells[8,1]:='542,904';
StringGrid2.Cells[9,1]:='542,908';
StringGrid2.Cells[10,1]:='542,828';
StringGrid2.Cells[11,1]:='542,15';
StringGrid2.Cells[12,1]:='541,87';
StringGrid2.Cells[13,1]:='541,268';
StringGrid2.Cells[14,1]:='542,4892';
StringGrid2.Cells[15,1]:='541,972';
StringGrid2.Cells[16,1]:='541,848';
StringGrid2.Cells[17,1]:='541,69';
StringGrid2.Cells[18,1]:='541,58';
StringGrid2.Cells[19,1]:='541,402';
StringGrid2.Cells[20,1]:='541,24';
StringGrid2.Cells[21,1]:='541,216';
StringGrid2.Cells[22,1]:='541,542';
StringGrid2.Cells[23,1]:='541,148';
StringGrid2.Cells[24,1]:='540,146';
StringGrid2.Cells[25,1]:='538,778';
StringGrid2.Cells[26,1]:='538,222';
StringGrid2.Cells[27,1]:='538,062';
StringGrid2.Cells[28,1]:='537,16';
StringGrid2.Cells[29,1]:='536,852';
StringGrid2.Cells[30,1]:='535,574';
StringGrid2.Cells[31,1]:='535,194';
StringGrid2.Cells[32,1]:='535,014';
StringGrid2.Cells[33,1]:='534,658';
StringGrid2.Cells[34,1]:='533,878';
StringGrid2.Cells[35,1]:='533,986';
StringGrid2.Cells[36,1]:='534,094';
StringGrid2.Cells[37,1]:='534,17';
StringGrid2.Cells[38,1]:='533,69';
StringGrid2.Cells[39,1]:='533,144';
StringGrid2.Cells[40,1]:='532,204';
StringGrid2.Cells[41,1]:='531,03';
StringGrid2.Cells[42,1]:='529,924';
StringGrid2.Cells[43,1]:='529,426';
StringGrid2.Cells[44,1]:='529,638';
StringGrid2.Cells[45,1]:='529,34';
StringGrid2.Cells[46,1]:='528,0729';
StringGrid2.Cells[47,1]:='0';
StringGrid2.Cells[48,1]:='0';
StringGrid2.Cells[49,1]:='0';
StringGrid2.Cells[50,1]:='0';
StringGrid2.Cells[51,1]:='0';
StringGrid2.Cells[52,1]:='0';
StringGrid2.Cells[53,1]:='0';
StringGrid2.Cells[54,1]:='0';
StringGrid2.Cells[55,1]:='0';
StringGrid2.Cells[56,1]:='0';
StringGrid2.Cells[57,1]:='0';
StringGrid2.Cells[58,1]:='0';
StringGrid2.Cells[59,1]:='0';
Button1Click(sender);
end;

procedure TForm1.N8Click(Sender: TObject);
var da,al:double;
    j:word;
begin
da:=1/(SpinEdit2.Value); al:=1;
for j:=1 to SpinEdit2.Value do
 begin
 StringGrid2.Cells[j,1]:=FloatToStr(1/al);
 al:=al+da;
 end;
 Button1Click(sender);

end;

end.
