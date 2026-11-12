π
=C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Notifications.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
enum 
NotificationType 
{ 
RenewalReminder .
,. /
TicketStatusChanged0 C
,C D
TicketReplyE P
,P Q
PaymentReceivedR a
,a b
PaymentFailedc p
,p q
AccountAccessr 
,	 Ä
TransferRequested
Å í
,
í ì
TicketCreated
î °
,
° ¢
TaxDueReminder
£ ±
,
± ≤
TransferReported
≥ √
,
√ ƒ
TransferRejected
≈ ’
,
’ ÷
ContactLead
◊ ‚
}
„ ‰
public 
sealed 
record 
Notification !
(! "
NotificationType" 2
Type3 7
,7 8

Dictionary9 C
<C D
stringD J
,J K
stringL R
>R S
DataT X
,X Y
stringZ `
?` a
	DedupeKeyb k
=l m
nulln r
,r s
stringt z
?z {
To| ~
=	 Ä
null
Å Ö
)
Ö Ü
;
Ü á
public 
sealed 
record 
EmailMessage !
(! "
string" (
To) +
,+ ,
string- 3
Subject4 ;
,; <
string= C
HtmlD H
,H I
stringJ P
TextQ U
)U V
;V W
public 
	interface 
IEmailSender 
{ 
Task 
	SendAsync	 
( 
EmailMessage 
message  '
,' (
CancellationToken) :
cancellationToken; L
=M N
defaultO V
)V W
;W X
} ≥
9C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\IncomeTax.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
sealed 
record 
MypeIncomeTax "
(" #
decimal# *
Limit+ 0
,0 1
decimal2 9
LowBase: A
,A B
decimalC J
LowTaxK Q
,Q R
decimalS Z
HighBase[ c
,c d
decimale l
HighTaxm t
)t u
{ 
public 

decimal 
Total 
=> 
LowTax "
+# $
HighTax% ,
;, -
public 

static 
MypeIncomeTax 
Compute  '
(' (
decimal( /
	netIncome0 9
,9 :
AnnualTaxSettings; L
settingsM U
)U V
{ 
var 
limit 
= 
settings 
. 
ThresholdUits *
*+ ,
settings- 5
.5 6
Uit6 9
;9 :
var 
taxable 
= 
Math 
. 
Max 
( 
	netIncome (
,( )
$num* ,
), -
;- .
var 
low 
= 
Math 
. 
Min 
( 
taxable "
," #
limit$ )
)) *
;* +
var, /
high0 4
=5 6
Math7 ;
.; <
Max< ?
(? @
taxable@ G
-H I
limitJ O
,O P
$numQ S
)S T
;T U
return 
new 
MypeIncomeTax  
(  !
limit! &
,& '
low( +
,+ ,
Math- 1
.1 2
Round2 7
(7 8
low8 ;
*< =
settings> F
.F G
LowRateG N
,N O
$numP Q
)Q R
,R S
highT X
,X Y
MathZ ^
.^ _
Round_ d
(d e
highe i
*j k
settingsl t
.t u
HighRateu }
,} ~
$num	 Ä
)
Ä Å
)
Å Ç
;
Ç É
} 
} 
public 
static 
class 
Form1662 
{ 
public 

static 
decimal 
Igv 
( 
Expense %
expense& -
,- .
decimal/ 6
igvRate7 >
)> ?
=>@ B
MathC G
.G H
RoundH M
(M N
expenseN U
.U V
	AmountPenV _
*` a
igvRateb i
,i j
$numk l
)l m
;m n
} ¿_
:C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\GitHubSync.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
static 
class 
GitHubLabels  
{ 
public		 

const		 
string		 
StatusPrefix		 $
=		% &
$str		' 0
;		0 1
public

 

const

 
string

 
ProjectPrefix

 %
=

& '
$str

( 3
;

3 4
private 
static 
readonly 
( 
TicketStatus )
Status* 0
,0 1
string2 8
Label9 >
)> ?
[? @
]@ A
StatusLabelsB N
=O P
[ 
( 	
TicketStatus	 
. 
Abierto 
, 
$str /
)/ 0
,0 1
( 	
TicketStatus	 
. 

EnProgreso  
,  !
$str" 6
)6 7
,7 8
( 	
TicketStatus	 
. 
Resuelto 
, 
$str  1
)1 2
,2 3
( 	
TicketStatus	 
. 
	Publicado 
,  
$str! 3
)3 4
,4 5
( 	
TicketStatus	 
. 
Cerrado 
, 
$str /
)/ 0
,0 1
] 
; 
public 

const 
string 
PortalCommentMarker +
=, -
$str. J
;J K
public 

static 
string 
ForType  
(  !

TicketType! +
type, 0
)0 1
=>2 4
type5 9
switch: @
{ 

TicketType 
. 
Bug 
=> 
$str 
,  

TicketType 
. 
Funcionalidad  
=>! #
$str$ 1
,1 2
_ 	
=>
 
$str 
, 
} 
; 
public 

static 
string 
	ForStatus "
(" #
TicketStatus# /
status0 6
)6 7
=>8 :
StatusLabels; G
.G H
FirstH M
(M N
xN O
=>P R
xS T
.T U
StatusU [
==\ ^
status_ e
)e f
.f g
Labelg l
;l m
public 

static 
string 

ForProject #
(# $
string$ *
projectSlug+ 6
)6 7
=>8 :
ProjectPrefix; H
+I J
projectSlugK V
;V W
public(( 

static(( 
TicketStatus(( 
ResolveStatus(( ,
(((, -
string((- 3

issueState((4 >
,((> ?
string((@ F
?((F G
stateReason((H S
,((S T
IEnumerable((U `
<((` a
string((a g
>((g h
labels((i o
)((o p
{)) 
var** 
set** 
=** 
labels** 
.** 
Select** 
(**  
x**  !
=>**" $
x**% &
.**& '
Trim**' +
(**+ ,
)**, -
.**- .
ToLowerInvariant**. >
(**> ?
)**? @
)**@ A
.**A B
	ToHashSet**B K
(**K L
)**L M
;**M N
var++ 
closed++ 
=++ 
string++ 
.++ 
Equals++ "
(++" #

issueState++# -
,++- .
$str++/ 7
,++7 8
StringComparison++9 I
.++I J
OrdinalIgnoreCase++J [
)++[ \
;++\ ]
foreach-- 
(-- 
var-- 
(-- 
status-- 
,-- 
label-- #
)--# $
in--% '
StatusLabels--( 4
.--4 5
Reverse--5 <
(--< =
)--= >
)--> ?
if.. 
(.. 
set.. 
... 
Contains.. 
(.. 
label.. "
).." #
&&..$ &
(..' (
!..( )
closed..) /
||..0 2
status..3 9
>=..: <
TicketStatus..= I
...I J
Resuelto..J R
)..R S
)..S T
return..U [
status..\ b
;..b c
if// 

(// 
!// 
closed// 
)// 
return// 
TicketStatus// (
.//( )
Abierto//) 0
;//0 1
return00 
string00 
.00 
Equals00 
(00 
stateReason00 (
,00( )
$str00* 7
,007 8
StringComparison009 I
.00I J
OrdinalIgnoreCase00J [
)00[ \
?00] ^
TicketStatus00_ k
.00k l
Cerrado00l s
:00t u
TicketStatus	00v Ç
.
00Ç É
Resuelto
00É ã
;
00ã å
}11 
}22 
public55 
static55 
class55 
GitHubProjectStatus55 '
{66 
private77 
static77 
readonly77 

Dictionary77 &
<77& '
string77' -
,77- .
TicketStatus77/ ;
>77; <
Columns77= D
=77E F
new77G J
(77J K
)77K L
{88 
[99 	
$str99	 
]99 
=99 
TicketStatus99 #
.99# $
Abierto99$ +
,99+ ,
[99- .
$str99. 7
]997 8
=999 :
TicketStatus99; G
.99G H
Abierto99H O
,99O P
[99Q R
$str99R X
]99X Y
=99Z [
TicketStatus99\ h
.99h i
Abierto99i p
,99p q
[99r s
$str99s z
]99z {
=99| }
TicketStatus	99~ ä
.
99ä ã
Abierto
99ã í
,
99í ì
[
99î ï
$str
99ï û
]
99û ü
=
99† °
TicketStatus
99¢ Æ
.
99Æ Ø
Abierto
99Ø ∂
,
99∂ ∑
[:: 	
$str::	 
]:: 
=:: 
TicketStatus:: &
.::& '

EnProgreso::' 1
,::1 2
[::3 4
$str::4 A
]::A B
=::C D
TicketStatus::E Q
.::Q R

EnProgreso::R \
,::\ ]
[;; 	
$str;;	 
];; 
=;; 
TicketStatus;; #
.;;# $
Resuelto;;$ ,
,;;, -
[;;. /
$str;;/ 5
];;5 6
=;;7 8
TicketStatus;;9 E
.;;E F
Resuelto;;F N
,;;N O
[<< 	
$str<<	 
]<< 
=<< 
TicketStatus<< $
.<<$ %
	Publicado<<% .
,<<. /
[<<0 1
$str<<1 <
]<<< =
=<<> ?
TicketStatus<<@ L
.<<L M
	Publicado<<M V
,<<V W
[== 	
$str==	 
]== 
=== 
TicketStatus== "
.==" #
Cerrado==# *
,==* +
[==, -
$str==- 5
]==5 6
===7 8
TicketStatus==9 E
.==E F
Cerrado==F M
,==M N
}>> 
;>> 
publicAA 

staticAA 
TicketStatusAA 
?AA 
MapAA  #
(AA# $
stringAA$ *
?AA* +
columnAA, 2
)AA2 3
{BB 
ifCC 

(CC 
stringCC 
.CC 
IsNullOrWhiteSpaceCC %
(CC% &
columnCC& ,
)CC, -
)CC- .
returnCC/ 5
nullCC6 :
;CC: ;
varDD 
plainDD 
=DD 
newDD 
stringDD 
(DD 
columnDD %
.DD% &
TrimDD& *
(DD* +
)DD+ ,
.DD, -
ToLowerInvariantDD- =
(DD= >
)DD> ?
.DD? @
	NormalizeDD@ I
(DDI J
SystemDDJ P
.DDP Q
TextDDQ U
.DDU V
NormalizationFormDDV g
.DDg h
FormDDDh m
)DDm n
.EE 
WhereEE 
(EE 
cEE 
=>EE 
SystemEE 
.EE 
GlobalizationEE ,
.EE, -
CharUnicodeInfoEE- <
.EE< =
GetUnicodeCategoryEE= O
(EEO P
cEEP Q
)EEQ R
!=EES U
SystemEEV \
.EE\ ]
GlobalizationEE] j
.EEj k
UnicodeCategoryEEk z
.EEz {
NonSpacingMark	EE{ â
)
EEâ ä
.
EEä ã
ToArray
EEã í
(
EEí ì
)
EEì î
)
EEî ï
;
EEï ñ
returnFF 
ColumnsFF 
.FF 
TryGetValueFF "
(FF" #
plainFF# (
,FF( )
outFF* -
varFF. 1
statusFF2 8
)FF8 9
?FF: ;
statusFF< B
:FFC D
nullFFE I
;FFI J
}GG 
publicMM 

staticMM 
TicketStatusMM 
?MM 
ResolveMM  '
(MM' (
GitHubIssueStateMM( 8
stateMM9 >
)MM> ?
=>MM@ B
MapNN 
(NN 
stateNN 
.NN 
ProjectStatusNN 
)NN  
isNN! #
{NN$ %
}NN& '
statusNN( .
&&NN/ 1
(NN2 3
!NN3 4
stateNN4 9
.NN9 :
ClosedNN: @
||NNA C
statusNND J
>=NNK M
TicketStatusNNN Z
.NNZ [
ResueltoNN[ c
)NNc d
?NNe f
statusNNg m
:NNn o
nullNNp t
;NNt u
}OO 
publicQQ 
staticQQ 
classQQ "
GitHubWebhookSignatureQQ *
{RR 
publicTT 

staticTT 
boolTT 
IsValidTT 
(TT 
stringTT %
secretTT& ,
,TT, -
byteTT. 2
[TT2 3
]TT3 4
bodyTT5 9
,TT9 :
stringTT; A
?TTA B
signatureHeaderTTC R
)TTR S
{UU 
constVV 
stringVV 
prefixVV 
=VV 
$strVV '
;VV' (
ifWW 

(WW 
stringWW 
.WW 
IsNullOrEmptyWW  
(WW  !
secretWW! '
)WW' (
||WW) +
stringWW, 2
.WW2 3
IsNullOrEmptyWW3 @
(WW@ A
signatureHeaderWWA P
)WWP Q
||WWR T
!WWU V
signatureHeaderWWV e
.WWe f

StartsWithWWf p
(WWp q
prefixWWq w
,WWw x
StringComparison	WWy â
.
WWâ ä
Ordinal
WWä ë
)
WWë í
)
WWí ì
return
WWî ö
false
WWõ †
;
WW† °
byteXX 
[XX 
]XX 
expectedXX 
;XX 
tryYY 
{YY 
expectedYY 
=YY 
ConvertYY  
.YY  !
FromHexStringYY! .
(YY. /
signatureHeaderYY/ >
[YY> ?
prefixYY? E
.YYE F
LengthYYF L
..YYL N
]YYN O
)YYO P
;YYP Q
}YYR S
catchZZ 
(ZZ 
FormatExceptionZZ 
)ZZ 
{ZZ  !
returnZZ" (
falseZZ) .
;ZZ. /
}ZZ0 1
var[[ 
actual[[ 
=[[ 

HMACSHA256[[ 
.[[  
HashData[[  (
([[( )
Encoding[[) 1
.[[1 2
UTF8[[2 6
.[[6 7
GetBytes[[7 ?
([[? @
secret[[@ F
)[[F G
,[[G H
body[[I M
)[[M N
;[[N O
return\\ #
CryptographicOperations\\ &
.\\& '
FixedTimeEquals\\' 6
(\\6 7
actual\\7 =
,\\= >
expected\\? G
)\\G H
;\\H I
}]] 
}^^ ™¯
8C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Entities.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
enum 
UserRole 
{ 
Admin 
, 
Cliente %
,% &

SuperAdmin' 1
}2 3
public 
enum 
ProductType 
{ 
Hosting !
,! "
Dominio# *
,* +
Ssl, /
,/ 0
BackupBd1 9
,9 :
SoporteMensual; I
,I J
DesarrolloWebK X
}Y Z
public 
enum 
BillingCycle 
{ 
Unico  
,  !
Mensual" )
,) *
Anual+ 0
,0 1
	Bimestral2 ;
,; <

Trimestral= G
,G H
	SemestralI R
}S T
public 
static 
class 
BillingCycles !
{ 
public 

static 
int 
Months 
( 
this !
BillingCycle" .
cycle/ 4
)4 5
=>6 8
cycle9 >
==? A
BillingCycleB N
.N O
AnualO T
?U V
$numW Y
:Z [
cycle\ a
.a b
SubscriptionMonthsb t
(t u
)u v
??w y
throwz 
new
Ä É)
ArgumentOutOfRangeException
Ñ ü
(
ü †
nameof
† ¶
(
¶ ß
cycle
ß ¨
)
¨ ≠
,
≠ Æ
$str
Ø Ã
)
Ã Õ
;
Õ Œ
public 

static 
int 
? 
SubscriptionMonths )
() *
this* .
BillingCycle/ ;
cycle< A
)A B
=>C E
cycleF K
switchL R
{S T
BillingCycleU a
.a b
Mensualb i
=>j l
$numm n
,n o
BillingCyclep |
.| }
	Bimestral	} Ü
=>
á â
$num
ä ã
,
ã å
BillingCycle
ç ô
.
ô ö

Trimestral
ö §
=>
• ß
$num
® ©
,
© ™
BillingCycle
´ ∑
.
∑ ∏
	Semestral
∏ ¡
=>
¬ ƒ
$num
≈ ∆
,
∆ «
_
» …
=>
  Ã
null
Õ —
}
“ ”
;
” ‘
public 

static 
bool 
IsSubscription %
(% &
this& *
BillingCycle+ 7
cycle8 =
)= >
=>? A
cycleB G
.G H
SubscriptionMonthsH Z
(Z [
)[ \
is] _
not` c
nulld h
;h i
} 
public 
enum 
ClientProductStatus 
{  !
Activo" (
,( )
	PorVencer* 3
,3 4
Vencido5 <
,< =
	Cancelado> G
,G H
	PendienteI R
}S T
public 
enum 

TicketType 
{ 
Bug 
, 
Funcionalidad +
,+ ,
Requerimiento- :
}; <
public 
enum 
TicketStatus 
{ 
Abierto "
," #

EnProgreso$ .
,. /
Resuelto0 8
,8 9
	Publicado: C
,C D
CerradoE L
}M N
public 
enum 
TaxDocumentType 
{ 
Factura %
,% &
ReciboPorHonorarios' :
}; <
public 
static 
class 
PaymentMethods "
{# $
public% +
const, 1
string2 8
PayPal9 ?
=@ A
$strB J
;J K
publicL R
constS X
stringY _
Transferencia` m
=n o
$strp 
;	 Ä
public 

const 
string 
Remesa 
=  
$str! )
;) *
}+ ,
public 
enum 
ExpenseType 
{ 
Fijo 
, 
Variable  (
}) *
public 
sealed 
class 
ExpenseCategory #
{$ %
public& ,
Guid- 1
Id2 4
{5 6
get7 :
;: ;
set< ?
;? @
}A B
=C D
GuidE I
.I J
NewGuidJ Q
(Q R
)R S
;S T
publicU [
string\ b
Namec g
{h i
getj m
;m n
seto r
;r s
}t u
=v w
stringx ~
.~ 
Empty	 Ñ
;
Ñ Ö
public 
string 
? 
Code 
{ 
get 
; 
set 
;  
}! "
public 
bool 
IsIncomeTax 
{ 
get 
; 
set  #
;# $
}% &
public' -
int. 1
	SortOrder2 ;
{< =
get> A
;A B
setC F
;F G
}H I
public 

bool 
IsDeductible 
{ 
get "
;" #
set$ '
;' (
}) *
=+ ,
true- 1
;1 2
}3 4
public 
static 
class 
ExpenseCategoryIds &
{ 
public   

static   
readonly   
Guid   
Hosting    '
=  ( )
new  * -
(  - .
$str  . T
)  T U
;  U V
public!! 

static!! 
readonly!! 
Guid!! 
Dominios!!  (
=!!) *
new!!+ .
(!!. /
$str!!/ U
)!!U V
;!!V W
public"" 

static"" 
readonly"" 
Guid"" 
SuscripcionesIA""  /
=""0 1
new""2 5
(""5 6
$str""6 \
)""\ ]
;""] ^
public## 

static## 
readonly## 
Guid## 

ApisPorUso##  *
=##+ ,
new##- 0
(##0 1
$str##1 W
)##W X
;##X Y
public$$ 

static$$ 
readonly$$ 
Guid$$ 
Sueldos$$  '
=$$( )
new$$* -
($$- .
$str$$. T
)$$T U
;$$U V
public%% 

static%% 
readonly%% 
Guid%% 
Otros%%  %
=%%& '
new%%( +
(%%+ ,
$str%%, R
)%%R S
;%%S T
public&& 

static&& 
readonly&& 
Guid&& 
ImpuestoRenta&&  -
=&&. /
new&&0 3
(&&3 4
$str&&4 Z
)&&Z [
;&&[ \
public'' 

static'' 
readonly'' 
Guid'' 

Comisiones''  *
=''+ ,
new''- 0
(''0 1
$str''1 W
)''W X
;''X Y
public)) 

static)) 
IReadOnlyList)) 
<))  
ExpenseCategory))  /
>))/ 0
Seed))1 5
=>))6 8
[** 
new++ 
(++ 
)++ 
{++ 
Id++ 
=++ 
Hosting++ 
,++ 
Code++ "
=++# $
$str++% .
,++. /
Name++0 4
=++5 6
$str++7 @
,++@ A
	SortOrder++B K
=++L M
$num++N O
}++P Q
,++Q R
new,, 
(,, 
),, 
{,, 
Id,, 
=,, 
Dominios,, 
,,, 
Code,, #
=,,$ %
$str,,& 0
,,,0 1
Name,,2 6
=,,7 8
$str,,9 C
,,,C D
	SortOrder,,E N
=,,O P
$num,,Q R
},,S T
,,,T U
new-- 
(-- 
)-- 
{-- 
Id-- 
=-- 
SuscripcionesIA-- $
,--$ %
Code--& *
=--+ ,
$str--- >
,--> ?
Name--@ D
=--E F
$str--G Y
,--Y Z
	SortOrder--[ d
=--e f
$num--g h
}--i j
,--j k
new.. 
(.. 
).. 
{.. 
Id.. 
=.. 

ApisPorUso.. 
,..  
Code..! %
=..& '
$str..( 4
,..4 5
Name..6 :
=..; <
$str..= K
,..K L
	SortOrder..M V
=..W X
$num..Y Z
}..[ \
,..\ ]
new// 
(// 
)// 
{// 
Id// 
=// 
Sueldos// 
,// 
Code// "
=//# $
$str//% .
,//. /
Name//0 4
=//5 6
$str//7 @
,//@ A
	SortOrder//B K
=//L M
$num//N O
}//P Q
,//Q R
new00 
(00 
)00 
{00 
Id00 
=00 
Otros00 
,00 
Code00  
=00! "
$str00# *
,00* +
Name00, 0
=001 2
$str003 :
,00: ;
	SortOrder00< E
=00F G
$num00H I
}00J K
,00K L
new11 
(11 
)11 
{11 
Id11 
=11 
ImpuestoRenta11 "
,11" #
Code11$ (
=11) *
$str11+ :
,11: ;
Name11< @
=11A B
$str11C X
,11X Y
IsIncomeTax11Z e
=11f g
true11h l
,11l m
	SortOrder11n w
=11x y
$num11z {
}11| }
,11} ~
new22 
(22 
)22 
{22 
Id22 
=22 

Comisiones22 
,22  
Code22! %
=22& '
$str22( 4
,224 5
Name226 :
=22; <
$str22= I
,22I J
	SortOrder22K T
=22U V
$num22W X
}22Y Z
,22Z [
]33 
;33 
}44 
public66 
enum66  
PurchaseDocumentType66  
{66! "
Factura66# *
,66* +
NotaCredito66, 7
,667 8

NotaDebito669 C
,66C D
Boleta66E K
,66K L
ReciboPorHonorarios66M `
,66` a

Extranjero66b l
,66l m
Otro66n r
}66s t
public== 
sealed== 
class== 
Purchase== 
{>> 
public?? 

Guid?? 
Id?? 
{?? 
get?? 
;?? 
set?? 
;?? 
}??  
=??! "
Guid??# '
.??' (
NewGuid??( /
(??/ 0
)??0 1
;??1 2
public@@ 

DateOnly@@ 
	IssueDate@@ 
{@@ 
get@@  #
;@@# $
set@@% (
;@@( )
}@@* +
publicBB 

DateOnlyBB 
PeriodBB 
{BB 
getBB  
;BB  !
setBB" %
;BB% &
}BB' (
publicCC 
 
PurchaseDocumentTypeCC 
DocumentTypeCC  ,
{CC- .
getCC/ 2
;CC2 3
setCC4 7
;CC7 8
}CC9 :
publicDD 

stringDD 
SeriesDD 
{DD 
getDD 
;DD 
setDD  #
;DD# $
}DD% &
=DD' (
stringDD) /
.DD/ 0
EmptyDD0 5
;DD5 6
publicEE 

stringEE 
NumberEE 
{EE 
getEE 
;EE 
setEE  #
;EE# $
}EE% &
=EE' (
stringEE) /
.EE/ 0
EmptyEE0 5
;EE5 6
publicFF 

stringFF 
SupplierTaxIdFF 
{FF  !
getFF" %
;FF% &
setFF' *
;FF* +
}FF, -
=FF. /
stringFF0 6
.FF6 7
EmptyFF7 <
;FF< =
publicGG 

stringGG 
SupplierNameGG 
{GG  
getGG! $
;GG$ %
setGG& )
;GG) *
}GG+ ,
=GG- .
stringGG/ 5
.GG5 6
EmptyGG6 ;
;GG; <
publicHH 

stringHH 
CurrencyHH 
{HH 
getHH  
;HH  !
setHH" %
;HH% &
}HH' (
=HH) *
$strHH+ 0
;HH0 1
publicII 

decimalII 
TaxBaseII 
{II 
getII  
;II  !
setII" %
;II% &
}II' (
publicJJ 

decimalJJ 
IgvJJ 
{JJ 
getJJ 
;JJ 
setJJ !
;JJ! "
}JJ# $
publicLL 

decimalLL 

NonTaxableLL 
{LL 
getLL  #
;LL# $
setLL% (
;LL( )
}LL* +
publicMM 

decimalMM 
TotalMM 
{MM 
getMM 
;MM 
setMM  #
;MM# $
}MM% &
publicNN 

decimalNN 
ExchangeRateNN 
{NN  !
getNN" %
;NN% &
setNN' *
;NN* +
}NN, -
=NN. /
$numNN0 2
;NN2 3
publicOO 

decimalOO 
BasePenOO 
{OO 
getOO  
;OO  !
setOO" %
;OO% &
}OO' (
publicPP 

decimalPP 
IgvPenPP 
{PP 
getPP 
;PP  
setPP! $
;PP$ %
}PP& '
publicQQ 

decimalQQ 
TotalPenQQ 
{QQ 
getQQ !
;QQ! "
setQQ# &
;QQ& '
}QQ( )
publicRR 

boolRR 
GivesTaxCreditRR 
{RR  
getRR! $
;RR$ %
setRR& )
;RR) *
}RR+ ,
publicTT 

GuidTT 
?TT 
	ExpenseIdTT 
{TT 
getTT  
;TT  !
setTT" %
;TT% &
}TT' (
publicUU 

stringUU 
?UU 
NotesUU 
{UU 
getUU 
;UU 
setUU  #
;UU# $
}UU% &
publicVV 

DateTimeVV 
	CreatedAtVV 
{VV 
getVV  #
;VV# $
setVV% (
;VV( )
}VV* +
=VV, -
DateTimeVV. 6
.VV6 7
UtcNowVV7 =
;VV= >
publicXX 

staticXX 
boolXX 
AllowsTaxCreditXX &
(XX& ' 
PurchaseDocumentTypeXX' ;
typeXX< @
)XX@ A
=>XXB D
typeXXE I
isXXJ L 
PurchaseDocumentTypeXXM a
.XXa b
FacturaXXb i
orXXj l!
PurchaseDocumentType	XXm Å
.
XXÅ Ç
NotaCredito
XXÇ ç
or
XXé ê"
PurchaseDocumentType
XXë •
.
XX• ¶

NotaDebito
XX¶ ∞
;
XX∞ ±
publicZZ 

decimalZZ 
TaxCreditPenZZ 
=>ZZ  "
GivesTaxCreditZZ# 1
?ZZ2 3
(ZZ4 5
DocumentTypeZZ5 A
==ZZB D 
PurchaseDocumentTypeZZE Y
.ZZY Z
NotaCreditoZZZ e
?ZZf g
-ZZh i
IgvPenZZi o
:ZZp q
IgvPenZZr x
)ZZx y
:ZZz {
$numZZ| ~
;ZZ~ 
}[[ 
public^^ 
sealed^^ 
class^^ 
LearningVideo^^ !
{^^" #
public^^$ *
Guid^^+ /
Id^^0 2
{^^3 4
get^^5 8
;^^8 9
set^^: =
;^^= >
}^^? @
=^^A B
Guid^^C G
.^^G H
NewGuid^^H O
(^^O P
)^^P Q
;^^Q R
public^^S Y
string^^Z `
Title^^a f
{^^g h
get^^i l
;^^l m
set^^n q
;^^q r
}^^s t
=^^u v
string^^w }
.^^} ~
Empty	^^~ É
;
^^É Ñ
public
^^Ö ã
string
^^å í
	YoutubeId
^^ì ú
{
^^ù û
get
^^ü ¢
;
^^¢ £
set
^^§ ß
;
^^ß ®
}
^^© ™
=
^^´ ¨
string
^^≠ ≥
.
^^≥ ¥
Empty
^^¥ π
;
^^π ∫
public
^^ª ¡
string
^^¬ »
Category
^^… —
{
^^“ ”
get
^^‘ ◊
;
^^◊ ÿ
set
^^Ÿ ‹
;
^^‹ ›
}
^^ﬁ ﬂ
=
^^‡ ·
string
^^‚ Ë
.
^^Ë È
Empty
^^È Ó
;
^^Ó Ô
public__ 
string__ 
?__ 
Language__ 
{__ 
get__ 
;__ 
set__  #
;__# $
}__% &
public__' -
string__. 4
?__4 5
Description__6 A
{__B C
get__D G
;__G H
set__I L
;__L M
}__N O
public__P V
int__W Z
	SortOrder__[ d
{__e f
get__g j
;__j k
set__l o
;__o p
}__q r
public__s y
bool__z ~
IsPublished	__ ä
{
__ã å
get
__ç ê
;
__ê ë
set
__í ï
;
__ï ñ
}
__ó ò
=
__ô ö
true
__õ ü
;
__ü †
public
__° ß
DateTime
__® ∞
	CreatedAt
__± ∫
{
__ª º
get
__Ω ¿
;
__¿ ¡
set
__¬ ≈
;
__≈ ∆
}
__« »
=
__…  
DateTime
__À ”
.
__” ‘
UtcNow
__‘ ⁄
;
__⁄ €
}
__‹ ›
publicbb 
sealedbb 
classbb 
ProductCategorybb #
{bb$ %
publicbb& ,
Guidbb- 1
Idbb2 4
{bb5 6
getbb7 :
;bb: ;
setbb< ?
;bb? @
}bbA B
=bbC D
GuidbbE I
.bbI J
NewGuidbbJ Q
(bbQ R
)bbR S
;bbS T
publicbbU [
stringbb\ b
Namebbc g
{bbh i
getbbj m
;bbm n
setbbo r
;bbr s
}bbt u
=bbv w
stringbbx ~
.bb~ 
Empty	bb Ñ
;
bbÑ Ö
public
bbÜ å
int
bbç ê
	SortOrder
bbë ö
{
bbõ ú
get
bbù †
;
bb† °
set
bb¢ •
;
bb• ¶
}
bbß ®
}
bb© ™
publicdd 
sealeddd 
classdd 
Clientdd 
{dd 
publicdd #
Guiddd$ (
Iddd) +
{dd, -
getdd. 1
;dd1 2
setdd3 6
;dd6 7
}dd8 9
=dd: ;
Guiddd< @
.dd@ A
NewGuidddA H
(ddH I
)ddI J
;ddJ K
publicddL R
stringddS Y
CompanyNameddZ e
{ddf g
getddh k
;ddk l
setddm p
;ddp q
}ddr s
=ddt u
stringddv |
.dd| }
Empty	dd} Ç
;
ddÇ É
public
ddÑ ä
string
ddã ë
ContactName
ddí ù
{
ddû ü
get
dd† £
;
dd£ §
set
dd• ®
;
dd® ©
}
dd™ ´
=
dd¨ ≠
string
ddÆ ¥
.
dd¥ µ
Empty
ddµ ∫
;
dd∫ ª
public
ddº ¬
string
dd√ …
Email
dd  œ
{
dd– —
get
dd“ ’
;
dd’ ÷
set
dd◊ ⁄
;
dd⁄ €
}
dd‹ ›
=
ddﬁ ﬂ
string
dd‡ Ê
.
ddÊ Á
Empty
ddÁ Ï
;
ddÏ Ì
public
ddÓ Ù
string
ddı ˚
?
dd˚ ¸
Phone
dd˝ Ç
{
ddÉ Ñ
get
ddÖ à
;
ddà â
set
ddä ç
;
ddç é
}
ddè ê
public
ddë ó
string
ddò û
PreferredLanguage
ddü ∞
{
dd± ≤
get
dd≥ ∂
;
dd∂ ∑
set
dd∏ ª
;
ddª º
}
ddΩ æ
=
ddø ¿
$str
dd¡ ≈
;
dd≈ ∆
public
dd« Õ
bool
ddŒ “
IsActive
dd” €
{
dd‹ ›
get
ddﬁ ·
;
dd· ‚
set
dd„ Ê
;
ddÊ Á
}
ddË È
=
ddÍ Î
true
ddÏ 
;
dd Ò
publicee 

boolee 
RequiresTaxDocumentee #
{ee$ %
getee& )
;ee) *
setee+ .
;ee. /
}ee0 1
publicee2 8
DateTimeee9 A
	CreatedAteeB K
{eeL M
geteeN Q
;eeQ R
seteeS V
;eeV W
}eeX Y
=eeZ [
DateTimeee\ d
.eed e
UtcNoweee k
;eek l
}eem n
publicff 
sealedff 
classff 
UserAccountff 
{ff  !
publicff" (
Guidff) -
Idff. 0
{ff1 2
getff3 6
;ff6 7
setff8 ;
;ff; <
}ff= >
=ff? @
GuidffA E
.ffE F
NewGuidffF M
(ffM N
)ffN O
;ffO P
publicffQ W
GuidffX \
?ff\ ]
ClientIdff^ f
{ffg h
getffi l
;ffl m
setffn q
;ffq r
}ffs t
publicffu {
string	ff| Ç
Email
ffÉ à
{
ffâ ä
get
ffã é
;
ffé è
set
ffê ì
;
ffì î
}
ffï ñ
=
ffó ò
string
ffô ü
.
ffü †
Empty
ff† •
;
ff• ¶
public
ffß ≠
string
ffÆ ¥
PasswordHash
ffµ ¡
{
ff¬ √
get
ffƒ «
;
ff« »
set
ff… Ã
;
ffÃ Õ
}
ffŒ œ
=
ff– —
string
ff“ ÿ
.
ffÿ Ÿ
Empty
ffŸ ﬁ
;
ffﬁ ﬂ
public
ff‡ Ê
string
ffÁ Ì
Name
ffÓ Ú
{
ffÛ Ù
get
ffı ¯
;
ff¯ ˘
set
ff˙ ˝
;
ff˝ ˛
}
ffˇ Ä
=
ffÅ Ç
string
ffÉ â
.
ffâ ä
Empty
ffä è
;
ffè ê
public
ffë ó
UserRole
ffò †
Role
ff° •
{
ff¶ ß
get
ff® ´
;
ff´ ¨
set
ff≠ ∞
;
ff∞ ±
}
ff≤ ≥
=
ff¥ µ
UserRole
ff∂ æ
.
ffæ ø
Cliente
ffø ∆
;
ff∆ «
public
ff» Œ
bool
ffœ ”
IsActive
ff‘ ‹
{
ff› ﬁ
get
ffﬂ ‚
;
ff‚ „
set
ff‰ Á
;
ffÁ Ë
}
ffÈ Í
=
ffÎ Ï
true
ffÌ Ò
;
ffÒ Ú
publicgg 

DateTimegg 
?gg 
NotificationsSeenAtgg (
{gg) *
getgg+ .
;gg. /
setgg0 3
;gg3 4
}gg5 6
}gg7 8
publicii 
sealedii 
classii 
Projectii 
{ii 
publicii $
Guidii% )
Idii* ,
{ii- .
getii/ 2
;ii2 3
setii4 7
;ii7 8
}ii9 :
=ii; <
Guidii= A
.iiA B
NewGuidiiB I
(iiI J
)iiJ K
;iiK L
publiciiM S
GuidiiT X
ClientIdiiY a
{iib c
getiid g
;iig h
setiii l
;iil m
}iin o
publiciip v
stringiiw }
Name	ii~ Ç
{
iiÉ Ñ
get
iiÖ à
;
iià â
set
iiä ç
;
iiç é
}
iiè ê
=
iië í
string
iiì ô
.
iiô ö
Empty
iiö ü
;
iiü †
public
ii° ß
string
ii® Æ
Slug
iiØ ≥
{
ii¥ µ
get
ii∂ π
;
iiπ ∫
set
iiª æ
;
iiæ ø
}
ii¿ ¡
=
ii¬ √
string
iiƒ  
.
ii  À
Empty
iiÀ –
;
ii– —
public
ii“ ÿ
List
iiŸ ›
<
ii› ﬁ
ProjectRepository
iiﬁ Ô
>
iiÔ 
Repositories
iiÒ ˝
{
ii˛ ˇ
get
iiÄ É
;
iiÉ Ñ
set
iiÖ à
;
iià â
}
iiä ã
=
iiå ç
[
iié è
]
iiè ê
;
iiê ë
}
iií ì
publickk 
sealedkk 
classkk 
ProjectRepositorykk %
{kk& '
publickk( .
Guidkk/ 3
Idkk4 6
{kk7 8
getkk9 <
;kk< =
setkk> A
;kkA B
}kkC D
=kkE F
GuidkkG K
.kkK L
NewGuidkkL S
(kkS T
)kkT U
;kkU V
publickkW ]
Guidkk^ b
	ProjectIdkkc l
{kkm n
getkko r
;kkr s
setkkt w
;kkw x
}kky z
public	kk{ Å
string
kkÇ à
Owner
kkâ é
{
kkè ê
get
kkë î
;
kkî ï
set
kkñ ô
;
kkô ö
}
kkõ ú
=
kkù û
string
kkü •
.
kk• ¶
Empty
kk¶ ´
;
kk´ ¨
public
kk≠ ≥
string
kk¥ ∫
Name
kkª ø
{
kk¿ ¡
get
kk¬ ≈
;
kk≈ ∆
set
kk«  
;
kk  À
}
kkÃ Õ
=
kkŒ œ
string
kk– ÷
.
kk÷ ◊
Empty
kk◊ ‹
;
kk‹ ›
public
kkﬁ ‰
string
kkÂ Î
?
kkÎ Ï
Label
kkÌ Ú
{
kkÛ Ù
get
kkı ¯
;
kk¯ ˘
set
kk˙ ˝
;
kk˝ ˛
}
kkˇ Ä
public
kkÅ á
bool
kkà å
	IsDefault
kkç ñ
{
kkó ò
get
kkô ú
;
kkú ù
set
kkû °
;
kk° ¢
}
kk£ §
}
kk• ¶
publicll 
staticll 
classll 
ProjectExtensionsll %
{mm 
publicoo 

staticoo 
ProjectRepositoryoo #
?oo# $
RepositoryForoo% 2
(oo2 3
thisoo3 7
IReadOnlyCollectionoo8 K
<ooK L
ProjectRepositoryooL ]
>oo] ^
repositoriesoo_ k
,ook l
Guidoom q
?ooq r
repositoryIdoos 
)	oo Ä
=>
ooÅ É
repositoryIdpp 
ispp 
Guidpp 
idpp 
?pp  !
repositoriespp" .
.pp. /
FirstOrDefaultpp/ =
(pp= >
xpp> ?
=>pp@ B
xppC D
.ppD E
IdppE G
==ppH J
idppK M
)ppM N
:ppO P
repositoriesppQ ]
.pp] ^
OrderByDescendingpp^ o
(ppo p
xppp q
=>ppr t
xppu v
.ppv w
	IsDefault	ppw Ä
)
ppÄ Å
.
ppÅ Ç
FirstOrDefault
ppÇ ê
(
ppê ë
)
ppë í
;
ppí ì
}qq 
publicrr 
sealedrr 
classrr 
Productrr 
{rr 
publicrr $
Guidrr% )
Idrr* ,
{rr- .
getrr/ 2
;rr2 3
setrr4 7
;rr7 8
}rr9 :
=rr; <
Guidrr= A
.rrA B
NewGuidrrB I
(rrI J
)rrJ K
;rrK L
publicrrM S
ProductTyperrT _
Typerr` d
{rre f
getrrg j
;rrj k
setrrl o
;rro p
}rrq r
publicrrs y
string	rrz Ä
Name
rrÅ Ö
{
rrÜ á
get
rrà ã
;
rrã å
set
rrç ê
;
rrê ë
}
rrí ì
=
rrî ï
string
rrñ ú
.
rrú ù
Empty
rrù ¢
;
rr¢ £
public
rr§ ™
BillingCycle
rr´ ∑
BillingCycle
rr∏ ƒ
{
rr≈ ∆
get
rr«  
;
rr  À
set
rrÃ œ
;
rrœ –
}
rr— “
public
rr” Ÿ
decimal
rr⁄ ·
?
rr· ‚
	BasePrice
rr„ Ï
{
rrÌ Ó
get
rrÔ Ú
;
rrÚ Û
set
rrÙ ˜
;
rr˜ ¯
}
rr˘ ˙
public
rr˚ Å
string
rrÇ à
Currency
rrâ ë
{
rrí ì
get
rrî ó
;
rró ò
set
rrô ú
;
rrú ù
}
rrû ü
=
rr† °
$str
rr¢ ß
;
rrß ®
public
rr© Ø
string
rr∞ ∂
?
rr∂ ∑
Description
rr∏ √
{
rrƒ ≈
get
rr∆ …
;
rr…  
set
rrÀ Œ
;
rrŒ œ
}
rr– —
public
rr“ ÿ
bool
rrŸ ›
IsActive
rrﬁ Ê
{
rrÁ Ë
get
rrÈ Ï
;
rrÏ Ì
set
rrÓ Ò
;
rrÒ Ú
}
rrÛ Ù
=
rrı ˆ
true
rr˜ ˚
;
rr˚ ¸
public
rr˝ É
string
rrÑ ä
?
rrä ã
PayPalPlanId
rrå ò
{
rrô ö
get
rrõ û
;
rrû ü
set
rr† £
;
rr£ §
}
rr• ¶
public
rrß ≠
decimal
rrÆ µ
?
rrµ ∂
PayPalPlanPrice
rr∑ ∆
{
rr« »
get
rr… Ã
;
rrÃ Õ
set
rrŒ —
;
rr— “
}
rr” ‘
public
rr’ €
TaxDocumentType
rr‹ Î
TaxDocumentType
rrÏ ˚
{
rr¸ ˝
get
rr˛ Å
;
rrÅ Ç
set
rrÉ Ü
;
rrÜ á
}
rrà â
=
rrä ã
TaxDocumentType
rrå õ
.
rrõ ú
Factura
rrú £
;
rr£ §
publictt 

stringtt 
?tt 
Categorytt 
{tt 
gettt !
;tt! "
settt# &
;tt& '
}tt( )
publicvv 

stringvv 
?vv 
Tagsvv 
{vv 
getvv 
;vv 
setvv "
;vv" #
}vv$ %
publicxx 

boolxx 
AllowsTicketsxx 
{xx 
getxx  #
;xx# $
setxx% (
;xx( )
}xx* +
}xx, -
publicyy 
sealedyy 
classyy 
ClientProductyy !
{yy" #
publicyy$ *
Guidyy+ /
Idyy0 2
{yy3 4
getyy5 8
;yy8 9
setyy: =
;yy= >
}yy? @
=yyA B
GuidyyC G
.yyG H
NewGuidyyH O
(yyO P
)yyP Q
;yyQ R
publicyyS Y
GuidyyZ ^
ClientIdyy_ g
{yyh i
getyyj m
;yym n
setyyo r
;yyr s
}yyt u
publicyyv |
Guid	yy} Å
	ProjectId
yyÇ ã
{
yyå ç
get
yyé ë
;
yyë í
set
yyì ñ
;
yyñ ó
}
yyò ô
public
yyö †
Guid
yy° •
	ProductId
yy¶ Ø
{
yy∞ ±
get
yy≤ µ
;
yyµ ∂
set
yy∑ ∫
;
yy∫ ª
}
yyº Ω
public
yyæ ƒ!
ClientProductStatus
yy≈ ÿ
Status
yyŸ ﬂ
{
yy‡ ·
get
yy‚ Â
;
yyÂ Ê
set
yyÁ Í
;
yyÍ Î
}
yyÏ Ì
public
yyÓ Ù
BillingCycle
yyı Å
BillingCycle
yyÇ é
{
yyè ê
get
yyë î
;
yyî ï
set
yyñ ô
;
yyô ö
}
yyõ ú
public
yyù £
bool
yy§ ®
IsManualBilling
yy© ∏
{
yyπ ∫
get
yyª æ
;
yyæ ø
set
yy¿ √
;
yy√ ƒ
}
yy≈ ∆
public
yy« Õ
DateTime
yyŒ ÷
?
yy÷ ◊
RenewsAt
yyÿ ‡
{
yy· ‚
get
yy„ Ê
;
yyÊ Á
set
yyË Î
;
yyÎ Ï
}
yyÌ Ó
public
yyÔ ı
DateTime
yyˆ ˛
?
yy˛ ˇ
NextChargeAt
yyÄ å
{
yyç é
get
yyè í
;
yyí ì
set
yyî ó
;
yyó ò
}
yyô ö
public
yyõ °
DateTime
yy¢ ™
?
yy™ ´
LastBackupAt
yy¨ ∏
{
yyπ ∫
get
yyª æ
;
yyæ ø
set
yy¿ √
;
yy√ ƒ
}
yy≈ ∆
public
yy« Õ
decimal
yyŒ ’
?
yy’ ÷
Price
yy◊ ‹
{
yy› ﬁ
get
yyﬂ ‚
;
yy‚ „
set
yy‰ Á
;
yyÁ Ë
}
yyÈ Í
public
yyÎ Ò
string
yyÚ ¯
?
yy¯ ˘ 
PriceLabelOverride
yy˙ å
{
yyç é
get
yyè í
;
yyí ì
set
yyî ó
;
yyó ò
}
yyô ö
public
yyõ °
string
yy¢ ®
?
yy® ©
PayPalOrderId
yy™ ∑
{
yy∏ π
get
yy∫ Ω
;
yyΩ æ
set
yyø ¬
;
yy¬ √
}
yyƒ ≈
public
yy∆ Ã
string
yyÕ ”
?
yy” ‘"
PayPalSubscriptionId
yy’ È
{
yyÍ Î
get
yyÏ Ô
;
yyÔ 
set
yyÒ Ù
;
yyÙ ı
}
yyˆ ˜
public
yy¯ ˛
string
yyˇ Ö
?
yyÖ Ü
PayPalPlanId
yyá ì
{
yyî ï
get
yyñ ô
;
yyô ö
set
yyõ û
;
yyû ü
}
yy† °
public
yy¢ ®
string
yy© Ø
?
yyØ ∞

DomainName
yy± ª
{
yyº Ω
get
yyæ ¡
;
yy¡ ¬
set
yy√ ∆
;
yy∆ «
}
yy» …
publiczz 

decimalzz 
?zz 
Discountzz 
{zz 
getzz "
;zz" #
setzz$ '
;zz' (
}zz) *
publiczz+ 1
DateTimezz2 :
?zz: ;
DiscountEndsAtzz< J
{zzK L
getzzM P
;zzP Q
setzzR U
;zzU V
}zzW X
publiczzY _
Productzz` g
?zzg h
Productzzi p
{zzq r
getzzs v
;zzv w
setzzx {
;zz{ |
}zz} ~
public	zz Ö
Project
zzÜ ç
?
zzç é
Project
zzè ñ
{
zzó ò
get
zzô ú
;
zzú ù
set
zzû °
;
zz° ¢
}
zz£ §
public|| 

int|| 
?|| 
PayPalOrderYears||  
{||! "
get||# &
;||& '
set||( +
;||+ ,
}||- .
public~~ 

decimal~~ 
?~~ 
AppliedIgvRate~~ "
{~~# $
get~~% (
;~~( )
set~~* -
;~~- .
}~~/ 0
public
ÄÄ 
#
TransferReportSummary
ÄÄ  
?
ÄÄ  !
TransferReport
ÄÄ" 0
{
ÄÄ1 2
get
ÄÄ3 6
;
ÄÄ6 7
set
ÄÄ8 ;
;
ÄÄ; <
}
ÄÄ= >
}
ÄÄ? @
publicÅÅ 
sealed
ÅÅ 
class
ÅÅ 
Ticket
ÅÅ 
{
ÅÅ 
public
ÅÅ #
Guid
ÅÅ$ (
Id
ÅÅ) +
{
ÅÅ, -
get
ÅÅ. 1
;
ÅÅ1 2
set
ÅÅ3 6
;
ÅÅ6 7
}
ÅÅ8 9
=
ÅÅ: ;
Guid
ÅÅ< @
.
ÅÅ@ A
NewGuid
ÅÅA H
(
ÅÅH I
)
ÅÅI J
;
ÅÅJ K
public
ÅÅL R
string
ÅÅS Y
Code
ÅÅZ ^
{
ÅÅ_ `
get
ÅÅa d
;
ÅÅd e
set
ÅÅf i
;
ÅÅi j
}
ÅÅk l
=
ÅÅm n
string
ÅÅo u
.
ÅÅu v
Empty
ÅÅv {
;
ÅÅ{ |
publicÅÅ} É
GuidÅÅÑ à
ClientIdÅÅâ ë
{ÅÅí ì
getÅÅî ó
;ÅÅó ò
setÅÅô ú
;ÅÅú ù
}ÅÅû ü
publicÅÅ† ¶
GuidÅÅß ´
	ProjectIdÅÅ¨ µ
{ÅÅ∂ ∑
getÅÅ∏ ª
;ÅÅª º
setÅÅΩ ¿
;ÅÅ¿ ¡
}ÅÅ¬ √
publicÅÅƒ  
GuidÅÅÀ œ
CreatedByUserIdÅÅ– ﬂ
{ÅÅ‡ ·
getÅÅ‚ Â
;ÅÅÂ Ê
setÅÅÁ Í
;ÅÅÍ Î
}ÅÅÏ Ì
publicÅÅÓ Ù

TicketTypeÅÅı ˇ
TypeÅÅÄ Ñ
{ÅÅÖ Ü
getÅÅá ä
;ÅÅä ã
setÅÅå è
;ÅÅè ê
}ÅÅë í
publicÅÅì ô
TicketStatusÅÅö ¶
StatusÅÅß ≠
{ÅÅÆ Ø
getÅÅ∞ ≥
;ÅÅ≥ ¥
setÅÅµ ∏
;ÅÅ∏ π
}ÅÅ∫ ª
=ÅÅº Ω
TicketStatusÅÅæ  
.ÅÅ  À
AbiertoÅÅÀ “
;ÅÅ“ ”
publicÅÅ‘ ⁄
stringÅÅ€ ·
TitleÅÅ‚ Á
{ÅÅË È
getÅÅÍ Ì
;ÅÅÌ Ó
setÅÅÔ Ú
;ÅÅÚ Û
}ÅÅÙ ı
=ÅÅˆ ˜
stringÅÅ¯ ˛
.ÅÅ˛ ˇ
EmptyÅÅˇ Ñ
;ÅÅÑ Ö
publicÅÅÜ å
stringÅÅç ì
DescriptionÅÅî ü
{ÅÅ† °
getÅÅ¢ •
;ÅÅ• ¶
setÅÅß ™
;ÅÅ™ ´
}ÅÅ¨ ≠
=ÅÅÆ Ø
stringÅÅ∞ ∂
.ÅÅ∂ ∑
EmptyÅÅ∑ º
;ÅÅº Ω
publicÅÅæ ƒ
stringÅÅ≈ À
?ÅÅÀ Ã
CurrentBehaviorÅÅÕ ‹
{ÅÅ› ﬁ
getÅÅﬂ ‚
;ÅÅ‚ „
setÅÅ‰ Á
;ÅÅÁ Ë
}ÅÅÈ Í
publicÅÅÎ Ò
stringÅÅÚ ¯
?ÅÅ¯ ˘ 
ExpectedBehaviorÅÅ˙ ä
{ÅÅã å
getÅÅç ê
;ÅÅê ë
setÅÅí ï
;ÅÅï ñ
}ÅÅó ò
publicÅÅô ü
stringÅÅ† ¶
?ÅÅ¶ ß 
StepsToReproduceÅÅ® ∏
{ÅÅπ ∫
getÅÅª æ
;ÅÅæ ø
setÅÅ¿ √
;ÅÅ√ ƒ
}ÅÅ≈ ∆
publicÅÅ« Õ
stringÅÅŒ ‘
?ÅÅ‘ ’
EnvironmentÅÅ÷ ·
{ÅÅ‚ „
getÅÅ‰ Á
;ÅÅÁ Ë
setÅÅÈ Ï
;ÅÅÏ Ì
}ÅÅÓ Ô
publicÅÅ ˆ
stringÅÅ˜ ˝
?ÅÅ˝ ˛"
AcceptanceCriteriaÅÅˇ ë
{ÅÅí ì
getÅÅî ó
;ÅÅó ò
setÅÅô ú
;ÅÅú ù
}ÅÅû ü
publicÅÅ† ¶
stringÅÅß ≠
?ÅÅ≠ Æ
EstimatedImpactÅÅØ æ
{ÅÅø ¿
getÅÅ¡ ƒ
;ÅÅƒ ≈
setÅÅ∆ …
;ÅÅ…  
}ÅÅÀ Ã
public
ÇÇ 

Guid
ÇÇ 
?
ÇÇ 
RepositoryId
ÇÇ 
{
ÇÇ 
get
ÇÇ  #
;
ÇÇ# $
set
ÇÇ% (
;
ÇÇ( )
}
ÇÇ* +
public
ÉÉ 

Guid
ÉÉ 
?
ÉÉ 
ClientProductId
ÉÉ  
{
ÉÉ! "
get
ÉÉ# &
;
ÉÉ& '
set
ÉÉ( +
;
ÉÉ+ ,
}
ÉÉ- .
public
ÉÉ/ 5
int
ÉÉ6 9
?
ÉÉ9 :
GithubIssueNumber
ÉÉ; L
{
ÉÉM N
get
ÉÉO R
;
ÉÉR S
set
ÉÉT W
;
ÉÉW X
}
ÉÉY Z
public
ÉÉ[ a
string
ÉÉb h
?
ÉÉh i
GithubIssueUrl
ÉÉj x
{
ÉÉy z
get
ÉÉ{ ~
;
ÉÉ~ 
setÉÉÄ É
;ÉÉÉ Ñ
}ÉÉÖ Ü
public
ÑÑ 
string
ÑÑ 
?
ÑÑ !
GithubProjectStatus
ÑÑ #
{
ÑÑ$ %
get
ÑÑ& )
;
ÑÑ) *
set
ÑÑ+ .
;
ÑÑ. /
}
ÑÑ0 1
public
ÑÑ2 8
DateTime
ÑÑ9 A
	CreatedAt
ÑÑB K
{
ÑÑL M
get
ÑÑN Q
;
ÑÑQ R
set
ÑÑS V
;
ÑÑV W
}
ÑÑX Y
=
ÑÑZ [
DateTime
ÑÑ\ d
.
ÑÑd e
UtcNow
ÑÑe k
;
ÑÑk l
public
ÑÑm s
DateTime
ÑÑt |
	UpdatedAtÑÑ} Ü
{ÑÑá à
getÑÑâ å
;ÑÑå ç
setÑÑé ë
;ÑÑë í
}ÑÑì î
=ÑÑï ñ
DateTimeÑÑó ü
.ÑÑü †
UtcNowÑÑ† ¶
;ÑÑ¶ ß
}ÑÑ® ©
publicÜÜ 
sealed
ÜÜ 
class
ÜÜ 
TicketAttachment
ÜÜ $
{
ÜÜ% &
public
ÜÜ' -
Guid
ÜÜ. 2
Id
ÜÜ3 5
{
ÜÜ6 7
get
ÜÜ8 ;
;
ÜÜ; <
set
ÜÜ= @
;
ÜÜ@ A
}
ÜÜB C
=
ÜÜD E
Guid
ÜÜF J
.
ÜÜJ K
NewGuid
ÜÜK R
(
ÜÜR S
)
ÜÜS T
;
ÜÜT U
public
ÜÜV \
Guid
ÜÜ] a
TicketId
ÜÜb j
{
ÜÜk l
get
ÜÜm p
;
ÜÜp q
set
ÜÜr u
;
ÜÜu v
}
ÜÜw x
public
ÜÜy 
stringÜÜÄ Ü
FileNameÜÜá è
{ÜÜê ë
getÜÜí ï
;ÜÜï ñ
setÜÜó ö
;ÜÜö õ
}ÜÜú ù
=ÜÜû ü
stringÜÜ† ¶
.ÜÜ¶ ß
EmptyÜÜß ¨
;ÜÜ¨ ≠
publicÜÜÆ ¥
stringÜÜµ ª
UrlÜÜº ø
{ÜÜ¿ ¡
getÜÜ¬ ≈
;ÜÜ≈ ∆
setÜÜ«  
;ÜÜ  À
}ÜÜÃ Õ
=ÜÜŒ œ
stringÜÜ– ÷
.ÜÜ÷ ◊
EmptyÜÜ◊ ‹
;ÜÜ‹ ›
publicÜÜﬁ ‰
longÜÜÂ È
	SizeBytesÜÜÍ Û
{ÜÜÙ ı
getÜÜˆ ˘
;ÜÜ˘ ˙
setÜÜ˚ ˛
;ÜÜ˛ ˇ
}ÜÜÄ Å
publicÜÜÇ à
stringÜÜâ è
ContentTypeÜÜê õ
{ÜÜú ù
getÜÜû °
;ÜÜ° ¢
setÜÜ£ ¶
;ÜÜ¶ ß
}ÜÜ® ©
=ÜÜ™ ´
$strÜÜ¨ ∆
;ÜÜ∆ «
publicÜÜ» Œ
byteÜÜœ ”
[ÜÜ” ‘
]ÜÜ‘ ’
ContentÜÜ÷ ›
{ÜÜﬁ ﬂ
getÜÜ‡ „
;ÜÜ„ ‰
setÜÜÂ Ë
;ÜÜË È
}ÜÜÍ Î
=ÜÜÏ Ì
[ÜÜÓ Ô
]ÜÜÔ 
;ÜÜ Ò
publicÜÜÚ ¯
DateTimeÜÜ˘ Å
	CreatedAtÜÜÇ ã
{ÜÜå ç
getÜÜé ë
;ÜÜë í
setÜÜì ñ
;ÜÜñ ó
}ÜÜò ô
=ÜÜö õ
DateTimeÜÜú §
.ÜÜ§ •
UtcNowÜÜ• ´
;ÜÜ´ ¨
publicÜÜ≠ ≥
boolÜÜ¥ ∏
IsImageÜÜπ ¿
=>ÜÜ¡ √
ContentTypeÜÜƒ œ
.ÜÜœ –

StartsWithÜÜ– ⁄
(ÜÜ⁄ €
$strÜÜ€ „
,ÜÜ„ ‰ 
StringComparisonÜÜÂ ı
.ÜÜı ˆ!
OrdinalIgnoreCaseÜÜˆ á
)ÜÜá à
;ÜÜà â
}ÜÜä ã
publicáá 
sealed
áá 
class
áá 
TicketComment
áá !
{
áá" #
public
áá$ *
Guid
áá+ /
Id
áá0 2
{
áá3 4
get
áá5 8
;
áá8 9
set
áá: =
;
áá= >
}
áá? @
=
ááA B
Guid
ááC G
.
ááG H
NewGuid
ááH O
(
ááO P
)
ááP Q
;
ááQ R
public
ááS Y
Guid
ááZ ^
TicketId
áá_ g
{
ááh i
get
ááj m
;
áám n
set
ááo r
;
áár s
}
áát u
public
ááv |
Guidáá} Å
?ááÅ Ç
AuthorUserIdááÉ è
{ááê ë
getááí ï
;ááï ñ
setááó ö
;ááö õ
}ááú ù
publicááû §
stringáá• ´
Bodyáá¨ ∞
{áá± ≤
getáá≥ ∂
;áá∂ ∑
setáá∏ ª
;ááª º
}ááΩ æ
=ááø ¿
stringáá¡ «
.áá« »
Emptyáá» Õ
;ááÕ Œ
publicááœ ’
booláá÷ ⁄

FromGithubáá€ Â
{ááÊ Á
getááË Î
;ááÎ Ï
setááÌ 
;áá Ò
}ááÚ Û
publicááÙ ˙
longáá˚ ˇ
?ááˇ Ä
GithubCommentIdááÅ ê
{ááë í
getááì ñ
;ááñ ó
setááò õ
;ááõ ú
}ááù û
publicááü •
stringáá¶ ¨
?áá¨ ≠!
GithubAuthorLoginááÆ ø
{áá¿ ¡
getáá¬ ≈
;áá≈ ∆
setáá«  
;áá  À
}ááÃ Õ
publicááŒ ‘
DateTimeáá’ ›
	CreatedAtááﬁ Á
{ááË È
getááÍ Ì
;ááÌ Ó
setááÔ Ú
;ááÚ Û
}ááÙ ı
=ááˆ ˜
DateTimeáá¯ Ä
.ááÄ Å
UtcNowááÅ á
;ááá à
}ááâ ä
publicââ 
sealed
ââ 
class
ââ  
PaymentTransaction
ââ &
{
ââ' (
public
ââ) /
Guid
ââ0 4
Id
ââ5 7
{
ââ8 9
get
ââ: =
;
ââ= >
set
ââ? B
;
ââB C
}
ââD E
=
ââF G
Guid
ââH L
.
ââL M
NewGuid
ââM T
(
ââT U
)
ââU V
;
ââV W
public
ââX ^
Guid
ââ_ c
ClientId
ââd l
{
ââm n
get
ââo r
;
ââr s
set
âât w
;
ââw x
}
âây z
public
ää 

Guid
ää 
?
ää 
ClientProductId
ää  
{
ää! "
get
ää# &
;
ää& '
set
ää( +
;
ää+ ,
}
ää- .
public
ää/ 5
string
ää6 <+
PayPalOrderIdOrSubscriptionId
ää= Z
{
ää[ \
get
ää] `
;
ää` a
set
ääb e
;
ääe f
}
ääg h
=
ääi j
string
ääk q
.
ääq r
Empty
äär w
;
ääw x
public
ääy 
decimalääÄ á
Amountääà é
{ääè ê
getääë î
;ääî ï
setääñ ô
;ääô ö
}ääõ ú
publicääù £
stringää§ ™
Currencyää´ ≥
{ää¥ µ
getää∂ π
;ääπ ∫
setääª æ
;ääæ ø
}ää¿ ¡
=ää¬ √
$strääƒ …
;ää…  
publicääÀ —
stringää“ ÿ
StatusääŸ ﬂ
{ää‡ ·
getää‚ Â
;ääÂ Ê
setääÁ Í
;ääÍ Î
}ääÏ Ì
=ääÓ Ô
stringää ˆ
.ääˆ ˜
Emptyää˜ ¸
;ää¸ ˝
public
ãã 

string
ãã 
Method
ãã 
{
ãã 
get
ãã 
;
ãã 
set
ãã  #
;
ãã# $
}
ãã% &
=
ãã' (
PaymentMethods
ãã) 7
.
ãã7 8
PayPal
ãã8 >
;
ãã> ?
public
åå 

int
åå 
Years
åå 
{
åå 
get
åå 
;
åå 
set
åå 
;
åå  
}
åå! "
=
åå# $
$num
åå% &
;
åå& '
public
åå( .
decimal
åå/ 6
	AmountPen
åå7 @
{
ååA B
get
ååC F
;
ååF G
set
ååH K
;
ååK L
}
ååM N
public
ååO U
string
ååV \
?
åå\ ]
InternalCode
åå^ j
{
ååk l
get
ååm p
;
ååp q
set
åår u
;
ååu v
}
ååw x
public
ååy 
DateTimeååÄ à
	CreatedAtååâ í
{ååì î
getååï ò
;ååò ô
setååö ù
;ååù û
}ååü †
=åå° ¢
DateTimeåå£ ´
.åå´ ¨
UtcNowåå¨ ≤
;åå≤ ≥
publicåå¥ ∫
stringååª ¡
?åå¡ ¬
Notesåå√ »
{åå…  
getååÀ Œ
;ååŒ œ
setåå– ”
;åå” ‘
}åå’ ÷
}åå◊ ÿ
publicçç 
sealed
çç 
class
çç 
NotificationLog
çç #
{
çç$ %
public
çç& ,
Guid
çç- 1
Id
çç2 4
{
çç5 6
get
çç7 :
;
çç: ;
set
çç< ?
;
çç? @
}
ççA B
=
ççC D
Guid
ççE I
.
ççI J
NewGuid
ççJ Q
(
ççQ R
)
ççR S
;
ççS T
public
ççU [
Guid
çç\ `
ClientId
çça i
{
ççj k
get
ççl o
;
çço p
set
ççq t
;
ççt u
}
ççv w
public
ççx ~
stringçç Ö
TypeççÜ ä
{ççã å
getççç ê
;ççê ë
setççí ï
;ççï ñ
}ççó ò
=ççô ö
stringççõ °
.çç° ¢
Emptyçç¢ ß
;ççß ®
publicçç© Ø
stringçç∞ ∂
Channelçç∑ æ
{ççø ¿
getçç¡ ƒ
;ççƒ ≈
setçç∆ …
;çç…  
}ççÀ Ã
=ççÕ Œ
stringççœ ’
.çç’ ÷
Emptyçç÷ €
;çç€ ‹
publicçç› „
DateTimeçç‰ Ï
SentAtççÌ Û
{ççÙ ı
getççˆ ˘
;çç˘ ˙
setçç˚ ˛
;çç˛ ˇ
}ççÄ Å
=ççÇ É
DateTimeççÑ å
.ççå ç
UtcNowççç ì
;ççì î
publicççï õ
boolççú †
Successçç° ®
{çç© ™
getçç´ Æ
;ççÆ Ø
setçç∞ ≥
;çç≥ ¥
}ççµ ∂
publicçç∑ Ω
stringççæ ƒ
?ççƒ ≈
	Recipientçç∆ œ
{çç– —
getçç“ ’
;çç’ ÷
setçç◊ ⁄
;çç⁄ €
}çç‹ ›
publicççﬁ ‰
stringççÂ Î
?ççÎ Ï
	DedupeKeyççÌ ˆ
{çç˜ ¯
getçç˘ ¸
;çç¸ ˝
setçç˛ Å
;ççÅ Ç
}ççÉ Ñ
publicççÖ ã
stringççå í
?ççí ì
Errorççî ô
{ççö õ
getççú ü
;ççü †
setçç° §
;çç§ •
}çç¶ ß
}çç® ©
publicêê 
sealed
êê 
class
êê 
ExchangeRate
êê  
{
êê! "
public
êê# )
Guid
êê* .
Id
êê/ 1
{
êê2 3
get
êê4 7
;
êê7 8
set
êê9 <
;
êê< =
}
êê> ?
=
êê@ A
Guid
êêB F
.
êêF G
NewGuid
êêG N
(
êêN O
)
êêO P
;
êêP Q
public
êêR X
DateOnly
êêY a
Date
êêb f
{
êêg h
get
êêi l
;
êêl m
set
êên q
;
êêq r
}
êês t
public
êêu {
stringêê| Ç
CurrencyCodeêêÉ è
{êêê ë
getêêí ï
;êêï ñ
setêêó ö
;êêö õ
}êêú ù
=êêû ü
stringêê† ¶
.êê¶ ß
Emptyêêß ¨
;êê¨ ≠
publicêêÆ ¥
decimalêêµ º
	RateToPenêêΩ ∆
{êê« »
getêê… Ã
;êêÃ Õ
setêêŒ —
;êê— “
}êê” ‘
publicêê’ €
stringêê‹ ‚
Sourceêê„ È
{êêÍ Î
getêêÏ Ô
;êêÔ 
setêêÒ Ù
;êêÙ ı
}êêˆ ˜
=êê¯ ˘
stringêê˙ Ä
.êêÄ Å
EmptyêêÅ Ü
;êêÜ á
}êêà â
publicìì 
sealed
ìì 
class
ìì 
TaxDocument
ìì 
{
ìì  !
public
ìì" (
Guid
ìì) -
Id
ìì. 0
{
ìì1 2
get
ìì3 6
;
ìì6 7
set
ìì8 ;
;
ìì; <
}
ìì= >
=
ìì? @
Guid
ììA E
.
ììE F
NewGuid
ììF M
(
ììM N
)
ììN O
;
ììO P
public
ììQ W
Guid
ììX \
?
ìì\ ]"
PaymentTransactionId
ìì^ r
{
ììs t
get
ììu x
;
ììx y
set
ììz }
;
ìì} ~
}ìì Ä
publicììÅ á
Guidììà å
ClientIdììç ï
{ììñ ó
getììò õ
;ììõ ú
setììù †
;ìì† °
}ìì¢ £
publicìì§ ™
TaxDocumentTypeìì´ ∫
Typeììª ø
{ìì¿ ¡
getìì¬ ≈
;ìì≈ ∆
setìì«  
;ìì  À
}ììÃ Õ
publicììŒ ‘
stringìì’ €
Seriesìì‹ ‚
{ìì„ ‰
getììÂ Ë
;ììË È
setììÍ Ì
;ììÌ Ó
}ììÔ 
=ììÒ Ú
stringììÛ ˘
.ìì˘ ˙
Emptyìì˙ ˇ
;ììˇ Ä
publicììÅ á
intììà ã
Numberììå í
{ììì î
getììï ò
;ììò ô
setììö ù
;ììù û
}ììü †
publicìì° ß
DateOnlyìì® ∞
	IssueDateìì± ∫
{ììª º
getììΩ ¿
;ìì¿ ¡
setìì¬ ≈
;ìì≈ ∆
}ìì« »
publicìì… œ
stringìì– ÷
Currencyìì◊ ﬂ
{ìì‡ ·
getìì‚ Â
;ììÂ Ê
setììÁ Í
;ììÍ Î
}ììÏ Ì
=ììÓ Ô
$strìì ı
;ììı ˆ
publicìì˜ ˝
decimalìì˛ Ö

BaseAmountììÜ ê
{ììë í
getììì ñ
;ììñ ó
setììò õ
;ììõ ú
}ììù û
publicììü •
decimalìì¶ ≠
	IgvAmountììÆ ∑
{ìì∏ π
getìì∫ Ω
;ììΩ æ
setììø ¬
;ìì¬ √
}ììƒ ≈
publicìì∆ Ã
decimalììÕ ‘
TotalAmountìì’ ‡
{ìì· ‚
getìì„ Ê
;ììÊ Á
setììË Î
;ììÎ Ï
}ììÌ Ó
publicììÔ ı
stringììˆ ¸
?ìì¸ ˝
Notesìì˛ É
{ììÑ Ö
getììÜ â
;ììâ ä
setììã é
;ììé è
}ììê ë
public
îî 

decimal
îî 
?
îî 
RetentionAmount
îî #
{
îî$ %
get
îî& )
;
îî) *
set
îî+ .
;
îî. /
}
îî0 1
}
îî2 3
publicöö 
sealed
öö 
class
öö 
PaymentReversal
öö #
{
öö$ %
public
öö& ,
Guid
öö- 1
Id
öö2 4
{
öö5 6
get
öö7 :
;
öö: ;
set
öö< ?
;
öö? @
}
ööA B
=
ööC D
Guid
ööE I
.
ööI J
NewGuid
ööJ Q
(
ööQ R
)
ööR S
;
ööS T
public
ööU [
Guid
öö\ `
ClientId
ööa i
{
ööj k
get
ööl o
;
ööo p
set
ööq t
;
ööt u
}
ööv w
public
ööx ~
Guidöö É
?ööÉ Ñ
ClientProductIdööÖ î
{ööï ñ
getööó ö
;ööö õ
setööú ü
;ööü †
}öö° ¢
public
õõ 

string
õõ 
?
õõ 

PaymentKey
õõ 
{
õõ 
get
õõ  #
;
õõ# $
set
õõ% (
;
õõ( )
}
õõ* +
public
õõ, 2
string
õõ3 9
?
õõ9 :
Method
õõ; A
{
õõB C
get
õõD G
;
õõG H
set
õõI L
;
õõL M
}
õõN O
public
õõP V
string
õõW ]
?
õõ] ^
InternalCode
õõ_ k
{
õõl m
get
õõn q
;
õõq r
set
õõs v
;
õõv w
}
õõx y
publicõõz Ä
decimalõõÅ à
Amountõõâ è
{õõê ë
getõõí ï
;õõï ñ
setõõó ö
;õõö õ
}õõú ù
publicõõû §
stringõõ• ´
Currencyõõ¨ ¥
{õõµ ∂
getõõ∑ ∫
;õõ∫ ª
setõõº ø
;õõø ¿
}õõ¡ ¬
=õõ√ ƒ
$strõõ≈  
;õõ  À
publicõõÃ “
decimalõõ” ⁄
?õõ⁄ €
	AmountPenõõ‹ Â
{õõÊ Á
getõõË Î
;õõÎ Ï
setõõÌ 
;õõ Ò
}õõÚ Û
publicõõÙ ˙
DateTimeõõ˚ É
?õõÉ Ñ
PaidAtõõÖ ã
{õõå ç
getõõé ë
;õõë í
setõõì ñ
;õõñ ó
}õõò ô
public
úú 

TaxDocumentType
úú 
DocumentType
úú '
{
úú( )
get
úú* -
;
úú- .
set
úú/ 2
;
úú2 3
}
úú4 5
public
úú6 <
string
úú= C
Series
úúD J
{
úúK L
get
úúM P
;
úúP Q
set
úúR U
;
úúU V
}
úúW X
=
úúY Z
string
úú[ a
.
úúa b
Empty
úúb g
;
úúg h
public
úúi o
int
úúp s
Number
úút z
{
úú{ |
getúú} Ä
;úúÄ Å
setúúÇ Ö
;úúÖ Ü
}úúá à
publicúúâ è
DateOnlyúúê ò
	IssueDateúúô ¢
{úú£ §
getúú• ®
;úú® ©
setúú™ ≠
;úú≠ Æ
}úúØ ∞
public
ùù 

string
ùù 
Reason
ùù 
{
ùù 
get
ùù 
;
ùù 
set
ùù  #
;
ùù# $
}
ùù% &
=
ùù' (
string
ùù) /
.
ùù/ 0
Empty
ùù0 5
;
ùù5 6
public
ûû 

bool
ûû 
	NotIssued
ûû 
{
ûû 
get
ûû 
;
ûû  
set
ûû! $
;
ûû$ %
}
ûû& '
public
ûû( .
bool
ûû/ 3
NumberReleased
ûû4 B
{
ûûC D
get
ûûE H
;
ûûH I
set
ûûJ M
;
ûûM N
}
ûûO P
public
ûûQ W
Guid
ûûX \
?
ûû\ ]
ReversedByUserId
ûû^ n
{
ûûo p
get
ûûq t
;
ûût u
set
ûûv y
;
ûûy z
}
ûû{ |
publicûû} É
DateTimeûûÑ å

ReversedAtûûç ó
{ûûò ô
getûûö ù
;ûûù û
setûûü ¢
;ûû¢ £
}ûû§ •
=ûû¶ ß
DateTimeûû® ∞
.ûû∞ ±
UtcNowûû± ∑
;ûû∑ ∏
}ûûπ ∫
public°° 
sealed
°° 
class
°° 
TaxDocumentLine
°° #
{
°°$ %
public
°°& ,
Guid
°°- 1
Id
°°2 4
{
°°5 6
get
°°7 :
;
°°: ;
set
°°< ?
;
°°? @
}
°°A B
=
°°C D
Guid
°°E I
.
°°I J
NewGuid
°°J Q
(
°°Q R
)
°°R S
;
°°S T
public
°°U [
Guid
°°\ `
TaxDocumentId
°°a n
{
°°o p
get
°°q t
;
°°t u
set
°°v y
;
°°y z
}
°°{ |
public°°} É
Guid°°Ñ à
?°°à â
ClientProductId°°ä ô
{°°ö õ
get°°ú ü
;°°ü †
set°°° §
;°°§ •
}°°¶ ß
public°°® Æ
string°°Ø µ
Description°°∂ ¡
{°°¬ √
get°°ƒ «
;°°« »
set°°… Ã
;°°Ã Õ
}°°Œ œ
=°°– —
string°°“ ÿ
.°°ÿ Ÿ
Empty°°Ÿ ﬁ
;°°ﬁ ﬂ
public°°‡ Ê
decimal°°Á Ó
Amount°°Ô ı
{°°ˆ ˜
get°°¯ ˚
;°°˚ ¸
set°°˝ Ä
;°°Ä Å
}°°Ç É
public°°Ñ ä
int°°ã é
Order°°è î
{°°ï ñ
get°°ó ö
;°°ö õ
set°°ú ü
;°°ü †
}°°° ¢
}°°£ §
public££ 
sealed
££ 
class
££ 
Expense
££ 
{
££ 
public
££ $
Guid
££% )
Id
££* ,
{
££- .
get
££/ 2
;
££2 3
set
££4 7
;
££7 8
}
££9 :
=
££; <
Guid
££= A
.
££A B
NewGuid
££B I
(
££I J
)
££J K
;
££K L
public
££M S
string
££T Z
Description
££[ f
{
££g h
get
££i l
;
££l m
set
££n q
;
££q r
}
££s t
=
££u v
string
££w }
.
££} ~
Empty££~ É
;££É Ñ
public££Ö ã
Guid££å ê

