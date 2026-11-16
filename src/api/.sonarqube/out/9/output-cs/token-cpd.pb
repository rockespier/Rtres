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
;´´◊ ÿ ë
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
varFF 
	paidYearsFF 
=FF 
itemFF 
.FF 
BillingCycleFF )
==FF* ,
BillingCycleFF- 9
.FF9 :
AnualFF: ?
?FF@ A
MathFFB F
.FFF G
ClampFFG L
(FFL M
yearsFFM R
??FFS U
(FFV W
transactionKeyFFW e
==FFf h
itemFFi m
.FFm n
PayPalOrderIdFFn {
?FF| }
item	FF~ Ç
.
FFÇ É
PayPalOrderYears
FFÉ ì
:
FFî ï
null
FFñ ö
)
FFö õ
??
FFú û
$num
FFü †
,
FF† °
$num
FF¢ £
,
FF£ §"
ClientProductPricing
FF• π
.
FFπ ∫
MaxPrepaidYears
FF∫ …
)
FF…  
:
FFÀ Ã
$num
FFÕ Œ
;
FFŒ œ
varGG 
transactionGG 
=GG 
newGG 
PaymentTransactionGG 0
{GG1 2
ClientIdGG3 ;
=GG< =
itemGG> B
.GGB C
ClientIdGGC K
,GGK L
ClientProductIdGGM \
=GG] ^
itemGG_ c
.GGc d
IdGGd f
,GGf g*
PayPalOrderIdOrSubscriptionId	GGh Ö
=
GGÜ á
transactionKey
GGà ñ
,
GGñ ó
Amount
GGò û
=
GGü †
amount
GG° ß
,
GGß ®
Currency
GG© ±
=
GG≤ ≥
currency
GG¥ º
??
GGΩ ø
item
GG¿ ƒ
.
GGƒ ≈
Product
GG≈ Ã
?
GGÃ Õ
.
GGÕ Œ
Currency
GGŒ ÷
??
GG◊ Ÿ
$str
GG⁄ ﬂ
,
GGﬂ ‡
Status
GG· Á
=
GGË È
$str
GGÍ ı
,
GGı ˆ
Method
GG˜ ˝
=
GG˛ ˇ
method
GGÄ Ü
,
GGÜ á
	CreatedAt
GGà ë
=
GGí ì
when
GGî ò
,
GGò ô
Years
GGö ü
=
GG† °
	paidYears
GG¢ ´
}
GG¨ ≠
;
GG≠ Æ
transactionHH 
.HH 
InternalCodeHH  
=HH! "
awaitHH# (
dbHH) +
.HH+ ,!
NextInternalCodeAsyncHH, A
(HHA B
ctHHB D
)HHD E
;HHE F
transactionII 
.II 
	AmountPenII 
=II 
amountII  &
*II' (
awaitII) .
dbII/ 1
.II1 2
RateToPenAsyncII2 @
(II@ A
transactionIIA L
.IIL M
CurrencyIIM U
,IIU V
DateOnlyIIW _
.II_ `
FromDateTimeII` l
(IIl m
transactionIIm x
.IIx y
	CreatedAt	IIy Ç
)
IIÇ É
,
IIÉ Ñ
ct
IIÖ á
)
IIá à
;
IIà â
dbJJ 

.JJ
 
PaymentTransactionsJJ 
.JJ 
AddJJ "
(JJ" #
transactionJJ# .
)JJ. /
;JJ/ 0
itemKK 
.KK 
StatusKK 
=KK 
ClientProductStatusKK )
.KK) *
ActivoKK* 0
;KK0 1
ExtendPeriodMM 
(MM 
itemMM 
,MM 
whenMM 
)MM  
;MM  !
itemNN 
.NN 
OnPaymentAppliedNN 
(NN 
)NN 
;NN  
forOO 
(OO 
varOO 
yearOO 
=OO 
$numOO 
;OO 
yearOO 
<OO  !
	paidYearsOO" +
;OO+ ,
yearOO- 1
++OO1 3
)OO3 4
ExtendPeriodOO5 A
(OOA B
itemOOB F
,OOF G
whenOOH L
)OOL M
;OOM N
tryPP 
{PP 
awaitPP 
dbPP 
.PP 
SaveChangesAsyncPP '
(PP' (
ctPP( *
)PP* +
;PP+ ,
}PP- .
catchQQ 
(QQ 
DbUpdateExceptionQQ  
)QQ  !
{RR 	
ifTT 
(TT 
!TT 
awaitTT 
PaymentExistsAsyncTT )
(TT) *
transactionKeyTT* 8
,TT8 9
ctTT: <
)TT< =
)TT= >
throwTT? D
;TTD E
dbUU 
.UU 
EntryUU 
(UU 
transactionUU  
)UU  !
.UU! "
StateUU" '
=UU( )
EntityStateUU* 5
.UU5 6
DetachedUU6 >
;UU> ?
awaitVV 
dbVV 
.VV 
EntryVV 
(VV 
itemVV 
)VV  
.VV  !
ReloadAsyncVV! ,
(VV, -
ctVV- /
)VV/ 0
;VV0 1
returnWW 
falseWW 
;WW 
}XX 	
awaitZZ 
taxDocumentsZZ 
.ZZ  
IssueForPaymentAsyncZZ /
(ZZ/ 0
transactionZZ0 ;
,ZZ; <
ctZZ= ?
)ZZ? @
;ZZ@ A
if[[ 

([[ 
await[[ 
db[[ 
.[[ 
Clients[[ 
.[[ 
	FindAsync[[ &
([[& '
[[[' (
item[[( ,
.[[, -
ClientId[[- 5
][[5 6
,[[6 7
ct[[8 :
)[[: ;
is[[< >
Client[[? E
client[[F L
)[[L M
await\\ 
notifications\\ 
.\\  
	SendAsync\\  )
(\\) *
client\\* 0
,\\0 1
new\\2 5
Notification\\6 B
(\\B C
NotificationType\\C S
.\\S T
PaymentReceived\\T c
,\\c d
new\\e h
(\\h i
)\\i j
{]] 
[^^ 
$str^^ 
]^^ 
=^^ 
item^^ "
.^^" #
Product^^# *
?^^* +
.^^+ ,
Name^^, 0
??^^1 3
$str^^4 6
,^^6 7
[__ 
$str__ 
]__ 
=__ 
amount__ #
.__# $
ToString__$ ,
(__, -
CultureInfo__- 8
.__8 9
InvariantCulture__9 I
)__I J
,__J K
[`` 
$str`` 
]`` 
=`` 
transaction`` *
.``* +
Currency``+ 3
,``3 4
}aa 
,aa 
$"aa 
$straa 
{aa 
transactionKeyaa (
}aa( )
"aa) *
)aa* +
,aa+ ,
ctaa- /
)aa/ 0
;aa0 1
returnbb 
truebb 
;bb 
}cc 
publickk 

statickk 
voidkk 
ExtendPeriodkk #
(kk# $
ClientProductkk$ 1
itemkk2 6
,kk6 7
DateTimekk8 @
nowkkA D
)kkD E
{ll 
switchmm 
(mm 
itemmm 
.mm 
BillingCyclemm !
)mm! "
{nn 	
caseoo 
BillingCycleoo 
.oo 
Anualoo #
:oo# $
itempp 
.pp 
RenewsAtpp 
=pp 
(pp  !
itempp! %
.pp% &
RenewsAtpp& .
ispp/ 1
DateTimepp2 :
renewsAtpp; C
&&ppD F
renewsAtppG O
>ppP Q
nowppR U
?ppV W
renewsAtppX `
:ppa b
nowppc f
)ppf g
.ppg h
AddYearspph p
(ppp q
$numppq r
)ppr s
;pps t
breakqq 
;qq 
caserr 
varrr 
cyclerr 
whenrr 
cyclerr  %
.rr% &
SubscriptionMonthsrr& 8
(rr8 9
)rr9 :
isrr; =
intrr> A
monthsrrB H
:rrH I
itemss 
.ss 
NextChargeAtss !
=ss" #
nowss$ '
.ss' (
	AddMonthsss( 1
(ss1 2
monthsss2 8
)ss8 9
;ss9 :
breaktt 
;tt 
}uu 	
}vv 
public|| 

static|| 
void|| 
RollbackPeriod|| %
(||% &
ClientProduct||& 3
item||4 8
,||8 9
int||: =
years||> C
,||C D
bool||E I
isLatestPayment||J Y
)||Y Z
{}} 
switch~~ 
(~~ 
item~~ 
.~~ 
BillingCycle~~ !
)~~! "
{ 	
case
ÄÄ 
BillingCycle
ÄÄ 
.
ÄÄ 
Anual
ÄÄ #
:
ÄÄ# $
item
ÅÅ 
.
ÅÅ 
RenewsAt
ÅÅ 
=
ÅÅ 
item
ÅÅ  $
.
ÅÅ$ %
RenewsAt
ÅÅ% -
?
ÅÅ- .
.
ÅÅ. /
AddYears
ÅÅ/ 7
(
ÅÅ7 8
-
ÅÅ8 9
years
ÅÅ9 >
)
ÅÅ> ?
;
ÅÅ? @
break
ÇÇ 
;
ÇÇ 
case
ÉÉ 
var
ÉÉ 
cycle
ÉÉ 
when
ÉÉ 
cycle
ÉÉ  %
.
ÉÉ% & 
SubscriptionMonths
ÉÉ& 8
(
ÉÉ8 9
)
ÉÉ9 :
is
ÉÉ; =
int
ÉÉ> A
months
ÉÉB H
&&
ÉÉI K
isLatestPayment
ÉÉL [
:
ÉÉ[ \
item
ÑÑ 
.
ÑÑ 
NextChargeAt
ÑÑ !
=
ÑÑ" #
item
ÑÑ$ (
.
ÑÑ( )
NextChargeAt
ÑÑ) 5
?
ÑÑ5 6
.
ÑÑ6 7
	AddMonths
ÑÑ7 @
(
ÑÑ@ A
-
ÑÑA B
months
ÑÑB H
)
ÑÑH I
;
ÑÑI J
break
ÖÖ 
;
ÖÖ 
}
ÜÜ 	
}
áá 
private
ää 
async
ää 
Task
ää 
<
ää 
bool
ää 
>
ää  
PaymentExistsAsync
ää /
(
ää/ 0
string
ää0 6
transactionKey
ää7 E
,
ääE F
CancellationToken
ääG X
ct
ääY [
)
ää[ \
=>
ää] _
await
ãã 
db
ãã 
.
ãã !
PaymentTransactions
ãã $
.
ãã$ %
AnyAsync
ãã% -
(
ãã- .
x
ãã. /
=>
ãã0 2
x
ãã3 4
.
ãã4 5+
PayPalOrderIdOrSubscriptionId
ãã5 R
==
ããS U
transactionKey
ããV d
,
ããd e
ct
ããf h
)
ããh i
||
åå 

await
åå 
db
åå 
.
åå 
PaymentReversals
åå $
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
åå4 5

PaymentKey
åå5 ?
==
åå@ B
transactionKey
ååC Q
&&
ååR T
x
ååU V
.
ååV W
Method
ååW ]
==
åå^ `
PaymentMethods
ååa o
.
ååo p
PayPal
ååp v
,
ååv w
ct
ååx z
)
ååz {
;
åå{ |
}çç 
publicìì 
sealed
ìì 
record
ìì 
PaymentOptions
ìì #
(
ìì# $
string
ìì$ *
Method
ìì+ 1
=
ìì2 3
PaymentMethods
ìì4 B
.
ììB C
PayPal
ììC I
,
ììI J
DateTime
ììK S
?
ììS T
PaidAt
ììU [
=
ìì\ ]
null
ìì^ b
,
ììb c
int
ììd g
?
ììg h
Years
ììi n
=
ììo p
null
ììq u
)
ììu v
;
ììv w∫Q
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
}00 ¿^
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
;DD 
returnEE 
dateEE 
<EE 
todayEE 
?EE 
ClientProductStatusEE 1
.EE1 2
VencidoEE2 9
:EE: ;
dateEE< @
<EEA B
todayEEC H
.EEH I
AddDaysEEI P
(EEP Q
ThresholdDaysEEQ ^
.EE^ _
MaxEE_ b
(EEb c
)EEc d
+EEe f
$numEEg h
)EEh i
?EEj k
ClientProductStatusEEl 
.	EE Ä
	PorVencer
EEÄ â
:
EEä ã!
ClientProductStatus
EEå ü
.
EEü †
Activo
EE† ¶
;
EE¶ ß
}FF 
}GG Û;
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
}11 ∆(
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
}&& Ëa
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
}AA °ã
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
GG˛ ˇ˘≈
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
varEE 
	componentEE 
=EE 
projectEE 
.EE  
RepositoriesEE  ,
.EE, -
CountEE- 2
>EE3 4
$numEE5 6
?EE7 8
projectEE9 @
.EE@ A
RepositoriesEEA M
.EEM N
RepositoryForEEN [
(EE[ \
tEE\ ]
.EE] ^
RepositoryIdEE^ j
)EEj k
isEEl n
{EEo p
}EEq r
rEEs t
?EEu v
rEEw x
.EEx y
LabelEEy ~
??	EE Å
r
EEÇ É
.
EEÉ Ñ
Name
EEÑ à
:
EEâ ä
null
EEã è
:
EEê ë
null
EEí ñ
;
EEñ ó
varFF 
	createdByFF 
=FF 
awaitFF 
dbFF  
.FF  !
UserAccountsFF! -
.FF- .
WhereFF. 3
(FF3 4
xFF4 5
=>FF6 8
xFF9 :
.FF: ;
IdFF; =
==FF> @
tFFA B
.FFB C
CreatedByUserIdFFC R
)FFR S
.FFS T
SelectFFT Z
(FFZ [
xFF[ \
=>FF] _
xFF` a
.FFa b
NameFFb f
==FFg i
$strFFj l
?FFm n
xFFo p
.FFp q
EmailFFq v
:FFw x
xFFy z
.FFz {
NameFF{ 
)	FF Ä
.
FFÄ Å"
SingleOrDefaultAsync
FFÅ ï
(
FFï ñ
ct
FFñ ò
)
FFò ô
;
FFô ö
varGG 
attachmentsGG 
=GG 
awaitGG 
dbGG  "
.GG" #
TicketAttachmentsGG# 4
.GG4 5
WhereGG5 :
(GG: ;
xGG; <
=>GG= ?
xGG@ A
.GGA B
TicketIdGGB J
==GGK M
idGGN P
)GGP Q
.GGQ R
OrderByGGR Y
(GGY Z
xGGZ [
=>GG\ ^
xGG_ `
.GG` a
	CreatedAtGGa j
)GGj k
.GGk l
SelectGGl r
(GGr s
xGGs t
=>GGu w
newGGx { 
TicketAttachmentDto	GG| è
(
GGè ê
x
GGê ë
.
GGë í
Id
GGí î
,
GGî ï
x
GGñ ó
.
GGó ò
FileName
GGò †
,
GG† °
x
GG¢ £
.
GG£ §
ContentType
GG§ Ø
,
GGØ ∞
x
GG± ≤
.
GG≤ ≥
	SizeBytes
GG≥ º
)
GGº Ω
)
GGΩ æ
.
GGæ ø
ToListAsync
GGø  
(
GG  À
ct
GGÀ Õ
)
GGÕ Œ
;
GGŒ œ
varHH 
commentsHH 
=HH 
awaitHH 
ToCommentDtosHH *
(HH* +
dbHH+ -
,HH- .
dbHH/ 1
.HH1 2
TicketCommentsHH2 @
.HH@ A
WhereHHA F
(HHF G
xHHG H
=>HHI K
xHHL M
.HHM N
TicketIdHHN V
==HHW Y
idHHZ \
)HH\ ]
.HH] ^
OrderByHH^ e
(HHe f
xHHf g
=>HHh j
xHHk l
.HHl m
	CreatedAtHHm v
)HHv w
)HHw x
.HHx y
ToListAsync	HHy Ñ
(
HHÑ Ö
ct
HHÖ á
)
HHá à
;
HHà â
returnII 
OkII 
(II 
newII 
{II 
ticketII 
=II  
tII! "
,II" #
projectNameII$ /
=II0 1
projectII2 9
.II9 :
NameII: >
,II> ?
componentNameII@ M
=IIN O
	componentIIP Y
,IIY Z
createdByNameII[ h
=IIi j
	createdByIIk t
,IIt u
attachments	IIv Å
,
IIÅ Ç
comments
IIÉ ã
}
IIå ç
)
IIç é
;
IIé è
}JJ 
[LL 
HttpGetLL 
(LL 
$strLL @
)LL@ A
]LLA B
publicMM 

asyncMM 
TaskMM 
<MM 
IActionResultMM #
>MM# $

AttachmentMM% /
(MM/ 0
GuidMM0 4
idMM5 7
,MM7 8
GuidMM9 =
attachmentIdMM> J
,MMJ K
GuidMML P
?MMP Q
clientIdMMR Z
,MMZ [
CancellationTokenMM\ m
ctMMn p
)MMp q
{NN 
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
aQQ 
=QQ 
awaitQQ 
dbQQ 
.QQ 
TicketAttachmentsQQ *
.QQ* + 
SingleOrDefaultAsyncQQ+ ?
(QQ? @
xQQ@ A
=>QQB D
xQQE F
.QQF G
IdQQG I
==QQJ L
attachmentIdQQM Y
&&QQZ \
xQQ] ^
.QQ^ _
TicketIdQQ_ g
==QQh j
idQQk m
&&QQn p
dbQQq s
.QQs t
TicketsQQt {
.QQ{ |
AnyQQ| 
(	QQ Ä
t
QQÄ Å
=>
QQÇ Ñ
t
QQÖ Ü
.
QQÜ á
Id
QQá â
==
QQä å
id
QQç è
&&
QQê í
(
QQì î
	anyClient
QQî ù
||
QQû †
t
QQ° ¢
.
QQ¢ £
ClientId
QQ£ ´
==
QQ¨ Æ
client
QQØ µ
)
QQµ ∂
)
QQ∂ ∑
,
QQ∑ ∏
ct
QQπ ª
)
QQª º
;
QQº Ω
returnRR 
aRR 
isRR 
nullRR 
?RR 
NotFoundRR #
(RR# $
)RR$ %
:RR& '
FileRR( ,
(RR, -
aRR- .
.RR. /
ContentRR/ 6
,RR6 7
aRR8 9
.RR9 :
ContentTypeRR: E
,RRE F
aRRG H
.RRH I
FileNameRRI Q
)RRQ R
;RRR S
}SS 
[TT 
HttpPostTT 
(TT 
$strTT *
)TT* +
]TT+ ,
publicUU 

asyncUU 
TaskUU 
<UU 
IActionResultUU #
>UU# $

AddCommentUU% /
(UU/ 0
GuidUU0 4
idUU5 7
,UU7 8&
CreateTicketCommentRequestUU9 S
rUUT U
,UUU V
CancellationTokenUUW h
ctUUi k
)UUk l
{VV 
ifWW 

(WW 
IsSuperAdminWW 
)WW 
returnWW  
ForbidWW! '
(WW' (
)WW( )
;WW) *
varXX 
errorXX 
=XX 
ResolveClientIdXX #
(XX# $
nullXX$ (
,XX( )
outXX* -
varXX. 1
clientXX2 8
)XX8 9
;XX9 :
ifXX; =
(XX> ?
errorXX? D
isXXE G
notXXH K
nullXXL P
)XXP Q
returnXXR X
errorXXY ^
;XX^ _
ifYY 

(YY 
stringYY 
.YY 
IsNullOrWhiteSpaceYY %
(YY% &
rYY& '
.YY' (
BodyYY( ,
)YY, -
)YY- .
returnYY/ 5

BadRequestYY6 @
(YY@ A
newYYA D
{YYE F
messageYYG N
=YYO P
$strYYQ v
}YYw x
)YYx y
;YYy z
varZZ 
ticketZZ 
=ZZ 
awaitZZ 
dbZZ 
.ZZ 
TicketsZZ %
.ZZ% & 
SingleOrDefaultAsyncZZ& :
(ZZ: ;
xZZ; <
=>ZZ= ?
xZZ@ A
.ZZA B
IdZZB D
==ZZE G
idZZH J
&&ZZK M
xZZN O
.ZZO P
ClientIdZZP X
==ZZY [
clientZZ\ b
,ZZb c
ctZZd f
)ZZf g
;ZZg h
ifZZi k
(ZZl m
ticketZZm s
isZZt v
nullZZw {
)ZZ{ |
return	ZZ} É
NotFound
ZZÑ å
(
ZZå ç
)
ZZç é
;
ZZé è
var[[ 
comment[[ 
=[[ 
new[[ 
TicketComment[[ '
{[[( )
TicketId[[* 2
=[[3 4
id[[5 7
,[[7 8
AuthorUserId[[9 E
=[[F G
UserId[[H N
,[[N O
Body[[P T
=[[U V
r[[W X
.[[X Y
Body[[Y ]
.[[] ^
Trim[[^ b
([[b c
)[[c d
}[[e f
;[[f g
db\\ 

.\\
 
TicketComments\\ 
.\\ 
Add\\ 
(\\ 
comment\\ %
)\\% &
;\\& '
ticket\\( .
.\\. /
	UpdatedAt\\/ 8
=\\9 :
DateTime\\; C
.\\C D
UtcNow\\D J
;\\J K
await\\L Q
db\\R T
.\\T U
SaveChangesAsync\\U e
(\\e f
ct\\f h
)\\h i
;\\i j
jobs]] 
.]] 
Enqueue]] 
<]] 
GitHubIssueSyncJob]] '
>]]' (
(]]( )
j]]) *
=>]]+ -
j]]. /
.]]/ 0
PostCommentAsync]]0 @
(]]@ A
comment]]A H
.]]H I
Id]]I K
,]]K L
CancellationToken]]M ^
.]]^ _
None]]_ c
)]]c d
)]]d e
;]]e f
return^^ 
Ok^^ 
(^^ 
await^^ 
ToCommentDtos^^ %
(^^% &
db^^& (
,^^( )
db^^* ,
.^^, -
TicketComments^^- ;
.^^; <
Where^^< A
(^^A B
x^^B C
=>^^D F
x^^G H
.^^H I
Id^^I K
==^^L N
comment^^O V
.^^V W
Id^^W Y
)^^Y Z
)^^Z [
.^^[ \
SingleAsync^^\ g
(^^g h
ct^^h j
)^^j k
)^^k l
;^^l m
}__ 
internalaa 
staticaa 

IQueryableaa 
<aa 
TicketCommentDtoaa /
>aa/ 0
ToCommentDtosaa1 >
(aa> ?
RtresDbContextaa? M
dbaaN P
,aaP Q

IQueryableaaR \
<aa\ ]
TicketCommentaa] j
>aaj k
commentsaal t
)aat u
=>aav x
comments	aay Å
.bb 	
Selectbb	 
(bb 
xbb 
=>bb 
newbb 
TicketCommentDtobb )
(bb) *
xbb* +
.bb+ ,
Idbb, .
,bb. /
xbb0 1
.bb1 2
Bodybb2 6
,bb6 7
xbb8 9
.bb9 :

FromGithubbb: D
,bbD E
xbbF G
.bbG H

FromGithubbbH R
?bbS T
xbbU V
.bbV W
GithubAuthorLoginbbW h
:bbi j
dbbbk m
.bbm n
UserAccountsbbn z
.bbz {
Where	bb{ Ä
(
bbÄ Å
u
bbÅ Ç
=>
bbÉ Ö
u
bbÜ á
.
bbá à
Id
bbà ä
==
bbã ç
x
bbé è
.
bbè ê
AuthorUserId
bbê ú
)
bbú ù
.
bbù û
Select
bbû §
(
bb§ •
u
bb• ¶
=>
bbß ©
u
bb™ ´
.
bb´ ¨
Role
bb¨ ∞
==
bb± ≥
UserRole
bb¥ º
.
bbº Ω

SuperAdmin
bbΩ «
?
bb» …
$str
bb  —
:
bb“ ”
u
bb‘ ’
.
bb’ ÷
Name
bb÷ ⁄
==
bb€ ›
$str
bbﬁ ‡
?
bb· ‚
u
bb„ ‰
.
bb‰ Â
Email
bbÂ Í
:
bbÎ Ï
u
bbÌ Ó
.
bbÓ Ô
Name
bbÔ Û
)
bbÛ Ù
.
bbÙ ı
FirstOrDefault
bbı É
(
bbÉ Ñ
)
bbÑ Ö
,
bbÖ Ü
x
bbá à
.
bbà â
	CreatedAt
bbâ í
)
bbí ì
)
bbì î
;
bbî ï
publiccc 

constcc 
intcc 
MaxAttachmentscc #
=cc$ %
$numcc& '
;cc' (
publicdd 

constdd 
longdd 
MaxAttachmentBytesdd (
=dd) *
$numdd+ -
*dd. /
$numdd0 4
*dd5 6
$numdd7 ;
;dd; <
[gg 
HttpPostgg 
(gg 
$strgg 
)gg 
,gg 
RequestSizeLimitgg *
(gg* +
$numgg+ 5
)gg5 6
,gg6 7
RequestFormLimitsgg8 I
(ggI J$
MultipartBodyLengthLimitggJ b
=ggc d
$numgge o
)ggo p
]ggp q
publichh 

asynchh 
Taskhh 
<hh 
IActionResulthh #
>hh# $
CreateTickethh% 1
(hh1 2
[hh2 3
FromFormhh3 ;
]hh; <
CreateTicketRequesthh= P
rhhQ R
,hhR S
GuidhhT X
?hhX Y
clientIdhhZ b
,hhb c
CancellationTokenhhd u
cthhv x
,hhx y
[hhz {
FromForm	hh{ É
]
hhÉ Ñ
List
hhÖ â
<
hhâ ä
	IFormFile
hhä ì
>
hhì î
?
hhî ï
files
hhñ õ
=
hhú ù
null
hhû ¢
)
hh¢ £
{ii 
varjj 
errorjj 
=jj 
ResolveClientIdjj #
(jj# $
clientIdjj$ ,
,jj, -
outjj. 1
varjj2 5
clientIdValuejj6 C
)jjC D
;jjD E
ifjjF H
(jjI J
errorjjJ O
isjjP R
notjjS V
nulljjW [
)jj[ \
returnjj] c
errorjjd i
;jji j
fileskk 
??=kk 
[kk 
]kk 
;kk 
ifll 

(ll 
filesll 
.ll 
Countll 
>ll 
MaxAttachmentsll (
)ll( )
returnll* 0

BadRequestll1 ;
(ll; <
newll< ?
{ll@ A
messagellB I
=llJ K
$"llL N
$strllN U
{llU V
MaxAttachmentsllV d
}lld e
$strlle z
"llz {
}ll| }
)ll} ~
;ll~ 
ifmm 

(mm 
filesmm 
.mm 
FirstOrDefaultmm  
(mm  !
xmm! "
=>mm# %
xmm& '
.mm' (
Lengthmm( .
==mm/ 1
$nummm2 3
||mm4 6
xmm7 8
.mm8 9
Lengthmm9 ?
>mm@ A
MaxAttachmentBytesmmB T
)mmT U
ismmV X
{mmY Z
}mm[ \
invalidmm] d
)mmd e
returnmmf l

BadRequestmmm w
(mmw x
newmmx {
{mm| }
message	mm~ Ö
=
mmÜ á
$"
mmà ä
$str
mmä ã
{
mmã å
invalid
mmå ì
.
mmì î
FileName
mmî ú
}
mmú ù
$str
mmù æ
"
mmæ ø
}
mm¿ ¡
)
mm¡ ¬
;
mm¬ √
varnn 
projectnn 
=nn 
awaitnn 
dbnn 
.nn 
Projectsnn '
.nn' (
Includenn( /
(nn/ 0
xnn0 1
=>nn2 4
xnn5 6
.nn6 7
Repositoriesnn7 C
)nnC D
.nnD E 
SingleOrDefaultAsyncnnE Y
(nnY Z
xnnZ [
=>nn\ ^
xnn_ `
.nn` a
Idnna c
==nnd f
rnng h
.nnh i
	ProjectIdnni r
&&nns u
xnnv w
.nnw x
ClientId	nnx Ä
==
nnÅ É
clientIdValue
nnÑ ë
,
nnë í
ct
nnì ï
)
nnï ñ
;
nnñ ó
if
nnò ö
(
nnõ ú
project
nnú £
is
nn§ ¶
null
nnß ´
)
nn´ ¨
return
nn≠ ≥
NotFound
nn¥ º
(
nnº Ω
)
nnΩ æ
;
nnæ ø
ifoo 

(oo 
roo 
.oo 
RepositoryIdoo 
isoo 
Guidoo "
repositoryIdoo# /
&&oo0 2
projectoo3 :
.oo: ;
Repositoriesoo; G
.ooG H
AllooH K
(ooK L
xooL M
=>ooN P
xooQ R
.ooR S
IdooS U
!=ooV X
repositoryIdooY e
)ooe f
)oof g
returnooh n

BadRequestooo y
(ooy z
newooz }
{oo~ 
message
ooÄ á
=
ooà â
$str
ooä ¥
}
ooµ ∂
)
oo∂ ∑
;
oo∑ ∏
ifpp 

(pp 
rpp 
.pp 
ClientProductIdpp 
ispp  
Guidpp! %
clientProductIdpp& 5
&&pp6 8
!pp9 :
awaitpp: ?
dbpp@ B
.ppB C
ClientProductsppC Q
.ppQ R
AnyAsyncppR Z
(ppZ [
xpp[ \
=>pp] _
xpp` a
.ppa b
Idppb d
==ppe g
clientProductIdpph w
&&ppx z
xpp{ |
.pp| }
ClientId	pp} Ö
==
ppÜ à
clientIdValue
ppâ ñ
&&
ppó ô
x
ppö õ
.
ppõ ú
	ProjectId
ppú •
==
pp¶ ®
r
pp© ™
.
pp™ ´
	ProjectId
pp´ ¥
&&
ppµ ∑
x
pp∏ π
.
ppπ ∫
Product
pp∫ ¡
!
pp¡ ¬
.
pp¬ √
AllowsTickets
pp√ –
,
pp– —
ct
pp“ ‘
)
pp‘ ’
)
pp’ ÷
returnqq 

BadRequestqq 
(qq 
newqq !
{qq" #
messageqq$ +
=qq, -
$strqq. O
}qqP Q
)qqQ R
;qqR S
varrr 
ticketrr 
=rr 
newrr 
Ticketrr 
{rr  !
Coderr" &
=rr' (
$"rr) +
$strrr+ .
{rr. /
$numrr/ 2
+rr3 4
awaitrr5 :
dbrr; =
.rr= >
Ticketsrr> E
.rrE F

CountAsyncrrF P
(rrP Q
ctrrQ S
)rrS T
}rrT U
"rrU V
,rrV W
ClientIdrrX `
=rra b
clientIdValuerrc p
,rrp q
	ProjectIdrrr {
=rr| }
rrr~ 
.	rr Ä
	ProjectId
rrÄ â
,
rrâ ä
RepositoryId
rrã ó
=
rrò ô
r
rrö õ
.
rrõ ú
RepositoryId
rrú ®
,
rr® ©
ClientProductId
rr™ π
=
rr∫ ª
r
rrº Ω
.
rrΩ æ
ClientProductId
rræ Õ
,
rrÕ Œ
CreatedByUserId
rrœ ﬁ
=
rrﬂ ‡
UserId
rr· Á
,
rrÁ Ë
Type
rrÈ Ì
=
rrÓ Ô
r
rr Ò
.
rrÒ Ú
Type
rrÚ ˆ
,
rrˆ ˜
Title
rr¯ ˝
=
rr˛ ˇ
r
rrÄ Å
.
rrÅ Ç
Title
rrÇ á
,
rrá à
Description
rrâ î
=
rrï ñ
r
rró ò
.
rrò ô
Description
rrô §
,
rr§ •
CurrentBehavior
rr¶ µ
=
rr∂ ∑
r
rr∏ π
.
rrπ ∫
CurrentBehavior
rr∫ …
,
rr…  
ExpectedBehavior
rrÀ €
=
rr‹ ›
r
rrﬁ ﬂ
.
rrﬂ ‡
ExpectedBehavior
rr‡ 
,
rr Ò
StepsToReproduce
rrÚ Ç
=
rrÉ Ñ
r
rrÖ Ü
.
rrÜ á
StepsToReproduce
rrá ó
,
rró ò
Environment
rrô §
=
rr• ¶
r
rrß ®
.
rr® ©
Environment
rr© ¥
,
rr¥ µ 
AcceptanceCriteria
rr∂ »
=
rr…  
r
rrÀ Ã
.
rrÃ Õ 
AcceptanceCriteria
rrÕ ﬂ
,
rrﬂ ‡
EstimatedImpact
rr· 
=
rrÒ Ú
r
rrÛ Ù
.
rrÙ ı
EstimatedImpact
rrı Ñ
}
rrÖ Ü
;
rrÜ á
dbss 

.ss
 
Ticketsss 
.ss 
Addss 
(ss 
ticketss 
)ss 
;ss 
foreachtt 
(tt 
vartt 
filett 
intt 
filestt "
)tt" #
{uu 	
usingvv 
varvv 
streamvv 
=vv 
newvv "
MemoryStreamvv# /
(vv/ 0
)vv0 1
;vv1 2
awaitvv3 8
filevv9 =
.vv= >
CopyToAsyncvv> I
(vvI J
streamvvJ P
,vvP Q
ctvvR T
)vvT U
;vvU V
dbww 
.ww 
TicketAttachmentsww  
.ww  !
Addww! $
(ww$ %
newww% (
TicketAttachmentww) 9
{ww: ;
TicketIdww< D
=wwE F
ticketwwG M
.wwM N
IdwwN P
,wwP Q
FileNamewwR Z
=ww[ \
Pathww] a
.wwa b
GetFileNamewwb m
(wwm n
filewwn r
.wwr s
FileNamewws {
)ww{ |
,ww| }
ContentType	ww~ â
=
wwä ã
string
wwå í
.
wwí ì 
IsNullOrWhiteSpace
wwì •
(
ww• ¶
file
ww¶ ™
.
ww™ ´
ContentType
ww´ ∂
)
ww∂ ∑
?
ww∏ π
$str
ww∫ ‘
:
ww’ ÷
file
ww◊ €
.
ww€ ‹
ContentType
ww‹ Á
,
wwÁ Ë
	SizeBytes
wwÈ Ú
=
wwÛ Ù
file
wwı ˘
.
ww˘ ˙
Length
ww˙ Ä
,
wwÄ Å
Content
wwÇ â
=
wwä ã
stream
wwå í
.
wwí ì
ToArray
wwì ö
(
wwö õ
)
wwõ ú
}
wwù û
)
wwû ü
;
wwü †
}xx 	
awaityy 
dbyy 
.yy 
SaveChangesAsyncyy !
(yy! "
ctyy" $
)yy$ %
;yy% &
jobszz 
.zz 
Enqueuezz 
<zz 
GitHubIssueSyncJobzz '
>zz' (
(zz( )
jzz) *
=>zz+ -
jzz. /
.zz/ 0
CreateIssueAsynczz0 @
(zz@ A
ticketzzA G
.zzG H
IdzzH J
,zzJ K
CancellationTokenzzL ]
.zz] ^
Nonezz^ b
)zzb c
)zzc d
;zzd e
if{{ 

({{ 
project{{ 
.{{ 
Repositories{{  
.{{  !
Count{{! &
=={{' )
$num{{* +
){{+ ,
await{{- 2#
NotifyPortalTicketAsync{{3 J
({{J K
ticket{{K Q
,{{Q R
project{{S Z
,{{Z [
ct{{\ ^
){{^ _
;{{_ `
await|| 
NotifyManagerAsync||  
(||  !
ticket||! '
,||' (
project||) 0
,||0 1
ct||2 4
)||4 5
;||5 6
return}} 
Created}} 
(}} 
$"}} 
$str}} &
{}}& '
ticket}}' -
.}}- .
Id}}. 0
}}}0 1
"}}1 2
,}}2 3
ticket}}4 :
)}}: ;
;}}; <
}~~ 
[
ÉÉ 
HttpGet
ÉÉ 
(
ÉÉ 
$str
ÉÉ 
)
ÉÉ 
]
ÉÉ 
public
ÑÑ 

async
ÑÑ 
Task
ÑÑ 
<
ÑÑ 
IActionResult
ÑÑ #
>
ÑÑ# $
Notifications
ÑÑ% 2
(
ÑÑ2 3
Guid
ÑÑ3 7
?
ÑÑ7 8
clientId
ÑÑ9 A
,
ÑÑA B
CancellationToken
ÑÑC T
ct
ÑÑU W
)
ÑÑW X
{
ÖÖ 
var
ÜÜ 
query
ÜÜ 
=
ÜÜ 
db
ÜÜ 
.
ÜÜ !
PortalNotifications
ÜÜ *
.
ÜÜ* +
AsQueryable
ÜÜ+ 6
(
ÜÜ6 7
)
ÜÜ7 8
;
ÜÜ8 9
if
áá 

(
áá 
!
áá 
(
áá 
IsSuperAdmin
áá 
&&
áá 
clientId
áá &
is
áá' )
null
áá* .
)
áá. /
)
áá/ 0
{
àà 	
var
ââ 
error
ââ 
=
ââ 
ResolveClientId
ââ '
(
ââ' (
clientId
ââ( 0
,
ââ0 1
out
ââ2 5
var
ââ6 9
id
ââ: <
)
ââ< =
;
ââ= >
if
ââ? A
(
ââB C
error
ââC H
is
ââI K
not
ââL O
null
ââP T
)
ââT U
return
ââV \
error
ââ] b
;
ââb c
query
ää 
=
ää 
query
ää 
.
ää 
Where
ää 
(
ää  
x
ää  !
=>
ää" $
x
ää% &
.
ää& '
ClientId
ää' /
==
ää0 2
id
ää3 5
&&
ää6 8
!
ää9 :
x
ää: ;
.
ää; <
ForStaff
ää< D
)
ääD E
;
ääE F
}
ãã 	
var
åå 
seenAt
åå 
=
åå 
await
åå 
db
åå 
.
åå 
UserAccounts
åå *
.
åå* +
Where
åå+ 0
(
åå0 1
x
åå1 2
=>
åå3 5
x
åå6 7
.
åå7 8
Id
åå8 :
==
åå; =
UserId
åå> D
)
ååD E
.
ååE F
Select
ååF L
(
ååL M
x
ååM N
=>
ååO Q
x
ååR S
.
ååS T!
NotificationsSeenAt
ååT g
)
ååg h
.
ååh i"
SingleOrDefaultAsync
ååi }
(
åå} ~
ctåå~ Ä
)ååÄ Å
;ååÅ Ç
var
çç 
unread
çç 
=
çç 
await
çç 
query
çç  
.
çç  !

CountAsync
çç! +
(
çç+ ,
x
çç, -
=>
çç. 0
seenAt
çç1 7
==
çç8 :
null
çç; ?
||
çç@ B
x
ççC D
.
ççD E
	CreatedAt
ççE N
>
ççO P
seenAt
ççQ W
,
ççW X
ct
ççY [
)
çç[ \
;
çç\ ]
var
éé 
rows
éé 
=
éé 
await
éé 
query
éé 
.
éé 
OrderByDescending
éé 0
(
éé0 1
x
éé1 2
=>
éé3 5
x
éé6 7
.
éé7 8
	CreatedAt
éé8 A
)
ééA B
.
ééB C
Take
ééC G
(
ééG H
$num
ééH J
)
ééJ K
.
èè 
Select
èè 
(
èè 
x
èè 
=>
èè 
new
èè 
{
èè 
x
èè  
.
èè  !
Id
èè! #
,
èè# $
x
èè% &
.
èè& '
ClientId
èè' /
,
èè/ 0
x
èè1 2
.
èè2 3
Type
èè3 7
,
èè7 8
x
èè9 :
.
èè: ;
ForStaff
èè; C
,
èèC D
x
èèE F
.
èèF G
DataJson
èèG O
,
èèO P
x
èèQ R
.
èèR S
	CreatedAt
èèS \
,
èè\ ]
Company
èè^ e
=
èèf g
db
èèh j
.
èèj k
Clients
èèk r
.
èèr s
Where
èès x
(
èèx y
c
èèy z
=>
èè{ }
c
èè~ 
.èè Ä
IdèèÄ Ç
==èèÉ Ö
xèèÜ á
.èèá à
ClientIdèèà ê
)èèê ë
.èèë í
Selectèèí ò
(èèò ô
cèèô ö
=>èèõ ù
cèèû ü
.èèü †
CompanyNameèè† ´
)èè´ ¨
.èè¨ ≠
FirstOrDefaultèè≠ ª
(èèª º
)èèº Ω
}èèæ ø
)èèø ¿
.
êê 
ToListAsync
êê 
(
êê 
ct
êê 
)
êê 
;
êê 
var
ëë 
items
ëë 
=
ëë 
rows
ëë 
.
ëë 
Select
ëë 
(
ëë  
x
ëë  !
=>
ëë" $
new
ëë% (
{
ëë) *
id
ëë+ -
=
ëë. /
x
ëë0 1
.
ëë1 2
Id
ëë2 4
,
ëë4 5
clientId
ëë6 >
=
ëë? @
x
ëëA B
.
ëëB C
ClientId
ëëC K
,
ëëK L
company
ëëM T
=
ëëU V
x
ëëW X
.
ëëX Y
Company
ëëY `
,
ëë` a
type
ëëb f
=
ëëg h
x
ëëi j
.
ëëj k
Type
ëëk o
,
ëëo p
forStaff
ëëq y
=
ëëz {
x
ëë| }
.
ëë} ~
ForStaffëë~ Ü
,ëëÜ á
	createdAtëëà ë
=ëëí ì
xëëî ï
.ëëï ñ
	CreatedAtëëñ ü
,ëëü †
unreadëë° ß
=ëë® ©
seenAtëë™ ∞
==ëë± ≥
nullëë¥ ∏
||ëëπ ª
xëëº Ω
.ëëΩ æ
	CreatedAtëëæ «
>ëë» …
seenAtëë  –
,ëë– —
dataëë“ ÷
=ëë◊ ÿ
JsonSerializerëëŸ Á
.ëëÁ Ë
DeserializeëëË Û
<ëëÛ Ù

DictionaryëëÙ ˛
<ëë˛ ˇ
stringëëˇ Ö
,ëëÖ Ü
stringëëá ç
>ëëç é
>ëëé è
(ëëè ê
xëëê ë
.ëëë í
DataJsonëëí ö
)ëëö õ
??ëëú û
[ëëü †
]ëë† °
}ëë¢ £
)ëë£ §
;ëë§ •
return
íí 
Ok
íí 
(
íí 
new
íí 
{
íí 
items
íí 
,
íí 
unread
íí %
}
íí& '
)
íí' (
;
íí( )
}
ìì 
[
ïï 
HttpPost
ïï 
(
ïï 
$str
ïï "
)
ïï" #
]
ïï# $
public
ññ 

async
ññ 
Task
ññ 
<
ññ 
IActionResult
ññ #
>
ññ# $
NotificationsSeen
ññ% 6
(
ññ6 7
CancellationToken
ññ7 H
ct
ññI K
)
ññK L
{
óó 
var
òò 
user
òò 
=
òò 
await
òò 
db
òò 
.
òò 
UserAccounts
òò (
.
òò( )"
SingleOrDefaultAsync
òò) =
(
òò= >
x
òò> ?
=>
òò@ B
x
òòC D
.
òòD E
Id
òòE G
==
òòH J
UserId
òòK Q
,
òòQ R
ct
òòS U
)
òòU V
;
òòV W
if
òòX Z
(
òò[ \
user
òò\ `
is
òòa c
null
òòd h
)
òòh i
return
òòj p
NotFound
òòq y
(
òòy z
)
òòz {
;
òò{ |
user
ôô 
.
ôô !
NotificationsSeenAt
ôô  
=
ôô! "
DateTime
ôô# +
.
ôô+ ,
UtcNow
ôô, 2
;
ôô2 3
await
ôô4 9
db
ôô: <
.
ôô< =
SaveChangesAsync
ôô= M
(
ôôM N
ct
ôôN P
)
ôôP Q
;
ôôQ R
return
ôôS Y
	NoContent
ôôZ c
(
ôôc d
)
ôôd e
;
ôôe f
}
öö 
private
úú 
async
úú 
Task
úú %
NotifyPortalTicketAsync
úú .
(
úú. /
Ticket
úú/ 5
ticket
úú6 <
,
úú< =
Project
úú> E
project
úúF M
,
úúM N
CancellationToken
úúO `
ct
úúa c
)
úúc d
{
ùù 
var
ûû 

staffEmail
ûû 
=
ûû 
configuration
ûû &
[
ûû& '
$str
ûû' A
]
ûûA B
is
ûûC E
{
ûûF G
Length
ûûH N
:
ûûN O
>
ûûP Q
$num
ûûR S
}
ûûT U

configured
ûûV `
?
ûûa b

configured
ûûc m
:
ûûn o
configuration
ûûp }
[
ûû} ~
$strûû~ â
]ûûâ ä
;ûûä ã
if
üü 

(
üü 
string
üü 
.
üü  
IsNullOrWhiteSpace
üü %
(
üü% &

staffEmail
üü& 0
)
üü0 1
)
üü1 2
{
üü3 4
logger
üü5 ;
.
üü; <

LogWarning
üü< F
(
üüF G
$strüüG à
,üüà â
ticketüüä ê
.üüê ë
Codeüüë ï
)üüï ñ
;üüñ ó
returnüüò û
;üüû ü
}üü† °
var
†† 
client
†† 
=
†† 
await
†† 
db
†† 
.
†† 
Clients
†† %
.
††% &
SingleAsync
††& 1
(
††1 2
x
††2 3
=>
††4 6
x
††7 8
.
††8 9
Id
††9 ;
==
††< >
ticket
††? E
.
††E F
ClientId
††F N
,
††N O
ct
††P R
)
††R S
;
††S T
await
°° 
notifications
°° 
.
°° 
	SendAsync
°° %
(
°°% &
client
°°& ,
,
°°, -
new
°°. 1
Notification
°°2 >
(
°°> ?
NotificationType
°°? O
.
°°O P
TicketCreated
°°P ]
,
°°] ^
new
°°_ b
(
°°b c
)
°°c d
{
°°e f
[
°°g h
$str
°°h r
]
°°r s
=
°°t u
ticket
°°v |
.
°°| }
Id
°°} 
.°° Ä
ToString°°Ä à
(°°à â
)°°â ä
,°°ä ã
[°°å ç
$str°°ç ì
]°°ì î
=°°ï ñ
ticket°°ó ù
.°°ù û
Code°°û ¢
,°°¢ £
[°°§ •
$str°°• ¨
]°°¨ ≠
=°°Æ Ø
ticket°°∞ ∂
.°°∂ ∑
Title°°∑ º
,°°º Ω
[°°æ ø
$str°°ø »
]°°» …
=°°  À
client°°Ã “
.°°“ ”
CompanyName°°” ﬁ
,°°ﬁ ﬂ
[°°‡ ·
$str°°· Í
]°°Í Î
=°°Ï Ì
project°°Ó ı
.°°ı ˆ
Name°°ˆ ˙
,°°˙ ˚
[°°¸ ˝
$str°°˝ É
]°°É Ñ
=°°Ö Ü
ticket°°á ç
.°°ç é
Description°°é ô
}°°ö õ
,°°õ ú
$"°°ù ü
$str°°ü Æ
{°°Æ Ø
ticket°°Ø µ
.°°µ ∂
Id°°∂ ∏
}°°∏ π
"°°π ∫
,°°∫ ª

staffEmail°°º ∆
)°°∆ «
,°°« »
ct°°… À
)°°À Ã
;°°Ã Õ
}
¢¢ 
private
•• 
async
•• 
Task
••  
NotifyManagerAsync
•• )
(
••) *
Ticket
••* 0
ticket
••1 7
,
••7 8
Project
••9 @
project
••A H
,
••H I
CancellationToken
••J [
ct
••\ ^
)
••^ _
{
¶¶ 
var
ßß 
creator
ßß 
=
ßß 
await
ßß 
db
ßß 
.
ßß 
UserAccounts
ßß +
.
ßß+ ,
AsNoTracking
ßß, 8
(
ßß8 9
)
ßß9 :
.
ßß: ;"
SingleOrDefaultAsync
ßß; O
(
ßßO P
x
ßßP Q
=>
ßßR T
x
ßßU V
.
ßßV W
Id
ßßW Y
==
ßßZ \
ticket
ßß] c
.
ßßc d
CreatedByUserId
ßßd s
&&
ßßt v
x
ßßw x
.
ßßx y
ClientIdßßy Å
==ßßÇ Ñ
ticketßßÖ ã
.ßßã å
ClientIdßßå î
,ßßî ï
ctßßñ ò
)ßßò ô
;ßßô ö
if
®® 

(
®® 
creator
®® 
?
®® 
.
®® 
	ManagerId
®® 
is
®® !
not
®®" %
Guid
®®& *
	managerId
®®+ 4
)
®®4 5
return
®®6 <
;
®®< =
var
©© 
manager
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
©©Z \
	managerId
©©] f
&&
©©g i
x
©©j k
.
©©k l
ClientId
©©l t
==
©©u w
ticket
©©x ~
.
©©~ 
ClientId©© á
&&©©à ä
x©©ã å
.©©å ç
IsActive©©ç ï
,©©ï ñ
ct©©ó ô
)©©ô ö
;©©ö õ
if
™™ 

(
™™ 
manager
™™ 
is
™™ 
null
™™ 
||
™™ 
string
™™ %
.
™™% & 
IsNullOrWhiteSpace
™™& 8
(
™™8 9
manager
™™9 @
.
™™@ A
Email
™™A F
)
™™F G
)
™™G H
return
™™I O
;
™™O P
var
´´ 
client
´´ 
=
´´ 
await
´´ 
db
´´ 
.
´´ 
Clients
´´ %
.
´´% &
SingleAsync
´´& 1
(
´´1 2
x
´´2 3
=>
´´4 6
x
´´7 8
.
´´8 9
Id
´´9 ;
==
´´< >
ticket
´´? E
.
´´E F
ClientId
´´F N
,
´´N O
ct
´´P R
)
´´R S
;
´´S T
var
¨¨ 
data
¨¨ 
=
¨¨ 
new
¨¨ 

Dictionary
¨¨ !
<
¨¨! "
string
¨¨" (
,
¨¨( )
string
¨¨* 0
>
¨¨0 1
{
¨¨2 3
[
¨¨4 5
$str
¨¨5 ?
]
¨¨? @
=
¨¨A B
ticket
¨¨C I
.
¨¨I J
Id
¨¨J L
.
¨¨L M
ToString
¨¨M U
(
¨¨U V
)
¨¨V W
,
¨¨W X
[
¨¨Y Z
$str
¨¨Z `
]
¨¨` a
=
¨¨b c
ticket
¨¨d j
.
¨¨j k
Code
¨¨k o
,
¨¨o p
[
¨¨q r
$str
¨¨r y
]
¨¨y z
=
¨¨{ |
ticket¨¨} É
.¨¨É Ñ
Title¨¨Ñ â
,¨¨â ä
[¨¨ã å
$str¨¨å ï
]¨¨ï ñ
=¨¨ó ò
project¨¨ô †
.¨¨† °
Name¨¨° •
,¨¨• ¶
[¨¨ß ®
$str¨¨® ±
]¨¨± ≤
=¨¨≥ ¥
creator¨¨µ º
.¨¨º Ω
Name¨¨Ω ¡
}¨¨¬ √
;¨¨√ ƒ
if
≠≠ 

(
≠≠ 
!
≠≠ 
string
≠≠ 
.
≠≠  
IsNullOrWhiteSpace
≠≠ &
(
≠≠& '
creator
≠≠' .
.
≠≠. /
Area
≠≠/ 3
)
≠≠3 4
)
≠≠4 5
data
≠≠6 :
[
≠≠: ;
$str
≠≠; A
]
≠≠A B
=
≠≠C D
creator
≠≠E L
.
≠≠L M
Area
≠≠M Q
;
≠≠Q R
await
ÆÆ 
notifications
ÆÆ 
.
ÆÆ 
	SendAsync
ÆÆ %
(
ÆÆ% &
client
ÆÆ& ,
,
ÆÆ, -
new
ÆÆ. 1
Notification
ÆÆ2 >
(
ÆÆ> ?
NotificationType
ÆÆ? O
.
ÆÆO P%
TicketCreatedForManager
ÆÆP g
,
ÆÆg h
data
ÆÆi m
,
ÆÆm n
$"
ÆÆo q
$strÆÆq Ä
{ÆÆÄ Å
ticketÆÆÅ á
.ÆÆá à
IdÆÆà ä
}ÆÆä ã
"ÆÆã å
,ÆÆå ç
managerÆÆé ï
.ÆÆï ñ
EmailÆÆñ õ
)ÆÆõ ú
,ÆÆú ù
ctÆÆû †
)ÆÆ† °
;ÆÆ° ¢
}
ØØ 
}∞∞ „À
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
} ◊n
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
)==6 7
=>==8 :
string==; A
.==A B
IsNullOrWhiteSpace==B T
(==T U
value==U Z
)==Z [
?==\ ]
null==^ b
:==c d
value==e j
.==j k
Trim==k o
(==o p
)==p q
is==r t
var==u x
v==y z
&&=={ }
v==~ 
.	== Ä
Length
==Ä Ü
>
==á à
max
==â å
?
==ç é
v
==è ê
[
==ê ë
..
==ë ì
max
==ì ñ
]
==ñ ó
:
==ò ô
value
==ö ü
.
==ü †
Trim
==† §
(
==§ •
)
==• ¶
;
==¶ ß
}>> 
publicAA 
sealedAA 
recordAA 
ContactRequestAA #
(AA# $
stringAA$ *
?AA* +
NameAA, 0
,AA0 1
stringAA2 8
?AA8 9
EmailAA: ?
,AA? @
stringAAA G
?AAG H
PhoneAAI N
,AAN O
stringAAP V
?AAV W
CompanyAAX _
,AA_ `
stringAAa g
?AAg h
ServiceAAi p
,AAp q
stringAAr x
?AAx y
Message	AAz Å
,
AAÅ Ç
string
AAÉ â
?
AAâ ä
Locale
AAã ë
,
AAë í
string
AAì ô
?
AAô ö
Page
AAõ ü
,
AAü †
string
AA° ß
?
AAß ®
Website
AA© ∞
=
AA± ≤
null
AA≥ ∑
)
AA∑ ∏
;
AA∏ π
publicBB 
sealedBB 
recordBB 
ContactLeadPatchBB %
(BB% &
ContactLeadStatusBB& 7
?BB7 8
StatusBB9 ?
,BB? @
stringBBA G
?BBG H
NotesBBI N
)BBN O
;BBO P ∏
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
;  Ú ÛËÉ
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
<66 
today66 $
.66$ %
Year66% )
?66* +
$num66, .
:66/ 0
year661 5
==666 8
today669 >
.66> ?
Year66? C
?66D E
today66F K
.66K L
Month66L Q
:66R S
$num66T U
;66U V
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
ÖÖe f¿≤
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
éé5 6
request
éé7 >
.
éé> ?
Ruc
éé? B
.
ééB C
Trim
ééC G
(
ééG H
)
ééH I
is
ééJ L
{
ééM N
Length
ééO U
:
ééU V
>
ééW X
$num
ééY Z
}
éé[ \
trimmed
éé] d
?
éée f
trimmed
éég n
:
ééo p
null
ééq u
;
ééu v
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
ÈÈ4 5
=>
ÈÈ6 8
cell
ÍÍ 
.
ÍÍ 
DataType
ÍÍ 
==
ÍÍ 

XLDataType
ÍÍ #
.
ÍÍ# $
Number
ÍÍ$ *
?
ÍÍ+ ,
(
ÍÍ- .
decimal
ÍÍ. 5
)
ÍÍ5 6
cell
ÍÍ6 :
.
ÍÍ: ;
	GetDouble
ÍÍ; D
(
ÍÍD E
)
ÍÍE F
:
ÎÎ 	
decimal
ÎÎ
 
.
ÎÎ 
TryParse
ÎÎ 
(
ÎÎ 
cell
ÎÎ 
.
ÎÎ  
	GetString
ÎÎ  )
(
ÎÎ) *
)
ÎÎ* +
.
ÎÎ+ ,
Trim
ÎÎ, 0
(
ÎÎ0 1
)
ÎÎ1 2
,
ÎÎ2 3
System
ÎÎ4 :
.
ÎÎ: ;
Globalization
ÎÎ; H
.
ÎÎH I
NumberStyles
ÎÎI U
.
ÎÎU V
Number
ÎÎV \
,
ÎÎ\ ]
System
ÎÎ^ d
.
ÎÎd e
Globalization
ÎÎe r
.
ÎÎr s
CultureInfo
ÎÎs ~
.
ÎÎ~ 
InvariantCultureÎÎ è
,ÎÎè ê
outÎÎë î
varÎÎï ò
valueÎÎô û
)ÎÎû ü
?ÎÎ† °
valueÎÎ¢ ß
:ÎÎ® ©
nullÎÎ™ Æ
;ÎÎÆ Ø
private
ÌÌ 
static
ÌÌ 
DateOnly
ÌÌ 
?
ÌÌ 
ReadDate
ÌÌ %
(
ÌÌ% &
IXLCell
ÌÌ& -
cell
ÌÌ. 2
)
ÌÌ2 3
=>
ÌÌ4 6
cell
ÓÓ 
.
ÓÓ 
DataType
ÓÓ 
==
ÓÓ 

XLDataType
ÓÓ #
.
ÓÓ# $
DateTime
ÓÓ$ ,
?
ÓÓ- .
DateOnly
ÓÓ/ 7
.
ÓÓ7 8
FromDateTime
ÓÓ8 D
(
ÓÓD E
cell
ÓÓE I
.
ÓÓI J
GetDateTime
ÓÓJ U
(
ÓÓU V
)
ÓÓV W
)
ÓÓW X
:
ÔÔ 	
DateOnly
ÔÔ
 
.
ÔÔ 
TryParseExact
ÔÔ  
(
ÔÔ  !
cell
ÔÔ! %
.
ÔÔ% &
	GetString
ÔÔ& /
(
ÔÔ/ 0
)
ÔÔ0 1
.
ÔÔ1 2
Trim
ÔÔ2 6
(
ÔÔ6 7
)
ÔÔ7 8
,
ÔÔ8 9
[
ÔÔ: ;
$str
ÔÔ; G
,
ÔÔG H
$str
ÔÔI U
,
ÔÔU V
$str
ÔÔW a
]
ÔÔa b
,
ÔÔb c
System
ÔÔd j
.
ÔÔj k
Globalization
ÔÔk x
.
ÔÔx y
CultureInfoÔÔy Ñ
.ÔÔÑ Ö 
InvariantCultureÔÔÖ ï
,ÔÔï ñ
SystemÔÔó ù
.ÔÔù û
GlobalizationÔÔû ´
.ÔÔ´ ¨
DateTimeStylesÔÔ¨ ∫
.ÔÔ∫ ª
NoneÔÔª ø
,ÔÔø ¿
outÔÔ¡ ƒ
varÔÔ≈ »
dateÔÔ… Õ
)ÔÔÕ Œ
?ÔÔœ –
dateÔÔ— ’
:ÔÔ÷ ◊
nullÔÔÿ ‹
;ÔÔ‹ ›
[
ÒÒ 

HttpDelete
ÒÒ 
(
ÒÒ 
$str
ÒÒ $
)
ÒÒ$ %
]
ÒÒ% &
public
ÚÚ 

async
ÚÚ 
Task
ÚÚ 
<
ÚÚ 
ActionResult
ÚÚ "
>
ÚÚ" #
DeleteExpense
ÚÚ$ 1
(
ÚÚ1 2
Guid
ÚÚ2 6
id
ÚÚ7 9
,
ÚÚ9 :
CancellationToken
ÚÚ; L
ct
ÚÚM O
)
ÚÚO P
{
ÛÛ 
var
ÙÙ 
expense
ÙÙ 
=
ÙÙ 
await
ÙÙ 
db
ÙÙ 
.
ÙÙ 
Expenses
ÙÙ '
.
ÙÙ' (
	FindAsync
ÙÙ( 1
(
ÙÙ1 2
[
ÙÙ2 3
id
ÙÙ3 5
]
ÙÙ5 6
,
ÙÙ6 7
ct
ÙÙ8 :
)
ÙÙ: ;
;
ÙÙ; <
if
ÙÙ= ?
(
ÙÙ@ A
expense
ÙÙA H
is
ÙÙI K
null
ÙÙL P
)
ÙÙP Q
return
ÙÙR X
NotFound
ÙÙY a
(
ÙÙa b
)
ÙÙb c
;
ÙÙc d
db
ıı 

.
ıı
 
Expenses
ıı 
.
ıı 
Remove
ıı 
(
ıı 
expense
ıı "
)
ıı" #
;
ıı# $
await
ıı% *
db
ıı+ -
.
ıı- .
SaveChangesAsync
ıı. >
(
ıı> ?
ct
ıı? A
)
ııA B
;
ııB C
return
ııD J
	NoContent
ııK T
(
ııT U
)
ııU V
;
ııV W
}
ˆˆ 
[
˝˝ 
HttpPost
˝˝ 
(
˝˝ 
$str
˝˝ 1
)
˝˝1 2
]
˝˝2 3
public
˛˛ 

async
˛˛ 
Task
˛˛ 
<
˛˛ 
ActionResult
˛˛ "
>
˛˛" #
EndRecurrence
˛˛$ 1
(
˛˛1 2
Guid
˛˛2 6
id
˛˛7 9
,
˛˛9 :"
EndRecurrenceRequest
˛˛; O
request
˛˛P W
,
˛˛W X
bool
˛˛Y ]
dryRun
˛˛^ d
,
˛˛d e
CancellationToken
˛˛f w
ct
˛˛x z
)
˛˛z {
{
ˇˇ 
var
ÄÄ 
expense
ÄÄ 
=
ÄÄ 
await
ÄÄ 
db
ÄÄ 
.
ÄÄ 
Expenses
ÄÄ '
.
ÄÄ' (
	FindAsync
ÄÄ( 1
(
ÄÄ1 2
[
ÄÄ2 3
id
ÄÄ3 5
]
ÄÄ5 6
,
ÄÄ6 7
ct
ÄÄ8 :
)
ÄÄ: ;
;
ÄÄ; <
if
ÄÄ= ?
(
ÄÄ@ A
expense
ÄÄA H
is
ÄÄI K
null
ÄÄL P
)
ÄÄP Q
return
ÄÄR X
NotFound
ÄÄY a
(
ÄÄa b
)
ÄÄb c
;
ÄÄc d
if
ÅÅ 

(
ÅÅ 
!
ÅÅ 
expense
ÅÅ 
.
ÅÅ 
	Recurring
ÅÅ 
)
ÅÅ 
return
ÅÅ  &

BadRequest
ÅÅ' 1
(
ÅÅ1 2
new
ÅÅ2 5
{
ÅÅ6 7
message
ÅÅ8 ?
=
ÅÅ@ A
$str
ÅÅB ^
}
ÅÅ_ `
)
ÅÅ` a
;
ÅÅa b
var
ÇÇ 
series
ÇÇ 
=
ÇÇ 
await
ÇÇ 
ExpenseSeries
ÇÇ (
(
ÇÇ( )
expense
ÇÇ) 0
)
ÇÇ0 1
.
ÇÇ1 2
ToListAsync
ÇÇ2 =
(
ÇÇ= >
ct
ÇÇ> @
)
ÇÇ@ A
;
ÇÇA B
var
ÉÉ 
removed
ÉÉ 
=
ÉÉ 
series
ÉÉ 
.
ÉÉ 
Where
ÉÉ "
(
ÉÉ" #
x
ÉÉ# $
=>
ÉÉ% '
x
ÉÉ( )
.
ÉÉ) *
Date
ÉÉ* .
>
ÉÉ/ 0
request
ÉÉ1 8
.
ÉÉ8 9
EndsAt
ÉÉ9 ?
)
ÉÉ? @
.
ÉÉ@ A
ToList
ÉÉA G
(
ÉÉG H
)
ÉÉH I
;
ÉÉI J
if
ÑÑ 

(
ÑÑ 
!
ÑÑ 
dryRun
ÑÑ 
)
ÑÑ 
{
ÖÖ 	
db
ÜÜ 
.
ÜÜ 
Expenses
ÜÜ 
.
ÜÜ 
RemoveRange
ÜÜ #
(
ÜÜ# $
removed
ÜÜ$ +
)
ÜÜ+ ,
;
ÜÜ, -
foreach
áá 
(
áá 
var
áá 
kept
áá 
in
áá  
series
áá! '
.
áá' (
Except
áá( .
(
áá. /
removed
áá/ 6
)
áá6 7
)
áá7 8
kept
áá9 =
.
áá= >
RecurrenceEndsAt
áá> N
=
ááO P
request
ááQ X
.
ááX Y
EndsAt
ááY _
;
áá_ `
await
àà 
db
àà 
.
àà 
SaveChangesAsync
àà %
(
àà% &
ct
àà& (
)
àà( )
;
àà) *
}
ââ 	
return
ää 
Ok
ää 
(
ää 
new
ää 
{
ää 
removed
ää 
=
ää  !
removed
ää" )
.
ää) *
Count
ää* /
,
ää/ 0
kept
ää1 5
=
ää6 7
series
ää8 >
.
ää> ?
Count
ää? D
-
ääE F
removed
ääG N
.
ääN O
Count
ääO T
,
ääT U
removedTotalPen
ääV e
=
ääf g
Math
ääh l
.
ääl m
Round
ääm r
(
äär s
removed
ääs z
.
ääz {
Sum
ää{ ~
(
ää~ 
xää Ä
=>ääÅ É
xääÑ Ö
.ääÖ Ü
	AmountPenääÜ è
)ääè ê
,ääê ë
$numääí ì
)ääì î
}ääï ñ
)ääñ ó
;ääó ò
}
ãã 
[
éé 

HttpDelete
éé 
(
éé 
$str
éé 3
)
éé3 4
]
éé4 5
public
èè 

async
èè 
Task
èè 
<
èè 
ActionResult
èè "
>
èè" #
ResumeRecurrence
èè$ 4
(
èè4 5
Guid
èè5 9
id
èè: <
,
èè< =
CancellationToken
èè> O
ct
èèP R
)
èèR S
{
êê 
var
ëë 
expense
ëë 
=
ëë 
await
ëë 
db
ëë 
.
ëë 
Expenses
ëë '
.
ëë' (
	FindAsync
ëë( 1
(
ëë1 2
[
ëë2 3
id
ëë3 5
]
ëë5 6
,
ëë6 7
ct
ëë8 :
)
ëë: ;
;
ëë; <
if
ëë= ?
(
ëë@ A
expense
ëëA H
is
ëëI K
null
ëëL P
)
ëëP Q
return
ëëR X
NotFound
ëëY a
(
ëëa b
)
ëëb c
;
ëëc d
foreach
íí 
(
íí 
var
íí 
x
íí 
in
íí 
await
íí 
ExpenseSeries
íí  -
(
íí- .
expense
íí. 5
)
íí5 6
.
íí6 7
ToListAsync
íí7 B
(
ííB C
ct
ííC E
)
ííE F
)
ííF G
x
ííH I
.
ííI J
RecurrenceEndsAt
ííJ Z
=
íí[ \
null
íí] a
;
íía b
await
ìì 
db
ìì 
.
ìì 
SaveChangesAsync
ìì !
(
ìì! "
ct
ìì" $
)
ìì$ %
;
ìì% &
return
ìì' -
	NoContent
ìì. 7
(
ìì7 8
)
ìì8 9
;
ìì9 :
}
îî 
private
ññ 

IQueryable
ññ 
<
ññ 
Expense
ññ 
>
ññ 
ExpenseSeries
ññ  -
(
ññ- .
Expense
ññ. 5
expense
ññ6 =
)
ññ= >
{
óó 
var
òò 
description
òò 
=
òò 
expense
òò !
.
òò! "
Description
òò" -
.
òò- .
Trim
òò. 2
(
òò2 3
)
òò3 4
;
òò4 5
return
ôô 
db
ôô 
.
ôô 
Expenses
ôô 
.
ôô 
Where
ôô  
(
ôô  !
x
ôô! "
=>
ôô# %
x
ôô& '
.
ôô' (
	Recurring
ôô( 1
&&
ôô2 4
x
ôô5 6
.
ôô6 7
Description
ôô7 B
.
ôôB C
Trim
ôôC G
(
ôôG H
)
ôôH I
==
ôôJ L
description
ôôM X
&&
ôôY [
x
ôô\ ]
.
ôô] ^

CategoryId
ôô^ h
==
ôôi k
expense
ôôl s
.
ôôs t

CategoryId
ôôt ~
&&ôô Å
xôôÇ É
.ôôÉ Ñ
CurrencyôôÑ å
==ôôç è
expenseôôê ó
.ôôó ò
Currencyôôò †
)ôô† °
;ôô° ¢
}
öö 
[
úú 
	HttpPatch
úú 
(
úú 
$str
úú #
)
úú# $
]
úú$ %
public
ùù 

async
ùù 
Task
ùù 
<
ùù 
ActionResult
ùù "
>
ùù" #
UpdateExpense
ùù$ 1
(
ùù1 2
Guid
ùù2 6
id
ùù7 9
,
ùù9 :!
ExpensePatchRequest
ùù; N
request
ùùO V
,
ùùV W
CancellationToken
ùùX i
ct
ùùj l
)
ùùl m
{
ûû 
var
üü 
expense
üü 
=
üü 
await
üü 
db
üü 
.
üü 
Expenses
üü '
.
üü' (
	FindAsync
üü( 1
(
üü1 2
[
üü2 3
id
üü3 5
]
üü5 6
,
üü6 7
ct
üü8 :
)
üü: ;
;
üü; <
if
üü= ?
(
üü@ A
expense
üüA H
is
üüI K
null
üüL P
)
üüP Q
return
üüR X
NotFound
üüY a
(
üüa b
)
üüb c
;
üüc d
if
†† 

(
†† 
request
†† 
.
†† 
Description
†† 
is
††  "
not
††# &
null
††' +
)
††+ ,
expense
††- 4
.
††4 5
Description
††5 @
=
††A B
request
††C J
.
††J K
Description
††K V
.
††V W
Trim
††W [
(
††[ \
)
††\ ]
;
††] ^
if
°° 

(
°° 
request
°° 
.
°° 

CategoryId
°° 
is
°° !
Guid
°°" &

categoryId
°°' 1
)
°°1 2
{
¢¢ 	
if
££ 
(
££ 
!
££ 
await
££ 
db
££ 
.
££ 
ExpenseCategories
££ +
.
££+ ,
AnyAsync
££, 4
(
££4 5
x
££5 6
=>
££7 9
x
££: ;
.
££; <
Id
££< >
==
££? A

categoryId
££B L
,
££L M
ct
££N P
)
££P Q
)
££Q R
return
££S Y

BadRequest
££Z d
(
££d e
new
££e h
{
££i j
message
££k r
=
££s t
$str££u í
}££ì î
)££î ï
;££ï ñ
expense
§§ 
.
§§ 

CategoryId
§§ 
=
§§  

categoryId
§§! +
;
§§+ ,
}
•• 	
if
¶¶ 

(
¶¶ 
request
¶¶ 
.
¶¶ 
Type
¶¶ 
is
¶¶ 
ExpenseType
¶¶ '
type
¶¶( ,
)
¶¶, -
expense
¶¶. 5
.
¶¶5 6
Type
¶¶6 :
=
¶¶; <
type
¶¶= A
;
¶¶A B
if
ßß 

(
ßß 
request
ßß 
.
ßß 
Amount
ßß 
is
ßß 
decimal
ßß %
amount
ßß& ,
)
ßß, -
expense
ßß. 5
.
ßß5 6
Amount
ßß6 <
=
ßß= >
amount
ßß? E
;
ßßE F
if
®® 

(
®® 
request
®® 
.
®® 
Currency
®® 
is
®® 
not
®®  #
null
®®$ (
)
®®( )
expense
®®* 1
.
®®1 2
Currency
®®2 :
=
®®; <
request
®®= D
.
®®D E
Currency
®®E M
.
®®M N
Trim
®®N R
(
®®R S
)
®®S T
.
®®T U
ToUpperInvariant
®®U e
(
®®e f
)
®®f g
;
®®g h
if
©© 

(
©© 
request
©© 
.
©© 
Date
©© 
is
©© 
DateOnly
©© $
date
©©% )
)
©©) *
expense
©©+ 2
.
©©2 3
Date
©©3 7
=
©©8 9
date
©©: >
;
©©> ?
if
™™ 

(
™™ 
request
™™ 
.
™™ 
	Recurring
™™ 
is
™™  
bool
™™! %
	recurring
™™& /
)
™™/ 0
expense
™™1 8
.
™™8 9
	Recurring
™™9 B
=
™™C D
	recurring
™™E N
;
™™N O
if
´´ 

(
´´ 
request
´´ 
.
´´ 
RecurrenceCycle
´´ #
is
´´$ &
BillingCycle
´´' 3
cycle
´´4 9
)
´´9 :
expense
´´; B
.
´´B C
RecurrenceCycle
´´C R
=
´´S T
cycle
´´U Z
;
´´Z [
if
¨¨ 

(
¨¨ 
request
¨¨ 
.
¨¨ 
IsNonDeductible
¨¨ #
is
¨¨$ &
bool
¨¨' +
nonDeductible
¨¨, 9
)
¨¨9 :
expense
¨¨; B
.
¨¨B C
IsNonDeductible
¨¨C R
=
¨¨S T
nonDeductible
¨¨U b
;
¨¨b c
if
≠≠ 

(
≠≠ 
request
≠≠ 
.
≠≠ #
IsNonDomiciledService
≠≠ )
is
≠≠* ,
bool
≠≠- 1
foreign
≠≠2 9
)
≠≠9 :!
ApplyForeignService
≠≠; N
(
≠≠N O
expense
≠≠O V
,
≠≠V W
foreign
≠≠X _
,
≠≠_ `
request
≠≠a h
.
≠≠h i!
ForeignSupplierName
≠≠i |
,
≠≠| }
request≠≠~ Ö
.≠≠Ö Ü&
ForeignSupplierCountry≠≠Ü ú
)≠≠ú ù
;≠≠ù û
if
ÆÆ 

(
ÆÆ 
string
ÆÆ 
.
ÆÆ  
IsNullOrWhiteSpace
ÆÆ %
(
ÆÆ% &
expense
ÆÆ& -
.
ÆÆ- .
Description
ÆÆ. 9
)
ÆÆ9 :
||
ÆÆ; =
string
ÆÆ> D
.
ÆÆD E 
IsNullOrWhiteSpace
ÆÆE W
(
ÆÆW X
expense
ÆÆX _
.
ÆÆ_ `
Currency
ÆÆ` h
)
ÆÆh i
||
ÆÆj l
expense
ÆÆm t
.
ÆÆt u
Amount
ÆÆu {
<=
ÆÆ| ~
$numÆÆ Ä
)ÆÆÄ Å
returnÆÆÇ à

BadRequestÆÆâ ì
(ÆÆì î
newÆÆî ó
{ÆÆò ô
messageÆÆö °
=ÆÆ¢ £
$strÆÆ§ ‡
}ÆÆ· ‚
)ÆÆ‚ „
;ÆÆ„ ‰
expense
ØØ 
.
ØØ 
	AmountPen
ØØ 
=
ØØ 
expense
ØØ #
.
ØØ# $
Amount
ØØ$ *
*
ØØ+ ,
await
ØØ- 2
db
ØØ3 5
.
ØØ5 6
RateToPenAsync
ØØ6 D
(
ØØD E
expense
ØØE L
.
ØØL M
Currency
ØØM U
,
ØØU V
expense
ØØW ^
.
ØØ^ _
Date
ØØ_ c
,
ØØc d
ct
ØØe g
)
ØØg h
;
ØØh i
await
∞∞ 
db
∞∞ 
.
∞∞ 
SaveChangesAsync
∞∞ !
(
∞∞! "
ct
∞∞" $
)
∞∞$ %
;
∞∞% &
await
∞∞' ,
db
∞∞- /
.
∞∞/ 0
Entry
∞∞0 5
(
∞∞5 6
expense
∞∞6 =
)
∞∞= >
.
∞∞> ?
	Reference
∞∞? H
(
∞∞H I
x
∞∞I J
=>
∞∞K M
x
∞∞N O
.
∞∞O P
Category
∞∞P X
)
∞∞X Y
.
∞∞Y Z
	LoadAsync
∞∞Z c
(
∞∞c d
ct
∞∞d f
)
∞∞f g
;
∞∞g h
return
∞∞i o
Ok
∞∞p r
(
∞∞r s

ExpenseDto
∞∞s }
(
∞∞} ~
expense∞∞~ Ö
)∞∞Ö Ü
)∞∞Ü á
;∞∞á à
}
±± 
private
≥≥ 
const
≥≥ 
string
≥≥ 
TaxDisclaimer
≥≥ &
=
≥≥' (
$str≥≥) ÿ
;≥≥ÿ Ÿ
private
∂∂ 
static
∂∂ 
(
∂∂ 
DateOnly
∂∂ 
From
∂∂ !
,
∂∂! "
DateOnly
∂∂# +
To
∂∂, .
)
∂∂. /
Period
∂∂0 6
(
∂∂6 7
int
∂∂7 :
?
∂∂: ;
month
∂∂< A
,
∂∂A B
int
∂∂C F
year
∂∂G K
)
∂∂K L
=>
∂∂M O
month
∑∑ 
is
∑∑ 
int
∑∑ 
m
∑∑ 
?
∑∑ 
(
∑∑ 
new
∑∑ 
DateOnly
∑∑ &
(
∑∑& '
year
∑∑' +
,
∑∑+ ,
m
∑∑- .
,
∑∑. /
$num
∑∑0 1
)
∑∑1 2
,
∑∑2 3
new
∑∑4 7
DateOnly
∑∑8 @
(
∑∑@ A
year
∑∑A E
,
∑∑E F
m
∑∑G H
,
∑∑H I
$num
∑∑J K
)
∑∑K L
.
∑∑L M
	AddMonths
∑∑M V
(
∑∑V W
$num
∑∑W X
)
∑∑X Y
.
∑∑Y Z
AddDays
∑∑Z a
(
∑∑a b
-
∑∑b c
$num
∑∑c d
)
∑∑d e
)
∑∑e f
:
∑∑g h
(
∑∑i j
new
∑∑j m
DateOnly
∑∑n v
(
∑∑v w
year
∑∑w {
,
∑∑{ |
$num
∑∑} ~
,
∑∑~ 
$num∑∑Ä Å
)∑∑Å Ç
,∑∑Ç É
new∑∑Ñ á
DateOnly∑∑à ê
(∑∑ê ë
year∑∑ë ï
,∑∑ï ñ
$num∑∑ó ô
,∑∑ô ö
$num∑∑õ ù
)∑∑ù û
)∑∑û ü
;∑∑ü †
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
∫∫. /
PreviousPeriod
∫∫0 >
(
∫∫> ?
int
∫∫? B
?
∫∫B C
month
∫∫D I
,
∫∫I J
int
∫∫K N
year
∫∫O S
)
∫∫S T
=>
∫∫U W
month
ªª 
is
ªª 
int
ªª 
m
ªª 
?
ªª 
Period
ªª 
(
ªª  
m
ªª  !
==
ªª" $
$num
ªª% &
?
ªª' (
$num
ªª) +
:
ªª, -
m
ªª. /
-
ªª0 1
$num
ªª2 3
,
ªª3 4
m
ªª5 6
==
ªª7 9
$num
ªª: ;
?
ªª< =
year
ªª> B
-
ªªC D
$num
ªªE F
:
ªªG H
year
ªªI M
)
ªªM N
:
ªªO P
Period
ªªQ W
(
ªªW X
null
ªªX \
,
ªª\ ]
year
ªª^ b
-
ªªc d
$num
ªªe f
)
ªªf g
;
ªªg h
private
¡¡ 
sealed
¡¡ 
record
¡¡ 
Sale
¡¡ 
(
¡¡ 
Guid
¡¡ #
ClientId
¡¡$ ,
,
¡¡, -
DateOnly
¡¡. 6
Date
¡¡7 ;
,
¡¡; <
decimal
¡¡= D
BasePen
¡¡E L
,
¡¡L M
decimal
¡¡N U
IgvPen
¡¡V \
,
¡¡\ ]
bool
¡¡^ b
Gravada
¡¡c j
,
¡¡j k
decimal
¡¡l s
RetentionPen¡¡t Ä
,¡¡Ä Å
bool¡¡Ç Ü
PersonaNatural¡¡á ï
=¡¡ñ ó
false¡¡ò ù
)¡¡ù û
{
¬¬ 
public
√√ 
bool
√√ 
Mype
√√ 
=>
√√ 
!
√√ 
PersonaNatural
√√ +
;
√√+ ,
}
ƒƒ 
private
ÀÀ 
async
ÀÀ 
Task
ÀÀ 
<
ÀÀ 
List
ÀÀ 
<
ÀÀ 
Sale
ÀÀ  
>
ÀÀ  !
>
ÀÀ! "

SalesAsync
ÀÀ# -
(
ÀÀ- .
DateOnly
ÀÀ. 6
from
ÀÀ7 ;
,
ÀÀ; <
DateOnly
ÀÀ= E
to
ÀÀF H
,
ÀÀH I
CancellationToken
ÀÀJ [
ct
ÀÀ\ ^
)
ÀÀ^ _
{
ÃÃ 
var
ÕÕ 
start
ÕÕ 
=
ÕÕ 
from
ÕÕ 
.
ÕÕ 

ToDateTime
ÕÕ #
(
ÕÕ# $
TimeOnly
ÕÕ$ ,
.
ÕÕ, -
MinValue
ÕÕ- 5
)
ÕÕ5 6
;
ÕÕ6 7
var
ÕÕ8 ;
end
ÕÕ< ?
=
ÕÕ@ A
to
ÕÕB D
.
ÕÕD E
AddDays
ÕÕE L
(
ÕÕL M
$num
ÕÕM N
)
ÕÕN O
.
ÕÕO P

ToDateTime
ÕÕP Z
(
ÕÕZ [
TimeOnly
ÕÕ[ c
.
ÕÕc d
MinValue
ÕÕd l
)
ÕÕl m
;
ÕÕm n
var
ŒŒ 
payments
ŒŒ 
=
ŒŒ 
await
ŒŒ 
db
ŒŒ 
.
ŒŒ  !
PaymentTransactions
ŒŒ  3
.
ŒŒ3 4
Where
ŒŒ4 9
(
ŒŒ9 :
x
ŒŒ: ;
=>
ŒŒ< >
x
ŒŒ? @
.
ŒŒ@ A
	CreatedAt
ŒŒA J
>=
ŒŒK M
start
ŒŒN S
&&
ŒŒT V
x
ŒŒW X
.
ŒŒX Y
	CreatedAt
ŒŒY b
<
ŒŒc d
end
ŒŒe h
)
ŒŒh i
.
œœ 
Select
œœ 
(
œœ 
x
œœ 
=>
œœ 
new
œœ 
{
œœ 
x
œœ  
.
œœ  !
ClientId
œœ! )
,
œœ) *
x
œœ+ ,
.
œœ, -
	CreatedAt
œœ- 6
,
œœ6 7
x
œœ8 9
.
œœ9 :
	AmountPen
œœ: C
,
œœC D
Document
œœE M
=
œœN O
db
œœP R
.
œœR S
TaxDocuments
œœS _
.
œœ_ `
FirstOrDefault
œœ` n
(
œœn o
d
œœo p
=>
œœq s
d
œœt u
.
œœu v#
PaymentTransactionIdœœv ä
==œœã ç
xœœé è
.œœè ê
Idœœê í
)œœí ì
}œœî ï
)œœï ñ
.œœñ ó
ToListAsyncœœó ¢
(œœ¢ £
ctœœ£ •
)œœ• ¶
;œœ¶ ß
return
–– 
payments
–– 
.
–– 
Select
–– 
(
–– 
x
––  
=>
––! #
{
—— 	
var
““ 
document
““ 
=
““ 
x
““ 
.
““ 
Document
““ %
is
““& (
{
““) *
TotalAmount
““+ 6
:
““6 7
>
““8 9
$num
““: ;
}
““< =
d
““> ?
?
““@ A
d
““B C
:
““D E
null
““F J
;
““J K
var
”” 
	isFactura
”” 
=
”” 
document
”” $
?
””$ %
.
””% &
Type
””& *
==
””+ -
TaxDocumentType
””. =
.
””= >
Factura
””> E
;
””E F
var
‘‘ 
basePen
‘‘ 
=
‘‘ 
	isFactura
‘‘ #
?
‘‘$ %
x
‘‘& '
.
‘‘' (
	AmountPen
‘‘( 1
*
‘‘2 3
document
‘‘4 <
!
‘‘< =
.
‘‘= >

BaseAmount
‘‘> H
/
‘‘I J
document
‘‘K S
.
‘‘S T
TotalAmount
‘‘T _
:
‘‘` a
x
‘‘b c
.
‘‘c d
	AmountPen
‘‘d m
;
‘‘m n
var
’’ 
retentionPen
’’ 
=
’’ 
document
’’ '
?
’’' (
.
’’( )
RetentionAmount
’’) 8
is
’’9 ;
decimal
’’< C
	retention
’’D M
?
’’N O
x
’’P Q
.
’’Q R
	AmountPen
’’R [
*
’’\ ]
	retention
’’^ g
/
’’h i
document
’’j r
.
’’r s
TotalAmount
’’s ~
:’’ Ä
$num’’Å É
;’’É Ñ
return
÷÷ 
new
÷÷ 
Sale
÷÷ 
(
÷÷ 
x
÷÷ 
.
÷÷ 
ClientId
÷÷ &
,
÷÷& '
DateOnly
÷÷( 0
.
÷÷0 1
FromDateTime
÷÷1 =
(
÷÷= >
x
÷÷> ?
.
÷÷? @
	CreatedAt
÷÷@ I
)
÷÷I J
,
÷÷J K
basePen
÷÷L S
,
÷÷S T
x
÷÷U V
.
÷÷V W
	AmountPen
÷÷W `
-
÷÷a b
basePen
÷÷c j
,
÷÷j k
	isFactura
÷÷l u
,
÷÷u v
retentionPen÷÷w É
,÷÷É Ñ
document÷÷Ö ç
?÷÷ç é
.÷÷é è
Type÷÷è ì
==÷÷î ñ
TaxDocumentType÷÷ó ¶
.÷÷¶ ß#
ReciboPorHonorarios÷÷ß ∫
)÷÷∫ ª
;÷÷ª º
}
◊◊ 	
)
◊◊	 

.
◊◊
 
ToList
◊◊ 
(
◊◊ 
)
◊◊ 
;
◊◊ 
}
ÿÿ 
[
⁄⁄ 
HttpGet
⁄⁄ 
(
⁄⁄ 
$str
⁄⁄ 
)
⁄⁄ 
]
⁄⁄ 
public
€€ 

async
€€ 
Task
€€ 
<
€€ 
ActionResult
€€ "
>
€€" #
SalesReport
€€$ /
(
€€/ 0
int
€€0 3
?
€€3 4
month
€€5 :
,
€€: ;
int
€€< ?
year
€€@ D
,
€€D E
string
€€F L
currency
€€M U
,
€€U V
CancellationToken
€€W h
ct
€€i k
)
€€k l
{
‹‹ 
if
›› 

(
›› 
currency
›› 
is
›› 
not
›› 
(
›› 
$str
›› "
or
››# %
$str
››& +
or
››, .
$str
››/ 4
)
››4 5
)
››5 6
return
››7 =

BadRequest
››> H
(
››H I
new
››I L
{
››M N
message
››O V
=
››W X
$str
››Y k
}
››l m
)
››m n
;
››n o
var
ﬁﬁ 
(
ﬁﬁ 
from
ﬁﬁ 
,
ﬁﬁ 
to
ﬁﬁ 
)
ﬁﬁ 
=
ﬁﬁ 
Period
ﬁﬁ 
(
ﬁﬁ  
month
ﬁﬁ  %
,
ﬁﬁ% &
year
ﬁﬁ' +
)
ﬁﬁ+ ,
;
ﬁﬁ, -
var
ﬂﬂ 
sales
ﬂﬂ 
=
ﬂﬂ 
await
ﬂﬂ 

SalesAsync
ﬂﬂ $
(
ﬂﬂ$ %
from
ﬂﬂ% )
,
ﬂﬂ) *
to
ﬂﬂ+ -
,
ﬂﬂ- .
ct
ﬂﬂ/ 1
)
ﬂﬂ1 2
;
ﬂﬂ2 3
decimal
‡‡ 
basePen
‡‡ 
=
‡‡ 
sales
‡‡ 
.
‡‡  
Sum
‡‡  #
(
‡‡# $
x
‡‡$ %
=>
‡‡& (
x
‡‡) *
.
‡‡* +
BasePen
‡‡+ 2
)
‡‡2 3
,
‡‡3 4
igvPen
‡‡5 ;
=
‡‡< =
sales
‡‡> C
.
‡‡C D
Sum
‡‡D G
(
‡‡G H
x
‡‡H I
=>
‡‡J L
x
‡‡M N
.
‡‡N O
IgvPen
‡‡O U
)
‡‡U V
;
‡‡V W
var
·· 
rate
·· 
=
·· 
currency
·· 
==
·· 
$str
·· $
?
··% &
$num
··' )
:
··* +
await
··, 1
db
··2 4
.
··4 5
RateToPenAsync
··5 C
(
··C D
currency
··D L
,
··L M
to
··N P
,
··P Q
ct
··R T
)
··T U
;
··U V
return
‚‚ 
Ok
‚‚ 
(
‚‚ 
new
‚‚ 
{
‚‚ 
baseImponible
‚‚ %
=
‚‚& '
Math
‚‚( ,
.
‚‚, -
Round
‚‚- 2
(
‚‚2 3
basePen
‚‚3 :
/
‚‚; <
rate
‚‚= A
,
‚‚A B
$num
‚‚C D
)
‚‚D E
,
‚‚E F
igv
‚‚G J
=
‚‚K L
Math
‚‚M Q
.
‚‚Q R
Round
‚‚R W
(
‚‚W X
igvPen
‚‚X ^
/
‚‚_ `
rate
‚‚a e
,
‚‚e f
$num
‚‚g h
)
‚‚h i
,
‚‚i j
total
‚‚k p
=
‚‚q r
Math
‚‚s w
.
‚‚w x
Round
‚‚x }
(
‚‚} ~
(
‚‚~ 
basePen‚‚ Ü
+‚‚á à
igvPen‚‚â è
)‚‚è ê
/‚‚ë í
rate‚‚ì ó
,‚‚ó ò
$num‚‚ô ö
)‚‚ö õ
}‚‚ú ù
)‚‚ù û
;‚‚û ü
}
„„ 
[
ÂÂ 
HttpGet
ÂÂ 
(
ÂÂ 
$str
ÂÂ "
)
ÂÂ" #
]
ÂÂ# $
public
ÊÊ 

async
ÊÊ 
Task
ÊÊ 
<
ÊÊ 
ActionResult
ÊÊ "
>
ÊÊ" #
TaxSummaryReport
ÊÊ$ 4
(
ÊÊ4 5
int
ÊÊ5 8
?
ÊÊ8 9
month
ÊÊ: ?
,
ÊÊ? @
int
ÊÊA D
year
ÊÊE I
,
ÊÊI J
CancellationToken
ÊÊK \
ct
ÊÊ] _
)
ÊÊ_ `
{
ÁÁ 
var
ËË 
settings
ËË 
=
ËË 
await
ËË 
TaxSettingsRow
ËË +
(
ËË+ ,
ct
ËË, .
)
ËË. /
;
ËË/ 0
var
ÈÈ 
(
ÈÈ 
from
ÈÈ 
,
ÈÈ 
to
ÈÈ 
)
ÈÈ 
=
ÈÈ 
Period
ÈÈ 
(
ÈÈ  
month
ÈÈ  %
,
ÈÈ% &
year
ÈÈ' +
)
ÈÈ+ ,
;
ÈÈ, -
var
ÍÍ 
sales
ÍÍ 
=
ÍÍ 
await
ÍÍ 

SalesAsync
ÍÍ $
(
ÍÍ$ %
from
ÍÍ% )
,
ÍÍ) *
to
ÍÍ+ -
,
ÍÍ- .
ct
ÍÍ/ 1
)
ÍÍ1 2
;
ÍÍ2 3
decimal
ÎÎ 
basePen
ÎÎ 
=
ÎÎ 
sales
ÎÎ 
.
ÎÎ  
Sum
ÎÎ  #
(
ÎÎ# $
x
ÎÎ$ %
=>
ÎÎ& (
x
ÎÎ) *
.
ÎÎ* +
BasePen
ÎÎ+ 2
)
ÎÎ2 3
,
ÎÎ3 4
gravadasPen
ÎÎ5 @
=
ÎÎA B
sales
ÎÎC H
.
ÎÎH I
Where
ÎÎI N
(
ÎÎN O
x
ÎÎO P
=>
ÎÎQ S
x
ÎÎT U
.
ÎÎU V
Gravada
ÎÎV ]
)
ÎÎ] ^
.
ÎÎ^ _
Sum
ÎÎ_ b
(
ÎÎb c
x
ÎÎc d
=>
ÎÎe g
x
ÎÎh i
.
ÎÎi j
BasePen
ÎÎj q
)
ÎÎq r
;
ÎÎr s
var
ÏÏ 
igv
ÏÏ 
=
ÏÏ 
(
ÏÏ 
await
ÏÏ 
IgvMonthsAsync
ÏÏ '
(
ÏÏ' (
to
ÏÏ( *
,
ÏÏ* +
ct
ÏÏ, .
)
ÏÏ. /
)
ÏÏ/ 0
.
ÏÏ0 1
Where
ÏÏ1 6
(
ÏÏ6 7
x
ÏÏ7 8
=>
ÏÏ9 ;
x
ÏÏ< =
.
ÏÏ= >
Month
ÏÏ> C
>=
ÏÏD F
from
ÏÏG K
)
ÏÏK L
.
ÏÏL M
ToList
ÏÏM S
(
ÏÏS T
)
ÏÏT U
;
ÏÏU V
return
ÓÓ 
Ok
ÓÓ 
(
ÓÓ 
new
ÓÓ 
{
ÔÔ 	
ventasGravadasPen
 
=
 
Math
  $
.
$ %
Round
% *
(
* +
gravadasPen
+ 6
,
6 7
$num
8 9
)
9 :
,
: ;!
ventasNoGravadasPen
< O
=
P Q
Math
R V
.
V W
Round
W \
(
\ ]
basePen
] d
-
e f
gravadasPen
g r
,
r s
$num
t u
)
u v
,
v w
igvEstimadox É
=Ñ Ö
MathÜ ä
.ä ã
Roundã ê
(ê ë
salesë ñ
.ñ ó
Sumó ö
(ö õ
xõ ú
=>ù ü
x† °
.° ¢
IgvPen¢ ®
)® ©
,© ™
$num´ ¨
)¨ ≠
,≠ Æ
rentaEstimadaØ º
=Ω æ
Mathø √
.√ ƒ
Roundƒ …
(…  
sales  œ
.œ –
Where– ’
(’ ÷
x÷ ◊
=>ÿ ⁄
x€ ‹
.‹ ›
Mype› ·
)· ‚
.‚ „
Sum„ Ê
(Ê Á
xÁ Ë
=>È Î
xÏ Ì
.Ì Ó
BasePenÓ ı
)ı ˆ
*˜ ¯
settings˘ Å
.Å Ç
	RentaRateÇ ã
,ã å
$numç é
)é è
,è ê'
ventasPersonaNaturalPenë ®
=© ™
Math´ Ø
.Ø ∞
Round∞ µ
(µ ∂
sales∂ ª
.ª º
Whereº ¡
(¡ ¬
x¬ √
=>ƒ ∆
x« »
.» …
PersonaNatural… ◊
)◊ ÿ
.ÿ Ÿ
SumŸ ‹
(‹ ›
x› ﬁ
=>ﬂ ·
x‚ „
.„ ‰
BasePen‰ Î
)Î Ï
,Ï Ì
$numÓ Ô
)Ô 
, Ò
tasaÚ ˆ
=˜ ¯
new˘ ¸
{˝ ˛
igvRateˇ Ü
=á à
settingsâ ë
.ë í
IgvRateí ô
,ô ö
	rentaRateõ §
=• ¶
settingsß Ø
.Ø ∞
	RentaRate∞ π
}∫ ª
,ª º

disclaimerΩ «
=» …
TaxDisclaimer  ◊
,◊ ÿ
igv
ÚÚ 
=
ÚÚ 
new
ÚÚ 
{
ÛÛ 
debitoFiscal
ÙÙ 
=
ÙÙ 
Math
ÙÙ #
.
ÙÙ# $
Round
ÙÙ$ )
(
ÙÙ) *
igv
ÙÙ* -
.
ÙÙ- .
Sum
ÙÙ. 1
(
ÙÙ1 2
x
ÙÙ2 3
=>
ÙÙ4 6
x
ÙÙ7 8
.
ÙÙ8 9
Debito
ÙÙ9 ?
)
ÙÙ? @
,
ÙÙ@ A
$num
ÙÙB C
)
ÙÙC D
,
ÙÙD E
creditoFiscal
ÙÙF S
=
ÙÙT U
Math
ÙÙV Z
.
ÙÙZ [
Round
ÙÙ[ `
(
ÙÙ` a
igv
ÙÙa d
.
ÙÙd e
Sum
ÙÙe h
(
ÙÙh i
x
ÙÙi j
=>
ÙÙk m
x
ÙÙn o
.
ÙÙo p
Credito
ÙÙp w
)
ÙÙw x
,
ÙÙx y
$num
ÙÙz {
)
ÙÙ{ |
,
ÙÙ| }!
saldoAFavorAnterior
ıı #
=
ıı$ %
Math
ıı& *
.
ıı* +
Round
ıı+ 0
(
ıı0 1
igv
ıı1 4
.
ıı4 5
FirstOrDefault
ıı5 C
(
ııC D
)
ııD E
?
ııE F
.
ııF G
SaldoAnterior
ııG T
??
ııU W
$num
ııX Z
,
ııZ [
$num
ıı\ ]
)
ıı] ^
,
ıı^ _
	igvAPagar
ıı` i
=
ııj k
Math
ııl p
.
ııp q
Round
ııq v
(
ııv w
igv
ııw z
.
ıız {
Sum
ıı{ ~
(
ıı~ 
xıı Ä
=>ııÅ É
xııÑ Ö
.ııÖ Ü
APagarııÜ å
)ııå ç
,ııç é
$numııè ê
)ııê ë
,ııë í"
saldoAFavorSiguiente
ˆˆ $
=
ˆˆ% &
Math
ˆˆ' +
.
ˆˆ+ ,
Round
ˆˆ, 1
(
ˆˆ1 2
igv
ˆˆ2 5
.
ˆˆ5 6
LastOrDefault
ˆˆ6 C
(
ˆˆC D
)
ˆˆD E
?
ˆˆE F
.
ˆˆF G
SaldoSiguiente
ˆˆG U
??
ˆˆV X
$num
ˆˆY [
,
ˆˆ[ \
$num
ˆˆ] ^
)
ˆˆ^ _
,
ˆˆ_ `
meses
˜˜ 
=
˜˜ 
igv
˜˜ 
.
˜˜ 
Select
˜˜ "
(
˜˜" #
x
˜˜# $
=>
˜˜% '
new
˜˜( +
{
˜˜, -
mes
˜˜. 1
=
˜˜2 3
x
˜˜4 5
.
˜˜5 6
Month
˜˜6 ;
.
˜˜; <
ToString
˜˜< D
(
˜˜D E
$str
˜˜E N
)
˜˜N O
,
˜˜O P
debitoFiscal
˜˜Q ]
=
˜˜^ _
Math
˜˜` d
.
˜˜d e
Round
˜˜e j
(
˜˜j k
x
˜˜k l
.
˜˜l m
Debito
˜˜m s
,
˜˜s t
$num
˜˜u v
)
˜˜v w
,
˜˜w x
creditoFiscal˜˜y Ü
=˜˜á à
Math˜˜â ç
.˜˜ç é
Round˜˜é ì
(˜˜ì î
x˜˜î ï
.˜˜ï ñ
Credito˜˜ñ ù
,˜˜ù û
$num˜˜ü †
)˜˜† °
,˜˜° ¢#
saldoAFavorAnterior˜˜£ ∂
=˜˜∑ ∏
Math˜˜π Ω
.˜˜Ω æ
Round˜˜æ √
(˜˜√ ƒ
x˜˜ƒ ≈
.˜˜≈ ∆
SaldoAnterior˜˜∆ ”
,˜˜” ‘
$num˜˜’ ÷
)˜˜÷ ◊
,˜˜◊ ÿ
	igvAPagar˜˜Ÿ ‚
=˜˜„ ‰
Math˜˜Â È
.˜˜È Í
Round˜˜Í Ô
(˜˜Ô 
x˜˜ Ò
.˜˜Ò Ú
APagar˜˜Ú ¯
,˜˜¯ ˘
$num˜˜˙ ˚
)˜˜˚ ¸
,˜˜¸ ˝$
saldoAFavorSiguiente˜˜˛ í
=˜˜ì î
Math˜˜ï ô
.˜˜ô ö
Round˜˜ö ü
(˜˜ü †
x˜˜† °
.˜˜° ¢
SaldoSiguiente˜˜¢ ∞
,˜˜∞ ±
$num˜˜≤ ≥
)˜˜≥ ¥
}˜˜µ ∂
)˜˜∂ ∑
,˜˜∑ ∏
}
¯¯ 
,
¯¯ 
}
˘˘ 	
)
˘˘	 

;
˘˘
 
}
˙˙ 
internal
¸¸ 
sealed
¸¸ 
record
¸¸ 
IgvMonth
¸¸ #
(
¸¸# $
DateOnly
¸¸$ ,
Month
¸¸- 2
,
¸¸2 3
decimal
¸¸4 ;
Debito
¸¸< B
,
¸¸B C
decimal
¸¸D K
Credito
¸¸L S
,
¸¸S T
decimal
¸¸U \
SaldoAnterior
¸¸] j
,
¸¸j k
decimal
¸¸l s
APagar
¸¸t z
,
¸¸z {
decimal¸¸| É
SaldoSiguiente¸¸Ñ í
)¸¸í ì
;¸¸ì î
internal
ÇÇ 
async
ÇÇ 
Task
ÇÇ 
<
ÇÇ 
List
ÇÇ 
<
ÇÇ 
IgvMonth
ÇÇ %
>
ÇÇ% &
>
ÇÇ& '
IgvMonthsAsync
ÇÇ( 6
(
ÇÇ6 7
DateOnly
ÇÇ7 ?
to
ÇÇ@ B
,
ÇÇB C
CancellationToken
ÇÇD U
ct
ÇÇV X
)
ÇÇX Y
{
ÉÉ 
var
ÑÑ 
end
ÑÑ 
=
ÑÑ 
new
ÑÑ 
DateOnly
ÑÑ 
(
ÑÑ 
to
ÑÑ !
.
ÑÑ! "
Year
ÑÑ" &
,
ÑÑ& '
to
ÑÑ( *
.
ÑÑ* +
Month
ÑÑ+ 0
,
ÑÑ0 1
$num
ÑÑ2 3
)
ÑÑ3 4
;
ÑÑ4 5
DateOnly
ÖÖ 
?
ÖÖ 
	firstSale
ÖÖ 
=
ÖÖ 
await
ÖÖ #
db
ÖÖ$ &
.
ÖÖ& '!
PaymentTransactions
ÖÖ' :
.
ÖÖ: ;
OrderBy
ÖÖ; B
(
ÖÖB C
x
ÖÖC D
=>
ÖÖE G
x
ÖÖH I
.
ÖÖI J
	CreatedAt
ÖÖJ S
)
ÖÖS T
.
ÖÖT U
Select
ÖÖU [
(
ÖÖ[ \
x
ÖÖ\ ]
=>
ÖÖ^ `
(
ÖÖa b
DateTime
ÖÖb j
?
ÖÖj k
)
ÖÖk l
x
ÖÖl m
.
ÖÖm n
	CreatedAt
ÖÖn w
)
ÖÖw x
.
ÖÖx y"
FirstOrDefaultAsyncÖÖy å
(ÖÖå ç
ctÖÖç è
)ÖÖè ê
isÖÖë ì
DateTimeÖÖî ú
dÖÖù û
?ÖÖü †
DateOnlyÖÖ° ©
.ÖÖ© ™
FromDateTimeÖÖ™ ∂
(ÖÖ∂ ∑
dÖÖ∑ ∏
)ÖÖ∏ π
:ÖÖ∫ ª
nullÖÖº ¿
;ÖÖ¿ ¡
DateOnly
ÜÜ 
?
ÜÜ 
firstPurchase
ÜÜ 
=
ÜÜ  !
await
ÜÜ" '
db
ÜÜ( *
.
ÜÜ* +
	Purchases
ÜÜ+ 4
.
ÜÜ4 5
OrderBy
ÜÜ5 <
(
ÜÜ< =
x
ÜÜ= >
=>
ÜÜ? A
x
ÜÜB C
.
ÜÜC D
Period
ÜÜD J
)
ÜÜJ K
.
ÜÜK L
Select
ÜÜL R
(
ÜÜR S
x
ÜÜS T
=>
ÜÜU W
(
ÜÜX Y
DateOnly
ÜÜY a
?
ÜÜa b
)
ÜÜb c
x
ÜÜc d
.
ÜÜd e
Period
ÜÜe k
)
ÜÜk l
.
ÜÜl m"
FirstOrDefaultAsyncÜÜm Ä
(ÜÜÄ Å
ctÜÜÅ É
)ÜÜÉ Ñ
;ÜÜÑ Ö
var
áá 
first
áá 
=
áá 
new
áá 
[
áá 
]
áá 
{
áá 
	firstSale
áá %
,
áá% &
firstPurchase
áá' 4
}
áá5 6
.
áá6 7
Where
áá7 <
(
áá< =
x
áá= >
=>
áá? A
x
ááB C
is
ááD F
not
ááG J
null
ááK O
)
ááO P
.
ááP Q
Select
ááQ W
(
ááW X
x
ááX Y
=>
ááZ \
x
áá] ^
!
áá^ _
.
áá_ `
Value
áá` e
)
ááe f
.
ááf g
DefaultIfEmpty
áág u
(
ááu v
end
ááv y
)
ááy z
.
ááz {
Min
áá{ ~
(
áá~ 
)áá Ä
;ááÄ Å
var
àà 
start
àà 
=
àà 
new
àà 
DateOnly
àà  
(
àà  !
first
àà! &
.
àà& '
Year
àà' +
,
àà+ ,
first
àà- 2
.
àà2 3
Month
àà3 8
,
àà8 9
$num
àà: ;
)
àà; <
;
àà< =
if
ââ 

(
ââ 
start
ââ 
>
ââ 
end
ââ 
)
ââ 
start
ââ 
=
ââ  
end
ââ! $
;
ââ$ %
var
ää 
sales
ää 
=
ää 
await
ää 

SalesAsync
ää $
(
ää$ %
start
ää% *
,
ää* +
end
ää, /
.
ää/ 0
	AddMonths
ää0 9
(
ää9 :
$num
ää: ;
)
ää; <
.
ää< =
AddDays
ää= D
(
ääD E
-
ääE F
$num
ääF G
)
ääG H
,
ääH I
ct
ääJ L
)
ääL M
;
ääM N
var
ãã 
	purchases
ãã 
=
ãã 
await
ãã 
db
ãã  
.
ãã  !
	Purchases
ãã! *
.
ãã* +
Where
ãã+ 0
(
ãã0 1
x
ãã1 2
=>
ãã3 5
x
ãã6 7
.
ãã7 8
Period
ãã8 >
>=
ãã? A
start
ããB G
&&
ããH J
x
ããK L
.
ããL M
Period
ããM S
<=
ããT V
end
ããW Z
)
ããZ [
.
ãã[ \
ToListAsync
ãã\ g
(
ããg h
ct
ããh j
)
ããj k
;
ããk l
var
çç 
settings
çç 
=
çç 
await
çç 
TaxSettingsRow
çç +
(
çç+ ,
ct
çç, .
)
çç. /
;
çç/ 0
var
éé 
form1662
éé 
=
éé 
settings
éé 
.
éé  
Use1662AsCredit
éé  /
?
èè 
(
èè 
await
èè 
db
èè 
.
èè 
Expenses
èè  
.
èè  !
Where
èè! &
(
èè& '
x
èè' (
=>
èè) +
x
èè, -
.
èè- .#
IsNonDomiciledService
èè. C
&&
èèD F
x
èèG H
.
èèH I
Form1662PaidAt
èèI W
!=
èèX Z
null
èè[ _
&&
èè` b
x
èèc d
.
èèd e
Form1662PaidAt
èèe s
>=
èèt v
start
èèw |
&&
èè} 
xèèÄ Å
.èèÅ Ç
Form1662PaidAtèèÇ ê
<=èèë ì
endèèî ó
.èèó ò
	AddMonthsèèò °
(èè° ¢
$numèè¢ £
)èè£ §
.èè§ •
AddDaysèè• ¨
(èè¨ ≠
-èè≠ Æ
$numèèÆ Ø
)èèØ ∞
)èè∞ ±
.èè± ≤
ToListAsyncèè≤ Ω
(èèΩ æ
ctèèæ ¿
)èè¿ ¡
)èè¡ ¬
.
êê 
GroupBy
êê 
(
êê 
x
êê 
=>
êê 
new
êê !
DateOnly
êê" *
(
êê* +
x
êê+ ,
.
êê, -
Form1662PaidAt
êê- ;
!
êê; <
.
êê< =
Value
êê= B
.
êêB C
Year
êêC G
,
êêG H
x
êêI J
.
êêJ K
Form1662PaidAt
êêK Y
.
êêY Z
Value
êêZ _
.
êê_ `
Month
êê` e
,
êêe f
$num
êêg h
)
êêh i
)
êêi j
.
êêj k
ToDictionary
êêk w
(
êêw x
g
êêx y
=>
êêz |
g
êê} ~
.
êê~ 
Keyêê Ç
,êêÇ É
gêêÑ Ö
=>êêÜ à
gêêâ ä
.êêä ã
Sumêêã é
(êêé è
xêêè ê
=>êêë ì
Form1662êêî ú
.êêú ù
Igvêêù †
(êê† °
xêê° ¢
,êê¢ £
settingsêê§ ¨
.êê¨ ≠
IgvRateêê≠ ¥
)êê¥ µ
)êêµ ∂
)êê∂ ∑
:
ëë 
[
ëë 
]
ëë 
;
ëë 
var
íí 
months
íí 
=
íí 
new
íí 
List
íí 
<
íí 
IgvMonth
íí &
>
íí& '
(
íí' (
)
íí( )
;
íí) *
var
íí+ .
carry
íí/ 4
=
íí5 6
$num
íí7 9
;
íí9 :
for
ìì 
(
ìì 
var
ìì 
month
ìì 
=
ìì 
start
ìì 
;
ìì 
month
ìì  %
<=
ìì& (
end
ìì) ,
;
ìì, -
month
ìì. 3
=
ìì4 5
month
ìì6 ;
.
ìì; <
	AddMonths
ìì< E
(
ììE F
$num
ììF G
)
ììG H
)
ììH I
{
îî 	
var
ïï 
monthEnd
ïï 
=
ïï 
month
ïï  
.
ïï  !
	AddMonths
ïï! *
(
ïï* +
$num
ïï+ ,
)
ïï, -
.
ïï- .
AddDays
ïï. 5
(
ïï5 6
-
ïï6 7
$num
ïï7 8
)
ïï8 9
;
ïï9 :
var
ññ 
debito
ññ 
=
ññ 
sales
ññ 
.
ññ 
Where
ññ $
(
ññ$ %
x
ññ% &
=>
ññ' )
x
ññ* +
.
ññ+ ,
Date
ññ, 0
>=
ññ1 3
month
ññ4 9
&&
ññ: <
x
ññ= >
.
ññ> ?
Date
ññ? C
<=
ññD F
monthEnd
ññG O
)
ññO P
.
ññP Q
Sum
ññQ T
(
ññT U
x
ññU V
=>
ññW Y
x
ññZ [
.
ññ[ \
IgvPen
ññ\ b
)
ññb c
;
ññc d
var
óó 
credito
óó 
=
óó 
	purchases
óó #
.
óó# $
Where
óó$ )
(
óó) *
x
óó* +
=>
óó, .
x
óó/ 0
.
óó0 1
Period
óó1 7
==
óó8 :
month
óó; @
)
óó@ A
.
óóA B
Sum
óóB E
(
óóE F
x
óóF G
=>
óóH J
x
óóK L
.
óóL M
TaxCreditPen
óóM Y
)
óóY Z
+
óó[ \
form1662
óó] e
.
óóe f
GetValueOrDefault
óóf w
(
óów x
month
óóx }
)
óó} ~
;
óó~ 
var
òò 
result
òò 
=
òò 
debito
òò 
-
òò  !
credito
òò" )
-
òò* +
carry
òò, 1
;
òò1 2
months
ôô 
.
ôô 
Add
ôô 
(
ôô 
new
ôô 
IgvMonth
ôô #
(
ôô# $
month
ôô$ )
,
ôô) *
debito
ôô+ 1
,
ôô1 2
credito
ôô3 :
,
ôô: ;
carry
ôô< A
,
ôôA B
Math
ôôC G
.
ôôG H
Max
ôôH K
(
ôôK L
result
ôôL R
,
ôôR S
$num
ôôT V
)
ôôV W
,
ôôW X
Math
ôôY ]
.
ôô] ^
Max
ôô^ a
(
ôôa b
-
ôôb c
result
ôôc i
,
ôôi j
$num
ôôk m
)
ôôm n
)
ôôn o
)
ôôo p
;
ôôp q
carry
öö 
=
öö 
Math
öö 
.
öö 
Max
öö 
(
öö 
-
öö 
result
öö $
,
öö$ %
$num
öö& (
)
öö( )
;
öö) *
}
õõ 	
return
úú 
months
úú 
;
úú 
}
ùù 
[
üü 
HttpGet
üü 
(
üü 
$str
üü 
)
üü  
]
üü  !
public
†† 

async
†† 
Task
†† 
<
†† 
ActionResult
†† "
>
††" #
ExpensesReport
††$ 2
(
††2 3
int
††3 6
?
††6 7
month
††8 =
,
††= >
int
††? B
year
††C G
,
††G H
CancellationToken
††I Z
ct
††[ ]
)
††] ^
{
°° 
var
¢¢ 
(
¢¢ 
from
¢¢ 
,
¢¢ 
to
¢¢ 
)
¢¢ 
=
¢¢ 
Period
¢¢ 
(
¢¢  
month
¢¢  %
,
¢¢% &
year
¢¢' +
)
¢¢+ ,
;
¢¢, -
var
££ 
expenses
££ 
=
££ 
await
££ 
db
££ 
.
££  
Expenses
££  (
.
££( )
Include
££) 0
(
££0 1
x
££1 2
=>
££3 5
x
££6 7
.
££7 8
Category
££8 @
)
££@ A
.
££A B
Where
££B G
(
££G H
x
££H I
=>
££J L
x
££M N
.
££N O
Date
££O S
>=
££T V
from
££W [
&&
££\ ^
x
££_ `
.
££` a
Date
££a e
<=
££f h
to
££i k
)
££k l
.
££l m
ToListAsync
££m x
(
££x y
ct
££y {
)
££{ |
;
££| }
return
§§ 
Ok
§§ 
(
§§ 
new
§§ 
{
§§ 
total
§§ 
=
§§ 
Math
§§  $
.
§§$ %
Round
§§% *
(
§§* +
expenses
§§+ 3
.
§§3 4
Sum
§§4 7
(
§§7 8
x
§§8 9
=>
§§: <
x
§§= >
.
§§> ?
	AmountPen
§§? H
)
§§H I
,
§§I J
$num
§§K L
)
§§L M
,
§§M N
porCategoria
§§O [
=
§§\ ]
expenses
§§^ f
.
§§f g
GroupBy
§§g n
(
§§n o
x
§§o p
=>
§§q s
x
§§t u
.
§§u v
Category
§§v ~
?
§§~ 
.§§ Ä
Name§§Ä Ñ
??§§Ö á
$str§§à ó
)§§ó ò
.§§ò ô!
OrderByDescending§§ô ™
(§§™ ´
g§§´ ¨
=>§§≠ Ø
g§§∞ ±
.§§± ≤
Sum§§≤ µ
(§§µ ∂
x§§∂ ∑
=>§§∏ ∫
x§§ª º
.§§º Ω
	AmountPen§§Ω ∆
)§§∆ «
)§§« »
.§§» …
Select§§… œ
(§§œ –
g§§– —
=>§§“ ‘
new§§’ ÿ
{§§Ÿ ⁄
	categoria§§€ ‰
=§§Â Ê
g§§Á Ë
.§§Ë È
Key§§È Ï
,§§Ï Ì
monto§§Ó Û
=§§Ù ı
Math§§ˆ ˙
.§§˙ ˚
Round§§˚ Ä
(§§Ä Å
g§§Å Ç
.§§Ç É
Sum§§É Ü
(§§Ü á
x§§á à
=>§§â ã
x§§å ç
.§§ç é
	AmountPen§§é ó
)§§ó ò
,§§ò ô
$num§§ö õ
)§§õ ú
}§§ù û
)§§û ü
}§§† °
)§§° ¢
;§§¢ £
}
•• 
[
¨¨ 
HttpGet
¨¨ 
(
¨¨ 
$str
¨¨ 
)
¨¨ 
]
¨¨ 
public
≠≠ 

async
≠≠ 
Task
≠≠ 
<
≠≠ 
ActionResult
≠≠ "
>
≠≠" #
	NetReport
≠≠$ -
(
≠≠- .
int
≠≠. 1
?
≠≠1 2
month
≠≠3 8
,
≠≠8 9
int
≠≠: =
year
≠≠> B
,
≠≠B C
CancellationToken
≠≠D U
ct
≠≠V X
)
≠≠X Y
{
ÆÆ 
var
ØØ 
settings
ØØ 
=
ØØ 
await
ØØ 
TaxSettingsRow
ØØ +
(
ØØ+ ,
ct
ØØ, .
)
ØØ. /
;
ØØ/ 0
var
∞∞ 
(
∞∞ 
from
∞∞ 
,
∞∞ 
to
∞∞ 
)
∞∞ 
=
∞∞ 
Period
∞∞ 
(
∞∞  
month
∞∞  %
,
∞∞% &
year
∞∞' +
)
∞∞+ ,
;
∞∞, -
var
±± 
sales
±± 
=
±± 
await
±± 

SalesAsync
±± $
(
±±$ %
from
±±% )
,
±±) *
to
±±+ -
,
±±- .
ct
±±/ 1
)
±±1 2
;
±±2 3
var
≤≤ 
expenses
≤≤ 
=
≤≤ 
await
≤≤ 
db
≤≤ 
.
≤≤  
Expenses
≤≤  (
.
≤≤( )
Include
≤≤) 0
(
≤≤0 1
x
≤≤1 2
=>
≤≤3 5
x
≤≤6 7
.
≤≤7 8
Category
≤≤8 @
)
≤≤@ A
.
≤≤A B
Where
≤≤B G
(
≤≤G H
x
≤≤H I
=>
≤≤J L
x
≤≤M N
.
≤≤N O
Date
≤≤O S
>=
≤≤T V
from
≤≤W [
&&
≤≤\ ^
x
≤≤_ `
.
≤≤` a
Date
≤≤a e
<=
≤≤f h
to
≤≤i k
)
≤≤k l
.
≤≤l m
ToListAsync
≤≤m x
(
≤≤x y
ct
≤≤y {
)
≤≤{ |
;
≤≤| }
var
≥≥ 
result
≥≥ 
=
≥≥ 

NetFigures
≥≥ 
(
≥≥  
sales
≥≥  %
,
≥≥% &
expenses
≥≥' /
,
≥≥/ 0
settings
≥≥1 9
.
≥≥9 :
	RentaRate
≥≥: C
)
≥≥C D
;
≥≥D E
var
¥¥ 
serie
¥¥ 
=
¥¥ 

Enumerable
¥¥ 
.
¥¥ 
Range
¥¥ $
(
¥¥$ %
$num
¥¥% &
,
¥¥& '
month
¥¥( -
is
¥¥. 0
null
¥¥1 5
?
¥¥6 7
$num
¥¥8 :
:
¥¥; <
$num
¥¥= >
)
¥¥> ?
.
¥¥? @
Select
¥¥@ F
(
¥¥F G
i
¥¥G H
=>
¥¥I K
from
¥¥L P
.
¥¥P Q
	AddMonths
¥¥Q Z
(
¥¥Z [
i
¥¥[ \
)
¥¥\ ]
)
¥¥] ^
.
¥¥^ _
Select
¥¥_ e
(
¥¥e f
start
¥¥f k
=>
¥¥l n
{
µµ 	
var
∂∂ 
end
∂∂ 
=
∂∂ 
start
∂∂ 
.
∂∂ 
	AddMonths
∂∂ %
(
∂∂% &
$num
∂∂& '
)
∂∂' (
.
∂∂( )
AddDays
∂∂) 0
(
∂∂0 1
-
∂∂1 2
$num
∂∂2 3
)
∂∂3 4
;
∂∂4 5
var
∑∑ 
n
∑∑ 
=
∑∑ 

NetFigures
∑∑ 
(
∑∑ 
sales
∑∑ $
.
∑∑$ %
Where
∑∑% *
(
∑∑* +
x
∑∑+ ,
=>
∑∑- /
x
∑∑0 1
.
∑∑1 2
Date
∑∑2 6
>=
∑∑7 9
start
∑∑: ?
&&
∑∑@ B
x
∑∑C D
.
∑∑D E
Date
∑∑E I
<=
∑∑J L
end
∑∑M P
)
∑∑P Q
,
∑∑Q R
expenses
∑∑S [
.
∑∑[ \
Where
∑∑\ a
(
∑∑a b
x
∑∑b c
=>
∑∑d f
x
∑∑g h
.
∑∑h i
Date
∑∑i m
>=
∑∑n p
start
∑∑q v
&&
∑∑w y
x
∑∑z {
.
∑∑{ |
Date∑∑| Ä
<=∑∑Å É
end∑∑Ñ á
)∑∑á à
,∑∑à â
settings∑∑ä í
.∑∑í ì
	RentaRate∑∑ì ú
)∑∑ú ù
;∑∑ù û
return
∏∏ 
new
∏∏ 
NetPoint
∏∏ 
(
∏∏  
start
∏∏  %
.
∏∏% &
ToString
∏∏& .
(
∏∏. /
$str
∏∏/ 8
)
∏∏8 9
,
∏∏9 :
Math
∏∏; ?
.
∏∏? @
Round
∏∏@ E
(
∏∏E F
n
∏∏F G
.
∏∏G H
Ventas
∏∏H N
,
∏∏N O
$num
∏∏P Q
)
∏∏Q R
,
∏∏R S
Math
∏∏T X
.
∏∏X Y
Round
∏∏Y ^
(
∏∏^ _
n
∏∏_ `
.
∏∏` a
Gastos
∏∏a g
,
∏∏g h
$num
∏∏i j
)
∏∏j k
,
∏∏k l
Math
∏∏m q
.
∏∏q r
Round
∏∏r w
(
∏∏w x
n
∏∏x y
.
∏∏y z
	Impuestos∏∏z É
,∏∏É Ñ
$num∏∏Ö Ü
)∏∏Ü á
,∏∏á à
Math∏∏â ç
.∏∏ç é
Round∏∏é ì
(∏∏ì î
n∏∏î ï
.∏∏ï ñ
Neta∏∏ñ ö
,∏∏ö õ
$num∏∏ú ù
)∏∏ù û
)∏∏û ü
;∏∏ü †
}
ππ 	
)
ππ	 

.
ππ
 
ToList
ππ 
(
ππ 
)
ππ 
;
ππ 
return
∫∫ 
Ok
∫∫ 
(
∫∫ 
new
∫∫ 
{
ªª 	
	ventasPen
ºº 
=
ºº 
Math
ºº 
.
ºº 
Round
ºº "
(
ºº" #
result
ºº# )
.
ºº) *
Ventas
ºº* 0
,
ºº0 1
$num
ºº2 3
)
ºº3 4
,
ºº4 5
	gastosPen
ºº6 ?
=
ºº@ A
Math
ººB F
.
ººF G
Round
ººG L
(
ººL M
result
ººM S
.
ººS T
Gastos
ººT Z
,
ººZ [
$num
ºº\ ]
)
ºº] ^
,
ºº^ _"
utilidadOperativaPen
ºº` t
=
ººu v
Math
ººw {
.
ºº{ |
Roundºº| Å
(ººÅ Ç
resultººÇ à
.ººà â
Ventasººâ è
-ººê ë
resultººí ò
.ººò ô
Gastosººô ü
,ººü †
$numºº° ¢
)ºº¢ £
,ºº£ §
	rentaRate
ΩΩ 
=
ΩΩ 
settings
ΩΩ  
.
ΩΩ  !
	RentaRate
ΩΩ! *
,
ΩΩ* +
impuestosPen
ΩΩ, 8
=
ΩΩ9 :
Math
ΩΩ; ?
.
ΩΩ? @
Round
ΩΩ@ E
(
ΩΩE F
result
ΩΩF L
.
ΩΩL M
	Impuestos
ΩΩM V
,
ΩΩV W
$num
ΩΩX Y
)
ΩΩY Z
,
ΩΩZ [
utilidadNetaPen
ææ 
=
ææ 
Math
ææ "
.
ææ" #
Round
ææ# (
(
ææ( )
result
ææ) /
.
ææ/ 0
Neta
ææ0 4
,
ææ4 5
$num
ææ6 7
)
ææ7 8
,
ææ8 9
margen
ææ: @
=
ææA B
result
ææC I
.
ææI J
Ventas
ææJ P
==
ææQ S
$num
ææT U
?
ææV W
$num
ææX Z
:
ææ[ \
Math
ææ] a
.
ææa b
Round
ææb g
(
ææg h
result
ææh n
.
ææn o
Neta
ææo s
/
ææt u
result
ææv |
.
ææ| }
Ventasææ} É
*ææÑ Ö
$numææÜ â
,ææâ ä
$numææã å
)ææå ç
,ææç é
serie
øø 
,
øø 

disclaimer
øø 
=
øø 
TaxDisclaimer
øø  -
,
øø- .
}
¿¿ 	
)
¿¿	 

;
¿¿
 
}
¡¡ 
private
√√ 
sealed
√√ 
record
√√ 
NetPoint
√√ "
(
√√" #
string
√√# )
Mes
√√* -
,
√√- .
decimal
√√/ 6
	VentasPen
√√7 @
,
√√@ A
decimal
√√B I
	GastosPen
√√J S
,
√√S T
decimal
√√U \
ImpuestosPen
√√] i
,
√√i j
decimal
√√k r
UtilidadNetaPen√√s Ç
)√√Ç É
;√√É Ñ
private
∆∆ 
static
∆∆ 
(
∆∆ 
decimal
∆∆ 
Ventas
∆∆ "
,
∆∆" #
decimal
∆∆$ +
Gastos
∆∆, 2
,
∆∆2 3
decimal
∆∆4 ;
	Impuestos
∆∆< E
,
∆∆E F
decimal
∆∆G N
Neta
∆∆O S
)
∆∆S T

NetFigures
∆∆U _
(
∆∆_ `
IEnumerable
∆∆` k
<
∆∆k l
Sale
∆∆l p
>
∆∆p q
sales
∆∆r w
,
∆∆w x
IEnumerable∆∆y Ñ
<∆∆Ñ Ö
Expense∆∆Ö å
>∆∆å ç
expenses∆∆é ñ
,∆∆ñ ó
decimal∆∆ò ü
	rentaRate∆∆† ©
)∆∆© ™
{
«« 
var
»» 
ventas
»» 
=
»» 
sales
»» 
.
»» 
Sum
»» 
(
»» 
x
»»  
=>
»»! #
x
»»$ %
.
»»% &
BasePen
»»& -
)
»»- .
;
»». /
var
…… 
gastos
…… 
=
…… 
expenses
…… 
.
…… 
Where
…… #
(
……# $
x
……$ %
=>
……& (
x
……) *
.
……* +
Category
……+ 3
?
……3 4
.
……4 5
IsIncomeTax
……5 @
!=
……A C
true
……D H
)
……H I
.
……I J
Sum
……J M
(
……M N
x
……N O
=>
……P R
x
……S T
.
……T U
	AmountPen
……U ^
)
……^ _
;
……_ `
var
   
	impuestos
   
=
   
sales
   
.
   
Where
   #
(
  # $
x
  $ %
=>
  & (
x
  ) *
.
  * +
Mype
  + /
)
  / 0
.
  0 1
Sum
  1 4
(
  4 5
x
  5 6
=>
  7 9
x
  : ;
.
  ; <
BasePen
  < C
)
  C D
*
  E F
	rentaRate
  G P
;
  P Q
return
ÀÀ 
(
ÀÀ 
ventas
ÀÀ 
,
ÀÀ 
gastos
ÀÀ 
,
ÀÀ 
	impuestos
ÀÀ  )
,
ÀÀ) *
ventas
ÀÀ+ 1
-
ÀÀ2 3
gastos
ÀÀ4 :
-
ÀÀ; <
	impuestos
ÀÀ= F
)
ÀÀF G
;
ÀÀG H
}
ÃÃ 
[
œœ 
HttpGet
œœ 
(
œœ 
$str
œœ 
)
œœ 
]
œœ  
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
––" #
ClientsReport
––$ 1
(
––1 2
int
––2 5
?
––5 6
month
––7 <
,
––< =
int
––> A
year
––B F
,
––F G
CancellationToken
––H Y
ct
––Z \
)
––\ ]
{
—— 
var
““ 
(
““ 
total
““ 
,
““ 
clientes
““ 
)
““ 
=
““ 
await
““  % 
ClientRankingAsync
““& 8
(
““8 9
month
““9 >
,
““> ?
year
““@ D
,
““D E
ct
““F H
)
““H I
;
““I J
return
”” 
Ok
”” 
(
”” 
new
”” 
{
”” 
totalPen
””  
=
””! "
total
””# (
,
””( )
clientes
””* 2
}
””3 4
)
””4 5
;
””5 6
}
‘‘ 
private
÷÷ 
sealed
÷÷ 
record
÷÷ 
ClientRankingRow
÷÷ *
(
÷÷* +
Guid
÷÷+ /
ClientId
÷÷0 8
,
÷÷8 9
string
÷÷: @

ClientName
÷÷A K
,
÷÷K L
decimal
÷÷M T
IngresosPen
÷÷U `
,
÷÷` a
decimal
÷÷b i

Porcentaje
÷÷j t
,
÷÷t u
decimal
÷÷v }"
PorcentajeAcumulado÷÷~ ë
,÷÷ë í
int÷÷ì ñ
Cobros÷÷ó ù
,÷÷ù û
DateOnly÷÷ü ß
UltimoCobro÷÷® ≥
,÷÷≥ ¥
decimal÷÷µ º"
PeriodoAnteriorPen÷÷Ω œ
,÷÷œ –
decimal÷÷— ÿ
?÷÷ÿ Ÿ#
VariacionPorcentaje÷÷⁄ Ì
)÷÷Ì Ó
;÷÷Ó Ô
private
ÿÿ 
async
ÿÿ 
Task
ÿÿ 
<
ÿÿ 
(
ÿÿ 
decimal
ÿÿ 
Total
ÿÿ  %
,
ÿÿ% &
List
ÿÿ' +
<
ÿÿ+ ,
ClientRankingRow
ÿÿ, <
>
ÿÿ< =
Rows
ÿÿ> B
)
ÿÿB C
>
ÿÿC D 
ClientRankingAsync
ÿÿE W
(
ÿÿW X
int
ÿÿX [
?
ÿÿ[ \
month
ÿÿ] b
,
ÿÿb c
int
ÿÿd g
year
ÿÿh l
,
ÿÿl m
CancellationToken
ÿÿn 
ctÿÿÄ Ç
)ÿÿÇ É
{
ŸŸ 
var
⁄⁄ 
(
⁄⁄ 
from
⁄⁄ 
,
⁄⁄ 
to
⁄⁄ 
)
⁄⁄ 
=
⁄⁄ 
Period
⁄⁄ 
(
⁄⁄  
month
⁄⁄  %
,
⁄⁄% &
year
⁄⁄' +
)
⁄⁄+ ,
;
⁄⁄, -
var
⁄⁄. 1
(
⁄⁄2 3
previousFrom
⁄⁄3 ?
,
⁄⁄? @

previousTo
⁄⁄A K
)
⁄⁄K L
=
⁄⁄M N
PreviousPeriod
⁄⁄O ]
(
⁄⁄] ^
month
⁄⁄^ c
,
⁄⁄c d
year
⁄⁄e i
)
⁄⁄i j
;
⁄⁄j k
var
€€ 
sales
€€ 
=
€€ 
await
€€ 

SalesAsync
€€ $
(
€€$ %
from
€€% )
,
€€) *
to
€€+ -
,
€€- .
ct
€€/ 1
)
€€1 2
;
€€2 3
var
‹‹ 
previous
‹‹ 
=
‹‹ 
(
‹‹ 
await
‹‹ 

SalesAsync
‹‹ (
(
‹‹( )
previousFrom
‹‹) 5
,
‹‹5 6

previousTo
‹‹7 A
,
‹‹A B
ct
‹‹C E
)
‹‹E F
)
‹‹F G
.
‹‹G H
GroupBy
‹‹H O
(
‹‹O P
x
‹‹P Q
=>
‹‹R T
x
‹‹U V
.
‹‹V W
ClientId
‹‹W _
)
‹‹_ `
.
‹‹` a
ToDictionary
‹‹a m
(
‹‹m n
g
‹‹n o
=>
‹‹p r
g
‹‹s t
.
‹‹t u
Key
‹‹u x
,
‹‹x y
g
‹‹z {
=>
‹‹| ~
g‹‹ Ä
.‹‹Ä Å
Sum‹‹Å Ñ
(‹‹Ñ Ö
x‹‹Ö Ü
=>‹‹á â
x‹‹ä ã
.‹‹ã å
BasePen‹‹å ì
)‹‹ì î
)‹‹î ï
;‹‹ï ñ
var
›› 
names
›› 
=
›› 
await
›› 
db
›› 
.
›› 
Clients
›› $
.
››$ %
ToDictionaryAsync
››% 6
(
››6 7
x
››7 8
=>
››9 ;
x
››< =
.
››= >
Id
››> @
,
››@ A
x
››B C
=>
››D F
x
››G H
.
››H I
CompanyName
››I T
,
››T U
ct
››V X
)
››X Y
;
››Y Z
var
ﬁﬁ 
total
ﬁﬁ 
=
ﬁﬁ 
sales
ﬁﬁ 
.
ﬁﬁ 
Sum
ﬁﬁ 
(
ﬁﬁ 
x
ﬁﬁ 
=>
ﬁﬁ  "
x
ﬁﬁ# $
.
ﬁﬁ$ %
BasePen
ﬁﬁ% ,
)
ﬁﬁ, -
;
ﬁﬁ- .
var
ﬁﬁ/ 2
accumulated
ﬁﬁ3 >
=
ﬁﬁ? @
$num
ﬁﬁA C
;
ﬁﬁC D
var
ﬂﬂ 
rows
ﬂﬂ 
=
ﬂﬂ 
sales
ﬂﬂ 
.
ﬂﬂ 
GroupBy
ﬂﬂ  
(
ﬂﬂ  !
x
ﬂﬂ! "
=>
ﬂﬂ# %
x
ﬂﬂ& '
.
ﬂﬂ' (
ClientId
ﬂﬂ( 0
)
ﬂﬂ0 1
.
ﬂﬂ1 2
Select
ﬂﬂ2 8
(
ﬂﬂ8 9
g
ﬂﬂ9 :
=>
ﬂﬂ; =
new
ﬂﬂ> A
{
ﬂﬂB C
ClientId
ﬂﬂD L
=
ﬂﬂM N
g
ﬂﬂO P
.
ﬂﬂP Q
Key
ﬂﬂQ T
,
ﬂﬂT U
Pen
ﬂﬂV Y
=
ﬂﬂZ [
g
ﬂﬂ\ ]
.
ﬂﬂ] ^
Sum
ﬂﬂ^ a
(
ﬂﬂa b
x
ﬂﬂb c
=>
ﬂﬂd f
x
ﬂﬂg h
.
ﬂﬂh i
BasePen
ﬂﬂi p
)
ﬂﬂp q
,
ﬂﬂq r
Count
ﬂﬂs x
=
ﬂﬂy z
g
ﬂﬂ{ |
.
ﬂﬂ| }
Countﬂﬂ} Ç
(ﬂﬂÇ É
)ﬂﬂÉ Ñ
,ﬂﬂÑ Ö
LastﬂﬂÜ ä
=ﬂﬂã å
gﬂﬂç é
.ﬂﬂé è
Maxﬂﬂè í
(ﬂﬂí ì
xﬂﬂì î
=>ﬂﬂï ó
xﬂﬂò ô
.ﬂﬂô ö
Dateﬂﬂö û
)ﬂﬂû ü
}ﬂﬂ† °
)ﬂﬂ° ¢
.ﬂﬂ¢ £!
OrderByDescendingﬂﬂ£ ¥
(ﬂﬂ¥ µ
xﬂﬂµ ∂
=>ﬂﬂ∑ π
xﬂﬂ∫ ª
.ﬂﬂª º
Penﬂﬂº ø
)ﬂﬂø ¿
.ﬂﬂ¿ ¡
Selectﬂﬂ¡ «
(ﬂﬂ« »
xﬂﬂ» …
=>ﬂﬂ  Ã
{
‡‡ 	
accumulated
·· 
+=
·· 
x
·· 
.
·· 
Pen
··  
;
··  !
var
‚‚ 
before
‚‚ 
=
‚‚ 
previous
‚‚ !
.
‚‚! "
GetValueOrDefault
‚‚" 3
(
‚‚3 4
x
‚‚4 5
.
‚‚5 6
ClientId
‚‚6 >
)
‚‚> ?
;
‚‚? @
return
„„ 
new
„„ 
ClientRankingRow
„„ '
(
„„' (
x
„„( )
.
„„) *
ClientId
„„* 2
,
„„2 3
names
„„4 9
.
„„9 :
GetValueOrDefault
„„: K
(
„„K L
x
„„L M
.
„„M N
ClientId
„„N V
)
„„V W
??
„„X Z
$str
„„[ p
,
„„p q
Math
„„r v
.
„„v w
Round
„„w |
(
„„| }
x
„„} ~
.
„„~ 
Pen„„ Ç
,„„Ç É
$num„„Ñ Ö
)„„Ö Ü
,„„Ü á
total„„à ç
==„„é ê
$num„„ë í
?„„ì î
$num„„ï ñ
:„„ó ò
Math„„ô ù
.„„ù û
Round„„û £
(„„£ §
x„„§ •
.„„• ¶
Pen„„¶ ©
/„„™ ´
total„„¨ ±
*„„≤ ≥
$num„„¥ ∑
,„„∑ ∏
$num„„π ∫
)„„∫ ª
,„„ª º
total„„Ω ¬
==„„√ ≈
$num„„∆ «
?„„» …
$num„„  À
:„„Ã Õ
Math„„Œ “
.„„“ ”
Round„„” ÿ
(„„ÿ Ÿ
accumulated„„Ÿ ‰
/„„Â Ê
total„„Á Ï
*„„Ì Ó
$num„„Ô Ú
,„„Ú Û
$num„„Ù ı
)„„ı ˆ
,„„ˆ ˜
x„„¯ ˘
.„„˘ ˙
Count„„˙ ˇ
,„„ˇ Ä
x„„Å Ç
.„„Ç É
Last„„É á
,„„á à
Math„„â ç
.„„ç é
Round„„é ì
(„„ì î
before„„î ö
,„„ö õ
$num„„ú ù
)„„ù û
,„„û ü
before„„† ¶
>„„ß ®
$num„„© ™
?„„´ ¨
Math„„≠ ±
.„„± ≤
Round„„≤ ∑
(„„∑ ∏
(„„∏ π
x„„π ∫
.„„∫ ª
Pen„„ª æ
-„„ø ¿
before„„¡ «
)„„« »
/„„…  
before„„À —
*„„“ ”
$num„„‘ ◊
,„„◊ ÿ
$num„„Ÿ ⁄
)„„⁄ €
:„„‹ ›
null„„ﬁ ‚
)„„‚ „
;„„„ ‰
}
‰‰ 	
)
‰‰	 

.
‰‰
 
ToList
‰‰ 
(
‰‰ 
)
‰‰ 
;
‰‰ 
return
ÂÂ 
(
ÂÂ 
Math
ÂÂ 
.
ÂÂ 
Round
ÂÂ 
(
ÂÂ 
total
ÂÂ  
,
ÂÂ  !
$num
ÂÂ" #
)
ÂÂ# $
,
ÂÂ$ %
rows
ÂÂ& *
)
ÂÂ* +
;
ÂÂ+ ,
}
ÊÊ 
[
ÈÈ 
HttpGet
ÈÈ 
(
ÈÈ 
$str
ÈÈ 
)
ÈÈ 
]
ÈÈ 
public
ÍÍ 

async
ÍÍ 
Task
ÍÍ 
<
ÍÍ 
IActionResult
ÍÍ #
>
ÍÍ# $
ExportReport
ÍÍ% 1
(
ÍÍ1 2
int
ÍÍ2 5
?
ÍÍ5 6
month
ÍÍ7 <
,
ÍÍ< =
int
ÍÍ> A
year
ÍÍB F
,
ÍÍF G
CancellationToken
ÍÍH Y
ct
ÍÍZ \
)
ÍÍ\ ]
{
ÎÎ 
var
ÏÏ 
settings
ÏÏ 
=
ÏÏ 
await
ÏÏ 
TaxSettingsRow
ÏÏ +
(
ÏÏ+ ,
ct
ÏÏ, .
)
ÏÏ. /
;
ÏÏ/ 0
var
ÌÌ 
(
ÌÌ 
from
ÌÌ 
,
ÌÌ 
to
ÌÌ 
)
ÌÌ 
=
ÌÌ 
Period
ÌÌ 
(
ÌÌ  
month
ÌÌ  %
,
ÌÌ% &
year
ÌÌ' +
)
ÌÌ+ ,
;
ÌÌ, -
var
ÓÓ 
sales
ÓÓ 
=
ÓÓ 
await
ÓÓ 

SalesAsync
ÓÓ $
(
ÓÓ$ %
from
ÓÓ% )
,
ÓÓ) *
to
ÓÓ+ -
,
ÓÓ- .
ct
ÓÓ/ 1
)
ÓÓ1 2
;
ÓÓ2 3
var
ÔÔ 
expenses
ÔÔ 
=
ÔÔ 
await
ÔÔ 
db
ÔÔ 
.
ÔÔ  
Expenses
ÔÔ  (
.
ÔÔ( )
Include
ÔÔ) 0
(
ÔÔ0 1
x
ÔÔ1 2
=>
ÔÔ3 5
x
ÔÔ6 7
.
ÔÔ7 8
Category
ÔÔ8 @
)
ÔÔ@ A
.
ÔÔA B
Where
ÔÔB G
(
ÔÔG H
x
ÔÔH I
=>
ÔÔJ L
x
ÔÔM N
.
ÔÔN O
Date
ÔÔO S
>=
ÔÔT V
from
ÔÔW [
&&
ÔÔ\ ^
x
ÔÔ_ `
.
ÔÔ` a
Date
ÔÔa e
<=
ÔÔf h
to
ÔÔi k
)
ÔÔk l
.
ÔÔl m
ToListAsync
ÔÔm x
(
ÔÔx y
ct
ÔÔy {
)
ÔÔ{ |
;
ÔÔ| }
var
 
net
 
=
 

NetFigures
 
(
 
sales
 "
,
" #
expenses
$ ,
,
, -
settings
. 6
.
6 7
	RentaRate
7 @
)
@ A
;
A B
var
ÒÒ 
(
ÒÒ 
_
ÒÒ 
,
ÒÒ 
ranking
ÒÒ 
)
ÒÒ 
=
ÒÒ 
await
ÒÒ   
ClientRankingAsync
ÒÒ! 3
(
ÒÒ3 4
month
ÒÒ4 9
,
ÒÒ9 :
year
ÒÒ; ?
,
ÒÒ? @
ct
ÒÒA C
)
ÒÒC D
;
ÒÒD E
using
ÛÛ 
var
ÛÛ 
book
ÛÛ 
=
ÛÛ 
new
ÛÛ 

XLWorkbook
ÛÛ '
(
ÛÛ' (
)
ÛÛ( )
;
ÛÛ) *
var
ÙÙ 
summary
ÙÙ 
=
ÙÙ 
book
ÙÙ 
.
ÙÙ 
AddWorksheet
ÙÙ '
(
ÙÙ' (
$str
ÙÙ( 2
)
ÙÙ2 3
;
ÙÙ3 4
(
ıı 	
string
ıı	 
Label
ıı 
,
ıı 
decimal
ıı 
Value
ıı $
)
ıı$ %
[
ıı% &
]
ıı& '
figures
ıı( /
=
ıı0 1
[
ıı2 3
(
ıı3 4
$str
ıı4 J
,
ııJ K
net
ııL O
.
ııO P
Ventas
ııP V
)
ııV W
,
ııW X
(
ııY Z
$str
ııZ s
,
ııs t
net
ııu x
.
ııx y
Gastos
ııy 
)ıı Ä
,ııÄ Å
(ııÇ É
$strııÉ ù
,ııù û
netııü ¢
.ıı¢ £
Ventasıı£ ©
-ıı™ ´
netıı¨ Ø
.ııØ ∞
Gastosıı∞ ∂
)ıı∂ ∑
,ıı∑ ∏
(ııπ ∫
$"ıı∫ º
$strııº —
{ıı— “
settingsıı“ ⁄
.ıı⁄ €
	RentaRateıı€ ‰
*ııÂ Ê
$numııÁ Í
:ııÍ Î
$strııÎ Ô
}ııÔ 
$strıı ¯
"ıı¯ ˘
,ıı˘ ˙
netıı˚ ˛
.ıı˛ ˇ
	Impuestosııˇ à
)ııà â
,ııâ ä
(ııã å
$strııå °
,ıı° ¢
netıı£ ¶
.ıı¶ ß
Netaııß ´
)ıı´ ¨
,ıı¨ ≠
(ııÆ Ø
$strııØ æ
,ııæ ø
netıı¿ √
.ıı√ ƒ
Ventasııƒ  
==ııÀ Õ
$numııŒ œ
?ıı– —
$numıı“ ”
:ıı‘ ’
netıı÷ Ÿ
.ııŸ ⁄
Netaıı⁄ ﬁ
/ııﬂ ‡
netıı· ‰
.ıı‰ Â
VentasııÂ Î
*ııÏ Ì
$numııÓ Ò
)ııÒ Ú
]ııÚ Û
;ııÛ Ù
for
ˆˆ 
(
ˆˆ 
var
ˆˆ 
i
ˆˆ 
=
ˆˆ 
$num
ˆˆ 
;
ˆˆ 
i
ˆˆ 
<
ˆˆ 
figures
ˆˆ #
.
ˆˆ# $
Length
ˆˆ$ *
;
ˆˆ* +
i
ˆˆ, -
++
ˆˆ- /
)
ˆˆ/ 0
{
ˆˆ1 2
summary
ˆˆ3 :
.
ˆˆ: ;
Cell
ˆˆ; ?
(
ˆˆ? @
i
ˆˆ@ A
+
ˆˆB C
$num
ˆˆD E
,
ˆˆE F
$num
ˆˆG H
)
ˆˆH I
.
ˆˆI J
Value
ˆˆJ O
=
ˆˆP Q
figures
ˆˆR Y
[
ˆˆY Z
i
ˆˆZ [
]
ˆˆ[ \
.
ˆˆ\ ]
Label
ˆˆ] b
;
ˆˆb c
summary
ˆˆd k
.
ˆˆk l
Cell
ˆˆl p
(
ˆˆp q
i
ˆˆq r
+
ˆˆs t
$num
ˆˆu v
,
ˆˆv w
$num
ˆˆx y
)
ˆˆy z
.
ˆˆz {
Valueˆˆ{ Ä
=ˆˆÅ Ç
MathˆˆÉ á
.ˆˆá à
Roundˆˆà ç
(ˆˆç é
figuresˆˆé ï
[ˆˆï ñ
iˆˆñ ó
]ˆˆó ò
.ˆˆò ô
Valueˆˆô û
,ˆˆû ü
$numˆˆ† °
)ˆˆ° ¢
;ˆˆ¢ £
}ˆˆ§ •
var
˜˜ 
row
˜˜ 
=
˜˜ 
figures
˜˜ 
.
˜˜ 
Length
˜˜  
+
˜˜! "
$num
˜˜# $
;
˜˜$ %
string
¯¯ 
[
¯¯ 
]
¯¯ 
header
¯¯ 
=
¯¯ 
[
¯¯ 
$str
¯¯  
,
¯¯  !
$str
¯¯" *
,
¯¯* +
$str
¯¯, 4
,
¯¯4 5
$str
¯¯6 =
,
¯¯= >
$str
¯¯? N
]
¯¯N O
;
¯¯O P
for
˘˘ 
(
˘˘ 
var
˘˘ 
c
˘˘ 
=
˘˘ 
$num
˘˘ 
;
˘˘ 
c
˘˘ 
<
˘˘ 
header
˘˘ "
.
˘˘" #
Length
˘˘# )
;
˘˘) *
c
˘˘+ ,
++
˘˘, .
)
˘˘. /
summary
˘˘0 7
.
˘˘7 8
Cell
˘˘8 <
(
˘˘< =
row
˘˘= @
,
˘˘@ A
c
˘˘B C
+
˘˘D E
$num
˘˘F G
)
˘˘G H
.
˘˘H I
Value
˘˘I N
=
˘˘O P
header
˘˘Q W
[
˘˘W X
c
˘˘X Y
]
˘˘Y Z
;
˘˘Z [
foreach
˙˙ 
(
˙˙ 
var
˙˙ 
start
˙˙ 
in
˙˙ 

Enumerable
˙˙ (
.
˙˙( )
Range
˙˙) .
(
˙˙. /
$num
˙˙/ 0
,
˙˙0 1
month
˙˙2 7
is
˙˙8 :
null
˙˙; ?
?
˙˙@ A
$num
˙˙B D
:
˙˙E F
$num
˙˙G H
)
˙˙H I
.
˙˙I J
Select
˙˙J P
(
˙˙P Q
i
˙˙Q R
=>
˙˙S U
from
˙˙V Z
.
˙˙Z [
	AddMonths
˙˙[ d
(
˙˙d e
i
˙˙e f
)
˙˙f g
)
˙˙g h
)
˙˙h i
{
˚˚ 	
var
¸¸ 
end
¸¸ 
=
¸¸ 
start
¸¸ 
.
¸¸ 
	AddMonths
¸¸ %
(
¸¸% &
$num
¸¸& '
)
¸¸' (
.
¸¸( )
AddDays
¸¸) 0
(
¸¸0 1
-
¸¸1 2
$num
¸¸2 3
)
¸¸3 4
;
¸¸4 5
var
˝˝ 
n
˝˝ 
=
˝˝ 

NetFigures
˝˝ 
(
˝˝ 
sales
˝˝ $
.
˝˝$ %
Where
˝˝% *
(
˝˝* +
x
˝˝+ ,
=>
˝˝- /
x
˝˝0 1
.
˝˝1 2
Date
˝˝2 6
>=
˝˝7 9
start
˝˝: ?
&&
˝˝@ B
x
˝˝C D
.
˝˝D E
Date
˝˝E I
<=
˝˝J L
end
˝˝M P
)
˝˝P Q
,
˝˝Q R
expenses
˝˝S [
.
˝˝[ \
Where
˝˝\ a
(
˝˝a b
x
˝˝b c
=>
˝˝d f
x
˝˝g h
.
˝˝h i
Date
˝˝i m
>=
˝˝n p
start
˝˝q v
&&
˝˝w y
x
˝˝z {
.
˝˝{ |
Date˝˝| Ä
<=˝˝Å É
end˝˝Ñ á
)˝˝á à
,˝˝à â
settings˝˝ä í
.˝˝í ì
	RentaRate˝˝ì ú
)˝˝ú ù
;˝˝ù û
row
˛˛ 
++
˛˛ 
;
˛˛ 
summary
˛˛ 
.
˛˛ 
Cell
˛˛ 
(
˛˛  
row
˛˛  #
,
˛˛# $
$num
˛˛% &
)
˛˛& '
.
˛˛' (
Value
˛˛( -
=
˛˛. /
start
˛˛0 5
.
˛˛5 6
ToString
˛˛6 >
(
˛˛> ?
$str
˛˛? H
)
˛˛H I
;
˛˛I J
summary
ˇˇ 
.
ˇˇ 
Cell
ˇˇ 
(
ˇˇ 
row
ˇˇ 
,
ˇˇ 
$num
ˇˇ 
)
ˇˇ  
.
ˇˇ  !
Value
ˇˇ! &
=
ˇˇ' (
Math
ˇˇ) -
.
ˇˇ- .
Round
ˇˇ. 3
(
ˇˇ3 4
n
ˇˇ4 5
.
ˇˇ5 6
Ventas
ˇˇ6 <
,
ˇˇ< =
$num
ˇˇ> ?
)
ˇˇ? @
;
ˇˇ@ A
summary
ˇˇB I
.
ˇˇI J
Cell
ˇˇJ N
(
ˇˇN O
row
ˇˇO R
,
ˇˇR S
$num
ˇˇT U
)
ˇˇU V
.
ˇˇV W
Value
ˇˇW \
=
ˇˇ] ^
Math
ˇˇ_ c
.
ˇˇc d
Round
ˇˇd i
(
ˇˇi j
n
ˇˇj k
.
ˇˇk l
Gastos
ˇˇl r
,
ˇˇr s
$num
ˇˇt u
)
ˇˇu v
;
ˇˇv w
summary
ˇˇx 
.ˇˇ Ä
CellˇˇÄ Ñ
(ˇˇÑ Ö
rowˇˇÖ à
,ˇˇà â
$numˇˇä ã
)ˇˇã å
.ˇˇå ç
Valueˇˇç í
=ˇˇì î
Mathˇˇï ô
.ˇˇô ö
Roundˇˇö ü
(ˇˇü †
nˇˇ† °
.ˇˇ° ¢
	Impuestosˇˇ¢ ´
,ˇˇ´ ¨
$numˇˇ≠ Æ
)ˇˇÆ Ø
;ˇˇØ ∞
summaryˇˇ± ∏
.ˇˇ∏ π
Cellˇˇπ Ω
(ˇˇΩ æ
rowˇˇæ ¡
,ˇˇ¡ ¬
$numˇˇ√ ƒ
)ˇˇƒ ≈
.ˇˇ≈ ∆
Valueˇˇ∆ À
=ˇˇÃ Õ
MathˇˇŒ “
.ˇˇ“ ”
Roundˇˇ” ÿ
(ˇˇÿ Ÿ
nˇˇŸ ⁄
.ˇˇ⁄ €
Netaˇˇ€ ﬂ
,ˇˇﬂ ‡
$numˇˇ· ‚
)ˇˇ‚ „
;ˇˇ„ ‰
}
ÄÄ 	
summary
ÅÅ 
.
ÅÅ 
Columns
ÅÅ 
(
ÅÅ 
)
ÅÅ 
.
ÅÅ 
AdjustToContents
ÅÅ *
(
ÅÅ* +
)
ÅÅ+ ,
;
ÅÅ, -
var
ÉÉ 
clients
ÉÉ 
=
ÉÉ 
book
ÉÉ 
.
ÉÉ 
AddWorksheet
ÉÉ '
(
ÉÉ' (
$str
ÉÉ( 2
)
ÉÉ2 3
;
ÉÉ3 4
string
ÑÑ 
[
ÑÑ 
]
ÑÑ 
clientHeader
ÑÑ 
=
ÑÑ 
[
ÑÑ  !
$str
ÑÑ! *
,
ÑÑ* +
$str
ÑÑ, D
,
ÑÑD E
$str
ÑÑF S
,
ÑÑS T
$str
ÑÑU b
,
ÑÑb c
$str
ÑÑd l
,
ÑÑl m
$str
ÑÑn |
,
ÑÑ| }
$strÑÑ~ ñ
,ÑÑñ ó
$strÑÑò •
]ÑÑ• ¶
;ÑÑ¶ ß
for
ÖÖ 
(
ÖÖ 
var
ÖÖ 
c
ÖÖ 
=
ÖÖ 
$num
ÖÖ 
;
ÖÖ 
c
ÖÖ 
<
ÖÖ 
clientHeader
ÖÖ (
.
ÖÖ( )
Length
ÖÖ) /
;
ÖÖ/ 0
c
ÖÖ1 2
++
ÖÖ2 4
)
ÖÖ4 5
clients
ÖÖ6 =
.
ÖÖ= >
Cell
ÖÖ> B
(
ÖÖB C
$num
ÖÖC D
,
ÖÖD E
c
ÖÖF G
+
ÖÖH I
$num
ÖÖJ K
)
ÖÖK L
.
ÖÖL M
Value
ÖÖM R
=
ÖÖS T
clientHeader
ÖÖU a
[
ÖÖa b
c
ÖÖb c
]
ÖÖc d
;
ÖÖd e
var
ÜÜ 
r
ÜÜ 
=
ÜÜ 
$num
ÜÜ 
;
ÜÜ 
foreach
áá 
(
áá 
var
áá 
x
áá 
in
áá 
ranking
áá !
)
áá! "
{
àà 	
r
ââ 
++
ââ 
;
ââ 
clients
ää 
.
ää 
Cell
ää 
(
ää 
r
ää 
,
ää 
$num
ää 
)
ää 
.
ää 
Value
ää $
=
ää% &
x
ää' (
.
ää( )

ClientName
ää) 3
;
ää3 4
clients
ää5 <
.
ää< =
Cell
ää= A
(
ääA B
r
ääB C
,
ääC D
$num
ääE F
)
ääF G
.
ääG H
Value
ääH M
=
ääN O
x
ääP Q
.
ääQ R
IngresosPen
ääR ]
;
ää] ^
clients
ää_ f
.
ääf g
Cell
ääg k
(
ääk l
r
ääl m
,
ääm n
$num
ääo p
)
ääp q
.
ääq r
Value
äär w
=
ääx y
x
ääz {
.
ää{ |

Porcentajeää| Ü
;ääÜ á
clientsääà è
.ääè ê
Cellääê î
(ääî ï
rääï ñ
,ääñ ó
$numääò ô
)ääô ö
.ääö õ
Valueääõ †
=ää° ¢
xää£ §
.ää§ •#
PorcentajeAcumuladoää• ∏
;ää∏ π
clients
ãã 
.
ãã 
Cell
ãã 
(
ãã 
r
ãã 
,
ãã 
$num
ãã 
)
ãã 
.
ãã 
Value
ãã $
=
ãã% &
x
ãã' (
.
ãã( )
Cobros
ãã) /
;
ãã/ 0
clients
ãã1 8
.
ãã8 9
Cell
ãã9 =
(
ãã= >
r
ãã> ?
,
ãã? @
$num
ããA B
)
ããB C
.
ããC D
Value
ããD I
=
ããJ K
x
ããL M
.
ããM N
UltimoCobro
ããN Y
.
ããY Z

ToDateTime
ããZ d
(
ããd e
TimeOnly
ããe m
.
ããm n
MinValue
ããn v
)
ããv w
;
ããw x
clientsããy Ä
.ããÄ Å
CellããÅ Ö
(ããÖ Ü
rããÜ á
,ããá à
$numããâ ä
)ããä ã
.ããã å
Valueããå ë
=ããí ì
xããî ï
.ããï ñ"
PeriodoAnteriorPenããñ ®
;ãã® ©
if
åå 
(
åå 
x
åå 
.
åå !
VariacionPorcentaje
åå %
is
åå& (
decimal
åå) 0
	variation
åå1 :
)
åå: ;
clients
åå< C
.
ååC D
Cell
ååD H
(
ååH I
r
ååI J
,
ååJ K
$num
ååL M
)
ååM N
.
ååN O
Value
ååO T
=
ååU V
	variation
ååW `
;
åå` a
}
çç 	
clients
éé 
.
éé 
Column
éé 
(
éé 
$num
éé 
)
éé 
.
éé 
Style
éé 
.
éé  

DateFormat
éé  *
.
éé* +
Format
éé+ 1
=
éé2 3
$str
éé4 @
;
éé@ A
clients
ééB I
.
ééI J
Columns
ééJ Q
(
ééQ R
)
ééR S
.
ééS T
AdjustToContents
ééT d
(
ééd e
)
éée f
;
ééf g
using
êê 
var
êê 
stream
êê 
=
êê 
new
êê 
MemoryStream
êê +
(
êê+ ,
)
êê, -
;
êê- .
book
êê/ 3
.
êê3 4
SaveAs
êê4 :
(
êê: ;
stream
êê; A
)
êêA B
;
êêB C
return
ëë 
File
ëë 
(
ëë 
stream
ëë 
.
ëë 
ToArray
ëë "
(
ëë" #
)
ëë# $
,
ëë$ %
$str
ëë& i
,
ëëi j
month
ëëk p
is
ëëq s
int
ëët w
m
ëëx y
?
ëëz {
$"
ëë| ~
$strëë~ Ü
{ëëÜ á
yearëëá ã
}ëëã å
$strëëå ç
{ëëç é
mëëé è
:ëëè ê
$strëëê í
}ëëí ì
$strëëì ò
"ëëò ô
:ëëö õ
$"ëëú û
$strëëû ¶
{ëë¶ ß
yearëëß ´
}ëë´ ¨
$strëë¨ ±
"ëë± ≤
)ëë≤ ≥
;ëë≥ ¥
}
íí 
[
îî 
HttpGet
îî 
(
îî 
$str
îî 
)
îî 
]
îî 
public
ïï 

async
ïï 
Task
ïï 
<
ïï 
ActionResult
ïï "
>
ïï" #
Clients
ïï$ +
(
ïï+ ,
CancellationToken
ïï, =
ct
ïï> @
)
ïï@ A
=>
ïïB D
Ok
ïïE G
(
ïïG H
await
ïïH M
db
ïïN P
.
ïïP Q
Clients
ïïQ X
.
ïïX Y
OrderBy
ïïY `
(
ïï` a
x
ïïa b
=>
ïïc e
x
ïïf g
.
ïïg h
CompanyName
ïïh s
)
ïïs t
.
ïït u
Select
ïïu {
(
ïï{ |
x
ïï| }
=>ïï~ Ä
newïïÅ Ñ
{ïïÖ Ü
idïïá â
=ïïä ã
xïïå ç
.ïïç é
Idïïé ê
,ïïê ë
companyNameïïí ù
=ïïû ü
xïï† °
.ïï° ¢
CompanyNameïï¢ ≠
,ïï≠ Æ
isActiveïïØ ∑
=ïï∏ π
xïï∫ ª
.ïïª º
IsActiveïïº ƒ
,ïïƒ ≈#
requiresTaxDocumentïï∆ Ÿ
=ïï⁄ €
xïï‹ ›
.ïï› ﬁ#
RequiresTaxDocumentïïﬁ Ò
,ïïÒ Ú
activeProductsïïÛ Å
=ïïÇ É
dbïïÑ Ü
.ïïÜ á
ClientProductsïïá ï
.ïïï ñ
Countïïñ õ
(ïïõ ú
pïïú ù
=>ïïû †
pïï° ¢
.ïï¢ £
ClientIdïï£ ´
==ïï¨ Æ
xïïØ ∞
.ïï∞ ±
Idïï± ≥
&&ïï¥ ∂
pïï∑ ∏
.ïï∏ π
Statusïïπ ø
==ïï¿ ¬#
ClientProductStatusïï√ ÷
.ïï÷ ◊
Activoïï◊ ›
)ïï› ﬁ
,ïïﬁ ﬂ 
expiringProductsïï‡ 
=ïïÒ Ú
dbïïÛ ı
.ïïı ˆ
ClientProductsïïˆ Ñ
.ïïÑ Ö
CountïïÖ ä
(ïïä ã
pïïã å
=>ïïç è
pïïê ë
.ïïë í
ClientIdïïí ö
==ïïõ ù
xïïû ü
.ïïü †
Idïï† ¢
&&ïï£ •
pïï¶ ß
.ïïß ®
Statusïï® Æ
==ïïØ ±#
ClientProductStatusïï≤ ≈
.ïï≈ ∆
	PorVencerïï∆ œ
)ïïœ –
,ïï– —
expiredProductsïï“ ·
=ïï‚ „
dbïï‰ Ê
.ïïÊ Á
ClientProductsïïÁ ı
.ïïı ˆ
Countïïˆ ˚
(ïï˚ ¸
pïï¸ ˝
=>ïï˛ Ä
pïïÅ Ç
.ïïÇ É
ClientIdïïÉ ã
==ïïå é
xïïè ê
.ïïê ë
Idïïë ì
&&ïïî ñ
pïïó ò
.ïïò ô
Statusïïô ü
==ïï† ¢#
ClientProductStatusïï£ ∂
.ïï∂ ∑
Vencidoïï∑ æ
)ïïæ ø
,ïïø ¿
openTicketsïï¡ Ã
=ïïÕ Œ
dbïïœ —
.ïï— “
Ticketsïï“ Ÿ
.ïïŸ ⁄
Countïï⁄ ﬂ
(ïïﬂ ‡
tïï‡ ·
=>ïï‚ ‰
tïïÂ Ê
.ïïÊ Á
ClientIdïïÁ Ô
==ïï Ú
xïïÛ Ù
.ïïÙ ı
Idïïı ˜
&&ïï¯ ˙
(ïï˚ ¸
tïï¸ ˝
.ïï˝ ˛
Statusïï˛ Ñ
==ïïÖ á
TicketStatusïïà î
.ïïî ï
Abiertoïïï ú
||ïïù ü
tïï† °
.ïï° ¢
Statusïï¢ ®
==ïï© ´
TicketStatusïï¨ ∏
.ïï∏ π

EnProgresoïïπ √
)ïï√ ƒ
)ïïƒ ≈
}ïï∆ «
)ïï« »
.ïï» …
ToListAsyncïï… ‘
(ïï‘ ’
ctïï’ ◊
)ïï◊ ÿ
)ïïÿ Ÿ
;ïïŸ ⁄
[
óó 
HttpGet
óó 
(
óó 
$str
óó  
)
óó  !
]
óó! "
public
òò 

async
òò 
Task
òò 
<
òò 
ActionResult
òò "
>
òò" #
Client
òò$ *
(
òò* +
Guid
òò+ /
id
òò0 2
,
òò2 3
CancellationToken
òò4 E
ct
òòF H
)
òòH I
{
ôô 
var
öö 
client
öö 
=
öö 
await
öö 
db
öö 
.
öö 
Clients
öö %
.
öö% &
	FindAsync
öö& /
(
öö/ 0
[
öö0 1
id
öö1 3
]
öö3 4
,
öö4 5
ct
öö6 8
)
öö8 9
;
öö9 :
if
õõ 

(
õõ 
client
õõ 
is
õõ 
null
õõ 
)
õõ 
return
õõ "
NotFound
õõ# +
(
õõ+ ,
)
õõ, -
;
õõ- .
var
úú 
products
úú 
=
úú 
await
úú 
db
úú 
.
úú  
ClientProducts
úú  .
.
úú. /
Include
úú/ 6
(
úú6 7
x
úú7 8
=>
úú9 ;
x
úú< =
.
úú= >
Product
úú> E
)
úúE F
.
úúF G
Include
úúG N
(
úúN O
x
úúO P
=>
úúQ S
x
úúT U
.
úúU V
Project
úúV ]
)
úú] ^
.
úú^ _
Where
úú_ d
(
úúd e
x
úúe f
=>
úúg i
x
úúj k
.
úúk l
ClientId
úúl t
==
úúu w
id
úúx z
)
úúz {
.
úú{ |
ToListAsyncúú| á
(úúá à
ctúúà ä
)úúä ã
;úúã å
var
ùù 
igvRate
ùù 
=
ùù 
await
ùù 
db
ùù 
.
ùù 
IgvRateAsync
ùù +
(
ùù+ ,
ct
ùù, .
)
ùù. /
;
ùù/ 0
return
ûû 
Ok
ûû 
(
ûû 
new
ûû 
{
ûû 
client
ûû 
=
ûû  
	ClientDto
ûû! *
(
ûû* +
client
ûû+ 1
)
ûû1 2
,
ûû2 3
products
ûû4 <
=
ûû= >
products
ûû? G
.
ûûG H
Select
ûûH N
(
ûûN O
x
ûûO P
=>
ûûQ S
ClientProductDto
ûûT d
(
ûûd e
x
ûûe f
,
ûûf g
x
ûûh i
.
ûûi j
Product
ûûj q
is
ûûr t
null
ûûu y
?
ûûz {
$num
ûû| ~
:ûû Ä$
ClientProductPricingûûÅ ï
.ûûï ñ

IgvRateForûûñ †
(ûû† °
clientûû° ß
,ûûß ®
xûû© ™
.ûû™ ´
Productûû´ ≤
,ûû≤ ≥
igvRateûû¥ ª
)ûûª º
)ûûº Ω
)ûûΩ æ
}ûûø ¿
)ûû¿ ¡
;ûû¡ ¬
}
üü 
[
°° 
HttpPost
°° 
(
°° 
$str
°° 
)
°° 
]
°° 
public
¢¢ 

async
¢¢ 
Task
¢¢ 
<
¢¢ 
ActionResult
¢¢ "
>
¢¢" #
CreateClient
¢¢$ 0
(
¢¢0 1
ClientRequest
¢¢1 >
request
¢¢? F
,
¢¢F G
CancellationToken
¢¢H Y
ct
¢¢Z \
)
¢¢\ ]
{
££ 
var
§§ 
error
§§ 
=
§§ 
ValidateClient
§§ "
(
§§" #
request
§§# *
)
§§* +
;
§§+ ,
if
§§- /
(
§§0 1
error
§§1 6
is
§§7 9
not
§§: =
null
§§> B
)
§§B C
return
§§D J

BadRequest
§§K U
(
§§U V
new
§§V Y
{
§§Z [
message
§§\ c
=
§§d e
error
§§f k
}
§§l m
)
§§m n
;
§§n o
var
•• 
email
•• 
=
•• 
request
•• 
.
•• 
Email
•• !
.
••! "
Trim
••" &
(
••& '
)
••' (
;
••( )
if
¶¶ 

(
¶¶ 
await
¶¶ 
db
¶¶ 
.
¶¶ 
Clients
¶¶ 
.
¶¶ 
AnyAsync
¶¶ %
(
¶¶% &
x
¶¶& '
=>
¶¶( *
x
¶¶+ ,
.
¶¶, -
Email
¶¶- 2
==
¶¶3 5
email
¶¶6 ;
,
¶¶; <
ct
¶¶= ?
)
¶¶? @
||
¶¶A C
await
¶¶D I
db
¶¶J L
.
¶¶L M
UserAccounts
¶¶M Y
.
¶¶Y Z
AnyAsync
¶¶Z b
(
¶¶b c
x
¶¶c d
=>
¶¶e g
x
¶¶h i
.
¶¶i j
Email
¶¶j o
==
¶¶p r
email
¶¶s x
,
¶¶x y
ct
¶¶z |
)
¶¶| }
)
¶¶} ~
return¶¶ Ö
Conflict¶¶Ü é
(¶¶é è
new¶¶è í
{¶¶ì î
message¶¶ï ú
=¶¶ù û
$str¶¶ü Ω
}¶¶æ ø
)¶¶ø ¿
;¶¶¿ ¡
var
ßß 
client
ßß 
=
ßß 
new
ßß 
Client
ßß 
{
ßß  !
CompanyName
ßß" -
=
ßß. /
request
ßß0 7
.
ßß7 8
CompanyName
ßß8 C
.
ßßC D
Trim
ßßD H
(
ßßH I
)
ßßI J
,
ßßJ K
ContactName
ßßL W
=
ßßX Y
request
ßßZ a
.
ßßa b
ContactName
ßßb m
.
ßßm n
Trim
ßßn r
(
ßßr s
)
ßßs t
,
ßßt u
Email
ßßv {
=
ßß| }
emailßß~ É
,ßßÉ Ñ
PhoneßßÖ ä
=ßßã å
EmptyToNullßßç ò
(ßßò ô
requestßßô †
.ßß† °
Phoneßß° ¶
)ßß¶ ß
,ßßß ®!
PreferredLanguageßß© ∫
=ßßª º
requestßßΩ ƒ
.ßßƒ ≈!
PreferredLanguageßß≈ ÷
.ßß÷ ◊
Trimßß◊ €
(ßß€ ‹
)ßß‹ ›
.ßß› ﬁ 
ToLowerInvariantßßﬁ Ó
(ßßÓ Ô
)ßßÔ 
,ßß Ò#
RequiresTaxDocumentßßÚ Ö
=ßßÜ á
requestßßà è
.ßßè ê#
RequiresTaxDocumentßßê £
}ßß§ •
;ßß• ¶
db
®® 

.
®®
 
Clients
®® 
.
®® 
Add
®® 
(
®® 
client
®® 
)
®® 
;
®® 
var
™™ 
access
™™ 
=
™™ 
AddAdminUser
™™ !
(
™™! "
client
™™" (
)
™™( )
;
™™) *
await
´´ 
db
´´ 
.
´´ 
SaveChangesAsync
´´ !
(
´´! "
ct
´´" $
)
´´$ %
;
´´% &
access
¨¨ 
=
¨¨ 
await
¨¨ 
EmailAccessAsync
¨¨ '
(
¨¨' (
client
¨¨( .
,
¨¨. /
access
¨¨0 6
,
¨¨6 7
ct
¨¨8 :
)
¨¨: ;
;
¨¨; <
return
≠≠ 
Created
≠≠ 
(
≠≠ 
$"
≠≠ 
$str
≠≠ ,
{
≠≠, -
client
≠≠- 3
.
≠≠3 4
Id
≠≠4 6
}
≠≠6 7
"
≠≠7 8
,
≠≠8 9
new
≠≠: =
{
≠≠> ?
client
≠≠@ F
=
≠≠G H
	ClientDto
≠≠I R
(
≠≠R S
client
≠≠S Y
)
≠≠Y Z
,
≠≠Z [
access
≠≠\ b
}
≠≠c d
)
≠≠d e
;
≠≠e f
}
ÆÆ 
[
∞∞ 
	HttpPatch
∞∞ 
(
∞∞ 
$str
∞∞ "
)
∞∞" #
]
∞∞# $
public
±± 

async
±± 
Task
±± 
<
±± 
ActionResult
±± "
>
±±" #
UpdateClient
±±$ 0
(
±±0 1
Guid
±±1 5
id
±±6 8
,
±±8 9 
ClientPatchRequest
±±: L
request
±±M T
,
±±T U
CancellationToken
±±V g
ct
±±h j
)
±±j k
{
≤≤ 
var
≥≥ 
client
≥≥ 
=
≥≥ 
await
≥≥ 
db
≥≥ 
.
≥≥ 
Clients
≥≥ %
.
≥≥% &
	FindAsync
≥≥& /
(
≥≥/ 0
[
≥≥0 1
id
≥≥1 3
]
≥≥3 4
,
≥≥4 5
ct
≥≥6 8
)
≥≥8 9
;
≥≥9 :
if
≥≥; =
(
≥≥> ?
client
≥≥? E
is
≥≥F H
null
≥≥I M
)
≥≥M N
return
≥≥O U
NotFound
≥≥V ^
(
≥≥^ _
)
≥≥_ `
;
≥≥` a
if
¥¥ 

(
¥¥ 
request
¥¥ 
.
¥¥ 
CompanyName
¥¥ 
is
¥¥  "
not
¥¥# &
null
¥¥' +
)
¥¥+ ,
client
¥¥- 3
.
¥¥3 4
CompanyName
¥¥4 ?
=
¥¥@ A
request
¥¥B I
.
¥¥I J
CompanyName
¥¥J U
.
¥¥U V
Trim
¥¥V Z
(
¥¥Z [
)
¥¥[ \
;
¥¥\ ]
if
µµ 

(
µµ 
request
µµ 
.
µµ 
ContactName
µµ 
is
µµ  "
not
µµ# &
null
µµ' +
)
µµ+ ,
client
µµ- 3
.
µµ3 4
ContactName
µµ4 ?
=
µµ@ A
request
µµB I
.
µµI J
ContactName
µµJ U
.
µµU V
Trim
µµV Z
(
µµZ [
)
µµ[ \
;
µµ\ ]
if
∂∂ 

(
∂∂ 
request
∂∂ 
.
∂∂ 
Phone
∂∂ 
is
∂∂ 
not
∂∂  
null
∂∂! %
)
∂∂% &
client
∂∂' -
.
∂∂- .
Phone
∂∂. 3
=
∂∂4 5
EmptyToNull
∂∂6 A
(
∂∂A B
request
∂∂B I
.
∂∂I J
Phone
∂∂J O
)
∂∂O P
;
∂∂P Q
if
∑∑ 

(
∑∑ 
request
∑∑ 
.
∑∑ 
PreferredLanguage
∑∑ %
is
∑∑& (
not
∑∑) ,
null
∑∑- 1
)
∑∑1 2
{
∏∏ 	
var
ππ 
lang
ππ 
=
ππ 
request
ππ 
.
ππ 
PreferredLanguage
ππ 0
.
ππ0 1
Trim
ππ1 5
(
ππ5 6
)
ππ6 7
.
ππ7 8
ToLowerInvariant
ππ8 H
(
ππH I
)
ππI J
;
ππJ K
if
∫∫ 
(
∫∫ 
lang
∫∫ 
is
∫∫ 
not
∫∫ 
(
∫∫ 
$str
∫∫ !
or
∫∫" $
$str
∫∫% )
or
∫∫* ,
$str
∫∫- 1
)
∫∫1 2
)
∫∫2 3
return
∫∫4 :

BadRequest
∫∫; E
(
∫∫E F
new
∫∫F I
{
∫∫J K
message
∫∫L S
=
∫∫T U
$str
∫∫V h
}
∫∫i j
)
∫∫j k
;
∫∫k l
client
ªª 
.
ªª 
PreferredLanguage
ªª $
=
ªª% &
lang
ªª' +
;
ªª+ ,
}
ºº 	
if
ΩΩ 

(
ΩΩ 
request
ΩΩ 
.
ΩΩ 
Email
ΩΩ 
is
ΩΩ 
not
ΩΩ  
null
ΩΩ! %
&&
ΩΩ& (
await
ΩΩ) .$
ChangeClientEmailAsync
ΩΩ/ E
(
ΩΩE F
client
ΩΩF L
,
ΩΩL M
request
ΩΩN U
.
ΩΩU V
Email
ΩΩV [
.
ΩΩ[ \
Trim
ΩΩ\ `
(
ΩΩ` a
)
ΩΩa b
,
ΩΩb c
ct
ΩΩd f
)
ΩΩf g
is
ΩΩh j
{
ΩΩk l
}
ΩΩm n

emailError
ΩΩo y
)
ΩΩy z
returnΩΩ{ Å

emailErrorΩΩÇ å
;ΩΩå ç
if
ææ 

(
ææ 
request
ææ 
.
ææ 
IsActive
ææ 
is
ææ 
bool
ææ  $
active
ææ% +
)
ææ+ ,
client
ææ- 3
.
ææ3 4
IsActive
ææ4 <
=
ææ= >
active
ææ? E
;
ææE F
if
øø 

(
øø 
request
øø 
.
øø !
RequiresTaxDocument
øø '
is
øø( *
bool
øø+ /
requiresTax
øø0 ;
)
øø; <
client
øø= C
.
øøC D!
RequiresTaxDocument
øøD W
=
øøX Y
requiresTax
øøZ e
;
øøe f
await
¿¿ 
db
¿¿ 
.
¿¿ 
SaveChangesAsync
¿¿ !
(
¿¿! "
ct
¿¿" $
)
¿¿$ %
;
¿¿% &
return
¿¿' -
Ok
¿¿. 0
(
¿¿0 1
	ClientDto
¿¿1 :
(
¿¿: ;
client
¿¿; A
)
¿¿A B
)
¿¿B C
;
¿¿C D
}
¡¡ 
private
ƒƒ 
async
ƒƒ 
Task
ƒƒ 
<
ƒƒ 
ActionResult
ƒƒ #
?
ƒƒ# $
>
ƒƒ$ %$
ChangeClientEmailAsync
ƒƒ& <
(
ƒƒ< =
Client
ƒƒ= C
client
ƒƒD J
,
ƒƒJ K
string
ƒƒL R
email
ƒƒS X
,
ƒƒX Y
CancellationToken
ƒƒZ k
ct
ƒƒl n
)
ƒƒn o
{
≈≈ 
if
∆∆ 

(
∆∆ 
string
∆∆ 
.
∆∆  
IsNullOrWhiteSpace
∆∆ %
(
∆∆% &
email
∆∆& +
)
∆∆+ ,
)
∆∆, -
return
∆∆. 4

BadRequest
∆∆5 ?
(
∆∆? @
new
∆∆@ C
{
∆∆D E
message
∆∆F M
=
∆∆N O
$str
∆∆P j
}
∆∆k l
)
∆∆l m
;
∆∆m n
if
«« 

(
«« 
await
«« 
db
«« 
.
«« 
Clients
«« 
.
«« 
AnyAsync
«« %
(
««% &
x
««& '
=>
««( *
x
««+ ,
.
««, -
Email
««- 2
==
««3 5
email
««6 ;
&&
««< >
x
««? @
.
««@ A
Id
««A C
!=
««D F
client
««G M
.
««M N
Id
««N P
,
««P Q
ct
««R T
)
««T U
)
««U V
return
««W ]
Conflict
««^ f
(
««f g
new
««g j
{
««k l
message
««m t
=
««u v
$str««w ï
}««ñ ó
)««ó ò
;««ò ô
client
»» 
.
»» 
Email
»» 
=
»» 
email
»» 
;
»» 
return
…… 
null
…… 
;
…… 
}
   
[
ÃÃ 
HttpGet
ÃÃ 
(
ÃÃ 
$str
ÃÃ &
)
ÃÃ& '
]
ÃÃ' (
public
ÕÕ 

IActionResult
ÕÕ 
ClientTemplate
ÕÕ '
(
ÕÕ' (
)
ÕÕ( )
=>
ÕÕ* ,
File
ÕÕ- 1
(
ÕÕ1 2
CreateWorkbook
ÕÕ2 @
(
ÕÕ@ A
new
ŒŒ 
(
ŒŒ 
$str
ŒŒ 
,
ŒŒ 
true
ŒŒ 
,
ŒŒ  
$str
ŒŒ! B
)
ŒŒB C
,
ŒŒC D
new
œœ 
(
œœ 
$str
œœ 
,
œœ 
true
œœ 
,
œœ  
$str
œœ! C
)
œœC D
,
œœD E
new
–– 
(
–– 
$str
–– 
,
–– 
true
–– 
,
–– 
$str
–– s
)
––s t
,
––t u
new
—— 
(
—— 
$str
—— 
,
—— 
false
—— 
,
—— 
$str
—— >
)
——> ?
,
——? @
new
““ 
(
““ 
$str
““ 
,
““  
true
““! %
,
““% &
$str
““' R
,
““R S
[
““T U
$str
““U Y
,
““Y Z
$str
““[ _
,
““_ `
$str
““a e
]
““e f
)
““f g
,
““g h
new
”” 
(
”” 
$str
”” !
,
””! "
false
””# (
,
””( )
$str””* ã
,””ã å
[””ç é
$str””é í
,””í ì
$str””î ò
]””ò ô
)””ô ö
)””ö õ
,””õ ú
$str
‘‘ K
,
‘‘K L
$str
‘‘M f
)
‘‘f g
;
‘‘g h
[
÷÷ 
HttpPost
÷÷ 
(
÷÷ 
$str
÷÷ 
)
÷÷ 
]
÷÷  
public
◊◊ 

async
◊◊ 
Task
◊◊ 
<
◊◊ 
ActionResult
◊◊ "
>
◊◊" #
ImportClients
◊◊$ 1
(
◊◊1 2
	IFormFile
◊◊2 ;
file
◊◊< @
,
◊◊@ A
CancellationToken
◊◊B S
ct
◊◊T V
)
◊◊V W
{
ÿÿ 
var
ŸŸ 
created_
ŸŸ 
=
ŸŸ 
new
ŸŸ 
List
ŸŸ 
<
ŸŸ  
(
ŸŸ  !
Client
ŸŸ! '
Client
ŸŸ( .
,
ŸŸ. /
ClientAccess
ŸŸ0 <
Access
ŸŸ= C
)
ŸŸC D
>
ŸŸD E
(
ŸŸE F
)
ŸŸF G
;
ŸŸG H
var
⁄⁄ 
(
⁄⁄ 
failure
⁄⁄ 
,
⁄⁄ 
created
⁄⁄ 
,
⁄⁄ 
errors
⁄⁄ %
)
⁄⁄% &
=
⁄⁄' (
await
⁄⁄) .
Import
⁄⁄/ 5
(
⁄⁄5 6
file
⁄⁄6 :
,
⁄⁄: ;
$str
⁄⁄< F
,
⁄⁄F G
async
⁄⁄H M
(
⁄⁄N O
row
⁄⁄O R
,
⁄⁄R S
	rowNumber
⁄⁄T ]
,
⁄⁄] ^
errors
⁄⁄_ e
)
⁄⁄e f
=>
⁄⁄g i
{
€€ 	
var
‹‹ 
requiresTax
‹‹ 
=
‹‹ 
	ReadYesNo
‹‹ '
(
‹‹' (
Cell
‹‹( ,
(
‹‹, -
row
‹‹- 0
,
‹‹0 1
$num
‹‹2 3
)
‹‹3 4
,
‹‹4 5
defaultValue
‹‹6 B
:
‹‹B C
false
‹‹D I
)
‹‹I J
;
‹‹J K
var
›› 
request
›› 
=
›› 
new
›› 
ClientRequest
›› +
(
››+ ,
Cell
››, 0
(
››0 1
row
››1 4
,
››4 5
$num
››6 7
)
››7 8
,
››8 9
Cell
››: >
(
››> ?
row
››? B
,
››B C
$num
››D E
)
››E F
,
››F G
Cell
››H L
(
››L M
row
››M P
,
››P Q
$num
››R S
)
››S T
,
››T U
Cell
››V Z
(
››Z [
row
››[ ^
,
››^ _
$num
››` a
)
››a b
,
››b c
Cell
››d h
(
››h i
row
››i l
,
››l m
$num
››n o
)
››o p
,
››p q
requiresTax
››r }
??››~ Ä
false››Å Ü
)››Ü á
;››á à
var››â å
error››ç í
=››ì î
requiresTax››ï †
is››° £
null››§ ®
?››© ™
$str››´ ◊
:››ÿ Ÿ
ValidateClient››⁄ Ë
(››Ë È
request››È 
)›› Ò
;››Ò Ú
var
ﬁﬁ 
email
ﬁﬁ 
=
ﬁﬁ 
request
ﬁﬁ 
.
ﬁﬁ  
Email
ﬁﬁ  %
.
ﬁﬁ% &
Trim
ﬁﬁ& *
(
ﬁﬁ* +
)
ﬁﬁ+ ,
;
ﬁﬁ, -
if
ﬂﬂ 
(
ﬂﬂ 
error
ﬂﬂ 
is
ﬂﬂ 
not
ﬂﬂ 
null
ﬂﬂ !
||
ﬂﬂ" $
await
ﬂﬂ% *
db
ﬂﬂ+ -
.
ﬂﬂ- .
Clients
ﬂﬂ. 5
.
ﬂﬂ5 6
AnyAsync
ﬂﬂ6 >
(
ﬂﬂ> ?
x
ﬂﬂ? @
=>
ﬂﬂA C
x
ﬂﬂD E
.
ﬂﬂE F
Email
ﬂﬂF K
==
ﬂﬂL N
email
ﬂﬂO T
,
ﬂﬂT U
ct
ﬂﬂV X
)
ﬂﬂX Y
||
ﬂﬂZ \
await
ﬂﬂ] b
db
ﬂﬂc e
.
ﬂﬂe f
UserAccounts
ﬂﬂf r
.
ﬂﬂr s
AnyAsync
ﬂﬂs {
(
ﬂﬂ{ |
x
ﬂﬂ| }
=>ﬂﬂ~ Ä
xﬂﬂÅ Ç
.ﬂﬂÇ É
EmailﬂﬂÉ à
==ﬂﬂâ ã
emailﬂﬂå ë
,ﬂﬂë í
ctﬂﬂì ï
)ﬂﬂï ñ
)ﬂﬂñ ó
{ﬂﬂò ô
errorsﬂﬂö †
.ﬂﬂ† °
Addﬂﬂ° §
(ﬂﬂ§ •
newﬂﬂ• ®
(ﬂﬂ® ©
	rowNumberﬂﬂ© ≤
,ﬂﬂ≤ ≥
errorﬂﬂ¥ π
??ﬂﬂ∫ º
$strﬂﬂΩ €
)ﬂﬂ€ ‹
)ﬂﬂ‹ ›
;ﬂﬂ› ﬁ
returnﬂﬂﬂ Â
falseﬂﬂÊ Î
;ﬂﬂÎ Ï
}ﬂﬂÌ Ó
var
‡‡ 
client
‡‡ 
=
‡‡ 
new
‡‡ 
Client
‡‡ #
{
‡‡$ %
CompanyName
‡‡& 1
=
‡‡2 3
request
‡‡4 ;
.
‡‡; <
CompanyName
‡‡< G
.
‡‡G H
Trim
‡‡H L
(
‡‡L M
)
‡‡M N
,
‡‡N O
ContactName
‡‡P [
=
‡‡\ ]
request
‡‡^ e
.
‡‡e f
ContactName
‡‡f q
.
‡‡q r
Trim
‡‡r v
(
‡‡v w
)
‡‡w x
,
‡‡x y
Email
‡‡z 
=‡‡Ä Å
email‡‡Ç á
,‡‡á à
Phone‡‡â é
=‡‡è ê
EmptyToNull‡‡ë ú
(‡‡ú ù
request‡‡ù §
.‡‡§ •
Phone‡‡• ™
)‡‡™ ´
,‡‡´ ¨!
PreferredLanguage‡‡≠ æ
=‡‡ø ¿
request‡‡¡ »
.‡‡» …!
PreferredLanguage‡‡… ⁄
.‡‡⁄ €
Trim‡‡€ ﬂ
(‡‡ﬂ ‡
)‡‡‡ ·
.‡‡· ‚ 
ToLowerInvariant‡‡‚ Ú
(‡‡Ú Û
)‡‡Û Ù
,‡‡Ù ı#
RequiresTaxDocument‡‡ˆ â
=‡‡ä ã
request‡‡å ì
.‡‡ì î#
RequiresTaxDocument‡‡î ß
}‡‡® ©
;‡‡© ™
db
·· 
.
·· 
Clients
·· 
.
·· 
Add
·· 
(
·· 
client
·· !
)
··! "
;
··" #
created_
··$ ,
.
··, -
Add
··- 0
(
··0 1
(
··1 2
client
··2 8
,
··8 9
AddAdminUser
··: F
(
··F G
client
··G M
)
··M N
)
··N O
)
··O P
;
··P Q
return
··R X
true
··Y ]
;
··] ^
}
‚‚ 	
,
‚‚	 

ct
‚‚ 
)
‚‚ 
;
‚‚ 
if
„„ 

(
„„ 
failure
„„ 
is
„„ 
not
„„ 
null
„„ 
)
„„  
return
„„! '
failure
„„( /
;
„„/ 0
var
‰‰ 
accesses
‰‰ 
=
‰‰ 
new
‰‰ 
List
‰‰ 
<
‰‰  
ClientAccess
‰‰  ,
>
‰‰, -
(
‰‰- .
)
‰‰. /
;
‰‰/ 0
foreach
ÂÂ 
(
ÂÂ 
var
ÂÂ 
(
ÂÂ 
client
ÂÂ 
,
ÂÂ 
access
ÂÂ $
)
ÂÂ$ %
in
ÂÂ& (
created_
ÂÂ) 1
)
ÂÂ1 2
accesses
ÂÂ3 ;
.
ÂÂ; <
Add
ÂÂ< ?
(
ÂÂ? @
await
ÂÂ@ E
EmailAccessAsync
ÂÂF V
(
ÂÂV W
client
ÂÂW ]
,
ÂÂ] ^
access
ÂÂ_ e
,
ÂÂe f
ct
ÂÂg i
)
ÂÂi j
)
ÂÂj k
;
ÂÂk l
return
ÊÊ 
Ok
ÊÊ 
(
ÊÊ 
new
ÊÊ 
{
ÊÊ 
created
ÊÊ 
,
ÊÊ  
skipped
ÊÊ! (
=
ÊÊ) *
errors
ÊÊ+ 1
.
ÊÊ1 2
Count
ÊÊ2 7
,
ÊÊ7 8
errors
ÊÊ9 ?
,
ÊÊ? @
accesses
ÊÊA I
}
ÊÊJ K
)
ÊÊK L
;
ÊÊL M
}
ÁÁ 
[
ÌÌ 
HttpPost
ÌÌ 
(
ÌÌ 
$str
ÌÌ (
)
ÌÌ( )
]
ÌÌ) *
public
ÓÓ 

async
ÓÓ 
Task
ÓÓ 
<
ÓÓ 
ActionResult
ÓÓ "
>
ÓÓ" #
ClientAccess
ÓÓ$ 0
(
ÓÓ0 1
Guid
ÓÓ1 5
id
ÓÓ6 8
,
ÓÓ8 9
CancellationToken
ÓÓ: K
ct
ÓÓL N
)
ÓÓN O
{
ÔÔ 
var
 
client
 
=
 
await
 
db
 
.
 
Clients
 %
.
% &
	FindAsync
& /
(
/ 0
[
0 1
id
1 3
]
3 4
,
4 5
ct
6 8
)
8 9
;
9 :
if
; =
(
> ?
client
? E
is
F H
null
I M
)
M N
return
O U
NotFound
V ^
(
^ _
)
_ `
;
` a
var
ÒÒ 
user
ÒÒ 
=
ÒÒ 
await
ÒÒ 
db
ÒÒ 
.
ÒÒ 
UserAccounts
ÒÒ (
.
ÒÒ( )"
SingleOrDefaultAsync
ÒÒ) =
(
ÒÒ= >
x
ÒÒ> ?
=>
ÒÒ@ B
x
ÒÒC D
.
ÒÒD E
Email
ÒÒE J
==
ÒÒK M
client
ÒÒN T
.
ÒÒT U
Email
ÒÒU Z
,
ÒÒZ [
ct
ÒÒ\ ^
)
ÒÒ^ _
;
ÒÒ_ `
if
ÚÚ 

(
ÚÚ 
user
ÚÚ 
is
ÚÚ 
not
ÚÚ 
null
ÚÚ 
&&
ÚÚ 
user
ÚÚ  $
.
ÚÚ$ %
ClientId
ÚÚ% -
!=
ÚÚ. 0
client
ÚÚ1 7
.
ÚÚ7 8
Id
ÚÚ8 :
)
ÚÚ: ;
return
ÚÚ< B
Conflict
ÚÚC K
(
ÚÚK L
new
ÚÚL O
{
ÚÚP Q
message
ÚÚR Y
=
ÚÚZ [
$strÚÚ\ ó
}ÚÚò ô
)ÚÚô ö
;ÚÚö õ
ClientAccess
ÛÛ 
access
ÛÛ 
;
ÛÛ 
if
ÙÙ 

(
ÙÙ 
user
ÙÙ 
is
ÙÙ 
null
ÙÙ 
)
ÙÙ 
access
ÙÙ  
=
ÙÙ! "
AddAdminUser
ÙÙ# /
(
ÙÙ/ 0
client
ÙÙ0 6
)
ÙÙ6 7
;
ÙÙ7 8
else
ıı 
{
ˆˆ 	
var
˜˜ 
temporaryPassword
˜˜ !
=
˜˜" #
AccountController
˜˜$ 5
.
˜˜5 6
TemporaryPassword
˜˜6 G
(
˜˜G H
)
˜˜H I
;
˜˜I J
user
¯¯ 
.
¯¯ 
PasswordHash
¯¯ 
=
¯¯ 
AccountController
¯¯  1
.
¯¯1 2
Hasher
¯¯2 8
.
¯¯8 9
HashPassword
¯¯9 E
(
¯¯E F
user
¯¯F J
,
¯¯J K
temporaryPassword
¯¯L ]
)
¯¯] ^
;
¯¯^ _
user
¯¯` d
.
¯¯d e
IsActive
¯¯e m
=
¯¯n o
true
¯¯p t
;
¯¯t u
access
˘˘ 
=
˘˘ 
new
˘˘ 
ClientAccess
˘˘ %
(
˘˘% &
client
˘˘& ,
.
˘˘, -
CompanyName
˘˘- 8
,
˘˘8 9
user
˘˘: >
.
˘˘> ?
Email
˘˘? D
,
˘˘D E
temporaryPassword
˘˘F W
)
˘˘W X
;
˘˘X Y
}
˙˙ 	
await
˚˚ 
db
˚˚ 
.
˚˚ 
SaveChangesAsync
˚˚ !
(
˚˚! "
ct
˚˚" $
)
˚˚$ %
;
˚˚% &
return
¸¸ 
Ok
¸¸ 
(
¸¸ 
await
¸¸ 
EmailAccessAsync
¸¸ (
(
¸¸( )
client
¸¸) /
,
¸¸/ 0
access
¸¸1 7
,
¸¸7 8
ct
¸¸9 ;
)
¸¸; <
)
¸¸< =
;
¸¸= >
}
˝˝ 
[
ˇˇ 
HttpPost
ˇˇ 
(
ˇˇ 
$str
ˇˇ 0
)
ˇˇ0 1
]
ˇˇ1 2
public
ÄÄ 

async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
ActionResult
ÄÄ "
>
ÄÄ" #
CreateProject
ÄÄ$ 1
(
ÄÄ1 2
Guid
ÄÄ2 6
clientId
ÄÄ7 ?
,
ÄÄ? @
ProjectRequest
ÄÄA O
request
ÄÄP W
,
ÄÄW X
CancellationToken
ÄÄY j
ct
ÄÄk m
)
ÄÄm n
{
ÅÅ 
if
ÇÇ 

(
ÇÇ 
!
ÇÇ 
await
ÇÇ 
db
ÇÇ 
.
ÇÇ 
Clients
ÇÇ 
.
ÇÇ 
AnyAsync
ÇÇ &
(
ÇÇ& '
x
ÇÇ' (
=>
ÇÇ) +
x
ÇÇ, -
.
ÇÇ- .
Id
ÇÇ. 0
==
ÇÇ1 3
clientId
ÇÇ4 <
,
ÇÇ< =
ct
ÇÇ> @
)
ÇÇ@ A
)
ÇÇA B
return
ÇÇC I
NotFound
ÇÇJ R
(
ÇÇR S
)
ÇÇS T
;
ÇÇT U
if
ÉÉ 

(
ÉÉ 
string
ÉÉ 
.
ÉÉ  
IsNullOrWhiteSpace
ÉÉ %
(
ÉÉ% &
request
ÉÉ& -
.
ÉÉ- .
Name
ÉÉ. 2
)
ÉÉ2 3
)
ÉÉ3 4
return
ÉÉ5 ;

BadRequest
ÉÉ< F
(
ÉÉF G
new
ÉÉG J
{
ÉÉK L
message
ÉÉM T
=
ÉÉU V
$str
ÉÉW 
}ÉÉÄ Å
)ÉÉÅ Ç
;ÉÉÇ É
var
ÑÑ 
slug
ÑÑ 
=
ÑÑ 
Slugify
ÑÑ 
(
ÑÑ 
string
ÑÑ !
.
ÑÑ! " 
IsNullOrWhiteSpace
ÑÑ" 4
(
ÑÑ4 5
request
ÑÑ5 <
.
ÑÑ< =
Slug
ÑÑ= A
)
ÑÑA B
?
ÑÑC D
request
ÑÑE L
.
ÑÑL M
Name
ÑÑM Q
:
ÑÑR S
request
ÑÑT [
.
ÑÑ[ \
Slug
ÑÑ\ `
)
ÑÑ` a
;
ÑÑa b
if
ÖÖ 

(
ÖÖ 
slug
ÖÖ 
.
ÖÖ 
Length
ÖÖ 
==
ÖÖ 
$num
ÖÖ 
)
ÖÖ 
return
ÖÖ $

BadRequest
ÖÖ% /
(
ÖÖ/ 0
new
ÖÖ0 3
{
ÖÖ4 5
message
ÖÖ6 =
=
ÖÖ> ?
$str
ÖÖ@ P
}
ÖÖQ R
)
ÖÖR S
;
ÖÖS T
if
ÜÜ 

(
ÜÜ 
await
ÜÜ 
db
ÜÜ 
.
ÜÜ 
Projects
ÜÜ 
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
ÜÜ- .
Slug
ÜÜ. 2
==
ÜÜ3 5
slug
ÜÜ6 :
,
ÜÜ: ;
ct
ÜÜ< >
)
ÜÜ> ?
)
ÜÜ? @
return
ÜÜA G
Conflict
ÜÜH P
(
ÜÜP Q
new
ÜÜQ T
{
ÜÜU V
message
ÜÜW ^
=
ÜÜ_ `
$"
ÜÜa c
$strÜÜc Ü
{ÜÜÜ á
slugÜÜá ã
}ÜÜã å
$strÜÜå é
"ÜÜé è
}ÜÜê ë
)ÜÜë í
;ÜÜí ì
var
áá 
project
áá 
=
áá 
new
áá 
Project
áá !
{
áá" #
ClientId
áá$ ,
=
áá- .
clientId
áá/ 7
,
áá7 8
Name
áá9 =
=
áá> ?
request
áá@ G
.
ááG H
Name
ááH L
.
ááL M
Trim
ááM Q
(
ááQ R
)
ááR S
,
ááS T
Slug
ááU Y
=
ááZ [
slug
áá\ `
}
ááa b
;
ááb c
if
ââ 

(
ââ 
!
ââ 
string
ââ 
.
ââ  
IsNullOrWhiteSpace
ââ &
(
ââ& '
request
ââ' .
.
ââ. /
GithubRepoOwner
ââ/ >
)
ââ> ?
&&
ââ@ B
!
ââC D
string
ââD J
.
ââJ K 
IsNullOrWhiteSpace
ââK ]
(
ââ] ^
request
ââ^ e
.
ââe f
GithubRepoName
ââf t
)
âât u
)
ââu v
{
ää 	
var
ãã 

repository
ãã 
=
ãã 
new
ãã  
ProjectRepository
ãã! 2
{
ãã3 4
	ProjectId
ãã5 >
=
ãã? @
project
ããA H
.
ããH I
Id
ããI K
,
ããK L
Owner
ããM R
=
ããS T
request
ããU \
.
ãã\ ]
GithubRepoOwner
ãã] l
.
ããl m
Trim
ããm q
(
ããq r
)
ããr s
,
ããs t
Name
ããu y
=
ããz {
requestãã| É
.ããÉ Ñ
GithubRepoNameããÑ í
.ããí ì
Trimããì ó
(ããó ò
)ããò ô
,ããô ö
	IsDefaultããõ §
=ãã• ¶
trueããß ´
}ãã¨ ≠
;ãã≠ Æ
if
åå 
(
åå 
await
åå %
RepositoryConflictAsync
åå -
(
åå- .

repository
åå. 8
.
åå8 9
Owner
åå9 >
,
åå> ?

repository
åå@ J
.
ååJ K
Name
ååK O
,
ååO P
null
ååQ U
,
ååU V
ct
ååW Y
)
ååY Z
is
åå[ ]
{
åå^ _
}
åå` a
conflict
ååb j
)
ååj k
return
åål r
conflict
åås {
;
åå{ |
project
çç 
.
çç 
Repositories
çç  
.
çç  !
Add
çç! $
(
çç$ %

repository
çç% /
)
çç/ 0
;
çç0 1
}
éé 	
db
èè 

.
èè
 
Projects
èè 
.
èè 
Add
èè 
(
èè 
project
èè 
)
èè  
;
èè  !
await
èè" '
db
èè( *
.
èè* +
SaveChangesAsync
èè+ ;
(
èè; <
ct
èè< >
)
èè> ?
;
èè? @
return
êê 
Created
êê 
(
êê 
$"
êê 
$str
êê -
{
êê- .
project
êê. 5
.
êê5 6
Id
êê6 8
}
êê8 9
"
êê9 :
,
êê: ;

ProjectDto
êê< F
(
êêF G
project
êêG N
)
êêN O
)
êêO P
;
êêP Q
}
ëë 
[
ìì 
	HttpPatch
ìì 
(
ìì 
$str
ìì #
)
ìì# $
]
ìì$ %
public
îî 

async
îî 
Task
îî 
<
îî 
ActionResult
îî "
>
îî" #
UpdateProject
îî$ 1
(
îî1 2
Guid
îî2 6
id
îî7 9
,
îî9 :
ProjectRequest
îî; I
request
îîJ Q
,
îîQ R
CancellationToken
îîS d
ct
îîe g
)
îîg h
{
ïï 
var
ññ 
project
ññ 
=
ññ 
await
ññ 
db
ññ 
.
ññ 
Projects
ññ '
.
ññ' (
Include
ññ( /
(
ññ/ 0
x
ññ0 1
=>
ññ2 4
x
ññ5 6
.
ññ6 7
Repositories
ññ7 C
)
ññC D
.
ññD E"
SingleOrDefaultAsync
ññE Y
(
ññY Z
x
ññZ [
=>
ññ\ ^
x
ññ_ `
.
ññ` a
Id
ñña c
==
ññd f
id
ññg i
,
ññi j
ct
ññk m
)
ññm n
;
ññn o
if
ññp r
(
ññs t
project
ññt {
is
ññ| ~
nullññ É
)ññÉ Ñ
returnññÖ ã
NotFoundññå î
(ññî ï
)ññï ñ
;ñññ ó
if
óó 

(
óó 
request
óó 
.
óó 
Name
óó 
is
óó 
not
óó 
null
óó  $
)
óó$ %
{
óó& '
if
óó( *
(
óó+ ,
string
óó, 2
.
óó2 3 
IsNullOrWhiteSpace
óó3 E
(
óóE F
request
óóF M
.
óóM N
Name
óóN R
)
óóR S
)
óóS T
return
óóU [

BadRequest
óó\ f
(
óóf g
new
óóg j
{
óók l
message
óóm t
=
óóu v
$stróów ü
}óó† °
)óó° ¢
;óó¢ £
projectóó§ ´
.óó´ ¨
Nameóó¨ ∞
=óó± ≤
requestóó≥ ∫
.óó∫ ª
Nameóóª ø
.óóø ¿
Trimóó¿ ƒ
(óóƒ ≈
)óó≈ ∆
;óó∆ «
}óó» …
await
òò 
db
òò 
.
òò 
SaveChangesAsync
òò !
(
òò! "
ct
òò" $
)
òò$ %
;
òò% &
return
òò' -
Ok
òò. 0
(
òò0 1

ProjectDto
òò1 ;
(
òò; <
project
òò< C
)
òòC D
)
òòD E
;
òòE F
}
ôô 
[
úú 

HttpDelete
úú 
(
úú 
$str
úú $
)
úú$ %
]
úú% &
public
ùù 

async
ùù 
Task
ùù 
<
ùù 
ActionResult
ùù "
>
ùù" #
DeleteProject
ùù$ 1
(
ùù1 2
Guid
ùù2 6
id
ùù7 9
,
ùù9 :
CancellationToken
ùù; L
ct
ùùM O
)
ùùO P
{
ûû 
var
üü 
project
üü 
=
üü 
await
üü 
db
üü 
.
üü 
Projects
üü '
.
üü' (
Include
üü( /
(
üü/ 0
x
üü0 1
=>
üü2 4
x
üü5 6
.
üü6 7
Repositories
üü7 C
)
üüC D
.
üüD E"
SingleOrDefaultAsync
üüE Y
(
üüY Z
x
üüZ [
=>
üü\ ^
x
üü_ `
.
üü` a
Id
üüa c
==
üüd f
id
üüg i
,
üüi j
ct
üük m
)
üüm n
;
üün o
if
üüp r
(
üüs t
project
üüt {
is
üü| ~
nullüü É
)üüÉ Ñ
returnüüÖ ã
NotFoundüüå î
(üüî ï
)üüï ñ
;üüñ ó
var
†† 
products
†† 
=
†† 
await
†† 
db
†† 
.
††  
ClientProducts
††  .
.
††. /

CountAsync
††/ 9
(
††9 :
x
††: ;
=>
††< >
x
††? @
.
††@ A
	ProjectId
††A J
==
††K M
id
††N P
,
††P Q
ct
††R T
)
††T U
;
††U V
var
°° 
tickets
°° 
=
°° 
await
°° 
db
°° 
.
°° 
Tickets
°° &
.
°°& '

CountAsync
°°' 1
(
°°1 2
x
°°2 3
=>
°°4 6
x
°°7 8
.
°°8 9
	ProjectId
°°9 B
==
°°C E
id
°°F H
,
°°H I
ct
°°J L
)
°°L M
;
°°M N
if
¢¢ 

(
¢¢ 
products
¢¢ 
+
¢¢ 
tickets
¢¢ 
>
¢¢  
$num
¢¢! "
)
¢¢" #
return
££ 
Conflict
££ 
(
££ 
new
££ 
{
££  !
message
££" )
=
££* +
$"
££, .
$str
££. /
{
££/ 0
project
££0 7
.
££7 8
Name
££8 <
}
££< =
$str
££= E
{
££E F
Count
££F K
(
££K L
products
££L T
,
££T U
$str
££V `
,
££` a
$str
££b m
)
££m n
}
££n o
{
££o p
(
££p q
products
££q y
>
££z {
$num
££| }
&&££~ Ä
tickets££Å à
>££â ä
$num££ã å
?££ç é
$str££è î
:££ï ñ
$str££ó ô
)££ô ö
}££ö õ
{££õ ú
Count££ú °
(££° ¢
tickets££¢ ©
,££© ™
$str££´ ≥
,££≥ ¥
$str££µ æ
)££æ ø
}££ø ¿
$str££¿ ¬
{££¬ √
(££√ ƒ
products££ƒ Ã
>££Õ Œ
$num££œ –
?££— “
$str££” ñ
:££ó ò
$str££ô Ê
)££Ê Á
}££Á Ë
$str££Ë È
"££È Í
}££Î Ï
)££Ï Ì
;££Ì Ó
db
§§ 

.
§§
 !
ProjectRepositories
§§ 
.
§§ 
RemoveRange
§§ *
(
§§* +
project
§§+ 2
.
§§2 3
Repositories
§§3 ?
)
§§? @
;
§§@ A
db
§§B D
.
§§D E
Projects
§§E M
.
§§M N
Remove
§§N T
(
§§T U
project
§§U \
)
§§\ ]
;
§§] ^
await
•• 
db
•• 
.
•• 
SaveChangesAsync
•• !
(
••! "
ct
••" $
)
••$ %
;
••% &
return
••' -
	NoContent
••. 7
(
••7 8
)
••8 9
;
••9 :
}
¶¶ 
private
®® 
static
®® 
string
®® 
Count
®® 
(
®®  
int
®®  #
n
®®$ %
,
®®% &
string
®®' -
one
®®. 1
,
®®1 2
string
®®3 9
many
®®: >
)
®®> ?
=>
®®@ B
n
®®C D
==
®®E G
$num
®®H I
?
®®J K
$str
®®L N
:
®®O P
n
®®Q R
==
®®S U
$num
®®V W
?
®®X Y
$"
®®Z \
$str
®®\ ^
{
®®^ _
one
®®_ b
}
®®b c
"
®®c d
:
®®e f
$"
®®g i
{
®®i j
n
®®j k
}
®®k l
$str
®®l m
{
®®m n
many
®®n r
}
®®r s
"
®®s t
;
®®t u
[
™™ 
HttpPost
™™ 
(
™™ 
$str
™™ /
)
™™/ 0
]
™™0 1
public
´´ 

async
´´ 
Task
´´ 
<
´´ 
ActionResult
´´ "
>
´´" #
AddRepository
´´$ 1
(
´´1 2
Guid
´´2 6
id
´´7 9
,
´´9 :
RepositoryRequest
´´; L
request
´´M T
,
´´T U
CancellationToken
´´V g
ct
´´h j
)
´´j k
{
¨¨ 
var
≠≠ 
project
≠≠ 
=
≠≠ 
await
≠≠ 
db
≠≠ 
.
≠≠ 
Projects
≠≠ '
.
≠≠' (
Include
≠≠( /
(
≠≠/ 0
x
≠≠0 1
=>
≠≠2 4
x
≠≠5 6
.
≠≠6 7
Repositories
≠≠7 C
)
≠≠C D
.
≠≠D E"
SingleOrDefaultAsync
≠≠E Y
(
≠≠Y Z
x
≠≠Z [
=>
≠≠\ ^
x
≠≠_ `
.
≠≠` a
Id
≠≠a c
==
≠≠d f
id
≠≠g i
,
≠≠i j
ct
≠≠k m
)
≠≠m n
;
≠≠n o
if
≠≠p r
(
≠≠s t
project
≠≠t {
is
≠≠| ~
null≠≠ É
)≠≠É Ñ
return≠≠Ö ã
NotFound≠≠å î
(≠≠î ï
)≠≠ï ñ
;≠≠ñ ó
if
ÆÆ 

(
ÆÆ 
string
ÆÆ 
.
ÆÆ  
IsNullOrWhiteSpace
ÆÆ %
(
ÆÆ% &
request
ÆÆ& -
.
ÆÆ- .
Owner
ÆÆ. 3
)
ÆÆ3 4
||
ÆÆ5 7
string
ÆÆ8 >
.
ÆÆ> ? 
IsNullOrWhiteSpace
ÆÆ? Q
(
ÆÆQ R
request
ÆÆR Y
.
ÆÆY Z
Name
ÆÆZ ^
)
ÆÆ^ _
)
ÆÆ_ `
return
ÆÆa g

BadRequest
ÆÆh r
(
ÆÆr s
new
ÆÆs v
{
ÆÆw x
messageÆÆy Ä
=ÆÆÅ Ç
$strÆÆÉ ±
}ÆÆ≤ ≥
)ÆÆ≥ ¥
;ÆÆ¥ µ
var
ØØ 

repository
ØØ 
=
ØØ 
new
ØØ 
ProjectRepository
ØØ .
{
ØØ/ 0
	ProjectId
ØØ1 :
=
ØØ; <
id
ØØ= ?
,
ØØ? @
Owner
ØØA F
=
ØØG H
request
ØØI P
.
ØØP Q
Owner
ØØQ V
.
ØØV W
Trim
ØØW [
(
ØØ[ \
)
ØØ\ ]
,
ØØ] ^
Name
ØØ_ c
=
ØØd e
request
ØØf m
.
ØØm n
Name
ØØn r
.
ØØr s
Trim
ØØs w
(
ØØw x
)
ØØx y
,
ØØy z
LabelØØ{ Ä
=ØØÅ Ç
EmptyToNullØØÉ é
(ØØé è
requestØØè ñ
.ØØñ ó
LabelØØó ú
)ØØú ù
,ØØù û
	IsDefaultØØü ®
=ØØ© ™
projectØØ´ ≤
.ØØ≤ ≥
RepositoriesØØ≥ ø
.ØØø ¿
CountØØ¿ ≈
==ØØ∆ »
$numØØ…  
||ØØÀ Õ
requestØØŒ ’
.ØØ’ ÷
	IsDefaultØØ÷ ﬂ
==ØØ‡ ‚
trueØØ„ Á
}ØØË È
;ØØÈ Í
if
∞∞ 

(
∞∞ 
await
∞∞ %
RepositoryConflictAsync
∞∞ )
(
∞∞) *

repository
∞∞* 4
.
∞∞4 5
Owner
∞∞5 :
,
∞∞: ;

repository
∞∞< F
.
∞∞F G
Name
∞∞G K
,
∞∞K L
null
∞∞M Q
,
∞∞Q R
ct
∞∞S U
)
∞∞U V
is
∞∞W Y
{
∞∞Z [
}
∞∞\ ]
conflict
∞∞^ f
)
∞∞f g
return
∞∞h n
conflict
∞∞o w
;
∞∞w x
if
±± 

(
±± 

repository
±± 
.
±± 
	IsDefault
±±  
)
±±  !
foreach
±±" )
(
±±* +
var
±±+ .
other
±±/ 4
in
±±5 7
project
±±8 ?
.
±±? @
Repositories
±±@ L
)
±±L M
other
±±N S
.
±±S T
	IsDefault
±±T ]
=
±±^ _
false
±±` e
;
±±e f
db
≤≤ 

.
≤≤
 !
ProjectRepositories
≤≤ 
.
≤≤ 
Add
≤≤ "
(
≤≤" #

repository
≤≤# -
)
≤≤- .
;
≤≤. /
project
≤≤0 7
.
≤≤7 8
Repositories
≤≤8 D
.
≤≤D E
Add
≤≤E H
(
≤≤H I

repository
≤≤I S
)
≤≤S T
;
≤≤T U
await
≤≤V [
db
≤≤\ ^
.
≤≤^ _
SaveChangesAsync
≤≤_ o
(
≤≤o p
ct
≤≤p r
)
≤≤r s
;
≤≤s t
return
≥≥ 
Ok
≥≥ 
(
≥≥ 

ProjectDto
≥≥ 
(
≥≥ 
project
≥≥ $
)
≥≥$ %
)
≥≥% &
;
≥≥& '
}
¥¥ 
[
∂∂ 
	HttpPatch
∂∂ 
(
∂∂ 
$str
∂∂ '
)
∂∂' (
]
∂∂( )
public
∑∑ 

async
∑∑ 
Task
∑∑ 
<
∑∑ 
ActionResult
∑∑ "
>
∑∑" #
UpdateRepository
∑∑$ 4
(
∑∑4 5
Guid
∑∑5 9
id
∑∑: <
,
∑∑< =
RepositoryRequest
∑∑> O
request
∑∑P W
,
∑∑W X
CancellationToken
∑∑Y j
ct
∑∑k m
)
∑∑m n
{
∏∏ 
var
ππ 

repository
ππ 
=
ππ 
await
ππ 
db
ππ !
.
ππ! "!
ProjectRepositories
ππ" 5
.
ππ5 6
	FindAsync
ππ6 ?
(
ππ? @
[
ππ@ A
id
ππA C
]
ππC D
,
ππD E
ct
ππF H
)
ππH I
;
ππI J
if
ππK M
(
ππN O

repository
ππO Y
is
ππZ \
null
ππ] a
)
ππa b
return
ππc i
NotFound
ππj r
(
ππr s
)
ππs t
;
ππt u
var
∫∫ 
project
∫∫ 
=
∫∫ 
await
∫∫ 
db
∫∫ 
.
∫∫ 
Projects
∫∫ '
.
∫∫' (
Include
∫∫( /
(
∫∫/ 0
x
∫∫0 1
=>
∫∫2 4
x
∫∫5 6
.
∫∫6 7
Repositories
∫∫7 C
)
∫∫C D
.
∫∫D E
SingleAsync
∫∫E P
(
∫∫P Q
x
∫∫Q R
=>
∫∫S U
x
∫∫V W
.
∫∫W X
Id
∫∫X Z
==
∫∫[ ]

repository
∫∫^ h
.
∫∫h i
	ProjectId
∫∫i r
,
∫∫r s
ct
∫∫t v
)
∫∫v w
;
∫∫w x
var
ªª 
owner
ªª 
=
ªª 
request
ªª 
.
ªª 
Owner
ªª !
?
ªª! "
.
ªª" #
Trim
ªª# '
(
ªª' (
)
ªª( )
??
ªª* ,

repository
ªª- 7
.
ªª7 8
Owner
ªª8 =
;
ªª= >
var
ªª? B
name
ªªC G
=
ªªH I
request
ªªJ Q
.
ªªQ R
Name
ªªR V
?
ªªV W
.
ªªW X
Trim
ªªX \
(
ªª\ ]
)
ªª] ^
??
ªª_ a

repository
ªªb l
.
ªªl m
Name
ªªm q
;
ªªq r
if
ºº 

(
ºº 
owner
ºº 
.
ºº 
Length
ºº 
==
ºº 
$num
ºº 
||
ºº  
name
ºº! %
.
ºº% &
Length
ºº& ,
==
ºº- /
$num
ºº0 1
)
ºº1 2
return
ºº3 9

BadRequest
ºº: D
(
ººD E
new
ººE H
{
ººI J
message
ººK R
=
ººS T
$strººU É
}ººÑ Ö
)ººÖ Ü
;ººÜ á
if
ææ 

(
ææ 
(
ææ 
owner
ææ 
!=
ææ 

repository
ææ  
.
ææ  !
Owner
ææ! &
||
ææ' )
name
ææ* .
!=
ææ/ 1

repository
ææ2 <
.
ææ< =
Name
ææ= A
)
ææA B
&&
ææC E
await
ææF K
db
ææL N
.
ææN O
Tickets
ææO V
.
ææV W
AnyAsync
ææW _
(
ææ_ `
x
ææ` a
=>
ææb d
x
ææe f
.
ææf g
RepositoryId
ææg s
==
ææt v
id
ææw y
&&
ææz |
x
ææ} ~
.
ææ~  
GithubIssueNumberææ ê
!=ææë ì
nullææî ò
,ææò ô
ctææö ú
)ææú ù
)ææù û
return
øø 
Conflict
øø 
(
øø 
new
øø 
{
øø  !
message
øø" )
=
øø* +
$strøø, Ä
}øøÅ Ç
)øøÇ É
;øøÉ Ñ
if
¿¿ 

(
¿¿ 
await
¿¿ %
RepositoryConflictAsync
¿¿ )
(
¿¿) *
owner
¿¿* /
,
¿¿/ 0
name
¿¿1 5
,
¿¿5 6
id
¿¿7 9
,
¿¿9 :
ct
¿¿; =
)
¿¿= >
is
¿¿? A
{
¿¿B C
}
¿¿D E
conflict
¿¿F N
)
¿¿N O
return
¿¿P V
conflict
¿¿W _
;
¿¿_ `

repository
¡¡ 
.
¡¡ 
Owner
¡¡ 
=
¡¡ 
owner
¡¡  
;
¡¡  !

repository
¡¡" ,
.
¡¡, -
Name
¡¡- 1
=
¡¡2 3
name
¡¡4 8
;
¡¡8 9
if
¬¬ 

(
¬¬ 
request
¬¬ 
.
¬¬ 
Label
¬¬ 
is
¬¬ 
not
¬¬  
null
¬¬! %
)
¬¬% &

repository
¬¬' 1
.
¬¬1 2
Label
¬¬2 7
=
¬¬8 9
EmptyToNull
¬¬: E
(
¬¬E F
request
¬¬F M
.
¬¬M N
Label
¬¬N S
)
¬¬S T
;
¬¬T U
if
√√ 

(
√√ 
request
√√ 
.
√√ 
	IsDefault
√√ 
==
√√  
true
√√! %
)
√√% &
foreach
√√' .
(
√√/ 0
var
√√0 3
other
√√4 9
in
√√: <
project
√√= D
.
√√D E
Repositories
√√E Q
)
√√Q R
other
√√S X
.
√√X Y
	IsDefault
√√Y b
=
√√c d
other
√√e j
.
√√j k
Id
√√k m
==
√√n p
id
√√q s
;
√√s t
await
ƒƒ 
db
ƒƒ 
.
ƒƒ 
SaveChangesAsync
ƒƒ !
(
ƒƒ! "
ct
ƒƒ" $
)
ƒƒ$ %
;
ƒƒ% &
return
ƒƒ' -
Ok
ƒƒ. 0
(
ƒƒ0 1

ProjectDto
ƒƒ1 ;
(
ƒƒ; <
project
ƒƒ< C
)
ƒƒC D
)
ƒƒD E
;
ƒƒE F
}
≈≈ 
[
«« 

HttpDelete
«« 
(
«« 
$str
«« (
)
««( )
]
««) *
public
»» 

async
»» 
Task
»» 
<
»» 
ActionResult
»» "
>
»»" #
DeleteRepository
»»$ 4
(
»»4 5
Guid
»»5 9
id
»»: <
,
»»< =
CancellationToken
»»> O
ct
»»P R
)
»»R S
{
…… 
var
   

repository
   
=
   
await
   
db
   !
.
  ! "!
ProjectRepositories
  " 5
.
  5 6
	FindAsync
  6 ?
(
  ? @
[
  @ A
id
  A C
]
  C D
,
  D E
ct
  F H
)
  H I
;
  I J
if
  K M
(
  N O

repository
  O Y
is
  Z \
null
  ] a
)
  a b
return
  c i
NotFound
  j r
(
  r s
)
  s t
;
  t u
if
ÀÀ 

(
ÀÀ 
await
ÀÀ 
db
ÀÀ 
.
ÀÀ 
Tickets
ÀÀ 
.
ÀÀ 
AnyAsync
ÀÀ %
(
ÀÀ% &
x
ÀÀ& '
=>
ÀÀ( *
x
ÀÀ+ ,
.
ÀÀ, -
RepositoryId
ÀÀ- 9
==
ÀÀ: <
id
ÀÀ= ?
,
ÀÀ? @
ct
ÀÀA C
)
ÀÀC D
)
ÀÀD E
return
ÀÀF L
Conflict
ÀÀM U
(
ÀÀU V
new
ÀÀV Y
{
ÀÀZ [
message
ÀÀ\ c
=
ÀÀd e
$strÀÀf £
}ÀÀ§ •
)ÀÀ• ¶
;ÀÀ¶ ß
var
ÃÃ 
project
ÃÃ 
=
ÃÃ 
await
ÃÃ 
db
ÃÃ 
.
ÃÃ 
Projects
ÃÃ '
.
ÃÃ' (
Include
ÃÃ( /
(
ÃÃ/ 0
x
ÃÃ0 1
=>
ÃÃ2 4
x
ÃÃ5 6
.
ÃÃ6 7
Repositories
ÃÃ7 C
)
ÃÃC D
.
ÃÃD E
SingleAsync
ÃÃE P
(
ÃÃP Q
x
ÃÃQ R
=>
ÃÃS U
x
ÃÃV W
.
ÃÃW X
Id
ÃÃX Z
==
ÃÃ[ ]

repository
ÃÃ^ h
.
ÃÃh i
	ProjectId
ÃÃi r
,
ÃÃr s
ct
ÃÃt v
)
ÃÃv w
;
ÃÃw x
project
ÕÕ 
.
ÕÕ 
Repositories
ÕÕ 
.
ÕÕ 
Remove
ÕÕ #
(
ÕÕ# $

repository
ÕÕ$ .
)
ÕÕ. /
;
ÕÕ/ 0
db
ÕÕ1 3
.
ÕÕ3 4!
ProjectRepositories
ÕÕ4 G
.
ÕÕG H
Remove
ÕÕH N
(
ÕÕN O

repository
ÕÕO Y
)
ÕÕY Z
;
ÕÕZ [
if
ŒŒ 

(
ŒŒ 

repository
ŒŒ 
.
ŒŒ 
	IsDefault
ŒŒ  
&&
ŒŒ! #
project
ŒŒ$ +
.
ŒŒ+ ,
Repositories
ŒŒ, 8
.
ŒŒ8 9
FirstOrDefault
ŒŒ9 G
(
ŒŒG H
)
ŒŒH I
is
ŒŒJ L
{
ŒŒM N
}
ŒŒO P
next
ŒŒQ U
)
ŒŒU V
next
ŒŒW [
.
ŒŒ[ \
	IsDefault
ŒŒ\ e
=
ŒŒf g
true
ŒŒh l
;
ŒŒl m
await
œœ 
db
œœ 
.
œœ 
SaveChangesAsync
œœ !
(
œœ! "
ct
œœ" $
)
œœ$ %
;
œœ% &
return
œœ' -
Ok
œœ. 0
(
œœ0 1

ProjectDto
œœ1 ;
(
œœ; <
project
œœ< C
)
œœC D
)
œœD E
;
œœE F
}
–– 
private
““ 
async
““ 
Task
““ 
<
““ 
ActionResult
““ #
?
““# $
>
““$ %%
RepositoryConflictAsync
““& =
(
““= >
string
““> D
owner
““E J
,
““J K
string
““L R
name
““S W
,
““W X
Guid
““Y ]
?
““] ^
exceptId
““_ g
,
““g h
CancellationToken
““i z
ct
““{ }
)
““} ~
=>““ Å
await
”” 
db
”” 
.
”” !
ProjectRepositories
”” $
.
””$ %
AnyAsync
””% -
(
””- .
x
””. /
=>
””0 2
x
””3 4
.
””4 5
Owner
””5 :
==
””; =
owner
””> C
&&
””D F
x
””G H
.
””H I
Name
””I M
==
””N P
name
””Q U
&&
””V X
x
””Y Z
.
””Z [
Id
””[ ]
!=
””^ `
exceptId
””a i
,
””i j
ct
””k m
)
””m n
?
‘‘ 
Conflict
‘‘ 
(
‘‘ 
new
‘‘ 
{
‘‘ 
message
‘‘ $
=
‘‘% &
$"
‘‘' )
$str
‘‘) 8
{
‘‘8 9
owner
‘‘9 >
}
‘‘> ?
$str
‘‘? @
{
‘‘@ A
name
‘‘A E
}
‘‘E F
$str
‘‘F f
"
‘‘f g
}
‘‘h i
)
‘‘i j
:
‘‘k l
null
‘‘m q
;
‘‘q r
private
◊◊ 
async
◊◊ 
Task
◊◊ 
<
◊◊ 
ClientAccess
◊◊ #
>
◊◊# $
EmailAccessAsync
◊◊% 5
(
◊◊5 6
Client
◊◊6 <
client
◊◊= C
,
◊◊C D
ClientAccess
◊◊E Q
access
◊◊R X
,
◊◊X Y
CancellationToken
◊◊Z k
ct
◊◊l n
)
◊◊n o
=>
◊◊p r
access
ÿÿ 
with
ÿÿ 
{
ÿÿ 
	EmailSent
ÿÿ 
=
ÿÿ  !
await
ÿÿ" '
accessEmail
ÿÿ( 3
.
ÿÿ3 4
	SendAsync
ÿÿ4 =
(
ÿÿ= >
client
ÿÿ> D
,
ÿÿD E
client
ÿÿF L
.
ÿÿL M
ContactName
ÿÿM X
,
ÿÿX Y
access
ÿÿZ `
.
ÿÿ` a
Email
ÿÿa f
,
ÿÿf g
access
ÿÿh n
.
ÿÿn o 
TemporaryPasswordÿÿo Ä
,ÿÿÄ Å
RequestÿÿÇ â
,ÿÿâ ä
ctÿÿã ç
)ÿÿç é
}ÿÿè ê
;ÿÿê ë
private
⁄⁄ 
ClientAccess
⁄⁄ 
AddAdminUser
⁄⁄ %
(
⁄⁄% &
Client
⁄⁄& ,
client
⁄⁄- 3
)
⁄⁄3 4
{
€€ 
var
‹‹ 
temporaryPassword
‹‹ 
=
‹‹ 
AccountController
‹‹  1
.
‹‹1 2
TemporaryPassword
‹‹2 C
(
‹‹C D
)
‹‹D E
;
‹‹E F
var
›› 
user
›› 
=
›› 
new
›› 
UserAccount
›› "
{
››# $
ClientId
››% -
=
››. /
client
››0 6
.
››6 7
Id
››7 9
,
››9 :
Name
››; ?
=
››@ A
client
››B H
.
››H I
ContactName
››I T
,
››T U
Email
››V [
=
››\ ]
client
››^ d
.
››d e
Email
››e j
,
››j k
Role
››l p
=
››q r
UserRole
››s {
.
››{ |
Admin››| Å
}››Ç É
;››É Ñ
user
ﬁﬁ 
.
ﬁﬁ 
PasswordHash
ﬁﬁ 
=
ﬁﬁ 
AccountController
ﬁﬁ -
.
ﬁﬁ- .
Hasher
ﬁﬁ. 4
.
ﬁﬁ4 5
HashPassword
ﬁﬁ5 A
(
ﬁﬁA B
user
ﬁﬁB F
,
ﬁﬁF G
temporaryPassword
ﬁﬁH Y
)
ﬁﬁY Z
;
ﬁﬁZ [
db
ﬂﬂ 

.
ﬂﬂ
 
UserAccounts
ﬂﬂ 
.
ﬂﬂ 
Add
ﬂﬂ 
(
ﬂﬂ 
user
ﬂﬂ  
)
ﬂﬂ  !
;
ﬂﬂ! "
return
‡‡ 
new
‡‡ 
ClientAccess
‡‡ 
(
‡‡  
client
‡‡  &
.
‡‡& '
CompanyName
‡‡' 2
,
‡‡2 3
user
‡‡4 8
.
‡‡8 9
Email
‡‡9 >
,
‡‡> ?
temporaryPassword
‡‡@ Q
)
‡‡Q R
;
‡‡R S
}
·· 
internal
„„ 
static
„„ 
string
„„ 
Slugify
„„ "
(
„„" #
string
„„# )
value
„„* /
)
„„/ 0
{
‰‰ 
var
ÂÂ 

normalized
ÂÂ 
=
ÂÂ 
value
ÂÂ 
.
ÂÂ 
Trim
ÂÂ #
(
ÂÂ# $
)
ÂÂ$ %
.
ÂÂ% &
ToLowerInvariant
ÂÂ& 6
(
ÂÂ6 7
)
ÂÂ7 8
.
ÂÂ8 9
	Normalize
ÂÂ9 B
(
ÂÂB C
System
ÂÂC I
.
ÂÂI J
Text
ÂÂJ N
.
ÂÂN O
NormalizationForm
ÂÂO `
.
ÂÂ` a
FormD
ÂÂa f
)
ÂÂf g
;
ÂÂg h
var
ÊÊ 
chars
ÊÊ 
=
ÊÊ 

normalized
ÊÊ 
.
ÊÊ 
Where
ÊÊ $
(
ÊÊ$ %
c
ÊÊ% &
=>
ÊÊ' )
System
ÊÊ* 0
.
ÊÊ0 1
Globalization
ÊÊ1 >
.
ÊÊ> ?
CharUnicodeInfo
ÊÊ? N
.
ÊÊN O 
GetUnicodeCategory
ÊÊO a
(
ÊÊa b
c
ÊÊb c
)
ÊÊc d
!=
ÊÊe g
System
ÊÊh n
.
ÊÊn o
Globalization
ÊÊo |
.
ÊÊ| }
UnicodeCategoryÊÊ} å
.ÊÊå ç
NonSpacingMarkÊÊç õ
)ÊÊõ ú
.ÊÊú ù
SelectÊÊù £
(ÊÊ£ §
cÊÊ§ •
=>ÊÊ¶ ®
charÊÊ© ≠
.ÊÊ≠ Æ
IsLetterOrDigitÊÊÆ Ω
(ÊÊΩ æ
cÊÊæ ø
)ÊÊø ¿
?ÊÊ¡ ¬
cÊÊ√ ƒ
:ÊÊ≈ ∆
$charÊÊ«  
)ÊÊ  À
;ÊÊÀ Ã
return
ÁÁ 
System
ÁÁ 
.
ÁÁ 
Text
ÁÁ 
.
ÁÁ  
RegularExpressions
ÁÁ -
.
ÁÁ- .
Regex
ÁÁ. 3
.
ÁÁ3 4
Replace
ÁÁ4 ;
(
ÁÁ; <
new
ÁÁ< ?
string
ÁÁ@ F
(
ÁÁF G
chars
ÁÁG L
.
ÁÁL M
ToArray
ÁÁM T
(
ÁÁT U
)
ÁÁU V
)
ÁÁV W
,
ÁÁW X
$str
ÁÁY `
,
ÁÁ` a
$str
ÁÁb e
)
ÁÁe f
.
ÁÁf g
Trim
ÁÁg k
(
ÁÁk l
$char
ÁÁl o
)
ÁÁo p
;
ÁÁp q
}
ËË 
[
ÍÍ 
HttpGet
ÍÍ 
(
ÍÍ 
$str
ÍÍ 
)
ÍÍ 
]
ÍÍ 
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
ÎÎ" #
Products
ÎÎ$ ,
(
ÎÎ, -
CancellationToken
ÎÎ- >
ct
ÎÎ? A
)
ÎÎA B
=>
ÎÎC E
Ok
ÎÎF H
(
ÎÎH I
(
ÎÎI J
await
ÎÎJ O
db
ÎÎP R
.
ÎÎR S
Products
ÎÎS [
.
ÎÎ[ \
OrderBy
ÎÎ\ c
(
ÎÎc d
x
ÎÎd e
=>
ÎÎf h
x
ÎÎi j
.
ÎÎj k
Name
ÎÎk o
)
ÎÎo p
.
ÎÎp q
ToListAsync
ÎÎq |
(
ÎÎ| }
ct
ÎÎ} 
)ÎÎ Ä
)ÎÎÄ Å
.ÎÎÅ Ç
SelectÎÎÇ à
(ÎÎà â

ProductDtoÎÎâ ì
)ÎÎì î
)ÎÎî ï
;ÎÎï ñ
[
ÌÌ 
HttpPost
ÌÌ 
(
ÌÌ 
$str
ÌÌ 
)
ÌÌ 
]
ÌÌ 
public
ÓÓ 

async
ÓÓ 
Task
ÓÓ 
<
ÓÓ 
ActionResult
ÓÓ "
>
ÓÓ" #
CreateProduct
ÓÓ$ 1
(
ÓÓ1 2
ProductRequest
ÓÓ2 @
request
ÓÓA H
,
ÓÓH I
CancellationToken
ÓÓJ [
ct
ÓÓ\ ^
)
ÓÓ^ _
{
ÔÔ 
var
 
error
 
=
 
ValidateProduct
 #
(
# $
request
$ +
)
+ ,
;
, -
if
. 0
(
1 2
error
2 7
is
8 :
not
; >
null
? C
)
C D
return
E K

BadRequest
L V
(
V W
new
W Z
{
[ \
message
] d
=
e f
error
g l
}
m n
)
n o
;
o p
var
ÒÒ 
product
ÒÒ 
=
ÒÒ 
	ToProduct
ÒÒ 
(
ÒÒ  
request
ÒÒ  '
)
ÒÒ' (
;
ÒÒ( )
db
ÒÒ* ,
.
ÒÒ, -
Products
ÒÒ- 5
.
ÒÒ5 6
Add
ÒÒ6 9
(
ÒÒ9 :
product
ÒÒ: A
)
ÒÒA B
;
ÒÒB C
await
ÒÒD I(
EnsureProductCategoryAsync
ÒÒJ d
(
ÒÒd e
product
ÒÒe l
.
ÒÒl m
Category
ÒÒm u
,
ÒÒu v
ct
ÒÒw y
)
ÒÒy z
;
ÒÒz {
awaitÒÒ| Å
dbÒÒÇ Ñ
.ÒÒÑ Ö 
SaveChangesAsyncÒÒÖ ï
(ÒÒï ñ
ctÒÒñ ò
)ÒÒò ô
;ÒÒô ö
returnÒÒõ °
CreatedÒÒ¢ ©
(ÒÒ© ™
$"ÒÒ™ ¨
$strÒÒ¨ ¿
{ÒÒ¿ ¡
productÒÒ¡ »
.ÒÒ» …
IdÒÒ… À
}ÒÒÀ Ã
"ÒÒÃ Õ
,ÒÒÕ Œ

ProductDtoÒÒœ Ÿ
(ÒÒŸ ⁄
productÒÒ⁄ ·
)ÒÒ· ‚
)ÒÒ‚ „
;ÒÒ„ ‰
}
ÚÚ 
[
ÙÙ 
	HttpPatch
ÙÙ 
(
ÙÙ 
$str
ÙÙ #
)
ÙÙ# $
]
ÙÙ$ %
public
ıı 

async
ıı 
Task
ıı 
<
ıı 
ActionResult
ıı "
>
ıı" #
UpdateProduct
ıı$ 1
(
ıı1 2
Guid
ıı2 6
id
ıı7 9
,
ıı9 :!
ProductPatchRequest
ıı; N
request
ııO V
,
ııV W
CancellationToken
ııX i
ct
ııj l
)
ııl m
{
ˆˆ 
var
˜˜ 
product
˜˜ 
=
˜˜ 
await
˜˜ 
db
˜˜ 
.
˜˜ 
Products
˜˜ '
.
˜˜' (
	FindAsync
˜˜( 1
(
˜˜1 2
[
˜˜2 3
id
˜˜3 5
]
˜˜5 6
,
˜˜6 7
ct
˜˜8 :
)
˜˜: ;
;
˜˜; <
if
˜˜= ?
(
˜˜@ A
product
˜˜A H
is
˜˜I K
null
˜˜L P
)
˜˜P Q
return
˜˜R X
NotFound
˜˜Y a
(
˜˜a b
)
˜˜b c
;
˜˜c d
if
¯¯ 

(
¯¯ 
request
¯¯ 
.
¯¯ 
Type
¯¯ 
is
¯¯ 
ProductType
¯¯ '
type
¯¯( ,
)
¯¯, -
product
¯¯. 5
.
¯¯5 6
Type
¯¯6 :
=
¯¯; <
type
¯¯= A
;
¯¯A B
if
¯¯C E
(
¯¯F G
request
¯¯G N
.
¯¯N O
Name
¯¯O S
is
¯¯T V
not
¯¯W Z
null
¯¯[ _
)
¯¯_ `
product
¯¯a h
.
¯¯h i
Name
¯¯i m
=
¯¯n o
request
¯¯p w
.
¯¯w x
Name
¯¯x |
.
¯¯| }
Trim¯¯} Å
(¯¯Å Ç
)¯¯Ç É
;¯¯É Ñ
if¯¯Ö á
(¯¯à â
request¯¯â ê
.¯¯ê ë
BillingCycle¯¯ë ù
is¯¯û †
BillingCycle¯¯° ≠
cycle¯¯Æ ≥
)¯¯≥ ¥
product¯¯µ º
.¯¯º Ω
BillingCycle¯¯Ω …
=¯¯  À
cycle¯¯Ã —
;¯¯— “
if¯¯” ’
(¯¯÷ ◊
request¯¯◊ ﬁ
.¯¯ﬁ ﬂ
	BasePrice¯¯ﬂ Ë
is¯¯È Î
not¯¯Ï Ô
null¯¯ Ù
)¯¯Ù ı
product¯¯ˆ ˝
.¯¯˝ ˛
	BasePrice¯¯˛ á
=¯¯à â
request¯¯ä ë
.¯¯ë í
	BasePrice¯¯í õ
;¯¯õ ú
if¯¯ù ü
(¯¯† °
request¯¯° ®
.¯¯® ©
Currency¯¯© ±
is¯¯≤ ¥
not¯¯µ ∏
null¯¯π Ω
)¯¯Ω æ
product¯¯ø ∆
.¯¯∆ «
Currency¯¯« œ
=¯¯– —
request¯¯“ Ÿ
.¯¯Ÿ ⁄
Currency¯¯⁄ ‚
.¯¯‚ „
Trim¯¯„ Á
(¯¯Á Ë
)¯¯Ë È
.¯¯È Í 
ToUpperInvariant¯¯Í ˙
(¯¯˙ ˚
)¯¯˚ ¸
;¯¯¸ ˝
if¯¯˛ Ä
(¯¯Å Ç
request¯¯Ç â
.¯¯â ä
Description¯¯ä ï
is¯¯ñ ò
not¯¯ô ú
null¯¯ù °
)¯¯° ¢
product¯¯£ ™
.¯¯™ ´
Description¯¯´ ∂
=¯¯∑ ∏
EmptyToNull¯¯π ƒ
(¯¯ƒ ≈
request¯¯≈ Ã
.¯¯Ã Õ
Description¯¯Õ ÿ
)¯¯ÿ Ÿ
;¯¯Ÿ ⁄
if¯¯€ ›
(¯¯ﬁ ﬂ
request¯¯ﬂ Ê
.¯¯Ê Á
IsActive¯¯Á Ô
is¯¯ Ú
bool¯¯Û ˜
active¯¯¯ ˛
)¯¯˛ ˇ
product¯¯Ä á
.¯¯á à
IsActive¯¯à ê
=¯¯ë í
active¯¯ì ô
;¯¯ô ö
if¯¯õ ù
(¯¯û ü
request¯¯ü ¶
.¯¯¶ ß
Category¯¯ß Ø
is¯¯∞ ≤
not¯¯≥ ∂
null¯¯∑ ª
)¯¯ª º
product¯¯Ω ƒ
.¯¯ƒ ≈
Category¯¯≈ Õ
=¯¯Œ œ
EmptyToNull¯¯– €
(¯¯€ ‹
request¯¯‹ „
.¯¯„ ‰
Category¯¯‰ Ï
)¯¯Ï Ì
;¯¯Ì Ó
if¯¯Ô Ò
(¯¯Ú Û
request¯¯Û ˙
.¯¯˙ ˚
Tags¯¯˚ ˇ
is¯¯Ä Ç
not¯¯É Ü
null¯¯á ã
)¯¯ã å
product¯¯ç î
.¯¯î ï
Tags¯¯ï ô
=¯¯ö õ
NormalizeTags¯¯ú ©
(¯¯© ™
request¯¯™ ±
.¯¯± ≤
Tags¯¯≤ ∂
)¯¯∂ ∑
;¯¯∑ ∏
if¯¯π ª
(¯¯º Ω
request¯¯Ω ƒ
.¯¯ƒ ≈
AllowsTickets¯¯≈ “
is¯¯” ’
bool¯¯÷ ⁄
allowsTickets¯¯€ Ë
)¯¯Ë È
product¯¯Í Ò
.¯¯Ò Ú
AllowsTickets¯¯Ú ˇ
=¯¯Ä Å
allowsTickets¯¯Ç è
;¯¯è ê
if¯¯ë ì
(¯¯î ï
request¯¯ï ú
.¯¯ú ù
TaxDocumentType¯¯ù ¨
is¯¯≠ Ø
TaxDocumentType¯¯∞ ø
taxType¯¯¿ «
)¯¯« »
product¯¯… –
.¯¯– —
TaxDocumentType¯¯— ‡
=¯¯· ‚
taxType¯¯„ Í
;¯¯Í Î
if
˘˘ 

(
˘˘ 
string
˘˘ 
.
˘˘  
IsNullOrWhiteSpace
˘˘ %
(
˘˘% &
product
˘˘& -
.
˘˘- .
Name
˘˘. 2
)
˘˘2 3
||
˘˘4 6
string
˘˘7 =
.
˘˘= > 
IsNullOrWhiteSpace
˘˘> P
(
˘˘P Q
product
˘˘Q X
.
˘˘X Y
Currency
˘˘Y a
)
˘˘a b
)
˘˘b c
return
˘˘d j

BadRequest
˘˘k u
(
˘˘u v
new
˘˘v y
{
˘˘z {
message˘˘| É
=˘˘Ñ Ö
$str˘˘Ü ©
}˘˘™ ´
)˘˘´ ¨
;˘˘¨ ≠
await
˙˙ (
EnsureProductCategoryAsync
˙˙ (
(
˙˙( )
product
˙˙) 0
.
˙˙0 1
Category
˙˙1 9
,
˙˙9 :
ct
˙˙; =
)
˙˙= >
;
˙˙> ?
await
˚˚ 
db
˚˚ 
.
˚˚ 
SaveChangesAsync
˚˚ !
(
˚˚! "
ct
˚˚" $
)
˚˚$ %
;
˚˚% &
return
˚˚' -
Ok
˚˚. 0
(
˚˚0 1

ProductDto
˚˚1 ;
(
˚˚; <
product
˚˚< C
)
˚˚C D
)
˚˚D E
;
˚˚E F
}
¸¸ 
[
˛˛ 
HttpGet
˛˛ 
(
˛˛ 
$str
˛˛ '
)
˛˛' (
]
˛˛( )
public
ˇˇ 

IActionResult
ˇˇ 
ProductTemplate
ˇˇ (
(
ˇˇ( )
)
ˇˇ) *
=>
ˇˇ+ -
File
ˇˇ. 2
(
ˇˇ2 3
CreateWorkbook
ˇˇ3 A
(
ˇˇA B
new
ÄÄ 
(
ÄÄ 
$str
ÄÄ 
,
ÄÄ 
true
ÄÄ 
,
ÄÄ 
$str
ÄÄ +
,
ÄÄ+ ,
Enum
ÄÄ- 1
.
ÄÄ1 2
GetNames
ÄÄ2 :
<
ÄÄ: ;
ProductType
ÄÄ; F
>
ÄÄF G
(
ÄÄG H
)
ÄÄH I
)
ÄÄI J
,
ÄÄJ K
new
ÅÅ 
(
ÅÅ 
$str
ÅÅ 
,
ÅÅ 
true
ÅÅ 
,
ÅÅ 
$str
ÅÅ G
)
ÅÅG H
,
ÅÅH I
new
ÇÇ 
(
ÇÇ 
$str
ÇÇ 
,
ÇÇ 
true
ÇÇ  
,
ÇÇ  !
$str
ÇÇ" \
,
ÇÇ\ ]
[
ÇÇ^ _
$str
ÇÇ_ f
,
ÇÇf g
$str
ÇÇh q
,
ÇÇq r
$str
ÇÇs ~
,
ÇÇ~ 
$strÇÇÄ å
,ÇÇå ç
$strÇÇé ô
,ÇÇô ö
$strÇÇõ ¢
]ÇÇ¢ £
)ÇÇ£ §
,ÇÇ§ •
new
ÉÉ 
(
ÉÉ 
$str
ÉÉ 
,
ÉÉ 
true
ÉÉ 
,
ÉÉ 
$strÉÉ ™
)ÉÉ™ ´
,ÉÉ´ ¨
new
ÑÑ 
(
ÑÑ 
$str
ÑÑ 
,
ÑÑ 
true
ÑÑ 
,
ÑÑ 
$str
ÑÑ .
,
ÑÑ. /
[
ÑÑ0 1
$str
ÑÑ1 6
,
ÑÑ6 7
$str
ÑÑ8 =
,
ÑÑ= >
$str
ÑÑ? D
]
ÑÑD E
)
ÑÑE F
,
ÑÑF G
new
ÖÖ 
(
ÖÖ 
$str
ÖÖ 
,
ÖÖ 
false
ÖÖ  
,
ÖÖ  !
$str
ÖÖ" /
)
ÖÖ/ 0
,
ÖÖ0 1
new
ÜÜ 
(
ÜÜ 
$str
ÜÜ 
,
ÜÜ 
false
ÜÜ 
,
ÜÜ 
$str
ÜÜ 5
,
ÜÜ5 6
[
ÜÜ7 8
$str
ÜÜ8 <
,
ÜÜ< =
$str
ÜÜ> B
]
ÜÜB C
)
ÜÜC D
,
ÜÜD E
new
áá 
(
áá 
$str
áá 
,
áá 
false
áá $
,
áá$ %
$str
áá& f
,
ááf g
Enum
ááh l
.
áál m
GetNames
áám u
<
ááu v
TaxDocumentTypeááv Ö
>ááÖ Ü
(ááÜ á
)ááá à
)ááà â
,ááâ ä
new
àà 
(
àà 
$str
àà 
,
àà 
false
àà 
,
àà 
$str
àà C
)
ààC D
,
ààD E
new
ââ 
(
ââ 
$str
ââ 
,
ââ 
false
ââ 
,
ââ 
$str
ââ w
)
ââw x
,
ââx y
new
ää 
(
ää 
$str
ää 
,
ää 
false
ää "
,
ää" #
$str
ää$ r
,
äär s
[
äät u
$str
ääu y
,
ääy z
$str
ää{ 
]ää Ä
)ääÄ Å
)ääÅ Ç
,ääÇ É
$str
ãã K
,
ããK L
$str
ããM g
)
ããg h
;
ããh i
[
çç 
HttpPost
çç 
(
çç 
$str
çç 
)
çç  
]
çç  !
public
éé 

async
éé 
Task
éé 
<
éé 
ActionResult
éé "
>
éé" #
ImportProducts
éé$ 2
(
éé2 3
	IFormFile
éé3 <
file
éé= A
,
ééA B
CancellationToken
ééC T
ct
ééU W
)
ééW X
{
èè 
var
êê 
(
êê 
failure
êê 
,
êê 
created
êê 
,
êê 
errors
êê %
)
êê% &
=
êê' (
await
êê) .
Import
êê/ 5
(
êê5 6
file
êê6 :
,
êê: ;
$str
êê< G
,
êêG H
async
êêI N
(
êêO P
row
êêP S
,
êêS T
	rowNumber
êêU ^
,
êê^ _
errors
êê` f
)
êêf g
=>
êêh j
{
ëë 
var
íí 
error
íí 
=
íí 
ParseProductRow
íí #
(
íí# $
row
íí$ '
,
íí' (
out
íí) ,
var
íí- 0
product
íí1 8
)
íí8 9
;
íí9 :
if
ìì 

(
ìì 
error
ìì 
is
ìì 
not
ìì 
null
ìì 
)
ìì 
{
ìì  
errors
ìì! '
.
ìì' (
Add
ìì( +
(
ìì+ ,
new
ìì, /
(
ìì/ 0
	rowNumber
ìì0 9
,
ìì9 :
error
ìì; @
)
ìì@ A
)
ììA B
;
ììB C
return
ììD J
false
ììK P
;
ììP Q
}
ììR S
db
îî 

.
îî
 
Products
îî 
.
îî 
Add
îî 
(
îî 
product
îî 
!
îî  
)
îî  !
;
îî! "
await
îî# ((
EnsureProductCategoryAsync
îî) C
(
îîC D
product
îîD K
!
îîK L
.
îîL M
Category
îîM U
,
îîU V
ct
îîW Y
)
îîY Z
;
îîZ [
return
îî\ b
true
îîc g
;
îîg h
}
ïï 	
,
ïï	 

ct
ïï 
)
ïï 
;
ïï 
return
ññ 
failure
ññ 
??
ññ 
Ok
ññ 
(
ññ 
new
ññ  
{
ññ! "
created
ññ# *
,
ññ* +
skipped
ññ, 3
=
ññ4 5
errors
ññ6 <
.
ññ< =
Count
ññ= B
,
ññB C
errors
ññD J
}
ññK L
)
ññL M
;
ññM N
}
óó 
[
ôô 
HttpPost
ôô 
(
ôô 
$str
ôô 0
)
ôô0 1
]
ôô1 2
public
öö 

async
öö 
Task
öö 
<
öö 
ActionResult
öö "
>
öö" #
AssignProduct
öö$ 1
(
öö1 2
Guid
öö2 6
clientId
öö7 ?
,
öö? @"
AssignProductRequest
ööA U
request
ööV ]
,
öö] ^
CancellationToken
öö_ p
ct
ööq s
)
öös t
{
õõ 
if
úú 

(
úú 
!
úú 
await
úú 
db
úú 
.
úú 
Clients
úú 
.
úú 
AnyAsync
úú &
(
úú& '
x
úú' (
=>
úú) +
x
úú, -
.
úú- .
Id
úú. 0
==
úú1 3
clientId
úú4 <
,
úú< =
ct
úú> @
)
úú@ A
||
úúB D
!
úúE F
await
úúF K
db
úúL N
.
úúN O
Projects
úúO W
.
úúW X
AnyAsync
úúX `
(
úú` a
x
úúa b
=>
úúc e
x
úúf g
.
úúg h
Id
úúh j
==
úúk m
request
úún u
.
úúu v
	ProjectId
úúv 
&&úúÄ Ç
xúúÉ Ñ
.úúÑ Ö
ClientIdúúÖ ç
==úúé ê
clientIdúúë ô
,úúô ö
ctúúõ ù
)úúù û
)úúû ü
returnúú† ¶
NotFoundúúß Ø
(úúØ ∞
)úú∞ ±
;úú± ≤
var
ùù 
product
ùù 
=
ùù 
await
ùù 
db
ùù 
.
ùù 
Products
ùù '
.
ùù' (
	FindAsync
ùù( 1
(
ùù1 2
[
ùù2 3
request
ùù3 :
.
ùù: ;
	ProductId
ùù; D
]
ùùD E
,
ùùE F
ct
ùùG I
)
ùùI J
;
ùùJ K
if
ùùL N
(
ùùO P
product
ùùP W
is
ùùX Z
null
ùù[ _
)
ùù_ `
return
ùùa g
NotFound
ùùh p
(
ùùp q
)
ùùq r
;
ùùr s
if
ûû 

(
ûû 
request
ûû 
.
ûû 
BillingMode
ûû 
is
ûû  "
not
ûû# &
(
ûû' (
$str
ûû( 0
or
ûû1 3
$str
ûû4 <
)
ûû< =
)
ûû= >
return
ûû? E

BadRequest
ûûF P
(
ûûP Q
new
ûûQ T
{
ûûU V
message
ûûW ^
=
ûû_ `
$strûûa Ä
}ûûÅ Ç
)ûûÇ É
;ûûÉ Ñ
if
üü 

(
üü 
request
üü 
.
üü 
BillingMode
üü 
==
üü  "
$str
üü# +
&&
üü, .
await
üü/ 4
db
üü5 7
.
üü7 8
PaymentSettings
üü8 G
.
üüG H
AnyAsync
üüH P
(
üüP Q
x
üüQ R
=>
üüS U
!
üüV W
x
üüW X
.
üüX Y
PayPalEnabled
üüY f
,
üüf g
ct
üüh j
)
üüj k
)
üük l
return
üüm s

BadRequest
üüt ~
(
üü~ 
newüü Ç
{üüÉ Ñ
messageüüÖ å
=üüç é
$strüüè ‚
}üü„ ‰
)üü‰ Â
;üüÂ Ê
var
†† 
item
†† 
=
†† 
new
†† 
ClientProduct
†† $
{
††% &
ClientId
††' /
=
††0 1
clientId
††2 :
,
††: ;
	ProjectId
††< E
=
††F G
request
††H O
.
††O P
	ProjectId
††P Y
,
††Y Z
	ProductId
††[ d
=
††e f
product
††g n
.
††n o
Id
††o q
,
††q r
BillingCycle
††s 
=††Ä Å
request††Ç â
.††â ä
BillingCycle††ä ñ
,††ñ ó
IsManualBilling††ò ß
=††® ©
request††™ ±
.††± ≤
BillingMode††≤ Ω
==††æ ¿
$str††¡ …
,††…  
Status††À —
=††“ ”
request††‘ €
.††€ ‹
BillingMode††‹ Á
==††Ë Í
$str††Î Û
?††Ù ı#
ClientProductStatus††ˆ â
.††â ä
Activo††ä ê
:††ë í#
ClientProductStatus††ì ¶
.††¶ ß
	Pendiente††ß ∞
,††∞ ±
Price††≤ ∑
=††∏ π
product††∫ ¡
.††¡ ¬
	BasePrice††¬ À
is††Ã Œ
null††œ ”
?††‘ ’
request††÷ ›
.††› ﬁ
Price††ﬁ „
:††‰ Â
null††Ê Í
,††Í Î

DomainName††Ï ˆ
=††˜ ¯
EmptyToNull††˘ Ñ
(††Ñ Ö
request††Ö å
.††å ç

DomainName††ç ó
)††ó ò
,††ò ô"
PriceLabelOverride††ö ¨
=††≠ Æ
EmptyToNull††Ø ∫
(††∫ ª
request††ª ¬
.††¬ √"
PriceLabelOverride††√ ’
)††’ ÷
,††÷ ◊
RenewsAt††ÿ ‡
=††· ‚
	ToUtcDate††„ Ï
(††Ï Ì
request††Ì Ù
.††Ù ı
RenewsAt††ı ˝
)††˝ ˛
,††˛ ˇ
NextChargeAt††Ä å
=††ç é
	ToUtcDate††è ò
(††ò ô
request††ô †
.††† °
NextChargeAt††° ≠
)††≠ Æ
,††Æ Ø
Product††∞ ∑
=††∏ π
product††∫ ¡
}††¬ √
;††√ ƒ
item
°° 
.
°° 
Status
°° 
=
°°  
RenewalReminderJob
°° (
.
°°( )
	StatusFor
°°) 2
(
°°2 3
item
°°3 7
.
°°7 8
Status
°°8 >
,
°°> ?
item
°°@ D
.
°°D E
RenewsAt
°°E M
,
°°M N
DateTime
°°O W
.
°°W X
UtcNow
°°X ^
)
°°^ _
;
°°_ `
if
¢¢ 

(
¢¢ 
item
¢¢ 
.
¢¢ 
SetDiscount
¢¢ 
(
¢¢ 
request
¢¢ $
.
¢¢$ %
Discount
¢¢% -
)
¢¢- .
is
¢¢/ 1
string
¢¢2 8
discountError
¢¢9 F
)
¢¢F G
return
¢¢H N

BadRequest
¢¢O Y
(
¢¢Y Z
new
¢¢Z ]
{
¢¢^ _
message
¢¢` g
=
¢¢h i
discountError
¢¢j w
}
¢¢x y
)
¢¢y z
;
¢¢z {
db
££ 

.
££
 
ClientProducts
££ 
.
££ 
Add
££ 
(
££ 
item
££ "
)
££" #
;
££# $
var
§§ 
igvRate
§§ 
=
§§ 
await
§§ 
db
§§ 
.
§§ 
IgvRateForAsync
§§ .
(
§§. /
clientId
§§/ 7
,
§§7 8
product
§§9 @
,
§§@ A
ct
§§B D
)
§§D E
;
§§E F
if
•• 

(
•• 
request
•• 
.
•• 
BillingMode
•• 
==
••  "
$str
••# +
)
••+ ,
{
¶¶ 	
try
ßß 
{
®® 
var
©© 
checkout
©© 
=
©© 
await
©© $
checkoutService
©©% 4
.
©©4 5

StartAsync
©©5 ?
(
©©? @
item
©©@ D
,
©©D E
product
©©F M
,
©©M N
Request
©©O V
,
©©V W
ct
©©X Z
,
©©Z [
igvRate
©©\ c
)
©©c d
;
©©d e
await
™™ 
db
™™ 
.
™™ 
SaveChangesAsync
™™ )
(
™™) *
ct
™™* ,
)
™™, -
;
™™- .
return
´´ 
Created
´´ 
(
´´ 
$"
´´ !
$str
´´! <
{
´´< =
item
´´= A
.
´´A B
Id
´´B D
}
´´D E
"
´´E F
,
´´F G
new
´´H K
{
´´L M
clientProduct
´´N [
=
´´\ ]
ClientProductDto
´´^ n
(
´´n o
item
´´o s
,
´´s t
igvRate
´´u |
)
´´| }
,
´´} ~
approvalUrl´´ ä
=´´ã å
checkout´´ç ï
.´´ï ñ
ApprovalUrl´´ñ °
}´´¢ £
)´´£ §
;´´§ •
}
¨¨ 
catch
≠≠ 
(
≠≠ '
InvalidOperationException
≠≠ ,
ex
≠≠- /
)
≠≠/ 0
{
≠≠1 2
return
≠≠3 9

BadRequest
≠≠: D
(
≠≠D E
new
≠≠E H
{
≠≠I J
message
≠≠K R
=
≠≠S T
ex
≠≠U W
.
≠≠W X
Message
≠≠X _
}
≠≠` a
)
≠≠a b
;
≠≠b c
}
≠≠d e
}
ÆÆ 	
await
ØØ 
db
ØØ 
.
ØØ 
SaveChangesAsync
ØØ !
(
ØØ! "
ct
ØØ" $
)
ØØ$ %
;
ØØ% &
return
ØØ' -
Created
ØØ. 5
(
ØØ5 6
$"
ØØ6 8
$str
ØØ8 S
{
ØØS T
item
ØØT X
.
ØØX Y
Id
ØØY [
}
ØØ[ \
"
ØØ\ ]
,
ØØ] ^
new
ØØ_ b
{
ØØc d
clientProduct
ØØe r
=
ØØs t
ClientProductDtoØØu Ö
(ØØÖ Ü
itemØØÜ ä
,ØØä ã
igvRateØØå ì
)ØØì î
,ØØî ï
approvalUrlØØñ °
=ØØ¢ £
(ØØ§ •
stringØØ• ´
?ØØ´ ¨
)ØØ¨ ≠
nullØØ≠ ±
}ØØ≤ ≥
)ØØ≥ ¥
;ØØ¥ µ
}
∞∞ 
[
∑∑ 
HttpPost
∑∑ 
(
∑∑ 
$str
∑∑ 2
)
∑∑2 3
]
∑∑3 4
public
∏∏ 

async
∏∏ 
Task
∏∏ 
<
∏∏ 
ActionResult
∏∏ "
>
∏∏" #%
RegisterTransferPayment
∏∏$ ;
(
∏∏; <
Guid
∏∏< @
id
∏∏A C
,
∏∏C D$
TransferPaymentRequest
∏∏E [
request
∏∏\ c
,
∏∏c d
[
∏∏e f
FromServices
∏∏f r
]
∏∏r s#
PayPalPaymentService∏∏t à
payments∏∏â ë
,∏∏ë í!
CancellationToken∏∏ì §
ct∏∏• ß
)∏∏ß ®
{
ππ 
var
∫∫ 
item
∫∫ 
=
∫∫ 
await
∫∫ 
db
∫∫ 
.
∫∫ 
ClientProducts
∫∫ *
.
∫∫* +
Include
∫∫+ 2
(
∫∫2 3
x
∫∫3 4
=>
∫∫5 7
x
∫∫8 9
.
∫∫9 :
Product
∫∫: A
)
∫∫A B
.
∫∫B C
Include
∫∫C J
(
∫∫J K
x
∫∫K L
=>
∫∫M O
x
∫∫P Q
.
∫∫Q R
Project
∫∫R Y
)
∫∫Y Z
.
∫∫Z ["
SingleOrDefaultAsync
∫∫[ o
(
∫∫o p
x
∫∫p q
=>
∫∫r t
x
∫∫u v
.
∫∫v w
Id
∫∫w y
==
∫∫z |
id
∫∫} 
,∫∫ Ä
ct∫∫Å É
)∫∫É Ñ
;∫∫Ñ Ö
if∫∫Ü à
(∫∫â ä
item∫∫ä é
is∫∫è ë
null∫∫í ñ
)∫∫ñ ó
return∫∫ò û
NotFound∫∫ü ß
(∫∫ß ®
)∫∫® ©
;∫∫© ™
if
ªª 

(
ªª 
!
ªª 
item
ªª 
.
ªª 
IsManualBilling
ªª !
)
ªª! "
return
ªª# )

BadRequest
ªª* 4
(
ªª4 5
new
ªª5 8
{
ªª9 :
message
ªª; B
=
ªªC D
$strªªE á
}ªªà â
)ªªâ ä
;ªªä ã
if
ºº 

(
ºº 
item
ºº 
.
ºº 
ValidateYears
ºº 
(
ºº 
request
ºº &
.
ºº& '
Years
ºº' ,
)
ºº, -
is
ºº. 0
string
ºº1 7

yearsError
ºº8 B
)
ººB C
return
ººD J

BadRequest
ººK U
(
ººU V
new
ººV Y
{
ººZ [
message
ºº\ c
=
ººd e

yearsError
ººf p
}
ººq r
)
ººr s
;
ººs t
var
ΩΩ 
igvRate
ΩΩ 
=
ΩΩ 
item
ΩΩ 
.
ΩΩ 
Product
ΩΩ "
is
ΩΩ# %
null
ΩΩ& *
?
ΩΩ+ ,
$num
ΩΩ- /
:
ΩΩ0 1
await
ΩΩ2 7
db
ΩΩ8 :
.
ΩΩ: ;
IgvRateForAsync
ΩΩ; J
(
ΩΩJ K
item
ΩΩK O
.
ΩΩO P
ClientId
ΩΩP X
,
ΩΩX Y
item
ΩΩZ ^
.
ΩΩ^ _
Product
ΩΩ_ f
,
ΩΩf g
ct
ΩΩh j
)
ΩΩj k
;
ΩΩk l
var
ææ 
amount
ææ 
=
ææ 
request
ææ 
.
ææ 
Amount
ææ #
??
ææ$ &
item
ææ' +
.
ææ+ ,
ChargeTotal
ææ, 7
(
ææ7 8
igvRate
ææ8 ?
,
ææ? @
request
ææA H
.
ææH I
Years
ææI N
)
ææN O
;
ææO P
if
øø 

(
øø 
amount
øø 
is
øø 
not
øø 
decimal
øø !
value
øø" '
||
øø( *
value
øø+ 0
<=
øø1 3
$num
øø4 5
)
øø5 6
return
øø7 =

BadRequest
øø> H
(
øøH I
new
øøI L
{
øøM N
message
øøO V
=
øøW X
$str
øøY u
}
øøv w
)
øøw x
;
øøx y
var
¿¿ 
	reference
¿¿ 
=
¿¿ 
request
¿¿ 
.
¿¿  
	Reference
¿¿  )
?
¿¿) *
.
¿¿* +
Trim
¿¿+ /
(
¿¿/ 0
)
¿¿0 1
;
¿¿1 2
var
¡¡ 
key
¡¡ 
=
¡¡ 
string
¡¡ 
.
¡¡  
IsNullOrWhiteSpace
¡¡ +
(
¡¡+ ,
	reference
¡¡, 5
)
¡¡5 6
?
¡¡7 8
$"
¡¡9 ;
$str
¡¡; ?
{
¡¡? @
Guid
¡¡@ D
.
¡¡D E
NewGuid
¡¡E L
(
¡¡L M
)
¡¡M N
:
¡¡N O
$str
¡¡O P
}
¡¡P Q
"
¡¡Q R
:
¡¡S T
$"
¡¡U W
$str
¡¡W [
{
¡¡[ \
	reference
¡¡\ e
}
¡¡e f
"
¡¡f g
;
¡¡g h
if
¬¬ 

(
¬¬ 
key
¬¬ 
.
¬¬ 
Length
¬¬ 
>
¬¬ 
$num
¬¬ 
)
¬¬ 
return
¬¬ $

BadRequest
¬¬% /
(
¬¬/ 0
new
¬¬0 3
{
¬¬4 5
message
¬¬6 =
=
¬¬> ?
$str
¬¬@ h
}
¬¬i j
)
¬¬j k
;
¬¬k l
var
√√ 
paidAt
√√ 
=
√√ 
	ToUtcDate
√√ 
(
√√ 
request
√√ &
.
√√& '
PaidAt
√√' -
)
√√- .
;
√√. /
if
ƒƒ 

(
ƒƒ 
paidAt
ƒƒ 
>
ƒƒ 
DateTime
ƒƒ 
.
ƒƒ 
UtcNow
ƒƒ $
.
ƒƒ$ %
AddDays
ƒƒ% ,
(
ƒƒ, -
$num
ƒƒ- .
)
ƒƒ. /
)
ƒƒ/ 0
return
ƒƒ1 7

BadRequest
ƒƒ8 B
(
ƒƒB C
new
ƒƒC F
{
ƒƒG H
message
ƒƒI P
=
ƒƒQ R
$str
ƒƒS z
}
ƒƒ{ |
)
ƒƒ| }
;
ƒƒ} ~
if
≈≈ 

(
≈≈ 
!
≈≈ 
await
≈≈ 
payments
≈≈ 
.
≈≈ 
ApplyPaymentAsync
≈≈ -
(
≈≈- .
item
≈≈. 2
,
≈≈2 3
key
≈≈4 7
,
≈≈7 8
value
≈≈9 >
,
≈≈> ?
item
≈≈@ D
.
≈≈D E
Product
≈≈E L
?
≈≈L M
.
≈≈M N
Currency
≈≈N V
,
≈≈V W
ct
≈≈X Z
,
≈≈Z [
new
≈≈\ _
(
≈≈_ `
PaymentMethods
≈≈` n
.
≈≈n o
Transferencia
≈≈o |
,
≈≈| }
paidAt≈≈~ Ñ
,≈≈Ñ Ö
request≈≈Ü ç
.≈≈ç é
Years≈≈é ì
)≈≈ì î
)≈≈î ï
)≈≈ï ñ
return≈≈ó ù
Conflict≈≈û ¶
(≈≈¶ ß
new≈≈ß ™
{≈≈´ ¨
message≈≈≠ ¥
=≈≈µ ∂
$str≈≈∑ 
}≈≈Ò Ú
)≈≈Ú Û
;≈≈Û Ù
item
«« 
.
«« 
Status
«« 
=
««  
RenewalReminderJob
«« (
.
««( )
	StatusFor
««) 2
(
««2 3
item
««3 7
.
««7 8
Status
««8 >
,
««> ?
item
««@ D
.
««D E
RenewsAt
««E M
,
««M N
DateTime
««O W
.
««W X
UtcNow
««X ^
)
««^ _
;
««_ `
await
««a f
db
««g i
.
««i j
SaveChangesAsync
««j z
(
««z {
ct
««{ }
)
««} ~
;
««~ 
return
»» 
Ok
»» 
(
»» 
ClientProductDto
»» "
(
»»" #
item
»»# '
,
»»' (
igvRate
»») 0
)
»»0 1
)
»»1 2
;
»»2 3
}
…… 
[
ÀÀ 
	HttpPatch
ÀÀ 
(
ÀÀ 
$str
ÀÀ *
)
ÀÀ* +
]
ÀÀ+ ,
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
ÃÃ" #!
UpdateClientProduct
ÃÃ$ 7
(
ÃÃ7 8
Guid
ÃÃ8 <
id
ÃÃ= ?
,
ÃÃ? @'
ClientProductPatchRequest
ÃÃA Z
request
ÃÃ[ b
,
ÃÃb c
CancellationToken
ÃÃd u
ct
ÃÃv x
)
ÃÃx y
{
ÕÕ 
var
ŒŒ 
item
ŒŒ 
=
ŒŒ 
await
ŒŒ 
db
ŒŒ 
.
ŒŒ 
ClientProducts
ŒŒ *
.
ŒŒ* +
Include
ŒŒ+ 2
(
ŒŒ2 3
x
ŒŒ3 4
=>
ŒŒ5 7
x
ŒŒ8 9
.
ŒŒ9 :
Product
ŒŒ: A
)
ŒŒA B
.
ŒŒB C
Include
ŒŒC J
(
ŒŒJ K
x
ŒŒK L
=>
ŒŒM O
x
ŒŒP Q
.
ŒŒQ R
Project
ŒŒR Y
)
ŒŒY Z
.
ŒŒZ ["
SingleOrDefaultAsync
ŒŒ[ o
(
ŒŒo p
x
ŒŒp q
=>
ŒŒr t
x
ŒŒu v
.
ŒŒv w
Id
ŒŒw y
==
ŒŒz |
id
ŒŒ} 
,ŒŒ Ä
ctŒŒÅ É
)ŒŒÉ Ñ
;ŒŒÑ Ö
ifŒŒÜ à
(ŒŒâ ä
itemŒŒä é
isŒŒè ë
nullŒŒí ñ
)ŒŒñ ó
returnŒŒò û
NotFoundŒŒü ß
(ŒŒß ®
)ŒŒ® ©
;ŒŒ© ™
if
œœ 

(
œœ 
request
œœ 
.
œœ 
Price
œœ 
is
œœ 
not
œœ  
null
œœ! %
)
œœ% &
item
œœ' +
.
œœ+ ,
Price
œœ, 1
=
œœ2 3
request
œœ4 ;
.
œœ; <
Price
œœ< A
;
œœA B
if
œœC E
(
œœF G
request
œœG N
.
œœN O
Status
œœO U
is
œœV X!
ClientProductStatus
œœY l
status
œœm s
)
œœs t
item
œœu y
.
œœy z
Statusœœz Ä
=œœÅ Ç
statusœœÉ â
;œœâ ä
ifœœã ç
(œœé è
requestœœè ñ
.œœñ ó
BillingCycleœœó £
isœœ§ ¶
BillingCycleœœß ≥
cycleœœ¥ π
)œœπ ∫
itemœœª ø
.œœø ¿
BillingCycleœœ¿ Ã
=œœÕ Œ
cycleœœœ ‘
;œœ‘ ’
ifœœ÷ ÿ
(œœŸ ⁄
requestœœ⁄ ·
.œœ· ‚

DomainNameœœ‚ Ï
isœœÌ Ô
notœœ Û
nullœœÙ ¯
)œœ¯ ˘
itemœœ˙ ˛
.œœ˛ ˇ

DomainNameœœˇ â
=œœä ã
EmptyToNullœœå ó
(œœó ò
requestœœò ü
.œœü †

DomainNameœœ† ™
)œœ™ ´
;œœ´ ¨
ifœœ≠ Ø
(œœ∞ ±
requestœœ± ∏
.œœ∏ π"
PriceLabelOverrideœœπ À
isœœÃ Œ
notœœœ “
nullœœ” ◊
)œœ◊ ÿ
itemœœŸ ›
.œœ› ﬁ"
PriceLabelOverrideœœﬁ 
=œœÒ Ú
EmptyToNullœœÛ ˛
(œœ˛ ˇ
requestœœˇ Ü
.œœÜ á"
PriceLabelOverrideœœá ô
)œœô ö
;œœö õ
ifœœú û
(œœü †
requestœœ† ß
.œœß ®
IsManualBillingœœ® ∑
isœœ∏ ∫
boolœœª ø
manualœœ¿ ∆
)œœ∆ «
itemœœ» Ã
.œœÃ Õ
IsManualBillingœœÕ ‹
=œœ› ﬁ
manualœœﬂ Â
;œœÂ Ê
if
–– 

(
–– 
request
–– 
.
–– 
Discount
–– 
is
–– 
not
––  #
null
––$ (
&&
––) +
item
––, 0
.
––0 1
SetDiscount
––1 <
(
––< =
request
––= D
.
––D E
Discount
––E M
)
––M N
is
––O Q
string
––R X
discountError
––Y f
)
––f g
return
––h n

BadRequest
––o y
(
––y z
new
––z }
{
––~ 
message––Ä á
=––à â
discountError––ä ó
}––ò ô
)––ô ö
;––ö õ
if
““ 

(
““ 
request
““ 
.
““ 
	ProjectId
““ 
is
““  
Guid
““! %
	projectId
““& /
&&
““0 2
	projectId
““3 <
!=
““= ?
item
““@ D
.
““D E
	ProjectId
““E N
)
““N O
{
”” 	
var
‘‘ 
project
‘‘ 
=
‘‘ 
await
‘‘ 
db
‘‘  "
.
‘‘" #
Projects
‘‘# +
.
‘‘+ ,"
SingleOrDefaultAsync
‘‘, @
(
‘‘@ A
x
‘‘A B
=>
‘‘C E
x
‘‘F G
.
‘‘G H
Id
‘‘H J
==
‘‘K M
	projectId
‘‘N W
&&
‘‘X Z
x
‘‘[ \
.
‘‘\ ]
ClientId
‘‘] e
==
‘‘f h
item
‘‘i m
.
‘‘m n
ClientId
‘‘n v
,
‘‘v w
ct
‘‘x z
)
‘‘z {
;
‘‘{ |
if
’’ 
(
’’ 
project
’’ 
is
’’ 
null
’’ 
)
’’  
return
’’! '

BadRequest
’’( 2
(
’’2 3
new
’’3 6
{
’’7 8
message
’’9 @
=
’’A B
$str
’’C m
}
’’n o
)
’’o p
;
’’p q
(
÷÷ 
item
÷÷ 
.
÷÷ 
	ProjectId
÷÷ 
,
÷÷ 
item
÷÷ !
.
÷÷! "
Project
÷÷" )
)
÷÷) *
=
÷÷+ ,
(
÷÷- .
project
÷÷. 5
.
÷÷5 6
Id
÷÷6 8
,
÷÷8 9
project
÷÷: A
)
÷÷A B
;
÷÷B C
}
◊◊ 	
await
ÿÿ 
db
ÿÿ 
.
ÿÿ 
SaveChangesAsync
ÿÿ !
(
ÿÿ! "
ct
ÿÿ" $
)
ÿÿ$ %
;
ÿÿ% &
return
ÿÿ' -
Ok
ÿÿ. 0
(
ÿÿ0 1
await
ÿÿ1 6#
ClientProductDtoAsync
ÿÿ7 L
(
ÿÿL M
item
ÿÿM Q
,
ÿÿQ R
ct
ÿÿS U
)
ÿÿU V
)
ÿÿV W
;
ÿÿW X
}
ŸŸ 
[
ﬂﬂ 

HttpDelete
ﬂﬂ 
(
ﬂﬂ 
$str
ﬂﬂ +
)
ﬂﬂ+ ,
]
ﬂﬂ, -
public
‡‡ 

async
‡‡ 
Task
‡‡ 
<
‡‡ 
ActionResult
‡‡ "
>
‡‡" #!
DeleteClientProduct
‡‡$ 7
(
‡‡7 8
Guid
‡‡8 <
id
‡‡= ?
,
‡‡? @
CancellationToken
‡‡A R
ct
‡‡S U
)
‡‡U V
{
·· 
var
‚‚ 
item
‚‚ 
=
‚‚ 
await
‚‚ 
db
‚‚ 
.
‚‚ 
ClientProducts
‚‚ *
.
‚‚* +
Include
‚‚+ 2
(
‚‚2 3
x
‚‚3 4
=>
‚‚5 7
x
‚‚8 9
.
‚‚9 :
Product
‚‚: A
)
‚‚A B
.
‚‚B C"
SingleOrDefaultAsync
‚‚C W
(
‚‚W X
x
‚‚X Y
=>
‚‚Z \
x
‚‚] ^
.
‚‚^ _
Id
‚‚_ a
==
‚‚b d
id
‚‚e g
,
‚‚g h
ct
‚‚i k
)
‚‚k l
;
‚‚l m
if
‚‚n p
(
‚‚q r
item
‚‚r v
is
‚‚w y
null
‚‚z ~
)
‚‚~ 
return‚‚Ä Ü
NotFound‚‚á è
(‚‚è ê
)‚‚ê ë
;‚‚ë í
var
„„ 
payments
„„ 
=
„„ 
await
„„ 
db
„„ 
.
„„  !
PaymentTransactions
„„  3
.
„„3 4

CountAsync
„„4 >
(
„„> ?
x
„„? @
=>
„„A C
x
„„D E
.
„„E F
ClientProductId
„„F U
==
„„V X
id
„„Y [
,
„„[ \
ct
„„] _
)
„„_ `
;
„„` a
if
‰‰ 

(
‰‰ 
payments
‰‰ 
==
‰‰ 
$num
‰‰ 
)
‰‰ 
payments
‰‰ #
=
‰‰$ %
await
‰‰& +
db
‰‰, .
.
‰‰. /
TaxDocumentLines
‰‰/ ?
.
‰‰? @

CountAsync
‰‰@ J
(
‰‰J K
x
‰‰K L
=>
‰‰M O
x
‰‰P Q
.
‰‰Q R
ClientProductId
‰‰R a
==
‰‰b d
id
‰‰e g
,
‰‰g h
ct
‰‰i k
)
‰‰k l
;
‰‰l m
if
ÂÂ 

(
ÂÂ 
payments
ÂÂ 
>
ÂÂ 
$num
ÂÂ 
)
ÂÂ 
return
ÂÂ  
Conflict
ÂÂ! )
(
ÂÂ) *
new
ÂÂ* -
{
ÂÂ. /
message
ÂÂ0 7
=
ÂÂ8 9
$"
ÂÂ: <
$str
ÂÂ< =
{
ÂÂ= >
item
ÂÂ> B
.
ÂÂB C
Product
ÂÂC J
?
ÂÂJ K
.
ÂÂK L
Name
ÂÂL P
}
ÂÂP Q
$str
ÂÂQ Y
{
ÂÂY Z
Count
ÂÂZ _
(
ÂÂ_ `
payments
ÂÂ` h
,
ÂÂh i
$str
ÂÂj {
,
ÂÂ{ |
$strÂÂ} ê
)ÂÂê ë
}ÂÂë í
$strÂÂí ˘
"ÂÂ˘ ˙
}ÂÂ˚ ¸
)ÂÂ¸ ˝
;ÂÂ˝ ˛
if
ÊÊ 

(
ÊÊ 
!
ÊÊ 
string
ÊÊ 
.
ÊÊ  
IsNullOrWhiteSpace
ÊÊ &
(
ÊÊ& '
item
ÊÊ' +
.
ÊÊ+ ,"
PayPalSubscriptionId
ÊÊ, @
)
ÊÊ@ A
&&
ÊÊB D
item
ÊÊE I
.
ÊÊI J
Status
ÊÊJ P
!=
ÊÊQ S!
ClientProductStatus
ÊÊT g
.
ÊÊg h
	Cancelado
ÊÊh q
)
ÊÊq r
return
ÊÊs y
ConflictÊÊz Ç
(ÊÊÇ É
newÊÊÉ Ü
{ÊÊá à
messageÊÊâ ê
=ÊÊë í
$strÊÊì ı
}ÊÊˆ ˜
)ÊÊ˜ ¯
;ÊÊ¯ ˘
await
ËË 
db
ËË 
.
ËË 
Tickets
ËË 
.
ËË 
Where
ËË 
(
ËË 
x
ËË  
=>
ËË! #
x
ËË$ %
.
ËË% &
ClientProductId
ËË& 5
==
ËË6 8
id
ËË9 ;
)
ËË; <
.
ËË< =
ForEachAsync
ËË= I
(
ËËI J
x
ËËJ K
=>
ËËL N
x
ËËO P
.
ËËP Q
ClientProductId
ËËQ `
=
ËËa b
null
ËËc g
,
ËËg h
ct
ËËi k
)
ËËk l
;
ËËl m
db
ÈÈ 

.
ÈÈ
 
TransferReports
ÈÈ 
.
ÈÈ 
RemoveRange
ÈÈ &
(
ÈÈ& '
await
ÈÈ' ,
db
ÈÈ- /
.
ÈÈ/ 0
TransferReports
ÈÈ0 ?
.
ÈÈ? @
Where
ÈÈ@ E
(
ÈÈE F
x
ÈÈF G
=>
ÈÈH J
x
ÈÈK L
.
ÈÈL M
ClientProductId
ÈÈM \
==
ÈÈ] _
id
ÈÈ` b
)
ÈÈb c
.
ÈÈc d
ToListAsync
ÈÈd o
(
ÈÈo p
ct
ÈÈp r
)
ÈÈr s
)
ÈÈs t
;
ÈÈt u
db
ÍÍ 

.
ÍÍ
 
ClientProducts
ÍÍ 
.
ÍÍ 
Remove
ÍÍ  
(
ÍÍ  !
item
ÍÍ! %
)
ÍÍ% &
;
ÍÍ& '
await
ÎÎ 
db
ÎÎ 
.
ÎÎ 
SaveChangesAsync
ÎÎ !
(
ÎÎ! "
ct
ÎÎ" $
)
ÎÎ$ %
;
ÎÎ% &
return
ÎÎ' -
	NoContent
ÎÎ. 7
(
ÎÎ7 8
)
ÎÎ8 9
;
ÎÎ9 :
}
ÏÏ 
[
ÛÛ 
HttpPut
ÛÛ 
(
ÛÛ 
$str
ÛÛ .
)
ÛÛ. /
]
ÛÛ/ 0
public
ÙÙ 

async
ÙÙ 
Task
ÙÙ 
<
ÙÙ 
ActionResult
ÙÙ "
>
ÙÙ" #&
UpdateClientProductDates
ÙÙ$ <
(
ÙÙ< =
Guid
ÙÙ= A
id
ÙÙB D
,
ÙÙD E'
ClientProductDatesRequest
ÙÙF _
request
ÙÙ` g
,
ÙÙg h
CancellationToken
ÙÙi z
ct
ÙÙ{ }
)
ÙÙ} ~
{
ıı 
var
ˆˆ 
item
ˆˆ 
=
ˆˆ 
await
ˆˆ 
db
ˆˆ 
.
ˆˆ 
ClientProducts
ˆˆ *
.
ˆˆ* +
Include
ˆˆ+ 2
(
ˆˆ2 3
x
ˆˆ3 4
=>
ˆˆ5 7
x
ˆˆ8 9
.
ˆˆ9 :
Product
ˆˆ: A
)
ˆˆA B
.
ˆˆB C
Include
ˆˆC J
(
ˆˆJ K
x
ˆˆK L
=>
ˆˆM O
x
ˆˆP Q
.
ˆˆQ R
Project
ˆˆR Y
)
ˆˆY Z
.
ˆˆZ ["
SingleOrDefaultAsync
ˆˆ[ o
(
ˆˆo p
x
ˆˆp q
=>
ˆˆr t
x
ˆˆu v
.
ˆˆv w
Id
ˆˆw y
==
ˆˆz |
id
ˆˆ} 
,ˆˆ Ä
ctˆˆÅ É
)ˆˆÉ Ñ
;ˆˆÑ Ö
ifˆˆÜ à
(ˆˆâ ä
itemˆˆä é
isˆˆè ë
nullˆˆí ñ
)ˆˆñ ó
returnˆˆò û
NotFoundˆˆü ß
(ˆˆß ®
)ˆˆ® ©
;ˆˆ© ™
item
˜˜ 
.
˜˜ 
RenewsAt
˜˜ 
=
˜˜ 
	ToUtcDate
˜˜ !
(
˜˜! "
request
˜˜" )
.
˜˜) *
RenewsAt
˜˜* 2
)
˜˜2 3
;
˜˜3 4
item
˜˜5 9
.
˜˜9 :
NextChargeAt
˜˜: F
=
˜˜G H
	ToUtcDate
˜˜I R
(
˜˜R S
request
˜˜S Z
.
˜˜Z [
NextChargeAt
˜˜[ g
)
˜˜g h
;
˜˜h i
item
¯¯ 
.
¯¯ 
Status
¯¯ 
=
¯¯  
RenewalReminderJob
¯¯ (
.
¯¯( )
	StatusFor
¯¯) 2
(
¯¯2 3
item
¯¯3 7
.
¯¯7 8
Status
¯¯8 >
,
¯¯> ?
item
¯¯@ D
.
¯¯D E
RenewsAt
¯¯E M
,
¯¯M N
DateTime
¯¯O W
.
¯¯W X
UtcNow
¯¯X ^
)
¯¯^ _
;
¯¯_ `
item
˘˘ 
.
˘˘ 
OnDatesChanged
˘˘ 
(
˘˘ 
)
˘˘ 
;
˘˘ 
await
˙˙ 
db
˙˙ 
.
˙˙ 
SaveChangesAsync
˙˙ !
(
˙˙! "
ct
˙˙" $
)
˙˙$ %
;
˙˙% &
return
˙˙' -
Ok
˙˙. 0
(
˙˙0 1
await
˙˙1 6#
ClientProductDtoAsync
˙˙7 L
(
˙˙L M
item
˙˙M Q
,
˙˙Q R
ct
˙˙S U
)
˙˙U V
)
˙˙V W
;
˙˙W X
}
˚˚ 
internal
˛˛ 
static
˛˛ 
DateTime
˛˛ 
?
˛˛ 
	ToUtcDate
˛˛ '
(
˛˛' (
DateOnly
˛˛( 0
?
˛˛0 1
date
˛˛2 6
)
˛˛6 7
=>
˛˛8 :
date
˛˛; ?
?
˛˛? @
.
˛˛@ A

ToDateTime
˛˛A K
(
˛˛K L
new
˛˛L O
TimeOnly
˛˛P X
(
˛˛X Y
$num
˛˛Y [
,
˛˛[ \
$num
˛˛] ^
)
˛˛^ _
,
˛˛_ `
DateTimeKind
˛˛a m
.
˛˛m n
Utc
˛˛n q
)
˛˛q r
;
˛˛r s
private
ÄÄ 
async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
(
ÄÄ 
ActionResult
ÄÄ $
?
ÄÄ$ %
Failure
ÄÄ& -
,
ÄÄ- .
int
ÄÄ/ 2
Created
ÄÄ3 :
,
ÄÄ: ;
List
ÄÄ< @
<
ÄÄ@ A
ImportError
ÄÄA L
>
ÄÄL M
Errors
ÄÄN T
)
ÄÄT U
>
ÄÄU V
Import
ÄÄW ]
(
ÄÄ] ^
	IFormFile
ÄÄ^ g
file
ÄÄh l
,
ÄÄl m
string
ÄÄn t
kind
ÄÄu y
,
ÄÄy z
Func
ÄÄ{ 
<ÄÄ Ä
IXLRowÄÄÄ Ü
,ÄÄÜ á
intÄÄà ã
,ÄÄã å
ListÄÄç ë
<ÄÄë í
ImportErrorÄÄí ù
>ÄÄù û
,ÄÄû ü
TaskÄÄ† §
<ÄÄ§ •
boolÄÄ• ©
>ÄÄ© ™
>ÄÄ™ ´
addRowÄÄ¨ ≤
,ÄÄ≤ ≥!
CancellationTokenÄÄ¥ ≈
ctÄÄ∆ »
)ÄÄ» …
{
ÅÅ 
var
ÇÇ 
errors
ÇÇ 
=
ÇÇ 
new
ÇÇ 
List
ÇÇ 
<
ÇÇ 
ImportError
ÇÇ )
>
ÇÇ) *
(
ÇÇ* +
)
ÇÇ+ ,
;
ÇÇ, -
var
ÇÇ. 1
created
ÇÇ2 9
=
ÇÇ: ;
$num
ÇÇ< =
;
ÇÇ= >
if
ÉÉ 

(
ÉÉ 
file
ÉÉ 
is
ÉÉ 
null
ÉÉ 
||
ÉÉ 
file
ÉÉ  
.
ÉÉ  !
Length
ÉÉ! '
==
ÉÉ( *
$num
ÉÉ+ ,
)
ÉÉ, -
return
ÉÉ. 4
(
ÉÉ5 6

BadRequest
ÉÉ6 @
(
ÉÉ@ A
new
ÉÉA D
{
ÉÉE F
message
ÉÉG N
=
ÉÉO P
$str
ÉÉQ o
}
ÉÉp q
)
ÉÉq r
,
ÉÉr s
$num
ÉÉt u
,
ÉÉu v
errors
ÉÉw }
)
ÉÉ} ~
;
ÉÉ~ 
try
ÑÑ 
{
ÑÑ 
using
ÑÑ 
var
ÑÑ 
stream
ÑÑ 
=
ÑÑ  
file
ÑÑ! %
.
ÑÑ% &
OpenReadStream
ÑÑ& 4
(
ÑÑ4 5
)
ÑÑ5 6
;
ÑÑ6 7
using
ÑÑ8 =
var
ÑÑ> A
book
ÑÑB F
=
ÑÑG H
new
ÑÑI L

XLWorkbook
ÑÑM W
(
ÑÑW X
stream
ÑÑX ^
)
ÑÑ^ _
;
ÑÑ_ `
var
ÑÑa d
sheet
ÑÑe j
=
ÑÑk l
book
ÑÑm q
.
ÑÑq r

Worksheets
ÑÑr |
.
ÑÑ| }
FirstÑÑ} Ç
(ÑÑÇ É
)ÑÑÉ Ñ
;ÑÑÑ Ö
foreachÑÑÜ ç
(ÑÑé è
varÑÑè í
rowÑÑì ñ
inÑÑó ô
sheetÑÑö ü
.ÑÑü †
RowsUsedÑÑ† ®
(ÑÑ® ©
)ÑÑ© ™
.ÑÑ™ ´
SkipÑÑ´ Ø
(ÑÑØ ∞
$numÑÑ∞ ±
)ÑÑ± ≤
)ÑÑ≤ ≥
ifÑÑ¥ ∂
(ÑÑ∑ ∏
awaitÑÑ∏ Ω
addRowÑÑæ ƒ
(ÑÑƒ ≈
rowÑÑ≈ »
,ÑÑ» …
rowÑÑ  Õ
.ÑÑÕ Œ
	RowNumberÑÑŒ ◊
(ÑÑ◊ ÿ
)ÑÑÿ Ÿ
,ÑÑŸ ⁄
errorsÑÑ€ ·
)ÑÑ· ‚
)ÑÑ‚ „
{ÑÑ‰ Â
awaitÑÑÊ Î
dbÑÑÏ Ó
.ÑÑÓ Ô 
SaveChangesAsyncÑÑÔ ˇ
(ÑÑˇ Ä
ctÑÑÄ Ç
)ÑÑÇ É
;ÑÑÉ Ñ
createdÑÑÖ å
++ÑÑå é
;ÑÑé è
}ÑÑê ë
}ÑÑí ì
catch
ÖÖ 
(
ÖÖ 
	Exception
ÖÖ 
ex
ÖÖ 
)
ÖÖ 
when
ÖÖ !
(
ÖÖ" #
ex
ÖÖ# %
is
ÖÖ& (
not
ÖÖ) ,
DbUpdateException
ÖÖ- >
)
ÖÖ> ?
{
ÖÖ@ A
return
ÖÖB H
(
ÖÖI J

BadRequest
ÖÖJ T
(
ÖÖT U
new
ÖÖU X
{
ÖÖY Z
message
ÖÖ[ b
=
ÖÖc d
$"
ÖÖe g
$strÖÖg á
{ÖÖá à
kindÖÖà å
}ÖÖå ç
$strÖÖç é
"ÖÖé è
}ÖÖê ë
)ÖÖë í
,ÖÖí ì
$numÖÖî ï
,ÖÖï ñ
errorsÖÖó ù
)ÖÖù û
;ÖÖû ü
}ÖÖ† °
return
ÜÜ 
(
ÜÜ 
null
ÜÜ 
,
ÜÜ 
created
ÜÜ 
,
ÜÜ 
errors
ÜÜ %
)
ÜÜ% &
;
ÜÜ& '
}
áá 
private
àà 
static
àà 
string
àà 
Cell
àà 
(
àà 
IXLRow
àà %
row
àà& )
,
àà) *
int
àà+ .
col
àà/ 2
)
àà2 3
=>
àà4 6
row
àà7 :
.
àà: ;
Cell
àà; ?
(
àà? @
col
àà@ C
)
ààC D
.
ààD E
	GetString
ààE N
(
ààN O
)
ààO P
;
ààP Q
private
çç 
static
çç 
byte
çç 
[
çç 
]
çç 
CreateWorkbook
çç (
(
çç( )
params
çç) /
TemplateColumn
çç0 >
[
çç> ?
]
çç? @
columns
ççA H
)
ççH I
{
éé 
const
èè 
int
èè 
LastDataRow
èè 
=
èè 
$num
èè  $
;
èè$ %
using
êê 
var
êê 
book
êê 
=
êê 
new
êê 

XLWorkbook
êê '
(
êê' (
)
êê( )
;
êê) *
var
êê+ .
sheet
êê/ 4
=
êê5 6
book
êê7 ;
.
êê; <
AddWorksheet
êê< H
(
êêH I
$str
êêI T
)
êêT U
;
êêU V
var
ëë 
help
ëë 
=
ëë 
book
ëë 
.
ëë 
AddWorksheet
ëë $
(
ëë$ %
$str
ëë% 6
)
ëë6 7
;
ëë7 8
help
íí 
.
íí 
Cell
íí 
(
íí 
$num
íí 
,
íí 
$num
íí 
)
íí 
.
íí 
Value
íí 
=
íí 
$str
íí  )
;
íí) *
help
íí+ /
.
íí/ 0
Cell
íí0 4
(
íí4 5
$num
íí5 6
,
íí6 7
$num
íí8 9
)
íí9 :
.
íí: ;
Value
íí; @
=
ííA B
$str
ííC P
;
ííP Q
help
ííR V
.
ííV W
Cell
ííW [
(
íí[ \
$num
íí\ ]
,
íí] ^
$num
íí_ `
)
íí` a
.
íía b
Value
ííb g
=
ííh i
$str
ííj }
;
íí} ~
helpíí É
.ííÉ Ñ
RowííÑ á
(ííá à
$numííà â
)ííâ ä
.ííä ã
Styleííã ê
.ííê ë
Fontííë ï
.ííï ñ
Boldííñ ö
=ííõ ú
trueííù °
;íí° ¢
for
ìì 
(
ìì 
var
ìì 
i
ìì 
=
ìì 
$num
ìì 
;
ìì 
i
ìì 
<
ìì 
columns
ìì #
.
ìì# $
Length
ìì$ *
;
ìì* +
i
ìì, -
++
ìì- /
)
ìì/ 0
{
îî 	
var
ïï 
column
ïï 
=
ïï 
columns
ïï  
[
ïï  !
i
ïï! "
]
ïï" #
;
ïï# $
var
ïï% (
accepted
ïï) 1
=
ïï2 3
column
ïï4 :
.
ïï: ;
Options
ïï; B
is
ïïC E
null
ïïF J
?
ïïK L
column
ïïM S
.
ïïS T
Accepted
ïïT \
:
ïï] ^
$"
ïï_ a
{
ïïa b
column
ïïb h
.
ïïh i
Accepted
ïïi q
}
ïïq r
$str
ïïr t
{
ïït u
string
ïïu {
.
ïï{ |
Joinïï| Ä
(ïïÄ Å
$strïïÅ Ö
,ïïÖ Ü
columnïïá ç
.ïïç é
Optionsïïé ï
)ïïï ñ
}ïïñ ó
"ïïó ò
;ïïò ô
var
ññ 
header
ññ 
=
ññ 
sheet
ññ 
.
ññ 
Cell
ññ #
(
ññ# $
$num
ññ$ %
,
ññ% &
i
ññ' (
+
ññ) *
$num
ññ+ ,
)
ññ, -
;
ññ- .
header
ññ/ 5
.
ññ5 6
Value
ññ6 ;
=
ññ< =
column
ññ> D
.
ññD E
Name
ññE I
;
ññI J
header
óó 
.
óó 
CreateComment
óó  
(
óó  !
)
óó! "
.
óó" #
AddText
óó# *
(
óó* +
$"
óó+ -
{
óó- .
(
óó. /
column
óó/ 5
.
óó5 6
Required
óó6 >
?
óó? @
$str
óóA N
:
óóO P
$str
óóQ [
)
óó[ \
}
óó\ ]
$str
óó] _
{
óó_ `
accepted
óó` h
}
óóh i
"
óói j
)
óój k
;
óók l
if
òò 
(
òò 
column
òò 
.
òò 
Required
òò 
)
òò  
header
òò! '
.
òò' (
Style
òò( -
.
òò- .
Fill
òò. 2
.
òò2 3
BackgroundColor
òò3 B
=
òòC D
XLColor
òòE L
.
òòL M
FromHtml
òòM U
(
òòU V
$str
òòV _
)
òò_ `
;
òò` a
if
ôô 
(
ôô 
column
ôô 
.
ôô 
Options
ôô 
is
ôô !
not
ôô" %
null
ôô& *
)
ôô* +
{
öö 
var
õõ 

validation
õõ 
=
õõ  
sheet
õõ! &
.
õõ& '
Range
õõ' ,
(
õõ, -
$num
õõ- .
,
õõ. /
i
õõ0 1
+
õõ2 3
$num
õõ4 5
,
õõ5 6
LastDataRow
õõ7 B
,
õõB C
i
õõD E
+
õõF G
$num
õõH I
)
õõI J
.
õõJ K"
CreateDataValidation
õõK _
(
õõ_ `
)
õõ` a
;
õõa b

validation
úú 
.
úú 
List
úú 
(
úú  
$"
úú  "
$str
úú" $
{
úú$ %
string
úú% +
.
úú+ ,
Join
úú, 0
(
úú0 1
$str
úú1 4
,
úú4 5
column
úú6 <
.
úú< =
Options
úú= D
)
úúD E
}
úúE F
$str
úúF H
"
úúH I
,
úúI J
true
úúK O
)
úúO P
;
úúP Q

validation
ùù 
.
ùù 

ErrorTitle
ùù %
=
ùù& '
column
ùù( .
.
ùù. /
Name
ùù/ 3
;
ùù3 4

validation
ùù5 ?
.
ùù? @
ErrorMessage
ùù@ L
=
ùùM N
$"
ùùO Q
$str
ùùQ d
{
ùùd e
string
ùùe k
.
ùùk l
Join
ùùl p
(
ùùp q
$str
ùùq u
,
ùùu v
column
ùùw }
.
ùù} ~
Optionsùù~ Ö
)ùùÖ Ü
}ùùÜ á
"ùùá à
;ùùà â
}
ûû 
help
üü 
.
üü 
Cell
üü 
(
üü 
i
üü 
+
üü 
$num
üü 
,
üü 
$num
üü 
)
üü 
.
üü  
Value
üü  %
=
üü& '
column
üü( .
.
üü. /
Name
üü/ 3
;
üü3 4
help
üü5 9
.
üü9 :
Cell
üü: >
(
üü> ?
i
üü? @
+
üüA B
$num
üüC D
,
üüD E
$num
üüF G
)
üüG H
.
üüH I
Value
üüI N
=
üüO P
column
üüQ W
.
üüW X
Required
üüX `
?
üüa b
$str
üüc g
:
üüh i
$str
üüj n
;
üün o
help
üüp t
.
üüt u
Cell
üüu y
(
üüy z
i
üüz {
+
üü| }
$num
üü~ 
,üü Ä
$numüüÅ Ç
)üüÇ É
.üüÉ Ñ
ValueüüÑ â
=üüä ã
acceptedüüå î
;üüî ï
}
†† 	
sheet
°° 
.
°° 
Row
°° 
(
°° 
$num
°° 
)
°° 
.
°° 
Style
°° 
.
°° 
Font
°° 
.
°°  
Bold
°°  $
=
°°% &
true
°°' +
;
°°+ ,
sheet
°°- 2
.
°°2 3
Columns
°°3 :
(
°°: ;
)
°°; <
.
°°< =
AdjustToContents
°°= M
(
°°M N
)
°°N O
;
°°O P
help
°°Q U
.
°°U V
Columns
°°V ]
(
°°] ^
)
°°^ _
.
°°_ `
AdjustToContents
°°` p
(
°°p q
)
°°q r
;
°°r s
help
¢¢ 
.
¢¢ 
Cell
¢¢ 
(
¢¢ 
columns
¢¢ 
.
¢¢ 
Length
¢¢  
+
¢¢! "
$num
¢¢# $
,
¢¢$ %
$num
¢¢& '
)
¢¢' (
.
¢¢( )
Value
¢¢) .
=
¢¢/ 0
$str¢¢1 ñ
;¢¢ñ ó
using
££ 
var
££ 
stream
££ 
=
££ 
new
££ 
MemoryStream
££ +
(
££+ ,
)
££, -
;
££- .
book
££/ 3
.
££3 4
SaveAs
££4 :
(
££: ;
stream
££; A
)
££A B
;
££B C
return
££D J
stream
££K Q
.
££Q R
ToArray
££R Y
(
££Y Z
)
££Z [
;
££[ \
}
§§ 
private
•• 
static
•• 
string
•• 
?
•• 
EmptyToNull
•• &
(
••& '
string
••' -
?
••- .
value
••/ 4
)
••4 5
=>
••6 8
string
••9 ?
.
••? @ 
IsNullOrWhiteSpace
••@ R
(
••R S
value
••S X
)
••X Y
?
••Z [
null
••\ `
:
••a b
value
••c h
.
••h i
Trim
••i m
(
••m n
)
••n o
;
••o p
private
¶¶ 
static
¶¶ 
string
¶¶ 
?
¶¶ 
ValidateClient
¶¶ )
(
¶¶) *
ClientRequest
¶¶* 7
request
¶¶8 ?
)
¶¶? @
=>
¶¶A C
string
¶¶D J
.
¶¶J K 
IsNullOrWhiteSpace
¶¶K ]
(
¶¶] ^
request
¶¶^ e
.
¶¶e f
CompanyName
¶¶f q
)
¶¶q r
||
¶¶s u
string
¶¶v |
.
¶¶| }!
IsNullOrWhiteSpace¶¶} è
(¶¶è ê
request¶¶ê ó
.¶¶ó ò
ContactName¶¶ò £
)¶¶£ §
||¶¶• ß
string¶¶® Æ
.¶¶Æ Ø"
IsNullOrWhiteSpace¶¶Ø ¡
(¶¶¡ ¬
request¶¶¬ …
.¶¶…  
Email¶¶  œ
)¶¶œ –
||¶¶— ”
!¶¶‘ ’
request¶¶’ ‹
.¶¶‹ ›
Email¶¶› ‚
.¶¶‚ „
Contains¶¶„ Î
(¶¶Î Ï
$char¶¶Ï Ô
)¶¶Ô 
?¶¶Ò Ú
$str¶¶Û ß
:¶¶® ©
request¶¶™ ±
.¶¶± ≤!
PreferredLanguage¶¶≤ √
.¶¶√ ƒ
Trim¶¶ƒ »
(¶¶» …
)¶¶…  
.¶¶  À 
ToLowerInvariant¶¶À €
(¶¶€ ‹
)¶¶‹ ›
is¶¶ﬁ ‡
not¶¶· ‰
(¶¶Â Ê
$str¶¶Ê Í
or¶¶Î Ì
$str¶¶Ó Ú
or¶¶Û ı
$str¶¶ˆ ˙
)¶¶˙ ˚
?¶¶¸ ˝
$str¶¶˛ ê
:¶¶ë í
null¶¶ì ó
;¶¶ó ò
private
ßß 
static
ßß 
string
ßß 
?
ßß 
ValidateProduct
ßß *
(
ßß* +
ProductRequest
ßß+ 9
request
ßß: A
)
ßßA B
=>
ßßC E
string
ßßF L
.
ßßL M 
IsNullOrWhiteSpace
ßßM _
(
ßß_ `
request
ßß` g
.
ßßg h
Name
ßßh l
)
ßßl m
||
ßßn p
string
ßßq w
.
ßßw x!
IsNullOrWhiteSpaceßßx ä
(ßßä ã
requestßßã í
.ßßí ì
Currencyßßì õ
)ßßõ ú
?ßßù û
$strßßü ¬
:ßß√ ƒ
nullßß≈ …
;ßß…  
private
©© 
async
©© 
Task
©© (
EnsureProductCategoryAsync
©© 1
(
©©1 2
string
©©2 8
?
©©8 9
name
©©: >
,
©©> ?
CancellationToken
©©@ Q
ct
©©R T
)
©©T U
{
™™ 
if
´´ 

(
´´ 
string
´´ 
.
´´  
IsNullOrWhiteSpace
´´ %
(
´´% &
name
´´& *
)
´´* +
)
´´+ ,
return
´´- 3
;
´´3 4
name
¨¨ 
=
¨¨ 
name
¨¨ 
.
¨¨ 
Trim
¨¨ 
(
¨¨ 
)
¨¨ 
;
¨¨ 
if
≠≠ 

(
≠≠ 
db
≠≠ 
.
≠≠ 
ProductCategories
≠≠  
.
≠≠  !
Local
≠≠! &
.
≠≠& '
Any
≠≠' *
(
≠≠* +
x
≠≠+ ,
=>
≠≠- /
x
≠≠0 1
.
≠≠1 2
Name
≠≠2 6
.
≠≠6 7
Equals
≠≠7 =
(
≠≠= >
name
≠≠> B
,
≠≠B C
StringComparison
≠≠D T
.
≠≠T U
OrdinalIgnoreCase
≠≠U f
)
≠≠f g
)
≠≠g h
||
≠≠i k
await
≠≠l q
db
≠≠r t
.
≠≠t u 
ProductCategories≠≠u Ü
.≠≠Ü á
AnyAsync≠≠á è
(≠≠è ê
x≠≠ê ë
=>≠≠í î
x≠≠ï ñ
.≠≠ñ ó
Name≠≠ó õ
==≠≠ú û
name≠≠ü £
,≠≠£ §
ct≠≠• ß
)≠≠ß ®
)≠≠® ©
return≠≠™ ∞
;≠≠∞ ±
db
ÆÆ 

.
ÆÆ
 
ProductCategories
ÆÆ 
.
ÆÆ 
Add
ÆÆ  
(
ÆÆ  !
new
ÆÆ! $
ProductCategory
ÆÆ% 4
{
ÆÆ5 6
Name
ÆÆ7 ;
=
ÆÆ< =
name
ÆÆ> B
,
ÆÆB C
	SortOrder
ÆÆD M
=
ÆÆN O
await
ÆÆP U
db
ÆÆV X
.
ÆÆX Y
ProductCategories
ÆÆY j
.
ÆÆj k

CountAsync
ÆÆk u
(
ÆÆu v
ct
ÆÆv x
)
ÆÆx y
+
ÆÆz {
db
ÆÆ| ~
.
ÆÆ~  
ProductCategoriesÆÆ ê
.ÆÆê ë
LocalÆÆë ñ
.ÆÆñ ó
CountÆÆó ú
}ÆÆù û
)ÆÆû ü
;ÆÆü †
}
ØØ 
internal
≤≤ 
static
≤≤ 
string
≤≤ 
Fold
≤≤ 
(
≤≤  
string
≤≤  &
value
≤≤' ,
)
≤≤, -
=>
≤≤. 0
new
≤≤1 4
(
≤≤4 5
value
≤≤5 :
.
≤≤: ;
Trim
≤≤; ?
(
≤≤? @
)
≤≤@ A
.
≤≤A B
ToLowerInvariant
≤≤B R
(
≤≤R S
)
≤≤S T
.
≤≤T U
	Normalize
≤≤U ^
(
≤≤^ _
System
≤≤_ e
.
≤≤e f
Text
≤≤f j
.
≤≤j k
NormalizationForm
≤≤k |
.
≤≤| }
FormD≤≤} Ç
)≤≤Ç É
.
≥≥ 	
Where
≥≥	 
(
≥≥ 
c
≥≥ 
=>
≥≥ 
System
≥≥ 
.
≥≥ 
Globalization
≥≥ (
.
≥≥( )
CharUnicodeInfo
≥≥) 8
.
≥≥8 9 
GetUnicodeCategory
≥≥9 K
(
≥≥K L
c
≥≥L M
)
≥≥M N
!=
≥≥O Q
System
≥≥R X
.
≥≥X Y
Globalization
≥≥Y f
.
≥≥f g
UnicodeCategory
≥≥g v
.
≥≥v w
NonSpacingMark≥≥w Ö
)≥≥Ö Ü
.≥≥Ü á
ToArray≥≥á é
(≥≥é è
)≥≥è ê
)≥≥ê ë
;≥≥ë í
private
µµ 
static
µµ 
Product
µµ 
	ToProduct
µµ $
(
µµ$ %
ProductRequest
µµ% 3
r
µµ4 5
)
µµ5 6
=>
µµ7 9
new
µµ: =
(
µµ= >
)
µµ> ?
{
µµ@ A
Type
µµB F
=
µµG H
r
µµI J
.
µµJ K
Type
µµK O
,
µµO P
Name
µµQ U
=
µµV W
r
µµX Y
.
µµY Z
Name
µµZ ^
.
µµ^ _
Trim
µµ_ c
(
µµc d
)
µµd e
,
µµe f
BillingCycle
µµg s
=
µµt u
r
µµv w
.
µµw x
BillingCycleµµx Ñ
,µµÑ Ö
	BasePriceµµÜ è
=µµê ë
rµµí ì
.µµì î
	BasePriceµµî ù
,µµù û
Currencyµµü ß
=µµ® ©
rµµ™ ´
.µµ´ ¨
Currencyµµ¨ ¥
.µµ¥ µ
Trimµµµ π
(µµπ ∫
)µµ∫ ª
.µµª º 
ToUpperInvariantµµº Ã
(µµÃ Õ
)µµÕ Œ
,µµŒ œ
Descriptionµµ– €
=µµ‹ ›
EmptyToNullµµﬁ È
(µµÈ Í
rµµÍ Î
.µµÎ Ï
DescriptionµµÏ ˜
)µµ˜ ¯
,µµ¯ ˘
IsActiveµµ˙ Ç
=µµÉ Ñ
rµµÖ Ü
.µµÜ á
IsActiveµµá è
,µµè ê
TaxDocumentTypeµµë †
=µµ° ¢
rµµ£ §
.µµ§ •
TaxDocumentTypeµµ• ¥
,µµ¥ µ
Categoryµµ∂ æ
=µµø ¿
EmptyToNullµµ¡ Ã
(µµÃ Õ
rµµÕ Œ
.µµŒ œ
Categoryµµœ ◊
)µµ◊ ÿ
,µµÿ Ÿ
Tagsµµ⁄ ﬁ
=µµﬂ ‡
NormalizeTagsµµ· Ó
(µµÓ Ô
rµµÔ 
.µµ Ò
TagsµµÒ ı
)µµı ˆ
,µµˆ ˜
AllowsTicketsµµ¯ Ö
=µµÜ á
rµµà â
.µµâ ä
AllowsTicketsµµä ó
}µµò ô
;µµô ö
private
∑∑ 
static
∑∑ 
string
∑∑ 
?
∑∑ 
NormalizeTags
∑∑ (
(
∑∑( )
string
∑∑) /
?
∑∑/ 0
tags
∑∑1 5
)
∑∑5 6
=>
∑∑7 9
tags
∑∑: >
?
∑∑> ?
.
∑∑? @
Split
∑∑@ E
(
∑∑E F
$char
∑∑F I
,
∑∑I J 
StringSplitOptions
∑∑K ]
.
∑∑] ^ 
RemoveEmptyEntries
∑∑^ p
|
∑∑q r!
StringSplitOptions∑∑s Ö
.∑∑Ö Ü
TrimEntries∑∑Ü ë
)∑∑ë í
.∑∑í ì
Distinct∑∑ì õ
(∑∑õ ú
StringComparer∑∑ú ™
.∑∑™ ´!
OrdinalIgnoreCase∑∑´ º
)∑∑º Ω
.∑∑Ω æ
ToArray∑∑æ ≈
(∑∑≈ ∆
)∑∑∆ «
is∑∑»  
{∑∑À Ã
Length∑∑Õ ”
:∑∑” ‘
>∑∑’ ÷
$num∑∑◊ ÿ
}∑∑Ÿ ⁄
list∑∑€ ﬂ
?∑∑‡ ·
string∑∑‚ Ë
.∑∑Ë È
Join∑∑È Ì
(∑∑Ì Ó
$str∑∑Ó Ú
,∑∑Ú Û
list∑∑Ù ¯
)∑∑¯ ˘
:∑∑˙ ˚
null∑∑¸ Ä
;∑∑Ä Å
private
∏∏ 
static
∏∏ 
object
∏∏ 
	ClientDto
∏∏ #
(
∏∏# $
Client
∏∏$ *
x
∏∏+ ,
)
∏∏, -
=>
∏∏. 0
new
∏∏1 4
{
∏∏5 6
id
∏∏7 9
=
∏∏: ;
x
∏∏< =
.
∏∏= >
Id
∏∏> @
,
∏∏@ A
companyName
∏∏B M
=
∏∏N O
x
∏∏P Q
.
∏∏Q R
CompanyName
∏∏R ]
,
∏∏] ^
contactName
∏∏_ j
=
∏∏k l
x
∏∏m n
.
∏∏n o
ContactName
∏∏o z
,
∏∏z {
email∏∏| Å
=∏∏Ç É
x∏∏Ñ Ö
.∏∏Ö Ü
Email∏∏Ü ã
,∏∏ã å
phone∏∏ç í
=∏∏ì î
x∏∏ï ñ
.∏∏ñ ó
Phone∏∏ó ú
,∏∏ú ù!
preferredLanguage∏∏û Ø
=∏∏∞ ±
x∏∏≤ ≥
.∏∏≥ ¥!
PreferredLanguage∏∏¥ ≈
,∏∏≈ ∆
isActive∏∏« œ
=∏∏– —
x∏∏“ ”
.∏∏” ‘
IsActive∏∏‘ ‹
,∏∏‹ ›#
requiresTaxDocument∏∏ﬁ Ò
=∏∏Ú Û
x∏∏Ù ı
.∏∏ı ˆ#
RequiresTaxDocument∏∏ˆ â
}∏∏ä ã
;∏∏ã å
private
ππ 
static
ππ 
object
ππ 

ProjectDto
ππ $
(
ππ$ %
Project
ππ% ,
x
ππ- .
)
ππ. /
=>
ππ0 2
new
ππ3 6
{
ππ7 8
id
ππ9 ;
=
ππ< =
x
ππ> ?
.
ππ? @
Id
ππ@ B
,
ππB C
clientId
ππD L
=
ππM N
x
ππO P
.
ππP Q
ClientId
ππQ Y
,
ππY Z
name
ππ[ _
=
ππ` a
x
ππb c
.
ππc d
Name
ππd h
,
ππh i
slug
ππj n
=
ππo p
x
ππq r
.
ππr s
Slug
ππs w
,
ππw x
repositoriesππy Ö
=ππÜ á
xππà â
.ππâ ä
Repositoriesππä ñ
.ππñ ó!
OrderByDescendingππó ®
(ππ® ©
rππ© ™
=>ππ´ ≠
rππÆ Ø
.ππØ ∞
	IsDefaultππ∞ π
)πππ ∫
.ππ∫ ª
ThenByππª ¡
(ππ¡ ¬
rππ¬ √
=>ππƒ ∆
rππ« »
.ππ» …
Nameππ… Õ
)ππÕ Œ
.ππŒ œ
Selectππœ ’
(ππ’ ÷
rππ÷ ◊
=>ππÿ ⁄
newππ€ ﬁ
{ππﬂ ‡
idππ· „
=ππ‰ Â
rππÊ Á
.ππÁ Ë
IdππË Í
,ππÍ Î
ownerππÏ Ò
=ππÚ Û
rππÙ ı
.ππı ˆ
Ownerππˆ ˚
,ππ˚ ¸
nameππ˝ Å
=ππÇ É
rππÑ Ö
.ππÖ Ü
NameππÜ ä
,ππä ã
labelππå ë
=ππí ì
rππî ï
.ππï ñ
Labelππñ õ
,ππõ ú
	isDefaultππù ¶
=ππß ®
rππ© ™
.ππ™ ´
	IsDefaultππ´ ¥
}ππµ ∂
)ππ∂ ∑
}ππ∏ π
;πππ ∫
private
∫∫ 
static
∫∫ 
object
∫∫ 

ProductDto
∫∫ $
(
∫∫$ %
Product
∫∫% ,
x
∫∫- .
)
∫∫. /
=>
∫∫0 2
new
∫∫3 6
{
∫∫7 8
id
∫∫9 ;
=
∫∫< =
x
∫∫> ?
.
∫∫? @
Id
∫∫@ B
,
∫∫B C
type
∫∫D H
=
∫∫I J
x
∫∫K L
.
∫∫L M
Type
∫∫M Q
.
∫∫Q R
ToString
∫∫R Z
(
∫∫Z [
)
∫∫[ \
,
∫∫\ ]
name
∫∫^ b
=
∫∫c d
x
∫∫e f
.
∫∫f g
Name
∫∫g k
,
∫∫k l
billingCycle
∫∫m y
=
∫∫z {
x
∫∫| }
.
∫∫} ~
BillingCycle∫∫~ ä
.∫∫ä ã
ToString∫∫ã ì
(∫∫ì î
)∫∫î ï
,∫∫ï ñ
	basePrice∫∫ó †
=∫∫° ¢
x∫∫£ §
.∫∫§ •
	BasePrice∫∫• Æ
,∫∫Æ Ø
currency∫∫∞ ∏
=∫∫π ∫
x∫∫ª º
.∫∫º Ω
Currency∫∫Ω ≈
,∫∫≈ ∆
description∫∫« “
=∫∫” ‘
x∫∫’ ÷
.∫∫÷ ◊
Description∫∫◊ ‚
,∫∫‚ „
isActive∫∫‰ Ï
=∫∫Ì Ó
x∫∫Ô 
.∫∫ Ò
IsActive∫∫Ò ˘
,∫∫˘ ˙
taxDocumentType∫∫˚ ä
=∫∫ã å
x∫∫ç é
.∫∫é è
TaxDocumentType∫∫è û
.∫∫û ü
ToString∫∫ü ß
(∫∫ß ®
)∫∫® ©
,∫∫© ™
category∫∫´ ≥
=∫∫¥ µ
x∫∫∂ ∑
.∫∫∑ ∏
Category∫∫∏ ¿
,∫∫¿ ¡
tags∫∫¬ ∆
=∫∫« »
x∫∫…  
.∫∫  À
Tags∫∫À œ
,∫∫œ –
allowsTickets∫∫— ﬁ
=∫∫ﬂ ‡
x∫∫· ‚
.∫∫‚ „
AllowsTickets∫∫„ 
}∫∫Ò Ú
;∫∫Ú Û
private
ªª 
async
ªª 
Task
ªª 
<
ªª 
object
ªª 
>
ªª #
ClientProductDtoAsync
ªª 4
(
ªª4 5
ClientProduct
ªª5 B
x
ªªC D
,
ªªD E
CancellationToken
ªªF W
ct
ªªX Z
)
ªªZ [
=>
ªª\ ^
ClientProductDto
ªª_ o
(
ªªo p
x
ªªp q
,
ªªq r
x
ªªs t
.
ªªt u
Product
ªªu |
is
ªª} 
nullªªÄ Ñ
?ªªÖ Ü
$numªªá â
:ªªä ã
awaitªªå ë
dbªªí î
.ªªî ï
IgvRateForAsyncªªï §
(ªª§ •
xªª• ¶
.ªª¶ ß
ClientIdªªß Ø
,ªªØ ∞
xªª± ≤
.ªª≤ ≥
Productªª≥ ∫
,ªª∫ ª
ctªªº æ
)ªªæ ø
)ªªø ¿
;ªª¿ ¡
private
ΩΩ 
static
ΩΩ 
object
ΩΩ 
ClientProductDto
ΩΩ *
(
ΩΩ* +
ClientProduct
ΩΩ+ 8
x
ΩΩ9 :
,
ΩΩ: ;
decimal
ΩΩ< C
igvRate
ΩΩD K
)
ΩΩK L
=>
ΩΩM O
new
ΩΩP S
{
ΩΩT U
igvRate
ΩΩV ]
,
ΩΩ] ^
nextChargeTotal
ΩΩ_ n
=
ΩΩo p
x
ΩΩq r
.
ΩΩr s
NextChargeTotalΩΩs Ç
(ΩΩÇ É
igvRateΩΩÉ ä
)ΩΩä ã
,ΩΩã å
idΩΩç è
=ΩΩê ë
xΩΩí ì
.ΩΩì î
IdΩΩî ñ
,ΩΩñ ó
clientIdΩΩò †
=ΩΩ° ¢
xΩΩ£ §
.ΩΩ§ •
ClientIdΩΩ• ≠
,ΩΩ≠ Æ
	projectIdΩΩØ ∏
=ΩΩπ ∫
xΩΩª º
.ΩΩº Ω
	ProjectIdΩΩΩ ∆
,ΩΩ∆ «
projectNameΩΩ» ”
=ΩΩ‘ ’
xΩΩ÷ ◊
.ΩΩ◊ ÿ
ProjectΩΩÿ ﬂ
?ΩΩﬂ ‡
.ΩΩ‡ ·
NameΩΩ· Â
,ΩΩÂ Ê
	productIdΩΩÁ 
=ΩΩÒ Ú
xΩΩÛ Ù
.ΩΩÙ ı
	ProductIdΩΩı ˛
,ΩΩ˛ ˇ
productNameΩΩÄ ã
=ΩΩå ç
xΩΩé è
.ΩΩè ê
ProductΩΩê ó
?ΩΩó ò
.ΩΩò ô
NameΩΩô ù
,ΩΩù û
productTypeΩΩü ™
=ΩΩ´ ¨
xΩΩ≠ Æ
.ΩΩÆ Ø
ProductΩΩØ ∂
?ΩΩ∂ ∑
.ΩΩ∑ ∏
TypeΩΩ∏ º
.ΩΩº Ω
ToStringΩΩΩ ≈
(ΩΩ≈ ∆
)ΩΩ∆ «
,ΩΩ« »
currencyΩΩ… —
=ΩΩ“ ”
xΩΩ‘ ’
.ΩΩ’ ÷
ProductΩΩ÷ ›
?ΩΩ› ﬁ
.ΩΩﬁ ﬂ
CurrencyΩΩﬂ Á
??ΩΩË Í
$strΩΩÎ 
,ΩΩ Ò
billingCycleΩΩÚ ˛
=ΩΩˇ Ä
xΩΩÅ Ç
.ΩΩÇ É
BillingCycleΩΩÉ è
.ΩΩè ê
ToStringΩΩê ò
(ΩΩò ô
)ΩΩô ö
,ΩΩö õ
isManualBillingΩΩú ´
=ΩΩ¨ ≠
xΩΩÆ Ø
.ΩΩØ ∞
IsManualBillingΩΩ∞ ø
,ΩΩø ¿
statusΩΩ¡ «
=ΩΩ» …
xΩΩ  À
.ΩΩÀ Ã
StatusΩΩÃ “
.ΩΩ“ ”
ToStringΩΩ” €
(ΩΩ€ ‹
)ΩΩ‹ ›
,ΩΩ› ﬁ
priceΩΩﬂ ‰
=ΩΩÂ Ê
xΩΩÁ Ë
.ΩΩË È
PriceΩΩÈ Ó
,ΩΩÓ Ô
	listPriceΩΩ ˘
=ΩΩ˙ ˚
xΩΩ¸ ˝
.ΩΩ˝ ˛
	ListPriceΩΩ˛ á
(ΩΩá à
)ΩΩà â
,ΩΩâ ä
discountΩΩã ì
=ΩΩî ï
xΩΩñ ó
.ΩΩó ò
DiscountΩΩò †
,ΩΩ† °
discountEndsAtΩΩ¢ ∞
=ΩΩ± ≤
xΩΩ≥ ¥
.ΩΩ¥ µ
DiscountEndsAtΩΩµ √
==ΩΩƒ ∆$
ClientProductPricingΩΩ« €
.ΩΩ€ ‹
NoEndΩΩ‹ ·
?ΩΩ‚ „
nullΩΩ‰ Ë
:ΩΩÈ Í
xΩΩÎ Ï
.ΩΩÏ Ì
DiscountEndsAtΩΩÌ ˚
,ΩΩ˚ ¸
currentPriceΩΩ˝ â
=ΩΩä ã
xΩΩå ç
.ΩΩç é
CurrentPriceΩΩé ö
(ΩΩö õ
DateTimeΩΩõ £
.ΩΩ£ §
UtcNowΩΩ§ ™
)ΩΩ™ ´
,ΩΩ´ ¨
nextChargePriceΩΩ≠ º
=ΩΩΩ æ
xΩΩø ¿
.ΩΩ¿ ¡
NextChargePriceΩΩ¡ –
(ΩΩ– —
)ΩΩ— “
,ΩΩ“ ”

domainNameΩΩ‘ ﬁ
=ΩΩﬂ ‡
xΩΩ· ‚
.ΩΩ‚ „

DomainNameΩΩ„ Ì
,ΩΩÌ Ó"
priceLabelOverrideΩΩÔ Å
=ΩΩÇ É
xΩΩÑ Ö
.ΩΩÖ Ü"
PriceLabelOverrideΩΩÜ ò
,ΩΩò ô
renewsAtΩΩö ¢
=ΩΩ£ §
xΩΩ• ¶
.ΩΩ¶ ß
RenewsAtΩΩß Ø
,ΩΩØ ∞
nextChargeAtΩΩ± Ω
=ΩΩæ ø
xΩΩ¿ ¡
.ΩΩ¡ ¬
NextChargeAtΩΩ¬ Œ
}ΩΩœ –
;ΩΩ– —
private
øø 
static
øø 
object
øø 
TaxDocumentDto
øø (
(
øø( )
TaxDocument
øø) 4
x
øø5 6
,
øø6 7
decimal
øø8 ?
	rateToPen
øø@ I
,
øøI J
IEnumerable
øøK V
<
øøV W
TaxDocumentLine
øøW f
>
øøf g
lines
øøh m
,
øøm n
string
øøo u
?
øøu v
paymentMethodøøw Ñ
)øøÑ Ö
=>øøÜ à
newøøâ å
{øøç é
paymentMethodøøè ú
,øøú ù
linesøøû £
=øø§ •
linesøø¶ ´
.øø´ ¨
Selectøø¨ ≤
(øø≤ ≥
løø≥ ¥
=>øøµ ∑
newøø∏ ª
{øøº Ω
clientProductIdøøæ Õ
=øøŒ œ
løø– —
.øø— “
ClientProductIdøø“ ·
,øø· ‚
descriptionøø„ Ó
=øøÔ 
løøÒ Ú
.øøÚ Û
DescriptionøøÛ ˛
,øø˛ ˇ
amountøøÄ Ü
=øøá à
løøâ ä
.øøä ã
Amountøøã ë
}øøí ì
)øøì î
.øøî ï
ToListøøï õ
(øøõ ú
)øøú ù
,øøù û
idøøü °
=øø¢ £
xøø§ •
.øø• ¶
Idøø¶ ®
,øø® ©$
paymentTransactionIdøø™ æ
=øøø ¿
xøø¡ ¬
.øø¬ √$
PaymentTransactionIdøø√ ◊
,øø◊ ÿ
clientIdøøŸ ·
=øø‚ „
xøø‰ Â
.øøÂ Ê
ClientIdøøÊ Ó
,øøÓ Ô
typeøø Ù
=øøı ˆ
xøø˜ ¯
.øø¯ ˘
Typeøø˘ ˝
.øø˝ ˛
ToStringøø˛ Ü
(øøÜ á
)øøá à
,øøà â
seriesøøä ê
=øøë í
xøøì î
.øøî ï
Seriesøøï õ
,øøõ ú
numberøøù £
=øø§ •
xøø¶ ß
.øøß ®
Numberøø® Æ
,øøÆ Ø
	issueDateøø∞ π
=øø∫ ª
xøøº Ω
.øøΩ æ
	IssueDateøøæ «
,øø« »
currencyøø… —
=øø“ ”
xøø‘ ’
.øø’ ÷
Currencyøø÷ ﬁ
,øøﬁ ﬂ

baseAmountøø‡ Í
=øøÎ Ï
xøøÌ Ó
.øøÓ Ô

BaseAmountøøÔ ˘
,øø˘ ˙
	igvAmountøø˚ Ñ
=øøÖ Ü
xøøá à
.øøà â
	IgvAmountøøâ í
,øøí ì
totalAmountøøî ü
=øø† °
xøø¢ £
.øø£ §
TotalAmountøø§ Ø
,øøØ ∞
notesøø± ∂
=øø∑ ∏
xøøπ ∫
.øø∫ ª
Notesøøª ¿
,øø¿ ¡
retentionAmountøø¬ —
=øø“ ”
xøø‘ ’
.øø’ ÷
RetentionAmountøø÷ Â
,øøÂ Ê
exchangeRate
¿¿ 
=
¿¿ 
x
¿¿ 
.
¿¿ 
Currency
¿¿ !
==
¿¿" $
$str
¿¿% *
?
¿¿+ ,
$num
¿¿- /
:
¿¿0 1
Math
¿¿2 6
.
¿¿6 7
Round
¿¿7 <
(
¿¿< =
	rateToPen
¿¿= F
,
¿¿F G
$num
¿¿H I
)
¿¿I J
,
¿¿J K
basePen
¿¿L S
=
¿¿T U
Math
¿¿V Z
.
¿¿Z [
Round
¿¿[ `
(
¿¿` a
x
¿¿a b
.
¿¿b c

BaseAmount
¿¿c m
*
¿¿n o
	rateToPen
¿¿p y
,
¿¿y z
$num
¿¿{ |
)
¿¿| }
,
¿¿} ~
igvPen¿¿ Ö
=¿¿Ü á
Math¿¿à å
.¿¿å ç
Round¿¿ç í
(¿¿í ì
x¿¿ì î
.¿¿î ï
	IgvAmount¿¿ï û
*¿¿ü †
	rateToPen¿¿° ™
,¿¿™ ´
$num¿¿¨ ≠
)¿¿≠ Æ
,¿¿Æ Ø
totalPen¿¿∞ ∏
=¿¿π ∫
Math¿¿ª ø
.¿¿ø ¿
Round¿¿¿ ≈
(¿¿≈ ∆
x¿¿∆ «
.¿¿« »
TotalAmount¿¿» ”
*¿¿‘ ’
	rateToPen¿¿÷ ﬂ
,¿¿ﬂ ‡
$num¿¿· ‚
)¿¿‚ „
}¿¿‰ Â
;¿¿Â Ê
private
¬¬ 
static
¬¬ 
void
¬¬ !
ApplyForeignService
¬¬ +
(
¬¬+ ,
Expense
¬¬, 3
expense
¬¬4 ;
,
¬¬; <
bool
¬¬= A
foreign
¬¬B I
,
¬¬I J
string
¬¬K Q
?
¬¬Q R
name
¬¬S W
,
¬¬W X
string
¬¬Y _
?
¬¬_ `
country
¬¬a h
)
¬¬h i
{
√√ 
expense
ƒƒ 
.
ƒƒ #
IsNonDomiciledService
ƒƒ %
=
ƒƒ& '
foreign
ƒƒ( /
;
ƒƒ/ 0
(
≈≈ 	
expense
≈≈	 
.
≈≈ !
ForeignSupplierName
≈≈ $
,
≈≈$ %
expense
≈≈& -
.
≈≈- .$
ForeignSupplierCountry
≈≈. D
)
≈≈D E
=
≈≈F G
foreign
≈≈H O
?
≈≈P Q
(
≈≈R S
EmptyToNull
≈≈S ^
(
≈≈^ _
name
≈≈_ c
)
≈≈c d
,
≈≈d e
EmptyToNull
≈≈f q
(
≈≈q r
country
≈≈r y
)
≈≈y z
)
≈≈z {
:
≈≈| }
(
≈≈~ 
null≈≈ É
,≈≈É Ñ
null≈≈Ö â
)≈≈â ä
;≈≈ä ã
if
∆∆ 

(
∆∆ 
!
∆∆ 
foreign
∆∆ 
)
∆∆ 
(
∆∆ 
expense
∆∆ 
.
∆∆ 
Form1662PaidAt
∆∆ -
,
∆∆- .
expense
∆∆/ 6
.
∆∆6 7
Form1662Number
∆∆7 E
)
∆∆E F
=
∆∆G H
(
∆∆I J
null
∆∆J N
,
∆∆N O
null
∆∆P T
)
∆∆T U
;
∆∆U V
}
«« 
private
…… 
static
…… 
object
…… 

ExpenseDto
…… $
(
……$ %
Expense
……% ,
x
……- .
)
……. /
=>
……0 2
new
……3 6
{
……7 8
id
……9 ;
=
……< =
x
……> ?
.
……? @
Id
……@ B
,
……B C
description
……D O
=
……P Q
x
……R S
.
……S T
Description
……T _
,
……_ `

categoryId
……a k
=
……l m
x
……n o
.
……o p

CategoryId
……p z
,
……z {
categoryName……| à
=……â ä
x……ã å
.……å ç
Category……ç ï
?……ï ñ
.……ñ ó
Name……ó õ
??……ú û
$str……ü °
,……° ¢
type……£ ß
=……® ©
x……™ ´
.……´ ¨
Type……¨ ∞
.……∞ ±
ToString……± π
(……π ∫
)……∫ ª
,……ª º
amount……Ω √
=……ƒ ≈
x……∆ «
.……« »
Amount……» Œ
,……Œ œ
currency……– ÿ
=……Ÿ ⁄
x……€ ‹
.……‹ ›
Currency……› Â
,……Â Ê
	amountPen……Á 
=……Ò Ú
x……Û Ù
.……Ù ı
	AmountPen……ı ˛
,……˛ ˇ
date……Ä Ñ
=……Ö Ü
x……á à
.……à â
Date……â ç
,……ç é
	recurring……è ò
=……ô ö
x……õ ú
.……ú ù
	Recurring……ù ¶
,……¶ ß
recurrenceCycle……® ∑
=……∏ π
x……∫ ª
.……ª º
RecurrenceCycle……º À
?……À Ã
.……Ã Õ
ToString……Õ ’
(……’ ÷
)……÷ ◊
,……◊ ÿ 
recurrenceEndsAt……Ÿ È
=……Í Î
x……Ï Ì
.……Ì Ó 
RecurrenceEndsAt……Ó ˛
,……˛ ˇ
isNonDeductible……Ä è
=……ê ë
x……í ì
.……ì î
IsNonDeductible……î £
,……£ §%
isNonDomiciledService……• ∫
=……ª º
x……Ω æ
.……æ ø%
IsNonDomiciledService……ø ‘
,……‘ ’#
foreignSupplierName……÷ È
=……Í Î
x……Ï Ì
.……Ì Ó#
ForeignSupplierName……Ó Å
,……Å Ç&
foreignSupplierCountry……É ô
=……ö õ
x……ú ù
.……ù û&
ForeignSupplierCountry……û ¥
,……¥ µ
form1662PaidAt……∂ ƒ
=……≈ ∆
x……« »
.……» …
Form1662PaidAt……… ◊
,……◊ ÿ
form1662Number……Ÿ Á
=……Ë È
x……Í Î
.……Î Ï
Form1662Number……Ï ˙
}……˚ ¸
;……¸ ˝
}   
publicÃÃ 
sealed
ÃÃ 
record
ÃÃ 
ProfileRequest
ÃÃ #
(
ÃÃ# $
string
ÃÃ$ *
Name
ÃÃ+ /
)
ÃÃ/ 0
;
ÃÃ0 1
publicÕÕ 
sealed
ÕÕ 
record
ÕÕ #
ChangePasswordRequest
ÕÕ *
(
ÕÕ* +
string
ÕÕ+ 1
CurrentPassword
ÕÕ2 A
,
ÕÕA B
string
ÕÕC I
NewPassword
ÕÕJ U
)
ÕÕU V
;
ÕÕV W
publicŒŒ 
sealed
ŒŒ 
record
ŒŒ 
InviteRequest
ŒŒ "
(
ŒŒ" #
string
ŒŒ# )
Name
ŒŒ* .
,
ŒŒ. /
string
ŒŒ0 6
Email
ŒŒ7 <
)
ŒŒ< =
;
ŒŒ= >
public–– 
sealed
–– 
record
–– 
UpdateTeamRequest
–– &
(
––& '
UserRole
––' /
?
––/ 0
Role
––1 5
,
––5 6
bool
––7 ;
?
––; <
IsActive
––= E
,
––E F
string
––G M
?
––M N
Area
––O S
=
––T U
null
––V Z
,
––Z [
string
––\ b
?
––b c
JobTitle
––d l
=
––m n
null
––o s
,
––s t
Guid
––u y
?
––y z
	ManagerId––{ Ñ
=––Ö Ü
null––á ã
)––ã å
;––å ç
public—— 
sealed
—— 
record
—— 
ClientRequest
—— "
(
——" #
string
——# )
CompanyName
——* 5
,
——5 6
string
——7 =
ContactName
——> I
,
——I J
string
——K Q
Email
——R W
,
——W X
string
——Y _
?
——_ `
Phone
——a f
,
——f g
string
——h n 
PreferredLanguage——o Ä
,——Ä Å
bool——Ç Ü#
RequiresTaxDocument——á ö
=——õ ú
false——ù ¢
)——¢ £
;——£ §
public““ 
sealed
““ 
record
““  
ClientPatchRequest
““ '
(
““' (
string
““( .
?
““. /
CompanyName
““0 ;
,
““; <
string
““= C
?
““C D
ContactName
““E P
,
““P Q
string
““R X
?
““X Y
Email
““Z _
,
““_ `
string
““a g
?
““g h
Phone
““i n
,
““n o
string
““p v
?
““v w 
PreferredLanguage““x â
,““â ä
bool““ã è
?““è ê
IsActive““ë ô
,““ô ö
bool““õ ü
?““ü †#
RequiresTaxDocument““° ¥
=““µ ∂
null““∑ ª
)““ª º
;““º Ω
public”” 
sealed
”” 
record
”” 
ProductRequest
”” #
(
””# $
[
””$ %
property
””% -
:
””- .
JsonRequired
””/ ;
]
””; <
ProductType
””= H
Type
””I M
,
””M N
string
””O U
Name
””V Z
,
””Z [
[
””\ ]
property
””] e
:
””e f
JsonRequired
””g s
]
””s t
BillingCycle””u Å
BillingCycle””Ç é
,””é è
decimal””ê ó
?””ó ò
	BasePrice””ô ¢
,””¢ £
string””§ ™
Currency””´ ≥
,””≥ ¥
string””µ ª
?””ª º
Description””Ω »
,””» …
[””  À
property””À ”
:””” ‘
JsonRequired””’ ·
]””· ‚
bool””„ Á
IsActive””Ë 
,”” Ò
TaxDocumentType””Ú Å
TaxDocumentType””Ç ë
=””í ì
TaxDocumentType””î £
.””£ §
Factura””§ ´
,””´ ¨
string””≠ ≥
?””≥ ¥
Category””µ Ω
=””æ ø
null””¿ ƒ
,””ƒ ≈
string””∆ Ã
?””Ã Õ
Tags””Œ “
=””” ‘
null””’ Ÿ
,””Ÿ ⁄
bool””€ ﬂ
AllowsTickets””‡ Ì
=””Ó Ô
false”” ı
)””ı ˆ
;””ˆ ˜
public‘‘ 
sealed
‘‘ 
record
‘‘ !
ProductPatchRequest
‘‘ (
(
‘‘( )
ProductType
‘‘) 4
?
‘‘4 5
Type
‘‘6 :
,
‘‘: ;
string
‘‘< B
?
‘‘B C
Name
‘‘D H
,
‘‘H I
BillingCycle
‘‘J V
?
‘‘V W
BillingCycle
‘‘X d
,
‘‘d e
decimal
‘‘f m
?
‘‘m n
	BasePrice
‘‘o x
,
‘‘x y
string‘‘z Ä
?‘‘Ä Å
Currency‘‘Ç ä
,‘‘ä ã
string‘‘å í
?‘‘í ì
Description‘‘î ü
,‘‘ü †
bool‘‘° •
?‘‘• ¶
IsActive‘‘ß Ø
,‘‘Ø ∞
TaxDocumentType‘‘± ¿
?‘‘¿ ¡
TaxDocumentType‘‘¬ —
=‘‘“ ”
null‘‘‘ ÿ
,‘‘ÿ Ÿ
string‘‘⁄ ‡
?‘‘‡ ·
Category‘‘‚ Í
=‘‘Î Ï
null‘‘Ì Ò
,‘‘Ò Ú
string‘‘Û ˘
?‘‘˘ ˙
Tags‘‘˚ ˇ
=‘‘Ä Å
null‘‘Ç Ü
,‘‘Ü á
bool‘‘à å
?‘‘å ç
AllowsTickets‘‘é õ
=‘‘ú ù
null‘‘û ¢
)‘‘¢ £
;‘‘£ §
public’’ 
sealed
’’ 
record
’’ "
AssignProductRequest
’’ )
(
’’) *
[
’’* +
property
’’+ 3
:
’’3 4
JsonRequired
’’5 A
]
’’A B
Guid
’’C G
	ProductId
’’H Q
,
’’Q R
[
’’S T
property
’’T \
:
’’\ ]
JsonRequired
’’^ j
]
’’j k
Guid
’’l p
	ProjectId
’’q z
,
’’z {
[
’’| }
property’’} Ö
:’’Ö Ü
JsonRequired’’á ì
]’’ì î
BillingCycle’’ï °
BillingCycle’’¢ Æ
,’’Æ Ø
string’’∞ ∂
BillingMode’’∑ ¬
,’’¬ √
decimal’’ƒ À
?’’À Ã
Price’’Õ “
,’’“ ”
string’’‘ ⁄
?’’⁄ €

DomainName’’‹ Ê
,’’Ê Á
string’’Ë Ó
?’’Ó Ô"
PriceLabelOverride’’ Ç
,’’Ç É
DateOnly’’Ñ å
?’’å ç
RenewsAt’’é ñ
=’’ó ò
null’’ô ù
,’’ù û
DateOnly’’ü ß
?’’ß ®
NextChargeAt’’© µ
=’’∂ ∑
null’’∏ º
,’’º Ω
decimal’’æ ≈
?’’≈ ∆
Discount’’« œ
=’’– —
null’’“ ÷
)’’÷ ◊
;’’◊ ÿ
public÷÷ 
sealed
÷÷ 
record
÷÷ $
TransferPaymentRequest
÷÷ +
(
÷÷+ ,
decimal
÷÷, 3
?
÷÷3 4
Amount
÷÷5 ;
,
÷÷; <
DateOnly
÷÷= E
?
÷÷E F
PaidAt
÷÷G M
,
÷÷M N
string
÷÷O U
?
÷÷U V
	Reference
÷÷W `
,
÷÷` a
int
÷÷b e
Years
÷÷f k
=
÷÷l m
$num
÷÷n o
)
÷÷o p
;
÷÷p q
public◊◊ 
sealed
◊◊ 
record
◊◊ '
ClientProductDatesRequest
◊◊ .
(
◊◊. /
DateOnly
◊◊/ 7
?
◊◊7 8
RenewsAt
◊◊9 A
,
◊◊A B
DateOnly
◊◊C K
?
◊◊K L
NextChargeAt
◊◊M Y
)
◊◊Y Z
;
◊◊Z [
publicÿÿ 
sealed
ÿÿ 
record
ÿÿ '
ClientProductPatchRequest
ÿÿ .
(
ÿÿ. /
decimal
ÿÿ/ 6
?
ÿÿ6 7
Price
ÿÿ8 =
,
ÿÿ= >!
ClientProductStatus
ÿÿ? R
?
ÿÿR S
Status
ÿÿT Z
,
ÿÿZ [
BillingCycle
ÿÿ\ h
?
ÿÿh i
BillingCycle
ÿÿj v
,
ÿÿv w
bool
ÿÿx |
?
ÿÿ| }
IsManualBillingÿÿ~ ç
,ÿÿç é
stringÿÿè ï
?ÿÿï ñ

DomainNameÿÿó °
,ÿÿ° ¢
stringÿÿ£ ©
?ÿÿ© ™"
PriceLabelOverrideÿÿ´ Ω
,ÿÿΩ æ
decimalÿÿø ∆
?ÿÿ∆ «
Discountÿÿ» –
=ÿÿ— “
nullÿÿ” ◊
,ÿÿ◊ ÿ
GuidÿÿŸ ›
?ÿÿ› ﬁ
	ProjectIdÿÿﬂ Ë
=ÿÿÈ Í
nullÿÿÎ Ô
)ÿÿÔ 
;ÿÿ Ò
publicŸŸ 
sealed
ŸŸ 
record
ŸŸ 
ImportError
ŸŸ  
(
ŸŸ  !
int
ŸŸ! $
Row
ŸŸ% (
,
ŸŸ( )
string
ŸŸ* 0
Reason
ŸŸ1 7
)
ŸŸ7 8
;
ŸŸ8 9
public€€ 
sealed
€€ 
record
€€ 
TemplateColumn
€€ #
(
€€# $
string
€€$ *
Name
€€+ /
,
€€/ 0
bool
€€1 5
Required
€€6 >
,
€€> ?
string
€€@ F
Accepted
€€G O
,
€€O P
string
€€Q W
[
€€W X
]
€€X Y
?
€€Y Z
Options
€€[ b
=
€€c d
null
€€e i
)
€€i j
;
€€j k
public‹‹ 
sealed
‹‹ 
record
‹‹ 
ClientAccess
‹‹ !
(
‹‹! "
string
‹‹" (

ClientName
‹‹) 3
,
‹‹3 4
string
‹‹5 ;
Email
‹‹< A
,
‹‹A B
string
‹‹C I
TemporaryPassword
‹‹J [
,
‹‹[ \
bool
‹‹] a
	EmailSent
‹‹b k
=
‹‹l m
false
‹‹n s
)
‹‹s t
;
‹‹t u
public›› 
sealed
›› 
record
›› 
ProjectRequest
›› #
(
››# $
string
››$ *
?
››* +
Name
››, 0
,
››0 1
string
››2 8
?
››8 9
Slug
››: >
,
››> ?
string
››@ F
?
››F G
GithubRepoOwner
››H W
,
››W X
string
››Y _
?
››_ `
GithubRepoName
››a o
)
››o p
;
››p q
publicﬁﬁ 
sealed
ﬁﬁ 
record
ﬁﬁ 
RepositoryRequest
ﬁﬁ &
(
ﬁﬁ& '
string
ﬁﬁ' -
?
ﬁﬁ- .
Owner
ﬁﬁ/ 4
,
ﬁﬁ4 5
string
ﬁﬁ6 <
?
ﬁﬁ< =
Name
ﬁﬁ> B
,
ﬁﬁB C
string
ﬁﬁD J
?
ﬁﬁJ K
Label
ﬁﬁL Q
=
ﬁﬁR S
null
ﬁﬁT X
,
ﬁﬁX Y
bool
ﬁﬁZ ^
?
ﬁﬁ^ _
	IsDefault
ﬁﬁ` i
=
ﬁﬁj k
null
ﬁﬁl p
)
ﬁﬁp q
;
ﬁﬁq r
publicﬂﬂ 
sealed
ﬂﬂ 
record
ﬂﬂ  
TaxSettingsRequest
ﬂﬂ '
(
ﬂﬂ' (
decimal
ﬂﬂ( /
?
ﬂﬂ/ 0
IgvRate
ﬂﬂ1 8
,
ﬂﬂ8 9
decimal
ﬂﬂ: A
?
ﬂﬂA B
	RentaRate
ﬂﬂC L
,
ﬂﬂL M
string
ﬂﬂN T
?
ﬂﬂT U
FacturaSeries
ﬂﬂV c
=
ﬂﬂd e
null
ﬂﬂf j
,
ﬂﬂj k
int
ﬂﬂl o
?
ﬂﬂo p 
FacturaNextNumberﬂﬂq Ç
=ﬂﬂÉ Ñ
nullﬂﬂÖ â
,ﬂﬂâ ä
stringﬂﬂã ë
?ﬂﬂë í
ReciboSeriesﬂﬂì ü
=ﬂﬂ† °
nullﬂﬂ¢ ¶
,ﬂﬂ¶ ß
intﬂﬂ® ´
?ﬂﬂ´ ¨ 
ReciboNextNumberﬂﬂ≠ Ω
=ﬂﬂæ ø
nullﬂﬂ¿ ƒ
,ﬂﬂƒ ≈
stringﬂﬂ∆ Ã
?ﬂﬂÃ Õ
RucﬂﬂŒ —
=ﬂﬂ“ ”
nullﬂﬂ‘ ÿ
,ﬂﬂÿ Ÿ
boolﬂﬂ⁄ ﬁ
?ﬂﬂﬁ ﬂ
IsGoodTaxpayerﬂﬂ‡ Ó
=ﬂﬂÔ 
nullﬂﬂÒ ı
,ﬂﬂı ˆ
boolﬂﬂ˜ ˚
?ﬂﬂ˚ ¸
Use1662AsCreditﬂﬂ˝ å
=ﬂﬂç é
nullﬂﬂè ì
)ﬂﬂì î
;ﬂﬂî ï
public·· 
sealed
·· 
record
··  
TaxDocumentRequest
·· '
(
··' (
Guid
··( ,
?
··, -
ClientProductId
··. =
,
··= >
[
··? @
property
··@ H
:
··H I
JsonRequired
··J V
]
··V W
DateOnly
··X `
	IssueDate
··a j
,
··j k
string
··l r
Currency
··s {
,
··{ |
decimal··} Ñ
?··Ñ Ö
TotalAmount··Ü ë
,··ë í
string··ì ô
?··ô ö
Notes··õ †
,··† °
decimal··¢ ©
?··© ™
RetentionAmount··´ ∫
=··ª º
null··Ω ¡
,··¡ ¬
IReadOnlyList··√ –
<··– —&
TaxDocumentItemRequest··— Á
>··Á Ë
?··Ë È
Items··Í Ô
=·· Ò
null··Ú ˆ
)··ˆ ˜
;··˜ ¯
public‚‚ 
sealed
‚‚ 
record
‚‚ $
TaxDocumentItemRequest
‚‚ +
(
‚‚+ ,
Guid
‚‚, 0
ClientProductId
‚‚1 @
,
‚‚@ A
decimal
‚‚B I
Amount
‚‚J P
)
‚‚P Q
;
‚‚Q R
public„„ 
sealed
„„ 
record
„„ '
ReverseTaxDocumentRequest
„„ .
(
„„. /
string
„„/ 5
?
„„5 6
Reason
„„7 =
,
„„= >
[
„„? @
property
„„@ H
:
„„H I
JsonRequired
„„J V
]
„„V W
bool
„„X \
	NotIssued
„„] f
)
„„f g
;
„„g h
public‰‰ 
sealed
‰‰ 
record
‰‰ 
ExpenseRequest
‰‰ #
(
‰‰# $
string
‰‰$ *
Description
‰‰+ 6
,
‰‰6 7
[
‰‰8 9
property
‰‰9 A
:
‰‰A B
JsonRequired
‰‰C O
]
‰‰O P
Guid
‰‰Q U

CategoryId
‰‰V `
,
‰‰` a
[
‰‰b c
property
‰‰c k
:
‰‰k l
JsonRequired
‰‰m y
]
‰‰y z
ExpenseType‰‰{ Ü
Type‰‰á ã
,‰‰ã å
[‰‰ç é
property‰‰é ñ
:‰‰ñ ó
JsonRequired‰‰ò §
]‰‰§ •
decimal‰‰¶ ≠
Amount‰‰Æ ¥
,‰‰¥ µ
string‰‰∂ º
Currency‰‰Ω ≈
,‰‰≈ ∆
[‰‰« »
property‰‰» –
:‰‰– —
JsonRequired‰‰“ ﬁ
]‰‰ﬁ ﬂ
DateOnly‰‰‡ Ë
Date‰‰È Ì
,‰‰Ì Ó
[‰‰Ô 
property‰‰ ¯
:‰‰¯ ˘
JsonRequired‰‰˙ Ü
]‰‰Ü á
bool‰‰à å
	Recurring‰‰ç ñ
,‰‰ñ ó
BillingCycle‰‰ò §
?‰‰§ •
RecurrenceCycle‰‰¶ µ
,‰‰µ ∂
bool‰‰∑ ª
IsNonDeductible‰‰º À
=‰‰Ã Õ
false‰‰Œ ”
,‰‰” ‘
bool‰‰’ Ÿ%
IsNonDomiciledService‰‰⁄ Ô
=‰‰ Ò
false‰‰Ú ˜
,‰‰˜ ¯
string‰‰˘ ˇ
?‰‰ˇ Ä#
ForeignSupplierName‰‰Å î
=‰‰ï ñ
null‰‰ó õ
,‰‰õ ú
string‰‰ù £
?‰‰£ §&
ForeignSupplierCountry‰‰• ª
=‰‰º Ω
null‰‰æ ¬
)‰‰¬ √
;‰‰√ ƒ
publicÂÂ 
sealed
ÂÂ 
record
ÂÂ "
EndRecurrenceRequest
ÂÂ )
(
ÂÂ) *
[
ÂÂ* +
property
ÂÂ+ 3
:
ÂÂ3 4
JsonRequired
ÂÂ5 A
]
ÂÂA B
DateOnly
ÂÂC K
EndsAt
ÂÂL R
)
ÂÂR S
;
ÂÂS T
publicÊÊ 
sealed
ÊÊ 
record
ÊÊ !
ExpensePatchRequest
ÊÊ (
(
ÊÊ( )
string
ÊÊ) /
?
ÊÊ/ 0
Description
ÊÊ1 <
,
ÊÊ< =
Guid
ÊÊ> B
?
ÊÊB C

CategoryId
ÊÊD N
,
ÊÊN O
ExpenseType
ÊÊP [
?
ÊÊ[ \
Type
ÊÊ] a
,
ÊÊa b
decimal
ÊÊc j
?
ÊÊj k
Amount
ÊÊl r
,
ÊÊr s
string
ÊÊt z
?
ÊÊz {
CurrencyÊÊ| Ñ
,ÊÊÑ Ö
DateOnlyÊÊÜ é
?ÊÊé è
DateÊÊê î
,ÊÊî ï
boolÊÊñ ö
?ÊÊö õ
	RecurringÊÊú •
,ÊÊ• ¶
BillingCycleÊÊß ≥
?ÊÊ≥ ¥
RecurrenceCycleÊÊµ ƒ
,ÊÊƒ ≈
boolÊÊ∆  
?ÊÊ  À
IsNonDeductibleÊÊÃ €
=ÊÊ‹ ›
nullÊÊﬁ ‚
,ÊÊ‚ „
boolÊÊ‰ Ë
?ÊÊË È%
IsNonDomiciledServiceÊÊÍ ˇ
=ÊÊÄ Å
nullÊÊÇ Ü
,ÊÊÜ á
stringÊÊà é
?ÊÊé è#
ForeignSupplierNameÊÊê £
=ÊÊ§ •
nullÊÊ¶ ™
,ÊÊ™ ´
stringÊÊ¨ ≤
?ÊÊ≤ ≥&
ForeignSupplierCountryÊÊ¥  
=ÊÊÀ Ã
nullÊÊÕ —
)ÊÊ— “
;ÊÊ“ ”◊
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