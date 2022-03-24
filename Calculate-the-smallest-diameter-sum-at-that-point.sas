options fullstimer=1;

/************************************************/
/* �@���̎��_�ł̌a�a�ŏ��l���Z�o����@�@�@�@�@�@�@�@�@�@�@�@*/
/************************************************/

*���s��ROOT�@���K�X�ύX���Ă�������;
%let RT_PATH=C:\Users\xxxx\Desktop;

*�f�[�^�̏ꏊ�@���K�X�ύX���Ă�������;
%let Raw	= &RT_PATH.\1 ;
%let OUT	= &RT_PATH.\1 ;

*���C�u�����o�^;
libname RAW " &Raw." access = readonly;
libname OUT " &OUT.";

*���t�ϊ��}�N��;
%macro DATECONV(VAR=);
	&VAR.=datepart(&VAR.);
	format &VAR. yymmdd10.;
%mend;

/************************************************/
/* �����܂Őݒ�
/************************************************/

*�K�v�ȃf�[�^�𒊏o  *****�������Ƃɐݒ�*****;
data tu_tl2 ;
	set raw.tu_tl;
	keep  Subject InstanceName S_TUTLDTC TRORRES_SUMDIAM;
run;
data rs_tl2 ;
	set raw.rs_tl;
	keep  Subject InstanceName TRDTC_TL TRORRES_SUMDIAM;
run;

*�ϐ����𓝈ꂷ��;
data rs_tl3;
	set rs_tl2;
	rename  TRDTC_TL = DTC;
run;
data tu_tl3;
	set tu_tl2;
	rename  S_TUTLDTC = DTC;
run;

*�f�[�^�Z�b�g���c�ς݂���;
data TL_ALL;
	set rs_tl3 tu_tl3;
	if DTC =. then delete;
	%DATECONV(VAR=DTC);
run;


*�f�[�^�Z�b�g���\�[�g���� �d�����폜;
proc sort data=TL_ALL out= TL_ALL2 nodupkey ;
	by SUBJECT DTC ;
run;

*���_�ŏ��l���Z�o����;
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

*�f�[�^���G�N�X�|�[�g;
PROC EXPORT DATA= TL_ALL3
OUTFILE= "&OUT\���_�ŏ��l.csv"
DBMS=CSV REPLACE ; PUTNAMES=YES;
RUN;