CategoryId££ë õ
{££ú ù
get££û °
;££° ¢
set£££ ¶
;££¶ ß
}££® ©
public££™ ∞
ExpenseCategory££± ¿
?££¿ ¡
Category££¬  
{££À Ã
get££Õ –
;££– —
set££“ ’
;££’ ÷
}££◊ ÿ
public££Ÿ ﬂ
ExpenseType££‡ Î
Type££Ï 
{££Ò Ú
get££Û ˆ
;££ˆ ˜
set££¯ ˚
;££˚ ¸
}££˝ ˛
public££ˇ Ö
decimal££Ü ç
Amount££é î
{££ï ñ
get££ó ö
;££ö õ
set££ú ü
;££ü †
}££° ¢
public£££ ©
string££™ ∞
Currency££± π
{££∫ ª
get££º ø
;££ø ¿
set££¡ ƒ
;££ƒ ≈
}££∆ «
=££» …
$str££  œ
;££œ –
public££— ◊
decimal££ÿ ﬂ
	AmountPen££‡ È
{££Í Î
get££Ï Ô
;££Ô 
set££Ò Ù
;££Ù ı
}££ˆ ˜
public££¯ ˛
DateOnly££ˇ á
Date££à å
{££ç é
get££è í
;££í ì
set££î ó
;££ó ò
}££ô ö
public££õ °
bool££¢ ¶
	Recurring££ß ∞
{££± ≤
get££≥ ∂
;££∂ ∑
set££∏ ª
;££ª º
}££Ω æ
public££ø ≈
BillingCycle££∆ “
?££“ ”
RecurrenceCycle££‘ „
{££‰ Â
get££Ê È
;££È Í
set££Î Ó
;££Ó Ô
}££ Ò
public
§§ 
DateOnly
§§ 
?
§§ 
RecurrenceEndsAt
§§ "
{
§§# $
get
§§% (
;
§§( )
set
§§* -
;
§§- .
}
§§/ 0
public
¶¶ 

bool
¶¶ 
IsNonDeductible
¶¶ 
{
¶¶  !
get
¶¶" %
;
¶¶% &
set
¶¶' *
;
¶¶* +
}
¶¶, -
public
®® 

bool
®® #
IsNonDomiciledService
®® %
{
®®& '
get
®®( +
;
®®+ ,
set
®®- 0
;
®®0 1
}
®®2 3
public
®®4 :
string
®®; A
?
®®A B!
ForeignSupplierName
®®C V
{
®®W X
get
®®Y \
;
®®\ ]
set
®®^ a
;
®®a b
}
®®c d
public
®®e k
string
®®l r
?
®®r s%
ForeignSupplierCountry®®t ä
{®®ã å
get®®ç ê
;®®ê ë
set®®í ï
;®®ï ñ
}®®ó ò
public
™™ 

DateOnly
™™ 
?
™™ 
Form1662PaidAt
™™ #
{
™™$ %
get
™™& )
;
™™) *
set
™™+ .
;
™™. /
}
™™0 1
public
™™2 8
string
™™9 ?
?
™™? @
Form1662Number
™™A O
{
™™P Q
get
™™R U
;
™™U V
set
™™W Z
;
™™Z [
}
™™\ ]
}
™™^ _
public≠≠ 
sealed
≠≠ 
class
≠≠ 
TaxSettings
≠≠ 
{ÆÆ 
public
ØØ 

Guid
ØØ 
Id
ØØ 
{
ØØ 
get
ØØ 
;
ØØ 
set
ØØ 
;
ØØ 
}
ØØ  
=
ØØ! "
Guid
ØØ# '
.
ØØ' (
NewGuid
ØØ( /
(
ØØ/ 0
)
ØØ0 1
;
ØØ1 2
public
ØØ3 9
decimal
ØØ: A
IgvRate
ØØB I
{
ØØJ K
get
ØØL O
;
ØØO P
set
ØØQ T
;
ØØT U
}
ØØV W
=
ØØX Y
$num
ØØZ _
;
ØØ_ `
public
ØØa g
decimal
ØØh o
	RentaRate
ØØp y
{
ØØz {
get
ØØ| 
;ØØ Ä
setØØÅ Ñ
;ØØÑ Ö
}ØØÜ á
=ØØà â
$numØØä è
;ØØè ê
publicØØë ó
DateTimeØØò †
	UpdatedAtØØ° ™
{ØØ´ ¨
getØØ≠ ∞
;ØØ∞ ±
setØØ≤ µ
;ØØµ ∂
}ØØ∑ ∏
=ØØπ ∫
DateTimeØØª √
.ØØ√ ƒ
UtcNowØØƒ  
;ØØ  À
public
≤≤ 

string
≤≤ 
FacturaSeries
≤≤ 
{
≤≤  !
get
≤≤" %
;
≤≤% &
set
≤≤' *
;
≤≤* +
}
≤≤, -
=
≤≤. /
$str
≤≤0 6
;
≤≤6 7
public
≤≤8 >
int
≤≤? B
FacturaNextNumber
≤≤C T
{
≤≤U V
get
≤≤W Z
;
≤≤Z [
set
≤≤\ _
;
≤≤_ `
}
≤≤a b
=
≤≤c d
$num
≤≤e f
;
≤≤f g
public
≥≥ 

string
≥≥ 
ReciboSeries
≥≥ 
{
≥≥  
get
≥≥! $
;
≥≥$ %
set
≥≥& )
;
≥≥) *
}
≥≥+ ,
=
≥≥- .
$str
≥≥/ 5
;
≥≥5 6
public
≥≥7 =
int
≥≥> A
ReciboNextNumber
≥≥B R
{
≥≥S T
get
≥≥U X
;
≥≥X Y
set
≥≥Z ]
;
≥≥] ^
}
≥≥_ `
=
≥≥a b
$num
≥≥c d
;
≥≥d e
public
µµ 

string
µµ 
?
µµ 
Ruc
µµ 
{
µµ 
get
µµ 
;
µµ 
set
µµ !
;
µµ! "
}
µµ# $
public
µµ% +
bool
µµ, 0
IsGoodTaxpayer
µµ1 ?
{
µµ@ A
get
µµB E
;
µµE F
set
µµG J
;
µµJ K
}
µµL M
public
∑∑ 

bool
∑∑ 
Use1662AsCredit
∑∑ 
{
∑∑  !
get
∑∑" %
;
∑∑% &
set
∑∑' *
;
∑∑* +
}
∑∑, -
}∏∏ 
publicææ 
sealed
ææ 
class
ææ 
AnnualTaxSettings
ææ %
{øø 
public
¿¿ 

Guid
¿¿ 
Id
¿¿ 
{
¿¿ 
get
¿¿ 
;
¿¿ 
set
¿¿ 
;
¿¿ 
}
¿¿  
=
¿¿! "
Guid
¿¿# '
.
¿¿' (
NewGuid
¿¿( /
(
¿¿/ 0
)
¿¿0 1
;
¿¿1 2
public
¿¿3 9
int
¿¿: =
Year
¿¿> B
{
¿¿C D
get
¿¿E H
;
¿¿H I
set
¿¿J M
;
¿¿M N
}
¿¿O P
public
¿¿Q W
decimal
¿¿X _
Uit
¿¿` c
{
¿¿d e
get
¿¿f i
;
¿¿i j
set
¿¿k n
;
¿¿n o
}
¿¿p q
public
¡¡ 

