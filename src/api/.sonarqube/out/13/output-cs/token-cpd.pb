Áå
HC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\TaxDocumentService.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public 
sealed 
class 
TaxDocumentService &
(& '
RtresDbContext' 5
db6 8
,8 9
ILogger: A
<A B
TaxDocumentServiceB T
>T U
loggerV \
)\ ]
{ 
const 	
int
 
MaxAttempts 
= 
$num 
; 
static 

readonly 
TimeSpan 

LimaOffset '
=( )
TimeSpan* 2
.2 3
	FromHours3 <
(< =
-= >
$num> ?
)? @
;@ A
public 

static 
DateOnly 
	LimaToday $
($ %
DateTime% -
utc. 1
)1 2
=>3 5
DateOnly6 >
.> ?
FromDateTime? K
(K L
utcL O
+P Q

LimaOffsetR \
)\ ]
;] ^
public 

async 
Task 
< 
TaxDocument !
?! "
>" # 
IssueForPaymentAsync$ 8
(8 9
PaymentTransaction9 K
paymentL S
,S T
CancellationTokenU f
ctg i
)i j
{ 
try 
{ 	
if 
( 
payment 
. 
ClientProductId '
is( *
null+ /
||0 2
await3 8
db9 ;
.; <
TaxDocuments< H
.H I
AnyAsyncI Q
(Q R
xR S
=>T V
xW X
.X Y 
PaymentTransactionIdY m
==n p
paymentq x
.x y
Idy {
,{ |
ct} 
)	 Ä
)
Ä Å
return
Ç à
null
â ç
;
ç é
var 
item 
= 
await 
db 
.  
ClientProducts  .
.. /
Include/ 6
(6 7
x7 8
=>9 ;
x< =
.= >
Product> E
)E F
.F G
SingleAsyncG R
(R S
xS T
=>U W
xX Y
.Y Z
IdZ \
==] _
payment` g
.g h
ClientProductIdh w
,w x
cty {
){ |
;| }
var 
client 
= 
await 
db !
.! "
Clients" )
.) *
SingleAsync* 5
(5 6
x6 7
=>8 :
x; <
.< =
Id= ?
==@ B
itemC G
.G H
ClientIdH P
,P Q
ctR T
)T U
;U V
if 
( 
! 
client 
. 
RequiresTaxDocument +
||, .
item/ 3
.3 4
Product4 ;
is< >
null? C
)C D
returnE K
nullL P
;P Q
return 
await 

IssueAsync #
(# $
new$ '
TaxDocumentDraft( 8
(8 9
client9 ?
.? @
Id@ B
,B C
itemD H
.H I
ProductI P
.P Q
TaxDocumentTypeQ `
,` a
	LimaTodayb k
(k l
paymentl s
.s t
	CreatedAtt }
)} ~
,~ 
payment
Ä á
.
á à
Currency
à ê
,
ê ë
payment
í ô
.
ô ö
Amount
ö †
,
† °
payment
¢ ©
.
© ™
Years
™ Ø
>
∞ ±
$num
≤ ≥
?
¥ µ
$"
∂ ∏
$str
∏ Ω
{
Ω æ
payment
æ ≈
.
≈ ∆
InternalCode
∆ “
}
“ ”
$str
” ’
{
’ ÷
payment
÷ ›
.
› ﬁ
Years
ﬁ „
}
„ ‰
$str
‰ ˘
"
˘ ˙
:
˚ ¸
$"
˝ ˇ
$str
ˇ Ñ
{
Ñ Ö
payment
Ö å
.
å ç
InternalCode
ç ô
}
ô ö
"
ö õ
,
õ ú
payment
ù §
.
§ •
Id
• ß
,
ß ®
[
© ™
new
™ ≠
TaxDocumentLine
Æ Ω
{
æ ø
ClientProductId
¿ œ
=
– —
item
“ ÷
.
÷ ◊
Id
◊ Ÿ
,
Ÿ ⁄
Description
€ Ê
=
Á Ë
LineDescription
È ¯
(
¯ ˘
item
˘ ˝
)
˝ ˛
,
˛ ˇ
Amount
Ä Ü
=
á à
payment
â ê
.
ê ë
Amount
ë ó
}
ò ô
]
ô ö
)
ö õ
,
õ ú
ct
ù ü
)
ü †
;
† °
} 	
catch 
( 
	Exception 
ex 
) 
when !
(" #
ex# %
is& (
not) ,&
OperationCanceledException- G
)G H
{   	
logger"" 
."" 
LogError"" 
("" 
ex"" 
,"" 
$str""  W
,""W X
payment""Y `
.""` a
Id""a c
)""c d
;""d e
return## 
null## 
;## 
}$$ 	
}%% 
public++ 

async++ 
Task++ 
<++ 
TaxDocument++ !
>++! "

IssueAsync++# -
(++- .
TaxDocumentDraft++. >
draft++? D
,++D E
CancellationToken++F W
ct++X Z
)++Z [
{,, 
var-- 
(-- 
clientId-- 
,-- 
type-- 
,-- 
	issueDate-- &
,--& '
currency--( 0
,--0 1
total--2 7
,--7 8
notes--9 >
,--> ? 
paymentTransactionId--@ T
,--T U
lines--V [
)--[ \
=--] ^
draft--_ d
;--d e
for.. 
(.. 
var.. 
attempt.. 
=.. 
$num.. 
;.. 
attempt.. %
<=..& (
MaxAttempts..) 4
;..4 5
attempt..6 =
++..= ?
)..? @
{// 	
var00 
settings00 
=00 
await00  
db00! #
.00# $
TaxSettings00$ /
.00/ 0
FirstOrDefaultAsync000 C
(00C D
ct00D F
)00F G
??00H J
db00K M
.00M N
TaxSettings00N Y
.00Y Z
Add00Z ]
(00] ^
new00^ a
TaxSettings00b m
(00m n
)00n o
)00o p
.00p q
Entity00q w
;00w x
var11 
(11 
series11 
,11 
number11 
)11  
=11! "
await11# (
NextNumberAsync11) 8
(118 9
settings119 A
,11A B
type11C G
,11G H
ct11I K
)11K L
;11L M
var22 

baseAmount22 
=22 
type22 !
==22" $
TaxDocumentType22% 4
.224 5
Factura225 <
?22= >
Math22? C
.22C D
Round22D I
(22I J
total22J O
/22P Q
(22R S
$num22S T
+22U V
settings22W _
.22_ `
IgvRate22` g
)22g h
,22h i
$num22j k
)22k l
:22m n
total22o t
;22t u
var33 
document33 
=33 
new33 
TaxDocument33 *
{33+ ,
ClientId33- 5
=336 7
clientId338 @
,33@ A
Type33B F
=33G H
type33I M
,33M N
Series33O U
=33V W
series33X ^
,33^ _
Number33` f
=33g h
number33i o
,33o p
	IssueDate33q z
=33{ |
	issueDate	33} Ü
,
33Ü á
Currency
33à ê
=
33ë í
currency
33ì õ
,
33õ ú

BaseAmount
33ù ß
=
33® ©

baseAmount
33™ ¥
,
33¥ µ
	IgvAmount
33∂ ø
=
33¿ ¡
total
33¬ «
-
33» …

baseAmount
33  ‘
,
33‘ ’
TotalAmount
33÷ ·
=
33‚ „
total
33‰ È
,
33È Í
Notes
33Î 
=
33Ò Ú
notes
33Û ¯
,
33¯ ˘"
PaymentTransactionId
33˙ é
=
33è ê"
paymentTransactionId
33ë •
}
33¶ ß
;
33ß ®
db44 
.44 
TaxDocuments44 
.44 
Add44 
(44  
document44  (
)44( )
;44) *
var55 
docLines55 
=55 
(55 
lines55 !
??55" $
[55% &
]55& '
)55' (
.55( )
Select55) /
(55/ 0
(550 1
x551 2
,552 3
i554 5
)555 6
=>557 9
new55: =
TaxDocumentLine55> M
{55N O
TaxDocumentId55P ]
=55^ _
document55` h
.55h i
Id55i k
,55k l
ClientProductId55m |
=55} ~
x	55 Ä
.
55Ä Å
ClientProductId
55Å ê
,
55ê ë
Description
55í ù
=
55û ü
x
55† °
.
55° ¢
Description
55¢ ≠
,
55≠ Æ
Amount
55Ø µ
=
55∂ ∑
x
55∏ π
.
55π ∫
Amount
55∫ ¿
,
55¿ ¡
Order
55¬ «
=
55» …
i
55  À
}
55Ã Õ
)
55Õ Œ
.
55Œ œ
ToList
55œ ’
(
55’ ÷
)
55÷ ◊
;
55◊ ÿ
db66 
.66 
TaxDocumentLines66 
.66  
AddRange66  (
(66( )
docLines66) 1
)661 2
;662 3
try77 
{77 
await77 
db77 
.77 
SaveChangesAsync77 +
(77+ ,
ct77, .
)77. /
;77/ 0
return771 7
document778 @
;77@ A
}77B C
catch88 
(88 
DbUpdateException88 $
)88$ %
{99 
await;; 
DiscardAsync;; "
(;;" #
document;;# +
,;;+ ,
docLines;;- 5
,;;5 6
settings;;7 ?
,;;? @
ct;;A C
);;C D
;;;D E
if<< 
(<< 
attempt<< 
>=<< 
MaxAttempts<< *
)<<* +
throw<<, 1
;<<1 2
}== 
}>> 	
throw?? 
new?? %
InvalidOperationException?? +
(??+ ,
$str??, `
)??` a
;??a b
}@@ 
privateGG 
asyncGG 
TaskGG 
<GG 
(GG 
stringGG 
SeriesGG %
,GG% &
intGG' *
NumberGG+ 1
)GG1 2
>GG2 3
NextNumberAsyncGG4 C
(GGC D
TaxSettingsGGD O
settingsGGP X
,GGX Y
TaxDocumentTypeGGZ i
typeGGj n
,GGn o
CancellationToken	GGp Å
ct
GGÇ Ñ
)
GGÑ Ö
{HH 
varII 
	isFacturaII 
=II 
typeII 
==II 
TaxDocumentTypeII  /
.II/ 0
FacturaII0 7
;II7 8
varJJ 
seriesJJ 
=JJ 
	isFacturaJJ 
?JJ  
settingsJJ! )
.JJ) *
FacturaSeriesJJ* 7
:JJ8 9
settingsJJ: B
.JJB C
ReciboSeriesJJC O
;JJO P
varKK 
lastKK 
=KK 
awaitKK 
dbKK 
.KK 
TaxDocumentsKK (
.KK( )
WhereKK) .
(KK. /
xKK/ 0
=>KK1 3
xKK4 5
.KK5 6
TypeKK6 :
==KK; =
typeKK> B
&&KKC E
xKKF G
.KKG H
SeriesKKH N
==KKO Q
seriesKKR X
)KKX Y
.KKY Z
MaxAsyncKKZ b
(KKb c
xKKc d
=>KKe g
(KKh i
intKKi l
?KKl m
)KKm n
xKKn o
.KKo p
NumberKKp v
,KKv w
ctKKx z
)KKz {
??KK| ~
$num	KK Ä
;
KKÄ Å
varLL 
numberLL 
=LL 
MathLL 
.LL 
MaxLL 
(LL 
	isFacturaLL '
?LL( )
settingsLL* 2
.LL2 3
FacturaNextNumberLL3 D
:LLE F
settingsLLG O
.LLO P
ReciboNextNumberLLP `
,LL` a
lastLLb f
+LLg h
$numLLi j
)LLj k
;LLk l
ifMM 

(MM 
	isFacturaMM 
)MM 
settingsMM 
.MM  
FacturaNextNumberMM  1
=MM2 3
numberMM4 :
+MM; <
$numMM= >
;MM> ?
elseMM@ D
settingsMME M
.MMM N
ReciboNextNumberMMN ^
=MM_ `
numberMMa g
+MMh i
$numMMj k
;MMk l
returnNN 
(NN 
seriesNN 
,NN 
numberNN 
)NN 
;NN  
}OO 
privateRR 
asyncRR 
TaskRR 
DiscardAsyncRR #
(RR# $
TaxDocumentRR$ /
documentRR0 8
,RR8 9
IEnumerableRR: E
<RRE F
TaxDocumentLineRRF U
>RRU V
linesRRW \
,RR\ ]
TaxSettingsRR^ i
settingsRRj r
,RRr s
CancellationToken	RRt Ö
ct
RRÜ à
)
RRà â
{SS 
dbTT 

.TT
 
EntryTT 
(TT 
documentTT 
)TT 
.TT 
StateTT  
=TT! "
EntityStateTT# .
.TT. /
DetachedTT/ 7
;TT7 8
foreachUU 
(UU 
varUU 
lineUU 
inUU 
linesUU "
)UU" #
dbUU$ &
.UU& '
EntryUU' ,
(UU, -
lineUU- 1
)UU1 2
.UU2 3
StateUU3 8
=UU9 :
EntityStateUU; F
.UUF G
DetachedUUG O
;UUO P
awaitVV 
dbVV 
.VV 
EntryVV 
(VV 
settingsVV 
)VV  
.VV  !
ReloadAsyncVV! ,
(VV, -
ctVV- /
)VV/ 0
;VV0 1
}WW 
public^^ 

async^^ 
Task^^ 
<^^ %
TaxDocumentReversalResult^^ /
?^^/ 0
>^^0 1
ReverseAsync^^2 >
(^^> ?
Guid^^? C

documentId^^D N
,^^N O
string^^P V
reason^^W ]
,^^] ^
bool^^_ c
	notIssued^^d m
,^^m n
Guid^^o s
?^^s t
userId^^u {
,^^{ |
CancellationToken	^^} é
ct
^^è ë
)
^^ë í
{__ 
var`` 
document`` 
=`` 
await`` 
db`` 
.``  
TaxDocuments``  ,
.``, - 
SingleOrDefaultAsync``- A
(``A B
x``B C
=>``D F
x``G H
.``H I
Id``I K
==``L N

documentId``O Y
,``Y Z
ct``[ ]
)``] ^
;``^ _
ifaa 

(aa 
documentaa 
isaa 
nullaa 
)aa 
returnaa $
nullaa% )
;aa) *
varbb 
paymentbb 
=bb 
documentbb 
.bb  
PaymentTransactionIdbb 3
isbb4 6
Guidbb7 ;
	paymentIdbb< E
?bbF G
awaitbbH M
dbbbN P
.bbP Q
PaymentTransactionsbbQ d
.bbd e 
SingleOrDefaultAsyncbbe y
(bby z
xbbz {
=>bb| ~
x	bb Ä
.
bbÄ Å
Id
bbÅ É
==
bbÑ Ü
	paymentId
bbá ê
,
bbê ë
ct
bbí î
)
bbî ï
:
bbñ ó
null
bbò ú
;
bbú ù
varcc 
itemcc 
=cc 
paymentcc 
iscc 
nullcc "
?cc# $
nullcc% )
:cc* +
awaitcc, 1
RevertProductAsynccc2 D
(ccD E
paymentccE L
,ccL M
reasonccN T
,ccT U
ctccV X
)ccX Y
;ccY Z
vardd 
numberReleaseddd 
=dd 
	notIssueddd &
&&dd' )
awaitdd* /
ReleaseNumberAsyncdd0 B
(ddB C
documentddC K
,ddK L
ctddM O
)ddO P
;ddP Q
dbee 

.ee
 
PaymentReversalsee 
.ee 
Addee 
(ee  
newee  #
PaymentReversalee$ 3
{ff 	
ClientIdgg 
=gg 
documentgg 
.gg  
ClientIdgg  (
,gg( )
ClientProductIdgg* 9
=gg: ;
paymentgg< C
?ggC D
.ggD E
ClientProductIdggE T
,ggT U

PaymentKeyggV `
=gga b
paymentggc j
?ggj k
.ggk l*
PayPalOrderIdOrSubscriptionId	ggl â
,
ggâ ä
Method
ggã ë
=
ggí ì
payment
ggî õ
?
ggõ ú
.
ggú ù
Method
ggù £
,
gg£ §
InternalCode
gg• ±
=
gg≤ ≥
payment
gg¥ ª
?
ggª º
.
ggº Ω
InternalCode
ggΩ …
,
gg…  
Amounthh 
=hh 
paymenthh 
?hh 
.hh 
Amounthh $
??hh% '
documenthh( 0
.hh0 1
TotalAmounthh1 <
,hh< =
Currencyhh> F
=hhG H
paymenthhI P
?hhP Q
.hhQ R
CurrencyhhR Z
??hh[ ]
documenthh^ f
.hhf g
Currencyhhg o
,hho p
	AmountPenhhq z
=hh{ |
payment	hh} Ñ
?
hhÑ Ö
.
hhÖ Ü
	AmountPen
hhÜ è
,
hhè ê
PaidAt
hhë ó
=
hhò ô
payment
hhö °
?
hh° ¢
.
hh¢ £
	CreatedAt
hh£ ¨
,
hh¨ ≠
DocumentTypeii 
=ii 
documentii #
.ii# $
Typeii$ (
,ii( )
Seriesii* 0
=ii1 2
documentii3 ;
.ii; <
Seriesii< B
,iiB C
NumberiiD J
=iiK L
documentiiM U
.iiU V
NumberiiV \
,ii\ ]
	IssueDateii^ g
=iih i
documentiij r
.iir s
	IssueDateiis |
,ii| }
Reason	ii~ Ñ
=
iiÖ Ü
reason
iiá ç
,
iiç é
	NotIssued
iiè ò
=
iiô ö
	notIssued
iiõ §
,
ii§ •
NumberReleased
ii¶ ¥
=
iiµ ∂
numberReleased
ii∑ ≈
,
ii≈ ∆
ReversedByUserId
ii« ◊
=
iiÿ Ÿ
userId
ii⁄ ‡
,
ii‡ ·
}jj 	
)jj	 

;jj
 
dbkk 

.kk
 
TaxDocumentLineskk 
.kk 
RemoveRangekk '
(kk' (
awaitkk( -
dbkk. 0
.kk0 1
TaxDocumentLineskk1 A
.kkA B
WherekkB G
(kkG H
xkkH I
=>kkJ L
xkkM N
.kkN O
TaxDocumentIdkkO \
==kk] _
documentkk` h
.kkh i
Idkki k
)kkk l
.kkl m
ToListAsynckkm x
(kkx y
ctkky {
)kk{ |
)kk| }
;kk} ~
dbll 

.ll
 
TaxDocumentsll 
.ll 
Removell 
(ll 
documentll '
)ll' (
;ll( )
ifmm 

(mm 
paymentmm 
ismm 
notmm 
nullmm 
)mm  
{nn 	
varpp 
	dedupeKeypp 
=pp 
$"pp 
$strpp &
{pp& '
paymentpp' .
.pp. /)
PayPalOrderIdOrSubscriptionIdpp/ L
}ppL M
"ppM N
;ppN O
dbqq 
.qq 
NotificationLogsqq 
.qq  
RemoveRangeqq  +
(qq+ ,
awaitqq, 1
dbqq2 4
.qq4 5
NotificationLogsqq5 E
.qqE F
WhereqqF K
(qqK L
xqqL M
=>qqN P
xqqQ R
.qqR S
	DedupeKeyqqS \
==qq] _
	dedupeKeyqq` i
)qqi j
.qqj k
ToListAsyncqqk v
(qqv w
ctqqw y
)qqy z
)qqz {
;qq{ |
dbrr 
.rr 
PortalNotificationsrr "
.rr" #
RemoveRangerr# .
(rr. /
awaitrr/ 4
dbrr5 7
.rr7 8
PortalNotificationsrr8 K
.rrK L
WhererrL Q
(rrQ R
xrrR S
=>rrT V
xrrW X
.rrX Y
	DedupeKeyrrY b
==rrc e
	dedupeKeyrrf o
)rro p
.rrp q
ToListAsyncrrq |
(rr| }
ctrr} 
)	rr Ä
)
rrÄ Å
;
rrÅ Ç
dbss 
.ss 
PaymentTransactionsss "
.ss" #
Removess# )
(ss) *
paymentss* 1
)ss1 2
;ss2 3
}tt 	
awaituu 
dbuu 
.uu 
SaveChangesAsyncuu !
(uu! "
ctuu" $
)uu$ %
;uu% &
returnvv 
newvv %
TaxDocumentReversalResultvv ,
(vv, -
numberReleasedvv- ;
,vv; <
paymentvv= D
?vvD E
.vvE F
MethodvvF L
,vvL M
itemvvN R
?vvR S
.vvS T
StatusvvT Z
,vvZ [
itemvv\ `
?vv` a
.vva b
RenewsAtvvb j
,vvj k
itemvvl p
?vvp q
.vvq r
NextChargeAtvvr ~
)vv~ 
;	vv Ä
}ww 
privatezz 
asynczz 
Taskzz 
<zz 
ClientProductzz $
?zz$ %
>zz% &
RevertProductAsynczz' 9
(zz9 :
PaymentTransactionzz: L
paymentzzM T
,zzT U
stringzzV \
reasonzz] c
,zzc d
CancellationTokenzze v
ctzzw y
)zzy z
{{{ 
var|| 
report|| 
=|| 
await|| 
db|| 
.|| 
TransferReports|| -
.||- . 
SingleOrDefaultAsync||. B
(||B C
x||C D
=>||E G
x||H I
.||I J 
PaymentTransactionId||J ^
==||_ a
payment||b i
.||i j
Id||j l
,||l m
ct||n p
)||p q
;||q r
if}} 

(}} 
report}} 
is}} 
not}} 
null}} 
)}} 
(}}  !
report}}! '
.}}' (
Status}}( .
,}}. /
report}}0 6
.}}6 7
RejectionReason}}7 F
,}}F G
report}}H N
.}}N O 
PaymentTransactionId}}O c
)}}c d
=}}e f
(}}g h 
TransferReportStatus}}h |
.}}| }
	Rechazado	}}} Ü
,
}}Ü á
$"
}}à ä
$str
}}ä ö
{
}}ö õ
reason
}}õ °
}
}}° ¢
"
}}¢ £
,
}}£ §
null
}}• ©
)
}}© ™
;
}}™ ´
if~~ 

(~~ 
payment~~ 
.~~ 
ClientProductId~~ #
is~~$ &
not~~' *
Guid~~+ /
itemId~~0 6
||~~7 9
payment~~: A
.~~A B)
PayPalOrderIdOrSubscriptionId~~B _
.~~_ `

StartsWith~~` j
(~~j k
$str~~k t
,~~t u
StringComparison	~~v Ü
.
~~Ü á
Ordinal
~~á é
)
~~é è
)
~~è ê
return
~~ë ó
null
~~ò ú
;
~~ú ù
var 
item 
= 
await 
db 
. 
ClientProducts *
.* + 
SingleOrDefaultAsync+ ?
(? @
x@ A
=>B D
xE F
.F G
IdG I
==J L
itemIdM S
,S T
ctU W
)W X
;X Y
if
ÄÄ 

(
ÄÄ 
item
ÄÄ 
is
ÄÄ 
null
ÄÄ 
)
ÄÄ 
return
ÄÄ  
null
ÄÄ! %
;
ÄÄ% &
var
ÅÅ 
others
ÅÅ 
=
ÅÅ 
await
ÅÅ 
db
ÅÅ 
.
ÅÅ !
PaymentTransactions
ÅÅ 1
.
ÅÅ1 2
Where
ÅÅ2 7
(
ÅÅ7 8
x
ÅÅ8 9
=>
ÅÅ: <
x
ÅÅ= >
.
ÅÅ> ?
ClientProductId
ÅÅ? N
==
ÅÅO Q
itemId
ÅÅR X
&&
ÅÅY [
x
ÅÅ\ ]
.
ÅÅ] ^
Id
ÅÅ^ `
!=
ÅÅa c
payment
ÅÅd k
.
ÅÅk l
Id
ÅÅl n
)
ÅÅn o
.
ÅÅo p
Select
ÅÅp v
(
ÅÅv w
x
ÅÅw x
=>
ÅÅy {
x
ÅÅ| }
.
ÅÅ} ~
	CreatedAtÅÅ~ á
)ÅÅá à
.ÅÅà â
ToListAsyncÅÅâ î
(ÅÅî ï
ctÅÅï ó
)ÅÅó ò
;ÅÅò ô
item
ÉÉ 
.
ÉÉ 
OnPaymentReversed
ÉÉ 
(
ÉÉ 
item
ÉÉ #
.
ÉÉ# $
BillingCycle
ÉÉ$ 0
==
ÉÉ1 3
BillingCycle
ÉÉ4 @
.
ÉÉ@ A
Anual
ÉÉA F
?
ÉÉG H
item
ÉÉI M
.
ÉÉM N
RenewsAt
ÉÉN V
?
ÉÉV W
.
ÉÉW X
AddYears
ÉÉX `
(
ÉÉ` a
$num
ÉÉa b
-
ÉÉc d
payment
ÉÉe l
.
ÉÉl m
Years
ÉÉm r
)
ÉÉr s
:
ÉÉt u
item
ÉÉv z
.
ÉÉz {
NextChargeAtÉÉ{ á
)ÉÉá à
;ÉÉà â"
PayPalPaymentService
ÑÑ 
.
ÑÑ 
RollbackPeriod
ÑÑ +
(
ÑÑ+ ,
item
ÑÑ, 0
,
ÑÑ0 1
payment
ÑÑ2 9
.
ÑÑ9 :
Years
ÑÑ: ?
,
ÑÑ? @
others
ÑÑA G
.
ÑÑG H
All
ÑÑH K
(
ÑÑK L
x
ÑÑL M
=>
ÑÑN P
x
ÑÑQ R
<=
ÑÑS U
payment
ÑÑV ]
.
ÑÑ] ^
	CreatedAt
ÑÑ^ g
)
ÑÑg h
)
ÑÑh i
;
ÑÑi j
if
áá 

(
áá 
others
áá 
.
áá 
Count
áá 
==
áá 
$num
áá 
&&
áá  
item
áá! %
.
áá% &
Status
áá& ,
!=
áá- /!
ClientProductStatus
áá0 C
.
ááC D
	Cancelado
ááD M
&&
ááN P
(
ááQ R
payment
ááR Y
.
ááY Z
Method
ááZ `
==
ááa c
PaymentMethods
áád r
.
áár s
PayPal
áás y
||
ááz |
reportáá} É
isááÑ Ü
notááá ä
nullááã è
)ááè ê
)ááê ë
{
àà 	
item
ââ 
.
ââ 
Status
ââ 
=
ââ !
ClientProductStatus
ââ -
.
ââ- .
	Pendiente
ââ. 7
;
ââ7 8
if
ää 
(
ää 
item
ää 
.
ää 
RenewsAt
ää 
==
ää  
payment
ää! (
.
ää( )
	CreatedAt
ää) 2
)
ää2 3
item
ää4 8
.
ää8 9
RenewsAt
ää9 A
=
ääB C
null
ääD H
;
ääH I
if
ãã 
(
ãã 
item
ãã 
.
ãã 
NextChargeAt
ãã !
==
ãã" $
payment
ãã% ,
.
ãã, -
	CreatedAt
ãã- 6
)
ãã6 7
item
ãã8 <
.
ãã< =
NextChargeAt
ãã= I
=
ããJ K
null
ããL P
;
ããP Q
}
åå 	
else
çç 
item
çç 
.
çç 
Status
çç 
=
çç  
RenewalReminderJob
çç -
.
çç- .
	StatusFor
çç. 7
(
çç7 8
item
çç8 <
.
çç< =
Status
çç= C
,
ççC D
item
ççE I
.
ççI J
RenewsAt
ççJ R
,
ççR S
DateTime
ççT \
.
çç\ ]
UtcNow
çç] c
)
ççc d
;
ççd e
return
éé 
item
éé 
;
éé 
}
èè 
private
ëë 
async
ëë 
Task
ëë 
<
ëë 
bool
ëë 
>
ëë  
ReleaseNumberAsync
ëë /
(
ëë/ 0
TaxDocument
ëë0 ;
document
ëë< D
,
ëëD E
CancellationToken
ëëF W
ct
ëëX Z
)
ëëZ [
{
íí 
var
ìì 
settings
ìì 
=
ìì 
await
ìì 
db
ìì 
.
ìì  
TaxSettings
ìì  +
.
ìì+ ,!
FirstOrDefaultAsync
ìì, ?
(
ìì? @
ct
ìì@ B
)
ììB C
;
ììC D
if
îî 

(
îî 
settings
îî 
is
îî 
null
îî 
||
îî 
await
îî  %
db
îî& (
.
îî( )
TaxDocuments
îî) 5
.
îî5 6
AnyAsync
îî6 >
(
îî> ?
x
îî? @
=>
îîA C
x
îîD E
.
îîE F
Type
îîF J
==
îîK M
document
îîN V
.
îîV W
Type
îîW [
&&
îî\ ^
x
îî_ `
.
îî` a
Series
îîa g
==
îîh j
document
îîk s
.
îîs t
Series
îît z
&&
îî{ }
x
îî~ 
.îî Ä
NumberîîÄ Ü
>îîá à
documentîîâ ë
.îîë í
Numberîîí ò
,îîò ô
ctîîö ú
)îîú ù
)îîù û
returnîîü •
falseîî¶ ´
;îî´ ¨
var
ïï 
	isFactura
ïï 
=
ïï 
document
ïï  
.
ïï  !
Type
ïï! %
==
ïï& (
TaxDocumentType
ïï) 8
.
ïï8 9
Factura
ïï9 @
;
ïï@ A
if
ññ 

(
ññ 
(
ññ 
	isFactura
ññ 
?
ññ 
settings
ññ !
.
ññ! "
FacturaSeries
ññ" /
:
ññ0 1
settings
ññ2 :
.
ññ: ;
ReciboSeries
ññ; G
)
ññG H
!=
ññI K
document
ññL T
.
ññT U
Series
ññU [
||
ññ\ ^
(
ññ_ `
	isFactura
ññ` i
?
ññj k
settings
ññl t
.
ññt u 
FacturaNextNumberññu Ü
:ññá à
settingsññâ ë
.ññë í 
ReciboNextNumberññí ¢
)ññ¢ £
!=ññ§ ¶
documentññß Ø
.ññØ ∞
Numberññ∞ ∂
+ññ∑ ∏
$numññπ ∫
)ññ∫ ª
returnññº ¬
falseññ√ »
;ññ» …
if
óó 

(
óó 
	isFactura
óó 
)
óó 
settings
óó 
.
óó  
FacturaNextNumber
óó  1
=
óó2 3
document
óó4 <
.
óó< =
Number
óó= C
;
óóC D
else
óóE I
settings
óóJ R
.
óóR S
ReciboNextNumber
óóS c
=
óód e
document
óóf n
.
óón o
Number
óóo u
;
óóu v
return
òò 
true
òò 
;
òò 
}
ôô 
public
úú 

static
úú 
string
úú 
LineDescription
úú (
(
úú( )
ClientProduct
úú) 6
item
úú7 ;
)
úú; <
{
ùù 
var
ûû 
name
ûû 
=
ûû 
item
ûû 
.
ûû 
Product
ûû 
?
ûû  
.
ûû  !
Name
ûû! %
??
ûû& (
$str
ûû) 3
;
ûû3 4
var
üü 
text
üü 
=
üü 
string
üü 
.
üü  
IsNullOrWhiteSpace
üü ,
(
üü, -
item
üü- 1
.
üü1 2

DomainName
üü2 <
)
üü< =
?
üü> ?
name
üü@ D
:
üüE F
$"
üüG I
{
üüI J
name
üüJ N
}
üüN O
$str
üüO R
{
üüR S
item
üüS W
.
üüW X

DomainName
üüX b
}
üüb c
"
üüc d
;
üüd e
return
†† 
text
†† 
.
†† 
Length
†† 
>
†† 
$num
††  
?
††! "
text
††# '
[
††' (
..
††( *
$num
††* -
]
††- .
:
††/ 0
text
††1 5
;
††5 6
}
°° 
}¢¢ 
public•• 
sealed
•• 
record
•• '
TaxDocumentReversalResult
•• .
(
••. /
bool
••/ 3
NumberReleased
••4 B
,
••B C
string
••D J
?
••J K
PaymentMethod
••L Y
,
••Y Z!
ClientProductStatus
••[ n
?
••n o
ProductStatus
••p }
,
••} ~
DateTime•• á
?••á à
RenewsAt••â ë
,••ë í
DateTime••ì õ
?••õ ú
NextChargeAt••ù ©
)••© ™
;••™ ´
public´´ 
sealed
´´ 
record
´´ 
TaxDocumentDraft
´´ %
(
´´% &
Guid
´´& *
ClientId
´´+ 3
,
´´3 4
TaxDocumentType
´´5 D
Type
´´E I
,
´´I J
DateOnly
´´K S
	IssueDate
´´T ]
,
´´] ^
string
´´_ e
Currency
´´f n
,
´´n o
decimal
´´p w
Total
´´x }
,
´´} ~
string´´ Ö
?´´Ö Ü
Notes´´á å
,´´å ç
Guid´´é í
?´´í ì$
PaymentTransactionId´´î ®
,´´® ©
IReadOnlyList´´™ ∑
<´´∑ ∏
TaxDocumentLine´´∏ «
>´´« »
?´´» …
Lines´´  œ
=´´– —
null´´“ ÷
)´´÷ ◊
;´´◊ ÿÛë
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\PayPalPaymentService.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public 
sealed 
class  
PayPalPaymentService (
(( )
RtresDbContext) 7
db8 :
,: ;
IPayPalClient< I
payPalJ P
,P Q
INotificationSenderR e
notificationsf s
,s t
TaxDocumentService	u á
taxDocuments
à î
,
î ï
ILogger
ñ ù
<
ù û"
PayPalPaymentService
û ≤
>
≤ ≥
logger
¥ ∫
)
∫ ª
{ 
public 

Task 
ConfirmAsync 
( 
ClientProduct *
item+ /
,/ 0
CancellationToken1 B
ctC E
)E F
=>G I
item 
. 
BillingCycle 
. 
IsSubscription (
(( )
)) *
&&+ -
!. /
string/ 5
.5 6
IsNullOrWhiteSpace6 H
(H I
itemI M
.M N 
PayPalSubscriptionIdN b
)b c
?d e!
SyncSubscriptionAsyncf {
({ |
item	| Ä
,
Ä Å
ct
Ç Ñ
)
Ñ Ö
:
Ü á
CaptureAsync
à î
(
î ï
item
ï ô
,
ô ö
ct
õ ù
)
ù û
;
û ü
public 

async 
Task !
SyncSubscriptionAsync +
(+ ,
ClientProduct, 9
item: >
,> ?
CancellationToken@ Q
ctR T
)T U
{ 
var 
subscription 
= 
await  
payPal! '
.' ( 
GetSubscriptionAsync( <
(< =
item= A
.A B 
PayPalSubscriptionIdB V
!V W
,W X
ctY [
)[ \
;\ ]
if 

( 
subscription 
. 
Status 
is  "
$str# .
or/ 1
$str2 ;
&&< >
item? C
.C D
StatusD J
!=K M
ClientProductStatusN a
.a b
	Canceladob k
)k l
{ 	
item 
. 
Status 
= 
ClientProductStatus -
.- .
	Cancelado. 7
;7 8
await   
db   
.   
SaveChangesAsync   %
(  % &
ct  & (
)  ( )
;  ) *
return!! 
;!! 
}"" 	
if## 

(## 
subscription## 
.## 
Status## 
!=##  "
$str### +
)##+ ,
{$$ 	
logger%% 
.%% 
LogInformation%% !
(%%! "
$str%%" |
,%%| }
subscription	%%~ ä
.
%%ä ã
Id
%%ã ç
,
%%ç é
subscription
%%è õ
.
%%õ ú
Status
%%ú ¢
,
%%¢ £
item
%%§ ®
.
%%® ©
Id
%%© ´
)
%%´ ¨
;
%%¨ ≠
return&& 
;&& 
}'' 	
foreach(( 
((( 
var(( 
payment(( 
in(( 
subscription((  ,
.((, -
Payments((- 5
)((5 6
await((7 <
ApplyPaymentAsync((= N
(((N O
item((O S
,((S T
payment((U \
.((\ ]
Id((] _
,((_ `
payment((a h
.((h i
Amount((i o
,((o p
payment((q x
.((x y
Currency	((y Å
,
((Å Ç
ct
((É Ö
)
((Ö Ü
;
((Ü á
item)) 
.)) 
Status)) 
=)) 
ClientProductStatus)) )
.))) *
Activo))* 0
;))0 1
if** 

(** 
subscription** 
.** 
NextBillingTime** (
is**) +
DateTime**, 4
next**5 9
)**9 :
item**; ?
.**? @
NextChargeAt**@ L
=**M N
next**O S
;**S T
await++ 
db++ 
.++ 
SaveChangesAsync++ !
(++! "
ct++" $
)++$ %
;++% &
},, 
public// 

async// 
Task// 
CaptureAsync// "
(//" #
ClientProduct//# 0
item//1 5
,//5 6
CancellationToken//7 H
ct//I K
)//K L
{00 
var11 
orderId11 
=11 
item11 
.11 
PayPalOrderId11 (
;11( )
if22 

(22 
string22 
.22 
IsNullOrWhiteSpace22 %
(22% &
orderId22& -
)22- .
||22/ 1
await222 7
PaymentExistsAsync228 J
(22J K
orderId22K R
,22R S
ct22T V
)22V W
)22W X
return22Y _
;22_ `
var33 
capture33 
=33 
await33 
payPal33 "
.33" #
CaptureOrderAsync33# 4
(334 5
orderId335 <
,33< =
ct33> @
)33@ A
;33A B
if44 

(44 
capture44 
.44 
Status44 
==44 
$str44 )
&&44* ,
capture44- 4
.444 5
Amount445 ;
is44< >
decimal44? F
amount44G M
)44M N
await55 
ApplyPaymentAsync55 #
(55# $
item55$ (
,55( )
orderId55* 1
,551 2
amount553 9
,559 :
capture55; B
.55B C
Currency55C K
,55K L
ct55M O
)55O P
;55P Q
else66 
logger77 
.77 

LogWarning77 
(77 
$str77 ~
,77~ 
orderId
77Ä á
,
77á à
capture
77â ê
.
77ê ë
Status
77ë ó
,
77ó ò
item
77ô ù
.
77ù û
Id
77û †
)
77† °
;
77° ¢
}88 
publicAA 

asyncAA 
TaskAA 
<AA 
boolAA 
>AA 
ApplyPaymentAsyncAA -
(AA- .
ClientProductAA. ;
itemAA< @
,AA@ A
stringAAB H
transactionKeyAAI W
,AAW X
decimalAAY `
amountAAa g
,AAg h
stringAAi o
?AAo p
currencyAAq y
,AAy z
CancellationToken	AA{ å
ct
AAç è
,
AAè ê
PaymentOptions
AAë ü
?
AAü †
options
AA° ®
=
AA© ™
null
AA´ Ø
)
AAØ ∞
{BB 
ifCC 

(CC 
awaitCC 
PaymentExistsAsyncCC $
(CC$ %
transactionKeyCC% 3
,CC3 4
ctCC5 7
)CC7 8
)CC8 9
returnCC: @
falseCCA F
;CCF G
varDD 
(DD 
methodDD 
,DD 
paidAtDD 
,DD 
yearsDD "
)DD" #
=DD$ %
optionsDD& -
??DD. 0
newDD1 4
(DD4 5
)DD5 6
;DD6 7
varEE 
whenEE 
=EE 
paidAtEE 
??EE 
DateTimeEE %
.EE% &
UtcNowEE& ,
;EE, -
varFF 

orderYearsFF 
=FF 
transactionKeyFF '
==FF( *
itemFF+ /
.FF/ 0
PayPalOrderIdFF0 =
?FF> ?
itemFF@ D
.FFD E
PayPalOrderYearsFFE U
:FFV W
nullFFX \
;FF\ ]
varGG 
	paidYearsGG 
=GG 
itemGG 
.GG 
BillingCycleGG )
==GG* ,
BillingCycleGG- 9
.GG9 :
AnualGG: ?
?GG@ A
MathGGB F
.GGF G
ClampGGG L
(GGL M
yearsGGM R
??GGS U

orderYearsGGV `
??GGa c
$numGGd e
,GGe f
$numGGg h
,GGh i 
ClientProductPricingGGj ~
.GG~ 
MaxPrepaidYears	GG é
)
GGé è
:
GGê ë
$num
GGí ì
;
GGì î
varHH 
transactionHH 
=HH 
newHH 
PaymentTransactionHH 0
{HH1 2
ClientIdHH3 ;
=HH< =
itemHH> B
.HHB C
ClientIdHHC K
,HHK L
ClientProductIdHHM \
=HH] ^
itemHH_ c
.HHc d
IdHHd f
,HHf g*
PayPalOrderIdOrSubscriptionId	HHh Ö
=
HHÜ á
transactionKey
HHà ñ
,
HHñ ó
Amount
HHò û
=
HHü †
amount
HH° ß
,
HHß ®
Currency
HH© ±
=
HH≤ ≥
currency
HH¥ º
??
HHΩ ø
item
HH¿ ƒ
.
HHƒ ≈
Product
HH≈ Ã
?
HHÃ Õ
.
HHÕ Œ
Currency
HHŒ ÷
??
HH◊ Ÿ
$str
HH⁄ ﬂ
,
HHﬂ ‡
Status
HH· Á
=
HHË È
$str
HHÍ ı
,
HHı ˆ
Method
HH˜ ˝
=
HH˛ ˇ
method
HHÄ Ü
,
HHÜ á
	CreatedAt
HHà ë
=
HHí ì
when
HHî ò
,
HHò ô
Years
HHö ü
=
HH† °
	paidYears
HH¢ ´
}
HH¨ ≠
;
HH≠ Æ
transactionII 
.II 
InternalCodeII  
=II! "
awaitII# (
dbII) +
.II+ ,!
NextInternalCodeAsyncII, A
(IIA B
ctIIB D
)IID E
;IIE F
transactionJJ 
.JJ 
	AmountPenJJ 
=JJ 
amountJJ  &
*JJ' (
awaitJJ) .
dbJJ/ 1
.JJ1 2
RateToPenAsyncJJ2 @
(JJ@ A
transactionJJA L
.JJL M
CurrencyJJM U
,JJU V
DateOnlyJJW _
.JJ_ `
FromDateTimeJJ` l
(JJl m
transactionJJm x
.JJx y
	CreatedAt	JJy Ç
)
JJÇ É
,
JJÉ Ñ
ct
JJÖ á
)
JJá à
;
JJà â
dbKK 

.KK
 
PaymentTransactionsKK 
.KK 
AddKK "
(KK" #
transactionKK# .
)KK. /
;KK/ 0
itemLL 
.LL 
StatusLL 
=LL 
ClientProductStatusLL )
.LL) *
ActivoLL* 0
;LL0 1
ExtendPeriodNN 
(NN 
itemNN 
,NN 
whenNN 
)NN  
;NN  !
itemOO 
.OO 
OnPaymentAppliedOO 
(OO 
)OO 
;OO  
forPP 
(PP 
varPP 
yearPP 
=PP 
$numPP 
;PP 
yearPP 
<PP  !
	paidYearsPP" +
;PP+ ,
yearPP- 1
++PP1 3
)PP3 4
ExtendPeriodPP5 A
(PPA B
itemPPB F
,PPF G
whenPPH L
)PPL M
;PPM N
tryQQ 
{QQ 
awaitQQ 
dbQQ 
.QQ 
SaveChangesAsyncQQ '
(QQ' (
ctQQ( *
)QQ* +
;QQ+ ,
}QQ- .
catchRR 
(RR 
DbUpdateExceptionRR  
)RR  !
{SS 	
ifUU 
(UU 
!UU 
awaitUU 
PaymentExistsAsyncUU )
(UU) *
transactionKeyUU* 8
,UU8 9
ctUU: <
)UU< =
)UU= >
throwUU? D
;UUD E
dbVV 
.VV 
EntryVV 
(VV 
transactionVV  
)VV  !
.VV! "
StateVV" '
=VV( )
EntityStateVV* 5
.VV5 6
DetachedVV6 >
;VV> ?
awaitWW 
dbWW 
.WW 
EntryWW 
(WW 
itemWW 
)WW  
.WW  !
ReloadAsyncWW! ,
(WW, -
ctWW- /
)WW/ 0
;WW0 1
returnXX 
falseXX 
;XX 
}YY 	
await[[ 
taxDocuments[[ 
.[[  
IssueForPaymentAsync[[ /
([[/ 0
transaction[[0 ;
,[[; <
ct[[= ?
)[[? @
;[[@ A
if\\ 

(\\ 
await\\ 
db\\ 
.\\ 
Clients\\ 
.\\ 
	FindAsync\\ &
(\\& '
[\\' (
item\\( ,
.\\, -
ClientId\\- 5
]\\5 6
,\\6 7
ct\\8 :
)\\: ;
is\\< >
Client\\? E
client\\F L
)\\L M
await]] 
notifications]] 
.]]  
	SendAsync]]  )
(]]) *
client]]* 0
,]]0 1
new]]2 5
Notification]]6 B
(]]B C
NotificationType]]C S
.]]S T
PaymentReceived]]T c
,]]c d
new]]e h
(]]h i
)]]i j
{^^ 
[__ 
$str__ 
]__ 
=__ 
item__ "
.__" #
Product__# *
?__* +
.__+ ,
Name__, 0
??__1 3
$str__4 6
,__6 7
[`` 
$str`` 
]`` 
=`` 
amount`` #
.``# $
ToString``$ ,
(``, -
CultureInfo``- 8
.``8 9
InvariantCulture``9 I
)``I J
,``J K
[aa 
$straa 
]aa 
=aa 
transactionaa *
.aa* +
Currencyaa+ 3
,aa3 4
}bb 
,bb 
$"bb 
$strbb 
{bb 
transactionKeybb (
}bb( )
"bb) *
)bb* +
,bb+ ,
ctbb- /
)bb/ 0
;bb0 1
returncc 
truecc 
;cc 
}dd 
publicll 

staticll 
voidll 
ExtendPeriodll #
(ll# $
ClientProductll$ 1
itemll2 6
,ll6 7
DateTimell8 @
nowllA D
)llD E
{mm 
switchnn 
(nn 
itemnn 
.nn 
BillingCyclenn !
)nn! "
{oo 	
casepp 
BillingCyclepp 
.pp 
Anualpp #
:pp# $
itemqq 
.qq 
RenewsAtqq 
=qq 
(qq  !
itemqq! %
.qq% &
RenewsAtqq& .
isqq/ 1
DateTimeqq2 :
renewsAtqq; C
&&qqD F
renewsAtqqG O
>qqP Q
nowqqR U
?qqV W
renewsAtqqX `
:qqa b
nowqqc f
)qqf g
.qqg h
AddYearsqqh p
(qqp q
$numqqq r
)qqr s
;qqs t
breakrr 
;rr 
casess 
varss 
cycless 
whenss 
cycless  %
.ss% &
SubscriptionMonthsss& 8
(ss8 9
)ss9 :
isss; =
intss> A
monthsssB H
:ssH I
itemtt 
.tt 
NextChargeAttt !
=tt" #
nowtt$ '
.tt' (
	AddMonthstt( 1
(tt1 2
monthstt2 8
)tt8 9
;tt9 :
breakuu 
;uu 
}vv 	
}ww 
public}} 

static}} 
void}} 
RollbackPeriod}} %
(}}% &
ClientProduct}}& 3
item}}4 8
,}}8 9
int}}: =
years}}> C
,}}C D
bool}}E I
isLatestPayment}}J Y
)}}Y Z
{~~ 
switch 
( 
item 
. 
BillingCycle !
)! "
{
ÄÄ 	
case
ÅÅ 
BillingCycle
ÅÅ 
.
ÅÅ 
Anual
ÅÅ #
:
ÅÅ# $
item
ÇÇ 
.
ÇÇ 
RenewsAt
ÇÇ 
=
ÇÇ 
item
ÇÇ  $
.
ÇÇ$ %
RenewsAt
ÇÇ% -
?
ÇÇ- .
.
ÇÇ. /
AddYears
ÇÇ/ 7
(
ÇÇ7 8
-
ÇÇ8 9
years
ÇÇ9 >
)
ÇÇ> ?
;
ÇÇ? @
break
ÉÉ 
;
ÉÉ 
case
ÑÑ 
var
ÑÑ 
cycle
ÑÑ 
when
ÑÑ 
cycle
ÑÑ  %
.
ÑÑ% & 
SubscriptionMonths
ÑÑ& 8
(
ÑÑ8 9
)
ÑÑ9 :
is
ÑÑ; =
int
ÑÑ> A
months
ÑÑB H
&&
ÑÑI K
isLatestPayment
ÑÑL [
:
ÑÑ[ \
item
ÖÖ 
.
ÖÖ 
NextChargeAt
ÖÖ !
=
ÖÖ" #
item
ÖÖ$ (
.
ÖÖ( )
NextChargeAt
ÖÖ) 5
?
ÖÖ5 6
.
ÖÖ6 7
	AddMonths
ÖÖ7 @
(
ÖÖ@ A
-
ÖÖA B
months
ÖÖB H
)
ÖÖH I
;
ÖÖI J
break
ÜÜ 
;
ÜÜ 
}
áá 	
}
àà 
private
ãã 
async
ãã 
Task
ãã 
<
ãã 
bool
ãã 
>
ãã  
PaymentExistsAsync
ãã /
(
ãã/ 0
string
ãã0 6
transactionKey
ãã7 E
,
ããE F
CancellationToken
ããG X
ct
ããY [
)
ãã[ \
=>
ãã] _
await
åå 
db
åå 
.
åå !
PaymentTransactions
åå $
.
åå$ %
AnyAsync
åå% -
(
åå- .
x
åå. /
=>
åå0 2
x
åå3 4
.
åå4 5+
PayPalOrderIdOrSubscriptionId
åå5 R
==
ååS U
transactionKey
ååV d
,
ååd e
ct
ååf h
)
ååh i
||
çç 

await
çç 
db
çç 
.
çç 
PaymentReversals
çç $
.
çç$ %
AnyAsync
çç% -
(
çç- .
x
çç. /
=>
çç0 2
x
çç3 4
.
çç4 5

PaymentKey
çç5 ?
==
çç@ B
transactionKey
ççC Q
&&
ççR T
x
ççU V
.
ççV W
Method
ççW ]
==
çç^ `
PaymentMethods
çça o
.
çço p
PayPal
ççp v
,
ççv w
ct
ççx z
)
ççz {
;
çç{ |
}éé 
publicîî 
sealed
îî 
record
îî 
PaymentOptions
îî #
(
îî# $
string
îî$ *
Method
îî+ 1
=
îî2 3
PaymentMethods
îî4 B
.
îîB C
PayPal
îîC I
,
îîI J
DateTime
îîK S
?
îîS T
PaidAt
îîU [
=
îî\ ]
null
îî^ b
,
îîb c
int
îîd g
?
îîg h
Years
îîi n
=
îîo p
null
îîq u
)
îîu v
;
îîv w∫Q
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\PayPalCheckoutService.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public 
sealed 
class !
PayPalCheckoutService )
() *
IPayPalClient* 7
payPal8 >
,> ?
IConfiguration@ N
configurationO \
)\ ]
{ 
public 

async 
Task 
< 
PayPalCheckout $
>$ %

StartAsync& 0
(0 1
ClientProduct1 >
item? C
,C D
ProductE L
productM T
,T U
HttpRequestV a
?a b
requestc j
,j k
CancellationTokenl }
ct	~ Ä
,
Ä Å
decimal
Ç â
igvRate
ä ë
=
í ì
$num
î ñ
,
ñ ó
int
ò õ
years
ú °
=
¢ £
$num
§ •
)
• ¶
{ 
if 

( 
item 
. 
ValidateYears 
( 
years $
)$ %
is& (
string) /

yearsError0 :
): ;
throw< A
newB E%
InvalidOperationExceptionF _
(_ `

yearsError` j
)j k
;k l
var 
baseUrl 
= 
PortalBaseUrl #
(# $
request$ +
,+ ,
configuration- :
): ;
;; <
var 
	returnUrl 
= 
$" 
{ 
baseUrl "
}" #
$str# C
{C D
itemD H
.H I
IdI K
}K L
"L M
;M N
var 
	cancelUrl 
= 
$" 
{ 
baseUrl "
}" #
$str# -
"- .
;. /
var 
	listPrice 
=  
ClientProductPricing ,
., -
WithIgv- 4
(4 5
item5 9
.9 :
	ListPrice: C
(C D
productD K
)K L
??M O
throwP U
newV Y%
InvalidOperationExceptionZ s
(s t
$str	t í
)
í ì
,
ì î
igvRate
ï ú
)
ú ù
;
ù û
var 
price 
= 
item 
. 
NextChargeTotal (
(( )
igvRate) 0
,0 1
product2 9
)9 :
!: ;
.; <
Value< A
;A B
if 

( 
price 
<= 
$num 
) 
throw 
new !%
InvalidOperationException" ;
(; <
$str	< é
)
é è
;
è ê
if 

( 
item 
. 
BillingCycle 
. 
SubscriptionMonths 0
(0 1
)1 2
is3 5
int6 9
months: @
)@ A
{ 	
item 
. 
PayPalPlanId 
= 
price  %
!=& (
	listPrice) 2
?3 4
await5 :
payPal; A
.A B
CreatePlanAsyncB Q
(Q R
productR Y
.Y Z
NameZ ^
,^ _
	listPrice` i
,i j
productk r
.r s
Currencys {
,{ |
months	} É
,
É Ñ
price
Ö ä
,
ä ã
ct
å é
)
é è
:
ê ë
await
í ó
	PlanAsync
ò °
(
° ¢
product
¢ ©
,
© ™
item
´ Ø
.
Ø ∞
BillingCycle
∞ º
,
º Ω
	listPrice
æ «
,
« »
ct
… À
)
À Ã
;
Ã Õ
var 
subscription 
= 
await $
payPal% +
.+ ,#
CreateSubscriptionAsync, C
(C D
itemD H
.H I
PayPalPlanIdI U
,U V
itemW [
.[ \
Id\ ^
.^ _
ToString_ g
(g h
)h i
,i j
	returnUrlk t
,t u
	cancelUrlv 
,	 Ä
ct
Å É
)
É Ñ
;
Ñ Ö
item 
.  
PayPalSubscriptionId %
=& '
subscription( 4
.4 5
Id5 7
;7 8
return 
subscription 
;  
} 	
var   
order   
=   
await   
payPal    
.    !
CreateOrderAsync  ! 1
(  1 2
item  2 6
.  6 7
ChargeTotal  7 B
(  B C
igvRate  C J
,  J K
years  L Q
,  Q R
product  S Z
)  Z [
!  [ \
.  \ ]
Value  ] b
,  b c
product  d k
.  k l
Currency  l t
,  t u
item  v z
.  z {
Id  { }
.  } ~
ToString	  ~ Ü
(
  Ü á
)
  á à
,
  à â
	returnUrl
  ä ì
,
  ì î
	cancelUrl
  ï û
,
  û ü
ct
  † ¢
)
  ¢ £
;
  £ §
item!! 
.!! 
PayPalOrderId!! 
=!! 
order!! "
.!!" #
Id!!# %
;!!% &
item"" 
."" 
PayPalOrderYears"" 
="" 
years""  %
;""% &
return## 
order## 
;## 
}$$ 
private** 
async** 
Task** 
<** 
string** 
>** 
	PlanAsync** (
(**( )
Product**) 0
product**1 8
,**8 9
BillingCycle**: F
cycle**G L
,**L M
decimal**N U
price**V [
,**[ \
CancellationToken**] n
ct**o q
)**q r
{++ 
var,, 
months,, 
=,, 
cycle,, 
.,, 
SubscriptionMonths,, -
(,,- .
),,. /
!,,/ 0
.,,0 1
Value,,1 6
;,,6 7
if-- 

(-- 
price-- 
!=-- 
product-- 
.-- 
	BasePrice-- &
||--' )
cycle--* /
!=--0 2
product--3 :
.--: ;
BillingCycle--; G
)--G H
return--I O
await--P U
payPal--V \
.--\ ]
CreatePlanAsync--] l
(--l m
product--m t
.--t u
Name--u y
,--y z
price	--{ Ä
,
--Ä Å
product
--Ç â
.
--â ä
Currency
--ä í
,
--í ì
months
--î ö
,
--ö õ
cancellationToken
--ú ≠
:
--≠ Æ
ct
--Ø ±
)
--± ≤
;
--≤ ≥
if.. 

(.. 
product.. 
... 
PayPalPlanId..  
is..! #
null..$ (
||..) +
product.., 3
...3 4
PayPalPlanPrice..4 C
!=..D F
price..G L
)..L M
{// 	
product00 
.00 
PayPalPlanId00  
=00! "
await00# (
payPal00) /
.00/ 0
CreatePlanAsync000 ?
(00? @
product00@ G
.00G H
Name00H L
,00L M
price00N S
,00S T
product00U \
.00\ ]
Currency00] e
,00e f
months00g m
,00m n
cancellationToken	00o Ä
:
00Ä Å
ct
00Ç Ñ
)
00Ñ Ö
;
00Ö Ü
product11 
.11 
PayPalPlanPrice11 #
=11$ %
price11& +
;11+ ,
}22 	
return33 
product33 
.33 
PayPalPlanId33 #
;33# $
}44 
public66 

static66 
string66 
[66 
]66 
AllowedOrigins66 )
(66) *
IConfiguration66* 8
configuration669 F
)66F G
=>66H J
[77 	
configuration77	 
[77 
$str77 +
]77+ ,
??77- /
$str770 C
,77C D
configuration77E R
[77R S
$str77S g
]77g h
??77i k
$str	77l Ü
,
77Ü á
$str
77à ü
,
77ü †
$str
77° ∏
,
77∏ π
$str
77∫ —
]
77— “
;
77“ ”
public:: 

static:: 
string:: 
PortalBaseUrl:: &
(::& '
HttpRequest::' 2
?::2 3
request::4 ;
,::; <
IConfiguration::= K
configuration::L Y
)::Y Z
{;; 
var<< 
origin<< 
=<< 
request<< 
?<< 
.<< 
Headers<< %
.<<% &
Origin<<& ,
.<<, -
ToString<<- 5
(<<5 6
)<<6 7
.<<7 8
TrimEnd<<8 ?
(<<? @
$char<<@ C
)<<C D
;<<D E
if== 

(== 
!== 
string== 
.== 
IsNullOrEmpty== !
(==! "
origin==" (
)==( )
&&==* ,
AllowedOrigins==- ;
(==; <
configuration==< I
)==I J
.==J K
Any==K N
(==N O
x==O P
=>==Q S
string==T Z
.==Z [
Equals==[ a
(==a b
x==b c
.==c d
TrimEnd==d k
(==k l
$char==l o
)==o p
,==p q
origin==r x
,==x y
StringComparison	==z ä
.
==ä ã
OrdinalIgnoreCase
==ã ú
)
==ú ù
)
==ù û
)
==û ü
return
==† ¶
origin
==ß ≠
;
==≠ Æ
return>> 
(>> 
configuration>> 
[>> 
$str>> 2
]>>2 3
??>>4 6
$str>>7 Q
)>>Q R
.>>R S
TrimEnd>>S Z
(>>Z [
$char>>[ ^
)>>^ _
;>>_ `
}?? 
}@@ ˙
AC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\JwtSettings.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public 
sealed 
record 
JwtSettings  
(  !
string! '
Issuer( .
,. /
string0 6
Audience7 ?
,? @ 
SymmetricSecurityKeyA U

SigningKeyV `
)` a
{ 
const

 	
int


 
MinKeyBytes

 
=

 
$num

 
;

 
public 

static 
JwtSettings 
FromConfiguration /
(/ 0
IConfiguration0 >
config? E
)E F
{ 
var 
key 
= 
config 
[ 
$str "
]" #
;# $
if 

( 
string 
. 
IsNullOrWhiteSpace %
(% &
key& )
)) *
)* +
throw 
new %
InvalidOperationException /
(/ 0
$str	0 §
)
§ •
;
• ¶
if 

( 
Encoding 
. 
UTF8 
. 
GetByteCount &
(& '
key' *
)* +
<, -
MinKeyBytes. 9
)9 :
throw 
new %
InvalidOperationException /
(/ 0
$"0 2
$str2 d
{d e
MinKeyBytese p
}p q
$strq x
"x y
)y z
;z {
if 

( 
key 
. 
Contains 
( 
$str $
,$ %
StringComparison& 6
.6 7
OrdinalIgnoreCase7 H
)H I
)I J
throw 
new %
InvalidOperationException /
(/ 0
$str0 w
)w x
;x y
return 
new 
JwtSettings 
( 
config %
[% &
$str& 2
]2 3
??4 6
$str7 B
,B C
configD J
[J K
$strK Y
]Y Z
??[ ]
$str^ i
,i j
newk n!
SymmetricSecurityKey	o É
(
É Ñ
Encoding
Ñ å
.
å ç
UTF8
ç ë
.
ë í
GetBytes
í ö
(
ö õ
key
õ û
)
û ü
)
ü †
)
† °
;
° ¢
} 
} Ñ.
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\FirebaseTokenVerifier.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public		 
sealed		 
record		 
FirebaseIdentity		 %
(		% &
string		& ,
Email		- 2
,		2 3
bool		4 8
EmailVerified		9 F
)		F G
;		G H
public 
	interface "
IFirebaseTokenVerifier '
{ 
Task 
< 	
FirebaseIdentity	 
? 
> 
VerifyAsync '
(' (
string( .
idToken/ 6
,6 7
CancellationToken8 I
ctJ L
)L M
;M N
} 
public 
sealed 
class !
FirebaseTokenVerifier )
:* +"
IFirebaseTokenVerifier, B
{ 
readonly 
string 
? 
	projectId 
; 
readonly  
ConfigurationManager !
<! "&
OpenIdConnectConfiguration" <
>< =
?= >
metadata? G
;G H
public 
!
FirebaseTokenVerifier  
(  !
IConfiguration! /
config0 6
)6 7
{ 
	projectId 
= 
config 
[ 
$str /
]/ 0
?0 1
.1 2
Trim2 6
(6 7
)7 8
;8 9
if 

( 
string 
. 
IsNullOrEmpty  
(  !
	projectId! *
)* +
)+ ,
return- 3
;3 4
metadata 
= 
new  
ConfigurationManager +
<+ ,&
OpenIdConnectConfiguration, F
>F G
(G H
$"   
$str   -
{  - .
	projectId  . 7
}  7 8
$str  8 Y
"  Y Z
,  Z [
new!! /
#OpenIdConnectConfigurationRetriever!! 3
(!!3 4
)!!4 5
,!!5 6
new!!7 :!
HttpDocumentRetriever!!; P
{!!Q R
RequireHttps!!S _
=!!` a
true!!b f
}!!g h
)!!h i
;!!i j
}"" 
public$$ 

async$$ 
Task$$ 
<$$ 
FirebaseIdentity$$ &
?$$& '
>$$' (
VerifyAsync$$) 4
($$4 5
string$$5 ;
idToken$$< C
,$$C D
CancellationToken$$E V
ct$$W Y
)$$Y Z
{%% 
if&& 

(&& 
metadata&& 
is&& 
null&& 
||&& 
string&&  &
.&&& '
IsNullOrWhiteSpace&&' 9
(&&9 :
idToken&&: A
)&&A B
)&&B C
return&&D J
null&&K O
;&&O P
try'' 
{(( 	
var)) 
oidc)) 
=)) 
await)) 
metadata)) %
.))% &!
GetConfigurationAsync))& ;
()); <
ct))< >
)))> ?
;))? @
var** 
result** 
=** 
await** 
new** "
JsonWebTokenHandler**# 6
(**6 7
)**7 8
.**8 9
ValidateTokenAsync**9 K
(**K L
idToken**L S
,**S T
new**U X%
TokenValidationParameters**Y r
{++ 
ValidateIssuer,, 
=,,  
true,,! %
,,,% &
ValidateAudience,,' 7
=,,8 9
true,,: >
,,,> ?
ValidateLifetime,,@ P
=,,Q R
true,,S W
,,,W X$
ValidateIssuerSigningKey,,Y q
=,,r s
true,,t x
,,,x y
ValidIssuer-- 
=-- 
$"--  
$str--  ?
{--? @
	projectId--@ I
}--I J
"--J K
,--K L
ValidAudience--M Z
=--[ \
	projectId--] f
,--f g
IssuerSigningKeys.. !
=.." #
oidc..$ (
...( )
SigningKeys..) 4
,..4 5
	ClockSkew..6 ?
=..@ A
TimeSpan..B J
...J K
FromMinutes..K V
(..V W
$num..W X
)..X Y
}// 
)// 
;// 
if00 
(00 
!00 
result00 
.00 
IsValid00 
)00  
return00! '
null00( ,
;00, -
var11 
email11 
=11 
result11 
.11 
Claims11 %
.11% &
TryGetValue11& 1
(111 2
$str112 9
,119 :
out11; >
var11? B
e11C D
)11D E
?11F G
e11H I
as11J L
string11M S
:11T U
null11V Z
;11Z [
if22 
(22 
string22 
.22 
IsNullOrWhiteSpace22 )
(22) *
email22* /
)22/ 0
)220 1
return222 8
null229 =
;22= >
var33 
verified33 
=33 
result33 !
.33! "
Claims33" (
.33( )
TryGetValue33) 4
(334 5
$str335 E
,33E F
out33G J
var33K N
v33O P
)33P Q
&&33R T
v33U V
is33W Y
true33Z ^
or33_ a
$str33b h
;33h i
return44 
new44 
FirebaseIdentity44 '
(44' (
email44( -
,44- .
verified44/ 7
)447 8
;448 9
}55 	
catch66 
(66 
	Exception66 
)66 
{77 	
return88 
null88 
;88 
}99 	
}:: 
};; â\
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\BankTransferService.cs
	namespace 	
Rtres
 
. 
Api 
. 
Services 
; 
public 
sealed 
class 
BankTransferService '
(' (
RtresDbContext( 6
db7 9
,9 :
IConfiguration; I
configurationJ W
)W X
{		 
public

 

async

 
Task

 
<

 
PaymentSettings

 %
>

% &
SettingsAsync

' 4
(

4 5
CancellationToken

5 F
ct

G I
)

I J
=>

K M
await 
db 
. 
PaymentSettings  
.  !
FirstOrDefaultAsync! 4
(4 5
ct5 7
)7 8
??9 ;
db< >
.> ?
PaymentSettings? N
.N O
AddO R
(R S
newS V
PaymentSettingsW f
(f g
)g h
)h i
.i j
Entityj p
;p q
public 

Task 
< 
List 
< 
BankAccount  
>  !
>! "
ActiveAccountsAsync# 6
(6 7
CancellationToken7 H
ctI K
)K L
=>M O
db 

.
 
BankAccounts 
. 
Where 
( 
x 
=>  "
x# $
.$ %
IsActive% -
)- .
.. /
OrderBy/ 6
(6 7
x7 8
=>9 ;
x< =
.= >
	SortOrder> G
)G H
.H I
ThenByI O
(O P
xP Q
=>R T
xU V
.V W
CurrencyW _
)_ `
.` a
ThenBya g
(g h
xh i
=>j l
xm n
.n o
BankNameo w
)w x
.x y
ToListAsync	y Ñ
(
Ñ Ö
ct
Ö á
)
á à
;
à â
public 

async 
Task 
< 
BankTransferInfoDto )
>) *
	InfoAsync+ 4
(4 5
ClientProduct5 B
itemC G
,G H
decimalI P
igvRateQ X
,X Y
intZ ]
years^ c
,c d
CancellationTokene v
ctw y
)y z
{ 
var 
currency 
= 
item 
. 
Product #
?# $
.$ %
Currency% -
??. 0
$str1 6
;6 7
var 
amount 
= 
item 
. 
ChargeTotal %
(% &
igvRate& -
,- .
years/ 4
)4 5
;5 6
var 
today 
= 
DateOnly 
. 
FromDateTime )
() *
DateTime* 2
.2 3
UtcNow3 9
)9 :
;: ;
var 
accounts 
= 
new 
List 
<  
BankAccountDto  .
>. /
(/ 0
)0 1
;1 2
foreach 
( 
var 
account 
in 
await  %
ActiveAccountsAsync& 9
(9 :
ct: <
)< =
)= >
{ 	
decimal 
? 
approx 
= 
null "
;" #
if 
( 
amount 
is 
decimal !
value" '
&&( *
account+ 2
.2 3
Currency3 ;
!=< >
currency? G
&&H J
awaitK P
HasRateAsyncQ ]
(] ^
currency^ f
,f g
cth j
)j k
&&l n
awaito t
HasRateAsync	u Å
(
Å Ç
account
Ç â
.
â ä
Currency
ä í
,
í ì
ct
î ñ
)
ñ ó
)
ó ò
approx 
= 
Math 
. 
Round #
(# $
value$ )
** +
await, 1
db2 4
.4 5
RateToPenAsync5 C
(C D
currencyD L
,L M
todayN S
,S T
ctU W
)W X
/Y Z
await[ `
dba c
.c d
RateToPenAsyncd r
(r s
accounts z
.z {
Currency	{ É
,
É Ñ
today
Ö ä
,
ä ã
ct
å é
)
é è
,
è ê
$num
ë í
)
í ì
;
ì î
accounts 
. 
Add 
( 
BankAccountDto '
.' (
From( ,
(, -
account- 4
,4 5
approx6 <
)< =
)= >
;> ?
}   	
accounts"" 
="" 
["" 
.."" 
accounts"" 
.""  
OrderBy""  '
(""' (
x""( )
=>""* ,
x""- .
."". /
Currency""/ 7
==""8 :
currency""; C
?""D E
$num""F G
:""H I
$num""J K
)""K L
]""L M
;""M N
return## 
new## 
BankTransferInfoDto## &
(##& '
configuration##' 4
[##4 5
$str##5 P
]##P Q
??##R T
$str##U W
,##W X
amount##Y _
,##_ `
years##a f
,##f g
currency##h p
,##p q
igvRate##r y
>##z {
$num##| }
,##} ~
accounts	## á
)
##á à
;
##à â
}$$ 
private&& 
async&& 
Task&& 
<&& 
bool&& 
>&& 
HasRateAsync&& )
(&&) *
string&&* 0
currency&&1 9
,&&9 :
CancellationToken&&; L
ct&&M O
)&&O P
=>&&Q S
currency&&T \
==&&] _
$str&&` e
||&&f h
await&&i n
db&&o q
.&&q r
ExchangeRates&&r 
.	&& Ä
AnyAsync
&&Ä à
(
&&à â
x
&&â ä
=>
&&ã ç
x
&&é è
.
&&è ê
CurrencyCode
&&ê ú
==
&&ù ü
currency
&&† ®
,
&&® ©
ct
&&™ ¨
)
&&¨ ≠
;
&&≠ Æ
public)) 

async)) 
Task)) 
<)) 

Dictionary))  
<))  !
Guid))! %
,))% &!
TransferReportSummary))' <
>))< =
>))= >
LatestReportsAsync))? Q
())Q R
IEnumerable))R ]
<))] ^
Guid))^ b
>))b c
clientProductIds))d t
,))t u
CancellationToken	))v á
ct
))à ä
)
))ä ã
{** 
var++ 
ids++ 
=++ 
clientProductIds++ "
.++" #
ToList++# )
(++) *
)++* +
;+++ ,
var,, 
reports,, 
=,, 
await,, 
db,, 
.,, 
TransferReports,, .
.,,. /
Where,,/ 4
(,,4 5
x,,5 6
=>,,7 9
ids,,: =
.,,= >
Contains,,> F
(,,F G
x,,G H
.,,H I
ClientProductId,,I X
),,X Y
),,Y Z
.-- 
Select-- 
(-- 
x-- 
=>-- 
new-- 
{-- 
x--  
.--  !
ClientProductId--! 0
,--0 1
x--2 3
.--3 4
Id--4 6
,--6 7
x--8 9
.--9 :
Status--: @
,--@ A
x--B C
.--C D
	CreatedAt--D M
,--M N
x--O P
.--P Q
RejectionReason--Q `
}--a b
)--b c
.--c d
ToListAsync--d o
(--o p
ct--p r
)--r s
;--s t
return.. 
reports.. 
... 
GroupBy.. 
(.. 
x..  
=>..! #
x..$ %
...% &
ClientProductId..& 5
)..5 6
...6 7
ToDictionary..7 C
(..C D
g..D E
=>..F H
g..I J
...J K
Key..K N
,..N O
g..P Q
=>..R T
g..U V
...V W
OrderByDescending..W h
(..h i
x..i j
=>..k m
x..n o
...o p
	CreatedAt..p y
)..y z
...z {
Select	..{ Å
(
..Å Ç
x
..Ç É
=>
..Ñ Ü
new
..á ä#
TransferReportSummary
..ã †
(
..† °
x
..° ¢
.
..¢ £
Id
..£ •
,
..• ¶
x
..ß ®
.
..® ©
Status
..© Ø
,
..Ø ∞
x
..± ≤
.
..≤ ≥
	CreatedAt
..≥ º
,
..º Ω
x
..æ ø
.
..ø ¿
RejectionReason
..¿ œ
)
..œ –
)
..– —
.
..— “
First
..“ ◊
(
..◊ ÿ
)
..ÿ Ÿ
)
..Ÿ ⁄
;
..⁄ €
}// 
}00 
public22 
sealed22 
record22 
BankAccountDto22 #
(22# $
Guid22$ (
Id22) +
,22+ ,
string22- 3
BankName224 <
,22< =
string22> D
Holder22E K
,22K L
string22M S
Currency22T \
,22\ ]
BankAccountType22^ m
Type22n r
,22r s
string22t z
AccountNumber	22{ à
,
22à â
string
22ä ê
?
22ê ë
Cci
22í ï
,
22ï ñ
bool
22ó õ
IsActive
22ú §
,
22§ •
int
22¶ ©
	SortOrder
22™ ≥
,
22≥ ¥
decimal
22µ º
?
22º Ω
ApproxAmount
22æ  
=
22À Ã
null
22Õ —
)
22— “
{33 
public44 

static44 
BankAccountDto44  
From44! %
(44% &
BankAccount44& 1
x442 3
,443 4
decimal445 <
?44< =
approxAmount44> J
=44K L
null44M Q
)44Q R
=>44S U
new44V Y
(44Y Z
x44Z [
.44[ \
Id44\ ^
,44^ _
x44` a
.44a b
BankName44b j
,44j k
x44l m
.44m n
Holder44n t
,44t u
x44v w
.44w x
Currency	44x Ä
,
44Ä Å
x
44Ç É
.
44É Ñ
Type
44Ñ à
,
44à â
x
44ä ã
.
44ã å
AccountNumber
44å ô
,
44ô ö
x
44õ ú
.
44ú ù
Cci
44ù †
,
44† °
x
44¢ £
.
44£ §
IsActive
44§ ¨
,
44¨ ≠
x
44Æ Ø
.
44Ø ∞
	SortOrder
44∞ π
,
44π ∫
approxAmount
44ª «
)
44« »
;
44» …
}55 
public77 
sealed77 
record77 
BankTransferInfoDto77 (
(77( )
string77) /
Instructions770 <
,77< =
decimal77> E
?77E F
Amount77G M
,77M N
int77O R
Years77S X
,77X Y
string77Z `
Currency77a i
,77i j
bool77k o
IncludesIgv77p {
,77{ |
List	77} Å
<
77Å Ç
BankAccountDto
77Ç ê
>
77ê ë
Accounts
77í ö
)
77ö õ
;
77õ ú€Å
4C:\repo\rtres-net\Rtres\src\api\Rtres.Api\Program.cs
var 
builder 
= 
WebApplication 
. 
CreateBuilder *
(* +
args+ /
)/ 0
;0 1
builder 
. 
Configuration 
. 
AddJsonFile !
(! "
$"" $
$str$ 0
{0 1
builder1 8
.8 9
Environment9 D
.D E
EnvironmentNameE T
}T U
$strU `
"` a
,a b
optionalc k
:k l
truem q
,q r
reloadOnChange	s Å
:
Å Ç
true
É á
)
á à
;
à â
builder 
. 
Services 
. 
AddControllers 
(  
)  !
.! "
AddJsonOptions" 0
(0 1
o1 2
=>3 5
o6 7
.7 8!
JsonSerializerOptions8 M
.M N

ConvertersN X
.X Y
AddY \
(\ ]
new] `#
JsonStringEnumConvertera x
(x y
)y z
)z {
){ |
;| }
builder 
. 
Services 
. 

AddOpenApi 
( 
) 
; 
builder 
. 
Services 
. "
AddRtresInfrastructure '
(' (
builder( /
./ 0
Configuration0 =
)= >
;> ?
builder 
. 
Services 
. 
	AddScoped 
< "
GitHubWebhookProcessor 1
>1 2
(2 3
)3 4
;4 5
builder 
. 
Services 
. 
	AddScoped 
< 
ExchangeRateSyncJob .
>. /
(/ 0
)0 1
;1 2
builder 
. 
Services 
. 
	AddScoped 
< 
INotificationSender .
,. /$
QueuedNotificationSender0 H
>H I
(I J
)J K
;K L
builder 
. 
Services 
. 
	AddScoped 
< 
NotificationJob *
>* +
(+ ,
), -
;- .
builder 
. 
Services 
. 
	AddScoped 
< 
AccessEmailService -
>- .
(. /
)/ 0
;0 1
builder 
. 
Services 
. 
AddSingleton 
< 
ILoginLinkMailer .
,. /%
BackgroundLoginLinkMailer0 I
>I J
(J K
)K L
;L M
builder 
. 
Services 
. 
	AddScoped 
< !
PayPalCheckoutService 0
>0 1
(1 2
)2 3
;3 4
builder 
. 
Services 
. 
	AddScoped 
<  
PayPalPaymentService /
>/ 0
(0 1
)1 2
;2 3
builder 
. 
Services 
. 
	AddScoped 
< 
TaxDocumentService -
>- .
(. /
)/ 0
;0 1
builder 
. 
Services 
. 
	AddScoped 
< 
BankTransferService .
>. /
(/ 0
)0 1
;1 2
builder   
.   
Services   
.   
	AddScoped   
<   
StaffNotifier   (
>  ( )
(  ) *
)  * +
;  + ,
builder!! 
.!! 
Services!! 
.!! 
AddCors!! 
(!! 
options!!  
=>!!! #
options!!$ +
.!!+ ,
AddDefaultPolicy!!, <
(!!< =
policy!!= C
=>!!D F
policy!!G M
."" 
WithOrigins"" 
("" !
PayPalCheckoutService"" &
.""& '
AllowedOrigins""' 5
(""5 6
builder""6 =
.""= >
Configuration""> K
)""K L
)""L M
.## 
AllowAnyHeader## 
(## 
)## 
.## 
AllowAnyMethod## $
(##$ %
)##% &
)##& '
)##' (
;##( )
var%% 
jwt%% 
=%% 	
JwtSettings%%
 
.%% 
FromConfiguration%% '
(%%' (
builder%%( /
.%%/ 0
Configuration%%0 =
)%%= >
;%%> ?
builder&& 
.&& 
Services&& 
.&& 
AddSingleton&& 
(&& 
jwt&& !
)&&! "
;&&" #
builder(( 
.(( 
Services(( 
.(( 
AddSingleton(( 
<(( "
IFirebaseTokenVerifier(( 4
,((4 5!
FirebaseTokenVerifier((6 K
>((K L
(((L M
)((M N
;((N O
builder)) 
.)) 
Services)) 
.)) 
AddAuthentication)) "
())" #
JwtBearerDefaults))# 4
.))4 5 
AuthenticationScheme))5 I
)))I J
.))J K
AddJwtBearer))K W
())W X
options))X _
=>))` b
options))c j
.))j k&
TokenValidationParameters	))k Ñ
=
))Ö Ü
new
))á ä'
TokenValidationParameters
))ã §
{** 
ValidateIssuer++ 
=++ 
true++ 
,++ 
ValidateAudience++ +
=++, -
true++. 2
,++2 3
ValidateLifetime++4 D
=++E F
true++G K
,++K L$
ValidateIssuerSigningKey++M e
=++f g
true++h l
,++l m
ValidIssuer,, 
=,, 
jwt,, 
.,, 
Issuer,, 
,,, 
ValidAudience,, +
=,,, -
jwt,,. 1
.,,1 2
Audience,,2 :
,,,: ;
IssuerSigningKey,,< L
=,,M N
jwt,,O R
.,,R S

SigningKey,,S ]
,,,] ^
	ClockSkew-- 
=-- 
TimeSpan-- 
.-- 
FromMinutes-- $
(--$ %
$num--% &
)--& '
}.. 
).. 
;.. 
builder// 
.// 
Services// 
.// 
AddAuthorization// !
(//! "
)//" #
;//# $
builder00 
.00 
Services00 
.00 
AddMemoryCache00 
(00  
)00  !
;00! "
builder22 
.22 
Services22 
.22 
	Configure22 
<22 #
ForwardedHeadersOptions22 2
>222 3
(223 4
o224 5
=>226 8
{33 
o44 
.44 
ForwardedHeaders44 
=44 
ForwardedHeaders44 )
.44) *
XForwardedFor44* 7
|448 9
ForwardedHeaders44: J
.44J K
XForwardedProto44K Z
;44Z [
o55 
.55 
KnownIPNetworks55 
.55 
Clear55 
(55 
)55 
;55 
o55  
.55  !
KnownProxies55! -
.55- .
Clear55. 3
(553 4
)554 5
;555 6
}66 
)66 
;66 
builder77 
.77 
Services77 
.77 
AddRateLimiter77 
(77  
o77  !
=>77" $
{88 
o99 
.99 
RejectionStatusCode99 
=99 
StatusCodes99 '
.99' ($
Status429TooManyRequests99( @
;99@ A
o:: 
.:: 

OnRejected:: 
=:: 
(:: 
ctx:: 
,:: 
ct:: 
):: 
=>:: 
new::  #
	ValueTask::$ -
(::- .
ctx::. 1
.::1 2
HttpContext::2 =
.::= >
Response::> F
.::F G
WriteAsJsonAsync::G W
(::W X
new::X [
{::\ ]
message::^ e
=::f g
ctx::h k
.::k l
HttpContext::l w
.::w x
Request::x 
.	:: Ä
Path
::Ä Ñ
.
::Ñ Ö 
StartsWithSegments
::Ö ó
(
::ó ò
$str
::ò ≠
)
::≠ Æ
?;; 	
$str;;
 k
:<< 	
$str<<
 [
}<<\ ]
,<<] ^
ct<<_ a
)<<a b
)<<b c
;<<c d
o>> 
.>> 
	AddPolicy>> 
(>> 
ContactController>> !
.>>! "
RateLimitPolicy>>" 1
,>>1 2
http>>3 7
=>>>8 :
RateLimitPartition>>; M
.>>M N!
GetFixedWindowLimiter>>N c
(>>c d
http?? 
.?? 

Connection?? 
.?? 
RemoteIpAddress?? '
???' (
.??( )
ToString??) 1
(??1 2
)??2 3
????4 6
$str??7 @
,??@ A
_@@ 	
=>@@
 
new@@ )
FixedWindowRateLimiterOptions@@ .
{@@/ 0
PermitLimit@@1 <
=@@= >
$num@@? @
,@@@ A
Window@@B H
=@@I J
TimeSpan@@K S
.@@S T
FromMinutes@@T _
(@@_ `
$num@@` b
)@@b c
,@@c d

QueueLimit@@e o
=@@p q
$num@@r s
}@@t u
)@@u v
)@@v w
;@@w x
oAA 
.AA 
	AddPolicyAA 
(AA 
AuthControllerAA 
.AA  
LoginRateLimitPolicyAA 3
,AA3 4
httpAA5 9
=>AA: <
RateLimitPartitionAA= O
.AAO P!
GetFixedWindowLimiterAAP e
(AAe f
httpBB 
.BB 

ConnectionBB 
.BB 
RemoteIpAddressBB '
?BB' (
.BB( )
ToStringBB) 1
(BB1 2
)BB2 3
??BB4 6
$strBB7 @
,BB@ A
_CC 	
=>CC
 
newCC )
FixedWindowRateLimiterOptionsCC .
{CC/ 0
PermitLimitCC1 <
=CC= >
$numCC? A
,CCA B
WindowCCC I
=CCJ K
TimeSpanCCL T
.CCT U
FromMinutesCCU `
(CC` a
$numCCa b
)CCb c
,CCc d

QueueLimitCCe o
=CCp q
$numCCr s
}CCt u
)CCu v
)CCv w
;CCw x
}DD 
)DD 
;DD 
builderFF 
.FF 
ServicesFF 
.FF 
AddHangfireFF 
(FF 
configFF #
=>FF$ &
configFF' -
.FF- .
UseSqlServerStorageFF. A
(FFA B
builderFFB I
.FFI J
ConfigurationFFJ W
.FFW X
GetConnectionStringFFX k
(FFk l
$strFFl w
)FFw x
,FFx y
newFFz }$
SqlServerStorageOptions	FF~ ï
{
FFñ ó&
PrepareSchemaIfNecessary
FFò ∞
=
FF± ≤
true
FF≥ ∑
}
FF∏ π
)
FFπ ∫
)
FF∫ ª
;
FFª º
builderGG 
.GG 
ServicesGG 
.GG 
AddHangfireServerGG "
(GG" #
)GG# $
;GG$ %
varII 
appII 
=II 	
builderII
 
.II 
BuildII 
(II 
)II 
;II 
appJJ 
.JJ 
UseForwardedHeadersJJ 
(JJ 
)JJ 
;JJ 
ifKK 
(KK 
appKK 
.KK 
EnvironmentKK 
.KK 
IsDevelopmentKK !
(KK! "
)KK" #
)KK# $
{LL 
appMM 
.MM 

MapOpenApiMM 
(MM 
)MM 
;MM 
usingNN 	
varNN
 
scopeNN 
=NN 
appNN 
.NN 
ServicesNN "
.NN" #
CreateScopeNN# .
(NN. /
)NN/ 0
;NN0 1
awaitOO 	
DbSeederOO
 
.OO 
	SeedAsyncOO 
(OO 
scopeOO "
.OO" #
ServiceProviderOO# 2
.OO2 3
GetRequiredServiceOO3 E
<OOE F
RtresDbContextOOF T
>OOT U
(OOU V
)OOV W
)OOW X
;OOX Y
}PP 
appQQ 
.QQ 
UseHttpsRedirectionQQ 
(QQ 
)QQ 
;QQ 
appRR 
.RR 
UseCorsRR 
(RR 
)RR 
;RR 
appSS 
.SS 
UseRateLimiterSS 
(SS 
)SS 
;SS 
appTT 
.TT 
UseAuthenticationTT 
(TT 
)TT 
;TT 
appUU 
.UU 
UseAuthorizationUU 
(UU 
)UU 
;UU 
appVV 
.VV  
UseHangfireDashboardVV 
(VV 
$strVV  
)VV  !
;VV! "
RecurringJobXX 
.XX 
AddOrUpdateXX 
<XX 
RenewalReminderJobXX +
>XX+ ,
(XX, -
$strXX- @
,XX@ A
jobXXB E
=>XXF H
jobXXI L
.XXL M
	SendAsyncXXM V
(XXV W
CancellationTokenXXW h
.XXh i
NoneXXi m
)XXm n
,XXn o
CronXXp t
.XXt u
DailyXXu z
(XXz {
$numXX{ }
)XX} ~
)XX~ 
;	XX Ä
RecurringJobZZ 
.ZZ 
AddOrUpdateZZ 
<ZZ 
ExchangeRateSyncJobZZ ,
>ZZ, -
(ZZ- .
$strZZ. B
,ZZB C
jobZZD G
=>ZZH J
jobZZK N
.ZZN O
	SyncAsyncZZO X
(ZZX Y
CancellationTokenZZY j
.ZZj k
NoneZZk o
)ZZo p
,ZZp q
CronZZr v
.ZZv w
DailyZZw |
(ZZ| }
$numZZ} 
)	ZZ Ä
)
ZZÄ Å
;
ZZÅ Ç
RecurringJob]] 
.]] 
AddOrUpdate]] 
<]] 
RecurringExpenseJob]] ,
>]], -
(]]- .
$str]]. B
,]]B C
job]]D G
=>]]H J
job]]K N
.]]N O
GenerateAsync]]O \
(]]\ ]
CancellationToken]]] n
.]]n o
None]]o s
)]]s t
,]]t u
Cron]]v z
.]]z {
Daily	]]{ Ä
(
]]Ä Å
$num
]]Å É
)
]]É Ñ
)
]]Ñ Ö
;
]]Ö Ü
RecurringJob__ 
.__ 
AddOrUpdate__ 
<__ &
GitHubProjectStatusSyncJob__ 3
>__3 4
(__4 5
$str__5 L
,__L M
job__N Q
=>__R T
job__U X
.__X Y
	SyncAsync__Y b
(__b c
CancellationToken__c t
.__t u
None__u y
)__y z
,__z {
$str	__| â
)
__â ä
;
__ä ã
RecurringJobaa 
.aa 
AddOrUpdateaa 
<aa 
TaxDueReminderJobaa *
>aa* +
(aa+ ,
$straa, ?
,aa? @
jobaaA D
=>aaE G
jobaaH K
.aaK L
	SendAsyncaaL U
(aaU V
CancellationTokenaaV g
.aag h
Noneaah l
)aal m
,aam n
$straao |
)aa| }
;aa} ~
RecurringJobbb 
.bb 
AddOrUpdatebb 
<bb #
PayPalReconciliationJobbb 0
>bb0 1
(bb1 2
$strbb2 I
,bbI J
jobbbK N
=>bbO Q
jobbbR U
.bbU V
ReconcileAsyncbbV d
(bbd e
CancellationTokenbbe v
.bbv w
Nonebbw {
)bb{ |
,bb| }
Cron	bb~ Ç
.
bbÇ É
Hourly
bbÉ â
)
bbâ ä
;
bbä ã
appcc 
.cc 
MapControllerscc 
(cc 
)cc 
;cc 
awaitdd 
appdd 	
.dd	 

RunAsyncdd
 
(dd 
)dd 
;dd 
publicff 
partialff 
classff 
Programff 
{ff 
	protectedff (
Programff) 0
(ff0 1
)ff1 2
{ff3 4
}ff5 6
}ff7 8”3
HC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\StaffNotifier.cs
	namespace 	
Rtres
 
. 
Api 
. 
Notifications !
;! "
public 
sealed 
class 
StaffNotifier !
(! "
RtresDbContext" 0
db1 3
,3 4
IEmailSender5 A
emailB G
,G H
IConfigurationI W
configurationX e
,e f
ILoggerg n
<n o
StaffNotifiero |
>| }
logger	~ Ñ
)
Ñ Ö
{ 
[ 
Hangfire 
. 
AutomaticRetry 
( 
Attempts %
=& '
$num( )
)) *
]* +
public 

async 
Task 
	SendAsync 
(  
Notification  ,
notification- 9
,9 :
CancellationToken; L
cancellationTokenM ^
)^ _
{ 
if 

( 
notification 
. 
	DedupeKey "
is# %
not& )
null* .
&&/ 1
await2 7
NotificationJob8 G
.G H
AlreadySentAsyncH X
(X Y
dbY [
,[ \
notification] i
.i j
	DedupeKeyj s
,s t
cancellationToken	u Ü
)
Ü á
)
á à
return
â è
;
è ê
if 

( 
! 
await 
db 
. 
PortalNotifications )
.) *
AnyAsync* 2
(2 3
x3 4
=>5 7
x8 9
.9 :
	DedupeKey: C
==D F
notificationG S
.S T
	DedupeKeyT ]
,] ^
cancellationToken_ p
)p q
)q r
db 
. 
PortalNotifications "
." #
Add# &
(& '
new' *
PortalNotification+ =
{> ?
ClientId@ H
=I J
GuidK O
.O P
EmptyP U
,U V
TypeW [
=\ ]
notification^ j
.j k
Typek o
.o p
ToStringp x
(x y
)y z
,z {
ForStaff	| Ñ
=
Ö Ü
true
á ã
,
ã å
	DedupeKey
ç ñ
=
ó ò
notification
ô •
.
• ¶
	DedupeKey
¶ Ø
,
Ø ∞
DataJson
± π
=
∫ ª
JsonSerializer
º  
.
  À
	Serialize
À ‘
(
‘ ’
notification
’ ·
.
· ‚
Data
‚ Ê
)
Ê Á
}
Ë È
)
È Í
;
Í Î
var 

staffEmail 
= 
configuration &
[& '
$str' A
]A B
isC E
{F G
LengthH N
:N O
>P Q
$numR S
}T U

configuredV `
?a b

configuredc m
:n o
configurationp }
[} ~
$str	~ â
]
â ä
;
ä ã
if 

( 
string 
. 
IsNullOrWhiteSpace %
(% &

staffEmail& 0
)0 1
)1 2
{3 4
logger5 ;
.; <

LogWarning< F
(F G
$str	G á
,
á à
notification
â ï
.
ï ñ
Type
ñ ö
)
ö õ
;
õ ú
await
ù ¢
db
£ •
.
• ¶
SaveChangesAsync
¶ ∂
(
∂ ∑
cancellationToken
∑ »
)
» …
;
…  
return
À —
;
— “
}
” ‘
var 
( 
subject 
, 
html 
, 
text  
)  !
=" #
EmailTemplates$ 2
.2 3
Render3 9
(9 :
notification: F
,F G
$strH L
,L M
configurationN [
[[ \
$str\ p
]p q
??r t
$str	u è
)
è ê
;
ê ë
var 
log 
= 
new 
NotificationLog %
{& '
ClientId( 0
=1 2
Guid3 7
.7 8
Empty8 =
,= >
Type? C
=D E
notificationF R
.R S
TypeS W
.W X
ToStringX `
(` a
)a b
,b c
Channeld k
=l m
$strn u
,u v
	Recipient	w Ä
=
Å Ç

staffEmail
É ç
,
ç é
	DedupeKey
è ò
=
ô ö
notification
õ ß
.
ß ®
	DedupeKey
® ±
}
≤ ≥
;
≥ ¥
db 

.
 
NotificationLogs 
. 
Add 
(  
log  #
)# $
;$ %
try 
{ 	
await 
email 
. 
	SendAsync !
(! "
new" %
EmailMessage& 2
(2 3

staffEmail3 =
,= >
subject? F
,F G
htmlH L
,L M
textN R
)R S
,S T
cancellationTokenU f
)f g
;g h
log 
. 
Success 
= 
true 
; 
} 	
catch   
(   
	Exception   
ex   
)   
{!! 	
log"" 
."" 
Error"" 
="" 
ex"" 
."" 
Message"" "
.""" #
Length""# )
>""* +
$num"", 0
?""1 2
ex""3 5
.""5 6
Message""6 =
[""= >
..""> @
$num""@ D
]""D E
:""F G
ex""H J
.""J K
Message""K R
;""R S
await## 
db## 
.## 
SaveChangesAsync## %
(##% &
cancellationToken##& 7
)##7 8
;##8 9
throw$$ 
;$$ 
}%% 	
await&& 
db&& 
.&& 
SaveChangesAsync&& !
(&&! "
cancellationToken&&" 3
)&&3 4
;&&4 5
}'' 
}(( ¶]
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\NotificationJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Notifications !
;! "
public 
sealed 
class 
NotificationJob #
(# $
RtresDbContext$ 2
db3 5
,5 6
IEmailSender7 C
emailD I
,I J
IConfigurationK Y
configurationZ g
,g h
ILoggeri p
<p q
NotificationJob	q Ä
>
Ä Å
logger
Ç à
)
à â
{ 
[ 
AutomaticRetry 
( 
Attempts 
= 
$num  
)  !
]! "
public 

async 
Task 
< 
bool 
> 
	SendAsync %
(% &
Guid& *
clientId+ 3
,3 4
Notification5 A
notificationB N
,N O
CancellationTokenP a
cancellationTokenb s
)s t
{ 
await 
AddToInboxAsync 
( 
clientId &
,& '
notification( 4
,4 5
cancellationToken6 G
)G H
;H I
if 

( 
notification 
. 
	DedupeKey "
is# %
not& )
null* .
&&/ 1
await2 7
AlreadySentAsync8 H
(H I
dbI K
,K L
notificationM Y
.Y Z
	DedupeKeyZ c
,c d
cancellationTokene v
)v w
)w x
returny 
false
Ä Ö
;
Ö Ü
var 
client 
= 
await 
db 
. 
Clients %
.% & 
SingleOrDefaultAsync& :
(: ;
x; <
=>= ?
x@ A
.A B
IdB D
==E G
clientIdH P
,P Q
cancellationTokenR c
)c d
;d e
if 

( 
client 
is 
null 
|| 
! 
client %
.% &
IsActive& .
||/ 1
string2 8
.8 9
IsNullOrWhiteSpace9 K
(K L
clientL R
.R S
EmailS X
)X Y
)Y Z
{ 	
logger 
. 
LogInformation !
(! "
$str" n
,n o
notificationp |
.| }
Type	} Å
,
Å Ç
clientId
É ã
)
ã å
;
å ç
return 
false 
; 
} 	
var 
	portalUrl 
= 
notification $
.$ %
Data% )
.) *
TryGetValue* 5
(5 6
$str6 A
,A B
outC F
varG J
urlK N
)N O
?P Q
urlR U
:V W
configurationX e
[e f
$strf z
]z {
??| ~
$str	 ô
;
ô ö
var 
( 
subject 
, 
html 
, 
text  
)  !
=" #
EmailTemplates$ 2
.2 3
Render3 9
(9 :
notification: F
,F G
clientH N
.N O
PreferredLanguageO `
,` a
	portalUrlb k
)k l
;l m
var 
	recipient 
= 
notification $
.$ %
To% '
??( *
client+ 1
.1 2
Email2 7
;7 8
var   
log   
=   
new   
NotificationLog   %
{  & '
ClientId  ( 0
=  1 2
client  3 9
.  9 :
Id  : <
,  < =
Type  > B
=  C D
notification  E Q
.  Q R
Type  R V
.  V W
ToString  W _
(  _ `
)  ` a
,  a b
Channel  c j
=  k l
$str  m t
,  t u
	Recipient  v 
=
  Ä Å
	recipient
  Ç ã
,
  ã å
	DedupeKey
  ç ñ
=
  ó ò
notification
  ô •
.
  • ¶
	DedupeKey
  ¶ Ø
}
  ∞ ±
;
  ± ≤
db!! 

.!!
 
NotificationLogs!! 
.!! 
Add!! 
(!!  
log!!  #
)!!# $
;!!$ %
try"" 
{## 	
await$$ 
email$$ 
.$$ 
	SendAsync$$ !
($$! "
new$$" %
EmailMessage$$& 2
($$2 3
	recipient$$3 <
,$$< =
subject$$> E
,$$E F
html$$G K
,$$K L
text$$M Q
)$$Q R
,$$R S
cancellationToken$$T e
)$$e f
;$$f g
log%% 
.%% 
Success%% 
=%% 
true%% 
;%% 
}&& 	
catch'' 
('' 
	Exception'' 
ex'' 
)'' 
{(( 	
log)) 
.)) 
Error)) 
=)) 
ex)) 
.)) 
Message)) "
.))" #
Length))# )
>))* +
$num)), 0
?))1 2
ex))3 5
.))5 6
Message))6 =
[))= >
..))> @
$num))@ D
]))D E
:))F G
ex))H J
.))J K
Message))K R
;))R S
await** 
db** 
.** 
SaveChangesAsync** %
(**% &
cancellationToken**& 7
)**7 8
;**8 9
throw++ 
;++ 
},, 	
await-- 
db-- 
.-- 
SaveChangesAsync-- !
(--! "
cancellationToken--" 3
)--3 4
;--4 5
return.. 
true.. 
;.. 
}// 
private22 
async22 
Task22 
AddToInboxAsync22 &
(22& '
Guid22' +
clientId22, 4
,224 5
Notification226 B
notification22C O
,22O P
CancellationToken22Q b
cancellationToken22c t
)22t u
{33 
if44 

(44 
notification44 
.44 
Type44 
==44  
NotificationType44! 1
.441 2
AccountAccess442 ?
)44? @
return44A G
;44G H
if55 

(55 
notification55 
.55 
Type55 
==55  
NotificationType55! 1
.551 2#
TicketCreatedForManager552 I
)55I J
return55K Q
;55Q R
if66 

(66 
notification66 
.66 
	DedupeKey66 "
is66# %
not66& )
null66* .
&&66/ 1
await662 7
db668 :
.66: ;
PortalNotifications66; N
.66N O
AnyAsync66O W
(66W X
x66X Y
=>66Z \
x66] ^
.66^ _
	DedupeKey66_ h
==66i k
notification66l x
.66x y
	DedupeKey	66y Ç
,
66Ç É
cancellationToken
66Ñ ï
)
66ï ñ
)
66ñ ó
return
66ò û
;
66û ü
if77 

(77 
!77 
await77 
db77 
.77 
Clients77 
.77 
AnyAsync77 &
(77& '
x77' (
=>77) +
x77, -
.77- .
Id77. 0
==771 3
clientId774 <
,77< =
cancellationToken77> O
)77O P
)77P Q
return77R X
;77X Y
db88 

.88
 
PortalNotifications88 
.88 
Add88 "
(88" #
new88# &
PortalNotification88' 9
{99 	
ClientId:: 
=:: 
clientId:: 
,::  
Type::! %
=::& '
notification::( 4
.::4 5
Type::5 9
.::9 :
ToString::: B
(::B C
)::C D
,::D E
	DedupeKey::F O
=::P Q
notification::R ^
.::^ _
	DedupeKey::_ h
,::h i
ForStaff;; 
=;; 
notification;; #
.;;# $
Type;;$ (
is;;) +
NotificationType;;, <
.;;< =
TicketCreated;;= J
or;;K M
NotificationType;;N ^
.;;^ _
TransferRequested;;_ p
or;;q s
NotificationType	;;t Ñ
.
;;Ñ Ö
TransferReported
;;Ö ï
,
;;ï ñ
DataJson<< 
=<< 
JsonSerializer<< %
.<<% &
	Serialize<<& /
(<</ 0
notification<<0 <
.<<< =
Data<<= A
.<<A B
Where<<B G
(<<G H
x<<H I
=><<J L
x<<M N
.<<N O
Key<<O R
!=<<S U
$str<<V a
)<<a b
.<<b c
ToDictionary<<c o
(<<o p
)<<p q
)<<q r
,<<r s
}== 	
)==	 

;==
 
await>> 
db>> 
.>> 
SaveChangesAsync>> !
(>>! "
cancellationToken>>" 3
)>>3 4
;>>4 5
}?? 
publicAA 

staticAA 
TaskAA 
<AA 
boolAA 
>AA 
AlreadySentAsyncAA -
(AA- .
RtresDbContextAA. <
dbAA= ?
,AA? @
stringAAA G
	dedupeKeyAAH Q
,AAQ R
CancellationTokenAAS d
cancellationTokenAAe v
)AAv w
=>AAx z
dbBB 

.BB
 
NotificationLogsBB 
.BB 
AnyAsyncBB $
(BB$ %
xBB% &
=>BB' )
xBB* +
.BB+ ,
	DedupeKeyBB, 5
==BB6 8
	dedupeKeyBB9 B
&&BBC E
xBBF G
.BBG H
SuccessBBH O
,BBO P
cancellationTokenBBQ b
)BBb c
;BBc d
}CC 
publicEE 
sealedEE 
classEE $
QueuedNotificationSenderEE ,
(EE, - 
IBackgroundJobClientEE- A
jobsEEB F
)EEF G
:EEH I
INotificationSenderEEJ ]
{FF 
publicGG 

TaskGG 
	SendAsyncGG 
(GG 
ClientGG  
clientGG! '
,GG' (
NotificationGG) 5
notificationGG6 B
,GGB C
CancellationTokenGGD U
cancellationTokenGGV g
=GGh i
defaultGGj q
)GGq r
{HH 
varJJ 
keyedJJ 
=JJ 
notificationJJ  
.JJ  !
	DedupeKeyJJ! *
isJJ+ -
nullJJ. 2
?JJ3 4
notificationJJ5 A
withJJB F
{JJG H
	DedupeKeyJJI R
=JJS T
$"JJU W
$strJJW \
{JJ\ ]
GuidJJ] a
.JJa b
NewGuidJJb i
(JJi j
)JJj k
:JJk l
$strJJl m
}JJm n
"JJn o
}JJp q
:JJr s
notification	JJt Ä
;
JJÄ Å
jobsKK 
.KK 
EnqueueKK 
<KK 
NotificationJobKK $
>KK$ %
(KK% &
jKK& '
=>KK( *
jKK+ ,
.KK, -
	SendAsyncKK- 6
(KK6 7
clientKK7 =
.KK= >
IdKK> @
,KK@ A
keyedKKB G
,KKG H
CancellationTokenKKI Z
.KKZ [
NoneKK[ _
)KK_ `
)KK` a
;KKa b
returnLL 
TaskLL 
.LL 
CompletedTaskLL !
;LL! "
}MM 
}NN á
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\LoginLinkMailer.cs
	namespace 	
Rtres
 
. 
Api 
. 
Notifications !
;! "
public 
	interface 
ILoginLinkMailer !
{ 
void 
Send	 
( 
EmailMessage 
message "
)" #
;# $
}		 
public 
sealed 
class %
BackgroundLoginLinkMailer -
(- . 
IServiceScopeFactory. B
scopesC I
,I J
ILoggerK R
<R S%
BackgroundLoginLinkMailerS l
>l m
loggern t
)t u
:v w
ILoginLinkMailer	x à
{ 
public 

void 
Send 
( 
EmailMessage !
message" )
)) *
=>+ -
_. /
=0 1
Task2 6
.6 7
Run7 :
(: ;
async; @
(A B
)B C
=>D F
{ 
try 
{ 	
using 
var 
scope 
= 
scopes $
.$ %
CreateScope% 0
(0 1
)1 2
;2 3
await 
scope 
. 
ServiceProvider '
.' (
GetRequiredService( :
<: ;
IEmailSender; G
>G H
(H I
)I J
.J K
	SendAsyncK T
(T U
messageU \
)\ ]
;] ^
} 	
catch 
( 
	Exception 
ex 
) 
{ 	
logger 
. 

LogWarning 
( 
ex  
,  !
$str" S
,S T
messageU \
.\ ]
To] _
)_ `
;` a
} 	
} 
) 
; 
} Ø
MC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\AccessEmailService.cs
	namespace 	
Rtres
 
. 
Api 
. 
Notifications !
;! "
public 
sealed 
class 
AccessEmailService &
(& '
NotificationJob' 6
job7 :
,: ;
IConfiguration< J
configurationK X
,X Y
ILoggerZ a
<a b
AccessEmailServiceb t
>t u
loggerv |
)| }
{ 
public 

async 
Task 
< 
bool 
> 
	SendAsync %
(% &
Client& ,
client- 3
,3 4
string5 ;
name< @
,@ A
stringB H
emailI N
,N O
stringP V
temporaryPasswordW h
,h i
HttpRequestj u
?u v
requestw ~
,~ 
CancellationToken
Ä ë
ct
í î
)
î ï
{ 
var 
notification 
= 
new 
Notification +
(+ ,
NotificationType, <
.< =
AccountAccess= J
,J K
newL O
(O P
)P Q
{ 	
[ 
$str 
] 
= 
name 
, 
[ 
$str 
] 
= 
client  
.  !
CompanyName! ,
,, -
[ 
$str 
] 
= 
email 
, 
[ 
$str 
] 
= 
temporaryPassword ,
,, -
[ 
$str 
] 
= !
PayPalCheckoutService 1
.1 2
PortalBaseUrl2 ?
(? @
request@ G
,G H
configurationI V
)V W
,W X
} 	
,	 

To 
: 
email 
) 
; 
try 
{ 	
return 
await 
job 
. 
	SendAsync &
(& '
client' -
.- .
Id. 0
,0 1
notification2 >
,> ?
ct@ B
)B C
;C D
} 	
catch 
( 
	Exception 
ex 
) 
{ 	
logger 
. 

LogWarning 
( 
ex  
,  !
$str" R
,R S
emailT Y
)Y Z
;Z [
return 
false 
; 
} 	
}   
}!! º8
CC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\TaxDueReminderJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class 
TaxDueReminderJob %
(% &
RtresDbContext& 4
db5 7
,7 8
StaffNotifier9 F
staffG L
,L M
ILoggerN U
<U V
TaxDueReminderJobV g
>g h
loggeri o
)o p
{ 
public 

static 
readonly 
int 
[ 
]  
ThresholdDays! .
=/ 0
[1 2
$num2 3
,3 4
$num5 6
,6 7
$num8 9
,9 :
$num; <
]< =
;= >
public 

async 
Task 
	SendAsync 
(  
CancellationToken  1
cancellationToken2 C
)C D
=>E G
awaitH M
	SendAsyncN W
(W X
DateTimeX `
.` a
UtcNowa g
,g h
cancellationTokeni z
)z {
;{ |
public 

async 
Task 
	SendAsync 
(  
DateTime  (
utcNow) /
,/ 0
CancellationToken1 B
cancellationTokenC T
)T U
{ 
var 
settings 
= 
await 
db 
.  
TaxSettings  +
.+ ,
FirstOrDefaultAsync, ?
(? @
cancellationToken@ Q
)Q R
;R S
if 

( 
settings 
is 
null 
|| 
(  !
settings! )
.) *
Ruc* -
is. 0
null1 5
&&6 8
!9 :
settings: B
.B C
IsGoodTaxpayerC Q
)Q R
)R S
{T U
loggerV \
.\ ]
LogInformation] k
(k l
$str	l ≤
)
≤ ≥
;
≥ ¥
return
µ ª
;
ª º
}
Ω æ
var 
today 
= 
	LimaToday 
( 
utcNow $
)$ %
;% &
var 
from 
= 
new 
DateOnly 
(  
today  %
.% &
Year& *
,* +
today, 1
.1 2
Month2 7
,7 8
$num9 :
): ;
.; <
	AddMonths< E
(E F
-F G
$numG H
)H I
;I J
var 
rows 
= 
await 
db 
. 
TaxDueDates '
.' (
Where( -
(- .
x. /
=>0 2
x3 4
.4 5
FiledAt5 <
=== ?
null@ D
&&E G
xH I
.I J
PeriodJ P
>=Q S
fromT X
&&Y [
x\ ]
.] ^
Period^ d
<=e g
todayh m
)m n
.n o
ToListAsynco z
(z {
cancellationToken	{ å
)
å ç
;
ç é
foreach 
( 
var 
row 
in 
rows  
)  !
{ 	
if 
( 
row 
. 
DueFor 
( 
settings #
.# $
Ruc$ '
,' (
settings) 1
.1 2
IsGoodTaxpayer2 @
)@ A
isB D
notE H
DateOnlyI Q
dueR U
)U V
continueW _
;_ `
var 
days 
= 
due 
. 
	DayNumber $
-% &
today' ,
., -
	DayNumber- 6
;6 7
if   
(   
days   
<   
$num   
||   
days    
>  ! "
ThresholdDays  # 0
.  0 1
Max  1 4
(  4 5
)  5 6
)  6 7
continue  8 @
;  @ A
var!! 
	threshold!! 
=!! 
ThresholdDays!! )
.!!) *
Where!!* /
(!!/ 0
t!!0 1
=>!!2 4
days!!5 9
<=!!: <
t!!= >
)!!> ?
.!!? @
Min!!@ C
(!!C D
)!!D E
;!!E F
var"" 
key"" 
="" 
$""" 
$str""  
{""  !
row""! $
.""$ %
Period""% +
:""+ ,
$str"", 2
}""2 3
$str""3 4
{""4 5
due""5 8
:""8 9
$str""9 A
}""A B
$str""B C
{""C D
	threshold""D M
}""M N
"""N O
;""O P
if## 
(## 
await## 
NotificationJob## %
.##% &
AlreadySentAsync##& 6
(##6 7
db##7 9
,##9 :
key##; >
,##> ?
cancellationToken##@ Q
)##Q R
)##R S
continue##T \
;##\ ]
var$$ 
data$$ 
=$$ 
new$$ 

Dictionary$$ %
<$$% &
string$$& ,
,$$, -
string$$. 4
>$$4 5
{%% 
[&& 
$str&& 
]&& 
=&& 
row&&  
.&&  !
Period&&! '
.&&' (
ToString&&( 0
(&&0 1
$str&&1 :
,&&: ;
CultureInfo&&< G
.&&G H
InvariantCulture&&H X
)&&X Y
,&&Y Z
['' 
$str'' 
]'' 
='' 
due'' !
.''! "
ToString''" *
(''* +
$str''+ 7
,''7 8
CultureInfo''9 D
.''D E
InvariantCulture''E U
)''U V
,''V W
[(( 
$str(( 
](( 
=(( 
days(( 
.((  
ToString((  (
(((( )
CultureInfo(() 4
.((4 5
InvariantCulture((5 E
)((E F
,((F G
})) 
;)) 
await** 
staff** 
.** 
	SendAsync** !
(**! "
new**" %
Notification**& 2
(**2 3
NotificationType**3 C
.**C D
TaxDueReminder**D R
,**R S
data**T X
,**X Y
key**Z ]
)**] ^
,**^ _
cancellationToken**` q
)**q r
;**r s
}++ 	
},, 
public// 

static// 
DateOnly// 
	LimaToday// $
(//$ %
DateTime//% -
utcNow//. 4
)//4 5
=>//6 8
DateOnly//9 A
.//A B
FromDateTime//B N
(//N O
utcNow//O U
.//U V
AddHours//V ^
(//^ _
-//_ `
$num//` a
)//a b
)//b c
;//c d
}00 Ê^
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\RenewalReminderJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class 
RenewalReminderJob &
(& '
RtresDbContext' 5
db6 8
,8 9
INotificationSender: M
notificationsN [
)[ \
{ 
public 

static 
readonly 
int 
[ 
]  
ThresholdDays! .
=/ 0
[1 2
$num2 4
,4 5
$num6 7
,7 8
$num9 :
]: ;
;; <
public 

async 
Task 
	SendAsync 
(  
CancellationToken  1
cancellationToken2 C
)C D
=>E G
awaitH M
	SendAsyncN W
(W X
DateTimeX `
.` a
UtcNowa g
,g h
cancellationTokeni z
)z {
;{ |
public 

async 
Task 
	SendAsync 
(  
DateTime  (
now) ,
,, -
CancellationToken. ?
cancellationToken@ Q
)Q R
{ 
var 
today 
= 
now 
. 
Date 
; 
var 
limit 
= 
today 
. 
AddDays !
(! "
ThresholdDays" /
./ 0
Max0 3
(3 4
)4 5
+6 7
$num8 9
)9 :
;: ;
var 
expired 
= 
await 
db 
. 
ClientProducts -
. 
Where 
( 
x 
=> 
( 
x 
. 
Status !
==" $
ClientProductStatus% 8
.8 9
Activo9 ?
||@ B
xC D
.D E
StatusE K
==L N
ClientProductStatusO b
.b c
	PorVencerc l
)l m
&&n p
xq r
.r s
BillingCycles 
!=
Ä Ç
BillingCycle
É è
.
è ê
Unico
ê ï
&&
ñ ò
x
ô ö
.
ö õ
RenewsAt
õ £
!=
§ ¶
null
ß ´
&&
¨ Æ
x
Ø ∞
.
∞ ±
RenewsAt
± π
<
∫ ª
today
º ¡
)
¡ ¬
. 
ToListAsync 
( 
cancellationToken *
)* +
;+ ,
foreach 
( 
var 
item 
in 
expired $
)$ %
item& *
.* +
Status+ 1
=2 3
ClientProductStatus4 G
.G H
VencidoH O
;O P
var 
due 
= 
await 
db 
. 
ClientProducts )
.) *
Include* 1
(1 2
x2 3
=>4 6
x7 8
.8 9
Product9 @
)@ A
. 
Where 
( 
x 
=> 
( 
x 
. 
Status !
==" $
ClientProductStatus% 8
.8 9
Activo9 ?
||@ B
xC D
.D E
StatusE K
==L N
ClientProductStatusO b
.b c
	PorVencerc l
)l m
&&n p
xq r
.r s
BillingCycles 
!=
Ä Ç
BillingCycle
É è
.
è ê
Unico
ê ï
&&
ñ ò
x
ô ö
.
ö õ
RenewsAt
õ £
!=
§ ¶
null
ß ´
&&
¨ Æ
x
Ø ∞
.
∞ ±
RenewsAt
± π
>=
∫ º
today
Ω ¬
&&
√ ≈
x
∆ «
.
« »
RenewsAt
» –
<
— “
limit
” ÿ
)
ÿ Ÿ
. 
Join 
( 
db 
. 
Clients 
. 
Where "
(" #
c# $
=>% '
c( )
.) *
IsActive* 2
)2 3
,3 4
product5 <
=>= ?
product@ G
.G H
ClientIdH P
,P Q
clientR X
=>Y [
client\ b
.b c
Idc e
,e f
(g h
producth o
,o p
clientq w
)w x
=>y {
new| 
{
Ä Å
product
Ç â
,
â ä
client
ã ë
}
í ì
)
ì î
. 
ToListAsync 
( 
cancellationToken *
)* +
;+ ,
var!! 
igvRate!! 
=!! 
await!! 
db!! 
.!! 
IgvRateAsync!! +
(!!+ ,
cancellationToken!!, =
)!!= >
;!!> ?
foreach"" 
("" 
var"" 
("" 
item"" 
,"" 
client"" "
)""" #
in""$ &
due""' *
.""* +
Select""+ 1
(""1 2
x""2 3
=>""4 6
(""7 8
x""8 9
.""9 :
product"": A
,""A B
x""C D
.""D E
client""E K
)""K L
)""L M
)""M N
{## 	
var$$ 
renewsAt$$ 
=$$ 
item$$ 
.$$  
RenewsAt$$  (
!$$( )
.$$) *
Value$$* /
;$$/ 0
var%% 
days%% 
=%% 
(%% 
renewsAt%%  
.%%  !
Date%%! %
-%%& '
today%%( -
)%%- .
.%%. /
Days%%/ 3
;%%3 4
var&& 
	threshold&& 
=&& 
ThresholdDays&& )
.&&) *
Where&&* /
(&&/ 0
t&&0 1
=>&&2 4
days&&5 9
<=&&: <
t&&= >
)&&> ?
.&&? @
Min&&@ C
(&&C D
)&&D E
;&&E F
item'' 
.'' 
Status'' 
='' 
ClientProductStatus'' -
.''- .
	PorVencer''. 7
;''7 8
var(( 
key(( 
=(( 
$"(( 
$str((  
{((  !
item((! %
.((% &
Id((& (
}((( )
$str(() *
{((* +
renewsAt((+ 3
:((3 4
$str((4 <
}((< =
$str((= >
{((> ?
	threshold((? H
}((H I
"((I J
;((J K
if)) 
()) 
await)) 
NotificationJob)) %
.))% &
AlreadySentAsync))& 6
())6 7
db))7 9
,))9 :
key)); >
,))> ?
cancellationToken))@ Q
)))Q R
)))R S
continue))T \
;))\ ]
var** 
data** 
=** 
new** 

Dictionary** %
<**% &
string**& ,
,**, -
string**. 4
>**4 5
{++ 
[,, 
$str,, 
],, 
=,, 
item,, "
.,," #
Product,,# *
?,,* +
.,,+ ,
Name,,, 0
??,,1 3
$str,,4 6
,,,6 7
[-- 
$str-- 
]-- 
=-- 
renewsAt-- '
.--' (
ToString--( 0
(--0 1
$str--1 4
,--4 5
CultureInfo--6 A
.--A B
InvariantCulture--B R
)--R S
,--S T
[.. 
$str.. 
].. 
=.. 
days.. 
...  
ToString..  (
(..( )
CultureInfo..) 4
...4 5
InvariantCulture..5 E
)..E F
,..F G
[// 
$str// 
]// 
=// 
item//  $
.//$ % 
PayPalSubscriptionId//% 9
is//: <
null//= A
?//B C
$str//D K
://L M
$str//N T
,//T U
}00 
;00 
if11 
(11 
!11 
string11 
.11 
IsNullOrWhiteSpace11 *
(11* +
item11+ /
.11/ 0

DomainName110 :
)11: ;
)11; <
data11= A
[11A B
$str11B J
]11J K
=11L M
item11N R
.11R S

DomainName11S ]
;11] ^
if33 
(33 
item33 
.33 
NextChargeTotal33 $
(33$ %
item33% )
.33) *
Product33* 1
is332 4
null335 9
?33: ;
$num33< >
:33? @ 
ClientProductPricing33A U
.33U V

IgvRateFor33V `
(33` a
client33a g
,33g h
item33i m
.33m n
Product33n u
,33u v
igvRate33w ~
)33~ 
)	33 Ä
is
33Å É
decimal
33Ñ ã
price
33å ë
)
33ë í
{44 
data55 
[55 
$str55 
]55 
=55  
price55! &
.55& '
ToString55' /
(55/ 0
CultureInfo550 ;
.55; <
InvariantCulture55< L
)55L M
;55M N
data66 
[66 
$str66 
]66  
=66! "
item66# '
.66' (
Product66( /
?66/ 0
.660 1
Currency661 9
??66: <
$str66= B
;66B C
}77 
await88 
notifications88 
.88  
	SendAsync88  )
(88) *
client88* 0
,880 1
new882 5
Notification886 B
(88B C
NotificationType88C S
.88S T
RenewalReminder88T c
,88c d
data88e i
,88i j
key88k n
)88n o
,88o p
cancellationToken	88q Ç
)
88Ç É
;
88É Ñ
}99 	
await:: 
db:: 
.:: 
SaveChangesAsync:: !
(::! "
cancellationToken::" 3
)::3 4
;::4 5
};; 
publicAA 

staticAA 
ClientProductStatusAA %
	StatusForAA& /
(AA/ 0
ClientProductStatusAA0 C
currentAAD K
,AAK L
DateTimeAAM U
?AAU V
renewsAtAAW _
,AA_ `
DateTimeAAa i
nowAAj m
)AAm n
{BB 
ifCC 

(CC 
currentCC 
isCC 
notCC 
(CC 
ClientProductStatusCC /
.CC/ 0
ActivoCC0 6
orCC7 9
ClientProductStatusCC: M
.CCM N
	PorVencerCCN W
orCCX Z
ClientProductStatusCC[ n
.CCn o
VencidoCCo v
)CCv w
||CCx z
renewsAt	CC{ É
is
CCÑ Ü
not
CCá ä
DateTime
CCã ì
date
CCî ò
)
CCò ô
return
CCö †
current
CC° ®
;
CC® ©
varDD 
todayDD 
=DD 
nowDD 
.DD 
DateDD 
;DD 
ifEE 

(EE 
dateEE 
<EE 
todayEE 
)EE 
returnEE  
ClientProductStatusEE! 4
.EE4 5
VencidoEE5 <
;EE< =
returnFF 
dateFF 
<FF 
todayFF 
.FF 
AddDaysFF #
(FF# $
ThresholdDaysFF$ 1
.FF1 2
MaxFF2 5
(FF5 6
)FF6 7
+FF8 9
$numFF: ;
)FF; <
?FF= >
ClientProductStatusFF? R
.FFR S
	PorVencerFFS \
:FF] ^
ClientProductStatusFF_ r
.FFr s
ActivoFFs y
;FFy z
}GG 
}HH Û;
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\RecurringExpenseJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class 
RecurringExpenseJob '
(' (
RtresDbContext( 6
db7 9
,9 :
ILogger; B
<B C
RecurringExpenseJobC V
>V W
loggerX ^
)^ _
{ 
public 

const 
int 
	DaysAhead 
=  
$num! #
;# $
[ 
AutomaticRetry 
( 
Attempts 
= 
$num  
)  !
,! "&
DisableConcurrentExecution# =
(= >
timeoutInSeconds> N
:N O
$numP S
)S T
]T U
public 

async 
Task 
GenerateAsync #
(# $
CancellationToken$ 5
cancellationToken6 G
)G H
=>I K
awaitL Q
GenerateAsyncR _
(_ `
DateOnly` h
.h i
FromDateTimei u
(u v
DateTimev ~
.~ 
UtcNow	 Ö
.
Ö Ü
AddHours
Ü é
(
é è
-
è ê
$num
ê ë
)
ë í
)
í ì
,
ì î
cancellationToken
ï ¶
)
¶ ß
;
ß ®
public 

async 
Task 
< 
int 
> 
GenerateAsync (
(( )
DateOnly) 1
today2 7
,7 8
CancellationToken9 J
cancellationTokenK \
)\ ]
{ 
var 
	recurring 
= 
await 
db  
.  !
Expenses! )
.) *
Where* /
(/ 0
x0 1
=>2 4
x5 6
.6 7
	Recurring7 @
&&A C
xD E
.E F
RecurrenceCycleF U
!=V X
nullY ]
&&^ `
xa b
.b c
RecurrenceCyclec r
!=s u
BillingCycle	v Ç
.
Ç É
Unico
É à
)
à â
.
â ä
ToListAsync
ä ï
(
ï ñ
cancellationToken
ñ ß
)
ß ®
;
® ©
var 
until 
= 
today 
. 
AddDays !
(! "
	DaysAhead" +
)+ ,
;, -
var 
created 
= 
$num 
; 
foreach 
( 
var 
series 
in 
	recurring (
.( )
GroupBy) 0
(0 1
x1 2
=>3 5
(6 7
Description7 B
:B C
xD E
.E F
DescriptionF Q
.Q R
TrimR V
(V W
)W X
.X Y
ToLowerInvariantY i
(i j
)j k
,k l
xm n
.n o

CategoryIdo y
,y z
x{ |
.| }
Currency	} Ö
)
Ö Ü
)
Ü á
)
á à
{ 	
if 
( 
series 
. 
Any 
( 
x 
=> 
x  !
.! "
RecurrenceEndsAt" 2
is3 5
not6 9
null: >
)> ?
)? @
continueA I
;I J
var 
last 
= 
series 
. 
MaxBy #
(# $
x$ %
=>& (
x) *
.* +
Date+ /
)/ 0
!0 1
;1 2
var 
months 
= 
last 
. 
RecurrenceCycle -
!- .
.. /
Value/ 4
.4 5
Months5 ;
(; <
)< =
;= >
var!! 
anchor!! 
=!! 
series!! 
.!!  
Min!!  #
(!!# $
x!!$ %
=>!!& (
x!!) *
.!!* +
Date!!+ /
)!!/ 0
;!!0 1
var"" 
step"" 
="" 
$num"" 
;"" 
for## 
(## 
var## 
next## 
=## 
anchor## "
.##" #
	AddMonths### ,
(##, -
months##- 3
)##3 4
;##4 5
next##6 :
<=##; =
until##> C
;##C D
next##E I
=##J K
anchor##L R
.##R S
	AddMonths##S \
(##\ ]
months##] c
*##d e
++##f h
step##h l
)##l m
)##m n
{$$ 
if%% 
(%% 
next%% 
<=%% 
last%%  
.%%  !
Date%%! %
||%%& (
next%%) -
<%%. /
today%%0 5
)%%5 6
continue%%7 ?
;%%? @
db&& 
.&& 
Expenses&& 
.&& 
Add&& 
(&&  
new&&  #
Expense&&$ +
{'' 
Description(( 
=((  !
last((" &
.((& '
Description((' 2
,((2 3

CategoryId((4 >
=((? @
last((A E
.((E F

CategoryId((F P
,((P Q
Type((R V
=((W X
last((Y ]
.((] ^
Type((^ b
,((b c
Amount((d j
=((k l
last((m q
.((q r
Amount((r x
,((x y
Currency	((z Ç
=
((É Ñ
last
((Ö â
.
((â ä
Currency
((ä í
,
((í ì
Date)) 
=)) 
next)) 
,))  
	Recurring))! *
=))+ ,
true))- 1
,))1 2
RecurrenceCycle))3 B
=))C D
last))E I
.))I J
RecurrenceCycle))J Y
,))Y Z
IsNonDeductible++ #
=++$ %
last++& *
.++* +
IsNonDeductible+++ :
,++: ;!
IsNonDomiciledService++< Q
=++R S
last++T X
.++X Y!
IsNonDomiciledService++Y n
,++n o 
ForeignSupplierName	++p É
=
++Ñ Ö
last
++Ü ä
.
++ä ã!
ForeignSupplierName
++ã û
,
++û ü$
ForeignSupplierCountry
++† ∂
=
++∑ ∏
last
++π Ω
.
++Ω æ$
ForeignSupplierCountry
++æ ‘
,
++‘ ’
	AmountPen-- 
=-- 
last--  $
.--$ %
Amount--% +
*--, -
await--. 3
db--4 6
.--6 7
RateToPenAsync--7 E
(--E F
last--F J
.--J K
Currency--K S
,--S T
next--U Y
,--Y Z
cancellationToken--[ l
)--l m
,--m n
}.. 
).. 
;.. 
created// 
++// 
;// 
logger00 
.00 
LogInformation00 %
(00% &
$str00& _
,00_ `
last00a e
.00e f
Description00f q
,00q r
next00s w
)00w x
;00x y
}11 
}22 	
await33 
db33 
.33 
SaveChangesAsync33 !
(33! "
cancellationToken33" 3
)333 4
;334 5
return44 
created44 
;44 
}55 
}66 °
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\PayPalReconciliationJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class #
PayPalReconciliationJob +
(+ ,
RtresDbContext, :
db; =
,= > 
PayPalPaymentService? S
paymentsT \
,\ ]
ILogger^ e
<e f#
PayPalReconciliationJobf }
>} ~
logger	 Ö
)
Ö Ü
{ 
[ 
AutomaticRetry 
( 
Attempts 
= 
$num  
)  !
]! "
public 

async 
Task 
ReconcileAsync $
($ %
CancellationToken% 6
ct7 9
)9 :
{ 
var 
items 
= 
await 
db 
. 
ClientProducts +
.+ ,
Include, 3
(3 4
x4 5
=>6 8
x9 :
.: ;
Product; B
)B C
. 
Where 
( 
x 
=> 
x 
.  
PayPalSubscriptionId .
!=/ 1
null2 6
&&7 9
!: ;
x; <
.< =
IsManualBilling= L
&&M O
xP Q
.Q R
StatusR X
!=Y [
ClientProductStatus\ o
.o p
	Canceladop y
)y z
. 
ToListAsync 
( 
ct 
) 
; 
foreach 
( 
var 
item 
in 
items "
)" #
{ 	
try 
{ 
await 
payments  
.  !!
SyncSubscriptionAsync! 6
(6 7
item7 ;
,; <
ct= ?
)? @
;@ A
}B C
catch 
( 
	Exception 
ex 
)  
when! %
(& '
ex' )
is* , 
HttpRequestException- A
orB D%
InvalidOperationExceptionE ^
)^ _
{ 
logger 
. 

LogWarning !
(! "
ex" $
,$ %
$str& {
,{ |
item	} Å
.
Å Ç"
PayPalSubscriptionId
Ç ñ
,
ñ ó
item
ò ú
.
ú ù
Id
ù ü
)
ü †
;
† °
} 
} 	
} 
}   ´:
LC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\GitHubProjectStatusSyncJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class &
GitHubProjectStatusSyncJob .
(. /
RtresDbContext/ =
db> @
,@ A
IGitHubIssuesClientB U
githubV \
,\ ]
INotificationSender^ q
notificationsr 
,	 Ä
ILogger
Å à
<
à â(
GitHubProjectStatusSyncJob
â £
>
£ §
logger
• ´
)
´ ¨
{ 
[ 
AutomaticRetry 
( 
Attempts 
= 
$num  
)  !
,! "&
DisableConcurrentExecution# =
(= >
timeoutInSeconds> N
:N O
$numP S
)S T
]T U
public 

async 
Task 
	SyncAsync 
(  
CancellationToken  1
cancellationToken2 C
)C D
{ 
var 
tickets 
= 
await 
db 
. 
Tickets &
.& '
Where' ,
(, -
x- .
=>/ 1
x2 3
.3 4
GithubIssueNumber4 E
!=F H
nullI M
&&N P
xQ R
.R S
RepositoryIdS _
!=` b
nullc g
&&h j
xk l
.l m
Statusm s
!=t v
TicketStatus	w É
.
É Ñ
Cerrado
Ñ ã
)
ã å
.
å ç
ToListAsync
ç ò
(
ò ô
cancellationToken
ô ™
)
™ ´
;
´ ¨
var 
repositoryIds 
= 
tickets #
.# $
Select$ *
(* +
x+ ,
=>- /
x0 1
.1 2
RepositoryId2 >
!> ?
.? @
Value@ E
)E F
.F G
DistinctG O
(O P
)P Q
.Q R
ToListR X
(X Y
)Y Z
;Z [
var 
repositories 
= 
await  
db! #
.# $
ProjectRepositories$ 7
.7 8
Where8 =
(= >
x> ?
=>@ B
repositoryIdsC P
.P Q
ContainsQ Y
(Y Z
xZ [
.[ \
Id\ ^
)^ _
)_ `
.` a
ToListAsynca l
(l m
cancellationTokenm ~
)~ 
;	 Ä
foreach 
( 
var 

repository 
in  "
repositories# /
)/ 0
{ 	
var 
group 
= 
tickets 
.  
Where  %
(% &
x& '
=>( *
x+ ,
., -
RepositoryId- 9
==: <

repository= G
.G H
IdH J
)J K
.K L
ToListL R
(R S
)S T
;T U
IReadOnlyDictionary 
<  
int  #
,# $
GitHubIssueState% 5
>5 6
states7 =
;= >
try 
{ 
states 
= 
await  
github! '
.' (
GetIssueStatesAsync( ;
(; <

repository< F
,F G
groupH M
.M N
SelectN T
(T U
xU V
=>W Y
xZ [
.[ \
GithubIssueNumber\ m
!m n
.n o
Valueo t
)t u
.u v
ToListv |
(| }
)} ~
,~ 
cancellationToken
Ä ë
)
ë í
;
í ì
}
î ï
catch 
( 
	Exception 
ex 
)  
when! %
(& '
ex' )
is* , 
HttpRequestException- A
orB D%
InvalidOperationExceptionE ^
)^ _
{ 
logger 
. 

LogWarning !
(! "
ex" $
,$ %
$str& a
,a b

repositoryc m
.m n
Ownern s
,s t

repositoryu 
.	 Ä
Name
Ä Ñ
)
Ñ Ö
;
Ö Ü
continue   
;   
}!! 
foreach## 
(## 
var## 
ticket## 
in##  "
group### (
)##( )
{$$ 
if%% 
(%% 
!%% 
states%% 
.%% 
TryGetValue%% '
(%%' (
ticket%%( .
.%%. /
GithubIssueNumber%%/ @
!%%@ A
.%%A B
Value%%B G
,%%G H
out%%I L
var%%M P
state%%Q V
)%%V W
||%%X Z
state%%[ `
.%%` a
ProjectStatus%%a n
is%%o q
null%%r v
||%%w y
state%%z 
.	%% Ä
ProjectStatus
%%Ä ç
==
%%é ê
ticket
%%ë ó
.
%%ó ò!
GithubProjectStatus
%%ò ´
)
%%´ ¨
continue
%%≠ µ
;
%%µ ∂
ticket&& 
.&& 
GithubProjectStatus&& *
=&&+ ,
state&&- 2
.&&2 3
ProjectStatus&&3 @
;&&@ A
if'' 
('' 
GitHubProjectStatus'' '
.''' (
Resolve''( /
(''/ 0
state''0 5
)''5 6
is''7 9
{'': ;
}''< =
status''> D
&&''E G
status''H N
!=''O Q
ticket''R X
.''X Y
Status''Y _
)''_ `
{(( 
ticket)) 
.)) 
Status)) !
=))" #
status))$ *
;))* +
ticket)), 2
.))2 3
	UpdatedAt))3 <
=))= >
DateTime))? G
.))G H
UtcNow))H N
;))N O
await** "
GitHubWebhookProcessor** 0
.**0 1
NotifyTicketAsync**1 B
(**B C
db**C E
,**E F
notifications**G T
,**T U
ticket**V \
,**\ ]
NotificationType**^ n
.**n o 
TicketStatusChanged	**o Ç
,
**Ç É
new
**Ñ á
(
**á à
)
**à â
{
**ä ã
[
**å ç
$str
**ç ï
]
**ï ñ
=
**ó ò
status
**ô ü
.
**ü †
ToString
**† ®
(
**® ©
)
**© ™
}
**´ ¨
,
**¨ ≠
null
**Æ ≤
,
**≤ ≥
cancellationToken
**¥ ≈
)
**≈ ∆
;
**∆ «
logger++ 
.++ 
LogInformation++ )
(++) *
$str++* c
,++c d
ticket++e k
.++k l
Code++l p
,++p q
status++r x
,++x y
state++z 
.	++ Ä
ProjectStatus
++Ä ç
)
++ç é
;
++é è
},, 
}-- 
await.. 
db.. 
... 
SaveChangesAsync.. %
(..% &
cancellationToken..& 7
)..7 8
;..8 9
}// 	
}00 
}11 Ëa
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\GitHubIssueSyncJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class 
GitHubIssueSyncJob &
(& '
RtresDbContext' 5
db6 8
,8 9
IGitHubIssuesClient: M
githubN T
,T U
ILoggerV ]
<] ^
GitHubIssueSyncJob^ p
>p q
loggerr x
)x y
{ 
[ 
AutomaticRetry 
( 
Attempts 
= 
$num  
)  !
]! "
public 

async 
Task 
CreateIssueAsync &
(& '
Guid' +
ticketId, 4
,4 5
CancellationToken6 G
cancellationTokenH Y
)Y Z
{ 
var 
ticket 
= 
await 
db 
. 
Tickets %
.% & 
SingleOrDefaultAsync& :
(: ;
x; <
=>= ?
x@ A
.A B
IdB D
==E G
ticketIdH P
,P Q
cancellationTokenR c
)c d
;d e
if 

( 
ticket 
is 
null 
) 
{ 
logger $
.$ %

LogWarning% /
(/ 0
$str0 _
,_ `
ticketIda i
)i j
;j k
returnl r
;r s
}t u
var 
project 
= 
await 
db 
. 
Projects '
.' (
Include( /
(/ 0
x0 1
=>2 4
x5 6
.6 7
Repositories7 C
)C D
.D E
SingleAsyncE P
(P Q
xQ R
=>S U
xV W
.W X
IdX Z
==[ ]
ticket^ d
.d e
	ProjectIde n
,n o
cancellationToken	p Å
)
Å Ç
;
Ç É
if 

( 
project 
. 
Repositories  
.  !
RepositoryFor! .
(. /
ticket/ 5
.5 6
RepositoryId6 B
)B C
isD F
notG J
{K L
}M N

repositoryO Y
)Y Z
{ 	
logger 
. 

LogWarning 
( 
$str u
,u v
projectw ~
.~ 
Slug	 É
,
É Ñ
ticket
Ö ã
.
ã å
Code
å ê
)
ê ë
;
ë í
return 
; 
} 	
if 

( 
ticket 
. 
GithubIssueNumber $
is% '
null( ,
), -
{ 	
var 
attachments 
= 
await #
db$ &
.& '
TicketAttachments' 8
.8 9
Where9 >
(> ?
x? @
=>A C
xD E
.E F
TicketIdF N
==O Q
ticketR X
.X Y
IdY [
)[ \
.\ ]
OrderBy] d
(d e
xe f
=>g i
xj k
.k l
	CreatedAtl u
)u v
.v w
ToListAsync	w Ç
(
Ç É
cancellationToken
É î
)
î ï
;
ï ñ
foreach 
( 
var 

attachment #
in$ &
attachments' 2
.2 3
Where3 8
(8 9
x9 :
=>; =
x> ?
.? @
Url@ C
.C D
LengthD J
==K M
$numN O
)O P
)P Q
{ 

attachment   
.   
Url   
=    
await  ! &
github  ' -
.  - .
UploadFileAsync  . =
(  = >

repository  > H
,  H I
GitHubIssuesClient  J \
.  \ ]
AttachmentPath  ] k
(  k l
ticket  l r
,  r s

attachment  t ~
)  ~ 
,	   Ä

attachment
  Å ã
.
  ã å
Content
  å ì
,
  ì î
$"
  ï ó
$str
  ó ¢
{
  ¢ £
ticket
  £ ©
.
  © ™
Code
  ™ Æ
}
  Æ Ø
$str
  Ø ±
{
  ± ≤

attachment
  ≤ º
.
  º Ω
FileName
  Ω ≈
}
  ≈ ∆
"
  ∆ «
,
  « »
cancellationToken
  … ⁄
)
  ⁄ €
;
  € ‹
await!! 
db!! 
.!! 
SaveChangesAsync!! )
(!!) *
cancellationToken!!* ;
)!!; <
;!!< =
}"" 
var## 
issue## 
=## 
await## 
github## $
.##$ %
CreateIssueAsync##% 5
(##5 6
project##6 =
,##= >

repository##? I
,##I J
ticket##K Q
,##Q R
attachments##S ^
,##^ _
cancellationToken##` q
)##q r
;##r s
ticket$$ 
.$$ 
RepositoryId$$ 
=$$  !

repository$$" ,
.$$, -
Id$$- /
;$$/ 0
ticket$$1 7
.$$7 8
GithubIssueNumber$$8 I
=$$J K
issue$$L Q
.$$Q R
Number$$R X
;$$X Y
ticket$$Z `
.$$` a
GithubIssueUrl$$a o
=$$p q
issue$$r w
.$$w x
Url$$x {
;$${ |
ticket	$$} É
.
$$É Ñ
	UpdatedAt
$$Ñ ç
=
$$é è
DateTime
$$ê ò
.
$$ò ô
UtcNow
$$ô ü
;
$$ü †
await%% 
db%% 
.%% 
SaveChangesAsync%% %
(%%% &
cancellationToken%%& 7
)%%7 8
;%%8 9
logger&& 
.&& 
LogInformation&& !
(&&! "
$str&&" Z
,&&Z [
ticket&&\ b
.&&b c
Code&&c g
,&&g h

repository&&i s
.&&s t
Owner&&t y
,&&y z

repository	&&{ Ö
.
&&Ö Ü
Name
&&Ü ä
,
&&ä ã
issue
&&å ë
.
&&ë í
Number
&&í ò
)
&&ò ô
;
&&ô ö
}'' 	
var** 
pending** 
=** 
await** 
db** 
.** 
TicketComments** -
.**- .
Where**. 3
(**3 4
x**4 5
=>**6 8
x**9 :
.**: ;
TicketId**; C
==**D F
ticket**G M
.**M N
Id**N P
&&**Q S
!**T U
x**U V
.**V W

FromGithub**W a
&&**b d
x**e f
.**f g
GithubCommentId**g v
==**w y
null**z ~
)**~ 
.	** Ä
OrderBy
**Ä á
(
**á à
x
**à â
=>
**ä å
x
**ç é
.
**é è
	CreatedAt
**è ò
)
**ò ô
.
**ô ö
ToListAsync
**ö •
(
**• ¶
cancellationToken
**¶ ∑
)
**∑ ∏
;
**∏ π
foreach++ 
(++ 
var++ 
comment++ 
in++ 
pending++  '
)++' (
await++) .
PublishAsync++/ ;
(++; <

repository++< F
,++F G
ticket++H N
,++N O
comment++P W
,++W X
cancellationToken++Y j
)++j k
;++k l
},, 
[.. 
AutomaticRetry.. 
(.. 
Attempts.. 
=.. 
$num..  
)..  !
]..! "
public// 

async// 
Task// 
PostCommentAsync// &
(//& '
Guid//' +
	commentId//, 5
,//5 6
CancellationToken//7 H
cancellationToken//I Z
)//Z [
{00 
var11 
comment11 
=11 
await11 
db11 
.11 
TicketComments11 -
.11- . 
SingleOrDefaultAsync11. B
(11B C
x11C D
=>11E G
x11H I
.11I J
Id11J L
==11M O
	commentId11P Y
,11Y Z
cancellationToken11[ l
)11l m
;11m n
if22 

(22 
comment22 
is22 
null22 
||22 
comment22 &
.22& '

FromGithub22' 1
||222 4
comment225 <
.22< =
GithubCommentId22= L
is22M O
not22P S
null22T X
)22X Y
return22Z `
;22` a
var33 
ticket33 
=33 
await33 
db33 
.33 
Tickets33 %
.33% &
SingleAsync33& 1
(331 2
x332 3
=>334 6
x337 8
.338 9
Id339 ;
==33< >
comment33? F
.33F G
TicketId33G O
,33O P
cancellationToken33Q b
)33b c
;33c d
if44 

(44 
ticket44 
.44 
GithubIssueNumber44 $
is44% '
null44( ,
)44, -
return44. 4
;444 5
var55 

repository55 
=55 
await55 
db55 !
.55! "
ProjectRepositories55" 5
.555 6 
SingleOrDefaultAsync556 J
(55J K
x55K L
=>55M O
x55P Q
.55Q R
Id55R T
==55U W
ticket55X ^
.55^ _
RepositoryId55_ k
,55k l
cancellationToken55m ~
)55~ 
;	55 Ä
if66 

(66 

repository66 
is66 
null66 
)66 
return66  &
;66& '
await77 
PublishAsync77 
(77 

repository77 %
,77% &
ticket77' -
,77- .
comment77/ 6
,776 7
cancellationToken778 I
)77I J
;77J K
}88 
private:: 
async:: 
Task:: 
PublishAsync:: #
(::# $
ProjectRepository::$ 5

repository::6 @
,::@ A
Ticket::B H
ticket::I O
,::O P
TicketComment::Q ^
comment::_ f
,::f g
CancellationToken::h y
cancellationToken	::z ã
)
::ã å
{;; 
var<< 
author<< 
=<< 
await<< 
db<< 
.<< 
UserAccounts<< *
.<<* +
Where<<+ 0
(<<0 1
x<<1 2
=><<3 5
x<<6 7
.<<7 8
Id<<8 :
==<<; =
comment<<> E
.<<E F
AuthorUserId<<F R
)<<R S
.<<S T
Select<<T Z
(<<Z [
x<<[ \
=><<] _
x<<` a
.<<a b
Role<<b f
==<<g i
UserRole<<j r
.<<r s

SuperAdmin<<s }
?<<~ 
$str
<<Ä á
:
<<à â
x
<<ä ã
.
<<ã å
Name
<<å ê
==
<<ë ì
$str
<<î ñ
?
<<ó ò
x
<<ô ö
.
<<ö õ
Email
<<õ †
:
<<° ¢
x
<<£ §
.
<<§ •
Name
<<• ©
)
<<© ™
.
<<™ ´"
SingleOrDefaultAsync
<<´ ø
(
<<ø ¿
cancellationToken
<<¿ —
)
<<— “
??
<<” ’
$str
<<÷ ﬂ
;
<<ﬂ ‡
comment== 
.== 
GithubCommentId== 
===  !
await==" '
github==( .
.==. /
CreateCommentAsync==/ A
(==A B

repository==B L
,==L M
ticket==N T
.==T U
GithubIssueNumber==U f
!==f g
.==g h
Value==h m
,==m n
GitHubIssuesClient	==o Å
.
==Å Ç
BuildCommentBody
==Ç í
(
==í ì
comment
==ì ö
,
==ö õ
author
==ú ¢
)
==¢ £
,
==£ §
cancellationToken
==• ∂
)
==∂ ∑
;
==∑ ∏
await>> 
db>> 
.>> 
SaveChangesAsync>> !
(>>! "
cancellationToken>>" 3
)>>3 4
;>>4 5
}?? 
}AA ∆(
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\ExchangeRateSyncJob.cs
	namespace 	
Rtres
 
. 
Api 
. 
Jobs 
; 
public 
sealed 
class 
ExchangeRateSyncJob '
(' (
RtresDbContext( 6
db7 9
,9 :
IExchangeRateClient; N
clientO U
,U V
ILoggerW ^
<^ _
ExchangeRateSyncJob_ r
>r s
loggert z
)z {
{ 
public 

async 
Task 
	SyncAsync 
(  
CancellationToken  1
cancellationToken2 C
)C D
{ 
await 
SyncCurrencyAsync 
(  
$str  %
,% &
client' -
.- .
GetUsdAsync. 9
,9 :
cancellationToken; L
)L M
;M N
await 
SyncCurrencyAsync 
(  
$str  %
,% &
client' -
.- .
GetEurAsync. 9
,9 :
cancellationToken; L
)L M
;M N
await 
db 
. 
SaveChangesAsync !
(! "
cancellationToken" 3
)3 4
;4 5
} 
private 
async 
Task 
SyncCurrencyAsync (
(( )
string) /
currency0 8
,8 9
Func: >
<> ?
CancellationToken? P
,P Q
TaskR V
<V W
ExchangeRateQuoteW h
?h i
>i j
>j k
fetchl q
,q r
CancellationToken	s Ñ
cancellationToken
Ö ñ
)
ñ ó
{ 
ExchangeRateQuote 
? 
quote  
=! "
null# '
;' (
try 
{ 
quote 
= 
await 
fetch !
(! "
cancellationToken" 3
)3 4
;4 5
}6 7
catch 
( 
	Exception 
ex 
) 
{ 
logger %
.% &

LogWarning& 0
(0 1
ex1 3
,3 4
$str5 i
,i j
currencyk s
)s t
;t u
}v w
if 

( 
quote 
is 
null 
) 
{ 	
var 
last 
= 
await 
db 
.  
ExchangeRates  -
.- .
Where. 3
(3 4
x4 5
=>6 8
x9 :
.: ;
CurrencyCode; G
==H J
currencyK S
)S T
.T U
OrderByDescendingU f
(f g
xg h
=>i k
xl m
.m n
Daten r
)r s
.s t 
FirstOrDefaultAsync	t á
(
á à
cancellationToken
à ô
)
ô ö
;
ö õ
if 
( 
last 
is 
null 
) 
{ 
logger  &
.& '

LogWarning' 1
(1 2
$str2 t
,t u
currencyv ~
)~ 
;	 Ä
return
Å á
;
á à
}
â ä
quote   
=   
new   
ExchangeRateQuote   )
(  ) *
DateOnly  * 2
.  2 3
FromDateTime  3 ?
(  ? @
DateTime  @ H
.  H I
UtcNow  I O
)  O P
,  P Q
last  R V
.  V W
	RateToPen  W `
,  ` a
$"  b d
$str  d m
{  m n
last  n r
.  r s
Source  s y
}  y z
"  z {
)  { |
;  | }
}!! 	
if## 

(## 
await## 
db## 
.## 
ExchangeRates## "
.##" #
AnyAsync### +
(##+ ,
x##, -
=>##. 0
x##1 2
.##2 3
Date##3 7
==##8 :
quote##; @
.##@ A
Date##A E
&&##F H
x##I J
.##J K
CurrencyCode##K W
==##X Z
currency##[ c
,##c d
cancellationToken##e v
)##v w
)##w x
return##y 
;	## Ä
db$$ 

.$$
 
ExchangeRates$$ 
.$$ 
Add$$ 
($$ 
new$$  
ExchangeRate$$! -
{$$. /
Date$$0 4
=$$5 6
quote$$7 <
.$$< =
Date$$= A
,$$A B
CurrencyCode$$C O
=$$P Q
currency$$R Z
,$$Z [
	RateToPen$$\ e
=$$f g
quote$$h m
.$$m n
	RateToPen$$n w
,$$w x
Source$$y 
=
$$Ä Å
quote
$$Ç á
.
$$á à
Source
$$à é
}
$$è ê
)
$$ê ë
;
$$ë í
}%% 
}&& °ã
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\GitHub\GitHubWebhookProcessor.cs
	namespace 	
Rtres
 
. 
Api 
. 
GitHub 
; 
public		 
sealed		 
class		 "
GitHubWebhookProcessor		 *
(		* +
RtresDbContext		+ 9
db		: <
,		< =
INotificationSender		> Q
notifications		R _
,		_ `
ILogger		a h
<		h i"
GitHubWebhookProcessor		i 
>			 Ä
logger
		Å á
)
		á à
{

 
public 

async 
Task 
ProcessAsync "
(" #
string# )
	eventName* 3
,3 4
JsonElement5 @
payloadA H
,H I
CancellationTokenJ [
ct\ ^
)^ _
{ 
if 

( 
	eventName 
is 
not 
( 
$str &
or' )
$str* 9
)9 :
): ;
return< B
;B C
if 

( 
! 
payload 
. 
TryGetProperty #
(# $
$str$ +
,+ ,
out- 0
var1 4
issue5 :
): ;
||< >
!? @
payload@ G
.G H
TryGetPropertyH V
(V W
$strW c
,c d
oute h
vari l
repom q
)q r
)r s
returnt z
;z {
if 

( 
issue 
. 
TryGetProperty  
(  !
$str! /
,/ 0
out1 4
_5 6
)6 7
)7 8
return9 ?
;? @
var 
owner 
= 
repo 
. 
GetProperty $
($ %
$str% ,
), -
.- .
GetProperty. 9
(9 :
$str: A
)A B
.B C
	GetStringC L
(L M
)M N
;N O
var 
name 
= 
repo 
. 
GetProperty #
(# $
$str$ *
)* +
.+ ,
	GetString, 5
(5 6
)6 7
;7 8
var 
number 
= 
issue 
. 
GetProperty &
(& '
$str' /
)/ 0
.0 1
GetInt321 9
(9 :
): ;
;; <
var 
ticket 
= 
await 
db 
. 
Tickets %
. 
Join 
( 
db 
. 
ProjectRepositories (
,( )
t* +
=>, .
t/ 0
.0 1
RepositoryId1 =
,= >
r? @
=>A C
(D E
GuidE I
?I J
)J K
rK L
.L M
IdM O
,O P
(Q R
tR S
,S T
rU V
)V W
=>X Z
new[ ^
{_ `
ta b
,b c
rd e
}f g
)g h
. 
Where 
( 
x 
=> 
x 
. 
t 
. 
GithubIssueNumber -
==. 0
number1 7
&&8 :
x; <
.< =
r= >
.> ?
Owner? D
==E G
ownerH M
&&N P
xQ R
.R S
rS T
.T U
NameU Y
==Z \
name] a
)a b
. 
Select 
( 
x 
=> 
x 
. 
t 
) 
.  
SingleOrDefaultAsync 2
(2 3
ct3 5
)5 6
;6 7
if 

( 
ticket 
is 
null 
) 
{ 
logger $
.$ %
LogDebug% -
(- .
$str. l
,l m
ownern s
,s t
nameu y
,y z
number	{ Å
)
Å Ç
;
Ç É
return
Ñ ä
;
ä ã
}
å ç
var 
action 
= 
payload 
. 
GetProperty (
(( )
$str) 1
)1 2
.2 3
	GetString3 <
(< =
)= >
;> ?
if 

( 
	eventName 
== 
$str !
)! "
{# $
if% '
(( )
!) *
AffectsStatus* 7
(7 8
action8 >
,> ?
payload@ G
)G H
)H I
returnJ P
;P Q
awaitR W
ApplyIssueAsyncX g
(g h
ticketh n
,n o
issuep u
,u v
ctw y
)y z
;z {
}| }
else 
await 
ApplyCommentAsync $
($ %
ticket% +
,+ ,
action- 3
,3 4
payload5 <
.< =
GetProperty= H
(H I
$strI R
)R S
,S T
ctU W
)W X
;X Y
await 
db 
. 
SaveChangesAsync !
(! "
ct" $
)$ %
;% &
} 
internal$$ 
static$$ 
bool$$ 
AffectsStatus$$ &
($$& '
string$$' -
?$$- .
action$$/ 5
,$$5 6
JsonElement$$7 B
payload$$C J
)$$J K
=>$$L N
action$$O U
switch$$V \
{%% 
$str&& 
or&& 
$str&& 
=>&& !
true&&" &
,&&& '
$str'' 
or'' 
$str''  
=>''! #
!''$ %
payload''% ,
.'', -
TryGetProperty''- ;
(''; <
$str''< C
,''C D
out''E H
var''I L
label''M R
)''R S
||''T V
(''W X
label''X ]
.''] ^
GetProperty''^ i
(''i j
$str''j p
)''p q
.''q r
	GetString''r {
(''{ |
)''| }
??	''~ Ä
$str
''Å É
)
''É Ñ
.
''Ñ Ö

StartsWith
''Ö è
(
''è ê
GitHubLabels
''ê ú
.
''ú ù
StatusPrefix
''ù ©
,
''© ™
StringComparison
''´ ª
.
''ª º
OrdinalIgnoreCase
''º Õ
)
''Õ Œ
,
''Œ œ
_(( 	
=>((
 
false(( 
,(( 
})) 
;)) 
private++ 
async++ 
Task++ 
ApplyIssueAsync++ &
(++& '
Ticket++' -
ticket++. 4
,++4 5
JsonElement++6 A
issue++B G
,++G H
CancellationToken++I Z
ct++[ ]
)++] ^
{,, 
var-- 
labels-- 
=-- 
issue-- 
.-- 
TryGetProperty-- )
(--) *
$str--* 2
,--2 3
out--4 7
var--8 ;
l--< =
)--= >
&&--? A
l--B C
.--C D
	ValueKind--D M
==--N P
JsonValueKind--Q ^
.--^ _
Array--_ d
?.. 
l.. 
... 
EnumerateArray.. 
(.. 
)..  
...  !
Select..! '
(..' (
x..( )
=>..* ,
x..- .
.... /
GetProperty../ :
(..: ;
$str..; A
)..A B
...B C
	GetString..C L
(..L M
)..M N
??..O Q
string..R X
...X Y
Empty..Y ^
)..^ _
:// 
[// 
]// 
;// 
var00 
stateReason00 
=00 
issue00 
.00  
TryGetProperty00  .
(00. /
$str00/ =
,00= >
out00? B
var00C F
r00G H
)00H I
&&00J L
r00M N
.00N O
	ValueKind00O X
==00Y [
JsonValueKind00\ i
.00i j
String00j p
?00q r
r00s t
.00t u
	GetString00u ~
(00~ 
)	00 Ä
:
00Å Ç
null
00É á
;
00á à
var11 
	newStatus11 
=11 
GitHubLabels11 $
.11$ %
ResolveStatus11% 2
(112 3
issue113 8
.118 9
GetProperty119 D
(11D E
$str11E L
)11L M
.11M N
	GetString11N W
(11W X
)11X Y
??11Z \
$str11] c
,11c d
stateReason11e p
,11p q
labels11r x
)11x y
;11y z
if22 

(22 
	newStatus22 
==22 
ticket22 
.22  
Status22  &
)22& '
return22( .
;22. /
ticket44 
.44 
Status44 
=44 
	newStatus44 !
;44! "
ticket44# )
.44) *
	UpdatedAt44* 3
=444 5
DateTime446 >
.44> ?
UtcNow44? E
;44E F
await55 
NotifyAsync55 
(55 
ticket55  
,55  !
NotificationType55" 2
.552 3
TicketStatusChanged553 F
,55F G
new55H K
(55K L
)55L M
{55N O
[55P Q
$str55Q Y
]55Y Z
=55[ \
	newStatus55] f
.55f g
ToString55g o
(55o p
)55p q
}55r s
,55s t
null55u y
,55y z
ct55{ }
)55} ~
;55~ 
}66 
private88 
Task88 
NotifyAsync88 
(88 
Ticket88 #
ticket88$ *
,88* +
NotificationType88, <
type88= A
,88A B

Dictionary88C M
<88M N
string88N T
,88T U
string88V \
>88\ ]
data88^ b
,88b c
string88d j
?88j k
	dedupeKey88l u
,88u v
CancellationToken	88w à
ct
88â ã
)
88ã å
=>
88ç è
NotifyTicketAsync99 
(99 
db99 
,99 
notifications99 +
,99+ ,
ticket99- 3
,993 4
type995 9
,999 :
data99; ?
,99? @
	dedupeKey99A J
,99J K
ct99L N
)99N O
;99O P
internal;; 
static;; 
async;; 
Task;; 
NotifyTicketAsync;; 0
(;;0 1
RtresDbContext;;1 ?
db;;@ B
,;;B C
INotificationSender;;D W
notifications;;X e
,;;e f
Ticket;;g m
ticket;;n t
,;;t u
NotificationType	;;v Ü
type
;;á ã
,
;;ã å

Dictionary
;;ç ó
<
;;ó ò
string
;;ò û
,
;;û ü
string
;;† ¶
>
;;¶ ß
data
;;® ¨
,
;;¨ ≠
string
;;Æ ¥
?
;;¥ µ
	dedupeKey
;;∂ ø
,
;;ø ¿
CancellationToken
;;¡ “
ct
;;” ’
)
;;’ ÷
{<< 
var== 
client== 
=== 
await== 
db== 
.== 
Clients== %
.==% &
	FindAsync==& /
(==/ 0
[==0 1
ticket==1 7
.==7 8
ClientId==8 @
]==@ A
,==A B
ct==C E
)==E F
;==F G
if>> 

(>> 
client>> 
is>> 
null>> 
)>> 
return>> "
;>>" #
data?? 
[?? 
$str?? 
]?? 
=?? 
ticket?? !
.??! "
Id??" $
.??$ %
ToString??% -
(??- .
)??. /
;??/ 0
data??1 5
[??5 6
$str??6 <
]??< =
=??> ?
ticket??@ F
.??F G
Code??G K
;??K L
data??M Q
[??Q R
$str??R Y
]??Y Z
=??[ \
ticket??] c
.??c d
Title??d i
;??i j
await@@ 
notifications@@ 
.@@ 
	SendAsync@@ %
(@@% &
client@@& ,
,@@, -
new@@. 1
Notification@@2 >
(@@> ?
type@@? C
,@@C D
data@@E I
,@@I J
	dedupeKey@@K T
)@@T U
,@@U V
ct@@W Y
)@@Y Z
;@@Z [
}AA 
privateCC 
asyncCC 
TaskCC 
ApplyCommentAsyncCC (
(CC( )
TicketCC) /
ticketCC0 6
,CC6 7
stringCC8 >
?CC> ?
actionCC@ F
,CCF G
JsonElementCCH S
commentCCT [
,CC[ \
CancellationTokenCC] n
ctCCo q
)CCq r
{DD 
varEE 
	commentIdEE 
=EE 
commentEE 
.EE  
GetPropertyEE  +
(EE+ ,
$strEE, 0
)EE0 1
.EE1 2
GetInt64EE2 :
(EE: ;
)EE; <
;EE< =
varFF 
userFF 
=FF 
commentFF 
.FF 
GetPropertyFF &
(FF& '
$strFF' -
)FF- .
;FF. /
ifGG 

(GG 
userGG 
.GG 
GetPropertyGG 
(GG 
$strGG #
)GG# $
.GG$ %
	GetStringGG% .
(GG. /
)GG/ 0
==GG1 3
$strGG4 9
)GG9 :
returnGG; A
;GGA B
varHH 
bodyHH 
=HH 
commentHH 
.HH 
GetPropertyHH &
(HH& '
$strHH' -
)HH- .
.HH. /
	GetStringHH/ 8
(HH8 9
)HH9 :
??HH; =
stringHH> D
.HHD E
EmptyHHE J
;HHJ K
ifII 

(II 
bodyII 
.II 
ContainsII 
(II 
GitHubLabelsII &
.II& '
PortalCommentMarkerII' :
,II: ;
StringComparisonII< L
.IIL M
OrdinalIIM T
)IIT U
)IIU V
returnIIW ]
;II] ^
varJJ 
existingJJ 
=JJ 
awaitJJ 
dbJJ 
.JJ  
TicketCommentsJJ  .
.JJ. / 
SingleOrDefaultAsyncJJ/ C
(JJC D
xJJD E
=>JJF H
xJJI J
.JJJ K
TicketIdJJK S
==JJT V
ticketJJW ]
.JJ] ^
IdJJ^ `
&&JJa c
xJJd e
.JJe f
GithubCommentIdJJf u
==JJv x
	commentId	JJy Ç
,
JJÇ É
ct
JJÑ Ü
)
JJÜ á
;
JJá à
switchKK 
(KK 
actionKK 
)KK 
{LL 	
caseMM 
$strMM 
whenMM 
existingMM  (
isMM) +
nullMM, 0
:MM0 1
varNN 
loginNN 
=NN 
userNN  
.NN  !
GetPropertyNN! ,
(NN, -
$strNN- 4
)NN4 5
.NN5 6
	GetStringNN6 ?
(NN? @
)NN@ A
;NNA B
dbOO 
.OO 
TicketCommentsOO !
.OO! "
AddOO" %
(OO% &
newOO& )
TicketCommentOO* 7
{OO8 9
TicketIdOO: B
=OOC D
ticketOOE K
.OOK L
IdOOL N
,OON O
BodyOOP T
=OOU V
bodyOOW [
,OO[ \

FromGithubOO] g
=OOh i
trueOOj n
,OOn o
GithubCommentIdOOp 
=
OOÄ Å
	commentId
OOÇ ã
,
OOã å
GithubAuthorLogin
OOç û
=
OOü †
login
OO° ¶
}
OOß ®
)
OO® ©
;
OO© ™
awaitPP 
NotifyAsyncPP !
(PP! "
ticketPP" (
,PP( )
NotificationTypePP* :
.PP: ;
TicketReplyPP; F
,PPF G
newPPH K
(PPK L
)PPL M
{PPN O
[PPP Q
$strPPQ Y
]PPY Z
=PP[ \
loginPP] b
??PPc e
$strPPf m
,PPm n
[PPo p
$strPPp v
]PPv w
=PPx y
bodyPPz ~
}	PP Ä
,
PPÄ Å
$"
PPÇ Ñ
$str
PPÑ ë
{
PPë í
	commentId
PPí õ
}
PPõ ú
"
PPú ù
,
PPù û
ct
PPü °
)
PP° ¢
;
PP¢ £
breakQQ 
;QQ 
caseRR 
$strRR 
whenRR 
existingRR '
isRR( *
notRR+ .
nullRR/ 3
:RR3 4
existingSS 
.SS 
BodySS 
=SS 
bodySS  $
;SS$ %
breakTT 
;TT 
caseUU 
$strUU 
whenUU 
existingUU  (
isUU) +
notUU, /
nullUU0 4
:UU4 5
dbVV 
.VV 
TicketCommentsVV !
.VV! "
RemoveVV" (
(VV( )
existingVV) 1
)VV1 2
;VV2 3
breakWW 
;WW 
defaultXX 
:XX 
returnYY 
;YY 
}ZZ 	
ticket[[ 
.[[ 
	UpdatedAt[[ 
=[[ 
DateTime[[ #
.[[# $
UtcNow[[$ *
;[[* +
}\\ 
}]] ≠«
NC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\TaxCalendarController.cs
	namespace

 	
Rtres


 
.

 
Api

 
.

 
Controllers

 
;

  
[ 
ApiController 
, 
	Authorize 
( 
Roles 
=  !
$str" .
). /
,/ 0
Route1 6
(6 7
$str7 O
)O P
]P Q
public 
sealed 
class !
TaxCalendarController )
() *
RtresDbContext* 8
db9 ;
); <
:= >
ControllerBase? M
{ 
[ 
HttpGet 
] 
public 

async 
Task 
< 
ActionResult "
>" #
Get$ '
(' (
int( +
?+ ,
year- 1
,1 2
CancellationToken3 D
ctE G
)G H
=>I K
OkL N
(N O
awaitO T
GetAsyncU ]
(] ^
year^ b
,b c
DateTimed l
.l m
UtcNowm s
,s t
ctu w
)w x
)x y
;y z
internal 
async 
Task 
< 
TaxCalendarDto &
>& '
GetAsync( 0
(0 1
int1 4
?4 5
year6 :
,: ;
DateTime< D
utcNowE K
,K L
CancellationTokenM ^
ct_ a
)a b
{ 
var 
settings 
= 
await 
db 
.  
TaxSettings  +
.+ ,
FirstOrDefaultAsync, ?
(? @
ct@ B
)B C
??D F
newG J
TaxSettingsK V
(V W
)W X
;X Y
var 
today 
= 
TaxDueReminderJob %
.% &
	LimaToday& /
(/ 0
utcNow0 6
)6 7
;7 8
var 
selected 
= 
year 
?? 
today $
.$ %
Year% )
;) *
var 
years 
= 
await 
db 
. 
TaxDueDates (
.( )
Select) /
(/ 0
x0 1
=>2 4
x5 6
.6 7
Period7 =
.= >
Year> B
)B C
.C D
DistinctD L
(L M
)M N
.N O
OrderByO V
(V W
xW X
=>Y [
x\ ]
)] ^
.^ _
ToListAsync_ j
(j k
ctk m
)m n
;n o
var 
rows 
= 
await 
db 
. 
TaxDueDates '
.' (
Where( -
(- .
x. /
=>0 2
x3 4
.4 5
Period5 ;
.; <
Year< @
==A C
selectedD L
)L M
.M N
OrderByN U
(U V
xV W
=>X Z
x[ \
.\ ]
Period] c
)c d
.d e
ToListAsynce p
(p q
ctq s
)s t
;t u
var 
pending 
= 
( 
await 
db 
.  
TaxDueDates  +
.+ ,
Where, 1
(1 2
x2 3
=>4 6
x7 8
.8 9
FiledAt9 @
==A C
nullD H
)H I
.I J
OrderByJ Q
(Q R
xR S
=>T V
xW X
.X Y
PeriodY _
)_ `
.` a
ToListAsynca l
(l m
ctm o
)o p
)p q
. 
Select 
( 
x 
=> 
( 
Row 
: 
x  
,  !
Due" %
:% &
x' (
.( )
DueFor) /
(/ 0
settings0 8
.8 9
Ruc9 <
,< =
settings> F
.F G
IsGoodTaxpayerG U
)U V
)V W
)W X
.X Y
WhereY ^
(^ _
x_ `
=>a c
xd e
.e f
Duef i
isj l
notm p
nullq u
)u v
.v w
ToListw }
(} ~
)~ 
;	 Ä
var   
next   
=   
pending   
.   
FirstOrDefault   )
(  ) *
x  * +
=>  , .
x  / 0
.  0 1
Due  1 4
>=  5 7
today  8 =
&&  > @
x  A B
.  B C
Row  C F
.  F G
Period  G M
<=  N P
today  Q V
)  V W
;  W X
var!! 
overdue!! 
=!! 
pending!! 
.!! 
Where!! #
(!!# $
x!!$ %
=>!!& (
x!!) *
.!!* +
Due!!+ .
<!!/ 0
today!!1 6
)!!6 7
.!!7 8
Select!!8 >
(!!> ?
x!!? @
=>!!A C
Month!!D I
(!!I J
x!!J K
.!!K L
Row!!L O
.!!O P
Period!!P V
)!!V W
)!!W X
.!!X Y
ToList!!Y _
(!!_ `
)!!` a
;!!a b
return"" 
new"" 
TaxCalendarDto"" !
(""! "
settings""" *
.""* +
Ruc""+ .
,"". /
settings""0 8
.""8 9
IsGoodTaxpayer""9 G
,""G H
today""I N
,""N O
selected""P X
,""X Y
years""Z _
,""_ `
rows## 
.## 
Select## 
(## 
x## 
=>## 
ToDto## "
(##" #
x### $
,##$ %
settings##& .
)##. /
)##/ 0
.##0 1
ToList##1 7
(##7 8
)##8 9
,##9 :
next$$ 
.$$ 
Row$$ 
is$$ 
null$$ 
?$$ 
null$$ #
:$$$ %
ToDto$$& +
($$+ ,
next$$, 0
.$$0 1
Row$$1 4
,$$4 5
settings$$6 >
)$$> ?
,$$? @
overdue$$A H
,$$H I
MissingNextYear&& 
:&& 
today&& "
.&&" #
Month&&# (
==&&) +
$num&&, .
&&&&/ 1
!&&2 3
years&&3 8
.&&8 9
Contains&&9 A
(&&A B
today&&B G
.&&G H
Year&&H L
+&&M N
$num&&O P
)&&P Q
)&&Q R
;&&R S
}'' 
[** 
HttpPut** 
(** 
$str** 
)** 
]** 
public++ 

async++ 
Task++ 
<++ 
ActionResult++ "
>++" #
Upsert++$ *
(++* +
string+++ 1
period++2 8
,++8 9
TaxDueDateRequest++: K
request++L S
,++S T
CancellationToken++U f
ct++g i
)++i j
{,, 
if-- 

(-- 
!-- 
DateOnly-- 
.-- 
TryParseExact-- #
(--# $
period--$ *
+--+ ,
$str--- 2
,--2 3
$str--4 @
,--@ A
CultureInfo--B M
.--M N
InvariantCulture--N ^
,--^ _
DateTimeStyles--` n
.--n o
None--o s
,--s t
out--u x
var--y |
start	--} Ç
)
--Ç É
)
--É Ñ
return
--Ö ã

BadRequest
--å ñ
(
--ñ ó
new
--ó ö
{
--õ ú
message
--ù §
=
--• ¶
$str
--ß “
}
--” ‘
)
--‘ ’
;
--’ ÷
DateOnly.. 
[.. 
].. 
dates.. 
=.. 
[.. 
request.. #
...# $
Digit0..$ *
,..* +
request.., 3
...3 4
Digit1..4 :
,..: ;
request..< C
...C D

Digit2And3..D N
,..N O
request..P W
...W X

Digit4And5..X b
,..b c
request..d k
...k l

Digit6And7..l v
,..v w
request..x 
.	.. Ä

Digit8And9
..Ä ä
,
..ä ã
request
..å ì
.
..ì î
GoodTaxpayer
..î †
]
..† °
;
..° ¢
if00 

(00 
dates00 
.00 
Any00 
(00 
d00 
=>00 
d00 
<00 
start00 $
.00$ %
	AddMonths00% .
(00. /
$num00/ 0
)000 1
||002 4
d005 6
>=007 9
start00: ?
.00? @
	AddMonths00@ I
(00I J
$num00J K
)00K L
)00L M
)00M N
return00O U

BadRequest00V `
(00` a
new00a d
{00e f
message00g n
=00o p
$"00q s
$str	00s ê
{
00ê ë
Month
00ë ñ
(
00ñ ó
start
00ó ú
)
00ú ù
}
00ù û
$str
00û —
"
00— “
}
00” ‘
)
00‘ ’
;
00’ ÷
if11 

(11 
dates11 
.11 
Any11 
(11 
d11 
=>11 
d11 
.11 
	DayOfWeek11 &
is11' )
	DayOfWeek11* 3
.113 4
Saturday114 <
or11= ?
	DayOfWeek11@ I
.11I J
Sunday11J P
)11P Q
)11Q R
return11S Y

BadRequest11Z d
(11d e
new11e h
{11i j
message11k r
=11s t
$str	11u «
}
11» …
)
11…  
;
11  À
var22 
row22 
=22 
await22 
db22 
.22 
TaxDueDates22 &
.22& ' 
SingleOrDefaultAsync22' ;
(22; <
x22< =
=>22> @
x22A B
.22B C
Period22C I
==22J L
start22M R
,22R S
ct22T V
)22V W
;22W X
if33 

(33 
row33 
is33 
null33 
)33 
{33 
row33 
=33  
new33! $

TaxDueDate33% /
{330 1
Period332 8
=339 :
start33; @
}33A B
;33B C
db33D F
.33F G
TaxDueDates33G R
.33R S
Add33S V
(33V W
row33W Z
)33Z [
;33[ \
}33] ^
(44 	
row44	 
.44 
Digit044 
,44 
row44 
.44 
Digit144 
,44  
row44! $
.44$ %

Digit2And344% /
,44/ 0
row441 4
.444 5

Digit4And5445 ?
,44? @
row44A D
.44D E

Digit6And744E O
,44O P
row44Q T
.44T U

Digit8And944U _
,44_ `
row44a d
.44d e
GoodTaxpayer44e q
)44q r
=44s t
(44u v
request44v }
.44} ~
Digit0	44~ Ñ
,
44Ñ Ö
request
44Ü ç
.
44ç é
Digit1
44é î
,
44î ï
request
44ñ ù
.
44ù û

Digit2And3
44û ®
,
44® ©
request
44™ ±
.
44± ≤

Digit4And5
44≤ º
,
44º Ω
request
44æ ≈
.
44≈ ∆

Digit6And7
44∆ –
,
44– —
request
44“ Ÿ
.
44Ÿ ⁄

Digit8And9
44⁄ ‰
,
44‰ Â
request
44Ê Ì
.
44Ì Ó
GoodTaxpayer
44Ó ˙
)
44˙ ˚
;
44˚ ¸
await55 
db55 
.55 
SaveChangesAsync55 !
(55! "
ct55" $
)55$ %
;55% &
return66 
Ok66 
(66 
ToDto66 
(66 
row66 
,66 
await66 "
db66# %
.66% &
TaxSettings66& 1
.661 2
FirstOrDefaultAsync662 E
(66E F
ct66F H
)66H I
??66J L
new66M P
TaxSettings66Q \
(66\ ]
)66] ^
)66^ _
)66_ `
;66` a
}77 
[:: 
HttpPost:: 
(:: 
$str:: 
)::  
]::  !
public;; 

async;; 
Task;; 
<;; 
ActionResult;; "
>;;" #
	MarkFiled;;$ -
(;;- .
Guid;;. 2
id;;3 5
,;;5 6#
TaxPeriodPaymentRequest;;7 N
?;;N O
request;;P W
,;;W X
CancellationToken;;Y j
ct;;k m
);;m n
{<< 
if== 

(== 
request== 
?== 
.== 
IgvPaid== 
<== 
$num==  
||==! #
request==$ +
?==+ ,
.==, -
	RentaPaid==- 6
<==7 8
$num==9 :
)==: ;
return==< B

BadRequest==C M
(==M N
new==N Q
{==R S
message==T [
===\ ]
$str	==^ ã
}
==å ç
)
==ç é
;
==é è
var>> 
row>> 
=>> 
await>> 
db>> 
.>> 
TaxDueDates>> &
.>>& '
	FindAsync>>' 0
(>>0 1
[>>1 2
id>>2 4
]>>4 5
,>>5 6
ct>>7 9
)>>9 :
;>>: ;
if>>< >
(>>? @
row>>@ C
is>>D F
null>>G K
)>>K L
return>>M S
NotFound>>T \
(>>\ ]
)>>] ^
;>>^ _
(?? 	
row??	 
.?? 
IgvPaid?? 
,?? 
row?? 
.?? 
	RentaPaid?? #
)??# $
=??% &
(??' (
request??( /
???/ 0
.??0 1
IgvPaid??1 8
,??8 9
request??: A
???A B
.??B C
	RentaPaid??C L
)??L M
;??M N
return@@ 
await@@ 
SetFiledAsync@@ "
(@@" #
id@@# %
,@@% &
DateTime@@' /
.@@/ 0
UtcNow@@0 6
,@@6 7
ct@@8 :
)@@: ;
;@@; <
}AA 
[CC 

HttpDeleteCC 
(CC 
$strCC !
)CC! "
]CC" #
publicDD 

asyncDD 
TaskDD 
<DD 
ActionResultDD "
>DD" #
UnmarkFiledDD$ /
(DD/ 0
GuidDD0 4
idDD5 7
,DD7 8
CancellationTokenDD9 J
ctDDK M
)DDM N
{EE 
varFF 
rowFF 
=FF 
awaitFF 
dbFF 
.FF 
TaxDueDatesFF &
.FF& '
	FindAsyncFF' 0
(FF0 1
[FF1 2
idFF2 4
]FF4 5
,FF5 6
ctFF7 9
)FF9 :
;FF: ;
ifFF< >
(FF? @
rowFF@ C
isFFD F
nullFFG K
)FFK L
returnFFM S
NotFoundFFT \
(FF\ ]
)FF] ^
;FF^ _
(GG 	
rowGG	 
.GG 
IgvPaidGG 
,GG 
rowGG 
.GG 
	RentaPaidGG #
)GG# $
=GG% &
(GG' (
nullGG( ,
,GG, -
nullGG. 2
)GG2 3
;GG3 4
returnHH 
awaitHH 
SetFiledAsyncHH "
(HH" #
idHH# %
,HH% &
nullHH' +
,HH+ ,
ctHH- /
)HH/ 0
;HH0 1
}II 
[LL 
HttpPostLL 
(LL 
$strLL 
)LL 
]LL 
publicMM 

asyncMM 
TaskMM 
<MM 
ActionResultMM "
>MM" #
MarkOverdueFiledMM$ 4
(MM4 5
CancellationTokenMM5 F
ctMMG I
)MMI J
{NN 
varOO 
settingsOO 
=OO 
awaitOO 
dbOO 
.OO  
TaxSettingsOO  +
.OO+ ,
FirstOrDefaultAsyncOO, ?
(OO? @
ctOO@ B
)OOB C
??OOD F
newOOG J
TaxSettingsOOK V
(OOV W
)OOW X
;OOX Y
varPP 
todayPP 
=PP 
TaxDueReminderJobPP %
.PP% &
	LimaTodayPP& /
(PP/ 0
DateTimePP0 8
.PP8 9
UtcNowPP9 ?
)PP? @
;PP@ A
varQQ 
overdueQQ 
=QQ 
(QQ 
awaitQQ 
dbQQ 
.QQ  
TaxDueDatesQQ  +
.QQ+ ,
WhereQQ, 1
(QQ1 2
xQQ2 3
=>QQ4 6
xQQ7 8
.QQ8 9
FiledAtQQ9 @
==QQA C
nullQQD H
&&QQI K
xQQL M
.QQM N
PeriodQQN T
<QQU V
todayQQW \
)QQ\ ]
.QQ] ^
ToListAsyncQQ^ i
(QQi j
ctQQj l
)QQl m
)QQm n
.QQn o
WhereQQo t
(QQt u
xQQu v
=>QQw y
xQQz {
.QQ{ |
DueFor	QQ| Ç
(
QQÇ É
settings
QQÉ ã
.
QQã å
Ruc
QQå è
,
QQè ê
settings
QQë ô
.
QQô ö
IsGoodTaxpayer
QQö ®
)
QQ® ©
<
QQ™ ´
today
QQ¨ ±
)
QQ± ≤
.
QQ≤ ≥
ToList
QQ≥ π
(
QQπ ∫
)
QQ∫ ª
;
QQª º
foreachRR 
(RR 
varRR 
rowRR 
inRR 
overdueRR #
)RR# $
rowRR% (
.RR( )
FiledAtRR) 0
=RR1 2
DateTimeRR3 ;
.RR; <
UtcNowRR< B
;RRB C
awaitSS 
dbSS 
.SS 
SaveChangesAsyncSS !
(SS! "
ctSS" $
)SS$ %
;SS% &
returnTT 
OkTT 
(TT 
newTT 
{TT 
markedTT 
=TT  
overdueTT! (
.TT( )
CountTT) .
}TT/ 0
)TT0 1
;TT1 2
}UU 
privateWW 
asyncWW 
TaskWW 
<WW 
ActionResultWW #
>WW# $
SetFiledAsyncWW% 2
(WW2 3
GuidWW3 7
idWW8 :
,WW: ;
DateTimeWW< D
?WWD E
filedAtWWF M
,WWM N
CancellationTokenWWO `
ctWWa c
)WWc d
{XX 
varYY 
rowYY 
=YY 
awaitYY 
dbYY 
.YY 
TaxDueDatesYY &
.YY& '
	FindAsyncYY' 0
(YY0 1
[YY1 2
idYY2 4
]YY4 5
,YY5 6
ctYY7 9
)YY9 :
;YY: ;
ifYY< >
(YY? @
rowYY@ C
isYYD F
nullYYG K
)YYK L
returnYYM S
NotFoundYYT \
(YY\ ]
)YY] ^
;YY^ _
rowZZ 
.ZZ 
FiledAtZZ 
=ZZ 
filedAtZZ 
;ZZ 
awaitZZ $
dbZZ% '
.ZZ' (
SaveChangesAsyncZZ( 8
(ZZ8 9
ctZZ9 ;
)ZZ; <
;ZZ< =
return[[ 
Ok[[ 
([[ 
ToDto[[ 
([[ 
row[[ 
,[[ 
await[[ "
db[[# %
.[[% &
TaxSettings[[& 1
.[[1 2
FirstOrDefaultAsync[[2 E
([[E F
ct[[F H
)[[H I
??[[J L
new[[M P
TaxSettings[[Q \
([[\ ]
)[[] ^
)[[^ _
)[[_ `
;[[` a
}\\ 
private^^ 
static^^ 
string^^ 
Month^^ 
(^^  
DateOnly^^  (
period^^) /
)^^/ 0
=>^^1 3
period^^4 :
.^^: ;
ToString^^; C
(^^C D
$str^^D O
,^^O P
CultureInfo^^Q \
.^^\ ]
GetCultureInfo^^] k
(^^k l
$str^^l s
)^^s t
)^^t u
.^^u v
ToLowerInvariant	^^v Ü
(
^^Ü á
)
^^á à
;
^^à â
private`` 
static`` 
TaxDueDateDto``  
ToDto``! &
(``& '

TaxDueDate``' 1
x``2 3
,``3 4
TaxSettings``5 @
settings``A I
)``I J
=>``K M
new``N Q
(``Q R
x``R S
.``S T
Id``T V
,``V W
x``X Y
.``Y Z
Period``Z `
.``` a
ToString``a i
(``i j
$str``j s
,``s t
CultureInfo	``u Ä
.
``Ä Å
InvariantCulture
``Å ë
)
``ë í
,
``í ì
xaa 	
.aa	 

Digit0aa
 
,aa 
xaa 
.aa 
Digit1aa 
,aa 
xaa 
.aa 

Digit2And3aa (
,aa( )
xaa* +
.aa+ ,

Digit4And5aa, 6
,aa6 7
xaa8 9
.aa9 :

Digit6And7aa: D
,aaD E
xaaF G
.aaG H

Digit8And9aaH R
,aaR S
xaaT U
.aaU V
GoodTaxpayeraaV b
,aab c
xaad e
.aae f
DueForaaf l
(aal m
settingsaam u
.aau v
Rucaav y
,aay z
settings	aa{ É
.
aaÉ Ñ
IsGoodTaxpayer
aaÑ í
)
aaí ì
,
aaì î
x
aaï ñ
.
aañ ó
FiledAt
aaó û
,
aaû ü
x
aa† °
.
aa° ¢
IgvPaid
aa¢ ©
,
aa© ™
x
aa´ ¨
.
aa¨ ≠
	RentaPaid
aa≠ ∂
)
aa∂ ∑
;
aa∑ ∏
}bb 
publicdd 
sealeddd 
recorddd 
TaxDueDateRequestdd &
(dd& '
[dd' (
propertydd( 0
:dd0 1
JsonRequireddd2 >
]dd> ?
DateOnlydd@ H
Digit0ddI O
,ddO P
[ddQ R
propertyddR Z
:ddZ [
JsonRequireddd\ h
]ddh i
DateOnlyddj r
Digit1dds y
,ddy z
[dd{ |
property	dd| Ñ
:
ddÑ Ö
JsonRequired
ddÜ í
]
ddí ì
DateOnly
ddî ú

Digit2And3
ddù ß
,
ddß ®
[
dd© ™
property
dd™ ≤
:
dd≤ ≥
JsonRequired
dd¥ ¿
]
dd¿ ¡
DateOnly
dd¬  

Digit4And5
ddÀ ’
,
dd’ ÷
[
dd◊ ÿ
property
ddÿ ‡
:
dd‡ ·
JsonRequired
dd‚ Ó
]
ddÓ Ô
DateOnly
dd ¯

Digit6And7
dd˘ É
,
ddÉ Ñ
[
ddÖ Ü
property
ddÜ é
:
ddé è
JsonRequired
ddê ú
]
ddú ù
DateOnly
ddû ¶

Digit8And9
ddß ±
,
dd± ≤
[
dd≥ ¥
property
dd¥ º
:
ddº Ω
JsonRequired
ddæ  
]
dd  À
DateOnly
ddÃ ‘
GoodTaxpayer
dd’ ·
)
dd· ‚
;
dd‚ „
publicee 
sealedee 
recordee 
TaxDueDateDtoee "
(ee" #
Guidee# '
Idee( *
,ee* +
stringee, 2
Periodee3 9
,ee9 :
DateOnlyee; C
Digit0eeD J
,eeJ K
DateOnlyeeL T
Digit1eeU [
,ee[ \
DateOnlyee] e

Digit2And3eef p
,eep q
DateOnlyeer z

Digit4And5	ee{ Ö
,
eeÖ Ü
DateOnly
eeá è

Digit6And7
eeê ö
,
eeö õ
DateOnly
eeú §

Digit8And9
ee• Ø
,
eeØ ∞
DateOnly
ee± π
GoodTaxpayer
ee∫ ∆
,
ee∆ «
DateOnly
ee» –
?
ee– —
DueDate
ee“ Ÿ
,
eeŸ ⁄
DateTime
ee€ „
?
ee„ ‰
FiledAt
eeÂ Ï
,
eeÏ Ì
decimal
eeÓ ı
?
eeı ˆ
IgvPaid
ee˜ ˛
=
eeˇ Ä
null
eeÅ Ö
,
eeÖ Ü
decimal
eeá é
?
eeé è
	RentaPaid
eeê ô
=
eeö õ
null
eeú †
)
ee† °
;
ee° ¢
publicff 
sealedff 
recordff #
TaxPeriodPaymentRequestff ,
(ff, -
decimalff- 4
?ff4 5
IgvPaidff6 =
,ff= >
decimalff? F
?ffF G
	RentaPaidffH Q
)ffQ R
;ffR S
publicgg 
sealedgg 
recordgg 
TaxCalendarDtogg #
(gg# $
stringgg$ *
?gg* +
Rucgg, /
,gg/ 0
boolgg1 5
IsGoodTaxpayergg6 D
,ggD E
DateOnlyggF N
TodayggO T
,ggT U
intggV Y
YearggZ ^
,gg^ _
Listgg` d
<ggd e
intgge h
>ggh i
Yearsggj o
,ggo p
Listggq u
<ggu v
TaxDueDateDto	ggv É
>
ggÉ Ñ
Rows
ggÖ â
,
ggâ ä
TaxDueDateDto
ggã ò
?
ggò ô
Next
ggö û
,
ggû ü
List
gg† §
<
gg§ •
string
gg• ´
>
gg´ ¨
Overdue
gg≠ ¥
,
gg¥ µ
bool
gg∂ ∫
MissingNextYear
ggª  
)
gg  À
;
ggÀ Ãèj
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PublicContentController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str "
)" #
]# $
public		 
sealed		 
class		 #
PublicContentController		 +
(		+ ,#
IWordPressContentClient		, C
content		D K
,		K L
RtresDbContext		M [
db		\ ^
)		^ _
:		` a
ControllerBase		b p
{

 
[ 
HttpGet 
( 
$str $
)$ %
]% &
public 

async 
Task 
< 
ActionResult "
<" #
WordPressPage# 0
>0 1
>1 2
GetPage3 :
(: ;
string; A
localeB H
,H I
stringJ P
slugQ U
,U V
CancellationTokenW h
cancellationTokeni z
)z {
{ 
if 

( 
locale 
is 
not 
( 
$str 
or  "
$str# '
or( *
$str+ /
)/ 0
)0 1
return2 8
NotFound9 A
(A B
)B C
;C D
return 
await 
content 
. 
GetPageAsync )
() *
locale* 0
,0 1
slug2 6
,6 7
cancellationToken8 I
)I J
isK M
{N O
}P Q
pageR V
?W X
OkY [
([ \
page\ `
)` a
:b c
NotFoundd l
(l m
)m n
;n o
} 
[ 
HttpGet 
( 
$str  
)  !
]! "
public 

async 
Task 
< 
ActionResult "
<" #
IReadOnlyList# 0
<0 1
WordPressProject1 A
>A B
>B C
>C D
GetProjectsE P
(P Q
stringQ W
localeX ^
,^ _
CancellationToken` q
cancellationToken	r É
)
É Ñ
{ 
if 

( 
locale 
is 
not 
( 
$str 
or  "
$str# '
or( *
$str+ /
)/ 0
)0 1
return2 8
NotFound9 A
(A B
)B C
;C D
return 
Ok 
( 
await 
content 
.  
GetProjectsAsync  0
(0 1
locale1 7
,7 8
cancellationToken9 J
)J K
)K L
;L M
} 
[ 
HttpGet 
( 
$str 
)  
]  !
public 

async 
Task 
< 
ActionResult "
<" #
IReadOnlyList# 0
<0 1
WordPressReview1 @
>@ A
>A B
>B C

GetReviewsD N
(N O
stringO U
localeV \
,\ ]
CancellationToken^ o
cancellationToken	p Å
)
Å Ç
{ 
if 

( 
locale 
is 
not 
( 
$str 
or  "
$str# '
or( *
$str+ /
)/ 0
)0 1
return2 8
NotFound9 A
(A B
)B C
;C D
return 
Ok 
( 
await 
content 
.  
GetReviewsAsync  /
(/ 0
locale0 6
,6 7
cancellationToken8 I
)I J
)J K
;K L
} 
[!! 
HttpGet!! 
(!! 
$str!! 
)!! 
]!! 
public"" 

async"" 
Task"" 
<"" 
ActionResult"" "
<""" #
IReadOnlyList""# 0
<""0 1
BlogPostSummaryDto""1 C
>""C D
>""D E
>""E F
GetBlogPosts""G S
(""S T
string""T Z
locale""[ a
,""a b
CancellationToken""c t
cancellationToken	""u Ü
)
""Ü á
{## 
if$$ 

($$ 
locale$$ 
is$$ 
not$$ 
($$ 
$str$$ 
or$$  "
$str$$# '
or$$( *
$str$$+ /
)$$/ 0
)$$0 1
return$$2 8
NotFound$$9 A
($$A B
)$$B C
;$$C D
try%% 
{%% 
return%% 
Ok%% 
(%% 
(%% 
await%% 
content%% &
.%%& '
GetBlogPostsAsync%%' 8
(%%8 9
locale%%9 ?
,%%? @
cancellationToken%%A R
)%%R S
)%%S T
.%%T U
Select%%U [
(%%[ \
Summary%%\ c
)%%c d
.%%d e
ToList%%e k
(%%k l
)%%l m
)%%m n
;%%n o
}%%p q
catch&& 
(&&  
HttpRequestException&& #
)&&# $
{&&% &
return&&' -

StatusCode&&. 8
(&&8 9
StatusCodes&&9 D
.&&D E'
Status503ServiceUnavailable&&E `
)&&` a
;&&a b
}&&c d
}'' 
[)) 
HttpGet)) 
()) 
$str)) #
)))# $
]))$ %
public** 

async** 
Task** 
<** 
ActionResult** "
<**" #
BlogPostDto**# .
>**. /
>**/ 0
GetBlogPost**1 <
(**< =
string**= C
locale**D J
,**J K
string**L R
slug**S W
,**W X
CancellationToken**Y j
cancellationToken**k |
)**| }
{++ 
if,, 

(,, 
locale,, 
is,, 
not,, 
(,, 
$str,, 
or,,  "
$str,,# '
or,,( *
$str,,+ /
),,/ 0
),,0 1
return,,2 8
NotFound,,9 A
(,,A B
),,B C
;,,C D
IReadOnlyList-- 
<-- 
WordPressBlogPost-- '
>--' (
posts--) .
;--. /
try.. 
{.. 
posts.. 
=.. 
await.. 
content.. #
...# $
GetBlogPostsAsync..$ 5
(..5 6
locale..6 <
,..< =
cancellationToken..> O
)..O P
;..P Q
}..R S
catch// 
(//  
HttpRequestException// #
)//# $
{//% &
return//' -

StatusCode//. 8
(//8 9
StatusCodes//9 D
.//D E'
Status503ServiceUnavailable//E `
)//` a
;//a b
}//c d
if00 

(00 
posts00 
.00 
FirstOrDefault00  
(00  !
x00! "
=>00# %
x00& '
.00' (
Slug00( ,
==00- /
slug000 4
)004 5
is006 8
not009 <
{00= >
}00? @
post00A E
)00E F
return00G M
NotFound00N V
(00V W
)00W X
;00X Y
var22 
related22 
=22 
posts22 
.22 
Where22 !
(22! "
x22" #
=>22$ &
x22' (
.22( )
Slug22) -
!=22. 0
slug221 5
)225 6
.226 7
OrderByDescending227 H
(22H I
x22I J
=>22K M
post22N R
.22R S
Tag22S V
is22W Y
not22Z ]
null22^ b
&&22c e
x22f g
.22g h
Tag22h k
==22l n
post22o s
.22s t
Tag22t w
)22w x
.22x y
Take22y }
(22} ~
$num22~ 
)	22 Ä
.
22Ä Å
Select
22Å á
(
22á à
Summary
22à è
)
22è ê
.
22ê ë
ToList
22ë ó
(
22ó ò
)
22ò ô
;
22ô ö
return33 
Ok33 
(33 
new33 
BlogPostDto33 !
(33! "
post33" &
.33& '
Slug33' +
,33+ ,
post33- 1
.331 2
Title332 7
,337 8
post339 =
.33= >
Excerpt33> E
,33E F
post33G K
.33K L
Html33L P
,33P Q
post33R V
.33V W
Tag33W Z
,33Z [
post33\ `
.33` a
PublishedAt33a l
,33l m
post33n r
.33r s
	UpdatedAt33s |
,33| }
post	33~ Ç
.
33Ç É
ReadingMinutes
33É ë
,
33ë í
post
33ì ó
.
33ó ò
CoverUrl
33ò †
,
33† °
post
33¢ ¶
.
33¶ ß
CoverAlt
33ß Ø
,
33Ø ∞
related
33± ∏
)
33∏ π
)
33π ∫
;
33∫ ª
}44 
private66 
static66 
BlogPostSummaryDto66 %
Summary66& -
(66- .
WordPressBlogPost66. ?
x66@ A
)66A B
=>66C E
new66F I
(66I J
x66J K
.66K L
Slug66L P
,66P Q
x66R S
.66S T
Title66T Y
,66Y Z
x66[ \
.66\ ]
Excerpt66] d
,66d e
x66f g
.66g h
Tag66h k
,66k l
x66m n
.66n o
PublishedAt66o z
,66z {
x66| }
.66} ~
ReadingMinutes	66~ å
,
66å ç
x
66é è
.
66è ê
CoverUrl
66ê ò
,
66ò ô
x
66ö õ
.
66õ ú
CoverAlt
66ú §
)
66§ •
;
66• ¶
[88 
HttpGet88 
(88 
$str88 
)88 
]88 
public99 

async99 
Task99 
<99 
ActionResult99 "
>99" #
GetHeroPhoto99$ 0
(990 1
CancellationToken991 B
cancellationToken99C T
)99T U
{:: 
var;; 
url;; 
=;; 
await;; 
content;; 
.;;   
GetHeroPhotoUrlAsync;;  4
(;;4 5
cancellationToken;;5 F
);;F G
;;;G H
return<< 
url<< 
is<< 
null<< 
?<< 
NotFound<< %
(<<% &
)<<& '
:<<( )
Ok<<* ,
(<<, -
new<<- 0
{<<1 2
url<<3 6
}<<7 8
)<<8 9
;<<9 :
}== 
[@@ 
HttpGet@@ 
(@@ 
$str@@ 
)@@ 
]@@ 
publicAA 

asyncAA 
TaskAA 
<AA 
ActionResultAA "
<AA" #
PublicStatsDtoAA# 1
>AA1 2
>AA2 3
GetStatsAA4 <
(AA< =
CancellationTokenAA= N
cancellationTokenAAO `
)AA` a
=>AAb d
OkBB 

(BB
 
newBB 
PublicStatsDtoBB 
(BB 
awaitBB #
dbBB$ &
.BB& '
ClientsBB' .
.BB. /

CountAsyncBB/ 9
(BB9 :
xBB: ;
=>BB< >
xBB? @
.BB@ A
IsActiveBBA I
,BBI J
cancellationTokenBBK \
)BB\ ]
)BB] ^
)BB^ _
;BB_ `
}CC 
publicEE 
sealedEE 
recordEE 
PublicStatsDtoEE #
(EE# $
intEE$ '
ActiveClientsEE( 5
)EE5 6
;EE6 7
publicFF 
sealedFF 
recordFF 
BlogPostSummaryDtoFF '
(FF' (
stringFF( .
SlugFF/ 3
,FF3 4
stringFF5 ;
TitleFF< A
,FFA B
stringFFC I
ExcerptFFJ Q
,FFQ R
stringFFS Y
?FFY Z
TagFF[ ^
,FF^ _
DateTimeOffsetFF` n
PublishedAtFFo z
,FFz {
intFF| 
ReadingMinutes
FFÄ é
,
FFé è
string
FFê ñ
?
FFñ ó
CoverUrl
FFò †
,
FF† °
string
FF¢ ®
?
FF® ©
CoverAlt
FF™ ≤
)
FF≤ ≥
;
FF≥ ¥
publicGG 
sealedGG 
recordGG 
BlogPostDtoGG  
(GG  !
stringGG! '
SlugGG( ,
,GG, -
stringGG. 4
TitleGG5 :
,GG: ;
stringGG< B
ExcerptGGC J
,GGJ K
stringGGL R
HtmlGGS W
,GGW X
stringGGY _
?GG_ `
TagGGa d
,GGd e
DateTimeOffsetGGf t
PublishedAt	GGu Ä
,
GGÄ Å
DateTimeOffset
GGÇ ê
	UpdatedAt
GGë ö
,
GGö õ
int
GGú ü
ReadingMinutes
GG† Æ
,
GGÆ Ø
string
GG∞ ∂
?
GG∂ ∑
CoverUrl
GG∏ ¿
,
GG¿ ¡
string
GG¬ »
?
GG» …
CoverAlt
GG  “
,
GG“ ”
IReadOnlyList
GG‘ ·
<
GG· ‚ 
BlogPostSummaryDto
GG‚ Ù
>
GGÙ ı
Related
GGˆ ˝
)
GG˝ ˛
;
GG˛ ˇ¿∆
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PortalController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
, 
Route  
(  !
$str! &
)& '
]' (
public 
sealed 
class 
PortalController $
($ %
RtresDbContext% 3
db4 6
,6 7 
IBackgroundJobClient8 L
jobsM Q
,Q R
INotificationSenderS f
notificationsg t
,t u
IConfiguration	v Ñ
configuration
Ö í
,
í ì
ILogger
î õ
<
õ ú
PortalController
ú ¨
>
¨ ≠
logger
Æ ¥
,
¥ µ!
BankTransferService
∂ …
	transfers
  ”
)
” ‘
:
’ ÷
ControllerBase
◊ Â
{ 
private 
Guid 
UserId 
=> 
Guid 
.  
Parse  %
(% &
User& *
.* +
FindFirstValue+ 9
(9 :

ClaimTypes: D
.D E
NameIdentifierE S
)S T
!T U
)U V
;V W
private 
bool 
IsSuperAdmin 
=>  
User! %
.% &
IsInRole& .
(. /
nameof/ 5
(5 6
UserRole6 >
.> ?

SuperAdmin? I
)I J
)J K
;K L
private 
IActionResult 
? 
ResolveClientId *
(* +
Guid+ /
?/ 0
clientId1 9
,9 :
out; >
Guid? C
valueD I
)I J
{ 
value 
= 
Guid 
. 
Empty 
; 
if 

( 
IsSuperAdmin 
) 
{ 	
if 
( 
clientId 
is 
not 
Guid  $
	requested% .
). /
return0 6

BadRequest7 A
(A B
newB E
{F G
messageH O
=P Q
$strR |
}} ~
)~ 
;	 Ä
value 
= 
	requested 
; 
return 
null 
; 
} 	
var 
claim 
= 
User 
. 
FindFirstValue '
(' (
$str( 3
)3 4
;4 5
if 

( 
! 
Guid 
. 
TryParse 
( 
claim  
,  !
out" %
value& +
)+ ,
), -
return. 4
Forbid5 ;
(; <
)< =
;= >
return 
null 
; 
} 
[!! 
HttpGet!! 
(!! 
$str!!  
)!!  !
]!!! "
public"" 

async"" 
Task"" 
<"" 
IActionResult"" #
>""# $
Summary""% ,
("", -
Guid""- 1
?""1 2
clientId""3 ;
,""; <
CancellationToken""= N
ct""O Q
)""Q R
{## 
var$$ 
error$$ 
=$$ 
ResolveClientId$$ #
($$# $
clientId$$$ ,
,$$, -
out$$. 1
var$$2 5
id$$6 8
)$$8 9
;$$9 :
if$$; =
($$> ?
error$$? D
is$$E G
not$$H K
null$$L P
)$$P Q
return$$R X
error$$Y ^
;$$^ _
var%% 
p%% 
=%% 
db%% 
.%% 
ClientProducts%% !
.%%! "
Where%%" '
(%%' (
x%%( )
=>%%* ,
x%%- .
.%%. /
ClientId%%/ 7
==%%8 :
id%%; =
)%%= >
;%%> ?
var&& 
next&& 
=&& 
await&& 
p&& 
.&& 
Include&& "
(&&" #
x&&# $
=>&&% '
x&&( )
.&&) *
Product&&* 1
)&&1 2
.&&2 3
Where&&3 8
(&&8 9
x&&9 :
=>&&; =
x&&> ?
.&&? @
NextChargeAt&&@ L
!=&&M O
null&&P T
)&&T U
.&&U V
OrderBy&&V ]
(&&] ^
x&&^ _
=>&&` b
x&&c d
.&&d e
NextChargeAt&&e q
)&&q r
.&&r s 
FirstOrDefaultAsync	&&s Ü
(
&&Ü á
ct
&&á â
)
&&â ä
;
&&ä ã
var'' 
nextPaymentAmount'' 
='' 
next''  $
?''$ %
.''% &
Product''& -
is''. 0
null''1 5
?''6 7
null''8 <
:''= >
next''? C
.''C D
NextChargeTotal''D S
(''S T
await''T Y
db''Z \
.''\ ]
IgvRateForAsync''] l
(''l m
id''m o
,''o p
next''q u
.''u v
Product''v }
,''} ~
ct	'' Å
)
''Å Ç
)
''Ç É
;
''É Ñ
return(( 
Ok(( 
((( 
new(( 
{(( 
activeProducts(( &
=((' (
await(() .
p((/ 0
.((0 1

CountAsync((1 ;
(((; <
x((< =
=>((> @
x((A B
.((B C
Status((C I
==((J L
ClientProductStatus((M `
.((` a
Activo((a g
,((g h
ct((i k
)((k l
,((l m
expiringSoon((n z
=(({ |
await	((} Ç
p
((É Ñ
.
((Ñ Ö

CountAsync
((Ö è
(
((è ê
x
((ê ë
=>
((í î
x
((ï ñ
.
((ñ ó
Status
((ó ù
==
((û †!
ClientProductStatus
((° ¥
.
((¥ µ
	PorVencer
((µ æ
,
((æ ø
ct
((¿ ¬
)
((¬ √
,
((√ ƒ
openTickets
((≈ –
=
((— “
await
((” ÿ
db
((Ÿ €
.
((€ ‹
Tickets
((‹ „
.
((„ ‰

CountAsync
((‰ Ó
(
((Ó Ô
x
((Ô 
=>
((Ò Û
x
((Ù ı
.
((ı ˆ
ClientId
((ˆ ˛
==
((ˇ Å
id
((Ç Ñ
&&
((Ö á
(
((à â
x
((â ä
.
((ä ã
Status
((ã ë
==
((í î
TicketStatus
((ï °
.
((° ¢
Abierto
((¢ ©
||
((™ ¨
x
((≠ Æ
.
((Æ Ø
Status
((Ø µ
==
((∂ ∏
TicketStatus
((π ≈
.
((≈ ∆

EnProgreso
((∆ –
)
((– —
,
((— “
ct
((” ’
)
((’ ÷
,
((÷ ◊
nextPaymentAmount
((ÿ È
}
((Í Î
)
((Î Ï
;
((Ï Ì
})) 
[** 
HttpGet** 
(** 
$str** 
)** 
]**  
public++ 

async++ 
Task++ 
<++ 
IActionResult++ #
>++# $
Products++% -
(++- .
Guid++. 2
?++2 3
clientId++4 <
,++< =
CancellationToken++> O
ct++P R
)++R S
{,, 
var-- 
error-- 
=-- 
ResolveClientId-- #
(--# $
clientId--$ ,
,--, -
out--. 1
var--2 5
id--6 8
)--8 9
;--9 :
if--; =
(--> ?
error--? D
is--E G
not--H K
null--L P
)--P Q
return--R X
error--Y ^
;--^ _
var.. 
items.. 
=.. 
await.. 
db.. 
... 
ClientProducts.. +
...+ ,
Include.., 3
(..3 4
x..4 5
=>..6 8
x..9 :
...: ;
Product..; B
)..B C
...C D
Include..D K
(..K L
x..L M
=>..N P
x..Q R
...R S
Project..S Z
)..Z [
...[ \
Where..\ a
(..a b
x..b c
=>..d f
x..g h
...h i
ClientId..i q
==..r t
id..u w
)..w x
...x y
ToListAsync	..y Ñ
(
..Ñ Ö
ct
..Ö á
)
..á à
;
..à â
var00 
client00 
=00 
await00 
db00 
.00 
Clients00 %
.00% & 
SingleOrDefaultAsync00& :
(00: ;
x00; <
=>00= ?
x00@ A
.00A B
Id00B D
==00E G
id00H J
,00J K
ct00L N
)00N O
;00O P
var00Q T
igvRate00U \
=00] ^
await00_ d
db00e g
.00g h
IgvRateAsync00h t
(00t u
ct00u w
)00w x
;00x y
var11 
reports11 
=11 
await11 
	transfers11 %
.11% &
LatestReportsAsync11& 8
(118 9
items119 >
.11> ?
Select11? E
(11E F
x11F G
=>11H J
x11K L
.11L M
Id11M O
)11O P
,11P Q
ct11R T
)11T U
;11U V
foreach22 
(22 
var22 
item22 
in22 
items22 "
)22" #
{33 	
item44 
.44 
AppliedIgvRate44 
=44  !
client44" (
is44) +
null44, 0
||441 3
item444 8
.448 9
Product449 @
is44A C
null44D H
?44I J
$num44K M
:44N O 
ClientProductPricing44P d
.44d e

IgvRateFor44e o
(44o p
client44p v
,44v w
item44x |
.44| }
Product	44} Ñ
,
44Ñ Ö
igvRate
44Ü ç
)
44ç é
;
44é è
item66 
.66 
TransferReport66 
=66  !
reports66" )
.66) *
TryGetValue66* 5
(665 6
item666 :
.66: ;
Id66; =
,66= >
out66? B
var66C F
report66G M
)66M N
&&66O Q
report66R X
.66X Y
Status66Y _
!=66` b 
TransferReportStatus66c w
.66w x
Aprobado	66x Ä
?
66Å Ç
report
66É â
:
66ä ã
null
66å ê
;
66ê ë
}77 	
return88 
Ok88 
(88 
items88 
)88 
;88 
}99 
[:: 
HttpGet:: 
(:: 
$str:: 
):: 
]:: 
public::  
async::! &
Task::' +
<::+ ,
IActionResult::, 9
>::9 :
Projects::; C
(::C D
Guid::D H
?::H I
clientId::J R
,::R S
CancellationToken::T e
ct::f h
)::h i
{::j k
var::l o
error::p u
=::v w
ResolveClientId	::x á
(
::á à
clientId
::à ê
,
::ê ë
out
::í ï
var
::ñ ô
id
::ö ú
)
::ú ù
;
::ù û
if
::ü °
(
::¢ £
error
::£ ®
is
::© ´
not
::¨ Ø
null
::∞ ¥
)
::¥ µ
return
::∂ º
error
::Ω ¬
;
::¬ √
var
::ƒ «
projects
::» –
=
::— “
await
::” ÿ
db
::Ÿ €
.
::€ ‹
Projects
::‹ ‰
.
::‰ Â
Include
::Â Ï
(
::Ï Ì
x
::Ì Ó
=>
::Ô Ò
x
::Ú Û
.
::Û Ù
Repositories
::Ù Ä
)
::Ä Å
.
::Å Ç
Where
::Ç á
(
::á à
x
::à â
=>
::ä å
x
::ç é
.
::é è
ClientId
::è ó
==
::ò ö
id
::õ ù
)
::ù û
.
::û ü
ToListAsync
::ü ™
(
::™ ´
ct
::´ ≠
)
::≠ Æ
;
::Æ Ø
foreach
::∞ ∑
(
::∏ π
var
::π º
p
::Ω æ
in
::ø ¡
projects
::¬  
)
::  À
p
::Ã Õ
.
::Õ Œ
Repositories
::Œ ⁄
=
::€ ‹
[
::› ﬁ
..
::ﬁ ‡
p
::· ‚
.
::‚ „
Repositories
::„ Ô
.
::Ô 
OrderByDescending
:: Å
(
::Å Ç
r
::Ç É
=>
::Ñ Ü
r
::á à
.
::à â
	IsDefault
::â í
)
::í ì
.
::ì î
ThenBy
::î ö
(
::ö õ
r
::õ ú
=>
::ù ü
r
::† °
.
::° ¢
Name
::¢ ¶
)
::¶ ß
]
::ß ®
;
::® ©
return
::™ ∞
Ok
::± ≥
(
::≥ ¥
projects
::¥ º
)
::º Ω
;
::Ω æ
}
::ø ¿
[;; 
HttpGet;; 
(;; 
$str;; 
);; 
];; 
public;; 
async;;  %
Task;;& *
<;;* +
IActionResult;;+ 8
>;;8 9
Tickets;;: A
(;;A B
Guid;;B F
?;;F G
clientId;;H P
,;;P Q
TicketStatus;;R ^
?;;^ _
status;;` f
=;;g h
null;;i m
,;;m n

TicketType;;o y
?;;y z
type;;{ 
=
;;Ä Å
null
;;Ç Ü
,
;;Ü á
int
;;à ã
page
;;å ê
=
;;ë í
$num
;;ì î
,
;;î ï
CancellationToken
;;ñ ß
ct
;;® ™
=
;;´ ¨
default
;;≠ ¥
)
;;¥ µ
{
;;∂ ∑
var
;;∏ ª
error
;;º ¡
=
;;¬ √
ResolveClientId
;;ƒ ”
(
;;” ‘
clientId
;;‘ ‹
,
;;‹ ›
out
;;ﬁ ·
var
;;‚ Â
id
;;Ê Ë
)
;;Ë È
;
;;È Í
if
;;Î Ì
(
;;Ó Ô
error
;;Ô Ù
is
;;ı ˜
not
;;¯ ˚
null
;;¸ Ä
)
;;Ä Å
return
;;Ç à
error
;;â é
;
;;é è
page
;;ê î
=
;;ï ñ
Math
;;ó õ
.
;;õ ú
Max
;;ú ü
(
;;ü †
page
;;† §
,
;;§ •
$num
;;¶ ß
)
;;ß ®
;
;;® ©
var
;;™ ≠
q
;;Æ Ø
=
;;∞ ±
db
;;≤ ¥
.
;;¥ µ
Tickets
;;µ º
.
;;º Ω
Where
;;Ω ¬
(
;;¬ √
x
;;√ ƒ
=>
;;≈ «
x
;;» …
.
;;…  
ClientId
;;  “
==
;;” ’
id
;;÷ ÿ
&&
;;Ÿ €
(
;;‹ ›
status
;;› „
==
;;‰ Ê
null
;;Á Î
||
;;Ï Ó
x
;;Ô 
.
;; Ò
Status
;;Ò ˜
==
;;¯ ˙
status
;;˚ Å
)
;;Å Ç
&&
;;É Ö
(
;;Ü á
type
;;á ã
==
;;å é
null
;;è ì
||
;;î ñ
x
;;ó ò
.
;;ò ô
Type
;;ô ù
==
;;û †
type
;;° •
)
;;• ¶
)
;;¶ ß
.
;;ß ®
OrderByDescending
;;® π
(
;;π ∫
x
;;∫ ª
=>
;;º æ
x
;;ø ¿
.
;;¿ ¡
	UpdatedAt
;;¡  
)
;;  À
;
;;À Ã
var
;;Õ –
n
;;— “
=
;;” ‘
await
;;’ ⁄
q
;;€ ‹
.
;;‹ ›

CountAsync
;;› Á
(
;;Á Ë
ct
;;Ë Í
)
;;Í Î
;
;;Î Ï
return
;;Ì Û
Ok
;;Ù ˆ
(
;;ˆ ˜
new
;;˜ ˙
{
;;˚ ¸
items
;;˝ Ç
=
;;É Ñ
await
;;Ö ä
q
;;ã å
.
;;å ç
Skip
;;ç ë
(
;;ë í
(
;;í ì
page
;;ì ó
-
;;ò ô
$num
;;ö õ
)
;;õ ú
*
;;ù û
$num
;;ü °
)
;;° ¢
.
;;¢ £
Take
;;£ ß
(
;;ß ®
$num
;;® ™
)
;;™ ´
.
;;´ ¨
ToListAsync
;;¨ ∑
(
;;∑ ∏
ct
;;∏ ∫
)
;;∫ ª
,
;;ª º
page
;;Ω ¡
,
;;¡ ¬

totalPages
;;√ Õ
=
;;Œ œ
(
;;– —
int
;;— ‘
)
;;‘ ’
Math
;;’ Ÿ
.
;;Ÿ ⁄
Ceiling
;;⁄ ·
(
;;· ‚
n
;;‚ „
/
;;‰ Â
$num
;;Ê È
)
;;È Í
}
;;Î Ï
)
;;Ï Ì
;
;;Ì Ó
}
;;Ô 
[<< 
HttpGet<< 
(<< 
$str<<  
)<<  !
]<<! "
public== 

async== 
Task== 
<== 
IActionResult== #
>==# $
Ticket==% +
(==+ ,
Guid==, 0
id==1 3
,==3 4
Guid==5 9
?==9 :
clientId==; C
,==C D
CancellationToken==E V
ct==W Y
)==Y Z
{>> 
var@@ 
	anyClient@@ 
=@@ 
IsSuperAdmin@@ $
&&@@% '
clientId@@( 0
is@@1 3
null@@4 8
;@@8 9
var@@: =
client@@> D
=@@E F
Guid@@G K
.@@K L
Empty@@L Q
;@@Q R
ifAA 

(AA 
!AA 
	anyClientAA 
&&AA 
ResolveClientIdAA )
(AA) *
clientIdAA* 2
,AA2 3
outAA4 7
clientAA8 >
)AA> ?
isAA@ B
{AAC D
}AAE F
errorAAG L
)AAL M
returnAAN T
errorAAU Z
;AAZ [
varBB 
tBB 
=BB 
awaitBB 
dbBB 
.BB 
TicketsBB  
.BB  ! 
SingleOrDefaultAsyncBB! 5
(BB5 6
xBB6 7
=>BB8 :
xBB; <
.BB< =
IdBB= ?
==BB@ B
idBBC E
&&BBF H
(BBI J
	anyClientBBJ S
||BBT V
xBBW X
.BBX Y
ClientIdBBY a
==BBb d
clientBBe k
)BBk l
,BBl m
ctBBn p
)BBp q
;BBq r
ifBBs u
(BBv w
tBBw x
isBBy {
null	BB| Ä
)
BBÄ Å
return
BBÇ à
NotFound
BBâ ë
(
BBë í
)
BBí ì
;
BBì î
varCC 
projectCC 
=CC 
awaitCC 
dbCC 
.CC 
ProjectsCC '
.CC' (
IncludeCC( /
(CC/ 0
xCC0 1
=>CC2 4
xCC5 6
.CC6 7
RepositoriesCC7 C
)CCC D
.CCD E
WhereCCE J
(CCJ K
xCCK L
=>CCM O
xCCP Q
.CCQ R
IdCCR T
==CCU W
tCCX Y
.CCY Z
	ProjectIdCCZ c
)CCc d
.CCd e
SingleAsyncCCe p
(CCp q
ctCCq s
)CCs t
;CCt u
varFF 

repositoryFF 
=FF 
projectFF  
.FF  !
RepositoriesFF! -
.FF- .
CountFF. 3
>FF4 5
$numFF6 7
?FF8 9
projectFF: A
.FFA B
RepositoriesFFB N
.FFN O
RepositoryForFFO \
(FF\ ]
tFF] ^
.FF^ _
RepositoryIdFF_ k
)FFk l
:FFm n
nullFFo s
;FFs t
varGG 
	componentGG 
=GG 

repositoryGG "
isGG# %
nullGG& *
?GG+ ,
nullGG- 1
:GG2 3

repositoryGG4 >
.GG> ?
LabelGG? D
??GGE G

repositoryGGH R
.GGR S
NameGGS W
;GGW X
varHH 
	createdByHH 
=HH 
awaitHH 
dbHH  
.HH  !
UserAccountsHH! -
.HH- .
WhereHH. 3
(HH3 4
xHH4 5
=>HH6 8
xHH9 :
.HH: ;
IdHH; =
==HH> @
tHHA B
.HHB C
CreatedByUserIdHHC R
)HHR S
.HHS T
SelectHHT Z
(HHZ [
xHH[ \
=>HH] _
xHH` a
.HHa b
NameHHb f
==HHg i
$strHHj l
?HHm n
xHHo p
.HHp q
EmailHHq v
:HHw x
xHHy z
.HHz {
NameHH{ 
)	HH Ä
.
HHÄ Å"
SingleOrDefaultAsync
HHÅ ï
(
HHï ñ
ct
HHñ ò
)
HHò ô
;
HHô ö
varII 
attachmentsII 
=II 
awaitII 
dbII  "
.II" #
TicketAttachmentsII# 4
.II4 5
WhereII5 :
(II: ;
xII; <
=>II= ?
xII@ A
.IIA B
TicketIdIIB J
==IIK M
idIIN P
)IIP Q
.IIQ R
OrderByIIR Y
(IIY Z
xIIZ [
=>II\ ^
xII_ `
.II` a
	CreatedAtIIa j
)IIj k
.IIk l
SelectIIl r
(IIr s
xIIs t
=>IIu w
newIIx { 
TicketAttachmentDto	II| è
(
IIè ê
x
IIê ë
.
IIë í
Id
IIí î
,
IIî ï
x
IIñ ó
.
IIó ò
FileName
IIò †
,
II† °
x
II¢ £
.
II£ §
ContentType
II§ Ø
,
IIØ ∞
x
II± ≤
.
II≤ ≥
	SizeBytes
II≥ º
)
IIº Ω
)
IIΩ æ
.
IIæ ø
ToListAsync
IIø  
(
II  À
ct
IIÀ Õ
)
IIÕ Œ
;
IIŒ œ
varJJ 
commentsJJ 
=JJ 
awaitJJ 
ToCommentDtosJJ *
(JJ* +
dbJJ+ -
,JJ- .
dbJJ/ 1
.JJ1 2
TicketCommentsJJ2 @
.JJ@ A
WhereJJA F
(JJF G
xJJG H
=>JJI K
xJJL M
.JJM N
TicketIdJJN V
==JJW Y
idJJZ \
)JJ\ ]
.JJ] ^
OrderByJJ^ e
(JJe f
xJJf g
=>JJh j
xJJk l
.JJl m
	CreatedAtJJm v
)JJv w
)JJw x
.JJx y
ToListAsync	JJy Ñ
(
JJÑ Ö
ct
JJÖ á
)
JJá à
;
JJà â
returnKK 
OkKK 
(KK 
newKK 
{KK 
ticketKK 
=KK  
tKK! "
,KK" #
projectNameKK$ /
=KK0 1
projectKK2 9
.KK9 :
NameKK: >
,KK> ?
componentNameKK@ M
=KKN O
	componentKKP Y
,KKY Z
createdByNameKK[ h
=KKi j
	createdByKKk t
,KKt u
attachments	KKv Å
,
KKÅ Ç
comments
KKÉ ã
}
KKå ç
)
KKç é
;
KKé è
}LL 
[NN 
HttpGetNN 
(NN 
$strNN @
)NN@ A
]NNA B
publicOO 

asyncOO 
TaskOO 
<OO 
IActionResultOO #
>OO# $

AttachmentOO% /
(OO/ 0
GuidOO0 4
idOO5 7
,OO7 8
GuidOO9 =
attachmentIdOO> J
,OOJ K
GuidOOL P
?OOP Q
clientIdOOR Z
,OOZ [
CancellationTokenOO\ m
ctOOn p
)OOp q
{PP 
varQQ 
	anyClientQQ 
=QQ 
IsSuperAdminQQ $
&&QQ% '
clientIdQQ( 0
isQQ1 3
nullQQ4 8
;QQ8 9
varQQ: =
clientQQ> D
=QQE F
GuidQQG K
.QQK L
EmptyQQL Q
;QQQ R
ifRR 

(RR 
!RR 
	anyClientRR 
&&RR 
ResolveClientIdRR )
(RR) *
clientIdRR* 2
,RR2 3
outRR4 7
clientRR8 >
)RR> ?
isRR@ B
{RRC D
}RRE F
errorRRG L
)RRL M
returnRRN T
errorRRU Z
;RRZ [
varSS 
aSS 
=SS 
awaitSS 
dbSS 
.SS 
TicketAttachmentsSS *
.SS* + 
SingleOrDefaultAsyncSS+ ?
(SS? @
xSS@ A
=>SSB D
xSSE F
.SSF G
IdSSG I
==SSJ L
attachmentIdSSM Y
&&SSZ \
xSS] ^
.SS^ _
TicketIdSS_ g
==SSh j
idSSk m
&&SSn p
dbSSq s
.SSs t
TicketsSSt {
.SS{ |
AnySS| 
(	SS Ä
t
SSÄ Å
=>
SSÇ Ñ
t
SSÖ Ü
.
SSÜ á
Id
SSá â
==
SSä å
id
SSç è
&&
SSê í
(
SSì î
	anyClient
SSî ù
||
SSû †
t
SS° ¢
.
SS¢ £
ClientId
SS£ ´
==
SS¨ Æ
client
SSØ µ
)
SSµ ∂
)
SS∂ ∑
,
SS∑ ∏
ct
SSπ ª
)
SSª º
;
SSº Ω
returnTT 
aTT 
isTT 
nullTT 
?TT 
NotFoundTT #
(TT# $
)TT$ %
:TT& '
FileTT( ,
(TT, -
aTT- .
.TT. /
ContentTT/ 6
,TT6 7
aTT8 9
.TT9 :
ContentTypeTT: E
,TTE F
aTTG H
.TTH I
FileNameTTI Q
)TTQ R
;TTR S
}UU 
[VV 
HttpPostVV 
(VV 
$strVV *
)VV* +
]VV+ ,
publicWW 

asyncWW 
TaskWW 
<WW 
IActionResultWW #
>WW# $

AddCommentWW% /
(WW/ 0
GuidWW0 4
idWW5 7
,WW7 8&
CreateTicketCommentRequestWW9 S
rWWT U
,WWU V
CancellationTokenWWW h
ctWWi k
)WWk l
{XX 
ifYY 

(YY 
IsSuperAdminYY 
)YY 
returnYY  
ForbidYY! '
(YY' (
)YY( )
;YY) *
varZZ 
errorZZ 
=ZZ 
ResolveClientIdZZ #
(ZZ# $
nullZZ$ (
,ZZ( )
outZZ* -
varZZ. 1
clientZZ2 8
)ZZ8 9
;ZZ9 :
ifZZ; =
(ZZ> ?
errorZZ? D
isZZE G
notZZH K
nullZZL P
)ZZP Q
returnZZR X
errorZZY ^
;ZZ^ _
if[[ 

([[ 
string[[ 
.[[ 
IsNullOrWhiteSpace[[ %
([[% &
r[[& '
.[[' (
Body[[( ,
)[[, -
)[[- .
return[[/ 5

BadRequest[[6 @
([[@ A
new[[A D
{[[E F
message[[G N
=[[O P
$str[[Q v
}[[w x
)[[x y
;[[y z
var\\ 
ticket\\ 
=\\ 
await\\ 
db\\ 
.\\ 
Tickets\\ %
.\\% & 
SingleOrDefaultAsync\\& :
(\\: ;
x\\; <
=>\\= ?
x\\@ A
.\\A B
Id\\B D
==\\E G
id\\H J
&&\\K M
x\\N O
.\\O P
ClientId\\P X
==\\Y [
client\\\ b
,\\b c
ct\\d f
)\\f g
;\\g h
if\\i k
(\\l m
ticket\\m s
is\\t v
null\\w {
)\\{ |
return	\\} É
NotFound
\\Ñ å
(
\\å ç
)
\\ç é
;
\\é è
var]] 
comment]] 
=]] 
new]] 
TicketComment]] '
{]]( )
TicketId]]* 2
=]]3 4
id]]5 7
,]]7 8
AuthorUserId]]9 E
=]]F G
UserId]]H N
,]]N O
Body]]P T
=]]U V
r]]W X
.]]X Y
Body]]Y ]
.]]] ^
Trim]]^ b
(]]b c
)]]c d
}]]e f
;]]f g
db^^ 

.^^
 
TicketComments^^ 
.^^ 
Add^^ 
(^^ 
comment^^ %
)^^% &
;^^& '
ticket^^( .
.^^. /
	UpdatedAt^^/ 8
=^^9 :
DateTime^^; C
.^^C D
UtcNow^^D J
;^^J K
await^^L Q
db^^R T
.^^T U
SaveChangesAsync^^U e
(^^e f
ct^^f h
)^^h i
;^^i j
jobs__ 
.__ 
Enqueue__ 
<__ 
GitHubIssueSyncJob__ '
>__' (
(__( )
j__) *
=>__+ -
j__. /
.__/ 0
PostCommentAsync__0 @
(__@ A
comment__A H
.__H I
Id__I K
,__K L
CancellationToken__M ^
.__^ _
None___ c
)__c d
)__d e
;__e f
return`` 
Ok`` 
(`` 
await`` 
ToCommentDtos`` %
(``% &
db``& (
,``( )
db``* ,
.``, -
TicketComments``- ;
.``; <
Where``< A
(``A B
x``B C
=>``D F
x``G H
.``H I
Id``I K
==``L N
comment``O V
.``V W
Id``W Y
)``Y Z
)``Z [
.``[ \
SingleAsync``\ g
(``g h
ct``h j
)``j k
)``k l
;``l m
}aa 
internalcc 
staticcc 

IQueryablecc 
<cc 
TicketCommentDtocc /
>cc/ 0
ToCommentDtoscc1 >
(cc> ?
RtresDbContextcc? M
dbccN P
,ccP Q

IQueryableccR \
<cc\ ]
TicketCommentcc] j
>ccj k
commentsccl t
)cct u
=>ccv x
comments	ccy Å
.dd 	
Selectdd	 
(dd 
xdd 
=>dd 
newdd 
TicketCommentDtodd )
(dd) *
xdd* +
.dd+ ,
Iddd, .
,dd. /
xdd0 1
.dd1 2
Bodydd2 6
,dd6 7
xdd8 9
.dd9 :

FromGithubdd: D
,ddD E
xddF G
.ddG H

FromGithubddH R
?ddS T
xddU V
.ddV W
GithubAuthorLoginddW h
:ddi j
dbddk m
.ddm n
UserAccountsddn z
.ddz {
Where	dd{ Ä
(
ddÄ Å
u
ddÅ Ç
=>
ddÉ Ö
u
ddÜ á
.
ddá à
Id
ddà ä
==
ddã ç
x
ddé è
.
ddè ê
AuthorUserId
ddê ú
)
ddú ù
.
ddù û
Select
ddû §
(
dd§ •
u
dd• ¶
=>
ddß ©
u
dd™ ´
.
dd´ ¨
Role
dd¨ ∞
==
dd± ≥
UserRole
dd¥ º
.
ddº Ω

SuperAdmin
ddΩ «
?
dd» …
$str
dd  —
:
dd“ ”
u
dd‘ ’
.
dd’ ÷
Name
dd÷ ⁄
==
dd€ ›
$str
ddﬁ ‡
?
dd· ‚
u
dd„ ‰
.
dd‰ Â
Email
ddÂ Í
:
ddÎ Ï
u
ddÌ Ó
.
ddÓ Ô
Name
ddÔ Û
)
ddÛ Ù
.
ddÙ ı
FirstOrDefault
ddı É
(
ddÉ Ñ
)
ddÑ Ö
,
ddÖ Ü
x
ddá à
.
ddà â
	CreatedAt
ddâ í
)
ddí ì
)
ddì î
;
ddî ï
publicee 

constee 
intee 
MaxAttachmentsee #
=ee$ %
$numee& '
;ee' (
publicff 

constff 
longff 
MaxAttachmentBytesff (
=ff) *
$numff+ -
*ff. /
$numff0 4
*ff5 6
$numff7 ;
;ff; <
[ii 
HttpPostii 
(ii 
$strii 
)ii 
,ii 
RequestSizeLimitii *
(ii* +
$numii+ 5
)ii5 6
,ii6 7
RequestFormLimitsii8 I
(iiI J$
MultipartBodyLengthLimitiiJ b
=iic d
$numiie o
)iio p
]iip q
publicjj 

asyncjj 
Taskjj 
<jj 
IActionResultjj #
>jj# $
CreateTicketjj% 1
(jj1 2
[jj2 3
FromFormjj3 ;
]jj; <
CreateTicketRequestjj= P
rjjQ R
,jjR S
GuidjjT X
?jjX Y
clientIdjjZ b
,jjb c
CancellationTokenjjd u
ctjjv x
,jjx y
[jjz {
FromForm	jj{ É
]
jjÉ Ñ
List
jjÖ â
<
jjâ ä
	IFormFile
jjä ì
>
jjì î
?
jjî ï
files
jjñ õ
=
jjú ù
null
jjû ¢
)
jj¢ £
{kk 
varll 
errorll 
=ll 
ResolveClientIdll #
(ll# $
clientIdll$ ,
,ll, -
outll. 1
varll2 5
clientIdValuell6 C
)llC D
;llD E
ifllF H
(llI J
errorllJ O
isllP R
notllS V
nullllW [
)ll[ \
returnll] c
errorlld i
;lli j
filesmm 
??=mm 
[mm 
]mm 
;mm 
ifnn 

(nn 
filesnn 
.nn 
Countnn 
>nn 
MaxAttachmentsnn (
)nn( )
returnnn* 0

BadRequestnn1 ;
(nn; <
newnn< ?
{nn@ A
messagennB I
=nnJ K
$"nnL N
$strnnN U
{nnU V
MaxAttachmentsnnV d
}nnd e
$strnne z
"nnz {
}nn| }
)nn} ~
;nn~ 
ifoo 

(oo 
filesoo 
.oo 
FirstOrDefaultoo  
(oo  !
xoo! "
=>oo# %
xoo& '
.oo' (
Lengthoo( .
==oo/ 1
$numoo2 3
||oo4 6
xoo7 8
.oo8 9
Lengthoo9 ?
>oo@ A
MaxAttachmentBytesooB T
)ooT U
isooV X
{ooY Z
}oo[ \
invalidoo] d
)ood e
returnoof l

BadRequestoom w
(oow x
newoox {
{oo| }
message	oo~ Ö
=
ooÜ á
$"
ooà ä
$str
ooä ã
{
ooã å
invalid
ooå ì
.
ooì î
FileName
ooî ú
}
ooú ù
$str
ooù æ
"
ooæ ø
}
oo¿ ¡
)
oo¡ ¬
;
oo¬ √
varpp 
projectpp 
=pp 
awaitpp 
dbpp 
.pp 
Projectspp '
.pp' (
Includepp( /
(pp/ 0
xpp0 1
=>pp2 4
xpp5 6
.pp6 7
Repositoriespp7 C
)ppC D
.ppD E 
SingleOrDefaultAsyncppE Y
(ppY Z
xppZ [
=>pp\ ^
xpp_ `
.pp` a
Idppa c
==ppd f
rppg h
.pph i
	ProjectIdppi r
&&pps u
xppv w
.ppw x
ClientId	ppx Ä
==
ppÅ É
clientIdValue
ppÑ ë
,
ppë í
ct
ppì ï
)
ppï ñ
;
ppñ ó
if
ppò ö
(
ppõ ú
project
ppú £
is
pp§ ¶
null
ppß ´
)
pp´ ¨
return
pp≠ ≥
NotFound
pp¥ º
(
ppº Ω
)
ppΩ æ
;
ppæ ø
ifqq 

(qq 
rqq 
.qq 
RepositoryIdqq 
isqq 
Guidqq "
repositoryIdqq# /
&&qq0 2
projectqq3 :
.qq: ;
Repositoriesqq; G
.qqG H
AllqqH K
(qqK L
xqqL M
=>qqN P
xqqQ R
.qqR S
IdqqS U
!=qqV X
repositoryIdqqY e
)qqe f
)qqf g
returnqqh n

BadRequestqqo y
(qqy z
newqqz }
{qq~ 
message
qqÄ á
=
qqà â
$str
qqä ¥
}
qqµ ∂
)
qq∂ ∑
;
qq∑ ∏
ifrr 

(rr 
rrr 
.rr 
ClientProductIdrr 
isrr  
Guidrr! %
clientProductIdrr& 5
&&rr6 8
!rr9 :
awaitrr: ?
dbrr@ B
.rrB C
ClientProductsrrC Q
.rrQ R
AnyAsyncrrR Z
(rrZ [
xrr[ \
=>rr] _
xrr` a
.rra b
Idrrb d
==rre g
clientProductIdrrh w
&&rrx z
xrr{ |
.rr| }
ClientId	rr} Ö
==
rrÜ à
clientIdValue
rrâ ñ
&&
rró ô
x
rrö õ
.
rrõ ú
	ProjectId
rrú •
==
rr¶ ®
r
rr© ™
.
rr™ ´
	ProjectId
rr´ ¥
&&
rrµ ∑
x
rr∏ π
.
rrπ ∫
Product
rr∫ ¡
!
rr¡ ¬
.
rr¬ √
AllowsTickets
rr√ –
,
rr– —
ct
rr“ ‘
)
rr‘ ’
)
rr’ ÷
returnss 

BadRequestss 
(ss 
newss !
{ss" #
messagess$ +
=ss, -
$strss. O
}ssP Q
)ssQ R
;ssR S
vartt 
tickettt 
=tt 
newtt 
Tickettt 
{tt  !
Codett" &
=tt' (
$"tt) +
$strtt+ .
{tt. /
$numtt/ 2
+tt3 4
awaittt5 :
dbtt; =
.tt= >
Ticketstt> E
.ttE F

CountAsyncttF P
(ttP Q
ctttQ S
)ttS T
}ttT U
"ttU V
,ttV W
ClientIdttX `
=tta b
clientIdValuettc p
,ttp q
	ProjectIdttr {
=tt| }
rtt~ 
.	tt Ä
	ProjectId
ttÄ â
,
ttâ ä
RepositoryId
ttã ó
=
ttò ô
r
ttö õ
.
ttõ ú
RepositoryId
ttú ®
,
tt® ©
ClientProductId
tt™ π
=
tt∫ ª
r
ttº Ω
.
ttΩ æ
ClientProductId
ttæ Õ
,
ttÕ Œ
CreatedByUserId
ttœ ﬁ
=
ttﬂ ‡
UserId
tt· Á
,
ttÁ Ë
Type
ttÈ Ì
=
ttÓ Ô
r
tt Ò
.
ttÒ Ú
Type
ttÚ ˆ
,
ttˆ ˜
Title
tt¯ ˝
=
tt˛ ˇ
r
ttÄ Å
.
ttÅ Ç
Title
ttÇ á
,
ttá à
Description
ttâ î
=
ttï ñ
r
ttó ò
.
ttò ô
Description
ttô §
,
tt§ •
CurrentBehavior
tt¶ µ
=
tt∂ ∑
r
tt∏ π
.
ttπ ∫
CurrentBehavior
tt∫ …
,
tt…  
ExpectedBehavior
ttÀ €
=
tt‹ ›
r
ttﬁ ﬂ
.
ttﬂ ‡
ExpectedBehavior
tt‡ 
,
tt Ò
StepsToReproduce
ttÚ Ç
=
ttÉ Ñ
r
ttÖ Ü
.
ttÜ á
StepsToReproduce
ttá ó
,
ttó ò
Environment
ttô §
=
tt• ¶
r
ttß ®
.
tt® ©
Environment
tt© ¥
,
tt¥ µ 
AcceptanceCriteria
tt∂ »
=
tt…  
r
ttÀ Ã
.
ttÃ Õ 
AcceptanceCriteria
ttÕ ﬂ
,
ttﬂ ‡
EstimatedImpact
tt· 
=
ttÒ Ú
r
ttÛ Ù
.
ttÙ ı
EstimatedImpact
ttı Ñ
}
ttÖ Ü
;
ttÜ á
dbuu 

.uu
 
Ticketsuu 
.uu 
Adduu 
(uu 
ticketuu 
)uu 
;uu 
foreachvv 
(vv 
varvv 
filevv 
invv 
filesvv "
)vv" #
{ww 	
usingxx 
varxx 
streamxx 
=xx 
newxx "
MemoryStreamxx# /
(xx/ 0
)xx0 1
;xx1 2
awaitxx3 8
filexx9 =
.xx= >
CopyToAsyncxx> I
(xxI J
streamxxJ P
,xxP Q
ctxxR T
)xxT U
;xxU V
dbyy 
.yy 
TicketAttachmentsyy  
.yy  !
Addyy! $
(yy$ %
newyy% (
TicketAttachmentyy) 9
{yy: ;
TicketIdyy< D
=yyE F
ticketyyG M
.yyM N
IdyyN P
,yyP Q
FileNameyyR Z
=yy[ \
Pathyy] a
.yya b
GetFileNameyyb m
(yym n
fileyyn r
.yyr s
FileNameyys {
)yy{ |
,yy| }
ContentType	yy~ â
=
yyä ã
string
yyå í
.
yyí ì 
IsNullOrWhiteSpace
yyì •
(
yy• ¶
file
yy¶ ™
.
yy™ ´
ContentType
yy´ ∂
)
yy∂ ∑
?
yy∏ π
$str
yy∫ ‘
:
yy’ ÷
file
yy◊ €
.
yy€ ‹
ContentType
yy‹ Á
,
yyÁ Ë
	SizeBytes
yyÈ Ú
=
yyÛ Ù
file
yyı ˘
.
yy˘ ˙
Length
yy˙ Ä
,
yyÄ Å
Content
yyÇ â
=
yyä ã
stream
yyå í
.
yyí ì
ToArray
yyì ö
(
yyö õ
)
yyõ ú
}
yyù û
)
yyû ü
;
yyü †
}zz 	
await{{ 
db{{ 
.{{ 
SaveChangesAsync{{ !
({{! "
ct{{" $
){{$ %
;{{% &
jobs|| 
.|| 
Enqueue|| 
<|| 
GitHubIssueSyncJob|| '
>||' (
(||( )
j||) *
=>||+ -
j||. /
.||/ 0
CreateIssueAsync||0 @
(||@ A
ticket||A G
.||G H
Id||H J
,||J K
CancellationToken||L ]
.||] ^
None||^ b
)||b c
)||c d
;||d e
if}} 

(}} 
project}} 
.}} 
Repositories}}  
.}}  !
Count}}! &
==}}' )
$num}}* +
)}}+ ,
await}}- 2#
NotifyPortalTicketAsync}}3 J
(}}J K
ticket}}K Q
,}}Q R
project}}S Z
,}}Z [
ct}}\ ^
)}}^ _
;}}_ `
await~~ 
NotifyManagerAsync~~  
(~~  !
ticket~~! '
,~~' (
project~~) 0
,~~0 1
ct~~2 4
)~~4 5
;~~5 6
return 
Created 
( 
$" 
$str &
{& '
ticket' -
.- .
Id. 0
}0 1
"1 2
,2 3
ticket4 :
): ;
;; <
}
ÄÄ 
[
ÖÖ 
HttpGet
ÖÖ 
(
ÖÖ 
$str
ÖÖ 
)
ÖÖ 
]
ÖÖ 
public
ÜÜ 

async
ÜÜ 
Task
ÜÜ 
<
ÜÜ 
IActionResult
ÜÜ #
>
ÜÜ# $
Notifications
ÜÜ% 2
(
ÜÜ2 3
Guid
ÜÜ3 7
?
ÜÜ7 8
clientId
ÜÜ9 A
,
ÜÜA B
CancellationToken
ÜÜC T
ct
ÜÜU W
)
ÜÜW X
{
áá 
var
àà 
query
àà 
=
àà 
db
àà 
.
àà !
PortalNotifications
àà *
.
àà* +
AsQueryable
àà+ 6
(
àà6 7
)
àà7 8
;
àà8 9
if
ââ 

(
ââ 
!
ââ 
(
ââ 
IsSuperAdmin
ââ 
&&
ââ 
clientId
ââ &
is
ââ' )
null
ââ* .
)
ââ. /
)
ââ/ 0
{
ää 	
var
ãã 
error
ãã 
=
ãã 
ResolveClientId
ãã '
(
ãã' (
clientId
ãã( 0
,
ãã0 1
out
ãã2 5
var
ãã6 9
id
ãã: <
)
ãã< =
;
ãã= >
if
ãã? A
(
ããB C
error
ããC H
is
ããI K
not
ããL O
null
ããP T
)
ããT U
return
ããV \
error
ãã] b
;
ããb c
query
åå 
=
åå 
query
åå 
.
åå 
Where
åå 
(
åå  
x
åå  !
=>
åå" $
x
åå% &
.
åå& '
ClientId
åå' /
==
åå0 2
id
åå3 5
&&
åå6 8
!
åå9 :
x
åå: ;
.
åå; <
ForStaff
åå< D
)
ååD E
;
ååE F
}
çç 	
var
éé 
seenAt
éé 
=
éé 
await
éé 
db
éé 
.
éé 
UserAccounts
éé *
.
éé* +
Where
éé+ 0
(
éé0 1
x
éé1 2
=>
éé3 5
x
éé6 7
.
éé7 8
Id
éé8 :
==
éé; =
UserId
éé> D
)
ééD E
.
ééE F
Select
ééF L
(
ééL M
x
ééM N
=>
ééO Q
x
ééR S
.
ééS T!
NotificationsSeenAt
ééT g
)
éég h
.
ééh i"
SingleOrDefaultAsync
ééi }
(
éé} ~
ctéé~ Ä
)ééÄ Å
;ééÅ Ç
var
èè 
unread
èè 
=
èè 
await
èè 
query
èè  
.
èè  !

CountAsync
èè! +
(
èè+ ,
x
èè, -
=>
èè. 0
seenAt
èè1 7
==
èè8 :
null
èè; ?
||
èè@ B
x
èèC D
.
èèD E
	CreatedAt
èèE N
>
èèO P
seenAt
èèQ W
,
èèW X
ct
èèY [
)
èè[ \
;
èè\ ]
var
êê 
rows
êê 
=
êê 
await
êê 
query
êê 
.
êê 
OrderByDescending
êê 0
(
êê0 1
x
êê1 2
=>
êê3 5
x
êê6 7
.
êê7 8
	CreatedAt
êê8 A
)
êêA B
.
êêB C
Take
êêC G
(
êêG H
$num
êêH J
)
êêJ K
.
ëë 
Select
ëë 
(
ëë 
x
ëë 
=>
ëë 
new
ëë 
{
ëë 
x
ëë  
.
ëë  !
Id
ëë! #
,
ëë# $
x
ëë% &
.
ëë& '
ClientId
ëë' /
,
ëë/ 0
x
ëë1 2
.
ëë2 3
Type
ëë3 7
,
ëë7 8
x
ëë9 :
.
ëë: ;
ForStaff
ëë; C
,
ëëC D
x
ëëE F
.
ëëF G
DataJson
ëëG O
,
ëëO P
x
ëëQ R
.
ëëR S
	CreatedAt
ëëS \
,
ëë\ ]
Company
ëë^ e
=
ëëf g
db
ëëh j
.
ëëj k
Clients
ëëk r
.
ëër s
Where
ëës x
(
ëëx y
c
ëëy z
=>
ëë{ }
c
ëë~ 
.ëë Ä
IdëëÄ Ç
==ëëÉ Ö
xëëÜ á
.ëëá à
ClientIdëëà ê
)ëëê ë
.ëëë í
Selectëëí ò
(ëëò ô
cëëô ö
=>ëëõ ù
cëëû ü
.ëëü †
CompanyNameëë† ´
)ëë´ ¨
.ëë¨ ≠
FirstOrDefaultëë≠ ª
(ëëª º
)ëëº Ω
}ëëæ ø
)ëëø ¿
.
íí 
ToListAsync
íí 
(
íí 
ct
íí 
)
íí 
;
íí 
var
ìì 
items
ìì 
=
ìì 
rows
ìì 
.
ìì 
Select
ìì 
(
ìì  
x
ìì  !
=>
ìì" $
new
ìì% (
{
ìì) *
id
ìì+ -
=
ìì. /
x
ìì0 1
.
ìì1 2
Id
ìì2 4
,
ìì4 5
clientId
ìì6 >
=
ìì? @
x
ììA B
.
ììB C
ClientId
ììC K
,
ììK L
company
ììM T
=
ììU V
x
ììW X
.
ììX Y
Company
ììY `
,
ìì` a
type
ììb f
=
ììg h
x
ììi j
.
ììj k
Type
ììk o
,
ììo p
forStaff
ììq y
=
ììz {
x
ìì| }
.
ìì} ~
ForStaffìì~ Ü
,ììÜ á
	createdAtììà ë
=ììí ì
xììî ï
.ììï ñ
	CreatedAtììñ ü
,ììü †
unreadìì° ß
=ìì® ©
seenAtìì™ ∞
==ìì± ≥
nullìì¥ ∏
||ììπ ª
xììº Ω
.ììΩ æ
	CreatedAtììæ «
>ìì» …
seenAtìì  –
,ìì– —
dataìì“ ÷
=ìì◊ ÿ
JsonSerializerììŸ Á
.ììÁ Ë
DeserializeììË Û
<ììÛ Ù

DictionaryììÙ ˛
<ìì˛ ˇ
stringììˇ Ö
,ììÖ Ü
stringììá ç
>ììç é
>ììé è
(ììè ê
xììê ë
.ììë í
DataJsonììí ö
)ììö õ
??ììú û
[ììü †
]ìì† °
}ìì¢ £
)ìì£ §
;ìì§ •
return
îî 
Ok
îî 
(
îî 
new
îî 
{
îî 
items
îî 
,
îî 
unread
îî %
}
îî& '
)
îî' (
;
îî( )
}
ïï 
[
óó 
HttpPost
óó 
(
óó 
$str
óó "
)
óó" #
]
óó# $
public
òò 

async
òò 
Task
òò 
<
òò 
IActionResult
òò #
>
òò# $
NotificationsSeen
òò% 6
(
òò6 7
CancellationToken
òò7 H
ct
òòI K
)
òòK L
{
ôô 
var
öö 
user
öö 
=
öö 
await
öö 
db
öö 
.
öö 
UserAccounts
öö (
.
öö( )"
SingleOrDefaultAsync
öö) =
(
öö= >
x
öö> ?
=>
öö@ B
x
ööC D
.
ööD E
Id
ööE G
==
ööH J
UserId
ööK Q
,
ööQ R
ct
ööS U
)
ööU V
;
ööV W
if
ööX Z
(
öö[ \
user
öö\ `
is
ööa c
null
ööd h
)
ööh i
return
ööj p
NotFound
ööq y
(
ööy z
)
ööz {
;
öö{ |
user
õõ 
.
õõ !
NotificationsSeenAt
õõ  
=
õõ! "
DateTime
õõ# +
.
õõ+ ,
UtcNow
õõ, 2
;
õõ2 3
await
õõ4 9
db
õõ: <
.
õõ< =
SaveChangesAsync
õõ= M
(
õõM N
ct
õõN P
)
õõP Q
;
õõQ R
return
õõS Y
	NoContent
õõZ c
(
õõc d
)
õõd e
;
õõe f
}
úú 
private
ûû 
async
ûû 
Task
ûû %
NotifyPortalTicketAsync
ûû .
(
ûû. /
Ticket
ûû/ 5
ticket
ûû6 <
,
ûû< =
Project
ûû> E
project
ûûF M
,
ûûM N
CancellationToken
ûûO `
ct
ûûa c
)
ûûc d
{
üü 
var
†† 

staffEmail
†† 
=
†† 
configuration
†† &
[
††& '
$str
††' A
]
††A B
is
††C E
{
††F G
Length
††H N
:
††N O
>
††P Q
$num
††R S
}
††T U

configured
††V `
?
††a b

configured
††c m
:
††n o
configuration
††p }
[
††} ~
$str††~ â
]††â ä
;††ä ã
if
°° 

(
°° 
string
°° 
.
°°  
IsNullOrWhiteSpace
°° %
(
°°% &

staffEmail
°°& 0
)
°°0 1
)
°°1 2
{
°°3 4
logger
°°5 ;
.
°°; <

LogWarning
°°< F
(
°°F G
$str°°G à
,°°à â
ticket°°ä ê
.°°ê ë
Code°°ë ï
)°°ï ñ
;°°ñ ó
return°°ò û
;°°û ü
}°°† °
var
¢¢ 
client
¢¢ 
=
¢¢ 
await
¢¢ 
db
¢¢ 
.
¢¢ 
Clients
¢¢ %
.
¢¢% &
SingleAsync
¢¢& 1
(
¢¢1 2
x
¢¢2 3
=>
¢¢4 6
x
¢¢7 8
.
¢¢8 9
Id
¢¢9 ;
==
¢¢< >
ticket
¢¢? E
.
¢¢E F
ClientId
¢¢F N
,
¢¢N O
ct
¢¢P R
)
¢¢R S
;
¢¢S T
await
££ 
notifications
££ 
.
££ 
	SendAsync
££ %
(
££% &
client
££& ,
,
££, -
new
££. 1
Notification
££2 >
(
££> ?
NotificationType
££? O
.
££O P
TicketCreated
££P ]
,
££] ^
new
££_ b
(
££b c
)
££c d
{
££e f
[
££g h
$str
££h r
]
££r s
=
££t u
ticket
££v |
.
££| }
Id
££} 
.££ Ä
ToString££Ä à
(££à â
)££â ä
,££ä ã
[££å ç
$str££ç ì
]££ì î
=££ï ñ
ticket££ó ù
.££ù û
Code££û ¢
,££¢ £
[££§ •
$str££• ¨
]££¨ ≠
=££Æ Ø
ticket££∞ ∂
.££∂ ∑
Title££∑ º
,££º Ω
[££æ ø
$str££ø »
]££» …
=££  À
client££Ã “
.££“ ”
CompanyName££” ﬁ
,££ﬁ ﬂ
[££‡ ·
$str££· Í
]££Í Î
=££Ï Ì
project££Ó ı
.££ı ˆ
Name££ˆ ˙
,££˙ ˚
[££¸ ˝
$str££˝ É
]££É Ñ
=££Ö Ü
ticket££á ç
.££ç é
Description££é ô
}££ö õ
,££õ ú
$"££ù ü
$str££ü Æ
{££Æ Ø
ticket££Ø µ
.££µ ∂
Id££∂ ∏
}££∏ π
"££π ∫
,££∫ ª

staffEmail££º ∆
)££∆ «
,££« »
ct££… À
)££À Ã
;££Ã Õ
}
§§ 
private
ßß 
async
ßß 
Task
ßß  
NotifyManagerAsync
ßß )
(
ßß) *
Ticket
ßß* 0
ticket
ßß1 7
,
ßß7 8
Project
ßß9 @
project
ßßA H
,
ßßH I
CancellationToken
ßßJ [
ct
ßß\ ^
)
ßß^ _
{
®® 
var
©© 
creator
©© 
=
©© 
await
©© 
db
©© 
.
©© 
UserAccounts
©© +
.
©©+ ,
AsNoTracking
©©, 8
(
©©8 9
)
©©9 :
.
©©: ;"
SingleOrDefaultAsync
©©; O
(
©©O P
x
©©P Q
=>
©©R T
x
©©U V
.
©©V W
Id
©©W Y
==
©©Z \
ticket
©©] c
.
©©c d
CreatedByUserId
©©d s
&&
©©t v
x
©©w x
.
©©x y
ClientId©©y Å
==©©Ç Ñ
ticket©©Ö ã
.©©ã å
ClientId©©å î
,©©î ï
ct©©ñ ò
)©©ò ô
;©©ô ö
if
™™ 

(
™™ 
creator
™™ 
?
™™ 
.
™™ 
	ManagerId
™™ 
is
™™ !
not
™™" %
Guid
™™& *
	managerId
™™+ 4
)
™™4 5
return
™™6 <
;
™™< =
var
´´ 
manager
´´ 
=
´´ 
await
´´ 
db
´´ 
.
´´ 
UserAccounts
´´ +
.
´´+ ,
AsNoTracking
´´, 8
(
´´8 9
)
´´9 :
.
´´: ;"
SingleOrDefaultAsync
´´; O
(
´´O P
x
´´P Q
=>
´´R T
x
´´U V
.
´´V W
Id
´´W Y
==
´´Z \
	managerId
´´] f
&&
´´g i
x
´´j k
.
´´k l
ClientId
´´l t
==
´´u w
ticket
´´x ~
.
´´~ 
ClientId´´ á
&&´´à ä
x´´ã å
.´´å ç
IsActive´´ç ï
,´´ï ñ
ct´´ó ô
)´´ô ö
;´´ö õ
if
¨¨ 

(
¨¨ 
manager
¨¨ 
is
¨¨ 
null
¨¨ 
||
¨¨ 
string
¨¨ %
.
¨¨% & 
IsNullOrWhiteSpace
¨¨& 8
(
¨¨8 9
manager
¨¨9 @
.
¨¨@ A
Email
¨¨A F
)
¨¨F G
)
¨¨G H
return
¨¨I O
;
¨¨O P
var
≠≠ 
client
≠≠ 
=
≠≠ 
await
≠≠ 
db
≠≠ 
.
≠≠ 
Clients
≠≠ %
.
≠≠% &
SingleAsync
≠≠& 1
(
≠≠1 2
x
≠≠2 3
=>
≠≠4 6
x
≠≠7 8
.
≠≠8 9
Id
≠≠9 ;
==
≠≠< >
ticket
≠≠? E
.
≠≠E F
ClientId
≠≠F N
,
≠≠N O
ct
≠≠P R
)
≠≠R S
;
≠≠S T
var
ÆÆ 
data
ÆÆ 
=
ÆÆ 
new
ÆÆ 

Dictionary
ÆÆ !
<
ÆÆ! "
string
ÆÆ" (
,
ÆÆ( )
string
ÆÆ* 0
>
ÆÆ0 1
{
ÆÆ2 3
[
ÆÆ4 5
$str
ÆÆ5 ?
]
ÆÆ? @
=
ÆÆA B
ticket
ÆÆC I
.
ÆÆI J
Id
ÆÆJ L
.
ÆÆL M
ToString
ÆÆM U
(
ÆÆU V
)
ÆÆV W
,
ÆÆW X
[
ÆÆY Z
$str
ÆÆZ `
]
ÆÆ` a
=
ÆÆb c
ticket
ÆÆd j
.
ÆÆj k
Code
ÆÆk o
,
ÆÆo p
[
ÆÆq r
$str
ÆÆr y
]
ÆÆy z
=
ÆÆ{ |
ticketÆÆ} É
.ÆÆÉ Ñ
TitleÆÆÑ â
,ÆÆâ ä
[ÆÆã å
$strÆÆå ï
]ÆÆï ñ
=ÆÆó ò
projectÆÆô †
.ÆÆ† °
NameÆÆ° •
,ÆÆ• ¶
[ÆÆß ®
$strÆÆ® ±
]ÆÆ± ≤
=ÆÆ≥ ¥
creatorÆÆµ º
.ÆÆº Ω
NameÆÆΩ ¡
}ÆÆ¬ √
;ÆÆ√ ƒ
if
ØØ 

(
ØØ 
!
ØØ 
string
ØØ 
.
ØØ  
IsNullOrWhiteSpace
ØØ &
(
ØØ& '
creator
ØØ' .
.
ØØ. /
Area
ØØ/ 3
)
ØØ3 4
)
ØØ4 5
data
ØØ6 :
[
ØØ: ;
$str
ØØ; A
]
ØØA B
=
ØØC D
creator
ØØE L
.
ØØL M
Area
ØØM Q
;
ØØQ R
await
∞∞ 
notifications
∞∞ 
.
∞∞ 
	SendAsync
∞∞ %
(
∞∞% &
client
∞∞& ,
,
∞∞, -
new
∞∞. 1
Notification
∞∞2 >
(
∞∞> ?
NotificationType
∞∞? O
.
∞∞O P%
TicketCreatedForManager
∞∞P g
,
∞∞g h
data
∞∞i m
,
∞∞m n
$"
∞∞o q
$str∞∞q Ä
{∞∞Ä Å
ticket∞∞Å á
.∞∞á à
Id∞∞à ä
}∞∞ä ã
"∞∞ã å
,∞∞å ç
manager∞∞é ï
.∞∞ï ñ
Email∞∞ñ õ
)∞∞õ ú
,∞∞ú ù
ct∞∞û †
)∞∞† °
;∞∞° ¢
}
±± 
}≤≤ „À
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PaymentsController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str 
) 
] 
public 
sealed 
class 
PaymentsController &
(& '
RtresDbContext' 5
db6 8
,8 9
IPayPalClient: G
payPalH N
,N O!
PayPalCheckoutServiceP e
checkoutServicef u
,u v!
PayPalPaymentService	w ã
payments
å î
,
î ï!
BankTransferService
ñ ©
	transfers
™ ≥
,
≥ ¥!
INotificationSender
µ »
notifications
… ÷
,
÷ ◊
IConfiguration
ÿ Ê
configuration
Á Ù
,
Ù ı
ILogger
ˆ ˝
<
˝ ˛ 
PaymentsController
˛ ê
>
ê ë
logger
í ò
)
ò ô
:
ö õ
ControllerBase
ú ™
{ 
public 

const 
int 
RenewalWindowDays &
=' (
$num) +
;+ ,
private 
IActionResult 
? 
ClientScope &
(& '
Guid' +
?+ ,
	requested- 6
,6 7
out8 ;
Guid< @
clientIdA I
)I J
{ 
clientId 
= 
Guid 
. 
Empty 
; 
if 

( 
User 
. 
IsInRole 
( 
nameof  
(  !
UserRole! )
.) *

SuperAdmin* 4
)4 5
)5 6
)6 7
{8 9
if: <
(= >
	requested> G
isH J
notK N
GuidO S
valueT Y
)Y Z
return[ a

BadRequestb l
(l m
newm p
{q r
messages z
={ |
$str	} ß
}
® ©
)
© ™
;
™ ´
clientId
¨ ¥
=
µ ∂
value
∑ º
;
º Ω
return
æ ƒ
null
≈ …
;
…  
}
À Ã
return 
Guid 
. 
TryParse 
( 
User !
.! "
FindFirstValue" 0
(0 1
$str1 <
)< =
,= >
out? B
clientIdC K
)K L
?M N
nullO S
:T U
ForbidV \
(\ ]
)] ^
;^ _
} 
[ 
	Authorize 
, 
HttpGet 
( 
$str *
)* +
]+ ,
public 

async 
Task 
< 
IActionResult #
># $
Catalog% ,
(, -
CancellationToken- >
ct? A
)A B
{ 
var 
client 
= 
Guid 
. 
TryParse "
(" #
User# '
.' (
FindFirstValue( 6
(6 7
$str7 B
)B C
,C D
outE H
varI L
clientIdM U
)U V
?W X
awaitY ^
db_ a
.a b
Clientsb i
.i j 
SingleOrDefaultAsyncj ~
(~ 
x	 Ä
=>
Å É
x
Ñ Ö
.
Ö Ü
Id
Ü à
==
â ã
clientId
å î
,
î ï
ct
ñ ò
)
ò ô
:
ö õ
null
ú †
;
† °
var   
igvRate   
=   
await   
db   
.   
IgvRateAsync   +
(  + ,
ct  , .
)  . /
;  / 0
var!! 
products!! 
=!! 
await!! 
db!! 
.!!  
Products!!  (
.!!( )
Where!!) .
(!!. /
x!!/ 0
=>!!1 3
x!!4 5
.!!5 6
IsActive!!6 >
)!!> ?
.!!? @
OrderBy!!@ G
(!!G H
x!!H I
=>!!J L
x!!M N
.!!N O
Name!!O S
)!!S T
.!!T U
ToListAsync!!U `
(!!` a
ct!!a c
)!!c d
;!!d e
return"" 
Ok"" 
("" 
products"" 
."" 
Select"" !
(""! "
x""" #
=>""$ &
new""' *
{""+ ,
id""- /
=""0 1
x""2 3
.""3 4
Id""4 6
,""6 7
type""8 <
=""= >
x""? @
.""@ A
Type""A E
,""E F
name""G K
=""L M
x""N O
.""O P
Name""P T
,""T U
billingCycle""V b
=""c d
x""e f
.""f g
BillingCycle""g s
,""s t
	basePrice""u ~
=	"" Ä
x
""Å Ç
.
""Ç É
	BasePrice
""É å
,
""å ç
currency
""é ñ
=
""ó ò
x
""ô ö
.
""ö õ
Currency
""õ £
,
""£ §
description
""• ∞
=
""± ≤
x
""≥ ¥
.
""¥ µ
Description
""µ ¿
,
""¿ ¡
category
""¬  
=
""À Ã
x
""Õ Œ
.
""Œ œ
Category
""œ ◊
,
""◊ ÿ
tags
""Ÿ ›
=
""ﬁ ﬂ
x
""‡ ·
.
""· ‚
Tags
""‚ Ê
,
""Ê Á
allowsTickets
""Ë ı
=
""ˆ ˜
x
""¯ ˘
.
""˘ ˙
AllowsTickets
""˙ á
,
""á à
isActive
""â ë
=
""í ì
x
""î ï
.
""ï ñ
IsActive
""ñ û
,
""û ü
igvRate
""† ß
=
""® ©
client
""™ ∞
is
""± ≥
null
""¥ ∏
?
""π ∫
$num
""ª Ω
:
""æ ø"
ClientProductPricing
""¿ ‘
.
""‘ ’

IgvRateFor
""’ ﬂ
(
""ﬂ ‡
client
""‡ Ê
,
""Ê Á
x
""Ë È
,
""È Í
igvRate
""Î Ú
)
""Ú Û
}
""Ù ı
)
""ı ˆ
)
""ˆ ˜
;
""˜ ¯
}## 
[%% 
	Authorize%% 
(%% 
Roles%% 
=%% 
$str%% &
)%%& '
,%%' (
HttpPost%%) 1
(%%1 2
$str%%2 A
)%%A B
]%%B C
public&& 

async&& 
Task&& 
<&& 
IActionResult&& #
>&&# $
	Subscribe&&% .
(&&. /
SubscribeRequest&&/ ?
request&&@ G
,&&G H
CancellationToken&&I Z
ct&&[ ]
)&&] ^
{'' 
var(( 
scope(( 
=(( 
ClientScope(( 
(((  
null((  $
,(($ %
out((& )
var((* -
clientId((. 6
)((6 7
;((7 8
if((9 ;
(((< =
scope((= B
is((C E
not((F I
null((J N
)((N O
return((P V
scope((W \
;((\ ]
var)) 
product)) 
=)) 
await)) 
db)) 
.)) 
Products)) '
.))' ( 
SingleOrDefaultAsync))( <
())< =
x))= >
=>))? A
x))B C
.))C D
Id))D F
==))G I
request))J Q
.))Q R
	ProductId))R [
&&))\ ^
x))_ `
.))` a
IsActive))a i
,))i j
ct))k m
)))m n
;))n o
if** 

(** 
product** 
is** 
null** 
)** 
return** #
NotFound**$ ,
(**, -
)**- .
;**. /
var++ 
	projectId++ 
=++ 
request++ 
.++  
	ProjectId++  )
;++) *
if,, 

(,, 
	projectId,, 
is,, 
null,, 
),, 
	projectId,, (
=,,) *
(,,+ ,
await,,, 1
NewProjectAsync,,2 A
(,,A B
clientId,,B J
,,,J K
product,,L S
.,,S T
Name,,T X
,,,X Y
ct,,Z \
),,\ ]
),,] ^
.,,^ _
Id,,_ a
;,,a b
else-- 
if-- 
(-- 
!-- 
await-- 
db-- 
.-- 
Projects-- #
.--# $
AnyAsync--$ ,
(--, -
x--- .
=>--/ 1
x--2 3
.--3 4
Id--4 6
==--7 9
	projectId--: C
&&--D F
x--G H
.--H I
ClientId--I Q
==--R T
clientId--U ]
,--] ^
ct--_ a
)--a b
)--b c
return--d j
NotFound--k s
(--s t
)--t u
;--u v
if.. 

(.. 
request.. 
... 
BillingCycle..  
!=..! #
product..$ +
...+ ,
BillingCycle.., 8
)..8 9
return..: @

BadRequest..A K
(..K L
new..L O
{..P Q
message..R Y
=..Z [
$str	..\ ì
}
..î ï
)
..ï ñ
;
..ñ ó
if// 

(// 
await// #
PaymentMethodErrorAsync// )
(//) *
request//* 1
.//1 2
PaymentMethod//2 ?
,//? @
ct//A C
)//C D
is//E G
string//H N
methodError//O Z
)//Z [
return//\ b

BadRequest//c m
(//m n
new//n q
{//r s
message//t {
=//| }
methodError	//~ â
}
//ä ã
)
//ã å
;
//å ç
var00 
transfer00 
=00 
request00 
.00 
PaymentMethod00 ,
==00- /
PaymentMethods000 >
.00> ?
Transferencia00? L
;00L M
var11 
item11 
=11 
new11 
ClientProduct11 $
{11% &
ClientId11' /
=110 1
clientId112 :
,11: ;
	ProjectId11< E
=11F G
	projectId11H Q
.11Q R
Value11R W
,11W X
	ProductId11Y b
=11c d
product11e l
.11l m
Id11m o
,11o p
Product11q x
=11y z
product	11{ Ç
,
11Ç É
BillingCycle
11Ñ ê
=
11ë í
request
11ì ö
.
11ö õ
BillingCycle
11õ ß
,
11ß ®
Status
11© Ø
=
11∞ ±!
ClientProductStatus
11≤ ≈
.
11≈ ∆
	Pendiente
11∆ œ
,
11œ –
Price
11— ÷
=
11◊ ÿ
product
11Ÿ ‡
.
11‡ ·
	BasePrice
11· Í
,
11Í Î
IsManualBilling
11Ï ˚
=
11¸ ˝
transfer
11˛ Ü
}
11á à
;
11à â
if22 

(22 
item22 
.22 
ValidateYears22 
(22 
request22 &
.22& '
Years22' ,
)22, -
is22. 0
string221 7

yearsError228 B
)22B C
return22D J

BadRequest22K U
(22U V
new22V Y
{22Z [
message22\ c
=22d e

yearsError22f p
}22q r
)22r s
;22s t
db33 

.33
 
ClientProducts33 
.33 
Add33 
(33 
item33 "
)33" #
;33# $
var44 
igvRate44 
=44 
await44 
db44 
.44 
IgvRateForAsync44 .
(44. /
clientId44/ 7
,447 8
product449 @
,44@ A
ct44B D
)44D E
;44E F
if66 

(66 
transfer66 
)66 
{77 	
await88 
db88 
.88 
SaveChangesAsync88 %
(88% &
ct88& (
)88( )
;88) *
await99 &
NotifyTransferRequestAsync99 ,
(99, -
item99- 1
,991 2
product993 :
,99: ;
igvRate99< C
,99C D
request99E L
.99L M
Years99M R
,99R S
ct99T V
)99V W
;99W X
return:: 
Ok:: 
(:: 
new:: 
{:: 
clientProductId:: +
=::, -
item::. 2
.::2 3
Id::3 5
,::5 6
approvalUrl::7 B
=::C D
(::E F
string::F L
?::L M
)::M N
null::N R
,::R S
bankTransfer::T `
=::a b
await::c h
	transfers::i r
.::r s
	InfoAsync::s |
(::| }
item	::} Å
,
::Å Ç
igvRate
::É ä
,
::ä ã
request
::å ì
.
::ì î
Years
::î ô
,
::ô ö
ct
::õ ù
)
::ù û
}
::ü †
)
::† °
;
::° ¢
};; 	
try<< 
{<< 
var<< 
checkout<< 
=<< 
await<< "
checkoutService<<# 2
.<<2 3

StartAsync<<3 =
(<<= >
item<<> B
,<<B C
product<<D K
,<<K L
Request<<M T
,<<T U
ct<<V X
,<<X Y
igvRate<<Z a
,<<a b
request<<c j
.<<j k
Years<<k p
)<<p q
;<<q r
await<<s x
db<<y {
.<<{ |
SaveChangesAsync	<<| å
(
<<å ç
ct
<<ç è
)
<<è ê
;
<<ê ë
return
<<í ò
Ok
<<ô õ
(
<<õ ú
new
<<ú ü
{
<<† °
clientProductId
<<¢ ±
=
<<≤ ≥
item
<<¥ ∏
.
<<∏ π
Id
<<π ª
,
<<ª º
approvalUrl
<<Ω »
=
<<…  
checkout
<<À ”
.
<<” ‘
ApprovalUrl
<<‘ ﬂ
}
<<‡ ·
)
<<· ‚
;
<<‚ „
}
<<‰ Â
catch
<<Ê Î
(
<<Ï Ì'
InvalidOperationException
<<Ì Ü
ex
<<á â
)
<<â ä
{
<<ã å
return
<<ç ì

BadRequest
<<î û
(
<<û ü
new
<<ü ¢
{
<<£ §
message
<<• ¨
=
<<≠ Æ
ex
<<Ø ±
.
<<± ≤
Message
<<≤ π
}
<<∫ ª
)
<<ª º
;
<<º Ω
}
<<æ ø
}== 
private@@ 
async@@ 
Task@@ 
<@@ 
string@@ 
?@@ 
>@@ #
PaymentMethodErrorAsync@@  7
(@@7 8
string@@8 >
method@@? E
,@@E F
CancellationToken@@G X
ct@@Y [
)@@[ \
{AA 
ifBB 

(BB 
methodBB 
isBB 
notBB 
(BB 
PaymentMethodsBB )
.BB) *
PayPalBB* 0
orBB1 3
PaymentMethodsBB4 B
.BBB C
TransferenciaBBC P
)BBP Q
)BBQ R
returnBBS Y
$strBBZ t
;BBt u
varCC 
settingsCC 
=CC 
awaitCC 
	transfersCC &
.CC& '
SettingsAsyncCC' 4
(CC4 5
ctCC5 7
)CC7 8
;CC8 9
ifDD 

(DD 
methodDD 
==DD 
PaymentMethodsDD $
.DD$ %
TransferenciaDD% 2
)DD2 3
returnDD4 :
settingsDD; C
.DDC D
BankTransferEnabledDDD W
?DDX Y
nullDDZ ^
:DD_ `
$str	DDa ö
;
DDö õ
returnEE 
settingsEE 
.EE 
PayPalEnabledEE %
?EE& '
nullEE( ,
:EE- .
$strEE/ a
;EEa b
}FF 
privateLL 
asyncLL 
TaskLL 
<LL 
ProjectLL 
>LL 
NewProjectAsyncLL  /
(LL/ 0
GuidLL0 4
clientIdLL5 =
,LL= >
stringLL? E
productNameLLF Q
,LLQ R
CancellationTokenLLS d
ctLLe g
)LLg h
{MM 
varNN 
companyNN 
=NN 
awaitNN 
dbNN 
.NN 
ClientsNN &
.NN& '
WhereNN' ,
(NN, -
xNN- .
=>NN/ 1
xNN2 3
.NN3 4
IdNN4 6
==NN7 9
clientIdNN: B
)NNB C
.NNC D
SelectNND J
(NNJ K
xNNK L
=>NNM O
xNNP Q
.NNQ R
CompanyNameNNR ]
)NN] ^
.NN^ _
SingleAsyncNN_ j
(NNj k
ctNNk m
)NNm n
;NNn o
varOO 
baseSlugOO 
=OO 
AdminControllerOO &
.OO& '
SlugifyOO' .
(OO. /
$"OO/ 1
{OO1 2
companyOO2 9
}OO9 :
$strOO: ;
{OO; <
productNameOO< G
}OOG H
"OOH I
)OOI J
;OOJ K
ifPP 

(PP 
baseSlugPP 
.PP 
LengthPP 
==PP 
$numPP  
)PP  !
baseSlugPP" *
=PP+ ,
$strPP- 7
;PP7 8
varQQ 
slugQQ 
=QQ 
baseSlugQQ 
;QQ 
varRR 
nRR 
=RR 
$numRR 
;RR 
whileSS 
(SS 
awaitSS 
dbSS 
.SS 
ProjectsSS  
.SS  !
AnyAsyncSS! )
(SS) *
xSS* +
=>SS, .
xSS/ 0
.SS0 1
SlugSS1 5
==SS6 8
slugSS9 =
,SS= >
ctSS? A
)SSA B
)SSB C
slugSSD H
=SSI J
$"SSK M
{SSM N
baseSlugSSN V
}SSV W
$strSSW X
{SSX Y
nSSY Z
++SSZ \
}SS\ ]
"SS] ^
;SS^ _
varTT 
projectTT 
=TT 
newTT 
ProjectTT !
{TT" #
ClientIdTT$ ,
=TT- .
clientIdTT/ 7
,TT7 8
NameTT9 =
=TT> ?
productNameTT@ K
,TTK L
SlugTTM Q
=TTR S
slugTTT X
}TTY Z
;TTZ [
dbUU 

.UU
 
ProjectsUU 
.UU 
AddUU 
(UU 
projectUU 
)UU  
;UU  !
returnVV 
projectVV 
;VV 
}WW 
[ZZ 
	AuthorizeZZ 
,ZZ 
HttpGetZZ 
(ZZ 
$strZZ A
)ZZA B
]ZZB C
public[[ 

async[[ 
Task[[ 
<[[ 
IActionResult[[ #
>[[# $
BankTransfer[[% 1
([[1 2
Guid[[2 6
id[[7 9
,[[9 :
Guid[[; ?
?[[? @
clientId[[A I
,[[I J
CancellationToken[[K \
ct[[] _
,[[_ `
int[[a d
years[[e j
=[[k l
$num[[m n
)[[n o
{\\ 
var]] 
scope]] 
=]] 
ClientScope]] 
(]]  
clientId]]  (
,]]( )
out]]* -
var]]. 1
owner]]2 7
)]]7 8
;]]8 9
if]]: <
(]]= >
scope]]> C
is]]D F
not]]G J
null]]K O
)]]O P
return]]Q W
scope]]X ]
;]]] ^
var^^ 
item^^ 
=^^ 
await^^ 
db^^ 
.^^ 
ClientProducts^^ *
.^^* +
Include^^+ 2
(^^2 3
x^^3 4
=>^^5 7
x^^8 9
.^^9 :
Product^^: A
)^^A B
.^^B C 
SingleOrDefaultAsync^^C W
(^^W X
x^^X Y
=>^^Z \
x^^] ^
.^^^ _
Id^^_ a
==^^b d
id^^e g
&&^^h j
x^^k l
.^^l m
ClientId^^m u
==^^v x
owner^^y ~
,^^~ 
ct
^^Ä Ç
)
^^Ç É
;
^^É Ñ
if__ 

(__ 
item__ 
?__ 
.__ 
Product__ 
is__ 
null__ !
)__! "
return__# )
NotFound__* 2
(__2 3
)__3 4
;__4 5
if`` 

(`` 
item`` 
.`` 
ValidateYears`` 
(`` 
years`` $
)``$ %
is``& (
string``) /

yearsError``0 :
)``: ;
return``< B

BadRequest``C M
(``M N
new``N Q
{``R S
message``T [
=``\ ]

yearsError``^ h
}``i j
)``j k
;``k l
returnaa 
Okaa 
(aa 
awaitaa 
	transfersaa !
.aa! "
	InfoAsyncaa" +
(aa+ ,
itemaa, 0
,aa0 1
awaitaa2 7
dbaa8 :
.aa: ;
IgvRateForAsyncaa; J
(aaJ K
owneraaK P
,aaP Q
itemaaR V
.aaV W
ProductaaW ^
,aa^ _
ctaa` b
)aab c
,aac d
yearsaae j
,aaj k
ctaal n
)aan o
)aao p
;aap q
}bb 
privatehh 
asynchh 
Taskhh &
NotifyTransferRequestAsynchh 1
(hh1 2
ClientProducthh2 ?
itemhh@ D
,hhD E
ProducthhF M
producthhN U
,hhU V
decimalhhW ^
igvRatehh_ f
,hhf g
inthhh k
yearshhl q
,hhq r
CancellationToken	hhs Ñ
ct
hhÖ á
)
hhá à
{ii 
varjj 

staffEmailjj 
=jj 
configurationjj &
[jj& '
$strjj' A
]jjA B
isjjC E
{jjF G
LengthjjH N
:jjN O
>jjP Q
$numjjR S
}jjT U

configuredjjV `
?jja b

configuredjjc m
:jjn o
configurationjjp }
[jj} ~
$str	jj~ â
]
jjâ ä
;
jjä ã
ifkk 

(kk 
stringkk 
.kk 
IsNullOrWhiteSpacekk %
(kk% &

staffEmailkk& 0
)kk0 1
)kk1 2
{kk3 4
loggerkk5 ;
.kk; <

LogWarningkk< F
(kkF G
$str	kkG ù
,
kkù û
item
kkü £
.
kk£ §
Id
kk§ ¶
)
kk¶ ß
;
kkß ®
return
kk© Ø
;
kkØ ∞
}
kk± ≤
varll 
clientll 
=ll 
awaitll 
dbll 
.ll 
Clientsll %
.ll% &
SingleAsyncll& 1
(ll1 2
xll2 3
=>ll4 6
xll7 8
.ll8 9
Idll9 ;
==ll< >
itemll? C
.llC D
ClientIdllD L
,llL M
ctllN P
)llP Q
;llQ R
varmm 
projectmm 
=mm 
awaitmm 
dbmm 
.mm 
Projectsmm '
.mm' (
Wheremm( -
(mm- .
xmm. /
=>mm0 2
xmm3 4
.mm4 5
Idmm5 7
==mm8 :
itemmm; ?
.mm? @
	ProjectIdmm@ I
)mmI J
.mmJ K
SelectmmK Q
(mmQ R
xmmR S
=>mmT V
xmmW X
.mmX Y
NamemmY ]
)mm] ^
.mm^ _
SingleAsyncmm_ j
(mmj k
ctmmk m
)mmm n
;mmn o
varnn 
datann 
=nn 
newnn 

Dictionarynn !
<nn! "
stringnn" (
,nn( )
stringnn* 0
>nn0 1
{nn2 3
[nn4 5
$strnn5 ?
]nn? @
=nnA B
clientnnC I
.nnI J
IdnnJ L
.nnL M
ToStringnnM U
(nnU V
)nnV W
,nnW X
[nnY Z
$strnnZ c
]nnc d
=nne f
clientnng m
.nnm n
CompanyNamennn y
,nny z
[nn{ |
$str	nn| Ö
]
nnÖ Ü
=
nná à
years
nnâ é
>
nnè ê
$num
nnë í
?
nnì î
$"
nnï ó
{
nnó ò
product
nnò ü
.
nnü †
Name
nn† §
}
nn§ •
$str
nn• ß
{
nnß ®
years
nn® ≠
}
nn≠ Æ
$str
nnÆ ¥
"
nn¥ µ
:
nn∂ ∑
product
nn∏ ø
.
nnø ¿
Name
nn¿ ƒ
,
nnƒ ≈
[
nn∆ «
$str
nn« –
]
nn– —
=
nn“ ”
project
nn‘ €
,
nn€ ‹
[
nn› ﬁ
$str
nnﬁ Ë
]
nnË È
=
nnÍ Î
product
nnÏ Û
.
nnÛ Ù
Currency
nnÙ ¸
}
nn˝ ˛
;
nn˛ ˇ
ifoo 

(oo 
itemoo 
.oo 
ChargeTotaloo 
(oo 
igvRateoo $
,oo$ %
yearsoo& +
)oo+ ,
isoo- /
decimaloo0 7
amountoo8 >
)oo> ?
dataoo@ D
[ooD E
$strooE M
]ooM N
=ooO P
amountooQ W
.ooW X
ToStringooX `
(oo` a
CultureInfoooa l
.ool m
InvariantCultureoom }
)oo} ~
;oo~ 
awaitpp 
notificationspp 
.pp 
	SendAsyncpp %
(pp% &
clientpp& ,
,pp, -
newpp. 1
Notificationpp2 >
(pp> ?
NotificationTypepp? O
.ppO P
TransferRequestedppP a
,ppa b
datappc g
,ppg h
$"ppi k
$strppk |
{pp| }
item	pp} Å
.
ppÅ Ç
Id
ppÇ Ñ
}
ppÑ Ö
"
ppÖ Ü
,
ppÜ á

staffEmail
ppà í
)
ppí ì
,
ppì î
ct
ppï ó
)
ppó ò
;
ppò ô
}qq 
[ss 
	Authorizess 
(ss 
Rolesss 
=ss 
$strss &
)ss& '
,ss' (
HttpPostss) 1
(ss1 2
$strss2 S
)ssS T
]ssT U
publictt 

asynctt 
Tasktt 
<tt 
IActionResulttt #
>tt# $
Renewtt% *
(tt* +
Guidtt+ /
idtt0 2
,tt2 3
Guidtt4 8
?tt8 9
clientIdtt: B
,ttB C
CancellationTokenttD U
ctttV X
,ttX Y
intttZ ]
yearstt^ c
=ttd e
$numttf g
)ttg h
{uu 
varvv 
scopevv 
=vv 
ClientScopevv 
(vv  
clientIdvv  (
,vv( )
outvv* -
varvv. 1
ownervv2 7
)vv7 8
;vv8 9
ifvv: <
(vv= >
scopevv> C
isvvD F
notvvG J
nullvvK O
)vvO P
returnvvQ W
scopevvX ]
;vv] ^
varww 
itemww 
=ww 
awaitww 
dbww 
.ww 
ClientProductsww *
.ww* +
Includeww+ 2
(ww2 3
xww3 4
=>ww5 7
xww8 9
.ww9 :
Productww: A
)wwA B
.wwB C 
SingleOrDefaultAsyncwwC W
(wwW X
xwwX Y
=>wwZ \
xww] ^
.ww^ _
Idww_ a
==wwb d
idwwe g
&&wwh j
xwwk l
.wwl m
ClientIdwwm u
==wwv x
ownerwwy ~
,ww~ 
ct
wwÄ Ç
)
wwÇ É
;
wwÉ Ñ
ifxx 

(xx 
itemxx 
?xx 
.xx 
Productxx 
isxx 
nullxx !
)xx! "
returnxx# )
NotFoundxx* 2
(xx2 3
)xx3 4
;xx4 5
varzz 
	renewablezz 
=zz 
itemzz 
.zz 
BillingCyclezz )
==zz* ,
BillingCyclezz- 9
.zz9 :
Anualzz: ?
&&zz@ B
(zzC D
itemzzD H
.zzH I
StatuszzI O
iszzP R
ClientProductStatuszzS f
.zzf g
	PorVencerzzg p
orzzq s 
ClientProductStatus	zzt á
.
zzá à
Vencido
zzà è
||
zzê í
item
zzì ó
.
zzó ò
RenewsAt
zzò †
<=
zz° £
DateTime
zz§ ¨
.
zz¨ ≠
UtcNow
zz≠ ≥
.
zz≥ ¥
AddDays
zz¥ ª
(
zzª º
RenewalWindowDays
zzº Õ
)
zzÕ Œ
)
zzŒ œ
;
zzœ –
if{{ 

({{ 
item{{ 
.{{ 
IsManualBilling{{  
||{{! #
!{{$ %
({{% &
	renewable{{& /
||{{0 2
item{{3 7
.{{7 8
Status{{8 >
=={{? A
ClientProductStatus{{B U
.{{U V
	Pendiente{{V _
){{_ `
){{` a
return{{b h

BadRequest{{i s
({{s t
new{{t w
{{{x y
message	{{z Å
=
{{Ç É
$str
{{Ñ ±
}
{{≤ ≥
)
{{≥ ¥
;
{{¥ µ
if|| 

(|| 
!|| 
(|| 
await|| 
	transfers|| 
.|| 
SettingsAsync|| +
(||+ ,
ct||, .
)||. /
)||/ 0
.||0 1
PayPalEnabled||1 >
)||> ?
return||@ F

BadRequest||G Q
(||Q R
new||R U
{||V W
message||X _
=||` a
$str	||b î
}
||ï ñ
)
||ñ ó
;
||ó ò
try}} 
{}} 
var}} 
checkout}} 
=}} 
await}} "
checkoutService}}# 2
.}}2 3

StartAsync}}3 =
(}}= >
item}}> B
,}}B C
item}}D H
.}}H I
Product}}I P
,}}P Q
Request}}R Y
,}}Y Z
ct}}[ ]
,}}] ^
await}}_ d
db}}e g
.}}g h
IgvRateForAsync}}h w
(}}w x
owner}}x }
,}}} ~
item	}} É
.
}}É Ñ
Product
}}Ñ ã
,
}}ã å
ct
}}ç è
)
}}è ê
,
}}ê ë
years
}}í ó
)
}}ó ò
;
}}ò ô
await
}}ö ü
db
}}† ¢
.
}}¢ £
SaveChangesAsync
}}£ ≥
(
}}≥ ¥
ct
}}¥ ∂
)
}}∂ ∑
;
}}∑ ∏
return
}}π ø
Ok
}}¿ ¬
(
}}¬ √
new
}}√ ∆
{
}}« »
approvalUrl
}}… ‘
=
}}’ ÷
checkout
}}◊ ﬂ
.
}}ﬂ ‡
ApprovalUrl
}}‡ Î
}
}}Ï Ì
)
}}Ì Ó
;
}}Ó Ô
}
}} Ò
catch
}}Ú ˜
(
}}¯ ˘'
InvalidOperationException
}}˘ í
ex
}}ì ï
)
}}ï ñ
{
}}ó ò
return
}}ô ü

BadRequest
}}† ™
(
}}™ ´
new
}}´ Æ
{
}}Ø ∞
message
}}± ∏
=
}}π ∫
ex
}}ª Ω
.
}}Ω æ
Message
}}æ ≈
}
}}∆ «
)
}}« »
;
}}» …
}
}}  À
}~~ 
[
ÄÄ 
	Authorize
ÄÄ 
(
ÄÄ 
Roles
ÄÄ 
=
ÄÄ 
$str
ÄÄ &
)
ÄÄ& '
,
ÄÄ' (
HttpPost
ÄÄ) 1
(
ÄÄ1 2
$str
ÄÄ2 T
)
ÄÄT U
]
ÄÄU V
public
ÅÅ 

async
ÅÅ 
Task
ÅÅ 
<
ÅÅ 
IActionResult
ÅÅ #
>
ÅÅ# $
Cancel
ÅÅ% +
(
ÅÅ+ ,
Guid
ÅÅ, 0
id
ÅÅ1 3
,
ÅÅ3 4
Guid
ÅÅ5 9
?
ÅÅ9 :
clientId
ÅÅ; C
,
ÅÅC D
CancellationToken
ÅÅE V
ct
ÅÅW Y
)
ÅÅY Z
{
ÇÇ 
var
ÉÉ 
scope
ÉÉ 
=
ÉÉ 
ClientScope
ÉÉ 
(
ÉÉ  
clientId
ÉÉ  (
,
ÉÉ( )
out
ÉÉ* -
var
ÉÉ. 1
owner
ÉÉ2 7
)
ÉÉ7 8
;
ÉÉ8 9
if
ÉÉ: <
(
ÉÉ= >
scope
ÉÉ> C
is
ÉÉD F
not
ÉÉG J
null
ÉÉK O
)
ÉÉO P
return
ÉÉQ W
scope
ÉÉX ]
;
ÉÉ] ^
var
ÑÑ 
item
ÑÑ 
=
ÑÑ 
await
ÑÑ 
db
ÑÑ 
.
ÑÑ 
ClientProducts
ÑÑ *
.
ÑÑ* +"
SingleOrDefaultAsync
ÑÑ+ ?
(
ÑÑ? @
x
ÑÑ@ A
=>
ÑÑB D
x
ÑÑE F
.
ÑÑF G
Id
ÑÑG I
==
ÑÑJ L
id
ÑÑM O
&&
ÑÑP R
x
ÑÑS T
.
ÑÑT U
ClientId
ÑÑU ]
==
ÑÑ^ `
owner
ÑÑa f
,
ÑÑf g
ct
ÑÑh j
)
ÑÑj k
;
ÑÑk l
if
ÖÖ 

(
ÖÖ 
item
ÖÖ 
is
ÖÖ 
null
ÖÖ 
)
ÖÖ 
return
ÖÖ  
NotFound
ÖÖ! )
(
ÖÖ) *
)
ÖÖ* +
;
ÖÖ+ ,
if
ÜÜ 

(
ÜÜ 
item
ÜÜ 
.
ÜÜ 
IsManualBilling
ÜÜ  
||
ÜÜ! #
item
ÜÜ$ (
.
ÜÜ( )
Status
ÜÜ) /
!=
ÜÜ0 2!
ClientProductStatus
ÜÜ3 F
.
ÜÜF G
Activo
ÜÜG M
||
ÜÜN P
!
ÜÜQ R
item
ÜÜR V
.
ÜÜV W
BillingCycle
ÜÜW c
.
ÜÜc d
IsSubscription
ÜÜd r
(
ÜÜr s
)
ÜÜs t
||
ÜÜu w
string
ÜÜx ~
.
ÜÜ~ !
IsNullOrWhiteSpaceÜÜ ë
(ÜÜë í
itemÜÜí ñ
.ÜÜñ ó$
PayPalSubscriptionIdÜÜó ´
)ÜÜ´ ¨
)ÜÜ¨ ≠
returnÜÜÆ ¥

BadRequestÜÜµ ø
(ÜÜø ¿
newÜÜ¿ √
{ÜÜƒ ≈
messageÜÜ∆ Õ
=ÜÜŒ œ
$strÜÜ– Ñ
}ÜÜÖ Ü
)ÜÜÜ á
;ÜÜá à
await
áá 
payPal
áá 
.
áá %
CancelSubscriptionAsync
áá ,
(
áá, -
item
áá- 1
.
áá1 2"
PayPalSubscriptionId
áá2 F
,
ááF G
$str
ááH y
,
ááy z
ct
áá{ }
)
áá} ~
;
áá~ 
itemááÄ Ñ
.ááÑ Ö
StatusááÖ ã
=ááå ç#
ClientProductStatusááé °
.áá° ¢
	Canceladoáá¢ ´
;áá´ ¨
awaitáá≠ ≤
dbáá≥ µ
.ááµ ∂ 
SaveChangesAsyncáá∂ ∆
(áá∆ «
ctáá« …
)áá…  
;áá  À
returnááÃ “
Okáá” ’
(áá’ ÷
)áá÷ ◊
;áá◊ ÿ
}
àà 
[
ãã 
	Authorize
ãã 
(
ãã 
Roles
ãã 
=
ãã 
$str
ãã &
)
ãã& '
,
ãã' (
HttpPost
ãã) 1
(
ãã1 2
$str
ãã2 U
)
ããU V
]
ããV W
public
åå 

async
åå 
Task
åå 
<
åå 
IActionResult
åå #
>
åå# $
Capture
åå% ,
(
åå, -
Guid
åå- 1
id
åå2 4
,
åå4 5
Guid
åå6 :
?
åå: ;
clientId
åå< D
,
ååD E
CancellationToken
ååF W
ct
ååX Z
)
ååZ [
{
çç 
var
éé 
scope
éé 
=
éé 
ClientScope
éé 
(
éé  
clientId
éé  (
,
éé( )
out
éé* -
var
éé. 1
owner
éé2 7
)
éé7 8
;
éé8 9
if
éé: <
(
éé= >
scope
éé> C
is
ééD F
not
ééG J
null
ééK O
)
ééO P
return
ééQ W
scope
ééX ]
;
éé] ^
var
èè 
item
èè 
=
èè 
await
èè 
db
èè 
.
èè 
ClientProducts
èè *
.
èè* +
Include
èè+ 2
(
èè2 3
x
èè3 4
=>
èè5 7
x
èè8 9
.
èè9 :
Product
èè: A
)
èèA B
.
èèB C"
SingleOrDefaultAsync
èèC W
(
èèW X
x
èèX Y
=>
èèZ \
x
èè] ^
.
èè^ _
Id
èè_ a
==
èèb d
id
èèe g
&&
èèh j
x
èèk l
.
èèl m
ClientId
èèm u
==
èèv x
owner
èèy ~
,
èè~ 
ctèèÄ Ç
)èèÇ É
;èèÉ Ñ
if
êê 

(
êê 
item
êê 
is
êê 
null
êê 
)
êê 
return
êê  
NotFound
êê! )
(
êê) *
)
êê* +
;
êê+ ,
try
ëë 
{
ëë 
await
ëë 
payments
ëë 
.
ëë 
ConfirmAsync
ëë )
(
ëë) *
item
ëë* .
,
ëë. /
ct
ëë0 2
)
ëë2 3
;
ëë3 4
}
ëë5 6
catch
íí 
(
íí "
HttpRequestException
íí #
ex
íí$ &
)
íí& '
{
íí( )
logger
íí* 0
.
íí0 1

LogWarning
íí1 ;
(
íí; <
ex
íí< >
,
íí> ?
$stríí@ Ö
,ííÖ Ü
idííá â
)ííâ ä
;ííä ã
}ííå ç
return
ìì 
Ok
ìì 
(
ìì 
new
ìì 
{
ìì 
status
ìì 
=
ìì  
item
ìì! %
.
ìì% &
Status
ìì& ,
.
ìì, -
ToString
ìì- 5
(
ìì5 6
)
ìì6 7
}
ìì8 9
)
ìì9 :
;
ìì: ;
}
îî 
[
ññ 
	Authorize
ññ 
(
ññ 
Roles
ññ 
=
ññ 
$str
ññ &
)
ññ& '
,
ññ' (
HttpGet
ññ) 0
(
ññ0 1
$str
ññ1 L
)
ññL M
]
ññM N
public
óó 

async
óó 
Task
óó 
<
óó 
IActionResult
óó #
>
óó# $
ClientProduct
óó% 2
(
óó2 3
Guid
óó3 7
id
óó8 :
,
óó: ;
Guid
óó< @
?
óó@ A
clientId
óóB J
,
óóJ K
CancellationToken
óóL ]
ct
óó^ `
)
óó` a
{
òò 
var
ôô 
scope
ôô 
=
ôô 
ClientScope
ôô 
(
ôô  
clientId
ôô  (
,
ôô( )
out
ôô* -
var
ôô. 1
owner
ôô2 7
)
ôô7 8
;
ôô8 9
if
ôô: <
(
ôô= >
scope
ôô> C
is
ôôD F
not
ôôG J
null
ôôK O
)
ôôO P
return
ôôQ W
scope
ôôX ]
;
ôô] ^
var
öö 
item
öö 
=
öö 
await
öö 
db
öö 
.
öö 
ClientProducts
öö *
.
öö* +
Include
öö+ 2
(
öö2 3
x
öö3 4
=>
öö5 7
x
öö8 9
.
öö9 :
Product
öö: A
)
ööA B
.
ööB C
Include
ööC J
(
ööJ K
x
ööK L
=>
ööM O
x
ööP Q
.
ööQ R
Project
ööR Y
)
ööY Z
.
ööZ ["
SingleOrDefaultAsync
öö[ o
(
ööo p
x
ööp q
=>
öör t
x
ööu v
.
ööv w
Id
ööw y
==
ööz |
id
öö} 
&&ööÄ Ç
xööÉ Ñ
.ööÑ Ö
ClientIdööÖ ç
==ööé ê
ownerööë ñ
,ööñ ó
ctööò ö
)ööö õ
;ööõ ú
returnööù £
itemöö§ ®
isöö© ´
nullöö¨ ∞
?öö± ≤
NotFoundöö≥ ª
(ööª º
)ööº Ω
:ööæ ø
Oköö¿ ¬
(öö¬ √
itemöö√ «
)öö« »
;öö» …
}
õõ 
[
ùù 
HttpPost
ùù 
(
ùù 
$str
ùù (
)
ùù( )
]
ùù) *
public
ûû 

async
ûû 
Task
ûû 
<
ûû 
IActionResult
ûû #
>
ûû# $
Webhook
ûû% ,
(
ûû, -
CancellationToken
ûû- >
ct
ûû? A
)
ûûA B
{
üü 
using
†† 
var
†† 
reader
†† 
=
†† 
new
†† 
StreamReader
†† +
(
††+ ,
Request
††, 3
.
††3 4
Body
††4 8
)
††8 9
;
††9 :
var
††; >
payload
††? F
=
††G H
await
††I N
reader
††O U
.
††U V
ReadToEndAsync
††V d
(
††d e
ct
††e g
)
††g h
;
††h i
var
††j m
headers
††n u
=
††v w
Request
††x 
.†† Ä
Headers††Ä á
.††á à
ToDictionary††à î
(††î ï
x††ï ñ
=>††ó ô
x††ö õ
.††õ ú
Key††ú ü
.††ü † 
ToLowerInvariant††† ∞
(††∞ ±
)††± ≤
,††≤ ≥
x††¥ µ
=>††∂ ∏
x††π ∫
.††∫ ª
Value††ª ¿
.††¿ ¡
ToString††¡ …
(††…  
)††  À
)††À Ã
;††Ã Õ
if
°° 

(
°° 
!
°° 
await
°° 
payPal
°° 
.
°°  
VerifyWebhookAsync
°° ,
(
°°, -
payload
°°- 4
,
°°4 5
headers
°°6 =
,
°°= >
ct
°°? A
)
°°A B
)
°°B C
return
°°D J
Unauthorized
°°K W
(
°°W X
)
°°X Y
;
°°Y Z
using
¢¢ 
var
¢¢ 
json
¢¢ 
=
¢¢ 
JsonDocument
¢¢ %
.
¢¢% &
Parse
¢¢& +
(
¢¢+ ,
payload
¢¢, 3
)
¢¢3 4
;
¢¢4 5
var
¢¢6 9
root
¢¢: >
=
¢¢? @
json
¢¢A E
.
¢¢E F
RootElement
¢¢F Q
;
¢¢Q R
var
¢¢S V
	eventType
¢¢W `
=
¢¢a b
Find
¢¢c g
(
¢¢g h
root
¢¢h l
,
¢¢l m
$str
¢¢n z
)
¢¢z {
;
¢¢{ |
if
¢¢} 
(¢¢Ä Å
!¢¢Å Ç
root¢¢Ç Ü
.¢¢Ü á
TryGetProperty¢¢á ï
(¢¢ï ñ
$str¢¢ñ †
,¢¢† °
out¢¢¢ •
var¢¢¶ ©
resource¢¢™ ≤
)¢¢≤ ≥
)¢¢≥ ¥
return¢¢µ ª
Ok¢¢º æ
(¢¢æ ø
)¢¢ø ¿
;¢¢¿ ¡
var
££ 

resourceId
££ 
=
££ 
Find
££ 
(
££ 
resource
££ &
,
££& '
$str
££( ,
)
££, -
;
££- .
var
££/ 2
orderId
££3 :
=
££; <
Nested
££= C
(
££C D
resource
££D L
,
££L M
$str
££N b
,
££b c
$str
££d q
,
££q r
$str
££s }
)
££} ~
??££ Å

resourceId££Ç å
;££å ç
var££é ë
customId££í ö
=££õ ú
Find££ù °
(££° ¢
resource££¢ ™
,££™ ´
$str££¨ ∑
)££∑ ∏
??££π ª
Find££º ¿
(££¿ ¡
resource££¡ …
,££…  
$str££À ”
)££” ‘
??££’ ◊
Find££ÿ ‹
(££‹ ›
root££› ·
,££· ‚
$str££„ Ó
)££Ó Ô
??££ Ú
PurchaseUnit££Û ˇ
(££ˇ Ä
resource££Ä à
,££à â
$str££ä ï
)££ï ñ
;££ñ ó
var
•• 
subscriptionId
•• 
=
•• 
Find
•• !
(
••! "
resource
••" *
,
••* +
$str
••, B
)
••B C
??
••D F

resourceId
••G Q
;
••Q R
var
¶¶ 
item
¶¶ 
=
¶¶ 
await
¶¶ 
WebhookItemAsync
¶¶ )
(
¶¶) *
customId
¶¶* 2
,
¶¶2 3
orderId
¶¶4 ;
,
¶¶; <
subscriptionId
¶¶= K
,
¶¶K L
ct
¶¶M O
)
¶¶O P
;
¶¶P Q
if
ßß 

(
ßß 
item
ßß 
is
ßß 
null
ßß 
)
ßß 
return
ßß  
Ok
ßß! #
(
ßß# $
)
ßß$ %
;
ßß% &
if
®® 

(
®® 
	eventType
®® 
is
®® 
$str
®® 9
or
®®: <
$str
®®= ]
)
®®] ^
{
®®_ `
item
®®a e
.
®®e f
Status
®®f l
=
®®m n
	eventType
®®o x
.
®®x y
EndsWith®®y Å
(®®Å Ç
$str®®Ç ç
)®®ç é
?®®è ê#
ClientProductStatus®®ë §
.®®§ •
Activo®®• ´
:®®¨ ≠#
ClientProductStatus®®Æ ¡
.®®¡ ¬
	Cancelado®®¬ À
;®®À Ã
item®®Õ —
.®®— “$
PayPalSubscriptionId®®“ Ê
??=®®Á Í

resourceId®®Î ı
;®®ı ˆ
}®®˜ ¯
if
™™ 

(
™™ 
	eventType
™™ 
is
™™ 
$str
™™ 2
)
™™2 3
{
™™4 5
item
™™6 :
.
™™: ;
PayPalOrderId
™™; H
??=
™™I L
orderId
™™M T
;
™™T U
await
™™V [
db
™™\ ^
.
™™^ _
SaveChangesAsync
™™_ o
(
™™o p
ct
™™p r
)
™™r s
;
™™s t
await
™™u z
payments™™{ É
.™™É Ñ
CaptureAsync™™Ñ ê
(™™ê ë
item™™ë ï
,™™ï ñ
ct™™ó ô
)™™ô ö
;™™ö õ
}™™ú ù
if
¨¨ 

(
¨¨ 
	eventType
¨¨ 
is
¨¨ 
$str
¨¨ 4
or
¨¨5 7
$str
¨¨8 P
&&
¨¨Q S
Amount
¨¨T Z
(
¨¨Z [
resource
¨¨[ c
)
¨¨c d
is
¨¨e g
(
¨¨h i
decimal
¨¨i p
amount
¨¨q w
,
¨¨w x
var
¨¨y |
currency¨¨} Ö
)¨¨Ö Ü
&&¨¨á â
orderId¨¨ä ë
is¨¨í î
not¨¨ï ò
null¨¨ô ù
)¨¨ù û
await
≠≠ 
payments
≠≠ 
.
≠≠ 
ApplyPaymentAsync
≠≠ ,
(
≠≠, -
item
≠≠- 1
,
≠≠1 2
orderId
≠≠3 :
,
≠≠: ;
amount
≠≠< B
,
≠≠B C
currency
≠≠D L
,
≠≠L M
ct
≠≠N P
)
≠≠P Q
;
≠≠Q R
await
ÆÆ 
db
ÆÆ 
.
ÆÆ 
SaveChangesAsync
ÆÆ !
(
ÆÆ! "
ct
ÆÆ" $
)
ÆÆ$ %
;
ÆÆ% &
if
ØØ 

(
ØØ 
	eventType
ØØ 
is
ØØ 
$str
ØØ 1
or
ØØ2 4
$str
ØØ5 J
or
ØØK M
$str
ØØN s
)
ØØs t
await
∞∞ &
NotifyPaymentFailedAsync
∞∞ *
(
∞∞* +
item
∞∞+ /
,
∞∞/ 0
Find
∞∞1 5
(
∞∞5 6
root
∞∞6 :
,
∞∞: ;
$str
∞∞< @
)
∞∞@ A
??
∞∞B D

resourceId
∞∞E O
,
∞∞O P
ct
∞∞Q S
)
∞∞S T
;
∞∞T U
return
±± 
Ok
±± 
(
±± 
)
±± 
;
±± 
}
≤≤ 
private
µµ 
async
µµ 
Task
µµ 
<
µµ 
ClientProduct
µµ $
?
µµ$ %
>
µµ% &
WebhookItemAsync
µµ' 7
(
µµ7 8
string
µµ8 >
?
µµ> ?
customId
µµ@ H
,
µµH I
string
µµJ P
?
µµP Q
orderId
µµR Y
,
µµY Z
string
µµ[ a
?
µµa b
subscriptionId
µµc q
,
µµq r 
CancellationTokenµµs Ñ
ctµµÖ á
)µµá à
{
∂∂ 
var
∑∑ 
products
∑∑ 
=
∑∑ 
db
∑∑ 
.
∑∑ 
ClientProducts
∑∑ (
.
∑∑( )
Include
∑∑) 0
(
∑∑0 1
x
∑∑1 2
=>
∑∑3 5
x
∑∑6 7
.
∑∑7 8
Product
∑∑8 ?
)
∑∑? @
;
∑∑@ A
if
∏∏ 

(
∏∏ 
Guid
∏∏ 
.
∏∏ 
TryParse
∏∏ 
(
∏∏ 
customId
∏∏ "
,
∏∏" #
out
∏∏$ '
var
∏∏( +

customGuid
∏∏, 6
)
∏∏6 7
&&
∏∏8 :
await
∏∏; @
products
∏∏A I
.
∏∏I J"
SingleOrDefaultAsync
∏∏J ^
(
∏∏^ _
x
∏∏_ `
=>
∏∏a c
x
∏∏d e
.
∏∏e f
Id
∏∏f h
==
∏∏i k

customGuid
∏∏l v
,
∏∏v w
ct
∏∏x z
)
∏∏z {
is
∏∏| ~
{∏∏ Ä
}∏∏Å Ç
item∏∏É á
)∏∏á à
return∏∏â è
item∏∏ê î
;∏∏î ï
if
ππ 

(
ππ 
string
ππ 
.
ππ  
IsNullOrWhiteSpace
ππ %
(
ππ% &
orderId
ππ& -
)
ππ- .
)
ππ. /
return
ππ0 6
null
ππ7 ;
;
ππ; <
return
∫∫ 
await
∫∫ 
products
∫∫ 
.
∫∫ "
SingleOrDefaultAsync
∫∫ 2
(
∫∫2 3
x
∫∫3 4
=>
∫∫5 7
x
∫∫8 9
.
∫∫9 :"
PayPalSubscriptionId
∫∫: N
==
∫∫O Q
subscriptionId
∫∫R `
||
∫∫a c
x
∫∫d e
.
∫∫e f
PayPalOrderId
∫∫f s
==
∫∫t v
orderId
∫∫w ~
,
∫∫~ 
ct∫∫Ä Ç
)∫∫Ç É
;∫∫É Ñ
}
ªª 
private
ΩΩ 
async
ΩΩ 
Task
ΩΩ &
NotifyPaymentFailedAsync
ΩΩ /
(
ΩΩ/ 0
ClientProduct
ΩΩ0 =
item
ΩΩ> B
,
ΩΩB C
string
ΩΩD J
?
ΩΩJ K
eventId
ΩΩL S
,
ΩΩS T
CancellationToken
ΩΩU f
ct
ΩΩg i
)
ΩΩi j
{
ææ 
if
øø 

(
øø 
await
øø 
db
øø 
.
øø 
Clients
øø 
.
øø 
	FindAsync
øø &
(
øø& '
[
øø' (
item
øø( ,
.
øø, -
ClientId
øø- 5
]
øø5 6
,
øø6 7
ct
øø8 :
)
øø: ;
is
øø< >
not
øø? B
Client
øøC I
client
øøJ P
)
øøP Q
return
øøR X
;
øøX Y
await
¿¿ 
notifications
¿¿ 
.
¿¿ 
	SendAsync
¿¿ %
(
¿¿% &
client
¿¿& ,
,
¿¿, -
new
¿¿. 1
Notification
¿¿2 >
(
¿¿> ?
NotificationType
¿¿? O
.
¿¿O P
PaymentFailed
¿¿P ]
,
¿¿] ^
new
¿¿_ b
(
¿¿b c
)
¿¿c d
{
¿¿e f
[
¿¿g h
$str
¿¿h q
]
¿¿q r
=
¿¿s t
item
¿¿u y
.
¿¿y z
Product¿¿z Å
?¿¿Å Ç
.¿¿Ç É
Name¿¿É á
??¿¿à ä
$str¿¿ã ç
}¿¿é è
,¿¿è ê
$"¿¿ë ì
$str¿¿ì ¢
{¿¿¢ £
eventId¿¿£ ™
}¿¿™ ´
"¿¿´ ¨
)¿¿¨ ≠
,¿¿≠ Æ
ct¿¿Ø ±
)¿¿± ≤
;¿¿≤ ≥
}
¡¡ 
private
√√ 
static
√√ 
string
√√ 
?
√√ 
Find
√√ 
(
√√  
JsonElement
√√  +
value
√√, 1
,
√√1 2
string
√√3 9
property
√√: B
)
√√B C
=>
√√D F
value
√√G L
.
√√L M
TryGetProperty
√√M [
(
√√[ \
property
√√\ d
,
√√d e
out
√√f i
var
√√j m
item
√√n r
)
√√r s
&&
√√t v
item
√√w {
.
√√{ |
	ValueKind√√| Ö
==√√Ü à
JsonValueKind√√â ñ
.√√ñ ó
String√√ó ù
?√√û ü
item√√† §
.√√§ •
	GetString√√• Æ
(√√Æ Ø
)√√Ø ∞
:√√± ≤
null√√≥ ∑
;√√∑ ∏
private
ƒƒ 
static
ƒƒ 
string
ƒƒ 
?
ƒƒ 
Nested
ƒƒ !
(
ƒƒ! "
JsonElement
ƒƒ" -
value
ƒƒ. 3
,
ƒƒ3 4
params
ƒƒ5 ;
string
ƒƒ< B
[
ƒƒB C
]
ƒƒC D
path
ƒƒE I
)
ƒƒI J
{
ƒƒK L
foreach
ƒƒM T
(
ƒƒU V
var
ƒƒV Y
property
ƒƒZ b
in
ƒƒc e
path
ƒƒf j
)
ƒƒj k
{
ƒƒl m
if
ƒƒn p
(
ƒƒq r
!
ƒƒr s
value
ƒƒs x
.
ƒƒx y
TryGetPropertyƒƒy á
(ƒƒá à
propertyƒƒà ê
,ƒƒê ë
outƒƒí ï
valueƒƒñ õ
)ƒƒõ ú
)ƒƒú ù
returnƒƒû §
nullƒƒ• ©
;ƒƒ© ™
}ƒƒ´ ¨
returnƒƒ≠ ≥
valueƒƒ¥ π
.ƒƒπ ∫
	ValueKindƒƒ∫ √
==ƒƒƒ ∆
JsonValueKindƒƒ« ‘
.ƒƒ‘ ’
Stringƒƒ’ €
?ƒƒ‹ ›
valueƒƒﬁ „
.ƒƒ„ ‰
	GetStringƒƒ‰ Ì
(ƒƒÌ Ó
)ƒƒÓ Ô
:ƒƒ Ò
nullƒƒÚ ˆ
;ƒƒˆ ˜
}ƒƒ¯ ˘
private
≈≈ 
static
≈≈ 
string
≈≈ 
?
≈≈ 
PurchaseUnit
≈≈ '
(
≈≈' (
JsonElement
≈≈( 3
resource
≈≈4 <
,
≈≈< =
string
≈≈> D
property
≈≈E M
)
≈≈M N
=>
≈≈O Q
resource
≈≈R Z
.
≈≈Z [
TryGetProperty
≈≈[ i
(
≈≈i j
$str
≈≈j z
,
≈≈z {
out
≈≈| 
var≈≈Ä É
units≈≈Ñ â
)≈≈â ä
&&≈≈ã ç
units≈≈é ì
.≈≈ì î
	ValueKind≈≈î ù
==≈≈û †
JsonValueKind≈≈° Æ
.≈≈Æ Ø
Array≈≈Ø ¥
&&≈≈µ ∑
units≈≈∏ Ω
.≈≈Ω æ
GetArrayLength≈≈æ Ã
(≈≈Ã Õ
)≈≈Õ Œ
>≈≈œ –
$num≈≈— “
?≈≈” ‘
Find≈≈’ Ÿ
(≈≈Ÿ ⁄
units≈≈⁄ ﬂ
[≈≈ﬂ ‡
$num≈≈‡ ·
]≈≈· ‚
,≈≈‚ „
property≈≈‰ Ï
)≈≈Ï Ì
:≈≈Ó Ô
null≈≈ Ù
;≈≈Ù ı
private
∆∆ 
static
∆∆ 
(
∆∆ 
decimal
∆∆ 
?
∆∆ 
amount
∆∆ #
,
∆∆# $
string
∆∆% +
?
∆∆+ ,
currency
∆∆- 5
)
∆∆5 6
Amount
∆∆7 =
(
∆∆= >
JsonElement
∆∆> I
resource
∆∆J R
)
∆∆R S
{
«« 
foreach
…… 
(
…… 
var
…… 
name
…… 
in
…… 
new
……  
[
……  !
]
……! "
{
……# $
$str
……% -
,
……- .
$str
……/ =
}
……> ?
)
……? @
if
……A C
(
……D E
resource
……E M
.
……M N
TryGetProperty
……N \
(
……\ ]
name
……] a
,
……a b
out
……c f
var
……g j
value
……k p
)
……p q
&&
……r t
(
……u v
value
……v {
.
……{ |
TryGetProperty……| ä
(……ä ã
$str……ã í
,……í ì
out……î ó
var……ò õ
amount……ú ¢
)……¢ £
||……§ ¶
value……ß ¨
.……¨ ≠
TryGetProperty……≠ ª
(……ª º
$str……º √
,……√ ƒ
out……≈ »
amount……… œ
)……œ –
)……– —
&&……“ ‘
decimal……’ ‹
.……‹ ›
TryParse……› Â
(……Â Ê
amount……Ê Ï
.……Ï Ì
	GetString……Ì ˆ
(……ˆ ˜
)……˜ ¯
,……¯ ˘
System……˙ Ä
.……Ä Å
Globalization……Å é
.……é è
NumberStyles……è õ
.……õ ú
Number……ú ¢
,……¢ £
System……§ ™
.……™ ´
Globalization……´ ∏
.……∏ π
CultureInfo……π ƒ
.……ƒ ≈ 
InvariantCulture……≈ ’
,……’ ÷
out……◊ ⁄
var……€ ﬁ
parsed……ﬂ Â
)……Â Ê
)……Ê Á
return……Ë Ó
(……Ô 
parsed…… ˆ
,……ˆ ˜
Find……¯ ¸
(……¸ ˝
value……˝ Ç
,……Ç É
$str……Ñ ì
)……ì î
??……ï ó
Find……ò ú
(……ú ù
value……ù ¢
,……¢ £
$str……§ Æ
)……Æ Ø
)……Ø ∞
;……∞ ±
if
   

(
   
resource
   
.
   
TryGetProperty
   #
(
  # $
$str
  $ 4
,
  4 5
out
  6 9
var
  : =
units
  > C
)
  C D
&&
  E G
units
  H M
.
  M N
	ValueKind
  N W
==
  X Z
JsonValueKind
  [ h
.
  h i
Array
  i n
&&
  o q
units
  r w
.
  w x
GetArrayLength  x Ü
(  Ü á
)  á à
>  â ä
$num  ã å
)  å ç
return  é î
Amount  ï õ
(  õ ú
units  ú °
[  ° ¢
$num  ¢ £
]  £ §
)  § •
;  • ¶
return
ÀÀ 
(
ÀÀ 
null
ÀÀ 
,
ÀÀ 
null
ÀÀ 
)
ÀÀ 
;
ÀÀ 
}
ÃÃ 
}ÕÕ 
public–– 
sealed
–– 
record
–– 
SubscribeRequest
–– %
(
––% &
[
––& '
property
––' /
:
––/ 0
JsonRequired
––1 =
]
––= >
Guid
––? C
	ProductId
––D M
,
––M N
Guid
––O S
?
––S T
	ProjectId
––U ^
,
––^ _
[
––` a
property
––a i
:
––i j
JsonRequired
––k w
]
––w x
BillingCycle––y Ö
BillingCycle––Ü í
,––í ì
string––î ö
PaymentMethod––õ ®
=––© ™
PaymentMethods––´ π
.––π ∫
PayPal––∫ ¿
,––¿ ¡
int––¬ ≈
Years––∆ À
=––Ã Õ
$num––Œ œ
)––œ –
;––– —∑u
LC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\LoginLinkController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str +
)+ ,
], -
public 
sealed 
class 
LoginLinkController '
(' (
RtresDbContext( 6
db7 9
,9 :
JwtSettings; F
jwtG J
,J K
IMemoryCacheL X
cacheY ^
,^ _
ILoginLinkMailer` p
mailerq w
,w x
IConfiguration	y á
configuration
à ï
)
ï ñ
:
ó ò
ControllerBase
ô ß
{ 
public 

static 
readonly 
TimeSpan #
Lifetime$ ,
=- .
TimeSpan/ 7
.7 8
FromMinutes8 C
(C D
$numD F
)F G
;G H
const 	
int
 
MaxLinksPerWindow 
=  !
$num" #
;# $
public 

const 
string 
Sent 
= 
$str p
;p q
public 

const 
string 
Invalid 
=  !
$str" y
;y z
sealed 

class 
	SentLinks 
{ 
public #
int$ '
Count( -
;- .
}/ 0
[   
HttpPost   
,   
EnableRateLimiting   !
(  ! "
AuthController  " 0
.  0 1 
LoginRateLimitPolicy  1 E
)  E F
]  F G
public!! 

async!! 
Task!! 
<!! 
ActionResult!! "
>!!" #
Send!!$ (
(!!( )
LoginLinkRequest!!) 9
request!!: A
,!!A B
CancellationToken!!C T
ct!!U W
)!!W X
{"" 
var## 
email## 
=## 
request## 
.## 
Email## !
?##! "
.##" #
Trim### '
(##' (
)##( )
.##) *
ToLowerInvariant##* :
(##: ;
)##; <
;##< =
if$$ 

($$ 
string$$ 
.$$ 
IsNullOrEmpty$$  
($$  !
email$$! &
)$$& '
||$$( *
!$$+ ,
email$$, 1
.$$1 2
Contains$$2 :
($$: ;
$char$$; >
)$$> ?
)$$? @
return$$A G

BadRequest$$H R
($$R S
new$$S V
{$$W X
message$$Y `
=$$a b
$str$$c ~
}	$$ Ä
)
$$Ä Å
;
$$Å Ç
var%% 
u%% 
=%% 
await%% 
db%% 
.%% 
UserAccounts%% %
.%%% &
AsNoTracking%%& 2
(%%2 3
)%%3 4
.%%4 5
FirstOrDefaultAsync%%5 H
(%%H I
x%%I J
=>%%K M
x%%N O
.%%O P
IsActive%%P X
&&%%Y [
x%%\ ]
.%%] ^
Email%%^ c
.%%c d
Trim%%d h
(%%h i
)%%i j
.%%j k
ToLower%%k r
(%%r s
)%%s t
==%%u w
email%%x }
,%%} ~
ct	%% Å
)
%%Å Ç
;
%%Ç É
var&& 
c&& 
=&& 
u&& 
?&& 
.&& 
ClientId&& 
is&& 
Guid&& #
clientId&&$ ,
?&&- .
await&&/ 4
db&&5 7
.&&7 8
Clients&&8 ?
.&&? @
AsNoTracking&&@ L
(&&L M
)&&M N
.&&N O
FirstOrDefaultAsync&&O b
(&&b c
x&&c d
=>&&e g
x&&h i
.&&i j
Id&&j l
==&&m o
clientId&&p x
,&&x y
ct&&z |
)&&| }
:&&~ 
null
&&Ä Ñ
;
&&Ñ Ö
if'' 

('' 
u'' 
is'' 
null'' 
||'' 
c'' 
is'' 
{'' 
IsActive''  (
:''( )
false''* /
}''0 1
||''2 4
!''5 6
WithinLimit''6 A
(''A B
email''B G
)''G H
)''H I
return''J P
Accepted''Q Y
(''Y Z
new''Z ]
{''^ _
message''` g
=''h i
Sent''j n
}''o p
)''p q
;''q r
var)) 
now)) 
=)) 
DateTime)) 
.)) 
UtcNow)) !
;))! "
var** 
token** 
=** 
	Base64Url** 
.** 
EncodeToString** ,
(**, -!
RandomNumberGenerator**- B
.**B C
GetBytes**C K
(**K L
$num**L N
)**N O
)**O P
;**P Q
db,, 

.,,
 

LoginLinks,, 
.,, 
RemoveRange,, !
(,,! "
await,," '
db,,( *
.,,* +

LoginLinks,,+ 5
.,,5 6
Where,,6 ;
(,,; <
x,,< =
=>,,> @
x,,A B
.,,B C
UserAccountId,,C P
==,,Q S
u,,T U
.,,U V
Id,,V X
&&,,Y [
x,,\ ]
.,,] ^
	ExpiresAt,,^ g
<,,h i
now,,j m
),,m n
.,,n o
ToListAsync,,o z
(,,z {
ct,,{ }
),,} ~
),,~ 
;	,, Ä
db-- 

.--
 

LoginLinks-- 
.-- 
Add-- 
(-- 
new-- 
	LoginLink-- '
{--( )
UserAccountId--* 7
=--8 9
u--: ;
.--; <
Id--< >
,--> ?
	TokenHash--@ I
=--J K
Hash--L P
(--P Q
token--Q V
)--V W
,--W X
	CreatedAt--Y b
=--c d
now--e h
,--h i
	ExpiresAt--j s
=--t u
now--v y
+--z {
Lifetime	--| Ñ
}
--Ö Ü
)
--Ü á
;
--á à
await.. 
db.. 
... 
SaveChangesAsync.. !
(..! "
ct.." $
)..$ %
;..% &
var00 
notification00 
=00 
new00 
Notification00 +
(00+ ,
NotificationType00, <
.00< =
	LoginLink00= F
,00F G
new00H K
(00K L
)00L M
{11 	
[22 
$str22 
]22 
=22 
u22 
.22 
Name22 
.22 
Split22 #
(22# $
$char22$ '
,22' (
StringSplitOptions22) ;
.22; <
RemoveEmptyEntries22< N
)22N O
.22O P
FirstOrDefault22P ^
(22^ _
)22_ `
??22a c
u22d e
.22e f
Name22f j
,22j k
[33 
$str33 
]33 
=33 
token33 
,33 
[44 
$str44 
]44 
=44 
(44 
(44 
int44 
)44  
Lifetime44  (
.44( )
TotalMinutes44) 5
)445 6
.446 7
ToString447 ?
(44? @
CultureInfo44@ K
.44K L
InvariantCulture44L \
)44\ ]
,44] ^
}55 	
,55	 

To55 
:55 
u55 
.55 
Email55 
)55 
;55 
var66 
(66 
subject66 
,66 
html66 
,66 
text66  
)66  !
=66" #
EmailTemplates66$ 2
.662 3
Render663 9
(669 :
notification66: F
,66F G
c66H I
?66I J
.66J K
PreferredLanguage66K \
,66\ ]!
PayPalCheckoutService66^ s
.66s t
PortalBaseUrl	66t Å
(
66Å Ç
Request
66Ç â
,
66â ä
configuration
66ã ò
)
66ò ô
)
66ô ö
;
66ö õ
mailer77 
.77 
Send77 
(77 
new77 
EmailMessage77 $
(77$ %
u77% &
.77& '
Email77' ,
,77, -
subject77. 5
,775 6
html777 ;
,77; <
text77= A
)77A B
)77B C
;77C D
return88 
Accepted88 
(88 
new88 
{88 
message88 %
=88& '
Sent88( ,
}88- .
)88. /
;88/ 0
}99 
[<< 
HttpPost<< 
(<< 
$str<< 
)<< 
,<< 
EnableRateLimiting<< +
(<<+ ,
AuthController<<, :
.<<: ; 
LoginRateLimitPolicy<<; O
)<<O P
]<<P Q
public== 

async== 
Task== 
<== 
ActionResult== "
>==" #
Verify==$ *
(==* +"
LoginLinkVerifyRequest==+ A
request==B I
,==I J
CancellationToken==K \
ct==] _
)==_ `
{>> 
if?? 

(?? 
string?? 
.?? 
IsNullOrWhiteSpace?? %
(??% &
request??& -
.??- .
Token??. 3
)??3 4
)??4 5
return??6 <
Unauthorized??= I
(??I J
new??J M
{??N O
message??P W
=??X Y
Invalid??Z a
}??b c
)??c d
;??d e
var@@ 
hash@@ 
=@@ 
Hash@@ 
(@@ 
request@@ 
.@@  
Token@@  %
.@@% &
Trim@@& *
(@@* +
)@@+ ,
)@@, -
;@@- .
varAA 
nowAA 
=AA 
DateTimeAA 
.AA 
UtcNowAA !
;AA! "
varBB 
linkBB 
=BB 
awaitBB 
dbBB 
.BB 

LoginLinksBB &
.BB& '
FirstOrDefaultAsyncBB' :
(BB: ;
xBB; <
=>BB= ?
xBB@ A
.BBA B
	TokenHashBBB K
==BBL N
hashBBO S
,BBS T
ctBBU W
)BBW X
;BBX Y
ifCC 

(CC 
linkCC 
isCC 
nullCC 
||CC 
linkCC  
.CC  !
UsedAtCC! '
isCC( *
notCC+ .
nullCC/ 3
||CC4 6
linkCC7 ;
.CC; <
	ExpiresAtCC< E
<=CCF H
nowCCI L
)CCL M
returnCCN T
UnauthorizedCCU a
(CCa b
newCCb e
{CCf g
messageCCh o
=CCp q
InvalidCCr y
}CCz {
)CC{ |
;CC| }
linkDD 
.DD 
UsedAtDD 
=DD 
nowDD 
;DD 
tryEE 
{EE 
awaitEE 
dbEE 
.EE 
SaveChangesAsyncEE '
(EE' (
ctEE( *
)EE* +
;EE+ ,
}EE- .
catchFF 
(FF (
DbUpdateConcurrencyExceptionFF +
)FF+ ,
{FF- .
returnFF/ 5
UnauthorizedFF6 B
(FFB C
newFFC F
{FFG H
messageFFI P
=FFQ R
InvalidFFS Z
}FF[ \
)FF\ ]
;FF] ^
}FF_ `
varHH 
uHH 
=HH 
awaitHH 
dbHH 
.HH 
UserAccountsHH %
.HH% &
AsNoTrackingHH& 2
(HH2 3
)HH3 4
.HH4 5
FirstOrDefaultAsyncHH5 H
(HHH I
xHHI J
=>HHK M
xHHN O
.HHO P
IdHHP R
==HHS U
linkHHV Z
.HHZ [
UserAccountIdHH[ h
&&HHi k
xHHl m
.HHm n
IsActiveHHn v
,HHv w
ctHHx z
)HHz {
;HH{ |
ifII 

(II 
uII 
isII 
nullII 
)II 
returnII 
UnauthorizedII *
(II* +
newII+ .
{II/ 0
messageII1 8
=II9 :
InvalidII; B
}IIC D
)IID E
;IIE F
varJJ 
cJJ 
=JJ 
uJJ 
.JJ 
ClientIdJJ 
isJJ 
GuidJJ "
clientIdJJ# +
?JJ, -
awaitJJ. 3
dbJJ4 6
.JJ6 7
ClientsJJ7 >
.JJ> ?
AsNoTrackingJJ? K
(JJK L
)JJL M
.JJM N
FirstOrDefaultAsyncJJN a
(JJa b
xJJb c
=>JJd f
xJJg h
.JJh i
IdJJi k
==JJl n
clientIdJJo w
,JJw x
ctJJy {
)JJ{ |
:JJ} ~
null	JJ É
;
JJÉ Ñ
ifKK 

(KK 
cKK 
isKK 
notKK 
nullKK 
&&KK 
!KK 
cKK 
.KK  
IsActiveKK  (
)KK( )
returnKK* 0

StatusCodeKK1 ;
(KK; <
$numKK< ?
,KK? @
newKKA D
{KKE F
messageKKG N
=KKO P
$str	KKQ Ñ
}
KKÖ Ü
)
KKÜ á
;
KKá à
returnLL 
AuthControllerLL 
.LL 

SessionForLL (
(LL( )
jwtLL) ,
,LL, -
uLL. /
,LL/ 0
cLL1 2
)LL2 3
;LL3 4
}MM 
boolOO 
WithinLimitOO	 
(OO 
stringOO 
emailOO !
)OO! "
{PP 
varQQ 
sentQQ 
=QQ 
cacheQQ 
.QQ 
GetOrCreateQQ $
(QQ$ %
$strQQ% 2
+QQ3 4
emailQQ5 :
,QQ: ;
eQQ< =
=>QQ> @
{QQA B
eQQC D
.QQD E+
AbsoluteExpirationRelativeToNowQQE d
=QQe f
LifetimeQQg o
;QQo p
returnQQq w
newQQx {
	SentLinks	QQ| Ö
(
QQÖ Ü
)
QQÜ á
;
QQá à
}
QQâ ä
)
QQä ã
!
QQã å
;
QQå ç
returnRR 
InterlockedRR 
.RR 
	IncrementRR $
(RR$ %
refRR% (
sentRR) -
.RR- .
CountRR. 3
)RR3 4
<=RR5 7
MaxLinksPerWindowRR8 I
;RRI J
}SS 
staticUU 

stringUU 
HashUU 
(UU 
stringUU 
tokenUU #
)UU# $
=>UU% '
ConvertUU( /
.UU/ 0
ToHexStringUU0 ;
(UU; <
SHA256UU< B
.UUB C
HashDataUUC K
(UUK L
EncodingUUL T
.UUT U
UTF8UUU Y
.UUY Z
GetBytesUUZ b
(UUb c
tokenUUc h
)UUh i
)UUi j
)UUj k
;UUk l
}VV Ωî
QC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\LearningVideosController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str 
) 
] 
public 
sealed 
partial 
class $
LearningVideosController 4
(4 5
RtresDbContext5 C
dbD F
)F G
:H I
ControllerBaseJ X
{ 
[ 
HttpGet 
( 
$str %
)% &
]& '
public 

async 
Task 
< 
ActionResult "
>" #
PublicVideos$ 0
(0 1
string1 7
locale8 >
,> ?
CancellationToken@ Q
ctR T
)T U
{ 
if 

( 
locale 
is 
not 
( 
$str 
or  "
$str# '
or( *
$str+ /
)/ 0
)0 1
return2 8
NotFound9 A
(A B
)B C
;C D
return 
Ok 
( 
await 
db 
. 
LearningVideos )
.) *
Where* /
(/ 0
x0 1
=>2 4
x5 6
.6 7
IsPublished7 B
&&C E
(F G
xG H
.H I
LanguageI Q
==R T
nullU Y
||Z \
x] ^
.^ _
Language_ g
==h j
localek q
)q r
)r s
. 
OrderBy 
( 
x 
=> 
x 
. 
	SortOrder %
)% &
.& '
ThenByDescending' 7
(7 8
x8 9
=>: <
x= >
.> ?
	CreatedAt? H
)H I
. 
Select 
( 
x 
=> 
new 
PublicVideoDto +
(+ ,
x, -
.- .
	YoutubeId. 7
,7 8
x9 :
.: ;
Title; @
,@ A
xB C
.C D
CategoryD L
,L M
xN O
.O P
DescriptionP [
)[ \
)\ ]
.] ^
ToListAsync^ i
(i j
ctj l
)l m
)m n
;n o
} 
[ 
HttpGet 
( 
$str $
)$ %
,% &
	Authorize' 0
(0 1
Roles1 6
=7 8
$str9 E
)E F
]F G
public 

async 
Task 
< 
ActionResult "
>" #
List$ (
(( )
CancellationToken) :
ct; =
)= >
=>? A
Ok 

(
 
await 
db 
. 
LearningVideos "
." #
OrderBy# *
(* +
x+ ,
=>- /
x0 1
.1 2
	SortOrder2 ;
); <
.< =
ThenByDescending= M
(M N
xN O
=>P R
xS T
.T U
	CreatedAtU ^
)^ _
._ `
Select` f
(f g
xg h
=>i k
ToDtol q
(q r
xr s
)s t
)t u
.u v
ToListAsync	v Å
(
Å Ç
ct
Ç Ñ
)
Ñ Ö
)
Ö Ü
;
Ü á
[ 
HttpPost 
( 
$str %
)% &
,& '
	Authorize( 1
(1 2
Roles2 7
=8 9
$str: F
)F G
]G H
public 

async 
Task 
< 
ActionResult "
>" #
Create$ *
(* + 
LearningVideoRequest+ ?
request@ G
,G H
CancellationTokenI Z
ct[ ]
)] ^
{ 
var 
video 
= 
new 
LearningVideo %
{& '
	SortOrder( 1
=2 3
await4 9
db: <
.< =
LearningVideos= K
.K L

CountAsyncL V
(V W
ctW Y
)Y Z
}[ \
;\ ]
if 

( 
Apply 
( 
video 
, 
request  
)  !
is" $
{% &
}' (
error) .
). /
return0 6

BadRequest7 A
(A B
newB E
{F G
messageH O
=P Q
errorR W
}X Y
)Y Z
;Z [
if   

(   
await   
db   
.   
LearningVideos   #
.  # $
AnyAsync  $ ,
(  , -
x  - .
=>  / 1
x  2 3
.  3 4
	YoutubeId  4 =
==  > @
video  A F
.  F G
	YoutubeId  G P
,  P Q
ct  R T
)  T U
)  U V
return  W ]
Conflict  ^ f
(  f g
new  g j
{  k l
message  m t
=  u v
$str	  w ó
}
  ò ô
)
  ô ö
;
  ö õ
db!! 

.!!
 
LearningVideos!! 
.!! 
Add!! 
(!! 
video!! #
)!!# $
;!!$ %
await!!& +
db!!, .
.!!. /
SaveChangesAsync!!/ ?
(!!? @
ct!!@ B
)!!B C
;!!C D
return"" 
Created"" 
("" 
$""" 
$str"" 4
{""4 5
video""5 :
."": ;
Id""; =
}""= >
"""> ?
,""? @
ToDto""A F
(""F G
video""G L
)""L M
)""M N
;""N O
}## 
[%% 
HttpPut%% 
(%% 
$str%% .
)%%. /
,%%/ 0
	Authorize%%1 :
(%%: ;
Roles%%; @
=%%A B
$str%%C O
)%%O P
]%%P Q
public&& 

async&& 
Task&& 
<&& 
ActionResult&& "
>&&" #
Update&&$ *
(&&* +
Guid&&+ /
id&&0 2
,&&2 3 
LearningVideoRequest&&4 H
request&&I P
,&&P Q
CancellationToken&&R c
ct&&d f
)&&f g
{'' 
var(( 
video(( 
=(( 
await(( 
db(( 
.(( 
LearningVideos(( +
.((+ ,
	FindAsync((, 5
(((5 6
[((6 7
id((7 9
]((9 :
,((: ;
ct((< >
)((> ?
;((? @
if((A C
(((D E
video((E J
is((K M
null((N R
)((R S
return((T Z
NotFound(([ c
(((c d
)((d e
;((e f
if)) 

()) 
Apply)) 
()) 
video)) 
,)) 
request))  
)))  !
is))" $
{))% &
}))' (
error))) .
))). /
return))0 6

BadRequest))7 A
())A B
new))B E
{))F G
message))H O
=))P Q
error))R W
}))X Y
)))Y Z
;))Z [
if** 

(** 
await** 
db** 
.** 
LearningVideos** #
.**# $
AnyAsync**$ ,
(**, -
x**- .
=>**/ 1
x**2 3
.**3 4
Id**4 6
!=**7 9
id**: <
&&**= ?
x**@ A
.**A B
	YoutubeId**B K
==**L N
video**O T
.**T U
	YoutubeId**U ^
,**^ _
ct**` b
)**b c
)**c d
return**e k
Conflict**l t
(**t u
new**u x
{**y z
message	**{ Ç
=
**É Ñ
$str
**Ö •
}
**¶ ß
)
**ß ®
;
**® ©
await++ 
db++ 
.++ 
SaveChangesAsync++ !
(++! "
ct++" $
)++$ %
;++% &
return++' -
Ok++. 0
(++0 1
ToDto++1 6
(++6 7
video++7 <
)++< =
)++= >
;++> ?
},, 
[.. 

HttpDelete.. 
(.. 
$str.. 1
)..1 2
,..2 3
	Authorize..4 =
(..= >
Roles..> C
=..D E
$str..F R
)..R S
]..S T
public// 

async// 
Task// 
<// 
ActionResult// "
>//" #
Delete//$ *
(//* +
Guid//+ /
id//0 2
,//2 3
CancellationToken//4 E
ct//F H
)//H I
{00 
var11 
video11 
=11 
await11 
db11 
.11 
LearningVideos11 +
.11+ ,
	FindAsync11, 5
(115 6
[116 7
id117 9
]119 :
,11: ;
ct11< >
)11> ?
;11? @
if11A C
(11D E
video11E J
is11K M
null11N R
)11R S
return11T Z
NotFound11[ c
(11c d
)11d e
;11e f
db22 

.22
 
LearningVideos22 
.22 
Remove22  
(22  !
video22! &
)22& '
;22' (
await22) .
db22/ 1
.221 2
SaveChangesAsync222 B
(22B C
ct22C E
)22E F
;22F G
return22H N
	NoContent22O X
(22X Y
)22Y Z
;22Z [
}33 
[66 
HttpPost66 
(66 
$str66 -
)66- .
,66. /
	Authorize660 9
(669 :
Roles66: ?
=66@ A
$str66B N
)66N O
]66O P
public77 

async77 
Task77 
<77 
ActionResult77 "
>77" #
Reorder77$ +
(77+ ,
IReadOnlyList77, 9
<779 :
Guid77: >
>77> ?
ids77@ C
,77C D
CancellationToken77E V
ct77W Y
)77Y Z
{88 
var99 
videos99 
=99 
await99 
db99 
.99 
LearningVideos99 ,
.99, -
ToListAsync99- 8
(998 9
ct999 ;
)99; <
;99< =
foreach:: 
(:: 
var:: 
v:: 
in:: 
videos::  
)::  !
v::" #
.::# $
	SortOrder::$ -
=::. /
ids::0 3
.::3 4
Contains::4 <
(::< =
v::= >
.::> ?
Id::? A
)::A B
?::C D
ids::E H
.::H I
ToList::I O
(::O P
)::P Q
.::Q R
IndexOf::R Y
(::Y Z
v::Z [
.::[ \
Id::\ ^
)::^ _
:::` a
ids::b e
.::e f
Count::f k
+::l m
v::n o
.::o p
	SortOrder::p y
;::y z
await;; 
db;; 
.;; 
SaveChangesAsync;; !
(;;! "
ct;;" $
);;$ %
;;;% &
return;;' -
	NoContent;;. 7
(;;7 8
);;8 9
;;;9 :
}<< 
private>> 
static>> 
string>> 
?>> 
Apply>>  
(>>  !
LearningVideo>>! .
video>>/ 4
,>>4 5 
LearningVideoRequest>>6 J
r>>K L
)>>L M
{?? 
if@@ 

(@@ 
ParseYoutubeId@@ 
(@@ 
r@@ 
.@@ 
Url@@  
)@@  !
is@@" $
not@@% (
{@@) *
}@@+ ,
	youtubeId@@- 6
)@@6 7
return@@8 >
$str	@@? è
;
@@è ê
ifAA 

(AA 
stringAA 
.AA 
IsNullOrWhiteSpaceAA %
(AA% &
rAA& '
.AA' (
TitleAA( -
)AA- .
)AA. /
returnAA0 6
$strAA7 R
;AAR S
ifBB 

(BB 
stringBB 
.BB 
IsNullOrWhiteSpaceBB %
(BB% &
rBB& '
.BB' (
CategoryBB( 0
)BB0 1
)BB1 2
returnBB3 9
$strBB: X
;BBX Y
varCC 
languageCC 
=CC 
stringCC 
.CC 
IsNullOrWhiteSpaceCC 0
(CC0 1
rCC1 2
.CC2 3
LanguageCC3 ;
)CC; <
?CC= >
nullCC? C
:CCD E
rCCF G
.CCG H
LanguageCCH P
.CCP Q
TrimCCQ U
(CCU V
)CCV W
.CCW X
ToLowerInvariantCCX h
(CCh i
)CCi j
;CCj k
ifDD 

(DD 
languageDD 
isDD 
notDD 
(DD 
nullDD !
orDD" $
$strDD% )
orDD* ,
$strDD- 1
orDD2 4
$strDD5 9
)DD9 :
)DD: ;
returnDD< B
$strDDC t
;DDt u
videoEE 
.EE 
	YoutubeIdEE 
=EE 
	youtubeIdEE #
;EE# $
videoEE% *
.EE* +
TitleEE+ 0
=EE1 2
rEE3 4
.EE4 5
TitleEE5 :
.EE: ;
TrimEE; ?
(EE? @
)EE@ A
;EEA B
videoEEC H
.EEH I
CategoryEEI Q
=EER S
rEET U
.EEU V
CategoryEEV ^
.EE^ _
TrimEE_ c
(EEc d
)EEd e
;EEe f
videoEEg l
.EEl m
LanguageEEm u
=EEv w
language	EEx Ä
;
EEÄ Å
videoFF 
.FF 
DescriptionFF 
=FF 
stringFF "
.FF" #
IsNullOrWhiteSpaceFF# 5
(FF5 6
rFF6 7
.FF7 8
DescriptionFF8 C
)FFC D
?FFE F
nullFFG K
:FFL M
rFFN O
.FFO P
DescriptionFFP [
.FF[ \
TrimFF\ `
(FF` a
)FFa b
;FFb c
videoFFd i
.FFi j
IsPublishedFFj u
=FFv w
rFFx y
.FFy z
IsPublished	FFz Ö
;
FFÖ Ü
returnGG 
nullGG 
;GG 
}HH 
publicKK 

staticKK 
stringKK 
?KK 
ParseYoutubeIdKK (
(KK( )
stringKK) /
?KK/ 0
inputKK1 6
)KK6 7
{LL 
ifMM 

(MM 
stringMM 
.MM 
IsNullOrWhiteSpaceMM %
(MM% &
inputMM& +
)MM+ ,
)MM, -
returnMM. 4
nullMM5 9
;MM9 :
varNN 
valueNN 
=NN 
inputNN 
.NN 
TrimNN 
(NN 
)NN  
;NN  !
ifOO 

(OO 
YoutubeIdRegexOO 
(OO 
)OO 
.OO 
IsMatchOO $
(OO$ %
valueOO% *
)OO* +
)OO+ ,
returnOO- 3
valueOO4 9
;OO9 :
varPP 
matchPP 
=PP 
YoutubeUrlRegexPP #
(PP# $
)PP$ %
.PP% &
MatchPP& +
(PP+ ,
valuePP, 1
)PP1 2
;PP2 3
returnQQ 
matchQQ 
.QQ 
SuccessQQ 
?QQ 
matchQQ $
.QQ$ %
GroupsQQ% +
[QQ+ ,
$strQQ, 0
]QQ0 1
.QQ1 2
ValueQQ2 7
:QQ8 9
nullQQ: >
;QQ> ?
}RR 
[TT 
GeneratedRegexTT 
(TT 
$strTT )
)TT) *
]TT* +
privateUU 
staticUU 
partialUU 
RegexUU  
YoutubeIdRegexUU! /
(UU/ 0
)UU0 1
;UU1 2
[WW 
GeneratedRegexWW 
(WW 
$str	WW ®
,
WW® ©
RegexOptions
WW™ ∂
.
WW∂ ∑

IgnoreCase
WW∑ ¡
)
WW¡ ¬
]
WW¬ √
privateXX 
staticXX 
partialXX 
RegexXX  
YoutubeUrlRegexXX! 0
(XX0 1
)XX1 2
;XX2 3
privateZZ 
staticZZ 
LearningVideoDtoZZ #
ToDtoZZ$ )
(ZZ) *
LearningVideoZZ* 7
xZZ8 9
)ZZ9 :
=>ZZ; =
newZZ> A
(ZZA B
xZZB C
.ZZC D
IdZZD F
,ZZF G
xZZH I
.ZZI J
	YoutubeIdZZJ S
,ZZS T
xZZU V
.ZZV W
TitleZZW \
,ZZ\ ]
xZZ^ _
.ZZ_ `
CategoryZZ` h
,ZZh i
xZZj k
.ZZk l
LanguageZZl t
,ZZt u
xZZv w
.ZZw x
Description	ZZx É
,
ZZÉ Ñ
x
ZZÖ Ü
.
ZZÜ á
	SortOrder
ZZá ê
,
ZZê ë
x
ZZí ì
.
ZZì î
IsPublished
ZZî ü
)
ZZü †
;
ZZ† °
}[[ 
public]] 
sealed]] 
record]]  
LearningVideoRequest]] )
(]]) *
string]]* 0
Url]]1 4
,]]4 5
string]]6 <
Title]]= B
,]]B C
string]]D J
Category]]K S
,]]S T
string]]U [
?]][ \
Language]]] e
,]]e f
string]]g m
?]]m n
Description]]o z
,]]z {
bool	]]| Ä
IsPublished
]]Å å
=
]]ç é
true
]]è ì
)
]]ì î
;
]]î ï
public^^ 
sealed^^ 
record^^ 
LearningVideoDto^^ %
(^^% &
Guid^^& *
Id^^+ -
,^^- .
string^^/ 5
	YoutubeId^^6 ?
,^^? @
string^^A G
Title^^H M
,^^M N
string^^O U
Category^^V ^
,^^^ _
string^^` f
?^^f g
Language^^h p
,^^p q
string^^r x
?^^x y
Description	^^z Ö
,
^^Ö Ü
int
^^á ä
	SortOrder
^^ã î
,
^^î ï
bool
^^ñ ö
IsPublished
^^õ ¶
)
^^¶ ß
;
^^ß ®
public__ 
sealed__ 
record__ 
PublicVideoDto__ #
(__# $
string__$ *
	YoutubeId__+ 4
,__4 5
string__6 <
Title__= B
,__B C
string__D J
Category__K S
,__S T
string__U [
?__[ \
Description__] h
)__h i
;__i j∂
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\GitHubWebhookController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str +
)+ ,
], -
public		 
sealed		 
class		 #
GitHubWebhookController		 +
(		+ ,"
GitHubWebhookProcessor		, B
	processor		C L
,		L M
IConfiguration		N \
configuration		] j
,		j k
ILogger		l s
<		s t$
GitHubWebhookController			t ã
>
		ã å
logger
		ç ì
)
		ì î
:
		ï ñ
ControllerBase
		ó •
{

 
[ 
HttpPost 
] 
public 

async 
Task 
< 
ActionResult "
>" #
Receive$ +
(+ ,
[, -

FromHeader- 7
(7 8
Name8 <
== >
$str? O
)O P
]P Q
stringR X
?X Y
	eventNameZ c
,c d
[e f

FromHeaderf p
(p q
Nameq u
=v w
$str	x ç
)
ç é
]
é è
string
ê ñ
?
ñ ó
	signature
ò °
,
° ¢
CancellationToken
£ ¥
ct
µ ∑
)
∑ ∏
{ 
using 
var 
buffer 
= 
new 
MemoryStream +
(+ ,
), -
;- .
await 
Request 
. 
Body 
. 
CopyToAsync &
(& '
buffer' -
,- .
ct/ 1
)1 2
;2 3
var 
body 
= 
buffer 
. 
ToArray !
(! "
)" #
;# $
var 
secret 
= 
configuration "
[" #
$str# 9
]9 :
??; =
string> D
.D E
EmptyE J
;J K
if 

( 
! "
GitHubWebhookSignature #
.# $
IsValid$ +
(+ ,
secret, 2
,2 3
body4 8
,8 9
	signature: C
)C D
)D E
{ 	
logger 
. 

LogWarning 
( 
$str q
)q r
;r s
return 
Unauthorized 
(  
)  !
;! "
} 	
if 

( 
	eventName 
== 
$str 
)  
return! '
Ok( *
(* +
)+ ,
;, -
using 
var 
payload 
= 
JsonDocument (
.( )
Parse) .
(. /
body/ 3
)3 4
;4 5
await 
	processor 
. 
ProcessAsync $
($ %
	eventName% .
??/ 1
$str2 4
,4 5
payload6 =
.= >
RootElement> I
,I J
ctK M
)M N
;N O
return 
Ok 
( 
) 
; 
} 
} ﬁn
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\ContactController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str 
) 
] 
public 
sealed 
class 
ContactController %
(% &
RtresDbContext& 4
db5 7
,7 8 
IBackgroundJobClient9 M
jobsN R
)R S
:T U
ControllerBaseV d
{ 
public 

const 
string 
RateLimitPolicy '
=( )
$str* 3
;3 4
public 

static 
readonly 
string !
[! "
]" #
Locales$ +
=, -
[. /
$str/ 3
,3 4
$str5 9
,9 :
$str; ?
]? @
;@ A
[ 
HttpPost 
( 
$str 
) 
,  
EnableRateLimiting! 3
(3 4
RateLimitPolicy4 C
)C D
]D E
public 

async 
Task 
< 
ActionResult "
>" #
Submit$ *
(* +
ContactRequest+ 9
request: A
,A B
CancellationTokenC T
ctU W
)W X
{ 
if 

( 
! 
string 
. 
IsNullOrWhiteSpace &
(& '
request' .
.. /
Website/ 6
)6 7
)7 8
return9 ?
Accepted@ H
(H I
)I J
;J K
var 
name 
= 
request 
. 
Name 
?  
.  !
Trim! %
(% &
)& '
;' (
var) ,
email- 2
=3 4
request5 <
.< =
Email= B
?B C
.C D
TrimD H
(H I
)I J
;J K
varL O
messageP W
=X Y
requestZ a
.a b
Messageb i
?i j
.j k
Trimk o
(o p
)p q
;q r
if 

( 
string 
. 
IsNullOrEmpty  
(  !
name! %
)% &
||' )
name* .
.. /
Length/ 5
>6 7
$num8 ;
); <
return= C

BadRequestD N
(N O
newO R
{S T
fieldU Z
=[ \
$str] c
,c d
messagee l
=m n
$str	o Ç
}
É Ñ
)
Ñ Ö
;
Ö Ü
if 

( 
string 
. 
IsNullOrEmpty  
(  !
email! &
)& '
||( *
email+ 0
.0 1
Length1 7
>8 9
$num: =
||> @
!A B
MailAddressB M
.M N
	TryCreateN W
(W X
emailX ]
,] ^
out_ b
_c d
)d e
)e f
returng m

BadRequestn x
(x y
newy |
{} ~
field	 Ñ
=
Ö Ü
$str
á é
,
é è
message
ê ó
=
ò ô
$str
ö ≥
}
¥ µ
)
µ ∂
;
∂ ∑
if 

( 
string 
. 
IsNullOrEmpty  
(  !
message! (
)( )
||* ,
message- 4
.4 5
Length5 ;
<< =
$num> @
||A C
messageD K
.K L
LengthL R
>S T
$numU Y
)Y Z
return[ a

BadRequestb l
(l m
newm p
{q r
fields x
=y z
$str	{ Ñ
,
Ñ Ö
message
Ü ç
=
é è
$str
ê –
}
— “
)
“ ”
;
” ‘
var   
lead   
=   
new   
ContactLead   "
{!! 	
Name"" 
="" 
name"" 
,"" 
Email"" 
=""  
email""! &
,""& '
Message""( /
=""0 1
message""2 9
,""9 :
Phone## 
=## 
Clip## 
(## 
request##  
.##  !
Phone##! &
,##& '
$num##( *
)##* +
,##+ ,
Company##- 4
=##5 6
Clip##7 ;
(##; <
request##< C
.##C D
Company##D K
,##K L
$num##M P
)##P Q
,##Q R
Service##S Z
=##[ \
Clip##] a
(##a b
request##b i
.##i j
Service##j q
,##q r
$num##s u
)##u v
,##v w
Locale$$ 
=$$ 
Locales$$ 
.$$ 
Contains$$ %
($$% &
request$$& -
.$$- .
Locale$$. 4
)$$4 5
?$$6 7
request$$8 ?
.$$? @
Locale$$@ F
!$$F G
:$$H I
$str$$J N
,$$N O

SourcePage$$P Z
=$$[ \
Clip$$] a
($$a b
request$$b i
.$$i j
Page$$j n
,$$n o
$num$$p s
)$$s t
,$$t u
}%% 	
;%%	 

db&& 

.&&
 
ContactLeads&& 
.&& 
Add&& 
(&& 
lead&&  
)&&  !
;&&! "
await&&# (
db&&) +
.&&+ ,
SaveChangesAsync&&, <
(&&< =
ct&&= ?
)&&? @
;&&@ A
var'' 
data'' 
='' 
new'' 

Dictionary'' !
<''! "
string''" (
,''( )
string''* 0
>''0 1
{''2 3
[''4 5
$str''5 =
]''= >
=''? @
lead''A E
.''E F
Id''F H
.''H I
ToString''I Q
(''Q R
)''R S
,''S T
[''U V
$str''V \
]''\ ]
=''^ _
lead''` d
.''d e
Name''e i
,''i j
[''k l
$str''l s
]''s t
=''u v
lead''w {
.''{ |
Email	''| Å
,
''Å Ç
[
''É Ñ
$str
''Ñ ç
]
''ç é
=
''è ê
lead
''ë ï
.
''ï ñ
Message
''ñ ù
,
''ù û
[
''ü †
$str
''† ®
]
''® ©
=
''™ ´
lead
''¨ ∞
.
''∞ ±
Locale
''± ∑
}
''∏ π
;
''π ∫
if(( 

((( 
lead(( 
.(( 
Phone(( 
is(( 
not(( 
null(( "
)((" #
data(($ (
[((( )
$str(() 0
]((0 1
=((2 3
lead((4 8
.((8 9
Phone((9 >
;((> ?
if)) 

()) 
lead)) 
.)) 
Company)) 
is)) 
not)) 
null))  $
)))$ %
data))& *
[))* +
$str))+ 4
]))4 5
=))6 7
lead))8 <
.))< =
Company))= D
;))D E
if** 

(** 
lead** 
.** 
Service** 
is** 
not** 
null**  $
)**$ %
data**& *
[*** +
$str**+ 4
]**4 5
=**6 7
lead**8 <
.**< =
Service**= D
;**D E
if++ 

(++ 
lead++ 
.++ 

SourcePage++ 
is++ 
not++ "
null++# '
)++' (
data++) -
[++- .
$str++. 4
]++4 5
=++6 7
lead++8 <
.++< =

SourcePage++= G
;++G H
jobs,, 
.,, 
Enqueue,, 
<,, 
StaffNotifier,, "
>,," #
(,,# $
x,,$ %
=>,,& (
x,,) *
.,,* +
	SendAsync,,+ 4
(,,4 5
new,,5 8
Notification,,9 E
(,,E F
NotificationType,,F V
.,,V W
ContactLead,,W b
,,,b c
data,,d h
,,,h i
$",,j l
$str,,l y
{,,y z
lead,,z ~
.,,~ 
Id	,, Å
}
,,Å Ç
"
,,Ç É
,
,,É Ñ
null
,,Ö â
)
,,â ä
,
,,ä ã
CancellationToken
,,å ù
.
,,ù û
None
,,û ¢
)
,,¢ £
)
,,£ §
;
,,§ •
return-- 
Accepted-- 
(-- 
)-- 
;-- 
}.. 
[00 
HttpGet00 
(00 
$str00 
)00 
,00 
	Authorize00 &
(00& '
Roles00' ,
=00- .
$str00/ ;
)00; <
]00< =
public11 

async11 
Task11 
<11 
ActionResult11 "
>11" #
Leads11$ )
(11) *
ContactLeadStatus11* ;
?11; <
status11= C
,11C D
CancellationToken11E V
ct11W Y
)11Y Z
=>11[ ]
Ok22 

(22
 
await22 
db22 
.22 
ContactLeads22  
.22  !
Where22! &
(22& '
x22' (
=>22) +
status22, 2
==223 5
null226 :
||22; =
x22> ?
.22? @
Status22@ F
==22G I
status22J P
)22P Q
.22Q R
OrderByDescending22R c
(22c d
x22d e
=>22f h
x22i j
.22j k
	CreatedAt22k t
)22t u
.22u v
Take22v z
(22z {
$num22{ ~
)22~ 
.	22 Ä
ToListAsync
22Ä ã
(
22ã å
ct
22å é
)
22é è
)
22è ê
;
22ê ë
[44 
	HttpPatch44 
(44 
$str44 &
)44& '
,44' (
	Authorize44) 2
(442 3
Roles443 8
=449 :
$str44; G
)44G H
]44H I
public55 

async55 
Task55 
<55 
ActionResult55 "
>55" #

UpdateLead55$ .
(55. /
Guid55/ 3
id554 6
,556 7
ContactLeadPatch558 H
request55I P
,55P Q
CancellationToken55R c
ct55d f
)55f g
{66 
var77 
lead77 
=77 
await77 
db77 
.77 
ContactLeads77 (
.77( )
	FindAsync77) 2
(772 3
[773 4
id774 6
]776 7
,777 8
ct779 ;
)77; <
;77< =
if77> @
(77A B
lead77B F
is77G I
null77J N
)77N O
return77P V
NotFound77W _
(77_ `
)77` a
;77a b
if88 

(88 
request88 
.88 
Status88 
is88 
ContactLeadStatus88 /
status880 6
)886 7
lead888 <
.88< =
Status88= C
=88D E
status88F L
;88L M
if99 

(99 
request99 
.99 
Notes99 
is99 
not99  
null99! %
)99% &
lead99' +
.99+ ,
Notes99, 1
=992 3
Clip994 8
(998 9
request999 @
.99@ A
Notes99A F
,99F G
$num99H L
)99L M
;99M N
await:: 
db:: 
.:: 
SaveChangesAsync:: !
(::! "
ct::" $
)::$ %
;::% &
return::' -
Ok::. 0
(::0 1
lead::1 5
)::5 6
;::6 7
};; 
private== 
static== 
string== 
?== 
Clip== 
(==  
string==  &
?==& '
value==( -
,==- .
int==/ 2
max==3 6
)==6 7
{>> 
if?? 

(?? 
string?? 
.?? 
IsNullOrWhiteSpace?? %
(??% &
value??& +
)??+ ,
)??, -
return??. 4
null??5 9
;??9 :
var@@ 
trimmed@@ 
=@@ 
value@@ 
.@@ 
Trim@@  
(@@  !
)@@! "
;@@" #
returnAA 
trimmedAA 
.AA 
LengthAA 
>AA 
maxAA  #
?AA$ %
trimmedAA& -
[AA- .
..AA. 0
maxAA0 3
]AA3 4
:AA5 6
trimmedAA7 >
;AA> ?
}BB 
}CC 
publicFF 
sealedFF 
recordFF 
ContactRequestFF #
(FF# $
stringFF$ *
?FF* +
NameFF, 0
,FF0 1
stringFF2 8
?FF8 9
EmailFF: ?
,FF? @
stringFFA G
?FFG H
PhoneFFI N
,FFN O
stringFFP V
?FFV W
CompanyFFX _
,FF_ `
stringFFa g
?FFg h
ServiceFFi p
,FFp q
stringFFr x
?FFx y
Message	FFz Å
,
FFÅ Ç
string
FFÉ â
?
FFâ ä
Locale
FFã ë
,
FFë í
string
FFì ô
?
FFô ö
Page
FFõ ü
,
FFü †
string
FF° ß
?
FFß ®
Website
FF© ∞
=
FF± ≤
null
FF≥ ∑
)
FF∑ ∏
;
FF∏ π
publicGG 
sealedGG 
recordGG 
ContactLeadPatchGG %
(GG% &
ContactLeadStatusGG& 7
?GG7 8
StatusGG9 ?
,GG? @
stringGGA G
?GGG H
NotesGGI N
)GGN O
;GGO P ∏
MC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\CategoriesController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
( 
Roles 
=  !
$str" .
). /
,/ 0
Route1 6
(6 7
$str7 B
)B C
]C D
public 
sealed 
class  
CategoriesController (
(( )
RtresDbContext) 7
db8 :
): ;
:< =
ControllerBase> L
{ 
[ 
HttpGet 
( 
$str !
)! "
]" #
public 

async 
Task 
< 
ActionResult "
>" #
ExpenseCategories$ 5
(5 6
CancellationToken6 G
ctH J
)J K
=>L N
OkO Q
(Q R
awaitR W
dbX Z
.Z [
ExpenseCategories[ l
.l m
OrderBym t
(t u
xu v
=>w y
xz {
.{ |
	SortOrder	| Ö
)
Ö Ü
.
Ü á
ThenBy
á ç
(
ç é
x
é è
=>
ê í
x
ì î
.
î ï
Name
ï ô
)
ô ö
. 	
Select	 
( 
x 
=> 
new 
CategoryDto $
($ %
x% &
.& '
Id' )
,) *
x+ ,
., -
Name- 1
,1 2
x3 4
.4 5
Code5 9
!=: <
null= A
,A B
xC D
.D E
IsIncomeTaxE P
,P Q
dbR T
.T U
ExpensesU ]
.] ^
Count^ c
(c d
ed e
=>f h
ei j
.j k

CategoryIdk u
==v x
xy z
.z {
Id{ }
)} ~
,~ 
x
Ä Å
.
Å Ç
IsDeductible
Ç é
&&
è ë
!
í ì
x
ì î
.
î ï
IsIncomeTax
ï †
)
† °
)
° ¢
.
¢ £
ToListAsync
£ Æ
(
Æ Ø
ct
Ø ±
)
± ≤
)
≤ ≥
;
≥ ¥
[ 
	HttpPatch 
( 
$str 8
)8 9
]9 :
public 

async 
Task 
< 
ActionResult "
>" #(
SetExpenseCategoryDeductible$ @
(@ A
GuidA E
idF H
,H I%
CategoryDeductibleRequestJ c
requestd k
,k l
CancellationTokenm ~
ct	 Å
)
Å Ç
{ 
var 
category 
= 
await 
db 
.  
ExpenseCategories  1
.1 2
	FindAsync2 ;
(; <
[< =
id= ?
]? @
,@ A
ctB D
)D E
;E F
ifG I
(J K
categoryK S
isT V
nullW [
)[ \
return] c
NotFoundd l
(l m
)m n
;n o
if 

( 
category 
. 
IsIncomeTax  
&&! #
request$ +
.+ ,
IsDeductible, 8
)8 9
return: @

BadRequestA K
(K L
newL O
{P Q
messageR Y
=Z [
$str	\ à
}
â ä
)
ä ã
;
ã å
category 
. 
IsDeductible 
= 
request  '
.' (
IsDeductible( 4
;4 5
await6 ;
db< >
.> ?
SaveChangesAsync? O
(O P
ctP R
)R S
;S T
returnU [
	NoContent\ e
(e f
)f g
;g h
} 
[ 
HttpPost 
( 
$str "
)" #
]# $
public 

async 
Task 
< 
ActionResult "
>" #!
CreateExpenseCategory$ 9
(9 :
CategoryRequest: I
requestJ Q
,Q R
CancellationTokenS d
cte g
)g h
{ 
if 

( 
await 
ValidateNameAsync #
(# $
request$ +
.+ ,
Name, 0
,0 1
db2 4
.4 5
ExpenseCategories5 F
.F G
SelectG M
(M N
xN O
=>P R
xS T
.T U
NameU Y
)Y Z
,Z [
ct\ ^
)^ _
is` b
{c d
}e f
errorg l
)l m
returnn t
erroru z
;z {
var 
category 
= 
new 
ExpenseCategory *
{+ ,
Name- 1
=2 3
request4 ;
.; <
Name< @
.@ A
TrimA E
(E F
)F G
,G H
	SortOrderI R
=S T
awaitU Z
db[ ]
.] ^
ExpenseCategories^ o
.o p

CountAsyncp z
(z {
ct{ }
)} ~
}	 Ä
;
Ä Å
db   

.  
 
ExpenseCategories   
.   
Add    
(    !
category  ! )
)  ) *
;  * +
await  , 1
db  2 4
.  4 5
SaveChangesAsync  5 E
(  E F
ct  F H
)  H I
;  I J
return!! 
Created!! 
(!! 
$"!! 
$str!! 7
{!!7 8
category!!8 @
.!!@ A
Id!!A C
}!!C D
"!!D E
,!!E F
new!!G J
CategoryDto!!K V
(!!V W
category!!W _
.!!_ `
Id!!` b
,!!b c
category!!d l
.!!l m
Name!!m q
,!!q r
false!!s x
,!!x y
false!!z 
,	!! Ä
$num
!!Å Ç
)
!!Ç É
)
!!É Ñ
;
!!Ñ Ö
}"" 
[$$ 
	HttpPatch$$ 
($$ 
$str$$ -
)$$- .
]$$. /
public%% 

async%% 
Task%% 
<%% 
ActionResult%% "
>%%" #!
RenameExpenseCategory%%$ 9
(%%9 :
Guid%%: >
id%%? A
,%%A B
CategoryRequest%%C R
request%%S Z
,%%Z [
CancellationToken%%\ m
ct%%n p
)%%p q
{&& 
var'' 
category'' 
='' 
await'' 
db'' 
.''  
ExpenseCategories''  1
.''1 2
	FindAsync''2 ;
(''; <
[''< =
id''= ?
]''? @
,''@ A
ct''B D
)''D E
;''E F
if''G I
(''J K
category''K S
is''T V
null''W [
)''[ \
return''] c
NotFound''d l
(''l m
)''m n
;''n o
if(( 

((( 
await(( 
ValidateNameAsync(( #
(((# $
request(($ +
.((+ ,
Name((, 0
,((0 1
db((2 4
.((4 5
ExpenseCategories((5 F
.((F G
Where((G L
(((L M
x((M N
=>((O Q
x((R S
.((S T
Id((T V
!=((W Y
id((Z \
)((\ ]
.((] ^
Select((^ d
(((d e
x((e f
=>((g i
x((j k
.((k l
Name((l p
)((p q
,((q r
ct((s u
)((u v
is((w y
{((z {
}((| }
error	((~ É
)
((É Ñ
return
((Ö ã
error
((å ë
;
((ë í
category)) 
.)) 
Name)) 
=)) 
request)) 
.))  
Name))  $
.))$ %
Trim))% )
())) *
)))* +
;))+ ,
await))- 2
db))3 5
.))5 6
SaveChangesAsync))6 F
())F G
ct))G I
)))I J
;))J K
return))L R
	NoContent))S \
())\ ]
)))] ^
;))^ _
}** 
[,, 

HttpDelete,, 
(,, 
$str,, .
),,. /
],,/ 0
public-- 

async-- 
Task-- 
<-- 
ActionResult-- "
>--" #!
DeleteExpenseCategory--$ 9
(--9 :
Guid--: >
id--? A
,--A B
CancellationToken--C T
ct--U W
)--W X
{.. 
var// 
category// 
=// 
await// 
db// 
.//  
ExpenseCategories//  1
.//1 2
	FindAsync//2 ;
(//; <
[//< =
id//= ?
]//? @
,//@ A
ct//B D
)//D E
;//E F
if//G I
(//J K
category//K S
is//T V
null//W [
)//[ \
return//] c
NotFound//d l
(//l m
)//m n
;//n o
if00 

(00 
category00 
.00 
Code00 
is00 
not00  
null00! %
)00% &
return00' -
Conflict00. 6
(006 7
new007 :
{00; <
message00= D
=00E F
$"00G I
$str00I J
{00J K
category00K S
.00S T
Name00T X
}00X Y
$str	00Y †
"
00† °
}
00¢ £
)
00£ §
;
00§ •
var11 
used11 
=11 
await11 
db11 
.11 
Expenses11 $
.11$ %

CountAsync11% /
(11/ 0
x110 1
=>112 4
x115 6
.116 7

CategoryId117 A
==11B D
id11E G
,11G H
ct11I K
)11K L
;11L M
if22 

(22 
used22 
>22 
$num22 
)22 
return22 
Conflict22 %
(22% &
new22& )
{22* +
message22, 3
=224 5
$"226 8
$str228 9
{229 :
category22: B
.22B C
Name22C G
}22G H
$str22H P
{22P Q
used22Q U
}22U V
$str22V W
{22W X
(22X Y
used22Y ]
==22^ `
$num22a b
?22c d
$str22e l
:22m n
$str22o w
)22w x
}22x y
$str	22y ¶
"
22¶ ß
}
22® ©
)
22© ™
;
22™ ´
db33 

.33
 
ExpenseCategories33 
.33 
Remove33 #
(33# $
category33$ ,
)33, -
;33- .
await33/ 4
db335 7
.337 8
SaveChangesAsync338 H
(33H I
ct33I K
)33K L
;33L M
return33N T
	NoContent33U ^
(33^ _
)33_ `
;33` a
}44 
[66 
HttpGet66 
(66 
$str66 !
)66! "
]66" #
public77 

async77 
Task77 
<77 
ActionResult77 "
>77" #
ProductCategories77$ 5
(775 6
CancellationToken776 G
ct77H J
)77J K
=>77L N
Ok77O Q
(77Q R
await77R W
db77X Z
.77Z [
ProductCategories77[ l
.77l m
OrderBy77m t
(77t u
x77u v
=>77w y
x77z {
.77{ |
	SortOrder	77| Ö
)
77Ö Ü
.
77Ü á
ThenBy
77á ç
(
77ç é
x
77é è
=>
77ê í
x
77ì î
.
77î ï
Name
77ï ô
)
77ô ö
.88 	
Select88	 
(88 
x88 
=>88 
new88 
CategoryDto88 $
(88$ %
x88% &
.88& '
Id88' )
,88) *
x88+ ,
.88, -
Name88- 1
,881 2
false883 8
,888 9
false88: ?
,88? @
db88A C
.88C D
Products88D L
.88L M
Count88M R
(88R S
p88S T
=>88U W
p88X Y
.88Y Z
Category88Z b
==88c e
x88f g
.88g h
Name88h l
)88l m
)88m n
)88n o
.88o p
ToListAsync88p {
(88{ |
ct88| ~
)88~ 
)	88 Ä
;
88Ä Å
[:: 
HttpPost:: 
(:: 
$str:: "
)::" #
]::# $
public;; 

async;; 
Task;; 
<;; 
ActionResult;; "
>;;" #!
CreateProductCategory;;$ 9
(;;9 :
CategoryRequest;;: I
request;;J Q
,;;Q R
CancellationToken;;S d
ct;;e g
);;g h
{<< 
if== 

(== 
await== 
ValidateNameAsync== #
(==# $
request==$ +
.==+ ,
Name==, 0
,==0 1
db==2 4
.==4 5
ProductCategories==5 F
.==F G
Select==G M
(==M N
x==N O
=>==P R
x==S T
.==T U
Name==U Y
)==Y Z
,==Z [
ct==\ ^
)==^ _
is==` b
{==c d
}==e f
error==g l
)==l m
return==n t
error==u z
;==z {
var>> 
category>> 
=>> 
new>> 
ProductCategory>> *
{>>+ ,
Name>>- 1
=>>2 3
request>>4 ;
.>>; <
Name>>< @
.>>@ A
Trim>>A E
(>>E F
)>>F G
,>>G H
	SortOrder>>I R
=>>S T
await>>U Z
db>>[ ]
.>>] ^
ProductCategories>>^ o
.>>o p

CountAsync>>p z
(>>z {
ct>>{ }
)>>} ~
}	>> Ä
;
>>Ä Å
db?? 

.??
 
ProductCategories?? 
.?? 
Add??  
(??  !
category??! )
)??) *
;??* +
await??, 1
db??2 4
.??4 5
SaveChangesAsync??5 E
(??E F
ct??F H
)??H I
;??I J
return@@ 
Created@@ 
(@@ 
$"@@ 
$str@@ 7
{@@7 8
category@@8 @
.@@@ A
Id@@A C
}@@C D
"@@D E
,@@E F
new@@G J
CategoryDto@@K V
(@@V W
category@@W _
.@@_ `
Id@@` b
,@@b c
category@@d l
.@@l m
Name@@m q
,@@q r
false@@s x
,@@x y
false@@z 
,	@@ Ä
$num
@@Å Ç
)
@@Ç É
)
@@É Ñ
;
@@Ñ Ö
}AA 
[DD 
	HttpPatchDD 
(DD 
$strDD -
)DD- .
]DD. /
publicEE 

asyncEE 
TaskEE 
<EE 
ActionResultEE "
>EE" #!
RenameProductCategoryEE$ 9
(EE9 :
GuidEE: >
idEE? A
,EEA B
CategoryRequestEEC R
requestEES Z
,EEZ [
CancellationTokenEE\ m
ctEEn p
)EEp q
{FF 
varGG 
categoryGG 
=GG 
awaitGG 
dbGG 
.GG  
ProductCategoriesGG  1
.GG1 2
	FindAsyncGG2 ;
(GG; <
[GG< =
idGG= ?
]GG? @
,GG@ A
ctGGB D
)GGD E
;GGE F
ifGGG I
(GGJ K
categoryGGK S
isGGT V
nullGGW [
)GG[ \
returnGG] c
NotFoundGGd l
(GGl m
)GGm n
;GGn o
ifHH 

(HH 
awaitHH 
ValidateNameAsyncHH #
(HH# $
requestHH$ +
.HH+ ,
NameHH, 0
,HH0 1
dbHH2 4
.HH4 5
ProductCategoriesHH5 F
.HHF G
WhereHHG L
(HHL M
xHHM N
=>HHO Q
xHHR S
.HHS T
IdHHT V
!=HHW Y
idHHZ \
)HH\ ]
.HH] ^
SelectHH^ d
(HHd e
xHHe f
=>HHg i
xHHj k
.HHk l
NameHHl p
)HHp q
,HHq r
ctHHs u
)HHu v
isHHw y
{HHz {
}HH| }
error	HH~ É
)
HHÉ Ñ
return
HHÖ ã
error
HHå ë
;
HHë í
varII 
nameII 
=II 
requestII 
.II 
NameII 
.II  
TrimII  $
(II$ %
)II% &
;II& '
foreachJJ 
(JJ 
varJJ 
productJJ 
inJJ 
awaitJJ  %
dbJJ& (
.JJ( )
ProductsJJ) 1
.JJ1 2
WhereJJ2 7
(JJ7 8
xJJ8 9
=>JJ: <
xJJ= >
.JJ> ?
CategoryJJ? G
==JJH J
categoryJJK S
.JJS T
NameJJT X
)JJX Y
.JJY Z
ToListAsyncJJZ e
(JJe f
ctJJf h
)JJh i
)JJi j
productJJk r
.JJr s
CategoryJJs {
=JJ| }
name	JJ~ Ç
;
JJÇ É
categoryKK 
.KK 
NameKK 
=KK 
nameKK 
;KK 
awaitKK #
dbKK$ &
.KK& '
SaveChangesAsyncKK' 7
(KK7 8
ctKK8 :
)KK: ;
;KK; <
returnKK= C
	NoContentKKD M
(KKM N
)KKN O
;KKO P
}LL 
[NN 

HttpDeleteNN 
(NN 
$strNN .
)NN. /
]NN/ 0
publicOO 

asyncOO 
TaskOO 
<OO 
ActionResultOO "
>OO" #!
DeleteProductCategoryOO$ 9
(OO9 :
GuidOO: >
idOO? A
,OOA B
CancellationTokenOOC T
ctOOU W
)OOW X
{PP 
varQQ 
categoryQQ 
=QQ 
awaitQQ 
dbQQ 
.QQ  
ProductCategoriesQQ  1
.QQ1 2
	FindAsyncQQ2 ;
(QQ; <
[QQ< =
idQQ= ?
]QQ? @
,QQ@ A
ctQQB D
)QQD E
;QQE F
ifQQG I
(QQJ K
categoryQQK S
isQQT V
nullQQW [
)QQ[ \
returnQQ] c
NotFoundQQd l
(QQl m
)QQm n
;QQn o
varRR 
usedRR 
=RR 
awaitRR 
dbRR 
.RR 
ProductsRR $
.RR$ %

CountAsyncRR% /
(RR/ 0
xRR0 1
=>RR2 4
xRR5 6
.RR6 7
CategoryRR7 ?
==RR@ B
categoryRRC K
.RRK L
NameRRL P
,RRP Q
ctRRR T
)RRT U
;RRU V
ifSS 

(SS 
usedSS 
>SS 
$numSS 
)SS 
returnSS 
ConflictSS %
(SS% &
newSS& )
{SS* +
messageSS, 3
=SS4 5
$"SS6 8
$strSS8 9
{SS9 :
categorySS: B
.SSB C
NameSSC G
}SSG H
$strSSH P
{SSP Q
usedSSQ U
}SSU V
$strSSV W
{SSW X
(SSX Y
usedSSY ]
==SS^ `
$numSSa b
?SSc d
$strSSe o
:SSp q
$strSSr }
)SS} ~
}SS~ 
$str	SS ¨
"
SS¨ ≠
}
SSÆ Ø
)
SSØ ∞
;
SS∞ ±
dbTT 

.TT
 
ProductCategoriesTT 
.TT 
RemoveTT #
(TT# $
categoryTT$ ,
)TT, -
;TT- .
awaitTT/ 4
dbTT5 7
.TT7 8
SaveChangesAsyncTT8 H
(TTH I
ctTTI K
)TTK L
;TTL M
returnTTN T
	NoContentTTU ^
(TT^ _
)TT_ `
;TT` a
}UU 
privateWW 
asyncWW 
TaskWW 
<WW 
ActionResultWW #
?WW# $
>WW$ %
ValidateNameAsyncWW& 7
(WW7 8
stringWW8 >
?WW> ?
nameWW@ D
,WWD E

IQueryableWWF P
<WWP Q
stringWWQ W
>WWW X
othersWWY _
,WW_ `
CancellationTokenWWa r
ctWWs u
)WWu v
{XX 
ifYY 

(YY 
stringYY 
.YY 
IsNullOrWhiteSpaceYY %
(YY% &
nameYY& *
)YY* +
)YY+ ,
returnYY- 3

BadRequestYY4 >
(YY> ?
newYY? B
{YYC D
messageYYE L
=YYM N
$strYYO j
}YYk l
)YYl m
;YYm n
ifZZ 

(ZZ 
nameZZ 
.ZZ 
TrimZZ 
(ZZ 
)ZZ 
.ZZ 
LengthZZ 
>ZZ  
$numZZ! $
)ZZ$ %
returnZZ& ,

BadRequestZZ- 7
(ZZ7 8
newZZ8 ;
{ZZ< =
messageZZ> E
=ZZF G
$strZZH p
}ZZq r
)ZZr s
;ZZs t
var[[ 
folded[[ 
=[[ 
AdminController[[ $
.[[$ %
Fold[[% )
([[) *
name[[* .
)[[. /
;[[/ 0
if\\ 

(\\ 
(\\ 
await\\ 
others\\ 
.\\ 
ToListAsync\\ %
(\\% &
ct\\& (
)\\( )
)\\) *
.\\* +
Any\\+ .
(\\. /
x\\/ 0
=>\\1 3
AdminController\\4 C
.\\C D
Fold\\D H
(\\H I
x\\I J
)\\J K
==\\L N
folded\\O U
)\\U V
)\\V W
return\\X ^
Conflict\\_ g
(\\g h
new\\h k
{\\l m
message\\n u
=\\v w
$"\\x z
$str	\\z ì
{
\\ì î
name
\\î ò
.
\\ò ô
Trim
\\ô ù
(
\\ù û
)
\\û ü
}
\\ü †
$str
\\† ¢
"
\\¢ £
}
\\§ •
)
\\• ¶
;
\\¶ ß
return]] 
null]] 
;]] 
}^^ 
}__ 
publicaa 
sealedaa 
recordaa 
CategoryDtoaa  
(aa  !
Guidaa! %
Idaa& (
,aa( )
stringaa* 0
Nameaa1 5
,aa5 6
boolaa7 ;
IsSystemaa< D
,aaD E
boolaaF J
IsIncomeTaxaaK V
,aaV W
intaaX [

UsageCountaa\ f
,aaf g
boolaah l
IsDeductibleaam y
=aaz {
true	aa| Ä
)
aaÄ Å
;
aaÅ Ç
publicbb 
sealedbb 
recordbb %
CategoryDeductibleRequestbb .
(bb. /
[bb/ 0
propertybb0 8
:bb8 9
JsonRequiredbb: F
]bbF G
boolbbH L
IsDeductiblebbM Y
)bbY Z
;bbZ [
publiccc 
sealedcc 
recordcc 
CategoryRequestcc $
(cc$ %
stringcc% +
Namecc, 0
)cc0 1
;cc1 2ó´
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\BankTransfersController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
, 
Route  
(  !
$str! &
)& '
]' (
public 
sealed 
partial 
class #
BankTransfersController 3
(3 4
RtresDbContext4 B
dbC E
,E F
BankTransferServiceG Z
	transfers[ d
,d e 
PayPalPaymentServicef z
payments	{ É
,
É Ñ!
INotificationSender
Ö ò
notifications
ô ¶
,
¶ ß
IConfiguration
® ∂
configuration
∑ ƒ
,
ƒ ≈
ILogger
∆ Õ
<
Õ Œ%
BankTransfersController
Œ Â
>
Â Ê
logger
Á Ì
)
Ì Ó
:
Ô 
ControllerBase
Ò ˇ
{ 
public 

const 
long 
MaxReceiptBytes %
=& '
$num( )
** +
$num, 0
*1 2
$num3 7
;7 8
public 

static 
readonly 
string !
[! "
]" #

Currencies$ .
=/ 0
[1 2
$str2 7
,7 8
$str9 >
,> ?
$str@ E
]E F
;F G
private 
static 
readonly 
string "
[" #
]# $
ReceiptTypes% 1
=2 3
[4 5
$str5 A
,A B
$strC N
,N O
$strP \
,\ ]
$str^ j
,j k
$strl }
]} ~
;~ 
private 
Guid 
UserId 
=> 
Guid 
.  
Parse  %
(% &
User& *
.* +
FindFirstValue+ 9
(9 :

ClaimTypes: D
.D E
NameIdentifierE S
)S T
!T U
)U V
;V W
private 
bool 
IsSuperAdmin 
=>  
User! %
.% &
IsInRole& .
(. /
nameof/ 5
(5 6
UserRole6 >
.> ?

SuperAdmin? I
)I J
)J K
;K L
[!! 
HttpGet!! 
(!! 
$str!! 
)!! 
]!!  
public"" 

async"" 
Task"" 
<"" 
ActionResult"" "
>""" #!
EnabledPaymentMethods""$ 9
(""9 :
CancellationToken"": K
ct""L N
)""N O
{""P Q
var""R U
s""V W
=""X Y
await""Z _
	transfers""` i
.""i j
SettingsAsync""j w
(""w x
ct""x z
)""z {
;""{ |
return	""} É
Ok
""Ñ Ü
(
""Ü á
new
""á ä
{
""ã å
payPal
""ç ì
=
""î ï
s
""ñ ó
.
""ó ò
PayPalEnabled
""ò •
,
""• ¶
bankTransfer
""ß ≥
=
""¥ µ
s
""∂ ∑
.
""∑ ∏!
BankTransferEnabled
""∏ À
}
""Ã Õ
)
""Õ Œ
;
""Œ œ
}
""– —
[$$ 
	HttpPatch$$ 
($$ 
$str$$ '
)$$' (
,$$( )
	Authorize$$* 3
($$3 4
Roles$$4 9
=$$: ;
$str$$< H
)$$H I
]$$I J
public%% 

async%% 
Task%% 
<%% 
ActionResult%% "
>%%" #!
UpdatePaymentSettings%%$ 9
(%%9 :"
PaymentSettingsRequest%%: P
request%%Q X
,%%X Y
CancellationToken%%Z k
ct%%l n
)%%n o
{&& 
var'' 
settings'' 
='' 
await'' 
	transfers'' &
.''& '
SettingsAsync''' 4
(''4 5
ct''5 7
)''7 8
;''8 9
var(( 
payPal(( 
=(( 
request(( 
.(( 
PayPal(( #
??(($ &
settings((' /
.((/ 0
PayPalEnabled((0 =
;((= >
var((? B
bank((C G
=((H I
request((J Q
.((Q R
BankTransfer((R ^
??((_ a
settings((b j
.((j k
BankTransferEnabled((k ~
;((~ 
if)) 

()) 
!)) 
payPal)) 
&&)) 
!)) 
bank)) 
))) 
return)) $

BadRequest))% /
())/ 0
new))0 3
{))4 5
message))6 =
=))> ?
$str	))@ î
}
))ï ñ
)
))ñ ó
;
))ó ò
if** 

(** 
bank** 
&&** 
!** 
settings** 
.** 
BankTransferEnabled** 1
&&**2 4
!**5 6
await**6 ;
db**< >
.**> ?
BankAccounts**? K
.**K L
AnyAsync**L T
(**T U
x**U V
=>**W Y
x**Z [
.**[ \
IsActive**\ d
,**d e
ct**f h
)**h i
)**i j
return**k q

BadRequest**r |
(**| }
new	**} Ä
{
**Å Ç
message
**É ä
=
**ã å
$str
**ç ﬁ
}
**ﬂ ‡
)
**‡ ·
;
**· ‚
(++ 	
settings++	 
.++ 
PayPalEnabled++ 
,++  
settings++! )
.++) *
BankTransferEnabled++* =
,++= >
settings++? G
.++G H
	UpdatedAt++H Q
)++Q R
=++S T
(++U V
payPal++V \
,++\ ]
bank++^ b
,++b c
DateTime++d l
.++l m
UtcNow++m s
)++s t
;++t u
await,, 
db,, 
.,, 
SaveChangesAsync,, !
(,,! "
ct,," $
),,$ %
;,,% &
return-- 
Ok-- 
(-- 
new-- 
{-- 
payPal-- 
,-- 
bankTransfer--  ,
=--- .
bank--/ 3
}--4 5
)--5 6
;--6 7
}.. 
[22 
HttpGet22 
(22 
$str22 "
)22" #
,22# $
	Authorize22% .
(22. /
Roles22/ 4
=225 6
$str227 C
)22C D
]22D E
public33 

async33 
Task33 
<33 
ActionResult33 "
>33" #
Accounts33$ ,
(33, -
CancellationToken33- >
ct33? A
)33A B
=>33C E
Ok44 

(44
 
(44 
await44 
db44 
.44 
BankAccounts44 !
.44! "
OrderBy44" )
(44) *
x44* +
=>44, .
x44/ 0
.440 1
	SortOrder441 :
)44: ;
.44; <
ThenBy44< B
(44B C
x44C D
=>44E G
x44H I
.44I J
Currency44J R
)44R S
.44S T
ThenBy44T Z
(44Z [
x44[ \
=>44] _
x44` a
.44a b
BankName44b j
)44j k
.44k l
ToListAsync44l w
(44w x
ct44x z
)44z {
)44{ |
.44| }
Select	44} É
(
44É Ñ
x
44Ñ Ö
=>
44Ü à
BankAccountDto
44â ó
.
44ó ò
From
44ò ú
(
44ú ù
x
44ù û
)
44û ü
)
44ü †
)
44† °
;
44° ¢
[66 
HttpPost66 
(66 
$str66 #
)66# $
,66$ %
	Authorize66& /
(66/ 0
Roles660 5
=666 7
$str668 D
)66D E
]66E F
public77 

async77 
Task77 
<77 
ActionResult77 "
>77" #
CreateAccount77$ 1
(771 2
BankAccountRequest772 D
request77E L
,77L M
CancellationToken77N _
ct77` b
)77b c
{88 
var99 
account99 
=99 
new99 
BankAccount99 %
{99& '
	SortOrder99( 1
=992 3
await994 9
db99: <
.99< =
BankAccounts99= I
.99I J

CountAsync99J T
(99T U
ct99U W
)99W X
}99Y Z
;99Z [
if:: 

(:: 
Apply:: 
(:: 
account:: 
,:: 
request:: "
)::" #
is::$ &
string::' -
error::. 3
)::3 4
return::5 ;

BadRequest::< F
(::F G
new::G J
{::K L
message::M T
=::U V
error::W \
}::] ^
)::^ _
;::_ `
if;; 

(;; 
await;; 
DuplicateAsync;;  
(;;  !
account;;! (
,;;( )
ct;;* ,
);;, -
);;- .
return;;/ 5
Conflict;;6 >
(;;> ?
new;;? B
{;;C D
message;;E L
=;;M N
$str;;O o
};;p q
);;q r
;;;r s
db<< 

.<<
 
BankAccounts<< 
.<< 
Add<< 
(<< 
account<< #
)<<# $
;<<$ %
await<<& +
db<<, .
.<<. /
SaveChangesAsync<</ ?
(<<? @
ct<<@ B
)<<B C
;<<C D
return== 
Created== 
(== 
$"== 
$str== 2
{==2 3
account==3 :
.==: ;
Id==; =
}=== >
"==> ?
,==? @
BankAccountDto==A O
.==O P
From==P T
(==T U
account==U \
)==\ ]
)==] ^
;==^ _
}>> 
[@@ 
HttpPut@@ 
(@@ 
$str@@ ,
)@@, -
,@@- .
	Authorize@@/ 8
(@@8 9
Roles@@9 >
=@@? @
$str@@A M
)@@M N
]@@N O
publicAA 

asyncAA 
TaskAA 
<AA 
ActionResultAA "
>AA" #
UpdateAccountAA$ 1
(AA1 2
GuidAA2 6
idAA7 9
,AA9 :
BankAccountRequestAA; M
requestAAN U
,AAU V
CancellationTokenAAW h
ctAAi k
)AAk l
{BB 
varCC 
accountCC 
=CC 
awaitCC 
dbCC 
.CC 
BankAccountsCC +
.CC+ ,
	FindAsyncCC, 5
(CC5 6
[CC6 7
idCC7 9
]CC9 :
,CC: ;
ctCC< >
)CC> ?
;CC? @
ifCCA C
(CCD E
accountCCE L
isCCM O
nullCCP T
)CCT U
returnCCV \
NotFoundCC] e
(CCe f
)CCf g
;CCg h
ifDD 

(DD 
ApplyDD 
(DD 
accountDD 
,DD 
requestDD "
)DD" #
isDD$ &
stringDD' -
errorDD. 3
)DD3 4
returnDD5 ;

BadRequestDD< F
(DDF G
newDDG J
{DDK L
messageDDM T
=DDU V
errorDDW \
}DD] ^
)DD^ _
;DD_ `
ifEE 

(EE 
awaitEE 
DuplicateAsyncEE  
(EE  !
accountEE! (
,EE( )
ctEE* ,
)EE, -
)EE- .
returnEE/ 5
ConflictEE6 >
(EE> ?
newEE? B
{EEC D
messageEEE L
=EEM N
$strEEO o
}EEp q
)EEq r
;EEr s
ifFF 

(FF 
!FF 
accountFF 
.FF 
IsActiveFF 
&&FF  
awaitFF! &0
$LastActiveAccountWithTransferOnAsyncFF' K
(FFK L
accountFFL S
.FFS T
IdFFT V
,FFV W
ctFFX Z
)FFZ [
)FF[ \
returnFF] c

BadRequestFFd n
(FFn o
newFFo r
{FFs t
messageFFu |
=FF} ~
$str	FF Ù
}
FFı ˆ
)
FFˆ ˜
;
FF˜ ¯
awaitGG 
dbGG 
.GG 
SaveChangesAsyncGG !
(GG! "
ctGG" $
)GG$ %
;GG% &
returnHH 
OkHH 
(HH 
BankAccountDtoHH  
.HH  !
FromHH! %
(HH% &
accountHH& -
)HH- .
)HH. /
;HH/ 0
}II 
[LL 

HttpDeleteLL 
(LL 
$strLL /
)LL/ 0
,LL0 1
	AuthorizeLL2 ;
(LL; <
RolesLL< A
=LLB C
$strLLD P
)LLP Q
]LLQ R
publicMM 

asyncMM 
TaskMM 
<MM 
ActionResultMM "
>MM" #
DeleteAccountMM$ 1
(MM1 2
GuidMM2 6
idMM7 9
,MM9 :
CancellationTokenMM; L
ctMMM O
)MMO P
{NN 
varOO 
accountOO 
=OO 
awaitOO 
dbOO 
.OO 
BankAccountsOO +
.OO+ ,
	FindAsyncOO, 5
(OO5 6
[OO6 7
idOO7 9
]OO9 :
,OO: ;
ctOO< >
)OO> ?
;OO? @
ifOOA C
(OOD E
accountOOE L
isOOM O
nullOOP T
)OOT U
returnOOV \
NotFoundOO] e
(OOe f
)OOf g
;OOg h
ifPP 

(PP 
awaitPP 
dbPP 
.PP 
TransferReportsPP $
.PP$ %
AnyAsyncPP% -
(PP- .
xPP. /
=>PP0 2
xPP3 4
.PP4 5
BankAccountIdPP5 B
==PPC E
idPPF H
,PPH I
ctPPJ L
)PPL M
)PPM N
returnPPO U
ConflictPPV ^
(PP^ _
newPP_ b
{PPc d
messagePPe l
=PPm n
$str	PPo ∏
}
PPπ ∫
)
PP∫ ª
;
PPª º
ifQQ 

(QQ 
accountQQ 
.QQ 
IsActiveQQ 
&&QQ 
awaitQQ  %0
$LastActiveAccountWithTransferOnAsyncQQ& J
(QQJ K
idQQK M
,QQM N
ctQQO Q
)QQQ R
)QQR S
returnQQT Z

BadRequestQQ[ e
(QQe f
newQQf i
{QQj k
messageQQl s
=QQt u
$str	QQv Î
}
QQÏ Ì
)
QQÌ Ó
;
QQÓ Ô
dbRR 

.RR
 
BankAccountsRR 
.RR 
RemoveRR 
(RR 
accountRR &
)RR& '
;RR' (
awaitRR) .
dbRR/ 1
.RR1 2
SaveChangesAsyncRR2 B
(RRB C
ctRRC E
)RRE F
;RRF G
returnSS 
	NoContentSS 
(SS 
)SS 
;SS 
}TT 
privateVV 
asyncVV 
TaskVV 
<VV 
boolVV 
>VV 0
$LastActiveAccountWithTransferOnAsyncVV A
(VVA B
GuidVVB F
idVVG I
,VVI J
CancellationTokenVVK \
ctVV] _
)VV_ `
=>VVa c
(WW 	
awaitWW	 
	transfersWW 
.WW 
SettingsAsyncWW &
(WW& '
ctWW' )
)WW) *
)WW* +
.WW+ ,
BankTransferEnabledWW, ?
&&WW@ B
!WWC D
awaitWWD I
dbWWJ L
.WWL M
BankAccountsWWM Y
.WWY Z
AnyAsyncWWZ b
(WWb c
xWWc d
=>WWe g
xWWh i
.WWi j
IsActiveWWj r
&&WWs u
xWWv w
.WWw x
IdWWx z
!=WW{ }
id	WW~ Ä
,
WWÄ Å
ct
WWÇ Ñ
)
WWÑ Ö
;
WWÖ Ü
privateYY 
TaskYY 
<YY 
boolYY 
>YY 
DuplicateAsyncYY %
(YY% &
BankAccountYY& 1
accountYY2 9
,YY9 :
CancellationTokenYY; L
ctYYM O
)YYO P
=>YYQ S
dbZZ 

.ZZ
 
BankAccountsZZ 
.ZZ 
AnyAsyncZZ  
(ZZ  !
xZZ! "
=>ZZ# %
xZZ& '
.ZZ' (
IdZZ( *
!=ZZ+ -
accountZZ. 5
.ZZ5 6
IdZZ6 8
&&ZZ9 ;
xZZ< =
.ZZ= >
BankNameZZ> F
==ZZG I
accountZZJ Q
.ZZQ R
BankNameZZR Z
&&ZZ[ ]
xZZ^ _
.ZZ_ `
AccountNumberZZ` m
==ZZn p
accountZZq x
.ZZx y
AccountNumber	ZZy Ü
,
ZZÜ á
ct
ZZà ä
)
ZZä ã
;
ZZã å
internal\\ 
static\\ 
string\\ 
?\\ 
Apply\\ !
(\\! "
BankAccount\\" -
account\\. 5
,\\5 6
BankAccountRequest\\7 I
r\\J K
)\\K L
{]] 
var^^ 
bank^^ 
=^^ 
r^^ 
.^^ 
BankName^^ 
?^^ 
.^^ 
Trim^^ #
(^^# $
)^^$ %
;^^% &
var^^' *
holder^^+ 1
=^^2 3
r^^4 5
.^^5 6
Holder^^6 <
?^^< =
.^^= >
Trim^^> B
(^^B C
)^^C D
;^^D E
var^^F I
currency^^J R
=^^S T
r^^U V
.^^V W
Currency^^W _
?^^_ `
.^^` a
Trim^^a e
(^^e f
)^^f g
.^^g h
ToUpperInvariant^^h x
(^^x y
)^^y z
;^^z {
var__ 
number__ 
=__ 
Digits__ 
(__ 
r__ 
.__ 
AccountNumber__ +
)__+ ,
;__, -
var__. 1
cci__2 5
=__6 7
Digits__8 >
(__> ?
r__? @
.__@ A
Cci__A D
)__D E
;__E F
if`` 

(`` 
string`` 
.`` 
IsNullOrEmpty``  
(``  !
bank``! %
)``% &
||``' )
string``* 0
.``0 1
IsNullOrEmpty``1 >
(``> ?
holder``? E
)``E F
)``F G
return``H N
$str``O x
;``x y
ifaa 

(aa 
currencyaa 
isaa 
nullaa 
||aa 
!aa  !

Currenciesaa! +
.aa+ ,
Containsaa, 4
(aa4 5
currencyaa5 =
)aa= >
)aa> ?
returnaa@ F
$straaG k
;aak l
ifbb 

(bb 
stringbb 
.bb 
IsNullOrEmptybb  
(bb  !
numberbb! '
)bb' (
||bb) +
numberbb, 2
.bb2 3
Lengthbb3 9
<bb: ;
$numbb< =
||bb> @
numberbbA G
.bbG H
LengthbbH N
>bbO P
$numbbQ S
)bbS T
returnbbU [
$str	bb\ Ä
;
bbÄ Å
ifcc 

(cc 
ccicc 
iscc 
{cc 
Lengthcc 
:cc 
>cc 
$numcc  
}cc! "
&&cc# %
!cc& '

CciPatterncc' 1
(cc1 2
)cc2 3
.cc3 4
IsMatchcc4 ;
(cc; <
ccicc< ?
)cc? @
)cc@ A
returnccB H
$strccI c
;ccc d
(dd 	
accountdd	 
.dd 
BankNamedd 
,dd 
accountdd "
.dd" #
Holderdd# )
,dd) *
accountdd+ 2
.dd2 3
Currencydd3 ;
,dd; <
accountdd= D
.ddD E
TypeddE I
,ddI J
accountddK R
.ddR S
AccountNumberddS `
,dd` a
accountddb i
.ddi j
Cciddj m
,ddm n
accountddo v
.ddv w
IsActiveddw 
)	dd Ä
=
ddÅ Ç
(
ddÉ Ñ
bank
ddÑ à
,
ddà â
holder
ddä ê
,
ddê ë
currency
ddí ö
,
ddö õ
r
ddú ù
.
ddù û
Type
ddû ¢
,
dd¢ £
number
dd§ ™
,
dd™ ´
cci
dd¨ Ø
is
dd∞ ≤
{
dd≥ ¥
Length
ddµ ª
:
ddª º
>
ddΩ æ
$num
ddø ¿
}
dd¡ ¬
?
dd√ ƒ
cci
dd≈ »
:
dd…  
null
ddÀ œ
,
ddœ –
r
dd— “
.
dd“ ”
IsActive
dd” €
)
dd€ ‹
;
dd‹ ›
returnee 
nullee 
;ee 
}ff 
privateii 
staticii 
stringii 
?ii 
Digitsii !
(ii! "
stringii" (
?ii( )
valueii* /
)ii/ 0
=>ii1 3
valueii4 9
isii: <
nullii= A
?iiB C
nulliiD H
:iiI J
WhitespacePatterniiK \
(ii\ ]
)ii] ^
.ii^ _
Replaceii_ f
(iif g
valueiig l
,iil m
$striin p
)iip q
.iiq r
ToUpperInvariant	iir Ç
(
iiÇ É
)
iiÉ Ñ
;
iiÑ Ö
[kk 
GeneratedRegexkk 
(kk 
$strkk 
)kk  
]kk  !
privatekk" )
statickk* 0
partialkk1 8
Regexkk9 >

CciPatternkk? I
(kkI J
)kkJ K
;kkK L
[ll 
GeneratedRegexll 
(ll 
$strll 
)ll 
]ll 
privatell $
staticll% +
partialll, 3
Regexll4 9
WhitespacePatternll: K
(llK L
)llL M
;llM N
[tt 
HttpPosttt 
(tt 
$strtt :
)tt: ;
,tt; <
	Authorizett= F
(ttF G
RolesttG L
=ttM N
$strttO ^
)tt^ _
,tt_ `
RequestSizeLimittta q
(ttq r
$numttr {
)tt{ |
,tt| }
RequestFormLimits	tt~ è
(
ttè ê&
MultipartBodyLengthLimit
ttê ®
=
tt© ™
$num
tt´ ¥
)
tt¥ µ
]
ttµ ∂
publicuu 

asyncuu 
Taskuu 
<uu 
ActionResultuu "
>uu" #
Reportuu$ *
(uu* +
Guiduu+ /
iduu0 2
,uu2 3
[uu4 5
FromFormuu5 =
]uu= >!
TransferReportRequestuu? T
requestuuU \
,uu\ ]
CancellationTokenuu^ o
ctuup r
,uur s
	IFormFileuut }
?uu} ~
receipt	uu Ü
=
uuá à
null
uuâ ç
)
uuç é
{vv 
ifww 

(ww 
!ww 
Guidww 
.ww 
TryParseww 
(ww 
Userww 
.ww  
FindFirstValueww  .
(ww. /
$strww/ :
)ww: ;
,ww; <
outww= @
varwwA D
clientIdwwE M
)wwM N
)wwN O
returnwwP V
ForbidwwW ]
(ww] ^
)ww^ _
;ww_ `
varxx 
settingsxx 
=xx 
awaitxx 
	transfersxx &
.xx& '
SettingsAsyncxx' 4
(xx4 5
ctxx5 7
)xx7 8
;xx8 9
ifyy 

(yy 
!yy 
settingsyy 
.yy 
BankTransferEnabledyy )
)yy) *
returnyy+ 1

BadRequestyy2 <
(yy< =
newyy= @
{yyA B
messageyyC J
=yyK L
$str	yyM Ü
}
yyá à
)
yyà â
;
yyâ ä
varzz 
itemzz 
=zz 
awaitzz 
dbzz 
.zz 
ClientProductszz *
.zz* +
Includezz+ 2
(zz2 3
xzz3 4
=>zz5 7
xzz8 9
.zz9 :
Productzz: A
)zzA B
.zzB C 
SingleOrDefaultAsynczzC W
(zzW X
xzzX Y
=>zzZ \
xzz] ^
.zz^ _
Idzz_ a
==zzb d
idzze g
&&zzh j
xzzk l
.zzl m
ClientIdzzm u
==zzv x
clientId	zzy Å
,
zzÅ Ç
ct
zzÉ Ö
)
zzÖ Ü
;
zzÜ á
if{{ 

({{ 
item{{ 
?{{ 
.{{ 
Product{{ 
is{{ 
null{{ !
){{! "
return{{# )
NotFound{{* 2
({{2 3
){{3 4
;{{4 5
if|| 

(|| 
!|| 
CanPayByTransfer|| 
(|| 
item|| "
,||" #
settings||$ ,
)||, -
)||- .
return||/ 5

BadRequest||6 @
(||@ A
new||A D
{||E F
message||G N
=||O P
$str	||Q é
}
||è ê
)
||ê ë
;
||ë í
if}} 

(}} 
await}} 
db}} 
.}} 
TransferReports}} $
.}}$ %
AnyAsync}}% -
(}}- .
x}}. /
=>}}0 2
x}}3 4
.}}4 5
ClientProductId}}5 D
==}}E G
id}}H J
&&}}K M
x}}N O
.}}O P
Status}}P V
==}}W Y 
TransferReportStatus}}Z n
.}}n o
	Pendiente}}o x
,}}x y
ct}}z |
)}}| }
)}}} ~
return	}} Ö
Conflict
}}Ü é
(
}}é è
new
}}è í
{
}}ì î
message
}}ï ú
=
}}ù û
$str
}}ü ‡
}
}}· ‚
)
}}‚ „
;
}}„ ‰
var~~ 
account~~ 
=~~ 
await~~ 
db~~ 
.~~ 
BankAccounts~~ +
.~~+ , 
SingleOrDefaultAsync~~, @
(~~@ A
x~~A B
=>~~C E
x~~F G
.~~G H
Id~~H J
==~~K M
request~~N U
.~~U V
BankAccountId~~V c
&&~~d f
x~~g h
.~~h i
IsActive~~i q
,~~q r
ct~~s u
)~~u v
;~~v w
if 

( 
account 
is 
null 
) 
return #

BadRequest$ .
(. /
new/ 2
{3 4
message5 <
== >
$str? g
}h i
)i j
;j k
var
ÄÄ 
	operation
ÄÄ 
=
ÄÄ 
request
ÄÄ 
.
ÄÄ  
OperationNumber
ÄÄ  /
?
ÄÄ/ 0
.
ÄÄ0 1
Trim
ÄÄ1 5
(
ÄÄ5 6
)
ÄÄ6 7
;
ÄÄ7 8
if
ÅÅ 

(
ÅÅ 
ValidateReport
ÅÅ 
(
ÅÅ 
request
ÅÅ "
,
ÅÅ" #
	operation
ÅÅ$ -
,
ÅÅ- .
receipt
ÅÅ/ 6
is
ÅÅ7 9
not
ÅÅ: =
null
ÅÅ> B
)
ÅÅB C
is
ÅÅD F
string
ÅÅG M
reportError
ÅÅN Y
)
ÅÅY Z
return
ÅÅ[ a

BadRequest
ÅÅb l
(
ÅÅl m
new
ÅÅm p
{
ÅÅq r
message
ÅÅs z
=
ÅÅ{ |
reportErrorÅÅ} à
}ÅÅâ ä
)ÅÅä ã
;ÅÅã å
if
ÇÇ 

(
ÇÇ 
item
ÇÇ 
.
ÇÇ 
ValidateYears
ÇÇ 
(
ÇÇ 
request
ÇÇ &
.
ÇÇ& '
Years
ÇÇ' ,
)
ÇÇ, -
is
ÇÇ. 0
string
ÇÇ1 7

yearsError
ÇÇ8 B
)
ÇÇB C
return
ÇÇD J

BadRequest
ÇÇK U
(
ÇÇU V
new
ÇÇV Y
{
ÇÇZ [
message
ÇÇ\ c
=
ÇÇd e

yearsError
ÇÇf p
}
ÇÇq r
)
ÇÇr s
;
ÇÇs t
if
ÉÉ 

(
ÉÉ 
!
ÉÉ 
string
ÉÉ 
.
ÉÉ 
IsNullOrEmpty
ÉÉ !
(
ÉÉ! "
	operation
ÉÉ" +
)
ÉÉ+ ,
&&
ÉÉ- /
await
ÉÉ0 5
db
ÉÉ6 8
.
ÉÉ8 9
TransferReports
ÉÉ9 H
.
ÉÉH I
AnyAsync
ÉÉI Q
(
ÉÉQ R
x
ÉÉR S
=>
ÉÉT V
x
ÉÉW X
.
ÉÉX Y
OperationNumber
ÉÉY h
==
ÉÉi k
	operation
ÉÉl u
&&
ÉÉv x
x
ÉÉy z
.
ÉÉz {
BankAccountIdÉÉ{ à
==ÉÉâ ã
accountÉÉå ì
.ÉÉì î
IdÉÉî ñ
&&ÉÉó ô
xÉÉö õ
.ÉÉõ ú
StatusÉÉú ¢
!=ÉÉ£ •$
TransferReportStatusÉÉ¶ ∫
.ÉÉ∫ ª
	RechazadoÉÉª ƒ
,ÉÉƒ ≈
ctÉÉ∆ »
)ÉÉ» …
)ÉÉ…  
return
ÑÑ 
Conflict
ÑÑ 
(
ÑÑ 
new
ÑÑ 
{
ÑÑ  !
message
ÑÑ" )
=
ÑÑ* +
$str
ÑÑ, S
}
ÑÑT U
)
ÑÑU V
;
ÑÑV W
var
ÜÜ 
report
ÜÜ 
=
ÜÜ 
new
ÜÜ 
TransferReport
ÜÜ '
{
ÜÜ( )
ClientId
ÜÜ* 2
=
ÜÜ3 4
clientId
ÜÜ5 =
,
ÜÜ= >
ClientProductId
ÜÜ? N
=
ÜÜO P
item
ÜÜQ U
.
ÜÜU V
Id
ÜÜV X
,
ÜÜX Y
BankAccountId
ÜÜZ g
=
ÜÜh i
account
ÜÜj q
.
ÜÜq r
Id
ÜÜr t
,
ÜÜt u
Amount
ÜÜv |
=
ÜÜ} ~
MathÜÜ É
.ÜÜÉ Ñ
RoundÜÜÑ â
(ÜÜâ ä
requestÜÜä ë
.ÜÜë í
AmountÜÜí ò
,ÜÜò ô
$numÜÜö õ
)ÜÜõ ú
,ÜÜú ù
CurrencyÜÜû ¶
=ÜÜß ®
accountÜÜ© ∞
.ÜÜ∞ ±
CurrencyÜÜ± π
,ÜÜπ ∫
PaidAtÜÜª ¡
=ÜÜ¬ √
requestÜÜƒ À
.ÜÜÀ Ã
PaidAtÜÜÃ “
,ÜÜ“ ”
OperationNumberÜÜ‘ „
=ÜÜ‰ Â
stringÜÜÊ Ï
.ÜÜÏ Ì
IsNullOrEmptyÜÜÌ ˙
(ÜÜ˙ ˚
	operationÜÜ˚ Ñ
)ÜÜÑ Ö
?ÜÜÜ á
nullÜÜà å
:ÜÜç é
	operationÜÜè ò
,ÜÜò ô
YearsÜÜö ü
=ÜÜ† °
requestÜÜ¢ ©
.ÜÜ© ™
YearsÜÜ™ Ø
,ÜÜØ ∞ 
ReportedByUserIdÜÜ± ¡
=ÜÜ¬ √
UserIdÜÜƒ  
}ÜÜÀ Ã
;ÜÜÃ Õ
if
áá 

(
áá 
receipt
áá 
is
áá 
not
áá 
null
áá 
&&
áá  "
await
áá# ( 
AttachReceiptAsync
áá) ;
(
áá; <
report
áá< B
,
ááB C
receipt
ááD K
,
ááK L
ct
ááM O
)
ááO P
is
ááQ S
string
ááT Z
receiptError
áá[ g
)
áág h
return
áái o

BadRequest
ááp z
(
ááz {
new
áá{ ~
{áá Ä
messageááÅ à
=ááâ ä
receiptErrorááã ó
}ááò ô
)ááô ö
;ááö õ
db
àà 

.
àà
 
TransferReports
àà 
.
àà 
Add
àà 
(
àà 
report
àà %
)
àà% &
;
àà& '
await
àà( -
db
àà. 0
.
àà0 1
SaveChangesAsync
àà1 A
(
ààA B
ct
ààB D
)
ààD E
;
ààE F
await
ââ 
NotifyStaffAsync
ââ 
(
ââ 
report
ââ %
,
ââ% &
item
ââ' +
,
ââ+ ,
ct
ââ- /
)
ââ/ 0
;
ââ0 1
return
ää 
Created
ää 
(
ää 
$"
ää 
$str
ää /
{
ää/ 0
report
ää0 6
.
ää6 7
Id
ää7 9
}
ää9 :
"
ää: ;
,
ää; <
new
ää= @#
TransferReportSummary
ääA V
(
ääV W
report
ääW ]
.
ää] ^
Id
ää^ `
,
ää` a
report
ääb h
.
ääh i
Status
ääi o
,
ääo p
report
ääq w
.
ääw x
	CreatedAtääx Å
,ääÅ Ç
nullääÉ á
)ääá à
)ääà â
;ääâ ä
}
ãã 
private
éé 
static
éé 
string
éé 
?
éé 
ValidateReport
éé )
(
éé) *#
TransferReportRequest
éé* ?
request
éé@ G
,
ééG H
string
ééI O
?
ééO P
	operation
ééQ Z
,
ééZ [
bool
éé\ `

hasReceipt
ééa k
)
éék l
{
èè 
if
êê 

(
êê 
string
êê 
.
êê 
IsNullOrEmpty
êê  
(
êê  !
	operation
êê! *
)
êê* +
&&
êê, .
!
êê/ 0

hasReceipt
êê0 :
)
êê: ;
return
êê< B
$strêêC à
;êêà â
if
ëë 

(
ëë 
	operation
ëë 
is
ëë 
{
ëë 
Length
ëë !
:
ëë! "
>
ëë# $
$num
ëë% '
}
ëë( )
)
ëë) *
return
ëë+ 1
$str
ëë2 Z
;
ëëZ [
if
íí 

(
íí 
request
íí 
.
íí 
Amount
íí 
<=
íí 
$num
íí 
)
íí  
return
íí! '
$str
íí( F
;
ííF G
var
ìì 
today
ìì 
=
ìì 
DateTime
ìì 
.
ìì 
UtcNow
ìì #
;
ìì# $
if
îî 

(
îî 
request
îî 
.
îî 
PaidAt
îî 
>
îî 
DateOnly
îî %
.
îî% &
FromDateTime
îî& 2
(
îî2 3
today
îî3 8
.
îî8 9
AddDays
îî9 @
(
îî@ A
$num
îîA B
)
îîB C
)
îîC D
||
îîE G
request
îîH O
.
îîO P
PaidAt
îîP V
<
îîW X
DateOnly
îîY a
.
îîa b
FromDateTime
îîb n
(
îîn o
today
îîo t
.
îît u
AddDays
îîu |
(
îî| }
-
îî} ~
$numîî~ Ä
)îîÄ Å
)îîÅ Ç
)îîÇ É
returnîîÑ ä
$strîîã ∑
;îî∑ ∏
return
ïï 
null
ïï 
;
ïï 
}
ññ 
private
ôô 
static
ôô 
async
ôô 
Task
ôô 
<
ôô 
string
ôô $
?
ôô$ %
>
ôô% & 
AttachReceiptAsync
ôô' 9
(
ôô9 :
TransferReport
ôô: H
report
ôôI O
,
ôôO P
	IFormFile
ôôQ Z
receipt
ôô[ b
,
ôôb c
CancellationToken
ôôd u
ct
ôôv x
)
ôôx y
{
öö 
if
õõ 

(
õõ 
receipt
õõ 
.
õõ 
Length
õõ 
==
õõ 
$num
õõ 
||
õõ  "
receipt
õõ# *
.
õõ* +
Length
õõ+ 1
>
õõ2 3
MaxReceiptBytes
õõ4 C
)
õõC D
return
õõE K
$str
õõL x
;
õõx y
var
úú 
type
úú 
=
úú 
receipt
úú 
.
úú 
ContentType
úú &
?
úú& '
.
úú' (
ToLowerInvariant
úú( 8
(
úú8 9
)
úú9 :
??
úú; =
$str
úú> @
;
úú@ A
if
ùù 

(
ùù 
!
ùù 
ReceiptTypes
ùù 
.
ùù 
Contains
ùù "
(
ùù" #
type
ùù# '
)
ùù' (
)
ùù( )
return
ùù* 0
$str
ùù1 o
;
ùùo p
using
ûû 
var
ûû 
stream
ûû 
=
ûû 
new
ûû 
MemoryStream
ûû +
(
ûû+ ,
)
ûû, -
;
ûû- .
await
ûû/ 4
receipt
ûû5 <
.
ûû< =
CopyToAsync
ûû= H
(
ûûH I
stream
ûûI O
,
ûûO P
ct
ûûQ S
)
ûûS T
;
ûûT U
(
üü 	
report
üü	 
.
üü 
ReceiptFileName
üü 
,
üü  
report
üü! '
.
üü' ( 
ReceiptContentType
üü( :
,
üü: ;
report
üü< B
.
üüB C
ReceiptContent
üüC Q
)
üüQ R
=
üüS T
(
üüU V
Path
üüV Z
.
üüZ [
GetFileName
üü[ f
(
üüf g
receipt
üüg n
.
üün o
FileName
üüo w
)
üüw x
,
üüx y
type
üüz ~
,
üü~ 
streamüüÄ Ü
.üüÜ á
ToArrayüüá é
(üüé è
)üüè ê
)üüê ë
;üüë í
return
†† 
null
†† 
;
†† 
}
°° 
internal
®® 
static
®® 
bool
®® 
CanPayByTransfer
®® )
(
®®) *
ClientProduct
®®* 7
item
®®8 <
,
®®< =
PaymentSettings
®®> M
settings
®®N V
)
®®V W
{
©© 
if
™™ 

(
™™ 
!
™™ 
settings
™™ 
.
™™ !
BankTransferEnabled
™™ )
||
™™* ,
item
™™- 1
.
™™1 2
Status
™™2 8
==
™™9 ;!
ClientProductStatus
™™< O
.
™™O P
	Cancelado
™™P Y
)
™™Y Z
return
™™[ a
false
™™b g
;
™™g h
if
´´ 

(
´´ 
!
´´ 
item
´´ 
.
´´ 
IsManualBilling
´´ !
&&
´´" $
(
´´% &
settings
´´& .
.
´´. /
PayPalEnabled
´´/ <
||
´´= ?
!
´´@ A
string
´´A G
.
´´G H 
IsNullOrWhiteSpace
´´H Z
(
´´Z [
item
´´[ _
.
´´_ `"
PayPalSubscriptionId
´´` t
)
´´t u
)
´´u v
)
´´v w
return
´´x ~
false´´ Ñ
;´´Ñ Ö
if
¨¨ 

(
¨¨ 
item
¨¨ 
.
¨¨ 
Status
¨¨ 
==
¨¨ !
ClientProductStatus
¨¨ .
.
¨¨. /
	Pendiente
¨¨/ 8
)
¨¨8 9
return
¨¨: @
true
¨¨A E
;
¨¨E F
if
≠≠ 

(
≠≠ 
item
≠≠ 
.
≠≠ 
BillingCycle
≠≠ 
==
≠≠  
BillingCycle
≠≠! -
.
≠≠- .
Unico
≠≠. 3
)
≠≠3 4
return
≠≠5 ;
false
≠≠< A
;
≠≠A B
if
ÆÆ 

(
ÆÆ 
item
ÆÆ 
.
ÆÆ 
Status
ÆÆ 
is
ÆÆ !
ClientProductStatus
ÆÆ .
.
ÆÆ. /
	PorVencer
ÆÆ/ 8
or
ÆÆ9 ;!
ClientProductStatus
ÆÆ< O
.
ÆÆO P
Vencido
ÆÆP W
)
ÆÆW X
return
ÆÆY _
true
ÆÆ` d
;
ÆÆd e
var
ØØ 
due
ØØ 
=
ØØ 
item
ØØ 
.
ØØ 
BillingCycle
ØØ #
.
ØØ# $
IsSubscription
ØØ$ 2
(
ØØ2 3
)
ØØ3 4
?
ØØ5 6
item
ØØ7 ;
.
ØØ; <
NextChargeAt
ØØ< H
:
ØØI J
item
ØØK O
.
ØØO P
RenewsAt
ØØP X
;
ØØX Y
return
∞∞ 
due
∞∞ 
is
∞∞ 
DateTime
∞∞ 
date
∞∞ #
&&
∞∞$ &
date
∞∞' +
<=
∞∞, .
DateTime
∞∞/ 7
.
∞∞7 8
UtcNow
∞∞8 >
.
∞∞> ?
AddDays
∞∞? F
(
∞∞F G 
PaymentsController
∞∞G Y
.
∞∞Y Z
RenewalWindowDays
∞∞Z k
)
∞∞k l
;
∞∞l m
}
±± 
private
≥≥ 
async
≥≥ 
Task
≥≥ 
NotifyStaffAsync
≥≥ '
(
≥≥' (
TransferReport
≥≥( 6
report
≥≥7 =
,
≥≥= >
ClientProduct
≥≥? L
item
≥≥M Q
,
≥≥Q R
CancellationToken
≥≥S d
ct
≥≥e g
)
≥≥g h
{
¥¥ 
var
µµ 

staffEmail
µµ 
=
µµ 
configuration
µµ &
[
µµ& '
$str
µµ' A
]
µµA B
is
µµC E
{
µµF G
Length
µµH N
:
µµN O
>
µµP Q
$num
µµR S
}
µµT U

configured
µµV `
?
µµa b

configured
µµc m
:
µµn o
configuration
µµp }
[
µµ} ~
$strµµ~ â
]µµâ ä
;µµä ã
if
∂∂ 

(
∂∂ 
string
∂∂ 
.
∂∂  
IsNullOrWhiteSpace
∂∂ %
(
∂∂% &

staffEmail
∂∂& 0
)
∂∂0 1
)
∂∂1 2
{
∂∂3 4
logger
∂∂5 ;
.
∂∂; <

LogWarning
∂∂< F
(
∂∂F G
$str∂∂G å
,∂∂å ç
report∂∂é î
.∂∂î ï
Id∂∂ï ó
)∂∂ó ò
;∂∂ò ô
return∂∂ö †
;∂∂† °
}∂∂¢ £
var
∑∑ 
client
∑∑ 
=
∑∑ 
await
∑∑ 
db
∑∑ 
.
∑∑ 
Clients
∑∑ %
.
∑∑% &
SingleAsync
∑∑& 1
(
∑∑1 2
x
∑∑2 3
=>
∑∑4 6
x
∑∑7 8
.
∑∑8 9
Id
∑∑9 ;
==
∑∑< >
report
∑∑? E
.
∑∑E F
ClientId
∑∑F N
,
∑∑N O
ct
∑∑P R
)
∑∑R S
;
∑∑S T
var
∏∏ 
data
∏∏ 
=
∏∏ 
new
∏∏ 

Dictionary
∏∏ !
<
∏∏! "
string
∏∏" (
,
∏∏( )
string
∏∏* 0
>
∏∏0 1
{
∏∏2 3
[
∏∏4 5
$str
∏∏5 ?
]
∏∏? @
=
∏∏A B
report
∏∏C I
.
∏∏I J
Id
∏∏J L
.
∏∏L M
ToString
∏∏M U
(
∏∏U V
)
∏∏V W
,
∏∏W X
[
∏∏Y Z
$str
∏∏Z c
]
∏∏c d
=
∏∏e f
client
∏∏g m
.
∏∏m n
CompanyName
∏∏n y
,
∏∏y z
[
∏∏{ |
$str∏∏| Ö
]∏∏Ö Ü
=∏∏á à
item∏∏â ç
.∏∏ç é
Product∏∏é ï
?∏∏ï ñ
.∏∏ñ ó
Name∏∏ó õ
??∏∏ú û
$str∏∏ü °
,∏∏° ¢
[∏∏£ §
$str∏∏§ ¨
]∏∏¨ ≠
=∏∏Æ Ø
report∏∏∞ ∂
.∏∏∂ ∑
Amount∏∏∑ Ω
.∏∏Ω æ
ToString∏∏æ ∆
(∏∏∆ «
CultureInfo∏∏« “
.∏∏“ ” 
InvariantCulture∏∏” „
)∏∏„ ‰
,∏∏‰ Â
[∏∏Ê Á
$str∏∏Á Ò
]∏∏Ò Ú
=∏∏Û Ù
report∏∏ı ˚
.∏∏˚ ¸
Currency∏∏¸ Ñ
}∏∏Ö Ü
;∏∏Ü á
if
ππ 

(
ππ 
report
ππ 
.
ππ 
OperationNumber
ππ "
is
ππ# %
not
ππ& )
null
ππ* .
)
ππ. /
data
ππ0 4
[
ππ4 5
$str
ππ5 @
]
ππ@ A
=
ππB C
report
ππD J
.
ππJ K
OperationNumber
ππK Z
;
ππZ [
await
∫∫ 
notifications
∫∫ 
.
∫∫ 
	SendAsync
∫∫ %
(
∫∫% &
client
∫∫& ,
,
∫∫, -
new
∫∫. 1
Notification
∫∫2 >
(
∫∫> ?
NotificationType
∫∫? O
.
∫∫O P
TransferReported
∫∫P `
,
∫∫` a
data
∫∫b f
,
∫∫f g
$"
∫∫h j
$str
∫∫j |
{
∫∫| }
report∫∫} É
.∫∫É Ñ
Id∫∫Ñ Ü
}∫∫Ü á
"∫∫á à
,∫∫à â

staffEmail∫∫ä î
)∫∫î ï
,∫∫ï ñ
ct∫∫ó ô
)∫∫ô ö
;∫∫ö õ
}
ªª 
[
ææ 
HttpGet
ææ 
(
ææ 
$str
ææ 1
)
ææ1 2
]
ææ2 3
public
øø 

async
øø 
Task
øø 
<
øø 
ActionResult
øø "
>
øø" #
Receipt
øø$ +
(
øø+ ,
Guid
øø, 0
id
øø1 3
,
øø3 4
CancellationToken
øø5 F
ct
øøG I
)
øøI J
{
¿¿ 
var
¡¡ 
report
¡¡ 
=
¡¡ 
await
¡¡ 
db
¡¡ 
.
¡¡ 
TransferReports
¡¡ -
.
¡¡- ."
SingleOrDefaultAsync
¡¡. B
(
¡¡B C
x
¡¡C D
=>
¡¡E G
x
¡¡H I
.
¡¡I J
Id
¡¡J L
==
¡¡M O
id
¡¡P R
,
¡¡R S
ct
¡¡T V
)
¡¡V W
;
¡¡W X
if
¬¬ 

(
¬¬ 
report
¬¬ 
?
¬¬ 
.
¬¬ 
ReceiptContent
¬¬ "
is
¬¬# %
null
¬¬& *
)
¬¬* +
return
¬¬, 2
NotFound
¬¬3 ;
(
¬¬; <
)
¬¬< =
;
¬¬= >
if
√√ 

(
√√ 
!
√√ 
IsSuperAdmin
√√ 
&&
√√ 
(
√√ 
!
√√ 
Guid
√√ #
.
√√# $
TryParse
√√$ ,
(
√√, -
User
√√- 1
.
√√1 2
FindFirstValue
√√2 @
(
√√@ A
$str
√√A L
)
√√L M
,
√√M N
out
√√O R
var
√√S V
clientId
√√W _
)
√√_ `
||
√√a c
clientId
√√d l
!=
√√m o
report
√√p v
.
√√v w
ClientId
√√w 
)√√ Ä
)√√Ä Å
return√√Ç à
NotFound√√â ë
(√√ë í
)√√í ì
;√√ì î
Response
ƒƒ 
.
ƒƒ 
Headers
ƒƒ 
.
ƒƒ 
CacheControl
ƒƒ %
=
ƒƒ& '
$str
ƒƒ( ;
;
ƒƒ; <
return
≈≈ 
File
≈≈ 
(
≈≈ 
report
≈≈ 
.
≈≈ 
ReceiptContent
≈≈ )
,
≈≈) *
report
≈≈+ 1
.
≈≈1 2 
ReceiptContentType
≈≈2 D
??
≈≈E G
$str
≈≈H b
,
≈≈b c
report
≈≈d j
.
≈≈j k
ReceiptFileName
≈≈k z
)
≈≈z {
;
≈≈{ |
}
∆∆ 
[
   
HttpGet
   
(
   
$str
   %
)
  % &
,
  & '
	Authorize
  ( 1
(
  1 2
Roles
  2 7
=
  8 9
$str
  : F
)
  F G
]
  G H
public
ÀÀ 

async
ÀÀ 
Task
ÀÀ 
<
ÀÀ 
ActionResult
ÀÀ "
>
ÀÀ" #
Reports
ÀÀ$ +
(
ÀÀ+ ,"
TransferReportStatus
ÀÀ, @
?
ÀÀ@ A
status
ÀÀB H
,
ÀÀH I
CancellationToken
ÀÀJ [
ct
ÀÀ\ ^
)
ÀÀ^ _
{
ÃÃ 
var
ÕÕ 
query
ÕÕ 
=
ÕÕ 
from
ÕÕ 
report
ÕÕ 
in
ÕÕ  "
db
ÕÕ# %
.
ÕÕ% &
TransferReports
ÕÕ& 5
join
ŒŒ 
client
ŒŒ 
in
ŒŒ  "
db
ŒŒ# %
.
ŒŒ% &
Clients
ŒŒ& -
on
ŒŒ. 0
report
ŒŒ1 7
.
ŒŒ7 8
ClientId
ŒŒ8 @
equals
ŒŒA G
client
ŒŒH N
.
ŒŒN O
Id
ŒŒO Q
join
œœ 
item
œœ 
in
œœ  
db
œœ! #
.
œœ# $
ClientProducts
œœ$ 2
on
œœ3 5
report
œœ6 <
.
œœ< =
ClientProductId
œœ= L
equals
œœM S
item
œœT X
.
œœX Y
Id
œœY [
join
–– 
product
––  
in
––! #
db
––$ &
.
––& '
Products
––' /
on
––0 2
item
––3 7
.
––7 8
	ProductId
––8 A
equals
––B H
product
––I P
.
––P Q
Id
––Q S
join
—— 
account
——  
in
——! #
db
——$ &
.
——& '
BankAccounts
——' 3
on
——4 6
report
——7 =
.
——= >
BankAccountId
——> K
equals
——L R
account
——S Z
.
——Z [
Id
——[ ]
into
——^ b
accounts
——c k
from
““ 
account
““  
in
““! #
accounts
““$ ,
.
““, -
DefaultIfEmpty
““- ;
(
““; <
)
““< =
where
”” 
status
””  
==
””! #
null
””$ (
||
””) +
report
””, 2
.
””2 3
Status
””3 9
==
””: <
status
””= C
orderby
‘‘ 
report
‘‘ "
.
‘‘" #
Status
‘‘# )
==
‘‘* ,"
TransferReportStatus
‘‘- A
.
‘‘A B
	Pendiente
‘‘B K

descending
‘‘L V
,
‘‘V W
report
‘‘X ^
.
‘‘^ _
	CreatedAt
‘‘_ h

descending
‘‘i s
select
’’ 
new
’’ 
TransferReportDto
’’ 0
(
’’0 1
report
’’1 7
.
’’7 8
Id
’’8 :
,
’’: ;
report
’’< B
.
’’B C
ClientId
’’C K
,
’’K L
client
’’M S
.
’’S T
CompanyName
’’T _
,
’’_ `
report
’’a g
.
’’g h
ClientProductId
’’h w
,
’’w x
product’’y Ä
.’’Ä Å
Name’’Å Ö
,’’Ö Ü
item’’á ã
.’’ã å

DomainName’’å ñ
,’’ñ ó
product’’ò ü
.’’ü †
Currency’’† ®
,’’® ©
report’’™ ∞
.’’∞ ±
Amount’’± ∑
,’’∑ ∏
report’’π ø
.’’ø ¿
Currency’’¿ »
,’’» …
report’’  –
.’’– —
PaidAt’’— ◊
,’’◊ ÿ
report’’Ÿ ﬂ
.’’ﬂ ‡
OperationNumber’’‡ Ô
,’’Ô 
report’’Ò ˜
.’’˜ ¯
Years’’¯ ˝
,’’˝ ˛
account
÷÷ 
==
÷÷  "
null
÷÷# '
?
÷÷( )
null
÷÷* .
:
÷÷/ 0
account
÷÷1 8
.
÷÷8 9
BankName
÷÷9 A
+
÷÷B C
$str
÷÷D G
+
÷÷H I
account
÷÷J Q
.
÷÷Q R
Currency
÷÷R Z
+
÷÷[ \
$str
÷÷] b
+
÷÷c d
account
÷÷e l
.
÷÷l m
AccountNumber
÷÷m z
,
÷÷z {
report÷÷| Ç
.÷÷Ç É
ReceiptContent÷÷É ë
!=÷÷í î
null÷÷ï ô
,÷÷ô ö
report÷÷õ °
.÷÷° ¢"
ReceiptContentType÷÷¢ ¥
,÷÷¥ µ
report÷÷∂ º
.÷÷º Ω
Status÷÷Ω √
,÷÷√ ƒ
report÷÷≈ À
.÷÷À Ã
RejectionReason÷÷Ã €
,÷÷€ ‹
report÷÷› „
.÷÷„ ‰
	CreatedAt÷÷‰ Ì
,÷÷Ì Ó
report÷÷Ô ı
.÷÷ı ˆ

ReviewedAt÷÷ˆ Ä
)÷÷Ä Å
;÷÷Å Ç
return
◊◊ 
Ok
◊◊ 
(
◊◊ 
await
◊◊ 
query
◊◊ 
.
◊◊ 
Take
◊◊ "
(
◊◊" #
$num
◊◊# &
)
◊◊& '
.
◊◊' (
ToListAsync
◊◊( 3
(
◊◊3 4
ct
◊◊4 6
)
◊◊6 7
)
◊◊7 8
;
◊◊8 9
}
ÿÿ 
[
ﬁﬁ 
HttpPost
ﬁﬁ 
(
ﬁﬁ 
$str
ﬁﬁ 8
)
ﬁﬁ8 9
,
ﬁﬁ9 :
	Authorize
ﬁﬁ; D
(
ﬁﬁD E
Roles
ﬁﬁE J
=
ﬁﬁK L
$str
ﬁﬁM Y
)
ﬁﬁY Z
]
ﬁﬁZ [
public
ﬂﬂ 

async
ﬂﬂ 
Task
ﬂﬂ 
<
ﬂﬂ 
ActionResult
ﬂﬂ "
>
ﬂﬂ" #
Approve
ﬂﬂ$ +
(
ﬂﬂ+ ,
Guid
ﬂﬂ, 0
id
ﬂﬂ1 3
,
ﬂﬂ3 4$
ApproveTransferRequest
ﬂﬂ5 K
request
ﬂﬂL S
,
ﬂﬂS T
CancellationToken
ﬂﬂU f
ct
ﬂﬂg i
)
ﬂﬂi j
{
‡‡ 
var
·· 
report
·· 
=
·· 
await
·· 
db
·· 
.
·· 
TransferReports
·· -
.
··- ."
SingleOrDefaultAsync
··. B
(
··B C
x
··C D
=>
··E G
x
··H I
.
··I J
Id
··J L
==
··M O
id
··P R
,
··R S
ct
··T V
)
··V W
;
··W X
if
··Y [
(
··\ ]
report
··] c
is
··d f
null
··g k
)
··k l
return
··m s
NotFound
··t |
(
··| }
)
··} ~
;
··~ 
if
‚‚ 

(
‚‚ 
report
‚‚ 
.
‚‚ 
Status
‚‚ 
!=
‚‚ "
TransferReportStatus
‚‚ 1
.
‚‚1 2
	Pendiente
‚‚2 ;
)
‚‚; <
return
‚‚= C
Conflict
‚‚D L
(
‚‚L M
new
‚‚M P
{
‚‚Q R
message
‚‚S Z
=
‚‚[ \
$str
‚‚] y
}
‚‚z {
)
‚‚{ |
;
‚‚| }
var
„„ 
item
„„ 
=
„„ 
await
„„ 
db
„„ 
.
„„ 
ClientProducts
„„ *
.
„„* +
Include
„„+ 2
(
„„2 3
x
„„3 4
=>
„„5 7
x
„„8 9
.
„„9 :
Product
„„: A
)
„„A B
.
„„B C
Include
„„C J
(
„„J K
x
„„K L
=>
„„M O
x
„„P Q
.
„„Q R
Project
„„R Y
)
„„Y Z
.
„„Z [
SingleAsync
„„[ f
(
„„f g
x
„„g h
=>
„„i k
x
„„l m
.
„„m n
Id
„„n p
==
„„q s
report
„„t z
.
„„z {
ClientProductId„„{ ä
,„„ä ã
ct„„å é
)„„é è
;„„è ê
var
‰‰ 
amount
‰‰ 
=
‰‰ 
Math
‰‰ 
.
‰‰ 
Round
‰‰ 
(
‰‰  
request
‰‰  '
.
‰‰' (
Amount
‰‰( .
??
‰‰/ 1
report
‰‰2 8
.
‰‰8 9
Amount
‰‰9 ?
,
‰‰? @
$num
‰‰A B
)
‰‰B C
;
‰‰C D
if
ÂÂ 

(
ÂÂ 
amount
ÂÂ 
<=
ÂÂ 
$num
ÂÂ 
)
ÂÂ 
return
ÂÂ 

BadRequest
ÂÂ  *
(
ÂÂ* +
new
ÂÂ+ .
{
ÂÂ/ 0
message
ÂÂ1 8
=
ÂÂ9 :
$str
ÂÂ; W
}
ÂÂX Y
)
ÂÂY Z
;
ÂÂZ [
var
ÊÊ 
	operation
ÊÊ 
=
ÊÊ 
(
ÊÊ 
request
ÊÊ  
.
ÊÊ  !
OperationNumber
ÊÊ! 0
??
ÊÊ1 3
report
ÊÊ4 :
.
ÊÊ: ;
OperationNumber
ÊÊ; J
)
ÊÊJ K
?
ÊÊK L
.
ÊÊL M
Trim
ÊÊM Q
(
ÊÊQ R
)
ÊÊR S
;
ÊÊS T
var
ÁÁ 
paidAt
ÁÁ 
=
ÁÁ 
request
ÁÁ 
.
ÁÁ 
PaidAt
ÁÁ #
??
ÁÁ$ &
report
ÁÁ' -
.
ÁÁ- .
PaidAt
ÁÁ. 4
;
ÁÁ4 5
var
ËË 
key
ËË 
=
ËË 
string
ËË 
.
ËË 
IsNullOrEmpty
ËË &
(
ËË& '
	operation
ËË' 0
)
ËË0 1
?
ËË2 3
$"
ËË4 6
$str
ËË6 ;
{
ËË; <
report
ËË< B
.
ËËB C
Id
ËËC E
:
ËËE F
$str
ËËF G
}
ËËG H
"
ËËH I
:
ËËJ K
$"
ËËL N
$str
ËËN R
{
ËËR S
	operation
ËËS \
}
ËË\ ]
"
ËË] ^
;
ËË^ _
if
ÈÈ 

(
ÈÈ 
key
ÈÈ 
.
ÈÈ 
Length
ÈÈ 
>
ÈÈ 
$num
ÈÈ 
)
ÈÈ 
return
ÈÈ $

BadRequest
ÈÈ% /
(
ÈÈ/ 0
new
ÈÈ0 3
{
ÈÈ4 5
message
ÈÈ6 =
=
ÈÈ> ?
$str
ÈÈ@ h
}
ÈÈi j
)
ÈÈj k
;
ÈÈk l
item
ÎÎ 
.
ÎÎ 
IsManualBilling
ÎÎ 
=
ÎÎ 
true
ÎÎ #
;
ÎÎ# $
if
ÏÏ 

(
ÏÏ 
!
ÏÏ 
await
ÏÏ 
payments
ÏÏ 
.
ÏÏ 
ApplyPaymentAsync
ÏÏ -
(
ÏÏ- .
item
ÏÏ. 2
,
ÏÏ2 3
key
ÏÏ4 7
,
ÏÏ7 8
amount
ÏÏ9 ?
,
ÏÏ? @
report
ÏÏA G
.
ÏÏG H
Currency
ÏÏH P
,
ÏÏP Q
ct
ÏÏR T
,
ÏÏT U
new
ÏÏV Y
(
ÏÏY Z
PaymentMethods
ÏÏZ h
.
ÏÏh i
Transferencia
ÏÏi v
,
ÏÏv w
DateTimeÏÏx Ä
.ÏÏÄ Å
SpecifyKindÏÏÅ å
(ÏÏå ç
paidAtÏÏç ì
.ÏÏì î

ToDateTimeÏÏî û
(ÏÏû ü
TimeOnlyÏÏü ß
.ÏÏß ®
MinValueÏÏ® ∞
)ÏÏ∞ ±
,ÏÏ± ≤
DateTimeKindÏÏ≥ ø
.ÏÏø ¿
UtcÏÏ¿ √
)ÏÏ√ ƒ
,ÏÏƒ ≈
reportÏÏ∆ Ã
.ÏÏÃ Õ
YearsÏÏÕ “
)ÏÏ“ ”
)ÏÏ” ‘
)ÏÏ‘ ’
return
ÌÌ 
Conflict
ÌÌ 
(
ÌÌ 
new
ÌÌ 
{
ÌÌ  !
message
ÌÌ" )
=
ÌÌ* +
$str
ÌÌ, o
}
ÌÌp q
)
ÌÌq r
;
ÌÌr s
item
ÓÓ 
.
ÓÓ 
Status
ÓÓ 
=
ÓÓ  
RenewalReminderJob
ÓÓ (
.
ÓÓ( )
	StatusFor
ÓÓ) 2
(
ÓÓ2 3
item
ÓÓ3 7
.
ÓÓ7 8
Status
ÓÓ8 >
,
ÓÓ> ?
item
ÓÓ@ D
.
ÓÓD E
RenewsAt
ÓÓE M
,
ÓÓM N
DateTime
ÓÓO W
.
ÓÓW X
UtcNow
ÓÓX ^
)
ÓÓ^ _
;
ÓÓ_ `
(
ÔÔ 	
report
ÔÔ	 
.
ÔÔ 
Status
ÔÔ 
,
ÔÔ 
report
ÔÔ 
.
ÔÔ 
Amount
ÔÔ %
,
ÔÔ% &
report
ÔÔ' -
.
ÔÔ- .
OperationNumber
ÔÔ. =
,
ÔÔ= >
report
ÔÔ? E
.
ÔÔE F
PaidAt
ÔÔF L
,
ÔÔL M
report
ÔÔN T
.
ÔÔT U

ReviewedAt
ÔÔU _
,
ÔÔ_ `
report
ÔÔa g
.
ÔÔg h
ReviewedByUserId
ÔÔh x
)
ÔÔx y
=
ÔÔz {
(
ÔÔ| }#
TransferReportStatusÔÔ} ë
.ÔÔë í
AprobadoÔÔí ö
,ÔÔö õ
amountÔÔú ¢
,ÔÔ¢ £
stringÔÔ§ ™
.ÔÔ™ ´
IsNullOrEmptyÔÔ´ ∏
(ÔÔ∏ π
	operationÔÔπ ¬
)ÔÔ¬ √
?ÔÔƒ ≈
nullÔÔ∆  
:ÔÔÀ Ã
	operationÔÔÕ ÷
,ÔÔ÷ ◊
paidAtÔÔÿ ﬁ
,ÔÔﬁ ﬂ
DateTimeÔÔ‡ Ë
.ÔÔË È
UtcNowÔÔÈ Ô
,ÔÔÔ 
UserIdÔÔÒ ˜
)ÔÔ˜ ¯
;ÔÔ¯ ˘
report
 
.
 "
PaymentTransactionId
 #
=
$ %
await
& +
db
, .
.
. /!
PaymentTransactions
/ B
.
B C
Where
C H
(
H I
x
I J
=>
K M
x
N O
.
O P+
PayPalOrderIdOrSubscriptionId
P m
==
n p
key
q t
)
t u
.
u v
Select
v |
(
| }
x
} ~
=> Å
(Ç É
GuidÉ á
?á à
)à â
xâ ä
.ä ã
Idã ç
)ç é
.é è$
SingleOrDefaultAsyncè £
(£ §
ct§ ¶
)¶ ß
;ß ®
await
ÒÒ 
db
ÒÒ 
.
ÒÒ 
SaveChangesAsync
ÒÒ !
(
ÒÒ! "
ct
ÒÒ" $
)
ÒÒ$ %
;
ÒÒ% &
return
ÚÚ 
Ok
ÚÚ 
(
ÚÚ 
new
ÚÚ 
{
ÚÚ 
status
ÚÚ 
=
ÚÚ  
report
ÚÚ! '
.
ÚÚ' (
Status
ÚÚ( .
,
ÚÚ. /!
clientProductStatus
ÚÚ0 C
=
ÚÚD E
item
ÚÚF J
.
ÚÚJ K
Status
ÚÚK Q
}
ÚÚR S
)
ÚÚS T
;
ÚÚT U
}
ÛÛ 
[
ıı 
HttpPost
ıı 
(
ıı 
$str
ıı 7
)
ıı7 8
,
ıı8 9
	Authorize
ıı: C
(
ııC D
Roles
ııD I
=
ııJ K
$str
ııL X
)
ııX Y
]
ııY Z
public
ˆˆ 

async
ˆˆ 
Task
ˆˆ 
<
ˆˆ 
ActionResult
ˆˆ "
>
ˆˆ" #
Reject
ˆˆ$ *
(
ˆˆ* +
Guid
ˆˆ+ /
id
ˆˆ0 2
,
ˆˆ2 3#
RejectTransferRequest
ˆˆ4 I
request
ˆˆJ Q
,
ˆˆQ R
CancellationToken
ˆˆS d
ct
ˆˆe g
)
ˆˆg h
{
˜˜ 
var
¯¯ 
report
¯¯ 
=
¯¯ 
await
¯¯ 
db
¯¯ 
.
¯¯ 
TransferReports
¯¯ -
.
¯¯- ."
SingleOrDefaultAsync
¯¯. B
(
¯¯B C
x
¯¯C D
=>
¯¯E G
x
¯¯H I
.
¯¯I J
Id
¯¯J L
==
¯¯M O
id
¯¯P R
,
¯¯R S
ct
¯¯T V
)
¯¯V W
;
¯¯W X
if
¯¯Y [
(
¯¯\ ]
report
¯¯] c
is
¯¯d f
null
¯¯g k
)
¯¯k l
return
¯¯m s
NotFound
¯¯t |
(
¯¯| }
)
¯¯} ~
;
¯¯~ 
if
˘˘ 

(
˘˘ 
report
˘˘ 
.
˘˘ 
Status
˘˘ 
!=
˘˘ "
TransferReportStatus
˘˘ 1
.
˘˘1 2
	Pendiente
˘˘2 ;
)
˘˘; <
return
˘˘= C
Conflict
˘˘D L
(
˘˘L M
new
˘˘M P
{
˘˘Q R
message
˘˘S Z
=
˘˘[ \
$str
˘˘] y
}
˘˘z {
)
˘˘{ |
;
˘˘| }
var
˙˙ 
reason
˙˙ 
=
˙˙ 
request
˙˙ 
.
˙˙ 
Reason
˙˙ #
?
˙˙# $
.
˙˙$ %
Trim
˙˙% )
(
˙˙) *
)
˙˙* +
;
˙˙+ ,
if
˚˚ 

(
˚˚ 
string
˚˚ 
.
˚˚ 
IsNullOrEmpty
˚˚  
(
˚˚  !
reason
˚˚! '
)
˚˚' (
)
˚˚( )
return
˚˚* 0

BadRequest
˚˚1 ;
(
˚˚; <
new
˚˚< ?
{
˚˚@ A
message
˚˚B I
=
˚˚J K
$str˚˚L Ç
}˚˚É Ñ
)˚˚Ñ Ö
;˚˚Ö Ü
if
¸¸ 

(
¸¸ 
reason
¸¸ 
.
¸¸ 
Length
¸¸ 
>
¸¸ 
$num
¸¸ 
)
¸¸  
return
¸¸! '

BadRequest
¸¸( 2
(
¸¸2 3
new
¸¸3 6
{
¸¸7 8
message
¸¸9 @
=
¸¸A B
$str
¸¸C z
}
¸¸{ |
)
¸¸| }
;
¸¸} ~
(
˝˝ 	
report
˝˝	 
.
˝˝ 
Status
˝˝ 
,
˝˝ 
report
˝˝ 
.
˝˝ 
RejectionReason
˝˝ .
,
˝˝. /
report
˝˝0 6
.
˝˝6 7

ReviewedAt
˝˝7 A
,
˝˝A B
report
˝˝C I
.
˝˝I J
ReviewedByUserId
˝˝J Z
)
˝˝Z [
=
˝˝\ ]
(
˝˝^ _"
TransferReportStatus
˝˝_ s
.
˝˝s t
	Rechazado
˝˝t }
,
˝˝} ~
reason˝˝ Ö
,˝˝Ö Ü
DateTime˝˝á è
.˝˝è ê
UtcNow˝˝ê ñ
,˝˝ñ ó
UserId˝˝ò û
)˝˝û ü
;˝˝ü †
await
˛˛ 
db
˛˛ 
.
˛˛ 
SaveChangesAsync
˛˛ !
(
˛˛! "
ct
˛˛" $
)
˛˛$ %
;
˛˛% &
var
ˇˇ 
product
ˇˇ 
=
ˇˇ 
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
ClientProducts
ˇˇ -
.
ˇˇ- .
Where
ˇˇ. 3
(
ˇˇ3 4
x
ˇˇ4 5
=>
ˇˇ6 8
x
ˇˇ9 :
.
ˇˇ: ;
Id
ˇˇ; =
==
ˇˇ> @
report
ˇˇA G
.
ˇˇG H
ClientProductId
ˇˇH W
)
ˇˇW X
.
ˇˇX Y
Select
ˇˇY _
(
ˇˇ_ `
x
ˇˇ` a
=>
ˇˇb d
x
ˇˇe f
.
ˇˇf g

DomainName
ˇˇg q
??
ˇˇr t
x
ˇˇu v
.
ˇˇv w
Product
ˇˇw ~
!
ˇˇ~ 
.ˇˇ Ä
NameˇˇÄ Ñ
)ˇˇÑ Ö
.ˇˇÖ Ü
SingleAsyncˇˇÜ ë
(ˇˇë í
ctˇˇí î
)ˇˇî ï
;ˇˇï ñ
if
ÄÄ 

(
ÄÄ 
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
Clients
ÄÄ 
.
ÄÄ 
	FindAsync
ÄÄ &
(
ÄÄ& '
[
ÄÄ' (
report
ÄÄ( .
.
ÄÄ. /
ClientId
ÄÄ/ 7
]
ÄÄ7 8
,
ÄÄ8 9
ct
ÄÄ: <
)
ÄÄ< =
is
ÄÄ> @
Client
ÄÄA G
client
ÄÄH N
)
ÄÄN O
await
ÅÅ 
notifications
ÅÅ 
.
ÅÅ  
	SendAsync
ÅÅ  )
(
ÅÅ) *
client
ÅÅ* 0
,
ÅÅ0 1
new
ÅÅ2 5
Notification
ÅÅ6 B
(
ÅÅB C
NotificationType
ÅÅC S
.
ÅÅS T
TransferRejected
ÅÅT d
,
ÅÅd e
new
ÅÅf i
(
ÅÅi j
)
ÅÅj k
{
ÅÅl m
[
ÅÅn o
$str
ÅÅo x
]
ÅÅx y
=
ÅÅz {
productÅÅ| É
,ÅÅÉ Ñ
[ÅÅÖ Ü
$strÅÅÜ é
]ÅÅé è
=ÅÅê ë
reportÅÅí ò
.ÅÅò ô
AmountÅÅô ü
.ÅÅü †
ToStringÅÅ† ®
(ÅÅ® ©
CultureInfoÅÅ© ¥
.ÅÅ¥ µ 
InvariantCultureÅÅµ ≈
)ÅÅ≈ ∆
,ÅÅ∆ «
[ÅÅ» …
$strÅÅ… ”
]ÅÅ” ‘
=ÅÅ’ ÷
reportÅÅ◊ ›
.ÅÅ› ﬁ
CurrencyÅÅﬁ Ê
,ÅÅÊ Á
[ÅÅË È
$strÅÅÈ Ò
]ÅÅÒ Ú
=ÅÅÛ Ù
reasonÅÅı ˚
}ÅÅ¸ ˝
,ÅÅ˝ ˛
$"ÅÅˇ Å
$strÅÅÅ ì
{ÅÅì î
reportÅÅî ö
.ÅÅö õ
IdÅÅõ ù
}ÅÅù û
"ÅÅû ü
)ÅÅü †
,ÅÅ† °
ctÅÅ¢ §
)ÅÅ§ •
;ÅÅ• ¶
return
ÇÇ 
Ok
ÇÇ 
(
ÇÇ 
new
ÇÇ 
{
ÇÇ 
status
ÇÇ 
=
ÇÇ  
report
ÇÇ! '
.
ÇÇ' (
Status
ÇÇ( .
}
ÇÇ/ 0
)
ÇÇ0 1
;
ÇÇ1 2
}
ÉÉ 
}ÑÑ 
publicÜÜ 
sealed
ÜÜ 
record
ÜÜ $
PaymentSettingsRequest
ÜÜ +
(
ÜÜ+ ,
bool
ÜÜ, 0
?
ÜÜ0 1
PayPal
ÜÜ2 8
,
ÜÜ8 9
bool
ÜÜ: >
?
ÜÜ> ?
BankTransfer
ÜÜ@ L
)
ÜÜL M
;
ÜÜM N
publicáá 
sealed
áá 
record
áá  
BankAccountRequest
áá '
(
áá' (
string
áá( .
?
áá. /
BankName
áá0 8
,
áá8 9
string
áá: @
?
áá@ A
Holder
ááB H
,
ááH I
string
ááJ P
?
ááP Q
Currency
ááR Z
,
ááZ [
[
áá\ ]
property
áá] e
:
ááe f
JsonRequired
áág s
]
áás t
BankAccountTypeááu Ñ
TypeááÖ â
,ááâ ä
stringááã ë
?ááë í
AccountNumberááì †
,áá† °
stringáá¢ ®
?áá® ©
Cciáá™ ≠
,áá≠ Æ
boolááØ ≥
IsActiveáá¥ º
=ááΩ æ
trueááø √
)áá√ ƒ
;ááƒ ≈
publicàà 
sealed
àà 
class
àà #
TransferReportRequest
àà )
{
àà* +
[
àà, -
BindRequired
àà- 9
]
àà9 :
public
àà; A
Guid
ààB F
BankAccountId
ààG T
{
ààU V
get
ààW Z
;
ààZ [
set
àà\ _
;
àà_ `
}
ààa b
[
ààc d
BindRequired
ààd p
]
ààp q
public
ààr x
decimalàày Ä
AmountààÅ á
{ààà â
getààä ç
;ààç é
setààè í
;ààí ì
}ààî ï
[ààñ ó
BindRequiredààó £
]àà£ §
publicàà• ´
DateOnlyàà¨ ¥
PaidAtààµ ª
{ààº Ω
getààæ ¡
;àà¡ ¬
setàà√ ∆
;àà∆ «
}àà» …
publicàà  –
stringàà— ◊
?àà◊ ÿ
OperationNumberààŸ Ë
{ààÈ Í
getààÎ Ó
;ààÓ Ô
setàà Û
;ààÛ Ù
}ààı ˆ
publicàà˜ ˝
intàà˛ Å
YearsààÇ á
{ààà â
getààä ç
;ààç é
setààè í
;ààí ì
}ààî ï
=ààñ ó
$numààò ô
;ààô ö
}ààõ ú
publicââ 
sealed
ââ 
record
ââ $
ApproveTransferRequest
ââ +
(
ââ+ ,
decimal
ââ, 3
?
ââ3 4
Amount
ââ5 ;
,
ââ; <
DateOnly
ââ= E
?
ââE F
PaidAt
ââG M
,
ââM N
string
ââO U
?
ââU V
OperationNumber
ââW f
)
ââf g
;
ââg h
publicää 
sealed
ää 
record
ää #
RejectTransferRequest
ää *
(
ää* +
string
ää+ 1
?
ää1 2
Reason
ää3 9
)
ää9 :
;
ää: ;
publicãã 
sealed
ãã 
record
ãã 
TransferReportDto
ãã &
(
ãã& '
Guid
ãã' +
Id
ãã, .
,
ãã. /
Guid
ãã0 4
ClientId
ãã5 =
,
ãã= >
string
ãã? E
Company
ããF M
,
ããM N
Guid
ããO S
ClientProductId
ããT c
,
ããc d
string
ããe k
Product
ããl s
,
ããs t
string
ããu {
?
ãã{ |

DomainNameãã} á
,ããá à
stringããâ è
ProductCurrencyããê ü
,ããü †
decimalãã° ®
Amountãã© Ø
,ããØ ∞
stringãã± ∑
Currencyãã∏ ¿
,ãã¿ ¡
DateOnlyãã¬  
PaidAtããÀ —
,ãã— “
stringãã” Ÿ
?ããŸ ⁄
OperationNumberãã€ Í
,ããÍ Î
intããÏ Ô
Yearsãã ı
,ããı ˆ
stringãã˜ ˝
?ãã˝ ˛
Accountããˇ Ü
,ããÜ á
boolããà å

HasReceiptããç ó
,ããó ò
stringããô ü
?ããü †"
ReceiptContentTypeãã° ≥
,ãã≥ ¥$
TransferReportStatusããµ …
Statusãã  –
,ãã– —
stringãã“ ÿ
?ããÿ Ÿ
RejectionReasonãã⁄ È
,ããÈ Í
DateTimeããÎ Û
	CreatedAtããÙ ˝
,ãã˝ ˛
DateTimeããˇ á
?ããá à

ReviewedAtããâ ì
)ããì î
;ããî ï∫s
GC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AuthController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str  
)  !
]! "
public 
sealed 
class 
AuthController "
(" #
RtresDbContext# 1
db2 4
,4 5
JwtSettings6 A
jwtB E
,E F
IMemoryCacheG S
cacheT Y
,Y Z"
IFirebaseTokenVerifier[ q
firebaser z
)z {
:| }
ControllerBase	~ å
{ 
public 

const 
string  
LoginRateLimitPolicy ,
=- .
$str/ 6
;6 7
const 	
int
 
MaxFailedAttempts 
=  !
$num" #
;# $
static 

readonly 
TimeSpan 
LockoutWindow *
=+ ,
TimeSpan- 5
.5 6
FromMinutes6 A
(A B
$numB D
)D E
;E F
sealed 

class 
FailedLogins 
{ 
public  &
int' *
Count+ 0
;0 1
}2 3
[ 
HttpPost 

(
 
$str 
) 
, 
EnableRateLimiting '
(' ( 
LoginRateLimitPolicy( <
)< =
]= >
public? E
asyncF K
TaskL P
<P Q
ActionResultQ ]
>] ^
Login_ d
(d e
LoginRequeste q
requestr y
,y z
CancellationToken	{ å
ct
ç è
)
è ê
{
ë í
var
ì ñ
failKey
ó û
=
û ü
$str
ü ¨
+
¨ ≠
request
≠ ¥
.
¥ µ
Email
µ ∫
.
∫ ª
Trim
ª ø
(
ø ¿
)
¿ ¡
.
¡ ¬
ToLowerInvariant
¬ “
(
“ ”
)
” ‘
;
‘ ’
if
÷ ÿ
(
ÿ Ÿ
cache
Ÿ ﬁ
.
ﬁ ﬂ
TryGetValue
ﬂ Í
(
Í Î
failKey
Î Ú
,
Ú Û
out
Û ˆ
FailedLogins
˜ É
?
É Ñ
fails
Ö ä
)
ä ã
&&
ã ç
fails
ç í
!
í ì
.
ì î
Count
î ô
>=
ô õ
MaxFailedAttempts
õ ¨
)
¨ ≠
return
≠ ≥

StatusCode
¥ æ
(
æ ø
$num
ø ¬
,
¬ √
new
√ ∆
{
∆ «
message
« Œ
=
Œ œ
$str
œ °
}
° ¢
)
¢ £
;
£ §
var
• ®
u
© ™
=
™ ´
await
´ ∞
db
± ≥
.
≥ ¥
UserAccounts
¥ ¿
.
¿ ¡"
SingleOrDefaultAsync
¡ ’
(
’ ÷
x
÷ ◊
=>
◊ Ÿ
x
Ÿ ⁄
.
⁄ €
Email
€ ‡
==
‡ ‚
request
‚ È
.
È Í
Email
Í Ô
&&
Ô Ò
x
Ò Ú
.
Ú Û
IsActive
Û ˚
,
˚ ¸
ct
¸ ˛
)
˛ ˇ
;
ˇ Ä
if
Å É
(
É Ñ
u
Ñ Ö
is
Ü à
null
â ç
||
ç è
new
è í
PasswordHasher
ì °
<
° ¢
UserAccount
¢ ≠
>
≠ Æ
(
Æ Ø
)
Ø ∞
.
∞ ±"
VerifyHashedPassword
± ≈
(
≈ ∆
u
∆ «
,
« »
u
» …
.
…  
PasswordHash
  ÷
,
÷ ◊
request
◊ ﬁ
.
ﬁ ﬂ
Password
ﬂ Á
)
Á Ë
==
Ë Í(
PasswordVerificationResult
Í Ñ
.
Ñ Ö
Failed
Ö ã
)
ã å
{
å ç
var
é ë
f
í ì
=
ì î
cache
î ô
.
ô ö
GetOrCreate
ö •
(
• ¶
failKey
¶ ≠
,
≠ Æ
e
Æ Ø
=>
Ø ±
{
± ≤
e
≤ ≥
.
≥ ¥-
AbsoluteExpirationRelativeToNow
¥ ”
=
” ‘
LockoutWindow
‘ ·
;
· ‚
return
‚ Ë
new
È Ï
FailedLogins
Ì ˘
(
˘ ˙
)
˙ ˚
;
˚ ¸
}
¸ ˝
)
˝ ˛
!
˛ ˇ
;
ˇ Ä
Interlocked
Å å
.
å ç
	Increment
ç ñ
(
ñ ó
ref
ó ö
f
õ ú
.
ú ù
Count
ù ¢
)
¢ £
;
£ §
return
• ´
Unauthorized
¨ ∏
(
∏ π
new
π º
{
Ω æ
message
æ ≈
=
≈ ∆
$str
∆ ﬂ
}
ﬂ ‡
)
‡ ·
;
· ‚
}
„ ‰
cache
Â Í
.
Í Î
Remove
Î Ò
(
Ò Ú
failKey
Ú ˘
)
˘ ˙
;
˙ ˚
var
¸ ˇ
c
Ä Å
=
Å Ç
u
Ç É
.
É Ñ
ClientId
Ñ å
is
ç è
Guid
ê î
clientId
ï ù
?
ù û
await
û £
db
§ ¶
.
¶ ß
Clients
ß Æ
.
Æ Ø
	FindAsync
Ø ∏
(
∏ π
[
π ∫
clientId
∫ ¬
]
¬ √
,
√ ƒ
ct
ƒ ∆
)
∆ «
:
« »
null
» Ã
;
Ã Õ
if
Œ –
(
– —
c
— “
is
” ’
not
÷ Ÿ
null
⁄ ﬁ
&&
ﬁ ‡
!
‡ ·
c
· ‚
.
‚ „
IsActive
„ Î
)
Î Ï
return
Ï Ú

StatusCode
Û ˝
(
˝ ˛
$num
˛ Å
,
Å Ç
new
Ç Ö
{
Ö Ü
message
Ü ç
=
ç é
$str
é ¡
}
¡ ¬
)
¬ √
;
√ ƒ
return
≈ À

SessionFor
Ã ÷
(
÷ ◊
jwt
◊ ⁄
,
⁄ €
u
€ ‹
,
‹ ›
c
› ﬁ
)
ﬁ ﬂ
;
ﬂ ‡
}
· ‚
const 	
string
 
GoogleRefused 
=  
$str! p
;p q
[ 
HttpPost 
( 
$str 
) 
, 
EnableRateLimiting +
(+ , 
LoginRateLimitPolicy, @
)@ A
]A B
publicC I
asyncJ O
TaskP T
<T U
ActionResultU a
>a b
Googlec i
(i j
GoogleLoginRequestj |
request	} Ñ
,
Ñ Ö
CancellationToken
Ü ó
ct
ò ö
)
ö õ
{
ú ù
var
û °
identity
¢ ™
=
™ ´
await
´ ∞
firebase
± π
.
π ∫
VerifyAsync
∫ ≈
(
≈ ∆
request
∆ Õ
.
Õ Œ
IdToken
Œ ’
,
’ ÷
ct
÷ ÿ
)
ÿ Ÿ
;
Ÿ ⁄
if
€ ›
(
› ﬁ
identity
ﬁ Ê
is
Á È
null
Í Ó
||
Ó 
!
 Ò
identity
Ò ˘
.
˘ ˙
EmailVerified
˙ á
)
á à
return
à é
Unauthorized
è õ
(
õ ú
new
ú ü
{
ü †
message
† ß
=
ß ®
GoogleRefused
® µ
}
µ ∂
)
∂ ∑
;
∑ ∏
var
π º
email
Ω ¬
=
¬ √
identity
√ À
.
À Ã
Email
Ã —
.
— “
Trim
“ ÷
(
÷ ◊
)
◊ ÿ
.
ÿ Ÿ
ToLower
Ÿ ‡
(
‡ ·
)
· ‚
;
‚ „
var
‰ Á
u
Ë È
=
È Í
await
Í Ô
db
 Ú
.
Ú Û
UserAccounts
Û ˇ
.
ˇ Ä
AsNoTracking
Ä å
(
å ç
)
ç é
.
é è!
FirstOrDefaultAsync
è ¢
(
¢ £
x
£ §
=>
§ ¶
x
¶ ß
.
ß ®
IsActive
® ∞
&&
∞ ≤
x
≤ ≥
.
≥ ¥
Email
¥ π
.
π ∫
Trim
∫ æ
(
æ ø
)
ø ¿
.
¿ ¡
ToLower
¡ »
(
» …
)
…  
==
  Ã
email
Ã —
,
— “
ct
“ ‘
)
‘ ’
;
’ ÷
if
◊ Ÿ
(
Ÿ ⁄
u
⁄ €
is
‹ ﬁ
null
ﬂ „
)
„ ‰
return
‰ Í
Unauthorized
Î ˜
(
˜ ¯
new
¯ ˚
{
˚ ¸
message
¸ É
=
É Ñ
GoogleRefused
Ñ ë
}
ë í
)
í ì
;
ì î
var
ï ò
c
ô ö
=
ö õ
u
õ ú
.
ú ù
ClientId
ù •
is
¶ ®
Guid
© ≠
clientId
Æ ∂
?
∂ ∑
await
∑ º
db
Ω ø
.
ø ¿
Clients
¿ «
.
« »
AsNoTracking
» ‘
(
‘ ’
)
’ ÷
.
÷ ◊!
FirstOrDefaultAsync
◊ Í
(
Í Î
x
Î Ï
=>
Ï Ó
x
Ó Ô
.
Ô 
Id
 Ú
==
Ú Ù
clientId
Ù ¸
,
¸ ˝
ct
˝ ˇ
)
ˇ Ä
:
Ä Å
null
Å Ö
;
Ö Ü
if
á â
(
â ä
c
ä ã
is
å é
not
è í
null
ì ó
&&
ó ô
!
ô ö
c
ö õ
.
õ ú
IsActive
ú §
)
§ •
return
• ´

StatusCode
¨ ∂
(
∂ ∑
$num
∑ ∫
,
∫ ª
new
ª æ
{
æ ø
message
ø ∆
=
∆ «
$str
« ˙
}
˙ ˚
)
˚ ¸
;
¸ ˝
return
˛ Ñ

SessionFor
Ö è
(
è ê
jwt
ê ì
,
ì î
u
î ï
,
ï ñ
c
ñ ó
)
ó ò
;
ò ô
}
ö õ
internal 
static 
ActionResult  

SessionFor! +
(+ ,
JwtSettings, 7
jwt8 ;
,; <
UserAccount= H
uI J
,J K
ClientL R
?R S
cT U
)U V
{W X
varY \
claims] c
=c d
newd g
Listh l
<l m
Claimm r
>r s
{s t
newt w
(w x$
JwtRegisteredClaimNames	x è
.
è ê
Sub
ê ì
,
ì î
u
î ï
.
ï ñ
Id
ñ ò
.
ò ô
ToString
ô °
(
° ¢
)
¢ £
)
£ §
,
§ •
new
• ®
(
® ©

ClaimTypes
© ≥
.
≥ ¥
NameIdentifier
¥ ¬
,
¬ √
u
√ ƒ
.
ƒ ≈
Id
≈ «
.
« »
ToString
» –
(
– —
)
— “
)
“ ”
,
” ‘
new
‘ ◊
(
◊ ÿ

ClaimTypes
ÿ ‚
.
‚ „
Role
„ Á
,
Á Ë
u
Ë È
.
È Í
Role
Í Ó
.
Ó Ô
ToString
Ô ˜
(
˜ ¯
)
¯ ˘
)
˘ ˙
}
˙ ˚
;
˚ ¸
if
˝ ˇ
(
ˇ Ä
u
Ä Å
.
Å Ç
ClientId
Ç ä
is
ã ç
Guid
é í
id
ì ï
)
ï ñ
claims
ñ ú
.
ú ù
Add
ù †
(
† °
new
° §
Claim
• ™
(
™ ´
$str
´ ∂
,
∂ ∑
id
∑ π
.
π ∫
ToString
∫ ¬
(
¬ √
)
√ ƒ
)
ƒ ≈
)
≈ ∆
;
∆ «
var
» À
token
Ã —
=
— “
new
“ ’
JwtSecurityToken
÷ Ê
(
Ê Á
jwt
Á Í
.
Í Î
Issuer
Î Ò
,
Ò Ú
jwt
Ú ı
.
ı ˆ
Audience
ˆ ˛
,
˛ ˇ
claims
ˇ Ö
,
Ö Ü
expires
Ü ç
:
ç é
DateTime
é ñ
.
ñ ó
UtcNow
ó ù
.
ù û
AddHours
û ¶
(
¶ ß
$num
ß ®
)
® ©
,
© ™ 
signingCredentials
™ º
:
º Ω
new
Ω ¿ 
SigningCredentials
¡ ”
(
” ‘
jwt
‘ ◊
.
◊ ÿ

SigningKey
ÿ ‚
,
‚ „ 
SecurityAlgorithms
„ ı
.
ı ˆ

HmacSha256
ˆ Ä
)
Ä Å
)
Å Ç
;
Ç É
var
Ñ á
initials
à ê
=
ê ë
string
ë ó
.
ó ò
Concat
ò û
(
û ü
u
ü †
.
† °
Name
° •
.
• ¶
Split
¶ ´
(
´ ¨
$char
¨ Ø
,
Ø ∞ 
StringSplitOptions
∞ ¬
.
¬ √ 
RemoveEmptyEntries
√ ’
)
’ ÷
.
÷ ◊
Take
◊ €
(
€ ‹
$num
‹ ›
)
› ﬁ
.
ﬁ ﬂ
Select
ﬂ Â
(
Â Ê
x
Ê Á
=>
Á È
x
È Í
[
Í Î
$num
Î Ï
]
Ï Ì
)
Ì Ó
)
Ó Ô
.
Ô 
ToUpperInvariant
 Ä
(
Ä Å
)
Å Ç
;
Ç É
return
Ñ ä
new
ã é
OkObjectResult
è ù
(
ù û
new
û °
{
¢ £
token
£ ®
=
® ©
new
© ¨%
JwtSecurityTokenHandler
≠ ƒ
(
ƒ ≈
)
≈ ∆
.
∆ «

WriteToken
« —
(
— “
token
“ ◊
)
◊ ÿ
,
ÿ Ÿ
user
Ÿ ›
=
› ﬁ
new
ﬁ ·
{
· ‚
name
‚ Ê
=
Ê Á
u
Á Ë
.
Ë È
Name
È Ì
,
Ì Ó
initials
Ó ˆ
,
ˆ ˜

clientName
˜ Å
=
Å Ç
c
Ç É
?
É Ñ
.
Ñ Ö
CompanyName
Ö ê
,
ê ë
role
ë ï
=
ï ñ
u
ñ ó
.
ó ò
Role
ò ú
.
ú ù
ToString
ù •
(
• ¶
)
¶ ß
}
ß ®
}
® ©
)
© ™
;
™ ´
}
¨ ≠
} ÿÖ
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.Purchases.cs
	namespace		 	
Rtres		
 
.		 
Api		 
.		 
Controllers		 
;		  
public 
sealed 
partial 
class 
AdminController +
{ 
[ 
HttpGet 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
	Purchases$ -
(- .
int. 1
year2 6
,6 7
int8 ;
?; <
month= B
,B C
CancellationTokenD U
ctV X
)X Y
{ 
var 
( 
from 
, 
to 
) 
= 
Period 
(  
month  %
,% &
year' +
)+ ,
;, -
var 
igvRate 
= 
await 
db 
. 
IgvRateAsync +
(+ ,
ct, .
). /
;/ 0
var 
items 
= 
await 
db 
. 
	Purchases &
.& '
Where' ,
(, -
x- .
=>/ 1
x2 3
.3 4
Period4 :
>=; =
from> B
&&C E
xF G
.G H
PeriodH N
<=O Q
toR T
)T U
.U V
OrderByDescendingV g
(g h
xh i
=>j l
xm n
.n o
	IssueDateo x
)x y
.y z
ThenBy	z Ä
(
Ä Å
x
Å Ç
=>
É Ö
x
Ü á
.
á à
SupplierName
à î
)
î ï
.
ï ñ
ToListAsync
ñ °
(
° ¢
ct
¢ §
)
§ •
;
• ¶
return 
Ok 
( 
new 
{ 	
items 
= 
items 
. 
Select  
(  !
x! "
=># %
PurchaseDto& 1
(1 2
x2 3
,3 4
igvRate5 <
)< =
)= >
,> ?
totalPen 
= 
Math 
. 
Round !
(! "
items" '
.' (
Sum( +
(+ ,
x, -
=>. 0
Signed1 7
(7 8
x8 9
,9 :
x; <
.< =
TotalPen= E
)E F
)F G
,G H
$numI J
)J K
,K L
creditoFiscalPen 
= 
Math #
.# $
Round$ )
() *
items* /
./ 0
Sum0 3
(3 4
x4 5
=>6 8
x9 :
.: ;
TaxCreditPen; G
)G H
,H I
$numJ K
)K L
,L M
igvSinCreditoPen 
= 
Math #
.# $
Round$ )
() *
items* /
./ 0
Where0 5
(5 6
x6 7
=>8 :
!; <
x< =
.= >
GivesTaxCredit> L
)L M
.M N
SumN Q
(Q R
xR S
=>T V
SignedW ]
(] ^
x^ _
,_ `
xa b
.b c
IgvPenc i
)i j
)j k
,k l
$numm n
)n o
,o p
} 	
)	 

;
 
} 
[ 
HttpPost 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
CreatePurchase$ 2
(2 3
PurchaseRequest3 B
requestC J
,J K
CancellationTokenL ]
ct^ `
)` a
{ 
var   
purchase   
=   
new   
Purchase   #
(  # $
)  $ %
;  % &
if!! 

(!! 
await!! 
ApplyPurchaseAsync!! $
(!!$ %
purchase!!% -
,!!- .
request!!/ 6
,!!6 7
ct!!8 :
)!!: ;
is!!< >
{!!? @
}!!A B
error!!C H
)!!H I
return!!J P
error!!Q V
;!!V W
db"" 

.""
 
	Purchases"" 
."" 
Add"" 
("" 
purchase"" !
)""! "
;""" #
if## 

(## 
request## 
.## 
CreateExpense## !
&&##" $
await##% *
LinkExpenseAsync##+ ;
(##; <
purchase##< D
,##D E
request##F M
.##M N
ExpenseCategoryId##N _
,##_ `
ct##a c
)##c d
is##e g
{##h i
}##j k
expenseError##l x
)##x y
return	##z Ä
expenseError
##Å ç
;
##ç é
await$$ 
db$$ 
.$$ 
SaveChangesAsync$$ !
($$! "
ct$$" $
)$$$ %
;$$% &
return%% 
Created%% 
(%% 
$"%% 
$str%% .
{%%. /
purchase%%/ 7
.%%7 8
Id%%8 :
}%%: ;
"%%; <
,%%< =
PurchaseDto%%> I
(%%I J
purchase%%J R
,%%R S
await%%T Y
db%%Z \
.%%\ ]
IgvRateAsync%%] i
(%%i j
ct%%j l
)%%l m
)%%m n
)%%n o
;%%o p
}&& 
[(( 
HttpPut(( 
((( 
$str(( "
)((" #
]((# $
public)) 

async)) 
Task)) 
<)) 
ActionResult)) "
>))" #
UpdatePurchase))$ 2
())2 3
Guid))3 7
id))8 :
,)): ;
PurchaseRequest))< K
request))L S
,))S T
CancellationToken))U f
ct))g i
)))i j
{** 
var++ 
purchase++ 
=++ 
await++ 
db++ 
.++  
	Purchases++  )
.++) *
	FindAsync++* 3
(++3 4
[++4 5
id++5 7
]++7 8
,++8 9
ct++: <
)++< =
;++= >
if++? A
(++B C
purchase++C K
is++L N
null++O S
)++S T
return++U [
NotFound++\ d
(++d e
)++e f
;++f g
if,, 

(,, 
await,, 
ApplyPurchaseAsync,, $
(,,$ %
purchase,,% -
,,,- .
request,,/ 6
,,,6 7
ct,,8 :
),,: ;
is,,< >
{,,? @
},,A B
error,,C H
),,H I
return,,J P
error,,Q V
;,,V W
if-- 

(-- 
(-- 
request-- 
.-- 
CreateExpense-- "
||--# %
purchase--& .
.--. /
	ExpenseId--/ 8
is--9 ;
not--< ?
null--@ D
)--D E
&&--F H
await--I N
LinkExpenseAsync--O _
(--_ `
purchase--` h
,--h i
request--j q
.--q r
ExpenseCategoryId	--r É
,
--É Ñ
ct
--Ö á
)
--á à
is
--â ã
{
--å ç
}
--é è
expenseError
--ê ú
)
--ú ù
return
--û §
expenseError
--• ±
;
--± ≤
await.. 
db.. 
... 
SaveChangesAsync.. !
(..! "
ct.." $
)..$ %
;..% &
return// 
Ok// 
(// 
PurchaseDto// 
(// 
purchase// &
,//& '
await//( -
db//. 0
.//0 1
IgvRateAsync//1 =
(//= >
ct//> @
)//@ A
)//A B
)//B C
;//C D
}00 
[33 

HttpDelete33 
(33 
$str33 %
)33% &
]33& '
public44 

async44 
Task44 
<44 
ActionResult44 "
>44" #
DeletePurchase44$ 2
(442 3
Guid443 7
id448 :
,44: ;
bool44< @
deleteExpense44A N
,44N O
CancellationToken44P a
ct44b d
)44d e
{55 
var66 
purchase66 
=66 
await66 
db66 
.66  
	Purchases66  )
.66) *
	FindAsync66* 3
(663 4
[664 5
id665 7
]667 8
,668 9
ct66: <
)66< =
;66= >
if66? A
(66B C
purchase66C K
is66L N
null66O S
)66S T
return66U [
NotFound66\ d
(66d e
)66e f
;66f g
if77 

(77 
deleteExpense77 
&&77 
purchase77 %
.77% &
	ExpenseId77& /
is770 2
Guid773 7
	expenseId778 A
&&77B D
await77E J
db77K M
.77M N
Expenses77N V
.77V W
	FindAsync77W `
(77` a
[77a b
	expenseId77b k
]77k l
,77l m
ct77n p
)77p q
is77r t
{77u v
}77w x
expense	77y Ä
)
77Ä Å
db
77Ç Ñ
.
77Ñ Ö
Expenses
77Ö ç
.
77ç é
Remove
77é î
(
77î ï
expense
77ï ú
)
77ú ù
;
77ù û
db88 

.88
 
	Purchases88 
.88 
Remove88 
(88 
purchase88 $
)88$ %
;88% &
await88' ,
db88- /
.88/ 0
SaveChangesAsync880 @
(88@ A
ct88A C
)88C D
;88D E
return88F L
	NoContent88M V
(88V W
)88W X
;88X Y
}99 
[;; 
HttpGet;; 
(;; 
$str;; (
);;( )
];;) *
public<< 

async<< 
Task<< 
<<< 
IActionResult<< #
><<# $
PurchaseTemplate<<% 5
(<<5 6
CancellationToken<<6 G
ct<<H J
)<<J K
=><<L N
File<<O S
(<<S T
CreateWorkbook<<T b
(<<b c
new== 
(== 
$str== 
,== 
true== 
,== 
$str== b
)==b c
,==c d
new>> 
(>> 
$str>> 
,>> 
false>> 
,>> 
$str>> P
)>>P Q
,>>Q R
new?? 
(?? 
$str?? 
,?? 
true??  
,??  !
$str??" 7
,??7 8
Enum??9 =
.??= >
GetNames??> F
<??F G 
PurchaseDocumentType??G [
>??[ \
(??\ ]
)??] ^
)??^ _
,??_ `
new@@ 
(@@ 
$str@@ 
,@@ 
false@@ 
,@@ 
$str@@ T
)@@T U
,@@U V
newAA 
(AA 
$strAA 
,AA 
trueAA 
,AA 
$strAA 4
)AA4 5
,AA5 6
newBB 
(BB 
$strBB 
,BB 
trueBB !
,BB! "
$strBB# b
)BBb c
,BBc d
newCC 
(CC 
$strCC 
,CC 
trueCC  
,CC  !
$strCC" >
)CC> ?
,CC? @
newDD 
(DD 
$strDD 
,DD 
trueDD 
,DD 
$strDD .
,DD. /
[DD0 1
$strDD1 6
,DD6 7
$strDD8 =
,DD= >
$strDD? D
]DDD E
)DDE F
,DDF G
newEE 
(EE 
$strEE 
,EE 
trueEE 
,EE 
$strEE G
)EEG H
,EEH I
newFF 
(FF 
$strFF 
,FF 
trueFF 
,FF 
$strFF >
)FF> ?
,FF? @
newGG 
(GG 
$strGG 
,GG 
falseGG 
,GG  
$strGG! K
)GGK L
,GGL M
newHH 
(HH 
$strHH $
,HH$ %
falseHH& +
,HH+ ,
$str	HH- ã
,
HHã å
[
HHç é
$str
HHé í
,
HHí ì
$str
HHî ò
]
HHò ô
)
HHô ö
,
HHö õ
newII 
(II 
$strII 
,II 
falseII $
,II$ %
$strII& b
,IIb c
[IId e
..IIe g
awaitIIh m
dbIIn p
.IIp q
ExpenseCategories	IIq Ç
.
IIÇ É
OrderBy
IIÉ ä
(
IIä ã
x
IIã å
=>
IIç è
x
IIê ë
.
IIë í
	SortOrder
IIí õ
)
IIõ ú
.
IIú ù
Select
IIù £
(
II£ §
x
II§ •
=>
II¶ ®
x
II© ™
.
II™ ´
Name
II´ Ø
)
IIØ ∞
.
II∞ ±
ToListAsync
II± º
(
IIº Ω
ct
IIΩ ø
)
IIø ¿
]
II¿ ¡
)
II¡ ¬
)
II¬ √
,
II√ ƒ
$strJJ K
,JJK L
$strJJM e
)JJe f
;JJf g
[LL 
HttpPostLL 
(LL 
$strLL  
)LL  !
]LL! "
publicMM 

asyncMM 
TaskMM 
<MM 
ActionResultMM "
>MM" #
ImportPurchasesMM$ 3
(MM3 4
	IFormFileMM4 =
fileMM> B
,MMB C
CancellationTokenMMD U
ctMMV X
)MMX Y
{NN 
varOO 

categoriesOO 
=OO 
awaitOO 
dbOO !
.OO! "
ExpenseCategoriesOO" 3
.OO3 4
ToListAsyncOO4 ?
(OO? @
ctOO@ B
)OOB C
;OOC D
varPP 
(PP 
failurePP 
,PP 
createdPP 
,PP 
errorsPP %
)PP% &
=PP' (
awaitPP) .
ImportPP/ 5
(PP5 6
filePP6 :
,PP: ;
$strPP< E
,PPE F
asyncPPG L
(PPM N
rowPPN Q
,PPQ R
	rowNumberPPS \
,PP\ ]
errorsPP^ d
)PPd e
=>PPf h
{QQ 	
varRR 

parseErrorRR 
=RR 
ParsePurchaseRowRR -
(RR- .
rowRR. 1
,RR1 2

categoriesRR3 =
,RR= >
outRR? B
varRRC F
requestRRG N
)RRN O
;RRO P
varSS 
purchaseSS 
=SS 
newSS 
PurchaseSS '
(SS' (
)SS( )
;SS) *
varTT 
errorTT 
=TT 

parseErrorTT "
??TT# %
MessageTT& -
(TT- .
awaitTT. 3
ApplyPurchaseAsyncTT4 F
(TTF G
purchaseTTG O
,TTO P
requestTTQ X
!TTX Y
,TTY Z
ctTT[ ]
)TT] ^
)TT^ _
;TT_ `
ifUU 
(UU 
errorUU 
isUU 
nullUU 
&&UU  
requestUU! (
!UU( )
.UU) *
CreateExpenseUU* 7
)UU7 8
errorUU9 >
=UU? @
MessageUUA H
(UUH I
awaitUUI N
LinkExpenseAsyncUUO _
(UU_ `
purchaseUU` h
,UUh i
requestUUj q
.UUq r
ExpenseCategoryId	UUr É
,
UUÉ Ñ
ct
UUÖ á
)
UUá à
)
UUà â
;
UUâ ä
ifVV 
(VV 
errorVV 
isVV 
notVV 
nullVV !
)VV! "
{VV# $
errorsVV% +
.VV+ ,
AddVV, /
(VV/ 0
newVV0 3
(VV3 4
	rowNumberVV4 =
,VV= >
errorVV? D
)VVD E
)VVE F
;VVF G
returnVVH N
falseVVO T
;VVT U
}VVV W
dbWW 
.WW 
	PurchasesWW 
.WW 
AddWW 
(WW 
purchaseWW %
)WW% &
;WW& '
awaitWW( -
dbWW. 0
.WW0 1
SaveChangesAsyncWW1 A
(WWA B
ctWWB D
)WWD E
;WWE F
returnWWG M
trueWWN R
;WWR S
}XX 	
,XX	 

ctXX 
)XX 
;XX 
returnYY 
failureYY 
??YY 
OkYY 
(YY 
newYY  
{YY! "
createdYY# *
,YY* +
skippedYY, 3
=YY4 5
errorsYY6 <
.YY< =
CountYY= B
,YYB C
errorsYYD J
}YYK L
)YYL M
;YYM N
}ZZ 
private\\ 
static\\ 
string\\ 
?\\ 
Message\\ "
(\\" #
ActionResult\\# /
?\\/ 0
result\\1 7
)\\7 8
=>\\9 ;
result\\< B
switch\\C I
{]] 
null^^ 
=>^^ 
null^^ 
,^^ 
ObjectResult__ 
{__ 
Value__ 
:__ 
var__ !
value__" '
}__( )
=>__* ,
value__- 2
?__2 3
.__3 4
GetType__4 ;
(__; <
)__< =
.__= >
GetProperty__> I
(__I J
$str__J S
)__S T
?__T U
.__U V
GetValue__V ^
(__^ _
value___ d
)__d e
as__f h
string__i o
??__p r
$str	__s É
,
__É Ñ
_`` 	
=>``
 
$str`` 
,`` 
}aa 
;aa 
privatecc 
staticcc 
stringcc 
?cc 
ParsePurchaseRowcc +
(cc+ ,
IXLRowcc, 2
rowcc3 6
,cc6 7
IReadOnlyListcc8 E
<ccE F
ExpenseCategoryccF U
>ccU V

categoriesccW a
,cca b
outccc f
PurchaseRequestccg v
?ccv w
requestccx 
)	cc Ä
{dd 
requestee 
=ee 
nullee 
;ee 
ifff 

(ff 
ReadDateff 
(ff 
rowff 
.ff 
Cellff 
(ff 
$numff 
)ff  
)ff  !
isff" $
notff% (
DateOnlyff) 1
	issueDateff2 ;
)ff; <
returnff= C
$strffD v
;ffv w
ifgg 

(gg 
!gg 
TryEnumgg 
<gg  
PurchaseDocumentTypegg )
>gg) *
(gg* +
Cellgg+ /
(gg/ 0
rowgg0 3
,gg3 4
$numgg5 6
)gg6 7
,gg7 8
outgg9 <
vargg= @
typeggA E
)ggE F
)ggF G
returnggH N
$"ggO Q
$strggQ l
{ggl m
stringggm s
.ggs t
Joinggt x
(ggx y
$strggy }
,gg} ~
Enum	gg É
.
ggÉ Ñ
GetNames
ggÑ å
<
ggå ç"
PurchaseDocumentType
ggç °
>
gg° ¢
(
gg¢ £
)
gg£ §
)
gg§ •
}
gg• ¶
$str
gg¶ ß
"
ggß ®
;
gg® ©
ifhh 

(hh 
ReadDecimalhh 
(hh 
rowhh 
.hh 
Cellhh  
(hh  !
$numhh! "
)hh" #
)hh# $
ishh% '
nothh( +
decimalhh, 3
taxBasehh4 ;
)hh; <
returnhh= C
$strhhD a
;hha b
ifii 

(ii 
ReadDecimalii 
(ii 
rowii 
.ii 
Cellii  
(ii  !
$numii! #
)ii# $
)ii$ %
isii& (
notii) ,
decimalii- 4
igvii5 8
)ii8 9
returnii: @
$striiA j
;iij k
varjj 

nonTaxablejj 
=jj 
stringjj 
.jj  
IsNullOrWhiteSpacejj  2
(jj2 3
Celljj3 7
(jj7 8
rowjj8 ;
,jj; <
$numjj= ?
)jj? @
)jj@ A
?jjB C
$numjjD F
:jjG H
ReadDecimaljjI T
(jjT U
rowjjU X
.jjX Y
CelljjY ]
(jj] ^
$numjj^ `
)jj` a
)jja b
??jjc e
-jjf g
$numjjg i
;jji j
ifkk 

(kk 

nonTaxablekk 
<kk 
$numkk 
)kk 
returnkk "
$strkk# U
;kkU V
ifll 

(ll 
	ReadYesNoll 
(ll 
Cellll 
(ll 
rowll 
,ll 
$numll  "
)ll" #
,ll# $
defaultValuell% 1
:ll1 2
truell3 7
)ll7 8
isll9 ;
notll< ?
boolll@ D
taxedllE J
)llJ K
returnllL R
$str	llS Ç
;
llÇ É
Guidmm 
?mm 

categoryIdmm 
=mm 
nullmm 
;mm  
varnn 
categoryTextnn 
=nn 
Foldnn 
(nn  
Cellnn  $
(nn$ %
rownn% (
,nn( )
$numnn* ,
)nn, -
)nn- .
;nn. /
ifoo 

(oo 
categoryTextoo 
.oo 
Lengthoo 
>oo  !
$numoo" #
)oo# $
{pp 	
ifqq 
(qq 

categoriesqq 
.qq 
FirstOrDefaultqq )
(qq) *
xqq* +
=>qq, .
Foldqq/ 3
(qq3 4
xqq4 5
.qq5 6
Nameqq6 :
)qq: ;
==qq< >
categoryTextqq? K
||qqL N
xqqO P
.qqP Q
CodeqqQ U
isqqV X
notqqY \
nullqq] a
&&qqb d
Foldqqe i
(qqi j
xqqj k
.qqk l
Codeqql p
)qqp q
==qqr t
categoryText	qqu Å
)
qqÅ Ç
is
qqÉ Ö
not
qqÜ â
{
qqä ã
}
qqå ç
category
qqé ñ
)
qqñ ó
return
qqò û
$str
qqü „
;
qq„ ‰

categoryIdrr 
=rr 
categoryrr !
.rr! "
Idrr" $
;rr$ %
}ss 	
requesttt 
=tt 
newtt 
PurchaseRequesttt %
(tt% &
	issueDatett& /
,tt/ 0
EmptyToNulltt1 <
(tt< =
Celltt= A
(ttA B
rowttB E
,ttE F
$numttG H
)ttH I
)ttI J
,ttJ K
typettL P
,ttP Q
CellttR V
(ttV W
rowttW Z
,ttZ [
$numtt\ ]
)tt] ^
.tt^ _
Trimtt_ c
(ttc d
)ttd e
,tte f
Cellttg k
(ttk l
rowttl o
,tto p
$numttq r
)ttr s
.tts t
Trimttt x
(ttx y
)tty z
,ttz {
Cell	tt| Ä
(
ttÄ Å
row
ttÅ Ñ
,
ttÑ Ö
$num
ttÜ á
)
ttá à
.
ttà â
Trim
ttâ ç
(
ttç é
)
tté è
,
ttè ê
Cell
ttë ï
(
ttï ñ
row
ttñ ô
,
ttô ö
$num
ttõ ú
)
ttú ù
.
ttù û
Trim
ttû ¢
(
tt¢ £
)
tt£ §
,
tt§ •
Celluu 
(uu 
rowuu 
,uu 
$numuu 
)uu 
.uu 
Trimuu 
(uu 
)uu 
.uu  
ToUpperInvariantuu  0
(uu0 1
)uu1 2
,uu2 3
taxBaseuu4 ;
,uu; <
igvuu= @
,uu@ A

nonTaxableuuB L
,uuL M
taxeduuN S
,uuS T
CreateExpenseuuU b
:uub c

categoryIduud n
isuuo q
notuur u
nulluuv z
,uuz {
ExpenseCategoryId	uu| ç
:
uuç é

categoryId
uuè ô
)
uuô ö
;
uuö õ
returnvv 
nullvv 
;vv 
}ww 
privatezz 
asynczz 
Taskzz 
<zz 
ActionResultzz #
?zz# $
>zz$ %
ApplyPurchaseAsynczz& 8
(zz8 9
Purchasezz9 A
purchasezzB J
,zzJ K
PurchaseRequestzzL [
rzz\ ]
,zz] ^
CancellationTokenzz_ p
ctzzq s
)zzs t
{{{ 
var|| 
supplierTaxId|| 
=|| 
(|| 
r|| 
.|| 
SupplierTaxId|| ,
??||- /
$str||0 2
)||2 3
.||3 4
Trim||4 8
(||8 9
)||9 :
;||: ;
var}} 
currency}} 
=}} 
(}} 
r}} 
.}} 
Currency}} "
??}}# %
$str}}& (
)}}( )
.}}) *
Trim}}* .
(}}. /
)}}/ 0
.}}0 1
ToUpperInvariant}}1 A
(}}A B
)}}B C
;}}C D
if~~ 

(~~ 
ValidatePurchase~~ 
(~~ 
r~~ 
,~~ 
supplierTaxId~~  -
,~~- .
currency~~/ 7
)~~7 8
is~~9 ;
string~~< B
error~~C H
)~~H I
return~~J P

BadRequest~~Q [
(~~[ \
new~~\ _
{~~` a
message~~b i
=~~j k
error~~l q
}~~r s
)~~s t
;~~t u
if 

( 
ParsePurchasePeriod 
(  
r  !
,! "
out# &
var' *
period+ 1
)1 2
is3 5
string6 <
periodError= H
)H I
returnJ P

BadRequestQ [
([ \
new\ _
{` a
messageb i
=j k
periodErrorl w
}x y
)y z
;z {
var
ÅÅ 
series
ÅÅ 
=
ÅÅ 
(
ÅÅ 
r
ÅÅ 
.
ÅÅ 
Series
ÅÅ 
??
ÅÅ !
$str
ÅÅ" $
)
ÅÅ$ %
.
ÅÅ% &
Trim
ÅÅ& *
(
ÅÅ* +
)
ÅÅ+ ,
.
ÅÅ, -
ToUpperInvariant
ÅÅ- =
(
ÅÅ= >
)
ÅÅ> ?
;
ÅÅ? @
var
ÅÅA D
number
ÅÅE K
=
ÅÅL M
r
ÅÅN O
.
ÅÅO P
Number
ÅÅP V
.
ÅÅV W
Trim
ÅÅW [
(
ÅÅ[ \
)
ÅÅ\ ]
.
ÅÅ] ^
	TrimStart
ÅÅ^ g
(
ÅÅg h
$char
ÅÅh k
)
ÅÅk l
;
ÅÅl m
if
ÅÅn p
(
ÅÅq r
number
ÅÅr x
.
ÅÅx y
Length
ÅÅy 
==ÅÅÄ Ç
$numÅÅÉ Ñ
)ÅÅÑ Ö
numberÅÅÜ å
=ÅÅç é
$strÅÅè í
;ÅÅí ì
if
ÇÇ 

(
ÇÇ 
await
ÇÇ 
db
ÇÇ 
.
ÇÇ 
	Purchases
ÇÇ 
.
ÇÇ 
AnyAsync
ÇÇ '
(
ÇÇ' (
x
ÇÇ( )
=>
ÇÇ* ,
x
ÇÇ- .
.
ÇÇ. /
Id
ÇÇ/ 1
!=
ÇÇ2 4
purchase
ÇÇ5 =
.
ÇÇ= >
Id
ÇÇ> @
&&
ÇÇA C
x
ÇÇD E
.
ÇÇE F
SupplierTaxId
ÇÇF S
==
ÇÇT V
supplierTaxId
ÇÇW d
&&
ÇÇe g
x
ÇÇh i
.
ÇÇi j
DocumentType
ÇÇj v
==
ÇÇw y
r
ÇÇz {
.
ÇÇ{ |
DocumentTypeÇÇ| à
&&ÇÇâ ã
xÇÇå ç
.ÇÇç é
SeriesÇÇé î
==ÇÇï ó
seriesÇÇò û
&&ÇÇü °
xÇÇ¢ £
.ÇÇ£ §
NumberÇÇ§ ™
==ÇÇ´ ≠
numberÇÇÆ ¥
,ÇÇ¥ µ
ctÇÇ∂ ∏
)ÇÇ∏ π
)ÇÇπ ∫
return
ÉÉ 
Conflict
ÉÉ 
(
ÉÉ 
new
ÉÉ 
{
ÉÉ  !
message
ÉÉ" )
=
ÉÉ* +
$"
ÉÉ, .
$str
ÉÉ. L
{
ÉÉL M
series
ÉÉM S
}
ÉÉS T
$str
ÉÉT U
{
ÉÉU V
number
ÉÉV \
}
ÉÉ\ ]
$str
ÉÉ] o
"
ÉÉo p
}
ÉÉq r
)
ÉÉr s
;
ÉÉs t
purchase
ÖÖ 
.
ÖÖ 
	IssueDate
ÖÖ 
=
ÖÖ 
r
ÖÖ 
.
ÖÖ 
	IssueDate
ÖÖ (
;
ÖÖ( )
purchase
ÖÖ* 2
.
ÖÖ2 3
Period
ÖÖ3 9
=
ÖÖ: ;
period
ÖÖ< B
;
ÖÖB C
purchase
ÖÖD L
.
ÖÖL M
DocumentType
ÖÖM Y
=
ÖÖZ [
r
ÖÖ\ ]
.
ÖÖ] ^
DocumentType
ÖÖ^ j
;
ÖÖj k
purchase
ÖÖl t
.
ÖÖt u
Series
ÖÖu {
=
ÖÖ| }
seriesÖÖ~ Ñ
;ÖÖÑ Ö
purchaseÖÖÜ é
.ÖÖé è
NumberÖÖè ï
=ÖÖñ ó
numberÖÖò û
;ÖÖû ü
purchase
ÜÜ 
.
ÜÜ 
SupplierTaxId
ÜÜ 
=
ÜÜ  
supplierTaxId
ÜÜ! .
;
ÜÜ. /
purchase
ÜÜ0 8
.
ÜÜ8 9
SupplierName
ÜÜ9 E
=
ÜÜF G
r
ÜÜH I
.
ÜÜI J
SupplierName
ÜÜJ V
.
ÜÜV W
Trim
ÜÜW [
(
ÜÜ[ \
)
ÜÜ\ ]
;
ÜÜ] ^
purchase
ÜÜ_ g
.
ÜÜg h
Currency
ÜÜh p
=
ÜÜq r
currency
ÜÜs {
;
ÜÜ{ |
purchase
áá 
.
áá 
TaxBase
áá 
=
áá 
r
áá 
.
áá 
TaxBase
áá $
;
áá$ %
purchase
áá& .
.
áá. /
Igv
áá/ 2
=
áá3 4
r
áá5 6
.
áá6 7
Igv
áá7 :
;
áá: ;
purchase
áá< D
.
ááD E

NonTaxable
ááE O
=
ááP Q
r
ááR S
.
ááS T

NonTaxable
ááT ^
;
áá^ _
purchase
áá` h
.
ááh i
Total
áái n
=
ááo p
r
ááq r
.
áár s
TaxBase
áás z
+
áá{ |
r
áá} ~
.
áá~ 
Igváá Ç
+ááÉ Ñ
rááÖ Ü
.ááÜ á

NonTaxableááá ë
;ááë í
purchase
àà 
.
àà 
ExchangeRate
àà 
=
àà 
await
àà  %
db
àà& (
.
àà( )
RateToPenAsync
àà) 7
(
àà7 8
currency
àà8 @
,
àà@ A
r
ààB C
.
ààC D
	IssueDate
ààD M
,
ààM N
ct
ààO Q
)
ààQ R
;
ààR S
purchase
ââ 
.
ââ 
BasePen
ââ 
=
ââ 
Math
ââ 
.
ââ  
Round
ââ  %
(
ââ% &
r
ââ& '
.
ââ' (
TaxBase
ââ( /
*
ââ0 1
purchase
ââ2 :
.
ââ: ;
ExchangeRate
ââ; G
,
ââG H
$num
ââI J
)
ââJ K
;
ââK L
purchase
ââM U
.
ââU V
IgvPen
ââV \
=
ââ] ^
Math
ââ_ c
.
ââc d
Round
ââd i
(
ââi j
r
ââj k
.
ââk l
Igv
ââl o
*
ââp q
purchase
ââr z
.
ââz {
ExchangeRateââ{ á
,ââá à
$numâââ ä
)ââä ã
;ââã å
purchaseââç ï
.ââï ñ
TotalPenââñ û
=ââü †
Mathââ° •
.ââ• ¶
Roundââ¶ ´
(ââ´ ¨
purchaseââ¨ ¥
.ââ¥ µ
Totalââµ ∫
*ââª º
purchaseââΩ ≈
.ââ≈ ∆
ExchangeRateââ∆ “
,ââ“ ”
$numââ‘ ’
)ââ’ ÷
;ââ÷ ◊
purchase
ää 
.
ää 
GivesTaxCredit
ää 
=
ää  !
r
ää" #
.
ää# $$
UsedForTaxedOperations
ää$ :
&&
ää; =
r
ää> ?
.
ää? @
Igv
ää@ C
>
ääD E
$num
ääF G
&&
ääH J
Purchase
ääK S
.
ääS T
AllowsTaxCredit
ääT c
(
ääc d
r
ääd e
.
ääe f
DocumentType
ääf r
)
äär s
;
ääs t
purchase
ãã 
.
ãã 
Notes
ãã 
=
ãã 
EmptyToNull
ãã $
(
ãã$ %
r
ãã% &
.
ãã& '
Notes
ãã' ,
)
ãã, -
;
ãã- .
return
åå 
null
åå 
;
åå 
}
çç 
private
êê 
static
êê 
string
êê 
?
êê 
ValidatePurchase
êê +
(
êê+ ,
PurchaseRequest
êê, ;
r
êê< =
,
êê= >
string
êê? E
supplierTaxId
êêF S
,
êêS T
string
êêU [
currency
êê\ d
)
êêd e
{
ëë 
var
íí 
peruvian
íí 
=
íí 
r
íí 
.
íí 
DocumentType
íí %
is
íí& (
not
íí) ,
(
íí- ."
PurchaseDocumentType
íí. B
.
ííB C

Extranjero
ííC M
or
ííN P"
PurchaseDocumentType
ííQ e
.
ííe f
Otro
ííf j
)
ííj k
;
íík l
if
ìì 

(
ìì 
peruvian
ìì 
&&
ìì 
!
ìì 
RucRegex
ìì !
(
ìì! "
)
ìì" #
.
ìì# $
IsMatch
ìì$ +
(
ìì+ ,
supplierTaxId
ìì, 9
)
ìì9 :
)
ìì: ;
return
ìì< B
$str
ììC p
;
ììp q
if
îî 

(
îî 
supplierTaxId
îî 
.
îî 
Length
îî  
==
îî! #
$num
îî$ %
)
îî% &
return
îî' -
$str
îî. W
;
îîW X
if
ïï 

(
ïï 
string
ïï 
.
ïï  
IsNullOrWhiteSpace
ïï %
(
ïï% &
r
ïï& '
.
ïï' (
SupplierName
ïï( 4
)
ïï4 5
)
ïï5 6
return
ïï7 =
$str
ïï> _
;
ïï_ `
if
ññ 

(
ññ 
peruvian
ññ 
&&
ññ 
string
ññ 
.
ññ  
IsNullOrWhiteSpace
ññ 1
(
ññ1 2
r
ññ2 3
.
ññ3 4
Series
ññ4 :
)
ññ: ;
)
ññ; <
return
ññ= C
$str
ññD q
;
ññq r
if
óó 

(
óó 
string
óó 
.
óó  
IsNullOrWhiteSpace
óó %
(
óó% &
r
óó& '
.
óó' (
Number
óó( .
)
óó. /
)
óó/ 0
return
óó1 7
$str
óó8 [
;
óó[ \
if
òò 

(
òò 
currency
òò 
is
òò 
not
òò 
(
òò 
$str
òò "
or
òò# %
$str
òò& +
or
òò, .
$str
òò/ 4
)
òò4 5
)
òò5 6
return
òò7 =
$str
òò> d
;
òòd e
if
ôô 

(
ôô 
r
ôô 
.
ôô 
TaxBase
ôô 
<
ôô 
$num
ôô 
||
ôô 
r
ôô 
.
ôô 
Igv
ôô "
<
ôô# $
$num
ôô% &
||
ôô' )
r
ôô* +
.
ôô+ ,

NonTaxable
ôô, 6
<
ôô7 8
$num
ôô9 :
||
ôô; =
r
ôô> ?
.
ôô? @
TaxBase
ôô@ G
+
ôôH I
r
ôôJ K
.
ôôK L
Igv
ôôL O
+
ôôP Q
r
ôôR S
.
ôôS T

NonTaxable
ôôT ^
<=
ôô_ a
$num
ôôb c
)
ôôc d
return
ôôe k
$strôôl ±
;ôô± ≤
if
öö 

(
öö 
r
öö 
.
öö 
Igv
öö 
>
öö 
$num
öö 
&&
öö 
r
öö 
.
öö 
DocumentType
öö '
is
öö( *"
PurchaseDocumentType
öö+ ?
.
öö? @
Boleta
öö@ F
or
ööG I"
PurchaseDocumentType
ööJ ^
.
öö^ _!
ReciboPorHonorarios
öö_ r
)
öör s
return
ööt z
$ströö{ ﬂ
;ööﬂ ‡
return
õõ 
null
õõ 
;
õõ 
}
úú 
private
üü 
static
üü 
string
üü 
?
üü !
ParsePurchasePeriod
üü .
(
üü. /
PurchaseRequest
üü/ >
r
üü? @
,
üü@ A
out
üüB E
DateOnly
üüF N
period
üüO U
)
üüU V
{
†† 
var
°° 

issueMonth
°° 
=
°° 
new
°° 
DateOnly
°° %
(
°°% &
r
°°& '
.
°°' (
	IssueDate
°°( 1
.
°°1 2
Year
°°2 6
,
°°6 7
r
°°8 9
.
°°9 :
	IssueDate
°°: C
.
°°C D
Month
°°D I
,
°°I J
$num
°°K L
)
°°L M
;
°°M N
period
¢¢ 
=
¢¢ 

issueMonth
¢¢ 
;
¢¢ 
if
££ 

(
££ 
string
££ 
.
££  
IsNullOrWhiteSpace
££ %
(
££% &
r
££& '
.
££' (
Period
££( .
)
££. /
)
££/ 0
return
££1 7
null
££8 <
;
££< =
if
§§ 

(
§§ 
!
§§ 
DateOnly
§§ 
.
§§ 
TryParseExact
§§ #
(
§§# $
r
§§$ %
.
§§% &
Period
§§& ,
.
§§, -
Trim
§§- 1
(
§§1 2
)
§§2 3
+
§§4 5
$str
§§6 ;
,
§§; <
$str
§§= I
,
§§I J
System
§§K Q
.
§§Q R
Globalization
§§R _
.
§§_ `
CultureInfo
§§` k
.
§§k l
InvariantCulture
§§l |
,
§§| }
System§§~ Ñ
.§§Ñ Ö
Globalization§§Ö í
.§§í ì
DateTimeStyles§§ì °
.§§° ¢
None§§¢ ¶
,§§¶ ß
out§§® ´
period§§¨ ≤
)§§≤ ≥
)§§≥ ¥
return§§µ ª
$str§§º ‹
;§§‹ ›
return
•• 
period
•• 
<
•• 

issueMonth
•• "
?
••# $
$str
••% g
:
••h i
null
••j n
;
••n o
}
¶¶ 
private
¨¨ 
async
¨¨ 
Task
¨¨ 
<
¨¨ 
ActionResult
¨¨ #
?
¨¨# $
>
¨¨$ %
LinkExpenseAsync
¨¨& 6
(
¨¨6 7
Purchase
¨¨7 ?
purchase
¨¨@ H
,
¨¨H I
Guid
¨¨J N
?
¨¨N O

categoryId
¨¨P Z
,
¨¨Z [
CancellationToken
¨¨\ m
ct
¨¨n p
)
¨¨p q
{
≠≠ 
if
ÆÆ 

(
ÆÆ 
purchase
ÆÆ 
.
ÆÆ 
DocumentType
ÆÆ !
==
ÆÆ" $"
PurchaseDocumentType
ÆÆ% 9
.
ÆÆ9 :
NotaCredito
ÆÆ: E
)
ÆÆE F
return
ÆÆG M
purchase
ÆÆN V
.
ÆÆV W
	ExpenseId
ÆÆW `
is
ÆÆa c
null
ÆÆd h
?
ÆÆi j
null
ÆÆk o
:
ÆÆp q

BadRequest
ÆÆr |
(
ÆÆ| }
newÆÆ} Ä
{ÆÆÅ Ç
messageÆÆÉ ä
=ÆÆã å
$strÆÆç ¬
}ÆÆ√ ƒ
)ÆÆƒ ≈
;ÆÆ≈ ∆
var
ØØ 
expense
ØØ 
=
ØØ 
purchase
ØØ 
.
ØØ 
	ExpenseId
ØØ (
is
ØØ) +
Guid
ØØ, 0
id
ØØ1 3
?
ØØ4 5
await
ØØ6 ;
db
ØØ< >
.
ØØ> ?
Expenses
ØØ? G
.
ØØG H
	FindAsync
ØØH Q
(
ØØQ R
[
ØØR S
id
ØØS U
]
ØØU V
,
ØØV W
ct
ØØX Z
)
ØØZ [
:
ØØ\ ]
null
ØØ^ b
;
ØØb c
var
∞∞ 
category
∞∞ 
=
∞∞ 

categoryId
∞∞ !
??
∞∞" $
expense
∞∞% ,
?
∞∞, -
.
∞∞- .

CategoryId
∞∞. 8
??
∞∞9 ; 
ExpenseCategoryIds
∞∞< N
.
∞∞N O
Otros
∞∞O T
;
∞∞T U
if
±± 

(
±± 
!
±± 
await
±± 
db
±± 
.
±± 
ExpenseCategories
±± '
.
±±' (
AnyAsync
±±( 0
(
±±0 1
x
±±1 2
=>
±±3 5
x
±±6 7
.
±±7 8
Id
±±8 :
==
±±; =
category
±±> F
,
±±F G
ct
±±H J
)
±±J K
)
±±K L
return
±±M S

BadRequest
±±T ^
(
±±^ _
new
±±_ b
{
±±c d
message
±±e l
=
±±m n
$str±±o ï
}±±ñ ó
)±±ó ò
;±±ò ô
if
≤≤ 

(
≤≤ 
expense
≤≤ 
is
≤≤ 
null
≤≤ 
)
≤≤ 
{
≤≤ 
expense
≤≤ &
=
≤≤' (
new
≤≤) ,
Expense
≤≤- 4
{
≤≤5 6
Type
≤≤7 ;
=
≤≤< =
ExpenseType
≤≤> I
.
≤≤I J
Variable
≤≤J R
}
≤≤S T
;
≤≤T U
db
≤≤V X
.
≤≤X Y
Expenses
≤≤Y a
.
≤≤a b
Add
≤≤b e
(
≤≤e f
expense
≤≤f m
)
≤≤m n
;
≤≤n o
purchase
≤≤p x
.
≤≤x y
	ExpenseId≤≤y Ç
=≤≤É Ñ
expense≤≤Ö å
.≤≤å ç
Id≤≤ç è
;≤≤è ê
}≤≤ë í
expense
≥≥ 
.
≥≥ 
Description
≥≥ 
=
≥≥ 
$"
≥≥  
{
≥≥  !
purchase
≥≥! )
.
≥≥) *
SupplierName
≥≥* 6
}
≥≥6 7
$str
≥≥7 :
{
≥≥: ;
(
≥≥; <
purchase
≥≥< D
.
≥≥D E
Series
≥≥E K
.
≥≥K L
Length
≥≥L R
>
≥≥S T
$num
≥≥U V
?
≥≥W X
purchase
≥≥Y a
.
≥≥a b
Series
≥≥b h
+
≥≥i j
$str
≥≥k n
:
≥≥o p
$str
≥≥q s
)
≥≥s t
}
≥≥t u
{
≥≥u v
purchase
≥≥v ~
.
≥≥~ 
Number≥≥ Ö
}≥≥Ö Ü
"≥≥Ü á
;≥≥á à
expense
¥¥ 
.
¥¥ 

CategoryId
¥¥ 
=
¥¥ 
category
¥¥ %
;
¥¥% &
expense
¥¥' .
.
¥¥. /
Currency
¥¥/ 7
=
¥¥8 9
purchase
¥¥: B
.
¥¥B C
Currency
¥¥C K
;
¥¥K L
expense
¥¥M T
.
¥¥T U
Date
¥¥U Y
=
¥¥Z [
purchase
¥¥\ d
.
¥¥d e
	IssueDate
¥¥e n
;
¥¥n o
expense
µµ 
.
µµ 
Amount
µµ 
=
µµ 
purchase
µµ !
.
µµ! "
GivesTaxCredit
µµ" 0
?
µµ1 2
purchase
µµ3 ;
.
µµ; <
TaxBase
µµ< C
+
µµD E
purchase
µµF N
.
µµN O

NonTaxable
µµO Y
:
µµZ [
purchase
µµ\ d
.
µµd e
Total
µµe j
;
µµj k
expense
∂∂ 
.
∂∂ 
	AmountPen
∂∂ 
=
∂∂ 
Math
∂∂  
.
∂∂  !
Round
∂∂! &
(
∂∂& '
expense
∂∂' .
.
∂∂. /
Amount
∂∂/ 5
*
∂∂6 7
purchase
∂∂8 @
.
∂∂@ A
ExchangeRate
∂∂A M
,
∂∂M N
$num
∂∂O P
)
∂∂P Q
;
∂∂Q R
return
∑∑ 
null
∑∑ 
;
∑∑ 
}
∏∏ 
private
∫∫ 
static
∫∫ 
decimal
∫∫ 
Signed
∫∫ !
(
∫∫! "
Purchase
∫∫" *
x
∫∫+ ,
,
∫∫, -
decimal
∫∫. 5
amount
∫∫6 <
)
∫∫< =
=>
∫∫> @
x
∫∫A B
.
∫∫B C
DocumentType
∫∫C O
==
∫∫P R"
PurchaseDocumentType
∫∫S g
.
∫∫g h
NotaCredito
∫∫h s
?
∫∫t u
-
∫∫v w
amount
∫∫w }
:
∫∫~ 
amount∫∫Ä Ü
;∫∫Ü á
private
ΩΩ 
static
ΩΩ 
object
ΩΩ 
PurchaseDto
ΩΩ %
(
ΩΩ% &
Purchase
ΩΩ& .
x
ΩΩ/ 0
,
ΩΩ0 1
decimal
ΩΩ2 9
igvRate
ΩΩ: A
)
ΩΩA B
=>
ΩΩC E
new
ΩΩF I
{
ææ 
id
øø 

=
øø 
x
øø 
.
øø 
Id
øø 
,
øø 
	issueDate
øø 
=
øø 
x
øø  
.
øø  !
	IssueDate
øø! *
,
øø* +
period
øø, 2
=
øø3 4
x
øø5 6
.
øø6 7
Period
øø7 =
.
øø= >
ToString
øø> F
(
øøF G
$str
øøG P
)
øøP Q
,
øøQ R
documentType
øøS _
=
øø` a
x
øøb c
.
øøc d
DocumentType
øød p
.
øøp q
ToString
øøq y
(
øøy z
)
øøz {
,
øø{ |
seriesøø} É
=øøÑ Ö
xøøÜ á
.øøá à
Seriesøøà é
,øøé è
numberøøê ñ
=øøó ò
xøøô ö
.øøö õ
Numberøøõ °
,øø° ¢
supplierTaxId
¿¿ 
=
¿¿ 
x
¿¿ 
.
¿¿ 
SupplierTaxId
¿¿ '
,
¿¿' (
supplierName
¿¿) 5
=
¿¿6 7
x
¿¿8 9
.
¿¿9 :
SupplierName
¿¿: F
,
¿¿F G
currency
¿¿H P
=
¿¿Q R
x
¿¿S T
.
¿¿T U
Currency
¿¿U ]
,
¿¿] ^
taxBase
¿¿_ f
=
¿¿g h
x
¿¿i j
.
¿¿j k
TaxBase
¿¿k r
,
¿¿r s
igv
¿¿t w
=
¿¿x y
x
¿¿z {
.
¿¿{ |
Igv
¿¿| 
,¿¿ Ä

nonTaxable¿¿Å ã
=¿¿å ç
x¿¿é è
.¿¿è ê

NonTaxable¿¿ê ö
,¿¿ö õ
total¿¿ú °
=¿¿¢ £
x¿¿§ •
.¿¿• ¶
Total¿¿¶ ´
,¿¿´ ¨
exchangeRate
¡¡ 
=
¡¡ 
x
¡¡ 
.
¡¡ 
ExchangeRate
¡¡ %
,
¡¡% &
totalPen
¡¡' /
=
¡¡0 1
x
¡¡2 3
.
¡¡3 4
TotalPen
¡¡4 <
,
¡¡< =
igvPen
¡¡> D
=
¡¡E F
x
¡¡G H
.
¡¡H I
IgvPen
¡¡I O
,
¡¡O P
givesTaxCredit
¡¡Q _
=
¡¡` a
x
¡¡b c
.
¡¡c d
GivesTaxCredit
¡¡d r
,
¡¡r s
taxCreditPen¡¡t Ä
=¡¡Å Ç
x¡¡É Ñ
.¡¡Ñ Ö
TaxCreditPen¡¡Ö ë
,¡¡ë í
	expenseId¡¡ì ú
=¡¡ù û
x¡¡ü †
.¡¡† °
	ExpenseId¡¡° ™
,¡¡™ ´
notes¡¡¨ ±
=¡¡≤ ≥
x¡¡¥ µ
.¡¡µ ∂
Notes¡¡∂ ª
,¡¡ª º

igvWarning
¬¬ 
=
¬¬ 
x
¬¬ 
.
¬¬ 
Igv
¬¬ 
>
¬¬ 
$num
¬¬ 
&&
¬¬ !
Math
¬¬" &
.
¬¬& '
Abs
¬¬' *
(
¬¬* +
x
¬¬+ ,
.
¬¬, -
Igv
¬¬- 0
-
¬¬1 2
x
¬¬3 4
.
¬¬4 5
TaxBase
¬¬5 <
*
¬¬= >
igvRate
¬¬? F
)
¬¬F G
>
¬¬H I
$num
¬¬J L
,
¬¬L M
}
√√ 
;
√√ 
[
≈≈ 
GeneratedRegex
≈≈ 
(
≈≈ 
$str
≈≈ 
)
≈≈  
]
≈≈  !
private
∆∆ 
static
∆∆ 
partial
∆∆ 
Regex
∆∆  
RucRegex
∆∆! )
(
∆∆) *
)
∆∆* +
;
∆∆+ ,
}«« 
public…… 
sealed
…… 
record
…… 
PurchaseRequest
…… $
(
……$ %
[
……% &
property
……& .
:
……. /
JsonRequired
……0 <
]
……< =
DateOnly
……> F
	IssueDate
……G P
,
……P Q
string
……R X
?
……X Y
Period
……Z `
,
……` a
[
……b c
property
……c k
:
……k l
JsonRequired
……m y
]
……y z#
PurchaseDocumentType……{ è
DocumentType……ê ú
,……ú ù
string……û §
?……§ •
Series……¶ ¨
,……¨ ≠
string……Æ ¥
Number……µ ª
,……ª º
string……Ω √
SupplierTaxId……ƒ —
,……— “
string……” Ÿ
SupplierName……⁄ Ê
,……Ê Á
string
   

Currency
   
,
   
[
   
property
   
:
   
JsonRequired
    ,
]
  , -
decimal
  . 5
TaxBase
  6 =
,
  = >
[
  ? @
property
  @ H
:
  H I
JsonRequired
  J V
]
  V W
decimal
  X _
Igv
  ` c
,
  c d
decimal
  e l

NonTaxable
  m w
=
  x y
$num
  z {
,
  { |
bool  } Å&
UsedForTaxedOperations  Ç ò
=  ô ö
true  õ ü
,  ü †
bool  ° •
CreateExpense  ¶ ≥
=  ¥ µ
false  ∂ ª
,  ª º
Guid  Ω ¡
?  ¡ ¬!
ExpenseCategoryId  √ ‘
=  ’ ÷
null  ◊ €
,  € ‹
string  › „
?  „ ‰
Notes  Â Í
=  Î Ï
null  Ì Ò
)  Ò Ú
;  Ú ÛÕÑ
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.AnnualTax.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
public 
sealed 
partial 
class 
AdminController +
{ 
[ 
HttpGet 
( 
$str "
)" #
]# $
public 

async 
Task 
< 
ActionResult "
>" #
AnnualTaxSettings$ 5
(5 6
CancellationToken6 G
ctH J
)J K
=>L N
OkO Q
(Q R
awaitR W
dbX Z
.Z [
AnnualTaxSettings[ l
.l m
OrderByDescendingm ~
(~ 
x	 Ä
=>
Å É
x
Ñ Ö
.
Ö Ü
Year
Ü ä
)
ä ã
.
ã å
ToListAsync
å ó
(
ó ò
ct
ò ö
)
ö õ
)
õ ú
;
ú ù
[ 
HttpPut 
( 
$str -
)- .
]. /
public 

async 
Task 
< 
ActionResult "
>" #!
SaveAnnualTaxSettings$ 9
(9 :
int: =
year> B
,B C$
AnnualTaxSettingsRequestD \
request] d
,d e
CancellationTokenf w
ctx z
)z {
{ 
if 

( 
year 
is 
< 
$num 
or 
> 
$num  $
)$ %
return& ,

BadRequest- 7
(7 8
new8 ;
{< =
message> E
=F G
$strH W
}X Y
)Y Z
;Z [
if 

( 
request 
. 
Uit 
<= 
$num 
) 
return $

BadRequest% /
(/ 0
new0 3
{4 5
message6 =
=> ?
$str@ d
}e f
)f g
;g h
if 

( 
request 
. 
ThresholdUits !
<=" $
$num% &
||' )
request* 1
.1 2
LowRate2 9
is: <
<= >
$num? @
orA C
>D E
$numF G
||H J
requestK R
.R S
HighRateS [
is\ ^
<_ `
$numa b
orc e
>f g
$numh i
)i j
returnk q

BadRequestr |
(| }
new	} Ä
{
Å Ç
message
É ä
=
ã å
$str
ç Ó
}
Ô 
)
 Ò
;
Ò Ú
var 
row 
= 
await 
db 
. 
AnnualTaxSettings ,
., - 
SingleOrDefaultAsync- A
(A B
xB C
=>D F
xG H
.H I
YearI M
==N P
yearQ U
,U V
ctW Y
)Y Z
;Z [
if 

( 
row 
is 
null 
) 
{ 
row 
=  
new! $
AnnualTaxSettings% 6
{7 8
Year9 =
=> ?
year@ D
}E F
;F G
dbH J
.J K
AnnualTaxSettingsK \
.\ ]
Add] `
(` a
rowa d
)d e
;e f
}g h
( 	
row	 
. 
Uit 
, 
row 
. 
ThresholdUits #
,# $
row% (
.( )
LowRate) 0
,0 1
row2 5
.5 6
HighRate6 >
)> ?
=@ A
(B C
requestC J
.J K
UitK N
,N O
requestP W
.W X
ThresholdUitsX e
,e f
requestg n
.n o
LowRateo v
,v w
requestx 
.	 Ä
HighRate
Ä à
)
à â
;
â ä
await 
db 
. 
SaveChangesAsync !
(! "
ct" $
)$ %
;% &
return 
Ok 
( 
row 
) 
; 
} 
[(( 
HttpGet(( 
((( 
$str(( #
)((# $
](($ %
public)) 

async)) 
Task)) 
<)) 
ActionResult)) "
>))" #
AnnualRentaReport))$ 5
())5 6
int))6 9
year)): >
,))> ?
CancellationToken))@ Q
ct))R T
)))T U
=>))V X
await))Y ^
AnnualRentaAsync))_ o
())o p
year))p t
,))t u
DateTime))v ~
.))~ 
UtcNow	)) Ö
,
))Ö Ü
ct
))á â
)
))â ä
;
))ä ã
internal++ 
async++ 
Task++ 
<++ 
ActionResult++ $
>++$ %
AnnualRentaAsync++& 6
(++6 7
int++7 :
year++; ?
,++? @
DateTime++A I
utcNow++J P
,++P Q
CancellationToken++R c
ct++d f
)++f g
{,, 
var-- 
annual-- 
=-- 
await-- 
db-- 
.-- 
AnnualTaxSettings-- /
.--/ 0 
SingleOrDefaultAsync--0 D
(--D E
x--E F
=>--G I
x--J K
.--K L
Year--L P
==--Q S
year--T X
,--X Y
ct--Z \
)--\ ]
;--] ^
if.. 

(.. 
annual.. 
is.. 
null.. 
).. 
return.. "
NotFound..# +
(..+ ,
new.., /
{..0 1
message..2 9
=..: ;
$"..< >
$str..> R
{..R S
year..S W
}..W X
$str..X x
"..x y
}..z {
)..{ |
;..| }
var// 
settings// 
=// 
await// 
TaxSettingsRow// +
(//+ ,
ct//, .
)//. /
;/// 0
var00 
(00 
from00 
,00 
to00 
)00 
=00 
(00 
new00 
DateOnly00 &
(00& '
year00' +
,00+ ,
$num00- .
,00. /
$num000 1
)001 2
,002 3
new004 7
DateOnly008 @
(00@ A
year00A E
,00E F
$num00G I
,00I J
$num00K M
)00M N
)00N O
;00O P
var11 
sales11 
=11 
await11 

SalesAsync11 $
(11$ %
from11% )
,11) *
to11+ -
,11- .
ct11/ 1
)111 2
;112 3
var22 
expenses22 
=22 
await22 
db22 
.22  
Expenses22  (
.22( )
Include22) 0
(220 1
x221 2
=>223 5
x226 7
.227 8
Category228 @
)22@ A
.22A B
Where22B G
(22G H
x22H I
=>22J L
x22M N
.22N O
Date22O S
>=22T V
from22W [
&&22\ ^
x22_ `
.22` a
Date22a e
<=22f h
to22i k
)22k l
.22l m
ToListAsync22m x
(22x y
ct22y {
)22{ |
;22| }
var33 
filed33 
=33 
await33 
db33 
.33 
TaxDueDates33 (
.33( )
Where33) .
(33. /
x33/ 0
=>331 3
x334 5
.335 6
Period336 <
>=33= ?
from33@ D
&&33E G
x33H I
.33I J
Period33J P
<=33Q S
to33T V
)33V W
.33W X
ToDictionaryAsync33X i
(33i j
x33j k
=>33l n
x33o p
.33p q
Period33q w
.33w x
Month33x }
,33} ~
ct	33 Å
)
33Å Ç
;
33Ç É
var44 
today44 
=44 
DateOnly44 
.44 
FromDateTime44 )
(44) *
utcNow44* 0
.440 1
AddHours441 9
(449 :
-44: ;
$num44; <
)44< =
)44= >
;44> ?
var66 
	lastMonth66 
=66 
year66 
.66 
	CompareTo66 &
(66& '
today66' ,
.66, -
Year66- 1
)661 2
switch663 9
{66: ;
<66< =
$num66> ?
=>66@ B
$num66C E
,66E F
$num66G H
=>66I K
today66L Q
.66Q R
Month66R W
,66W X
_66Y Z
=>66[ ]
$num66^ _
}66` a
;66a b
var88 
months88 
=88 

Enumerable88 
.88  
Range88  %
(88% &
$num88& '
,88' (
$num88) +
)88+ ,
.88, -
Select88- 3
(883 4
m884 5
=>886 8
{99 	
var:: 
start:: 
=:: 
new:: 
DateOnly:: $
(::$ %
year::% )
,::) *
m::+ ,
,::, -
$num::. /
)::/ 0
;::0 1
var::2 5
end::6 9
=::: ;
start::< A
.::A B
	AddMonths::B K
(::K L
$num::L M
)::M N
.::N O
AddDays::O V
(::V W
-::W X
$num::X Y
)::Y Z
;::Z [
var;; 
ventas;; 
=;; 
sales;; 
.;; 
Where;; $
(;;$ %
x;;% &
=>;;' )
x;;* +
.;;+ ,
Mype;;, 0
&&;;1 3
x;;4 5
.;;5 6
Date;;6 :
>=;;; =
start;;> C
&&;;D F
x;;G H
.;;H I
Date;;I M
<=;;N P
end;;Q T
);;T U
.;;U V
Sum;;V Y
(;;Y Z
x;;Z [
=>;;\ ^
x;;_ `
.;;` a
BasePen;;a h
);;h i
;;;i j
var<< 
gastos<< 
=<< 
expenses<< !
.<<! "
Where<<" '
(<<' (
x<<( )
=><<* ,
x<<- .
.<<. /
Date<</ 3
>=<<4 6
start<<7 <
&&<<= ?
x<<@ A
.<<A B
Date<<B F
<=<<G I
end<<J M
&&<<N P
IsDeductible<<Q ]
(<<] ^
x<<^ _
)<<_ `
)<<` a
.<<a b
Sum<<b e
(<<e f
x<<f g
=><<h j
x<<k l
.<<l m
	AmountPen<<m v
)<<v w
;<<w x
var== 
paid== 
=== 
filed== 
.== 
TryGetValue== (
(==( )
m==) *
,==* +
out==, /
var==0 3
row==4 7
)==7 8
?==9 :
row==; >
.==> ?
	RentaPaid==? H
:==I J
null==K O
;==O P
var>> 
pago>> 
=>> 
m>> 
>>> 
	lastMonth>> $
?>>% &
$num>>' )
:>>* +
paid>>, 0
??>>1 3
Math>>4 8
.>>8 9
Round>>9 >
(>>> ?
ventas>>? E
*>>F G
settings>>H P
.>>P Q
	RentaRate>>Q Z
,>>Z [
$num>>\ ]
)>>] ^
;>>^ _
return?? 
new?? 
AnnualMonth?? "
(??" #
start??# (
.??( )
ToString??) 1
(??1 2
$str??2 ;
)??; <
,??< =
Math??> B
.??B C
Round??C H
(??H I
ventas??I O
,??O P
$num??Q R
)??R S
,??S T
Math??U Y
.??Y Z
Round??Z _
(??_ `
gastos??` f
,??f g
$num??h i
)??i j
,??j k
pago??l p
,??p q
m??r s
<=??t v
	lastMonth	??w Ä
&&
??Å É
paid
??Ñ à
is
??â ã
null
??å ê
)
??ê ë
;
??ë í
}@@ 	
)@@	 

.@@
 
ToList@@ 
(@@ 
)@@ 
;@@ 
varBB 

ventasMypeBB 
=BB 
monthsBB 
.BB  
SumBB  #
(BB# $
xBB$ %
=>BB& (
xBB) *
.BB* +
	VentasPenBB+ 4
)BB4 5
;BB5 6
varBB7 :

deduciblesBB; E
=BBF G
monthsBBH N
.BBN O
SumBBO R
(BBR S
xBBS T
=>BBU W
xBBX Y
.BBY Z
	GastosPenBBZ c
)BBc d
;BBd e
varCC 
noDeduciblesCC 
=CC 
expensesCC #
.CC# $
WhereCC$ )
(CC) *
xCC* +
=>CC, .
!CC/ 0
IsDeductibleCC0 <
(CC< =
xCC= >
)CC> ?
&&CC@ B
xCCC D
.CCD E
CategoryCCE M
?CCM N
.CCN O
IsIncomeTaxCCO Z
!=CC[ ]
trueCC^ b
)CCb c
.CCc d
GroupByCCd k
(CCk l
xCCl m
=>CCn p
xCCq r
.CCr s
DescriptionCCs ~
.CC~ 
Trim	CC É
(
CCÉ Ñ
)
CCÑ Ö
)
CCÖ Ü
.
CCÜ á
Select
CCá ç
(
CCç é
g
CCé è
=>
CCê í
new
CCì ñ
{
CCó ò
descripcion
CCô §
=
CC• ¶
g
CCß ®
.
CC® ©
Key
CC© ¨
,
CC¨ ≠
monto
CCÆ ≥
=
CC¥ µ
Math
CC∂ ∫
.
CC∫ ª
Round
CCª ¿
(
CC¿ ¡
g
CC¡ ¬
.
CC¬ √
Sum
CC√ ∆
(
CC∆ «
x
CC« »
=>
CC… À
x
CCÃ Õ
.
CCÕ Œ
	AmountPen
CCŒ ◊
)
CC◊ ÿ
,
CCÿ Ÿ
$num
CC⁄ €
)
CC€ ‹
}
CC› ﬁ
)
CCﬁ ﬂ
.
CCﬂ ‡
OrderByDescending
CC‡ Ò
(
CCÒ Ú
x
CCÚ Û
=>
CCÙ ˆ
x
CC˜ ¯
.
CC¯ ˘
monto
CC˘ ˛
)
CC˛ ˇ
.
CCˇ Ä
ToList
CCÄ Ü
(
CCÜ á
)
CCá à
;
CCà â
varDD 
rentaDD 
=DD 

ventasMypeDD 
-DD  

deduciblesDD! +
;DD+ ,
varEE 
impuestoEE 
=EE 
MypeIncomeTaxEE $
.EE$ %
ComputeEE% ,
(EE, -
rentaEE- 2
,EE2 3
annualEE4 :
)EE: ;
;EE; <
varFF 
pagosFF 
=FF 
monthsFF 
.FF 
SumFF 
(FF 
xFF  
=>FF! #
xFF$ %
.FF% &
PagoACuentaPenFF& 4
)FF4 5
;FF5 6
varHH 

proyeccionHH 
=HH 
AnnualProjectionHH )
(HH) *
yearHH* .
,HH. /
todayHH0 5
,HH5 6
monthsHH7 =
,HH= >
annualHH? E
,HHE F
settingsHHG O
.HHO P
	RentaRateHHP Y
)HHY Z
;HHZ [
varII 
naturalII 
=II 
salesII 
.II 
WhereII !
(II! "
xII" #
=>II$ &
xII' (
.II( )
PersonaNaturalII) 7
)II7 8
.II8 9
ToListII9 ?
(II? @
)II@ A
;IIA B
returnJJ 
OkJJ 
(JJ 
newJJ 
{KK 	
yearLL 
,LL 
uitLL 
=LL 
annualLL 
.LL 
UitLL "
,LL" #
tasasLL$ )
=LL* +
newLL, /
{LL0 1
annualLL2 8
.LL8 9
ThresholdUitsLL9 F
,LLF G
annualLLH N
.LLN O
LowRateLLO V
,LLV W
annualLLX ^
.LL^ _
HighRateLL_ g
,LLg h
pagoACuentaLLi t
=LLu v
settingsLLw 
.	LL Ä
	RentaRate
LLÄ â
}
LLä ã
,
LLã å
ventasMypePenMM 
=MM 
MathMM  
.MM  !
RoundMM! &
(MM& '

ventasMypeMM' 1
,MM1 2
$numMM3 4
)MM4 5
,MM5 6
gastosDeduciblesPenMM7 J
=MMK L
MathMMM Q
.MMQ R
RoundMMR W
(MMW X

deduciblesMMX b
,MMb c
$numMMd e
)MMe f
,MMf g
noDeduciblesMMh t
,MMt u
noDeduciblesPen	MMv Ö
=
MMÜ á
noDeducibles
MMà î
.
MMî ï
Sum
MMï ò
(
MMò ô
x
MMô ö
=>
MMõ ù
x
MMû ü
.
MMü †
monto
MM† •
)
MM• ¶
,
MM¶ ß
rentaNetaPenNN 
=NN 
MathNN 
.NN  
RoundNN  %
(NN% &
rentaNN& +
,NN+ ,
$numNN- .
)NN. /
,NN/ 0
impuestoNN1 9
,NN9 :
pagosACuentaPenNN; J
=NNK L
MathNNM Q
.NNQ R
RoundNNR W
(NNW X
pagosNNX ]
,NN] ^
$numNN_ `
)NN` a
,NNa b
pagosEstimadosNNc q
=NNr s
monthsNNt z
.NNz {
Count	NN{ Ä
(
NNÄ Å
x
NNÅ Ç
=>
NNÉ Ö
x
NNÜ á
.
NNá à
Estimado
NNà ê
)
NNê ë
,
NNë í
saldoPenOO 
=OO 
MathOO 
.OO 
RoundOO !
(OO! "
impuestoOO" *
.OO* +
TotalOO+ 0
-OO1 2
pagosOO3 8
,OO8 9
$numOO: ;
)OO; <
,OO< =
mesesOO> C
=OOD E
monthsOOF L
,OOL M

proyeccionOON X
,OOX Y
personaNaturalPP 
=PP 
newPP  
{PP! "
ingresosPenPP# .
=PP/ 0
MathPP1 5
.PP5 6
RoundPP6 ;
(PP; <
naturalPP< C
.PPC D
SumPPD G
(PPG H
xPPH I
=>PPJ L
xPPM N
.PPN O
BasePenPPO V
)PPV W
,PPW X
$numPPY Z
)PPZ [
,PP[ \
retencionesPenPP] k
=PPl m
MathPPn r
.PPr s
RoundPPs x
(PPx y
natural	PPy Ä
.
PPÄ Å
Sum
PPÅ Ñ
(
PPÑ Ö
x
PPÖ Ü
=>
PPá â
x
PPä ã
.
PPã å
RetentionPen
PPå ò
)
PPò ô
,
PPô ö
$num
PPõ ú
)
PPú ù
}
PPû ü
,
PPü †

disclaimerQQ 
=QQ 
TaxDisclaimerQQ &
,QQ& '
}RR 	
)RR	 

;RR
 
}SS 
privateVV 
staticVV 
objectVV 
?VV 
AnnualProjectionVV +
(VV+ ,
intVV, /
yearVV0 4
,VV4 5
DateOnlyVV6 >
todayVV? D
,VVD E
ListVVF J
<VVJ K
AnnualMonthVVK V
>VVV W
monthsVVX ^
,VV^ _
AnnualTaxSettingsVV` q
annualVVr x
,VVx y
decimal	VVz Å
	rentaRate
VVÇ ã
)
VVã å
{WW 
ifXX 

(XX 
yearXX 
!=XX 
todayXX 
.XX 
YearXX 
||XX !
todayXX" '
.XX' (
MonthXX( -
==XX. 0
$numXX1 3
||XX4 6
todayXX7 <
.XX< =
MonthXX= B
==XXC E
$numXXF G
)XXG H
returnXXI O
nullXXP T
;XXT U
varYY 
closedYY 
=YY 
monthsYY 
.YY 
TakeYY  
(YY  !
todayYY! &
.YY& '
MonthYY' ,
-YY- .
$numYY/ 0
)YY0 1
.YY1 2
ToListYY2 8
(YY8 9
)YY9 :
;YY: ;
varZZ 
ventasPZZ 
=ZZ 
closedZZ 
.ZZ 
AverageZZ $
(ZZ$ %
xZZ% &
=>ZZ' )
xZZ* +
.ZZ+ ,
	VentasPenZZ, 5
)ZZ5 6
*ZZ7 8
$numZZ9 ;
;ZZ; <
varZZ= @
gastosPZZA H
=ZZI J
closedZZK Q
.ZZQ R
AverageZZR Y
(ZZY Z
xZZZ [
=>ZZ\ ^
xZZ_ `
.ZZ` a
	GastosPenZZa j
)ZZj k
*ZZl m
$numZZn p
;ZZp q
var[[ 
	impuestoP[[ 
=[[ 
MypeIncomeTax[[ %
.[[% &
Compute[[& -
([[- .
ventasP[[. 5
-[[6 7
gastosP[[8 ?
,[[? @
annual[[A G
)[[G H
;[[H I
var\\ 
pagosP\\ 
=\\ 
Math\\ 
.\\ 
Round\\ 
(\\  
ventasP\\  '
*\\( )
	rentaRate\\* 3
,\\3 4
$num\\5 6
)\\6 7
;\\7 8
return]] 
new]] 
{]] 
	mesesBase]] 
=]]  
closed]]! '
.]]' (
Count]]( -
,]]- .
	ventasPen]]/ 8
=]]9 :
Math]]; ?
.]]? @
Round]]@ E
(]]E F
ventasP]]F M
,]]M N
$num]]O P
)]]P Q
,]]Q R
gastosDeduciblesPen]]S f
=]]g h
Math]]i m
.]]m n
Round]]n s
(]]s t
gastosP]]t {
,]]{ |
$num]]} ~
)]]~ 
,	]] Ä
rentaNetaPen
]]Å ç
=
]]é è
Math
]]ê î
.
]]î ï
Round
]]ï ö
(
]]ö õ
ventasP
]]õ ¢
-
]]£ §
gastosP
]]• ¨
,
]]¨ ≠
$num
]]Æ Ø
)
]]Ø ∞
,
]]∞ ±
impuesto
]]≤ ∫
=
]]ª º
	impuestoP
]]Ω ∆
,
]]∆ «
pagosACuentaPen
]]» ◊
=
]]ÿ Ÿ
pagosP
]]⁄ ‡
,
]]‡ ·
saldoPen
]]‚ Í
=
]]Î Ï
Math
]]Ì Ò
.
]]Ò Ú
Round
]]Ú ˜
(
]]˜ ¯
	impuestoP
]]¯ Å
.
]]Å Ç
Total
]]Ç á
-
]]à â
pagosP
]]ä ê
,
]]ê ë
$num
]]í ì
)
]]ì î
}
]]ï ñ
;
]]ñ ó
}^^ 
privateaa 
staticaa 
boolaa 
IsDeductibleaa $
(aa$ %
Expenseaa% ,
xaa- .
)aa. /
=>aa0 2
xaa3 4
.aa4 5
Categoryaa5 =
?aa= >
.aa> ?
IsIncomeTaxaa? J
!=aaK M
trueaaN R
&&aaS U
xaaV W
.aaW X
CategoryaaX `
?aa` a
.aaa b
IsDeductibleaab n
!=aao q
falseaar w
&&aax z
!aa{ |
xaa| }
.aa} ~
IsNonDeductible	aa~ ç
;
aaç é
privatecc 
sealedcc 
recordcc 
AnnualMonthcc %
(cc% &
stringcc& ,
Mescc- 0
,cc0 1
decimalcc2 9
	VentasPencc: C
,ccC D
decimalccE L
	GastosPenccM V
,ccV W
decimalccX _
PagoACuentaPencc` n
,ccn o
boolccp t
Estimadoccu }
)cc} ~
;cc~ 
[hh 
HttpGethh 
(hh 
$strhh 
)hh 
]hh 
publicii 

asyncii 
Taskii 
<ii 
ActionResultii "
>ii" #
Form1662Listii$ 0
(ii0 1
intii1 4
yearii5 9
,ii9 :
intii; >
monthii? D
,iiD E
CancellationTokeniiF W
ctiiX Z
)iiZ [
{jj 
varkk 
settingskk 
=kk 
awaitkk 
TaxSettingsRowkk +
(kk+ ,
ctkk, .
)kk. /
;kk/ 0
varll 
rowsll 
=ll 
awaitll 
dbll 
.ll 
Expensesll $
.ll$ %
Wherell% *
(ll* +
xll+ ,
=>ll- /
xll0 1
.ll1 2!
IsNonDomiciledServicell2 G
&&llH J
xllK L
.llL M
DatellM Q
.llQ R
YearllR V
==llW Y
yearllZ ^
&&ll_ a
xllb c
.llc d
Datelld h
.llh i
Monthlli n
==llo q
monthllr w
)llw x
.llx y
OrderBy	lly Ä
(
llÄ Å
x
llÅ Ç
=>
llÉ Ö
x
llÜ á
.
llá à
Date
llà å
)
llå ç
.
llç é
ToListAsync
llé ô
(
llô ö
ct
llö ú
)
llú ù
;
llù û
varmm 
itemsmm 
=mm 
rowsmm 
.mm 
Selectmm 
(mm  
xmm  !
=>mm" $
newmm% (
{mm) *
idmm+ -
=mm. /
xmm0 1
.mm1 2
Idmm2 4
,mm4 5
datemm6 :
=mm; <
xmm= >
.mm> ?
Datemm? C
,mmC D
descriptionmmE P
=mmQ R
xmmS T
.mmT U
DescriptionmmU `
,mm` a
suppliermmb j
=mmk l
xmmm n
.mmn o 
ForeignSupplierName	mmo Ç
,
mmÇ É
country
mmÑ ã
=
mmå ç
x
mmé è
.
mmè ê$
ForeignSupplierCountry
mmê ¶
,
mm¶ ß
amount
mm® Æ
=
mmØ ∞
x
mm± ≤
.
mm≤ ≥
Amount
mm≥ π
,
mmπ ∫
currency
mmª √
=
mmƒ ≈
x
mm∆ «
.
mm« »
Currency
mm» –
,
mm– —
exchangeRate
mm“ ﬁ
=
mmﬂ ‡
x
mm· ‚
.
mm‚ „
Amount
mm„ È
==
mmÍ Ï
$num
mmÌ Ó
?
mmÔ 
$num
mmÒ Ú
:
mmÛ Ù
Math
mmı ˘
.
mm˘ ˙
Round
mm˙ ˇ
(
mmˇ Ä
x
mmÄ Å
.
mmÅ Ç
	AmountPen
mmÇ ã
/
mmå ç
x
mmé è
.
mmè ê
Amount
mmê ñ
,
mmñ ó
$num
mmò ô
)
mmô ö
,
mmö õ
basePen
mmú £
=
mm§ •
Math
mm¶ ™
.
mm™ ´
Round
mm´ ∞
(
mm∞ ±
x
mm± ≤
.
mm≤ ≥
	AmountPen
mm≥ º
,
mmº Ω
$num
mmæ ø
)
mmø ¿
,
mm¿ ¡
igvPen
mm¬ »
=
mm…  
Form1662
mmÀ ”
.
mm” ‘
Igv
mm‘ ◊
(
mm◊ ÿ
x
mmÿ Ÿ
,
mmŸ ⁄
settings
mm€ „
.
mm„ ‰
IgvRate
mm‰ Î
)
mmÎ Ï
,
mmÏ Ì
paidAt
mmÓ Ù
=
mmı ˆ
x
mm˜ ¯
.
mm¯ ˘
Form1662PaidAt
mm˘ á
,
mmá à
number
mmâ è
=
mmê ë
x
mmí ì
.
mmì î
Form1662Number
mmî ¢
}
mm£ §
)
mm§ •
.
mm• ¶
ToList
mm¶ ¨
(
mm¨ ≠
)
mm≠ Æ
;
mmÆ Ø
returnnn 
Oknn 
(nn 
newnn 
{nn 
periodonn 
=nn  !
$"nn" $
{nn$ %
monthnn% *
:nn* +
$strnn+ -
}nn- .
$strnn. /
{nn/ 0
yearnn0 4
}nn4 5
"nn5 6
,nn6 7
tributonn8 ?
=nn@ A
$strnnB H
,nnH I
igvRatennJ Q
=nnR S
settingsnnT \
.nn\ ]
IgvRatenn] d
,nnd e
usedAsCreditnnf r
=nns t
settingsnnu }
.nn} ~
Use1662AsCredit	nn~ ç
,
nnç é
totalIgvPen
nnè ö
=
nnõ ú
items
nnù ¢
.
nn¢ £
Sum
nn£ ¶
(
nn¶ ß
x
nnß ®
=>
nn© ´
x
nn¨ ≠
.
nn≠ Æ
igvPen
nnÆ ¥
)
nn¥ µ
,
nnµ ∂

pendientes
nn∑ ¡
=
nn¬ √
items
nnƒ …
.
nn…  
Count
nn  œ
(
nnœ –
x
nn– —
=>
nn“ ‘
x
nn’ ÷
.
nn÷ ◊
paidAt
nn◊ ›
is
nnﬁ ‡
null
nn· Â
)
nnÂ Ê
,
nnÊ Á
items
nnË Ì
}
nnÓ Ô
)
nnÔ 
;
nn Ò
}oo 
[qq 
HttpPostqq 
(qq 
$strqq ,
)qq, -
]qq- .
publicrr 

asyncrr 
Taskrr 
<rr 
ActionResultrr "
>rr" #
MarkForm1662Paidrr$ 4
(rr4 5
Guidrr5 9
idrr: <
,rr< ="
Form1662PaymentRequestrr> T
requestrrU \
,rr\ ]
CancellationTokenrr^ o
ctrrp r
)rrr s
{ss 
vartt 
expensett 
=tt 
awaittt 
dbtt 
.tt 
Expensestt '
.tt' (
	FindAsynctt( 1
(tt1 2
[tt2 3
idtt3 5
]tt5 6
,tt6 7
cttt8 :
)tt: ;
;tt; <
iftt= ?
(tt@ A
expensettA H
isttI K
nullttL P
)ttP Q
returnttR X
NotFoundttY a
(tta b
)ttb c
;ttc d
ifuu 

(uu 
!uu 
expenseuu 
.uu !
IsNonDomiciledServiceuu *
)uu* +
returnuu, 2

BadRequestuu3 =
(uu= >
newuu> A
{uuB C
messageuuD K
=uuL M
$str	uuN ò
}
uuô ö
)
uuö õ
;
uuõ ú
ifvv 

(vv 
requestvv 
.vv 
PaidAtvv 
<vv 
expensevv $
.vv$ %
Datevv% )
)vv) *
returnvv+ 1

BadRequestvv2 <
(vv< =
newvv= @
{vvA B
messagevvC J
=vvK L
$strvvM }
}vv~ 
)	vv Ä
;
vvÄ Å
(ww 	
expenseww	 
.ww 
Form1662PaidAtww 
,ww  
expenseww! (
.ww( )
Form1662Numberww) 7
)ww7 8
=ww9 :
(ww; <
requestww< C
.wwC D
PaidAtwwD J
,wwJ K
EmptyToNullwwL W
(wwW X
requestwwX _
.ww_ `
Numberww` f
)wwf g
)wwg h
;wwh i
awaitxx 
dbxx 
.xx 
SaveChangesAsyncxx !
(xx! "
ctxx" $
)xx$ %
;xx% &
returnxx' -
	NoContentxx. 7
(xx7 8
)xx8 9
;xx9 :
}yy 
[{{ 

HttpDelete{{ 
({{ 
$str{{ .
){{. /
]{{/ 0
public|| 

async|| 
Task|| 
<|| 
ActionResult|| "
>||" #
UnmarkForm1662Paid||$ 6
(||6 7
Guid||7 ;
id||< >
,||> ?
CancellationToken||@ Q
ct||R T
)||T U
{}} 
var~~ 
expense~~ 
=~~ 
await~~ 
db~~ 
.~~ 
Expenses~~ '
.~~' (
	FindAsync~~( 1
(~~1 2
[~~2 3
id~~3 5
]~~5 6
,~~6 7
ct~~8 :
)~~: ;
;~~; <
if~~= ?
(~~@ A
expense~~A H
is~~I K
null~~L P
)~~P Q
return~~R X
NotFound~~Y a
(~~a b
)~~b c
;~~c d
( 	
expense	 
. 
Form1662PaidAt 
,  
expense! (
.( )
Form1662Number) 7
)7 8
=9 :
(; <
null< @
,@ A
nullB F
)F G
;G H
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
SaveChangesAsync
ÄÄ !
(
ÄÄ! "
ct
ÄÄ" $
)
ÄÄ$ %
;
ÄÄ% &
return
ÄÄ' -
	NoContent
ÄÄ. 7
(
ÄÄ7 8
)
ÄÄ8 9
;
ÄÄ9 :
}
ÅÅ 
}ÇÇ 
publicÑÑ 
sealed
ÑÑ 
record
ÑÑ &
AnnualTaxSettingsRequest
ÑÑ -
(
ÑÑ- .
[
ÑÑ. /
property
ÑÑ/ 7
:
ÑÑ7 8
JsonRequired
ÑÑ9 E
]
ÑÑE F
decimal
ÑÑG N
Uit
ÑÑO R
,
ÑÑR S
decimal
ÑÑT [
ThresholdUits
ÑÑ\ i
=
ÑÑj k
$num
ÑÑl o
,
ÑÑo p
decimal
ÑÑq x
LowRateÑÑy Ä
=ÑÑÅ Ç
$numÑÑÉ à
,ÑÑà â
decimalÑÑä ë
HighRateÑÑí ö
=ÑÑõ ú
$numÑÑù £
)ÑÑ£ §
;ÑÑ§ •
publicÖÖ 
sealed
ÖÖ 
record
ÖÖ $
Form1662PaymentRequest
ÖÖ +
(
ÖÖ+ ,
[
ÖÖ, -
property
ÖÖ- 5
:
ÖÖ5 6
JsonRequired
ÖÖ7 C
]
ÖÖC D
DateOnly
ÖÖE M
PaidAt
ÖÖN T
,
ÖÖT U
string
ÖÖV \
?
ÖÖ\ ]
Number
ÖÖ^ d
)
ÖÖd e
;
ÖÖe fÙ≤
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AccountController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
, 
Route  
(  !
$str! &
)& '
]' (
public 
sealed 
class 
AccountController %
(% &
RtresDbContext& 4
db5 7
,7 8
AccessEmailService9 K
accessEmailL W
)W X
:Y Z
ControllerBase[ i
{ 
private 
Guid 
UserId 
=> 
Guid 
.  
Parse  %
(% &
User& *
.* +
FindFirstValue+ 9
(9 :

ClaimTypes: D
.D E
NameIdentifierE S
)S T
!T U
)U V
;V W
private 
bool 
TryGetClientId 
(  
out  #
Guid$ (
clientId) 1
)1 2
=>3 5
Guid6 :
.: ;
TryParse; C
(C D
UserD H
.H I
FindFirstValueI W
(W X
$strX c
)c d
,d e
outf i
clientIdj r
)r s
;s t
internal 
static 
readonly 
PasswordHasher +
<+ ,
UserAccount, 7
>7 8
Hasher9 ?
=@ A
newB E
(E F
)F G
;G H
[ 
HttpGet 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
Profile$ +
(+ ,
CancellationToken, =
ct> @
)@ A
{B C
varD G
userH L
=M N
awaitO T
dbU W
.W X
UserAccountsX d
.d e
	FindAsynce n
(n o
[o p
UserIdp v
]v w
,w x
cty {
){ |
;| }
return	~ Ñ
user
Ö â
is
ä å
null
ç ë
?
í ì
NotFound
î ú
(
ú ù
)
ù û
:
ü †
Ok
° £
(
£ §
new
§ ß
{
® ©
name
™ Æ
=
Ø ∞
user
± µ
.
µ ∂
Name
∂ ∫
,
∫ ª
email
º ¡
=
¬ √
user
ƒ »
.
» …
Email
… Œ
}
œ –
)
– —
;
— “
}
” ‘
[ 
	HttpPatch 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
UpdateProfile$ 1
(1 2
ProfileRequest2 @
requestA H
,H I
CancellationTokenJ [
ct\ ^
)^ _
{` a
ifb d
(e f
stringf l
.l m
IsNullOrWhiteSpacem 
(	 Ä
request
Ä á
.
á à
Name
à å
)
å ç
)
ç é
return
è ï

BadRequest
ñ †
(
† °
new
° §
{
• ¶
message
ß Æ
=
Ø ∞
$str
± Ã
}
Õ Œ
)
Œ œ
;
œ –
var
— ‘
user
’ Ÿ
=
⁄ €
await
‹ ·
db
‚ ‰
.
‰ Â
UserAccounts
Â Ò
.
Ò Ú
	FindAsync
Ú ˚
(
˚ ¸
[
¸ ˝
UserId
˝ É
]
É Ñ
,
Ñ Ö
ct
Ü à
)
à â
;
â ä
if
ã ç
(
é è
user
è ì
is
î ñ
null
ó õ
)
õ ú
return
ù £
NotFound
§ ¨
(
¨ ≠
)
≠ Æ
;
Æ Ø
user
∞ ¥
.
¥ µ
Name
µ π
=
∫ ª
request
º √
.
√ ƒ
Name
ƒ »
.
» …
Trim
… Õ
(
Õ Œ
)
Œ œ
;
œ –
await
— ÷
db
◊ Ÿ
.
Ÿ ⁄
SaveChangesAsync
⁄ Í
(
Í Î
ct
Î Ì
)
Ì Ó
;
Ó Ô
return
 ˆ
Ok
˜ ˘
(
˘ ˙
)
˙ ˚
;
˚ ¸
}
˝ ˛
[ 
HttpPost 
( 
$str '
)' (
]( )
public 

async 
Task 
< 
ActionResult "
>" #
ChangePassword$ 2
(2 3!
ChangePasswordRequest3 H
requestI P
,P Q
CancellationTokenR c
ctd f
)f g
{h i
varj m
usern r
=s t
awaitu z
db{ }
.} ~
UserAccounts	~ ä
.
ä ã
	FindAsync
ã î
(
î ï
[
ï ñ
UserId
ñ ú
]
ú ù
,
ù û
ct
ü °
)
° ¢
;
¢ £
if
§ ¶
(
ß ®
user
® ¨
is
≠ Ø
null
∞ ¥
)
¥ µ
return
∂ º
NotFound
Ω ≈
(
≈ ∆
)
∆ «
;
« »
if
… À
(
Ã Õ
Hasher
Õ ”
.
” ‘"
VerifyHashedPassword
‘ Ë
(
Ë È
user
È Ì
,
Ì Ó
user
Ô Û
.
Û Ù
PasswordHash
Ù Ä
,
Ä Å
request
Ç â
.
â ä
CurrentPassword
ä ô
)
ô ö
==
õ ù(
PasswordVerificationResult
û ∏
.
∏ π
Failed
π ø
)
ø ¿
return
¡ «

BadRequest
» “
(
“ ”
new
” ÷
{
◊ ÿ
message
Ÿ ‡
=
· ‚
$str
„ Ü
}
á à
)
à â
;
â ä
if
ã ç
(
é è
string
è ï
.
ï ñ 
IsNullOrWhiteSpace
ñ ®
(
® ©
request
© ∞
.
∞ ±
NewPassword
± º
)
º Ω
)
Ω æ
return
ø ≈

BadRequest
∆ –
(
– —
new
— ‘
{
’ ÷
message
◊ ﬁ
=
ﬂ ‡
$str
· Ü
}
á à
)
à â
;
â ä
user
ã è
.
è ê
PasswordHash
ê ú
=
ù û
Hasher
ü •
.
• ¶
HashPassword
¶ ≤
(
≤ ≥
user
≥ ∑
,
∑ ∏
request
π ¿
.
¿ ¡
NewPassword
¡ Ã
)
Ã Õ
;
Õ Œ
await
œ ‘
db
’ ◊
.
◊ ÿ
SaveChangesAsync
ÿ Ë
(
Ë È
ct
È Î
)
Î Ï
;
Ï Ì
return
Ó Ù
Ok
ı ˜
(
˜ ¯
)
¯ ˘
;
˘ ˙
}
˚ ¸
internal!! 
static!! 
string!! 
TemporaryPassword!! ,
(!!, -
)!!- .
=>!!/ 1
Convert!!2 9
.!!9 :
ToBase64String!!: H
(!!H I!
RandomNumberGenerator!!I ^
.!!^ _
GetBytes!!_ g
(!!g h
$num!!h j
)!!j k
)!!k l
.!!l m
Replace!!m t
(!!t u
$str!!u x
,!!x y
$str!!z }
)!!} ~
.!!~ 
Replace	!! Ü
(
!!Ü á
$str
!!á ä
,
!!ä ã
$str
!!å è
)
!!è ê
;
!!ê ë
[## 
HttpGet## 
(## 
$str## #
)### $
]##$ %
public$$ 

async$$ 
Task$$ 
<$$ 
ActionResult$$ "
>$$" #
Transactions$$$ 0
($$0 1
Guid$$1 5
?$$5 6
clientId$$7 ?
,$$? @
CancellationToken$$A R
ct$$S U
)$$U V
{%% 
Guid'' 
?'' 
scope'' 
;'' 
if(( 

((( 
User(( 
.(( 
IsInRole(( 
((( 
nameof((  
(((  !
UserRole((! )
.(() *

SuperAdmin((* 4
)((4 5
)((5 6
)((6 7
scope((8 =
=((> ?
clientId((@ H
;((H I
else)) 
if)) 
()) 
TryGetClientId)) 
())  
out))  #
var))$ '
own))( +
)))+ ,
))), -
scope)). 3
=))4 5
own))6 9
;))9 :
else** 
return** 
Ok** 
(** 
Array** 
.** 
Empty** "
<**" #
object**# )
>**) *
(*** +
)**+ ,
)**, -
;**- .
return++ 
Ok++ 
(++ 
await++ 
(++ 
from++ 
transaction++ )
in++* ,
db++- /
.++/ 0
PaymentTransactions++0 C
join,, 
client,, $
in,,% '
db,,( *
.,,* +
Clients,,+ 2
on,,3 5
transaction,,6 A
.,,A B
ClientId,,B J
equals,,K Q
client,,R X
.,,X Y
Id,,Y [
where-- 
scope-- $
==--% '
null--( ,
||--- /
transaction--0 ;
.--; <
ClientId--< D
==--E G
scope--H M
orderby..  
transaction..! ,
..., -
	CreatedAt..- 6

descending..7 A
let00 
product00 $
=00% &
(00' (
from00( ,
clientProduct00- :
in00; =
db00> @
.00@ A
ClientProducts00A O
join00P T
p00U V
in00W Y
db00Z \
.00\ ]
Products00] e
on00f h
clientProduct00i v
.00v w
	ProductId	00w Ä
equals
00Å á
p
00à â
.
00â ä
Id
00ä å
where
00ç í
clientProduct
00ì †
.
00† °
Id
00° £
==
00§ ¶
transaction
00ß ≤
.
00≤ ≥
ClientProductId
00≥ ¬
select
00√ …
p
00  À
.
00À Ã
Name
00Ã –
)
00– —
.
00— “
FirstOrDefault
00“ ‡
(
00‡ ·
)
00· ‚
select11 
new11  #
{11$ %
id11& (
=11) *
transaction11+ 6
.116 7
Id117 9
,119 :
	createdAt11; D
=11E F
transaction11G R
.11R S
	CreatedAt11S \
,11\ ]
product11^ e
=11f g
product11h o
??11p r
transaction11s ~
.11~ 
Notes	11 Ñ
??
11Ö á
transaction
11à ì
.
11ì î
Method
11î ö
,
11ö õ

clientName
11ú ¶
=
11ß ®
client
11© Ø
.
11Ø ∞
CompanyName
11∞ ª
,
11ª º
amount
11Ω √
=
11ƒ ≈
transaction
11∆ —
.
11— “
Amount
11“ ÿ
,
11ÿ Ÿ
currency
11⁄ ‚
=
11„ ‰
transaction
11Â 
.
11 Ò
Currency
11Ò ˘
,
11˘ ˙
status
11˚ Å
=
11Ç É
transaction
11Ñ è
.
11è ê
Status
11ê ñ
,
11ñ ó
internalCode
11ò §
=
11• ¶
transaction
11ß ≤
.
11≤ ≥
InternalCode
11≥ ø
}
11¿ ¡
)
11¡ ¬
.
11¬ √
ToListAsync
11√ Œ
(
11Œ œ
ct
11œ —
)
11— “
)
11“ ”
;
11” ‘
}22 
[33 
HttpGet33 
(33 
$str33 
)33 
,33 
	Authorize33 %
(33% &
Roles33& +
=33, -
$str33. 5
)335 6
]336 7
public44 

async44 
Task44 
<44 
ActionResult44 "
>44" #
Team44$ (
(44( )
CancellationToken44) :
ct44; =
)44= >
{44? @
if44A C
(44D E
!44E F
TryGetClientId44F T
(44T U
out44U X
var44Y \
clientId44] e
)44e f
)44f g
return44h n
Forbid44o u
(44u v
)44v w
;44w x
return44y 
Ok
44Ä Ç
(
44Ç É
await
44É à
db
44â ã
.
44ã å
UserAccounts
44å ò
.
44ò ô
Where
44ô û
(
44û ü
x
44ü †
=>
44° £
x
44§ •
.
44• ¶
ClientId
44¶ Æ
==
44Ø ±
clientId
44≤ ∫
)
44∫ ª
.
44ª º
OrderBy
44º √
(
44√ ƒ
x
44ƒ ≈
=>
44∆ »
x
44…  
.
44  À
Name
44À œ
)
44œ –
.
44– —
Select
44— ◊
(
44◊ ÿ
x
44ÿ Ÿ
=>
44⁄ ‹
new
44› ‡
{
44· ‚
id
44„ Â
=
44Ê Á
x
44Ë È
.
44È Í
Id
44Í Ï
,
44Ï Ì
name
44Ó Ú
=
44Û Ù
x
44ı ˆ
.
44ˆ ˜
Name
44˜ ˚
,
44˚ ¸
email
44˝ Ç
=
44É Ñ
x
44Ö Ü
.
44Ü á
Email
44á å
,
44å ç
role
44é í
=
44ì î
x
44ï ñ
.
44ñ ó
Role
44ó õ
.
44õ ú
ToString
44ú §
(
44§ •
)
44• ¶
,
44¶ ß
isActive
44® ∞
=
44± ≤
x
44≥ ¥
.
44¥ µ
IsActive
44µ Ω
,
44Ω æ
area
44ø √
=
44ƒ ≈
x
44∆ «
.
44« »
Area
44» Ã
,
44Ã Õ
jobTitle
44Œ ÷
=
44◊ ÿ
x
44Ÿ ⁄
.
44⁄ €
JobTitle
44€ „
,
44„ ‰
	managerId
44Â Ó
=
44Ô 
x
44Ò Ú
.
44Ú Û
	ManagerId
44Û ¸
}
44˝ ˛
)
44˛ ˇ
.
44ˇ Ä
ToListAsync
44Ä ã
(
44ã å
ct
44å é
)
44é è
)
44è ê
;
44ê ë
}
44í ì
[55 
HttpPost55 
(55 
$str55 
)55 
,55 
	Authorize55 &
(55& '
Roles55' ,
=55- .
$str55/ 6
)556 7
]557 8
public66 

async66 
Task66 
<66 
ActionResult66 "
>66" #
Invite66$ *
(66* +
InviteRequest66+ 8
request669 @
,66@ A
CancellationToken66B S
ct66T V
)66V W
{66X Y
if66Z \
(66] ^
!66^ _
TryGetClientId66_ m
(66m n
out66n q
var66r u
clientId66v ~
)66~ 
)	66 Ä
return
66Å á
Forbid
66à é
(
66é è
)
66è ê
;
66ê ë
if
66í î
(
66ï ñ
string
66ñ ú
.
66ú ù 
IsNullOrWhiteSpace
66ù Ø
(
66Ø ∞
request
66∞ ∑
.
66∑ ∏
Name
66∏ º
)
66º Ω
||
66æ ¿
string
66¡ «
.
66« » 
IsNullOrWhiteSpace
66» ⁄
(
66⁄ €
request
66€ ‚
.
66‚ „
Email
66„ Ë
)
66Ë È
)
66È Í
return
66Î Ò

BadRequest
66Ú ¸
(
66¸ ˝
new
66˝ Ä
{
66Å Ç
message
66É ä
=
66ã å
$str
66ç Ø
}
66∞ ±
)
66± ≤
;
66≤ ≥
if
66¥ ∂
(
66∑ ∏
await
66∏ Ω
db
66æ ¿
.
66¿ ¡
UserAccounts
66¡ Õ
.
66Õ Œ
AnyAsync
66Œ ÷
(
66÷ ◊
x
66◊ ÿ
=>
66Ÿ €
x
66‹ ›
.
66› ﬁ
Email
66ﬁ „
==
66‰ Ê
request
66Á Ó
.
66Ó Ô
Email
66Ô Ù
,
66Ù ı
ct
66ˆ ¯
)
66¯ ˘
)
66˘ ˙
return
66˚ Å
Conflict
66Ç ä
(
66ä ã
new
66ã é
{
66è ê
message
66ë ò
=
66ô ö
$str
66õ π
}
66∫ ª
)
66ª º
;
66º Ω
var
66æ ¡
temporaryPassword
66¬ ”
=
66‘ ’
TemporaryPassword
66÷ Á
(
66Á Ë
)
66Ë È
;
66È Í
var
66Î Ó
user
66Ô Û
=
66Ù ı
new
66ˆ ˘
UserAccount
66˙ Ö
{
66Ü á
ClientId
66à ê
=
66ë í
clientId
66ì õ
,
66õ ú
Name
66ù °
=
66¢ £
request
66§ ´
.
66´ ¨
Name
66¨ ∞
.
66∞ ±
Trim
66± µ
(
66µ ∂
)
66∂ ∑
,
66∑ ∏
Email
66π æ
=
66ø ¿
request
66¡ »
.
66» …
Email
66… Œ
.
66Œ œ
Trim
66œ ”
(
66” ‘
)
66‘ ’
,
66’ ÷
Role
66◊ €
=
66‹ ›
UserRole
66ﬁ Ê
.
66Ê Á
Cliente
66Á Ó
}
66Ô 
;
66 Ò
user
66Ú ˆ
.
66ˆ ˜
PasswordHash
66˜ É
=
66Ñ Ö
Hasher
66Ü å
.
66å ç
HashPassword
66ç ô
(
66ô ö
user
66ö û
,
66û ü
temporaryPassword
66† ±
)
66± ≤
;
66≤ ≥
db
66¥ ∂
.
66∂ ∑
UserAccounts
66∑ √
.
66√ ƒ
Add
66ƒ «
(
66« »
user
66» Ã
)
66Ã Õ
;
66Õ Œ
await
66œ ‘
db
66’ ◊
.
66◊ ÿ
SaveChangesAsync
66ÿ Ë
(
66Ë È
ct
66È Î
)
66Î Ï
;
66Ï Ì
var
66Ó Ò
client
66Ú ¯
=
66˘ ˙
await
66˚ Ä
db
66Å É
.
66É Ñ
Clients
66Ñ ã
.
66ã å
	FindAsync
66å ï
(
66ï ñ
[
66ñ ó
clientId
66ó ü
]
66ü †
,
66† °
ct
66¢ §
)
66§ •
;
66• ¶
var
66ß ™
	emailSent
66´ ¥
=
66µ ∂
client
66∑ Ω
is
66æ ¿
not
66¡ ƒ
null
66≈ …
&&
66  Ã
await
66Õ “
accessEmail
66” ﬁ
.
66ﬁ ﬂ
	SendAsync
66ﬂ Ë
(
66Ë È
client
66È Ô
,
66Ô 
user
66Ò ı
.
66ı ˆ
Name
66ˆ ˙
,
66˙ ˚
user
66¸ Ä
.
66Ä Å
Email
66Å Ü
,
66Ü á
temporaryPassword
66à ô
,
66ô ö
Request
66õ ¢
,
66¢ £
ct
66§ ¶
)
66¶ ß
;
66ß ®
return
66© Ø
Created
66∞ ∑
(
66∑ ∏
$"
66∏ ∫
$str
66∫  
{
66  À
user
66À œ
.
66œ –
Id
66– “
}
66“ ”
"
66” ‘
,
66‘ ’
new
66÷ Ÿ
{
66⁄ €
id
66‹ ﬁ
=
66ﬂ ‡
user
66· Â
.
66Â Ê
Id
66Ê Ë
,
66Ë È
temporaryPassword
66Í ˚
,
66˚ ¸
	emailSent
66˝ Ü
}
66á à
)
66à â
;
66â ä
}
66ã å
[77 
	HttpPatch77 
(77 
$str77 %
)77% &
,77& '
	Authorize77( 1
(771 2
Roles772 7
=778 9
$str77: A
)77A B
]77B C
public88 

async88 
Task88 
<88 
ActionResult88 "
>88" #

UpdateTeam88$ .
(88. /
Guid88/ 3
id884 6
,886 7
UpdateTeamRequest888 I
request88J Q
,88Q R
CancellationToken88S d
ct88e g
)88g h
{88i j
if88k m
(88n o
!88o p
TryGetClientId88p ~
(88~ 
out	88 Ç
var
88É Ü
clientId
88á è
)
88è ê
)
88ê ë
return
88í ò
Forbid
88ô ü
(
88ü †
)
88† °
;
88° ¢
var
88£ ¶
user
88ß ´
=
88¨ ≠
await
88Æ ≥
db
88¥ ∂
.
88∂ ∑
UserAccounts
88∑ √
.
88√ ƒ"
SingleOrDefaultAsync
88ƒ ÿ
(
88ÿ Ÿ
x
88Ÿ ⁄
=>
88€ ›
x
88ﬁ ﬂ
.
88ﬂ ‡
Id
88‡ ‚
==
88„ Â
id
88Ê Ë
&&
88È Î
x
88Ï Ì
.
88Ì Ó
ClientId
88Ó ˆ
==
88˜ ˘
clientId
88˙ Ç
,
88Ç É
ct
88Ñ Ü
)
88Ü á
;
88á à
if
88â ã
(
88å ç
user
88ç ë
is
88í î
null
88ï ô
)
88ô ö
return
88õ °
NotFound
88¢ ™
(
88™ ´
)
88´ ¨
;
88¨ ≠
if
88Æ ∞
(
88± ≤
id
88≤ ¥
==
88µ ∑
UserId
88∏ æ
&&
88ø ¡
(
88¬ √
(
88√ ƒ
request
88ƒ À
.
88À Ã
Role
88Ã –
is
88— ”
UserRole
88‘ ‹
.
88‹ ›
Cliente
88› ‰
)
88‰ Â
||
88Ê Ë
request
88È 
.
88 Ò
IsActive
88Ò ˘
is
88˙ ¸
false
88˝ Ç
)
88Ç É
)
88É Ñ
return
88Ö ã

BadRequest
88å ñ
(
88ñ ó
new
88ó ö
{
88õ ú
message
88ù §
=
88• ¶
$str
88ß –
}
88— “
)
88“ ”
;
88” ‘
if
88’ ◊
(
88ÿ Ÿ
request
88Ÿ ‡
.
88‡ ·
Role
88· Â
is
88Ê Ë
UserRole
88È Ò
role
88Ú ˆ
&&
88˜ ˘
role
88˙ ˛
is
88ˇ Å
not
88Ç Ö
(
88Ü á
UserRole
88á è
.
88è ê
Cliente
88ê ó
or
88ò ö
UserRole
88õ £
.
88£ §
Admin
88§ ©
)
88© ™
)
88™ ´
return
88¨ ≤

BadRequest
88≥ Ω
(
88Ω æ
)
88æ ø
;
88ø ¿
var99 
area99 
=99 
request99 
.99 
Area99 
?99  
.99  !
Trim99! %
(99% &
)99& '
;99' (
var99) ,
jobTitle99- 5
=996 7
request998 ?
.99? @
JobTitle99@ H
?99H I
.99I J
Trim99J N
(99N O
)99O P
;99P Q
if:: 

(:: 
area:: 
?:: 
.:: 
Length:: 
>:: 
$num:: 
||:: !
jobTitle::" *
?::* +
.::+ ,
Length::, 2
>::3 4
$num::5 8
)::8 9
return::: @

BadRequest::A K
(::K L
new::L O
{::P Q
message::R Y
=::Z [
$str	::\ ì
}
::î ï
)
::ï ñ
;
::ñ ó
if;; 

(;; 
request;; 
.;; 
	ManagerId;; 
is;;  
Guid;;! %
	managerId;;& /
&&;;0 2
	managerId;;3 <
!=;;= ?
Guid;;@ D
.;;D E
Empty;;E J
&&;;K M
await;;N S 
ValidateManagerAsync;;T h
(;;h i
user;;i m
,;;m n
	managerId;;o x
,;;x y
clientId	;;z Ç
,
;;Ç É
ct
;;Ñ Ü
)
;;Ü á
is
;;à ä
string
;;ã ë
managerError
;;í û
)
;;û ü
return
;;† ¶

BadRequest
;;ß ±
(
;;± ≤
new
;;≤ µ
{
;;∂ ∑
message
;;∏ ø
=
;;¿ ¡
managerError
;;¬ Œ
}
;;œ –
)
;;– —
;
;;— “
if<< 

(<< 
request<< 
.<< 
Role<< 
is<< 
UserRole<< $
	validRole<<% .
)<<. /
user<<0 4
.<<4 5
Role<<5 9
=<<: ;
	validRole<<< E
;<<E F
if<<G I
(<<J K
request<<K R
.<<R S
IsActive<<S [
is<<\ ^
bool<<_ c
active<<d j
)<<j k
user<<l p
.<<p q
IsActive<<q y
=<<z {
active	<<| Ç
;
<<Ç É
if== 

(== 
area== 
is== 
not== 
null== 
)== 
user== "
.==" #
Area==# '
===( )
area==* .
.==. /
Length==/ 5
====6 8
$num==9 :
?==; <
null=== A
:==B C
area==D H
;==H I
if==J L
(==M N
jobTitle==N V
is==W Y
not==Z ]
null==^ b
)==b c
user==d h
.==h i
JobTitle==i q
===r s
jobTitle==t |
.==| }
Length	==} É
==
==Ñ Ü
$num
==á à
?
==â ä
null
==ã è
:
==ê ë
jobTitle
==í ö
;
==ö õ
if>> 

(>> 
request>> 
.>> 
	ManagerId>> 
is>>  
Guid>>! %

newManager>>& 0
)>>0 1
user>>2 6
.>>6 7
	ManagerId>>7 @
=>>A B

newManager>>C M
==>>N P
Guid>>Q U
.>>U V
Empty>>V [
?>>\ ]
null>>^ b
:>>c d

newManager>>e o
;>>o p
await?? 
db?? 
.?? 
SaveChangesAsync?? !
(??! "
ct??" $
)??$ %
;??% &
return??' -
Ok??. 0
(??0 1
)??1 2
;??2 3
}??4 5
privateAA 
asyncAA 
TaskAA 
<AA 
stringAA 
?AA 
>AA  
ValidateManagerAsyncAA  4
(AA4 5
UserAccountAA5 @
userAAA E
,AAE F
GuidAAG K
	managerIdAAL U
,AAU V
GuidAAW [
clientIdAA\ d
,AAd e
CancellationTokenAAf w
ctAAx z
)AAz {
{BB 
ifCC 

(CC 
	managerIdCC 
==CC 
userCC 
.CC 
IdCC  
)CC  !
returnCC" (
$strCC) \
;CC\ ]
varDD 
managerDD 
=DD 
awaitDD 
dbDD 
.DD 
UserAccountsDD +
.DD+ ,
AsNoTrackingDD, 8
(DD8 9
)DD9 :
.DD: ; 
SingleOrDefaultAsyncDD; O
(DDO P
xDDP Q
=>DDR T
xDDU V
.DDV W
IdDDW Y
==DDZ \
	managerIdDD] f
&&DDg i
xDDj k
.DDk l
ClientIdDDl t
==DDu w
clientId	DDx Ä
,
DDÄ Å
ct
DDÇ Ñ
)
DDÑ Ö
;
DDÖ Ü
ifEE 

(EE 
managerEE 
isEE 
nullEE 
)EE 
returnEE #
$strEE$ Z
;EEZ [
ifFF 

(FF 
!FF 
managerFF 
.FF 
IsActiveFF 
)FF 
returnFF %
$strFF& U
;FFU V
varGG 
managersGG 
=GG 
awaitGG 
dbGG 
.GG  
UserAccountsGG  ,
.GG, -
AsNoTrackingGG- 9
(GG9 :
)GG: ;
.GG; <
WhereGG< A
(GGA B
xGGB C
=>GGD F
xGGG H
.GGH I
ClientIdGGI Q
==GGR T
clientIdGGU ]
)GG] ^
.GG^ _
ToDictionaryAsyncGG_ p
(GGp q
xGGq r
=>GGs u
xGGv w
.GGw x
IdGGx z
,GGz {
xGG| }
=>	GG~ Ä
x
GGÅ Ç
.
GGÇ É
	ManagerId
GGÉ å
,
GGå ç
ct
GGé ê
)
GGê ë
;
GGë í
varHH 
visitedHH 
=HH 
newHH 
HashSetHH !
<HH! "
GuidHH" &
>HH& '
(HH' (
)HH( )
;HH) *
forII 
(II 
GuidII 
?II 
currentII 
=II 
	managerIdII &
;II& '
currentII( /
isII0 2
GuidII3 7
idII8 :
&&II; =
visitedII> E
.IIE F
AddIIF I
(III J
idIIJ L
)IIL M
;IIM N
currentIIO V
=IIW X
managersIIY a
.IIa b
GetValueOrDefaultIIb s
(IIs t
idIIt v
)IIv w
)IIw x
ifJJ 
(JJ 
idJJ 
==JJ 
userJJ 
.JJ 
IdJJ 
)JJ 
returnJJ %
$strJJ& h
;JJh i
returnKK 
nullKK 
;KK 
}LL 
}MM 
[OO 
ApiControllerOO 
,OO 
	AuthorizeOO 
(OO 
RolesOO 
=OO  !
$strOO" .
)OO. /
,OO/ 0
RouteOO1 6
(OO6 7
$strOO7 B
)OOB C
]OOC D
publicPP 
sealedPP 
partialPP 
classPP 
AdminControllerPP +
(PP+ ,
RtresDbContextPP, :
dbPP; =
,PP= >!
PayPalCheckoutServicePP? T
checkoutServicePPU d
,PPd e
ExchangeRateSyncJobPPf y
exchangeRateSync	PPz ä
,
PPä ã 
AccessEmailService
PPå û
accessEmail
PPü ™
,
PP™ ´ 
TaxDocumentService
PP¨ æ
taxDocuments
PPø À
,
PPÀ Ã"
IBackgroundJobClient
PPÕ ·
jobs
PP‚ Ê
,
PPÊ Á!
INotificationSender
PPË ˚
notifications
PP¸ â
)
PPâ ä
:
PPã å
ControllerBase
PPç õ
{QQ 
privateRR 
GuidRR 
UserIdRR 
=>RR 
GuidRR 
.RR  
ParseRR  %
(RR% &
UserRR& *
.RR* +
FindFirstValueRR+ 9
(RR9 :

ClaimTypesRR: D
.RRD E
NameIdentifierRRE S
)RRS T
!RRT U
)RRU V
;RRV W
[SS 
HttpGetSS 
(SS 
$strSS 
)SS 
]SS 
publicTT 

asyncTT 
TaskTT 
<TT 
ActionResultTT "
>TT" #
TicketsTT$ +
(TT+ ,
TicketStatusTT, 8
?TT8 9
statusTT: @
,TT@ A
GuidTTB F
?TTF G
clientIdTTH P
,TTP Q
GuidTTR V
?TTV W
	projectIdTTX a
,TTa b
intTTc f
pageTTg k
=TTl m
$numTTn o
,TTo p
CancellationToken	TTq Ç
ct
TTÉ Ö
=
TTÜ á
default
TTà è
)
TTè ê
{UU 
pageVV 
=VV 
MathVV 
.VV 
MaxVV 
(VV 
pageVV 
,VV 
$numVV 
)VV  
;VV  !
varWW 
queryWW 
=WW 
fromWW 
ticketWW 
inWW  "
dbWW# %
.WW% &
TicketsWW& -
joinXX 
clientXX 
inXX  "
dbXX# %
.XX% &
ClientsXX& -
onXX. 0
ticketXX1 7
.XX7 8
ClientIdXX8 @
equalsXXA G
clientXXH N
.XXN O
IdXXO Q
joinYY 
projectYY  
inYY! #
dbYY$ &
.YY& '
ProjectsYY' /
onYY0 2
ticketYY3 9
.YY9 :
	ProjectIdYY: C
equalsYYD J
projectYYK R
.YYR S
IdYYS U
whereZZ 
(ZZ 
statusZZ !
==ZZ" $
nullZZ% )
||ZZ* ,
ticketZZ- 3
.ZZ3 4
StatusZZ4 :
==ZZ; =
statusZZ> D
)ZZD E
&&ZZF H
(ZZI J
clientIdZZJ R
==ZZS U
nullZZV Z
||ZZ[ ]
ticketZZ^ d
.ZZd e
ClientIdZZe m
==ZZn p
clientIdZZq y
)ZZy z
&&ZZ{ }
(ZZ~ 
	projectId	ZZ à
==
ZZâ ã
null
ZZå ê
||
ZZë ì
ticket
ZZî ö
.
ZZö õ
	ProjectId
ZZõ §
==
ZZ• ß
	projectId
ZZ® ±
)
ZZ± ≤
orderby[[ 
ticket[[ "
.[[" #
	UpdatedAt[[# ,

descending[[- 7
select\\ 
new\\ 
{\\  
ticket\\! '
,\\' (
client\\) /
,\\/ 0
project\\1 8
}\\9 :
;\\: ;
var]] 
total]] 
=]] 
await]] 
query]] 
.]]  

CountAsync]]  *
(]]* +
ct]]+ -
)]]- .
;]]. /
var^^ 
items^^ 
=^^ 
await^^ 
query^^ 
.^^  
Skip^^  $
(^^$ %
(^^% &
page^^& *
-^^+ ,
$num^^- .
)^^. /
*^^0 1
$num^^2 4
)^^4 5
.^^5 6
Take^^6 :
(^^: ;
$num^^; =
)^^= >
.^^> ?
Select^^? E
(^^E F
x^^F G
=>^^H J
new^^K N
{^^O P
id^^Q S
=^^T U
x^^V W
.^^W X
ticket^^X ^
.^^^ _
Id^^_ a
,^^a b
code^^c g
=^^h i
x^^j k
.^^k l
ticket^^l r
.^^r s
Code^^s w
,^^w x
clientId	^^y Å
=
^^Ç É
x
^^Ñ Ö
.
^^Ö Ü
ticket
^^Ü å
.
^^å ç
ClientId
^^ç ï
,
^^ï ñ
	projectId
^^ó †
=
^^° ¢
x
^^£ §
.
^^§ •
ticket
^^• ´
.
^^´ ¨
	ProjectId
^^¨ µ
,
^^µ ∂
type
^^∑ ª
=
^^º Ω
x
^^æ ø
.
^^ø ¿
ticket
^^¿ ∆
.
^^∆ «
Type
^^« À
.
^^À Ã
ToString
^^Ã ‘
(
^^‘ ’
)
^^’ ÷
,
^^÷ ◊
status
^^ÿ ﬁ
=
^^ﬂ ‡
x
^^· ‚
.
^^‚ „
ticket
^^„ È
.
^^È Í
Status
^^Í 
.
^^ Ò
ToString
^^Ò ˘
(
^^˘ ˙
)
^^˙ ˚
,
^^˚ ¸
title
^^˝ Ç
=
^^É Ñ
x
^^Ö Ü
.
^^Ü á
ticket
^^á ç
.
^^ç é
Title
^^é ì
,
^^ì î
description
^^ï †
=
^^° ¢
x
^^£ §
.
^^§ •
ticket
^^• ´
.
^^´ ¨
Description
^^¨ ∑
,
^^∑ ∏
	createdAt
^^π ¬
=
^^√ ƒ
x
^^≈ ∆
.
^^∆ «
ticket
^^« Õ
.
^^Õ Œ
	CreatedAt
^^Œ ◊
,
^^◊ ÿ
	updatedAt
^^Ÿ ‚
=
^^„ ‰
x
^^Â Ê
.
^^Ê Á
ticket
^^Á Ì
.
^^Ì Ó
	UpdatedAt
^^Ó ˜
,
^^˜ ¯
githubIssueNumber
^^˘ ä
=
^^ã å
x
^^ç é
.
^^é è
ticket
^^è ï
.
^^ï ñ
GithubIssueNumber
^^ñ ß
,
^^ß ®
githubIssueUrl
^^© ∑
=
^^∏ π
x
^^∫ ª
.
^^ª º
ticket
^^º ¬
.
^^¬ √
GithubIssueUrl
^^√ —
,
^^— “
client
^^” Ÿ
=
^^⁄ €
new
^^‹ ﬂ
{
^^‡ ·
id
^^‚ ‰
=
^^Â Ê
x
^^Á Ë
.
^^Ë È
client
^^È Ô
.
^^Ô 
Id
^^ Ú
,
^^Ú Û
name
^^Ù ¯
=
^^˘ ˙
x
^^˚ ¸
.
^^¸ ˝
client
^^˝ É
.
^^É Ñ
CompanyName
^^Ñ è
}
^^ê ë
,
^^ë í
project
^^ì ö
=
^^õ ú
new
^^ù †
{
^^° ¢
id
^^£ •
=
^^¶ ß
x
^^® ©
.
^^© ™
project
^^™ ±
.
^^± ≤
Id
^^≤ ¥
,
^^¥ µ
name
^^∂ ∫
=
^^ª º
x
^^Ω æ
.
^^æ ø
project
^^ø ∆
.
^^∆ «
Name
^^« À
}
^^Ã Õ
,
^^Õ Œ
	managedIn
^^œ ÿ
=
^^Ÿ ⁄
db
^^€ ›
.
^^› ﬁ!
ProjectRepositories
^^ﬁ Ò
.
^^Ò Ú
Any
^^Ú ı
(
^^ı ˆ
r
^^ˆ ˜
=>
^^¯ ˙
r
^^˚ ¸
.
^^¸ ˝
	ProjectId
^^˝ Ü
==
^^á â
x
^^ä ã
.
^^ã å
project
^^å ì
.
^^ì î
Id
^^î ñ
)
^^ñ ó
?
^^ò ô
$str
^^ö ¢
:
^^£ §
$str
^^• ≠
}
^^Æ Ø
)
^^Ø ∞
.
^^∞ ±
ToListAsync
^^± º
(
^^º Ω
ct
^^Ω ø
)
^^ø ¿
;
^^¿ ¡
return__ 
Ok__ 
(__ 
new__ 
{__ 
items__ 
,__ 
page__ #
,__# $

totalPages__% /
=__0 1
(__2 3
int__3 6
)__6 7
Math__7 ;
.__; <
Ceiling__< C
(__C D
total__D I
/__J K
$num__L O
)__O P
}__Q R
)__R S
;__S T
}`` 
[aa 
	HttpPatchaa 
(aa 
$straa "
)aa" #
]aa# $
publicbb 

asyncbb 
Taskbb 
<bb 
ActionResultbb "
>bb" #
UpdateTicketbb$ 0
(bb0 1
Guidbb1 5
idbb6 8
,bb8 9%
UpdateTicketStatusRequestbb: S
requestbbT [
,bb[ \
CancellationTokenbb] n
ctbbo q
)bbq r
{cc 
vardd 
entrydd 
=dd 
awaitdd 
(dd 
fromdd 
ticketdd  &
indd' )
dbdd* ,
.dd, -
Ticketsdd- 4
joindd5 9
projectdd: A
inddB D
dbddE G
.ddG H
ProjectsddH P
onddQ S
ticketddT Z
.ddZ [
	ProjectIddd[ d
equalsdde k
projectddl s
.dds t
Idddt v
whereddw |
ticket	dd} É
.
ddÉ Ñ
Id
ddÑ Ü
==
ddá â
id
ddä å
select
ddç ì
new
ddî ó
{
ddò ô
ticket
ddö †
,
dd† °
project
dd¢ ©
}
dd™ ´
)
dd´ ¨
.
dd¨ ≠"
SingleOrDefaultAsync
dd≠ ¡
(
dd¡ ¬
ct
dd¬ ƒ
)
ddƒ ≈
;
dd≈ ∆
if
dd« …
(
dd  À
entry
ddÀ –
is
dd— ”
null
dd‘ ÿ
)
ddÿ Ÿ
return
dd⁄ ‡
NotFound
dd· È
(
ddÈ Í
)
ddÍ Î
;
ddÎ Ï
ifee 

(ee 
awaitee 
dbee 
.ee 
ProjectRepositoriesee (
.ee( )
AnyAsyncee) 1
(ee1 2
xee2 3
=>ee4 6
xee7 8
.ee8 9
	ProjectIdee9 B
==eeC E
entryeeF K
.eeK L
projecteeL S
.eeS T
IdeeT V
,eeV W
cteeX Z
)eeZ [
)ee[ \
returnee] c
Conflicteed l
(eel m
neweem p
{eeq r
messageees z
=ee{ |
$str	ee} ≠
}
eeÆ Ø
)
eeØ ∞
;
ee∞ ±
ifff 

(ff 
entryff 
.ff 
ticketff 
.ff 
Statusff 
==ff  "
requestff# *
.ff* +
Statusff+ 1
)ff1 2
returnff3 9
Okff: <
(ff< =
newff= @
{ffA B
statusffC I
=ffJ K
entryffL Q
.ffQ R
ticketffR X
.ffX Y
StatusffY _
.ff_ `
ToStringff` h
(ffh i
)ffi j
}ffk l
)ffl m
;ffm n
entrygg 
.gg 
ticketgg 
.gg 
Statusgg 
=gg 
requestgg %
.gg% &
Statusgg& ,
;gg, -
entrygg. 3
.gg3 4
ticketgg4 :
.gg: ;
	UpdatedAtgg; D
=ggE F
DateTimeggG O
.ggO P
UtcNowggP V
;ggV W
awaitggX ]
dbgg^ `
.gg` a
SaveChangesAsyncgga q
(ggq r
ctggr t
)ggt u
;ggu v
varhh 
clienthh 
=hh 
awaithh 
dbhh 
.hh 
Clientshh %
.hh% &
SingleAsynchh& 1
(hh1 2
xhh2 3
=>hh4 6
xhh7 8
.hh8 9
Idhh9 ;
==hh< >
entryhh? D
.hhD E
tickethhE K
.hhK L
ClientIdhhL T
,hhT U
cthhV X
)hhX Y
;hhY Z
awaitii 
notificationsii 
.ii 
	SendAsyncii %
(ii% &
clientii& ,
,ii, -
newii. 1
Notificationii2 >
(ii> ?
NotificationTypeii? O
.iiO P
TicketStatusChangediiP c
,iic d
newiie h
(iih i
)iii j
{iik l
[iim n
$striin x
]iix y
=iiz {
entry	ii| Å
.
iiÅ Ç
ticket
iiÇ à
.
iià â
Id
iiâ ã
.
iiã å
ToString
iiå î
(
iiî ï
)
iiï ñ
,
iiñ ó
[
iiò ô
$str
iiô ü
]
iiü †
=
ii° ¢
entry
ii£ ®
.
ii® ©
ticket
ii© Ø
.
iiØ ∞
Code
ii∞ ¥
,
ii¥ µ
[
ii∂ ∑
$str
ii∑ æ
]
iiæ ø
=
ii¿ ¡
entry
ii¬ «
.
ii« »
ticket
ii» Œ
.
iiŒ œ
Title
iiœ ‘
,
ii‘ ’
[
ii÷ ◊
$str
ii◊ ﬂ
]
iiﬂ ‡
=
ii· ‚
entry
ii„ Ë
.
iiË È
ticket
iiÈ Ô
.
iiÔ 
Status
ii ˆ
.
iiˆ ˜
ToString
ii˜ ˇ
(
iiˇ Ä
)
iiÄ Å
}
iiÇ É
,
iiÉ Ñ
$"
iiÖ á
$str
iiá ï
{
iiï ñ
entry
iiñ õ
.
iiõ ú
ticket
iiú ¢
.
ii¢ £
Id
ii£ •
}
ii• ¶
$str
ii¶ ß
{
iiß ®
entry
ii® ≠
.
ii≠ Æ
ticket
iiÆ ¥
.
ii¥ µ
	UpdatedAt
iiµ æ
.
iiæ ø
Ticks
iiø ƒ
}
iiƒ ≈
"
ii≈ ∆
)
ii∆ «
,
ii« »
ct
ii… À
)
iiÀ Ã
;
iiÃ Õ
returnjj 
Okjj 
(jj 
newjj 
{jj 
statusjj 
=jj  
entryjj! &
.jj& '
ticketjj' -
.jj- .
Statusjj. 4
.jj4 5
ToStringjj5 =
(jj= >
)jj> ?
}jj@ A
)jjA B
;jjB C
}kk 
[ll 
HttpPostll 
(ll 
$strll *
)ll* +
]ll+ ,
publicmm 

asyncmm 
Taskmm 
<mm 
ActionResultmm "
>mm" #
AddTicketCommentmm$ 4
(mm4 5
Guidmm5 9
idmm: <
,mm< =&
CreateTicketCommentRequestmm> X
requestmmY `
,mm` a
CancellationTokenmmb s
ctmmt v
)mmv w
{nn 
ifoo 

(oo 
stringoo 
.oo 
IsNullOrWhiteSpaceoo %
(oo% &
requestoo& -
.oo- .
Bodyoo. 2
)oo2 3
)oo3 4
returnoo5 ;

BadRequestoo< F
(ooF G
newooG J
{ooK L
messageooM T
=ooU V
$strooW |
}oo} ~
)oo~ 
;	oo Ä
varpp 
entrypp 
=pp 
awaitpp 
(pp 
frompp 
ticketpp  &
inpp' )
dbpp* ,
.pp, -
Ticketspp- 4
joinpp5 9
projectpp: A
inppB D
dbppE G
.ppG H
ProjectsppH P
onppQ S
ticketppT Z
.ppZ [
	ProjectIdpp[ d
equalsppe k
projectppl s
.pps t
Idppt v
whereppw |
ticket	pp} É
.
ppÉ Ñ
Id
ppÑ Ü
==
ppá â
id
ppä å
select
ppç ì
new
ppî ó
{
ppò ô
ticket
ppö †
,
pp† °
project
pp¢ ©
}
pp™ ´
)
pp´ ¨
.
pp¨ ≠"
SingleOrDefaultAsync
pp≠ ¡
(
pp¡ ¬
ct
pp¬ ƒ
)
ppƒ ≈
;
pp≈ ∆
if
pp« …
(
pp  À
entry
ppÀ –
is
pp— ”
null
pp‘ ÿ
)
ppÿ Ÿ
return
pp⁄ ‡
NotFound
pp· È
(
ppÈ Í
)
ppÍ Î
;
ppÎ Ï
varqq 
commentqq 
=qq 
newqq 
TicketCommentqq '
{qq( )
TicketIdqq* 2
=qq3 4
idqq5 7
,qq7 8
AuthorUserIdqq9 E
=qqF G
UserIdqqH N
,qqN O
BodyqqP T
=qqU V
requestqqW ^
.qq^ _
Bodyqq_ c
.qqc d
Trimqqd h
(qqh i
)qqi j
}qqk l
;qql m
dbqqn p
.qqp q
TicketCommentsqqq 
.	qq Ä
Add
qqÄ É
(
qqÉ Ñ
comment
qqÑ ã
)
qqã å
;
qqå ç
entry
qqé ì
.
qqì î
ticket
qqî ö
.
qqö õ
	UpdatedAt
qqõ §
=
qq• ¶
DateTime
qqß Ø
.
qqØ ∞
UtcNow
qq∞ ∂
;
qq∂ ∑
await
qq∏ Ω
db
qqæ ¿
.
qq¿ ¡
SaveChangesAsync
qq¡ —
(
qq— “
ct
qq“ ‘
)
qq‘ ’
;
qq’ ÷
ifrr 

(rr 
awaitrr 
dbrr 
.rr 
ProjectRepositoriesrr (
.rr( )
AnyAsyncrr) 1
(rr1 2
xrr2 3
=>rr4 6
xrr7 8
.rr8 9
	ProjectIdrr9 B
==rrC E
entryrrF K
.rrK L
projectrrL S
.rrS T
IdrrT V
,rrV W
ctrrX Z
)rrZ [
)rr[ \
jobsrr] a
.rra b
Enqueuerrb i
<rri j
GitHubIssueSyncJobrrj |
>rr| }
(rr} ~
jrr~ 
=>
rrÄ Ç
j
rrÉ Ñ
.
rrÑ Ö
PostCommentAsync
rrÖ ï
(
rrï ñ
comment
rrñ ù
.
rrù û
Id
rrû †
,
rr† °
CancellationToken
rr¢ ≥
.
rr≥ ¥
None
rr¥ ∏
)
rr∏ π
)
rrπ ∫
;
rr∫ ª
varss 
clientss 
=ss 
awaitss 
dbss 
.ss 
Clientsss %
.ss% &
SingleAsyncss& 1
(ss1 2
xss2 3
=>ss4 6
xss7 8
.ss8 9
Idss9 ;
==ss< >
entryss? D
.ssD E
ticketssE K
.ssK L
ClientIdssL T
,ssT U
ctssV X
)ssX Y
;ssY Z
awaittt 
notificationstt 
.tt 
	SendAsynctt %
(tt% &
clienttt& ,
,tt, -
newtt. 1
Notificationtt2 >
(tt> ?
NotificationTypett? O
.ttO P
TicketReplyttP [
,tt[ \
newtt] `
(tt` a
)tta b
{ttc d
[tte f
$strttf p
]ttp q
=ttr s
entryttt y
.tty z
ticket	ttz Ä
.
ttÄ Å
Id
ttÅ É
.
ttÉ Ñ
ToString
ttÑ å
(
ttå ç
)
ttç é
,
tté è
[
ttê ë
$str
ttë ó
]
ttó ò
=
ttô ö
entry
ttõ †
.
tt† °
ticket
tt° ß
.
ttß ®
Code
tt® ¨
,
tt¨ ≠
[
ttÆ Ø
$str
ttØ ∂
]
tt∂ ∑
=
tt∏ π
entry
tt∫ ø
.
ttø ¿
ticket
tt¿ ∆
.
tt∆ «
Title
tt« Ã
,
ttÃ Õ
[
ttŒ œ
$str
ttœ ◊
]
tt◊ ÿ
=
ttŸ ⁄
$str
tt€ ‚
,
tt‚ „
[
tt‰ Â
$str
ttÂ Î
]
ttÎ Ï
=
ttÌ Ó
comment
ttÔ ˆ
.
ttˆ ˜
Body
tt˜ ˚
}
tt¸ ˝
,
tt˝ ˛
$"
ttˇ Å
$str
ttÅ ï
{
ttï ñ
comment
ttñ ù
.
ttù û
Id
ttû †
}
tt† °
"
tt° ¢
)
tt¢ £
,
tt£ §
ct
tt• ß
)
ttß ®
;
tt® ©
returnuu 
Okuu 
(uu 
awaituu 
PortalControlleruu (
.uu( )
ToCommentDtosuu) 6
(uu6 7
dbuu7 9
,uu9 :
dbuu; =
.uu= >
TicketCommentsuu> L
.uuL M
WhereuuM R
(uuR S
xuuS T
=>uuU W
xuuX Y
.uuY Z
IduuZ \
==uu] _
commentuu` g
.uug h
Iduuh j
)uuj k
)uuk l
.uul m
SingleAsyncuum x
(uux y
ctuuy {
)uu{ |
)uu| }
;uu} ~
}vv 
[ww 
HttpGetww 
(ww 
$strww 
)ww 
]ww 
publicxx 

asyncxx 
Taskxx 
<xx 
ActionResultxx "
>xx" #
ExchangeRatesxx$ 1
(xx1 2
DateOnlyxx2 :
?xx: ;
fromxx< @
,xx@ A
DateOnlyxxB J
?xxJ K
toxxL N
,xxN O
CancellationTokenxxP a
ctxxb d
)xxd e
=>xxf h
Okxxi k
(xxk l
awaitxxl q
dbxxr t
.xxt u
ExchangeRates	xxu Ç
.yy 	
Whereyy	 
(yy 
xyy 
=>yy 
(yy 
fromyy 
==yy 
nullyy !
||yy" $
xyy% &
.yy& '
Dateyy' +
>=yy, .
fromyy/ 3
)yy3 4
&&yy5 7
(yy8 9
toyy9 ;
==yy< >
nullyy? C
||yyD F
xyyG H
.yyH I
DateyyI M
<=yyN P
toyyQ S
)yyS T
)yyT U
.yyU V
OrderByDescendingyyV g
(yyg h
xyyh i
=>yyj l
xyym n
.yyn o
Dateyyo s
)yys t
.zz 	
Selectzz	 
(zz 
xzz 
=>zz 
newzz 
{zz 
datezz 
=zz  !
xzz" #
.zz# $
Datezz$ (
,zz( )
currencyCodezz* 6
=zz7 8
xzz9 :
.zz: ;
CurrencyCodezz; G
,zzG H
	rateToPenzzI R
=zzS T
xzzU V
.zzV W
	RateToPenzzW `
,zz` a
sourcezzb h
=zzi j
xzzk l
.zzl m
Sourcezzm s
}zzt u
)zzu v
.zzv w
ToListAsync	zzw Ç
(
zzÇ É
ct
zzÉ Ö
)
zzÖ Ü
)
zzÜ á
;
zzá à
[|| 
HttpPost|| 
(|| 
$str|| #
)||# $
]||$ %
public}} 

async}} 
Task}} 
<}} 
ActionResult}} "
>}}" #
SyncExchangeRates}}$ 5
(}}5 6
CancellationToken}}6 G
ct}}H J
)}}J K
{~~ 
await 
exchangeRateSync 
. 
	SyncAsync (
(( )
ct) +
)+ ,
;, -
return
ÄÄ 
Ok
ÄÄ 
(
ÄÄ 
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
ExchangeRates
ÄÄ (
.
ÄÄ( )
OrderByDescending
ÄÄ) :
(
ÄÄ: ;
x
ÄÄ; <
=>
ÄÄ= ?
x
ÄÄ@ A
.
ÄÄA B
Date
ÄÄB F
)
ÄÄF G
.
ÄÄG H
Take
ÄÄH L
(
ÄÄL M
$num
ÄÄM N
)
ÄÄN O
.
ÄÄO P
Select
ÄÄP V
(
ÄÄV W
x
ÄÄW X
=>
ÄÄY [
new
ÄÄ\ _
{
ÄÄ` a
date
ÄÄb f
=
ÄÄg h
x
ÄÄi j
.
ÄÄj k
Date
ÄÄk o
,
ÄÄo p
currencyCode
ÄÄq }
=
ÄÄ~ 
xÄÄÄ Å
.ÄÄÅ Ç
CurrencyCodeÄÄÇ é
,ÄÄé è
	rateToPenÄÄê ô
=ÄÄö õ
xÄÄú ù
.ÄÄù û
	RateToPenÄÄû ß
,ÄÄß ®
sourceÄÄ© Ø
=ÄÄ∞ ±
xÄÄ≤ ≥
.ÄÄ≥ ¥
SourceÄÄ¥ ∫
}ÄÄª º
)ÄÄº Ω
.ÄÄΩ æ
ToListAsyncÄÄæ …
(ÄÄ…  
ctÄÄ  Ã
)ÄÄÃ Õ
)ÄÄÕ Œ
;ÄÄŒ œ
}
ÅÅ 
[
ÉÉ 
HttpGet
ÉÉ 
(
ÉÉ 
$str
ÉÉ 
)
ÉÉ 
]
ÉÉ 
public
ÑÑ 

async
ÑÑ 
Task
ÑÑ 
<
ÑÑ 
ActionResult
ÑÑ "
>
ÑÑ" #
TaxSettings
ÑÑ$ /
(
ÑÑ/ 0
CancellationToken
ÑÑ0 A
ct
ÑÑB D
)
ÑÑD E
=>
ÑÑF H
Ok
ÑÑI K
(
ÑÑK L
TaxSettingsDto
ÑÑL Z
(
ÑÑZ [
await
ÑÑ[ `
TaxSettingsRow
ÑÑa o
(
ÑÑo p
ct
ÑÑp r
)
ÑÑr s
)
ÑÑs t
)
ÑÑt u
;
ÑÑu v
[
ÜÜ 
	HttpPatch
ÜÜ 
(
ÜÜ 
$str
ÜÜ 
)
ÜÜ 
]
ÜÜ 
public
áá 

async
áá 
Task
áá 
<
áá 
ActionResult
áá "
>
áá" #
UpdateTaxSettings
áá$ 5
(
áá5 6 
TaxSettingsRequest
áá6 H
request
ááI P
,
ááP Q
CancellationToken
ááR c
ct
áád f
)
ááf g
{
àà 
if
ââ 

(
ââ 
request
ââ 
.
ââ 
IgvRate
ââ 
is
ââ 
decimal
ââ &
igv
ââ' *
&&
ââ+ -
(
ââ. /
igv
ââ/ 2
<
ââ3 4
$num
ââ5 6
||
ââ7 9
igv
ââ: =
>
ââ> ?
$num
ââ@ A
)
ââA B
||
ââC E
request
ââF M
.
ââM N
	RentaRate
ââN W
is
ââX Z
decimal
ââ[ b
renta0
ââc i
&&
ââj l
(
ââm n
renta0
âân t
<
ââu v
$num
ââw x
||
âây {
renta0ââ| Ç
>ââÉ Ñ
$numââÖ Ü
)ââÜ á
)ââá à
returnâââ è

BadRequestââê ö
(ââö õ
newââõ û
{ââü †
messageââ° ®
=ââ© ™
$strââ´ „
}ââ‰ Â
)ââÂ Ê
;ââÊ Á
var
ää 
settings
ää 
=
ää 
await
ää 
TaxSettingsRow
ää +
(
ää+ ,
ct
ää, .
)
ää. /
;
ää/ 0
var
ãã 
facturaSeries
ãã 
=
ãã 
request
ãã #
.
ãã# $
FacturaSeries
ãã$ 1
?
ãã1 2
.
ãã2 3
Trim
ãã3 7
(
ãã7 8
)
ãã8 9
.
ãã9 :
ToUpperInvariant
ãã: J
(
ããJ K
)
ããK L
??
ããM O
settings
ããP X
.
ããX Y
FacturaSeries
ããY f
;
ããf g
var
ããh k
reciboSeries
ããl x
=
ããy z
requestãã{ Ç
.ããÇ É
ReciboSeriesããÉ è
?ããè ê
.ããê ë
Trimããë ï
(ããï ñ
)ããñ ó
.ããó ò 
ToUpperInvariantããò ®
(ãã® ©
)ãã© ™
??ãã´ ≠
settingsããÆ ∂
.ãã∂ ∑
ReciboSeriesãã∑ √
;ãã√ ƒ
var
åå 
facturaNext
åå 
=
åå 
request
åå !
.
åå! "
FacturaNextNumber
åå" 3
??
åå4 6
settings
åå7 ?
.
åå? @
FacturaNextNumber
åå@ Q
;
ååQ R
var
ååS V

reciboNext
ååW a
=
ååb c
request
ååd k
.
ååk l
ReciboNextNumber
åål |
??
åå} 
settingsååÄ à
.ååà â 
ReciboNextNumberååâ ô
;ååô ö
if
çç 

(
çç 
await
çç !
ValidateSeriesAsync
çç %
(
çç% &
facturaSeries
çç& 3
,
çç3 4
facturaNext
çç5 @
,
çç@ A
reciboSeries
ççB N
,
ççN O

reciboNext
ççP Z
,
ççZ [
ct
çç\ ^
)
çç^ _
is
çç` b
string
ççc i
seriesError
ççj u
)
ççu v
return
ççw }

BadRequestçç~ à
(ççà â
newççâ å
{ççç é
messageççè ñ
=ççó ò
seriesErrorççô §
}çç• ¶
)çç¶ ß
;ççß ®
var
éé 
ruc
éé 
=
éé 
request
éé 
.
éé 
Ruc
éé 
is
éé  
null
éé! %
?
éé& '
settings
éé( 0
.
éé0 1
Ruc
éé1 4
:
éé5 6
EmptyToNull
éé7 B
(
ééB C
request
ééC J
.
ééJ K
Ruc
ééK N
)
ééN O
;
ééO P
if
èè 

(
èè 
ruc
èè 
is
èè 
not
èè 
null
èè 
&&
èè 
!
èè  
Regex
èè  %
.
èè% &
IsMatch
èè& -
(
èè- .
ruc
èè. 1
,
èè1 2
$str
èè3 L
)
èèL M
)
èèM N
return
èèO U

BadRequest
èèV `
(
èè` a
new
èèa d
{
èèe f
message
èèg n
=
èèo p
$strèèq ©
}èè™ ´
)èè´ ¨
;èè¨ ≠
settings
êê 
.
êê 
Ruc
êê 
=
êê 
ruc
êê 
;
êê 
if
ëë 

(
ëë 
request
ëë 
.
ëë 
IsGoodTaxpayer
ëë "
is
ëë# %
bool
ëë& *
goodTaxpayer
ëë+ 7
)
ëë7 8
settings
ëë9 A
.
ëëA B
IsGoodTaxpayer
ëëB P
=
ëëQ R
goodTaxpayer
ëëS _
;
ëë_ `
if
íí 

(
íí 
request
íí 
.
íí 
Use1662AsCredit
íí #
is
íí$ &
bool
íí' +
use1662
íí, 3
)
íí3 4
settings
íí5 =
.
íí= >
Use1662AsCredit
íí> M
=
ííN O
use1662
ííP W
;
ííW X
if
ìì 

(
ìì 
request
ìì 
.
ìì 
IgvRate
ìì 
is
ìì 
decimal
ìì &
igvRate
ìì' .
)
ìì. /
settings
ìì0 8
.
ìì8 9
IgvRate
ìì9 @
=
ììA B
igvRate
ììC J
;
ììJ K
if
îî 

(
îî 
request
îî 
.
îî 
	RentaRate
îî 
is
îî  
decimal
îî! (
	rentaRate
îî) 2
)
îî2 3
settings
îî4 <
.
îî< =
	RentaRate
îî= F
=
îîG H
	rentaRate
îîI R
;
îîR S
(
ïï 	
settings
ïï	 
.
ïï 
FacturaSeries
ïï 
,
ïï  
settings
ïï! )
.
ïï) *
FacturaNextNumber
ïï* ;
,
ïï; <
settings
ïï= E
.
ïïE F
ReciboSeries
ïïF R
,
ïïR S
settings
ïïT \
.
ïï\ ]
ReciboNextNumber
ïï] m
)
ïïm n
=
ïïo p
(
ïïq r
facturaSeries
ïïr 
,ïï Ä
facturaNextïïÅ å
,ïïå ç
reciboSeriesïïé ö
,ïïö õ

reciboNextïïú ¶
)ïï¶ ß
;ïïß ®
settings
ññ 
.
ññ 
	UpdatedAt
ññ 
=
ññ 
DateTime
ññ %
.
ññ% &
UtcNow
ññ& ,
;
ññ, -
await
óó 
db
óó 
.
óó 
SaveChangesAsync
óó !
(
óó! "
ct
óó" $
)
óó$ %
;
óó% &
return
òò 
Ok
òò 
(
òò 
TaxSettingsDto
òò  
(
òò  !
settings
òò! )
)
òò) *
)
òò* +
;
òò+ ,
}
ôô 
private
õõ 
async
õõ 
Task
õõ 
<
õõ 
string
õõ 
?
õõ 
>
õõ !
ValidateSeriesAsync
õõ  3
(
õõ3 4
string
õõ4 :
facturaSeries
õõ; H
,
õõH I
int
õõJ M
facturaNext
õõN Y
,
õõY Z
string
õõ[ a
reciboSeries
õõb n
,
õõn o
int
õõp s

reciboNext
õõt ~
,
õõ~ !
CancellationTokenõõÄ ë
ctõõí î
)õõî ï
{
úú 
if
üü 

(
üü 
!
üü 
Regex
üü 
.
üü 
IsMatch
üü 
(
üü 
facturaSeries
üü (
,
üü( )
$str
üü* =
)
üü= >
||
üü? A
!
üüB C
Regex
üüC H
.
üüH I
IsMatch
üüI P
(
üüP Q
reciboSeries
üüQ ]
,
üü] ^
$str
üü_ o
)
üüo p
)
üüp q
return
üür x
$strüüy ô
;üüô ö
if
†† 

(
†† 
facturaNext
†† 
<
†† 
$num
†† 
||
†† 

reciboNext
†† )
<
††* +
$num
††, -
)
††- .
return
††/ 5
$str
††6 b
;
††b c
if
¢¢ 

(
¢¢ 
await
¢¢ 
LastNumberAsync
¢¢ !
(
¢¢! "
TaxDocumentType
¢¢" 1
.
¢¢1 2
Factura
¢¢2 9
,
¢¢9 :
facturaSeries
¢¢; H
,
¢¢H I
ct
¢¢J L
)
¢¢L M
is
¢¢N P
int
¢¢Q T
lastF
¢¢U Z
&&
¢¢[ ]
facturaNext
¢¢^ i
<=
¢¢j l
lastF
¢¢m r
)
¢¢r s
return
¢¢t z
$"
¢¢{ }
$str¢¢} Ü
{¢¢Ü á
facturaSeries¢¢á î
}¢¢î ï
$str¢¢ï Æ
{¢¢Æ Ø
lastF¢¢Ø ¥
}¢¢¥ µ
$str¢¢µ ›
"¢¢› ﬁ
;¢¢ﬁ ﬂ
if
££ 

(
££ 
await
££ 
LastNumberAsync
££ !
(
££! "
TaxDocumentType
££" 1
.
££1 2!
ReciboPorHonorarios
££2 E
,
££E F
reciboSeries
££G S
,
££S T
ct
££U W
)
££W X
is
££Y [
int
££\ _
lastR
££` e
&&
££f h

reciboNext
££i s
<=
££t v
lastR
££w |
)
££| }
return££~ Ñ
$"££Ö á
$str££á ê
{££ê ë
reciboSeries££ë ù
}££ù û
$str££û ∂
{££∂ ∑
lastR££∑ º
}££º Ω
$str££Ω Â
"££Â Ê
;££Ê Á
return
§§ 
null
§§ 
;
§§ 
}
•• 
private
ßß 
Task
ßß 
<
ßß 
int
ßß 
?
ßß 
>
ßß 
LastNumberAsync
ßß &
(
ßß& '
TaxDocumentType
ßß' 6
type
ßß7 ;
,
ßß; <
string
ßß= C
series
ßßD J
,
ßßJ K
CancellationToken
ßßL ]
ct
ßß^ `
)
ßß` a
=>
ßßb d
db
ßße g
.
ßßg h
TaxDocuments
ßßh t
.
ßßt u
Where
ßßu z
(
ßßz {
x
ßß{ |
=>
ßß} 
xßßÄ Å
.ßßÅ Ç
TypeßßÇ Ü
==ßßá â
typeßßä é
&&ßßè ë
xßßí ì
.ßßì î
Seriesßßî ö
==ßßõ ù
seriesßßû §
)ßß§ •
.ßß• ¶
MaxAsyncßß¶ Æ
(ßßÆ Ø
xßßØ ∞
=>ßß± ≥
(ßß¥ µ
intßßµ ∏
?ßß∏ π
)ßßπ ∫
xßß∫ ª
.ßßª º
Numberßßº ¬
,ßß¬ √
ctßßƒ ∆
)ßß∆ «
;ßß« »
private
®® 
static
®® 
object
®® 
TaxSettingsDto
®® (
(
®®( )
TaxSettings
®®) 4
x
®®5 6
)
®®6 7
=>
®®8 :
new
®®; >
{
®®? @
igvRate
®®A H
=
®®I J
x
®®K L
.
®®L M
IgvRate
®®M T
,
®®T U
	rentaRate
®®V _
=
®®` a
x
®®b c
.
®®c d
	RentaRate
®®d m
,
®®m n
facturaSeries
®®o |
=
®®} ~
x®® Ä
.®®Ä Å
FacturaSeries®®Å é
,®®é è!
facturaNextNumber®®ê °
=®®¢ £
x®®§ •
.®®• ¶!
FacturaNextNumber®®¶ ∑
,®®∑ ∏
reciboSeries®®π ≈
=®®∆ «
x®®» …
.®®…  
ReciboSeries®®  ÷
,®®÷ ◊ 
reciboNextNumber®®ÿ Ë
=®®È Í
x®®Î Ï
.®®Ï Ì 
ReciboNextNumber®®Ì ˝
,®®˝ ˛
ruc®®ˇ Ç
=®®É Ñ
x®®Ö Ü
.®®Ü á
Ruc®®á ä
,®®ä ã
isGoodTaxpayer®®å ö
=®®õ ú
x®®ù û
.®®û ü
IsGoodTaxpayer®®ü ≠
,®®≠ Æ
use1662AsCredit®®Ø æ
=®®ø ¿
x®®¡ ¬
.®®¬ √
Use1662AsCredit®®√ “
}®®” ‘
;®®‘ ’
private
™™ 
async
™™ 
Task
™™ 
<
™™ 
TaxSettings
™™ "
>
™™" #
TaxSettingsRow
™™$ 2
(
™™2 3
CancellationToken
™™3 D
ct
™™E G
)
™™G H
{
´´ 
var
¨¨ 
settings
¨¨ 
=
¨¨ 
await
¨¨ 
db
¨¨ 
.
¨¨  
TaxSettings
¨¨  +
.
¨¨+ ,!
FirstOrDefaultAsync
¨¨, ?
(
¨¨? @
ct
¨¨@ B
)
¨¨B C
;
¨¨C D
if
≠≠ 

(
≠≠ 
settings
≠≠ 
is
≠≠ 
not
≠≠ 
null
≠≠  
)
≠≠  !
return
≠≠" (
settings
≠≠) 1
;
≠≠1 2
settings
ÆÆ 
=
ÆÆ 
new
ÆÆ 
TaxSettings
ÆÆ "
(
ÆÆ" #
)
ÆÆ# $
;
ÆÆ$ %
db
ÆÆ& (
.
ÆÆ( )
TaxSettings
ÆÆ) 4
.
ÆÆ4 5
Add
ÆÆ5 8
(
ÆÆ8 9
settings
ÆÆ9 A
)
ÆÆA B
;
ÆÆB C
await
ÆÆD I
db
ÆÆJ L
.
ÆÆL M
SaveChangesAsync
ÆÆM ]
(
ÆÆ] ^
ct
ÆÆ^ `
)
ÆÆ` a
;
ÆÆa b
return
ÆÆc i
settings
ÆÆj r
;
ÆÆr s
}
ØØ 
[
±± 
HttpGet
±± 
(
±± 
$str
±± 
)
±± 
]
±± 
public
≤≤ 

async
≤≤ 
Task
≤≤ 
<
≤≤ 
ActionResult
≤≤ "
>
≤≤" #
TaxDocuments
≤≤$ 0
(
≤≤0 1
Guid
≤≤1 5
?
≤≤5 6
clientId
≤≤7 ?
,
≤≤? @
int
≤≤A D
?
≤≤D E
month
≤≤F K
,
≤≤K L
int
≤≤M P
?
≤≤P Q
year
≤≤R V
,
≤≤V W
CancellationToken
≤≤X i
ct
≤≤j l
)
≤≤l m
{
≥≥ 
var
¥¥ 
rows
¥¥ 
=
¥¥ 
await
¥¥ 
db
¥¥ 
.
¥¥ 
TaxDocuments
¥¥ (
.
µµ 
Where
µµ 
(
µµ 
x
µµ 
=>
µµ 
(
µµ 
clientId
µµ !
==
µµ" $
null
µµ% )
||
µµ* ,
x
µµ- .
.
µµ. /
ClientId
µµ/ 7
==
µµ8 :
clientId
µµ; C
)
µµC D
&&
µµE G
(
µµH I
month
µµI N
==
µµO Q
null
µµR V
||
µµW Y
x
µµZ [
.
µµ[ \
	IssueDate
µµ\ e
.
µµe f
Month
µµf k
==
µµl n
month
µµo t
)
µµt u
&&
µµv x
(
µµy z
year
µµz ~
==µµ Å
nullµµÇ Ü
||µµá â
xµµä ã
.µµã å
	IssueDateµµå ï
.µµï ñ
Yearµµñ ö
==µµõ ù
yearµµû ¢
)µµ¢ £
)µµ£ §
.
∂∂ 
OrderByDescending
∂∂ 
(
∂∂ 
x
∂∂  
=>
∂∂! #
x
∂∂$ %
.
∂∂% &
	IssueDate
∂∂& /
)
∂∂/ 0
.
∂∂0 1
ThenByDescending
∂∂1 A
(
∂∂A B
x
∂∂B C
=>
∂∂D F
x
∂∂G H
.
∂∂H I
Number
∂∂I O
)
∂∂O P
.
∑∑ 
Select
∑∑ 
(
∑∑ 
x
∑∑ 
=>
∑∑ 
new
∑∑ 
{
∑∑ 
Document
∑∑ '
=
∑∑( )
x
∑∑* +
,
∑∑+ ,
Payment
∑∑- 4
=
∑∑5 6
db
∑∑7 9
.
∑∑9 :!
PaymentTransactions
∑∑: M
.
∑∑M N
Where
∑∑N S
(
∑∑S T
p
∑∑T U
=>
∑∑V X
p
∑∑Y Z
.
∑∑Z [
Id
∑∑[ ]
==
∑∑^ `
x
∑∑a b
.
∑∑b c"
PaymentTransactionId
∑∑c w
)
∑∑w x
.
∑∑x y
Select
∑∑y 
(∑∑ Ä
p∑∑Ä Å
=>∑∑Ç Ñ
new∑∑Ö à
{∑∑â ä
p∑∑ã å
.∑∑å ç
Amount∑∑ç ì
,∑∑ì î
p∑∑ï ñ
.∑∑ñ ó
	AmountPen∑∑ó †
,∑∑† °
p∑∑¢ £
.∑∑£ §
Method∑∑§ ™
}∑∑´ ¨
)∑∑¨ ≠
.∑∑≠ Æ
FirstOrDefault∑∑Æ º
(∑∑º Ω
)∑∑Ω æ
}∑∑ø ¿
)∑∑¿ ¡
.
∏∏ 
ToListAsync
∏∏ 
(
∏∏ 
ct
∏∏ 
)
∏∏ 
;
∏∏ 
var
ππ 
docIds
ππ 
=
ππ 
rows
ππ 
.
ππ 
Select
ππ  
(
ππ  !
x
ππ! "
=>
ππ# %
x
ππ& '
.
ππ' (
Document
ππ( 0
.
ππ0 1
Id
ππ1 3
)
ππ3 4
.
ππ4 5
ToList
ππ5 ;
(
ππ; <
)
ππ< =
;
ππ= >
var
∫∫ 
lines
∫∫ 
=
∫∫ 
(
∫∫ 
await
∫∫ 
db
∫∫ 
.
∫∫ 
TaxDocumentLines
∫∫ .
.
∫∫. /
Where
∫∫/ 4
(
∫∫4 5
x
∫∫5 6
=>
∫∫7 9
docIds
∫∫: @
.
∫∫@ A
Contains
∫∫A I
(
∫∫I J
x
∫∫J K
.
∫∫K L
TaxDocumentId
∫∫L Y
)
∫∫Y Z
)
∫∫Z [
.
∫∫[ \
OrderBy
∫∫\ c
(
∫∫c d
x
∫∫d e
=>
∫∫f h
x
∫∫i j
.
∫∫j k
Order
∫∫k p
)
∫∫p q
.
∫∫q r
ToListAsync
∫∫r }
(
∫∫} ~
ct∫∫~ Ä
)∫∫Ä Å
)∫∫Å Ç
.∫∫Ç É
ToLookup∫∫É ã
(∫∫ã å
x∫∫å ç
=>∫∫é ê
x∫∫ë í
.∫∫í ì
TaxDocumentId∫∫ì †
)∫∫† °
;∫∫° ¢
var
ªª 
result
ªª 
=
ªª 
new
ªª 
List
ªª 
<
ªª 
object
ªª $
>
ªª$ %
(
ªª% &
rows
ªª& *
.
ªª* +
Count
ªª+ 0
)
ªª0 1
;
ªª1 2
foreach
ºº 
(
ºº 
var
ºº 
x
ºº 
in
ºº 
rows
ºº 
)
ºº 
{
ΩΩ 	
var
øø 
rate
øø 
=
øø 
x
øø 
.
øø 
Payment
øø  
is
øø! #
{
øø$ %
Amount
øø& ,
:
øø, -
>
øø. /
$num
øø0 1
}
øø2 3
p
øø4 5
?
øø6 7
p
øø8 9
.
øø9 :
	AmountPen
øø: C
/
øøD E
p
øøF G
.
øøG H
Amount
øøH N
:
øøO P
await
øøQ V
db
øøW Y
.
øøY Z
RateToPenAsync
øøZ h
(
øøh i
x
øøi j
.
øøj k
Document
øøk s
.
øøs t
Currency
øøt |
,
øø| }
x
øø~ 
.øø Ä
DocumentøøÄ à
.øøà â
	IssueDateøøâ í
,øøí ì
ctøøî ñ
)øøñ ó
;øøó ò
result
¿¿ 
.
¿¿ 
Add
¿¿ 
(
¿¿ 
TaxDocumentDto
¿¿ %
(
¿¿% &
x
¿¿& '
.
¿¿' (
Document
¿¿( 0
,
¿¿0 1
rate
¿¿2 6
,
¿¿6 7
lines
¿¿8 =
[
¿¿= >
x
¿¿> ?
.
¿¿? @
Document
¿¿@ H
.
¿¿H I
Id
¿¿I K
]
¿¿K L
,
¿¿L M
x
¿¿N O
.
¿¿O P
Payment
¿¿P W
?
¿¿W X
.
¿¿X Y
Method
¿¿Y _
)
¿¿_ `
)
¿¿` a
;
¿¿a b
}
¡¡ 	
return
¬¬ 
Ok
¬¬ 
(
¬¬ 
result
¬¬ 
)
¬¬ 
;
¬¬ 
}
√√ 
[
…… 
HttpPost
…… 
(
…… 
$str
…… 
)
…… 
]
…… 
public
   

async
   
Task
   
<
   
ActionResult
   "
>
  " #
CreateTaxDocument
  $ 5
(
  5 6 
TaxDocumentRequest
  6 H
request
  I P
,
  P Q
CancellationToken
  R c
ct
  d f
)
  f g
{
ÀÀ 
var
ÃÃ 
items
ÃÃ 
=
ÃÃ 
TaxDocumentItems
ÃÃ $
(
ÃÃ$ %
request
ÃÃ% ,
)
ÃÃ, -
;
ÃÃ- .
if
ÕÕ 

(
ÕÕ &
ValidateTaxDocumentItems
ÕÕ $
(
ÕÕ$ %
request
ÕÕ% ,
.
ÕÕ, -
Currency
ÕÕ- 5
,
ÕÕ5 6
items
ÕÕ7 <
)
ÕÕ< =
is
ÕÕ> @
string
ÕÕA G

itemsError
ÕÕH R
)
ÕÕR S
return
ÕÕT Z

BadRequest
ÕÕ[ e
(
ÕÕe f
new
ÕÕf i
{
ÕÕj k
message
ÕÕl s
=
ÕÕt u

itemsErrorÕÕv Ä
}ÕÕÅ Ç
)ÕÕÇ É
;ÕÕÉ Ñ
var
ŒŒ 
ids
ŒŒ 
=
ŒŒ 
items
ŒŒ 
.
ŒŒ 
Select
ŒŒ 
(
ŒŒ 
x
ŒŒ  
=>
ŒŒ! #
x
ŒŒ$ %
.
ŒŒ% &
ClientProductId
ŒŒ& 5
)
ŒŒ5 6
.
ŒŒ6 7
ToList
ŒŒ7 =
(
ŒŒ= >
)
ŒŒ> ?
;
ŒŒ? @
var
œœ 
products
œœ 
=
œœ 
await
œœ 
db
œœ 
.
œœ  
ClientProducts
œœ  .
.
œœ. /
Include
œœ/ 6
(
œœ6 7
x
œœ7 8
=>
œœ9 ;
x
œœ< =
.
œœ= >
Product
œœ> E
)
œœE F
.
œœF G
Where
œœG L
(
œœL M
x
œœM N
=>
œœO Q
ids
œœR U
.
œœU V
Contains
œœV ^
(
œœ^ _
x
œœ_ `
.
œœ` a
Id
œœa c
)
œœc d
)
œœd e
.
œœe f
ToListAsync
œœf q
(
œœq r
ct
œœr t
)
œœt u
;
œœu v
if
–– 

(
–– 
products
–– 
.
–– 
Count
–– 
!=
–– 
items
–– #
.
––# $
Count
––$ )
||
––* ,
products
––- 5
.
––5 6
Any
––6 9
(
––9 :
x
––: ;
=>
––< >
x
––? @
.
––@ A
Product
––A H
is
––I K
null
––L P
)
––P Q
)
––Q R
return
––S Y
NotFound
––Z b
(
––b c
new
––c f
{
––g h
message
––i p
=
––q r
$str––s ò
}––ô ö
)––ö õ
;––õ ú
if
—— 

(
—— 
products
—— 
.
—— 
Select
—— 
(
—— 
x
—— 
=>
——  
x
——! "
.
——" #
ClientId
——# +
)
——+ ,
.
——, -
Distinct
——- 5
(
——5 6
)
——6 7
.
——7 8
Count
——8 =
(
——= >
)
——> ?
>
——@ A
$num
——B C
)
——C D
return
——E K

BadRequest
——L V
(
——V W
new
——W Z
{
——[ \
message
——] d
=
——e f
$str——g ô
}——ö õ
)——õ ú
;——ú ù
var
““ 
types
““ 
=
““ 
products
““ 
.
““ 
Select
““ #
(
““# $
x
““$ %
=>
““& (
x
““) *
.
““* +
Product
““+ 2
!
““2 3
.
““3 4
TaxDocumentType
““4 C
)
““C D
.
““D E
Distinct
““E M
(
““M N
)
““N O
.
““O P
ToList
““P V
(
““V W
)
““W X
;
““X Y
if
”” 

(
”” 
types
”” 
.
”” 
Count
”” 
>
”” 
$num
”” 
)
”” 
return
”” #

BadRequest
””$ .
(
””. /
new
””/ 2
{
””3 4
message
””5 <
=
””= >
$str””? ∑
}””∏ π
)””π ∫
;””∫ ª
var
‘‘ 
client
‘‘ 
=
‘‘ 
await
‘‘ 
db
‘‘ 
.
‘‘ 
Clients
‘‘ %
.
‘‘% &
	FindAsync
‘‘& /
(
‘‘/ 0
[
‘‘0 1
products
‘‘1 9
[
‘‘9 :
$num
‘‘: ;
]
‘‘; <
.
‘‘< =
ClientId
‘‘= E
]
‘‘E F
,
‘‘F G
ct
‘‘H J
)
‘‘J K
;
‘‘K L
if
’’ 

(
’’ 
client
’’ 
is
’’ 
null
’’ 
||
’’ 
!
’’ 
client
’’ %
.
’’% &!
RequiresTaxDocument
’’& 9
)
’’9 :
return
’’; A

BadRequest
’’B L
(
’’L M
new
’’M P
{
’’Q R
message
’’S Z
=
’’[ \
$str’’] ≤
}’’≥ ¥
)’’¥ µ
;’’µ ∂
var
÷÷ 
total
÷÷ 
=
÷÷ 
items
÷÷ 
.
÷÷ 
Sum
÷÷ 
(
÷÷ 
x
÷÷ 
=>
÷÷  "
x
÷÷# $
.
÷÷$ %
Amount
÷÷% +
)
÷÷+ ,
;
÷÷, -
if
◊◊ 

(
◊◊ 
request
◊◊ 
.
◊◊ 
RetentionAmount
◊◊ #
is
◊◊$ &
<
◊◊' (
$num
◊◊) *
||
◊◊+ -
request
◊◊. 5
.
◊◊5 6
RetentionAmount
◊◊6 E
>
◊◊F G
total
◊◊H M
)
◊◊M N
return
◊◊O U

BadRequest
◊◊V `
(
◊◊` a
new
◊◊a d
{
◊◊e f
message
◊◊g n
=
◊◊o p
$str◊◊q û
}◊◊ü †
)◊◊† °
;◊◊° ¢
var
⁄⁄ 
currency
⁄⁄ 
=
⁄⁄ 
request
⁄⁄ 
.
⁄⁄ 
Currency
⁄⁄ '
.
⁄⁄' (
Trim
⁄⁄( ,
(
⁄⁄, -
)
⁄⁄- .
.
⁄⁄. /
ToUpperInvariant
⁄⁄/ ?
(
⁄⁄? @
)
⁄⁄@ A
;
⁄⁄A B
var
€€ 
payment
€€ 
=
€€ 
new
€€  
PaymentTransaction
€€ ,
{
€€- .
ClientId
€€/ 7
=
€€8 9
client
€€: @
.
€€@ A
Id
€€A C
,
€€C D
ClientProductId
€€E T
=
€€U V
items
€€W \
.
€€\ ]
Count
€€] b
==
€€c e
$num
€€f g
?
€€h i
items
€€j o
[
€€o p
$num
€€p q
]
€€q r
.
€€r s
ClientProductId€€s Ç
:€€É Ñ
null€€Ö â
,€€â ä
Amount€€ã ë
=€€í ì
total€€î ô
,€€ô ö
Currency€€õ £
=€€§ •
currency€€¶ Æ
,€€Æ Ø
Status€€∞ ∂
=€€∑ ∏
$str€€π ƒ
,€€ƒ ≈
Method€€∆ Ã
=€€Õ Œ
PaymentMethods€€œ ›
.€€› ﬁ
Transferencia€€ﬁ Î
,€€Î Ï
	CreatedAt€€Ì ˆ
=€€˜ ¯
request€€˘ Ä
.€€Ä Å
	IssueDate€€Å ä
.€€ä ã

ToDateTime€€ã ï
(€€ï ñ
new€€ñ ô
TimeOnly€€ö ¢
(€€¢ £
$num€€£ •
,€€• ¶
$num€€ß ®
)€€® ©
,€€© ™
DateTimeKind€€´ ∑
.€€∑ ∏
Utc€€∏ ª
)€€ª º
,€€º Ω
Notes€€æ √
=€€ƒ ≈
EmptyToNull€€∆ —
(€€— “
request€€“ Ÿ
.€€Ÿ ⁄
Notes€€⁄ ﬂ
)€€ﬂ ‡
}€€· ‚
;€€‚ „
payment
‹‹ 
.
‹‹ +
PayPalOrderIdOrSubscriptionId
‹‹ -
=
‹‹. /
$"
‹‹0 2
$str
‹‹2 9
{
‹‹9 :
payment
‹‹: A
.
‹‹A B
Id
‹‹B D
:
‹‹D E
$str
‹‹E F
}
‹‹F G
"
‹‹G H
;
‹‹H I
payment
›› 
.
›› 
InternalCode
›› 
=
›› 
await
›› $
db
››% '
.
››' (#
NextInternalCodeAsync
››( =
(
››= >
ct
››> @
)
››@ A
;
››A B
payment
ﬁﬁ 
.
ﬁﬁ 
	AmountPen
ﬁﬁ 
=
ﬁﬁ 
payment
ﬁﬁ #
.
ﬁﬁ# $
Amount
ﬁﬁ$ *
*
ﬁﬁ+ ,
await
ﬁﬁ- 2
db
ﬁﬁ3 5
.
ﬁﬁ5 6
RateToPenAsync
ﬁﬁ6 D
(
ﬁﬁD E
currency
ﬁﬁE M
,
ﬁﬁM N
request
ﬁﬁO V
.
ﬁﬁV W
	IssueDate
ﬁﬁW `
,
ﬁﬁ` a
ct
ﬁﬁb d
)
ﬁﬁd e
;
ﬁﬁe f
db
ﬂﬂ 

.
ﬂﬂ
 !
PaymentTransactions
ﬂﬂ 
.
ﬂﬂ 
Add
ﬂﬂ "
(
ﬂﬂ" #
payment
ﬂﬂ# *
)
ﬂﬂ* +
;
ﬂﬂ+ ,
await
ﬂﬂ- 2
db
ﬂﬂ3 5
.
ﬂﬂ5 6
SaveChangesAsync
ﬂﬂ6 F
(
ﬂﬂF G
ct
ﬂﬂG I
)
ﬂﬂI J
;
ﬂﬂJ K
var
‡‡ 
lines
‡‡ 
=
‡‡ 
items
‡‡ 
.
‡‡ 
Select
‡‡  
(
‡‡  !
x
‡‡! "
=>
‡‡# %
new
‡‡& )
TaxDocumentLine
‡‡* 9
{
‡‡: ;
ClientProductId
‡‡< K
=
‡‡L M
x
‡‡N O
.
‡‡O P
ClientProductId
‡‡P _
,
‡‡_ `
Description
‡‡a l
=
‡‡m n!
TaxDocumentService‡‡o Å
.‡‡Å Ç
LineDescription‡‡Ç ë
(‡‡ë í
products‡‡í ö
.‡‡ö õ
Single‡‡õ °
(‡‡° ¢
p‡‡¢ £
=>‡‡§ ¶
p‡‡ß ®
.‡‡® ©
Id‡‡© ´
==‡‡¨ Æ
x‡‡Ø ∞
.‡‡∞ ±
ClientProductId‡‡± ¿
)‡‡¿ ¡
)‡‡¡ ¬
,‡‡¬ √
Amount‡‡ƒ  
=‡‡À Ã
x‡‡Õ Œ
.‡‡Œ œ
Amount‡‡œ ’
}‡‡÷ ◊
)‡‡◊ ÿ
.‡‡ÿ Ÿ
ToList‡‡Ÿ ﬂ
(‡‡ﬂ ‡
)‡‡‡ ·
;‡‡· ‚
var
·· 
document
·· 
=
·· 
await
·· 
taxDocuments
·· )
.
··) *

IssueAsync
··* 4
(
··4 5
new
··5 8
TaxDocumentDraft
··9 I
(
··I J
client
··J P
.
··P Q
Id
··Q S
,
··S T
types
··U Z
[
··Z [
$num
··[ \
]
··\ ]
,
··] ^
request
··_ f
.
··f g
	IssueDate
··g p
,
··p q
currency
··r z
,
··z {
total··| Å
,··Å Ç
EmptyToNull··É é
(··é è
request··è ñ
.··ñ ó
Notes··ó ú
)··ú ù
,··ù û
payment··ü ¶
.··¶ ß
Id··ß ©
,··© ™
lines··´ ∞
)··∞ ±
,··± ≤
ct··≥ µ
)··µ ∂
;··∂ ∑
if
‚‚ 

(
‚‚ 
request
‚‚ 
.
‚‚ 
RetentionAmount
‚‚ #
>
‚‚$ %
$num
‚‚& '
)
‚‚' (
{
‚‚) *
document
‚‚+ 3
.
‚‚3 4
RetentionAmount
‚‚4 C
=
‚‚D E
request
‚‚F M
.
‚‚M N
RetentionAmount
‚‚N ]
;
‚‚] ^
await
‚‚_ d
db
‚‚e g
.
‚‚g h
SaveChangesAsync
‚‚h x
(
‚‚x y
ct
‚‚y {
)
‚‚{ |
;
‚‚| }
}
‚‚~ 
var
„„ 
saved
„„ 
=
„„ 
await
„„ 
db
„„ 
.
„„ 
TaxDocumentLines
„„ -
.
„„- .
Where
„„. 3
(
„„3 4
x
„„4 5
=>
„„6 8
x
„„9 :
.
„„: ;
TaxDocumentId
„„; H
==
„„I K
document
„„L T
.
„„T U
Id
„„U W
)
„„W X
.
„„X Y
OrderBy
„„Y `
(
„„` a
x
„„a b
=>
„„c e
x
„„f g
.
„„g h
Order
„„h m
)
„„m n
.
„„n o
ToListAsync
„„o z
(
„„z {
ct
„„{ }
)
„„} ~
;
„„~ 
return
‰‰ 
Created
‰‰ 
(
‰‰ 
$"
‰‰ 
$str
‰‰ 2
{
‰‰2 3
document
‰‰3 ;
.
‰‰; <
Id
‰‰< >
}
‰‰> ?
"
‰‰? @
,
‰‰@ A
TaxDocumentDto
‰‰B P
(
‰‰P Q
document
‰‰Q Y
,
‰‰Y Z
payment
‰‰[ b
.
‰‰b c
Amount
‰‰c i
>
‰‰j k
$num
‰‰l m
?
‰‰n o
payment
‰‰p w
.
‰‰w x
	AmountPen‰‰x Å
/‰‰Ç É
payment‰‰Ñ ã
.‰‰ã å
Amount‰‰å í
:‰‰ì î
$num‰‰ï ó
,‰‰ó ò
saved‰‰ô û
,‰‰û ü
payment‰‰† ß
.‰‰ß ®
Method‰‰® Æ
)‰‰Æ Ø
)‰‰Ø ∞
;‰‰∞ ±
}
ÂÂ 
private
ËË 
static
ËË 
IReadOnlyList
ËË  
<
ËË  !$
TaxDocumentItemRequest
ËË! 7
>
ËË7 8
TaxDocumentItems
ËË9 I
(
ËËI J 
TaxDocumentRequest
ËËJ \
request
ËË] d
)
ËËd e
{
ÈÈ 
if
ÍÍ 

(
ÍÍ 
request
ÍÍ 
.
ÍÍ 
Items
ÍÍ 
is
ÍÍ 
{
ÍÍ 
Count
ÍÍ $
:
ÍÍ$ %
>
ÍÍ& '
$num
ÍÍ( )
}
ÍÍ* +
list
ÍÍ, 0
)
ÍÍ0 1
return
ÍÍ2 8
list
ÍÍ9 =
;
ÍÍ= >
return
ÎÎ 
request
ÎÎ 
.
ÎÎ 
ClientProductId
ÎÎ &
is
ÎÎ' )
Guid
ÎÎ* .
single
ÎÎ/ 5
?
ÎÎ6 7
[
ÎÎ8 9
new
ÎÎ9 <$
TaxDocumentItemRequest
ÎÎ= S
(
ÎÎS T
single
ÎÎT Z
,
ÎÎZ [
request
ÎÎ\ c
.
ÎÎc d
TotalAmount
ÎÎd o
??
ÎÎp r
$num
ÎÎs t
)
ÎÎt u
]
ÎÎu v
:
ÎÎw x
[
ÎÎy z
]
ÎÎz {
;
ÎÎ{ |
}
ÏÏ 
private
ÓÓ 
static
ÓÓ 
string
ÓÓ 
?
ÓÓ &
ValidateTaxDocumentItems
ÓÓ 3
(
ÓÓ3 4
string
ÓÓ4 :
?
ÓÓ: ;
currency
ÓÓ< D
,
ÓÓD E
IReadOnlyList
ÓÓF S
<
ÓÓS T$
TaxDocumentItemRequest
ÓÓT j
>
ÓÓj k
items
ÓÓl q
)
ÓÓq r
{
ÔÔ 
if
 

(
 
string
 
.
  
IsNullOrWhiteSpace
 %
(
% &
currency
& .
)
. /
||
0 2
items
3 8
.
8 9
Count
9 >
==
? A
$num
B C
)
C D
return
E K
$str
L }
;
} ~
if
ÒÒ 

(
ÒÒ 
items
ÒÒ 
.
ÒÒ 
Any
ÒÒ 
(
ÒÒ 
x
ÒÒ 
=>
ÒÒ 
x
ÒÒ 
.
ÒÒ 
Amount
ÒÒ #
<=
ÒÒ$ &
$num
ÒÒ' (
)
ÒÒ( )
)
ÒÒ) *
return
ÒÒ+ 1
$str
ÒÒ2 b
;
ÒÒb c
if
ÚÚ 

(
ÚÚ 
items
ÚÚ 
.
ÚÚ 
Select
ÚÚ 
(
ÚÚ 
x
ÚÚ 
=>
ÚÚ 
x
ÚÚ 
.
ÚÚ  
ClientProductId
ÚÚ  /
)
ÚÚ/ 0
.
ÚÚ0 1
Distinct
ÚÚ1 9
(
ÚÚ9 :
)
ÚÚ: ;
.
ÚÚ; <
Count
ÚÚ< A
(
ÚÚA B
)
ÚÚB C
!=
ÚÚD F
items
ÚÚG L
.
ÚÚL M
Count
ÚÚM R
)
ÚÚR S
return
ÚÚT Z
$strÚÚ[ Ä
;ÚÚÄ Å
return
ÛÛ 
null
ÛÛ 
;
ÛÛ 
}
ÙÙ 
[
˜˜ 
HttpPost
˜˜ 
(
˜˜ 
$str
˜˜ /
)
˜˜/ 0
]
˜˜0 1
public
¯¯ 

async
¯¯ 
Task
¯¯ 
<
¯¯ 
ActionResult
¯¯ "
>
¯¯" # 
ReverseTaxDocument
¯¯$ 6
(
¯¯6 7
Guid
¯¯7 ;
id
¯¯< >
,
¯¯> ?'
ReverseTaxDocumentRequest
¯¯@ Y
request
¯¯Z a
,
¯¯a b
CancellationToken
¯¯c t
ct
¯¯u w
)
¯¯w x
{
˘˘ 
var
˙˙ 
reason
˙˙ 
=
˙˙ 
request
˙˙ 
.
˙˙ 
Reason
˙˙ #
?
˙˙# $
.
˙˙$ %
Trim
˙˙% )
(
˙˙) *
)
˙˙* +
;
˙˙+ ,
if
˚˚ 

(
˚˚ 
string
˚˚ 
.
˚˚ 
IsNullOrEmpty
˚˚  
(
˚˚  !
reason
˚˚! '
)
˚˚' (
)
˚˚( )
return
˚˚* 0

BadRequest
˚˚1 ;
(
˚˚; <
new
˚˚< ?
{
˚˚@ A
message
˚˚B I
=
˚˚J K
$str
˚˚L k
}
˚˚l m
)
˚˚m n
;
˚˚n o
if
¸¸ 

(
¸¸ 
reason
¸¸ 
.
¸¸ 
Length
¸¸ 
>
¸¸ 
$num
¸¸ 
)
¸¸  
return
¸¸! '

BadRequest
¸¸( 2
(
¸¸2 3
new
¸¸3 6
{
¸¸7 8
message
¸¸9 @
=
¸¸A B
$str
¸¸C p
}
¸¸q r
)
¸¸r s
;
¸¸s t
return
˝˝ 
await
˝˝ 
taxDocuments
˝˝ !
.
˝˝! "
ReverseAsync
˝˝" .
(
˝˝. /
id
˝˝/ 1
,
˝˝1 2
reason
˝˝3 9
,
˝˝9 :
request
˝˝; B
.
˝˝B C
	NotIssued
˝˝C L
,
˝˝L M
UserId
˝˝N T
,
˝˝T U
ct
˝˝V X
)
˝˝X Y
is
˝˝Z \'
TaxDocumentReversalResult
˝˝] v
result
˝˝w }
?
˝˝~ 
Ok˝˝Ä Ç
(˝˝Ç É
result˝˝É â
)˝˝â ä
:˝˝ã å
NotFound˝˝ç ï
(˝˝ï ñ
)˝˝ñ ó
;˝˝ó ò
}
˛˛ 
[
ÄÄ 
HttpGet
ÄÄ 
(
ÄÄ 
$str
ÄÄ 
)
ÄÄ 
]
ÄÄ 
public
ÅÅ 

async
ÅÅ 
Task
ÅÅ 
<
ÅÅ 
ActionResult
ÅÅ "
>
ÅÅ" #
Expenses
ÅÅ$ ,
(
ÅÅ, -
int
ÅÅ- 0
?
ÅÅ0 1
month
ÅÅ2 7
,
ÅÅ7 8
int
ÅÅ9 <
?
ÅÅ< =
year
ÅÅ> B
,
ÅÅB C
Guid
ÅÅD H
?
ÅÅH I

categoryId
ÅÅJ T
,
ÅÅT U
CancellationToken
ÅÅV g
ct
ÅÅh j
)
ÅÅj k
=>
ÅÅl n
Ok
ÅÅo q
(
ÅÅq r
await
ÅÅr w
db
ÅÅx z
.
ÅÅz {
ExpensesÅÅ{ É
.ÅÅÉ Ñ
IncludeÅÅÑ ã
(ÅÅã å
xÅÅå ç
=>ÅÅé ê
xÅÅë í
.ÅÅí ì
CategoryÅÅì õ
)ÅÅõ ú
.
ÇÇ 	
Where
ÇÇ	 
(
ÇÇ 
x
ÇÇ 
=>
ÇÇ 
(
ÇÇ 
month
ÇÇ 
==
ÇÇ 
null
ÇÇ "
||
ÇÇ# %
x
ÇÇ& '
.
ÇÇ' (
Date
ÇÇ( ,
.
ÇÇ, -
Month
ÇÇ- 2
==
ÇÇ3 5
month
ÇÇ6 ;
)
ÇÇ; <
&&
ÇÇ= ?
(
ÇÇ@ A
year
ÇÇA E
==
ÇÇF H
null
ÇÇI M
||
ÇÇN P
x
ÇÇQ R
.
ÇÇR S
Date
ÇÇS W
.
ÇÇW X
Year
ÇÇX \
==
ÇÇ] _
year
ÇÇ` d
)
ÇÇd e
&&
ÇÇf h
(
ÇÇi j

categoryId
ÇÇj t
==
ÇÇu w
null
ÇÇx |
||
ÇÇ} 
xÇÇÄ Å
.ÇÇÅ Ç

CategoryIdÇÇÇ å
==ÇÇç è

categoryIdÇÇê ö
)ÇÇö õ
)ÇÇõ ú
.
ÉÉ 	
OrderByDescending
ÉÉ	 
(
ÉÉ 
x
ÉÉ 
=>
ÉÉ 
x
ÉÉ  !
.
ÉÉ! "
Date
ÉÉ" &
)
ÉÉ& '
.
ÉÉ' (
Select
ÉÉ( .
(
ÉÉ. /
x
ÉÉ/ 0
=>
ÉÉ1 3

ExpenseDto
ÉÉ4 >
(
ÉÉ> ?
x
ÉÉ? @
)
ÉÉ@ A
)
ÉÉA B
.
ÉÉB C
ToListAsync
ÉÉC N
(
ÉÉN O
ct
ÉÉO Q
)
ÉÉQ R
)
ÉÉR S
;
ÉÉS T
[
ÖÖ 
HttpPost
ÖÖ 
(
ÖÖ 
$str
ÖÖ 
)
ÖÖ 
]
ÖÖ 
public
ÜÜ 

async
ÜÜ 
Task
ÜÜ 
<
ÜÜ 
ActionResult
ÜÜ "
>
ÜÜ" #
CreateExpense
ÜÜ$ 1
(
ÜÜ1 2
ExpenseRequest
ÜÜ2 @
request
ÜÜA H
,
ÜÜH I
CancellationToken
ÜÜJ [
ct
ÜÜ\ ^
)
ÜÜ^ _
{
áá 
if
àà 

(
àà 
string
àà 
.
àà  
IsNullOrWhiteSpace
àà %
(
àà% &
request
àà& -
.
àà- .
Description
àà. 9
)
àà9 :
||
àà; =
string
àà> D
.
ààD E 
IsNullOrWhiteSpace
ààE W
(
ààW X
request
ààX _
.
àà_ `
Currency
àà` h
)
ààh i
||
ààj l
request
ààm t
.
ààt u
Amount
ààu {
<=
àà| ~
$numàà Ä
)ààÄ Å
returnààÇ à

BadRequestààâ ì
(ààì î
newààî ó
{ààò ô
messageààö °
=àà¢ £
$stràà§ ‡
}àà· ‚
)àà‚ „
;àà„ ‰
if
ââ 

(
ââ 
!
ââ 
await
ââ 
db
ââ 
.
ââ 
ExpenseCategories
ââ '
.
ââ' (
AnyAsync
ââ( 0
(
ââ0 1
x
ââ1 2
=>
ââ3 5
x
ââ6 7
.
ââ7 8
Id
ââ8 :
==
ââ; =
request
ââ> E
.
ââE F

CategoryId
ââF P
,
ââP Q
ct
ââR T
)
ââT U
)
ââU V
return
ââW ]

BadRequest
ââ^ h
(
ââh i
new
ââi l
{
ââm n
message
ââo v
=
ââw x
$strâây ñ
}ââó ò
)ââò ô
;ââô ö
var
ää 
expense
ää 
=
ää 
new
ää 
Expense
ää !
{
ää" #
Description
ää$ /
=
ää0 1
request
ää2 9
.
ää9 :
Description
ää: E
.
ääE F
Trim
ääF J
(
ääJ K
)
ääK L
,
ääL M

CategoryId
ääN X
=
ääY Z
request
ää[ b
.
ääb c

CategoryId
ääc m
,
ääm n
Type
ääo s
=
äät u
request
ääv }
.
ää} ~
Typeää~ Ç
,ääÇ É
AmountääÑ ä
=ääã å
requestääç î
.ääî ï
Amountääï õ
,ääõ ú
Currencyääù •
=ää¶ ß
requestää® Ø
.ääØ ∞
Currencyää∞ ∏
.ää∏ π
Trimääπ Ω
(ääΩ æ
)ääæ ø
.ääø ¿ 
ToUpperInvariantää¿ –
(ää– —
)ää— “
,ää“ ”
Dateää‘ ÿ
=ääŸ ⁄
requestää€ ‚
.ää‚ „
Dateää„ Á
,ääÁ Ë
	RecurringääÈ Ú
=ääÛ Ù
requestääı ¸
.ää¸ ˝
	Recurringää˝ Ü
,ääÜ á
RecurrenceCycleääà ó
=ääò ô
requestääö °
.ää° ¢
RecurrenceCycleää¢ ±
,ää± ≤
IsNonDeductibleää≥ ¬
=ää√ ƒ
requestää≈ Ã
.ääÃ Õ
IsNonDeductibleääÕ ‹
}ää› ﬁ
;ääﬁ ﬂ!
ApplyForeignService
ãã 
(
ãã 
expense
ãã #
,
ãã# $
request
ãã% ,
.
ãã, -#
IsNonDomiciledService
ãã- B
,
ããB C
request
ããD K
.
ããK L!
ForeignSupplierName
ããL _
,
ãã_ `
request
ããa h
.
ããh i$
ForeignSupplierCountry
ããi 
)ãã Ä
;ããÄ Å
expense
åå 
.
åå 
	AmountPen
åå 
=
åå 
expense
åå #
.
åå# $
Amount
åå$ *
*
åå+ ,
await
åå- 2
db
åå3 5
.
åå5 6
RateToPenAsync
åå6 D
(
ååD E
expense
ååE L
.
ååL M
Currency
ååM U
,
ååU V
expense
ååW ^
.
åå^ _
Date
åå_ c
,
ååc d
ct
ååe g
)
ååg h
;
ååh i
db
çç 

.
çç
 
Expenses
çç 
.
çç 
Add
çç 
(
çç 
expense
çç 
)
çç  
;
çç  !
await
çç" '
db
çç( *
.
çç* +
SaveChangesAsync
çç+ ;
(
çç; <
ct
çç< >
)
çç> ?
;
çç? @
await
éé 
db
éé 
.
éé 
Entry
éé 
(
éé 
expense
éé 
)
éé 
.
éé  
	Reference
éé  )
(
éé) *
x
éé* +
=>
éé, .
x
éé/ 0
.
éé0 1
Category
éé1 9
)
éé9 :
.
éé: ;
	LoadAsync
éé; D
(
ééD E
ct
ééE G
)
ééG H
;
ééH I
return
èè 
Created
èè 
(
èè 
$"
èè 
$str
èè -
{
èè- .
expense
èè. 5
.
èè5 6
Id
èè6 8
}
èè8 9
"
èè9 :
,
èè: ;

ExpenseDto
èè< F
(
èèF G
expense
èèG N
)
èèN O
)
èèO P
;
èèP Q
}
êê 
[
íí 
HttpGet
íí 
(
íí 
$str
íí '
)
íí' (
]
íí( )
public
ìì 

async
ìì 
Task
ìì 
<
ìì 
IActionResult
ìì #
>
ìì# $
ExpenseTemplate
ìì% 4
(
ìì4 5
CancellationToken
ìì5 F
ct
ììG I
)
ììI J
=>
ììK M
File
ììN R
(
ììR S
CreateWorkbook
ììS a
(
ììa b
new
îî 
(
îî 
$str
îî 
,
îî 
true
îî 
,
îî  
$str
îî! @
)
îî@ A
,
îîA B
new
ïï 
(
ïï 
$str
ïï 
,
ïï 
true
ïï 
,
ïï 
$str
ïï V
,
ïïV W
[
ïïX Y
..
ïïY [
await
ïï\ a
db
ïïb d
.
ïïd e
ExpenseCategories
ïïe v
.
ïïv w
OrderBy
ïïw ~
(
ïï~ 
xïï Ä
=>ïïÅ É
xïïÑ Ö
.ïïÖ Ü
	SortOrderïïÜ è
)ïïè ê
.ïïê ë
ThenByïïë ó
(ïïó ò
xïïò ô
=>ïïö ú
xïïù û
.ïïû ü
Nameïïü £
)ïï£ §
.ïï§ •
Selectïï• ´
(ïï´ ¨
xïï¨ ≠
=>ïïÆ ∞
xïï± ≤
.ïï≤ ≥
Nameïï≥ ∑
)ïï∑ ∏
.ïï∏ π
ToListAsyncïïπ ƒ
(ïïƒ ≈
ctïï≈ «
)ïï« »
]ïï» …
)ïï…  
,ïï  À
new
ññ 
(
ññ 
$str
ññ 
,
ññ 
true
ññ 
,
ññ 
$str
ññ +
,
ññ+ ,
Enum
ññ- 1
.
ññ1 2
GetNames
ññ2 :
<
ññ: ;
ExpenseType
ññ; F
>
ññF G
(
ññG H
)
ññH I
)
ññI J
,
ññJ K
new
óó 
(
óó 
$str
óó 
,
óó 
true
óó 
,
óó 
$str
óó K
)
óóK L
,
óóL M
new
òò 
(
òò 
$str
òò 
,
òò 
true
òò 
,
òò 
$str
òò .
,
òò. /
[
òò0 1
$str
òò1 6
,
òò6 7
$str
òò8 =
,
òò= >
$str
òò? D
]
òòD E
)
òòE F
,
òòF G
new
ôô 
(
ôô 
$str
ôô 
,
ôô 
true
ôô 
,
ôô 
$str
ôô K
)
ôôK L
,
ôôL M
new
öö 
(
öö 
$str
öö 
,
öö 
false
öö 
,
öö 
$str
öö  6
,
öö6 7
[
öö8 9
$str
öö9 =
,
öö= >
$str
öö? C
]
ööC D
)
ööD E
,
ööE F
new
õõ 
(
õõ 
$str
õõ 
,
õõ 
false
õõ $
,
õõ$ %
$str
õõ& X
,
õõX Y
[
õõZ [
$str
õõ[ d
,
õõd e
$str
õõf m
]
õõm n
)
õõn o
)
õõo p
,
õõp q
$str
úú K
,
úúK L
$str
úúM d
)
úúd e
;
úúe f
[
üü 
HttpPost
üü 
(
üü 
$str
üü 
)
üü  
]
üü  !
public
†† 

async
†† 
Task
†† 
<
†† 
ActionResult
†† "
>
††" #
ImportExpenses
††$ 2
(
††2 3
	IFormFile
††3 <
file
††= A
,
††A B
CancellationToken
††C T
ct
††U W
)
††W X
{
°° 
var
¢¢ 

categories
¢¢ 
=
¢¢ 
await
¢¢ 
db
¢¢ !
.
¢¢! "
ExpenseCategories
¢¢" 3
.
¢¢3 4
ToListAsync
¢¢4 ?
(
¢¢? @
ct
¢¢@ B
)
¢¢B C
;
¢¢C D
var
££ 
(
££ 
failure
££ 
,
££ 
created
££ 
,
££ 
errors
££ %
)
££% &
=
££' (
await
££) .
Import
££/ 5
(
££5 6
file
££6 :
,
££: ;
$str
££< D
,
££D E
async
££F K
(
££L M
row
££M P
,
££P Q
	rowNumber
££R [
,
££[ \
errors
££] c
)
££c d
=>
££e g
{
§§ 	
var
•• 
error
•• 
=
•• 
ParseExpenseRow
•• '
(
••' (
row
••( +
,
••+ ,

categories
••- 7
,
••7 8
out
••9 <
var
••= @
expense
••A H
)
••H I
;
••I J
if
¶¶ 
(
¶¶ 
error
¶¶ 
is
¶¶ 
not
¶¶ 
null
¶¶ !
)
¶¶! "
{
¶¶# $
errors
¶¶% +
.
¶¶+ ,
Add
¶¶, /
(
¶¶/ 0
new
¶¶0 3
(
¶¶3 4
	rowNumber
¶¶4 =
,
¶¶= >
error
¶¶? D
)
¶¶D E
)
¶¶E F
;
¶¶F G
return
¶¶H N
false
¶¶O T
;
¶¶T U
}
¶¶V W
expense
ßß 
!
ßß 
.
ßß 
	AmountPen
ßß 
=
ßß  
expense
ßß! (
.
ßß( )
Amount
ßß) /
*
ßß0 1
await
ßß2 7
db
ßß8 :
.
ßß: ;
RateToPenAsync
ßß; I
(
ßßI J
expense
ßßJ Q
.
ßßQ R
Currency
ßßR Z
,
ßßZ [
expense
ßß\ c
.
ßßc d
Date
ßßd h
,
ßßh i
ct
ßßj l
)
ßßl m
;
ßßm n
db
®® 
.
®® 
Expenses
®® 
.
®® 
Add
®® 
(
®® 
expense
®® #
)
®®# $
;
®®$ %
return
®®& ,
true
®®- 1
;
®®1 2
}
©© 	
,
©©	 

ct
©© 
)
©© 
;
©© 
return
™™ 
failure
™™ 
??
™™ 
Ok
™™ 
(
™™ 
new
™™  
{
™™! "
created
™™# *
,
™™* +
skipped
™™, 3
=
™™4 5
errors
™™6 <
.
™™< =
Count
™™= B
,
™™B C
errors
™™D J
}
™™K L
)
™™L M
;
™™M N
}
´´ 
private
≠≠ 
static
≠≠ 
string
≠≠ 
?
≠≠ 
ParseProductRow
≠≠ *
(
≠≠* +
IXLRow
≠≠+ 1
row
≠≠2 5
,
≠≠5 6
out
≠≠7 :
Product
≠≠; B
?
≠≠B C
product
≠≠D K
)
≠≠K L
{
ÆÆ 
product
ØØ 
=
ØØ 
null
ØØ 
;
ØØ 
if
∞∞ 

(
∞∞ 
!
∞∞ 
TryEnum
∞∞ 
<
∞∞ 
ProductType
∞∞  
>
∞∞  !
(
∞∞! "
Cell
∞∞" &
(
∞∞& '
row
∞∞' *
,
∞∞* +
$num
∞∞, -
)
∞∞- .
,
∞∞. /
out
∞∞0 3
var
∞∞4 7
type
∞∞8 <
)
∞∞< =
)
∞∞= >
return
∞∞? E
$"
∞∞F H
$str
∞∞H [
{
∞∞[ \
string
∞∞\ b
.
∞∞b c
Join
∞∞c g
(
∞∞g h
$str
∞∞h l
,
∞∞l m
Enum
∞∞n r
.
∞∞r s
GetNames
∞∞s {
<
∞∞{ |
ProductType∞∞| á
>∞∞á à
(∞∞à â
)∞∞â ä
)∞∞ä ã
}∞∞ã å
$str∞∞å ç
"∞∞ç é
;∞∞é è
var
±± 
name
±± 
=
±± 
Cell
±± 
(
±± 
row
±± 
,
±± 
$num
±± 
)
±± 
.
±±  
Trim
±±  $
(
±±$ %
)
±±% &
;
±±& '
if
≤≤ 

(
≤≤ 
string
≤≤ 
.
≤≤  
IsNullOrWhiteSpace
≤≤ %
(
≤≤% &
name
≤≤& *
)
≤≤* +
)
≤≤+ ,
return
≤≤- 3
$str
≤≤4 O
;
≤≤O P
if
≥≥ 

(
≥≥ 
!
≥≥ 
TryEnum
≥≥ 
<
≥≥ 
BillingCycle
≥≥ !
>
≥≥! "
(
≥≥" #
Cell
≥≥# '
(
≥≥' (
row
≥≥( +
,
≥≥+ ,
$num
≥≥- .
)
≥≥. /
,
≥≥/ 0
out
≥≥1 4
var
≥≥5 8
cycle
≥≥9 >
)
≥≥> ?
)
≥≥? @
return
≥≥A G
$str≥≥H û
;≥≥û ü
if
¥¥ 

(
¥¥ 
ReadDecimal
¥¥ 
(
¥¥ 
row
¥¥ 
.
¥¥ 
Cell
¥¥  
(
¥¥  !
$num
¥¥! "
)
¥¥" #
)
¥¥# $
is
¥¥% '
not
¥¥( +
decimal
¥¥, 3
price
¥¥4 9
||
¥¥: <
price
¥¥= B
<
¥¥C D
$num
¥¥E F
)
¥¥F G
return
¥¥H N
$str¥¥O Ä
;¥¥Ä Å
var
µµ 
currency
µµ 
=
µµ 
Cell
µµ 
(
µµ 
row
µµ 
,
µµ  
$num
µµ! "
)
µµ" #
.
µµ# $
Trim
µµ$ (
(
µµ( )
)
µµ) *
.
µµ* +
ToUpperInvariant
µµ+ ;
(
µµ; <
)
µµ< =
;
µµ= >
if
∂∂ 

(
∂∂ 
currency
∂∂ 
is
∂∂ 
not
∂∂ 
(
∂∂ 
$str
∂∂ "
or
∂∂# %
$str
∂∂& +
or
∂∂, .
$str
∂∂/ 4
)
∂∂4 5
)
∂∂5 6
return
∂∂7 =
$str
∂∂> d
;
∂∂d e
if
∑∑ 

(
∑∑ 
	ReadYesNo
∑∑ 
(
∑∑ 
Cell
∑∑ 
(
∑∑ 
row
∑∑ 
,
∑∑ 
$num
∑∑  !
)
∑∑! "
,
∑∑" #
defaultValue
∑∑$ 0
:
∑∑0 1
true
∑∑2 6
)
∑∑6 7
is
∑∑8 :
not
∑∑; >
bool
∑∑? C
active
∑∑D J
)
∑∑J K
return
∑∑L R
$str
∑∑S t
;
∑∑t u
var
∏∏ 
taxText
∏∏ 
=
∏∏ 
Cell
∏∏ 
(
∏∏ 
row
∏∏ 
,
∏∏ 
$num
∏∏  !
)
∏∏! "
.
∏∏" #
Trim
∏∏# '
(
∏∏' (
)
∏∏( )
;
∏∏) *
var
∏∏+ .
taxType
∏∏/ 6
=
∏∏7 8
TaxDocumentType
∏∏9 H
.
∏∏H I
Factura
∏∏I P
;
∏∏P Q
if
ππ 

(
ππ 
taxText
ππ 
!=
ππ 
$str
ππ 
&&
ππ 
!
ππ 
TryEnum
ππ %
(
ππ% &
taxText
ππ& -
,
ππ- .
out
ππ/ 2
taxType
ππ3 :
)
ππ: ;
)
ππ; <
return
ππ= C
$strππD Ç
;ππÇ É
if
∫∫ 

(
∫∫ 
	ReadYesNo
∫∫ 
(
∫∫ 
Cell
∫∫ 
(
∫∫ 
row
∫∫ 
,
∫∫ 
$num
∫∫  "
)
∫∫" #
,
∫∫# $
defaultValue
∫∫% 1
:
∫∫1 2
false
∫∫3 8
)
∫∫8 9
is
∫∫: <
not
∫∫= @
bool
∫∫A E
allowsTickets
∫∫F S
)
∫∫S T
return
∫∫U [
$str∫∫\ Ç
;∫∫Ç É
product
ªª 
=
ªª 
new
ªª 
Product
ªª 
{
ªª 
Type
ªª  $
=
ªª% &
type
ªª' +
,
ªª+ ,
Name
ªª- 1
=
ªª2 3
name
ªª4 8
,
ªª8 9
BillingCycle
ªª: F
=
ªªG H
cycle
ªªI N
,
ªªN O
	BasePrice
ªªP Y
=
ªªZ [
price
ªª\ a
,
ªªa b
Currency
ªªc k
=
ªªl m
currency
ªªn v
,
ªªv w
Descriptionªªx É
=ªªÑ Ö
EmptyToNullªªÜ ë
(ªªë í
Cellªªí ñ
(ªªñ ó
rowªªó ö
,ªªö õ
$numªªú ù
)ªªù û
)ªªû ü
,ªªü †
IsActiveªª° ©
=ªª™ ´
activeªª¨ ≤
,ªª≤ ≥
TaxDocumentTypeªª¥ √
=ªªƒ ≈
taxTypeªª∆ Õ
,ªªÕ Œ
Categoryªªœ ◊
=ªªÿ Ÿ
EmptyToNullªª⁄ Â
(ªªÂ Ê
CellªªÊ Í
(ªªÍ Î
rowªªÎ Ó
,ªªÓ Ô
$numªª Ò
)ªªÒ Ú
)ªªÚ Û
,ªªÛ Ù
Tagsªªı ˘
=ªª˙ ˚
NormalizeTagsªª¸ â
(ªªâ ä
Cellªªä é
(ªªé è
rowªªè í
,ªªí ì
$numªªî ñ
)ªªñ ó
)ªªó ò
,ªªò ô
AllowsTicketsªªö ß
=ªª® ©
allowsTicketsªª™ ∑
}ªª∏ π
;ªªπ ∫
return
ºº 
null
ºº 
;
ºº 
}
ΩΩ 
private
¿¿ 
static
¿¿ 
bool
¿¿ 
TryEnum
¿¿ 
<
¿¿  
T
¿¿  !
>
¿¿! "
(
¿¿" #
string
¿¿# )
value
¿¿* /
,
¿¿/ 0
out
¿¿1 4
T
¿¿5 6
result
¿¿7 =
)
¿¿= >
where
¿¿? D
T
¿¿E F
:
¿¿G H
struct
¿¿I O
,
¿¿O P
Enum
¿¿Q U
=>
¿¿V X
Enum
¿¿Y ]
.
¿¿] ^
TryParse
¿¿^ f
(
¿¿f g
value
¿¿g l
.
¿¿l m
Trim
¿¿m q
(
¿¿q r
)
¿¿r s
,
¿¿s t
true
¿¿u y
,
¿¿y z
out
¿¿{ ~
result¿¿ Ö
)¿¿Ö Ü
&&¿¿á â
Enum¿¿ä é
.¿¿é è
	IsDefined¿¿è ò
(¿¿ò ô
result¿¿ô ü
)¿¿ü †
&&¿¿° £
!¿¿§ •
int¿¿• ®
.¿¿® ©
TryParse¿¿© ±
(¿¿± ≤
value¿¿≤ ∑
.¿¿∑ ∏
Trim¿¿∏ º
(¿¿º Ω
)¿¿Ω æ
,¿¿æ ø
out¿¿¿ √
_¿¿ƒ ≈
)¿¿≈ ∆
;¿¿∆ «
private
√√ 
static
√√ 
bool
√√ 
?
√√ 
	ReadYesNo
√√ "
(
√√" #
string
√√# )
value
√√* /
,
√√/ 0
bool
√√1 5
defaultValue
√√6 B
)
√√B C
=>
√√D F
value
√√G L
.
√√L M
Trim
√√M Q
(
√√Q R
)
√√R S
.
√√S T
ToUpperInvariant
√√T d
(
√√d e
)
√√e f
switch
√√g m
{
ƒƒ 
$str
≈≈ 

=>
≈≈ 
defaultValue
≈≈ 
,
≈≈ 
$str
∆∆ 
or
∆∆ 
$str
∆∆ 
or
∆∆ 
$str
∆∆ 
or
∆∆ !
$str
∆∆" -
or
∆∆. 0
$str
∆∆1 4
=>
∆∆5 7
true
∆∆8 <
,
∆∆< =
$str
«« 
or
«« 
$str
«« 
or
«« 
$str
«« "
or
««# %
$str
««& )
=>
««* ,
false
««- 2
,
««2 3
_
»» 	
=>
»»
 
null
»» 
,
»» 
}
…… 
;
…… 
private
ÀÀ 
static
ÀÀ 
string
ÀÀ 
?
ÀÀ 
ParseExpenseRow
ÀÀ *
(
ÀÀ* +
IXLRow
ÀÀ+ 1
row
ÀÀ2 5
,
ÀÀ5 6
IReadOnlyList
ÀÀ7 D
<
ÀÀD E
ExpenseCategory
ÀÀE T
>
ÀÀT U

categories
ÀÀV `
,
ÀÀ` a
out
ÀÀb e
Expense
ÀÀf m
?
ÀÀm n
expense
ÀÀo v
)
ÀÀv w
{
ÃÃ 
expense
ÕÕ 
=
ÕÕ 
null
ÕÕ 
;
ÕÕ 
var
ŒŒ 
description
ŒŒ 
=
ŒŒ 
Cell
ŒŒ 
(
ŒŒ 
row
ŒŒ "
,
ŒŒ" #
$num
ŒŒ$ %
)
ŒŒ% &
.
ŒŒ& '
Trim
ŒŒ' +
(
ŒŒ+ ,
)
ŒŒ, -
;
ŒŒ- .
if
œœ 

(
œœ 
string
œœ 
.
œœ  
IsNullOrWhiteSpace
œœ %
(
œœ% &
description
œœ& 1
)
œœ1 2
)
œœ2 3
return
œœ4 :
$str
œœ; [
;
œœ[ \
var
—— 
categoryText
—— 
=
—— 
Fold
—— 
(
——  
Cell
——  $
(
——$ %
row
——% (
,
——( )
$num
——* +
)
——+ ,
)
——, -
;
——- .
if
““ 

(
““ 

categories
““ 
.
““ 
FirstOrDefault
““ %
(
““% &
x
““& '
=>
““( *
Fold
““+ /
(
““/ 0
x
““0 1
.
““1 2
Name
““2 6
)
““6 7
==
““8 :
categoryText
““; G
||
““H J
x
““K L
.
““L M
Code
““M Q
is
““R T
not
““U X
null
““Y ]
&&
““^ `
Fold
““a e
(
““e f
x
““f g
.
““g h
Code
““h l
)
““l m
==
““n p
categoryText
““q }
)
““} ~
is““ Å
not““Ç Ö
{““Ü á
}““à â
category““ä í
)““í ì
return““î ö
$"““õ ù
$str““ù µ
{““µ ∂
string““∂ º
.““º Ω
Join““Ω ¡
(““¡ ¬
$str““¬ ∆
,““∆ «

categories““» “
.“““ ”
OrderBy““” ⁄
(““⁄ €
x““€ ‹
=>““› ﬂ
x““‡ ·
.““· ‚
	SortOrder““‚ Î
)““Î Ï
.““Ï Ì
Select““Ì Û
(““Û Ù
x““Ù ı
=>““ˆ ¯
x““˘ ˙
.““˙ ˚
Name““˚ ˇ
)““ˇ Ä
)““Ä Å
}““Å Ç
$str““Ç É
"““É Ñ
;““Ñ Ö
if
”” 

(
”” 
!
”” 
TryEnum
”” 
<
”” 
ExpenseType
””  
>
””  !
(
””! "
Cell
””" &
(
””& '
row
””' *
,
””* +
$num
””, -
)
””- .
,
””. /
out
””0 3
var
””4 7
type
””8 <
)
””< =
)
””= >
return
””? E
$str
””F k
;
””k l
if
‘‘ 

(
‘‘ 
ReadDecimal
‘‘ 
(
‘‘ 
row
‘‘ 
.
‘‘ 
Cell
‘‘  
(
‘‘  !
$num
‘‘! "
)
‘‘" #
)
‘‘# $
is
‘‘% '
not
‘‘( +
decimal
‘‘, 3
amount
‘‘4 :
||
‘‘; =
amount
‘‘> D
<=
‘‘E G
$num
‘‘H I
)
‘‘I J
return
‘‘K Q
$str
‘‘R z
;
‘‘z {
var
’’ 
currency
’’ 
=
’’ 
Cell
’’ 
(
’’ 
row
’’ 
,
’’  
$num
’’! "
)
’’" #
.
’’# $
Trim
’’$ (
(
’’( )
)
’’) *
.
’’* +
ToUpperInvariant
’’+ ;
(
’’; <
)
’’< =
;
’’= >
if
÷÷ 

(
÷÷ 
currency
÷÷ 
is
÷÷ 
not
÷÷ 
(
÷÷ 
$str
÷÷ "
or
÷÷# %
$str
÷÷& +
or
÷÷, .
$str
÷÷/ 4
)
÷÷4 5
)
÷÷5 6
return
÷÷7 =
$str
÷÷> d
;
÷÷d e
if
◊◊ 

(
◊◊ 
ReadDate
◊◊ 
(
◊◊ 
row
◊◊ 
.
◊◊ 
Cell
◊◊ 
(
◊◊ 
$num
◊◊ 
)
◊◊  
)
◊◊  !
is
◊◊" $
not
◊◊% (
DateOnly
◊◊) 1
date
◊◊2 6
)
◊◊6 7
return
◊◊8 >
$str
◊◊? m
;
◊◊m n
if
ÿÿ 

(
ÿÿ 
	ReadYesNo
ÿÿ 
(
ÿÿ 
Cell
ÿÿ 
(
ÿÿ 
row
ÿÿ 
,
ÿÿ 
$num
ÿÿ  !
)
ÿÿ! "
,
ÿÿ" #
defaultValue
ÿÿ$ 0
:
ÿÿ0 1
false
ÿÿ2 7
)
ÿÿ7 8
is
ÿÿ9 ;
not
ÿÿ< ?
bool
ÿÿ@ D
	recurring
ÿÿE N
)
ÿÿN O
return
ÿÿP V
$str
ÿÿW y
;
ÿÿy z
if
ŸŸ 

(
ŸŸ 
!
ŸŸ  
TryRecurrenceCycle
ŸŸ 
(
ŸŸ  
Cell
ŸŸ  $
(
ŸŸ$ %
row
ŸŸ% (
,
ŸŸ( )
$num
ŸŸ* +
)
ŸŸ+ ,
,
ŸŸ, -
	recurring
ŸŸ. 7
,
ŸŸ7 8
out
ŸŸ9 <
var
ŸŸ= @
cycle
ŸŸA F
)
ŸŸF G
)
ŸŸG H
return
ŸŸI O
$strŸŸP ê
;ŸŸê ë
expense
⁄⁄ 
=
⁄⁄ 
new
⁄⁄ 
Expense
⁄⁄ 
{
⁄⁄ 
Description
⁄⁄  +
=
⁄⁄, -
description
⁄⁄. 9
,
⁄⁄9 :

CategoryId
⁄⁄; E
=
⁄⁄F G
category
⁄⁄H P
.
⁄⁄P Q
Id
⁄⁄Q S
,
⁄⁄S T
Type
⁄⁄U Y
=
⁄⁄Z [
type
⁄⁄\ `
,
⁄⁄` a
Amount
⁄⁄b h
=
⁄⁄i j
amount
⁄⁄k q
,
⁄⁄q r
Currency
⁄⁄s {
=
⁄⁄| }
currency⁄⁄~ Ü
,⁄⁄Ü á
Date⁄⁄à å
=⁄⁄ç é
date⁄⁄è ì
,⁄⁄ì î
	Recurring⁄⁄ï û
=⁄⁄ü †
	recurring⁄⁄° ™
,⁄⁄™ ´
RecurrenceCycle⁄⁄¨ ª
=⁄⁄º Ω
cycle⁄⁄æ √
}⁄⁄ƒ ≈
;⁄⁄≈ ∆
return
€€ 
null
€€ 
;
€€ 
}
‹‹ 
private
ﬂﬂ 
static
ﬂﬂ 
bool
ﬂﬂ  
TryRecurrenceCycle
ﬂﬂ *
(
ﬂﬂ* +
string
ﬂﬂ+ 1
value
ﬂﬂ2 7
,
ﬂﬂ7 8
bool
ﬂﬂ9 =
	recurring
ﬂﬂ> G
,
ﬂﬂG H
out
ﬂﬂI L
BillingCycle
ﬂﬂM Y
?
ﬂﬂY Z
cycle
ﬂﬂ[ `
)
ﬂﬂ` a
{
‡‡ 
cycle
·· 
=
·· 
null
·· 
;
·· 
if
‚‚ 

(
‚‚ 
!
‚‚ 
	recurring
‚‚ 
)
‚‚ 
return
‚‚ 
true
‚‚ #
;
‚‚# $
if
„„ 

(
„„ 
!
„„ 
TryEnum
„„ 
<
„„ 
BillingCycle
„„ !
>
„„! "
(
„„" #
value
„„# (
,
„„( )
out
„„* -
var
„„. 1
parsed
„„2 8
)
„„8 9
||
„„: <
parsed
„„= C
is
„„D F
not
„„G J
(
„„K L
BillingCycle
„„L X
.
„„X Y
Mensual
„„Y `
or
„„a c
BillingCycle
„„d p
.
„„p q
Anual
„„q v
)
„„v w
)
„„w x
return
„„y 
false„„Ä Ö
;„„Ö Ü
cycle
‰‰ 
=
‰‰ 
parsed
‰‰ 
;
‰‰ 
return
ÂÂ 
true
ÂÂ 
;
ÂÂ 
}
ÊÊ 
private
ÈÈ 
static
ÈÈ 
decimal
ÈÈ 
?
ÈÈ 
ReadDecimal
ÈÈ '
(
ÈÈ' (
IXLCell
ÈÈ( /
cell
ÈÈ0 4
)
ÈÈ4 5
{
ÍÍ 
if
ÎÎ 

(
ÎÎ 
cell
ÎÎ 
.
ÎÎ 
DataType
ÎÎ 
==
ÎÎ 

XLDataType
ÎÎ '
.
ÎÎ' (
Number
ÎÎ( .
)
ÎÎ. /
return
ÎÎ0 6
(
ÎÎ7 8
decimal
ÎÎ8 ?
)
ÎÎ? @
cell
ÎÎ@ D
.
ÎÎD E
	GetDouble
ÎÎE N
(
ÎÎN O
)
ÎÎO P
;
ÎÎP Q
return
ÏÏ 
decimal
ÏÏ 
.
ÏÏ 
TryParse
ÏÏ 
(
ÏÏ  
cell
ÏÏ  $
.
ÏÏ$ %
	GetString
ÏÏ% .
(
ÏÏ. /
)
ÏÏ/ 0
.
ÏÏ0 1
Trim
ÏÏ1 5
(
ÏÏ5 6
)
ÏÏ6 7
,
ÏÏ7 8
System
ÏÏ9 ?
.
ÏÏ? @
Globalization
ÏÏ@ M
.
ÏÏM N
NumberStyles
ÏÏN Z
.
ÏÏZ [
Number
ÏÏ[ a
,
ÏÏa b
System
ÏÏc i
.
ÏÏi j
Globalization
ÏÏj w
.
ÏÏw x
CultureInfoÏÏx É
.ÏÏÉ Ñ 
InvariantCultureÏÏÑ î
,ÏÏî ï
outÏÏñ ô
varÏÏö ù
valueÏÏû £
)ÏÏ£ §
?ÏÏ• ¶
valueÏÏß ¨
:ÏÏ≠ Æ
nullÏÏØ ≥
;ÏÏ≥ ¥
}
ÌÌ 
private
ÔÔ 
static
ÔÔ 
DateOnly
ÔÔ 
?
ÔÔ 
ReadDate
ÔÔ %
(
ÔÔ% &
IXLCell
ÔÔ& -
cell
ÔÔ. 2
)
ÔÔ2 3
{
 
if
ÒÒ 

(
ÒÒ 
cell
ÒÒ 
.
ÒÒ 
DataType
ÒÒ 
==
ÒÒ 

XLDataType
ÒÒ '
.
ÒÒ' (
DateTime
ÒÒ( 0
)
ÒÒ0 1
return
ÒÒ2 8
DateOnly
ÒÒ9 A
.
ÒÒA B
FromDateTime
ÒÒB N
(
ÒÒN O
cell
ÒÒO S
.
ÒÒS T
GetDateTime
ÒÒT _
(
ÒÒ_ `
)
ÒÒ` a
)
ÒÒa b
;
ÒÒb c
return
ÚÚ 
DateOnly
ÚÚ 
.
ÚÚ 
TryParseExact
ÚÚ %
(
ÚÚ% &
cell
ÚÚ& *
.
ÚÚ* +
	GetString
ÚÚ+ 4
(
ÚÚ4 5
)
ÚÚ5 6
.
ÚÚ6 7
Trim
ÚÚ7 ;
(
ÚÚ; <
)
ÚÚ< =
,
ÚÚ= >
[
ÚÚ? @
$str
ÚÚ@ L
,
ÚÚL M
$str
ÚÚN Z
,
ÚÚZ [
$str
ÚÚ\ f
]
ÚÚf g
,
ÚÚg h
System
ÚÚi o
.
ÚÚo p
Globalization
ÚÚp }
.
ÚÚ} ~
CultureInfoÚÚ~ â
.ÚÚâ ä 
InvariantCultureÚÚä ö
,ÚÚö õ
SystemÚÚú ¢
.ÚÚ¢ £
GlobalizationÚÚ£ ∞
.ÚÚ∞ ±
DateTimeStylesÚÚ± ø
.ÚÚø ¿
NoneÚÚ¿ ƒ
,ÚÚƒ ≈
outÚÚ∆ …
varÚÚ  Õ
dateÚÚŒ “
)ÚÚ“ ”
?ÚÚ‘ ’
dateÚÚ÷ ⁄
:ÚÚ€ ‹
nullÚÚ› ·
;ÚÚ· ‚
}
ÛÛ 
[
ıı 

HttpDelete
ıı 
(
ıı 
$str
ıı $
)
ıı$ %
]
ıı% &
public
ˆˆ 

async
ˆˆ 
Task
ˆˆ 
<
ˆˆ 
ActionResult
ˆˆ "
>
ˆˆ" #
DeleteExpense
ˆˆ$ 1
(
ˆˆ1 2
Guid
ˆˆ2 6
id
ˆˆ7 9
,
ˆˆ9 :
CancellationToken
ˆˆ; L
ct
ˆˆM O
)
ˆˆO P
{
˜˜ 
var
¯¯ 
expense
¯¯ 
=
¯¯ 
await
¯¯ 
db
¯¯ 
.
¯¯ 
Expenses
¯¯ '
.
¯¯' (
	FindAsync
¯¯( 1
(
¯¯1 2
[
¯¯2 3
id
¯¯3 5
]
¯¯5 6
,
¯¯6 7
ct
¯¯8 :
)
¯¯: ;
;
¯¯; <
if
¯¯= ?
(
¯¯@ A
expense
¯¯A H
is
¯¯I K
null
¯¯L P
)
¯¯P Q
return
¯¯R X
NotFound
¯¯Y a
(
¯¯a b
)
¯¯b c
;
¯¯c d
db
˘˘ 

.
˘˘
 
Expenses
˘˘ 
.
˘˘ 
Remove
˘˘ 
(
˘˘ 
expense
˘˘ "
)
˘˘" #
;
˘˘# $
await
˘˘% *
db
˘˘+ -
.
˘˘- .
SaveChangesAsync
˘˘. >
(
˘˘> ?
ct
˘˘? A
)
˘˘A B
;
˘˘B C
return
˘˘D J
	NoContent
˘˘K T
(
˘˘T U
)
˘˘U V
;
˘˘V W
}
˙˙ 
[
ÅÅ 
HttpPost
ÅÅ 
(
ÅÅ 
$str
ÅÅ 1
)
ÅÅ1 2
]
ÅÅ2 3
public
ÇÇ 

async
ÇÇ 
Task
ÇÇ 
<
ÇÇ 
ActionResult
ÇÇ "
>
ÇÇ" #
EndRecurrence
ÇÇ$ 1
(
ÇÇ1 2
Guid
ÇÇ2 6
id
ÇÇ7 9
,
ÇÇ9 :"
EndRecurrenceRequest
ÇÇ; O
request
ÇÇP W
,
ÇÇW X
bool
ÇÇY ]
dryRun
ÇÇ^ d
,
ÇÇd e
CancellationToken
ÇÇf w
ct
ÇÇx z
)
ÇÇz {
{
ÉÉ 
var
ÑÑ 
expense
ÑÑ 
=
ÑÑ 
await
ÑÑ 
db
ÑÑ 
.
ÑÑ 
Expenses
ÑÑ '
.
ÑÑ' (
	FindAsync
ÑÑ( 1
(
ÑÑ1 2
[
ÑÑ2 3
id
ÑÑ3 5
]
ÑÑ5 6
,
ÑÑ6 7
ct
ÑÑ8 :
)
ÑÑ: ;
;
ÑÑ; <
if
ÑÑ= ?
(
ÑÑ@ A
expense
ÑÑA H
is
ÑÑI K
null
ÑÑL P
)
ÑÑP Q
return
ÑÑR X
NotFound
ÑÑY a
(
ÑÑa b
)
ÑÑb c
;
ÑÑc d
if
ÖÖ 

(
ÖÖ 
!
ÖÖ 
expense
ÖÖ 
.
ÖÖ 
	Recurring
ÖÖ 
)
ÖÖ 
return
ÖÖ  &

BadRequest
ÖÖ' 1
(
ÖÖ1 2
new
ÖÖ2 5
{
ÖÖ6 7
message
ÖÖ8 ?
=
ÖÖ@ A
$str
ÖÖB ^
}
ÖÖ_ `
)
ÖÖ` a
;
ÖÖa b
var
ÜÜ 
series
ÜÜ 
=
ÜÜ 
await
ÜÜ 
ExpenseSeries
ÜÜ (
(
ÜÜ( )
expense
ÜÜ) 0
)
ÜÜ0 1
.
ÜÜ1 2
ToListAsync
ÜÜ2 =
(
ÜÜ= >
ct
ÜÜ> @
)
ÜÜ@ A
;
ÜÜA B
var
áá 
removed
áá 
=
áá 
series
áá 
.
áá 
Where
áá "
(
áá" #
x
áá# $
=>
áá% '
x
áá( )
.
áá) *
Date
áá* .
>
áá/ 0
request
áá1 8
.
áá8 9
EndsAt
áá9 ?
)
áá? @
.
áá@ A
ToList
ááA G
(
ááG H
)
ááH I
;
ááI J
if
àà 

(
àà 
!
àà 
dryRun
àà 
)
àà 
{
ââ 	
db
ää 
.
ää 
Expenses
ää 
.
ää 
RemoveRange
ää #
(
ää# $
removed
ää$ +
)
ää+ ,
;
ää, -
foreach
ãã 
(
ãã 
var
ãã 
kept
ãã 
in
ãã  
series
ãã! '
.
ãã' (
Except
ãã( .
(
ãã. /
removed
ãã/ 6
)
ãã6 7
)
ãã7 8
kept
ãã9 =
.
ãã= >
RecurrenceEndsAt
ãã> N
=
ããO P
request
ããQ X
.
ããX Y
EndsAt
ããY _
;
ãã_ `
await
åå 
db
åå 
.
åå 
SaveChangesAsync
åå %
(
åå% &
ct
åå& (
)
åå( )
;
åå) *
}
çç 	
return
éé 
Ok
éé 
(
éé 
new
éé 
{
éé 
removed
éé 
=
éé  !
removed
éé" )
.
éé) *
Count
éé* /
,
éé/ 0
kept
éé1 5
=
éé6 7
series
éé8 >
.
éé> ?
Count
éé? D
-
ééE F
removed
ééG N
.
ééN O
Count
ééO T
,
ééT U
removedTotalPen
ééV e
=
ééf g
Math
ééh l
.
éél m
Round
éém r
(
éér s
removed
éés z
.
ééz {
Sum
éé{ ~
(
éé~ 
xéé Ä
=>ééÅ É
xééÑ Ö
.ééÖ Ü
	AmountPenééÜ è
)ééè ê
,ééê ë
$numééí ì
)ééì î
}ééï ñ
)ééñ ó
;ééó ò
}
èè 
[
íí 

HttpDelete
íí 
(
íí 
$str
íí 3
)
íí3 4
]
íí4 5
public
ìì 

async
ìì 
Task
ìì 
<
ìì 
ActionResult
ìì "
>
ìì" #
ResumeRecurrence
ìì$ 4
(
ìì4 5
Guid
ìì5 9
id
ìì: <
,
ìì< =
CancellationToken
ìì> O
ct
ììP R
)
ììR S
{
îî 
var
ïï 
expense
ïï 
=
ïï 
await
ïï 
db
ïï 
.
ïï 
Expenses
ïï '
.
ïï' (
	FindAsync
ïï( 1
(
ïï1 2
[
ïï2 3
id
ïï3 5
]
ïï5 6
,
ïï6 7
ct
ïï8 :
)
ïï: ;
;
ïï; <
if
ïï= ?
(
ïï@ A
expense
ïïA H
is
ïïI K
null
ïïL P
)
ïïP Q
return
ïïR X
NotFound
ïïY a
(
ïïa b
)
ïïb c
;
ïïc d
foreach
ññ 
(
ññ 
var
ññ 
x
ññ 
in
ññ 
await
ññ 
ExpenseSeries
ññ  -
(
ññ- .
expense
ññ. 5
)
ññ5 6
.
ññ6 7
ToListAsync
ññ7 B
(
ññB C
ct
ññC E
)
ññE F
)
ññF G
x
ññH I
.
ññI J
RecurrenceEndsAt
ññJ Z
=
ññ[ \
null
ññ] a
;
ñña b
await
óó 
db
óó 
.
óó 
SaveChangesAsync
óó !
(
óó! "
ct
óó" $
)
óó$ %
;
óó% &
return
óó' -
	NoContent
óó. 7
(
óó7 8
)
óó8 9
;
óó9 :
}
òò 
private
öö 

IQueryable
öö 
<
öö 
Expense
öö 
>
öö 
ExpenseSeries
öö  -
(
öö- .
Expense
öö. 5
expense
öö6 =
)
öö= >
{
õõ 
var
úú 
description
úú 
=
úú 
expense
úú !
.
úú! "
Description
úú" -
.
úú- .
Trim
úú. 2
(
úú2 3
)
úú3 4
;
úú4 5
return
ùù 
db
ùù 
.
ùù 
Expenses
ùù 
.
ùù 
Where
ùù  
(
ùù  !
x
ùù! "
=>
ùù# %
x
ùù& '
.
ùù' (
	Recurring
ùù( 1
&&
ùù2 4
x
ùù5 6
.
ùù6 7
Description
ùù7 B
.
ùùB C
Trim
ùùC G
(
ùùG H
)
ùùH I
==
ùùJ L
description
ùùM X
&&
ùùY [
x
ùù\ ]
.
ùù] ^

CategoryId
ùù^ h
==
ùùi k
expense
ùùl s
.
ùùs t

CategoryId
ùùt ~
&&ùù Å
xùùÇ É
.ùùÉ Ñ
CurrencyùùÑ å
==ùùç è
expenseùùê ó
.ùùó ò
Currencyùùò †
)ùù† °
;ùù° ¢
}
ûû 
[
†† 
	HttpPatch
†† 
(
†† 
$str
†† #
)
††# $
]
††$ %
public
°° 

async
°° 
Task
°° 
<
°° 
ActionResult
°° "
>
°°" #
UpdateExpense
°°$ 1
(
°°1 2
Guid
°°2 6
id
°°7 9
,
°°9 :!
ExpensePatchRequest
°°; N
request
°°O V
,
°°V W
CancellationToken
°°X i
ct
°°j l
)
°°l m
{
¢¢ 
var
££ 
expense
££ 
=
££ 
await
££ 
db
££ 
.
££ 
Expenses
££ '
.
££' (
	FindAsync
££( 1
(
££1 2
[
££2 3
id
££3 5
]
££5 6
,
££6 7
ct
££8 :
)
££: ;
;
££; <
if
££= ?
(
££@ A
expense
££A H
is
££I K
null
££L P
)
££P Q
return
££R X
NotFound
££Y a
(
££a b
)
££b c
;
££c d
if
§§ 

(
§§ 
request
§§ 
.
§§ 
Description
§§ 
is
§§  "
not
§§# &
null
§§' +
)
§§+ ,
expense
§§- 4
.
§§4 5
Description
§§5 @
=
§§A B
request
§§C J
.
§§J K
Description
§§K V
.
§§V W
Trim
§§W [
(
§§[ \
)
§§\ ]
;
§§] ^
if
•• 

(
•• 
request
•• 
.
•• 

CategoryId
•• 
is
•• !
Guid
••" &

categoryId
••' 1
)
••1 2
{
¶¶ 	
if
ßß 
(
ßß 
!
ßß 
await
ßß 
db
ßß 
.
ßß 
ExpenseCategories
ßß +
.
ßß+ ,
AnyAsync
ßß, 4
(
ßß4 5
x
ßß5 6
=>
ßß7 9
x
ßß: ;
.
ßß; <
Id
ßß< >
==
ßß? A

categoryId
ßßB L
,
ßßL M
ct
ßßN P
)
ßßP Q
)
ßßQ R
return
ßßS Y

BadRequest
ßßZ d
(
ßßd e
new
ßße h
{
ßßi j
message
ßßk r
=
ßßs t
$strßßu í
}ßßì î
)ßßî ï
;ßßï ñ
expense
®® 
.
®® 

CategoryId
®® 
=
®®  

categoryId
®®! +
;
®®+ ,
}
©© 	
if
™™ 

(
™™ 
request
™™ 
.
™™ 
Type
™™ 
is
™™ 
ExpenseType
™™ '
type
™™( ,
)
™™, -
expense
™™. 5
.
™™5 6
Type
™™6 :
=
™™; <
type
™™= A
;
™™A B
if
´´ 

(
´´ 
request
´´ 
.
´´ 
Amount
´´ 
is
´´ 
decimal
´´ %
amount
´´& ,
)
´´, -
expense
´´. 5
.
´´5 6
Amount
´´6 <
=
´´= >
amount
´´? E
;
´´E F
if
¨¨ 

(
¨¨ 
request
¨¨ 
.
¨¨ 
Currency
¨¨ 
is
¨¨ 
not
¨¨  #
null
¨¨$ (
)
¨¨( )
expense
¨¨* 1
.
¨¨1 2
Currency
¨¨2 :
=
¨¨; <
request
¨¨= D
.
¨¨D E
Currency
¨¨E M
.
¨¨M N
Trim
¨¨N R
(
¨¨R S
)
¨¨S T
.
¨¨T U
ToUpperInvariant
¨¨U e
(
¨¨e f
)
¨¨f g
;
¨¨g h
if
≠≠ 

(
≠≠ 
request
≠≠ 
.
≠≠ 
Date
≠≠ 
is
≠≠ 
DateOnly
≠≠ $
date
≠≠% )
)
≠≠) *
expense
≠≠+ 2
.
≠≠2 3
Date
≠≠3 7
=
≠≠8 9
date
≠≠: >
;
≠≠> ?
if
ÆÆ 

(
ÆÆ 
request
ÆÆ 
.
ÆÆ 
	Recurring
ÆÆ 
is
ÆÆ  
bool
ÆÆ! %
	recurring
ÆÆ& /
)
ÆÆ/ 0
expense
ÆÆ1 8
.
ÆÆ8 9
	Recurring
ÆÆ9 B
=
ÆÆC D
	recurring
ÆÆE N
;
ÆÆN O
if
ØØ 

(
ØØ 
request
ØØ 
.
ØØ 
RecurrenceCycle
ØØ #
is
ØØ$ &
BillingCycle
ØØ' 3
cycle
ØØ4 9
)
ØØ9 :
expense
ØØ; B
.
ØØB C
RecurrenceCycle
ØØC R
=
ØØS T
cycle
ØØU Z
;
ØØZ [
if
∞∞ 

(
∞∞ 
request
∞∞ 
.
∞∞ 
IsNonDeductible
∞∞ #
is
∞∞$ &
bool
∞∞' +
nonDeductible
∞∞, 9
)
∞∞9 :
expense
∞∞; B
.
∞∞B C
IsNonDeductible
∞∞C R
=
∞∞S T
nonDeductible
∞∞U b
;
∞∞b c
if
±± 

(
±± 
request
±± 
.
±± #
IsNonDomiciledService
±± )
is
±±* ,
bool
±±- 1
foreign
±±2 9
)
±±9 :!
ApplyForeignService
±±; N
(
±±N O
expense
±±O V
,
±±V W
foreign
±±X _
,
±±_ `
request
±±a h
.
±±h i!
ForeignSupplierName
±±i |
,
±±| }
request±±~ Ö
.±±Ö Ü&
ForeignSupplierCountry±±Ü ú
)±±ú ù
;±±ù û
if
≤≤ 

(
≤≤ 
string
≤≤ 
.
≤≤  
IsNullOrWhiteSpace
≤≤ %
(
≤≤% &
expense
≤≤& -
.
≤≤- .
Description
≤≤. 9
)
≤≤9 :
||
≤≤; =
string
≤≤> D
.
≤≤D E 
IsNullOrWhiteSpace
≤≤E W
(
≤≤W X
expense
≤≤X _
.
≤≤_ `
Currency
≤≤` h
)
≤≤h i
||
≤≤j l
expense
≤≤m t
.
≤≤t u
Amount
≤≤u {
<=
≤≤| ~
$num≤≤ Ä
)≤≤Ä Å
return≤≤Ç à

BadRequest≤≤â ì
(≤≤ì î
new≤≤î ó
{≤≤ò ô
message≤≤ö °
=≤≤¢ £
$str≤≤§ ‡
}≤≤· ‚
)≤≤‚ „
;≤≤„ ‰
expense
≥≥ 
.
≥≥ 
	AmountPen
≥≥ 
=
≥≥ 
expense
≥≥ #
.
≥≥# $
Amount
≥≥$ *
*
≥≥+ ,
await
≥≥- 2
db
≥≥3 5
.
≥≥5 6
RateToPenAsync
≥≥6 D
(
≥≥D E
expense
≥≥E L
.
≥≥L M
Currency
≥≥M U
,
≥≥U V
expense
≥≥W ^
.
≥≥^ _
Date
≥≥_ c
,
≥≥c d
ct
≥≥e g
)
≥≥g h
;
≥≥h i
await
¥¥ 
db
¥¥ 
.
¥¥ 
SaveChangesAsync
¥¥ !
(
¥¥! "
ct
¥¥" $
)
¥¥$ %
;
¥¥% &
await
¥¥' ,
db
¥¥- /
.
¥¥/ 0
Entry
¥¥0 5
(
¥¥5 6
expense
¥¥6 =
)
¥¥= >
.
¥¥> ?
	Reference
¥¥? H
(
¥¥H I
x
¥¥I J
=>
¥¥K M
x
¥¥N O
.
¥¥O P
Category
¥¥P X
)
¥¥X Y
.
¥¥Y Z
	LoadAsync
¥¥Z c
(
¥¥c d
ct
¥¥d f
)
¥¥f g
;
¥¥g h
return
¥¥i o
Ok
¥¥p r
(
¥¥r s

ExpenseDto
¥¥s }
(
¥¥} ~
expense¥¥~ Ö
)¥¥Ö Ü
)¥¥Ü á
;¥¥á à
}
µµ 
private
∑∑ 
const
∑∑ 
string
∑∑ 
TaxDisclaimer
∑∑ &
=
∑∑' (
$str∑∑) ÿ
;∑∑ÿ Ÿ
private
∫∫ 
static
∫∫ 
(
∫∫ 
DateOnly
∫∫ 
From
∫∫ !
,
∫∫! "
DateOnly
∫∫# +
To
∫∫, .
)
∫∫. /
Period
∫∫0 6
(
∫∫6 7
int
∫∫7 :
?
∫∫: ;
month
∫∫< A
,
∫∫A B
int
∫∫C F
year
∫∫G K
)
∫∫K L
=>
∫∫M O
month
ªª 
is
ªª 
int
ªª 
m
ªª 
?
ªª 
(
ªª 
new
ªª 
DateOnly
ªª &
(
ªª& '
year
ªª' +
,
ªª+ ,
m
ªª- .
,
ªª. /
$num
ªª0 1
)
ªª1 2
,
ªª2 3
new
ªª4 7
DateOnly
ªª8 @
(
ªª@ A
year
ªªA E
,
ªªE F
m
ªªG H
,
ªªH I
$num
ªªJ K
)
ªªK L
.
ªªL M
	AddMonths
ªªM V
(
ªªV W
$num
ªªW X
)
ªªX Y
.
ªªY Z
AddDays
ªªZ a
(
ªªa b
-
ªªb c
$num
ªªc d
)
ªªd e
)
ªªe f
:
ªªg h
(
ªªi j
new
ªªj m
DateOnly
ªªn v
(
ªªv w
year
ªªw {
,
ªª{ |
$num
ªª} ~
,
ªª~ 
$numªªÄ Å
)ªªÅ Ç
,ªªÇ É
newªªÑ á
DateOnlyªªà ê
(ªªê ë
yearªªë ï
,ªªï ñ
$numªªó ô
,ªªô ö
$numªªõ ù
)ªªù û
)ªªû ü
;ªªü †
private
ææ 
static
ææ 
(
ææ 
DateOnly
ææ 
From
ææ !
,
ææ! "
DateOnly
ææ# +
To
ææ, .
)
ææ. /
PreviousPeriod
ææ0 >
(
ææ> ?
int
ææ? B
?
ææB C
month
ææD I
,
ææI J
int
ææK N
year
ææO S
)
ææS T
=>
ææU W
month
øø 
switch
øø 
{
øø 
null
øø 
=>
øø 
Period
øø %
(
øø% &
null
øø& *
,
øø* +
year
øø, 0
-
øø1 2
$num
øø3 4
)
øø4 5
,
øø5 6
$num
øø7 8
=>
øø9 ;
Period
øø< B
(
øøB C
$num
øøC E
,
øøE F
year
øøG K
-
øøL M
$num
øøN O
)
øøO P
,
øøP Q
int
øøR U
m
øøV W
=>
øøX Z
Period
øø[ a
(
øøa b
m
øøb c
-
øød e
$num
øøf g
,
øøg h
year
øøi m
)
øøm n
}
øøo p
;
øøp q
private
≈≈ 
sealed
≈≈ 
record
≈≈ 
Sale
≈≈ 
(
≈≈ 
Guid
≈≈ #
ClientId
≈≈$ ,
,
≈≈, -
DateOnly
≈≈. 6
Date
≈≈7 ;
,
≈≈; <
decimal
≈≈= D
BasePen
≈≈E L
,
≈≈L M
decimal
≈≈N U
IgvPen
≈≈V \
,
≈≈\ ]
bool
≈≈^ b
Gravada
≈≈c j
,
≈≈j k
decimal
≈≈l s
RetentionPen≈≈t Ä
,≈≈Ä Å
bool≈≈Ç Ü
PersonaNatural≈≈á ï
=≈≈ñ ó
false≈≈ò ù
)≈≈ù û
{
∆∆ 
public
«« 
bool
«« 
Mype
«« 
=>
«« 
!
«« 
PersonaNatural
«« +
;
««+ ,
}
»» 
private
œœ 
async
œœ 
Task
œœ 
<
œœ 
List
œœ 
<
œœ 
Sale
œœ  
>
œœ  !
>
œœ! "

SalesAsync
œœ# -
(
œœ- .
DateOnly
œœ. 6
from
œœ7 ;
,
œœ; <
DateOnly
œœ= E
to
œœF H
,
œœH I
CancellationToken
œœJ [
ct
œœ\ ^
)
œœ^ _
{
–– 
var
—— 
start
—— 
=
—— 
from
—— 
.
—— 

ToDateTime
—— #
(
——# $
TimeOnly
——$ ,
.
——, -
MinValue
——- 5
)
——5 6
;
——6 7
var
——8 ;
end
——< ?
=
——@ A
to
——B D
.
——D E
AddDays
——E L
(
——L M
$num
——M N
)
——N O
.
——O P

ToDateTime
——P Z
(
——Z [
TimeOnly
——[ c
.
——c d
MinValue
——d l
)
——l m
;
——m n
var
““ 
payments
““ 
=
““ 
await
““ 
db
““ 
.
““  !
PaymentTransactions
““  3
.
““3 4
Where
““4 9
(
““9 :
x
““: ;
=>
““< >
x
““? @
.
““@ A
	CreatedAt
““A J
>=
““K M
start
““N S
&&
““T V
x
““W X
.
““X Y
	CreatedAt
““Y b
<
““c d
end
““e h
)
““h i
.
”” 
Select
”” 
(
”” 
x
”” 
=>
”” 
new
”” 
{
”” 
x
””  
.
””  !
ClientId
””! )
,
””) *
x
””+ ,
.
””, -
	CreatedAt
””- 6
,
””6 7
x
””8 9
.
””9 :
	AmountPen
””: C
,
””C D
Document
””E M
=
””N O
db
””P R
.
””R S
TaxDocuments
””S _
.
””_ `
FirstOrDefault
””` n
(
””n o
d
””o p
=>
””q s
d
””t u
.
””u v#
PaymentTransactionId””v ä
==””ã ç
x””é è
.””è ê
Id””ê í
)””í ì
}””î ï
)””ï ñ
.””ñ ó
ToListAsync””ó ¢
(””¢ £
ct””£ •
)””• ¶
;””¶ ß
return
‘‘ 
payments
‘‘ 
.
‘‘ 
Select
‘‘ 
(
‘‘ 
x
‘‘  
=>
‘‘! #
{
’’ 	
var
÷÷ 
document
÷÷ 
=
÷÷ 
x
÷÷ 
.
÷÷ 
Document
÷÷ %
is
÷÷& (
{
÷÷) *
TotalAmount
÷÷+ 6
:
÷÷6 7
>
÷÷8 9
$num
÷÷: ;
}
÷÷< =
d
÷÷> ?
?
÷÷@ A
d
÷÷B C
:
÷÷D E
null
÷÷F J
;
÷÷J K
var
◊◊ 
	isFactura
◊◊ 
=
◊◊ 
document
◊◊ $
?
◊◊$ %
.
◊◊% &
Type
◊◊& *
==
◊◊+ -
TaxDocumentType
◊◊. =
.
◊◊= >
Factura
◊◊> E
;
◊◊E F
var
ÿÿ 
basePen
ÿÿ 
=
ÿÿ 
	isFactura
ÿÿ #
?
ÿÿ$ %
x
ÿÿ& '
.
ÿÿ' (
	AmountPen
ÿÿ( 1
*
ÿÿ2 3
document
ÿÿ4 <
!
ÿÿ< =
.
ÿÿ= >

BaseAmount
ÿÿ> H
/
ÿÿI J
document
ÿÿK S
.
ÿÿS T
TotalAmount
ÿÿT _
:
ÿÿ` a
x
ÿÿb c
.
ÿÿc d
	AmountPen
ÿÿd m
;
ÿÿm n
var
ŸŸ 
retentionPen
ŸŸ 
=
ŸŸ 
document
ŸŸ '
?
ŸŸ' (
.
ŸŸ( )
RetentionAmount
ŸŸ) 8
is
ŸŸ9 ;
decimal
ŸŸ< C
	retention
ŸŸD M
?
ŸŸN O
x
ŸŸP Q
.
ŸŸQ R
	AmountPen
ŸŸR [
*
ŸŸ\ ]
	retention
ŸŸ^ g
/
ŸŸh i
document
ŸŸj r
.
ŸŸr s
TotalAmount
ŸŸs ~
:ŸŸ Ä
$numŸŸÅ É
;ŸŸÉ Ñ
return
⁄⁄ 
new
⁄⁄ 
Sale
⁄⁄ 
(
⁄⁄ 
x
⁄⁄ 
.
⁄⁄ 
ClientId
⁄⁄ &
,
⁄⁄& '
DateOnly
⁄⁄( 0
.
⁄⁄0 1
FromDateTime
⁄⁄1 =
(
⁄⁄= >
x
⁄⁄> ?
.
⁄⁄? @
	CreatedAt
⁄⁄@ I
)
⁄⁄I J
,
⁄⁄J K
basePen
⁄⁄L S
,
⁄⁄S T
x
⁄⁄U V
.
⁄⁄V W
	AmountPen
⁄⁄W `
-
⁄⁄a b
basePen
⁄⁄c j
,
⁄⁄j k
	isFactura
⁄⁄l u
,
⁄⁄u v
retentionPen⁄⁄w É
,⁄⁄É Ñ
document⁄⁄Ö ç
?⁄⁄ç é
.⁄⁄é è
Type⁄⁄è ì
==⁄⁄î ñ
TaxDocumentType⁄⁄ó ¶
.⁄⁄¶ ß#
ReciboPorHonorarios⁄⁄ß ∫
)⁄⁄∫ ª
;⁄⁄ª º
}
€€ 	
)
€€	 

.
€€
 
ToList
€€ 
(
€€ 
)
€€ 
;
€€ 
}
‹‹ 
[
ﬁﬁ 
HttpGet
ﬁﬁ 
(
ﬁﬁ 
$str
ﬁﬁ 
)
ﬁﬁ 
]
ﬁﬁ 
public
ﬂﬂ 

async
ﬂﬂ 
Task
ﬂﬂ 
<
ﬂﬂ 
ActionResult
ﬂﬂ "
>
ﬂﬂ" #
SalesReport
ﬂﬂ$ /
(
ﬂﬂ/ 0
int
ﬂﬂ0 3
?
ﬂﬂ3 4
month
ﬂﬂ5 :
,
ﬂﬂ: ;
int
ﬂﬂ< ?
year
ﬂﬂ@ D
,
ﬂﬂD E
string
ﬂﬂF L
currency
ﬂﬂM U
,
ﬂﬂU V
CancellationToken
ﬂﬂW h
ct
ﬂﬂi k
)
ﬂﬂk l
{
‡‡ 
if
·· 

(
·· 
currency
·· 
is
·· 
not
·· 
(
·· 
$str
·· "
or
··# %
$str
··& +
or
··, .
$str
··/ 4
)
··4 5
)
··5 6
return
··7 =

BadRequest
··> H
(
··H I
new
··I L
{
··M N
message
··O V
=
··W X
$str
··Y k
}
··l m
)
··m n
;
··n o
var
‚‚ 
(
‚‚ 
from
‚‚ 
,
‚‚ 
to
‚‚ 
)
‚‚ 
=
‚‚ 
Period
‚‚ 
(
‚‚  
month
‚‚  %
,
‚‚% &
year
‚‚' +
)
‚‚+ ,
;
‚‚, -
var
„„ 
sales
„„ 
=
„„ 
await
„„ 

SalesAsync
„„ $
(
„„$ %
from
„„% )
,
„„) *
to
„„+ -
,
„„- .
ct
„„/ 1
)
„„1 2
;
„„2 3
decimal
‰‰ 
basePen
‰‰ 
=
‰‰ 
sales
‰‰ 
.
‰‰  
Sum
‰‰  #
(
‰‰# $
x
‰‰$ %
=>
‰‰& (
x
‰‰) *
.
‰‰* +
BasePen
‰‰+ 2
)
‰‰2 3
,
‰‰3 4
igvPen
‰‰5 ;
=
‰‰< =
sales
‰‰> C
.
‰‰C D
Sum
‰‰D G
(
‰‰G H
x
‰‰H I
=>
‰‰J L
x
‰‰M N
.
‰‰N O
IgvPen
‰‰O U
)
‰‰U V
;
‰‰V W
var
ÂÂ 
rate
ÂÂ 
=
ÂÂ 
currency
ÂÂ 
==
ÂÂ 
$str
ÂÂ $
?
ÂÂ% &
$num
ÂÂ' )
:
ÂÂ* +
await
ÂÂ, 1
db
ÂÂ2 4
.
ÂÂ4 5
RateToPenAsync
ÂÂ5 C
(
ÂÂC D
currency
ÂÂD L
,
ÂÂL M
to
ÂÂN P
,
ÂÂP Q
ct
ÂÂR T
)
ÂÂT U
;
ÂÂU V
return
ÊÊ 
Ok
ÊÊ 
(
ÊÊ 
new
ÊÊ 
{
ÊÊ 
baseImponible
ÊÊ %
=
ÊÊ& '
Math
ÊÊ( ,
.
ÊÊ, -
Round
ÊÊ- 2
(
ÊÊ2 3
basePen
ÊÊ3 :
/
ÊÊ; <
rate
ÊÊ= A
,
ÊÊA B
$num
ÊÊC D
)
ÊÊD E
,
ÊÊE F
igv
ÊÊG J
=
ÊÊK L
Math
ÊÊM Q
.
ÊÊQ R
Round
ÊÊR W
(
ÊÊW X
igvPen
ÊÊX ^
/
ÊÊ_ `
rate
ÊÊa e
,
ÊÊe f
$num
ÊÊg h
)
ÊÊh i
,
ÊÊi j
total
ÊÊk p
=
ÊÊq r
Math
ÊÊs w
.
ÊÊw x
Round
ÊÊx }
(
ÊÊ} ~
(
ÊÊ~ 
basePenÊÊ Ü
+ÊÊá à
igvPenÊÊâ è
)ÊÊè ê
/ÊÊë í
rateÊÊì ó
,ÊÊó ò
$numÊÊô ö
)ÊÊö õ
}ÊÊú ù
)ÊÊù û
;ÊÊû ü
}
ÁÁ 
[
ÈÈ 
HttpGet
ÈÈ 
(
ÈÈ 
$str
ÈÈ "
)
ÈÈ" #
]
ÈÈ# $
public
ÍÍ 

async
ÍÍ 
Task
ÍÍ 
<
ÍÍ 
ActionResult
ÍÍ "
>
ÍÍ" #
TaxSummaryReport
ÍÍ$ 4
(
ÍÍ4 5
int
ÍÍ5 8
?
ÍÍ8 9
month
ÍÍ: ?
,
ÍÍ? @
int
ÍÍA D
year
ÍÍE I
,
ÍÍI J
CancellationToken
ÍÍK \
ct
ÍÍ] _
)
ÍÍ_ `
{
ÎÎ 
var
ÏÏ 
settings
ÏÏ 
=
ÏÏ 
await
ÏÏ 
TaxSettingsRow
ÏÏ +
(
ÏÏ+ ,
ct
ÏÏ, .
)
ÏÏ. /
;
ÏÏ/ 0
var
ÌÌ 
(
ÌÌ 
from
ÌÌ 
,
ÌÌ 
to
ÌÌ 
)
ÌÌ 
=
ÌÌ 
Period
ÌÌ 
(
ÌÌ  
month
ÌÌ  %
,
ÌÌ% &
year
ÌÌ' +
)
ÌÌ+ ,
;
ÌÌ, -
var
ÓÓ 
sales
ÓÓ 
=
ÓÓ 
await
ÓÓ 

SalesAsync
ÓÓ $
(
ÓÓ$ %
from
ÓÓ% )
,
ÓÓ) *
to
ÓÓ+ -
,
ÓÓ- .
ct
ÓÓ/ 1
)
ÓÓ1 2
;
ÓÓ2 3
decimal
ÔÔ 
basePen
ÔÔ 
=
ÔÔ 
sales
ÔÔ 
.
ÔÔ  
Sum
ÔÔ  #
(
ÔÔ# $
x
ÔÔ$ %
=>
ÔÔ& (
x
ÔÔ) *
.
ÔÔ* +
BasePen
ÔÔ+ 2
)
ÔÔ2 3
,
ÔÔ3 4
gravadasPen
ÔÔ5 @
=
ÔÔA B
sales
ÔÔC H
.
ÔÔH I
Where
ÔÔI N
(
ÔÔN O
x
ÔÔO P
=>
ÔÔQ S
x
ÔÔT U
.
ÔÔU V
Gravada
ÔÔV ]
)
ÔÔ] ^
.
ÔÔ^ _
Sum
ÔÔ_ b
(
ÔÔb c
x
ÔÔc d
=>
ÔÔe g
x
ÔÔh i
.
ÔÔi j
BasePen
ÔÔj q
)
ÔÔq r
;
ÔÔr s
var
 
igv
 
=
 
(
 
await
 
IgvMonthsAsync
 '
(
' (
to
( *
,
* +
ct
, .
)
. /
)
/ 0
.
0 1
Where
1 6
(
6 7
x
7 8
=>
9 ;
x
< =
.
= >
Month
> C
>=
D F
from
G K
)
K L
.
L M
ToList
M S
(
S T
)
T U
;
U V
return
ÚÚ 
Ok
ÚÚ 
(
ÚÚ 
new
ÚÚ 
{
ÛÛ 	
ventasGravadasPen
ÙÙ 
=
ÙÙ 
Math
ÙÙ  $
.
ÙÙ$ %
Round
ÙÙ% *
(
ÙÙ* +
gravadasPen
ÙÙ+ 6
,
ÙÙ6 7
$num
ÙÙ8 9
)
ÙÙ9 :
,
ÙÙ: ;!
ventasNoGravadasPen
ÙÙ< O
=
ÙÙP Q
Math
ÙÙR V
.
ÙÙV W
Round
ÙÙW \
(
ÙÙ\ ]
basePen
ÙÙ] d
-
ÙÙe f
gravadasPen
ÙÙg r
,
ÙÙr s
$num
ÙÙt u
)
ÙÙu v
,
ÙÙv w
igvEstimadoÙÙx É
=ÙÙÑ Ö
MathÙÙÜ ä
.ÙÙä ã
RoundÙÙã ê
(ÙÙê ë
salesÙÙë ñ
.ÙÙñ ó
SumÙÙó ö
(ÙÙö õ
xÙÙõ ú
=>ÙÙù ü
xÙÙ† °
.ÙÙ° ¢
IgvPenÙÙ¢ ®
)ÙÙ® ©
,ÙÙ© ™
$numÙÙ´ ¨
)ÙÙ¨ ≠
,ÙÙ≠ Æ
rentaEstimadaÙÙØ º
=ÙÙΩ æ
MathÙÙø √
.ÙÙ√ ƒ
RoundÙÙƒ …
(ÙÙ…  
salesÙÙ  œ
.ÙÙœ –
WhereÙÙ– ’
(ÙÙ’ ÷
xÙÙ÷ ◊
=>ÙÙÿ ⁄
xÙÙ€ ‹
.ÙÙ‹ ›
MypeÙÙ› ·
)ÙÙ· ‚
.ÙÙ‚ „
SumÙÙ„ Ê
(ÙÙÊ Á
xÙÙÁ Ë
=>ÙÙÈ Î
xÙÙÏ Ì
.ÙÙÌ Ó
BasePenÙÙÓ ı
)ÙÙı ˆ
*ÙÙ˜ ¯
settingsÙÙ˘ Å
.ÙÙÅ Ç
	RentaRateÙÙÇ ã
,ÙÙã å
$numÙÙç é
)ÙÙé è
,ÙÙè ê'
ventasPersonaNaturalPenÙÙë ®
=ÙÙ© ™
MathÙÙ´ Ø
.ÙÙØ ∞
RoundÙÙ∞ µ
(ÙÙµ ∂
salesÙÙ∂ ª
.ÙÙª º
WhereÙÙº ¡
(ÙÙ¡ ¬
xÙÙ¬ √
=>ÙÙƒ ∆
xÙÙ« »
.ÙÙ» …
PersonaNaturalÙÙ… ◊
)ÙÙ◊ ÿ
.ÙÙÿ Ÿ
SumÙÙŸ ‹
(ÙÙ‹ ›
xÙÙ› ﬁ
=>ÙÙﬂ ·
xÙÙ‚ „
.ÙÙ„ ‰
BasePenÙÙ‰ Î
)ÙÙÎ Ï
,ÙÙÏ Ì
$numÙÙÓ Ô
)ÙÙÔ 
,ÙÙ Ò
tasaÙÙÚ ˆ
=ÙÙ˜ ¯
newÙÙ˘ ¸
{ÙÙ˝ ˛
igvRateÙÙˇ Ü
=ÙÙá à
settingsÙÙâ ë
.ÙÙë í
IgvRateÙÙí ô
,ÙÙô ö
	rentaRateÙÙõ §
=ÙÙ• ¶
settingsÙÙß Ø
.ÙÙØ ∞
	RentaRateÙÙ∞ π
}ÙÙ∫ ª
,ÙÙª º

disclaimerÙÙΩ «
=ÙÙ» …
TaxDisclaimerÙÙ  ◊
,ÙÙ◊ ÿ
igv
ˆˆ 
=
ˆˆ 
new
ˆˆ 
{
˜˜ 
debitoFiscal
¯¯ 
=
¯¯ 
Math
¯¯ #
.
¯¯# $
Round
¯¯$ )
(
¯¯) *
igv
¯¯* -
.
¯¯- .
Sum
¯¯. 1
(
¯¯1 2
x
¯¯2 3
=>
¯¯4 6
x
¯¯7 8
.
¯¯8 9
Debito
¯¯9 ?
)
¯¯? @
,
¯¯@ A
$num
¯¯B C
)
¯¯C D
,
¯¯D E
creditoFiscal
¯¯F S
=
¯¯T U
Math
¯¯V Z
.
¯¯Z [
Round
¯¯[ `
(
¯¯` a
igv
¯¯a d
.
¯¯d e
Sum
¯¯e h
(
¯¯h i
x
¯¯i j
=>
¯¯k m
x
¯¯n o
.
¯¯o p
Credito
¯¯p w
)
¯¯w x
,
¯¯x y
$num
¯¯z {
)
¯¯{ |
,
¯¯| }!
saldoAFavorAnterior
˘˘ #
=
˘˘$ %
Math
˘˘& *
.
˘˘* +
Round
˘˘+ 0
(
˘˘0 1
igv
˘˘1 4
.
˘˘4 5
FirstOrDefault
˘˘5 C
(
˘˘C D
)
˘˘D E
?
˘˘E F
.
˘˘F G
SaldoAnterior
˘˘G T
??
˘˘U W
$num
˘˘X Z
,
˘˘Z [
$num
˘˘\ ]
)
˘˘] ^
,
˘˘^ _
	igvAPagar
˘˘` i
=
˘˘j k
Math
˘˘l p
.
˘˘p q
Round
˘˘q v
(
˘˘v w
igv
˘˘w z
.
˘˘z {
Sum
˘˘{ ~
(
˘˘~ 
x˘˘ Ä
=>˘˘Å É
x˘˘Ñ Ö
.˘˘Ö Ü
APagar˘˘Ü å
)˘˘å ç
,˘˘ç é
$num˘˘è ê
)˘˘ê ë
,˘˘ë í"
saldoAFavorSiguiente
˙˙ $
=
˙˙% &
Math
˙˙' +
.
˙˙+ ,
Round
˙˙, 1
(
˙˙1 2
igv
˙˙2 5
.
˙˙5 6
LastOrDefault
˙˙6 C
(
˙˙C D
)
˙˙D E
?
˙˙E F
.
˙˙F G
SaldoSiguiente
˙˙G U
??
˙˙V X
$num
˙˙Y [
,
˙˙[ \
$num
˙˙] ^
)
˙˙^ _
,
˙˙_ `
meses
˚˚ 
=
˚˚ 
igv
˚˚ 
.
˚˚ 
Select
˚˚ "
(
˚˚" #
x
˚˚# $
=>
˚˚% '
new
˚˚( +
{
˚˚, -
mes
˚˚. 1
=
˚˚2 3
x
˚˚4 5
.
˚˚5 6
Month
˚˚6 ;
.
˚˚; <
ToString
˚˚< D
(
˚˚D E
$str
˚˚E N
)
˚˚N O
,
˚˚O P
debitoFiscal
˚˚Q ]
=
˚˚^ _
Math
˚˚` d
.
˚˚d e
Round
˚˚e j
(
˚˚j k
x
˚˚k l
.
˚˚l m
Debito
˚˚m s
,
˚˚s t
$num
˚˚u v
)
˚˚v w
,
˚˚w x
creditoFiscal˚˚y Ü
=˚˚á à
Math˚˚â ç
.˚˚ç é
Round˚˚é ì
(˚˚ì î
x˚˚î ï
.˚˚ï ñ
Credito˚˚ñ ù
,˚˚ù û
$num˚˚ü †
)˚˚† °
,˚˚° ¢#
saldoAFavorAnterior˚˚£ ∂
=˚˚∑ ∏
Math˚˚π Ω
.˚˚Ω æ
Round˚˚æ √
(˚˚√ ƒ
x˚˚ƒ ≈
.˚˚≈ ∆
SaldoAnterior˚˚∆ ”
,˚˚” ‘
$num˚˚’ ÷
)˚˚÷ ◊
,˚˚◊ ÿ
	igvAPagar˚˚Ÿ ‚
=˚˚„ ‰
Math˚˚Â È
.˚˚È Í
Round˚˚Í Ô
(˚˚Ô 
x˚˚ Ò
.˚˚Ò Ú
APagar˚˚Ú ¯
,˚˚¯ ˘
$num˚˚˙ ˚
)˚˚˚ ¸
,˚˚¸ ˝$
saldoAFavorSiguiente˚˚˛ í
=˚˚ì î
Math˚˚ï ô
.˚˚ô ö
Round˚˚ö ü
(˚˚ü †
x˚˚† °
.˚˚° ¢
SaldoSiguiente˚˚¢ ∞
,˚˚∞ ±
$num˚˚≤ ≥
)˚˚≥ ¥
}˚˚µ ∂
)˚˚∂ ∑
,˚˚∑ ∏
}
¸¸ 
,
¸¸ 
}
˝˝ 	
)
˝˝	 

;
˝˝
 
}
˛˛ 
internal
ÄÄ 
sealed
ÄÄ 
record
ÄÄ 
IgvMonth
ÄÄ #
(
ÄÄ# $
DateOnly
ÄÄ$ ,
Month
ÄÄ- 2
,
ÄÄ2 3
decimal
ÄÄ4 ;
Debito
ÄÄ< B
,
ÄÄB C
decimal
ÄÄD K
Credito
ÄÄL S
,
ÄÄS T
decimal
ÄÄU \
SaldoAnterior
ÄÄ] j
,
ÄÄj k
decimal
ÄÄl s
APagar
ÄÄt z
,
ÄÄz {
decimalÄÄ| É
SaldoSiguienteÄÄÑ í
)ÄÄí ì
;ÄÄì î
internal
ÜÜ 
async
ÜÜ 
Task
ÜÜ 
<
ÜÜ 
List
ÜÜ 
<
ÜÜ 
IgvMonth
ÜÜ %
>
ÜÜ% &
>
ÜÜ& '
IgvMonthsAsync
ÜÜ( 6
(
ÜÜ6 7
DateOnly
ÜÜ7 ?
to
ÜÜ@ B
,
ÜÜB C
CancellationToken
ÜÜD U
ct
ÜÜV X
)
ÜÜX Y
{
áá 
var
àà 
end
àà 
=
àà 
new
àà 
DateOnly
àà 
(
àà 
to
àà !
.
àà! "
Year
àà" &
,
àà& '
to
àà( *
.
àà* +
Month
àà+ 0
,
àà0 1
$num
àà2 3
)
àà3 4
;
àà4 5
DateOnly
ââ 
?
ââ 
	firstSale
ââ 
=
ââ 
await
ââ #
db
ââ$ &
.
ââ& '!
PaymentTransactions
ââ' :
.
ââ: ;
OrderBy
ââ; B
(
ââB C
x
ââC D
=>
ââE G
x
ââH I
.
ââI J
	CreatedAt
ââJ S
)
ââS T
.
ââT U
Select
ââU [
(
ââ[ \
x
ââ\ ]
=>
ââ^ `
(
ââa b
DateTime
ââb j
?
ââj k
)
ââk l
x
ââl m
.
ââm n
	CreatedAt
âân w
)
ââw x
.
ââx y"
FirstOrDefaultAsyncâây å
(ââå ç
ctââç è
)ââè ê
isââë ì
DateTimeââî ú
dââù û
?ââü †
DateOnlyââ° ©
.ââ© ™
FromDateTimeââ™ ∂
(ââ∂ ∑
dââ∑ ∏
)ââ∏ π
:ââ∫ ª
nullââº ¿
;ââ¿ ¡
DateOnly
ää 
?
ää 
firstPurchase
ää 
=
ää  !
await
ää" '
db
ää( *
.
ää* +
	Purchases
ää+ 4
.
ää4 5
OrderBy
ää5 <
(
ää< =
x
ää= >
=>
ää? A
x
ääB C
.
ääC D
Period
ääD J
)
ääJ K
.
ääK L
Select
ääL R
(
ääR S
x
ääS T
=>
ääU W
(
ääX Y
DateOnly
ääY a
?
ääa b
)
ääb c
x
ääc d
.
ääd e
Period
ääe k
)
ääk l
.
ääl m"
FirstOrDefaultAsyncääm Ä
(ääÄ Å
ctääÅ É
)ääÉ Ñ
;ääÑ Ö
var
ãã 
first
ãã 
=
ãã 
new
ãã 
[
ãã 
]
ãã 
{
ãã 
	firstSale
ãã %
,
ãã% &
firstPurchase
ãã' 4
}
ãã5 6
.
ãã6 7
Where
ãã7 <
(
ãã< =
x
ãã= >
=>
ãã? A
x
ããB C
is
ããD F
not
ããG J
null
ããK O
)
ããO P
.
ããP Q
Select
ããQ W
(
ããW X
x
ããX Y
=>
ããZ \
x
ãã] ^
!
ãã^ _
.
ãã_ `
Value
ãã` e
)
ããe f
.
ããf g
DefaultIfEmpty
ããg u
(
ããu v
end
ããv y
)
ããy z
.
ããz {
Min
ãã{ ~
(
ãã~ 
)ãã Ä
;ããÄ Å
var
åå 
start
åå 
=
åå 
new
åå 
DateOnly
åå  
(
åå  !
first
åå! &
.
åå& '
Year
åå' +
,
åå+ ,
first
åå- 2
.
åå2 3
Month
åå3 8
,
åå8 9
$num
åå: ;
)
åå; <
;
åå< =
if
çç 

(
çç 
start
çç 
>
çç 
end
çç 
)
çç 
start
çç 
=
çç  
end
çç! $
;
çç$ %
var
éé 
sales
éé 
=
éé 
await
éé 

SalesAsync
éé $
(
éé$ %
start
éé% *
,
éé* +
end
éé, /
.
éé/ 0
	AddMonths
éé0 9
(
éé9 :
$num
éé: ;
)
éé; <
.
éé< =
AddDays
éé= D
(
ééD E
-
ééE F
$num
ééF G
)
ééG H
,
ééH I
ct
ééJ L
)
ééL M
;
ééM N
var
èè 
	purchases
èè 
=
èè 
await
èè 
db
èè  
.
èè  !
	Purchases
èè! *
.
èè* +
Where
èè+ 0
(
èè0 1
x
èè1 2
=>
èè3 5
x
èè6 7
.
èè7 8
Period
èè8 >
>=
èè? A
start
èèB G
&&
èèH J
x
èèK L
.
èèL M
Period
èèM S
<=
èèT V
end
èèW Z
)
èèZ [
.
èè[ \
ToListAsync
èè\ g
(
èèg h
ct
èèh j
)
èèj k
;
èèk l
var
ëë 
settings
ëë 
=
ëë 
await
ëë 
TaxSettingsRow
ëë +
(
ëë+ ,
ct
ëë, .
)
ëë. /
;
ëë/ 0
var
íí 
form1662
íí 
=
íí 
settings
íí 
.
íí  
Use1662AsCredit
íí  /
?
ìì 
(
ìì 
await
ìì 
db
ìì 
.
ìì 
Expenses
ìì  
.
ìì  !
Where
ìì! &
(
ìì& '
x
ìì' (
=>
ìì) +
x
ìì, -
.
ìì- .#
IsNonDomiciledService
ìì. C
&&
ììD F
x
ììG H
.
ììH I
Form1662PaidAt
ììI W
!=
ììX Z
null
ìì[ _
&&
ìì` b
x
ììc d
.
ììd e
Form1662PaidAt
ììe s
>=
ììt v
start
ììw |
&&
ìì} 
xììÄ Å
.ììÅ Ç
Form1662PaidAtììÇ ê
<=ììë ì
endììî ó
.ììó ò
	AddMonthsììò °
(ìì° ¢
$numìì¢ £
)ìì£ §
.ìì§ •
AddDaysìì• ¨
(ìì¨ ≠
-ìì≠ Æ
$numììÆ Ø
)ììØ ∞
)ìì∞ ±
.ìì± ≤
ToListAsyncìì≤ Ω
(ììΩ æ
ctììæ ¿
)ìì¿ ¡
)ìì¡ ¬
.
îî 
GroupBy
îî 
(
îî 
x
îî 
=>
îî 
new
îî !
DateOnly
îî" *
(
îî* +
x
îî+ ,
.
îî, -
Form1662PaidAt
îî- ;
!
îî; <
.
îî< =
Value
îî= B
.
îîB C
Year
îîC G
,
îîG H
x
îîI J
.
îîJ K
Form1662PaidAt
îîK Y
.
îîY Z
Value
îîZ _
.
îî_ `
Month
îî` e
,
îîe f
$num
îîg h
)
îîh i
)
îîi j
.
îîj k
ToDictionary
îîk w
(
îîw x
g
îîx y
=>
îîz |
g
îî} ~
.
îî~ 
Keyîî Ç
,îîÇ É
gîîÑ Ö
=>îîÜ à
gîîâ ä
.îîä ã
Sumîîã é
(îîé è
xîîè ê
=>îîë ì
Form1662îîî ú
.îîú ù
Igvîîù †
(îî† °
xîî° ¢
,îî¢ £
settingsîî§ ¨
.îî¨ ≠
IgvRateîî≠ ¥
)îî¥ µ
)îîµ ∂
)îî∂ ∑
:
ïï 
[
ïï 
]
ïï 
;
ïï 
var
ññ 
months
ññ 
=
ññ 
new
ññ 
List
ññ 
<
ññ 
IgvMonth
ññ &
>
ññ& '
(
ññ' (
)
ññ( )
;
ññ) *
var
ññ+ .
carry
ññ/ 4
=
ññ5 6
$num
ññ7 9
;
ññ9 :
for
óó 
(
óó 
var
óó 
month
óó 
=
óó 
start
óó 
;
óó 
month
óó  %
<=
óó& (
end
óó) ,
;
óó, -
month
óó. 3
=
óó4 5
month
óó6 ;
.
óó; <
	AddMonths
óó< E
(
óóE F
$num
óóF G
)
óóG H
)
óóH I
{
òò 	
var
ôô 
monthEnd
ôô 
=
ôô 
month
ôô  
.
ôô  !
	AddMonths
ôô! *
(
ôô* +
$num
ôô+ ,
)
ôô, -
.
ôô- .
AddDays
ôô. 5
(
ôô5 6
-
ôô6 7
$num
ôô7 8
)
ôô8 9
;
ôô9 :
var
öö 
debito
öö 
=
öö 
sales
öö 
.
öö 
Where
öö $
(
öö$ %
x
öö% &
=>
öö' )
x
öö* +
.
öö+ ,
Date
öö, 0
>=
öö1 3
month
öö4 9
&&
öö: <
x
öö= >
.
öö> ?
Date
öö? C
<=
ööD F
monthEnd
ööG O
)
ööO P
.
ööP Q
Sum
ööQ T
(
ööT U
x
ööU V
=>
ööW Y
x
ööZ [
.
öö[ \
IgvPen
öö\ b
)
ööb c
;
ööc d
var
õõ 
credito
õõ 
=
õõ 
	purchases
õõ #
.
õõ# $
Where
õõ$ )
(
õõ) *
x
õõ* +
=>
õõ, .
x
õõ/ 0
.
õõ0 1
Period
õõ1 7
==
õõ8 :
month
õõ; @
)
õõ@ A
.
õõA B
Sum
õõB E
(
õõE F
x
õõF G
=>
õõH J
x
õõK L
.
õõL M
TaxCreditPen
õõM Y
)
õõY Z
+
õõ[ \
form1662
õõ] e
.
õõe f
GetValueOrDefault
õõf w
(
õõw x
month
õõx }
)
õõ} ~
;
õõ~ 
var
úú 
result
úú 
=
úú 
debito
úú 
-
úú  !
credito
úú" )
-
úú* +
carry
úú, 1
;
úú1 2
months
ùù 
.
ùù 
Add
ùù 
(
ùù 
new
ùù 
IgvMonth
ùù #
(
ùù# $
month
ùù$ )
,
ùù) *
debito
ùù+ 1
,
ùù1 2
credito
ùù3 :
,
ùù: ;
carry
ùù< A
,
ùùA B
Math
ùùC G
.
ùùG H
Max
ùùH K
(
ùùK L
result
ùùL R
,
ùùR S
$num
ùùT V
)
ùùV W
,
ùùW X
Math
ùùY ]
.
ùù] ^
Max
ùù^ a
(
ùùa b
-
ùùb c
result
ùùc i
,
ùùi j
$num
ùùk m
)
ùùm n
)
ùùn o
)
ùùo p
;
ùùp q
carry
ûû 
=
ûû 
Math
ûû 
.
ûû 
Max
ûû 
(
ûû 
-
ûû 
result
ûû $
,
ûû$ %
$num
ûû& (
)
ûû( )
;
ûû) *
}
üü 	
return
†† 
months
†† 
;
†† 
}
°° 
[
££ 
HttpGet
££ 
(
££ 
$str
££ 
)
££  
]
££  !
public
§§ 

async
§§ 
Task
§§ 
<
§§ 
ActionResult
§§ "
>
§§" #
ExpensesReport
§§$ 2
(
§§2 3
int
§§3 6
?
§§6 7
month
§§8 =
,
§§= >
int
§§? B
year
§§C G
,
§§G H
CancellationToken
§§I Z
ct
§§[ ]
)
§§] ^
{
•• 
var
¶¶ 
(
¶¶ 
from
¶¶ 
,
¶¶ 
to
¶¶ 
)
¶¶ 
=
¶¶ 
Period
¶¶ 
(
¶¶  
month
¶¶  %
,
¶¶% &
year
¶¶' +
)
¶¶+ ,
;
¶¶, -
var
ßß 
expenses
ßß 
=
ßß 
await
ßß 
db
ßß 
.
ßß  
Expenses
ßß  (
.
ßß( )
Include
ßß) 0
(
ßß0 1
x
ßß1 2
=>
ßß3 5
x
ßß6 7
.
ßß7 8
Category
ßß8 @
)
ßß@ A
.
ßßA B
Where
ßßB G
(
ßßG H
x
ßßH I
=>
ßßJ L
x
ßßM N
.
ßßN O
Date
ßßO S
>=
ßßT V
from
ßßW [
&&
ßß\ ^
x
ßß_ `
.
ßß` a
Date
ßßa e
<=
ßßf h
to
ßßi k
)
ßßk l
.
ßßl m
ToListAsync
ßßm x
(
ßßx y
ct
ßßy {
)
ßß{ |
;
ßß| }
return
®® 
Ok
®® 
(
®® 
new
®® 
{
®® 
total
®® 
=
®® 
Math
®®  $
.
®®$ %
Round
®®% *
(
®®* +
expenses
®®+ 3
.
®®3 4
Sum
®®4 7
(
®®7 8
x
®®8 9
=>
®®: <
x
®®= >
.
®®> ?
	AmountPen
®®? H
)
®®H I
,
®®I J
$num
®®K L
)
®®L M
,
®®M N
porCategoria
®®O [
=
®®\ ]
expenses
®®^ f
.
®®f g
GroupBy
®®g n
(
®®n o
x
®®o p
=>
®®q s
x
®®t u
.
®®u v
Category
®®v ~
?
®®~ 
.®® Ä
Name®®Ä Ñ
??®®Ö á
$str®®à ó
)®®ó ò
.®®ò ô!
OrderByDescending®®ô ™
(®®™ ´
g®®´ ¨
=>®®≠ Ø
g®®∞ ±
.®®± ≤
Sum®®≤ µ
(®®µ ∂
x®®∂ ∑
=>®®∏ ∫
x®®ª º
.®®º Ω
	AmountPen®®Ω ∆
)®®∆ «
)®®« »
.®®» …
Select®®… œ
(®®œ –
g®®– —
=>®®“ ‘
new®®’ ÿ
{®®Ÿ ⁄
	categoria®®€ ‰
=®®Â Ê
g®®Á Ë
.®®Ë È
Key®®È Ï
,®®Ï Ì
monto®®Ó Û
=®®Ù ı
Math®®ˆ ˙
.®®˙ ˚
Round®®˚ Ä
(®®Ä Å
g®®Å Ç
.®®Ç É
Sum®®É Ü
(®®Ü á
x®®á à
=>®®â ã
x®®å ç
.®®ç é
	AmountPen®®é ó
)®®ó ò
,®®ò ô
$num®®ö õ
)®®õ ú
}®®ù û
)®®û ü
}®®† °
)®®° ¢
;®®¢ £
}
©© 
[
∞∞ 
HttpGet
∞∞ 
(
∞∞ 
$str
∞∞ 
)
∞∞ 
]
∞∞ 
public
±± 

async
±± 
Task
±± 
<
±± 
ActionResult
±± "
>
±±" #
	NetReport
±±$ -
(
±±- .
int
±±. 1
?
±±1 2
month
±±3 8
,
±±8 9
int
±±: =
year
±±> B
,
±±B C
CancellationToken
±±D U
ct
±±V X
)
±±X Y
{
≤≤ 
var
≥≥ 
settings
≥≥ 
=
≥≥ 
await
≥≥ 
TaxSettingsRow
≥≥ +
(
≥≥+ ,
ct
≥≥, .
)
≥≥. /
;
≥≥/ 0
var
¥¥ 
(
¥¥ 
from
¥¥ 
,
¥¥ 
to
¥¥ 
)
¥¥ 
=
¥¥ 
Period
¥¥ 
(
¥¥  
month
¥¥  %
,
¥¥% &
year
¥¥' +
)
¥¥+ ,
;
¥¥, -
var
µµ 
sales
µµ 
=
µµ 
await
µµ 

SalesAsync
µµ $
(
µµ$ %
from
µµ% )
,
µµ) *
to
µµ+ -
,
µµ- .
ct
µµ/ 1
)
µµ1 2
;
µµ2 3
var
∂∂ 
expenses
∂∂ 
=
∂∂ 
await
∂∂ 
db
∂∂ 
.
∂∂  
Expenses
∂∂  (
.
∂∂( )
Include
∂∂) 0
(
∂∂0 1
x
∂∂1 2
=>
∂∂3 5
x
∂∂6 7
.
∂∂7 8
Category
∂∂8 @
)
∂∂@ A
.
∂∂A B
Where
∂∂B G
(
∂∂G H
x
∂∂H I
=>
∂∂J L
x
∂∂M N
.
∂∂N O
Date
∂∂O S
>=
∂∂T V
from
∂∂W [
&&
∂∂\ ^
x
∂∂_ `
.
∂∂` a
Date
∂∂a e
<=
∂∂f h
to
∂∂i k
)
∂∂k l
.
∂∂l m
ToListAsync
∂∂m x
(
∂∂x y
ct
∂∂y {
)
∂∂{ |
;
∂∂| }
var
∑∑ 
result
∑∑ 
=
∑∑ 

NetFigures
∑∑ 
(
∑∑  
sales
∑∑  %
,
∑∑% &
expenses
∑∑' /
,
∑∑/ 0
settings
∑∑1 9
.
∑∑9 :
	RentaRate
∑∑: C
)
∑∑C D
;
∑∑D E
var
∏∏ 
serie
∏∏ 
=
∏∏ 

Enumerable
∏∏ 
.
∏∏ 
Range
∏∏ $
(
∏∏$ %
$num
∏∏% &
,
∏∏& '
month
∏∏( -
is
∏∏. 0
null
∏∏1 5
?
∏∏6 7
$num
∏∏8 :
:
∏∏; <
$num
∏∏= >
)
∏∏> ?
.
∏∏? @
Select
∏∏@ F
(
∏∏F G
i
∏∏G H
=>
∏∏I K
from
∏∏L P
.
∏∏P Q
	AddMonths
∏∏Q Z
(
∏∏Z [
i
∏∏[ \
)
∏∏\ ]
)
∏∏] ^
.
∏∏^ _
Select
∏∏_ e
(
∏∏e f
start
∏∏f k
=>
∏∏l n
{
ππ 	
var
∫∫ 
end
∫∫ 
=
∫∫ 
start
∫∫ 
.
∫∫ 
	AddMonths
∫∫ %
(
∫∫% &
$num
∫∫& '
)
∫∫' (
.
∫∫( )
AddDays
∫∫) 0
(
∫∫0 1
-
∫∫1 2
$num
∫∫2 3
)
∫∫3 4
;
∫∫4 5
var
ªª 
n
ªª 
=
ªª 

NetFigures
ªª 
(
ªª 
sales
ªª $
.
ªª$ %
Where
ªª% *
(
ªª* +
x
ªª+ ,
=>
ªª- /
x
ªª0 1
.
ªª1 2
Date
ªª2 6
>=
ªª7 9
start
ªª: ?
&&
ªª@ B
x
ªªC D
.
ªªD E
Date
ªªE I
<=
ªªJ L
end
ªªM P
)
ªªP Q
,
ªªQ R
expenses
ªªS [
.
ªª[ \
Where
ªª\ a
(
ªªa b
x
ªªb c
=>
ªªd f
x
ªªg h
.
ªªh i
Date
ªªi m
>=
ªªn p
start
ªªq v
&&
ªªw y
x
ªªz {
.
ªª{ |
Dateªª| Ä
<=ªªÅ É
endªªÑ á
)ªªá à
,ªªà â
settingsªªä í
.ªªí ì
	RentaRateªªì ú
)ªªú ù
;ªªù û
return
ºº 
new
ºº 
NetPoint
ºº 
(
ºº  
start
ºº  %
.
ºº% &
ToString
ºº& .
(
ºº. /
$str
ºº/ 8
)
ºº8 9
,
ºº9 :
Math
ºº; ?
.
ºº? @
Round
ºº@ E
(
ººE F
n
ººF G
.
ººG H
Ventas
ººH N
,
ººN O
$num
ººP Q
)
ººQ R
,
ººR S
Math
ººT X
.
ººX Y
Round
ººY ^
(
ºº^ _
n
ºº_ `
.
ºº` a
Gastos
ººa g
,
ººg h
$num
ººi j
)
ººj k
,
ººk l
Math
ººm q
.
ººq r
Round
ººr w
(
ººw x
n
ººx y
.
ººy z
	Impuestosººz É
,ººÉ Ñ
$numººÖ Ü
)ººÜ á
,ººá à
Mathººâ ç
.ººç é
Roundººé ì
(ººì î
nººî ï
.ººï ñ
Netaººñ ö
,ººö õ
$numººú ù
)ººù û
)ººû ü
;ººü †
}
ΩΩ 	
)
ΩΩ	 

.
ΩΩ
 
ToList
ΩΩ 
(
ΩΩ 
)
ΩΩ 
;
ΩΩ 
return
ææ 
Ok
ææ 
(
ææ 
new
ææ 
{
øø 	
	ventasPen
¿¿ 
=
¿¿ 
Math
¿¿ 
.
¿¿ 
Round
¿¿ "
(
¿¿" #
result
¿¿# )
.
¿¿) *
Ventas
¿¿* 0
,
¿¿0 1
$num
¿¿2 3
)
¿¿3 4
,
¿¿4 5
	gastosPen
¿¿6 ?
=
¿¿@ A
Math
¿¿B F
.
¿¿F G
Round
¿¿G L
(
¿¿L M
result
¿¿M S
.
¿¿S T
Gastos
¿¿T Z
,
¿¿Z [
$num
¿¿\ ]
)
¿¿] ^
,
¿¿^ _"
utilidadOperativaPen
¿¿` t
=
¿¿u v
Math
¿¿w {
.
¿¿{ |
Round¿¿| Å
(¿¿Å Ç
result¿¿Ç à
.¿¿à â
Ventas¿¿â è
-¿¿ê ë
result¿¿í ò
.¿¿ò ô
Gastos¿¿ô ü
,¿¿ü †
$num¿¿° ¢
)¿¿¢ £
,¿¿£ §
	rentaRate
¡¡ 
=
¡¡ 
settings
¡¡  
.
¡¡  !
	RentaRate
¡¡! *
,
¡¡* +
impuestosPen
¡¡, 8
=
¡¡9 :
Math
¡¡; ?
.
¡¡? @
Round
¡¡@ E
(
¡¡E F
result
¡¡F L
.
¡¡L M
	Impuestos
¡¡M V
,
¡¡V W
$num
¡¡X Y
)
¡¡Y Z
,
¡¡Z [
utilidadNetaPen
¬¬ 
=
¬¬ 
Math
¬¬ "
.
¬¬" #
Round
¬¬# (
(
¬¬( )
result
¬¬) /
.
¬¬/ 0
Neta
¬¬0 4
,
¬¬4 5
$num
¬¬6 7
)
¬¬7 8
,
¬¬8 9
margen
¬¬: @
=
¬¬A B
result
¬¬C I
.
¬¬I J
Ventas
¬¬J P
==
¬¬Q S
$num
¬¬T U
?
¬¬V W
$num
¬¬X Z
:
¬¬[ \
Math
¬¬] a
.
¬¬a b
Round
¬¬b g
(
¬¬g h
result
¬¬h n
.
¬¬n o
Neta
¬¬o s
/
¬¬t u
result
¬¬v |
.
¬¬| }
Ventas¬¬} É
*¬¬Ñ Ö
$num¬¬Ü â
,¬¬â ä
$num¬¬ã å
)¬¬å ç
,¬¬ç é
serie
√√ 
,
√√ 

disclaimer
√√ 
=
√√ 
TaxDisclaimer
√√  -
,
√√- .
}
ƒƒ 	
)
ƒƒ	 

;
ƒƒ
 
}
≈≈ 
private
«« 
sealed
«« 
record
«« 
NetPoint
«« "
(
««" #
string
««# )
Mes
««* -
,
««- .
decimal
««/ 6
	VentasPen
««7 @
,
««@ A
decimal
««B I
	GastosPen
««J S
,
««S T
decimal
««U \
ImpuestosPen
««] i
,
««i j
decimal
««k r
UtilidadNetaPen««s Ç
)««Ç É
;««É Ñ
private
   
static
   
(
   
decimal
   
Ventas
   "
,
  " #
decimal
  $ +
Gastos
  , 2
,
  2 3
decimal
  4 ;
	Impuestos
  < E
,
  E F
decimal
  G N
Neta
  O S
)
  S T

NetFigures
  U _
(
  _ `
IEnumerable
  ` k
<
  k l
Sale
  l p
>
  p q
sales
  r w
,
  w x
IEnumerable  y Ñ
<  Ñ Ö
Expense  Ö å
>  å ç
expenses  é ñ
,  ñ ó
decimal  ò ü
	rentaRate  † ©
)  © ™
{
ÀÀ 
var
ÃÃ 
ventas
ÃÃ 
=
ÃÃ 
sales
ÃÃ 
.
ÃÃ 
Sum
ÃÃ 
(
ÃÃ 
x
ÃÃ  
=>
ÃÃ! #
x
ÃÃ$ %
.
ÃÃ% &
BasePen
ÃÃ& -
)
ÃÃ- .
;
ÃÃ. /
var
ÕÕ 
gastos
ÕÕ 
=
ÕÕ 
expenses
ÕÕ 
.
ÕÕ 
Where
ÕÕ #
(
ÕÕ# $
x
ÕÕ$ %
=>
ÕÕ& (
x
ÕÕ) *
.
ÕÕ* +
Category
ÕÕ+ 3
?
ÕÕ3 4
.
ÕÕ4 5
IsIncomeTax
ÕÕ5 @
!=
ÕÕA C
true
ÕÕD H
)
ÕÕH I
.
ÕÕI J
Sum
ÕÕJ M
(
ÕÕM N
x
ÕÕN O
=>
ÕÕP R
x
ÕÕS T
.
ÕÕT U
	AmountPen
ÕÕU ^
)
ÕÕ^ _
;
ÕÕ_ `
var
ŒŒ 
	impuestos
ŒŒ 
=
ŒŒ 
sales
ŒŒ 
.
ŒŒ 
Where
ŒŒ #
(
ŒŒ# $
x
ŒŒ$ %
=>
ŒŒ& (
x
ŒŒ) *
.
ŒŒ* +
Mype
ŒŒ+ /
)
ŒŒ/ 0
.
ŒŒ0 1
Sum
ŒŒ1 4
(
ŒŒ4 5
x
ŒŒ5 6
=>
ŒŒ7 9
x
ŒŒ: ;
.
ŒŒ; <
BasePen
ŒŒ< C
)
ŒŒC D
*
ŒŒE F
	rentaRate
ŒŒG P
;
ŒŒP Q
return
œœ 
(
œœ 
ventas
œœ 
,
œœ 
gastos
œœ 
,
œœ 
	impuestos
œœ  )
,
œœ) *
ventas
œœ+ 1
-
œœ2 3
gastos
œœ4 :
-
œœ; <
	impuestos
œœ= F
)
œœF G
;
œœG H
}
–– 
[
”” 
HttpGet
”” 
(
”” 
$str
”” 
)
”” 
]
””  
public
‘‘ 

async
‘‘ 
Task
‘‘ 
<
‘‘ 
ActionResult
‘‘ "
>
‘‘" #
ClientsReport
‘‘$ 1
(
‘‘1 2
int
‘‘2 5
?
‘‘5 6
month
‘‘7 <
,
‘‘< =
int
‘‘> A
year
‘‘B F
,
‘‘F G
CancellationToken
‘‘H Y
ct
‘‘Z \
)
‘‘\ ]
{
’’ 
var
÷÷ 
(
÷÷ 
total
÷÷ 
,
÷÷ 
clientes
÷÷ 
)
÷÷ 
=
÷÷ 
await
÷÷  % 
ClientRankingAsync
÷÷& 8
(
÷÷8 9
month
÷÷9 >
,
÷÷> ?
year
÷÷@ D
,
÷÷D E
ct
÷÷F H
)
÷÷H I
;
÷÷I J
return
◊◊ 
Ok
◊◊ 
(
◊◊ 
new
◊◊ 
{
◊◊ 
totalPen
◊◊  
=
◊◊! "
total
◊◊# (
,
◊◊( )
clientes
◊◊* 2
}
◊◊3 4
)
◊◊4 5
;
◊◊5 6
}
ÿÿ 
private
⁄⁄ 
sealed
⁄⁄ 
record
⁄⁄ 
ClientRankingRow
⁄⁄ *
(
⁄⁄* +
Guid
⁄⁄+ /
ClientId
⁄⁄0 8
,
⁄⁄8 9
string
⁄⁄: @

ClientName
⁄⁄A K
,
⁄⁄K L
decimal
⁄⁄M T
IngresosPen
⁄⁄U `
,
⁄⁄` a
decimal
⁄⁄b i

Porcentaje
⁄⁄j t
,
⁄⁄t u
decimal
⁄⁄v }"
PorcentajeAcumulado⁄⁄~ ë
,⁄⁄ë í
int⁄⁄ì ñ
Cobros⁄⁄ó ù
,⁄⁄ù û
DateOnly⁄⁄ü ß
UltimoCobro⁄⁄® ≥
,⁄⁄≥ ¥
decimal⁄⁄µ º"
PeriodoAnteriorPen⁄⁄Ω œ
,⁄⁄œ –
decimal⁄⁄— ÿ
?⁄⁄ÿ Ÿ#
VariacionPorcentaje⁄⁄⁄ Ì
)⁄⁄Ì Ó
;⁄⁄Ó Ô
private
‹‹ 
async
‹‹ 
Task
‹‹ 
<
‹‹ 
(
‹‹ 
decimal
‹‹ 
Total
‹‹  %
,
‹‹% &
List
‹‹' +
<
‹‹+ ,
ClientRankingRow
‹‹, <
>
‹‹< =
Rows
‹‹> B
)
‹‹B C
>
‹‹C D 
ClientRankingAsync
‹‹E W
(
‹‹W X
int
‹‹X [
?
‹‹[ \
month
‹‹] b
,
‹‹b c
int
‹‹d g
year
‹‹h l
,
‹‹l m
CancellationToken
‹‹n 
ct‹‹Ä Ç
)‹‹Ç É
{
›› 
var
ﬁﬁ 
(
ﬁﬁ 
from
ﬁﬁ 
,
ﬁﬁ 
to
ﬁﬁ 
)
ﬁﬁ 
=
ﬁﬁ 
Period
ﬁﬁ 
(
ﬁﬁ  
month
ﬁﬁ  %
,
ﬁﬁ% &
year
ﬁﬁ' +
)
ﬁﬁ+ ,
;
ﬁﬁ, -
var
ﬁﬁ. 1
(
ﬁﬁ2 3
previousFrom
ﬁﬁ3 ?
,
ﬁﬁ? @

previousTo
ﬁﬁA K
)
ﬁﬁK L
=
ﬁﬁM N
PreviousPeriod
ﬁﬁO ]
(
ﬁﬁ] ^
month
ﬁﬁ^ c
,
ﬁﬁc d
year
ﬁﬁe i
)
ﬁﬁi j
;
ﬁﬁj k
var
ﬂﬂ 
sales
ﬂﬂ 
=
ﬂﬂ 
await
ﬂﬂ 

SalesAsync
ﬂﬂ $
(
ﬂﬂ$ %
from
ﬂﬂ% )
,
ﬂﬂ) *
to
ﬂﬂ+ -
,
ﬂﬂ- .
ct
ﬂﬂ/ 1
)
ﬂﬂ1 2
;
ﬂﬂ2 3
var
‡‡ 
previous
‡‡ 
=
‡‡ 
(
‡‡ 
await
‡‡ 

SalesAsync
‡‡ (
(
‡‡( )
previousFrom
‡‡) 5
,
‡‡5 6

previousTo
‡‡7 A
,
‡‡A B
ct
‡‡C E
)
‡‡E F
)
‡‡F G
.
‡‡G H
GroupBy
‡‡H O
(
‡‡O P
x
‡‡P Q
=>
‡‡R T
x
‡‡U V
.
‡‡V W
ClientId
‡‡W _
)
‡‡_ `
.
‡‡` a
ToDictionary
‡‡a m
(
‡‡m n
g
‡‡n o
=>
‡‡p r
g
‡‡s t
.
‡‡t u
Key
‡‡u x
,
‡‡x y
g
‡‡z {
=>
‡‡| ~
g‡‡ Ä
.‡‡Ä Å
Sum‡‡Å Ñ
(‡‡Ñ Ö
x‡‡Ö Ü
=>‡‡á â
x‡‡ä ã
.‡‡ã å
BasePen‡‡å ì
)‡‡ì î
)‡‡î ï
;‡‡ï ñ
var
·· 
names
·· 
=
·· 
await
·· 
db
·· 
.
·· 
Clients
·· $
.
··$ %
ToDictionaryAsync
··% 6
(
··6 7
x
··7 8
=>
··9 ;
x
··< =
.
··= >
Id
··> @
,
··@ A
x
··B C
=>
··D F
x
··G H
.
··H I
CompanyName
··I T
,
··T U
ct
··V X
)
··X Y
;
··Y Z
var
‚‚ 
total
‚‚ 
=
‚‚ 
sales
‚‚ 
.
‚‚ 
Sum
‚‚ 
(
‚‚ 
x
‚‚ 
=>
‚‚  "
x
‚‚# $
.
‚‚$ %
BasePen
‚‚% ,
)
‚‚, -
;
‚‚- .
var
‚‚/ 2
accumulated
‚‚3 >
=
‚‚? @
$num
‚‚A C
;
‚‚C D
var
„„ 
rows
„„ 
=
„„ 
sales
„„ 
.
„„ 
GroupBy
„„  
(
„„  !
x
„„! "
=>
„„# %
x
„„& '
.
„„' (
ClientId
„„( 0
)
„„0 1
.
„„1 2
Select
„„2 8
(
„„8 9
g
„„9 :
=>
„„; =
new
„„> A
{
„„B C
ClientId
„„D L
=
„„M N
g
„„O P
.
„„P Q
Key
„„Q T
,
„„T U
Pen
„„V Y
=
„„Z [
g
„„\ ]
.
„„] ^
Sum
„„^ a
(
„„a b
x
„„b c
=>
„„d f
x
„„g h
.
„„h i
BasePen
„„i p
)
„„p q
,
„„q r
Count
„„s x
=
„„y z
g
„„{ |
.
„„| }
Count„„} Ç
(„„Ç É
)„„É Ñ
,„„Ñ Ö
Last„„Ü ä
=„„ã å
g„„ç é
.„„é è
Max„„è í
(„„í ì
x„„ì î
=>„„ï ó
x„„ò ô
.„„ô ö
Date„„ö û
)„„û ü
}„„† °
)„„° ¢
.„„¢ £!
OrderByDescending„„£ ¥
(„„¥ µ
x„„µ ∂
=>„„∑ π
x„„∫ ª
.„„ª º
Pen„„º ø
)„„ø ¿
.„„¿ ¡
Select„„¡ «
(„„« »
x„„» …
=>„„  Ã
{
‰‰ 	
accumulated
ÂÂ 
+=
ÂÂ 
x
ÂÂ 
.
ÂÂ 
Pen
ÂÂ  
;
ÂÂ  !
var
ÊÊ 
before
ÊÊ 
=
ÊÊ 
previous
ÊÊ !
.
ÊÊ! "
GetValueOrDefault
ÊÊ" 3
(
ÊÊ3 4
x
ÊÊ4 5
.
ÊÊ5 6
ClientId
ÊÊ6 >
)
ÊÊ> ?
;
ÊÊ? @
return
ÁÁ 
new
ÁÁ 
ClientRankingRow
ÁÁ '
(
ÁÁ' (
x
ÁÁ( )
.
ÁÁ) *
ClientId
ÁÁ* 2
,
ÁÁ2 3
names
ÁÁ4 9
.
ÁÁ9 :
GetValueOrDefault
ÁÁ: K
(
ÁÁK L
x
ÁÁL M
.
ÁÁM N
ClientId
ÁÁN V
)
ÁÁV W
??
ÁÁX Z
$str
ÁÁ[ p
,
ÁÁp q
Math
ÁÁr v
.
ÁÁv w
Round
ÁÁw |
(
ÁÁ| }
x
ÁÁ} ~
.
ÁÁ~ 
PenÁÁ Ç
,ÁÁÇ É
$numÁÁÑ Ö
)ÁÁÖ Ü
,ÁÁÜ á
totalÁÁà ç
==ÁÁé ê
$numÁÁë í
?ÁÁì î
$numÁÁï ñ
:ÁÁó ò
MathÁÁô ù
.ÁÁù û
RoundÁÁû £
(ÁÁ£ §
xÁÁ§ •
.ÁÁ• ¶
PenÁÁ¶ ©
/ÁÁ™ ´
totalÁÁ¨ ±
*ÁÁ≤ ≥
$numÁÁ¥ ∑
,ÁÁ∑ ∏
$numÁÁπ ∫
)ÁÁ∫ ª
,ÁÁª º
totalÁÁΩ ¬
==ÁÁ√ ≈
$numÁÁ∆ «
?ÁÁ» …
$numÁÁ  À
:ÁÁÃ Õ
MathÁÁŒ “
.ÁÁ“ ”
RoundÁÁ” ÿ
(ÁÁÿ Ÿ
accumulatedÁÁŸ ‰
/ÁÁÂ Ê
totalÁÁÁ Ï
*ÁÁÌ Ó
$numÁÁÔ Ú
,ÁÁÚ Û
$numÁÁÙ ı
)ÁÁı ˆ
,ÁÁˆ ˜
xÁÁ¯ ˘
.ÁÁ˘ ˙
CountÁÁ˙ ˇ
,ÁÁˇ Ä
xÁÁÅ Ç
.ÁÁÇ É
LastÁÁÉ á
,ÁÁá à
MathÁÁâ ç
.ÁÁç é
RoundÁÁé ì
(ÁÁì î
beforeÁÁî ö
,ÁÁö õ
$numÁÁú ù
)ÁÁù û
,ÁÁû ü
beforeÁÁ† ¶
>ÁÁß ®
$numÁÁ© ™
?ÁÁ´ ¨
MathÁÁ≠ ±
.ÁÁ± ≤
RoundÁÁ≤ ∑
(ÁÁ∑ ∏
(ÁÁ∏ π
xÁÁπ ∫
.ÁÁ∫ ª
PenÁÁª æ
-ÁÁø ¿
beforeÁÁ¡ «
)ÁÁ« »
/ÁÁ…  
beforeÁÁÀ —
*ÁÁ“ ”
$numÁÁ‘ ◊
,ÁÁ◊ ÿ
$numÁÁŸ ⁄
)ÁÁ⁄ €
:ÁÁ‹ ›
nullÁÁﬁ ‚
)ÁÁ‚ „
;ÁÁ„ ‰
}
ËË 	
)
ËË	 

.
ËË
 
ToList
ËË 
(
ËË 
)
ËË 
;
ËË 
return
ÈÈ 
(
ÈÈ 
Math
ÈÈ 
.
ÈÈ 
Round
ÈÈ 
(
ÈÈ 
total
ÈÈ  
,
ÈÈ  !
$num
ÈÈ" #
)
ÈÈ# $
,
ÈÈ$ %
rows
ÈÈ& *
)
ÈÈ* +
;
ÈÈ+ ,
}
ÍÍ 
[
ÌÌ 
HttpGet
ÌÌ 
(
ÌÌ 
$str
ÌÌ 
)
ÌÌ 
]
ÌÌ 
public
ÓÓ 

async
ÓÓ 
Task
ÓÓ 
<
ÓÓ 
IActionResult
ÓÓ #
>
ÓÓ# $
ExportReport
ÓÓ% 1
(
ÓÓ1 2
int
ÓÓ2 5
?
ÓÓ5 6
month
ÓÓ7 <
,
ÓÓ< =
int
ÓÓ> A
year
ÓÓB F
,
ÓÓF G
CancellationToken
ÓÓH Y
ct
ÓÓZ \
)
ÓÓ\ ]
{
ÔÔ 
var
 
settings
 
=
 
await
 
TaxSettingsRow
 +
(
+ ,
ct
, .
)
. /
;
/ 0
var
ÒÒ 
(
ÒÒ 
from
ÒÒ 
,
ÒÒ 
to
ÒÒ 
)
ÒÒ 
=
ÒÒ 
Period
ÒÒ 
(
ÒÒ  
month
ÒÒ  %
,
ÒÒ% &
year
ÒÒ' +
)
ÒÒ+ ,
;
ÒÒ, -
var
ÚÚ 
sales
ÚÚ 
=
ÚÚ 
await
ÚÚ 

SalesAsync
ÚÚ $
(
ÚÚ$ %
from
ÚÚ% )
,
ÚÚ) *
to
ÚÚ+ -
,
ÚÚ- .
ct
ÚÚ/ 1
)
ÚÚ1 2
;
ÚÚ2 3
var
ÛÛ 
expenses
ÛÛ 
=
ÛÛ 
await
ÛÛ 
db
ÛÛ 
.
ÛÛ  
Expenses
ÛÛ  (
.
ÛÛ( )
Include
ÛÛ) 0
(
ÛÛ0 1
x
ÛÛ1 2
=>
ÛÛ3 5
x
ÛÛ6 7
.
ÛÛ7 8
Category
ÛÛ8 @
)
ÛÛ@ A
.
ÛÛA B
Where
ÛÛB G
(
ÛÛG H
x
ÛÛH I
=>
ÛÛJ L
x
ÛÛM N
.
ÛÛN O
Date
ÛÛO S
>=
ÛÛT V
from
ÛÛW [
&&
ÛÛ\ ^
x
ÛÛ_ `
.
ÛÛ` a
Date
ÛÛa e
<=
ÛÛf h
to
ÛÛi k
)
ÛÛk l
.
ÛÛl m
ToListAsync
ÛÛm x
(
ÛÛx y
ct
ÛÛy {
)
ÛÛ{ |
;
ÛÛ| }
var
ÙÙ 
net
ÙÙ 
=
ÙÙ 

NetFigures
ÙÙ 
(
ÙÙ 
sales
ÙÙ "
,
ÙÙ" #
expenses
ÙÙ$ ,
,
ÙÙ, -
settings
ÙÙ. 6
.
ÙÙ6 7
	RentaRate
ÙÙ7 @
)
ÙÙ@ A
;
ÙÙA B
var
ıı 
(
ıı 
_
ıı 
,
ıı 
ranking
ıı 
)
ıı 
=
ıı 
await
ıı   
ClientRankingAsync
ıı! 3
(
ıı3 4
month
ıı4 9
,
ıı9 :
year
ıı; ?
,
ıı? @
ct
ııA C
)
ııC D
;
ııD E
using
˜˜ 
var
˜˜ 
book
˜˜ 
=
˜˜ 
new
˜˜ 

XLWorkbook
˜˜ '
(
˜˜' (
)
˜˜( )
;
˜˜) *
var
¯¯ 
summary
¯¯ 
=
¯¯ 
book
¯¯ 
.
¯¯ 
AddWorksheet
¯¯ '
(
¯¯' (
$str
¯¯( 2
)
¯¯2 3
;
¯¯3 4
(
˘˘ 	
string
˘˘	 
Label
˘˘ 
,
˘˘ 
decimal
˘˘ 
Value
˘˘ $
)
˘˘$ %
[
˘˘% &
]
˘˘& '
figures
˘˘( /
=
˘˘0 1
[
˘˘2 3
(
˘˘3 4
$str
˘˘4 J
,
˘˘J K
net
˘˘L O
.
˘˘O P
Ventas
˘˘P V
)
˘˘V W
,
˘˘W X
(
˘˘Y Z
$str
˘˘Z s
,
˘˘s t
net
˘˘u x
.
˘˘x y
Gastos
˘˘y 
)˘˘ Ä
,˘˘Ä Å
(˘˘Ç É
$str˘˘É ù
,˘˘ù û
net˘˘ü ¢
.˘˘¢ £
Ventas˘˘£ ©
-˘˘™ ´
net˘˘¨ Ø
.˘˘Ø ∞
Gastos˘˘∞ ∂
)˘˘∂ ∑
,˘˘∑ ∏
(˘˘π ∫
$"˘˘∫ º
$str˘˘º —
{˘˘— “
settings˘˘“ ⁄
.˘˘⁄ €
	RentaRate˘˘€ ‰
*˘˘Â Ê
$num˘˘Á Í
:˘˘Í Î
$str˘˘Î Ô
}˘˘Ô 
$str˘˘ ¯
"˘˘¯ ˘
,˘˘˘ ˙
net˘˘˚ ˛
.˘˘˛ ˇ
	Impuestos˘˘ˇ à
)˘˘à â
,˘˘â ä
(˘˘ã å
$str˘˘å °
,˘˘° ¢
net˘˘£ ¶
.˘˘¶ ß
Neta˘˘ß ´
)˘˘´ ¨
,˘˘¨ ≠
(˘˘Æ Ø
$str˘˘Ø æ
,˘˘æ ø
net˘˘¿ √
.˘˘√ ƒ
Ventas˘˘ƒ  
==˘˘À Õ
$num˘˘Œ œ
?˘˘– —
$num˘˘“ ”
:˘˘‘ ’
net˘˘÷ Ÿ
.˘˘Ÿ ⁄
Neta˘˘⁄ ﬁ
/˘˘ﬂ ‡
net˘˘· ‰
.˘˘‰ Â
Ventas˘˘Â Î
*˘˘Ï Ì
$num˘˘Ó Ò
)˘˘Ò Ú
]˘˘Ú Û
;˘˘Û Ù
for
˙˙ 
(
˙˙ 
var
˙˙ 
i
˙˙ 
=
˙˙ 
$num
˙˙ 
;
˙˙ 
i
˙˙ 
<
˙˙ 
figures
˙˙ #
.
˙˙# $
Length
˙˙$ *
;
˙˙* +
i
˙˙, -
++
˙˙- /
)
˙˙/ 0
{
˙˙1 2
summary
˙˙3 :
.
˙˙: ;
Cell
˙˙; ?
(
˙˙? @
i
˙˙@ A
+
˙˙B C
$num
˙˙D E
,
˙˙E F
$num
˙˙G H
)
˙˙H I
.
˙˙I J
Value
˙˙J O
=
˙˙P Q
figures
˙˙R Y
[
˙˙Y Z
i
˙˙Z [
]
˙˙[ \
.
˙˙\ ]
Label
˙˙] b
;
˙˙b c
summary
˙˙d k
.
˙˙k l
Cell
˙˙l p
(
˙˙p q
i
˙˙q r
+
˙˙s t
$num
˙˙u v
,
˙˙v w
$num
˙˙x y
)
˙˙y z
.
˙˙z {
Value˙˙{ Ä
=˙˙Å Ç
Math˙˙É á
.˙˙á à
Round˙˙à ç
(˙˙ç é
figures˙˙é ï
[˙˙ï ñ
i˙˙ñ ó
]˙˙ó ò
.˙˙ò ô
Value˙˙ô û
,˙˙û ü
$num˙˙† °
)˙˙° ¢
;˙˙¢ £
}˙˙§ •
var
˚˚ 
row
˚˚ 
=
˚˚ 
figures
˚˚ 
.
˚˚ 
Length
˚˚  
+
˚˚! "
$num
˚˚# $
;
˚˚$ %
string
¸¸ 
[
¸¸ 
]
¸¸ 
header
¸¸ 
=
¸¸ 
[
¸¸ 
$str
¸¸  
,
¸¸  !
$str
¸¸" *
,
¸¸* +
$str
¸¸, 4
,
¸¸4 5
$str
¸¸6 =
,
¸¸= >
$str
¸¸? N
]
¸¸N O
;
¸¸O P
for
˝˝ 
(
˝˝ 
var
˝˝ 
c
˝˝ 
=
˝˝ 
$num
˝˝ 
;
˝˝ 
c
˝˝ 
<
˝˝ 
header
˝˝ "
.
˝˝" #
Length
˝˝# )
;
˝˝) *
c
˝˝+ ,
++
˝˝, .
)
˝˝. /
summary
˝˝0 7
.
˝˝7 8
Cell
˝˝8 <
(
˝˝< =
row
˝˝= @
,
˝˝@ A
c
˝˝B C
+
˝˝D E
$num
˝˝F G
)
˝˝G H
.
˝˝H I
Value
˝˝I N
=
˝˝O P
header
˝˝Q W
[
˝˝W X
c
˝˝X Y
]
˝˝Y Z
;
˝˝Z [
foreach
˛˛ 
(
˛˛ 
var
˛˛ 
start
˛˛ 
in
˛˛ 

Enumerable
˛˛ (
.
˛˛( )
Range
˛˛) .
(
˛˛. /
$num
˛˛/ 0
,
˛˛0 1
month
˛˛2 7
is
˛˛8 :
null
˛˛; ?
?
˛˛@ A
$num
˛˛B D
:
˛˛E F
$num
˛˛G H
)
˛˛H I
.
˛˛I J
Select
˛˛J P
(
˛˛P Q
i
˛˛Q R
=>
˛˛S U
from
˛˛V Z
.
˛˛Z [
	AddMonths
˛˛[ d
(
˛˛d e
i
˛˛e f
)
˛˛f g
)
˛˛g h
)
˛˛h i
{
ˇˇ 	
var
ÄÄ 
end
ÄÄ 
=
ÄÄ 
start
ÄÄ 
.
ÄÄ 
	AddMonths
ÄÄ %
(
ÄÄ% &
$num
ÄÄ& '
)
ÄÄ' (
.
ÄÄ( )
AddDays
ÄÄ) 0
(
ÄÄ0 1
-
ÄÄ1 2
$num
ÄÄ2 3
)
ÄÄ3 4
;
ÄÄ4 5
var
ÅÅ 
n
ÅÅ 
=
ÅÅ 

NetFigures
ÅÅ 
(
ÅÅ 
sales
ÅÅ $
.
ÅÅ$ %
Where
ÅÅ% *
(
ÅÅ* +
x
ÅÅ+ ,
=>
ÅÅ- /
x
ÅÅ0 1
.
ÅÅ1 2
Date
ÅÅ2 6
>=
ÅÅ7 9
start
ÅÅ: ?
&&
ÅÅ@ B
x
ÅÅC D
.
ÅÅD E
Date
ÅÅE I
<=
ÅÅJ L
end
ÅÅM P
)
ÅÅP Q
,
ÅÅQ R
expenses
ÅÅS [
.
ÅÅ[ \
Where
ÅÅ\ a
(
ÅÅa b
x
ÅÅb c
=>
ÅÅd f
x
ÅÅg h
.
ÅÅh i
Date
ÅÅi m
>=
ÅÅn p
start
ÅÅq v
&&
ÅÅw y
x
ÅÅz {
.
ÅÅ{ |
DateÅÅ| Ä
<=ÅÅÅ É
endÅÅÑ á
)ÅÅá à
,ÅÅà â
settingsÅÅä í
.ÅÅí ì
	RentaRateÅÅì ú
)ÅÅú ù
;ÅÅù û
row
ÇÇ 
++
ÇÇ 
;
ÇÇ 
summary
ÇÇ 
.
ÇÇ 
Cell
ÇÇ 
(
ÇÇ  
row
ÇÇ  #
,
ÇÇ# $
$num
ÇÇ% &
)
ÇÇ& '
.
ÇÇ' (
Value
ÇÇ( -
=
ÇÇ. /
start
ÇÇ0 5
.
ÇÇ5 6
ToString
ÇÇ6 >
(
ÇÇ> ?
$str
ÇÇ? H
)
ÇÇH I
;
ÇÇI J
summary
ÉÉ 
.
ÉÉ 
Cell
ÉÉ 
(
ÉÉ 
row
ÉÉ 
,
ÉÉ 
$num
ÉÉ 
)
ÉÉ  
.
ÉÉ  !
Value
ÉÉ! &
=
ÉÉ' (
Math
ÉÉ) -
.
ÉÉ- .
Round
ÉÉ. 3
(
ÉÉ3 4
n
ÉÉ4 5
.
ÉÉ5 6
Ventas
ÉÉ6 <
,
ÉÉ< =
$num
ÉÉ> ?
)
ÉÉ? @
;
ÉÉ@ A
summary
ÉÉB I
.
ÉÉI J
Cell
ÉÉJ N
(
ÉÉN O
row
ÉÉO R
,
ÉÉR S
$num
ÉÉT U
)
ÉÉU V
.
ÉÉV W
Value
ÉÉW \
=
ÉÉ] ^
Math
ÉÉ_ c
.
ÉÉc d
Round
ÉÉd i
(
ÉÉi j
n
ÉÉj k
.
ÉÉk l
Gastos
ÉÉl r
,
ÉÉr s
$num
ÉÉt u
)
ÉÉu v
;
ÉÉv w
summary
ÉÉx 
.ÉÉ Ä
CellÉÉÄ Ñ
(ÉÉÑ Ö
rowÉÉÖ à
,ÉÉà â
$numÉÉä ã
)ÉÉã å
.ÉÉå ç
ValueÉÉç í
=ÉÉì î
MathÉÉï ô
.ÉÉô ö
RoundÉÉö ü
(ÉÉü †
nÉÉ† °
.ÉÉ° ¢
	ImpuestosÉÉ¢ ´
,ÉÉ´ ¨
$numÉÉ≠ Æ
)ÉÉÆ Ø
;ÉÉØ ∞
summaryÉÉ± ∏
.ÉÉ∏ π
CellÉÉπ Ω
(ÉÉΩ æ
rowÉÉæ ¡
,ÉÉ¡ ¬
$numÉÉ√ ƒ
)ÉÉƒ ≈
.ÉÉ≈ ∆
ValueÉÉ∆ À
=ÉÉÃ Õ
MathÉÉŒ “
.ÉÉ“ ”
RoundÉÉ” ÿ
(ÉÉÿ Ÿ
nÉÉŸ ⁄
.ÉÉ⁄ €
NetaÉÉ€ ﬂ
,ÉÉﬂ ‡
$numÉÉ· ‚
)ÉÉ‚ „
;ÉÉ„ ‰
}
ÑÑ 	
summary
ÖÖ 
.
ÖÖ 
Columns
ÖÖ 
(
ÖÖ 
)
ÖÖ 
.
ÖÖ 
AdjustToContents
ÖÖ *
(
ÖÖ* +
)
ÖÖ+ ,
;
ÖÖ, -
var
áá 
clients
áá 
=
áá 
book
áá 
.
áá 
AddWorksheet
áá '
(
áá' (
$str
áá( 2
)
áá2 3
;
áá3 4
string
àà 
[
àà 
]
àà 
clientHeader
àà 
=
àà 
[
àà  !
$str
àà! *
,
àà* +
$str
àà, D
,
ààD E
$str
ààF S
,
ààS T
$str
ààU b
,
ààb c
$str
ààd l
,
ààl m
$str
ààn |
,
àà| }
$stràà~ ñ
,ààñ ó
$strààò •
]àà• ¶
;àà¶ ß
for
ââ 
(
ââ 
var
ââ 
c
ââ 
=
ââ 
$num
ââ 
;
ââ 
c
ââ 
<
ââ 
clientHeader
ââ (
.
ââ( )
Length
ââ) /
;
ââ/ 0
c
ââ1 2
++
ââ2 4
)
ââ4 5
clients
ââ6 =
.
ââ= >
Cell
ââ> B
(
ââB C
$num
ââC D
,
ââD E
c
ââF G
+
ââH I
$num
ââJ K
)
ââK L
.
ââL M
Value
ââM R
=
ââS T
clientHeader
ââU a
[
ââa b
c
ââb c
]
ââc d
;
ââd e
var
ää 
r
ää 
=
ää 
$num
ää 
;
ää 
foreach
ãã 
(
ãã 
var
ãã 
x
ãã 
in
ãã 
ranking
ãã !
)
ãã! "
{
åå 	
r
çç 
++
çç 
;
çç 
clients
éé 
.
éé 
Cell
éé 
(
éé 
r
éé 
,
éé 
$num
éé 
)
éé 
.
éé 
Value
éé $
=
éé% &
x
éé' (
.
éé( )

ClientName
éé) 3
;
éé3 4
clients
éé5 <
.
éé< =
Cell
éé= A
(
ééA B
r
ééB C
,
ééC D
$num
ééE F
)
ééF G
.
ééG H
Value
ééH M
=
ééN O
x
ééP Q
.
ééQ R
IngresosPen
ééR ]
;
éé] ^
clients
éé_ f
.
ééf g
Cell
éég k
(
éék l
r
éél m
,
éém n
$num
ééo p
)
éép q
.
ééq r
Value
éér w
=
ééx y
x
ééz {
.
éé{ |

Porcentajeéé| Ü
;ééÜ á
clientsééà è
.ééè ê
Cellééê î
(ééî ï
rééï ñ
,ééñ ó
$numééò ô
)ééô ö
.ééö õ
Valueééõ †
=éé° ¢
xéé£ §
.éé§ •#
PorcentajeAcumuladoéé• ∏
;éé∏ π
clients
èè 
.
èè 
Cell
èè 
(
èè 
r
èè 
,
èè 
$num
èè 
)
èè 
.
èè 
Value
èè $
=
èè% &
x
èè' (
.
èè( )
Cobros
èè) /
;
èè/ 0
clients
èè1 8
.
èè8 9
Cell
èè9 =
(
èè= >
r
èè> ?
,
èè? @
$num
èèA B
)
èèB C
.
èèC D
Value
èèD I
=
èèJ K
x
èèL M
.
èèM N
UltimoCobro
èèN Y
.
èèY Z

ToDateTime
èèZ d
(
èèd e
TimeOnly
èèe m
.
èèm n
MinValue
èèn v
)
èèv w
;
èèw x
clientsèèy Ä
.èèÄ Å
CellèèÅ Ö
(èèÖ Ü
rèèÜ á
,èèá à
$numèèâ ä
)èèä ã
.èèã å
Valueèèå ë
=èèí ì
xèèî ï
.èèï ñ"
PeriodoAnteriorPenèèñ ®
;èè® ©
if
êê 
(
êê 
x
êê 
.
êê !
VariacionPorcentaje
êê %
is
êê& (
decimal
êê) 0
	variation
êê1 :
)
êê: ;
clients
êê< C
.
êêC D
Cell
êêD H
(
êêH I
r
êêI J
,
êêJ K
$num
êêL M
)
êêM N
.
êêN O
Value
êêO T
=
êêU V
	variation
êêW `
;
êê` a
}
ëë 	
clients
íí 
.
íí 
Column
íí 
(
íí 
$num
íí 
)
íí 
.
íí 
Style
íí 
.
íí  

DateFormat
íí  *
.
íí* +
Format
íí+ 1
=
íí2 3
$str
íí4 @
;
íí@ A
clients
ííB I
.
ííI J
Columns
ííJ Q
(
ííQ R
)
ííR S
.
ííS T
AdjustToContents
ííT d
(
ííd e
)
ííe f
;
ííf g
using
îî 
var
îî 
stream
îî 
=
îî 
new
îî 
MemoryStream
îî +
(
îî+ ,
)
îî, -
;
îî- .
book
îî/ 3
.
îî3 4
SaveAs
îî4 :
(
îî: ;
stream
îî; A
)
îîA B
;
îîB C
return
ïï 
File
ïï 
(
ïï 
stream
ïï 
.
ïï 
ToArray
ïï "
(
ïï" #
)
ïï# $
,
ïï$ %
$str
ïï& i
,
ïïi j
month
ïïk p
is
ïïq s
int
ïït w
m
ïïx y
?
ïïz {
$"
ïï| ~
$strïï~ Ü
{ïïÜ á
yearïïá ã
}ïïã å
$strïïå ç
{ïïç é
mïïé è
:ïïè ê
$strïïê í
}ïïí ì
$strïïì ò
"ïïò ô
:ïïö õ
$"ïïú û
$strïïû ¶
{ïï¶ ß
yearïïß ´
}ïï´ ¨
$strïï¨ ±
"ïï± ≤
)ïï≤ ≥
;ïï≥ ¥
}
ññ 
[
òò 
HttpGet
òò 
(
òò 
$str
òò 
)
òò 
]
òò 
public
ôô 

async
ôô 
Task
ôô 
<
ôô 
ActionResult
ôô "
>
ôô" #
Clients
ôô$ +
(
ôô+ ,
CancellationToken
ôô, =
ct
ôô> @
)
ôô@ A
=>
ôôB D
Ok
ôôE G
(
ôôG H
await
ôôH M
db
ôôN P
.
ôôP Q
Clients
ôôQ X
.
ôôX Y
OrderBy
ôôY `
(
ôô` a
x
ôôa b
=>
ôôc e
x
ôôf g
.
ôôg h
CompanyName
ôôh s
)
ôôs t
.
ôôt u
Select
ôôu {
(
ôô{ |
x
ôô| }
=>ôô~ Ä
newôôÅ Ñ
{ôôÖ Ü
idôôá â
=ôôä ã
xôôå ç
.ôôç é
Idôôé ê
,ôôê ë
companyNameôôí ù
=ôôû ü
xôô† °
.ôô° ¢
CompanyNameôô¢ ≠
,ôô≠ Æ
isActiveôôØ ∑
=ôô∏ π
xôô∫ ª
.ôôª º
IsActiveôôº ƒ
,ôôƒ ≈#
requiresTaxDocumentôô∆ Ÿ
=ôô⁄ €
xôô‹ ›
.ôô› ﬁ#
RequiresTaxDocumentôôﬁ Ò
,ôôÒ Ú
activeProductsôôÛ Å
=ôôÇ É
dbôôÑ Ü
.ôôÜ á
ClientProductsôôá ï
.ôôï ñ
Countôôñ õ
(ôôõ ú
pôôú ù
=>ôôû †
pôô° ¢
.ôô¢ £
ClientIdôô£ ´
==ôô¨ Æ
xôôØ ∞
.ôô∞ ±
Idôô± ≥
&&ôô¥ ∂
pôô∑ ∏
.ôô∏ π
Statusôôπ ø
==ôô¿ ¬#
ClientProductStatusôô√ ÷
.ôô÷ ◊
Activoôô◊ ›
)ôô› ﬁ
,ôôﬁ ﬂ 
expiringProductsôô‡ 
=ôôÒ Ú
dbôôÛ ı
.ôôı ˆ
ClientProductsôôˆ Ñ
.ôôÑ Ö
CountôôÖ ä
(ôôä ã
pôôã å
=>ôôç è
pôôê ë
.ôôë í
ClientIdôôí ö
==ôôõ ù
xôôû ü
.ôôü †
Idôô† ¢
&&ôô£ •
pôô¶ ß
.ôôß ®
Statusôô® Æ
==ôôØ ±#
ClientProductStatusôô≤ ≈
.ôô≈ ∆
	PorVencerôô∆ œ
)ôôœ –
,ôô– —
expiredProductsôô“ ·
=ôô‚ „
dbôô‰ Ê
.ôôÊ Á
ClientProductsôôÁ ı
.ôôı ˆ
Countôôˆ ˚
(ôô˚ ¸
pôô¸ ˝
=>ôô˛ Ä
pôôÅ Ç
.ôôÇ É
ClientIdôôÉ ã
==ôôå é
xôôè ê
.ôôê ë
Idôôë ì
&&ôôî ñ
pôôó ò
.ôôò ô
Statusôôô ü
==ôô† ¢#
ClientProductStatusôô£ ∂
.ôô∂ ∑
Vencidoôô∑ æ
)ôôæ ø
,ôôø ¿
openTicketsôô¡ Ã
=ôôÕ Œ
dbôôœ —
.ôô— “
Ticketsôô“ Ÿ
.ôôŸ ⁄
Countôô⁄ ﬂ
(ôôﬂ ‡
tôô‡ ·
=>ôô‚ ‰
tôôÂ Ê
.ôôÊ Á
ClientIdôôÁ Ô
==ôô Ú
xôôÛ Ù
.ôôÙ ı
Idôôı ˜
&&ôô¯ ˙
(ôô˚ ¸
tôô¸ ˝
.ôô˝ ˛
Statusôô˛ Ñ
==ôôÖ á
TicketStatusôôà î
.ôôî ï
Abiertoôôï ú
||ôôù ü
tôô† °
.ôô° ¢
Statusôô¢ ®
==ôô© ´
TicketStatusôô¨ ∏
.ôô∏ π

EnProgresoôôπ √
)ôô√ ƒ
)ôôƒ ≈
}ôô∆ «
)ôô« »
.ôô» …
ToListAsyncôô… ‘
(ôô‘ ’
ctôô’ ◊
)ôô◊ ÿ
)ôôÿ Ÿ
;ôôŸ ⁄
[
õõ 
HttpGet
õõ 
(
õõ 
$str
õõ  
)
õõ  !
]
õõ! "
public
úú 

async
úú 
Task
úú 
<
úú 
ActionResult
úú "
>
úú" #
Client
úú$ *
(
úú* +
Guid
úú+ /
id
úú0 2
,
úú2 3
CancellationToken
úú4 E
ct
úúF H
)
úúH I
{
ùù 
var
ûû 
client
ûû 
=
ûû 
await
ûû 
db
ûû 
.
ûû 
Clients
ûû %
.
ûû% &
	FindAsync
ûû& /
(
ûû/ 0
[
ûû0 1
id
ûû1 3
]
ûû3 4
,
ûû4 5
ct
ûû6 8
)
ûû8 9
;
ûû9 :
if
üü 

(
üü 
client
üü 
is
üü 
null
üü 
)
üü 
return
üü "
NotFound
üü# +
(
üü+ ,
)
üü, -
;
üü- .
var
†† 
products
†† 
=
†† 
await
†† 
db
†† 
.
††  
ClientProducts
††  .
.
††. /
Include
††/ 6
(
††6 7
x
††7 8
=>
††9 ;
x
††< =
.
††= >
Product
††> E
)
††E F
.
††F G
Include
††G N
(
††N O
x
††O P
=>
††Q S
x
††T U
.
††U V
Project
††V ]
)
††] ^
.
††^ _
Where
††_ d
(
††d e
x
††e f
=>
††g i
x
††j k
.
††k l
ClientId
††l t
==
††u w
id
††x z
)
††z {
.
††{ |
ToListAsync††| á
(††á à
ct††à ä
)††ä ã
;††ã å
var
°° 
igvRate
°° 
=
°° 
await
°° 
db
°° 
.
°° 
IgvRateAsync
°° +
(
°°+ ,
ct
°°, .
)
°°. /
;
°°/ 0
return
¢¢ 
Ok
¢¢ 
(
¢¢ 
new
¢¢ 
{
¢¢ 
client
¢¢ 
=
¢¢  
	ClientDto
¢¢! *
(
¢¢* +
client
¢¢+ 1
)
¢¢1 2
,
¢¢2 3
products
¢¢4 <
=
¢¢= >
products
¢¢? G
.
¢¢G H
Select
¢¢H N
(
¢¢N O
x
¢¢O P
=>
¢¢Q S
ClientProductDto
¢¢T d
(
¢¢d e
x
¢¢e f
,
¢¢f g
x
¢¢h i
.
¢¢i j
Product
¢¢j q
is
¢¢r t
null
¢¢u y
?
¢¢z {
$num
¢¢| ~
:¢¢ Ä$
ClientProductPricing¢¢Å ï
.¢¢ï ñ

IgvRateFor¢¢ñ †
(¢¢† °
client¢¢° ß
,¢¢ß ®
x¢¢© ™
.¢¢™ ´
Product¢¢´ ≤
,¢¢≤ ≥
igvRate¢¢¥ ª
)¢¢ª º
)¢¢º Ω
)¢¢Ω æ
}¢¢ø ¿
)¢¢¿ ¡
;¢¢¡ ¬
}
££ 
[
•• 
HttpPost
•• 
(
•• 
$str
•• 
)
•• 
]
•• 
public
¶¶ 

async
¶¶ 
Task
¶¶ 
<
¶¶ 
ActionResult
¶¶ "
>
¶¶" #
CreateClient
¶¶$ 0
(
¶¶0 1
ClientRequest
¶¶1 >
request
¶¶? F
,
¶¶F G
CancellationToken
¶¶H Y
ct
¶¶Z \
)
¶¶\ ]
{
ßß 
var
®® 
error
®® 
=
®® 
ValidateClient
®® "
(
®®" #
request
®®# *
)
®®* +
;
®®+ ,
if
®®- /
(
®®0 1
error
®®1 6
is
®®7 9
not
®®: =
null
®®> B
)
®®B C
return
®®D J

BadRequest
®®K U
(
®®U V
new
®®V Y
{
®®Z [
message
®®\ c
=
®®d e
error
®®f k
}
®®l m
)
®®m n
;
®®n o
var
©© 
email
©© 
=
©© 
request
©© 
.
©© 
Email
©© !
.
©©! "
Trim
©©" &
(
©©& '
)
©©' (
;
©©( )
if
™™ 

(
™™ 
await
™™ 
db
™™ 
.
™™ 
Clients
™™ 
.
™™ 
AnyAsync
™™ %
(
™™% &
x
™™& '
=>
™™( *
x
™™+ ,
.
™™, -
Email
™™- 2
==
™™3 5
email
™™6 ;
,
™™; <
ct
™™= ?
)
™™? @
||
™™A C
await
™™D I
db
™™J L
.
™™L M
UserAccounts
™™M Y
.
™™Y Z
AnyAsync
™™Z b
(
™™b c
x
™™c d
=>
™™e g
x
™™h i
.
™™i j
Email
™™j o
==
™™p r
email
™™s x
,
™™x y
ct
™™z |
)
™™| }
)
™™} ~
return™™ Ö
Conflict™™Ü é
(™™é è
new™™è í
{™™ì î
message™™ï ú
=™™ù û
$str™™ü Ω
}™™æ ø
)™™ø ¿
;™™¿ ¡
var
´´ 
client
´´ 
=
´´ 
new
´´ 
Client
´´ 
{
´´  !
CompanyName
´´" -
=
´´. /
request
´´0 7
.
´´7 8
CompanyName
´´8 C
.
´´C D
Trim
´´D H
(
´´H I
)
´´I J
,
´´J K
ContactName
´´L W
=
´´X Y
request
´´Z a
.
´´a b
ContactName
´´b m
.
´´m n
Trim
´´n r
(
´´r s
)
´´s t
,
´´t u
Email
´´v {
=
´´| }
email´´~ É
,´´É Ñ
Phone´´Ö ä
=´´ã å
EmptyToNull´´ç ò
(´´ò ô
request´´ô †
.´´† °
Phone´´° ¶
)´´¶ ß
,´´ß ®!
PreferredLanguage´´© ∫
=´´ª º
request´´Ω ƒ
.´´ƒ ≈!
PreferredLanguage´´≈ ÷
.´´÷ ◊
Trim´´◊ €
(´´€ ‹
)´´‹ ›
.´´› ﬁ 
ToLowerInvariant´´ﬁ Ó
(´´Ó Ô
)´´Ô 
,´´ Ò#
RequiresTaxDocument´´Ú Ö
=´´Ü á
request´´à è
.´´è ê#
RequiresTaxDocument´´ê £
}´´§ •
;´´• ¶
db
¨¨ 

.
¨¨
 
Clients
¨¨ 
.
¨¨ 
Add
¨¨ 
(
¨¨ 
client
¨¨ 
)
¨¨ 
;
¨¨ 
var
ÆÆ 
access
ÆÆ 
=
ÆÆ 
AddAdminUser
ÆÆ !
(
ÆÆ! "
client
ÆÆ" (
)
ÆÆ( )
;
ÆÆ) *
await
ØØ 
db
ØØ 
.
ØØ 
SaveChangesAsync
ØØ !
(
ØØ! "
ct
ØØ" $
)
ØØ$ %
;
ØØ% &
access
∞∞ 
=
∞∞ 
await
∞∞ 
EmailAccessAsync
∞∞ '
(
∞∞' (
client
∞∞( .
,
∞∞. /
access
∞∞0 6
,
∞∞6 7
ct
∞∞8 :
)
∞∞: ;
;
∞∞; <
return
±± 
Created
±± 
(
±± 
$"
±± 
$str
±± ,
{
±±, -
client
±±- 3
.
±±3 4
Id
±±4 6
}
±±6 7
"
±±7 8
,
±±8 9
new
±±: =
{
±±> ?
client
±±@ F
=
±±G H
	ClientDto
±±I R
(
±±R S
client
±±S Y
)
±±Y Z
,
±±Z [
access
±±\ b
}
±±c d
)
±±d e
;
±±e f
}
≤≤ 
[
¥¥ 
	HttpPatch
¥¥ 
(
¥¥ 
$str
¥¥ "
)
¥¥" #
]
¥¥# $
public
µµ 

async
µµ 
Task
µµ 
<
µµ 
ActionResult
µµ "
>
µµ" #
UpdateClient
µµ$ 0
(
µµ0 1
Guid
µµ1 5
id
µµ6 8
,
µµ8 9 
ClientPatchRequest
µµ: L
request
µµM T
,
µµT U
CancellationToken
µµV g
ct
µµh j
)
µµj k
{
∂∂ 
var
∑∑ 
client
∑∑ 
=
∑∑ 
await
∑∑ 
db
∑∑ 
.
∑∑ 
Clients
∑∑ %
.
∑∑% &
	FindAsync
∑∑& /
(
∑∑/ 0
[
∑∑0 1
id
∑∑1 3
]
∑∑3 4
,
∑∑4 5
ct
∑∑6 8
)
∑∑8 9
;
∑∑9 :
if
∑∑; =
(
∑∑> ?
client
∑∑? E
is
∑∑F H
null
∑∑I M
)
∑∑M N
return
∑∑O U
NotFound
∑∑V ^
(
∑∑^ _
)
∑∑_ `
;
∑∑` a
if
∏∏ 

(
∏∏ 
request
∏∏ 
.
∏∏ 
CompanyName
∏∏ 
is
∏∏  "
not
∏∏# &
null
∏∏' +
)
∏∏+ ,
client
∏∏- 3
.
∏∏3 4
CompanyName
∏∏4 ?
=
∏∏@ A
request
∏∏B I
.
∏∏I J
CompanyName
∏∏J U
.
∏∏U V
Trim
∏∏V Z
(
∏∏Z [
)
∏∏[ \
;
∏∏\ ]
if
ππ 

(
ππ 
request
ππ 
.
ππ 
ContactName
ππ 
is
ππ  "
not
ππ# &
null
ππ' +
)
ππ+ ,
client
ππ- 3
.
ππ3 4
ContactName
ππ4 ?
=
ππ@ A
request
ππB I
.
ππI J
ContactName
ππJ U
.
ππU V
Trim
ππV Z
(
ππZ [
)
ππ[ \
;
ππ\ ]
if
∫∫ 

(
∫∫ 
request
∫∫ 
.
∫∫ 
Phone
∫∫ 
is
∫∫ 
not
∫∫  
null
∫∫! %
)
∫∫% &
client
∫∫' -
.
∫∫- .
Phone
∫∫. 3
=
∫∫4 5
EmptyToNull
∫∫6 A
(
∫∫A B
request
∫∫B I
.
∫∫I J
Phone
∫∫J O
)
∫∫O P
;
∫∫P Q
if
ªª 

(
ªª 
request
ªª 
.
ªª 
PreferredLanguage
ªª %
is
ªª& (
not
ªª) ,
null
ªª- 1
)
ªª1 2
{
ºº 	
var
ΩΩ 
lang
ΩΩ 
=
ΩΩ 
request
ΩΩ 
.
ΩΩ 
PreferredLanguage
ΩΩ 0
.
ΩΩ0 1
Trim
ΩΩ1 5
(
ΩΩ5 6
)
ΩΩ6 7
.
ΩΩ7 8
ToLowerInvariant
ΩΩ8 H
(
ΩΩH I
)
ΩΩI J
;
ΩΩJ K
if
ææ 
(
ææ 
lang
ææ 
is
ææ 
not
ææ 
(
ææ 
$str
ææ !
or
ææ" $
$str
ææ% )
or
ææ* ,
$str
ææ- 1
)
ææ1 2
)
ææ2 3
return
ææ4 :

BadRequest
ææ; E
(
ææE F
new
ææF I
{
ææJ K
message
ææL S
=
ææT U
$str
ææV h
}
ææi j
)
ææj k
;
ææk l
client
øø 
.
øø 
PreferredLanguage
øø $
=
øø% &
lang
øø' +
;
øø+ ,
}
¿¿ 	
if
¡¡ 

(
¡¡ 
request
¡¡ 
.
¡¡ 
Email
¡¡ 
is
¡¡ 
not
¡¡  
null
¡¡! %
&&
¡¡& (
await
¡¡) .$
ChangeClientEmailAsync
¡¡/ E
(
¡¡E F
client
¡¡F L
,
¡¡L M
request
¡¡N U
.
¡¡U V
Email
¡¡V [
.
¡¡[ \
Trim
¡¡\ `
(
¡¡` a
)
¡¡a b
,
¡¡b c
ct
¡¡d f
)
¡¡f g
is
¡¡h j
{
¡¡k l
}
¡¡m n

emailError
¡¡o y
)
¡¡y z
return¡¡{ Å

emailError¡¡Ç å
;¡¡å ç
if
¬¬ 

(
¬¬ 
request
¬¬ 
.
¬¬ 
IsActive
¬¬ 
is
¬¬ 
bool
¬¬  $
active
¬¬% +
)
¬¬+ ,
client
¬¬- 3
.
¬¬3 4
IsActive
¬¬4 <
=
¬¬= >
active
¬¬? E
;
¬¬E F
if
√√ 

(
√√ 
request
√√ 
.
√√ !
RequiresTaxDocument
√√ '
is
√√( *
bool
√√+ /
requiresTax
√√0 ;
)
√√; <
client
√√= C
.
√√C D!
RequiresTaxDocument
√√D W
=
√√X Y
requiresTax
√√Z e
;
√√e f
await
ƒƒ 
db
ƒƒ 
.
ƒƒ 
SaveChangesAsync
ƒƒ !
(
ƒƒ! "
ct
ƒƒ" $
)
ƒƒ$ %
;
ƒƒ% &
return
ƒƒ' -
Ok
ƒƒ. 0
(
ƒƒ0 1
	ClientDto
ƒƒ1 :
(
ƒƒ: ;
client
ƒƒ; A
)
ƒƒA B
)
ƒƒB C
;
ƒƒC D
}
≈≈ 
private
»» 
async
»» 
Task
»» 
<
»» 
ActionResult
»» #
?
»»# $
>
»»$ %$
ChangeClientEmailAsync
»»& <
(
»»< =
Client
»»= C
client
»»D J
,
»»J K
string
»»L R
email
»»S X
,
»»X Y
CancellationToken
»»Z k
ct
»»l n
)
»»n o
{
…… 
if
   

(
   
string
   
.
    
IsNullOrWhiteSpace
   %
(
  % &
email
  & +
)
  + ,
)
  , -
return
  . 4

BadRequest
  5 ?
(
  ? @
new
  @ C
{
  D E
message
  F M
=
  N O
$str
  P j
}
  k l
)
  l m
;
  m n
if
ÀÀ 

(
ÀÀ 
await
ÀÀ 
db
ÀÀ 
.
ÀÀ 
Clients
ÀÀ 
.
ÀÀ 
AnyAsync
ÀÀ %
(
ÀÀ% &
x
ÀÀ& '
=>
ÀÀ( *
x
ÀÀ+ ,
.
ÀÀ, -
Email
ÀÀ- 2
==
ÀÀ3 5
email
ÀÀ6 ;
&&
ÀÀ< >
x
ÀÀ? @
.
ÀÀ@ A
Id
ÀÀA C
!=
ÀÀD F
client
ÀÀG M
.
ÀÀM N
Id
ÀÀN P
,
ÀÀP Q
ct
ÀÀR T
)
ÀÀT U
)
ÀÀU V
return
ÀÀW ]
Conflict
ÀÀ^ f
(
ÀÀf g
new
ÀÀg j
{
ÀÀk l
message
ÀÀm t
=
ÀÀu v
$strÀÀw ï
}ÀÀñ ó
)ÀÀó ò
;ÀÀò ô
client
ÃÃ 
.
ÃÃ 
Email
ÃÃ 
=
ÃÃ 
email
ÃÃ 
;
ÃÃ 
return
ÕÕ 
null
ÕÕ 
;
ÕÕ 
}
ŒŒ 
[
–– 
HttpGet
–– 
(
–– 
$str
–– &
)
––& '
]
––' (
public
—— 

IActionResult
—— 
ClientTemplate
—— '
(
——' (
)
——( )
=>
——* ,
File
——- 1
(
——1 2
CreateWorkbook
——2 @
(
——@ A
new
““ 
(
““ 
$str
““ 
,
““ 
true
““ 
,
““  
$str
““! B
)
““B C
,
““C D
new
”” 
(
”” 
$str
”” 
,
”” 
true
”” 
,
””  
$str
””! C
)
””C D
,
””D E
new
‘‘ 
(
‘‘ 
$str
‘‘ 
,
‘‘ 
true
‘‘ 
,
‘‘ 
$str
‘‘ s
)
‘‘s t
,
‘‘t u
new
’’ 
(
’’ 
$str
’’ 
,
’’ 
false
’’ 
,
’’ 
$str
’’ >
)
’’> ?
,
’’? @
new
÷÷ 
(
÷÷ 
$str
÷÷ 
,
÷÷  
true
÷÷! %
,
÷÷% &
$str
÷÷' R
,
÷÷R S
[
÷÷T U
$str
÷÷U Y
,
÷÷Y Z
$str
÷÷[ _
,
÷÷_ `
$str
÷÷a e
]
÷÷e f
)
÷÷f g
,
÷÷g h
new
◊◊ 
(
◊◊ 
$str
◊◊ !
,
◊◊! "
false
◊◊# (
,
◊◊( )
$str◊◊* ã
,◊◊ã å
[◊◊ç é
$str◊◊é í
,◊◊í ì
$str◊◊î ò
]◊◊ò ô
)◊◊ô ö
)◊◊ö õ
,◊◊õ ú
$str
ÿÿ K
,
ÿÿK L
$str
ÿÿM f
)
ÿÿf g
;
ÿÿg h
[
⁄⁄ 
HttpPost
⁄⁄ 
(
⁄⁄ 
$str
⁄⁄ 
)
⁄⁄ 
]
⁄⁄  
public
€€ 

async
€€ 
Task
€€ 
<
€€ 
ActionResult
€€ "
>
€€" #
ImportClients
€€$ 1
(
€€1 2
	IFormFile
€€2 ;
file
€€< @
,
€€@ A
CancellationToken
€€B S
ct
€€T V
)
€€V W
{
‹‹ 
var
›› 
created_
›› 
=
›› 
new
›› 
List
›› 
<
››  
(
››  !
Client
››! '
Client
››( .
,
››. /
ClientAccess
››0 <
Access
››= C
)
››C D
>
››D E
(
››E F
)
››F G
;
››G H
var
ﬁﬁ 
(
ﬁﬁ 
failure
ﬁﬁ 
,
ﬁﬁ 
created
ﬁﬁ 
,
ﬁﬁ 
errors
ﬁﬁ %
)
ﬁﬁ% &
=
ﬁﬁ' (
await
ﬁﬁ) .
Import
ﬁﬁ/ 5
(
ﬁﬁ5 6
file
ﬁﬁ6 :
,
ﬁﬁ: ;
$str
ﬁﬁ< F
,
ﬁﬁF G
async
ﬁﬁH M
(
ﬁﬁN O
row
ﬁﬁO R
,
ﬁﬁR S
	rowNumber
ﬁﬁT ]
,
ﬁﬁ] ^
errors
ﬁﬁ_ e
)
ﬁﬁe f
=>
ﬁﬁg i
{
ﬂﬂ 	
var
‡‡ 
requiresTax
‡‡ 
=
‡‡ 
	ReadYesNo
‡‡ '
(
‡‡' (
Cell
‡‡( ,
(
‡‡, -
row
‡‡- 0
,
‡‡0 1
$num
‡‡2 3
)
‡‡3 4
,
‡‡4 5
defaultValue
‡‡6 B
:
‡‡B C
false
‡‡D I
)
‡‡I J
;
‡‡J K
var
·· 
request
·· 
=
·· 
new
·· 
ClientRequest
·· +
(
··+ ,
Cell
··, 0
(
··0 1
row
··1 4
,
··4 5
$num
··6 7
)
··7 8
,
··8 9
Cell
··: >
(
··> ?
row
··? B
,
··B C
$num
··D E
)
··E F
,
··F G
Cell
··H L
(
··L M
row
··M P
,
··P Q
$num
··R S
)
··S T
,
··T U
Cell
··V Z
(
··Z [
row
··[ ^
,
··^ _
$num
··` a
)
··a b
,
··b c
Cell
··d h
(
··h i
row
··i l
,
··l m
$num
··n o
)
··o p
,
··p q
requiresTax
··r }
??··~ Ä
false··Å Ü
)··Ü á
;··á à
var··â å
error··ç í
=··ì î
requiresTax··ï †
is··° £
null··§ ®
?··© ™
$str··´ ◊
:··ÿ Ÿ
ValidateClient··⁄ Ë
(··Ë È
request··È 
)·· Ò
;··Ò Ú
var
‚‚ 
email
‚‚ 
=
‚‚ 
request
‚‚ 
.
‚‚  
Email
‚‚  %
.
‚‚% &
Trim
‚‚& *
(
‚‚* +
)
‚‚+ ,
;
‚‚, -
if
„„ 
(
„„ 
error
„„ 
is
„„ 
not
„„ 
null
„„ !
||
„„" $
await
„„% *
db
„„+ -
.
„„- .
Clients
„„. 5
.
„„5 6
AnyAsync
„„6 >
(
„„> ?
x
„„? @
=>
„„A C
x
„„D E
.
„„E F
Email
„„F K
==
„„L N
email
„„O T
,
„„T U
ct
„„V X
)
„„X Y
||
„„Z \
await
„„] b
db
„„c e
.
„„e f
UserAccounts
„„f r
.
„„r s
AnyAsync
„„s {
(
„„{ |
x
„„| }
=>„„~ Ä
x„„Å Ç
.„„Ç É
Email„„É à
==„„â ã
email„„å ë
,„„ë í
ct„„ì ï
)„„ï ñ
)„„ñ ó
{„„ò ô
errors„„ö †
.„„† °
Add„„° §
(„„§ •
new„„• ®
(„„® ©
	rowNumber„„© ≤
,„„≤ ≥
error„„¥ π
??„„∫ º
$str„„Ω €
)„„€ ‹
)„„‹ ›
;„„› ﬁ
return„„ﬂ Â
false„„Ê Î
;„„Î Ï
}„„Ì Ó
var
‰‰ 
client
‰‰ 
=
‰‰ 
new
‰‰ 
Client
‰‰ #
{
‰‰$ %
CompanyName
‰‰& 1
=
‰‰2 3
request
‰‰4 ;
.
‰‰; <
CompanyName
‰‰< G
.
‰‰G H
Trim
‰‰H L
(
‰‰L M
)
‰‰M N
,
‰‰N O
ContactName
‰‰P [
=
‰‰\ ]
request
‰‰^ e
.
‰‰e f
ContactName
‰‰f q
.
‰‰q r
Trim
‰‰r v
(
‰‰v w
)
‰‰w x
,
‰‰x y
Email
‰‰z 
=‰‰Ä Å
email‰‰Ç á
,‰‰á à
Phone‰‰â é
=‰‰è ê
EmptyToNull‰‰ë ú
(‰‰ú ù
request‰‰ù §
.‰‰§ •
Phone‰‰• ™
)‰‰™ ´
,‰‰´ ¨!
PreferredLanguage‰‰≠ æ
=‰‰ø ¿
request‰‰¡ »
.‰‰» …!
PreferredLanguage‰‰… ⁄
.‰‰⁄ €
Trim‰‰€ ﬂ
(‰‰ﬂ ‡
)‰‰‡ ·
.‰‰· ‚ 
ToLowerInvariant‰‰‚ Ú
(‰‰Ú Û
)‰‰Û Ù
,‰‰Ù ı#
RequiresTaxDocument‰‰ˆ â
=‰‰ä ã
request‰‰å ì
.‰‰ì î#
RequiresTaxDocument‰‰î ß
}‰‰® ©
;‰‰© ™
db
ÂÂ 
.
ÂÂ 
Clients
ÂÂ 
.
ÂÂ 
Add
ÂÂ 
(
ÂÂ 
client
ÂÂ !
)
ÂÂ! "
;
ÂÂ" #
created_
ÂÂ$ ,
.
ÂÂ, -
Add
ÂÂ- 0
(
ÂÂ0 1
(
ÂÂ1 2
client
ÂÂ2 8
,
ÂÂ8 9
AddAdminUser
ÂÂ: F
(
ÂÂF G
client
ÂÂG M
)
ÂÂM N
)
ÂÂN O
)
ÂÂO P
;
ÂÂP Q
return
ÂÂR X
true
ÂÂY ]
;
ÂÂ] ^
}
ÊÊ 	
,
ÊÊ	 

ct
ÊÊ 
)
ÊÊ 
;
ÊÊ 
if
ÁÁ 

(
ÁÁ 
failure
ÁÁ 
is
ÁÁ 
not
ÁÁ 
null
ÁÁ 
)
ÁÁ  
return
ÁÁ! '
failure
ÁÁ( /
;
ÁÁ/ 0
var
ËË 
accesses
ËË 
=
ËË 
new
ËË 
List
ËË 
<
ËË  
ClientAccess
ËË  ,
>
ËË, -
(
ËË- .
)
ËË. /
;
ËË/ 0
foreach
ÈÈ 
(
ÈÈ 
var
ÈÈ 
(
ÈÈ 
client
ÈÈ 
,
ÈÈ 
access
ÈÈ $
)
ÈÈ$ %
in
ÈÈ& (
created_
ÈÈ) 1
)
ÈÈ1 2
accesses
ÈÈ3 ;
.
ÈÈ; <
Add
ÈÈ< ?
(
ÈÈ? @
await
ÈÈ@ E
EmailAccessAsync
ÈÈF V
(
ÈÈV W
client
ÈÈW ]
,
ÈÈ] ^
access
ÈÈ_ e
,
ÈÈe f
ct
ÈÈg i
)
ÈÈi j
)
ÈÈj k
;
ÈÈk l
return
ÍÍ 
Ok
ÍÍ 
(
ÍÍ 
new
ÍÍ 
{
ÍÍ 
created
ÍÍ 
,
ÍÍ  
skipped
ÍÍ! (
=
ÍÍ) *
errors
ÍÍ+ 1
.
ÍÍ1 2
Count
ÍÍ2 7
,
ÍÍ7 8
errors
ÍÍ9 ?
,
ÍÍ? @
accesses
ÍÍA I
}
ÍÍJ K
)
ÍÍK L
;
ÍÍL M
}
ÎÎ 
[
ÒÒ 
HttpPost
ÒÒ 
(
ÒÒ 
$str
ÒÒ (
)
ÒÒ( )
]
ÒÒ) *
public
ÚÚ 

async
ÚÚ 
Task
ÚÚ 
<
ÚÚ 
ActionResult
ÚÚ "
>
ÚÚ" #
ClientAccess
ÚÚ$ 0
(
ÚÚ0 1
Guid
ÚÚ1 5
id
ÚÚ6 8
,
ÚÚ8 9
CancellationToken
ÚÚ: K
ct
ÚÚL N
)
ÚÚN O
{
ÛÛ 
var
ÙÙ 
client
ÙÙ 
=
ÙÙ 
await
ÙÙ 
db
ÙÙ 
.
ÙÙ 
Clients
ÙÙ %
.
ÙÙ% &
	FindAsync
ÙÙ& /
(
ÙÙ/ 0
[
ÙÙ0 1
id
ÙÙ1 3
]
ÙÙ3 4
,
ÙÙ4 5
ct
ÙÙ6 8
)
ÙÙ8 9
;
ÙÙ9 :
if
ÙÙ; =
(
ÙÙ> ?
client
ÙÙ? E
is
ÙÙF H
null
ÙÙI M
)
ÙÙM N
return
ÙÙO U
NotFound
ÙÙV ^
(
ÙÙ^ _
)
ÙÙ_ `
;
ÙÙ` a
var
ıı 
user
ıı 
=
ıı 
await
ıı 
db
ıı 
.
ıı 
UserAccounts
ıı (
.
ıı( )"
SingleOrDefaultAsync
ıı) =
(
ıı= >
x
ıı> ?
=>
ıı@ B
x
ııC D
.
ııD E
Email
ııE J
==
ııK M
client
ııN T
.
ııT U
Email
ııU Z
,
ııZ [
ct
ıı\ ^
)
ıı^ _
;
ıı_ `
if
ˆˆ 

(
ˆˆ 
user
ˆˆ 
is
ˆˆ 
not
ˆˆ 
null
ˆˆ 
&&
ˆˆ 
user
ˆˆ  $
.
ˆˆ$ %
ClientId
ˆˆ% -
!=
ˆˆ. 0
client
ˆˆ1 7
.
ˆˆ7 8
Id
ˆˆ8 :
)
ˆˆ: ;
return
ˆˆ< B
Conflict
ˆˆC K
(
ˆˆK L
new
ˆˆL O
{
ˆˆP Q
message
ˆˆR Y
=
ˆˆZ [
$strˆˆ\ ó
}ˆˆò ô
)ˆˆô ö
;ˆˆö õ
ClientAccess
˜˜ 
access
˜˜ 
;
˜˜ 
if
¯¯ 

(
¯¯ 
user
¯¯ 
is
¯¯ 
null
¯¯ 
)
¯¯ 
access
¯¯  
=
¯¯! "
AddAdminUser
¯¯# /
(
¯¯/ 0
client
¯¯0 6
)
¯¯6 7
;
¯¯7 8
else
˘˘ 
{
˙˙ 	
var
˚˚ 
temporaryPassword
˚˚ !
=
˚˚" #
AccountController
˚˚$ 5
.
˚˚5 6
TemporaryPassword
˚˚6 G
(
˚˚G H
)
˚˚H I
;
˚˚I J
user
¸¸ 
.
¸¸ 
PasswordHash
¸¸ 
=
¸¸ 
AccountController
¸¸  1
.
¸¸1 2
Hasher
¸¸2 8
.
¸¸8 9
HashPassword
¸¸9 E
(
¸¸E F
user
¸¸F J
,
¸¸J K
temporaryPassword
¸¸L ]
)
¸¸] ^
;
¸¸^ _
user
¸¸` d
.
¸¸d e
IsActive
¸¸e m
=
¸¸n o
true
¸¸p t
;
¸¸t u
access
˝˝ 
=
˝˝ 
new
˝˝ 
ClientAccess
˝˝ %
(
˝˝% &
client
˝˝& ,
.
˝˝, -
CompanyName
˝˝- 8
,
˝˝8 9
user
˝˝: >
.
˝˝> ?
Email
˝˝? D
,
˝˝D E
temporaryPassword
˝˝F W
)
˝˝W X
;
˝˝X Y
}
˛˛ 	
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
SaveChangesAsync
ˇˇ !
(
ˇˇ! "
ct
ˇˇ" $
)
ˇˇ$ %
;
ˇˇ% &
return
ÄÄ 
Ok
ÄÄ 
(
ÄÄ 
await
ÄÄ 
EmailAccessAsync
ÄÄ (
(
ÄÄ( )
client
ÄÄ) /
,
ÄÄ/ 0
access
ÄÄ1 7
,
ÄÄ7 8
ct
ÄÄ9 ;
)
ÄÄ; <
)
ÄÄ< =
;
ÄÄ= >
}
ÅÅ 
[
ÉÉ 
HttpPost
ÉÉ 
(
ÉÉ 
$str
ÉÉ 0
)
ÉÉ0 1
]
ÉÉ1 2
public
ÑÑ 

async
ÑÑ 
Task
ÑÑ 
<
ÑÑ 
ActionResult
ÑÑ "
>
ÑÑ" #
CreateProject
ÑÑ$ 1
(
ÑÑ1 2
Guid
ÑÑ2 6
clientId
ÑÑ7 ?
,
ÑÑ? @
ProjectRequest
ÑÑA O
request
ÑÑP W
,
ÑÑW X
CancellationToken
ÑÑY j
ct
ÑÑk m
)
ÑÑm n
{
ÖÖ 
if
ÜÜ 

(
ÜÜ 
!
ÜÜ 
await
ÜÜ 
db
ÜÜ 
.
ÜÜ 
Clients
ÜÜ 
.
ÜÜ 
AnyAsync
ÜÜ &
(
ÜÜ& '
x
ÜÜ' (
=>
ÜÜ) +
x
ÜÜ, -
.
ÜÜ- .
Id
ÜÜ. 0
==
ÜÜ1 3
clientId
ÜÜ4 <
,
ÜÜ< =
ct
ÜÜ> @
)
ÜÜ@ A
)
ÜÜA B
return
ÜÜC I
NotFound
ÜÜJ R
(
ÜÜR S
)
ÜÜS T
;
ÜÜT U
if
áá 

(
áá 
string
áá 
.
áá  
IsNullOrWhiteSpace
áá %
(
áá% &
request
áá& -
.
áá- .
Name
áá. 2
)
áá2 3
)
áá3 4
return
áá5 ;

BadRequest
áá< F
(
ááF G
new
ááG J
{
ááK L
message
ááM T
=
ááU V
$str
ááW 
}ááÄ Å
)ááÅ Ç
;ááÇ É
var
àà 
slug
àà 
=
àà 
Slugify
àà 
(
àà 
string
àà !
.
àà! " 
IsNullOrWhiteSpace
àà" 4
(
àà4 5
request
àà5 <
.
àà< =
Slug
àà= A
)
ààA B
?
ààC D
request
ààE L
.
ààL M
Name
ààM Q
:
ààR S
request
ààT [
.
àà[ \
Slug
àà\ `
)
àà` a
;
ààa b
if
ââ 

(
ââ 
slug
ââ 
.
ââ 
Length
ââ 
==
ââ 
$num
ââ 
)
ââ 
return
ââ $

BadRequest
ââ% /
(
ââ/ 0
new
ââ0 3
{
ââ4 5
message
ââ6 =
=
ââ> ?
$str
ââ@ P
}
ââQ R
)
ââR S
;
ââS T
if
ää 

(
ää 
await
ää 
db
ää 
.
ää 
Projects
ää 
.
ää 
AnyAsync
ää &
(
ää& '
x
ää' (
=>
ää) +
x
ää, -
.
ää- .
Slug
ää. 2
==
ää3 5
slug
ää6 :
,
ää: ;
ct
ää< >
)
ää> ?
)
ää? @
return
ääA G
Conflict
ääH P
(
ääP Q
new
ääQ T
{
ääU V
message
ääW ^
=
ää_ `
$"
ääa c
$strääc Ü
{ääÜ á
slugääá ã
}ääã å
$strääå é
"ääé è
}ääê ë
)ääë í
;ääí ì
var
ãã 
project
ãã 
=
ãã 
new
ãã 
Project
ãã !
{
ãã" #
ClientId
ãã$ ,
=
ãã- .
clientId
ãã/ 7
,
ãã7 8
Name
ãã9 =
=
ãã> ?
request
ãã@ G
.
ããG H
Name
ããH L
.
ããL M
Trim
ããM Q
(
ããQ R
)
ããR S
,
ããS T
Slug
ããU Y
=
ããZ [
slug
ãã\ `
}
ããa b
;
ããb c
if
çç 

(
çç 
!
çç 
string
çç 
.
çç  
IsNullOrWhiteSpace
çç &
(
çç& '
request
çç' .
.
çç. /
GithubRepoOwner
çç/ >
)
çç> ?
&&
çç@ B
!
ççC D
string
ççD J
.
ççJ K 
IsNullOrWhiteSpace
ççK ]
(
çç] ^
request
çç^ e
.
ççe f
GithubRepoName
ççf t
)
ççt u
)
ççu v
{
éé 	
var
èè 

repository
èè 
=
èè 
new
èè  
ProjectRepository
èè! 2
{
èè3 4
	ProjectId
èè5 >
=
èè? @
project
èèA H
.
èèH I
Id
èèI K
,
èèK L
Owner
èèM R
=
èèS T
request
èèU \
.
èè\ ]
GithubRepoOwner
èè] l
.
èèl m
Trim
èèm q
(
èèq r
)
èèr s
,
èès t
Name
èèu y
=
èèz {
requestèè| É
.èèÉ Ñ
GithubRepoNameèèÑ í
.èèí ì
Trimèèì ó
(èèó ò
)èèò ô
,èèô ö
	IsDefaultèèõ §
=èè• ¶
trueèèß ´
}èè¨ ≠
;èè≠ Æ
if
êê 
(
êê 
await
êê %
RepositoryConflictAsync
êê -
(
êê- .

repository
êê. 8
.
êê8 9
Owner
êê9 >
,
êê> ?

repository
êê@ J
.
êêJ K
Name
êêK O
,
êêO P
null
êêQ U
,
êêU V
ct
êêW Y
)
êêY Z
is
êê[ ]
{
êê^ _
}
êê` a
conflict
êêb j
)
êêj k
return
êêl r
conflict
êês {
;
êê{ |
project
ëë 
.
ëë 
Repositories
ëë  
.
ëë  !
Add
ëë! $
(
ëë$ %

repository
ëë% /
)
ëë/ 0
;
ëë0 1
}
íí 	
db
ìì 

.
ìì
 
Projects
ìì 
.
ìì 
Add
ìì 
(
ìì 
project
ìì 
)
ìì  
;
ìì  !
await
ìì" '
db
ìì( *
.
ìì* +
SaveChangesAsync
ìì+ ;
(
ìì; <
ct
ìì< >
)
ìì> ?
;
ìì? @
return
îî 
Created
îî 
(
îî 
$"
îî 
$str
îî -
{
îî- .
project
îî. 5
.
îî5 6
Id
îî6 8
}
îî8 9
"
îî9 :
,
îî: ;

ProjectDto
îî< F
(
îîF G
project
îîG N
)
îîN O
)
îîO P
;
îîP Q
}
ïï 
[
óó 
	HttpPatch
óó 
(
óó 
$str
óó #
)
óó# $
]
óó$ %
public
òò 

async
òò 
Task
òò 
<
òò 
ActionResult
òò "
>
òò" #
UpdateProject
òò$ 1
(
òò1 2
Guid
òò2 6
id
òò7 9
,
òò9 :
ProjectRequest
òò; I
request
òòJ Q
,
òòQ R
CancellationToken
òòS d
ct
òòe g
)
òòg h
{
ôô 
var
öö 
project
öö 
=
öö 
await
öö 
db
öö 
.
öö 
Projects
öö '
.
öö' (
Include
öö( /
(
öö/ 0
x
öö0 1
=>
öö2 4
x
öö5 6
.
öö6 7
Repositories
öö7 C
)
ööC D
.
ööD E"
SingleOrDefaultAsync
ööE Y
(
ööY Z
x
ööZ [
=>
öö\ ^
x
öö_ `
.
öö` a
Id
ööa c
==
ööd f
id
öög i
,
ööi j
ct
öök m
)
ööm n
;
öön o
if
ööp r
(
öös t
project
ööt {
is
öö| ~
nullöö É
)ööÉ Ñ
returnööÖ ã
NotFoundööå î
(ööî ï
)ööï ñ
;ööñ ó
if
õõ 

(
õõ 
request
õõ 
.
õõ 
Name
õõ 
is
õõ 
not
õõ 
null
õõ  $
)
õõ$ %
{
õõ& '
if
õõ( *
(
õõ+ ,
string
õõ, 2
.
õõ2 3 
IsNullOrWhiteSpace
õõ3 E
(
õõE F
request
õõF M
.
õõM N
Name
õõN R
)
õõR S
)
õõS T
return
õõU [

BadRequest
õõ\ f
(
õõf g
new
õõg j
{
õõk l
message
õõm t
=
õõu v
$strõõw ü
}õõ† °
)õõ° ¢
;õõ¢ £
projectõõ§ ´
.õõ´ ¨
Nameõõ¨ ∞
=õõ± ≤
requestõõ≥ ∫
.õõ∫ ª
Nameõõª ø
.õõø ¿
Trimõõ¿ ƒ
(õõƒ ≈
)õõ≈ ∆
;õõ∆ «
}õõ» …
await
úú 
db
úú 
.
úú 
SaveChangesAsync
úú !
(
úú! "
ct
úú" $
)
úú$ %
;
úú% &
return
úú' -
Ok
úú. 0
(
úú0 1

ProjectDto
úú1 ;
(
úú; <
project
úú< C
)
úúC D
)
úúD E
;
úúE F
}
ùù 
[
†† 

HttpDelete
†† 
(
†† 
$str
†† $
)
††$ %
]
††% &
public
°° 

async
°° 
Task
°° 
<
°° 
ActionResult
°° "
>
°°" #
DeleteProject
°°$ 1
(
°°1 2
Guid
°°2 6
id
°°7 9
,
°°9 :
CancellationToken
°°; L
ct
°°M O
)
°°O P
{
¢¢ 
var
££ 
project
££ 
=
££ 
await
££ 
db
££ 
.
££ 
Projects
££ '
.
££' (
Include
££( /
(
££/ 0
x
££0 1
=>
££2 4
x
££5 6
.
££6 7
Repositories
££7 C
)
££C D
.
££D E"
SingleOrDefaultAsync
££E Y
(
££Y Z
x
££Z [
=>
££\ ^
x
££_ `
.
££` a
Id
££a c
==
££d f
id
££g i
,
££i j
ct
££k m
)
££m n
;
££n o
if
££p r
(
££s t
project
££t {
is
££| ~
null££ É
)££É Ñ
return££Ö ã
NotFound££å î
(££î ï
)££ï ñ
;££ñ ó
var
§§ 
products
§§ 
=
§§ 
await
§§ 
db
§§ 
.
§§  
ClientProducts
§§  .
.
§§. /

CountAsync
§§/ 9
(
§§9 :
x
§§: ;
=>
§§< >
x
§§? @
.
§§@ A
	ProjectId
§§A J
==
§§K M
id
§§N P
,
§§P Q
ct
§§R T
)
§§T U
;
§§U V
var
•• 
tickets
•• 
=
•• 
await
•• 
db
•• 
.
•• 
Tickets
•• &
.
••& '

CountAsync
••' 1
(
••1 2
x
••2 3
=>
••4 6
x
••7 8
.
••8 9
	ProjectId
••9 B
==
••C E
id
••F H
,
••H I
ct
••J L
)
••L M
;
••M N
if
¶¶ 

(
¶¶ 
products
¶¶ 
+
¶¶ 
tickets
¶¶ 
>
¶¶  
$num
¶¶! "
)
¶¶" #
return
ßß 
Conflict
ßß 
(
ßß 
new
ßß 
{
ßß  !
message
ßß" )
=
ßß* +
$"
ßß, .
$str
ßß. /
{
ßß/ 0
project
ßß0 7
.
ßß7 8
Name
ßß8 <
}
ßß< =
$str
ßß= E
{
ßßE F
Count
ßßF K
(
ßßK L
products
ßßL T
,
ßßT U
$str
ßßV `
,
ßß` a
$str
ßßb m
)
ßßm n
}
ßßn o
{
ßßo p
(
ßßp q
products
ßßq y
>
ßßz {
$num
ßß| }
&&ßß~ Ä
ticketsßßÅ à
>ßßâ ä
$numßßã å
?ßßç é
$strßßè î
:ßßï ñ
$strßßó ô
)ßßô ö
}ßßö õ
{ßßõ ú
Countßßú °
(ßß° ¢
ticketsßß¢ ©
,ßß© ™
$strßß´ ≥
,ßß≥ ¥
$strßßµ æ
)ßßæ ø
}ßßø ¿
$strßß¿ ¬
{ßß¬ √
(ßß√ ƒ
productsßßƒ Ã
>ßßÕ Œ
$numßßœ –
?ßß— “
$strßß” ñ
:ßßó ò
$strßßô Ê
)ßßÊ Á
}ßßÁ Ë
$strßßË È
"ßßÈ Í
}ßßÎ Ï
)ßßÏ Ì
;ßßÌ Ó
db
®® 

.
®®
 !
ProjectRepositories
®® 
.
®® 
RemoveRange
®® *
(
®®* +
project
®®+ 2
.
®®2 3
Repositories
®®3 ?
)
®®? @
;
®®@ A
db
®®B D
.
®®D E
Projects
®®E M
.
®®M N
Remove
®®N T
(
®®T U
project
®®U \
)
®®\ ]
;
®®] ^
await
©© 
db
©© 
.
©© 
SaveChangesAsync
©© !
(
©©! "
ct
©©" $
)
©©$ %
;
©©% &
return
©©' -
	NoContent
©©. 7
(
©©7 8
)
©©8 9
;
©©9 :
}
™™ 
private
¨¨ 
static
¨¨ 
string
¨¨ 
Count
¨¨ 
(
¨¨  
int
¨¨  #
n
¨¨$ %
,
¨¨% &
string
¨¨' -
one
¨¨. 1
,
¨¨1 2
string
¨¨3 9
many
¨¨: >
)
¨¨> ?
=>
¨¨@ B
n
¨¨C D
switch
¨¨E K
{
¨¨L M
$num
¨¨N O
=>
¨¨P R
$str
¨¨S U
,
¨¨U V
$num
¨¨W X
=>
¨¨Y [
$"
¨¨\ ^
$str
¨¨^ `
{
¨¨` a
one
¨¨a d
}
¨¨d e
"
¨¨e f
,
¨¨f g
_
¨¨h i
=>
¨¨j l
$"
¨¨m o
{
¨¨o p
n
¨¨p q
}
¨¨q r
$str
¨¨r s
{
¨¨s t
many
¨¨t x
}
¨¨x y
"
¨¨y z
}
¨¨{ |
;
¨¨| }
[
ÆÆ 
HttpPost
ÆÆ 
(
ÆÆ 
$str
ÆÆ /
)
ÆÆ/ 0
]
ÆÆ0 1
public
ØØ 

async
ØØ 
Task
ØØ 
<
ØØ 
ActionResult
ØØ "
>
ØØ" #
AddRepository
ØØ$ 1
(
ØØ1 2
Guid
ØØ2 6
id
ØØ7 9
,
ØØ9 :
RepositoryRequest
ØØ; L
request
ØØM T
,
ØØT U
CancellationToken
ØØV g
ct
ØØh j
)
ØØj k
{
∞∞ 
var
±± 
project
±± 
=
±± 
await
±± 
db
±± 
.
±± 
Projects
±± '
.
±±' (
Include
±±( /
(
±±/ 0
x
±±0 1
=>
±±2 4
x
±±5 6
.
±±6 7
Repositories
±±7 C
)
±±C D
.
±±D E"
SingleOrDefaultAsync
±±E Y
(
±±Y Z
x
±±Z [
=>
±±\ ^
x
±±_ `
.
±±` a
Id
±±a c
==
±±d f
id
±±g i
,
±±i j
ct
±±k m
)
±±m n
;
±±n o
if
±±p r
(
±±s t
project
±±t {
is
±±| ~
null±± É
)±±É Ñ
return±±Ö ã
NotFound±±å î
(±±î ï
)±±ï ñ
;±±ñ ó
if
≤≤ 

(
≤≤ 
string
≤≤ 
.
≤≤  
IsNullOrWhiteSpace
≤≤ %
(
≤≤% &
request
≤≤& -
.
≤≤- .
Owner
≤≤. 3
)
≤≤3 4
||
≤≤5 7
string
≤≤8 >
.
≤≤> ? 
IsNullOrWhiteSpace
≤≤? Q
(
≤≤Q R
request
≤≤R Y
.
≤≤Y Z
Name
≤≤Z ^
)
≤≤^ _
)
≤≤_ `
return
≤≤a g

BadRequest
≤≤h r
(
≤≤r s
new
≤≤s v
{
≤≤w x
message≤≤y Ä
=≤≤Å Ç
$str≤≤É ±
}≤≤≤ ≥
)≤≤≥ ¥
;≤≤¥ µ
var
≥≥ 

repository
≥≥ 
=
≥≥ 
new
≥≥ 
ProjectRepository
≥≥ .
{
≥≥/ 0
	ProjectId
≥≥1 :
=
≥≥; <
id
≥≥= ?
,
≥≥? @
Owner
≥≥A F
=
≥≥G H
request
≥≥I P
.
≥≥P Q
Owner
≥≥Q V
.
≥≥V W
Trim
≥≥W [
(
≥≥[ \
)
≥≥\ ]
,
≥≥] ^
Name
≥≥_ c
=
≥≥d e
request
≥≥f m
.
≥≥m n
Name
≥≥n r
.
≥≥r s
Trim
≥≥s w
(
≥≥w x
)
≥≥x y
,
≥≥y z
Label≥≥{ Ä
=≥≥Å Ç
EmptyToNull≥≥É é
(≥≥é è
request≥≥è ñ
.≥≥ñ ó
Label≥≥ó ú
)≥≥ú ù
,≥≥ù û
	IsDefault≥≥ü ®
=≥≥© ™
project≥≥´ ≤
.≥≥≤ ≥
Repositories≥≥≥ ø
.≥≥ø ¿
Count≥≥¿ ≈
==≥≥∆ »
$num≥≥…  
||≥≥À Õ
request≥≥Œ ’
.≥≥’ ÷
	IsDefault≥≥÷ ﬂ
==≥≥‡ ‚
true≥≥„ Á
}≥≥Ë È
;≥≥È Í
if
¥¥ 

(
¥¥ 
await
¥¥ %
RepositoryConflictAsync
¥¥ )
(
¥¥) *

repository
¥¥* 4
.
¥¥4 5
Owner
¥¥5 :
,
¥¥: ;

repository
¥¥< F
.
¥¥F G
Name
¥¥G K
,
¥¥K L
null
¥¥M Q
,
¥¥Q R
ct
¥¥S U
)
¥¥U V
is
¥¥W Y
{
¥¥Z [
}
¥¥\ ]
conflict
¥¥^ f
)
¥¥f g
return
¥¥h n
conflict
¥¥o w
;
¥¥w x
if
µµ 

(
µµ 

repository
µµ 
.
µµ 
	IsDefault
µµ  
)
µµ  !
foreach
µµ" )
(
µµ* +
var
µµ+ .
other
µµ/ 4
in
µµ5 7
project
µµ8 ?
.
µµ? @
Repositories
µµ@ L
)
µµL M
other
µµN S
.
µµS T
	IsDefault
µµT ]
=
µµ^ _
false
µµ` e
;
µµe f
db
∂∂ 

.
∂∂
 !
ProjectRepositories
∂∂ 
.
∂∂ 
Add
∂∂ "
(
∂∂" #

repository
∂∂# -
)
∂∂- .
;
∂∂. /
project
∂∂0 7
.
∂∂7 8
Repositories
∂∂8 D
.
∂∂D E
Add
∂∂E H
(
∂∂H I

repository
∂∂I S
)
∂∂S T
;
∂∂T U
await
∂∂V [
db
∂∂\ ^
.
∂∂^ _
SaveChangesAsync
∂∂_ o
(
∂∂o p
ct
∂∂p r
)
∂∂r s
;
∂∂s t
return
∑∑ 
Ok
∑∑ 
(
∑∑ 

ProjectDto
∑∑ 
(
∑∑ 
project
∑∑ $
)
∑∑$ %
)
∑∑% &
;
∑∑& '
}
∏∏ 
[
∫∫ 
	HttpPatch
∫∫ 
(
∫∫ 
$str
∫∫ '
)
∫∫' (
]
∫∫( )
public
ªª 

async
ªª 
Task
ªª 
<
ªª 
ActionResult
ªª "
>
ªª" #
UpdateRepository
ªª$ 4
(
ªª4 5
Guid
ªª5 9
id
ªª: <
,
ªª< =
RepositoryRequest
ªª> O
request
ªªP W
,
ªªW X
CancellationToken
ªªY j
ct
ªªk m
)
ªªm n
{
ºº 
var
ΩΩ 

repository
ΩΩ 
=
ΩΩ 
await
ΩΩ 
db
ΩΩ !
.
ΩΩ! "!
ProjectRepositories
ΩΩ" 5
.
ΩΩ5 6
	FindAsync
ΩΩ6 ?
(
ΩΩ? @
[
ΩΩ@ A
id
ΩΩA C
]
ΩΩC D
,
ΩΩD E
ct
ΩΩF H
)
ΩΩH I
;
ΩΩI J
if
ΩΩK M
(
ΩΩN O

repository
ΩΩO Y
is
ΩΩZ \
null
ΩΩ] a
)
ΩΩa b
return
ΩΩc i
NotFound
ΩΩj r
(
ΩΩr s
)
ΩΩs t
;
ΩΩt u
var
ææ 
project
ææ 
=
ææ 
await
ææ 
db
ææ 
.
ææ 
Projects
ææ '
.
ææ' (
Include
ææ( /
(
ææ/ 0
x
ææ0 1
=>
ææ2 4
x
ææ5 6
.
ææ6 7
Repositories
ææ7 C
)
ææC D
.
ææD E
SingleAsync
ææE P
(
ææP Q
x
ææQ R
=>
ææS U
x
ææV W
.
ææW X
Id
ææX Z
==
ææ[ ]

repository
ææ^ h
.
ææh i
	ProjectId
ææi r
,
æær s
ct
ææt v
)
ææv w
;
ææw x
var
øø 
owner
øø 
=
øø 
request
øø 
.
øø 
Owner
øø !
?
øø! "
.
øø" #
Trim
øø# '
(
øø' (
)
øø( )
??
øø* ,

repository
øø- 7
.
øø7 8
Owner
øø8 =
;
øø= >
var
øø? B
name
øøC G
=
øøH I
request
øøJ Q
.
øøQ R
Name
øøR V
?
øøV W
.
øøW X
Trim
øøX \
(
øø\ ]
)
øø] ^
??
øø_ a

repository
øøb l
.
øøl m
Name
øøm q
;
øøq r
if
¿¿ 

(
¿¿ 
owner
¿¿ 
.
¿¿ 
Length
¿¿ 
==
¿¿ 
$num
¿¿ 
||
¿¿  
name
¿¿! %
.
¿¿% &
Length
¿¿& ,
==
¿¿- /
$num
¿¿0 1
)
¿¿1 2
return
¿¿3 9

BadRequest
¿¿: D
(
¿¿D E
new
¿¿E H
{
¿¿I J
message
¿¿K R
=
¿¿S T
$str¿¿U É
}¿¿Ñ Ö
)¿¿Ö Ü
;¿¿Ü á
if
¬¬ 

(
¬¬ 
(
¬¬ 
owner
¬¬ 
!=
¬¬ 

repository
¬¬  
.
¬¬  !
Owner
¬¬! &
||
¬¬' )
name
¬¬* .
!=
¬¬/ 1

repository
¬¬2 <
.
¬¬< =
Name
¬¬= A
)
¬¬A B
&&
¬¬C E
await
¬¬F K
db
¬¬L N
.
¬¬N O
Tickets
¬¬O V
.
¬¬V W
AnyAsync
¬¬W _
(
¬¬_ `
x
¬¬` a
=>
¬¬b d
x
¬¬e f
.
¬¬f g
RepositoryId
¬¬g s
==
¬¬t v
id
¬¬w y
&&
¬¬z |
x
¬¬} ~
.
¬¬~  
GithubIssueNumber¬¬ ê
!=¬¬ë ì
null¬¬î ò
,¬¬ò ô
ct¬¬ö ú
)¬¬ú ù
)¬¬ù û
return
√√ 
Conflict
√√ 
(
√√ 
new
√√ 
{
√√  !
message
√√" )
=
√√* +
$str√√, Ä
}√√Å Ç
)√√Ç É
;√√É Ñ
if
ƒƒ 

(
ƒƒ 
await
ƒƒ %
RepositoryConflictAsync
ƒƒ )
(
ƒƒ) *
owner
ƒƒ* /
,
ƒƒ/ 0
name
ƒƒ1 5
,
ƒƒ5 6
id
ƒƒ7 9
,
ƒƒ9 :
ct
ƒƒ; =
)
ƒƒ= >
is
ƒƒ? A
{
ƒƒB C
}
ƒƒD E
conflict
ƒƒF N
)
ƒƒN O
return
ƒƒP V
conflict
ƒƒW _
;
ƒƒ_ `

repository
≈≈ 
.
≈≈ 
Owner
≈≈ 
=
≈≈ 
owner
≈≈  
;
≈≈  !

repository
≈≈" ,
.
≈≈, -
Name
≈≈- 1
=
≈≈2 3
name
≈≈4 8
;
≈≈8 9
if
∆∆ 

(
∆∆ 
request
∆∆ 
.
∆∆ 
Label
∆∆ 
is
∆∆ 
not
∆∆  
null
∆∆! %
)
∆∆% &

repository
∆∆' 1
.
∆∆1 2
Label
∆∆2 7
=
∆∆8 9
EmptyToNull
∆∆: E
(
∆∆E F
request
∆∆F M
.
∆∆M N
Label
∆∆N S
)
∆∆S T
;
∆∆T U
if
«« 

(
«« 
request
«« 
.
«« 
	IsDefault
«« 
==
««  
true
««! %
)
««% &
foreach
««' .
(
««/ 0
var
««0 3
other
««4 9
in
««: <
project
««= D
.
««D E
Repositories
««E Q
)
««Q R
other
««S X
.
««X Y
	IsDefault
««Y b
=
««c d
other
««e j
.
««j k
Id
««k m
==
««n p
id
««q s
;
««s t
await
»» 
db
»» 
.
»» 
SaveChangesAsync
»» !
(
»»! "
ct
»»" $
)
»»$ %
;
»»% &
return
»»' -
Ok
»». 0
(
»»0 1

ProjectDto
»»1 ;
(
»»; <
project
»»< C
)
»»C D
)
»»D E
;
»»E F
}
…… 
[
ÀÀ 

HttpDelete
ÀÀ 
(
ÀÀ 
$str
ÀÀ (
)
ÀÀ( )
]
ÀÀ) *
public
ÃÃ 

async
ÃÃ 
Task
ÃÃ 
<
ÃÃ 
ActionResult
ÃÃ "
>
ÃÃ" #
DeleteRepository
ÃÃ$ 4
(
ÃÃ4 5
Guid
ÃÃ5 9
id
ÃÃ: <
,
ÃÃ< =
CancellationToken
ÃÃ> O
ct
ÃÃP R
)
ÃÃR S
{
ÕÕ 
var
ŒŒ 

repository
ŒŒ 
=
ŒŒ 
await
ŒŒ 
db
ŒŒ !
.
ŒŒ! "!
ProjectRepositories
ŒŒ" 5
.
ŒŒ5 6
	FindAsync
ŒŒ6 ?
(
ŒŒ? @
[
ŒŒ@ A
id
ŒŒA C
]
ŒŒC D
,
ŒŒD E
ct
ŒŒF H
)
ŒŒH I
;
ŒŒI J
if
ŒŒK M
(
ŒŒN O

repository
ŒŒO Y
is
ŒŒZ \
null
ŒŒ] a
)
ŒŒa b
return
ŒŒc i
NotFound
ŒŒj r
(
ŒŒr s
)
ŒŒs t
;
ŒŒt u
if
œœ 

(
œœ 
await
œœ 
db
œœ 
.
œœ 
Tickets
œœ 
.
œœ 
AnyAsync
œœ %
(
œœ% &
x
œœ& '
=>
œœ( *
x
œœ+ ,
.
œœ, -
RepositoryId
œœ- 9
==
œœ: <
id
œœ= ?
,
œœ? @
ct
œœA C
)
œœC D
)
œœD E
return
œœF L
Conflict
œœM U
(
œœU V
new
œœV Y
{
œœZ [
message
œœ\ c
=
œœd e
$strœœf £
}œœ§ •
)œœ• ¶
;œœ¶ ß
var
–– 
project
–– 
=
–– 
await
–– 
db
–– 
.
–– 
Projects
–– '
.
––' (
Include
––( /
(
––/ 0
x
––0 1
=>
––2 4
x
––5 6
.
––6 7
Repositories
––7 C
)
––C D
.
––D E
SingleAsync
––E P
(
––P Q
x
––Q R
=>
––S U
x
––V W
.
––W X
Id
––X Z
==
––[ ]

repository
––^ h
.
––h i
	ProjectId
––i r
,
––r s
ct
––t v
)
––v w
;
––w x
project
—— 
.
—— 
Repositories
—— 
.
—— 
Remove
—— #
(
——# $

repository
——$ .
)
——. /
;
——/ 0
db
——1 3
.
——3 4!
ProjectRepositories
——4 G
.
——G H
Remove
——H N
(
——N O

repository
——O Y
)
——Y Z
;
——Z [
if
““ 

(
““ 

repository
““ 
.
““ 
	IsDefault
““  
&&
““! #
project
““$ +
.
““+ ,
Repositories
““, 8
.
““8 9
FirstOrDefault
““9 G
(
““G H
)
““H I
is
““J L
{
““M N
}
““O P
next
““Q U
)
““U V
next
““W [
.
““[ \
	IsDefault
““\ e
=
““f g
true
““h l
;
““l m
await
”” 
db
”” 
.
”” 
SaveChangesAsync
”” !
(
””! "
ct
””" $
)
””$ %
;
””% &
return
””' -
Ok
””. 0
(
””0 1

ProjectDto
””1 ;
(
””; <
project
””< C
)
””C D
)
””D E
;
””E F
}
‘‘ 
private
÷÷ 
async
÷÷ 
Task
÷÷ 
<
÷÷ 
ActionResult
÷÷ #
?
÷÷# $
>
÷÷$ %%
RepositoryConflictAsync
÷÷& =
(
÷÷= >
string
÷÷> D
owner
÷÷E J
,
÷÷J K
string
÷÷L R
name
÷÷S W
,
÷÷W X
Guid
÷÷Y ]
?
÷÷] ^
exceptId
÷÷_ g
,
÷÷g h
CancellationToken
÷÷i z
ct
÷÷{ }
)
÷÷} ~
=>÷÷ Å
await
◊◊ 
db
◊◊ 
.
◊◊ !
ProjectRepositories
◊◊ $
.
◊◊$ %
AnyAsync
◊◊% -
(
◊◊- .
x
◊◊. /
=>
◊◊0 2
x
◊◊3 4
.
◊◊4 5
Owner
◊◊5 :
==
◊◊; =
owner
◊◊> C
&&
◊◊D F
x
◊◊G H
.
◊◊H I
Name
◊◊I M
==
◊◊N P
name
◊◊Q U
&&
◊◊V X
x
◊◊Y Z
.
◊◊Z [
Id
◊◊[ ]
!=
◊◊^ `
exceptId
◊◊a i
,
◊◊i j
ct
◊◊k m
)
◊◊m n
?
ÿÿ 
Conflict
ÿÿ 
(
ÿÿ 
new
ÿÿ 
{
ÿÿ 
message
ÿÿ $
=
ÿÿ% &
$"
ÿÿ' )
$str
ÿÿ) 8
{
ÿÿ8 9
owner
ÿÿ9 >
}
ÿÿ> ?
$str
ÿÿ? @
{
ÿÿ@ A
name
ÿÿA E
}
ÿÿE F
$str
ÿÿF f
"
ÿÿf g
}
ÿÿh i
)
ÿÿi j
:
ÿÿk l
null
ÿÿm q
;
ÿÿq r
private
€€ 
async
€€ 
Task
€€ 
<
€€ 
ClientAccess
€€ #
>
€€# $
EmailAccessAsync
€€% 5
(
€€5 6
Client
€€6 <
client
€€= C
,
€€C D
ClientAccess
€€E Q
access
€€R X
,
€€X Y
CancellationToken
€€Z k
ct
€€l n
)
€€n o
=>
€€p r
access
‹‹ 
with
‹‹ 
{
‹‹ 
	EmailSent
‹‹ 
=
‹‹  !
await
‹‹" '
accessEmail
‹‹( 3
.
‹‹3 4
	SendAsync
‹‹4 =
(
‹‹= >
client
‹‹> D
,
‹‹D E
client
‹‹F L
.
‹‹L M
ContactName
‹‹M X
,
‹‹X Y
access
‹‹Z `
.
‹‹` a
Email
‹‹a f
,
‹‹f g
access
‹‹h n
.
‹‹n o 
TemporaryPassword‹‹o Ä
,‹‹Ä Å
Request‹‹Ç â
,‹‹â ä
ct‹‹ã ç
)‹‹ç é
}‹‹è ê
;‹‹ê ë
private
ﬁﬁ 
ClientAccess
ﬁﬁ 
AddAdminUser
ﬁﬁ %
(
ﬁﬁ% &
Client
ﬁﬁ& ,
client
ﬁﬁ- 3
)
ﬁﬁ3 4
{
ﬂﬂ 
var
‡‡ 
temporaryPassword
‡‡ 
=
‡‡ 
AccountController
‡‡  1
.
‡‡1 2
TemporaryPassword
‡‡2 C
(
‡‡C D
)
‡‡D E
;
‡‡E F
var
·· 
user
·· 
=
·· 
new
·· 
UserAccount
·· "
{
··# $
ClientId
··% -
=
··. /
client
··0 6
.
··6 7
Id
··7 9
,
··9 :
Name
··; ?
=
··@ A
client
··B H
.
··H I
ContactName
··I T
,
··T U
Email
··V [
=
··\ ]
client
··^ d
.
··d e
Email
··e j
,
··j k
Role
··l p
=
··q r
UserRole
··s {
.
··{ |
Admin··| Å
}··Ç É
;··É Ñ
user
‚‚ 
.
‚‚ 
PasswordHash
‚‚ 
=
‚‚ 
AccountController
‚‚ -
.
‚‚- .
Hasher
‚‚. 4
.
‚‚4 5
HashPassword
‚‚5 A
(
‚‚A B
user
‚‚B F
,
‚‚F G
temporaryPassword
‚‚H Y
)
‚‚Y Z
;
‚‚Z [
db
„„ 

.
„„
 
UserAccounts
„„ 
.
„„ 
Add
„„ 
(
„„ 
user
„„  
)
„„  !
;
„„! "
return
‰‰ 
new
‰‰ 
ClientAccess
‰‰ 
(
‰‰  
client
‰‰  &
.
‰‰& '
CompanyName
‰‰' 2
,
‰‰2 3
user
‰‰4 8
.
‰‰8 9
Email
‰‰9 >
,
‰‰> ?
temporaryPassword
‰‰@ Q
)
‰‰Q R
;
‰‰R S
}
ÂÂ 
internal
ÁÁ 
static
ÁÁ 
string
ÁÁ 
Slugify
ÁÁ "
(
ÁÁ" #
string
ÁÁ# )
value
ÁÁ* /
)
ÁÁ/ 0
{
ËË 
var
ÈÈ 

normalized
ÈÈ 
=
ÈÈ 
value
ÈÈ 
.
ÈÈ 
Trim
ÈÈ #
(
ÈÈ# $
)
ÈÈ$ %
.
ÈÈ% &
ToLowerInvariant
ÈÈ& 6
(
ÈÈ6 7
)
ÈÈ7 8
.
ÈÈ8 9
	Normalize
ÈÈ9 B
(
ÈÈB C
System
ÈÈC I
.
ÈÈI J
Text
ÈÈJ N
.
ÈÈN O
NormalizationForm
ÈÈO `
.
ÈÈ` a
FormD
ÈÈa f
)
ÈÈf g
;
ÈÈg h
var
ÍÍ 
chars
ÍÍ 
=
ÍÍ 

normalized
ÍÍ 
.
ÍÍ 
Where
ÍÍ $
(
ÍÍ$ %
c
ÍÍ% &
=>
ÍÍ' )
System
ÍÍ* 0
.
ÍÍ0 1
Globalization
ÍÍ1 >
.
ÍÍ> ?
CharUnicodeInfo
ÍÍ? N
.
ÍÍN O 
GetUnicodeCategory
ÍÍO a
(
ÍÍa b
c
ÍÍb c
)
ÍÍc d
!=
ÍÍe g
System
ÍÍh n
.
ÍÍn o
Globalization
ÍÍo |
.
ÍÍ| }
UnicodeCategoryÍÍ} å
.ÍÍå ç
NonSpacingMarkÍÍç õ
)ÍÍõ ú
.ÍÍú ù
SelectÍÍù £
(ÍÍ£ §
cÍÍ§ •
=>ÍÍ¶ ®
charÍÍ© ≠
.ÍÍ≠ Æ
IsLetterOrDigitÍÍÆ Ω
(ÍÍΩ æ
cÍÍæ ø
)ÍÍø ¿
?ÍÍ¡ ¬
cÍÍ√ ƒ
:ÍÍ≈ ∆
$charÍÍ«  
)ÍÍ  À
;ÍÍÀ Ã
return
ÎÎ 
System
ÎÎ 
.
ÎÎ 
Text
ÎÎ 
.
ÎÎ  
RegularExpressions
ÎÎ -
.
ÎÎ- .
Regex
ÎÎ. 3
.
ÎÎ3 4
Replace
ÎÎ4 ;
(
ÎÎ; <
new
ÎÎ< ?
string
ÎÎ@ F
(
ÎÎF G
chars
ÎÎG L
.
ÎÎL M
ToArray
ÎÎM T
(
ÎÎT U
)
ÎÎU V
)
ÎÎV W
,
ÎÎW X
$str
ÎÎY `
,
ÎÎ` a
$str
ÎÎb e
)
ÎÎe f
.
ÎÎf g
Trim
ÎÎg k
(
ÎÎk l
$char
ÎÎl o
)
ÎÎo p
;
ÎÎp q
}
ÏÏ 
[
ÓÓ 
HttpGet
ÓÓ 
(
ÓÓ 
$str
ÓÓ 
)
ÓÓ 
]
ÓÓ 
public
ÔÔ 

async
ÔÔ 
Task
ÔÔ 
<
ÔÔ 
ActionResult
ÔÔ "
>
ÔÔ" #
Products
ÔÔ$ ,
(
ÔÔ, -
CancellationToken
ÔÔ- >
ct
ÔÔ? A
)
ÔÔA B
=>
ÔÔC E
Ok
ÔÔF H
(
ÔÔH I
(
ÔÔI J
await
ÔÔJ O
db
ÔÔP R
.
ÔÔR S
Products
ÔÔS [
.
ÔÔ[ \
OrderBy
ÔÔ\ c
(
ÔÔc d
x
ÔÔd e
=>
ÔÔf h
x
ÔÔi j
.
ÔÔj k
Name
ÔÔk o
)
ÔÔo p
.
ÔÔp q
ToListAsync
ÔÔq |
(
ÔÔ| }
ct
ÔÔ} 
)ÔÔ Ä
)ÔÔÄ Å
.ÔÔÅ Ç
SelectÔÔÇ à
(ÔÔà â

ProductDtoÔÔâ ì
)ÔÔì î
)ÔÔî ï
;ÔÔï ñ
[
ÒÒ 
HttpPost
ÒÒ 
(
ÒÒ 
$str
ÒÒ 
)
ÒÒ 
]
ÒÒ 
public
ÚÚ 

async
ÚÚ 
Task
ÚÚ 
<
ÚÚ 
ActionResult
ÚÚ "
>
ÚÚ" #
CreateProduct
ÚÚ$ 1
(
ÚÚ1 2
ProductRequest
ÚÚ2 @
request
ÚÚA H
,
ÚÚH I
CancellationToken
ÚÚJ [
ct
ÚÚ\ ^
)
ÚÚ^ _
{
ÛÛ 
var
ÙÙ 
error
ÙÙ 
=
ÙÙ 
ValidateProduct
ÙÙ #
(
ÙÙ# $
request
ÙÙ$ +
)
ÙÙ+ ,
;
ÙÙ, -
if
ÙÙ. 0
(
ÙÙ1 2
error
ÙÙ2 7
is
ÙÙ8 :
not
ÙÙ; >
null
ÙÙ? C
)
ÙÙC D
return
ÙÙE K

BadRequest
ÙÙL V
(
ÙÙV W
new
ÙÙW Z
{
ÙÙ[ \
message
ÙÙ] d
=
ÙÙe f
error
ÙÙg l
}
ÙÙm n
)
ÙÙn o
;
ÙÙo p
var
ıı 
product
ıı 
=
ıı 
	ToProduct
ıı 
(
ıı  
request
ıı  '
)
ıı' (
;
ıı( )
db
ıı* ,
.
ıı, -
Products
ıı- 5
.
ıı5 6
Add
ıı6 9
(
ıı9 :
product
ıı: A
)
ııA B
;
ııB C
await
ııD I(
EnsureProductCategoryAsync
ııJ d
(
ııd e
product
ııe l
.
ııl m
Category
ıım u
,
ııu v
ct
ııw y
)
ııy z
;
ıız {
awaitıı| Å
dbııÇ Ñ
.ııÑ Ö 
SaveChangesAsyncııÖ ï
(ııï ñ
ctııñ ò
)ııò ô
;ııô ö
returnııõ °
Createdıı¢ ©
(ıı© ™
$"ıı™ ¨
$strıı¨ ¿
{ıı¿ ¡
productıı¡ »
.ıı» …
Idıı… À
}ııÀ Ã
"ııÃ Õ
,ııÕ Œ

ProductDtoııœ Ÿ
(ııŸ ⁄
productıı⁄ ·
)ıı· ‚
)ıı‚ „
;ıı„ ‰
}
ˆˆ 
[
¯¯ 
	HttpPatch
¯¯ 
(
¯¯ 
$str
¯¯ #
)
¯¯# $
]
¯¯$ %
public
˘˘ 

async
˘˘ 
Task
˘˘ 
<
˘˘ 
ActionResult
˘˘ "
>
˘˘" #
UpdateProduct
˘˘$ 1
(
˘˘1 2
Guid
˘˘2 6
id
˘˘7 9
,
˘˘9 :!
ProductPatchRequest
˘˘; N
request
˘˘O V
,
˘˘V W
CancellationToken
˘˘X i
ct
˘˘j l
)
˘˘l m
{
˙˙ 
var
˚˚ 
product
˚˚ 
=
˚˚ 
await
˚˚ 
db
˚˚ 
.
˚˚ 
Products
˚˚ '
.
˚˚' (
	FindAsync
˚˚( 1
(
˚˚1 2
[
˚˚2 3
id
˚˚3 5
]
˚˚5 6
,
˚˚6 7
ct
˚˚8 :
)
˚˚: ;
;
˚˚; <
if
˚˚= ?
(
˚˚@ A
product
˚˚A H
is
˚˚I K
null
˚˚L P
)
˚˚P Q
return
˚˚R X
NotFound
˚˚Y a
(
˚˚a b
)
˚˚b c
;
˚˚c d
if
¸¸ 

(
¸¸ 
request
¸¸ 
.
¸¸ 
Type
¸¸ 
is
¸¸ 
ProductType
¸¸ '
type
¸¸( ,
)
¸¸, -
product
¸¸. 5
.
¸¸5 6
Type
¸¸6 :
=
¸¸; <
type
¸¸= A
;
¸¸A B
if
¸¸C E
(
¸¸F G
request
¸¸G N
.
¸¸N O
Name
¸¸O S
is
¸¸T V
not
¸¸W Z
null
¸¸[ _
)
¸¸_ `
product
¸¸a h
.
¸¸h i
Name
¸¸i m
=
¸¸n o
request
¸¸p w
.
¸¸w x
Name
¸¸x |
.
¸¸| }
Trim¸¸} Å
(¸¸Å Ç
)¸¸Ç É
;¸¸É Ñ
if¸¸Ö á
(¸¸à â
request¸¸â ê
.¸¸ê ë
BillingCycle¸¸ë ù
is¸¸û †
BillingCycle¸¸° ≠
cycle¸¸Æ ≥
)¸¸≥ ¥
product¸¸µ º
.¸¸º Ω
BillingCycle¸¸Ω …
=¸¸  À
cycle¸¸Ã —
;¸¸— “
if¸¸” ’
(¸¸÷ ◊
request¸¸◊ ﬁ
.¸¸ﬁ ﬂ
	BasePrice¸¸ﬂ Ë
is¸¸È Î
not¸¸Ï Ô
null¸¸ Ù
)¸¸Ù ı
product¸¸ˆ ˝
.¸¸˝ ˛
	BasePrice¸¸˛ á
=¸¸à â
request¸¸ä ë
.¸¸ë í
	BasePrice¸¸í õ
;¸¸õ ú
if¸¸ù ü
(¸¸† °
request¸¸° ®
.¸¸® ©
Currency¸¸© ±
is¸¸≤ ¥
not¸¸µ ∏
null¸¸π Ω
)¸¸Ω æ
product¸¸ø ∆
.¸¸∆ «
Currency¸¸« œ
=¸¸– —
request¸¸“ Ÿ
.¸¸Ÿ ⁄
Currency¸¸⁄ ‚
.¸¸‚ „
Trim¸¸„ Á
(¸¸Á Ë
)¸¸Ë È
.¸¸È Í 
ToUpperInvariant¸¸Í ˙
(¸¸˙ ˚
)¸¸˚ ¸
;¸¸¸ ˝
if¸¸˛ Ä
(¸¸Å Ç
request¸¸Ç â
.¸¸â ä
Description¸¸ä ï
is¸¸ñ ò
not¸¸ô ú
null¸¸ù °
)¸¸° ¢
product¸¸£ ™
.¸¸™ ´
Description¸¸´ ∂
=¸¸∑ ∏
EmptyToNull¸¸π ƒ
(¸¸ƒ ≈
request¸¸≈ Ã
.¸¸Ã Õ
Description¸¸Õ ÿ
)¸¸ÿ Ÿ
;¸¸Ÿ ⁄
if¸¸€ ›
(¸¸ﬁ ﬂ
request¸¸ﬂ Ê
.¸¸Ê Á
IsActive¸¸Á Ô
is¸¸ Ú
bool¸¸Û ˜
active¸¸¯ ˛
)¸¸˛ ˇ
product¸¸Ä á
.¸¸á à
IsActive¸¸à ê
=¸¸ë í
active¸¸ì ô
;¸¸ô ö
if¸¸õ ù
(¸¸û ü
request¸¸ü ¶
.¸¸¶ ß
Category¸¸ß Ø
is¸¸∞ ≤
not¸¸≥ ∂
null¸¸∑ ª
)¸¸ª º
product¸¸Ω ƒ
.¸¸ƒ ≈
Category¸¸≈ Õ
=¸¸Œ œ
EmptyToNull¸¸– €
(¸¸€ ‹
request¸¸‹ „
.¸¸„ ‰
Category¸¸‰ Ï
)¸¸Ï Ì
;¸¸Ì Ó
if¸¸Ô Ò
(¸¸Ú Û
request¸¸Û ˙
.¸¸˙ ˚
Tags¸¸˚ ˇ
is¸¸Ä Ç
not¸¸É Ü
null¸¸á ã
)¸¸ã å
product¸¸ç î
.¸¸î ï
Tags¸¸ï ô
=¸¸ö õ
NormalizeTags¸¸ú ©
(¸¸© ™
request¸¸™ ±
.¸¸± ≤
Tags¸¸≤ ∂
)¸¸∂ ∑
;¸¸∑ ∏
if¸¸π ª
(¸¸º Ω
request¸¸Ω ƒ
.¸¸ƒ ≈
AllowsTickets¸¸≈ “
is¸¸” ’
bool¸¸÷ ⁄
allowsTickets¸¸€ Ë
)¸¸Ë È
product¸¸Í Ò
.¸¸Ò Ú
AllowsTickets¸¸Ú ˇ
=¸¸Ä Å
allowsTickets¸¸Ç è
;¸¸è ê
if¸¸ë ì
(¸¸î ï
request¸¸ï ú
.¸¸ú ù
TaxDocumentType¸¸ù ¨
is¸¸≠ Ø
TaxDocumentType¸¸∞ ø
taxType¸¸¿ «
)¸¸« »
product¸¸… –
.¸¸– —
TaxDocumentType¸¸— ‡
=¸¸· ‚
taxType¸¸„ Í
;¸¸Í Î
if
˝˝ 

(
˝˝ 
string
˝˝ 
.
˝˝  
IsNullOrWhiteSpace
˝˝ %
(
˝˝% &
product
˝˝& -
.
˝˝- .
Name
˝˝. 2
)
˝˝2 3
||
˝˝4 6
string
˝˝7 =
.
˝˝= > 
IsNullOrWhiteSpace
˝˝> P
(
˝˝P Q
product
˝˝Q X
.
˝˝X Y
Currency
˝˝Y a
)
˝˝a b
)
˝˝b c
return
˝˝d j

BadRequest
˝˝k u
(
˝˝u v
new
˝˝v y
{
˝˝z {
message˝˝| É
=˝˝Ñ Ö
$str˝˝Ü ©
}˝˝™ ´
)˝˝´ ¨
;˝˝¨ ≠
await
˛˛ (
EnsureProductCategoryAsync
˛˛ (
(
˛˛( )
product
˛˛) 0
.
˛˛0 1
Category
˛˛1 9
,
˛˛9 :
ct
˛˛; =
)
˛˛= >
;
˛˛> ?
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
SaveChangesAsync
ˇˇ !
(
ˇˇ! "
ct
ˇˇ" $
)
ˇˇ$ %
;
ˇˇ% &
return
ˇˇ' -
Ok
ˇˇ. 0
(
ˇˇ0 1

ProductDto
ˇˇ1 ;
(
ˇˇ; <
product
ˇˇ< C
)
ˇˇC D
)
ˇˇD E
;
ˇˇE F
}
ÄÄ 
[
ÇÇ 
HttpGet
ÇÇ 
(
ÇÇ 
$str
ÇÇ '
)
ÇÇ' (
]
ÇÇ( )
public
ÉÉ 

IActionResult
ÉÉ 
ProductTemplate
ÉÉ (
(
ÉÉ( )
)
ÉÉ) *
=>
ÉÉ+ -
File
ÉÉ. 2
(
ÉÉ2 3
CreateWorkbook
ÉÉ3 A
(
ÉÉA B
new
ÑÑ 
(
ÑÑ 
$str
ÑÑ 
,
ÑÑ 
true
ÑÑ 
,
ÑÑ 
$str
ÑÑ +
,
ÑÑ+ ,
Enum
ÑÑ- 1
.
ÑÑ1 2
GetNames
ÑÑ2 :
<
ÑÑ: ;
ProductType
ÑÑ; F
>
ÑÑF G
(
ÑÑG H
)
ÑÑH I
)
ÑÑI J
,
ÑÑJ K
new
ÖÖ 
(
ÖÖ 
$str
ÖÖ 
,
ÖÖ 
true
ÖÖ 
,
ÖÖ 
$str
ÖÖ G
)
ÖÖG H
,
ÖÖH I
new
ÜÜ 
(
ÜÜ 
$str
ÜÜ 
,
ÜÜ 
true
ÜÜ  
,
ÜÜ  !
$str
ÜÜ" \
,
ÜÜ\ ]
[
ÜÜ^ _
$str
ÜÜ_ f
,
ÜÜf g
$str
ÜÜh q
,
ÜÜq r
$str
ÜÜs ~
,
ÜÜ~ 
$strÜÜÄ å
,ÜÜå ç
$strÜÜé ô
,ÜÜô ö
$strÜÜõ ¢
]ÜÜ¢ £
)ÜÜ£ §
,ÜÜ§ •
new
áá 
(
áá 
$str
áá 
,
áá 
true
áá 
,
áá 
$stráá ™
)áá™ ´
,áá´ ¨
new
àà 
(
àà 
$str
àà 
,
àà 
true
àà 
,
àà 
$str
àà .
,
àà. /
[
àà0 1
$str
àà1 6
,
àà6 7
$str
àà8 =
,
àà= >
$str
àà? D
]
ààD E
)
ààE F
,
ààF G
new
ââ 
(
ââ 
$str
ââ 
,
ââ 
false
ââ  
,
ââ  !
$str
ââ" /
)
ââ/ 0
,
ââ0 1
new
ää 
(
ää 
$str
ää 
,
ää 
false
ää 
,
ää 
$str
ää 5
,
ää5 6
[
ää7 8
$str
ää8 <
,
ää< =
$str
ää> B
]
ääB C
)
ääC D
,
ääD E
new
ãã 
(
ãã 
$str
ãã 
,
ãã 
false
ãã $
,
ãã$ %
$str
ãã& f
,
ããf g
Enum
ããh l
.
ããl m
GetNames
ããm u
<
ããu v
TaxDocumentTypeããv Ö
>ããÖ Ü
(ããÜ á
)ããá à
)ããà â
,ããâ ä
new
åå 
(
åå 
$str
åå 
,
åå 
false
åå 
,
åå 
$str
åå C
)
ååC D
,
ååD E
new
çç 
(
çç 
$str
çç 
,
çç 
false
çç 
,
çç 
$str
çç w
)
ççw x
,
ççx y
new
éé 
(
éé 
$str
éé 
,
éé 
false
éé "
,
éé" #
$str
éé$ r
,
éér s
[
éét u
$str
ééu y
,
ééy z
$str
éé{ 
]éé Ä
)ééÄ Å
)ééÅ Ç
,ééÇ É
$str
èè K
,
èèK L
$str
èèM g
)
èèg h
;
èèh i
[
ëë 
HttpPost
ëë 
(
ëë 
$str
ëë 
)
ëë  
]
ëë  !
public
íí 

async
íí 
Task
íí 
<
íí 
ActionResult
íí "
>
íí" #
ImportProducts
íí$ 2
(
íí2 3
	IFormFile
íí3 <
file
íí= A
,
ííA B
CancellationToken
ííC T
ct
ííU W
)
ííW X
{
ìì 
var
îî 
(
îî 
failure
îî 
,
îî 
created
îî 
,
îî 
errors
îî %
)
îî% &
=
îî' (
await
îî) .
Import
îî/ 5
(
îî5 6
file
îî6 :
,
îî: ;
$str
îî< G
,
îîG H
async
îîI N
(
îîO P
row
îîP S
,
îîS T
	rowNumber
îîU ^
,
îî^ _
errors
îî` f
)
îîf g
=>
îîh j
{
ïï 
var
ññ 
error
ññ 
=
ññ 
ParseProductRow
ññ #
(
ññ# $
row
ññ$ '
,
ññ' (
out
ññ) ,
var
ññ- 0
product
ññ1 8
)
ññ8 9
;
ññ9 :
if
óó 

(
óó 
error
óó 
is
óó 
not
óó 
null
óó 
)
óó 
{
óó  
errors
óó! '
.
óó' (
Add
óó( +
(
óó+ ,
new
óó, /
(
óó/ 0
	rowNumber
óó0 9
,
óó9 :
error
óó; @
)
óó@ A
)
óóA B
;
óóB C
return
óóD J
false
óóK P
;
óóP Q
}
óóR S
db
òò 

.
òò
 
Products
òò 
.
òò 
Add
òò 
(
òò 
product
òò 
!
òò  
)
òò  !
;
òò! "
await
òò# ((
EnsureProductCategoryAsync
òò) C
(
òòC D
product
òòD K
!
òòK L
.
òòL M
Category
òòM U
,
òòU V
ct
òòW Y
)
òòY Z
;
òòZ [
return
òò\ b
true
òòc g
;
òòg h
}
ôô 	
,
ôô	 

ct
ôô 
)
ôô 
;
ôô 
return
öö 
failure
öö 
??
öö 
Ok
öö 
(
öö 
new
öö  
{
öö! "
created
öö# *
,
öö* +
skipped
öö, 3
=
öö4 5
errors
öö6 <
.
öö< =
Count
öö= B
,
ööB C
errors
ööD J
}
ööK L
)
ööL M
;
ööM N
}
õõ 
[
ùù 
HttpPost
ùù 
(
ùù 
$str
ùù 0
)
ùù0 1
]
ùù1 2
public
ûû 

async
ûû 
Task
ûû 
<
ûû 
ActionResult
ûû "
>
ûû" #
AssignProduct
ûû$ 1
(
ûû1 2
Guid
ûû2 6
clientId
ûû7 ?
,
ûû? @"
AssignProductRequest
ûûA U
request
ûûV ]
,
ûû] ^
CancellationToken
ûû_ p
ct
ûûq s
)
ûûs t
{
üü 
if
†† 

(
†† 
!
†† 
await
†† 
db
†† 
.
†† 
Clients
†† 
.
†† 
AnyAsync
†† &
(
††& '
x
††' (
=>
††) +
x
††, -
.
††- .
Id
††. 0
==
††1 3
clientId
††4 <
,
††< =
ct
††> @
)
††@ A
||
††B D
!
††E F
await
††F K
db
††L N
.
††N O
Projects
††O W
.
††W X
AnyAsync
††X `
(
††` a
x
††a b
=>
††c e
x
††f g
.
††g h
Id
††h j
==
††k m
request
††n u
.
††u v
	ProjectId
††v 
&&††Ä Ç
x††É Ñ
.††Ñ Ö
ClientId††Ö ç
==††é ê
clientId††ë ô
,††ô ö
ct††õ ù
)††ù û
)††û ü
return††† ¶
NotFound††ß Ø
(††Ø ∞
)††∞ ±
;††± ≤
var
°° 
product
°° 
=
°° 
await
°° 
db
°° 
.
°° 
Products
°° '
.
°°' (
	FindAsync
°°( 1
(
°°1 2
[
°°2 3
request
°°3 :
.
°°: ;
	ProductId
°°; D
]
°°D E
,
°°E F
ct
°°G I
)
°°I J
;
°°J K
if
°°L N
(
°°O P
product
°°P W
is
°°X Z
null
°°[ _
)
°°_ `
return
°°a g
NotFound
°°h p
(
°°p q
)
°°q r
;
°°r s
if
¢¢ 

(
¢¢ 
request
¢¢ 
.
¢¢ 
BillingMode
¢¢ 
is
¢¢  "
not
¢¢# &
(
¢¢' (
$str
¢¢( 0
or
¢¢1 3
$str
¢¢4 <
)
¢¢< =
)
¢¢= >
return
¢¢? E

BadRequest
¢¢F P
(
¢¢P Q
new
¢¢Q T
{
¢¢U V
message
¢¢W ^
=
¢¢_ `
$str¢¢a Ä
}¢¢Å Ç
)¢¢Ç É
;¢¢É Ñ
if
££ 

(
££ 
request
££ 
.
££ 
BillingMode
££ 
==
££  "
$str
££# +
&&
££, .
await
££/ 4
db
££5 7
.
££7 8
PaymentSettings
££8 G
.
££G H
AnyAsync
££H P
(
££P Q
x
££Q R
=>
££S U
!
££V W
x
££W X
.
££X Y
PayPalEnabled
££Y f
,
££f g
ct
££h j
)
££j k
)
££k l
return
££m s

BadRequest
££t ~
(
££~ 
new££ Ç
{££É Ñ
message££Ö å
=££ç é
$str££è ‚
}££„ ‰
)££‰ Â
;££Â Ê
var
§§ 
item
§§ 
=
§§ 
new
§§ 
ClientProduct
§§ $
{
§§% &
ClientId
§§' /
=
§§0 1
clientId
§§2 :
,
§§: ;
	ProjectId
§§< E
=
§§F G
request
§§H O
.
§§O P
	ProjectId
§§P Y
,
§§Y Z
	ProductId
§§[ d
=
§§e f
product
§§g n
.
§§n o
Id
§§o q
,
§§q r
BillingCycle
§§s 
=§§Ä Å
request§§Ç â
.§§â ä
BillingCycle§§ä ñ
,§§ñ ó
IsManualBilling§§ò ß
=§§® ©
request§§™ ±
.§§± ≤
BillingMode§§≤ Ω
==§§æ ¿
$str§§¡ …
,§§…  
Status§§À —
=§§“ ”
request§§‘ €
.§§€ ‹
BillingMode§§‹ Á
==§§Ë Í
$str§§Î Û
?§§Ù ı#
ClientProductStatus§§ˆ â
.§§â ä
Activo§§ä ê
:§§ë í#
ClientProductStatus§§ì ¶
.§§¶ ß
	Pendiente§§ß ∞
,§§∞ ±
Price§§≤ ∑
=§§∏ π
product§§∫ ¡
.§§¡ ¬
	BasePrice§§¬ À
is§§Ã Œ
null§§œ ”
?§§‘ ’
request§§÷ ›
.§§› ﬁ
Price§§ﬁ „
:§§‰ Â
null§§Ê Í
,§§Í Î

DomainName§§Ï ˆ
=§§˜ ¯
EmptyToNull§§˘ Ñ
(§§Ñ Ö
request§§Ö å
.§§å ç

DomainName§§ç ó
)§§ó ò
,§§ò ô"
PriceLabelOverride§§ö ¨
=§§≠ Æ
EmptyToNull§§Ø ∫
(§§∫ ª
request§§ª ¬
.§§¬ √"
PriceLabelOverride§§√ ’
)§§’ ÷
,§§÷ ◊
RenewsAt§§ÿ ‡
=§§· ‚
	ToUtcDate§§„ Ï
(§§Ï Ì
request§§Ì Ù
.§§Ù ı
RenewsAt§§ı ˝
)§§˝ ˛
,§§˛ ˇ
NextChargeAt§§Ä å
=§§ç é
	ToUtcDate§§è ò
(§§ò ô
request§§ô †
.§§† °
NextChargeAt§§° ≠
)§§≠ Æ
,§§Æ Ø
Product§§∞ ∑
=§§∏ π
product§§∫ ¡
}§§¬ √
;§§√ ƒ
item
•• 
.
•• 
Status
•• 
=
••  
RenewalReminderJob
•• (
.
••( )
	StatusFor
••) 2
(
••2 3
item
••3 7
.
••7 8
Status
••8 >
,
••> ?
item
••@ D
.
••D E
RenewsAt
••E M
,
••M N
DateTime
••O W
.
••W X
UtcNow
••X ^
)
••^ _
;
••_ `
if
¶¶ 

(
¶¶ 
item
¶¶ 
.
¶¶ 
SetDiscount
¶¶ 
(
¶¶ 
request
¶¶ $
.
¶¶$ %
Discount
¶¶% -
)
¶¶- .
is
¶¶/ 1
string
¶¶2 8
discountError
¶¶9 F
)
¶¶F G
return
¶¶H N

BadRequest
¶¶O Y
(
¶¶Y Z
new
¶¶Z ]
{
¶¶^ _
message
¶¶` g
=
¶¶h i
discountError
¶¶j w
}
¶¶x y
)
¶¶y z
;
¶¶z {
db
ßß 

.
ßß
 
ClientProducts
ßß 
.
ßß 
Add
ßß 
(
ßß 
item
ßß "
)
ßß" #
;
ßß# $
var
®® 
igvRate
®® 
=
®® 
await
®® 
db
®® 
.
®® 
IgvRateForAsync
®® .
(
®®. /
clientId
®®/ 7
,
®®7 8
product
®®9 @
,
®®@ A
ct
®®B D
)
®®D E
;
®®E F
if
©© 

(
©© 
request
©© 
.
©© 
BillingMode
©© 
==
©©  "
$str
©©# +
)
©©+ ,
{
™™ 	
try
´´ 
{
¨¨ 
var
≠≠ 
checkout
≠≠ 
=
≠≠ 
await
≠≠ $
checkoutService
≠≠% 4
.
≠≠4 5

StartAsync
≠≠5 ?
(
≠≠? @
item
≠≠@ D
,
≠≠D E
product
≠≠F M
,
≠≠M N
Request
≠≠O V
,
≠≠V W
ct
≠≠X Z
,
≠≠Z [
igvRate
≠≠\ c
)
≠≠c d
;
≠≠d e
await
ÆÆ 
db
ÆÆ 
.
ÆÆ 
SaveChangesAsync
ÆÆ )
(
ÆÆ) *
ct
ÆÆ* ,
)
ÆÆ, -
;
ÆÆ- .
return
ØØ 
Created
ØØ 
(
ØØ 
$"
ØØ !
$str
ØØ! <
{
ØØ< =
item
ØØ= A
.
ØØA B
Id
ØØB D
}
ØØD E
"
ØØE F
,
ØØF G
new
ØØH K
{
ØØL M
clientProduct
ØØN [
=
ØØ\ ]
ClientProductDto
ØØ^ n
(
ØØn o
item
ØØo s
,
ØØs t
igvRate
ØØu |
)
ØØ| }
,
ØØ} ~
approvalUrlØØ ä
=ØØã å
checkoutØØç ï
.ØØï ñ
ApprovalUrlØØñ °
}ØØ¢ £
)ØØ£ §
;ØØ§ •
}
∞∞ 
catch
±± 
(
±± '
InvalidOperationException
±± ,
ex
±±- /
)
±±/ 0
{
±±1 2
return
±±3 9

BadRequest
±±: D
(
±±D E
new
±±E H
{
±±I J
message
±±K R
=
±±S T
ex
±±U W
.
±±W X
Message
±±X _
}
±±` a
)
±±a b
;
±±b c
}
±±d e
}
≤≤ 	
await
≥≥ 
db
≥≥ 
.
≥≥ 
SaveChangesAsync
≥≥ !
(
≥≥! "
ct
≥≥" $
)
≥≥$ %
;
≥≥% &
return
≥≥' -
Created
≥≥. 5
(
≥≥5 6
$"
≥≥6 8
$str
≥≥8 S
{
≥≥S T
item
≥≥T X
.
≥≥X Y
Id
≥≥Y [
}
≥≥[ \
"
≥≥\ ]
,
≥≥] ^
new
≥≥_ b
{
≥≥c d
clientProduct
≥≥e r
=
≥≥s t
ClientProductDto≥≥u Ö
(≥≥Ö Ü
item≥≥Ü ä
,≥≥ä ã
igvRate≥≥å ì
)≥≥ì î
,≥≥î ï
approvalUrl≥≥ñ °
=≥≥¢ £
(≥≥§ •
string≥≥• ´
?≥≥´ ¨
)≥≥¨ ≠
null≥≥≠ ±
}≥≥≤ ≥
)≥≥≥ ¥
;≥≥¥ µ
}
¥¥ 
[
ªª 
HttpPost
ªª 
(
ªª 
$str
ªª 2
)
ªª2 3
]
ªª3 4
public
ºº 

async
ºº 
Task
ºº 
<
ºº 
ActionResult
ºº "
>
ºº" #%
RegisterTransferPayment
ºº$ ;
(
ºº; <
Guid
ºº< @
id
ººA C
,
ººC D$
TransferPaymentRequest
ººE [
request
ºº\ c
,
ººc d
[
ººe f
FromServices
ººf r
]
ººr s#
PayPalPaymentServiceººt à
paymentsººâ ë
,ººë í!
CancellationTokenººì §
ctºº• ß
)ººß ®
{
ΩΩ 
var
ææ 
item
ææ 
=
ææ 
await
ææ 
db
ææ 
.
ææ 
ClientProducts
ææ *
.
ææ* +
Include
ææ+ 2
(
ææ2 3
x
ææ3 4
=>
ææ5 7
x
ææ8 9
.
ææ9 :
Product
ææ: A
)
ææA B
.
ææB C
Include
ææC J
(
ææJ K
x
ææK L
=>
ææM O
x
ææP Q
.
ææQ R
Project
ææR Y
)
ææY Z
.
ææZ ["
SingleOrDefaultAsync
ææ[ o
(
ææo p
x
ææp q
=>
æær t
x
ææu v
.
ææv w
Id
ææw y
==
ææz |
id
ææ} 
,ææ Ä
ctææÅ É
)ææÉ Ñ
;ææÑ Ö
ifææÜ à
(ææâ ä
itemææä é
isææè ë
nullææí ñ
)ææñ ó
returnææò û
NotFoundææü ß
(ææß ®
)ææ® ©
;ææ© ™
if
øø 

(
øø 
!
øø 
item
øø 
.
øø 
IsManualBilling
øø !
)
øø! "
return
øø# )

BadRequest
øø* 4
(
øø4 5
new
øø5 8
{
øø9 :
message
øø; B
=
øøC D
$strøøE á
}øøà â
)øøâ ä
;øøä ã
if
¿¿ 

(
¿¿ 
item
¿¿ 
.
¿¿ 
ValidateYears
¿¿ 
(
¿¿ 
request
¿¿ &
.
¿¿& '
Years
¿¿' ,
)
¿¿, -
is
¿¿. 0
string
¿¿1 7

yearsError
¿¿8 B
)
¿¿B C
return
¿¿D J

BadRequest
¿¿K U
(
¿¿U V
new
¿¿V Y
{
¿¿Z [
message
¿¿\ c
=
¿¿d e

yearsError
¿¿f p
}
¿¿q r
)
¿¿r s
;
¿¿s t
var
¡¡ 
igvRate
¡¡ 
=
¡¡ 
item
¡¡ 
.
¡¡ 
Product
¡¡ "
is
¡¡# %
null
¡¡& *
?
¡¡+ ,
$num
¡¡- /
:
¡¡0 1
await
¡¡2 7
db
¡¡8 :
.
¡¡: ;
IgvRateForAsync
¡¡; J
(
¡¡J K
item
¡¡K O
.
¡¡O P
ClientId
¡¡P X
,
¡¡X Y
item
¡¡Z ^
.
¡¡^ _
Product
¡¡_ f
,
¡¡f g
ct
¡¡h j
)
¡¡j k
;
¡¡k l
var
¬¬ 
amount
¬¬ 
=
¬¬ 
request
¬¬ 
.
¬¬ 
Amount
¬¬ #
??
¬¬$ &
item
¬¬' +
.
¬¬+ ,
ChargeTotal
¬¬, 7
(
¬¬7 8
igvRate
¬¬8 ?
,
¬¬? @
request
¬¬A H
.
¬¬H I
Years
¬¬I N
)
¬¬N O
;
¬¬O P
if
√√ 

(
√√ 
amount
√√ 
is
√√ 
not
√√ 
decimal
√√ !
value
√√" '
||
√√( *
value
√√+ 0
<=
√√1 3
$num
√√4 5
)
√√5 6
return
√√7 =

BadRequest
√√> H
(
√√H I
new
√√I L
{
√√M N
message
√√O V
=
√√W X
$str
√√Y u
}
√√v w
)
√√w x
;
√√x y
var
ƒƒ 
	reference
ƒƒ 
=
ƒƒ 
request
ƒƒ 
.
ƒƒ  
	Reference
ƒƒ  )
?
ƒƒ) *
.
ƒƒ* +
Trim
ƒƒ+ /
(
ƒƒ/ 0
)
ƒƒ0 1
;
ƒƒ1 2
var
≈≈ 
key
≈≈ 
=
≈≈ 
string
≈≈ 
.
≈≈  
IsNullOrWhiteSpace
≈≈ +
(
≈≈+ ,
	reference
≈≈, 5
)
≈≈5 6
?
≈≈7 8
$"
≈≈9 ;
$str
≈≈; ?
{
≈≈? @
Guid
≈≈@ D
.
≈≈D E
NewGuid
≈≈E L
(
≈≈L M
)
≈≈M N
:
≈≈N O
$str
≈≈O P
}
≈≈P Q
"
≈≈Q R
:
≈≈S T
$"
≈≈U W
$str
≈≈W [
{
≈≈[ \
	reference
≈≈\ e
}
≈≈e f
"
≈≈f g
;
≈≈g h
if
∆∆ 

(
∆∆ 
key
∆∆ 
.
∆∆ 
Length
∆∆ 
>
∆∆ 
$num
∆∆ 
)
∆∆ 
return
∆∆ $

BadRequest
∆∆% /
(
∆∆/ 0
new
∆∆0 3
{
∆∆4 5
message
∆∆6 =
=
∆∆> ?
$str
∆∆@ h
}
∆∆i j
)
∆∆j k
;
∆∆k l
var
«« 
paidAt
«« 
=
«« 
	ToUtcDate
«« 
(
«« 
request
«« &
.
««& '
PaidAt
««' -
)
««- .
;
««. /
if
»» 

(
»» 
paidAt
»» 
>
»» 
DateTime
»» 
.
»» 
UtcNow
»» $
.
»»$ %
AddDays
»»% ,
(
»», -
$num
»»- .
)
»». /
)
»»/ 0
return
»»1 7

BadRequest
»»8 B
(
»»B C
new
»»C F
{
»»G H
message
»»I P
=
»»Q R
$str
»»S z
}
»»{ |
)
»»| }
;
»»} ~
if
…… 

(
…… 
!
…… 
await
…… 
payments
…… 
.
…… 
ApplyPaymentAsync
…… -
(
……- .
item
……. 2
,
……2 3
key
……4 7
,
……7 8
value
……9 >
,
……> ?
item
……@ D
.
……D E
Product
……E L
?
……L M
.
……M N
Currency
……N V
,
……V W
ct
……X Z
,
……Z [
new
……\ _
(
……_ `
PaymentMethods
……` n
.
……n o
Transferencia
……o |
,
……| }
paidAt……~ Ñ
,……Ñ Ö
request……Ü ç
.……ç é
Years……é ì
)……ì î
)……î ï
)……ï ñ
return……ó ù
Conflict……û ¶
(……¶ ß
new……ß ™
{……´ ¨
message……≠ ¥
=……µ ∂
$str……∑ 
}……Ò Ú
)……Ú Û
;……Û Ù
item
ÀÀ 
.
ÀÀ 
Status
ÀÀ 
=
ÀÀ  
RenewalReminderJob
ÀÀ (
.
ÀÀ( )
	StatusFor
ÀÀ) 2
(
ÀÀ2 3
item
ÀÀ3 7
.
ÀÀ7 8
Status
ÀÀ8 >
,
ÀÀ> ?
item
ÀÀ@ D
.
ÀÀD E
RenewsAt
ÀÀE M
,
ÀÀM N
DateTime
ÀÀO W
.
ÀÀW X
UtcNow
ÀÀX ^
)
ÀÀ^ _
;
ÀÀ_ `
await
ÀÀa f
db
ÀÀg i
.
ÀÀi j
SaveChangesAsync
ÀÀj z
(
ÀÀz {
ct
ÀÀ{ }
)
ÀÀ} ~
;
ÀÀ~ 
return
ÃÃ 
Ok
ÃÃ 
(
ÃÃ 
ClientProductDto
ÃÃ "
(
ÃÃ" #
item
ÃÃ# '
,
ÃÃ' (
igvRate
ÃÃ) 0
)
ÃÃ0 1
)
ÃÃ1 2
;
ÃÃ2 3
}
ÕÕ 
[
œœ 
	HttpPatch
œœ 
(
œœ 
$str
œœ *
)
œœ* +
]
œœ+ ,
public
–– 

async
–– 
Task
–– 
<
–– 
ActionResult
–– "
>
––" #!
UpdateClientProduct
––$ 7
(
––7 8
Guid
––8 <
id
––= ?
,
––? @'
ClientProductPatchRequest
––A Z
request
––[ b
,
––b c
CancellationToken
––d u
ct
––v x
)
––x y
{
—— 
var
““ 
item
““ 
=
““ 
await
““ 
db
““ 
.
““ 
ClientProducts
““ *
.
““* +
Include
““+ 2
(
““2 3
x
““3 4
=>
““5 7
x
““8 9
.
““9 :
Product
““: A
)
““A B
.
““B C
Include
““C J
(
““J K
x
““K L
=>
““M O
x
““P Q
.
““Q R
Project
““R Y
)
““Y Z
.
““Z ["
SingleOrDefaultAsync
““[ o
(
““o p
x
““p q
=>
““r t
x
““u v
.
““v w
Id
““w y
==
““z |
id
““} 
,““ Ä
ct““Å É
)““É Ñ
;““Ñ Ö
if““Ü à
(““â ä
item““ä é
is““è ë
null““í ñ
)““ñ ó
return““ò û
NotFound““ü ß
(““ß ®
)““® ©
;““© ™
if
”” 

(
”” 
request
”” 
.
”” 
Price
”” 
is
”” 
not
””  
null
””! %
)
””% &
item
””' +
.
””+ ,
Price
””, 1
=
””2 3
request
””4 ;
.
””; <
Price
””< A
;
””A B
if
””C E
(
””F G
request
””G N
.
””N O
Status
””O U
is
””V X!
ClientProductStatus
””Y l
status
””m s
)
””s t
item
””u y
.
””y z
Status””z Ä
=””Å Ç
status””É â
;””â ä
if””ã ç
(””é è
request””è ñ
.””ñ ó
BillingCycle””ó £
is””§ ¶
BillingCycle””ß ≥
cycle””¥ π
)””π ∫
item””ª ø
.””ø ¿
BillingCycle””¿ Ã
=””Õ Œ
cycle””œ ‘
;””‘ ’
if””÷ ÿ
(””Ÿ ⁄
request””⁄ ·
.””· ‚

DomainName””‚ Ï
is””Ì Ô
not”” Û
null””Ù ¯
)””¯ ˘
item””˙ ˛
.””˛ ˇ

DomainName””ˇ â
=””ä ã
EmptyToNull””å ó
(””ó ò
request””ò ü
.””ü †

DomainName””† ™
)””™ ´
;””´ ¨
if””≠ Ø
(””∞ ±
request””± ∏
.””∏ π"
PriceLabelOverride””π À
is””Ã Œ
not””œ “
null””” ◊
)””◊ ÿ
item””Ÿ ›
.””› ﬁ"
PriceLabelOverride””ﬁ 
=””Ò Ú
EmptyToNull””Û ˛
(””˛ ˇ
request””ˇ Ü
.””Ü á"
PriceLabelOverride””á ô
)””ô ö
;””ö õ
if””ú û
(””ü †
request””† ß
.””ß ®
IsManualBilling””® ∑
is””∏ ∫
bool””ª ø
manual””¿ ∆
)””∆ «
item””» Ã
.””Ã Õ
IsManualBilling””Õ ‹
=””› ﬁ
manual””ﬂ Â
;””Â Ê
if
‘‘ 

(
‘‘ 
request
‘‘ 
.
‘‘ 
Discount
‘‘ 
is
‘‘ 
not
‘‘  #
null
‘‘$ (
&&
‘‘) +
item
‘‘, 0
.
‘‘0 1
SetDiscount
‘‘1 <
(
‘‘< =
request
‘‘= D
.
‘‘D E
Discount
‘‘E M
)
‘‘M N
is
‘‘O Q
string
‘‘R X
discountError
‘‘Y f
)
‘‘f g
return
‘‘h n

BadRequest
‘‘o y
(
‘‘y z
new
‘‘z }
{
‘‘~ 
message‘‘Ä á
=‘‘à â
discountError‘‘ä ó
}‘‘ò ô
)‘‘ô ö
;‘‘ö õ
if
÷÷ 

(
÷÷ 
request
÷÷ 
.
÷÷ 
	ProjectId
÷÷ 
is
÷÷  
Guid
÷÷! %
	projectId
÷÷& /
&&
÷÷0 2
	projectId
÷÷3 <
!=
÷÷= ?
item
÷÷@ D
.
÷÷D E
	ProjectId
÷÷E N
)
÷÷N O
{
◊◊ 	
var
ÿÿ 
project
ÿÿ 
=
ÿÿ 
await
ÿÿ 
db
ÿÿ  "
.
ÿÿ" #
Projects
ÿÿ# +
.
ÿÿ+ ,"
SingleOrDefaultAsync
ÿÿ, @
(
ÿÿ@ A
x
ÿÿA B
=>
ÿÿC E
x
ÿÿF G
.
ÿÿG H
Id
ÿÿH J
==
ÿÿK M
	projectId
ÿÿN W
&&
ÿÿX Z
x
ÿÿ[ \
.
ÿÿ\ ]
ClientId
ÿÿ] e
==
ÿÿf h
item
ÿÿi m
.
ÿÿm n
ClientId
ÿÿn v
,
ÿÿv w
ct
ÿÿx z
)
ÿÿz {
;
ÿÿ{ |
if
ŸŸ 
(
ŸŸ 
project
ŸŸ 
is
ŸŸ 
null
ŸŸ 
)
ŸŸ  
return
ŸŸ! '

BadRequest
ŸŸ( 2
(
ŸŸ2 3
new
ŸŸ3 6
{
ŸŸ7 8
message
ŸŸ9 @
=
ŸŸA B
$str
ŸŸC m
}
ŸŸn o
)
ŸŸo p
;
ŸŸp q
(
⁄⁄ 
item
⁄⁄ 
.
⁄⁄ 
	ProjectId
⁄⁄ 
,
⁄⁄ 
item
⁄⁄ !
.
⁄⁄! "
Project
⁄⁄" )
)
⁄⁄) *
=
⁄⁄+ ,
(
⁄⁄- .
project
⁄⁄. 5
.
⁄⁄5 6
Id
⁄⁄6 8
,
⁄⁄8 9
project
⁄⁄: A
)
⁄⁄A B
;
⁄⁄B C
}
€€ 	
await
‹‹ 
db
‹‹ 
.
‹‹ 
SaveChangesAsync
‹‹ !
(
‹‹! "
ct
‹‹" $
)
‹‹$ %
;
‹‹% &
return
‹‹' -
Ok
‹‹. 0
(
‹‹0 1
await
‹‹1 6#
ClientProductDtoAsync
‹‹7 L
(
‹‹L M
item
‹‹M Q
,
‹‹Q R
ct
‹‹S U
)
‹‹U V
)
‹‹V W
;
‹‹W X
}
›› 
[
„„ 

HttpDelete
„„ 
(
„„ 
$str
„„ +
)
„„+ ,
]
„„, -
public
‰‰ 

async
‰‰ 
Task
‰‰ 
<
‰‰ 
ActionResult
‰‰ "
>
‰‰" #!
DeleteClientProduct
‰‰$ 7
(
‰‰7 8
Guid
‰‰8 <
id
‰‰= ?
,
‰‰? @
CancellationToken
‰‰A R
ct
‰‰S U
)
‰‰U V
{
ÂÂ 
var
ÊÊ 
item
ÊÊ 
=
ÊÊ 
await
ÊÊ 
db
ÊÊ 
.
ÊÊ 
ClientProducts
ÊÊ *
.
ÊÊ* +
Include
ÊÊ+ 2
(
ÊÊ2 3
x
ÊÊ3 4
=>
ÊÊ5 7
x
ÊÊ8 9
.
ÊÊ9 :
Product
ÊÊ: A
)
ÊÊA B
.
ÊÊB C"
SingleOrDefaultAsync
ÊÊC W
(
ÊÊW X
x
ÊÊX Y
=>
ÊÊZ \
x
ÊÊ] ^
.
ÊÊ^ _
Id
ÊÊ_ a
==
ÊÊb d
id
ÊÊe g
,
ÊÊg h
ct
ÊÊi k
)
ÊÊk l
;
ÊÊl m
if
ÊÊn p
(
ÊÊq r
item
ÊÊr v
is
ÊÊw y
null
ÊÊz ~
)
ÊÊ~ 
returnÊÊÄ Ü
NotFoundÊÊá è
(ÊÊè ê
)ÊÊê ë
;ÊÊë í
var
ÁÁ 
payments
ÁÁ 
=
ÁÁ 
await
ÁÁ 
db
ÁÁ 
.
ÁÁ  !
PaymentTransactions
ÁÁ  3
.
ÁÁ3 4

CountAsync
ÁÁ4 >
(
ÁÁ> ?
x
ÁÁ? @
=>
ÁÁA C
x
ÁÁD E
.
ÁÁE F
ClientProductId
ÁÁF U
==
ÁÁV X
id
ÁÁY [
,
ÁÁ[ \
ct
ÁÁ] _
)
ÁÁ_ `
;
ÁÁ` a
if
ËË 

(
ËË 
payments
ËË 
==
ËË 
$num
ËË 
)
ËË 
payments
ËË #
=
ËË$ %
await
ËË& +
db
ËË, .
.
ËË. /
TaxDocumentLines
ËË/ ?
.
ËË? @

CountAsync
ËË@ J
(
ËËJ K
x
ËËK L
=>
ËËM O
x
ËËP Q
.
ËËQ R
ClientProductId
ËËR a
==
ËËb d
id
ËËe g
,
ËËg h
ct
ËËi k
)
ËËk l
;
ËËl m
if
ÈÈ 

(
ÈÈ 
payments
ÈÈ 
>
ÈÈ 
$num
ÈÈ 
)
ÈÈ 
return
ÈÈ  
Conflict
ÈÈ! )
(
ÈÈ) *
new
ÈÈ* -
{
ÈÈ. /
message
ÈÈ0 7
=
ÈÈ8 9
$"
ÈÈ: <
$str
ÈÈ< =
{
ÈÈ= >
item
ÈÈ> B
.
ÈÈB C
Product
ÈÈC J
?
ÈÈJ K
.
ÈÈK L
Name
ÈÈL P
}
ÈÈP Q
$str
ÈÈQ Y
{
ÈÈY Z
Count
ÈÈZ _
(
ÈÈ_ `
payments
ÈÈ` h
,
ÈÈh i
$str
ÈÈj {
,
ÈÈ{ |
$strÈÈ} ê
)ÈÈê ë
}ÈÈë í
$strÈÈí ˘
"ÈÈ˘ ˙
}ÈÈ˚ ¸
)ÈÈ¸ ˝
;ÈÈ˝ ˛
if
ÍÍ 

(
ÍÍ 
!
ÍÍ 
string
ÍÍ 
.
ÍÍ  
IsNullOrWhiteSpace
ÍÍ &
(
ÍÍ& '
item
ÍÍ' +
.
ÍÍ+ ,"
PayPalSubscriptionId
ÍÍ, @
)
ÍÍ@ A
&&
ÍÍB D
item
ÍÍE I
.
ÍÍI J
Status
ÍÍJ P
!=
ÍÍQ S!
ClientProductStatus
ÍÍT g
.
ÍÍg h
	Cancelado
ÍÍh q
)
ÍÍq r
return
ÍÍs y
ConflictÍÍz Ç
(ÍÍÇ É
newÍÍÉ Ü
{ÍÍá à
messageÍÍâ ê
=ÍÍë í
$strÍÍì ı
}ÍÍˆ ˜
)ÍÍ˜ ¯
;ÍÍ¯ ˘
await
ÏÏ 
db
ÏÏ 
.
ÏÏ 
Tickets
ÏÏ 
.
ÏÏ 
Where
ÏÏ 
(
ÏÏ 
x
ÏÏ  
=>
ÏÏ! #
x
ÏÏ$ %
.
ÏÏ% &
ClientProductId
ÏÏ& 5
==
ÏÏ6 8
id
ÏÏ9 ;
)
ÏÏ; <
.
ÏÏ< =
ForEachAsync
ÏÏ= I
(
ÏÏI J
x
ÏÏJ K
=>
ÏÏL N
x
ÏÏO P
.
ÏÏP Q
ClientProductId
ÏÏQ `
=
ÏÏa b
null
ÏÏc g
,
ÏÏg h
ct
ÏÏi k
)
ÏÏk l
;
ÏÏl m
db
ÌÌ 

.
ÌÌ
 
TransferReports
ÌÌ 
.
ÌÌ 
RemoveRange
ÌÌ &
(
ÌÌ& '
await
ÌÌ' ,
db
ÌÌ- /
.
ÌÌ/ 0
TransferReports
ÌÌ0 ?
.
ÌÌ? @
Where
ÌÌ@ E
(
ÌÌE F
x
ÌÌF G
=>
ÌÌH J
x
ÌÌK L
.
ÌÌL M
ClientProductId
ÌÌM \
==
ÌÌ] _
id
ÌÌ` b
)
ÌÌb c
.
ÌÌc d
ToListAsync
ÌÌd o
(
ÌÌo p
ct
ÌÌp r
)
ÌÌr s
)
ÌÌs t
;
ÌÌt u
db
ÓÓ 

.
ÓÓ
 
ClientProducts
ÓÓ 
.
ÓÓ 
Remove
ÓÓ  
(
ÓÓ  !
item
ÓÓ! %
)
ÓÓ% &
;
ÓÓ& '
await
ÔÔ 
db
ÔÔ 
.
ÔÔ 
SaveChangesAsync
ÔÔ !
(
ÔÔ! "
ct
ÔÔ" $
)
ÔÔ$ %
;
ÔÔ% &
return
ÔÔ' -
	NoContent
ÔÔ. 7
(
ÔÔ7 8
)
ÔÔ8 9
;
ÔÔ9 :
}
 
[
˜˜ 
HttpPut
˜˜ 
(
˜˜ 
$str
˜˜ .
)
˜˜. /
]
˜˜/ 0
public
¯¯ 

async
¯¯ 
Task
¯¯ 
<
¯¯ 
ActionResult
¯¯ "
>
¯¯" #&
UpdateClientProductDates
¯¯$ <
(
¯¯< =
Guid
¯¯= A
id
¯¯B D
,
¯¯D E'
ClientProductDatesRequest
¯¯F _
request
¯¯` g
,
¯¯g h
CancellationToken
¯¯i z
ct
¯¯{ }
)
¯¯} ~
{
˘˘ 
var
˙˙ 
item
˙˙ 
=
˙˙ 
await
˙˙ 
db
˙˙ 
.
˙˙ 
ClientProducts
˙˙ *
.
˙˙* +
Include
˙˙+ 2
(
˙˙2 3
x
˙˙3 4
=>
˙˙5 7
x
˙˙8 9
.
˙˙9 :
Product
˙˙: A
)
˙˙A B
.
˙˙B C
Include
˙˙C J
(
˙˙J K
x
˙˙K L
=>
˙˙M O
x
˙˙P Q
.
˙˙Q R
Project
˙˙R Y
)
˙˙Y Z
.
˙˙Z ["
SingleOrDefaultAsync
˙˙[ o
(
˙˙o p
x
˙˙p q
=>
˙˙r t
x
˙˙u v
.
˙˙v w
Id
˙˙w y
==
˙˙z |
id
˙˙} 
,˙˙ Ä
ct˙˙Å É
)˙˙É Ñ
;˙˙Ñ Ö
if˙˙Ü à
(˙˙â ä
item˙˙ä é
is˙˙è ë
null˙˙í ñ
)˙˙ñ ó
return˙˙ò û
NotFound˙˙ü ß
(˙˙ß ®
)˙˙® ©
;˙˙© ™
item
˚˚ 
.
˚˚ 
RenewsAt
˚˚ 
=
˚˚ 
	ToUtcDate
˚˚ !
(
˚˚! "
request
˚˚" )
.
˚˚) *
RenewsAt
˚˚* 2
)
˚˚2 3
;
˚˚3 4
item
˚˚5 9
.
˚˚9 :
NextChargeAt
˚˚: F
=
˚˚G H
	ToUtcDate
˚˚I R
(
˚˚R S
request
˚˚S Z
.
˚˚Z [
NextChargeAt
˚˚[ g
)
˚˚g h
;
˚˚h i
item
¸¸ 
.
¸¸ 
Status
¸¸ 
=
¸¸  
RenewalReminderJob
¸¸ (
.
¸¸( )
	StatusFor
¸¸) 2
(
¸¸2 3
item
¸¸3 7
.
¸¸7 8
Status
¸¸8 >
,
¸¸> ?
item
¸¸@ D
.
¸¸D E
RenewsAt
¸¸E M
,
¸¸M N
DateTime
¸¸O W
.
¸¸W X
UtcNow
¸¸X ^
)
¸¸^ _
;
¸¸_ `
item
˝˝ 
.
˝˝ 
OnDatesChanged
˝˝ 
(
˝˝ 
)
˝˝ 
;
˝˝ 
await
˛˛ 
db
˛˛ 
.
˛˛ 
SaveChangesAsync
˛˛ !
(
˛˛! "
ct
˛˛" $
)
˛˛$ %
;
˛˛% &
return
˛˛' -
Ok
˛˛. 0
(
˛˛0 1
await
˛˛1 6#
ClientProductDtoAsync
˛˛7 L
(
˛˛L M
item
˛˛M Q
,
˛˛Q R
ct
˛˛S U
)
˛˛U V
)
˛˛V W
;
˛˛W X
}
ˇˇ 
internal
ÇÇ 
static
ÇÇ 
DateTime
ÇÇ 
?
ÇÇ 
	ToUtcDate
ÇÇ '
(
ÇÇ' (
DateOnly
ÇÇ( 0
?
ÇÇ0 1
date
ÇÇ2 6
)
ÇÇ6 7
=>
ÇÇ8 :
date
ÇÇ; ?
?
ÇÇ? @
.
ÇÇ@ A

ToDateTime
ÇÇA K
(
ÇÇK L
new
ÇÇL O
TimeOnly
ÇÇP X
(
ÇÇX Y
$num
ÇÇY [
,
ÇÇ[ \
$num
ÇÇ] ^
)
ÇÇ^ _
,
ÇÇ_ `
DateTimeKind
ÇÇa m
.
ÇÇm n
Utc
ÇÇn q
)
ÇÇq r
;
ÇÇr s
private
ÑÑ 
async
ÑÑ 
Task
ÑÑ 
<
ÑÑ 
(
ÑÑ 
ActionResult
ÑÑ $
?
ÑÑ$ %
Failure
ÑÑ& -
,
ÑÑ- .
int
ÑÑ/ 2
Created
ÑÑ3 :
,
ÑÑ: ;
List
ÑÑ< @
<
ÑÑ@ A
ImportError
ÑÑA L
>
ÑÑL M
Errors
ÑÑN T
)
ÑÑT U
>
ÑÑU V
Import
ÑÑW ]
(
ÑÑ] ^
	IFormFile
ÑÑ^ g
file
ÑÑh l
,
ÑÑl m
string
ÑÑn t
kind
ÑÑu y
,
ÑÑy z
Func
ÑÑ{ 
<ÑÑ Ä
IXLRowÑÑÄ Ü
,ÑÑÜ á
intÑÑà ã
,ÑÑã å
ListÑÑç ë
<ÑÑë í
ImportErrorÑÑí ù
>ÑÑù û
,ÑÑû ü
TaskÑÑ† §
<ÑÑ§ •
boolÑÑ• ©
>ÑÑ© ™
>ÑÑ™ ´
addRowÑÑ¨ ≤
,ÑÑ≤ ≥!
CancellationTokenÑÑ¥ ≈
ctÑÑ∆ »
)ÑÑ» …
{
ÖÖ 
var
ÜÜ 
errors
ÜÜ 
=
ÜÜ 
new
ÜÜ 
List
ÜÜ 
<
ÜÜ 
ImportError
ÜÜ )
>
ÜÜ) *
(
ÜÜ* +
)
ÜÜ+ ,
;
ÜÜ, -
var
ÜÜ. 1
created
ÜÜ2 9
=
ÜÜ: ;
$num
ÜÜ< =
;
ÜÜ= >
if
áá 

(
áá 
file
áá 
is
áá 
null
áá 
||
áá 
file
áá  
.
áá  !
Length
áá! '
==
áá( *
$num
áá+ ,
)
áá, -
return
áá. 4
(
áá5 6

BadRequest
áá6 @
(
áá@ A
new
ááA D
{
ááE F
message
ááG N
=
ááO P
$str
ááQ o
}
ááp q
)
ááq r
,
áár s
$num
áát u
,
ááu v
errors
ááw }
)
áá} ~
;
áá~ 
try
àà 
{
àà 
using
àà 
var
àà 
stream
àà 
=
àà  
file
àà! %
.
àà% &
OpenReadStream
àà& 4
(
àà4 5
)
àà5 6
;
àà6 7
using
àà8 =
var
àà> A
book
ààB F
=
ààG H
new
ààI L

XLWorkbook
ààM W
(
ààW X
stream
ààX ^
)
àà^ _
;
àà_ `
var
ààa d
sheet
ààe j
=
ààk l
book
ààm q
.
ààq r

Worksheets
ààr |
.
àà| }
Firstàà} Ç
(ààÇ É
)ààÉ Ñ
;ààÑ Ö
foreachààÜ ç
(ààé è
varààè í
rowààì ñ
inààó ô
sheetààö ü
.ààü †
RowsUsedàà† ®
(àà® ©
)àà© ™
.àà™ ´
Skipàà´ Ø
(ààØ ∞
$numàà∞ ±
)àà± ≤
)àà≤ ≥
ifàà¥ ∂
(àà∑ ∏
awaitàà∏ Ω
addRowààæ ƒ
(ààƒ ≈
rowàà≈ »
,àà» …
rowàà  Õ
.ààÕ Œ
	RowNumberààŒ ◊
(àà◊ ÿ
)ààÿ Ÿ
,ààŸ ⁄
errorsàà€ ·
)àà· ‚
)àà‚ „
{àà‰ Â
awaitààÊ Î
dbààÏ Ó
.ààÓ Ô 
SaveChangesAsyncààÔ ˇ
(ààˇ Ä
ctààÄ Ç
)ààÇ É
;ààÉ Ñ
createdààÖ å
++ààå é
;ààé è
}ààê ë
}ààí ì
catch
ââ 
(
ââ 
	Exception
ââ 
ex
ââ 
)
ââ 
when
ââ !
(
ââ" #
ex
ââ# %
is
ââ& (
not
ââ) ,
DbUpdateException
ââ- >
)
ââ> ?
{
ââ@ A
return
ââB H
(
ââI J

BadRequest
ââJ T
(
ââT U
new
ââU X
{
ââY Z
message
ââ[ b
=
ââc d
$"
ââe g
$strââg á
{ââá à
kindââà å
}ââå ç
$strââç é
"ââé è
}ââê ë
)ââë í
,ââí ì
$numââî ï
,ââï ñ
errorsââó ù
)ââù û
;ââû ü
}ââ† °
return
ää 
(
ää 
null
ää 
,
ää 
created
ää 
,
ää 
errors
ää %
)
ää% &
;
ää& '
}
ãã 
private
åå 
static
åå 
string
åå 
Cell
åå 
(
åå 
IXLRow
åå %
row
åå& )
,
åå) *
int
åå+ .
col
åå/ 2
)
åå2 3
=>
åå4 6
row
åå7 :
.
åå: ;
Cell
åå; ?
(
åå? @
col
åå@ C
)
ååC D
.
ååD E
	GetString
ååE N
(
ååN O
)
ååO P
;
ååP Q
private
ëë 
static
ëë 
byte
ëë 
[
ëë 
]
ëë 
CreateWorkbook
ëë (
(
ëë( )
params
ëë) /
TemplateColumn
ëë0 >
[
ëë> ?
]
ëë? @
columns
ëëA H
)
ëëH I
{
íí 
const
ìì 
int
ìì 
LastDataRow
ìì 
=
ìì 
$num
ìì  $
;
ìì$ %
using
îî 
var
îî 
book
îî 
=
îî 
new
îî 

XLWorkbook
îî '
(
îî' (
)
îî( )
;
îî) *
var
îî+ .
sheet
îî/ 4
=
îî5 6
book
îî7 ;
.
îî; <
AddWorksheet
îî< H
(
îîH I
$str
îîI T
)
îîT U
;
îîU V
var
ïï 
help
ïï 
=
ïï 
book
ïï 
.
ïï 
AddWorksheet
ïï $
(
ïï$ %
$str
ïï% 6
)
ïï6 7
;
ïï7 8
help
ññ 
.
ññ 
Cell
ññ 
(
ññ 
$num
ññ 
,
ññ 
$num
ññ 
)
ññ 
.
ññ 
Value
ññ 
=
ññ 
$str
ññ  )
;
ññ) *
help
ññ+ /
.
ññ/ 0
Cell
ññ0 4
(
ññ4 5
$num
ññ5 6
,
ññ6 7
$num
ññ8 9
)
ññ9 :
.
ññ: ;
Value
ññ; @
=
ññA B
$str
ññC P
;
ññP Q
help
ññR V
.
ññV W
Cell
ññW [
(
ññ[ \
$num
ññ\ ]
,
ññ] ^
$num
ññ_ `
)
ññ` a
.
ñña b
Value
ññb g
=
ññh i
$str
ññj }
;
ññ} ~
helpññ É
.ññÉ Ñ
RowññÑ á
(ññá à
$numññà â
)ññâ ä
.ññä ã
Styleññã ê
.ññê ë
Fontññë ï
.ññï ñ
Boldñññ ö
=ññõ ú
trueññù °
;ññ° ¢
for
óó 
(
óó 
var
óó 
i
óó 
=
óó 
$num
óó 
;
óó 
i
óó 
<
óó 
columns
óó #
.
óó# $
Length
óó$ *
;
óó* +
i
óó, -
++
óó- /
)
óó/ 0
{
òò 	
var
ôô 
column
ôô 
=
ôô 
columns
ôô  
[
ôô  !
i
ôô! "
]
ôô" #
;
ôô# $
var
ôô% (
accepted
ôô) 1
=
ôô2 3
column
ôô4 :
.
ôô: ;
Options
ôô; B
is
ôôC E
null
ôôF J
?
ôôK L
column
ôôM S
.
ôôS T
Accepted
ôôT \
:
ôô] ^
$"
ôô_ a
{
ôôa b
column
ôôb h
.
ôôh i
Accepted
ôôi q
}
ôôq r
$str
ôôr t
{
ôôt u
string
ôôu {
.
ôô{ |
Joinôô| Ä
(ôôÄ Å
$strôôÅ Ö
,ôôÖ Ü
columnôôá ç
.ôôç é
Optionsôôé ï
)ôôï ñ
}ôôñ ó
"ôôó ò
;ôôò ô
var
öö 
header
öö 
=
öö 
sheet
öö 
.
öö 
Cell
öö #
(
öö# $
$num
öö$ %
,
öö% &
i
öö' (
+
öö) *
$num
öö+ ,
)
öö, -
;
öö- .
header
öö/ 5
.
öö5 6
Value
öö6 ;
=
öö< =
column
öö> D
.
ööD E
Name
ööE I
;
ööI J
header
õõ 
.
õõ 
CreateComment
õõ  
(
õõ  !
)
õõ! "
.
õõ" #
AddText
õõ# *
(
õõ* +
$"
õõ+ -
{
õõ- .
(
õõ. /
column
õõ/ 5
.
õõ5 6
Required
õõ6 >
?
õõ? @
$str
õõA N
:
õõO P
$str
õõQ [
)
õõ[ \
}
õõ\ ]
$str
õõ] _
{
õõ_ `
accepted
õõ` h
}
õõh i
"
õõi j
)
õõj k
;
õõk l
if
úú 
(
úú 
column
úú 
.
úú 
Required
úú 
)
úú  
header
úú! '
.
úú' (
Style
úú( -
.
úú- .
Fill
úú. 2
.
úú2 3
BackgroundColor
úú3 B
=
úúC D
XLColor
úúE L
.
úúL M
FromHtml
úúM U
(
úúU V
$str
úúV _
)
úú_ `
;
úú` a
if
ùù 
(
ùù 
column
ùù 
.
ùù 
Options
ùù 
is
ùù !
not
ùù" %
null
ùù& *
)
ùù* +
{
ûû 
var
üü 

validation
üü 
=
üü  
sheet
üü! &
.
üü& '
Range
üü' ,
(
üü, -
$num
üü- .
,
üü. /
i
üü0 1
+
üü2 3
$num
üü4 5
,
üü5 6
LastDataRow
üü7 B
,
üüB C
i
üüD E
+
üüF G
$num
üüH I
)
üüI J
.
üüJ K"
CreateDataValidation
üüK _
(
üü_ `
)
üü` a
;
üüa b

validation
†† 
.
†† 
List
†† 
(
††  
$"
††  "
$str
††" $
{
††$ %
string
††% +
.
††+ ,
Join
††, 0
(
††0 1
$str
††1 4
,
††4 5
column
††6 <
.
††< =
Options
††= D
)
††D E
}
††E F
$str
††F H
"
††H I
,
††I J
true
††K O
)
††O P
;
††P Q

validation
°° 
.
°° 

ErrorTitle
°° %
=
°°& '
column
°°( .
.
°°. /
Name
°°/ 3
;
°°3 4

validation
°°5 ?
.
°°? @
ErrorMessage
°°@ L
=
°°M N
$"
°°O Q
$str
°°Q d
{
°°d e
string
°°e k
.
°°k l
Join
°°l p
(
°°p q
$str
°°q u
,
°°u v
column
°°w }
.
°°} ~
Options°°~ Ö
)°°Ö Ü
}°°Ü á
"°°á à
;°°à â
}
¢¢ 
help
££ 
.
££ 
Cell
££ 
(
££ 
i
££ 
+
££ 
$num
££ 
,
££ 
$num
££ 
)
££ 
.
££  
Value
££  %
=
££& '
column
££( .
.
££. /
Name
££/ 3
;
££3 4
help
££5 9
.
££9 :
Cell
££: >
(
££> ?
i
££? @
+
££A B
$num
££C D
,
££D E
$num
££F G
)
££G H
.
££H I
Value
££I N
=
££O P
column
££Q W
.
££W X
Required
££X `
?
££a b
$str
££c g
:
££h i
$str
££j n
;
££n o
help
££p t
.
££t u
Cell
££u y
(
££y z
i
££z {
+
££| }
$num
££~ 
,££ Ä
$num££Å Ç
)££Ç É
.££É Ñ
Value££Ñ â
=££ä ã
accepted££å î
;££î ï
}
§§ 	
sheet
•• 
.
•• 
Row
•• 
(
•• 
$num
•• 
)
•• 
.
•• 
Style
•• 
.
•• 
Font
•• 
.
••  
Bold
••  $
=
••% &
true
••' +
;
••+ ,
sheet
••- 2
.
••2 3
Columns
••3 :
(
••: ;
)
••; <
.
••< =
AdjustToContents
••= M
(
••M N
)
••N O
;
••O P
help
••Q U
.
••U V
Columns
••V ]
(
••] ^
)
••^ _
.
••_ `
AdjustToContents
••` p
(
••p q
)
••q r
;
••r s
help
¶¶ 
.
¶¶ 
Cell
¶¶ 
(
¶¶ 
columns
¶¶ 
.
¶¶ 
Length
¶¶  
+
¶¶! "
$num
¶¶# $
,
¶¶$ %
$num
¶¶& '
)
¶¶' (
.
¶¶( )
Value
¶¶) .
=
¶¶/ 0
$str¶¶1 ñ
;¶¶ñ ó
using
ßß 
var
ßß 
stream
ßß 
=
ßß 
new
ßß 
MemoryStream
ßß +
(
ßß+ ,
)
ßß, -
;
ßß- .
book
ßß/ 3
.
ßß3 4
SaveAs
ßß4 :
(
ßß: ;
stream
ßß; A
)
ßßA B
;
ßßB C
return
ßßD J
stream
ßßK Q
.
ßßQ R
ToArray
ßßR Y
(
ßßY Z
)
ßßZ [
;
ßß[ \
}
®® 
private
©© 
static
©© 
string
©© 
?
©© 
EmptyToNull
©© &
(
©©& '
string
©©' -
?
©©- .
value
©©/ 4
)
©©4 5
=>
©©6 8
string
©©9 ?
.
©©? @ 
IsNullOrWhiteSpace
©©@ R
(
©©R S
value
©©S X
)
©©X Y
?
©©Z [
null
©©\ `
:
©©a b
value
©©c h
.
©©h i
Trim
©©i m
(
©©m n
)
©©n o
;
©©o p
private
™™ 
static
™™ 
string
™™ 
?
™™ 
ValidateClient
™™ )
(
™™) *
ClientRequest
™™* 7
request
™™8 ?
)
™™? @
{
´´ 
if
¨¨ 

(
¨¨ 
string
¨¨ 
.
¨¨  
IsNullOrWhiteSpace
¨¨ %
(
¨¨% &
request
¨¨& -
.
¨¨- .
CompanyName
¨¨. 9
)
¨¨9 :
||
¨¨; =
string
¨¨> D
.
¨¨D E 
IsNullOrWhiteSpace
¨¨E W
(
¨¨W X
request
¨¨X _
.
¨¨_ `
ContactName
¨¨` k
)
¨¨k l
||
¨¨m o
string
¨¨p v
.
¨¨v w!
IsNullOrWhiteSpace¨¨w â
(¨¨â ä
request¨¨ä ë
.¨¨ë í
Email¨¨í ó
)¨¨ó ò
||¨¨ô õ
!¨¨ú ù
request¨¨ù §
.¨¨§ •
Email¨¨• ™
.¨¨™ ´
Contains¨¨´ ≥
(¨¨≥ ¥
$char¨¨¥ ∑
)¨¨∑ ∏
)¨¨∏ π
return¨¨∫ ¿
$str¨¨¡ ı
;¨¨ı ˆ
return
≠≠ 
request
≠≠ 
.
≠≠ 
PreferredLanguage
≠≠ (
.
≠≠( )
Trim
≠≠) -
(
≠≠- .
)
≠≠. /
.
≠≠/ 0
ToLowerInvariant
≠≠0 @
(
≠≠@ A
)
≠≠A B
is
≠≠C E
not
≠≠F I
(
≠≠J K
$str
≠≠K O
or
≠≠P R
$str
≠≠S W
or
≠≠X Z
$str
≠≠[ _
)
≠≠_ `
?
≠≠a b
$str
≠≠c u
:
≠≠v w
null
≠≠x |
;
≠≠| }
}
ÆÆ 
private
ØØ 
static
ØØ 
string
ØØ 
?
ØØ 
ValidateProduct
ØØ *
(
ØØ* +
ProductRequest
ØØ+ 9
request
ØØ: A
)
ØØA B
=>
ØØC E
string
ØØF L
.
ØØL M 
IsNullOrWhiteSpace
ØØM _
(
ØØ_ `
request
ØØ` g
.
ØØg h
Name
ØØh l
)
ØØl m
||
ØØn p
string
ØØq w
.
ØØw x!
IsNullOrWhiteSpaceØØx ä
(ØØä ã
requestØØã í
.ØØí ì
CurrencyØØì õ
)ØØõ ú
?ØØù û
$strØØü ¬
:ØØ√ ƒ
nullØØ≈ …
;ØØ…  
private
±± 
async
±± 
Task
±± (
EnsureProductCategoryAsync
±± 1
(
±±1 2
string
±±2 8
?
±±8 9
name
±±: >
,
±±> ?
CancellationToken
±±@ Q
ct
±±R T
)
±±T U
{
≤≤ 
if
≥≥ 

(
≥≥ 
string
≥≥ 
.
≥≥  
IsNullOrWhiteSpace
≥≥ %
(
≥≥% &
name
≥≥& *
)
≥≥* +
)
≥≥+ ,
return
≥≥- 3
;
≥≥3 4
name
¥¥ 
=
¥¥ 
name
¥¥ 
.
¥¥ 
Trim
¥¥ 
(
¥¥ 
)
¥¥ 
;
¥¥ 
if
µµ 

(
µµ 
db
µµ 
.
µµ 
ProductCategories
µµ  
.
µµ  !
Local
µµ! &
.
µµ& '
Any
µµ' *
(
µµ* +
x
µµ+ ,
=>
µµ- /
x
µµ0 1
.
µµ1 2
Name
µµ2 6
.
µµ6 7
Equals
µµ7 =
(
µµ= >
name
µµ> B
,
µµB C
StringComparison
µµD T
.
µµT U
OrdinalIgnoreCase
µµU f
)
µµf g
)
µµg h
||
µµi k
await
µµl q
db
µµr t
.
µµt u 
ProductCategoriesµµu Ü
.µµÜ á
AnyAsyncµµá è
(µµè ê
xµµê ë
=>µµí î
xµµï ñ
.µµñ ó
Nameµµó õ
==µµú û
nameµµü £
,µµ£ §
ctµµ• ß
)µµß ®
)µµ® ©
returnµµ™ ∞
;µµ∞ ±
db
∂∂ 

.
∂∂
 
ProductCategories
∂∂ 
.
∂∂ 
Add
∂∂  
(
∂∂  !
new
∂∂! $
ProductCategory
∂∂% 4
{
∂∂5 6
Name
∂∂7 ;
=
∂∂< =
name
∂∂> B
,
∂∂B C
	SortOrder
∂∂D M
=
∂∂N O
await
∂∂P U
db
∂∂V X
.
∂∂X Y
ProductCategories
∂∂Y j
.
∂∂j k

CountAsync
∂∂k u
(
∂∂u v
ct
∂∂v x
)
∂∂x y
+
∂∂z {
db
∂∂| ~
.
∂∂~  
ProductCategories∂∂ ê
.∂∂ê ë
Local∂∂ë ñ
.∂∂ñ ó
Count∂∂ó ú
}∂∂ù û
)∂∂û ü
;∂∂ü †
}
∑∑ 
internal
∫∫ 
static
∫∫ 
string
∫∫ 
Fold
∫∫ 
(
∫∫  
string
∫∫  &
value
∫∫' ,
)
∫∫, -
=>
∫∫. 0
new
∫∫1 4
(
∫∫4 5
value
∫∫5 :
.
∫∫: ;
Trim
∫∫; ?
(
∫∫? @
)
∫∫@ A
.
∫∫A B
ToLowerInvariant
∫∫B R
(
∫∫R S
)
∫∫S T
.
∫∫T U
	Normalize
∫∫U ^
(
∫∫^ _
System
∫∫_ e
.
∫∫e f
Text
∫∫f j
.
∫∫j k
NormalizationForm
∫∫k |
.
∫∫| }
FormD∫∫} Ç
)∫∫Ç É
.
ªª 	
Where
ªª	 
(
ªª 
c
ªª 
=>
ªª 
System
ªª 
.
ªª 
Globalization
ªª (
.
ªª( )
CharUnicodeInfo
ªª) 8
.
ªª8 9 
GetUnicodeCategory
ªª9 K
(
ªªK L
c
ªªL M
)
ªªM N
!=
ªªO Q
System
ªªR X
.
ªªX Y
Globalization
ªªY f
.
ªªf g
UnicodeCategory
ªªg v
.
ªªv w
NonSpacingMarkªªw Ö
)ªªÖ Ü
.ªªÜ á
ToArrayªªá é
(ªªé è
)ªªè ê
)ªªê ë
;ªªë í
private
ΩΩ 
static
ΩΩ 
Product
ΩΩ 
	ToProduct
ΩΩ $
(
ΩΩ$ %
ProductRequest
ΩΩ% 3
r
ΩΩ4 5
)
ΩΩ5 6
=>
ΩΩ7 9
new
ΩΩ: =
(
ΩΩ= >
)
ΩΩ> ?
{
ΩΩ@ A
Type
ΩΩB F
=
ΩΩG H
r
ΩΩI J
.
ΩΩJ K
Type
ΩΩK O
,
ΩΩO P
Name
ΩΩQ U
=
ΩΩV W
r
ΩΩX Y
.
ΩΩY Z
Name
ΩΩZ ^
.
ΩΩ^ _
Trim
ΩΩ_ c
(
ΩΩc d
)
ΩΩd e
,
ΩΩe f
BillingCycle
ΩΩg s
=
ΩΩt u
r
ΩΩv w
.
ΩΩw x
BillingCycleΩΩx Ñ
,ΩΩÑ Ö
	BasePriceΩΩÜ è
=ΩΩê ë
rΩΩí ì
.ΩΩì î
	BasePriceΩΩî ù
,ΩΩù û
CurrencyΩΩü ß
=ΩΩ® ©
rΩΩ™ ´
.ΩΩ´ ¨
CurrencyΩΩ¨ ¥
.ΩΩ¥ µ
TrimΩΩµ π
(ΩΩπ ∫
)ΩΩ∫ ª
.ΩΩª º 
ToUpperInvariantΩΩº Ã
(ΩΩÃ Õ
)ΩΩÕ Œ
,ΩΩŒ œ
DescriptionΩΩ– €
=ΩΩ‹ ›
EmptyToNullΩΩﬁ È
(ΩΩÈ Í
rΩΩÍ Î
.ΩΩÎ Ï
DescriptionΩΩÏ ˜
)ΩΩ˜ ¯
,ΩΩ¯ ˘
IsActiveΩΩ˙ Ç
=ΩΩÉ Ñ
rΩΩÖ Ü
.ΩΩÜ á
IsActiveΩΩá è
,ΩΩè ê
TaxDocumentTypeΩΩë †
=ΩΩ° ¢
rΩΩ£ §
.ΩΩ§ •
TaxDocumentTypeΩΩ• ¥
,ΩΩ¥ µ
CategoryΩΩ∂ æ
=ΩΩø ¿
EmptyToNullΩΩ¡ Ã
(ΩΩÃ Õ
rΩΩÕ Œ
.ΩΩŒ œ
CategoryΩΩœ ◊
)ΩΩ◊ ÿ
,ΩΩÿ Ÿ
TagsΩΩ⁄ ﬁ
=ΩΩﬂ ‡
NormalizeTagsΩΩ· Ó
(ΩΩÓ Ô
rΩΩÔ 
.ΩΩ Ò
TagsΩΩÒ ı
)ΩΩı ˆ
,ΩΩˆ ˜
AllowsTicketsΩΩ¯ Ö
=ΩΩÜ á
rΩΩà â
.ΩΩâ ä
AllowsTicketsΩΩä ó
}ΩΩò ô
;ΩΩô ö
private
øø 
static
øø 
string
øø 
?
øø 
NormalizeTags
øø (
(
øø( )
string
øø) /
?
øø/ 0
tags
øø1 5
)
øø5 6
=>
øø7 9
tags
øø: >
?
øø> ?
.
øø? @
Split
øø@ E
(
øøE F
$char
øøF I
,
øøI J 
StringSplitOptions
øøK ]
.
øø] ^ 
RemoveEmptyEntries
øø^ p
|
øøq r!
StringSplitOptionsøøs Ö
.øøÖ Ü
TrimEntriesøøÜ ë
)øøë í
.øøí ì
Distinctøøì õ
(øøõ ú
StringComparerøøú ™
.øø™ ´!
OrdinalIgnoreCaseøø´ º
)øøº Ω
.øøΩ æ
ToArrayøøæ ≈
(øø≈ ∆
)øø∆ «
isøø»  
{øøÀ Ã
LengthøøÕ ”
:øø” ‘
>øø’ ÷
$numøø◊ ÿ
}øøŸ ⁄
listøø€ ﬂ
?øø‡ ·
stringøø‚ Ë
.øøË È
JoinøøÈ Ì
(øøÌ Ó
$strøøÓ Ú
,øøÚ Û
listøøÙ ¯
)øø¯ ˘
:øø˙ ˚
nulløø¸ Ä
;øøÄ Å
private
¿¿ 
static
¿¿ 
object
¿¿ 
	ClientDto
¿¿ #
(
¿¿# $
Client
¿¿$ *
x
¿¿+ ,
)
¿¿, -
=>
¿¿. 0
new
¿¿1 4
{
¿¿5 6
id
¿¿7 9
=
¿¿: ;
x
¿¿< =
.
¿¿= >
Id
¿¿> @
,
¿¿@ A
companyName
¿¿B M
=
¿¿N O
x
¿¿P Q
.
¿¿Q R
CompanyName
¿¿R ]
,
¿¿] ^
contactName
¿¿_ j
=
¿¿k l
x
¿¿m n
.
¿¿n o
ContactName
¿¿o z
,
¿¿z {
email¿¿| Å
=¿¿Ç É
x¿¿Ñ Ö
.¿¿Ö Ü
Email¿¿Ü ã
,¿¿ã å
phone¿¿ç í
=¿¿ì î
x¿¿ï ñ
.¿¿ñ ó
Phone¿¿ó ú
,¿¿ú ù!
preferredLanguage¿¿û Ø
=¿¿∞ ±
x¿¿≤ ≥
.¿¿≥ ¥!
PreferredLanguage¿¿¥ ≈
,¿¿≈ ∆
isActive¿¿« œ
=¿¿– —
x¿¿“ ”
.¿¿” ‘
IsActive¿¿‘ ‹
,¿¿‹ ›#
requiresTaxDocument¿¿ﬁ Ò
=¿¿Ú Û
x¿¿Ù ı
.¿¿ı ˆ#
RequiresTaxDocument¿¿ˆ â
}¿¿ä ã
;¿¿ã å
private
¡¡ 
static
¡¡ 
object
¡¡ 

ProjectDto
¡¡ $
(
¡¡$ %
Project
¡¡% ,
x
¡¡- .
)
¡¡. /
=>
¡¡0 2
new
¡¡3 6
{
¡¡7 8
id
¡¡9 ;
=
¡¡< =
x
¡¡> ?
.
¡¡? @
Id
¡¡@ B
,
¡¡B C
clientId
¡¡D L
=
¡¡M N
x
¡¡O P
.
¡¡P Q
ClientId
¡¡Q Y
,
¡¡Y Z
name
¡¡[ _
=
¡¡` a
x
¡¡b c
.
¡¡c d
Name
¡¡d h
,
¡¡h i
slug
¡¡j n
=
¡¡o p
x
¡¡q r
.
¡¡r s
Slug
¡¡s w
,
¡¡w x
repositories¡¡y Ö
=¡¡Ü á
x¡¡à â
.¡¡â ä
Repositories¡¡ä ñ
.¡¡ñ ó!
OrderByDescending¡¡ó ®
(¡¡® ©
r¡¡© ™
=>¡¡´ ≠
r¡¡Æ Ø
.¡¡Ø ∞
	IsDefault¡¡∞ π
)¡¡π ∫
.¡¡∫ ª
ThenBy¡¡ª ¡
(¡¡¡ ¬
r¡¡¬ √
=>¡¡ƒ ∆
r¡¡« »
.¡¡» …
Name¡¡… Õ
)¡¡Õ Œ
.¡¡Œ œ
Select¡¡œ ’
(¡¡’ ÷
r¡¡÷ ◊
=>¡¡ÿ ⁄
new¡¡€ ﬁ
{¡¡ﬂ ‡
id¡¡· „
=¡¡‰ Â
r¡¡Ê Á
.¡¡Á Ë
Id¡¡Ë Í
,¡¡Í Î
owner¡¡Ï Ò
=¡¡Ú Û
r¡¡Ù ı
.¡¡ı ˆ
Owner¡¡ˆ ˚
,¡¡˚ ¸
name¡¡˝ Å
=¡¡Ç É
r¡¡Ñ Ö
.¡¡Ö Ü
Name¡¡Ü ä
,¡¡ä ã
label¡¡å ë
=¡¡í ì
r¡¡î ï
.¡¡ï ñ
Label¡¡ñ õ
,¡¡õ ú
	isDefault¡¡ù ¶
=¡¡ß ®
r¡¡© ™
.¡¡™ ´
	IsDefault¡¡´ ¥
}¡¡µ ∂
)¡¡∂ ∑
}¡¡∏ π
;¡¡π ∫
private
¬¬ 
static
¬¬ 
object
¬¬ 

ProductDto
¬¬ $
(
¬¬$ %
Product
¬¬% ,
x
¬¬- .
)
¬¬. /
=>
¬¬0 2
new
¬¬3 6
{
¬¬7 8
id
¬¬9 ;
=
¬¬< =
x
¬¬> ?
.
¬¬? @
Id
¬¬@ B
,
¬¬B C
type
¬¬D H
=
¬¬I J
x
¬¬K L
.
¬¬L M
Type
¬¬M Q
.
¬¬Q R
ToString
¬¬R Z
(
¬¬Z [
)
¬¬[ \
,
¬¬\ ]
name
¬¬^ b
=
¬¬c d
x
¬¬e f
.
¬¬f g
Name
¬¬g k
,
¬¬k l
billingCycle
¬¬m y
=
¬¬z {
x
¬¬| }
.
¬¬} ~
BillingCycle¬¬~ ä
.¬¬ä ã
ToString¬¬ã ì
(¬¬ì î
)¬¬î ï
,¬¬ï ñ
	basePrice¬¬ó †
=¬¬° ¢
x¬¬£ §
.¬¬§ •
	BasePrice¬¬• Æ
,¬¬Æ Ø
currency¬¬∞ ∏
=¬¬π ∫
x¬¬ª º
.¬¬º Ω
Currency¬¬Ω ≈
,¬¬≈ ∆
description¬¬« “
=¬¬” ‘
x¬¬’ ÷
.¬¬÷ ◊
Description¬¬◊ ‚
,¬¬‚ „
isActive¬¬‰ Ï
=¬¬Ì Ó
x¬¬Ô 
.¬¬ Ò
IsActive¬¬Ò ˘
,¬¬˘ ˙
taxDocumentType¬¬˚ ä
=¬¬ã å
x¬¬ç é
.¬¬é è
TaxDocumentType¬¬è û
.¬¬û ü
ToString¬¬ü ß
(¬¬ß ®
)¬¬® ©
,¬¬© ™
category¬¬´ ≥
=¬¬¥ µ
x¬¬∂ ∑
.¬¬∑ ∏
Category¬¬∏ ¿
,¬¬¿ ¡
tags¬¬¬ ∆
=¬¬« »
x¬¬…  
.¬¬  À
Tags¬¬À œ
,¬¬œ –
allowsTickets¬¬— ﬁ
=¬¬ﬂ ‡
x¬¬· ‚
.¬¬‚ „
AllowsTickets¬¬„ 
}¬¬Ò Ú
;¬¬Ú Û
private
√√ 
async
√√ 
Task
√√ 
<
√√ 
object
√√ 
>
√√ #
ClientProductDtoAsync
√√ 4
(
√√4 5
ClientProduct
√√5 B
x
√√C D
,
√√D E
CancellationToken
√√F W
ct
√√X Z
)
√√Z [
=>
√√\ ^
ClientProductDto
√√_ o
(
√√o p
x
√√p q
,
√√q r
x
√√s t
.
√√t u
Product
√√u |
is
√√} 
null√√Ä Ñ
?√√Ö Ü
$num√√á â
:√√ä ã
await√√å ë
db√√í î
.√√î ï
IgvRateForAsync√√ï §
(√√§ •
x√√• ¶
.√√¶ ß
ClientId√√ß Ø
,√√Ø ∞
x√√± ≤
.√√≤ ≥
Product√√≥ ∫
,√√∫ ª
ct√√º æ
)√√æ ø
)√√ø ¿
;√√¿ ¡
private
≈≈ 
static
≈≈ 
object
≈≈ 
ClientProductDto
≈≈ *
(
≈≈* +
ClientProduct
≈≈+ 8
x
≈≈9 :
,
≈≈: ;
decimal
≈≈< C
igvRate
≈≈D K
)
≈≈K L
=>
≈≈M O
new
≈≈P S
{
≈≈T U
igvRate
≈≈V ]
,
≈≈] ^
nextChargeTotal
≈≈_ n
=
≈≈o p
x
≈≈q r
.
≈≈r s
NextChargeTotal≈≈s Ç
(≈≈Ç É
igvRate≈≈É ä
)≈≈ä ã
,≈≈ã å
id≈≈ç è
=≈≈ê ë
x≈≈í ì
.≈≈ì î
Id≈≈î ñ
,≈≈ñ ó
clientId≈≈ò †
=≈≈° ¢
x≈≈£ §
.≈≈§ •
ClientId≈≈• ≠
,≈≈≠ Æ
	projectId≈≈Ø ∏
=≈≈π ∫
x≈≈ª º
.≈≈º Ω
	ProjectId≈≈Ω ∆
,≈≈∆ «
projectName≈≈» ”
=≈≈‘ ’
x≈≈÷ ◊
.≈≈◊ ÿ
Project≈≈ÿ ﬂ
?≈≈ﬂ ‡
.≈≈‡ ·
Name≈≈· Â
,≈≈Â Ê
	productId≈≈Á 
=≈≈Ò Ú
x≈≈Û Ù
.≈≈Ù ı
	ProductId≈≈ı ˛
,≈≈˛ ˇ
productName≈≈Ä ã
=≈≈å ç
x≈≈é è
.≈≈è ê
Product≈≈ê ó
?≈≈ó ò
.≈≈ò ô
Name≈≈ô ù
,≈≈ù û
productType≈≈ü ™
=≈≈´ ¨
x≈≈≠ Æ
.≈≈Æ Ø
Product≈≈Ø ∂
?≈≈∂ ∑
.≈≈∑ ∏
Type≈≈∏ º
.≈≈º Ω
ToString≈≈Ω ≈
(≈≈≈ ∆
)≈≈∆ «
,≈≈« »
currency≈≈… —
=≈≈“ ”
x≈≈‘ ’
.≈≈’ ÷
Product≈≈÷ ›
?≈≈› ﬁ
.≈≈ﬁ ﬂ
Currency≈≈ﬂ Á
??≈≈Ë Í
$str≈≈Î 
,≈≈ Ò
billingCycle≈≈Ú ˛
=≈≈ˇ Ä
x≈≈Å Ç
.≈≈Ç É
BillingCycle≈≈É è
.≈≈è ê
ToString≈≈ê ò
(≈≈ò ô
)≈≈ô ö
,≈≈ö õ
isManualBilling≈≈ú ´
=≈≈¨ ≠
x≈≈Æ Ø
.≈≈Ø ∞
IsManualBilling≈≈∞ ø
,≈≈ø ¿
status≈≈¡ «
=≈≈» …
x≈≈  À
.≈≈À Ã
Status≈≈Ã “
.≈≈“ ”
ToString≈≈” €
(≈≈€ ‹
)≈≈‹ ›
,≈≈› ﬁ
price≈≈ﬂ ‰
=≈≈Â Ê
x≈≈Á Ë
.≈≈Ë È
Price≈≈È Ó
,≈≈Ó Ô
	listPrice≈≈ ˘
=≈≈˙ ˚
x≈≈¸ ˝
.≈≈˝ ˛
	ListPrice≈≈˛ á
(≈≈á à
)≈≈à â
,≈≈â ä
discount≈≈ã ì
=≈≈î ï
x≈≈ñ ó
.≈≈ó ò
Discount≈≈ò †
,≈≈† °
discountEndsAt≈≈¢ ∞
=≈≈± ≤
x≈≈≥ ¥
.≈≈¥ µ
DiscountEndsAt≈≈µ √
==≈≈ƒ ∆$
ClientProductPricing≈≈« €
.≈≈€ ‹
NoEnd≈≈‹ ·
?≈≈‚ „
null≈≈‰ Ë
:≈≈È Í
x≈≈Î Ï
.≈≈Ï Ì
DiscountEndsAt≈≈Ì ˚
,≈≈˚ ¸
currentPrice≈≈˝ â
=≈≈ä ã
x≈≈å ç
.≈≈ç é
CurrentPrice≈≈é ö
(≈≈ö õ
DateTime≈≈õ £
.≈≈£ §
UtcNow≈≈§ ™
)≈≈™ ´
,≈≈´ ¨
nextChargePrice≈≈≠ º
=≈≈Ω æ
x≈≈ø ¿
.≈≈¿ ¡
NextChargePrice≈≈¡ –
(≈≈– —
)≈≈— “
,≈≈“ ”

domainName≈≈‘ ﬁ
=≈≈ﬂ ‡
x≈≈· ‚
.≈≈‚ „

DomainName≈≈„ Ì
,≈≈Ì Ó"
priceLabelOverride≈≈Ô Å
=≈≈Ç É
x≈≈Ñ Ö
.≈≈Ö Ü"
PriceLabelOverride≈≈Ü ò
,≈≈ò ô
renewsAt≈≈ö ¢
=≈≈£ §
x≈≈• ¶
.≈≈¶ ß
RenewsAt≈≈ß Ø
,≈≈Ø ∞
nextChargeAt≈≈± Ω
=≈≈æ ø
x≈≈¿ ¡
.≈≈¡ ¬
NextChargeAt≈≈¬ Œ
}≈≈œ –
;≈≈– —
private
«« 
static
«« 
object
«« 
TaxDocumentDto
«« (
(
««( )
TaxDocument
««) 4
x
««5 6
,
««6 7
decimal
««8 ?
	rateToPen
««@ I
,
««I J
IEnumerable
««K V
<
««V W
TaxDocumentLine
««W f
>
««f g
lines
««h m
,
««m n
string
««o u
?
««u v
paymentMethod««w Ñ
)««Ñ Ö
=>««Ü à
new««â å
{««ç é
paymentMethod««è ú
,««ú ù
lines««û £
=««§ •
lines««¶ ´
.««´ ¨
Select««¨ ≤
(««≤ ≥
l««≥ ¥
=>««µ ∑
new««∏ ª
{««º Ω
clientProductId««æ Õ
=««Œ œ
l««– —
.««— “
ClientProductId««“ ·
,««· ‚
description««„ Ó
=««Ô 
l««Ò Ú
.««Ú Û
Description««Û ˛
,««˛ ˇ
amount««Ä Ü
=««á à
l««â ä
.««ä ã
Amount««ã ë
}««í ì
)««ì î
.««î ï
ToList««ï õ
(««õ ú
)««ú ù
,««ù û
id««ü °
=««¢ £
x««§ •
.««• ¶
Id««¶ ®
,««® ©$
paymentTransactionId««™ æ
=««ø ¿
x««¡ ¬
.««¬ √$
PaymentTransactionId««√ ◊
,««◊ ÿ
clientId««Ÿ ·
=««‚ „
x««‰ Â
.««Â Ê
ClientId««Ê Ó
,««Ó Ô
type«« Ù
=««ı ˆ
x««˜ ¯
.««¯ ˘
Type««˘ ˝
.««˝ ˛
ToString««˛ Ü
(««Ü á
)««á à
,««à â
series««ä ê
=««ë í
x««ì î
.««î ï
Series««ï õ
,««õ ú
number««ù £
=««§ •
x««¶ ß
.««ß ®
Number««® Æ
,««Æ Ø
	issueDate««∞ π
=««∫ ª
x««º Ω
.««Ω æ
	IssueDate««æ «
,««« »
currency««… —
=««“ ”
x««‘ ’
.««’ ÷
Currency««÷ ﬁ
,««ﬁ ﬂ

baseAmount««‡ Í
=««Î Ï
x««Ì Ó
.««Ó Ô

BaseAmount««Ô ˘
,««˘ ˙
	igvAmount««˚ Ñ
=««Ö Ü
x««á à
.««à â
	IgvAmount««â í
,««í ì
totalAmount««î ü
=««† °
x««¢ £
.««£ §
TotalAmount««§ Ø
,««Ø ∞
notes««± ∂
=««∑ ∏
x««π ∫
.««∫ ª
Notes««ª ¿
,««¿ ¡
retentionAmount««¬ —
=««“ ”
x««‘ ’
.««’ ÷
RetentionAmount««÷ Â
,««Â Ê
exchangeRate
»» 
=
»» 
x
»» 
.
»» 
Currency
»» !
==
»»" $
$str
»»% *
?
»»+ ,
$num
»»- /
:
»»0 1
Math
»»2 6
.
»»6 7
Round
»»7 <
(
»»< =
	rateToPen
»»= F
,
»»F G
$num
»»H I
)
»»I J
,
»»J K
basePen
»»L S
=
»»T U
Math
»»V Z
.
»»Z [
Round
»»[ `
(
»»` a
x
»»a b
.
»»b c

BaseAmount
»»c m
*
»»n o
	rateToPen
»»p y
,
»»y z
$num
»»{ |
)
»»| }
,
»»} ~
igvPen»» Ö
=»»Ü á
Math»»à å
.»»å ç
Round»»ç í
(»»í ì
x»»ì î
.»»î ï
	IgvAmount»»ï û
*»»ü †
	rateToPen»»° ™
,»»™ ´
$num»»¨ ≠
)»»≠ Æ
,»»Æ Ø
totalPen»»∞ ∏
=»»π ∫
Math»»ª ø
.»»ø ¿
Round»»¿ ≈
(»»≈ ∆
x»»∆ «
.»»« »
TotalAmount»»» ”
*»»‘ ’
	rateToPen»»÷ ﬂ
,»»ﬂ ‡
$num»»· ‚
)»»‚ „
}»»‰ Â
;»»Â Ê
private
   
static
   
void
   !
ApplyForeignService
   +
(
  + ,
Expense
  , 3
expense
  4 ;
,
  ; <
bool
  = A
foreign
  B I
,
  I J
string
  K Q
?
  Q R
name
  S W
,
  W X
string
  Y _
?
  _ `
country
  a h
)
  h i
{
ÀÀ 
expense
ÃÃ 
.
ÃÃ #
IsNonDomiciledService
ÃÃ %
=
ÃÃ& '
foreign
ÃÃ( /
;
ÃÃ/ 0
(
ÕÕ 	
expense
ÕÕ	 
.
ÕÕ !
ForeignSupplierName
ÕÕ $
,
ÕÕ$ %
expense
ÕÕ& -
.
ÕÕ- .$
ForeignSupplierCountry
ÕÕ. D
)
ÕÕD E
=
ÕÕF G
foreign
ÕÕH O
?
ÕÕP Q
(
ÕÕR S
EmptyToNull
ÕÕS ^
(
ÕÕ^ _
name
ÕÕ_ c
)
ÕÕc d
,
ÕÕd e
EmptyToNull
ÕÕf q
(
ÕÕq r
country
ÕÕr y
)
ÕÕy z
)
ÕÕz {
:
ÕÕ| }
(
ÕÕ~ 
nullÕÕ É
,ÕÕÉ Ñ
nullÕÕÖ â
)ÕÕâ ä
;ÕÕä ã
if
ŒŒ 

(
ŒŒ 
!
ŒŒ 
foreign
ŒŒ 
)
ŒŒ 
(
ŒŒ 
expense
ŒŒ 
.
ŒŒ 
Form1662PaidAt
ŒŒ -
,
ŒŒ- .
expense
ŒŒ/ 6
.
ŒŒ6 7
Form1662Number
ŒŒ7 E
)
ŒŒE F
=
ŒŒG H
(
ŒŒI J
null
ŒŒJ N
,
ŒŒN O
null
ŒŒP T
)
ŒŒT U
;
ŒŒU V
}
œœ 
private
—— 
static
—— 
object
—— 

ExpenseDto
—— $
(
——$ %
Expense
——% ,
x
——- .
)
——. /
=>
——0 2
new
——3 6
{
——7 8
id
——9 ;
=
——< =
x
——> ?
.
——? @
Id
——@ B
,
——B C
description
——D O
=
——P Q
x
——R S
.
——S T
Description
——T _
,
——_ `

categoryId
——a k
=
——l m
x
——n o
.
——o p

CategoryId
——p z
,
——z {
categoryName——| à
=——â ä
x——ã å
.——å ç
Category——ç ï
?——ï ñ
.——ñ ó
Name——ó õ
??——ú û
$str——ü °
,——° ¢
type——£ ß
=——® ©
x——™ ´
.——´ ¨
Type——¨ ∞
.——∞ ±
ToString——± π
(——π ∫
)——∫ ª
,——ª º
amount——Ω √
=——ƒ ≈
x——∆ «
.——« »
Amount——» Œ
,——Œ œ
currency——– ÿ
=——Ÿ ⁄
x——€ ‹
.——‹ ›
Currency——› Â
,——Â Ê
	amountPen——Á 
=——Ò Ú
x——Û Ù
.——Ù ı
	AmountPen——ı ˛
,——˛ ˇ
date——Ä Ñ
=——Ö Ü
x——á à
.——à â
Date——â ç
,——ç é
	recurring——è ò
=——ô ö
x——õ ú
.——ú ù
	Recurring——ù ¶
,——¶ ß
recurrenceCycle——® ∑
=——∏ π
x——∫ ª
.——ª º
RecurrenceCycle——º À
?——À Ã
.——Ã Õ
ToString——Õ ’
(——’ ÷
)——÷ ◊
,——◊ ÿ 
recurrenceEndsAt——Ÿ È
=——Í Î
x——Ï Ì
.——Ì Ó 
RecurrenceEndsAt——Ó ˛
,——˛ ˇ
isNonDeductible——Ä è
=——ê ë
x——í ì
.——ì î
IsNonDeductible——î £
,——£ §%
isNonDomiciledService——• ∫
=——ª º
x——Ω æ
.——æ ø%
IsNonDomiciledService——ø ‘
,——‘ ’#
foreignSupplierName——÷ È
=——Í Î
x——Ï Ì
.——Ì Ó#
ForeignSupplierName——Ó Å
,——Å Ç&
foreignSupplierCountry——É ô
=——ö õ
x——ú ù
.——ù û&
ForeignSupplierCountry——û ¥
,——¥ µ
form1662PaidAt——∂ ƒ
=——≈ ∆
x——« »
.——» …
Form1662PaidAt——… ◊
,——◊ ÿ
form1662Number——Ÿ Á
=——Ë È
x——Í Î
.——Î Ï
Form1662Number——Ï ˙
}——˚ ¸
;——¸ ˝
}““ 
public‘‘ 
sealed
‘‘ 
record
‘‘ 
ProfileRequest
‘‘ #
(
‘‘# $
string
‘‘$ *
Name
‘‘+ /
)
‘‘/ 0
;
‘‘0 1
public’’ 
sealed
’’ 
record
’’ #
ChangePasswordRequest
’’ *
(
’’* +
string
’’+ 1
CurrentPassword
’’2 A
,
’’A B
string
’’C I
NewPassword
’’J U
)
’’U V
;
’’V W
public÷÷ 
sealed
÷÷ 
record
÷÷ 
InviteRequest
÷÷ "
(
÷÷" #
string
÷÷# )
Name
÷÷* .
,
÷÷. /
string
÷÷0 6
Email
÷÷7 <
)
÷÷< =
;
÷÷= >
publicÿÿ 
sealed
ÿÿ 
record
ÿÿ 
UpdateTeamRequest
ÿÿ &
(
ÿÿ& '
UserRole
ÿÿ' /
?
ÿÿ/ 0
Role
ÿÿ1 5
,
ÿÿ5 6
bool
ÿÿ7 ;
?
ÿÿ; <
IsActive
ÿÿ= E
,
ÿÿE F
string
ÿÿG M
?
ÿÿM N
Area
ÿÿO S
=
ÿÿT U
null
ÿÿV Z
,
ÿÿZ [
string
ÿÿ\ b
?
ÿÿb c
JobTitle
ÿÿd l
=
ÿÿm n
null
ÿÿo s
,
ÿÿs t
Guid
ÿÿu y
?
ÿÿy z
	ManagerIdÿÿ{ Ñ
=ÿÿÖ Ü
nullÿÿá ã
)ÿÿã å
;ÿÿå ç
publicŸŸ 
sealed
ŸŸ 
record
ŸŸ 
ClientRequest
ŸŸ "
(
ŸŸ" #
string
ŸŸ# )
CompanyName
ŸŸ* 5
,
ŸŸ5 6
string
ŸŸ7 =
ContactName
ŸŸ> I
,
ŸŸI J
string
ŸŸK Q
Email
ŸŸR W
,
ŸŸW X
string
ŸŸY _
?
ŸŸ_ `
Phone
ŸŸa f
,
ŸŸf g
string
ŸŸh n 
PreferredLanguageŸŸo Ä
,ŸŸÄ Å
boolŸŸÇ Ü#
RequiresTaxDocumentŸŸá ö
=ŸŸõ ú
falseŸŸù ¢
)ŸŸ¢ £
;ŸŸ£ §
public⁄⁄ 
sealed
⁄⁄ 
record
⁄⁄  
ClientPatchRequest
⁄⁄ '
(
⁄⁄' (
string
⁄⁄( .
?
⁄⁄. /
CompanyName
⁄⁄0 ;
,
⁄⁄; <
string
⁄⁄= C
?
⁄⁄C D
ContactName
⁄⁄E P
,
⁄⁄P Q
string
⁄⁄R X
?
⁄⁄X Y
Email
⁄⁄Z _
,
⁄⁄_ `
string
⁄⁄a g
?
⁄⁄g h
Phone
⁄⁄i n
,
⁄⁄n o
string
⁄⁄p v
?
⁄⁄v w 
PreferredLanguage⁄⁄x â
,⁄⁄â ä
bool⁄⁄ã è
?⁄⁄è ê
IsActive⁄⁄ë ô
,⁄⁄ô ö
bool⁄⁄õ ü
?⁄⁄ü †#
RequiresTaxDocument⁄⁄° ¥
=⁄⁄µ ∂
null⁄⁄∑ ª
)⁄⁄ª º
;⁄⁄º Ω
public€€ 
sealed
€€ 
record
€€ 
ProductRequest
€€ #
(
€€# $
[
€€$ %
property
€€% -
:
€€- .
JsonRequired
€€/ ;
]
€€; <
ProductType
€€= H
Type
€€I M
,
€€M N
string
€€O U
Name
€€V Z
,
€€Z [
[
€€\ ]
property
€€] e
:
€€e f
JsonRequired
€€g s
]
€€s t
BillingCycle€€u Å
BillingCycle€€Ç é
,€€é è
decimal€€ê ó
?€€ó ò
	BasePrice€€ô ¢
,€€¢ £
string€€§ ™
Currency€€´ ≥
,€€≥ ¥
string€€µ ª
?€€ª º
Description€€Ω »
,€€» …
[€€  À
property€€À ”
:€€” ‘
JsonRequired€€’ ·
]€€· ‚
bool€€„ Á
IsActive€€Ë 
,€€ Ò
TaxDocumentType€€Ú Å
TaxDocumentType€€Ç ë
=€€í ì
TaxDocumentType€€î £
.€€£ §
Factura€€§ ´
,€€´ ¨
string€€≠ ≥
?€€≥ ¥
Category€€µ Ω
=€€æ ø
null€€¿ ƒ
,€€ƒ ≈
string€€∆ Ã
?€€Ã Õ
Tags€€Œ “
=€€” ‘
null€€’ Ÿ
,€€Ÿ ⁄
bool€€€ ﬂ
AllowsTickets€€‡ Ì
=€€Ó Ô
false€€ ı
)€€ı ˆ
;€€ˆ ˜
public‹‹ 
sealed
‹‹ 
record
‹‹ !
ProductPatchRequest
‹‹ (
(
‹‹( )
ProductType
‹‹) 4
?
‹‹4 5
Type
‹‹6 :
,
‹‹: ;
string
‹‹< B
?
‹‹B C
Name
‹‹D H
,
‹‹H I
BillingCycle
‹‹J V
?
‹‹V W
BillingCycle
‹‹X d
,
‹‹d e
decimal
‹‹f m
?
‹‹m n
	BasePrice
‹‹o x
,
‹‹x y
string‹‹z Ä
?‹‹Ä Å
Currency‹‹Ç ä
,‹‹ä ã
string‹‹å í
?‹‹í ì
Description‹‹î ü
,‹‹ü †
bool‹‹° •
?‹‹• ¶
IsActive‹‹ß Ø
,‹‹Ø ∞
TaxDocumentType‹‹± ¿
?‹‹¿ ¡
TaxDocumentType‹‹¬ —
=‹‹“ ”
null‹‹‘ ÿ
,‹‹ÿ Ÿ
string‹‹⁄ ‡
?‹‹‡ ·
Category‹‹‚ Í
=‹‹Î Ï
null‹‹Ì Ò
,‹‹Ò Ú
string‹‹Û ˘
?‹‹˘ ˙
Tags‹‹˚ ˇ
=‹‹Ä Å
null‹‹Ç Ü
,‹‹Ü á
bool‹‹à å
?‹‹å ç
AllowsTickets‹‹é õ
=‹‹ú ù
null‹‹û ¢
)‹‹¢ £
;‹‹£ §
public›› 
sealed
›› 
record
›› "
AssignProductRequest
›› )
(
››) *
[
››* +
property
››+ 3
:
››3 4
JsonRequired
››5 A
]
››A B
Guid
››C G
	ProductId
››H Q
,
››Q R
[
››S T
property
››T \
:
››\ ]
JsonRequired
››^ j
]
››j k
Guid
››l p
	ProjectId
››q z
,
››z {
[
››| }
property››} Ö
:››Ö Ü
JsonRequired››á ì
]››ì î
BillingCycle››ï °
BillingCycle››¢ Æ
,››Æ Ø
string››∞ ∂
BillingMode››∑ ¬
,››¬ √
decimal››ƒ À
?››À Ã
Price››Õ “
,››“ ”
string››‘ ⁄
?››⁄ €

DomainName››‹ Ê
,››Ê Á
string››Ë Ó
?››Ó Ô"
PriceLabelOverride›› Ç
,››Ç É
DateOnly››Ñ å
?››å ç
RenewsAt››é ñ
=››ó ò
null››ô ù
,››ù û
DateOnly››ü ß
?››ß ®
NextChargeAt››© µ
=››∂ ∑
null››∏ º
,››º Ω
decimal››æ ≈
?››≈ ∆
Discount››« œ
=››– —
null››“ ÷
)››÷ ◊
;››◊ ÿ
publicﬁﬁ 
sealed
ﬁﬁ 
record
ﬁﬁ $
TransferPaymentRequest
ﬁﬁ +
(
ﬁﬁ+ ,
decimal
ﬁﬁ, 3
?
ﬁﬁ3 4
Amount
ﬁﬁ5 ;
,
ﬁﬁ; <
DateOnly
ﬁﬁ= E
?
ﬁﬁE F
PaidAt
ﬁﬁG M
,
ﬁﬁM N
string
ﬁﬁO U
?
ﬁﬁU V
	Reference
ﬁﬁW `
,
ﬁﬁ` a
int
ﬁﬁb e
Years
ﬁﬁf k
=
ﬁﬁl m
$num
ﬁﬁn o
)
ﬁﬁo p
;
ﬁﬁp q
publicﬂﬂ 
sealed
ﬂﬂ 
record
ﬂﬂ '
ClientProductDatesRequest
ﬂﬂ .
(
ﬂﬂ. /
DateOnly
ﬂﬂ/ 7
?
ﬂﬂ7 8
RenewsAt
ﬂﬂ9 A
,
ﬂﬂA B
DateOnly
ﬂﬂC K
?
ﬂﬂK L
NextChargeAt
ﬂﬂM Y
)
ﬂﬂY Z
;
ﬂﬂZ [
public‡‡ 
sealed
‡‡ 
record
‡‡ '
ClientProductPatchRequest
‡‡ .
(
‡‡. /
decimal
‡‡/ 6
?
‡‡6 7
Price
‡‡8 =
,
‡‡= >!
ClientProductStatus
‡‡? R
?
‡‡R S
Status
‡‡T Z
,
‡‡Z [
BillingCycle
‡‡\ h
?
‡‡h i
BillingCycle
‡‡j v
,
‡‡v w
bool
‡‡x |
?
‡‡| }
IsManualBilling‡‡~ ç
,‡‡ç é
string‡‡è ï
?‡‡ï ñ

DomainName‡‡ó °
,‡‡° ¢
string‡‡£ ©
?‡‡© ™"
PriceLabelOverride‡‡´ Ω
,‡‡Ω æ
decimal‡‡ø ∆
?‡‡∆ «
Discount‡‡» –
=‡‡— “
null‡‡” ◊
,‡‡◊ ÿ
Guid‡‡Ÿ ›
?‡‡› ﬁ
	ProjectId‡‡ﬂ Ë
=‡‡È Í
null‡‡Î Ô
)‡‡Ô 
;‡‡ Ò
public·· 
sealed
·· 
record
·· 
ImportError
··  
(
··  !
int
··! $
Row
··% (
,
··( )
string
··* 0
Reason
··1 7
)
··7 8
;
··8 9
public„„ 
sealed
„„ 
record
„„ 
TemplateColumn
„„ #
(
„„# $
string
„„$ *
Name
„„+ /
,
„„/ 0
bool
„„1 5
Required
„„6 >
,
„„> ?
string
„„@ F
Accepted
„„G O
,
„„O P
string
„„Q W
[
„„W X
]
„„X Y
?
„„Y Z
Options
„„[ b
=
„„c d
null
„„e i
)
„„i j
;
„„j k
public‰‰ 
sealed
‰‰ 
record
‰‰ 
ClientAccess
‰‰ !
(
‰‰! "
string
‰‰" (

ClientName
‰‰) 3
,
‰‰3 4
string
‰‰5 ;
Email
‰‰< A
,
‰‰A B
string
‰‰C I
TemporaryPassword
‰‰J [
,
‰‰[ \
bool
‰‰] a
	EmailSent
‰‰b k
=
‰‰l m
false
‰‰n s
)
‰‰s t
;
‰‰t u
publicÂÂ 
sealed
ÂÂ 
record
ÂÂ 
ProjectRequest
ÂÂ #
(
ÂÂ# $
string
ÂÂ$ *
?
ÂÂ* +
Name
ÂÂ, 0
,
ÂÂ0 1
string
ÂÂ2 8
?
ÂÂ8 9
Slug
ÂÂ: >
,
ÂÂ> ?
string
ÂÂ@ F
?
ÂÂF G
GithubRepoOwner
ÂÂH W
,
ÂÂW X
string
ÂÂY _
?
ÂÂ_ `
GithubRepoName
ÂÂa o
)
ÂÂo p
;
ÂÂp q
publicÊÊ 
sealed
ÊÊ 
record
ÊÊ 
RepositoryRequest
ÊÊ &
(
ÊÊ& '
string
ÊÊ' -
?
ÊÊ- .
Owner
ÊÊ/ 4
,
ÊÊ4 5
string
ÊÊ6 <
?
ÊÊ< =
Name
ÊÊ> B
,
ÊÊB C
string
ÊÊD J
?
ÊÊJ K
Label
ÊÊL Q
=
ÊÊR S
null
ÊÊT X
,
ÊÊX Y
bool
ÊÊZ ^
?
ÊÊ^ _
	IsDefault
ÊÊ` i
=
ÊÊj k
null
ÊÊl p
)
ÊÊp q
;
ÊÊq r
publicÁÁ 
sealed
ÁÁ 
record
ÁÁ  
TaxSettingsRequest
ÁÁ '
(
ÁÁ' (
decimal
ÁÁ( /
?
ÁÁ/ 0
IgvRate
ÁÁ1 8
,
ÁÁ8 9
decimal
ÁÁ: A
?
ÁÁA B
	RentaRate
ÁÁC L
,
ÁÁL M
string
ÁÁN T
?
ÁÁT U
FacturaSeries
ÁÁV c
=
ÁÁd e
null
ÁÁf j
,
ÁÁj k
int
ÁÁl o
?
ÁÁo p 
FacturaNextNumberÁÁq Ç
=ÁÁÉ Ñ
nullÁÁÖ â
,ÁÁâ ä
stringÁÁã ë
?ÁÁë í
ReciboSeriesÁÁì ü
=ÁÁ† °
nullÁÁ¢ ¶
,ÁÁ¶ ß
intÁÁ® ´
?ÁÁ´ ¨ 
ReciboNextNumberÁÁ≠ Ω
=ÁÁæ ø
nullÁÁ¿ ƒ
,ÁÁƒ ≈
stringÁÁ∆ Ã
?ÁÁÃ Õ
RucÁÁŒ —
=ÁÁ“ ”
nullÁÁ‘ ÿ
,ÁÁÿ Ÿ
boolÁÁ⁄ ﬁ
?ÁÁﬁ ﬂ
IsGoodTaxpayerÁÁ‡ Ó
=ÁÁÔ 
nullÁÁÒ ı
,ÁÁı ˆ
boolÁÁ˜ ˚
?ÁÁ˚ ¸
Use1662AsCreditÁÁ˝ å
=ÁÁç é
nullÁÁè ì
)ÁÁì î
;ÁÁî ï
publicÈÈ 
sealed
ÈÈ 
record
ÈÈ  
TaxDocumentRequest
ÈÈ '
(
ÈÈ' (
Guid
ÈÈ( ,
?
ÈÈ, -
ClientProductId
ÈÈ. =
,
ÈÈ= >
[
ÈÈ? @
property
ÈÈ@ H
:
ÈÈH I
JsonRequired
ÈÈJ V
]
ÈÈV W
DateOnly
ÈÈX `
	IssueDate
ÈÈa j
,
ÈÈj k
string
ÈÈl r
Currency
ÈÈs {
,
ÈÈ{ |
decimalÈÈ} Ñ
?ÈÈÑ Ö
TotalAmountÈÈÜ ë
,ÈÈë í
stringÈÈì ô
?ÈÈô ö
NotesÈÈõ †
,ÈÈ† °
decimalÈÈ¢ ©
?ÈÈ© ™
RetentionAmountÈÈ´ ∫
=ÈÈª º
nullÈÈΩ ¡
,ÈÈ¡ ¬
IReadOnlyListÈÈ√ –
<ÈÈ– —&
TaxDocumentItemRequestÈÈ— Á
>ÈÈÁ Ë
?ÈÈË È
ItemsÈÈÍ Ô
=ÈÈ Ò
nullÈÈÚ ˆ
)ÈÈˆ ˜
;ÈÈ˜ ¯
publicÍÍ 
sealed
ÍÍ 
record
ÍÍ $
TaxDocumentItemRequest
ÍÍ +
(
ÍÍ+ ,
Guid
ÍÍ, 0
ClientProductId
ÍÍ1 @
,
ÍÍ@ A
decimal
ÍÍB I
Amount
ÍÍJ P
)
ÍÍP Q
;
ÍÍQ R
publicÎÎ 
sealed
ÎÎ 
record
ÎÎ '
ReverseTaxDocumentRequest
ÎÎ .
(
ÎÎ. /
string
ÎÎ/ 5
?
ÎÎ5 6
Reason
ÎÎ7 =
,
ÎÎ= >
[
ÎÎ? @
property
ÎÎ@ H
:
ÎÎH I
JsonRequired
ÎÎJ V
]
ÎÎV W
bool
ÎÎX \
	NotIssued
ÎÎ] f
)
ÎÎf g
;
ÎÎg h
publicÏÏ 
sealed
ÏÏ 
record
ÏÏ 
ExpenseRequest
ÏÏ #
(
ÏÏ# $
string
ÏÏ$ *
Description
ÏÏ+ 6
,
ÏÏ6 7
[
ÏÏ8 9
property
ÏÏ9 A
:
ÏÏA B
JsonRequired
ÏÏC O
]
ÏÏO P
Guid
ÏÏQ U

CategoryId
ÏÏV `
,
ÏÏ` a
[
ÏÏb c
property
ÏÏc k
:
ÏÏk l
JsonRequired
ÏÏm y
]
ÏÏy z
ExpenseTypeÏÏ{ Ü
TypeÏÏá ã
,ÏÏã å
[ÏÏç é
propertyÏÏé ñ
:ÏÏñ ó
JsonRequiredÏÏò §
]ÏÏ§ •
decimalÏÏ¶ ≠
AmountÏÏÆ ¥
,ÏÏ¥ µ
stringÏÏ∂ º
CurrencyÏÏΩ ≈
,ÏÏ≈ ∆
[ÏÏ« »
propertyÏÏ» –
:ÏÏ– —
JsonRequiredÏÏ“ ﬁ
]ÏÏﬁ ﬂ
DateOnlyÏÏ‡ Ë
DateÏÏÈ Ì
,ÏÏÌ Ó
[ÏÏÔ 
propertyÏÏ ¯
:ÏÏ¯ ˘
JsonRequiredÏÏ˙ Ü
]ÏÏÜ á
boolÏÏà å
	RecurringÏÏç ñ
,ÏÏñ ó
BillingCycleÏÏò §
?ÏÏ§ •
RecurrenceCycleÏÏ¶ µ
,ÏÏµ ∂
boolÏÏ∑ ª
IsNonDeductibleÏÏº À
=ÏÏÃ Õ
falseÏÏŒ ”
,ÏÏ” ‘
boolÏÏ’ Ÿ%
IsNonDomiciledServiceÏÏ⁄ Ô
=ÏÏ Ò
falseÏÏÚ ˜
,ÏÏ˜ ¯
stringÏÏ˘ ˇ
?ÏÏˇ Ä#
ForeignSupplierNameÏÏÅ î
=ÏÏï ñ
nullÏÏó õ
,ÏÏõ ú
stringÏÏù £
?ÏÏ£ §&
ForeignSupplierCountryÏÏ• ª
=ÏÏº Ω
nullÏÏæ ¬
)ÏÏ¬ √
;ÏÏ√ ƒ
publicÌÌ 
sealed
ÌÌ 
record
ÌÌ "
EndRecurrenceRequest
ÌÌ )
(
ÌÌ) *
[
ÌÌ* +
property
ÌÌ+ 3
:
ÌÌ3 4
JsonRequired
ÌÌ5 A
]
ÌÌA B
DateOnly
ÌÌC K
EndsAt
ÌÌL R
)
ÌÌR S
;
ÌÌS T
publicÓÓ 
sealed
ÓÓ 
record
ÓÓ !
ExpensePatchRequest
ÓÓ (
(
ÓÓ( )
string
ÓÓ) /
?
ÓÓ/ 0
Description
ÓÓ1 <
,
ÓÓ< =
Guid
ÓÓ> B
?
ÓÓB C

CategoryId
ÓÓD N
,
ÓÓN O
ExpenseType
ÓÓP [
?
ÓÓ[ \
Type
ÓÓ] a
,
ÓÓa b
decimal
ÓÓc j
?
ÓÓj k
Amount
ÓÓl r
,
ÓÓr s
string
ÓÓt z
?
ÓÓz {
CurrencyÓÓ| Ñ
,ÓÓÑ Ö
DateOnlyÓÓÜ é
?ÓÓé è
DateÓÓê î
,ÓÓî ï
boolÓÓñ ö
?ÓÓö õ
	RecurringÓÓú •
,ÓÓ• ¶
BillingCycleÓÓß ≥
?ÓÓ≥ ¥
RecurrenceCycleÓÓµ ƒ
,ÓÓƒ ≈
boolÓÓ∆  
?ÓÓ  À
IsNonDeductibleÓÓÃ €
=ÓÓ‹ ›
nullÓÓﬁ ‚
,ÓÓ‚ „
boolÓÓ‰ Ë
?ÓÓË È%
IsNonDomiciledServiceÓÓÍ ˇ
=ÓÓÄ Å
nullÓÓÇ Ü
,ÓÓÜ á
stringÓÓà é
?ÓÓé è#
ForeignSupplierNameÓÓê £
=ÓÓ§ •
nullÓÓ¶ ™
,ÓÓ™ ´
stringÓÓ¨ ≤
?ÓÓ≤ ≥&
ForeignSupplierCountryÓÓ¥  
=ÓÓÀ Ã
nullÓÓÕ —
)ÓÓ— “
;ÓÓ“ ”◊
6C:\repo\rtres-net\Rtres\src\api\Rtres.Api\Contracts.cs
	namespace 	
Rtres
 
. 
Api 
; 
public 
record 
LoginRequest 
( 
string !
Email" '
,' (
string) /
Password0 8
)8 9
;9 :
public 
record 
GoogleLoginRequest  
(  !
string! '
IdToken( /
)/ 0
;0 1
public		 
record		 
LoginLinkRequest		 
(		 
string		 %
Email		& +
)		+ ,
;		, -
public

 
record

 "
LoginLinkVerifyRequest

 $
(

$ %
string

% +
Token

, 1
)

1 2
;

2 3
public 
record 
TicketAttachmentDto !
(! "
Guid" &
Id' )
,) *
string+ 1
FileName2 :
,: ;
string< B
ContentTypeC N
,N O
longP T
	SizeBytesU ^
)^ _
;_ `
public 
record 
CreateTicketRequest !
(! "
[" #
BindRequired# /
]/ 0
Guid1 5
	ProjectId6 ?
,? @
[A B
BindRequiredB N
]N O

TicketTypeP Z
Type[ _
,_ `
stringa g
Titleh m
,m n
stringo u
Description	v Å
,
Å Ç
string
É â
?
â ä
CurrentBehavior
ã ö
,
ö õ
string
ú ¢
?
¢ £
ExpectedBehavior
§ ¥
,
¥ µ
string
∂ º
?
º Ω
StepsToReproduce
æ Œ
,
Œ œ
string
– ÷
?
÷ ◊
Environment
ÿ „
,
„ ‰
string
Â Î
?
Î Ï 
AcceptanceCriteria
Ì ˇ
,
ˇ Ä
string
Å á
?
á à
EstimatedImpact
â ò
,
ò ô
Guid
ö û
?
û ü
RepositoryId
† ¨
=
≠ Æ
null
Ø ≥
,
≥ ¥
Guid
µ π
?
π ∫
ClientProductId
ª  
=
À Ã
null
Õ —
)
— “
;
“ ”
public 
record &
CreateTicketCommentRequest (
(( )
string) /
Body0 4
)4 5
;5 6
public 
record %
UpdateTicketStatusRequest '
(' (
[( )
property) 1
:1 2
JsonRequired3 ?
]? @
TicketStatusA M
StatusN T
)T U
;U V
public 
record 
TicketCommentDto 
( 
Guid #
Id$ &
,& '
string( .
Body/ 3
,3 4
bool5 9

FromGithub: D
,D E
stringF L
?L M

AuthorNameN X
,X Y
DateTimeZ b
	CreatedAtc l
)l m
;m n