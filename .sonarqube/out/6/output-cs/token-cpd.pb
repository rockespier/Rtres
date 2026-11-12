Ìı
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
(# $
client$ *
.* +
Id+ -
,- .
item/ 3
.3 4
Product4 ;
.; <
TaxDocumentType< K
,K L
	LimaTodayM V
(V W
paymentW ^
.^ _
	CreatedAt_ h
)h i
,i j
paymentk r
.r s
Currencys {
,{ |
payment	} Ñ
.
Ñ Ö
Amount
Ö ã
,
ã å
payment
ç î
.
î ï
Years
ï ö
>
õ ú
$num
ù û
?
ü †
$"
° £
$str
£ ®
{
® ©
payment
© ∞
.
∞ ±
InternalCode
± Ω
}
Ω æ
$str
æ ¿
{
¿ ¡
payment
¡ »
.
» …
Years
… Œ
}
Œ œ
$str
œ ‰
"
‰ Â
:
Ê Á
$"
Ë Í
$str
Í Ô
{
Ô 
payment
 ˜
.
˜ ¯
InternalCode
¯ Ñ
}
Ñ Ö
"
Ö Ü
,
Ü á
payment
à è
.
è ê
Id
ê í
,
í ì
ct
î ñ
,
ñ ó
[
ò ô
new
ô ú
TaxDocumentLine
ù ¨
{
≠ Æ
ClientProductId
Ø æ
=
ø ¿
item
¡ ≈
.
≈ ∆
Id
∆ »
,
» …
Description
  ’
=
÷ ◊
LineDescription
ÿ Á
(
Á Ë
item
Ë Ï
)
Ï Ì
,
Ì Ó
Amount
Ô ı
=
ˆ ˜
payment
¯ ˇ
.
ˇ Ä
Amount
Ä Ü
}
á à
]
à â
)
â ä
;
ä ã
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
(++- .
Guid++. 2
clientId++3 ;
,++; <
TaxDocumentType++= L
type++M Q
,++Q R
DateOnly++S [
	issueDate++\ e
,++e f
string++g m
currency++n v
,++v w
decimal++x 
total
++Ä Ö
,
++Ö Ü
string
++á ç
?
++ç é
notes
++è î
,
++î ï
Guid
++ñ ö
?
++ö õ"
paymentTransactionId
++ú ∞
,
++∞ ±
CancellationToken
++≤ √
ct
++ƒ ∆
,
++∆ «
IReadOnlyList
++» ’
<
++’ ÷
TaxDocumentLine
++÷ Â
>
++Â Ê
?
++Ê Á
lines
++Ë Ì
=
++Ó Ô
null
++ Ù
)
++Ù ı
{,, 
for-- 
(-- 
var-- 
attempt-- 
=-- 
$num-- 
;-- 
;-- 
attempt--  '
++--' )
)--) *
{.. 	
var// 
settings// 
=// 
await//  
db//! #
.//# $
TaxSettings//$ /
./// 0
FirstOrDefaultAsync//0 C
(//C D
ct//D F
)//F G
??//H J
db//K M
.//M N
TaxSettings//N Y
.//Y Z
Add//Z ]
(//] ^
new//^ a
TaxSettings//b m
(//m n
)//n o
)//o p
.//p q
Entity//q w
;//w x
var00 
	isFactura00 
=00 
type00  
==00! #
TaxDocumentType00$ 3
.003 4
Factura004 ;
;00; <
var11 
series11 
=11 
	isFactura11 "
?11# $
settings11% -
.11- .
FacturaSeries11. ;
:11< =
settings11> F
.11F G
ReciboSeries11G S
;11S T
var44 
last44 
=44 
await44 
db44 
.44  
TaxDocuments44  ,
.44, -
Where44- 2
(442 3
x443 4
=>445 7
x448 9
.449 :
Type44: >
==44? A
type44B F
&&44G I
x44J K
.44K L
Series44L R
==44S U
series44V \
)44\ ]
.44] ^
MaxAsync44^ f
(44f g
x44g h
=>44i k
(44l m
int44m p
?44p q
)44q r
x44r s
.44s t
Number44t z
,44z {
ct44| ~
)44~ 
??
44Ä Ç
$num
44É Ñ
;
44Ñ Ö
var55 
number55 
=55 
Math55 
.55 
Max55 !
(55! "
	isFactura55" +
?55, -
settings55. 6
.556 7
FacturaNextNumber557 H
:55I J
settings55K S
.55S T
ReciboNextNumber55T d
,55d e
last55f j
+55k l
$num55m n
)55n o
;55o p
var66 

baseAmount66 
=66 
	isFactura66 &
?66' (
Math66) -
.66- .
Round66. 3
(663 4
total664 9
/66: ;
(66< =
$num66= >
+66? @
settings66A I
.66I J
IgvRate66J Q
)66Q R
,66R S
$num66T U
)66U V
:66W X
total66Y ^
;66^ _
var77 
document77 
=77 
new77 
TaxDocument77 *
{77+ ,
ClientId77- 5
=776 7
clientId778 @
,77@ A
Type77B F
=77G H
type77I M
,77M N
Series77O U
=77V W
series77X ^
,77^ _
Number77` f
=77g h
number77i o
,77o p
	IssueDate77q z
=77{ |
	issueDate	77} Ü
,
77Ü á
Currency
77à ê
=
77ë í
currency
77ì õ
,
77õ ú

BaseAmount
77ù ß
=
77® ©

baseAmount
77™ ¥
,
77¥ µ
	IgvAmount
77∂ ø
=
77¿ ¡
total
77¬ «
-
77» …

baseAmount
77  ‘
,
77‘ ’
TotalAmount
77÷ ·
=
77‚ „
total
77‰ È
,
77È Í
Notes
77Î 
=
77Ò Ú
notes
77Û ¯
,
77¯ ˘"
PaymentTransactionId
77˙ é
=
77è ê"
paymentTransactionId
77ë •
}
77¶ ß
;
77ß ®
db88 
.88 
TaxDocuments88 
.88 
Add88 
(88  
document88  (
)88( )
;88) *
var99 
docLines99 
=99 
(99 
lines99 !
??99" $
[99% &
]99& '
)99' (
.99( )
Select99) /
(99/ 0
(990 1
x991 2
,992 3
i994 5
)995 6
=>997 9
new99: =
TaxDocumentLine99> M
{99N O
TaxDocumentId99P ]
=99^ _
document99` h
.99h i
Id99i k
,99k l
ClientProductId99m |
=99} ~
x	99 Ä
.
99Ä Å
ClientProductId
99Å ê
,
99ê ë
Description
99í ù
=
99û ü
x
99† °
.
99° ¢
Description
99¢ ≠
,
99≠ Æ
Amount
99Ø µ
=
99∂ ∑
x
99∏ π
.
99π ∫
Amount
99∫ ¿
,
99¿ ¡
Order
99¬ «
=
99» …
i
99  À
}
99Ã Õ
)
99Õ Œ
.
99Œ œ
ToList
99œ ’
(
99’ ÷
)
99÷ ◊
;
99◊ ÿ
db:: 
.:: 
TaxDocumentLines:: 
.::  
AddRange::  (
(::( )
docLines::) 1
)::1 2
;::2 3
if;; 
(;; 
	isFactura;; 
);; 
settings;; #
.;;# $
FacturaNextNumber;;$ 5
=;;6 7
number;;8 >
+;;? @
$num;;A B
;;;B C
else;;D H
settings;;I Q
.;;Q R
ReciboNextNumber;;R b
=;;c d
number;;e k
+;;l m
$num;;n o
;;;o p
try<< 
{<< 
await<< 
db<< 
.<< 
SaveChangesAsync<< +
(<<+ ,
ct<<, .
)<<. /
;<</ 0
return<<1 7
document<<8 @
;<<@ A
}<<B C
catch== 
(== 
DbUpdateException== $
)==$ %
{>> 
dbAA 
.AA 
EntryAA 
(AA 
documentAA !
)AA! "
.AA" #
StateAA# (
=AA) *
EntityStateAA+ 6
.AA6 7
DetachedAA7 ?
;AA? @
foreachBB 
(BB 
varBB 
lineBB !
inBB" $
docLinesBB% -
)BB- .
dbBB/ 1
.BB1 2
EntryBB2 7
(BB7 8
lineBB8 <
)BB< =
.BB= >
StateBB> C
=BBD E
EntityStateBBF Q
.BBQ R
DetachedBBR Z
;BBZ [
awaitCC 
dbCC 
.CC 
EntryCC 
(CC 
settingsCC '
)CC' (
.CC( )
ReloadAsyncCC) 4
(CC4 5
ctCC5 7
)CC7 8
;CC8 9
ifDD 
(DD 
attemptDD 
>=DD 
MaxAttemptsDD *
)DD* +
throwDD, 1
;DD1 2
}EE 
}FF 	
}GG 
publicNN 

asyncNN 
TaskNN 
<NN %
TaxDocumentReversalResultNN /
?NN/ 0
>NN0 1
ReverseAsyncNN2 >
(NN> ?
GuidNN? C

documentIdNND N
,NNN O
stringNNP V
reasonNNW ]
,NN] ^
boolNN_ c
	notIssuedNNd m
,NNm n
GuidNNo s
?NNs t
userIdNNu {
,NN{ |
CancellationToken	NN} é
ct
NNè ë
)
NNë í
{OO 
varPP 
documentPP 
=PP 
awaitPP 
dbPP 
.PP  
TaxDocumentsPP  ,
.PP, - 
SingleOrDefaultAsyncPP- A
(PPA B
xPPB C
=>PPD F
xPPG H
.PPH I
IdPPI K
==PPL N

documentIdPPO Y
,PPY Z
ctPP[ ]
)PP] ^
;PP^ _
ifQQ 

(QQ 
documentQQ 
isQQ 
nullQQ 
)QQ 
returnQQ $
nullQQ% )
;QQ) *
varRR 
paymentRR 
=RR 
documentRR 
.RR  
PaymentTransactionIdRR 3
isRR4 6
GuidRR7 ;
	paymentIdRR< E
?RRF G
awaitRRH M
dbRRN P
.RRP Q
PaymentTransactionsRRQ d
.RRd e 
SingleOrDefaultAsyncRRe y
(RRy z
xRRz {
=>RR| ~
x	RR Ä
.
RRÄ Å
Id
RRÅ É
==
RRÑ Ü
	paymentId
RRá ê
,
RRê ë
ct
RRí î
)
RRî ï
:
RRñ ó
null
RRò ú
;
RRú ù
varSS 
itemSS 
=SS 
paymentSS 
isSS 
nullSS "
?SS# $
nullSS% )
:SS* +
awaitSS, 1
RevertProductAsyncSS2 D
(SSD E
paymentSSE L
,SSL M
reasonSSN T
,SST U
ctSSV X
)SSX Y
;SSY Z
varTT 
numberReleasedTT 
=TT 
	notIssuedTT &
&&TT' )
awaitTT* /
ReleaseNumberAsyncTT0 B
(TTB C
documentTTC K
,TTK L
ctTTM O
)TTO P
;TTP Q
dbUU 

.UU
 
PaymentReversalsUU 
.UU 
AddUU 
(UU  
newUU  #
PaymentReversalUU$ 3
{VV 	
ClientIdWW 
=WW 
documentWW 
.WW  
ClientIdWW  (
,WW( )
ClientProductIdWW* 9
=WW: ;
paymentWW< C
?WWC D
.WWD E
ClientProductIdWWE T
,WWT U

PaymentKeyWWV `
=WWa b
paymentWWc j
?WWj k
.WWk l*
PayPalOrderIdOrSubscriptionId	WWl â
,
WWâ ä
Method
WWã ë
=
WWí ì
payment
WWî õ
?
WWõ ú
.
WWú ù
Method
WWù £
,
WW£ §
InternalCode
WW• ±
=
WW≤ ≥
payment
WW¥ ª
?
WWª º
.
WWº Ω
InternalCode
WWΩ …
,
WW…  
AmountXX 
=XX 
paymentXX 
?XX 
.XX 
AmountXX $
??XX% '
documentXX( 0
.XX0 1
TotalAmountXX1 <
,XX< =
CurrencyXX> F
=XXG H
paymentXXI P
?XXP Q
.XXQ R
CurrencyXXR Z
??XX[ ]
documentXX^ f
.XXf g
CurrencyXXg o
,XXo p
	AmountPenXXq z
=XX{ |
payment	XX} Ñ
?
XXÑ Ö
.
XXÖ Ü
	AmountPen
XXÜ è
,
XXè ê
PaidAt
XXë ó
=
XXò ô
payment
XXö °
?
XX° ¢
.
XX¢ £
	CreatedAt
XX£ ¨
,
XX¨ ≠
DocumentTypeYY 
=YY 
documentYY #
.YY# $
TypeYY$ (
,YY( )
SeriesYY* 0
=YY1 2
documentYY3 ;
.YY; <
SeriesYY< B
,YYB C
NumberYYD J
=YYK L
documentYYM U
.YYU V
NumberYYV \
,YY\ ]
	IssueDateYY^ g
=YYh i
documentYYj r
.YYr s
	IssueDateYYs |
,YY| }
Reason	YY~ Ñ
=
YYÖ Ü
reason
YYá ç
,
YYç é
	NotIssued
YYè ò
=
YYô ö
	notIssued
YYõ §
,
YY§ •
NumberReleased
YY¶ ¥
=
YYµ ∂
numberReleased
YY∑ ≈
,
YY≈ ∆
ReversedByUserId
YY« ◊
=
YYÿ Ÿ
userId
YY⁄ ‡
,
YY‡ ·
}ZZ 	
)ZZ	 

;ZZ
 
db[[ 

.[[
 
TaxDocumentLines[[ 
.[[ 
RemoveRange[[ '
([[' (
await[[( -
db[[. 0
.[[0 1
TaxDocumentLines[[1 A
.[[A B
Where[[B G
([[G H
x[[H I
=>[[J L
x[[M N
.[[N O
TaxDocumentId[[O \
==[[] _
document[[` h
.[[h i
Id[[i k
)[[k l
.[[l m
ToListAsync[[m x
([[x y
ct[[y {
)[[{ |
)[[| }
;[[} ~
db\\ 

.\\
 
TaxDocuments\\ 
.\\ 
Remove\\ 
(\\ 
document\\ '
)\\' (
;\\( )
if]] 

(]] 
payment]] 
is]] 
not]] 
null]] 
)]]  
{^^ 	
var`` 
	dedupeKey`` 
=`` 
$"`` 
$str`` &
{``& '
payment``' .
.``. /)
PayPalOrderIdOrSubscriptionId``/ L
}``L M
"``M N
;``N O
dbaa 
.aa 
NotificationLogsaa 
.aa  
RemoveRangeaa  +
(aa+ ,
awaitaa, 1
dbaa2 4
.aa4 5
NotificationLogsaa5 E
.aaE F
WhereaaF K
(aaK L
xaaL M
=>aaN P
xaaQ R
.aaR S
	DedupeKeyaaS \
==aa] _
	dedupeKeyaa` i
)aai j
.aaj k
ToListAsyncaak v
(aav w
ctaaw y
)aay z
)aaz {
;aa{ |
dbbb 
.bb 
PortalNotificationsbb "
.bb" #
RemoveRangebb# .
(bb. /
awaitbb/ 4
dbbb5 7
.bb7 8
PortalNotificationsbb8 K
.bbK L
WherebbL Q
(bbQ R
xbbR S
=>bbT V
xbbW X
.bbX Y
	DedupeKeybbY b
==bbc e
	dedupeKeybbf o
)bbo p
.bbp q
ToListAsyncbbq |
(bb| }
ctbb} 
)	bb Ä
)
bbÄ Å
;
bbÅ Ç
dbcc 
.cc 
PaymentTransactionscc "
.cc" #
Removecc# )
(cc) *
paymentcc* 1
)cc1 2
;cc2 3
}dd 	
awaitee 
dbee 
.ee 
SaveChangesAsyncee !
(ee! "
ctee" $
)ee$ %
;ee% &
returnff 
newff %
TaxDocumentReversalResultff ,
(ff, -
numberReleasedff- ;
,ff; <
paymentff= D
?ffD E
.ffE F
MethodffF L
,ffL M
itemffN R
?ffR S
.ffS T
StatusffT Z
,ffZ [
itemff\ `
?ff` a
.ffa b
RenewsAtffb j
,ffj k
itemffl p
?ffp q
.ffq r
NextChargeAtffr ~
)ff~ 
;	ff Ä
}gg 
privatejj 
asyncjj 
Taskjj 
<jj 
ClientProductjj $
?jj$ %
>jj% &
RevertProductAsyncjj' 9
(jj9 :
PaymentTransactionjj: L
paymentjjM T
,jjT U
stringjjV \
reasonjj] c
,jjc d
CancellationTokenjje v
ctjjw y
)jjy z
{kk 
varll 
reportll 
=ll 
awaitll 
dbll 
.ll 
TransferReportsll -
.ll- . 
SingleOrDefaultAsyncll. B
(llB C
xllC D
=>llE G
xllH I
.llI J 
PaymentTransactionIdllJ ^
==ll_ a
paymentllb i
.lli j
Idllj l
,lll m
ctlln p
)llp q
;llq r
ifmm 

(mm 
reportmm 
ismm 
notmm 
nullmm 
)mm 
(mm  !
reportmm! '
.mm' (
Statusmm( .
,mm. /
reportmm0 6
.mm6 7
RejectionReasonmm7 F
,mmF G
reportmmH N
.mmN O 
PaymentTransactionIdmmO c
)mmc d
=mme f
(mmg h 
TransferReportStatusmmh |
.mm| }
	Rechazado	mm} Ü
,
mmÜ á
$"
mmà ä
$str
mmä ö
{
mmö õ
reason
mmõ °
}
mm° ¢
"
mm¢ £
,
mm£ §
null
mm• ©
)
mm© ™
;
mm™ ´
ifnn 

(nn 
paymentnn 
.nn 
ClientProductIdnn #
isnn$ &
notnn' *
Guidnn+ /
itemIdnn0 6
||nn7 9
paymentnn: A
.nnA B)
PayPalOrderIdOrSubscriptionIdnnB _
.nn_ `

StartsWithnn` j
(nnj k
$strnnk t
,nnt u
StringComparison	nnv Ü
.
nnÜ á
Ordinal
nná é
)
nné è
)
nnè ê
return
nnë ó
null
nnò ú
;
nnú ù
varoo 
itemoo 
=oo 
awaitoo 
dboo 
.oo 
ClientProductsoo *
.oo* + 
SingleOrDefaultAsyncoo+ ?
(oo? @
xoo@ A
=>ooB D
xooE F
.ooF G
IdooG I
==ooJ L
itemIdooM S
,ooS T
ctooU W
)ooW X
;ooX Y
ifpp 

(pp 
itempp 
ispp 
nullpp 
)pp 
returnpp  
nullpp! %
;pp% &
varqq 
othersqq 
=qq 
awaitqq 
dbqq 
.qq 
PaymentTransactionsqq 1
.qq1 2
Whereqq2 7
(qq7 8
xqq8 9
=>qq: <
xqq= >
.qq> ?
ClientProductIdqq? N
==qqO Q
itemIdqqR X
&&qqY [
xqq\ ]
.qq] ^
Idqq^ `
!=qqa c
paymentqqd k
.qqk l
Idqql n
)qqn o
.qqo p
Selectqqp v
(qqv w
xqqw x
=>qqy {
xqq| }
.qq} ~
	CreatedAt	qq~ á
)
qqá à
.
qqà â
ToListAsync
qqâ î
(
qqî ï
ct
qqï ó
)
qqó ò
;
qqò ô
itemss 
.ss 
OnPaymentReversedss 
(ss 
itemss #
.ss# $
BillingCycless$ 0
==ss1 3
BillingCycless4 @
.ss@ A
AnualssA F
?ssG H
itemssI M
.ssM N
RenewsAtssN V
?ssV W
.ssW X
AddYearsssX `
(ss` a
$numssa b
-ssc d
paymentsse l
.ssl m
Yearsssm r
)ssr s
:sst u
itemssv z
.ssz {
NextChargeAt	ss{ á
)
ssá à
;
ssà â 
PayPalPaymentServicett 
.tt 
RollbackPeriodtt +
(tt+ ,
itemtt, 0
,tt0 1
paymenttt2 9
.tt9 :
Yearstt: ?
,tt? @
othersttA G
.ttG H
AllttH K
(ttK L
xttL M
=>ttN P
xttQ R
<=ttS U
paymentttV ]
.tt] ^
	CreatedAttt^ g
)ttg h
)tth i
;tti j
ifww 

(ww 
othersww 
.ww 
Countww 
==ww 
$numww 
&&ww  
itemww! %
.ww% &
Statusww& ,
!=ww- /
ClientProductStatusww0 C
.wwC D
	CanceladowwD M
&&wwN P
(wwQ R
paymentwwR Y
.wwY Z
MethodwwZ `
==wwa c
PaymentMethodswwd r
.wwr s
PayPalwws y
||wwz |
report	ww} É
is
wwÑ Ü
not
wwá ä
null
wwã è
)
wwè ê
)
wwê ë
{xx 	
itemyy 
.yy 
Statusyy 
=yy 
ClientProductStatusyy -
.yy- .
	Pendienteyy. 7
;yy7 8
ifzz 
(zz 
itemzz 
.zz 
RenewsAtzz 
==zz  
paymentzz! (
.zz( )
	CreatedAtzz) 2
)zz2 3
itemzz4 8
.zz8 9
RenewsAtzz9 A
=zzB C
nullzzD H
;zzH I
if{{ 
({{ 
item{{ 
.{{ 
NextChargeAt{{ !
=={{" $
payment{{% ,
.{{, -
	CreatedAt{{- 6
){{6 7
item{{8 <
.{{< =
NextChargeAt{{= I
={{J K
null{{L P
;{{P Q
}|| 	
else}} 
item}} 
.}} 
Status}} 
=}} 
RenewalReminderJob}} -
.}}- .
	StatusFor}}. 7
(}}7 8
item}}8 <
.}}< =
Status}}= C
,}}C D
item}}E I
.}}I J
RenewsAt}}J R
,}}R S
DateTime}}T \
.}}\ ]
UtcNow}}] c
)}}c d
;}}d e
return~~ 
item~~ 
;~~ 
} 
private
ÅÅ 
async
ÅÅ 
Task
ÅÅ 
<
ÅÅ 
bool
ÅÅ 
>
ÅÅ  
ReleaseNumberAsync
ÅÅ /
(
ÅÅ/ 0
TaxDocument
ÅÅ0 ;
document
ÅÅ< D
,
ÅÅD E
CancellationToken
ÅÅF W
ct
ÅÅX Z
)
ÅÅZ [
{
ÇÇ 
var
ÉÉ 
settings
ÉÉ 
=
ÉÉ 
await
ÉÉ 
db
ÉÉ 
.
ÉÉ  
TaxSettings
ÉÉ  +
.
ÉÉ+ ,!
FirstOrDefaultAsync
ÉÉ, ?
(
ÉÉ? @
ct
ÉÉ@ B
)
ÉÉB C
;
ÉÉC D
if
ÑÑ 

(
ÑÑ 
settings
ÑÑ 
is
ÑÑ 
null
ÑÑ 
||
ÑÑ 
await
ÑÑ  %
db
ÑÑ& (
.
ÑÑ( )
TaxDocuments
ÑÑ) 5
.
ÑÑ5 6
AnyAsync
ÑÑ6 >
(
ÑÑ> ?
x
ÑÑ? @
=>
ÑÑA C
x
ÑÑD E
.
ÑÑE F
Type
ÑÑF J
==
ÑÑK M
document
ÑÑN V
.
ÑÑV W
Type
ÑÑW [
&&
ÑÑ\ ^
x
ÑÑ_ `
.
ÑÑ` a
Series
ÑÑa g
==
ÑÑh j
document
ÑÑk s
.
ÑÑs t
Series
ÑÑt z
&&
ÑÑ{ }
x
ÑÑ~ 
.ÑÑ Ä
NumberÑÑÄ Ü
>ÑÑá à
documentÑÑâ ë
.ÑÑë í
NumberÑÑí ò
,ÑÑò ô
ctÑÑö ú
)ÑÑú ù
)ÑÑù û
returnÑÑü •
falseÑÑ¶ ´
;ÑÑ´ ¨
var
ÖÖ 
	isFactura
ÖÖ 
=
ÖÖ 
document
ÖÖ  
.
ÖÖ  !
Type
ÖÖ! %
==
ÖÖ& (
TaxDocumentType
ÖÖ) 8
.
ÖÖ8 9
Factura
ÖÖ9 @
;
ÖÖ@ A
if
ÜÜ 

(
ÜÜ 
(
ÜÜ 
	isFactura
ÜÜ 
?
ÜÜ 
settings
ÜÜ !
.
ÜÜ! "
FacturaSeries
ÜÜ" /
:
ÜÜ0 1
settings
ÜÜ2 :
.
ÜÜ: ;
ReciboSeries
ÜÜ; G
)
ÜÜG H
!=
ÜÜI K
document
ÜÜL T
.
ÜÜT U
Series
ÜÜU [
||
ÜÜ\ ^
(
ÜÜ_ `
	isFactura
ÜÜ` i
?
ÜÜj k
settings
ÜÜl t
.
ÜÜt u 
FacturaNextNumberÜÜu Ü
:ÜÜá à
settingsÜÜâ ë
.ÜÜë í 
ReciboNextNumberÜÜí ¢
)ÜÜ¢ £
!=ÜÜ§ ¶
documentÜÜß Ø
.ÜÜØ ∞
NumberÜÜ∞ ∂
+ÜÜ∑ ∏
$numÜÜπ ∫
)ÜÜ∫ ª
returnÜÜº ¬
falseÜÜ√ »
;ÜÜ» …
if
áá 

(
áá 
	isFactura
áá 
)
áá 
settings
áá 
.
áá  
FacturaNextNumber
áá  1
=
áá2 3
document
áá4 <
.
áá< =
Number
áá= C
;
ááC D
else
ááE I
settings
ááJ R
.
ááR S
ReciboNextNumber
ááS c
=
áád e
document
ááf n
.
áán o
Number
ááo u
;
ááu v
return
àà 
true
àà 
;
àà 
}
ââ 
public
åå 

static
åå 
string
åå 
LineDescription
åå (
(
åå( )
ClientProduct
åå) 6
item
åå7 ;
)
åå; <
{
çç 
var
éé 
name
éé 
=
éé 
item
éé 
.
éé 
Product
éé 
?
éé  
.
éé  !
Name
éé! %
??
éé& (
$str
éé) 3
;
éé3 4
var
èè 
text
èè 
=
èè 
string
èè 
.
èè  
IsNullOrWhiteSpace
èè ,
(
èè, -
item
èè- 1
.
èè1 2

DomainName
èè2 <
)
èè< =
?
èè> ?
name
èè@ D
:
èèE F
$"
èèG I
{
èèI J
name
èèJ N
}
èèN O
$str
èèO R
{
èèR S
item
èèS W
.
èèW X

DomainName
èèX b
}
èèb c
"
èèc d
;
èèd e
return
êê 
text
êê 
.
êê 
Length
êê 
>
êê 
$num
êê  
?
êê! "
text
êê# '
[
êê' (
..
êê( *
$num
êê* -
]
êê- .
:
êê/ 0
text
êê1 5
;
êê5 6
}
ëë 
}íí 
publicïï 
sealed
ïï 
record
ïï '
TaxDocumentReversalResult
ïï .
(
ïï. /
bool
ïï/ 3
NumberReleased
ïï4 B
,
ïïB C
string
ïïD J
?
ïïJ K
PaymentMethod
ïïL Y
,
ïïY Z!
ClientProductStatus
ïï[ n
?
ïïn o
ProductStatus
ïïp }
,
ïï} ~
DateTimeïï á
?ïïá à
RenewsAtïïâ ë
,ïïë í
DateTimeïïì õ
?ïïõ ú
NextChargeAtïïù ©
)ïï© ™
;ïï™ ´ ç
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
AAè ê
string
AAë ó
method
AAò û
=
AAü †
PaymentMethods
AA° Ø
.
AAØ ∞
PayPal
AA∞ ∂
,
AA∂ ∑
DateTime
AA∏ ¿
?
AA¿ ¡
paidAt
AA¬ »
=
AA…  
null
AAÀ œ
,
AAœ –
int
AA— ‘
?
AA‘ ’
years
AA÷ €
=
AA‹ ›
null
AAﬁ ‚
)
AA‚ „
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
varDD 
whenDD 
=DD 
paidAtDD 
??DD 
DateTimeDD %
.DD% &
UtcNowDD& ,
;DD, -
varEE 
	paidYearsEE 
=EE 
itemEE 
.EE 
BillingCycleEE )
==EE* ,
BillingCycleEE- 9
.EE9 :
AnualEE: ?
?EE@ A
MathEEB F
.EEF G
ClampEEG L
(EEL M
yearsEEM R
??EES U
(EEV W
transactionKeyEEW e
==EEf h
itemEEi m
.EEm n
PayPalOrderIdEEn {
?EE| }
item	EE~ Ç
.
EEÇ É
PayPalOrderYears
EEÉ ì
:
EEî ï
null
EEñ ö
)
EEö õ
??
EEú û
$num
EEü †
,
EE† °
$num
EE¢ £
,
EE£ §"
ClientProductPricing
EE• π
.
EEπ ∫
MaxPrepaidYears
EE∫ …
)
EE…  
:
EEÀ Ã
$num
EEÕ Œ
;
EEŒ œ
varFF 
transactionFF 
=FF 
newFF 
PaymentTransactionFF 0
{FF1 2
ClientIdFF3 ;
=FF< =
itemFF> B
.FFB C
ClientIdFFC K
,FFK L
ClientProductIdFFM \
=FF] ^
itemFF_ c
.FFc d
IdFFd f
,FFf g*
PayPalOrderIdOrSubscriptionId	FFh Ö
=
FFÜ á
transactionKey
FFà ñ
,
FFñ ó
Amount
FFò û
=
FFü †
amount
FF° ß
,
FFß ®
Currency
FF© ±
=
FF≤ ≥
currency
FF¥ º
??
FFΩ ø
item
FF¿ ƒ
.
FFƒ ≈
Product
FF≈ Ã
?
FFÃ Õ
.
FFÕ Œ
Currency
FFŒ ÷
??
FF◊ Ÿ
$str
FF⁄ ﬂ
,
FFﬂ ‡
Status
FF· Á
=
FFË È
$str
FFÍ ı
,
FFı ˆ
Method
FF˜ ˝
=
FF˛ ˇ
method
FFÄ Ü
,
FFÜ á
	CreatedAt
FFà ë
=
FFí ì
when
FFî ò
,
FFò ô
Years
FFö ü
=
FF† °
	paidYears
FF¢ ´
}
FF¨ ≠
;
FF≠ Æ
transactionGG 
.GG 
InternalCodeGG  
=GG! "
awaitGG# (
dbGG) +
.GG+ ,!
NextInternalCodeAsyncGG, A
(GGA B
ctGGB D
)GGD E
;GGE F
transactionHH 
.HH 
	AmountPenHH 
=HH 
amountHH  &
*HH' (
awaitHH) .
dbHH/ 1
.HH1 2
RateToPenAsyncHH2 @
(HH@ A
transactionHHA L
.HHL M
CurrencyHHM U
,HHU V
DateOnlyHHW _
.HH_ `
FromDateTimeHH` l
(HHl m
transactionHHm x
.HHx y
	CreatedAt	HHy Ç
)
HHÇ É
,
HHÉ Ñ
ct
HHÖ á
)
HHá à
;
HHà â
dbII 

.II
 
PaymentTransactionsII 
.II 
AddII "
(II" #
transactionII# .
)II. /
;II/ 0
itemJJ 
.JJ 
StatusJJ 
=JJ 
ClientProductStatusJJ )
.JJ) *
ActivoJJ* 0
;JJ0 1
ExtendPeriodLL 
(LL 
itemLL 
,LL 
whenLL 
)LL  
;LL  !
itemMM 
.MM 
OnPaymentAppliedMM 
(MM 
)MM 
;MM  
forNN 
(NN 
varNN 
yearNN 
=NN 
$numNN 
;NN 
yearNN 
<NN  !
	paidYearsNN" +
;NN+ ,
yearNN- 1
++NN1 3
)NN3 4
ExtendPeriodNN5 A
(NNA B
itemNNB F
,NNF G
whenNNH L
)NNL M
;NNM N
tryOO 
{OO 
awaitOO 
dbOO 
.OO 
SaveChangesAsyncOO '
(OO' (
ctOO( *
)OO* +
;OO+ ,
}OO- .
catchPP 
(PP 
DbUpdateExceptionPP  
)PP  !
{QQ 	
ifSS 
(SS 
!SS 
awaitSS 
PaymentExistsAsyncSS )
(SS) *
transactionKeySS* 8
,SS8 9
ctSS: <
)SS< =
)SS= >
throwSS? D
;SSD E
dbTT 
.TT 
EntryTT 
(TT 
transactionTT  
)TT  !
.TT! "
StateTT" '
=TT( )
EntityStateTT* 5
.TT5 6
DetachedTT6 >
;TT> ?
awaitUU 
dbUU 
.UU 
EntryUU 
(UU 
itemUU 
)UU  
.UU  !
ReloadAsyncUU! ,
(UU, -
ctUU- /
)UU/ 0
;UU0 1
returnVV 
falseVV 
;VV 
}WW 	
awaitYY 
taxDocumentsYY 
.YY  
IssueForPaymentAsyncYY /
(YY/ 0
transactionYY0 ;
,YY; <
ctYY= ?
)YY? @
;YY@ A
ifZZ 

(ZZ 
awaitZZ 
dbZZ 
.ZZ 
ClientsZZ 
.ZZ 
	FindAsyncZZ &
(ZZ& '
[ZZ' (
itemZZ( ,
.ZZ, -
ClientIdZZ- 5
]ZZ5 6
,ZZ6 7
ctZZ8 :
)ZZ: ;
isZZ< >
ClientZZ? E
clientZZF L
)ZZL M
await[[ 
notifications[[ 
.[[  
	SendAsync[[  )
([[) *
client[[* 0
,[[0 1
new[[2 5
Notification[[6 B
([[B C
NotificationType[[C S
.[[S T
PaymentReceived[[T c
,[[c d
new[[e h
([[h i
)[[i j
{\\ 
[]] 
$str]] 
]]] 
=]] 
item]] "
.]]" #
Product]]# *
?]]* +
.]]+ ,
Name]], 0
??]]1 3
$str]]4 6
,]]6 7
[^^ 
$str^^ 
]^^ 
=^^ 
amount^^ #
.^^# $
ToString^^$ ,
(^^, -
CultureInfo^^- 8
.^^8 9
InvariantCulture^^9 I
)^^I J
,^^J K
[__ 
$str__ 
]__ 
=__ 
transaction__ *
.__* +
Currency__+ 3
,__3 4
}`` 
,`` 
$"`` 
$str`` 
{`` 
transactionKey`` (
}``( )
"``) *
)``* +
,``+ ,
ct``- /
)``/ 0
;``0 1
returnaa 
trueaa 
;aa 
}bb 
publicjj 

staticjj 
voidjj 
ExtendPeriodjj #
(jj# $
ClientProductjj$ 1
itemjj2 6
,jj6 7
DateTimejj8 @
nowjjA D
)jjD E
{kk 
switchll 
(ll 
itemll 
.ll 
BillingCyclell !
)ll! "
{mm 	
casenn 
BillingCyclenn 
.nn 
Anualnn #
:nn# $
itemoo 
.oo 
RenewsAtoo 
=oo 
(oo  !
itemoo! %
.oo% &
RenewsAtoo& .
isoo/ 1
DateTimeoo2 :
renewsAtoo; C
&&ooD F
renewsAtooG O
>ooP Q
nowooR U
?ooV W
renewsAtooX `
:ooa b
nowooc f
)oof g
.oog h
AddYearsooh p
(oop q
$numooq r
)oor s
;oos t
breakpp 
;pp 
caseqq 
varqq 
cycleqq 
whenqq 
cycleqq  %
.qq% &
SubscriptionMonthsqq& 8
(qq8 9
)qq9 :
isqq; =
intqq> A
monthsqqB H
:qqH I
itemrr 
.rr 
NextChargeAtrr !
=rr" #
nowrr$ '
.rr' (
	AddMonthsrr( 1
(rr1 2
monthsrr2 8
)rr8 9
;rr9 :
breakss 
;ss 
}tt 	
}uu 
public{{ 

static{{ 
void{{ 
RollbackPeriod{{ %
({{% &
ClientProduct{{& 3
item{{4 8
,{{8 9
int{{: =
years{{> C
,{{C D
bool{{E I
isLatestPayment{{J Y
){{Y Z
{|| 
switch}} 
(}} 
item}} 
.}} 
BillingCycle}} !
)}}! "
{~~ 	
case 
BillingCycle 
. 
Anual #
:# $
item
ÄÄ 
.
ÄÄ 
RenewsAt
ÄÄ 
=
ÄÄ 
item
ÄÄ  $
.
ÄÄ$ %
RenewsAt
ÄÄ% -
?
ÄÄ- .
.
ÄÄ. /
AddYears
ÄÄ/ 7
(
ÄÄ7 8
-
ÄÄ8 9
years
ÄÄ9 >
)
ÄÄ> ?
;
ÄÄ? @
break
ÅÅ 
;
ÅÅ 
case
ÇÇ 
var
ÇÇ 
cycle
ÇÇ 
when
ÇÇ 
cycle
ÇÇ  %
.
ÇÇ% & 
SubscriptionMonths
ÇÇ& 8
(
ÇÇ8 9
)
ÇÇ9 :
is
ÇÇ; =
int
ÇÇ> A
months
ÇÇB H
&&
ÇÇI K
isLatestPayment
ÇÇL [
:
ÇÇ[ \
item
ÉÉ 
.
ÉÉ 
NextChargeAt
ÉÉ !
=
ÉÉ" #
item
ÉÉ$ (
.
ÉÉ( )
NextChargeAt
ÉÉ) 5
?
ÉÉ5 6
.
ÉÉ6 7
	AddMonths
ÉÉ7 @
(
ÉÉ@ A
-
ÉÉA B
months
ÉÉB H
)
ÉÉH I
;
ÉÉI J
break
ÑÑ 
;
ÑÑ 
}
ÖÖ 	
}
ÜÜ 
private
ââ 
async
ââ 
Task
ââ 
<
ââ 
bool
ââ 
>
ââ  
PaymentExistsAsync
ââ /
(
ââ/ 0
string
ââ0 6
transactionKey
ââ7 E
,
ââE F
CancellationToken
ââG X
ct
ââY [
)
ââ[ \
=>
ââ] _
await
ää 
db
ää 
.
ää !
PaymentTransactions
ää $
.
ää$ %
AnyAsync
ää% -
(
ää- .
x
ää. /
=>
ää0 2
x
ää3 4
.
ää4 5+
PayPalOrderIdOrSubscriptionId
ää5 R
==
ääS U
transactionKey
ääV d
,
ääd e
ct
ääf h
)
ääh i
||
ãã 

await
ãã 
db
ãã 
.
ãã 
PaymentReversals
ãã $
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
ãã4 5

PaymentKey
ãã5 ?
==
ãã@ B
transactionKey
ããC Q
&&
ããR T
x
ããU V
.
ããV W
Method
ããW ]
==
ãã^ `
PaymentMethods
ããa o
.
ãão p
PayPal
ããp v
,
ããv w
ct
ããx z
)
ããz {
;
ãã{ |
}åå ∫Q
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
}  |
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
. 
	AddScoped 
< !
PayPalCheckoutService 0
>0 1
(1 2
)2 3
;3 4
builder 
. 
Services 
. 
	AddScoped 
<  
PayPalPaymentService /
>/ 0
(0 1
)1 2
;2 3
builder 
. 
Services 
. 
	AddScoped 
< 
TaxDocumentService -
>- .
(. /
)/ 0
;0 1
builder 
. 
Services 
. 
	AddScoped 
< 
BankTransferService .
>. /
(/ 0
)0 1
;1 2
builder 
. 
Services 
. 
	AddScoped 
< 
StaffNotifier (
>( )
() *
)* +
;+ ,
builder   
.   
Services   
.   
AddCors   
(   
options    
=>  ! #
options  $ +
.  + ,
AddDefaultPolicy  , <
(  < =
policy  = C
=>  D F
policy  G M
.!! 
WithOrigins!! 
(!! !
PayPalCheckoutService!! &
.!!& '
AllowedOrigins!!' 5
(!!5 6
builder!!6 =
.!!= >
Configuration!!> K
)!!K L
)!!L M
."" 
AllowAnyHeader"" 
("" 
)"" 
."" 
AllowAnyMethod"" $
(""$ %
)""% &
)""& '
)""' (
;""( )
var$$ 
jwt$$ 
=$$ 	
JwtSettings$$
 
.$$ 
FromConfiguration$$ '
($$' (
builder$$( /
.$$/ 0
Configuration$$0 =
)$$= >
;$$> ?
builder%% 
.%% 
Services%% 
.%% 
AddSingleton%% 
(%% 
jwt%% !
)%%! "
;%%" #
builder&& 
.&& 
Services&& 
.&& 
AddAuthentication&& "
(&&" #
JwtBearerDefaults&&# 4
.&&4 5 
AuthenticationScheme&&5 I
)&&I J
.&&J K
AddJwtBearer&&K W
(&&W X
options&&X _
=>&&` b
options&&c j
.&&j k&
TokenValidationParameters	&&k Ñ
=
&&Ö Ü
new
&&á ä'
TokenValidationParameters
&&ã §
{'' 
ValidateIssuer(( 
=(( 
true(( 
,(( 
ValidateAudience(( +
=((, -
true((. 2
,((2 3
ValidateLifetime((4 D
=((E F
true((G K
,((K L$
ValidateIssuerSigningKey((M e
=((f g
true((h l
,((l m
ValidIssuer)) 
=)) 
jwt)) 
.)) 
Issuer)) 
,)) 
ValidAudience)) +
=)), -
jwt)). 1
.))1 2
Audience))2 :
,)): ;
IssuerSigningKey))< L
=))M N
jwt))O R
.))R S

SigningKey))S ]
,))] ^
	ClockSkew** 
=** 
TimeSpan** 
.** 
FromMinutes** $
(**$ %
$num**% &
)**& '
}++ 
)++ 
;++ 
builder,, 
.,, 
Services,, 
.,, 
AddAuthorization,, !
(,,! "
),," #
;,,# $
builder-- 
.-- 
Services-- 
.-- 
AddMemoryCache-- 
(--  
)--  !
;--! "
builder// 
.// 
Services// 
.// 
	Configure// 
<// #
ForwardedHeadersOptions// 2
>//2 3
(//3 4
o//4 5
=>//6 8
{00 
o11 
.11 
ForwardedHeaders11 
=11 
ForwardedHeaders11 )
.11) *
XForwardedFor11* 7
|118 9
ForwardedHeaders11: J
.11J K
XForwardedProto11K Z
;11Z [
o22 
.22 
KnownIPNetworks22 
.22 
Clear22 
(22 
)22 
;22 
o22  
.22  !
KnownProxies22! -
.22- .
Clear22. 3
(223 4
)224 5
;225 6
}33 
)33 
;33 
builder44 
.44 
Services44 
.44 
AddRateLimiter44 
(44  
o44  !
=>44" $
{55 
o66 
.66 
RejectionStatusCode66 
=66 
StatusCodes66 '
.66' ($
Status429TooManyRequests66( @
;66@ A
o77 
.77 

OnRejected77 
=77 
(77 
ctx77 
,77 
ct77 
)77 
=>77 
new77  #
	ValueTask77$ -
(77- .
ctx77. 1
.771 2
HttpContext772 =
.77= >
Response77> F
.77F G
WriteAsJsonAsync77G W
(77W X
new77X [
{77\ ]
message77^ e
=77f g
ctx77h k
.77k l
HttpContext77l w
.77w x
Request77x 
.	77 Ä
Path
77Ä Ñ
.
77Ñ Ö 
StartsWithSegments
77Ö ó
(
77ó ò
$str
77ò ≠
)
77≠ Æ
?88 	
$str88
 k
:99 	
$str99
 [
}99\ ]
,99] ^
ct99_ a
)99a b
)99b c
;99c d
o;; 
.;; 
	AddPolicy;; 
(;; 
ContactController;; !
.;;! "
RateLimitPolicy;;" 1
,;;1 2
http;;3 7
=>;;8 :
RateLimitPartition;;; M
.;;M N!
GetFixedWindowLimiter;;N c
(;;c d
http<< 
.<< 

Connection<< 
.<< 
RemoteIpAddress<< '
?<<' (
.<<( )
ToString<<) 1
(<<1 2
)<<2 3
??<<4 6
$str<<7 @
,<<@ A
_== 	
=>==
 
new== )
FixedWindowRateLimiterOptions== .
{==/ 0
PermitLimit==1 <
==== >
$num==? @
,==@ A
Window==B H
===I J
TimeSpan==K S
.==S T
FromMinutes==T _
(==_ `
$num==` b
)==b c
,==c d

QueueLimit==e o
===p q
$num==r s
}==t u
)==u v
)==v w
;==w x
o>> 
.>> 
	AddPolicy>> 
(>> 
AuthController>> 
.>>  
LoginRateLimitPolicy>> 3
,>>3 4
http>>5 9
=>>>: <
RateLimitPartition>>= O
.>>O P!
GetFixedWindowLimiter>>P e
(>>e f
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
$num@@? A
,@@A B
Window@@C I
=@@J K
TimeSpan@@L T
.@@T U
FromMinutes@@U `
(@@` a
$num@@a b
)@@b c
,@@c d

QueueLimit@@e o
=@@p q
$num@@r s
}@@t u
)@@u v
)@@v w
;@@w x
}AA 
)AA 
;AA 
builderCC 
.CC 
ServicesCC 
.CC 
AddHangfireCC 
(CC 
configCC #
=>CC$ &
configCC' -
.CC- .
UseSqlServerStorageCC. A
(CCA B
builderCCB I
.CCI J
ConfigurationCCJ W
.CCW X
GetConnectionStringCCX k
(CCk l
$strCCl w
)CCw x
,CCx y
newCCz }$
SqlServerStorageOptions	CC~ ï
{
CCñ ó&
PrepareSchemaIfNecessary
CCò ∞
=
CC± ≤
true
CC≥ ∑
}
CC∏ π
)
CCπ ∫
)
CC∫ ª
;
CCª º
builderDD 
.DD 
ServicesDD 
.DD 
AddHangfireServerDD "
(DD" #
)DD# $
;DD$ %
varFF 
appFF 
=FF 	
builderFF
 
.FF 
BuildFF 
(FF 
)FF 
;FF 
appGG 
.GG 
UseForwardedHeadersGG 
(GG 
)GG 
;GG 
ifHH 
(HH 
appHH 
.HH 
EnvironmentHH 
.HH 
IsDevelopmentHH !
(HH! "
)HH" #
)HH# $
{II 
appJJ 
.JJ 

MapOpenApiJJ 
(JJ 
)JJ 
;JJ 
usingKK 	
varKK
 
scopeKK 
=KK 
appKK 
.KK 
ServicesKK "
.KK" #
CreateScopeKK# .
(KK. /
)KK/ 0
;KK0 1
awaitLL 	
DbSeederLL
 
.LL 
	SeedAsyncLL 
(LL 
scopeLL "
.LL" #
ServiceProviderLL# 2
.LL2 3
GetRequiredServiceLL3 E
<LLE F
RtresDbContextLLF T
>LLT U
(LLU V
)LLV W
)LLW X
;LLX Y
}MM 
appNN 
.NN 
UseHttpsRedirectionNN 
(NN 
)NN 
;NN 
appOO 
.OO 
UseCorsOO 
(OO 
)OO 
;OO 
appPP 
.PP 
UseRateLimiterPP 
(PP 
)PP 
;PP 
appQQ 
.QQ 
UseAuthenticationQQ 
(QQ 
)QQ 
;QQ 
appRR 
.RR 
UseAuthorizationRR 
(RR 
)RR 
;RR 
appSS 
.SS  
UseHangfireDashboardSS 
(SS 
$strSS  
)SS  !
;SS! "
RecurringJobUU 
.UU 
AddOrUpdateUU 
<UU 
RenewalReminderJobUU +
>UU+ ,
(UU, -
$strUU- @
,UU@ A
jobUUB E
=>UUF H
jobUUI L
.UUL M
	SendAsyncUUM V
(UUV W
CancellationTokenUUW h
.UUh i
NoneUUi m
)UUm n
,UUn o
CronUUp t
.UUt u
DailyUUu z
(UUz {
$numUU{ }
)UU} ~
)UU~ 
;	UU Ä
RecurringJobWW 
.WW 
AddOrUpdateWW 
<WW 
ExchangeRateSyncJobWW ,
>WW, -
(WW- .
$strWW. B
,WWB C
jobWWD G
=>WWH J
jobWWK N
.WWN O
	SyncAsyncWWO X
(WWX Y
CancellationTokenWWY j
.WWj k
NoneWWk o
)WWo p
,WWp q
CronWWr v
.WWv w
DailyWWw |
(WW| }
$numWW} 
)	WW Ä
)
WWÄ Å
;
WWÅ Ç
RecurringJobZZ 
.ZZ 
AddOrUpdateZZ 
<ZZ 
RecurringExpenseJobZZ ,
>ZZ, -
(ZZ- .
$strZZ. B
,ZZB C
jobZZD G
=>ZZH J
jobZZK N
.ZZN O
GenerateAsyncZZO \
(ZZ\ ]
CancellationTokenZZ] n
.ZZn o
NoneZZo s
)ZZs t
,ZZt u
CronZZv z
.ZZz {
Daily	ZZ{ Ä
(
ZZÄ Å
$num
ZZÅ É
)
ZZÉ Ñ
)
ZZÑ Ö
;
ZZÖ Ü
RecurringJob\\ 
.\\ 
AddOrUpdate\\ 
<\\ &
GitHubProjectStatusSyncJob\\ 3
>\\3 4
(\\4 5
$str\\5 L
,\\L M
job\\N Q
=>\\R T
job\\U X
.\\X Y
	SyncAsync\\Y b
(\\b c
CancellationToken\\c t
.\\t u
None\\u y
)\\y z
,\\z {
$str	\\| â
)
\\â ä
;
\\ä ã
RecurringJob^^ 
.^^ 
AddOrUpdate^^ 
<^^ 
TaxDueReminderJob^^ *
>^^* +
(^^+ ,
$str^^, ?
,^^? @
job^^A D
=>^^E G
job^^H K
.^^K L
	SendAsync^^L U
(^^U V
CancellationToken^^V g
.^^g h
None^^h l
)^^l m
,^^m n
$str^^o |
)^^| }
;^^} ~
RecurringJob__ 
.__ 
AddOrUpdate__ 
<__ #
PayPalReconciliationJob__ 0
>__0 1
(__1 2
$str__2 I
,__I J
job__K N
=>__O Q
job__R U
.__U V
ReconcileAsync__V d
(__d e
CancellationToken__e v
.__v w
None__w {
)__{ |
,__| }
Cron	__~ Ç
.
__Ç É
Hourly
__É â
)
__â ä
;
__ä ã
app`` 
.`` 
MapControllers`` 
(`` 
)`` 
;`` 
appaa 
.aa 
Runaa 
(aa 
)aa 	
;aa	 

publiccc 
partialcc 
classcc 
Programcc 
;cc â\
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
}(( ∏[
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
.55 
	DedupeKey55 "
is55# %
not55& )
null55* .
&&55/ 1
await552 7
db558 :
.55: ;
PortalNotifications55; N
.55N O
AnyAsync55O W
(55W X
x55X Y
=>55Z \
x55] ^
.55^ _
	DedupeKey55_ h
==55i k
notification55l x
.55x y
	DedupeKey	55y Ç
,
55Ç É
cancellationToken
55Ñ ï
)
55ï ñ
)
55ñ ó
return
55ò û
;
55û ü
if66 

(66 
!66 
await66 
db66 
.66 
Clients66 
.66 
AnyAsync66 &
(66& '
x66' (
=>66) +
x66, -
.66- .
Id66. 0
==661 3
clientId664 <
,66< =
cancellationToken66> O
)66O P
)66P Q
return66R X
;66X Y
db77 

.77
 
PortalNotifications77 
.77 
Add77 "
(77" #
new77# &
PortalNotification77' 9
{88 	
ClientId99 
=99 
clientId99 
,99  
Type99! %
=99& '
notification99( 4
.994 5
Type995 9
.999 :
ToString99: B
(99B C
)99C D
,99D E
	DedupeKey99F O
=99P Q
notification99R ^
.99^ _
	DedupeKey99_ h
,99h i
ForStaff:: 
=:: 
notification:: #
.::# $
Type::$ (
is::) +
NotificationType::, <
.::< =
TicketCreated::= J
or::K M
NotificationType::N ^
.::^ _
TransferRequested::_ p
or::q s
NotificationType	::t Ñ
.
::Ñ Ö
TransferReported
::Ö ï
,
::ï ñ
DataJson;; 
=;; 
JsonSerializer;; %
.;;% &
	Serialize;;& /
(;;/ 0
notification;;0 <
.;;< =
Data;;= A
.;;A B
Where;;B G
(;;G H
x;;H I
=>;;J L
x;;M N
.;;N O
Key;;O R
!=;;S U
$str;;V a
);;a b
.;;b c
ToDictionary;;c o
(;;o p
);;p q
);;q r
,;;r s
}<< 	
)<<	 

;<<
 
await== 
db== 
.== 
SaveChangesAsync== !
(==! "
cancellationToken==" 3
)==3 4
;==4 5
}>> 
public@@ 

static@@ 
Task@@ 
<@@ 
bool@@ 
>@@ 
AlreadySentAsync@@ -
(@@- .
RtresDbContext@@. <
db@@= ?
,@@? @
string@@A G
	dedupeKey@@H Q
,@@Q R
CancellationToken@@S d
cancellationToken@@e v
)@@v w
=>@@x z
dbAA 

.AA
 
NotificationLogsAA 
.AA 
AnyAsyncAA $
(AA$ %
xAA% &
=>AA' )
xAA* +
.AA+ ,
	DedupeKeyAA, 5
==AA6 8
	dedupeKeyAA9 B
&&AAC E
xAAF G
.AAG H
SuccessAAH O
,AAO P
cancellationTokenAAQ b
)AAb c
;AAc d
}BB 
publicDD 
sealedDD 
classDD $
QueuedNotificationSenderDD ,
(DD, - 
IBackgroundJobClientDD- A
jobsDDB F
)DDF G
:DDH I
INotificationSenderDDJ ]
{EE 
publicFF 

TaskFF 
	SendAsyncFF 
(FF 
ClientFF  
clientFF! '
,FF' (
NotificationFF) 5
notificationFF6 B
,FFB C
CancellationTokenFFD U
cancellationTokenFFV g
=FFh i
defaultFFj q
)FFq r
{GG 
varII 
keyedII 
=II 
notificationII  
.II  !
	DedupeKeyII! *
isII+ -
nullII. 2
?II3 4
notificationII5 A
withIIB F
{IIG H
	DedupeKeyIII R
=IIS T
$"IIU W
$strIIW \
{II\ ]
GuidII] a
.IIa b
NewGuidIIb i
(IIi j
)IIj k
:IIk l
$strIIl m
}IIm n
"IIn o
}IIp q
:IIr s
notification	IIt Ä
;
IIÄ Å
jobsJJ 
.JJ 
EnqueueJJ 
<JJ 
NotificationJobJJ $
>JJ$ %
(JJ% &
jJJ& '
=>JJ( *
jJJ+ ,
.JJ, -
	SendAsyncJJ- 6
(JJ6 7
clientJJ7 =
.JJ= >
IdJJ> @
,JJ@ A
keyedJJB G
,JJG H
CancellationTokenJJI Z
.JJZ [
NoneJJ[ _
)JJ_ `
)JJ` a
;JJa b
returnKK 
TaskKK 
.KK 
CompletedTaskKK !
;KK! "
}LL 
}MM Ø
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
}]] ‰¡
NC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\TaxCalendarController.cs
	namespace		 	
Rtres		
 
.		 
Api		 
.		 
Controllers		 
;		  
[ 
ApiController 
, 
	Authorize 
( 
Roles 
=  !
$str" .
). /
,/ 0
Route1 6
(6 7
$str7 O
)O P
]P Q
public 
sealed 
class !
TaxCalendarController )
() *
RtresDbContext* 8
db9 ;
); <
:= >
ControllerBase? M
{ 
[ 
HttpGet 
] 
public 

async 
Task 
< 
ActionResult "
>" #
Get$ '
(' (
int( +
?+ ,
year- 1
,1 2
CancellationToken3 D
ctE G
)G H
=>I K
OkL N
(N O
awaitO T
GetAsyncU ]
(] ^
year^ b
,b c
DateTimed l
.l m
UtcNowm s
,s t
ctu w
)w x
)x y
;y z
internal 
async 
Task 
< 
TaxCalendarDto &
>& '
GetAsync( 0
(0 1
int1 4
?4 5
year6 :
,: ;
DateTime< D
utcNowE K
,K L
CancellationTokenM ^
ct_ a
)a b
{ 
var 
settings 
= 
await 
db 
.  
TaxSettings  +
.+ ,
FirstOrDefaultAsync, ?
(? @
ct@ B
)B C
??D F
newG J
TaxSettingsK V
(V W
)W X
;X Y
var 
today 
= 
TaxDueReminderJob %
.% &
	LimaToday& /
(/ 0
utcNow0 6
)6 7
;7 8
var 
selected 
= 
year 
?? 
today $
.$ %
Year% )
;) *
var 
years 
= 
await 
db 
. 
TaxDueDates (
.( )
Select) /
(/ 0
x0 1
=>2 4
x5 6
.6 7
Period7 =
.= >
Year> B
)B C
.C D
DistinctD L
(L M
)M N
.N O
OrderByO V
(V W
xW X
=>Y [
x\ ]
)] ^
.^ _
ToListAsync_ j
(j k
ctk m
)m n
;n o
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
.4 5
Period5 ;
.; <
Year< @
==A C
selectedD L
)L M
.M N
OrderByN U
(U V
xV W
=>X Z
x[ \
.\ ]
Period] c
)c d
.d e
ToListAsynce p
(p q
ctq s
)s t
;t u
var 
pending 
= 
( 
await 
db 
.  
TaxDueDates  +
.+ ,
Where, 1
(1 2
x2 3
=>4 6
x7 8
.8 9
FiledAt9 @
==A C
nullD H
)H I
.I J
OrderByJ Q
(Q R
xR S
=>T V
xW X
.X Y
PeriodY _
)_ `
.` a
ToListAsynca l
(l m
ctm o
)o p
)p q
. 
Select 
( 
x 
=> 
( 
Row 
: 
x  
,  !
Due" %
:% &
x' (
.( )
DueFor) /
(/ 0
settings0 8
.8 9
Ruc9 <
,< =
settings> F
.F G
IsGoodTaxpayerG U
)U V
)V W
)W X
.X Y
WhereY ^
(^ _
x_ `
=>a c
xd e
.e f
Duef i
isj l
notm p
nullq u
)u v
.v w
ToListw }
(} ~
)~ 
;	 Ä
var 
next 
= 
pending 
. 
FirstOrDefault )
() *
x* +
=>, .
x/ 0
.0 1
Due1 4
>=5 7
today8 =
&&> @
xA B
.B C
RowC F
.F G
PeriodG M
<=N P
todayQ V
)V W
;W X
var   
overdue   
=   
pending   
.   
Where   #
(  # $
x  $ %
=>  & (
x  ) *
.  * +
Due  + .
<  / 0
today  1 6
)  6 7
.  7 8
Select  8 >
(  > ?
x  ? @
=>  A C
Month  D I
(  I J
x  J K
.  K L
Row  L O
.  O P
Period  P V
)  V W
)  W X
.  X Y
ToList  Y _
(  _ `
)  ` a
;  a b
return!! 
new!! 
TaxCalendarDto!! !
(!!! "
settings!!" *
.!!* +
Ruc!!+ .
,!!. /
settings!!0 8
.!!8 9
IsGoodTaxpayer!!9 G
,!!G H
today!!I N
,!!N O
selected!!P X
,!!X Y
years!!Z _
,!!_ `
rows"" 
."" 
Select"" 
("" 
x"" 
=>"" 
ToDto"" "
(""" #
x""# $
,""$ %
settings""& .
)"". /
)""/ 0
.""0 1
ToList""1 7
(""7 8
)""8 9
,""9 :
next## 
.## 
Row## 
is## 
null## 
?## 
null## #
:##$ %
ToDto##& +
(##+ ,
next##, 0
.##0 1
Row##1 4
,##4 5
settings##6 >
)##> ?
,##? @
overdue##A H
,##H I
MissingNextYear%% 
:%% 
today%% "
.%%" #
Month%%# (
==%%) +
$num%%, .
&&%%/ 1
!%%2 3
years%%3 8
.%%8 9
Contains%%9 A
(%%A B
today%%B G
.%%G H
Year%%H L
+%%M N
$num%%O P
)%%P Q
)%%Q R
;%%R S
}&& 
[)) 
HttpPut)) 
()) 
$str)) 
))) 
])) 
public** 

async** 
Task** 
<** 
ActionResult** "
>**" #
Upsert**$ *
(*** +
string**+ 1
period**2 8
,**8 9
TaxDueDateRequest**: K
request**L S
,**S T
CancellationToken**U f
ct**g i
)**i j
{++ 
if,, 

(,, 
!,, 
DateOnly,, 
.,, 
TryParseExact,, #
(,,# $
period,,$ *
+,,+ ,
$str,,- 2
,,,2 3
$str,,4 @
,,,@ A
CultureInfo,,B M
.,,M N
InvariantCulture,,N ^
,,,^ _
DateTimeStyles,,` n
.,,n o
None,,o s
,,,s t
out,,u x
var,,y |
start	,,} Ç
)
,,Ç É
)
,,É Ñ
return
,,Ö ã

BadRequest
,,å ñ
(
,,ñ ó
new
,,ó ö
{
,,õ ú
message
,,ù §
=
,,• ¶
$str
,,ß “
}
,,” ‘
)
,,‘ ’
;
,,’ ÷
DateOnly-- 
[-- 
]-- 
dates-- 
=-- 
[-- 
request-- #
.--# $
Digit0--$ *
,--* +
request--, 3
.--3 4
Digit1--4 :
,--: ;
request--< C
.--C D

Digit2And3--D N
,--N O
request--P W
.--W X

Digit4And5--X b
,--b c
request--d k
.--k l

Digit6And7--l v
,--v w
request--x 
.	-- Ä

Digit8And9
--Ä ä
,
--ä ã
request
--å ì
.
--ì î
GoodTaxpayer
--î †
]
--† °
;
--° ¢
if// 

(// 
dates// 
.// 
Any// 
(// 
d// 
=>// 
d// 
<// 
start// $
.//$ %
	AddMonths//% .
(//. /
$num/// 0
)//0 1
||//2 4
d//5 6
>=//7 9
start//: ?
.//? @
	AddMonths//@ I
(//I J
$num//J K
)//K L
)//L M
)//M N
return//O U

BadRequest//V `
(//` a
new//a d
{//e f
message//g n
=//o p
$"//q s
$str	//s ê
{
//ê ë
Month
//ë ñ
(
//ñ ó
start
//ó ú
)
//ú ù
}
//ù û
$str
//û —
"
//— “
}
//” ‘
)
//‘ ’
;
//’ ÷
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
.00 
	DayOfWeek00 &
is00' )
	DayOfWeek00* 3
.003 4
Saturday004 <
or00= ?
	DayOfWeek00@ I
.00I J
Sunday00J P
)00P Q
)00Q R
return00S Y

BadRequest00Z d
(00d e
new00e h
{00i j
message00k r
=00s t
$str	00u «
}
00» …
)
00…  
;
00  À
var11 
row11 
=11 
await11 
db11 
.11 
TaxDueDates11 &
.11& ' 
SingleOrDefaultAsync11' ;
(11; <
x11< =
=>11> @
x11A B
.11B C
Period11C I
==11J L
start11M R
,11R S
ct11T V
)11V W
;11W X
if22 

(22 
row22 
is22 
null22 
)22 
{22 
row22 
=22  
new22! $

TaxDueDate22% /
{220 1
Period222 8
=229 :
start22; @
}22A B
;22B C
db22D F
.22F G
TaxDueDates22G R
.22R S
Add22S V
(22V W
row22W Z
)22Z [
;22[ \
}22] ^
(33 	
row33	 
.33 
Digit033 
,33 
row33 
.33 
Digit133 
,33  
row33! $
.33$ %

Digit2And333% /
,33/ 0
row331 4
.334 5

Digit4And5335 ?
,33? @
row33A D
.33D E

Digit6And733E O
,33O P
row33Q T
.33T U

Digit8And933U _
,33_ `
row33a d
.33d e
GoodTaxpayer33e q
)33q r
=33s t
(33u v
request33v }
.33} ~
Digit0	33~ Ñ
,
33Ñ Ö
request
33Ü ç
.
33ç é
Digit1
33é î
,
33î ï
request
33ñ ù
.
33ù û

Digit2And3
33û ®
,
33® ©
request
33™ ±
.
33± ≤

Digit4And5
33≤ º
,
33º Ω
request
33æ ≈
.
33≈ ∆

Digit6And7
33∆ –
,
33– —
request
33“ Ÿ
.
33Ÿ ⁄

Digit8And9
33⁄ ‰
,
33‰ Â
request
33Ê Ì
.
33Ì Ó
GoodTaxpayer
33Ó ˙
)
33˙ ˚
;
33˚ ¸
await44 
db44 
.44 
SaveChangesAsync44 !
(44! "
ct44" $
)44$ %
;44% &
return55 
Ok55 
(55 
ToDto55 
(55 
row55 
,55 
await55 "
db55# %
.55% &
TaxSettings55& 1
.551 2
FirstOrDefaultAsync552 E
(55E F
ct55F H
)55H I
??55J L
new55M P
TaxSettings55Q \
(55\ ]
)55] ^
)55^ _
)55_ `
;55` a
}66 
[99 
HttpPost99 
(99 
$str99 
)99  
]99  !
public:: 

async:: 
Task:: 
<:: 
ActionResult:: "
>::" #
	MarkFiled::$ -
(::- .
Guid::. 2
id::3 5
,::5 6#
TaxPeriodPaymentRequest::7 N
?::N O
request::P W
,::W X
CancellationToken::Y j
ct::k m
)::m n
{;; 
if<< 

(<< 
request<< 
?<< 
.<< 
IgvPaid<< 
<<< 
$num<<  
||<<! #
request<<$ +
?<<+ ,
.<<, -
	RentaPaid<<- 6
<<<7 8
$num<<9 :
)<<: ;
return<<< B

BadRequest<<C M
(<<M N
new<<N Q
{<<R S
message<<T [
=<<\ ]
$str	<<^ ã
}
<<å ç
)
<<ç é
;
<<é è
var== 
row== 
=== 
await== 
db== 
.== 
TaxDueDates== &
.==& '
	FindAsync==' 0
(==0 1
[==1 2
id==2 4
]==4 5
,==5 6
ct==7 9
)==9 :
;==: ;
if==< >
(==? @
row==@ C
is==D F
null==G K
)==K L
return==M S
NotFound==T \
(==\ ]
)==] ^
;==^ _
(>> 	
row>>	 
.>> 
IgvPaid>> 
,>> 
row>> 
.>> 
	RentaPaid>> #
)>># $
=>>% &
(>>' (
request>>( /
?>>/ 0
.>>0 1
IgvPaid>>1 8
,>>8 9
request>>: A
?>>A B
.>>B C
	RentaPaid>>C L
)>>L M
;>>M N
return?? 
await?? 
SetFiledAsync?? "
(??" #
id??# %
,??% &
DateTime??' /
.??/ 0
UtcNow??0 6
,??6 7
ct??8 :
)??: ;
;??; <
}@@ 
[BB 

HttpDeleteBB 
(BB 
$strBB !
)BB! "
]BB" #
publicCC 

asyncCC 
TaskCC 
<CC 
ActionResultCC "
>CC" #
UnmarkFiledCC$ /
(CC/ 0
GuidCC0 4
idCC5 7
,CC7 8
CancellationTokenCC9 J
ctCCK M
)CCM N
{DD 
varEE 
rowEE 
=EE 
awaitEE 
dbEE 
.EE 
TaxDueDatesEE &
.EE& '
	FindAsyncEE' 0
(EE0 1
[EE1 2
idEE2 4
]EE4 5
,EE5 6
ctEE7 9
)EE9 :
;EE: ;
ifEE< >
(EE? @
rowEE@ C
isEED F
nullEEG K
)EEK L
returnEEM S
NotFoundEET \
(EE\ ]
)EE] ^
;EE^ _
(FF 	
rowFF	 
.FF 
IgvPaidFF 
,FF 
rowFF 
.FF 
	RentaPaidFF #
)FF# $
=FF% &
(FF' (
nullFF( ,
,FF, -
nullFF. 2
)FF2 3
;FF3 4
returnGG 
awaitGG 
SetFiledAsyncGG "
(GG" #
idGG# %
,GG% &
nullGG' +
,GG+ ,
ctGG- /
)GG/ 0
;GG0 1
}HH 
[KK 
HttpPostKK 
(KK 
$strKK 
)KK 
]KK 
publicLL 

asyncLL 
TaskLL 
<LL 
ActionResultLL "
>LL" #
MarkOverdueFiledLL$ 4
(LL4 5
CancellationTokenLL5 F
ctLLG I
)LLI J
{MM 
varNN 
settingsNN 
=NN 
awaitNN 
dbNN 
.NN  
TaxSettingsNN  +
.NN+ ,
FirstOrDefaultAsyncNN, ?
(NN? @
ctNN@ B
)NNB C
??NND F
newNNG J
TaxSettingsNNK V
(NNV W
)NNW X
;NNX Y
varOO 
todayOO 
=OO 
TaxDueReminderJobOO %
.OO% &
	LimaTodayOO& /
(OO/ 0
DateTimeOO0 8
.OO8 9
UtcNowOO9 ?
)OO? @
;OO@ A
varPP 
overduePP 
=PP 
(PP 
awaitPP 
dbPP 
.PP  
TaxDueDatesPP  +
.PP+ ,
WherePP, 1
(PP1 2
xPP2 3
=>PP4 6
xPP7 8
.PP8 9
FiledAtPP9 @
==PPA C
nullPPD H
&&PPI K
xPPL M
.PPM N
PeriodPPN T
<PPU V
todayPPW \
)PP\ ]
.PP] ^
ToListAsyncPP^ i
(PPi j
ctPPj l
)PPl m
)PPm n
.PPn o
WherePPo t
(PPt u
xPPu v
=>PPw y
xPPz {
.PP{ |
DueFor	PP| Ç
(
PPÇ É
settings
PPÉ ã
.
PPã å
Ruc
PPå è
,
PPè ê
settings
PPë ô
.
PPô ö
IsGoodTaxpayer
PPö ®
)
PP® ©
<
PP™ ´
today
PP¨ ±
)
PP± ≤
.
PP≤ ≥
ToList
PP≥ π
(
PPπ ∫
)
PP∫ ª
;
PPª º
foreachQQ 
(QQ 
varQQ 
rowQQ 
inQQ 
overdueQQ #
)QQ# $
rowQQ% (
.QQ( )
FiledAtQQ) 0
=QQ1 2
DateTimeQQ3 ;
.QQ; <
UtcNowQQ< B
;QQB C
awaitRR 
dbRR 
.RR 
SaveChangesAsyncRR !
(RR! "
ctRR" $
)RR$ %
;RR% &
returnSS 
OkSS 
(SS 
newSS 
{SS 
markedSS 
=SS  
overdueSS! (
.SS( )
CountSS) .
}SS/ 0
)SS0 1
;SS1 2
}TT 
privateVV 
asyncVV 
TaskVV 
<VV 
ActionResultVV #
>VV# $
SetFiledAsyncVV% 2
(VV2 3
GuidVV3 7
idVV8 :
,VV: ;
DateTimeVV< D
?VVD E
filedAtVVF M
,VVM N
CancellationTokenVVO `
ctVVa c
)VVc d
{WW 
varXX 
rowXX 
=XX 
awaitXX 
dbXX 
.XX 
TaxDueDatesXX &
.XX& '
	FindAsyncXX' 0
(XX0 1
[XX1 2
idXX2 4
]XX4 5
,XX5 6
ctXX7 9
)XX9 :
;XX: ;
ifXX< >
(XX? @
rowXX@ C
isXXD F
nullXXG K
)XXK L
returnXXM S
NotFoundXXT \
(XX\ ]
)XX] ^
;XX^ _
rowYY 
.YY 
FiledAtYY 
=YY 
filedAtYY 
;YY 
awaitYY $
dbYY% '
.YY' (
SaveChangesAsyncYY( 8
(YY8 9
ctYY9 ;
)YY; <
;YY< =
returnZZ 
OkZZ 
(ZZ 
ToDtoZZ 
(ZZ 
rowZZ 
,ZZ 
awaitZZ "
dbZZ# %
.ZZ% &
TaxSettingsZZ& 1
.ZZ1 2
FirstOrDefaultAsyncZZ2 E
(ZZE F
ctZZF H
)ZZH I
??ZZJ L
newZZM P
TaxSettingsZZQ \
(ZZ\ ]
)ZZ] ^
)ZZ^ _
)ZZ_ `
;ZZ` a
}[[ 
private]] 
static]] 
string]] 
Month]] 
(]]  
DateOnly]]  (
period]]) /
)]]/ 0
=>]]1 3
period]]4 :
.]]: ;
ToString]]; C
(]]C D
$str]]D O
,]]O P
CultureInfo]]Q \
.]]\ ]
GetCultureInfo]]] k
(]]k l
$str]]l s
)]]s t
)]]t u
.]]u v
ToLowerInvariant	]]v Ü
(
]]Ü á
)
]]á à
;
]]à â
private__ 
static__ 
TaxDueDateDto__  
ToDto__! &
(__& '

TaxDueDate__' 1
x__2 3
,__3 4
TaxSettings__5 @
settings__A I
)__I J
=>__K M
new__N Q
(__Q R
x__R S
.__S T
Id__T V
,__V W
x__X Y
.__Y Z
Period__Z `
.__` a
ToString__a i
(__i j
$str__j s
,__s t
CultureInfo	__u Ä
.
__Ä Å
InvariantCulture
__Å ë
)
__ë í
,
__í ì
x`` 	
.``	 

Digit0``
 
,`` 
x`` 
.`` 
Digit1`` 
,`` 
x`` 
.`` 

Digit2And3`` (
,``( )
x``* +
.``+ ,

Digit4And5``, 6
,``6 7
x``8 9
.``9 :

Digit6And7``: D
,``D E
x``F G
.``G H

Digit8And9``H R
,``R S
x``T U
.``U V
GoodTaxpayer``V b
,``b c
x``d e
.``e f
DueFor``f l
(``l m
settings``m u
.``u v
Ruc``v y
,``y z
settings	``{ É
.
``É Ñ
IsGoodTaxpayer
``Ñ í
)
``í ì
,
``ì î
x
``ï ñ
.
``ñ ó
FiledAt
``ó û
,
``û ü
x
``† °
.
``° ¢
IgvPaid
``¢ ©
,
``© ™
x
``´ ¨
.
``¨ ≠
	RentaPaid
``≠ ∂
)
``∂ ∑
;
``∑ ∏
}aa 
publiccc 
sealedcc 
recordcc 
TaxDueDateRequestcc &
(cc& '
DateOnlycc' /
Digit0cc0 6
,cc6 7
DateOnlycc8 @
Digit1ccA G
,ccG H
DateOnlyccI Q

Digit2And3ccR \
,cc\ ]
DateOnlycc^ f

Digit4And5ccg q
,ccq r
DateOnlyccs {

Digit6And7	cc| Ü
,
ccÜ á
DateOnly
ccà ê

Digit8And9
ccë õ
,
ccõ ú
DateOnly
ccù •
GoodTaxpayer
cc¶ ≤
)
cc≤ ≥
;
cc≥ ¥
publicdd 
sealeddd 
recorddd 
TaxDueDateDtodd "
(dd" #
Guiddd# '
Iddd( *
,dd* +
stringdd, 2
Perioddd3 9
,dd9 :
DateOnlydd; C
Digit0ddD J
,ddJ K
DateOnlyddL T
Digit1ddU [
,dd[ \
DateOnlydd] e

Digit2And3ddf p
,ddp q
DateOnlyddr z

Digit4And5	dd{ Ö
,
ddÖ Ü
DateOnly
ddá è

Digit6And7
ddê ö
,
ddö õ
DateOnly
ddú §

Digit8And9
dd• Ø
,
ddØ ∞
DateOnly
dd± π
GoodTaxpayer
dd∫ ∆
,
dd∆ «
DateOnly
dd» –
?
dd– —
DueDate
dd“ Ÿ
,
ddŸ ⁄
DateTime
dd€ „
?
dd„ ‰
FiledAt
ddÂ Ï
,
ddÏ Ì
decimal
ddÓ ı
?
ddı ˆ
IgvPaid
dd˜ ˛
=
ddˇ Ä
null
ddÅ Ö
,
ddÖ Ü
decimal
ddá é
?
ddé è
	RentaPaid
ddê ô
=
ddö õ
null
ddú †
)
dd† °
;
dd° ¢
publicee 
sealedee 
recordee #
TaxPeriodPaymentRequestee ,
(ee, -
decimalee- 4
?ee4 5
IgvPaidee6 =
,ee= >
decimalee? F
?eeF G
	RentaPaideeH Q
)eeQ R
;eeR S
publicff 
sealedff 
recordff 
TaxCalendarDtoff #
(ff# $
stringff$ *
?ff* +
Rucff, /
,ff/ 0
boolff1 5
IsGoodTaxpayerff6 D
,ffD E
DateOnlyffF N
TodayffO T
,ffT U
intffV Y
YearffZ ^
,ff^ _
Listff` d
<ffd e
intffe h
>ffh i
Yearsffj o
,ffo p
Listffq u
<ffu v
TaxDueDateDto	ffv É
>
ffÉ Ñ
Rows
ffÖ â
,
ffâ ä
TaxDueDateDto
ffã ò
?
ffò ô
Next
ffö û
,
ffû ü
List
ff† §
<
ff§ •
string
ff• ´
>
ff´ ¨
Overdue
ff≠ ¥
,
ff¥ µ
bool
ff∂ ∫
MissingNextYear
ffª  
)
ff  À
;
ffÀ Ãèj
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
GG˛ ˇπù
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
;{{_ `
return|| 
Created|| 
(|| 
$"|| 
$str|| &
{||& '
ticket||' -
.||- .
Id||. 0
}||0 1
"||1 2
,||2 3
ticket||4 :
)||: ;
;||; <
}}} 
[
ÇÇ 
HttpGet
ÇÇ 
(
ÇÇ 
$str
ÇÇ 
)
ÇÇ 
]
ÇÇ 
public
ÉÉ 

async
ÉÉ 
Task
ÉÉ 
<
ÉÉ 
IActionResult
ÉÉ #
>
ÉÉ# $
Notifications
ÉÉ% 2
(
ÉÉ2 3
Guid
ÉÉ3 7
?
ÉÉ7 8
clientId
ÉÉ9 A
,
ÉÉA B
CancellationToken
ÉÉC T
ct
ÉÉU W
)
ÉÉW X
{
ÑÑ 
var
ÖÖ 
query
ÖÖ 
=
ÖÖ 
db
ÖÖ 
.
ÖÖ !
PortalNotifications
ÖÖ *
.
ÖÖ* +
AsQueryable
ÖÖ+ 6
(
ÖÖ6 7
)
ÖÖ7 8
;
ÖÖ8 9
if
ÜÜ 

(
ÜÜ 
!
ÜÜ 
(
ÜÜ 
IsSuperAdmin
ÜÜ 
&&
ÜÜ 
clientId
ÜÜ &
is
ÜÜ' )
null
ÜÜ* .
)
ÜÜ. /
)
ÜÜ/ 0
{
áá 	
var
àà 
error
àà 
=
àà 
ResolveClientId
àà '
(
àà' (
clientId
àà( 0
,
àà0 1
out
àà2 5
var
àà6 9
id
àà: <
)
àà< =
;
àà= >
if
àà? A
(
ààB C
error
ààC H
is
ààI K
not
ààL O
null
ààP T
)
ààT U
return
ààV \
error
àà] b
;
ààb c
query
ââ 
=
ââ 
query
ââ 
.
ââ 
Where
ââ 
(
ââ  
x
ââ  !
=>
ââ" $
x
ââ% &
.
ââ& '
ClientId
ââ' /
==
ââ0 2
id
ââ3 5
&&
ââ6 8
!
ââ9 :
x
ââ: ;
.
ââ; <
ForStaff
ââ< D
)
ââD E
;
ââE F
}
ää 	
var
ãã 
seenAt
ãã 
=
ãã 
await
ãã 
db
ãã 
.
ãã 
UserAccounts
ãã *
.
ãã* +
Where
ãã+ 0
(
ãã0 1
x
ãã1 2
=>
ãã3 5
x
ãã6 7
.
ãã7 8
Id
ãã8 :
==
ãã; =
UserId
ãã> D
)
ããD E
.
ããE F
Select
ããF L
(
ããL M
x
ããM N
=>
ããO Q
x
ããR S
.
ããS T!
NotificationsSeenAt
ããT g
)
ããg h
.
ããh i"
SingleOrDefaultAsync
ããi }
(
ãã} ~
ctãã~ Ä
)ããÄ Å
;ããÅ Ç
var
åå 
unread
åå 
=
åå 
await
åå 
query
åå  
.
åå  !

CountAsync
åå! +
(
åå+ ,
x
åå, -
=>
åå. 0
seenAt
åå1 7
==
åå8 :
null
åå; ?
||
åå@ B
x
ååC D
.
ååD E
	CreatedAt
ååE N
>
ååO P
seenAt
ååQ W
,
ååW X
ct
ååY [
)
åå[ \
;
åå\ ]
var
çç 
rows
çç 
=
çç 
await
çç 
query
çç 
.
çç 
OrderByDescending
çç 0
(
çç0 1
x
çç1 2
=>
çç3 5
x
çç6 7
.
çç7 8
	CreatedAt
çç8 A
)
ççA B
.
ççB C
Take
ççC G
(
ççG H
$num
ççH J
)
ççJ K
.
éé 
Select
éé 
(
éé 
x
éé 
=>
éé 
new
éé 
{
éé 
x
éé  
.
éé  !
Id
éé! #
,
éé# $
x
éé% &
.
éé& '
ClientId
éé' /
,
éé/ 0
x
éé1 2
.
éé2 3
Type
éé3 7
,
éé7 8
x
éé9 :
.
éé: ;
ForStaff
éé; C
,
ééC D
x
ééE F
.
ééF G
DataJson
ééG O
,
ééO P
x
ééQ R
.
ééR S
	CreatedAt
ééS \
,
éé\ ]
Company
éé^ e
=
ééf g
db
ééh j
.
ééj k
Clients
éék r
.
éér s
Where
éés x
(
ééx y
c
ééy z
=>
éé{ }
c
éé~ 
.éé Ä
IdééÄ Ç
==ééÉ Ö
xééÜ á
.ééá à
ClientIdééà ê
)ééê ë
.ééë í
Selectééí ò
(ééò ô
cééô ö
=>ééõ ù
cééû ü
.ééü †
CompanyNameéé† ´
)éé´ ¨
.éé¨ ≠
FirstOrDefaultéé≠ ª
(ééª º
)ééº Ω
}ééæ ø
)ééø ¿
.
èè 
ToListAsync
èè 
(
èè 
ct
èè 
)
èè 
;
èè 
var
êê 
items
êê 
=
êê 
rows
êê 
.
êê 
Select
êê 
(
êê  
x
êê  !
=>
êê" $
new
êê% (
{
êê) *
id
êê+ -
=
êê. /
x
êê0 1
.
êê1 2
Id
êê2 4
,
êê4 5
clientId
êê6 >
=
êê? @
x
êêA B
.
êêB C
ClientId
êêC K
,
êêK L
company
êêM T
=
êêU V
x
êêW X
.
êêX Y
Company
êêY `
,
êê` a
type
êêb f
=
êêg h
x
êêi j
.
êêj k
Type
êêk o
,
êêo p
forStaff
êêq y
=
êêz {
x
êê| }
.
êê} ~
ForStaffêê~ Ü
,êêÜ á
	createdAtêêà ë
=êêí ì
xêêî ï
.êêï ñ
	CreatedAtêêñ ü
,êêü †
unreadêê° ß
=êê® ©
seenAtêê™ ∞
==êê± ≥
nullêê¥ ∏
||êêπ ª
xêêº Ω
.êêΩ æ
	CreatedAtêêæ «
>êê» …
seenAtêê  –
,êê– —
dataêê“ ÷
=êê◊ ÿ
JsonSerializerêêŸ Á
.êêÁ Ë
DeserializeêêË Û
<êêÛ Ù

DictionaryêêÙ ˛
<êê˛ ˇ
stringêêˇ Ö
,êêÖ Ü
stringêêá ç
>êêç é
>êêé è
(êêè ê
xêêê ë
.êêë í
DataJsonêêí ö
)êêö õ
??êêú û
[êêü †
]êê† °
}êê¢ £
)êê£ §
;êê§ •
return
ëë 
Ok
ëë 
(
ëë 
new
ëë 
{
ëë 
items
ëë 
,
ëë 
unread
ëë %
}
ëë& '
)
ëë' (
;
ëë( )
}
íí 
[
îî 
HttpPost
îî 
(
îî 
$str
îî "
)
îî" #
]
îî# $
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
ïï# $
NotificationsSeen
ïï% 6
(
ïï6 7
CancellationToken
ïï7 H
ct
ïïI K
)
ïïK L
{
ññ 
var
óó 
user
óó 
=
óó 
await
óó 
db
óó 
.
óó 
UserAccounts
óó (
.
óó( )"
SingleOrDefaultAsync
óó) =
(
óó= >
x
óó> ?
=>
óó@ B
x
óóC D
.
óóD E
Id
óóE G
==
óóH J
UserId
óóK Q
,
óóQ R
ct
óóS U
)
óóU V
;
óóV W
if
óóX Z
(
óó[ \
user
óó\ `
is
óóa c
null
óód h
)
óóh i
return
óój p
NotFound
óóq y
(
óóy z
)
óóz {
;
óó{ |
user
òò 
.
òò !
NotificationsSeenAt
òò  
=
òò! "
DateTime
òò# +
.
òò+ ,
UtcNow
òò, 2
;
òò2 3
await
òò4 9
db
òò: <
.
òò< =
SaveChangesAsync
òò= M
(
òòM N
ct
òòN P
)
òòP Q
;
òòQ R
return
òòS Y
	NoContent
òòZ c
(
òòc d
)
òòd e
;
òòe f
}
ôô 
private
õõ 
async
õõ 
Task
õõ %
NotifyPortalTicketAsync
õõ .
(
õõ. /
Ticket
õõ/ 5
ticket
õõ6 <
,
õõ< =
Project
õõ> E
project
õõF M
,
õõM N
CancellationToken
õõO `
ct
õõa c
)
õõc d
{
úú 
var
ùù 

staffEmail
ùù 
=
ùù 
configuration
ùù &
[
ùù& '
$str
ùù' A
]
ùùA B
is
ùùC E
{
ùùF G
Length
ùùH N
:
ùùN O
>
ùùP Q
$num
ùùR S
}
ùùT U

configured
ùùV `
?
ùùa b

configured
ùùc m
:
ùùn o
configuration
ùùp }
[
ùù} ~
$strùù~ â
]ùùâ ä
;ùùä ã
if
ûû 

(
ûû 
string
ûû 
.
ûû  
IsNullOrWhiteSpace
ûû %
(
ûû% &

staffEmail
ûû& 0
)
ûû0 1
)
ûû1 2
{
ûû3 4
logger
ûû5 ;
.
ûû; <

LogWarning
ûû< F
(
ûûF G
$strûûG à
,ûûà â
ticketûûä ê
.ûûê ë
Codeûûë ï
)ûûï ñ
;ûûñ ó
returnûûò û
;ûûû ü
}ûû† °
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
üü< >
ticket
üü? E
.
üüE F
ClientId
üüF N
,
üüN O
ct
üüP R
)
üüR S
;
üüS T
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
††O P
TicketCreated
††P ]
,
††] ^
new
††_ b
(
††b c
)
††c d
{
††e f
[
††g h
$str
††h r
]
††r s
=
††t u
ticket
††v |
.
††| }
Id
††} 
.†† Ä
ToString††Ä à
(††à â
)††â ä
,††ä ã
[††å ç
$str††ç ì
]††ì î
=††ï ñ
ticket††ó ù
.††ù û
Code††û ¢
,††¢ £
[††§ •
$str††• ¨
]††¨ ≠
=††Æ Ø
ticket††∞ ∂
.††∂ ∑
Title††∑ º
,††º Ω
[††æ ø
$str††ø »
]††» …
=††  À
client††Ã “
.††“ ”
CompanyName††” ﬁ
,††ﬁ ﬂ
[††‡ ·
$str††· Í
]††Í Î
=††Ï Ì
project††Ó ı
.††ı ˆ
Name††ˆ ˙
,††˙ ˚
[††¸ ˝
$str††˝ É
]††É Ñ
=††Ö Ü
ticket††á ç
.††ç é
Description††é ô
}††ö õ
,††õ ú
$"††ù ü
$str††ü Æ
{††Æ Ø
ticket††Ø µ
.††µ ∂
Id††∂ ∏
}††∏ π
"††π ∫
,††∫ ª

staffEmail††º ∆
)††∆ «
,††« »
ct††… À
)††À Ã
;††Ã Õ
}
°° 
}¢¢ √∫
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PaymentsController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
Route 
( 
$str 
) 
] 
public 
sealed 
class 
PaymentsController &
(& '
RtresDbContext' 5
db6 8
,8 9
IPayPalClient: G
payPalH N
,N O!
PayPalCheckoutServiceP e
checkoutServicef u
,u v!
PayPalPaymentService	w ã
payments
å î
,
î ï!
BankTransferService
ñ ©
	transfers
™ ≥
,
≥ ¥!
INotificationSender
µ »
notifications
… ÷
,
÷ ◊
IConfiguration
ÿ Ê
configuration
Á Ù
,
Ù ı
ILogger
ˆ ˝
<
˝ ˛ 
PaymentsController
˛ ê
>
ê ë
logger
í ò
)
ò ô
:
ö õ
ControllerBase
ú ™
{ 
public 

const 
int 
RenewalWindowDays &
=' (
$num) +
;+ ,
private 
IActionResult 
? 
ClientScope &
(& '
Guid' +
?+ ,
	requested- 6
,6 7
out8 ;
Guid< @
clientIdA I
)I J
{ 
clientId 
= 
Guid 
. 
Empty 
; 
if 

( 
User 
. 
IsInRole 
( 
nameof  
(  !
UserRole! )
.) *

SuperAdmin* 4
)4 5
)5 6
)6 7
{8 9
if: <
(= >
	requested> G
isH J
notK N
GuidO S
valueT Y
)Y Z
return[ a

BadRequestb l
(l m
newm p
{q r
messages z
={ |
$str	} ß
}
® ©
)
© ™
;
™ ´
clientId
¨ ¥
=
µ ∂
value
∑ º
;
º Ω
return
æ ƒ
null
≈ …
;
…  
}
À Ã
return 
Guid 
. 
TryParse 
( 
User !
.! "
FindFirstValue" 0
(0 1
$str1 <
)< =
,= >
out? B
clientIdC K
)K L
?M N
nullO S
:T U
ForbidV \
(\ ]
)] ^
;^ _
} 
[ 
	Authorize 
, 
HttpGet 
( 
$str *
)* +
]+ ,
public 

async 
Task 
< 
IActionResult #
># $
Catalog% ,
(, -
CancellationToken- >
ct? A
)A B
{ 
var 
client 
= 
Guid 
. 
TryParse "
(" #
User# '
.' (
FindFirstValue( 6
(6 7
$str7 B
)B C
,C D
outE H
varI L
clientIdM U
)U V
?W X
awaitY ^
db_ a
.a b
Clientsb i
.i j 
SingleOrDefaultAsyncj ~
(~ 
x	 Ä
=>
Å É
x
Ñ Ö
.
Ö Ü
Id
Ü à
==
â ã
clientId
å î
,
î ï
ct
ñ ò
)
ò ô
:
ö õ
null
ú †
;
† °
var 
igvRate 
= 
await 
db 
. 
IgvRateAsync +
(+ ,
ct, .
). /
;/ 0
var   
products   
=   
await   
db   
.    
Products    (
.  ( )
Where  ) .
(  . /
x  / 0
=>  1 3
x  4 5
.  5 6
IsActive  6 >
)  > ?
.  ? @
OrderBy  @ G
(  G H
x  H I
=>  J L
x  M N
.  N O
Name  O S
)  S T
.  T U
ToListAsync  U `
(  ` a
ct  a c
)  c d
;  d e
return!! 
Ok!! 
(!! 
products!! 
.!! 
Select!! !
(!!! "
x!!" #
=>!!$ &
new!!' *
{!!+ ,
id!!- /
=!!0 1
x!!2 3
.!!3 4
Id!!4 6
,!!6 7
type!!8 <
=!!= >
x!!? @
.!!@ A
Type!!A E
,!!E F
name!!G K
=!!L M
x!!N O
.!!O P
Name!!P T
,!!T U
billingCycle!!V b
=!!c d
x!!e f
.!!f g
BillingCycle!!g s
,!!s t
	basePrice!!u ~
=	!! Ä
x
!!Å Ç
.
!!Ç É
	BasePrice
!!É å
,
!!å ç
currency
!!é ñ
=
!!ó ò
x
!!ô ö
.
!!ö õ
Currency
!!õ £
,
!!£ §
description
!!• ∞
=
!!± ≤
x
!!≥ ¥
.
!!¥ µ
Description
!!µ ¿
,
!!¿ ¡
category
!!¬  
=
!!À Ã
x
!!Õ Œ
.
!!Œ œ
Category
!!œ ◊
,
!!◊ ÿ
tags
!!Ÿ ›
=
!!ﬁ ﬂ
x
!!‡ ·
.
!!· ‚
Tags
!!‚ Ê
,
!!Ê Á
allowsTickets
!!Ë ı
=
!!ˆ ˜
x
!!¯ ˘
.
!!˘ ˙
AllowsTickets
!!˙ á
,
!!á à
isActive
!!â ë
=
!!í ì
x
!!î ï
.
!!ï ñ
IsActive
!!ñ û
,
!!û ü
igvRate
!!† ß
=
!!® ©
client
!!™ ∞
is
!!± ≥
null
!!¥ ∏
?
!!π ∫
$num
!!ª Ω
:
!!æ ø"
ClientProductPricing
!!¿ ‘
.
!!‘ ’

IgvRateFor
!!’ ﬂ
(
!!ﬂ ‡
client
!!‡ Ê
,
!!Ê Á
x
!!Ë È
,
!!È Í
igvRate
!!Î Ú
)
!!Ú Û
}
!!Ù ı
)
!!ı ˆ
)
!!ˆ ˜
;
!!˜ ¯
}"" 
[$$ 
	Authorize$$ 
($$ 
Roles$$ 
=$$ 
$str$$ &
)$$& '
,$$' (
HttpPost$$) 1
($$1 2
$str$$2 A
)$$A B
]$$B C
public%% 

async%% 
Task%% 
<%% 
IActionResult%% #
>%%# $
	Subscribe%%% .
(%%. /
SubscribeRequest%%/ ?
request%%@ G
,%%G H
CancellationToken%%I Z
ct%%[ ]
)%%] ^
{&& 
var'' 
scope'' 
='' 
ClientScope'' 
(''  
null''  $
,''$ %
out''& )
var''* -
clientId''. 6
)''6 7
;''7 8
if''9 ;
(''< =
scope''= B
is''C E
not''F I
null''J N
)''N O
return''P V
scope''W \
;''\ ]
var(( 
product(( 
=(( 
await(( 
db(( 
.(( 
Products(( '
.((' ( 
SingleOrDefaultAsync((( <
(((< =
x((= >
=>((? A
x((B C
.((C D
Id((D F
==((G I
request((J Q
.((Q R
	ProductId((R [
&&((\ ^
x((_ `
.((` a
IsActive((a i
,((i j
ct((k m
)((m n
;((n o
if)) 

()) 
product)) 
is)) 
null)) 
))) 
return)) #
NotFound))$ ,
()), -
)))- .
;)). /
var** 
	projectId** 
=** 
request** 
.**  
	ProjectId**  )
;**) *
if++ 

(++ 
	projectId++ 
is++ 
null++ 
)++ 
	projectId++ (
=++) *
(+++ ,
await++, 1
NewProjectAsync++2 A
(++A B
clientId++B J
,++J K
product++L S
.++S T
Name++T X
,++X Y
ct++Z \
)++\ ]
)++] ^
.++^ _
Id++_ a
;++a b
else,, 
if,, 
(,, 
!,, 
await,, 
db,, 
.,, 
Projects,, #
.,,# $
AnyAsync,,$ ,
(,,, -
x,,- .
=>,,/ 1
x,,2 3
.,,3 4
Id,,4 6
==,,7 9
	projectId,,: C
&&,,D F
x,,G H
.,,H I
ClientId,,I Q
==,,R T
clientId,,U ]
,,,] ^
ct,,_ a
),,a b
),,b c
return,,d j
NotFound,,k s
(,,s t
),,t u
;,,u v
if-- 

(-- 
request-- 
.-- 
BillingCycle--  
!=--! #
product--$ +
.--+ ,
BillingCycle--, 8
)--8 9
return--: @

BadRequest--A K
(--K L
new--L O
{--P Q
message--R Y
=--Z [
$str	--\ ì
}
--î ï
)
--ï ñ
;
--ñ ó
if.. 

(.. 
request.. 
... 
PaymentMethod.. !
is.." $
not..% (
(..) *
PaymentMethods..* 8
...8 9
PayPal..9 ?
or..@ B
PaymentMethods..C Q
...Q R
Transferencia..R _
).._ `
)..` a
return..b h

BadRequest..i s
(..s t
new..t w
{..x y
message	..z Å
=
..Ç É
$str
..Ñ û
}
..ü †
)
..† °
;
..° ¢
var// 
transfer// 
=// 
request// 
.// 
PaymentMethod// ,
==//- /
PaymentMethods//0 >
.//> ?
Transferencia//? L
;//L M
var00 
settings00 
=00 
await00 
	transfers00 &
.00& '
SettingsAsync00' 4
(004 5
ct005 7
)007 8
;008 9
if11 

(11 
transfer11 
?11 
!11 
settings11  
.11  !
BankTransferEnabled11! 4
:115 6
!117 8
settings118 @
.11@ A
PayPalEnabled11A N
)11N O
return11P V

BadRequest11W a
(11a b
new11b e
{11f g
message11h o
=11p q
transfer11r z
?11{ |
$str	11} ∂
:
11∑ ∏
$str
11π Î
}
11Ï Ì
)
11Ì Ó
;
11Ó Ô
var22 
item22 
=22 
new22 
ClientProduct22 $
{22% &
ClientId22' /
=220 1
clientId222 :
,22: ;
	ProjectId22< E
=22F G
	projectId22H Q
.22Q R
Value22R W
,22W X
	ProductId22Y b
=22c d
product22e l
.22l m
Id22m o
,22o p
Product22q x
=22y z
product	22{ Ç
,
22Ç É
BillingCycle
22Ñ ê
=
22ë í
request
22ì ö
.
22ö õ
BillingCycle
22õ ß
,
22ß ®
Status
22© Ø
=
22∞ ±!
ClientProductStatus
22≤ ≈
.
22≈ ∆
	Pendiente
22∆ œ
,
22œ –
Price
22— ÷
=
22◊ ÿ
product
22Ÿ ‡
.
22‡ ·
	BasePrice
22· Í
,
22Í Î
IsManualBilling
22Ï ˚
=
22¸ ˝
transfer
22˛ Ü
}
22á à
;
22à â
if33 

(33 
item33 
.33 
ValidateYears33 
(33 
request33 &
.33& '
Years33' ,
)33, -
is33. 0
string331 7

yearsError338 B
)33B C
return33D J

BadRequest33K U
(33U V
new33V Y
{33Z [
message33\ c
=33d e

yearsError33f p
}33q r
)33r s
;33s t
db44 

.44
 
ClientProducts44 
.44 
Add44 
(44 
item44 "
)44" #
;44# $
var55 
igvRate55 
=55 
await55 
db55 
.55 
IgvRateForAsync55 .
(55. /
clientId55/ 7
,557 8
product559 @
,55@ A
ct55B D
)55D E
;55E F
if77 

(77 
transfer77 
)77 
{88 	
await99 
db99 
.99 
SaveChangesAsync99 %
(99% &
ct99& (
)99( )
;99) *
await:: &
NotifyTransferRequestAsync:: ,
(::, -
item::- 1
,::1 2
product::3 :
,::: ;
igvRate::< C
,::C D
request::E L
.::L M
Years::M R
,::R S
ct::T V
)::V W
;::W X
return;; 
Ok;; 
(;; 
new;; 
{;; 
clientProductId;; +
=;;, -
item;;. 2
.;;2 3
Id;;3 5
,;;5 6
approvalUrl;;7 B
=;;C D
(;;E F
string;;F L
?;;L M
);;M N
null;;N R
,;;R S
bankTransfer;;T `
=;;a b
await;;c h
	transfers;;i r
.;;r s
	InfoAsync;;s |
(;;| }
item	;;} Å
,
;;Å Ç
igvRate
;;É ä
,
;;ä ã
request
;;å ì
.
;;ì î
Years
;;î ô
,
;;ô ö
ct
;;õ ù
)
;;ù û
}
;;ü †
)
;;† °
;
;;° ¢
}<< 	
try== 
{== 
var== 
checkout== 
=== 
await== "
checkoutService==# 2
.==2 3

StartAsync==3 =
(=== >
item==> B
,==B C
product==D K
,==K L
Request==M T
,==T U
ct==V X
,==X Y
igvRate==Z a
,==a b
request==c j
.==j k
Years==k p
)==p q
;==q r
await==s x
db==y {
.=={ |
SaveChangesAsync	==| å
(
==å ç
ct
==ç è
)
==è ê
;
==ê ë
return
==í ò
Ok
==ô õ
(
==õ ú
new
==ú ü
{
==† °
clientProductId
==¢ ±
=
==≤ ≥
item
==¥ ∏
.
==∏ π
Id
==π ª
,
==ª º
approvalUrl
==Ω »
=
==…  
checkout
==À ”
.
==” ‘
ApprovalUrl
==‘ ﬂ
}
==‡ ·
)
==· ‚
;
==‚ „
}
==‰ Â
catch
==Ê Î
(
==Ï Ì'
InvalidOperationException
==Ì Ü
ex
==á â
)
==â ä
{
==ã å
return
==ç ì

BadRequest
==î û
(
==û ü
new
==ü ¢
{
==£ §
message
==• ¨
=
==≠ Æ
ex
==Ø ±
.
==± ≤
Message
==≤ π
}
==∫ ª
)
==ª º
;
==º Ω
}
==æ ø
}>> 
privateDD 
asyncDD 
TaskDD 
<DD 
ProjectDD 
>DD 
NewProjectAsyncDD  /
(DD/ 0
GuidDD0 4
clientIdDD5 =
,DD= >
stringDD? E
productNameDDF Q
,DDQ R
CancellationTokenDDS d
ctDDe g
)DDg h
{EE 
varFF 
companyFF 
=FF 
awaitFF 
dbFF 
.FF 
ClientsFF &
.FF& '
WhereFF' ,
(FF, -
xFF- .
=>FF/ 1
xFF2 3
.FF3 4
IdFF4 6
==FF7 9
clientIdFF: B
)FFB C
.FFC D
SelectFFD J
(FFJ K
xFFK L
=>FFM O
xFFP Q
.FFQ R
CompanyNameFFR ]
)FF] ^
.FF^ _
SingleAsyncFF_ j
(FFj k
ctFFk m
)FFm n
;FFn o
varGG 
baseSlugGG 
=GG 
AdminControllerGG &
.GG& '
SlugifyGG' .
(GG. /
$"GG/ 1
{GG1 2
companyGG2 9
}GG9 :
$strGG: ;
{GG; <
productNameGG< G
}GGG H
"GGH I
)GGI J
;GGJ K
ifHH 

(HH 
baseSlugHH 
.HH 
LengthHH 
==HH 
$numHH  
)HH  !
baseSlugHH" *
=HH+ ,
$strHH- 7
;HH7 8
varII 
slugII 
=II 
baseSlugII 
;II 
forJJ 
(JJ 
varJJ 
nJJ 
=JJ 
$numJJ 
;JJ 
awaitJJ 
dbJJ  
.JJ  !
ProjectsJJ! )
.JJ) *
AnyAsyncJJ* 2
(JJ2 3
xJJ3 4
=>JJ5 7
xJJ8 9
.JJ9 :
SlugJJ: >
==JJ? A
slugJJB F
,JJF G
ctJJH J
)JJJ K
;JJK L
nJJM N
++JJN P
)JJP Q
slugJJR V
=JJW X
$"JJY [
{JJ[ \
baseSlugJJ\ d
}JJd e
$strJJe f
{JJf g
nJJg h
}JJh i
"JJi j
;JJj k
varKK 
projectKK 
=KK 
newKK 
ProjectKK !
{KK" #
ClientIdKK$ ,
=KK- .
clientIdKK/ 7
,KK7 8
NameKK9 =
=KK> ?
productNameKK@ K
,KKK L
SlugKKM Q
=KKR S
slugKKT X
}KKY Z
;KKZ [
dbLL 

.LL
 
ProjectsLL 
.LL 
AddLL 
(LL 
projectLL 
)LL  
;LL  !
returnMM 
projectMM 
;MM 
}NN 
[QQ 
	AuthorizeQQ 
,QQ 
HttpGetQQ 
(QQ 
$strQQ A
)QQA B
]QQB C
publicRR 

asyncRR 
TaskRR 
<RR 
IActionResultRR #
>RR# $
BankTransferRR% 1
(RR1 2
GuidRR2 6
idRR7 9
,RR9 :
GuidRR; ?
?RR? @
clientIdRRA I
,RRI J
CancellationTokenRRK \
ctRR] _
,RR_ `
intRRa d
yearsRRe j
=RRk l
$numRRm n
)RRn o
{SS 
varTT 
scopeTT 
=TT 
ClientScopeTT 
(TT  
clientIdTT  (
,TT( )
outTT* -
varTT. 1
ownerTT2 7
)TT7 8
;TT8 9
ifTT: <
(TT= >
scopeTT> C
isTTD F
notTTG J
nullTTK O
)TTO P
returnTTQ W
scopeTTX ]
;TT] ^
varUU 
itemUU 
=UU 
awaitUU 
dbUU 
.UU 
ClientProductsUU *
.UU* +
IncludeUU+ 2
(UU2 3
xUU3 4
=>UU5 7
xUU8 9
.UU9 :
ProductUU: A
)UUA B
.UUB C 
SingleOrDefaultAsyncUUC W
(UUW X
xUUX Y
=>UUZ \
xUU] ^
.UU^ _
IdUU_ a
==UUb d
idUUe g
&&UUh j
xUUk l
.UUl m
ClientIdUUm u
==UUv x
ownerUUy ~
,UU~ 
ct
UUÄ Ç
)
UUÇ É
;
UUÉ Ñ
ifVV 

(VV 
itemVV 
?VV 
.VV 
ProductVV 
isVV 
nullVV !
)VV! "
returnVV# )
NotFoundVV* 2
(VV2 3
)VV3 4
;VV4 5
ifWW 

(WW 
itemWW 
.WW 
ValidateYearsWW 
(WW 
yearsWW $
)WW$ %
isWW& (
stringWW) /

yearsErrorWW0 :
)WW: ;
returnWW< B

BadRequestWWC M
(WWM N
newWWN Q
{WWR S
messageWWT [
=WW\ ]

yearsErrorWW^ h
}WWi j
)WWj k
;WWk l
returnXX 
OkXX 
(XX 
awaitXX 
	transfersXX !
.XX! "
	InfoAsyncXX" +
(XX+ ,
itemXX, 0
,XX0 1
awaitXX2 7
dbXX8 :
.XX: ;
IgvRateForAsyncXX; J
(XXJ K
ownerXXK P
,XXP Q
itemXXR V
.XXV W
ProductXXW ^
,XX^ _
ctXX` b
)XXb c
,XXc d
yearsXXe j
,XXj k
ctXXl n
)XXn o
)XXo p
;XXp q
}YY 
private__ 
async__ 
Task__ &
NotifyTransferRequestAsync__ 1
(__1 2
ClientProduct__2 ?
item__@ D
,__D E
Product__F M
product__N U
,__U V
decimal__W ^
igvRate___ f
,__f g
int__h k
years__l q
,__q r
CancellationToken	__s Ñ
ct
__Ö á
)
__á à
{`` 
varaa 

staffEmailaa 
=aa 
configurationaa &
[aa& '
$straa' A
]aaA B
isaaC E
{aaF G
LengthaaH N
:aaN O
>aaP Q
$numaaR S
}aaT U

configuredaaV `
?aaa b

configuredaac m
:aan o
configurationaap }
[aa} ~
$str	aa~ â
]
aaâ ä
;
aaä ã
ifbb 

(bb 
stringbb 
.bb 
IsNullOrWhiteSpacebb %
(bb% &

staffEmailbb& 0
)bb0 1
)bb1 2
{bb3 4
loggerbb5 ;
.bb; <

LogWarningbb< F
(bbF G
$str	bbG ù
,
bbù û
item
bbü £
.
bb£ §
Id
bb§ ¶
)
bb¶ ß
;
bbß ®
return
bb© Ø
;
bbØ ∞
}
bb± ≤
varcc 
clientcc 
=cc 
awaitcc 
dbcc 
.cc 
Clientscc %
.cc% &
SingleAsynccc& 1
(cc1 2
xcc2 3
=>cc4 6
xcc7 8
.cc8 9
Idcc9 ;
==cc< >
itemcc? C
.ccC D
ClientIdccD L
,ccL M
ctccN P
)ccP Q
;ccQ R
vardd 
projectdd 
=dd 
awaitdd 
dbdd 
.dd 
Projectsdd '
.dd' (
Wheredd( -
(dd- .
xdd. /
=>dd0 2
xdd3 4
.dd4 5
Iddd5 7
==dd8 :
itemdd; ?
.dd? @
	ProjectIddd@ I
)ddI J
.ddJ K
SelectddK Q
(ddQ R
xddR S
=>ddT V
xddW X
.ddX Y
NameddY ]
)dd] ^
.dd^ _
SingleAsyncdd_ j
(ddj k
ctddk m
)ddm n
;ddn o
varee 
dataee 
=ee 
newee 

Dictionaryee !
<ee! "
stringee" (
,ee( )
stringee* 0
>ee0 1
{ee2 3
[ee4 5
$stree5 ?
]ee? @
=eeA B
clienteeC I
.eeI J
IdeeJ L
.eeL M
ToStringeeM U
(eeU V
)eeV W
,eeW X
[eeY Z
$streeZ c
]eec d
=eee f
clienteeg m
.eem n
CompanyNameeen y
,eey z
[ee{ |
$str	ee| Ö
]
eeÖ Ü
=
eeá à
years
eeâ é
>
eeè ê
$num
eeë í
?
eeì î
$"
eeï ó
{
eeó ò
product
eeò ü
.
eeü †
Name
ee† §
}
ee§ •
$str
ee• ß
{
eeß ®
years
ee® ≠
}
ee≠ Æ
$str
eeÆ ¥
"
ee¥ µ
:
ee∂ ∑
product
ee∏ ø
.
eeø ¿
Name
ee¿ ƒ
,
eeƒ ≈
[
ee∆ «
$str
ee« –
]
ee– —
=
ee“ ”
project
ee‘ €
,
ee€ ‹
[
ee› ﬁ
$str
eeﬁ Ë
]
eeË È
=
eeÍ Î
product
eeÏ Û
.
eeÛ Ù
Currency
eeÙ ¸
}
ee˝ ˛
;
ee˛ ˇ
ifff 

(ff 
itemff 
.ff 
ChargeTotalff 
(ff 
igvRateff $
,ff$ %
yearsff& +
)ff+ ,
isff- /
decimalff0 7
amountff8 >
)ff> ?
dataff@ D
[ffD E
$strffE M
]ffM N
=ffO P
amountffQ W
.ffW X
ToStringffX `
(ff` a
CultureInfoffa l
.ffl m
InvariantCultureffm }
)ff} ~
;ff~ 
awaitgg 
notificationsgg 
.gg 
	SendAsyncgg %
(gg% &
clientgg& ,
,gg, -
newgg. 1
Notificationgg2 >
(gg> ?
NotificationTypegg? O
.ggO P
TransferRequestedggP a
,gga b
dataggc g
,ggg h
$"ggi k
$strggk |
{gg| }
item	gg} Å
.
ggÅ Ç
Id
ggÇ Ñ
}
ggÑ Ö
"
ggÖ Ü
,
ggÜ á

staffEmail
ggà í
)
ggí ì
,
ggì î
ct
ggï ó
)
ggó ò
;
ggò ô
}hh 
[jj 
	Authorizejj 
(jj 
Rolesjj 
=jj 
$strjj &
)jj& '
,jj' (
HttpPostjj) 1
(jj1 2
$strjj2 S
)jjS T
]jjT U
publickk 

asynckk 
Taskkk 
<kk 
IActionResultkk #
>kk# $
Renewkk% *
(kk* +
Guidkk+ /
idkk0 2
,kk2 3
Guidkk4 8
?kk8 9
clientIdkk: B
,kkB C
CancellationTokenkkD U
ctkkV X
,kkX Y
intkkZ ]
yearskk^ c
=kkd e
$numkkf g
)kkg h
{ll 
varmm 
scopemm 
=mm 
ClientScopemm 
(mm  
clientIdmm  (
,mm( )
outmm* -
varmm. 1
ownermm2 7
)mm7 8
;mm8 9
ifmm: <
(mm= >
scopemm> C
ismmD F
notmmG J
nullmmK O
)mmO P
returnmmQ W
scopemmX ]
;mm] ^
varnn 
itemnn 
=nn 
awaitnn 
dbnn 
.nn 
ClientProductsnn *
.nn* +
Includenn+ 2
(nn2 3
xnn3 4
=>nn5 7
xnn8 9
.nn9 :
Productnn: A
)nnA B
.nnB C 
SingleOrDefaultAsyncnnC W
(nnW X
xnnX Y
=>nnZ \
xnn] ^
.nn^ _
Idnn_ a
==nnb d
idnne g
&&nnh j
xnnk l
.nnl m
ClientIdnnm u
==nnv x
ownernny ~
,nn~ 
ct
nnÄ Ç
)
nnÇ É
;
nnÉ Ñ
ifoo 

(oo 
itemoo 
?oo 
.oo 
Productoo 
isoo 
nulloo !
)oo! "
returnoo# )
NotFoundoo* 2
(oo2 3
)oo3 4
;oo4 5
varqq 
	renewableqq 
=qq 
itemqq 
.qq 
BillingCycleqq )
==qq* ,
BillingCycleqq- 9
.qq9 :
Anualqq: ?
&&qq@ B
(qqC D
itemqqD H
.qqH I
StatusqqI O
isqqP R
ClientProductStatusqqS f
.qqf g
	PorVencerqqg p
orqqq s 
ClientProductStatus	qqt á
.
qqá à
Vencido
qqà è
||
qqê í
item
qqì ó
.
qqó ò
RenewsAt
qqò †
<=
qq° £
DateTime
qq§ ¨
.
qq¨ ≠
UtcNow
qq≠ ≥
.
qq≥ ¥
AddDays
qq¥ ª
(
qqª º
RenewalWindowDays
qqº Õ
)
qqÕ Œ
)
qqŒ œ
;
qqœ –
ifrr 

(rr 
itemrr 
.rr 
IsManualBillingrr  
||rr! #
!rr$ %
(rr% &
	renewablerr& /
||rr0 2
itemrr3 7
.rr7 8
Statusrr8 >
==rr? A
ClientProductStatusrrB U
.rrU V
	PendienterrV _
)rr_ `
)rr` a
returnrrb h

BadRequestrri s
(rrs t
newrrt w
{rrx y
message	rrz Å
=
rrÇ É
$str
rrÑ ±
}
rr≤ ≥
)
rr≥ ¥
;
rr¥ µ
ifss 

(ss 
!ss 
(ss 
awaitss 
	transfersss 
.ss 
SettingsAsyncss +
(ss+ ,
ctss, .
)ss. /
)ss/ 0
.ss0 1
PayPalEnabledss1 >
)ss> ?
returnss@ F

BadRequestssG Q
(ssQ R
newssR U
{ssV W
messagessX _
=ss` a
$str	ssb î
}
ssï ñ
)
ssñ ó
;
ssó ò
trytt 
{tt 
vartt 
checkouttt 
=tt 
awaittt "
checkoutServicett# 2
.tt2 3

StartAsynctt3 =
(tt= >
itemtt> B
,ttB C
itemttD H
.ttH I
ProductttI P
,ttP Q
RequestttR Y
,ttY Z
cttt[ ]
,tt] ^
awaittt_ d
dbtte g
.ttg h
IgvRateForAsynctth w
(ttw x
ownerttx }
,tt} ~
item	tt É
.
ttÉ Ñ
Product
ttÑ ã
,
ttã å
ct
ttç è
)
ttè ê
,
ttê ë
years
ttí ó
)
ttó ò
;
ttò ô
await
ttö ü
db
tt† ¢
.
tt¢ £
SaveChangesAsync
tt£ ≥
(
tt≥ ¥
ct
tt¥ ∂
)
tt∂ ∑
;
tt∑ ∏
return
ttπ ø
Ok
tt¿ ¬
(
tt¬ √
new
tt√ ∆
{
tt« »
approvalUrl
tt… ‘
=
tt’ ÷
checkout
tt◊ ﬂ
.
ttﬂ ‡
ApprovalUrl
tt‡ Î
}
ttÏ Ì
)
ttÌ Ó
;
ttÓ Ô
}
tt Ò
catch
ttÚ ˜
(
tt¯ ˘'
InvalidOperationException
tt˘ í
ex
ttì ï
)
ttï ñ
{
ttó ò
return
ttô ü

BadRequest
tt† ™
(
tt™ ´
new
tt´ Æ
{
ttØ ∞
message
tt± ∏
=
ttπ ∫
ex
ttª Ω
.
ttΩ æ
Message
ttæ ≈
}
tt∆ «
)
tt« »
;
tt» …
}
tt  À
}uu 
[ww 
	Authorizeww 
(ww 
Rolesww 
=ww 
$strww &
)ww& '
,ww' (
HttpPostww) 1
(ww1 2
$strww2 T
)wwT U
]wwU V
publicxx 

asyncxx 
Taskxx 
<xx 
IActionResultxx #
>xx# $
Cancelxx% +
(xx+ ,
Guidxx, 0
idxx1 3
,xx3 4
Guidxx5 9
?xx9 :
clientIdxx; C
,xxC D
CancellationTokenxxE V
ctxxW Y
)xxY Z
{yy 
varzz 
scopezz 
=zz 
ClientScopezz 
(zz  
clientIdzz  (
,zz( )
outzz* -
varzz. 1
ownerzz2 7
)zz7 8
;zz8 9
ifzz: <
(zz= >
scopezz> C
iszzD F
notzzG J
nullzzK O
)zzO P
returnzzQ W
scopezzX ]
;zz] ^
var{{ 
item{{ 
={{ 
await{{ 
db{{ 
.{{ 
ClientProducts{{ *
.{{* + 
SingleOrDefaultAsync{{+ ?
({{? @
x{{@ A
=>{{B D
x{{E F
.{{F G
Id{{G I
=={{J L
id{{M O
&&{{P R
x{{S T
.{{T U
ClientId{{U ]
=={{^ `
owner{{a f
,{{f g
ct{{h j
){{j k
;{{k l
if|| 

(|| 
item|| 
is|| 
null|| 
)|| 
return||  
NotFound||! )
(||) *
)||* +
;||+ ,
if}} 

(}} 
item}} 
.}} 
IsManualBilling}}  
||}}! #
item}}$ (
.}}( )
Status}}) /
!=}}0 2
ClientProductStatus}}3 F
.}}F G
Activo}}G M
||}}N P
!}}Q R
item}}R V
.}}V W
BillingCycle}}W c
.}}c d
IsSubscription}}d r
(}}r s
)}}s t
||}}u w
string}}x ~
.}}~ 
IsNullOrWhiteSpace	}} ë
(
}}ë í
item
}}í ñ
.
}}ñ ó"
PayPalSubscriptionId
}}ó ´
)
}}´ ¨
)
}}¨ ≠
return
}}Æ ¥

BadRequest
}}µ ø
(
}}ø ¿
new
}}¿ √
{
}}ƒ ≈
message
}}∆ Õ
=
}}Œ œ
$str
}}– Ñ
}
}}Ö Ü
)
}}Ü á
;
}}á à
await~~ 
payPal~~ 
.~~ #
CancelSubscriptionAsync~~ ,
(~~, -
item~~- 1
.~~1 2 
PayPalSubscriptionId~~2 F
,~~F G
$str~~H y
,~~y z
ct~~{ }
)~~} ~
;~~~ 
item
~~Ä Ñ
.
~~Ñ Ö
Status
~~Ö ã
=
~~å ç!
ClientProductStatus
~~é °
.
~~° ¢
	Cancelado
~~¢ ´
;
~~´ ¨
await
~~≠ ≤
db
~~≥ µ
.
~~µ ∂
SaveChangesAsync
~~∂ ∆
(
~~∆ «
ct
~~« …
)
~~…  
;
~~  À
return
~~Ã “
Ok
~~” ’
(
~~’ ÷
)
~~÷ ◊
;
~~◊ ÿ
} 
[
ÇÇ 
	Authorize
ÇÇ 
(
ÇÇ 
Roles
ÇÇ 
=
ÇÇ 
$str
ÇÇ &
)
ÇÇ& '
,
ÇÇ' (
HttpPost
ÇÇ) 1
(
ÇÇ1 2
$str
ÇÇ2 U
)
ÇÇU V
]
ÇÇV W
public
ÉÉ 

async
ÉÉ 
Task
ÉÉ 
<
ÉÉ 
IActionResult
ÉÉ #
>
ÉÉ# $
Capture
ÉÉ% ,
(
ÉÉ, -
Guid
ÉÉ- 1
id
ÉÉ2 4
,
ÉÉ4 5
Guid
ÉÉ6 :
?
ÉÉ: ;
clientId
ÉÉ< D
,
ÉÉD E
CancellationToken
ÉÉF W
ct
ÉÉX Z
)
ÉÉZ [
{
ÑÑ 
var
ÖÖ 
scope
ÖÖ 
=
ÖÖ 
ClientScope
ÖÖ 
(
ÖÖ  
clientId
ÖÖ  (
,
ÖÖ( )
out
ÖÖ* -
var
ÖÖ. 1
owner
ÖÖ2 7
)
ÖÖ7 8
;
ÖÖ8 9
if
ÖÖ: <
(
ÖÖ= >
scope
ÖÖ> C
is
ÖÖD F
not
ÖÖG J
null
ÖÖK O
)
ÖÖO P
return
ÖÖQ W
scope
ÖÖX ]
;
ÖÖ] ^
var
ÜÜ 
item
ÜÜ 
=
ÜÜ 
await
ÜÜ 
db
ÜÜ 
.
ÜÜ 
ClientProducts
ÜÜ *
.
ÜÜ* +
Include
ÜÜ+ 2
(
ÜÜ2 3
x
ÜÜ3 4
=>
ÜÜ5 7
x
ÜÜ8 9
.
ÜÜ9 :
Product
ÜÜ: A
)
ÜÜA B
.
ÜÜB C"
SingleOrDefaultAsync
ÜÜC W
(
ÜÜW X
x
ÜÜX Y
=>
ÜÜZ \
x
ÜÜ] ^
.
ÜÜ^ _
Id
ÜÜ_ a
==
ÜÜb d
id
ÜÜe g
&&
ÜÜh j
x
ÜÜk l
.
ÜÜl m
ClientId
ÜÜm u
==
ÜÜv x
owner
ÜÜy ~
,
ÜÜ~ 
ctÜÜÄ Ç
)ÜÜÇ É
;ÜÜÉ Ñ
if
áá 

(
áá 
item
áá 
is
áá 
null
áá 
)
áá 
return
áá  
NotFound
áá! )
(
áá) *
)
áá* +
;
áá+ ,
try
àà 
{
àà 
await
àà 
payments
àà 
.
àà 
ConfirmAsync
àà )
(
àà) *
item
àà* .
,
àà. /
ct
àà0 2
)
àà2 3
;
àà3 4
}
àà5 6
catch
ââ 
(
ââ "
HttpRequestException
ââ #
ex
ââ$ &
)
ââ& '
{
ââ( )
logger
ââ* 0
.
ââ0 1

LogWarning
ââ1 ;
(
ââ; <
ex
ââ< >
,
ââ> ?
$strââ@ Ö
,ââÖ Ü
idââá â
)âââ ä
;ââä ã
}ââå ç
return
ää 
Ok
ää 
(
ää 
new
ää 
{
ää 
status
ää 
=
ää  
item
ää! %
.
ää% &
Status
ää& ,
.
ää, -
ToString
ää- 5
(
ää5 6
)
ää6 7
}
ää8 9
)
ää9 :
;
ää: ;
}
ãã 
[
çç 
	Authorize
çç 
(
çç 
Roles
çç 
=
çç 
$str
çç &
)
çç& '
,
çç' (
HttpGet
çç) 0
(
çç0 1
$str
çç1 L
)
ççL M
]
ççM N
public
éé 

async
éé 
Task
éé 
<
éé 
IActionResult
éé #
>
éé# $
ClientProduct
éé% 2
(
éé2 3
Guid
éé3 7
id
éé8 :
,
éé: ;
Guid
éé< @
?
éé@ A
clientId
ééB J
,
ééJ K
CancellationToken
ééL ]
ct
éé^ `
)
éé` a
{
èè 
var
êê 
scope
êê 
=
êê 
ClientScope
êê 
(
êê  
clientId
êê  (
,
êê( )
out
êê* -
var
êê. 1
owner
êê2 7
)
êê7 8
;
êê8 9
if
êê: <
(
êê= >
scope
êê> C
is
êêD F
not
êêG J
null
êêK O
)
êêO P
return
êêQ W
scope
êêX ]
;
êê] ^
var
ëë 
item
ëë 
=
ëë 
await
ëë 
db
ëë 
.
ëë 
ClientProducts
ëë *
.
ëë* +
Include
ëë+ 2
(
ëë2 3
x
ëë3 4
=>
ëë5 7
x
ëë8 9
.
ëë9 :
Product
ëë: A
)
ëëA B
.
ëëB C
Include
ëëC J
(
ëëJ K
x
ëëK L
=>
ëëM O
x
ëëP Q
.
ëëQ R
Project
ëëR Y
)
ëëY Z
.
ëëZ ["
SingleOrDefaultAsync
ëë[ o
(
ëëo p
x
ëëp q
=>
ëër t
x
ëëu v
.
ëëv w
Id
ëëw y
==
ëëz |
id
ëë} 
&&ëëÄ Ç
xëëÉ Ñ
.ëëÑ Ö
ClientIdëëÖ ç
==ëëé ê
ownerëëë ñ
,ëëñ ó
ctëëò ö
)ëëö õ
;ëëõ ú
returnëëù £
itemëë§ ®
isëë© ´
nullëë¨ ∞
?ëë± ≤
NotFoundëë≥ ª
(ëëª º
)ëëº Ω
:ëëæ ø
Okëë¿ ¬
(ëë¬ √
itemëë√ «
)ëë« »
;ëë» …
}
íí 
[
îî 
HttpPost
îî 
(
îî 
$str
îî (
)
îî( )
]
îî) *
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
ïï# $
Webhook
ïï% ,
(
ïï, -
CancellationToken
ïï- >
ct
ïï? A
)
ïïA B
{
ññ 
using
óó 
var
óó 
reader
óó 
=
óó 
new
óó 
StreamReader
óó +
(
óó+ ,
Request
óó, 3
.
óó3 4
Body
óó4 8
)
óó8 9
;
óó9 :
var
óó; >
payload
óó? F
=
óóG H
await
óóI N
reader
óóO U
.
óóU V
ReadToEndAsync
óóV d
(
óód e
ct
óóe g
)
óóg h
;
óóh i
var
óój m
headers
óón u
=
óóv w
Request
óóx 
.óó Ä
HeadersóóÄ á
.óóá à
ToDictionaryóóà î
(óóî ï
xóóï ñ
=>óóó ô
xóóö õ
.óóõ ú
Keyóóú ü
.óóü † 
ToLowerInvariantóó† ∞
(óó∞ ±
)óó± ≤
,óó≤ ≥
xóó¥ µ
=>óó∂ ∏
xóóπ ∫
.óó∫ ª
Valueóóª ¿
.óó¿ ¡
ToStringóó¡ …
(óó…  
)óó  À
)óóÀ Ã
;óóÃ Õ
if
òò 

(
òò 
!
òò 
await
òò 
payPal
òò 
.
òò  
VerifyWebhookAsync
òò ,
(
òò, -
payload
òò- 4
,
òò4 5
headers
òò6 =
,
òò= >
ct
òò? A
)
òòA B
)
òòB C
return
òòD J
Unauthorized
òòK W
(
òòW X
)
òòX Y
;
òòY Z
using
ôô 
var
ôô 
json
ôô 
=
ôô 
JsonDocument
ôô %
.
ôô% &
Parse
ôô& +
(
ôô+ ,
payload
ôô, 3
)
ôô3 4
;
ôô4 5
var
ôô6 9
root
ôô: >
=
ôô? @
json
ôôA E
.
ôôE F
RootElement
ôôF Q
;
ôôQ R
var
ôôS V
	eventType
ôôW `
=
ôôa b
Find
ôôc g
(
ôôg h
root
ôôh l
,
ôôl m
$str
ôôn z
)
ôôz {
;
ôô{ |
if
ôô} 
(ôôÄ Å
!ôôÅ Ç
rootôôÇ Ü
.ôôÜ á
TryGetPropertyôôá ï
(ôôï ñ
$strôôñ †
,ôô† °
outôô¢ •
varôô¶ ©
resourceôô™ ≤
)ôô≤ ≥
)ôô≥ ¥
returnôôµ ª
Okôôº æ
(ôôæ ø
)ôôø ¿
;ôô¿ ¡
var
öö 

resourceId
öö 
=
öö 
Find
öö 
(
öö 
resource
öö &
,
öö& '
$str
öö( ,
)
öö, -
;
öö- .
var
öö/ 2
orderId
öö3 :
=
öö; <
Nested
öö= C
(
ööC D
resource
ööD L
,
ööL M
$str
ööN b
,
ööb c
$str
ööd q
,
ööq r
$str
öös }
)
öö} ~
??öö Å

resourceIdööÇ å
;ööå ç
varööé ë
customIdööí ö
=ööõ ú
Findööù °
(öö° ¢
resourceöö¢ ™
,öö™ ´
$ströö¨ ∑
)öö∑ ∏
??ööπ ª
Findööº ¿
(öö¿ ¡
resourceöö¡ …
,öö…  
$strööÀ ”
)öö” ‘
??öö’ ◊
Findööÿ ‹
(öö‹ ›
rootöö› ·
,öö· ‚
$ströö„ Ó
)ööÓ Ô
??öö Ú
PurchaseUnitööÛ ˇ
(ööˇ Ä
resourceööÄ à
,ööà â
$strööä ï
)ööï ñ
;ööñ ó
var
úú 
subscriptionId
úú 
=
úú 
Find
úú !
(
úú! "
resource
úú" *
,
úú* +
$str
úú, B
)
úúB C
??
úúD F

resourceId
úúG Q
;
úúQ R
ClientProduct
ùù 
?
ùù 
item
ùù 
=
ùù 
Guid
ùù "
.
ùù" #
TryParse
ùù# +
(
ùù+ ,
customId
ùù, 4
,
ùù4 5
out
ùù6 9
var
ùù: =

customGuid
ùù> H
)
ùùH I
?
ùùJ K
await
ùùL Q
db
ùùR T
.
ùùT U
ClientProducts
ùùU c
.
ùùc d
Include
ùùd k
(
ùùk l
x
ùùl m
=>
ùùn p
x
ùùq r
.
ùùr s
Product
ùùs z
)
ùùz {
.
ùù{ |#
SingleOrDefaultAsyncùù| ê
(ùùê ë
xùùë í
=>ùùì ï
xùùñ ó
.ùùó ò
Idùùò ö
==ùùõ ù

customGuidùùû ®
,ùù® ©
ctùù™ ¨
)ùù¨ ≠
:ùùÆ Ø
nullùù∞ ¥
;ùù¥ µ
item
ûû 
??=
ûû 
!
ûû 
string
ûû 
.
ûû  
IsNullOrWhiteSpace
ûû +
(
ûû+ ,
orderId
ûû, 3
)
ûû3 4
?
ûû5 6
await
ûû7 <
db
ûû= ?
.
ûû? @
ClientProducts
ûû@ N
.
ûûN O
Include
ûûO V
(
ûûV W
x
ûûW X
=>
ûûY [
x
ûû\ ]
.
ûû] ^
Product
ûû^ e
)
ûûe f
.
ûûf g"
SingleOrDefaultAsync
ûûg {
(
ûû{ |
x
ûû| }
=>ûû~ Ä
xûûÅ Ç
.ûûÇ É$
PayPalSubscriptionIdûûÉ ó
==ûûò ö
subscriptionIdûûõ ©
||ûû™ ¨
xûû≠ Æ
.ûûÆ Ø
PayPalOrderIdûûØ º
==ûûΩ ø
orderIdûû¿ «
,ûû« »
ctûû… À
)ûûÀ Ã
:ûûÕ Œ
nullûûœ ”
;ûû” ‘
if
üü 

(
üü 
item
üü 
is
üü 
null
üü 
)
üü 
return
üü  
Ok
üü! #
(
üü# $
)
üü$ %
;
üü% &
if
†† 

(
†† 
	eventType
†† 
is
†† 
$str
†† 9
or
††: <
$str
††= ]
)
††] ^
{
††_ `
item
††a e
.
††e f
Status
††f l
=
††m n
	eventType
††o x
.
††x y
EndsWith††y Å
(††Å Ç
$str††Ç ç
)††ç é
?††è ê#
ClientProductStatus††ë §
.††§ •
Activo††• ´
:††¨ ≠#
ClientProductStatus††Æ ¡
.††¡ ¬
	Cancelado††¬ À
;††À Ã
item††Õ —
.††— “$
PayPalSubscriptionId††“ Ê
??=††Á Í

resourceId††Î ı
;††ı ˆ
}††˜ ¯
if
¢¢ 

(
¢¢ 
	eventType
¢¢ 
is
¢¢ 
$str
¢¢ 2
)
¢¢2 3
{
¢¢4 5
item
¢¢6 :
.
¢¢: ;
PayPalOrderId
¢¢; H
??=
¢¢I L
orderId
¢¢M T
;
¢¢T U
await
¢¢V [
db
¢¢\ ^
.
¢¢^ _
SaveChangesAsync
¢¢_ o
(
¢¢o p
ct
¢¢p r
)
¢¢r s
;
¢¢s t
await
¢¢u z
payments¢¢{ É
.¢¢É Ñ
CaptureAsync¢¢Ñ ê
(¢¢ê ë
item¢¢ë ï
,¢¢ï ñ
ct¢¢ó ô
)¢¢ô ö
;¢¢ö õ
}¢¢ú ù
if
§§ 

(
§§ 
	eventType
§§ 
is
§§ 
$str
§§ 4
or
§§5 7
$str
§§8 P
&&
§§Q S
Amount
§§T Z
(
§§Z [
resource
§§[ c
)
§§c d
is
§§e g
(
§§h i
decimal
§§i p
amount
§§q w
,
§§w x
var
§§y |
currency§§} Ö
)§§Ö Ü
&&§§á â
orderId§§ä ë
is§§í î
not§§ï ò
null§§ô ù
)§§ù û
await
•• 
payments
•• 
.
•• 
ApplyPaymentAsync
•• ,
(
••, -
item
••- 1
,
••1 2
orderId
••3 :
,
••: ;
amount
••< B
,
••B C
currency
••D L
,
••L M
ct
••N P
)
••P Q
;
••Q R
Notification
¶¶ 
?
¶¶ 
failure
¶¶ 
=
¶¶ 
null
¶¶  $
;
¶¶$ %
if
ßß 

(
ßß 
	eventType
ßß 
is
ßß 
$str
ßß 1
or
ßß2 4
$str
ßß5 J
or
ßßK M
$str
ßßN s
)
ßßs t
failure
®® 
=
®® 
new
®® 
Notification
®® &
(
®®& '
NotificationType
®®' 7
.
®®7 8
PaymentFailed
®®8 E
,
®®E F
new
®®G J
(
®®J K
)
®®K L
{
®®M N
[
®®O P
$str
®®P Y
]
®®Y Z
=
®®[ \
item
®®] a
.
®®a b
Product
®®b i
?
®®i j
.
®®j k
Name
®®k o
??
®®p r
$str
®®s u
}
®®v w
,
®®w x
$"
®®y {
$str®®{ ä
{®®ä ã
Find®®ã è
(®®è ê
root®®ê î
,®®î ï
$str®®ñ ö
)®®ö õ
??®®ú û

resourceId®®ü ©
}®®© ™
"®®™ ´
)®®´ ¨
;®®¨ ≠
await
©© 
db
©© 
.
©© 
SaveChangesAsync
©© !
(
©©! "
ct
©©" $
)
©©$ %
;
©©% &
if
™™ 

(
™™ 
failure
™™ 
is
™™ 
not
™™ 
null
™™ 
&&
™™  "
await
™™# (
db
™™) +
.
™™+ ,
Clients
™™, 3
.
™™3 4
	FindAsync
™™4 =
(
™™= >
[
™™> ?
item
™™? C
.
™™C D
ClientId
™™D L
]
™™L M
,
™™M N
ct
™™O Q
)
™™Q R
is
™™S U
Client
™™V \
client
™™] c
)
™™c d
await
™™e j
notifications
™™k x
.
™™x y
	SendAsync™™y Ç
(™™Ç É
client™™É â
,™™â ä
failure™™ã í
,™™í ì
ct™™î ñ
)™™ñ ó
;™™ó ò
return
´´ 
Ok
´´ 
(
´´ 
)
´´ 
;
´´ 
}
¨¨ 
private
ÆÆ 
static
ÆÆ 
string
ÆÆ 
?
ÆÆ 
Find
ÆÆ 
(
ÆÆ  
JsonElement
ÆÆ  +
value
ÆÆ, 1
,
ÆÆ1 2
string
ÆÆ3 9
property
ÆÆ: B
)
ÆÆB C
=>
ÆÆD F
value
ÆÆG L
.
ÆÆL M
TryGetProperty
ÆÆM [
(
ÆÆ[ \
property
ÆÆ\ d
,
ÆÆd e
out
ÆÆf i
var
ÆÆj m
item
ÆÆn r
)
ÆÆr s
&&
ÆÆt v
item
ÆÆw {
.
ÆÆ{ |
	ValueKindÆÆ| Ö
==ÆÆÜ à
JsonValueKindÆÆâ ñ
.ÆÆñ ó
StringÆÆó ù
?ÆÆû ü
itemÆÆ† §
.ÆÆ§ •
	GetStringÆÆ• Æ
(ÆÆÆ Ø
)ÆÆØ ∞
:ÆÆ± ≤
nullÆÆ≥ ∑
;ÆÆ∑ ∏
private
ØØ 
static
ØØ 
string
ØØ 
?
ØØ 
Nested
ØØ !
(
ØØ! "
JsonElement
ØØ" -
value
ØØ. 3
,
ØØ3 4
params
ØØ5 ;
string
ØØ< B
[
ØØB C
]
ØØC D
path
ØØE I
)
ØØI J
{
ØØK L
foreach
ØØM T
(
ØØU V
var
ØØV Y
property
ØØZ b
in
ØØc e
path
ØØf j
)
ØØj k
{
ØØl m
if
ØØn p
(
ØØq r
!
ØØr s
value
ØØs x
.
ØØx y
TryGetPropertyØØy á
(ØØá à
propertyØØà ê
,ØØê ë
outØØí ï
valueØØñ õ
)ØØõ ú
)ØØú ù
returnØØû §
nullØØ• ©
;ØØ© ™
}ØØ´ ¨
returnØØ≠ ≥
valueØØ¥ π
.ØØπ ∫
	ValueKindØØ∫ √
==ØØƒ ∆
JsonValueKindØØ« ‘
.ØØ‘ ’
StringØØ’ €
?ØØ‹ ›
valueØØﬁ „
.ØØ„ ‰
	GetStringØØ‰ Ì
(ØØÌ Ó
)ØØÓ Ô
:ØØ Ò
nullØØÚ ˆ
;ØØˆ ˜
}ØØ¯ ˘
private
∞∞ 
static
∞∞ 
string
∞∞ 
?
∞∞ 
PurchaseUnit
∞∞ '
(
∞∞' (
JsonElement
∞∞( 3
resource
∞∞4 <
,
∞∞< =
string
∞∞> D
property
∞∞E M
)
∞∞M N
=>
∞∞O Q
resource
∞∞R Z
.
∞∞Z [
TryGetProperty
∞∞[ i
(
∞∞i j
$str
∞∞j z
,
∞∞z {
out
∞∞| 
var∞∞Ä É
units∞∞Ñ â
)∞∞â ä
&&∞∞ã ç
units∞∞é ì
.∞∞ì î
	ValueKind∞∞î ù
==∞∞û †
JsonValueKind∞∞° Æ
.∞∞Æ Ø
Array∞∞Ø ¥
&&∞∞µ ∑
units∞∞∏ Ω
.∞∞Ω æ
GetArrayLength∞∞æ Ã
(∞∞Ã Õ
)∞∞Õ Œ
>∞∞œ –
$num∞∞— “
?∞∞” ‘
Find∞∞’ Ÿ
(∞∞Ÿ ⁄
units∞∞⁄ ﬂ
[∞∞ﬂ ‡
$num∞∞‡ ·
]∞∞· ‚
,∞∞‚ „
property∞∞‰ Ï
)∞∞Ï Ì
:∞∞Ó Ô
null∞∞ Ù
;∞∞Ù ı
private
±± 
static
±± 
(
±± 
decimal
±± 
?
±± 
amount
±± #
,
±±# $
string
±±% +
?
±±+ ,
currency
±±- 5
)
±±5 6
Amount
±±7 =
(
±±= >
JsonElement
±±> I
resource
±±J R
)
±±R S
{
≤≤ 
foreach
¥¥ 
(
¥¥ 
var
¥¥ 
name
¥¥ 
in
¥¥ 
new
¥¥  
[
¥¥  !
]
¥¥! "
{
¥¥# $
$str
¥¥% -
,
¥¥- .
$str
¥¥/ =
}
¥¥> ?
)
¥¥? @
if
¥¥A C
(
¥¥D E
resource
¥¥E M
.
¥¥M N
TryGetProperty
¥¥N \
(
¥¥\ ]
name
¥¥] a
,
¥¥a b
out
¥¥c f
var
¥¥g j
value
¥¥k p
)
¥¥p q
&&
¥¥r t
(
¥¥u v
value
¥¥v {
.
¥¥{ |
TryGetProperty¥¥| ä
(¥¥ä ã
$str¥¥ã í
,¥¥í ì
out¥¥î ó
var¥¥ò õ
amount¥¥ú ¢
)¥¥¢ £
||¥¥§ ¶
value¥¥ß ¨
.¥¥¨ ≠
TryGetProperty¥¥≠ ª
(¥¥ª º
$str¥¥º √
,¥¥√ ƒ
out¥¥≈ »
amount¥¥… œ
)¥¥œ –
)¥¥– —
&&¥¥“ ‘
decimal¥¥’ ‹
.¥¥‹ ›
TryParse¥¥› Â
(¥¥Â Ê
amount¥¥Ê Ï
.¥¥Ï Ì
	GetString¥¥Ì ˆ
(¥¥ˆ ˜
)¥¥˜ ¯
,¥¥¯ ˘
System¥¥˙ Ä
.¥¥Ä Å
Globalization¥¥Å é
.¥¥é è
NumberStyles¥¥è õ
.¥¥õ ú
Number¥¥ú ¢
,¥¥¢ £
System¥¥§ ™
.¥¥™ ´
Globalization¥¥´ ∏
.¥¥∏ π
CultureInfo¥¥π ƒ
.¥¥ƒ ≈ 
InvariantCulture¥¥≈ ’
,¥¥’ ÷
out¥¥◊ ⁄
var¥¥€ ﬁ
parsed¥¥ﬂ Â
)¥¥Â Ê
)¥¥Ê Á
return¥¥Ë Ó
(¥¥Ô 
parsed¥¥ ˆ
,¥¥ˆ ˜
Find¥¥¯ ¸
(¥¥¸ ˝
value¥¥˝ Ç
,¥¥Ç É
$str¥¥Ñ ì
)¥¥ì î
??¥¥ï ó
Find¥¥ò ú
(¥¥ú ù
value¥¥ù ¢
,¥¥¢ £
$str¥¥§ Æ
)¥¥Æ Ø
)¥¥Ø ∞
;¥¥∞ ±
if
µµ 

(
µµ 
resource
µµ 
.
µµ 
TryGetProperty
µµ #
(
µµ# $
$str
µµ$ 4
,
µµ4 5
out
µµ6 9
var
µµ: =
units
µµ> C
)
µµC D
&&
µµE G
units
µµH M
.
µµM N
	ValueKind
µµN W
==
µµX Z
JsonValueKind
µµ[ h
.
µµh i
Array
µµi n
&&
µµo q
units
µµr w
.
µµw x
GetArrayLengthµµx Ü
(µµÜ á
)µµá à
>µµâ ä
$numµµã å
)µµå ç
returnµµé î
Amountµµï õ
(µµõ ú
unitsµµú °
[µµ° ¢
$numµµ¢ £
]µµ£ §
)µµ§ •
;µµ• ¶
return
∂∂ 
(
∂∂ 
null
∂∂ 
,
∂∂ 
null
∂∂ 
)
∂∂ 
;
∂∂ 
}
∑∑ 
}∏∏ 
publicªª 
sealed
ªª 
record
ªª 
SubscribeRequest
ªª %
(
ªª% &
Guid
ªª& *
	ProductId
ªª+ 4
,
ªª4 5
Guid
ªª6 :
?
ªª: ;
	ProjectId
ªª< E
,
ªªE F
BillingCycle
ªªG S
BillingCycle
ªªT `
,
ªª` a
string
ªªb h
PaymentMethod
ªªi v
=
ªªw x
PaymentMethodsªªy á
.ªªá à
PayPalªªà é
,ªªé è
intªªê ì
Yearsªªî ô
=ªªö õ
$numªªú ù
)ªªù û
;ªªû üÎì
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
] 
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
$str )
)) *
]* +
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
$str (
)( )
,) *
	Authorize+ 4
(4 5
Roles5 :
=; <
$str= I
)I J
]J K
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
$str )
)) *
,* +
	Authorize, 5
(5 6
Roles6 ;
=< =
$str> J
)J K
]K L
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
$str%% 2
)%%2 3
,%%3 4
	Authorize%%5 >
(%%> ?
Roles%%? D
=%%E F
$str%%G S
)%%S T
]%%T U
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
$str.. 5
)..5 6
,..6 7
	Authorize..8 A
(..A B
Roles..B G
=..H I
$str..J V
)..V W
]..W X
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
$str66 1
)661 2
,662 3
	Authorize664 =
(66= >
Roles66> C
=66D E
$str66F R
)66R S
]66S T
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
;__i j•
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
CancellationToken, =
ct> @
)@ A
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
,8 9
Request: A
.A B
HeadersB I
[I J
$strJ _
]_ `
)` a
)a b
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
} 	
var 
	eventName 
= 
Request 
.  
Headers  '
[' (
$str( 8
]8 9
.9 :
ToString: B
(B C
)C D
;D E
if 

( 
	eventName 
== 
$str 
)  
return! '
Ok( *
(* +
)+ ,
;, -
using 
var 
payload 
= 
JsonDocument (
.( )
Parse) .
(. /
body/ 3
)3 4
;4 5
await 
	processor 
. 
ProcessAsync $
($ %
	eventName% .
,. /
payload0 7
.7 8
RootElement8 C
,C D
ctE G
)G H
;H I
return 
Ok 
( 
) 
; 
} 
} Ön
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
] 
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
$str "
)" #
,# $
EnableRateLimiting% 7
(7 8
RateLimitPolicy8 G
)G H
]H I
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
$str00 
)00 
,00  
	Authorize00! *
(00* +
Roles00+ 0
=001 2
$str003 ?
)00? @
]00@ A
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
$str44 *
)44* +
,44+ ,
	Authorize44- 6
(446 7
Roles447 <
=44= >
$str44? K
)44K L
]44L M
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
;BBO PÌ∑
MC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\CategoriesController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[

 
ApiController

 
,

 
	Authorize

 
(

 
Roles

 
=

  !
$str

" .
)

. /
,

/ 0
Route

1 6
(

6 7
$str

7 B
)

B C
]

C D
public 
sealed 
class  
CategoriesController (
(( )
RtresDbContext) 7
db8 :
): ;
:< =
ControllerBase> L
{ 
[ 
HttpGet 
( 
$str !
)! "
]" #
public 

async 
Task 
< 
ActionResult "
>" #
ExpenseCategories$ 5
(5 6
CancellationToken6 G
ctH J
)J K
=>L N
OkO Q
(Q R
awaitR W
dbX Z
.Z [
ExpenseCategories[ l
.l m
OrderBym t
(t u
xu v
=>w y
xz {
.{ |
	SortOrder	| Ö
)
Ö Ü
.
Ü á
ThenBy
á ç
(
ç é
x
é è
=>
ê í
x
ì î
.
î ï
Name
ï ô
)
ô ö
. 	
Select	 
( 
x 
=> 
new 
CategoryDto $
($ %
x% &
.& '
Id' )
,) *
x+ ,
., -
Name- 1
,1 2
x3 4
.4 5
Code5 9
!=: <
null= A
,A B
xC D
.D E
IsIncomeTaxE P
,P Q
dbR T
.T U
ExpensesU ]
.] ^
Count^ c
(c d
ed e
=>f h
ei j
.j k

CategoryIdk u
==v x
xy z
.z {
Id{ }
)} ~
,~ 
x
Ä Å
.
Å Ç
IsDeductible
Ç é
&&
è ë
!
í ì
x
ì î
.
î ï
IsIncomeTax
ï †
)
† °
)
° ¢
.
¢ £
ToListAsync
£ Æ
(
Æ Ø
ct
Ø ±
)
± ≤
)
≤ ≥
;
≥ ¥
[ 
	HttpPatch 
( 
$str 8
)8 9
]9 :
public 

async 
Task 
< 
ActionResult "
>" #(
SetExpenseCategoryDeductible$ @
(@ A
GuidA E
idF H
,H I%
CategoryDeductibleRequestJ c
requestd k
,k l
CancellationTokenm ~
ct	 Å
)
Å Ç
{ 
var 
category 
= 
await 
db 
.  
ExpenseCategories  1
.1 2
	FindAsync2 ;
(; <
[< =
id= ?
]? @
,@ A
ctB D
)D E
;E F
ifG I
(J K
categoryK S
isT V
nullW [
)[ \
return] c
NotFoundd l
(l m
)m n
;n o
if 

( 
category 
. 
IsIncomeTax  
&&! #
request$ +
.+ ,
IsDeductible, 8
)8 9
return: @

BadRequestA K
(K L
newL O
{P Q
messageR Y
=Z [
$str	\ à
}
â ä
)
ä ã
;
ã å
category 
. 
IsDeductible 
= 
request  '
.' (
IsDeductible( 4
;4 5
await6 ;
db< >
.> ?
SaveChangesAsync? O
(O P
ctP R
)R S
;S T
returnU [
	NoContent\ e
(e f
)f g
;g h
} 
[ 
HttpPost 
( 
$str "
)" #
]# $
public 

async 
Task 
< 
ActionResult "
>" #!
CreateExpenseCategory$ 9
(9 :
CategoryRequest: I
requestJ Q
,Q R
CancellationTokenS d
cte g
)g h
{ 
if 

( 
await 
ValidateNameAsync #
(# $
request$ +
.+ ,
Name, 0
,0 1
db2 4
.4 5
ExpenseCategories5 F
.F G
SelectG M
(M N
xN O
=>P R
xS T
.T U
NameU Y
)Y Z
,Z [
ct\ ^
)^ _
is` b
{c d
}e f
errorg l
)l m
returnn t
erroru z
;z {
var 
category 
= 
new 
ExpenseCategory *
{+ ,
Name- 1
=2 3
request4 ;
.; <
Name< @
.@ A
TrimA E
(E F
)F G
,G H
	SortOrderI R
=S T
awaitU Z
db[ ]
.] ^
ExpenseCategories^ o
.o p

CountAsyncp z
(z {
ct{ }
)} ~
}	 Ä
;
Ä Å
db 

.
 
ExpenseCategories 
. 
Add  
(  !
category! )
)) *
;* +
await, 1
db2 4
.4 5
SaveChangesAsync5 E
(E F
ctF H
)H I
;I J
return   
Created   
(   
$"   
$str   7
{  7 8
category  8 @
.  @ A
Id  A C
}  C D
"  D E
,  E F
new  G J
CategoryDto  K V
(  V W
category  W _
.  _ `
Id  ` b
,  b c
category  d l
.  l m
Name  m q
,  q r
false  s x
,  x y
false  z 
,	   Ä
$num
  Å Ç
)
  Ç É
)
  É Ñ
;
  Ñ Ö
}!! 
[## 
	HttpPatch## 
(## 
$str## -
)##- .
]##. /
public$$ 

async$$ 
Task$$ 
<$$ 
ActionResult$$ "
>$$" #!
RenameExpenseCategory$$$ 9
($$9 :
Guid$$: >
id$$? A
,$$A B
CategoryRequest$$C R
request$$S Z
,$$Z [
CancellationToken$$\ m
ct$$n p
)$$p q
{%% 
var&& 
category&& 
=&& 
await&& 
db&& 
.&&  
ExpenseCategories&&  1
.&&1 2
	FindAsync&&2 ;
(&&; <
[&&< =
id&&= ?
]&&? @
,&&@ A
ct&&B D
)&&D E
;&&E F
if&&G I
(&&J K
category&&K S
is&&T V
null&&W [
)&&[ \
return&&] c
NotFound&&d l
(&&l m
)&&m n
;&&n o
if'' 

('' 
await'' 
ValidateNameAsync'' #
(''# $
request''$ +
.''+ ,
Name'', 0
,''0 1
db''2 4
.''4 5
ExpenseCategories''5 F
.''F G
Where''G L
(''L M
x''M N
=>''O Q
x''R S
.''S T
Id''T V
!=''W Y
id''Z \
)''\ ]
.''] ^
Select''^ d
(''d e
x''e f
=>''g i
x''j k
.''k l
Name''l p
)''p q
,''q r
ct''s u
)''u v
is''w y
{''z {
}''| }
error	''~ É
)
''É Ñ
return
''Ö ã
error
''å ë
;
''ë í
category(( 
.(( 
Name(( 
=(( 
request(( 
.((  
Name((  $
.(($ %
Trim((% )
((() *
)((* +
;((+ ,
await((- 2
db((3 5
.((5 6
SaveChangesAsync((6 F
(((F G
ct((G I
)((I J
;((J K
return((L R
	NoContent((S \
(((\ ]
)((] ^
;((^ _
})) 
[++ 

HttpDelete++ 
(++ 
$str++ .
)++. /
]++/ 0
public,, 

async,, 
Task,, 
<,, 
ActionResult,, "
>,," #!
DeleteExpenseCategory,,$ 9
(,,9 :
Guid,,: >
id,,? A
,,,A B
CancellationToken,,C T
ct,,U W
),,W X
{-- 
var.. 
category.. 
=.. 
await.. 
db.. 
...  
ExpenseCategories..  1
...1 2
	FindAsync..2 ;
(..; <
[..< =
id..= ?
]..? @
,..@ A
ct..B D
)..D E
;..E F
if..G I
(..J K
category..K S
is..T V
null..W [
)..[ \
return..] c
NotFound..d l
(..l m
)..m n
;..n o
if// 

(// 
category// 
.// 
Code// 
is// 
not//  
null//! %
)//% &
return//' -
Conflict//. 6
(//6 7
new//7 :
{//; <
message//= D
=//E F
$"//G I
$str//I J
{//J K
category//K S
.//S T
Name//T X
}//X Y
$str	//Y †
"
//† °
}
//¢ £
)
//£ §
;
//§ •
var00 
used00 
=00 
await00 
db00 
.00 
Expenses00 $
.00$ %

CountAsync00% /
(00/ 0
x000 1
=>002 4
x005 6
.006 7

CategoryId007 A
==00B D
id00E G
,00G H
ct00I K
)00K L
;00L M
if11 

(11 
used11 
>11 
$num11 
)11 
return11 
Conflict11 %
(11% &
new11& )
{11* +
message11, 3
=114 5
$"116 8
$str118 9
{119 :
category11: B
.11B C
Name11C G
}11G H
$str11H P
{11P Q
used11Q U
}11U V
$str11V W
{11W X
(11X Y
used11Y ]
==11^ `
$num11a b
?11c d
$str11e l
:11m n
$str11o w
)11w x
}11x y
$str	11y ¶
"
11¶ ß
}
11® ©
)
11© ™
;
11™ ´
db22 

.22
 
ExpenseCategories22 
.22 
Remove22 #
(22# $
category22$ ,
)22, -
;22- .
await22/ 4
db225 7
.227 8
SaveChangesAsync228 H
(22H I
ct22I K
)22K L
;22L M
return22N T
	NoContent22U ^
(22^ _
)22_ `
;22` a
}33 
[55 
HttpGet55 
(55 
$str55 !
)55! "
]55" #
public66 

async66 
Task66 
<66 
ActionResult66 "
>66" #
ProductCategories66$ 5
(665 6
CancellationToken666 G
ct66H J
)66J K
=>66L N
Ok66O Q
(66Q R
await66R W
db66X Z
.66Z [
ProductCategories66[ l
.66l m
OrderBy66m t
(66t u
x66u v
=>66w y
x66z {
.66{ |
	SortOrder	66| Ö
)
66Ö Ü
.
66Ü á
ThenBy
66á ç
(
66ç é
x
66é è
=>
66ê í
x
66ì î
.
66î ï
Name
66ï ô
)
66ô ö
.77 	
Select77	 
(77 
x77 
=>77 
new77 
CategoryDto77 $
(77$ %
x77% &
.77& '
Id77' )
,77) *
x77+ ,
.77, -
Name77- 1
,771 2
false773 8
,778 9
false77: ?
,77? @
db77A C
.77C D
Products77D L
.77L M
Count77M R
(77R S
p77S T
=>77U W
p77X Y
.77Y Z
Category77Z b
==77c e
x77f g
.77g h
Name77h l
)77l m
)77m n
)77n o
.77o p
ToListAsync77p {
(77{ |
ct77| ~
)77~ 
)	77 Ä
;
77Ä Å
[99 
HttpPost99 
(99 
$str99 "
)99" #
]99# $
public:: 

async:: 
Task:: 
<:: 
ActionResult:: "
>::" #!
CreateProductCategory::$ 9
(::9 :
CategoryRequest::: I
request::J Q
,::Q R
CancellationToken::S d
ct::e g
)::g h
{;; 
if<< 

(<< 
await<< 
ValidateNameAsync<< #
(<<# $
request<<$ +
.<<+ ,
Name<<, 0
,<<0 1
db<<2 4
.<<4 5
ProductCategories<<5 F
.<<F G
Select<<G M
(<<M N
x<<N O
=><<P R
x<<S T
.<<T U
Name<<U Y
)<<Y Z
,<<Z [
ct<<\ ^
)<<^ _
is<<` b
{<<c d
}<<e f
error<<g l
)<<l m
return<<n t
error<<u z
;<<z {
var== 
category== 
=== 
new== 
ProductCategory== *
{==+ ,
Name==- 1
===2 3
request==4 ;
.==; <
Name==< @
.==@ A
Trim==A E
(==E F
)==F G
,==G H
	SortOrder==I R
===S T
await==U Z
db==[ ]
.==] ^
ProductCategories==^ o
.==o p

CountAsync==p z
(==z {
ct=={ }
)==} ~
}	== Ä
;
==Ä Å
db>> 

.>>
 
ProductCategories>> 
.>> 
Add>>  
(>>  !
category>>! )
)>>) *
;>>* +
await>>, 1
db>>2 4
.>>4 5
SaveChangesAsync>>5 E
(>>E F
ct>>F H
)>>H I
;>>I J
return?? 
Created?? 
(?? 
$"?? 
$str?? 7
{??7 8
category??8 @
.??@ A
Id??A C
}??C D
"??D E
,??E F
new??G J
CategoryDto??K V
(??V W
category??W _
.??_ `
Id??` b
,??b c
category??d l
.??l m
Name??m q
,??q r
false??s x
,??x y
false??z 
,	?? Ä
$num
??Å Ç
)
??Ç É
)
??É Ñ
;
??Ñ Ö
}@@ 
[CC 
	HttpPatchCC 
(CC 
$strCC -
)CC- .
]CC. /
publicDD 

asyncDD 
TaskDD 
<DD 
ActionResultDD "
>DD" #!
RenameProductCategoryDD$ 9
(DD9 :
GuidDD: >
idDD? A
,DDA B
CategoryRequestDDC R
requestDDS Z
,DDZ [
CancellationTokenDD\ m
ctDDn p
)DDp q
{EE 
varFF 
categoryFF 
=FF 
awaitFF 
dbFF 
.FF  
ProductCategoriesFF  1
.FF1 2
	FindAsyncFF2 ;
(FF; <
[FF< =
idFF= ?
]FF? @
,FF@ A
ctFFB D
)FFD E
;FFE F
ifFFG I
(FFJ K
categoryFFK S
isFFT V
nullFFW [
)FF[ \
returnFF] c
NotFoundFFd l
(FFl m
)FFm n
;FFn o
ifGG 

(GG 
awaitGG 
ValidateNameAsyncGG #
(GG# $
requestGG$ +
.GG+ ,
NameGG, 0
,GG0 1
dbGG2 4
.GG4 5
ProductCategoriesGG5 F
.GGF G
WhereGGG L
(GGL M
xGGM N
=>GGO Q
xGGR S
.GGS T
IdGGT V
!=GGW Y
idGGZ \
)GG\ ]
.GG] ^
SelectGG^ d
(GGd e
xGGe f
=>GGg i
xGGj k
.GGk l
NameGGl p
)GGp q
,GGq r
ctGGs u
)GGu v
isGGw y
{GGz {
}GG| }
error	GG~ É
)
GGÉ Ñ
return
GGÖ ã
error
GGå ë
;
GGë í
varHH 
nameHH 
=HH 
requestHH 
.HH 
NameHH 
.HH  
TrimHH  $
(HH$ %
)HH% &
;HH& '
foreachII 
(II 
varII 
productII 
inII 
awaitII  %
dbII& (
.II( )
ProductsII) 1
.II1 2
WhereII2 7
(II7 8
xII8 9
=>II: <
xII= >
.II> ?
CategoryII? G
==IIH J
categoryIIK S
.IIS T
NameIIT X
)IIX Y
.IIY Z
ToListAsyncIIZ e
(IIe f
ctIIf h
)IIh i
)IIi j
productIIk r
.IIr s
CategoryIIs {
=II| }
name	II~ Ç
;
IIÇ É
categoryJJ 
.JJ 
NameJJ 
=JJ 
nameJJ 
;JJ 
awaitJJ #
dbJJ$ &
.JJ& '
SaveChangesAsyncJJ' 7
(JJ7 8
ctJJ8 :
)JJ: ;
;JJ; <
returnJJ= C
	NoContentJJD M
(JJM N
)JJN O
;JJO P
}KK 
[MM 

HttpDeleteMM 
(MM 
$strMM .
)MM. /
]MM/ 0
publicNN 

asyncNN 
TaskNN 
<NN 
ActionResultNN "
>NN" #!
DeleteProductCategoryNN$ 9
(NN9 :
GuidNN: >
idNN? A
,NNA B
CancellationTokenNNC T
ctNNU W
)NNW X
{OO 
varPP 
categoryPP 
=PP 
awaitPP 
dbPP 
.PP  
ProductCategoriesPP  1
.PP1 2
	FindAsyncPP2 ;
(PP; <
[PP< =
idPP= ?
]PP? @
,PP@ A
ctPPB D
)PPD E
;PPE F
ifPPG I
(PPJ K
categoryPPK S
isPPT V
nullPPW [
)PP[ \
returnPP] c
NotFoundPPd l
(PPl m
)PPm n
;PPn o
varQQ 
usedQQ 
=QQ 
awaitQQ 
dbQQ 
.QQ 
ProductsQQ $
.QQ$ %

CountAsyncQQ% /
(QQ/ 0
xQQ0 1
=>QQ2 4
xQQ5 6
.QQ6 7
CategoryQQ7 ?
==QQ@ B
categoryQQC K
.QQK L
NameQQL P
,QQP Q
ctQQR T
)QQT U
;QQU V
ifRR 

(RR 
usedRR 
>RR 
$numRR 
)RR 
returnRR 
ConflictRR %
(RR% &
newRR& )
{RR* +
messageRR, 3
=RR4 5
$"RR6 8
$strRR8 9
{RR9 :
categoryRR: B
.RRB C
NameRRC G
}RRG H
$strRRH P
{RRP Q
usedRRQ U
}RRU V
$strRRV W
{RRW X
(RRX Y
usedRRY ]
==RR^ `
$numRRa b
?RRc d
$strRRe o
:RRp q
$strRRr }
)RR} ~
}RR~ 
$str	RR ¨
"
RR¨ ≠
}
RRÆ Ø
)
RRØ ∞
;
RR∞ ±
dbSS 

.SS
 
ProductCategoriesSS 
.SS 
RemoveSS #
(SS# $
categorySS$ ,
)SS, -
;SS- .
awaitSS/ 4
dbSS5 7
.SS7 8
SaveChangesAsyncSS8 H
(SSH I
ctSSI K
)SSK L
;SSL M
returnSSN T
	NoContentSSU ^
(SS^ _
)SS_ `
;SS` a
}TT 
privateVV 
asyncVV 
TaskVV 
<VV 
ActionResultVV #
?VV# $
>VV$ %
ValidateNameAsyncVV& 7
(VV7 8
stringVV8 >
?VV> ?
nameVV@ D
,VVD E

IQueryableVVF P
<VVP Q
stringVVQ W
>VVW X
othersVVY _
,VV_ `
CancellationTokenVVa r
ctVVs u
)VVu v
{WW 
ifXX 

(XX 
stringXX 
.XX 
IsNullOrWhiteSpaceXX %
(XX% &
nameXX& *
)XX* +
)XX+ ,
returnXX- 3

BadRequestXX4 >
(XX> ?
newXX? B
{XXC D
messageXXE L
=XXM N
$strXXO j
}XXk l
)XXl m
;XXm n
ifYY 

(YY 
nameYY 
.YY 
TrimYY 
(YY 
)YY 
.YY 
LengthYY 
>YY  
$numYY! $
)YY$ %
returnYY& ,

BadRequestYY- 7
(YY7 8
newYY8 ;
{YY< =
messageYY> E
=YYF G
$strYYH p
}YYq r
)YYr s
;YYs t
varZZ 
foldedZZ 
=ZZ 
AdminControllerZZ $
.ZZ$ %
FoldZZ% )
(ZZ) *
nameZZ* .
)ZZ. /
;ZZ/ 0
if[[ 

([[ 
([[ 
await[[ 
others[[ 
.[[ 
ToListAsync[[ %
([[% &
ct[[& (
)[[( )
)[[) *
.[[* +
Any[[+ .
([[. /
x[[/ 0
=>[[1 3
AdminController[[4 C
.[[C D
Fold[[D H
([[H I
x[[I J
)[[J K
==[[L N
folded[[O U
)[[U V
)[[V W
return[[X ^
Conflict[[_ g
([[g h
new[[h k
{[[l m
message[[n u
=[[v w
$"[[x z
$str	[[z ì
{
[[ì î
name
[[î ò
.
[[ò ô
Trim
[[ô ù
(
[[ù û
)
[[û ü
}
[[ü †
$str
[[† ¢
"
[[¢ £
}
[[§ •
)
[[• ¶
;
[[¶ ß
return\\ 
null\\ 
;\\ 
}]] 
}^^ 
public`` 
sealed`` 
record`` 
CategoryDto``  
(``  !
Guid``! %
Id``& (
,``( )
string``* 0
Name``1 5
,``5 6
bool``7 ;
IsSystem``< D
,``D E
bool``F J
IsIncomeTax``K V
,``V W
int``X [

UsageCount``\ f
,``f g
bool``h l
IsDeductible``m y
=``z {
true	``| Ä
)
``Ä Å
;
``Å Ç
publicaa 
sealedaa 
recordaa %
CategoryDeductibleRequestaa .
(aa. /
boolaa/ 3
IsDeductibleaa4 @
)aa@ A
;aaA B
publicbb 
sealedbb 
recordbb 
CategoryRequestbb $
(bb$ %
stringbb% +
Namebb, 0
)bb0 1
;bb1 2Øü
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\BankTransfersController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
, 
Route  
(  !
$str! &
)& '
]' (
public 
sealed 
partial 
class #
BankTransfersController 3
(3 4
RtresDbContext4 B
dbC E
,E F
BankTransferServiceG Z
	transfers[ d
,d e 
PayPalPaymentServicef z
payments	{ É
,
É Ñ!
INotificationSender
Ö ò
notifications
ô ¶
,
¶ ß
IConfiguration
® ∂
configuration
∑ ƒ
,
ƒ ≈
ILogger
∆ Õ
<
Õ Œ%
BankTransfersController
Œ Â
>
Â Ê
logger
Á Ì
)
Ì Ó
:
Ô 
ControllerBase
Ò ˇ
{ 
public 

const 
long 
MaxReceiptBytes %
=& '
$num( )
** +
$num, 0
*1 2
$num3 7
;7 8
public 

static 
readonly 
string !
[! "
]" #

Currencies$ .
=/ 0
[1 2
$str2 7
,7 8
$str9 >
,> ?
$str@ E
]E F
;F G
private 
static 
readonly 
string "
[" #
]# $
ReceiptTypes% 1
=2 3
[4 5
$str5 A
,A B
$strC N
,N O
$strP \
,\ ]
$str^ j
,j k
$strl }
]} ~
;~ 
private 
Guid 
UserId 
=> 
Guid 
.  
Parse  %
(% &
User& *
.* +
FindFirstValue+ 9
(9 :

ClaimTypes: D
.D E
NameIdentifierE S
)S T
!T U
)U V
;V W
private 
bool 
IsSuperAdmin 
=>  
User! %
.% &
IsInRole& .
(. /
nameof/ 5
(5 6
UserRole6 >
.> ?

SuperAdmin? I
)I J
)J K
;K L
[ 
HttpGet 
( 
$str 
) 
]  
public   

async   
Task   
<   
ActionResult   "
>  " #!
EnabledPaymentMethods  $ 9
(  9 :
CancellationToken  : K
ct  L N
)  N O
{  P Q
var  R U
s  V W
=  X Y
await  Z _
	transfers  ` i
.  i j
SettingsAsync  j w
(  w x
ct  x z
)  z {
;  { |
return	  } É
Ok
  Ñ Ü
(
  Ü á
new
  á ä
{
  ã å
payPal
  ç ì
=
  î ï
s
  ñ ó
.
  ó ò
PayPalEnabled
  ò •
,
  • ¶
bankTransfer
  ß ≥
=
  ¥ µ
s
  ∂ ∑
.
  ∑ ∏!
BankTransferEnabled
  ∏ À
}
  Ã Õ
)
  Õ Œ
;
  Œ œ
}
  – —
["" 
	HttpPatch"" 
("" 
$str"" '
)""' (
,""( )
	Authorize""* 3
(""3 4
Roles""4 9
="": ;
$str""< H
)""H I
]""I J
public## 

async## 
Task## 
<## 
ActionResult## "
>##" #!
UpdatePaymentSettings##$ 9
(##9 :"
PaymentSettingsRequest##: P
request##Q X
,##X Y
CancellationToken##Z k
ct##l n
)##n o
{$$ 
var%% 
settings%% 
=%% 
await%% 
	transfers%% &
.%%& '
SettingsAsync%%' 4
(%%4 5
ct%%5 7
)%%7 8
;%%8 9
var&& 
payPal&& 
=&& 
request&& 
.&& 
PayPal&& #
??&&$ &
settings&&' /
.&&/ 0
PayPalEnabled&&0 =
;&&= >
var&&? B
bank&&C G
=&&H I
request&&J Q
.&&Q R
BankTransfer&&R ^
??&&_ a
settings&&b j
.&&j k
BankTransferEnabled&&k ~
;&&~ 
if'' 

('' 
!'' 
payPal'' 
&&'' 
!'' 
bank'' 
)'' 
return'' $

BadRequest''% /
(''/ 0
new''0 3
{''4 5
message''6 =
=''> ?
$str	''@ î
}
''ï ñ
)
''ñ ó
;
''ó ò
if(( 

((( 
bank(( 
&&(( 
!(( 
settings(( 
.(( 
BankTransferEnabled(( 1
&&((2 4
!((5 6
await((6 ;
db((< >
.((> ?
BankAccounts((? K
.((K L
AnyAsync((L T
(((T U
x((U V
=>((W Y
x((Z [
.(([ \
IsActive((\ d
,((d e
ct((f h
)((h i
)((i j
return((k q

BadRequest((r |
(((| }
new	((} Ä
{
((Å Ç
message
((É ä
=
((ã å
$str
((ç ﬁ
}
((ﬂ ‡
)
((‡ ·
;
((· ‚
()) 	
settings))	 
.)) 
PayPalEnabled)) 
,))  
settings))! )
.))) *
BankTransferEnabled))* =
,))= >
settings))? G
.))G H
	UpdatedAt))H Q
)))Q R
=))S T
())U V
payPal))V \
,))\ ]
bank))^ b
,))b c
DateTime))d l
.))l m
UtcNow))m s
)))s t
;))t u
await** 
db** 
.** 
SaveChangesAsync** !
(**! "
ct**" $
)**$ %
;**% &
return++ 
Ok++ 
(++ 
new++ 
{++ 
payPal++ 
,++ 
bankTransfer++  ,
=++- .
bank++/ 3
}++4 5
)++5 6
;++6 7
},, 
[00 
HttpGet00 
(00 
$str00 "
)00" #
,00# $
	Authorize00% .
(00. /
Roles00/ 4
=005 6
$str007 C
)00C D
]00D E
public11 

async11 
Task11 
<11 
ActionResult11 "
>11" #
Accounts11$ ,
(11, -
CancellationToken11- >
ct11? A
)11A B
=>11C E
Ok22 

(22
 
(22 
await22 
db22 
.22 
BankAccounts22 !
.22! "
OrderBy22" )
(22) *
x22* +
=>22, .
x22/ 0
.220 1
	SortOrder221 :
)22: ;
.22; <
ThenBy22< B
(22B C
x22C D
=>22E G
x22H I
.22I J
Currency22J R
)22R S
.22S T
ThenBy22T Z
(22Z [
x22[ \
=>22] _
x22` a
.22a b
BankName22b j
)22j k
.22k l
ToListAsync22l w
(22w x
ct22x z
)22z {
)22{ |
.22| }
Select	22} É
(
22É Ñ
x
22Ñ Ö
=>
22Ü à
BankAccountDto
22â ó
.
22ó ò
From
22ò ú
(
22ú ù
x
22ù û
)
22û ü
)
22ü †
)
22† °
;
22° ¢
[44 
HttpPost44 
(44 
$str44 #
)44# $
,44$ %
	Authorize44& /
(44/ 0
Roles440 5
=446 7
$str448 D
)44D E
]44E F
public55 

async55 
Task55 
<55 
ActionResult55 "
>55" #
CreateAccount55$ 1
(551 2
BankAccountRequest552 D
request55E L
,55L M
CancellationToken55N _
ct55` b
)55b c
{66 
var77 
account77 
=77 
new77 
BankAccount77 %
{77& '
	SortOrder77( 1
=772 3
await774 9
db77: <
.77< =
BankAccounts77= I
.77I J

CountAsync77J T
(77T U
ct77U W
)77W X
}77Y Z
;77Z [
if88 

(88 
Apply88 
(88 
account88 
,88 
request88 "
)88" #
is88$ &
string88' -
error88. 3
)883 4
return885 ;

BadRequest88< F
(88F G
new88G J
{88K L
message88M T
=88U V
error88W \
}88] ^
)88^ _
;88_ `
if99 

(99 
await99 
DuplicateAsync99  
(99  !
account99! (
,99( )
ct99* ,
)99, -
)99- .
return99/ 5
Conflict996 >
(99> ?
new99? B
{99C D
message99E L
=99M N
$str99O o
}99p q
)99q r
;99r s
db:: 

.::
 
BankAccounts:: 
.:: 
Add:: 
(:: 
account:: #
)::# $
;::$ %
await::& +
db::, .
.::. /
SaveChangesAsync::/ ?
(::? @
ct::@ B
)::B C
;::C D
return;; 
Created;; 
(;; 
$";; 
$str;; 2
{;;2 3
account;;3 :
.;;: ;
Id;;; =
};;= >
";;> ?
,;;? @
BankAccountDto;;A O
.;;O P
From;;P T
(;;T U
account;;U \
);;\ ]
);;] ^
;;;^ _
}<< 
[>> 
HttpPut>> 
(>> 
$str>> ,
)>>, -
,>>- .
	Authorize>>/ 8
(>>8 9
Roles>>9 >
=>>? @
$str>>A M
)>>M N
]>>N O
public?? 

async?? 
Task?? 
<?? 
ActionResult?? "
>??" #
UpdateAccount??$ 1
(??1 2
Guid??2 6
id??7 9
,??9 :
BankAccountRequest??; M
request??N U
,??U V
CancellationToken??W h
ct??i k
)??k l
{@@ 
varAA 
accountAA 
=AA 
awaitAA 
dbAA 
.AA 
BankAccountsAA +
.AA+ ,
	FindAsyncAA, 5
(AA5 6
[AA6 7
idAA7 9
]AA9 :
,AA: ;
ctAA< >
)AA> ?
;AA? @
ifAAA C
(AAD E
accountAAE L
isAAM O
nullAAP T
)AAT U
returnAAV \
NotFoundAA] e
(AAe f
)AAf g
;AAg h
ifBB 

(BB 
ApplyBB 
(BB 
accountBB 
,BB 
requestBB "
)BB" #
isBB$ &
stringBB' -
errorBB. 3
)BB3 4
returnBB5 ;

BadRequestBB< F
(BBF G
newBBG J
{BBK L
messageBBM T
=BBU V
errorBBW \
}BB] ^
)BB^ _
;BB_ `
ifCC 

(CC 
awaitCC 
DuplicateAsyncCC  
(CC  !
accountCC! (
,CC( )
ctCC* ,
)CC, -
)CC- .
returnCC/ 5
ConflictCC6 >
(CC> ?
newCC? B
{CCC D
messageCCE L
=CCM N
$strCCO o
}CCp q
)CCq r
;CCr s
ifDD 

(DD 
!DD 
accountDD 
.DD 
IsActiveDD 
&&DD  
awaitDD! &0
$LastActiveAccountWithTransferOnAsyncDD' K
(DDK L
accountDDL S
.DDS T
IdDDT V
,DDV W
ctDDX Z
)DDZ [
)DD[ \
returnDD] c

BadRequestDDd n
(DDn o
newDDo r
{DDs t
messageDDu |
=DD} ~
$str	DD Ù
}
DDı ˆ
)
DDˆ ˜
;
DD˜ ¯
awaitEE 
dbEE 
.EE 
SaveChangesAsyncEE !
(EE! "
ctEE" $
)EE$ %
;EE% &
returnFF 
OkFF 
(FF 
BankAccountDtoFF  
.FF  !
FromFF! %
(FF% &
accountFF& -
)FF- .
)FF. /
;FF/ 0
}GG 
[JJ 

HttpDeleteJJ 
(JJ 
$strJJ /
)JJ/ 0
,JJ0 1
	AuthorizeJJ2 ;
(JJ; <
RolesJJ< A
=JJB C
$strJJD P
)JJP Q
]JJQ R
publicKK 

asyncKK 
TaskKK 
<KK 
ActionResultKK "
>KK" #
DeleteAccountKK$ 1
(KK1 2
GuidKK2 6
idKK7 9
,KK9 :
CancellationTokenKK; L
ctKKM O
)KKO P
{LL 
varMM 
accountMM 
=MM 
awaitMM 
dbMM 
.MM 
BankAccountsMM +
.MM+ ,
	FindAsyncMM, 5
(MM5 6
[MM6 7
idMM7 9
]MM9 :
,MM: ;
ctMM< >
)MM> ?
;MM? @
ifMMA C
(MMD E
accountMME L
isMMM O
nullMMP T
)MMT U
returnMMV \
NotFoundMM] e
(MMe f
)MMf g
;MMg h
ifNN 

(NN 
awaitNN 
dbNN 
.NN 
TransferReportsNN $
.NN$ %
AnyAsyncNN% -
(NN- .
xNN. /
=>NN0 2
xNN3 4
.NN4 5
BankAccountIdNN5 B
==NNC E
idNNF H
,NNH I
ctNNJ L
)NNL M
)NNM N
returnNNO U
ConflictNNV ^
(NN^ _
newNN_ b
{NNc d
messageNNe l
=NNm n
$str	NNo ∏
}
NNπ ∫
)
NN∫ ª
;
NNª º
ifOO 

(OO 
accountOO 
.OO 
IsActiveOO 
&&OO 
awaitOO  %0
$LastActiveAccountWithTransferOnAsyncOO& J
(OOJ K
idOOK M
,OOM N
ctOOO Q
)OOQ R
)OOR S
returnOOT Z

BadRequestOO[ e
(OOe f
newOOf i
{OOj k
messageOOl s
=OOt u
$str	OOv Î
}
OOÏ Ì
)
OOÌ Ó
;
OOÓ Ô
dbPP 

.PP
 
BankAccountsPP 
.PP 
RemovePP 
(PP 
accountPP &
)PP& '
;PP' (
awaitPP) .
dbPP/ 1
.PP1 2
SaveChangesAsyncPP2 B
(PPB C
ctPPC E
)PPE F
;PPF G
returnQQ 
	NoContentQQ 
(QQ 
)QQ 
;QQ 
}RR 
privateTT 
asyncTT 
TaskTT 
<TT 
boolTT 
>TT 0
$LastActiveAccountWithTransferOnAsyncTT A
(TTA B
GuidTTB F
idTTG I
,TTI J
CancellationTokenTTK \
ctTT] _
)TT_ `
=>TTa c
(UU 	
awaitUU	 
	transfersUU 
.UU 
SettingsAsyncUU &
(UU& '
ctUU' )
)UU) *
)UU* +
.UU+ ,
BankTransferEnabledUU, ?
&&UU@ B
!UUC D
awaitUUD I
dbUUJ L
.UUL M
BankAccountsUUM Y
.UUY Z
AnyAsyncUUZ b
(UUb c
xUUc d
=>UUe g
xUUh i
.UUi j
IsActiveUUj r
&&UUs u
xUUv w
.UUw x
IdUUx z
!=UU{ }
id	UU~ Ä
,
UUÄ Å
ct
UUÇ Ñ
)
UUÑ Ö
;
UUÖ Ü
privateWW 
TaskWW 
<WW 
boolWW 
>WW 
DuplicateAsyncWW %
(WW% &
BankAccountWW& 1
accountWW2 9
,WW9 :
CancellationTokenWW; L
ctWWM O
)WWO P
=>WWQ S
dbXX 

.XX
 
BankAccountsXX 
.XX 
AnyAsyncXX  
(XX  !
xXX! "
=>XX# %
xXX& '
.XX' (
IdXX( *
!=XX+ -
accountXX. 5
.XX5 6
IdXX6 8
&&XX9 ;
xXX< =
.XX= >
BankNameXX> F
==XXG I
accountXXJ Q
.XXQ R
BankNameXXR Z
&&XX[ ]
xXX^ _
.XX_ `
AccountNumberXX` m
==XXn p
accountXXq x
.XXx y
AccountNumber	XXy Ü
,
XXÜ á
ct
XXà ä
)
XXä ã
;
XXã å
internalZZ 
staticZZ 
stringZZ 
?ZZ 
ApplyZZ !
(ZZ! "
BankAccountZZ" -
accountZZ. 5
,ZZ5 6
BankAccountRequestZZ7 I
rZZJ K
)ZZK L
{[[ 
var\\ 
bank\\ 
=\\ 
r\\ 
.\\ 
BankName\\ 
?\\ 
.\\ 
Trim\\ #
(\\# $
)\\$ %
;\\% &
var\\' *
holder\\+ 1
=\\2 3
r\\4 5
.\\5 6
Holder\\6 <
?\\< =
.\\= >
Trim\\> B
(\\B C
)\\C D
;\\D E
var\\F I
currency\\J R
=\\S T
r\\U V
.\\V W
Currency\\W _
?\\_ `
.\\` a
Trim\\a e
(\\e f
)\\f g
.\\g h
ToUpperInvariant\\h x
(\\x y
)\\y z
;\\z {
var]] 
number]] 
=]] 
Digits]] 
(]] 
r]] 
.]] 
AccountNumber]] +
)]]+ ,
;]], -
var]]. 1
cci]]2 5
=]]6 7
Digits]]8 >
(]]> ?
r]]? @
.]]@ A
Cci]]A D
)]]D E
;]]E F
if^^ 

(^^ 
string^^ 
.^^ 
IsNullOrEmpty^^  
(^^  !
bank^^! %
)^^% &
||^^' )
string^^* 0
.^^0 1
IsNullOrEmpty^^1 >
(^^> ?
holder^^? E
)^^E F
)^^F G
return^^H N
$str^^O x
;^^x y
if__ 

(__ 
currency__ 
is__ 
null__ 
||__ 
!__  !

Currencies__! +
.__+ ,
Contains__, 4
(__4 5
currency__5 =
)__= >
)__> ?
return__@ F
$str__G k
;__k l
if`` 

(`` 
string`` 
.`` 
IsNullOrEmpty``  
(``  !
number``! '
)``' (
||``) +
number``, 2
.``2 3
Length``3 9
<``: ;
$num``< =
||``> @
number``A G
.``G H
Length``H N
>``O P
$num``Q S
)``S T
return``U [
$str	``\ Ä
;
``Ä Å
ifaa 

(aa 
cciaa 
isaa 
{aa 
Lengthaa 
:aa 
>aa 
$numaa  
}aa! "
&&aa# %
!aa& '

CciPatternaa' 1
(aa1 2
)aa2 3
.aa3 4
IsMatchaa4 ;
(aa; <
cciaa< ?
)aa? @
)aa@ A
returnaaB H
$straaI c
;aac d
(bb 	
accountbb	 
.bb 
BankNamebb 
,bb 
accountbb "
.bb" #
Holderbb# )
,bb) *
accountbb+ 2
.bb2 3
Currencybb3 ;
,bb; <
accountbb= D
.bbD E
TypebbE I
,bbI J
accountbbK R
.bbR S
AccountNumberbbS `
,bb` a
accountbbb i
.bbi j
Ccibbj m
,bbm n
accountbbo v
.bbv w
IsActivebbw 
)	bb Ä
=
bbÅ Ç
(
bbÉ Ñ
bank
bbÑ à
,
bbà â
holder
bbä ê
,
bbê ë
currency
bbí ö
,
bbö õ
r
bbú ù
.
bbù û
Type
bbû ¢
,
bb¢ £
number
bb§ ™
,
bb™ ´
cci
bb¨ Ø
is
bb∞ ≤
{
bb≥ ¥
Length
bbµ ª
:
bbª º
>
bbΩ æ
$num
bbø ¿
}
bb¡ ¬
?
bb√ ƒ
cci
bb≈ »
:
bb…  
null
bbÀ œ
,
bbœ –
r
bb— “
.
bb“ ”
IsActive
bb” €
)
bb€ ‹
;
bb‹ ›
returncc 
nullcc 
;cc 
}dd 
privategg 
staticgg 
stringgg 
?gg 
Digitsgg !
(gg! "
stringgg" (
?gg( )
valuegg* /
)gg/ 0
=>gg1 3
valuegg4 9
isgg: <
nullgg= A
?ggB C
nullggD H
:ggI J
WhitespacePatternggK \
(gg\ ]
)gg] ^
.gg^ _
Replacegg_ f
(ggf g
valueggg l
,ggl m
$strggn p
)ggp q
.ggq r
ToUpperInvariant	ggr Ç
(
ggÇ É
)
ggÉ Ñ
;
ggÑ Ö
[ii 
GeneratedRegexii 
(ii 
$strii 
)ii  
]ii  !
privateii" )
staticii* 0
partialii1 8
Regexii9 >

CciPatternii? I
(iiI J
)iiJ K
;iiK L
[jj 
GeneratedRegexjj 
(jj 
$strjj 
)jj 
]jj 
privatejj $
staticjj% +
partialjj, 3
Regexjj4 9
WhitespacePatternjj: K
(jjK L
)jjL M
;jjM N
[rr 
HttpPostrr 
(rr 
$strrr :
)rr: ;
,rr; <
	Authorizerr= F
(rrF G
RolesrrG L
=rrM N
$strrrO ^
)rr^ _
,rr_ `
RequestSizeLimitrra q
(rrq r
$numrrr {
)rr{ |
,rr| }
RequestFormLimits	rr~ è
(
rrè ê&
MultipartBodyLengthLimit
rrê ®
=
rr© ™
$num
rr´ ¥
)
rr¥ µ
]
rrµ ∂
publicss 

asyncss 
Taskss 
<ss 
ActionResultss "
>ss" #
Reportss$ *
(ss* +
Guidss+ /
idss0 2
,ss2 3
[ss4 5
FromFormss5 =
]ss= >!
TransferReportRequestss? T
requestssU \
,ss\ ]
CancellationTokenss^ o
ctssp r
,ssr s
	IFormFilesst }
?ss} ~
receipt	ss Ü
=
ssá à
null
ssâ ç
)
ssç é
{tt 
ifuu 

(uu 
!uu 
Guiduu 
.uu 
TryParseuu 
(uu 
Useruu 
.uu  
FindFirstValueuu  .
(uu. /
$struu/ :
)uu: ;
,uu; <
outuu= @
varuuA D
clientIduuE M
)uuM N
)uuN O
returnuuP V
ForbiduuW ]
(uu] ^
)uu^ _
;uu_ `
varvv 
settingsvv 
=vv 
awaitvv 
	transfersvv &
.vv& '
SettingsAsyncvv' 4
(vv4 5
ctvv5 7
)vv7 8
;vv8 9
ifww 

(ww 
!ww 
settingsww 
.ww 
BankTransferEnabledww )
)ww) *
returnww+ 1

BadRequestww2 <
(ww< =
newww= @
{wwA B
messagewwC J
=wwK L
$str	wwM Ü
}
wwá à
)
wwà â
;
wwâ ä
varxx 
itemxx 
=xx 
awaitxx 
dbxx 
.xx 
ClientProductsxx *
.xx* +
Includexx+ 2
(xx2 3
xxx3 4
=>xx5 7
xxx8 9
.xx9 :
Productxx: A
)xxA B
.xxB C 
SingleOrDefaultAsyncxxC W
(xxW X
xxxX Y
=>xxZ \
xxx] ^
.xx^ _
Idxx_ a
==xxb d
idxxe g
&&xxh j
xxxk l
.xxl m
ClientIdxxm u
==xxv x
clientId	xxy Å
,
xxÅ Ç
ct
xxÉ Ö
)
xxÖ Ü
;
xxÜ á
ifyy 

(yy 
itemyy 
?yy 
.yy 
Productyy 
isyy 
nullyy !
)yy! "
returnyy# )
NotFoundyy* 2
(yy2 3
)yy3 4
;yy4 5
ifzz 

(zz 
!zz 
CanPayByTransferzz 
(zz 
itemzz "
,zz" #
settingszz$ ,
)zz, -
)zz- .
returnzz/ 5

BadRequestzz6 @
(zz@ A
newzzA D
{zzE F
messagezzG N
=zzO P
$str	zzQ é
}
zzè ê
)
zzê ë
;
zzë í
if{{ 

({{ 
await{{ 
db{{ 
.{{ 
TransferReports{{ $
.{{$ %
AnyAsync{{% -
({{- .
x{{. /
=>{{0 2
x{{3 4
.{{4 5
ClientProductId{{5 D
=={{E G
id{{H J
&&{{K M
x{{N O
.{{O P
Status{{P V
=={{W Y 
TransferReportStatus{{Z n
.{{n o
	Pendiente{{o x
,{{x y
ct{{z |
){{| }
){{} ~
return	{{ Ö
Conflict
{{Ü é
(
{{é è
new
{{è í
{
{{ì î
message
{{ï ú
=
{{ù û
$str
{{ü ‡
}
{{· ‚
)
{{‚ „
;
{{„ ‰
var|| 
account|| 
=|| 
await|| 
db|| 
.|| 
BankAccounts|| +
.||+ , 
SingleOrDefaultAsync||, @
(||@ A
x||A B
=>||C E
x||F G
.||G H
Id||H J
==||K M
request||N U
.||U V
BankAccountId||V c
&&||d f
x||g h
.||h i
IsActive||i q
,||q r
ct||s u
)||u v
;||v w
if}} 

(}} 
account}} 
is}} 
null}} 
)}} 
return}} #

BadRequest}}$ .
(}}. /
new}}/ 2
{}}3 4
message}}5 <
=}}= >
$str}}? g
}}}h i
)}}i j
;}}j k
var~~ 
	operation~~ 
=~~ 
request~~ 
.~~  
OperationNumber~~  /
?~~/ 0
.~~0 1
Trim~~1 5
(~~5 6
)~~6 7
;~~7 8
if 

( 
string 
. 
IsNullOrEmpty  
(  !
	operation! *
)* +
&&, .
receipt/ 6
is7 9
null: >
)> ?
return@ F

BadRequestG Q
(Q R
newR U
{V W
messageX _
=` a
$str	b ß
}
® ©
)
© ™
;
™ ´
if
ÄÄ 

(
ÄÄ 
	operation
ÄÄ 
is
ÄÄ 
{
ÄÄ 
Length
ÄÄ !
:
ÄÄ! "
>
ÄÄ# $
$num
ÄÄ% '
}
ÄÄ( )
)
ÄÄ) *
return
ÄÄ+ 1

BadRequest
ÄÄ2 <
(
ÄÄ< =
new
ÄÄ= @
{
ÄÄA B
message
ÄÄC J
=
ÄÄK L
$str
ÄÄM u
}
ÄÄv w
)
ÄÄw x
;
ÄÄx y
if
ÅÅ 

(
ÅÅ 
request
ÅÅ 
.
ÅÅ 
Amount
ÅÅ 
<=
ÅÅ 
$num
ÅÅ 
)
ÅÅ  
return
ÅÅ! '

BadRequest
ÅÅ( 2
(
ÅÅ2 3
new
ÅÅ3 6
{
ÅÅ7 8
message
ÅÅ9 @
=
ÅÅA B
$str
ÅÅC a
}
ÅÅb c
)
ÅÅc d
;
ÅÅd e
if
ÇÇ 

(
ÇÇ 
request
ÇÇ 
.
ÇÇ 
PaidAt
ÇÇ 
>
ÇÇ 
DateOnly
ÇÇ %
.
ÇÇ% &
FromDateTime
ÇÇ& 2
(
ÇÇ2 3
DateTime
ÇÇ3 ;
.
ÇÇ; <
UtcNow
ÇÇ< B
.
ÇÇB C
AddDays
ÇÇC J
(
ÇÇJ K
$num
ÇÇK L
)
ÇÇL M
)
ÇÇM N
||
ÇÇO Q
request
ÇÇR Y
.
ÇÇY Z
PaidAt
ÇÇZ `
<
ÇÇa b
DateOnly
ÇÇc k
.
ÇÇk l
FromDateTime
ÇÇl x
(
ÇÇx y
DateTimeÇÇy Å
.ÇÇÅ Ç
UtcNowÇÇÇ à
.ÇÇà â
AddDaysÇÇâ ê
(ÇÇê ë
-ÇÇë í
$numÇÇí î
)ÇÇî ï
)ÇÇï ñ
)ÇÇñ ó
returnÇÇò û

BadRequestÇÇü ©
(ÇÇ© ™
newÇÇ™ ≠
{ÇÇÆ Ø
messageÇÇ∞ ∑
=ÇÇ∏ π
$strÇÇ∫ Ê
}ÇÇÁ Ë
)ÇÇË È
;ÇÇÈ Í
if
ÉÉ 

(
ÉÉ 
item
ÉÉ 
.
ÉÉ 
ValidateYears
ÉÉ 
(
ÉÉ 
request
ÉÉ &
.
ÉÉ& '
Years
ÉÉ' ,
)
ÉÉ, -
is
ÉÉ. 0
string
ÉÉ1 7

yearsError
ÉÉ8 B
)
ÉÉB C
return
ÉÉD J

BadRequest
ÉÉK U
(
ÉÉU V
new
ÉÉV Y
{
ÉÉZ [
message
ÉÉ\ c
=
ÉÉd e

yearsError
ÉÉf p
}
ÉÉq r
)
ÉÉr s
;
ÉÉs t
if
ÑÑ 

(
ÑÑ 
!
ÑÑ 
string
ÑÑ 
.
ÑÑ 
IsNullOrEmpty
ÑÑ !
(
ÑÑ! "
	operation
ÑÑ" +
)
ÑÑ+ ,
&&
ÑÑ- /
await
ÑÑ0 5
db
ÑÑ6 8
.
ÑÑ8 9
TransferReports
ÑÑ9 H
.
ÑÑH I
AnyAsync
ÑÑI Q
(
ÑÑQ R
x
ÑÑR S
=>
ÑÑT V
x
ÑÑW X
.
ÑÑX Y
OperationNumber
ÑÑY h
==
ÑÑi k
	operation
ÑÑl u
&&
ÑÑv x
x
ÑÑy z
.
ÑÑz {
BankAccountIdÑÑ{ à
==ÑÑâ ã
accountÑÑå ì
.ÑÑì î
IdÑÑî ñ
&&ÑÑó ô
xÑÑö õ
.ÑÑõ ú
StatusÑÑú ¢
!=ÑÑ£ •$
TransferReportStatusÑÑ¶ ∫
.ÑÑ∫ ª
	RechazadoÑÑª ƒ
,ÑÑƒ ≈
ctÑÑ∆ »
)ÑÑ» …
)ÑÑ…  
return
ÖÖ 
Conflict
ÖÖ 
(
ÖÖ 
new
ÖÖ 
{
ÖÖ  !
message
ÖÖ" )
=
ÖÖ* +
$str
ÖÖ, S
}
ÖÖT U
)
ÖÖU V
;
ÖÖV W
var
áá 
report
áá 
=
áá 
new
áá 
TransferReport
áá '
{
áá( )
ClientId
áá* 2
=
áá3 4
clientId
áá5 =
,
áá= >
ClientProductId
áá? N
=
ááO P
item
ááQ U
.
ááU V
Id
ááV X
,
ááX Y
BankAccountId
ááZ g
=
ááh i
account
ááj q
.
ááq r
Id
áár t
,
áát u
Amount
ááv |
=
áá} ~
Matháá É
.ááÉ Ñ
RoundááÑ â
(ááâ ä
requestááä ë
.ááë í
Amountááí ò
,ááò ô
$numááö õ
)ááõ ú
,ááú ù
Currencyááû ¶
=ááß ®
accountáá© ∞
.áá∞ ±
Currencyáá± π
,ááπ ∫
PaidAtááª ¡
=áá¬ √
requestááƒ À
.ááÀ Ã
PaidAtááÃ “
,áá“ ”
OperationNumberáá‘ „
=áá‰ Â
stringááÊ Ï
.ááÏ Ì
IsNullOrEmptyááÌ ˙
(áá˙ ˚
	operationáá˚ Ñ
)ááÑ Ö
?ááÜ á
nullááà å
:ááç é
	operationááè ò
,ááò ô
Yearsááö ü
=áá† °
requestáá¢ ©
.áá© ™
Yearsáá™ Ø
,ááØ ∞ 
ReportedByUserIdáá± ¡
=áá¬ √
UserIdááƒ  
}ááÀ Ã
;ááÃ Õ
if
àà 

(
àà 
receipt
àà 
is
àà 
not
àà 
null
àà 
)
àà  
{
ââ 	
if
ää 
(
ää 
receipt
ää 
.
ää 
Length
ää 
==
ää !
$num
ää" #
||
ää$ &
receipt
ää' .
.
ää. /
Length
ää/ 5
>
ää6 7
MaxReceiptBytes
ää8 G
)
ääG H
return
ääI O

BadRequest
ääP Z
(
ääZ [
new
ää[ ^
{
ää_ `
message
ääa h
=
ääi j
$strääk ó
}ääò ô
)ääô ö
;ääö õ
var
ãã 
type
ãã 
=
ãã 
receipt
ãã 
.
ãã 
ContentType
ãã *
?
ãã* +
.
ãã+ ,
ToLowerInvariant
ãã, <
(
ãã< =
)
ãã= >
??
ãã? A
$str
ããB D
;
ããD E
if
åå 
(
åå 
!
åå 
ReceiptTypes
åå 
.
åå 
Contains
åå &
(
åå& '
type
åå' +
)
åå+ ,
)
åå, -
return
åå. 4

BadRequest
åå5 ?
(
åå? @
new
åå@ C
{
ååD E
message
ååF M
=
ååN O
$strååP é
}ååè ê
)ååê ë
;ååë í
using
çç 
var
çç 
stream
çç 
=
çç 
new
çç "
MemoryStream
çç# /
(
çç/ 0
)
çç0 1
;
çç1 2
await
çç3 8
receipt
çç9 @
.
çç@ A
CopyToAsync
ççA L
(
ççL M
stream
ççM S
,
ççS T
ct
ççU W
)
ççW X
;
ççX Y
(
éé 
report
éé 
.
éé 
ReceiptFileName
éé #
,
éé# $
report
éé% +
.
éé+ , 
ReceiptContentType
éé, >
,
éé> ?
report
éé@ F
.
ééF G
ReceiptContent
ééG U
)
ééU V
=
ééW X
(
ééY Z
Path
ééZ ^
.
éé^ _
GetFileName
éé_ j
(
ééj k
receipt
éék r
.
éér s
FileName
éés {
)
éé{ |
,
éé| }
typeéé~ Ç
,ééÇ É
streamééÑ ä
.ééä ã
ToArrayééã í
(ééí ì
)ééì î
)ééî ï
;ééï ñ
}
èè 	
db
êê 

.
êê
 
TransferReports
êê 
.
êê 
Add
êê 
(
êê 
report
êê %
)
êê% &
;
êê& '
await
êê( -
db
êê. 0
.
êê0 1
SaveChangesAsync
êê1 A
(
êêA B
ct
êêB D
)
êêD E
;
êêE F
await
ëë 
NotifyStaffAsync
ëë 
(
ëë 
report
ëë %
,
ëë% &
item
ëë' +
,
ëë+ ,
ct
ëë- /
)
ëë/ 0
;
ëë0 1
return
íí 
Created
íí 
(
íí 
$"
íí 
$str
íí /
{
íí/ 0
report
íí0 6
.
íí6 7
Id
íí7 9
}
íí9 :
"
íí: ;
,
íí; <
new
íí= @#
TransferReportSummary
ííA V
(
ííV W
report
ííW ]
.
íí] ^
Id
íí^ `
,
íí` a
report
ííb h
.
ííh i
Status
ííi o
,
íío p
report
ííq w
.
ííw x
	CreatedAtííx Å
,ííÅ Ç
nullííÉ á
)ííá à
)ííà â
;ííâ ä
}
ìì 
internal
öö 
static
öö 
bool
öö 
CanPayByTransfer
öö )
(
öö) *
ClientProduct
öö* 7
item
öö8 <
,
öö< =
PaymentSettings
öö> M
settings
ööN V
)
ööV W
{
õõ 
if
úú 

(
úú 
!
úú 
settings
úú 
.
úú !
BankTransferEnabled
úú )
||
úú* ,
item
úú- 1
.
úú1 2
Status
úú2 8
==
úú9 ;!
ClientProductStatus
úú< O
.
úúO P
	Cancelado
úúP Y
)
úúY Z
return
úú[ a
false
úúb g
;
úúg h
if
ùù 

(
ùù 
!
ùù 
item
ùù 
.
ùù 
IsManualBilling
ùù !
&&
ùù" $
(
ùù% &
settings
ùù& .
.
ùù. /
PayPalEnabled
ùù/ <
||
ùù= ?
!
ùù@ A
string
ùùA G
.
ùùG H 
IsNullOrWhiteSpace
ùùH Z
(
ùùZ [
item
ùù[ _
.
ùù_ `"
PayPalSubscriptionId
ùù` t
)
ùùt u
)
ùùu v
)
ùùv w
return
ùùx ~
falseùù Ñ
;ùùÑ Ö
if
ûû 

(
ûû 
item
ûû 
.
ûû 
Status
ûû 
==
ûû !
ClientProductStatus
ûû .
.
ûû. /
	Pendiente
ûû/ 8
)
ûû8 9
return
ûû: @
true
ûûA E
;
ûûE F
if
üü 

(
üü 
item
üü 
.
üü 
BillingCycle
üü 
==
üü  
BillingCycle
üü! -
.
üü- .
Unico
üü. 3
)
üü3 4
return
üü5 ;
false
üü< A
;
üüA B
if
†† 

(
†† 
item
†† 
.
†† 
Status
†† 
is
†† !
ClientProductStatus
†† .
.
††. /
	PorVencer
††/ 8
or
††9 ;!
ClientProductStatus
††< O
.
††O P
Vencido
††P W
)
††W X
return
††Y _
true
††` d
;
††d e
var
°° 
due
°° 
=
°° 
item
°° 
.
°° 
BillingCycle
°° #
.
°°# $
IsSubscription
°°$ 2
(
°°2 3
)
°°3 4
?
°°5 6
item
°°7 ;
.
°°; <
NextChargeAt
°°< H
:
°°I J
item
°°K O
.
°°O P
RenewsAt
°°P X
;
°°X Y
return
¢¢ 
due
¢¢ 
is
¢¢ 
DateTime
¢¢ 
date
¢¢ #
&&
¢¢$ &
date
¢¢' +
<=
¢¢, .
DateTime
¢¢/ 7
.
¢¢7 8
UtcNow
¢¢8 >
.
¢¢> ?
AddDays
¢¢? F
(
¢¢F G 
PaymentsController
¢¢G Y
.
¢¢Y Z
RenewalWindowDays
¢¢Z k
)
¢¢k l
;
¢¢l m
}
££ 
private
•• 
async
•• 
Task
•• 
NotifyStaffAsync
•• '
(
••' (
TransferReport
••( 6
report
••7 =
,
••= >
ClientProduct
••? L
item
••M Q
,
••Q R
CancellationToken
••S d
ct
••e g
)
••g h
{
¶¶ 
var
ßß 

staffEmail
ßß 
=
ßß 
configuration
ßß &
[
ßß& '
$str
ßß' A
]
ßßA B
is
ßßC E
{
ßßF G
Length
ßßH N
:
ßßN O
>
ßßP Q
$num
ßßR S
}
ßßT U

configured
ßßV `
?
ßßa b

configured
ßßc m
:
ßßn o
configuration
ßßp }
[
ßß} ~
$strßß~ â
]ßßâ ä
;ßßä ã
if
®® 

(
®® 
string
®® 
.
®®  
IsNullOrWhiteSpace
®® %
(
®®% &

staffEmail
®®& 0
)
®®0 1
)
®®1 2
{
®®3 4
logger
®®5 ;
.
®®; <

LogWarning
®®< F
(
®®F G
$str®®G å
,®®å ç
report®®é î
.®®î ï
Id®®ï ó
)®®ó ò
;®®ò ô
return®®ö †
;®®† °
}®®¢ £
var
©© 
client
©© 
=
©© 
await
©© 
db
©© 
.
©© 
Clients
©© %
.
©©% &
SingleAsync
©©& 1
(
©©1 2
x
©©2 3
=>
©©4 6
x
©©7 8
.
©©8 9
Id
©©9 ;
==
©©< >
report
©©? E
.
©©E F
ClientId
©©F N
,
©©N O
ct
©©P R
)
©©R S
;
©©S T
var
™™ 
data
™™ 
=
™™ 
new
™™ 

Dictionary
™™ !
<
™™! "
string
™™" (
,
™™( )
string
™™* 0
>
™™0 1
{
™™2 3
[
™™4 5
$str
™™5 ?
]
™™? @
=
™™A B
report
™™C I
.
™™I J
Id
™™J L
.
™™L M
ToString
™™M U
(
™™U V
)
™™V W
,
™™W X
[
™™Y Z
$str
™™Z c
]
™™c d
=
™™e f
client
™™g m
.
™™m n
CompanyName
™™n y
,
™™y z
[
™™{ |
$str™™| Ö
]™™Ö Ü
=™™á à
item™™â ç
.™™ç é
Product™™é ï
?™™ï ñ
.™™ñ ó
Name™™ó õ
??™™ú û
$str™™ü °
,™™° ¢
[™™£ §
$str™™§ ¨
]™™¨ ≠
=™™Æ Ø
report™™∞ ∂
.™™∂ ∑
Amount™™∑ Ω
.™™Ω æ
ToString™™æ ∆
(™™∆ «
CultureInfo™™« “
.™™“ ” 
InvariantCulture™™” „
)™™„ ‰
,™™‰ Â
[™™Ê Á
$str™™Á Ò
]™™Ò Ú
=™™Û Ù
report™™ı ˚
.™™˚ ¸
Currency™™¸ Ñ
}™™Ö Ü
;™™Ü á
if
´´ 

(
´´ 
report
´´ 
.
´´ 
OperationNumber
´´ "
is
´´# %
not
´´& )
null
´´* .
)
´´. /
data
´´0 4
[
´´4 5
$str
´´5 @
]
´´@ A
=
´´B C
report
´´D J
.
´´J K
OperationNumber
´´K Z
;
´´Z [
await
¨¨ 
notifications
¨¨ 
.
¨¨ 
	SendAsync
¨¨ %
(
¨¨% &
client
¨¨& ,
,
¨¨, -
new
¨¨. 1
Notification
¨¨2 >
(
¨¨> ?
NotificationType
¨¨? O
.
¨¨O P
TransferReported
¨¨P `
,
¨¨` a
data
¨¨b f
,
¨¨f g
$"
¨¨h j
$str
¨¨j |
{
¨¨| }
report¨¨} É
.¨¨É Ñ
Id¨¨Ñ Ü
}¨¨Ü á
"¨¨á à
,¨¨à â

staffEmail¨¨ä î
)¨¨î ï
,¨¨ï ñ
ct¨¨ó ô
)¨¨ô ö
;¨¨ö õ
}
≠≠ 
[
∞∞ 
HttpGet
∞∞ 
(
∞∞ 
$str
∞∞ 1
)
∞∞1 2
]
∞∞2 3
public
±± 

async
±± 
Task
±± 
<
±± 
ActionResult
±± "
>
±±" #
Receipt
±±$ +
(
±±+ ,
Guid
±±, 0
id
±±1 3
,
±±3 4
CancellationToken
±±5 F
ct
±±G I
)
±±I J
{
≤≤ 
var
≥≥ 
report
≥≥ 
=
≥≥ 
await
≥≥ 
db
≥≥ 
.
≥≥ 
TransferReports
≥≥ -
.
≥≥- ."
SingleOrDefaultAsync
≥≥. B
(
≥≥B C
x
≥≥C D
=>
≥≥E G
x
≥≥H I
.
≥≥I J
Id
≥≥J L
==
≥≥M O
id
≥≥P R
,
≥≥R S
ct
≥≥T V
)
≥≥V W
;
≥≥W X
if
¥¥ 

(
¥¥ 
report
¥¥ 
?
¥¥ 
.
¥¥ 
ReceiptContent
¥¥ "
is
¥¥# %
null
¥¥& *
)
¥¥* +
return
¥¥, 2
NotFound
¥¥3 ;
(
¥¥; <
)
¥¥< =
;
¥¥= >
if
µµ 

(
µµ 
!
µµ 
IsSuperAdmin
µµ 
&&
µµ 
(
µµ 
!
µµ 
Guid
µµ #
.
µµ# $
TryParse
µµ$ ,
(
µµ, -
User
µµ- 1
.
µµ1 2
FindFirstValue
µµ2 @
(
µµ@ A
$str
µµA L
)
µµL M
,
µµM N
out
µµO R
var
µµS V
clientId
µµW _
)
µµ_ `
||
µµa c
clientId
µµd l
!=
µµm o
report
µµp v
.
µµv w
ClientId
µµw 
)µµ Ä
)µµÄ Å
returnµµÇ à
NotFoundµµâ ë
(µµë í
)µµí ì
;µµì î
Response
∂∂ 
.
∂∂ 
Headers
∂∂ 
.
∂∂ 
CacheControl
∂∂ %
=
∂∂& '
$str
∂∂( ;
;
∂∂; <
return
∑∑ 
File
∑∑ 
(
∑∑ 
report
∑∑ 
.
∑∑ 
ReceiptContent
∑∑ )
,
∑∑) *
report
∑∑+ 1
.
∑∑1 2 
ReceiptContentType
∑∑2 D
??
∑∑E G
$str
∑∑H b
,
∑∑b c
report
∑∑d j
.
∑∑j k
ReceiptFileName
∑∑k z
)
∑∑z {
;
∑∑{ |
}
∏∏ 
[
ºº 
HttpGet
ºº 
(
ºº 
$str
ºº %
)
ºº% &
,
ºº& '
	Authorize
ºº( 1
(
ºº1 2
Roles
ºº2 7
=
ºº8 9
$str
ºº: F
)
ººF G
]
ººG H
public
ΩΩ 

async
ΩΩ 
Task
ΩΩ 
<
ΩΩ 
ActionResult
ΩΩ "
>
ΩΩ" #
Reports
ΩΩ$ +
(
ΩΩ+ ,"
TransferReportStatus
ΩΩ, @
?
ΩΩ@ A
status
ΩΩB H
,
ΩΩH I
CancellationToken
ΩΩJ [
ct
ΩΩ\ ^
)
ΩΩ^ _
{
ææ 
var
øø 
query
øø 
=
øø 
from
øø 
report
øø 
in
øø  "
db
øø# %
.
øø% &
TransferReports
øø& 5
join
¿¿ 
client
¿¿ 
in
¿¿  "
db
¿¿# %
.
¿¿% &
Clients
¿¿& -
on
¿¿. 0
report
¿¿1 7
.
¿¿7 8
ClientId
¿¿8 @
equals
¿¿A G
client
¿¿H N
.
¿¿N O
Id
¿¿O Q
join
¡¡ 
item
¡¡ 
in
¡¡  
db
¡¡! #
.
¡¡# $
ClientProducts
¡¡$ 2
on
¡¡3 5
report
¡¡6 <
.
¡¡< =
ClientProductId
¡¡= L
equals
¡¡M S
item
¡¡T X
.
¡¡X Y
Id
¡¡Y [
join
¬¬ 
product
¬¬  
in
¬¬! #
db
¬¬$ &
.
¬¬& '
Products
¬¬' /
on
¬¬0 2
item
¬¬3 7
.
¬¬7 8
	ProductId
¬¬8 A
equals
¬¬B H
product
¬¬I P
.
¬¬P Q
Id
¬¬Q S
join
√√ 
account
√√  
in
√√! #
db
√√$ &
.
√√& '
BankAccounts
√√' 3
on
√√4 6
report
√√7 =
.
√√= >
BankAccountId
√√> K
equals
√√L R
account
√√S Z
.
√√Z [
Id
√√[ ]
into
√√^ b
accounts
√√c k
from
ƒƒ 
account
ƒƒ  
in
ƒƒ! #
accounts
ƒƒ$ ,
.
ƒƒ, -
DefaultIfEmpty
ƒƒ- ;
(
ƒƒ; <
)
ƒƒ< =
where
≈≈ 
status
≈≈  
==
≈≈! #
null
≈≈$ (
||
≈≈) +
report
≈≈, 2
.
≈≈2 3
Status
≈≈3 9
==
≈≈: <
status
≈≈= C
orderby
∆∆ 
report
∆∆ "
.
∆∆" #
Status
∆∆# )
==
∆∆* ,"
TransferReportStatus
∆∆- A
.
∆∆A B
	Pendiente
∆∆B K

descending
∆∆L V
,
∆∆V W
report
∆∆X ^
.
∆∆^ _
	CreatedAt
∆∆_ h

descending
∆∆i s
select
«« 
new
«« 
TransferReportDto
«« 0
(
««0 1
report
««1 7
.
««7 8
Id
««8 :
,
««: ;
report
««< B
.
««B C
ClientId
««C K
,
««K L
client
««M S
.
««S T
CompanyName
««T _
,
««_ `
report
««a g
.
««g h
ClientProductId
««h w
,
««w x
product««y Ä
.««Ä Å
Name««Å Ö
,««Ö Ü
item««á ã
.««ã å

DomainName««å ñ
,««ñ ó
product««ò ü
.««ü †
Currency««† ®
,««® ©
report««™ ∞
.««∞ ±
Amount««± ∑
,««∑ ∏
report««π ø
.««ø ¿
Currency««¿ »
,««» …
report««  –
.««– —
PaidAt««— ◊
,««◊ ÿ
report««Ÿ ﬂ
.««ﬂ ‡
OperationNumber««‡ Ô
,««Ô 
report««Ò ˜
.««˜ ¯
Years««¯ ˝
,««˝ ˛
account
»» 
==
»»  "
null
»»# '
?
»»( )
null
»»* .
:
»»/ 0
account
»»1 8
.
»»8 9
BankName
»»9 A
+
»»B C
$str
»»D G
+
»»H I
account
»»J Q
.
»»Q R
Currency
»»R Z
+
»»[ \
$str
»»] b
+
»»c d
account
»»e l
.
»»l m
AccountNumber
»»m z
,
»»z {
report»»| Ç
.»»Ç É
ReceiptContent»»É ë
!=»»í î
null»»ï ô
,»»ô ö
report»»õ °
.»»° ¢"
ReceiptContentType»»¢ ¥
,»»¥ µ
report»»∂ º
.»»º Ω
Status»»Ω √
,»»√ ƒ
report»»≈ À
.»»À Ã
RejectionReason»»Ã €
,»»€ ‹
report»»› „
.»»„ ‰
	CreatedAt»»‰ Ì
,»»Ì Ó
report»»Ô ı
.»»ı ˆ

ReviewedAt»»ˆ Ä
)»»Ä Å
;»»Å Ç
return
…… 
Ok
…… 
(
…… 
await
…… 
query
…… 
.
…… 
Take
…… "
(
……" #
$num
……# &
)
……& '
.
……' (
ToListAsync
……( 3
(
……3 4
ct
……4 6
)
……6 7
)
……7 8
;
……8 9
}
   
[
–– 
HttpPost
–– 
(
–– 
$str
–– 8
)
––8 9
,
––9 :
	Authorize
––; D
(
––D E
Roles
––E J
=
––K L
$str
––M Y
)
––Y Z
]
––Z [
public
—— 

async
—— 
Task
—— 
<
—— 
ActionResult
—— "
>
——" #
Approve
——$ +
(
——+ ,
Guid
——, 0
id
——1 3
,
——3 4$
ApproveTransferRequest
——5 K
request
——L S
,
——S T
CancellationToken
——U f
ct
——g i
)
——i j
{
““ 
var
”” 
report
”” 
=
”” 
await
”” 
db
”” 
.
”” 
TransferReports
”” -
.
””- ."
SingleOrDefaultAsync
””. B
(
””B C
x
””C D
=>
””E G
x
””H I
.
””I J
Id
””J L
==
””M O
id
””P R
,
””R S
ct
””T V
)
””V W
;
””W X
if
””Y [
(
””\ ]
report
””] c
is
””d f
null
””g k
)
””k l
return
””m s
NotFound
””t |
(
””| }
)
””} ~
;
””~ 
if
‘‘ 

(
‘‘ 
report
‘‘ 
.
‘‘ 
Status
‘‘ 
!=
‘‘ "
TransferReportStatus
‘‘ 1
.
‘‘1 2
	Pendiente
‘‘2 ;
)
‘‘; <
return
‘‘= C
Conflict
‘‘D L
(
‘‘L M
new
‘‘M P
{
‘‘Q R
message
‘‘S Z
=
‘‘[ \
$str
‘‘] y
}
‘‘z {
)
‘‘{ |
;
‘‘| }
var
’’ 
item
’’ 
=
’’ 
await
’’ 
db
’’ 
.
’’ 
ClientProducts
’’ *
.
’’* +
Include
’’+ 2
(
’’2 3
x
’’3 4
=>
’’5 7
x
’’8 9
.
’’9 :
Product
’’: A
)
’’A B
.
’’B C
Include
’’C J
(
’’J K
x
’’K L
=>
’’M O
x
’’P Q
.
’’Q R
Project
’’R Y
)
’’Y Z
.
’’Z [
SingleAsync
’’[ f
(
’’f g
x
’’g h
=>
’’i k
x
’’l m
.
’’m n
Id
’’n p
==
’’q s
report
’’t z
.
’’z {
ClientProductId’’{ ä
,’’ä ã
ct’’å é
)’’é è
;’’è ê
var
÷÷ 
amount
÷÷ 
=
÷÷ 
Math
÷÷ 
.
÷÷ 
Round
÷÷ 
(
÷÷  
request
÷÷  '
.
÷÷' (
Amount
÷÷( .
??
÷÷/ 1
report
÷÷2 8
.
÷÷8 9
Amount
÷÷9 ?
,
÷÷? @
$num
÷÷A B
)
÷÷B C
;
÷÷C D
if
◊◊ 

(
◊◊ 
amount
◊◊ 
<=
◊◊ 
$num
◊◊ 
)
◊◊ 
return
◊◊ 

BadRequest
◊◊  *
(
◊◊* +
new
◊◊+ .
{
◊◊/ 0
message
◊◊1 8
=
◊◊9 :
$str
◊◊; W
}
◊◊X Y
)
◊◊Y Z
;
◊◊Z [
var
ÿÿ 
	operation
ÿÿ 
=
ÿÿ 
(
ÿÿ 
request
ÿÿ  
.
ÿÿ  !
OperationNumber
ÿÿ! 0
??
ÿÿ1 3
report
ÿÿ4 :
.
ÿÿ: ;
OperationNumber
ÿÿ; J
)
ÿÿJ K
?
ÿÿK L
.
ÿÿL M
Trim
ÿÿM Q
(
ÿÿQ R
)
ÿÿR S
;
ÿÿS T
var
ŸŸ 
paidAt
ŸŸ 
=
ŸŸ 
request
ŸŸ 
.
ŸŸ 
PaidAt
ŸŸ #
??
ŸŸ$ &
report
ŸŸ' -
.
ŸŸ- .
PaidAt
ŸŸ. 4
;
ŸŸ4 5
var
⁄⁄ 
key
⁄⁄ 
=
⁄⁄ 
string
⁄⁄ 
.
⁄⁄ 
IsNullOrEmpty
⁄⁄ &
(
⁄⁄& '
	operation
⁄⁄' 0
)
⁄⁄0 1
?
⁄⁄2 3
$"
⁄⁄4 6
$str
⁄⁄6 ;
{
⁄⁄; <
report
⁄⁄< B
.
⁄⁄B C
Id
⁄⁄C E
:
⁄⁄E F
$str
⁄⁄F G
}
⁄⁄G H
"
⁄⁄H I
:
⁄⁄J K
$"
⁄⁄L N
$str
⁄⁄N R
{
⁄⁄R S
	operation
⁄⁄S \
}
⁄⁄\ ]
"
⁄⁄] ^
;
⁄⁄^ _
if
€€ 

(
€€ 
key
€€ 
.
€€ 
Length
€€ 
>
€€ 
$num
€€ 
)
€€ 
return
€€ $

BadRequest
€€% /
(
€€/ 0
new
€€0 3
{
€€4 5
message
€€6 =
=
€€> ?
$str
€€@ h
}
€€i j
)
€€j k
;
€€k l
item
›› 
.
›› 
IsManualBilling
›› 
=
›› 
true
›› #
;
››# $
if
ﬁﬁ 

(
ﬁﬁ 
!
ﬁﬁ 
await
ﬁﬁ 
payments
ﬁﬁ 
.
ﬁﬁ 
ApplyPaymentAsync
ﬁﬁ -
(
ﬁﬁ- .
item
ﬁﬁ. 2
,
ﬁﬁ2 3
key
ﬁﬁ4 7
,
ﬁﬁ7 8
amount
ﬁﬁ9 ?
,
ﬁﬁ? @
report
ﬁﬁA G
.
ﬁﬁG H
Currency
ﬁﬁH P
,
ﬁﬁP Q
ct
ﬁﬁR T
,
ﬁﬁT U
PaymentMethods
ﬁﬁV d
.
ﬁﬁd e
Transferencia
ﬁﬁe r
,
ﬁﬁr s
DateTime
ﬁﬁt |
.
ﬁﬁ| }
SpecifyKindﬁﬁ} à
(ﬁﬁà â
paidAtﬁﬁâ è
.ﬁﬁè ê

ToDateTimeﬁﬁê ö
(ﬁﬁö õ
TimeOnlyﬁﬁõ £
.ﬁﬁ£ §
MinValueﬁﬁ§ ¨
)ﬁﬁ¨ ≠
,ﬁﬁ≠ Æ
DateTimeKindﬁﬁØ ª
.ﬁﬁª º
Utcﬁﬁº ø
)ﬁﬁø ¿
,ﬁﬁ¿ ¡
reportﬁﬁ¬ »
.ﬁﬁ» …
Yearsﬁﬁ… Œ
)ﬁﬁŒ œ
)ﬁﬁœ –
return
ﬂﬂ 
Conflict
ﬂﬂ 
(
ﬂﬂ 
new
ﬂﬂ 
{
ﬂﬂ  !
message
ﬂﬂ" )
=
ﬂﬂ* +
$str
ﬂﬂ, o
}
ﬂﬂp q
)
ﬂﬂq r
;
ﬂﬂr s
item
‡‡ 
.
‡‡ 
Status
‡‡ 
=
‡‡  
RenewalReminderJob
‡‡ (
.
‡‡( )
	StatusFor
‡‡) 2
(
‡‡2 3
item
‡‡3 7
.
‡‡7 8
Status
‡‡8 >
,
‡‡> ?
item
‡‡@ D
.
‡‡D E
RenewsAt
‡‡E M
,
‡‡M N
DateTime
‡‡O W
.
‡‡W X
UtcNow
‡‡X ^
)
‡‡^ _
;
‡‡_ `
(
·· 	
report
··	 
.
·· 
Status
·· 
,
·· 
report
·· 
.
·· 
Amount
·· %
,
··% &
report
··' -
.
··- .
OperationNumber
··. =
,
··= >
report
··? E
.
··E F
PaidAt
··F L
,
··L M
report
··N T
.
··T U

ReviewedAt
··U _
,
··_ `
report
··a g
.
··g h
ReviewedByUserId
··h x
)
··x y
=
··z {
(
··| }#
TransferReportStatus··} ë
.··ë í
Aprobado··í ö
,··ö õ
amount··ú ¢
,··¢ £
string··§ ™
.··™ ´
IsNullOrEmpty··´ ∏
(··∏ π
	operation··π ¬
)··¬ √
?··ƒ ≈
null··∆  
:··À Ã
	operation··Õ ÷
,··÷ ◊
paidAt··ÿ ﬁ
,··ﬁ ﬂ
DateTime··‡ Ë
.··Ë È
UtcNow··È Ô
,··Ô 
UserId··Ò ˜
)··˜ ¯
;··¯ ˘
report
‚‚ 
.
‚‚ "
PaymentTransactionId
‚‚ #
=
‚‚$ %
await
‚‚& +
db
‚‚, .
.
‚‚. /!
PaymentTransactions
‚‚/ B
.
‚‚B C
Where
‚‚C H
(
‚‚H I
x
‚‚I J
=>
‚‚K M
x
‚‚N O
.
‚‚O P+
PayPalOrderIdOrSubscriptionId
‚‚P m
==
‚‚n p
key
‚‚q t
)
‚‚t u
.
‚‚u v
Select
‚‚v |
(
‚‚| }
x
‚‚} ~
=>‚‚ Å
(‚‚Ç É
Guid‚‚É á
?‚‚á à
)‚‚à â
x‚‚â ä
.‚‚ä ã
Id‚‚ã ç
)‚‚ç é
.‚‚é è$
SingleOrDefaultAsync‚‚è £
(‚‚£ §
ct‚‚§ ¶
)‚‚¶ ß
;‚‚ß ®
await
„„ 
db
„„ 
.
„„ 
SaveChangesAsync
„„ !
(
„„! "
ct
„„" $
)
„„$ %
;
„„% &
return
‰‰ 
Ok
‰‰ 
(
‰‰ 
new
‰‰ 
{
‰‰ 
status
‰‰ 
=
‰‰  
report
‰‰! '
.
‰‰' (
Status
‰‰( .
,
‰‰. /!
clientProductStatus
‰‰0 C
=
‰‰D E
item
‰‰F J
.
‰‰J K
Status
‰‰K Q
}
‰‰R S
)
‰‰S T
;
‰‰T U
}
ÂÂ 
[
ÁÁ 
HttpPost
ÁÁ 
(
ÁÁ 
$str
ÁÁ 7
)
ÁÁ7 8
,
ÁÁ8 9
	Authorize
ÁÁ: C
(
ÁÁC D
Roles
ÁÁD I
=
ÁÁJ K
$str
ÁÁL X
)
ÁÁX Y
]
ÁÁY Z
public
ËË 

async
ËË 
Task
ËË 
<
ËË 
ActionResult
ËË "
>
ËË" #
Reject
ËË$ *
(
ËË* +
Guid
ËË+ /
id
ËË0 2
,
ËË2 3#
RejectTransferRequest
ËË4 I
request
ËËJ Q
,
ËËQ R
CancellationToken
ËËS d
ct
ËËe g
)
ËËg h
{
ÈÈ 
var
ÍÍ 
report
ÍÍ 
=
ÍÍ 
await
ÍÍ 
db
ÍÍ 
.
ÍÍ 
TransferReports
ÍÍ -
.
ÍÍ- ."
SingleOrDefaultAsync
ÍÍ. B
(
ÍÍB C
x
ÍÍC D
=>
ÍÍE G
x
ÍÍH I
.
ÍÍI J
Id
ÍÍJ L
==
ÍÍM O
id
ÍÍP R
,
ÍÍR S
ct
ÍÍT V
)
ÍÍV W
;
ÍÍW X
if
ÍÍY [
(
ÍÍ\ ]
report
ÍÍ] c
is
ÍÍd f
null
ÍÍg k
)
ÍÍk l
return
ÍÍm s
NotFound
ÍÍt |
(
ÍÍ| }
)
ÍÍ} ~
;
ÍÍ~ 
if
ÎÎ 

(
ÎÎ 
report
ÎÎ 
.
ÎÎ 
Status
ÎÎ 
!=
ÎÎ "
TransferReportStatus
ÎÎ 1
.
ÎÎ1 2
	Pendiente
ÎÎ2 ;
)
ÎÎ; <
return
ÎÎ= C
Conflict
ÎÎD L
(
ÎÎL M
new
ÎÎM P
{
ÎÎQ R
message
ÎÎS Z
=
ÎÎ[ \
$str
ÎÎ] y
}
ÎÎz {
)
ÎÎ{ |
;
ÎÎ| }
var
ÏÏ 
reason
ÏÏ 
=
ÏÏ 
request
ÏÏ 
.
ÏÏ 
Reason
ÏÏ #
?
ÏÏ# $
.
ÏÏ$ %
Trim
ÏÏ% )
(
ÏÏ) *
)
ÏÏ* +
;
ÏÏ+ ,
if
ÌÌ 

(
ÌÌ 
string
ÌÌ 
.
ÌÌ 
IsNullOrEmpty
ÌÌ  
(
ÌÌ  !
reason
ÌÌ! '
)
ÌÌ' (
)
ÌÌ( )
return
ÌÌ* 0

BadRequest
ÌÌ1 ;
(
ÌÌ; <
new
ÌÌ< ?
{
ÌÌ@ A
message
ÌÌB I
=
ÌÌJ K
$strÌÌL Ç
}ÌÌÉ Ñ
)ÌÌÑ Ö
;ÌÌÖ Ü
if
ÓÓ 

(
ÓÓ 
reason
ÓÓ 
.
ÓÓ 
Length
ÓÓ 
>
ÓÓ 
$num
ÓÓ 
)
ÓÓ  
return
ÓÓ! '

BadRequest
ÓÓ( 2
(
ÓÓ2 3
new
ÓÓ3 6
{
ÓÓ7 8
message
ÓÓ9 @
=
ÓÓA B
$str
ÓÓC z
}
ÓÓ{ |
)
ÓÓ| }
;
ÓÓ} ~
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
ÔÔ 
RejectionReason
ÔÔ .
,
ÔÔ. /
report
ÔÔ0 6
.
ÔÔ6 7

ReviewedAt
ÔÔ7 A
,
ÔÔA B
report
ÔÔC I
.
ÔÔI J
ReviewedByUserId
ÔÔJ Z
)
ÔÔZ [
=
ÔÔ\ ]
(
ÔÔ^ _"
TransferReportStatus
ÔÔ_ s
.
ÔÔs t
	Rechazado
ÔÔt }
,
ÔÔ} ~
reasonÔÔ Ö
,ÔÔÖ Ü
DateTimeÔÔá è
.ÔÔè ê
UtcNowÔÔê ñ
,ÔÔñ ó
UserIdÔÔò û
)ÔÔû ü
;ÔÔü †
await
 
db
 
.
 
SaveChangesAsync
 !
(
! "
ct
" $
)
$ %
;
% &
var
ÒÒ 
product
ÒÒ 
=
ÒÒ 
await
ÒÒ 
db
ÒÒ 
.
ÒÒ 
ClientProducts
ÒÒ -
.
ÒÒ- .
Where
ÒÒ. 3
(
ÒÒ3 4
x
ÒÒ4 5
=>
ÒÒ6 8
x
ÒÒ9 :
.
ÒÒ: ;
Id
ÒÒ; =
==
ÒÒ> @
report
ÒÒA G
.
ÒÒG H
ClientProductId
ÒÒH W
)
ÒÒW X
.
ÒÒX Y
Select
ÒÒY _
(
ÒÒ_ `
x
ÒÒ` a
=>
ÒÒb d
x
ÒÒe f
.
ÒÒf g

DomainName
ÒÒg q
??
ÒÒr t
x
ÒÒu v
.
ÒÒv w
Product
ÒÒw ~
!
ÒÒ~ 
.ÒÒ Ä
NameÒÒÄ Ñ
)ÒÒÑ Ö
.ÒÒÖ Ü
SingleAsyncÒÒÜ ë
(ÒÒë í
ctÒÒí î
)ÒÒî ï
;ÒÒï ñ
if
ÚÚ 

(
ÚÚ 
await
ÚÚ 
db
ÚÚ 
.
ÚÚ 
Clients
ÚÚ 
.
ÚÚ 
	FindAsync
ÚÚ &
(
ÚÚ& '
[
ÚÚ' (
report
ÚÚ( .
.
ÚÚ. /
ClientId
ÚÚ/ 7
]
ÚÚ7 8
,
ÚÚ8 9
ct
ÚÚ: <
)
ÚÚ< =
is
ÚÚ> @
Client
ÚÚA G
client
ÚÚH N
)
ÚÚN O
await
ÛÛ 
notifications
ÛÛ 
.
ÛÛ  
	SendAsync
ÛÛ  )
(
ÛÛ) *
client
ÛÛ* 0
,
ÛÛ0 1
new
ÛÛ2 5
Notification
ÛÛ6 B
(
ÛÛB C
NotificationType
ÛÛC S
.
ÛÛS T
TransferRejected
ÛÛT d
,
ÛÛd e
new
ÛÛf i
(
ÛÛi j
)
ÛÛj k
{
ÛÛl m
[
ÛÛn o
$str
ÛÛo x
]
ÛÛx y
=
ÛÛz {
productÛÛ| É
,ÛÛÉ Ñ
[ÛÛÖ Ü
$strÛÛÜ é
]ÛÛé è
=ÛÛê ë
reportÛÛí ò
.ÛÛò ô
AmountÛÛô ü
.ÛÛü †
ToStringÛÛ† ®
(ÛÛ® ©
CultureInfoÛÛ© ¥
.ÛÛ¥ µ 
InvariantCultureÛÛµ ≈
)ÛÛ≈ ∆
,ÛÛ∆ «
[ÛÛ» …
$strÛÛ… ”
]ÛÛ” ‘
=ÛÛ’ ÷
reportÛÛ◊ ›
.ÛÛ› ﬁ
CurrencyÛÛﬁ Ê
,ÛÛÊ Á
[ÛÛË È
$strÛÛÈ Ò
]ÛÛÒ Ú
=ÛÛÛ Ù
reasonÛÛı ˚
}ÛÛ¸ ˝
,ÛÛ˝ ˛
$"ÛÛˇ Å
$strÛÛÅ ì
{ÛÛì î
reportÛÛî ö
.ÛÛö õ
IdÛÛõ ù
}ÛÛù û
"ÛÛû ü
)ÛÛü †
,ÛÛ† °
ctÛÛ¢ §
)ÛÛ§ •
;ÛÛ• ¶
return
ÙÙ 
Ok
ÙÙ 
(
ÙÙ 
new
ÙÙ 
{
ÙÙ 
status
ÙÙ 
=
ÙÙ  
report
ÙÙ! '
.
ÙÙ' (
Status
ÙÙ( .
}
ÙÙ/ 0
)
ÙÙ0 1
;
ÙÙ1 2
}
ıı 
}ˆˆ 
public¯¯ 
sealed
¯¯ 
record
¯¯ $
PaymentSettingsRequest
¯¯ +
(
¯¯+ ,
bool
¯¯, 0
?
¯¯0 1
PayPal
¯¯2 8
,
¯¯8 9
bool
¯¯: >
?
¯¯> ?
BankTransfer
¯¯@ L
)
¯¯L M
;
¯¯M N
public˘˘ 
sealed
˘˘ 
record
˘˘  
BankAccountRequest
˘˘ '
(
˘˘' (
string
˘˘( .
?
˘˘. /
BankName
˘˘0 8
,
˘˘8 9
string
˘˘: @
?
˘˘@ A
Holder
˘˘B H
,
˘˘H I
string
˘˘J P
?
˘˘P Q
Currency
˘˘R Z
,
˘˘Z [
BankAccountType
˘˘\ k
Type
˘˘l p
,
˘˘p q
string
˘˘r x
?
˘˘x y
AccountNumber˘˘z á
,˘˘á à
string˘˘â è
?˘˘è ê
Cci˘˘ë î
,˘˘î ï
bool˘˘ñ ö
IsActive˘˘õ £
=˘˘§ •
true˘˘¶ ™
)˘˘™ ´
;˘˘´ ¨
public˙˙ 
sealed
˙˙ 
class
˙˙ #
TransferReportRequest
˙˙ )
{
˙˙* +
public
˙˙, 2
Guid
˙˙3 7
BankAccountId
˙˙8 E
{
˙˙F G
get
˙˙H K
;
˙˙K L
set
˙˙M P
;
˙˙P Q
}
˙˙R S
public
˙˙T Z
decimal
˙˙[ b
Amount
˙˙c i
{
˙˙j k
get
˙˙l o
;
˙˙o p
set
˙˙q t
;
˙˙t u
}
˙˙v w
public
˙˙x ~
DateOnly˙˙ á
PaidAt˙˙à é
{˙˙è ê
get˙˙ë î
;˙˙î ï
set˙˙ñ ô
;˙˙ô ö
}˙˙õ ú
public˙˙ù £
string˙˙§ ™
?˙˙™ ´
OperationNumber˙˙¨ ª
{˙˙º Ω
get˙˙æ ¡
;˙˙¡ ¬
set˙˙√ ∆
;˙˙∆ «
}˙˙» …
public˙˙  –
int˙˙— ‘
Years˙˙’ ⁄
{˙˙€ ‹
get˙˙› ‡
;˙˙‡ ·
set˙˙‚ Â
;˙˙Â Ê
}˙˙Á Ë
=˙˙È Í
$num˙˙Î Ï
;˙˙Ï Ì
}˙˙Ó Ô
public˚˚ 
sealed
˚˚ 
record
˚˚ $
ApproveTransferRequest
˚˚ +
(
˚˚+ ,
decimal
˚˚, 3
?
˚˚3 4
Amount
˚˚5 ;
,
˚˚; <
DateOnly
˚˚= E
?
˚˚E F
PaidAt
˚˚G M
,
˚˚M N
string
˚˚O U
?
˚˚U V
OperationNumber
˚˚W f
)
˚˚f g
;
˚˚g h
public¸¸ 
sealed
¸¸ 
record
¸¸ #
RejectTransferRequest
¸¸ *
(
¸¸* +
string
¸¸+ 1
?
¸¸1 2
Reason
¸¸3 9
)
¸¸9 :
;
¸¸: ;
public˝˝ 
sealed
˝˝ 
record
˝˝ 
TransferReportDto
˝˝ &
(
˝˝& '
Guid
˝˝' +
Id
˝˝, .
,
˝˝. /
Guid
˝˝0 4
ClientId
˝˝5 =
,
˝˝= >
string
˝˝? E
Company
˝˝F M
,
˝˝M N
Guid
˝˝O S
ClientProductId
˝˝T c
,
˝˝c d
string
˝˝e k
Product
˝˝l s
,
˝˝s t
string
˝˝u {
?
˝˝{ |

DomainName˝˝} á
,˝˝á à
string˝˝â è
ProductCurrency˝˝ê ü
,˝˝ü †
decimal˝˝° ®
Amount˝˝© Ø
,˝˝Ø ∞
string˝˝± ∑
Currency˝˝∏ ¿
,˝˝¿ ¡
DateOnly˝˝¬  
PaidAt˝˝À —
,˝˝— “
string˝˝” Ÿ
?˝˝Ÿ ⁄
OperationNumber˝˝€ Í
,˝˝Í Î
int˝˝Ï Ô
Years˝˝ ı
,˝˝ı ˆ
string˝˝˜ ˝
?˝˝˝ ˛
Account˝˝ˇ Ü
,˝˝Ü á
bool˝˝à å

HasReceipt˝˝ç ó
,˝˝ó ò
string˝˝ô ü
?˝˝ü †"
ReceiptContentType˝˝° ≥
,˝˝≥ ¥$
TransferReportStatus˝˝µ …
Status˝˝  –
,˝˝– —
string˝˝“ ÿ
?˝˝ÿ Ÿ
RejectionReason˝˝⁄ È
,˝˝È Í
DateTime˝˝Î Û
	CreatedAt˝˝Ù ˝
,˝˝˝ ˛
DateTime˝˝ˇ á
?˝˝á à

ReviewedAt˝˝â ì
)˝˝ì î
;˝˝î ïœ¸
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.AnnualTax.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
public 
sealed 
partial 
class 
AdminController +
{ 
[ 
HttpGet 
( 
$str "
)" #
]# $
public 

async 
Task 
< 
ActionResult "
>" #
AnnualTaxSettings$ 5
(5 6
CancellationToken6 G
ctH J
)J K
=>L N
OkO Q
(Q R
awaitR W
dbX Z
.Z [
AnnualTaxSettings[ l
.l m
OrderByDescendingm ~
(~ 
x	 Ä
=>
Å É
x
Ñ Ö
.
Ö Ü
Year
Ü ä
)
ä ã
.
ã å
ToListAsync
å ó
(
ó ò
ct
ò ö
)
ö õ
)
õ ú
;
ú ù
[ 
HttpPut 
( 
$str -
)- .
]. /
public 

async 
Task 
< 
ActionResult "
>" #!
SaveAnnualTaxSettings$ 9
(9 :
int: =
year> B
,B C$
AnnualTaxSettingsRequestD \
request] d
,d e
CancellationTokenf w
ctx z
)z {
{ 
if 

( 
year 
is 
< 
$num 
or 
> 
$num  $
)$ %
return& ,

BadRequest- 7
(7 8
new8 ;
{< =
message> E
=F G
$strH W
}X Y
)Y Z
;Z [
if 

( 
request 
. 
Uit 
<= 
$num 
) 
return $

BadRequest% /
(/ 0
new0 3
{4 5
message6 =
=> ?
$str@ d
}e f
)f g
;g h
if 

( 
request 
. 
ThresholdUits !
<=" $
$num% &
||' )
request* 1
.1 2
LowRate2 9
is: <
<= >
$num? @
orA C
>D E
$numF G
||H J
requestK R
.R S
HighRateS [
is\ ^
<_ `
$numa b
orc e
>f g
$numh i
)i j
returnk q

BadRequestr |
(| }
new	} Ä
{
Å Ç
message
É ä
=
ã å
$str
ç Ó
}
Ô 
)
 Ò
;
Ò Ú
var 
row 
= 
await 
db 
. 
AnnualTaxSettings ,
., - 
SingleOrDefaultAsync- A
(A B
xB C
=>D F
xG H
.H I
YearI M
==N P
yearQ U
,U V
ctW Y
)Y Z
;Z [
if 

( 
row 
is 
null 
) 
{ 
row 
=  
new! $
AnnualTaxSettings% 6
{7 8
Year9 =
=> ?
year@ D
}E F
;F G
dbH J
.J K
AnnualTaxSettingsK \
.\ ]
Add] `
(` a
rowa d
)d e
;e f
}g h
( 	
row	 
. 
Uit 
, 
row 
. 
ThresholdUits #
,# $
row% (
.( )
LowRate) 0
,0 1
row2 5
.5 6
HighRate6 >
)> ?
=@ A
(B C
requestC J
.J K
UitK N
,N O
requestP W
.W X
ThresholdUitsX e
,e f
requestg n
.n o
LowRateo v
,v w
requestx 
.	 Ä
HighRate
Ä à
)
à â
;
â ä
await 
db 
. 
SaveChangesAsync !
(! "
ct" $
)$ %
;% &
return 
Ok 
( 
row 
) 
; 
} 
['' 
HttpGet'' 
('' 
$str'' #
)''# $
]''$ %
public(( 

async(( 
Task(( 
<(( 
ActionResult(( "
>((" #
AnnualRentaReport(($ 5
(((5 6
int((6 9
year((: >
,((> ?
CancellationToken((@ Q
ct((R T
)((T U
=>((V X
await((Y ^
AnnualRentaAsync((_ o
(((o p
year((p t
,((t u
DateTime((v ~
.((~ 
UtcNow	(( Ö
,
((Ö Ü
ct
((á â
)
((â ä
;
((ä ã
internal** 
async** 
Task** 
<** 
ActionResult** $
>**$ %
AnnualRentaAsync**& 6
(**6 7
int**7 :
year**; ?
,**? @
DateTime**A I
utcNow**J P
,**P Q
CancellationToken**R c
ct**d f
)**f g
{++ 
var,, 
annual,, 
=,, 
await,, 
db,, 
.,, 
AnnualTaxSettings,, /
.,,/ 0 
SingleOrDefaultAsync,,0 D
(,,D E
x,,E F
=>,,G I
x,,J K
.,,K L
Year,,L P
==,,Q S
year,,T X
,,,X Y
ct,,Z \
),,\ ]
;,,] ^
if-- 

(-- 
annual-- 
is-- 
null-- 
)-- 
return-- "
NotFound--# +
(--+ ,
new--, /
{--0 1
message--2 9
=--: ;
$"--< >
$str--> R
{--R S
year--S W
}--W X
$str--X x
"--x y
}--z {
)--{ |
;--| }
var.. 
settings.. 
=.. 
await.. 
TaxSettingsRow.. +
(..+ ,
ct.., .
)... /
;../ 0
var// 
(// 
from// 
,// 
to// 
)// 
=// 
(// 
new// 
DateOnly// &
(//& '
year//' +
,//+ ,
$num//- .
,//. /
$num//0 1
)//1 2
,//2 3
new//4 7
DateOnly//8 @
(//@ A
year//A E
,//E F
$num//G I
,//I J
$num//K M
)//M N
)//N O
;//O P
var00 
sales00 
=00 
await00 

SalesAsync00 $
(00$ %
from00% )
,00) *
to00+ -
,00- .
ct00/ 1
)001 2
;002 3
var11 
expenses11 
=11 
await11 
db11 
.11  
Expenses11  (
.11( )
Include11) 0
(110 1
x111 2
=>113 5
x116 7
.117 8
Category118 @
)11@ A
.11A B
Where11B G
(11G H
x11H I
=>11J L
x11M N
.11N O
Date11O S
>=11T V
from11W [
&&11\ ^
x11_ `
.11` a
Date11a e
<=11f h
to11i k
)11k l
.11l m
ToListAsync11m x
(11x y
ct11y {
)11{ |
;11| }
var22 
filed22 
=22 
await22 
db22 
.22 
TaxDueDates22 (
.22( )
Where22) .
(22. /
x22/ 0
=>221 3
x224 5
.225 6
Period226 <
>=22= ?
from22@ D
&&22E G
x22H I
.22I J
Period22J P
<=22Q S
to22T V
)22V W
.22W X
ToDictionaryAsync22X i
(22i j
x22j k
=>22l n
x22o p
.22p q
Period22q w
.22w x
Month22x }
,22} ~
ct	22 Å
)
22Å Ç
;
22Ç É
var33 
today33 
=33 
DateOnly33 
.33 
FromDateTime33 )
(33) *
utcNow33* 0
.330 1
AddHours331 9
(339 :
-33: ;
$num33; <
)33< =
)33= >
;33> ?
var55 
	lastMonth55 
=55 
year55 
<55 
today55 $
.55$ %
Year55% )
?55* +
$num55, .
:55/ 0
year551 5
==556 8
today559 >
.55> ?
Year55? C
?55D E
today55F K
.55K L
Month55L Q
:55R S
$num55T U
;55U V
var77 
months77 
=77 

Enumerable77 
.77  
Range77  %
(77% &
$num77& '
,77' (
$num77) +
)77+ ,
.77, -
Select77- 3
(773 4
m774 5
=>776 8
{88 	
var99 
start99 
=99 
new99 
DateOnly99 $
(99$ %
year99% )
,99) *
m99+ ,
,99, -
$num99. /
)99/ 0
;990 1
var992 5
end996 9
=99: ;
start99< A
.99A B
	AddMonths99B K
(99K L
$num99L M
)99M N
.99N O
AddDays99O V
(99V W
-99W X
$num99X Y
)99Y Z
;99Z [
var:: 
ventas:: 
=:: 
sales:: 
.:: 
Where:: $
(::$ %
x::% &
=>::' )
x::* +
.::+ ,
Mype::, 0
&&::1 3
x::4 5
.::5 6
Date::6 :
>=::; =
start::> C
&&::D F
x::G H
.::H I
Date::I M
<=::N P
end::Q T
)::T U
.::U V
Sum::V Y
(::Y Z
x::Z [
=>::\ ^
x::_ `
.::` a
BasePen::a h
)::h i
;::i j
var;; 
gastos;; 
=;; 
expenses;; !
.;;! "
Where;;" '
(;;' (
x;;( )
=>;;* ,
x;;- .
.;;. /
Date;;/ 3
>=;;4 6
start;;7 <
&&;;= ?
x;;@ A
.;;A B
Date;;B F
<=;;G I
end;;J M
&&;;N P
IsDeductible;;Q ]
(;;] ^
x;;^ _
);;_ `
);;` a
.;;a b
Sum;;b e
(;;e f
x;;f g
=>;;h j
x;;k l
.;;l m
	AmountPen;;m v
);;v w
;;;w x
var<< 
paid<< 
=<< 
filed<< 
.<< 
TryGetValue<< (
(<<( )
m<<) *
,<<* +
out<<, /
var<<0 3
row<<4 7
)<<7 8
?<<9 :
row<<; >
.<<> ?
	RentaPaid<<? H
:<<I J
null<<K O
;<<O P
var== 
pago== 
=== 
m== 
>== 
	lastMonth== $
?==% &
$num==' )
:==* +
paid==, 0
??==1 3
Math==4 8
.==8 9
Round==9 >
(==> ?
ventas==? E
*==F G
settings==H P
.==P Q
	RentaRate==Q Z
,==Z [
$num==\ ]
)==] ^
;==^ _
return>> 
new>> 
AnnualMonth>> "
(>>" #
start>># (
.>>( )
ToString>>) 1
(>>1 2
$str>>2 ;
)>>; <
,>>< =
Math>>> B
.>>B C
Round>>C H
(>>H I
ventas>>I O
,>>O P
$num>>Q R
)>>R S
,>>S T
Math>>U Y
.>>Y Z
Round>>Z _
(>>_ `
gastos>>` f
,>>f g
$num>>h i
)>>i j
,>>j k
pago>>l p
,>>p q
m>>r s
<=>>t v
	lastMonth	>>w Ä
&&
>>Å É
paid
>>Ñ à
is
>>â ã
null
>>å ê
)
>>ê ë
;
>>ë í
}?? 	
)??	 

.??
 
ToList?? 
(?? 
)?? 
;?? 
varAA 

ventasMypeAA 
=AA 
monthsAA 
.AA  
SumAA  #
(AA# $
xAA$ %
=>AA& (
xAA) *
.AA* +
	VentasPenAA+ 4
)AA4 5
;AA5 6
varAA7 :

deduciblesAA; E
=AAF G
monthsAAH N
.AAN O
SumAAO R
(AAR S
xAAS T
=>AAU W
xAAX Y
.AAY Z
	GastosPenAAZ c
)AAc d
;AAd e
varBB 
noDeduciblesBB 
=BB 
expensesBB #
.BB# $
WhereBB$ )
(BB) *
xBB* +
=>BB, .
!BB/ 0
IsDeductibleBB0 <
(BB< =
xBB= >
)BB> ?
&&BB@ B
xBBC D
.BBD E
CategoryBBE M
?BBM N
.BBN O
IsIncomeTaxBBO Z
!=BB[ ]
trueBB^ b
)BBb c
.BBc d
GroupByBBd k
(BBk l
xBBl m
=>BBn p
xBBq r
.BBr s
DescriptionBBs ~
.BB~ 
Trim	BB É
(
BBÉ Ñ
)
BBÑ Ö
)
BBÖ Ü
.
BBÜ á
Select
BBá ç
(
BBç é
g
BBé è
=>
BBê í
new
BBì ñ
{
BBó ò
descripcion
BBô §
=
BB• ¶
g
BBß ®
.
BB® ©
Key
BB© ¨
,
BB¨ ≠
monto
BBÆ ≥
=
BB¥ µ
Math
BB∂ ∫
.
BB∫ ª
Round
BBª ¿
(
BB¿ ¡
g
BB¡ ¬
.
BB¬ √
Sum
BB√ ∆
(
BB∆ «
x
BB« »
=>
BB… À
x
BBÃ Õ
.
BBÕ Œ
	AmountPen
BBŒ ◊
)
BB◊ ÿ
,
BBÿ Ÿ
$num
BB⁄ €
)
BB€ ‹
}
BB› ﬁ
)
BBﬁ ﬂ
.
BBﬂ ‡
OrderByDescending
BB‡ Ò
(
BBÒ Ú
x
BBÚ Û
=>
BBÙ ˆ
x
BB˜ ¯
.
BB¯ ˘
monto
BB˘ ˛
)
BB˛ ˇ
.
BBˇ Ä
ToList
BBÄ Ü
(
BBÜ á
)
BBá à
;
BBà â
varCC 
rentaCC 
=CC 

ventasMypeCC 
-CC  

deduciblesCC! +
;CC+ ,
varDD 
impuestoDD 
=DD 
MypeIncomeTaxDD $
.DD$ %
ComputeDD% ,
(DD, -
rentaDD- 2
,DD2 3
annualDD4 :
)DD: ;
;DD; <
varEE 
pagosEE 
=EE 
monthsEE 
.EE 
SumEE 
(EE 
xEE  
=>EE! #
xEE$ %
.EE% &
PagoACuentaPenEE& 4
)EE4 5
;EE5 6
objectHH 
?HH 

proyeccionHH 
=HH 
nullHH !
;HH! "
ifII 

(II 
yearII 
==II 
todayII 
.II 
YearII 
&&II !
todayII" '
.II' (
MonthII( -
<II. /
$numII0 2
&&II3 5
todayII6 ;
.II; <
MonthII< A
>IIB C
$numIID E
)IIE F
{JJ 	
varKK 
closedKK 
=KK 
monthsKK 
.KK  
TakeKK  $
(KK$ %
todayKK% *
.KK* +
MonthKK+ 0
-KK1 2
$numKK3 4
)KK4 5
.KK5 6
ToListKK6 <
(KK< =
)KK= >
;KK> ?
varLL 
ventasPLL 
=LL 
closedLL  
.LL  !
AverageLL! (
(LL( )
xLL) *
=>LL+ -
xLL. /
.LL/ 0
	VentasPenLL0 9
)LL9 :
*LL; <
$numLL= ?
;LL? @
varLLA D
gastosPLLE L
=LLM N
closedLLO U
.LLU V
AverageLLV ]
(LL] ^
xLL^ _
=>LL` b
xLLc d
.LLd e
	GastosPenLLe n
)LLn o
*LLp q
$numLLr t
;LLt u
varMM 
	impuestoPMM 
=MM 
MypeIncomeTaxMM )
.MM) *
ComputeMM* 1
(MM1 2
ventasPMM2 9
-MM: ;
gastosPMM< C
,MMC D
annualMME K
)MMK L
;MML M
varNN 
pagosPNN 
=NN 
MathNN 
.NN 
RoundNN #
(NN# $
ventasPNN$ +
*NN, -
settingsNN. 6
.NN6 7
	RentaRateNN7 @
,NN@ A
$numNNB C
)NNC D
;NND E

proyeccionOO 
=OO 
newOO 
{OO 
	mesesBaseOO (
=OO) *
closedOO+ 1
.OO1 2
CountOO2 7
,OO7 8
	ventasPenOO9 B
=OOC D
MathOOE I
.OOI J
RoundOOJ O
(OOO P
ventasPOOP W
,OOW X
$numOOY Z
)OOZ [
,OO[ \
gastosDeduciblesPenOO] p
=OOq r
MathOOs w
.OOw x
RoundOOx }
(OO} ~
gastosP	OO~ Ö
,
OOÖ Ü
$num
OOá à
)
OOà â
,
OOâ ä
rentaNetaPen
OOã ó
=
OOò ô
Math
OOö û
.
OOû ü
Round
OOü §
(
OO§ •
ventasP
OO• ¨
-
OO≠ Æ
gastosP
OOØ ∂
,
OO∂ ∑
$num
OO∏ π
)
OOπ ∫
,
OO∫ ª
impuesto
OOº ƒ
=
OO≈ ∆
	impuestoP
OO« –
,
OO– —
pagosACuentaPen
OO“ ·
=
OO‚ „
pagosP
OO‰ Í
,
OOÍ Î
saldoPen
OOÏ Ù
=
OOı ˆ
Math
OO˜ ˚
.
OO˚ ¸
Round
OO¸ Å
(
OOÅ Ç
	impuestoP
OOÇ ã
.
OOã å
Total
OOå ë
-
OOí ì
pagosP
OOî ö
,
OOö õ
$num
OOú ù
)
OOù û
}
OOü †
;
OO† °
}PP 	
varRR 
naturalRR 
=RR 
salesRR 
.RR 
WhereRR !
(RR! "
xRR" #
=>RR$ &
xRR' (
.RR( )
PersonaNaturalRR) 7
)RR7 8
.RR8 9
ToListRR9 ?
(RR? @
)RR@ A
;RRA B
returnSS 
OkSS 
(SS 
newSS 
{TT 	
yearUU 
,UU 
uitUU 
=UU 
annualUU 
.UU 
UitUU "
,UU" #
tasasUU$ )
=UU* +
newUU, /
{UU0 1
annualUU2 8
.UU8 9
ThresholdUitsUU9 F
,UUF G
annualUUH N
.UUN O
LowRateUUO V
,UUV W
annualUUX ^
.UU^ _
HighRateUU_ g
,UUg h
pagoACuentaUUi t
=UUu v
settingsUUw 
.	UU Ä
	RentaRate
UUÄ â
}
UUä ã
,
UUã å
ventasMypePenVV 
=VV 
MathVV  
.VV  !
RoundVV! &
(VV& '

ventasMypeVV' 1
,VV1 2
$numVV3 4
)VV4 5
,VV5 6
gastosDeduciblesPenVV7 J
=VVK L
MathVVM Q
.VVQ R
RoundVVR W
(VVW X

deduciblesVVX b
,VVb c
$numVVd e
)VVe f
,VVf g
noDeduciblesVVh t
,VVt u
noDeduciblesPen	VVv Ö
=
VVÜ á
noDeducibles
VVà î
.
VVî ï
Sum
VVï ò
(
VVò ô
x
VVô ö
=>
VVõ ù
x
VVû ü
.
VVü †
monto
VV† •
)
VV• ¶
,
VV¶ ß
rentaNetaPenWW 
=WW 
MathWW 
.WW  
RoundWW  %
(WW% &
rentaWW& +
,WW+ ,
$numWW- .
)WW. /
,WW/ 0
impuestoWW1 9
,WW9 :
pagosACuentaPenWW; J
=WWK L
MathWWM Q
.WWQ R
RoundWWR W
(WWW X
pagosWWX ]
,WW] ^
$numWW_ `
)WW` a
,WWa b
pagosEstimadosWWc q
=WWr s
monthsWWt z
.WWz {
Count	WW{ Ä
(
WWÄ Å
x
WWÅ Ç
=>
WWÉ Ö
x
WWÜ á
.
WWá à
Estimado
WWà ê
)
WWê ë
,
WWë í
saldoPenXX 
=XX 
MathXX 
.XX 
RoundXX !
(XX! "
impuestoXX" *
.XX* +
TotalXX+ 0
-XX1 2
pagosXX3 8
,XX8 9
$numXX: ;
)XX; <
,XX< =
mesesXX> C
=XXD E
monthsXXF L
,XXL M

proyeccionXXN X
,XXX Y
personaNaturalYY 
=YY 
newYY  
{YY! "
ingresosPenYY# .
=YY/ 0
MathYY1 5
.YY5 6
RoundYY6 ;
(YY; <
naturalYY< C
.YYC D
SumYYD G
(YYG H
xYYH I
=>YYJ L
xYYM N
.YYN O
BasePenYYO V
)YYV W
,YYW X
$numYYY Z
)YYZ [
,YY[ \
retencionesPenYY] k
=YYl m
MathYYn r
.YYr s
RoundYYs x
(YYx y
natural	YYy Ä
.
YYÄ Å
Sum
YYÅ Ñ
(
YYÑ Ö
x
YYÖ Ü
=>
YYá â
x
YYä ã
.
YYã å
RetentionPen
YYå ò
)
YYò ô
,
YYô ö
$num
YYõ ú
)
YYú ù
}
YYû ü
,
YYü †

disclaimerZZ 
=ZZ 
TaxDisclaimerZZ &
,ZZ& '
}[[ 	
)[[	 

;[[
 
}\\ 
private__ 
static__ 
bool__ 
IsDeductible__ $
(__$ %
Expense__% ,
x__- .
)__. /
=>__0 2
x__3 4
.__4 5
Category__5 =
?__= >
.__> ?
IsIncomeTax__? J
!=__K M
true__N R
&&__S U
x__V W
.__W X
Category__X `
?__` a
.__a b
IsDeductible__b n
!=__o q
false__r w
&&__x z
!__{ |
x__| }
.__} ~
IsNonDeductible	__~ ç
;
__ç é
privateaa 
sealedaa 
recordaa 
AnnualMonthaa %
(aa% &
stringaa& ,
Mesaa- 0
,aa0 1
decimalaa2 9
	VentasPenaa: C
,aaC D
decimalaaE L
	GastosPenaaM V
,aaV W
decimalaaX _
PagoACuentaPenaa` n
,aan o
boolaap t
Estimadoaau }
)aa} ~
;aa~ 
[ff 
HttpGetff 
(ff 
$strff 
)ff 
]ff 
publicgg 

asyncgg 
Taskgg 
<gg 
ActionResultgg "
>gg" #
Form1662Listgg$ 0
(gg0 1
intgg1 4
yeargg5 9
,gg9 :
intgg; >
monthgg? D
,ggD E
CancellationTokenggF W
ctggX Z
)ggZ [
{hh 
varii 
settingsii 
=ii 
awaitii 
TaxSettingsRowii +
(ii+ ,
ctii, .
)ii. /
;ii/ 0
varjj 
rowsjj 
=jj 
awaitjj 
dbjj 
.jj 
Expensesjj $
.jj$ %
Wherejj% *
(jj* +
xjj+ ,
=>jj- /
xjj0 1
.jj1 2!
IsNonDomiciledServicejj2 G
&&jjH J
xjjK L
.jjL M
DatejjM Q
.jjQ R
YearjjR V
==jjW Y
yearjjZ ^
&&jj_ a
xjjb c
.jjc d
Datejjd h
.jjh i
Monthjji n
==jjo q
monthjjr w
)jjw x
.jjx y
OrderBy	jjy Ä
(
jjÄ Å
x
jjÅ Ç
=>
jjÉ Ö
x
jjÜ á
.
jjá à
Date
jjà å
)
jjå ç
.
jjç é
ToListAsync
jjé ô
(
jjô ö
ct
jjö ú
)
jjú ù
;
jjù û
varkk 
itemskk 
=kk 
rowskk 
.kk 
Selectkk 
(kk  
xkk  !
=>kk" $
newkk% (
{kk) *
idkk+ -
=kk. /
xkk0 1
.kk1 2
Idkk2 4
,kk4 5
datekk6 :
=kk; <
xkk= >
.kk> ?
Datekk? C
,kkC D
descriptionkkE P
=kkQ R
xkkS T
.kkT U
DescriptionkkU `
,kk` a
supplierkkb j
=kkk l
xkkm n
.kkn o 
ForeignSupplierName	kko Ç
,
kkÇ É
country
kkÑ ã
=
kkå ç
x
kké è
.
kkè ê$
ForeignSupplierCountry
kkê ¶
,
kk¶ ß
amount
kk® Æ
=
kkØ ∞
x
kk± ≤
.
kk≤ ≥
Amount
kk≥ π
,
kkπ ∫
currency
kkª √
=
kkƒ ≈
x
kk∆ «
.
kk« »
Currency
kk» –
,
kk– —
exchangeRate
kk“ ﬁ
=
kkﬂ ‡
x
kk· ‚
.
kk‚ „
Amount
kk„ È
==
kkÍ Ï
$num
kkÌ Ó
?
kkÔ 
$num
kkÒ Ú
:
kkÛ Ù
Math
kkı ˘
.
kk˘ ˙
Round
kk˙ ˇ
(
kkˇ Ä
x
kkÄ Å
.
kkÅ Ç
	AmountPen
kkÇ ã
/
kkå ç
x
kké è
.
kkè ê
Amount
kkê ñ
,
kkñ ó
$num
kkò ô
)
kkô ö
,
kkö õ
basePen
kkú £
=
kk§ •
Math
kk¶ ™
.
kk™ ´
Round
kk´ ∞
(
kk∞ ±
x
kk± ≤
.
kk≤ ≥
	AmountPen
kk≥ º
,
kkº Ω
$num
kkæ ø
)
kkø ¿
,
kk¿ ¡
igvPen
kk¬ »
=
kk…  
Form1662
kkÀ ”
.
kk” ‘
Igv
kk‘ ◊
(
kk◊ ÿ
x
kkÿ Ÿ
,
kkŸ ⁄
settings
kk€ „
.
kk„ ‰
IgvRate
kk‰ Î
)
kkÎ Ï
,
kkÏ Ì
paidAt
kkÓ Ù
=
kkı ˆ
x
kk˜ ¯
.
kk¯ ˘
Form1662PaidAt
kk˘ á
,
kká à
number
kkâ è
=
kkê ë
x
kkí ì
.
kkì î
Form1662Number
kkî ¢
}
kk£ §
)
kk§ •
.
kk• ¶
ToList
kk¶ ¨
(
kk¨ ≠
)
kk≠ Æ
;
kkÆ Ø
returnll 
Okll 
(ll 
newll 
{ll 
periodoll 
=ll  !
$"ll" $
{ll$ %
monthll% *
:ll* +
$strll+ -
}ll- .
$strll. /
{ll/ 0
yearll0 4
}ll4 5
"ll5 6
,ll6 7
tributoll8 ?
=ll@ A
$strllB H
,llH I
igvRatellJ Q
=llR S
settingsllT \
.ll\ ]
IgvRatell] d
,lld e
usedAsCreditllf r
=lls t
settingsllu }
.ll} ~
Use1662AsCredit	ll~ ç
,
llç é
totalIgvPen
llè ö
=
llõ ú
items
llù ¢
.
ll¢ £
Sum
ll£ ¶
(
ll¶ ß
x
llß ®
=>
ll© ´
x
ll¨ ≠
.
ll≠ Æ
igvPen
llÆ ¥
)
ll¥ µ
,
llµ ∂

pendientes
ll∑ ¡
=
ll¬ √
items
llƒ …
.
ll…  
Count
ll  œ
(
llœ –
x
ll– —
=>
ll“ ‘
x
ll’ ÷
.
ll÷ ◊
paidAt
ll◊ ›
is
llﬁ ‡
null
ll· Â
)
llÂ Ê
,
llÊ Á
items
llË Ì
}
llÓ Ô
)
llÔ 
;
ll Ò
}mm 
[oo 
HttpPostoo 
(oo 
$stroo ,
)oo, -
]oo- .
publicpp 

asyncpp 
Taskpp 
<pp 
ActionResultpp "
>pp" #
MarkForm1662Paidpp$ 4
(pp4 5
Guidpp5 9
idpp: <
,pp< ="
Form1662PaymentRequestpp> T
requestppU \
,pp\ ]
CancellationTokenpp^ o
ctppp r
)ppr s
{qq 
varrr 
expenserr 
=rr 
awaitrr 
dbrr 
.rr 
Expensesrr '
.rr' (
	FindAsyncrr( 1
(rr1 2
[rr2 3
idrr3 5
]rr5 6
,rr6 7
ctrr8 :
)rr: ;
;rr; <
ifrr= ?
(rr@ A
expenserrA H
isrrI K
nullrrL P
)rrP Q
returnrrR X
NotFoundrrY a
(rra b
)rrb c
;rrc d
ifss 

(ss 
!ss 
expensess 
.ss !
IsNonDomiciledServicess *
)ss* +
returnss, 2

BadRequestss3 =
(ss= >
newss> A
{ssB C
messagessD K
=ssL M
$str	ssN ò
}
ssô ö
)
ssö õ
;
ssõ ú
iftt 

(tt 
requesttt 
.tt 
PaidAttt 
<tt 
expensett $
.tt$ %
Datett% )
)tt) *
returntt+ 1

BadRequesttt2 <
(tt< =
newtt= @
{ttA B
messagettC J
=ttK L
$strttM }
}tt~ 
)	tt Ä
;
ttÄ Å
(uu 	
expenseuu	 
.uu 
Form1662PaidAtuu 
,uu  
expenseuu! (
.uu( )
Form1662Numberuu) 7
)uu7 8
=uu9 :
(uu; <
requestuu< C
.uuC D
PaidAtuuD J
,uuJ K
EmptyToNulluuL W
(uuW X
requestuuX _
.uu_ `
Numberuu` f
)uuf g
)uug h
;uuh i
awaitvv 
dbvv 
.vv 
SaveChangesAsyncvv !
(vv! "
ctvv" $
)vv$ %
;vv% &
returnvv' -
	NoContentvv. 7
(vv7 8
)vv8 9
;vv9 :
}ww 
[yy 

HttpDeleteyy 
(yy 
$stryy .
)yy. /
]yy/ 0
publiczz 

asynczz 
Taskzz 
<zz 
ActionResultzz "
>zz" #
UnmarkForm1662Paidzz$ 6
(zz6 7
Guidzz7 ;
idzz< >
,zz> ?
CancellationTokenzz@ Q
ctzzR T
)zzT U
{{{ 
var|| 
expense|| 
=|| 
await|| 
db|| 
.|| 
Expenses|| '
.||' (
	FindAsync||( 1
(||1 2
[||2 3
id||3 5
]||5 6
,||6 7
ct||8 :
)||: ;
;||; <
if||= ?
(||@ A
expense||A H
is||I K
null||L P
)||P Q
return||R X
NotFound||Y a
(||a b
)||b c
;||c d
(}} 	
expense}}	 
.}} 
Form1662PaidAt}} 
,}}  
expense}}! (
.}}( )
Form1662Number}}) 7
)}}7 8
=}}9 :
(}}; <
null}}< @
,}}@ A
null}}B F
)}}F G
;}}G H
await~~ 
db~~ 
.~~ 
SaveChangesAsync~~ !
(~~! "
ct~~" $
)~~$ %
;~~% &
return~~' -
	NoContent~~. 7
(~~7 8
)~~8 9
;~~9 :
} 
}ÄÄ 
publicÇÇ 
sealed
ÇÇ 
record
ÇÇ &
AnnualTaxSettingsRequest
ÇÇ -
(
ÇÇ- .
decimal
ÇÇ. 5
Uit
ÇÇ6 9
,
ÇÇ9 :
decimal
ÇÇ; B
ThresholdUits
ÇÇC P
=
ÇÇQ R
$num
ÇÇS V
,
ÇÇV W
decimal
ÇÇX _
LowRate
ÇÇ` g
=
ÇÇh i
$num
ÇÇj o
,
ÇÇo p
decimal
ÇÇq x
HighRateÇÇy Å
=ÇÇÇ É
$numÇÇÑ ä
)ÇÇä ã
;ÇÇã å
publicÉÉ 
sealed
ÉÉ 
record
ÉÉ $
Form1662PaymentRequest
ÉÉ +
(
ÉÉ+ ,
DateOnly
ÉÉ, 4
PaidAt
ÉÉ5 ;
,
ÉÉ; <
string
ÉÉ= C
?
ÉÉC D
Number
ÉÉE K
)
ÉÉK L
;
ÉÉL MÀO
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
)Y Z
:[ \
ControllerBase] k
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
√ ƒ
var
≈ »
claims
… œ
=
œ –
new
– ”
List
‘ ÿ
<
ÿ Ÿ
Claim
Ÿ ﬁ
>
ﬁ ﬂ
{
ﬂ ‡
new
‡ „
(
„ ‰%
JwtRegisteredClaimNames
‰ ˚
.
˚ ¸
Sub
¸ ˇ
,
ˇ Ä	
u
Ä	 Å	
.
Å	 Ç	
Id
Ç	 Ñ	
.
Ñ	 Ö	
ToString
Ö	 ç	
(
ç	 é	
)
é	 è	
)
è	 ê	
,
ê	 ë	
new
ë	 î	
(
î	 ï	

ClaimTypes
ï	 ü	
.
ü	 †	
NameIdentifier
†	 Æ	
,
Æ	 Ø	
u
Ø	 ∞	
.
∞	 ±	
Id
±	 ≥	
.
≥	 ¥	
ToString
¥	 º	
(
º	 Ω	
)
Ω	 æ	
)
æ	 ø	
,
ø	 ¿	
new
¿	 √	
(
√	 ƒ	

ClaimTypes
ƒ	 Œ	
.
Œ	 œ	
Role
œ	 ”	
,
”	 ‘	
u
‘	 ’	
.
’	 ÷	
Role
÷	 ⁄	
.
⁄	 €	
ToString
€	 „	
(
„	 ‰	
)
‰	 Â	
)
Â	 Ê	
}
Ê	 Á	
;
Á	 Ë	
if
È	 Î	
(
Î	 Ï	
u
Ï	 Ì	
.
Ì	 Ó	
ClientId
Ó	 ˆ	
is
˜	 ˘	
Guid
˙	 ˛	
id
ˇ	 Å

)
Å
 Ç

claims
Ç
 à

.
à
 â

Add
â
 å

(
å
 ç

new
ç
 ê

Claim
ë
 ñ

(
ñ
 ó

$str
ó
 ¢

,
¢
 £

id
£
 •

.
•
 ¶

ToString
¶
 Æ

(
Æ
 Ø

)
Ø
 ∞

)
∞
 ±

)
±
 ≤

;
≤
 ≥

var
¥
 ∑

token
∏
 Ω

=
Ω
 æ

new
æ
 ¡

JwtSecurityToken
¬
 “

(
“
 ”

jwt
”
 ÷

.
÷
 ◊

Issuer
◊
 ›

,
›
 ﬁ

jwt
ﬁ
 ·

.
·
 ‚

Audience
‚
 Í

,
Í
 Î

claims
Î
 Ò

,
Ò
 Ú

expires
Ú
 ˘

:
˘
 ˙

DateTime
˙
 Ç
.
Ç É
UtcNow
É â
.
â ä
AddHours
ä í
(
í ì
$num
ì î
)
î ï
,
ï ñ 
signingCredentials
ñ ®
:
® ©
new
© ¨ 
SigningCredentials
≠ ø
(
ø ¿
jwt
¿ √
.
√ ƒ

SigningKey
ƒ Œ
,
Œ œ 
SecurityAlgorithms
œ ·
.
· ‚

HmacSha256
‚ Ï
)
Ï Ì
)
Ì Ó
;
Ó Ô
var
 Û
initials
Ù ¸
=
¸ ˝
string
˝ É
.
É Ñ
Concat
Ñ ä
(
ä ã
u
ã å
.
å ç
Name
ç ë
.
ë í
Split
í ó
(
ó ò
$char
ò õ
,
õ ú 
StringSplitOptions
ú Æ
.
Æ Ø 
RemoveEmptyEntries
Ø ¡
)
¡ ¬
.
¬ √
Take
√ «
(
« »
$num
» …
)
…  
.
  À
Select
À —
(
— “
x
“ ”
=>
” ’
x
’ ÷
[
÷ ◊
$num
◊ ÿ
]
ÿ Ÿ
)
Ÿ ⁄
)
⁄ €
.
€ ‹
ToUpperInvariant
‹ Ï
(
Ï Ì
)
Ì Ó
;
Ó Ô
return
 ˆ
Ok
˜ ˘
(
˘ ˙
new
˙ ˝
{
˛ ˇ
token
ˇ Ñ
=
Ñ Ö
new
Ö à%
JwtSecurityTokenHandler
â †
(
† °
)
° ¢
.
¢ £

WriteToken
£ ≠
(
≠ Æ
token
Æ ≥
)
≥ ¥
,
¥ µ
user
µ π
=
π ∫
new
∫ Ω
{
Ω æ
name
æ ¬
=
¬ √
u
√ ƒ
.
ƒ ≈
Name
≈ …
,
…  
initials
  “
,
“ ”

clientName
” ›
=
› ﬁ
c
ﬁ ﬂ
?
ﬂ ‡
.
‡ ·
CompanyName
· Ï
,
Ï Ì
role
Ì Ò
=
Ò Ú
u
Ú Û
.
Û Ù
Role
Ù ¯
.
¯ ˘
ToString
˘ Å
(
Å Ç
)
Ç É
}
É Ñ
}
Ñ Ö
)
Ö Ü
;
Ü á
}
à â
} Å˛
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.Purchases.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
public 
sealed 
partial 
class 
AdminController +
{ 
[ 
HttpGet 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
	Purchases$ -
(- .
int. 1
year2 6
,6 7
int8 ;
?; <
month= B
,B C
CancellationTokenD U
ctV X
)X Y
{ 
var 
( 
from 
, 
to 
) 
= 
Period 
(  
month  %
,% &
year' +
)+ ,
;, -
var 
igvRate 
= 
await 
db 
. 
IgvRateAsync +
(+ ,
ct, .
). /
;/ 0
var 
items 
= 
await 
db 
. 
	Purchases &
.& '
Where' ,
(, -
x- .
=>/ 1
x2 3
.3 4
Period4 :
>=; =
from> B
&&C E
xF G
.G H
PeriodH N
<=O Q
toR T
)T U
.U V
OrderByDescendingV g
(g h
xh i
=>j l
xm n
.n o
	IssueDateo x
)x y
.y z
ThenBy	z Ä
(
Ä Å
x
Å Ç
=>
É Ö
x
Ü á
.
á à
SupplierName
à î
)
î ï
.
ï ñ
ToListAsync
ñ °
(
° ¢
ct
¢ §
)
§ •
;
• ¶
return 
Ok 
( 
new 
{ 	
items 
= 
items 
. 
Select  
(  !
x! "
=># %
PurchaseDto& 1
(1 2
x2 3
,3 4
igvRate5 <
)< =
)= >
,> ?
totalPen 
= 
Math 
. 
Round !
(! "
items" '
.' (
Sum( +
(+ ,
x, -
=>. 0
Signed1 7
(7 8
x8 9
,9 :
x; <
.< =
TotalPen= E
)E F
)F G
,G H
$numI J
)J K
,K L
creditoFiscalPen 
= 
Math #
.# $
Round$ )
() *
items* /
./ 0
Sum0 3
(3 4
x4 5
=>6 8
x9 :
.: ;
TaxCreditPen; G
)G H
,H I
$numJ K
)K L
,L M
igvSinCreditoPen 
= 
Math #
.# $
Round$ )
() *
items* /
./ 0
Where0 5
(5 6
x6 7
=>8 :
!; <
x< =
.= >
GivesTaxCredit> L
)L M
.M N
SumN Q
(Q R
xR S
=>T V
SignedW ]
(] ^
x^ _
,_ `
xa b
.b c
IgvPenc i
)i j
)j k
,k l
$numm n
)n o
,o p
} 	
)	 

;
 
} 
[ 
HttpPost 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
CreatePurchase$ 2
(2 3
PurchaseRequest3 B
requestC J
,J K
CancellationTokenL ]
ct^ `
)` a
{ 
var 
purchase 
= 
new 
Purchase #
(# $
)$ %
;% &
if   

(   
await   
ApplyPurchaseAsync   $
(  $ %
purchase  % -
,  - .
request  / 6
,  6 7
ct  8 :
)  : ;
is  < >
{  ? @
}  A B
error  C H
)  H I
return  J P
error  Q V
;  V W
db!! 

.!!
 
	Purchases!! 
.!! 
Add!! 
(!! 
purchase!! !
)!!! "
;!!" #
if"" 

("" 
request"" 
."" 
CreateExpense"" !
&&""" $
await""% *
LinkExpenseAsync""+ ;
(""; <
purchase""< D
,""D E
request""F M
.""M N
ExpenseCategoryId""N _
,""_ `
ct""a c
)""c d
is""e g
{""h i
}""j k
expenseError""l x
)""x y
return	""z Ä
expenseError
""Å ç
;
""ç é
await## 
db## 
.## 
SaveChangesAsync## !
(##! "
ct##" $
)##$ %
;##% &
return$$ 
Created$$ 
($$ 
$"$$ 
$str$$ .
{$$. /
purchase$$/ 7
.$$7 8
Id$$8 :
}$$: ;
"$$; <
,$$< =
PurchaseDto$$> I
($$I J
purchase$$J R
,$$R S
await$$T Y
db$$Z \
.$$\ ]
IgvRateAsync$$] i
($$i j
ct$$j l
)$$l m
)$$m n
)$$n o
;$$o p
}%% 
['' 
HttpPut'' 
('' 
$str'' "
)''" #
]''# $
public(( 

async(( 
Task(( 
<(( 
ActionResult(( "
>((" #
UpdatePurchase(($ 2
(((2 3
Guid((3 7
id((8 :
,((: ;
PurchaseRequest((< K
request((L S
,((S T
CancellationToken((U f
ct((g i
)((i j
{)) 
var** 
purchase** 
=** 
await** 
db** 
.**  
	Purchases**  )
.**) *
	FindAsync*** 3
(**3 4
[**4 5
id**5 7
]**7 8
,**8 9
ct**: <
)**< =
;**= >
if**? A
(**B C
purchase**C K
is**L N
null**O S
)**S T
return**U [
NotFound**\ d
(**d e
)**e f
;**f g
if++ 

(++ 
await++ 
ApplyPurchaseAsync++ $
(++$ %
purchase++% -
,++- .
request++/ 6
,++6 7
ct++8 :
)++: ;
is++< >
{++? @
}++A B
error++C H
)++H I
return++J P
error++Q V
;++V W
if,, 

(,, 
(,, 
request,, 
.,, 
CreateExpense,, "
||,,# %
purchase,,& .
.,,. /
	ExpenseId,,/ 8
is,,9 ;
not,,< ?
null,,@ D
),,D E
&&,,F H
await,,I N
LinkExpenseAsync,,O _
(,,_ `
purchase,,` h
,,,h i
request,,j q
.,,q r
ExpenseCategoryId	,,r É
,
,,É Ñ
ct
,,Ö á
)
,,á à
is
,,â ã
{
,,å ç
}
,,é è
expenseError
,,ê ú
)
,,ú ù
return
,,û §
expenseError
,,• ±
;
,,± ≤
await-- 
db-- 
.-- 
SaveChangesAsync-- !
(--! "
ct--" $
)--$ %
;--% &
return.. 
Ok.. 
(.. 
PurchaseDto.. 
(.. 
purchase.. &
,..& '
await..( -
db... 0
...0 1
IgvRateAsync..1 =
(..= >
ct..> @
)..@ A
)..A B
)..B C
;..C D
}// 
[22 

HttpDelete22 
(22 
$str22 %
)22% &
]22& '
public33 

async33 
Task33 
<33 
ActionResult33 "
>33" #
DeletePurchase33$ 2
(332 3
Guid333 7
id338 :
,33: ;
bool33< @
deleteExpense33A N
,33N O
CancellationToken33P a
ct33b d
)33d e
{44 
var55 
purchase55 
=55 
await55 
db55 
.55  
	Purchases55  )
.55) *
	FindAsync55* 3
(553 4
[554 5
id555 7
]557 8
,558 9
ct55: <
)55< =
;55= >
if55? A
(55B C
purchase55C K
is55L N
null55O S
)55S T
return55U [
NotFound55\ d
(55d e
)55e f
;55f g
if66 

(66 
deleteExpense66 
&&66 
purchase66 %
.66% &
	ExpenseId66& /
is660 2
Guid663 7
	expenseId668 A
&&66B D
await66E J
db66K M
.66M N
Expenses66N V
.66V W
	FindAsync66W `
(66` a
[66a b
	expenseId66b k
]66k l
,66l m
ct66n p
)66p q
is66r t
{66u v
}66w x
expense	66y Ä
)
66Ä Å
db
66Ç Ñ
.
66Ñ Ö
Expenses
66Ö ç
.
66ç é
Remove
66é î
(
66î ï
expense
66ï ú
)
66ú ù
;
66ù û
db77 

.77
 
	Purchases77 
.77 
Remove77 
(77 
purchase77 $
)77$ %
;77% &
await77' ,
db77- /
.77/ 0
SaveChangesAsync770 @
(77@ A
ct77A C
)77C D
;77D E
return77F L
	NoContent77M V
(77V W
)77W X
;77X Y
}88 
[:: 
HttpGet:: 
(:: 
$str:: (
)::( )
]::) *
public;; 

async;; 
Task;; 
<;; 
IActionResult;; #
>;;# $
PurchaseTemplate;;% 5
(;;5 6
CancellationToken;;6 G
ct;;H J
);;J K
=>;;L N
File;;O S
(;;S T
CreateWorkbook;;T b
(;;b c
new<< 
(<< 
$str<< 
,<< 
true<< 
,<< 
$str<< b
)<<b c
,<<c d
new== 
(== 
$str== 
,== 
false== 
,== 
$str== P
)==P Q
,==Q R
new>> 
(>> 
$str>> 
,>> 
true>>  
,>>  !
$str>>" 7
,>>7 8
Enum>>9 =
.>>= >
GetNames>>> F
<>>F G 
PurchaseDocumentType>>G [
>>>[ \
(>>\ ]
)>>] ^
)>>^ _
,>>_ `
new?? 
(?? 
$str?? 
,?? 
false?? 
,?? 
$str?? T
)??T U
,??U V
new@@ 
(@@ 
$str@@ 
,@@ 
true@@ 
,@@ 
$str@@ 4
)@@4 5
,@@5 6
newAA 
(AA 
$strAA 
,AA 
trueAA !
,AA! "
$strAA# b
)AAb c
,AAc d
newBB 
(BB 
$strBB 
,BB 
trueBB  
,BB  !
$strBB" >
)BB> ?
,BB? @
newCC 
(CC 
$strCC 
,CC 
trueCC 
,CC 
$strCC .
,CC. /
[CC0 1
$strCC1 6
,CC6 7
$strCC8 =
,CC= >
$strCC? D
]CCD E
)CCE F
,CCF G
newDD 
(DD 
$strDD 
,DD 
trueDD 
,DD 
$strDD G
)DDG H
,DDH I
newEE 
(EE 
$strEE 
,EE 
trueEE 
,EE 
$strEE >
)EE> ?
,EE? @
newFF 
(FF 
$strFF 
,FF 
falseFF 
,FF  
$strFF! K
)FFK L
,FFL M
newGG 
(GG 
$strGG $
,GG$ %
falseGG& +
,GG+ ,
$str	GG- ã
,
GGã å
[
GGç é
$str
GGé í
,
GGí ì
$str
GGî ò
]
GGò ô
)
GGô ö
,
GGö õ
newHH 
(HH 
$strHH 
,HH 
falseHH $
,HH$ %
$strHH& b
,HHb c
[HHd e
..HHe g
awaitHHh m
dbHHn p
.HHp q
ExpenseCategories	HHq Ç
.
HHÇ É
OrderBy
HHÉ ä
(
HHä ã
x
HHã å
=>
HHç è
x
HHê ë
.
HHë í
	SortOrder
HHí õ
)
HHõ ú
.
HHú ù
Select
HHù £
(
HH£ §
x
HH§ •
=>
HH¶ ®
x
HH© ™
.
HH™ ´
Name
HH´ Ø
)
HHØ ∞
.
HH∞ ±
ToListAsync
HH± º
(
HHº Ω
ct
HHΩ ø
)
HHø ¿
]
HH¿ ¡
)
HH¡ ¬
)
HH¬ √
,
HH√ ƒ
$strII K
,IIK L
$strIIM e
)IIe f
;IIf g
[KK 
HttpPostKK 
(KK 
$strKK  
)KK  !
]KK! "
publicLL 

asyncLL 
TaskLL 
<LL 
ActionResultLL "
>LL" #
ImportPurchasesLL$ 3
(LL3 4
	IFormFileLL4 =
fileLL> B
,LLB C
CancellationTokenLLD U
ctLLV X
)LLX Y
{MM 
varNN 

categoriesNN 
=NN 
awaitNN 
dbNN !
.NN! "
ExpenseCategoriesNN" 3
.NN3 4
ToListAsyncNN4 ?
(NN? @
ctNN@ B
)NNB C
;NNC D
varOO 
(OO 
failureOO 
,OO 
createdOO 
,OO 
errorsOO %
)OO% &
=OO' (
awaitOO) .
ImportOO/ 5
(OO5 6
fileOO6 :
,OO: ;
$strOO< E
,OOE F
asyncOOG L
(OOM N
rowOON Q
,OOQ R
	rowNumberOOS \
,OO\ ]
errorsOO^ d
)OOd e
=>OOf h
{PP 	
varQQ 

parseErrorQQ 
=QQ 
ParsePurchaseRowQQ -
(QQ- .
rowQQ. 1
,QQ1 2

categoriesQQ3 =
,QQ= >
outQQ? B
varQQC F
requestQQG N
)QQN O
;QQO P
varRR 
purchaseRR 
=RR 
newRR 
PurchaseRR '
(RR' (
)RR( )
;RR) *
varSS 
errorSS 
=SS 

parseErrorSS "
??SS# %
MessageSS& -
(SS- .
awaitSS. 3
ApplyPurchaseAsyncSS4 F
(SSF G
purchaseSSG O
,SSO P
requestSSQ X
!SSX Y
,SSY Z
ctSS[ ]
)SS] ^
)SS^ _
;SS_ `
ifTT 
(TT 
errorTT 
isTT 
nullTT 
&&TT  
requestTT! (
!TT( )
.TT) *
CreateExpenseTT* 7
)TT7 8
errorTT9 >
=TT? @
MessageTTA H
(TTH I
awaitTTI N
LinkExpenseAsyncTTO _
(TT_ `
purchaseTT` h
,TTh i
requestTTj q
.TTq r
ExpenseCategoryId	TTr É
,
TTÉ Ñ
ct
TTÖ á
)
TTá à
)
TTà â
;
TTâ ä
ifUU 
(UU 
errorUU 
isUU 
notUU 
nullUU !
)UU! "
{UU# $
errorsUU% +
.UU+ ,
AddUU, /
(UU/ 0
newUU0 3
(UU3 4
	rowNumberUU4 =
,UU= >
errorUU? D
)UUD E
)UUE F
;UUF G
returnUUH N
falseUUO T
;UUT U
}UUV W
dbVV 
.VV 
	PurchasesVV 
.VV 
AddVV 
(VV 
purchaseVV %
)VV% &
;VV& '
awaitVV( -
dbVV. 0
.VV0 1
SaveChangesAsyncVV1 A
(VVA B
ctVVB D
)VVD E
;VVE F
returnVVG M
trueVVN R
;VVR S
}WW 	
,WW	 

ctWW 
)WW 
;WW 
returnXX 
failureXX 
??XX 
OkXX 
(XX 
newXX  
{XX! "
createdXX# *
,XX* +
skippedXX, 3
=XX4 5
errorsXX6 <
.XX< =
CountXX= B
,XXB C
errorsXXD J
}XXK L
)XXL M
;XXM N
}YY 
private[[ 
static[[ 
string[[ 
?[[ 
Message[[ "
([[" #
ActionResult[[# /
?[[/ 0
result[[1 7
)[[7 8
=>[[9 ;
result[[< B
switch[[C I
{\\ 
null]] 
=>]] 
null]] 
,]] 
ObjectResult^^ 
{^^ 
Value^^ 
:^^ 
var^^ !
value^^" '
}^^( )
=>^^* ,
value^^- 2
?^^2 3
.^^3 4
GetType^^4 ;
(^^; <
)^^< =
.^^= >
GetProperty^^> I
(^^I J
$str^^J S
)^^S T
?^^T U
.^^U V
GetValue^^V ^
(^^^ _
value^^_ d
)^^d e
as^^f h
string^^i o
??^^p r
$str	^^s É
,
^^É Ñ
___ 	
=>__
 
$str__ 
,__ 
}`` 
;`` 
privatebb 
staticbb 
stringbb 
?bb 
ParsePurchaseRowbb +
(bb+ ,
IXLRowbb, 2
rowbb3 6
,bb6 7
IReadOnlyListbb8 E
<bbE F
ExpenseCategorybbF U
>bbU V

categoriesbbW a
,bba b
outbbc f
PurchaseRequestbbg v
?bbv w
requestbbx 
)	bb Ä
{cc 
requestdd 
=dd 
nulldd 
;dd 
ifee 

(ee 
ReadDateee 
(ee 
rowee 
.ee 
Cellee 
(ee 
$numee 
)ee  
)ee  !
isee" $
notee% (
DateOnlyee) 1
	issueDateee2 ;
)ee; <
returnee= C
$streeD v
;eev w
ifff 

(ff 
!ff 
TryEnumff 
<ff  
PurchaseDocumentTypeff )
>ff) *
(ff* +
Cellff+ /
(ff/ 0
rowff0 3
,ff3 4
$numff5 6
)ff6 7
,ff7 8
outff9 <
varff= @
typeffA E
)ffE F
)ffF G
returnffH N
$"ffO Q
$strffQ l
{ffl m
stringffm s
.ffs t
Joinfft x
(ffx y
$strffy }
,ff} ~
Enum	ff É
.
ffÉ Ñ
GetNames
ffÑ å
<
ffå ç"
PurchaseDocumentType
ffç °
>
ff° ¢
(
ff¢ £
)
ff£ §
)
ff§ •
}
ff• ¶
$str
ff¶ ß
"
ffß ®
;
ff® ©
ifgg 

(gg 
ReadDecimalgg 
(gg 
rowgg 
.gg 
Cellgg  
(gg  !
$numgg! "
)gg" #
)gg# $
isgg% '
notgg( +
decimalgg, 3
taxBasegg4 ;
)gg; <
returngg= C
$strggD a
;gga b
ifhh 

(hh 
ReadDecimalhh 
(hh 
rowhh 
.hh 
Cellhh  
(hh  !
$numhh! #
)hh# $
)hh$ %
ishh& (
nothh) ,
decimalhh- 4
igvhh5 8
)hh8 9
returnhh: @
$strhhA j
;hhj k
varii 

nonTaxableii 
=ii 
stringii 
.ii  
IsNullOrWhiteSpaceii  2
(ii2 3
Cellii3 7
(ii7 8
rowii8 ;
,ii; <
$numii= ?
)ii? @
)ii@ A
?iiB C
$numiiD F
:iiG H
ReadDecimaliiI T
(iiT U
rowiiU X
.iiX Y
CelliiY ]
(ii] ^
$numii^ `
)ii` a
)iia b
??iic e
-iif g
$numiig i
;iii j
ifjj 

(jj 

nonTaxablejj 
<jj 
$numjj 
)jj 
returnjj "
$strjj# U
;jjU V
ifkk 

(kk 
	ReadYesNokk 
(kk 
Cellkk 
(kk 
rowkk 
,kk 
$numkk  "
)kk" #
,kk# $
defaultValuekk% 1
:kk1 2
truekk3 7
)kk7 8
iskk9 ;
notkk< ?
boolkk@ D
taxedkkE J
)kkJ K
returnkkL R
$str	kkS Ç
;
kkÇ É
Guidll 
?ll 

categoryIdll 
=ll 
nullll 
;ll  
varmm 
categoryTextmm 
=mm 
Foldmm 
(mm  
Cellmm  $
(mm$ %
rowmm% (
,mm( )
$nummm* ,
)mm, -
)mm- .
;mm. /
ifnn 

(nn 
categoryTextnn 
.nn 
Lengthnn 
>nn  !
$numnn" #
)nn# $
{oo 	
ifpp 
(pp 

categoriespp 
.pp 
FirstOrDefaultpp )
(pp) *
xpp* +
=>pp, .
Foldpp/ 3
(pp3 4
xpp4 5
.pp5 6
Namepp6 :
)pp: ;
==pp< >
categoryTextpp? K
||ppL N
xppO P
.ppP Q
CodeppQ U
isppV X
notppY \
nullpp] a
&&ppb d
Foldppe i
(ppi j
xppj k
.ppk l
Codeppl p
)ppp q
==ppr t
categoryText	ppu Å
)
ppÅ Ç
is
ppÉ Ö
not
ppÜ â
{
ppä ã
}
ppå ç
category
ppé ñ
)
ppñ ó
return
ppò û
$str
ppü „
;
pp„ ‰

categoryIdqq 
=qq 
categoryqq !
.qq! "
Idqq" $
;qq$ %
}rr 	
requestss 
=ss 
newss 
PurchaseRequestss %
(ss% &
	issueDatess& /
,ss/ 0
EmptyToNullss1 <
(ss< =
Cellss= A
(ssA B
rowssB E
,ssE F
$numssG H
)ssH I
)ssI J
,ssJ K
typessL P
,ssP Q
CellssR V
(ssV W
rowssW Z
,ssZ [
$numss\ ]
)ss] ^
.ss^ _
Trimss_ c
(ssc d
)ssd e
,sse f
Cellssg k
(ssk l
rowssl o
,sso p
$numssq r
)ssr s
.sss t
Trimsst x
(ssx y
)ssy z
,ssz {
Cell	ss| Ä
(
ssÄ Å
row
ssÅ Ñ
,
ssÑ Ö
$num
ssÜ á
)
ssá à
.
ssà â
Trim
ssâ ç
(
ssç é
)
ssé è
,
ssè ê
Cell
ssë ï
(
ssï ñ
row
ssñ ô
,
ssô ö
$num
ssõ ú
)
ssú ù
.
ssù û
Trim
ssû ¢
(
ss¢ £
)
ss£ §
,
ss§ •
Celltt 
(tt 
rowtt 
,tt 
$numtt 
)tt 
.tt 
Trimtt 
(tt 
)tt 
.tt  
ToUpperInvarianttt  0
(tt0 1
)tt1 2
,tt2 3
taxBasett4 ;
,tt; <
igvtt= @
,tt@ A

nonTaxablettB L
,ttL M
taxedttN S
,ttS T
CreateExpensettU b
:ttb c

categoryIdttd n
istto q
notttr u
nullttv z
,ttz {
ExpenseCategoryId	tt| ç
:
ttç é

categoryId
ttè ô
)
ttô ö
;
ttö õ
returnuu 
nulluu 
;uu 
}vv 
privateyy 
asyncyy 
Taskyy 
<yy 
ActionResultyy #
?yy# $
>yy$ %
ApplyPurchaseAsyncyy& 8
(yy8 9
Purchaseyy9 A
purchaseyyB J
,yyJ K
PurchaseRequestyyL [
ryy\ ]
,yy] ^
CancellationTokenyy_ p
ctyyq s
)yys t
{zz 
var{{ 
peruvian{{ 
={{ 
r{{ 
.{{ 
DocumentType{{ %
is{{& (
not{{) ,
({{- . 
PurchaseDocumentType{{. B
.{{B C

Extranjero{{C M
or{{N P 
PurchaseDocumentType{{Q e
.{{e f
Otro{{f j
){{j k
;{{k l
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
;||: ;
if}} 

(}} 
peruvian}} 
&&}} 
!}} 
RucRegex}} !
(}}! "
)}}" #
.}}# $
IsMatch}}$ +
(}}+ ,
supplierTaxId}}, 9
)}}9 :
)}}: ;
return}}< B

BadRequest}}C M
(}}M N
new}}N Q
{}}R S
message}}T [
=}}\ ]
$str	}}^ ã
}
}}å ç
)
}}ç é
;
}}é è
if~~ 

(~~ 
supplierTaxId~~ 
.~~ 
Length~~  
==~~! #
$num~~$ %
)~~% &
return~~' -

BadRequest~~. 8
(~~8 9
new~~9 <
{~~= >
message~~? F
=~~G H
$str~~I r
}~~s t
)~~t u
;~~u v
if 

( 
string 
. 
IsNullOrWhiteSpace %
(% &
r& '
.' (
SupplierName( 4
)4 5
)5 6
return7 =

BadRequest> H
(H I
newI L
{M N
messageO V
=W X
$strY z
}{ |
)| }
;} ~
if
ÄÄ 

(
ÄÄ 
peruvian
ÄÄ 
&&
ÄÄ 
string
ÄÄ 
.
ÄÄ  
IsNullOrWhiteSpace
ÄÄ 1
(
ÄÄ1 2
r
ÄÄ2 3
.
ÄÄ3 4
Series
ÄÄ4 :
)
ÄÄ: ;
)
ÄÄ; <
return
ÄÄ= C

BadRequest
ÄÄD N
(
ÄÄN O
new
ÄÄO R
{
ÄÄS T
message
ÄÄU \
=
ÄÄ] ^
$strÄÄ_ å
}ÄÄç é
)ÄÄé è
;ÄÄè ê
if
ÅÅ 

(
ÅÅ 
string
ÅÅ 
.
ÅÅ  
IsNullOrWhiteSpace
ÅÅ %
(
ÅÅ% &
r
ÅÅ& '
.
ÅÅ' (
Number
ÅÅ( .
)
ÅÅ. /
)
ÅÅ/ 0
return
ÅÅ1 7

BadRequest
ÅÅ8 B
(
ÅÅB C
new
ÅÅC F
{
ÅÅG H
message
ÅÅI P
=
ÅÅQ R
$str
ÅÅS v
}
ÅÅw x
)
ÅÅx y
;
ÅÅy z
var
ÇÇ 
currency
ÇÇ 
=
ÇÇ 
(
ÇÇ 
r
ÇÇ 
.
ÇÇ 
Currency
ÇÇ "
??
ÇÇ# %
$str
ÇÇ& (
)
ÇÇ( )
.
ÇÇ) *
Trim
ÇÇ* .
(
ÇÇ. /
)
ÇÇ/ 0
.
ÇÇ0 1
ToUpperInvariant
ÇÇ1 A
(
ÇÇA B
)
ÇÇB C
;
ÇÇC D
if
ÉÉ 

(
ÉÉ 
currency
ÉÉ 
is
ÉÉ 
not
ÉÉ 
(
ÉÉ 
$str
ÉÉ "
or
ÉÉ# %
$str
ÉÉ& +
or
ÉÉ, .
$str
ÉÉ/ 4
)
ÉÉ4 5
)
ÉÉ5 6
return
ÉÉ7 =

BadRequest
ÉÉ> H
(
ÉÉH I
new
ÉÉI L
{
ÉÉM N
message
ÉÉO V
=
ÉÉW X
$str
ÉÉY 
}ÉÉÄ Å
)ÉÉÅ Ç
;ÉÉÇ É
if
ÑÑ 

(
ÑÑ 
r
ÑÑ 
.
ÑÑ 
TaxBase
ÑÑ 
<
ÑÑ 
$num
ÑÑ 
||
ÑÑ 
r
ÑÑ 
.
ÑÑ 
Igv
ÑÑ "
<
ÑÑ# $
$num
ÑÑ% &
||
ÑÑ' )
r
ÑÑ* +
.
ÑÑ+ ,

NonTaxable
ÑÑ, 6
<
ÑÑ7 8
$num
ÑÑ9 :
||
ÑÑ; =
r
ÑÑ> ?
.
ÑÑ? @
TaxBase
ÑÑ@ G
+
ÑÑH I
r
ÑÑJ K
.
ÑÑK L
Igv
ÑÑL O
+
ÑÑP Q
r
ÑÑR S
.
ÑÑS T

NonTaxable
ÑÑT ^
<=
ÑÑ_ a
$num
ÑÑb c
)
ÑÑc d
return
ÑÑe k

BadRequest
ÑÑl v
(
ÑÑv w
new
ÑÑw z
{
ÑÑ{ |
messageÑÑ} Ñ
=ÑÑÖ Ü
$strÑÑá Ã
}ÑÑÕ Œ
)ÑÑŒ œ
;ÑÑœ –
if
ÖÖ 

(
ÖÖ 
r
ÖÖ 
.
ÖÖ 
Igv
ÖÖ 
>
ÖÖ 
$num
ÖÖ 
&&
ÖÖ 
r
ÖÖ 
.
ÖÖ 
DocumentType
ÖÖ '
is
ÖÖ( *"
PurchaseDocumentType
ÖÖ+ ?
.
ÖÖ? @
Boleta
ÖÖ@ F
or
ÖÖG I"
PurchaseDocumentType
ÖÖJ ^
.
ÖÖ^ _!
ReciboPorHonorarios
ÖÖ_ r
)
ÖÖr s
return
ÖÖt z

BadRequestÖÖ{ Ö
(ÖÖÖ Ü
newÖÖÜ â
{ÖÖä ã
messageÖÖå ì
=ÖÖî ï
$strÖÖñ ˙
}ÖÖ˚ ¸
)ÖÖ¸ ˝
;ÖÖ˝ ˛
var
áá 

issueMonth
áá 
=
áá 
new
áá 
DateOnly
áá %
(
áá% &
r
áá& '
.
áá' (
	IssueDate
áá( 1
.
áá1 2
Year
áá2 6
,
áá6 7
r
áá8 9
.
áá9 :
	IssueDate
áá: C
.
ááC D
Month
ááD I
,
ááI J
$num
ááK L
)
ááL M
;
ááM N
var
àà 
period
àà 
=
àà 

issueMonth
àà 
;
àà  
if
ââ 

(
ââ 
!
ââ 
string
ââ 
.
ââ  
IsNullOrWhiteSpace
ââ &
(
ââ& '
r
ââ' (
.
ââ( )
Period
ââ) /
)
ââ/ 0
)
ââ0 1
{
ää 	
if
ãã 
(
ãã 
!
ãã 
DateOnly
ãã 
.
ãã 
TryParseExact
ãã '
(
ãã' (
r
ãã( )
.
ãã) *
Period
ãã* 0
.
ãã0 1
Trim
ãã1 5
(
ãã5 6
)
ãã6 7
+
ãã8 9
$str
ãã: ?
,
ãã? @
$str
ããA M
,
ããM N
out
ããO R
period
ããS Y
)
ããY Z
)
ããZ [
return
ãã\ b

BadRequest
ããc m
(
ããm n
new
ããn q
{
ããr s
message
ããt {
=
ãã| }
$strãã~ û
}ããü †
)ãã† °
;ãã° ¢
if
åå 
(
åå 
period
åå 
<
åå 

issueMonth
åå #
)
åå# $
return
åå% +

BadRequest
åå, 6
(
åå6 7
new
åå7 :
{
åå; <
message
åå= D
=
ååE F
$strååG â
}ååä ã
)ååã å
;ååå ç
}
çç 	
var
èè 
series
èè 
=
èè 
(
èè 
r
èè 
.
èè 
Series
èè 
??
èè !
$str
èè" $
)
èè$ %
.
èè% &
Trim
èè& *
(
èè* +
)
èè+ ,
.
èè, -
ToUpperInvariant
èè- =
(
èè= >
)
èè> ?
;
èè? @
var
èèA D
number
èèE K
=
èèL M
r
èèN O
.
èèO P
Number
èèP V
.
èèV W
Trim
èèW [
(
èè[ \
)
èè\ ]
.
èè] ^
	TrimStart
èè^ g
(
èèg h
$char
èèh k
)
èèk l
;
èèl m
if
èèn p
(
èèq r
number
èèr x
.
èèx y
Length
èèy 
==èèÄ Ç
$numèèÉ Ñ
)èèÑ Ö
numberèèÜ å
=èèç é
$strèèè í
;èèí ì
if
êê 

(
êê 
await
êê 
db
êê 
.
êê 
	Purchases
êê 
.
êê 
AnyAsync
êê '
(
êê' (
x
êê( )
=>
êê* ,
x
êê- .
.
êê. /
Id
êê/ 1
!=
êê2 4
purchase
êê5 =
.
êê= >
Id
êê> @
&&
êêA C
x
êêD E
.
êêE F
SupplierTaxId
êêF S
==
êêT V
supplierTaxId
êêW d
&&
êêe g
x
êêh i
.
êêi j
DocumentType
êêj v
==
êêw y
r
êêz {
.
êê{ |
DocumentTypeêê| à
&&êêâ ã
xêêå ç
.êêç é
Seriesêêé î
==êêï ó
seriesêêò û
&&êêü °
xêê¢ £
.êê£ §
Numberêê§ ™
==êê´ ≠
numberêêÆ ¥
,êê¥ µ
ctêê∂ ∏
)êê∏ π
)êêπ ∫
return
ëë 
Conflict
ëë 
(
ëë 
new
ëë 
{
ëë  !
message
ëë" )
=
ëë* +
$"
ëë, .
$str
ëë. L
{
ëëL M
series
ëëM S
}
ëëS T
$str
ëëT U
{
ëëU V
number
ëëV \
}
ëë\ ]
$str
ëë] o
"
ëëo p
}
ëëq r
)
ëër s
;
ëës t
purchase
ìì 
.
ìì 
	IssueDate
ìì 
=
ìì 
r
ìì 
.
ìì 
	IssueDate
ìì (
;
ìì( )
purchase
ìì* 2
.
ìì2 3
Period
ìì3 9
=
ìì: ;
period
ìì< B
;
ììB C
purchase
ììD L
.
ììL M
DocumentType
ììM Y
=
ììZ [
r
ìì\ ]
.
ìì] ^
DocumentType
ìì^ j
;
ììj k
purchase
ììl t
.
ììt u
Series
ììu {
=
ìì| }
seriesìì~ Ñ
;ììÑ Ö
purchaseììÜ é
.ììé è
Numberììè ï
=ììñ ó
numberììò û
;ììû ü
purchase
îî 
.
îî 
SupplierTaxId
îî 
=
îî  
supplierTaxId
îî! .
;
îî. /
purchase
îî0 8
.
îî8 9
SupplierName
îî9 E
=
îîF G
r
îîH I
.
îîI J
SupplierName
îîJ V
.
îîV W
Trim
îîW [
(
îî[ \
)
îî\ ]
;
îî] ^
purchase
îî_ g
.
îîg h
Currency
îîh p
=
îîq r
currency
îîs {
;
îî{ |
purchase
ïï 
.
ïï 
TaxBase
ïï 
=
ïï 
r
ïï 
.
ïï 
TaxBase
ïï $
;
ïï$ %
purchase
ïï& .
.
ïï. /
Igv
ïï/ 2
=
ïï3 4
r
ïï5 6
.
ïï6 7
Igv
ïï7 :
;
ïï: ;
purchase
ïï< D
.
ïïD E

NonTaxable
ïïE O
=
ïïP Q
r
ïïR S
.
ïïS T

NonTaxable
ïïT ^
;
ïï^ _
purchase
ïï` h
.
ïïh i
Total
ïïi n
=
ïïo p
r
ïïq r
.
ïïr s
TaxBase
ïïs z
+
ïï{ |
r
ïï} ~
.
ïï~ 
Igvïï Ç
+ïïÉ Ñ
rïïÖ Ü
.ïïÜ á

NonTaxableïïá ë
;ïïë í
purchase
ññ 
.
ññ 
ExchangeRate
ññ 
=
ññ 
await
ññ  %
db
ññ& (
.
ññ( )
RateToPenAsync
ññ) 7
(
ññ7 8
currency
ññ8 @
,
ññ@ A
r
ññB C
.
ññC D
	IssueDate
ññD M
,
ññM N
ct
ññO Q
)
ññQ R
;
ññR S
purchase
óó 
.
óó 
BasePen
óó 
=
óó 
Math
óó 
.
óó  
Round
óó  %
(
óó% &
r
óó& '
.
óó' (
TaxBase
óó( /
*
óó0 1
purchase
óó2 :
.
óó: ;
ExchangeRate
óó; G
,
óóG H
$num
óóI J
)
óóJ K
;
óóK L
purchase
óóM U
.
óóU V
IgvPen
óóV \
=
óó] ^
Math
óó_ c
.
óóc d
Round
óód i
(
óói j
r
óój k
.
óók l
Igv
óól o
*
óóp q
purchase
óór z
.
óóz {
ExchangeRateóó{ á
,óóá à
$numóóâ ä
)óóä ã
;óóã å
purchaseóóç ï
.óóï ñ
TotalPenóóñ û
=óóü †
Mathóó° •
.óó• ¶
Roundóó¶ ´
(óó´ ¨
purchaseóó¨ ¥
.óó¥ µ
Totalóóµ ∫
*óóª º
purchaseóóΩ ≈
.óó≈ ∆
ExchangeRateóó∆ “
,óó“ ”
$numóó‘ ’
)óó’ ÷
;óó÷ ◊
purchase
òò 
.
òò 
GivesTaxCredit
òò 
=
òò  !
r
òò" #
.
òò# $$
UsedForTaxedOperations
òò$ :
&&
òò; =
r
òò> ?
.
òò? @
Igv
òò@ C
>
òòD E
$num
òòF G
&&
òòH J
Purchase
òòK S
.
òòS T
AllowsTaxCredit
òòT c
(
òòc d
r
òòd e
.
òòe f
DocumentType
òòf r
)
òòr s
;
òòs t
purchase
ôô 
.
ôô 
Notes
ôô 
=
ôô 
EmptyToNull
ôô $
(
ôô$ %
r
ôô% &
.
ôô& '
Notes
ôô' ,
)
ôô, -
;
ôô- .
return
öö 
null
öö 
;
öö 
}
õõ 
private
°° 
async
°° 
Task
°° 
<
°° 
ActionResult
°° #
?
°°# $
>
°°$ %
LinkExpenseAsync
°°& 6
(
°°6 7
Purchase
°°7 ?
purchase
°°@ H
,
°°H I
Guid
°°J N
?
°°N O

categoryId
°°P Z
,
°°Z [
CancellationToken
°°\ m
ct
°°n p
)
°°p q
{
¢¢ 
if
££ 

(
££ 
purchase
££ 
.
££ 
DocumentType
££ !
==
££" $"
PurchaseDocumentType
££% 9
.
££9 :
NotaCredito
££: E
)
££E F
return
££G M
purchase
££N V
.
££V W
	ExpenseId
££W `
is
££a c
null
££d h
?
££i j
null
££k o
:
££p q

BadRequest
££r |
(
££| }
new££} Ä
{££Å Ç
message££É ä
=££ã å
$str££ç ¬
}££√ ƒ
)££ƒ ≈
;££≈ ∆
var
§§ 
expense
§§ 
=
§§ 
purchase
§§ 
.
§§ 
	ExpenseId
§§ (
is
§§) +
Guid
§§, 0
id
§§1 3
?
§§4 5
await
§§6 ;
db
§§< >
.
§§> ?
Expenses
§§? G
.
§§G H
	FindAsync
§§H Q
(
§§Q R
[
§§R S
id
§§S U
]
§§U V
,
§§V W
ct
§§X Z
)
§§Z [
:
§§\ ]
null
§§^ b
;
§§b c
var
•• 
category
•• 
=
•• 

categoryId
•• !
??
••" $
expense
••% ,
?
••, -
.
••- .

CategoryId
••. 8
??
••9 ; 
ExpenseCategoryIds
••< N
.
••N O
Otros
••O T
;
••T U
if
¶¶ 

(
¶¶ 
!
¶¶ 
await
¶¶ 
db
¶¶ 
.
¶¶ 
ExpenseCategories
¶¶ '
.
¶¶' (
AnyAsync
¶¶( 0
(
¶¶0 1
x
¶¶1 2
=>
¶¶3 5
x
¶¶6 7
.
¶¶7 8
Id
¶¶8 :
==
¶¶; =
category
¶¶> F
,
¶¶F G
ct
¶¶H J
)
¶¶J K
)
¶¶K L
return
¶¶M S

BadRequest
¶¶T ^
(
¶¶^ _
new
¶¶_ b
{
¶¶c d
message
¶¶e l
=
¶¶m n
$str¶¶o ï
}¶¶ñ ó
)¶¶ó ò
;¶¶ò ô
if
ßß 

(
ßß 
expense
ßß 
is
ßß 
null
ßß 
)
ßß 
{
ßß 
expense
ßß &
=
ßß' (
new
ßß) ,
Expense
ßß- 4
{
ßß5 6
Type
ßß7 ;
=
ßß< =
ExpenseType
ßß> I
.
ßßI J
Variable
ßßJ R
}
ßßS T
;
ßßT U
db
ßßV X
.
ßßX Y
Expenses
ßßY a
.
ßßa b
Add
ßßb e
(
ßße f
expense
ßßf m
)
ßßm n
;
ßßn o
purchase
ßßp x
.
ßßx y
	ExpenseIdßßy Ç
=ßßÉ Ñ
expenseßßÖ å
.ßßå ç
Idßßç è
;ßßè ê
}ßßë í
expense
®® 
.
®® 
Description
®® 
=
®® 
$"
®®  
{
®®  !
purchase
®®! )
.
®®) *
SupplierName
®®* 6
}
®®6 7
$str
®®7 :
{
®®: ;
(
®®; <
purchase
®®< D
.
®®D E
Series
®®E K
.
®®K L
Length
®®L R
>
®®S T
$num
®®U V
?
®®W X
purchase
®®Y a
.
®®a b
Series
®®b h
+
®®i j
$str
®®k n
:
®®o p
$str
®®q s
)
®®s t
}
®®t u
{
®®u v
purchase
®®v ~
.
®®~ 
Number®® Ö
}®®Ö Ü
"®®Ü á
;®®á à
expense
©© 
.
©© 

CategoryId
©© 
=
©© 
category
©© %
;
©©% &
expense
©©' .
.
©©. /
Currency
©©/ 7
=
©©8 9
purchase
©©: B
.
©©B C
Currency
©©C K
;
©©K L
expense
©©M T
.
©©T U
Date
©©U Y
=
©©Z [
purchase
©©\ d
.
©©d e
	IssueDate
©©e n
;
©©n o
expense
™™ 
.
™™ 
Amount
™™ 
=
™™ 
purchase
™™ !
.
™™! "
GivesTaxCredit
™™" 0
?
™™1 2
purchase
™™3 ;
.
™™; <
TaxBase
™™< C
+
™™D E
purchase
™™F N
.
™™N O

NonTaxable
™™O Y
:
™™Z [
purchase
™™\ d
.
™™d e
Total
™™e j
;
™™j k
expense
´´ 
.
´´ 
	AmountPen
´´ 
=
´´ 
Math
´´  
.
´´  !
Round
´´! &
(
´´& '
expense
´´' .
.
´´. /
Amount
´´/ 5
*
´´6 7
purchase
´´8 @
.
´´@ A
ExchangeRate
´´A M
,
´´M N
$num
´´O P
)
´´P Q
;
´´Q R
return
¨¨ 
null
¨¨ 
;
¨¨ 
}
≠≠ 
private
ØØ 
static
ØØ 
decimal
ØØ 
Signed
ØØ !
(
ØØ! "
Purchase
ØØ" *
x
ØØ+ ,
,
ØØ, -
decimal
ØØ. 5
amount
ØØ6 <
)
ØØ< =
=>
ØØ> @
x
ØØA B
.
ØØB C
DocumentType
ØØC O
==
ØØP R"
PurchaseDocumentType
ØØS g
.
ØØg h
NotaCredito
ØØh s
?
ØØt u
-
ØØv w
amount
ØØw }
:
ØØ~ 
amountØØÄ Ü
;ØØÜ á
private
≤≤ 
static
≤≤ 
object
≤≤ 
PurchaseDto
≤≤ %
(
≤≤% &
Purchase
≤≤& .
x
≤≤/ 0
,
≤≤0 1
decimal
≤≤2 9
igvRate
≤≤: A
)
≤≤A B
=>
≤≤C E
new
≤≤F I
{
≥≥ 
id
¥¥ 

=
¥¥ 
x
¥¥ 
.
¥¥ 
Id
¥¥ 
,
¥¥ 
	issueDate
¥¥ 
=
¥¥ 
x
¥¥  
.
¥¥  !
	IssueDate
¥¥! *
,
¥¥* +
period
¥¥, 2
=
¥¥3 4
x
¥¥5 6
.
¥¥6 7
Period
¥¥7 =
.
¥¥= >
ToString
¥¥> F
(
¥¥F G
$str
¥¥G P
)
¥¥P Q
,
¥¥Q R
documentType
¥¥S _
=
¥¥` a
x
¥¥b c
.
¥¥c d
DocumentType
¥¥d p
.
¥¥p q
ToString
¥¥q y
(
¥¥y z
)
¥¥z {
,
¥¥{ |
series¥¥} É
=¥¥Ñ Ö
x¥¥Ü á
.¥¥á à
Series¥¥à é
,¥¥é è
number¥¥ê ñ
=¥¥ó ò
x¥¥ô ö
.¥¥ö õ
Number¥¥õ °
,¥¥° ¢
supplierTaxId
µµ 
=
µµ 
x
µµ 
.
µµ 
SupplierTaxId
µµ '
,
µµ' (
supplierName
µµ) 5
=
µµ6 7
x
µµ8 9
.
µµ9 :
SupplierName
µµ: F
,
µµF G
currency
µµH P
=
µµQ R
x
µµS T
.
µµT U
Currency
µµU ]
,
µµ] ^
taxBase
µµ_ f
=
µµg h
x
µµi j
.
µµj k
TaxBase
µµk r
,
µµr s
igv
µµt w
=
µµx y
x
µµz {
.
µµ{ |
Igv
µµ| 
,µµ Ä

nonTaxableµµÅ ã
=µµå ç
xµµé è
.µµè ê

NonTaxableµµê ö
,µµö õ
totalµµú °
=µµ¢ £
xµµ§ •
.µµ• ¶
Totalµµ¶ ´
,µµ´ ¨
exchangeRate
∂∂ 
=
∂∂ 
x
∂∂ 
.
∂∂ 
ExchangeRate
∂∂ %
,
∂∂% &
totalPen
∂∂' /
=
∂∂0 1
x
∂∂2 3
.
∂∂3 4
TotalPen
∂∂4 <
,
∂∂< =
igvPen
∂∂> D
=
∂∂E F
x
∂∂G H
.
∂∂H I
IgvPen
∂∂I O
,
∂∂O P
givesTaxCredit
∂∂Q _
=
∂∂` a
x
∂∂b c
.
∂∂c d
GivesTaxCredit
∂∂d r
,
∂∂r s
taxCreditPen∂∂t Ä
=∂∂Å Ç
x∂∂É Ñ
.∂∂Ñ Ö
TaxCreditPen∂∂Ö ë
,∂∂ë í
	expenseId∂∂ì ú
=∂∂ù û
x∂∂ü †
.∂∂† °
	ExpenseId∂∂° ™
,∂∂™ ´
notes∂∂¨ ±
=∂∂≤ ≥
x∂∂¥ µ
.∂∂µ ∂
Notes∂∂∂ ª
,∂∂ª º

igvWarning
∑∑ 
=
∑∑ 
x
∑∑ 
.
∑∑ 
Igv
∑∑ 
>
∑∑ 
$num
∑∑ 
&&
∑∑ !
Math
∑∑" &
.
∑∑& '
Abs
∑∑' *
(
∑∑* +
x
∑∑+ ,
.
∑∑, -
Igv
∑∑- 0
-
∑∑1 2
x
∑∑3 4
.
∑∑4 5
TaxBase
∑∑5 <
*
∑∑= >
igvRate
∑∑? F
)
∑∑F G
>
∑∑H I
$num
∑∑J L
,
∑∑L M
}
∏∏ 
;
∏∏ 
[
∫∫ 
GeneratedRegex
∫∫ 
(
∫∫ 
$str
∫∫ 
)
∫∫  
]
∫∫  !
private
ªª 
static
ªª 
partial
ªª 
Regex
ªª  
RucRegex
ªª! )
(
ªª) *
)
ªª* +
;
ªª+ ,
}ºº 
publicææ 
sealed
ææ 
record
ææ 
PurchaseRequest
ææ $
(
ææ$ %
DateOnly
ææ% -
	IssueDate
ææ. 7
,
ææ7 8
string
ææ9 ?
?
ææ? @
Period
ææA G
,
ææG H"
PurchaseDocumentType
ææI ]
DocumentType
ææ^ j
,
ææj k
string
ææl r
?
æær s
Series
ææt z
,
ææz {
stringææ| Ç
NumberææÉ â
,ææâ ä
stringææã ë
SupplierTaxIdææí ü
,ææü †
stringææ° ß
SupplierNameææ® ¥
,ææ¥ µ
string
øø 

Currency
øø 
,
øø 
decimal
øø 
TaxBase
øø $
,
øø$ %
decimal
øø& -
Igv
øø. 1
,
øø1 2
decimal
øø3 :

NonTaxable
øø; E
=
øøF G
$num
øøH I
,
øøI J
bool
øøK O$
UsedForTaxedOperations
øøP f
=
øøg h
true
øøi m
,
øøm n
bool
øøo s
CreateExpenseøøt Å
=øøÇ É
falseøøÑ â
,øøâ ä
Guidøøã è
?øøè ê!
ExpenseCategoryIdøøë ¢
=øø£ §
nulløø• ©
,øø© ™
stringøø´ ±
?øø± ≤
Notesøø≥ ∏
=øøπ ∫
nulløøª ø
)øøø ¿
;øø¿ ¡Î’
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AccountController.cs
	namespace 	
Rtres
 
. 
Api 
. 
Controllers 
;  
[ 
ApiController 
, 
	Authorize 
, 
Route  
(  !
$str! &
)& '
]' (
public 
sealed 
class 
AccountController %
(% &
RtresDbContext& 4
db5 7
,7 8
AccessEmailService9 K
accessEmailL W
)W X
:Y Z
ControllerBase[ i
{ 
private 
Guid 
UserId 
=> 
Guid 
.  
Parse  %
(% &
User& *
.* +
FindFirstValue+ 9
(9 :

ClaimTypes: D
.D E
NameIdentifierE S
)S T
!T U
)U V
;V W
private 
bool 
TryGetClientId 
(  
out  #
Guid$ (
clientId) 1
)1 2
=>3 5
Guid6 :
.: ;
TryParse; C
(C D
UserD H
.H I
FindFirstValueI W
(W X
$strX c
)c d
,d e
outf i
clientIdj r
)r s
;s t
internal 
static 
readonly 
PasswordHasher +
<+ ,
UserAccount, 7
>7 8
Hasher9 ?
=@ A
newB E
(E F
)F G
;G H
[ 
HttpGet 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
Profile$ +
(+ ,
CancellationToken, =
ct> @
)@ A
{B C
varD G
userH L
=M N
awaitO T
dbU W
.W X
UserAccountsX d
.d e
	FindAsynce n
(n o
[o p
UserIdp v
]v w
,w x
cty {
){ |
;| }
return	~ Ñ
user
Ö â
is
ä å
null
ç ë
?
í ì
NotFound
î ú
(
ú ù
)
ù û
:
ü †
Ok
° £
(
£ §
new
§ ß
{
® ©
name
™ Æ
=
Ø ∞
user
± µ
.
µ ∂
Name
∂ ∫
,
∫ ª
email
º ¡
=
¬ √
user
ƒ »
.
» …
Email
… Œ
}
œ –
)
– —
;
— “
}
” ‘
[ 
	HttpPatch 
( 
$str 
) 
] 
public 

async 
Task 
< 
ActionResult "
>" #
UpdateProfile$ 1
(1 2
ProfileRequest2 @
requestA H
,H I
CancellationTokenJ [
ct\ ^
)^ _
{` a
ifb d
(e f
stringf l
.l m
IsNullOrWhiteSpacem 
(	 Ä
request
Ä á
.
á à
Name
à å
)
å ç
)
ç é
return
è ï

BadRequest
ñ †
(
† °
new
° §
{
• ¶
message
ß Æ
=
Ø ∞
$str
± Ã
}
Õ Œ
)
Œ œ
;
œ –
var
— ‘
user
’ Ÿ
=
⁄ €
await
‹ ·
db
‚ ‰
.
‰ Â
UserAccounts
Â Ò
.
Ò Ú
	FindAsync
Ú ˚
(
˚ ¸
[
¸ ˝
UserId
˝ É
]
É Ñ
,
Ñ Ö
ct
Ü à
)
à â
;
â ä
if
ã ç
(
é è
user
è ì
is
î ñ
null
ó õ
)
õ ú
return
ù £
NotFound
§ ¨
(
¨ ≠
)
≠ Æ
;
Æ Ø
user
∞ ¥
.
¥ µ
Name
µ π
=
∫ ª
request
º √
.
√ ƒ
Name
ƒ »
.
» …
Trim
… Õ
(
Õ Œ
)
Œ œ
;
œ –
await
— ÷
db
◊ Ÿ
.
Ÿ ⁄
SaveChangesAsync
⁄ Í
(
Í Î
ct
Î Ì
)
Ì Ó
;
Ó Ô
return
 ˆ
Ok
˜ ˘
(
˘ ˙
)
˙ ˚
;
˚ ¸
}
˝ ˛
[ 
HttpPost 
( 
$str '
)' (
]( )
public 

async 
Task 
< 
ActionResult "
>" #
ChangePassword$ 2
(2 3!
ChangePasswordRequest3 H
requestI P
,P Q
CancellationTokenR c
ctd f
)f g
{h i
varj m
usern r
=s t
awaitu z
db{ }
.} ~
UserAccounts	~ ä
.
ä ã
	FindAsync
ã î
(
î ï
[
ï ñ
UserId
ñ ú
]
ú ù
,
ù û
ct
ü °
)
° ¢
;
¢ £
if
§ ¶
(
ß ®
user
® ¨
is
≠ Ø
null
∞ ¥
)
¥ µ
return
∂ º
NotFound
Ω ≈
(
≈ ∆
)
∆ «
;
« »
if
… À
(
Ã Õ
Hasher
Õ ”
.
” ‘"
VerifyHashedPassword
‘ Ë
(
Ë È
user
È Ì
,
Ì Ó
user
Ô Û
.
Û Ù
PasswordHash
Ù Ä
,
Ä Å
request
Ç â
.
â ä
CurrentPassword
ä ô
)
ô ö
==
õ ù(
PasswordVerificationResult
û ∏
.
∏ π
Failed
π ø
)
ø ¿
return
¡ «

BadRequest
» “
(
“ ”
new
” ÷
{
◊ ÿ
message
Ÿ ‡
=
· ‚
$str
„ Ü
}
á à
)
à â
;
â ä
if
ã ç
(
é è
string
è ï
.
ï ñ 
IsNullOrWhiteSpace
ñ ®
(
® ©
request
© ∞
.
∞ ±
NewPassword
± º
)
º Ω
)
Ω æ
return
ø ≈

BadRequest
∆ –
(
– —
new
— ‘
{
’ ÷
message
◊ ﬁ
=
ﬂ ‡
$str
· Ü
}
á à
)
à â
;
â ä
user
ã è
.
è ê
PasswordHash
ê ú
=
ù û
Hasher
ü •
.
• ¶
HashPassword
¶ ≤
(
≤ ≥
user
≥ ∑
,
∑ ∏
request
π ¿
.
¿ ¡
NewPassword
¡ Ã
)
Ã Õ
;
Õ Œ
await
œ ‘
db
’ ◊
.
◊ ÿ
SaveChangesAsync
ÿ Ë
(
Ë È
ct
È Î
)
Î Ï
;
Ï Ì
return
Ó Ù
Ok
ı ˜
(
˜ ¯
)
¯ ˘
;
˘ ˙
}
˚ ¸
internal   
static   
string   
TemporaryPassword   ,
(  , -
)  - .
=>  / 1
Convert  2 9
.  9 :
ToBase64String  : H
(  H I!
RandomNumberGenerator  I ^
.  ^ _
GetBytes  _ g
(  g h
$num  h j
)  j k
)  k l
.  l m
Replace  m t
(  t u
$str  u x
,  x y
$str  z }
)  } ~
.  ~ 
Replace	   Ü
(
  Ü á
$str
  á ä
,
  ä ã
$str
  å è
)
  è ê
;
  ê ë
["" 
HttpGet"" 
("" 
$str"" #
)""# $
]""$ %
public## 

async## 
Task## 
<## 
ActionResult## "
>##" #
Transactions##$ 0
(##0 1
Guid##1 5
?##5 6
clientId##7 ?
,##? @
CancellationToken##A R
ct##S U
)##U V
{$$ 
Guid&& 
?&& 
scope&& 
;&& 
if'' 

('' 
User'' 
.'' 
IsInRole'' 
('' 
nameof''  
(''  !
UserRole''! )
.'') *

SuperAdmin''* 4
)''4 5
)''5 6
)''6 7
scope''8 =
=''> ?
clientId''@ H
;''H I
else(( 
if(( 
((( 
TryGetClientId(( 
(((  
out((  #
var(($ '
own((( +
)((+ ,
)((, -
scope((. 3
=((4 5
own((6 9
;((9 :
else)) 
return)) 
Ok)) 
()) 
Array)) 
.)) 
Empty)) "
<))" #
object))# )
>))) *
())* +
)))+ ,
))), -
;))- .
return** 
Ok** 
(** 
await** 
(** 
from** 
transaction** )
in*** ,
db**- /
.**/ 0
PaymentTransactions**0 C
join++ 
client++ $
in++% '
db++( *
.++* +
Clients+++ 2
on++3 5
transaction++6 A
.++A B
ClientId++B J
equals++K Q
client++R X
.++X Y
Id++Y [
where,, 
scope,, $
==,,% '
null,,( ,
||,,- /
transaction,,0 ;
.,,; <
ClientId,,< D
==,,E G
scope,,H M
orderby--  
transaction--! ,
.--, -
	CreatedAt--- 6

descending--7 A
let// 
product// $
=//% &
(//' (
from//( ,
clientProduct//- :
in//; =
db//> @
.//@ A
ClientProducts//A O
join//P T
p//U V
in//W Y
db//Z \
.//\ ]
Products//] e
on//f h
clientProduct//i v
.//v w
	ProductId	//w Ä
equals
//Å á
p
//à â
.
//â ä
Id
//ä å
where
//ç í
clientProduct
//ì †
.
//† °
Id
//° £
==
//§ ¶
transaction
//ß ≤
.
//≤ ≥
ClientProductId
//≥ ¬
select
//√ …
p
//  À
.
//À Ã
Name
//Ã –
)
//– —
.
//— “
FirstOrDefault
//“ ‡
(
//‡ ·
)
//· ‚
select00 
new00  #
{00$ %
id00& (
=00) *
transaction00+ 6
.006 7
Id007 9
,009 :
	createdAt00; D
=00E F
transaction00G R
.00R S
	CreatedAt00S \
,00\ ]
product00^ e
=00f g
product00h o
??00p r
transaction00s ~
.00~ 
Notes	00 Ñ
??
00Ö á
transaction
00à ì
.
00ì î
Method
00î ö
,
00ö õ

clientName
00ú ¶
=
00ß ®
client
00© Ø
.
00Ø ∞
CompanyName
00∞ ª
,
00ª º
amount
00Ω √
=
00ƒ ≈
transaction
00∆ —
.
00— “
Amount
00“ ÿ
,
00ÿ Ÿ
currency
00⁄ ‚
=
00„ ‰
transaction
00Â 
.
00 Ò
Currency
00Ò ˘
,
00˘ ˙
status
00˚ Å
=
00Ç É
transaction
00Ñ è
.
00è ê
Status
00ê ñ
,
00ñ ó
internalCode
00ò §
=
00• ¶
transaction
00ß ≤
.
00≤ ≥
InternalCode
00≥ ø
}
00¿ ¡
)
00¡ ¬
.
00¬ √
ToListAsync
00√ Œ
(
00Œ œ
ct
00œ —
)
00— “
)
00“ ”
;
00” ‘
}11 
[22 
HttpGet22 
(22 
$str22 
)22 
,22 
	Authorize22 %
(22% &
Roles22& +
=22, -
$str22. 5
)225 6
]226 7
public33 

async33 
Task33 
<33 
ActionResult33 "
>33" #
Team33$ (
(33( )
CancellationToken33) :
ct33; =
)33= >
{33? @
if33A C
(33D E
!33E F
TryGetClientId33F T
(33T U
out33U X
var33Y \
clientId33] e
)33e f
)33f g
return33h n
Forbid33o u
(33u v
)33v w
;33w x
return33y 
Ok
33Ä Ç
(
33Ç É
await
33É à
db
33â ã
.
33ã å
UserAccounts
33å ò
.
33ò ô
Where
33ô û
(
33û ü
x
33ü †
=>
33° £
x
33§ •
.
33• ¶
ClientId
33¶ Æ
==
33Ø ±
clientId
33≤ ∫
)
33∫ ª
.
33ª º
OrderBy
33º √
(
33√ ƒ
x
33ƒ ≈
=>
33∆ »
x
33…  
.
33  À
Name
33À œ
)
33œ –
.
33– —
Select
33— ◊
(
33◊ ÿ
x
33ÿ Ÿ
=>
33⁄ ‹
new
33› ‡
{
33· ‚
id
33„ Â
=
33Ê Á
x
33Ë È
.
33È Í
Id
33Í Ï
,
33Ï Ì
name
33Ó Ú
=
33Û Ù
x
33ı ˆ
.
33ˆ ˜
Name
33˜ ˚
,
33˚ ¸
email
33˝ Ç
=
33É Ñ
x
33Ö Ü
.
33Ü á
Email
33á å
,
33å ç
role
33é í
=
33ì î
x
33ï ñ
.
33ñ ó
Role
33ó õ
.
33õ ú
ToString
33ú §
(
33§ •
)
33• ¶
,
33¶ ß
isActive
33® ∞
=
33± ≤
x
33≥ ¥
.
33¥ µ
IsActive
33µ Ω
}
33æ ø
)
33ø ¿
.
33¿ ¡
ToListAsync
33¡ Ã
(
33Ã Õ
ct
33Õ œ
)
33œ –
)
33– —
;
33— “
}
33” ‘
[44 
HttpPost44 
(44 
$str44 
)44 
,44 
	Authorize44 &
(44& '
Roles44' ,
=44- .
$str44/ 6
)446 7
]447 8
public55 

async55 
Task55 
<55 
ActionResult55 "
>55" #
Invite55$ *
(55* +
InviteRequest55+ 8
request559 @
,55@ A
CancellationToken55B S
ct55T V
)55V W
{55X Y
if55Z \
(55] ^
!55^ _
TryGetClientId55_ m
(55m n
out55n q
var55r u
clientId55v ~
)55~ 
)	55 Ä
return
55Å á
Forbid
55à é
(
55é è
)
55è ê
;
55ê ë
if
55í î
(
55ï ñ
string
55ñ ú
.
55ú ù 
IsNullOrWhiteSpace
55ù Ø
(
55Ø ∞
request
55∞ ∑
.
55∑ ∏
Name
55∏ º
)
55º Ω
||
55æ ¿
string
55¡ «
.
55« » 
IsNullOrWhiteSpace
55» ⁄
(
55⁄ €
request
55€ ‚
.
55‚ „
Email
55„ Ë
)
55Ë È
)
55È Í
return
55Î Ò

BadRequest
55Ú ¸
(
55¸ ˝
new
55˝ Ä
{
55Å Ç
message
55É ä
=
55ã å
$str
55ç Ø
}
55∞ ±
)
55± ≤
;
55≤ ≥
if
55¥ ∂
(
55∑ ∏
await
55∏ Ω
db
55æ ¿
.
55¿ ¡
UserAccounts
55¡ Õ
.
55Õ Œ
AnyAsync
55Œ ÷
(
55÷ ◊
x
55◊ ÿ
=>
55Ÿ €
x
55‹ ›
.
55› ﬁ
Email
55ﬁ „
==
55‰ Ê
request
55Á Ó
.
55Ó Ô
Email
55Ô Ù
,
55Ù ı
ct
55ˆ ¯
)
55¯ ˘
)
55˘ ˙
return
55˚ Å
Conflict
55Ç ä
(
55ä ã
new
55ã é
{
55è ê
message
55ë ò
=
55ô ö
$str
55õ π
}
55∫ ª
)
55ª º
;
55º Ω
var
55æ ¡
temporaryPassword
55¬ ”
=
55‘ ’
TemporaryPassword
55÷ Á
(
55Á Ë
)
55Ë È
;
55È Í
var
55Î Ó
user
55Ô Û
=
55Ù ı
new
55ˆ ˘
UserAccount
55˙ Ö
{
55Ü á
ClientId
55à ê
=
55ë í
clientId
55ì õ
,
55õ ú
Name
55ù °
=
55¢ £
request
55§ ´
.
55´ ¨
Name
55¨ ∞
.
55∞ ±
Trim
55± µ
(
55µ ∂
)
55∂ ∑
,
55∑ ∏
Email
55π æ
=
55ø ¿
request
55¡ »
.
55» …
Email
55… Œ
.
55Œ œ
Trim
55œ ”
(
55” ‘
)
55‘ ’
,
55’ ÷
Role
55◊ €
=
55‹ ›
UserRole
55ﬁ Ê
.
55Ê Á
Cliente
55Á Ó
}
55Ô 
;
55 Ò
user
55Ú ˆ
.
55ˆ ˜
PasswordHash
55˜ É
=
55Ñ Ö
Hasher
55Ü å
.
55å ç
HashPassword
55ç ô
(
55ô ö
user
55ö û
,
55û ü
temporaryPassword
55† ±
)
55± ≤
;
55≤ ≥
db
55¥ ∂
.
55∂ ∑
UserAccounts
55∑ √
.
55√ ƒ
Add
55ƒ «
(
55« »
user
55» Ã
)
55Ã Õ
;
55Õ Œ
await
55œ ‘
db
55’ ◊
.
55◊ ÿ
SaveChangesAsync
55ÿ Ë
(
55Ë È
ct
55È Î
)
55Î Ï
;
55Ï Ì
var
55Ó Ò
client
55Ú ¯
=
55˘ ˙
await
55˚ Ä
db
55Å É
.
55É Ñ
Clients
55Ñ ã
.
55ã å
	FindAsync
55å ï
(
55ï ñ
[
55ñ ó
clientId
55ó ü
]
55ü †
,
55† °
ct
55¢ §
)
55§ •
;
55• ¶
var
55ß ™
	emailSent
55´ ¥
=
55µ ∂
client
55∑ Ω
is
55æ ¿
not
55¡ ƒ
null
55≈ …
&&
55  Ã
await
55Õ “
accessEmail
55” ﬁ
.
55ﬁ ﬂ
	SendAsync
55ﬂ Ë
(
55Ë È
client
55È Ô
,
55Ô 
user
55Ò ı
.
55ı ˆ
Name
55ˆ ˙
,
55˙ ˚
user
55¸ Ä
.
55Ä Å
Email
55Å Ü
,
55Ü á
temporaryPassword
55à ô
,
55ô ö
Request
55õ ¢
,
55¢ £
ct
55§ ¶
)
55¶ ß
;
55ß ®
return
55© Ø
Created
55∞ ∑
(
55∑ ∏
$"
55∏ ∫
$str
55∫  
{
55  À
user
55À œ
.
55œ –
Id
55– “
}
55“ ”
"
55” ‘
,
55‘ ’
new
55÷ Ÿ
{
55⁄ €
id
55‹ ﬁ
=
55ﬂ ‡
user
55· Â
.
55Â Ê
Id
55Ê Ë
,
55Ë È
temporaryPassword
55Í ˚
,
55˚ ¸
	emailSent
55˝ Ü
}
55á à
)
55à â
;
55â ä
}
55ã å
[66 
	HttpPatch66 
(66 
$str66 %
)66% &
,66& '
	Authorize66( 1
(661 2
Roles662 7
=668 9
$str66: A
)66A B
]66B C
public77 

async77 
Task77 
<77 
ActionResult77 "
>77" #

UpdateTeam77$ .
(77. /
Guid77/ 3
id774 6
,776 7
UpdateTeamRequest778 I
request77J Q
,77Q R
CancellationToken77S d
ct77e g
)77g h
{77i j
if77k m
(77n o
!77o p
TryGetClientId77p ~
(77~ 
out	77 Ç
var
77É Ü
clientId
77á è
)
77è ê
)
77ê ë
return
77í ò
Forbid
77ô ü
(
77ü †
)
77† °
;
77° ¢
var
77£ ¶
user
77ß ´
=
77¨ ≠
await
77Æ ≥
db
77¥ ∂
.
77∂ ∑
UserAccounts
77∑ √
.
77√ ƒ"
SingleOrDefaultAsync
77ƒ ÿ
(
77ÿ Ÿ
x
77Ÿ ⁄
=>
77€ ›
x
77ﬁ ﬂ
.
77ﬂ ‡
Id
77‡ ‚
==
77„ Â
id
77Ê Ë
&&
77È Î
x
77Ï Ì
.
77Ì Ó
ClientId
77Ó ˆ
==
77˜ ˘
clientId
77˙ Ç
,
77Ç É
ct
77Ñ Ü
)
77Ü á
;
77á à
if
77â ã
(
77å ç
user
77ç ë
is
77í î
null
77ï ô
)
77ô ö
return
77õ °
NotFound
77¢ ™
(
77™ ´
)
77´ ¨
;
77¨ ≠
if
77Æ ∞
(
77± ≤
id
77≤ ¥
==
77µ ∑
UserId
77∏ æ
&&
77ø ¡
(
77¬ √
(
77√ ƒ
request
77ƒ À
.
77À Ã
Role
77Ã –
is
77— ”
UserRole
77‘ ‹
.
77‹ ›
Cliente
77› ‰
)
77‰ Â
||
77Ê Ë
request
77È 
.
77 Ò
IsActive
77Ò ˘
is
77˙ ¸
false
77˝ Ç
)
77Ç É
)
77É Ñ
return
77Ö ã

BadRequest
77å ñ
(
77ñ ó
new
77ó ö
{
77õ ú
message
77ù §
=
77• ¶
$str
77ß –
}
77— “
)
77“ ”
;
77” ‘
if
77’ ◊
(
77ÿ Ÿ
request
77Ÿ ‡
.
77‡ ·
Role
77· Â
is
77Ê Ë
UserRole
77È Ò
role
77Ú ˆ
&&
77˜ ˘
role
77˙ ˛
is
77ˇ Å
not
77Ç Ö
(
77Ü á
UserRole
77á è
.
77è ê
Cliente
77ê ó
or
77ò ö
UserRole
77õ £
.
77£ §
Admin
77§ ©
)
77© ™
)
77™ ´
return
77¨ ≤

BadRequest
77≥ Ω
(
77Ω æ
)
77æ ø
;
77ø ¿
if
77¡ √
(
77ƒ ≈
request
77≈ Ã
.
77Ã Õ
Role
77Õ —
is
77“ ‘
UserRole
77’ ›
	validRole
77ﬁ Á
)
77Á Ë
user
77È Ì
.
77Ì Ó
Role
77Ó Ú
=
77Û Ù
	validRole
77ı ˛
;
77˛ ˇ
if
77Ä Ç
(
77É Ñ
request
77Ñ ã
.
77ã å
IsActive
77å î
is
77ï ó
bool
77ò ú
active
77ù £
)
77£ §
user
77• ©
.
77© ™
IsActive
77™ ≤
=
77≥ ¥
active
77µ ª
;
77ª º
await
77Ω ¬
db
77√ ≈
.
77≈ ∆
SaveChangesAsync
77∆ ÷
(
77÷ ◊
ct
77◊ Ÿ
)
77Ÿ ⁄
;
77⁄ €
return
77‹ ‚
Ok
77„ Â
(
77Â Ê
)
77Ê Á
;
77Á Ë
}
77È Í
}88 
[:: 
ApiController:: 
,:: 
	Authorize:: 
(:: 
Roles:: 
=::  !
$str::" .
)::. /
,::/ 0
Route::1 6
(::6 7
$str::7 B
)::B C
]::C D
public;; 
sealed;; 
partial;; 
class;; 
AdminController;; +
(;;+ ,
RtresDbContext;;, :
db;;; =
,;;= >!
PayPalCheckoutService;;? T
checkoutService;;U d
,;;d e
ExchangeRateSyncJob;;f y
exchangeRateSync	;;z ä
,
;;ä ã 
AccessEmailService
;;å û
accessEmail
;;ü ™
,
;;™ ´ 
TaxDocumentService
;;¨ æ
taxDocuments
;;ø À
,
;;À Ã"
IBackgroundJobClient
;;Õ ·
jobs
;;‚ Ê
,
;;Ê Á!
INotificationSender
;;Ë ˚
notifications
;;¸ â
)
;;â ä
:
;;ã å
ControllerBase
;;ç õ
{<< 
private== 
Guid== 
UserId== 
=>== 
Guid== 
.==  
Parse==  %
(==% &
User==& *
.==* +
FindFirstValue==+ 9
(==9 :

ClaimTypes==: D
.==D E
NameIdentifier==E S
)==S T
!==T U
)==U V
;==V W
[>> 
HttpGet>> 
(>> 
$str>> 
)>> 
]>> 
public?? 

async?? 
Task?? 
<?? 
ActionResult?? "
>??" #
Tickets??$ +
(??+ ,
TicketStatus??, 8
???8 9
status??: @
,??@ A
Guid??B F
???F G
clientId??H P
,??P Q
Guid??R V
???V W
	projectId??X a
,??a b
int??c f
page??g k
=??l m
$num??n o
,??o p
CancellationToken	??q Ç
ct
??É Ö
=
??Ü á
default
??à è
)
??è ê
{@@ 
pageAA 
=AA 
MathAA 
.AA 
MaxAA 
(AA 
pageAA 
,AA 
$numAA 
)AA  
;AA  !
varBB 
queryBB 
=BB 
fromBB 
ticketBB 
inBB  "
dbBB# %
.BB% &
TicketsBB& -
joinCC 
clientCC 
inCC  "
dbCC# %
.CC% &
ClientsCC& -
onCC. 0
ticketCC1 7
.CC7 8
ClientIdCC8 @
equalsCCA G
clientCCH N
.CCN O
IdCCO Q
joinDD 
projectDD  
inDD! #
dbDD$ &
.DD& '
ProjectsDD' /
onDD0 2
ticketDD3 9
.DD9 :
	ProjectIdDD: C
equalsDDD J
projectDDK R
.DDR S
IdDDS U
whereEE 
(EE 
statusEE !
==EE" $
nullEE% )
||EE* ,
ticketEE- 3
.EE3 4
StatusEE4 :
==EE; =
statusEE> D
)EED E
&&EEF H
(EEI J
clientIdEEJ R
==EES U
nullEEV Z
||EE[ ]
ticketEE^ d
.EEd e
ClientIdEEe m
==EEn p
clientIdEEq y
)EEy z
&&EE{ }
(EE~ 
	projectId	EE à
==
EEâ ã
null
EEå ê
||
EEë ì
ticket
EEî ö
.
EEö õ
	ProjectId
EEõ §
==
EE• ß
	projectId
EE® ±
)
EE± ≤
orderbyFF 
ticketFF "
.FF" #
	UpdatedAtFF# ,

descendingFF- 7
selectGG 
newGG 
{GG  
ticketGG! '
,GG' (
clientGG) /
,GG/ 0
projectGG1 8
}GG9 :
;GG: ;
varHH 
totalHH 
=HH 
awaitHH 
queryHH 
.HH  

CountAsyncHH  *
(HH* +
ctHH+ -
)HH- .
;HH. /
varII 
itemsII 
=II 
awaitII 
queryII 
.II  
SkipII  $
(II$ %
(II% &
pageII& *
-II+ ,
$numII- .
)II. /
*II0 1
$numII2 4
)II4 5
.II5 6
TakeII6 :
(II: ;
$numII; =
)II= >
.II> ?
SelectII? E
(IIE F
xIIF G
=>IIH J
newIIK N
{IIO P
idIIQ S
=IIT U
xIIV W
.IIW X
ticketIIX ^
.II^ _
IdII_ a
,IIa b
codeIIc g
=IIh i
xIIj k
.IIk l
ticketIIl r
.IIr s
CodeIIs w
,IIw x
clientId	IIy Å
=
IIÇ É
x
IIÑ Ö
.
IIÖ Ü
ticket
IIÜ å
.
IIå ç
ClientId
IIç ï
,
IIï ñ
	projectId
IIó †
=
II° ¢
x
II£ §
.
II§ •
ticket
II• ´
.
II´ ¨
	ProjectId
II¨ µ
,
IIµ ∂
type
II∑ ª
=
IIº Ω
x
IIæ ø
.
IIø ¿
ticket
II¿ ∆
.
II∆ «
Type
II« À
.
IIÀ Ã
ToString
IIÃ ‘
(
II‘ ’
)
II’ ÷
,
II÷ ◊
status
IIÿ ﬁ
=
IIﬂ ‡
x
II· ‚
.
II‚ „
ticket
II„ È
.
IIÈ Í
Status
IIÍ 
.
II Ò
ToString
IIÒ ˘
(
II˘ ˙
)
II˙ ˚
,
II˚ ¸
title
II˝ Ç
=
IIÉ Ñ
x
IIÖ Ü
.
IIÜ á
ticket
IIá ç
.
IIç é
Title
IIé ì
,
IIì î
description
IIï †
=
II° ¢
x
II£ §
.
II§ •
ticket
II• ´
.
II´ ¨
Description
II¨ ∑
,
II∑ ∏
	createdAt
IIπ ¬
=
II√ ƒ
x
II≈ ∆
.
II∆ «
ticket
II« Õ
.
IIÕ Œ
	CreatedAt
IIŒ ◊
,
II◊ ÿ
	updatedAt
IIŸ ‚
=
II„ ‰
x
IIÂ Ê
.
IIÊ Á
ticket
IIÁ Ì
.
IIÌ Ó
	UpdatedAt
IIÓ ˜
,
II˜ ¯
githubIssueNumber
II˘ ä
=
IIã å
x
IIç é
.
IIé è
ticket
IIè ï
.
IIï ñ
GithubIssueNumber
IIñ ß
,
IIß ®
githubIssueUrl
II© ∑
=
II∏ π
x
II∫ ª
.
IIª º
ticket
IIº ¬
.
II¬ √
GithubIssueUrl
II√ —
,
II— “
client
II” Ÿ
=
II⁄ €
new
II‹ ﬂ
{
II‡ ·
id
II‚ ‰
=
IIÂ Ê
x
IIÁ Ë
.
IIË È
client
IIÈ Ô
.
IIÔ 
Id
II Ú
,
IIÚ Û
name
IIÙ ¯
=
II˘ ˙
x
II˚ ¸
.
II¸ ˝
client
II˝ É
.
IIÉ Ñ
CompanyName
IIÑ è
}
IIê ë
,
IIë í
project
IIì ö
=
IIõ ú
new
IIù †
{
II° ¢
id
II£ •
=
II¶ ß
x
II® ©
.
II© ™
project
II™ ±
.
II± ≤
Id
II≤ ¥
,
II¥ µ
name
II∂ ∫
=
IIª º
x
IIΩ æ
.
IIæ ø
project
IIø ∆
.
II∆ «
Name
II« À
}
IIÃ Õ
,
IIÕ Œ
	managedIn
IIœ ÿ
=
IIŸ ⁄
db
II€ ›
.
II› ﬁ!
ProjectRepositories
IIﬁ Ò
.
IIÒ Ú
Any
IIÚ ı
(
IIı ˆ
r
IIˆ ˜
=>
II¯ ˙
r
II˚ ¸
.
II¸ ˝
	ProjectId
II˝ Ü
==
IIá â
x
IIä ã
.
IIã å
project
IIå ì
.
IIì î
Id
IIî ñ
)
IIñ ó
?
IIò ô
$str
IIö ¢
:
II£ §
$str
II• ≠
}
IIÆ Ø
)
IIØ ∞
.
II∞ ±
ToListAsync
II± º
(
IIº Ω
ct
IIΩ ø
)
IIø ¿
;
II¿ ¡
returnJJ 
OkJJ 
(JJ 
newJJ 
{JJ 
itemsJJ 
,JJ 
pageJJ #
,JJ# $

totalPagesJJ% /
=JJ0 1
(JJ2 3
intJJ3 6
)JJ6 7
MathJJ7 ;
.JJ; <
CeilingJJ< C
(JJC D
totalJJD I
/JJJ K
$numJJL O
)JJO P
}JJQ R
)JJR S
;JJS T
}KK 
[LL 
	HttpPatchLL 
(LL 
$strLL "
)LL" #
]LL# $
publicMM 

asyncMM 
TaskMM 
<MM 
ActionResultMM "
>MM" #
UpdateTicketMM$ 0
(MM0 1
GuidMM1 5
idMM6 8
,MM8 9%
UpdateTicketStatusRequestMM: S
requestMMT [
,MM[ \
CancellationTokenMM] n
ctMMo q
)MMq r
{NN 
varOO 
entryOO 
=OO 
awaitOO 
(OO 
fromOO 
ticketOO  &
inOO' )
dbOO* ,
.OO, -
TicketsOO- 4
joinOO5 9
projectOO: A
inOOB D
dbOOE G
.OOG H
ProjectsOOH P
onOOQ S
ticketOOT Z
.OOZ [
	ProjectIdOO[ d
equalsOOe k
projectOOl s
.OOs t
IdOOt v
whereOOw |
ticket	OO} É
.
OOÉ Ñ
Id
OOÑ Ü
==
OOá â
id
OOä å
select
OOç ì
new
OOî ó
{
OOò ô
ticket
OOö †
,
OO† °
project
OO¢ ©
}
OO™ ´
)
OO´ ¨
.
OO¨ ≠"
SingleOrDefaultAsync
OO≠ ¡
(
OO¡ ¬
ct
OO¬ ƒ
)
OOƒ ≈
;
OO≈ ∆
if
OO« …
(
OO  À
entry
OOÀ –
is
OO— ”
null
OO‘ ÿ
)
OOÿ Ÿ
return
OO⁄ ‡
NotFound
OO· È
(
OOÈ Í
)
OOÍ Î
;
OOÎ Ï
ifPP 

(PP 
awaitPP 
dbPP 
.PP 
ProjectRepositoriesPP (
.PP( )
AnyAsyncPP) 1
(PP1 2
xPP2 3
=>PP4 6
xPP7 8
.PP8 9
	ProjectIdPP9 B
==PPC E
entryPPF K
.PPK L
projectPPL S
.PPS T
IdPPT V
,PPV W
ctPPX Z
)PPZ [
)PP[ \
returnPP] c
ConflictPPd l
(PPl m
newPPm p
{PPq r
messagePPs z
=PP{ |
$str	PP} ≠
}
PPÆ Ø
)
PPØ ∞
;
PP∞ ±
ifQQ 

(QQ 
entryQQ 
.QQ 
ticketQQ 
.QQ 
StatusQQ 
==QQ  "
requestQQ# *
.QQ* +
StatusQQ+ 1
)QQ1 2
returnQQ3 9
OkQQ: <
(QQ< =
newQQ= @
{QQA B
statusQQC I
=QQJ K
entryQQL Q
.QQQ R
ticketQQR X
.QQX Y
StatusQQY _
.QQ_ `
ToStringQQ` h
(QQh i
)QQi j
}QQk l
)QQl m
;QQm n
entryRR 
.RR 
ticketRR 
.RR 
StatusRR 
=RR 
requestRR %
.RR% &
StatusRR& ,
;RR, -
entryRR. 3
.RR3 4
ticketRR4 :
.RR: ;
	UpdatedAtRR; D
=RRE F
DateTimeRRG O
.RRO P
UtcNowRRP V
;RRV W
awaitRRX ]
dbRR^ `
.RR` a
SaveChangesAsyncRRa q
(RRq r
ctRRr t
)RRt u
;RRu v
varSS 
clientSS 
=SS 
awaitSS 
dbSS 
.SS 
ClientsSS %
.SS% &
SingleAsyncSS& 1
(SS1 2
xSS2 3
=>SS4 6
xSS7 8
.SS8 9
IdSS9 ;
==SS< >
entrySS? D
.SSD E
ticketSSE K
.SSK L
ClientIdSSL T
,SST U
ctSSV X
)SSX Y
;SSY Z
awaitTT 
notificationsTT 
.TT 
	SendAsyncTT %
(TT% &
clientTT& ,
,TT, -
newTT. 1
NotificationTT2 >
(TT> ?
NotificationTypeTT? O
.TTO P
TicketStatusChangedTTP c
,TTc d
newTTe h
(TTh i
)TTi j
{TTk l
[TTm n
$strTTn x
]TTx y
=TTz {
entry	TT| Å
.
TTÅ Ç
ticket
TTÇ à
.
TTà â
Id
TTâ ã
.
TTã å
ToString
TTå î
(
TTî ï
)
TTï ñ
,
TTñ ó
[
TTò ô
$str
TTô ü
]
TTü †
=
TT° ¢
entry
TT£ ®
.
TT® ©
ticket
TT© Ø
.
TTØ ∞
Code
TT∞ ¥
,
TT¥ µ
[
TT∂ ∑
$str
TT∑ æ
]
TTæ ø
=
TT¿ ¡
entry
TT¬ «
.
TT« »
ticket
TT» Œ
.
TTŒ œ
Title
TTœ ‘
,
TT‘ ’
[
TT÷ ◊
$str
TT◊ ﬂ
]
TTﬂ ‡
=
TT· ‚
entry
TT„ Ë
.
TTË È
ticket
TTÈ Ô
.
TTÔ 
Status
TT ˆ
.
TTˆ ˜
ToString
TT˜ ˇ
(
TTˇ Ä
)
TTÄ Å
}
TTÇ É
,
TTÉ Ñ
$"
TTÖ á
$str
TTá ï
{
TTï ñ
entry
TTñ õ
.
TTõ ú
ticket
TTú ¢
.
TT¢ £
Id
TT£ •
}
TT• ¶
$str
TT¶ ß
{
TTß ®
entry
TT® ≠
.
TT≠ Æ
ticket
TTÆ ¥
.
TT¥ µ
	UpdatedAt
TTµ æ
.
TTæ ø
Ticks
TTø ƒ
}
TTƒ ≈
"
TT≈ ∆
)
TT∆ «
,
TT« »
ct
TT… À
)
TTÀ Ã
;
TTÃ Õ
returnUU 
OkUU 
(UU 
newUU 
{UU 
statusUU 
=UU  
entryUU! &
.UU& '
ticketUU' -
.UU- .
StatusUU. 4
.UU4 5
ToStringUU5 =
(UU= >
)UU> ?
}UU@ A
)UUA B
;UUB C
}VV 
[WW 
HttpPostWW 
(WW 
$strWW *
)WW* +
]WW+ ,
publicXX 

asyncXX 
TaskXX 
<XX 
ActionResultXX "
>XX" #
AddTicketCommentXX$ 4
(XX4 5
GuidXX5 9
idXX: <
,XX< =&
CreateTicketCommentRequestXX> X
requestXXY `
,XX` a
CancellationTokenXXb s
ctXXt v
)XXv w
{YY 
ifZZ 

(ZZ 
stringZZ 
.ZZ 
IsNullOrWhiteSpaceZZ %
(ZZ% &
requestZZ& -
.ZZ- .
BodyZZ. 2
)ZZ2 3
)ZZ3 4
returnZZ5 ;

BadRequestZZ< F
(ZZF G
newZZG J
{ZZK L
messageZZM T
=ZZU V
$strZZW |
}ZZ} ~
)ZZ~ 
;	ZZ Ä
var[[ 
entry[[ 
=[[ 
await[[ 
([[ 
from[[ 
ticket[[  &
in[[' )
db[[* ,
.[[, -
Tickets[[- 4
join[[5 9
project[[: A
in[[B D
db[[E G
.[[G H
Projects[[H P
on[[Q S
ticket[[T Z
.[[Z [
	ProjectId[[[ d
equals[[e k
project[[l s
.[[s t
Id[[t v
where[[w |
ticket	[[} É
.
[[É Ñ
Id
[[Ñ Ü
==
[[á â
id
[[ä å
select
[[ç ì
new
[[î ó
{
[[ò ô
ticket
[[ö †
,
[[† °
project
[[¢ ©
}
[[™ ´
)
[[´ ¨
.
[[¨ ≠"
SingleOrDefaultAsync
[[≠ ¡
(
[[¡ ¬
ct
[[¬ ƒ
)
[[ƒ ≈
;
[[≈ ∆
if
[[« …
(
[[  À
entry
[[À –
is
[[— ”
null
[[‘ ÿ
)
[[ÿ Ÿ
return
[[⁄ ‡
NotFound
[[· È
(
[[È Í
)
[[Í Î
;
[[Î Ï
var\\ 
comment\\ 
=\\ 
new\\ 
TicketComment\\ '
{\\( )
TicketId\\* 2
=\\3 4
id\\5 7
,\\7 8
AuthorUserId\\9 E
=\\F G
UserId\\H N
,\\N O
Body\\P T
=\\U V
request\\W ^
.\\^ _
Body\\_ c
.\\c d
Trim\\d h
(\\h i
)\\i j
}\\k l
;\\l m
db\\n p
.\\p q
TicketComments\\q 
.	\\ Ä
Add
\\Ä É
(
\\É Ñ
comment
\\Ñ ã
)
\\ã å
;
\\å ç
entry
\\é ì
.
\\ì î
ticket
\\î ö
.
\\ö õ
	UpdatedAt
\\õ §
=
\\• ¶
DateTime
\\ß Ø
.
\\Ø ∞
UtcNow
\\∞ ∂
;
\\∂ ∑
await
\\∏ Ω
db
\\æ ¿
.
\\¿ ¡
SaveChangesAsync
\\¡ —
(
\\— “
ct
\\“ ‘
)
\\‘ ’
;
\\’ ÷
if]] 

(]] 
await]] 
db]] 
.]] 
ProjectRepositories]] (
.]]( )
AnyAsync]]) 1
(]]1 2
x]]2 3
=>]]4 6
x]]7 8
.]]8 9
	ProjectId]]9 B
==]]C E
entry]]F K
.]]K L
project]]L S
.]]S T
Id]]T V
,]]V W
ct]]X Z
)]]Z [
)]][ \
jobs]]] a
.]]a b
Enqueue]]b i
<]]i j
GitHubIssueSyncJob]]j |
>]]| }
(]]} ~
j]]~ 
=>
]]Ä Ç
j
]]É Ñ
.
]]Ñ Ö
PostCommentAsync
]]Ö ï
(
]]ï ñ
comment
]]ñ ù
.
]]ù û
Id
]]û †
,
]]† °
CancellationToken
]]¢ ≥
.
]]≥ ¥
None
]]¥ ∏
)
]]∏ π
)
]]π ∫
;
]]∫ ª
var^^ 
client^^ 
=^^ 
await^^ 
db^^ 
.^^ 
Clients^^ %
.^^% &
SingleAsync^^& 1
(^^1 2
x^^2 3
=>^^4 6
x^^7 8
.^^8 9
Id^^9 ;
==^^< >
entry^^? D
.^^D E
ticket^^E K
.^^K L
ClientId^^L T
,^^T U
ct^^V X
)^^X Y
;^^Y Z
await__ 
notifications__ 
.__ 
	SendAsync__ %
(__% &
client__& ,
,__, -
new__. 1
Notification__2 >
(__> ?
NotificationType__? O
.__O P
TicketReply__P [
,__[ \
new__] `
(__` a
)__a b
{__c d
[__e f
$str__f p
]__p q
=__r s
entry__t y
.__y z
ticket	__z Ä
.
__Ä Å
Id
__Å É
.
__É Ñ
ToString
__Ñ å
(
__å ç
)
__ç é
,
__é è
[
__ê ë
$str
__ë ó
]
__ó ò
=
__ô ö
entry
__õ †
.
__† °
ticket
__° ß
.
__ß ®
Code
__® ¨
,
__¨ ≠
[
__Æ Ø
$str
__Ø ∂
]
__∂ ∑
=
__∏ π
entry
__∫ ø
.
__ø ¿
ticket
__¿ ∆
.
__∆ «
Title
__« Ã
,
__Ã Õ
[
__Œ œ
$str
__œ ◊
]
__◊ ÿ
=
__Ÿ ⁄
$str
__€ ‚
,
__‚ „
[
__‰ Â
$str
__Â Î
]
__Î Ï
=
__Ì Ó
comment
__Ô ˆ
.
__ˆ ˜
Body
__˜ ˚
}
__¸ ˝
,
__˝ ˛
$"
__ˇ Å
$str
__Å ï
{
__ï ñ
comment
__ñ ù
.
__ù û
Id
__û †
}
__† °
"
__° ¢
)
__¢ £
,
__£ §
ct
__• ß
)
__ß ®
;
__® ©
return`` 
Ok`` 
(`` 
await`` 
PortalController`` (
.``( )
ToCommentDtos``) 6
(``6 7
db``7 9
,``9 :
db``; =
.``= >
TicketComments``> L
.``L M
Where``M R
(``R S
x``S T
=>``U W
x``X Y
.``Y Z
Id``Z \
==``] _
comment``` g
.``g h
Id``h j
)``j k
)``k l
.``l m
SingleAsync``m x
(``x y
ct``y {
)``{ |
)``| }
;``} ~
}aa 
[bb 
HttpGetbb 
(bb 
$strbb 
)bb 
]bb 
publiccc 

asynccc 
Taskcc 
<cc 
ActionResultcc "
>cc" #
ExchangeRatescc$ 1
(cc1 2
DateOnlycc2 :
?cc: ;
fromcc< @
,cc@ A
DateOnlyccB J
?ccJ K
toccL N
,ccN O
CancellationTokenccP a
ctccb d
)ccd e
=>ccf h
Okcci k
(cck l
awaitccl q
dbccr t
.cct u
ExchangeRates	ccu Ç
.dd 	
Wheredd	 
(dd 
xdd 
=>dd 
(dd 
fromdd 
==dd 
nulldd !
||dd" $
xdd% &
.dd& '
Datedd' +
>=dd, .
fromdd/ 3
)dd3 4
&&dd5 7
(dd8 9
todd9 ;
==dd< >
nulldd? C
||ddD F
xddG H
.ddH I
DateddI M
<=ddN P
toddQ S
)ddS T
)ddT U
.ddU V
OrderByDescendingddV g
(ddg h
xddh i
=>ddj l
xddm n
.ddn o
Dateddo s
)dds t
.ee 	
Selectee	 
(ee 
xee 
=>ee 
newee 
{ee 
dateee 
=ee  !
xee" #
.ee# $
Dateee$ (
,ee( )
currencyCodeee* 6
=ee7 8
xee9 :
.ee: ;
CurrencyCodeee; G
,eeG H
	rateToPeneeI R
=eeS T
xeeU V
.eeV W
	RateToPeneeW `
,ee` a
sourceeeb h
=eei j
xeek l
.eel m
Sourceeem s
}eet u
)eeu v
.eev w
ToListAsync	eew Ç
(
eeÇ É
ct
eeÉ Ö
)
eeÖ Ü
)
eeÜ á
;
eeá à
[gg 
HttpPostgg 
(gg 
$strgg #
)gg# $
]gg$ %
publichh 

asynchh 
Taskhh 
<hh 
ActionResulthh "
>hh" #
SyncExchangeRateshh$ 5
(hh5 6
CancellationTokenhh6 G
cthhH J
)hhJ K
{ii 
awaitjj 
exchangeRateSyncjj 
.jj 
	SyncAsyncjj (
(jj( )
ctjj) +
)jj+ ,
;jj, -
returnkk 
Okkk 
(kk 
awaitkk 
dbkk 
.kk 
ExchangeRateskk (
.kk( )
OrderByDescendingkk) :
(kk: ;
xkk; <
=>kk= ?
xkk@ A
.kkA B
DatekkB F
)kkF G
.kkG H
TakekkH L
(kkL M
$numkkM N
)kkN O
.kkO P
SelectkkP V
(kkV W
xkkW X
=>kkY [
newkk\ _
{kk` a
datekkb f
=kkg h
xkki j
.kkj k
Datekkk o
,kko p
currencyCodekkq }
=kk~ 
x
kkÄ Å
.
kkÅ Ç
CurrencyCode
kkÇ é
,
kké è
	rateToPen
kkê ô
=
kkö õ
x
kkú ù
.
kkù û
	RateToPen
kkû ß
,
kkß ®
source
kk© Ø
=
kk∞ ±
x
kk≤ ≥
.
kk≥ ¥
Source
kk¥ ∫
}
kkª º
)
kkº Ω
.
kkΩ æ
ToListAsync
kkæ …
(
kk…  
ct
kk  Ã
)
kkÃ Õ
)
kkÕ Œ
;
kkŒ œ
}ll 
[nn 
HttpGetnn 
(nn 
$strnn 
)nn 
]nn 
publicoo 

asyncoo 
Taskoo 
<oo 
ActionResultoo "
>oo" #
TaxSettingsoo$ /
(oo/ 0
CancellationTokenoo0 A
ctooB D
)ooD E
=>ooF H
OkooI K
(ooK L
TaxSettingsDtoooL Z
(ooZ [
awaitoo[ `
TaxSettingsRowooa o
(ooo p
ctoop r
)oor s
)oos t
)oot u
;oou v
[qq 
	HttpPatchqq 
(qq 
$strqq 
)qq 
]qq 
publicrr 

asyncrr 
Taskrr 
<rr 
ActionResultrr "
>rr" #
UpdateTaxSettingsrr$ 5
(rr5 6
TaxSettingsRequestrr6 H
requestrrI P
,rrP Q
CancellationTokenrrR c
ctrrd f
)rrf g
{ss 
iftt 

(tt 
requesttt 
.tt 
IgvRatett 
istt 
decimaltt &
igvtt' *
&&tt+ -
(tt. /
igvtt/ 2
<tt3 4
$numtt5 6
||tt7 9
igvtt: =
>tt> ?
$numtt@ A
)ttA B
||ttC E
requestttF M
.ttM N
	RentaRatettN W
isttX Z
decimaltt[ b
renta0ttc i
&&ttj l
(ttm n
renta0ttn t
<ttu v
$numttw x
||tty {
renta0	tt| Ç
>
ttÉ Ñ
$num
ttÖ Ü
)
ttÜ á
)
ttá à
return
ttâ è

BadRequest
ttê ö
(
ttö õ
new
ttõ û
{
ttü †
message
tt° ®
=
tt© ™
$str
tt´ „
}
tt‰ Â
)
ttÂ Ê
;
ttÊ Á
varuu 
settingsuu 
=uu 
awaituu 
TaxSettingsRowuu +
(uu+ ,
ctuu, .
)uu. /
;uu/ 0
varvv 
facturaSeriesvv 
=vv 
requestvv #
.vv# $
FacturaSeriesvv$ 1
?vv1 2
.vv2 3
Trimvv3 7
(vv7 8
)vv8 9
.vv9 :
ToUpperInvariantvv: J
(vvJ K
)vvK L
??vvM O
settingsvvP X
.vvX Y
FacturaSeriesvvY f
;vvf g
varvvh k
reciboSeriesvvl x
=vvy z
request	vv{ Ç
.
vvÇ É
ReciboSeries
vvÉ è
?
vvè ê
.
vvê ë
Trim
vvë ï
(
vvï ñ
)
vvñ ó
.
vvó ò
ToUpperInvariant
vvò ®
(
vv® ©
)
vv© ™
??
vv´ ≠
settings
vvÆ ∂
.
vv∂ ∑
ReciboSeries
vv∑ √
;
vv√ ƒ
ifyy 

(yy 
!yy 
Regexyy 
.yy 
IsMatchyy 
(yy 
facturaSeriesyy (
,yy( )
$stryy* =
)yy= >
||yy? A
!yyB C
RegexyyC H
.yyH I
IsMatchyyI P
(yyP Q
reciboSeriesyyQ ]
,yy] ^
$stryy_ o
)yyo p
)yyp q
returnyyr x

BadRequest	yyy É
(
yyÉ Ñ
new
yyÑ á
{
yyà â
message
yyä ë
=
yyí ì
$str
yyî ¥
}
yyµ ∂
)
yy∂ ∑
;
yy∑ ∏
varzz 
facturaNextzz 
=zz 
requestzz !
.zz! "
FacturaNextNumberzz" 3
??zz4 6
settingszz7 ?
.zz? @
FacturaNextNumberzz@ Q
;zzQ R
varzzS V

reciboNextzzW a
=zzb c
requestzzd k
.zzk l
ReciboNextNumberzzl |
??zz} 
settings
zzÄ à
.
zzà â
ReciboNextNumber
zzâ ô
;
zzô ö
if{{ 

({{ 
facturaNext{{ 
<{{ 
$num{{ 
||{{ 

reciboNext{{ )
<{{* +
$num{{, -
){{- .
return{{/ 5

BadRequest{{6 @
({{@ A
new{{A D
{{{E F
message{{G N
={{O P
$str{{Q }
}{{~ 
)	{{ Ä
;
{{Ä Å
if}} 

(}} 
await}} 
LastNumberAsync}} !
(}}! "
TaxDocumentType}}" 1
.}}1 2
Factura}}2 9
,}}9 :
facturaSeries}}; H
,}}H I
ct}}J L
)}}L M
is}}N P
int}}Q T
lastF}}U Z
&&}}[ ]
facturaNext}}^ i
<=}}j l
lastF}}m r
)}}r s
return}}t z

BadRequest	}}{ Ö
(
}}Ö Ü
new
}}Ü â
{
}}ä ã
message
}}å ì
=
}}î ï
$"
}}ñ ò
$str
}}ò °
{
}}° ¢
facturaSeries
}}¢ Ø
}
}}Ø ∞
$str
}}∞ …
{
}}…  
lastF
}}  œ
}
}}œ –
$str
}}– ¯
"
}}¯ ˘
}
}}˙ ˚
)
}}˚ ¸
;
}}¸ ˝
if~~ 

(~~ 
await~~ 
LastNumberAsync~~ !
(~~! "
TaxDocumentType~~" 1
.~~1 2
ReciboPorHonorarios~~2 E
,~~E F
reciboSeries~~G S
,~~S T
ct~~U W
)~~W X
is~~Y [
int~~\ _
lastR~~` e
&&~~f h

reciboNext~~i s
<=~~t v
lastR~~w |
)~~| }
return	~~~ Ñ

BadRequest
~~Ö è
(
~~è ê
new
~~ê ì
{
~~î ï
message
~~ñ ù
=
~~û ü
$"
~~† ¢
$str
~~¢ ´
{
~~´ ¨
reciboSeries
~~¨ ∏
}
~~∏ π
$str
~~π —
{
~~— “
lastR
~~“ ◊
}
~~◊ ÿ
$str
~~ÿ Ä
"
~~Ä Å
}
~~Ç É
)
~~É Ñ
;
~~Ñ Ö
var 
ruc 
= 
request 
. 
Ruc 
is  
null! %
?& '
settings( 0
.0 1
Ruc1 4
:5 6
request7 >
.> ?
Ruc? B
.B C
TrimC G
(G H
)H I
isJ L
{M N
LengthO U
:U V
>W X
$numY Z
}[ \
trimmed] d
?e f
trimmedg n
:o p
nullq u
;u v
if
ÄÄ 

(
ÄÄ 
ruc
ÄÄ 
is
ÄÄ 
not
ÄÄ 
null
ÄÄ 
&&
ÄÄ 
!
ÄÄ  
Regex
ÄÄ  %
.
ÄÄ% &
IsMatch
ÄÄ& -
(
ÄÄ- .
ruc
ÄÄ. 1
,
ÄÄ1 2
$str
ÄÄ3 L
)
ÄÄL M
)
ÄÄM N
return
ÄÄO U

BadRequest
ÄÄV `
(
ÄÄ` a
new
ÄÄa d
{
ÄÄe f
message
ÄÄg n
=
ÄÄo p
$strÄÄq ©
}ÄÄ™ ´
)ÄÄ´ ¨
;ÄÄ¨ ≠
settings
ÅÅ 
.
ÅÅ 
Ruc
ÅÅ 
=
ÅÅ 
ruc
ÅÅ 
;
ÅÅ 
if
ÇÇ 

(
ÇÇ 
request
ÇÇ 
.
ÇÇ 
IsGoodTaxpayer
ÇÇ "
is
ÇÇ# %
bool
ÇÇ& *
goodTaxpayer
ÇÇ+ 7
)
ÇÇ7 8
settings
ÇÇ9 A
.
ÇÇA B
IsGoodTaxpayer
ÇÇB P
=
ÇÇQ R
goodTaxpayer
ÇÇS _
;
ÇÇ_ `
if
ÉÉ 

(
ÉÉ 
request
ÉÉ 
.
ÉÉ 
Use1662AsCredit
ÉÉ #
is
ÉÉ$ &
bool
ÉÉ' +
use1662
ÉÉ, 3
)
ÉÉ3 4
settings
ÉÉ5 =
.
ÉÉ= >
Use1662AsCredit
ÉÉ> M
=
ÉÉN O
use1662
ÉÉP W
;
ÉÉW X
if
ÑÑ 

(
ÑÑ 
request
ÑÑ 
.
ÑÑ 
IgvRate
ÑÑ 
is
ÑÑ 
decimal
ÑÑ &
igvRate
ÑÑ' .
)
ÑÑ. /
settings
ÑÑ0 8
.
ÑÑ8 9
IgvRate
ÑÑ9 @
=
ÑÑA B
igvRate
ÑÑC J
;
ÑÑJ K
if
ÖÖ 

(
ÖÖ 
request
ÖÖ 
.
ÖÖ 
	RentaRate
ÖÖ 
is
ÖÖ  
decimal
ÖÖ! (
	rentaRate
ÖÖ) 2
)
ÖÖ2 3
settings
ÖÖ4 <
.
ÖÖ< =
	RentaRate
ÖÖ= F
=
ÖÖG H
	rentaRate
ÖÖI R
;
ÖÖR S
(
ÜÜ 	
settings
ÜÜ	 
.
ÜÜ 
FacturaSeries
ÜÜ 
,
ÜÜ  
settings
ÜÜ! )
.
ÜÜ) *
FacturaNextNumber
ÜÜ* ;
,
ÜÜ; <
settings
ÜÜ= E
.
ÜÜE F
ReciboSeries
ÜÜF R
,
ÜÜR S
settings
ÜÜT \
.
ÜÜ\ ]
ReciboNextNumber
ÜÜ] m
)
ÜÜm n
=
ÜÜo p
(
ÜÜq r
facturaSeries
ÜÜr 
,ÜÜ Ä
facturaNextÜÜÅ å
,ÜÜå ç
reciboSeriesÜÜé ö
,ÜÜö õ

reciboNextÜÜú ¶
)ÜÜ¶ ß
;ÜÜß ®
settings
áá 
.
áá 
	UpdatedAt
áá 
=
áá 
DateTime
áá %
.
áá% &
UtcNow
áá& ,
;
áá, -
await
àà 
db
àà 
.
àà 
SaveChangesAsync
àà !
(
àà! "
ct
àà" $
)
àà$ %
;
àà% &
return
ââ 
Ok
ââ 
(
ââ 
TaxSettingsDto
ââ  
(
ââ  !
settings
ââ! )
)
ââ) *
)
ââ* +
;
ââ+ ,
}
ää 
private
åå 
Task
åå 
<
åå 
int
åå 
?
åå 
>
åå 
LastNumberAsync
åå &
(
åå& '
TaxDocumentType
åå' 6
type
åå7 ;
,
åå; <
string
åå= C
series
ååD J
,
ååJ K
CancellationToken
ååL ]
ct
åå^ `
)
åå` a
=>
ååb d
db
ååe g
.
ååg h
TaxDocuments
ååh t
.
ååt u
Where
ååu z
(
ååz {
x
åå{ |
=>
åå} 
xååÄ Å
.ååÅ Ç
TypeååÇ Ü
==ååá â
typeååä é
&&ååè ë
xååí ì
.ååì î
Seriesååî ö
==ååõ ù
seriesååû §
)åå§ •
.åå• ¶
MaxAsyncåå¶ Æ
(ååÆ Ø
xååØ ∞
=>åå± ≥
(åå¥ µ
intååµ ∏
?åå∏ π
)ååπ ∫
xåå∫ ª
.ååª º
Numberååº ¬
,åå¬ √
ctååƒ ∆
)åå∆ «
;åå« »
private
çç 
static
çç 
object
çç 
TaxSettingsDto
çç (
(
çç( )
TaxSettings
çç) 4
x
çç5 6
)
çç6 7
=>
çç8 :
new
çç; >
{
çç? @
igvRate
ççA H
=
ççI J
x
ççK L
.
ççL M
IgvRate
ççM T
,
ççT U
	rentaRate
ççV _
=
çç` a
x
ççb c
.
ççc d
	RentaRate
ççd m
,
ççm n
facturaSeries
çço |
=
çç} ~
xçç Ä
.ççÄ Å
FacturaSeriesççÅ é
,ççé è!
facturaNextNumberççê °
=çç¢ £
xçç§ •
.çç• ¶!
FacturaNextNumberçç¶ ∑
,çç∑ ∏
reciboSeriesççπ ≈
=çç∆ «
xçç» …
.çç…  
ReciboSeriesçç  ÷
,çç÷ ◊ 
reciboNextNumberççÿ Ë
=ççÈ Í
xççÎ Ï
.ççÏ Ì 
ReciboNextNumberççÌ ˝
,çç˝ ˛
rucççˇ Ç
=ççÉ Ñ
xççÖ Ü
.ççÜ á
Rucççá ä
,ççä ã
isGoodTaxpayerççå ö
=ççõ ú
xççù û
.ççû ü
IsGoodTaxpayerççü ≠
,çç≠ Æ
use1662AsCreditççØ æ
=ççø ¿
xçç¡ ¬
.çç¬ √
Use1662AsCreditçç√ “
}çç” ‘
;çç‘ ’
private
èè 
async
èè 
Task
èè 
<
èè 
TaxSettings
èè "
>
èè" #
TaxSettingsRow
èè$ 2
(
èè2 3
CancellationToken
èè3 D
ct
èèE G
)
èèG H
{
êê 
var
ëë 
settings
ëë 
=
ëë 
await
ëë 
db
ëë 
.
ëë  
TaxSettings
ëë  +
.
ëë+ ,!
FirstOrDefaultAsync
ëë, ?
(
ëë? @
ct
ëë@ B
)
ëëB C
;
ëëC D
if
íí 

(
íí 
settings
íí 
is
íí 
not
íí 
null
íí  
)
íí  !
return
íí" (
settings
íí) 1
;
íí1 2
settings
ìì 
=
ìì 
new
ìì 
TaxSettings
ìì "
(
ìì" #
)
ìì# $
;
ìì$ %
db
ìì& (
.
ìì( )
TaxSettings
ìì) 4
.
ìì4 5
Add
ìì5 8
(
ìì8 9
settings
ìì9 A
)
ììA B
;
ììB C
await
ììD I
db
ììJ L
.
ììL M
SaveChangesAsync
ììM ]
(
ìì] ^
ct
ìì^ `
)
ìì` a
;
ììa b
return
ììc i
settings
ììj r
;
ììr s
}
îî 
[
ññ 
HttpGet
ññ 
(
ññ 
$str
ññ 
)
ññ 
]
ññ 
public
óó 

async
óó 
Task
óó 
<
óó 
ActionResult
óó "
>
óó" #
TaxDocuments
óó$ 0
(
óó0 1
Guid
óó1 5
?
óó5 6
clientId
óó7 ?
,
óó? @
int
óóA D
?
óóD E
month
óóF K
,
óóK L
int
óóM P
?
óóP Q
year
óóR V
,
óóV W
CancellationToken
óóX i
ct
óój l
)
óól m
{
òò 
var
ôô 
rows
ôô 
=
ôô 
await
ôô 
db
ôô 
.
ôô 
TaxDocuments
ôô (
.
öö 
Where
öö 
(
öö 
x
öö 
=>
öö 
(
öö 
clientId
öö !
==
öö" $
null
öö% )
||
öö* ,
x
öö- .
.
öö. /
ClientId
öö/ 7
==
öö8 :
clientId
öö; C
)
ööC D
&&
ööE G
(
ööH I
month
ööI N
==
ööO Q
null
ööR V
||
ööW Y
x
ööZ [
.
öö[ \
	IssueDate
öö\ e
.
ööe f
Month
ööf k
==
ööl n
month
ööo t
)
ööt u
&&
ööv x
(
ööy z
year
ööz ~
==öö Å
nullööÇ Ü
||ööá â
xööä ã
.ööã å
	IssueDateööå ï
.ööï ñ
Yearööñ ö
==ööõ ù
yearööû ¢
)öö¢ £
)öö£ §
.
õõ 
OrderByDescending
õõ 
(
õõ 
x
õõ  
=>
õõ! #
x
õõ$ %
.
õõ% &
	IssueDate
õõ& /
)
õõ/ 0
.
õõ0 1
ThenByDescending
õõ1 A
(
õõA B
x
õõB C
=>
õõD F
x
õõG H
.
õõH I
Number
õõI O
)
õõO P
.
úú 
Select
úú 
(
úú 
x
úú 
=>
úú 
new
úú 
{
úú 
Document
úú '
=
úú( )
x
úú* +
,
úú+ ,
Payment
úú- 4
=
úú5 6
db
úú7 9
.
úú9 :!
PaymentTransactions
úú: M
.
úúM N
Where
úúN S
(
úúS T
p
úúT U
=>
úúV X
p
úúY Z
.
úúZ [
Id
úú[ ]
==
úú^ `
x
úúa b
.
úúb c"
PaymentTransactionId
úúc w
)
úúw x
.
úúx y
Select
úúy 
(úú Ä
púúÄ Å
=>úúÇ Ñ
newúúÖ à
{úúâ ä
púúã å
.úúå ç
Amountúúç ì
,úúì î
púúï ñ
.úúñ ó
	AmountPenúúó †
,úú† °
púú¢ £
.úú£ §
Methodúú§ ™
}úú´ ¨
)úú¨ ≠
.úú≠ Æ
FirstOrDefaultúúÆ º
(úúº Ω
)úúΩ æ
}úúø ¿
)úú¿ ¡
.
ùù 
ToListAsync
ùù 
(
ùù 
ct
ùù 
)
ùù 
;
ùù 
var
ûû 
docIds
ûû 
=
ûû 
rows
ûû 
.
ûû 
Select
ûû  
(
ûû  !
x
ûû! "
=>
ûû# %
x
ûû& '
.
ûû' (
Document
ûû( 0
.
ûû0 1
Id
ûû1 3
)
ûû3 4
.
ûû4 5
ToList
ûû5 ;
(
ûû; <
)
ûû< =
;
ûû= >
var
üü 
lines
üü 
=
üü 
(
üü 
await
üü 
db
üü 
.
üü 
TaxDocumentLines
üü .
.
üü. /
Where
üü/ 4
(
üü4 5
x
üü5 6
=>
üü7 9
docIds
üü: @
.
üü@ A
Contains
üüA I
(
üüI J
x
üüJ K
.
üüK L
TaxDocumentId
üüL Y
)
üüY Z
)
üüZ [
.
üü[ \
OrderBy
üü\ c
(
üüc d
x
üüd e
=>
üüf h
x
üüi j
.
üüj k
Order
üük p
)
üüp q
.
üüq r
ToListAsync
üür }
(
üü} ~
ctüü~ Ä
)üüÄ Å
)üüÅ Ç
.üüÇ É
ToLookupüüÉ ã
(üüã å
xüüå ç
=>üüé ê
xüüë í
.üüí ì
TaxDocumentIdüüì †
)üü† °
;üü° ¢
var
†† 
result
†† 
=
†† 
new
†† 
List
†† 
<
†† 
object
†† $
>
††$ %
(
††% &
rows
††& *
.
††* +
Count
††+ 0
)
††0 1
;
††1 2
foreach
°° 
(
°° 
var
°° 
x
°° 
in
°° 
rows
°° 
)
°° 
{
¢¢ 	
var
§§ 
rate
§§ 
=
§§ 
x
§§ 
.
§§ 
Payment
§§  
is
§§! #
{
§§$ %
Amount
§§& ,
:
§§, -
>
§§. /
$num
§§0 1
}
§§2 3
p
§§4 5
?
§§6 7
p
§§8 9
.
§§9 :
	AmountPen
§§: C
/
§§D E
p
§§F G
.
§§G H
Amount
§§H N
:
§§O P
await
§§Q V
db
§§W Y
.
§§Y Z
RateToPenAsync
§§Z h
(
§§h i
x
§§i j
.
§§j k
Document
§§k s
.
§§s t
Currency
§§t |
,
§§| }
x
§§~ 
.§§ Ä
Document§§Ä à
.§§à â
	IssueDate§§â í
,§§í ì
ct§§î ñ
)§§ñ ó
;§§ó ò
result
•• 
.
•• 
Add
•• 
(
•• 
TaxDocumentDto
•• %
(
••% &
x
••& '
.
••' (
Document
••( 0
,
••0 1
rate
••2 6
,
••6 7
lines
••8 =
[
••= >
x
••> ?
.
••? @
Document
••@ H
.
••H I
Id
••I K
]
••K L
,
••L M
x
••N O
.
••O P
Payment
••P W
?
••W X
.
••X Y
Method
••Y _
)
••_ `
)
••` a
;
••a b
}
¶¶ 	
return
ßß 
Ok
ßß 
(
ßß 
result
ßß 
)
ßß 
;
ßß 
}
®® 
[
ÆÆ 
HttpPost
ÆÆ 
(
ÆÆ 
$str
ÆÆ 
)
ÆÆ 
]
ÆÆ 
public
ØØ 

async
ØØ 
Task
ØØ 
<
ØØ 
ActionResult
ØØ "
>
ØØ" #
CreateTaxDocument
ØØ$ 5
(
ØØ5 6 
TaxDocumentRequest
ØØ6 H
request
ØØI P
,
ØØP Q
CancellationToken
ØØR c
ct
ØØd f
)
ØØf g
{
∞∞ 
IReadOnlyList
±± 
<
±± $
TaxDocumentItemRequest
±± ,
>
±±, -
items
±±. 3
=
±±4 5
request
±±6 =
.
±±= >
Items
±±> C
is
±±D F
{
±±G H
Count
±±I N
:
±±N O
>
±±P Q
$num
±±R S
}
±±T U
list
±±V Z
?
±±[ \
list
±±] a
:
±±b c
request
±±d k
.
±±k l
ClientProductId
±±l {
is
±±| ~
Guid±± É
single±±Ñ ä
?±±ã å
[±±ç é
new±±é ë&
TaxDocumentItemRequest±±í ®
(±±® ©
single±±© Ø
,±±Ø ∞
request±±± ∏
.±±∏ π
TotalAmount±±π ƒ
)±±ƒ ≈
]±±≈ ∆
:±±« »
[±±…  
]±±  À
;±±À Ã
if
≤≤ 

(
≤≤ 
string
≤≤ 
.
≤≤  
IsNullOrWhiteSpace
≤≤ %
(
≤≤% &
request
≤≤& -
.
≤≤- .
Currency
≤≤. 6
)
≤≤6 7
||
≤≤8 :
items
≤≤; @
.
≤≤@ A
Count
≤≤A F
==
≤≤G I
$num
≤≤J K
)
≤≤K L
return
≤≤M S

BadRequest
≤≤T ^
(
≤≤^ _
new
≤≤_ b
{
≤≤c d
message
≤≤e l
=
≤≤m n
$str≤≤o †
}≤≤° ¢
)≤≤¢ £
;≤≤£ §
if
≥≥ 

(
≥≥ 
items
≥≥ 
.
≥≥ 
Any
≥≥ 
(
≥≥ 
x
≥≥ 
=>
≥≥ 
x
≥≥ 
.
≥≥ 
Amount
≥≥ #
<=
≥≥$ &
$num
≥≥' (
)
≥≥( )
)
≥≥) *
return
≥≥+ 1

BadRequest
≥≥2 <
(
≥≥< =
new
≥≥= @
{
≥≥A B
message
≥≥C J
=
≥≥K L
$str
≥≥M }
}
≥≥~ 
)≥≥ Ä
;≥≥Ä Å
if
¥¥ 

(
¥¥ 
items
¥¥ 
.
¥¥ 
Select
¥¥ 
(
¥¥ 
x
¥¥ 
=>
¥¥ 
x
¥¥ 
.
¥¥  
ClientProductId
¥¥  /
)
¥¥/ 0
.
¥¥0 1
Distinct
¥¥1 9
(
¥¥9 :
)
¥¥: ;
.
¥¥; <
Count
¥¥< A
(
¥¥A B
)
¥¥B C
!=
¥¥D F
items
¥¥G L
.
¥¥L M
Count
¥¥M R
)
¥¥R S
return
¥¥T Z

BadRequest
¥¥[ e
(
¥¥e f
new
¥¥f i
{
¥¥j k
message
¥¥l s
=
¥¥t u
$str¥¥v õ
}¥¥ú ù
)¥¥ù û
;¥¥û ü
var
µµ 
ids
µµ 
=
µµ 
items
µµ 
.
µµ 
Select
µµ 
(
µµ 
x
µµ  
=>
µµ! #
x
µµ$ %
.
µµ% &
ClientProductId
µµ& 5
)
µµ5 6
.
µµ6 7
ToList
µµ7 =
(
µµ= >
)
µµ> ?
;
µµ? @
var
∂∂ 
products
∂∂ 
=
∂∂ 
await
∂∂ 
db
∂∂ 
.
∂∂  
ClientProducts
∂∂  .
.
∂∂. /
Include
∂∂/ 6
(
∂∂6 7
x
∂∂7 8
=>
∂∂9 ;
x
∂∂< =
.
∂∂= >
Product
∂∂> E
)
∂∂E F
.
∂∂F G
Where
∂∂G L
(
∂∂L M
x
∂∂M N
=>
∂∂O Q
ids
∂∂R U
.
∂∂U V
Contains
∂∂V ^
(
∂∂^ _
x
∂∂_ `
.
∂∂` a
Id
∂∂a c
)
∂∂c d
)
∂∂d e
.
∂∂e f
ToListAsync
∂∂f q
(
∂∂q r
ct
∂∂r t
)
∂∂t u
;
∂∂u v
if
∑∑ 

(
∑∑ 
products
∑∑ 
.
∑∑ 
Count
∑∑ 
!=
∑∑ 
items
∑∑ #
.
∑∑# $
Count
∑∑$ )
||
∑∑* ,
products
∑∑- 5
.
∑∑5 6
Any
∑∑6 9
(
∑∑9 :
x
∑∑: ;
=>
∑∑< >
x
∑∑? @
.
∑∑@ A
Product
∑∑A H
is
∑∑I K
null
∑∑L P
)
∑∑P Q
)
∑∑Q R
return
∑∑S Y
NotFound
∑∑Z b
(
∑∑b c
new
∑∑c f
{
∑∑g h
message
∑∑i p
=
∑∑q r
$str∑∑s ò
}∑∑ô ö
)∑∑ö õ
;∑∑õ ú
if
∏∏ 

(
∏∏ 
products
∏∏ 
.
∏∏ 
Select
∏∏ 
(
∏∏ 
x
∏∏ 
=>
∏∏  
x
∏∏! "
.
∏∏" #
ClientId
∏∏# +
)
∏∏+ ,
.
∏∏, -
Distinct
∏∏- 5
(
∏∏5 6
)
∏∏6 7
.
∏∏7 8
Count
∏∏8 =
(
∏∏= >
)
∏∏> ?
>
∏∏@ A
$num
∏∏B C
)
∏∏C D
return
∏∏E K

BadRequest
∏∏L V
(
∏∏V W
new
∏∏W Z
{
∏∏[ \
message
∏∏] d
=
∏∏e f
$str∏∏g ô
}∏∏ö õ
)∏∏õ ú
;∏∏ú ù
var
ππ 
types
ππ 
=
ππ 
products
ππ 
.
ππ 
Select
ππ #
(
ππ# $
x
ππ$ %
=>
ππ& (
x
ππ) *
.
ππ* +
Product
ππ+ 2
!
ππ2 3
.
ππ3 4
TaxDocumentType
ππ4 C
)
ππC D
.
ππD E
Distinct
ππE M
(
ππM N
)
ππN O
.
ππO P
ToList
ππP V
(
ππV W
)
ππW X
;
ππX Y
if
∫∫ 

(
∫∫ 
types
∫∫ 
.
∫∫ 
Count
∫∫ 
>
∫∫ 
$num
∫∫ 
)
∫∫ 
return
∫∫ #

BadRequest
∫∫$ .
(
∫∫. /
new
∫∫/ 2
{
∫∫3 4
message
∫∫5 <
=
∫∫= >
$str∫∫? ∑
}∫∫∏ π
)∫∫π ∫
;∫∫∫ ª
var
ªª 
client
ªª 
=
ªª 
await
ªª 
db
ªª 
.
ªª 
Clients
ªª %
.
ªª% &
	FindAsync
ªª& /
(
ªª/ 0
[
ªª0 1
products
ªª1 9
[
ªª9 :
$num
ªª: ;
]
ªª; <
.
ªª< =
ClientId
ªª= E
]
ªªE F
,
ªªF G
ct
ªªH J
)
ªªJ K
;
ªªK L
if
ºº 

(
ºº 
client
ºº 
is
ºº 
null
ºº 
||
ºº 
!
ºº 
client
ºº %
.
ºº% &!
RequiresTaxDocument
ºº& 9
)
ºº9 :
return
ºº; A

BadRequest
ººB L
(
ººL M
new
ººM P
{
ººQ R
message
ººS Z
=
ºº[ \
$strºº] ≤
}ºº≥ ¥
)ºº¥ µ
;ººµ ∂
var
ΩΩ 
total
ΩΩ 
=
ΩΩ 
items
ΩΩ 
.
ΩΩ 
Sum
ΩΩ 
(
ΩΩ 
x
ΩΩ 
=>
ΩΩ  "
x
ΩΩ# $
.
ΩΩ$ %
Amount
ΩΩ% +
)
ΩΩ+ ,
;
ΩΩ, -
if
ææ 

(
ææ 
request
ææ 
.
ææ 
RetentionAmount
ææ #
is
ææ$ &
<
ææ' (
$num
ææ) *
||
ææ+ -
request
ææ. 5
.
ææ5 6
RetentionAmount
ææ6 E
>
ææF G
total
ææH M
)
ææM N
return
ææO U

BadRequest
ææV `
(
ææ` a
new
ææa d
{
ææe f
message
ææg n
=
ææo p
$strææq û
}ææü †
)ææ† °
;ææ° ¢
var
¡¡ 
currency
¡¡ 
=
¡¡ 
request
¡¡ 
.
¡¡ 
Currency
¡¡ '
.
¡¡' (
Trim
¡¡( ,
(
¡¡, -
)
¡¡- .
.
¡¡. /
ToUpperInvariant
¡¡/ ?
(
¡¡? @
)
¡¡@ A
;
¡¡A B
var
¬¬ 
payment
¬¬ 
=
¬¬ 
new
¬¬  
PaymentTransaction
¬¬ ,
{
¬¬- .
ClientId
¬¬/ 7
=
¬¬8 9
client
¬¬: @
.
¬¬@ A
Id
¬¬A C
,
¬¬C D
ClientProductId
¬¬E T
=
¬¬U V
items
¬¬W \
.
¬¬\ ]
Count
¬¬] b
==
¬¬c e
$num
¬¬f g
?
¬¬h i
items
¬¬j o
[
¬¬o p
$num
¬¬p q
]
¬¬q r
.
¬¬r s
ClientProductId¬¬s Ç
:¬¬É Ñ
null¬¬Ö â
,¬¬â ä
Amount¬¬ã ë
=¬¬í ì
total¬¬î ô
,¬¬ô ö
Currency¬¬õ £
=¬¬§ •
currency¬¬¶ Æ
,¬¬Æ Ø
Status¬¬∞ ∂
=¬¬∑ ∏
$str¬¬π ƒ
,¬¬ƒ ≈
Method¬¬∆ Ã
=¬¬Õ Œ
PaymentMethods¬¬œ ›
.¬¬› ﬁ
Transferencia¬¬ﬁ Î
,¬¬Î Ï
	CreatedAt¬¬Ì ˆ
=¬¬˜ ¯
request¬¬˘ Ä
.¬¬Ä Å
	IssueDate¬¬Å ä
.¬¬ä ã

ToDateTime¬¬ã ï
(¬¬ï ñ
new¬¬ñ ô
TimeOnly¬¬ö ¢
(¬¬¢ £
$num¬¬£ •
,¬¬• ¶
$num¬¬ß ®
)¬¬® ©
,¬¬© ™
DateTimeKind¬¬´ ∑
.¬¬∑ ∏
Utc¬¬∏ ª
)¬¬ª º
,¬¬º Ω
Notes¬¬æ √
=¬¬ƒ ≈
EmptyToNull¬¬∆ —
(¬¬— “
request¬¬“ Ÿ
.¬¬Ÿ ⁄
Notes¬¬⁄ ﬂ
)¬¬ﬂ ‡
}¬¬· ‚
;¬¬‚ „
payment
√√ 
.
√√ +
PayPalOrderIdOrSubscriptionId
√√ -
=
√√. /
$"
√√0 2
$str
√√2 9
{
√√9 :
payment
√√: A
.
√√A B
Id
√√B D
:
√√D E
$str
√√E F
}
√√F G
"
√√G H
;
√√H I
payment
ƒƒ 
.
ƒƒ 
InternalCode
ƒƒ 
=
ƒƒ 
await
ƒƒ $
db
ƒƒ% '
.
ƒƒ' (#
NextInternalCodeAsync
ƒƒ( =
(
ƒƒ= >
ct
ƒƒ> @
)
ƒƒ@ A
;
ƒƒA B
payment
≈≈ 
.
≈≈ 
	AmountPen
≈≈ 
=
≈≈ 
payment
≈≈ #
.
≈≈# $
Amount
≈≈$ *
*
≈≈+ ,
await
≈≈- 2
db
≈≈3 5
.
≈≈5 6
RateToPenAsync
≈≈6 D
(
≈≈D E
currency
≈≈E M
,
≈≈M N
request
≈≈O V
.
≈≈V W
	IssueDate
≈≈W `
,
≈≈` a
ct
≈≈b d
)
≈≈d e
;
≈≈e f
db
∆∆ 

.
∆∆
 !
PaymentTransactions
∆∆ 
.
∆∆ 
Add
∆∆ "
(
∆∆" #
payment
∆∆# *
)
∆∆* +
;
∆∆+ ,
await
∆∆- 2
db
∆∆3 5
.
∆∆5 6
SaveChangesAsync
∆∆6 F
(
∆∆F G
ct
∆∆G I
)
∆∆I J
;
∆∆J K
var
«« 
lines
«« 
=
«« 
items
«« 
.
«« 
Select
««  
(
««  !
x
««! "
=>
««# %
new
««& )
TaxDocumentLine
««* 9
{
««: ;
ClientProductId
««< K
=
««L M
x
««N O
.
««O P
ClientProductId
««P _
,
««_ `
Description
««a l
=
««m n!
TaxDocumentService««o Å
.««Å Ç
LineDescription««Ç ë
(««ë í
products««í ö
.««ö õ
Single««õ °
(««° ¢
p««¢ £
=>««§ ¶
p««ß ®
.««® ©
Id««© ´
==««¨ Æ
x««Ø ∞
.««∞ ±
ClientProductId««± ¿
)««¿ ¡
)««¡ ¬
,««¬ √
Amount««ƒ  
=««À Ã
x««Õ Œ
.««Œ œ
Amount««œ ’
}««÷ ◊
)««◊ ÿ
.««ÿ Ÿ
ToList««Ÿ ﬂ
(««ﬂ ‡
)««‡ ·
;««· ‚
var
»» 
document
»» 
=
»» 
await
»» 
taxDocuments
»» )
.
»») *

IssueAsync
»»* 4
(
»»4 5
client
»»5 ;
.
»»; <
Id
»»< >
,
»»> ?
types
»»@ E
[
»»E F
$num
»»F G
]
»»G H
,
»»H I
request
»»J Q
.
»»Q R
	IssueDate
»»R [
,
»»[ \
currency
»»] e
,
»»e f
total
»»g l
,
»»l m
EmptyToNull
»»n y
(
»»y z
request»»z Å
.»»Å Ç
Notes»»Ç á
)»»á à
,»»à â
payment»»ä ë
.»»ë í
Id»»í î
,»»î ï
ct»»ñ ò
,»»ò ô
lines»»ö ü
)»»ü †
;»»† °
if
…… 

(
…… 
request
…… 
.
…… 
RetentionAmount
…… #
>
……$ %
$num
……& '
)
……' (
{
……) *
document
……+ 3
.
……3 4
RetentionAmount
……4 C
=
……D E
request
……F M
.
……M N
RetentionAmount
……N ]
;
……] ^
await
……_ d
db
……e g
.
……g h
SaveChangesAsync
……h x
(
……x y
ct
……y {
)
……{ |
;
……| }
}
……~ 
var
   
saved
   
=
   
await
   
db
   
.
   
TaxDocumentLines
   -
.
  - .
Where
  . 3
(
  3 4
x
  4 5
=>
  6 8
x
  9 :
.
  : ;
TaxDocumentId
  ; H
==
  I K
document
  L T
.
  T U
Id
  U W
)
  W X
.
  X Y
OrderBy
  Y `
(
  ` a
x
  a b
=>
  c e
x
  f g
.
  g h
Order
  h m
)
  m n
.
  n o
ToListAsync
  o z
(
  z {
ct
  { }
)
  } ~
;
  ~ 
return
ÀÀ 
Created
ÀÀ 
(
ÀÀ 
$"
ÀÀ 
$str
ÀÀ 2
{
ÀÀ2 3
document
ÀÀ3 ;
.
ÀÀ; <
Id
ÀÀ< >
}
ÀÀ> ?
"
ÀÀ? @
,
ÀÀ@ A
TaxDocumentDto
ÀÀB P
(
ÀÀP Q
document
ÀÀQ Y
,
ÀÀY Z
payment
ÀÀ[ b
.
ÀÀb c
Amount
ÀÀc i
>
ÀÀj k
$num
ÀÀl m
?
ÀÀn o
payment
ÀÀp w
.
ÀÀw x
	AmountPenÀÀx Å
/ÀÀÇ É
paymentÀÀÑ ã
.ÀÀã å
AmountÀÀå í
:ÀÀì î
$numÀÀï ó
,ÀÀó ò
savedÀÀô û
,ÀÀû ü
paymentÀÀ† ß
.ÀÀß ®
MethodÀÀ® Æ
)ÀÀÆ Ø
)ÀÀØ ∞
;ÀÀ∞ ±
}
ÃÃ 
[
œœ 
HttpPost
œœ 
(
œœ 
$str
œœ /
)
œœ/ 0
]
œœ0 1
public
–– 

async
–– 
Task
–– 
<
–– 
ActionResult
–– "
>
––" # 
ReverseTaxDocument
––$ 6
(
––6 7
Guid
––7 ;
id
––< >
,
––> ?'
ReverseTaxDocumentRequest
––@ Y
request
––Z a
,
––a b
CancellationToken
––c t
ct
––u w
)
––w x
{
—— 
var
““ 
reason
““ 
=
““ 
request
““ 
.
““ 
Reason
““ #
?
““# $
.
““$ %
Trim
““% )
(
““) *
)
““* +
;
““+ ,
if
”” 

(
”” 
string
”” 
.
”” 
IsNullOrEmpty
””  
(
””  !
reason
””! '
)
””' (
)
””( )
return
””* 0

BadRequest
””1 ;
(
””; <
new
””< ?
{
””@ A
message
””B I
=
””J K
$str
””L k
}
””l m
)
””m n
;
””n o
if
‘‘ 

(
‘‘ 
reason
‘‘ 
.
‘‘ 
Length
‘‘ 
>
‘‘ 
$num
‘‘ 
)
‘‘  
return
‘‘! '

BadRequest
‘‘( 2
(
‘‘2 3
new
‘‘3 6
{
‘‘7 8
message
‘‘9 @
=
‘‘A B
$str
‘‘C p
}
‘‘q r
)
‘‘r s
;
‘‘s t
return
’’ 
await
’’ 
taxDocuments
’’ !
.
’’! "
ReverseAsync
’’" .
(
’’. /
id
’’/ 1
,
’’1 2
reason
’’3 9
,
’’9 :
request
’’; B
.
’’B C
	NotIssued
’’C L
,
’’L M
UserId
’’N T
,
’’T U
ct
’’V X
)
’’X Y
is
’’Z \'
TaxDocumentReversalResult
’’] v
result
’’w }
?
’’~ 
Ok’’Ä Ç
(’’Ç É
result’’É â
)’’â ä
:’’ã å
NotFound’’ç ï
(’’ï ñ
)’’ñ ó
;’’ó ò
}
÷÷ 
[
ÿÿ 
HttpGet
ÿÿ 
(
ÿÿ 
$str
ÿÿ 
)
ÿÿ 
]
ÿÿ 
public
ŸŸ 

async
ŸŸ 
Task
ŸŸ 
<
ŸŸ 
ActionResult
ŸŸ "
>
ŸŸ" #
Expenses
ŸŸ$ ,
(
ŸŸ, -
int
ŸŸ- 0
?
ŸŸ0 1
month
ŸŸ2 7
,
ŸŸ7 8
int
ŸŸ9 <
?
ŸŸ< =
year
ŸŸ> B
,
ŸŸB C
Guid
ŸŸD H
?
ŸŸH I

categoryId
ŸŸJ T
,
ŸŸT U
CancellationToken
ŸŸV g
ct
ŸŸh j
)
ŸŸj k
=>
ŸŸl n
Ok
ŸŸo q
(
ŸŸq r
await
ŸŸr w
db
ŸŸx z
.
ŸŸz {
ExpensesŸŸ{ É
.ŸŸÉ Ñ
IncludeŸŸÑ ã
(ŸŸã å
xŸŸå ç
=>ŸŸé ê
xŸŸë í
.ŸŸí ì
CategoryŸŸì õ
)ŸŸõ ú
.
⁄⁄ 	
Where
⁄⁄	 
(
⁄⁄ 
x
⁄⁄ 
=>
⁄⁄ 
(
⁄⁄ 
month
⁄⁄ 
==
⁄⁄ 
null
⁄⁄ "
||
⁄⁄# %
x
⁄⁄& '
.
⁄⁄' (
Date
⁄⁄( ,
.
⁄⁄, -
Month
⁄⁄- 2
==
⁄⁄3 5
month
⁄⁄6 ;
)
⁄⁄; <
&&
⁄⁄= ?
(
⁄⁄@ A
year
⁄⁄A E
==
⁄⁄F H
null
⁄⁄I M
||
⁄⁄N P
x
⁄⁄Q R
.
⁄⁄R S
Date
⁄⁄S W
.
⁄⁄W X
Year
⁄⁄X \
==
⁄⁄] _
year
⁄⁄` d
)
⁄⁄d e
&&
⁄⁄f h
(
⁄⁄i j

categoryId
⁄⁄j t
==
⁄⁄u w
null
⁄⁄x |
||
⁄⁄} 
x⁄⁄Ä Å
.⁄⁄Å Ç

CategoryId⁄⁄Ç å
==⁄⁄ç è

categoryId⁄⁄ê ö
)⁄⁄ö õ
)⁄⁄õ ú
.
€€ 	
OrderByDescending
€€	 
(
€€ 
x
€€ 
=>
€€ 
x
€€  !
.
€€! "
Date
€€" &
)
€€& '
.
€€' (
Select
€€( .
(
€€. /
x
€€/ 0
=>
€€1 3

ExpenseDto
€€4 >
(
€€> ?
x
€€? @
)
€€@ A
)
€€A B
.
€€B C
ToListAsync
€€C N
(
€€N O
ct
€€O Q
)
€€Q R
)
€€R S
;
€€S T
[
›› 
HttpPost
›› 
(
›› 
$str
›› 
)
›› 
]
›› 
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
ﬁﬁ" #
CreateExpense
ﬁﬁ$ 1
(
ﬁﬁ1 2
ExpenseRequest
ﬁﬁ2 @
request
ﬁﬁA H
,
ﬁﬁH I
CancellationToken
ﬁﬁJ [
ct
ﬁﬁ\ ^
)
ﬁﬁ^ _
{
ﬂﬂ 
if
‡‡ 

(
‡‡ 
string
‡‡ 
.
‡‡  
IsNullOrWhiteSpace
‡‡ %
(
‡‡% &
request
‡‡& -
.
‡‡- .
Description
‡‡. 9
)
‡‡9 :
||
‡‡; =
string
‡‡> D
.
‡‡D E 
IsNullOrWhiteSpace
‡‡E W
(
‡‡W X
request
‡‡X _
.
‡‡_ `
Currency
‡‡` h
)
‡‡h i
||
‡‡j l
request
‡‡m t
.
‡‡t u
Amount
‡‡u {
<=
‡‡| ~
$num‡‡ Ä
)‡‡Ä Å
return‡‡Ç à

BadRequest‡‡â ì
(‡‡ì î
new‡‡î ó
{‡‡ò ô
message‡‡ö °
=‡‡¢ £
$str‡‡§ ‡
}‡‡· ‚
)‡‡‚ „
;‡‡„ ‰
if
·· 

(
·· 
!
·· 
await
·· 
db
·· 
.
·· 
ExpenseCategories
·· '
.
··' (
AnyAsync
··( 0
(
··0 1
x
··1 2
=>
··3 5
x
··6 7
.
··7 8
Id
··8 :
==
··; =
request
··> E
.
··E F

CategoryId
··F P
,
··P Q
ct
··R T
)
··T U
)
··U V
return
··W ]

BadRequest
··^ h
(
··h i
new
··i l
{
··m n
message
··o v
=
··w x
$str··y ñ
}··ó ò
)··ò ô
;··ô ö
var
‚‚ 
expense
‚‚ 
=
‚‚ 
new
‚‚ 
Expense
‚‚ !
{
‚‚" #
Description
‚‚$ /
=
‚‚0 1
request
‚‚2 9
.
‚‚9 :
Description
‚‚: E
.
‚‚E F
Trim
‚‚F J
(
‚‚J K
)
‚‚K L
,
‚‚L M

CategoryId
‚‚N X
=
‚‚Y Z
request
‚‚[ b
.
‚‚b c

CategoryId
‚‚c m
,
‚‚m n
Type
‚‚o s
=
‚‚t u
request
‚‚v }
.
‚‚} ~
Type‚‚~ Ç
,‚‚Ç É
Amount‚‚Ñ ä
=‚‚ã å
request‚‚ç î
.‚‚î ï
Amount‚‚ï õ
,‚‚õ ú
Currency‚‚ù •
=‚‚¶ ß
request‚‚® Ø
.‚‚Ø ∞
Currency‚‚∞ ∏
.‚‚∏ π
Trim‚‚π Ω
(‚‚Ω æ
)‚‚æ ø
.‚‚ø ¿ 
ToUpperInvariant‚‚¿ –
(‚‚– —
)‚‚— “
,‚‚“ ”
Date‚‚‘ ÿ
=‚‚Ÿ ⁄
request‚‚€ ‚
.‚‚‚ „
Date‚‚„ Á
,‚‚Á Ë
	Recurring‚‚È Ú
=‚‚Û Ù
request‚‚ı ¸
.‚‚¸ ˝
	Recurring‚‚˝ Ü
,‚‚Ü á
RecurrenceCycle‚‚à ó
=‚‚ò ô
request‚‚ö °
.‚‚° ¢
RecurrenceCycle‚‚¢ ±
,‚‚± ≤
IsNonDeductible‚‚≥ ¬
=‚‚√ ƒ
request‚‚≈ Ã
.‚‚Ã Õ
IsNonDeductible‚‚Õ ‹
}‚‚› ﬁ
;‚‚ﬁ ﬂ!
ApplyForeignService
„„ 
(
„„ 
expense
„„ #
,
„„# $
request
„„% ,
.
„„, -#
IsNonDomiciledService
„„- B
,
„„B C
request
„„D K
.
„„K L!
ForeignSupplierName
„„L _
,
„„_ `
request
„„a h
.
„„h i$
ForeignSupplierCountry
„„i 
)„„ Ä
;„„Ä Å
expense
‰‰ 
.
‰‰ 
	AmountPen
‰‰ 
=
‰‰ 
expense
‰‰ #
.
‰‰# $
Amount
‰‰$ *
*
‰‰+ ,
await
‰‰- 2
db
‰‰3 5
.
‰‰5 6
RateToPenAsync
‰‰6 D
(
‰‰D E
expense
‰‰E L
.
‰‰L M
Currency
‰‰M U
,
‰‰U V
expense
‰‰W ^
.
‰‰^ _
Date
‰‰_ c
,
‰‰c d
ct
‰‰e g
)
‰‰g h
;
‰‰h i
db
ÂÂ 

.
ÂÂ
 
Expenses
ÂÂ 
.
ÂÂ 
Add
ÂÂ 
(
ÂÂ 
expense
ÂÂ 
)
ÂÂ  
;
ÂÂ  !
await
ÂÂ" '
db
ÂÂ( *
.
ÂÂ* +
SaveChangesAsync
ÂÂ+ ;
(
ÂÂ; <
ct
ÂÂ< >
)
ÂÂ> ?
;
ÂÂ? @
await
ÊÊ 
db
ÊÊ 
.
ÊÊ 
Entry
ÊÊ 
(
ÊÊ 
expense
ÊÊ 
)
ÊÊ 
.
ÊÊ  
	Reference
ÊÊ  )
(
ÊÊ) *
x
ÊÊ* +
=>
ÊÊ, .
x
ÊÊ/ 0
.
ÊÊ0 1
Category
ÊÊ1 9
)
ÊÊ9 :
.
ÊÊ: ;
	LoadAsync
ÊÊ; D
(
ÊÊD E
ct
ÊÊE G
)
ÊÊG H
;
ÊÊH I
return
ÁÁ 
Created
ÁÁ 
(
ÁÁ 
$"
ÁÁ 
$str
ÁÁ -
{
ÁÁ- .
expense
ÁÁ. 5
.
ÁÁ5 6
Id
ÁÁ6 8
}
ÁÁ8 9
"
ÁÁ9 :
,
ÁÁ: ;

ExpenseDto
ÁÁ< F
(
ÁÁF G
expense
ÁÁG N
)
ÁÁN O
)
ÁÁO P
;
ÁÁP Q
}
ËË 
[
ÍÍ 
HttpGet
ÍÍ 
(
ÍÍ 
$str
ÍÍ '
)
ÍÍ' (
]
ÍÍ( )
public
ÎÎ 

async
ÎÎ 
Task
ÎÎ 
<
ÎÎ 
IActionResult
ÎÎ #
>
ÎÎ# $
ExpenseTemplate
ÎÎ% 4
(
ÎÎ4 5
CancellationToken
ÎÎ5 F
ct
ÎÎG I
)
ÎÎI J
=>
ÎÎK M
File
ÎÎN R
(
ÎÎR S
CreateWorkbook
ÎÎS a
(
ÎÎa b
new
ÏÏ 
(
ÏÏ 
$str
ÏÏ 
,
ÏÏ 
true
ÏÏ 
,
ÏÏ  
$str
ÏÏ! @
)
ÏÏ@ A
,
ÏÏA B
new
ÌÌ 
(
ÌÌ 
$str
ÌÌ 
,
ÌÌ 
true
ÌÌ 
,
ÌÌ 
$str
ÌÌ V
,
ÌÌV W
[
ÌÌX Y
..
ÌÌY [
await
ÌÌ\ a
db
ÌÌb d
.
ÌÌd e
ExpenseCategories
ÌÌe v
.
ÌÌv w
OrderBy
ÌÌw ~
(
ÌÌ~ 
xÌÌ Ä
=>ÌÌÅ É
xÌÌÑ Ö
.ÌÌÖ Ü
	SortOrderÌÌÜ è
)ÌÌè ê
.ÌÌê ë
ThenByÌÌë ó
(ÌÌó ò
xÌÌò ô
=>ÌÌö ú
xÌÌù û
.ÌÌû ü
NameÌÌü £
)ÌÌ£ §
.ÌÌ§ •
SelectÌÌ• ´
(ÌÌ´ ¨
xÌÌ¨ ≠
=>ÌÌÆ ∞
xÌÌ± ≤
.ÌÌ≤ ≥
NameÌÌ≥ ∑
)ÌÌ∑ ∏
.ÌÌ∏ π
ToListAsyncÌÌπ ƒ
(ÌÌƒ ≈
ctÌÌ≈ «
)ÌÌ« »
]ÌÌ» …
)ÌÌ…  
,ÌÌ  À
new
ÓÓ 
(
ÓÓ 
$str
ÓÓ 
,
ÓÓ 
true
ÓÓ 
,
ÓÓ 
$str
ÓÓ +
,
ÓÓ+ ,
Enum
ÓÓ- 1
.
ÓÓ1 2
GetNames
ÓÓ2 :
<
ÓÓ: ;
ExpenseType
ÓÓ; F
>
ÓÓF G
(
ÓÓG H
)
ÓÓH I
)
ÓÓI J
,
ÓÓJ K
new
ÔÔ 
(
ÔÔ 
$str
ÔÔ 
,
ÔÔ 
true
ÔÔ 
,
ÔÔ 
$str
ÔÔ K
)
ÔÔK L
,
ÔÔL M
new
 
(
 
$str
 
,
 
true
 
,
 
$str
 .
,
. /
[
0 1
$str
1 6
,
6 7
$str
8 =
,
= >
$str
? D
]
D E
)
E F
,
F G
new
ÒÒ 
(
ÒÒ 
$str
ÒÒ 
,
ÒÒ 
true
ÒÒ 
,
ÒÒ 
$str
ÒÒ K
)
ÒÒK L
,
ÒÒL M
new
ÚÚ 
(
ÚÚ 
$str
ÚÚ 
,
ÚÚ 
false
ÚÚ 
,
ÚÚ 
$str
ÚÚ  6
,
ÚÚ6 7
[
ÚÚ8 9
$str
ÚÚ9 =
,
ÚÚ= >
$str
ÚÚ? C
]
ÚÚC D
)
ÚÚD E
,
ÚÚE F
new
ÛÛ 
(
ÛÛ 
$str
ÛÛ 
,
ÛÛ 
false
ÛÛ $
,
ÛÛ$ %
$str
ÛÛ& X
,
ÛÛX Y
[
ÛÛZ [
$str
ÛÛ[ d
,
ÛÛd e
$str
ÛÛf m
]
ÛÛm n
)
ÛÛn o
)
ÛÛo p
,
ÛÛp q
$str
ÙÙ K
,
ÙÙK L
$str
ÙÙM d
)
ÙÙd e
;
ÙÙe f
[
˜˜ 
HttpPost
˜˜ 
(
˜˜ 
$str
˜˜ 
)
˜˜  
]
˜˜  !
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
ImportExpenses
¯¯$ 2
(
¯¯2 3
	IFormFile
¯¯3 <
file
¯¯= A
,
¯¯A B
CancellationToken
¯¯C T
ct
¯¯U W
)
¯¯W X
{
˘˘ 
var
˙˙ 

categories
˙˙ 
=
˙˙ 
await
˙˙ 
db
˙˙ !
.
˙˙! "
ExpenseCategories
˙˙" 3
.
˙˙3 4
ToListAsync
˙˙4 ?
(
˙˙? @
ct
˙˙@ B
)
˙˙B C
;
˙˙C D
var
˚˚ 
(
˚˚ 
failure
˚˚ 
,
˚˚ 
created
˚˚ 
,
˚˚ 
errors
˚˚ %
)
˚˚% &
=
˚˚' (
await
˚˚) .
Import
˚˚/ 5
(
˚˚5 6
file
˚˚6 :
,
˚˚: ;
$str
˚˚< D
,
˚˚D E
async
˚˚F K
(
˚˚L M
row
˚˚M P
,
˚˚P Q
	rowNumber
˚˚R [
,
˚˚[ \
errors
˚˚] c
)
˚˚c d
=>
˚˚e g
{
¸¸ 	
var
˝˝ 
error
˝˝ 
=
˝˝ 
ParseExpenseRow
˝˝ '
(
˝˝' (
row
˝˝( +
,
˝˝+ ,

categories
˝˝- 7
,
˝˝7 8
out
˝˝9 <
var
˝˝= @
expense
˝˝A H
)
˝˝H I
;
˝˝I J
if
˛˛ 
(
˛˛ 
error
˛˛ 
is
˛˛ 
not
˛˛ 
null
˛˛ !
)
˛˛! "
{
˛˛# $
errors
˛˛% +
.
˛˛+ ,
Add
˛˛, /
(
˛˛/ 0
new
˛˛0 3
(
˛˛3 4
	rowNumber
˛˛4 =
,
˛˛= >
error
˛˛? D
)
˛˛D E
)
˛˛E F
;
˛˛F G
return
˛˛H N
false
˛˛O T
;
˛˛T U
}
˛˛V W
expense
ˇˇ 
!
ˇˇ 
.
ˇˇ 
	AmountPen
ˇˇ 
=
ˇˇ  
expense
ˇˇ! (
.
ˇˇ( )
Amount
ˇˇ) /
*
ˇˇ0 1
await
ˇˇ2 7
db
ˇˇ8 :
.
ˇˇ: ;
RateToPenAsync
ˇˇ; I
(
ˇˇI J
expense
ˇˇJ Q
.
ˇˇQ R
Currency
ˇˇR Z
,
ˇˇZ [
expense
ˇˇ\ c
.
ˇˇc d
Date
ˇˇd h
,
ˇˇh i
ct
ˇˇj l
)
ˇˇl m
;
ˇˇm n
db
ÄÄ 
.
ÄÄ 
Expenses
ÄÄ 
.
ÄÄ 
Add
ÄÄ 
(
ÄÄ 
expense
ÄÄ #
)
ÄÄ# $
;
ÄÄ$ %
return
ÄÄ& ,
true
ÄÄ- 1
;
ÄÄ1 2
}
ÅÅ 	
,
ÅÅ	 

ct
ÅÅ 
)
ÅÅ 
;
ÅÅ 
return
ÇÇ 
failure
ÇÇ 
??
ÇÇ 
Ok
ÇÇ 
(
ÇÇ 
new
ÇÇ  
{
ÇÇ! "
created
ÇÇ# *
,
ÇÇ* +
skipped
ÇÇ, 3
=
ÇÇ4 5
errors
ÇÇ6 <
.
ÇÇ< =
Count
ÇÇ= B
,
ÇÇB C
errors
ÇÇD J
}
ÇÇK L
)
ÇÇL M
;
ÇÇM N
}
ÉÉ 
private
ÖÖ 
static
ÖÖ 
string
ÖÖ 
?
ÖÖ 
ParseProductRow
ÖÖ *
(
ÖÖ* +
IXLRow
ÖÖ+ 1
row
ÖÖ2 5
,
ÖÖ5 6
out
ÖÖ7 :
Product
ÖÖ; B
?
ÖÖB C
product
ÖÖD K
)
ÖÖK L
{
ÜÜ 
product
áá 
=
áá 
null
áá 
;
áá 
if
àà 

(
àà 
!
àà 
TryEnum
àà 
<
àà 
ProductType
àà  
>
àà  !
(
àà! "
Cell
àà" &
(
àà& '
row
àà' *
,
àà* +
$num
àà, -
)
àà- .
,
àà. /
out
àà0 3
var
àà4 7
type
àà8 <
)
àà< =
)
àà= >
return
àà? E
$"
ààF H
$str
ààH [
{
àà[ \
string
àà\ b
.
ààb c
Join
ààc g
(
ààg h
$str
ààh l
,
ààl m
Enum
ààn r
.
ààr s
GetNames
ààs {
<
àà{ |
ProductTypeàà| á
>ààá à
(ààà â
)ààâ ä
)ààä ã
}ààã å
$strààå ç
"ààç é
;ààé è
var
ââ 
name
ââ 
=
ââ 
Cell
ââ 
(
ââ 
row
ââ 
,
ââ 
$num
ââ 
)
ââ 
.
ââ  
Trim
ââ  $
(
ââ$ %
)
ââ% &
;
ââ& '
if
ää 

(
ää 
string
ää 
.
ää  
IsNullOrWhiteSpace
ää %
(
ää% &
name
ää& *
)
ää* +
)
ää+ ,
return
ää- 3
$str
ää4 O
;
ääO P
if
ãã 

(
ãã 
!
ãã 
TryEnum
ãã 
<
ãã 
BillingCycle
ãã !
>
ãã! "
(
ãã" #
Cell
ãã# '
(
ãã' (
row
ãã( +
,
ãã+ ,
$num
ãã- .
)
ãã. /
,
ãã/ 0
out
ãã1 4
var
ãã5 8
cycle
ãã9 >
)
ãã> ?
)
ãã? @
return
ããA G
$strããH û
;ããû ü
if
åå 

(
åå 
ReadDecimal
åå 
(
åå 
row
åå 
.
åå 
Cell
åå  
(
åå  !
$num
åå! "
)
åå" #
)
åå# $
is
åå% '
not
åå( +
decimal
åå, 3
price
åå4 9
||
åå: <
price
åå= B
<
ååC D
$num
ååE F
)
ååF G
return
ååH N
$strååO Ä
;ååÄ Å
var
çç 
currency
çç 
=
çç 
Cell
çç 
(
çç 
row
çç 
,
çç  
$num
çç! "
)
çç" #
.
çç# $
Trim
çç$ (
(
çç( )
)
çç) *
.
çç* +
ToUpperInvariant
çç+ ;
(
çç; <
)
çç< =
;
çç= >
if
éé 

(
éé 
currency
éé 
is
éé 
not
éé 
(
éé 
$str
éé "
or
éé# %
$str
éé& +
or
éé, .
$str
éé/ 4
)
éé4 5
)
éé5 6
return
éé7 =
$str
éé> d
;
ééd e
if
èè 

(
èè 
	ReadYesNo
èè 
(
èè 
Cell
èè 
(
èè 
row
èè 
,
èè 
$num
èè  !
)
èè! "
,
èè" #
defaultValue
èè$ 0
:
èè0 1
true
èè2 6
)
èè6 7
is
èè8 :
not
èè; >
bool
èè? C
active
èèD J
)
èèJ K
return
èèL R
$str
èèS t
;
èèt u
var
êê 
taxText
êê 
=
êê 
Cell
êê 
(
êê 
row
êê 
,
êê 
$num
êê  !
)
êê! "
.
êê" #
Trim
êê# '
(
êê' (
)
êê( )
;
êê) *
var
êê+ .
taxType
êê/ 6
=
êê7 8
TaxDocumentType
êê9 H
.
êêH I
Factura
êêI P
;
êêP Q
if
ëë 

(
ëë 
taxText
ëë 
!=
ëë 
$str
ëë 
&&
ëë 
!
ëë 
TryEnum
ëë %
(
ëë% &
taxText
ëë& -
,
ëë- .
out
ëë/ 2
taxType
ëë3 :
)
ëë: ;
)
ëë; <
return
ëë= C
$strëëD Ç
;ëëÇ É
if
íí 

(
íí 
	ReadYesNo
íí 
(
íí 
Cell
íí 
(
íí 
row
íí 
,
íí 
$num
íí  "
)
íí" #
,
íí# $
defaultValue
íí% 1
:
íí1 2
false
íí3 8
)
íí8 9
is
íí: <
not
íí= @
bool
ííA E
allowsTickets
ííF S
)
ííS T
return
ííU [
$stríí\ Ç
;ííÇ É
product
ìì 
=
ìì 
new
ìì 
Product
ìì 
{
ìì 
Type
ìì  $
=
ìì% &
type
ìì' +
,
ìì+ ,
Name
ìì- 1
=
ìì2 3
name
ìì4 8
,
ìì8 9
BillingCycle
ìì: F
=
ììG H
cycle
ììI N
,
ììN O
	BasePrice
ììP Y
=
ììZ [
price
ìì\ a
,
ììa b
Currency
ììc k
=
ììl m
currency
ììn v
,
ììv w
Descriptionììx É
=ììÑ Ö
EmptyToNullììÜ ë
(ììë í
Cellììí ñ
(ììñ ó
rowììó ö
,ììö õ
$numììú ù
)ììù û
)ììû ü
,ììü †
IsActiveìì° ©
=ìì™ ´
activeìì¨ ≤
,ìì≤ ≥
TaxDocumentTypeìì¥ √
=ììƒ ≈
taxTypeìì∆ Õ
,ììÕ Œ
Categoryììœ ◊
=ììÿ Ÿ
EmptyToNullìì⁄ Â
(ììÂ Ê
CellììÊ Í
(ììÍ Î
rowììÎ Ó
,ììÓ Ô
$numìì Ò
)ììÒ Ú
)ììÚ Û
,ììÛ Ù
Tagsììı ˘
=ìì˙ ˚
NormalizeTagsìì¸ â
(ììâ ä
Cellììä é
(ììé è
rowììè í
,ììí ì
$numììî ñ
)ììñ ó
)ììó ò
,ììò ô
AllowsTicketsììö ß
=ìì® ©
allowsTicketsìì™ ∑
}ìì∏ π
;ììπ ∫
return
îî 
null
îî 
;
îî 
}
ïï 
private
òò 
static
òò 
bool
òò 
TryEnum
òò 
<
òò  
T
òò  !
>
òò! "
(
òò" #
string
òò# )
value
òò* /
,
òò/ 0
out
òò1 4
T
òò5 6
result
òò7 =
)
òò= >
where
òò? D
T
òòE F
:
òòG H
struct
òòI O
,
òòO P
Enum
òòQ U
=>
òòV X
Enum
òòY ]
.
òò] ^
TryParse
òò^ f
(
òòf g
value
òòg l
.
òòl m
Trim
òòm q
(
òòq r
)
òòr s
,
òòs t
true
òòu y
,
òòy z
out
òò{ ~
resultòò Ö
)òòÖ Ü
&&òòá â
Enumòòä é
.òòé è
	IsDefinedòòè ò
(òòò ô
resultòòô ü
)òòü †
&&òò° £
!òò§ •
intòò• ®
.òò® ©
TryParseòò© ±
(òò± ≤
valueòò≤ ∑
.òò∑ ∏
Trimòò∏ º
(òòº Ω
)òòΩ æ
,òòæ ø
outòò¿ √
_òòƒ ≈
)òò≈ ∆
;òò∆ «
private
õõ 
static
õõ 
bool
õõ 
?
õõ 
	ReadYesNo
õõ "
(
õõ" #
string
õõ# )
value
õõ* /
,
õõ/ 0
bool
õõ1 5
defaultValue
õõ6 B
)
õõB C
=>
õõD F
value
õõG L
.
õõL M
Trim
õõM Q
(
õõQ R
)
õõR S
.
õõS T
ToUpperInvariant
õõT d
(
õõd e
)
õõe f
switch
õõg m
{
úú 
$str
ùù 

=>
ùù 
defaultValue
ùù 
,
ùù 
$str
ûû 
or
ûû 
$str
ûû 
or
ûû 
$str
ûû 
or
ûû !
$str
ûû" -
or
ûû. 0
$str
ûû1 4
=>
ûû5 7
true
ûû8 <
,
ûû< =
$str
üü 
or
üü 
$str
üü 
or
üü 
$str
üü "
or
üü# %
$str
üü& )
=>
üü* ,
false
üü- 2
,
üü2 3
_
†† 	
=>
††
 
null
†† 
,
†† 
}
°° 
;
°° 
private
££ 
static
££ 
string
££ 
?
££ 
ParseExpenseRow
££ *
(
££* +
IXLRow
££+ 1
row
££2 5
,
££5 6
IReadOnlyList
££7 D
<
££D E
ExpenseCategory
££E T
>
££T U

categories
££V `
,
££` a
out
££b e
Expense
££f m
?
££m n
expense
££o v
)
££v w
{
§§ 
expense
•• 
=
•• 
null
•• 
;
•• 
var
¶¶ 
description
¶¶ 
=
¶¶ 
Cell
¶¶ 
(
¶¶ 
row
¶¶ "
,
¶¶" #
$num
¶¶$ %
)
¶¶% &
.
¶¶& '
Trim
¶¶' +
(
¶¶+ ,
)
¶¶, -
;
¶¶- .
if
ßß 

(
ßß 
string
ßß 
.
ßß  
IsNullOrWhiteSpace
ßß %
(
ßß% &
description
ßß& 1
)
ßß1 2
)
ßß2 3
return
ßß4 :
$str
ßß; [
;
ßß[ \
var
©© 
categoryText
©© 
=
©© 
Fold
©© 
(
©©  
Cell
©©  $
(
©©$ %
row
©©% (
,
©©( )
$num
©©* +
)
©©+ ,
)
©©, -
;
©©- .
if
™™ 

(
™™ 

categories
™™ 
.
™™ 
FirstOrDefault
™™ %
(
™™% &
x
™™& '
=>
™™( *
Fold
™™+ /
(
™™/ 0
x
™™0 1
.
™™1 2
Name
™™2 6
)
™™6 7
==
™™8 :
categoryText
™™; G
||
™™H J
x
™™K L
.
™™L M
Code
™™M Q
is
™™R T
not
™™U X
null
™™Y ]
&&
™™^ `
Fold
™™a e
(
™™e f
x
™™f g
.
™™g h
Code
™™h l
)
™™l m
==
™™n p
categoryText
™™q }
)
™™} ~
is™™ Å
not™™Ç Ö
{™™Ü á
}™™à â
category™™ä í
)™™í ì
return™™î ö
$"™™õ ù
$str™™ù µ
{™™µ ∂
string™™∂ º
.™™º Ω
Join™™Ω ¡
(™™¡ ¬
$str™™¬ ∆
,™™∆ «

categories™™» “
.™™“ ”
OrderBy™™” ⁄
(™™⁄ €
x™™€ ‹
=>™™› ﬂ
x™™‡ ·
.™™· ‚
	SortOrder™™‚ Î
)™™Î Ï
.™™Ï Ì
Select™™Ì Û
(™™Û Ù
x™™Ù ı
=>™™ˆ ¯
x™™˘ ˙
.™™˙ ˚
Name™™˚ ˇ
)™™ˇ Ä
)™™Ä Å
}™™Å Ç
$str™™Ç É
"™™É Ñ
;™™Ñ Ö
if
´´ 

(
´´ 
!
´´ 
TryEnum
´´ 
<
´´ 
ExpenseType
´´  
>
´´  !
(
´´! "
Cell
´´" &
(
´´& '
row
´´' *
,
´´* +
$num
´´, -
)
´´- .
,
´´. /
out
´´0 3
var
´´4 7
type
´´8 <
)
´´< =
)
´´= >
return
´´? E
$str
´´F k
;
´´k l
if
¨¨ 

(
¨¨ 
ReadDecimal
¨¨ 
(
¨¨ 
row
¨¨ 
.
¨¨ 
Cell
¨¨  
(
¨¨  !
$num
¨¨! "
)
¨¨" #
)
¨¨# $
is
¨¨% '
not
¨¨( +
decimal
¨¨, 3
amount
¨¨4 :
||
¨¨; =
amount
¨¨> D
<=
¨¨E G
$num
¨¨H I
)
¨¨I J
return
¨¨K Q
$str
¨¨R z
;
¨¨z {
var
≠≠ 
currency
≠≠ 
=
≠≠ 
Cell
≠≠ 
(
≠≠ 
row
≠≠ 
,
≠≠  
$num
≠≠! "
)
≠≠" #
.
≠≠# $
Trim
≠≠$ (
(
≠≠( )
)
≠≠) *
.
≠≠* +
ToUpperInvariant
≠≠+ ;
(
≠≠; <
)
≠≠< =
;
≠≠= >
if
ÆÆ 

(
ÆÆ 
currency
ÆÆ 
is
ÆÆ 
not
ÆÆ 
(
ÆÆ 
$str
ÆÆ "
or
ÆÆ# %
$str
ÆÆ& +
or
ÆÆ, .
$str
ÆÆ/ 4
)
ÆÆ4 5
)
ÆÆ5 6
return
ÆÆ7 =
$str
ÆÆ> d
;
ÆÆd e
if
ØØ 

(
ØØ 
ReadDate
ØØ 
(
ØØ 
row
ØØ 
.
ØØ 
Cell
ØØ 
(
ØØ 
$num
ØØ 
)
ØØ  
)
ØØ  !
is
ØØ" $
not
ØØ% (
DateOnly
ØØ) 1
date
ØØ2 6
)
ØØ6 7
return
ØØ8 >
$str
ØØ? m
;
ØØm n
if
∞∞ 

(
∞∞ 
	ReadYesNo
∞∞ 
(
∞∞ 
Cell
∞∞ 
(
∞∞ 
row
∞∞ 
,
∞∞ 
$num
∞∞  !
)
∞∞! "
,
∞∞" #
defaultValue
∞∞$ 0
:
∞∞0 1
false
∞∞2 7
)
∞∞7 8
is
∞∞9 ;
not
∞∞< ?
bool
∞∞@ D
	recurring
∞∞E N
)
∞∞N O
return
∞∞P V
$str
∞∞W y
;
∞∞y z
BillingCycle
±± 
?
±± 
cycle
±± 
=
±± 
null
±± "
;
±±" #
if
≤≤ 

(
≤≤ 
	recurring
≤≤ 
)
≤≤ 
{
≥≥ 	
if
¥¥ 
(
¥¥ 
!
¥¥ 
TryEnum
¥¥ 
<
¥¥ 
BillingCycle
¥¥ %
>
¥¥% &
(
¥¥& '
Cell
¥¥' +
(
¥¥+ ,
row
¥¥, /
,
¥¥/ 0
$num
¥¥1 2
)
¥¥2 3
,
¥¥3 4
out
¥¥5 8
var
¥¥9 <
parsed
¥¥= C
)
¥¥C D
||
¥¥E G
parsed
¥¥H N
is
¥¥O Q
not
¥¥R U
(
¥¥V W
BillingCycle
¥¥W c
.
¥¥c d
Mensual
¥¥d k
or
¥¥l n
BillingCycle
¥¥o {
.
¥¥{ |
Anual¥¥| Å
)¥¥Å Ç
)¥¥Ç É
return¥¥Ñ ä
$str¥¥ã À
;¥¥À Ã
cycle
µµ 
=
µµ 
parsed
µµ 
;
µµ 
}
∂∂ 	
expense
∑∑ 
=
∑∑ 
new
∑∑ 
Expense
∑∑ 
{
∑∑ 
Description
∑∑  +
=
∑∑, -
description
∑∑. 9
,
∑∑9 :

CategoryId
∑∑; E
=
∑∑F G
category
∑∑H P
.
∑∑P Q
Id
∑∑Q S
,
∑∑S T
Type
∑∑U Y
=
∑∑Z [
type
∑∑\ `
,
∑∑` a
Amount
∑∑b h
=
∑∑i j
amount
∑∑k q
,
∑∑q r
Currency
∑∑s {
=
∑∑| }
currency∑∑~ Ü
,∑∑Ü á
Date∑∑à å
=∑∑ç é
date∑∑è ì
,∑∑ì î
	Recurring∑∑ï û
=∑∑ü †
	recurring∑∑° ™
,∑∑™ ´
RecurrenceCycle∑∑¨ ª
=∑∑º Ω
cycle∑∑æ √
}∑∑ƒ ≈
;∑∑≈ ∆
return
∏∏ 
null
∏∏ 
;
∏∏ 
}
ππ 
private
ºº 
static
ºº 
decimal
ºº 
?
ºº 
ReadDecimal
ºº '
(
ºº' (
IXLCell
ºº( /
cell
ºº0 4
)
ºº4 5
=>
ºº6 8
cell
ΩΩ 
.
ΩΩ 
DataType
ΩΩ 
==
ΩΩ 

XLDataType
ΩΩ #
.
ΩΩ# $
Number
ΩΩ$ *
?
ΩΩ+ ,
(
ΩΩ- .
decimal
ΩΩ. 5
)
ΩΩ5 6
cell
ΩΩ6 :
.
ΩΩ: ;
	GetDouble
ΩΩ; D
(
ΩΩD E
)
ΩΩE F
:
ææ 	
decimal
ææ
 
.
ææ 
TryParse
ææ 
(
ææ 
cell
ææ 
.
ææ  
	GetString
ææ  )
(
ææ) *
)
ææ* +
.
ææ+ ,
Trim
ææ, 0
(
ææ0 1
)
ææ1 2
,
ææ2 3
System
ææ4 :
.
ææ: ;
Globalization
ææ; H
.
ææH I
NumberStyles
ææI U
.
ææU V
Number
ææV \
,
ææ\ ]
System
ææ^ d
.
ææd e
Globalization
ææe r
.
æær s
CultureInfo
ææs ~
.
ææ~ 
InvariantCultureææ è
,ææè ê
outææë î
varææï ò
valueææô û
)ææû ü
?ææ† °
valueææ¢ ß
:ææ® ©
nullææ™ Æ
;ææÆ Ø
private
¿¿ 
static
¿¿ 
DateOnly
¿¿ 
?
¿¿ 
ReadDate
¿¿ %
(
¿¿% &
IXLCell
¿¿& -
cell
¿¿. 2
)
¿¿2 3
=>
¿¿4 6
cell
¡¡ 
.
¡¡ 
DataType
¡¡ 
==
¡¡ 

XLDataType
¡¡ #
.
¡¡# $
DateTime
¡¡$ ,
?
¡¡- .
DateOnly
¡¡/ 7
.
¡¡7 8
FromDateTime
¡¡8 D
(
¡¡D E
cell
¡¡E I
.
¡¡I J
GetDateTime
¡¡J U
(
¡¡U V
)
¡¡V W
)
¡¡W X
:
¬¬ 	
DateOnly
¬¬
 
.
¬¬ 
TryParseExact
¬¬  
(
¬¬  !
cell
¬¬! %
.
¬¬% &
	GetString
¬¬& /
(
¬¬/ 0
)
¬¬0 1
.
¬¬1 2
Trim
¬¬2 6
(
¬¬6 7
)
¬¬7 8
,
¬¬8 9
[
¬¬: ;
$str
¬¬; G
,
¬¬G H
$str
¬¬I U
,
¬¬U V
$str
¬¬W a
]
¬¬a b
,
¬¬b c
System
¬¬d j
.
¬¬j k
Globalization
¬¬k x
.
¬¬x y
CultureInfo¬¬y Ñ
.¬¬Ñ Ö 
InvariantCulture¬¬Ö ï
,¬¬ï ñ
System¬¬ó ù
.¬¬ù û
Globalization¬¬û ´
.¬¬´ ¨
DateTimeStyles¬¬¨ ∫
.¬¬∫ ª
None¬¬ª ø
,¬¬ø ¿
out¬¬¡ ƒ
var¬¬≈ »
date¬¬… Õ
)¬¬Õ Œ
?¬¬œ –
date¬¬— ’
:¬¬÷ ◊
null¬¬ÿ ‹
;¬¬‹ ›
[
ƒƒ 

HttpDelete
ƒƒ 
(
ƒƒ 
$str
ƒƒ $
)
ƒƒ$ %
]
ƒƒ% &
public
≈≈ 

async
≈≈ 
Task
≈≈ 
<
≈≈ 
ActionResult
≈≈ "
>
≈≈" #
DeleteExpense
≈≈$ 1
(
≈≈1 2
Guid
≈≈2 6
id
≈≈7 9
,
≈≈9 :
CancellationToken
≈≈; L
ct
≈≈M O
)
≈≈O P
{
∆∆ 
var
«« 
expense
«« 
=
«« 
await
«« 
db
«« 
.
«« 
Expenses
«« '
.
««' (
	FindAsync
««( 1
(
««1 2
[
««2 3
id
««3 5
]
««5 6
,
««6 7
ct
««8 :
)
««: ;
;
««; <
if
««= ?
(
««@ A
expense
««A H
is
««I K
null
««L P
)
««P Q
return
««R X
NotFound
««Y a
(
««a b
)
««b c
;
««c d
db
»» 

.
»»
 
Expenses
»» 
.
»» 
Remove
»» 
(
»» 
expense
»» "
)
»»" #
;
»»# $
await
»»% *
db
»»+ -
.
»»- .
SaveChangesAsync
»». >
(
»»> ?
ct
»»? A
)
»»A B
;
»»B C
return
»»D J
	NoContent
»»K T
(
»»T U
)
»»U V
;
»»V W
}
…… 
[
–– 
HttpPost
–– 
(
–– 
$str
–– 1
)
––1 2
]
––2 3
public
—— 

async
—— 
Task
—— 
<
—— 
ActionResult
—— "
>
——" #
EndRecurrence
——$ 1
(
——1 2
Guid
——2 6
id
——7 9
,
——9 :"
EndRecurrenceRequest
——; O
request
——P W
,
——W X
bool
——Y ]
dryRun
——^ d
,
——d e
CancellationToken
——f w
ct
——x z
)
——z {
{
““ 
var
”” 
expense
”” 
=
”” 
await
”” 
db
”” 
.
”” 
Expenses
”” '
.
””' (
	FindAsync
””( 1
(
””1 2
[
””2 3
id
””3 5
]
””5 6
,
””6 7
ct
””8 :
)
””: ;
;
””; <
if
””= ?
(
””@ A
expense
””A H
is
””I K
null
””L P
)
””P Q
return
””R X
NotFound
””Y a
(
””a b
)
””b c
;
””c d
if
‘‘ 

(
‘‘ 
!
‘‘ 
expense
‘‘ 
.
‘‘ 
	Recurring
‘‘ 
)
‘‘ 
return
‘‘  &

BadRequest
‘‘' 1
(
‘‘1 2
new
‘‘2 5
{
‘‘6 7
message
‘‘8 ?
=
‘‘@ A
$str
‘‘B ^
}
‘‘_ `
)
‘‘` a
;
‘‘a b
var
’’ 
series
’’ 
=
’’ 
await
’’ 
ExpenseSeries
’’ (
(
’’( )
expense
’’) 0
)
’’0 1
.
’’1 2
ToListAsync
’’2 =
(
’’= >
ct
’’> @
)
’’@ A
;
’’A B
var
÷÷ 
removed
÷÷ 
=
÷÷ 
series
÷÷ 
.
÷÷ 
Where
÷÷ "
(
÷÷" #
x
÷÷# $
=>
÷÷% '
x
÷÷( )
.
÷÷) *
Date
÷÷* .
>
÷÷/ 0
request
÷÷1 8
.
÷÷8 9
EndsAt
÷÷9 ?
)
÷÷? @
.
÷÷@ A
ToList
÷÷A G
(
÷÷G H
)
÷÷H I
;
÷÷I J
if
◊◊ 

(
◊◊ 
!
◊◊ 
dryRun
◊◊ 
)
◊◊ 
{
ÿÿ 	
db
ŸŸ 
.
ŸŸ 
Expenses
ŸŸ 
.
ŸŸ 
RemoveRange
ŸŸ #
(
ŸŸ# $
removed
ŸŸ$ +
)
ŸŸ+ ,
;
ŸŸ, -
foreach
⁄⁄ 
(
⁄⁄ 
var
⁄⁄ 
kept
⁄⁄ 
in
⁄⁄  
series
⁄⁄! '
.
⁄⁄' (
Except
⁄⁄( .
(
⁄⁄. /
removed
⁄⁄/ 6
)
⁄⁄6 7
)
⁄⁄7 8
kept
⁄⁄9 =
.
⁄⁄= >
RecurrenceEndsAt
⁄⁄> N
=
⁄⁄O P
request
⁄⁄Q X
.
⁄⁄X Y
EndsAt
⁄⁄Y _
;
⁄⁄_ `
await
€€ 
db
€€ 
.
€€ 
SaveChangesAsync
€€ %
(
€€% &
ct
€€& (
)
€€( )
;
€€) *
}
‹‹ 	
return
›› 
Ok
›› 
(
›› 
new
›› 
{
›› 
removed
›› 
=
››  !
removed
››" )
.
››) *
Count
››* /
,
››/ 0
kept
››1 5
=
››6 7
series
››8 >
.
››> ?
Count
››? D
-
››E F
removed
››G N
.
››N O
Count
››O T
,
››T U
removedTotalPen
››V e
=
››f g
Math
››h l
.
››l m
Round
››m r
(
››r s
removed
››s z
.
››z {
Sum
››{ ~
(
››~ 
x›› Ä
=>››Å É
x››Ñ Ö
.››Ö Ü
	AmountPen››Ü è
)››è ê
,››ê ë
$num››í ì
)››ì î
}››ï ñ
)››ñ ó
;››ó ò
}
ﬁﬁ 
[
·· 

HttpDelete
·· 
(
·· 
$str
·· 3
)
··3 4
]
··4 5
public
‚‚ 

async
‚‚ 
Task
‚‚ 
<
‚‚ 
ActionResult
‚‚ "
>
‚‚" #
ResumeRecurrence
‚‚$ 4
(
‚‚4 5
Guid
‚‚5 9
id
‚‚: <
,
‚‚< =
CancellationToken
‚‚> O
ct
‚‚P R
)
‚‚R S
{
„„ 
var
‰‰ 
expense
‰‰ 
=
‰‰ 
await
‰‰ 
db
‰‰ 
.
‰‰ 
Expenses
‰‰ '
.
‰‰' (
	FindAsync
‰‰( 1
(
‰‰1 2
[
‰‰2 3
id
‰‰3 5
]
‰‰5 6
,
‰‰6 7
ct
‰‰8 :
)
‰‰: ;
;
‰‰; <
if
‰‰= ?
(
‰‰@ A
expense
‰‰A H
is
‰‰I K
null
‰‰L P
)
‰‰P Q
return
‰‰R X
NotFound
‰‰Y a
(
‰‰a b
)
‰‰b c
;
‰‰c d
foreach
ÂÂ 
(
ÂÂ 
var
ÂÂ 
x
ÂÂ 
in
ÂÂ 
await
ÂÂ 
ExpenseSeries
ÂÂ  -
(
ÂÂ- .
expense
ÂÂ. 5
)
ÂÂ5 6
.
ÂÂ6 7
ToListAsync
ÂÂ7 B
(
ÂÂB C
ct
ÂÂC E
)
ÂÂE F
)
ÂÂF G
x
ÂÂH I
.
ÂÂI J
RecurrenceEndsAt
ÂÂJ Z
=
ÂÂ[ \
null
ÂÂ] a
;
ÂÂa b
await
ÊÊ 
db
ÊÊ 
.
ÊÊ 
SaveChangesAsync
ÊÊ !
(
ÊÊ! "
ct
ÊÊ" $
)
ÊÊ$ %
;
ÊÊ% &
return
ÊÊ' -
	NoContent
ÊÊ. 7
(
ÊÊ7 8
)
ÊÊ8 9
;
ÊÊ9 :
}
ÁÁ 
private
ÈÈ 

IQueryable
ÈÈ 
<
ÈÈ 
Expense
ÈÈ 
>
ÈÈ 
ExpenseSeries
ÈÈ  -
(
ÈÈ- .
Expense
ÈÈ. 5
expense
ÈÈ6 =
)
ÈÈ= >
{
ÍÍ 
var
ÎÎ 
description
ÎÎ 
=
ÎÎ 
expense
ÎÎ !
.
ÎÎ! "
Description
ÎÎ" -
.
ÎÎ- .
Trim
ÎÎ. 2
(
ÎÎ2 3
)
ÎÎ3 4
;
ÎÎ4 5
return
ÏÏ 
db
ÏÏ 
.
ÏÏ 
Expenses
ÏÏ 
.
ÏÏ 
Where
ÏÏ  
(
ÏÏ  !
x
ÏÏ! "
=>
ÏÏ# %
x
ÏÏ& '
.
ÏÏ' (
	Recurring
ÏÏ( 1
&&
ÏÏ2 4
x
ÏÏ5 6
.
ÏÏ6 7
Description
ÏÏ7 B
.
ÏÏB C
Trim
ÏÏC G
(
ÏÏG H
)
ÏÏH I
==
ÏÏJ L
description
ÏÏM X
&&
ÏÏY [
x
ÏÏ\ ]
.
ÏÏ] ^

CategoryId
ÏÏ^ h
==
ÏÏi k
expense
ÏÏl s
.
ÏÏs t

CategoryId
ÏÏt ~
&&ÏÏ Å
xÏÏÇ É
.ÏÏÉ Ñ
CurrencyÏÏÑ å
==ÏÏç è
expenseÏÏê ó
.ÏÏó ò
CurrencyÏÏò †
)ÏÏ† °
;ÏÏ° ¢
}
ÌÌ 
[
ÔÔ 
	HttpPatch
ÔÔ 
(
ÔÔ 
$str
ÔÔ #
)
ÔÔ# $
]
ÔÔ$ %
public
 

async
 
Task
 
<
 
ActionResult
 "
>
" #
UpdateExpense
$ 1
(
1 2
Guid
2 6
id
7 9
,
9 :!
ExpensePatchRequest
; N
request
O V
,
V W
CancellationToken
X i
ct
j l
)
l m
{
ÒÒ 
var
ÚÚ 
expense
ÚÚ 
=
ÚÚ 
await
ÚÚ 
db
ÚÚ 
.
ÚÚ 
Expenses
ÚÚ '
.
ÚÚ' (
	FindAsync
ÚÚ( 1
(
ÚÚ1 2
[
ÚÚ2 3
id
ÚÚ3 5
]
ÚÚ5 6
,
ÚÚ6 7
ct
ÚÚ8 :
)
ÚÚ: ;
;
ÚÚ; <
if
ÚÚ= ?
(
ÚÚ@ A
expense
ÚÚA H
is
ÚÚI K
null
ÚÚL P
)
ÚÚP Q
return
ÚÚR X
NotFound
ÚÚY a
(
ÚÚa b
)
ÚÚb c
;
ÚÚc d
if
ÛÛ 

(
ÛÛ 
request
ÛÛ 
.
ÛÛ 
Description
ÛÛ 
is
ÛÛ  "
not
ÛÛ# &
null
ÛÛ' +
)
ÛÛ+ ,
expense
ÛÛ- 4
.
ÛÛ4 5
Description
ÛÛ5 @
=
ÛÛA B
request
ÛÛC J
.
ÛÛJ K
Description
ÛÛK V
.
ÛÛV W
Trim
ÛÛW [
(
ÛÛ[ \
)
ÛÛ\ ]
;
ÛÛ] ^
if
ÙÙ 

(
ÙÙ 
request
ÙÙ 
.
ÙÙ 

CategoryId
ÙÙ 
is
ÙÙ !
Guid
ÙÙ" &

categoryId
ÙÙ' 1
)
ÙÙ1 2
{
ıı 	
if
ˆˆ 
(
ˆˆ 
!
ˆˆ 
await
ˆˆ 
db
ˆˆ 
.
ˆˆ 
ExpenseCategories
ˆˆ +
.
ˆˆ+ ,
AnyAsync
ˆˆ, 4
(
ˆˆ4 5
x
ˆˆ5 6
=>
ˆˆ7 9
x
ˆˆ: ;
.
ˆˆ; <
Id
ˆˆ< >
==
ˆˆ? A

categoryId
ˆˆB L
,
ˆˆL M
ct
ˆˆN P
)
ˆˆP Q
)
ˆˆQ R
return
ˆˆS Y

BadRequest
ˆˆZ d
(
ˆˆd e
new
ˆˆe h
{
ˆˆi j
message
ˆˆk r
=
ˆˆs t
$strˆˆu í
}ˆˆì î
)ˆˆî ï
;ˆˆï ñ
expense
˜˜ 
.
˜˜ 

CategoryId
˜˜ 
=
˜˜  

categoryId
˜˜! +
;
˜˜+ ,
}
¯¯ 	
if
˘˘ 

(
˘˘ 
request
˘˘ 
.
˘˘ 
Type
˘˘ 
is
˘˘ 
ExpenseType
˘˘ '
type
˘˘( ,
)
˘˘, -
expense
˘˘. 5
.
˘˘5 6
Type
˘˘6 :
=
˘˘; <
type
˘˘= A
;
˘˘A B
if
˙˙ 

(
˙˙ 
request
˙˙ 
.
˙˙ 
Amount
˙˙ 
is
˙˙ 
decimal
˙˙ %
amount
˙˙& ,
)
˙˙, -
expense
˙˙. 5
.
˙˙5 6
Amount
˙˙6 <
=
˙˙= >
amount
˙˙? E
;
˙˙E F
if
˚˚ 

(
˚˚ 
request
˚˚ 
.
˚˚ 
Currency
˚˚ 
is
˚˚ 
not
˚˚  #
null
˚˚$ (
)
˚˚( )
expense
˚˚* 1
.
˚˚1 2
Currency
˚˚2 :
=
˚˚; <
request
˚˚= D
.
˚˚D E
Currency
˚˚E M
.
˚˚M N
Trim
˚˚N R
(
˚˚R S
)
˚˚S T
.
˚˚T U
ToUpperInvariant
˚˚U e
(
˚˚e f
)
˚˚f g
;
˚˚g h
if
¸¸ 

(
¸¸ 
request
¸¸ 
.
¸¸ 
Date
¸¸ 
is
¸¸ 
DateOnly
¸¸ $
date
¸¸% )
)
¸¸) *
expense
¸¸+ 2
.
¸¸2 3
Date
¸¸3 7
=
¸¸8 9
date
¸¸: >
;
¸¸> ?
if
˝˝ 

(
˝˝ 
request
˝˝ 
.
˝˝ 
	Recurring
˝˝ 
is
˝˝  
bool
˝˝! %
	recurring
˝˝& /
)
˝˝/ 0
expense
˝˝1 8
.
˝˝8 9
	Recurring
˝˝9 B
=
˝˝C D
	recurring
˝˝E N
;
˝˝N O
if
˛˛ 

(
˛˛ 
request
˛˛ 
.
˛˛ 
RecurrenceCycle
˛˛ #
is
˛˛$ &
BillingCycle
˛˛' 3
cycle
˛˛4 9
)
˛˛9 :
expense
˛˛; B
.
˛˛B C
RecurrenceCycle
˛˛C R
=
˛˛S T
cycle
˛˛U Z
;
˛˛Z [
if
ˇˇ 

(
ˇˇ 
request
ˇˇ 
.
ˇˇ 
IsNonDeductible
ˇˇ #
is
ˇˇ$ &
bool
ˇˇ' +
nonDeductible
ˇˇ, 9
)
ˇˇ9 :
expense
ˇˇ; B
.
ˇˇB C
IsNonDeductible
ˇˇC R
=
ˇˇS T
nonDeductible
ˇˇU b
;
ˇˇb c
if
ÄÄ 

(
ÄÄ 
request
ÄÄ 
.
ÄÄ #
IsNonDomiciledService
ÄÄ )
is
ÄÄ* ,
bool
ÄÄ- 1
foreign
ÄÄ2 9
)
ÄÄ9 :!
ApplyForeignService
ÄÄ; N
(
ÄÄN O
expense
ÄÄO V
,
ÄÄV W
foreign
ÄÄX _
,
ÄÄ_ `
request
ÄÄa h
.
ÄÄh i!
ForeignSupplierName
ÄÄi |
,
ÄÄ| }
requestÄÄ~ Ö
.ÄÄÖ Ü&
ForeignSupplierCountryÄÄÜ ú
)ÄÄú ù
;ÄÄù û
if
ÅÅ 

(
ÅÅ 
string
ÅÅ 
.
ÅÅ  
IsNullOrWhiteSpace
ÅÅ %
(
ÅÅ% &
expense
ÅÅ& -
.
ÅÅ- .
Description
ÅÅ. 9
)
ÅÅ9 :
||
ÅÅ; =
string
ÅÅ> D
.
ÅÅD E 
IsNullOrWhiteSpace
ÅÅE W
(
ÅÅW X
expense
ÅÅX _
.
ÅÅ_ `
Currency
ÅÅ` h
)
ÅÅh i
||
ÅÅj l
expense
ÅÅm t
.
ÅÅt u
Amount
ÅÅu {
<=
ÅÅ| ~
$numÅÅ Ä
)ÅÅÄ Å
returnÅÅÇ à

BadRequestÅÅâ ì
(ÅÅì î
newÅÅî ó
{ÅÅò ô
messageÅÅö °
=ÅÅ¢ £
$strÅÅ§ ‡
}ÅÅ· ‚
)ÅÅ‚ „
;ÅÅ„ ‰
expense
ÇÇ 
.
ÇÇ 
	AmountPen
ÇÇ 
=
ÇÇ 
expense
ÇÇ #
.
ÇÇ# $
Amount
ÇÇ$ *
*
ÇÇ+ ,
await
ÇÇ- 2
db
ÇÇ3 5
.
ÇÇ5 6
RateToPenAsync
ÇÇ6 D
(
ÇÇD E
expense
ÇÇE L
.
ÇÇL M
Currency
ÇÇM U
,
ÇÇU V
expense
ÇÇW ^
.
ÇÇ^ _
Date
ÇÇ_ c
,
ÇÇc d
ct
ÇÇe g
)
ÇÇg h
;
ÇÇh i
await
ÉÉ 
db
ÉÉ 
.
ÉÉ 
SaveChangesAsync
ÉÉ !
(
ÉÉ! "
ct
ÉÉ" $
)
ÉÉ$ %
;
ÉÉ% &
await
ÉÉ' ,
db
ÉÉ- /
.
ÉÉ/ 0
Entry
ÉÉ0 5
(
ÉÉ5 6
expense
ÉÉ6 =
)
ÉÉ= >
.
ÉÉ> ?
	Reference
ÉÉ? H
(
ÉÉH I
x
ÉÉI J
=>
ÉÉK M
x
ÉÉN O
.
ÉÉO P
Category
ÉÉP X
)
ÉÉX Y
.
ÉÉY Z
	LoadAsync
ÉÉZ c
(
ÉÉc d
ct
ÉÉd f
)
ÉÉf g
;
ÉÉg h
return
ÉÉi o
Ok
ÉÉp r
(
ÉÉr s

ExpenseDto
ÉÉs }
(
ÉÉ} ~
expenseÉÉ~ Ö
)ÉÉÖ Ü
)ÉÉÜ á
;ÉÉá à
}
ÑÑ 
private
ÜÜ 
const
ÜÜ 
string
ÜÜ 
TaxDisclaimer
ÜÜ &
=
ÜÜ' (
$strÜÜ) ÿ
;ÜÜÿ Ÿ
private
ââ 
static
ââ 
(
ââ 
DateOnly
ââ 
From
ââ !
,
ââ! "
DateOnly
ââ# +
To
ââ, .
)
ââ. /
Period
ââ0 6
(
ââ6 7
int
ââ7 :
?
ââ: ;
month
ââ< A
,
ââA B
int
ââC F
year
ââG K
)
ââK L
=>
ââM O
month
ää 
is
ää 
int
ää 
m
ää 
?
ää 
(
ää 
new
ää 
DateOnly
ää &
(
ää& '
year
ää' +
,
ää+ ,
m
ää- .
,
ää. /
$num
ää0 1
)
ää1 2
,
ää2 3
new
ää4 7
DateOnly
ää8 @
(
ää@ A
year
ääA E
,
ääE F
m
ääG H
,
ääH I
$num
ääJ K
)
ääK L
.
ääL M
	AddMonths
ääM V
(
ääV W
$num
ääW X
)
ääX Y
.
ääY Z
AddDays
ääZ a
(
ääa b
-
ääb c
$num
ääc d
)
ääd e
)
ääe f
:
ääg h
(
ääi j
new
ääj m
DateOnly
ään v
(
ääv w
year
ääw {
,
ää{ |
$num
ää} ~
,
ää~ 
$numääÄ Å
)ääÅ Ç
,ääÇ É
newääÑ á
DateOnlyääà ê
(ääê ë
yearääë ï
,ääï ñ
$numääó ô
,ääô ö
$numääõ ù
)ääù û
)ääû ü
;ääü †
private
çç 
static
çç 
(
çç 
DateOnly
çç 
From
çç !
,
çç! "
DateOnly
çç# +
To
çç, .
)
çç. /
PreviousPeriod
çç0 >
(
çç> ?
int
çç? B
?
ççB C
month
ççD I
,
ççI J
int
ççK N
year
ççO S
)
ççS T
=>
ççU W
month
éé 
is
éé 
int
éé 
m
éé 
?
éé 
Period
éé 
(
éé  
m
éé  !
==
éé" $
$num
éé% &
?
éé' (
$num
éé) +
:
éé, -
m
éé. /
-
éé0 1
$num
éé2 3
,
éé3 4
m
éé5 6
==
éé7 9
$num
éé: ;
?
éé< =
year
éé> B
-
ééC D
$num
ééE F
:
ééG H
year
ééI M
)
ééM N
:
ééO P
Period
ééQ W
(
ééW X
null
ééX \
,
éé\ ]
year
éé^ b
-
ééc d
$num
éée f
)
ééf g
;
éég h
private
îî 
sealed
îî 
record
îî 
Sale
îî 
(
îî 
Guid
îî #
ClientId
îî$ ,
,
îî, -
DateOnly
îî. 6
Date
îî7 ;
,
îî; <
decimal
îî= D
BasePen
îîE L
,
îîL M
decimal
îîN U
IgvPen
îîV \
,
îî\ ]
bool
îî^ b
Gravada
îîc j
,
îîj k
decimal
îîl s
RetentionPenîît Ä
,îîÄ Å
boolîîÇ Ü
PersonaNaturalîîá ï
=îîñ ó
falseîîò ù
)îîù û
{
ïï 
public
ññ 
bool
ññ 
Mype
ññ 
=>
ññ 
!
ññ 
PersonaNatural
ññ +
;
ññ+ ,
}
óó 
private
ûû 
async
ûû 
Task
ûû 
<
ûû 
List
ûû 
<
ûû 
Sale
ûû  
>
ûû  !
>
ûû! "

SalesAsync
ûû# -
(
ûû- .
DateOnly
ûû. 6
from
ûû7 ;
,
ûû; <
DateOnly
ûû= E
to
ûûF H
,
ûûH I
CancellationToken
ûûJ [
ct
ûû\ ^
)
ûû^ _
{
üü 
var
†† 
start
†† 
=
†† 
from
†† 
.
†† 

ToDateTime
†† #
(
††# $
TimeOnly
††$ ,
.
††, -
MinValue
††- 5
)
††5 6
;
††6 7
var
††8 ;
end
††< ?
=
††@ A
to
††B D
.
††D E
AddDays
††E L
(
††L M
$num
††M N
)
††N O
.
††O P

ToDateTime
††P Z
(
††Z [
TimeOnly
††[ c
.
††c d
MinValue
††d l
)
††l m
;
††m n
var
°° 
payments
°° 
=
°° 
await
°° 
db
°° 
.
°°  !
PaymentTransactions
°°  3
.
°°3 4
Where
°°4 9
(
°°9 :
x
°°: ;
=>
°°< >
x
°°? @
.
°°@ A
	CreatedAt
°°A J
>=
°°K M
start
°°N S
&&
°°T V
x
°°W X
.
°°X Y
	CreatedAt
°°Y b
<
°°c d
end
°°e h
)
°°h i
.
¢¢ 
Select
¢¢ 
(
¢¢ 
x
¢¢ 
=>
¢¢ 
new
¢¢ 
{
¢¢ 
x
¢¢  
.
¢¢  !
ClientId
¢¢! )
,
¢¢) *
x
¢¢+ ,
.
¢¢, -
	CreatedAt
¢¢- 6
,
¢¢6 7
x
¢¢8 9
.
¢¢9 :
	AmountPen
¢¢: C
,
¢¢C D
Document
¢¢E M
=
¢¢N O
db
¢¢P R
.
¢¢R S
TaxDocuments
¢¢S _
.
¢¢_ `
FirstOrDefault
¢¢` n
(
¢¢n o
d
¢¢o p
=>
¢¢q s
d
¢¢t u
.
¢¢u v#
PaymentTransactionId¢¢v ä
==¢¢ã ç
x¢¢é è
.¢¢è ê
Id¢¢ê í
)¢¢í ì
}¢¢î ï
)¢¢ï ñ
.¢¢ñ ó
ToListAsync¢¢ó ¢
(¢¢¢ £
ct¢¢£ •
)¢¢• ¶
;¢¢¶ ß
return
££ 
payments
££ 
.
££ 
Select
££ 
(
££ 
x
££  
=>
££! #
{
§§ 	
var
•• 
document
•• 
=
•• 
x
•• 
.
•• 
Document
•• %
is
••& (
{
••) *
TotalAmount
••+ 6
:
••6 7
>
••8 9
$num
••: ;
}
••< =
d
••> ?
?
••@ A
d
••B C
:
••D E
null
••F J
;
••J K
var
¶¶ 
	isFactura
¶¶ 
=
¶¶ 
document
¶¶ $
?
¶¶$ %
.
¶¶% &
Type
¶¶& *
==
¶¶+ -
TaxDocumentType
¶¶. =
.
¶¶= >
Factura
¶¶> E
;
¶¶E F
var
ßß 
basePen
ßß 
=
ßß 
	isFactura
ßß #
?
ßß$ %
x
ßß& '
.
ßß' (
	AmountPen
ßß( 1
*
ßß2 3
document
ßß4 <
!
ßß< =
.
ßß= >

BaseAmount
ßß> H
/
ßßI J
document
ßßK S
.
ßßS T
TotalAmount
ßßT _
:
ßß` a
x
ßßb c
.
ßßc d
	AmountPen
ßßd m
;
ßßm n
var
®® 
retentionPen
®® 
=
®® 
document
®® '
?
®®' (
.
®®( )
RetentionAmount
®®) 8
is
®®9 ;
decimal
®®< C
	retention
®®D M
?
®®N O
x
®®P Q
.
®®Q R
	AmountPen
®®R [
*
®®\ ]
	retention
®®^ g
/
®®h i
document
®®j r
.
®®r s
TotalAmount
®®s ~
:®® Ä
$num®®Å É
;®®É Ñ
return
©© 
new
©© 
Sale
©© 
(
©© 
x
©© 
.
©© 
ClientId
©© &
,
©©& '
DateOnly
©©( 0
.
©©0 1
FromDateTime
©©1 =
(
©©= >
x
©©> ?
.
©©? @
	CreatedAt
©©@ I
)
©©I J
,
©©J K
basePen
©©L S
,
©©S T
x
©©U V
.
©©V W
	AmountPen
©©W `
-
©©a b
basePen
©©c j
,
©©j k
	isFactura
©©l u
,
©©u v
retentionPen©©w É
,©©É Ñ
document©©Ö ç
?©©ç é
.©©é è
Type©©è ì
==©©î ñ
TaxDocumentType©©ó ¶
.©©¶ ß#
ReciboPorHonorarios©©ß ∫
)©©∫ ª
;©©ª º
}
™™ 	
)
™™	 

.
™™
 
ToList
™™ 
(
™™ 
)
™™ 
;
™™ 
}
´´ 
[
≠≠ 
HttpGet
≠≠ 
(
≠≠ 
$str
≠≠ 
)
≠≠ 
]
≠≠ 
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
ÆÆ" #
SalesReport
ÆÆ$ /
(
ÆÆ/ 0
int
ÆÆ0 3
?
ÆÆ3 4
month
ÆÆ5 :
,
ÆÆ: ;
int
ÆÆ< ?
year
ÆÆ@ D
,
ÆÆD E
string
ÆÆF L
currency
ÆÆM U
,
ÆÆU V
CancellationToken
ÆÆW h
ct
ÆÆi k
)
ÆÆk l
{
ØØ 
if
∞∞ 

(
∞∞ 
currency
∞∞ 
is
∞∞ 
not
∞∞ 
(
∞∞ 
$str
∞∞ "
or
∞∞# %
$str
∞∞& +
or
∞∞, .
$str
∞∞/ 4
)
∞∞4 5
)
∞∞5 6
return
∞∞7 =

BadRequest
∞∞> H
(
∞∞H I
new
∞∞I L
{
∞∞M N
message
∞∞O V
=
∞∞W X
$str
∞∞Y k
}
∞∞l m
)
∞∞m n
;
∞∞n o
var
±± 
(
±± 
from
±± 
,
±± 
to
±± 
)
±± 
=
±± 
Period
±± 
(
±±  
month
±±  %
,
±±% &
year
±±' +
)
±±+ ,
;
±±, -
var
≤≤ 
sales
≤≤ 
=
≤≤ 
await
≤≤ 

SalesAsync
≤≤ $
(
≤≤$ %
from
≤≤% )
,
≤≤) *
to
≤≤+ -
,
≤≤- .
ct
≤≤/ 1
)
≤≤1 2
;
≤≤2 3
decimal
≥≥ 
basePen
≥≥ 
=
≥≥ 
sales
≥≥ 
.
≥≥  
Sum
≥≥  #
(
≥≥# $
x
≥≥$ %
=>
≥≥& (
x
≥≥) *
.
≥≥* +
BasePen
≥≥+ 2
)
≥≥2 3
,
≥≥3 4
igvPen
≥≥5 ;
=
≥≥< =
sales
≥≥> C
.
≥≥C D
Sum
≥≥D G
(
≥≥G H
x
≥≥H I
=>
≥≥J L
x
≥≥M N
.
≥≥N O
IgvPen
≥≥O U
)
≥≥U V
;
≥≥V W
var
¥¥ 
rate
¥¥ 
=
¥¥ 
currency
¥¥ 
==
¥¥ 
$str
¥¥ $
?
¥¥% &
$num
¥¥' )
:
¥¥* +
await
¥¥, 1
db
¥¥2 4
.
¥¥4 5
RateToPenAsync
¥¥5 C
(
¥¥C D
currency
¥¥D L
,
¥¥L M
to
¥¥N P
,
¥¥P Q
ct
¥¥R T
)
¥¥T U
;
¥¥U V
return
µµ 
Ok
µµ 
(
µµ 
new
µµ 
{
µµ 
baseImponible
µµ %
=
µµ& '
Math
µµ( ,
.
µµ, -
Round
µµ- 2
(
µµ2 3
basePen
µµ3 :
/
µµ; <
rate
µµ= A
,
µµA B
$num
µµC D
)
µµD E
,
µµE F
igv
µµG J
=
µµK L
Math
µµM Q
.
µµQ R
Round
µµR W
(
µµW X
igvPen
µµX ^
/
µµ_ `
rate
µµa e
,
µµe f
$num
µµg h
)
µµh i
,
µµi j
total
µµk p
=
µµq r
Math
µµs w
.
µµw x
Round
µµx }
(
µµ} ~
(
µµ~ 
basePenµµ Ü
+µµá à
igvPenµµâ è
)µµè ê
/µµë í
rateµµì ó
,µµó ò
$numµµô ö
)µµö õ
}µµú ù
)µµù û
;µµû ü
}
∂∂ 
[
∏∏ 
HttpGet
∏∏ 
(
∏∏ 
$str
∏∏ "
)
∏∏" #
]
∏∏# $
public
ππ 

async
ππ 
Task
ππ 
<
ππ 
ActionResult
ππ "
>
ππ" #
TaxSummaryReport
ππ$ 4
(
ππ4 5
int
ππ5 8
?
ππ8 9
month
ππ: ?
,
ππ? @
int
ππA D
year
ππE I
,
ππI J
CancellationToken
ππK \
ct
ππ] _
)
ππ_ `
{
∫∫ 
var
ªª 
settings
ªª 
=
ªª 
await
ªª 
TaxSettingsRow
ªª +
(
ªª+ ,
ct
ªª, .
)
ªª. /
;
ªª/ 0
var
ºº 
(
ºº 
from
ºº 
,
ºº 
to
ºº 
)
ºº 
=
ºº 
Period
ºº 
(
ºº  
month
ºº  %
,
ºº% &
year
ºº' +
)
ºº+ ,
;
ºº, -
var
ΩΩ 
sales
ΩΩ 
=
ΩΩ 
await
ΩΩ 

SalesAsync
ΩΩ $
(
ΩΩ$ %
from
ΩΩ% )
,
ΩΩ) *
to
ΩΩ+ -
,
ΩΩ- .
ct
ΩΩ/ 1
)
ΩΩ1 2
;
ΩΩ2 3
decimal
ææ 
basePen
ææ 
=
ææ 
sales
ææ 
.
ææ  
Sum
ææ  #
(
ææ# $
x
ææ$ %
=>
ææ& (
x
ææ) *
.
ææ* +
BasePen
ææ+ 2
)
ææ2 3
,
ææ3 4
gravadasPen
ææ5 @
=
ææA B
sales
ææC H
.
ææH I
Where
ææI N
(
ææN O
x
ææO P
=>
ææQ S
x
ææT U
.
ææU V
Gravada
ææV ]
)
ææ] ^
.
ææ^ _
Sum
ææ_ b
(
ææb c
x
ææc d
=>
ææe g
x
ææh i
.
ææi j
BasePen
ææj q
)
ææq r
;
æær s
var
øø 
igv
øø 
=
øø 
(
øø 
await
øø 
IgvMonthsAsync
øø '
(
øø' (
to
øø( *
,
øø* +
ct
øø, .
)
øø. /
)
øø/ 0
.
øø0 1
Where
øø1 6
(
øø6 7
x
øø7 8
=>
øø9 ;
x
øø< =
.
øø= >
Month
øø> C
>=
øøD F
from
øøG K
)
øøK L
.
øøL M
ToList
øøM S
(
øøS T
)
øøT U
;
øøU V
return
¡¡ 
Ok
¡¡ 
(
¡¡ 
new
¡¡ 
{
¬¬ 	
ventasGravadasPen
√√ 
=
√√ 
Math
√√  $
.
√√$ %
Round
√√% *
(
√√* +
gravadasPen
√√+ 6
,
√√6 7
$num
√√8 9
)
√√9 :
,
√√: ;!
ventasNoGravadasPen
√√< O
=
√√P Q
Math
√√R V
.
√√V W
Round
√√W \
(
√√\ ]
basePen
√√] d
-
√√e f
gravadasPen
√√g r
,
√√r s
$num
√√t u
)
√√u v
,
√√v w
igvEstimado√√x É
=√√Ñ Ö
Math√√Ü ä
.√√ä ã
Round√√ã ê
(√√ê ë
sales√√ë ñ
.√√ñ ó
Sum√√ó ö
(√√ö õ
x√√õ ú
=>√√ù ü
x√√† °
.√√° ¢
IgvPen√√¢ ®
)√√® ©
,√√© ™
$num√√´ ¨
)√√¨ ≠
,√√≠ Æ
rentaEstimada√√Ø º
=√√Ω æ
Math√√ø √
.√√√ ƒ
Round√√ƒ …
(√√…  
sales√√  œ
.√√œ –
Where√√– ’
(√√’ ÷
x√√÷ ◊
=>√√ÿ ⁄
x√√€ ‹
.√√‹ ›
Mype√√› ·
)√√· ‚
.√√‚ „
Sum√√„ Ê
(√√Ê Á
x√√Á Ë
=>√√È Î
x√√Ï Ì
.√√Ì Ó
BasePen√√Ó ı
)√√ı ˆ
*√√˜ ¯
settings√√˘ Å
.√√Å Ç
	RentaRate√√Ç ã
,√√ã å
$num√√ç é
)√√é è
,√√è ê'
ventasPersonaNaturalPen√√ë ®
=√√© ™
Math√√´ Ø
.√√Ø ∞
Round√√∞ µ
(√√µ ∂
sales√√∂ ª
.√√ª º
Where√√º ¡
(√√¡ ¬
x√√¬ √
=>√√ƒ ∆
x√√« »
.√√» …
PersonaNatural√√… ◊
)√√◊ ÿ
.√√ÿ Ÿ
Sum√√Ÿ ‹
(√√‹ ›
x√√› ﬁ
=>√√ﬂ ·
x√√‚ „
.√√„ ‰
BasePen√√‰ Î
)√√Î Ï
,√√Ï Ì
$num√√Ó Ô
)√√Ô 
,√√ Ò
tasa√√Ú ˆ
=√√˜ ¯
new√√˘ ¸
{√√˝ ˛
igvRate√√ˇ Ü
=√√á à
settings√√â ë
.√√ë í
IgvRate√√í ô
,√√ô ö
	rentaRate√√õ §
=√√• ¶
settings√√ß Ø
.√√Ø ∞
	RentaRate√√∞ π
}√√∫ ª
,√√ª º

disclaimer√√Ω «
=√√» …
TaxDisclaimer√√  ◊
,√√◊ ÿ
igv
≈≈ 
=
≈≈ 
new
≈≈ 
{
∆∆ 
debitoFiscal
«« 
=
«« 
Math
«« #
.
««# $
Round
««$ )
(
««) *
igv
««* -
.
««- .
Sum
««. 1
(
««1 2
x
««2 3
=>
««4 6
x
««7 8
.
««8 9
Debito
««9 ?
)
««? @
,
««@ A
$num
««B C
)
««C D
,
««D E
creditoFiscal
««F S
=
««T U
Math
««V Z
.
««Z [
Round
««[ `
(
««` a
igv
««a d
.
««d e
Sum
««e h
(
««h i
x
««i j
=>
««k m
x
««n o
.
««o p
Credito
««p w
)
««w x
,
««x y
$num
««z {
)
««{ |
,
««| }!
saldoAFavorAnterior
»» #
=
»»$ %
Math
»»& *
.
»»* +
Round
»»+ 0
(
»»0 1
igv
»»1 4
.
»»4 5
FirstOrDefault
»»5 C
(
»»C D
)
»»D E
?
»»E F
.
»»F G
SaldoAnterior
»»G T
??
»»U W
$num
»»X Z
,
»»Z [
$num
»»\ ]
)
»»] ^
,
»»^ _
	igvAPagar
»»` i
=
»»j k
Math
»»l p
.
»»p q
Round
»»q v
(
»»v w
igv
»»w z
.
»»z {
Sum
»»{ ~
(
»»~ 
x»» Ä
=>»»Å É
x»»Ñ Ö
.»»Ö Ü
APagar»»Ü å
)»»å ç
,»»ç é
$num»»è ê
)»»ê ë
,»»ë í"
saldoAFavorSiguiente
…… $
=
……% &
Math
……' +
.
……+ ,
Round
……, 1
(
……1 2
igv
……2 5
.
……5 6
LastOrDefault
……6 C
(
……C D
)
……D E
?
……E F
.
……F G
SaldoSiguiente
……G U
??
……V X
$num
……Y [
,
……[ \
$num
……] ^
)
……^ _
,
……_ `
meses
   
=
   
igv
   
.
   
Select
   "
(
  " #
x
  # $
=>
  % '
new
  ( +
{
  , -
mes
  . 1
=
  2 3
x
  4 5
.
  5 6
Month
  6 ;
.
  ; <
ToString
  < D
(
  D E
$str
  E N
)
  N O
,
  O P
debitoFiscal
  Q ]
=
  ^ _
Math
  ` d
.
  d e
Round
  e j
(
  j k
x
  k l
.
  l m
Debito
  m s
,
  s t
$num
  u v
)
  v w
,
  w x
creditoFiscal  y Ü
=  á à
Math  â ç
.  ç é
Round  é ì
(  ì î
x  î ï
.  ï ñ
Credito  ñ ù
,  ù û
$num  ü †
)  † °
,  ° ¢#
saldoAFavorAnterior  £ ∂
=  ∑ ∏
Math  π Ω
.  Ω æ
Round  æ √
(  √ ƒ
x  ƒ ≈
.  ≈ ∆
SaldoAnterior  ∆ ”
,  ” ‘
$num  ’ ÷
)  ÷ ◊
,  ◊ ÿ
	igvAPagar  Ÿ ‚
=  „ ‰
Math  Â È
.  È Í
Round  Í Ô
(  Ô 
x   Ò
.  Ò Ú
APagar  Ú ¯
,  ¯ ˘
$num  ˙ ˚
)  ˚ ¸
,  ¸ ˝$
saldoAFavorSiguiente  ˛ í
=  ì î
Math  ï ô
.  ô ö
Round  ö ü
(  ü †
x  † °
.  ° ¢
SaldoSiguiente  ¢ ∞
,  ∞ ±
$num  ≤ ≥
)  ≥ ¥
}  µ ∂
)  ∂ ∑
,  ∑ ∏
}
ÀÀ 
,
ÀÀ 
}
ÃÃ 	
)
ÃÃ	 

;
ÃÃ
 
}
ÕÕ 
internal
œœ 
sealed
œœ 
record
œœ 
IgvMonth
œœ #
(
œœ# $
DateOnly
œœ$ ,
Month
œœ- 2
,
œœ2 3
decimal
œœ4 ;
Debito
œœ< B
,
œœB C
decimal
œœD K
Credito
œœL S
,
œœS T
decimal
œœU \
SaldoAnterior
œœ] j
,
œœj k
decimal
œœl s
APagar
œœt z
,
œœz {
decimalœœ| É
SaldoSiguienteœœÑ í
)œœí ì
;œœì î
internal
’’ 
async
’’ 
Task
’’ 
<
’’ 
List
’’ 
<
’’ 
IgvMonth
’’ %
>
’’% &
>
’’& '
IgvMonthsAsync
’’( 6
(
’’6 7
DateOnly
’’7 ?
to
’’@ B
,
’’B C
CancellationToken
’’D U
ct
’’V X
)
’’X Y
{
÷÷ 
var
◊◊ 
end
◊◊ 
=
◊◊ 
new
◊◊ 
DateOnly
◊◊ 
(
◊◊ 
to
◊◊ !
.
◊◊! "
Year
◊◊" &
,
◊◊& '
to
◊◊( *
.
◊◊* +
Month
◊◊+ 0
,
◊◊0 1
$num
◊◊2 3
)
◊◊3 4
;
◊◊4 5
DateOnly
ÿÿ 
?
ÿÿ 
	firstSale
ÿÿ 
=
ÿÿ 
await
ÿÿ #
db
ÿÿ$ &
.
ÿÿ& '!
PaymentTransactions
ÿÿ' :
.
ÿÿ: ;
OrderBy
ÿÿ; B
(
ÿÿB C
x
ÿÿC D
=>
ÿÿE G
x
ÿÿH I
.
ÿÿI J
	CreatedAt
ÿÿJ S
)
ÿÿS T
.
ÿÿT U
Select
ÿÿU [
(
ÿÿ[ \
x
ÿÿ\ ]
=>
ÿÿ^ `
(
ÿÿa b
DateTime
ÿÿb j
?
ÿÿj k
)
ÿÿk l
x
ÿÿl m
.
ÿÿm n
	CreatedAt
ÿÿn w
)
ÿÿw x
.
ÿÿx y"
FirstOrDefaultAsyncÿÿy å
(ÿÿå ç
ctÿÿç è
)ÿÿè ê
isÿÿë ì
DateTimeÿÿî ú
dÿÿù û
?ÿÿü †
DateOnlyÿÿ° ©
.ÿÿ© ™
FromDateTimeÿÿ™ ∂
(ÿÿ∂ ∑
dÿÿ∑ ∏
)ÿÿ∏ π
:ÿÿ∫ ª
nullÿÿº ¿
;ÿÿ¿ ¡
DateOnly
ŸŸ 
?
ŸŸ 
firstPurchase
ŸŸ 
=
ŸŸ  !
await
ŸŸ" '
db
ŸŸ( *
.
ŸŸ* +
	Purchases
ŸŸ+ 4
.
ŸŸ4 5
OrderBy
ŸŸ5 <
(
ŸŸ< =
x
ŸŸ= >
=>
ŸŸ? A
x
ŸŸB C
.
ŸŸC D
Period
ŸŸD J
)
ŸŸJ K
.
ŸŸK L
Select
ŸŸL R
(
ŸŸR S
x
ŸŸS T
=>
ŸŸU W
(
ŸŸX Y
DateOnly
ŸŸY a
?
ŸŸa b
)
ŸŸb c
x
ŸŸc d
.
ŸŸd e
Period
ŸŸe k
)
ŸŸk l
.
ŸŸl m"
FirstOrDefaultAsyncŸŸm Ä
(ŸŸÄ Å
ctŸŸÅ É
)ŸŸÉ Ñ
;ŸŸÑ Ö
var
⁄⁄ 
first
⁄⁄ 
=
⁄⁄ 
new
⁄⁄ 
[
⁄⁄ 
]
⁄⁄ 
{
⁄⁄ 
	firstSale
⁄⁄ %
,
⁄⁄% &
firstPurchase
⁄⁄' 4
}
⁄⁄5 6
.
⁄⁄6 7
Where
⁄⁄7 <
(
⁄⁄< =
x
⁄⁄= >
=>
⁄⁄? A
x
⁄⁄B C
is
⁄⁄D F
not
⁄⁄G J
null
⁄⁄K O
)
⁄⁄O P
.
⁄⁄P Q
Select
⁄⁄Q W
(
⁄⁄W X
x
⁄⁄X Y
=>
⁄⁄Z \
x
⁄⁄] ^
!
⁄⁄^ _
.
⁄⁄_ `
Value
⁄⁄` e
)
⁄⁄e f
.
⁄⁄f g
DefaultIfEmpty
⁄⁄g u
(
⁄⁄u v
end
⁄⁄v y
)
⁄⁄y z
.
⁄⁄z {
Min
⁄⁄{ ~
(
⁄⁄~ 
)⁄⁄ Ä
;⁄⁄Ä Å
var
€€ 
start
€€ 
=
€€ 
new
€€ 
DateOnly
€€  
(
€€  !
first
€€! &
.
€€& '
Year
€€' +
,
€€+ ,
first
€€- 2
.
€€2 3
Month
€€3 8
,
€€8 9
$num
€€: ;
)
€€; <
;
€€< =
if
‹‹ 

(
‹‹ 
start
‹‹ 
>
‹‹ 
end
‹‹ 
)
‹‹ 
start
‹‹ 
=
‹‹  
end
‹‹! $
;
‹‹$ %
var
›› 
sales
›› 
=
›› 
await
›› 

SalesAsync
›› $
(
››$ %
start
››% *
,
››* +
end
››, /
.
››/ 0
	AddMonths
››0 9
(
››9 :
$num
››: ;
)
››; <
.
››< =
AddDays
››= D
(
››D E
-
››E F
$num
››F G
)
››G H
,
››H I
ct
››J L
)
››L M
;
››M N
var
ﬁﬁ 
	purchases
ﬁﬁ 
=
ﬁﬁ 
await
ﬁﬁ 
db
ﬁﬁ  
.
ﬁﬁ  !
	Purchases
ﬁﬁ! *
.
ﬁﬁ* +
Where
ﬁﬁ+ 0
(
ﬁﬁ0 1
x
ﬁﬁ1 2
=>
ﬁﬁ3 5
x
ﬁﬁ6 7
.
ﬁﬁ7 8
Period
ﬁﬁ8 >
>=
ﬁﬁ? A
start
ﬁﬁB G
&&
ﬁﬁH J
x
ﬁﬁK L
.
ﬁﬁL M
Period
ﬁﬁM S
<=
ﬁﬁT V
end
ﬁﬁW Z
)
ﬁﬁZ [
.
ﬁﬁ[ \
ToListAsync
ﬁﬁ\ g
(
ﬁﬁg h
ct
ﬁﬁh j
)
ﬁﬁj k
;
ﬁﬁk l
var
‡‡ 
settings
‡‡ 
=
‡‡ 
await
‡‡ 
TaxSettingsRow
‡‡ +
(
‡‡+ ,
ct
‡‡, .
)
‡‡. /
;
‡‡/ 0
var
·· 
form1662
·· 
=
·· 
settings
·· 
.
··  
Use1662AsCredit
··  /
?
‚‚ 
(
‚‚ 
await
‚‚ 
db
‚‚ 
.
‚‚ 
Expenses
‚‚  
.
‚‚  !
Where
‚‚! &
(
‚‚& '
x
‚‚' (
=>
‚‚) +
x
‚‚, -
.
‚‚- .#
IsNonDomiciledService
‚‚. C
&&
‚‚D F
x
‚‚G H
.
‚‚H I
Form1662PaidAt
‚‚I W
!=
‚‚X Z
null
‚‚[ _
&&
‚‚` b
x
‚‚c d
.
‚‚d e
Form1662PaidAt
‚‚e s
>=
‚‚t v
start
‚‚w |
&&
‚‚} 
x‚‚Ä Å
.‚‚Å Ç
Form1662PaidAt‚‚Ç ê
<=‚‚ë ì
end‚‚î ó
.‚‚ó ò
	AddMonths‚‚ò °
(‚‚° ¢
$num‚‚¢ £
)‚‚£ §
.‚‚§ •
AddDays‚‚• ¨
(‚‚¨ ≠
-‚‚≠ Æ
$num‚‚Æ Ø
)‚‚Ø ∞
)‚‚∞ ±
.‚‚± ≤
ToListAsync‚‚≤ Ω
(‚‚Ω æ
ct‚‚æ ¿
)‚‚¿ ¡
)‚‚¡ ¬
.
„„ 
GroupBy
„„ 
(
„„ 
x
„„ 
=>
„„ 
new
„„ !
DateOnly
„„" *
(
„„* +
x
„„+ ,
.
„„, -
Form1662PaidAt
„„- ;
!
„„; <
.
„„< =
Value
„„= B
.
„„B C
Year
„„C G
,
„„G H
x
„„I J
.
„„J K
Form1662PaidAt
„„K Y
.
„„Y Z
Value
„„Z _
.
„„_ `
Month
„„` e
,
„„e f
$num
„„g h
)
„„h i
)
„„i j
.
„„j k
ToDictionary
„„k w
(
„„w x
g
„„x y
=>
„„z |
g
„„} ~
.
„„~ 
Key„„ Ç
,„„Ç É
g„„Ñ Ö
=>„„Ü à
g„„â ä
.„„ä ã
Sum„„ã é
(„„é è
x„„è ê
=>„„ë ì
Form1662„„î ú
.„„ú ù
Igv„„ù †
(„„† °
x„„° ¢
,„„¢ £
settings„„§ ¨
.„„¨ ≠
IgvRate„„≠ ¥
)„„¥ µ
)„„µ ∂
)„„∂ ∑
:
‰‰ 
[
‰‰ 
]
‰‰ 
;
‰‰ 
var
ÂÂ 
months
ÂÂ 
=
ÂÂ 
new
ÂÂ 
List
ÂÂ 
<
ÂÂ 
IgvMonth
ÂÂ &
>
ÂÂ& '
(
ÂÂ' (
)
ÂÂ( )
;
ÂÂ) *
var
ÂÂ+ .
carry
ÂÂ/ 4
=
ÂÂ5 6
$num
ÂÂ7 9
;
ÂÂ9 :
for
ÊÊ 
(
ÊÊ 
var
ÊÊ 
month
ÊÊ 
=
ÊÊ 
start
ÊÊ 
;
ÊÊ 
month
ÊÊ  %
<=
ÊÊ& (
end
ÊÊ) ,
;
ÊÊ, -
month
ÊÊ. 3
=
ÊÊ4 5
month
ÊÊ6 ;
.
ÊÊ; <
	AddMonths
ÊÊ< E
(
ÊÊE F
$num
ÊÊF G
)
ÊÊG H
)
ÊÊH I
{
ÁÁ 	
var
ËË 
monthEnd
ËË 
=
ËË 
month
ËË  
.
ËË  !
	AddMonths
ËË! *
(
ËË* +
$num
ËË+ ,
)
ËË, -
.
ËË- .
AddDays
ËË. 5
(
ËË5 6
-
ËË6 7
$num
ËË7 8
)
ËË8 9
;
ËË9 :
var
ÈÈ 
debito
ÈÈ 
=
ÈÈ 
sales
ÈÈ 
.
ÈÈ 
Where
ÈÈ $
(
ÈÈ$ %
x
ÈÈ% &
=>
ÈÈ' )
x
ÈÈ* +
.
ÈÈ+ ,
Date
ÈÈ, 0
>=
ÈÈ1 3
month
ÈÈ4 9
&&
ÈÈ: <
x
ÈÈ= >
.
ÈÈ> ?
Date
ÈÈ? C
<=
ÈÈD F
monthEnd
ÈÈG O
)
ÈÈO P
.
ÈÈP Q
Sum
ÈÈQ T
(
ÈÈT U
x
ÈÈU V
=>
ÈÈW Y
x
ÈÈZ [
.
ÈÈ[ \
IgvPen
ÈÈ\ b
)
ÈÈb c
;
ÈÈc d
var
ÍÍ 
credito
ÍÍ 
=
ÍÍ 
	purchases
ÍÍ #
.
ÍÍ# $
Where
ÍÍ$ )
(
ÍÍ) *
x
ÍÍ* +
=>
ÍÍ, .
x
ÍÍ/ 0
.
ÍÍ0 1
Period
ÍÍ1 7
==
ÍÍ8 :
month
ÍÍ; @
)
ÍÍ@ A
.
ÍÍA B
Sum
ÍÍB E
(
ÍÍE F
x
ÍÍF G
=>
ÍÍH J
x
ÍÍK L
.
ÍÍL M
TaxCreditPen
ÍÍM Y
)
ÍÍY Z
+
ÍÍ[ \
form1662
ÍÍ] e
.
ÍÍe f
GetValueOrDefault
ÍÍf w
(
ÍÍw x
month
ÍÍx }
)
ÍÍ} ~
;
ÍÍ~ 
var
ÎÎ 
result
ÎÎ 
=
ÎÎ 
debito
ÎÎ 
-
ÎÎ  !
credito
ÎÎ" )
-
ÎÎ* +
carry
ÎÎ, 1
;
ÎÎ1 2
months
ÏÏ 
.
ÏÏ 
Add
ÏÏ 
(
ÏÏ 
new
ÏÏ 
IgvMonth
ÏÏ #
(
ÏÏ# $
month
ÏÏ$ )
,
ÏÏ) *
debito
ÏÏ+ 1
,
ÏÏ1 2
credito
ÏÏ3 :
,
ÏÏ: ;
carry
ÏÏ< A
,
ÏÏA B
Math
ÏÏC G
.
ÏÏG H
Max
ÏÏH K
(
ÏÏK L
result
ÏÏL R
,
ÏÏR S
$num
ÏÏT V
)
ÏÏV W
,
ÏÏW X
Math
ÏÏY ]
.
ÏÏ] ^
Max
ÏÏ^ a
(
ÏÏa b
-
ÏÏb c
result
ÏÏc i
,
ÏÏi j
$num
ÏÏk m
)
ÏÏm n
)
ÏÏn o
)
ÏÏo p
;
ÏÏp q
carry
ÌÌ 
=
ÌÌ 
Math
ÌÌ 
.
ÌÌ 
Max
ÌÌ 
(
ÌÌ 
-
ÌÌ 
result
ÌÌ $
,
ÌÌ$ %
$num
ÌÌ& (
)
ÌÌ( )
;
ÌÌ) *
}
ÓÓ 	
return
ÔÔ 
months
ÔÔ 
;
ÔÔ 
}
 
[
ÚÚ 
HttpGet
ÚÚ 
(
ÚÚ 
$str
ÚÚ 
)
ÚÚ  
]
ÚÚ  !
public
ÛÛ 

async
ÛÛ 
Task
ÛÛ 
<
ÛÛ 
ActionResult
ÛÛ "
>
ÛÛ" #
ExpensesReport
ÛÛ$ 2
(
ÛÛ2 3
int
ÛÛ3 6
?
ÛÛ6 7
month
ÛÛ8 =
,
ÛÛ= >
int
ÛÛ? B
year
ÛÛC G
,
ÛÛG H
CancellationToken
ÛÛI Z
ct
ÛÛ[ ]
)
ÛÛ] ^
{
ÙÙ 
var
ıı 
(
ıı 
from
ıı 
,
ıı 
to
ıı 
)
ıı 
=
ıı 
Period
ıı 
(
ıı  
month
ıı  %
,
ıı% &
year
ıı' +
)
ıı+ ,
;
ıı, -
var
ˆˆ 
expenses
ˆˆ 
=
ˆˆ 
await
ˆˆ 
db
ˆˆ 
.
ˆˆ  
Expenses
ˆˆ  (
.
ˆˆ( )
Include
ˆˆ) 0
(
ˆˆ0 1
x
ˆˆ1 2
=>
ˆˆ3 5
x
ˆˆ6 7
.
ˆˆ7 8
Category
ˆˆ8 @
)
ˆˆ@ A
.
ˆˆA B
Where
ˆˆB G
(
ˆˆG H
x
ˆˆH I
=>
ˆˆJ L
x
ˆˆM N
.
ˆˆN O
Date
ˆˆO S
>=
ˆˆT V
from
ˆˆW [
&&
ˆˆ\ ^
x
ˆˆ_ `
.
ˆˆ` a
Date
ˆˆa e
<=
ˆˆf h
to
ˆˆi k
)
ˆˆk l
.
ˆˆl m
ToListAsync
ˆˆm x
(
ˆˆx y
ct
ˆˆy {
)
ˆˆ{ |
;
ˆˆ| }
return
˜˜ 
Ok
˜˜ 
(
˜˜ 
new
˜˜ 
{
˜˜ 
total
˜˜ 
=
˜˜ 
Math
˜˜  $
.
˜˜$ %
Round
˜˜% *
(
˜˜* +
expenses
˜˜+ 3
.
˜˜3 4
Sum
˜˜4 7
(
˜˜7 8
x
˜˜8 9
=>
˜˜: <
x
˜˜= >
.
˜˜> ?
	AmountPen
˜˜? H
)
˜˜H I
,
˜˜I J
$num
˜˜K L
)
˜˜L M
,
˜˜M N
porCategoria
˜˜O [
=
˜˜\ ]
expenses
˜˜^ f
.
˜˜f g
GroupBy
˜˜g n
(
˜˜n o
x
˜˜o p
=>
˜˜q s
x
˜˜t u
.
˜˜u v
Category
˜˜v ~
?
˜˜~ 
.˜˜ Ä
Name˜˜Ä Ñ
??˜˜Ö á
$str˜˜à ó
)˜˜ó ò
.˜˜ò ô!
OrderByDescending˜˜ô ™
(˜˜™ ´
g˜˜´ ¨
=>˜˜≠ Ø
g˜˜∞ ±
.˜˜± ≤
Sum˜˜≤ µ
(˜˜µ ∂
x˜˜∂ ∑
=>˜˜∏ ∫
x˜˜ª º
.˜˜º Ω
	AmountPen˜˜Ω ∆
)˜˜∆ «
)˜˜« »
.˜˜» …
Select˜˜… œ
(˜˜œ –
g˜˜– —
=>˜˜“ ‘
new˜˜’ ÿ
{˜˜Ÿ ⁄
	categoria˜˜€ ‰
=˜˜Â Ê
g˜˜Á Ë
.˜˜Ë È
Key˜˜È Ï
,˜˜Ï Ì
monto˜˜Ó Û
=˜˜Ù ı
Math˜˜ˆ ˙
.˜˜˙ ˚
Round˜˜˚ Ä
(˜˜Ä Å
g˜˜Å Ç
.˜˜Ç É
Sum˜˜É Ü
(˜˜Ü á
x˜˜á à
=>˜˜â ã
x˜˜å ç
.˜˜ç é
	AmountPen˜˜é ó
)˜˜ó ò
,˜˜ò ô
$num˜˜ö õ
)˜˜õ ú
}˜˜ù û
)˜˜û ü
}˜˜† °
)˜˜° ¢
;˜˜¢ £
}
¯¯ 
[
ˇˇ 
HttpGet
ˇˇ 
(
ˇˇ 
$str
ˇˇ 
)
ˇˇ 
]
ˇˇ 
public
ÄÄ 

async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
ActionResult
ÄÄ "
>
ÄÄ" #
	NetReport
ÄÄ$ -
(
ÄÄ- .
int
ÄÄ. 1
?
ÄÄ1 2
month
ÄÄ3 8
,
ÄÄ8 9
int
ÄÄ: =
year
ÄÄ> B
,
ÄÄB C
CancellationToken
ÄÄD U
ct
ÄÄV X
)
ÄÄX Y
{
ÅÅ 
var
ÇÇ 
settings
ÇÇ 
=
ÇÇ 
await
ÇÇ 
TaxSettingsRow
ÇÇ +
(
ÇÇ+ ,
ct
ÇÇ, .
)
ÇÇ. /
;
ÇÇ/ 0
var
ÉÉ 
(
ÉÉ 
from
ÉÉ 
,
ÉÉ 
to
ÉÉ 
)
ÉÉ 
=
ÉÉ 
Period
ÉÉ 
(
ÉÉ  
month
ÉÉ  %
,
ÉÉ% &
year
ÉÉ' +
)
ÉÉ+ ,
;
ÉÉ, -
var
ÑÑ 
sales
ÑÑ 
=
ÑÑ 
await
ÑÑ 

SalesAsync
ÑÑ $
(
ÑÑ$ %
from
ÑÑ% )
,
ÑÑ) *
to
ÑÑ+ -
,
ÑÑ- .
ct
ÑÑ/ 1
)
ÑÑ1 2
;
ÑÑ2 3
var
ÖÖ 
expenses
ÖÖ 
=
ÖÖ 
await
ÖÖ 
db
ÖÖ 
.
ÖÖ  
Expenses
ÖÖ  (
.
ÖÖ( )
Include
ÖÖ) 0
(
ÖÖ0 1
x
ÖÖ1 2
=>
ÖÖ3 5
x
ÖÖ6 7
.
ÖÖ7 8
Category
ÖÖ8 @
)
ÖÖ@ A
.
ÖÖA B
Where
ÖÖB G
(
ÖÖG H
x
ÖÖH I
=>
ÖÖJ L
x
ÖÖM N
.
ÖÖN O
Date
ÖÖO S
>=
ÖÖT V
from
ÖÖW [
&&
ÖÖ\ ^
x
ÖÖ_ `
.
ÖÖ` a
Date
ÖÖa e
<=
ÖÖf h
to
ÖÖi k
)
ÖÖk l
.
ÖÖl m
ToListAsync
ÖÖm x
(
ÖÖx y
ct
ÖÖy {
)
ÖÖ{ |
;
ÖÖ| }
var
ÜÜ 
result
ÜÜ 
=
ÜÜ 

NetFigures
ÜÜ 
(
ÜÜ  
sales
ÜÜ  %
,
ÜÜ% &
expenses
ÜÜ' /
,
ÜÜ/ 0
settings
ÜÜ1 9
.
ÜÜ9 :
	RentaRate
ÜÜ: C
)
ÜÜC D
;
ÜÜD E
var
áá 
serie
áá 
=
áá 

Enumerable
áá 
.
áá 
Range
áá $
(
áá$ %
$num
áá% &
,
áá& '
month
áá( -
is
áá. 0
null
áá1 5
?
áá6 7
$num
áá8 :
:
áá; <
$num
áá= >
)
áá> ?
.
áá? @
Select
áá@ F
(
ááF G
i
ááG H
=>
ááI K
from
ááL P
.
ááP Q
	AddMonths
ááQ Z
(
ááZ [
i
áá[ \
)
áá\ ]
)
áá] ^
.
áá^ _
Select
áá_ e
(
ááe f
start
ááf k
=>
áál n
{
àà 	
var
ââ 
end
ââ 
=
ââ 
start
ââ 
.
ââ 
	AddMonths
ââ %
(
ââ% &
$num
ââ& '
)
ââ' (
.
ââ( )
AddDays
ââ) 0
(
ââ0 1
-
ââ1 2
$num
ââ2 3
)
ââ3 4
;
ââ4 5
var
ää 
n
ää 
=
ää 

NetFigures
ää 
(
ää 
sales
ää $
.
ää$ %
Where
ää% *
(
ää* +
x
ää+ ,
=>
ää- /
x
ää0 1
.
ää1 2
Date
ää2 6
>=
ää7 9
start
ää: ?
&&
ää@ B
x
ääC D
.
ääD E
Date
ääE I
<=
ääJ L
end
ääM P
)
ääP Q
,
ääQ R
expenses
ääS [
.
ää[ \
Where
ää\ a
(
ääa b
x
ääb c
=>
ääd f
x
ääg h
.
ääh i
Date
ääi m
>=
ään p
start
ääq v
&&
ääw y
x
ääz {
.
ää{ |
Dateää| Ä
<=ääÅ É
endääÑ á
)ääá à
,ääà â
settingsäää í
.ääí ì
	RentaRateääì ú
)ääú ù
;ääù û
return
ãã 
new
ãã 
NetPoint
ãã 
(
ãã  
start
ãã  %
.
ãã% &
ToString
ãã& .
(
ãã. /
$str
ãã/ 8
)
ãã8 9
,
ãã9 :
Math
ãã; ?
.
ãã? @
Round
ãã@ E
(
ããE F
n
ããF G
.
ããG H
Ventas
ããH N
,
ããN O
$num
ããP Q
)
ããQ R
,
ããR S
Math
ããT X
.
ããX Y
Round
ããY ^
(
ãã^ _
n
ãã_ `
.
ãã` a
Gastos
ããa g
,
ããg h
$num
ããi j
)
ããj k
,
ããk l
Math
ããm q
.
ããq r
Round
ããr w
(
ããw x
n
ããx y
.
ããy z
	Impuestosããz É
,ããÉ Ñ
$numããÖ Ü
)ããÜ á
,ããá à
Mathããâ ç
.ããç é
Roundããé ì
(ããì î
nããî ï
.ããï ñ
Netaããñ ö
,ããö õ
$numããú ù
)ããù û
)ããû ü
;ããü †
}
åå 	
)
åå	 

.
åå
 
ToList
åå 
(
åå 
)
åå 
;
åå 
return
çç 
Ok
çç 
(
çç 
new
çç 
{
éé 	
	ventasPen
èè 
=
èè 
Math
èè 
.
èè 
Round
èè "
(
èè" #
result
èè# )
.
èè) *
Ventas
èè* 0
,
èè0 1
$num
èè2 3
)
èè3 4
,
èè4 5
	gastosPen
èè6 ?
=
èè@ A
Math
èèB F
.
èèF G
Round
èèG L
(
èèL M
result
èèM S
.
èèS T
Gastos
èèT Z
,
èèZ [
$num
èè\ ]
)
èè] ^
,
èè^ _"
utilidadOperativaPen
èè` t
=
èèu v
Math
èèw {
.
èè{ |
Roundèè| Å
(èèÅ Ç
resultèèÇ à
.èèà â
Ventasèèâ è
-èèê ë
resultèèí ò
.èèò ô
Gastosèèô ü
,èèü †
$numèè° ¢
)èè¢ £
,èè£ §
	rentaRate
êê 
=
êê 
settings
êê  
.
êê  !
	RentaRate
êê! *
,
êê* +
impuestosPen
êê, 8
=
êê9 :
Math
êê; ?
.
êê? @
Round
êê@ E
(
êêE F
result
êêF L
.
êêL M
	Impuestos
êêM V
,
êêV W
$num
êêX Y
)
êêY Z
,
êêZ [
utilidadNetaPen
ëë 
=
ëë 
Math
ëë "
.
ëë" #
Round
ëë# (
(
ëë( )
result
ëë) /
.
ëë/ 0
Neta
ëë0 4
,
ëë4 5
$num
ëë6 7
)
ëë7 8
,
ëë8 9
margen
ëë: @
=
ëëA B
result
ëëC I
.
ëëI J
Ventas
ëëJ P
==
ëëQ S
$num
ëëT U
?
ëëV W
$num
ëëX Z
:
ëë[ \
Math
ëë] a
.
ëëa b
Round
ëëb g
(
ëëg h
result
ëëh n
.
ëën o
Neta
ëëo s
/
ëët u
result
ëëv |
.
ëë| }
Ventasëë} É
*ëëÑ Ö
$numëëÜ â
,ëëâ ä
$numëëã å
)ëëå ç
,ëëç é
serie
íí 
,
íí 

disclaimer
íí 
=
íí 
TaxDisclaimer
íí  -
,
íí- .
}
ìì 	
)
ìì	 

;
ìì
 
}
îî 
private
ññ 
sealed
ññ 
record
ññ 
NetPoint
ññ "
(
ññ" #
string
ññ# )
Mes
ññ* -
,
ññ- .
decimal
ññ/ 6
	VentasPen
ññ7 @
,
ññ@ A
decimal
ññB I
	GastosPen
ññJ S
,
ññS T
decimal
ññU \
ImpuestosPen
ññ] i
,
ññi j
decimal
ññk r
UtilidadNetaPenññs Ç
)ññÇ É
;ññÉ Ñ
private
ôô 
static
ôô 
(
ôô 
decimal
ôô 
Ventas
ôô "
,
ôô" #
decimal
ôô$ +
Gastos
ôô, 2
,
ôô2 3
decimal
ôô4 ;
	Impuestos
ôô< E
,
ôôE F
decimal
ôôG N
Neta
ôôO S
)
ôôS T

NetFigures
ôôU _
(
ôô_ `
IEnumerable
ôô` k
<
ôôk l
Sale
ôôl p
>
ôôp q
sales
ôôr w
,
ôôw x
IEnumerableôôy Ñ
<ôôÑ Ö
ExpenseôôÖ å
>ôôå ç
expensesôôé ñ
,ôôñ ó
decimalôôò ü
	rentaRateôô† ©
)ôô© ™
{
öö 
var
õõ 
ventas
õõ 
=
õõ 
sales
õõ 
.
õõ 
Sum
õõ 
(
õõ 
x
õõ  
=>
õõ! #
x
õõ$ %
.
õõ% &
BasePen
õõ& -
)
õõ- .
;
õõ. /
var
úú 
gastos
úú 
=
úú 
expenses
úú 
.
úú 
Where
úú #
(
úú# $
x
úú$ %
=>
úú& (
x
úú) *
.
úú* +
Category
úú+ 3
?
úú3 4
.
úú4 5
IsIncomeTax
úú5 @
!=
úúA C
true
úúD H
)
úúH I
.
úúI J
Sum
úúJ M
(
úúM N
x
úúN O
=>
úúP R
x
úúS T
.
úúT U
	AmountPen
úúU ^
)
úú^ _
;
úú_ `
var
ùù 
	impuestos
ùù 
=
ùù 
sales
ùù 
.
ùù 
Where
ùù #
(
ùù# $
x
ùù$ %
=>
ùù& (
x
ùù) *
.
ùù* +
Mype
ùù+ /
)
ùù/ 0
.
ùù0 1
Sum
ùù1 4
(
ùù4 5
x
ùù5 6
=>
ùù7 9
x
ùù: ;
.
ùù; <
BasePen
ùù< C
)
ùùC D
*
ùùE F
	rentaRate
ùùG P
;
ùùP Q
return
ûû 
(
ûû 
ventas
ûû 
,
ûû 
gastos
ûû 
,
ûû 
	impuestos
ûû  )
,
ûû) *
ventas
ûû+ 1
-
ûû2 3
gastos
ûû4 :
-
ûû; <
	impuestos
ûû= F
)
ûûF G
;
ûûG H
}
üü 
[
¢¢ 
HttpGet
¢¢ 
(
¢¢ 
$str
¢¢ 
)
¢¢ 
]
¢¢  
public
££ 

async
££ 
Task
££ 
<
££ 
ActionResult
££ "
>
££" #
ClientsReport
££$ 1
(
££1 2
int
££2 5
?
££5 6
month
££7 <
,
££< =
int
££> A
year
££B F
,
££F G
CancellationToken
££H Y
ct
££Z \
)
££\ ]
{
§§ 
var
•• 
(
•• 
total
•• 
,
•• 
clientes
•• 
)
•• 
=
•• 
await
••  % 
ClientRankingAsync
••& 8
(
••8 9
month
••9 >
,
••> ?
year
••@ D
,
••D E
ct
••F H
)
••H I
;
••I J
return
¶¶ 
Ok
¶¶ 
(
¶¶ 
new
¶¶ 
{
¶¶ 
totalPen
¶¶  
=
¶¶! "
total
¶¶# (
,
¶¶( )
clientes
¶¶* 2
}
¶¶3 4
)
¶¶4 5
;
¶¶5 6
}
ßß 
private
©© 
sealed
©© 
record
©© 
ClientRankingRow
©© *
(
©©* +
Guid
©©+ /
ClientId
©©0 8
,
©©8 9
string
©©: @

ClientName
©©A K
,
©©K L
decimal
©©M T
IngresosPen
©©U `
,
©©` a
decimal
©©b i

Porcentaje
©©j t
,
©©t u
decimal
©©v }"
PorcentajeAcumulado©©~ ë
,©©ë í
int©©ì ñ
Cobros©©ó ù
,©©ù û
DateOnly©©ü ß
UltimoCobro©©® ≥
,©©≥ ¥
decimal©©µ º"
PeriodoAnteriorPen©©Ω œ
,©©œ –
decimal©©— ÿ
?©©ÿ Ÿ#
VariacionPorcentaje©©⁄ Ì
)©©Ì Ó
;©©Ó Ô
private
´´ 
async
´´ 
Task
´´ 
<
´´ 
(
´´ 
decimal
´´ 
Total
´´  %
,
´´% &
List
´´' +
<
´´+ ,
ClientRankingRow
´´, <
>
´´< =
Rows
´´> B
)
´´B C
>
´´C D 
ClientRankingAsync
´´E W
(
´´W X
int
´´X [
?
´´[ \
month
´´] b
,
´´b c
int
´´d g
year
´´h l
,
´´l m
CancellationToken
´´n 
ct´´Ä Ç
)´´Ç É
{
¨¨ 
var
≠≠ 
(
≠≠ 
from
≠≠ 
,
≠≠ 
to
≠≠ 
)
≠≠ 
=
≠≠ 
Period
≠≠ 
(
≠≠  
month
≠≠  %
,
≠≠% &
year
≠≠' +
)
≠≠+ ,
;
≠≠, -
var
≠≠. 1
(
≠≠2 3
previousFrom
≠≠3 ?
,
≠≠? @

previousTo
≠≠A K
)
≠≠K L
=
≠≠M N
PreviousPeriod
≠≠O ]
(
≠≠] ^
month
≠≠^ c
,
≠≠c d
year
≠≠e i
)
≠≠i j
;
≠≠j k
var
ÆÆ 
sales
ÆÆ 
=
ÆÆ 
await
ÆÆ 

SalesAsync
ÆÆ $
(
ÆÆ$ %
from
ÆÆ% )
,
ÆÆ) *
to
ÆÆ+ -
,
ÆÆ- .
ct
ÆÆ/ 1
)
ÆÆ1 2
;
ÆÆ2 3
var
ØØ 
previous
ØØ 
=
ØØ 
(
ØØ 
await
ØØ 

SalesAsync
ØØ (
(
ØØ( )
previousFrom
ØØ) 5
,
ØØ5 6

previousTo
ØØ7 A
,
ØØA B
ct
ØØC E
)
ØØE F
)
ØØF G
.
ØØG H
GroupBy
ØØH O
(
ØØO P
x
ØØP Q
=>
ØØR T
x
ØØU V
.
ØØV W
ClientId
ØØW _
)
ØØ_ `
.
ØØ` a
ToDictionary
ØØa m
(
ØØm n
g
ØØn o
=>
ØØp r
g
ØØs t
.
ØØt u
Key
ØØu x
,
ØØx y
g
ØØz {
=>
ØØ| ~
gØØ Ä
.ØØÄ Å
SumØØÅ Ñ
(ØØÑ Ö
xØØÖ Ü
=>ØØá â
xØØä ã
.ØØã å
BasePenØØå ì
)ØØì î
)ØØî ï
;ØØï ñ
var
∞∞ 
names
∞∞ 
=
∞∞ 
await
∞∞ 
db
∞∞ 
.
∞∞ 
Clients
∞∞ $
.
∞∞$ %
ToDictionaryAsync
∞∞% 6
(
∞∞6 7
x
∞∞7 8
=>
∞∞9 ;
x
∞∞< =
.
∞∞= >
Id
∞∞> @
,
∞∞@ A
x
∞∞B C
=>
∞∞D F
x
∞∞G H
.
∞∞H I
CompanyName
∞∞I T
,
∞∞T U
ct
∞∞V X
)
∞∞X Y
;
∞∞Y Z
var
±± 
total
±± 
=
±± 
sales
±± 
.
±± 
Sum
±± 
(
±± 
x
±± 
=>
±±  "
x
±±# $
.
±±$ %
BasePen
±±% ,
)
±±, -
;
±±- .
var
±±/ 2
accumulated
±±3 >
=
±±? @
$num
±±A C
;
±±C D
var
≤≤ 
rows
≤≤ 
=
≤≤ 
sales
≤≤ 
.
≤≤ 
GroupBy
≤≤  
(
≤≤  !
x
≤≤! "
=>
≤≤# %
x
≤≤& '
.
≤≤' (
ClientId
≤≤( 0
)
≤≤0 1
.
≤≤1 2
Select
≤≤2 8
(
≤≤8 9
g
≤≤9 :
=>
≤≤; =
new
≤≤> A
{
≤≤B C
ClientId
≤≤D L
=
≤≤M N
g
≤≤O P
.
≤≤P Q
Key
≤≤Q T
,
≤≤T U
Pen
≤≤V Y
=
≤≤Z [
g
≤≤\ ]
.
≤≤] ^
Sum
≤≤^ a
(
≤≤a b
x
≤≤b c
=>
≤≤d f
x
≤≤g h
.
≤≤h i
BasePen
≤≤i p
)
≤≤p q
,
≤≤q r
Count
≤≤s x
=
≤≤y z
g
≤≤{ |
.
≤≤| }
Count≤≤} Ç
(≤≤Ç É
)≤≤É Ñ
,≤≤Ñ Ö
Last≤≤Ü ä
=≤≤ã å
g≤≤ç é
.≤≤é è
Max≤≤è í
(≤≤í ì
x≤≤ì î
=>≤≤ï ó
x≤≤ò ô
.≤≤ô ö
Date≤≤ö û
)≤≤û ü
}≤≤† °
)≤≤° ¢
.≤≤¢ £!
OrderByDescending≤≤£ ¥
(≤≤¥ µ
x≤≤µ ∂
=>≤≤∑ π
x≤≤∫ ª
.≤≤ª º
Pen≤≤º ø
)≤≤ø ¿
.≤≤¿ ¡
Select≤≤¡ «
(≤≤« »
x≤≤» …
=>≤≤  Ã
{
≥≥ 	
accumulated
¥¥ 
+=
¥¥ 
x
¥¥ 
.
¥¥ 
Pen
¥¥  
;
¥¥  !
var
µµ 
before
µµ 
=
µµ 
previous
µµ !
.
µµ! "
GetValueOrDefault
µµ" 3
(
µµ3 4
x
µµ4 5
.
µµ5 6
ClientId
µµ6 >
)
µµ> ?
;
µµ? @
return
∂∂ 
new
∂∂ 
ClientRankingRow
∂∂ '
(
∂∂' (
x
∂∂( )
.
∂∂) *
ClientId
∂∂* 2
,
∂∂2 3
names
∂∂4 9
.
∂∂9 :
GetValueOrDefault
∂∂: K
(
∂∂K L
x
∂∂L M
.
∂∂M N
ClientId
∂∂N V
)
∂∂V W
??
∂∂X Z
$str
∂∂[ p
,
∂∂p q
Math
∂∂r v
.
∂∂v w
Round
∂∂w |
(
∂∂| }
x
∂∂} ~
.
∂∂~ 
Pen∂∂ Ç
,∂∂Ç É
$num∂∂Ñ Ö
)∂∂Ö Ü
,∂∂Ü á
total∂∂à ç
==∂∂é ê
$num∂∂ë í
?∂∂ì î
$num∂∂ï ñ
:∂∂ó ò
Math∂∂ô ù
.∂∂ù û
Round∂∂û £
(∂∂£ §
x∂∂§ •
.∂∂• ¶
Pen∂∂¶ ©
/∂∂™ ´
total∂∂¨ ±
*∂∂≤ ≥
$num∂∂¥ ∑
,∂∂∑ ∏
$num∂∂π ∫
)∂∂∫ ª
,∂∂ª º
total∂∂Ω ¬
==∂∂√ ≈
$num∂∂∆ «
?∂∂» …
$num∂∂  À
:∂∂Ã Õ
Math∂∂Œ “
.∂∂“ ”
Round∂∂” ÿ
(∂∂ÿ Ÿ
accumulated∂∂Ÿ ‰
/∂∂Â Ê
total∂∂Á Ï
*∂∂Ì Ó
$num∂∂Ô Ú
,∂∂Ú Û
$num∂∂Ù ı
)∂∂ı ˆ
,∂∂ˆ ˜
x∂∂¯ ˘
.∂∂˘ ˙
Count∂∂˙ ˇ
,∂∂ˇ Ä
x∂∂Å Ç
.∂∂Ç É
Last∂∂É á
,∂∂á à
Math∂∂â ç
.∂∂ç é
Round∂∂é ì
(∂∂ì î
before∂∂î ö
,∂∂ö õ
$num∂∂ú ù
)∂∂ù û
,∂∂û ü
before∂∂† ¶
>∂∂ß ®
$num∂∂© ™
?∂∂´ ¨
Math∂∂≠ ±
.∂∂± ≤
Round∂∂≤ ∑
(∂∂∑ ∏
(∂∂∏ π
x∂∂π ∫
.∂∂∫ ª
Pen∂∂ª æ
-∂∂ø ¿
before∂∂¡ «
)∂∂« »
/∂∂…  
before∂∂À —
*∂∂“ ”
$num∂∂‘ ◊
,∂∂◊ ÿ
$num∂∂Ÿ ⁄
)∂∂⁄ €
:∂∂‹ ›
null∂∂ﬁ ‚
)∂∂‚ „
;∂∂„ ‰
}
∑∑ 	
)
∑∑	 

.
∑∑
 
ToList
∑∑ 
(
∑∑ 
)
∑∑ 
;
∑∑ 
return
∏∏ 
(
∏∏ 
Math
∏∏ 
.
∏∏ 
Round
∏∏ 
(
∏∏ 
total
∏∏  
,
∏∏  !
$num
∏∏" #
)
∏∏# $
,
∏∏$ %
rows
∏∏& *
)
∏∏* +
;
∏∏+ ,
}
ππ 
[
ºº 
HttpGet
ºº 
(
ºº 
$str
ºº 
)
ºº 
]
ºº 
public
ΩΩ 

async
ΩΩ 
Task
ΩΩ 
<
ΩΩ 
IActionResult
ΩΩ #
>
ΩΩ# $
ExportReport
ΩΩ% 1
(
ΩΩ1 2
int
ΩΩ2 5
?
ΩΩ5 6
month
ΩΩ7 <
,
ΩΩ< =
int
ΩΩ> A
year
ΩΩB F
,
ΩΩF G
CancellationToken
ΩΩH Y
ct
ΩΩZ \
)
ΩΩ\ ]
{
ææ 
var
øø 
settings
øø 
=
øø 
await
øø 
TaxSettingsRow
øø +
(
øø+ ,
ct
øø, .
)
øø. /
;
øø/ 0
var
¿¿ 
(
¿¿ 
from
¿¿ 
,
¿¿ 
to
¿¿ 
)
¿¿ 
=
¿¿ 
Period
¿¿ 
(
¿¿  
month
¿¿  %
,
¿¿% &
year
¿¿' +
)
¿¿+ ,
;
¿¿, -
var
¡¡ 
sales
¡¡ 
=
¡¡ 
await
¡¡ 

SalesAsync
¡¡ $
(
¡¡$ %
from
¡¡% )
,
¡¡) *
to
¡¡+ -
,
¡¡- .
ct
¡¡/ 1
)
¡¡1 2
;
¡¡2 3
var
¬¬ 
expenses
¬¬ 
=
¬¬ 
await
¬¬ 
db
¬¬ 
.
¬¬  
Expenses
¬¬  (
.
¬¬( )
Include
¬¬) 0
(
¬¬0 1
x
¬¬1 2
=>
¬¬3 5
x
¬¬6 7
.
¬¬7 8
Category
¬¬8 @
)
¬¬@ A
.
¬¬A B
Where
¬¬B G
(
¬¬G H
x
¬¬H I
=>
¬¬J L
x
¬¬M N
.
¬¬N O
Date
¬¬O S
>=
¬¬T V
from
¬¬W [
&&
¬¬\ ^
x
¬¬_ `
.
¬¬` a
Date
¬¬a e
<=
¬¬f h
to
¬¬i k
)
¬¬k l
.
¬¬l m
ToListAsync
¬¬m x
(
¬¬x y
ct
¬¬y {
)
¬¬{ |
;
¬¬| }
var
√√ 
net
√√ 
=
√√ 

NetFigures
√√ 
(
√√ 
sales
√√ "
,
√√" #
expenses
√√$ ,
,
√√, -
settings
√√. 6
.
√√6 7
	RentaRate
√√7 @
)
√√@ A
;
√√A B
var
ƒƒ 
(
ƒƒ 
_
ƒƒ 
,
ƒƒ 
ranking
ƒƒ 
)
ƒƒ 
=
ƒƒ 
await
ƒƒ   
ClientRankingAsync
ƒƒ! 3
(
ƒƒ3 4
month
ƒƒ4 9
,
ƒƒ9 :
year
ƒƒ; ?
,
ƒƒ? @
ct
ƒƒA C
)
ƒƒC D
;
ƒƒD E
using
∆∆ 
var
∆∆ 
book
∆∆ 
=
∆∆ 
new
∆∆ 

XLWorkbook
∆∆ '
(
∆∆' (
)
∆∆( )
;
∆∆) *
var
«« 
summary
«« 
=
«« 
book
«« 
.
«« 
AddWorksheet
«« '
(
««' (
$str
««( 2
)
««2 3
;
««3 4
(
»» 	
string
»»	 
Label
»» 
,
»» 
decimal
»» 
Value
»» $
)
»»$ %
[
»»% &
]
»»& '
figures
»»( /
=
»»0 1
[
»»2 3
(
»»3 4
$str
»»4 J
,
»»J K
net
»»L O
.
»»O P
Ventas
»»P V
)
»»V W
,
»»W X
(
»»Y Z
$str
»»Z s
,
»»s t
net
»»u x
.
»»x y
Gastos
»»y 
)»» Ä
,»»Ä Å
(»»Ç É
$str»»É ù
,»»ù û
net»»ü ¢
.»»¢ £
Ventas»»£ ©
-»»™ ´
net»»¨ Ø
.»»Ø ∞
Gastos»»∞ ∂
)»»∂ ∑
,»»∑ ∏
(»»π ∫
$"»»∫ º
$str»»º —
{»»— “
settings»»“ ⁄
.»»⁄ €
	RentaRate»»€ ‰
*»»Â Ê
$num»»Á Í
:»»Í Î
$str»»Î Ô
}»»Ô 
$str»» ¯
"»»¯ ˘
,»»˘ ˙
net»»˚ ˛
.»»˛ ˇ
	Impuestos»»ˇ à
)»»à â
,»»â ä
(»»ã å
$str»»å °
,»»° ¢
net»»£ ¶
.»»¶ ß
Neta»»ß ´
)»»´ ¨
,»»¨ ≠
(»»Æ Ø
$str»»Ø æ
,»»æ ø
net»»¿ √
.»»√ ƒ
Ventas»»ƒ  
==»»À Õ
$num»»Œ œ
?»»– —
$num»»“ ”
:»»‘ ’
net»»÷ Ÿ
.»»Ÿ ⁄
Neta»»⁄ ﬁ
/»»ﬂ ‡
net»»· ‰
.»»‰ Â
Ventas»»Â Î
*»»Ï Ì
$num»»Ó Ò
)»»Ò Ú
]»»Ú Û
;»»Û Ù
for
…… 
(
…… 
var
…… 
i
…… 
=
…… 
$num
…… 
;
…… 
i
…… 
<
…… 
figures
…… #
.
……# $
Length
……$ *
;
……* +
i
……, -
++
……- /
)
……/ 0
{
……1 2
summary
……3 :
.
……: ;
Cell
……; ?
(
……? @
i
……@ A
+
……B C
$num
……D E
,
……E F
$num
……G H
)
……H I
.
……I J
Value
……J O
=
……P Q
figures
……R Y
[
……Y Z
i
……Z [
]
……[ \
.
……\ ]
Label
……] b
;
……b c
summary
……d k
.
……k l
Cell
……l p
(
……p q
i
……q r
+
……s t
$num
……u v
,
……v w
$num
……x y
)
……y z
.
……z {
Value……{ Ä
=……Å Ç
Math……É á
.……á à
Round……à ç
(……ç é
figures……é ï
[……ï ñ
i……ñ ó
]……ó ò
.……ò ô
Value……ô û
,……û ü
$num……† °
)……° ¢
;……¢ £
}……§ •
var
   
row
   
=
   
figures
   
.
   
Length
    
+
  ! "
$num
  # $
;
  $ %
string
ÀÀ 
[
ÀÀ 
]
ÀÀ 
header
ÀÀ 
=
ÀÀ 
[
ÀÀ 
$str
ÀÀ  
,
ÀÀ  !
$str
ÀÀ" *
,
ÀÀ* +
$str
ÀÀ, 4
,
ÀÀ4 5
$str
ÀÀ6 =
,
ÀÀ= >
$str
ÀÀ? N
]
ÀÀN O
;
ÀÀO P
for
ÃÃ 
(
ÃÃ 
var
ÃÃ 
c
ÃÃ 
=
ÃÃ 
$num
ÃÃ 
;
ÃÃ 
c
ÃÃ 
<
ÃÃ 
header
ÃÃ "
.
ÃÃ" #
Length
ÃÃ# )
;
ÃÃ) *
c
ÃÃ+ ,
++
ÃÃ, .
)
ÃÃ. /
summary
ÃÃ0 7
.
ÃÃ7 8
Cell
ÃÃ8 <
(
ÃÃ< =
row
ÃÃ= @
,
ÃÃ@ A
c
ÃÃB C
+
ÃÃD E
$num
ÃÃF G
)
ÃÃG H
.
ÃÃH I
Value
ÃÃI N
=
ÃÃO P
header
ÃÃQ W
[
ÃÃW X
c
ÃÃX Y
]
ÃÃY Z
;
ÃÃZ [
foreach
ÕÕ 
(
ÕÕ 
var
ÕÕ 
start
ÕÕ 
in
ÕÕ 

Enumerable
ÕÕ (
.
ÕÕ( )
Range
ÕÕ) .
(
ÕÕ. /
$num
ÕÕ/ 0
,
ÕÕ0 1
month
ÕÕ2 7
is
ÕÕ8 :
null
ÕÕ; ?
?
ÕÕ@ A
$num
ÕÕB D
:
ÕÕE F
$num
ÕÕG H
)
ÕÕH I
.
ÕÕI J
Select
ÕÕJ P
(
ÕÕP Q
i
ÕÕQ R
=>
ÕÕS U
from
ÕÕV Z
.
ÕÕZ [
	AddMonths
ÕÕ[ d
(
ÕÕd e
i
ÕÕe f
)
ÕÕf g
)
ÕÕg h
)
ÕÕh i
{
ŒŒ 	
var
œœ 
end
œœ 
=
œœ 
start
œœ 
.
œœ 
	AddMonths
œœ %
(
œœ% &
$num
œœ& '
)
œœ' (
.
œœ( )
AddDays
œœ) 0
(
œœ0 1
-
œœ1 2
$num
œœ2 3
)
œœ3 4
;
œœ4 5
var
–– 
n
–– 
=
–– 

NetFigures
–– 
(
–– 
sales
–– $
.
––$ %
Where
––% *
(
––* +
x
––+ ,
=>
––- /
x
––0 1
.
––1 2
Date
––2 6
>=
––7 9
start
––: ?
&&
––@ B
x
––C D
.
––D E
Date
––E I
<=
––J L
end
––M P
)
––P Q
,
––Q R
expenses
––S [
.
––[ \
Where
––\ a
(
––a b
x
––b c
=>
––d f
x
––g h
.
––h i
Date
––i m
>=
––n p
start
––q v
&&
––w y
x
––z {
.
––{ |
Date––| Ä
<=––Å É
end––Ñ á
)––á à
,––à â
settings––ä í
.––í ì
	RentaRate––ì ú
)––ú ù
;––ù û
row
—— 
++
—— 
;
—— 
summary
—— 
.
—— 
Cell
—— 
(
——  
row
——  #
,
——# $
$num
——% &
)
——& '
.
——' (
Value
——( -
=
——. /
start
——0 5
.
——5 6
ToString
——6 >
(
——> ?
$str
——? H
)
——H I
;
——I J
summary
““ 
.
““ 
Cell
““ 
(
““ 
row
““ 
,
““ 
$num
““ 
)
““  
.
““  !
Value
““! &
=
““' (
Math
““) -
.
““- .
Round
““. 3
(
““3 4
n
““4 5
.
““5 6
Ventas
““6 <
,
““< =
$num
““> ?
)
““? @
;
““@ A
summary
““B I
.
““I J
Cell
““J N
(
““N O
row
““O R
,
““R S
$num
““T U
)
““U V
.
““V W
Value
““W \
=
““] ^
Math
““_ c
.
““c d
Round
““d i
(
““i j
n
““j k
.
““k l
Gastos
““l r
,
““r s
$num
““t u
)
““u v
;
““v w
summary
““x 
.““ Ä
Cell““Ä Ñ
(““Ñ Ö
row““Ö à
,““à â
$num““ä ã
)““ã å
.““å ç
Value““ç í
=““ì î
Math““ï ô
.““ô ö
Round““ö ü
(““ü †
n““† °
.““° ¢
	Impuestos““¢ ´
,““´ ¨
$num““≠ Æ
)““Æ Ø
;““Ø ∞
summary““± ∏
.““∏ π
Cell““π Ω
(““Ω æ
row““æ ¡
,““¡ ¬
$num““√ ƒ
)““ƒ ≈
.““≈ ∆
Value““∆ À
=““Ã Õ
Math““Œ “
.“““ ”
Round““” ÿ
(““ÿ Ÿ
n““Ÿ ⁄
.““⁄ €
Neta““€ ﬂ
,““ﬂ ‡
$num““· ‚
)““‚ „
;““„ ‰
}
”” 	
summary
‘‘ 
.
‘‘ 
Columns
‘‘ 
(
‘‘ 
)
‘‘ 
.
‘‘ 
AdjustToContents
‘‘ *
(
‘‘* +
)
‘‘+ ,
;
‘‘, -
var
÷÷ 
clients
÷÷ 
=
÷÷ 
book
÷÷ 
.
÷÷ 
AddWorksheet
÷÷ '
(
÷÷' (
$str
÷÷( 2
)
÷÷2 3
;
÷÷3 4
string
◊◊ 
[
◊◊ 
]
◊◊ 
clientHeader
◊◊ 
=
◊◊ 
[
◊◊  !
$str
◊◊! *
,
◊◊* +
$str
◊◊, D
,
◊◊D E
$str
◊◊F S
,
◊◊S T
$str
◊◊U b
,
◊◊b c
$str
◊◊d l
,
◊◊l m
$str
◊◊n |
,
◊◊| }
$str◊◊~ ñ
,◊◊ñ ó
$str◊◊ò •
]◊◊• ¶
;◊◊¶ ß
for
ÿÿ 
(
ÿÿ 
var
ÿÿ 
c
ÿÿ 
=
ÿÿ 
$num
ÿÿ 
;
ÿÿ 
c
ÿÿ 
<
ÿÿ 
clientHeader
ÿÿ (
.
ÿÿ( )
Length
ÿÿ) /
;
ÿÿ/ 0
c
ÿÿ1 2
++
ÿÿ2 4
)
ÿÿ4 5
clients
ÿÿ6 =
.
ÿÿ= >
Cell
ÿÿ> B
(
ÿÿB C
$num
ÿÿC D
,
ÿÿD E
c
ÿÿF G
+
ÿÿH I
$num
ÿÿJ K
)
ÿÿK L
.
ÿÿL M
Value
ÿÿM R
=
ÿÿS T
clientHeader
ÿÿU a
[
ÿÿa b
c
ÿÿb c
]
ÿÿc d
;
ÿÿd e
var
ŸŸ 
r
ŸŸ 
=
ŸŸ 
$num
ŸŸ 
;
ŸŸ 
foreach
⁄⁄ 
(
⁄⁄ 
var
⁄⁄ 
x
⁄⁄ 
in
⁄⁄ 
ranking
⁄⁄ !
)
⁄⁄! "
{
€€ 	
r
‹‹ 
++
‹‹ 
;
‹‹ 
clients
›› 
.
›› 
Cell
›› 
(
›› 
r
›› 
,
›› 
$num
›› 
)
›› 
.
›› 
Value
›› $
=
››% &
x
››' (
.
››( )

ClientName
››) 3
;
››3 4
clients
››5 <
.
››< =
Cell
››= A
(
››A B
r
››B C
,
››C D
$num
››E F
)
››F G
.
››G H
Value
››H M
=
››N O
x
››P Q
.
››Q R
IngresosPen
››R ]
;
››] ^
clients
››_ f
.
››f g
Cell
››g k
(
››k l
r
››l m
,
››m n
$num
››o p
)
››p q
.
››q r
Value
››r w
=
››x y
x
››z {
.
››{ |

Porcentaje››| Ü
;››Ü á
clients››à è
.››è ê
Cell››ê î
(››î ï
r››ï ñ
,››ñ ó
$num››ò ô
)››ô ö
.››ö õ
Value››õ †
=››° ¢
x››£ §
.››§ •#
PorcentajeAcumulado››• ∏
;››∏ π
clients
ﬁﬁ 
.
ﬁﬁ 
Cell
ﬁﬁ 
(
ﬁﬁ 
r
ﬁﬁ 
,
ﬁﬁ 
$num
ﬁﬁ 
)
ﬁﬁ 
.
ﬁﬁ 
Value
ﬁﬁ $
=
ﬁﬁ% &
x
ﬁﬁ' (
.
ﬁﬁ( )
Cobros
ﬁﬁ) /
;
ﬁﬁ/ 0
clients
ﬁﬁ1 8
.
ﬁﬁ8 9
Cell
ﬁﬁ9 =
(
ﬁﬁ= >
r
ﬁﬁ> ?
,
ﬁﬁ? @
$num
ﬁﬁA B
)
ﬁﬁB C
.
ﬁﬁC D
Value
ﬁﬁD I
=
ﬁﬁJ K
x
ﬁﬁL M
.
ﬁﬁM N
UltimoCobro
ﬁﬁN Y
.
ﬁﬁY Z

ToDateTime
ﬁﬁZ d
(
ﬁﬁd e
TimeOnly
ﬁﬁe m
.
ﬁﬁm n
MinValue
ﬁﬁn v
)
ﬁﬁv w
;
ﬁﬁw x
clientsﬁﬁy Ä
.ﬁﬁÄ Å
CellﬁﬁÅ Ö
(ﬁﬁÖ Ü
rﬁﬁÜ á
,ﬁﬁá à
$numﬁﬁâ ä
)ﬁﬁä ã
.ﬁﬁã å
Valueﬁﬁå ë
=ﬁﬁí ì
xﬁﬁî ï
.ﬁﬁï ñ"
PeriodoAnteriorPenﬁﬁñ ®
;ﬁﬁ® ©
if
ﬂﬂ 
(
ﬂﬂ 
x
ﬂﬂ 
.
ﬂﬂ !
VariacionPorcentaje
ﬂﬂ %
is
ﬂﬂ& (
decimal
ﬂﬂ) 0
	variation
ﬂﬂ1 :
)
ﬂﬂ: ;
clients
ﬂﬂ< C
.
ﬂﬂC D
Cell
ﬂﬂD H
(
ﬂﬂH I
r
ﬂﬂI J
,
ﬂﬂJ K
$num
ﬂﬂL M
)
ﬂﬂM N
.
ﬂﬂN O
Value
ﬂﬂO T
=
ﬂﬂU V
	variation
ﬂﬂW `
;
ﬂﬂ` a
}
‡‡ 	
clients
·· 
.
·· 
Column
·· 
(
·· 
$num
·· 
)
·· 
.
·· 
Style
·· 
.
··  

DateFormat
··  *
.
··* +
Format
··+ 1
=
··2 3
$str
··4 @
;
··@ A
clients
··B I
.
··I J
Columns
··J Q
(
··Q R
)
··R S
.
··S T
AdjustToContents
··T d
(
··d e
)
··e f
;
··f g
using
„„ 
var
„„ 
stream
„„ 
=
„„ 
new
„„ 
MemoryStream
„„ +
(
„„+ ,
)
„„, -
;
„„- .
book
„„/ 3
.
„„3 4
SaveAs
„„4 :
(
„„: ;
stream
„„; A
)
„„A B
;
„„B C
return
‰‰ 
File
‰‰ 
(
‰‰ 
stream
‰‰ 
.
‰‰ 
ToArray
‰‰ "
(
‰‰" #
)
‰‰# $
,
‰‰$ %
$str
‰‰& i
,
‰‰i j
month
‰‰k p
is
‰‰q s
int
‰‰t w
m
‰‰x y
?
‰‰z {
$"
‰‰| ~
$str‰‰~ Ü
{‰‰Ü á
year‰‰á ã
}‰‰ã å
$str‰‰å ç
{‰‰ç é
m‰‰é è
:‰‰è ê
$str‰‰ê í
}‰‰í ì
$str‰‰ì ò
"‰‰ò ô
:‰‰ö õ
$"‰‰ú û
$str‰‰û ¶
{‰‰¶ ß
year‰‰ß ´
}‰‰´ ¨
$str‰‰¨ ±
"‰‰± ≤
)‰‰≤ ≥
;‰‰≥ ¥
}
ÂÂ 
[
ÁÁ 
HttpGet
ÁÁ 
(
ÁÁ 
$str
ÁÁ 
)
ÁÁ 
]
ÁÁ 
public
ËË 

async
ËË 
Task
ËË 
<
ËË 
ActionResult
ËË "
>
ËË" #
Clients
ËË$ +
(
ËË+ ,
CancellationToken
ËË, =
ct
ËË> @
)
ËË@ A
=>
ËËB D
Ok
ËËE G
(
ËËG H
await
ËËH M
db
ËËN P
.
ËËP Q
Clients
ËËQ X
.
ËËX Y
OrderBy
ËËY `
(
ËË` a
x
ËËa b
=>
ËËc e
x
ËËf g
.
ËËg h
CompanyName
ËËh s
)
ËËs t
.
ËËt u
Select
ËËu {
(
ËË{ |
x
ËË| }
=>ËË~ Ä
newËËÅ Ñ
{ËËÖ Ü
idËËá â
=ËËä ã
xËËå ç
.ËËç é
IdËËé ê
,ËËê ë
companyNameËËí ù
=ËËû ü
xËË† °
.ËË° ¢
CompanyNameËË¢ ≠
,ËË≠ Æ
isActiveËËØ ∑
=ËË∏ π
xËË∫ ª
.ËËª º
IsActiveËËº ƒ
,ËËƒ ≈#
requiresTaxDocumentËË∆ Ÿ
=ËË⁄ €
xËË‹ ›
.ËË› ﬁ#
RequiresTaxDocumentËËﬁ Ò
,ËËÒ Ú
activeProductsËËÛ Å
=ËËÇ É
dbËËÑ Ü
.ËËÜ á
ClientProductsËËá ï
.ËËï ñ
CountËËñ õ
(ËËõ ú
pËËú ù
=>ËËû †
pËË° ¢
.ËË¢ £
ClientIdËË£ ´
==ËË¨ Æ
xËËØ ∞
.ËË∞ ±
IdËË± ≥
&&ËË¥ ∂
pËË∑ ∏
.ËË∏ π
StatusËËπ ø
==ËË¿ ¬#
ClientProductStatusËË√ ÷
.ËË÷ ◊
ActivoËË◊ ›
)ËË› ﬁ
,ËËﬁ ﬂ 
expiringProductsËË‡ 
=ËËÒ Ú
dbËËÛ ı
.ËËı ˆ
ClientProductsËËˆ Ñ
.ËËÑ Ö
CountËËÖ ä
(ËËä ã
pËËã å
=>ËËç è
pËËê ë
.ËËë í
ClientIdËËí ö
==ËËõ ù
xËËû ü
.ËËü †
IdËË† ¢
&&ËË£ •
pËË¶ ß
.ËËß ®
StatusËË® Æ
==ËËØ ±#
ClientProductStatusËË≤ ≈
.ËË≈ ∆
	PorVencerËË∆ œ
)ËËœ –
,ËË– —
expiredProductsËË“ ·
=ËË‚ „
dbËË‰ Ê
.ËËÊ Á
ClientProductsËËÁ ı
.ËËı ˆ
CountËËˆ ˚
(ËË˚ ¸
pËË¸ ˝
=>ËË˛ Ä
pËËÅ Ç
.ËËÇ É
ClientIdËËÉ ã
==ËËå é
xËËè ê
.ËËê ë
IdËËë ì
&&ËËî ñ
pËËó ò
.ËËò ô
StatusËËô ü
==ËË† ¢#
ClientProductStatusËË£ ∂
.ËË∂ ∑
VencidoËË∑ æ
)ËËæ ø
,ËËø ¿
openTicketsËË¡ Ã
=ËËÕ Œ
dbËËœ —
.ËË— “
TicketsËË“ Ÿ
.ËËŸ ⁄
CountËË⁄ ﬂ
(ËËﬂ ‡
tËË‡ ·
=>ËË‚ ‰
tËËÂ Ê
.ËËÊ Á
ClientIdËËÁ Ô
==ËË Ú
xËËÛ Ù
.ËËÙ ı
IdËËı ˜
&&ËË¯ ˙
(ËË˚ ¸
tËË¸ ˝
.ËË˝ ˛
StatusËË˛ Ñ
==ËËÖ á
TicketStatusËËà î
.ËËî ï
AbiertoËËï ú
||ËËù ü
tËË† °
.ËË° ¢
StatusËË¢ ®
==ËË© ´
TicketStatusËË¨ ∏
.ËË∏ π

EnProgresoËËπ √
)ËË√ ƒ
)ËËƒ ≈
}ËË∆ «
)ËË« »
.ËË» …
ToListAsyncËË… ‘
(ËË‘ ’
ctËË’ ◊
)ËË◊ ÿ
)ËËÿ Ÿ
;ËËŸ ⁄
[
ÍÍ 
HttpGet
ÍÍ 
(
ÍÍ 
$str
ÍÍ  
)
ÍÍ  !
]
ÍÍ! "
public
ÎÎ 

async
ÎÎ 
Task
ÎÎ 
<
ÎÎ 
ActionResult
ÎÎ "
>
ÎÎ" #
Client
ÎÎ$ *
(
ÎÎ* +
Guid
ÎÎ+ /
id
ÎÎ0 2
,
ÎÎ2 3
CancellationToken
ÎÎ4 E
ct
ÎÎF H
)
ÎÎH I
{
ÏÏ 
var
ÌÌ 
client
ÌÌ 
=
ÌÌ 
await
ÌÌ 
db
ÌÌ 
.
ÌÌ 
Clients
ÌÌ %
.
ÌÌ% &
	FindAsync
ÌÌ& /
(
ÌÌ/ 0
[
ÌÌ0 1
id
ÌÌ1 3
]
ÌÌ3 4
,
ÌÌ4 5
ct
ÌÌ6 8
)
ÌÌ8 9
;
ÌÌ9 :
if
ÓÓ 

(
ÓÓ 
client
ÓÓ 
is
ÓÓ 
null
ÓÓ 
)
ÓÓ 
return
ÓÓ "
NotFound
ÓÓ# +
(
ÓÓ+ ,
)
ÓÓ, -
;
ÓÓ- .
var
ÔÔ 
products
ÔÔ 
=
ÔÔ 
await
ÔÔ 
db
ÔÔ 
.
ÔÔ  
ClientProducts
ÔÔ  .
.
ÔÔ. /
Include
ÔÔ/ 6
(
ÔÔ6 7
x
ÔÔ7 8
=>
ÔÔ9 ;
x
ÔÔ< =
.
ÔÔ= >
Product
ÔÔ> E
)
ÔÔE F
.
ÔÔF G
Include
ÔÔG N
(
ÔÔN O
x
ÔÔO P
=>
ÔÔQ S
x
ÔÔT U
.
ÔÔU V
Project
ÔÔV ]
)
ÔÔ] ^
.
ÔÔ^ _
Where
ÔÔ_ d
(
ÔÔd e
x
ÔÔe f
=>
ÔÔg i
x
ÔÔj k
.
ÔÔk l
ClientId
ÔÔl t
==
ÔÔu w
id
ÔÔx z
)
ÔÔz {
.
ÔÔ{ |
ToListAsyncÔÔ| á
(ÔÔá à
ctÔÔà ä
)ÔÔä ã
;ÔÔã å
var
 
igvRate
 
=
 
await
 
db
 
.
 
IgvRateAsync
 +
(
+ ,
ct
, .
)
. /
;
/ 0
return
ÒÒ 
Ok
ÒÒ 
(
ÒÒ 
new
ÒÒ 
{
ÒÒ 
client
ÒÒ 
=
ÒÒ  
	ClientDto
ÒÒ! *
(
ÒÒ* +
client
ÒÒ+ 1
)
ÒÒ1 2
,
ÒÒ2 3
products
ÒÒ4 <
=
ÒÒ= >
products
ÒÒ? G
.
ÒÒG H
Select
ÒÒH N
(
ÒÒN O
x
ÒÒO P
=>
ÒÒQ S
ClientProductDto
ÒÒT d
(
ÒÒd e
x
ÒÒe f
,
ÒÒf g
x
ÒÒh i
.
ÒÒi j
Product
ÒÒj q
is
ÒÒr t
null
ÒÒu y
?
ÒÒz {
$num
ÒÒ| ~
:ÒÒ Ä$
ClientProductPricingÒÒÅ ï
.ÒÒï ñ

IgvRateForÒÒñ †
(ÒÒ† °
clientÒÒ° ß
,ÒÒß ®
xÒÒ© ™
.ÒÒ™ ´
ProductÒÒ´ ≤
,ÒÒ≤ ≥
igvRateÒÒ¥ ª
)ÒÒª º
)ÒÒº Ω
)ÒÒΩ æ
}ÒÒø ¿
)ÒÒ¿ ¡
;ÒÒ¡ ¬
}
ÚÚ 
[
ÙÙ 
HttpPost
ÙÙ 
(
ÙÙ 
$str
ÙÙ 
)
ÙÙ 
]
ÙÙ 
public
ıı 

async
ıı 
Task
ıı 
<
ıı 
ActionResult
ıı "
>
ıı" #
CreateClient
ıı$ 0
(
ıı0 1
ClientRequest
ıı1 >
request
ıı? F
,
ııF G
CancellationToken
ııH Y
ct
ııZ \
)
ıı\ ]
{
ˆˆ 
var
˜˜ 
error
˜˜ 
=
˜˜ 
ValidateClient
˜˜ "
(
˜˜" #
request
˜˜# *
)
˜˜* +
;
˜˜+ ,
if
˜˜- /
(
˜˜0 1
error
˜˜1 6
is
˜˜7 9
not
˜˜: =
null
˜˜> B
)
˜˜B C
return
˜˜D J

BadRequest
˜˜K U
(
˜˜U V
new
˜˜V Y
{
˜˜Z [
message
˜˜\ c
=
˜˜d e
error
˜˜f k
}
˜˜l m
)
˜˜m n
;
˜˜n o
var
¯¯ 
email
¯¯ 
=
¯¯ 
request
¯¯ 
.
¯¯ 
Email
¯¯ !
.
¯¯! "
Trim
¯¯" &
(
¯¯& '
)
¯¯' (
;
¯¯( )
if
˘˘ 

(
˘˘ 
await
˘˘ 
db
˘˘ 
.
˘˘ 
Clients
˘˘ 
.
˘˘ 
AnyAsync
˘˘ %
(
˘˘% &
x
˘˘& '
=>
˘˘( *
x
˘˘+ ,
.
˘˘, -
Email
˘˘- 2
==
˘˘3 5
email
˘˘6 ;
,
˘˘; <
ct
˘˘= ?
)
˘˘? @
||
˘˘A C
await
˘˘D I
db
˘˘J L
.
˘˘L M
UserAccounts
˘˘M Y
.
˘˘Y Z
AnyAsync
˘˘Z b
(
˘˘b c
x
˘˘c d
=>
˘˘e g
x
˘˘h i
.
˘˘i j
Email
˘˘j o
==
˘˘p r
email
˘˘s x
,
˘˘x y
ct
˘˘z |
)
˘˘| }
)
˘˘} ~
return˘˘ Ö
Conflict˘˘Ü é
(˘˘é è
new˘˘è í
{˘˘ì î
message˘˘ï ú
=˘˘ù û
$str˘˘ü Ω
}˘˘æ ø
)˘˘ø ¿
;˘˘¿ ¡
var
˙˙ 
client
˙˙ 
=
˙˙ 
new
˙˙ 
Client
˙˙ 
{
˙˙  !
CompanyName
˙˙" -
=
˙˙. /
request
˙˙0 7
.
˙˙7 8
CompanyName
˙˙8 C
.
˙˙C D
Trim
˙˙D H
(
˙˙H I
)
˙˙I J
,
˙˙J K
ContactName
˙˙L W
=
˙˙X Y
request
˙˙Z a
.
˙˙a b
ContactName
˙˙b m
.
˙˙m n
Trim
˙˙n r
(
˙˙r s
)
˙˙s t
,
˙˙t u
Email
˙˙v {
=
˙˙| }
email˙˙~ É
,˙˙É Ñ
Phone˙˙Ö ä
=˙˙ã å
EmptyToNull˙˙ç ò
(˙˙ò ô
request˙˙ô †
.˙˙† °
Phone˙˙° ¶
)˙˙¶ ß
,˙˙ß ®!
PreferredLanguage˙˙© ∫
=˙˙ª º
request˙˙Ω ƒ
.˙˙ƒ ≈!
PreferredLanguage˙˙≈ ÷
.˙˙÷ ◊
Trim˙˙◊ €
(˙˙€ ‹
)˙˙‹ ›
.˙˙› ﬁ 
ToLowerInvariant˙˙ﬁ Ó
(˙˙Ó Ô
)˙˙Ô 
,˙˙ Ò#
RequiresTaxDocument˙˙Ú Ö
=˙˙Ü á
request˙˙à è
.˙˙è ê#
RequiresTaxDocument˙˙ê £
}˙˙§ •
;˙˙• ¶
db
˚˚ 

.
˚˚
 
Clients
˚˚ 
.
˚˚ 
Add
˚˚ 
(
˚˚ 
client
˚˚ 
)
˚˚ 
;
˚˚ 
var
˝˝ 
access
˝˝ 
=
˝˝ 
AddAdminUser
˝˝ !
(
˝˝! "
client
˝˝" (
)
˝˝( )
;
˝˝) *
await
˛˛ 
db
˛˛ 
.
˛˛ 
SaveChangesAsync
˛˛ !
(
˛˛! "
ct
˛˛" $
)
˛˛$ %
;
˛˛% &
access
ˇˇ 
=
ˇˇ 
await
ˇˇ 
EmailAccessAsync
ˇˇ '
(
ˇˇ' (
client
ˇˇ( .
,
ˇˇ. /
access
ˇˇ0 6
,
ˇˇ6 7
ct
ˇˇ8 :
)
ˇˇ: ;
;
ˇˇ; <
return
ÄÄ 
Created
ÄÄ 
(
ÄÄ 
$"
ÄÄ 
$str
ÄÄ ,
{
ÄÄ, -
client
ÄÄ- 3
.
ÄÄ3 4
Id
ÄÄ4 6
}
ÄÄ6 7
"
ÄÄ7 8
,
ÄÄ8 9
new
ÄÄ: =
{
ÄÄ> ?
client
ÄÄ@ F
=
ÄÄG H
	ClientDto
ÄÄI R
(
ÄÄR S
client
ÄÄS Y
)
ÄÄY Z
,
ÄÄZ [
access
ÄÄ\ b
}
ÄÄc d
)
ÄÄd e
;
ÄÄe f
}
ÅÅ 
[
ÉÉ 
	HttpPatch
ÉÉ 
(
ÉÉ 
$str
ÉÉ "
)
ÉÉ" #
]
ÉÉ# $
public
ÑÑ 

async
ÑÑ 
Task
ÑÑ 
<
ÑÑ 
ActionResult
ÑÑ "
>
ÑÑ" #
UpdateClient
ÑÑ$ 0
(
ÑÑ0 1
Guid
ÑÑ1 5
id
ÑÑ6 8
,
ÑÑ8 9 
ClientPatchRequest
ÑÑ: L
request
ÑÑM T
,
ÑÑT U
CancellationToken
ÑÑV g
ct
ÑÑh j
)
ÑÑj k
{
ÖÖ 
var
ÜÜ 
client
ÜÜ 
=
ÜÜ 
await
ÜÜ 
db
ÜÜ 
.
ÜÜ 
Clients
ÜÜ %
.
ÜÜ% &
	FindAsync
ÜÜ& /
(
ÜÜ/ 0
[
ÜÜ0 1
id
ÜÜ1 3
]
ÜÜ3 4
,
ÜÜ4 5
ct
ÜÜ6 8
)
ÜÜ8 9
;
ÜÜ9 :
if
ÜÜ; =
(
ÜÜ> ?
client
ÜÜ? E
is
ÜÜF H
null
ÜÜI M
)
ÜÜM N
return
ÜÜO U
NotFound
ÜÜV ^
(
ÜÜ^ _
)
ÜÜ_ `
;
ÜÜ` a
if
áá 

(
áá 
request
áá 
.
áá 
CompanyName
áá 
is
áá  "
not
áá# &
null
áá' +
)
áá+ ,
client
áá- 3
.
áá3 4
CompanyName
áá4 ?
=
áá@ A
request
ááB I
.
ááI J
CompanyName
ááJ U
.
ááU V
Trim
ááV Z
(
ááZ [
)
áá[ \
;
áá\ ]
if
àà 

(
àà 
request
àà 
.
àà 
ContactName
àà 
is
àà  "
not
àà# &
null
àà' +
)
àà+ ,
client
àà- 3
.
àà3 4
ContactName
àà4 ?
=
àà@ A
request
ààB I
.
ààI J
ContactName
ààJ U
.
ààU V
Trim
ààV Z
(
ààZ [
)
àà[ \
;
àà\ ]
if
ââ 

(
ââ 
request
ââ 
.
ââ 
Phone
ââ 
is
ââ 
not
ââ  
null
ââ! %
)
ââ% &
client
ââ' -
.
ââ- .
Phone
ââ. 3
=
ââ4 5
EmptyToNull
ââ6 A
(
ââA B
request
ââB I
.
ââI J
Phone
ââJ O
)
ââO P
;
ââP Q
if
ää 

(
ää 
request
ää 
.
ää 
PreferredLanguage
ää %
is
ää& (
not
ää) ,
null
ää- 1
)
ää1 2
{
ää3 4
var
ää5 8
lang
ää9 =
=
ää> ?
request
ää@ G
.
ääG H
PreferredLanguage
ääH Y
.
ääY Z
Trim
ääZ ^
(
ää^ _
)
ää_ `
.
ää` a
ToLowerInvariant
ääa q
(
ääq r
)
äär s
;
ääs t
if
ääu w
(
ääx y
lang
ääy }
isää~ Ä
notääÅ Ñ
(ääÖ Ü
$strääÜ ä
orääã ç
$strääé í
orääì ï
$strääñ ö
)ääö õ
)ääõ ú
returnääù £

BadRequestää§ Æ
(ääÆ Ø
newääØ ≤
{ää≥ ¥
messageääµ º
=ääΩ æ
$strääø —
}ää“ ”
)ää” ‘
;ää‘ ’
clientää÷ ‹
.ää‹ ›!
PreferredLanguageää› Ó
=ääÔ 
langääÒ ı
;ääı ˆ
}ää˜ ¯
if
ãã 

(
ãã 
request
ãã 
.
ãã 
Email
ãã 
is
ãã 
not
ãã  
null
ãã! %
)
ãã% &
{
ãã' (
var
ãã) ,
email
ãã- 2
=
ãã3 4
request
ãã5 <
.
ãã< =
Email
ãã= B
.
ããB C
Trim
ããC G
(
ããG H
)
ããH I
;
ããI J
if
ããK M
(
ããN O
string
ããO U
.
ããU V 
IsNullOrWhiteSpace
ããV h
(
ããh i
email
ããi n
)
ããn o
)
ãão p
return
ããq w

BadRequestããx Ç
(ããÇ É
newããÉ Ü
{ããá à
messageããâ ê
=ããë í
$strããì ≠
}ããÆ Ø
)ããØ ∞
;ãã∞ ±
ifãã≤ ¥
(ããµ ∂
awaitãã∂ ª
dbããº æ
.ããæ ø
Clientsããø ∆
.ãã∆ «
AnyAsyncãã« œ
(ããœ –
xãã– —
=>ãã“ ‘
xãã’ ÷
.ãã÷ ◊
Emailãã◊ ‹
==ãã› ﬂ
emailãã‡ Â
&&ããÊ Ë
xããÈ Í
.ããÍ Î
IdããÎ Ì
!=ããÓ 
idããÒ Û
,ããÛ Ù
ctããı ˜
)ãã˜ ¯
)ãã¯ ˘
returnãã˙ Ä
ConflictããÅ â
(ããâ ä
newããä ç
{ããé è
messageããê ó
=ããò ô
$strããö ∏
}ããπ ∫
)ãã∫ ª
;ããª º
clientããΩ √
.ãã√ ƒ
Emailããƒ …
=ãã  À
emailããÃ —
;ãã— “
}ãã” ‘
if
åå 

(
åå 
request
åå 
.
åå 
IsActive
åå 
is
åå 
bool
åå  $
active
åå% +
)
åå+ ,
client
åå- 3
.
åå3 4
IsActive
åå4 <
=
åå= >
active
åå? E
;
ååE F
if
çç 

(
çç 
request
çç 
.
çç !
RequiresTaxDocument
çç '
is
çç( *
bool
çç+ /
requiresTax
çç0 ;
)
çç; <
client
çç= C
.
ççC D!
RequiresTaxDocument
ççD W
=
ççX Y
requiresTax
ççZ e
;
ççe f
await
éé 
db
éé 
.
éé 
SaveChangesAsync
éé !
(
éé! "
ct
éé" $
)
éé$ %
;
éé% &
return
éé' -
Ok
éé. 0
(
éé0 1
	ClientDto
éé1 :
(
éé: ;
client
éé; A
)
ééA B
)
ééB C
;
ééC D
}
èè 
[
ëë 
HttpGet
ëë 
(
ëë 
$str
ëë &
)
ëë& '
]
ëë' (
public
íí 

IActionResult
íí 
ClientTemplate
íí '
(
íí' (
)
íí( )
=>
íí* ,
File
íí- 1
(
íí1 2
CreateWorkbook
íí2 @
(
íí@ A
new
ìì 
(
ìì 
$str
ìì 
,
ìì 
true
ìì 
,
ìì  
$str
ìì! B
)
ììB C
,
ììC D
new
îî 
(
îî 
$str
îî 
,
îî 
true
îî 
,
îî  
$str
îî! C
)
îîC D
,
îîD E
new
ïï 
(
ïï 
$str
ïï 
,
ïï 
true
ïï 
,
ïï 
$str
ïï s
)
ïïs t
,
ïït u
new
ññ 
(
ññ 
$str
ññ 
,
ññ 
false
ññ 
,
ññ 
$str
ññ >
)
ññ> ?
,
ññ? @
new
óó 
(
óó 
$str
óó 
,
óó  
true
óó! %
,
óó% &
$str
óó' R
,
óóR S
[
óóT U
$str
óóU Y
,
óóY Z
$str
óó[ _
,
óó_ `
$str
óóa e
]
óóe f
)
óóf g
,
óóg h
new
òò 
(
òò 
$str
òò !
,
òò! "
false
òò# (
,
òò( )
$stròò* ã
,òòã å
[òòç é
$stròòé í
,òòí ì
$stròòî ò
]òòò ô
)òòô ö
)òòö õ
,òòõ ú
$str
ôô K
,
ôôK L
$str
ôôM f
)
ôôf g
;
ôôg h
[
õõ 
HttpPost
õõ 
(
õõ 
$str
õõ 
)
õõ 
]
õõ  
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
úú" #
ImportClients
úú$ 1
(
úú1 2
	IFormFile
úú2 ;
file
úú< @
,
úú@ A
CancellationToken
úúB S
ct
úúT V
)
úúV W
{
ùù 
var
ûû 
created_
ûû 
=
ûû 
new
ûû 
List
ûû 
<
ûû  
(
ûû  !
Client
ûû! '
Client
ûû( .
,
ûû. /
ClientAccess
ûû0 <
Access
ûû= C
)
ûûC D
>
ûûD E
(
ûûE F
)
ûûF G
;
ûûG H
var
üü 
(
üü 
failure
üü 
,
üü 
created
üü 
,
üü 
errors
üü %
)
üü% &
=
üü' (
await
üü) .
Import
üü/ 5
(
üü5 6
file
üü6 :
,
üü: ;
$str
üü< F
,
üüF G
async
üüH M
(
üüN O
row
üüO R
,
üüR S
	rowNumber
üüT ]
,
üü] ^
errors
üü_ e
)
üüe f
=>
üüg i
{
†† 	
var
°° 
requiresTax
°° 
=
°° 
	ReadYesNo
°° '
(
°°' (
Cell
°°( ,
(
°°, -
row
°°- 0
,
°°0 1
$num
°°2 3
)
°°3 4
,
°°4 5
defaultValue
°°6 B
:
°°B C
false
°°D I
)
°°I J
;
°°J K
var
¢¢ 
request
¢¢ 
=
¢¢ 
new
¢¢ 
ClientRequest
¢¢ +
(
¢¢+ ,
Cell
¢¢, 0
(
¢¢0 1
row
¢¢1 4
,
¢¢4 5
$num
¢¢6 7
)
¢¢7 8
,
¢¢8 9
Cell
¢¢: >
(
¢¢> ?
row
¢¢? B
,
¢¢B C
$num
¢¢D E
)
¢¢E F
,
¢¢F G
Cell
¢¢H L
(
¢¢L M
row
¢¢M P
,
¢¢P Q
$num
¢¢R S
)
¢¢S T
,
¢¢T U
Cell
¢¢V Z
(
¢¢Z [
row
¢¢[ ^
,
¢¢^ _
$num
¢¢` a
)
¢¢a b
,
¢¢b c
Cell
¢¢d h
(
¢¢h i
row
¢¢i l
,
¢¢l m
$num
¢¢n o
)
¢¢o p
,
¢¢p q
requiresTax
¢¢r }
??¢¢~ Ä
false¢¢Å Ü
)¢¢Ü á
;¢¢á à
var¢¢â å
error¢¢ç í
=¢¢ì î
requiresTax¢¢ï †
is¢¢° £
null¢¢§ ®
?¢¢© ™
$str¢¢´ ◊
:¢¢ÿ Ÿ
ValidateClient¢¢⁄ Ë
(¢¢Ë È
request¢¢È 
)¢¢ Ò
;¢¢Ò Ú
var
££ 
email
££ 
=
££ 
request
££ 
.
££  
Email
££  %
.
££% &
Trim
££& *
(
££* +
)
££+ ,
;
££, -
if
§§ 
(
§§ 
error
§§ 
is
§§ 
not
§§ 
null
§§ !
||
§§" $
await
§§% *
db
§§+ -
.
§§- .
Clients
§§. 5
.
§§5 6
AnyAsync
§§6 >
(
§§> ?
x
§§? @
=>
§§A C
x
§§D E
.
§§E F
Email
§§F K
==
§§L N
email
§§O T
,
§§T U
ct
§§V X
)
§§X Y
||
§§Z \
await
§§] b
db
§§c e
.
§§e f
UserAccounts
§§f r
.
§§r s
AnyAsync
§§s {
(
§§{ |
x
§§| }
=>§§~ Ä
x§§Å Ç
.§§Ç É
Email§§É à
==§§â ã
email§§å ë
,§§ë í
ct§§ì ï
)§§ï ñ
)§§ñ ó
{§§ò ô
errors§§ö †
.§§† °
Add§§° §
(§§§ •
new§§• ®
(§§® ©
	rowNumber§§© ≤
,§§≤ ≥
error§§¥ π
??§§∫ º
$str§§Ω €
)§§€ ‹
)§§‹ ›
;§§› ﬁ
return§§ﬂ Â
false§§Ê Î
;§§Î Ï
}§§Ì Ó
var
•• 
client
•• 
=
•• 
new
•• 
Client
•• #
{
••$ %
CompanyName
••& 1
=
••2 3
request
••4 ;
.
••; <
CompanyName
••< G
.
••G H
Trim
••H L
(
••L M
)
••M N
,
••N O
ContactName
••P [
=
••\ ]
request
••^ e
.
••e f
ContactName
••f q
.
••q r
Trim
••r v
(
••v w
)
••w x
,
••x y
Email
••z 
=••Ä Å
email••Ç á
,••á à
Phone••â é
=••è ê
EmptyToNull••ë ú
(••ú ù
request••ù §
.••§ •
Phone••• ™
)••™ ´
,••´ ¨!
PreferredLanguage••≠ æ
=••ø ¿
request••¡ »
.••» …!
PreferredLanguage••… ⁄
.••⁄ €
Trim••€ ﬂ
(••ﬂ ‡
)••‡ ·
.••· ‚ 
ToLowerInvariant••‚ Ú
(••Ú Û
)••Û Ù
,••Ù ı#
RequiresTaxDocument••ˆ â
=••ä ã
request••å ì
.••ì î#
RequiresTaxDocument••î ß
}••® ©
;••© ™
db
¶¶ 
.
¶¶ 
Clients
¶¶ 
.
¶¶ 
Add
¶¶ 
(
¶¶ 
client
¶¶ !
)
¶¶! "
;
¶¶" #
created_
¶¶$ ,
.
¶¶, -
Add
¶¶- 0
(
¶¶0 1
(
¶¶1 2
client
¶¶2 8
,
¶¶8 9
AddAdminUser
¶¶: F
(
¶¶F G
client
¶¶G M
)
¶¶M N
)
¶¶N O
)
¶¶O P
;
¶¶P Q
return
¶¶R X
true
¶¶Y ]
;
¶¶] ^
}
ßß 	
,
ßß	 

ct
ßß 
)
ßß 
;
ßß 
if
®® 

(
®® 
failure
®® 
is
®® 
not
®® 
null
®® 
)
®®  
return
®®! '
failure
®®( /
;
®®/ 0
var
©© 
accesses
©© 
=
©© 
new
©© 
List
©© 
<
©©  
ClientAccess
©©  ,
>
©©, -
(
©©- .
)
©©. /
;
©©/ 0
foreach
™™ 
(
™™ 
var
™™ 
(
™™ 
client
™™ 
,
™™ 
access
™™ $
)
™™$ %
in
™™& (
created_
™™) 1
)
™™1 2
accesses
™™3 ;
.
™™; <
Add
™™< ?
(
™™? @
await
™™@ E
EmailAccessAsync
™™F V
(
™™V W
client
™™W ]
,
™™] ^
access
™™_ e
,
™™e f
ct
™™g i
)
™™i j
)
™™j k
;
™™k l
return
´´ 
Ok
´´ 
(
´´ 
new
´´ 
{
´´ 
created
´´ 
,
´´  
skipped
´´! (
=
´´) *
errors
´´+ 1
.
´´1 2
Count
´´2 7
,
´´7 8
errors
´´9 ?
,
´´? @
accesses
´´A I
}
´´J K
)
´´K L
;
´´L M
}
¨¨ 
[
≤≤ 
HttpPost
≤≤ 
(
≤≤ 
$str
≤≤ (
)
≤≤( )
]
≤≤) *
public
≥≥ 

async
≥≥ 
Task
≥≥ 
<
≥≥ 
ActionResult
≥≥ "
>
≥≥" #
ClientAccess
≥≥$ 0
(
≥≥0 1
Guid
≥≥1 5
id
≥≥6 8
,
≥≥8 9
CancellationToken
≥≥: K
ct
≥≥L N
)
≥≥N O
{
¥¥ 
var
µµ 
client
µµ 
=
µµ 
await
µµ 
db
µµ 
.
µµ 
Clients
µµ %
.
µµ% &
	FindAsync
µµ& /
(
µµ/ 0
[
µµ0 1
id
µµ1 3
]
µµ3 4
,
µµ4 5
ct
µµ6 8
)
µµ8 9
;
µµ9 :
if
µµ; =
(
µµ> ?
client
µµ? E
is
µµF H
null
µµI M
)
µµM N
return
µµO U
NotFound
µµV ^
(
µµ^ _
)
µµ_ `
;
µµ` a
var
∂∂ 
user
∂∂ 
=
∂∂ 
await
∂∂ 
db
∂∂ 
.
∂∂ 
UserAccounts
∂∂ (
.
∂∂( )"
SingleOrDefaultAsync
∂∂) =
(
∂∂= >
x
∂∂> ?
=>
∂∂@ B
x
∂∂C D
.
∂∂D E
Email
∂∂E J
==
∂∂K M
client
∂∂N T
.
∂∂T U
Email
∂∂U Z
,
∂∂Z [
ct
∂∂\ ^
)
∂∂^ _
;
∂∂_ `
if
∑∑ 

(
∑∑ 
user
∑∑ 
is
∑∑ 
not
∑∑ 
null
∑∑ 
&&
∑∑ 
user
∑∑  $
.
∑∑$ %
ClientId
∑∑% -
!=
∑∑. 0
client
∑∑1 7
.
∑∑7 8
Id
∑∑8 :
)
∑∑: ;
return
∑∑< B
Conflict
∑∑C K
(
∑∑K L
new
∑∑L O
{
∑∑P Q
message
∑∑R Y
=
∑∑Z [
$str∑∑\ ó
}∑∑ò ô
)∑∑ô ö
;∑∑ö õ
ClientAccess
∏∏ 
access
∏∏ 
;
∏∏ 
if
ππ 

(
ππ 
user
ππ 
is
ππ 
null
ππ 
)
ππ 
access
ππ  
=
ππ! "
AddAdminUser
ππ# /
(
ππ/ 0
client
ππ0 6
)
ππ6 7
;
ππ7 8
else
∫∫ 
{
ªª 	
var
ºº 
temporaryPassword
ºº !
=
ºº" #
AccountController
ºº$ 5
.
ºº5 6
TemporaryPassword
ºº6 G
(
ººG H
)
ººH I
;
ººI J
user
ΩΩ 
.
ΩΩ 
PasswordHash
ΩΩ 
=
ΩΩ 
AccountController
ΩΩ  1
.
ΩΩ1 2
Hasher
ΩΩ2 8
.
ΩΩ8 9
HashPassword
ΩΩ9 E
(
ΩΩE F
user
ΩΩF J
,
ΩΩJ K
temporaryPassword
ΩΩL ]
)
ΩΩ] ^
;
ΩΩ^ _
user
ΩΩ` d
.
ΩΩd e
IsActive
ΩΩe m
=
ΩΩn o
true
ΩΩp t
;
ΩΩt u
access
ææ 
=
ææ 
new
ææ 
ClientAccess
ææ %
(
ææ% &
client
ææ& ,
.
ææ, -
CompanyName
ææ- 8
,
ææ8 9
user
ææ: >
.
ææ> ?
Email
ææ? D
,
ææD E
temporaryPassword
ææF W
)
ææW X
;
ææX Y
}
øø 	
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
¡¡ 
Ok
¡¡ 
(
¡¡ 
await
¡¡ 
EmailAccessAsync
¡¡ (
(
¡¡( )
client
¡¡) /
,
¡¡/ 0
access
¡¡1 7
,
¡¡7 8
ct
¡¡9 ;
)
¡¡; <
)
¡¡< =
;
¡¡= >
}
¬¬ 
[
ƒƒ 
HttpPost
ƒƒ 
(
ƒƒ 
$str
ƒƒ 0
)
ƒƒ0 1
]
ƒƒ1 2
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
≈≈" #
CreateProject
≈≈$ 1
(
≈≈1 2
Guid
≈≈2 6
clientId
≈≈7 ?
,
≈≈? @
ProjectRequest
≈≈A O
request
≈≈P W
,
≈≈W X
CancellationToken
≈≈Y j
ct
≈≈k m
)
≈≈m n
{
∆∆ 
if
«« 

(
«« 
!
«« 
await
«« 
db
«« 
.
«« 
Clients
«« 
.
«« 
AnyAsync
«« &
(
««& '
x
««' (
=>
««) +
x
««, -
.
««- .
Id
««. 0
==
««1 3
clientId
««4 <
,
««< =
ct
««> @
)
««@ A
)
««A B
return
««C I
NotFound
««J R
(
««R S
)
««S T
;
««T U
if
»» 

(
»» 
string
»» 
.
»»  
IsNullOrWhiteSpace
»» %
(
»»% &
request
»»& -
.
»»- .
Name
»». 2
)
»»2 3
)
»»3 4
return
»»5 ;

BadRequest
»»< F
(
»»F G
new
»»G J
{
»»K L
message
»»M T
=
»»U V
$str
»»W 
}»»Ä Å
)»»Å Ç
;»»Ç É
var
…… 
slug
…… 
=
…… 
Slugify
…… 
(
…… 
string
…… !
.
……! " 
IsNullOrWhiteSpace
……" 4
(
……4 5
request
……5 <
.
……< =
Slug
……= A
)
……A B
?
……C D
request
……E L
.
……L M
Name
……M Q
:
……R S
request
……T [
.
……[ \
Slug
……\ `
)
……` a
;
……a b
if
   

(
   
slug
   
.
   
Length
   
==
   
$num
   
)
   
return
   $

BadRequest
  % /
(
  / 0
new
  0 3
{
  4 5
message
  6 =
=
  > ?
$str
  @ P
}
  Q R
)
  R S
;
  S T
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
ÀÀ 
Projects
ÀÀ 
.
ÀÀ 
AnyAsync
ÀÀ &
(
ÀÀ& '
x
ÀÀ' (
=>
ÀÀ) +
x
ÀÀ, -
.
ÀÀ- .
Slug
ÀÀ. 2
==
ÀÀ3 5
slug
ÀÀ6 :
,
ÀÀ: ;
ct
ÀÀ< >
)
ÀÀ> ?
)
ÀÀ? @
return
ÀÀA G
Conflict
ÀÀH P
(
ÀÀP Q
new
ÀÀQ T
{
ÀÀU V
message
ÀÀW ^
=
ÀÀ_ `
$"
ÀÀa c
$strÀÀc Ü
{ÀÀÜ á
slugÀÀá ã
}ÀÀã å
$strÀÀå é
"ÀÀé è
}ÀÀê ë
)ÀÀë í
;ÀÀí ì
var
ÃÃ 
project
ÃÃ 
=
ÃÃ 
new
ÃÃ 
Project
ÃÃ !
{
ÃÃ" #
ClientId
ÃÃ$ ,
=
ÃÃ- .
clientId
ÃÃ/ 7
,
ÃÃ7 8
Name
ÃÃ9 =
=
ÃÃ> ?
request
ÃÃ@ G
.
ÃÃG H
Name
ÃÃH L
.
ÃÃL M
Trim
ÃÃM Q
(
ÃÃQ R
)
ÃÃR S
,
ÃÃS T
Slug
ÃÃU Y
=
ÃÃZ [
slug
ÃÃ\ `
}
ÃÃa b
;
ÃÃb c
if
ŒŒ 

(
ŒŒ 
!
ŒŒ 
string
ŒŒ 
.
ŒŒ  
IsNullOrWhiteSpace
ŒŒ &
(
ŒŒ& '
request
ŒŒ' .
.
ŒŒ. /
GithubRepoOwner
ŒŒ/ >
)
ŒŒ> ?
&&
ŒŒ@ B
!
ŒŒC D
string
ŒŒD J
.
ŒŒJ K 
IsNullOrWhiteSpace
ŒŒK ]
(
ŒŒ] ^
request
ŒŒ^ e
.
ŒŒe f
GithubRepoName
ŒŒf t
)
ŒŒt u
)
ŒŒu v
{
œœ 	
var
–– 

repository
–– 
=
–– 
new
––  
ProjectRepository
––! 2
{
––3 4
	ProjectId
––5 >
=
––? @
project
––A H
.
––H I
Id
––I K
,
––K L
Owner
––M R
=
––S T
request
––U \
.
––\ ]
GithubRepoOwner
––] l
.
––l m
Trim
––m q
(
––q r
)
––r s
,
––s t
Name
––u y
=
––z {
request––| É
.––É Ñ
GithubRepoName––Ñ í
.––í ì
Trim––ì ó
(––ó ò
)––ò ô
,––ô ö
	IsDefault––õ §
=––• ¶
true––ß ´
}––¨ ≠
;––≠ Æ
if
—— 
(
—— 
await
—— %
RepositoryConflictAsync
—— -
(
——- .

repository
——. 8
.
——8 9
Owner
——9 >
,
——> ?

repository
——@ J
.
——J K
Name
——K O
,
——O P
null
——Q U
,
——U V
ct
——W Y
)
——Y Z
is
——[ ]
{
——^ _
}
——` a
conflict
——b j
)
——j k
return
——l r
conflict
——s {
;
——{ |
project
““ 
.
““ 
Repositories
““  
.
““  !
Add
““! $
(
““$ %

repository
““% /
)
““/ 0
;
““0 1
}
”” 	
db
‘‘ 

.
‘‘
 
Projects
‘‘ 
.
‘‘ 
Add
‘‘ 
(
‘‘ 
project
‘‘ 
)
‘‘  
;
‘‘  !
await
‘‘" '
db
‘‘( *
.
‘‘* +
SaveChangesAsync
‘‘+ ;
(
‘‘; <
ct
‘‘< >
)
‘‘> ?
;
‘‘? @
return
’’ 
Created
’’ 
(
’’ 
$"
’’ 
$str
’’ -
{
’’- .
project
’’. 5
.
’’5 6
Id
’’6 8
}
’’8 9
"
’’9 :
,
’’: ;

ProjectDto
’’< F
(
’’F G
project
’’G N
)
’’N O
)
’’O P
;
’’P Q
}
÷÷ 
[
ÿÿ 
	HttpPatch
ÿÿ 
(
ÿÿ 
$str
ÿÿ #
)
ÿÿ# $
]
ÿÿ$ %
public
ŸŸ 

async
ŸŸ 
Task
ŸŸ 
<
ŸŸ 
ActionResult
ŸŸ "
>
ŸŸ" #
UpdateProject
ŸŸ$ 1
(
ŸŸ1 2
Guid
ŸŸ2 6
id
ŸŸ7 9
,
ŸŸ9 :
ProjectRequest
ŸŸ; I
request
ŸŸJ Q
,
ŸŸQ R
CancellationToken
ŸŸS d
ct
ŸŸe g
)
ŸŸg h
{
⁄⁄ 
var
€€ 
project
€€ 
=
€€ 
await
€€ 
db
€€ 
.
€€ 
Projects
€€ '
.
€€' (
Include
€€( /
(
€€/ 0
x
€€0 1
=>
€€2 4
x
€€5 6
.
€€6 7
Repositories
€€7 C
)
€€C D
.
€€D E"
SingleOrDefaultAsync
€€E Y
(
€€Y Z
x
€€Z [
=>
€€\ ^
x
€€_ `
.
€€` a
Id
€€a c
==
€€d f
id
€€g i
,
€€i j
ct
€€k m
)
€€m n
;
€€n o
if
€€p r
(
€€s t
project
€€t {
is
€€| ~
null€€ É
)€€É Ñ
return€€Ö ã
NotFound€€å î
(€€î ï
)€€ï ñ
;€€ñ ó
if
‹‹ 

(
‹‹ 
request
‹‹ 
.
‹‹ 
Name
‹‹ 
is
‹‹ 
not
‹‹ 
null
‹‹  $
)
‹‹$ %
{
‹‹& '
if
‹‹( *
(
‹‹+ ,
string
‹‹, 2
.
‹‹2 3 
IsNullOrWhiteSpace
‹‹3 E
(
‹‹E F
request
‹‹F M
.
‹‹M N
Name
‹‹N R
)
‹‹R S
)
‹‹S T
return
‹‹U [

BadRequest
‹‹\ f
(
‹‹f g
new
‹‹g j
{
‹‹k l
message
‹‹m t
=
‹‹u v
$str‹‹w ü
}‹‹† °
)‹‹° ¢
;‹‹¢ £
project‹‹§ ´
.‹‹´ ¨
Name‹‹¨ ∞
=‹‹± ≤
request‹‹≥ ∫
.‹‹∫ ª
Name‹‹ª ø
.‹‹ø ¿
Trim‹‹¿ ƒ
(‹‹ƒ ≈
)‹‹≈ ∆
;‹‹∆ «
}‹‹» …
await
›› 
db
›› 
.
›› 
SaveChangesAsync
›› !
(
››! "
ct
››" $
)
››$ %
;
››% &
return
››' -
Ok
››. 0
(
››0 1

ProjectDto
››1 ;
(
››; <
project
››< C
)
››C D
)
››D E
;
››E F
}
ﬁﬁ 
[
·· 

HttpDelete
·· 
(
·· 
$str
·· $
)
··$ %
]
··% &
public
‚‚ 

async
‚‚ 
Task
‚‚ 
<
‚‚ 
ActionResult
‚‚ "
>
‚‚" #
DeleteProject
‚‚$ 1
(
‚‚1 2
Guid
‚‚2 6
id
‚‚7 9
,
‚‚9 :
CancellationToken
‚‚; L
ct
‚‚M O
)
‚‚O P
{
„„ 
var
‰‰ 
project
‰‰ 
=
‰‰ 
await
‰‰ 
db
‰‰ 
.
‰‰ 
Projects
‰‰ '
.
‰‰' (
Include
‰‰( /
(
‰‰/ 0
x
‰‰0 1
=>
‰‰2 4
x
‰‰5 6
.
‰‰6 7
Repositories
‰‰7 C
)
‰‰C D
.
‰‰D E"
SingleOrDefaultAsync
‰‰E Y
(
‰‰Y Z
x
‰‰Z [
=>
‰‰\ ^
x
‰‰_ `
.
‰‰` a
Id
‰‰a c
==
‰‰d f
id
‰‰g i
,
‰‰i j
ct
‰‰k m
)
‰‰m n
;
‰‰n o
if
‰‰p r
(
‰‰s t
project
‰‰t {
is
‰‰| ~
null‰‰ É
)‰‰É Ñ
return‰‰Ö ã
NotFound‰‰å î
(‰‰î ï
)‰‰ï ñ
;‰‰ñ ó
var
ÂÂ 
products
ÂÂ 
=
ÂÂ 
await
ÂÂ 
db
ÂÂ 
.
ÂÂ  
ClientProducts
ÂÂ  .
.
ÂÂ. /

CountAsync
ÂÂ/ 9
(
ÂÂ9 :
x
ÂÂ: ;
=>
ÂÂ< >
x
ÂÂ? @
.
ÂÂ@ A
	ProjectId
ÂÂA J
==
ÂÂK M
id
ÂÂN P
,
ÂÂP Q
ct
ÂÂR T
)
ÂÂT U
;
ÂÂU V
var
ÊÊ 
tickets
ÊÊ 
=
ÊÊ 
await
ÊÊ 
db
ÊÊ 
.
ÊÊ 
Tickets
ÊÊ &
.
ÊÊ& '

CountAsync
ÊÊ' 1
(
ÊÊ1 2
x
ÊÊ2 3
=>
ÊÊ4 6
x
ÊÊ7 8
.
ÊÊ8 9
	ProjectId
ÊÊ9 B
==
ÊÊC E
id
ÊÊF H
,
ÊÊH I
ct
ÊÊJ L
)
ÊÊL M
;
ÊÊM N
if
ÁÁ 

(
ÁÁ 
products
ÁÁ 
+
ÁÁ 
tickets
ÁÁ 
>
ÁÁ  
$num
ÁÁ! "
)
ÁÁ" #
return
ËË 
Conflict
ËË 
(
ËË 
new
ËË 
{
ËË  !
message
ËË" )
=
ËË* +
$"
ËË, .
$str
ËË. /
{
ËË/ 0
project
ËË0 7
.
ËË7 8
Name
ËË8 <
}
ËË< =
$str
ËË= E
{
ËËE F
Count
ËËF K
(
ËËK L
products
ËËL T
,
ËËT U
$str
ËËV `
,
ËË` a
$str
ËËb m
)
ËËm n
}
ËËn o
{
ËËo p
(
ËËp q
products
ËËq y
>
ËËz {
$num
ËË| }
&&ËË~ Ä
ticketsËËÅ à
>ËËâ ä
$numËËã å
?ËËç é
$strËËè î
:ËËï ñ
$strËËó ô
)ËËô ö
}ËËö õ
{ËËõ ú
CountËËú °
(ËË° ¢
ticketsËË¢ ©
,ËË© ™
$strËË´ ≥
,ËË≥ ¥
$strËËµ æ
)ËËæ ø
}ËËø ¿
$strËË¿ ¬
{ËË¬ √
(ËË√ ƒ
productsËËƒ Ã
>ËËÕ Œ
$numËËœ –
?ËË— “
$strËË” ñ
:ËËó ò
$strËËô Ê
)ËËÊ Á
}ËËÁ Ë
$strËËË È
"ËËÈ Í
}ËËÎ Ï
)ËËÏ Ì
;ËËÌ Ó
db
ÈÈ 

.
ÈÈ
 !
ProjectRepositories
ÈÈ 
.
ÈÈ 
RemoveRange
ÈÈ *
(
ÈÈ* +
project
ÈÈ+ 2
.
ÈÈ2 3
Repositories
ÈÈ3 ?
)
ÈÈ? @
;
ÈÈ@ A
db
ÈÈB D
.
ÈÈD E
Projects
ÈÈE M
.
ÈÈM N
Remove
ÈÈN T
(
ÈÈT U
project
ÈÈU \
)
ÈÈ\ ]
;
ÈÈ] ^
await
ÍÍ 
db
ÍÍ 
.
ÍÍ 
SaveChangesAsync
ÍÍ !
(
ÍÍ! "
ct
ÍÍ" $
)
ÍÍ$ %
;
ÍÍ% &
return
ÍÍ' -
	NoContent
ÍÍ. 7
(
ÍÍ7 8
)
ÍÍ8 9
;
ÍÍ9 :
}
ÎÎ 
private
ÌÌ 
static
ÌÌ 
string
ÌÌ 
Count
ÌÌ 
(
ÌÌ  
int
ÌÌ  #
n
ÌÌ$ %
,
ÌÌ% &
string
ÌÌ' -
one
ÌÌ. 1
,
ÌÌ1 2
string
ÌÌ3 9
many
ÌÌ: >
)
ÌÌ> ?
=>
ÌÌ@ B
n
ÌÌC D
==
ÌÌE G
$num
ÌÌH I
?
ÌÌJ K
$str
ÌÌL N
:
ÌÌO P
n
ÌÌQ R
==
ÌÌS U
$num
ÌÌV W
?
ÌÌX Y
$"
ÌÌZ \
$str
ÌÌ\ ^
{
ÌÌ^ _
one
ÌÌ_ b
}
ÌÌb c
"
ÌÌc d
:
ÌÌe f
$"
ÌÌg i
{
ÌÌi j
n
ÌÌj k
}
ÌÌk l
$str
ÌÌl m
{
ÌÌm n
many
ÌÌn r
}
ÌÌr s
"
ÌÌs t
;
ÌÌt u
[
ÔÔ 
HttpPost
ÔÔ 
(
ÔÔ 
$str
ÔÔ /
)
ÔÔ/ 0
]
ÔÔ0 1
public
 

async
 
Task
 
<
 
ActionResult
 "
>
" #
AddRepository
$ 1
(
1 2
Guid
2 6
id
7 9
,
9 :
RepositoryRequest
; L
request
M T
,
T U
CancellationToken
V g
ct
h j
)
j k
{
ÒÒ 
var
ÚÚ 
project
ÚÚ 
=
ÚÚ 
await
ÚÚ 
db
ÚÚ 
.
ÚÚ 
Projects
ÚÚ '
.
ÚÚ' (
Include
ÚÚ( /
(
ÚÚ/ 0
x
ÚÚ0 1
=>
ÚÚ2 4
x
ÚÚ5 6
.
ÚÚ6 7
Repositories
ÚÚ7 C
)
ÚÚC D
.
ÚÚD E"
SingleOrDefaultAsync
ÚÚE Y
(
ÚÚY Z
x
ÚÚZ [
=>
ÚÚ\ ^
x
ÚÚ_ `
.
ÚÚ` a
Id
ÚÚa c
==
ÚÚd f
id
ÚÚg i
,
ÚÚi j
ct
ÚÚk m
)
ÚÚm n
;
ÚÚn o
if
ÚÚp r
(
ÚÚs t
project
ÚÚt {
is
ÚÚ| ~
nullÚÚ É
)ÚÚÉ Ñ
returnÚÚÖ ã
NotFoundÚÚå î
(ÚÚî ï
)ÚÚï ñ
;ÚÚñ ó
if
ÛÛ 

(
ÛÛ 
string
ÛÛ 
.
ÛÛ  
IsNullOrWhiteSpace
ÛÛ %
(
ÛÛ% &
request
ÛÛ& -
.
ÛÛ- .
Owner
ÛÛ. 3
)
ÛÛ3 4
||
ÛÛ5 7
string
ÛÛ8 >
.
ÛÛ> ? 
IsNullOrWhiteSpace
ÛÛ? Q
(
ÛÛQ R
request
ÛÛR Y
.
ÛÛY Z
Name
ÛÛZ ^
)
ÛÛ^ _
)
ÛÛ_ `
return
ÛÛa g

BadRequest
ÛÛh r
(
ÛÛr s
new
ÛÛs v
{
ÛÛw x
messageÛÛy Ä
=ÛÛÅ Ç
$strÛÛÉ ±
}ÛÛ≤ ≥
)ÛÛ≥ ¥
;ÛÛ¥ µ
var
ÙÙ 

repository
ÙÙ 
=
ÙÙ 
new
ÙÙ 
ProjectRepository
ÙÙ .
{
ÙÙ/ 0
	ProjectId
ÙÙ1 :
=
ÙÙ; <
id
ÙÙ= ?
,
ÙÙ? @
Owner
ÙÙA F
=
ÙÙG H
request
ÙÙI P
.
ÙÙP Q
Owner
ÙÙQ V
.
ÙÙV W
Trim
ÙÙW [
(
ÙÙ[ \
)
ÙÙ\ ]
,
ÙÙ] ^
Name
ÙÙ_ c
=
ÙÙd e
request
ÙÙf m
.
ÙÙm n
Name
ÙÙn r
.
ÙÙr s
Trim
ÙÙs w
(
ÙÙw x
)
ÙÙx y
,
ÙÙy z
LabelÙÙ{ Ä
=ÙÙÅ Ç
EmptyToNullÙÙÉ é
(ÙÙé è
requestÙÙè ñ
.ÙÙñ ó
LabelÙÙó ú
)ÙÙú ù
,ÙÙù û
	IsDefaultÙÙü ®
=ÙÙ© ™
projectÙÙ´ ≤
.ÙÙ≤ ≥
RepositoriesÙÙ≥ ø
.ÙÙø ¿
CountÙÙ¿ ≈
==ÙÙ∆ »
$numÙÙ…  
||ÙÙÀ Õ
requestÙÙŒ ’
.ÙÙ’ ÷
	IsDefaultÙÙ÷ ﬂ
==ÙÙ‡ ‚
trueÙÙ„ Á
}ÙÙË È
;ÙÙÈ Í
if
ıı 

(
ıı 
await
ıı %
RepositoryConflictAsync
ıı )
(
ıı) *

repository
ıı* 4
.
ıı4 5
Owner
ıı5 :
,
ıı: ;

repository
ıı< F
.
ııF G
Name
ııG K
,
ııK L
null
ııM Q
,
ııQ R
ct
ııS U
)
ııU V
is
ııW Y
{
ııZ [
}
ıı\ ]
conflict
ıı^ f
)
ııf g
return
ııh n
conflict
ııo w
;
ııw x
if
ˆˆ 

(
ˆˆ 

repository
ˆˆ 
.
ˆˆ 
	IsDefault
ˆˆ  
)
ˆˆ  !
foreach
ˆˆ" )
(
ˆˆ* +
var
ˆˆ+ .
other
ˆˆ/ 4
in
ˆˆ5 7
project
ˆˆ8 ?
.
ˆˆ? @
Repositories
ˆˆ@ L
)
ˆˆL M
other
ˆˆN S
.
ˆˆS T
	IsDefault
ˆˆT ]
=
ˆˆ^ _
false
ˆˆ` e
;
ˆˆe f
db
˜˜ 

.
˜˜
 !
ProjectRepositories
˜˜ 
.
˜˜ 
Add
˜˜ "
(
˜˜" #

repository
˜˜# -
)
˜˜- .
;
˜˜. /
project
˜˜0 7
.
˜˜7 8
Repositories
˜˜8 D
.
˜˜D E
Add
˜˜E H
(
˜˜H I

repository
˜˜I S
)
˜˜S T
;
˜˜T U
await
˜˜V [
db
˜˜\ ^
.
˜˜^ _
SaveChangesAsync
˜˜_ o
(
˜˜o p
ct
˜˜p r
)
˜˜r s
;
˜˜s t
return
¯¯ 
Ok
¯¯ 
(
¯¯ 

ProjectDto
¯¯ 
(
¯¯ 
project
¯¯ $
)
¯¯$ %
)
¯¯% &
;
¯¯& '
}
˘˘ 
[
˚˚ 
	HttpPatch
˚˚ 
(
˚˚ 
$str
˚˚ '
)
˚˚' (
]
˚˚( )
public
¸¸ 

async
¸¸ 
Task
¸¸ 
<
¸¸ 
ActionResult
¸¸ "
>
¸¸" #
UpdateRepository
¸¸$ 4
(
¸¸4 5
Guid
¸¸5 9
id
¸¸: <
,
¸¸< =
RepositoryRequest
¸¸> O
request
¸¸P W
,
¸¸W X
CancellationToken
¸¸Y j
ct
¸¸k m
)
¸¸m n
{
˝˝ 
var
˛˛ 

repository
˛˛ 
=
˛˛ 
await
˛˛ 
db
˛˛ !
.
˛˛! "!
ProjectRepositories
˛˛" 5
.
˛˛5 6
	FindAsync
˛˛6 ?
(
˛˛? @
[
˛˛@ A
id
˛˛A C
]
˛˛C D
,
˛˛D E
ct
˛˛F H
)
˛˛H I
;
˛˛I J
if
˛˛K M
(
˛˛N O

repository
˛˛O Y
is
˛˛Z \
null
˛˛] a
)
˛˛a b
return
˛˛c i
NotFound
˛˛j r
(
˛˛r s
)
˛˛s t
;
˛˛t u
var
ˇˇ 
project
ˇˇ 
=
ˇˇ 
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
Projects
ˇˇ '
.
ˇˇ' (
Include
ˇˇ( /
(
ˇˇ/ 0
x
ˇˇ0 1
=>
ˇˇ2 4
x
ˇˇ5 6
.
ˇˇ6 7
Repositories
ˇˇ7 C
)
ˇˇC D
.
ˇˇD E
SingleAsync
ˇˇE P
(
ˇˇP Q
x
ˇˇQ R
=>
ˇˇS U
x
ˇˇV W
.
ˇˇW X
Id
ˇˇX Z
==
ˇˇ[ ]

repository
ˇˇ^ h
.
ˇˇh i
	ProjectId
ˇˇi r
,
ˇˇr s
ct
ˇˇt v
)
ˇˇv w
;
ˇˇw x
var
ÄÄ 
owner
ÄÄ 
=
ÄÄ 
request
ÄÄ 
.
ÄÄ 
Owner
ÄÄ !
?
ÄÄ! "
.
ÄÄ" #
Trim
ÄÄ# '
(
ÄÄ' (
)
ÄÄ( )
??
ÄÄ* ,

repository
ÄÄ- 7
.
ÄÄ7 8
Owner
ÄÄ8 =
;
ÄÄ= >
var
ÄÄ? B
name
ÄÄC G
=
ÄÄH I
request
ÄÄJ Q
.
ÄÄQ R
Name
ÄÄR V
?
ÄÄV W
.
ÄÄW X
Trim
ÄÄX \
(
ÄÄ\ ]
)
ÄÄ] ^
??
ÄÄ_ a

repository
ÄÄb l
.
ÄÄl m
Name
ÄÄm q
;
ÄÄq r
if
ÅÅ 

(
ÅÅ 
owner
ÅÅ 
.
ÅÅ 
Length
ÅÅ 
==
ÅÅ 
$num
ÅÅ 
||
ÅÅ  
name
ÅÅ! %
.
ÅÅ% &
Length
ÅÅ& ,
==
ÅÅ- /
$num
ÅÅ0 1
)
ÅÅ1 2
return
ÅÅ3 9

BadRequest
ÅÅ: D
(
ÅÅD E
new
ÅÅE H
{
ÅÅI J
message
ÅÅK R
=
ÅÅS T
$strÅÅU É
}ÅÅÑ Ö
)ÅÅÖ Ü
;ÅÅÜ á
if
ÉÉ 

(
ÉÉ 
(
ÉÉ 
owner
ÉÉ 
!=
ÉÉ 

repository
ÉÉ  
.
ÉÉ  !
Owner
ÉÉ! &
||
ÉÉ' )
name
ÉÉ* .
!=
ÉÉ/ 1

repository
ÉÉ2 <
.
ÉÉ< =
Name
ÉÉ= A
)
ÉÉA B
&&
ÉÉC E
await
ÉÉF K
db
ÉÉL N
.
ÉÉN O
Tickets
ÉÉO V
.
ÉÉV W
AnyAsync
ÉÉW _
(
ÉÉ_ `
x
ÉÉ` a
=>
ÉÉb d
x
ÉÉe f
.
ÉÉf g
RepositoryId
ÉÉg s
==
ÉÉt v
id
ÉÉw y
&&
ÉÉz |
x
ÉÉ} ~
.
ÉÉ~  
GithubIssueNumberÉÉ ê
!=ÉÉë ì
nullÉÉî ò
,ÉÉò ô
ctÉÉö ú
)ÉÉú ù
)ÉÉù û
return
ÑÑ 
Conflict
ÑÑ 
(
ÑÑ 
new
ÑÑ 
{
ÑÑ  !
message
ÑÑ" )
=
ÑÑ* +
$strÑÑ, Ä
}ÑÑÅ Ç
)ÑÑÇ É
;ÑÑÉ Ñ
if
ÖÖ 

(
ÖÖ 
await
ÖÖ %
RepositoryConflictAsync
ÖÖ )
(
ÖÖ) *
owner
ÖÖ* /
,
ÖÖ/ 0
name
ÖÖ1 5
,
ÖÖ5 6
id
ÖÖ7 9
,
ÖÖ9 :
ct
ÖÖ; =
)
ÖÖ= >
is
ÖÖ? A
{
ÖÖB C
}
ÖÖD E
conflict
ÖÖF N
)
ÖÖN O
return
ÖÖP V
conflict
ÖÖW _
;
ÖÖ_ `

repository
ÜÜ 
.
ÜÜ 
Owner
ÜÜ 
=
ÜÜ 
owner
ÜÜ  
;
ÜÜ  !

repository
ÜÜ" ,
.
ÜÜ, -
Name
ÜÜ- 1
=
ÜÜ2 3
name
ÜÜ4 8
;
ÜÜ8 9
if
áá 

(
áá 
request
áá 
.
áá 
Label
áá 
is
áá 
not
áá  
null
áá! %
)
áá% &

repository
áá' 1
.
áá1 2
Label
áá2 7
=
áá8 9
EmptyToNull
áá: E
(
ááE F
request
ááF M
.
ááM N
Label
ááN S
)
ááS T
;
ááT U
if
àà 

(
àà 
request
àà 
.
àà 
	IsDefault
àà 
==
àà  
true
àà! %
)
àà% &
foreach
àà' .
(
àà/ 0
var
àà0 3
other
àà4 9
in
àà: <
project
àà= D
.
ààD E
Repositories
ààE Q
)
ààQ R
other
ààS X
.
ààX Y
	IsDefault
ààY b
=
ààc d
other
ààe j
.
ààj k
Id
ààk m
==
ààn p
id
ààq s
;
ààs t
await
ââ 
db
ââ 
.
ââ 
SaveChangesAsync
ââ !
(
ââ! "
ct
ââ" $
)
ââ$ %
;
ââ% &
return
ââ' -
Ok
ââ. 0
(
ââ0 1

ProjectDto
ââ1 ;
(
ââ; <
project
ââ< C
)
ââC D
)
ââD E
;
ââE F
}
ää 
[
åå 

HttpDelete
åå 
(
åå 
$str
åå (
)
åå( )
]
åå) *
public
çç 

async
çç 
Task
çç 
<
çç 
ActionResult
çç "
>
çç" #
DeleteRepository
çç$ 4
(
çç4 5
Guid
çç5 9
id
çç: <
,
çç< =
CancellationToken
çç> O
ct
ççP R
)
ççR S
{
éé 
var
èè 

repository
èè 
=
èè 
await
èè 
db
èè !
.
èè! "!
ProjectRepositories
èè" 5
.
èè5 6
	FindAsync
èè6 ?
(
èè? @
[
èè@ A
id
èèA C
]
èèC D
,
èèD E
ct
èèF H
)
èèH I
;
èèI J
if
èèK M
(
èèN O

repository
èèO Y
is
èèZ \
null
èè] a
)
èèa b
return
èèc i
NotFound
èèj r
(
èèr s
)
èès t
;
èèt u
if
êê 

(
êê 
await
êê 
db
êê 
.
êê 
Tickets
êê 
.
êê 
AnyAsync
êê %
(
êê% &
x
êê& '
=>
êê( *
x
êê+ ,
.
êê, -
RepositoryId
êê- 9
==
êê: <
id
êê= ?
,
êê? @
ct
êêA C
)
êêC D
)
êêD E
return
êêF L
Conflict
êêM U
(
êêU V
new
êêV Y
{
êêZ [
message
êê\ c
=
êêd e
$strêêf £
}êê§ •
)êê• ¶
;êê¶ ß
var
ëë 
project
ëë 
=
ëë 
await
ëë 
db
ëë 
.
ëë 
Projects
ëë '
.
ëë' (
Include
ëë( /
(
ëë/ 0
x
ëë0 1
=>
ëë2 4
x
ëë5 6
.
ëë6 7
Repositories
ëë7 C
)
ëëC D
.
ëëD E
SingleAsync
ëëE P
(
ëëP Q
x
ëëQ R
=>
ëëS U
x
ëëV W
.
ëëW X
Id
ëëX Z
==
ëë[ ]

repository
ëë^ h
.
ëëh i
	ProjectId
ëëi r
,
ëër s
ct
ëët v
)
ëëv w
;
ëëw x
project
íí 
.
íí 
Repositories
íí 
.
íí 
Remove
íí #
(
íí# $

repository
íí$ .
)
íí. /
;
íí/ 0
db
íí1 3
.
íí3 4!
ProjectRepositories
íí4 G
.
ííG H
Remove
ííH N
(
ííN O

repository
ííO Y
)
ííY Z
;
ííZ [
if
ìì 

(
ìì 

repository
ìì 
.
ìì 
	IsDefault
ìì  
&&
ìì! #
project
ìì$ +
.
ìì+ ,
Repositories
ìì, 8
.
ìì8 9
FirstOrDefault
ìì9 G
(
ììG H
)
ììH I
is
ììJ L
{
ììM N
}
ììO P
next
ììQ U
)
ììU V
next
ììW [
.
ìì[ \
	IsDefault
ìì\ e
=
ììf g
true
ììh l
;
ììl m
await
îî 
db
îî 
.
îî 
SaveChangesAsync
îî !
(
îî! "
ct
îî" $
)
îî$ %
;
îî% &
return
îî' -
Ok
îî. 0
(
îî0 1

ProjectDto
îî1 ;
(
îî; <
project
îî< C
)
îîC D
)
îîD E
;
îîE F
}
ïï 
private
óó 
async
óó 
Task
óó 
<
óó 
ActionResult
óó #
?
óó# $
>
óó$ %%
RepositoryConflictAsync
óó& =
(
óó= >
string
óó> D
owner
óóE J
,
óóJ K
string
óóL R
name
óóS W
,
óóW X
Guid
óóY ]
?
óó] ^
exceptId
óó_ g
,
óóg h
CancellationToken
óói z
ct
óó{ }
)
óó} ~
=>óó Å
await
òò 
db
òò 
.
òò !
ProjectRepositories
òò $
.
òò$ %
AnyAsync
òò% -
(
òò- .
x
òò. /
=>
òò0 2
x
òò3 4
.
òò4 5
Owner
òò5 :
==
òò; =
owner
òò> C
&&
òòD F
x
òòG H
.
òòH I
Name
òòI M
==
òòN P
name
òòQ U
&&
òòV X
x
òòY Z
.
òòZ [
Id
òò[ ]
!=
òò^ `
exceptId
òòa i
,
òòi j
ct
òòk m
)
òòm n
?
ôô 
Conflict
ôô 
(
ôô 
new
ôô 
{
ôô 
message
ôô $
=
ôô% &
$"
ôô' )
$str
ôô) 8
{
ôô8 9
owner
ôô9 >
}
ôô> ?
$str
ôô? @
{
ôô@ A
name
ôôA E
}
ôôE F
$str
ôôF f
"
ôôf g
}
ôôh i
)
ôôi j
:
ôôk l
null
ôôm q
;
ôôq r
private
úú 
async
úú 
Task
úú 
<
úú 
ClientAccess
úú #
>
úú# $
EmailAccessAsync
úú% 5
(
úú5 6
Client
úú6 <
client
úú= C
,
úúC D
ClientAccess
úúE Q
access
úúR X
,
úúX Y
CancellationToken
úúZ k
ct
úúl n
)
úún o
=>
úúp r
access
ùù 
with
ùù 
{
ùù 
	EmailSent
ùù 
=
ùù  !
await
ùù" '
accessEmail
ùù( 3
.
ùù3 4
	SendAsync
ùù4 =
(
ùù= >
client
ùù> D
,
ùùD E
client
ùùF L
.
ùùL M
ContactName
ùùM X
,
ùùX Y
access
ùùZ `
.
ùù` a
Email
ùùa f
,
ùùf g
access
ùùh n
.
ùùn o 
TemporaryPasswordùùo Ä
,ùùÄ Å
RequestùùÇ â
,ùùâ ä
ctùùã ç
)ùùç é
}ùùè ê
;ùùê ë
private
üü 
ClientAccess
üü 
AddAdminUser
üü %
(
üü% &
Client
üü& ,
client
üü- 3
)
üü3 4
{
†† 
var
°° 
temporaryPassword
°° 
=
°° 
AccountController
°°  1
.
°°1 2
TemporaryPassword
°°2 C
(
°°C D
)
°°D E
;
°°E F
var
¢¢ 
user
¢¢ 
=
¢¢ 
new
¢¢ 
UserAccount
¢¢ "
{
¢¢# $
ClientId
¢¢% -
=
¢¢. /
client
¢¢0 6
.
¢¢6 7
Id
¢¢7 9
,
¢¢9 :
Name
¢¢; ?
=
¢¢@ A
client
¢¢B H
.
¢¢H I
ContactName
¢¢I T
,
¢¢T U
Email
¢¢V [
=
¢¢\ ]
client
¢¢^ d
.
¢¢d e
Email
¢¢e j
,
¢¢j k
Role
¢¢l p
=
¢¢q r
UserRole
¢¢s {
.
¢¢{ |
Admin¢¢| Å
}¢¢Ç É
;¢¢É Ñ
user
££ 
.
££ 
PasswordHash
££ 
=
££ 
AccountController
££ -
.
££- .
Hasher
££. 4
.
££4 5
HashPassword
££5 A
(
££A B
user
££B F
,
££F G
temporaryPassword
££H Y
)
££Y Z
;
££Z [
db
§§ 

.
§§
 
UserAccounts
§§ 
.
§§ 
Add
§§ 
(
§§ 
user
§§  
)
§§  !
;
§§! "
return
•• 
new
•• 
ClientAccess
•• 
(
••  
client
••  &
.
••& '
CompanyName
••' 2
,
••2 3
user
••4 8
.
••8 9
Email
••9 >
,
••> ?
temporaryPassword
••@ Q
)
••Q R
;
••R S
}
¶¶ 
internal
®® 
static
®® 
string
®® 
Slugify
®® "
(
®®" #
string
®®# )
value
®®* /
)
®®/ 0
{
©© 
var
™™ 

normalized
™™ 
=
™™ 
value
™™ 
.
™™ 
Trim
™™ #
(
™™# $
)
™™$ %
.
™™% &
ToLowerInvariant
™™& 6
(
™™6 7
)
™™7 8
.
™™8 9
	Normalize
™™9 B
(
™™B C
System
™™C I
.
™™I J
Text
™™J N
.
™™N O
NormalizationForm
™™O `
.
™™` a
FormD
™™a f
)
™™f g
;
™™g h
var
´´ 
chars
´´ 
=
´´ 

normalized
´´ 
.
´´ 
Where
´´ $
(
´´$ %
c
´´% &
=>
´´' )
System
´´* 0
.
´´0 1
Globalization
´´1 >
.
´´> ?
CharUnicodeInfo
´´? N
.
´´N O 
GetUnicodeCategory
´´O a
(
´´a b
c
´´b c
)
´´c d
!=
´´e g
System
´´h n
.
´´n o
Globalization
´´o |
.
´´| }
UnicodeCategory´´} å
.´´å ç
NonSpacingMark´´ç õ
)´´õ ú
.´´ú ù
Select´´ù £
(´´£ §
c´´§ •
=>´´¶ ®
char´´© ≠
.´´≠ Æ
IsLetterOrDigit´´Æ Ω
(´´Ω æ
c´´æ ø
)´´ø ¿
?´´¡ ¬
c´´√ ƒ
:´´≈ ∆
$char´´«  
)´´  À
;´´À Ã
return
¨¨ 
System
¨¨ 
.
¨¨ 
Text
¨¨ 
.
¨¨  
RegularExpressions
¨¨ -
.
¨¨- .
Regex
¨¨. 3
.
¨¨3 4
Replace
¨¨4 ;
(
¨¨; <
new
¨¨< ?
string
¨¨@ F
(
¨¨F G
chars
¨¨G L
.
¨¨L M
ToArray
¨¨M T
(
¨¨T U
)
¨¨U V
)
¨¨V W
,
¨¨W X
$str
¨¨Y `
,
¨¨` a
$str
¨¨b e
)
¨¨e f
.
¨¨f g
Trim
¨¨g k
(
¨¨k l
$char
¨¨l o
)
¨¨o p
;
¨¨p q
}
≠≠ 
[
ØØ 
HttpGet
ØØ 
(
ØØ 
$str
ØØ 
)
ØØ 
]
ØØ 
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
∞∞" #
Products
∞∞$ ,
(
∞∞, -
CancellationToken
∞∞- >
ct
∞∞? A
)
∞∞A B
=>
∞∞C E
Ok
∞∞F H
(
∞∞H I
(
∞∞I J
await
∞∞J O
db
∞∞P R
.
∞∞R S
Products
∞∞S [
.
∞∞[ \
OrderBy
∞∞\ c
(
∞∞c d
x
∞∞d e
=>
∞∞f h
x
∞∞i j
.
∞∞j k
Name
∞∞k o
)
∞∞o p
.
∞∞p q
ToListAsync
∞∞q |
(
∞∞| }
ct
∞∞} 
)∞∞ Ä
)∞∞Ä Å
.∞∞Å Ç
Select∞∞Ç à
(∞∞à â

ProductDto∞∞â ì
)∞∞ì î
)∞∞î ï
;∞∞ï ñ
[
≤≤ 
HttpPost
≤≤ 
(
≤≤ 
$str
≤≤ 
)
≤≤ 
]
≤≤ 
public
≥≥ 

async
≥≥ 
Task
≥≥ 
<
≥≥ 
ActionResult
≥≥ "
>
≥≥" #
CreateProduct
≥≥$ 1
(
≥≥1 2
ProductRequest
≥≥2 @
request
≥≥A H
,
≥≥H I
CancellationToken
≥≥J [
ct
≥≥\ ^
)
≥≥^ _
{
¥¥ 
var
µµ 
error
µµ 
=
µµ 
ValidateProduct
µµ #
(
µµ# $
request
µµ$ +
)
µµ+ ,
;
µµ, -
if
µµ. 0
(
µµ1 2
error
µµ2 7
is
µµ8 :
not
µµ; >
null
µµ? C
)
µµC D
return
µµE K

BadRequest
µµL V
(
µµV W
new
µµW Z
{
µµ[ \
message
µµ] d
=
µµe f
error
µµg l
}
µµm n
)
µµn o
;
µµo p
var
∂∂ 
product
∂∂ 
=
∂∂ 
	ToProduct
∂∂ 
(
∂∂  
request
∂∂  '
)
∂∂' (
;
∂∂( )
db
∂∂* ,
.
∂∂, -
Products
∂∂- 5
.
∂∂5 6
Add
∂∂6 9
(
∂∂9 :
product
∂∂: A
)
∂∂A B
;
∂∂B C
await
∂∂D I(
EnsureProductCategoryAsync
∂∂J d
(
∂∂d e
product
∂∂e l
.
∂∂l m
Category
∂∂m u
,
∂∂u v
ct
∂∂w y
)
∂∂y z
;
∂∂z {
await∂∂| Å
db∂∂Ç Ñ
.∂∂Ñ Ö 
SaveChangesAsync∂∂Ö ï
(∂∂ï ñ
ct∂∂ñ ò
)∂∂ò ô
;∂∂ô ö
return∂∂õ °
Created∂∂¢ ©
(∂∂© ™
$"∂∂™ ¨
$str∂∂¨ ¿
{∂∂¿ ¡
product∂∂¡ »
.∂∂» …
Id∂∂… À
}∂∂À Ã
"∂∂Ã Õ
,∂∂Õ Œ

ProductDto∂∂œ Ÿ
(∂∂Ÿ ⁄
product∂∂⁄ ·
)∂∂· ‚
)∂∂‚ „
;∂∂„ ‰
}
∑∑ 
[
ππ 
	HttpPatch
ππ 
(
ππ 
$str
ππ #
)
ππ# $
]
ππ$ %
public
∫∫ 

async
∫∫ 
Task
∫∫ 
<
∫∫ 
ActionResult
∫∫ "
>
∫∫" #
UpdateProduct
∫∫$ 1
(
∫∫1 2
Guid
∫∫2 6
id
∫∫7 9
,
∫∫9 :!
ProductPatchRequest
∫∫; N
request
∫∫O V
,
∫∫V W
CancellationToken
∫∫X i
ct
∫∫j l
)
∫∫l m
{
ªª 
var
ºº 
product
ºº 
=
ºº 
await
ºº 
db
ºº 
.
ºº 
Products
ºº '
.
ºº' (
	FindAsync
ºº( 1
(
ºº1 2
[
ºº2 3
id
ºº3 5
]
ºº5 6
,
ºº6 7
ct
ºº8 :
)
ºº: ;
;
ºº; <
if
ºº= ?
(
ºº@ A
product
ººA H
is
ººI K
null
ººL P
)
ººP Q
return
ººR X
NotFound
ººY a
(
ººa b
)
ººb c
;
ººc d
if
ΩΩ 

(
ΩΩ 
request
ΩΩ 
.
ΩΩ 
Type
ΩΩ 
is
ΩΩ 
ProductType
ΩΩ '
type
ΩΩ( ,
)
ΩΩ, -
product
ΩΩ. 5
.
ΩΩ5 6
Type
ΩΩ6 :
=
ΩΩ; <
type
ΩΩ= A
;
ΩΩA B
if
ΩΩC E
(
ΩΩF G
request
ΩΩG N
.
ΩΩN O
Name
ΩΩO S
is
ΩΩT V
not
ΩΩW Z
null
ΩΩ[ _
)
ΩΩ_ `
product
ΩΩa h
.
ΩΩh i
Name
ΩΩi m
=
ΩΩn o
request
ΩΩp w
.
ΩΩw x
Name
ΩΩx |
.
ΩΩ| }
TrimΩΩ} Å
(ΩΩÅ Ç
)ΩΩÇ É
;ΩΩÉ Ñ
ifΩΩÖ á
(ΩΩà â
requestΩΩâ ê
.ΩΩê ë
BillingCycleΩΩë ù
isΩΩû †
BillingCycleΩΩ° ≠
cycleΩΩÆ ≥
)ΩΩ≥ ¥
productΩΩµ º
.ΩΩº Ω
BillingCycleΩΩΩ …
=ΩΩ  À
cycleΩΩÃ —
;ΩΩ— “
ifΩΩ” ’
(ΩΩ÷ ◊
requestΩΩ◊ ﬁ
.ΩΩﬁ ﬂ
	BasePriceΩΩﬂ Ë
isΩΩÈ Î
notΩΩÏ Ô
nullΩΩ Ù
)ΩΩÙ ı
productΩΩˆ ˝
.ΩΩ˝ ˛
	BasePriceΩΩ˛ á
=ΩΩà â
requestΩΩä ë
.ΩΩë í
	BasePriceΩΩí õ
;ΩΩõ ú
ifΩΩù ü
(ΩΩ† °
requestΩΩ° ®
.ΩΩ® ©
CurrencyΩΩ© ±
isΩΩ≤ ¥
notΩΩµ ∏
nullΩΩπ Ω
)ΩΩΩ æ
productΩΩø ∆
.ΩΩ∆ «
CurrencyΩΩ« œ
=ΩΩ– —
requestΩΩ“ Ÿ
.ΩΩŸ ⁄
CurrencyΩΩ⁄ ‚
.ΩΩ‚ „
TrimΩΩ„ Á
(ΩΩÁ Ë
)ΩΩË È
.ΩΩÈ Í 
ToUpperInvariantΩΩÍ ˙
(ΩΩ˙ ˚
)ΩΩ˚ ¸
;ΩΩ¸ ˝
ifΩΩ˛ Ä
(ΩΩÅ Ç
requestΩΩÇ â
.ΩΩâ ä
DescriptionΩΩä ï
isΩΩñ ò
notΩΩô ú
nullΩΩù °
)ΩΩ° ¢
productΩΩ£ ™
.ΩΩ™ ´
DescriptionΩΩ´ ∂
=ΩΩ∑ ∏
EmptyToNullΩΩπ ƒ
(ΩΩƒ ≈
requestΩΩ≈ Ã
.ΩΩÃ Õ
DescriptionΩΩÕ ÿ
)ΩΩÿ Ÿ
;ΩΩŸ ⁄
ifΩΩ€ ›
(ΩΩﬁ ﬂ
requestΩΩﬂ Ê
.ΩΩÊ Á
IsActiveΩΩÁ Ô
isΩΩ Ú
boolΩΩÛ ˜
activeΩΩ¯ ˛
)ΩΩ˛ ˇ
productΩΩÄ á
.ΩΩá à
IsActiveΩΩà ê
=ΩΩë í
activeΩΩì ô
;ΩΩô ö
ifΩΩõ ù
(ΩΩû ü
requestΩΩü ¶
.ΩΩ¶ ß
CategoryΩΩß Ø
isΩΩ∞ ≤
notΩΩ≥ ∂
nullΩΩ∑ ª
)ΩΩª º
productΩΩΩ ƒ
.ΩΩƒ ≈
CategoryΩΩ≈ Õ
=ΩΩŒ œ
EmptyToNullΩΩ– €
(ΩΩ€ ‹
requestΩΩ‹ „
.ΩΩ„ ‰
CategoryΩΩ‰ Ï
)ΩΩÏ Ì
;ΩΩÌ Ó
ifΩΩÔ Ò
(ΩΩÚ Û
requestΩΩÛ ˙
.ΩΩ˙ ˚
TagsΩΩ˚ ˇ
isΩΩÄ Ç
notΩΩÉ Ü
nullΩΩá ã
)ΩΩã å
productΩΩç î
.ΩΩî ï
TagsΩΩï ô
=ΩΩö õ
NormalizeTagsΩΩú ©
(ΩΩ© ™
requestΩΩ™ ±
.ΩΩ± ≤
TagsΩΩ≤ ∂
)ΩΩ∂ ∑
;ΩΩ∑ ∏
ifΩΩπ ª
(ΩΩº Ω
requestΩΩΩ ƒ
.ΩΩƒ ≈
AllowsTicketsΩΩ≈ “
isΩΩ” ’
boolΩΩ÷ ⁄
allowsTicketsΩΩ€ Ë
)ΩΩË È
productΩΩÍ Ò
.ΩΩÒ Ú
AllowsTicketsΩΩÚ ˇ
=ΩΩÄ Å
allowsTicketsΩΩÇ è
;ΩΩè ê
ifΩΩë ì
(ΩΩî ï
requestΩΩï ú
.ΩΩú ù
TaxDocumentTypeΩΩù ¨
isΩΩ≠ Ø
TaxDocumentTypeΩΩ∞ ø
taxTypeΩΩ¿ «
)ΩΩ« »
productΩΩ… –
.ΩΩ– —
TaxDocumentTypeΩΩ— ‡
=ΩΩ· ‚
taxTypeΩΩ„ Í
;ΩΩÍ Î
if
ææ 

(
ææ 
string
ææ 
.
ææ  
IsNullOrWhiteSpace
ææ %
(
ææ% &
product
ææ& -
.
ææ- .
Name
ææ. 2
)
ææ2 3
||
ææ4 6
string
ææ7 =
.
ææ= > 
IsNullOrWhiteSpace
ææ> P
(
ææP Q
product
ææQ X
.
ææX Y
Currency
ææY a
)
ææa b
)
ææb c
return
ææd j

BadRequest
ææk u
(
ææu v
new
ææv y
{
ææz {
messageææ| É
=ææÑ Ö
$strææÜ ©
}ææ™ ´
)ææ´ ¨
;ææ¨ ≠
await
øø (
EnsureProductCategoryAsync
øø (
(
øø( )
product
øø) 0
.
øø0 1
Category
øø1 9
,
øø9 :
ct
øø; =
)
øø= >
;
øø> ?
await
¿¿ 
db
¿¿ 
.
¿¿ 
SaveChangesAsync
¿¿ !
(
¿¿! "
ct
¿¿" $
)
¿¿$ %
;
¿¿% &
return
¿¿' -
Ok
¿¿. 0
(
¿¿0 1

ProductDto
¿¿1 ;
(
¿¿; <
product
¿¿< C
)
¿¿C D
)
¿¿D E
;
¿¿E F
}
¡¡ 
[
√√ 
HttpGet
√√ 
(
√√ 
$str
√√ '
)
√√' (
]
√√( )
public
ƒƒ 

IActionResult
ƒƒ 
ProductTemplate
ƒƒ (
(
ƒƒ( )
)
ƒƒ) *
=>
ƒƒ+ -
File
ƒƒ. 2
(
ƒƒ2 3
CreateWorkbook
ƒƒ3 A
(
ƒƒA B
new
≈≈ 
(
≈≈ 
$str
≈≈ 
,
≈≈ 
true
≈≈ 
,
≈≈ 
$str
≈≈ +
,
≈≈+ ,
Enum
≈≈- 1
.
≈≈1 2
GetNames
≈≈2 :
<
≈≈: ;
ProductType
≈≈; F
>
≈≈F G
(
≈≈G H
)
≈≈H I
)
≈≈I J
,
≈≈J K
new
∆∆ 
(
∆∆ 
$str
∆∆ 
,
∆∆ 
true
∆∆ 
,
∆∆ 
$str
∆∆ G
)
∆∆G H
,
∆∆H I
new
«« 
(
«« 
$str
«« 
,
«« 
true
««  
,
««  !
$str
««" \
,
««\ ]
[
««^ _
$str
««_ f
,
««f g
$str
««h q
,
««q r
$str
««s ~
,
««~ 
$str««Ä å
,««å ç
$str««é ô
,««ô ö
$str««õ ¢
]««¢ £
)««£ §
,««§ •
new
»» 
(
»» 
$str
»» 
,
»» 
true
»» 
,
»» 
$str»» ™
)»»™ ´
,»»´ ¨
new
…… 
(
…… 
$str
…… 
,
…… 
true
…… 
,
…… 
$str
…… .
,
……. /
[
……0 1
$str
……1 6
,
……6 7
$str
……8 =
,
……= >
$str
……? D
]
……D E
)
……E F
,
……F G
new
   
(
   
$str
   
,
   
false
    
,
    !
$str
  " /
)
  / 0
,
  0 1
new
ÀÀ 
(
ÀÀ 
$str
ÀÀ 
,
ÀÀ 
false
ÀÀ 
,
ÀÀ 
$str
ÀÀ 5
,
ÀÀ5 6
[
ÀÀ7 8
$str
ÀÀ8 <
,
ÀÀ< =
$str
ÀÀ> B
]
ÀÀB C
)
ÀÀC D
,
ÀÀD E
new
ÃÃ 
(
ÃÃ 
$str
ÃÃ 
,
ÃÃ 
false
ÃÃ $
,
ÃÃ$ %
$str
ÃÃ& f
,
ÃÃf g
Enum
ÃÃh l
.
ÃÃl m
GetNames
ÃÃm u
<
ÃÃu v
TaxDocumentTypeÃÃv Ö
>ÃÃÖ Ü
(ÃÃÜ á
)ÃÃá à
)ÃÃà â
,ÃÃâ ä
new
ÕÕ 
(
ÕÕ 
$str
ÕÕ 
,
ÕÕ 
false
ÕÕ 
,
ÕÕ 
$str
ÕÕ C
)
ÕÕC D
,
ÕÕD E
new
ŒŒ 
(
ŒŒ 
$str
ŒŒ 
,
ŒŒ 
false
ŒŒ 
,
ŒŒ 
$str
ŒŒ w
)
ŒŒw x
,
ŒŒx y
new
œœ 
(
œœ 
$str
œœ 
,
œœ 
false
œœ "
,
œœ" #
$str
œœ$ r
,
œœr s
[
œœt u
$str
œœu y
,
œœy z
$str
œœ{ 
]œœ Ä
)œœÄ Å
)œœÅ Ç
,œœÇ É
$str
–– K
,
––K L
$str
––M g
)
––g h
;
––h i
[
““ 
HttpPost
““ 
(
““ 
$str
““ 
)
““  
]
““  !
public
”” 

async
”” 
Task
”” 
<
”” 
ActionResult
”” "
>
””" #
ImportProducts
””$ 2
(
””2 3
	IFormFile
””3 <
file
””= A
,
””A B
CancellationToken
””C T
ct
””U W
)
””W X
{
‘‘ 
var
’’ 
(
’’ 
failure
’’ 
,
’’ 
created
’’ 
,
’’ 
errors
’’ %
)
’’% &
=
’’' (
await
’’) .
Import
’’/ 5
(
’’5 6
file
’’6 :
,
’’: ;
$str
’’< G
,
’’G H
async
’’I N
(
’’O P
row
’’P S
,
’’S T
	rowNumber
’’U ^
,
’’^ _
errors
’’` f
)
’’f g
=>
’’h j
{
÷÷ 
var
◊◊ 
error
◊◊ 
=
◊◊ 
ParseProductRow
◊◊ #
(
◊◊# $
row
◊◊$ '
,
◊◊' (
out
◊◊) ,
var
◊◊- 0
product
◊◊1 8
)
◊◊8 9
;
◊◊9 :
if
ÿÿ 

(
ÿÿ 
error
ÿÿ 
is
ÿÿ 
not
ÿÿ 
null
ÿÿ 
)
ÿÿ 
{
ÿÿ  
errors
ÿÿ! '
.
ÿÿ' (
Add
ÿÿ( +
(
ÿÿ+ ,
new
ÿÿ, /
(
ÿÿ/ 0
	rowNumber
ÿÿ0 9
,
ÿÿ9 :
error
ÿÿ; @
)
ÿÿ@ A
)
ÿÿA B
;
ÿÿB C
return
ÿÿD J
false
ÿÿK P
;
ÿÿP Q
}
ÿÿR S
db
ŸŸ 

.
ŸŸ
 
Products
ŸŸ 
.
ŸŸ 
Add
ŸŸ 
(
ŸŸ 
product
ŸŸ 
!
ŸŸ  
)
ŸŸ  !
;
ŸŸ! "
await
ŸŸ# ((
EnsureProductCategoryAsync
ŸŸ) C
(
ŸŸC D
product
ŸŸD K
!
ŸŸK L
.
ŸŸL M
Category
ŸŸM U
,
ŸŸU V
ct
ŸŸW Y
)
ŸŸY Z
;
ŸŸZ [
return
ŸŸ\ b
true
ŸŸc g
;
ŸŸg h
}
⁄⁄ 	
,
⁄⁄	 

ct
⁄⁄ 
)
⁄⁄ 
;
⁄⁄ 
return
€€ 
failure
€€ 
??
€€ 
Ok
€€ 
(
€€ 
new
€€  
{
€€! "
created
€€# *
,
€€* +
skipped
€€, 3
=
€€4 5
errors
€€6 <
.
€€< =
Count
€€= B
,
€€B C
errors
€€D J
}
€€K L
)
€€L M
;
€€M N
}
‹‹ 
[
ﬁﬁ 
HttpPost
ﬁﬁ 
(
ﬁﬁ 
$str
ﬁﬁ 0
)
ﬁﬁ0 1
]
ﬁﬁ1 2
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
AssignProduct
ﬂﬂ$ 1
(
ﬂﬂ1 2
Guid
ﬂﬂ2 6
clientId
ﬂﬂ7 ?
,
ﬂﬂ? @"
AssignProductRequest
ﬂﬂA U
request
ﬂﬂV ]
,
ﬂﬂ] ^
CancellationToken
ﬂﬂ_ p
ct
ﬂﬂq s
)
ﬂﬂs t
{
‡‡ 
if
·· 

(
·· 
!
·· 
await
·· 
db
·· 
.
·· 
Clients
·· 
.
·· 
AnyAsync
·· &
(
··& '
x
··' (
=>
··) +
x
··, -
.
··- .
Id
··. 0
==
··1 3
clientId
··4 <
,
··< =
ct
··> @
)
··@ A
||
··B D
!
··E F
await
··F K
db
··L N
.
··N O
Projects
··O W
.
··W X
AnyAsync
··X `
(
··` a
x
··a b
=>
··c e
x
··f g
.
··g h
Id
··h j
==
··k m
request
··n u
.
··u v
	ProjectId
··v 
&&··Ä Ç
x··É Ñ
.··Ñ Ö
ClientId··Ö ç
==··é ê
clientId··ë ô
,··ô ö
ct··õ ù
)··ù û
)··û ü
return··† ¶
NotFound··ß Ø
(··Ø ∞
)··∞ ±
;··± ≤
var
‚‚ 
product
‚‚ 
=
‚‚ 
await
‚‚ 
db
‚‚ 
.
‚‚ 
Products
‚‚ '
.
‚‚' (
	FindAsync
‚‚( 1
(
‚‚1 2
[
‚‚2 3
request
‚‚3 :
.
‚‚: ;
	ProductId
‚‚; D
]
‚‚D E
,
‚‚E F
ct
‚‚G I
)
‚‚I J
;
‚‚J K
if
‚‚L N
(
‚‚O P
product
‚‚P W
is
‚‚X Z
null
‚‚[ _
)
‚‚_ `
return
‚‚a g
NotFound
‚‚h p
(
‚‚p q
)
‚‚q r
;
‚‚r s
if
„„ 

(
„„ 
request
„„ 
.
„„ 
BillingMode
„„ 
is
„„  "
not
„„# &
(
„„' (
$str
„„( 0
or
„„1 3
$str
„„4 <
)
„„< =
)
„„= >
return
„„? E

BadRequest
„„F P
(
„„P Q
new
„„Q T
{
„„U V
message
„„W ^
=
„„_ `
$str„„a Ä
}„„Å Ç
)„„Ç É
;„„É Ñ
if
‰‰ 

(
‰‰ 
request
‰‰ 
.
‰‰ 
BillingMode
‰‰ 
==
‰‰  "
$str
‰‰# +
&&
‰‰, .
await
‰‰/ 4
db
‰‰5 7
.
‰‰7 8
PaymentSettings
‰‰8 G
.
‰‰G H
AnyAsync
‰‰H P
(
‰‰P Q
x
‰‰Q R
=>
‰‰S U
!
‰‰V W
x
‰‰W X
.
‰‰X Y
PayPalEnabled
‰‰Y f
,
‰‰f g
ct
‰‰h j
)
‰‰j k
)
‰‰k l
return
‰‰m s

BadRequest
‰‰t ~
(
‰‰~ 
new‰‰ Ç
{‰‰É Ñ
message‰‰Ö å
=‰‰ç é
$str‰‰è ‚
}‰‰„ ‰
)‰‰‰ Â
;‰‰Â Ê
var
ÂÂ 
item
ÂÂ 
=
ÂÂ 
new
ÂÂ 
ClientProduct
ÂÂ $
{
ÂÂ% &
ClientId
ÂÂ' /
=
ÂÂ0 1
clientId
ÂÂ2 :
,
ÂÂ: ;
	ProjectId
ÂÂ< E
=
ÂÂF G
request
ÂÂH O
.
ÂÂO P
	ProjectId
ÂÂP Y
,
ÂÂY Z
	ProductId
ÂÂ[ d
=
ÂÂe f
product
ÂÂg n
.
ÂÂn o
Id
ÂÂo q
,
ÂÂq r
BillingCycle
ÂÂs 
=ÂÂÄ Å
requestÂÂÇ â
.ÂÂâ ä
BillingCycleÂÂä ñ
,ÂÂñ ó
IsManualBillingÂÂò ß
=ÂÂ® ©
requestÂÂ™ ±
.ÂÂ± ≤
BillingModeÂÂ≤ Ω
==ÂÂæ ¿
$strÂÂ¡ …
,ÂÂ…  
StatusÂÂÀ —
=ÂÂ“ ”
requestÂÂ‘ €
.ÂÂ€ ‹
BillingModeÂÂ‹ Á
==ÂÂË Í
$strÂÂÎ Û
?ÂÂÙ ı#
ClientProductStatusÂÂˆ â
.ÂÂâ ä
ActivoÂÂä ê
:ÂÂë í#
ClientProductStatusÂÂì ¶
.ÂÂ¶ ß
	PendienteÂÂß ∞
,ÂÂ∞ ±
PriceÂÂ≤ ∑
=ÂÂ∏ π
productÂÂ∫ ¡
.ÂÂ¡ ¬
	BasePriceÂÂ¬ À
isÂÂÃ Œ
nullÂÂœ ”
?ÂÂ‘ ’
requestÂÂ÷ ›
.ÂÂ› ﬁ
PriceÂÂﬁ „
:ÂÂ‰ Â
nullÂÂÊ Í
,ÂÂÍ Î

DomainNameÂÂÏ ˆ
=ÂÂ˜ ¯
EmptyToNullÂÂ˘ Ñ
(ÂÂÑ Ö
requestÂÂÖ å
.ÂÂå ç

DomainNameÂÂç ó
)ÂÂó ò
,ÂÂò ô"
PriceLabelOverrideÂÂö ¨
=ÂÂ≠ Æ
EmptyToNullÂÂØ ∫
(ÂÂ∫ ª
requestÂÂª ¬
.ÂÂ¬ √"
PriceLabelOverrideÂÂ√ ’
)ÂÂ’ ÷
,ÂÂ÷ ◊
RenewsAtÂÂÿ ‡
=ÂÂ· ‚
	ToUtcDateÂÂ„ Ï
(ÂÂÏ Ì
requestÂÂÌ Ù
.ÂÂÙ ı
RenewsAtÂÂı ˝
)ÂÂ˝ ˛
,ÂÂ˛ ˇ
NextChargeAtÂÂÄ å
=ÂÂç é
	ToUtcDateÂÂè ò
(ÂÂò ô
requestÂÂô †
.ÂÂ† °
NextChargeAtÂÂ° ≠
)ÂÂ≠ Æ
,ÂÂÆ Ø
ProductÂÂ∞ ∑
=ÂÂ∏ π
productÂÂ∫ ¡
}ÂÂ¬ √
;ÂÂ√ ƒ
item
ÊÊ 
.
ÊÊ 
Status
ÊÊ 
=
ÊÊ  
RenewalReminderJob
ÊÊ (
.
ÊÊ( )
	StatusFor
ÊÊ) 2
(
ÊÊ2 3
item
ÊÊ3 7
.
ÊÊ7 8
Status
ÊÊ8 >
,
ÊÊ> ?
item
ÊÊ@ D
.
ÊÊD E
RenewsAt
ÊÊE M
,
ÊÊM N
DateTime
ÊÊO W
.
ÊÊW X
UtcNow
ÊÊX ^
)
ÊÊ^ _
;
ÊÊ_ `
if
ÁÁ 

(
ÁÁ 
item
ÁÁ 
.
ÁÁ 
SetDiscount
ÁÁ 
(
ÁÁ 
request
ÁÁ $
.
ÁÁ$ %
Discount
ÁÁ% -
)
ÁÁ- .
is
ÁÁ/ 1
string
ÁÁ2 8
discountError
ÁÁ9 F
)
ÁÁF G
return
ÁÁH N

BadRequest
ÁÁO Y
(
ÁÁY Z
new
ÁÁZ ]
{
ÁÁ^ _
message
ÁÁ` g
=
ÁÁh i
discountError
ÁÁj w
}
ÁÁx y
)
ÁÁy z
;
ÁÁz {
db
ËË 

.
ËË
 
ClientProducts
ËË 
.
ËË 
Add
ËË 
(
ËË 
item
ËË "
)
ËË" #
;
ËË# $
var
ÈÈ 
igvRate
ÈÈ 
=
ÈÈ 
await
ÈÈ 
db
ÈÈ 
.
ÈÈ 
IgvRateForAsync
ÈÈ .
(
ÈÈ. /
clientId
ÈÈ/ 7
,
ÈÈ7 8
product
ÈÈ9 @
,
ÈÈ@ A
ct
ÈÈB D
)
ÈÈD E
;
ÈÈE F
if
ÍÍ 

(
ÍÍ 
request
ÍÍ 
.
ÍÍ 
BillingMode
ÍÍ 
==
ÍÍ  "
$str
ÍÍ# +
)
ÍÍ+ ,
{
ÎÎ 	
try
ÏÏ 
{
ÌÌ 
var
ÓÓ 
checkout
ÓÓ 
=
ÓÓ 
await
ÓÓ $
checkoutService
ÓÓ% 4
.
ÓÓ4 5

StartAsync
ÓÓ5 ?
(
ÓÓ? @
item
ÓÓ@ D
,
ÓÓD E
product
ÓÓF M
,
ÓÓM N
Request
ÓÓO V
,
ÓÓV W
ct
ÓÓX Z
,
ÓÓZ [
igvRate
ÓÓ\ c
)
ÓÓc d
;
ÓÓd e
await
ÔÔ 
db
ÔÔ 
.
ÔÔ 
SaveChangesAsync
ÔÔ )
(
ÔÔ) *
ct
ÔÔ* ,
)
ÔÔ, -
;
ÔÔ- .
return
 
Created
 
(
 
$"
 !
$str
! <
{
< =
item
= A
.
A B
Id
B D
}
D E
"
E F
,
F G
new
H K
{
L M
clientProduct
N [
=
\ ]
ClientProductDto
^ n
(
n o
item
o s
,
s t
igvRate
u |
)
| }
,
} ~
approvalUrl ä
=ã å
checkoutç ï
.ï ñ
ApprovalUrlñ °
}¢ £
)£ §
;§ •
}
ÒÒ 
catch
ÚÚ 
(
ÚÚ '
InvalidOperationException
ÚÚ ,
ex
ÚÚ- /
)
ÚÚ/ 0
{
ÚÚ1 2
return
ÚÚ3 9

BadRequest
ÚÚ: D
(
ÚÚD E
new
ÚÚE H
{
ÚÚI J
message
ÚÚK R
=
ÚÚS T
ex
ÚÚU W
.
ÚÚW X
Message
ÚÚX _
}
ÚÚ` a
)
ÚÚa b
;
ÚÚb c
}
ÚÚd e
}
ÛÛ 	
await
ÙÙ 
db
ÙÙ 
.
ÙÙ 
SaveChangesAsync
ÙÙ !
(
ÙÙ! "
ct
ÙÙ" $
)
ÙÙ$ %
;
ÙÙ% &
return
ÙÙ' -
Created
ÙÙ. 5
(
ÙÙ5 6
$"
ÙÙ6 8
$str
ÙÙ8 S
{
ÙÙS T
item
ÙÙT X
.
ÙÙX Y
Id
ÙÙY [
}
ÙÙ[ \
"
ÙÙ\ ]
,
ÙÙ] ^
new
ÙÙ_ b
{
ÙÙc d
clientProduct
ÙÙe r
=
ÙÙs t
ClientProductDtoÙÙu Ö
(ÙÙÖ Ü
itemÙÙÜ ä
,ÙÙä ã
igvRateÙÙå ì
)ÙÙì î
,ÙÙî ï
approvalUrlÙÙñ °
=ÙÙ¢ £
(ÙÙ§ •
stringÙÙ• ´
?ÙÙ´ ¨
)ÙÙ¨ ≠
nullÙÙ≠ ±
}ÙÙ≤ ≥
)ÙÙ≥ ¥
;ÙÙ¥ µ
}
ıı 
[
¸¸ 
HttpPost
¸¸ 
(
¸¸ 
$str
¸¸ 2
)
¸¸2 3
]
¸¸3 4
public
˝˝ 

async
˝˝ 
Task
˝˝ 
<
˝˝ 
ActionResult
˝˝ "
>
˝˝" #%
RegisterTransferPayment
˝˝$ ;
(
˝˝; <
Guid
˝˝< @
id
˝˝A C
,
˝˝C D$
TransferPaymentRequest
˝˝E [
request
˝˝\ c
,
˝˝c d
[
˝˝e f
FromServices
˝˝f r
]
˝˝r s#
PayPalPaymentService˝˝t à
payments˝˝â ë
,˝˝ë í!
CancellationToken˝˝ì §
ct˝˝• ß
)˝˝ß ®
{
˛˛ 
var
ˇˇ 
item
ˇˇ 
=
ˇˇ 
await
ˇˇ 
db
ˇˇ 
.
ˇˇ 
ClientProducts
ˇˇ *
.
ˇˇ* +
Include
ˇˇ+ 2
(
ˇˇ2 3
x
ˇˇ3 4
=>
ˇˇ5 7
x
ˇˇ8 9
.
ˇˇ9 :
Product
ˇˇ: A
)
ˇˇA B
.
ˇˇB C
Include
ˇˇC J
(
ˇˇJ K
x
ˇˇK L
=>
ˇˇM O
x
ˇˇP Q
.
ˇˇQ R
Project
ˇˇR Y
)
ˇˇY Z
.
ˇˇZ ["
SingleOrDefaultAsync
ˇˇ[ o
(
ˇˇo p
x
ˇˇp q
=>
ˇˇr t
x
ˇˇu v
.
ˇˇv w
Id
ˇˇw y
==
ˇˇz |
id
ˇˇ} 
,ˇˇ Ä
ctˇˇÅ É
)ˇˇÉ Ñ
;ˇˇÑ Ö
ifˇˇÜ à
(ˇˇâ ä
itemˇˇä é
isˇˇè ë
nullˇˇí ñ
)ˇˇñ ó
returnˇˇò û
NotFoundˇˇü ß
(ˇˇß ®
)ˇˇ® ©
;ˇˇ© ™
if
ÄÄ 

(
ÄÄ 
!
ÄÄ 
item
ÄÄ 
.
ÄÄ 
IsManualBilling
ÄÄ !
)
ÄÄ! "
return
ÄÄ# )

BadRequest
ÄÄ* 4
(
ÄÄ4 5
new
ÄÄ5 8
{
ÄÄ9 :
message
ÄÄ; B
=
ÄÄC D
$strÄÄE á
}ÄÄà â
)ÄÄâ ä
;ÄÄä ã
if
ÅÅ 

(
ÅÅ 
item
ÅÅ 
.
ÅÅ 
ValidateYears
ÅÅ 
(
ÅÅ 
request
ÅÅ &
.
ÅÅ& '
Years
ÅÅ' ,
)
ÅÅ, -
is
ÅÅ. 0
string
ÅÅ1 7

yearsError
ÅÅ8 B
)
ÅÅB C
return
ÅÅD J

BadRequest
ÅÅK U
(
ÅÅU V
new
ÅÅV Y
{
ÅÅZ [
message
ÅÅ\ c
=
ÅÅd e

yearsError
ÅÅf p
}
ÅÅq r
)
ÅÅr s
;
ÅÅs t
var
ÇÇ 
igvRate
ÇÇ 
=
ÇÇ 
item
ÇÇ 
.
ÇÇ 
Product
ÇÇ "
is
ÇÇ# %
null
ÇÇ& *
?
ÇÇ+ ,
$num
ÇÇ- /
:
ÇÇ0 1
await
ÇÇ2 7
db
ÇÇ8 :
.
ÇÇ: ;
IgvRateForAsync
ÇÇ; J
(
ÇÇJ K
item
ÇÇK O
.
ÇÇO P
ClientId
ÇÇP X
,
ÇÇX Y
item
ÇÇZ ^
.
ÇÇ^ _
Product
ÇÇ_ f
,
ÇÇf g
ct
ÇÇh j
)
ÇÇj k
;
ÇÇk l
var
ÉÉ 
amount
ÉÉ 
=
ÉÉ 
request
ÉÉ 
.
ÉÉ 
Amount
ÉÉ #
??
ÉÉ$ &
item
ÉÉ' +
.
ÉÉ+ ,
ChargeTotal
ÉÉ, 7
(
ÉÉ7 8
igvRate
ÉÉ8 ?
,
ÉÉ? @
request
ÉÉA H
.
ÉÉH I
Years
ÉÉI N
)
ÉÉN O
;
ÉÉO P
if
ÑÑ 

(
ÑÑ 
amount
ÑÑ 
is
ÑÑ 
not
ÑÑ 
decimal
ÑÑ !
value
ÑÑ" '
||
ÑÑ( *
value
ÑÑ+ 0
<=
ÑÑ1 3
$num
ÑÑ4 5
)
ÑÑ5 6
return
ÑÑ7 =

BadRequest
ÑÑ> H
(
ÑÑH I
new
ÑÑI L
{
ÑÑM N
message
ÑÑO V
=
ÑÑW X
$str
ÑÑY u
}
ÑÑv w
)
ÑÑw x
;
ÑÑx y
var
ÖÖ 
	reference
ÖÖ 
=
ÖÖ 
request
ÖÖ 
.
ÖÖ  
	Reference
ÖÖ  )
?
ÖÖ) *
.
ÖÖ* +
Trim
ÖÖ+ /
(
ÖÖ/ 0
)
ÖÖ0 1
;
ÖÖ1 2
var
ÜÜ 
key
ÜÜ 
=
ÜÜ 
string
ÜÜ 
.
ÜÜ  
IsNullOrWhiteSpace
ÜÜ +
(
ÜÜ+ ,
	reference
ÜÜ, 5
)
ÜÜ5 6
?
ÜÜ7 8
$"
ÜÜ9 ;
$str
ÜÜ; ?
{
ÜÜ? @
Guid
ÜÜ@ D
.
ÜÜD E
NewGuid
ÜÜE L
(
ÜÜL M
)
ÜÜM N
:
ÜÜN O
$str
ÜÜO P
}
ÜÜP Q
"
ÜÜQ R
:
ÜÜS T
$"
ÜÜU W
$str
ÜÜW [
{
ÜÜ[ \
	reference
ÜÜ\ e
}
ÜÜe f
"
ÜÜf g
;
ÜÜg h
if
áá 

(
áá 
key
áá 
.
áá 
Length
áá 
>
áá 
$num
áá 
)
áá 
return
áá $

BadRequest
áá% /
(
áá/ 0
new
áá0 3
{
áá4 5
message
áá6 =
=
áá> ?
$str
áá@ h
}
áái j
)
ááj k
;
áák l
var
àà 
paidAt
àà 
=
àà 
	ToUtcDate
àà 
(
àà 
request
àà &
.
àà& '
PaidAt
àà' -
)
àà- .
;
àà. /
if
ââ 

(
ââ 
paidAt
ââ 
>
ââ 
DateTime
ââ 
.
ââ 
UtcNow
ââ $
.
ââ$ %
AddDays
ââ% ,
(
ââ, -
$num
ââ- .
)
ââ. /
)
ââ/ 0
return
ââ1 7

BadRequest
ââ8 B
(
ââB C
new
ââC F
{
ââG H
message
ââI P
=
ââQ R
$str
ââS z
}
ââ{ |
)
ââ| }
;
ââ} ~
if
ää 

(
ää 
!
ää 
await
ää 
payments
ää 
.
ää 
ApplyPaymentAsync
ää -
(
ää- .
item
ää. 2
,
ää2 3
key
ää4 7
,
ää7 8
value
ää9 >
,
ää> ?
item
ää@ D
.
ääD E
Product
ääE L
?
ääL M
.
ääM N
Currency
ääN V
,
ääV W
ct
ääX Z
,
ääZ [
PaymentMethods
ää\ j
.
ääj k
Transferencia
ääk x
,
ääx y
paidAtääz Ä
,ääÄ Å
requestääÇ â
.ääâ ä
Yearsäää è
)ääè ê
)ääê ë
returnääí ò
Conflictääô °
(ää° ¢
newää¢ •
{ää¶ ß
messageää® Ø
=ää∞ ±
$strää≤ Î
}ääÏ Ì
)ääÌ Ó
;ääÓ Ô
item
åå 
.
åå 
Status
åå 
=
åå  
RenewalReminderJob
åå (
.
åå( )
	StatusFor
åå) 2
(
åå2 3
item
åå3 7
.
åå7 8
Status
åå8 >
,
åå> ?
item
åå@ D
.
ååD E
RenewsAt
ååE M
,
ååM N
DateTime
ååO W
.
ååW X
UtcNow
ååX ^
)
åå^ _
;
åå_ `
await
ååa f
db
ååg i
.
ååi j
SaveChangesAsync
ååj z
(
ååz {
ct
åå{ }
)
åå} ~
;
åå~ 
return
çç 
Ok
çç 
(
çç 
ClientProductDto
çç "
(
çç" #
item
çç# '
,
çç' (
igvRate
çç) 0
)
çç0 1
)
çç1 2
;
çç2 3
}
éé 
[
êê 
	HttpPatch
êê 
(
êê 
$str
êê *
)
êê* +
]
êê+ ,
public
ëë 

async
ëë 
Task
ëë 
<
ëë 
ActionResult
ëë "
>
ëë" #!
UpdateClientProduct
ëë$ 7
(
ëë7 8
Guid
ëë8 <
id
ëë= ?
,
ëë? @'
ClientProductPatchRequest
ëëA Z
request
ëë[ b
,
ëëb c
CancellationToken
ëëd u
ct
ëëv x
)
ëëx y
{
íí 
var
ìì 
item
ìì 
=
ìì 
await
ìì 
db
ìì 
.
ìì 
ClientProducts
ìì *
.
ìì* +
Include
ìì+ 2
(
ìì2 3
x
ìì3 4
=>
ìì5 7
x
ìì8 9
.
ìì9 :
Product
ìì: A
)
ììA B
.
ììB C
Include
ììC J
(
ììJ K
x
ììK L
=>
ììM O
x
ììP Q
.
ììQ R
Project
ììR Y
)
ììY Z
.
ììZ ["
SingleOrDefaultAsync
ìì[ o
(
ììo p
x
ììp q
=>
ììr t
x
ììu v
.
ììv w
Id
ììw y
==
ììz |
id
ìì} 
,ìì Ä
ctììÅ É
)ììÉ Ñ
;ììÑ Ö
ifììÜ à
(ììâ ä
itemììä é
isììè ë
nullììí ñ
)ììñ ó
returnììò û
NotFoundììü ß
(ììß ®
)ìì® ©
;ìì© ™
if
îî 

(
îî 
request
îî 
.
îî 
Price
îî 
is
îî 
not
îî  
null
îî! %
)
îî% &
item
îî' +
.
îî+ ,
Price
îî, 1
=
îî2 3
request
îî4 ;
.
îî; <
Price
îî< A
;
îîA B
if
îîC E
(
îîF G
request
îîG N
.
îîN O
Status
îîO U
is
îîV X!
ClientProductStatus
îîY l
status
îîm s
)
îîs t
item
îîu y
.
îîy z
Statusîîz Ä
=îîÅ Ç
statusîîÉ â
;îîâ ä
ifîîã ç
(îîé è
requestîîè ñ
.îîñ ó
BillingCycleîîó £
isîî§ ¶
BillingCycleîîß ≥
cycleîî¥ π
)îîπ ∫
itemîîª ø
.îîø ¿
BillingCycleîî¿ Ã
=îîÕ Œ
cycleîîœ ‘
;îî‘ ’
ifîî÷ ÿ
(îîŸ ⁄
requestîî⁄ ·
.îî· ‚

DomainNameîî‚ Ï
isîîÌ Ô
notîî Û
nullîîÙ ¯
)îî¯ ˘
itemîî˙ ˛
.îî˛ ˇ

DomainNameîîˇ â
=îîä ã
EmptyToNullîîå ó
(îîó ò
requestîîò ü
.îîü †

DomainNameîî† ™
)îî™ ´
;îî´ ¨
ifîî≠ Ø
(îî∞ ±
requestîî± ∏
.îî∏ π"
PriceLabelOverrideîîπ À
isîîÃ Œ
notîîœ “
nullîî” ◊
)îî◊ ÿ
itemîîŸ ›
.îî› ﬁ"
PriceLabelOverrideîîﬁ 
=îîÒ Ú
EmptyToNullîîÛ ˛
(îî˛ ˇ
requestîîˇ Ü
.îîÜ á"
PriceLabelOverrideîîá ô
)îîô ö
;îîö õ
ifîîú û
(îîü †
requestîî† ß
.îîß ®
IsManualBillingîî® ∑
isîî∏ ∫
boolîîª ø
manualîî¿ ∆
)îî∆ «
itemîî» Ã
.îîÃ Õ
IsManualBillingîîÕ ‹
=îî› ﬁ
manualîîﬂ Â
;îîÂ Ê
if
ïï 

(
ïï 
request
ïï 
.
ïï 
Discount
ïï 
is
ïï 
not
ïï  #
null
ïï$ (
&&
ïï) +
item
ïï, 0
.
ïï0 1
SetDiscount
ïï1 <
(
ïï< =
request
ïï= D
.
ïïD E
Discount
ïïE M
)
ïïM N
is
ïïO Q
string
ïïR X
discountError
ïïY f
)
ïïf g
return
ïïh n

BadRequest
ïïo y
(
ïïy z
new
ïïz }
{
ïï~ 
messageïïÄ á
=ïïà â
discountErrorïïä ó
}ïïò ô
)ïïô ö
;ïïö õ
if
óó 

(
óó 
request
óó 
.
óó 
	ProjectId
óó 
is
óó  
Guid
óó! %
	projectId
óó& /
&&
óó0 2
	projectId
óó3 <
!=
óó= ?
item
óó@ D
.
óóD E
	ProjectId
óóE N
)
óóN O
{
òò 	
var
ôô 
project
ôô 
=
ôô 
await
ôô 
db
ôô  "
.
ôô" #
Projects
ôô# +
.
ôô+ ,"
SingleOrDefaultAsync
ôô, @
(
ôô@ A
x
ôôA B
=>
ôôC E
x
ôôF G
.
ôôG H
Id
ôôH J
==
ôôK M
	projectId
ôôN W
&&
ôôX Z
x
ôô[ \
.
ôô\ ]
ClientId
ôô] e
==
ôôf h
item
ôôi m
.
ôôm n
ClientId
ôôn v
,
ôôv w
ct
ôôx z
)
ôôz {
;
ôô{ |
if
öö 
(
öö 
project
öö 
is
öö 
null
öö 
)
öö  
return
öö! '

BadRequest
öö( 2
(
öö2 3
new
öö3 6
{
öö7 8
message
öö9 @
=
ööA B
$str
ööC m
}
öön o
)
ööo p
;
ööp q
(
õõ 
item
õõ 
.
õõ 
	ProjectId
õõ 
,
õõ 
item
õõ !
.
õõ! "
Project
õõ" )
)
õõ) *
=
õõ+ ,
(
õõ- .
project
õõ. 5
.
õõ5 6
Id
õõ6 8
,
õõ8 9
project
õõ: A
)
õõA B
;
õõB C
}
úú 	
await
ùù 
db
ùù 
.
ùù 
SaveChangesAsync
ùù !
(
ùù! "
ct
ùù" $
)
ùù$ %
;
ùù% &
return
ùù' -
Ok
ùù. 0
(
ùù0 1
await
ùù1 6#
ClientProductDtoAsync
ùù7 L
(
ùùL M
item
ùùM Q
,
ùùQ R
ct
ùùS U
)
ùùU V
)
ùùV W
;
ùùW X
}
ûû 
[
§§ 

HttpDelete
§§ 
(
§§ 
$str
§§ +
)
§§+ ,
]
§§, -
public
•• 

async
•• 
Task
•• 
<
•• 
ActionResult
•• "
>
••" #!
DeleteClientProduct
••$ 7
(
••7 8
Guid
••8 <
id
••= ?
,
••? @
CancellationToken
••A R
ct
••S U
)
••U V
{
¶¶ 
var
ßß 
item
ßß 
=
ßß 
await
ßß 
db
ßß 
.
ßß 
ClientProducts
ßß *
.
ßß* +
Include
ßß+ 2
(
ßß2 3
x
ßß3 4
=>
ßß5 7
x
ßß8 9
.
ßß9 :
Product
ßß: A
)
ßßA B
.
ßßB C"
SingleOrDefaultAsync
ßßC W
(
ßßW X
x
ßßX Y
=>
ßßZ \
x
ßß] ^
.
ßß^ _
Id
ßß_ a
==
ßßb d
id
ßße g
,
ßßg h
ct
ßßi k
)
ßßk l
;
ßßl m
if
ßßn p
(
ßßq r
item
ßßr v
is
ßßw y
null
ßßz ~
)
ßß~ 
returnßßÄ Ü
NotFoundßßá è
(ßßè ê
)ßßê ë
;ßßë í
var
®® 
payments
®® 
=
®® 
await
®® 
db
®® 
.
®®  !
PaymentTransactions
®®  3
.
®®3 4

CountAsync
®®4 >
(
®®> ?
x
®®? @
=>
®®A C
x
®®D E
.
®®E F
ClientProductId
®®F U
==
®®V X
id
®®Y [
,
®®[ \
ct
®®] _
)
®®_ `
;
®®` a
if
©© 

(
©© 
payments
©© 
==
©© 
$num
©© 
)
©© 
payments
©© #
=
©©$ %
await
©©& +
db
©©, .
.
©©. /
TaxDocumentLines
©©/ ?
.
©©? @

CountAsync
©©@ J
(
©©J K
x
©©K L
=>
©©M O
x
©©P Q
.
©©Q R
ClientProductId
©©R a
==
©©b d
id
©©e g
,
©©g h
ct
©©i k
)
©©k l
;
©©l m
if
™™ 

(
™™ 
payments
™™ 
>
™™ 
$num
™™ 
)
™™ 
return
™™  
Conflict
™™! )
(
™™) *
new
™™* -
{
™™. /
message
™™0 7
=
™™8 9
$"
™™: <
$str
™™< =
{
™™= >
item
™™> B
.
™™B C
Product
™™C J
?
™™J K
.
™™K L
Name
™™L P
}
™™P Q
$str
™™Q Y
{
™™Y Z
Count
™™Z _
(
™™_ `
payments
™™` h
,
™™h i
$str
™™j {
,
™™{ |
$str™™} ê
)™™ê ë
}™™ë í
$str™™í ˘
"™™˘ ˙
}™™˚ ¸
)™™¸ ˝
;™™˝ ˛
if
´´ 

(
´´ 
!
´´ 
string
´´ 
.
´´  
IsNullOrWhiteSpace
´´ &
(
´´& '
item
´´' +
.
´´+ ,"
PayPalSubscriptionId
´´, @
)
´´@ A
&&
´´B D
item
´´E I
.
´´I J
Status
´´J P
!=
´´Q S!
ClientProductStatus
´´T g
.
´´g h
	Cancelado
´´h q
)
´´q r
return
´´s y
Conflict´´z Ç
(´´Ç É
new´´É Ü
{´´á à
message´´â ê
=´´ë í
$str´´ì ı
}´´ˆ ˜
)´´˜ ¯
;´´¯ ˘
await
≠≠ 
db
≠≠ 
.
≠≠ 
Tickets
≠≠ 
.
≠≠ 
Where
≠≠ 
(
≠≠ 
x
≠≠  
=>
≠≠! #
x
≠≠$ %
.
≠≠% &
ClientProductId
≠≠& 5
==
≠≠6 8
id
≠≠9 ;
)
≠≠; <
.
≠≠< =
ForEachAsync
≠≠= I
(
≠≠I J
x
≠≠J K
=>
≠≠L N
x
≠≠O P
.
≠≠P Q
ClientProductId
≠≠Q `
=
≠≠a b
null
≠≠c g
,
≠≠g h
ct
≠≠i k
)
≠≠k l
;
≠≠l m
db
ÆÆ 

.
ÆÆ
 
TransferReports
ÆÆ 
.
ÆÆ 
RemoveRange
ÆÆ &
(
ÆÆ& '
await
ÆÆ' ,
db
ÆÆ- /
.
ÆÆ/ 0
TransferReports
ÆÆ0 ?
.
ÆÆ? @
Where
ÆÆ@ E
(
ÆÆE F
x
ÆÆF G
=>
ÆÆH J
x
ÆÆK L
.
ÆÆL M
ClientProductId
ÆÆM \
==
ÆÆ] _
id
ÆÆ` b
)
ÆÆb c
.
ÆÆc d
ToListAsync
ÆÆd o
(
ÆÆo p
ct
ÆÆp r
)
ÆÆr s
)
ÆÆs t
;
ÆÆt u
db
ØØ 

.
ØØ
 
ClientProducts
ØØ 
.
ØØ 
Remove
ØØ  
(
ØØ  !
item
ØØ! %
)
ØØ% &
;
ØØ& '
await
∞∞ 
db
∞∞ 
.
∞∞ 
SaveChangesAsync
∞∞ !
(
∞∞! "
ct
∞∞" $
)
∞∞$ %
;
∞∞% &
return
∞∞' -
	NoContent
∞∞. 7
(
∞∞7 8
)
∞∞8 9
;
∞∞9 :
}
±± 
[
∏∏ 
HttpPut
∏∏ 
(
∏∏ 
$str
∏∏ .
)
∏∏. /
]
∏∏/ 0
public
ππ 

async
ππ 
Task
ππ 
<
ππ 
ActionResult
ππ "
>
ππ" #&
UpdateClientProductDates
ππ$ <
(
ππ< =
Guid
ππ= A
id
ππB D
,
ππD E'
ClientProductDatesRequest
ππF _
request
ππ` g
,
ππg h
CancellationToken
ππi z
ct
ππ{ }
)
ππ} ~
{
∫∫ 
var
ªª 
item
ªª 
=
ªª 
await
ªª 
db
ªª 
.
ªª 
ClientProducts
ªª *
.
ªª* +
Include
ªª+ 2
(
ªª2 3
x
ªª3 4
=>
ªª5 7
x
ªª8 9
.
ªª9 :
Product
ªª: A
)
ªªA B
.
ªªB C
Include
ªªC J
(
ªªJ K
x
ªªK L
=>
ªªM O
x
ªªP Q
.
ªªQ R
Project
ªªR Y
)
ªªY Z
.
ªªZ ["
SingleOrDefaultAsync
ªª[ o
(
ªªo p
x
ªªp q
=>
ªªr t
x
ªªu v
.
ªªv w
Id
ªªw y
==
ªªz |
id
ªª} 
,ªª Ä
ctªªÅ É
)ªªÉ Ñ
;ªªÑ Ö
ifªªÜ à
(ªªâ ä
itemªªä é
isªªè ë
nullªªí ñ
)ªªñ ó
returnªªò û
NotFoundªªü ß
(ªªß ®
)ªª® ©
;ªª© ™
item
ºº 
.
ºº 
RenewsAt
ºº 
=
ºº 
	ToUtcDate
ºº !
(
ºº! "
request
ºº" )
.
ºº) *
RenewsAt
ºº* 2
)
ºº2 3
;
ºº3 4
item
ºº5 9
.
ºº9 :
NextChargeAt
ºº: F
=
ººG H
	ToUtcDate
ººI R
(
ººR S
request
ººS Z
.
ººZ [
NextChargeAt
ºº[ g
)
ººg h
;
ººh i
item
ΩΩ 
.
ΩΩ 
Status
ΩΩ 
=
ΩΩ  
RenewalReminderJob
ΩΩ (
.
ΩΩ( )
	StatusFor
ΩΩ) 2
(
ΩΩ2 3
item
ΩΩ3 7
.
ΩΩ7 8
Status
ΩΩ8 >
,
ΩΩ> ?
item
ΩΩ@ D
.
ΩΩD E
RenewsAt
ΩΩE M
,
ΩΩM N
DateTime
ΩΩO W
.
ΩΩW X
UtcNow
ΩΩX ^
)
ΩΩ^ _
;
ΩΩ_ `
item
ææ 
.
ææ 
OnDatesChanged
ææ 
(
ææ 
)
ææ 
;
ææ 
await
øø 
db
øø 
.
øø 
SaveChangesAsync
øø !
(
øø! "
ct
øø" $
)
øø$ %
;
øø% &
return
øø' -
Ok
øø. 0
(
øø0 1
await
øø1 6#
ClientProductDtoAsync
øø7 L
(
øøL M
item
øøM Q
,
øøQ R
ct
øøS U
)
øøU V
)
øøV W
;
øøW X
}
¿¿ 
internal
√√ 
static
√√ 
DateTime
√√ 
?
√√ 
	ToUtcDate
√√ '
(
√√' (
DateOnly
√√( 0
?
√√0 1
date
√√2 6
)
√√6 7
=>
√√8 :
date
√√; ?
?
√√? @
.
√√@ A

ToDateTime
√√A K
(
√√K L
new
√√L O
TimeOnly
√√P X
(
√√X Y
$num
√√Y [
,
√√[ \
$num
√√] ^
)
√√^ _
,
√√_ `
DateTimeKind
√√a m
.
√√m n
Utc
√√n q
)
√√q r
;
√√r s
private
≈≈ 
async
≈≈ 
Task
≈≈ 
<
≈≈ 
(
≈≈ 
ActionResult
≈≈ $
?
≈≈$ %
Failure
≈≈& -
,
≈≈- .
int
≈≈/ 2
Created
≈≈3 :
,
≈≈: ;
List
≈≈< @
<
≈≈@ A
ImportError
≈≈A L
>
≈≈L M
Errors
≈≈N T
)
≈≈T U
>
≈≈U V
Import
≈≈W ]
(
≈≈] ^
	IFormFile
≈≈^ g
file
≈≈h l
,
≈≈l m
string
≈≈n t
kind
≈≈u y
,
≈≈y z
Func
≈≈{ 
<≈≈ Ä
IXLRow≈≈Ä Ü
,≈≈Ü á
int≈≈à ã
,≈≈ã å
List≈≈ç ë
<≈≈ë í
ImportError≈≈í ù
>≈≈ù û
,≈≈û ü
Task≈≈† §
<≈≈§ •
bool≈≈• ©
>≈≈© ™
>≈≈™ ´
addRow≈≈¨ ≤
,≈≈≤ ≥!
CancellationToken≈≈¥ ≈
ct≈≈∆ »
)≈≈» …
{
∆∆ 
var
«« 
errors
«« 
=
«« 
new
«« 
List
«« 
<
«« 
ImportError
«« )
>
««) *
(
««* +
)
««+ ,
;
««, -
var
««. 1
created
««2 9
=
««: ;
$num
««< =
;
««= >
if
»» 

(
»» 
file
»» 
is
»» 
null
»» 
||
»» 
file
»»  
.
»»  !
Length
»»! '
==
»»( *
$num
»»+ ,
)
»», -
return
»». 4
(
»»5 6

BadRequest
»»6 @
(
»»@ A
new
»»A D
{
»»E F
message
»»G N
=
»»O P
$str
»»Q o
}
»»p q
)
»»q r
,
»»r s
$num
»»t u
,
»»u v
errors
»»w }
)
»»} ~
;
»»~ 
try
…… 
{
…… 
using
…… 
var
…… 
stream
…… 
=
……  
file
……! %
.
……% &
OpenReadStream
……& 4
(
……4 5
)
……5 6
;
……6 7
using
……8 =
var
……> A
book
……B F
=
……G H
new
……I L

XLWorkbook
……M W
(
……W X
stream
……X ^
)
……^ _
;
……_ `
var
……a d
sheet
……e j
=
……k l
book
……m q
.
……q r

Worksheets
……r |
.
……| }
First……} Ç
(……Ç É
)……É Ñ
;……Ñ Ö
foreach……Ü ç
(……é è
var……è í
row……ì ñ
in……ó ô
sheet……ö ü
.……ü †
RowsUsed……† ®
(……® ©
)……© ™
.……™ ´
Skip……´ Ø
(……Ø ∞
$num……∞ ±
)……± ≤
)……≤ ≥
if……¥ ∂
(……∑ ∏
await……∏ Ω
addRow……æ ƒ
(……ƒ ≈
row……≈ »
,……» …
row……  Õ
.……Õ Œ
	RowNumber……Œ ◊
(……◊ ÿ
)……ÿ Ÿ
,……Ÿ ⁄
errors……€ ·
)……· ‚
)……‚ „
{……‰ Â
await……Ê Î
db……Ï Ó
.……Ó Ô 
SaveChangesAsync……Ô ˇ
(……ˇ Ä
ct……Ä Ç
)……Ç É
;……É Ñ
created……Ö å
++……å é
;……é è
}……ê ë
}……í ì
catch
   
(
   
	Exception
   
ex
   
)
   
when
   !
(
  " #
ex
  # %
is
  & (
not
  ) ,
DbUpdateException
  - >
)
  > ?
{
  @ A
return
  B H
(
  I J

BadRequest
  J T
(
  T U
new
  U X
{
  Y Z
message
  [ b
=
  c d
$"
  e g
$str  g á
{  á à
kind  à å
}  å ç
$str  ç é
"  é è
}  ê ë
)  ë í
,  í ì
$num  î ï
,  ï ñ
errors  ó ù
)  ù û
;  û ü
}  † °
return
ÀÀ 
(
ÀÀ 
null
ÀÀ 
,
ÀÀ 
created
ÀÀ 
,
ÀÀ 
errors
ÀÀ %
)
ÀÀ% &
;
ÀÀ& '
}
ÃÃ 
private
ÕÕ 
static
ÕÕ 
string
ÕÕ 
Cell
ÕÕ 
(
ÕÕ 
IXLRow
ÕÕ %
row
ÕÕ& )
,
ÕÕ) *
int
ÕÕ+ .
col
ÕÕ/ 2
)
ÕÕ2 3
=>
ÕÕ4 6
row
ÕÕ7 :
.
ÕÕ: ;
Cell
ÕÕ; ?
(
ÕÕ? @
col
ÕÕ@ C
)
ÕÕC D
.
ÕÕD E
	GetString
ÕÕE N
(
ÕÕN O
)
ÕÕO P
;
ÕÕP Q
private
““ 
static
““ 
byte
““ 
[
““ 
]
““ 
CreateWorkbook
““ (
(
““( )
params
““) /
TemplateColumn
““0 >
[
““> ?
]
““? @
columns
““A H
)
““H I
{
”” 
const
‘‘ 
int
‘‘ 
LastDataRow
‘‘ 
=
‘‘ 
$num
‘‘  $
;
‘‘$ %
using
’’ 
var
’’ 
book
’’ 
=
’’ 
new
’’ 

XLWorkbook
’’ '
(
’’' (
)
’’( )
;
’’) *
var
’’+ .
sheet
’’/ 4
=
’’5 6
book
’’7 ;
.
’’; <
AddWorksheet
’’< H
(
’’H I
$str
’’I T
)
’’T U
;
’’U V
var
÷÷ 
help
÷÷ 
=
÷÷ 
book
÷÷ 
.
÷÷ 
AddWorksheet
÷÷ $
(
÷÷$ %
$str
÷÷% 6
)
÷÷6 7
;
÷÷7 8
help
◊◊ 
.
◊◊ 
Cell
◊◊ 
(
◊◊ 
$num
◊◊ 
,
◊◊ 
$num
◊◊ 
)
◊◊ 
.
◊◊ 
Value
◊◊ 
=
◊◊ 
$str
◊◊  )
;
◊◊) *
help
◊◊+ /
.
◊◊/ 0
Cell
◊◊0 4
(
◊◊4 5
$num
◊◊5 6
,
◊◊6 7
$num
◊◊8 9
)
◊◊9 :
.
◊◊: ;
Value
◊◊; @
=
◊◊A B
$str
◊◊C P
;
◊◊P Q
help
◊◊R V
.
◊◊V W
Cell
◊◊W [
(
◊◊[ \
$num
◊◊\ ]
,
◊◊] ^
$num
◊◊_ `
)
◊◊` a
.
◊◊a b
Value
◊◊b g
=
◊◊h i
$str
◊◊j }
;
◊◊} ~
help◊◊ É
.◊◊É Ñ
Row◊◊Ñ á
(◊◊á à
$num◊◊à â
)◊◊â ä
.◊◊ä ã
Style◊◊ã ê
.◊◊ê ë
Font◊◊ë ï
.◊◊ï ñ
Bold◊◊ñ ö
=◊◊õ ú
true◊◊ù °
;◊◊° ¢
for
ÿÿ 
(
ÿÿ 
var
ÿÿ 
i
ÿÿ 
=
ÿÿ 
$num
ÿÿ 
;
ÿÿ 
i
ÿÿ 
<
ÿÿ 
columns
ÿÿ #
.
ÿÿ# $
Length
ÿÿ$ *
;
ÿÿ* +
i
ÿÿ, -
++
ÿÿ- /
)
ÿÿ/ 0
{
ŸŸ 	
var
⁄⁄ 
column
⁄⁄ 
=
⁄⁄ 
columns
⁄⁄  
[
⁄⁄  !
i
⁄⁄! "
]
⁄⁄" #
;
⁄⁄# $
var
⁄⁄% (
accepted
⁄⁄) 1
=
⁄⁄2 3
column
⁄⁄4 :
.
⁄⁄: ;
Options
⁄⁄; B
is
⁄⁄C E
null
⁄⁄F J
?
⁄⁄K L
column
⁄⁄M S
.
⁄⁄S T
Accepted
⁄⁄T \
:
⁄⁄] ^
$"
⁄⁄_ a
{
⁄⁄a b
column
⁄⁄b h
.
⁄⁄h i
Accepted
⁄⁄i q
}
⁄⁄q r
$str
⁄⁄r t
{
⁄⁄t u
string
⁄⁄u {
.
⁄⁄{ |
Join⁄⁄| Ä
(⁄⁄Ä Å
$str⁄⁄Å Ö
,⁄⁄Ö Ü
column⁄⁄á ç
.⁄⁄ç é
Options⁄⁄é ï
)⁄⁄ï ñ
}⁄⁄ñ ó
"⁄⁄ó ò
;⁄⁄ò ô
var
€€ 
header
€€ 
=
€€ 
sheet
€€ 
.
€€ 
Cell
€€ #
(
€€# $
$num
€€$ %
,
€€% &
i
€€' (
+
€€) *
$num
€€+ ,
)
€€, -
;
€€- .
header
€€/ 5
.
€€5 6
Value
€€6 ;
=
€€< =
column
€€> D
.
€€D E
Name
€€E I
;
€€I J
header
‹‹ 
.
‹‹ 
CreateComment
‹‹  
(
‹‹  !
)
‹‹! "
.
‹‹" #
AddText
‹‹# *
(
‹‹* +
$"
‹‹+ -
{
‹‹- .
(
‹‹. /
column
‹‹/ 5
.
‹‹5 6
Required
‹‹6 >
?
‹‹? @
$str
‹‹A N
:
‹‹O P
$str
‹‹Q [
)
‹‹[ \
}
‹‹\ ]
$str
‹‹] _
{
‹‹_ `
accepted
‹‹` h
}
‹‹h i
"
‹‹i j
)
‹‹j k
;
‹‹k l
if
›› 
(
›› 
column
›› 
.
›› 
Required
›› 
)
››  
header
››! '
.
››' (
Style
››( -
.
››- .
Fill
››. 2
.
››2 3
BackgroundColor
››3 B
=
››C D
XLColor
››E L
.
››L M
FromHtml
››M U
(
››U V
$str
››V _
)
››_ `
;
››` a
if
ﬁﬁ 
(
ﬁﬁ 
column
ﬁﬁ 
.
ﬁﬁ 
Options
ﬁﬁ 
is
ﬁﬁ !
not
ﬁﬁ" %
null
ﬁﬁ& *
)
ﬁﬁ* +
{
ﬂﬂ 
var
‡‡ 

validation
‡‡ 
=
‡‡  
sheet
‡‡! &
.
‡‡& '
Range
‡‡' ,
(
‡‡, -
$num
‡‡- .
,
‡‡. /
i
‡‡0 1
+
‡‡2 3
$num
‡‡4 5
,
‡‡5 6
LastDataRow
‡‡7 B
,
‡‡B C
i
‡‡D E
+
‡‡F G
$num
‡‡H I
)
‡‡I J
.
‡‡J K"
CreateDataValidation
‡‡K _
(
‡‡_ `
)
‡‡` a
;
‡‡a b

validation
·· 
.
·· 
List
·· 
(
··  
$"
··  "
$str
··" $
{
··$ %
string
··% +
.
··+ ,
Join
··, 0
(
··0 1
$str
··1 4
,
··4 5
column
··6 <
.
··< =
Options
··= D
)
··D E
}
··E F
$str
··F H
"
··H I
,
··I J
true
··K O
)
··O P
;
··P Q

validation
‚‚ 
.
‚‚ 

ErrorTitle
‚‚ %
=
‚‚& '
column
‚‚( .
.
‚‚. /
Name
‚‚/ 3
;
‚‚3 4

validation
‚‚5 ?
.
‚‚? @
ErrorMessage
‚‚@ L
=
‚‚M N
$"
‚‚O Q
$str
‚‚Q d
{
‚‚d e
string
‚‚e k
.
‚‚k l
Join
‚‚l p
(
‚‚p q
$str
‚‚q u
,
‚‚u v
column
‚‚w }
.
‚‚} ~
Options‚‚~ Ö
)‚‚Ö Ü
}‚‚Ü á
"‚‚á à
;‚‚à â
}
„„ 
help
‰‰ 
.
‰‰ 
Cell
‰‰ 
(
‰‰ 
i
‰‰ 
+
‰‰ 
$num
‰‰ 
,
‰‰ 
$num
‰‰ 
)
‰‰ 
.
‰‰  
Value
‰‰  %
=
‰‰& '
column
‰‰( .
.
‰‰. /
Name
‰‰/ 3
;
‰‰3 4
help
‰‰5 9
.
‰‰9 :
Cell
‰‰: >
(
‰‰> ?
i
‰‰? @
+
‰‰A B
$num
‰‰C D
,
‰‰D E
$num
‰‰F G
)
‰‰G H
.
‰‰H I
Value
‰‰I N
=
‰‰O P
column
‰‰Q W
.
‰‰W X
Required
‰‰X `
?
‰‰a b
$str
‰‰c g
:
‰‰h i
$str
‰‰j n
;
‰‰n o
help
‰‰p t
.
‰‰t u
Cell
‰‰u y
(
‰‰y z
i
‰‰z {
+
‰‰| }
$num
‰‰~ 
,‰‰ Ä
$num‰‰Å Ç
)‰‰Ç É
.‰‰É Ñ
Value‰‰Ñ â
=‰‰ä ã
accepted‰‰å î
;‰‰î ï
}
ÂÂ 	
sheet
ÊÊ 
.
ÊÊ 
Row
ÊÊ 
(
ÊÊ 
$num
ÊÊ 
)
ÊÊ 
.
ÊÊ 
Style
ÊÊ 
.
ÊÊ 
Font
ÊÊ 
.
ÊÊ  
Bold
ÊÊ  $
=
ÊÊ% &
true
ÊÊ' +
;
ÊÊ+ ,
sheet
ÊÊ- 2
.
ÊÊ2 3
Columns
ÊÊ3 :
(
ÊÊ: ;
)
ÊÊ; <
.
ÊÊ< =
AdjustToContents
ÊÊ= M
(
ÊÊM N
)
ÊÊN O
;
ÊÊO P
help
ÊÊQ U
.
ÊÊU V
Columns
ÊÊV ]
(
ÊÊ] ^
)
ÊÊ^ _
.
ÊÊ_ `
AdjustToContents
ÊÊ` p
(
ÊÊp q
)
ÊÊq r
;
ÊÊr s
help
ÁÁ 
.
ÁÁ 
Cell
ÁÁ 
(
ÁÁ 
columns
ÁÁ 
.
ÁÁ 
Length
ÁÁ  
+
ÁÁ! "
$num
ÁÁ# $
,
ÁÁ$ %
$num
ÁÁ& '
)
ÁÁ' (
.
ÁÁ( )
Value
ÁÁ) .
=
ÁÁ/ 0
$strÁÁ1 ñ
;ÁÁñ ó
using
ËË 
var
ËË 
stream
ËË 
=
ËË 
new
ËË 
MemoryStream
ËË +
(
ËË+ ,
)
ËË, -
;
ËË- .
book
ËË/ 3
.
ËË3 4
SaveAs
ËË4 :
(
ËË: ;
stream
ËË; A
)
ËËA B
;
ËËB C
return
ËËD J
stream
ËËK Q
.
ËËQ R
ToArray
ËËR Y
(
ËËY Z
)
ËËZ [
;
ËË[ \
}
ÈÈ 
private
ÍÍ 
static
ÍÍ 
string
ÍÍ 
?
ÍÍ 
EmptyToNull
ÍÍ &
(
ÍÍ& '
string
ÍÍ' -
?
ÍÍ- .
value
ÍÍ/ 4
)
ÍÍ4 5
=>
ÍÍ6 8
string
ÍÍ9 ?
.
ÍÍ? @ 
IsNullOrWhiteSpace
ÍÍ@ R
(
ÍÍR S
value
ÍÍS X
)
ÍÍX Y
?
ÍÍZ [
null
ÍÍ\ `
:
ÍÍa b
value
ÍÍc h
.
ÍÍh i
Trim
ÍÍi m
(
ÍÍm n
)
ÍÍn o
;
ÍÍo p
private
ÎÎ 
static
ÎÎ 
string
ÎÎ 
?
ÎÎ 
ValidateClient
ÎÎ )
(
ÎÎ) *
ClientRequest
ÎÎ* 7
request
ÎÎ8 ?
)
ÎÎ? @
=>
ÎÎA C
string
ÎÎD J
.
ÎÎJ K 
IsNullOrWhiteSpace
ÎÎK ]
(
ÎÎ] ^
request
ÎÎ^ e
.
ÎÎe f
CompanyName
ÎÎf q
)
ÎÎq r
||
ÎÎs u
string
ÎÎv |
.
ÎÎ| }!
IsNullOrWhiteSpaceÎÎ} è
(ÎÎè ê
requestÎÎê ó
.ÎÎó ò
ContactNameÎÎò £
)ÎÎ£ §
||ÎÎ• ß
stringÎÎ® Æ
.ÎÎÆ Ø"
IsNullOrWhiteSpaceÎÎØ ¡
(ÎÎ¡ ¬
requestÎÎ¬ …
.ÎÎ…  
EmailÎÎ  œ
)ÎÎœ –
||ÎÎ— ”
!ÎÎ‘ ’
requestÎÎ’ ‹
.ÎÎ‹ ›
EmailÎÎ› ‚
.ÎÎ‚ „
ContainsÎÎ„ Î
(ÎÎÎ Ï
$charÎÎÏ Ô
)ÎÎÔ 
?ÎÎÒ Ú
$strÎÎÛ ß
:ÎÎ® ©
requestÎÎ™ ±
.ÎÎ± ≤!
PreferredLanguageÎÎ≤ √
.ÎÎ√ ƒ
TrimÎÎƒ »
(ÎÎ» …
)ÎÎ…  
.ÎÎ  À 
ToLowerInvariantÎÎÀ €
(ÎÎ€ ‹
)ÎÎ‹ ›
isÎÎﬁ ‡
notÎÎ· ‰
(ÎÎÂ Ê
$strÎÎÊ Í
orÎÎÎ Ì
$strÎÎÓ Ú
orÎÎÛ ı
$strÎÎˆ ˙
)ÎÎ˙ ˚
?ÎÎ¸ ˝
$strÎÎ˛ ê
:ÎÎë í
nullÎÎì ó
;ÎÎó ò
private
ÏÏ 
static
ÏÏ 
string
ÏÏ 
?
ÏÏ 
ValidateProduct
ÏÏ *
(
ÏÏ* +
ProductRequest
ÏÏ+ 9
request
ÏÏ: A
)
ÏÏA B
=>
ÏÏC E
string
ÏÏF L
.
ÏÏL M 
IsNullOrWhiteSpace
ÏÏM _
(
ÏÏ_ `
request
ÏÏ` g
.
ÏÏg h
Name
ÏÏh l
)
ÏÏl m
||
ÏÏn p
string
ÏÏq w
.
ÏÏw x!
IsNullOrWhiteSpaceÏÏx ä
(ÏÏä ã
requestÏÏã í
.ÏÏí ì
CurrencyÏÏì õ
)ÏÏõ ú
?ÏÏù û
$strÏÏü ¬
:ÏÏ√ ƒ
nullÏÏ≈ …
;ÏÏ…  
private
ÓÓ 
async
ÓÓ 
Task
ÓÓ (
EnsureProductCategoryAsync
ÓÓ 1
(
ÓÓ1 2
string
ÓÓ2 8
?
ÓÓ8 9
name
ÓÓ: >
,
ÓÓ> ?
CancellationToken
ÓÓ@ Q
ct
ÓÓR T
)
ÓÓT U
{
ÔÔ 
if
 

(
 
string
 
.
  
IsNullOrWhiteSpace
 %
(
% &
name
& *
)
* +
)
+ ,
return
- 3
;
3 4
name
ÒÒ 
=
ÒÒ 
name
ÒÒ 
.
ÒÒ 
Trim
ÒÒ 
(
ÒÒ 
)
ÒÒ 
;
ÒÒ 
if
ÚÚ 

(
ÚÚ 
db
ÚÚ 
.
ÚÚ 
ProductCategories
ÚÚ  
.
ÚÚ  !
Local
ÚÚ! &
.
ÚÚ& '
Any
ÚÚ' *
(
ÚÚ* +
x
ÚÚ+ ,
=>
ÚÚ- /
x
ÚÚ0 1
.
ÚÚ1 2
Name
ÚÚ2 6
.
ÚÚ6 7
Equals
ÚÚ7 =
(
ÚÚ= >
name
ÚÚ> B
,
ÚÚB C
StringComparison
ÚÚD T
.
ÚÚT U
OrdinalIgnoreCase
ÚÚU f
)
ÚÚf g
)
ÚÚg h
||
ÚÚi k
await
ÚÚl q
db
ÚÚr t
.
ÚÚt u 
ProductCategoriesÚÚu Ü
.ÚÚÜ á
AnyAsyncÚÚá è
(ÚÚè ê
xÚÚê ë
=>ÚÚí î
xÚÚï ñ
.ÚÚñ ó
NameÚÚó õ
==ÚÚú û
nameÚÚü £
,ÚÚ£ §
ctÚÚ• ß
)ÚÚß ®
)ÚÚ® ©
returnÚÚ™ ∞
;ÚÚ∞ ±
db
ÛÛ 

.
ÛÛ
 
ProductCategories
ÛÛ 
.
ÛÛ 
Add
ÛÛ  
(
ÛÛ  !
new
ÛÛ! $
ProductCategory
ÛÛ% 4
{
ÛÛ5 6
Name
ÛÛ7 ;
=
ÛÛ< =
name
ÛÛ> B
,
ÛÛB C
	SortOrder
ÛÛD M
=
ÛÛN O
await
ÛÛP U
db
ÛÛV X
.
ÛÛX Y
ProductCategories
ÛÛY j
.
ÛÛj k

CountAsync
ÛÛk u
(
ÛÛu v
ct
ÛÛv x
)
ÛÛx y
+
ÛÛz {
db
ÛÛ| ~
.
ÛÛ~  
ProductCategoriesÛÛ ê
.ÛÛê ë
LocalÛÛë ñ
.ÛÛñ ó
CountÛÛó ú
}ÛÛù û
)ÛÛû ü
;ÛÛü †
}
ÙÙ 
internal
˜˜ 
static
˜˜ 
string
˜˜ 
Fold
˜˜ 
(
˜˜  
string
˜˜  &
value
˜˜' ,
)
˜˜, -
=>
˜˜. 0
new
˜˜1 4
(
˜˜4 5
value
˜˜5 :
.
˜˜: ;
Trim
˜˜; ?
(
˜˜? @
)
˜˜@ A
.
˜˜A B
ToLowerInvariant
˜˜B R
(
˜˜R S
)
˜˜S T
.
˜˜T U
	Normalize
˜˜U ^
(
˜˜^ _
System
˜˜_ e
.
˜˜e f
Text
˜˜f j
.
˜˜j k
NormalizationForm
˜˜k |
.
˜˜| }
FormD˜˜} Ç
)˜˜Ç É
.
¯¯ 	
Where
¯¯	 
(
¯¯ 
c
¯¯ 
=>
¯¯ 
System
¯¯ 
.
¯¯ 
Globalization
¯¯ (
.
¯¯( )
CharUnicodeInfo
¯¯) 8
.
¯¯8 9 
GetUnicodeCategory
¯¯9 K
(
¯¯K L
c
¯¯L M
)
¯¯M N
!=
¯¯O Q
System
¯¯R X
.
¯¯X Y
Globalization
¯¯Y f
.
¯¯f g
UnicodeCategory
¯¯g v
.
¯¯v w
NonSpacingMark¯¯w Ö
)¯¯Ö Ü
.¯¯Ü á
ToArray¯¯á é
(¯¯é è
)¯¯è ê
)¯¯ê ë
;¯¯ë í
private
˙˙ 
static
˙˙ 
Product
˙˙ 
	ToProduct
˙˙ $
(
˙˙$ %
ProductRequest
˙˙% 3
r
˙˙4 5
)
˙˙5 6
=>
˙˙7 9
new
˙˙: =
(
˙˙= >
)
˙˙> ?
{
˙˙@ A
Type
˙˙B F
=
˙˙G H
r
˙˙I J
.
˙˙J K
Type
˙˙K O
,
˙˙O P
Name
˙˙Q U
=
˙˙V W
r
˙˙X Y
.
˙˙Y Z
Name
˙˙Z ^
.
˙˙^ _
Trim
˙˙_ c
(
˙˙c d
)
˙˙d e
,
˙˙e f
BillingCycle
˙˙g s
=
˙˙t u
r
˙˙v w
.
˙˙w x
BillingCycle˙˙x Ñ
,˙˙Ñ Ö
	BasePrice˙˙Ü è
=˙˙ê ë
r˙˙í ì
.˙˙ì î
	BasePrice˙˙î ù
,˙˙ù û
Currency˙˙ü ß
=˙˙® ©
r˙˙™ ´
.˙˙´ ¨
Currency˙˙¨ ¥
.˙˙¥ µ
Trim˙˙µ π
(˙˙π ∫
)˙˙∫ ª
.˙˙ª º 
ToUpperInvariant˙˙º Ã
(˙˙Ã Õ
)˙˙Õ Œ
,˙˙Œ œ
Description˙˙– €
=˙˙‹ ›
EmptyToNull˙˙ﬁ È
(˙˙È Í
r˙˙Í Î
.˙˙Î Ï
Description˙˙Ï ˜
)˙˙˜ ¯
,˙˙¯ ˘
IsActive˙˙˙ Ç
=˙˙É Ñ
r˙˙Ö Ü
.˙˙Ü á
IsActive˙˙á è
,˙˙è ê
TaxDocumentType˙˙ë †
=˙˙° ¢
r˙˙£ §
.˙˙§ •
TaxDocumentType˙˙• ¥
,˙˙¥ µ
Category˙˙∂ æ
=˙˙ø ¿
EmptyToNull˙˙¡ Ã
(˙˙Ã Õ
r˙˙Õ Œ
.˙˙Œ œ
Category˙˙œ ◊
)˙˙◊ ÿ
,˙˙ÿ Ÿ
Tags˙˙⁄ ﬁ
=˙˙ﬂ ‡
NormalizeTags˙˙· Ó
(˙˙Ó Ô
r˙˙Ô 
.˙˙ Ò
Tags˙˙Ò ı
)˙˙ı ˆ
,˙˙ˆ ˜
AllowsTickets˙˙¯ Ö
=˙˙Ü á
r˙˙à â
.˙˙â ä
AllowsTickets˙˙ä ó
}˙˙ò ô
;˙˙ô ö
private
¸¸ 
static
¸¸ 
string
¸¸ 
?
¸¸ 
NormalizeTags
¸¸ (
(
¸¸( )
string
¸¸) /
?
¸¸/ 0
tags
¸¸1 5
)
¸¸5 6
=>
¸¸7 9
tags
¸¸: >
?
¸¸> ?
.
¸¸? @
Split
¸¸@ E
(
¸¸E F
$char
¸¸F I
,
¸¸I J 
StringSplitOptions
¸¸K ]
.
¸¸] ^ 
RemoveEmptyEntries
¸¸^ p
|
¸¸q r!
StringSplitOptions¸¸s Ö
.¸¸Ö Ü
TrimEntries¸¸Ü ë
)¸¸ë í
.¸¸í ì
Distinct¸¸ì õ
(¸¸õ ú
StringComparer¸¸ú ™
.¸¸™ ´!
OrdinalIgnoreCase¸¸´ º
)¸¸º Ω
.¸¸Ω æ
ToArray¸¸æ ≈
(¸¸≈ ∆
)¸¸∆ «
is¸¸»  
{¸¸À Ã
Length¸¸Õ ”
:¸¸” ‘
>¸¸’ ÷
$num¸¸◊ ÿ
}¸¸Ÿ ⁄
list¸¸€ ﬂ
?¸¸‡ ·
string¸¸‚ Ë
.¸¸Ë È
Join¸¸È Ì
(¸¸Ì Ó
$str¸¸Ó Ú
,¸¸Ú Û
list¸¸Ù ¯
)¸¸¯ ˘
:¸¸˙ ˚
null¸¸¸ Ä
;¸¸Ä Å
private
˝˝ 
static
˝˝ 
object
˝˝ 
	ClientDto
˝˝ #
(
˝˝# $
Client
˝˝$ *
x
˝˝+ ,
)
˝˝, -
=>
˝˝. 0
new
˝˝1 4
{
˝˝5 6
id
˝˝7 9
=
˝˝: ;
x
˝˝< =
.
˝˝= >
Id
˝˝> @
,
˝˝@ A
companyName
˝˝B M
=
˝˝N O
x
˝˝P Q
.
˝˝Q R
CompanyName
˝˝R ]
,
˝˝] ^
contactName
˝˝_ j
=
˝˝k l
x
˝˝m n
.
˝˝n o
ContactName
˝˝o z
,
˝˝z {
email˝˝| Å
=˝˝Ç É
x˝˝Ñ Ö
.˝˝Ö Ü
Email˝˝Ü ã
,˝˝ã å
phone˝˝ç í
=˝˝ì î
x˝˝ï ñ
.˝˝ñ ó
Phone˝˝ó ú
,˝˝ú ù!
preferredLanguage˝˝û Ø
=˝˝∞ ±
x˝˝≤ ≥
.˝˝≥ ¥!
PreferredLanguage˝˝¥ ≈
,˝˝≈ ∆
isActive˝˝« œ
=˝˝– —
x˝˝“ ”
.˝˝” ‘
IsActive˝˝‘ ‹
,˝˝‹ ›#
requiresTaxDocument˝˝ﬁ Ò
=˝˝Ú Û
x˝˝Ù ı
.˝˝ı ˆ#
RequiresTaxDocument˝˝ˆ â
}˝˝ä ã
;˝˝ã å
private
˛˛ 
static
˛˛ 
object
˛˛ 

ProjectDto
˛˛ $
(
˛˛$ %
Project
˛˛% ,
x
˛˛- .
)
˛˛. /
=>
˛˛0 2
new
˛˛3 6
{
˛˛7 8
id
˛˛9 ;
=
˛˛< =
x
˛˛> ?
.
˛˛? @
Id
˛˛@ B
,
˛˛B C
clientId
˛˛D L
=
˛˛M N
x
˛˛O P
.
˛˛P Q
ClientId
˛˛Q Y
,
˛˛Y Z
name
˛˛[ _
=
˛˛` a
x
˛˛b c
.
˛˛c d
Name
˛˛d h
,
˛˛h i
slug
˛˛j n
=
˛˛o p
x
˛˛q r
.
˛˛r s
Slug
˛˛s w
,
˛˛w x
repositories˛˛y Ö
=˛˛Ü á
x˛˛à â
.˛˛â ä
Repositories˛˛ä ñ
.˛˛ñ ó!
OrderByDescending˛˛ó ®
(˛˛® ©
r˛˛© ™
=>˛˛´ ≠
r˛˛Æ Ø
.˛˛Ø ∞
	IsDefault˛˛∞ π
)˛˛π ∫
.˛˛∫ ª
ThenBy˛˛ª ¡
(˛˛¡ ¬
r˛˛¬ √
=>˛˛ƒ ∆
r˛˛« »
.˛˛» …
Name˛˛… Õ
)˛˛Õ Œ
.˛˛Œ œ
Select˛˛œ ’
(˛˛’ ÷
r˛˛÷ ◊
=>˛˛ÿ ⁄
new˛˛€ ﬁ
{˛˛ﬂ ‡
id˛˛· „
=˛˛‰ Â
r˛˛Ê Á
.˛˛Á Ë
Id˛˛Ë Í
,˛˛Í Î
owner˛˛Ï Ò
=˛˛Ú Û
r˛˛Ù ı
.˛˛ı ˆ
Owner˛˛ˆ ˚
,˛˛˚ ¸
name˛˛˝ Å
=˛˛Ç É
r˛˛Ñ Ö
.˛˛Ö Ü
Name˛˛Ü ä
,˛˛ä ã
label˛˛å ë
=˛˛í ì
r˛˛î ï
.˛˛ï ñ
Label˛˛ñ õ
,˛˛õ ú
	isDefault˛˛ù ¶
=˛˛ß ®
r˛˛© ™
.˛˛™ ´
	IsDefault˛˛´ ¥
}˛˛µ ∂
)˛˛∂ ∑
}˛˛∏ π
;˛˛π ∫
private
ˇˇ 
static
ˇˇ 
object
ˇˇ 

ProductDto
ˇˇ $
(
ˇˇ$ %
Product
ˇˇ% ,
x
ˇˇ- .
)
ˇˇ. /
=>
ˇˇ0 2
new
ˇˇ3 6
{
ˇˇ7 8
id
ˇˇ9 ;
=
ˇˇ< =
x
ˇˇ> ?
.
ˇˇ? @
Id
ˇˇ@ B
,
ˇˇB C
type
ˇˇD H
=
ˇˇI J
x
ˇˇK L
.
ˇˇL M
Type
ˇˇM Q
.
ˇˇQ R
ToString
ˇˇR Z
(
ˇˇZ [
)
ˇˇ[ \
,
ˇˇ\ ]
name
ˇˇ^ b
=
ˇˇc d
x
ˇˇe f
.
ˇˇf g
Name
ˇˇg k
,
ˇˇk l
billingCycle
ˇˇm y
=
ˇˇz {
x
ˇˇ| }
.
ˇˇ} ~
BillingCycleˇˇ~ ä
.ˇˇä ã
ToStringˇˇã ì
(ˇˇì î
)ˇˇî ï
,ˇˇï ñ
	basePriceˇˇó †
=ˇˇ° ¢
xˇˇ£ §
.ˇˇ§ •
	BasePriceˇˇ• Æ
,ˇˇÆ Ø
currencyˇˇ∞ ∏
=ˇˇπ ∫
xˇˇª º
.ˇˇº Ω
CurrencyˇˇΩ ≈
,ˇˇ≈ ∆
descriptionˇˇ« “
=ˇˇ” ‘
xˇˇ’ ÷
.ˇˇ÷ ◊
Descriptionˇˇ◊ ‚
,ˇˇ‚ „
isActiveˇˇ‰ Ï
=ˇˇÌ Ó
xˇˇÔ 
.ˇˇ Ò
IsActiveˇˇÒ ˘
,ˇˇ˘ ˙
taxDocumentTypeˇˇ˚ ä
=ˇˇã å
xˇˇç é
.ˇˇé è
TaxDocumentTypeˇˇè û
.ˇˇû ü
ToStringˇˇü ß
(ˇˇß ®
)ˇˇ® ©
,ˇˇ© ™
categoryˇˇ´ ≥
=ˇˇ¥ µ
xˇˇ∂ ∑
.ˇˇ∑ ∏
Categoryˇˇ∏ ¿
,ˇˇ¿ ¡
tagsˇˇ¬ ∆
=ˇˇ« »
xˇˇ…  
.ˇˇ  À
TagsˇˇÀ œ
,ˇˇœ –
allowsTicketsˇˇ— ﬁ
=ˇˇﬂ ‡
xˇˇ· ‚
.ˇˇ‚ „
AllowsTicketsˇˇ„ 
}ˇˇÒ Ú
;ˇˇÚ Û
private
ÄÄ 
async
ÄÄ 
Task
ÄÄ 
<
ÄÄ 
object
ÄÄ 
>
ÄÄ #
ClientProductDtoAsync
ÄÄ 4
(
ÄÄ4 5
ClientProduct
ÄÄ5 B
x
ÄÄC D
,
ÄÄD E
CancellationToken
ÄÄF W
ct
ÄÄX Z
)
ÄÄZ [
=>
ÄÄ\ ^
ClientProductDto
ÄÄ_ o
(
ÄÄo p
x
ÄÄp q
,
ÄÄq r
x
ÄÄs t
.
ÄÄt u
Product
ÄÄu |
is
ÄÄ} 
nullÄÄÄ Ñ
?ÄÄÖ Ü
$numÄÄá â
:ÄÄä ã
awaitÄÄå ë
dbÄÄí î
.ÄÄî ï
IgvRateForAsyncÄÄï §
(ÄÄ§ •
xÄÄ• ¶
.ÄÄ¶ ß
ClientIdÄÄß Ø
,ÄÄØ ∞
xÄÄ± ≤
.ÄÄ≤ ≥
ProductÄÄ≥ ∫
,ÄÄ∫ ª
ctÄÄº æ
)ÄÄæ ø
)ÄÄø ¿
;ÄÄ¿ ¡
private
ÇÇ 
static
ÇÇ 
object
ÇÇ 
ClientProductDto
ÇÇ *
(
ÇÇ* +
ClientProduct
ÇÇ+ 8
x
ÇÇ9 :
,
ÇÇ: ;
decimal
ÇÇ< C
igvRate
ÇÇD K
)
ÇÇK L
=>
ÇÇM O
new
ÇÇP S
{
ÇÇT U
igvRate
ÇÇV ]
,
ÇÇ] ^
nextChargeTotal
ÇÇ_ n
=
ÇÇo p
x
ÇÇq r
.
ÇÇr s
NextChargeTotalÇÇs Ç
(ÇÇÇ É
igvRateÇÇÉ ä
)ÇÇä ã
,ÇÇã å
idÇÇç è
=ÇÇê ë
xÇÇí ì
.ÇÇì î
IdÇÇî ñ
,ÇÇñ ó
clientIdÇÇò †
=ÇÇ° ¢
xÇÇ£ §
.ÇÇ§ •
ClientIdÇÇ• ≠
,ÇÇ≠ Æ
	projectIdÇÇØ ∏
=ÇÇπ ∫
xÇÇª º
.ÇÇº Ω
	ProjectIdÇÇΩ ∆
,ÇÇ∆ «
projectNameÇÇ» ”
=ÇÇ‘ ’
xÇÇ÷ ◊
.ÇÇ◊ ÿ
ProjectÇÇÿ ﬂ
?ÇÇﬂ ‡
.ÇÇ‡ ·
NameÇÇ· Â
,ÇÇÂ Ê
	productIdÇÇÁ 
=ÇÇÒ Ú
xÇÇÛ Ù
.ÇÇÙ ı
	ProductIdÇÇı ˛
,ÇÇ˛ ˇ
productNameÇÇÄ ã
=ÇÇå ç
xÇÇé è
.ÇÇè ê
ProductÇÇê ó
?ÇÇó ò
.ÇÇò ô
NameÇÇô ù
,ÇÇù û
productTypeÇÇü ™
=ÇÇ´ ¨
xÇÇ≠ Æ
.ÇÇÆ Ø
ProductÇÇØ ∂
?ÇÇ∂ ∑
.ÇÇ∑ ∏
TypeÇÇ∏ º
.ÇÇº Ω
ToStringÇÇΩ ≈
(ÇÇ≈ ∆
)ÇÇ∆ «
,ÇÇ« »
currencyÇÇ… —
=ÇÇ“ ”
xÇÇ‘ ’
.ÇÇ’ ÷
ProductÇÇ÷ ›
?ÇÇ› ﬁ
.ÇÇﬁ ﬂ
CurrencyÇÇﬂ Á
??ÇÇË Í
$strÇÇÎ 
,ÇÇ Ò
billingCycleÇÇÚ ˛
=ÇÇˇ Ä
xÇÇÅ Ç
.ÇÇÇ É
BillingCycleÇÇÉ è
.ÇÇè ê
ToStringÇÇê ò
(ÇÇò ô
)ÇÇô ö
,ÇÇö õ
isManualBillingÇÇú ´
=ÇÇ¨ ≠
xÇÇÆ Ø
.ÇÇØ ∞
IsManualBillingÇÇ∞ ø
,ÇÇø ¿
statusÇÇ¡ «
=ÇÇ» …
xÇÇ  À
.ÇÇÀ Ã
StatusÇÇÃ “
.ÇÇ“ ”
ToStringÇÇ” €
(ÇÇ€ ‹
)ÇÇ‹ ›
,ÇÇ› ﬁ
priceÇÇﬂ ‰
=ÇÇÂ Ê
xÇÇÁ Ë
.ÇÇË È
PriceÇÇÈ Ó
,ÇÇÓ Ô
	listPriceÇÇ ˘
=ÇÇ˙ ˚
xÇÇ¸ ˝
.ÇÇ˝ ˛
	ListPriceÇÇ˛ á
(ÇÇá à
)ÇÇà â
,ÇÇâ ä
discountÇÇã ì
=ÇÇî ï
xÇÇñ ó
.ÇÇó ò
DiscountÇÇò †
,ÇÇ† °
discountEndsAtÇÇ¢ ∞
=ÇÇ± ≤
xÇÇ≥ ¥
.ÇÇ¥ µ
DiscountEndsAtÇÇµ √
==ÇÇƒ ∆$
ClientProductPricingÇÇ« €
.ÇÇ€ ‹
NoEndÇÇ‹ ·
?ÇÇ‚ „
nullÇÇ‰ Ë
:ÇÇÈ Í
xÇÇÎ Ï
.ÇÇÏ Ì
DiscountEndsAtÇÇÌ ˚
,ÇÇ˚ ¸
currentPriceÇÇ˝ â
=ÇÇä ã
xÇÇå ç
.ÇÇç é
CurrentPriceÇÇé ö
(ÇÇö õ
DateTimeÇÇõ £
.ÇÇ£ §
UtcNowÇÇ§ ™
)ÇÇ™ ´
,ÇÇ´ ¨
nextChargePriceÇÇ≠ º
=ÇÇΩ æ
xÇÇø ¿
.ÇÇ¿ ¡
NextChargePriceÇÇ¡ –
(ÇÇ– —
)ÇÇ— “
,ÇÇ“ ”

domainNameÇÇ‘ ﬁ
=ÇÇﬂ ‡
xÇÇ· ‚
.ÇÇ‚ „

DomainNameÇÇ„ Ì
,ÇÇÌ Ó"
priceLabelOverrideÇÇÔ Å
=ÇÇÇ É
xÇÇÑ Ö
.ÇÇÖ Ü"
PriceLabelOverrideÇÇÜ ò
,ÇÇò ô
renewsAtÇÇö ¢
=ÇÇ£ §
xÇÇ• ¶
.ÇÇ¶ ß
RenewsAtÇÇß Ø
,ÇÇØ ∞
nextChargeAtÇÇ± Ω
=ÇÇæ ø
xÇÇ¿ ¡
.ÇÇ¡ ¬
NextChargeAtÇÇ¬ Œ
}ÇÇœ –
;ÇÇ– —
private
ÑÑ 
static
ÑÑ 
object
ÑÑ 
TaxDocumentDto
ÑÑ (
(
ÑÑ( )
TaxDocument
ÑÑ) 4
x
ÑÑ5 6
,
ÑÑ6 7
decimal
ÑÑ8 ?
	rateToPen
ÑÑ@ I
,
ÑÑI J
IEnumerable
ÑÑK V
<
ÑÑV W
TaxDocumentLine
ÑÑW f
>
ÑÑf g
lines
ÑÑh m
,
ÑÑm n
string
ÑÑo u
?
ÑÑu v
paymentMethodÑÑw Ñ
)ÑÑÑ Ö
=>ÑÑÜ à
newÑÑâ å
{ÑÑç é
paymentMethodÑÑè ú
,ÑÑú ù
linesÑÑû £
=ÑÑ§ •
linesÑÑ¶ ´
.ÑÑ´ ¨
SelectÑÑ¨ ≤
(ÑÑ≤ ≥
lÑÑ≥ ¥
=>ÑÑµ ∑
newÑÑ∏ ª
{ÑÑº Ω
clientProductIdÑÑæ Õ
=ÑÑŒ œ
lÑÑ– —
.ÑÑ— “
ClientProductIdÑÑ“ ·
,ÑÑ· ‚
descriptionÑÑ„ Ó
=ÑÑÔ 
lÑÑÒ Ú
.ÑÑÚ Û
DescriptionÑÑÛ ˛
,ÑÑ˛ ˇ
amountÑÑÄ Ü
=ÑÑá à
lÑÑâ ä
.ÑÑä ã
AmountÑÑã ë
}ÑÑí ì
)ÑÑì î
.ÑÑî ï
ToListÑÑï õ
(ÑÑõ ú
)ÑÑú ù
,ÑÑù û
idÑÑü °
=ÑÑ¢ £
xÑÑ§ •
.ÑÑ• ¶
IdÑÑ¶ ®
,ÑÑ® ©$
paymentTransactionIdÑÑ™ æ
=ÑÑø ¿
xÑÑ¡ ¬
.ÑÑ¬ √$
PaymentTransactionIdÑÑ√ ◊
,ÑÑ◊ ÿ
clientIdÑÑŸ ·
=ÑÑ‚ „
xÑÑ‰ Â
.ÑÑÂ Ê
ClientIdÑÑÊ Ó
,ÑÑÓ Ô
typeÑÑ Ù
=ÑÑı ˆ
xÑÑ˜ ¯
.ÑÑ¯ ˘
TypeÑÑ˘ ˝
.ÑÑ˝ ˛
ToStringÑÑ˛ Ü
(ÑÑÜ á
)ÑÑá à
,ÑÑà â
seriesÑÑä ê
=ÑÑë í
xÑÑì î
.ÑÑî ï
SeriesÑÑï õ
,ÑÑõ ú
numberÑÑù £
=ÑÑ§ •
xÑÑ¶ ß
.ÑÑß ®
NumberÑÑ® Æ
,ÑÑÆ Ø
	issueDateÑÑ∞ π
=ÑÑ∫ ª
xÑÑº Ω
.ÑÑΩ æ
	IssueDateÑÑæ «
,ÑÑ« »
currencyÑÑ… —
=ÑÑ“ ”
xÑÑ‘ ’
.ÑÑ’ ÷
CurrencyÑÑ÷ ﬁ
,ÑÑﬁ ﬂ

baseAmountÑÑ‡ Í
=ÑÑÎ Ï
xÑÑÌ Ó
.ÑÑÓ Ô

BaseAmountÑÑÔ ˘
,ÑÑ˘ ˙
	igvAmountÑÑ˚ Ñ
=ÑÑÖ Ü
xÑÑá à
.ÑÑà â
	IgvAmountÑÑâ í
,ÑÑí ì
totalAmountÑÑî ü
=ÑÑ† °
xÑÑ¢ £
.ÑÑ£ §
TotalAmountÑÑ§ Ø
,ÑÑØ ∞
notesÑÑ± ∂
=ÑÑ∑ ∏
xÑÑπ ∫
.ÑÑ∫ ª
NotesÑÑª ¿
,ÑÑ¿ ¡
retentionAmountÑÑ¬ —
=ÑÑ“ ”
xÑÑ‘ ’
.ÑÑ’ ÷
RetentionAmountÑÑ÷ Â
,ÑÑÂ Ê
exchangeRate
ÖÖ 
=
ÖÖ 
x
ÖÖ 
.
ÖÖ 
Currency
ÖÖ !
==
ÖÖ" $
$str
ÖÖ% *
?
ÖÖ+ ,
$num
ÖÖ- /
:
ÖÖ0 1
Math
ÖÖ2 6
.
ÖÖ6 7
Round
ÖÖ7 <
(
ÖÖ< =
	rateToPen
ÖÖ= F
,
ÖÖF G
$num
ÖÖH I
)
ÖÖI J
,
ÖÖJ K
basePen
ÖÖL S
=
ÖÖT U
Math
ÖÖV Z
.
ÖÖZ [
Round
ÖÖ[ `
(
ÖÖ` a
x
ÖÖa b
.
ÖÖb c

BaseAmount
ÖÖc m
*
ÖÖn o
	rateToPen
ÖÖp y
,
ÖÖy z
$num
ÖÖ{ |
)
ÖÖ| }
,
ÖÖ} ~
igvPenÖÖ Ö
=ÖÖÜ á
MathÖÖà å
.ÖÖå ç
RoundÖÖç í
(ÖÖí ì
xÖÖì î
.ÖÖî ï
	IgvAmountÖÖï û
*ÖÖü †
	rateToPenÖÖ° ™
,ÖÖ™ ´
$numÖÖ¨ ≠
)ÖÖ≠ Æ
,ÖÖÆ Ø
totalPenÖÖ∞ ∏
=ÖÖπ ∫
MathÖÖª ø
.ÖÖø ¿
RoundÖÖ¿ ≈
(ÖÖ≈ ∆
xÖÖ∆ «
.ÖÖ« »
TotalAmountÖÖ» ”
*ÖÖ‘ ’
	rateToPenÖÖ÷ ﬂ
,ÖÖﬂ ‡
$numÖÖ· ‚
)ÖÖ‚ „
}ÖÖ‰ Â
;ÖÖÂ Ê
private
áá 
static
áá 
void
áá !
ApplyForeignService
áá +
(
áá+ ,
Expense
áá, 3
expense
áá4 ;
,
áá; <
bool
áá= A
foreign
ááB I
,
ááI J
string
ááK Q
?
ááQ R
name
ááS W
,
ááW X
string
ááY _
?
áá_ `
country
ááa h
)
ááh i
{
àà 
expense
ââ 
.
ââ #
IsNonDomiciledService
ââ %
=
ââ& '
foreign
ââ( /
;
ââ/ 0
(
ää 	
expense
ää	 
.
ää !
ForeignSupplierName
ää $
,
ää$ %
expense
ää& -
.
ää- .$
ForeignSupplierCountry
ää. D
)
ääD E
=
ääF G
foreign
ääH O
?
ääP Q
(
ääR S
EmptyToNull
ääS ^
(
ää^ _
name
ää_ c
)
ääc d
,
ääd e
EmptyToNull
ääf q
(
ääq r
country
äär y
)
ääy z
)
ääz {
:
ää| }
(
ää~ 
nullää É
,ääÉ Ñ
nullääÖ â
)ääâ ä
;äää ã
if
ãã 

(
ãã 
!
ãã 
foreign
ãã 
)
ãã 
(
ãã 
expense
ãã 
.
ãã 
Form1662PaidAt
ãã -
,
ãã- .
expense
ãã/ 6
.
ãã6 7
Form1662Number
ãã7 E
)
ããE F
=
ããG H
(
ããI J
null
ããJ N
,
ããN O
null
ããP T
)
ããT U
;
ããU V
}
åå 
private
éé 
static
éé 
object
éé 

ExpenseDto
éé $
(
éé$ %
Expense
éé% ,
x
éé- .
)
éé. /
=>
éé0 2
new
éé3 6
{
éé7 8
id
éé9 ;
=
éé< =
x
éé> ?
.
éé? @
Id
éé@ B
,
ééB C
description
ééD O
=
ééP Q
x
ééR S
.
ééS T
Description
ééT _
,
éé_ `

categoryId
ééa k
=
éél m
x
één o
.
ééo p

CategoryId
éép z
,
ééz {
categoryNameéé| à
=ééâ ä
xééã å
.ééå ç
Categoryééç ï
?ééï ñ
.ééñ ó
Nameééó õ
??ééú û
$strééü °
,éé° ¢
typeéé£ ß
=éé® ©
xéé™ ´
.éé´ ¨
Typeéé¨ ∞
.éé∞ ±
ToStringéé± π
(ééπ ∫
)éé∫ ª
,ééª º
amountééΩ √
=ééƒ ≈
xéé∆ «
.éé« »
Amountéé» Œ
,ééŒ œ
currencyéé– ÿ
=ééŸ ⁄
xéé€ ‹
.éé‹ ›
Currencyéé› Â
,ééÂ Ê
	amountPenééÁ 
=ééÒ Ú
xééÛ Ù
.ééÙ ı
	AmountPenééı ˛
,éé˛ ˇ
dateééÄ Ñ
=ééÖ Ü
xééá à
.ééà â
Dateééâ ç
,ééç é
	recurringééè ò
=ééô ö
xééõ ú
.ééú ù
	Recurringééù ¶
,éé¶ ß
recurrenceCycleéé® ∑
=éé∏ π
xéé∫ ª
.ééª º
RecurrenceCycleééº À
?ééÀ Ã
.ééÃ Õ
ToStringééÕ ’
(éé’ ÷
)éé÷ ◊
,éé◊ ÿ 
recurrenceEndsAtééŸ È
=ééÍ Î
xééÏ Ì
.ééÌ Ó 
RecurrenceEndsAtééÓ ˛
,éé˛ ˇ
isNonDeductibleééÄ è
=ééê ë
xééí ì
.ééì î
IsNonDeductibleééî £
,éé£ §%
isNonDomiciledServiceéé• ∫
=ééª º
xééΩ æ
.ééæ ø%
IsNonDomiciledServiceééø ‘
,éé‘ ’#
foreignSupplierNameéé÷ È
=ééÍ Î
xééÏ Ì
.ééÌ Ó#
ForeignSupplierNameééÓ Å
,ééÅ Ç&
foreignSupplierCountryééÉ ô
=ééö õ
xééú ù
.ééù û&
ForeignSupplierCountryééû ¥
,éé¥ µ
form1662PaidAtéé∂ ƒ
=éé≈ ∆
xéé« »
.éé» …
Form1662PaidAtéé… ◊
,éé◊ ÿ
form1662NumberééŸ Á
=ééË È
xééÍ Î
.ééÎ Ï
Form1662NumberééÏ ˙
}éé˚ ¸
;éé¸ ˝
}èè 
publicëë 
sealed
ëë 
record
ëë 
ProfileRequest
ëë #
(
ëë# $
string
ëë$ *
Name
ëë+ /
)
ëë/ 0
;
ëë0 1
publicíí 
sealed
íí 
record
íí #
ChangePasswordRequest
íí *
(
íí* +
string
íí+ 1
CurrentPassword
íí2 A
,
ííA B
string
ííC I
NewPassword
ííJ U
)
ííU V
;
ííV W
publicìì 
sealed
ìì 
record
ìì 
InviteRequest
ìì "
(
ìì" #
string
ìì# )
Name
ìì* .
,
ìì. /
string
ìì0 6
Email
ìì7 <
)
ìì< =
;
ìì= >
publicîî 
sealed
îî 
record
îî 
UpdateTeamRequest
îî &
(
îî& '
UserRole
îî' /
?
îî/ 0
Role
îî1 5
,
îî5 6
bool
îî7 ;
?
îî; <
IsActive
îî= E
)
îîE F
;
îîF G
publicïï 
sealed
ïï 
record
ïï 
ClientRequest
ïï "
(
ïï" #
string
ïï# )
CompanyName
ïï* 5
,
ïï5 6
string
ïï7 =
ContactName
ïï> I
,
ïïI J
string
ïïK Q
Email
ïïR W
,
ïïW X
string
ïïY _
?
ïï_ `
Phone
ïïa f
,
ïïf g
string
ïïh n 
PreferredLanguageïïo Ä
,ïïÄ Å
boolïïÇ Ü#
RequiresTaxDocumentïïá ö
=ïïõ ú
falseïïù ¢
)ïï¢ £
;ïï£ §
publicññ 
sealed
ññ 
record
ññ  
ClientPatchRequest
ññ '
(
ññ' (
string
ññ( .
?
ññ. /
CompanyName
ññ0 ;
,
ññ; <
string
ññ= C
?
ññC D
ContactName
ññE P
,
ññP Q
string
ññR X
?
ññX Y
Email
ññZ _
,
ññ_ `
string
ñña g
?
ññg h
Phone
ññi n
,
ññn o
string
ññp v
?
ññv w 
PreferredLanguageññx â
,ññâ ä
boolññã è
?ññè ê
IsActiveññë ô
,ññô ö
boolññõ ü
?ññü †#
RequiresTaxDocumentññ° ¥
=ññµ ∂
nullññ∑ ª
)ññª º
;ññº Ω
publicóó 
sealed
óó 
record
óó 
ProductRequest
óó #
(
óó# $
ProductType
óó$ /
Type
óó0 4
,
óó4 5
string
óó6 <
Name
óó= A
,
óóA B
BillingCycle
óóC O
BillingCycle
óóP \
,
óó\ ]
decimal
óó^ e
?
óóe f
	BasePrice
óóg p
,
óóp q
string
óór x
Currencyóóy Å
,óóÅ Ç
stringóóÉ â
?óóâ ä
Descriptionóóã ñ
,óóñ ó
boolóóò ú
IsActiveóóù •
,óó• ¶
TaxDocumentTypeóóß ∂
TaxDocumentTypeóó∑ ∆
=óó« »
TaxDocumentTypeóó… ÿ
.óóÿ Ÿ
FacturaóóŸ ‡
,óó‡ ·
stringóó‚ Ë
?óóË È
CategoryóóÍ Ú
=óóÛ Ù
nullóóı ˘
,óó˘ ˙
stringóó˚ Å
?óóÅ Ç
TagsóóÉ á
=óóà â
nullóóä é
,óóé è
boolóóê î
AllowsTicketsóóï ¢
=óó£ §
falseóó• ™
)óó™ ´
;óó´ ¨
publicòò 
sealed
òò 
record
òò !
ProductPatchRequest
òò (
(
òò( )
ProductType
òò) 4
?
òò4 5
Type
òò6 :
,
òò: ;
string
òò< B
?
òòB C
Name
òòD H
,
òòH I
BillingCycle
òòJ V
?
òòV W
BillingCycle
òòX d
,
òòd e
decimal
òòf m
?
òòm n
	BasePrice
òòo x
,
òòx y
stringòòz Ä
?òòÄ Å
CurrencyòòÇ ä
,òòä ã
stringòòå í
?òòí ì
Descriptionòòî ü
,òòü †
boolòò° •
?òò• ¶
IsActiveòòß Ø
,òòØ ∞
TaxDocumentTypeòò± ¿
?òò¿ ¡
TaxDocumentTypeòò¬ —
=òò“ ”
nullòò‘ ÿ
,òòÿ Ÿ
stringòò⁄ ‡
?òò‡ ·
Categoryòò‚ Í
=òòÎ Ï
nullòòÌ Ò
,òòÒ Ú
stringòòÛ ˘
?òò˘ ˙
Tagsòò˚ ˇ
=òòÄ Å
nullòòÇ Ü
,òòÜ á
boolòòà å
?òòå ç
AllowsTicketsòòé õ
=òòú ù
nullòòû ¢
)òò¢ £
;òò£ §
publicôô 
sealed
ôô 
record
ôô "
AssignProductRequest
ôô )
(
ôô) *
Guid
ôô* .
	ProductId
ôô/ 8
,
ôô8 9
Guid
ôô: >
	ProjectId
ôô? H
,
ôôH I
BillingCycle
ôôJ V
BillingCycle
ôôW c
,
ôôc d
string
ôôe k
BillingMode
ôôl w
,
ôôw x
decimalôôy Ä
?ôôÄ Å
PriceôôÇ á
,ôôá à
stringôôâ è
?ôôè ê

DomainNameôôë õ
,ôôõ ú
stringôôù £
?ôô£ §"
PriceLabelOverrideôô• ∑
,ôô∑ ∏
DateOnlyôôπ ¡
?ôô¡ ¬
RenewsAtôô√ À
=ôôÃ Õ
nullôôŒ “
,ôô“ ”
DateOnlyôô‘ ‹
?ôô‹ ›
NextChargeAtôôﬁ Í
=ôôÎ Ï
nullôôÌ Ò
,ôôÒ Ú
decimalôôÛ ˙
?ôô˙ ˚
Discountôô¸ Ñ
=ôôÖ Ü
nullôôá ã
)ôôã å
;ôôå ç
publicöö 
sealed
öö 
record
öö $
TransferPaymentRequest
öö +
(
öö+ ,
decimal
öö, 3
?
öö3 4
Amount
öö5 ;
,
öö; <
DateOnly
öö= E
?
ööE F
PaidAt
ööG M
,
ööM N
string
ööO U
?
ööU V
	Reference
ööW `
,
öö` a
int
ööb e
Years
ööf k
=
ööl m
$num
öön o
)
ööo p
;
ööp q
publicõõ 
sealed
õõ 
record
õõ '
ClientProductDatesRequest
õõ .
(
õõ. /
DateOnly
õõ/ 7
?
õõ7 8
RenewsAt
õõ9 A
,
õõA B
DateOnly
õõC K
?
õõK L
NextChargeAt
õõM Y
)
õõY Z
;
õõZ [
publicúú 
sealed
úú 
record
úú '
ClientProductPatchRequest
úú .
(
úú. /
decimal
úú/ 6
?
úú6 7
Price
úú8 =
,
úú= >!
ClientProductStatus
úú? R
?
úúR S
Status
úúT Z
,
úúZ [
BillingCycle
úú\ h
?
úúh i
BillingCycle
úúj v
,
úúv w
bool
úúx |
?
úú| }
IsManualBillingúú~ ç
,úúç é
stringúúè ï
?úúï ñ

DomainNameúúó °
,úú° ¢
stringúú£ ©
?úú© ™"
PriceLabelOverrideúú´ Ω
,úúΩ æ
decimalúúø ∆
?úú∆ «
Discountúú» –
=úú— “
nullúú” ◊
,úú◊ ÿ
GuidúúŸ ›
?úú› ﬁ
	ProjectIdúúﬂ Ë
=úúÈ Í
nullúúÎ Ô
)úúÔ 
;úú Ò
publicùù 
sealed
ùù 
record
ùù 
ImportError
ùù  
(
ùù  !
int
ùù! $
Row
ùù% (
,
ùù( )
string
ùù* 0
Reason
ùù1 7
)
ùù7 8
;
ùù8 9
publicüü 
sealed
üü 
record
üü 
TemplateColumn
üü #
(
üü# $
string
üü$ *
Name
üü+ /
,
üü/ 0
bool
üü1 5
Required
üü6 >
,
üü> ?
string
üü@ F
Accepted
üüG O
,
üüO P
string
üüQ W
[
üüW X
]
üüX Y
?
üüY Z
Options
üü[ b
=
üüc d
null
üüe i
)
üüi j
;
üüj k
public†† 
sealed
†† 
record
†† 
ClientAccess
†† !
(
††! "
string
††" (

ClientName
††) 3
,
††3 4
string
††5 ;
Email
††< A
,
††A B
string
††C I
TemporaryPassword
††J [
,
††[ \
bool
††] a
	EmailSent
††b k
=
††l m
false
††n s
)
††s t
;
††t u
public°° 
sealed
°° 
record
°° 
ProjectRequest
°° #
(
°°# $
string
°°$ *
?
°°* +
Name
°°, 0
,
°°0 1
string
°°2 8
?
°°8 9
Slug
°°: >
,
°°> ?
string
°°@ F
?
°°F G
GithubRepoOwner
°°H W
,
°°W X
string
°°Y _
?
°°_ `
GithubRepoName
°°a o
)
°°o p
;
°°p q
public¢¢ 
sealed
¢¢ 
record
¢¢ 
RepositoryRequest
¢¢ &
(
¢¢& '
string
¢¢' -
?
¢¢- .
Owner
¢¢/ 4
,
¢¢4 5
string
¢¢6 <
?
¢¢< =
Name
¢¢> B
,
¢¢B C
string
¢¢D J
?
¢¢J K
Label
¢¢L Q
=
¢¢R S
null
¢¢T X
,
¢¢X Y
bool
¢¢Z ^
?
¢¢^ _
	IsDefault
¢¢` i
=
¢¢j k
null
¢¢l p
)
¢¢p q
;
¢¢q r
public££ 
sealed
££ 
record
££  
TaxSettingsRequest
££ '
(
££' (
decimal
££( /
?
££/ 0
IgvRate
££1 8
,
££8 9
decimal
££: A
?
££A B
	RentaRate
££C L
,
££L M
string
££N T
?
££T U
FacturaSeries
££V c
=
££d e
null
££f j
,
££j k
int
££l o
?
££o p 
FacturaNextNumber££q Ç
=££É Ñ
null££Ö â
,££â ä
string££ã ë
?££ë í
ReciboSeries££ì ü
=££† °
null££¢ ¶
,££¶ ß
int££® ´
?££´ ¨ 
ReciboNextNumber££≠ Ω
=££æ ø
null££¿ ƒ
,££ƒ ≈
string££∆ Ã
?££Ã Õ
Ruc££Œ —
=££“ ”
null££‘ ÿ
,££ÿ Ÿ
bool££⁄ ﬁ
?££ﬁ ﬂ
IsGoodTaxpayer££‡ Ó
=££Ô 
null££Ò ı
,££ı ˆ
bool££˜ ˚
?££˚ ¸
Use1662AsCredit££˝ å
=££ç é
null££è ì
)££ì î
;££î ï
public•• 
sealed
•• 
record
••  
TaxDocumentRequest
•• '
(
••' (
Guid
••( ,
?
••, -
ClientProductId
••. =
,
••= >
DateOnly
••? G
	IssueDate
••H Q
,
••Q R
string
••S Y
Currency
••Z b
,
••b c
decimal
••d k
TotalAmount
••l w
,
••w x
string
••y 
?•• Ä
Notes••Å Ü
,••Ü á
decimal••à è
?••è ê
RetentionAmount••ë †
=••° ¢
null••£ ß
,••ß ®
IReadOnlyList••© ∂
<••∂ ∑&
TaxDocumentItemRequest••∑ Õ
>••Õ Œ
?••Œ œ
Items••– ’
=••÷ ◊
null••ÿ ‹
)••‹ ›
;••› ﬁ
public¶¶ 
sealed
¶¶ 
record
¶¶ $
TaxDocumentItemRequest
¶¶ +
(
¶¶+ ,
Guid
¶¶, 0
ClientProductId
¶¶1 @
,
¶¶@ A
decimal
¶¶B I
Amount
¶¶J P
)
¶¶P Q
;
¶¶Q R
publicßß 
sealed
ßß 
record
ßß '
ReverseTaxDocumentRequest
ßß .
(
ßß. /
string
ßß/ 5
?
ßß5 6
Reason
ßß7 =
,
ßß= >
bool
ßß? C
	NotIssued
ßßD M
)
ßßM N
;
ßßN O
public®® 
sealed
®® 
record
®® 
ExpenseRequest
®® #
(
®®# $
string
®®$ *
Description
®®+ 6
,
®®6 7
Guid
®®8 <

CategoryId
®®= G
,
®®G H
ExpenseType
®®I T
Type
®®U Y
,
®®Y Z
decimal
®®[ b
Amount
®®c i
,
®®i j
string
®®k q
Currency
®®r z
,
®®z {
DateOnly®®| Ñ
Date®®Ö â
,®®â ä
bool®®ã è
	Recurring®®ê ô
,®®ô ö
BillingCycle®®õ ß
?®®ß ®
RecurrenceCycle®®© ∏
,®®∏ π
bool®®∫ æ
IsNonDeductible®®ø Œ
=®®œ –
false®®— ÷
,®®÷ ◊
bool®®ÿ ‹%
IsNonDomiciledService®®› Ú
=®®Û Ù
false®®ı ˙
,®®˙ ˚
string®®¸ Ç
?®®Ç É#
ForeignSupplierName®®Ñ ó
=®®ò ô
null®®ö û
,®®û ü
string®®† ¶
?®®¶ ß&
ForeignSupplierCountry®®® æ
=®®ø ¿
null®®¡ ≈
)®®≈ ∆
;®®∆ «
public©© 
sealed
©© 
record
©© "
EndRecurrenceRequest
©© )
(
©©) *
DateOnly
©©* 2
EndsAt
©©3 9
)
©©9 :
;
©©: ;
public™™ 
sealed
™™ 
record
™™ !
ExpensePatchRequest
™™ (
(
™™( )
string
™™) /
?
™™/ 0
Description
™™1 <
,
™™< =
Guid
™™> B
?
™™B C

CategoryId
™™D N
,
™™N O
ExpenseType
™™P [
?
™™[ \
Type
™™] a
,
™™a b
decimal
™™c j
?
™™j k
Amount
™™l r
,
™™r s
string
™™t z
?
™™z {
Currency™™| Ñ
,™™Ñ Ö
DateOnly™™Ü é
?™™é è
Date™™ê î
,™™î ï
bool™™ñ ö
?™™ö õ
	Recurring™™ú •
,™™• ¶
BillingCycle™™ß ≥
?™™≥ ¥
RecurrenceCycle™™µ ƒ
,™™ƒ ≈
bool™™∆  
?™™  À
IsNonDeductible™™Ã €
=™™‹ ›
null™™ﬁ ‚
,™™‚ „
bool™™‰ Ë
?™™Ë È%
IsNonDomiciledService™™Í ˇ
=™™Ä Å
null™™Ç Ü
,™™Ü á
string™™à é
?™™é è#
ForeignSupplierName™™ê £
=™™§ •
null™™¶ ™
,™™™ ´
string™™¨ ≤
?™™≤ ≥&
ForeignSupplierCountry™™¥  
=™™À Ã
null™™Õ —
)™™— “
;™™“ ”¨
6C:\repo\rtres-net\Rtres\src\api\Rtres.Api\Contracts.cs
	namespace 	
Rtres
 
. 
Api 
; 
public 
record 
LoginRequest 
( 
string !
Email" '
,' (
string) /
Password0 8
)8 9
;9 :
public 
record 
TicketAttachmentDto !
(! "
Guid" &
Id' )
,) *
string+ 1
FileName2 :
,: ;
string< B
ContentTypeC N
,N O
longP T
	SizeBytesU ^
)^ _
;_ `
public 
record 
CreateTicketRequest !
(! "
Guid" &
	ProjectId' 0
,0 1

TicketType2 <
Type= A
,A B
stringC I
TitleJ O
,O P
stringQ W
DescriptionX c
,c d
stringe k
?k l
CurrentBehaviorm |
,| }
string	~ Ñ
?
Ñ Ö
ExpectedBehavior
Ü ñ
,
ñ ó
string
ò û
?
û ü
StepsToReproduce
† ∞
,
∞ ±
string
≤ ∏
?
∏ π
Environment
∫ ≈
,
≈ ∆
string
« Õ
?
Õ Œ 
AcceptanceCriteria
œ ·
,
· ‚
string
„ È
?
È Í
EstimatedImpact
Î ˙
,
˙ ˚
Guid
¸ Ä
?
Ä Å
RepositoryId
Ç é
=
è ê
null
ë ï
,
ï ñ
Guid
ó õ
?
õ ú
ClientProductId
ù ¨
=
≠ Æ
null
Ø ≥
)
≥ ¥
;
¥ µ
public 
record &
CreateTicketCommentRequest (
(( )
string) /
Body0 4
)4 5
;5 6
public		 
record		 %
UpdateTicketStatusRequest		 '
(		' (
TicketStatus		( 4
Status		5 ;
)		; <
;		< =
public

 
record

 
TicketCommentDto

 
(

 
Guid

 #
Id

$ &
,

& '
string

( .
Body

/ 3
,

3 4
bool

5 9

FromGithub

: D
,

D E
string

F L
?

L M

AuthorName

N X
,

X Y
DateTime

Z b
	CreatedAt

c l
)

l m
;

m n