//������ ����������� ��������� ��������� ���������������
//�����: ������� ������. ��98�. ������. 2001.
//
//
//
unit bkpropag;

interface
const MAXLAYERS=100; //������������ ���������� �����
const MAXVES=300; //������������ ���������� �������� � ����
const MAXINPUT=300; //������������ ���������� ������ ���������
const MAXTRAND=300; //���������� �������� �� ��������� ����

type
    TVesCountNeuro=array[0..MAXLAYERS] of word; //��� ���������� �������� � �����
    TVesNeuro=array[1..MAXLAYERS,1..MAXVES,1..MAXVES] of double; //��� �������� ����� ���������
    TTrend=array[1..MAXTRAND] of double;  //��������� ���
    TOutPromezh=array[0..MAXLAYERS,1..MAXVES] of double; //������������� �������� �������
type
TBackPropagation=class
private
       fCountLayer:word; //���������� ����� � ���������
       fArrayVesCount:TVesCountNeuro; //���������� �������� � �����
       fArrayVes:TVesNeuro; //�������� ����� ���������
       fXCount:word; //���������� ������� ��������
       fY:double; //�������� ������ ���������
       fCountTrend:word; //���������� ����� �� ��������� ����
       fTrend:TTrend; //��������� ���
       fYPromezh:TOutPromezh; //������������� �������� �������
       procedure RandomVes; //������� ����� ��������� �������
       function activation (g:double):double; //������� ���������
       function activation_diff(g:Double):double; //����������� ������� ���������
public
      constructor Create;
      function Education(epsilon:double; alpha:double):boolean;
      function DoOnePrognoz:double; //��������� ����������� �������
      function DoPrognoz(X:TTrend):double;

      //������� ������
      //������� ���������� �������� � �����
      function SetArrayVesCount(Count:word; XCount:word; AVC:TVesCountNeuro):boolean; //������� ���������� �������� � �����
      function GetArrayVesCount(var Count:word; var XCount:word):TVesCountNeuro;
      //������ ��������� ���
      function SetTrend(Count:word; ST:TTrend):boolean; //������ ��������� ���
      function GetTrend(var Count:word):TTrend;

      property CountLayer:word read fCountLayer; //���������� �����

end;

implementation
uses Forms,Dialogs,SysUtils;

{ TBackPropagation }
procedure TBackPropagation.RandomVes;
//������� ����� ��������� ��������� �������
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
//�����������
begin
//�������������� ��� ��������
fCountLayer:=0;
fCountTrend:=0;
fXCount:=0;
fY:=0;
Randomize;
RandomVes; //������� ����� ��������� �������
end;

function TBackPropagation.DoOnePrognoz: double;
//����������� �������
var i,j,k:word;
    s:double;
begin
//������ ������� ������� - ������� ������ � ������������� �������
for i:=1 to fXCount do  fYPromezh[0,i]:=fTrend[fCountTrend-fXCount+i];
//��������� ������
for i:=1 to fCountLayer do //��� ������� ����
 for j:=1 to fArrayVesCount[i] do //��� ������� ������� � ����
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //������ ���
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //�������� �� ��������������� ����� ����������� ����
  fYPromezh[i,j]:=activation(s); //������� ���������
  end;
DoOnePrognoz:=fYPromezh[fCountLayer,1]; //�� ��������� ���� - ���� ������
end;

function TBackPropagation.DoPrognoz(X: TTrend): double;
//�������
var i,j,k:word;
    s:double;
begin
//������ ������� ������� - ������� ������ � ������������� �������
for i:=1 to fXCount do  fYPromezh[0,i]:=X[i];
//��������� ������
for i:=1 to fCountLayer do //��� ������� ����
 for j:=1 to fArrayVesCount[i] do //��� ������� ������� � ����
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //������ ���
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //�������� �� ��������������� ����� ����������� ����
  fYPromezh[i,j]:=activation(s); //������� ���������
  end;
DoPrognoz:=fYPromezh[fCountLayer,1]; //�� ��������� ���� - ���� ������

end;

function TBackPropagation.Education(epsilon:double; alpha:double): boolean;
//��������
var ArrayDelta:TOutPromezh; //������ ������-�������
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
    begin nach:=1; d_epsilon:=neuro_epsilon; neuro_epsilon:=0; continue; end; //����������� ��������� ��� �������
 //��������� ������ ������
 for i:=1 to fCountLayer do //��� ������� ����
 for j:=1 to fArrayVesCount[i] do //��� ������� ������� � ����
  begin
  s:=0;
  for k:=1 to fArrayVesCount[i-1] do //������ ���
   s:=s+fArrayVes[i,j,k]*fYPromezh[i-1,k]; //�������� �� ��������������� ����� ����������� ����
  fYPromezh[i,j]:=activation(s); //������� ���������
  end;
 //��������� �������� ������
 //��� ��������� ����
 for j:=1 to fArrayVesCount[fCountLayer] do //��� ������� ������� ���������� ����
 begin
 neuro_epsilon2:=(fTrend[nach+fXCount]-fYPromezh[fCountLayer,j]);
 delta:=neuro_epsilon2*activation_diff(fYPromezh[fCountLayer,j]); //������-��������
 ArrayDelta[fCountLayer,j]:=delta;
 for k:=1 to fArrayVesCount[fCountLayer-1] do //��� ������� ���� ������� ���������� ����
  fArrayVes[fCountLayer,j,k]:=fArrayVes[fCountLayer,j,k]+alpha*delta*fYPromezh[fCountLayer-1,k];
 end;
 neuro_epsilon:=neuro_epsilon+abs(neuro_epsilon2);
 //��� ������� �����
 for i:=fCountLayer-1 downto 1 do //��� ������� ����
  for j:=1 to fArrayVesCount[i] do //��� ������� ������� � ����
   begin //1
   //��������� ������ �������� ���� i
    s:=0;
    for m:=1 to fArrayVesCount[i+1] do //��� ������� ������� � ��������� ����
     s:=s+ArrayDelta[i+1,m]*fArrayVes[i+1,m,j];
    //��������� ������ �������� ��� ���� i
    delta:=activation_diff(fYPromezh[i,j])*s;
    ArrayDelta[i,j]:=delta;
    //������������ ���� ��� ������� j ���� i
     for k:=1 to fArrayVesCount[i-1] do //��� ������� ���� � �������
     fArrayVes[i,j,k]:=fArrayVes[i,j,k]+alpha*delta*fYpromezh[i-1,k];
   end; //1

 //���������� ���������� ������ ������-��������
 d:=0;
 for i:=1 to fCountLayer do //��� ������� ����
  for j:=1 to fArrayVesCount[i] do //��� ������� ������� � ����
   d:=d+abs(ArrayDelta[i,j]);
 //��������� �� ��������� ����
 inc (nach);
 end; {while}
 MessageDlg('��������� ��������� �������� �������� ����������'#13+
'�� '+IntToStr(kol)+' ��������'#13+
'� ���������� ������������ '+FloatToStr(d_epsilon), mtInformation, [mbOk], 0);

end;

function TBackPropagation.GetArrayVesCount(
  var Count: word; var XCount:word): TVesCountNeuro;
begin
//��������� ��������
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
//������ ��������
fXcount:=XCount;
fCountLayer:=Count;
fArrayVesCount:=AVC;
fArrayVesCount[0]:=fXCount; //���������� ������� ��������
SetArrayVesCount:=true;
end;

function TBackPropagation.SetTrend(Count: word; ST: TTrend): boolean;
begin
fCountTrend:=Count;
fTrend:=ST;
SetTrend:=true;
end;

end.
