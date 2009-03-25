//Модуль реализующий нейросеть обратного распространения
//Автор: Дмитрий Пауков. ПО98в. Донецк. 2001.
//
//
//
unit bkpropag;

interface
const MAXLAYERS=100; //максимальное количество слоев
const MAXVES=300; //максимальное количество нейронов в слое
const MAXINPUT=300; //максимальное количество входов нейросети
const MAXTRAND=300; //количество значений во временном ряду

type
    TVesCountNeuro=array[0..MAXLAYERS] of word; //тип количество нейронов в слоях
    TVesNeuro=array[1..MAXLAYERS,1..MAXVES,1..MAXVES] of double; //тип значений весов нейросети
    TTrend=array[1..MAXTRAND] of double;  //временной ряд
    TOutPromezh=array[0..MAXLAYERS,1..MAXVES] of double; //промежуточные выходные сигналы
type
TBackPropagation=class
private
       fCountLayer:word; //количество слоев в нейросети
       fArrayVesCount:TVesCountNeuro; //количество нейронов в слоях
       fArrayVes:TVesNeuro; //значения весов нейросети
       fXCount:word; //количество входных сигналов
       fY:double; //выходной сигнал нейросети
       fCountTrend:word; //количнство чисел во временном ряду
       fTrend:TTrend; //временной ряд
       fYPromezh:TOutPromezh; //промежуточные выходные сигналы
       procedure RandomVes; //задание весов случайным образом
       function activation (g:double):double; //функция активации
       function activation_diff(g:Double):double; //производная функции активации
public
      constructor Create;
      function Education(epsilon:double; alpha:double):boolean;
      function DoOnePrognoz:double; //выполняет одношаговый прогноз
      function DoPrognoz(X:TTrend):double;

      //входные данные
      //задание количество нейронов в слоях
      function SetArrayVesCount(Count:word; XCount:word; AVC:TVesCountNeuro):boolean; //задание количество нейронов в слоях
      function GetArrayVesCount(var Count:word; var XCount:word):TVesCountNeuro;
      //задать временной ряд
      function SetTrend(Count:word; ST:TTrend):boolean; //задать временной ряд
      function GetTrend(var Count:word):TTrend;

      property CountLayer:word read fCountLayer; //количество слоев

end;

implementation
uses Forms,Dialogs,SysUtils;

{ TBackPropagation }
procedure TBackPropagation.RandomVes;
//задание весов нейросети случайным образом
var i,j,k:word;
begin
for i:=1 to MAXLAYERS do
 for j:=1 to MAXVES do
  for k:=1 to MAXVES do
  fArrayVes[i,j,k]:=Random(800)/1000;
end;

function TBackPropagation.activation(g: double): double;
begin
activation:=1/(1+Exp(-g));
end;

function TBackPropagation.activation_diff(g: Double): double;
begin
activation_diff:=g*(1-g);
end;

constructor TBackPropagation.Create;
//конструктор
begin
//инициализируем все значения
fCountLayer:=0;
fCountTrend:=0;
fXCount:=0;
fY:=0;
Randomize;
RandomVes; //задание весов случайным образом
end;

function TBackPropagation.DoOnePrognoz: double;
//одношаговый прогноз
var i,j,k:word;
    s:double;
begin
//задаем входные сигналы - нулевая строка в промежутояных выходах
for i:=1 to fXCount do  fYPromezh[0,i]:=fTrend[fCountTrend-fXCount+i];
//выполняем расчет
for i:=1 to fCountLayer do //для каждого слоя
 for j:=1 to fArrayVesCount[i] do //для кождого нейрона в слое
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //каждый вес
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //умножаем на соответствующий выход предыдущего слоя
  fYPromezh[i,j]:=activation(s); //функция активации
  end;
DoOnePrognoz:=fYPromezh[fCountLayer,1]; //на последнем слое - один нейрон
end;

function TBackPropagation.DoPrognoz(X: TTrend): double;
//прогноз
var i,j,k:word;
    s:double;
begin
//задаем входные сигналы - нулевая строка в промежуточных выходах
for i:=1 to fXCount do  fYPromezh[0,i]:=X[i];
//выполняем расчет
for i:=1 to fCountLayer do //для каждого слоя
 for j:=1 to fArrayVesCount[i] do //для кождого нейрона в слое
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //каждый вес
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //умножаем на соответствующий выход предыдущего слоя
  fYPromezh[i,j]:=activation(s); //функция активации
  end;
DoPrognoz:=fYPromezh[fCountLayer,1]; //на последнем слое - один нейрон

