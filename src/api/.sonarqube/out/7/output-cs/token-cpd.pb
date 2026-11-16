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
}^^ £ë
8C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Entities.cs
	namespace 	
Rtres
 
. 
Domain 
; 
public 
enum 
UserRole 
{ 
Admin 
, 
Cliente %
,% &

SuperAdmin' 1
}2 3
public 
enum 
ProductType 
{ 
Hosting !
,! "
Dominio# *
,* +
Ssl, /
,/ 0
BackupBd1 9
,9 :
SoporteMensual; I
,I J
DesarrolloWebK X
}Y Z
public 
enum 
BillingCycle 
{ 
Unico  
,  !
Mensual" )
,) *
Anual+ 0
,0 1
	Bimestral2 ;
,; <

Trimestral= G
,G H
	SemestralI R
}S T
public 
static 
class 
BillingCycles !
{		 
public 

static 
int 
Months 
( 
this !
BillingCycle" .
cycle/ 4
)4 5
=>6 8
cycle9 >
==? A
BillingCycleB N
.N O
AnualO T
?U V
$numW Y
:Z [
cycle\ a
.a b
SubscriptionMonthsb t
(t u
)u v
??w y
throwz 
new
Ä É)
ArgumentOutOfRangeException
Ñ ü
(
ü †
nameof
† ¶
(
¶ ß
cycle
ß ¨
)
¨ ≠
,
≠ Æ
$str
Ø Ã
)
Ã Õ
;
Õ Œ
public 

static 
int 
? 
SubscriptionMonths )
() *
this* .
BillingCycle/ ;
cycle< A
)A B
=>C E
cycleF K
switchL R
{S T
BillingCycleU a
.a b
Mensualb i
=>j l
$numm n
,n o
BillingCyclep |
.| }
	Bimestral	} Ü
=>
á â
$num
ä ã
,
ã å
BillingCycle
ç ô
.
ô ö

Trimestral
ö §
=>
• ß
$num
® ©
,
© ™
BillingCycle
´ ∑
.
∑ ∏
	Semestral
∏ ¡
=>
¬ ƒ
$num
≈ ∆
,
∆ «
_
» …
=>
  Ã
null
Õ —
}
“ ”
;
” ‘
public 