decimal
¡¡ 
ThresholdUits
¡¡  
{
¡¡! "
get
¡¡# &
;
¡¡& '
set
¡¡( +
;
¡¡+ ,
}
¡¡- .
=
¡¡/ 0
$num
¡¡1 4
;
¡¡4 5
public
¡¡6 <
decimal
¡¡= D
LowRate
¡¡E L
{
¡¡M N
get
¡¡O R
;
¡¡R S
set
¡¡T W
;
¡¡W X
}
¡¡Y Z
=
¡¡[ \
$num
¡¡] b
;
¡¡b c
public
¡¡d j
decimal
¡¡k r
HighRate
¡¡s {
{
¡¡| }
get¡¡~ Å
;¡¡Å Ç
set¡¡É Ü
;¡¡Ü á
}¡¡à â
=¡¡ä ã
$num¡¡å í
;¡¡í ì
}¬¬ 
public…… 
sealed
…… 
class
…… 

TaxDueDate
…… 
{   
public
ÀÀ 

Guid
ÀÀ 
Id
ÀÀ 
{
ÀÀ 
get
ÀÀ 
;
ÀÀ 
set
ÀÀ 
;
ÀÀ 
}
ÀÀ  
=
ÀÀ! "
Guid
ÀÀ# '
.
ÀÀ' (
NewGuid
ÀÀ( /
(
ÀÀ/ 0
)
ÀÀ0 1
;
ÀÀ1 2
public
ÕÕ 

DateOnly
ÕÕ 
Period
ÕÕ 
{
ÕÕ 
get
ÕÕ  
;
ÕÕ  !
set
ÕÕ" %
;
ÕÕ% &
}
ÕÕ' (
public
ŒŒ 

DateOnly
ŒŒ 
Digit0
ŒŒ 
{
ŒŒ 
get
ŒŒ  
;
ŒŒ  !
set
ŒŒ" %
;
ŒŒ% &
}
ŒŒ' (
public
ŒŒ) /
DateOnly
ŒŒ0 8
Digit1
ŒŒ9 ?
{
ŒŒ@ A
get
ŒŒB E
;
ŒŒE F
set
ŒŒG J
;
ŒŒJ K
}
ŒŒL M
public
ŒŒN T
DateOnly
ŒŒU ]