end;

function TBackPropagation.Education(epsilon:double; alpha:double): boolean;
//обучение
var ArrayDelta:TOutPromezh; //массив дельта-величин
    i,j,k,m:word;
    s,d,delta:double;
    nach:word;
    neuro_epsilon,neuro_epsilon2,d_epsilon:double;
    kol:longint;
begin
d:=100; nach:=1;  neuro_epsilon:=0;   d_epsilon:=100;
kol:=0;
while  (d_epsilon>epsilon) and (kol<200000000) do
 begin {while}
 inc(kol);
 Application.ProcessMessages;
  if nach<=fCountTrend-fXCount then
   for i:=1 to fXCount do fYPromezh[0,i]:=fTrend[nach+i-1]
   else
    begin nach:=1; d_epsilon:=neuro_epsilon; neuro_epsilon:=0; continue; end; //анализируем временной ряд сначала
 //выполняем прямой проход
 for i:=1 to fCountLayer do //для каждого слоя
 for j:=1 to fArrayVesCount[i] do //для кождого нейрона в слое
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //каждый вес
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //умножаем на соответствующий выход предыдущего слоя
  fYPromezh[i,j]:=activation(s); //функция активации
  end;
 //выполняем обратный проход
 //для выходного слоя
 for j:=1 to fArrayVesCount[fCountLayer] do //для каждого нейрона последнего слоя
 begin
 neuro_epsilon2:=(fTrend[nach+fXCount]-fYPromezh[fCountLayer,j]);
 delta:=neuro_epsilon2*activation_diff(fYPromezh[fCountLayer,j]); //дельта-величина
 ArrayDelta[fCountLayer,j]:=delta;
 for k:=1 to fArrayVesCount[fCountLayer-1] do //для каждого веса нейрона последнего слоя
  fArrayVes[fCountLayer,j,k]:=fArrayVes[fCountLayer,j,k]+alpha*delta*fYPromezh[fCountLayer-1,k];
 end;
 neuro_epsilon:=neuro_epsilon+abs(neuro_epsilon2);
 //для скрытых слоев
 for i:=fCountLayer-1 downto 1 do //для каждого слоя
  for j:=1 to fArrayVesCount[i] do //для каждого нейрона в слое
   begin //1
   //вычисляем ошибку скрытого слоя i
    s:=0;
    for m:=1 to fArrayVesCount[i+1] do //для каждого нейрона в следующем слое
     s:=s+ArrayDelta[i+1,m]*fArrayVes[i+1,m,j];
    //вычисляем дельта величину для слоя i
    delta:=activation_diff(fYPromezh[i,j])*s;
    ArrayDelta[i,j]:=delta;
    //корректируем веса для нейрона j слоя i
     for k:=1 to fArrayVesCount[i-1] do //для каждого веса в нейроне
     fArrayVes[i,j,k]:=fArrayVes[i,j,k]+alpha*delta*fYpromezh[i-1,k];
   end; //1

 //определяем совокупную ошибку дельта-величины
 d:=0;
 for i:=1 to fCountLayer do //для каждого слоя
  for j:=1 to fArrayVesCount[i] do //для каждого нейрона в слое
   d:=d+abs(ArrayDelta[i,j]);
 //переходим на следующее окно
 inc (nach);
 end; {while}
 MessageDlg('Нейросеть обучилась согласно заданным параметрам'#13+
'за '+IntToStr(kol)+' итераций'#13+
'с совокупной погрешностью '+FloatToStr(d_epsilon), mtInformation, [mbOk], 0);

end;

function TBackPropagation.GetArrayVesCount(
  var Count: word; var XCount:word): TVesCountNeuro;
begin
//считываем значения
XCount:=fXCount;
Count:=fCountLayer;
GetArrayVesCount:=fArrayVesCount;
end;

function TBackPropagation.GetTrend(var Count: word): TTrend;
begin
Count:=fCountTrend;
GetTrend:=fTrend;
end;

function TBackPropagation.SetArrayVesCount(Count: word; XCount:word;
  AVC: TVesCountNeuro): boolean;
begin
//задаем значения
fXcount:=XCount;
fCountLayer:=Count;
fArrayVesCount:=AVC;
fArrayVesCount[0]:=fXCount; //количество входных сигналов
SetArrayVesCount:=true;
end;

function TBackPropagation.SetTrend(Count: word; ST: TTrend): boolean;
begin
fCountTrend:=Count;
fTrend:=ST;
SetTrend:=true;
end;

end.
