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
77õ ú”3
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
}(( €Å
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
}ff7 8¶]
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
{ 	
if 
( 
! 
AffectsStatus 
( 
action %
,% &
payload' .
). /
)/ 0
return1 7
;7 8
await 
ApplyIssueAsync !
(! "
ticket" (
,( )
issue* /
,/ 0
ct1 3
)3 4
;4 5
} 	
else   
await   
ApplyCommentAsync   $
(  $ %
ticket  % +
,  + ,
action  - 3
,  3 4
payload  5 <
.  < =
GetProperty  = H
(  H I
$str  I R
)  R S
,  S T
ct  U W
)  W X
;  X Y
await!! 
db!! 
.!! 
SaveChangesAsync!! !
(!!! "
ct!!" $
)!!$ %
;!!% &
}"" 
internal(( 
static(( 
bool(( 
AffectsStatus(( &
(((& '
string((' -
?((- .
action((/ 5
,((5 6
JsonElement((7 B
payload((C J
)((J K
=>((L N
action((O U
switch((V \
{)) 
$str** 
or** 
$str** 
=>** !
true**" &
,**& '
$str++ 
or++ 
$str++  
=>++! #
!++$ %
payload++% ,
.++, -
TryGetProperty++- ;
(++; <
$str++< C
,++C D
out++E H
var++I L
label++M R
)++R S
||++T V
(++W X
label++X ]
.++] ^
GetProperty++^ i
(++i j
$str++j p
)++p q
.++q r
	GetString++r {
(++{ |
)++| }
??	++~ Ä
$str
++Å É
)
++É Ñ
.
++Ñ Ö

StartsWith
++Ö è
(
++è ê
GitHubLabels
++ê ú
.
++ú ù
StatusPrefix
++ù ©
,
++© ™
StringComparison
++´ ª
.
++ª º
OrdinalIgnoreCase
++º Õ
)
++Õ Œ
,
++Œ œ
_,, 	
=>,,
 
false,, 
,,, 
}-- 
;-- 
private// 
async// 
Task// 
ApplyIssueAsync// &
(//& '
Ticket//' -
ticket//. 4
,//4 5
JsonElement//6 A
issue//B G
,//G H
CancellationToken//I Z
ct//[ ]
)//] ^
{00 
var11 
labels11 
=11 
issue11 
.11 
TryGetProperty11 )
(11) *
$str11* 2
,112 3
out114 7
var118 ;
l11< =
)11= >
&&11? A
l11B C
.11C D
	ValueKind11D M
==11N P
JsonValueKind11Q ^
.11^ _
Array11_ d
?22 
l22 
.22 
EnumerateArray22 
(22 
)22  
.22  !
Select22! '
(22' (
x22( )
=>22* ,
x22- .
.22. /
GetProperty22/ :
(22: ;
$str22; A
)22A B
.22B C
	GetString22C L
(22L M
)22M N
??22O Q
string22R X
.22X Y
Empty22Y ^
)22^ _
:33 
[33 
]33 
;33 
var44 
stateReason44 
=44 
issue44 
.44  
TryGetProperty44  .
(44. /
$str44/ =
,44= >
out44? B
var44C F
r44G H
)44H I
&&44J L
r44M N
.44N O
	ValueKind44O X
==44Y [
JsonValueKind44\ i
.44i j
String44j p
?44q r
r44s t
.44t u
	GetString44u ~
(44~ 
)	44 Ä
:
44Å Ç
null
44É á
;
44á à
var55 
	newStatus55 
=55 
GitHubLabels55 $
.55$ %
ResolveStatus55% 2
(552 3
issue553 8
.558 9
GetProperty559 D
(55D E
$str55E L
)55L M
.55M N
	GetString55N W
(55W X
)55X Y
??55Z \
$str55] c
,55c d
stateReason55e p
,55p q
labels55r x
)55x y
;55y z
if66 

(66 
	newStatus66 
==66 
ticket66 
.66  
Status66  &
)66& '
return66( .
;66. /
ticket88 
.88 
Status88 
=88 
	newStatus88 !
;88! "
ticket88# )
.88) *
	UpdatedAt88* 3
=884 5
DateTime886 >
.88> ?
UtcNow88? E
;88E F
await99 
NotifyAsync99 
(99 
ticket99  
,99  !
NotificationType99" 2
.992 3
TicketStatusChanged993 F
,99F G
new99H K
(99K L
)99L M
{99N O
[99P Q
$str99Q Y
]99Y Z
=99[ \
	newStatus99] f
.99f g
ToString99g o
(99o p
)99p q
}99r s
,99s t
null99u y
,99y z
ct99{ }
)99} ~
;99~ 
}:: 
private<< 
Task<< 
NotifyAsync<< 
(<< 
Ticket<< #
ticket<<$ *
,<<* +
NotificationType<<, <
type<<= A
,<<A B

Dictionary<<C M
<<<M N
string<<N T
,<<T U
string<<V \
><<\ ]
data<<^ b
,<<b c
string<<d j
?<<j k
	dedupeKey<<l u
,<<u v
CancellationToken	<<w à
ct
<<â ã
)
<<ã å
=>
<<ç è
NotifyTicketAsync== 
(== 
db== 
,== 
notifications== +
,==+ ,
ticket==- 3
,==3 4
type==5 9
,==9 :
data==; ?
,==? @
	dedupeKey==A J
,==J K
ct==L N
)==N O
;==O P
internal?? 
static?? 
async?? 
Task?? 
NotifyTicketAsync?? 0
(??0 1
RtresDbContext??1 ?
db??@ B
,??B C
INotificationSender??D W
notifications??X e
,??e f
Ticket??g m
ticket??n t
,??t u
NotificationType	??v Ü
type
??á ã
,
??ã å

Dictionary
??ç ó
<
??ó ò
string
??ò û
,
??û ü
string
??† ¶
>
??¶ ß
data
??® ¨
,
??¨ ≠
string
??Æ ¥
?
??¥ µ
	dedupeKey
??∂ ø
,
??ø ¿
CancellationToken
??¡ “
ct
??” ’
)
??’ ÷
{@@ 
varAA 
clientAA 
=AA 
awaitAA 
dbAA 
.AA 
ClientsAA %
.AA% &
	FindAsyncAA& /
(AA/ 0
[AA0 1
ticketAA1 7
.AA7 8
ClientIdAA8 @
]AA@ A
,AAA B
ctAAC E
)AAE F
;AAF G
ifBB 

(BB 
clientBB 
isBB 
nullBB 
)BB 
returnBB "
;BB" #
dataCC 
[CC 
$strCC 
]CC 
=CC 
ticketCC !
.CC! "
IdCC" $
.CC$ %
ToStringCC% -
(CC- .
)CC. /
;CC/ 0
dataCC1 5
[CC5 6
$strCC6 <
]CC< =
=CC> ?
ticketCC@ F
.CCF G
CodeCCG K
;CCK L
dataCCM Q
[CCQ R
$strCCR Y
]CCY Z
=CC[ \
ticketCC] c
.CCc d
TitleCCd i
;CCi j
awaitDD 
notificationsDD 
.DD 
	SendAsyncDD %
(DD% &
clientDD& ,
,DD, -
newDD. 1
NotificationDD2 >
(DD> ?
typeDD? C
,DDC D
dataDDE I
,DDI J
	dedupeKeyDDK T
)DDT U
,DDU V
ctDDW Y
)DDY Z
;DDZ [
}EE 
privateGG 
asyncGG 
TaskGG 
ApplyCommentAsyncGG (
(GG( )
TicketGG) /
ticketGG0 6
,GG6 7
stringGG8 >
?GG> ?
actionGG@ F
,GGF G
JsonElementGGH S
commentGGT [
,GG[ \
CancellationTokenGG] n
ctGGo q
)GGq r
{HH 
varII 
	commentIdII 
=II 
commentII 
.II  
GetPropertyII  +
(II+ ,
$strII, 0
)II0 1
.II1 2
GetInt64II2 :
(II: ;
)II; <
;II< =
varJJ 
userJJ 
=JJ 
commentJJ 
.JJ 
GetPropertyJJ &
(JJ& '
$strJJ' -
)JJ- .
;JJ. /
ifKK 

(KK 
userKK 
.KK 
GetPropertyKK 
(KK 
$strKK #
)KK# $
.KK$ %
	GetStringKK% .
(KK. /
)KK/ 0
==KK1 3
$strKK4 9
)KK9 :
returnKK; A
;KKA B
varLL 
bodyLL 
=LL 
commentLL 
.LL 
GetPropertyLL &
(LL& '
$strLL' -
)LL- .
.LL. /
	GetStringLL/ 8
(LL8 9
)LL9 :
??LL; =
stringLL> D
.LLD E
EmptyLLE J
;LLJ K
ifMM 

(MM 
bodyMM 
.MM 
ContainsMM 
(MM 
GitHubLabelsMM &
.MM& '
PortalCommentMarkerMM' :
,MM: ;
StringComparisonMM< L
.MML M
OrdinalMMM T
)MMT U
)MMU V
returnMMW ]
;MM] ^
varNN 
existingNN 
=NN 
awaitNN 
dbNN 
.NN  
TicketCommentsNN  .
.NN. / 
SingleOrDefaultAsyncNN/ C
(NNC D
xNND E
=>NNF H
xNNI J
.NNJ K
TicketIdNNK S
==NNT V
ticketNNW ]
.NN] ^
IdNN^ `
&&NNa c
xNNd e
.NNe f
GithubCommentIdNNf u
==NNv x
	commentId	NNy Ç
,
NNÇ É
ct
NNÑ Ü
)
NNÜ á
;
NNá à
switchOO 
(OO 
actionOO 
)OO 
{PP 	
caseQQ 
$strQQ 
whenQQ 
existingQQ  (
isQQ) +
nullQQ, 0
:QQ0 1
varRR 
loginRR 
=RR 
userRR  
.RR  !
GetPropertyRR! ,
(RR, -
$strRR- 4
)RR4 5
.RR5 6
	GetStringRR6 ?
(RR? @
)RR@ A
;RRA B
dbSS 
.SS 
TicketCommentsSS !
.SS! "
AddSS" %
(SS% &
newSS& )
TicketCommentSS* 7
{SS8 9
TicketIdSS: B
=SSC D
ticketSSE K
.SSK L
IdSSL N
,SSN O
BodySSP T
=SSU V
bodySSW [
,SS[ \

FromGithubSS] g
=SSh i
trueSSj n
,SSn o
GithubCommentIdSSp 
=
SSÄ Å
	commentId
SSÇ ã
,
SSã å
GithubAuthorLogin
SSç û
=
SSü †
login
SS° ¶
}
SSß ®
)
SS® ©
;
SS© ™
awaitTT 
NotifyAsyncTT !
(TT! "
ticketTT" (
,TT( )
NotificationTypeTT* :
.TT: ;
TicketReplyTT; F
,TTF G
newTTH K
(TTK L
)TTL M
{TTN O
[TTP Q
$strTTQ Y
]TTY Z
=TT[ \
loginTT] b
??TTc e
$strTTf m
,TTm n
[TTo p
$strTTp v
]TTv w
=TTx y
bodyTTz ~
}	TT Ä
,
TTÄ Å
$"
TTÇ Ñ
$str
TTÑ ë
{
TTë í
	commentId
TTí õ
}
TTõ ú
"
TTú ù
,
TTù û
ct
TTü °
)
TT° ¢
;
TT¢ £
breakUU 
;UU 
caseVV 
$strVV 
whenVV 
existingVV '
isVV( *
notVV+ .
nullVV/ 3
:VV3 4
existingWW 
.WW 
BodyWW 
=WW 
bodyWW  $
;WW$ %
breakXX 
;XX 
caseYY 
$strYY 
whenYY 
existingYY  (
isYY) +
notYY, /
nullYY0 4
:YY4 5
dbZZ 
.ZZ 
TicketCommentsZZ !
.ZZ! "
RemoveZZ" (
(ZZ( )
existingZZ) 1
)ZZ1 2
;ZZ2 3
break[[ 
;[[ 
default\\ 
:\\ 
return]] 
;]] 
}^^ 	
ticket__ 
.__ 
	UpdatedAt__ 
=__ 
DateTime__ #
.__# $
UtcNow__$ *
;__* +
}`` 
}aa ≠«
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
GG˛ ˇ»
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
{;; 
var<< 
error<< 
=<< 
ResolveClientId<< #
(<<# $
clientId<<$ ,
,<<, -
out<<. 1
var<<2 5
id<<6 8
)<<8 9
;<<9 :
if== 

(== 
error== 
is== 
not== 
null== 
)== 
return== %
error==& +
;==+ ,
var>> 
projects>> 
=>> 
await>> 
db>> 
.>>  
Projects>>  (
.>>( )
Include>>) 0
(>>0 1
x>>1 2
=>>>3 5
x>>6 7
.>>7 8
Repositories>>8 D
)>>D E
.>>E F
Where>>F K
(>>K L
x>>L M
=>>>N P
x>>Q R
.>>R S
ClientId>>S [
==>>\ ^
id>>_ a
)>>a b
.>>b c
ToListAsync>>c n
(>>n o
ct>>o q
)>>q r
;>>r s
foreach?? 
(?? 
var?? 
p?? 
in?? 
projects?? "
)??" #
p??$ %
.??% &
Repositories??& 2
=??3 4
[??5 6
..??6 8
p??9 :
.??: ;
Repositories??; G
.??G H
OrderByDescending??H Y
(??Y Z
r??Z [
=>??\ ^
r??_ `
.??` a
	IsDefault??a j
)??j k
.??k l
ThenBy??l r
(??r s
r??s t
=>??u w
r??x y
.??y z
Name??z ~
)??~ 
]	?? Ä
;
??Ä Å
return@@ 
Ok@@ 
(@@ 
projects@@ 
)@@ 
;@@ 
}AA 
[BB 
HttpGetBB 
(BB 
$strBB 
)BB 
]BB 
publicBB 
asyncBB  %
TaskBB& *
<BB* +
IActionResultBB+ 8
>BB8 9
TicketsBB: A
(BBA B
GuidBBB F
?BBF G
clientIdBBH P
,BBP Q
TicketStatusBBR ^
?BB^ _
statusBB` f
=BBg h
nullBBi m
,BBm n

TicketTypeBBo y
?BBy z
typeBB{ 
=
BBÄ Å
null
BBÇ Ü
,
BBÜ á
int
BBà ã
page
BBå ê
=
BBë í
$num
BBì î
,
BBî ï
CancellationToken
BBñ ß
ct
BB® ™
=
BB´ ¨
default
BB≠ ¥
)
BB¥ µ
{CC 
varDD 
errorDD 
=DD 
ResolveClientIdDD #
(DD# $
clientIdDD$ ,
,DD, -
outDD. 1
varDD2 5
idDD6 8
)DD8 9
;DD9 :
ifEE 

(EE 
errorEE 
isEE 
notEE 
nullEE 
)EE 
returnEE %
errorEE& +
;EE+ ,
pageFF 
=FF 
MathFF 
.FF 
MaxFF 
(FF 
pageFF 
,FF 
$numFF 
)FF  
;FF  !
varGG 
qGG 
=GG 
dbGG 
.GG 
TicketsGG 
.GG 
WhereGG  
(GG  !
xGG! "
=>GG# %
xGG& '
.GG' (
ClientIdGG( 0
==GG1 3
idGG4 6
&&GG7 9
(GG: ;
statusGG; A
==GGB D
nullGGE I
||GGJ L
xGGM N
.GGN O
StatusGGO U
==GGV X
statusGGY _
)GG_ `
&&GGa c
(GGd e
typeGGe i
==GGj l
nullGGm q
||GGr t
xGGu v
.GGv w
TypeGGw {
==GG| ~
type	GG É
)
GGÉ Ñ
)
GGÑ Ö
.
GGÖ Ü
OrderByDescending
GGÜ ó
(
GGó ò
x
GGò ô
=>
GGö ú
x
GGù û
.
GGû ü
	UpdatedAt
GGü ®
)
GG® ©
;
GG© ™
varHH 
nHH 
=HH 
awaitHH 
qHH 
.HH 

CountAsyncHH "
(HH" #
ctHH# %
)HH% &
;HH& '
returnII 
OkII 
(II 
newII 
{II 
itemsII 
=II 
awaitII  %
qII& '
.II' (
SkipII( ,
(II, -
(II- .
pageII. 2
-II3 4
$numII5 6
)II6 7
*II8 9
$numII: <
)II< =
.II= >
TakeII> B
(IIB C
$numIIC E
)IIE F
.IIF G
ToListAsyncIIG R
(IIR S
ctIIS U
)IIU V
,IIV W
pageIIX \
,II\ ]

totalPagesII^ h
=IIi j
(IIk l
intIIl o
)IIo p
MathIIp t
.IIt u
CeilingIIu |
(II| }
nII} ~
/	II Ä
$num
IIÅ Ñ
)
IIÑ Ö
}
IIÜ á
)
IIá à
;
IIà â
}JJ 
[KK 
HttpGetKK 
(KK 
$strKK  
)KK  !
]KK! "
publicLL 

asyncLL 
TaskLL 
<LL 
IActionResultLL #
>LL# $
TicketLL% +
(LL+ ,
GuidLL, 0
idLL1 3
,LL3 4
GuidLL5 9
?LL9 :
clientIdLL; C
,LLC D
CancellationTokenLLE V
ctLLW Y
)LLY Z
{MM 
varOO 
	anyClientOO 
=OO 
IsSuperAdminOO $
&&OO% '
clientIdOO( 0
isOO1 3
nullOO4 8
;OO8 9
varOO: =
clientOO> D
=OOE F
GuidOOG K
.OOK L
EmptyOOL Q
;OOQ R
ifPP 

(PP 
!PP 
	anyClientPP 
&&PP 
ResolveClientIdPP )
(PP) *
clientIdPP* 2
,PP2 3
outPP4 7
clientPP8 >
)PP> ?
isPP@ B
{PPC D
}PPE F
errorPPG L
)PPL M
returnPPN T
errorPPU Z
;PPZ [
varQQ 
tQQ 
=QQ 
awaitQQ 
dbQQ 
.QQ 
TicketsQQ  
.QQ  ! 
SingleOrDefaultAsyncQQ! 5
(QQ5 6
xQQ6 7
=>QQ8 :
xQQ; <
.QQ< =
IdQQ= ?
==QQ@ B
idQQC E
&&QQF H
(QQI J
	anyClientQQJ S
||QQT V
xQQW X
.QQX Y
ClientIdQQY a
==QQb d
clientQQe k
)QQk l
,QQl m
ctQQn p
)QQp q
;QQq r
ifQQs u
(QQv w
tQQw x
isQQy {
null	QQ| Ä
)
QQÄ Å
return
QQÇ à
NotFound
QQâ ë
(
QQë í
)
QQí ì
;
QQì î
varRR 
projectRR 
=RR 
awaitRR 
dbRR 
.RR 
ProjectsRR '
.RR' (
IncludeRR( /
(RR/ 0
xRR0 1
=>RR2 4
xRR5 6
.RR6 7
RepositoriesRR7 C
)RRC D
.RRD E
WhereRRE J
(RRJ K
xRRK L
=>RRM O
xRRP Q
.RRQ R
IdRRR T
==RRU W
tRRX Y
.RRY Z
	ProjectIdRRZ c
)RRc d
.RRd e
SingleAsyncRRe p
(RRp q
ctRRq s
)RRs t
;RRt u
varUU 

repositoryUU 
=UU 
projectUU  
.UU  !
RepositoriesUU! -
.UU- .
CountUU. 3
>UU4 5
$numUU6 7
?UU8 9
projectUU: A
.UUA B
RepositoriesUUB N
.UUN O
RepositoryForUUO \
(UU\ ]
tUU] ^
.UU^ _
RepositoryIdUU_ k
)UUk l
:UUm n
nullUUo s
;UUs t
varVV 
	componentVV 
=VV 

repositoryVV "
isVV# %
nullVV& *
?VV+ ,
nullVV- 1
:VV2 3

repositoryVV4 >
.VV> ?
LabelVV? D
??VVE G

repositoryVVH R
.VVR S
NameVVS W
;VVW X
varWW 
	createdByWW 
=WW 
awaitWW 
dbWW  
.WW  !
UserAccountsWW! -
.WW- .
WhereWW. 3
(WW3 4
xWW4 5
=>WW6 8
xWW9 :
.WW: ;
IdWW; =
==WW> @
tWWA B
.WWB C
CreatedByUserIdWWC R
)WWR S
.WWS T
SelectWWT Z
(WWZ [
xWW[ \
=>WW] _
xWW` a
.WWa b
NameWWb f
==WWg i
$strWWj l
?WWm n
xWWo p
.WWp q
EmailWWq v
:WWw x
xWWy z
.WWz {
NameWW{ 
)	WW Ä
.
WWÄ Å"
SingleOrDefaultAsync
WWÅ ï
(
WWï ñ
ct
WWñ ò
)
WWò ô
;
WWô ö
varXX 
attachmentsXX 
=XX 
awaitXX 
dbXX  "
.XX" #
TicketAttachmentsXX# 4
.XX4 5
WhereXX5 :
(XX: ;
xXX; <
=>XX= ?
xXX@ A
.XXA B
TicketIdXXB J
==XXK M
idXXN P
)XXP Q
.XXQ R
OrderByXXR Y
(XXY Z
xXXZ [
=>XX\ ^
xXX_ `
.XX` a
	CreatedAtXXa j
)XXj k
.XXk l
SelectXXl r
(XXr s
xXXs t
=>XXu w
newXXx { 
TicketAttachmentDto	XX| è
(
XXè ê
x
XXê ë
.
XXë í
Id
XXí î
,
XXî ï
x
XXñ ó
.
XXó ò
FileName
XXò †
,
XX† °
x
XX¢ £
.
XX£ §
ContentType
XX§ Ø
,
XXØ ∞
x
XX± ≤
.
XX≤ ≥
	SizeBytes
XX≥ º
)
XXº Ω
)
XXΩ æ
.
XXæ ø
ToListAsync
XXø  
(
XX  À
ct
XXÀ Õ
)
XXÕ Œ
;
XXŒ œ
varYY 
commentsYY 
=YY 
awaitYY 
ToCommentDtosYY *
(YY* +
dbYY+ -
,YY- .
dbYY/ 1
.YY1 2
TicketCommentsYY2 @
.YY@ A
WhereYYA F
(YYF G
xYYG H
=>YYI K
xYYL M
.YYM N
TicketIdYYN V
==YYW Y
idYYZ \
)YY\ ]
.YY] ^
OrderByYY^ e
(YYe f
xYYf g
=>YYh j
xYYk l
.YYl m
	CreatedAtYYm v
)YYv w
)YYw x
.YYx y
ToListAsync	YYy Ñ
(
YYÑ Ö
ct
YYÖ á
)
YYá à
;
YYà â
returnZZ 
OkZZ 
(ZZ 
newZZ 
{ZZ 
ticketZZ 
=ZZ  
tZZ! "
,ZZ" #
projectNameZZ$ /
=ZZ0 1
projectZZ2 9
.ZZ9 :
NameZZ: >
,ZZ> ?
componentNameZZ@ M
=ZZN O
	componentZZP Y
,ZZY Z
createdByNameZZ[ h
=ZZi j
	createdByZZk t
,ZZt u
attachments	ZZv Å
,
ZZÅ Ç
comments
ZZÉ ã
}
ZZå ç
)
ZZç é
;
ZZé è
}[[ 
[]] 
HttpGet]] 
(]] 
$str]] @
)]]@ A
]]]A B
public^^ 

async^^ 
Task^^ 
<^^ 
IActionResult^^ #
>^^# $

Attachment^^% /
(^^/ 0
Guid^^0 4
id^^5 7
,^^7 8
Guid^^9 =
attachmentId^^> J
,^^J K
Guid^^L P
?^^P Q
clientId^^R Z
,^^Z [
CancellationToken^^\ m
ct^^n p
)^^p q
{__ 
var`` 
	anyClient`` 
=`` 
IsSuperAdmin`` $
&&``% '
clientId``( 0
is``1 3
null``4 8
;``8 9
var``: =
client``> D
=``E F
Guid``G K
.``K L
Empty``L Q
;``Q R
ifaa 

(aa 
!aa 
	anyClientaa 
&&aa 
ResolveClientIdaa )
(aa) *
clientIdaa* 2
,aa2 3
outaa4 7
clientaa8 >
)aa> ?
isaa@ B
{aaC D
}aaE F
erroraaG L
)aaL M
returnaaN T
erroraaU Z
;aaZ [
varbb 
abb 
=bb 
awaitbb 
dbbb 
.bb 
TicketAttachmentsbb *
.bb* + 
SingleOrDefaultAsyncbb+ ?
(bb? @
xbb@ A
=>bbB D
xbbE F
.bbF G
IdbbG I
==bbJ L
attachmentIdbbM Y
&&bbZ \
xbb] ^
.bb^ _
TicketIdbb_ g
==bbh j
idbbk m
&&bbn p
dbbbq s
.bbs t
Ticketsbbt {
.bb{ |
Anybb| 
(	bb Ä
t
bbÄ Å
=>
bbÇ Ñ
t
bbÖ Ü
.
bbÜ á
Id
bbá â
==
bbä å
id
bbç è
&&
bbê í
(
bbì î
	anyClient
bbî ù
||
bbû †
t
bb° ¢
.
bb¢ £
ClientId
bb£ ´
==
bb¨ Æ
client
bbØ µ
)
bbµ ∂
)
bb∂ ∑
,
bb∑ ∏
ct
bbπ ª
)
bbª º
;
bbº Ω
returncc 
acc 
iscc 
nullcc 
?cc 
NotFoundcc #
(cc# $
)cc$ %
:cc& '
Filecc( ,
(cc, -
acc- .
.cc. /
Contentcc/ 6
,cc6 7
acc8 9
.cc9 :
ContentTypecc: E
,ccE F
accG H
.ccH I
FileNameccI Q
)ccQ R
;ccR S
}dd 
[ee 
HttpPostee 
(ee 
$stree *
)ee* +
]ee+ ,
publicff 

asyncff 
Taskff 
<ff 
IActionResultff #
>ff# $

AddCommentff% /
(ff/ 0
Guidff0 4
idff5 7
,ff7 8&
CreateTicketCommentRequestff9 S
rffT U
,ffU V
CancellationTokenffW h
ctffi k
)ffk l
{gg 
ifhh 

(hh 
IsSuperAdminhh 
)hh 
returnhh  
Forbidhh! '
(hh' (
)hh( )
;hh) *
varii 
errorii 
=ii 
ResolveClientIdii #
(ii# $
nullii$ (
,ii( )
outii* -
varii. 1
clientii2 8
)ii8 9
;ii9 :
ifii; =
(ii> ?
errorii? D
isiiE G
notiiH K
nulliiL P
)iiP Q
returniiR X
erroriiY ^
;ii^ _
ifjj 

(jj 
stringjj 
.jj 
IsNullOrWhiteSpacejj %
(jj% &
rjj& '
.jj' (
Bodyjj( ,
)jj, -
)jj- .
returnjj/ 5

BadRequestjj6 @
(jj@ A
newjjA D
{jjE F
messagejjG N
=jjO P
$strjjQ v
}jjw x
)jjx y
;jjy z
varkk 
ticketkk 
=kk 
awaitkk 
dbkk 
.kk 
Ticketskk %
.kk% & 
SingleOrDefaultAsynckk& :
(kk: ;
xkk; <
=>kk= ?
xkk@ A
.kkA B
IdkkB D
==kkE G
idkkH J
&&kkK M
xkkN O
.kkO P
ClientIdkkP X
==kkY [
clientkk\ b
,kkb c
ctkkd f
)kkf g
;kkg h
ifkki k
(kkl m
ticketkkm s
iskkt v
nullkkw {
)kk{ |
return	kk} É
NotFound
kkÑ å
(
kkå ç
)
kkç é
;
kké è
varll 
commentll 
=ll 
newll 
TicketCommentll '
{ll( )
TicketIdll* 2
=ll3 4
idll5 7
,ll7 8
AuthorUserIdll9 E
=llF G
UserIdllH N
,llN O
BodyllP T
=llU V
rllW X
.llX Y
BodyllY ]
.ll] ^
Trimll^ b
(llb c
)llc d
}lle f
;llf g
dbmm 

.mm
 
TicketCommentsmm 
.mm 
Addmm 
(mm 
commentmm %
)mm% &
;mm& '
ticketmm( .
.mm. /
	UpdatedAtmm/ 8
=mm9 :
DateTimemm; C
.mmC D
UtcNowmmD J
;mmJ K
awaitmmL Q
dbmmR T
.mmT U
SaveChangesAsyncmmU e
(mme f
ctmmf h
)mmh i
;mmi j
jobsnn 
.nn 
Enqueuenn 
<nn 
GitHubIssueSyncJobnn '
>nn' (
(nn( )
jnn) *
=>nn+ -
jnn. /
.nn/ 0
PostCommentAsyncnn0 @
(nn@ A
commentnnA H
.nnH I
IdnnI K
,nnK L
CancellationTokennnM ^
.nn^ _
Nonenn_ c
)nnc d
)nnd e
;nne f
returnoo 
Okoo 
(oo 
awaitoo 
ToCommentDtosoo %
(oo% &
dboo& (
,oo( )
dboo* ,
.oo, -
TicketCommentsoo- ;
.oo; <
Whereoo< A
(ooA B
xooB C
=>ooD F
xooG H
.ooH I
IdooI K
==ooL N
commentooO V
.ooV W
IdooW Y
)ooY Z
)ooZ [
.oo[ \
SingleAsyncoo\ g
(oog h
ctooh j
)ooj k
)ook l
;ool m
}pp 
internalrr 
staticrr 

IQueryablerr 
<rr 
TicketCommentDtorr /
>rr/ 0
ToCommentDtosrr1 >
(rr> ?
RtresDbContextrr? M
dbrrN P
,rrP Q

IQueryablerrR \
<rr\ ]
TicketCommentrr] j
>rrj k
commentsrrl t
)rrt u
=>rrv x
comments	rry Å
.ss 	
Selectss	 
(ss 
xss 
=>ss 
newss 
TicketCommentDtoss )
(ss) *
xss* +
.ss+ ,
Idss, .
,ss. /
xss0 1
.ss1 2
Bodyss2 6
,ss6 7
xss8 9
.ss9 :

FromGithubss: D
,ssD E
xssF G
.ssG H

FromGithubssH R
?ssS T
xssU V
.ssV W
GithubAuthorLoginssW h
:ssi j
dbssk m
.ssm n
UserAccountsssn z
.ssz {
Where	ss{ Ä
(
ssÄ Å
u
ssÅ Ç
=>
ssÉ Ö
u
ssÜ á
.
ssá à
Id
ssà ä
==
ssã ç
x
ssé è
.
ssè ê
AuthorUserId
ssê ú
)
ssú ù
.
ssù û
Select
ssû §
(
ss§ •
u
ss• ¶
=>
ssß ©
u
ss™ ´
.
ss´ ¨
Role
ss¨ ∞
==
ss± ≥
UserRole
ss¥ º
.
ssº Ω

SuperAdmin
ssΩ «
?
ss» …
$str
ss  —
:
ss“ ”
u
ss‘ ’
.
ss’ ÷
Name
ss÷ ⁄
==
ss€ ›
$str
ssﬁ ‡
?
ss· ‚
u
ss„ ‰
.
ss‰ Â
Email
ssÂ Í
:
ssÎ Ï
u
ssÌ Ó
.
ssÓ Ô
Name
ssÔ Û
)
ssÛ Ù
.
ssÙ ı
FirstOrDefault
ssı É
(
ssÉ Ñ
)
ssÑ Ö
,
ssÖ Ü
x
ssá à
.
ssà â
	CreatedAt
ssâ í
)
ssí ì
)
ssì î
;
ssî ï
publictt 

consttt 
inttt 
MaxAttachmentstt #
=tt$ %
$numtt& '
;tt' (
publicuu 

constuu 
longuu 
MaxAttachmentBytesuu (
=uu) *
$numuu+ -
*uu. /
$numuu0 4
*uu5 6
$numuu7 ;
;uu; <
[xx 
HttpPostxx 
(xx 
$strxx 
)xx 
,xx 
RequestSizeLimitxx *
(xx* +
$numxx+ 5
)xx5 6
,xx6 7
RequestFormLimitsxx8 I
(xxI J$
MultipartBodyLengthLimitxxJ b
=xxc d
$numxxe o
)xxo p
]xxp q
publicyy 

asyncyy 
Taskyy 
<yy 
IActionResultyy #
>yy# $
CreateTicketyy% 1
(yy1 2
[yy2 3
FromFormyy3 ;
]yy; <
CreateTicketRequestyy= P
ryyQ R
,yyR S
GuidyyT X
?yyX Y
clientIdyyZ b
,yyb c
CancellationTokenyyd u
ctyyv x
,yyx y
[yyz {
FromForm	yy{ É
]
yyÉ Ñ
List
yyÖ â
<
yyâ ä
	IFormFile
yyä ì
>
yyì î
?
yyî ï
files
yyñ õ
=
yyú ù
null
yyû ¢
)
yy¢ £
{zz 
var{{ 
error{{ 
={{ 
ResolveClientId{{ #
({{# $
clientId{{$ ,
,{{, -
out{{. 1
var{{2 5
clientIdValue{{6 C
){{C D
;{{D E
if{{F H
({{I J
error{{J O
is{{P R
not{{S V
null{{W [
){{[ \
return{{] c
error{{d i
;{{i j
files|| 
??=|| 
[|| 
]|| 
;|| 
if}} 

(}} 
files}} 
.}} 
Count}} 
>}} 
MaxAttachments}} (
)}}( )
return}}* 0

BadRequest}}1 ;
(}}; <
new}}< ?
{}}@ A
message}}B I
=}}J K
$"}}L N
$str}}N U
{}}U V
MaxAttachments}}V d
}}}d e
$str}}e z
"}}z {
}}}| }
)}}} ~
;}}~ 
if~~ 

(~~ 
files~~ 
.~~ 
FirstOrDefault~~  
(~~  !
x~~! "
=>~~# %
x~~& '
.~~' (
Length~~( .
==~~/ 1
$num~~2 3
||~~4 6
x~~7 8
.~~8 9
Length~~9 ?
>~~@ A
MaxAttachmentBytes~~B T
)~~T U
is~~V X
{~~Y Z
}~~[ \
invalid~~] d
)~~d e
return~~f l

BadRequest~~m w
(~~w x
new~~x {
{~~| }
message	~~~ Ö
=
~~Ü á
$"
~~à ä
$str
~~ä ã
{
~~ã å
invalid
~~å ì
.
~~ì î
FileName
~~î ú
}
~~ú ù
$str
~~ù æ
"
~~æ ø
}
~~¿ ¡
)
~~¡ ¬
;
~~¬ √
var 
project 
= 
await 
db 
. 
Projects '
.' (
Include( /
(/ 0
x0 1
=>2 4
x5 6
.6 7
Repositories7 C
)C D
.D E 
SingleOrDefaultAsyncE Y
(Y Z
xZ [
=>\ ^
x_ `
.` a
Ida c
==d f
rg h
.h i
	ProjectIdi r
&&s u
xv w
.w x
ClientId	x Ä
==
Å É
clientIdValue
Ñ ë
,
ë í
ct
ì ï
)
ï ñ
;
ñ ó
if
ò ö
(
õ ú
project
ú £
is
§ ¶
null
ß ´
)
´ ¨
return
≠ ≥
NotFound
¥ º
(
º Ω
)
Ω æ
;
æ ø
if
ÄÄ 

(
ÄÄ 
r
ÄÄ 
.
ÄÄ 
RepositoryId
ÄÄ 
is
ÄÄ 
Guid
ÄÄ "
repositoryId
ÄÄ# /
&&
ÄÄ0 2
project
ÄÄ3 :
.
ÄÄ: ;
Repositories
ÄÄ; G
.
ÄÄG H
All
ÄÄH K
(
ÄÄK L
x
ÄÄL M
=>
ÄÄN P
x
ÄÄQ R
.
ÄÄR S
Id
ÄÄS U
!=
ÄÄV X
repositoryId
ÄÄY e
)
ÄÄe f
)
ÄÄf g
return
ÄÄh n

BadRequest
ÄÄo y
(
ÄÄy z
new
ÄÄz }
{
ÄÄ~ 
messageÄÄÄ á
=ÄÄà â
$strÄÄä ¥
}ÄÄµ ∂
)ÄÄ∂ ∑
;ÄÄ∑ ∏
if
ÅÅ 

(
ÅÅ 
r
ÅÅ 
.
ÅÅ 
ClientProductId
ÅÅ 
is
ÅÅ  
Guid
ÅÅ! %
clientProductId
ÅÅ& 5
&&
ÅÅ6 8
!
ÅÅ9 :
await
ÅÅ: ?
db
ÅÅ@ B
.
ÅÅB C
ClientProducts
ÅÅC Q
.
ÅÅQ R
AnyAsync
ÅÅR Z
(
ÅÅZ [
x
ÅÅ[ \
=>
ÅÅ] _
x
ÅÅ` a
.
ÅÅa b
Id
ÅÅb d
==
ÅÅe g
clientProductId
ÅÅh w
&&
ÅÅx z
x
ÅÅ{ |
.
ÅÅ| }
ClientIdÅÅ} Ö
==ÅÅÜ à
clientIdValueÅÅâ ñ
&&ÅÅó ô
xÅÅö õ
.ÅÅõ ú
	ProjectIdÅÅú •
==ÅÅ¶ ®
rÅÅ© ™
.ÅÅ™ ´
	ProjectIdÅÅ´ ¥
&&ÅÅµ ∑
xÅÅ∏ π
.ÅÅπ ∫
ProductÅÅ∫ ¡
!ÅÅ¡ ¬
.ÅÅ¬ √
AllowsTicketsÅÅ√ –
,ÅÅ– —
ctÅÅ“ ‘
)ÅÅ‘ ’
)ÅÅ’ ÷
return
ÇÇ 

BadRequest
ÇÇ 
(
ÇÇ 
new
ÇÇ !
{
ÇÇ" #
message
ÇÇ$ +
=
ÇÇ, -
$str
ÇÇ. O
}
ÇÇP Q
)
ÇÇQ R
;
ÇÇR S
var
ÉÉ 
ticket
ÉÉ 
=
ÉÉ 
new
ÉÉ 
Ticket
ÉÉ 
{
ÉÉ  !
Code
ÉÉ" &
=
ÉÉ' (
$"
ÉÉ) +
$str
ÉÉ+ .
{
ÉÉ. /
$num
ÉÉ/ 2
+
ÉÉ3 4
await
ÉÉ5 :
db
ÉÉ; =
.
ÉÉ= >
Tickets
ÉÉ> E
.
ÉÉE F

CountAsync
ÉÉF P
(
ÉÉP Q
ct
ÉÉQ S
)
ÉÉS T
}
ÉÉT U
"
ÉÉU V
,
ÉÉV W
ClientId
ÉÉX `
=
ÉÉa b
clientIdValue
ÉÉc p
,
ÉÉp q
	ProjectId
ÉÉr {
=
ÉÉ| }
r
ÉÉ~ 
.ÉÉ Ä
	ProjectIdÉÉÄ â
,ÉÉâ ä
RepositoryIdÉÉã ó
=ÉÉò ô
rÉÉö õ
.ÉÉõ ú
RepositoryIdÉÉú ®
,ÉÉ® ©
ClientProductIdÉÉ™ π
=ÉÉ∫ ª
rÉÉº Ω
.ÉÉΩ æ
ClientProductIdÉÉæ Õ
,ÉÉÕ Œ
CreatedByUserIdÉÉœ ﬁ
=ÉÉﬂ ‡
UserIdÉÉ· Á
,ÉÉÁ Ë
TypeÉÉÈ Ì
=ÉÉÓ Ô
rÉÉ Ò
.ÉÉÒ Ú
TypeÉÉÚ ˆ
,ÉÉˆ ˜
TitleÉÉ¯ ˝
=ÉÉ˛ ˇ
rÉÉÄ Å
.ÉÉÅ Ç
TitleÉÉÇ á
,ÉÉá à
DescriptionÉÉâ î
=ÉÉï ñ
rÉÉó ò
.ÉÉò ô
DescriptionÉÉô §
,ÉÉ§ •
CurrentBehaviorÉÉ¶ µ
=ÉÉ∂ ∑
rÉÉ∏ π
.ÉÉπ ∫
CurrentBehaviorÉÉ∫ …
,ÉÉ…   
ExpectedBehaviorÉÉÀ €
=ÉÉ‹ ›
rÉÉﬁ ﬂ
.ÉÉﬂ ‡ 
ExpectedBehaviorÉÉ‡ 
,ÉÉ Ò 
StepsToReproduceÉÉÚ Ç
=ÉÉÉ Ñ
rÉÉÖ Ü
.ÉÉÜ á 
StepsToReproduceÉÉá ó
,ÉÉó ò
EnvironmentÉÉô §
=ÉÉ• ¶
rÉÉß ®
.ÉÉ® ©
EnvironmentÉÉ© ¥
,ÉÉ¥ µ"
AcceptanceCriteriaÉÉ∂ »
=ÉÉ…  
rÉÉÀ Ã
.ÉÉÃ Õ"
AcceptanceCriteriaÉÉÕ ﬂ
,ÉÉﬂ ‡
EstimatedImpactÉÉ· 
=ÉÉÒ Ú
rÉÉÛ Ù
.ÉÉÙ ı
EstimatedImpactÉÉı Ñ
}ÉÉÖ Ü
;ÉÉÜ á
db
ÑÑ 

.
ÑÑ
 
Tickets
ÑÑ 
.
ÑÑ 
Add
ÑÑ 
(
ÑÑ 
ticket
ÑÑ 
)
ÑÑ 
;
ÑÑ 
foreach
ÖÖ 
(
ÖÖ 
var
ÖÖ 
file
ÖÖ 
in
ÖÖ 
files
ÖÖ "
)
ÖÖ" #
{
ÜÜ 	
using
áá 
var
áá 
stream
áá 
=
áá 
new
áá "
MemoryStream
áá# /
(
áá/ 0
)
áá0 1
;
áá1 2
await
áá3 8
file
áá9 =
.
áá= >
CopyToAsync
áá> I
(
ááI J
stream
ááJ P
,
ááP Q
ct
ááR T
)
ááT U
;
ááU V
db
àà 
.
àà 
TicketAttachments
àà  
.
àà  !
Add
àà! $
(
àà$ %
new
àà% (
TicketAttachment
àà) 9
{
àà: ;
TicketId
àà< D
=
ààE F
ticket
ààG M
.
ààM N
Id
ààN P
,
ààP Q
FileName
ààR Z
=
àà[ \
Path
àà] a
.
ààa b
GetFileName
ààb m
(
ààm n
file
ààn r
.
ààr s
FileName
ààs {
)
àà{ |
,
àà| }
ContentTypeàà~ â
=ààä ã
stringààå í
.ààí ì"
IsNullOrWhiteSpaceààì •
(àà• ¶
fileàà¶ ™
.àà™ ´
ContentTypeàà´ ∂
)àà∂ ∑
?àà∏ π
$stràà∫ ‘
:àà’ ÷
fileàà◊ €
.àà€ ‹
ContentTypeàà‹ Á
,ààÁ Ë
	SizeBytesààÈ Ú
=ààÛ Ù
fileààı ˘
.àà˘ ˙
Lengthàà˙ Ä
,ààÄ Å
ContentààÇ â
=ààä ã
streamààå í
.ààí ì
ToArrayààì ö
(ààö õ
)ààõ ú
}ààù û
)ààû ü
;ààü †
}
ââ 	
await
ää 
db
ää 
.
ää 
SaveChangesAsync
ää !
(
ää! "
ct
ää" $
)
ää$ %
;
ää% &
jobs
ãã 
.
ãã 
Enqueue
ãã 
<
ãã  
GitHubIssueSyncJob
ãã '
>
ãã' (
(
ãã( )
j
ãã) *
=>
ãã+ -
j
ãã. /
.
ãã/ 0
CreateIssueAsync
ãã0 @
(
ãã@ A
ticket
ããA G
.
ããG H
Id
ããH J
,
ããJ K
CancellationToken
ããL ]
.
ãã] ^
None
ãã^ b
)
ããb c
)
ããc d
;
ããd e
if
åå 

(
åå 
project
åå 
.
åå 
Repositories
åå  
.
åå  !
Count
åå! &
==
åå' )
$num
åå* +
)
åå+ ,
await
åå- 2%
NotifyPortalTicketAsync
åå3 J
(
ååJ K
ticket
ååK Q
,
ååQ R
project
ååS Z
,
ååZ [
ct
åå\ ^
)
åå^ _
;
åå_ `
await
çç  
NotifyManagerAsync
çç  
(
çç  !
ticket
çç! '
,
çç' (
project
çç) 0
,
çç0 1
ct
çç2 4
)
çç4 5
;
çç5 6
return
éé 
Created
éé 
(
éé 
$"
éé 
$str
éé &
{
éé& '
ticket
éé' -
.
éé- .
Id
éé. 0
}
éé0 1
"
éé1 2
,
éé2 3
ticket
éé4 :
)
éé: ;
;
éé; <
}
èè 
[
îî 
HttpGet
îî 
(
îî 
$str
îî 
)
îî 
]
îî 
public
ïï 

async
ïï 
Task
ïï 
<
ïï 
IActionResult
ïï #
>
ïï# $
Notifications
ïï% 2
(
ïï2 3
Guid
ïï3 7
?
ïï7 8
clientId
ïï9 A
,
ïïA B
CancellationToken
ïïC T
ct
ïïU W
)
ïïW X
{
ññ 
var
óó 
query
óó 
=
óó 
db
óó 
.
óó !
PortalNotifications
óó *
.
óó* +
AsQueryable
óó+ 6
(
óó6 7
)
óó7 8
;
óó8 9
if
òò 

(
òò 
!
òò 
(
òò 
IsSuperAdmin
òò 
&&
òò 
clientId
òò &
is
òò' )
null
òò* .
)
òò. /
)
òò/ 0
{
ôô 	
var
öö 
error
öö 
=
öö 
ResolveClientId
öö '
(
öö' (
clientId
öö( 0
,
öö0 1
out
öö2 5
var
öö6 9
id
öö: <
)
öö< =
;
öö= >
if
öö? A
(
ööB C
error
ööC H
is
ööI K
not
ööL O
null
ööP T
)
ööT U
return
ööV \
error
öö] b
;
ööb c
query
õõ 
=
õõ 
query
õõ 
.
õõ 
Where
õõ 
(
õõ  
x
õõ  !
=>
õõ" $
x
õõ% &
.
õõ& '
ClientId
õõ' /
==
õõ0 2
id
õõ3 5
&&
õõ6 8
!
õõ9 :
x
õõ: ;
.
õõ; <
ForStaff
õõ< D
)
õõD E
;
õõE F
}
úú 	
var
ùù 
seenAt
ùù 
=
ùù 
await
ùù 
db
ùù 
.
ùù 
UserAccounts
ùù *
.
ùù* +
Where
ùù+ 0
(
ùù0 1
x
ùù1 2
=>
ùù3 5
x
ùù6 7
.
ùù7 8
Id
ùù8 :
==
ùù; =
UserId
ùù> D
)
ùùD E
.
ùùE F
Select
ùùF L
(
ùùL M
x
ùùM N
=>
ùùO Q
x
ùùR S
.
ùùS T!
NotificationsSeenAt
ùùT g
)
ùùg h
.
ùùh i"
SingleOrDefaultAsync
ùùi }
(
ùù} ~
ctùù~ Ä
)ùùÄ Å
;ùùÅ Ç
var
ûû 
unread
ûû 
=
ûû 
await
ûû 
query
ûû  
.
ûû  !

CountAsync
ûû! +
(
ûû+ ,
x
ûû, -
=>
ûû. 0
seenAt
ûû1 7
==
ûû8 :
null
ûû; ?
||
ûû@ B
x
ûûC D
.
ûûD E
	CreatedAt
ûûE N
>
ûûO P
seenAt
ûûQ W
,
ûûW X
ct
ûûY [
)
ûû[ \
;
ûû\ ]
var
üü 
rows
üü 
=
üü 
await
üü 
query
üü 
.
üü 
OrderByDescending
üü 0
(
üü0 1
x
üü1 2
=>
üü3 5
x
üü6 7
.
üü7 8
	CreatedAt
üü8 A
)
üüA B
.
üüB C
Take
üüC G
(
üüG H
$num
üüH J
)
üüJ K
.
†† 
Select
†† 
(
†† 
x
†† 
=>
†† 
new
†† 
{
†† 
x
††  
.
††  !
Id
††! #
,
††# $
x
††% &
.
††& '
ClientId
††' /
,
††/ 0
x
††1 2
.
††2 3
Type
††3 7
,
††7 8
x
††9 :
.
††: ;
ForStaff
††; C
,
††C D
x
††E F
.
††F G
DataJson
††G O
,
††O P
x
††Q R
.
††R S
	CreatedAt
††S \
,
††\ ]
Company
††^ e
=
††f g
db
††h j
.
††j k
Clients
††k r
.
††r s
Where
††s x
(
††x y
c
††y z
=>
††{ }
c
††~ 
.†† Ä
Id††Ä Ç
==††É Ö
x††Ü á
.††á à
ClientId††à ê
)††ê ë
.††ë í
Select††í ò
(††ò ô
c††ô ö
=>††õ ù
c††û ü
.††ü †
CompanyName††† ´
)††´ ¨
.††¨ ≠
FirstOrDefault††≠ ª
(††ª º
)††º Ω
}††æ ø
)††ø ¿
.
°° 
ToListAsync
°° 
(
°° 
ct
°° 
)
°° 
;
°° 
var
¢¢ 
items
¢¢ 
=
¢¢ 
rows
¢¢ 
.
¢¢ 
Select
¢¢ 
(
¢¢  
x
¢¢  !
=>
¢¢" $
new
¢¢% (
{
¢¢) *
id
¢¢+ -
=
¢¢. /
x
¢¢0 1
.
¢¢1 2
Id
¢¢2 4
,
¢¢4 5
clientId
¢¢6 >
=
¢¢? @
x
¢¢A B
.
¢¢B C
ClientId
¢¢C K
,
¢¢K L
company
¢¢M T
=
¢¢U V
x
¢¢W X
.
¢¢X Y
Company
¢¢Y `
,
¢¢` a
type
¢¢b f
=
¢¢g h
x
¢¢i j
.
¢¢j k
Type
¢¢k o
,
¢¢o p
forStaff
¢¢q y
=
¢¢z {
x
¢¢| }
.
¢¢} ~
ForStaff¢¢~ Ü
,¢¢Ü á
	createdAt¢¢à ë
=¢¢í ì
x¢¢î ï
.¢¢ï ñ
	CreatedAt¢¢ñ ü
,¢¢ü †
unread¢¢° ß
=¢¢® ©
seenAt¢¢™ ∞
==¢¢± ≥
null¢¢¥ ∏
||¢¢π ª
x¢¢º Ω
.¢¢Ω æ
	CreatedAt¢¢æ «
>¢¢» …
seenAt¢¢  –
,¢¢– —
data¢¢“ ÷
=¢¢◊ ÿ
JsonSerializer¢¢Ÿ Á
.¢¢Á Ë
Deserialize¢¢Ë Û
<¢¢Û Ù

Dictionary¢¢Ù ˛
<¢¢˛ ˇ
string¢¢ˇ Ö
,¢¢Ö Ü
string¢¢á ç
>¢¢ç é
>¢¢é è
(¢¢è ê
x¢¢ê ë
.¢¢ë í
DataJson¢¢í ö
)¢¢ö õ
??¢¢ú û
[¢¢ü †
]¢¢† °
}¢¢¢ £
)¢¢£ §
;¢¢§ •
return
££ 
Ok
££ 
(
££ 
new
££ 
{
££ 
items
££ 
,
££ 
unread
££ %
}
££& '
)
££' (
;
££( )
}
§§ 
[
¶¶ 
HttpPost
¶¶ 
(
¶¶ 
$str
¶¶ "
)
¶¶" #
]
¶¶# $
public
ßß 

async
ßß 
Task
ßß 
<
ßß 
IActionResult
ßß #
>
ßß# $
NotificationsSeen
ßß% 6
(
ßß6 7
CancellationToken
ßß7 H
ct
ßßI K
)
ßßK L
{
®® 
var
©© 
user
©© 
=
©© 
await
©© 
db
©© 
.
©© 
UserAccounts
©© (
.
©©( )"
SingleOrDefaultAsync
©©) =
(
©©= >
x
©©> ?
=>
©©@ B
x
©©C D
.
©©D E
Id
©©E G
==
©©H J
UserId
©©K Q
,
©©Q R
ct
©©S U
)
©©U V
;
©©V W
if
©©X Z
(
©©[ \
user
©©\ `
is
©©a c
null
©©d h
)
©©h i
return
©©j p
NotFound
©©q y
(
©©y z
)
©©z {
;
©©{ |
user
™™ 
.
™™ !
NotificationsSeenAt
™™  
=
™™! "
DateTime
™™# +
.
™™+ ,
UtcNow
™™, 2
;
™™2 3
await
™™4 9
db
™™: <
.
™™< =
SaveChangesAsync
™™= M
(
™™M N
ct
™™N P
)
™™P Q
;
™™Q R
return
™™S Y
	NoContent
™™Z c
(
™™c d
)
™™d e
;
™™e f
}
´´ 
private
≠≠ 
async
≠≠ 
Task
≠≠ %
NotifyPortalTicketAsync
≠≠ .
(
≠≠. /
Ticket
≠≠/ 5
ticket
≠≠6 <
,
≠≠< =
Project
≠≠> E
project
≠≠F M
,
≠≠M N
CancellationToken
≠≠O `
ct
≠≠a c
)
≠≠c d
{
ÆÆ 
var
ØØ 

staffEmail
ØØ 
=
ØØ 
configuration
ØØ &
[
ØØ& '
$str
ØØ' A
]
ØØA B
is
ØØC E
{
ØØF G
Length
ØØH N
:
ØØN O
>
ØØP Q
$num
ØØR S
}
ØØT U

configured
ØØV `
?
ØØa b

configured
ØØc m
:
ØØn o
configuration
ØØp }
[
ØØ} ~
$strØØ~ â
]ØØâ ä
;ØØä ã
if
∞∞ 

(
∞∞ 
string
∞∞ 
.
∞∞  
IsNullOrWhiteSpace
∞∞ %
(
∞∞% &

staffEmail
∞∞& 0
)
∞∞0 1
)
∞∞1 2
{
∞∞3 4
logger
∞∞5 ;
.
∞∞; <

LogWarning
∞∞< F
(
∞∞F G
$str∞∞G à
,∞∞à â
ticket∞∞ä ê
.∞∞ê ë
Code∞∞ë ï
)∞∞ï ñ
;∞∞ñ ó
return∞∞ò û
;∞∞û ü
}∞∞† °
var
±± 
client
±± 
=
±± 
await
±± 
db
±± 
.
±± 
Clients
±± %
.
±±% &
SingleAsync
±±& 1
(
±±1 2
x
±±2 3
=>
±±4 6
x
±±7 8
.
±±8 9
Id
±±9 ;
==
±±< >
ticket
±±? E
.
±±E F
ClientId
±±F N
,
±±N O
ct
±±P R
)
±±R S
;
±±S T
await
≤≤ 
notifications
≤≤ 
.
≤≤ 
	SendAsync
≤≤ %
(
≤≤% &
client
≤≤& ,
,
≤≤, -
new
≤≤. 1
Notification
≤≤2 >
(
≤≤> ?
NotificationType
≤≤? O
.
≤≤O P
TicketCreated
≤≤P ]
,
≤≤] ^
new
≤≤_ b
(
≤≤b c
)
≤≤c d
{
≤≤e f
[
≤≤g h
$str
≤≤h r
]
≤≤r s
=
≤≤t u
ticket
≤≤v |
.
≤≤| }
Id
≤≤} 
.≤≤ Ä
ToString≤≤Ä à
(≤≤à â
)≤≤â ä
,≤≤ä ã
[≤≤å ç
$str≤≤ç ì
]≤≤ì î
=≤≤ï ñ
ticket≤≤ó ù
.≤≤ù û
Code≤≤û ¢
,≤≤¢ £
[≤≤§ •
$str≤≤• ¨
]≤≤¨ ≠
=≤≤Æ Ø
ticket≤≤∞ ∂
.≤≤∂ ∑
Title≤≤∑ º
,≤≤º Ω
[≤≤æ ø
$str≤≤ø »
]≤≤» …
=≤≤  À
client≤≤Ã “
.≤≤“ ”
CompanyName≤≤” ﬁ
,≤≤ﬁ ﬂ
[≤≤‡ ·
$str≤≤· Í
]≤≤Í Î
=≤≤Ï Ì
project≤≤Ó ı
.≤≤ı ˆ
Name≤≤ˆ ˙
,≤≤˙ ˚
[≤≤¸ ˝
$str≤≤˝ É
]≤≤É Ñ
=≤≤Ö Ü
ticket≤≤á ç
.≤≤ç é
Description≤≤é ô
}≤≤ö õ
,≤≤õ ú
$"≤≤ù ü
$str≤≤ü Æ
{≤≤Æ Ø
ticket≤≤Ø µ
.≤≤µ ∂
Id≤≤∂ ∏
}≤≤∏ π
"≤≤π ∫
,≤≤∫ ª

staffEmail≤≤º ∆
)≤≤∆ «
,≤≤« »
ct≤≤… À
)≤≤À Ã
;≤≤Ã Õ
}
≥≥ 
private
∂∂ 
async
∂∂ 
Task
∂∂  
NotifyManagerAsync
∂∂ )
(
∂∂) *
Ticket
∂∂* 0
ticket
∂∂1 7
,
∂∂7 8
Project
∂∂9 @
project
∂∂A H
,
∂∂H I
CancellationToken
∂∂J [
ct
∂∂\ ^
)
∂∂^ _
{
∑∑ 
var
∏∏ 
creator
∏∏ 
=
∏∏ 
await
∏∏ 
db
∏∏ 
.
∏∏ 
UserAccounts
∏∏ +
.
∏∏+ ,
AsNoTracking
∏∏, 8
(
∏∏8 9
)
∏∏9 :
.
∏∏: ;"
SingleOrDefaultAsync
∏∏; O
(
∏∏O P
x
∏∏P Q
=>
∏∏R T
x
∏∏U V
.
∏∏V W
Id
∏∏W Y
==
∏∏Z \
ticket
∏∏] c
.
∏∏c d
CreatedByUserId
∏∏d s
&&
∏∏t v
x
∏∏w x
.
∏∏x y
ClientId∏∏y Å
==∏∏Ç Ñ
ticket∏∏Ö ã
.∏∏ã å
ClientId∏∏å î
,∏∏î ï
ct∏∏ñ ò
)∏∏ò ô
;∏∏ô ö
if
ππ 

(
ππ 
creator
ππ 
?
ππ 
.
ππ 
	ManagerId
ππ 
is
ππ !
not
ππ" %
Guid
ππ& *
	managerId
ππ+ 4
)
ππ4 5
return
ππ6 <
;
ππ< =
var
∫∫ 
manager
∫∫ 
=
∫∫ 
await
∫∫ 
db
∫∫ 
.
∫∫ 
UserAccounts
∫∫ +
.
∫∫+ ,
AsNoTracking
∫∫, 8
(
∫∫8 9
)
∫∫9 :
.
∫∫: ;"
SingleOrDefaultAsync
∫∫; O
(
∫∫O P
x
∫∫P Q
=>
∫∫R T
x
∫∫U V
.
∫∫V W
Id
∫∫W Y
==
∫∫Z \
	managerId
∫∫] f
&&
∫∫g i
x
∫∫j k
.
∫∫k l
ClientId
∫∫l t
==
∫∫u w
ticket
∫∫x ~
.
∫∫~ 
ClientId∫∫ á
&&∫∫à ä
x∫∫ã å
.∫∫å ç
IsActive∫∫ç ï
,∫∫ï ñ
ct∫∫ó ô
)∫∫ô ö
;∫∫ö õ
if
ªª 

(
ªª 
manager
ªª 
is
ªª 
null
ªª 
||
ªª 
string
ªª %
.
ªª% & 
IsNullOrWhiteSpace
ªª& 8
(
ªª8 9
manager
ªª9 @
.
ªª@ A
Email
ªªA F
)
ªªF G
)
ªªG H
return
ªªI O
;
ªªO P
var
ºº 
client
ºº 
=
ºº 
await
ºº 
db
ºº 
.
ºº 
Clients
ºº %
.
ºº% &
SingleAsync
ºº& 1
(
ºº1 2
x
ºº2 3
=>
ºº4 6
x
ºº7 8
.
ºº8 9
Id
ºº9 ;
==
ºº< >
ticket
ºº? E
.
ººE F
ClientId
ººF N
,
ººN O
ct
ººP R
)
ººR S
;
ººS T
var
ΩΩ 
data
ΩΩ 
=
ΩΩ 
new
ΩΩ 

Dictionary
ΩΩ !
<
ΩΩ! "
string
ΩΩ" (
,
ΩΩ( )
string
ΩΩ* 0
>
ΩΩ0 1
{
ΩΩ2 3
[
ΩΩ4 5
$str
ΩΩ5 ?
]
ΩΩ? @
=
ΩΩA B
ticket
ΩΩC I
.
ΩΩI J
Id
ΩΩJ L
.
ΩΩL M
ToString
ΩΩM U
(
ΩΩU V
)
ΩΩV W
,
ΩΩW X
[
ΩΩY Z
$str
ΩΩZ `
]
ΩΩ` a
=
ΩΩb c
ticket
ΩΩd j
.
ΩΩj k
Code
ΩΩk o
,
ΩΩo p
[
ΩΩq r
$str
ΩΩr y
]
ΩΩy z
=
ΩΩ{ |
ticketΩΩ} É
.ΩΩÉ Ñ
TitleΩΩÑ â
,ΩΩâ ä
[ΩΩã å
$strΩΩå ï
]ΩΩï ñ
=ΩΩó ò
projectΩΩô †
.ΩΩ† °
NameΩΩ° •
,ΩΩ• ¶
[ΩΩß ®
$strΩΩ® ±
]ΩΩ± ≤
=ΩΩ≥ ¥
creatorΩΩµ º
.ΩΩº Ω
NameΩΩΩ ¡
}ΩΩ¬ √
;ΩΩ√ ƒ
if
ææ 

(
ææ 
!
ææ 
string
ææ 
.
ææ  
IsNullOrWhiteSpace
ææ &
(
ææ& '
creator
ææ' .
.
ææ. /
Area
ææ/ 3
)
ææ3 4
)
ææ4 5
data
ææ6 :
[
ææ: ;
$str
ææ; A
]
ææA B
=
ææC D
creator
ææE L
.
ææL M
Area
ææM Q
;
ææQ R
await
øø 
notifications
øø 
.
øø 
	SendAsync
øø %
(
øø% &
client
øø& ,
,
øø, -
new
øø. 1
Notification
øø2 >
(
øø> ?
NotificationType
øø? O
.
øøO P%
TicketCreatedForManager
øøP g
,
øøg h
data
øøi m
,
øøm n
$"
øøo q
$strøøq Ä
{øøÄ Å
ticketøøÅ á
.øøá à
Idøøà ä
}øøä ã
"øøã å
,øøå ç
managerøøé ï
.øøï ñ
Emailøøñ õ
)øøõ ú
,øøú ù
ctøøû †
)øø† °
;øø° ¢
}
¿¿ 
}¡¡ ‹Õ
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
{ 	
if 
( 
	requested 
is 
not  
Guid! %
value& +
)+ ,
return- 3

BadRequest4 >
(> ?
new? B
{C D
messageE L
=M N
$strO y
}z {
){ |
;| }
clientId 
= 
value 
; 
return 
null 
; 
} 	
return 
Guid 
. 
TryParse 
( 
User !
.! "
FindFirstValue" 0
(0 1
$str1 <
)< =
,= >
out? B
clientIdC K
)K L
?M N
nullO S
:T U
ForbidV \
(\ ]
)] ^
;^ _
} 
[   
	Authorize   
,   
HttpGet   
(   
$str   *
)  * +
]  + ,
public!! 

async!! 
Task!! 
<!! 
IActionResult!! #
>!!# $
Catalog!!% ,
(!!, -
CancellationToken!!- >
ct!!? A
)!!A B
{"" 
var$$ 
client$$ 
=$$ 
Guid$$ 
.$$ 
TryParse$$ "
($$" #
User$$# '
.$$' (
FindFirstValue$$( 6
($$6 7
$str$$7 B
)$$B C
,$$C D
out$$E H
var$$I L
clientId$$M U
)$$U V
?$$W X
await$$Y ^
db$$_ a
.$$a b
Clients$$b i
.$$i j 
SingleOrDefaultAsync$$j ~
($$~ 
x	$$ Ä
=>
$$Å É
x
$$Ñ Ö
.
$$Ö Ü
Id
$$Ü à
==
$$â ã
clientId
$$å î
,
$$î ï
ct
$$ñ ò
)
$$ò ô
:
$$ö õ
null
$$ú †
;
$$† °
var%% 
igvRate%% 
=%% 
await%% 
db%% 
.%% 
IgvRateAsync%% +
(%%+ ,
ct%%, .
)%%. /
;%%/ 0
var&& 
products&& 
=&& 
await&& 
db&& 
.&&  
Products&&  (
.&&( )
Where&&) .
(&&. /
x&&/ 0
=>&&1 3
x&&4 5
.&&5 6
IsActive&&6 >
)&&> ?
.&&? @
OrderBy&&@ G
(&&G H
x&&H I
=>&&J L
x&&M N
.&&N O
Name&&O S
)&&S T
.&&T U
ToListAsync&&U `
(&&` a
ct&&a c
)&&c d
;&&d e
return'' 
Ok'' 
('' 
products'' 
.'' 
Select'' !
(''! "
x''" #
=>''$ &
new''' *
{''+ ,
id''- /
=''0 1
x''2 3
.''3 4
Id''4 6
,''6 7
type''8 <
=''= >
x''? @
.''@ A
Type''A E
,''E F
name''G K
=''L M
x''N O
.''O P
Name''P T
,''T U
billingCycle''V b
=''c d
x''e f
.''f g
BillingCycle''g s
,''s t
	basePrice''u ~
=	'' Ä
x
''Å Ç
.
''Ç É
	BasePrice
''É å
,
''å ç
currency
''é ñ
=
''ó ò
x
''ô ö
.
''ö õ
Currency
''õ £
,
''£ §
description
''• ∞
=
''± ≤
x
''≥ ¥
.
''¥ µ
Description
''µ ¿
,
''¿ ¡
category
''¬  
=
''À Ã
x
''Õ Œ
.
''Œ œ
Category
''œ ◊
,
''◊ ÿ
tags
''Ÿ ›
=
''ﬁ ﬂ
x
''‡ ·
.
''· ‚
Tags
''‚ Ê
,
''Ê Á
allowsTickets
''Ë ı
=
''ˆ ˜
x
''¯ ˘
.
''˘ ˙
AllowsTickets
''˙ á
,
''á à
isActive
''â ë
=
''í ì
x
''î ï
.
''ï ñ
IsActive
''ñ û
,
''û ü
igvRate
''† ß
=
''® ©
client
''™ ∞
is
''± ≥
null
''¥ ∏
?
''π ∫
$num
''ª Ω
:
''æ ø"
ClientProductPricing
''¿ ‘
.
''‘ ’

IgvRateFor
''’ ﬂ
(
''ﬂ ‡
client
''‡ Ê
,
''Ê Á
x
''Ë È
,
''È Í
igvRate
''Î Ú
)
''Ú Û
}
''Ù ı
)
''ı ˆ
)
''ˆ ˜
;
''˜ ¯
}(( 
[** 
	Authorize** 
(** 
Roles** 
=** 
$str** &
)**& '
,**' (
HttpPost**) 1
(**1 2
$str**2 A
)**A B
]**B C
public++ 

async++ 
Task++ 
<++ 
IActionResult++ #
>++# $
	Subscribe++% .
(++. /
SubscribeRequest++/ ?
request++@ G
,++G H
CancellationToken++I Z
ct++[ ]
)++] ^
{,, 
var-- 
scope-- 
=-- 
ClientScope-- 
(--  
null--  $
,--$ %
out--& )
var--* -
clientId--. 6
)--6 7
;--7 8
if--9 ;
(--< =
scope--= B
is--C E
not--F I
null--J N
)--N O
return--P V
scope--W \
;--\ ]
var.. 
product.. 
=.. 
await.. 
db.. 
... 
Products.. '
...' ( 
SingleOrDefaultAsync..( <
(..< =
x..= >
=>..? A
x..B C
...C D
Id..D F
==..G I
request..J Q
...Q R
	ProductId..R [
&&..\ ^
x.._ `
...` a
IsActive..a i
,..i j
ct..k m
)..m n
;..n o
if// 

(// 
product// 
is// 
null// 
)// 
return// #
NotFound//$ ,
(//, -
)//- .
;//. /
var00 
	projectId00 
=00 
request00 
.00  
	ProjectId00  )
;00) *
if11 

(11 
	projectId11 
is11 
null11 
)11 
	projectId11 (
=11) *
(11+ ,
await11, 1
NewProjectAsync112 A
(11A B
clientId11B J
,11J K
product11L S
.11S T
Name11T X
,11X Y
ct11Z \
)11\ ]
)11] ^
.11^ _
Id11_ a
;11a b
else22 
if22 
(22 
!22 
await22 
db22 
.22 
Projects22 #
.22# $
AnyAsync22$ ,
(22, -
x22- .
=>22/ 1
x222 3
.223 4
Id224 6
==227 9
	projectId22: C
&&22D F
x22G H
.22H I
ClientId22I Q
==22R T
clientId22U ]
,22] ^
ct22_ a
)22a b
)22b c
return22d j
NotFound22k s
(22s t
)22t u
;22u v
if33 

(33 
request33 
.33 
BillingCycle33  
!=33! #
product33$ +
.33+ ,
BillingCycle33, 8
)338 9
return33: @

BadRequest33A K
(33K L
new33L O
{33P Q
message33R Y
=33Z [
$str	33\ ì
}
33î ï
)
33ï ñ
;
33ñ ó
if44 

(44 
await44 #
PaymentMethodErrorAsync44 )
(44) *
request44* 1
.441 2
PaymentMethod442 ?
,44? @
ct44A C
)44C D
is44E G
string44H N
methodError44O Z
)44Z [
return44\ b

BadRequest44c m
(44m n
new44n q
{44r s
message44t {
=44| }
methodError	44~ â
}
44ä ã
)
44ã å
;
44å ç
var55 
transfer55 
=55 
request55 
.55 
PaymentMethod55 ,
==55- /
PaymentMethods550 >
.55> ?
Transferencia55? L
;55L M
var66 
item66 
=66 
new66 
ClientProduct66 $
{66% &
ClientId66' /
=660 1
clientId662 :
,66: ;
	ProjectId66< E
=66F G
	projectId66H Q
.66Q R
Value66R W
,66W X
	ProductId66Y b
=66c d
product66e l
.66l m
Id66m o
,66o p
Product66q x
=66y z
product	66{ Ç
,
66Ç É
BillingCycle
66Ñ ê
=
66ë í
request
66ì ö
.
66ö õ
BillingCycle
66õ ß
,
66ß ®
Status
66© Ø
=
66∞ ±!
ClientProductStatus
66≤ ≈
.
66≈ ∆
	Pendiente
66∆ œ
,
66œ –
Price
66— ÷
=
66◊ ÿ
product
66Ÿ ‡
.
66‡ ·
	BasePrice
66· Í
,
66Í Î
IsManualBilling
66Ï ˚
=
66¸ ˝
transfer
66˛ Ü
}
66á à
;
66à â
if77 

(77 
item77 
.77 
ValidateYears77 
(77 
request77 &
.77& '
Years77' ,
)77, -
is77. 0
string771 7

yearsError778 B
)77B C
return77D J

BadRequest77K U
(77U V
new77V Y
{77Z [
message77\ c
=77d e

yearsError77f p
}77q r
)77r s
;77s t
db88 

.88
 
ClientProducts88 
.88 
Add88 
(88 
item88 "
)88" #
;88# $
var99 
igvRate99 
=99 
await99 
db99 
.99 
IgvRateForAsync99 .
(99. /
clientId99/ 7
,997 8
product999 @
,99@ A
ct99B D
)99D E
;99E F
if;; 

(;; 
transfer;; 
);; 
{<< 	
await== 
db== 
.== 
SaveChangesAsync== %
(==% &
ct==& (
)==( )
;==) *
await>> &
NotifyTransferRequestAsync>> ,
(>>, -
item>>- 1
,>>1 2
product>>3 :
,>>: ;
igvRate>>< C
,>>C D
request>>E L
.>>L M
Years>>M R
,>>R S
ct>>T V
)>>V W
;>>W X
return?? 
Ok?? 
(?? 
new?? 
{?? 
clientProductId?? +
=??, -
item??. 2
.??2 3
Id??3 5
,??5 6
approvalUrl??7 B
=??C D
(??E F
string??F L
???L M
)??M N
null??N R
,??R S
bankTransfer??T `
=??a b
await??c h
	transfers??i r
.??r s
	InfoAsync??s |
(??| }
item	??} Å
,
??Å Ç
igvRate
??É ä
,
??ä ã
request
??å ì
.
??ì î
Years
??î ô
,
??ô ö
ct
??õ ù
)
??ù û
}
??ü †
)
??† °
;
??° ¢
}@@ 	
tryAA 
{AA 
varAA 
checkoutAA 
=AA 
awaitAA "
checkoutServiceAA# 2
.AA2 3

StartAsyncAA3 =
(AA= >
itemAA> B
,AAB C
productAAD K
,AAK L
RequestAAM T
,AAT U
ctAAV X
,AAX Y
igvRateAAZ a
,AAa b
requestAAc j
.AAj k
YearsAAk p
)AAp q
;AAq r
awaitAAs x
dbAAy {
.AA{ |
SaveChangesAsync	AA| å
(
AAå ç
ct
AAç è
)
AAè ê
;
AAê ë
return
AAí ò
Ok
AAô õ
(
AAõ ú
new
AAú ü
{
AA† °
clientProductId
AA¢ ±
=
AA≤ ≥
item
AA¥ ∏
.
AA∏ π
Id
AAπ ª
,
AAª º
approvalUrl
AAΩ »
=
AA…  
checkout
AAÀ ”
.
AA” ‘
ApprovalUrl
AA‘ ﬂ
}
AA‡ ·
)
AA· ‚
;
AA‚ „
}
AA‰ Â
catch
AAÊ Î
(
AAÏ Ì'
InvalidOperationException
AAÌ Ü
ex
AAá â
)
AAâ ä
{
AAã å
return
AAç ì

BadRequest
AAî û
(
AAû ü
new
AAü ¢
{
AA£ §
message
AA• ¨
=
AA≠ Æ
ex
AAØ ±
.
AA± ≤
Message
AA≤ π
}
AA∫ ª
)
AAª º
;
AAº Ω
}
AAæ ø
}BB 
privateEE 
asyncEE 
TaskEE 
<EE 
stringEE 
?EE 
>EE #
PaymentMethodErrorAsyncEE  7
(EE7 8
stringEE8 >
methodEE? E
,EEE F
CancellationTokenEEG X
ctEEY [
)EE[ \
{FF 
ifGG 

(GG 
methodGG 
isGG 
notGG 
(GG 
PaymentMethodsGG )
.GG) *
PayPalGG* 0
orGG1 3
PaymentMethodsGG4 B
.GGB C
TransferenciaGGC P
)GGP Q
)GGQ R
returnGGS Y
$strGGZ t
;GGt u
varHH 
settingsHH 
=HH 
awaitHH 
	transfersHH &
.HH& '
SettingsAsyncHH' 4
(HH4 5
ctHH5 7
)HH7 8
;HH8 9
ifII 

(II 
methodII 
==II 
PaymentMethodsII $
.II$ %
TransferenciaII% 2
)II2 3
returnII4 :
settingsII; C
.IIC D
BankTransferEnabledIID W
?IIX Y
nullIIZ ^
:II_ `
$str	IIa ö
;
IIö õ
returnJJ 
settingsJJ 
.JJ 
PayPalEnabledJJ %
?JJ& '
nullJJ( ,
:JJ- .
$strJJ/ a
;JJa b
}KK 
privateQQ 
asyncQQ 
TaskQQ 
<QQ 
ProjectQQ 
>QQ 
NewProjectAsyncQQ  /
(QQ/ 0
GuidQQ0 4
clientIdQQ5 =
,QQ= >
stringQQ? E
productNameQQF Q
,QQQ R
CancellationTokenQQS d
ctQQe g
)QQg h
{RR 
varSS 
companySS 
=SS 
awaitSS 
dbSS 
.SS 
ClientsSS &
.SS& '
WhereSS' ,
(SS, -
xSS- .
=>SS/ 1
xSS2 3
.SS3 4
IdSS4 6
==SS7 9
clientIdSS: B
)SSB C
.SSC D
SelectSSD J
(SSJ K
xSSK L
=>SSM O
xSSP Q
.SSQ R
CompanyNameSSR ]
)SS] ^
.SS^ _
SingleAsyncSS_ j
(SSj k
ctSSk m
)SSm n
;SSn o
varTT 
baseSlugTT 
=TT 
AdminControllerTT &
.TT& '
SlugifyTT' .
(TT. /
$"TT/ 1
{TT1 2
companyTT2 9
}TT9 :
$strTT: ;
{TT; <
productNameTT< G
}TTG H
"TTH I
)TTI J
;TTJ K
ifUU 

(UU 
baseSlugUU 
.UU 
LengthUU 
==UU 
$numUU  
)UU  !
baseSlugUU" *
=UU+ ,
$strUU- 7
;UU7 8
varVV 
slugVV 
=VV 
baseSlugVV 
;VV 
varWW 
nWW 
=WW 
$numWW 
;WW 
whileXX 
(XX 
awaitXX 
dbXX 
.XX 
ProjectsXX  
.XX  !
AnyAsyncXX! )
(XX) *
xXX* +
=>XX, .
xXX/ 0
.XX0 1
SlugXX1 5
==XX6 8
slugXX9 =
,XX= >
ctXX? A
)XXA B
)XXB C
slugXXD H
=XXI J
$"XXK M
{XXM N
baseSlugXXN V
}XXV W
$strXXW X
{XXX Y
nXXY Z
++XXZ \
}XX\ ]
"XX] ^
;XX^ _
varYY 
projectYY 
=YY 
newYY 
ProjectYY !
{YY" #
ClientIdYY$ ,
=YY- .
clientIdYY/ 7
,YY7 8
NameYY9 =
=YY> ?
productNameYY@ K
,YYK L
SlugYYM Q
=YYR S
slugYYT X
}YYY Z
;YYZ [
dbZZ 

.ZZ
 
ProjectsZZ 
.ZZ 
AddZZ 
(ZZ 
projectZZ 
)ZZ  
;ZZ  !
return[[ 
project[[ 
;[[ 
}\\ 
[__ 
	Authorize__ 
,__ 
HttpGet__ 
(__ 
$str__ A
)__A B
]__B C
public`` 

async`` 
Task`` 
<`` 
IActionResult`` #
>``# $
BankTransfer``% 1
(``1 2
Guid``2 6
id``7 9
,``9 :
Guid``; ?
?``? @
clientId``A I
,``I J
CancellationToken``K \
ct``] _
,``_ `
int``a d
years``e j
=``k l
$num``m n
)``n o
{aa 
varbb 
scopebb 
=bb 
ClientScopebb 
(bb  
clientIdbb  (
,bb( )
outbb* -
varbb. 1
ownerbb2 7
)bb7 8
;bb8 9
ifbb: <
(bb= >
scopebb> C
isbbD F
notbbG J
nullbbK O
)bbO P
returnbbQ W
scopebbX ]
;bb] ^
varcc 
itemcc 
=cc 
awaitcc 
dbcc 
.cc 
ClientProductscc *
.cc* +
Includecc+ 2
(cc2 3
xcc3 4
=>cc5 7
xcc8 9
.cc9 :
Productcc: A
)ccA B
.ccB C 
SingleOrDefaultAsyncccC W
(ccW X
xccX Y
=>ccZ \
xcc] ^
.cc^ _
Idcc_ a
==ccb d
idcce g
&&cch j
xcck l
.ccl m
ClientIdccm u
==ccv x
ownerccy ~
,cc~ 
ct
ccÄ Ç
)
ccÇ É
;
ccÉ Ñ
ifdd 

(dd 
itemdd 
?dd 
.dd 
Productdd 
isdd 
nulldd !
)dd! "
returndd# )
NotFounddd* 2
(dd2 3
)dd3 4
;dd4 5
ifee 

(ee 
itemee 
.ee 
ValidateYearsee 
(ee 
yearsee $
)ee$ %
isee& (
stringee) /

yearsErroree0 :
)ee: ;
returnee< B

BadRequesteeC M
(eeM N
neweeN Q
{eeR S
messageeeT [
=ee\ ]

yearsErroree^ h
}eei j
)eej k
;eek l
returnff 
Okff 
(ff 
awaitff 
	transfersff !
.ff! "
	InfoAsyncff" +
(ff+ ,
itemff, 0
,ff0 1
awaitff2 7
dbff8 :
.ff: ;
IgvRateForAsyncff; J
(ffJ K
ownerffK P
,ffP Q
itemffR V
.ffV W
ProductffW ^
,ff^ _
ctff` b
)ffb c
,ffc d
yearsffe j
,ffj k
ctffl n
)ffn o
)ffo p
;ffp q
}gg 
privatemm 
asyncmm 
Taskmm &
NotifyTransferRequestAsyncmm 1
(mm1 2
ClientProductmm2 ?
itemmm@ D
,mmD E
ProductmmF M
productmmN U
,mmU V
decimalmmW ^
igvRatemm_ f
,mmf g
intmmh k
yearsmml q
,mmq r
CancellationToken	mms Ñ
ct
mmÖ á
)
mmá à
{nn 
varoo 

staffEmailoo 
=oo 
configurationoo &
[oo& '
$stroo' A
]ooA B
isooC E
{ooF G
LengthooH N
:ooN O
>ooP Q
$numooR S
}ooT U

configuredooV `
?ooa b

configuredooc m
:oon o
configurationoop }
[oo} ~
$str	oo~ â
]
ooâ ä
;
ooä ã
ifpp 

(pp 
stringpp 
.pp 
IsNullOrWhiteSpacepp %
(pp% &

staffEmailpp& 0
)pp0 1
)pp1 2
{pp3 4
loggerpp5 ;
.pp; <

LogWarningpp< F
(ppF G
$str	ppG ù
,
ppù û
item
ppü £
.
pp£ §
Id
pp§ ¶
)
pp¶ ß
;
ppß ®
return
pp© Ø
;
ppØ ∞
}
pp± ≤
varqq 
clientqq 
=qq 
awaitqq 
dbqq 
.qq 
Clientsqq %
.qq% &
SingleAsyncqq& 1
(qq1 2
xqq2 3
=>qq4 6
xqq7 8
.qq8 9
Idqq9 ;
==qq< >
itemqq? C
.qqC D
ClientIdqqD L
,qqL M
ctqqN P
)qqP Q
;qqQ R
varrr 
projectrr 
=rr 
awaitrr 
dbrr 
.rr 
Projectsrr '
.rr' (
Whererr( -
(rr- .
xrr. /
=>rr0 2
xrr3 4
.rr4 5
Idrr5 7
==rr8 :
itemrr; ?
.rr? @
	ProjectIdrr@ I
)rrI J
.rrJ K
SelectrrK Q
(rrQ R
xrrR S
=>rrT V
xrrW X
.rrX Y
NamerrY ]
)rr] ^
.rr^ _
SingleAsyncrr_ j
(rrj k
ctrrk m
)rrm n
;rrn o
varss 
datass 
=ss 
newss 

Dictionaryss !
<ss! "
stringss" (
,ss( )
stringss* 0
>ss0 1
{ss2 3
[ss4 5
$strss5 ?
]ss? @
=ssA B
clientssC I
.ssI J
IdssJ L
.ssL M
ToStringssM U
(ssU V
)ssV W
,ssW X
[ssY Z
$strssZ c
]ssc d
=sse f
clientssg m
.ssm n
CompanyNamessn y
,ssy z
[ss{ |
$str	ss| Ö
]
ssÖ Ü
=
ssá à
years
ssâ é
>
ssè ê
$num
ssë í
?
ssì î
$"
ssï ó
{
ssó ò
product
ssò ü
.
ssü †
Name
ss† §
}
ss§ •
$str
ss• ß
{
ssß ®
years
ss® ≠
}
ss≠ Æ
$str
ssÆ ¥
"
ss¥ µ
:
ss∂ ∑
product
ss∏ ø
.
ssø ¿
Name
ss¿ ƒ
,
ssƒ ≈
[
ss∆ «
$str
ss« –
]
ss– —
=
ss“ ”
project
ss‘ €
,
ss€ ‹
[
ss› ﬁ
$str
ssﬁ Ë
]
ssË È
=
ssÍ Î
product
ssÏ Û
.
ssÛ Ù
Currency
ssÙ ¸
}
ss˝ ˛
;
ss˛ ˇ
iftt 

(tt 
itemtt 
.tt 
ChargeTotaltt 
(tt 
igvRatett $
,tt$ %
yearstt& +
)tt+ ,
istt- /
decimaltt0 7
amounttt8 >
)tt> ?
datatt@ D
[ttD E
$strttE M
]ttM N
=ttO P
amountttQ W
.ttW X
ToStringttX `
(tt` a
CultureInfotta l
.ttl m
InvariantCulturettm }
)tt} ~
;tt~ 
awaituu 
notificationsuu 
.uu 
	SendAsyncuu %
(uu% &
clientuu& ,
,uu, -
newuu. 1
Notificationuu2 >
(uu> ?
NotificationTypeuu? O
.uuO P
TransferRequesteduuP a
,uua b
datauuc g
,uug h
$"uui k
$struuk |
{uu| }
item	uu} Å
.
uuÅ Ç
Id
uuÇ Ñ
}
uuÑ Ö
"
uuÖ Ü
,
uuÜ á

staffEmail
uuà í
)
uuí ì
,
uuì î
ct
uuï ó
)
uuó ò
;
uuò ô
}vv 
[xx 
	Authorizexx 
(xx 
Rolesxx 
=xx 
$strxx &
)xx& '
,xx' (
HttpPostxx) 1
(xx1 2
$strxx2 S
)xxS T
]xxT U
publicyy 

asyncyy 
Taskyy 
<yy 
IActionResultyy #
>yy# $
Renewyy% *
(yy* +
Guidyy+ /
idyy0 2
,yy2 3
Guidyy4 8
?yy8 9
clientIdyy: B
,yyB C
CancellationTokenyyD U
ctyyV X
,yyX Y
intyyZ ]
yearsyy^ c
=yyd e
$numyyf g
)yyg h
{zz 
var{{ 
scope{{ 
={{ 
ClientScope{{ 
({{  
clientId{{  (
,{{( )
out{{* -
var{{. 1
owner{{2 7
){{7 8
;{{8 9
if{{: <
({{= >
scope{{> C
is{{D F
not{{G J
null{{K O
){{O P
return{{Q W
scope{{X ]
;{{] ^
var|| 
item|| 
=|| 
await|| 
db|| 
.|| 
ClientProducts|| *
.||* +
Include||+ 2
(||2 3
x||3 4
=>||5 7
x||8 9
.||9 :
Product||: A
)||A B
.||B C 
SingleOrDefaultAsync||C W
(||W X
x||X Y
=>||Z \
x||] ^
.||^ _
Id||_ a
==||b d
id||e g
&&||h j
x||k l
.||l m
ClientId||m u
==||v x
owner||y ~
,||~ 
ct
||Ä Ç
)
||Ç É
;
||É Ñ
if}} 

(}} 
item}} 
?}} 
.}} 
Product}} 
is}} 
null}} !
)}}! "
return}}# )
NotFound}}* 2
(}}2 3
)}}3 4
;}}4 5
var 
	renewable 
= 
item 
. 
BillingCycle )
==* ,
BillingCycle- 9
.9 :
Anual: ?
&&@ B
(C D
itemD H
.H I
StatusI O
isP R
ClientProductStatusS f
.f g
	PorVencerg p
orq s 
ClientProductStatus	t á
.
á à
Vencido
à è
||
ê í
item
ì ó
.
ó ò
RenewsAt
ò †
<=
° £
DateTime
§ ¨
.
¨ ≠
UtcNow
≠ ≥
.
≥ ¥
AddDays
¥ ª
(
ª º
RenewalWindowDays
º Õ
)
Õ Œ
)
Œ œ
;
œ –
if
ÄÄ 

(
ÄÄ 
item
ÄÄ 
.
ÄÄ 
IsManualBilling
ÄÄ  
||
ÄÄ! #
!
ÄÄ$ %
(
ÄÄ% &
	renewable
ÄÄ& /
||
ÄÄ0 2
item
ÄÄ3 7
.
ÄÄ7 8
Status
ÄÄ8 >
==
ÄÄ? A!
ClientProductStatus
ÄÄB U
.
ÄÄU V
	Pendiente
ÄÄV _
)
ÄÄ_ `
)
ÄÄ` a
return
ÄÄb h

BadRequest
ÄÄi s
(
ÄÄs t
new
ÄÄt w
{
ÄÄx y
messageÄÄz Å
=ÄÄÇ É
$strÄÄÑ ±
}ÄÄ≤ ≥
)ÄÄ≥ ¥
;ÄÄ¥ µ
if
ÅÅ 

(
ÅÅ 
!
ÅÅ 
(
ÅÅ 
await
ÅÅ 
	transfers
ÅÅ 
.
ÅÅ 
SettingsAsync
ÅÅ +
(
ÅÅ+ ,
ct
ÅÅ, .
)
ÅÅ. /
)
ÅÅ/ 0
.
ÅÅ0 1
PayPalEnabled
ÅÅ1 >
)
ÅÅ> ?
return
ÅÅ@ F

BadRequest
ÅÅG Q
(
ÅÅQ R
new
ÅÅR U
{
ÅÅV W
message
ÅÅX _
=
ÅÅ` a
$strÅÅb î
}ÅÅï ñ
)ÅÅñ ó
;ÅÅó ò
try
ÇÇ 
{
ÇÇ 
var
ÇÇ 
checkout
ÇÇ 
=
ÇÇ 
await
ÇÇ "
checkoutService
ÇÇ# 2
.
ÇÇ2 3

StartAsync
ÇÇ3 =
(
ÇÇ= >
item
ÇÇ> B
,
ÇÇB C
item
ÇÇD H
.
ÇÇH I
Product
ÇÇI P
,
ÇÇP Q
Request
ÇÇR Y
,
ÇÇY Z
ct
ÇÇ[ ]
,
ÇÇ] ^
await
ÇÇ_ d
db
ÇÇe g
.
ÇÇg h
IgvRateForAsync
ÇÇh w
(
ÇÇw x
owner
ÇÇx }
,
ÇÇ} ~
itemÇÇ É
.ÇÇÉ Ñ
ProductÇÇÑ ã
,ÇÇã å
ctÇÇç è
)ÇÇè ê
,ÇÇê ë
yearsÇÇí ó
)ÇÇó ò
;ÇÇò ô
awaitÇÇö ü
dbÇÇ† ¢
.ÇÇ¢ £ 
SaveChangesAsyncÇÇ£ ≥
(ÇÇ≥ ¥
ctÇÇ¥ ∂
)ÇÇ∂ ∑
;ÇÇ∑ ∏
returnÇÇπ ø
OkÇÇ¿ ¬
(ÇÇ¬ √
newÇÇ√ ∆
{ÇÇ« »
approvalUrlÇÇ… ‘
=ÇÇ’ ÷
checkoutÇÇ◊ ﬂ
.ÇÇﬂ ‡
ApprovalUrlÇÇ‡ Î
}ÇÇÏ Ì
)ÇÇÌ Ó
;ÇÇÓ Ô
}ÇÇ Ò
catchÇÇÚ ˜
(ÇÇ¯ ˘)
InvalidOperationExceptionÇÇ˘ í
exÇÇì ï
)ÇÇï ñ
{ÇÇó ò
returnÇÇô ü

BadRequestÇÇ† ™
(ÇÇ™ ´
newÇÇ´ Æ
{ÇÇØ ∞
messageÇÇ± ∏
=ÇÇπ ∫
exÇÇª Ω
.ÇÇΩ æ
MessageÇÇæ ≈
}ÇÇ∆ «
)ÇÇ« »
;ÇÇ» …
}ÇÇ  À
}
ÉÉ 
[
ÖÖ 
	Authorize
ÖÖ 
(
ÖÖ 
Roles
ÖÖ 
=
ÖÖ 
$str
ÖÖ &
)
ÖÖ& '
,
ÖÖ' (
HttpPost
ÖÖ) 1
(
ÖÖ1 2
$str
ÖÖ2 T
)
ÖÖT U
]
ÖÖU V
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
ÜÜ# $
Cancel
ÜÜ% +
(
ÜÜ+ ,
Guid
ÜÜ, 0
id
ÜÜ1 3
,
ÜÜ3 4
Guid
ÜÜ5 9
?
ÜÜ9 :
clientId
ÜÜ; C
,
ÜÜC D
CancellationToken
ÜÜE V
ct
ÜÜW Y
)
ÜÜY Z
{
áá 
var
àà 
scope
àà 
=
àà 
ClientScope
àà 
(
àà  
clientId
àà  (
,
àà( )
out
àà* -
var
àà. 1
owner
àà2 7
)
àà7 8
;
àà8 9
if
àà: <
(
àà= >
scope
àà> C
is
ààD F
not
ààG J
null
ààK O
)
ààO P
return
ààQ W
scope
ààX ]
;
àà] ^
var
ââ 
item
ââ 
=
ââ 
await
ââ 
db
ââ 
.
ââ 
ClientProducts
ââ *
.
ââ* +"
SingleOrDefaultAsync
ââ+ ?
(
ââ? @
x
ââ@ A
=>
ââB D
x
ââE F
.
ââF G
Id
ââG I
==
ââJ L
id
ââM O
&&
ââP R
x
ââS T
.
ââT U
ClientId
ââU ]
==
ââ^ `
owner
ââa f
,
ââf g
ct
ââh j
)
ââj k
;
ââk l
if
ää 

(
ää 
item
ää 
is
ää 
null
ää 
)
ää 
return
ää  
NotFound
ää! )
(
ää) *
)
ää* +
;
ää+ ,
if
ãã 

(
ãã 
item
ãã 
.
ãã 
IsManualBilling
ãã  
||
ãã! #
item
ãã$ (
.
ãã( )
Status
ãã) /
!=
ãã0 2!
ClientProductStatus
ãã3 F
.
ããF G
Activo
ããG M
||
ããN P
!
ããQ R
item
ããR V
.
ããV W
BillingCycle
ããW c
.
ããc d
IsSubscription
ããd r
(
ããr s
)
ããs t
||
ããu w
string
ããx ~
.
ãã~ !
IsNullOrWhiteSpaceãã ë
(ããë í
itemããí ñ
.ããñ ó$
PayPalSubscriptionIdããó ´
)ãã´ ¨
)ãã¨ ≠
returnããÆ ¥

BadRequestããµ ø
(ããø ¿
newãã¿ √
{ããƒ ≈
messageãã∆ Õ
=ããŒ œ
$strãã– Ñ
}ããÖ Ü
)ããÜ á
;ããá à
await
åå 
payPal
åå 
.
åå %
CancelSubscriptionAsync
åå ,
(
åå, -
item
åå- 1
.
åå1 2"
PayPalSubscriptionId
åå2 F
,
ååF G
$str
ååH y
,
ååy z
ct
åå{ }
)
åå} ~
;
åå~ 
itemååÄ Ñ
.ååÑ Ö
StatusååÖ ã
=ååå ç#
ClientProductStatusååé °
.åå° ¢
	Canceladoåå¢ ´
;åå´ ¨
awaitåå≠ ≤
dbåå≥ µ
.ååµ ∂ 
SaveChangesAsyncåå∂ ∆
(åå∆ «
ctåå« …
)åå…  
;åå  À
returnååÃ “
Okåå” ’
(åå’ ÷
)åå÷ ◊
;åå◊ ÿ
}
çç 
[
êê 
	Authorize
êê 
(
êê 
Roles
êê 
=
êê 
$str
êê &
)
êê& '
,
êê' (
HttpPost
êê) 1
(
êê1 2
$str
êê2 U
)
êêU V
]
êêV W
public
ëë 

async
ëë 
Task
ëë 
<
ëë 
IActionResult
ëë #
>
ëë# $
Capture
ëë% ,
(
ëë, -
Guid
ëë- 1
id
ëë2 4
,
ëë4 5
Guid
ëë6 :
?
ëë: ;
clientId
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
ìì 
scope
ìì 
=
ìì 
ClientScope
ìì 
(
ìì  
clientId
ìì  (
,
ìì( )
out
ìì* -
var
ìì. 1
owner
ìì2 7
)
ìì7 8
;
ìì8 9
if
ìì: <
(
ìì= >
scope
ìì> C
is
ììD F
not
ììG J
null
ììK O
)
ììO P
return
ììQ W
scope
ììX ]
;
ìì] ^
var
îî 
item
îî 
=
îî 
await
îî 
db
îî 
.
îî 
ClientProducts
îî *
.
îî* +
Include
îî+ 2
(
îî2 3
x
îî3 4
=>
îî5 7
x
îî8 9
.
îî9 :
Product
îî: A
)
îîA B
.
îîB C"
SingleOrDefaultAsync
îîC W
(
îîW X
x
îîX Y
=>
îîZ \
x
îî] ^
.
îî^ _
Id
îî_ a
==
îîb d
id
îîe g
&&
îîh j
x
îîk l
.
îîl m
ClientId
îîm u
==
îîv x
owner
îîy ~
,
îî~ 
ctîîÄ Ç
)îîÇ É
;îîÉ Ñ
if
ïï 

(
ïï 
item
ïï 
is
ïï 
null
ïï 
)
ïï 
return
ïï  
NotFound
ïï! )
(
ïï) *
)
ïï* +
;
ïï+ ,
try
ññ 
{
ññ 
await
ññ 
payments
ññ 
.
ññ 
ConfirmAsync
ññ )
(
ññ) *
item
ññ* .
,
ññ. /
ct
ññ0 2
)
ññ2 3
;
ññ3 4
}
ññ5 6
catch
óó 
(
óó "
HttpRequestException
óó #
ex
óó$ &
)
óó& '
{
óó( )
logger
óó* 0
.
óó0 1

LogWarning
óó1 ;
(
óó; <
ex
óó< >
,
óó> ?
$stróó@ Ö
,óóÖ Ü
idóóá â
)óóâ ä
;óóä ã
}óóå ç
return
òò 
Ok
òò 
(
òò 
new
òò 
{
òò 
status
òò 
=
òò  
item
òò! %
.
òò% &
Status
òò& ,
.
òò, -
ToString
òò- 5
(
òò5 6
)
òò6 7
}
òò8 9
)
òò9 :
;
òò: ;
}
ôô 
[
õõ 
	Authorize
õõ 
(
õõ 
Roles
õõ 
=
õõ 
$str
õõ &
)
õõ& '
,
õõ' (
HttpGet
õõ) 0
(
õõ0 1
$str
õõ1 L
)
õõL M
]
õõM N
public
úú 

async
úú 
Task
úú 
<
úú 
IActionResult
úú #
>
úú# $
ClientProduct
úú% 2
(
úú2 3
Guid
úú3 7
id
úú8 :
,
úú: ;
Guid
úú< @
?
úú@ A
clientId
úúB J
,
úúJ K
CancellationToken
úúL ]
ct
úú^ `
)
úú` a
{
ùù 
var
ûû 
scope
ûû 
=
ûû 
ClientScope
ûû 
(
ûû  
clientId
ûû  (
,
ûû( )
out
ûû* -
var
ûû. 1
owner
ûû2 7
)
ûû7 8
;
ûû8 9
if
ûû: <
(
ûû= >
scope
ûû> C
is
ûûD F
not
ûûG J
null
ûûK O
)
ûûO P
return
ûûQ W
scope
ûûX ]
;
ûû] ^
var
üü 
item
üü 
=
üü 
await
üü 
db
üü 
.
üü 
ClientProducts
üü *
.
üü* +
Include
üü+ 2
(
üü2 3
x
üü3 4
=>
üü5 7
x
üü8 9
.
üü9 :
Product
üü: A
)
üüA B
.
üüB C
Include
üüC J
(
üüJ K
x
üüK L
=>
üüM O
x
üüP Q
.
üüQ R
Project
üüR Y
)
üüY Z
.
üüZ ["
SingleOrDefaultAsync
üü[ o
(
üüo p
x
üüp q
=>
üür t
x
üüu v
.
üüv w
Id
üüw y
==
üüz |
id
üü} 
&&üüÄ Ç
xüüÉ Ñ
.üüÑ Ö
ClientIdüüÖ ç
==üüé ê
ownerüüë ñ
,üüñ ó
ctüüò ö
)üüö õ
;üüõ ú
returnüüù £
itemüü§ ®
isüü© ´
nullüü¨ ∞
?üü± ≤
NotFoundüü≥ ª
(üüª º
)üüº Ω
:üüæ ø
Oküü¿ ¬
(üü¬ √
itemüü√ «
)üü« »
;üü» …
}
†† 
[
¢¢ 
HttpPost
¢¢ 
(
¢¢ 
$str
¢¢ (
)
¢¢( )
]
¢¢) *
public
££ 

async
££ 
Task
££ 
<
££ 
IActionResult
££ #
>
££# $
Webhook
££% ,
(
££, -
CancellationToken
££- >
ct
££? A
)
££A B
{
§§ 
using
•• 
var
•• 
reader
•• 
=
•• 
new
•• 
StreamReader
•• +
(
••+ ,
Request
••, 3
.
••3 4
Body
••4 8
)
••8 9
;
••9 :
var
••; >
payload
••? F
=
••G H
await
••I N
reader
••O U
.
••U V
ReadToEndAsync
••V d
(
••d e
ct
••e g
)
••g h
;
••h i
var
••j m
headers
••n u
=
••v w
Request
••x 
.•• Ä
Headers••Ä á
.••á à
ToDictionary••à î
(••î ï
x••ï ñ
=>••ó ô
x••ö õ
.••õ ú
Key••ú ü
.••ü † 
ToLowerInvariant••† ∞
(••∞ ±
)••± ≤
,••≤ ≥
x••¥ µ
=>••∂ ∏
x••π ∫
.••∫ ª
Value••ª ¿
.••¿ ¡
ToString••¡ …
(••…  
)••  À
)••À Ã
;••Ã Õ
if
¶¶ 

(
¶¶ 
!
¶¶ 
await
¶¶ 
payPal
¶¶ 
.
¶¶  
VerifyWebhookAsync
¶¶ ,
(
¶¶, -
payload
¶¶- 4
,
¶¶4 5
headers
¶¶6 =
,
¶¶= >
ct
¶¶? A
)
¶¶A B
)
¶¶B C
return
¶¶D J
Unauthorized
¶¶K W
(
¶¶W X
)
¶¶X Y
;
¶¶Y Z
using
ßß 
var
ßß 
json
ßß 
=
ßß 
JsonDocument
ßß %
.
ßß% &
Parse
ßß& +
(
ßß+ ,
payload
ßß, 3
)
ßß3 4
;
ßß4 5
var
ßß6 9
root
ßß: >
=
ßß? @
json
ßßA E
.
ßßE F
RootElement
ßßF Q
;
ßßQ R
var
ßßS V
	eventType
ßßW `
=
ßßa b
Find
ßßc g
(
ßßg h
root
ßßh l
,
ßßl m
$str
ßßn z
)
ßßz {
;
ßß{ |
if
ßß} 
(ßßÄ Å
!ßßÅ Ç
rootßßÇ Ü
.ßßÜ á
TryGetPropertyßßá ï
(ßßï ñ
$strßßñ †
,ßß† °
outßß¢ •
varßß¶ ©
resourceßß™ ≤
)ßß≤ ≥
)ßß≥ ¥
returnßßµ ª
Okßßº æ
(ßßæ ø
)ßßø ¿
;ßß¿ ¡
var
®® 

resourceId
®® 
=
®® 
Find
®® 
(
®® 
resource
®® &
,
®®& '
$str
®®( ,
)
®®, -
;
®®- .
var
®®/ 2
orderId
®®3 :
=
®®; <
Nested
®®= C
(
®®C D
resource
®®D L
,
®®L M
$str
®®N b
,
®®b c
$str
®®d q
,
®®q r
$str
®®s }
)
®®} ~
??®® Å

resourceId®®Ç å
;®®å ç
var®®é ë
customId®®í ö
=®®õ ú
Find®®ù °
(®®° ¢
resource®®¢ ™
,®®™ ´
$str®®¨ ∑
)®®∑ ∏
??®®π ª
Find®®º ¿
(®®¿ ¡
resource®®¡ …
,®®…  
$str®®À ”
)®®” ‘
??®®’ ◊
Find®®ÿ ‹
(®®‹ ›
root®®› ·
,®®· ‚
$str®®„ Ó
)®®Ó Ô
??®® Ú
PurchaseUnit®®Û ˇ
(®®ˇ Ä
resource®®Ä à
,®®à â
$str®®ä ï
)®®ï ñ
;®®ñ ó
var
™™ 
subscriptionId
™™ 
=
™™ 
Find
™™ !
(
™™! "
resource
™™" *
,
™™* +
$str
™™, B
)
™™B C
??
™™D F

resourceId
™™G Q
;
™™Q R
var
´´ 
item
´´ 
=
´´ 
await
´´ 
WebhookItemAsync
´´ )
(
´´) *
customId
´´* 2
,
´´2 3
orderId
´´4 ;
,
´´; <
subscriptionId
´´= K
,
´´K L
ct
´´M O
)
´´O P
;
´´P Q
if
¨¨ 

(
¨¨ 
item
¨¨ 
is
¨¨ 
null
¨¨ 
)
¨¨ 
return
¨¨  
Ok
¨¨! #
(
¨¨# $
)
¨¨$ %
;
¨¨% &
if
≠≠ 

(
≠≠ 
	eventType
≠≠ 
is
≠≠ 
$str
≠≠ 9
or
≠≠: <
$str
≠≠= ]
)
≠≠] ^
{
≠≠_ `
item
≠≠a e
.
≠≠e f
Status
≠≠f l
=
≠≠m n
	eventType
≠≠o x
.
≠≠x y
EndsWith≠≠y Å
(≠≠Å Ç
$str≠≠Ç ç
)≠≠ç é
?≠≠è ê#
ClientProductStatus≠≠ë §
.≠≠§ •
Activo≠≠• ´
:≠≠¨ ≠#
ClientProductStatus≠≠Æ ¡
.≠≠¡ ¬
	Cancelado≠≠¬ À
;≠≠À Ã
item≠≠Õ —
.≠≠— “$
PayPalSubscriptionId≠≠“ Ê
??=≠≠Á Í

resourceId≠≠Î ı
;≠≠ı ˆ
}≠≠˜ ¯
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
ØØ 2
)
ØØ2 3
{
ØØ4 5
item
ØØ6 :
.
ØØ: ;
PayPalOrderId
ØØ; H
??=
ØØI L
orderId
ØØM T
;
ØØT U
await
ØØV [
db
ØØ\ ^
.
ØØ^ _
SaveChangesAsync
ØØ_ o
(
ØØo p
ct
ØØp r
)
ØØr s
;
ØØs t
await
ØØu z
paymentsØØ{ É
.ØØÉ Ñ
CaptureAsyncØØÑ ê
(ØØê ë
itemØØë ï
,ØØï ñ
ctØØó ô
)ØØô ö
;ØØö õ
}ØØú ù
if
±± 

(
±± 
	eventType
±± 
is
±± 
$str
±± 4
or
±±5 7
$str
±±8 P
&&
±±Q S
Amount
±±T Z
(
±±Z [
resource
±±[ c
)
±±c d
is
±±e g
(
±±h i
decimal
±±i p
amount
±±q w
,
±±w x
var
±±y |
currency±±} Ö
)±±Ö Ü
&&±±á â
orderId±±ä ë
is±±í î
not±±ï ò
null±±ô ù
)±±ù û
await
≤≤ 
payments
≤≤ 
.
≤≤ 
ApplyPaymentAsync
≤≤ ,
(
≤≤, -
item
≤≤- 1
,
≤≤1 2
orderId
≤≤3 :
,
≤≤: ;
amount
≤≤< B
,
≤≤B C
currency
≤≤D L
,
≤≤L M
ct
≤≤N P
)
≤≤P Q
;
≤≤Q R
await
≥≥ 
db
≥≥ 
.
≥≥ 
SaveChangesAsync
≥≥ !
(
≥≥! "
ct
≥≥" $
)
≥≥$ %
;
≥≥% &
if
¥¥ 

(
¥¥ 
	eventType
¥¥ 
is
¥¥ 
$str
¥¥ 1
or
¥¥2 4
$str
¥¥5 J
or
¥¥K M
$str
¥¥N s
)
¥¥s t
await
µµ &
NotifyPaymentFailedAsync
µµ *
(
µµ* +
item
µµ+ /
,
µµ/ 0
Find
µµ1 5
(
µµ5 6
root
µµ6 :
,
µµ: ;
$str
µµ< @
)
µµ@ A
??
µµB D

resourceId
µµE O
,
µµO P
ct
µµQ S
)
µµS T
;
µµT U
return
∂∂ 
Ok
∂∂ 
(
∂∂ 
)
∂∂ 
;
∂∂ 
}
∑∑ 
private
∫∫ 
async
∫∫ 
Task
∫∫ 
<
∫∫ 
ClientProduct
∫∫ $
?
∫∫$ %
>
∫∫% &
WebhookItemAsync
∫∫' 7
(
∫∫7 8
string
∫∫8 >
?
∫∫> ?
customId
∫∫@ H
,
∫∫H I
string
∫∫J P
?
∫∫P Q
orderId
∫∫R Y
,
∫∫Y Z
string
∫∫[ a
?
∫∫a b
subscriptionId
∫∫c q
,
∫∫q r 
CancellationToken∫∫s Ñ
ct∫∫Ö á
)∫∫á à
{
ªª 
var
ºº 
products
ºº 
=
ºº 
db
ºº 
.
ºº 
ClientProducts
ºº (
.
ºº( )
Include
ºº) 0
(
ºº0 1
x
ºº1 2
=>
ºº3 5
x
ºº6 7
.
ºº7 8
Product
ºº8 ?
)
ºº? @
;
ºº@ A
if
ΩΩ 

(
ΩΩ 
Guid
ΩΩ 
.
ΩΩ 
TryParse
ΩΩ 
(
ΩΩ 
customId
ΩΩ "
,
ΩΩ" #
out
ΩΩ$ '
var
ΩΩ( +

customGuid
ΩΩ, 6
)
ΩΩ6 7
&&
ΩΩ8 :
await
ΩΩ; @
products
ΩΩA I
.
ΩΩI J"
SingleOrDefaultAsync
ΩΩJ ^
(
ΩΩ^ _
x
ΩΩ_ `
=>
ΩΩa c
x
ΩΩd e
.
ΩΩe f
Id
ΩΩf h
==
ΩΩi k

customGuid
ΩΩl v
,
ΩΩv w
ct
ΩΩx z
)
ΩΩz {
is
ΩΩ| ~
{ΩΩ Ä
}ΩΩÅ Ç
itemΩΩÉ á
)ΩΩá à
returnΩΩâ è
itemΩΩê î
;ΩΩî ï
if
ææ 

(
ææ 
string
ææ 
.
ææ  
IsNullOrWhiteSpace
ææ %
(
ææ% &
orderId
ææ& -
)
ææ- .
)
ææ. /
return
ææ0 6
null
ææ7 ;
;
ææ; <
return
øø 
await
øø 
products
øø 
.
øø "
SingleOrDefaultAsync
øø 2
(
øø2 3
x
øø3 4
=>
øø5 7
x
øø8 9
.
øø9 :"
PayPalSubscriptionId
øø: N
==
øøO Q
subscriptionId
øøR `
||
øøa c
x
øød e
.
øøe f
PayPalOrderId
øøf s
==
øøt v
orderId
øøw ~
,
øø~ 
ctøøÄ Ç
)øøÇ É
;øøÉ Ñ
}
¿¿ 
private
¬¬ 
async
¬¬ 
Task
¬¬ &
NotifyPaymentFailedAsync
¬¬ /
(
¬¬/ 0
ClientProduct
¬¬0 =
item
¬¬> B
,
¬¬B C
string
¬¬D J
?
¬¬J K
eventId
¬¬L S
,
¬¬S T
CancellationToken
¬¬U f
ct
¬¬g i
)
¬¬i j
{
√√ 
if
ƒƒ 

(
ƒƒ 
await
ƒƒ 
db
ƒƒ 
.
ƒƒ 
Clients
ƒƒ 
.
ƒƒ 
	FindAsync
ƒƒ &
(
ƒƒ& '
[
ƒƒ' (
item
ƒƒ( ,
.
ƒƒ, -
ClientId
ƒƒ- 5
]
ƒƒ5 6
,
ƒƒ6 7
ct
ƒƒ8 :
)
ƒƒ: ;
is
ƒƒ< >
not
ƒƒ? B
Client
ƒƒC I
client
ƒƒJ P
)
ƒƒP Q
return
ƒƒR X
;
ƒƒX Y
await
≈≈ 
notifications
≈≈ 
.
≈≈ 
	SendAsync
≈≈ %
(
≈≈% &
client
≈≈& ,
,
≈≈, -
new
≈≈. 1
Notification
≈≈2 >
(
≈≈> ?
NotificationType
≈≈? O
.
≈≈O P
PaymentFailed
≈≈P ]
,
≈≈] ^
new
≈≈_ b
(
≈≈b c
)
≈≈c d
{
≈≈e f
[
≈≈g h
$str
≈≈h q
]
≈≈q r
=
≈≈s t
item
≈≈u y
.
≈≈y z
Product≈≈z Å
?≈≈Å Ç
.≈≈Ç É
Name≈≈É á
??≈≈à ä
$str≈≈ã ç
}≈≈é è
,≈≈è ê
$"≈≈ë ì
$str≈≈ì ¢
{≈≈¢ £
eventId≈≈£ ™
}≈≈™ ´
"≈≈´ ¨
)≈≈¨ ≠
,≈≈≠ Æ
ct≈≈Ø ±
)≈≈± ≤
;≈≈≤ ≥
}
∆∆ 
private
»» 
static
»» 
string
»» 
?
»» 
Find
»» 
(
»»  
JsonElement
»»  +
value
»», 1
,
»»1 2
string
»»3 9
property
»»: B
)
»»B C
=>
»»D F
value
»»G L
.
»»L M
TryGetProperty
»»M [
(
»»[ \
property
»»\ d
,
»»d e
out
»»f i
var
»»j m
item
»»n r
)
»»r s
&&
»»t v
item
»»w {
.
»»{ |
	ValueKind»»| Ö
==»»Ü à
JsonValueKind»»â ñ
.»»ñ ó
String»»ó ù
?»»û ü
item»»† §
.»»§ •
	GetString»»• Æ
(»»Æ Ø
)»»Ø ∞
:»»± ≤
null»»≥ ∑
;»»∑ ∏
private
…… 
static
…… 
string
…… 
?
…… 
Nested
…… !
(
……! "
JsonElement
……" -
value
……. 3
,
……3 4
params
……5 ;
string
……< B
[
……B C
]
……C D
path
……E I
)
……I J
{
……K L
foreach
……M T
(
……U V
var
……V Y
property
……Z b
in
……c e
path
……f j
)
……j k
{
……l m
if
……n p
(
……q r
!
……r s
value
……s x
.
……x y
TryGetProperty……y á
(……á à
property……à ê
,……ê ë
out……í ï
value……ñ õ
)……õ ú
)……ú ù
return……û §
null……• ©
;……© ™
}……´ ¨
return……≠ ≥
value……¥ π
.……π ∫
	ValueKind……∫ √
==……ƒ ∆
JsonValueKind……« ‘
.……‘ ’
String……’ €
?……‹ ›
value……ﬁ „
.……„ ‰
	GetString……‰ Ì
(……Ì Ó
)……Ó Ô
:…… Ò
null……Ú ˆ
;……ˆ ˜
}……¯ ˘
private
   
static
   
string
   
?
   
PurchaseUnit
   '
(
  ' (
JsonElement
  ( 3
resource
  4 <
,
  < =
string
  > D
property
  E M
)
  M N
=>
  O Q
resource
  R Z
.
  Z [
TryGetProperty
  [ i
(
  i j
$str
  j z
,
  z {
out
  | 
var  Ä É
units  Ñ â
)  â ä
&&  ã ç
units  é ì
.  ì î
	ValueKind  î ù
==  û †
JsonValueKind  ° Æ
.  Æ Ø
Array  Ø ¥
&&  µ ∑
units  ∏ Ω
.  Ω æ
GetArrayLength  æ Ã
(  Ã Õ
)  Õ Œ
>  œ –
$num  — “
?  ” ‘
Find  ’ Ÿ
(  Ÿ ⁄
units  ⁄ ﬂ
[  ﬂ ‡
$num  ‡ ·
]  · ‚
,  ‚ „
property  ‰ Ï
)  Ï Ì
:  Ó Ô
null   Ù
;  Ù ı
private
ÀÀ 
static
ÀÀ 
(
ÀÀ 
decimal
ÀÀ 
?
ÀÀ 
amount
ÀÀ #
,
ÀÀ# $
string
ÀÀ% +
?
ÀÀ+ ,
currency
ÀÀ- 5
)
ÀÀ5 6
Amount
ÀÀ7 =
(
ÀÀ= >
JsonElement
ÀÀ> I
resource
ÀÀJ R
)
ÀÀR S
{
ÃÃ 
foreach
ŒŒ 
(
ŒŒ 
var
ŒŒ 
name
ŒŒ 
in
ŒŒ 
new
ŒŒ  
[
ŒŒ  !
]
ŒŒ! "
{
ŒŒ# $
$str
ŒŒ% -
,
ŒŒ- .
$str
ŒŒ/ =
}
ŒŒ> ?
)
ŒŒ? @
if
ŒŒA C
(
ŒŒD E
resource
ŒŒE M
.
ŒŒM N
TryGetProperty
ŒŒN \
(
ŒŒ\ ]
name
ŒŒ] a
,
ŒŒa b
out
ŒŒc f
var
ŒŒg j
value
ŒŒk p
)
ŒŒp q
&&
ŒŒr t
(
ŒŒu v
value
ŒŒv {
.
ŒŒ{ |
TryGetPropertyŒŒ| ä
(ŒŒä ã
$strŒŒã í
,ŒŒí ì
outŒŒî ó
varŒŒò õ
amountŒŒú ¢
)ŒŒ¢ £
||ŒŒ§ ¶
valueŒŒß ¨
.ŒŒ¨ ≠
TryGetPropertyŒŒ≠ ª
(ŒŒª º
$strŒŒº √
,ŒŒ√ ƒ
outŒŒ≈ »
amountŒŒ… œ
)ŒŒœ –
)ŒŒ– —
&&ŒŒ“ ‘
decimalŒŒ’ ‹
.ŒŒ‹ ›
TryParseŒŒ› Â
(ŒŒÂ Ê
amountŒŒÊ Ï
.ŒŒÏ Ì
	GetStringŒŒÌ ˆ
(ŒŒˆ ˜
)ŒŒ˜ ¯
,ŒŒ¯ ˘
SystemŒŒ˙ Ä
.ŒŒÄ Å
GlobalizationŒŒÅ é
.ŒŒé è
NumberStylesŒŒè õ
.ŒŒõ ú
NumberŒŒú ¢
,ŒŒ¢ £
SystemŒŒ§ ™
.ŒŒ™ ´
GlobalizationŒŒ´ ∏
.ŒŒ∏ π
CultureInfoŒŒπ ƒ
.ŒŒƒ ≈ 
InvariantCultureŒŒ≈ ’
,ŒŒ’ ÷
outŒŒ◊ ⁄
varŒŒ€ ﬁ
parsedŒŒﬂ Â
)ŒŒÂ Ê
)ŒŒÊ Á
returnŒŒË Ó
(ŒŒÔ 
parsedŒŒ ˆ
,ŒŒˆ ˜
FindŒŒ¯ ¸
(ŒŒ¸ ˝
valueŒŒ˝ Ç
,ŒŒÇ É
$strŒŒÑ ì
)ŒŒì î
??ŒŒï ó
FindŒŒò ú
(ŒŒú ù
valueŒŒù ¢
,ŒŒ¢ £
$strŒŒ§ Æ
)ŒŒÆ Ø
)ŒŒØ ∞
;ŒŒ∞ ±
if
œœ 

(
œœ 
resource
œœ 
.
œœ 
TryGetProperty
œœ #
(
œœ# $
$str
œœ$ 4
,
œœ4 5
out
œœ6 9
var
œœ: =
units
œœ> C
)
œœC D
&&
œœE G
units
œœH M
.
œœM N
	ValueKind
œœN W
==
œœX Z
JsonValueKind
œœ[ h
.
œœh i
Array
œœi n
&&
œœo q
units
œœr w
.
œœw x
GetArrayLengthœœx Ü
(œœÜ á
)œœá à
>œœâ ä
$numœœã å
)œœå ç
returnœœé î
Amountœœï õ
(œœõ ú
unitsœœú °
[œœ° ¢
$numœœ¢ £
]œœ£ §
)œœ§ •
;œœ• ¶
return
–– 
(
–– 
null
–– 
,
–– 
null
–– 
)
–– 
;
–– 
}
—— 
}““ 
public’’ 
sealed
’’ 
record
’’ 
SubscribeRequest
’’ %
(
’’% &
[
’’& '
property
’’' /
:
’’/ 0
JsonRequired
’’1 =
]
’’= >
Guid
’’? C
	ProductId
’’D M
,
’’M N
Guid
’’O S
?
’’S T
	ProjectId
’’U ^
,
’’^ _
[
’’` a
property
’’a i
:
’’i j
JsonRequired
’’k w
]
’’w x
BillingCycle’’y Ö
BillingCycle’’Ü í
,’’í ì
string’’î ö
PaymentMethod’’õ ®
=’’© ™
PaymentMethods’’´ π
.’’π ∫
PayPal’’∫ ¿
,’’¿ ¡
int’’¬ ≈
Years’’∆ À
=’’Ã Õ
$num’’Œ œ
)’’œ –
;’’– —∑u
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
;ããî ï˜j
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
[ 
HttpPost 
( 
$str 
) 
, 
EnableRateLimiting *
(* + 
LoginRateLimitPolicy+ ?
)? @
]@ A
publicB H
asyncI N
TaskO S
<S T
ActionResultT `
>` a
Loginb g
(g h
LoginRequesth t
requestu |
,| }
CancellationToken	~ è
ct
ê í
)
í ì
{ 
var 
failKey 
= 
$str !
+! "
request" )
.) *
Email* /
./ 0
Trim0 4
(4 5
)5 6
.6 7
ToLowerInvariant7 G
(G H
)H I
;I J
if 

(
 
cache 
. 
TryGetValue 
( 
failKey $
,$ %
out% (
FailedLogins) 5
?5 6
fails7 <
)< =
&&= ?
fails? D
!D E
.E F
CountF K
>=K M
MaxFailedAttemptsM ^
)^ _
return_ e

StatusCodef p
(p q
$numq t
,t u
newu x
{x y
message	y Ä
=
Ä Å
$str
Å ”
}
” ‘
)
‘ ’
;
’ ÷
var 
u 
= 
await 
db 
. 
UserAccounts #
.# $ 
SingleOrDefaultAsync$ 8
(8 9
x9 :
=>: <
x< =
.= >
Email> C
==C E
requestE L
.L M
EmailM R
&&R T
xT U
.U V
IsActiveV ^
,^ _
ct_ a
)a b
;b c
if 

(
 
u 
is 
null 
|| 
new 
PasswordHasher (
<( )
UserAccount) 4
>4 5
(5 6
)6 7
.7 8 
VerifyHashedPassword8 L
(L M
uM N
,N O
uO P
.P Q
PasswordHashQ ]
,] ^
request^ e
.e f
Passwordf n
)n o
==o q'
PasswordVerificationResult	q ã
.
ã å
Failed
å í
)
í ì
{ 	
var 
f 
= 
cache 
. 
GetOrCreate #
(# $
failKey$ +
,+ ,
e, -
=>- /
{/ 0
e0 1
.1 2+
AbsoluteExpirationRelativeToNow2 Q
=Q R
LockoutWindowR _
;_ `
return` f
newg j
FailedLoginsk w
(w x
)x y
;y z
}z {
){ |
!| }
;} ~
Interlocked 
. 
	Increment !
(! "
ref" %
f& '
.' (
Count( -
)- .
;. /
return 
Unauthorized 
(  
new  #
{$ %
message% ,
=, -
$str- F
}F G
)G H
;H I
} 	
cache   
.   
Remove   
(   
failKey   
)   
;   
var!! 
c!! 
=!! 
u!! 
.!! 
ClientId!! 
is!! 
Guid!!  
clientId!!! )
?!!) *
await!!* /
db!!0 2
.!!2 3
Clients!!3 :
.!!: ;
	FindAsync!!; D
(!!D E
[!!E F
clientId!!F N
]!!N O
,!!O P
ct!!P R
)!!R S
:!!S T
null!!T X
;!!X Y
if"" 

(""
 
c"" 
is"" 
not"" 
null"" 
&&"" 
!"" 
c"" 
."" 
IsActive"" %
)""% &
return""& ,

StatusCode""- 7
(""7 8
$num""8 ;
,""; <
new""< ?
{""? @
message""@ G
=""G H
$str""H {
}""{ |
)""| }
;""} ~
return## 

SessionFor## 
(## 
jwt## 
,## 
u## 
,##  
c##  !
)##! "
;##" #
}$$ 
const%% 	
string%%
 
GoogleRefused%% 
=%%  
$str%%! p
;%%p q
['' 
HttpPost'' 
('' 
$str'' 
)'' 
,'' 
EnableRateLimiting'' +
(''+ , 
LoginRateLimitPolicy'', @
)''@ A
]''A B
public''C I
async''J O
Task''P T
<''T U
ActionResult''U a
>''a b
Google''c i
(''i j
GoogleLoginRequest''j |
request	''} Ñ
,
''Ñ Ö
CancellationToken
''Ü ó
ct
''ò ö
)
''ö õ
{(( 
var)) 
identity)) 
=)) 
await)) 
firebase)) #
.))# $
VerifyAsync))$ /
())/ 0
request))0 7
.))7 8
IdToken))8 ?
,))? @
ct))@ B
)))B C
;))C D
if** 

(**
 
identity** 
is** 
null** 
||** 
!** 
identity** &
.**& '
EmailVerified**' 4
)**4 5
return**5 ;
Unauthorized**< H
(**H I
new**I L
{**L M
message**M T
=**T U
GoogleRefused**U b
}**b c
)**c d
;**d e
var++ 
email++ 
=++ 
identity++ 
.++ 
Email++  
.++  !
Trim++! %
(++% &
)++& '
.++' (
ToLower++( /
(++/ 0
)++0 1
;++1 2
var,, 
u,, 
=,, 
await,, 
db,, 
.,, 
UserAccounts,, #
.,,# $
AsNoTracking,,$ 0
(,,0 1
),,1 2
.,,2 3
FirstOrDefaultAsync,,3 F
(,,F G
x,,G H
=>,,H J
x,,J K
.,,K L
IsActive,,L T
&&,,T V
x,,V W
.,,W X
Email,,X ]
.,,] ^
Trim,,^ b
(,,b c
),,c d
.,,d e
ToLower,,e l
(,,l m
),,m n
==,,n p
email,,p u
,,,u v
ct,,v x
),,x y
;,,y z
if-- 

(--
 
u-- 
is-- 
null-- 
)-- 
return-- 
Unauthorized-- (
(--( )
new--) ,
{--, -
message--- 4
=--4 5
GoogleRefused--5 B
}--B C
)--C D
;--D E
var.. 
c.. 
=.. 
u.. 
... 
ClientId.. 
is.. 
Guid..  
clientId..! )
?..) *
await..* /
db..0 2
...2 3
Clients..3 :
...: ;
AsNoTracking..; G
(..G H
)..H I
...I J
FirstOrDefaultAsync..J ]
(..] ^
x..^ _
=>.._ a
x..a b
...b c
Id..c e
==..e g
clientId..g o
,..o p
ct..p r
)..r s
:..s t
null..t x
;..x y
if// 

(//
 
c// 
is// 
not// 
null// 
&&// 
!// 
c// 
.// 
IsActive// %
)//% &
return//& ,

StatusCode//- 7
(//7 8
$num//8 ;
,//; <
new//< ?
{//? @
message//@ G
=//G H
$str//H {
}//{ |
)//| }
;//} ~
return00 

SessionFor00 
(00 
jwt00 
,00 
u00 
,00  
c00  !
)00! "
;00" #
}11 
internal33 
static33 
ActionResult33  

SessionFor33! +
(33+ ,
JwtSettings33, 7
jwt338 ;
,33; <
UserAccount33= H
u33I J
,33J K
Client33L R
?33R S
c33T U
)33U V
{44 
var55 
claims55 
=55 
new55 
List55 
<55 
Claim55 !
>55! "
{55" #
new55# &
(55& '#
JwtRegisteredClaimNames55' >
.55> ?
Sub55? B
,55B C
u55C D
.55D E
Id55E G
.55G H
ToString55H P
(55P Q
)55Q R
)55R S
,55S T
new55T W
(55W X

ClaimTypes55X b
.55b c
NameIdentifier55c q
,55q r
u55r s
.55s t
Id55t v
.55v w
ToString55w 
(	55 Ä
)
55Ä Å
)
55Å Ç
,
55Ç É
new
55É Ü
(
55Ü á

ClaimTypes
55á ë
.
55ë í
Role
55í ñ
,
55ñ ó
u
55ó ò
.
55ò ô
Role
55ô ù
.
55ù û
ToString
55û ¶
(
55¶ ß
)
55ß ®
)
55® ©
}
55© ™
;
55™ ´
if66 

(66
 
u66 
.66 
ClientId66 
is66 
Guid66 
id66  
)66  !
claims66! '
.66' (
Add66( +
(66+ ,
new66, /
Claim660 5
(665 6
$str666 A
,66A B
id66B D
.66D E
ToString66E M
(66M N
)66N O
)66O P
)66P Q
;66Q R
var77 
token77 
=77 
new77 
JwtSecurityToken77 &
(77& '
jwt77' *
.77* +
Issuer77+ 1
,771 2
jwt772 5
.775 6
Audience776 >
,77> ?
claims77? E
,77E F
expires77F M
:77M N
DateTime77N V
.77V W
UtcNow77W ]
.77] ^
AddHours77^ f
(77f g
$num77g h
)77h i
,77i j
signingCredentials77j |
:77| }
new	77} Ä 
SigningCredentials
77Å ì
(
77ì î
jwt
77î ó
.
77ó ò

SigningKey
77ò ¢
,
77¢ £ 
SecurityAlgorithms
77£ µ
.
77µ ∂

HmacSha256
77∂ ¿
)
77¿ ¡
)
77¡ ¬
;
77¬ √
var88 
initials88 
=88 
string88 
.88 
Concat88 "
(88" #
u88# $
.88$ %
Name88% )
.88) *
Split88* /
(88/ 0
$char880 3
,883 4
StringSplitOptions884 F
.88F G
RemoveEmptyEntries88G Y
)88Y Z
.88Z [
Take88[ _
(88_ `
$num88` a
)88a b
.88b c
Select88c i
(88i j
x88j k
=>88k m
x88m n
[88n o
$num88o p
]88p q
)88q r
)88r s
.88s t
ToUpperInvariant	88t Ñ
(
88Ñ Ö
)
88Ö Ü
;
88Ü á
return99 
new99 
OkObjectResult99 !
(99! "
new99" %
{99& '
token99' ,
=99, -
new99- 0#
JwtSecurityTokenHandler991 H
(99H I
)99I J
.99J K

WriteToken99K U
(99U V
token99V [
)99[ \
,99\ ]
user99] a
=99a b
new99b e
{99e f
name99f j
=99j k
u99k l
.99l m
Name99m q
,99q r
initials99r z
,99z {

clientName	99{ Ö
=
99Ö Ü
c
99Ü á
?
99á à
.
99à â
CompanyName
99â î
,
99î ï
role
99ï ô
=
99ô ö
u
99ö õ
.
99õ ú
Role
99ú †
.
99† °
ToString
99° ©
(
99© ™
)
99™ ´
}
99´ ¨
}
99¨ ≠
)
99≠ Æ
;
99Æ Ø
}:: 
};; ÿÖ
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
ÖÖe fáπ
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
{ 
if 

( 
string 
. 
IsNullOrWhiteSpace %
(% &
request& -
.- .
Name. 2
)2 3
)3 4
return5 ;

BadRequest< F
(F G
newG J
{K L
messageM T
=U V
$strW r
}s t
)t u
;u v
var   
user   
=   
await   
db   
.   
UserAccounts   (
.  ( )
	FindAsync  ) 2
(  2 3
[  3 4
UserId  4 :
]  : ;
,  ; <
ct  = ?
)  ? @
;  @ A
if!! 

(!! 
user!! 
is!! 
null!! 
)!! 
return!!  
NotFound!!! )
(!!) *
)!!* +
;!!+ ,
user"" 
."" 
Name"" 
="" 
request"" 
."" 
Name""  
.""  !
Trim""! %
(""% &
)""& '
;""' (
await## 
db## 
.## 
SaveChangesAsync## !
(##! "
ct##" $
)##$ %
;##% &
return$$ 
Ok$$ 
($$ 
)$$ 
;$$ 
}%% 
[&& 
HttpPost&& 
(&& 
$str&& '
)&&' (
]&&( )
public'' 

async'' 
Task'' 
<'' 
ActionResult'' "
>''" #
ChangePassword''$ 2
(''2 3!
ChangePasswordRequest''3 H
request''I P
,''P Q
CancellationToken''R c
ct''d f
)''f g
{(( 
var)) 
user)) 
=)) 
await)) 
db)) 
.)) 
UserAccounts)) (
.))( )
	FindAsync))) 2
())2 3
[))3 4
UserId))4 :
])): ;
,)); <
ct))= ?
)))? @
;))@ A
if** 

(** 
user** 
is** 
null** 
)** 
return**  
NotFound**! )
(**) *
)*** +
;**+ ,
if++ 

(++ 
Hasher++ 
.++  
VerifyHashedPassword++ '
(++' (
user++( ,
,++, -
user++. 2
.++2 3
PasswordHash++3 ?
,++? @
request++A H
.++H I
CurrentPassword++I X
)++X Y
==++Z \&
PasswordVerificationResult++] w
.++w x
Failed++x ~
)++~ 
return
++Ä Ü

BadRequest
++á ë
(
++ë í
new
++í ï
{
++ñ ó
message
++ò ü
=
++† °
$str
++¢ ≈
}
++∆ «
)
++« »
;
++» …
if,, 

(,, 
string,, 
.,, 
IsNullOrWhiteSpace,, %
(,,% &
request,,& -
.,,- .
NewPassword,,. 9
),,9 :
),,: ;
return,,< B

BadRequest,,C M
(,,M N
new,,N Q
{,,R S
message,,T [
=,,\ ]
$str	,,^ É
}
,,Ñ Ö
)
,,Ö Ü
;
,,Ü á
user-- 
.-- 
PasswordHash-- 
=-- 
Hasher-- "
.--" #
HashPassword--# /
(--/ 0
user--0 4
,--4 5
request--6 =
.--= >
NewPassword--> I
)--I J
;--J K
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
(// 
)// 
;// 
}00 
internal22 
static22 
string22 
TemporaryPassword22 ,
(22, -
)22- .
=>22/ 1
Convert222 9
.229 :
ToBase64String22: H
(22H I!
RandomNumberGenerator22I ^
.22^ _
GetBytes22_ g
(22g h
$num22h j
)22j k
)22k l
.22l m
Replace22m t
(22t u
$str22u x
,22x y
$str22z }
)22} ~
.22~ 
Replace	22 Ü
(
22Ü á
$str
22á ä
,
22ä ã
$str
22å è
)
22è ê
;
22ê ë
[44 
HttpGet44 
(44 
$str44 #
)44# $
]44$ %
public55 

async55 
Task55 
<55 
ActionResult55 "
>55" #
Transactions55$ 0
(550 1
Guid551 5
?555 6
clientId557 ?
,55? @
CancellationToken55A R
ct55S U
)55U V
{66 
Guid88 
?88 
scope88 
;88 
if99 

(99 
User99 
.99 
IsInRole99 
(99 
nameof99  
(99  !
UserRole99! )
.99) *

SuperAdmin99* 4
)994 5
)995 6
)996 7
scope998 =
=99> ?
clientId99@ H
;99H I
else:: 
if:: 
(:: 
TryGetClientId:: 
(::  
out::  #
var::$ '
own::( +
)::+ ,
)::, -
scope::. 3
=::4 5
own::6 9
;::9 :
else;; 
return;; 
Ok;; 
(;; 
Array;; 
.;; 
Empty;; "
<;;" #
object;;# )
>;;) *
(;;* +
);;+ ,
);;, -
;;;- .
return<< 
Ok<< 
(<< 
await<< 
(<< 
from<< 
transaction<< )
in<<* ,
db<<- /
.<</ 0
PaymentTransactions<<0 C
join== 
client== $
in==% '
db==( *
.==* +
Clients==+ 2
on==3 5
transaction==6 A
.==A B
ClientId==B J
equals==K Q
client==R X
.==X Y
Id==Y [
where>> 
scope>> $
==>>% '
null>>( ,
||>>- /
transaction>>0 ;
.>>; <
ClientId>>< D
==>>E G
scope>>H M
orderby??  
transaction??! ,
.??, -
	CreatedAt??- 6

descending??7 A
letAA 
productAA $
=AA% &
(AA' (
fromAA( ,
clientProductAA- :
inAA; =
dbAA> @
.AA@ A
ClientProductsAAA O
joinAAP T
pAAU V
inAAW Y
dbAAZ \
.AA\ ]
ProductsAA] e
onAAf h
clientProductAAi v
.AAv w
	ProductId	AAw Ä
equals
AAÅ á
p
AAà â
.
AAâ ä
Id
AAä å
where
AAç í
clientProduct
AAì †
.
AA† °
Id
AA° £
==
AA§ ¶
transaction
AAß ≤
.
AA≤ ≥
ClientProductId
AA≥ ¬
select
AA√ …
p
AA  À
.
AAÀ Ã
Name
AAÃ –
)
AA– —
.
AA— “
FirstOrDefault
AA“ ‡
(
AA‡ ·
)
AA· ‚
selectBB 
newBB  #
{BB$ %
idBB& (
=BB) *
transactionBB+ 6
.BB6 7
IdBB7 9
,BB9 :
	createdAtBB; D
=BBE F
transactionBBG R
.BBR S
	CreatedAtBBS \
,BB\ ]
productBB^ e
=BBf g
productBBh o
??BBp r
transactionBBs ~
.BB~ 
Notes	BB Ñ
??
BBÖ á
transaction
BBà ì
.
BBì î
Method
BBî ö
,
BBö õ

clientName
BBú ¶
=
BBß ®
client
BB© Ø
.
BBØ ∞
CompanyName
BB∞ ª
,
BBª º
amount
BBΩ √
=
BBƒ ≈
transaction
BB∆ —
.
BB— “
Amount
BB“ ÿ
,
BBÿ Ÿ
currency
BB⁄ ‚
=
BB„ ‰
transaction
BBÂ 
.
BB Ò
Currency
BBÒ ˘
,
BB˘ ˙
status
BB˚ Å
=
BBÇ É
transaction
BBÑ è
.
BBè ê
Status
BBê ñ
,
BBñ ó
internalCode
BBò §
=
BB• ¶
transaction
BBß ≤
.
BB≤ ≥
InternalCode
BB≥ ø
}
BB¿ ¡
)
BB¡ ¬
.
BB¬ √
ToListAsync
BB√ Œ
(
BBŒ œ
ct
BBœ —
)
BB— “
)
BB“ ”
;
BB” ‘
}CC 
[DD 
HttpGetDD 
(DD 
$strDD 
)DD 
,DD 
	AuthorizeDD %
(DD% &
RolesDD& +
=DD, -
$strDD. 5
)DD5 6
]DD6 7
publicEE 

asyncEE 
TaskEE 
<EE 
ActionResultEE "
>EE" #
TeamEE$ (
(EE( )
CancellationTokenEE) :
ctEE; =
)EE= >
{FF 
ifGG 

(GG 
!GG 
TryGetClientIdGG 
(GG 
outGG 
varGG  #
clientIdGG$ ,
)GG, -
)GG- .
returnGG/ 5
ForbidGG6 <
(GG< =
)GG= >
;GG> ?
returnHH 
OkHH 
(HH 
awaitHH 
dbHH 
.HH 
UserAccountsHH '
.HH' (
WhereHH( -
(HH- .
xHH. /
=>HH0 2
xHH3 4
.HH4 5
ClientIdHH5 =
==HH> @
clientIdHHA I
)HHI J
.HHJ K
OrderByHHK R
(HHR S
xHHS T
=>HHU W
xHHX Y
.HHY Z
NameHHZ ^
)HH^ _
.HH_ `
SelectHH` f
(HHf g
xHHg h
=>HHi k
newHHl o
{HHp q
idHHr t
=HHu v
xHHw x
.HHx y
IdHHy {
,HH{ |
name	HH} Å
=
HHÇ É
x
HHÑ Ö
.
HHÖ Ü
Name
HHÜ ä
,
HHä ã
email
HHå ë
=
HHí ì
x
HHî ï
.
HHï ñ
Email
HHñ õ
,
HHõ ú
role
HHù °
=
HH¢ £
x
HH§ •
.
HH• ¶
Role
HH¶ ™
.
HH™ ´
ToString
HH´ ≥
(
HH≥ ¥
)
HH¥ µ
,
HHµ ∂
isActive
HH∑ ø
=
HH¿ ¡
x
HH¬ √
.
HH√ ƒ
IsActive
HHƒ Ã
,
HHÃ Õ
area
HHŒ “
=
HH” ‘
x
HH’ ÷
.
HH÷ ◊
Area
HH◊ €
,
HH€ ‹
jobTitle
HH› Â
=
HHÊ Á
x
HHË È
.
HHÈ Í
JobTitle
HHÍ Ú
,
HHÚ Û
	managerId
HHÙ ˝
=
HH˛ ˇ
x
HHÄ Å
.
HHÅ Ç
	ManagerId
HHÇ ã
}
HHå ç
)
HHç é
.
HHé è
ToListAsync
HHè ö
(
HHö õ
ct
HHõ ù
)
HHù û
)
HHû ü
;
HHü †
}II 
[JJ 
HttpPostJJ 
(JJ 
$strJJ 
)JJ 
,JJ 
	AuthorizeJJ &
(JJ& '
RolesJJ' ,
=JJ- .
$strJJ/ 6
)JJ6 7
]JJ7 8
publicKK 

asyncKK 
TaskKK 
<KK 
ActionResultKK "
>KK" #
InviteKK$ *
(KK* +
InviteRequestKK+ 8
requestKK9 @
,KK@ A
CancellationTokenKKB S
ctKKT V
)KKV W
{LL 
ifMM 

(MM 
!MM 
TryGetClientIdMM 
(MM 
outMM 
varMM  #
clientIdMM$ ,
)MM, -
)MM- .
returnMM/ 5
ForbidMM6 <
(MM< =
)MM= >
;MM> ?
ifNN 

(NN 
stringNN 
.NN 
IsNullOrWhiteSpaceNN %
(NN% &
requestNN& -
.NN- .
NameNN. 2
)NN2 3
||NN4 6
stringNN7 =
.NN= >
IsNullOrWhiteSpaceNN> P
(NNP Q
requestNNQ X
.NNX Y
EmailNNY ^
)NN^ _
)NN_ `
returnNNa g

BadRequestNNh r
(NNr s
newNNs v
{NNw x
message	NNy Ä
=
NNÅ Ç
$str
NNÉ •
}
NN¶ ß
)
NNß ®
;
NN® ©
ifOO 

(OO 
awaitOO 
dbOO 
.OO 
UserAccountsOO !
.OO! "
AnyAsyncOO" *
(OO* +
xOO+ ,
=>OO- /
xOO0 1
.OO1 2
EmailOO2 7
==OO8 :
requestOO; B
.OOB C
EmailOOC H
,OOH I
ctOOJ L
)OOL M
)OOM N
returnOOO U
ConflictOOV ^
(OO^ _
newOO_ b
{OOc d
messageOOe l
=OOm n
$str	OOo ç
}
OOé è
)
OOè ê
;
OOê ë
varPP 
temporaryPasswordPP 
=PP 
TemporaryPasswordPP  1
(PP1 2
)PP2 3
;PP3 4
varQQ 
userQQ 
=QQ 
newQQ 
UserAccountQQ "
{QQ# $
ClientIdQQ% -
=QQ. /
clientIdQQ0 8
,QQ8 9
NameQQ: >
=QQ? @
requestQQA H
.QQH I
NameQQI M
.QQM N
TrimQQN R
(QQR S
)QQS T
,QQT U
EmailQQV [
=QQ\ ]
requestQQ^ e
.QQe f
EmailQQf k
.QQk l
TrimQQl p
(QQp q
)QQq r
,QQr s
RoleQQt x
=QQy z
UserRole	QQ{ É
.
QQÉ Ñ
Cliente
QQÑ ã
}
QQå ç
;
QQç é
userRR 
.RR 
PasswordHashRR 
=RR 
HasherRR "
.RR" #
HashPasswordRR# /
(RR/ 0
userRR0 4
,RR4 5
temporaryPasswordRR6 G
)RRG H
;RRH I
dbSS 

.SS
 
UserAccountsSS 
.SS 
AddSS 
(SS 
userSS  
)SS  !
;SS! "
awaitTT 
dbTT 
.TT 
SaveChangesAsyncTT !
(TT! "
ctTT" $
)TT$ %
;TT% &
varUU 
clientUU 
=UU 
awaitUU 
dbUU 
.UU 
ClientsUU %
.UU% &
	FindAsyncUU& /
(UU/ 0
[UU0 1
clientIdUU1 9
]UU9 :
,UU: ;
ctUU< >
)UU> ?
;UU? @
varVV 
	emailSentVV 
=VV 
clientVV 
isVV !
notVV" %
nullVV& *
&&VV+ -
awaitVV. 3
accessEmailVV4 ?
.VV? @
	SendAsyncVV@ I
(VVI J
clientVVJ P
,VVP Q
userVVR V
.VVV W
NameVVW [
,VV[ \
userVV] a
.VVa b
EmailVVb g
,VVg h
temporaryPasswordVVi z
,VVz {
Request	VV| É
,
VVÉ Ñ
ct
VVÖ á
)
VVá à
;
VVà â
returnWW 
CreatedWW 
(WW 
$"WW 
$strWW )
{WW) *
userWW* .
.WW. /
IdWW/ 1
}WW1 2
"WW2 3
,WW3 4
newWW5 8
{WW9 :
idWW; =
=WW> ?
userWW@ D
.WWD E
IdWWE G
,WWG H
temporaryPasswordWWI Z
,WWZ [
	emailSentWW\ e
}WWf g
)WWg h
;WWh i
}XX 
[YY 
	HttpPatchYY 
(YY 
$strYY %
)YY% &
,YY& '
	AuthorizeYY( 1
(YY1 2
RolesYY2 7
=YY8 9
$strYY: A
)YYA B
]YYB C
publicZZ 

asyncZZ 
TaskZZ 
<ZZ 
ActionResultZZ "
>ZZ" #

UpdateTeamZZ$ .
(ZZ. /
GuidZZ/ 3
idZZ4 6
,ZZ6 7
UpdateTeamRequestZZ8 I
requestZZJ Q
,ZZQ R
CancellationTokenZZS d
ctZZe g
)ZZg h
{[[ 
if\\ 

(\\ 
!\\ 
TryGetClientId\\ 
(\\ 
out\\ 
var\\  #
clientId\\$ ,
)\\, -
)\\- .
return\\/ 5
Forbid\\6 <
(\\< =
)\\= >
;\\> ?
var]] 
user]] 
=]] 
await]] 
db]] 
.]] 
UserAccounts]] (
.]]( ) 
SingleOrDefaultAsync]]) =
(]]= >
x]]> ?
=>]]@ B
x]]C D
.]]D E
Id]]E G
==]]H J
id]]K M
&&]]N P
x]]Q R
.]]R S
ClientId]]S [
==]]\ ^
clientId]]_ g
,]]g h
ct]]i k
)]]k l
;]]l m
if^^ 

(^^ 
user^^ 
is^^ 
null^^ 
)^^ 
return^^  
NotFound^^! )
(^^) *
)^^* +
;^^+ ,
if__ 

(__ 
id__ 
==__ 
UserId__ 
&&__ 
(__ 
(__ 
request__ %
.__% &
Role__& *
is__+ -
UserRole__. 6
.__6 7
Cliente__7 >
)__> ?
||__@ B
request__C J
.__J K
IsActive__K S
is__T V
false__W \
)__\ ]
)__] ^
return___ e

BadRequest__f p
(__p q
new__q t
{__u v
message__w ~
=	__ Ä
$str
__Å ™
}
__´ ¨
)
__¨ ≠
;
__≠ Æ
if`` 

(`` 
request`` 
.`` 
Role`` 
is`` 
UserRole`` $
role``% )
&&``* ,
role``- 1
is``2 4
not``5 8
(``9 :
UserRole``: B
.``B C
Cliente``C J
or``K M
UserRole``N V
.``V W
Admin``W \
)``\ ]
)``] ^
return``_ e

BadRequest``f p
(``p q
)``q r
;``r s
varaa 
areaaa 
=aa 
requestaa 
.aa 
Areaaa 
?aa  
.aa  !
Trimaa! %
(aa% &
)aa& '
;aa' (
varaa) ,
jobTitleaa- 5
=aa6 7
requestaa8 ?
.aa? @
JobTitleaa@ H
?aaH I
.aaI J
TrimaaJ N
(aaN O
)aaO P
;aaP Q
ifbb 

(bb 
areabb 
?bb 
.bb 
Lengthbb 
>bb 
$numbb 
||bb !
jobTitlebb" *
?bb* +
.bb+ ,
Lengthbb, 2
>bb3 4
$numbb5 8
)bb8 9
returnbb: @

BadRequestbbA K
(bbK L
newbbL O
{bbP Q
messagebbR Y
=bbZ [
$str	bb\ ì
}
bbî ï
)
bbï ñ
;
bbñ ó
ifcc 

(cc 
requestcc 
.cc 
	ManagerIdcc 
iscc  
Guidcc! %
	managerIdcc& /
&&cc0 2
	managerIdcc3 <
!=cc= ?
Guidcc@ D
.ccD E
EmptyccE J
&&ccK M
awaitccN S 
ValidateManagerAsyncccT h
(cch i
usercci m
,ccm n
	managerIdcco x
,ccx y
clientId	ccz Ç
,
ccÇ É
ct
ccÑ Ü
)
ccÜ á
is
ccà ä
string
ccã ë
managerError
ccí û
)
ccû ü
return
cc† ¶

BadRequest
ccß ±
(
cc± ≤
new
cc≤ µ
{
cc∂ ∑
message
cc∏ ø
=
cc¿ ¡
managerError
cc¬ Œ
}
ccœ –
)
cc– —
;
cc— “
ifdd 

(dd 
requestdd 
.dd 
Roledd 
isdd 
UserRoledd $
	validRoledd% .
)dd. /
userdd0 4
.dd4 5
Roledd5 9
=dd: ;
	validRoledd< E
;ddE F
ifee 

(ee 
requestee 
.ee 
IsActiveee 
isee 
boolee  $
activeee% +
)ee+ ,
useree- 1
.ee1 2
IsActiveee2 :
=ee; <
activeee= C
;eeC D
ifff 

(ff 
areaff 
isff 
notff 
nullff 
)ff 
userff "
.ff" #
Areaff# '
=ff( )
areaff* .
.ff. /
Lengthff/ 5
==ff6 8
$numff9 :
?ff; <
nullff= A
:ffB C
areaffD H
;ffH I
ifgg 

(gg 
jobTitlegg 
isgg 
notgg 
nullgg  
)gg  !
usergg" &
.gg& '
JobTitlegg' /
=gg0 1
jobTitlegg2 :
.gg: ;
Lengthgg; A
==ggB D
$numggE F
?ggG H
nullggI M
:ggN O
jobTitleggP X
;ggX Y
ifhh 

(hh 
requesthh 
.hh 
	ManagerIdhh 
ishh  
Guidhh! %

newManagerhh& 0
)hh0 1
userhh2 6
.hh6 7
	ManagerIdhh7 @
=hhA B

newManagerhhC M
==hhN P
GuidhhQ U
.hhU V
EmptyhhV [
?hh\ ]
nullhh^ b
:hhc d

newManagerhhe o
;hho p
awaitii 
dbii 
.ii 
SaveChangesAsyncii !
(ii! "
ctii" $
)ii$ %
;ii% &
returnjj 
Okjj 
(jj 
)jj 
;jj 
}kk 
privatemm 
asyncmm 
Taskmm 
<mm 
stringmm 
?mm 
>mm  
ValidateManagerAsyncmm  4
(mm4 5
UserAccountmm5 @
usermmA E
,mmE F
GuidmmG K
	managerIdmmL U
,mmU V
GuidmmW [
clientIdmm\ d
,mmd e
CancellationTokenmmf w
ctmmx z
)mmz {
{nn 
ifoo 

(oo 
	managerIdoo 
==oo 
useroo 
.oo 
Idoo  
)oo  !
returnoo" (
$stroo) \
;oo\ ]
varpp 
managerpp 
=pp 
awaitpp 
dbpp 
.pp 
UserAccountspp +
.pp+ ,
AsNoTrackingpp, 8
(pp8 9
)pp9 :
.pp: ; 
SingleOrDefaultAsyncpp; O
(ppO P
xppP Q
=>ppR T
xppU V
.ppV W
IdppW Y
==ppZ \
	managerIdpp] f
&&ppg i
xppj k
.ppk l
ClientIdppl t
==ppu w
clientId	ppx Ä
,
ppÄ Å
ct
ppÇ Ñ
)
ppÑ Ö
;
ppÖ Ü
ifqq 

(qq 
managerqq 
isqq 
nullqq 
)qq 
returnqq #
$strqq$ Z
;qqZ [
ifrr 

(rr 
!rr 
managerrr 
.rr 
IsActiverr 
)rr 
returnrr %
$strrr& U
;rrU V
varss 
managersss 
=ss 
awaitss 
dbss 
.ss  
UserAccountsss  ,
.ss, -
AsNoTrackingss- 9
(ss9 :
)ss: ;
.ss; <
Wheress< A
(ssA B
xssB C
=>ssD F
xssG H
.ssH I
ClientIdssI Q
==ssR T
clientIdssU ]
)ss] ^
.ss^ _
ToDictionaryAsyncss_ p
(ssp q
xssq r
=>sss u
xssv w
.ssw x
Idssx z
,ssz {
xss| }
=>	ss~ Ä
x
ssÅ Ç
.
ssÇ É
	ManagerId
ssÉ å
,
sså ç
ct
ssé ê
)
ssê ë
;
ssë í
vartt 
visitedtt 
=tt 
newtt 
HashSettt !
<tt! "
Guidtt" &
>tt& '
(tt' (
)tt( )
;tt) *
foruu 
(uu 
Guiduu 
?uu 
currentuu 
=uu 
	managerIduu &
;uu& '
currentuu( /
isuu0 2
Guiduu3 7
iduu8 :
&&uu; =
visiteduu> E
.uuE F
AdduuF I
(uuI J
iduuJ L
)uuL M
;uuM N
currentuuO V
=uuW X
managersuuY a
.uua b
GetValueOrDefaultuub s
(uus t
iduut v
)uuv w
)uuw x
ifvv 
(vv 
idvv 
==vv 
uservv 
.vv 
Idvv 
)vv 
returnvv %
$strvv& h
;vvh i
returnww 
nullww 
;ww 
}xx 
}yy 
[{{ 
ApiController{{ 
,{{ 
	Authorize{{ 
({{ 
Roles{{ 
={{  !
$str{{" .
){{. /
,{{/ 0
Route{{1 6
({{6 7
$str{{7 B
){{B C
]{{C D
public|| 
sealed|| 
partial|| 
class|| 
AdminController|| +
(||+ ,
RtresDbContext||, :
db||; =
,||= >!
PayPalCheckoutService||? T
checkoutService||U d
,||d e
ExchangeRateSyncJob||f y
exchangeRateSync	||z ä
,
||ä ã 
AccessEmailService
||å û
accessEmail
||ü ™
,
||™ ´ 
TaxDocumentService
||¨ æ
taxDocuments
||ø À
,
||À Ã"
IBackgroundJobClient
||Õ ·
jobs
||‚ Ê
,
||Ê Á!
INotificationSender
||Ë ˚
notifications
||¸ â
)
||â ä
:
||ã å
ControllerBase
||ç õ
{}} 
private~~ 
Guid~~ 
UserId~~ 
=>~~ 
Guid~~ 
.~~  
Parse~~  %
(~~% &
User~~& *
.~~* +
FindFirstValue~~+ 9
(~~9 :

ClaimTypes~~: D
.~~D E
NameIdentifier~~E S
)~~S T
!~~T U
)~~U V
;~~V W
[ 
HttpGet 
( 
$str 
) 
] 
public
ÄÄ 

async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
ActionResult
ÄÄ "
>
ÄÄ" #
Tickets
ÄÄ$ +
(
ÄÄ+ ,
TicketStatus
ÄÄ, 8
?
ÄÄ8 9
status
ÄÄ: @
,
ÄÄ@ A
Guid
ÄÄB F
?
ÄÄF G
clientId
ÄÄH P
,
ÄÄP Q
Guid
ÄÄR V
?
ÄÄV W
	projectId
ÄÄX a
,
ÄÄa b
int
ÄÄc f
page
ÄÄg k
=
ÄÄl m
$num
ÄÄn o
,
ÄÄo p 
CancellationTokenÄÄq Ç
ctÄÄÉ Ö
=ÄÄÜ á
defaultÄÄà è
)ÄÄè ê
{
ÅÅ 
page
ÇÇ 
=
ÇÇ 
Math
ÇÇ 
.
ÇÇ 
Max
ÇÇ 
(
ÇÇ 
page
ÇÇ 
,
ÇÇ 
$num
ÇÇ 
)
ÇÇ  
;
ÇÇ  !
var
ÉÉ 
query
ÉÉ 
=
ÉÉ 
from
ÉÉ 
ticket
ÉÉ 
in
ÉÉ  "
db
ÉÉ# %
.
ÉÉ% &
Tickets
ÉÉ& -
join
ÑÑ 
client
ÑÑ 
in
ÑÑ  "
db
ÑÑ# %
.
ÑÑ% &
Clients
ÑÑ& -
on
ÑÑ. 0
ticket
ÑÑ1 7
.
ÑÑ7 8
ClientId
ÑÑ8 @
equals
ÑÑA G
client
ÑÑH N
.
ÑÑN O
Id
ÑÑO Q
join
ÖÖ 
project
ÖÖ  
in
ÖÖ! #
db
ÖÖ$ &
.
ÖÖ& '
Projects
ÖÖ' /
on
ÖÖ0 2
ticket
ÖÖ3 9
.
ÖÖ9 :
	ProjectId
ÖÖ: C
equals
ÖÖD J
project
ÖÖK R
.
ÖÖR S
Id
ÖÖS U
where
ÜÜ 
(
ÜÜ 
status
ÜÜ !
==
ÜÜ" $
null
ÜÜ% )
||
ÜÜ* ,
ticket
ÜÜ- 3
.
ÜÜ3 4
Status
ÜÜ4 :
==
ÜÜ; =
status
ÜÜ> D
)
ÜÜD E
&&
ÜÜF H
(
ÜÜI J
clientId
ÜÜJ R
==
ÜÜS U
null
ÜÜV Z
||
ÜÜ[ ]
ticket
ÜÜ^ d
.
ÜÜd e
ClientId
ÜÜe m
==
ÜÜn p
clientId
ÜÜq y
)
ÜÜy z
&&
ÜÜ{ }
(
ÜÜ~ 
	projectIdÜÜ à
==ÜÜâ ã
nullÜÜå ê
||ÜÜë ì
ticketÜÜî ö
.ÜÜö õ
	ProjectIdÜÜõ §
==ÜÜ• ß
	projectIdÜÜ® ±
)ÜÜ± ≤
orderby
áá 
ticket
áá "
.
áá" #
	UpdatedAt
áá# ,

descending
áá- 7
select
àà 
new
àà 
{
àà  
ticket
àà! '
,
àà' (
client
àà) /
,
àà/ 0
project
àà1 8
}
àà9 :
;
àà: ;
var
ââ 
total
ââ 
=
ââ 
await
ââ 
query
ââ 
.
ââ  

CountAsync
ââ  *
(
ââ* +
ct
ââ+ -
)
ââ- .
;
ââ. /
var
ää 
items
ää 
=
ää 
await
ää 
query
ää 
.
ää  
Skip
ää  $
(
ää$ %
(
ää% &
page
ää& *
-
ää+ ,
$num
ää- .
)
ää. /
*
ää0 1
$num
ää2 4
)
ää4 5
.
ää5 6
Take
ää6 :
(
ää: ;
$num
ää; =
)
ää= >
.
ää> ?
Select
ää? E
(
ääE F
x
ääF G
=>
ääH J
new
ääK N
{
ääO P
id
ääQ S
=
ääT U
x
ääV W
.
ääW X
ticket
ääX ^
.
ää^ _
Id
ää_ a
,
ääa b
code
ääc g
=
ääh i
x
ääj k
.
ääk l
ticket
ääl r
.
äär s
Code
ääs w
,
ääw x
clientIdääy Å
=ääÇ É
xääÑ Ö
.ääÖ Ü
ticketääÜ å
.ääå ç
ClientIdääç ï
,ääï ñ
	projectIdääó †
=ää° ¢
xää£ §
.ää§ •
ticketää• ´
.ää´ ¨
	ProjectIdää¨ µ
,ääµ ∂
typeää∑ ª
=ääº Ω
xääæ ø
.ääø ¿
ticketää¿ ∆
.ää∆ «
Typeää« À
.ääÀ Ã
ToStringääÃ ‘
(ää‘ ’
)ää’ ÷
,ää÷ ◊
statusääÿ ﬁ
=ääﬂ ‡
xää· ‚
.ää‚ „
ticketää„ È
.ääÈ Í
StatusääÍ 
.ää Ò
ToStringääÒ ˘
(ää˘ ˙
)ää˙ ˚
,ää˚ ¸
titleää˝ Ç
=ääÉ Ñ
xääÖ Ü
.ääÜ á
ticketääá ç
.ääç é
Titleääé ì
,ääì î
descriptionääï †
=ää° ¢
xää£ §
.ää§ •
ticketää• ´
.ää´ ¨
Descriptionää¨ ∑
,ää∑ ∏
	createdAtääπ ¬
=ää√ ƒ
xää≈ ∆
.ää∆ «
ticketää« Õ
.ääÕ Œ
	CreatedAtääŒ ◊
,ää◊ ÿ
	updatedAtääŸ ‚
=ää„ ‰
xääÂ Ê
.ääÊ Á
ticketääÁ Ì
.ääÌ Ó
	UpdatedAtääÓ ˜
,ää˜ ¯!
githubIssueNumberää˘ ä
=ääã å
xääç é
.ääé è
ticketääè ï
.ääï ñ!
GithubIssueNumberääñ ß
,ääß ®
githubIssueUrlää© ∑
=ää∏ π
xää∫ ª
.ääª º
ticketääº ¬
.ää¬ √
GithubIssueUrlää√ —
,ää— “
clientää” Ÿ
=ää⁄ €
newää‹ ﬂ
{ää‡ ·
idää‚ ‰
=ääÂ Ê
xääÁ Ë
.ääË È
clientääÈ Ô
.ääÔ 
Idää Ú
,ääÚ Û
nameääÙ ¯
=ää˘ ˙
xää˚ ¸
.ää¸ ˝
clientää˝ É
.ääÉ Ñ
CompanyNameääÑ è
}ääê ë
,ääë í
projectääì ö
=ääõ ú
newääù †
{ää° ¢
idää£ •
=ää¶ ß
xää® ©
.ää© ™
projectää™ ±
.ää± ≤
Idää≤ ¥
,ää¥ µ
nameää∂ ∫
=ääª º
xääΩ æ
.ääæ ø
projectääø ∆
.ää∆ «
Nameää« À
}ääÃ Õ
,ääÕ Œ
	managedInääœ ÿ
=ääŸ ⁄
dbää€ ›
.ää› ﬁ#
ProjectRepositoriesääﬁ Ò
.ääÒ Ú
AnyääÚ ı
(ääı ˆ
rääˆ ˜
=>ää¯ ˙
rää˚ ¸
.ää¸ ˝
	ProjectIdää˝ Ü
==ääá â
xäää ã
.ääã å
projectääå ì
.ääì î
Idääî ñ
)ääñ ó
?ääò ô
$strääö ¢
:ää£ §
$strää• ≠
}ääÆ Ø
)ääØ ∞
.ää∞ ±
ToListAsyncää± º
(ääº Ω
ctääΩ ø
)ääø ¿
;ää¿ ¡
return
ãã 
Ok
ãã 
(
ãã 
new
ãã 
{
ãã 
items
ãã 
,
ãã 
page
ãã #
,
ãã# $

totalPages
ãã% /
=
ãã0 1
(
ãã2 3
int
ãã3 6
)
ãã6 7
Math
ãã7 ;
.
ãã; <
Ceiling
ãã< C
(
ããC D
total
ããD I
/
ããJ K
$num
ããL O
)
ããO P
}
ããQ R
)
ããR S
;
ããS T
}
åå 
[
çç 
	HttpPatch
çç 
(
çç 
$str
çç "
)
çç" #
]
çç# $
public
éé 

async
éé 
Task
éé 
<
éé 
ActionResult
éé "
>
éé" #
UpdateTicket
éé$ 0
(
éé0 1
Guid
éé1 5
id
éé6 8
,
éé8 9'
UpdateTicketStatusRequest
éé: S
request
ééT [
,
éé[ \
CancellationToken
éé] n
ct
ééo q
)
ééq r
{
èè 
var
êê 
entry
êê 
=
êê 
await
êê 
(
êê 
from
êê 
ticket
êê  &
in
êê' )
db
êê* ,
.
êê, -
Tickets
êê- 4
join
êê5 9
project
êê: A
in
êêB D
db
êêE G
.
êêG H
Projects
êêH P
on
êêQ S
ticket
êêT Z
.
êêZ [
	ProjectId
êê[ d
equals
êêe k
project
êêl s
.
êês t
Id
êêt v
where
êêw |
ticketêê} É
.êêÉ Ñ
IdêêÑ Ü
==êêá â
idêêä å
selectêêç ì
newêêî ó
{êêò ô
ticketêêö †
,êê† °
projectêê¢ ©
}êê™ ´
)êê´ ¨
.êê¨ ≠$
SingleOrDefaultAsyncêê≠ ¡
(êê¡ ¬
ctêê¬ ƒ
)êêƒ ≈
;êê≈ ∆
ifêê« …
(êê  À
entryêêÀ –
isêê— ”
nullêê‘ ÿ
)êêÿ Ÿ
returnêê⁄ ‡
NotFoundêê· È
(êêÈ Í
)êêÍ Î
;êêÎ Ï
if
ëë 

(
ëë 
await
ëë 
db
ëë 
.
ëë !
ProjectRepositories
ëë (
.
ëë( )
AnyAsync
ëë) 1
(
ëë1 2
x
ëë2 3
=>
ëë4 6
x
ëë7 8
.
ëë8 9
	ProjectId
ëë9 B
==
ëëC E
entry
ëëF K
.
ëëK L
project
ëëL S
.
ëëS T
Id
ëëT V
,
ëëV W
ct
ëëX Z
)
ëëZ [
)
ëë[ \
return
ëë] c
Conflict
ëëd l
(
ëël m
new
ëëm p
{
ëëq r
message
ëës z
=
ëë{ |
$strëë} ≠
}ëëÆ Ø
)ëëØ ∞
;ëë∞ ±
if
íí 

(
íí 
entry
íí 
.
íí 
ticket
íí 
.
íí 
Status
íí 
==
íí  "
request
íí# *
.
íí* +
Status
íí+ 1
)
íí1 2
return
íí3 9
Ok
íí: <
(
íí< =
new
íí= @
{
ííA B
status
ííC I
=
ííJ K
entry
ííL Q
.
ííQ R
ticket
ííR X
.
ííX Y
Status
ííY _
.
íí_ `
ToString
íí` h
(
ííh i
)
ííi j
}
íík l
)
ííl m
;
íím n
entry
ìì 
.
ìì 
ticket
ìì 
.
ìì 
Status
ìì 
=
ìì 
request
ìì %
.
ìì% &
Status
ìì& ,
;
ìì, -
entry
ìì. 3
.
ìì3 4
ticket
ìì4 :
.
ìì: ;
	UpdatedAt
ìì; D
=
ììE F
DateTime
ììG O
.
ììO P
UtcNow
ììP V
;
ììV W
await
ììX ]
db
ìì^ `
.
ìì` a
SaveChangesAsync
ììa q
(
ììq r
ct
ììr t
)
ììt u
;
ììu v
var
îî 
client
îî 
=
îî 
await
îî 
db
îî 
.
îî 
Clients
îî %
.
îî% &
SingleAsync
îî& 1
(
îî1 2
x
îî2 3
=>
îî4 6
x
îî7 8
.
îî8 9
Id
îî9 ;
==
îî< >
entry
îî? D
.
îîD E
ticket
îîE K
.
îîK L
ClientId
îîL T
,
îîT U
ct
îîV X
)
îîX Y
;
îîY Z
await
ïï 
notifications
ïï 
.
ïï 
	SendAsync
ïï %
(
ïï% &
client
ïï& ,
,
ïï, -
new
ïï. 1
Notification
ïï2 >
(
ïï> ?
NotificationType
ïï? O
.
ïïO P!
TicketStatusChanged
ïïP c
,
ïïc d
new
ïïe h
(
ïïh i
)
ïïi j
{
ïïk l
[
ïïm n
$str
ïïn x
]
ïïx y
=
ïïz {
entryïï| Å
.ïïÅ Ç
ticketïïÇ à
.ïïà â
Idïïâ ã
.ïïã å
ToStringïïå î
(ïïî ï
)ïïï ñ
,ïïñ ó
[ïïò ô
$strïïô ü
]ïïü †
=ïï° ¢
entryïï£ ®
.ïï® ©
ticketïï© Ø
.ïïØ ∞
Codeïï∞ ¥
,ïï¥ µ
[ïï∂ ∑
$strïï∑ æ
]ïïæ ø
=ïï¿ ¡
entryïï¬ «
.ïï« »
ticketïï» Œ
.ïïŒ œ
Titleïïœ ‘
,ïï‘ ’
[ïï÷ ◊
$strïï◊ ﬂ
]ïïﬂ ‡
=ïï· ‚
entryïï„ Ë
.ïïË È
ticketïïÈ Ô
.ïïÔ 
Statusïï ˆ
.ïïˆ ˜
ToStringïï˜ ˇ
(ïïˇ Ä
)ïïÄ Å
}ïïÇ É
,ïïÉ Ñ
$"ïïÖ á
$strïïá ï
{ïïï ñ
entryïïñ õ
.ïïõ ú
ticketïïú ¢
.ïï¢ £
Idïï£ •
}ïï• ¶
$strïï¶ ß
{ïïß ®
entryïï® ≠
.ïï≠ Æ
ticketïïÆ ¥
.ïï¥ µ
	UpdatedAtïïµ æ
.ïïæ ø
Ticksïïø ƒ
}ïïƒ ≈
"ïï≈ ∆
)ïï∆ «
,ïï« »
ctïï… À
)ïïÀ Ã
;ïïÃ Õ
return
ññ 
Ok
ññ 
(
ññ 
new
ññ 
{
ññ 
status
ññ 
=
ññ  
entry
ññ! &
.
ññ& '
ticket
ññ' -
.
ññ- .
Status
ññ. 4
.
ññ4 5
ToString
ññ5 =
(
ññ= >
)
ññ> ?
}
ññ@ A
)
ññA B
;
ññB C
}
óó 
[
òò 
HttpPost
òò 
(
òò 
$str
òò *
)
òò* +
]
òò+ ,
public
ôô 

async
ôô 
Task
ôô 
<
ôô 
ActionResult
ôô "
>
ôô" #
AddTicketComment
ôô$ 4
(
ôô4 5
Guid
ôô5 9
id
ôô: <
,
ôô< =(
CreateTicketCommentRequest
ôô> X
request
ôôY `
,
ôô` a
CancellationToken
ôôb s
ct
ôôt v
)
ôôv w
{
öö 
if
õõ 

(
õõ 
string
õõ 
.
õõ  
IsNullOrWhiteSpace
õõ %
(
õõ% &
request
õõ& -
.
õõ- .
Body
õõ. 2
)
õõ2 3
)
õõ3 4
return
õõ5 ;

BadRequest
õõ< F
(
õõF G
new
õõG J
{
õõK L
message
õõM T
=
õõU V
$str
õõW |
}
õõ} ~
)
õõ~ 
;õõ Ä
var
úú 
entry
úú 
=
úú 
await
úú 
(
úú 
from
úú 
ticket
úú  &
in
úú' )
db
úú* ,
.
úú, -
Tickets
úú- 4
join
úú5 9
project
úú: A
in
úúB D
db
úúE G
.
úúG H
Projects
úúH P
on
úúQ S
ticket
úúT Z
.
úúZ [
	ProjectId
úú[ d
equals
úúe k
project
úúl s
.
úús t
Id
úút v
where
úúw |
ticketúú} É
.úúÉ Ñ
IdúúÑ Ü
==úúá â
idúúä å
selectúúç ì
newúúî ó
{úúò ô
ticketúúö †
,úú† °
projectúú¢ ©
}úú™ ´
)úú´ ¨
.úú¨ ≠$
SingleOrDefaultAsyncúú≠ ¡
(úú¡ ¬
ctúú¬ ƒ
)úúƒ ≈
;úú≈ ∆
ifúú« …
(úú  À
entryúúÀ –
isúú— ”
nullúú‘ ÿ
)úúÿ Ÿ
returnúú⁄ ‡
NotFoundúú· È
(úúÈ Í
)úúÍ Î
;úúÎ Ï
var
ùù 
comment
ùù 
=
ùù 
new
ùù 
TicketComment
ùù '
{
ùù( )
TicketId
ùù* 2
=
ùù3 4
id
ùù5 7
,
ùù7 8
AuthorUserId
ùù9 E
=
ùùF G
UserId
ùùH N
,
ùùN O
Body
ùùP T
=
ùùU V
request
ùùW ^
.
ùù^ _
Body
ùù_ c
.
ùùc d
Trim
ùùd h
(
ùùh i
)
ùùi j
}
ùùk l
;
ùùl m
db
ùùn p
.
ùùp q
TicketComments
ùùq 
.ùù Ä
AddùùÄ É
(ùùÉ Ñ
commentùùÑ ã
)ùùã å
;ùùå ç
entryùùé ì
.ùùì î
ticketùùî ö
.ùùö õ
	UpdatedAtùùõ §
=ùù• ¶
DateTimeùùß Ø
.ùùØ ∞
UtcNowùù∞ ∂
;ùù∂ ∑
awaitùù∏ Ω
dbùùæ ¿
.ùù¿ ¡ 
SaveChangesAsyncùù¡ —
(ùù— “
ctùù“ ‘
)ùù‘ ’
;ùù’ ÷
if
ûû 

(
ûû 
await
ûû 
db
ûû 
.
ûû !
ProjectRepositories
ûû (
.
ûû( )
AnyAsync
ûû) 1
(
ûû1 2
x
ûû2 3
=>
ûû4 6
x
ûû7 8
.
ûû8 9
	ProjectId
ûû9 B
==
ûûC E
entry
ûûF K
.
ûûK L
project
ûûL S
.
ûûS T
Id
ûûT V
,
ûûV W
ct
ûûX Z
)
ûûZ [
)
ûû[ \
jobs
ûû] a
.
ûûa b
Enqueue
ûûb i
<
ûûi j 
GitHubIssueSyncJob
ûûj |
>
ûû| }
(
ûû} ~
j
ûû~ 
=>ûûÄ Ç
jûûÉ Ñ
.ûûÑ Ö 
PostCommentAsyncûûÖ ï
(ûûï ñ
commentûûñ ù
.ûûù û
Idûûû †
,ûû† °!
CancellationTokenûû¢ ≥
.ûû≥ ¥
Noneûû¥ ∏
)ûû∏ π
)ûûπ ∫
;ûû∫ ª
var
üü 
client
üü 
=
üü 
await
üü 
db
üü 
.
üü 
Clients
üü %
.
üü% &
SingleAsync
üü& 1
(
üü1 2
x
üü2 3
=>
üü4 6
x
üü7 8
.
üü8 9
Id
üü9 ;
==
üü< >
entry
üü? D
.
üüD E
ticket
üüE K
.
üüK L
ClientId
üüL T
,
üüT U
ct
üüV X
)
üüX Y
;
üüY Z
await
†† 
notifications
†† 
.
†† 
	SendAsync
†† %
(
††% &
client
††& ,
,
††, -
new
††. 1
Notification
††2 >
(
††> ?
NotificationType
††? O
.
††O P
TicketReply
††P [
,
††[ \
new
††] `
(
††` a
)
††a b
{
††c d
[
††e f
$str
††f p
]
††p q
=
††r s
entry
††t y
.
††y z
ticket††z Ä
.††Ä Å
Id††Å É
.††É Ñ
ToString††Ñ å
(††å ç
)††ç é
,††é è
[††ê ë
$str††ë ó
]††ó ò
=††ô ö
entry††õ †
.††† °
ticket††° ß
.††ß ®
Code††® ¨
,††¨ ≠
[††Æ Ø
$str††Ø ∂
]††∂ ∑
=††∏ π
entry††∫ ø
.††ø ¿
ticket††¿ ∆
.††∆ «
Title††« Ã
,††Ã Õ
[††Œ œ
$str††œ ◊
]††◊ ÿ
=††Ÿ ⁄
$str††€ ‚
,††‚ „
[††‰ Â
$str††Â Î
]††Î Ï
=††Ì Ó
comment††Ô ˆ
.††ˆ ˜
Body††˜ ˚
}††¸ ˝
,††˝ ˛
$"††ˇ Å
$str††Å ï
{††ï ñ
comment††ñ ù
.††ù û
Id††û †
}††† °
"††° ¢
)††¢ £
,††£ §
ct††• ß
)††ß ®
;††® ©
return
°° 
Ok
°° 
(
°° 
await
°° 
PortalController
°° (
.
°°( )
ToCommentDtos
°°) 6
(
°°6 7
db
°°7 9
,
°°9 :
db
°°; =
.
°°= >
TicketComments
°°> L
.
°°L M
Where
°°M R
(
°°R S
x
°°S T
=>
°°U W
x
°°X Y
.
°°Y Z
Id
°°Z \
==
°°] _
comment
°°` g
.
°°g h
Id
°°h j
)
°°j k
)
°°k l
.
°°l m
SingleAsync
°°m x
(
°°x y
ct
°°y {
)
°°{ |
)
°°| }
;
°°} ~
}
¢¢ 
[
££ 
HttpGet
££ 
(
££ 
$str
££ 
)
££ 
]
££ 
public
§§ 

async
§§ 
Task
§§ 
<
§§ 
ActionResult
§§ "
>
§§" #
ExchangeRates
§§$ 1
(
§§1 2
DateOnly
§§2 :
?
§§: ;
from
§§< @
,
§§@ A
DateOnly
§§B J
?
§§J K
to
§§L N
,
§§N O
CancellationToken
§§P a
ct
§§b d
)
§§d e
=>
§§f h
Ok
§§i k
(
§§k l
await
§§l q
db
§§r t
.
§§t u
ExchangeRates§§u Ç
.
•• 	
Where
••	 
(
•• 
x
•• 
=>
•• 
(
•• 
from
•• 
==
•• 
null
•• !
||
••" $
x
••% &
.
••& '
Date
••' +
>=
••, .
from
••/ 3
)
••3 4
&&
••5 7
(
••8 9
to
••9 ;
==
••< >
null
••? C
||
••D F
x
••G H
.
••H I
Date
••I M
<=
••N P
to
••Q S
)
••S T
)
••T U
.
••U V
OrderByDescending
••V g
(
••g h
x
••h i
=>
••j l
x
••m n
.
••n o
Date
••o s
)
••s t
.
¶¶ 	
Select
¶¶	 
(
¶¶ 
x
¶¶ 
=>
¶¶ 
new
¶¶ 
{
¶¶ 
date
¶¶ 
=
¶¶  !
x
¶¶" #
.
¶¶# $
Date
¶¶$ (
,
¶¶( )
currencyCode
¶¶* 6
=
¶¶7 8
x
¶¶9 :
.
¶¶: ;
CurrencyCode
¶¶; G
,
¶¶G H
	rateToPen
¶¶I R
=
¶¶S T
x
¶¶U V
.
¶¶V W
	RateToPen
¶¶W `
,
¶¶` a
source
¶¶b h
=
¶¶i j
x
¶¶k l
.
¶¶l m
Source
¶¶m s
}
¶¶t u
)
¶¶u v
.
¶¶v w
ToListAsync¶¶w Ç
(¶¶Ç É
ct¶¶É Ö
)¶¶Ö Ü
)¶¶Ü á
;¶¶á à
[
®® 
HttpPost
®® 
(
®® 
$str
®® #
)
®®# $
]
®®$ %
public
©© 

async
©© 
Task
©© 
<
©© 
ActionResult
©© "
>
©©" #
SyncExchangeRates
©©$ 5
(
©©5 6
CancellationToken
©©6 G
ct
©©H J
)
©©J K
{
™™ 
await
´´ 
exchangeRateSync
´´ 
.
´´ 
	SyncAsync
´´ (
(
´´( )
ct
´´) +
)
´´+ ,
;
´´, -
return
¨¨ 
Ok
¨¨ 
(
¨¨ 
await
¨¨ 
db
¨¨ 
.
¨¨ 
ExchangeRates
¨¨ (
.
¨¨( )
OrderByDescending
¨¨) :
(
¨¨: ;
x
¨¨; <
=>
¨¨= ?
x
¨¨@ A
.
¨¨A B
Date
¨¨B F
)
¨¨F G
.
¨¨G H
Take
¨¨H L
(
¨¨L M
$num
¨¨M N
)
¨¨N O
.
¨¨O P
Select
¨¨P V
(
¨¨V W
x
¨¨W X
=>
¨¨Y [
new
¨¨\ _
{
¨¨` a
date
¨¨b f
=
¨¨g h
x
¨¨i j
.
¨¨j k
Date
¨¨k o
,
¨¨o p
currencyCode
¨¨q }
=
¨¨~ 
x¨¨Ä Å
.¨¨Å Ç
CurrencyCode¨¨Ç é
,¨¨é è
	rateToPen¨¨ê ô
=¨¨ö õ
x¨¨ú ù
.¨¨ù û
	RateToPen¨¨û ß
,¨¨ß ®
source¨¨© Ø
=¨¨∞ ±
x¨¨≤ ≥
.¨¨≥ ¥
Source¨¨¥ ∫
}¨¨ª º
)¨¨º Ω
.¨¨Ω æ
ToListAsync¨¨æ …
(¨¨…  
ct¨¨  Ã
)¨¨Ã Õ
)¨¨Õ Œ
;¨¨Œ œ
}
≠≠ 
[
ØØ 
HttpGet
ØØ 
(
ØØ 
$str
ØØ 
)
ØØ 
]
ØØ 
public
∞∞ 

async
∞∞ 
Task
∞∞ 
<
∞∞ 
ActionResult
∞∞ "
>
∞∞" #
TaxSettings
∞∞$ /
(
∞∞/ 0
CancellationToken
∞∞0 A
ct
∞∞B D
)
∞∞D E
=>
∞∞F H
Ok
∞∞I K
(
∞∞K L
TaxSettingsDto
∞∞L Z
(
∞∞Z [
await
∞∞[ `
TaxSettingsRow
∞∞a o
(
∞∞o p
ct
∞∞p r
)
∞∞r s
)
∞∞s t
)
∞∞t u
;
∞∞u v
[
≤≤ 
	HttpPatch
≤≤ 
(
≤≤ 
$str
≤≤ 
)
≤≤ 
]
≤≤ 
public
≥≥ 

async
≥≥ 
Task
≥≥ 
<
≥≥ 
ActionResult
≥≥ "
>
≥≥" #
UpdateTaxSettings
≥≥$ 5
(
≥≥5 6 
TaxSettingsRequest
≥≥6 H
request
≥≥I P
,
≥≥P Q
CancellationToken
≥≥R c
ct
≥≥d f
)
≥≥f g
{
¥¥ 
if
µµ 

(
µµ 
request
µµ 
.
µµ 
IgvRate
µµ 
is
µµ 
decimal
µµ &
igv
µµ' *
&&
µµ+ -
(
µµ. /
igv
µµ/ 2
<
µµ3 4
$num
µµ5 6
||
µµ7 9
igv
µµ: =
>
µµ> ?
$num
µµ@ A
)
µµA B
||
µµC E
request
µµF M
.
µµM N
	RentaRate
µµN W
is
µµX Z
decimal
µµ[ b
renta0
µµc i
&&
µµj l
(
µµm n
renta0
µµn t
<
µµu v
$num
µµw x
||
µµy {
renta0µµ| Ç
>µµÉ Ñ
$numµµÖ Ü
)µµÜ á
)µµá à
returnµµâ è

BadRequestµµê ö
(µµö õ
newµµõ û
{µµü †
messageµµ° ®
=µµ© ™
$strµµ´ „
}µµ‰ Â
)µµÂ Ê
;µµÊ Á
var
∂∂ 
settings
∂∂ 
=
∂∂ 
await
∂∂ 
TaxSettingsRow
∂∂ +
(
∂∂+ ,
ct
∂∂, .
)
∂∂. /
;
∂∂/ 0
var
∑∑ 
facturaSeries
∑∑ 
=
∑∑ 
request
∑∑ #
.
∑∑# $
FacturaSeries
∑∑$ 1
?
∑∑1 2
.
∑∑2 3
Trim
∑∑3 7
(
∑∑7 8
)
∑∑8 9
.
∑∑9 :
ToUpperInvariant
∑∑: J
(
∑∑J K
)
∑∑K L
??
∑∑M O
settings
∑∑P X
.
∑∑X Y
FacturaSeries
∑∑Y f
;
∑∑f g
var
∑∑h k
reciboSeries
∑∑l x
=
∑∑y z
request∑∑{ Ç
.∑∑Ç É
ReciboSeries∑∑É è
?∑∑è ê
.∑∑ê ë
Trim∑∑ë ï
(∑∑ï ñ
)∑∑ñ ó
.∑∑ó ò 
ToUpperInvariant∑∑ò ®
(∑∑® ©
)∑∑© ™
??∑∑´ ≠
settings∑∑Æ ∂
.∑∑∂ ∑
ReciboSeries∑∑∑ √
;∑∑√ ƒ
var
∏∏ 
facturaNext
∏∏ 
=
∏∏ 
request
∏∏ !
.
∏∏! "
FacturaNextNumber
∏∏" 3
??
∏∏4 6
settings
∏∏7 ?
.
∏∏? @
FacturaNextNumber
∏∏@ Q
;
∏∏Q R
var
∏∏S V

reciboNext
∏∏W a
=
∏∏b c
request
∏∏d k
.
∏∏k l
ReciboNextNumber
∏∏l |
??
∏∏} 
settings∏∏Ä à
.∏∏à â 
ReciboNextNumber∏∏â ô
;∏∏ô ö
if
ππ 

(
ππ 
await
ππ !
ValidateSeriesAsync
ππ %
(
ππ% &
facturaSeries
ππ& 3
,
ππ3 4
facturaNext
ππ5 @
,
ππ@ A
reciboSeries
ππB N
,
ππN O

reciboNext
ππP Z
,
ππZ [
ct
ππ\ ^
)
ππ^ _
is
ππ` b
string
ππc i
seriesError
ππj u
)
ππu v
return
ππw }

BadRequestππ~ à
(ππà â
newππâ å
{ππç é
messageππè ñ
=ππó ò
seriesErrorππô §
}ππ• ¶
)ππ¶ ß
;ππß ®
var
∫∫ 
ruc
∫∫ 
=
∫∫ 
request
∫∫ 
.
∫∫ 
Ruc
∫∫ 
is
∫∫  
null
∫∫! %
?
∫∫& '
settings
∫∫( 0
.
∫∫0 1
Ruc
∫∫1 4
:
∫∫5 6
EmptyToNull
∫∫7 B
(
∫∫B C
request
∫∫C J
.
∫∫J K
Ruc
∫∫K N
)
∫∫N O
;
∫∫O P
if
ªª 

(
ªª 
ruc
ªª 
is
ªª 
not
ªª 
null
ªª 
&&
ªª 
!
ªª  
Regex
ªª  %
.
ªª% &
IsMatch
ªª& -
(
ªª- .
ruc
ªª. 1
,
ªª1 2
$str
ªª3 L
)
ªªL M
)
ªªM N
return
ªªO U

BadRequest
ªªV `
(
ªª` a
new
ªªa d
{
ªªe f
message
ªªg n
=
ªªo p
$strªªq ©
}ªª™ ´
)ªª´ ¨
;ªª¨ ≠
settings
ºº 
.
ºº 
Ruc
ºº 
=
ºº 
ruc
ºº 
;
ºº 
if
ΩΩ 

(
ΩΩ 
request
ΩΩ 
.
ΩΩ 
IsGoodTaxpayer
ΩΩ "
is
ΩΩ# %
bool
ΩΩ& *
goodTaxpayer
ΩΩ+ 7
)
ΩΩ7 8
settings
ΩΩ9 A
.
ΩΩA B
IsGoodTaxpayer
ΩΩB P
=
ΩΩQ R
goodTaxpayer
ΩΩS _
;
ΩΩ_ `
if
ææ 

(
ææ 
request
ææ 
.
ææ 
Use1662AsCredit
ææ #
is
ææ$ &
bool
ææ' +
use1662
ææ, 3
)
ææ3 4
settings
ææ5 =
.
ææ= >
Use1662AsCredit
ææ> M
=
ææN O
use1662
ææP W
;
ææW X
if
øø 

(
øø 
request
øø 
.
øø 
IgvRate
øø 
is
øø 
decimal
øø &
igvRate
øø' .
)
øø. /
settings
øø0 8
.
øø8 9
IgvRate
øø9 @
=
øøA B
igvRate
øøC J
;
øøJ K
if
¿¿ 

(
¿¿ 
request
¿¿ 
.
¿¿ 
	RentaRate
¿¿ 
is
¿¿  
decimal
¿¿! (
	rentaRate
¿¿) 2
)
¿¿2 3
settings
¿¿4 <
.
¿¿< =
	RentaRate
¿¿= F
=
¿¿G H
	rentaRate
¿¿I R
;
¿¿R S
(
¡¡ 	
settings
¡¡	 
.
¡¡ 
FacturaSeries
¡¡ 
,
¡¡  
settings
¡¡! )
.
¡¡) *
FacturaNextNumber
¡¡* ;
,
¡¡; <
settings
¡¡= E
.
¡¡E F
ReciboSeries
¡¡F R
,
¡¡R S
settings
¡¡T \
.
¡¡\ ]
ReciboNextNumber
¡¡] m
)
¡¡m n
=
¡¡o p
(
¡¡q r
facturaSeries
¡¡r 
,¡¡ Ä
facturaNext¡¡Å å
,¡¡å ç
reciboSeries¡¡é ö
,¡¡ö õ

reciboNext¡¡ú ¶
)¡¡¶ ß
;¡¡ß ®
settings
¬¬ 
.
¬¬ 
	UpdatedAt
¬¬ 
=
¬¬ 
DateTime
¬¬ %
.
¬¬% &
UtcNow
¬¬& ,
;
¬¬, -
await
√√ 
db
√√ 
.
√√ 
SaveChangesAsync
√√ !
(
√√! "
ct
√√" $
)
√√$ %
;
√√% &
return
ƒƒ 
Ok
ƒƒ 
(
ƒƒ 
TaxSettingsDto
ƒƒ  
(
ƒƒ  !
settings
ƒƒ! )
)
ƒƒ) *
)
ƒƒ* +
;
ƒƒ+ ,
}
≈≈ 
private
«« 
async
«« 
Task
«« 
<
«« 
string
«« 
?
«« 
>
«« !
ValidateSeriesAsync
««  3
(
««3 4
string
««4 :
facturaSeries
««; H
,
««H I
int
««J M
facturaNext
««N Y
,
««Y Z
string
««[ a
reciboSeries
««b n
,
««n o
int
««p s

reciboNext
««t ~
,
««~ !
CancellationToken««Ä ë
ct««í î
)««î ï
{
»» 
if
ÀÀ 

(
ÀÀ 
!
ÀÀ 
Regex
ÀÀ 
.
ÀÀ 
IsMatch
ÀÀ 
(
ÀÀ 
facturaSeries
ÀÀ (
,
ÀÀ( )
$str
ÀÀ* =
)
ÀÀ= >
||
ÀÀ? A
!
ÀÀB C
Regex
ÀÀC H
.
ÀÀH I
IsMatch
ÀÀI P
(
ÀÀP Q
reciboSeries
ÀÀQ ]
,
ÀÀ] ^
$str
ÀÀ_ o
)
ÀÀo p
)
ÀÀp q
return
ÀÀr x
$strÀÀy ô
;ÀÀô ö
if
ÃÃ 

(
ÃÃ 
facturaNext
ÃÃ 
<
ÃÃ 
$num
ÃÃ 
||
ÃÃ 

reciboNext
ÃÃ )
<
ÃÃ* +
$num
ÃÃ, -
)
ÃÃ- .
return
ÃÃ/ 5
$str
ÃÃ6 b
;
ÃÃb c
if
ŒŒ 

(
ŒŒ 
await
ŒŒ 
LastNumberAsync
ŒŒ !
(
ŒŒ! "
TaxDocumentType
ŒŒ" 1
.
ŒŒ1 2
Factura
ŒŒ2 9
,
ŒŒ9 :
facturaSeries
ŒŒ; H
,
ŒŒH I
ct
ŒŒJ L
)
ŒŒL M
is
ŒŒN P
int
ŒŒQ T
lastF
ŒŒU Z
&&
ŒŒ[ ]
facturaNext
ŒŒ^ i
<=
ŒŒj l
lastF
ŒŒm r
)
ŒŒr s
return
ŒŒt z
$"
ŒŒ{ }
$strŒŒ} Ü
{ŒŒÜ á
facturaSeriesŒŒá î
}ŒŒî ï
$strŒŒï Æ
{ŒŒÆ Ø
lastFŒŒØ ¥
}ŒŒ¥ µ
$strŒŒµ ›
"ŒŒ› ﬁ
;ŒŒﬁ ﬂ
if
œœ 

(
œœ 
await
œœ 
LastNumberAsync
œœ !
(
œœ! "
TaxDocumentType
œœ" 1
.
œœ1 2!
ReciboPorHonorarios
œœ2 E
,
œœE F
reciboSeries
œœG S
,
œœS T
ct
œœU W
)
œœW X
is
œœY [
int
œœ\ _
lastR
œœ` e
&&
œœf h

reciboNext
œœi s
<=
œœt v
lastR
œœw |
)
œœ| }
returnœœ~ Ñ
$"œœÖ á
$strœœá ê
{œœê ë
reciboSeriesœœë ù
}œœù û
$strœœû ∂
{œœ∂ ∑
lastRœœ∑ º
}œœº Ω
$strœœΩ Â
"œœÂ Ê
;œœÊ Á
return
–– 
null
–– 
;
–– 
}
—— 
private
”” 
Task
”” 
<
”” 
int
”” 
?
”” 
>
”” 
LastNumberAsync
”” &
(
””& '
TaxDocumentType
””' 6
type
””7 ;
,
””; <
string
””= C
series
””D J
,
””J K
CancellationToken
””L ]
ct
””^ `
)
””` a
=>
””b d
db
””e g
.
””g h
TaxDocuments
””h t
.
””t u
Where
””u z
(
””z {
x
””{ |
=>
””} 
x””Ä Å
.””Å Ç
Type””Ç Ü
==””á â
type””ä é
&&””è ë
x””í ì
.””ì î
Series””î ö
==””õ ù
series””û §
)””§ •
.””• ¶
MaxAsync””¶ Æ
(””Æ Ø
x””Ø ∞
=>””± ≥
(””¥ µ
int””µ ∏
?””∏ π
)””π ∫
x””∫ ª
.””ª º
Number””º ¬
,””¬ √
ct””ƒ ∆
)””∆ «
;””« »
private
‘‘ 
static
‘‘ 
object
‘‘ 
TaxSettingsDto
‘‘ (
(
‘‘( )
TaxSettings
‘‘) 4
x
‘‘5 6
)
‘‘6 7
=>
‘‘8 :
new
‘‘; >
{
‘‘? @
igvRate
‘‘A H
=
‘‘I J
x
‘‘K L
.
‘‘L M
IgvRate
‘‘M T
,
‘‘T U
	rentaRate
‘‘V _
=
‘‘` a
x
‘‘b c
.
‘‘c d
	RentaRate
‘‘d m
,
‘‘m n
facturaSeries
‘‘o |
=
‘‘} ~
x‘‘ Ä
.‘‘Ä Å
FacturaSeries‘‘Å é
,‘‘é è!
facturaNextNumber‘‘ê °
=‘‘¢ £
x‘‘§ •
.‘‘• ¶!
FacturaNextNumber‘‘¶ ∑
,‘‘∑ ∏
reciboSeries‘‘π ≈
=‘‘∆ «
x‘‘» …
.‘‘…  
ReciboSeries‘‘  ÷
,‘‘÷ ◊ 
reciboNextNumber‘‘ÿ Ë
=‘‘È Í
x‘‘Î Ï
.‘‘Ï Ì 
ReciboNextNumber‘‘Ì ˝
,‘‘˝ ˛
ruc‘‘ˇ Ç
=‘‘É Ñ
x‘‘Ö Ü
.‘‘Ü á
Ruc‘‘á ä
,‘‘ä ã
isGoodTaxpayer‘‘å ö
=‘‘õ ú
x‘‘ù û
.‘‘û ü
IsGoodTaxpayer‘‘ü ≠
,‘‘≠ Æ
use1662AsCredit‘‘Ø æ
=‘‘ø ¿
x‘‘¡ ¬
.‘‘¬ √
Use1662AsCredit‘‘√ “
}‘‘” ‘
;‘‘‘ ’
private
÷÷ 
async
÷÷ 
Task
÷÷ 
<
÷÷ 
TaxSettings
÷÷ "
>
÷÷" #
TaxSettingsRow
÷÷$ 2
(
÷÷2 3
CancellationToken
÷÷3 D
ct
÷÷E G
)
÷÷G H
{
◊◊ 
var
ÿÿ 
settings
ÿÿ 
=
ÿÿ 
await
ÿÿ 
db
ÿÿ 
.
ÿÿ  
TaxSettings
ÿÿ  +
.
ÿÿ+ ,!
FirstOrDefaultAsync
ÿÿ, ?
(
ÿÿ? @
ct
ÿÿ@ B
)
ÿÿB C
;
ÿÿC D
if
ŸŸ 

(
ŸŸ 
settings
ŸŸ 
is
ŸŸ 
not
ŸŸ 
null
ŸŸ  
)
ŸŸ  !
return
ŸŸ" (
settings
ŸŸ) 1
;
ŸŸ1 2
settings
⁄⁄ 
=
⁄⁄ 
new
⁄⁄ 
TaxSettings
⁄⁄ "
(
⁄⁄" #
)
⁄⁄# $
;
⁄⁄$ %
db
⁄⁄& (
.
⁄⁄( )
TaxSettings
⁄⁄) 4
.
⁄⁄4 5
Add
⁄⁄5 8
(
⁄⁄8 9
settings
⁄⁄9 A
)
⁄⁄A B
;
⁄⁄B C
await
⁄⁄D I
db
⁄⁄J L
.
⁄⁄L M
SaveChangesAsync
⁄⁄M ]
(
⁄⁄] ^
ct
⁄⁄^ `
)
⁄⁄` a
;
⁄⁄a b
return
⁄⁄c i
settings
⁄⁄j r
;
⁄⁄r s
}
€€ 
[
›› 
HttpGet
›› 
(
›› 
$str
›› 
)
›› 
]
›› 
public
ﬁﬁ 

async
ﬁﬁ 
Task
ﬁﬁ 
<
ﬁﬁ 
ActionResult
ﬁﬁ "
>
ﬁﬁ" #
TaxDocuments
ﬁﬁ$ 0
(
ﬁﬁ0 1
Guid
ﬁﬁ1 5
?
ﬁﬁ5 6
clientId
ﬁﬁ7 ?
,
ﬁﬁ? @
int
ﬁﬁA D
?
ﬁﬁD E
month
ﬁﬁF K
,
ﬁﬁK L
int
ﬁﬁM P
?
ﬁﬁP Q
year
ﬁﬁR V
,
ﬁﬁV W
CancellationToken
ﬁﬁX i
ct
ﬁﬁj l
)
ﬁﬁl m
{
ﬂﬂ 
var
‡‡ 
rows
‡‡ 
=
‡‡ 
await
‡‡ 
db
‡‡ 
.
‡‡ 
TaxDocuments
‡‡ (
.
·· 
Where
·· 
(
·· 
x
·· 
=>
·· 
(
·· 
clientId
·· !
==
··" $
null
··% )
||
··* ,
x
··- .
.
··. /
ClientId
··/ 7
==
··8 :
clientId
··; C
)
··C D
&&
··E G
(
··H I
month
··I N
==
··O Q
null
··R V
||
··W Y
x
··Z [
.
··[ \
	IssueDate
··\ e
.
··e f
Month
··f k
==
··l n
month
··o t
)
··t u
&&
··v x
(
··y z
year
··z ~
==·· Å
null··Ç Ü
||··á â
x··ä ã
.··ã å
	IssueDate··å ï
.··ï ñ
Year··ñ ö
==··õ ù
year··û ¢
)··¢ £
)··£ §
.
‚‚ 
OrderByDescending
‚‚ 
(
‚‚ 
x
‚‚  
=>
‚‚! #
x
‚‚$ %
.
‚‚% &
	IssueDate
‚‚& /
)
‚‚/ 0
.
‚‚0 1
ThenByDescending
‚‚1 A
(
‚‚A B
x
‚‚B C
=>
‚‚D F
x
‚‚G H
.
‚‚H I
Number
‚‚I O
)
‚‚O P
.
„„ 
Select
„„ 
(
„„ 
x
„„ 
=>
„„ 
new
„„ 
{
„„ 
Document
„„ '
=
„„( )
x
„„* +
,
„„+ ,
Payment
„„- 4
=
„„5 6
db
„„7 9
.
„„9 :!
PaymentTransactions
„„: M
.
„„M N
Where
„„N S
(
„„S T
p
„„T U
=>
„„V X
p
„„Y Z
.
„„Z [
Id
„„[ ]
==
„„^ `
x
„„a b
.
„„b c"
PaymentTransactionId
„„c w
)
„„w x
.
„„x y
Select
„„y 
(„„ Ä
p„„Ä Å
=>„„Ç Ñ
new„„Ö à
{„„â ä
p„„ã å
.„„å ç
Amount„„ç ì
,„„ì î
p„„ï ñ
.„„ñ ó
	AmountPen„„ó †
,„„† °
p„„¢ £
.„„£ §
Method„„§ ™
}„„´ ¨
)„„¨ ≠
.„„≠ Æ
FirstOrDefault„„Æ º
(„„º Ω
)„„Ω æ
}„„ø ¿
)„„¿ ¡
.
‰‰ 
ToListAsync
‰‰ 
(
‰‰ 
ct
‰‰ 
)
‰‰ 
;
‰‰ 
var
ÂÂ 
docIds
ÂÂ 
=
ÂÂ 
rows
ÂÂ 
.
ÂÂ 
Select
ÂÂ  
(
ÂÂ  !
x
ÂÂ! "
=>
ÂÂ# %
x
ÂÂ& '
.
ÂÂ' (
Document
ÂÂ( 0
.
ÂÂ0 1
Id
ÂÂ1 3
)
ÂÂ3 4
.
ÂÂ4 5
ToList
ÂÂ5 ;
(
ÂÂ; <
)
ÂÂ< =
;
ÂÂ= >
var
ÊÊ 
lines
ÊÊ 
=
ÊÊ 
(
ÊÊ 
await
ÊÊ 
db
ÊÊ 
.
ÊÊ 
TaxDocumentLines
ÊÊ .
.
ÊÊ. /
Where
ÊÊ/ 4
(
ÊÊ4 5
x
ÊÊ5 6
=>
ÊÊ7 9
docIds
ÊÊ: @
.
ÊÊ@ A
Contains
ÊÊA I
(
ÊÊI J
x
ÊÊJ K
.
ÊÊK L
TaxDocumentId
ÊÊL Y
)
ÊÊY Z
)
ÊÊZ [
.
ÊÊ[ \
OrderBy
ÊÊ\ c
(
ÊÊc d
x
ÊÊd e
=>
ÊÊf h
x
ÊÊi j
.
ÊÊj k
Order
ÊÊk p
)
ÊÊp q
.
ÊÊq r
ToListAsync
ÊÊr }
(
ÊÊ} ~
ctÊÊ~ Ä
)ÊÊÄ Å
)ÊÊÅ Ç
.ÊÊÇ É
ToLookupÊÊÉ ã
(ÊÊã å
xÊÊå ç
=>ÊÊé ê
xÊÊë í
.ÊÊí ì
TaxDocumentIdÊÊì †
)ÊÊ† °
;ÊÊ° ¢
var
ÁÁ 
result
ÁÁ 
=
ÁÁ 
new
ÁÁ 
List
ÁÁ 
<
ÁÁ 
object
ÁÁ $
>
ÁÁ$ %
(
ÁÁ% &
rows
ÁÁ& *
.
ÁÁ* +
Count
ÁÁ+ 0
)
ÁÁ0 1
;
ÁÁ1 2
foreach
ËË 
(
ËË 
var
ËË 
x
ËË 
in
ËË 
rows
ËË 
)
ËË 
{
ÈÈ 	
var
ÎÎ 
rate
ÎÎ 
=
ÎÎ 
x
ÎÎ 
.
ÎÎ 
Payment
ÎÎ  
is
ÎÎ! #
{
ÎÎ$ %
Amount
ÎÎ& ,
:
ÎÎ, -
>
ÎÎ. /
$num
ÎÎ0 1
}
ÎÎ2 3
p
ÎÎ4 5
?
ÎÎ6 7
p
ÎÎ8 9
.
ÎÎ9 :
	AmountPen
ÎÎ: C
/
ÎÎD E
p
ÎÎF G
.
ÎÎG H
Amount
ÎÎH N
:
ÎÎO P
await
ÎÎQ V
db
ÎÎW Y
.
ÎÎY Z
RateToPenAsync
ÎÎZ h
(
ÎÎh i
x
ÎÎi j
.
ÎÎj k
Document
ÎÎk s
.
ÎÎs t
Currency
ÎÎt |
,
ÎÎ| }
x
ÎÎ~ 
.ÎÎ Ä
DocumentÎÎÄ à
.ÎÎà â
	IssueDateÎÎâ í
,ÎÎí ì
ctÎÎî ñ
)ÎÎñ ó
;ÎÎó ò
result
ÏÏ 
.
ÏÏ 
Add
ÏÏ 
(
ÏÏ 
TaxDocumentDto
ÏÏ %
(
ÏÏ% &
x
ÏÏ& '
.
ÏÏ' (
Document
ÏÏ( 0
,
ÏÏ0 1
rate
ÏÏ2 6
,
ÏÏ6 7
lines
ÏÏ8 =
[
ÏÏ= >
x
ÏÏ> ?
.
ÏÏ? @
Document
ÏÏ@ H
.
ÏÏH I
Id
ÏÏI K
]
ÏÏK L
,
ÏÏL M
x
ÏÏN O
.
ÏÏO P
Payment
ÏÏP W
?
ÏÏW X
.
ÏÏX Y
Method
ÏÏY _
)
ÏÏ_ `
)
ÏÏ` a
;
ÏÏa b
}
ÌÌ 	
return
ÓÓ 
Ok
ÓÓ 
(
ÓÓ 
result
ÓÓ 
)
ÓÓ 
;
ÓÓ 
}
ÔÔ 
[
ıı 
HttpPost
ıı 
(
ıı 
$str
ıı 
)
ıı 
]
ıı 
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
ˆˆ" #
CreateTaxDocument
ˆˆ$ 5
(
ˆˆ5 6 
TaxDocumentRequest
ˆˆ6 H
request
ˆˆI P
,
ˆˆP Q
CancellationToken
ˆˆR c
ct
ˆˆd f
)
ˆˆf g
{
˜˜ 
var
¯¯ 
items
¯¯ 
=
¯¯ 
TaxDocumentItems
¯¯ $
(
¯¯$ %
request
¯¯% ,
)
¯¯, -
;
¯¯- .
if
˘˘ 

(
˘˘ &
ValidateTaxDocumentItems
˘˘ $
(
˘˘$ %
request
˘˘% ,
.
˘˘, -
Currency
˘˘- 5
,
˘˘5 6
items
˘˘7 <
)
˘˘< =
is
˘˘> @
string
˘˘A G

itemsError
˘˘H R
)
˘˘R S
return
˘˘T Z

BadRequest
˘˘[ e
(
˘˘e f
new
˘˘f i
{
˘˘j k
message
˘˘l s
=
˘˘t u

itemsError˘˘v Ä
}˘˘Å Ç
)˘˘Ç É
;˘˘É Ñ
var
˙˙ 
ids
˙˙ 
=
˙˙ 
items
˙˙ 
.
˙˙ 
Select
˙˙ 
(
˙˙ 
x
˙˙  
=>
˙˙! #
x
˙˙$ %
.
˙˙% &
ClientProductId
˙˙& 5
)
˙˙5 6
.
˙˙6 7
ToList
˙˙7 =
(
˙˙= >
)
˙˙> ?
;
˙˙? @
var
˚˚ 
products
˚˚ 
=
˚˚ 
await
˚˚ 
db
˚˚ 
.
˚˚  
ClientProducts
˚˚  .
.
˚˚. /
Include
˚˚/ 6
(
˚˚6 7
x
˚˚7 8
=>
˚˚9 ;
x
˚˚< =
.
˚˚= >
Product
˚˚> E
)
˚˚E F
.
˚˚F G
Where
˚˚G L
(
˚˚L M
x
˚˚M N
=>
˚˚O Q
ids
˚˚R U
.
˚˚U V
Contains
˚˚V ^
(
˚˚^ _
x
˚˚_ `
.
˚˚` a
Id
˚˚a c
)
˚˚c d
)
˚˚d e
.
˚˚e f
ToListAsync
˚˚f q
(
˚˚q r
ct
˚˚r t
)
˚˚t u
;
˚˚u v
if
¸¸ 

(
¸¸ 
products
¸¸ 
.
¸¸ 
Count
¸¸ 
!=
¸¸ 
items
¸¸ #
.
¸¸# $
Count
¸¸$ )
||
¸¸* ,
products
¸¸- 5
.
¸¸5 6
Any
¸¸6 9
(
¸¸9 :
x
¸¸: ;
=>
¸¸< >
x
¸¸? @
.
¸¸@ A
Product
¸¸A H
is
¸¸I K
null
¸¸L P
)
¸¸P Q
)
¸¸Q R
return
¸¸S Y
NotFound
¸¸Z b
(
¸¸b c
new
¸¸c f
{
¸¸g h
message
¸¸i p
=
¸¸q r
$str¸¸s ò
}¸¸ô ö
)¸¸ö õ
;¸¸õ ú
if
˝˝ 

(
˝˝ 
products
˝˝ 
.
˝˝ 
Select
˝˝ 
(
˝˝ 
x
˝˝ 
=>
˝˝  
x
˝˝! "
.
˝˝" #
ClientId
˝˝# +
)
˝˝+ ,
.
˝˝, -
Distinct
˝˝- 5
(
˝˝5 6
)
˝˝6 7
.
˝˝7 8
Count
˝˝8 =
(
˝˝= >
)
˝˝> ?
>
˝˝@ A
$num
˝˝B C
)
˝˝C D
return
˝˝E K

BadRequest
˝˝L V
(
˝˝V W
new
˝˝W Z
{
˝˝[ \
message
˝˝] d
=
˝˝e f
$str˝˝g ô
}˝˝ö õ
)˝˝õ ú
;˝˝ú ù
var
˛˛ 
types
˛˛ 
=
˛˛ 
products
˛˛ 
.
˛˛ 
Select
˛˛ #
(
˛˛# $
x
˛˛$ %
=>
˛˛& (
x
˛˛) *
.
˛˛* +
Product
˛˛+ 2
!
˛˛2 3
.
˛˛3 4
TaxDocumentType
˛˛4 C
)
˛˛C D
.
˛˛D E
Distinct
˛˛E M
(
˛˛M N
)
˛˛N O
.
˛˛O P
ToList
˛˛P V
(
˛˛V W
)
˛˛W X
;
˛˛X Y
if
ˇˇ 

(
ˇˇ 
types
ˇˇ 
.
ˇˇ 
Count
ˇˇ 
>
ˇˇ 
$num
ˇˇ 
)
ˇˇ 
return
ˇˇ #

BadRequest
ˇˇ$ .
(
ˇˇ. /
new
ˇˇ/ 2
{
ˇˇ3 4
message
ˇˇ5 <
=
ˇˇ= >
$strˇˇ? ∑
}ˇˇ∏ π
)ˇˇπ ∫
;ˇˇ∫ ª
var
ÄÄ 
client
ÄÄ 
=
ÄÄ 
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
Clients
ÄÄ %
.
ÄÄ% &
	FindAsync
ÄÄ& /
(
ÄÄ/ 0
[
ÄÄ0 1
products
ÄÄ1 9
[
ÄÄ9 :
$num
ÄÄ: ;
]
ÄÄ; <
.
ÄÄ< =
ClientId
ÄÄ= E
]
ÄÄE F
,
ÄÄF G
ct
ÄÄH J
)
ÄÄJ K
;
ÄÄK L
if
ÅÅ 

(
ÅÅ 
client
ÅÅ 
is
ÅÅ 
null
ÅÅ 
||
ÅÅ 
!
ÅÅ 
client
ÅÅ %
.
ÅÅ% &!
RequiresTaxDocument
ÅÅ& 9
)
ÅÅ9 :
return
ÅÅ; A

BadRequest
ÅÅB L
(
ÅÅL M
new
ÅÅM P
{
ÅÅQ R
message
ÅÅS Z
=
ÅÅ[ \
$strÅÅ] ≤
}ÅÅ≥ ¥
)ÅÅ¥ µ
;ÅÅµ ∂
var
ÇÇ 
total
ÇÇ 
=
ÇÇ 
items
ÇÇ 
.
ÇÇ 
Sum
ÇÇ 
(
ÇÇ 
x
ÇÇ 
=>
ÇÇ  "
x
ÇÇ# $
.
ÇÇ$ %
Amount
ÇÇ% +
)
ÇÇ+ ,
;
ÇÇ, -
if
ÉÉ 

(
ÉÉ 
request
ÉÉ 
.
ÉÉ 
RetentionAmount
ÉÉ #
is
ÉÉ$ &
<
ÉÉ' (
$num
ÉÉ) *
||
ÉÉ+ -
request
ÉÉ. 5
.
ÉÉ5 6
RetentionAmount
ÉÉ6 E
>
ÉÉF G
total
ÉÉH M
)
ÉÉM N
return
ÉÉO U

BadRequest
ÉÉV `
(
ÉÉ` a
new
ÉÉa d
{
ÉÉe f
message
ÉÉg n
=
ÉÉo p
$strÉÉq û
}ÉÉü †
)ÉÉ† °
;ÉÉ° ¢
var
ÜÜ 
currency
ÜÜ 
=
ÜÜ 
request
ÜÜ 
.
ÜÜ 
Currency
ÜÜ '
.
ÜÜ' (
Trim
ÜÜ( ,
(
ÜÜ, -
)
ÜÜ- .
.
ÜÜ. /
ToUpperInvariant
ÜÜ/ ?
(
ÜÜ? @
)
ÜÜ@ A
;
ÜÜA B
var
áá 
payment
áá 
=
áá 
new
áá  
PaymentTransaction
áá ,
{
áá- .
ClientId
áá/ 7
=
áá8 9
client
áá: @
.
áá@ A
Id
ááA C
,
ááC D
ClientProductId
ááE T
=
ááU V
items
ááW \
.
áá\ ]
Count
áá] b
==
áác e
$num
ááf g
?
ááh i
items
ááj o
[
ááo p
$num
ááp q
]
ááq r
.
áár s
ClientProductIdáás Ç
:ááÉ Ñ
nullááÖ â
,ááâ ä
Amountááã ë
=ááí ì
totalááî ô
,ááô ö
Currencyááõ £
=áá§ •
currencyáá¶ Æ
,ááÆ Ø
Statusáá∞ ∂
=áá∑ ∏
$strááπ ƒ
,ááƒ ≈
Methodáá∆ Ã
=ááÕ Œ
PaymentMethodsááœ ›
.áá› ﬁ
Transferenciaááﬁ Î
,ááÎ Ï
	CreatedAtááÌ ˆ
=áá˜ ¯
requestáá˘ Ä
.ááÄ Å
	IssueDateááÅ ä
.ááä ã

ToDateTimeááã ï
(ááï ñ
newááñ ô
TimeOnlyááö ¢
(áá¢ £
$numáá£ •
,áá• ¶
$numááß ®
)áá® ©
,áá© ™
DateTimeKindáá´ ∑
.áá∑ ∏
Utcáá∏ ª
)ááª º
,ááº Ω
Notesááæ √
=ááƒ ≈
EmptyToNulláá∆ —
(áá— “
requestáá“ Ÿ
.ááŸ ⁄
Notesáá⁄ ﬂ
)ááﬂ ‡
}áá· ‚
;áá‚ „
payment
àà 
.
àà +
PayPalOrderIdOrSubscriptionId
àà -
=
àà. /
$"
àà0 2
$str
àà2 9
{
àà9 :
payment
àà: A
.
ààA B
Id
ààB D
:
ààD E
$str
ààE F
}
ààF G
"
ààG H
;
ààH I
payment
ââ 
.
ââ 
InternalCode
ââ 
=
ââ 
await
ââ $
db
ââ% '
.
ââ' (#
NextInternalCodeAsync
ââ( =
(
ââ= >
ct
ââ> @
)
ââ@ A
;
ââA B
payment
ää 
.
ää 
	AmountPen
ää 
=
ää 
payment
ää #
.
ää# $
Amount
ää$ *
*
ää+ ,
await
ää- 2
db
ää3 5
.
ää5 6
RateToPenAsync
ää6 D
(
ääD E
currency
ääE M
,
ääM N
request
ääO V
.
ääV W
	IssueDate
ääW `
,
ää` a
ct
ääb d
)
ääd e
;
ääe f
db
ãã 

.
ãã
 !
PaymentTransactions
ãã 
.
ãã 
Add
ãã "
(
ãã" #
payment
ãã# *
)
ãã* +
;
ãã+ ,
await
ãã- 2
db
ãã3 5
.
ãã5 6
SaveChangesAsync
ãã6 F
(
ããF G
ct
ããG I
)
ããI J
;
ããJ K
var
åå 
lines
åå 
=
åå 
items
åå 
.
åå 
Select
åå  
(
åå  !
x
åå! "
=>
åå# %
new
åå& )
TaxDocumentLine
åå* 9
{
åå: ;
ClientProductId
åå< K
=
ååL M
x
ååN O
.
ååO P
ClientProductId
ååP _
,
åå_ `
Description
ååa l
=
ååm n!
TaxDocumentServiceååo Å
.ååÅ Ç
LineDescriptionååÇ ë
(ååë í
productsååí ö
.ååö õ
Singleååõ °
(åå° ¢
påå¢ £
=>åå§ ¶
pååß ®
.åå® ©
Idåå© ´
==åå¨ Æ
xååØ ∞
.åå∞ ±
ClientProductIdåå± ¿
)åå¿ ¡
)åå¡ ¬
,åå¬ √
Amountååƒ  
=ååÀ Ã
xååÕ Œ
.ååŒ œ
Amountååœ ’
}åå÷ ◊
)åå◊ ÿ
.ååÿ Ÿ
ToListååŸ ﬂ
(ååﬂ ‡
)åå‡ ·
;åå· ‚
var
çç 
document
çç 
=
çç 
await
çç 
taxDocuments
çç )
.
çç) *

IssueAsync
çç* 4
(
çç4 5
new
çç5 8
TaxDocumentDraft
çç9 I
(
ççI J
client
ççJ P
.
ççP Q
Id
ççQ S
,
ççS T
types
ççU Z
[
ççZ [
$num
çç[ \
]
çç\ ]
,
çç] ^
request
çç_ f
.
ççf g
	IssueDate
ççg p
,
ççp q
currency
ççr z
,
ççz {
totalçç| Å
,ççÅ Ç
EmptyToNullççÉ é
(ççé è
requestççè ñ
.ççñ ó
Notesççó ú
)ççú ù
,ççù û
paymentççü ¶
.çç¶ ß
Idççß ©
,çç© ™
linesçç´ ∞
)çç∞ ±
,çç± ≤
ctçç≥ µ
)ççµ ∂
;çç∂ ∑
if
éé 

(
éé 
request
éé 
.
éé 
RetentionAmount
éé #
>
éé$ %
$num
éé& '
)
éé' (
{
éé) *
document
éé+ 3
.
éé3 4
RetentionAmount
éé4 C
=
ééD E
request
ééF M
.
ééM N
RetentionAmount
ééN ]
;
éé] ^
await
éé_ d
db
éée g
.
éég h
SaveChangesAsync
ééh x
(
ééx y
ct
ééy {
)
éé{ |
;
éé| }
}
éé~ 
var
èè 
saved
èè 
=
èè 
await
èè 
db
èè 
.
èè 
TaxDocumentLines
èè -
.
èè- .
Where
èè. 3
(
èè3 4
x
èè4 5
=>
èè6 8
x
èè9 :
.
èè: ;
TaxDocumentId
èè; H
==
èèI K
document
èèL T
.
èèT U
Id
èèU W
)
èèW X
.
èèX Y
OrderBy
èèY `
(
èè` a
x
èèa b
=>
èèc e
x
èèf g
.
èèg h
Order
èèh m
)
èèm n
.
èèn o
ToListAsync
èèo z
(
èèz {
ct
èè{ }
)
èè} ~
;
èè~ 
return
êê 
Created
êê 
(
êê 
$"
êê 
$str
êê 2
{
êê2 3
document
êê3 ;
.
êê; <
Id
êê< >
}
êê> ?
"
êê? @
,
êê@ A
TaxDocumentDto
êêB P
(
êêP Q
document
êêQ Y
,
êêY Z
payment
êê[ b
.
êêb c
Amount
êêc i
>
êêj k
$num
êêl m
?
êên o
payment
êêp w
.
êêw x
	AmountPenêêx Å
/êêÇ É
paymentêêÑ ã
.êêã å
Amountêêå í
:êêì î
$numêêï ó
,êêó ò
savedêêô û
,êêû ü
paymentêê† ß
.êêß ®
Methodêê® Æ
)êêÆ Ø
)êêØ ∞
;êê∞ ±
}
ëë 
private
îî 
static
îî 
IReadOnlyList
îî  
<
îî  !$
TaxDocumentItemRequest
îî! 7
>
îî7 8
TaxDocumentItems
îî9 I
(
îîI J 
TaxDocumentRequest
îîJ \
request
îî] d
)
îîd e
{
ïï 
if
ññ 

(
ññ 
request
ññ 
.
ññ 
Items
ññ 
is
ññ 
{
ññ 
Count
ññ $
:
ññ$ %
>
ññ& '
$num
ññ( )
}
ññ* +
list
ññ, 0
)
ññ0 1
return
ññ2 8
list
ññ9 =
;
ññ= >
return
óó 
request
óó 
.
óó 
ClientProductId
óó &
is
óó' )
Guid
óó* .
single
óó/ 5
?
óó6 7
[
óó8 9
new
óó9 <$
TaxDocumentItemRequest
óó= S
(
óóS T
single
óóT Z
,
óóZ [
request
óó\ c
.
óóc d
TotalAmount
óód o
??
óóp r
$num
óós t
)
óót u
]
óóu v
:
óów x
[
óóy z
]
óóz {
;
óó{ |
}
òò 
private
öö 
static
öö 
string
öö 
?
öö &
ValidateTaxDocumentItems
öö 3
(
öö3 4
string
öö4 :
?
öö: ;
currency
öö< D
,
ööD E
IReadOnlyList
ööF S
<
ööS T$
TaxDocumentItemRequest
ööT j
>
ööj k
items
ööl q
)
ööq r
{
õõ 
if
úú 

(
úú 
string
úú 
.
úú  
IsNullOrWhiteSpace
úú %
(
úú% &
currency
úú& .
)
úú. /
||
úú0 2
items
úú3 8
.
úú8 9
Count
úú9 >
==
úú? A
$num
úúB C
)
úúC D
return
úúE K
$str
úúL }
;
úú} ~
if
ùù 

(
ùù 
items
ùù 
.
ùù 
Any
ùù 
(
ùù 
x
ùù 
=>
ùù 
x
ùù 
.
ùù 
Amount
ùù #
<=
ùù$ &
$num
ùù' (
)
ùù( )
)
ùù) *
return
ùù+ 1
$str
ùù2 b
;
ùùb c
if
ûû 

(
ûû 
items
ûû 
.
ûû 
Select
ûû 
(
ûû 
x
ûû 
=>
ûû 
x
ûû 
.
ûû  
ClientProductId
ûû  /
)
ûû/ 0
.
ûû0 1
Distinct
ûû1 9
(
ûû9 :
)
ûû: ;
.
ûû; <
Count
ûû< A
(
ûûA B
)
ûûB C
!=
ûûD F
items
ûûG L
.
ûûL M
Count
ûûM R
)
ûûR S
return
ûûT Z
$strûû[ Ä
;ûûÄ Å
return
üü 
null
üü 
;
üü 
}
†† 
[
££ 
HttpPost
££ 
(
££ 
$str
££ /
)
££/ 0
]
££0 1
public
§§ 

async
§§ 
Task
§§ 
<
§§ 
ActionResult
§§ "
>
§§" # 
ReverseTaxDocument
§§$ 6
(
§§6 7
Guid
§§7 ;
id
§§< >
,
§§> ?'
ReverseTaxDocumentRequest
§§@ Y
request
§§Z a
,
§§a b
CancellationToken
§§c t
ct
§§u w
)
§§w x
{
•• 
var
¶¶ 
reason
¶¶ 
=
¶¶ 
request
¶¶ 
.
¶¶ 
Reason
¶¶ #
?
¶¶# $
.
¶¶$ %
Trim
¶¶% )
(
¶¶) *
)
¶¶* +
;
¶¶+ ,
if
ßß 

(
ßß 
string
ßß 
.
ßß 
IsNullOrEmpty
ßß  
(
ßß  !
reason
ßß! '
)
ßß' (
)
ßß( )
return
ßß* 0

BadRequest
ßß1 ;
(
ßß; <
new
ßß< ?
{
ßß@ A
message
ßßB I
=
ßßJ K
$str
ßßL k
}
ßßl m
)
ßßm n
;
ßßn o
if
®® 

(
®® 
reason
®® 
.
®® 
Length
®® 
>
®® 
$num
®® 
)
®®  
return
®®! '

BadRequest
®®( 2
(
®®2 3
new
®®3 6
{
®®7 8
message
®®9 @
=
®®A B
$str
®®C p
}
®®q r
)
®®r s
;
®®s t
return
©© 
await
©© 
taxDocuments
©© !
.
©©! "
ReverseAsync
©©" .
(
©©. /
id
©©/ 1
,
©©1 2
reason
©©3 9
,
©©9 :
request
©©; B
.
©©B C
	NotIssued
©©C L
,
©©L M
UserId
©©N T
,
©©T U
ct
©©V X
)
©©X Y
is
©©Z \'
TaxDocumentReversalResult
©©] v
result
©©w }
?
©©~ 
Ok©©Ä Ç
(©©Ç É
result©©É â
)©©â ä
:©©ã å
NotFound©©ç ï
(©©ï ñ
)©©ñ ó
;©©ó ò
}
™™ 
[
¨¨ 
HttpGet
¨¨ 
(
¨¨ 
$str
¨¨ 
)
¨¨ 
]
¨¨ 
public
≠≠ 

async
≠≠ 
Task
≠≠ 
<
≠≠ 
ActionResult
≠≠ "
>
≠≠" #
Expenses
≠≠$ ,
(
≠≠, -
int
≠≠- 0
?
≠≠0 1
month
≠≠2 7
,
≠≠7 8
int
≠≠9 <
?
≠≠< =
year
≠≠> B
,
≠≠B C
Guid
≠≠D H
?
≠≠H I

categoryId
≠≠J T
,
≠≠T U
CancellationToken
≠≠V g
ct
≠≠h j
)
≠≠j k
=>
≠≠l n
Ok
≠≠o q
(
≠≠q r
await
≠≠r w
db
≠≠x z
.
≠≠z {
Expenses≠≠{ É
.≠≠É Ñ
Include≠≠Ñ ã
(≠≠ã å
x≠≠å ç
=>≠≠é ê
x≠≠ë í
.≠≠í ì
Category≠≠ì õ
)≠≠õ ú
.
ÆÆ 	
Where
ÆÆ	 
(
ÆÆ 
x
ÆÆ 
=>
ÆÆ 
(
ÆÆ 
month
ÆÆ 
==
ÆÆ 
null
ÆÆ "
||
ÆÆ# %
x
ÆÆ& '
.
ÆÆ' (
Date
ÆÆ( ,
.
ÆÆ, -
Month
ÆÆ- 2
==
ÆÆ3 5
month
ÆÆ6 ;
)
ÆÆ; <
&&
ÆÆ= ?
(
ÆÆ@ A
year
ÆÆA E
==
ÆÆF H
null
ÆÆI M
||
ÆÆN P
x
ÆÆQ R
.
ÆÆR S
Date
ÆÆS W
.
ÆÆW X
Year
ÆÆX \
==
ÆÆ] _
year
ÆÆ` d
)
ÆÆd e
&&
ÆÆf h
(
ÆÆi j

categoryId
ÆÆj t
==
ÆÆu w
null
ÆÆx |
||
ÆÆ} 
xÆÆÄ Å
.ÆÆÅ Ç

CategoryIdÆÆÇ å
==ÆÆç è

categoryIdÆÆê ö
)ÆÆö õ
)ÆÆõ ú
.
ØØ 	
OrderByDescending
ØØ	 
(
ØØ 
x
ØØ 
=>
ØØ 
x
ØØ  !
.
ØØ! "
Date
ØØ" &
)
ØØ& '
.
ØØ' (
Select
ØØ( .
(
ØØ. /
x
ØØ/ 0
=>
ØØ1 3

ExpenseDto
ØØ4 >
(
ØØ> ?
x
ØØ? @
)
ØØ@ A
)
ØØA B
.
ØØB C
ToListAsync
ØØC N
(
ØØN O
ct
ØØO Q
)
ØØQ R
)
ØØR S
;
ØØS T
[
±± 
HttpPost
±± 
(
±± 
$str
±± 
)
±± 
]
±± 
public
≤≤ 

async
≤≤ 
Task
≤≤ 
<
≤≤ 
ActionResult
≤≤ "
>
≤≤" #
CreateExpense
≤≤$ 1
(
≤≤1 2
ExpenseRequest
≤≤2 @
request
≤≤A H
,
≤≤H I
CancellationToken
≤≤J [
ct
≤≤\ ^
)
≤≤^ _
{
≥≥ 
if
¥¥ 

(
¥¥ 
string
¥¥ 
.
¥¥  
IsNullOrWhiteSpace
¥¥ %
(
¥¥% &
request
¥¥& -
.
¥¥- .
Description
¥¥. 9
)
¥¥9 :
||
¥¥; =
string
¥¥> D
.
¥¥D E 
IsNullOrWhiteSpace
¥¥E W
(
¥¥W X
request
¥¥X _
.
¥¥_ `
Currency
¥¥` h
)
¥¥h i
||
¥¥j l
request
¥¥m t
.
¥¥t u
Amount
¥¥u {
<=
¥¥| ~
$num¥¥ Ä
)¥¥Ä Å
return¥¥Ç à

BadRequest¥¥â ì
(¥¥ì î
new¥¥î ó
{¥¥ò ô
message¥¥ö °
=¥¥¢ £
$str¥¥§ ‡
}¥¥· ‚
)¥¥‚ „
;¥¥„ ‰
if
µµ 

(
µµ 
!
µµ 
await
µµ 
db
µµ 
.
µµ 
ExpenseCategories
µµ '
.
µµ' (
AnyAsync
µµ( 0
(
µµ0 1
x
µµ1 2
=>
µµ3 5
x
µµ6 7
.
µµ7 8
Id
µµ8 :
==
µµ; =
request
µµ> E
.
µµE F

CategoryId
µµF P
,
µµP Q
ct
µµR T
)
µµT U
)
µµU V
return
µµW ]

BadRequest
µµ^ h
(
µµh i
new
µµi l
{
µµm n
message
µµo v
=
µµw x
$strµµy ñ
}µµó ò
)µµò ô
;µµô ö
var
∂∂ 
expense
∂∂ 
=
∂∂ 
new
∂∂ 
Expense
∂∂ !
{
∂∂" #
Description
∂∂$ /
=
∂∂0 1
request
∂∂2 9
.
∂∂9 :
Description
∂∂: E
.
∂∂E F
Trim
∂∂F J
(
∂∂J K
)
∂∂K L
,
∂∂L M

CategoryId
∂∂N X
=
∂∂Y Z
request
∂∂[ b
.
∂∂b c

CategoryId
∂∂c m
,
∂∂m n
Type
∂∂o s
=
∂∂t u
request
∂∂v }
.
∂∂} ~
Type∂∂~ Ç
,∂∂Ç É
Amount∂∂Ñ ä
=∂∂ã å
request∂∂ç î
.∂∂î ï
Amount∂∂ï õ
,∂∂õ ú
Currency∂∂ù •
=∂∂¶ ß
request∂∂® Ø
.∂∂Ø ∞
Currency∂∂∞ ∏
.∂∂∏ π
Trim∂∂π Ω
(∂∂Ω æ
)∂∂æ ø
.∂∂ø ¿ 
ToUpperInvariant∂∂¿ –
(∂∂– —
)∂∂— “
,∂∂“ ”
Date∂∂‘ ÿ
=∂∂Ÿ ⁄
request∂∂€ ‚
.∂∂‚ „
Date∂∂„ Á
,∂∂Á Ë
	Recurring∂∂È Ú
=∂∂Û Ù
request∂∂ı ¸
.∂∂¸ ˝
	Recurring∂∂˝ Ü
,∂∂Ü á
RecurrenceCycle∂∂à ó
=∂∂ò ô
request∂∂ö °
.∂∂° ¢
RecurrenceCycle∂∂¢ ±
,∂∂± ≤
IsNonDeductible∂∂≥ ¬
=∂∂√ ƒ
request∂∂≈ Ã
.∂∂Ã Õ
IsNonDeductible∂∂Õ ‹
}∂∂› ﬁ
;∂∂ﬁ ﬂ!
ApplyForeignService
∑∑ 
(
∑∑ 
expense
∑∑ #
,
∑∑# $
request
∑∑% ,
.
∑∑, -#
IsNonDomiciledService
∑∑- B
,
∑∑B C
request
∑∑D K
.
∑∑K L!
ForeignSupplierName
∑∑L _
,
∑∑_ `
request
∑∑a h
.
∑∑h i$
ForeignSupplierCountry
∑∑i 
)∑∑ Ä
;∑∑Ä Å
expense
∏∏ 
.
∏∏ 
	AmountPen
∏∏ 
=
∏∏ 
expense
∏∏ #
.
∏∏# $
Amount
∏∏$ *
*
∏∏+ ,
await
∏∏- 2
db
∏∏3 5
.
∏∏5 6
RateToPenAsync
∏∏6 D
(
∏∏D E
expense
∏∏E L
.
∏∏L M
Currency
∏∏M U
,
∏∏U V
expense
∏∏W ^
.
∏∏^ _
Date
∏∏_ c
,
∏∏c d
ct
∏∏e g
)
∏∏g h
;
∏∏h i
db
ππ 

.
ππ
 
Expenses
ππ 
.
ππ 
Add
ππ 
(
ππ 
expense
ππ 
)
ππ  
;
ππ  !
await
ππ" '
db
ππ( *
.
ππ* +
SaveChangesAsync
ππ+ ;
(
ππ; <
ct
ππ< >
)
ππ> ?
;
ππ? @
await
∫∫ 
db
∫∫ 
.
∫∫ 
Entry
∫∫ 
(
∫∫ 
expense
∫∫ 
)
∫∫ 
.
∫∫  
	Reference
∫∫  )
(
∫∫) *
x
∫∫* +
=>
∫∫, .
x
∫∫/ 0
.
∫∫0 1
Category
∫∫1 9
)
∫∫9 :
.
∫∫: ;
	LoadAsync
∫∫; D
(
∫∫D E
ct
∫∫E G
)
∫∫G H
;
∫∫H I
return
ªª 
Created
ªª 
(
ªª 
$"
ªª 
$str
ªª -
{
ªª- .
expense
ªª. 5
.
ªª5 6
Id
ªª6 8
}
ªª8 9
"
ªª9 :
,
ªª: ;

ExpenseDto
ªª< F
(
ªªF G
expense
ªªG N
)
ªªN O
)
ªªO P
;
ªªP Q
}
ºº 
[
ææ 
HttpGet
ææ 
(
ææ 
$str
ææ '
)
ææ' (
]
ææ( )
public
øø 

async
øø 
Task
øø 
<
øø 
IActionResult
øø #
>
øø# $
ExpenseTemplate
øø% 4
(
øø4 5
CancellationToken
øø5 F
ct
øøG I
)
øøI J
=>
øøK M
File
øøN R
(
øøR S
CreateWorkbook
øøS a
(
øøa b
new
¿¿ 
(
¿¿ 
$str
¿¿ 
,
¿¿ 
true
¿¿ 
,
¿¿  
$str
¿¿! @
)
¿¿@ A
,
¿¿A B
new
¡¡ 
(
¡¡ 
$str
¡¡ 
,
¡¡ 
true
¡¡ 
,
¡¡ 
$str
¡¡ V
,
¡¡V W
[
¡¡X Y
..
¡¡Y [
await
¡¡\ a
db
¡¡b d
.
¡¡d e
ExpenseCategories
¡¡e v
.
¡¡v w
OrderBy
¡¡w ~
(
¡¡~ 
x¡¡ Ä
=>¡¡Å É
x¡¡Ñ Ö
.¡¡Ö Ü
	SortOrder¡¡Ü è
)¡¡è ê
.¡¡ê ë
ThenBy¡¡ë ó
(¡¡ó ò
x¡¡ò ô
=>¡¡ö ú
x¡¡ù û
.¡¡û ü
Name¡¡ü £
)¡¡£ §
.¡¡§ •
Select¡¡• ´
(¡¡´ ¨
x¡¡¨ ≠
=>¡¡Æ ∞
x¡¡± ≤
.¡¡≤ ≥
Name¡¡≥ ∑
)¡¡∑ ∏
.¡¡∏ π
ToListAsync¡¡π ƒ
(¡¡ƒ ≈
ct¡¡≈ «
)¡¡« »
]¡¡» …
)¡¡…  
,¡¡  À
new
¬¬ 
(
¬¬ 
$str
¬¬ 
,
¬¬ 
true
¬¬ 
,
¬¬ 
$str
¬¬ +
,
¬¬+ ,
Enum
¬¬- 1
.
¬¬1 2
GetNames
¬¬2 :
<
¬¬: ;
ExpenseType
¬¬; F
>
¬¬F G
(
¬¬G H
)
¬¬H I
)
¬¬I J
,
¬¬J K
new
√√ 
(
√√ 
$str
√√ 
,
√√ 
true
√√ 
,
√√ 
$str
√√ K
)
√√K L
,
√√L M
new
ƒƒ 
(
ƒƒ 
$str
ƒƒ 
,
ƒƒ 
true
ƒƒ 
,
ƒƒ 
$str
ƒƒ .
,
ƒƒ. /
[
ƒƒ0 1
$str
ƒƒ1 6
,
ƒƒ6 7
$str
ƒƒ8 =
,
ƒƒ= >
$str
ƒƒ? D
]
ƒƒD E
)
ƒƒE F
,
ƒƒF G
new
≈≈ 
(
≈≈ 
$str
≈≈ 
,
≈≈ 
true
≈≈ 
,
≈≈ 
$str
≈≈ K
)
≈≈K L
,
≈≈L M
new
∆∆ 
(
∆∆ 
$str
∆∆ 
,
∆∆ 
false
∆∆ 
,
∆∆ 
$str
∆∆  6
,
∆∆6 7
[
∆∆8 9
$str
∆∆9 =
,
∆∆= >
$str
∆∆? C
]
∆∆C D
)
∆∆D E
,
∆∆E F
new
«« 
(
«« 
$str
«« 
,
«« 
false
«« $
,
««$ %
$str
««& X
,
««X Y
[
««Z [
$str
««[ d
,
««d e
$str
««f m
]
««m n
)
««n o
)
««o p
,
««p q
$str
»» K
,
»»K L
$str
»»M d
)
»»d e
;
»»e f
[
ÀÀ 
HttpPost
ÀÀ 
(
ÀÀ 
$str
ÀÀ 
)
ÀÀ  
]
ÀÀ  !
public
ÃÃ 

async
ÃÃ 
Task
ÃÃ 
<
ÃÃ 
ActionResult
ÃÃ "
>
ÃÃ" #
ImportExpenses
ÃÃ$ 2
(
ÃÃ2 3
	IFormFile
ÃÃ3 <
file
ÃÃ= A
,
ÃÃA B
CancellationToken
ÃÃC T
ct
ÃÃU W
)
ÃÃW X
{
ÕÕ 
var
ŒŒ 

categories
ŒŒ 
=
ŒŒ 
await
ŒŒ 
db
ŒŒ !
.
ŒŒ! "
ExpenseCategories
ŒŒ" 3
.
ŒŒ3 4
ToListAsync
ŒŒ4 ?
(
ŒŒ? @
ct
ŒŒ@ B
)
ŒŒB C
;
ŒŒC D
var
œœ 
(
œœ 
failure
œœ 
,
œœ 
created
œœ 
,
œœ 
errors
œœ %
)
œœ% &
=
œœ' (
await
œœ) .
Import
œœ/ 5
(
œœ5 6
file
œœ6 :
,
œœ: ;
$str
œœ< D
,
œœD E
async
œœF K
(
œœL M
row
œœM P
,
œœP Q
	rowNumber
œœR [
,
œœ[ \
errors
œœ] c
)
œœc d
=>
œœe g
{
–– 	
var
—— 
error
—— 
=
—— 
ParseExpenseRow
—— '
(
——' (
row
——( +
,
——+ ,

categories
——- 7
,
——7 8
out
——9 <
var
——= @
expense
——A H
)
——H I
;
——I J
if
““ 
(
““ 
error
““ 
is
““ 
not
““ 
null
““ !
)
““! "
{
““# $
errors
““% +
.
““+ ,
Add
““, /
(
““/ 0
new
““0 3
(
““3 4
	rowNumber
““4 =
,
““= >
error
““? D
)
““D E
)
““E F
;
““F G
return
““H N
false
““O T
;
““T U
}
““V W
expense
”” 
!
”” 
.
”” 
	AmountPen
”” 
=
””  
expense
””! (
.
””( )
Amount
””) /
*
””0 1
await
””2 7
db
””8 :
.
””: ;
RateToPenAsync
””; I
(
””I J
expense
””J Q
.
””Q R
Currency
””R Z
,
””Z [
expense
””\ c
.
””c d
Date
””d h
,
””h i
ct
””j l
)
””l m
;
””m n
db
‘‘ 
.
‘‘ 
Expenses
‘‘ 
.
‘‘ 
Add
‘‘ 
(
‘‘ 
expense
‘‘ #
)
‘‘# $
;
‘‘$ %
return
‘‘& ,
true
‘‘- 1
;
‘‘1 2
}
’’ 	
,
’’	 

ct
’’ 
)
’’ 
;
’’ 
return
÷÷ 
failure
÷÷ 
??
÷÷ 
Ok
÷÷ 
(
÷÷ 
new
÷÷  
{
÷÷! "
created
÷÷# *
,
÷÷* +
skipped
÷÷, 3
=
÷÷4 5
errors
÷÷6 <
.
÷÷< =
Count
÷÷= B
,
÷÷B C
errors
÷÷D J
}
÷÷K L
)
÷÷L M
;
÷÷M N
}
◊◊ 
private
ŸŸ 
static
ŸŸ 
string
ŸŸ 
?
ŸŸ 
ParseProductRow
ŸŸ *
(
ŸŸ* +
IXLRow
ŸŸ+ 1
row
ŸŸ2 5
,
ŸŸ5 6
out
ŸŸ7 :
Product
ŸŸ; B
?
ŸŸB C
product
ŸŸD K
)
ŸŸK L
{
⁄⁄ 
product
€€ 
=
€€ 
null
€€ 
;
€€ 
if
‹‹ 

(
‹‹ 
!
‹‹ 
TryEnum
‹‹ 
<
‹‹ 
ProductType
‹‹  
>
‹‹  !
(
‹‹! "
Cell
‹‹" &
(
‹‹& '
row
‹‹' *
,
‹‹* +
$num
‹‹, -
)
‹‹- .
,
‹‹. /
out
‹‹0 3
var
‹‹4 7
type
‹‹8 <
)
‹‹< =
)
‹‹= >
return
‹‹? E
$"
‹‹F H
$str
‹‹H [
{
‹‹[ \
string
‹‹\ b
.
‹‹b c
Join
‹‹c g
(
‹‹g h
$str
‹‹h l
,
‹‹l m
Enum
‹‹n r
.
‹‹r s
GetNames
‹‹s {
<
‹‹{ |
ProductType‹‹| á
>‹‹á à
(‹‹à â
)‹‹â ä
)‹‹ä ã
}‹‹ã å
$str‹‹å ç
"‹‹ç é
;‹‹é è
var
›› 
name
›› 
=
›› 
Cell
›› 
(
›› 
row
›› 
,
›› 
$num
›› 
)
›› 
.
››  
Trim
››  $
(
››$ %
)
››% &
;
››& '
if
ﬁﬁ 

(
ﬁﬁ 
string
ﬁﬁ 
.
ﬁﬁ  
IsNullOrWhiteSpace
ﬁﬁ %
(
ﬁﬁ% &
name
ﬁﬁ& *
)
ﬁﬁ* +
)
ﬁﬁ+ ,
return
ﬁﬁ- 3
$str
ﬁﬁ4 O
;
ﬁﬁO P
if
ﬂﬂ 

(
ﬂﬂ 
!
ﬂﬂ 
TryEnum
ﬂﬂ 
<
ﬂﬂ 
BillingCycle
ﬂﬂ !
>
ﬂﬂ! "
(
ﬂﬂ" #
Cell
ﬂﬂ# '
(
ﬂﬂ' (
row
ﬂﬂ( +
,
ﬂﬂ+ ,
$num
ﬂﬂ- .
)
ﬂﬂ. /
,
ﬂﬂ/ 0
out
ﬂﬂ1 4
var
ﬂﬂ5 8
cycle
ﬂﬂ9 >
)
ﬂﬂ> ?
)
ﬂﬂ? @
return
ﬂﬂA G
$strﬂﬂH û
;ﬂﬂû ü
if
‡‡ 

(
‡‡ 
ReadDecimal
‡‡ 
(
‡‡ 
row
‡‡ 
.
‡‡ 
Cell
‡‡  
(
‡‡  !
$num
‡‡! "
)
‡‡" #
)
‡‡# $
is
‡‡% '
not
‡‡( +
decimal
‡‡, 3
price
‡‡4 9
||
‡‡: <
price
‡‡= B
<
‡‡C D
$num
‡‡E F
)
‡‡F G
return
‡‡H N
$str‡‡O Ä
;‡‡Ä Å
var
·· 
currency
·· 
=
·· 
Cell
·· 
(
·· 
row
·· 
,
··  
$num
··! "
)
··" #
.
··# $
Trim
··$ (
(
··( )
)
··) *
.
··* +
ToUpperInvariant
··+ ;
(
··; <
)
··< =
;
··= >
if
‚‚ 

(
‚‚ 
currency
‚‚ 
is
‚‚ 
not
‚‚ 
(
‚‚ 
$str
‚‚ "
or
‚‚# %
$str
‚‚& +
or
‚‚, .
$str
‚‚/ 4
)
‚‚4 5
)
‚‚5 6
return
‚‚7 =
$str
‚‚> d
;
‚‚d e
if
„„ 

(
„„ 
	ReadYesNo
„„ 
(
„„ 
Cell
„„ 
(
„„ 
row
„„ 
,
„„ 
$num
„„  !
)
„„! "
,
„„" #
defaultValue
„„$ 0
:
„„0 1
true
„„2 6
)
„„6 7
is
„„8 :
not
„„; >
bool
„„? C
active
„„D J
)
„„J K
return
„„L R
$str
„„S t
;
„„t u
var
‰‰ 
taxText
‰‰ 
=
‰‰ 
Cell
‰‰ 
(
‰‰ 
row
‰‰ 
,
‰‰ 
$num
‰‰  !
)
‰‰! "
.
‰‰" #
Trim
‰‰# '
(
‰‰' (
)
‰‰( )
;
‰‰) *
var
‰‰+ .
taxType
‰‰/ 6
=
‰‰7 8
TaxDocumentType
‰‰9 H
.
‰‰H I
Factura
‰‰I P
;
‰‰P Q
if
ÂÂ 

(
ÂÂ 
taxText
ÂÂ 
!=
ÂÂ 
$str
ÂÂ 
&&
ÂÂ 
!
ÂÂ 
TryEnum
ÂÂ %
(
ÂÂ% &
taxText
ÂÂ& -
,
ÂÂ- .
out
ÂÂ/ 2
taxType
ÂÂ3 :
)
ÂÂ: ;
)
ÂÂ; <
return
ÂÂ= C
$strÂÂD Ç
;ÂÂÇ É
if
ÊÊ 

(
ÊÊ 
	ReadYesNo
ÊÊ 
(
ÊÊ 
Cell
ÊÊ 
(
ÊÊ 
row
ÊÊ 
,
ÊÊ 
$num
ÊÊ  "
)
ÊÊ" #
,
ÊÊ# $
defaultValue
ÊÊ% 1
:
ÊÊ1 2
false
ÊÊ3 8
)
ÊÊ8 9
is
ÊÊ: <
not
ÊÊ= @
bool
ÊÊA E
allowsTickets
ÊÊF S
)
ÊÊS T
return
ÊÊU [
$strÊÊ\ Ç
;ÊÊÇ É
product
ÁÁ 
=
ÁÁ 
new
ÁÁ 
Product
ÁÁ 
{
ÁÁ 
Type
ÁÁ  $
=
ÁÁ% &
type
ÁÁ' +
,
ÁÁ+ ,
Name
ÁÁ- 1
=
ÁÁ2 3
name
ÁÁ4 8
,
ÁÁ8 9
BillingCycle
ÁÁ: F
=
ÁÁG H
cycle
ÁÁI N
,
ÁÁN O
	BasePrice
ÁÁP Y
=
ÁÁZ [
price
ÁÁ\ a
,
ÁÁa b
Currency
ÁÁc k
=
ÁÁl m
currency
ÁÁn v
,
ÁÁv w
DescriptionÁÁx É
=ÁÁÑ Ö
EmptyToNullÁÁÜ ë
(ÁÁë í
CellÁÁí ñ
(ÁÁñ ó
rowÁÁó ö
,ÁÁö õ
$numÁÁú ù
)ÁÁù û
)ÁÁû ü
,ÁÁü †
IsActiveÁÁ° ©
=ÁÁ™ ´
activeÁÁ¨ ≤
,ÁÁ≤ ≥
TaxDocumentTypeÁÁ¥ √
=ÁÁƒ ≈
taxTypeÁÁ∆ Õ
,ÁÁÕ Œ
CategoryÁÁœ ◊
=ÁÁÿ Ÿ
EmptyToNullÁÁ⁄ Â
(ÁÁÂ Ê
CellÁÁÊ Í
(ÁÁÍ Î
rowÁÁÎ Ó
,ÁÁÓ Ô
$numÁÁ Ò
)ÁÁÒ Ú
)ÁÁÚ Û
,ÁÁÛ Ù
TagsÁÁı ˘
=ÁÁ˙ ˚
NormalizeTagsÁÁ¸ â
(ÁÁâ ä
CellÁÁä é
(ÁÁé è
rowÁÁè í
,ÁÁí ì
$numÁÁî ñ
)ÁÁñ ó
)ÁÁó ò
,ÁÁò ô
AllowsTicketsÁÁö ß
=ÁÁ® ©
allowsTicketsÁÁ™ ∑
}ÁÁ∏ π
;ÁÁπ ∫
return
ËË 
null
ËË 
;
ËË 
}
ÈÈ 
private
ÏÏ 
static
ÏÏ 
bool
ÏÏ 
TryEnum
ÏÏ 
<
ÏÏ  
T
ÏÏ  !
>
ÏÏ! "
(
ÏÏ" #
string
ÏÏ# )
value
ÏÏ* /
,
ÏÏ/ 0
out
ÏÏ1 4
T
ÏÏ5 6
result
ÏÏ7 =
)
ÏÏ= >
where
ÏÏ? D
T
ÏÏE F
:
ÏÏG H
struct
ÏÏI O
,
ÏÏO P
Enum
ÏÏQ U
=>
ÏÏV X
Enum
ÏÏY ]
.
ÏÏ] ^
TryParse
ÏÏ^ f
(
ÏÏf g
value
ÏÏg l
.
ÏÏl m
Trim
ÏÏm q
(
ÏÏq r
)
ÏÏr s
,
ÏÏs t
true
ÏÏu y
,
ÏÏy z
out
ÏÏ{ ~
resultÏÏ Ö
)ÏÏÖ Ü
&&ÏÏá â
EnumÏÏä é
.ÏÏé è
	IsDefinedÏÏè ò
(ÏÏò ô
resultÏÏô ü
)ÏÏü †
&&ÏÏ° £
!ÏÏ§ •
intÏÏ• ®
.ÏÏ® ©
TryParseÏÏ© ±
(ÏÏ± ≤
valueÏÏ≤ ∑
.ÏÏ∑ ∏
TrimÏÏ∏ º
(ÏÏº Ω
)ÏÏΩ æ
,ÏÏæ ø
outÏÏ¿ √
_ÏÏƒ ≈
)ÏÏ≈ ∆
;ÏÏ∆ «
private
ÔÔ 
static
ÔÔ 
bool
ÔÔ 
?
ÔÔ 
	ReadYesNo
ÔÔ "
(
ÔÔ" #
string
ÔÔ# )
value
ÔÔ* /
,
ÔÔ/ 0
bool
ÔÔ1 5
defaultValue
ÔÔ6 B
)
ÔÔB C
=>
ÔÔD F
value
ÔÔG L
.
ÔÔL M
Trim
ÔÔM Q
(
ÔÔQ R
)
ÔÔR S
.
ÔÔS T
ToUpperInvariant
ÔÔT d
(
ÔÔd e
)
ÔÔe f
switch
ÔÔg m
{
 
$str
ÒÒ 

=>
ÒÒ 
defaultValue
ÒÒ 
,
ÒÒ 
$str
ÚÚ 
or
ÚÚ 
$str
ÚÚ 
or
ÚÚ 
$str
ÚÚ 
or
ÚÚ !
$str
ÚÚ" -
or
ÚÚ. 0
$str
ÚÚ1 4
=>
ÚÚ5 7
true
ÚÚ8 <
,
ÚÚ< =
$str
ÛÛ 
or
ÛÛ 
$str
ÛÛ 
or
ÛÛ 
$str
ÛÛ "
or
ÛÛ# %
$str
ÛÛ& )
=>
ÛÛ* ,
false
ÛÛ- 2
,
ÛÛ2 3
_
ÙÙ 	
=>
ÙÙ
 
null
ÙÙ 
,
ÙÙ 
}
ıı 
;
ıı 
private
˜˜ 
static
˜˜ 
string
˜˜ 
?
˜˜ 
ParseExpenseRow
˜˜ *
(
˜˜* +
IXLRow
˜˜+ 1
row
˜˜2 5
,
˜˜5 6
IReadOnlyList
˜˜7 D
<
˜˜D E
ExpenseCategory
˜˜E T
>
˜˜T U

categories
˜˜V `
,
˜˜` a
out
˜˜b e
Expense
˜˜f m
?
˜˜m n
expense
˜˜o v
)
˜˜v w
{
¯¯ 
expense
˘˘ 
=
˘˘ 
null
˘˘ 
;
˘˘ 
var
˙˙ 
description
˙˙ 
=
˙˙ 
Cell
˙˙ 
(
˙˙ 
row
˙˙ "
,
˙˙" #
$num
˙˙$ %
)
˙˙% &
.
˙˙& '
Trim
˙˙' +
(
˙˙+ ,
)
˙˙, -
;
˙˙- .
if
˚˚ 

(
˚˚ 
string
˚˚ 
.
˚˚  
IsNullOrWhiteSpace
˚˚ %
(
˚˚% &
description
˚˚& 1
)
˚˚1 2
)
˚˚2 3
return
˚˚4 :
$str
˚˚; [
;
˚˚[ \
var
˝˝ 
categoryText
˝˝ 
=
˝˝ 
Fold
˝˝ 
(
˝˝  
Cell
˝˝  $
(
˝˝$ %
row
˝˝% (
,
˝˝( )
$num
˝˝* +
)
˝˝+ ,
)
˝˝, -
;
˝˝- .
if
˛˛ 

(
˛˛ 

categories
˛˛ 
.
˛˛ 
FirstOrDefault
˛˛ %
(
˛˛% &
x
˛˛& '
=>
˛˛( *
Fold
˛˛+ /
(
˛˛/ 0
x
˛˛0 1
.
˛˛1 2
Name
˛˛2 6
)
˛˛6 7
==
˛˛8 :
categoryText
˛˛; G
||
˛˛H J
x
˛˛K L
.
˛˛L M
Code
˛˛M Q
is
˛˛R T
not
˛˛U X
null
˛˛Y ]
&&
˛˛^ `
Fold
˛˛a e
(
˛˛e f
x
˛˛f g
.
˛˛g h
Code
˛˛h l
)
˛˛l m
==
˛˛n p
categoryText
˛˛q }
)
˛˛} ~
is˛˛ Å
not˛˛Ç Ö
{˛˛Ü á
}˛˛à â
category˛˛ä í
)˛˛í ì
return˛˛î ö
$"˛˛õ ù
$str˛˛ù µ
{˛˛µ ∂
string˛˛∂ º
.˛˛º Ω
Join˛˛Ω ¡
(˛˛¡ ¬
$str˛˛¬ ∆
,˛˛∆ «

categories˛˛» “
.˛˛“ ”
OrderBy˛˛” ⁄
(˛˛⁄ €
x˛˛€ ‹
=>˛˛› ﬂ
x˛˛‡ ·
.˛˛· ‚
	SortOrder˛˛‚ Î
)˛˛Î Ï
.˛˛Ï Ì
Select˛˛Ì Û
(˛˛Û Ù
x˛˛Ù ı
=>˛˛ˆ ¯
x˛˛˘ ˙
.˛˛˙ ˚
Name˛˛˚ ˇ
)˛˛ˇ Ä
)˛˛Ä Å
}˛˛Å Ç
$str˛˛Ç É
"˛˛É Ñ
;˛˛Ñ Ö
if
ˇˇ 

(
ˇˇ 
!
ˇˇ 
TryEnum
ˇˇ 
<
ˇˇ 
ExpenseType
ˇˇ  
>
ˇˇ  !
(
ˇˇ! "
Cell
ˇˇ" &
(
ˇˇ& '
row
ˇˇ' *
,
ˇˇ* +
$num
ˇˇ, -
)
ˇˇ- .
,
ˇˇ. /
out
ˇˇ0 3
var
ˇˇ4 7
type
ˇˇ8 <
)
ˇˇ< =
)
ˇˇ= >
return
ˇˇ? E
$str
ˇˇF k
;
ˇˇk l
if
ÄÄ 

(
ÄÄ 
ReadDecimal
ÄÄ 
(
ÄÄ 
row
ÄÄ 
.
ÄÄ 
Cell
ÄÄ  
(
ÄÄ  !
$num
ÄÄ! "
)
ÄÄ" #
)
ÄÄ# $
is
ÄÄ% '
not
ÄÄ( +
decimal
ÄÄ, 3
amount
ÄÄ4 :
||
ÄÄ; =
amount
ÄÄ> D
<=
ÄÄE G
$num
ÄÄH I
)
ÄÄI J
return
ÄÄK Q
$str
ÄÄR z
;
ÄÄz {
var
ÅÅ 
currency
ÅÅ 
=
ÅÅ 
Cell
ÅÅ 
(
ÅÅ 
row
ÅÅ 
,
ÅÅ  
$num
ÅÅ! "
)
ÅÅ" #
.
ÅÅ# $
Trim
ÅÅ$ (
(
ÅÅ( )
)
ÅÅ) *
.
ÅÅ* +
ToUpperInvariant
ÅÅ+ ;
(
ÅÅ; <
)
ÅÅ< =
;
ÅÅ= >
if
ÇÇ 

(
ÇÇ 
currency
ÇÇ 
is
ÇÇ 
not
ÇÇ 
(
ÇÇ 
$str
ÇÇ "
or
ÇÇ# %
$str
ÇÇ& +
or
ÇÇ, .
$str
ÇÇ/ 4
)
ÇÇ4 5
)
ÇÇ5 6
return
ÇÇ7 =
$str
ÇÇ> d
;
ÇÇd e
if
ÉÉ 

(
ÉÉ 
ReadDate
ÉÉ 
(
ÉÉ 
row
ÉÉ 
.
ÉÉ 
Cell
ÉÉ 
(
ÉÉ 
$num
ÉÉ 
)
ÉÉ  
)
ÉÉ  !
is
ÉÉ" $
not
ÉÉ% (
DateOnly
ÉÉ) 1
date
ÉÉ2 6
)
ÉÉ6 7
return
ÉÉ8 >
$str
ÉÉ? m
;
ÉÉm n
if
ÑÑ 

(
ÑÑ 
	ReadYesNo
ÑÑ 
(
ÑÑ 
Cell
ÑÑ 
(
ÑÑ 
row
ÑÑ 
,
ÑÑ 
$num
ÑÑ  !
)
ÑÑ! "
,
ÑÑ" #
defaultValue
ÑÑ$ 0
:
ÑÑ0 1
false
ÑÑ2 7
)
ÑÑ7 8
is
ÑÑ9 ;
not
ÑÑ< ?
bool
ÑÑ@ D
	recurring
ÑÑE N
)
ÑÑN O
return
ÑÑP V
$str
ÑÑW y
;
ÑÑy z
if
ÖÖ 

(
ÖÖ 
!
ÖÖ  
TryRecurrenceCycle
ÖÖ 
(
ÖÖ  
Cell
ÖÖ  $
(
ÖÖ$ %
row
ÖÖ% (
,
ÖÖ( )
$num
ÖÖ* +
)
ÖÖ+ ,
,
ÖÖ, -
	recurring
ÖÖ. 7
,
ÖÖ7 8
out
ÖÖ9 <
var
ÖÖ= @
cycle
ÖÖA F
)
ÖÖF G
)
ÖÖG H
return
ÖÖI O
$strÖÖP ê
;ÖÖê ë
expense
ÜÜ 
=
ÜÜ 
new
ÜÜ 
Expense
ÜÜ 
{
ÜÜ 
Description
ÜÜ  +
=
ÜÜ, -
description
ÜÜ. 9
,
ÜÜ9 :

CategoryId
ÜÜ; E
=
ÜÜF G
category
ÜÜH P
.
ÜÜP Q
Id
ÜÜQ S
,
ÜÜS T
Type
ÜÜU Y
=
ÜÜZ [
type
ÜÜ\ `
,
ÜÜ` a
Amount
ÜÜb h
=
ÜÜi j
amount
ÜÜk q
,
ÜÜq r
Currency
ÜÜs {
=
ÜÜ| }
currencyÜÜ~ Ü
,ÜÜÜ á
DateÜÜà å
=ÜÜç é
dateÜÜè ì
,ÜÜì î
	RecurringÜÜï û
=ÜÜü †
	recurringÜÜ° ™
,ÜÜ™ ´
RecurrenceCycleÜÜ¨ ª
=ÜÜº Ω
cycleÜÜæ √
}ÜÜƒ ≈
;ÜÜ≈ ∆
return
áá 
null
áá 
;
áá 
}
àà 
private
ãã 
static
ãã 
bool
ãã  
TryRecurrenceCycle
ãã *
(
ãã* +
string
ãã+ 1
value
ãã2 7
,
ãã7 8
bool
ãã9 =
	recurring
ãã> G
,
ããG H
out
ããI L
BillingCycle
ããM Y
?
ããY Z
cycle
ãã[ `
)
ãã` a
{
åå 
cycle
çç 
=
çç 
null
çç 
;
çç 
if
éé 

(
éé 
!
éé 
	recurring
éé 
)
éé 
return
éé 
true
éé #
;
éé# $
if
èè 

(
èè 
!
èè 
TryEnum
èè 
<
èè 
BillingCycle
èè !
>
èè! "
(
èè" #
value
èè# (
,
èè( )
out
èè* -
var
èè. 1
parsed
èè2 8
)
èè8 9
||
èè: <
parsed
èè= C
is
èèD F
not
èèG J
(
èèK L
BillingCycle
èèL X
.
èèX Y
Mensual
èèY `
or
èèa c
BillingCycle
èèd p
.
èèp q
Anual
èèq v
)
èèv w
)
èèw x
return
èèy 
falseèèÄ Ö
;èèÖ Ü
cycle
êê 
=
êê 
parsed
êê 
;
êê 
return
ëë 
true
ëë 
;
ëë 
}
íí 
private
ïï 
static
ïï 
decimal
ïï 
?
ïï 
ReadDecimal
ïï '
(
ïï' (
IXLCell
ïï( /
cell
ïï0 4
)
ïï4 5
{
ññ 
if
óó 

(
óó 
cell
óó 
.
óó 
DataType
óó 
==
óó 

XLDataType
óó '
.
óó' (
Number
óó( .
)
óó. /
return
óó0 6
(
óó7 8
decimal
óó8 ?
)
óó? @
cell
óó@ D
.
óóD E
	GetDouble
óóE N
(
óóN O
)
óóO P
;
óóP Q
return
òò 
decimal
òò 
.
òò 
TryParse
òò 
(
òò  
cell
òò  $
.
òò$ %
	GetString
òò% .
(
òò. /
)
òò/ 0
.
òò0 1
Trim
òò1 5
(
òò5 6
)
òò6 7
,
òò7 8
System
òò9 ?
.
òò? @
Globalization
òò@ M
.
òòM N
NumberStyles
òòN Z
.
òòZ [
Number
òò[ a
,
òòa b
System
òòc i
.
òòi j
Globalization
òòj w
.
òòw x
CultureInfoòòx É
.òòÉ Ñ 
InvariantCultureòòÑ î
,òòî ï
outòòñ ô
varòòö ù
valueòòû £
)òò£ §
?òò• ¶
valueòòß ¨
:òò≠ Æ
nullòòØ ≥
;òò≥ ¥
}
ôô 
private
õõ 
static
õõ 
DateOnly
õõ 
?
õõ 
ReadDate
õõ %
(
õõ% &
IXLCell
õõ& -
cell
õõ. 2
)
õõ2 3
{
úú 
if
ùù 

(
ùù 
cell
ùù 
.
ùù 
DataType
ùù 
==
ùù 

XLDataType
ùù '
.
ùù' (
DateTime
ùù( 0
)
ùù0 1
return
ùù2 8
DateOnly
ùù9 A
.
ùùA B
FromDateTime
ùùB N
(
ùùN O
cell
ùùO S
.
ùùS T
GetDateTime
ùùT _
(
ùù_ `
)
ùù` a
)
ùùa b
;
ùùb c
return
ûû 
DateOnly
ûû 
.
ûû 
TryParseExact
ûû %
(
ûû% &
cell
ûû& *
.
ûû* +
	GetString
ûû+ 4
(
ûû4 5
)
ûû5 6
.
ûû6 7
Trim
ûû7 ;
(
ûû; <
)
ûû< =
,
ûû= >
[
ûû? @
$str
ûû@ L
,
ûûL M
$str
ûûN Z
,
ûûZ [
$str
ûû\ f
]
ûûf g
,
ûûg h
System
ûûi o
.
ûûo p
Globalization
ûûp }
.
ûû} ~
CultureInfoûû~ â
.ûûâ ä 
InvariantCultureûûä ö
,ûûö õ
Systemûûú ¢
.ûû¢ £
Globalizationûû£ ∞
.ûû∞ ±
DateTimeStylesûû± ø
.ûûø ¿
Noneûû¿ ƒ
,ûûƒ ≈
outûû∆ …
varûû  Õ
dateûûŒ “
)ûû“ ”
?ûû‘ ’
dateûû÷ ⁄
:ûû€ ‹
nullûû› ·
;ûû· ‚
}
üü 
[
°° 

HttpDelete
°° 
(
°° 
$str
°° $
)
°°$ %
]
°°% &
public
¢¢ 

async
¢¢ 
Task
¢¢ 
<
¢¢ 
ActionResult
¢¢ "
>
¢¢" #
DeleteExpense
¢¢$ 1
(
¢¢1 2
Guid
¢¢2 6
id
¢¢7 9
,
¢¢9 :
CancellationToken
¢¢; L
ct
¢¢M O
)
¢¢O P
{
££ 
var
§§ 
expense
§§ 
=
§§ 
await
§§ 
db
§§ 
.
§§ 
Expenses
§§ '
.
§§' (
	FindAsync
§§( 1
(
§§1 2
[
§§2 3
id
§§3 5
]
§§5 6
,
§§6 7
ct
§§8 :
)
§§: ;
;
§§; <
if
§§= ?
(
§§@ A
expense
§§A H
is
§§I K
null
§§L P
)
§§P Q
return
§§R X
NotFound
§§Y a
(
§§a b
)
§§b c
;
§§c d
db
•• 

.
••
 
Expenses
•• 
.
•• 
Remove
•• 
(
•• 
expense
•• "
)
••" #
;
••# $
await
••% *
db
••+ -
.
••- .
SaveChangesAsync
••. >
(
••> ?
ct
••? A
)
••A B
;
••B C
return
••D J
	NoContent
••K T
(
••T U
)
••U V
;
••V W
}
¶¶ 
[
≠≠ 
HttpPost
≠≠ 
(
≠≠ 
$str
≠≠ 1
)
≠≠1 2
]
≠≠2 3
public
ÆÆ 

async
ÆÆ 
Task
ÆÆ 
<
ÆÆ 
ActionResult
ÆÆ "
>
ÆÆ" #
EndRecurrence
ÆÆ$ 1
(
ÆÆ1 2
Guid
ÆÆ2 6
id
ÆÆ7 9
,
ÆÆ9 :"
EndRecurrenceRequest
ÆÆ; O
request
ÆÆP W
,
ÆÆW X
bool
ÆÆY ]
dryRun
ÆÆ^ d
,
ÆÆd e
CancellationToken
ÆÆf w
ct
ÆÆx z
)
ÆÆz {
{
ØØ 
var
∞∞ 
expense
∞∞ 
=
∞∞ 
await
∞∞ 
db
∞∞ 
.
∞∞ 
Expenses
∞∞ '
.
∞∞' (
	FindAsync
∞∞( 1
(
∞∞1 2
[
∞∞2 3
id
∞∞3 5
]
∞∞5 6
,
∞∞6 7
ct
∞∞8 :
)
∞∞: ;
;
∞∞; <
if
∞∞= ?
(
∞∞@ A
expense
∞∞A H
is
∞∞I K
null
∞∞L P
)
∞∞P Q
return
∞∞R X
NotFound
∞∞Y a
(
∞∞a b
)
∞∞b c
;
∞∞c d
if
±± 

(
±± 
!
±± 
expense
±± 
.
±± 
	Recurring
±± 
)
±± 
return
±±  &

BadRequest
±±' 1
(
±±1 2
new
±±2 5
{
±±6 7
message
±±8 ?
=
±±@ A
$str
±±B ^
}
±±_ `
)
±±` a
;
±±a b
var
≤≤ 
series
≤≤ 
=
≤≤ 
await
≤≤ 
ExpenseSeries
≤≤ (
(
≤≤( )
expense
≤≤) 0
)
≤≤0 1
.
≤≤1 2
ToListAsync
≤≤2 =
(
≤≤= >
ct
≤≤> @
)
≤≤@ A
;
≤≤A B
var
≥≥ 
removed
≥≥ 
=
≥≥ 
series
≥≥ 
.
≥≥ 
Where
≥≥ "
(
≥≥" #
x
≥≥# $
=>
≥≥% '
x
≥≥( )
.
≥≥) *
Date
≥≥* .
>
≥≥/ 0
request
≥≥1 8
.
≥≥8 9
EndsAt
≥≥9 ?
)
≥≥? @
.
≥≥@ A
ToList
≥≥A G
(
≥≥G H
)
≥≥H I
;
≥≥I J
if
¥¥ 

(
¥¥ 
!
¥¥ 
dryRun
¥¥ 
)
¥¥ 
{
µµ 	
db
∂∂ 
.
∂∂ 
Expenses
∂∂ 
.
∂∂ 
RemoveRange
∂∂ #
(
∂∂# $
removed
∂∂$ +
)
∂∂+ ,
;
∂∂, -
foreach
∑∑ 
(
∑∑ 
var
∑∑ 
kept
∑∑ 
in
∑∑  
series
∑∑! '
.
∑∑' (
Except
∑∑( .
(
∑∑. /
removed
∑∑/ 6
)
∑∑6 7
)
∑∑7 8
kept
∑∑9 =
.
∑∑= >
RecurrenceEndsAt
∑∑> N
=
∑∑O P
request
∑∑Q X
.
∑∑X Y
EndsAt
∑∑Y _
;
∑∑_ `
await
∏∏ 
db
∏∏ 
.
∏∏ 
SaveChangesAsync
∏∏ %
(
∏∏% &
ct
∏∏& (
)
∏∏( )
;
∏∏) *
}
ππ 	
return
∫∫ 
Ok
∫∫ 
(
∫∫ 
new
∫∫ 
{
∫∫ 
removed
∫∫ 
=
∫∫  !
removed
∫∫" )
.
∫∫) *
Count
∫∫* /
,
∫∫/ 0
kept
∫∫1 5
=
∫∫6 7
series
∫∫8 >
.
∫∫> ?
Count
∫∫? D
-
∫∫E F
removed
∫∫G N
.
∫∫N O
Count
∫∫O T
,
∫∫T U
removedTotalPen
∫∫V e
=
∫∫f g
Math
∫∫h l
.
∫∫l m
Round
∫∫m r
(
∫∫r s
removed
∫∫s z
.
∫∫z {
Sum
∫∫{ ~
(
∫∫~ 
x∫∫ Ä
=>∫∫Å É
x∫∫Ñ Ö
.∫∫Ö Ü
	AmountPen∫∫Ü è
)∫∫è ê
,∫∫ê ë
$num∫∫í ì
)∫∫ì î
}∫∫ï ñ
)∫∫ñ ó
;∫∫ó ò
}
ªª 
[
ææ 

HttpDelete
ææ 
(
ææ 
$str
ææ 3
)
ææ3 4
]
ææ4 5
public
øø 

async
øø 
Task
øø 
<
øø 
ActionResult
øø "
>
øø" #
ResumeRecurrence
øø$ 4
(
øø4 5
Guid
øø5 9
id
øø: <
,
øø< =
CancellationToken
øø> O
ct
øøP R
)
øøR S
{
¿¿ 
var
¡¡ 
expense
¡¡ 
=
¡¡ 
await
¡¡ 
db
¡¡ 
.
¡¡ 
Expenses
¡¡ '
.
¡¡' (
	FindAsync
¡¡( 1
(
¡¡1 2
[
¡¡2 3
id
¡¡3 5
]
¡¡5 6
,
¡¡6 7
ct
¡¡8 :
)
¡¡: ;
;
¡¡; <
if
¡¡= ?
(
¡¡@ A
expense
¡¡A H
is
¡¡I K
null
¡¡L P
)
¡¡P Q
return
¡¡R X
NotFound
¡¡Y a
(
¡¡a b
)
¡¡b c
;
¡¡c d
foreach
¬¬ 
(
¬¬ 
var
¬¬ 
x
¬¬ 
in
¬¬ 
await
¬¬ 
ExpenseSeries
¬¬  -
(
¬¬- .
expense
¬¬. 5
)
¬¬5 6
.
¬¬6 7
ToListAsync
¬¬7 B
(
¬¬B C
ct
¬¬C E
)
¬¬E F
)
¬¬F G
x
¬¬H I
.
¬¬I J
RecurrenceEndsAt
¬¬J Z
=
¬¬[ \
null
¬¬] a
;
¬¬a b
await
√√ 
db
√√ 
.
√√ 
SaveChangesAsync
√√ !
(
√√! "
ct
√√" $
)
√√$ %
;
√√% &
return
√√' -
	NoContent
√√. 7
(
√√7 8
)
√√8 9
;
√√9 :
}
ƒƒ 
private
∆∆ 

IQueryable
∆∆ 
<
∆∆ 
Expense
∆∆ 
>
∆∆ 
ExpenseSeries
∆∆  -
(
∆∆- .
Expense
∆∆. 5
expense
∆∆6 =
)
∆∆= >
{
«« 
var
»» 
description
»» 
=
»» 
expense
»» !
.
»»! "
Description
»»" -
.
»»- .
Trim
»». 2
(
»»2 3
)
»»3 4
;
»»4 5
return
…… 
db
…… 
.
…… 
Expenses
…… 
.
…… 
Where
……  
(
……  !
x
……! "
=>
……# %
x
……& '
.
……' (
	Recurring
……( 1
&&
……2 4
x
……5 6
.
……6 7
Description
……7 B
.
……B C
Trim
……C G
(
……G H
)
……H I
==
……J L
description
……M X
&&
……Y [
x
……\ ]
.
……] ^

CategoryId
……^ h
==
……i k
expense
……l s
.
……s t

CategoryId
……t ~
&&…… Å
x……Ç É
.……É Ñ
Currency……Ñ å
==……ç è
expense……ê ó
.……ó ò
Currency……ò †
)……† °
;……° ¢
}
   
[
ÃÃ 
	HttpPatch
ÃÃ 
(
ÃÃ 
$str
ÃÃ #
)
ÃÃ# $
]
ÃÃ$ %
public
ÕÕ 

async
ÕÕ 
Task
ÕÕ 
<
ÕÕ 
ActionResult
ÕÕ "
>
ÕÕ" #
UpdateExpense
ÕÕ$ 1
(
ÕÕ1 2
Guid
ÕÕ2 6
id
ÕÕ7 9
,
ÕÕ9 :!
ExpensePatchRequest
ÕÕ; N
request
ÕÕO V
,
ÕÕV W
CancellationToken
ÕÕX i
ct
ÕÕj l
)
ÕÕl m
{
ŒŒ 
var
œœ 
expense
œœ 
=
œœ 
await
œœ 
db
œœ 
.
œœ 
Expenses
œœ '
.
œœ' (
	FindAsync
œœ( 1
(
œœ1 2
[
œœ2 3
id
œœ3 5
]
œœ5 6
,
œœ6 7
ct
œœ8 :
)
œœ: ;
;
œœ; <
if
œœ= ?
(
œœ@ A
expense
œœA H
is
œœI K
null
œœL P
)
œœP Q
return
œœR X
NotFound
œœY a
(
œœa b
)
œœb c
;
œœc d
if
–– 

(
–– 
request
–– 
.
–– 
Description
–– 
is
––  "
not
––# &
null
––' +
)
––+ ,
expense
––- 4
.
––4 5
Description
––5 @
=
––A B
request
––C J
.
––J K
Description
––K V
.
––V W
Trim
––W [
(
––[ \
)
––\ ]
;
––] ^
if
—— 

(
—— 
request
—— 
.
—— 

CategoryId
—— 
is
—— !
Guid
——" &

categoryId
——' 1
)
——1 2
{
““ 	
if
”” 
(
”” 
!
”” 
await
”” 
db
”” 
.
”” 
ExpenseCategories
”” +
.
””+ ,
AnyAsync
””, 4
(
””4 5
x
””5 6
=>
””7 9
x
””: ;
.
””; <
Id
””< >
==
””? A

categoryId
””B L
,
””L M
ct
””N P
)
””P Q
)
””Q R
return
””S Y

BadRequest
””Z d
(
””d e
new
””e h
{
””i j
message
””k r
=
””s t
$str””u í
}””ì î
)””î ï
;””ï ñ
expense
‘‘ 
.
‘‘ 

CategoryId
‘‘ 
=
‘‘  

categoryId
‘‘! +
;
‘‘+ ,
}
’’ 	
if
÷÷ 

(
÷÷ 
request
÷÷ 
.
÷÷ 
Type
÷÷ 
is
÷÷ 
ExpenseType
÷÷ '
type
÷÷( ,
)
÷÷, -
expense
÷÷. 5
.
÷÷5 6
Type
÷÷6 :
=
÷÷; <
type
÷÷= A
;
÷÷A B
if
◊◊ 

(
◊◊ 
request
◊◊ 
.
◊◊ 
Amount
◊◊ 
is
◊◊ 
decimal
◊◊ %
amount
◊◊& ,
)
◊◊, -
expense
◊◊. 5
.
◊◊5 6
Amount
◊◊6 <
=
◊◊= >
amount
◊◊? E
;
◊◊E F
if
ÿÿ 

(
ÿÿ 
request
ÿÿ 
.
ÿÿ 
Currency
ÿÿ 
is
ÿÿ 
not
ÿÿ  #
null
ÿÿ$ (
)
ÿÿ( )
expense
ÿÿ* 1
.
ÿÿ1 2
Currency
ÿÿ2 :
=
ÿÿ; <
request
ÿÿ= D
.
ÿÿD E
Currency
ÿÿE M
.
ÿÿM N
Trim
ÿÿN R
(
ÿÿR S
)
ÿÿS T
.
ÿÿT U
ToUpperInvariant
ÿÿU e
(
ÿÿe f
)
ÿÿf g
;
ÿÿg h
if
ŸŸ 

(
ŸŸ 
request
ŸŸ 
.
ŸŸ 
Date
ŸŸ 
is
ŸŸ 
DateOnly
ŸŸ $
date
ŸŸ% )
)
ŸŸ) *
expense
ŸŸ+ 2
.
ŸŸ2 3
Date
ŸŸ3 7
=
ŸŸ8 9
date
ŸŸ: >
;
ŸŸ> ?
if
⁄⁄ 

(
⁄⁄ 
request
⁄⁄ 
.
⁄⁄ 
	Recurring
⁄⁄ 
is
⁄⁄  
bool
⁄⁄! %
	recurring
⁄⁄& /
)
⁄⁄/ 0
expense
⁄⁄1 8
.
⁄⁄8 9
	Recurring
⁄⁄9 B
=
⁄⁄C D
	recurring
⁄⁄E N
;
⁄⁄N O
if
€€ 

(
€€ 
request
€€ 
.
€€ 
RecurrenceCycle
€€ #
is
€€$ &
BillingCycle
€€' 3
cycle
€€4 9
)
€€9 :
expense
€€; B
.
€€B C
RecurrenceCycle
€€C R
=
€€S T
cycle
€€U Z
;
€€Z [
if
‹‹ 

(
‹‹ 
request
‹‹ 
.
‹‹ 
IsNonDeductible
‹‹ #
is
‹‹$ &
bool
‹‹' +
nonDeductible
‹‹, 9
)
‹‹9 :
expense
‹‹; B
.
‹‹B C
IsNonDeductible
‹‹C R
=
‹‹S T
nonDeductible
‹‹U b
;
‹‹b c
if
›› 

(
›› 
request
›› 
.
›› #
IsNonDomiciledService
›› )
is
››* ,
bool
››- 1
foreign
››2 9
)
››9 :!
ApplyForeignService
››; N
(
››N O
expense
››O V
,
››V W
foreign
››X _
,
››_ `
request
››a h
.
››h i!
ForeignSupplierName
››i |
,
››| }
request››~ Ö
.››Ö Ü&
ForeignSupplierCountry››Ü ú
)››ú ù
;››ù û
if
ﬁﬁ 

(
ﬁﬁ 
string
ﬁﬁ 
.
ﬁﬁ  
IsNullOrWhiteSpace
ﬁﬁ %
(
ﬁﬁ% &
expense
ﬁﬁ& -
.
ﬁﬁ- .
Description
ﬁﬁ. 9
)
ﬁﬁ9 :
||
ﬁﬁ; =
string
ﬁﬁ> D
.
ﬁﬁD E 
IsNullOrWhiteSpace
ﬁﬁE W
(
ﬁﬁW X
expense
ﬁﬁX _
.
ﬁﬁ_ `
Currency
ﬁﬁ` h
)
ﬁﬁh i
||
ﬁﬁj l
expense
ﬁﬁm t
.
ﬁﬁt u
Amount
ﬁﬁu {
<=
ﬁﬁ| ~
$numﬁﬁ Ä
)ﬁﬁÄ Å
returnﬁﬁÇ à

BadRequestﬁﬁâ ì
(ﬁﬁì î
newﬁﬁî ó
{ﬁﬁò ô
messageﬁﬁö °
=ﬁﬁ¢ £
$strﬁﬁ§ ‡
}ﬁﬁ· ‚
)ﬁﬁ‚ „
;ﬁﬁ„ ‰
expense
ﬂﬂ 
.
ﬂﬂ 
	AmountPen
ﬂﬂ 
=
ﬂﬂ 
expense
ﬂﬂ #
.
ﬂﬂ# $
Amount
ﬂﬂ$ *
*
ﬂﬂ+ ,
await
ﬂﬂ- 2
db
ﬂﬂ3 5
.
ﬂﬂ5 6
RateToPenAsync
ﬂﬂ6 D
(
ﬂﬂD E
expense
ﬂﬂE L
.
ﬂﬂL M
Currency
ﬂﬂM U
,
ﬂﬂU V
expense
ﬂﬂW ^
.
ﬂﬂ^ _
Date
ﬂﬂ_ c
,
ﬂﬂc d
ct
ﬂﬂe g
)
ﬂﬂg h
;
ﬂﬂh i
await
‡‡ 
db
‡‡ 
.
‡‡ 
SaveChangesAsync
‡‡ !
(
‡‡! "
ct
‡‡" $
)
‡‡$ %
;
‡‡% &
await
‡‡' ,
db
‡‡- /
.
‡‡/ 0
Entry
‡‡0 5
(
‡‡5 6
expense
‡‡6 =
)
‡‡= >
.
‡‡> ?
	Reference
‡‡? H
(
‡‡H I
x
‡‡I J
=>
‡‡K M
x
‡‡N O
.
‡‡O P
Category
‡‡P X
)
‡‡X Y
.
‡‡Y Z
	LoadAsync
‡‡Z c
(
‡‡c d
ct
‡‡d f
)
‡‡f g
;
‡‡g h
return
‡‡i o
Ok
‡‡p r
(
‡‡r s

ExpenseDto
‡‡s }
(
‡‡} ~
expense‡‡~ Ö
)‡‡Ö Ü
)‡‡Ü á
;‡‡á à
}
·· 
private
„„ 
const
„„ 
string
„„ 
TaxDisclaimer
„„ &
=
„„' (
$str„„) ÿ
;„„ÿ Ÿ
private
ÊÊ 
static
ÊÊ 
(
ÊÊ 
DateOnly
ÊÊ 
From
ÊÊ !
,
ÊÊ! "
DateOnly
ÊÊ# +
To
ÊÊ, .
)
ÊÊ. /
Period
ÊÊ0 6
(
ÊÊ6 7
int
ÊÊ7 :
?
ÊÊ: ;
month
ÊÊ< A
,
ÊÊA B
int
ÊÊC F
year
ÊÊG K
)
ÊÊK L
=>
ÊÊM O
month
ÁÁ 
is
ÁÁ 
int
ÁÁ 
m
ÁÁ 
?
ÁÁ 
(
ÁÁ 
new
ÁÁ 
DateOnly
ÁÁ &
(
ÁÁ& '
year
ÁÁ' +
,
ÁÁ+ ,
m
ÁÁ- .
,
ÁÁ. /
$num
ÁÁ0 1
)
ÁÁ1 2
,
ÁÁ2 3
new
ÁÁ4 7
DateOnly
ÁÁ8 @
(
ÁÁ@ A
year
ÁÁA E
,
ÁÁE F
m
ÁÁG H
,
ÁÁH I
$num
ÁÁJ K
)
ÁÁK L
.
ÁÁL M
	AddMonths
ÁÁM V
(
ÁÁV W
$num
ÁÁW X
)
ÁÁX Y
.
ÁÁY Z
AddDays
ÁÁZ a
(
ÁÁa b
-
ÁÁb c
$num
ÁÁc d
)
ÁÁd e
)
ÁÁe f
:
ÁÁg h
(
ÁÁi j
new
ÁÁj m
DateOnly
ÁÁn v
(
ÁÁv w
year
ÁÁw {
,
ÁÁ{ |
$num
ÁÁ} ~
,
ÁÁ~ 
$numÁÁÄ Å
)ÁÁÅ Ç
,ÁÁÇ É
newÁÁÑ á
DateOnlyÁÁà ê
(ÁÁê ë
yearÁÁë ï
,ÁÁï ñ
$numÁÁó ô
,ÁÁô ö
$numÁÁõ ù
)ÁÁù û
)ÁÁû ü
;ÁÁü †
private
ÍÍ 
static
ÍÍ 
(
ÍÍ 
DateOnly
ÍÍ 
From
ÍÍ !
,
ÍÍ! "
DateOnly
ÍÍ# +
To
ÍÍ, .
)
ÍÍ. /
PreviousPeriod
ÍÍ0 >
(
ÍÍ> ?
int
ÍÍ? B
?
ÍÍB C
month
ÍÍD I
,
ÍÍI J
int
ÍÍK N
year
ÍÍO S
)
ÍÍS T
=>
ÍÍU W
month
ÎÎ 
switch
ÎÎ 
{
ÎÎ 
null
ÎÎ 
=>
ÎÎ 
Period
ÎÎ %
(
ÎÎ% &
null
ÎÎ& *
,
ÎÎ* +
year
ÎÎ, 0
-
ÎÎ1 2
$num
ÎÎ3 4
)
ÎÎ4 5
,
ÎÎ5 6
$num
ÎÎ7 8
=>
ÎÎ9 ;
Period
ÎÎ< B
(
ÎÎB C
$num
ÎÎC E
,
ÎÎE F
year
ÎÎG K
-
ÎÎL M
$num
ÎÎN O
)
ÎÎO P
,
ÎÎP Q
int
ÎÎR U
m
ÎÎV W
=>
ÎÎX Z
Period
ÎÎ[ a
(
ÎÎa b
m
ÎÎb c
-
ÎÎd e
$num
ÎÎf g
,
ÎÎg h
year
ÎÎi m
)
ÎÎm n
}
ÎÎo p
;
ÎÎp q
private
ÒÒ 
sealed
ÒÒ 
record
ÒÒ 
Sale
ÒÒ 
(
ÒÒ 
Guid
ÒÒ #
ClientId
ÒÒ$ ,
,
ÒÒ, -
DateOnly
ÒÒ. 6
Date
ÒÒ7 ;
,
ÒÒ; <
decimal
ÒÒ= D
BasePen
ÒÒE L
,
ÒÒL M
decimal
ÒÒN U
IgvPen
ÒÒV \
,
ÒÒ\ ]
bool
ÒÒ^ b
Gravada
ÒÒc j
,
ÒÒj k
decimal
ÒÒl s
RetentionPenÒÒt Ä
,ÒÒÄ Å
boolÒÒÇ Ü
PersonaNaturalÒÒá ï
=ÒÒñ ó
falseÒÒò ù
)ÒÒù û
{
ÚÚ 
public
ÛÛ 
bool
ÛÛ 
Mype
ÛÛ 
=>
ÛÛ 
!
ÛÛ 
PersonaNatural
ÛÛ +
;
ÛÛ+ ,
}
ÙÙ 
private
˚˚ 
async
˚˚ 
Task
˚˚ 
<
˚˚ 
List
˚˚ 
<
˚˚ 
Sale
˚˚  
>
˚˚  !
>
˚˚! "

SalesAsync
˚˚# -
(
˚˚- .
DateOnly
˚˚. 6
from
˚˚7 ;
,
˚˚; <
DateOnly
˚˚= E
to
˚˚F H
,
˚˚H I
CancellationToken
˚˚J [
ct
˚˚\ ^
)
˚˚^ _
{
¸¸ 
var
˝˝ 
start
˝˝ 
=
˝˝ 
from
˝˝ 
.
˝˝ 

ToDateTime
˝˝ #
(
˝˝# $
TimeOnly
˝˝$ ,
.
˝˝, -
MinValue
˝˝- 5
)
˝˝5 6
;
˝˝6 7
var
˝˝8 ;
end
˝˝< ?
=
˝˝@ A
to
˝˝B D
.
˝˝D E
AddDays
˝˝E L
(
˝˝L M
$num
˝˝M N
)
˝˝N O
.
˝˝O P

ToDateTime
˝˝P Z
(
˝˝Z [
TimeOnly
˝˝[ c
.
˝˝c d
MinValue
˝˝d l
)
˝˝l m
;
˝˝m n
var
˛˛ 
payments
˛˛ 
=
˛˛ 
await
˛˛ 
db
˛˛ 
.
˛˛  !
PaymentTransactions
˛˛  3
.
˛˛3 4
Where
˛˛4 9
(
˛˛9 :
x
˛˛: ;
=>
˛˛< >
x
˛˛? @
.
˛˛@ A
	CreatedAt
˛˛A J
>=
˛˛K M
start
˛˛N S
&&
˛˛T V
x
˛˛W X
.
˛˛X Y
	CreatedAt
˛˛Y b
<
˛˛c d
end
˛˛e h
)
˛˛h i
.
ˇˇ 
Select
ˇˇ 
(
ˇˇ 
x
ˇˇ 
=>
ˇˇ 
new
ˇˇ 
{
ˇˇ 
x
ˇˇ  
.
ˇˇ  !
ClientId
ˇˇ! )
,
ˇˇ) *
x
ˇˇ+ ,
.
ˇˇ, -
	CreatedAt
ˇˇ- 6
,
ˇˇ6 7
x
ˇˇ8 9
.
ˇˇ9 :
	AmountPen
ˇˇ: C
,
ˇˇC D
Document
ˇˇE M
=
ˇˇN O
db
ˇˇP R
.
ˇˇR S
TaxDocuments
ˇˇS _
.
ˇˇ_ `
FirstOrDefault
ˇˇ` n
(
ˇˇn o
d
ˇˇo p
=>
ˇˇq s
d
ˇˇt u
.
ˇˇu v#
PaymentTransactionIdˇˇv ä
==ˇˇã ç
xˇˇé è
.ˇˇè ê
Idˇˇê í
)ˇˇí ì
}ˇˇî ï
)ˇˇï ñ
.ˇˇñ ó
ToListAsyncˇˇó ¢
(ˇˇ¢ £
ctˇˇ£ •
)ˇˇ• ¶
;ˇˇ¶ ß
return
ÄÄ 
payments
ÄÄ 
.
ÄÄ 
Select
ÄÄ 
(
ÄÄ 
x
ÄÄ  
=>
ÄÄ! #
{
ÅÅ 	
var
ÇÇ 
document
ÇÇ 
=
ÇÇ 
x
ÇÇ 
.
ÇÇ 
Document
ÇÇ %
is
ÇÇ& (
{
ÇÇ) *
TotalAmount
ÇÇ+ 6
:
ÇÇ6 7
>
ÇÇ8 9
$num
ÇÇ: ;
}
ÇÇ< =
d
ÇÇ> ?
?
ÇÇ@ A
d
ÇÇB C
:
ÇÇD E
null
ÇÇF J
;
ÇÇJ K
var
ÉÉ 
	isFactura
ÉÉ 
=
ÉÉ 
document
ÉÉ $
?
ÉÉ$ %
.
ÉÉ% &
Type
ÉÉ& *
==
ÉÉ+ -
TaxDocumentType
ÉÉ. =
.
ÉÉ= >
Factura
ÉÉ> E
;
ÉÉE F
var
ÑÑ 
basePen
ÑÑ 
=
ÑÑ 
	isFactura
ÑÑ #
?
ÑÑ$ %
x
ÑÑ& '
.
ÑÑ' (
	AmountPen
ÑÑ( 1
*
ÑÑ2 3
document
ÑÑ4 <
!
ÑÑ< =
.
ÑÑ= >

BaseAmount
ÑÑ> H
/
ÑÑI J
document
ÑÑK S
.
ÑÑS T
TotalAmount
ÑÑT _
:
ÑÑ` a
x
ÑÑb c
.
ÑÑc d
	AmountPen
ÑÑd m
;
ÑÑm n
var
ÖÖ 
retentionPen
ÖÖ 
=
ÖÖ 
document
ÖÖ '
?
ÖÖ' (
.
ÖÖ( )
RetentionAmount
ÖÖ) 8
is
ÖÖ9 ;
decimal
ÖÖ< C
	retention
ÖÖD M
?
ÖÖN O
x
ÖÖP Q
.
ÖÖQ R
	AmountPen
ÖÖR [
*
ÖÖ\ ]
	retention
ÖÖ^ g
/
ÖÖh i
document
ÖÖj r
.
ÖÖr s
TotalAmount
ÖÖs ~
:ÖÖ Ä
$numÖÖÅ É
;ÖÖÉ Ñ
return
ÜÜ 
new
ÜÜ 
Sale
ÜÜ 
(
ÜÜ 
x
ÜÜ 
.
ÜÜ 
ClientId
ÜÜ &
,
ÜÜ& '
DateOnly
ÜÜ( 0
.
ÜÜ0 1
FromDateTime
ÜÜ1 =
(
ÜÜ= >
x
ÜÜ> ?
.
ÜÜ? @
	CreatedAt
ÜÜ@ I
)
ÜÜI J
,
ÜÜJ K
basePen
ÜÜL S
,
ÜÜS T
x
ÜÜU V
.
ÜÜV W
	AmountPen
ÜÜW `
-
ÜÜa b
basePen
ÜÜc j
,
ÜÜj k
	isFactura
ÜÜl u
,
ÜÜu v
retentionPenÜÜw É
,ÜÜÉ Ñ
documentÜÜÖ ç
?ÜÜç é
.ÜÜé è
TypeÜÜè ì
==ÜÜî ñ
TaxDocumentTypeÜÜó ¶
.ÜÜ¶ ß#
ReciboPorHonorariosÜÜß ∫
)ÜÜ∫ ª
;ÜÜª º
}
áá 	
)
áá	 

.
áá
 
ToList
áá 
(
áá 
)
áá 
;
áá 
}
àà 
[
ää 
HttpGet
ää 
(
ää 
$str
ää 
)
ää 
]
ää 
public
ãã 

async
ãã 
Task
ãã 
<
ãã 
ActionResult
ãã "
>
ãã" #
SalesReport
ãã$ /
(
ãã/ 0
int
ãã0 3
?
ãã3 4
month
ãã5 :
,
ãã: ;
int
ãã< ?
year
ãã@ D
,
ããD E
string
ããF L
currency
ããM U
,
ããU V
CancellationToken
ããW h
ct
ããi k
)
ããk l
{
åå 
if
çç 

(
çç 
currency
çç 
is
çç 
not
çç 
(
çç 
$str
çç "
or
çç# %
$str
çç& +
or
çç, .
$str
çç/ 4
)
çç4 5
)
çç5 6
return
çç7 =

BadRequest
çç> H
(
ççH I
new
ççI L
{
ççM N
message
ççO V
=
ççW X
$str
ççY k
}
ççl m
)
ççm n
;
ççn o
var
éé 
(
éé 
from
éé 
,
éé 
to
éé 
)
éé 
=
éé 
Period
éé 
(
éé  
month
éé  %
,
éé% &
year
éé' +
)
éé+ ,
;
éé, -
var
èè 
sales
èè 
=
èè 
await
èè 

SalesAsync
èè $
(
èè$ %
from
èè% )
,
èè) *
to
èè+ -
,
èè- .
ct
èè/ 1
)
èè1 2
;
èè2 3
decimal
êê 
basePen
êê 
=
êê 
sales
êê 
.
êê  
Sum
êê  #
(
êê# $
x
êê$ %
=>
êê& (
x
êê) *
.
êê* +
BasePen
êê+ 2
)
êê2 3
,
êê3 4
igvPen
êê5 ;
=
êê< =
sales
êê> C
.
êêC D
Sum
êêD G
(
êêG H
x
êêH I
=>
êêJ L
x
êêM N
.
êêN O
IgvPen
êêO U
)
êêU V
;
êêV W
var
ëë 
rate
ëë 
=
ëë 
currency
ëë 
==
ëë 
$str
ëë $
?
ëë% &
$num
ëë' )
:
ëë* +
await
ëë, 1
db
ëë2 4
.
ëë4 5
RateToPenAsync
ëë5 C
(
ëëC D
currency
ëëD L
,
ëëL M
to
ëëN P
,
ëëP Q
ct
ëëR T
)
ëëT U
;
ëëU V
return
íí 
Ok
íí 
(
íí 
new
íí 
{
íí 
baseImponible
íí %
=
íí& '
Math
íí( ,
.
íí, -
Round
íí- 2
(
íí2 3
basePen
íí3 :
/
íí; <
rate
íí= A
,
ííA B
$num
ííC D
)
ííD E
,
ííE F
igv
ííG J
=
ííK L
Math
ííM Q
.
ííQ R
Round
ííR W
(
ííW X
igvPen
ííX ^
/
íí_ `
rate
íía e
,
ííe f
$num
ííg h
)
ííh i
,
ííi j
total
íík p
=
ííq r
Math
íís w
.
ííw x
Round
ííx }
(
íí} ~
(
íí~ 
basePeníí Ü
+ííá à
igvPenííâ è
)ííè ê
/ííë í
rateííì ó
,ííó ò
$numííô ö
)ííö õ
}ííú ù
)ííù û
;ííû ü
}
ìì 
[
ïï 
HttpGet
ïï 
(
ïï 
$str
ïï "
)
ïï" #
]
ïï# $
public
ññ 

async
ññ 
Task
ññ 
<
ññ 
ActionResult
ññ "
>
ññ" #
TaxSummaryReport
ññ$ 4
(
ññ4 5
int
ññ5 8
?
ññ8 9
month
ññ: ?
,
ññ? @
int
ññA D
year
ññE I
,
ññI J
CancellationToken
ññK \
ct
ññ] _
)
ññ_ `
{
óó 
var
òò 
settings
òò 
=
òò 
await
òò 
TaxSettingsRow
òò +
(
òò+ ,
ct
òò, .
)
òò. /
;
òò/ 0
var
ôô 
(
ôô 
from
ôô 
,
ôô 
to
ôô 
)
ôô 
=
ôô 
Period
ôô 
(
ôô  
month
ôô  %
,
ôô% &
year
ôô' +
)
ôô+ ,
;
ôô, -
var
öö 
sales
öö 
=
öö 
await
öö 

SalesAsync
öö $
(
öö$ %
from
öö% )
,
öö) *
to
öö+ -
,
öö- .
ct
öö/ 1
)
öö1 2
;
öö2 3
decimal
õõ 
basePen
õõ 
=
õõ 
sales
õõ 
.
õõ  
Sum
õõ  #
(
õõ# $
x
õõ$ %
=>
õõ& (
x
õõ) *
.
õõ* +
BasePen
õõ+ 2
)
õõ2 3
,
õõ3 4
gravadasPen
õõ5 @
=
õõA B
sales
õõC H
.
õõH I
Where
õõI N
(
õõN O
x
õõO P
=>
õõQ S
x
õõT U
.
õõU V
Gravada
õõV ]
)
õõ] ^
.
õõ^ _
Sum
õõ_ b
(
õõb c
x
õõc d
=>
õõe g
x
õõh i
.
õõi j
BasePen
õõj q
)
õõq r
;
õõr s
var
úú 
igv
úú 
=
úú 
(
úú 
await
úú 
IgvMonthsAsync
úú '
(
úú' (
to
úú( *
,
úú* +
ct
úú, .
)
úú. /
)
úú/ 0
.
úú0 1
Where
úú1 6
(
úú6 7
x
úú7 8
=>
úú9 ;
x
úú< =
.
úú= >
Month
úú> C
>=
úúD F
from
úúG K
)
úúK L
.
úúL M
ToList
úúM S
(
úúS T
)
úúT U
;
úúU V
return
ûû 
Ok
ûû 
(
ûû 
new
ûû 
{
üü 	
ventasGravadasPen
†† 
=
†† 
Math
††  $
.
††$ %
Round
††% *
(
††* +
gravadasPen
††+ 6
,
††6 7
$num
††8 9
)
††9 :
,
††: ;!
ventasNoGravadasPen
††< O
=
††P Q
Math
††R V
.
††V W
Round
††W \
(
††\ ]
basePen
††] d
-
††e f
gravadasPen
††g r
,
††r s
$num
††t u
)
††u v
,
††v w
igvEstimado††x É
=††Ñ Ö
Math††Ü ä
.††ä ã
Round††ã ê
(††ê ë
sales††ë ñ
.††ñ ó
Sum††ó ö
(††ö õ
x††õ ú
=>††ù ü
x††† °
.††° ¢
IgvPen††¢ ®
)††® ©
,††© ™
$num††´ ¨
)††¨ ≠
,††≠ Æ
rentaEstimada††Ø º
=††Ω æ
Math††ø √
.††√ ƒ
Round††ƒ …
(††…  
sales††  œ
.††œ –
Where††– ’
(††’ ÷
x††÷ ◊
=>††ÿ ⁄
x††€ ‹
.††‹ ›
Mype††› ·
)††· ‚
.††‚ „
Sum††„ Ê
(††Ê Á
x††Á Ë
=>††È Î
x††Ï Ì
.††Ì Ó
BasePen††Ó ı
)††ı ˆ
*††˜ ¯
settings††˘ Å
.††Å Ç
	RentaRate††Ç ã
,††ã å
$num††ç é
)††é è
,††è ê'
ventasPersonaNaturalPen††ë ®
=††© ™
Math††´ Ø
.††Ø ∞
Round††∞ µ
(††µ ∂
sales††∂ ª
.††ª º
Where††º ¡
(††¡ ¬
x††¬ √
=>††ƒ ∆
x††« »
.††» …
PersonaNatural††… ◊
)††◊ ÿ
.††ÿ Ÿ
Sum††Ÿ ‹
(††‹ ›
x††› ﬁ
=>††ﬂ ·
x††‚ „
.††„ ‰
BasePen††‰ Î
)††Î Ï
,††Ï Ì
$num††Ó Ô
)††Ô 
,†† Ò
tasa††Ú ˆ
=††˜ ¯
new††˘ ¸
{††˝ ˛
igvRate††ˇ Ü
=††á à
settings††â ë
.††ë í
IgvRate††í ô
,††ô ö
	rentaRate††õ §
=††• ¶
settings††ß Ø
.††Ø ∞
	RentaRate††∞ π
}††∫ ª
,††ª º

disclaimer††Ω «
=††» …
TaxDisclaimer††  ◊
,††◊ ÿ
igv
¢¢ 
=
¢¢ 
new
¢¢ 
{
££ 
debitoFiscal
§§ 
=
§§ 
Math
§§ #
.
§§# $
Round
§§$ )
(
§§) *
igv
§§* -
.
§§- .
Sum
§§. 1
(
§§1 2
x
§§2 3
=>
§§4 6
x
§§7 8
.
§§8 9
Debito
§§9 ?
)
§§? @
,
§§@ A
$num
§§B C
)
§§C D
,
§§D E
creditoFiscal
§§F S
=
§§T U
Math
§§V Z
.
§§Z [
Round
§§[ `
(
§§` a
igv
§§a d
.
§§d e
Sum
§§e h
(
§§h i
x
§§i j
=>
§§k m
x
§§n o
.
§§o p
Credito
§§p w
)
§§w x
,
§§x y
$num
§§z {
)
§§{ |
,
§§| }!
saldoAFavorAnterior
•• #
=
••$ %
Math
••& *
.
••* +
Round
••+ 0
(
••0 1
igv
••1 4
.
••4 5
FirstOrDefault
••5 C
(
••C D
)
••D E
?
••E F
.
••F G
SaldoAnterior
••G T
??
••U W
$num
••X Z
,
••Z [
$num
••\ ]
)
••] ^
,
••^ _
	igvAPagar
••` i
=
••j k
Math
••l p
.
••p q
Round
••q v
(
••v w
igv
••w z
.
••z {
Sum
••{ ~
(
••~ 
x•• Ä
=>••Å É
x••Ñ Ö
.••Ö Ü
APagar••Ü å
)••å ç
,••ç é
$num••è ê
)••ê ë
,••ë í"
saldoAFavorSiguiente
¶¶ $
=
¶¶% &
Math
¶¶' +
.
¶¶+ ,
Round
¶¶, 1
(
¶¶1 2
igv
¶¶2 5
.
¶¶5 6
LastOrDefault
¶¶6 C
(
¶¶C D
)
¶¶D E
?
¶¶E F
.
¶¶F G
SaldoSiguiente
¶¶G U
??
¶¶V X
$num
¶¶Y [
,
¶¶[ \
$num
¶¶] ^
)
¶¶^ _
,
¶¶_ `
meses
ßß 
=
ßß 
igv
ßß 
.
ßß 
Select
ßß "
(
ßß" #
x
ßß# $
=>
ßß% '
new
ßß( +
{
ßß, -
mes
ßß. 1
=
ßß2 3
x
ßß4 5
.
ßß5 6
Month
ßß6 ;
.
ßß; <
ToString
ßß< D
(
ßßD E
$str
ßßE N
)
ßßN O
,
ßßO P
debitoFiscal
ßßQ ]
=
ßß^ _
Math
ßß` d
.
ßßd e
Round
ßße j
(
ßßj k
x
ßßk l
.
ßßl m
Debito
ßßm s
,
ßßs t
$num
ßßu v
)
ßßv w
,
ßßw x
creditoFiscalßßy Ü
=ßßá à
Mathßßâ ç
.ßßç é
Roundßßé ì
(ßßì î
xßßî ï
.ßßï ñ
Creditoßßñ ù
,ßßù û
$numßßü †
)ßß† °
,ßß° ¢#
saldoAFavorAnteriorßß£ ∂
=ßß∑ ∏
Mathßßπ Ω
.ßßΩ æ
Roundßßæ √
(ßß√ ƒ
xßßƒ ≈
.ßß≈ ∆
SaldoAnteriorßß∆ ”
,ßß” ‘
$numßß’ ÷
)ßß÷ ◊
,ßß◊ ÿ
	igvAPagarßßŸ ‚
=ßß„ ‰
MathßßÂ È
.ßßÈ Í
RoundßßÍ Ô
(ßßÔ 
xßß Ò
.ßßÒ Ú
APagarßßÚ ¯
,ßß¯ ˘
$numßß˙ ˚
)ßß˚ ¸
,ßß¸ ˝$
saldoAFavorSiguienteßß˛ í
=ßßì î
Mathßßï ô
.ßßô ö
Roundßßö ü
(ßßü †
xßß† °
.ßß° ¢
SaldoSiguienteßß¢ ∞
,ßß∞ ±
$numßß≤ ≥
)ßß≥ ¥
}ßßµ ∂
)ßß∂ ∑
,ßß∑ ∏
}
®® 
,
®® 
}
©© 	
)
©©	 

;
©©
 
}
™™ 
internal
¨¨ 
sealed
¨¨ 
record
¨¨ 
IgvMonth
¨¨ #
(
¨¨# $
DateOnly
¨¨$ ,
Month
¨¨- 2
,
¨¨2 3
decimal
¨¨4 ;
Debito
¨¨< B
,
¨¨B C
decimal
¨¨D K
Credito
¨¨L S
,
¨¨S T
decimal
¨¨U \
SaldoAnterior
¨¨] j
,
¨¨j k
decimal
¨¨l s
APagar
¨¨t z
,
¨¨z {
decimal¨¨| É
SaldoSiguiente¨¨Ñ í
)¨¨í ì
;¨¨ì î
internal
≤≤ 
async
≤≤ 
Task
≤≤ 
<
≤≤ 
List
≤≤ 
<
≤≤ 
IgvMonth
≤≤ %
>
≤≤% &
>
≤≤& '
IgvMonthsAsync
≤≤( 6
(
≤≤6 7
DateOnly
≤≤7 ?
to
≤≤@ B
,
≤≤B C
CancellationToken
≤≤D U
ct
≤≤V X
)
≤≤X Y
{
≥≥ 
var
¥¥ 
end
¥¥ 
=
¥¥ 
new
¥¥ 
DateOnly
¥¥ 
(
¥¥ 
to
¥¥ !
.
¥¥! "
Year
¥¥" &
,
¥¥& '
to
¥¥( *
.
¥¥* +
Month
¥¥+ 0
,
¥¥0 1
$num
¥¥2 3
)
¥¥3 4
;
¥¥4 5
DateOnly
µµ 
?
µµ 
	firstSale
µµ 
=
µµ 
await
µµ #
db
µµ$ &
.
µµ& '!
PaymentTransactions
µµ' :
.
µµ: ;
OrderBy
µµ; B
(
µµB C
x
µµC D
=>
µµE G
x
µµH I
.
µµI J
	CreatedAt
µµJ S
)
µµS T
.
µµT U
Select
µµU [
(
µµ[ \
x
µµ\ ]
=>
µµ^ `
(
µµa b
DateTime
µµb j
?
µµj k
)
µµk l
x
µµl m
.
µµm n
	CreatedAt
µµn w
)
µµw x
.
µµx y"
FirstOrDefaultAsyncµµy å
(µµå ç
ctµµç è
)µµè ê
isµµë ì
DateTimeµµî ú
dµµù û
?µµü †
DateOnlyµµ° ©
.µµ© ™
FromDateTimeµµ™ ∂
(µµ∂ ∑
dµµ∑ ∏
)µµ∏ π
:µµ∫ ª
nullµµº ¿
;µµ¿ ¡
DateOnly
∂∂ 
?
∂∂ 
firstPurchase
∂∂ 
=
∂∂  !
await
∂∂" '
db
∂∂( *
.
∂∂* +
	Purchases
∂∂+ 4
.
∂∂4 5
OrderBy
∂∂5 <
(
∂∂< =
x
∂∂= >
=>
∂∂? A
x
∂∂B C
.
∂∂C D
Period
∂∂D J
)
∂∂J K
.
∂∂K L
Select
∂∂L R
(
∂∂R S
x
∂∂S T
=>
∂∂U W
(
∂∂X Y
DateOnly
∂∂Y a
?
∂∂a b
)
∂∂b c
x
∂∂c d
.
∂∂d e
Period
∂∂e k
)
∂∂k l
.
∂∂l m"
FirstOrDefaultAsync∂∂m Ä
(∂∂Ä Å
ct∂∂Å É
)∂∂É Ñ
;∂∂Ñ Ö
var
∑∑ 
first
∑∑ 
=
∑∑ 
new
∑∑ 
[
∑∑ 
]
∑∑ 
{
∑∑ 
	firstSale
∑∑ %
,
∑∑% &
firstPurchase
∑∑' 4
}
∑∑5 6
.
∑∑6 7
Where
∑∑7 <
(
∑∑< =
x
∑∑= >
=>
∑∑? A
x
∑∑B C
is
∑∑D F
not
∑∑G J
null
∑∑K O
)
∑∑O P
.
∑∑P Q
Select
∑∑Q W
(
∑∑W X
x
∑∑X Y
=>
∑∑Z \
x
∑∑] ^
!
∑∑^ _
.
∑∑_ `
Value
∑∑` e
)
∑∑e f
.
∑∑f g
DefaultIfEmpty
∑∑g u
(
∑∑u v
end
∑∑v y
)
∑∑y z
.
∑∑z {
Min
∑∑{ ~
(
∑∑~ 
)∑∑ Ä
;∑∑Ä Å
var
∏∏ 
start
∏∏ 
=
∏∏ 
new
∏∏ 
DateOnly
∏∏  
(
∏∏  !
first
∏∏! &
.
∏∏& '
Year
∏∏' +
,
∏∏+ ,
first
∏∏- 2
.
∏∏2 3
Month
∏∏3 8
,
∏∏8 9
$num
∏∏: ;
)
∏∏; <
;
∏∏< =
if
ππ 

(
ππ 
start
ππ 
>
ππ 
end
ππ 
)
ππ 
start
ππ 
=
ππ  
end
ππ! $
;
ππ$ %
var
∫∫ 
sales
∫∫ 
=
∫∫ 
await
∫∫ 

SalesAsync
∫∫ $
(
∫∫$ %
start
∫∫% *
,
∫∫* +
end
∫∫, /
.
∫∫/ 0
	AddMonths
∫∫0 9
(
∫∫9 :
$num
∫∫: ;
)
∫∫; <
.
∫∫< =
AddDays
∫∫= D
(
∫∫D E
-
∫∫E F
$num
∫∫F G
)
∫∫G H
,
∫∫H I
ct
∫∫J L
)
∫∫L M
;
∫∫M N
var
ªª 
	purchases
ªª 
=
ªª 
await
ªª 
db
ªª  
.
ªª  !
	Purchases
ªª! *
.
ªª* +
Where
ªª+ 0
(
ªª0 1
x
ªª1 2
=>
ªª3 5
x
ªª6 7
.
ªª7 8
Period
ªª8 >
>=
ªª? A
start
ªªB G
&&
ªªH J
x
ªªK L
.
ªªL M
Period
ªªM S
<=
ªªT V
end
ªªW Z
)
ªªZ [
.
ªª[ \
ToListAsync
ªª\ g
(
ªªg h
ct
ªªh j
)
ªªj k
;
ªªk l
var
ΩΩ 
settings
ΩΩ 
=
ΩΩ 
await
ΩΩ 
TaxSettingsRow
ΩΩ +
(
ΩΩ+ ,
ct
ΩΩ, .
)
ΩΩ. /
;
ΩΩ/ 0
var
ææ 
form1662
ææ 
=
ææ 
settings
ææ 
.
ææ  
Use1662AsCredit
ææ  /
?
øø 
(
øø 
await
øø 
db
øø 
.
øø 
Expenses
øø  
.
øø  !
Where
øø! &
(
øø& '
x
øø' (
=>
øø) +
x
øø, -
.
øø- .#
IsNonDomiciledService
øø. C
&&
øøD F
x
øøG H
.
øøH I
Form1662PaidAt
øøI W
!=
øøX Z
null
øø[ _
&&
øø` b
x
øøc d
.
øød e
Form1662PaidAt
øøe s
>=
øøt v
start
øøw |
&&
øø} 
xøøÄ Å
.øøÅ Ç
Form1662PaidAtøøÇ ê
<=øøë ì
endøøî ó
.øøó ò
	AddMonthsøøò °
(øø° ¢
$numøø¢ £
)øø£ §
.øø§ •
AddDaysøø• ¨
(øø¨ ≠
-øø≠ Æ
$numøøÆ Ø
)øøØ ∞
)øø∞ ±
.øø± ≤
ToListAsyncøø≤ Ω
(øøΩ æ
ctøøæ ¿
)øø¿ ¡
)øø¡ ¬
.
¿¿ 
GroupBy
¿¿ 
(
¿¿ 
x
¿¿ 
=>
¿¿ 
new
¿¿ !
DateOnly
¿¿" *
(
¿¿* +
x
¿¿+ ,
.
¿¿, -
Form1662PaidAt
¿¿- ;
!
¿¿; <
.
¿¿< =
Value
¿¿= B
.
¿¿B C
Year
¿¿C G
,
¿¿G H
x
¿¿I J
.
¿¿J K
Form1662PaidAt
¿¿K Y
.
¿¿Y Z
Value
¿¿Z _
.
¿¿_ `
Month
¿¿` e
,
¿¿e f
$num
¿¿g h
)
¿¿h i
)
¿¿i j
.
¿¿j k
ToDictionary
¿¿k w
(
¿¿w x
g
¿¿x y
=>
¿¿z |
g
¿¿} ~
.
¿¿~ 
Key¿¿ Ç
,¿¿Ç É
g¿¿Ñ Ö
=>¿¿Ü à
g¿¿â ä
.¿¿ä ã
Sum¿¿ã é
(¿¿é è
x¿¿è ê
=>¿¿ë ì
Form1662¿¿î ú
.¿¿ú ù
Igv¿¿ù †
(¿¿† °
x¿¿° ¢
,¿¿¢ £
settings¿¿§ ¨
.¿¿¨ ≠
IgvRate¿¿≠ ¥
)¿¿¥ µ
)¿¿µ ∂
)¿¿∂ ∑
:
¡¡ 
[
¡¡ 
]
¡¡ 
;
¡¡ 
var
¬¬ 
months
¬¬ 
=
¬¬ 
new
¬¬ 
List
¬¬ 
<
¬¬ 
IgvMonth
¬¬ &
>
¬¬& '
(
¬¬' (
)
¬¬( )
;
¬¬) *
var
¬¬+ .
carry
¬¬/ 4
=
¬¬5 6
$num
¬¬7 9
;
¬¬9 :
for
√√ 
(
√√ 
var
√√ 
month
√√ 
=
√√ 
start
√√ 
;
√√ 
month
√√  %
<=
√√& (
end
√√) ,
;
√√, -
month
√√. 3
=
√√4 5
month
√√6 ;
.
√√; <
	AddMonths
√√< E
(
√√E F
$num
√√F G
)
√√G H
)
√√H I
{
ƒƒ 	
var
≈≈ 
monthEnd
≈≈ 
=
≈≈ 
month
≈≈  
.
≈≈  !
	AddMonths
≈≈! *
(
≈≈* +
$num
≈≈+ ,
)
≈≈, -
.
≈≈- .
AddDays
≈≈. 5
(
≈≈5 6
-
≈≈6 7
$num
≈≈7 8
)
≈≈8 9
;
≈≈9 :
var
∆∆ 
debito
∆∆ 
=
∆∆ 
sales
∆∆ 
.
∆∆ 
Where
∆∆ $
(
∆∆$ %
x
∆∆% &
=>
∆∆' )
x
∆∆* +
.
∆∆+ ,
Date
∆∆, 0
>=
∆∆1 3
month
∆∆4 9
&&
∆∆: <
x
∆∆= >
.
∆∆> ?
Date
∆∆? C
<=
∆∆D F
monthEnd
∆∆G O
)
∆∆O P
.
∆∆P Q
Sum
∆∆Q T
(
∆∆T U
x
∆∆U V
=>
∆∆W Y
x
∆∆Z [
.
∆∆[ \
IgvPen
∆∆\ b
)
∆∆b c
;
∆∆c d
var
«« 
credito
«« 
=
«« 
	purchases
«« #
.
««# $
Where
««$ )
(
««) *
x
««* +
=>
««, .
x
««/ 0
.
««0 1
Period
««1 7
==
««8 :
month
««; @
)
««@ A
.
««A B
Sum
««B E
(
««E F
x
««F G
=>
««H J
x
««K L
.
««L M
TaxCreditPen
««M Y
)
««Y Z
+
««[ \
form1662
««] e
.
««e f
GetValueOrDefault
««f w
(
««w x
month
««x }
)
««} ~
;
««~ 
var
»» 
result
»» 
=
»» 
debito
»» 
-
»»  !
credito
»»" )
-
»»* +
carry
»», 1
;
»»1 2
months
…… 
.
…… 
Add
…… 
(
…… 
new
…… 
IgvMonth
…… #
(
……# $
month
……$ )
,
……) *
debito
……+ 1
,
……1 2
credito
……3 :
,
……: ;
carry
……< A
,
……A B
Math
……C G
.
……G H
Max
……H K
(
……K L
result
……L R
,
……R S
$num
……T V
)
……V W
,
……W X
Math
……Y ]
.
……] ^
Max
……^ a
(
……a b
-
……b c
result
……c i
,
……i j
$num
……k m
)
……m n
)
……n o
)
……o p
;
……p q
carry
   
=
   
Math
   
.
   
Max
   
(
   
-
   
result
   $
,
  $ %
$num
  & (
)
  ( )
;
  ) *
}
ÀÀ 	
return
ÃÃ 
months
ÃÃ 
;
ÃÃ 
}
ÕÕ 
[
œœ 
HttpGet
œœ 
(
œœ 
$str
œœ 
)
œœ  
]
œœ  !
public
–– 

async
–– 
Task
–– 
<
–– 
ActionResult
–– "
>
––" #
ExpensesReport
––$ 2
(
––2 3
int
––3 6
?
––6 7
month
––8 =
,
––= >
int
––? B
year
––C G
,
––G H
CancellationToken
––I Z
ct
––[ ]
)
––] ^
{
—— 
var
““ 
(
““ 
from
““ 
,
““ 
to
““ 
)
““ 
=
““ 
Period
““ 
(
““  
month
““  %
,
““% &
year
““' +
)
““+ ,
;
““, -
var
”” 
expenses
”” 
=
”” 
await
”” 
db
”” 
.
””  
Expenses
””  (
.
””( )
Include
””) 0
(
””0 1
x
””1 2
=>
””3 5
x
””6 7
.
””7 8
Category
””8 @
)
””@ A
.
””A B
Where
””B G
(
””G H
x
””H I
=>
””J L
x
””M N
.
””N O
Date
””O S
>=
””T V
from
””W [
&&
””\ ^
x
””_ `
.
””` a
Date
””a e
<=
””f h
to
””i k
)
””k l
.
””l m
ToListAsync
””m x
(
””x y
ct
””y {
)
””{ |
;
””| }
return
‘‘ 
Ok
‘‘ 
(
‘‘ 
new
‘‘ 
{
‘‘ 
total
‘‘ 
=
‘‘ 
Math
‘‘  $
.
‘‘$ %
Round
‘‘% *
(
‘‘* +
expenses
‘‘+ 3
.
‘‘3 4
Sum
‘‘4 7
(
‘‘7 8
x
‘‘8 9
=>
‘‘: <
x
‘‘= >
.
‘‘> ?
	AmountPen
‘‘? H
)
‘‘H I
,
‘‘I J
$num
‘‘K L
)
‘‘L M
,
‘‘M N
porCategoria
‘‘O [
=
‘‘\ ]
expenses
‘‘^ f
.
‘‘f g
GroupBy
‘‘g n
(
‘‘n o
x
‘‘o p
=>
‘‘q s
x
‘‘t u
.
‘‘u v
Category
‘‘v ~
?
‘‘~ 
.‘‘ Ä
Name‘‘Ä Ñ
??‘‘Ö á
$str‘‘à ó
)‘‘ó ò
.‘‘ò ô!
OrderByDescending‘‘ô ™
(‘‘™ ´
g‘‘´ ¨
=>‘‘≠ Ø
g‘‘∞ ±
.‘‘± ≤
Sum‘‘≤ µ
(‘‘µ ∂
x‘‘∂ ∑
=>‘‘∏ ∫
x‘‘ª º
.‘‘º Ω
	AmountPen‘‘Ω ∆
)‘‘∆ «
)‘‘« »
.‘‘» …
Select‘‘… œ
(‘‘œ –
g‘‘– —
=>‘‘“ ‘
new‘‘’ ÿ
{‘‘Ÿ ⁄
	categoria‘‘€ ‰
=‘‘Â Ê
g‘‘Á Ë
.‘‘Ë È
Key‘‘È Ï
,‘‘Ï Ì
monto‘‘Ó Û
=‘‘Ù ı
Math‘‘ˆ ˙
.‘‘˙ ˚
Round‘‘˚ Ä
(‘‘Ä Å
g‘‘Å Ç
.‘‘Ç É
Sum‘‘É Ü
(‘‘Ü á
x‘‘á à
=>‘‘â ã
x‘‘å ç
.‘‘ç é
	AmountPen‘‘é ó
)‘‘ó ò
,‘‘ò ô
$num‘‘ö õ
)‘‘õ ú
}‘‘ù û
)‘‘û ü
}‘‘† °
)‘‘° ¢
;‘‘¢ £
}
’’ 
[
‹‹ 
HttpGet
‹‹ 
(
‹‹ 
$str
‹‹ 
)
‹‹ 
]
‹‹ 
public
›› 

async
›› 
Task
›› 
<
›› 
ActionResult
›› "
>
››" #
	NetReport
››$ -
(
››- .
int
››. 1
?
››1 2
month
››3 8
,
››8 9
int
››: =
year
››> B
,
››B C
CancellationToken
››D U
ct
››V X
)
››X Y
{
ﬁﬁ 
var
ﬂﬂ 
settings
ﬂﬂ 
=
ﬂﬂ 
await
ﬂﬂ 
TaxSettingsRow
ﬂﬂ +
(
ﬂﬂ+ ,
ct
ﬂﬂ, .
)
ﬂﬂ. /
;
ﬂﬂ/ 0
var
‡‡ 
(
‡‡ 
from
‡‡ 
,
‡‡ 
to
‡‡ 
)
‡‡ 
=
‡‡ 
Period
‡‡ 
(
‡‡  
month
‡‡  %
,
‡‡% &
year
‡‡' +
)
‡‡+ ,
;
‡‡, -
var
·· 
sales
·· 
=
·· 
await
·· 

SalesAsync
·· $
(
··$ %
from
··% )
,
··) *
to
··+ -
,
··- .
ct
··/ 1
)
··1 2
;
··2 3
var
‚‚ 
expenses
‚‚ 
=
‚‚ 
await
‚‚ 
db
‚‚ 
.
‚‚  
Expenses
‚‚  (
.
‚‚( )
Include
‚‚) 0
(
‚‚0 1
x
‚‚1 2
=>
‚‚3 5
x
‚‚6 7
.
‚‚7 8
Category
‚‚8 @
)
‚‚@ A
.
‚‚A B
Where
‚‚B G
(
‚‚G H
x
‚‚H I
=>
‚‚J L
x
‚‚M N
.
‚‚N O
Date
‚‚O S
>=
‚‚T V
from
‚‚W [
&&
‚‚\ ^
x
‚‚_ `
.
‚‚` a
Date
‚‚a e
<=
‚‚f h
to
‚‚i k
)
‚‚k l
.
‚‚l m
ToListAsync
‚‚m x
(
‚‚x y
ct
‚‚y {
)
‚‚{ |
;
‚‚| }
var
„„ 
result
„„ 
=
„„ 

NetFigures
„„ 
(
„„  
sales
„„  %
,
„„% &
expenses
„„' /
,
„„/ 0
settings
„„1 9
.
„„9 :
	RentaRate
„„: C
)
„„C D
;
„„D E
var
‰‰ 
serie
‰‰ 
=
‰‰ 

Enumerable
‰‰ 
.
‰‰ 
Range
‰‰ $
(
‰‰$ %
$num
‰‰% &
,
‰‰& '
month
‰‰( -
is
‰‰. 0
null
‰‰1 5
?
‰‰6 7
$num
‰‰8 :
:
‰‰; <
$num
‰‰= >
)
‰‰> ?
.
‰‰? @
Select
‰‰@ F
(
‰‰F G
i
‰‰G H
=>
‰‰I K
from
‰‰L P
.
‰‰P Q
	AddMonths
‰‰Q Z
(
‰‰Z [
i
‰‰[ \
)
‰‰\ ]
)
‰‰] ^
.
‰‰^ _
Select
‰‰_ e
(
‰‰e f
start
‰‰f k
=>
‰‰l n
{
ÂÂ 	
var
ÊÊ 
end
ÊÊ 
=
ÊÊ 
start
ÊÊ 
.
ÊÊ 
	AddMonths
ÊÊ %
(
ÊÊ% &
$num
ÊÊ& '
)
ÊÊ' (
.
ÊÊ( )
AddDays
ÊÊ) 0
(
ÊÊ0 1
-
ÊÊ1 2
$num
ÊÊ2 3
)
ÊÊ3 4
;
ÊÊ4 5
var
ÁÁ 
n
ÁÁ 
=
ÁÁ 

NetFigures
ÁÁ 
(
ÁÁ 
sales
ÁÁ $
.
ÁÁ$ %
Where
ÁÁ% *
(
ÁÁ* +
x
ÁÁ+ ,
=>
ÁÁ- /
x
ÁÁ0 1
.
ÁÁ1 2
Date
ÁÁ2 6
>=
ÁÁ7 9
start
ÁÁ: ?
&&
ÁÁ@ B
x
ÁÁC D
.
ÁÁD E
Date
ÁÁE I
<=
ÁÁJ L
end
ÁÁM P
)
ÁÁP Q
,
ÁÁQ R
expenses
ÁÁS [
.
ÁÁ[ \
Where
ÁÁ\ a
(
ÁÁa b
x
ÁÁb c
=>
ÁÁd f
x
ÁÁg h
.
ÁÁh i
Date
ÁÁi m
>=
ÁÁn p
start
ÁÁq v
&&
ÁÁw y
x
ÁÁz {
.
ÁÁ{ |
DateÁÁ| Ä
<=ÁÁÅ É
endÁÁÑ á
)ÁÁá à
,ÁÁà â
settingsÁÁä í
.ÁÁí ì
	RentaRateÁÁì ú
)ÁÁú ù
;ÁÁù û
return
ËË 
new
ËË 
NetPoint
ËË 
(
ËË  
start
ËË  %
.
ËË% &
ToString
ËË& .
(
ËË. /
$str
ËË/ 8
)
ËË8 9
,
ËË9 :
Math
ËË; ?
.
ËË? @
Round
ËË@ E
(
ËËE F
n
ËËF G
.
ËËG H
Ventas
ËËH N
,
ËËN O
$num
ËËP Q
)
ËËQ R
,
ËËR S
Math
ËËT X
.
ËËX Y
Round
ËËY ^
(
ËË^ _
n
ËË_ `
.
ËË` a
Gastos
ËËa g
,
ËËg h
$num
ËËi j
)
ËËj k
,
ËËk l
Math
ËËm q
.
ËËq r
Round
ËËr w
(
ËËw x
n
ËËx y
.
ËËy z
	ImpuestosËËz É
,ËËÉ Ñ
$numËËÖ Ü
)ËËÜ á
,ËËá à
MathËËâ ç
.ËËç é
RoundËËé ì
(ËËì î
nËËî ï
.ËËï ñ
NetaËËñ ö
,ËËö õ
$numËËú ù
)ËËù û
)ËËû ü
;ËËü †
}
ÈÈ 	
)
ÈÈ	 

.
ÈÈ
 
ToList
ÈÈ 
(
ÈÈ 
)
ÈÈ 
;
ÈÈ 
return
ÍÍ 
Ok
ÍÍ 
(
ÍÍ 
new
ÍÍ 
{
ÎÎ 	
	ventasPen
ÏÏ 
=
ÏÏ 
Math
ÏÏ 
.
ÏÏ 
Round
ÏÏ "
(
ÏÏ" #
result
ÏÏ# )
.
ÏÏ) *
Ventas
ÏÏ* 0
,
ÏÏ0 1
$num
ÏÏ2 3
)
ÏÏ3 4
,
ÏÏ4 5
	gastosPen
ÏÏ6 ?
=
ÏÏ@ A
Math
ÏÏB F
.
ÏÏF G
Round
ÏÏG L
(
ÏÏL M
result
ÏÏM S
.
ÏÏS T
Gastos
ÏÏT Z
,
ÏÏZ [
$num
ÏÏ\ ]
)
ÏÏ] ^
,
ÏÏ^ _"
utilidadOperativaPen
ÏÏ` t
=
ÏÏu v
Math
ÏÏw {
.
ÏÏ{ |
RoundÏÏ| Å
(ÏÏÅ Ç
resultÏÏÇ à
.ÏÏà â
VentasÏÏâ è
-ÏÏê ë
resultÏÏí ò
.ÏÏò ô
GastosÏÏô ü
,ÏÏü †
$numÏÏ° ¢
)ÏÏ¢ £
,ÏÏ£ §
	rentaRate
ÌÌ 
=
ÌÌ 
settings
ÌÌ  
.
ÌÌ  !
	RentaRate
ÌÌ! *
,
ÌÌ* +
impuestosPen
ÌÌ, 8
=
ÌÌ9 :
Math
ÌÌ; ?
.
ÌÌ? @
Round
ÌÌ@ E
(
ÌÌE F
result
ÌÌF L
.
ÌÌL M
	Impuestos
ÌÌM V
,
ÌÌV W
$num
ÌÌX Y
)
ÌÌY Z
,
ÌÌZ [
utilidadNetaPen
ÓÓ 
=
ÓÓ 
Math
ÓÓ "
.
ÓÓ" #
Round
ÓÓ# (
(
ÓÓ( )
result
ÓÓ) /
.
ÓÓ/ 0
Neta
ÓÓ0 4
,
ÓÓ4 5
$num
ÓÓ6 7
)
ÓÓ7 8
,
ÓÓ8 9
margen
ÓÓ: @
=
ÓÓA B
result
ÓÓC I
.
ÓÓI J
Ventas
ÓÓJ P
==
ÓÓQ S
$num
ÓÓT U
?
ÓÓV W
$num
ÓÓX Z
:
ÓÓ[ \
Math
ÓÓ] a
.
ÓÓa b
Round
ÓÓb g
(
ÓÓg h
result
ÓÓh n
.
ÓÓn o
Neta
ÓÓo s
/
ÓÓt u
result
ÓÓv |
.
ÓÓ| }
VentasÓÓ} É
*ÓÓÑ Ö
$numÓÓÜ â
,ÓÓâ ä
$numÓÓã å
)ÓÓå ç
,ÓÓç é
serie
ÔÔ 
,
ÔÔ 

disclaimer
ÔÔ 
=
ÔÔ 
TaxDisclaimer
ÔÔ  -
,
ÔÔ- .
}
 	
)
	 

;

 
}
ÒÒ 
private
ÛÛ 
sealed
ÛÛ 
record
ÛÛ 
NetPoint
ÛÛ "
(
ÛÛ" #
string
ÛÛ# )
Mes
ÛÛ* -
,
ÛÛ- .
decimal
ÛÛ/ 6
	VentasPen
ÛÛ7 @
,
ÛÛ@ A
decimal
ÛÛB I
	GastosPen
ÛÛJ S
,
ÛÛS T
decimal
ÛÛU \
ImpuestosPen
ÛÛ] i
,
ÛÛi j
decimal
ÛÛk r
UtilidadNetaPenÛÛs Ç
)ÛÛÇ É
;ÛÛÉ Ñ
private
ˆˆ 
static
ˆˆ 
(
ˆˆ 
decimal
ˆˆ 
Ventas
ˆˆ "
,
ˆˆ" #
decimal
ˆˆ$ +
Gastos
ˆˆ, 2
,
ˆˆ2 3
decimal
ˆˆ4 ;
	Impuestos
ˆˆ< E
,
ˆˆE F
decimal
ˆˆG N
Neta
ˆˆO S
)
ˆˆS T

NetFigures
ˆˆU _
(
ˆˆ_ `
IEnumerable
ˆˆ` k
<
ˆˆk l
Sale
ˆˆl p
>
ˆˆp q
sales
ˆˆr w
,
ˆˆw x
IEnumerableˆˆy Ñ
<ˆˆÑ Ö
ExpenseˆˆÖ å
>ˆˆå ç
expensesˆˆé ñ
,ˆˆñ ó
decimalˆˆò ü
	rentaRateˆˆ† ©
)ˆˆ© ™
{
˜˜ 
var
¯¯ 
ventas
¯¯ 
=
¯¯ 
sales
¯¯ 
.
¯¯ 
Sum
¯¯ 
(
¯¯ 
x
¯¯  
=>
¯¯! #
x
¯¯$ %
.
¯¯% &
BasePen
¯¯& -
)
¯¯- .
;
¯¯. /
var
˘˘ 
gastos
˘˘ 
=
˘˘ 
expenses
˘˘ 
.
˘˘ 
Where
˘˘ #
(
˘˘# $
x
˘˘$ %
=>
˘˘& (
x
˘˘) *
.
˘˘* +
Category
˘˘+ 3
?
˘˘3 4
.
˘˘4 5
IsIncomeTax
˘˘5 @
!=
˘˘A C
true
˘˘D H
)
˘˘H I
.
˘˘I J
Sum
˘˘J M
(
˘˘M N
x
˘˘N O
=>
˘˘P R
x
˘˘S T
.
˘˘T U
	AmountPen
˘˘U ^
)
˘˘^ _
;
˘˘_ `
var
˙˙ 
	impuestos
˙˙ 
=
˙˙ 
sales
˙˙ 
.
˙˙ 
Where
˙˙ #
(
˙˙# $
x
˙˙$ %
=>
˙˙& (
x
˙˙) *
.
˙˙* +
Mype
˙˙+ /
)
˙˙/ 0
.
˙˙0 1
Sum
˙˙1 4
(
˙˙4 5
x
˙˙5 6
=>
˙˙7 9
x
˙˙: ;
.
˙˙; <
BasePen
˙˙< C
)
˙˙C D
*
˙˙E F
	rentaRate
˙˙G P
;
˙˙P Q
return
˚˚ 
(
˚˚ 
ventas
˚˚ 
,
˚˚ 
gastos
˚˚ 
,
˚˚ 
	impuestos
˚˚  )
,
˚˚) *
ventas
˚˚+ 1
-
˚˚2 3
gastos
˚˚4 :
-
˚˚; <
	impuestos
˚˚= F
)
˚˚F G
;
˚˚G H
}
¸¸ 
[
ˇˇ 
HttpGet
ˇˇ 
(
ˇˇ 
$str
ˇˇ 
)
ˇˇ 
]
ˇˇ  
public
ÄÄ 

async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
ActionResult
ÄÄ "
>
ÄÄ" #
ClientsReport
ÄÄ$ 1
(
ÄÄ1 2
int
ÄÄ2 5
?
ÄÄ5 6
month
ÄÄ7 <
,
ÄÄ< =
int
ÄÄ> A
year
ÄÄB F
,
ÄÄF G
CancellationToken
ÄÄH Y
ct
ÄÄZ \
)
ÄÄ\ ]
{
ÅÅ 
var
ÇÇ 
(
ÇÇ 
total
ÇÇ 
,
ÇÇ 
clientes
ÇÇ 
)
ÇÇ 
=
ÇÇ 
await
ÇÇ  % 
ClientRankingAsync
ÇÇ& 8
(
ÇÇ8 9
month
ÇÇ9 >
,
ÇÇ> ?
year
ÇÇ@ D
,
ÇÇD E
ct
ÇÇF H
)
ÇÇH I
;
ÇÇI J
return
ÉÉ 
Ok
ÉÉ 
(
ÉÉ 
new
ÉÉ 
{
ÉÉ 
totalPen
ÉÉ  
=
ÉÉ! "
total
ÉÉ# (
,
ÉÉ( )
clientes
ÉÉ* 2
}
ÉÉ3 4
)
ÉÉ4 5
;
ÉÉ5 6
}
ÑÑ 
private
ÜÜ 
sealed
ÜÜ 
record
ÜÜ 
ClientRankingRow
ÜÜ *
(
ÜÜ* +
Guid
ÜÜ+ /
ClientId
ÜÜ0 8
,
ÜÜ8 9
string
ÜÜ: @

ClientName
ÜÜA K
,
ÜÜK L
decimal
ÜÜM T
IngresosPen
ÜÜU `
,
ÜÜ` a
decimal
ÜÜb i

Porcentaje
ÜÜj t
,
ÜÜt u
decimal
ÜÜv }"
PorcentajeAcumuladoÜÜ~ ë
,ÜÜë í
intÜÜì ñ
CobrosÜÜó ù
,ÜÜù û
DateOnlyÜÜü ß
UltimoCobroÜÜ® ≥
,ÜÜ≥ ¥
decimalÜÜµ º"
PeriodoAnteriorPenÜÜΩ œ
,ÜÜœ –
decimalÜÜ— ÿ
?ÜÜÿ Ÿ#
VariacionPorcentajeÜÜ⁄ Ì
)ÜÜÌ Ó
;ÜÜÓ Ô
private
àà 
async
àà 
Task
àà 
<
àà 
(
àà 
decimal
àà 
Total
àà  %
,
àà% &
List
àà' +
<
àà+ ,
ClientRankingRow
àà, <
>
àà< =
Rows
àà> B
)
ààB C
>
ààC D 
ClientRankingAsync
ààE W
(
ààW X
int
ààX [
?
àà[ \
month
àà] b
,
ààb c
int
ààd g
year
ààh l
,
ààl m
CancellationToken
ààn 
ctààÄ Ç
)ààÇ É
{
ââ 
var
ää 
(
ää 
from
ää 
,
ää 
to
ää 
)
ää 
=
ää 
Period
ää 
(
ää  
month
ää  %
,
ää% &
year
ää' +
)
ää+ ,
;
ää, -
var
ää. 1
(
ää2 3
previousFrom
ää3 ?
,
ää? @

previousTo
ääA K
)
ääK L
=
ääM N
PreviousPeriod
ääO ]
(
ää] ^
month
ää^ c
,
ääc d
year
ääe i
)
ääi j
;
ääj k
var
ãã 
sales
ãã 
=
ãã 
await
ãã 

SalesAsync
ãã $
(
ãã$ %
from
ãã% )
,
ãã) *
to
ãã+ -
,
ãã- .
ct
ãã/ 1
)
ãã1 2
;
ãã2 3
var
åå 
previous
åå 
=
åå 
(
åå 
await
åå 

SalesAsync
åå (
(
åå( )
previousFrom
åå) 5
,
åå5 6

previousTo
åå7 A
,
ååA B
ct
ååC E
)
ååE F
)
ååF G
.
ååG H
GroupBy
ååH O
(
ååO P
x
ååP Q
=>
ååR T
x
ååU V
.
ååV W
ClientId
ååW _
)
åå_ `
.
åå` a
ToDictionary
ååa m
(
ååm n
g
åån o
=>
ååp r
g
åås t
.
ååt u
Key
ååu x
,
ååx y
g
ååz {
=>
åå| ~
gåå Ä
.ååÄ Å
SumååÅ Ñ
(ååÑ Ö
xååÖ Ü
=>ååá â
xååä ã
.ååã å
BasePenååå ì
)ååì î
)ååî ï
;ååï ñ
var
çç 
names
çç 
=
çç 
await
çç 
db
çç 
.
çç 
Clients
çç $
.
çç$ %
ToDictionaryAsync
çç% 6
(
çç6 7
x
çç7 8
=>
çç9 ;
x
çç< =
.
çç= >
Id
çç> @
,
çç@ A
x
ççB C
=>
ççD F
x
ççG H
.
ççH I
CompanyName
ççI T
,
ççT U
ct
ççV X
)
ççX Y
;
ççY Z
var
éé 
total
éé 
=
éé 
sales
éé 
.
éé 
Sum
éé 
(
éé 
x
éé 
=>
éé  "
x
éé# $
.
éé$ %
BasePen
éé% ,
)
éé, -
;
éé- .
var
éé/ 2
accumulated
éé3 >
=
éé? @
$num
ééA C
;
ééC D
var
èè 
rows
èè 
=
èè 
sales
èè 
.
èè 
GroupBy
èè  
(
èè  !
x
èè! "
=>
èè# %
x
èè& '
.
èè' (
ClientId
èè( 0
)
èè0 1
.
èè1 2
Select
èè2 8
(
èè8 9
g
èè9 :
=>
èè; =
new
èè> A
{
èèB C
ClientId
èèD L
=
èèM N
g
èèO P
.
èèP Q
Key
èèQ T
,
èèT U
Pen
èèV Y
=
èèZ [
g
èè\ ]
.
èè] ^
Sum
èè^ a
(
èèa b
x
èèb c
=>
èèd f
x
èèg h
.
èèh i
BasePen
èèi p
)
èèp q
,
èèq r
Count
èès x
=
èèy z
g
èè{ |
.
èè| }
Countèè} Ç
(èèÇ É
)èèÉ Ñ
,èèÑ Ö
LastèèÜ ä
=èèã å
gèèç é
.èèé è
Maxèèè í
(èèí ì
xèèì î
=>èèï ó
xèèò ô
.èèô ö
Dateèèö û
)èèû ü
}èè† °
)èè° ¢
.èè¢ £!
OrderByDescendingèè£ ¥
(èè¥ µ
xèèµ ∂
=>èè∑ π
xèè∫ ª
.èèª º
Penèèº ø
)èèø ¿
.èè¿ ¡
Selectèè¡ «
(èè« »
xèè» …
=>èè  Ã
{
êê 	
accumulated
ëë 
+=
ëë 
x
ëë 
.
ëë 
Pen
ëë  
;
ëë  !
var
íí 
before
íí 
=
íí 
previous
íí !
.
íí! "
GetValueOrDefault
íí" 3
(
íí3 4
x
íí4 5
.
íí5 6
ClientId
íí6 >
)
íí> ?
;
íí? @
return
ìì 
new
ìì 
ClientRankingRow
ìì '
(
ìì' (
x
ìì( )
.
ìì) *
ClientId
ìì* 2
,
ìì2 3
names
ìì4 9
.
ìì9 :
GetValueOrDefault
ìì: K
(
ììK L
x
ììL M
.
ììM N
ClientId
ììN V
)
ììV W
??
ììX Z
$str
ìì[ p
,
ììp q
Math
ììr v
.
ììv w
Round
ììw |
(
ìì| }
x
ìì} ~
.
ìì~ 
Penìì Ç
,ììÇ É
$numììÑ Ö
)ììÖ Ü
,ììÜ á
totalììà ç
==ììé ê
$numììë í
?ììì î
$numììï ñ
:ììó ò
Mathììô ù
.ììù û
Roundììû £
(ìì£ §
xìì§ •
.ìì• ¶
Penìì¶ ©
/ìì™ ´
totalìì¨ ±
*ìì≤ ≥
$numìì¥ ∑
,ìì∑ ∏
$numììπ ∫
)ìì∫ ª
,ììª º
totalììΩ ¬
==ìì√ ≈
$numìì∆ «
?ìì» …
$numìì  À
:ììÃ Õ
MathììŒ “
.ìì“ ”
Roundìì” ÿ
(ììÿ Ÿ
accumulatedììŸ ‰
/ììÂ Ê
totalììÁ Ï
*ììÌ Ó
$numììÔ Ú
,ììÚ Û
$numììÙ ı
)ììı ˆ
,ììˆ ˜
xìì¯ ˘
.ìì˘ ˙
Countìì˙ ˇ
,ììˇ Ä
xììÅ Ç
.ììÇ É
LastììÉ á
,ììá à
Mathììâ ç
.ììç é
Roundììé ì
(ììì î
beforeììî ö
,ììö õ
$numììú ù
)ììù û
,ììû ü
beforeìì† ¶
>ììß ®
$numìì© ™
?ìì´ ¨
Mathìì≠ ±
.ìì± ≤
Roundìì≤ ∑
(ìì∑ ∏
(ìì∏ π
xììπ ∫
.ìì∫ ª
Penììª æ
-ììø ¿
beforeìì¡ «
)ìì« »
/ìì…  
beforeììÀ —
*ìì“ ”
$numìì‘ ◊
,ìì◊ ÿ
$numììŸ ⁄
)ìì⁄ €
:ìì‹ ›
nullììﬁ ‚
)ìì‚ „
;ìì„ ‰
}
îî 	
)
îî	 

.
îî
 
ToList
îî 
(
îî 
)
îî 
;
îî 
return
ïï 
(
ïï 
Math
ïï 
.
ïï 
Round
ïï 
(
ïï 
total
ïï  
,
ïï  !
$num
ïï" #
)
ïï# $
,
ïï$ %
rows
ïï& *
)
ïï* +
;
ïï+ ,
}
ññ 
[
ôô 
HttpGet
ôô 
(
ôô 
$str
ôô 
)
ôô 
]
ôô 
public
öö 

async
öö 
Task
öö 
<
öö 
IActionResult
öö #
>
öö# $
ExportReport
öö% 1
(
öö1 2
int
öö2 5
?
öö5 6
month
öö7 <
,
öö< =
int
öö> A
year
ööB F
,
ööF G
CancellationToken
ööH Y
ct
ööZ \
)
öö\ ]
{
õõ 
var
úú 
settings
úú 
=
úú 
await
úú 
TaxSettingsRow
úú +
(
úú+ ,
ct
úú, .
)
úú. /
;
úú/ 0
var
ùù 
(
ùù 
from
ùù 
,
ùù 
to
ùù 
)
ùù 
=
ùù 
Period
ùù 
(
ùù  
month
ùù  %
,
ùù% &
year
ùù' +
)
ùù+ ,
;
ùù, -
var
ûû 
sales
ûû 
=
ûû 
await
ûû 

SalesAsync
ûû $
(
ûû$ %
from
ûû% )
,
ûû) *
to
ûû+ -
,
ûû- .
ct
ûû/ 1
)
ûû1 2
;
ûû2 3
var
üü 
expenses
üü 
=
üü 
await
üü 
db
üü 
.
üü  
Expenses
üü  (
.
üü( )
Include
üü) 0
(
üü0 1
x
üü1 2
=>
üü3 5
x
üü6 7
.
üü7 8
Category
üü8 @
)
üü@ A
.
üüA B
Where
üüB G
(
üüG H
x
üüH I
=>
üüJ L
x
üüM N
.
üüN O
Date
üüO S
>=
üüT V
from
üüW [
&&
üü\ ^
x
üü_ `
.
üü` a
Date
üüa e
<=
üüf h
to
üüi k
)
üük l
.
üül m
ToListAsync
üüm x
(
üüx y
ct
üüy {
)
üü{ |
;
üü| }
var
†† 
net
†† 
=
†† 

NetFigures
†† 
(
†† 
sales
†† "
,
††" #
expenses
††$ ,
,
††, -
settings
††. 6
.
††6 7
	RentaRate
††7 @
)
††@ A
;
††A B
var
°° 
(
°° 
_
°° 
,
°° 
ranking
°° 
)
°° 
=
°° 
await
°°   
ClientRankingAsync
°°! 3
(
°°3 4
month
°°4 9
,
°°9 :
year
°°; ?
,
°°? @
ct
°°A C
)
°°C D
;
°°D E
using
££ 
var
££ 
book
££ 
=
££ 
new
££ 

XLWorkbook
££ '
(
££' (
)
££( )
;
££) *
var
§§ 
summary
§§ 
=
§§ 
book
§§ 
.
§§ 
AddWorksheet
§§ '
(
§§' (
$str
§§( 2
)
§§2 3
;
§§3 4
(
•• 	
string
••	 
Label
•• 
,
•• 
decimal
•• 
Value
•• $
)
••$ %
[
••% &
]
••& '
figures
••( /
=
••0 1
[
••2 3
(
••3 4
$str
••4 J
,
••J K
net
••L O
.
••O P
Ventas
••P V
)
••V W
,
••W X
(
••Y Z
$str
••Z s
,
••s t
net
••u x
.
••x y
Gastos
••y 
)•• Ä
,••Ä Å
(••Ç É
$str••É ù
,••ù û
net••ü ¢
.••¢ £
Ventas••£ ©
-••™ ´
net••¨ Ø
.••Ø ∞
Gastos••∞ ∂
)••∂ ∑
,••∑ ∏
(••π ∫
$"••∫ º
$str••º —
{••— “
settings••“ ⁄
.••⁄ €
	RentaRate••€ ‰
*••Â Ê
$num••Á Í
:••Í Î
$str••Î Ô
}••Ô 
$str•• ¯
"••¯ ˘
,••˘ ˙
net••˚ ˛
.••˛ ˇ
	Impuestos••ˇ à
)••à â
,••â ä
(••ã å
$str••å °
,••° ¢
net••£ ¶
.••¶ ß
Neta••ß ´
)••´ ¨
,••¨ ≠
(••Æ Ø
$str••Ø æ
,••æ ø
net••¿ √
.••√ ƒ
Ventas••ƒ  
==••À Õ
$num••Œ œ
?••– —
$num••“ ”
:••‘ ’
net••÷ Ÿ
.••Ÿ ⁄
Neta••⁄ ﬁ
/••ﬂ ‡
net••· ‰
.••‰ Â
Ventas••Â Î
*••Ï Ì
$num••Ó Ò
)••Ò Ú
]••Ú Û
;••Û Ù
for
¶¶ 
(
¶¶ 
var
¶¶ 
i
¶¶ 
=
¶¶ 
$num
¶¶ 
;
¶¶ 
i
¶¶ 
<
¶¶ 
figures
¶¶ #
.
¶¶# $
Length
¶¶$ *
;
¶¶* +
i
¶¶, -
++
¶¶- /
)
¶¶/ 0
{
¶¶1 2
summary
¶¶3 :
.
¶¶: ;
Cell
¶¶; ?
(
¶¶? @
i
¶¶@ A
+
¶¶B C
$num
¶¶D E
,
¶¶E F
$num
¶¶G H
)
¶¶H I
.
¶¶I J
Value
¶¶J O
=
¶¶P Q
figures
¶¶R Y
[
¶¶Y Z
i
¶¶Z [
]
¶¶[ \
.
¶¶\ ]
Label
¶¶] b
;
¶¶b c
summary
¶¶d k
.
¶¶k l
Cell
¶¶l p
(
¶¶p q
i
¶¶q r
+
¶¶s t
$num
¶¶u v
,
¶¶v w
$num
¶¶x y
)
¶¶y z
.
¶¶z {
Value¶¶{ Ä
=¶¶Å Ç
Math¶¶É á
.¶¶á à
Round¶¶à ç
(¶¶ç é
figures¶¶é ï
[¶¶ï ñ
i¶¶ñ ó
]¶¶ó ò
.¶¶ò ô
Value¶¶ô û
,¶¶û ü
$num¶¶† °
)¶¶° ¢
;¶¶¢ £
}¶¶§ •
var
ßß 
row
ßß 
=
ßß 
figures
ßß 
.
ßß 
Length
ßß  
+
ßß! "
$num
ßß# $
;
ßß$ %
string
®® 
[
®® 
]
®® 
header
®® 
=
®® 
[
®® 
$str
®®  
,
®®  !
$str
®®" *
,
®®* +
$str
®®, 4
,
®®4 5
$str
®®6 =
,
®®= >
$str
®®? N
]
®®N O
;
®®O P
for
©© 
(
©© 
var
©© 
c
©© 
=
©© 
$num
©© 
;
©© 
c
©© 
<
©© 
header
©© "
.
©©" #
Length
©©# )
;
©©) *
c
©©+ ,
++
©©, .
)
©©. /
summary
©©0 7
.
©©7 8
Cell
©©8 <
(
©©< =
row
©©= @
,
©©@ A
c
©©B C
+
©©D E
$num
©©F G
)
©©G H
.
©©H I
Value
©©I N
=
©©O P
header
©©Q W
[
©©W X
c
©©X Y
]
©©Y Z
;
©©Z [
foreach
™™ 
(
™™ 
var
™™ 
start
™™ 
in
™™ 

Enumerable
™™ (
.
™™( )
Range
™™) .
(
™™. /
$num
™™/ 0
,
™™0 1
month
™™2 7
is
™™8 :
null
™™; ?
?
™™@ A
$num
™™B D
:
™™E F
$num
™™G H
)
™™H I
.
™™I J
Select
™™J P
(
™™P Q
i
™™Q R
=>
™™S U
from
™™V Z
.
™™Z [
	AddMonths
™™[ d
(
™™d e
i
™™e f
)
™™f g
)
™™g h
)
™™h i
{
´´ 	
var
¨¨ 
end
¨¨ 
=
¨¨ 
start
¨¨ 
.
¨¨ 
	AddMonths
¨¨ %
(
¨¨% &
$num
¨¨& '
)
¨¨' (
.
¨¨( )
AddDays
¨¨) 0
(
¨¨0 1
-
¨¨1 2
$num
¨¨2 3
)
¨¨3 4
;
¨¨4 5
var
≠≠ 
n
≠≠ 
=
≠≠ 

NetFigures
≠≠ 
(
≠≠ 
sales
≠≠ $
.
≠≠$ %
Where
≠≠% *
(
≠≠* +
x
≠≠+ ,
=>
≠≠- /
x
≠≠0 1
.
≠≠1 2
Date
≠≠2 6
>=
≠≠7 9
start
≠≠: ?
&&
≠≠@ B
x
≠≠C D
.
≠≠D E
Date
≠≠E I
<=
≠≠J L
end
≠≠M P
)
≠≠P Q
,
≠≠Q R
expenses
≠≠S [
.
≠≠[ \
Where
≠≠\ a
(
≠≠a b
x
≠≠b c
=>
≠≠d f
x
≠≠g h
.
≠≠h i
Date
≠≠i m
>=
≠≠n p
start
≠≠q v
&&
≠≠w y
x
≠≠z {
.
≠≠{ |
Date≠≠| Ä
<=≠≠Å É
end≠≠Ñ á
)≠≠á à
,≠≠à â
settings≠≠ä í
.≠≠í ì
	RentaRate≠≠ì ú
)≠≠ú ù
;≠≠ù û
row
ÆÆ 
++
ÆÆ 
;
ÆÆ 
summary
ÆÆ 
.
ÆÆ 
Cell
ÆÆ 
(
ÆÆ  
row
ÆÆ  #
,
ÆÆ# $
$num
ÆÆ% &
)
ÆÆ& '
.
ÆÆ' (
Value
ÆÆ( -
=
ÆÆ. /
start
ÆÆ0 5
.
ÆÆ5 6
ToString
ÆÆ6 >
(
ÆÆ> ?
$str
ÆÆ? H
)
ÆÆH I
;
ÆÆI J
summary
ØØ 
.
ØØ 
Cell
ØØ 
(
ØØ 
row
ØØ 
,
ØØ 
$num
ØØ 
)
ØØ  
.
ØØ  !
Value
ØØ! &
=
ØØ' (
Math
ØØ) -
.
ØØ- .
Round
ØØ. 3
(
ØØ3 4
n
ØØ4 5
.
ØØ5 6
Ventas
ØØ6 <
,
ØØ< =
$num
ØØ> ?
)
ØØ? @
;
ØØ@ A
summary
ØØB I
.
ØØI J
Cell
ØØJ N
(
ØØN O
row
ØØO R
,
ØØR S
$num
ØØT U
)
ØØU V
.
ØØV W
Value
ØØW \
=
ØØ] ^
Math
ØØ_ c
.
ØØc d
Round
ØØd i
(
ØØi j
n
ØØj k
.
ØØk l
Gastos
ØØl r
,
ØØr s
$num
ØØt u
)
ØØu v
;
ØØv w
summary
ØØx 
.ØØ Ä
CellØØÄ Ñ
(ØØÑ Ö
rowØØÖ à
,ØØà â
$numØØä ã
)ØØã å
.ØØå ç
ValueØØç í
=ØØì î
MathØØï ô
.ØØô ö
RoundØØö ü
(ØØü †
nØØ† °
.ØØ° ¢
	ImpuestosØØ¢ ´
,ØØ´ ¨
$numØØ≠ Æ
)ØØÆ Ø
;ØØØ ∞
summaryØØ± ∏
.ØØ∏ π
CellØØπ Ω
(ØØΩ æ
rowØØæ ¡
,ØØ¡ ¬
$numØØ√ ƒ
)ØØƒ ≈
.ØØ≈ ∆
ValueØØ∆ À
=ØØÃ Õ
MathØØŒ “
.ØØ“ ”
RoundØØ” ÿ
(ØØÿ Ÿ
nØØŸ ⁄
.ØØ⁄ €
NetaØØ€ ﬂ
,ØØﬂ ‡
$numØØ· ‚
)ØØ‚ „
;ØØ„ ‰
}
∞∞ 	
summary
±± 
.
±± 
Columns
±± 
(
±± 
)
±± 
.
±± 
AdjustToContents
±± *
(
±±* +
)
±±+ ,
;
±±, -
var
≥≥ 
clients
≥≥ 
=
≥≥ 
book
≥≥ 
.
≥≥ 
AddWorksheet
≥≥ '
(
≥≥' (
$str
≥≥( 2
)
≥≥2 3
;
≥≥3 4
string
¥¥ 
[
¥¥ 
]
¥¥ 
clientHeader
¥¥ 
=
¥¥ 
[
¥¥  !
$str
¥¥! *
,
¥¥* +
$str
¥¥, D
,
¥¥D E
$str
¥¥F S
,
¥¥S T
$str
¥¥U b
,
¥¥b c
$str
¥¥d l
,
¥¥l m
$str
¥¥n |
,
¥¥| }
$str¥¥~ ñ
,¥¥ñ ó
$str¥¥ò •
]¥¥• ¶
;¥¥¶ ß
for
µµ 
(
µµ 
var
µµ 
c
µµ 
=
µµ 
$num
µµ 
;
µµ 
c
µµ 
<
µµ 
clientHeader
µµ (
.
µµ( )
Length
µµ) /
;
µµ/ 0
c
µµ1 2
++
µµ2 4
)
µµ4 5
clients
µµ6 =
.
µµ= >
Cell
µµ> B
(
µµB C
$num
µµC D
,
µµD E
c
µµF G
+
µµH I
$num
µµJ K
)
µµK L
.
µµL M
Value
µµM R
=
µµS T
clientHeader
µµU a
[
µµa b
c
µµb c
]
µµc d
;
µµd e
var
∂∂ 
r
∂∂ 
=
∂∂ 
$num
∂∂ 
;
∂∂ 
foreach
∑∑ 
(
∑∑ 
var
∑∑ 
x
∑∑ 
in
∑∑ 
ranking
∑∑ !
)
∑∑! "
{
∏∏ 	
r
ππ 
++
ππ 
;
ππ 
clients
∫∫ 
.
∫∫ 
Cell
∫∫ 
(
∫∫ 
r
∫∫ 
,
∫∫ 
$num
∫∫ 
)
∫∫ 
.
∫∫ 
Value
∫∫ $
=
∫∫% &
x
∫∫' (
.
∫∫( )

ClientName
∫∫) 3
;
∫∫3 4
clients
∫∫5 <
.
∫∫< =
Cell
∫∫= A
(
∫∫A B
r
∫∫B C
,
∫∫C D
$num
∫∫E F
)
∫∫F G
.
∫∫G H
Value
∫∫H M
=
∫∫N O
x
∫∫P Q
.
∫∫Q R
IngresosPen
∫∫R ]
;
∫∫] ^
clients
∫∫_ f
.
∫∫f g
Cell
∫∫g k
(
∫∫k l
r
∫∫l m
,
∫∫m n
$num
∫∫o p
)
∫∫p q
.
∫∫q r
Value
∫∫r w
=
∫∫x y
x
∫∫z {
.
∫∫{ |

Porcentaje∫∫| Ü
;∫∫Ü á
clients∫∫à è
.∫∫è ê
Cell∫∫ê î
(∫∫î ï
r∫∫ï ñ
,∫∫ñ ó
$num∫∫ò ô
)∫∫ô ö
.∫∫ö õ
Value∫∫õ †
=∫∫° ¢
x∫∫£ §
.∫∫§ •#
PorcentajeAcumulado∫∫• ∏
;∫∫∏ π
clients
ªª 
.
ªª 
Cell
ªª 
(
ªª 
r
ªª 
,
ªª 
$num
ªª 
)
ªª 
.
ªª 
Value
ªª $
=
ªª% &
x
ªª' (
.
ªª( )
Cobros
ªª) /
;
ªª/ 0
clients
ªª1 8
.
ªª8 9
Cell
ªª9 =
(
ªª= >
r
ªª> ?
,
ªª? @
$num
ªªA B
)
ªªB C
.
ªªC D
Value
ªªD I
=
ªªJ K
x
ªªL M
.
ªªM N
UltimoCobro
ªªN Y
.
ªªY Z

ToDateTime
ªªZ d
(
ªªd e
TimeOnly
ªªe m
.
ªªm n
MinValue
ªªn v
)
ªªv w
;
ªªw x
clientsªªy Ä
.ªªÄ Å
CellªªÅ Ö
(ªªÖ Ü
rªªÜ á
,ªªá à
$numªªâ ä
)ªªä ã
.ªªã å
Valueªªå ë
=ªªí ì
xªªî ï
.ªªï ñ"
PeriodoAnteriorPenªªñ ®
;ªª® ©
if
ºº 
(
ºº 
x
ºº 
.
ºº !
VariacionPorcentaje
ºº %
is
ºº& (
decimal
ºº) 0
	variation
ºº1 :
)
ºº: ;
clients
ºº< C
.
ººC D
Cell
ººD H
(
ººH I
r
ººI J
,
ººJ K
$num
ººL M
)
ººM N
.
ººN O
Value
ººO T
=
ººU V
	variation
ººW `
;
ºº` a
}
ΩΩ 	
clients
ææ 
.
ææ 
Column
ææ 
(
ææ 
$num
ææ 
)
ææ 
.
ææ 
Style
ææ 
.
ææ  

DateFormat
ææ  *
.
ææ* +
Format
ææ+ 1
=
ææ2 3
$str
ææ4 @
;
ææ@ A
clients
ææB I
.
ææI J
Columns
ææJ Q
(
ææQ R
)
ææR S
.
ææS T
AdjustToContents
ææT d
(
ææd e
)
ææe f
;
ææf g
using
¿¿ 
var
¿¿ 
stream
¿¿ 
=
¿¿ 
new
¿¿ 
MemoryStream
¿¿ +
(
¿¿+ ,
)
¿¿, -
;
¿¿- .
book
¿¿/ 3
.
¿¿3 4
SaveAs
¿¿4 :
(
¿¿: ;
stream
¿¿; A
)
¿¿A B
;
¿¿B C
return
¡¡ 
File
¡¡ 
(
¡¡ 
stream
¡¡ 
.
¡¡ 
ToArray
¡¡ "
(
¡¡" #
)
¡¡# $
,
¡¡$ %
$str
¡¡& i
,
¡¡i j
month
¡¡k p
is
¡¡q s
int
¡¡t w
m
¡¡x y
?
¡¡z {
$"
¡¡| ~
$str¡¡~ Ü
{¡¡Ü á
year¡¡á ã
}¡¡ã å
$str¡¡å ç
{¡¡ç é
m¡¡é è
:¡¡è ê
$str¡¡ê í
}¡¡í ì
$str¡¡ì ò
"¡¡ò ô
:¡¡ö õ
$"¡¡ú û
$str¡¡û ¶
{¡¡¶ ß
year¡¡ß ´
}¡¡´ ¨
$str¡¡¨ ±
"¡¡± ≤
)¡¡≤ ≥
;¡¡≥ ¥
}
¬¬ 
[
ƒƒ 
HttpGet
ƒƒ 
(
ƒƒ 
$str
ƒƒ 
)
ƒƒ 
]
ƒƒ 
public
≈≈ 

async
≈≈ 
Task
≈≈ 
<
≈≈ 
ActionResult
≈≈ "
>
≈≈" #
Clients
≈≈$ +
(
≈≈+ ,
CancellationToken
≈≈, =
ct
≈≈> @
)
≈≈@ A
=>
≈≈B D
Ok
≈≈E G
(
≈≈G H
await
≈≈H M
db
≈≈N P
.
≈≈P Q
Clients
≈≈Q X
.
≈≈X Y
OrderBy
≈≈Y `
(
≈≈` a
x
≈≈a b
=>
≈≈c e
x
≈≈f g
.
≈≈g h
CompanyName
≈≈h s
)
≈≈s t
.
≈≈t u
Select
≈≈u {
(
≈≈{ |
x
≈≈| }
=>≈≈~ Ä
new≈≈Å Ñ
{≈≈Ö Ü
id≈≈á â
=≈≈ä ã
x≈≈å ç
.≈≈ç é
Id≈≈é ê
,≈≈ê ë
companyName≈≈í ù
=≈≈û ü
x≈≈† °
.≈≈° ¢
CompanyName≈≈¢ ≠
,≈≈≠ Æ
isActive≈≈Ø ∑
=≈≈∏ π
x≈≈∫ ª
.≈≈ª º
IsActive≈≈º ƒ
,≈≈ƒ ≈#
requiresTaxDocument≈≈∆ Ÿ
=≈≈⁄ €
x≈≈‹ ›
.≈≈› ﬁ#
RequiresTaxDocument≈≈ﬁ Ò
,≈≈Ò Ú
activeProducts≈≈Û Å
=≈≈Ç É
db≈≈Ñ Ü
.≈≈Ü á
ClientProducts≈≈á ï
.≈≈ï ñ
Count≈≈ñ õ
(≈≈õ ú
p≈≈ú ù
=>≈≈û †
p≈≈° ¢
.≈≈¢ £
ClientId≈≈£ ´
==≈≈¨ Æ
x≈≈Ø ∞
.≈≈∞ ±
Id≈≈± ≥
&&≈≈¥ ∂
p≈≈∑ ∏
.≈≈∏ π
Status≈≈π ø
==≈≈¿ ¬#
ClientProductStatus≈≈√ ÷
.≈≈÷ ◊
Activo≈≈◊ ›
)≈≈› ﬁ
,≈≈ﬁ ﬂ 
expiringProducts≈≈‡ 
=≈≈Ò Ú
db≈≈Û ı
.≈≈ı ˆ
ClientProducts≈≈ˆ Ñ
.≈≈Ñ Ö
Count≈≈Ö ä
(≈≈ä ã
p≈≈ã å
=>≈≈ç è
p≈≈ê ë
.≈≈ë í
ClientId≈≈í ö
==≈≈õ ù
x≈≈û ü
.≈≈ü †
Id≈≈† ¢
&&≈≈£ •
p≈≈¶ ß
.≈≈ß ®
Status≈≈® Æ
==≈≈Ø ±#
ClientProductStatus≈≈≤ ≈
.≈≈≈ ∆
	PorVencer≈≈∆ œ
)≈≈œ –
,≈≈– —
expiredProducts≈≈“ ·
=≈≈‚ „
db≈≈‰ Ê
.≈≈Ê Á
ClientProducts≈≈Á ı
.≈≈ı ˆ
Count≈≈ˆ ˚
(≈≈˚ ¸
p≈≈¸ ˝
=>≈≈˛ Ä
p≈≈Å Ç
.≈≈Ç É
ClientId≈≈É ã
==≈≈å é
x≈≈è ê
.≈≈ê ë
Id≈≈ë ì
&&≈≈î ñ
p≈≈ó ò
.≈≈ò ô
Status≈≈ô ü
==≈≈† ¢#
ClientProductStatus≈≈£ ∂
.≈≈∂ ∑
Vencido≈≈∑ æ
)≈≈æ ø
,≈≈ø ¿
openTickets≈≈¡ Ã
=≈≈Õ Œ
db≈≈œ —
.≈≈— “
Tickets≈≈“ Ÿ
.≈≈Ÿ ⁄
Count≈≈⁄ ﬂ
(≈≈ﬂ ‡
t≈≈‡ ·
=>≈≈‚ ‰
t≈≈Â Ê
.≈≈Ê Á
ClientId≈≈Á Ô
==≈≈ Ú
x≈≈Û Ù
.≈≈Ù ı
Id≈≈ı ˜
&&≈≈¯ ˙
(≈≈˚ ¸
t≈≈¸ ˝
.≈≈˝ ˛
Status≈≈˛ Ñ
==≈≈Ö á
TicketStatus≈≈à î
.≈≈î ï
Abierto≈≈ï ú
||≈≈ù ü
t≈≈† °
.≈≈° ¢
Status≈≈¢ ®
==≈≈© ´
TicketStatus≈≈¨ ∏
.≈≈∏ π

EnProgreso≈≈π √
)≈≈√ ƒ
)≈≈ƒ ≈
}≈≈∆ «
)≈≈« »
.≈≈» …
ToListAsync≈≈… ‘
(≈≈‘ ’
ct≈≈’ ◊
)≈≈◊ ÿ
)≈≈ÿ Ÿ
;≈≈Ÿ ⁄
[
«« 
HttpGet
«« 
(
«« 
$str
««  
)
««  !
]
««! "
public
»» 

async
»» 
Task
»» 
<
»» 
ActionResult
»» "
>
»»" #
Client
»»$ *
(
»»* +
Guid
»»+ /
id
»»0 2
,
»»2 3
CancellationToken
»»4 E
ct
»»F H
)
»»H I
{
…… 
var
   
client
   
=
   
await
   
db
   
.
   
Clients
   %
.
  % &
	FindAsync
  & /
(
  / 0
[
  0 1
id
  1 3
]
  3 4
,
  4 5
ct
  6 8
)
  8 9
;
  9 :
if
ÀÀ 

(
ÀÀ 
client
ÀÀ 
is
ÀÀ 
null
ÀÀ 
)
ÀÀ 
return
ÀÀ "
NotFound
ÀÀ# +
(
ÀÀ+ ,
)
ÀÀ, -
;
ÀÀ- .
var
ÃÃ 
products
ÃÃ 
=
ÃÃ 
await
ÃÃ 
db
ÃÃ 
.
ÃÃ  
ClientProducts
ÃÃ  .
.
ÃÃ. /
Include
ÃÃ/ 6
(
ÃÃ6 7
x
ÃÃ7 8
=>
ÃÃ9 ;
x
ÃÃ< =
.
ÃÃ= >
Product
ÃÃ> E
)
ÃÃE F
.
ÃÃF G
Include
ÃÃG N
(
ÃÃN O
x
ÃÃO P
=>
ÃÃQ S
x
ÃÃT U
.
ÃÃU V
Project
ÃÃV ]
)
ÃÃ] ^
.
ÃÃ^ _
Where
ÃÃ_ d
(
ÃÃd e
x
ÃÃe f
=>
ÃÃg i
x
ÃÃj k
.
ÃÃk l
ClientId
ÃÃl t
==
ÃÃu w
id
ÃÃx z
)
ÃÃz {
.
ÃÃ{ |
ToListAsyncÃÃ| á
(ÃÃá à
ctÃÃà ä
)ÃÃä ã
;ÃÃã å
var
ÕÕ 
igvRate
ÕÕ 
=
ÕÕ 
await
ÕÕ 
db
ÕÕ 
.
ÕÕ 
IgvRateAsync
ÕÕ +
(
ÕÕ+ ,
ct
ÕÕ, .
)
ÕÕ. /
;
ÕÕ/ 0
return
ŒŒ 
Ok
ŒŒ 
(
ŒŒ 
new
ŒŒ 
{
ŒŒ 
client
ŒŒ 
=
ŒŒ  
	ClientDto
ŒŒ! *
(
ŒŒ* +
client
ŒŒ+ 1
)
ŒŒ1 2
,
ŒŒ2 3
products
ŒŒ4 <
=
ŒŒ= >
products
ŒŒ? G
.
ŒŒG H
Select
ŒŒH N
(
ŒŒN O
x
ŒŒO P
=>
ŒŒQ S
ClientProductDto
ŒŒT d
(
ŒŒd e
x
ŒŒe f
,
ŒŒf g
x
ŒŒh i
.
ŒŒi j
Product
ŒŒj q
is
ŒŒr t
null
ŒŒu y
?
ŒŒz {
$num
ŒŒ| ~
:ŒŒ Ä$
ClientProductPricingŒŒÅ ï
.ŒŒï ñ

IgvRateForŒŒñ †
(ŒŒ† °
clientŒŒ° ß
,ŒŒß ®
xŒŒ© ™
.ŒŒ™ ´
ProductŒŒ´ ≤
,ŒŒ≤ ≥
igvRateŒŒ¥ ª
)ŒŒª º
)ŒŒº Ω
)ŒŒΩ æ
}ŒŒø ¿
)ŒŒ¿ ¡
;ŒŒ¡ ¬
}
œœ 
[
—— 
HttpPost
—— 
(
—— 
$str
—— 
)
—— 
]
—— 
public
““ 

async
““ 
Task
““ 
<
““ 
ActionResult
““ "
>
““" #
CreateClient
““$ 0
(
““0 1
ClientRequest
““1 >
request
““? F
,
““F G
CancellationToken
““H Y
ct
““Z \
)
““\ ]
{
”” 
var
‘‘ 
error
‘‘ 
=
‘‘ 
ValidateClient
‘‘ "
(
‘‘" #
request
‘‘# *
)
‘‘* +
;
‘‘+ ,
if
‘‘- /
(
‘‘0 1
error
‘‘1 6
is
‘‘7 9
not
‘‘: =
null
‘‘> B
)
‘‘B C
return
‘‘D J

BadRequest
‘‘K U
(
‘‘U V
new
‘‘V Y
{
‘‘Z [
message
‘‘\ c
=
‘‘d e
error
‘‘f k
}
‘‘l m
)
‘‘m n
;
‘‘n o
var
’’ 
email
’’ 
=
’’ 
request
’’ 
.
’’ 
Email
’’ !
.
’’! "
Trim
’’" &
(
’’& '
)
’’' (
;
’’( )
if
÷÷ 

(
÷÷ 
await
÷÷ 
db
÷÷ 
.
÷÷ 
Clients
÷÷ 
.
÷÷ 
AnyAsync
÷÷ %
(
÷÷% &
x
÷÷& '
=>
÷÷( *
x
÷÷+ ,
.
÷÷, -
Email
÷÷- 2
==
÷÷3 5
email
÷÷6 ;
,
÷÷; <
ct
÷÷= ?
)
÷÷? @
||
÷÷A C
await
÷÷D I
db
÷÷J L
.
÷÷L M
UserAccounts
÷÷M Y
.
÷÷Y Z
AnyAsync
÷÷Z b
(
÷÷b c
x
÷÷c d
=>
÷÷e g
x
÷÷h i
.
÷÷i j
Email
÷÷j o
==
÷÷p r
email
÷÷s x
,
÷÷x y
ct
÷÷z |
)
÷÷| }
)
÷÷} ~
return÷÷ Ö
Conflict÷÷Ü é
(÷÷é è
new÷÷è í
{÷÷ì î
message÷÷ï ú
=÷÷ù û
$str÷÷ü Ω
}÷÷æ ø
)÷÷ø ¿
;÷÷¿ ¡
var
◊◊ 
client
◊◊ 
=
◊◊ 
new
◊◊ 
Client
◊◊ 
{
◊◊  !
CompanyName
◊◊" -
=
◊◊. /
request
◊◊0 7
.
◊◊7 8
CompanyName
◊◊8 C
.
◊◊C D
Trim
◊◊D H
(
◊◊H I
)
◊◊I J
,
◊◊J K
ContactName
◊◊L W
=
◊◊X Y
request
◊◊Z a
.
◊◊a b
ContactName
◊◊b m
.
◊◊m n
Trim
◊◊n r
(
◊◊r s
)
◊◊s t
,
◊◊t u
Email
◊◊v {
=
◊◊| }
email◊◊~ É
,◊◊É Ñ
Phone◊◊Ö ä
=◊◊ã å
EmptyToNull◊◊ç ò
(◊◊ò ô
request◊◊ô †
.◊◊† °
Phone◊◊° ¶
)◊◊¶ ß
,◊◊ß ®!
PreferredLanguage◊◊© ∫
=◊◊ª º
request◊◊Ω ƒ
.◊◊ƒ ≈!
PreferredLanguage◊◊≈ ÷
.◊◊÷ ◊
Trim◊◊◊ €
(◊◊€ ‹
)◊◊‹ ›
.◊◊› ﬁ 
ToLowerInvariant◊◊ﬁ Ó
(◊◊Ó Ô
)◊◊Ô 
,◊◊ Ò#
RequiresTaxDocument◊◊Ú Ö
=◊◊Ü á
request◊◊à è
.◊◊è ê#
RequiresTaxDocument◊◊ê £
}◊◊§ •
;◊◊• ¶
db
ÿÿ 

.
ÿÿ
 
Clients
ÿÿ 
.
ÿÿ 
Add
ÿÿ 
(
ÿÿ 
client
ÿÿ 
)
ÿÿ 
;
ÿÿ 
var
⁄⁄ 
access
⁄⁄ 
=
⁄⁄ 
AddAdminUser
⁄⁄ !
(
⁄⁄! "
client
⁄⁄" (
)
⁄⁄( )
;
⁄⁄) *
await
€€ 
db
€€ 
.
€€ 
SaveChangesAsync
€€ !
(
€€! "
ct
€€" $
)
€€$ %
;
€€% &
access
‹‹ 
=
‹‹ 
await
‹‹ 
EmailAccessAsync
‹‹ '
(
‹‹' (
client
‹‹( .
,
‹‹. /
access
‹‹0 6
,
‹‹6 7
ct
‹‹8 :
)
‹‹: ;
;
‹‹; <
return
›› 
Created
›› 
(
›› 
$"
›› 
$str
›› ,
{
››, -
client
››- 3
.
››3 4
Id
››4 6
}
››6 7
"
››7 8
,
››8 9
new
››: =
{
››> ?
client
››@ F
=
››G H
	ClientDto
››I R
(
››R S
client
››S Y
)
››Y Z
,
››Z [
access
››\ b
}
››c d
)
››d e
;
››e f
}
ﬁﬁ 
[
‡‡ 
	HttpPatch
‡‡ 
(
‡‡ 
$str
‡‡ "
)
‡‡" #
]
‡‡# $
public
·· 

async
·· 
Task
·· 
<
·· 
ActionResult
·· "
>
··" #
UpdateClient
··$ 0
(
··0 1
Guid
··1 5
id
··6 8
,
··8 9 
ClientPatchRequest
··: L
request
··M T
,
··T U
CancellationToken
··V g
ct
··h j
)
··j k
{
‚‚ 
var
„„ 
client
„„ 
=
„„ 
await
„„ 
db
„„ 
.
„„ 
Clients
„„ %
.
„„% &
	FindAsync
„„& /
(
„„/ 0
[
„„0 1
id
„„1 3
]
„„3 4
,
„„4 5
ct
„„6 8
)
„„8 9
;
„„9 :
if
„„; =
(
„„> ?
client
„„? E
is
„„F H
null
„„I M
)
„„M N
return
„„O U
NotFound
„„V ^
(
„„^ _
)
„„_ `
;
„„` a
if
‰‰ 

(
‰‰ 
request
‰‰ 
.
‰‰ 
CompanyName
‰‰ 
is
‰‰  "
not
‰‰# &
null
‰‰' +
)
‰‰+ ,
client
‰‰- 3
.
‰‰3 4
CompanyName
‰‰4 ?
=
‰‰@ A
request
‰‰B I
.
‰‰I J
CompanyName
‰‰J U
.
‰‰U V
Trim
‰‰V Z
(
‰‰Z [
)
‰‰[ \
;
‰‰\ ]
if
ÂÂ 

(
ÂÂ 
request
ÂÂ 
.
ÂÂ 
ContactName
ÂÂ 
is
ÂÂ  "
not
ÂÂ# &
null
ÂÂ' +
)
ÂÂ+ ,
client
ÂÂ- 3
.
ÂÂ3 4
ContactName
ÂÂ4 ?
=
ÂÂ@ A
request
ÂÂB I
.
ÂÂI J
ContactName
ÂÂJ U
.
ÂÂU V
Trim
ÂÂV Z
(
ÂÂZ [
)
ÂÂ[ \
;
ÂÂ\ ]
if
ÊÊ 

(
ÊÊ 
request
ÊÊ 
.
ÊÊ 
Phone
ÊÊ 
is
ÊÊ 
not
ÊÊ  
null
ÊÊ! %
)
ÊÊ% &
client
ÊÊ' -
.
ÊÊ- .
Phone
ÊÊ. 3
=
ÊÊ4 5
EmptyToNull
ÊÊ6 A
(
ÊÊA B
request
ÊÊB I
.
ÊÊI J
Phone
ÊÊJ O
)
ÊÊO P
;
ÊÊP Q
if
ÁÁ 

(
ÁÁ 
request
ÁÁ 
.
ÁÁ 
PreferredLanguage
ÁÁ %
is
ÁÁ& (
not
ÁÁ) ,
null
ÁÁ- 1
)
ÁÁ1 2
{
ËË 	
var
ÈÈ 
lang
ÈÈ 
=
ÈÈ 
request
ÈÈ 
.
ÈÈ 
PreferredLanguage
ÈÈ 0
.
ÈÈ0 1
Trim
ÈÈ1 5
(
ÈÈ5 6
)
ÈÈ6 7
.
ÈÈ7 8
ToLowerInvariant
ÈÈ8 H
(
ÈÈH I
)
ÈÈI J
;
ÈÈJ K
if
ÍÍ 
(
ÍÍ 
lang
ÍÍ 
is
ÍÍ 
not
ÍÍ 
(
ÍÍ 
$str
ÍÍ !
or
ÍÍ" $
$str
ÍÍ% )
or
ÍÍ* ,
$str
ÍÍ- 1
)
ÍÍ1 2
)
ÍÍ2 3
return
ÍÍ4 :

BadRequest
ÍÍ; E
(
ÍÍE F
new
ÍÍF I
{
ÍÍJ K
message
ÍÍL S
=
ÍÍT U
$str
ÍÍV h
}
ÍÍi j
)
ÍÍj k
;
ÍÍk l
client
ÎÎ 
.
ÎÎ 
PreferredLanguage
ÎÎ $
=
ÎÎ% &
lang
ÎÎ' +
;
ÎÎ+ ,
}
ÏÏ 	
if
ÌÌ 

(
ÌÌ 
request
ÌÌ 
.
ÌÌ 
Email
ÌÌ 
is
ÌÌ 
not
ÌÌ  
null
ÌÌ! %
&&
ÌÌ& (
await
ÌÌ) .$
ChangeClientEmailAsync
ÌÌ/ E
(
ÌÌE F
client
ÌÌF L
,
ÌÌL M
request
ÌÌN U
.
ÌÌU V
Email
ÌÌV [
.
ÌÌ[ \
Trim
ÌÌ\ `
(
ÌÌ` a
)
ÌÌa b
,
ÌÌb c
ct
ÌÌd f
)
ÌÌf g
is
ÌÌh j
{
ÌÌk l
}
ÌÌm n

emailError
ÌÌo y
)
ÌÌy z
returnÌÌ{ Å

emailErrorÌÌÇ å
;ÌÌå ç
if
ÓÓ 

(
ÓÓ 
request
ÓÓ 
.
ÓÓ 
IsActive
ÓÓ 
is
ÓÓ 
bool
ÓÓ  $
active
ÓÓ% +
)
ÓÓ+ ,
client
ÓÓ- 3
.
ÓÓ3 4
IsActive
ÓÓ4 <
=
ÓÓ= >
active
ÓÓ? E
;
ÓÓE F
if
ÔÔ 

(
ÔÔ 
request
ÔÔ 
.
ÔÔ !
RequiresTaxDocument
ÔÔ '
is
ÔÔ( *
bool
ÔÔ+ /
requiresTax
ÔÔ0 ;
)
ÔÔ; <
client
ÔÔ= C
.
ÔÔC D!
RequiresTaxDocument
ÔÔD W
=
ÔÔX Y
requiresTax
ÔÔZ e
;
ÔÔe f
await
 
db
 
.
 
SaveChangesAsync
 !
(
! "
ct
" $
)
$ %
;
% &
return
' -
Ok
. 0
(
0 1
	ClientDto
1 :
(
: ;
client
; A
)
A B
)
B C
;
C D
}
ÒÒ 
private
ÙÙ 
async
ÙÙ 
Task
ÙÙ 
<
ÙÙ 
ActionResult
ÙÙ #
?
ÙÙ# $
>
ÙÙ$ %$
ChangeClientEmailAsync
ÙÙ& <
(
ÙÙ< =
Client
ÙÙ= C
client
ÙÙD J
,
ÙÙJ K
string
ÙÙL R
email
ÙÙS X
,
ÙÙX Y
CancellationToken
ÙÙZ k
ct
ÙÙl n
)
ÙÙn o
{
ıı 
if
ˆˆ 

(
ˆˆ 
string
ˆˆ 
.
ˆˆ  
IsNullOrWhiteSpace
ˆˆ %
(
ˆˆ% &
email
ˆˆ& +
)
ˆˆ+ ,
)
ˆˆ, -
return
ˆˆ. 4

BadRequest
ˆˆ5 ?
(
ˆˆ? @
new
ˆˆ@ C
{
ˆˆD E
message
ˆˆF M
=
ˆˆN O
$str
ˆˆP j
}
ˆˆk l
)
ˆˆl m
;
ˆˆm n
if
˜˜ 

(
˜˜ 
await
˜˜ 
db
˜˜ 
.
˜˜ 
Clients
˜˜ 
.
˜˜ 
AnyAsync
˜˜ %
(
˜˜% &
x
˜˜& '
=>
˜˜( *
x
˜˜+ ,
.
˜˜, -
Email
˜˜- 2
==
˜˜3 5
email
˜˜6 ;
&&
˜˜< >
x
˜˜? @
.
˜˜@ A
Id
˜˜A C
!=
˜˜D F
client
˜˜G M
.
˜˜M N
Id
˜˜N P
,
˜˜P Q
ct
˜˜R T
)
˜˜T U
)
˜˜U V
return
˜˜W ]
Conflict
˜˜^ f
(
˜˜f g
new
˜˜g j
{
˜˜k l
message
˜˜m t
=
˜˜u v
$str˜˜w ï
}˜˜ñ ó
)˜˜ó ò
;˜˜ò ô
client
¯¯ 
.
¯¯ 
Email
¯¯ 
=
¯¯ 
email
¯¯ 
;
¯¯ 
return
˘˘ 
null
˘˘ 
;
˘˘ 
}
˙˙ 
[
¸¸ 
HttpGet
¸¸ 
(
¸¸ 
$str
¸¸ &
)
¸¸& '
]
¸¸' (
public
˝˝ 

IActionResult
˝˝ 
ClientTemplate
˝˝ '
(
˝˝' (
)
˝˝( )
=>
˝˝* ,
File
˝˝- 1
(
˝˝1 2
CreateWorkbook
˝˝2 @
(
˝˝@ A
new
˛˛ 
(
˛˛ 
$str
˛˛ 
,
˛˛ 
true
˛˛ 
,
˛˛  
$str
˛˛! B
)
˛˛B C
,
˛˛C D
new
ˇˇ 
(
ˇˇ 
$str
ˇˇ 
,
ˇˇ 
true
ˇˇ 
,
ˇˇ  
$str
ˇˇ! C
)
ˇˇC D
,
ˇˇD E
new
ÄÄ 
(
ÄÄ 
$str
ÄÄ 
,
ÄÄ 
true
ÄÄ 
,
ÄÄ 
$str
ÄÄ s
)
ÄÄs t
,
ÄÄt u
new
ÅÅ 
(
ÅÅ 
$str
ÅÅ 
,
ÅÅ 
false
ÅÅ 
,
ÅÅ 
$str
ÅÅ >
)
ÅÅ> ?
,
ÅÅ? @
new
ÇÇ 
(
ÇÇ 
$str
ÇÇ 
,
ÇÇ  
true
ÇÇ! %
,
ÇÇ% &
$str
ÇÇ' R
,
ÇÇR S
[
ÇÇT U
$str
ÇÇU Y
,
ÇÇY Z
$str
ÇÇ[ _
,
ÇÇ_ `
$str
ÇÇa e
]
ÇÇe f
)
ÇÇf g
,
ÇÇg h
new
ÉÉ 
(
ÉÉ 
$str
ÉÉ !
,
ÉÉ! "
false
ÉÉ# (
,
ÉÉ( )
$strÉÉ* ã
,ÉÉã å
[ÉÉç é
$strÉÉé í
,ÉÉí ì
$strÉÉî ò
]ÉÉò ô
)ÉÉô ö
)ÉÉö õ
,ÉÉõ ú
$str
ÑÑ K
,
ÑÑK L
$str
ÑÑM f
)
ÑÑf g
;
ÑÑg h
[
ÜÜ 
HttpPost
ÜÜ 
(
ÜÜ 
$str
ÜÜ 
)
ÜÜ 
]
ÜÜ  
public
áá 

async
áá 
Task
áá 
<
áá 
ActionResult
áá "
>
áá" #
ImportClients
áá$ 1
(
áá1 2
	IFormFile
áá2 ;
file
áá< @
,
áá@ A
CancellationToken
ááB S
ct
ááT V
)
ááV W
{
àà 
var
ââ 
created_
ââ 
=
ââ 
new
ââ 
List
ââ 
<
ââ  
(
ââ  !
Client
ââ! '
Client
ââ( .
,
ââ. /
ClientAccess
ââ0 <
Access
ââ= C
)
ââC D
>
ââD E
(
ââE F
)
ââF G
;
ââG H
var
ää 
(
ää 
failure
ää 
,
ää 
created
ää 
,
ää 
errors
ää %
)
ää% &
=
ää' (
await
ää) .
Import
ää/ 5
(
ää5 6
file
ää6 :
,
ää: ;
$str
ää< F
,
ääF G
async
ääH M
(
ääN O
row
ääO R
,
ääR S
	rowNumber
ääT ]
,
ää] ^
errors
ää_ e
)
ääe f
=>
ääg i
{
ãã 	
var
åå 
requiresTax
åå 
=
åå 
	ReadYesNo
åå '
(
åå' (
Cell
åå( ,
(
åå, -
row
åå- 0
,
åå0 1
$num
åå2 3
)
åå3 4
,
åå4 5
defaultValue
åå6 B
:
ååB C
false
ååD I
)
ååI J
;
ååJ K
var
çç 
request
çç 
=
çç 
new
çç 
ClientRequest
çç +
(
çç+ ,
Cell
çç, 0
(
çç0 1
row
çç1 4
,
çç4 5
$num
çç6 7
)
çç7 8
,
çç8 9
Cell
çç: >
(
çç> ?
row
çç? B
,
ççB C
$num
ççD E
)
ççE F
,
ççF G
Cell
ççH L
(
ççL M
row
ççM P
,
ççP Q
$num
ççR S
)
ççS T
,
ççT U
Cell
ççV Z
(
ççZ [
row
çç[ ^
,
çç^ _
$num
çç` a
)
çça b
,
ççb c
Cell
ççd h
(
ççh i
row
ççi l
,
ççl m
$num
ççn o
)
çço p
,
ççp q
requiresTax
ççr }
??çç~ Ä
falseççÅ Ü
)ççÜ á
;ççá à
varççâ å
errorççç í
=ççì î
requiresTaxççï †
isçç° £
nullçç§ ®
?çç© ™
$strçç´ ◊
:ççÿ Ÿ
ValidateClientçç⁄ Ë
(ççË È
requestççÈ 
)çç Ò
;ççÒ Ú
var
éé 
email
éé 
=
éé 
request
éé 
.
éé  
Email
éé  %
.
éé% &
Trim
éé& *
(
éé* +
)
éé+ ,
;
éé, -
if
èè 
(
èè 
error
èè 
is
èè 
not
èè 
null
èè !
||
èè" $
await
èè% *
db
èè+ -
.
èè- .
Clients
èè. 5
.
èè5 6
AnyAsync
èè6 >
(
èè> ?
x
èè? @
=>
èèA C
x
èèD E
.
èèE F
Email
èèF K
==
èèL N
email
èèO T
,
èèT U
ct
èèV X
)
èèX Y
||
èèZ \
await
èè] b
db
èèc e
.
èèe f
UserAccounts
èèf r
.
èèr s
AnyAsync
èès {
(
èè{ |
x
èè| }
=>èè~ Ä
xèèÅ Ç
.èèÇ É
EmailèèÉ à
==èèâ ã
emailèèå ë
,èèë í
ctèèì ï
)èèï ñ
)èèñ ó
{èèò ô
errorsèèö †
.èè† °
Addèè° §
(èè§ •
newèè• ®
(èè® ©
	rowNumberèè© ≤
,èè≤ ≥
errorèè¥ π
??èè∫ º
$strèèΩ €
)èè€ ‹
)èè‹ ›
;èè› ﬁ
returnèèﬂ Â
falseèèÊ Î
;èèÎ Ï
}èèÌ Ó
var
êê 
client
êê 
=
êê 
new
êê 
Client
êê #
{
êê$ %
CompanyName
êê& 1
=
êê2 3
request
êê4 ;
.
êê; <
CompanyName
êê< G
.
êêG H
Trim
êêH L
(
êêL M
)
êêM N
,
êêN O
ContactName
êêP [
=
êê\ ]
request
êê^ e
.
êêe f
ContactName
êêf q
.
êêq r
Trim
êêr v
(
êêv w
)
êêw x
,
êêx y
Email
êêz 
=êêÄ Å
emailêêÇ á
,êêá à
Phoneêêâ é
=êêè ê
EmptyToNullêêë ú
(êêú ù
requestêêù §
.êê§ •
Phoneêê• ™
)êê™ ´
,êê´ ¨!
PreferredLanguageêê≠ æ
=êêø ¿
requestêê¡ »
.êê» …!
PreferredLanguageêê… ⁄
.êê⁄ €
Trimêê€ ﬂ
(êêﬂ ‡
)êê‡ ·
.êê· ‚ 
ToLowerInvariantêê‚ Ú
(êêÚ Û
)êêÛ Ù
,êêÙ ı#
RequiresTaxDocumentêêˆ â
=êêä ã
requestêêå ì
.êêì î#
RequiresTaxDocumentêêî ß
}êê® ©
;êê© ™
db
ëë 
.
ëë 
Clients
ëë 
.
ëë 
Add
ëë 
(
ëë 
client
ëë !
)
ëë! "
;
ëë" #
created_
ëë$ ,
.
ëë, -
Add
ëë- 0
(
ëë0 1
(
ëë1 2
client
ëë2 8
,
ëë8 9
AddAdminUser
ëë: F
(
ëëF G
client
ëëG M
)
ëëM N
)
ëëN O
)
ëëO P
;
ëëP Q
return
ëëR X
true
ëëY ]
;
ëë] ^
}
íí 	
,
íí	 

ct
íí 
)
íí 
;
íí 
if
ìì 

(
ìì 
failure
ìì 
is
ìì 
not
ìì 
null
ìì 
)
ìì  
return
ìì! '
failure
ìì( /
;
ìì/ 0
var
îî 
accesses
îî 
=
îî 
new
îî 
List
îî 
<
îî  
ClientAccess
îî  ,
>
îî, -
(
îî- .
)
îî. /
;
îî/ 0
foreach
ïï 
(
ïï 
var
ïï 
(
ïï 
client
ïï 
,
ïï 
access
ïï $
)
ïï$ %
in
ïï& (
created_
ïï) 1
)
ïï1 2
accesses
ïï3 ;
.
ïï; <
Add
ïï< ?
(
ïï? @
await
ïï@ E
EmailAccessAsync
ïïF V
(
ïïV W
client
ïïW ]
,
ïï] ^
access
ïï_ e
,
ïïe f
ct
ïïg i
)
ïïi j
)
ïïj k
;
ïïk l
return
ññ 
Ok
ññ 
(
ññ 
new
ññ 
{
ññ 
created
ññ 
,
ññ  
skipped
ññ! (
=
ññ) *
errors
ññ+ 1
.
ññ1 2
Count
ññ2 7
,
ññ7 8
errors
ññ9 ?
,
ññ? @
accesses
ññA I
}
ññJ K
)
ññK L
;
ññL M
}
óó 
[
ùù 
HttpPost
ùù 
(
ùù 
$str
ùù (
)
ùù( )
]
ùù) *
public
ûû 

async
ûû 
Task
ûû 
<
ûû 
ActionResult
ûû "
>
ûû" #
ClientAccess
ûû$ 0
(
ûû0 1
Guid
ûû1 5
id
ûû6 8
,
ûû8 9
CancellationToken
ûû: K
ct
ûûL N
)
ûûN O
{
üü 
var
†† 
client
†† 
=
†† 
await
†† 
db
†† 
.
†† 
Clients
†† %
.
††% &
	FindAsync
††& /
(
††/ 0
[
††0 1
id
††1 3
]
††3 4
,
††4 5
ct
††6 8
)
††8 9
;
††9 :
if
††; =
(
††> ?
client
††? E
is
††F H
null
††I M
)
††M N
return
††O U
NotFound
††V ^
(
††^ _
)
††_ `
;
††` a
var
°° 
user
°° 
=
°° 
await
°° 
db
°° 
.
°° 
UserAccounts
°° (
.
°°( )"
SingleOrDefaultAsync
°°) =
(
°°= >
x
°°> ?
=>
°°@ B
x
°°C D
.
°°D E
Email
°°E J
==
°°K M
client
°°N T
.
°°T U
Email
°°U Z
,
°°Z [
ct
°°\ ^
)
°°^ _
;
°°_ `
if
¢¢ 

(
¢¢ 
user
¢¢ 
is
¢¢ 
not
¢¢ 
null
¢¢ 
&&
¢¢ 
user
¢¢  $
.
¢¢$ %
ClientId
¢¢% -
!=
¢¢. 0
client
¢¢1 7
.
¢¢7 8
Id
¢¢8 :
)
¢¢: ;
return
¢¢< B
Conflict
¢¢C K
(
¢¢K L
new
¢¢L O
{
¢¢P Q
message
¢¢R Y
=
¢¢Z [
$str¢¢\ ó
}¢¢ò ô
)¢¢ô ö
;¢¢ö õ
ClientAccess
££ 
access
££ 
;
££ 
if
§§ 

(
§§ 
user
§§ 
is
§§ 
null
§§ 
)
§§ 
access
§§  
=
§§! "
AddAdminUser
§§# /
(
§§/ 0
client
§§0 6
)
§§6 7
;
§§7 8
else
•• 
{
¶¶ 	
var
ßß 
temporaryPassword
ßß !
=
ßß" #
AccountController
ßß$ 5
.
ßß5 6
TemporaryPassword
ßß6 G
(
ßßG H
)
ßßH I
;
ßßI J
user
®® 
.
®® 
PasswordHash
®® 
=
®® 
AccountController
®®  1
.
®®1 2
Hasher
®®2 8
.
®®8 9
HashPassword
®®9 E
(
®®E F
user
®®F J
,
®®J K
temporaryPassword
®®L ]
)
®®] ^
;
®®^ _
user
®®` d
.
®®d e
IsActive
®®e m
=
®®n o
true
®®p t
;
®®t u
access
©© 
=
©© 
new
©© 
ClientAccess
©© %
(
©©% &
client
©©& ,
.
©©, -
CompanyName
©©- 8
,
©©8 9
user
©©: >
.
©©> ?
Email
©©? D
,
©©D E
temporaryPassword
©©F W
)
©©W X
;
©©X Y
}
™™ 	
await
´´ 
db
´´ 
.
´´ 
SaveChangesAsync
´´ !
(
´´! "
ct
´´" $
)
´´$ %
;
´´% &
return
¨¨ 
Ok
¨¨ 
(
¨¨ 
await
¨¨ 
EmailAccessAsync
¨¨ (
(
¨¨( )
client
¨¨) /
,
¨¨/ 0
access
¨¨1 7
,
¨¨7 8
ct
¨¨9 ;
)
¨¨; <
)
¨¨< =
;
¨¨= >
}
≠≠ 
[
ØØ 
HttpPost
ØØ 
(
ØØ 
$str
ØØ 0
)
ØØ0 1
]
ØØ1 2
public
∞∞ 

async
∞∞ 
Task
∞∞ 
<
∞∞ 
ActionResult
∞∞ "
>
∞∞" #
CreateProject
∞∞$ 1
(
∞∞1 2
Guid
∞∞2 6
clientId
∞∞7 ?
,
∞∞? @
ProjectRequest
∞∞A O
request
∞∞P W
,
∞∞W X
CancellationToken
∞∞Y j
ct
∞∞k m
)
∞∞m n
{
±± 
if
≤≤ 

(
≤≤ 
!
≤≤ 
await
≤≤ 
db
≤≤ 
.
≤≤ 
Clients
≤≤ 
.
≤≤ 
AnyAsync
≤≤ &
(
≤≤& '
x
≤≤' (
=>
≤≤) +
x
≤≤, -
.
≤≤- .
Id
≤≤. 0
==
≤≤1 3
clientId
≤≤4 <
,
≤≤< =
ct
≤≤> @
)
≤≤@ A
)
≤≤A B
return
≤≤C I
NotFound
≤≤J R
(
≤≤R S
)
≤≤S T
;
≤≤T U
if
≥≥ 

(
≥≥ 
string
≥≥ 
.
≥≥  
IsNullOrWhiteSpace
≥≥ %
(
≥≥% &
request
≥≥& -
.
≥≥- .
Name
≥≥. 2
)
≥≥2 3
)
≥≥3 4
return
≥≥5 ;

BadRequest
≥≥< F
(
≥≥F G
new
≥≥G J
{
≥≥K L
message
≥≥M T
=
≥≥U V
$str
≥≥W 
}≥≥Ä Å
)≥≥Å Ç
;≥≥Ç É
var
¥¥ 
slug
¥¥ 
=
¥¥ 
Slugify
¥¥ 
(
¥¥ 
string
¥¥ !
.
¥¥! " 
IsNullOrWhiteSpace
¥¥" 4
(
¥¥4 5
request
¥¥5 <
.
¥¥< =
Slug
¥¥= A
)
¥¥A B
?
¥¥C D
request
¥¥E L
.
¥¥L M
Name
¥¥M Q
:
¥¥R S
request
¥¥T [
.
¥¥[ \
Slug
¥¥\ `
)
¥¥` a
;
¥¥a b
if
µµ 

(
µµ 
slug
µµ 
.
µµ 
Length
µµ 
==
µµ 
$num
µµ 
)
µµ 
return
µµ $

BadRequest
µµ% /
(
µµ/ 0
new
µµ0 3
{
µµ4 5
message
µµ6 =
=
µµ> ?
$str
µµ@ P
}
µµQ R
)
µµR S
;
µµS T
if
∂∂ 

(
∂∂ 
await
∂∂ 
db
∂∂ 
.
∂∂ 
Projects
∂∂ 
.
∂∂ 
AnyAsync
∂∂ &
(
∂∂& '
x
∂∂' (
=>
∂∂) +
x
∂∂, -
.
∂∂- .
Slug
∂∂. 2
==
∂∂3 5
slug
∂∂6 :
,
∂∂: ;
ct
∂∂< >
)
∂∂> ?
)
∂∂? @
return
∂∂A G
Conflict
∂∂H P
(
∂∂P Q
new
∂∂Q T
{
∂∂U V
message
∂∂W ^
=
∂∂_ `
$"
∂∂a c
$str∂∂c Ü
{∂∂Ü á
slug∂∂á ã
}∂∂ã å
$str∂∂å é
"∂∂é è
}∂∂ê ë
)∂∂ë í
;∂∂í ì
var
∑∑ 
project
∑∑ 
=
∑∑ 
new
∑∑ 
Project
∑∑ !
{
∑∑" #
ClientId
∑∑$ ,
=
∑∑- .
clientId
∑∑/ 7
,
∑∑7 8
Name
∑∑9 =
=
∑∑> ?
request
∑∑@ G
.
∑∑G H
Name
∑∑H L
.
∑∑L M
Trim
∑∑M Q
(
∑∑Q R
)
∑∑R S
,
∑∑S T
Slug
∑∑U Y
=
∑∑Z [
slug
∑∑\ `
}
∑∑a b
;
∑∑b c
if
ππ 

(
ππ 
!
ππ 
string
ππ 
.
ππ  
IsNullOrWhiteSpace
ππ &
(
ππ& '
request
ππ' .
.
ππ. /
GithubRepoOwner
ππ/ >
)
ππ> ?
&&
ππ@ B
!
ππC D
string
ππD J
.
ππJ K 
IsNullOrWhiteSpace
ππK ]
(
ππ] ^
request
ππ^ e
.
ππe f
GithubRepoName
ππf t
)
ππt u
)
ππu v
{
∫∫ 	
var
ªª 

repository
ªª 
=
ªª 
new
ªª  
ProjectRepository
ªª! 2
{
ªª3 4
	ProjectId
ªª5 >
=
ªª? @
project
ªªA H
.
ªªH I
Id
ªªI K
,
ªªK L
Owner
ªªM R
=
ªªS T
request
ªªU \
.
ªª\ ]
GithubRepoOwner
ªª] l
.
ªªl m
Trim
ªªm q
(
ªªq r
)
ªªr s
,
ªªs t
Name
ªªu y
=
ªªz {
requestªª| É
.ªªÉ Ñ
GithubRepoNameªªÑ í
.ªªí ì
Trimªªì ó
(ªªó ò
)ªªò ô
,ªªô ö
	IsDefaultªªõ §
=ªª• ¶
trueªªß ´
}ªª¨ ≠
;ªª≠ Æ
if
ºº 
(
ºº 
await
ºº %
RepositoryConflictAsync
ºº -
(
ºº- .

repository
ºº. 8
.
ºº8 9
Owner
ºº9 >
,
ºº> ?

repository
ºº@ J
.
ººJ K
Name
ººK O
,
ººO P
null
ººQ U
,
ººU V
ct
ººW Y
)
ººY Z
is
ºº[ ]
{
ºº^ _
}
ºº` a
conflict
ººb j
)
ººj k
return
ººl r
conflict
ººs {
;
ºº{ |
project
ΩΩ 
.
ΩΩ 
Repositories
ΩΩ  
.
ΩΩ  !
Add
ΩΩ! $
(
ΩΩ$ %

repository
ΩΩ% /
)
ΩΩ/ 0
;
ΩΩ0 1
}
ææ 	
db
øø 

.
øø
 
Projects
øø 
.
øø 
Add
øø 
(
øø 
project
øø 
)
øø  
;
øø  !
await
øø" '
db
øø( *
.
øø* +
SaveChangesAsync
øø+ ;
(
øø; <
ct
øø< >
)
øø> ?
;
øø? @
return
¿¿ 
Created
¿¿ 
(
¿¿ 
$"
¿¿ 
$str
¿¿ -
{
¿¿- .
project
¿¿. 5
.
¿¿5 6
Id
¿¿6 8
}
¿¿8 9
"
¿¿9 :
,
¿¿: ;

ProjectDto
¿¿< F
(
¿¿F G
project
¿¿G N
)
¿¿N O
)
¿¿O P
;
¿¿P Q
}
¡¡ 
[
√√ 
	HttpPatch
√√ 
(
√√ 
$str
√√ #
)
√√# $
]
√√$ %
public
ƒƒ 

async
ƒƒ 
Task
ƒƒ 
<
ƒƒ 
ActionResult
ƒƒ "
>
ƒƒ" #
UpdateProject
ƒƒ$ 1
(
ƒƒ1 2
Guid
ƒƒ2 6
id
ƒƒ7 9
,
ƒƒ9 :
ProjectRequest
ƒƒ; I
request
ƒƒJ Q
,
ƒƒQ R
CancellationToken
ƒƒS d
ct
ƒƒe g
)
ƒƒg h
{
≈≈ 
var
∆∆ 
project
∆∆ 
=
∆∆ 
await
∆∆ 
db
∆∆ 
.
∆∆ 
Projects
∆∆ '
.
∆∆' (
Include
∆∆( /
(
∆∆/ 0
x
∆∆0 1
=>
∆∆2 4
x
∆∆5 6
.
∆∆6 7
Repositories
∆∆7 C
)
∆∆C D
.
∆∆D E"
SingleOrDefaultAsync
∆∆E Y
(
∆∆Y Z
x
∆∆Z [
=>
∆∆\ ^
x
∆∆_ `
.
∆∆` a
Id
∆∆a c
==
∆∆d f
id
∆∆g i
,
∆∆i j
ct
∆∆k m
)
∆∆m n
;
∆∆n o
if
∆∆p r
(
∆∆s t
project
∆∆t {
is
∆∆| ~
null∆∆ É
)∆∆É Ñ
return∆∆Ö ã
NotFound∆∆å î
(∆∆î ï
)∆∆ï ñ
;∆∆ñ ó
if
«« 

(
«« 
request
«« 
.
«« 
Name
«« 
is
«« 
not
«« 
null
««  $
)
««$ %
{
»» 	
if
…… 
(
…… 
string
…… 
.
……  
IsNullOrWhiteSpace
…… )
(
……) *
request
……* 1
.
……1 2
Name
……2 6
)
……6 7
)
……7 8
return
……9 ?

BadRequest
……@ J
(
……J K
new
……K N
{
……O P
message
……Q X
=
……Y Z
$str……[ É
}……Ñ Ö
)……Ö Ü
;……Ü á
project
   
.
   
Name
   
=
   
request
   "
.
  " #
Name
  # '
.
  ' (
Trim
  ( ,
(
  , -
)
  - .
;
  . /
}
ÀÀ 	
await
ÃÃ 
db
ÃÃ 
.
ÃÃ 
SaveChangesAsync
ÃÃ !
(
ÃÃ! "
ct
ÃÃ" $
)
ÃÃ$ %
;
ÃÃ% &
return
ÃÃ' -
Ok
ÃÃ. 0
(
ÃÃ0 1

ProjectDto
ÃÃ1 ;
(
ÃÃ; <
project
ÃÃ< C
)
ÃÃC D
)
ÃÃD E
;
ÃÃE F
}
ÕÕ 
[
–– 

HttpDelete
–– 
(
–– 
$str
–– $
)
––$ %
]
––% &
public
—— 

async
—— 
Task
—— 
<
—— 
ActionResult
—— "
>
——" #
DeleteProject
——$ 1
(
——1 2
Guid
——2 6
id
——7 9
,
——9 :
CancellationToken
——; L
ct
——M O
)
——O P
{
““ 
var
”” 
project
”” 
=
”” 
await
”” 
db
”” 
.
”” 
Projects
”” '
.
””' (
Include
””( /
(
””/ 0
x
””0 1
=>
””2 4
x
””5 6
.
””6 7
Repositories
””7 C
)
””C D
.
””D E"
SingleOrDefaultAsync
””E Y
(
””Y Z
x
””Z [
=>
””\ ^
x
””_ `
.
””` a
Id
””a c
==
””d f
id
””g i
,
””i j
ct
””k m
)
””m n
;
””n o
if
””p r
(
””s t
project
””t {
is
””| ~
null”” É
)””É Ñ
return””Ö ã
NotFound””å î
(””î ï
)””ï ñ
;””ñ ó
var
‘‘ 
products
‘‘ 
=
‘‘ 
await
‘‘ 
db
‘‘ 
.
‘‘  
ClientProducts
‘‘  .
.
‘‘. /

CountAsync
‘‘/ 9
(
‘‘9 :
x
‘‘: ;
=>
‘‘< >
x
‘‘? @
.
‘‘@ A
	ProjectId
‘‘A J
==
‘‘K M
id
‘‘N P
,
‘‘P Q
ct
‘‘R T
)
‘‘T U
;
‘‘U V
var
’’ 
tickets
’’ 
=
’’ 
await
’’ 
db
’’ 
.
’’ 
Tickets
’’ &
.
’’& '

CountAsync
’’' 1
(
’’1 2
x
’’2 3
=>
’’4 6
x
’’7 8
.
’’8 9
	ProjectId
’’9 B
==
’’C E
id
’’F H
,
’’H I
ct
’’J L
)
’’L M
;
’’M N
if
÷÷ 

(
÷÷ 
products
÷÷ 
+
÷÷ 
tickets
÷÷ 
>
÷÷  
$num
÷÷! "
)
÷÷" #
return
◊◊ 
Conflict
◊◊ 
(
◊◊ 
new
◊◊ 
{
◊◊  !
message
◊◊" )
=
◊◊* +
$"
◊◊, .
$str
◊◊. /
{
◊◊/ 0
project
◊◊0 7
.
◊◊7 8
Name
◊◊8 <
}
◊◊< =
$str
◊◊= E
{
◊◊E F
Count
◊◊F K
(
◊◊K L
products
◊◊L T
,
◊◊T U
$str
◊◊V `
,
◊◊` a
$str
◊◊b m
)
◊◊m n
}
◊◊n o
{
◊◊o p
(
◊◊p q
products
◊◊q y
>
◊◊z {
$num
◊◊| }
&&◊◊~ Ä
tickets◊◊Å à
>◊◊â ä
$num◊◊ã å
?◊◊ç é
$str◊◊è î
:◊◊ï ñ
$str◊◊ó ô
)◊◊ô ö
}◊◊ö õ
{◊◊õ ú
Count◊◊ú °
(◊◊° ¢
tickets◊◊¢ ©
,◊◊© ™
$str◊◊´ ≥
,◊◊≥ ¥
$str◊◊µ æ
)◊◊æ ø
}◊◊ø ¿
$str◊◊¿ ¬
{◊◊¬ √
(◊◊√ ƒ
products◊◊ƒ Ã
>◊◊Õ Œ
$num◊◊œ –
?◊◊— “
$str◊◊” ñ
:◊◊ó ò
$str◊◊ô Ê
)◊◊Ê Á
}◊◊Á Ë
$str◊◊Ë È
"◊◊È Í
}◊◊Î Ï
)◊◊Ï Ì
;◊◊Ì Ó
db
ÿÿ 

.
ÿÿ
 !
ProjectRepositories
ÿÿ 
.
ÿÿ 
RemoveRange
ÿÿ *
(
ÿÿ* +
project
ÿÿ+ 2
.
ÿÿ2 3
Repositories
ÿÿ3 ?
)
ÿÿ? @
;
ÿÿ@ A
db
ÿÿB D
.
ÿÿD E
Projects
ÿÿE M
.
ÿÿM N
Remove
ÿÿN T
(
ÿÿT U
project
ÿÿU \
)
ÿÿ\ ]
;
ÿÿ] ^
await
ŸŸ 
db
ŸŸ 
.
ŸŸ 
SaveChangesAsync
ŸŸ !
(
ŸŸ! "
ct
ŸŸ" $
)
ŸŸ$ %
;
ŸŸ% &
return
ŸŸ' -
	NoContent
ŸŸ. 7
(
ŸŸ7 8
)
ŸŸ8 9
;
ŸŸ9 :
}
⁄⁄ 
private
‹‹ 
static
‹‹ 
string
‹‹ 
Count
‹‹ 
(
‹‹  
int
‹‹  #
n
‹‹$ %
,
‹‹% &
string
‹‹' -
one
‹‹. 1
,
‹‹1 2
string
‹‹3 9
many
‹‹: >
)
‹‹> ?
=>
‹‹@ B
n
‹‹C D
switch
‹‹E K
{
‹‹L M
$num
‹‹N O
=>
‹‹P R
$str
‹‹S U
,
‹‹U V
$num
‹‹W X
=>
‹‹Y [
$"
‹‹\ ^
$str
‹‹^ `
{
‹‹` a
one
‹‹a d
}
‹‹d e
"
‹‹e f
,
‹‹f g
_
‹‹h i
=>
‹‹j l
$"
‹‹m o
{
‹‹o p
n
‹‹p q
}
‹‹q r
$str
‹‹r s
{
‹‹s t
many
‹‹t x
}
‹‹x y
"
‹‹y z
}
‹‹{ |
;
‹‹| }
[
ﬁﬁ 
HttpPost
ﬁﬁ 
(
ﬁﬁ 
$str
ﬁﬁ /
)
ﬁﬁ/ 0
]
ﬁﬁ0 1
public
ﬂﬂ 

async
ﬂﬂ 
Task
ﬂﬂ 
<
ﬂﬂ 
ActionResult
ﬂﬂ "
>
ﬂﬂ" #
AddRepository
ﬂﬂ$ 1
(
ﬂﬂ1 2
Guid
ﬂﬂ2 6
id
ﬂﬂ7 9
,
ﬂﬂ9 :
RepositoryRequest
ﬂﬂ; L
request
ﬂﬂM T
,
ﬂﬂT U
CancellationToken
ﬂﬂV g
ct
ﬂﬂh j
)
ﬂﬂj k
{
‡‡ 
var
·· 
project
·· 
=
·· 
await
·· 
db
·· 
.
·· 
Projects
·· '
.
··' (
Include
··( /
(
··/ 0
x
··0 1
=>
··2 4
x
··5 6
.
··6 7
Repositories
··7 C
)
··C D
.
··D E"
SingleOrDefaultAsync
··E Y
(
··Y Z
x
··Z [
=>
··\ ^
x
··_ `
.
··` a
Id
··a c
==
··d f
id
··g i
,
··i j
ct
··k m
)
··m n
;
··n o
if
··p r
(
··s t
project
··t {
is
··| ~
null·· É
)··É Ñ
return··Ö ã
NotFound··å î
(··î ï
)··ï ñ
;··ñ ó
if
‚‚ 

(
‚‚ 
string
‚‚ 
.
‚‚  
IsNullOrWhiteSpace
‚‚ %
(
‚‚% &
request
‚‚& -
.
‚‚- .
Owner
‚‚. 3
)
‚‚3 4
||
‚‚5 7
string
‚‚8 >
.
‚‚> ? 
IsNullOrWhiteSpace
‚‚? Q
(
‚‚Q R
request
‚‚R Y
.
‚‚Y Z
Name
‚‚Z ^
)
‚‚^ _
)
‚‚_ `
return
‚‚a g

BadRequest
‚‚h r
(
‚‚r s
new
‚‚s v
{
‚‚w x
message‚‚y Ä
=‚‚Å Ç
$str‚‚É ±
}‚‚≤ ≥
)‚‚≥ ¥
;‚‚¥ µ
var
„„ 

repository
„„ 
=
„„ 
new
„„ 
ProjectRepository
„„ .
{
„„/ 0
	ProjectId
„„1 :
=
„„; <
id
„„= ?
,
„„? @
Owner
„„A F
=
„„G H
request
„„I P
.
„„P Q
Owner
„„Q V
.
„„V W
Trim
„„W [
(
„„[ \
)
„„\ ]
,
„„] ^
Name
„„_ c
=
„„d e
request
„„f m
.
„„m n
Name
„„n r
.
„„r s
Trim
„„s w
(
„„w x
)
„„x y
,
„„y z
Label„„{ Ä
=„„Å Ç
EmptyToNull„„É é
(„„é è
request„„è ñ
.„„ñ ó
Label„„ó ú
)„„ú ù
,„„ù û
	IsDefault„„ü ®
=„„© ™
project„„´ ≤
.„„≤ ≥
Repositories„„≥ ø
.„„ø ¿
Count„„¿ ≈
==„„∆ »
$num„„…  
||„„À Õ
request„„Œ ’
.„„’ ÷
	IsDefault„„÷ ﬂ
==„„‡ ‚
true„„„ Á
}„„Ë È
;„„È Í
if
‰‰ 

(
‰‰ 
await
‰‰ %
RepositoryConflictAsync
‰‰ )
(
‰‰) *

repository
‰‰* 4
.
‰‰4 5
Owner
‰‰5 :
,
‰‰: ;

repository
‰‰< F
.
‰‰F G
Name
‰‰G K
,
‰‰K L
null
‰‰M Q
,
‰‰Q R
ct
‰‰S U
)
‰‰U V
is
‰‰W Y
{
‰‰Z [
}
‰‰\ ]
conflict
‰‰^ f
)
‰‰f g
return
‰‰h n
conflict
‰‰o w
;
‰‰w x
if
ÂÂ 

(
ÂÂ 

repository
ÂÂ 
.
ÂÂ 
	IsDefault
ÂÂ  
)
ÂÂ  !
foreach
ÂÂ" )
(
ÂÂ* +
var
ÂÂ+ .
other
ÂÂ/ 4
in
ÂÂ5 7
project
ÂÂ8 ?
.
ÂÂ? @
Repositories
ÂÂ@ L
)
ÂÂL M
other
ÂÂN S
.
ÂÂS T
	IsDefault
ÂÂT ]
=
ÂÂ^ _
false
ÂÂ` e
;
ÂÂe f
db
ÊÊ 

.
ÊÊ
 !
ProjectRepositories
ÊÊ 
.
ÊÊ 
Add
ÊÊ "
(
ÊÊ" #

repository
ÊÊ# -
)
ÊÊ- .
;
ÊÊ. /
project
ÊÊ0 7
.
ÊÊ7 8
Repositories
ÊÊ8 D
.
ÊÊD E
Add
ÊÊE H
(
ÊÊH I

repository
ÊÊI S
)
ÊÊS T
;
ÊÊT U
await
ÊÊV [
db
ÊÊ\ ^
.
ÊÊ^ _
SaveChangesAsync
ÊÊ_ o
(
ÊÊo p
ct
ÊÊp r
)
ÊÊr s
;
ÊÊs t
return
ÁÁ 
Ok
ÁÁ 
(
ÁÁ 

ProjectDto
ÁÁ 
(
ÁÁ 
project
ÁÁ $
)
ÁÁ$ %
)
ÁÁ% &
;
ÁÁ& '
}
ËË 
[
ÍÍ 
	HttpPatch
ÍÍ 
(
ÍÍ 
$str
ÍÍ '
)
ÍÍ' (
]
ÍÍ( )
public
ÎÎ 

async
ÎÎ 
Task
ÎÎ 
<
ÎÎ 
ActionResult
ÎÎ "
>
ÎÎ" #
UpdateRepository
ÎÎ$ 4
(
ÎÎ4 5
Guid
ÎÎ5 9
id
ÎÎ: <
,
ÎÎ< =
RepositoryRequest
ÎÎ> O
request
ÎÎP W
,
ÎÎW X
CancellationToken
ÎÎY j
ct
ÎÎk m
)
ÎÎm n
{
ÏÏ 
var
ÌÌ 

repository
ÌÌ 
=
ÌÌ 
await
ÌÌ 
db
ÌÌ !
.
ÌÌ! "!
ProjectRepositories
ÌÌ" 5
.
ÌÌ5 6
	FindAsync
ÌÌ6 ?
(
ÌÌ? @
[
ÌÌ@ A
id
ÌÌA C
]
ÌÌC D
,
ÌÌD E
ct
ÌÌF H
)
ÌÌH I
;
ÌÌI J
if
ÌÌK M
(
ÌÌN O

repository
ÌÌO Y
is
ÌÌZ \
null
ÌÌ] a
)
ÌÌa b
return
ÌÌc i
NotFound
ÌÌj r
(
ÌÌr s
)
ÌÌs t
;
ÌÌt u
var
ÓÓ 
project
ÓÓ 
=
ÓÓ 
await
ÓÓ 
db
ÓÓ 
.
ÓÓ 
Projects
ÓÓ '
.
ÓÓ' (
Include
ÓÓ( /
(
ÓÓ/ 0
x
ÓÓ0 1
=>
ÓÓ2 4
x
ÓÓ5 6
.
ÓÓ6 7
Repositories
ÓÓ7 C
)
ÓÓC D
.
ÓÓD E
SingleAsync
ÓÓE P
(
ÓÓP Q
x
ÓÓQ R
=>
ÓÓS U
x
ÓÓV W
.
ÓÓW X
Id
ÓÓX Z
==
ÓÓ[ ]

repository
ÓÓ^ h
.
ÓÓh i
	ProjectId
ÓÓi r
,
ÓÓr s
ct
ÓÓt v
)
ÓÓv w
;
ÓÓw x
var
ÔÔ 
owner
ÔÔ 
=
ÔÔ 
request
ÔÔ 
.
ÔÔ 
Owner
ÔÔ !
?
ÔÔ! "
.
ÔÔ" #
Trim
ÔÔ# '
(
ÔÔ' (
)
ÔÔ( )
??
ÔÔ* ,

repository
ÔÔ- 7
.
ÔÔ7 8
Owner
ÔÔ8 =
;
ÔÔ= >
var
ÔÔ? B
name
ÔÔC G
=
ÔÔH I
request
ÔÔJ Q
.
ÔÔQ R
Name
ÔÔR V
?
ÔÔV W
.
ÔÔW X
Trim
ÔÔX \
(
ÔÔ\ ]
)
ÔÔ] ^
??
ÔÔ_ a

repository
ÔÔb l
.
ÔÔl m
Name
ÔÔm q
;
ÔÔq r
if
 

(
 
owner
 
.
 
Length
 
==
 
$num
 
||
  
name
! %
.
% &
Length
& ,
==
- /
$num
0 1
)
1 2
return
3 9

BadRequest
: D
(
D E
new
E H
{
I J
message
K R
=
S T
$strU É
}Ñ Ö
)Ö Ü
;Ü á
if
ÚÚ 

(
ÚÚ 
(
ÚÚ 
owner
ÚÚ 
!=
ÚÚ 

repository
ÚÚ  
.
ÚÚ  !
Owner
ÚÚ! &
||
ÚÚ' )
name
ÚÚ* .
!=
ÚÚ/ 1

repository
ÚÚ2 <
.
ÚÚ< =
Name
ÚÚ= A
)
ÚÚA B
&&
ÚÚC E
await
ÚÚF K
db
ÚÚL N
.
ÚÚN O
Tickets
ÚÚO V
.
ÚÚV W
AnyAsync
ÚÚW _
(
ÚÚ_ `
x
ÚÚ` a
=>
ÚÚb d
x
ÚÚe f
.
ÚÚf g
RepositoryId
ÚÚg s
==
ÚÚt v
id
ÚÚw y
&&
ÚÚz |
x
ÚÚ} ~
.
ÚÚ~  
GithubIssueNumberÚÚ ê
!=ÚÚë ì
nullÚÚî ò
,ÚÚò ô
ctÚÚö ú
)ÚÚú ù
)ÚÚù û
return
ÛÛ 
Conflict
ÛÛ 
(
ÛÛ 
new
ÛÛ 
{
ÛÛ  !
message
ÛÛ" )
=
ÛÛ* +
$strÛÛ, Ä
}ÛÛÅ Ç
)ÛÛÇ É
;ÛÛÉ Ñ
if
ÙÙ 

(
ÙÙ 
await
ÙÙ %
RepositoryConflictAsync
ÙÙ )
(
ÙÙ) *
owner
ÙÙ* /
,
ÙÙ/ 0
name
ÙÙ1 5
,
ÙÙ5 6
id
ÙÙ7 9
,
ÙÙ9 :
ct
ÙÙ; =
)
ÙÙ= >
is
ÙÙ? A
{
ÙÙB C
}
ÙÙD E
conflict
ÙÙF N
)
ÙÙN O
return
ÙÙP V
conflict
ÙÙW _
;
ÙÙ_ `

repository
ıı 
.
ıı 
Owner
ıı 
=
ıı 
owner
ıı  
;
ıı  !

repository
ıı" ,
.
ıı, -
Name
ıı- 1
=
ıı2 3
name
ıı4 8
;
ıı8 9
if
ˆˆ 

(
ˆˆ 
request
ˆˆ 
.
ˆˆ 
Label
ˆˆ 
is
ˆˆ 
not
ˆˆ  
null
ˆˆ! %
)
ˆˆ% &

repository
ˆˆ' 1
.
ˆˆ1 2
Label
ˆˆ2 7
=
ˆˆ8 9
EmptyToNull
ˆˆ: E
(
ˆˆE F
request
ˆˆF M
.
ˆˆM N
Label
ˆˆN S
)
ˆˆS T
;
ˆˆT U
if
˜˜ 

(
˜˜ 
request
˜˜ 
.
˜˜ 
	IsDefault
˜˜ 
==
˜˜  
true
˜˜! %
)
˜˜% &
foreach
˜˜' .
(
˜˜/ 0
var
˜˜0 3
other
˜˜4 9
in
˜˜: <
project
˜˜= D
.
˜˜D E
Repositories
˜˜E Q
)
˜˜Q R
other
˜˜S X
.
˜˜X Y
	IsDefault
˜˜Y b
=
˜˜c d
other
˜˜e j
.
˜˜j k
Id
˜˜k m
==
˜˜n p
id
˜˜q s
;
˜˜s t
await
¯¯ 
db
¯¯ 
.
¯¯ 
SaveChangesAsync
¯¯ !
(
¯¯! "
ct
¯¯" $
)
¯¯$ %
;
¯¯% &
return
¯¯' -
Ok
¯¯. 0
(
¯¯0 1

ProjectDto
¯¯1 ;
(
¯¯; <
project
¯¯< C
)
¯¯C D
)
¯¯D E
;
¯¯E F
}
˘˘ 
[
˚˚ 

HttpDelete
˚˚ 
(
˚˚ 
$str
˚˚ (
)
˚˚( )
]
˚˚) *
public
¸¸ 

async
¸¸ 
Task
¸¸ 
<
¸¸ 
ActionResult
¸¸ "
>
¸¸" #
DeleteRepository
¸¸$ 4
(
¸¸4 5
Guid
¸¸5 9
id
¸¸: <
,
¸¸< =
CancellationToken
¸¸> O
ct
¸¸P R
)
¸¸R S
{
˝˝ 
var
˛˛ 

repository
˛˛ 
=
˛˛ 
await
˛˛ 
db
˛˛ !
.
˛˛! "!
ProjectRepositories
˛˛" 5
.
˛˛5 6
	FindAsync
˛˛6 ?
(
˛˛? @
[
˛˛@ A
id
˛˛A C
]
˛˛C D
,
˛˛D E
ct
˛˛F H
)
˛˛H I
;
˛˛I J
if
˛˛K M
(
˛˛N O

repository
˛˛O Y
is
˛˛Z \
null
˛˛] a
)
˛˛a b
return
˛˛c i
NotFound
˛˛j r
(
˛˛r s
)
˛˛s t
;
˛˛t u
if
ˇˇ 

(
ˇˇ 
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
Tickets
ˇˇ 
.
ˇˇ 
AnyAsync
ˇˇ %
(
ˇˇ% &
x
ˇˇ& '
=>
ˇˇ( *
x
ˇˇ+ ,
.
ˇˇ, -
RepositoryId
ˇˇ- 9
==
ˇˇ: <
id
ˇˇ= ?
,
ˇˇ? @
ct
ˇˇA C
)
ˇˇC D
)
ˇˇD E
return
ˇˇF L
Conflict
ˇˇM U
(
ˇˇU V
new
ˇˇV Y
{
ˇˇZ [
message
ˇˇ\ c
=
ˇˇd e
$strˇˇf £
}ˇˇ§ •
)ˇˇ• ¶
;ˇˇ¶ ß
var
ÄÄ 
project
ÄÄ 
=
ÄÄ 
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
Projects
ÄÄ '
.
ÄÄ' (
Include
ÄÄ( /
(
ÄÄ/ 0
x
ÄÄ0 1
=>
ÄÄ2 4
x
ÄÄ5 6
.
ÄÄ6 7
Repositories
ÄÄ7 C
)
ÄÄC D
.
ÄÄD E
SingleAsync
ÄÄE P
(
ÄÄP Q
x
ÄÄQ R
=>
ÄÄS U
x
ÄÄV W
.
ÄÄW X
Id
ÄÄX Z
==
ÄÄ[ ]

repository
ÄÄ^ h
.
ÄÄh i
	ProjectId
ÄÄi r
,
ÄÄr s
ct
ÄÄt v
)
ÄÄv w
;
ÄÄw x
project
ÅÅ 
.
ÅÅ 
Repositories
ÅÅ 
.
ÅÅ 
Remove
ÅÅ #
(
ÅÅ# $

repository
ÅÅ$ .
)
ÅÅ. /
;
ÅÅ/ 0
db
ÅÅ1 3
.
ÅÅ3 4!
ProjectRepositories
ÅÅ4 G
.
ÅÅG H
Remove
ÅÅH N
(
ÅÅN O

repository
ÅÅO Y
)
ÅÅY Z
;
ÅÅZ [
if
ÇÇ 

(
ÇÇ 

repository
ÇÇ 
.
ÇÇ 
	IsDefault
ÇÇ  
&&
ÇÇ! #
project
ÇÇ$ +
.
ÇÇ+ ,
Repositories
ÇÇ, 8
.
ÇÇ8 9
FirstOrDefault
ÇÇ9 G
(
ÇÇG H
)
ÇÇH I
is
ÇÇJ L
{
ÇÇM N
}
ÇÇO P
next
ÇÇQ U
)
ÇÇU V
next
ÇÇW [
.
ÇÇ[ \
	IsDefault
ÇÇ\ e
=
ÇÇf g
true
ÇÇh l
;
ÇÇl m
await
ÉÉ 
db
ÉÉ 
.
ÉÉ 
SaveChangesAsync
ÉÉ !
(
ÉÉ! "
ct
ÉÉ" $
)
ÉÉ$ %
;
ÉÉ% &
return
ÉÉ' -
Ok
ÉÉ. 0
(
ÉÉ0 1

ProjectDto
ÉÉ1 ;
(
ÉÉ; <
project
ÉÉ< C
)
ÉÉC D
)
ÉÉD E
;
ÉÉE F
}
ÑÑ 
private
ÜÜ 
async
ÜÜ 
Task
ÜÜ 
<
ÜÜ 
ActionResult
ÜÜ #
?
ÜÜ# $
>
ÜÜ$ %%
RepositoryConflictAsync
ÜÜ& =
(
ÜÜ= >
string
ÜÜ> D
owner
ÜÜE J
,
ÜÜJ K
string
ÜÜL R
name
ÜÜS W
,
ÜÜW X
Guid
ÜÜY ]
?
ÜÜ] ^
exceptId
ÜÜ_ g
,
ÜÜg h
CancellationToken
ÜÜi z
ct
ÜÜ{ }
)
ÜÜ} ~
=>ÜÜ Å
await
áá 
db
áá 
.
áá !
ProjectRepositories
áá $
.
áá$ %
AnyAsync
áá% -
(
áá- .
x
áá. /
=>
áá0 2
x
áá3 4
.
áá4 5
Owner
áá5 :
==
áá; =
owner
áá> C
&&
ááD F
x
ááG H
.
ááH I
Name
ááI M
==
ááN P
name
ááQ U
&&
ááV X
x
ááY Z
.
ááZ [
Id
áá[ ]
!=
áá^ `
exceptId
ááa i
,
áái j
ct
áák m
)
áám n
?
àà 
Conflict
àà 
(
àà 
new
àà 
{
àà 
message
àà $
=
àà% &
$"
àà' )
$str
àà) 8
{
àà8 9
owner
àà9 >
}
àà> ?
$str
àà? @
{
àà@ A
name
ààA E
}
ààE F
$str
ààF f
"
ààf g
}
ààh i
)
àài j
:
ààk l
null
ààm q
;
ààq r
private
ãã 
async
ãã 
Task
ãã 
<
ãã 
ClientAccess
ãã #
>
ãã# $
EmailAccessAsync
ãã% 5
(
ãã5 6
Client
ãã6 <
client
ãã= C
,
ããC D
ClientAccess
ããE Q
access
ããR X
,
ããX Y
CancellationToken
ããZ k
ct
ããl n
)
ããn o
=>
ããp r
access
åå 
with
åå 
{
åå 
	EmailSent
åå 
=
åå  !
await
åå" '
accessEmail
åå( 3
.
åå3 4
	SendAsync
åå4 =
(
åå= >
client
åå> D
,
ååD E
client
ååF L
.
ååL M
ContactName
ååM X
,
ååX Y
access
ååZ `
.
åå` a
Email
ååa f
,
ååf g
access
ååh n
.
åån o 
TemporaryPasswordååo Ä
,ååÄ Å
RequestååÇ â
,ååâ ä
ctååã ç
)ååç é
}ååè ê
;ååê ë
private
éé 
ClientAccess
éé 
AddAdminUser
éé %
(
éé% &
Client
éé& ,
client
éé- 3
)
éé3 4
{
èè 
var
êê 
temporaryPassword
êê 
=
êê 
AccountController
êê  1
.
êê1 2
TemporaryPassword
êê2 C
(
êêC D
)
êêD E
;
êêE F
var
ëë 
user
ëë 
=
ëë 
new
ëë 
UserAccount
ëë "
{
ëë# $
ClientId
ëë% -
=
ëë. /
client
ëë0 6
.
ëë6 7
Id
ëë7 9
,
ëë9 :
Name
ëë; ?
=
ëë@ A
client
ëëB H
.
ëëH I
ContactName
ëëI T
,
ëëT U
Email
ëëV [
=
ëë\ ]
client
ëë^ d
.
ëëd e
Email
ëëe j
,
ëëj k
Role
ëël p
=
ëëq r
UserRole
ëës {
.
ëë{ |
Adminëë| Å
}ëëÇ É
;ëëÉ Ñ
user
íí 
.
íí 
PasswordHash
íí 
=
íí 
AccountController
íí -
.
íí- .
Hasher
íí. 4
.
íí4 5
HashPassword
íí5 A
(
ííA B
user
ííB F
,
ííF G
temporaryPassword
ííH Y
)
ííY Z
;
ííZ [
db
ìì 

.
ìì
 
UserAccounts
ìì 
.
ìì 
Add
ìì 
(
ìì 
user
ìì  
)
ìì  !
;
ìì! "
return
îî 
new
îî 
ClientAccess
îî 
(
îî  
client
îî  &
.
îî& '
CompanyName
îî' 2
,
îî2 3
user
îî4 8
.
îî8 9
Email
îî9 >
,
îî> ?
temporaryPassword
îî@ Q
)
îîQ R
;
îîR S
}
ïï 
internal
óó 
static
óó 
string
óó 
Slugify
óó "
(
óó" #
string
óó# )
value
óó* /
)
óó/ 0
{
òò 
var
ôô 

normalized
ôô 
=
ôô 
value
ôô 
.
ôô 
Trim
ôô #
(
ôô# $
)
ôô$ %
.
ôô% &
ToLowerInvariant
ôô& 6
(
ôô6 7
)
ôô7 8
.
ôô8 9
	Normalize
ôô9 B
(
ôôB C
System
ôôC I
.
ôôI J
Text
ôôJ N
.
ôôN O
NormalizationForm
ôôO `
.
ôô` a
FormD
ôôa f
)
ôôf g
;
ôôg h
var
öö 
chars
öö 
=
öö 

normalized
öö 
.
öö 
Where
öö $
(
öö$ %
c
öö% &
=>
öö' )
System
öö* 0
.
öö0 1
Globalization
öö1 >
.
öö> ?
CharUnicodeInfo
öö? N
.
ööN O 
GetUnicodeCategory
ööO a
(
ööa b
c
ööb c
)
ööc d
!=
ööe g
System
ööh n
.
öön o
Globalization
ööo |
.
öö| }
UnicodeCategoryöö} å
.ööå ç
NonSpacingMarkööç õ
)ööõ ú
.ööú ù
Selectööù £
(öö£ §
cöö§ •
=>öö¶ ®
charöö© ≠
.öö≠ Æ
IsLetterOrDigitööÆ Ω
(ööΩ æ
cööæ ø
)ööø ¿
?öö¡ ¬
cöö√ ƒ
:öö≈ ∆
$charöö«  
)öö  À
;ööÀ Ã
return
õõ 
System
õõ 
.
õõ 
Text
õõ 
.
õõ  
RegularExpressions
õõ -
.
õõ- .
Regex
õõ. 3
.
õõ3 4
Replace
õõ4 ;
(
õõ; <
new
õõ< ?
string
õõ@ F
(
õõF G
chars
õõG L
.
õõL M
ToArray
õõM T
(
õõT U
)
õõU V
)
õõV W
,
õõW X
$str
õõY `
,
õõ` a
$str
õõb e
)
õõe f
.
õõf g
Trim
õõg k
(
õõk l
$char
õõl o
)
õõo p
;
õõp q
}
úú 
[
ûû 
HttpGet
ûû 
(
ûû 
$str
ûû 
)
ûû 
]
ûû 
public
üü 

async
üü 
Task
üü 
<
üü 
ActionResult
üü "
>
üü" #
Products
üü$ ,
(
üü, -
CancellationToken
üü- >
ct
üü? A
)
üüA B
=>
üüC E
Ok
üüF H
(
üüH I
(
üüI J
await
üüJ O
db
üüP R
.
üüR S
Products
üüS [
.
üü[ \
OrderBy
üü\ c
(
üüc d
x
üüd e
=>
üüf h
x
üüi j
.
üüj k
Name
üük o
)
üüo p
.
üüp q
ToListAsync
üüq |
(
üü| }
ct
üü} 
)üü Ä
)üüÄ Å
.üüÅ Ç
SelectüüÇ à
(üüà â

ProductDtoüüâ ì
)üüì î
)üüî ï
;üüï ñ
[
°° 
HttpPost
°° 
(
°° 
$str
°° 
)
°° 
]
°° 
public
¢¢ 

async
¢¢ 
Task
¢¢ 
<
¢¢ 
ActionResult
¢¢ "
>
¢¢" #
CreateProduct
¢¢$ 1
(
¢¢1 2
ProductRequest
¢¢2 @
request
¢¢A H
,
¢¢H I
CancellationToken
¢¢J [
ct
¢¢\ ^
)
¢¢^ _
{
££ 
var
§§ 
error
§§ 
=
§§ 
ValidateProduct
§§ #
(
§§# $
request
§§$ +
)
§§+ ,
;
§§, -
if
§§. 0
(
§§1 2
error
§§2 7
is
§§8 :
not
§§; >
null
§§? C
)
§§C D
return
§§E K

BadRequest
§§L V
(
§§V W
new
§§W Z
{
§§[ \
message
§§] d
=
§§e f
error
§§g l
}
§§m n
)
§§n o
;
§§o p
var
•• 
product
•• 
=
•• 
	ToProduct
•• 
(
••  
request
••  '
)
••' (
;
••( )
db
••* ,
.
••, -
Products
••- 5
.
••5 6
Add
••6 9
(
••9 :
product
••: A
)
••A B
;
••B C
await
••D I(
EnsureProductCategoryAsync
••J d
(
••d e
product
••e l
.
••l m
Category
••m u
,
••u v
ct
••w y
)
••y z
;
••z {
await••| Å
db••Ç Ñ
.••Ñ Ö 
SaveChangesAsync••Ö ï
(••ï ñ
ct••ñ ò
)••ò ô
;••ô ö
return••õ °
Created••¢ ©
(••© ™
$"••™ ¨
$str••¨ ¿
{••¿ ¡
product••¡ »
.••» …
Id••… À
}••À Ã
"••Ã Õ
,••Õ Œ

ProductDto••œ Ÿ
(••Ÿ ⁄
product••⁄ ·
)••· ‚
)••‚ „
;••„ ‰
}
¶¶ 
[
®® 
	HttpPatch
®® 
(
®® 
$str
®® #
)
®®# $
]
®®$ %
public
©© 

async
©© 
Task
©© 
<
©© 
ActionResult
©© "
>
©©" #
UpdateProduct
©©$ 1
(
©©1 2
Guid
©©2 6
id
©©7 9
,
©©9 :!
ProductPatchRequest
©©; N
request
©©O V
,
©©V W
CancellationToken
©©X i
ct
©©j l
)
©©l m
{
™™ 
var
´´ 
product
´´ 
=
´´ 
await
´´ 
db
´´ 
.
´´ 
Products
´´ '
.
´´' (
	FindAsync
´´( 1
(
´´1 2
[
´´2 3
id
´´3 5
]
´´5 6
,
´´6 7
ct
´´8 :
)
´´: ;
;
´´; <
if
´´= ?
(
´´@ A
product
´´A H
is
´´I K
null
´´L P
)
´´P Q
return
´´R X
NotFound
´´Y a
(
´´a b
)
´´b c
;
´´c d
if
¨¨ 

(
¨¨ 
request
¨¨ 
.
¨¨ 
Type
¨¨ 
is
¨¨ 
ProductType
¨¨ '
type
¨¨( ,
)
¨¨, -
product
¨¨. 5
.
¨¨5 6
Type
¨¨6 :
=
¨¨; <
type
¨¨= A
;
¨¨A B
if
≠≠ 

(
≠≠ 
request
≠≠ 
.
≠≠ 
Name
≠≠ 
is
≠≠ 
not
≠≠ 
null
≠≠  $
)
≠≠$ %
product
≠≠& -
.
≠≠- .
Name
≠≠. 2
=
≠≠3 4
request
≠≠5 <
.
≠≠< =
Name
≠≠= A
.
≠≠A B
Trim
≠≠B F
(
≠≠F G
)
≠≠G H
;
≠≠H I
if
ÆÆ 

(
ÆÆ 
request
ÆÆ 
.
ÆÆ 
BillingCycle
ÆÆ  
is
ÆÆ! #
BillingCycle
ÆÆ$ 0
cycle
ÆÆ1 6
)
ÆÆ6 7
product
ÆÆ8 ?
.
ÆÆ? @
BillingCycle
ÆÆ@ L
=
ÆÆM N
cycle
ÆÆO T
;
ÆÆT U
if
ØØ 

(
ØØ 
request
ØØ 
.
ØØ 
	BasePrice
ØØ 
is
ØØ  
not
ØØ! $
null
ØØ% )
)
ØØ) *
product
ØØ+ 2
.
ØØ2 3
	BasePrice
ØØ3 <
=
ØØ= >
request
ØØ? F
.
ØØF G
	BasePrice
ØØG P
;
ØØP Q
if
∞∞ 

(
∞∞ 
request
∞∞ 
.
∞∞ 
Currency
∞∞ 
is
∞∞ 
not
∞∞  #
null
∞∞$ (
)
∞∞( )
product
∞∞* 1
.
∞∞1 2
Currency
∞∞2 :
=
∞∞; <
request
∞∞= D
.
∞∞D E
Currency
∞∞E M
.
∞∞M N
Trim
∞∞N R
(
∞∞R S
)
∞∞S T
.
∞∞T U
ToUpperInvariant
∞∞U e
(
∞∞e f
)
∞∞f g
;
∞∞g h
if
±± 

(
±± 
request
±± 
.
±± 
Description
±± 
is
±±  "
not
±±# &
null
±±' +
)
±±+ ,
product
±±- 4
.
±±4 5
Description
±±5 @
=
±±A B
EmptyToNull
±±C N
(
±±N O
request
±±O V
.
±±V W
Description
±±W b
)
±±b c
;
±±c d
if
≤≤ 

(
≤≤ 
request
≤≤ 
.
≤≤ 
IsActive
≤≤ 
is
≤≤ 
bool
≤≤  $
active
≤≤% +
)
≤≤+ ,
product
≤≤- 4
.
≤≤4 5
IsActive
≤≤5 =
=
≤≤> ?
active
≤≤@ F
;
≤≤F G
if
≥≥ 

(
≥≥ 
request
≥≥ 
.
≥≥ 
Category
≥≥ 
is
≥≥ 
not
≥≥  #
null
≥≥$ (
)
≥≥( )
product
≥≥* 1
.
≥≥1 2
Category
≥≥2 :
=
≥≥; <
EmptyToNull
≥≥= H
(
≥≥H I
request
≥≥I P
.
≥≥P Q
Category
≥≥Q Y
)
≥≥Y Z
;
≥≥Z [
if
¥¥ 

(
¥¥ 
request
¥¥ 
.
¥¥ 
Tags
¥¥ 
is
¥¥ 
not
¥¥ 
null
¥¥  $
)
¥¥$ %
product
¥¥& -
.
¥¥- .
Tags
¥¥. 2
=
¥¥3 4
NormalizeTags
¥¥5 B
(
¥¥B C
request
¥¥C J
.
¥¥J K
Tags
¥¥K O
)
¥¥O P
;
¥¥P Q
if
µµ 

(
µµ 
request
µµ 
.
µµ 
AllowsTickets
µµ !
is
µµ" $
bool
µµ% )
allowsTickets
µµ* 7
)
µµ7 8
product
µµ9 @
.
µµ@ A
AllowsTickets
µµA N
=
µµO P
allowsTickets
µµQ ^
;
µµ^ _
if
∂∂ 

(
∂∂ 
request
∂∂ 
.
∂∂ 
TaxDocumentType
∂∂ #
is
∂∂$ &
TaxDocumentType
∂∂' 6
taxType
∂∂7 >
)
∂∂> ?
product
∂∂@ G
.
∂∂G H
TaxDocumentType
∂∂H W
=
∂∂X Y
taxType
∂∂Z a
;
∂∂a b
if
∑∑ 

(
∑∑ 
string
∑∑ 
.
∑∑  
IsNullOrWhiteSpace
∑∑ %
(
∑∑% &
product
∑∑& -
.
∑∑- .
Name
∑∑. 2
)
∑∑2 3
||
∑∑4 6
string
∑∑7 =
.
∑∑= > 
IsNullOrWhiteSpace
∑∑> P
(
∑∑P Q
product
∑∑Q X
.
∑∑X Y
Currency
∑∑Y a
)
∑∑a b
)
∑∑b c
return
∑∑d j

BadRequest
∑∑k u
(
∑∑u v
new
∑∑v y
{
∑∑z {
message∑∑| É
=∑∑Ñ Ö
$str∑∑Ü ©
}∑∑™ ´
)∑∑´ ¨
;∑∑¨ ≠
await
∏∏ (
EnsureProductCategoryAsync
∏∏ (
(
∏∏( )
product
∏∏) 0
.
∏∏0 1
Category
∏∏1 9
,
∏∏9 :
ct
∏∏; =
)
∏∏= >
;
∏∏> ?
await
ππ 
db
ππ 
.
ππ 
SaveChangesAsync
ππ !
(
ππ! "
ct
ππ" $
)
ππ$ %
;
ππ% &
return
ππ' -
Ok
ππ. 0
(
ππ0 1

ProductDto
ππ1 ;
(
ππ; <
product
ππ< C
)
ππC D
)
ππD E
;
ππE F
}
∫∫ 
[
ºº 
HttpGet
ºº 
(
ºº 
$str
ºº '
)
ºº' (
]
ºº( )
public
ΩΩ 

IActionResult
ΩΩ 
ProductTemplate
ΩΩ (
(
ΩΩ( )
)
ΩΩ) *
=>
ΩΩ+ -
File
ΩΩ. 2
(
ΩΩ2 3
CreateWorkbook
ΩΩ3 A
(
ΩΩA B
new
ææ 
(
ææ 
$str
ææ 
,
ææ 
true
ææ 
,
ææ 
$str
ææ +
,
ææ+ ,
Enum
ææ- 1
.
ææ1 2
GetNames
ææ2 :
<
ææ: ;
ProductType
ææ; F
>
ææF G
(
ææG H
)
ææH I
)
ææI J
,
ææJ K
new
øø 
(
øø 
$str
øø 
,
øø 
true
øø 
,
øø 
$str
øø G
)
øøG H
,
øøH I
new
¿¿ 
(
¿¿ 
$str
¿¿ 
,
¿¿ 
true
¿¿  
,
¿¿  !
$str
¿¿" \
,
¿¿\ ]
[
¿¿^ _
$str
¿¿_ f
,
¿¿f g
$str
¿¿h q
,
¿¿q r
$str
¿¿s ~
,
¿¿~ 
$str¿¿Ä å
,¿¿å ç
$str¿¿é ô
,¿¿ô ö
$str¿¿õ ¢
]¿¿¢ £
)¿¿£ §
,¿¿§ •
new
¡¡ 
(
¡¡ 
$str
¡¡ 
,
¡¡ 
true
¡¡ 
,
¡¡ 
$str¡¡ ™
)¡¡™ ´
,¡¡´ ¨
new
¬¬ 
(
¬¬ 
$str
¬¬ 
,
¬¬ 
true
¬¬ 
,
¬¬ 
$str
¬¬ .
,
¬¬. /
[
¬¬0 1
$str
¬¬1 6
,
¬¬6 7
$str
¬¬8 =
,
¬¬= >
$str
¬¬? D
]
¬¬D E
)
¬¬E F
,
¬¬F G
new
√√ 
(
√√ 
$str
√√ 
,
√√ 
false
√√  
,
√√  !
$str
√√" /
)
√√/ 0
,
√√0 1
new
ƒƒ 
(
ƒƒ 
$str
ƒƒ 
,
ƒƒ 
false
ƒƒ 
,
ƒƒ 
$str
ƒƒ 5
,
ƒƒ5 6
[
ƒƒ7 8
$str
ƒƒ8 <
,
ƒƒ< =
$str
ƒƒ> B
]
ƒƒB C
)
ƒƒC D
,
ƒƒD E
new
≈≈ 
(
≈≈ 
$str
≈≈ 
,
≈≈ 
false
≈≈ $
,
≈≈$ %
$str
≈≈& f
,
≈≈f g
Enum
≈≈h l
.
≈≈l m
GetNames
≈≈m u
<
≈≈u v
TaxDocumentType≈≈v Ö
>≈≈Ö Ü
(≈≈Ü á
)≈≈á à
)≈≈à â
,≈≈â ä
new
∆∆ 
(
∆∆ 
$str
∆∆ 
,
∆∆ 
false
∆∆ 
,
∆∆ 
$str
∆∆ C
)
∆∆C D
,
∆∆D E
new
«« 
(
«« 
$str
«« 
,
«« 
false
«« 
,
«« 
$str
«« w
)
««w x
,
««x y
new
»» 
(
»» 
$str
»» 
,
»» 
false
»» "
,
»»" #
$str
»»$ r
,
»»r s
[
»»t u
$str
»»u y
,
»»y z
$str
»»{ 
]»» Ä
)»»Ä Å
)»»Å Ç
,»»Ç É
$str
…… K
,
……K L
$str
……M g
)
……g h
;
……h i
[
ÀÀ 
HttpPost
ÀÀ 
(
ÀÀ 
$str
ÀÀ 
)
ÀÀ  
]
ÀÀ  !
public
ÃÃ 

async
ÃÃ 
Task
ÃÃ 
<
ÃÃ 
ActionResult
ÃÃ "
>
ÃÃ" #
ImportProducts
ÃÃ$ 2
(
ÃÃ2 3
	IFormFile
ÃÃ3 <
file
ÃÃ= A
,
ÃÃA B
CancellationToken
ÃÃC T
ct
ÃÃU W
)
ÃÃW X
{
ÕÕ 
var
ŒŒ 
(
ŒŒ 
failure
ŒŒ 
,
ŒŒ 
created
ŒŒ 
,
ŒŒ 
errors
ŒŒ %
)
ŒŒ% &
=
ŒŒ' (
await
ŒŒ) .
Import
ŒŒ/ 5
(
ŒŒ5 6
file
ŒŒ6 :
,
ŒŒ: ;
$str
ŒŒ< G
,
ŒŒG H
async
ŒŒI N
(
ŒŒO P
row
ŒŒP S
,
ŒŒS T
	rowNumber
ŒŒU ^
,
ŒŒ^ _
errors
ŒŒ` f
)
ŒŒf g
=>
ŒŒh j
{
œœ 
var
–– 
error
–– 
=
–– 
ParseProductRow
–– #
(
––# $
row
––$ '
,
––' (
out
––) ,
var
––- 0
product
––1 8
)
––8 9
;
––9 :
if
—— 

(
—— 
error
—— 
is
—— 
not
—— 
null
—— 
)
—— 
{
——  
errors
——! '
.
——' (
Add
——( +
(
——+ ,
new
——, /
(
——/ 0
	rowNumber
——0 9
,
——9 :
error
——; @
)
——@ A
)
——A B
;
——B C
return
——D J
false
——K P
;
——P Q
}
——R S
db
““ 

.
““
 
Products
““ 
.
““ 
Add
““ 
(
““ 
product
““ 
!
““  
)
““  !
;
““! "
await
““# ((
EnsureProductCategoryAsync
““) C
(
““C D
product
““D K
!
““K L
.
““L M
Category
““M U
,
““U V
ct
““W Y
)
““Y Z
;
““Z [
return
““\ b
true
““c g
;
““g h
}
”” 	
,
””	 

ct
”” 
)
”” 
;
”” 
return
‘‘ 
failure
‘‘ 
??
‘‘ 
Ok
‘‘ 
(
‘‘ 
new
‘‘  
{
‘‘! "
created
‘‘# *
,
‘‘* +
skipped
‘‘, 3
=
‘‘4 5
errors
‘‘6 <
.
‘‘< =
Count
‘‘= B
,
‘‘B C
errors
‘‘D J
}
‘‘K L
)
‘‘L M
;
‘‘M N
}
’’ 
[
◊◊ 
HttpPost
◊◊ 
(
◊◊ 
$str
◊◊ 0
)
◊◊0 1
]
◊◊1 2
public
ÿÿ 

async
ÿÿ 
Task
ÿÿ 
<
ÿÿ 
ActionResult
ÿÿ "
>
ÿÿ" #
AssignProduct
ÿÿ$ 1
(
ÿÿ1 2
Guid
ÿÿ2 6
clientId
ÿÿ7 ?
,
ÿÿ? @"
AssignProductRequest
ÿÿA U
request
ÿÿV ]
,
ÿÿ] ^
CancellationToken
ÿÿ_ p
ct
ÿÿq s
)
ÿÿs t
{
ŸŸ 
if
⁄⁄ 

(
⁄⁄ 
!
⁄⁄ 
await
⁄⁄ 
db
⁄⁄ 
.
⁄⁄ 
Clients
⁄⁄ 
.
⁄⁄ 
AnyAsync
⁄⁄ &
(
⁄⁄& '
x
⁄⁄' (
=>
⁄⁄) +
x
⁄⁄, -
.
⁄⁄- .
Id
⁄⁄. 0
==
⁄⁄1 3
clientId
⁄⁄4 <
,
⁄⁄< =
ct
⁄⁄> @
)
⁄⁄@ A
||
⁄⁄B D
!
⁄⁄E F
await
⁄⁄F K
db
⁄⁄L N
.
⁄⁄N O
Projects
⁄⁄O W
.
⁄⁄W X
AnyAsync
⁄⁄X `
(
⁄⁄` a
x
⁄⁄a b
=>
⁄⁄c e
x
⁄⁄f g
.
⁄⁄g h
Id
⁄⁄h j
==
⁄⁄k m
request
⁄⁄n u
.
⁄⁄u v
	ProjectId
⁄⁄v 
&&⁄⁄Ä Ç
x⁄⁄É Ñ
.⁄⁄Ñ Ö
ClientId⁄⁄Ö ç
==⁄⁄é ê
clientId⁄⁄ë ô
,⁄⁄ô ö
ct⁄⁄õ ù
)⁄⁄ù û
)⁄⁄û ü
return⁄⁄† ¶
NotFound⁄⁄ß Ø
(⁄⁄Ø ∞
)⁄⁄∞ ±
;⁄⁄± ≤
var
€€ 
product
€€ 
=
€€ 
await
€€ 
db
€€ 
.
€€ 
Products
€€ '
.
€€' (
	FindAsync
€€( 1
(
€€1 2
[
€€2 3
request
€€3 :
.
€€: ;
	ProductId
€€; D
]
€€D E
,
€€E F
ct
€€G I
)
€€I J
;
€€J K
if
€€L N
(
€€O P
product
€€P W
is
€€X Z
null
€€[ _
)
€€_ `
return
€€a g
NotFound
€€h p
(
€€p q
)
€€q r
;
€€r s
if
‹‹ 

(
‹‹ 
request
‹‹ 
.
‹‹ 
BillingMode
‹‹ 
is
‹‹  "
not
‹‹# &
(
‹‹' (
$str
‹‹( 0
or
‹‹1 3
$str
‹‹4 <
)
‹‹< =
)
‹‹= >
return
‹‹? E

BadRequest
‹‹F P
(
‹‹P Q
new
‹‹Q T
{
‹‹U V
message
‹‹W ^
=
‹‹_ `
$str‹‹a Ä
}‹‹Å Ç
)‹‹Ç É
;‹‹É Ñ
if
›› 

(
›› 
request
›› 
.
›› 
BillingMode
›› 
==
››  "
$str
››# +
&&
››, .
await
››/ 4
db
››5 7
.
››7 8
PaymentSettings
››8 G
.
››G H
AnyAsync
››H P
(
››P Q
x
››Q R
=>
››S U
!
››V W
x
››W X
.
››X Y
PayPalEnabled
››Y f
,
››f g
ct
››h j
)
››j k
)
››k l
return
››m s

BadRequest
››t ~
(
››~ 
new›› Ç
{››É Ñ
message››Ö å
=››ç é
$str››è ‚
}››„ ‰
)››‰ Â
;››Â Ê
var
ﬁﬁ 
item
ﬁﬁ 
=
ﬁﬁ 
new
ﬁﬁ 
ClientProduct
ﬁﬁ $
{
ﬁﬁ% &
ClientId
ﬁﬁ' /
=
ﬁﬁ0 1
clientId
ﬁﬁ2 :
,
ﬁﬁ: ;
	ProjectId
ﬁﬁ< E
=
ﬁﬁF G
request
ﬁﬁH O
.
ﬁﬁO P
	ProjectId
ﬁﬁP Y
,
ﬁﬁY Z
	ProductId
ﬁﬁ[ d
=
ﬁﬁe f
product
ﬁﬁg n
.
ﬁﬁn o
Id
ﬁﬁo q
,
ﬁﬁq r
BillingCycle
ﬁﬁs 
=ﬁﬁÄ Å
requestﬁﬁÇ â
.ﬁﬁâ ä
BillingCycleﬁﬁä ñ
,ﬁﬁñ ó
IsManualBillingﬁﬁò ß
=ﬁﬁ® ©
requestﬁﬁ™ ±
.ﬁﬁ± ≤
BillingModeﬁﬁ≤ Ω
==ﬁﬁæ ¿
$strﬁﬁ¡ …
,ﬁﬁ…  
StatusﬁﬁÀ —
=ﬁﬁ“ ”
requestﬁﬁ‘ €
.ﬁﬁ€ ‹
BillingModeﬁﬁ‹ Á
==ﬁﬁË Í
$strﬁﬁÎ Û
?ﬁﬁÙ ı#
ClientProductStatusﬁﬁˆ â
.ﬁﬁâ ä
Activoﬁﬁä ê
:ﬁﬁë í#
ClientProductStatusﬁﬁì ¶
.ﬁﬁ¶ ß
	Pendienteﬁﬁß ∞
,ﬁﬁ∞ ±
Priceﬁﬁ≤ ∑
=ﬁﬁ∏ π
productﬁﬁ∫ ¡
.ﬁﬁ¡ ¬
	BasePriceﬁﬁ¬ À
isﬁﬁÃ Œ
nullﬁﬁœ ”
?ﬁﬁ‘ ’
requestﬁﬁ÷ ›
.ﬁﬁ› ﬁ
Priceﬁﬁﬁ „
:ﬁﬁ‰ Â
nullﬁﬁÊ Í
,ﬁﬁÍ Î

DomainNameﬁﬁÏ ˆ
=ﬁﬁ˜ ¯
EmptyToNullﬁﬁ˘ Ñ
(ﬁﬁÑ Ö
requestﬁﬁÖ å
.ﬁﬁå ç

DomainNameﬁﬁç ó
)ﬁﬁó ò
,ﬁﬁò ô"
PriceLabelOverrideﬁﬁö ¨
=ﬁﬁ≠ Æ
EmptyToNullﬁﬁØ ∫
(ﬁﬁ∫ ª
requestﬁﬁª ¬
.ﬁﬁ¬ √"
PriceLabelOverrideﬁﬁ√ ’
)ﬁﬁ’ ÷
,ﬁﬁ÷ ◊
RenewsAtﬁﬁÿ ‡
=ﬁﬁ· ‚
	ToUtcDateﬁﬁ„ Ï
(ﬁﬁÏ Ì
requestﬁﬁÌ Ù
.ﬁﬁÙ ı
RenewsAtﬁﬁı ˝
)ﬁﬁ˝ ˛
,ﬁﬁ˛ ˇ
NextChargeAtﬁﬁÄ å
=ﬁﬁç é
	ToUtcDateﬁﬁè ò
(ﬁﬁò ô
requestﬁﬁô †
.ﬁﬁ† °
NextChargeAtﬁﬁ° ≠
)ﬁﬁ≠ Æ
,ﬁﬁÆ Ø
Productﬁﬁ∞ ∑
=ﬁﬁ∏ π
productﬁﬁ∫ ¡
}ﬁﬁ¬ √
;ﬁﬁ√ ƒ
item
ﬂﬂ 
.
ﬂﬂ 
Status
ﬂﬂ 
=
ﬂﬂ  
RenewalReminderJob
ﬂﬂ (
.
ﬂﬂ( )
	StatusFor
ﬂﬂ) 2
(
ﬂﬂ2 3
item
ﬂﬂ3 7
.
ﬂﬂ7 8
Status
ﬂﬂ8 >
,
ﬂﬂ> ?
item
ﬂﬂ@ D
.
ﬂﬂD E
RenewsAt
ﬂﬂE M
,
ﬂﬂM N
DateTime
ﬂﬂO W
.
ﬂﬂW X
UtcNow
ﬂﬂX ^
)
ﬂﬂ^ _
;
ﬂﬂ_ `
if
‡‡ 

(
‡‡ 
item
‡‡ 
.
‡‡ 
SetDiscount
‡‡ 
(
‡‡ 
request
‡‡ $
.
‡‡$ %
Discount
‡‡% -
)
‡‡- .
is
‡‡/ 1
string
‡‡2 8
discountError
‡‡9 F
)
‡‡F G
return
‡‡H N

BadRequest
‡‡O Y
(
‡‡Y Z
new
‡‡Z ]
{
‡‡^ _
message
‡‡` g
=
‡‡h i
discountError
‡‡j w
}
‡‡x y
)
‡‡y z
;
‡‡z {
db
·· 

.
··
 
ClientProducts
·· 
.
·· 
Add
·· 
(
·· 
item
·· "
)
··" #
;
··# $
var
‚‚ 
igvRate
‚‚ 
=
‚‚ 
await
‚‚ 
db
‚‚ 
.
‚‚ 
IgvRateForAsync
‚‚ .
(
‚‚. /
clientId
‚‚/ 7
,
‚‚7 8
product
‚‚9 @
,
‚‚@ A
ct
‚‚B D
)
‚‚D E
;
‚‚E F
if
„„ 

(
„„ 
request
„„ 
.
„„ 
BillingMode
„„ 
==
„„  "
$str
„„# +
)
„„+ ,
{
‰‰ 	
try
ÂÂ 
{
ÊÊ 
var
ÁÁ 
checkout
ÁÁ 
=
ÁÁ 
await
ÁÁ $
checkoutService
ÁÁ% 4
.
ÁÁ4 5

StartAsync
ÁÁ5 ?
(
ÁÁ? @
item
ÁÁ@ D
,
ÁÁD E
product
ÁÁF M
,
ÁÁM N
Request
ÁÁO V
,
ÁÁV W
ct
ÁÁX Z
,
ÁÁZ [
igvRate
ÁÁ\ c
)
ÁÁc d
;
ÁÁd e
await
ËË 
db
ËË 
.
ËË 
SaveChangesAsync
ËË )
(
ËË) *
ct
ËË* ,
)
ËË, -
;
ËË- .
return
ÈÈ 
Created
ÈÈ 
(
ÈÈ 
$"
ÈÈ !
$str
ÈÈ! <
{
ÈÈ< =
item
ÈÈ= A
.
ÈÈA B
Id
ÈÈB D
}
ÈÈD E
"
ÈÈE F
,
ÈÈF G
new
ÈÈH K
{
ÈÈL M
clientProduct
ÈÈN [
=
ÈÈ\ ]
ClientProductDto
ÈÈ^ n
(
ÈÈn o
item
ÈÈo s
,
ÈÈs t
igvRate
ÈÈu |
)
ÈÈ| }
,
ÈÈ} ~
approvalUrlÈÈ ä
=ÈÈã å
checkoutÈÈç ï
.ÈÈï ñ
ApprovalUrlÈÈñ °
}ÈÈ¢ £
)ÈÈ£ §
;ÈÈ§ •
}
ÍÍ 
catch
ÎÎ 
(
ÎÎ '
InvalidOperationException
ÎÎ ,
ex
ÎÎ- /
)
ÎÎ/ 0
{
ÎÎ1 2
return
ÎÎ3 9

BadRequest
ÎÎ: D
(
ÎÎD E
new
ÎÎE H
{
ÎÎI J
message
ÎÎK R
=
ÎÎS T
ex
ÎÎU W
.
ÎÎW X
Message
ÎÎX _
}
ÎÎ` a
)
ÎÎa b
;
ÎÎb c
}
ÎÎd e
}
ÏÏ 	
await
ÌÌ 
db
ÌÌ 
.
ÌÌ 
SaveChangesAsync
ÌÌ !
(
ÌÌ! "
ct
ÌÌ" $
)
ÌÌ$ %
;
ÌÌ% &
return
ÌÌ' -
Created
ÌÌ. 5
(
ÌÌ5 6
$"
ÌÌ6 8
$str
ÌÌ8 S
{
ÌÌS T
item
ÌÌT X
.
ÌÌX Y
Id
ÌÌY [
}
ÌÌ[ \
"
ÌÌ\ ]
,
ÌÌ] ^
new
ÌÌ_ b
{
ÌÌc d
clientProduct
ÌÌe r
=
ÌÌs t
ClientProductDtoÌÌu Ö
(ÌÌÖ Ü
itemÌÌÜ ä
,ÌÌä ã
igvRateÌÌå ì
)ÌÌì î
,ÌÌî ï
approvalUrlÌÌñ °
=ÌÌ¢ £
(ÌÌ§ •
stringÌÌ• ´
?ÌÌ´ ¨
)ÌÌ¨ ≠
nullÌÌ≠ ±
}ÌÌ≤ ≥
)ÌÌ≥ ¥
;ÌÌ¥ µ
}
ÓÓ 
[
ıı 
HttpPost
ıı 
(
ıı 
$str
ıı 2
)
ıı2 3
]
ıı3 4
public
ˆˆ 

async
ˆˆ 
Task
ˆˆ 
<
ˆˆ 
ActionResult
ˆˆ "
>
ˆˆ" #%
RegisterTransferPayment
ˆˆ$ ;
(
ˆˆ; <
Guid
ˆˆ< @
id
ˆˆA C
,
ˆˆC D$
TransferPaymentRequest
ˆˆE [
request
ˆˆ\ c
,
ˆˆc d
[
ˆˆe f
FromServices
ˆˆf r
]
ˆˆr s#
PayPalPaymentServiceˆˆt à
paymentsˆˆâ ë
,ˆˆë í!
CancellationTokenˆˆì §
ctˆˆ• ß
)ˆˆß ®
{
˜˜ 
var
¯¯ 
item
¯¯ 
=
¯¯ 
await
¯¯ 
db
¯¯ 
.
¯¯ 
ClientProducts
¯¯ *
.
¯¯* +
Include
¯¯+ 2
(
¯¯2 3
x
¯¯3 4
=>
¯¯5 7
x
¯¯8 9
.
¯¯9 :
Product
¯¯: A
)
¯¯A B
.
¯¯B C
Include
¯¯C J
(
¯¯J K
x
¯¯K L
=>
¯¯M O
x
¯¯P Q
.
¯¯Q R
Project
¯¯R Y
)
¯¯Y Z
.
¯¯Z ["
SingleOrDefaultAsync
¯¯[ o
(
¯¯o p
x
¯¯p q
=>
¯¯r t
x
¯¯u v
.
¯¯v w
Id
¯¯w y
==
¯¯z |
id
¯¯} 
,¯¯ Ä
ct¯¯Å É
)¯¯É Ñ
;¯¯Ñ Ö
if¯¯Ü à
(¯¯â ä
item¯¯ä é
is¯¯è ë
null¯¯í ñ
)¯¯ñ ó
return¯¯ò û
NotFound¯¯ü ß
(¯¯ß ®
)¯¯® ©
;¯¯© ™
if
˘˘ 

(
˘˘ 
!
˘˘ 
item
˘˘ 
.
˘˘ 
IsManualBilling
˘˘ !
)
˘˘! "
return
˘˘# )

BadRequest
˘˘* 4
(
˘˘4 5
new
˘˘5 8
{
˘˘9 :
message
˘˘; B
=
˘˘C D
$str˘˘E á
}˘˘à â
)˘˘â ä
;˘˘ä ã
if
˙˙ 

(
˙˙ 
item
˙˙ 
.
˙˙ 
ValidateYears
˙˙ 
(
˙˙ 
request
˙˙ &
.
˙˙& '
Years
˙˙' ,
)
˙˙, -
is
˙˙. 0
string
˙˙1 7

yearsError
˙˙8 B
)
˙˙B C
return
˙˙D J

BadRequest
˙˙K U
(
˙˙U V
new
˙˙V Y
{
˙˙Z [
message
˙˙\ c
=
˙˙d e

yearsError
˙˙f p
}
˙˙q r
)
˙˙r s
;
˙˙s t
var
˚˚ 
igvRate
˚˚ 
=
˚˚ 
item
˚˚ 
.
˚˚ 
Product
˚˚ "
is
˚˚# %
null
˚˚& *
?
˚˚+ ,
$num
˚˚- /
:
˚˚0 1
await
˚˚2 7
db
˚˚8 :
.
˚˚: ;
IgvRateForAsync
˚˚; J
(
˚˚J K
item
˚˚K O
.
˚˚O P
ClientId
˚˚P X
,
˚˚X Y
item
˚˚Z ^
.
˚˚^ _
Product
˚˚_ f
,
˚˚f g
ct
˚˚h j
)
˚˚j k
;
˚˚k l
var
¸¸ 
amount
¸¸ 
=
¸¸ 
request
¸¸ 
.
¸¸ 
Amount
¸¸ #
??
¸¸$ &
item
¸¸' +
.
¸¸+ ,
ChargeTotal
¸¸, 7
(
¸¸7 8
igvRate
¸¸8 ?
,
¸¸? @
request
¸¸A H
.
¸¸H I
Years
¸¸I N
)
¸¸N O
;
¸¸O P
if
˝˝ 

(
˝˝ 
amount
˝˝ 
is
˝˝ 
not
˝˝ 
decimal
˝˝ !
value
˝˝" '
||
˝˝( *
value
˝˝+ 0
<=
˝˝1 3
$num
˝˝4 5
)
˝˝5 6
return
˝˝7 =

BadRequest
˝˝> H
(
˝˝H I
new
˝˝I L
{
˝˝M N
message
˝˝O V
=
˝˝W X
$str
˝˝Y u
}
˝˝v w
)
˝˝w x
;
˝˝x y
var
˛˛ 
	reference
˛˛ 
=
˛˛ 
request
˛˛ 
.
˛˛  
	Reference
˛˛  )
?
˛˛) *
.
˛˛* +
Trim
˛˛+ /
(
˛˛/ 0
)
˛˛0 1
;
˛˛1 2
var
ˇˇ 
key
ˇˇ 
=
ˇˇ 
string
ˇˇ 
.
ˇˇ  
IsNullOrWhiteSpace
ˇˇ +
(
ˇˇ+ ,
	reference
ˇˇ, 5
)
ˇˇ5 6
?
ˇˇ7 8
$"
ˇˇ9 ;
$str
ˇˇ; ?
{
ˇˇ? @
Guid
ˇˇ@ D
.
ˇˇD E
NewGuid
ˇˇE L
(
ˇˇL M
)
ˇˇM N
:
ˇˇN O
$str
ˇˇO P
}
ˇˇP Q
"
ˇˇQ R
:
ˇˇS T
$"
ˇˇU W
$str
ˇˇW [
{
ˇˇ[ \
	reference
ˇˇ\ e
}
ˇˇe f
"
ˇˇf g
;
ˇˇg h
if
ÄÄ 

(
ÄÄ 
key
ÄÄ 
.
ÄÄ 
Length
ÄÄ 
>
ÄÄ 
$num
ÄÄ 
)
ÄÄ 
return
ÄÄ $

BadRequest
ÄÄ% /
(
ÄÄ/ 0
new
ÄÄ0 3
{
ÄÄ4 5
message
ÄÄ6 =
=
ÄÄ> ?
$str
ÄÄ@ h
}
ÄÄi j
)
ÄÄj k
;
ÄÄk l
var
ÅÅ 
paidAt
ÅÅ 
=
ÅÅ 
	ToUtcDate
ÅÅ 
(
ÅÅ 
request
ÅÅ &
.
ÅÅ& '
PaidAt
ÅÅ' -
)
ÅÅ- .
;
ÅÅ. /
if
ÇÇ 

(
ÇÇ 
paidAt
ÇÇ 
>
ÇÇ 
DateTime
ÇÇ 
.
ÇÇ 
UtcNow
ÇÇ $
.
ÇÇ$ %
AddDays
ÇÇ% ,
(
ÇÇ, -
$num
ÇÇ- .
)
ÇÇ. /
)
ÇÇ/ 0
return
ÇÇ1 7

BadRequest
ÇÇ8 B
(
ÇÇB C
new
ÇÇC F
{
ÇÇG H
message
ÇÇI P
=
ÇÇQ R
$str
ÇÇS z
}
ÇÇ{ |
)
ÇÇ| }
;
ÇÇ} ~
if
ÉÉ 

(
ÉÉ 
!
ÉÉ 
await
ÉÉ 
payments
ÉÉ 
.
ÉÉ 
ApplyPaymentAsync
ÉÉ -
(
ÉÉ- .
item
ÉÉ. 2
,
ÉÉ2 3
key
ÉÉ4 7
,
ÉÉ7 8
value
ÉÉ9 >
,
ÉÉ> ?
item
ÉÉ@ D
.
ÉÉD E
Product
ÉÉE L
?
ÉÉL M
.
ÉÉM N
Currency
ÉÉN V
,
ÉÉV W
ct
ÉÉX Z
,
ÉÉZ [
new
ÉÉ\ _
(
ÉÉ_ `
PaymentMethods
ÉÉ` n
.
ÉÉn o
Transferencia
ÉÉo |
,
ÉÉ| }
paidAtÉÉ~ Ñ
,ÉÉÑ Ö
requestÉÉÜ ç
.ÉÉç é
YearsÉÉé ì
)ÉÉì î
)ÉÉî ï
)ÉÉï ñ
returnÉÉó ù
ConflictÉÉû ¶
(ÉÉ¶ ß
newÉÉß ™
{ÉÉ´ ¨
messageÉÉ≠ ¥
=ÉÉµ ∂
$strÉÉ∑ 
}ÉÉÒ Ú
)ÉÉÚ Û
;ÉÉÛ Ù
item
ÖÖ 
.
ÖÖ 
Status
ÖÖ 
=
ÖÖ  
RenewalReminderJob
ÖÖ (
.
ÖÖ( )
	StatusFor
ÖÖ) 2
(
ÖÖ2 3
item
ÖÖ3 7
.
ÖÖ7 8
Status
ÖÖ8 >
,
ÖÖ> ?
item
ÖÖ@ D
.
ÖÖD E
RenewsAt
ÖÖE M
,
ÖÖM N
DateTime
ÖÖO W
.
ÖÖW X
UtcNow
ÖÖX ^
)
ÖÖ^ _
;
ÖÖ_ `
await
ÖÖa f
db
ÖÖg i
.
ÖÖi j
SaveChangesAsync
ÖÖj z
(
ÖÖz {
ct
ÖÖ{ }
)
ÖÖ} ~
;
ÖÖ~ 
return
ÜÜ 
Ok
ÜÜ 
(
ÜÜ 
ClientProductDto
ÜÜ "
(
ÜÜ" #
item
ÜÜ# '
,
ÜÜ' (
igvRate
ÜÜ) 0
)
ÜÜ0 1
)
ÜÜ1 2
;
ÜÜ2 3
}
áá 
[
ââ 
	HttpPatch
ââ 
(
ââ 
$str
ââ *
)
ââ* +
]
ââ+ ,
public
ää 

async
ää 
Task
ää 
<
ää 
ActionResult
ää "
>
ää" #!
UpdateClientProduct
ää$ 7
(
ää7 8
Guid
ää8 <
id
ää= ?
,
ää? @'
ClientProductPatchRequest
ääA Z
request
ää[ b
,
ääb c
CancellationToken
ääd u
ct
ääv x
)
ääx y
{
ãã 
var
åå 
item
åå 
=
åå 
await
åå 
db
åå 
.
åå 
ClientProducts
åå *
.
åå* +
Include
åå+ 2
(
åå2 3
x
åå3 4
=>
åå5 7
x
åå8 9
.
åå9 :
Product
åå: A
)
ååA B
.
ååB C
Include
ååC J
(
ååJ K
x
ååK L
=>
ååM O
x
ååP Q
.
ååQ R
Project
ååR Y
)
ååY Z
.
ååZ ["
SingleOrDefaultAsync
åå[ o
(
ååo p
x
ååp q
=>
åår t
x
ååu v
.
ååv w
Id
ååw y
==
ååz |
id
åå} 
,åå Ä
ctååÅ É
)ååÉ Ñ
;ååÑ Ö
ifååÜ à
(ååâ ä
itemååä é
isååè ë
nullååí ñ
)ååñ ó
returnååò û
NotFoundååü ß
(ååß ®
)åå® ©
;åå© ™
if
çç 

(
çç 
request
çç 
.
çç 
Price
çç 
is
çç 
not
çç  
null
çç! %
)
çç% &
item
çç' +
.
çç+ ,
Price
çç, 1
=
çç2 3
request
çç4 ;
.
çç; <
Price
çç< A
;
ççA B
if
éé 

(
éé 
request
éé 
.
éé 
Status
éé 
is
éé !
ClientProductStatus
éé 1
status
éé2 8
)
éé8 9
item
éé: >
.
éé> ?
Status
éé? E
=
ééF G
status
ééH N
;
ééN O
if
èè 

(
èè 
request
èè 
.
èè 
BillingCycle
èè  
is
èè! #
BillingCycle
èè$ 0
cycle
èè1 6
)
èè6 7
item
èè8 <
.
èè< =
BillingCycle
èè= I
=
èèJ K
cycle
èèL Q
;
èèQ R
if
êê 

(
êê 
request
êê 
.
êê 

DomainName
êê 
is
êê !
not
êê" %
null
êê& *
)
êê* +
item
êê, 0
.
êê0 1

DomainName
êê1 ;
=
êê< =
EmptyToNull
êê> I
(
êêI J
request
êêJ Q
.
êêQ R

DomainName
êêR \
)
êê\ ]
;
êê] ^
if
ëë 

(
ëë 
request
ëë 
.
ëë  
PriceLabelOverride
ëë &
is
ëë' )
not
ëë* -
null
ëë. 2
)
ëë2 3
item
ëë4 8
.
ëë8 9 
PriceLabelOverride
ëë9 K
=
ëëL M
EmptyToNull
ëëN Y
(
ëëY Z
request
ëëZ a
.
ëëa b 
PriceLabelOverride
ëëb t
)
ëët u
;
ëëu v
if
íí 

(
íí 
request
íí 
.
íí 
IsManualBilling
íí #
is
íí$ &
bool
íí' +
manual
íí, 2
)
íí2 3
item
íí4 8
.
íí8 9
IsManualBilling
íí9 H
=
ííI J
manual
ííK Q
;
ííQ R
if
ìì 

(
ìì 
request
ìì 
.
ìì 
Discount
ìì 
is
ìì 
not
ìì  #
null
ìì$ (
&&
ìì) +
item
ìì, 0
.
ìì0 1
SetDiscount
ìì1 <
(
ìì< =
request
ìì= D
.
ììD E
Discount
ììE M
)
ììM N
is
ììO Q
string
ììR X
discountError
ììY f
)
ììf g
return
ììh n

BadRequest
ììo y
(
ììy z
new
ììz }
{
ìì~ 
messageììÄ á
=ììà â
discountErrorììä ó
}ììò ô
)ììô ö
;ììö õ
if
ïï 

(
ïï 
request
ïï 
.
ïï 
	ProjectId
ïï 
is
ïï  
Guid
ïï! %
	projectId
ïï& /
&&
ïï0 2
	projectId
ïï3 <
!=
ïï= ?
item
ïï@ D
.
ïïD E
	ProjectId
ïïE N
)
ïïN O
{
ññ 	
var
óó 
project
óó 
=
óó 
await
óó 
db
óó  "
.
óó" #
Projects
óó# +
.
óó+ ,"
SingleOrDefaultAsync
óó, @
(
óó@ A
x
óóA B
=>
óóC E
x
óóF G
.
óóG H
Id
óóH J
==
óóK M
	projectId
óóN W
&&
óóX Z
x
óó[ \
.
óó\ ]
ClientId
óó] e
==
óóf h
item
óói m
.
óóm n
ClientId
óón v
,
óóv w
ct
óóx z
)
óóz {
;
óó{ |
if
òò 
(
òò 
project
òò 
is
òò 
null
òò 
)
òò  
return
òò! '

BadRequest
òò( 2
(
òò2 3
new
òò3 6
{
òò7 8
message
òò9 @
=
òòA B
$str
òòC m
}
òòn o
)
òòo p
;
òòp q
(
ôô 
item
ôô 
.
ôô 
	ProjectId
ôô 
,
ôô 
item
ôô !
.
ôô! "
Project
ôô" )
)
ôô) *
=
ôô+ ,
(
ôô- .
project
ôô. 5
.
ôô5 6
Id
ôô6 8
,
ôô8 9
project
ôô: A
)
ôôA B
;
ôôB C
}
öö 	
await
õõ 
db
õõ 
.
õõ 
SaveChangesAsync
õõ !
(
õõ! "
ct
õõ" $
)
õõ$ %
;
õõ% &
return
õõ' -
Ok
õõ. 0
(
õõ0 1
await
õõ1 6#
ClientProductDtoAsync
õõ7 L
(
õõL M
item
õõM Q
,
õõQ R
ct
õõS U
)
õõU V
)
õõV W
;
õõW X
}
úú 
[
¢¢ 

HttpDelete
¢¢ 
(
¢¢ 
$str
¢¢ +
)
¢¢+ ,
]
¢¢, -
public
££ 

async
££ 
Task
££ 
<
££ 
ActionResult
££ "
>
££" #!
DeleteClientProduct
££$ 7
(
££7 8
Guid
££8 <
id
££= ?
,
££? @
CancellationToken
££A R
ct
££S U
)
££U V
{
§§ 
var
•• 
item
•• 
=
•• 
await
•• 
db
•• 
.
•• 
ClientProducts
•• *
.
••* +
Include
••+ 2
(
••2 3
x
••3 4
=>
••5 7
x
••8 9
.
••9 :
Product
••: A
)
••A B
.
••B C"
SingleOrDefaultAsync
••C W
(
••W X
x
••X Y
=>
••Z \
x
••] ^
.
••^ _
Id
••_ a
==
••b d
id
••e g
,
••g h
ct
••i k
)
••k l
;
••l m
if
••n p
(
••q r
item
••r v
is
••w y
null
••z ~
)
••~ 
return••Ä Ü
NotFound••á è
(••è ê
)••ê ë
;••ë í
var
¶¶ 
payments
¶¶ 
=
¶¶ 
await
¶¶ 
db
¶¶ 
.
¶¶  !
PaymentTransactions
¶¶  3
.
¶¶3 4

CountAsync
¶¶4 >
(
¶¶> ?
x
¶¶? @
=>
¶¶A C
x
¶¶D E
.
¶¶E F
ClientProductId
¶¶F U
==
¶¶V X
id
¶¶Y [
,
¶¶[ \
ct
¶¶] _
)
¶¶_ `
;
¶¶` a
if
ßß 

(
ßß 
payments
ßß 
==
ßß 
$num
ßß 
)
ßß 
payments
ßß #
=
ßß$ %
await
ßß& +
db
ßß, .
.
ßß. /
TaxDocumentLines
ßß/ ?
.
ßß? @

CountAsync
ßß@ J
(
ßßJ K
x
ßßK L
=>
ßßM O
x
ßßP Q
.
ßßQ R
ClientProductId
ßßR a
==
ßßb d
id
ßße g
,
ßßg h
ct
ßßi k
)
ßßk l
;
ßßl m
if
®® 

(
®® 
payments
®® 
>
®® 
$num
®® 
)
®® 
return
®®  
Conflict
®®! )
(
®®) *
new
®®* -
{
®®. /
message
®®0 7
=
®®8 9
$"
®®: <
$str
®®< =
{
®®= >
item
®®> B
.
®®B C
Product
®®C J
?
®®J K
.
®®K L
Name
®®L P
}
®®P Q
$str
®®Q Y
{
®®Y Z
Count
®®Z _
(
®®_ `
payments
®®` h
,
®®h i
$str
®®j {
,
®®{ |
$str®®} ê
)®®ê ë
}®®ë í
$str®®í ˘
"®®˘ ˙
}®®˚ ¸
)®®¸ ˝
;®®˝ ˛
if
©© 

(
©© 
!
©© 
string
©© 
.
©©  
IsNullOrWhiteSpace
©© &
(
©©& '
item
©©' +
.
©©+ ,"
PayPalSubscriptionId
©©, @
)
©©@ A
&&
©©B D
item
©©E I
.
©©I J
Status
©©J P
!=
©©Q S!
ClientProductStatus
©©T g
.
©©g h
	Cancelado
©©h q
)
©©q r
return
©©s y
Conflict©©z Ç
(©©Ç É
new©©É Ü
{©©á à
message©©â ê
=©©ë í
$str©©ì ı
}©©ˆ ˜
)©©˜ ¯
;©©¯ ˘
await
´´ 
db
´´ 
.
´´ 
Tickets
´´ 
.
´´ 
Where
´´ 
(
´´ 
x
´´  
=>
´´! #
x
´´$ %
.
´´% &
ClientProductId
´´& 5
==
´´6 8
id
´´9 ;
)
´´; <
.
´´< =
ForEachAsync
´´= I
(
´´I J
x
´´J K
=>
´´L N
x
´´O P
.
´´P Q
ClientProductId
´´Q `
=
´´a b
null
´´c g
,
´´g h
ct
´´i k
)
´´k l
;
´´l m
db
¨¨ 

.
¨¨
 
TransferReports
¨¨ 
.
¨¨ 
RemoveRange
¨¨ &
(
¨¨& '
await
¨¨' ,
db
¨¨- /
.
¨¨/ 0
TransferReports
¨¨0 ?
.
¨¨? @
Where
¨¨@ E
(
¨¨E F
x
¨¨F G
=>
¨¨H J
x
¨¨K L
.
¨¨L M
ClientProductId
¨¨M \
==
¨¨] _
id
¨¨` b
)
¨¨b c
.
¨¨c d
ToListAsync
¨¨d o
(
¨¨o p
ct
¨¨p r
)
¨¨r s
)
¨¨s t
;
¨¨t u
db
≠≠ 

.
≠≠
 
ClientProducts
≠≠ 
.
≠≠ 
Remove
≠≠  
(
≠≠  !
item
≠≠! %
)
≠≠% &
;
≠≠& '
await
ÆÆ 
db
ÆÆ 
.
ÆÆ 
SaveChangesAsync
ÆÆ !
(
ÆÆ! "
ct
ÆÆ" $
)
ÆÆ$ %
;
ÆÆ% &
return
ÆÆ' -
	NoContent
ÆÆ. 7
(
ÆÆ7 8
)
ÆÆ8 9
;
ÆÆ9 :
}
ØØ 
[
∂∂ 
HttpPut
∂∂ 
(
∂∂ 
$str
∂∂ .
)
∂∂. /
]
∂∂/ 0
public
∑∑ 

async
∑∑ 
Task
∑∑ 
<
∑∑ 
ActionResult
∑∑ "
>
∑∑" #&
UpdateClientProductDates
∑∑$ <
(
∑∑< =
Guid
∑∑= A
id
∑∑B D
,
∑∑D E'
ClientProductDatesRequest
∑∑F _
request
∑∑` g
,
∑∑g h
CancellationToken
∑∑i z
ct
∑∑{ }
)
∑∑} ~
{
∏∏ 
var
ππ 
item
ππ 
=
ππ 
await
ππ 
db
ππ 
.
ππ 
ClientProducts
ππ *
.
ππ* +
Include
ππ+ 2
(
ππ2 3
x
ππ3 4
=>
ππ5 7
x
ππ8 9
.
ππ9 :
Product
ππ: A
)
ππA B
.
ππB C
Include
ππC J
(
ππJ K
x
ππK L
=>
ππM O
x
ππP Q
.
ππQ R
Project
ππR Y
)
ππY Z
.
ππZ ["
SingleOrDefaultAsync
ππ[ o
(
ππo p
x
ππp q
=>
ππr t
x
ππu v
.
ππv w
Id
ππw y
==
ππz |
id
ππ} 
,ππ Ä
ctππÅ É
)ππÉ Ñ
;ππÑ Ö
ifππÜ à
(ππâ ä
itemππä é
isππè ë
nullππí ñ
)ππñ ó
returnππò û
NotFoundππü ß
(ππß ®
)ππ® ©
;ππ© ™
item
∫∫ 
.
∫∫ 
RenewsAt
∫∫ 
=
∫∫ 
	ToUtcDate
∫∫ !
(
∫∫! "
request
∫∫" )
.
∫∫) *
RenewsAt
∫∫* 2
)
∫∫2 3
;
∫∫3 4
item
∫∫5 9
.
∫∫9 :
NextChargeAt
∫∫: F
=
∫∫G H
	ToUtcDate
∫∫I R
(
∫∫R S
request
∫∫S Z
.
∫∫Z [
NextChargeAt
∫∫[ g
)
∫∫g h
;
∫∫h i
item
ªª 
.
ªª 
Status
ªª 
=
ªª  
RenewalReminderJob
ªª (
.
ªª( )
	StatusFor
ªª) 2
(
ªª2 3
item
ªª3 7
.
ªª7 8
Status
ªª8 >
,
ªª> ?
item
ªª@ D
.
ªªD E
RenewsAt
ªªE M
,
ªªM N
DateTime
ªªO W
.
ªªW X
UtcNow
ªªX ^
)
ªª^ _
;
ªª_ `
item
ºº 
.
ºº 
OnDatesChanged
ºº 
(
ºº 
)
ºº 
;
ºº 
await
ΩΩ 
db
ΩΩ 
.
ΩΩ 
SaveChangesAsync
ΩΩ !
(
ΩΩ! "
ct
ΩΩ" $
)
ΩΩ$ %
;
ΩΩ% &
return
ΩΩ' -
Ok
ΩΩ. 0
(
ΩΩ0 1
await
ΩΩ1 6#
ClientProductDtoAsync
ΩΩ7 L
(
ΩΩL M
item
ΩΩM Q
,
ΩΩQ R
ct
ΩΩS U
)
ΩΩU V
)
ΩΩV W
;
ΩΩW X
}
ææ 
internal
¡¡ 
static
¡¡ 
DateTime
¡¡ 
?
¡¡ 
	ToUtcDate
¡¡ '
(
¡¡' (
DateOnly
¡¡( 0
?
¡¡0 1
date
¡¡2 6
)
¡¡6 7
=>
¡¡8 :
date
¡¡; ?
?
¡¡? @
.
¡¡@ A

ToDateTime
¡¡A K
(
¡¡K L
new
¡¡L O
TimeOnly
¡¡P X
(
¡¡X Y
$num
¡¡Y [
,
¡¡[ \
$num
¡¡] ^
)
¡¡^ _
,
¡¡_ `
DateTimeKind
¡¡a m
.
¡¡m n
Utc
¡¡n q
)
¡¡q r
;
¡¡r s
private
√√ 
async
√√ 
Task
√√ 
<
√√ 
(
√√ 
ActionResult
√√ $
?
√√$ %
Failure
√√& -
,
√√- .
int
√√/ 2
Created
√√3 :
,
√√: ;
List
√√< @
<
√√@ A
ImportError
√√A L
>
√√L M
Errors
√√N T
)
√√T U
>
√√U V
Import
√√W ]
(
√√] ^
	IFormFile
√√^ g
file
√√h l
,
√√l m
string
√√n t
kind
√√u y
,
√√y z
Func
√√{ 
<√√ Ä
IXLRow√√Ä Ü
,√√Ü á
int√√à ã
,√√ã å
List√√ç ë
<√√ë í
ImportError√√í ù
>√√ù û
,√√û ü
Task√√† §
<√√§ •
bool√√• ©
>√√© ™
>√√™ ´
addRow√√¨ ≤
,√√≤ ≥!
CancellationToken√√¥ ≈
ct√√∆ »
)√√» …
{
ƒƒ 
var
≈≈ 
errors
≈≈ 
=
≈≈ 
new
≈≈ 
List
≈≈ 
<
≈≈ 
ImportError
≈≈ )
>
≈≈) *
(
≈≈* +
)
≈≈+ ,
;
≈≈, -
var
≈≈. 1
created
≈≈2 9
=
≈≈: ;
$num
≈≈< =
;
≈≈= >
if
∆∆ 

(
∆∆ 
file
∆∆ 
is
∆∆ 
null
∆∆ 
||
∆∆ 
file
∆∆  
.
∆∆  !
Length
∆∆! '
==
∆∆( *
$num
∆∆+ ,
)
∆∆, -
return
∆∆. 4
(
∆∆5 6

BadRequest
∆∆6 @
(
∆∆@ A
new
∆∆A D
{
∆∆E F
message
∆∆G N
=
∆∆O P
$str
∆∆Q o
}
∆∆p q
)
∆∆q r
,
∆∆r s
$num
∆∆t u
,
∆∆u v
errors
∆∆w }
)
∆∆} ~
;
∆∆~ 
try
«« 
{
«« 
using
«« 
var
«« 
stream
«« 
=
««  
file
««! %
.
««% &
OpenReadStream
««& 4
(
««4 5
)
««5 6
;
««6 7
using
««8 =
var
««> A
book
««B F
=
««G H
new
««I L

XLWorkbook
««M W
(
««W X
stream
««X ^
)
««^ _
;
««_ `
var
««a d
sheet
««e j
=
««k l
book
««m q
.
««q r

Worksheets
««r |
.
««| }
First««} Ç
(««Ç É
)««É Ñ
;««Ñ Ö
foreach««Ü ç
(««é è
var««è í
row««ì ñ
in««ó ô
sheet««ö ü
.««ü †
RowsUsed««† ®
(««® ©
)««© ™
.««™ ´
Skip««´ Ø
(««Ø ∞
$num««∞ ±
)««± ≤
)««≤ ≥
if««¥ ∂
(««∑ ∏
await««∏ Ω
addRow««æ ƒ
(««ƒ ≈
row««≈ »
,««» …
row««  Õ
.««Õ Œ
	RowNumber««Œ ◊
(««◊ ÿ
)««ÿ Ÿ
,««Ÿ ⁄
errors««€ ·
)««· ‚
)««‚ „
{««‰ Â
await««Ê Î
db««Ï Ó
.««Ó Ô 
SaveChangesAsync««Ô ˇ
(««ˇ Ä
ct««Ä Ç
)««Ç É
;««É Ñ
created««Ö å
++««å é
;««é è
}««ê ë
}««í ì
catch
»» 
(
»» 
	Exception
»» 
ex
»» 
)
»» 
when
»» !
(
»»" #
ex
»»# %
is
»»& (
not
»») ,
DbUpdateException
»»- >
)
»»> ?
{
»»@ A
return
»»B H
(
»»I J

BadRequest
»»J T
(
»»T U
new
»»U X
{
»»Y Z
message
»»[ b
=
»»c d
$"
»»e g
$str»»g á
{»»á à
kind»»à å
}»»å ç
$str»»ç é
"»»é è
}»»ê ë
)»»ë í
,»»í ì
$num»»î ï
,»»ï ñ
errors»»ó ù
)»»ù û
;»»û ü
}»»† °
return
…… 
(
…… 
null
…… 
,
…… 
created
…… 
,
…… 
errors
…… %
)
……% &
;
……& '
}
   
private
ÀÀ 
static
ÀÀ 
string
ÀÀ 
Cell
ÀÀ 
(
ÀÀ 
IXLRow
ÀÀ %
row
ÀÀ& )
,
ÀÀ) *
int
ÀÀ+ .
col
ÀÀ/ 2
)
ÀÀ2 3
=>
ÀÀ4 6
row
ÀÀ7 :
.
ÀÀ: ;
Cell
ÀÀ; ?
(
ÀÀ? @
col
ÀÀ@ C
)
ÀÀC D
.
ÀÀD E
	GetString
ÀÀE N
(
ÀÀN O
)
ÀÀO P
;
ÀÀP Q
private
–– 
static
–– 
byte
–– 
[
–– 
]
–– 
CreateWorkbook
–– (
(
––( )
params
––) /
TemplateColumn
––0 >
[
––> ?
]
––? @
columns
––A H
)
––H I
{
—— 
const
““ 
int
““ 
LastDataRow
““ 
=
““ 
$num
““  $
;
““$ %
using
”” 
var
”” 
book
”” 
=
”” 
new
”” 

XLWorkbook
”” '
(
””' (
)
””( )
;
””) *
var
””+ .
sheet
””/ 4
=
””5 6
book
””7 ;
.
””; <
AddWorksheet
””< H
(
””H I
$str
””I T
)
””T U
;
””U V
var
‘‘ 
help
‘‘ 
=
‘‘ 
book
‘‘ 
.
‘‘ 
AddWorksheet
‘‘ $
(
‘‘$ %
$str
‘‘% 6
)
‘‘6 7
;
‘‘7 8
help
’’ 
.
’’ 
Cell
’’ 
(
’’ 
$num
’’ 
,
’’ 
$num
’’ 
)
’’ 
.
’’ 
Value
’’ 
=
’’ 
$str
’’  )
;
’’) *
help
’’+ /
.
’’/ 0
Cell
’’0 4
(
’’4 5
$num
’’5 6
,
’’6 7
$num
’’8 9
)
’’9 :
.
’’: ;
Value
’’; @
=
’’A B
$str
’’C P
;
’’P Q
help
’’R V
.
’’V W
Cell
’’W [
(
’’[ \
$num
’’\ ]
,
’’] ^
$num
’’_ `
)
’’` a
.
’’a b
Value
’’b g
=
’’h i
$str
’’j }
;
’’} ~
help’’ É
.’’É Ñ
Row’’Ñ á
(’’á à
$num’’à â
)’’â ä
.’’ä ã
Style’’ã ê
.’’ê ë
Font’’ë ï
.’’ï ñ
Bold’’ñ ö
=’’õ ú
true’’ù °
;’’° ¢
for
÷÷ 
(
÷÷ 
var
÷÷ 
i
÷÷ 
=
÷÷ 
$num
÷÷ 
;
÷÷ 
i
÷÷ 
<
÷÷ 
columns
÷÷ #
.
÷÷# $
Length
÷÷$ *
;
÷÷* +
i
÷÷, -
++
÷÷- /
)
÷÷/ 0
{
◊◊ 	
var
ÿÿ 
column
ÿÿ 
=
ÿÿ 
columns
ÿÿ  
[
ÿÿ  !
i
ÿÿ! "
]
ÿÿ" #
;
ÿÿ# $
var
ÿÿ% (
accepted
ÿÿ) 1
=
ÿÿ2 3
column
ÿÿ4 :
.
ÿÿ: ;
Options
ÿÿ; B
is
ÿÿC E
null
ÿÿF J
?
ÿÿK L
column
ÿÿM S
.
ÿÿS T
Accepted
ÿÿT \
:
ÿÿ] ^
$"
ÿÿ_ a
{
ÿÿa b
column
ÿÿb h
.
ÿÿh i
Accepted
ÿÿi q
}
ÿÿq r
$str
ÿÿr t
{
ÿÿt u
string
ÿÿu {
.
ÿÿ{ |
Joinÿÿ| Ä
(ÿÿÄ Å
$strÿÿÅ Ö
,ÿÿÖ Ü
columnÿÿá ç
.ÿÿç é
Optionsÿÿé ï
)ÿÿï ñ
}ÿÿñ ó
"ÿÿó ò
;ÿÿò ô
var
ŸŸ 
header
ŸŸ 
=
ŸŸ 
sheet
ŸŸ 
.
ŸŸ 
Cell
ŸŸ #
(
ŸŸ# $
$num
ŸŸ$ %
,
ŸŸ% &
i
ŸŸ' (
+
ŸŸ) *
$num
ŸŸ+ ,
)
ŸŸ, -
;
ŸŸ- .
header
ŸŸ/ 5
.
ŸŸ5 6
Value
ŸŸ6 ;
=
ŸŸ< =
column
ŸŸ> D
.
ŸŸD E
Name
ŸŸE I
;
ŸŸI J
header
⁄⁄ 
.
⁄⁄ 
CreateComment
⁄⁄  
(
⁄⁄  !
)
⁄⁄! "
.
⁄⁄" #
AddText
⁄⁄# *
(
⁄⁄* +
$"
⁄⁄+ -
{
⁄⁄- .
(
⁄⁄. /
column
⁄⁄/ 5
.
⁄⁄5 6
Required
⁄⁄6 >
?
⁄⁄? @
$str
⁄⁄A N
:
⁄⁄O P
$str
⁄⁄Q [
)
⁄⁄[ \
}
⁄⁄\ ]
$str
⁄⁄] _
{
⁄⁄_ `
accepted
⁄⁄` h
}
⁄⁄h i
"
⁄⁄i j
)
⁄⁄j k
;
⁄⁄k l
if
€€ 
(
€€ 
column
€€ 
.
€€ 
Required
€€ 
)
€€  
header
€€! '
.
€€' (
Style
€€( -
.
€€- .
Fill
€€. 2
.
€€2 3
BackgroundColor
€€3 B
=
€€C D
XLColor
€€E L
.
€€L M
FromHtml
€€M U
(
€€U V
$str
€€V _
)
€€_ `
;
€€` a
if
‹‹ 
(
‹‹ 
column
‹‹ 
.
‹‹ 
Options
‹‹ 
is
‹‹ !
not
‹‹" %
null
‹‹& *
)
‹‹* +
{
›› 
var
ﬁﬁ 

validation
ﬁﬁ 
=
ﬁﬁ  
sheet
ﬁﬁ! &
.
ﬁﬁ& '
Range
ﬁﬁ' ,
(
ﬁﬁ, -
$num
ﬁﬁ- .
,
ﬁﬁ. /
i
ﬁﬁ0 1
+
ﬁﬁ2 3
$num
ﬁﬁ4 5
,
ﬁﬁ5 6
LastDataRow
ﬁﬁ7 B
,
ﬁﬁB C
i
ﬁﬁD E
+
ﬁﬁF G
$num
ﬁﬁH I
)
ﬁﬁI J
.
ﬁﬁJ K"
CreateDataValidation
ﬁﬁK _
(
ﬁﬁ_ `
)
ﬁﬁ` a
;
ﬁﬁa b

validation
ﬂﬂ 
.
ﬂﬂ 
List
ﬂﬂ 
(
ﬂﬂ  
$"
ﬂﬂ  "
$str
ﬂﬂ" $
{
ﬂﬂ$ %
string
ﬂﬂ% +
.
ﬂﬂ+ ,
Join
ﬂﬂ, 0
(
ﬂﬂ0 1
$str
ﬂﬂ1 4
,
ﬂﬂ4 5
column
ﬂﬂ6 <
.
ﬂﬂ< =
Options
ﬂﬂ= D
)
ﬂﬂD E
}
ﬂﬂE F
$str
ﬂﬂF H
"
ﬂﬂH I
,
ﬂﬂI J
true
ﬂﬂK O
)
ﬂﬂO P
;
ﬂﬂP Q

validation
‡‡ 
.
‡‡ 

ErrorTitle
‡‡ %
=
‡‡& '
column
‡‡( .
.
‡‡. /
Name
‡‡/ 3
;
‡‡3 4

validation
‡‡5 ?
.
‡‡? @
ErrorMessage
‡‡@ L
=
‡‡M N
$"
‡‡O Q
$str
‡‡Q d
{
‡‡d e
string
‡‡e k
.
‡‡k l
Join
‡‡l p
(
‡‡p q
$str
‡‡q u
,
‡‡u v
column
‡‡w }
.
‡‡} ~
Options‡‡~ Ö
)‡‡Ö Ü
}‡‡Ü á
"‡‡á à
;‡‡à â
}
·· 
help
‚‚ 
.
‚‚ 
Cell
‚‚ 
(
‚‚ 
i
‚‚ 
+
‚‚ 
$num
‚‚ 
,
‚‚ 
$num
‚‚ 
)
‚‚ 
.
‚‚  
Value
‚‚  %
=
‚‚& '
column
‚‚( .
.
‚‚. /
Name
‚‚/ 3
;
‚‚3 4
help
‚‚5 9
.
‚‚9 :
Cell
‚‚: >
(
‚‚> ?
i
‚‚? @
+
‚‚A B
$num
‚‚C D
,
‚‚D E
$num
‚‚F G
)
‚‚G H
.
‚‚H I
Value
‚‚I N
=
‚‚O P
column
‚‚Q W
.
‚‚W X
Required
‚‚X `
?
‚‚a b
$str
‚‚c g
:
‚‚h i
$str
‚‚j n
;
‚‚n o
help
‚‚p t
.
‚‚t u
Cell
‚‚u y
(
‚‚y z
i
‚‚z {
+
‚‚| }
$num
‚‚~ 
,‚‚ Ä
$num‚‚Å Ç
)‚‚Ç É
.‚‚É Ñ
Value‚‚Ñ â
=‚‚ä ã
accepted‚‚å î
;‚‚î ï
}
„„ 	
sheet
‰‰ 
.
‰‰ 
Row
‰‰ 
(
‰‰ 
$num
‰‰ 
)
‰‰ 
.
‰‰ 
Style
‰‰ 
.
‰‰ 
Font
‰‰ 
.
‰‰  
Bold
‰‰  $
=
‰‰% &
true
‰‰' +
;
‰‰+ ,
sheet
‰‰- 2
.
‰‰2 3
Columns
‰‰3 :
(
‰‰: ;
)
‰‰; <
.
‰‰< =
AdjustToContents
‰‰= M
(
‰‰M N
)
‰‰N O
;
‰‰O P
help
‰‰Q U
.
‰‰U V
Columns
‰‰V ]
(
‰‰] ^
)
‰‰^ _
.
‰‰_ `
AdjustToContents
‰‰` p
(
‰‰p q
)
‰‰q r
;
‰‰r s
help
ÂÂ 
.
ÂÂ 
Cell
ÂÂ 
(
ÂÂ 
columns
ÂÂ 
.
ÂÂ 
Length
ÂÂ  
+
ÂÂ! "
$num
ÂÂ# $
,
ÂÂ$ %
$num
ÂÂ& '
)
ÂÂ' (
.
ÂÂ( )
Value
ÂÂ) .
=
ÂÂ/ 0
$strÂÂ1 ñ
;ÂÂñ ó
using
ÊÊ 
var
ÊÊ 
stream
ÊÊ 
=
ÊÊ 
new
ÊÊ 
MemoryStream
ÊÊ +
(
ÊÊ+ ,
)
ÊÊ, -
;
ÊÊ- .
book
ÊÊ/ 3
.
ÊÊ3 4
SaveAs
ÊÊ4 :
(
ÊÊ: ;
stream
ÊÊ; A
)
ÊÊA B
;
ÊÊB C
return
ÊÊD J
stream
ÊÊK Q
.
ÊÊQ R
ToArray
ÊÊR Y
(
ÊÊY Z
)
ÊÊZ [
;
ÊÊ[ \
}
ÁÁ 
private
ËË 
static
ËË 
string
ËË 
?
ËË 
EmptyToNull
ËË &
(
ËË& '
string
ËË' -
?
ËË- .
value
ËË/ 4
)
ËË4 5
=>
ËË6 8
string
ËË9 ?
.
ËË? @ 
IsNullOrWhiteSpace
ËË@ R
(
ËËR S
value
ËËS X
)
ËËX Y
?
ËËZ [
null
ËË\ `
:
ËËa b
value
ËËc h
.
ËËh i
Trim
ËËi m
(
ËËm n
)
ËËn o
;
ËËo p
private
ÈÈ 
static
ÈÈ 
string
ÈÈ 
?
ÈÈ 
ValidateClient
ÈÈ )
(
ÈÈ) *
ClientRequest
ÈÈ* 7
request
ÈÈ8 ?
)
ÈÈ? @
{
ÍÍ 
if
ÎÎ 

(
ÎÎ 
string
ÎÎ 
.
ÎÎ  
IsNullOrWhiteSpace
ÎÎ %
(
ÎÎ% &
request
ÎÎ& -
.
ÎÎ- .
CompanyName
ÎÎ. 9
)
ÎÎ9 :
||
ÎÎ; =
string
ÎÎ> D
.
ÎÎD E 
IsNullOrWhiteSpace
ÎÎE W
(
ÎÎW X
request
ÎÎX _
.
ÎÎ_ `
ContactName
ÎÎ` k
)
ÎÎk l
||
ÎÎm o
string
ÎÎp v
.
ÎÎv w!
IsNullOrWhiteSpaceÎÎw â
(ÎÎâ ä
requestÎÎä ë
.ÎÎë í
EmailÎÎí ó
)ÎÎó ò
||ÎÎô õ
!ÎÎú ù
requestÎÎù §
.ÎÎ§ •
EmailÎÎ• ™
.ÎÎ™ ´
ContainsÎÎ´ ≥
(ÎÎ≥ ¥
$charÎÎ¥ ∑
)ÎÎ∑ ∏
)ÎÎ∏ π
returnÎÎ∫ ¿
$strÎÎ¡ ı
;ÎÎı ˆ
return
ÏÏ 
request
ÏÏ 
.
ÏÏ 
PreferredLanguage
ÏÏ (
.
ÏÏ( )
Trim
ÏÏ) -
(
ÏÏ- .
)
ÏÏ. /
.
ÏÏ/ 0
ToLowerInvariant
ÏÏ0 @
(
ÏÏ@ A
)
ÏÏA B
is
ÏÏC E
not
ÏÏF I
(
ÏÏJ K
$str
ÏÏK O
or
ÏÏP R
$str
ÏÏS W
or
ÏÏX Z
$str
ÏÏ[ _
)
ÏÏ_ `
?
ÏÏa b
$str
ÏÏc u
:
ÏÏv w
null
ÏÏx |
;
ÏÏ| }
}
ÌÌ 
private
ÓÓ 
static
ÓÓ 
string
ÓÓ 
?
ÓÓ 
ValidateProduct
ÓÓ *
(
ÓÓ* +
ProductRequest
ÓÓ+ 9
request
ÓÓ: A
)
ÓÓA B
=>
ÓÓC E
string
ÓÓF L
.
ÓÓL M 
IsNullOrWhiteSpace
ÓÓM _
(
ÓÓ_ `
request
ÓÓ` g
.
ÓÓg h
Name
ÓÓh l
)
ÓÓl m
||
ÓÓn p
string
ÓÓq w
.
ÓÓw x!
IsNullOrWhiteSpaceÓÓx ä
(ÓÓä ã
requestÓÓã í
.ÓÓí ì
CurrencyÓÓì õ
)ÓÓõ ú
?ÓÓù û
$strÓÓü ¬
:ÓÓ√ ƒ
nullÓÓ≈ …
;ÓÓ…  
private
 
async
 
Task
 (
EnsureProductCategoryAsync
 1
(
1 2
string
2 8
?
8 9
name
: >
,
> ?
CancellationToken
@ Q
ct
R T
)
T U
{
ÒÒ 
if
ÚÚ 

(
ÚÚ 
string
ÚÚ 
.
ÚÚ  
IsNullOrWhiteSpace
ÚÚ %
(
ÚÚ% &
name
ÚÚ& *
)
ÚÚ* +
)
ÚÚ+ ,
return
ÚÚ- 3
;
ÚÚ3 4
name
ÛÛ 
=
ÛÛ 
name
ÛÛ 
.
ÛÛ 
Trim
ÛÛ 
(
ÛÛ 
)
ÛÛ 
;
ÛÛ 
if
ÙÙ 

(
ÙÙ 
db
ÙÙ 
.
ÙÙ 
ProductCategories
ÙÙ  
.
ÙÙ  !
Local
ÙÙ! &
.
ÙÙ& '
Any
ÙÙ' *
(
ÙÙ* +
x
ÙÙ+ ,
=>
ÙÙ- /
x
ÙÙ0 1
.
ÙÙ1 2
Name
ÙÙ2 6
.
ÙÙ6 7
Equals
ÙÙ7 =
(
ÙÙ= >
name
ÙÙ> B
,
ÙÙB C
StringComparison
ÙÙD T
.
ÙÙT U
OrdinalIgnoreCase
ÙÙU f
)
ÙÙf g
)
ÙÙg h
||
ÙÙi k
await
ÙÙl q
db
ÙÙr t
.
ÙÙt u 
ProductCategoriesÙÙu Ü
.ÙÙÜ á
AnyAsyncÙÙá è
(ÙÙè ê
xÙÙê ë
=>ÙÙí î
xÙÙï ñ
.ÙÙñ ó
NameÙÙó õ
==ÙÙú û
nameÙÙü £
,ÙÙ£ §
ctÙÙ• ß
)ÙÙß ®
)ÙÙ® ©
returnÙÙ™ ∞
;ÙÙ∞ ±
db
ıı 

.
ıı
 
ProductCategories
ıı 
.
ıı 
Add
ıı  
(
ıı  !
new
ıı! $
ProductCategory
ıı% 4
{
ıı5 6
Name
ıı7 ;
=
ıı< =
name
ıı> B
,
ııB C
	SortOrder
ııD M
=
ııN O
await
ııP U
db
ııV X
.
ııX Y
ProductCategories
ııY j
.
ııj k

CountAsync
ıık u
(
ııu v
ct
ııv x
)
ııx y
+
ıız {
db
ıı| ~
.
ıı~  
ProductCategoriesıı ê
.ııê ë
Localııë ñ
.ııñ ó
Countııó ú
}ııù û
)ııû ü
;ııü †
}
ˆˆ 
internal
˘˘ 
static
˘˘ 
string
˘˘ 
Fold
˘˘ 
(
˘˘  
string
˘˘  &
value
˘˘' ,
)
˘˘, -
=>
˘˘. 0
new
˘˘1 4
(
˘˘4 5
value
˘˘5 :
.
˘˘: ;
Trim
˘˘; ?
(
˘˘? @
)
˘˘@ A
.
˘˘A B
ToLowerInvariant
˘˘B R
(
˘˘R S
)
˘˘S T
.
˘˘T U
	Normalize
˘˘U ^
(
˘˘^ _
System
˘˘_ e
.
˘˘e f
Text
˘˘f j
.
˘˘j k
NormalizationForm
˘˘k |
.
˘˘| }
FormD˘˘} Ç
)˘˘Ç É
.
˙˙ 	
Where
˙˙	 
(
˙˙ 
c
˙˙ 
=>
˙˙ 
System
˙˙ 
.
˙˙ 
Globalization
˙˙ (
.
˙˙( )
CharUnicodeInfo
˙˙) 8
.
˙˙8 9 
GetUnicodeCategory
˙˙9 K
(
˙˙K L
c
˙˙L M
)
˙˙M N
!=
˙˙O Q
System
˙˙R X
.
˙˙X Y
Globalization
˙˙Y f
.
˙˙f g
UnicodeCategory
˙˙g v
.
˙˙v w
NonSpacingMark˙˙w Ö
)˙˙Ö Ü
.˙˙Ü á
ToArray˙˙á é
(˙˙é è
)˙˙è ê
)˙˙ê ë
;˙˙ë í
private
¸¸ 
static
¸¸ 
Product
¸¸ 
	ToProduct
¸¸ $
(
¸¸$ %
ProductRequest
¸¸% 3
r
¸¸4 5
)
¸¸5 6
=>
¸¸7 9
new
¸¸: =
(
¸¸= >
)
¸¸> ?
{
¸¸@ A
Type
¸¸B F
=
¸¸G H
r
¸¸I J
.
¸¸J K
Type
¸¸K O
,
¸¸O P
Name
¸¸Q U
=
¸¸V W
r
¸¸X Y
.
¸¸Y Z
Name
¸¸Z ^
.
¸¸^ _
Trim
¸¸_ c
(
¸¸c d
)
¸¸d e
,
¸¸e f
BillingCycle
¸¸g s
=
¸¸t u
r
¸¸v w
.
¸¸w x
BillingCycle¸¸x Ñ
,¸¸Ñ Ö
	BasePrice¸¸Ü è
=¸¸ê ë
r¸¸í ì
.¸¸ì î
	BasePrice¸¸î ù
,¸¸ù û
Currency¸¸ü ß
=¸¸® ©
r¸¸™ ´
.¸¸´ ¨
Currency¸¸¨ ¥
.¸¸¥ µ
Trim¸¸µ π
(¸¸π ∫
)¸¸∫ ª
.¸¸ª º 
ToUpperInvariant¸¸º Ã
(¸¸Ã Õ
)¸¸Õ Œ
,¸¸Œ œ
Description¸¸– €
=¸¸‹ ›
EmptyToNull¸¸ﬁ È
(¸¸È Í
r¸¸Í Î
.¸¸Î Ï
Description¸¸Ï ˜
)¸¸˜ ¯
,¸¸¯ ˘
IsActive¸¸˙ Ç
=¸¸É Ñ
r¸¸Ö Ü
.¸¸Ü á
IsActive¸¸á è
,¸¸è ê
TaxDocumentType¸¸ë †
=¸¸° ¢
r¸¸£ §
.¸¸§ •
TaxDocumentType¸¸• ¥
,¸¸¥ µ
Category¸¸∂ æ
=¸¸ø ¿
EmptyToNull¸¸¡ Ã
(¸¸Ã Õ
r¸¸Õ Œ
.¸¸Œ œ
Category¸¸œ ◊
)¸¸◊ ÿ
,¸¸ÿ Ÿ
Tags¸¸⁄ ﬁ
=¸¸ﬂ ‡
NormalizeTags¸¸· Ó
(¸¸Ó Ô
r¸¸Ô 
.¸¸ Ò
Tags¸¸Ò ı
)¸¸ı ˆ
,¸¸ˆ ˜
AllowsTickets¸¸¯ Ö
=¸¸Ü á
r¸¸à â
.¸¸â ä
AllowsTickets¸¸ä ó
}¸¸ò ô
;¸¸ô ö
private
˛˛ 
static
˛˛ 
string
˛˛ 
?
˛˛ 
NormalizeTags
˛˛ (
(
˛˛( )
string
˛˛) /
?
˛˛/ 0
tags
˛˛1 5
)
˛˛5 6
=>
˛˛7 9
tags
˛˛: >
?
˛˛> ?
.
˛˛? @
Split
˛˛@ E
(
˛˛E F
$char
˛˛F I
,
˛˛I J 
StringSplitOptions
˛˛K ]
.
˛˛] ^ 
RemoveEmptyEntries
˛˛^ p
|
˛˛q r!
StringSplitOptions˛˛s Ö
.˛˛Ö Ü
TrimEntries˛˛Ü ë
)˛˛ë í
.˛˛í ì
Distinct˛˛ì õ
(˛˛õ ú
StringComparer˛˛ú ™
.˛˛™ ´!
OrdinalIgnoreCase˛˛´ º
)˛˛º Ω
.˛˛Ω æ
ToArray˛˛æ ≈
(˛˛≈ ∆
)˛˛∆ «
is˛˛»  
{˛˛À Ã
Length˛˛Õ ”
:˛˛” ‘
>˛˛’ ÷
$num˛˛◊ ÿ
}˛˛Ÿ ⁄
list˛˛€ ﬂ
?˛˛‡ ·
string˛˛‚ Ë
.˛˛Ë È
Join˛˛È Ì
(˛˛Ì Ó
$str˛˛Ó Ú
,˛˛Ú Û
list˛˛Ù ¯
)˛˛¯ ˘
:˛˛˙ ˚
null˛˛¸ Ä
;˛˛Ä Å
private
ˇˇ 
static
ˇˇ 
object
ˇˇ 
	ClientDto
ˇˇ #
(
ˇˇ# $
Client
ˇˇ$ *
x
ˇˇ+ ,
)
ˇˇ, -
=>
ˇˇ. 0
new
ˇˇ1 4
{
ˇˇ5 6
id
ˇˇ7 9
=
ˇˇ: ;
x
ˇˇ< =
.
ˇˇ= >
Id
ˇˇ> @
,
ˇˇ@ A
companyName
ˇˇB M
=
ˇˇN O
x
ˇˇP Q
.
ˇˇQ R
CompanyName
ˇˇR ]
,
ˇˇ] ^
contactName
ˇˇ_ j
=
ˇˇk l
x
ˇˇm n
.
ˇˇn o
ContactName
ˇˇo z
,
ˇˇz {
emailˇˇ| Å
=ˇˇÇ É
xˇˇÑ Ö
.ˇˇÖ Ü
EmailˇˇÜ ã
,ˇˇã å
phoneˇˇç í
=ˇˇì î
xˇˇï ñ
.ˇˇñ ó
Phoneˇˇó ú
,ˇˇú ù!
preferredLanguageˇˇû Ø
=ˇˇ∞ ±
xˇˇ≤ ≥
.ˇˇ≥ ¥!
PreferredLanguageˇˇ¥ ≈
,ˇˇ≈ ∆
isActiveˇˇ« œ
=ˇˇ– —
xˇˇ“ ”
.ˇˇ” ‘
IsActiveˇˇ‘ ‹
,ˇˇ‹ ›#
requiresTaxDocumentˇˇﬁ Ò
=ˇˇÚ Û
xˇˇÙ ı
.ˇˇı ˆ#
RequiresTaxDocumentˇˇˆ â
}ˇˇä ã
;ˇˇã å
private
Ä	Ä	 
static
Ä	Ä	 
object
Ä	Ä	 

ProjectDto
Ä	Ä	 $
(
Ä	Ä	$ %
Project
Ä	Ä	% ,
x
Ä	Ä	- .
)
Ä	Ä	. /
=>
Ä	Ä	0 2
new
Ä	Ä	3 6
{
Ä	Ä	7 8
id
Ä	Ä	9 ;
=
Ä	Ä	< =
x
Ä	Ä	> ?
.
Ä	Ä	? @
Id
Ä	Ä	@ B
,
Ä	Ä	B C
clientId
Ä	Ä	D L
=
Ä	Ä	M N
x
Ä	Ä	O P
.
Ä	Ä	P Q
ClientId
Ä	Ä	Q Y
,
Ä	Ä	Y Z
name
Ä	Ä	[ _
=
Ä	Ä	` a
x
Ä	Ä	b c
.
Ä	Ä	c d
Name
Ä	Ä	d h
,
Ä	Ä	h i
slug
Ä	Ä	j n
=
Ä	Ä	o p
x
Ä	Ä	q r
.
Ä	Ä	r s
Slug
Ä	Ä	s w
,
Ä	Ä	w x
repositoriesÄ	Ä	y Ö
=Ä	Ä	Ü á
xÄ	Ä	à â
.Ä	Ä	â ä
RepositoriesÄ	Ä	ä ñ
.Ä	Ä	ñ ó!
OrderByDescendingÄ	Ä	ó ®
(Ä	Ä	® ©
rÄ	Ä	© ™
=>Ä	Ä	´ ≠
rÄ	Ä	Æ Ø
.Ä	Ä	Ø ∞
	IsDefaultÄ	Ä	∞ π
)Ä	Ä	π ∫
.Ä	Ä	∫ ª
ThenByÄ	Ä	ª ¡
(Ä	Ä	¡ ¬
rÄ	Ä	¬ √
=>Ä	Ä	ƒ ∆
rÄ	Ä	« »
.Ä	Ä	» …
NameÄ	Ä	… Õ
)Ä	Ä	Õ Œ
.Ä	Ä	Œ œ
SelectÄ	Ä	œ ’
(Ä	Ä	’ ÷
rÄ	Ä	÷ ◊
=>Ä	Ä	ÿ ⁄
newÄ	Ä	€ ﬁ
{Ä	Ä	ﬂ ‡
idÄ	Ä	· „
=Ä	Ä	‰ Â
rÄ	Ä	Ê Á
.Ä	Ä	Á Ë
IdÄ	Ä	Ë Í
,Ä	Ä	Í Î
ownerÄ	Ä	Ï Ò
=Ä	Ä	Ú Û
rÄ	Ä	Ù ı
.Ä	Ä	ı ˆ
OwnerÄ	Ä	ˆ ˚
,Ä	Ä	˚ ¸
nameÄ	Ä	˝ Å
=Ä	Ä	Ç É
rÄ	Ä	Ñ Ö
.Ä	Ä	Ö Ü
NameÄ	Ä	Ü ä
,Ä	Ä	ä ã
labelÄ	Ä	å ë
=Ä	Ä	í ì
rÄ	Ä	î ï
.Ä	Ä	ï ñ
LabelÄ	Ä	ñ õ
,Ä	Ä	õ ú
	isDefaultÄ	Ä	ù ¶
=Ä	Ä	ß ®
rÄ	Ä	© ™
.Ä	Ä	™ ´
	IsDefaultÄ	Ä	´ ¥
}Ä	Ä	µ ∂
)Ä	Ä	∂ ∑
}Ä	Ä	∏ π
;Ä	Ä	π ∫
private
Å	Å	 
static
Å	Å	 
object
Å	Å	 

ProductDto
Å	Å	 $
(
Å	Å	$ %
Product
Å	Å	% ,
x
Å	Å	- .
)
Å	Å	. /
=>
Å	Å	0 2
new
Å	Å	3 6
{
Å	Å	7 8
id
Å	Å	9 ;
=
Å	Å	< =
x
Å	Å	> ?
.
Å	Å	? @
Id
Å	Å	@ B
,
Å	Å	B C
type
Å	Å	D H
=
Å	Å	I J
x
Å	Å	K L
.
Å	Å	L M
Type
Å	Å	M Q
.
Å	Å	Q R
ToString
Å	Å	R Z
(
Å	Å	Z [
)
Å	Å	[ \
,
Å	Å	\ ]
name
Å	Å	^ b
=
Å	Å	c d
x
Å	Å	e f
.
Å	Å	f g
Name
Å	Å	g k
,
Å	Å	k l
billingCycle
Å	Å	m y
=
Å	Å	z {
x
Å	Å	| }
.
Å	Å	} ~
BillingCycleÅ	Å	~ ä
.Å	Å	ä ã
ToStringÅ	Å	ã ì
(Å	Å	ì î
)Å	Å	î ï
,Å	Å	ï ñ
	basePriceÅ	Å	ó †
=Å	Å	° ¢
xÅ	Å	£ §
.Å	Å	§ •
	BasePriceÅ	Å	• Æ
,Å	Å	Æ Ø
currencyÅ	Å	∞ ∏
=Å	Å	π ∫
xÅ	Å	ª º
.Å	Å	º Ω
CurrencyÅ	Å	Ω ≈
,Å	Å	≈ ∆
descriptionÅ	Å	« “
=Å	Å	” ‘
xÅ	Å	’ ÷
.Å	Å	÷ ◊
DescriptionÅ	Å	◊ ‚
,Å	Å	‚ „
isActiveÅ	Å	‰ Ï
=Å	Å	Ì Ó
xÅ	Å	Ô 
.Å	Å	 Ò
IsActiveÅ	Å	Ò ˘
,Å	Å	˘ ˙
taxDocumentTypeÅ	Å	˚ ä
=Å	Å	ã å
xÅ	Å	ç é
.Å	Å	é è
TaxDocumentTypeÅ	Å	è û
.Å	Å	û ü
ToStringÅ	Å	ü ß
(Å	Å	ß ®
)Å	Å	® ©
,Å	Å	© ™
categoryÅ	Å	´ ≥
=Å	Å	¥ µ
xÅ	Å	∂ ∑
.Å	Å	∑ ∏
CategoryÅ	Å	∏ ¿
,Å	Å	¿ ¡
tagsÅ	Å	¬ ∆
=Å	Å	« »
xÅ	Å	…  
.Å	Å	  À
TagsÅ	Å	À œ
,Å	Å	œ –
allowsTicketsÅ	Å	— ﬁ
=Å	Å	ﬂ ‡
xÅ	Å	· ‚
.Å	Å	‚ „
AllowsTicketsÅ	Å	„ 
}Å	Å	Ò Ú
;Å	Å	Ú Û
private
Ç	Ç	 
async
Ç	Ç	 
Task
Ç	Ç	 
<
Ç	Ç	 
object
Ç	Ç	 
>
Ç	Ç	 #
ClientProductDtoAsync
Ç	Ç	 4
(
Ç	Ç	4 5
ClientProduct
Ç	Ç	5 B
x
Ç	Ç	C D
,
Ç	Ç	D E
CancellationToken
Ç	Ç	F W
ct
Ç	Ç	X Z
)
Ç	Ç	Z [
=>
Ç	Ç	\ ^
ClientProductDto
Ç	Ç	_ o
(
Ç	Ç	o p
x
Ç	Ç	p q
,
Ç	Ç	q r
x
Ç	Ç	s t
.
Ç	Ç	t u
Product
Ç	Ç	u |
is
Ç	Ç	} 
nullÇ	Ç	Ä Ñ
?Ç	Ç	Ö Ü
$numÇ	Ç	á â
:Ç	Ç	ä ã
awaitÇ	Ç	å ë
dbÇ	Ç	í î
.Ç	Ç	î ï
IgvRateForAsyncÇ	Ç	ï §
(Ç	Ç	§ •
xÇ	Ç	• ¶
.Ç	Ç	¶ ß
ClientIdÇ	Ç	ß Ø
,Ç	Ç	Ø ∞
xÇ	Ç	± ≤
.Ç	Ç	≤ ≥
ProductÇ	Ç	≥ ∫
,Ç	Ç	∫ ª
ctÇ	Ç	º æ
)Ç	Ç	æ ø
)Ç	Ç	ø ¿
;Ç	Ç	¿ ¡
private
Ñ	Ñ	 
static
Ñ	Ñ	 
object
Ñ	Ñ	 
ClientProductDto
Ñ	Ñ	 *
(
Ñ	Ñ	* +
ClientProduct
Ñ	Ñ	+ 8
x
Ñ	Ñ	9 :
,
Ñ	Ñ	: ;
decimal
Ñ	Ñ	< C
igvRate
Ñ	Ñ	D K
)
Ñ	Ñ	K L
=>
Ñ	Ñ	M O
new
Ñ	Ñ	P S
{
Ñ	Ñ	T U
igvRate
Ñ	Ñ	V ]
,
Ñ	Ñ	] ^
nextChargeTotal
Ñ	Ñ	_ n
=
Ñ	Ñ	o p
x
Ñ	Ñ	q r
.
Ñ	Ñ	r s
NextChargeTotalÑ	Ñ	s Ç
(Ñ	Ñ	Ç É
igvRateÑ	Ñ	É ä
)Ñ	Ñ	ä ã
,Ñ	Ñ	ã å
idÑ	Ñ	ç è
=Ñ	Ñ	ê ë
xÑ	Ñ	í ì
.Ñ	Ñ	ì î
IdÑ	Ñ	î ñ
,Ñ	Ñ	ñ ó
clientIdÑ	Ñ	ò †
=Ñ	Ñ	° ¢
xÑ	Ñ	£ §
.Ñ	Ñ	§ •
ClientIdÑ	Ñ	• ≠
,Ñ	Ñ	≠ Æ
	projectIdÑ	Ñ	Ø ∏
=Ñ	Ñ	π ∫
xÑ	Ñ	ª º
.Ñ	Ñ	º Ω
	ProjectIdÑ	Ñ	Ω ∆
,Ñ	Ñ	∆ «
projectNameÑ	Ñ	» ”
=Ñ	Ñ	‘ ’
xÑ	Ñ	÷ ◊
.Ñ	Ñ	◊ ÿ
ProjectÑ	Ñ	ÿ ﬂ
?Ñ	Ñ	ﬂ ‡
.Ñ	Ñ	‡ ·
NameÑ	Ñ	· Â
,Ñ	Ñ	Â Ê
	productIdÑ	Ñ	Á 
=Ñ	Ñ	Ò Ú
xÑ	Ñ	Û Ù
.Ñ	Ñ	Ù ı
	ProductIdÑ	Ñ	ı ˛
,Ñ	Ñ	˛ ˇ
productNameÑ	Ñ	Ä ã
=Ñ	Ñ	å ç
xÑ	Ñ	é è
.Ñ	Ñ	è ê
ProductÑ	Ñ	ê ó
?Ñ	Ñ	ó ò
.Ñ	Ñ	ò ô
NameÑ	Ñ	ô ù
,Ñ	Ñ	ù û
productTypeÑ	Ñ	ü ™
=Ñ	Ñ	´ ¨
xÑ	Ñ	≠ Æ
.Ñ	Ñ	Æ Ø
ProductÑ	Ñ	Ø ∂
?Ñ	Ñ	∂ ∑
.Ñ	Ñ	∑ ∏
TypeÑ	Ñ	∏ º
.Ñ	Ñ	º Ω
ToStringÑ	Ñ	Ω ≈
(Ñ	Ñ	≈ ∆
)Ñ	Ñ	∆ «
,Ñ	Ñ	« »
currencyÑ	Ñ	… —
=Ñ	Ñ	“ ”
xÑ	Ñ	‘ ’
.Ñ	Ñ	’ ÷
ProductÑ	Ñ	÷ ›
?Ñ	Ñ	› ﬁ
.Ñ	Ñ	ﬁ ﬂ
CurrencyÑ	Ñ	ﬂ Á
??Ñ	Ñ	Ë Í
$strÑ	Ñ	Î 
,Ñ	Ñ	 Ò
billingCycleÑ	Ñ	Ú ˛
=Ñ	Ñ	ˇ Ä
xÑ	Ñ	Å Ç
.Ñ	Ñ	Ç É
BillingCycleÑ	Ñ	É è
.Ñ	Ñ	è ê
ToStringÑ	Ñ	ê ò
(Ñ	Ñ	ò ô
)Ñ	Ñ	ô ö
,Ñ	Ñ	ö õ
isManualBillingÑ	Ñ	ú ´
=Ñ	Ñ	¨ ≠
xÑ	Ñ	Æ Ø
.Ñ	Ñ	Ø ∞
IsManualBillingÑ	Ñ	∞ ø
,Ñ	Ñ	ø ¿
statusÑ	Ñ	¡ «
=Ñ	Ñ	» …
xÑ	Ñ	  À
.Ñ	Ñ	À Ã
StatusÑ	Ñ	Ã “
.Ñ	Ñ	“ ”
ToStringÑ	Ñ	” €
(Ñ	Ñ	€ ‹
)Ñ	Ñ	‹ ›
,Ñ	Ñ	› ﬁ
priceÑ	Ñ	ﬂ ‰
=Ñ	Ñ	Â Ê
xÑ	Ñ	Á Ë
.Ñ	Ñ	Ë È
PriceÑ	Ñ	È Ó
,Ñ	Ñ	Ó Ô
	listPriceÑ	Ñ	 ˘
=Ñ	Ñ	˙ ˚
xÑ	Ñ	¸ ˝
.Ñ	Ñ	˝ ˛
	ListPriceÑ	Ñ	˛ á
(Ñ	Ñ	á à
)Ñ	Ñ	à â
,Ñ	Ñ	â ä
discountÑ	Ñ	ã ì
=Ñ	Ñ	î ï
xÑ	Ñ	ñ ó
.Ñ	Ñ	ó ò
DiscountÑ	Ñ	ò †
,Ñ	Ñ	† °
discountEndsAtÑ	Ñ	¢ ∞
=Ñ	Ñ	± ≤
xÑ	Ñ	≥ ¥
.Ñ	Ñ	¥ µ
DiscountEndsAtÑ	Ñ	µ √
==Ñ	Ñ	ƒ ∆$
ClientProductPricingÑ	Ñ	« €
.Ñ	Ñ	€ ‹
NoEndÑ	Ñ	‹ ·
?Ñ	Ñ	‚ „
nullÑ	Ñ	‰ Ë
:Ñ	Ñ	È Í
xÑ	Ñ	Î Ï
.Ñ	Ñ	Ï Ì
DiscountEndsAtÑ	Ñ	Ì ˚
,Ñ	Ñ	˚ ¸
currentPriceÑ	Ñ	˝ â
=Ñ	Ñ	ä ã
xÑ	Ñ	å ç
.Ñ	Ñ	ç é
CurrentPriceÑ	Ñ	é ö
(Ñ	Ñ	ö õ
DateTimeÑ	Ñ	õ £
.Ñ	Ñ	£ §
UtcNowÑ	Ñ	§ ™
)Ñ	Ñ	™ ´
,Ñ	Ñ	´ ¨
nextChargePriceÑ	Ñ	≠ º
=Ñ	Ñ	Ω æ
xÑ	Ñ	ø ¿
.Ñ	Ñ	¿ ¡
NextChargePriceÑ	Ñ	¡ –
(Ñ	Ñ	– —
)Ñ	Ñ	— “
,Ñ	Ñ	“ ”

domainNameÑ	Ñ	‘ ﬁ
=Ñ	Ñ	ﬂ ‡
xÑ	Ñ	· ‚
.Ñ	Ñ	‚ „

DomainNameÑ	Ñ	„ Ì
,Ñ	Ñ	Ì Ó"
priceLabelOverrideÑ	Ñ	Ô Å
=Ñ	Ñ	Ç É
xÑ	Ñ	Ñ Ö
.Ñ	Ñ	Ö Ü"
PriceLabelOverrideÑ	Ñ	Ü ò
,Ñ	Ñ	ò ô
renewsAtÑ	Ñ	ö ¢
=Ñ	Ñ	£ §
xÑ	Ñ	• ¶
.Ñ	Ñ	¶ ß
RenewsAtÑ	Ñ	ß Ø
,Ñ	Ñ	Ø ∞
nextChargeAtÑ	Ñ	± Ω
=Ñ	Ñ	æ ø
xÑ	Ñ	¿ ¡
.Ñ	Ñ	¡ ¬
NextChargeAtÑ	Ñ	¬ Œ
}Ñ	Ñ	œ –
;Ñ	Ñ	– —
private
Ü	Ü	 
static
Ü	Ü	 
object
Ü	Ü	 
TaxDocumentDto
Ü	Ü	 (
(
Ü	Ü	( )
TaxDocument
Ü	Ü	) 4
x
Ü	Ü	5 6
,
Ü	Ü	6 7
decimal
Ü	Ü	8 ?
	rateToPen
Ü	Ü	@ I
,
Ü	Ü	I J
IEnumerable
Ü	Ü	K V
<
Ü	Ü	V W
TaxDocumentLine
Ü	Ü	W f
>
Ü	Ü	f g
lines
Ü	Ü	h m
,
Ü	Ü	m n
string
Ü	Ü	o u
?
Ü	Ü	u v
paymentMethodÜ	Ü	w Ñ
)Ü	Ü	Ñ Ö
=>Ü	Ü	Ü à
newÜ	Ü	â å
{Ü	Ü	ç é
paymentMethodÜ	Ü	è ú
,Ü	Ü	ú ù
linesÜ	Ü	û £
=Ü	Ü	§ •
linesÜ	Ü	¶ ´
.Ü	Ü	´ ¨
SelectÜ	Ü	¨ ≤
(Ü	Ü	≤ ≥
lÜ	Ü	≥ ¥
=>Ü	Ü	µ ∑
newÜ	Ü	∏ ª
{Ü	Ü	º Ω
clientProductIdÜ	Ü	æ Õ
=Ü	Ü	Œ œ
lÜ	Ü	– —
.Ü	Ü	— “
ClientProductIdÜ	Ü	“ ·
,Ü	Ü	· ‚
descriptionÜ	Ü	„ Ó
=Ü	Ü	Ô 
lÜ	Ü	Ò Ú
.Ü	Ü	Ú Û
DescriptionÜ	Ü	Û ˛
,Ü	Ü	˛ ˇ
amountÜ	Ü	Ä Ü
=Ü	Ü	á à
lÜ	Ü	â ä
.Ü	Ü	ä ã
AmountÜ	Ü	ã ë
}Ü	Ü	í ì
)Ü	Ü	ì î
.Ü	Ü	î ï
ToListÜ	Ü	ï õ
(Ü	Ü	õ ú
)Ü	Ü	ú ù
,Ü	Ü	ù û
idÜ	Ü	ü °
=Ü	Ü	¢ £
xÜ	Ü	§ •
.Ü	Ü	• ¶
IdÜ	Ü	¶ ®
,Ü	Ü	® ©$
paymentTransactionIdÜ	Ü	™ æ
=Ü	Ü	ø ¿
xÜ	Ü	¡ ¬
.Ü	Ü	¬ √$
PaymentTransactionIdÜ	Ü	√ ◊
,Ü	Ü	◊ ÿ
clientIdÜ	Ü	Ÿ ·
=Ü	Ü	‚ „
xÜ	Ü	‰ Â
.Ü	Ü	Â Ê
ClientIdÜ	Ü	Ê Ó
,Ü	Ü	Ó Ô
typeÜ	Ü	 Ù
=Ü	Ü	ı ˆ
xÜ	Ü	˜ ¯
.Ü	Ü	¯ ˘
TypeÜ	Ü	˘ ˝
.Ü	Ü	˝ ˛
ToStringÜ	Ü	˛ Ü
(Ü	Ü	Ü á
)Ü	Ü	á à
,Ü	Ü	à â
seriesÜ	Ü	ä ê
=Ü	Ü	ë í
xÜ	Ü	ì î
.Ü	Ü	î ï
SeriesÜ	Ü	ï õ
,Ü	Ü	õ ú
numberÜ	Ü	ù £
=Ü	Ü	§ •
xÜ	Ü	¶ ß
.Ü	Ü	ß ®
NumberÜ	Ü	® Æ
,Ü	Ü	Æ Ø
	issueDateÜ	Ü	∞ π
=Ü	Ü	∫ ª
xÜ	Ü	º Ω
.Ü	Ü	Ω æ
	IssueDateÜ	Ü	æ «
,Ü	Ü	« »
currencyÜ	Ü	… —
=Ü	Ü	“ ”
xÜ	Ü	‘ ’
.Ü	Ü	’ ÷
CurrencyÜ	Ü	÷ ﬁ
,Ü	Ü	ﬁ ﬂ

baseAmountÜ	Ü	‡ Í
=Ü	Ü	Î Ï
xÜ	Ü	Ì Ó
.Ü	Ü	Ó Ô

BaseAmountÜ	Ü	Ô ˘
,Ü	Ü	˘ ˙
	igvAmountÜ	Ü	˚ Ñ
=Ü	Ü	Ö Ü
xÜ	Ü	á à
.Ü	Ü	à â
	IgvAmountÜ	Ü	â í
,Ü	Ü	í ì
totalAmountÜ	Ü	î ü
=Ü	Ü	† °
xÜ	Ü	¢ £
.Ü	Ü	£ §
TotalAmountÜ	Ü	§ Ø
,Ü	Ü	Ø ∞
notesÜ	Ü	± ∂
=Ü	Ü	∑ ∏
xÜ	Ü	π ∫
.Ü	Ü	∫ ª
NotesÜ	Ü	ª ¿
,Ü	Ü	¿ ¡
retentionAmountÜ	Ü	¬ —
=Ü	Ü	“ ”
xÜ	Ü	‘ ’
.Ü	Ü	’ ÷
RetentionAmountÜ	Ü	÷ Â
,Ü	Ü	Â Ê
exchangeRate
á	á	 
=
á	á	 
x
á	á	 
.
á	á	 
Currency
á	á	 !
==
á	á	" $
$str
á	á	% *
?
á	á	+ ,
$num
á	á	- /
:
á	á	0 1
Math
á	á	2 6
.
á	á	6 7
Round
á	á	7 <
(
á	á	< =
	rateToPen
á	á	= F
,
á	á	F G
$num
á	á	H I
)
á	á	I J
,
á	á	J K
basePen
á	á	L S
=
á	á	T U
Math
á	á	V Z
.
á	á	Z [
Round
á	á	[ `
(
á	á	` a
x
á	á	a b
.
á	á	b c

BaseAmount
á	á	c m
*
á	á	n o
	rateToPen
á	á	p y
,
á	á	y z
$num
á	á	{ |
)
á	á	| }
,
á	á	} ~
igvPená	á	 Ö
=á	á	Ü á
Mathá	á	à å
.á	á	å ç
Roundá	á	ç í
(á	á	í ì
xá	á	ì î
.á	á	î ï
	IgvAmountá	á	ï û
*á	á	ü †
	rateToPená	á	° ™
,á	á	™ ´
$numá	á	¨ ≠
)á	á	≠ Æ
,á	á	Æ Ø
totalPená	á	∞ ∏
=á	á	π ∫
Mathá	á	ª ø
.á	á	ø ¿
Roundá	á	¿ ≈
(á	á	≈ ∆
xá	á	∆ «
.á	á	« »
TotalAmountá	á	» ”
*á	á	‘ ’
	rateToPená	á	÷ ﬂ
,á	á	ﬂ ‡
$numá	á	· ‚
)á	á	‚ „
}á	á	‰ Â
;á	á	Â Ê
private
â	â	 
static
â	â	 
void
â	â	 !
ApplyForeignService
â	â	 +
(
â	â	+ ,
Expense
â	â	, 3
expense
â	â	4 ;
,
â	â	; <
bool
â	â	= A
foreign
â	â	B I
,
â	â	I J
string
â	â	K Q
?
â	â	Q R
name
â	â	S W
,
â	â	W X
string
â	â	Y _
?
â	â	_ `
country
â	â	a h
)
â	â	h i
{
ä	ä	 
expense
ã	ã	 
.
ã	ã	 #
IsNonDomiciledService
ã	ã	 %
=
ã	ã	& '
foreign
ã	ã	( /
;
ã	ã	/ 0
(
å	å	 	
expense
å	å		 
.
å	å	 !
ForeignSupplierName
å	å	 $
,
å	å	$ %
expense
å	å	& -
.
å	å	- .$
ForeignSupplierCountry
å	å	. D
)
å	å	D E
=
å	å	F G
foreign
å	å	H O
?
å	å	P Q
(
å	å	R S
EmptyToNull
å	å	S ^
(
å	å	^ _
name
å	å	_ c
)
å	å	c d
,
å	å	d e
EmptyToNull
å	å	f q
(
å	å	q r
country
å	å	r y
)
å	å	y z
)
å	å	z {
:
å	å	| }
(
å	å	~ 
nullå	å	 É
,å	å	É Ñ
nullå	å	Ö â
)å	å	â ä
;å	å	ä ã
if
ç	ç	 

(
ç	ç	 
!
ç	ç	 
foreign
ç	ç	 
)
ç	ç	 
(
ç	ç	 
expense
ç	ç	 
.
ç	ç	 
Form1662PaidAt
ç	ç	 -
,
ç	ç	- .
expense
ç	ç	/ 6
.
ç	ç	6 7
Form1662Number
ç	ç	7 E
)
ç	ç	E F
=
ç	ç	G H
(
ç	ç	I J
null
ç	ç	J N
,
ç	ç	N O
null
ç	ç	P T
)
ç	ç	T U
;
ç	ç	U V
}
é	é	 
private
ê	ê	 
static
ê	ê	 
object
ê	ê	 

ExpenseDto
ê	ê	 $
(
ê	ê	$ %
Expense
ê	ê	% ,
x
ê	ê	- .
)
ê	ê	. /
=>
ê	ê	0 2
new
ê	ê	3 6
{
ê	ê	7 8
id
ê	ê	9 ;
=
ê	ê	< =
x
ê	ê	> ?
.
ê	ê	? @
Id
ê	ê	@ B
,
ê	ê	B C
description
ê	ê	D O
=
ê	ê	P Q
x
ê	ê	R S
.
ê	ê	S T
Description
ê	ê	T _
,
ê	ê	_ `

categoryId
ê	ê	a k
=
ê	ê	l m
x
ê	ê	n o
.
ê	ê	o p

CategoryId
ê	ê	p z
,
ê	ê	z {
categoryNameê	ê	| à
=ê	ê	â ä
xê	ê	ã å
.ê	ê	å ç
Categoryê	ê	ç ï
?ê	ê	ï ñ
.ê	ê	ñ ó
Nameê	ê	ó õ
??ê	ê	ú û
$strê	ê	ü °
,ê	ê	° ¢
typeê	ê	£ ß
=ê	ê	® ©
xê	ê	™ ´
.ê	ê	´ ¨
Typeê	ê	¨ ∞
.ê	ê	∞ ±
ToStringê	ê	± π
(ê	ê	π ∫
)ê	ê	∫ ª
,ê	ê	ª º
amountê	ê	Ω √
=ê	ê	ƒ ≈
xê	ê	∆ «
.ê	ê	« »
Amountê	ê	» Œ
,ê	ê	Œ œ
currencyê	ê	– ÿ
=ê	ê	Ÿ ⁄
xê	ê	€ ‹
.ê	ê	‹ ›
Currencyê	ê	› Â
,ê	ê	Â Ê
	amountPenê	ê	Á 
=ê	ê	Ò Ú
xê	ê	Û Ù
.ê	ê	Ù ı
	AmountPenê	ê	ı ˛
,ê	ê	˛ ˇ
dateê	ê	Ä Ñ
=ê	ê	Ö Ü
xê	ê	á à
.ê	ê	à â
Dateê	ê	â ç
,ê	ê	ç é
	recurringê	ê	è ò
=ê	ê	ô ö
xê	ê	õ ú
.ê	ê	ú ù
	Recurringê	ê	ù ¶
,ê	ê	¶ ß
recurrenceCycleê	ê	® ∑
=ê	ê	∏ π
xê	ê	∫ ª
.ê	ê	ª º
RecurrenceCycleê	ê	º À
?ê	ê	À Ã
.ê	ê	Ã Õ
ToStringê	ê	Õ ’
(ê	ê	’ ÷
)ê	ê	÷ ◊
,ê	ê	◊ ÿ 
recurrenceEndsAtê	ê	Ÿ È
=ê	ê	Í Î
xê	ê	Ï Ì
.ê	ê	Ì Ó 
RecurrenceEndsAtê	ê	Ó ˛
,ê	ê	˛ ˇ
isNonDeductibleê	ê	Ä è
=ê	ê	ê ë
xê	ê	í ì
.ê	ê	ì î
IsNonDeductibleê	ê	î £
,ê	ê	£ §%
isNonDomiciledServiceê	ê	• ∫
=ê	ê	ª º
xê	ê	Ω æ
.ê	ê	æ ø%
IsNonDomiciledServiceê	ê	ø ‘
,ê	ê	‘ ’#
foreignSupplierNameê	ê	÷ È
=ê	ê	Í Î
xê	ê	Ï Ì
.ê	ê	Ì Ó#
ForeignSupplierNameê	ê	Ó Å
,ê	ê	Å Ç&
foreignSupplierCountryê	ê	É ô
=ê	ê	ö õ
xê	ê	ú ù
.ê	ê	ù û&
ForeignSupplierCountryê	ê	û ¥
,ê	ê	¥ µ
form1662PaidAtê	ê	∂ ƒ
=ê	ê	≈ ∆
xê	ê	« »
.ê	ê	» …
Form1662PaidAtê	ê	… ◊
,ê	ê	◊ ÿ
form1662Numberê	ê	Ÿ Á
=ê	ê	Ë È
xê	ê	Í Î
.ê	ê	Î Ï
Form1662Numberê	ê	Ï ˙
}ê	ê	˚ ¸
;ê	ê	¸ ˝
}ë	ë	 
publicì	ì	 
sealed
ì	ì	 
record
ì	ì	 
ProfileRequest
ì	ì	 #
(
ì	ì	# $
string
ì	ì	$ *
Name
ì	ì	+ /
)
ì	ì	/ 0
;
ì	ì	0 1
publicî	î	 
sealed
î	î	 
record
î	î	 #
ChangePasswordRequest
î	î	 *
(
î	î	* +
string
î	î	+ 1
CurrentPassword
î	î	2 A
,
î	î	A B
string
î	î	C I
NewPassword
î	î	J U
)
î	î	U V
;
î	î	V W
publicï	ï	 
sealed
ï	ï	 
record
ï	ï	 
InviteRequest
ï	ï	 "
(
ï	ï	" #
string
ï	ï	# )
Name
ï	ï	* .
,
ï	ï	. /
string
ï	ï	0 6
Email
ï	ï	7 <
)
ï	ï	< =
;
ï	ï	= >
publicó	ó	 
sealed
ó	ó	 
record
ó	ó	 
UpdateTeamRequest
ó	ó	 &
(
ó	ó	& '
UserRole
ó	ó	' /
?
ó	ó	/ 0
Role
ó	ó	1 5
,
ó	ó	5 6
bool
ó	ó	7 ;
?
ó	ó	; <
IsActive
ó	ó	= E
,
ó	ó	E F
string
ó	ó	G M
?
ó	ó	M N
Area
ó	ó	O S
=
ó	ó	T U
null
ó	ó	V Z
,
ó	ó	Z [
string
ó	ó	\ b
?
ó	ó	b c
JobTitle
ó	ó	d l
=
ó	ó	m n
null
ó	ó	o s
,
ó	ó	s t
Guid
ó	ó	u y
?
ó	ó	y z
	ManagerIdó	ó	{ Ñ
=ó	ó	Ö Ü
nulló	ó	á ã
)ó	ó	ã å
;ó	ó	å ç
publicò	ò	 
sealed
ò	ò	 
record
ò	ò	 
ClientRequest
ò	ò	 "
(
ò	ò	" #
string
ò	ò	# )
CompanyName
ò	ò	* 5
,
ò	ò	5 6
string
ò	ò	7 =
ContactName
ò	ò	> I
,
ò	ò	I J
string
ò	ò	K Q
Email
ò	ò	R W
,
ò	ò	W X
string
ò	ò	Y _
?
ò	ò	_ `
Phone
ò	ò	a f
,
ò	ò	f g
string
ò	ò	h n 
PreferredLanguageò	ò	o Ä
,ò	ò	Ä Å
boolò	ò	Ç Ü#
RequiresTaxDocumentò	ò	á ö
=ò	ò	õ ú
falseò	ò	ù ¢
)ò	ò	¢ £
;ò	ò	£ §
publicô	ô	 
sealed
ô	ô	 
record
ô	ô	  
ClientPatchRequest
ô	ô	 '
(
ô	ô	' (
string
ô	ô	( .
?
ô	ô	. /
CompanyName
ô	ô	0 ;
,
ô	ô	; <
string
ô	ô	= C
?
ô	ô	C D
ContactName
ô	ô	E P
,
ô	ô	P Q
string
ô	ô	R X
?
ô	ô	X Y
Email
ô	ô	Z _
,
ô	ô	_ `
string
ô	ô	a g
?
ô	ô	g h
Phone
ô	ô	i n
,
ô	ô	n o
string
ô	ô	p v
?
ô	ô	v w 
PreferredLanguageô	ô	x â
,ô	ô	â ä
boolô	ô	ã è
?ô	ô	è ê
IsActiveô	ô	ë ô
,ô	ô	ô ö
boolô	ô	õ ü
?ô	ô	ü †#
RequiresTaxDocumentô	ô	° ¥
=ô	ô	µ ∂
nullô	ô	∑ ª
)ô	ô	ª º
;ô	ô	º Ω
publicö	ö	 
sealed
ö	ö	 
record
ö	ö	 
ProductRequest
ö	ö	 #
(
ö	ö	# $
[
ö	ö	$ %
property
ö	ö	% -
:
ö	ö	- .
JsonRequired
ö	ö	/ ;
]
ö	ö	; <
ProductType
ö	ö	= H
Type
ö	ö	I M
,
ö	ö	M N
string
ö	ö	O U
Name
ö	ö	V Z
,
ö	ö	Z [
[
ö	ö	\ ]
property
ö	ö	] e
:
ö	ö	e f
JsonRequired
ö	ö	g s
]
ö	ö	s t
BillingCycleö	ö	u Å
BillingCycleö	ö	Ç é
,ö	ö	é è
decimalö	ö	ê ó
?ö	ö	ó ò
	BasePriceö	ö	ô ¢
,ö	ö	¢ £
stringö	ö	§ ™
Currencyö	ö	´ ≥
,ö	ö	≥ ¥
stringö	ö	µ ª
?ö	ö	ª º
Descriptionö	ö	Ω »
,ö	ö	» …
[ö	ö	  À
propertyö	ö	À ”
:ö	ö	” ‘
JsonRequiredö	ö	’ ·
]ö	ö	· ‚
boolö	ö	„ Á
IsActiveö	ö	Ë 
,ö	ö	 Ò
TaxDocumentTypeö	ö	Ú Å
TaxDocumentTypeö	ö	Ç ë
=ö	ö	í ì
TaxDocumentTypeö	ö	î £
.ö	ö	£ §
Facturaö	ö	§ ´
,ö	ö	´ ¨
stringö	ö	≠ ≥
?ö	ö	≥ ¥
Categoryö	ö	µ Ω
=ö	ö	æ ø
nullö	ö	¿ ƒ
,ö	ö	ƒ ≈
stringö	ö	∆ Ã
?ö	ö	Ã Õ
Tagsö	ö	Œ “
=ö	ö	” ‘
nullö	ö	’ Ÿ
,ö	ö	Ÿ ⁄
boolö	ö	€ ﬂ
AllowsTicketsö	ö	‡ Ì
=ö	ö	Ó Ô
falseö	ö	 ı
)ö	ö	ı ˆ
;ö	ö	ˆ ˜
publicõ	õ	 
sealed
õ	õ	 
record
õ	õ	 !
ProductPatchRequest
õ	õ	 (
(
õ	õ	( )
ProductType
õ	õ	) 4
?
õ	õ	4 5
Type
õ	õ	6 :
,
õ	õ	: ;
string
õ	õ	< B
?
õ	õ	B C
Name
õ	õ	D H
,
õ	õ	H I
BillingCycle
õ	õ	J V
?
õ	õ	V W
BillingCycle
õ	õ	X d
,
õ	õ	d e
decimal
õ	õ	f m
?
õ	õ	m n
	BasePrice
õ	õ	o x
,
õ	õ	x y
stringõ	õ	z Ä
?õ	õ	Ä Å
Currencyõ	õ	Ç ä
,õ	õ	ä ã
stringõ	õ	å í
?õ	õ	í ì
Descriptionõ	õ	î ü
,õ	õ	ü †
boolõ	õ	° •
?õ	õ	• ¶
IsActiveõ	õ	ß Ø
,õ	õ	Ø ∞
TaxDocumentTypeõ	õ	± ¿
?õ	õ	¿ ¡
TaxDocumentTypeõ	õ	¬ —
=õ	õ	“ ”
nullõ	õ	‘ ÿ
,õ	õ	ÿ Ÿ
stringõ	õ	⁄ ‡
?õ	õ	‡ ·
Categoryõ	õ	‚ Í
=õ	õ	Î Ï
nullõ	õ	Ì Ò
,õ	õ	Ò Ú
stringõ	õ	Û ˘
?õ	õ	˘ ˙
Tagsõ	õ	˚ ˇ
=õ	õ	Ä Å
nullõ	õ	Ç Ü
,õ	õ	Ü á
boolõ	õ	à å
?õ	õ	å ç
AllowsTicketsõ	õ	é õ
=õ	õ	ú ù
nullõ	õ	û ¢
)õ	õ	¢ £
;õ	õ	£ §
publicú	ú	 
sealed
ú	ú	 
record
ú	ú	 "
AssignProductRequest
ú	ú	 )
(
ú	ú	) *
[
ú	ú	* +
property
ú	ú	+ 3
:
ú	ú	3 4
JsonRequired
ú	ú	5 A
]
ú	ú	A B
Guid
ú	ú	C G
	ProductId
ú	ú	H Q
,
ú	ú	Q R
[
ú	ú	S T
property
ú	ú	T \
:
ú	ú	\ ]
JsonRequired
ú	ú	^ j
]
ú	ú	j k
Guid
ú	ú	l p
	ProjectId
ú	ú	q z
,
ú	ú	z {
[
ú	ú	| }
propertyú	ú	} Ö
:ú	ú	Ö Ü
JsonRequiredú	ú	á ì
]ú	ú	ì î
BillingCycleú	ú	ï °
BillingCycleú	ú	¢ Æ
,ú	ú	Æ Ø
stringú	ú	∞ ∂
BillingModeú	ú	∑ ¬
,ú	ú	¬ √
decimalú	ú	ƒ À
?ú	ú	À Ã
Priceú	ú	Õ “
,ú	ú	“ ”
stringú	ú	‘ ⁄
?ú	ú	⁄ €

DomainNameú	ú	‹ Ê
,ú	ú	Ê Á
stringú	ú	Ë Ó
?ú	ú	Ó Ô"
PriceLabelOverrideú	ú	 Ç
,ú	ú	Ç É
DateOnlyú	ú	Ñ å
?ú	ú	å ç
RenewsAtú	ú	é ñ
=ú	ú	ó ò
nullú	ú	ô ù
,ú	ú	ù û
DateOnlyú	ú	ü ß
?ú	ú	ß ®
NextChargeAtú	ú	© µ
=ú	ú	∂ ∑
nullú	ú	∏ º
,ú	ú	º Ω
decimalú	ú	æ ≈
?ú	ú	≈ ∆
Discountú	ú	« œ
=ú	ú	– —
nullú	ú	“ ÷
)ú	ú	÷ ◊
;ú	ú	◊ ÿ
publicù	ù	 
sealed
ù	ù	 
record
ù	ù	 $
TransferPaymentRequest
ù	ù	 +
(
ù	ù	+ ,
decimal
ù	ù	, 3
?
ù	ù	3 4
Amount
ù	ù	5 ;
,
ù	ù	; <
DateOnly
ù	ù	= E
?
ù	ù	E F
PaidAt
ù	ù	G M
,
ù	ù	M N
string
ù	ù	O U
?
ù	ù	U V
	Reference
ù	ù	W `
,
ù	ù	` a
int
ù	ù	b e
Years
ù	ù	f k
=
ù	ù	l m
$num
ù	ù	n o
)
ù	ù	o p
;
ù	ù	p q
publicû	û	 
sealed
û	û	 
record
û	û	 '
ClientProductDatesRequest
û	û	 .
(
û	û	. /
DateOnly
û	û	/ 7
?
û	û	7 8
RenewsAt
û	û	9 A
,
û	û	A B
DateOnly
û	û	C K
?
û	û	K L
NextChargeAt
û	û	M Y
)
û	û	Y Z
;
û	û	Z [
publicü	ü	 
sealed
ü	ü	 
record
ü	ü	 '
ClientProductPatchRequest
ü	ü	 .
(
ü	ü	. /
decimal
ü	ü	/ 6
?
ü	ü	6 7
Price
ü	ü	8 =
,
ü	ü	= >!
ClientProductStatus
ü	ü	? R
?
ü	ü	R S
Status
ü	ü	T Z
,
ü	ü	Z [
BillingCycle
ü	ü	\ h
?
ü	ü	h i
BillingCycle
ü	ü	j v
,
ü	ü	v w
bool
ü	ü	x |
?
ü	ü	| }
IsManualBillingü	ü	~ ç
,ü	ü	ç é
stringü	ü	è ï
?ü	ü	ï ñ

DomainNameü	ü	ó °
,ü	ü	° ¢
stringü	ü	£ ©
?ü	ü	© ™"
PriceLabelOverrideü	ü	´ Ω
,ü	ü	Ω æ
decimalü	ü	ø ∆
?ü	ü	∆ «
Discountü	ü	» –
=ü	ü	— “
nullü	ü	” ◊
,ü	ü	◊ ÿ
Guidü	ü	Ÿ ›
?ü	ü	› ﬁ
	ProjectIdü	ü	ﬂ Ë
=ü	ü	È Í
nullü	ü	Î Ô
)ü	ü	Ô 
;ü	ü	 Ò
public†	†	 
sealed
†	†	 
record
†	†	 
ImportError
†	†	  
(
†	†	  !
int
†	†	! $
Row
†	†	% (
,
†	†	( )
string
†	†	* 0
Reason
†	†	1 7
)
†	†	7 8
;
†	†	8 9
public¢	¢	 
sealed
¢	¢	 
record
¢	¢	 
TemplateColumn
¢	¢	 #
(
¢	¢	# $
string
¢	¢	$ *
Name
¢	¢	+ /
,
¢	¢	/ 0
bool
¢	¢	1 5
Required
¢	¢	6 >
,
¢	¢	> ?
string
¢	¢	@ F
Accepted
¢	¢	G O
,
¢	¢	O P
string
¢	¢	Q W
[
¢	¢	W X
]
¢	¢	X Y
?
¢	¢	Y Z
Options
¢	¢	[ b
=
¢	¢	c d
null
¢	¢	e i
)
¢	¢	i j
;
¢	¢	j k
public£	£	 
sealed
£	£	 
record
£	£	 
ClientAccess
£	£	 !
(
£	£	! "
string
£	£	" (

ClientName
£	£	) 3
,
£	£	3 4
string
£	£	5 ;
Email
£	£	< A
,
£	£	A B
string
£	£	C I
TemporaryPassword
£	£	J [
,
£	£	[ \
bool
£	£	] a
	EmailSent
£	£	b k
=
£	£	l m
false
£	£	n s
)
£	£	s t
;
£	£	t u
public§	§	 
sealed
§	§	 
record
§	§	 
ProjectRequest
§	§	 #
(
§	§	# $
string
§	§	$ *
?
§	§	* +
Name
§	§	, 0
,
§	§	0 1
string
§	§	2 8
?
§	§	8 9
Slug
§	§	: >
,
§	§	> ?
string
§	§	@ F
?
§	§	F G
GithubRepoOwner
§	§	H W
,
§	§	W X
string
§	§	Y _
?
§	§	_ `
GithubRepoName
§	§	a o
)
§	§	o p
;
§	§	p q
public•	•	 
sealed
•	•	 
record
•	•	 
RepositoryRequest
•	•	 &
(
•	•	& '
string
•	•	' -
?
•	•	- .
Owner
•	•	/ 4
,
•	•	4 5
string
•	•	6 <
?
•	•	< =
Name
•	•	> B
,
•	•	B C
string
•	•	D J
?
•	•	J K
Label
•	•	L Q
=
•	•	R S
null
•	•	T X
,
•	•	X Y
bool
•	•	Z ^
?
•	•	^ _
	IsDefault
•	•	` i
=
•	•	j k
null
•	•	l p
)
•	•	p q
;
•	•	q r
public¶	¶	 
sealed
¶	¶	 
record
¶	¶	  
TaxSettingsRequest
¶	¶	 '
(
¶	¶	' (
decimal
¶	¶	( /
?
¶	¶	/ 0
IgvRate
¶	¶	1 8
,
¶	¶	8 9
decimal
¶	¶	: A
?
¶	¶	A B
	RentaRate
¶	¶	C L
,
¶	¶	L M
string
¶	¶	N T
?
¶	¶	T U
FacturaSeries
¶	¶	V c
=
¶	¶	d e
null
¶	¶	f j
,
¶	¶	j k
int
¶	¶	l o
?
¶	¶	o p 
FacturaNextNumber¶	¶	q Ç
=¶	¶	É Ñ
null¶	¶	Ö â
,¶	¶	â ä
string¶	¶	ã ë
?¶	¶	ë í
ReciboSeries¶	¶	ì ü
=¶	¶	† °
null¶	¶	¢ ¶
,¶	¶	¶ ß
int¶	¶	® ´
?¶	¶	´ ¨ 
ReciboNextNumber¶	¶	≠ Ω
=¶	¶	æ ø
null¶	¶	¿ ƒ
,¶	¶	ƒ ≈
string¶	¶	∆ Ã
?¶	¶	Ã Õ
Ruc¶	¶	Œ —
=¶	¶	“ ”
null¶	¶	‘ ÿ
,¶	¶	ÿ Ÿ
bool¶	¶	⁄ ﬁ
?¶	¶	ﬁ ﬂ
IsGoodTaxpayer¶	¶	‡ Ó
=¶	¶	Ô 
null¶	¶	Ò ı
,¶	¶	ı ˆ
bool¶	¶	˜ ˚
?¶	¶	˚ ¸
Use1662AsCredit¶	¶	˝ å
=¶	¶	ç é
null¶	¶	è ì
)¶	¶	ì î
;¶	¶	î ï
public®	®	 
sealed
®	®	 
record
®	®	  
TaxDocumentRequest
®	®	 '
(
®	®	' (
Guid
®	®	( ,
?
®	®	, -
ClientProductId
®	®	. =
,
®	®	= >
[
®	®	? @
property
®	®	@ H
:
®	®	H I
JsonRequired
®	®	J V
]
®	®	V W
DateOnly
®	®	X `
	IssueDate
®	®	a j
,
®	®	j k
string
®	®	l r
Currency
®	®	s {
,
®	®	{ |
decimal®	®	} Ñ
?®	®	Ñ Ö
TotalAmount®	®	Ü ë
,®	®	ë í
string®	®	ì ô
?®	®	ô ö
Notes®	®	õ †
,®	®	† °
decimal®	®	¢ ©
?®	®	© ™
RetentionAmount®	®	´ ∫
=®	®	ª º
null®	®	Ω ¡
,®	®	¡ ¬
IReadOnlyList®	®	√ –
<®	®	– —&
TaxDocumentItemRequest®	®	— Á
>®	®	Á Ë
?®	®	Ë È
Items®	®	Í Ô
=®	®	 Ò
null®	®	Ú ˆ
)®	®	ˆ ˜
;®	®	˜ ¯
public©	©	 
sealed
©	©	 
record
©	©	 $
TaxDocumentItemRequest
©	©	 +
(
©	©	+ ,
Guid
©	©	, 0
ClientProductId
©	©	1 @
,
©	©	@ A
decimal
©	©	B I
Amount
©	©	J P
)
©	©	P Q
;
©	©	Q R
public™	™	 
sealed
™	™	 
record
™	™	 '
ReverseTaxDocumentRequest
™	™	 .
(
™	™	. /
string
™	™	/ 5
?
™	™	5 6
Reason
™	™	7 =
,
™	™	= >
[
™	™	? @
property
™	™	@ H
:
™	™	H I
JsonRequired
™	™	J V
]
™	™	V W
bool
™	™	X \
	NotIssued
™	™	] f
)
™	™	f g
;
™	™	g h
public´	´	 
sealed
´	´	 
record
´	´	 
ExpenseRequest
´	´	 #
(
´	´	# $
string
´	´	$ *
Description
´	´	+ 6
,
´	´	6 7
[
´	´	8 9
property
´	´	9 A
:
´	´	A B
JsonRequired
´	´	C O
]
´	´	O P
Guid
´	´	Q U

CategoryId
´	´	V `
,
´	´	` a
[
´	´	b c
property
´	´	c k
:
´	´	k l
JsonRequired
´	´	m y
]
´	´	y z
ExpenseType´	´	{ Ü
Type´	´	á ã
,´	´	ã å
[´	´	ç é
property´	´	é ñ
:´	´	ñ ó
JsonRequired´	´	ò §
]´	´	§ •
decimal´	´	¶ ≠
Amount´	´	Æ ¥
,´	´	¥ µ
string´	´	∂ º
Currency´	´	Ω ≈
,´	´	≈ ∆
[´	´	« »
property´	´	» –
:´	´	– —
JsonRequired´	´	“ ﬁ
]´	´	ﬁ ﬂ
DateOnly´	´	‡ Ë
Date´	´	È Ì
,´	´	Ì Ó
[´	´	Ô 
property´	´	 ¯
:´	´	¯ ˘
JsonRequired´	´	˙ Ü
]´	´	Ü á
bool´	´	à å
	Recurring´	´	ç ñ
,´	´	ñ ó
BillingCycle´	´	ò §
?´	´	§ •
RecurrenceCycle´	´	¶ µ
,´	´	µ ∂
bool´	´	∑ ª
IsNonDeductible´	´	º À
=´	´	Ã Õ
false´	´	Œ ”
,´	´	” ‘
bool´	´	’ Ÿ%
IsNonDomiciledService´	´	⁄ Ô
=´	´	 Ò
false´	´	Ú ˜
,´	´	˜ ¯
string´	´	˘ ˇ
?´	´	ˇ Ä#
ForeignSupplierName´	´	Å î
=´	´	ï ñ
null´	´	ó õ
,´	´	õ ú
string´	´	ù £
?´	´	£ §&
ForeignSupplierCountry´	´	• ª
=´	´	º Ω
null´	´	æ ¬
)´	´	¬ √
;´	´	√ ƒ
public¨	¨	 
sealed
¨	¨	 
record
¨	¨	 "
EndRecurrenceRequest
¨	¨	 )
(
¨	¨	) *
[
¨	¨	* +
property
¨	¨	+ 3
:
¨	¨	3 4
JsonRequired
¨	¨	5 A
]
¨	¨	A B
DateOnly
¨	¨	C K
EndsAt
¨	¨	L R
)
¨	¨	R S
;
¨	¨	S T
public≠	≠	 
sealed
≠	≠	 
record
≠	≠	 !
ExpensePatchRequest
≠	≠	 (
(
≠	≠	( )
string
≠	≠	) /
?
≠	≠	/ 0
Description
≠	≠	1 <
,
≠	≠	< =
Guid
≠	≠	> B
?
≠	≠	B C

CategoryId
≠	≠	D N
,
≠	≠	N O
ExpenseType
≠	≠	P [
?
≠	≠	[ \
Type
≠	≠	] a
,
≠	≠	a b
decimal
≠	≠	c j
?
≠	≠	j k
Amount
≠	≠	l r
,
≠	≠	r s
string
≠	≠	t z
?
≠	≠	z {
Currency≠	≠	| Ñ
,≠	≠	Ñ Ö
DateOnly≠	≠	Ü é
?≠	≠	é è
Date≠	≠	ê î
,≠	≠	î ï
bool≠	≠	ñ ö
?≠	≠	ö õ
	Recurring≠	≠	ú •
,≠	≠	• ¶
BillingCycle≠	≠	ß ≥
?≠	≠	≥ ¥
RecurrenceCycle≠	≠	µ ƒ
,≠	≠	ƒ ≈
bool≠	≠	∆  
?≠	≠	  À
IsNonDeductible≠	≠	Ã €
=≠	≠	‹ ›
null≠	≠	ﬁ ‚
,≠	≠	‚ „
bool≠	≠	‰ Ë
?≠	≠	Ë È%
IsNonDomiciledService≠	≠	Í ˇ
=≠	≠	Ä Å
null≠	≠	Ç Ü
,≠	≠	Ü á
string≠	≠	à é
?≠	≠	é è#
ForeignSupplierName≠	≠	ê £
=≠	≠	§ •
null≠	≠	¶ ™
,≠	≠	™ ´
string≠	≠	¨ ≤
?≠	≠	≤ ≥&
ForeignSupplierCountry≠	≠	¥  
=≠	≠	À Ã
null≠	≠	Õ —
)≠	≠	— “
;≠	≠	“ ”◊
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