Digit2And3
ŒŒ^ h
{
ŒŒi j
get
ŒŒk n
;
ŒŒn o
set
ŒŒp s
;
ŒŒs t
}
ŒŒu v
public
ŒŒw }
DateOnlyŒŒ~ Ü

Digit4And5ŒŒá ë
{ŒŒí ì
getŒŒî ó
;ŒŒó ò
setŒŒô ú
;ŒŒú ù
}ŒŒû ü
publicŒŒ† ¶
DateOnlyŒŒß Ø

Digit6And7ŒŒ∞ ∫
{ŒŒª º
getŒŒΩ ¿
;ŒŒ¿ ¡
setŒŒ¬ ≈
;ŒŒ≈ ∆
}ŒŒ« »
publicŒŒ… œ
DateOnlyŒŒ– ÿ

Digit8And9ŒŒŸ „
{ŒŒ‰ Â
getŒŒÊ È
;ŒŒÈ Í
setŒŒÎ Ó
;ŒŒÓ Ô
}ŒŒ Ò
public
–– 

DateOnly
–– 
GoodTaxpayer
––  
{
––! "
get
––# &
;
––& '
set
––( +
;
––+ ,
}
––- .
public
—— 

DateTime
—— 
?
—— 
FiledAt
—— 
{
—— 
get
—— "
;
——" #
set
——$ '
;
——' (
}
——) *
public
”” 

