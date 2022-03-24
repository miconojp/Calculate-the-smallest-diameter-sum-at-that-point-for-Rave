options fullstimer=1;

/************************************************/
/* 　その時点での径和最小値を算出する　　　　　　　　　　　　*/
/************************************************/

*実行環境ROOT　※適宜変更してください;
%let RT_PATH=C:\Users\xxxx\Desktop;

*データの場所　※適宜変更してください;
%let Raw	= &RT_PATH.\1 ;
%let OUT	= &RT_PATH.\1 ;

*ライブラリ登録;
libname RAW " &Raw." access = readonly;
libname OUT " &OUT.";

*日付変換マクロ;
%macro DATECONV(VAR=);
	&VAR.=datepart(&VAR.);
	format &VAR. yymmdd10.;
%mend;

/************************************************/
/* ここまで設定
/************************************************/

*必要なデータを抽出  *****試験ごとに設定*****;
data tu_tl2 ;
	set raw.tu_tl;
	keep  Subject InstanceName S_TUTLDTC TRORRES_SUMDIAM;
run;
data rs_tl2 ;
	set raw.rs_tl;
	keep  Subject InstanceName TRDTC_TL TRORRES_SUMDIAM;
run;

*変数名を統一する;
data rs_tl3;
	set rs_tl2;
	rename  TRDTC_TL = DTC;
run;
data tu_tl3;
	set tu_tl2;
	rename  S_TUTLDTC = DTC;
run;

*データセットを縦積みする;
data TL_ALL;
	set rs_tl3 tu_tl3;
	if DTC =. then delete;
	%DATECONV(VAR=DTC);
run;


*データセットをソートする 重複も削除;
proc sort data=TL_ALL out= TL_ALL2 nodupkey ;
	by SUBJECT DTC ;
run;

*時点最小値を算出する;
data TL_ALL3(drop = lagSubject);
	set TL_ALL2 ;
	retain  SumMin;

	currentMin = TRORRES_SUMDIAM;
	lagSubject = lag(Subject);
	
	if SumMin =. then do ;
		SumMin = currentMin;
	end;
	else if  lagSubject ^= subject then do;
		SumMin = currentMin;
	end;
    else	if lagSubject = subject then do ;

		if SumMin > currentMin then do ;
			SumMin = currentMin;
		end;
	end;
run;

*データをエクスポート;
PROC EXPORT DATA= TL_ALL3
OUTFILE= "&OUT\時点最小値.csv"
DBMS=CSV REPLACE ; PUTNAMES=YES;
RUN;