static 
bool 
IsSubscription %
(% &
this& *
BillingCycle+ 7
cycle8 =
)= >
=>? A
cycleB G
.G H
SubscriptionMonthsH Z
(Z [
)[ \
is] _
not` c
nulld h
;h i
} 
public 
enum 
ClientProductStatus 
{  !
Activo" (
,( )
	PorVencer* 3
,3 4
Vencido5 <
,< =
	Cancelado> G
,G H
	PendienteI R
}S T
public 
enum 

TicketType 
{ 
Bug 
, 
Funcionalidad +
,+ ,
Requerimiento- :
}; <
public 
enum 
TicketStatus 
{ 
Abierto "
," #

EnProgreso$ .
,. /
Resuelto0 8
,8 9
	Publicado: C
,C D
CerradoE L
}M N
public 
enum 
TaxDocumentType 
{ 
Factura %
,% &
ReciboPorHonorarios' :
}; <
public 
static 
class 
PaymentMethods "
{# $
public% +
const, 1
string2 8
PayPal9 ?
=@ A
$strB J
;J K
publicL R
constS X
stringY _
Transferencia` m
=n o
$strp 
;	 Ä
public 

const 
string 
Remesa 
=  
$str! )
;) *
}+ ,
public 
enum 
ExpenseType 
{ 
Fijo 
, 
Variable  (
}) *
public 
sealed 
class 
ExpenseCategory #
{$ %
public& ,
Guid- 1
Id2 4
{5 6
get7 :
;: ;
set< ?
;? @
}A B
=C D
GuidE I
.I J
NewGuidJ Q
(Q R
)R S
;S T
publicU [
string\ b
Namec g
{h i
getj m
;m n
seto r
;r s
}t u
=v w
stringx ~
.~ 
Empty	 Ñ
;
Ñ Ö
public 
string 
? 
Code 
{ 
get 
; 
set 
;  
}! "
public 
bool 
IsIncomeTax 
{ 
get 
; 
set  #
;# $
}% &
public' -
int. 1
	SortOrder2 ;
{< =
get> A
;A B
setC F
;F G
}H I
public 

bool 
IsDeductible 
{ 
get "
;" #
set$ '
;' (
}) *
=+ ,
true- 1
;1 2
}3 4
public 
static 
class 
ExpenseCategoryIds &
{   
public!! 

static!! 
readonly!! 
Guid!! 
Hosting!!  '
=!!( )
new!!* -
(!!- .
$str!!. T
)!!T U
;!!U V
public"" 

static"" 
readonly"" 
Guid"" 
Dominios""  (
="") *
new""+ .
("". /
$str""/ U
)""U V
;""V W
public## 

static## 
readonly## 
Guid## 
SuscripcionesIA##  /
=##0 1
new##2 5
(##5 6
$str##6 \
)##\ ]
;##] ^
public$$ 

static$$ 
readonly$$ 
Guid$$ 

ApisPorUso$$  *
=$$+ ,
new$$- 0
($$0 1
$str$$1 W
)$$W X
;$$X Y
public%% 

static%% 
readonly%% 
Guid%% 
Sueldos%%  '
=%%( )
new%%* -
(%%- .
$str%%. T
)%%T U
;%%U V
public&& 

static&& 
readonly&& 
Guid&& 
Otros&&  %
=&&& '
new&&( +
(&&+ ,
$str&&, R
)&&R S
;&&S T
public'' 

static'' 
readonly'' 
Guid'' 
ImpuestoRenta''  -
=''. /
new''0 3
(''3 4
$str''4 Z
)''Z [
;''[ \
public(( 

static(( 
readonly(( 
Guid(( 

Comisiones((  *
=((+ ,
new((- 0
(((0 1
$str((1 W
)((W X
;((X Y
public** 

static** 
IReadOnlyList** 
<**  
ExpenseCategory**  /
>**/ 0
Seed**1 5
=>**6 8
[++ 
new,, 
(,, 
),, 
{,, 
Id,, 
=,, 
Hosting,, 
,,, 
Code,, "
=,,# $
$str,,% .
,,,. /
Name,,0 4
=,,5 6
$str,,7 @
,,,@ A
	SortOrder,,B K
=,,L M
$num,,N O
},,P Q
,,,Q R
new-- 
(-- 
)-- 
{-- 
Id-- 
=-- 
Dominios-- 
,-- 
Code-- #
=--$ %
$str--& 0
,--0 1
Name--2 6
=--7 8
$str--9 C
,--C D
	SortOrder--E N
=--O P
$num--Q R
}--S T
,--T U
new.. 
(.. 
).. 
{.. 
Id.. 
=.. 
SuscripcionesIA.. $
,..$ %
Code..& *
=..+ ,
$str..- >
,..> ?
Name..@ D
=..E F
$str..G Y
,..Y Z
	SortOrder..[ d
=..e f
$num..g h
}..i j
,..j k
new// 
(// 
)// 
{// 
Id// 
=// 

ApisPorUso// 
,//  
Code//! %
=//& '
$str//( 4
,//4 5
Name//6 :
=//; <
$str//= K
,//K L
	SortOrder//M V
=//W X
$num//Y Z
}//[ \
,//\ ]
new00 
(00 
)00 
{00 
Id00 
=00 
Sueldos00 
,00 
Code00 "
=00# $
$str00% .
,00. /
Name000 4
=005 6
$str007 @
,00@ A
	SortOrder00B K
=00L M
$num00N O
}00P Q
,00Q R
new11 
(11 
)11 
{11 
Id11 
=11 
Otros11 
,11 
Code11  
=11! "
$str11# *
,11* +
Name11, 0
=111 2
$str113 :
,11: ;
	SortOrder11< E
=11F G
$num11H I
}11J K
,11K L
new22 
(22 
)22 
{22 
Id22 
=22 
ImpuestoRenta22 "
,22" #
Code22$ (
=22) *
$str22+ :
,22: ;
Name22< @
=22A B
$str22C X
,22X Y
IsIncomeTax22Z e
=22f g
true22h l
,22l m
	SortOrder22n w
=22x y
$num22z {
}22| }
,22} ~
new33 
(33 
)33 
{33 
Id33 
=33 

Comisiones33 
,33  
Code33! %
=33& '
$str33( 4
,334 5
Name336 :
=33; <
$str33= I
,33I J
	SortOrder33K T
=33U V
$num33W X
}33Y Z
,33Z [
]44 
;44 
}55 
public77 
enum77  
PurchaseDocumentType77  
{77! "
Factura77# *
,77* +
NotaCredito77, 7
,777 8

NotaDebito779 C
,77C D
Boleta77E K
,77K L
ReciboPorHonorarios77M `
,77` a

Extranjero77b l
,77l m
Otro77n r
}77s t
public>> 
sealed>> 
class>> 
Purchase>> 
{?? 
public@@ 

Guid@@ 
Id@@ 
{@@ 
get@@ 
;@@ 
set@@ 
;@@ 
}@@  
=@@! "
Guid@@# '
.@@' (
NewGuid@@( /
(@@/ 0
)@@0 1
;@@1 2
publicAA 

DateOnlyAA 
	IssueDateAA 
{AA 
getAA  #
;AA# $
setAA% (
;AA( )
}AA* +
publicCC 

DateOnlyCC 
PeriodCC 
{CC 
getCC  
;CC  !
setCC" %
;CC% &
}CC' (
publicDD 
 
PurchaseDocumentTypeDD 
DocumentTypeDD  ,
{DD- .
getDD/ 2
;DD2 3
setDD4 7
;DD7 8
}DD9 :
publicEE 

stringEE 
SeriesEE 
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
stringFF 
NumberFF 
{FF 
getFF 
;FF 
setFF  #
;FF# $
}FF% &
=FF' (
stringFF) /
.FF/ 0
EmptyFF0 5
;FF5 6
publicGG 

stringGG 
SupplierTaxIdGG 
{GG  !
getGG" %
;GG% &
setGG' *
;GG* +
}GG, -
=GG. /
stringGG0 6
.GG6 7
EmptyGG7 <
;GG< =
publicHH 

stringHH 
SupplierNameHH 
{HH  
getHH! $
;HH$ %
setHH& )
;HH) *
}HH+ ,
=HH- .
stringHH/ 5
.HH5 6
EmptyHH6 ;
;HH; <
publicII 

stringII 
CurrencyII 
{II 
getII  
;II  !
setII" %
;II% &
}II' (
=II) *
$strII+ 0
;II0 1
publicJJ 

decimalJJ 
TaxBaseJJ 
{JJ 
getJJ  
;JJ  !
setJJ" %
;JJ% &
}JJ' (
publicKK 

decimalKK 
IgvKK 
{KK 
getKK 
;KK 
setKK !
;KK! "
}KK# $
publicMM 

decimalMM 

NonTaxableMM 
{MM 
getMM  #
;MM# $
setMM% (
;MM( )
}MM* +
publicNN 

decimalNN 
TotalNN 
{NN 
getNN 
;NN 
setNN  #
;NN# $
}NN% &
publicOO 

decimalOO 
ExchangeRateOO 
{OO  !
getOO" %
;OO% &
setOO' *
;OO* +
}OO, -
=OO. /
$numOO0 2
;OO2 3
publicPP 

decimalPP 
BasePenPP 
{PP 
getPP  
;PP  !
setPP" %
;PP% &
}PP' (
publicQQ 

decimalQQ 
IgvPenQQ 
{QQ 
getQQ 
;QQ  
setQQ! $
;QQ$ %
}QQ& '
publicRR 

decimalRR 
TotalPenRR 
{RR 
getRR !
;RR! "
setRR# &
;RR& '
}RR( )
publicSS 

boolSS 
GivesTaxCreditSS 
{SS  
getSS! $
;SS$ %
setSS& )
;SS) *
}SS+ ,
publicUU 

GuidUU 
?UU 
	ExpenseIdUU 
{UU 
getUU  
;UU  !
setUU" %
;UU% &
}UU' (
publicVV 

stringVV 
?VV 
NotesVV 
{VV 
getVV 
;VV 
setVV  #
;VV# $
}VV% &
publicWW 

DateTimeWW 
	CreatedAtWW 
{WW 
getWW  #
;WW# $
setWW% (
;WW( )
}WW* +
=WW, -
DateTimeWW. 6
.WW6 7
UtcNowWW7 =
;WW= >
publicYY 

staticYY 
boolYY 
AllowsTaxCreditYY &
(YY& ' 
PurchaseDocumentTypeYY' ;
typeYY< @
)YY@ A
=>YYB D
typeYYE I
isYYJ L 
PurchaseDocumentTypeYYM a
.YYa b
FacturaYYb i
orYYj l!
PurchaseDocumentType	YYm Å
.
YYÅ Ç
NotaCredito
YYÇ ç
or
YYé ê"
PurchaseDocumentType
YYë •
.
YY• ¶

NotaDebito
YY¶ ∞
;
YY∞ ±
public[[ 

decimal[[ 
TaxCreditPen[[ 
=>[[  "
GivesTaxCredit[[# 1
?[[2 3
([[4 5
DocumentType[[5 A
==[[B D 
PurchaseDocumentType[[E Y
.[[Y Z
NotaCredito[[Z e
?[[f g
-[[h i
IgvPen[[i o
:[[p q
IgvPen[[r x
)[[x y
:[[z {
$num[[| ~
;[[~ 
}\\ 
public__ 
sealed__ 
class__ 
LearningVideo__ !
{__" #
public__$ *
Guid__+ /
Id__0 2
{__3 4
get__5 8
;__8 9
set__: =
;__= >
}__? @
=__A B
Guid__C G
.__G H
NewGuid__H O
(__O P
)__P Q
;__Q R
public__S Y
string__Z `
Title__a f
{__g h
get__i l
;__l m
set__n q
;__q r
}__s t
=__u v
string__w }
.__} ~
Empty	__~ É
;
__É Ñ
public
__Ö ã
string
__å í
	YoutubeId
__ì ú
{
__ù û
get
__ü ¢
;
__¢ £
set
__§ ß
;
__ß ®
}
__© ™
=
__´ ¨
string
__≠ ≥
.
__≥ ¥
Empty
__¥ π
;
__π ∫
public
__ª ¡
string
__¬ »
Category
__… —
{
__“ ”
get
__‘ ◊
;
__◊ ÿ
set
__Ÿ ‹
;
__‹ ›
}
__ﬁ ﬂ
=
__‡ ·
string
__‚ Ë
.
__Ë È
Empty
__È Ó
;
__Ó Ô
public`` 
string`` 
?`` 
Language`` 
{`` 
get`` 
;`` 
set``  #
;``# $
}``% &
public``' -
string``. 4
?``4 5
Description``6 A
{``B C
get``D G
;``G H
set``I L
;``L M
}``N O
public``P V
int``W Z
	SortOrder``[ d
{``e f
get``g j
;``j k
set``l o
;``o p
}``q r
public``s y
bool``z ~
IsPublished	`` ä
{
``ã å
get
``ç ê
;
``ê ë
set
``í ï
;
``ï ñ
}
``ó ò
=
``ô ö
true
``õ ü
;
``ü †
public
``° ß
DateTime
``® ∞
	CreatedAt
``± ∫
{
``ª º
get
``Ω ¿
;
``¿ ¡
set
``¬ ≈
;
``≈ ∆
}
``« »
=
``…  
DateTime
``À ”
.
``” ‘
UtcNow
``‘ ⁄
;
``⁄ €
}
``‹ ›
publiccc 
sealedcc 
classcc 
ProductCategorycc #
{cc$ %
publiccc& ,
Guidcc- 1
Idcc2 4
{cc5 6
getcc7 :
;cc: ;
setcc< ?
;cc? @
}ccA B
=ccC D
GuidccE I
.ccI J
NewGuidccJ Q
(ccQ R
)ccR S
;ccS T
publicccU [
stringcc\ b
Nameccc g
{cch i
getccj m
;ccm n
setcco r
;ccr s
}cct u
=ccv w
stringccx ~
.cc~ 
Empty	cc Ñ
;
ccÑ Ö
public
ccÜ å
int
ccç ê
	SortOrder
ccë ö
{
ccõ ú
get
ccù †
;
cc† °
set
cc¢ •
;
cc• ¶
}
ccß ®
}
cc© ™
publicee 
sealedee 
classee 
Clientee 
{ee 
publicee #
Guidee$ (
Idee) +
{ee, -
getee. 1
;ee1 2
setee3 6
;ee6 7
}ee8 9
=ee: ;
Guidee< @
.ee@ A
NewGuideeA H
(eeH I
)eeI J
;eeJ K
publiceeL R
stringeeS Y
CompanyNameeeZ e
{eef g
geteeh k
;eek l
seteem p
;eep q
}eer s
=eet u
stringeev |
.ee| }
Empty	ee} Ç
;
eeÇ É
public
eeÑ ä
string
eeã ë
ContactName
eeí ù
{
eeû ü
get
ee† £
;
ee£ §
set
ee• ®
;
ee® ©
}
ee™ ´
=
ee¨ ≠
string
eeÆ ¥
.
ee¥ µ
Empty
eeµ ∫
;
ee∫ ª
public
eeº ¬
string
ee√ …
Email
ee  œ
{
ee– —
get
ee“ ’
;
ee’ ÷
set
ee◊ ⁄
;
ee⁄ €
}
ee‹ ›
=
eeﬁ ﬂ
string
ee‡ Ê
.
eeÊ Á
Empty
eeÁ Ï
;
eeÏ Ì
public
eeÓ Ù
string
eeı ˚
?
ee˚ ¸
Phone
ee˝ Ç
{
eeÉ Ñ
get
eeÖ à
;
eeà â
set
eeä ç
;
eeç é
}
eeè ê
public
eeë ó
string
eeò û
PreferredLanguage
eeü ∞
{
ee± ≤
get
ee≥ ∂
;
ee∂ ∑
set
ee∏ ª
;
eeª º
}
eeΩ æ
=
eeø ¿
$str
ee¡ ≈
;
ee≈ ∆
public
ee« Õ
bool
eeŒ “
IsActive
ee” €
{
ee‹ ›
get
eeﬁ ·
;
ee· ‚
set
ee„ Ê
;
eeÊ Á
}
eeË È
=
eeÍ Î
true
eeÏ 
;
ee Ò
publicff 

boolff 
RequiresTaxDocumentff #
{ff$ %
getff& )
;ff) *
setff+ .
;ff. /
}ff0 1
publicff2 8
DateTimeff9 A
	CreatedAtffB K
{ffL M
getffN Q
;ffQ R
setffS V
;ffV W
}ffX Y
=ffZ [
DateTimeff\ d
.ffd e
UtcNowffe k
;ffk l
}ffm n
publicgg 
sealedgg 
classgg 
UserAccountgg 
{gg  !
publicgg" (
Guidgg) -
Idgg. 0
{gg1 2
getgg3 6
;gg6 7
setgg8 ;
;gg; <
}gg= >
=gg? @
GuidggA E
.ggE F
NewGuidggF M
(ggM N
)ggN O
;ggO P
publicggQ W
GuidggX \
?gg\ ]
ClientIdgg^ f
{ggg h
getggi l
;ggl m
setggn q
;ggq r
}ggs t
publicggu {
string	gg| Ç
Email
ggÉ à
{
ggâ ä
get
ggã é
;
ggé è
set
ggê ì
;
ggì î
}
ggï ñ
=
ggó ò
string
ggô ü
.
ggü †
Empty
gg† •
;
gg• ¶
public
ggß ≠
string
ggÆ ¥
PasswordHash
ggµ ¡
{
gg¬ √
get
ggƒ «
;
gg« »
set
gg… Ã
;
ggÃ Õ
}
ggŒ œ
=
gg– —
string
gg“ ÿ
.
ggÿ Ÿ
Empty
ggŸ ﬁ
;
ggﬁ ﬂ
public
gg‡ Ê
string
ggÁ Ì
Name
ggÓ Ú
{
ggÛ Ù
get
ggı ¯
;
gg¯ ˘
set
gg˙ ˝
;
gg˝ ˛
}
ggˇ Ä
=
ggÅ Ç
string
ggÉ â
.
ggâ ä
Empty
ggä è
;
ggè ê
public
ggë ó
UserRole
ggò †
Role
gg° •
{
gg¶ ß
get
gg® ´
;
gg´ ¨
set
gg≠ ∞
;
gg∞ ±
}
gg≤ ≥
=
gg¥ µ
UserRole
gg∂ æ
.
ggæ ø
Cliente
ggø ∆
;
gg∆ «
public
gg» Œ
bool
ggœ ”
IsActive
gg‘ ‹
{
gg› ﬁ
get
ggﬂ ‚
;
gg‚ „
set
gg‰ Á
;
ggÁ Ë
}
ggÈ Í
=
ggÎ Ï
true
ggÌ Ò
;
ggÒ Ú
publichh 

DateTimehh 
?hh 
NotificationsSeenAthh (
{hh) *
gethh+ .
;hh. /
sethh0 3
;hh3 4
}hh5 6
publicjj 

stringjj 
?jj 
Areajj 
{jj 
getjj 
;jj 
setjj "
;jj" #
}jj$ %
publicll 

stringll 
?ll 
JobTitlell 
{ll 
getll !
;ll! "
setll# &
;ll& '
}ll( )
publicnn 

Guidnn 
?nn 
	ManagerIdnn 
{nn 
getnn  
;nn  !
setnn" %
;nn% &
}nn' (
}nn) *
publicss 
sealedss 
classss 
	LoginLinkss 
{ss 
publicss  &
Guidss' +
Idss, .
{ss/ 0
getss1 4
;ss4 5
setss6 9
;ss9 :
}ss; <
=ss= >
Guidss? C
.ssC D
NewGuidssD K
(ssK L
)ssL M
;ssM N
publicssO U
GuidssV Z
UserAccountIdss[ h
{ssi j
getssk n
;ssn o
setssp s
;sss t
}ssu v
publicssw }
string	ss~ Ñ
	TokenHash
ssÖ é
{
ssè ê
get
ssë î
;
ssî ï
set
ssñ ô
;
ssô ö
}
ssõ ú
=
ssù û
string
ssü •
.
ss• ¶
Empty
ss¶ ´
;
ss´ ¨
public
ss≠ ≥
DateTime
ss¥ º
	CreatedAt
ssΩ ∆
{
ss« »
get
ss… Ã
;
ssÃ Õ
set
ssŒ —
;
ss— “
}
ss” ‘
=
ss’ ÷
DateTime
ss◊ ﬂ
.
ssﬂ ‡
UtcNow
ss‡ Ê
;
ssÊ Á
public
ssË Ó
DateTime
ssÔ ˜
	ExpiresAt
ss¯ Å
{
ssÇ É
get
ssÑ á
;
ssá à
set
ssâ å
;
sså ç
}
ssé è
public
ssê ñ
DateTime
ssó ü
?
ssü †
UsedAt
ss° ß
{
ss® ©
get
ss™ ≠
;
ss≠ Æ
set
ssØ ≤
;
ss≤ ≥
}
ss¥ µ
}
ss∂ ∑
publicuu 
sealeduu 
classuu 
Projectuu 
{uu 
publicuu $
Guiduu% )
Iduu* ,
{uu- .
getuu/ 2
;uu2 3
setuu4 7
;uu7 8
}uu9 :
=uu; <
Guiduu= A
.uuA B
NewGuiduuB I
(uuI J
)uuJ K
;uuK L
publicuuM S
GuiduuT X
ClientIduuY a
{uub c
getuud g
;uug h
setuui l
;uul m
}uun o
publicuup v
stringuuw }
Name	uu~ Ç
{
uuÉ Ñ
get
uuÖ à
;
uuà â
set
uuä ç
;
uuç é
}
uuè ê
=
uuë í
string
uuì ô
.
uuô ö
Empty
uuö ü
;
uuü †
public
uu° ß
string
uu® Æ
Slug
uuØ ≥
{
uu¥ µ
get
uu∂ π
;
uuπ ∫
set
uuª æ
;
uuæ ø
}
uu¿ ¡
=
uu¬ √
string
uuƒ  
.
uu  À
Empty
uuÀ –
;
uu– —
public
uu“ ÿ
List
uuŸ ›
<
uu› ﬁ
ProjectRepository
uuﬁ Ô
>
uuÔ 
Repositories
uuÒ ˝
{
uu˛ ˇ
get
uuÄ É
;
uuÉ Ñ
set
uuÖ à
;
uuà â
}
uuä ã
=
uuå ç
[
uué è
]
uuè ê
;
uuê ë
}
uuí ì
publicww 
sealedww 
classww 
ProjectRepositoryww %
{ww& '
publicww( .
Guidww/ 3
Idww4 6
{ww7 8
getww9 <
;ww< =
setww> A
;wwA B
}wwC D
=wwE F
GuidwwG K
.wwK L
NewGuidwwL S
(wwS T
)wwT U
;wwU V
publicwwW ]
Guidww^ b
	ProjectIdwwc l
{wwm n
getwwo r
;wwr s
setwwt w
;www x
}wwy z
public	ww{ Å
string
wwÇ à
Owner
wwâ é
{
wwè ê
get
wwë î
;
wwî ï
set
wwñ ô
;
wwô ö
}
wwõ ú
=
wwù û
string
wwü •
.
ww• ¶
Empty
ww¶ ´
;
ww´ ¨
public
ww≠ ≥
string
ww¥ ∫
Name
wwª ø
{
ww¿ ¡
get
ww¬ ≈
;
ww≈ ∆
set
ww«  
;
ww  À
}
wwÃ Õ
=
wwŒ œ
string
ww– ÷
.
ww÷ ◊
Empty
ww◊ ‹
;
ww‹ ›
public
wwﬁ ‰
string
wwÂ Î
?
wwÎ Ï
Label
wwÌ Ú
{
wwÛ Ù
get
wwı ¯
;
ww¯ ˘
set
ww˙ ˝
;
ww˝ ˛
}
wwˇ Ä
public
wwÅ á
bool
wwà å
	IsDefault
wwç ñ
{
wwó ò
get
wwô ú
;
wwú ù
set
wwû °
;
ww° ¢
}
ww£ §
}
ww• ¶
publicxx 
staticxx 
classxx 
ProjectExtensionsxx %
{yy 
public{{ 

static{{ 
ProjectRepository{{ #
?{{# $
RepositoryFor{{% 2
({{2 3
this{{3 7
IReadOnlyCollection{{8 K
<{{K L
ProjectRepository{{L ]
>{{] ^
repositories{{_ k
,{{k l
Guid{{m q
?{{q r
repositoryId{{s 
)	{{ Ä
=>
{{Å É
repositoryId|| 
is|| 
Guid|| 
id|| 
?||  !
repositories||" .
.||. /
FirstOrDefault||/ =
(||= >
x||> ?
=>||@ B
x||C D
.||D E
Id||E G
==||H J
id||K M
)||M N
:||O P
repositories||Q ]
.||] ^
OrderByDescending||^ o
(||o p
x||p q
=>||r t
x||u v
.||v w
	IsDefault	||w Ä
)
||Ä Å
.
||Å Ç
FirstOrDefault
||Ç ê
(
||ê ë
)
||ë í
;
||í ì
}}} 
public~~ 
sealed~~ 
class~~ 
Product~~ 
{~~ 
public~~ $
Guid~~% )
Id~~* ,
{~~- .
get~~/ 2
;~~2 3
set~~4 7
;~~7 8
}~~9 :
=~~; <
Guid~~= A
.~~A B
NewGuid~~B I
(~~I J
)~~J K
;~~K L
public~~M S
ProductType~~T _
Type~~` d
{~~e f
get~~g j
;~~j k
set~~l o
;~~o p
}~~q r
public~~s y
string	~~z Ä
Name
~~Å Ö
{
~~Ü á
get
~~à ã
;
~~ã å
set
~~ç ê
;
~~ê ë
}
~~í ì
=
~~î ï
string
~~ñ ú
.
~~ú ù
Empty
~~ù ¢
;
~~¢ £
public
~~§ ™
BillingCycle
~~´ ∑
BillingCycle
~~∏ ƒ
{
~~≈ ∆
get
~~«  
;
~~  À
set
~~Ã œ
;
~~œ –
}
~~— “
public
~~” Ÿ
decimal
~~⁄ ·
?
~~· ‚
	BasePrice
~~„ Ï
{
~~Ì Ó
get
~~Ô Ú
;
~~Ú Û
set
~~Ù ˜
;
~~˜ ¯
}
~~˘ ˙
public
~~˚ Å
string
~~Ç à
Currency
~~â ë
{
~~í ì
get
~~î ó
;
~~ó ò
set
~~ô ú
;
~~ú ù
}
~~û ü
=
~~† °
$str
~~¢ ß
;
~~ß ®
public
~~© Ø
string
~~∞ ∂
?
~~∂ ∑
Description
~~∏ √
{
~~ƒ ≈
get
~~∆ …
;
~~…  
set
~~À Œ
;
~~Œ œ
}
~~– —
public
~~“ ÿ
bool
~~Ÿ ›
IsActive
~~ﬁ Ê
{
~~Á Ë
get
~~È Ï
;
~~Ï Ì
set
~~Ó Ò
;
~~Ò Ú
}
~~Û Ù
=
~~ı ˆ
true
~~˜ ˚
;
~~˚ ¸
public
~~˝ É
string
~~Ñ ä
?
~~ä ã
PayPalPlanId
~~å ò
{
~~ô ö
get
~~õ û
;
~~û ü
set
~~† £
;
~~£ §
}
~~• ¶
public
~~ß ≠
decimal
~~Æ µ
?
~~µ ∂
PayPalPlanPrice
~~∑ ∆
{
~~« »
get
~~… Ã
;
~~Ã Õ
set
~~Œ —
;
~~— “
}
~~” ‘
public
~~’ €
TaxDocumentType
~~‹ Î
TaxDocumentType
~~Ï ˚
{
~~¸ ˝
get
~~˛ Å
;
~~Å Ç
set
~~É Ü
;
~~Ü á
}
~~à â
=
~~ä ã
TaxDocumentType
~~å õ
.
~~õ ú
Factura
~~ú £
;
~~£ §
public
ÄÄ 

string
ÄÄ 
?
ÄÄ 
Category
ÄÄ 
{
ÄÄ 
get
ÄÄ !
;
ÄÄ! "
set
ÄÄ# &
;
ÄÄ& '
}
ÄÄ( )
public
ÇÇ 

string
ÇÇ 
?
ÇÇ 
Tags
ÇÇ 
{
ÇÇ 
get
ÇÇ 
;
ÇÇ 
set
ÇÇ "
;
ÇÇ" #
}
ÇÇ$ %
public
ÑÑ 

bool
ÑÑ 
AllowsTickets
ÑÑ 
{
ÑÑ 
get
ÑÑ  #
;
ÑÑ# $
set
ÑÑ% (
;
ÑÑ( )
}
ÑÑ* +
}
ÑÑ, -
publicÖÖ 
sealed
ÖÖ 
class
ÖÖ 
ClientProduct
ÖÖ !
{
ÖÖ" #
public
ÖÖ$ *
Guid
ÖÖ+ /
Id
ÖÖ0 2
{
ÖÖ3 4
get
ÖÖ5 8
;
ÖÖ8 9
set
ÖÖ: =
;
ÖÖ= >
}
ÖÖ? @
=
ÖÖA B
Guid
ÖÖC G
.
ÖÖG H
NewGuid
ÖÖH O
(
ÖÖO P
)
ÖÖP Q
;
ÖÖQ R
public
ÖÖS Y
Guid
ÖÖZ ^
ClientId
ÖÖ_ g
{
ÖÖh i
get
ÖÖj m
;
ÖÖm n
set
ÖÖo r
;
ÖÖr s
}
ÖÖt u
public
ÖÖv |
GuidÖÖ} Å
	ProjectIdÖÖÇ ã
{ÖÖå ç
getÖÖé ë
;ÖÖë í
setÖÖì ñ
;ÖÖñ ó
}ÖÖò ô
publicÖÖö †
GuidÖÖ° •
	ProductIdÖÖ¶ Ø
{ÖÖ∞ ±
getÖÖ≤ µ
;ÖÖµ ∂
setÖÖ∑ ∫
;ÖÖ∫ ª
}ÖÖº Ω
publicÖÖæ ƒ#
ClientProductStatusÖÖ≈ ÿ
StatusÖÖŸ ﬂ
{ÖÖ‡ ·
getÖÖ‚ Â
;ÖÖÂ Ê
setÖÖÁ Í
;ÖÖÍ Î
}ÖÖÏ Ì
publicÖÖÓ Ù
BillingCycleÖÖı Å
BillingCycleÖÖÇ é
{ÖÖè ê
getÖÖë î
;ÖÖî ï
setÖÖñ ô
;ÖÖô ö
}ÖÖõ ú
publicÖÖù £
boolÖÖ§ ®
IsManualBillingÖÖ© ∏
{ÖÖπ ∫
getÖÖª æ
;ÖÖæ ø
setÖÖ¿ √
;ÖÖ√ ƒ
}ÖÖ≈ ∆
publicÖÖ« Õ
DateTimeÖÖŒ ÷
?ÖÖ÷ ◊
RenewsAtÖÖÿ ‡
{ÖÖ· ‚
getÖÖ„ Ê
;ÖÖÊ Á
setÖÖË Î
;ÖÖÎ Ï
}ÖÖÌ Ó
publicÖÖÔ ı
DateTimeÖÖˆ ˛
?ÖÖ˛ ˇ
NextChargeAtÖÖÄ å
{ÖÖç é
getÖÖè í
;ÖÖí ì
setÖÖî ó
;ÖÖó ò
}ÖÖô ö
publicÖÖõ °
DateTimeÖÖ¢ ™
?ÖÖ™ ´
LastBackupAtÖÖ¨ ∏
{ÖÖπ ∫
getÖÖª æ
;ÖÖæ ø
setÖÖ¿ √
;ÖÖ√ ƒ
}ÖÖ≈ ∆
publicÖÖ« Õ
decimalÖÖŒ ’
?ÖÖ’ ÷
PriceÖÖ◊ ‹
{ÖÖ› ﬁ
getÖÖﬂ ‚
;ÖÖ‚ „
setÖÖ‰ Á
;ÖÖÁ Ë
}ÖÖÈ Í
publicÖÖÎ Ò
stringÖÖÚ ¯
?ÖÖ¯ ˘"
PriceLabelOverrideÖÖ˙ å
{ÖÖç é
getÖÖè í
;ÖÖí ì
setÖÖî ó
;ÖÖó ò
}ÖÖô ö
publicÖÖõ °
stringÖÖ¢ ®
?ÖÖ® ©
PayPalOrderIdÖÖ™ ∑
{ÖÖ∏ π
getÖÖ∫ Ω
;ÖÖΩ æ
setÖÖø ¬
;ÖÖ¬ √
}ÖÖƒ ≈
publicÖÖ∆ Ã
stringÖÖÕ ”
?ÖÖ” ‘$
PayPalSubscriptionIdÖÖ’ È
{ÖÖÍ Î
getÖÖÏ Ô
;ÖÖÔ 
setÖÖÒ Ù
;ÖÖÙ ı
}ÖÖˆ ˜
publicÖÖ¯ ˛
stringÖÖˇ Ö
?ÖÖÖ Ü
PayPalPlanIdÖÖá ì
{ÖÖî ï
getÖÖñ ô
;ÖÖô ö
setÖÖõ û
;ÖÖû ü
}ÖÖ† °
publicÖÖ¢ ®
stringÖÖ© Ø
?ÖÖØ ∞

DomainNameÖÖ± ª
{ÖÖº Ω
getÖÖæ ¡
;ÖÖ¡ ¬
setÖÖ√ ∆
;ÖÖ∆ «
}ÖÖ» …
public
ÜÜ 

decimal
ÜÜ 
?
ÜÜ 
Discount
ÜÜ 
{
ÜÜ 
get
ÜÜ "
;
ÜÜ" #
set
ÜÜ$ '
;
ÜÜ' (
}
ÜÜ) *
public
ÜÜ+ 1
DateTime
ÜÜ2 :
?
ÜÜ: ;
DiscountEndsAt
ÜÜ< J
{
ÜÜK L
get
ÜÜM P
;
ÜÜP Q
set
ÜÜR U
;
ÜÜU V
}
ÜÜW X
public
ÜÜY _
Product
ÜÜ` g
?
ÜÜg h
Product
ÜÜi p
{
ÜÜq r
get
ÜÜs v
;
ÜÜv w
set
ÜÜx {
;
ÜÜ{ |
}
ÜÜ} ~
publicÜÜ Ö
ProjectÜÜÜ ç
?ÜÜç é
ProjectÜÜè ñ
{ÜÜó ò
getÜÜô ú
;ÜÜú ù
setÜÜû °
;ÜÜ° ¢
}ÜÜ£ §
public
àà 

int
àà 
?
àà 
PayPalOrderYears
àà  
{
àà! "
get
àà# &
;
àà& '
set
àà( +
;
àà+ ,
}
àà- .
public
ää 

decimal
ää 
?
ää 
AppliedIgvRate
ää "
{
ää# $
get
ää% (
;
ää( )
set
ää* -
;
ää- .
}
ää/ 0
public
åå 
#
TransferReportSummary
åå  
?
åå  !
TransferReport
åå" 0
{
åå1 2
get
åå3 6
;
åå6 7
set
åå8 ;
;
åå; <
}
åå= >
}
åå? @
publicçç 
sealed
çç 
class
çç 
Ticket
çç 
{
çç 
public
çç #
Guid
çç$ (
Id
çç) +
{
çç, -
get
çç. 1
;
çç1 2
set
çç3 6
;
çç6 7
}
çç8 9
=
çç: ;
Guid
çç< @
.
çç@ A
NewGuid
ççA H
(
ççH I
)
ççI J
;
ççJ K
public
ççL R
string
ççS Y
Code
ççZ ^
{
çç_ `
get
çça d
;
ççd e
set
ççf i
;
ççi j
}
ççk l
=
ççm n
string
çço u
.
ççu v
Empty
ççv {
;
çç{ |
publicçç} É
GuidççÑ à
ClientIdççâ ë
{ççí ì
getççî ó
;ççó ò
setççô ú
;ççú ù
}ççû ü
publicçç† ¶
Guidççß ´
	ProjectIdçç¨ µ
{çç∂ ∑
getçç∏ ª
;ççª º
setççΩ ¿
;çç¿ ¡
}çç¬ √
publicççƒ  
GuidççÀ œ
CreatedByUserIdçç– ﬂ
{çç‡ ·
getçç‚ Â
;ççÂ Ê
setççÁ Í
;ççÍ Î
}ççÏ Ì
publicççÓ Ù

TicketTypeççı ˇ
TypeççÄ Ñ
{ççÖ Ü
getççá ä
;ççä ã
setççå è
;ççè ê
}ççë í
publicççì ô
TicketStatusççö ¶
Statusççß ≠
{ççÆ Ø
getçç∞ ≥
;çç≥ ¥
setççµ ∏
;çç∏ π
}çç∫ ª
=ççº Ω
TicketStatusççæ  
.çç  À
AbiertoççÀ “
;çç“ ”
publicçç‘ ⁄
stringçç€ ·
Titleçç‚ Á
{ççË È
getççÍ Ì
;ççÌ Ó
setççÔ Ú
;ççÚ Û
}ççÙ ı
=ççˆ ˜
stringçç¯ ˛
.çç˛ ˇ
Emptyççˇ Ñ
;ççÑ Ö
publicççÜ å
stringççç ì
Descriptionççî ü
{çç† °
getçç¢ •
;çç• ¶
setççß ™
;çç™ ´
}çç¨ ≠
=ççÆ Ø
stringçç∞ ∂
.çç∂ ∑
Emptyçç∑ º
;ççº Ω
publicççæ ƒ
stringçç≈ À
?ççÀ Ã
CurrentBehaviorççÕ ‹
{çç› ﬁ
getççﬂ ‚
;çç‚ „
setçç‰ Á
;ççÁ Ë
}ççÈ Í
publicççÎ Ò
stringççÚ ¯
?çç¯ ˘ 
ExpectedBehaviorçç˙ ä
{ççã å
getççç ê
;ççê ë
setççí ï
;ççï ñ
}ççó ò
publicççô ü
stringçç† ¶
?çç¶ ß 
StepsToReproduceçç® ∏
{ççπ ∫
getççª æ
;ççæ ø
setçç¿ √
;çç√ ƒ
}çç≈ ∆
publicçç« Õ
stringççŒ ‘
?çç‘ ’
Environmentçç÷ ·
{çç‚ „
getçç‰ Á
;ççÁ Ë
setççÈ Ï
;ççÏ Ì
}ççÓ Ô
publicçç ˆ
stringçç˜ ˝
?çç˝ ˛"
AcceptanceCriteriaççˇ ë
{ççí ì
getççî ó
;ççó ò
setççô ú
;ççú ù
}ççû ü
publicçç† ¶
stringççß ≠
?çç≠ Æ
EstimatedImpactççØ æ
{ççø ¿
getçç¡ ƒ
;ççƒ ≈
setçç∆ …
;çç…  
}ççÀ Ã
public
éé 

Guid
éé 
?
éé 
RepositoryId
éé 
{
éé 
get
éé  #
;
éé# $
set
éé% (
;
éé( )
}
éé* +
public
èè 

Guid
èè 
?
èè 
ClientProductId
èè  
{
èè! "
get
èè# &
;
èè& '
set
èè( +
;
èè+ ,
}
èè- .
public
èè/ 5
int
èè6 9
?
èè9 :
GithubIssueNumber
èè; L
{
èèM N
get
èèO R
;
èèR S
set
èèT W
;
èèW X
}
èèY Z
public
èè[ a
string
èèb h
?
èèh i
GithubIssueUrl
èèj x
{
èèy z
get
èè{ ~
;
èè~ 
setèèÄ É
;èèÉ Ñ
}èèÖ Ü
public
êê 
string
êê 
?
êê !
GithubProjectStatus
êê #
{
êê$ %
get
êê& )
;
êê) *
set
êê+ .
;
êê. /
}
êê0 1
public
êê2 8
DateTime
êê9 A
	CreatedAt
êêB K
{
êêL M
get
êêN Q
;
êêQ R
set
êêS V
;
êêV W
}
êêX Y
=
êêZ [
DateTime
êê\ d
.
êêd e
UtcNow
êêe k
;
êêk l
public
êêm s
DateTime
êêt |
	UpdatedAtêê} Ü
{êêá à
getêêâ å
;êêå ç
setêêé ë
;êêë í
}êêì î
=êêï ñ
DateTimeêêó ü
.êêü †
UtcNowêê† ¶
;êê¶ ß
}êê® ©
publicíí 
sealed
íí 
class
íí 
TicketAttachment
íí $
{
íí% &
public
íí' -
Guid
íí. 2
Id
íí3 5
{
íí6 7
get
íí8 ;
;
íí; <
set
íí= @
;
íí@ A
}
ííB C
=
ííD E
Guid
ííF J
.
ííJ K
NewGuid
ííK R
(
ííR S
)
ííS T
;
ííT U
public
ííV \
Guid
íí] a
TicketId
ííb j
{
íík l
get
íím p
;
ííp q
set
íír u
;
ííu v
}
ííw x
public
ííy 
stringííÄ Ü
FileNameííá è
{ííê ë
getííí ï
;ííï ñ
setííó ö
;ííö õ
}ííú ù
=ííû ü
stringíí† ¶
.íí¶ ß
Emptyííß ¨
;íí¨ ≠
publicííÆ ¥
stringííµ ª
Urlííº ø
{íí¿ ¡
getíí¬ ≈
;íí≈ ∆
setíí«  
;íí  À
}ííÃ Õ
=ííŒ œ
stringíí– ÷
.íí÷ ◊
Emptyíí◊ ‹
;íí‹ ›
publicííﬁ ‰
longííÂ È
	SizeBytesííÍ Û
{ííÙ ı
getííˆ ˘
;íí˘ ˙
setíí˚ ˛
;íí˛ ˇ
}ííÄ Å
publicííÇ à
stringííâ è
ContentTypeííê õ
{ííú ù
getííû °
;íí° ¢
setíí£ ¶
;íí¶ ß
}íí® ©
=íí™ ´
$stríí¨ ∆
;íí∆ «
publicíí» Œ
byteííœ ”
[íí” ‘
]íí‘ ’
Contentíí÷ ›
{ííﬁ ﬂ
getíí‡ „
;íí„ ‰
setííÂ Ë
;ííË È
}ííÍ Î
=ííÏ Ì
[ííÓ Ô
]ííÔ 
;íí Ò
publicííÚ ¯
DateTimeíí˘ Å
	CreatedAtííÇ ã
{ííå ç
getííé ë
;ííë í
setííì ñ
;ííñ ó
}ííò ô
=ííö õ
DateTimeííú §
.íí§ •
UtcNowíí• ´
;íí´ ¨
publicíí≠ ≥
boolíí¥ ∏
IsImageííπ ¿
=>íí¡ √
ContentTypeííƒ œ
.ííœ –

StartsWithíí– ⁄
(íí⁄ €
$stríí€ „
,íí„ ‰ 
StringComparisonííÂ ı
.ííı ˆ!
OrdinalIgnoreCaseííˆ á
)ííá à
;ííà â
}ííä ã
publicìì 
sealed
ìì 
class
ìì 
TicketComment
ìì !
{
ìì" #
public
ìì$ *
Guid
ìì+ /
Id
ìì0 2
{
ìì3 4
get
ìì5 8
;
ìì8 9
set
ìì: =
;
ìì= >
}
ìì? @
=
ììA B
Guid
ììC G
.
ììG H
NewGuid
ììH O
(
ììO P
)
ììP Q
;
ììQ R
public
ììS Y
Guid
ììZ ^
TicketId
ìì_ g
{
ììh i
get
ììj m
;
ììm n
set
ììo r
;
ììr s
}
ììt u
public
ììv |
Guidìì} Å
?ììÅ Ç
AuthorUserIdììÉ è
{ììê ë
getììí ï
;ììï ñ
setììó ö
;ììö õ
}ììú ù
publicììû §
stringìì• ´
Bodyìì¨ ∞
{ìì± ≤
getìì≥ ∂
;ìì∂ ∑
setìì∏ ª
;ììª º
}ììΩ æ
=ììø ¿
stringìì¡ «
.ìì« »
Emptyìì» Õ
;ììÕ Œ
publicììœ ’
boolìì÷ ⁄

FromGithubìì€ Â
{ììÊ Á
getììË Î
;ììÎ Ï
setììÌ 
;ìì Ò
}ììÚ Û
publicììÙ ˙
longìì˚ ˇ
?ììˇ Ä
GithubCommentIdììÅ ê
{ììë í
getììì ñ
;ììñ ó
setììò õ
;ììõ ú
}ììù û
publicììü •
stringìì¶ ¨
?ìì¨ ≠!
GithubAuthorLoginììÆ ø
{ìì¿ ¡
getìì¬ ≈
;ìì≈ ∆
setìì«  
;ìì  À
}ììÃ Õ
publicììŒ ‘
DateTimeìì’ ›
	CreatedAtììﬁ Á
{ììË È
getììÍ Ì
;ììÌ Ó
setììÔ Ú
;ììÚ Û
}ììÙ ı
=ììˆ ˜
DateTimeìì¯ Ä
.ììÄ Å
UtcNowììÅ á
;ììá à
}ììâ ä
publicïï 
sealed
ïï 
class
ïï  
PaymentTransaction
ïï &
{
ïï' (
public
ïï) /
Guid
ïï0 4
Id
ïï5 7
{
ïï8 9
get
ïï: =
;
ïï= >
set
ïï? B
;
ïïB C
}
ïïD E
=
ïïF G
Guid
ïïH L
.
ïïL M
NewGuid
ïïM T
(
ïïT U
)
ïïU V
;
ïïV W
public
ïïX ^
Guid
ïï_ c
ClientId
ïïd l
{
ïïm n
get
ïïo r
;
ïïr s
set
ïït w
;
ïïw x
}
ïïy z
public
ññ 

Guid
ññ 
?
ññ 
ClientProductId
ññ  
{
ññ! "
get
ññ# &
;
ññ& '
set
ññ( +
;
ññ+ ,
}
ññ- .
public
ññ/ 5
string
ññ6 <+
PayPalOrderIdOrSubscriptionId
ññ= Z
{
ññ[ \
get
ññ] `
;
ññ` a
set
ññb e
;
ññe f
}
ññg h
=
ññi j
string
ññk q
.
ññq r
Empty
ññr w
;
ññw x
public
ññy 
decimalññÄ á
Amountññà é
{ññè ê
getññë î
;ññî ï
setñññ ô
;ññô ö
}ññõ ú
publicññù £
stringññ§ ™
Currencyññ´ ≥
{ññ¥ µ
getññ∂ π
;ññπ ∫
setññª æ
;ññæ ø
}ññ¿ ¡
=ññ¬ √
$strññƒ …
;ññ…  
publicññÀ —
stringññ“ ÿ
StatusññŸ ﬂ
{ññ‡ ·
getññ‚ Â
;ññÂ Ê
setññÁ Í
;ññÍ Î
}ññÏ Ì
=ññÓ Ô
stringññ ˆ
.ññˆ ˜
Emptyññ˜ ¸
;ññ¸ ˝
public
óó 

string
óó 
Method
óó 
{
óó 
get
óó 
;
óó 
set
óó  #
;
óó# $
}
óó% &
=
óó' (
PaymentMethods
óó) 7
.
óó7 8
PayPal
óó8 >
;
óó> ?
public
òò 

int
òò 
Years
òò 
{
òò 
get
òò 
;
òò 
set
òò 
;
òò  
}
òò! "
=
òò# $
$num
òò% &
;
òò& '
public
òò( .
decimal
òò/ 6
	AmountPen
òò7 @
{
òòA B
get
òòC F
;
òòF G
set
òòH K
;
òòK L
}
òòM N
public
òòO U
string
òòV \
?
òò\ ]
InternalCode
òò^ j
{
òòk l
get
òòm p
;
òòp q
set
òòr u
;
òòu v
}
òòw x
public
òòy 
DateTimeòòÄ à
	CreatedAtòòâ í
{òòì î
getòòï ò
;òòò ô
setòòö ù
;òòù û
}òòü †
=òò° ¢
DateTimeòò£ ´
.òò´ ¨
UtcNowòò¨ ≤
;òò≤ ≥
publicòò¥ ∫
stringòòª ¡
?òò¡ ¬
Notesòò√ »
{òò…  
getòòÀ Œ
;òòŒ œ
setòò– ”
;òò” ‘
}òò’ ÷
}òò◊ ÿ
publicôô 
sealed
ôô 
class
ôô 
NotificationLog
ôô #
{
ôô$ %
public
ôô& ,
Guid
ôô- 1
Id
ôô2 4
{
ôô5 6
get
ôô7 :
;
ôô: ;
set
ôô< ?
;
ôô? @
}
ôôA B
=
ôôC D
Guid
ôôE I
.
ôôI J
NewGuid
ôôJ Q
(
ôôQ R
)
ôôR S
;
ôôS T
public
ôôU [
Guid
ôô\ `
ClientId
ôôa i
{
ôôj k
get
ôôl o
;
ôôo p
set
ôôq t
;
ôôt u
}
ôôv w
public
ôôx ~
stringôô Ö
TypeôôÜ ä
{ôôã å
getôôç ê
;ôôê ë
setôôí ï
;ôôï ñ
}ôôó ò
=ôôô ö
stringôôõ °
.ôô° ¢
Emptyôô¢ ß
;ôôß ®
publicôô© Ø
stringôô∞ ∂
Channelôô∑ æ
{ôôø ¿
getôô¡ ƒ
;ôôƒ ≈
setôô∆ …
;ôô…  
}ôôÀ Ã
=ôôÕ Œ
stringôôœ ’
.ôô’ ÷
Emptyôô÷ €
;ôô€ ‹
publicôô› „
DateTimeôô‰ Ï
SentAtôôÌ Û
{ôôÙ ı
getôôˆ ˘
;ôô˘ ˙
setôô˚ ˛
;ôô˛ ˇ
}ôôÄ Å
=ôôÇ É
DateTimeôôÑ å
.ôôå ç
UtcNowôôç ì
;ôôì î
publicôôï õ
boolôôú †
Successôô° ®
{ôô© ™
getôô´ Æ
;ôôÆ Ø
setôô∞ ≥
;ôô≥ ¥
}ôôµ ∂
publicôô∑ Ω
stringôôæ ƒ
?ôôƒ ≈
	Recipientôô∆ œ
{ôô– —
getôô“ ’
;ôô’ ÷
setôô◊ ⁄
;ôô⁄ €
}ôô‹ ›
publicôôﬁ ‰
stringôôÂ Î
?ôôÎ Ï
	DedupeKeyôôÌ ˆ
{ôô˜ ¯
getôô˘ ¸
;ôô¸ ˝
setôô˛ Å
;ôôÅ Ç
}ôôÉ Ñ
publicôôÖ ã
stringôôå í
?ôôí ì
Errorôôî ô
{ôôö õ
getôôú ü
;ôôü †
setôô° §
;ôô§ •
}ôô¶ ß
}ôô® ©
publicúú 
sealed
úú 
class
úú 
ExchangeRate
úú  
{
úú! "
public
úú# )
Guid
úú* .
Id
úú/ 1
{
úú2 3
get
úú4 7
;
úú7 8
set
úú9 <
;
úú< =
}
úú> ?
=
úú@ A
Guid
úúB F
.
úúF G
NewGuid
úúG N
(
úúN O
)
úúO P
;
úúP Q
public
úúR X
DateOnly
úúY a
Date
úúb f
{
úúg h
get
úúi l
;
úúl m
set
úún q
;
úúq r
}
úús t
public
úúu {
stringúú| Ç
CurrencyCodeúúÉ è
{úúê ë
getúúí ï
;úúï ñ
setúúó ö
;úúö õ
}úúú ù
=úúû ü
stringúú† ¶
.úú¶ ß
Emptyúúß ¨
;úú¨ ≠
publicúúÆ ¥
decimalúúµ º
	RateToPenúúΩ ∆
{úú« »
getúú… Ã
;úúÃ Õ
setúúŒ —
;úú— “
}úú” ‘
publicúú’ €
stringúú‹ ‚
Sourceúú„ È
{úúÍ Î
getúúÏ Ô
;úúÔ 
setúúÒ Ù
;úúÙ ı
}úúˆ ˜
=úú¯ ˘
stringúú˙ Ä
.úúÄ Å
EmptyúúÅ Ü
;úúÜ á
}úúà â
publicüü 
sealed
üü 
class
üü 
TaxDocument
üü 
{
üü  !
public
üü" (
Guid
üü) -
Id
üü. 0
{
üü1 2
get
üü3 6
;
üü6 7
set
üü8 ;
;
üü; <
}
üü= >
=
üü? @
Guid
üüA E
.
üüE F
NewGuid
üüF M
(
üüM N
)
üüN O
;
üüO P
public
üüQ W
Guid
üüX \
?
üü\ ]"
PaymentTransactionId
üü^ r
{
üüs t
get
üüu x
;
üüx y
set
üüz }
;
üü} ~
}üü Ä
publicüüÅ á
Guidüüà å
ClientIdüüç ï
{üüñ ó
getüüò õ
;üüõ ú
setüüù †
;üü† °
}üü¢ £
publicüü§ ™
TaxDocumentTypeüü´ ∫
Typeüüª ø
{üü¿ ¡
getüü¬ ≈
;üü≈ ∆
setüü«  
;üü  À
}üüÃ Õ
publicüüŒ ‘
stringüü’ €
Seriesüü‹ ‚
{üü„ ‰
getüüÂ Ë
;üüË È
setüüÍ Ì
;üüÌ Ó
}üüÔ 
=üüÒ Ú
stringüüÛ ˘
.üü˘ ˙
Emptyüü˙ ˇ
;üüˇ Ä
publicüüÅ á
intüüà ã
Numberüüå í
{üüì î
getüüï ò
;üüò ô
setüüö ù
;üüù û
}üüü †
publicüü° ß
DateOnlyüü® ∞
	IssueDateüü± ∫
{üüª º
getüüΩ ¿
;üü¿ ¡
setüü¬ ≈
;üü≈ ∆
}üü« »
publicüü… œ
stringüü– ÷
Currencyüü◊ ﬂ
{üü‡ ·
getüü‚ Â
;üüÂ Ê
setüüÁ Í
;üüÍ Î
}üüÏ Ì
=üüÓ Ô
$strüü ı
;üüı ˆ
publicüü˜ ˝
decimalüü˛ Ö

BaseAmountüüÜ ê
{üüë í
getüüì ñ
;üüñ ó
setüüò õ
;üüõ ú
}üüù û
publicüüü •
decimalüü¶ ≠
	IgvAmountüüÆ ∑
{üü∏ π
getüü∫ Ω
;üüΩ æ
setüüø ¬
;üü¬ √
}üüƒ ≈
publicüü∆ Ã
decimalüüÕ ‘
TotalAmountüü’ ‡
{üü· ‚
getüü„ Ê
;üüÊ Á
setüüË Î
;üüÎ Ï
}üüÌ Ó
publicüüÔ ı
stringüüˆ ¸
?üü¸ ˝
Notesüü˛ É
{üüÑ Ö
getüüÜ â
;üüâ ä
setüüã é
;üüé è
}üüê ë
public
†† 

decimal
†† 
?
†† 
RetentionAmount
†† #
{
††$ %
get
††& )
;
††) *
set
††+ .
;
††. /
}
††0 1
}
††2 3
public¶¶ 
sealed
¶¶ 
class
¶¶ 
PaymentReversal
¶¶ #
{
¶¶$ %
public
¶¶& ,
Guid
¶¶- 1
Id
¶¶2 4
{
¶¶5 6
get
¶¶7 :
;
¶¶: ;
set
¶¶< ?
;
¶¶? @
}
¶¶A B
=
¶¶C D
Guid
¶¶E I
.
¶¶I J
NewGuid
¶¶J Q
(
¶¶Q R
)
¶¶R S
;
¶¶S T
public
¶¶U [
Guid
¶¶\ `
ClientId
¶¶a i
{
¶¶j k
get
¶¶l o
;
¶¶o p
set
¶¶q t
;
¶¶t u
}
¶¶v w
public
¶¶x ~
Guid¶¶ É
?¶¶É Ñ
ClientProductId¶¶Ö î
{¶¶ï ñ
get¶¶ó ö
;¶¶ö õ
set¶¶ú ü
;¶¶ü †
}¶¶° ¢
public
ßß 

string
ßß 
?
ßß 

PaymentKey
ßß 
{
ßß 
get
ßß  #
;
ßß# $
set
ßß% (
;
ßß( )
}
ßß* +
public
ßß, 2
string
ßß3 9
?
ßß9 :
Method
ßß; A
{
ßßB C
get
ßßD G
;
ßßG H
set
ßßI L
;
ßßL M
}
ßßN O
public
ßßP V
string
ßßW ]
?
ßß] ^
InternalCode
ßß_ k
{
ßßl m
get
ßßn q
;
ßßq r
set
ßßs v
;
ßßv w
}
ßßx y
publicßßz Ä
decimalßßÅ à
Amountßßâ è
{ßßê ë
getßßí ï
;ßßï ñ
setßßó ö
;ßßö õ
}ßßú ù
publicßßû §
stringßß• ´
Currencyßß¨ ¥
{ßßµ ∂
getßß∑ ∫
;ßß∫ ª
setßßº ø
;ßßø ¿
}ßß¡ ¬
=ßß√ ƒ
$strßß≈  
;ßß  À
publicßßÃ “
decimalßß” ⁄
?ßß⁄ €
	AmountPenßß‹ Â
{ßßÊ Á
getßßË Î
;ßßÎ Ï
setßßÌ 
;ßß Ò
}ßßÚ Û
publicßßÙ ˙
DateTimeßß˚ É
?ßßÉ Ñ
PaidAtßßÖ ã
{ßßå ç
getßßé ë
;ßßë í
setßßì ñ
;ßßñ ó
}ßßò ô
public
®® 

TaxDocumentType
®® 
DocumentType
®® '
{
®®( )
get
®®* -
;
®®- .
set
®®/ 2
;
®®2 3
}
®®4 5
public
®®6 <
string
®®= C
Series
®®D J
{
®®K L
get
®®M P
;
®®P Q
set
®®R U
;
®®U V
}
®®W X
=
®®Y Z
string
®®[ a
.
®®a b
Empty
®®b g
;
®®g h
public
®®i o
int
®®p s
Number
®®t z
{
®®{ |
get®®} Ä
;®®Ä Å
set®®Ç Ö
;®®Ö Ü
}®®á à
public®®â è
DateOnly®®ê ò
	IssueDate®®ô ¢
{®®£ §
get®®• ®
;®®® ©
set®®™ ≠
;®®≠ Æ
}®®Ø ∞
public
©© 

string
©© 
Reason
©© 
{
©© 
get
©© 
;
©© 
set
©©  #
;
©©# $
}
©©% &
=
©©' (
string
©©) /
.
©©/ 0
Empty
©©0 5
;
©©5 6
public
™™ 

bool
™™ 
	NotIssued
™™ 
{
™™ 
get
™™ 
;
™™  
set
™™! $
;
™™$ %
}
™™& '
public
™™( .
bool
™™/ 3
NumberReleased
™™4 B
{
™™C D
get
™™E H
;
™™H I
set
™™J M
;
™™M N
}
™™O P
public
™™Q W
Guid
™™X \
?
™™\ ]
ReversedByUserId
™™^ n
{
™™o p
get
™™q t
;
™™t u
set
™™v y
;
™™y z
}
™™{ |
public™™} É
DateTime™™Ñ å

ReversedAt™™ç ó
{™™ò ô
get™™ö ù
;™™ù û
set™™ü ¢
;™™¢ £
}™™§ •
=™™¶ ß
DateTime™™® ∞
.™™∞ ±
UtcNow™™± ∑
;™™∑ ∏
}™™π ∫
public≠≠ 
sealed
≠≠ 
class
≠≠ 
TaxDocumentLine
≠≠ #
{
≠≠$ %
public
≠≠& ,
Guid
≠≠- 1
Id
≠≠2 4
{
≠≠5 6
get
≠≠7 :
;
≠≠: ;
set
≠≠< ?
;
≠≠? @
}
≠≠A B
=
≠≠C D
Guid
≠≠E I
.
≠≠I J
NewGuid
≠≠J Q
(
≠≠Q R
)
≠≠R S
;
≠≠S T
public
≠≠U [
Guid
≠≠\ `
TaxDocumentId
≠≠a n
{
≠≠o p
get
≠≠q t
;
≠≠t u
set
≠≠v y
;
≠≠y z
}
≠≠{ |
public≠≠} É
Guid≠≠Ñ à
?≠≠à â
ClientProductId≠≠ä ô
{≠≠ö õ
get≠≠ú ü
;≠≠ü †
set≠≠° §
;≠≠§ •
}≠≠¶ ß
public≠≠® Æ
string≠≠Ø µ
Description≠≠∂ ¡
{≠≠¬ √
get≠≠ƒ «
;≠≠« »
set≠≠… Ã
;≠≠Ã Õ
}≠≠Œ œ
=≠≠– —
string≠≠“ ÿ
.≠≠ÿ Ÿ
Empty≠≠Ÿ ﬁ
;≠≠ﬁ ﬂ
public≠≠‡ Ê
decimal≠≠Á Ó
Amount≠≠Ô ı
{≠≠ˆ ˜
get≠≠¯ ˚
;≠≠˚ ¸
set≠≠˝ Ä
;≠≠Ä Å
}≠≠Ç É
public≠≠Ñ ä
int≠≠ã é
Order≠≠è î
{≠≠ï ñ
get≠≠ó ö
;≠≠ö õ
set≠≠ú ü
;≠≠ü †
}≠≠° ¢
}≠≠£ §
publicØØ 
sealed
ØØ 
class
ØØ 
Expense
ØØ 
{
ØØ 
public
ØØ $
Guid
ØØ% )
Id
ØØ* ,
{
ØØ- .
get
ØØ/ 2
;
ØØ2 3
set
ØØ4 7
;
ØØ7 8
}
ØØ9 :
=
ØØ; <
Guid
ØØ= A
.
ØØA B
NewGuid
ØØB I
(
ØØI J
)
ØØJ K
;
ØØK L
public
ØØM S
string
ØØT Z
Description
ØØ[ f
{
ØØg h
get
ØØi l
;
ØØl m
set
ØØn q
;
ØØq r
}
ØØs t
=
ØØu v
string
ØØw }
.
ØØ} ~
EmptyØØ~ É
;ØØÉ Ñ
publicØØÖ ã
GuidØØå ê

CategoryIdØØë õ
{ØØú ù
getØØû °
;ØØ° ¢
setØØ£ ¶
;ØØ¶ ß
}ØØ® ©
publicØØ™ ∞
ExpenseCategoryØØ± ¿
?ØØ¿ ¡
CategoryØØ¬  
{ØØÀ Ã
getØØÕ –
;ØØ– —
setØØ“ ’
;ØØ’ ÷
}ØØ◊ ÿ
publicØØŸ ﬂ
ExpenseTypeØØ‡ Î
TypeØØÏ 
{ØØÒ Ú
getØØÛ ˆ
;ØØˆ ˜
setØØ¯ ˚
;ØØ˚ ¸
}ØØ˝ ˛
publicØØˇ Ö
decimalØØÜ ç
AmountØØé î
{ØØï ñ
getØØó ö
;ØØö õ
setØØú ü
;ØØü †
}ØØ° ¢
publicØØ£ ©
stringØØ™ ∞
CurrencyØØ± π
{ØØ∫ ª
getØØº ø
;ØØø ¿
setØØ¡ ƒ
;ØØƒ ≈
}ØØ∆ «
=ØØ» …
$strØØ  œ
;ØØœ –
publicØØ— ◊
decimalØØÿ ﬂ
	AmountPenØØ‡ È
{ØØÍ Î
getØØÏ Ô
;ØØÔ 
setØØÒ Ù
;ØØÙ ı
}ØØˆ ˜
publicØØ¯ ˛
DateOnlyØØˇ á
DateØØà å
{ØØç é
getØØè í
;ØØí ì
setØØî ó
;ØØó ò
}ØØô ö
publicØØõ °
boolØØ¢ ¶
	RecurringØØß ∞
{ØØ± ≤
getØØ≥ ∂
;ØØ∂ ∑
setØØ∏ ª
;ØØª º
}ØØΩ æ
publicØØø ≈
BillingCycleØØ∆ “
?ØØ“ ”
RecurrenceCycleØØ‘ „
{ØØ‰ Â
getØØÊ È
;ØØÈ Í
setØØÎ Ó
;ØØÓ Ô
}ØØ Ò
public
∞∞ 
DateOnly
∞∞ 
?
∞∞ 
RecurrenceEndsAt
∞∞ "
{
∞∞# $
get
∞∞% (
;
∞∞( )
set
∞∞* -
;
∞∞- .
}
∞∞/ 0
public
≤≤ 

bool
≤≤ 
IsNonDeductible
≤≤ 
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
≤≤, -
public
¥¥ 

bool
¥¥ #
IsNonDomiciledService
¥¥ %
{
¥¥& '
get
¥¥( +
;
¥¥+ ,
set
¥¥- 0
;
¥¥0 1
}
¥¥2 3
public
¥¥4 :
string
¥¥; A
?
¥¥A B!
ForeignSupplierName
¥¥C V
{
¥¥W X
get
¥¥Y \
;
¥¥\ ]
set
¥¥^ a
;
¥¥a b
}
¥¥c d
public
¥¥e k
string
¥¥l r
?
¥¥r s%
ForeignSupplierCountry¥¥t ä
{¥¥ã å
get¥¥ç ê
;¥¥ê ë
set¥¥í ï
;¥¥ï ñ
}¥¥ó ò
public
∂∂ 

DateOnly
∂∂ 
?
∂∂ 
Form1662PaidAt
∂∂ #
{
∂∂$ %
get
∂∂& )
;
∂∂) *
set
∂∂+ .
;
∂∂. /
}
∂∂0 1
public
∂∂2 8
string
∂∂9 ?
?
∂∂? @
Form1662Number
∂∂A O
{
∂∂P Q
get
∂∂R U
;
∂∂U V
set
∂∂W Z
;
∂∂Z [
}
∂∂\ ]
}
∂∂^ _
publicππ 
sealed
ππ 
class
ππ 
TaxSettings
ππ 
{∫∫ 
public
ªª 

Guid
ªª 
Id
ªª 
{
ªª 
get
ªª 
;
ªª 
set
ªª 
;
ªª 
}
ªª  
=
ªª! "
Guid
ªª# '
.
ªª' (
NewGuid
ªª( /
(
ªª/ 0
)
ªª0 1
;
ªª1 2
public
ªª3 9
decimal
ªª: A
IgvRate
ªªB I
{
ªªJ K
get
ªªL O
;
ªªO P
set
ªªQ T
;
ªªT U
}
ªªV W
=
ªªX Y
$num
ªªZ _
;
ªª_ `
public
ªªa g
decimal
ªªh o
	RentaRate
ªªp y
{
ªªz {
get
ªª| 
;ªª Ä
setªªÅ Ñ
;ªªÑ Ö
}ªªÜ á
=ªªà â
$numªªä è
;ªªè ê
publicªªë ó
DateTimeªªò †
	UpdatedAtªª° ™
{ªª´ ¨
getªª≠ ∞
;ªª∞ ±
setªª≤ µ
;ªªµ ∂
}ªª∑ ∏
=ªªπ ∫
DateTimeªªª √
.ªª√ ƒ
UtcNowªªƒ  
;ªª  À
public
ææ 

string
ææ 
FacturaSeries
ææ 
{
ææ  !
get
ææ" %
;
ææ% &
set
ææ' *
;
ææ* +
}
ææ, -
=
ææ. /
$str
ææ0 6
;
ææ6 7
public
ææ8 >
int
ææ? B
FacturaNextNumber
ææC T
{
ææU V
get
ææW Z
;
ææZ [
set
ææ\ _
;
ææ_ `
}
ææa b
=
ææc d
$num
ææe f
;
ææf g
public
øø 

string
øø 
ReciboSeries
øø 
{
øø  
get
øø! $
;
øø$ %
set
øø& )
;
øø) *
}
øø+ ,
=
øø- .
$str
øø/ 5
;
øø5 6
public
øø7 =
int
øø> A
ReciboNextNumber
øøB R
{
øøS T
get
øøU X
;
øøX Y
set
øøZ ]
;
øø] ^
}
øø_ `
=
øøa b
$num
øøc d
;
øød e
public
¡¡ 

string
¡¡ 
?
¡¡ 
Ruc
¡¡ 
{
¡¡ 
get
¡¡ 
;
¡¡ 
set
¡¡ !
;
¡¡! "
}
¡¡# $
public
¡¡% +
bool
¡¡, 0
IsGoodTaxpayer
¡¡1 ?
{
¡¡@ A
get
¡¡B E
;
¡¡E F
set
¡¡G J
;
¡¡J K
}
¡¡L M
public
√√ 

bool
√√ 
Use1662AsCredit
√√ 
{
√√  !
get
√√" %
;
√√% &
set
√√' *
;
√√* +
}
√√, -
}ƒƒ 
public   
sealed
   
class
   
AnnualTaxSettings
   %
{ÀÀ 
public
ÃÃ 

Guid
ÃÃ 
Id
ÃÃ 
{
ÃÃ 
get
ÃÃ 
;
ÃÃ 
set
ÃÃ 
;
ÃÃ 
}
ÃÃ  
=
ÃÃ! "
Guid
ÃÃ# '
.
ÃÃ' (
NewGuid
ÃÃ( /
(
ÃÃ/ 0
)
ÃÃ0 1
;
ÃÃ1 2
public
ÃÃ3 9
int
ÃÃ: =
Year
ÃÃ> B
{
ÃÃC D
get
ÃÃE H
;
ÃÃH I
set
ÃÃJ M
;
ÃÃM N
}
ÃÃO P
public
ÃÃQ W
decimal
ÃÃX _
Uit
ÃÃ` c
{
ÃÃd e
get
ÃÃf i
;
ÃÃi j
set
ÃÃk n
;
ÃÃn o
}
ÃÃp q
public
ÕÕ 

decimal
ÕÕ 
ThresholdUits
ÕÕ  
{
ÕÕ! "
get
ÕÕ# &
;
ÕÕ& '
set
ÕÕ( +
;
ÕÕ+ ,
}
ÕÕ- .
=
ÕÕ/ 0
$num
ÕÕ1 4
;
ÕÕ4 5
public
ÕÕ6 <
decimal
ÕÕ= D
LowRate
ÕÕE L
{
ÕÕM N
get
ÕÕO R
;
ÕÕR S
set
ÕÕT W
;
ÕÕW X
}
ÕÕY Z
=
ÕÕ[ \
$num
ÕÕ] b
;
ÕÕb c
public
ÕÕd j
decimal
ÕÕk r
HighRate
ÕÕs {
{
ÕÕ| }
getÕÕ~ Å
;ÕÕÅ Ç
setÕÕÉ Ü
;ÕÕÜ á
}ÕÕà â
=ÕÕä ã
$numÕÕå í
;ÕÕí ì
}ŒŒ 
public’’ 
sealed
’’ 
class
’’ 

TaxDueDate
’’ 
{÷÷ 
public
◊◊ 

Guid
◊◊ 
Id
◊◊ 
{
◊◊ 
get
◊◊ 
;
◊◊ 
set
◊◊ 
;
◊◊ 
}
◊◊  
=
◊◊! "
Guid
◊◊# '
.
◊◊' (
NewGuid
◊◊( /
(
◊◊/ 0
)
◊◊0 1
;
◊◊1 2
public
ŸŸ 

DateOnly
ŸŸ 
Period
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
⁄⁄ 

DateOnly
⁄⁄ 
Digit0
⁄⁄ 
{
⁄⁄ 
get
⁄⁄  
;
⁄⁄  !
set
⁄⁄" %
;
⁄⁄% &
}
⁄⁄' (
public
⁄⁄) /
DateOnly
⁄⁄0 8
Digit1
⁄⁄9 ?
{
⁄⁄@ A
get
⁄⁄B E
;
⁄⁄E F
set
⁄⁄G J
;
⁄⁄J K
}
⁄⁄L M
public
⁄⁄N T
DateOnly
⁄⁄U ]

Digit2And3
⁄⁄^ h
{
⁄⁄i j
get
⁄⁄k n
;
⁄⁄n o
set
⁄⁄p s
;
⁄⁄s t
}
⁄⁄u v
public
⁄⁄w }
DateOnly⁄⁄~ Ü

Digit4And5⁄⁄á ë
{⁄⁄í ì
get⁄⁄î ó
;⁄⁄ó ò
set⁄⁄ô ú
;⁄⁄ú ù
}⁄⁄û ü
public⁄⁄† ¶
DateOnly⁄⁄ß Ø

Digit6And7⁄⁄∞ ∫
{⁄⁄ª º
get⁄⁄Ω ¿
;⁄⁄¿ ¡
set⁄⁄¬ ≈
;⁄⁄≈ ∆
}⁄⁄« »
public⁄⁄… œ
DateOnly⁄⁄– ÿ

Digit8And9⁄⁄Ÿ „
{⁄⁄‰ Â
get⁄⁄Ê È
;⁄⁄È Í
set⁄⁄Î Ó
;⁄⁄Ó Ô
}⁄⁄ Ò
public
‹‹ 

DateOnly
‹‹ 
GoodTaxpayer
‹‹  
{
‹‹! "
get
‹‹# &
;
‹‹& '
set
‹‹( +
;
‹‹+ ,
}
‹‹- .
public
›› 

DateTime
›› 
?
›› 
FiledAt
›› 
{
›› 
get
›› "
;
››" #
set
››$ '
;
››' (
}
››) *
public
ﬂﬂ 

decimal
ﬂﬂ 
?
ﬂﬂ 
IgvPaid
ﬂﬂ 
{
ﬂﬂ 
get
ﬂﬂ !
;
ﬂﬂ! "
set
ﬂﬂ# &
;
ﬂﬂ& '
}
ﬂﬂ( )
public
ﬂﬂ* 0
decimal
ﬂﬂ1 8
?
ﬂﬂ8 9
	RentaPaid
ﬂﬂ: C
{
ﬂﬂD E
get
ﬂﬂF I
;
ﬂﬂI J
set
ﬂﬂK N
;
ﬂﬂN O
}
ﬂﬂP Q
public
‚‚ 

DateOnly
‚‚ 
?
‚‚ 
DueFor
‚‚ 
(
‚‚ 
string
‚‚ "
?
‚‚" #
ruc
‚‚$ '
,
‚‚' (
bool
‚‚) -
goodTaxpayer
‚‚. :
)
‚‚: ;
{
„„ 
if
‰‰ 

(
‰‰ 
goodTaxpayer
‰‰ 
)
‰‰ 
return
‰‰  
GoodTaxpayer
‰‰! -
;
‰‰- .
if
ÂÂ 

(
ÂÂ 
string
ÂÂ 
.
ÂÂ  
IsNullOrWhiteSpace
ÂÂ %
(
ÂÂ% &
ruc
ÂÂ& )
)
ÂÂ) *
||
ÂÂ+ -
!
ÂÂ. /
char
ÂÂ/ 3
.
ÂÂ3 4
IsAsciiDigit
ÂÂ4 @
(
ÂÂ@ A
ruc
ÂÂA D
.
ÂÂD E
Trim
ÂÂE I
(
ÂÂI J
)
ÂÂJ K
[
ÂÂK L
^
ÂÂL M
$num
ÂÂM N
]
ÂÂN O
)
ÂÂO P
)
ÂÂP Q
return
ÂÂR X
null
ÂÂY ]
;
ÂÂ] ^
return
ÊÊ 
(
ÊÊ 
ruc
ÊÊ 
.
ÊÊ 
Trim
ÊÊ 
(
ÊÊ 
)
ÊÊ 
[
ÊÊ 
^
ÊÊ 
$num
ÊÊ 
]
ÊÊ 
-
ÊÊ  
$char
ÊÊ! $
)
ÊÊ$ %
switch
ÊÊ& ,
{
ÊÊ- .
$num
ÊÊ/ 0
=>
ÊÊ1 3
Digit0
ÊÊ4 :
,
ÊÊ: ;
$num
ÊÊ< =
=>
ÊÊ> @
Digit1
ÊÊA G
,
ÊÊG H
$num
ÊÊI J
or
ÊÊK M
$num
ÊÊN O
=>
ÊÊP R

Digit2And3
ÊÊS ]
,
ÊÊ] ^
$num
ÊÊ_ `
or
ÊÊa c
$num
ÊÊd e
=>
ÊÊf h

Digit4And5
ÊÊi s
,
ÊÊs t
$num
ÊÊu v
or
ÊÊw y
$num
ÊÊz {
=>
ÊÊ| ~

Digit6And7ÊÊ â
,ÊÊâ ä
_ÊÊã å
=>ÊÊç è

Digit8And9ÊÊê ö
}ÊÊõ ú
;ÊÊú ù
}
ÁÁ 
}ËË 
publicÓÓ 
static
ÓÓ 
class
ÓÓ 
TaxDueDateSeed
ÓÓ "
{ÔÔ 
public
 

static
 

TaxDueDate
 
[
 
]
 
Rows2026
 '
=>
( *
Rows
+ /
(
/ 0
$num
0 4
,
4 5
[
ÒÒ 
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
(
˝˝ 	
$str
˝˝	 
,
˝˝ 
$str
˝˝ #
,
˝˝# $
$str
˝˝% 1
,
˝˝1 2
$str
˝˝3 ?
,
˝˝? @
$str
˝˝A M
,
˝˝M N
$str
˝˝O [
,
˝˝[ \
$str
˝˝] i
)
˝˝i j
,
˝˝j k
]
˛˛ 
)
˛˛ 
;
˛˛ 
private
ÄÄ 
static
ÄÄ 

TaxDueDate
ÄÄ 
[
ÄÄ 
]
ÄÄ 
Rows
ÄÄ  $
(
ÄÄ$ %
int
ÄÄ% (
year
ÄÄ) -
,
ÄÄ- .
(
ÄÄ/ 0
string
ÄÄ0 6
,
ÄÄ6 7
string
ÄÄ8 >
,
ÄÄ> ?
string
ÄÄ@ F
,
ÄÄF G
string
ÄÄH N
,
ÄÄN O
string
ÄÄP V
,
ÄÄV W
string
ÄÄX ^
,
ÄÄ^ _
string
ÄÄ` f
)
ÄÄf g
[
ÄÄg h
]
ÄÄh i
months
ÄÄj p
)
ÄÄp q
=>
ÄÄr t
months
ÄÄu {
.
ÄÄ{ |
SelectÄÄ| Ç
(ÄÄÇ É
(ÄÄÉ Ñ
mÄÄÑ Ö
,ÄÄÖ Ü
iÄÄá à
)ÄÄà â
=>ÄÄä å
newÄÄç ê

TaxDueDateÄÄë õ
{
ÅÅ 
Id
ÉÉ 

=
ÉÉ 
new
ÉÉ 
Guid
ÉÉ 
(
ÉÉ 
$"
ÉÉ 
$str
ÉÉ 0
{
ÉÉ0 1
year
ÉÉ1 5
:
ÉÉ5 6
$str
ÉÉ6 8
}
ÉÉ8 9
{
ÉÉ9 :
i
ÉÉ: ;
+
ÉÉ< =
$num
ÉÉ> ?
:
ÉÉ? @
$str
ÉÉ@ B
}
ÉÉB C
"
ÉÉC D
)
ÉÉD E
,
ÉÉE F
Period
ÉÉG M
=
ÉÉN O
new
ÉÉP S
DateOnly
ÉÉT \
(
ÉÉ\ ]
year
ÉÉ] a
,
ÉÉa b
i
ÉÉc d
+
ÉÉe f
$num
ÉÉg h
,
ÉÉh i
$num
ÉÉj k
)
ÉÉk l
,
ÉÉl m
Digit0
ÑÑ 
=
ÑÑ 
DateOnly
ÑÑ 
.
ÑÑ 
Parse
ÑÑ 
(
ÑÑ  
m
ÑÑ  !
.
ÑÑ! "
Item1
ÑÑ" '
,
ÑÑ' (
CultureInfo
ÑÑ) 4
.
ÑÑ4 5
InvariantCulture
ÑÑ5 E
)
ÑÑE F
,
ÑÑF G
Digit1
ÑÑH N
=
ÑÑO P
DateOnly
ÑÑQ Y
.
ÑÑY Z
Parse
ÑÑZ _
(
ÑÑ_ `
m
ÑÑ` a
.
ÑÑa b
Item2
ÑÑb g
,
ÑÑg h
CultureInfo
ÑÑi t
.
ÑÑt u
InvariantCultureÑÑu Ö
)ÑÑÖ Ü
,ÑÑÜ á

Digit2And3ÑÑà í
=ÑÑì î
DateOnlyÑÑï ù
.ÑÑù û
ParseÑÑû £
(ÑÑ£ §
mÑÑ§ •
.ÑÑ• ¶
Item3ÑÑ¶ ´
,ÑÑ´ ¨
CultureInfoÑÑ≠ ∏
.ÑÑ∏ π 
InvariantCultureÑÑπ …
)ÑÑ…  
,ÑÑ  À

Digit4And5ÑÑÃ ÷
=ÑÑ◊ ÿ
DateOnlyÑÑŸ ·
.ÑÑ· ‚
ParseÑÑ‚ Á
(ÑÑÁ Ë
mÑÑË È
.ÑÑÈ Í
Item4ÑÑÍ Ô
,ÑÑÔ 
CultureInfoÑÑÒ ¸
.ÑÑ¸ ˝ 
InvariantCultureÑÑ˝ ç
)ÑÑç é
,ÑÑé è

Digit6And7
ÖÖ 
=
ÖÖ 
DateOnly
ÖÖ 
.
ÖÖ 
Parse
ÖÖ #
(
ÖÖ# $
m
ÖÖ$ %
.
ÖÖ% &
Item5
ÖÖ& +
,
ÖÖ+ ,
CultureInfo
ÖÖ- 8
.
ÖÖ8 9
InvariantCulture
ÖÖ9 I
)
ÖÖI J
,
ÖÖJ K

Digit8And9
ÖÖL V
=
ÖÖW X
DateOnly
ÖÖY a
.
ÖÖa b
Parse
ÖÖb g
(
ÖÖg h
m
ÖÖh i
.
ÖÖi j
Item6
ÖÖj o
,
ÖÖo p
CultureInfo
ÖÖq |
.
ÖÖ| }
InvariantCultureÖÖ} ç
)ÖÖç é
,ÖÖé è
GoodTaxpayerÖÖê ú
=ÖÖù û
DateOnlyÖÖü ß
.ÖÖß ®
ParseÖÖ® ≠
(ÖÖ≠ Æ
mÖÖÆ Ø
.ÖÖØ ∞
Item7ÖÖ∞ µ
,ÖÖµ ∂
CultureInfoÖÖ∑ ¬
.ÖÖ¬ √ 
InvariantCultureÖÖ√ ”
)ÖÖ” ‘
,ÖÖ‘ ’
}
ÜÜ 
)
ÜÜ 
.
ÜÜ 
ToArray
ÜÜ 
(
ÜÜ 
)
ÜÜ 
;
ÜÜ 
}áá 
publicçç 
sealed
çç 
class
çç  
PortalNotification
çç &
{
çç' (
public
çç) /
Guid
çç0 4
Id
çç5 7
{
çç8 9
get
çç: =
;
çç= >
set
çç? B
;
ççB C
}
ççD E
=
ççF G
Guid
ççH L
.
ççL M
NewGuid
ççM T
(
ççT U
)
ççU V
;
ççV W
public
ççX ^
Guid
çç_ c
ClientId
ççd l
{
ççm n
get
çço r
;
ççr s
set
ççt w
;
ççw x
}
ççy z
publicçç{ Å
stringççÇ à
Typeççâ ç
{ççé è
getççê ì
;ççì î
setççï ò
;ççò ô
}ççö õ
=ççú ù
stringççû §
.çç§ •
Emptyçç• ™
;çç™ ´
publicçç¨ ≤
boolçç≥ ∑
ForStaffçç∏ ¿
{çç¡ ¬
getçç√ ∆
;çç∆ «
setçç» À
;ççÀ Ã
}ççÕ Œ
publicççœ ’
stringçç÷ ‹
DataJsonçç› Â
{ççÊ Á
getççË Î
;ççÎ Ï
setççÌ 
;çç Ò
}ççÚ Û
=ççÙ ı
$strççˆ ˙
;çç˙ ˚
publicçç¸ Ç
stringççÉ â
?ççâ ä
	DedupeKeyççã î
{ççï ñ
getççó ö
;ççö õ
setççú ü
;ççü †
}çç° ¢
publicçç£ ©
DateTimeçç™ ≤
	CreatedAtçç≥ º
{ççΩ æ
getççø ¬
;çç¬ √
setççƒ «
;çç« »
}çç…  
=ççÀ Ã
DateTimeççÕ ’
.çç’ ÷
UtcNowçç÷ ‹
;çç‹ ›
}ççﬁ ﬂﬂ\
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