decimal
”” 
?
”” 
IgvPaid
”” 
{
”” 
get
”” !
;
””! "
set
””# &
;
””& '
}
””( )
public
””* 0
decimal
””1 8
?
””8 9
	RentaPaid
””: C
{
””D E
get
””F I
;
””I J
set
””K N
;
””N O
}
””P Q
public
÷÷ 

DateOnly
÷÷ 
?
÷÷ 
DueFor
÷÷ 
(
÷÷ 
string
÷÷ "
?
÷÷" #
ruc
÷÷$ '
,
÷÷' (
bool
÷÷) -
goodTaxpayer
÷÷. :
)
÷÷: ;
{
◊◊ 
if
ÿÿ 

(
ÿÿ 
goodTaxpayer
ÿÿ 
)
ÿÿ 
return
ÿÿ  
GoodTaxpayer
ÿÿ! -
;
ÿÿ- .
if
ŸŸ 

(
ŸŸ 
string
ŸŸ 
.
ŸŸ  
IsNullOrWhiteSpace
ŸŸ %
(
ŸŸ% &
ruc
ŸŸ& )
)
ŸŸ) *
||
ŸŸ+ -
!
ŸŸ. /
char
ŸŸ/ 3
.
ŸŸ3 4
IsAsciiDigit
ŸŸ4 @
(
ŸŸ@ A
ruc
ŸŸA D
.
ŸŸD E
Trim
ŸŸE I
(
ŸŸI J
)
ŸŸJ K
[
ŸŸK L
^
ŸŸL M
$num
ŸŸM N
]
ŸŸN O
)
ŸŸO P
)
ŸŸP Q
return
ŸŸR X
null
ŸŸY ]
;
ŸŸ] ^
return
⁄⁄ 
(
⁄⁄ 
ruc
⁄⁄ 
.
⁄⁄ 
Trim
⁄⁄ 
(
⁄⁄ 
)
⁄⁄ 
[
⁄⁄ 
^
⁄⁄ 
$num
⁄⁄ 
]
⁄⁄ 
-
⁄⁄  
$char
⁄⁄! $
)
⁄⁄$ %
switch
⁄⁄& ,
{
⁄⁄- .
$num
⁄⁄/ 0
=>
⁄⁄1 3
Digit0
⁄⁄4 :
,
⁄⁄: ;
$num
⁄⁄< =
=>
⁄⁄> @
Digit1
⁄⁄A G
,
⁄⁄G H
$num
⁄⁄I J
or
⁄⁄K M
$num
⁄⁄N O
=>
⁄⁄P R

Digit2And3
⁄⁄S ]
,
⁄⁄] ^
$num
⁄⁄_ `
or
⁄⁄a c
$num
⁄⁄d e
=>
⁄⁄f h

Digit4And5
⁄⁄i s
,
⁄⁄s t
$num
⁄⁄u v
or
⁄⁄w y
$num
⁄⁄z {
=>
⁄⁄| ~

Digit6And7⁄⁄ â
,⁄⁄â ä
_⁄⁄ã å
=>⁄⁄ç è

Digit8And9⁄⁄ê ö
}⁄⁄õ ú
;⁄⁄ú ù
}
€€ 
}‹‹ 
public‚‚ 
static
‚‚ 
class
‚‚ 
TaxDueDateSeed
‚‚ "
{„„ 
public
‰‰ 

static
‰‰ 

TaxDueDate
‰‰ 
[
‰‰ 
]
‰‰ 
Rows2026
‰‰ '
=>
‰‰( *
Rows
‰‰+ /
(
‰‰/ 0
$num
‰‰0 4
,
‰‰4 5
[
ÂÂ 
(
ÊÊ 	
$str
ÊÊ	 
,
ÊÊ 
$str
ÊÊ #
,
ÊÊ# $
$str
ÊÊ% 1
,
ÊÊ1 2
$str
ÊÊ3 ?
,
ÊÊ? @
$str
ÊÊA M
,
ÊÊM N
$str
ÊÊO [
,
ÊÊ[ \
$str
ÊÊ] i
)
ÊÊi j
,
ÊÊj k
(
ÁÁ 	
$str
ÁÁ	 
,
ÁÁ 
$str
ÁÁ #
,
ÁÁ# $
$str
ÁÁ% 1
,
ÁÁ1 2
$str
ÁÁ3 ?
,
ÁÁ? @
$str
ÁÁA M
,
ÁÁM N
$str
ÁÁO [
,
ÁÁ[ \
$str
ÁÁ] i
)
ÁÁi j
,
ÁÁj k
(
ËË 	
$str
ËË	 
,
ËË 
$str
ËË #
,
ËË# $
$str
ËË% 1
,
ËË1 2
$str
ËË3 ?
,
ËË? @
$str
ËËA M
,
ËËM N
$str
ËËO [
,
ËË[ \
$str
ËË] i
)
ËËi j
,
ËËj k
(
ÈÈ 	
$str
ÈÈ	 
,
ÈÈ 
$str
ÈÈ #
,
ÈÈ# $
$str
ÈÈ% 1
,
ÈÈ1 2
$str
ÈÈ3 ?
,
ÈÈ? @
$str
ÈÈA M
,
ÈÈM N
$str
ÈÈO [
,
ÈÈ[ \
$str
ÈÈ] i
)
ÈÈi j
,
ÈÈj k
(
ÍÍ 	
$str
ÍÍ	 
,
ÍÍ 
$str
ÍÍ #
,
ÍÍ# $
$str
ÍÍ% 1
,
ÍÍ1 2
$str
ÍÍ3 ?
,
ÍÍ? @
$str
ÍÍA M
,
ÍÍM N
$str
ÍÍO [
,
ÍÍ[ \
$str
ÍÍ] i
)
ÍÍi j
,
ÍÍj k
(
ÎÎ 	
$str
ÎÎ	 
,
ÎÎ 
$str
ÎÎ #
,
ÎÎ# $
$str
ÎÎ% 1
,
ÎÎ1 2
$str
ÎÎ3 ?
,
ÎÎ? @
$str
ÎÎA M
,
ÎÎM N
$str
ÎÎO [
,
ÎÎ[ \
$str
ÎÎ] i
)
ÎÎi j
,
ÎÎj k
(
ÏÏ 	
$str
ÏÏ	 
,
ÏÏ 
$str
ÏÏ #
,
ÏÏ# $
$str
ÏÏ% 1
,
ÏÏ1 2
$str
ÏÏ3 ?
,
ÏÏ? @
$str
ÏÏA M
,
ÏÏM N
$str
ÏÏO [
,
ÏÏ[ \
$str
ÏÏ] i
)
ÏÏi j
,
ÏÏj k
(
ÌÌ 	
$str
ÌÌ	 
,
ÌÌ 
$str
ÌÌ #
,
ÌÌ# $
$str
ÌÌ% 1
,
ÌÌ1 2
$str
ÌÌ3 ?
,
ÌÌ? @
$str
ÌÌA M
,
ÌÌM N
$str
ÌÌO [
,
ÌÌ[ \
$str
ÌÌ] i
)
ÌÌi j
,
ÌÌj k
(
ÓÓ 	
$str
ÓÓ	 
,
ÓÓ 
$str
ÓÓ #
,
ÓÓ# $
$str
ÓÓ% 1
,
ÓÓ1 2
$str
ÓÓ3 ?
,
ÓÓ? @
$str
ÓÓA M
,
ÓÓM N
$str
ÓÓO [
,
ÓÓ[ \
$str
ÓÓ] i
)
ÓÓi j
,
ÓÓj k
(
ÔÔ 	
$str
ÔÔ	 
,
ÔÔ 
$str
ÔÔ #
,
ÔÔ# $
$str
ÔÔ% 1
,
ÔÔ1 2
$str
ÔÔ3 ?
,
ÔÔ? @
$str
ÔÔA M
,
ÔÔM N
$str
ÔÔO [
,
ÔÔ[ \
$str
ÔÔ] i
)
ÔÔi j
,
ÔÔj k
(
 	
$str
	 
,
 
$str
 #
,
# $
$str
% 1
,
1 2
$str
3 ?
,
? @
$str
A M
,
M N
$str
O [
,
[ \
$str
] i
)
i j
,
j k
(
ÒÒ 	
$str
ÒÒ	 
,
ÒÒ 
$str
ÒÒ #
,
ÒÒ# $
$str
ÒÒ% 1
,
ÒÒ1 2
$str
ÒÒ3 ?
,
ÒÒ? @
$str
ÒÒA M
,
ÒÒM N
$str
ÒÒO [
,
ÒÒ[ \
$str
ÒÒ] i
)
ÒÒi j
,
ÒÒj k
]
ÚÚ 
)
ÚÚ 
;
ÚÚ 
private
ÙÙ 
static
ÙÙ 

TaxDueDate
ÙÙ 
[
ÙÙ 
]
ÙÙ 
Rows
ÙÙ  $
(
ÙÙ$ %
int
ÙÙ% (
year
ÙÙ) -
,
ÙÙ- .
(
ÙÙ/ 0
string
ÙÙ0 6
,
ÙÙ6 7
string
ÙÙ8 >
,
ÙÙ> ?
string
ÙÙ@ F
,
ÙÙF G
string
ÙÙH N
,
ÙÙN O
string
ÙÙP V
,
ÙÙV W
string
ÙÙX ^
,
ÙÙ^ _
string
ÙÙ` f
)
ÙÙf g
[
ÙÙg h
]
ÙÙh i
months
ÙÙj p
)
ÙÙp q
=>
ÙÙr t
months
ÙÙu {
.
ÙÙ{ |
SelectÙÙ| Ç
(ÙÙÇ É
(ÙÙÉ Ñ
mÙÙÑ Ö
,ÙÙÖ Ü
iÙÙá à
)ÙÙà â
=>ÙÙä å
newÙÙç ê

TaxDueDateÙÙë õ
{
ıı 
Id
˜˜ 

=
˜˜ 
new
˜˜ 
Guid
˜˜ 
(
˜˜ 
$"
˜˜ 
$str
˜˜ 0
{
˜˜0 1
year
˜˜1 5
:
˜˜5 6
$str
˜˜6 8
}
˜˜8 9
{
˜˜9 :
i
˜˜: ;
+
˜˜< =
$num
˜˜> ?
:
˜˜? @
$str
˜˜@ B
}
˜˜B C
"
˜˜C D
)
˜˜D E
,
˜˜E F
Period
˜˜G M
=
˜˜N O
new
˜˜P S
DateOnly
˜˜T \
(
˜˜\ ]
year
˜˜] a
,
˜˜a b
i
˜˜c d
+
˜˜e f
$num
˜˜g h
,
˜˜h i
$num
˜˜j k
)
˜˜k l
,
˜˜l m
Digit0
¯¯ 
=
¯¯ 
DateOnly
¯¯ 
.
¯¯ 
Parse
¯¯ 
(
¯¯  
m
¯¯  !
.
¯¯! "
Item1
¯¯" '
)
¯¯' (
,
¯¯( )
Digit1
¯¯* 0
=
¯¯1 2
DateOnly
¯¯3 ;
.
¯¯; <
Parse
¯¯< A
(
¯¯A B
m
¯¯B C
.
¯¯C D
Item2
¯¯D I
)
¯¯I J
,
¯¯J K

Digit2And3
¯¯L V
=
¯¯W X
DateOnly
¯¯Y a
.
¯¯a b
Parse
¯¯b g
(
¯¯g h
m
¯¯h i
.
¯¯i j
Item3
¯¯j o
)
¯¯o p
,
¯¯p q

Digit4And5
¯¯r |
=
¯¯} ~
DateOnly¯¯ á
.¯¯á à
Parse¯¯à ç
(¯¯ç é
m¯¯é è
.¯¯è ê
Item4¯¯ê ï
)¯¯ï ñ
,¯¯ñ ó

Digit6And7
˘˘ 
=
˘˘ 
DateOnly
˘˘ 
.
˘˘ 
Parse
˘˘ #
(
˘˘# $
m
˘˘$ %
.
˘˘% &
Item5
˘˘& +
)
˘˘+ ,
,
˘˘, -

Digit8And9
˘˘. 8
=
˘˘9 :
DateOnly
˘˘; C
.
˘˘C D
Parse
˘˘D I
(
˘˘I J
m
˘˘J K
.
˘˘K L
Item6
˘˘L Q
)
˘˘Q R
,
˘˘R S
GoodTaxpayer
˘˘T `
=
˘˘a b
DateOnly
˘˘c k
.
˘˘k l
Parse
˘˘l q
(
˘˘q r
m
˘˘r s
.
˘˘s t
Item7
˘˘t y
)
˘˘y z
,
˘˘z {
}
˙˙ 
)
˙˙ 
.
˙˙ 
ToArray
˙˙ 
(
˙˙ 
)
˙˙ 
;
˙˙ 
}˚˚ 
publicÅÅ 
sealed
ÅÅ 
class
ÅÅ  
PortalNotification
ÅÅ &
{
ÅÅ' (
public
ÅÅ) /
Guid
ÅÅ0 4
Id
ÅÅ5 7
{
ÅÅ8 9
get
ÅÅ: =
;
ÅÅ= >
set
ÅÅ? B
;
ÅÅB C
}
ÅÅD E
=
ÅÅF G
Guid
ÅÅH L
.
ÅÅL M
NewGuid
ÅÅM T
(
ÅÅT U
)
ÅÅU V
;
ÅÅV W
public
ÅÅX ^
Guid
ÅÅ_ c
ClientId
ÅÅd l
{
ÅÅm n
get
ÅÅo r
;
ÅÅr s
set
ÅÅt w
;
ÅÅw x
}
ÅÅy z
publicÅÅ{ Å
stringÅÅÇ à
TypeÅÅâ ç
{ÅÅé è
getÅÅê ì
;ÅÅì î
setÅÅï ò
;ÅÅò ô
}ÅÅö õ
=ÅÅú ù
stringÅÅû §
.ÅÅ§ •
EmptyÅÅ• ™
;ÅÅ™ ´
publicÅÅ¨ ≤
boolÅÅ≥ ∑
ForStaffÅÅ∏ ¿
{ÅÅ¡ ¬
getÅÅ√ ∆
;ÅÅ∆ «
setÅÅ» À
;ÅÅÀ Ã
}ÅÅÕ Œ
publicÅÅœ ’
stringÅÅ÷ ‹
DataJsonÅÅ› Â
{ÅÅÊ Á
getÅÅË Î
;ÅÅÎ Ï
setÅÅÌ 
;ÅÅ Ò
}ÅÅÚ Û
=ÅÅÙ ı
$strÅÅˆ ˙
;ÅÅ˙ ˚
publicÅÅ¸ Ç
stringÅÅÉ â
?ÅÅâ ä
	DedupeKeyÅÅã î
{ÅÅï ñ
getÅÅó ö
;ÅÅö õ
setÅÅú ü
;ÅÅü †
}ÅÅ° ¢
publicÅÅ£ ©
DateTimeÅÅ™ ≤
	CreatedAtÅÅ≥ º
{ÅÅΩ æ
getÅÅø ¬
;ÅÅ¬ √
setÅÅƒ «
;ÅÅ« »
}ÅÅ…  
=ÅÅÀ Ã
DateTimeÅÅÕ ’
.ÅÅ’ ÷
UtcNowÅÅ÷ ‹
;ÅÅ‹ ›
}ÅÅﬁ ﬂﬂ\
9C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Contracts.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
record 
WordPressPage 
( 
string "
Locale# )
,) *
string+ 1
Slug2 6
,6 7
string8 >
Title? D
,D E
stringF L
HtmlM Q
,Q R
DateTimeOffsetS a
	UpdatedAtb k
)k l
;l m
public 
record 
WordPressProject 
( 
string %
Name& *
,* +
string, 2
Category3 ;
,; <
string= C
?C D
PhotoUrlE M
)M N
;N O
public 
record 
WordPressReview 
( 
string $
Author% +
,+ ,
string- 3
Quote4 9
)9 :
;: ;
public 
record 
WordPressBlogPost 
(  
string  &
Slug' +
,+ ,
string- 3
Title4 9
,9 :
string; A
ExcerptB I
,I J
stringK Q
HtmlR V
,V W
stringX ^
?^ _
Tag` c
,c d
DateTimeOffsete s
PublishedAtt 
,	 Ä
DateTimeOffset
Å è
	UpdatedAt
ê ô
,
ô ö
int
õ û
ReadingMinutes
ü ≠
,
≠ Æ
string
Ø µ
?
µ ∂
CoverUrl
∑ ø
,
ø ¿
string
¡ «
?
« »
CoverAlt
… —
)
— “
;
“ ”
public 
record 
PayPalCheckout 
( 
string #
Id$ &
,& '
string( .
ApprovalUrl/ :
): ;
;; <
public

 
record

 
PayPalCapture

 
(

 
string

 "
OrderId

# *
,

* +
string

, 2
Status

3 9
,

9 :
decimal

; B
?

B C
Amount

D J
,

J K
string

L R
?

R S
Currency

T \
)

\ ]
;

] ^
public 
record %
PayPalSubscriptionPayment '
(' (
string( .
Id/ 1
,1 2
decimal3 :
Amount; A
,A B
stringC I
CurrencyJ R
)R S
;S T
public 
record "
PayPalSubscriptionInfo $
($ %
string% +
Id, .
,. /
string0 6
Status7 =
,= >
DateTime? G
?G H
NextBillingTimeI X
,X Y
IReadOnlyListZ g
<g h&
PayPalSubscriptionPayment	h Å
>
Å Ç
Payments
É ã
)
ã å
;
å ç
public 
record 
GitHubIssue 
( 
int 
Number $
,$ %
string& ,
Url- 0
)0 1
;1 2
public 
record 
GitHubIssueState 
( 
bool #
Closed$ *
,* +
string, 2
?2 3
ProjectStatus4 A
)A B
;B C
public 
record 
ExchangeRateQuote 
(  
DateOnly  (
Date) -
,- .
decimal/ 6
	RateToPen7 @
,@ A
stringB H
SourceI O
)O P
;P Q
public 
	interface #
IWordPressContentClient (
{ 
Task 
< 	
WordPressPage	 
? 
> 
GetPageAsync %
(% &
string& ,
locale- 3
,3 4
string5 ;
slug< @
,@ A
CancellationTokenB S
cancellationTokenT e
=f g
defaulth o
)o p
;p q
Task 
< 	
IReadOnlyList	 
< 
WordPressProject '
>' (
>( )
GetProjectsAsync* :
(: ;
string; A
localeB H
,H I
CancellationTokenJ [
cancellationToken\ m
=n o
defaultp w
)w x
;x y
Task 
< 	
IReadOnlyList	 
< 
WordPressReview &
>& '
>' (
GetReviewsAsync) 8
(8 9
string9 ?
locale@ F
,F G
CancellationTokenH Y
cancellationTokenZ k
=l m
defaultn u
)u v
;v w
Task 
< 	
IReadOnlyList	 
< 
WordPressBlogPost (
>( )
>) *
GetBlogPostsAsync+ <
(< =
string= C
localeD J
,J K
CancellationTokenL ]
cancellationToken^ o
=p q
defaultr y
)y z
;z {
Task 
< 	
string	 
? 
>  
GetHeroPhotoUrlAsync &
(& '
CancellationToken' 8
cancellationToken9 J
=K L
defaultM T
)T U
;U V
} 
public 
	interface 
IPayPalClient 
{ 
Task 
< 	
PayPalCheckout	 
> 
CreateOrderAsync )
() *
decimal* 1
amount2 8
,8 9
string: @
currencyA I
,I J
stringK Q
customIdR Z
,Z [
string\ b
	returnUrlc l
,l m
stringn t
	cancelUrlu ~
,~ 
CancellationToken
Ä ë
cancellationToken
í £
=
§ •
default
¶ ≠
)
≠ Æ
;
Æ Ø
Task   
<   	
PayPalCheckout  	 
>   #
CreateSubscriptionAsync   0
(  0 1
string  1 7
planId  8 >
,  > ?
string  @ F
customId  G O
,  O P
string  Q W
	returnUrl  X a
,  a b
string  c i
	cancelUrl  j s
,  s t
CancellationToken	  u Ü
cancellationToken
  á ò
=
  ô ö
default
  õ ¢
)
  ¢ £
;
  £ §
Task!! 
<!! 	
PayPalCapture!!	 
>!! 
CaptureOrderAsync!! )
(!!) *
string!!* 0
orderId!!1 8
,!!8 9
CancellationToken!!: K
cancellationToken!!L ]
=!!^ _
default!!` g
)!!g h
;!!h i
Task%% 
<%% 	
string%%	 
>%% 
CreatePlanAsync%%  
(%%  !
string%%! '
name%%( ,
,%%, -
decimal%%. 5
price%%6 ;
,%%; <
string%%= C
currency%%D L
,%%L M
int%%N Q
intervalMonths%%R `
,%%` a
decimal%%b i
?%%i j
firstCyclePrice%%k z
=%%{ |
null	%%} Å
,
%%Å Ç
CancellationToken
%%É î
cancellationToken
%%ï ¶
=
%%ß ®
default
%%© ∞
)
%%∞ ±
;
%%± ≤
Task&& 
<&& 	"
PayPalSubscriptionInfo&&	 
>&&   
GetSubscriptionAsync&&! 5
(&&5 6
string&&6 <
subscriptionId&&= K
,&&K L
CancellationToken&&M ^
cancellationToken&&_ p
=&&q r
default&&s z
)&&z {
;&&{ |
Task'' #
CancelSubscriptionAsync''	  
(''  !
string''! '
subscriptionId''( 6
,''6 7
string''8 >
reason''? E
,''E F
CancellationToken''G X
cancellationToken''Y j
=''k l
default''m t
)''t u
;''u v
Task(( 
<(( 	
bool((	 
>(( 
VerifyWebhookAsync(( !
(((! "
string((" (
payload(() 0
,((0 1
IReadOnlyDictionary((2 E
<((E F
string((F L
,((L M
string((N T
>((T U
headers((V ]
,((] ^
CancellationToken((_ p
cancellationToken	((q Ç
=
((É Ñ
default
((Ö å
)
((å ç
;
((ç é
})) 
public++ 
	interface++ 
IGitHubIssuesClient++ $
{,, 
Task-- 
<-- 	
GitHubIssue--	 
>-- 
CreateIssueAsync-- &
(--& '
Project--' .
project--/ 6
,--6 7
ProjectRepository--8 I

repository--J T
,--T U
Ticket--V \
ticket--] c
,--c d
IReadOnlyList--e r
<--r s
TicketAttachment	--s É
>
--É Ñ
attachments
--Ö ê
,
--ê ë
CancellationToken
--í £
cancellationToken
--§ µ
=
--∂ ∑
default
--∏ ø
)
--ø ¿
;
--¿ ¡
Task00 
<00 	
IReadOnlyDictionary00	 
<00 
int00  
,00  !
GitHubIssueState00" 2
>002 3
>003 4
GetIssueStatesAsync005 H
(00H I
ProjectRepository00I Z

repository00[ e
,00e f
IReadOnlyCollection00g z
<00z {
int00{ ~
>00~ 
issueNumbers
00Ä å
,
00å ç
CancellationToken
00é ü
cancellationToken
00† ±
=
00≤ ≥
default
00¥ ª
)
00ª º
;
00º Ω
Task11 
<11 	
string11	 
>11 
UploadFileAsync11  
(11  !
ProjectRepository11! 2

repository113 =
,11= >
string11? E
path11F J
,11J K
byte11L P
[11P Q
]11Q R
content11S Z
,11Z [
string11\ b
message11c j
,11j k
CancellationToken11l }
cancellationToken	11~ è
=
11ê ë
default
11í ô
)
11ô ö
;
11ö õ
Task22 
<22 	
long22	 
>22 
CreateCommentAsync22 !
(22! "
ProjectRepository22" 3

repository224 >
,22> ?
int22@ C
issueNumber22D O
,22O P
string22Q W
body22X \
,22\ ]
CancellationToken22^ o
cancellationToken	22p Å
=
22Ç É
default
22Ñ ã
)
22ã å
;
22å ç
}33 
public66 
	interface66 
IExchangeRateClient66 $
{77 
Task88 
<88 	
ExchangeRateQuote88	 
?88 
>88 
GetUsdAsync88 (
(88( )
CancellationToken88) :
cancellationToken88; L
=88M N
default88O V
)88V W
;88W X
Task99 
<99 	
ExchangeRateQuote99	 
?99 
>99 
GetEurAsync99 (
(99( )
CancellationToken99) :
cancellationToken99; L
=99M N
default99O V
)99V W
;99W X
}:: 
public<< 
	interface<< 
INotificationSender<< $
{== 
Task>> 
	SendAsync>>	 
(>> 
Client>> 
client>>  
,>>  !
Notification>>" .
notification>>/ ;
,>>; <
CancellationToken>>= N
cancellationToken>>O `
=>>a b
default>>c j
)>>j k
;>>k l
}?? Ó
<C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\ContactLeads.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
enum 
ContactLeadStatus 
{ 
Nuevo  %
,% &

Contactado' 1
,1 2
Cliente3 :
,: ;

Descartado< F
}G H
public 
sealed 
class 
ContactLead 
{ 
public 

Guid 
Id 
{ 
get 
; 
set 
; 
}  
=! "
Guid# '
.' (
NewGuid( /
(/ 0
)0 1
;1 2
public		 

string		 
Name		 
{		 
get		 
;		 
set		 !
;		! "
}		# $
=		% &
string		' -
.		- .
Empty		. 3
;		3 4
public

 

string

 
Email

 
{

 
get

 
;

 
set

 "
;

" #
}

$ %
=

& '
string

( .
.

. /
Empty

/ 4
;

4 5
public 

string 
? 
Phone 
{ 
get 
; 
set  #
;# $
}% &
public 

string 
? 
Company 
{ 
get  
;  !
set" %
;% &
}' (
public 

string 
? 
Service 
{ 
get  
;  !
set" %
;% &
}' (
public 

string 
Message 
{ 
get 
;  
set! $
;$ %
}& '
=( )
string* 0
.0 1
Empty1 6
;6 7
public 

string 
Locale 
{ 
get 
; 
set  #
;# $
}% &
=' (
$str) -
;- .
public 

string 
? 

SourcePage 
{ 
get  #
;# $
set% (
;( )
}* +
public 

ContactLeadStatus 
Status #
{$ %
get& )
;) *
set+ .
;. /
}0 1
public 

string 
? 
Notes 
{ 
get 
; 
set  #
;# $
}% &
public 

DateTime 
	CreatedAt 
{ 
get  #
;# $
set% (
;( )
}* +
=, -
DateTime. 6
.6 7
UtcNow7 =
;= >
} ôk
DC:\repo\rtres-net\Rtres\src\api\Rtres.Domain\ClientProductPricing.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
static 
class  
ClientProductPricing (
{ 
public 

static 
readonly 
DateTime #
NoEnd$ )
=* +
new, /
(/ 0
$num0 4
,4 5
$num6 8
,8 9
$num: <
,< =
$num> ?
,? @
$numA B
,B C
$numD E
,E F
DateTimeKindG S
.S T
UtcT W
)W X
;X Y
public 

static 
decimal 
? 
	ListPrice $
($ %
this% )
ClientProduct* 7
item8 <
,< =
Product> E
?E F
productG N
=O P
nullQ U
)U V
=>W Y
(Z [
product[ b
??c e
itemf j
.j k
Productk r
)r s
?s t
.t u
	BasePriceu ~
??	 Å
item
Ç Ü
.
Ü á
Price
á å
;
å ç
private 
static 
bool 
HasAdjustment %
(% &
this& *
ClientProduct+ 8
item9 =
)= >
=>? A
itemB F
.F G
DiscountG O
isP R
notS V
(W X
nullX \
or] _
$num` b
)b c
;c d
public 

static 
bool 
DiscountPendingUse )
() *
this* .
ClientProduct/ <
item= A
)A B
=>C E
itemF J
.J K
HasAdjustmentK X
(X Y
)Y Z
&&[ ]
item^ b
.b c
DiscountEndsAtc q
isr t
nullu y
;y z
public 

static 
decimal 
? 
NextChargePrice *
(* +
this+ /
ClientProduct0 =
item> B
,B C
ProductD K
?K L
productM T
=U V
nullW [
)[ \
=>] _
item 
. 
	ListPrice 
( 
product 
) 
is  "
decimal# *
list+ /
?0 1
list2 6
-7 8
(9 :
item: >
.> ?
DiscountPendingUse? Q
(Q R
)R S
?T U
itemV Z
.Z [
Discount[ c
!c d
.d e
Valuee j
:k l
$numm o
)o p
:q r
nulls w
;w x
public 

static 
decimal 

IgvRateFor $
($ %
Client% +
client, 2
,2 3
Product4 ;
product< C
,C D
decimalE L
igvRateM T
)T U
=>V X
client   
.   
RequiresTaxDocument   "
&&  # %
product  & -
.  - .
TaxDocumentType  . =
==  > @
TaxDocumentType  A P
.  P Q
Factura  Q X
?  Y Z
igvRate  [ b
:  c d
$num  e g
;  g h
public"" 

static"" 
decimal"" 
WithIgv"" !
(""! "
decimal""" )
net""* -
,""- .
decimal""/ 6
igvRate""7 >
)""> ?
=>""@ B
Math""C G
.""G H
Round""H M
(""M N
net""N Q
*""R S
(""T U
$num""U V
+""W X
igvRate""Y `
)""` a
,""a b
$num""c d
)""d e
;""e f
public%% 

static%% 
decimal%% 
?%% 
NextChargeTotal%% *
(%%* +
this%%+ /
ClientProduct%%0 =
item%%> B
,%%B C
decimal%%D K
igvRate%%L S
,%%S T
Product%%U \
?%%\ ]
product%%^ e
=%%f g
null%%h l
)%%l m
=>%%n p
item&& 
.&& 
NextChargePrice&& 
(&& 
product&& $
)&&$ %
is&&& (
decimal&&) 0
net&&1 4
?&&5 6
WithIgv&&7 >
(&&> ?
net&&? B
,&&B C
igvRate&&D K
)&&K L
:&&M N
null&&O S
;&&S T
public(( 

const(( 
int(( 
MaxPrepaidYears(( $
=((% &
$num((' (
;((( )
public.. 

static.. 
decimal.. 
?.. 
ChargeTotal.. &
(..& '
this..' +
ClientProduct.., 9
item..: >
,..> ?
decimal..@ G
igvRate..H O
,..O P
int..Q T
years..U Z
,..Z [
Product..\ c
?..c d
product..e l
=..m n
null..o s
)..s t
=>..u w
item// 
.// 
NextChargePrice// 
(// 
product// $
)//$ %
is//& (
decimal//) 0
first//1 6
&&//7 9
item//: >
.//> ?
	ListPrice//? H
(//H I
product//I P
)//P Q
is//R T
decimal//U \
list//] a
?//b c
WithIgv//d k
(//k l
first//l q
+//r s
(//t u
years//u z
-//{ |
$num//} ~
)//~ 
*
//Ä Å
list
//Ç Ü
,
//Ü á
igvRate
//à è
)
//è ê
:
//ë í
null
//ì ó
;
//ó ò
public22 

static22 
string22 
?22 
ValidateYears22 '
(22' (
this22( ,
ClientProduct22- :
item22; ?
,22? @
int22A D
years22E J
)22J K
=>22L N
years33 
<33 
$num33 
||33 
years33 
>33 
MaxPrepaidYears33 ,
?33- .
$"33/ 1
$str331 H
{33H I
MaxPrepaidYears33I X
}33X Y
$str33Y _
"33_ `
:44 	
years44
 
>44 
$num44 
&&44 
item44 
.44 
BillingCycle44 (
!=44) +
BillingCycle44, 8
.448 9
Anual449 >
?44? @
$str44A ~
:	44 Ä
null
44Å Ö
;
44Ö Ü
public77 

static77 
decimal77 
?77 
CurrentPrice77 '
(77' (
this77( ,
ClientProduct77- :
item77; ?
,77? @
DateTime77A I
now77J M
,77M N
Product77O V
?77V W
product77X _
=77` a
null77b f
)77f g
=>77h j
item88 
.88 
	ListPrice88 
(88 
product88 
)88 
is88  "
decimal88# *
list88+ /
?880 1
list882 6
-887 8
(889 :
item88: >
.88> ?
HasAdjustment88? L
(88L M
)88M N
&&88O Q
(88R S
item88S W
.88W X
DiscountEndsAt88X f
is88g i
null88j n
||88o q
now88r u
<88v w
item88x |
.88| }
DiscountEndsAt	88} ã
)
88ã å
?
88ç é
item
88è ì
.
88ì î
Discount
88î ú
!
88ú ù
.
88ù û
Value
88û £
:
88§ •
$num
88¶ ®
)
88® ©
:
88™ ´
null
88¨ ∞
;
88∞ ±
public?? 

static?? 
string?? 
??? 
SetDiscount?? %
(??% &
this??& *
ClientProduct??+ 8
item??9 =
,??= >
decimal??? F
???F G
discount??H P
,??P Q
Product??R Y
???Y Z
product??[ b
=??c d
null??e i
)??i j
{@@ 
ifAA 

(AA 
discountAA 
isAA 
nullAA 
orAA 
$numAA  !
)AA! "
{AA# $
itemAA% )
.AA) *
DiscountAA* 2
=AA3 4
nullAA5 9
;AA9 :
itemAA; ?
.AA? @
DiscountEndsAtAA@ N
=AAO P
nullAAQ U
;AAU V
returnAAW ]
nullAA^ b
;AAb c
}AAd e
ifBB 

(BB 
itemBB 
.BB 
	ListPriceBB 
(BB 
productBB "
)BB" #
isBB$ &
notBB' *
decimalBB+ 2
listBB3 7
)BB7 8
returnBB9 ?
$str	BB@ ë
;
BBë í
ifCC 

(CC 
discountCC 
>CC 
listCC 
)CC 
returnCC #
$"CC$ &
$strCC& \
{CC\ ]
listCC] a
:CCa b
$strCCb f
}CCf g
$strCCg i
"CCi j
;CCj k
ifEE 

(EE 
discountEE 
<EE 
$numEE 
&&EE 
!EE 
stringEE #
.EE# $
IsNullOrWhiteSpaceEE$ 6
(EE6 7
itemEE7 ;
.EE; < 
PayPalSubscriptionIdEE< P
)EEP Q
&&EER T
itemEEU Y
.EEY Z
StatusEEZ `
isEEa c
notEEd g
(EEh i
ClientProductStatusEEi |
.EE| }
	Pendiente	EE} Ü
or
EEá â!
ClientProductStatus
EEä ù
.
EEù û
	Cancelado
EEû ß
)
EEß ®
)
EE® ©
returnFF 
$strFF v
;FFv w
itemGG 
.GG 
DiscountGG 
=GG 
MathGG 
.GG 
RoundGG "
(GG" #
discountGG# +
.GG+ ,
ValueGG, 1
,GG1 2
$numGG3 4
)GG4 5
;GG5 6
itemHH 
.HH 
DiscountEndsAtHH 
=HH 
discountHH &
<HH' (
$numHH) *
||HH+ -
itemHH. 2
.HH2 3
StatusHH3 9
==HH: <
ClientProductStatusHH= P
.HHP Q
	PendienteHHQ Z
