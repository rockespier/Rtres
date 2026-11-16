õ
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
,
‚ „
	LoginLink
‰ Ì
,
Ì Ó%
TicketCreatedForManager
Ô Ü
}
á à
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
}^^ ±ã
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
}gg5 6
publicii 

stringii 
?ii 
Areaii 
{ii 
getii 
;ii 
setii "
;ii" #
}ii$ %
publickk 

stringkk 
?kk 
JobTitlekk 
{kk 
getkk !
;kk! "
setkk# &
;kk& '
}kk( )
publicmm 

Guidmm 
?mm 
	ManagerIdmm 
{mm 
getmm  
;mm  !
setmm" %
;mm% &
}mm' (
}mm) *
publicrr 
sealedrr 
classrr 
	LoginLinkrr 
{rr 
publicrr  &
Guidrr' +
Idrr, .
{rr/ 0
getrr1 4
;rr4 5
setrr6 9
;rr9 :
}rr; <
=rr= >
Guidrr? C
.rrC D
NewGuidrrD K
(rrK L
)rrL M
;rrM N
publicrrO U
GuidrrV Z
UserAccountIdrr[ h
{rri j
getrrk n
;rrn o
setrrp s
;rrs t
}rru v
publicrrw }
string	rr~ Ñ
	TokenHash
rrÖ é
{
rrè ê
get
rrë î
;
rrî ï
set
rrñ ô
;
rrô ö
}
rrõ ú
=
rrù û
string
rrü •
.
rr• ¶
Empty
rr¶ ´
;
rr´ ¨
public
rr≠ ≥
DateTime
rr¥ º
	CreatedAt
rrΩ ∆
{
rr« »
get
rr… Ã
;
rrÃ Õ
set
rrŒ —
;
rr— “
}
rr” ‘
=
rr’ ÷
DateTime
rr◊ ﬂ
.
rrﬂ ‡
UtcNow
rr‡ Ê
;
rrÊ Á
public
rrË Ó
DateTime
rrÔ ˜
	ExpiresAt
rr¯ Å
{
rrÇ É
get
rrÑ á
;
rrá à
set
rrâ å
;
rrå ç
}
rré è
public
rrê ñ
DateTime
rró ü
?
rrü †
UsedAt
rr° ß
{
rr® ©
get
rr™ ≠
;
rr≠ Æ
set
rrØ ≤
;
rr≤ ≥
}
rr¥ µ
}
rr∂ ∑
publictt 
sealedtt 
classtt 
Projecttt 
{tt 
publictt $
Guidtt% )
Idtt* ,
{tt- .
gettt/ 2
;tt2 3
settt4 7
;tt7 8
}tt9 :
=tt; <
Guidtt= A
.ttA B
NewGuidttB I
(ttI J
)ttJ K
;ttK L
publicttM S
GuidttT X
ClientIdttY a
{ttb c
getttd g
;ttg h
settti l
;ttl m
}ttn o
publicttp v
stringttw }
Name	tt~ Ç
{
ttÉ Ñ
get
ttÖ à
;
ttà â
set
ttä ç
;
ttç é
}
ttè ê
=
ttë í
string
ttì ô
.
ttô ö
Empty
ttö ü
;
ttü †
public
tt° ß
string
tt® Æ
Slug
ttØ ≥
{
tt¥ µ
get
tt∂ π
;
ttπ ∫
set
ttª æ
;
ttæ ø
}
tt¿ ¡
=
tt¬ √
string
ttƒ  
.
tt  À
Empty
ttÀ –
;
tt– —
public
tt“ ÿ
List
ttŸ ›
<
tt› ﬁ
ProjectRepository
ttﬁ Ô
>
ttÔ 
Repositories
ttÒ ˝
{
tt˛ ˇ
get
ttÄ É
;
ttÉ Ñ
set
ttÖ à
;
ttà â
}
ttä ã
=
ttå ç
[
tté è
]
ttè ê
;
ttê ë
}
ttí ì
publicvv 
sealedvv 
classvv 
ProjectRepositoryvv %
{vv& '
publicvv( .
Guidvv/ 3
Idvv4 6
{vv7 8
getvv9 <
;vv< =
setvv> A
;vvA B
}vvC D
=vvE F
GuidvvG K
.vvK L
NewGuidvvL S
(vvS T
)vvT U
;vvU V
publicvvW ]
Guidvv^ b
	ProjectIdvvc l
{vvm n
getvvo r
;vvr s
setvvt w
;vvw x
}vvy z
public	vv{ Å
string
vvÇ à
Owner
vvâ é
{
vvè ê
get
vvë î
;
vvî ï
set
vvñ ô
;
vvô ö
}
vvõ ú
=
vvù û
string
vvü •
.
vv• ¶
Empty
vv¶ ´
;
vv´ ¨
public
vv≠ ≥
string
vv¥ ∫
Name
vvª ø
{
vv¿ ¡
get
vv¬ ≈
;
vv≈ ∆
set
vv«  
;
vv  À
}
vvÃ Õ
=
vvŒ œ
string
vv– ÷
.
vv÷ ◊
Empty
vv◊ ‹
;
vv‹ ›
public
vvﬁ ‰
string
vvÂ Î
?
vvÎ Ï
Label
vvÌ Ú
{
vvÛ Ù
get
vvı ¯
;
vv¯ ˘
set
vv˙ ˝
;
vv˝ ˛
}
vvˇ Ä
public
vvÅ á
bool
vvà å
	IsDefault
vvç ñ
{
vvó ò
get
vvô ú
;
vvú ù
set
vvû °
;
vv° ¢
}
vv£ §
}
vv• ¶
publicww 
staticww 
classww 
ProjectExtensionsww %
{xx 
publiczz 

staticzz 
ProjectRepositoryzz #
?zz# $
RepositoryForzz% 2
(zz2 3
thiszz3 7
IReadOnlyCollectionzz8 K
<zzK L
ProjectRepositoryzzL ]
>zz] ^
repositorieszz_ k
,zzk l
Guidzzm q
?zzq r
repositoryIdzzs 
)	zz Ä
=>
zzÅ É
repositoryId{{ 
is{{ 
Guid{{ 
id{{ 
?{{  !
repositories{{" .
.{{. /
FirstOrDefault{{/ =
({{= >
x{{> ?
=>{{@ B
x{{C D
.{{D E
Id{{E G
=={{H J
id{{K M
){{M N
:{{O P
repositories{{Q ]
.{{] ^
OrderByDescending{{^ o
({{o p
x{{p q
=>{{r t
x{{u v
.{{v w
	IsDefault	{{w Ä
)
{{Ä Å
.
{{Å Ç
FirstOrDefault
{{Ç ê
(
{{ê ë
)
{{ë í
;
{{í ì
}|| 
public}} 
sealed}} 
class}} 
Product}} 
{}} 
public}} $
Guid}}% )
Id}}* ,
{}}- .
get}}/ 2
;}}2 3
set}}4 7
;}}7 8
}}}9 :
=}}; <
Guid}}= A
.}}A B
NewGuid}}B I
(}}I J
)}}J K
;}}K L
public}}M S
ProductType}}T _
Type}}` d
{}}e f
get}}g j
;}}j k
set}}l o
;}}o p
}}}q r
public}}s y
string	}}z Ä
Name
}}Å Ö
{
}}Ü á
get
}}à ã
;
}}ã å
set
}}ç ê
;
}}ê ë
}
}}í ì
=
}}î ï
string
}}ñ ú
.
}}ú ù
Empty
}}ù ¢
;
}}¢ £
public
}}§ ™
BillingCycle
}}´ ∑
BillingCycle
}}∏ ƒ
{
}}≈ ∆
get
}}«  
;
}}  À
set
}}Ã œ
;
}}œ –
}
}}— “
public
}}” Ÿ
decimal
}}⁄ ·
?
}}· ‚
	BasePrice
}}„ Ï
{
}}Ì Ó
get
}}Ô Ú
;
}}Ú Û
set
}}Ù ˜
;
}}˜ ¯
}
}}˘ ˙
public
}}˚ Å
string
}}Ç à
Currency
}}â ë
{
}}í ì
get
}}î ó
;
}}ó ò
set
}}ô ú
;
}}ú ù
}
}}û ü
=
}}† °
$str
}}¢ ß
;
}}ß ®
public
}}© Ø
string
}}∞ ∂
?
}}∂ ∑
Description
}}∏ √
{
}}ƒ ≈
get
}}∆ …
;
}}…  
set
}}À Œ
;
}}Œ œ
}
}}– —
public
}}“ ÿ
bool
}}Ÿ ›
IsActive
}}ﬁ Ê
{
}}Á Ë
get
}}È Ï
;
}}Ï Ì
set
}}Ó Ò
;
}}Ò Ú
}
}}Û Ù
=
}}ı ˆ
true
}}˜ ˚
;
}}˚ ¸
public
}}˝ É
string
}}Ñ ä
?
}}ä ã
PayPalPlanId
}}å ò
{
}}ô ö
get
}}õ û
;
}}û ü
set
}}† £
;
}}£ §
}
}}• ¶
public
}}ß ≠
decimal
}}Æ µ
?
}}µ ∂
PayPalPlanPrice
}}∑ ∆
{
}}« »
get
}}… Ã
;
}}Ã Õ
set
}}Œ —
;
}}— “
}
}}” ‘
public
}}’ €
TaxDocumentType
}}‹ Î
TaxDocumentType
}}Ï ˚
{
}}¸ ˝
get
}}˛ Å
;
}}Å Ç
set
}}É Ü
;
}}Ü á
}
}}à â
=
}}ä ã
TaxDocumentType
}}å õ
.
}}õ ú
Factura
}}ú £
;
}}£ §
public 

string 
? 
Category 
{ 
get !
;! "
set# &
;& '
}( )
public
ÅÅ 

string
ÅÅ 
?
ÅÅ 
Tags
ÅÅ 
{
ÅÅ 
get
ÅÅ 
;
ÅÅ 
set
ÅÅ "
;
ÅÅ" #
}
ÅÅ$ %
public
ÉÉ 

bool
ÉÉ 
AllowsTickets
ÉÉ 
{
ÉÉ 
get
ÉÉ  #
;
ÉÉ# $
set
ÉÉ% (
;
ÉÉ( )
}
ÉÉ* +
}
ÉÉ, -
publicÑÑ 
sealed
ÑÑ 
class
ÑÑ 
ClientProduct
ÑÑ !
{
ÑÑ" #
public
ÑÑ$ *
Guid
ÑÑ+ /
Id
ÑÑ0 2
{
ÑÑ3 4
get
ÑÑ5 8
;
ÑÑ8 9
set
ÑÑ: =
;
ÑÑ= >
}
ÑÑ? @
=
ÑÑA B
Guid
ÑÑC G
.
ÑÑG H
NewGuid
ÑÑH O
(
ÑÑO P
)
ÑÑP Q
;
ÑÑQ R
public
ÑÑS Y
Guid
ÑÑZ ^
ClientId
ÑÑ_ g
{
ÑÑh i
get
ÑÑj m
;
ÑÑm n
set
ÑÑo r
;
ÑÑr s
}
ÑÑt u
public
ÑÑv |
GuidÑÑ} Å
	ProjectIdÑÑÇ ã
{ÑÑå ç
getÑÑé ë
;ÑÑë í
setÑÑì ñ
;ÑÑñ ó
}ÑÑò ô
publicÑÑö †
GuidÑÑ° •
	ProductIdÑÑ¶ Ø
{ÑÑ∞ ±
getÑÑ≤ µ
;ÑÑµ ∂
setÑÑ∑ ∫
;ÑÑ∫ ª
}ÑÑº Ω
publicÑÑæ ƒ#
ClientProductStatusÑÑ≈ ÿ
StatusÑÑŸ ﬂ
{ÑÑ‡ ·
getÑÑ‚ Â
;ÑÑÂ Ê
setÑÑÁ Í
;ÑÑÍ Î
}ÑÑÏ Ì
publicÑÑÓ Ù
BillingCycleÑÑı Å
BillingCycleÑÑÇ é
{ÑÑè ê
getÑÑë î
;ÑÑî ï
setÑÑñ ô
;ÑÑô ö
}ÑÑõ ú
publicÑÑù £
boolÑÑ§ ®
IsManualBillingÑÑ© ∏
{ÑÑπ ∫
getÑÑª æ
;ÑÑæ ø
setÑÑ¿ √
;ÑÑ√ ƒ
}ÑÑ≈ ∆
publicÑÑ« Õ
DateTimeÑÑŒ ÷
?ÑÑ÷ ◊
RenewsAtÑÑÿ ‡
{ÑÑ· ‚
getÑÑ„ Ê
;ÑÑÊ Á
setÑÑË Î
;ÑÑÎ Ï
}ÑÑÌ Ó
publicÑÑÔ ı
DateTimeÑÑˆ ˛
?ÑÑ˛ ˇ
NextChargeAtÑÑÄ å
{ÑÑç é
getÑÑè í
;ÑÑí ì
setÑÑî ó
;ÑÑó ò
}ÑÑô ö
publicÑÑõ °
DateTimeÑÑ¢ ™
?ÑÑ™ ´
LastBackupAtÑÑ¨ ∏
{ÑÑπ ∫
getÑÑª æ
;ÑÑæ ø
setÑÑ¿ √
;ÑÑ√ ƒ
}ÑÑ≈ ∆
publicÑÑ« Õ
decimalÑÑŒ ’
?ÑÑ’ ÷
PriceÑÑ◊ ‹
{ÑÑ› ﬁ
getÑÑﬂ ‚
;ÑÑ‚ „
setÑÑ‰ Á
;ÑÑÁ Ë
}ÑÑÈ Í
publicÑÑÎ Ò
stringÑÑÚ ¯
?ÑÑ¯ ˘"
PriceLabelOverrideÑÑ˙ å
{ÑÑç é
getÑÑè í
;ÑÑí ì
setÑÑî ó
;ÑÑó ò
}ÑÑô ö
publicÑÑõ °
stringÑÑ¢ ®
?ÑÑ® ©
PayPalOrderIdÑÑ™ ∑
{ÑÑ∏ π
getÑÑ∫ Ω
;ÑÑΩ æ
setÑÑø ¬
;ÑÑ¬ √
}ÑÑƒ ≈
publicÑÑ∆ Ã
stringÑÑÕ ”
?ÑÑ” ‘$
PayPalSubscriptionIdÑÑ’ È
{ÑÑÍ Î
getÑÑÏ Ô
;ÑÑÔ 
setÑÑÒ Ù
;ÑÑÙ ı
}ÑÑˆ ˜
publicÑÑ¯ ˛
stringÑÑˇ Ö
?ÑÑÖ Ü
PayPalPlanIdÑÑá ì
{ÑÑî ï
getÑÑñ ô
;ÑÑô ö
setÑÑõ û
;ÑÑû ü
}ÑÑ† °
publicÑÑ¢ ®
stringÑÑ© Ø
?ÑÑØ ∞

DomainNameÑÑ± ª
{ÑÑº Ω
getÑÑæ ¡
;ÑÑ¡ ¬
setÑÑ√ ∆
;ÑÑ∆ «
}ÑÑ» …
public
ÖÖ 

decimal
ÖÖ 
?
ÖÖ 
Discount
ÖÖ 
{
ÖÖ 
get
ÖÖ "
;
ÖÖ" #
set
ÖÖ$ '
;
ÖÖ' (
}
ÖÖ) *
public
ÖÖ+ 1
DateTime
ÖÖ2 :
?
ÖÖ: ;
DiscountEndsAt
ÖÖ< J
{
ÖÖK L
get
ÖÖM P
;
ÖÖP Q
set
ÖÖR U
;
ÖÖU V
}
ÖÖW X
public
ÖÖY _
Product
ÖÖ` g
?
ÖÖg h
Product
ÖÖi p
{
ÖÖq r
get
ÖÖs v
;
ÖÖv w
set
ÖÖx {
;
ÖÖ{ |
}
ÖÖ} ~
publicÖÖ Ö
ProjectÖÖÜ ç
?ÖÖç é
ProjectÖÖè ñ
{ÖÖó ò
getÖÖô ú
;ÖÖú ù
setÖÖû °
;ÖÖ° ¢
}ÖÖ£ §
public
áá 

int
áá 
?
áá 
PayPalOrderYears
áá  
{
áá! "
get
áá# &
;
áá& '
set
áá( +
;
áá+ ,
}
áá- .
public
ââ 

decimal
ââ 
?
ââ 
AppliedIgvRate
ââ "
{
ââ# $
get
ââ% (
;
ââ( )
set
ââ* -
;
ââ- .
}
ââ/ 0
public
ãã 
#
TransferReportSummary
ãã  
?
ãã  !
TransferReport
ãã" 0
{
ãã1 2
get
ãã3 6
;
ãã6 7
set
ãã8 ;
;
ãã; <
}
ãã= >
}
ãã? @
publicåå 
sealed
åå 
class
åå 
Ticket
åå 
{
åå 
public
åå #
Guid
åå$ (
Id
åå) +
{
åå, -
get
åå. 1
;
åå1 2
set
åå3 6
;
åå6 7
}
åå8 9
=
åå: ;
Guid
åå< @
.
åå@ A
NewGuid
ååA H
(
ååH I
)
ååI J
;
ååJ K
public
ååL R
string
ååS Y
Code
ååZ ^
{
åå_ `
get
ååa d
;
ååd e
set
ååf i
;
ååi j
}
ååk l
=
ååm n
string
ååo u
.
ååu v
Empty
ååv {
;
åå{ |
publicåå} É
GuidååÑ à
ClientIdååâ ë
{ååí ì
getååî ó
;ååó ò
setååô ú
;ååú ù
}ååû ü
publicåå† ¶
Guidååß ´
	ProjectIdåå¨ µ
{åå∂ ∑
getåå∏ ª
;ååª º
setååΩ ¿
;åå¿ ¡
}åå¬ √
publicååƒ  
GuidååÀ œ
CreatedByUserIdåå– ﬂ
{åå‡ ·
getåå‚ Â
;ååÂ Ê
setååÁ Í
;ååÍ Î
}ååÏ Ì
publicååÓ Ù

TicketTypeååı ˇ
TypeååÄ Ñ
{ååÖ Ü
getååá ä
;ååä ã
setååå è
;ååè ê
}ååë í
publicååì ô
TicketStatusååö ¶
Statusååß ≠
{ååÆ Ø
getåå∞ ≥
;åå≥ ¥
setååµ ∏
;åå∏ π
}åå∫ ª
=ååº Ω
TicketStatusååæ  
.åå  À
AbiertoååÀ “
;åå“ ”
publicåå‘ ⁄
stringåå€ ·
Titleåå‚ Á
{ååË È
getååÍ Ì
;ååÌ Ó
setååÔ Ú
;ååÚ Û
}ååÙ ı
=ååˆ ˜
stringåå¯ ˛
.åå˛ ˇ
Emptyååˇ Ñ
;ååÑ Ö
publicååÜ å
stringååç ì
Descriptionååî ü
{åå† °
getåå¢ •
;åå• ¶
setååß ™
;åå™ ´
}åå¨ ≠
=ååÆ Ø
stringåå∞ ∂
.åå∂ ∑
Emptyåå∑ º
;ååº Ω
publicååæ ƒ
stringåå≈ À
?ååÀ Ã
CurrentBehaviorååÕ ‹
{åå› ﬁ
getååﬂ ‚
;åå‚ „
setåå‰ Á
;ååÁ Ë
}ååÈ Í
publicååÎ Ò
stringååÚ ¯
?åå¯ ˘ 
ExpectedBehavioråå˙ ä
{ååã å
getååç ê
;ååê ë
setååí ï
;ååï ñ
}ååó ò
publicååô ü
stringåå† ¶
?åå¶ ß 
StepsToReproduceåå® ∏
{ååπ ∫
getååª æ
;ååæ ø
setåå¿ √
;åå√ ƒ
}åå≈ ∆
publicåå« Õ
stringååŒ ‘
?åå‘ ’
Environmentåå÷ ·
{åå‚ „
getåå‰ Á
;ååÁ Ë
setååÈ Ï
;ååÏ Ì
}ååÓ Ô
publicåå ˆ
stringåå˜ ˝
?åå˝ ˛"
AcceptanceCriteriaååˇ ë
{ååí ì
getååî ó
;ååó ò
setååô ú
;ååú ù
}ååû ü
publicåå† ¶
stringååß ≠
?åå≠ Æ
EstimatedImpactååØ æ
{ååø ¿
getåå¡ ƒ
;ååƒ ≈
setåå∆ …
;åå…  
}ååÀ Ã
public
çç 

Guid
çç 
?
çç 
RepositoryId
çç 
{
çç 
get
çç  #
;
çç# $
set
çç% (
;
çç( )
}
çç* +
public
éé 

Guid
éé 
?
éé 
ClientProductId
éé  
{
éé! "
get
éé# &
;
éé& '
set
éé( +
;
éé+ ,
}
éé- .
public
éé/ 5
int
éé6 9
?
éé9 :
GithubIssueNumber
éé; L
{
ééM N
get
ééO R
;
ééR S
set
ééT W
;
ééW X
}
ééY Z
public
éé[ a
string
ééb h
?
ééh i
GithubIssueUrl
ééj x
{
ééy z
get
éé{ ~
;
éé~ 
setééÄ É
;ééÉ Ñ
}ééÖ Ü
public
èè 
string
èè 
?
èè !
GithubProjectStatus
èè #
{
èè$ %
get
èè& )
;
èè) *
set
èè+ .
;
èè. /
}
èè0 1
public
èè2 8
DateTime
èè9 A
	CreatedAt
èèB K
{
èèL M
get
èèN Q
;
èèQ R
set
èèS V
;
èèV W
}
èèX Y
=
èèZ [
DateTime
èè\ d
.
èèd e
UtcNow
èèe k
;
èèk l
public
èèm s
DateTime
èèt |
	UpdatedAtèè} Ü
{èèá à
getèèâ å
;èèå ç
setèèé ë
;èèë í
}èèì î
=èèï ñ
DateTimeèèó ü
.èèü †
UtcNowèè† ¶
;èè¶ ß
}èè® ©
publicëë 
sealed
ëë 
class
ëë 
TicketAttachment
ëë $
{
ëë% &
public
ëë' -
Guid
ëë. 2
Id
ëë3 5
{
ëë6 7
get
ëë8 ;
;
ëë; <
set
ëë= @
;
ëë@ A
}
ëëB C
=
ëëD E
Guid
ëëF J
.
ëëJ K
NewGuid
ëëK R
(
ëëR S
)
ëëS T
;
ëëT U
public
ëëV \
Guid
ëë] a
TicketId
ëëb j
{
ëëk l
get
ëëm p
;
ëëp q
set
ëër u
;
ëëu v
}
ëëw x
public
ëëy 
stringëëÄ Ü
FileNameëëá è
{ëëê ë
getëëí ï
;ëëï ñ
setëëó ö
;ëëö õ
}ëëú ù
=ëëû ü
stringëë† ¶
.ëë¶ ß
Emptyëëß ¨
;ëë¨ ≠
publicëëÆ ¥
stringëëµ ª
Urlëëº ø
{ëë¿ ¡
getëë¬ ≈
;ëë≈ ∆
setëë«  
;ëë  À
}ëëÃ Õ
=ëëŒ œ
stringëë– ÷
.ëë÷ ◊
Emptyëë◊ ‹
;ëë‹ ›
publicëëﬁ ‰
longëëÂ È
	SizeBytesëëÍ Û
{ëëÙ ı
getëëˆ ˘
;ëë˘ ˙
setëë˚ ˛
;ëë˛ ˇ
}ëëÄ Å
publicëëÇ à
stringëëâ è
ContentTypeëëê õ
{ëëú ù
getëëû °
;ëë° ¢
setëë£ ¶
;ëë¶ ß
}ëë® ©
=ëë™ ´
$strëë¨ ∆
;ëë∆ «
publicëë» Œ
byteëëœ ”
[ëë” ‘
]ëë‘ ’
Contentëë÷ ›
{ëëﬁ ﬂ
getëë‡ „
;ëë„ ‰
setëëÂ Ë
;ëëË È
}ëëÍ Î
=ëëÏ Ì
[ëëÓ Ô
]ëëÔ 
;ëë Ò
publicëëÚ ¯
DateTimeëë˘ Å
	CreatedAtëëÇ ã
{ëëå ç
getëëé ë
;ëëë í
setëëì ñ
;ëëñ ó
}ëëò ô
=ëëö õ
DateTimeëëú §
.ëë§ •
UtcNowëë• ´
;ëë´ ¨
publicëë≠ ≥
boolëë¥ ∏
IsImageëëπ ¿
=>ëë¡ √
ContentTypeëëƒ œ
.ëëœ –

StartsWithëë– ⁄
(ëë⁄ €
$strëë€ „
,ëë„ ‰ 
StringComparisonëëÂ ı
.ëëı ˆ!
OrdinalIgnoreCaseëëˆ á
)ëëá à
;ëëà â
}ëëä ã
publicíí 
sealed
íí 
class
íí 
TicketComment
íí !
{
íí" #
public
íí$ *
Guid
íí+ /
Id
íí0 2
{
íí3 4
get
íí5 8
;
íí8 9
set
íí: =
;
íí= >
}
íí? @
=
ííA B
Guid
ííC G
.
ííG H
NewGuid
ííH O
(
ííO P
)
ííP Q
;
ííQ R
public
ííS Y
Guid
ííZ ^
TicketId
íí_ g
{
ííh i
get
ííj m
;
íím n
set
íío r
;
íír s
}
íít u
public
íív |
Guidíí} Å
?ííÅ Ç
AuthorUserIdííÉ è
{ííê ë
getííí ï
;ííï ñ
setííó ö
;ííö õ
}ííú ù
publicííû §
stringíí• ´
Bodyíí¨ ∞
{íí± ≤
getíí≥ ∂
;íí∂ ∑
setíí∏ ª
;ííª º
}ííΩ æ
=ííø ¿
stringíí¡ «
.íí« »
Emptyíí» Õ
;ííÕ Œ
publicííœ ’
boolíí÷ ⁄

FromGithubíí€ Â
{ííÊ Á
getííË Î
;ííÎ Ï
setííÌ 
;íí Ò
}ííÚ Û
publicííÙ ˙
longíí˚ ˇ
?ííˇ Ä
GithubCommentIdííÅ ê
{ííë í
getííì ñ
;ííñ ó
setííò õ
;ííõ ú
}ííù û
publicííü •
stringíí¶ ¨
?íí¨ ≠!
GithubAuthorLoginííÆ ø
{íí¿ ¡
getíí¬ ≈
;íí≈ ∆
setíí«  
;íí  À
}ííÃ Õ
publicííŒ ‘
DateTimeíí’ ›
	CreatedAtííﬁ Á
{ííË È
getííÍ Ì
;ííÌ Ó
setííÔ Ú
;ííÚ Û
}ííÙ ı
=ííˆ ˜
DateTimeíí¯ Ä
.ííÄ Å
UtcNowííÅ á
;ííá à
}ííâ ä
publicîî 
sealed
îî 
class
îî  
PaymentTransaction
îî &
{
îî' (
public
îî) /
Guid
îî0 4
Id
îî5 7
{
îî8 9
get
îî: =
;
îî= >
set
îî? B
;
îîB C
}
îîD E
=
îîF G
Guid
îîH L
.
îîL M
NewGuid
îîM T
(
îîT U
)
îîU V
;
îîV W
public
îîX ^
Guid
îî_ c
ClientId
îîd l
{
îîm n
get
îîo r
;
îîr s
set
îît w
;
îîw x
}
îîy z
public
ïï 

Guid
ïï 
?
ïï 
ClientProductId
ïï  
{
ïï! "
get
ïï# &
;
ïï& '
set
ïï( +
;
ïï+ ,
}
ïï- .
public
ïï/ 5
string
ïï6 <+
PayPalOrderIdOrSubscriptionId
ïï= Z
{
ïï[ \
get
ïï] `
;
ïï` a
set
ïïb e
;
ïïe f
}
ïïg h
=
ïïi j
string
ïïk q
.
ïïq r
Empty
ïïr w
;
ïïw x
public
ïïy 
decimalïïÄ á
Amountïïà é
{ïïè ê
getïïë î
;ïïî ï
setïïñ ô
;ïïô ö
}ïïõ ú
publicïïù £
stringïï§ ™
Currencyïï´ ≥
{ïï¥ µ
getïï∂ π
;ïïπ ∫
setïïª æ
;ïïæ ø
}ïï¿ ¡
=ïï¬ √
$strïïƒ …
;ïï…  
publicïïÀ —
stringïï“ ÿ
StatusïïŸ ﬂ
{ïï‡ ·
getïï‚ Â
;ïïÂ Ê
setïïÁ Í
;ïïÍ Î
}ïïÏ Ì
=ïïÓ Ô
stringïï ˆ
.ïïˆ ˜
Emptyïï˜ ¸
;ïï¸ ˝
public
ññ 

string
ññ 
Method
ññ 
{
ññ 
get
ññ 
;
ññ 
set
ññ  #
;
ññ# $
}
ññ% &
=
ññ' (
PaymentMethods
ññ) 7
.
ññ7 8
PayPal
ññ8 >
;
ññ> ?
public
óó 

int
óó 
Years
óó 
{
óó 
get
óó 
;
óó 
set
óó 
;
óó  
}
óó! "
=
óó# $
$num
óó% &
;
óó& '
public
óó( .
decimal
óó/ 6
	AmountPen
óó7 @
{
óóA B
get
óóC F
;
óóF G
set
óóH K
;
óóK L
}
óóM N
public
óóO U
string
óóV \
?
óó\ ]
InternalCode
óó^ j
{
óók l
get
óóm p
;
óóp q
set
óór u
;
óóu v
}
óów x
public
óóy 
DateTimeóóÄ à
	CreatedAtóóâ í
{óóì î
getóóï ò
;óóò ô
setóóö ù
;óóù û
}óóü †
=óó° ¢
DateTimeóó£ ´
.óó´ ¨
UtcNowóó¨ ≤
;óó≤ ≥
publicóó¥ ∫
stringóóª ¡
?óó¡ ¬
Notesóó√ »
{óó…  
getóóÀ Œ
;óóŒ œ
setóó– ”
;óó” ‘
}óó’ ÷
}óó◊ ÿ
publicòò 
sealed
òò 
class
òò 
NotificationLog
òò #
{
òò$ %
public
òò& ,
Guid
òò- 1
Id
òò2 4
{
òò5 6
get
òò7 :
;
òò: ;
set
òò< ?
;
òò? @
}
òòA B
=
òòC D
Guid
òòE I
.
òòI J
NewGuid
òòJ Q
(
òòQ R
)
òòR S
;
òòS T
public
òòU [
Guid
òò\ `
ClientId
òòa i
{
òòj k
get
òòl o
;
òòo p
set
òòq t
;
òòt u
}
òòv w
public
òòx ~
stringòò Ö
TypeòòÜ ä
{òòã å
getòòç ê
;òòê ë
setòòí ï
;òòï ñ
}òòó ò
=òòô ö
stringòòõ °
.òò° ¢
Emptyòò¢ ß
;òòß ®
publicòò© Ø
stringòò∞ ∂
Channelòò∑ æ
{òòø ¿
getòò¡ ƒ
;òòƒ ≈
setòò∆ …
;òò…  
}òòÀ Ã
=òòÕ Œ
stringòòœ ’
.òò’ ÷
Emptyòò÷ €
;òò€ ‹
publicòò› „
DateTimeòò‰ Ï
SentAtòòÌ Û
{òòÙ ı
getòòˆ ˘
;òò˘ ˙
setòò˚ ˛
;òò˛ ˇ
}òòÄ Å
=òòÇ É
DateTimeòòÑ å
.òòå ç
UtcNowòòç ì
;òòì î
publicòòï õ
boolòòú †
Successòò° ®
{òò© ™
getòò´ Æ
;òòÆ Ø
setòò∞ ≥
;òò≥ ¥
}òòµ ∂
publicòò∑ Ω
stringòòæ ƒ
?òòƒ ≈
	Recipientòò∆ œ
{òò– —
getòò“ ’
;òò’ ÷
setòò◊ ⁄
;òò⁄ €
}òò‹ ›
publicòòﬁ ‰
stringòòÂ Î
?òòÎ Ï
	DedupeKeyòòÌ ˆ
{òò˜ ¯
getòò˘ ¸
;òò¸ ˝
setòò˛ Å
;òòÅ Ç
}òòÉ Ñ
publicòòÖ ã
stringòòå í
?òòí ì
Erroròòî ô
{òòö õ
getòòú ü
;òòü †
setòò° §
;òò§ •
}òò¶ ß
}òò® ©
publicõõ 
sealed
õõ 
class
õõ 
ExchangeRate
õõ  
{
õõ! "
public
õõ# )
Guid
õõ* .
Id
õõ/ 1
{
õõ2 3
get
õõ4 7
;
õõ7 8
set
õõ9 <
;
õõ< =
}
õõ> ?
=
õõ@ A
Guid
õõB F
.
õõF G
NewGuid
õõG N
(
õõN O
)
õõO P
;
õõP Q
public
õõR X
DateOnly
õõY a
Date
õõb f
{
õõg h
get
õõi l
;
õõl m
set
õõn q
;
õõq r
}
õõs t
public
õõu {
stringõõ| Ç
CurrencyCodeõõÉ è
{õõê ë
getõõí ï
;õõï ñ
setõõó ö
;õõö õ
}õõú ù
=õõû ü
stringõõ† ¶
.õõ¶ ß
Emptyõõß ¨
;õõ¨ ≠
publicõõÆ ¥
decimalõõµ º
	RateToPenõõΩ ∆
{õõ« »
getõõ… Ã
;õõÃ Õ
setõõŒ —
;õõ— “
}õõ” ‘
publicõõ’ €
stringõõ‹ ‚
Sourceõõ„ È
{õõÍ Î
getõõÏ Ô
;õõÔ 
setõõÒ Ù
;õõÙ ı
}õõˆ ˜
=õõ¯ ˘
stringõõ˙ Ä
.õõÄ Å
EmptyõõÅ Ü
;õõÜ á
}õõà â
publicûû 
sealed
ûû 
class
ûû 
TaxDocument
ûû 
{
ûû  !
public
ûû" (
Guid
ûû) -
Id
ûû. 0
{
ûû1 2
get
ûû3 6
;
ûû6 7
set
ûû8 ;
;
ûû; <
}
ûû= >
=
ûû? @
Guid
ûûA E
.
ûûE F
NewGuid
ûûF M
(
ûûM N
)
ûûN O
;
ûûO P
public
ûûQ W
Guid
ûûX \
?
ûû\ ]"
PaymentTransactionId
ûû^ r
{
ûûs t
get
ûûu x
;
ûûx y
set
ûûz }
;
ûû} ~
}ûû Ä
publicûûÅ á
Guidûûà å
ClientIdûûç ï
{ûûñ ó
getûûò õ
;ûûõ ú
setûûù †
;ûû† °
}ûû¢ £
publicûû§ ™
TaxDocumentTypeûû´ ∫
Typeûûª ø
{ûû¿ ¡
getûû¬ ≈
;ûû≈ ∆
setûû«  
;ûû  À
}ûûÃ Õ
publicûûŒ ‘
stringûû’ €
Seriesûû‹ ‚
{ûû„ ‰
getûûÂ Ë
;ûûË È
setûûÍ Ì
;ûûÌ Ó
}ûûÔ 
=ûûÒ Ú
stringûûÛ ˘
.ûû˘ ˙
Emptyûû˙ ˇ
;ûûˇ Ä
publicûûÅ á
intûûà ã
Numberûûå í
{ûûì î
getûûï ò
;ûûò ô
setûûö ù
;ûûù û
}ûûü †
publicûû° ß
DateOnlyûû® ∞
	IssueDateûû± ∫
{ûûª º
getûûΩ ¿
;ûû¿ ¡
setûû¬ ≈
;ûû≈ ∆
}ûû« »
publicûû… œ
stringûû– ÷
Currencyûû◊ ﬂ
{ûû‡ ·
getûû‚ Â
;ûûÂ Ê
setûûÁ Í
;ûûÍ Î
}ûûÏ Ì
=ûûÓ Ô
$strûû ı
;ûûı ˆ
publicûû˜ ˝
decimalûû˛ Ö

BaseAmountûûÜ ê
{ûûë í
getûûì ñ
;ûûñ ó
setûûò õ
;ûûõ ú
}ûûù û
publicûûü •
decimalûû¶ ≠
	IgvAmountûûÆ ∑
{ûû∏ π
getûû∫ Ω
;ûûΩ æ
setûûø ¬
;ûû¬ √
}ûûƒ ≈
publicûû∆ Ã
decimalûûÕ ‘
TotalAmountûû’ ‡
{ûû· ‚
getûû„ Ê
;ûûÊ Á
setûûË Î
;ûûÎ Ï
}ûûÌ Ó
publicûûÔ ı
stringûûˆ ¸
?ûû¸ ˝
Notesûû˛ É
{ûûÑ Ö
getûûÜ â
;ûûâ ä
setûûã é
;ûûé è
}ûûê ë
public
üü 

decimal
üü 
?
üü 
RetentionAmount
üü #
{
üü$ %
get
üü& )
;
üü) *
set
üü+ .
;
üü. /
}
üü0 1
}
üü2 3
public•• 
sealed
•• 
class
•• 
PaymentReversal
•• #
{
••$ %
public
••& ,
Guid
••- 1
Id
••2 4
{
••5 6
get
••7 :
;
••: ;
set
••< ?
;
••? @
}
••A B
=
••C D
Guid
••E I
.
••I J
NewGuid
••J Q
(
••Q R
)
••R S
;
••S T
public
••U [
Guid
••\ `
ClientId
••a i
{
••j k
get
••l o
;
••o p
set
••q t
;
••t u
}
••v w
public
••x ~
Guid•• É
?••É Ñ
ClientProductId••Ö î
{••ï ñ
get••ó ö
;••ö õ
set••ú ü
;••ü †
}••° ¢
public
¶¶ 

string
¶¶ 
?
¶¶ 

PaymentKey
¶¶ 
{
¶¶ 
get
¶¶  #
;
¶¶# $
set
¶¶% (
;
¶¶( )
}
¶¶* +
public
¶¶, 2
string
¶¶3 9
?
¶¶9 :
Method
¶¶; A
{
¶¶B C
get
¶¶D G
;
¶¶G H
set
¶¶I L
;
¶¶L M
}
¶¶N O
public
¶¶P V
string
¶¶W ]
?
¶¶] ^
InternalCode
¶¶_ k
{
¶¶l m
get
¶¶n q
;
¶¶q r
set
¶¶s v
;
¶¶v w
}
¶¶x y
public¶¶z Ä
decimal¶¶Å à
Amount¶¶â è
{¶¶ê ë
get¶¶í ï
;¶¶ï ñ
set¶¶ó ö
;¶¶ö õ
}¶¶ú ù
public¶¶û §
string¶¶• ´
Currency¶¶¨ ¥
{¶¶µ ∂
get¶¶∑ ∫
;¶¶∫ ª
set¶¶º ø
;¶¶ø ¿
}¶¶¡ ¬
=¶¶√ ƒ
$str¶¶≈  
;¶¶  À
public¶¶Ã “
decimal¶¶” ⁄
?¶¶⁄ €
	AmountPen¶¶‹ Â
{¶¶Ê Á
get¶¶Ë Î
;¶¶Î Ï
set¶¶Ì 
;¶¶ Ò
}¶¶Ú Û
public¶¶Ù ˙
DateTime¶¶˚ É
?¶¶É Ñ
PaidAt¶¶Ö ã
{¶¶å ç
get¶¶é ë
;¶¶ë í
set¶¶ì ñ
;¶¶ñ ó
}¶¶ò ô
public
ßß 

TaxDocumentType
ßß 
DocumentType
ßß '
{
ßß( )
get
ßß* -
;
ßß- .
set
ßß/ 2
;
ßß2 3
}
ßß4 5
public
ßß6 <
string
ßß= C
Series
ßßD J
{
ßßK L
get
ßßM P
;
ßßP Q
set
ßßR U
;
ßßU V
}
ßßW X
=
ßßY Z
string
ßß[ a
.
ßßa b
Empty
ßßb g
;
ßßg h
public
ßßi o
int
ßßp s
Number
ßßt z
{
ßß{ |
getßß} Ä
;ßßÄ Å
setßßÇ Ö
;ßßÖ Ü
}ßßá à
publicßßâ è
DateOnlyßßê ò
	IssueDateßßô ¢
{ßß£ §
getßß• ®
;ßß® ©
setßß™ ≠
;ßß≠ Æ
}ßßØ ∞
public
®® 

string
®® 
Reason
®® 
{
®® 
get
®® 
;
®® 
set
®®  #
;
®®# $
}
®®% &
=
®®' (
string
®®) /
.
®®/ 0
Empty
®®0 5
;
®®5 6
public
©© 

bool
©© 
	NotIssued
©© 
{
©© 
get
©© 
;
©©  
set
©©! $
;
©©$ %
}
©©& '
public
©©( .
bool
©©/ 3
NumberReleased
©©4 B
{
©©C D
get
©©E H
;
©©H I
set
©©J M
;
©©M N
}
©©O P
public
©©Q W
Guid
©©X \
?
©©\ ]
ReversedByUserId
©©^ n
{
©©o p
get
©©q t
;
©©t u
set
©©v y
;
©©y z
}
©©{ |
public©©} É
DateTime©©Ñ å

ReversedAt©©ç ó
{©©ò ô
get©©ö ù
;©©ù û
set©©ü ¢
;©©¢ £
}©©§ •
=©©¶ ß
DateTime©©® ∞
.©©∞ ±
UtcNow©©± ∑
;©©∑ ∏
}©©π ∫
public¨¨ 
sealed
¨¨ 
class
¨¨ 
TaxDocumentLine
¨¨ #
{
¨¨$ %
public
¨¨& ,
Guid
¨¨- 1
Id
¨¨2 4
{
¨¨5 6
get
¨¨7 :
;
¨¨: ;
set
¨¨< ?
;
¨¨? @
}
¨¨A B
=
¨¨C D
Guid
¨¨E I
.
¨¨I J
NewGuid
¨¨J Q
(
¨¨Q R
)
¨¨R S
;
¨¨S T
public
¨¨U [
Guid
¨¨\ `
TaxDocumentId
¨¨a n
{
¨¨o p
get
¨¨q t
;
¨¨t u
set
¨¨v y
;
¨¨y z
}
¨¨{ |
public¨¨} É
Guid¨¨Ñ à
?¨¨à â
ClientProductId¨¨ä ô
{¨¨ö õ
get¨¨ú ü
;¨¨ü †
set¨¨° §
;¨¨§ •
}¨¨¶ ß
public¨¨® Æ
string¨¨Ø µ
Description¨¨∂ ¡
{¨¨¬ √
get¨¨ƒ «
;¨¨« »
set¨¨… Ã
;¨¨Ã Õ
}¨¨Œ œ
=¨¨– —
string¨¨“ ÿ
.¨¨ÿ Ÿ
Empty¨¨Ÿ ﬁ
;¨¨ﬁ ﬂ
public¨¨‡ Ê
decimal¨¨Á Ó
Amount¨¨Ô ı
{¨¨ˆ ˜
get¨¨¯ ˚
;¨¨˚ ¸
set¨¨˝ Ä
;¨¨Ä Å
}¨¨Ç É
public¨¨Ñ ä
int¨¨ã é
Order¨¨è î
{¨¨ï ñ
get¨¨ó ö
;¨¨ö õ
set¨¨ú ü
;¨¨ü †
}¨¨° ¢
}¨¨£ §
publicÆÆ 
sealed
ÆÆ 
class
ÆÆ 
Expense
ÆÆ 
{
ÆÆ 
public
ÆÆ $
Guid
ÆÆ% )
Id
ÆÆ* ,
{
ÆÆ- .
get
ÆÆ/ 2
;
ÆÆ2 3
set
ÆÆ4 7
;
ÆÆ7 8
}
ÆÆ9 :
=
ÆÆ; <
Guid
ÆÆ= A
.
ÆÆA B
NewGuid
ÆÆB I
(
ÆÆI J
)
ÆÆJ K
;
ÆÆK L
public
ÆÆM S
string
ÆÆT Z
Description
ÆÆ[ f
{
ÆÆg h
get
ÆÆi l
;
ÆÆl m
set
ÆÆn q
;
ÆÆq r
}
ÆÆs t
=
ÆÆu v
string
ÆÆw }
.
ÆÆ} ~
EmptyÆÆ~ É
;ÆÆÉ Ñ
publicÆÆÖ ã
GuidÆÆå ê

CategoryIdÆÆë õ
{ÆÆú ù
getÆÆû °
;ÆÆ° ¢
setÆÆ£ ¶
;ÆÆ¶ ß
}ÆÆ® ©
publicÆÆ™ ∞
ExpenseCategoryÆÆ± ¿
?ÆÆ¿ ¡
CategoryÆÆ¬  
{ÆÆÀ Ã
getÆÆÕ –
;ÆÆ– —
setÆÆ“ ’
;ÆÆ’ ÷
}ÆÆ◊ ÿ
publicÆÆŸ ﬂ
ExpenseTypeÆÆ‡ Î
TypeÆÆÏ 
{ÆÆÒ Ú
getÆÆÛ ˆ
;ÆÆˆ ˜
setÆÆ¯ ˚
;ÆÆ˚ ¸
}ÆÆ˝ ˛
publicÆÆˇ Ö
decimalÆÆÜ ç
AmountÆÆé î
{ÆÆï ñ
getÆÆó ö
;ÆÆö õ
setÆÆú ü
;ÆÆü †
}ÆÆ° ¢
publicÆÆ£ ©
stringÆÆ™ ∞
CurrencyÆÆ± π
{ÆÆ∫ ª
getÆÆº ø
;ÆÆø ¿
setÆÆ¡ ƒ
;ÆÆƒ ≈
}ÆÆ∆ «
=ÆÆ» …
$strÆÆ  œ
;ÆÆœ –
publicÆÆ— ◊
decimalÆÆÿ ﬂ
	AmountPenÆÆ‡ È
{ÆÆÍ Î
getÆÆÏ Ô
;ÆÆÔ 
setÆÆÒ Ù
;ÆÆÙ ı
}ÆÆˆ ˜
publicÆÆ¯ ˛
DateOnlyÆÆˇ á
DateÆÆà å
{ÆÆç é
getÆÆè í
;ÆÆí ì
setÆÆî ó
;ÆÆó ò
}ÆÆô ö
publicÆÆõ °
boolÆÆ¢ ¶
	RecurringÆÆß ∞
{ÆÆ± ≤
getÆÆ≥ ∂
;ÆÆ∂ ∑
setÆÆ∏ ª
;ÆÆª º
}ÆÆΩ æ
publicÆÆø ≈
BillingCycleÆÆ∆ “
?ÆÆ“ ”
RecurrenceCycleÆÆ‘ „
{ÆÆ‰ Â
getÆÆÊ È
;ÆÆÈ Í
setÆÆÎ Ó
;ÆÆÓ Ô
}ÆÆ Ò
public
ØØ 
DateOnly
ØØ 
?
ØØ 
RecurrenceEndsAt
ØØ "
{
ØØ# $
get
ØØ% (
;
ØØ( )
set
ØØ* -
;
ØØ- .
}
ØØ/ 0
public
±± 

bool
±± 
IsNonDeductible
±± 
{
±±  !
get
±±" %
;
±±% &
set
±±' *
;
±±* +
}
±±, -
public
≥≥ 

bool
≥≥ #
IsNonDomiciledService
≥≥ %
{
≥≥& '
get
≥≥( +
;
≥≥+ ,
set
≥≥- 0
;
≥≥0 1
}
≥≥2 3
public
≥≥4 :
string
≥≥; A
?
≥≥A B!
ForeignSupplierName
≥≥C V
{
≥≥W X
get
≥≥Y \
;
≥≥\ ]
set
≥≥^ a
;
≥≥a b
}
≥≥c d
public
≥≥e k
string
≥≥l r
?
≥≥r s%
ForeignSupplierCountry≥≥t ä
{≥≥ã å
get≥≥ç ê
;≥≥ê ë
set≥≥í ï
;≥≥ï ñ
}≥≥ó ò
public
µµ 

DateOnly
µµ 
?
µµ 
Form1662PaidAt
µµ #
{
µµ$ %
get
µµ& )
;
µµ) *
set
µµ+ .
;
µµ. /
}
µµ0 1
public
µµ2 8
string
µµ9 ?
?
µµ? @
Form1662Number
µµA O
{
µµP Q
get
µµR U
;
µµU V
set
µµW Z
;
µµZ [
}
µµ\ ]
}
µµ^ _
public∏∏ 
sealed
∏∏ 
class
∏∏ 
TaxSettings
∏∏ 
{ππ 
public
∫∫ 

Guid
∫∫ 
Id
∫∫ 
{
∫∫ 
get
∫∫ 
;
∫∫ 
set
∫∫ 
;
∫∫ 
}
∫∫  
=
∫∫! "
Guid
∫∫# '
.
∫∫' (
NewGuid
∫∫( /
(
∫∫/ 0
)
∫∫0 1
;
∫∫1 2
public
∫∫3 9
decimal
∫∫: A
IgvRate
∫∫B I
{
∫∫J K
get
∫∫L O
;
∫∫O P
set
∫∫Q T
;
∫∫T U
}
∫∫V W
=
∫∫X Y
$num
∫∫Z _
;
∫∫_ `
public
∫∫a g
decimal
∫∫h o
	RentaRate
∫∫p y
{
∫∫z {
get
∫∫| 
;∫∫ Ä
set∫∫Å Ñ
;∫∫Ñ Ö
}∫∫Ü á
=∫∫à â
$num∫∫ä è
;∫∫è ê
public∫∫ë ó
DateTime∫∫ò †
	UpdatedAt∫∫° ™
{∫∫´ ¨
get∫∫≠ ∞
;∫∫∞ ±
set∫∫≤ µ
;∫∫µ ∂
}∫∫∑ ∏
=∫∫π ∫
DateTime∫∫ª √
.∫∫√ ƒ
UtcNow∫∫ƒ  
;∫∫  À
public
ΩΩ 

string
ΩΩ 
FacturaSeries
ΩΩ 
{
ΩΩ  !
get
ΩΩ" %
;
ΩΩ% &
set
ΩΩ' *
;
ΩΩ* +
}
ΩΩ, -
=
ΩΩ. /
$str
ΩΩ0 6
;
ΩΩ6 7
public
ΩΩ8 >
int
ΩΩ? B
FacturaNextNumber
ΩΩC T
{
ΩΩU V
get
ΩΩW Z
;
ΩΩZ [
set
ΩΩ\ _
;
ΩΩ_ `
}
ΩΩa b
=
ΩΩc d
$num
ΩΩe f
;
ΩΩf g
public
ææ 

string
ææ 
ReciboSeries
ææ 
{
ææ  
get
ææ! $
;
ææ$ %
set
ææ& )
;
ææ) *
}
ææ+ ,
=
ææ- .
$str
ææ/ 5
;
ææ5 6
public
ææ7 =
int
ææ> A
ReciboNextNumber
ææB R
{
ææS T
get
ææU X
;
ææX Y
set
ææZ ]
;
ææ] ^
}
ææ_ `
=
ææa b
$num
ææc d
;
ææd e
public
¿¿ 

string
¿¿ 
?
¿¿ 
Ruc
¿¿ 
{
¿¿ 
get
¿¿ 
;
¿¿ 
set
¿¿ !
;
¿¿! "
}
¿¿# $
public
¿¿% +
bool
¿¿, 0
IsGoodTaxpayer
¿¿1 ?
{
¿¿@ A
get
¿¿B E
;
¿¿E F
set
¿¿G J
;
¿¿J K
}
¿¿L M
public
¬¬ 

bool
¬¬ 
Use1662AsCredit
¬¬ 
{
¬¬  !
get
¬¬" %
;
¬¬% &
set
¬¬' *
;
¬¬* +
}
¬¬, -
}√√ 
public…… 
sealed
…… 
class
…… 
AnnualTaxSettings
…… %
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
ÀÀ3 9
int
ÀÀ: =
Year
ÀÀ> B
{
ÀÀC D
get
ÀÀE H
;
ÀÀH I
set
ÀÀJ M
;
ÀÀM N
}
ÀÀO P
public
ÀÀQ W
decimal
ÀÀX _
Uit
ÀÀ` c
{
ÀÀd e
get
ÀÀf i
;
ÀÀi j
set
ÀÀk n
;
ÀÀn o
}
ÀÀp q
public
ÃÃ 

decimal
ÃÃ 
ThresholdUits
ÃÃ  
{
ÃÃ! "
get
ÃÃ# &
;
ÃÃ& '
set
ÃÃ( +
;
ÃÃ+ ,
}
ÃÃ- .
=
ÃÃ/ 0
$num
ÃÃ1 4
;
ÃÃ4 5
public
ÃÃ6 <
decimal
ÃÃ= D
LowRate
ÃÃE L
{
ÃÃM N
get
ÃÃO R
;
ÃÃR S
set
ÃÃT W
;
ÃÃW X
}
ÃÃY Z
=
ÃÃ[ \
$num
ÃÃ] b
;
ÃÃb c
public
ÃÃd j
decimal
ÃÃk r
HighRate
ÃÃs {
{
ÃÃ| }
getÃÃ~ Å
;ÃÃÅ Ç
setÃÃÉ Ü
;ÃÃÜ á
}ÃÃà â
=ÃÃä ã
$numÃÃå í
;ÃÃí ì
}ÕÕ 
public‘‘ 
sealed
‘‘ 
class
‘‘ 

TaxDueDate
‘‘ 
{’’ 
public
÷÷ 

Guid
÷÷ 
Id
÷÷ 
{
÷÷ 
get
÷÷ 
;
÷÷ 
set
÷÷ 
;
÷÷ 
}
÷÷  
=
÷÷! "
Guid
÷÷# '
.
÷÷' (
NewGuid
÷÷( /
(
÷÷/ 0
)
÷÷0 1
;
÷÷1 2
public
ÿÿ 

DateOnly
ÿÿ 
Period
ÿÿ 
{
ÿÿ 
get
ÿÿ  
;
ÿÿ  !
set
ÿÿ" %
;
ÿÿ% &
}
ÿÿ' (
public
ŸŸ 

DateOnly
ŸŸ 
Digit0
ŸŸ 
{
ŸŸ 
get
ŸŸ  
;
ŸŸ  !
set
ŸŸ" %
;
ŸŸ% &
}
ŸŸ' (
public
ŸŸ) /
DateOnly
ŸŸ0 8
Digit1
ŸŸ9 ?
{
ŸŸ@ A
get
ŸŸB E
;
ŸŸE F
set
ŸŸG J
;
ŸŸJ K
}
ŸŸL M
public
ŸŸN T
DateOnly
ŸŸU ]

Digit2And3
ŸŸ^ h
{
ŸŸi j
get
ŸŸk n
;
ŸŸn o
set
ŸŸp s
;
ŸŸs t
}
ŸŸu v
public
ŸŸw }
DateOnlyŸŸ~ Ü

Digit4And5ŸŸá ë
{ŸŸí ì
getŸŸî ó
;ŸŸó ò
setŸŸô ú
;ŸŸú ù
}ŸŸû ü
publicŸŸ† ¶
DateOnlyŸŸß Ø

Digit6And7ŸŸ∞ ∫
{ŸŸª º
getŸŸΩ ¿
;ŸŸ¿ ¡
setŸŸ¬ ≈
;ŸŸ≈ ∆
}ŸŸ« »
publicŸŸ… œ
DateOnlyŸŸ– ÿ

Digit8And9ŸŸŸ „
{ŸŸ‰ Â
getŸŸÊ È
;ŸŸÈ Í
setŸŸÎ Ó
;ŸŸÓ Ô
}ŸŸ Ò
public
€€ 

DateOnly
€€ 
GoodTaxpayer
€€  
{
€€! "
get
€€# &
;
€€& '
set
€€( +
;
€€+ ,
}
€€- .
public
‹‹ 

DateTime
‹‹ 
?
‹‹ 
FiledAt
‹‹ 
{
‹‹ 
get
‹‹ "
;
‹‹" #
set
‹‹$ '
;
‹‹' (
}
‹‹) *
public
ﬁﬁ 

decimal
ﬁﬁ 
?
ﬁﬁ 
IgvPaid
ﬁﬁ 
{
ﬁﬁ 
get
ﬁﬁ !
;
ﬁﬁ! "
set
ﬁﬁ# &
;
ﬁﬁ& '
}
ﬁﬁ( )
public
ﬁﬁ* 0
decimal
ﬁﬁ1 8
?
ﬁﬁ8 9
	RentaPaid
ﬁﬁ: C
{
ﬁﬁD E
get
ﬁﬁF I
;
ﬁﬁI J
set
ﬁﬁK N
;
ﬁﬁN O
}
ﬁﬁP Q
public
·· 

DateOnly
·· 
?
·· 
DueFor
·· 
(
·· 
string
·· "
?
··" #
ruc
··$ '
,
··' (
bool
··) -
goodTaxpayer
··. :
)
··: ;
{
‚‚ 
if
„„ 

(
„„ 
goodTaxpayer
„„ 
)
„„ 
return
„„  
GoodTaxpayer
„„! -
;
„„- .
if
‰‰ 

(
‰‰ 
string
‰‰ 
.
‰‰  
IsNullOrWhiteSpace
‰‰ %
(
‰‰% &
ruc
‰‰& )
)
‰‰) *
||
‰‰+ -
!
‰‰. /
char
‰‰/ 3
.
‰‰3 4
IsAsciiDigit
‰‰4 @
(
‰‰@ A
ruc
‰‰A D
.
‰‰D E
Trim
‰‰E I
(
‰‰I J
)
‰‰J K
[
‰‰K L
^
‰‰L M
$num
‰‰M N
]
‰‰N O
)
‰‰O P
)
‰‰P Q
return
‰‰R X
null
‰‰Y ]
;
‰‰] ^
return
ÂÂ 
(
ÂÂ 
ruc
ÂÂ 
.
ÂÂ 
Trim
ÂÂ 
(
ÂÂ 
)
ÂÂ 
[
ÂÂ 
^
ÂÂ 
$num
ÂÂ 
]
ÂÂ 
-
ÂÂ  
$char
ÂÂ! $
)
ÂÂ$ %
switch
ÂÂ& ,
{
ÂÂ- .
$num
ÂÂ/ 0
=>
ÂÂ1 3
Digit0
ÂÂ4 :
,
ÂÂ: ;
$num
ÂÂ< =
=>
ÂÂ> @
Digit1
ÂÂA G
,
ÂÂG H
$num
ÂÂI J
or
ÂÂK M
$num
ÂÂN O
=>
ÂÂP R

Digit2And3
ÂÂS ]
,
ÂÂ] ^
$num
ÂÂ_ `
or
ÂÂa c
$num
ÂÂd e
=>
ÂÂf h

Digit4And5
ÂÂi s
,
ÂÂs t
$num
ÂÂu v
or
ÂÂw y
$num
ÂÂz {
=>
ÂÂ| ~

Digit6And7ÂÂ â
,ÂÂâ ä
_ÂÂã å
=>ÂÂç è

Digit8And9ÂÂê ö
}ÂÂõ ú
;ÂÂú ù
}
ÊÊ 
}ÁÁ 
publicÌÌ 
static
ÌÌ 
class
ÌÌ 
TaxDueDateSeed
ÌÌ "
{ÓÓ 
public
ÔÔ 

static
ÔÔ 

TaxDueDate
ÔÔ 
[
ÔÔ 
]
ÔÔ 
Rows2026
ÔÔ '
=>
ÔÔ( *
Rows
ÔÔ+ /
(
ÔÔ/ 0
$num
ÔÔ0 4
,
ÔÔ4 5
[
 
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
(
ÚÚ 	
$str
ÚÚ	 
,
ÚÚ 
$str
ÚÚ #
,
ÚÚ# $
$str
ÚÚ% 1
,
ÚÚ1 2
$str
ÚÚ3 ?
,
ÚÚ? @
$str
ÚÚA M
,
ÚÚM N
$str
ÚÚO [
,
ÚÚ[ \
$str
ÚÚ] i
)
ÚÚi j
,
ÚÚj k
(
ÛÛ 	
$str
ÛÛ	 
,
ÛÛ 
$str
ÛÛ #
,
ÛÛ# $
$str
ÛÛ% 1
,
ÛÛ1 2
$str
ÛÛ3 ?
,
ÛÛ? @
$str
ÛÛA M
,
ÛÛM N
$str
ÛÛO [
,
ÛÛ[ \
$str
ÛÛ] i
)
ÛÛi j
,
ÛÛj k
(
ÙÙ 	
$str
ÙÙ	 
,
ÙÙ 
$str
ÙÙ #
,
ÙÙ# $
$str
ÙÙ% 1
,
ÙÙ1 2
$str
ÙÙ3 ?
,
ÙÙ? @
$str
ÙÙA M
,
ÙÙM N
$str
ÙÙO [
,
ÙÙ[ \
$str
ÙÙ] i
)
ÙÙi j
,
ÙÙj k
(
ıı 	
$str
ıı	 
,
ıı 
$str
ıı #
,
ıı# $
$str
ıı% 1
,
ıı1 2
$str
ıı3 ?
,
ıı? @
$str
ııA M
,
ııM N
$str
ııO [
,
ıı[ \
$str
ıı] i
)
ııi j
,
ııj k
(
ˆˆ 	
$str
ˆˆ	 
,
ˆˆ 
$str
ˆˆ #
,
ˆˆ# $
$str
ˆˆ% 1
,
ˆˆ1 2
$str
ˆˆ3 ?
,
ˆˆ? @
$str
ˆˆA M
,
ˆˆM N
$str
ˆˆO [
,
ˆˆ[ \
$str
ˆˆ] i
)
ˆˆi j
,
ˆˆj k
(
˜˜ 	
$str
˜˜	 
,
˜˜ 
$str
˜˜ #
,
˜˜# $
$str
˜˜% 1
,
˜˜1 2
$str
˜˜3 ?
,
˜˜? @
$str
˜˜A M
,
˜˜M N
$str
˜˜O [
,
˜˜[ \
$str
˜˜] i
)
˜˜i j
,
˜˜j k
(
¯¯ 	
$str
¯¯	 
,
¯¯ 
$str
¯¯ #
,
¯¯# $
$str
¯¯% 1
,
¯¯1 2
$str
¯¯3 ?
,
¯¯? @
$str
¯¯A M
,
¯¯M N
$str
¯¯O [
,
¯¯[ \
$str
¯¯] i
)
¯¯i j
,
¯¯j k
(
˘˘ 	
$str
˘˘	 
,
˘˘ 
$str
˘˘ #
,
˘˘# $
$str
˘˘% 1
,
˘˘1 2
$str
˘˘3 ?
,
˘˘? @
$str
˘˘A M
,
˘˘M N
$str
˘˘O [
,
˘˘[ \
$str
˘˘] i
)
˘˘i j
,
˘˘j k
(
˙˙ 	
$str
˙˙	 
,
˙˙ 
$str
˙˙ #
,
˙˙# $
$str
˙˙% 1
,
˙˙1 2
$str
˙˙3 ?
,
˙˙? @
$str
˙˙A M
,
˙˙M N
$str
˙˙O [
,
˙˙[ \
$str
˙˙] i
)
˙˙i j
,
˙˙j k
(
˚˚ 	
$str
˚˚	 
,
˚˚ 
$str
˚˚ #
,
˚˚# $
$str
˚˚% 1
,
˚˚1 2
$str
˚˚3 ?
,
˚˚? @
$str
˚˚A M
,
˚˚M N
$str
˚˚O [
,
˚˚[ \
$str
˚˚] i
)
˚˚i j
,
˚˚j k
(
¸¸ 	
$str
¸¸	 
,
¸¸ 
$str
¸¸ #
,
¸¸# $
$str
¸¸% 1
,
¸¸1 2
$str
¸¸3 ?
,
¸¸? @
$str
¸¸A M
,
¸¸M N
$str
¸¸O [
,
¸¸[ \
$str
¸¸] i
)
¸¸i j
,
¸¸j k
]
˝˝ 
)
˝˝ 
;
˝˝ 
private
ˇˇ 
static
ˇˇ 

TaxDueDate
ˇˇ 
[
ˇˇ 
]
ˇˇ 
Rows
ˇˇ  $
(
ˇˇ$ %
int
ˇˇ% (
year
ˇˇ) -
,
ˇˇ- .
(
ˇˇ/ 0
string
ˇˇ0 6
,
ˇˇ6 7
string
ˇˇ8 >
,
ˇˇ> ?
string
ˇˇ@ F
,
ˇˇF G
string
ˇˇH N
,
ˇˇN O
string
ˇˇP V
,
ˇˇV W
string
ˇˇX ^
,
ˇˇ^ _
string
ˇˇ` f
)
ˇˇf g
[
ˇˇg h
]
ˇˇh i
months
ˇˇj p
)
ˇˇp q
=>
ˇˇr t
months
ˇˇu {
.
ˇˇ{ |
Selectˇˇ| Ç
(ˇˇÇ É
(ˇˇÉ Ñ
mˇˇÑ Ö
,ˇˇÖ Ü
iˇˇá à
)ˇˇà â
=>ˇˇä å
newˇˇç ê

TaxDueDateˇˇë õ
{
ÄÄ 
Id
ÇÇ 

=
ÇÇ 
new
ÇÇ 
Guid
ÇÇ 
(
ÇÇ 
$"
ÇÇ 
$str
ÇÇ 0
{
ÇÇ0 1
year
ÇÇ1 5
:
ÇÇ5 6
$str
ÇÇ6 8
}
ÇÇ8 9
{
ÇÇ9 :
i
ÇÇ: ;
+
ÇÇ< =
$num
ÇÇ> ?
:
ÇÇ? @
$str
ÇÇ@ B
}
ÇÇB C
"
ÇÇC D
)
ÇÇD E
,
ÇÇE F
Period
ÇÇG M
=
ÇÇN O
new
ÇÇP S
DateOnly
ÇÇT \
(
ÇÇ\ ]
year
ÇÇ] a
,
ÇÇa b
i
ÇÇc d
+
ÇÇe f
$num
ÇÇg h
,
ÇÇh i
$num
ÇÇj k
)
ÇÇk l
,
ÇÇl m
Digit0
ÉÉ 
=
ÉÉ 
DateOnly
ÉÉ 
.
ÉÉ 
Parse
ÉÉ 
(
ÉÉ  
m
ÉÉ  !
.
ÉÉ! "
Item1
ÉÉ" '
)
ÉÉ' (
,
ÉÉ( )
Digit1
ÉÉ* 0
=
ÉÉ1 2
DateOnly
ÉÉ3 ;
.
ÉÉ; <
Parse
ÉÉ< A
(
ÉÉA B
m
ÉÉB C
.
ÉÉC D
Item2
ÉÉD I
)
ÉÉI J
,
ÉÉJ K

Digit2And3
ÉÉL V
=
ÉÉW X
DateOnly
ÉÉY a
.
ÉÉa b
Parse
ÉÉb g
(
ÉÉg h
m
ÉÉh i
.
ÉÉi j
Item3
ÉÉj o
)
ÉÉo p
,
ÉÉp q

Digit4And5
ÉÉr |
=
ÉÉ} ~
DateOnlyÉÉ á
.ÉÉá à
ParseÉÉà ç
(ÉÉç é
mÉÉé è
.ÉÉè ê
Item4ÉÉê ï
)ÉÉï ñ
,ÉÉñ ó

Digit6And7
ÑÑ 
=
ÑÑ 
DateOnly
ÑÑ 
.
ÑÑ 
Parse
ÑÑ #
(
ÑÑ# $
m
ÑÑ$ %
.
ÑÑ% &
Item5
ÑÑ& +
)
ÑÑ+ ,
,
ÑÑ, -

Digit8And9
ÑÑ. 8
=
ÑÑ9 :
DateOnly
ÑÑ; C
.
ÑÑC D
Parse
ÑÑD I
(
ÑÑI J
m
ÑÑJ K
.
ÑÑK L
Item6
ÑÑL Q
)
ÑÑQ R
,
ÑÑR S
GoodTaxpayer
ÑÑT `
=
ÑÑa b
DateOnly
ÑÑc k
.
ÑÑk l
Parse
ÑÑl q
(
ÑÑq r
m
ÑÑr s
.
ÑÑs t
Item7
ÑÑt y
)
ÑÑy z
,
ÑÑz {
}
ÖÖ 
)
ÖÖ 
.
ÖÖ 
ToArray
ÖÖ 
(
ÖÖ 
)
ÖÖ 
;
ÖÖ 
}ÜÜ 
publicåå 
sealed
åå 
class
åå  
PortalNotification
åå &
{
åå' (
public
åå) /
Guid
åå0 4
Id
åå5 7
{
åå8 9
get
åå: =
;
åå= >
set
åå? B
;
ååB C
}
ååD E
=
ååF G
Guid
ååH L
.
ååL M
NewGuid
ååM T
(
ååT U
)
ååU V
;
ååV W
public
ååX ^
Guid
åå_ c
ClientId
ååd l
{
ååm n
get
ååo r
;
åår s
set
ååt w
;
ååw x
}
ååy z
publicåå{ Å
stringååÇ à
Typeååâ ç
{ååé è
getååê ì
;ååì î
setååï ò
;ååò ô
}ååö õ
=ååú ù
stringååû §
.åå§ •
Emptyåå• ™
;åå™ ´
publicåå¨ ≤
boolåå≥ ∑
ForStaffåå∏ ¿
{åå¡ ¬
getåå√ ∆
;åå∆ «
setåå» À
;ååÀ Ã
}ååÕ Œ
publicååœ ’
stringåå÷ ‹
DataJsonåå› Â
{ååÊ Á
getååË Î
;ååÎ Ï
setååÌ 
;åå Ò
}ååÚ Û
=ååÙ ı
$strååˆ ˙
;åå˙ ˚
publicåå¸ Ç
stringååÉ â
?ååâ ä
	DedupeKeyååã î
{ååï ñ
getååó ö
;ååö õ
setååú ü
;ååü †
}åå° ¢
publicåå£ ©
DateTimeåå™ ≤
	CreatedAtåå≥ º
{ååΩ æ
getååø ¬
;åå¬ √
setååƒ «
;åå« »
}åå…  
=ååÀ Ã
DateTimeååÕ ’
.åå’ ÷
UtcNowåå÷ ‹
;åå‹ ›
}ååﬁ ﬂﬂ\
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