?HH[ \
nullHH] a
:HHb c
itemHHd h
.HHh i
	PeriodEndHHi r
(HHr s
)HHs t
??HHu w
NoEndHHx }
;HH} ~
returnII 
nullII 
;II 
}JJ 
publicPP 

staticPP 
voidPP 
OnPaymentAppliedPP '
(PP' (
thisPP( ,
ClientProductPP- :
itemPP; ?
)PP? @
{QQ 
ifRR 

(RR 
!RR 
itemRR 
.RR 
HasAdjustmentRR 
(RR  
)RR  !
)RR! "
returnRR# )
;RR) *
ifSS 

(SS 
itemSS 
.SS 
DiscountEndsAtSS 
isSS  "
nullSS# '
)SS' (
itemSS) -
.SS- .
DiscountEndsAtSS. <
=SS= >
itemSS? C
.SSC D
	PeriodEndSSD M
(SSM N
)SSN O
??SSP R
NoEndSSS X
;SSX Y
elseTT 
{TT 
itemTT 
.TT 
DiscountTT 
=TT 
nullTT #
;TT# $
itemTT% )
.TT) *
DiscountEndsAtTT* 8
=TT9 :
nullTT; ?
;TT? @
}TTA B
}UU 
public\\ 

static\\ 
void\\ 
OnPaymentReversed\\ (
(\\( )
this\\) -
ClientProduct\\. ;
item\\< @
,\\@ A
DateTime\\B J
?\\J K
paidPeriodEnd\\L Y
)\\Y Z
{]] 
if^^ 

(^^ 
item^^ 
.^^ 
HasAdjustment^^ 
(^^ 
)^^  
&&^^! #
(^^$ %
item^^% )
.^^) *
DiscountEndsAt^^* 8
==^^9 ;
NoEnd^^< A
||^^B D
item^^E I
.^^I J
DiscountEndsAt^^J X
==^^Y [
paidPeriodEnd^^\ i
)^^i j
)^^j k
item^^l p
.^^p q
DiscountEndsAt^^q 
=
^^Ä Å
null
^^Ç Ü
;
^^Ü á
}__ 
publicbb 

staticbb 
voidbb 
OnDatesChangedbb %
(bb% &
thisbb& *
ClientProductbb+ 8
itembb9 =
)bb= >
{cc 
ifdd 

(dd 
itemdd 
.dd 
DiscountEndsAtdd 
==dd  "
NoEnddd# (
&&dd) +
itemdd, 0
.dd0 1
	PeriodEnddd1 :
(dd: ;
)dd; <
isdd= ?
DateTimedd@ H
endddI L
)ddL M
itemddN R
.ddR S
DiscountEndsAtddS a
=ddb c
endddd g
;ddg h
}ee 
privategg 
staticgg 
DateTimegg 
?gg 
	PeriodEndgg &
(gg& '
thisgg' +
ClientProductgg, 9
itemgg: >
)gg> ?
=>gg@ B
itemggC G
.ggG H
BillingCycleggH T
.ggT U
IsSubscriptionggU c
(ggc d
)ggd e
?ggf g
itemggh l
.ggl m
NextChargeAtggm y
:ggz {
item	gg| Ä
.
ggÄ Å
RenewsAt
ggÅ â
;
ggâ ä
}hh ‰:
=C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\BankTransfers.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
enum 
BankAccountType 
{ 
Ahorros %
,% &
	Corriente' 0
}1 2
public 
sealed 
class 
BankAccount 
{ 
public 

Guid 
Id 
{ 
get 
; 
set 
; 
}  
=! "
Guid# '
.' (
NewGuid( /
(/ 0
)0 1
;1 2
public		 

string		 
BankName		 
{		 
get		  
;		  !
set		" %
;		% &
}		' (
=		) *
string		+ 1
.		1 2
Empty		2 7
;		7 8
public 

string 
Holder 
{ 
get 
; 
set  #
;# $
}% &
=' (
string) /
./ 0
Empty0 5
;5 6
public 

string 
Currency 
{ 
get  
;  !
set" %
;% &
}' (
=) *
$str+ 0
;0 1
public 

BankAccountType 
Type 
{  !
get" %
;% &
set' *
;* +
}, -
public 

string 
AccountNumber 
{  !
get" %
;% &
set' *
;* +
}, -
=. /
string0 6
.6 7
Empty7 <
;< =
public 

string 
? 
Cci 
{ 
get 
; 
set !
;! "
}# $
public 

bool 
IsActive 
{ 
get 
; 
set  #
;# $
}% &
=' (
true) -
;- .
public 

int 
	SortOrder 
{ 
get 
; 
set  #
;# $
}% &
} 
public 
sealed 
class 
PaymentSettings #
{ 
public 

Guid 
Id 
{ 
get 
; 
set 
; 
}  
=! "
Guid# '
.' (
NewGuid( /
(/ 0
)0 1
;1 2
public 

bool 
PayPalEnabled 
{ 
get  #
;# $
set% (
;( )
}* +
=, -
true. 2
;2 3
public 

bool 
BankTransferEnabled #
{$ %
get& )
;) *
set+ .
;. /
}0 1
=2 3
true4 8
;8 9
public 

DateTime 
	UpdatedAt 
{ 
get  #
;# $
set% (
;( )
}* +
=, -
DateTime. 6
.6 7
UtcNow7 =
;= >
} 
public 
enum  
TransferReportStatus  
{! "
	Pendiente# ,
,, -
Aprobado. 6
,6 7
	Rechazado8 A
}B C
public%% 
sealed%% 
class%% 
TransferReport%% "
{&& 
public'' 

Guid'' 
Id'' 
{'' 
get'' 
;'' 
set'' 
;'' 
}''  
=''! "
Guid''# '
.''' (
NewGuid''( /
(''/ 0
)''0 1
;''1 2
public(( 

Guid(( 
ClientId(( 
{(( 
get(( 
;(( 
set((  #
;((# $
}((% &
public)) 

Guid)) 
ClientProductId)) 
{))  !
get))" %
;))% &
set))' *
;))* +
})), -
public** 

Guid** 
?** 
BankAccountId** 
{**  
get**! $
;**$ %
set**& )
;**) *
}**+ ,
public++ 

decimal++ 
Amount++ 
{++ 
get++ 
;++  
set++! $
;++$ %
}++& '
public-- 

string-- 
Currency-- 
{-- 
get--  
;--  !
set--" %
;--% &
}--' (
=--) *
$str--+ 0
;--0 1
public.. 

DateOnly.. 
PaidAt.. 
{.. 
get..  
;..  !
set.." %
;..% &
}..' (
public// 

string// 
?// 
OperationNumber// "
{//# $
get//% (
;//( )
set//* -
;//- .
}/// 0
public00 

int00 
Years00 
{00 
get00 
;00 
set00 
;00  
}00! "
=00# $
$num00% &
;00& '
public11 

string11 
?11 
ReceiptFileName11 "
{11# $
get11% (
;11( )
set11* -
;11- .
}11/ 0
public22 

string22 
?22 
ReceiptContentType22 %
{22& '
get22( +
;22+ ,
set22- 0
;220 1
}222 3
public33 

byte33 
[33 
]33 
?33 
ReceiptContent33 !
{33" #
get33$ '
;33' (
set33) ,
;33, -
}33. /
public44 
 
TransferReportStatus44 
Status44  &
{44' (
get44) ,
;44, -
set44. 1
;441 2
}443 4
public55 

string55 
?55 
RejectionReason55 "
{55# $
get55% (
;55( )
set55* -
;55- .
}55/ 0
public66 

Guid66 
?66 
ReportedByUserId66 !
{66" #
get66$ '
;66' (
set66) ,
;66, -
}66. /
public77 

Guid77 
?77 
ReviewedByUserId77 !
{77" #
get77$ '
;77' (
set77) ,
;77, -
}77. /
public88 

DateTime88 
?88 

ReviewedAt88 
{88  !
get88" %
;88% &
set88' *
;88* +
}88, -
public99 

Guid99 
?99  
PaymentTransactionId99 %
{99& '
get99( +
;99+ ,
set99- 0
;990 1
}992 3
public:: 

DateTime:: 
	CreatedAt:: 
{:: 
get::  #
;::# $
set::% (
;::( )
}::* +
=::, -
DateTime::. 6
.::6 7
UtcNow::7 =
;::= >
};; 
public>> 
sealed>> 
record>> !
TransferReportSummary>> *
(>>* +
Guid>>+ /
Id>>0 2
,>>2 3 
TransferReportStatus>>4 H
Status>>I O
,>>O P
DateTime>>Q Y
	CreatedAt>>Z c
,>>c d
string>>e k
?>>k l
RejectionReason>>m |
)>>| }
;>>} ~