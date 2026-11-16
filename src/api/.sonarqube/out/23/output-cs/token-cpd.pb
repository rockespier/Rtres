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
}^^ ﬂ\
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
}?? àï
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
TaxCreditPen[[ 
{\\ 
get]] 
{^^ 	
if__ 
(__ 
!__ 
GivesTaxCredit__ 
)__  
return__! '
$num__( *
;__* +
return`` 
DocumentType`` 
==``  " 
PurchaseDocumentType``# 7
.``7 8
NotaCredito``8 C
?``D E
-``F G
IgvPen``G M
:``N O
IgvPen``P V
;``V W
}aa 	
}bb 
}cc 
publicff 
sealedff 
classff 
LearningVideoff !
{ff" #
publicff$ *
Guidff+ /
Idff0 2
{ff3 4
getff5 8
;ff8 9
setff: =
;ff= >
}ff? @
=ffA B
GuidffC G
.ffG H
NewGuidffH O
(ffO P
)ffP Q
;ffQ R
publicffS Y
stringffZ `
Titleffa f
{ffg h
getffi l
;ffl m
setffn q
;ffq r
}ffs t
=ffu v
stringffw }
.ff} ~
Empty	ff~ É
;
ffÉ Ñ
public
ffÖ ã
string
ffå í
	YoutubeId
ffì ú
{
ffù û
get
ffü ¢
;
ff¢ £
set
ff§ ß
;
ffß ®
}
ff© ™
=
ff´ ¨
string
ff≠ ≥
.
ff≥ ¥
Empty
ff¥ π
;
ffπ ∫
public
ffª ¡
string
ff¬ »
Category
ff… —
{
ff“ ”
get
ff‘ ◊
;
ff◊ ÿ
set
ffŸ ‹
;
ff‹ ›
}
ffﬁ ﬂ
=
ff‡ ·
string
ff‚ Ë
.
ffË È
Empty
ffÈ Ó
;
ffÓ Ô
publicgg 
stringgg 
?gg 
Languagegg 
{gg 
getgg 
;gg 
setgg  #
;gg# $
}gg% &
publicgg' -
stringgg. 4
?gg4 5
Descriptiongg6 A
{ggB C
getggD G
;ggG H
setggI L
;ggL M
}ggN O
publicggP V
intggW Z
	SortOrdergg[ d
{gge f
getggg j
;ggj k
setggl o
;ggo p
}ggq r
publicggs y
boolggz ~
IsPublished	gg ä
{
ggã å
get
ggç ê
;
ggê ë
set
ggí ï
;
ggï ñ
}
ggó ò
=
ggô ö
true
ggõ ü
;
ggü †
public
gg° ß
DateTime
gg® ∞
	CreatedAt
gg± ∫
{
ggª º
get
ggΩ ¿
;
gg¿ ¡
set
gg¬ ≈
;
gg≈ ∆
}
gg« »
=
gg…  
DateTime
ggÀ ”
.
gg” ‘
UtcNow
gg‘ ⁄
;
gg⁄ €
}
gg‹ ›
publicjj 
sealedjj 
classjj 
ProductCategoryjj #
{jj$ %
publicjj& ,
Guidjj- 1
Idjj2 4
{jj5 6
getjj7 :
;jj: ;
setjj< ?
;jj? @
}jjA B
=jjC D
GuidjjE I
.jjI J
NewGuidjjJ Q
(jjQ R
)jjR S
;jjS T
publicjjU [
stringjj\ b
Namejjc g
{jjh i
getjjj m
;jjm n
setjjo r
;jjr s
}jjt u
=jjv w
stringjjx ~
.jj~ 
Empty	jj Ñ
;
jjÑ Ö
public
jjÜ å
int
jjç ê
	SortOrder
jjë ö
{
jjõ ú
get
jjù †
;
jj† °
set
jj¢ •
;
jj• ¶
}
jjß ®
}
jj© ™
publicll 
sealedll 
classll 
Clientll 
{ll 
publicll #
Guidll$ (
Idll) +
{ll, -
getll. 1
;ll1 2
setll3 6
;ll6 7
}ll8 9
=ll: ;
Guidll< @
.ll@ A
NewGuidllA H
(llH I
)llI J
;llJ K
publicllL R
stringllS Y
CompanyNamellZ e
{llf g
getllh k
;llk l
setllm p
;llp q
}llr s
=llt u
stringllv |
.ll| }
Empty	ll} Ç
;
llÇ É
public
llÑ ä
string
llã ë
ContactName
llí ù
{
llû ü
get
ll† £
;
ll£ §
set
ll• ®
;
ll® ©
}
ll™ ´
=
ll¨ ≠
string
llÆ ¥
.
ll¥ µ
Empty
llµ ∫
;
ll∫ ª
public
llº ¬
string
ll√ …
Email
ll  œ
{
ll– —
get
ll“ ’
;
ll’ ÷
set
ll◊ ⁄
;
ll⁄ €
}
ll‹ ›
=
llﬁ ﬂ
string
ll‡ Ê
.
llÊ Á
Empty
llÁ Ï
;
llÏ Ì
public
llÓ Ù
string
llı ˚
?
ll˚ ¸
Phone
ll˝ Ç
{
llÉ Ñ
get
llÖ à
;
llà â
set
llä ç
;
llç é
}
llè ê
public
llë ó
string
llò û
PreferredLanguage
llü ∞
{
ll± ≤
get
ll≥ ∂
;
ll∂ ∑
set
ll∏ ª
;
llª º
}
llΩ æ
=
llø ¿
$str
ll¡ ≈
;
ll≈ ∆
public
ll« Õ
bool
llŒ “
IsActive
ll” €
{
ll‹ ›
get
llﬁ ·
;
ll· ‚
set
ll„ Ê
;
llÊ Á
}
llË È
=
llÍ Î
true
llÏ 
;
ll Ò
publicmm 

boolmm 
RequiresTaxDocumentmm #
{mm$ %
getmm& )
;mm) *
setmm+ .
;mm. /
}mm0 1
publicmm2 8
DateTimemm9 A
	CreatedAtmmB K
{mmL M
getmmN Q
;mmQ R
setmmS V
;mmV W
}mmX Y
=mmZ [
DateTimemm\ d
.mmd e
UtcNowmme k
;mmk l
}mmm n
publicnn 
sealednn 
classnn 
UserAccountnn 
{nn  !
publicnn" (
Guidnn) -
Idnn. 0
{nn1 2
getnn3 6
;nn6 7
setnn8 ;
;nn; <
}nn= >
=nn? @
GuidnnA E
.nnE F
NewGuidnnF M
(nnM N
)nnN O
;nnO P
publicnnQ W
GuidnnX \
?nn\ ]
ClientIdnn^ f
{nng h
getnni l
;nnl m
setnnn q
;nnq r
}nns t
publicnnu {
string	nn| Ç
Email
nnÉ à
{
nnâ ä
get
nnã é
;
nné è
set
nnê ì
;
nnì î
}
nnï ñ
=
nnó ò
string
nnô ü
.
nnü †
Empty
nn† •
;
nn• ¶
public
nnß ≠
string
nnÆ ¥
PasswordHash
nnµ ¡
{
nn¬ √
get
nnƒ «
;
nn« »
set
nn… Ã
;
nnÃ Õ
}
nnŒ œ
=
nn– —
string
nn“ ÿ
.
nnÿ Ÿ
Empty
nnŸ ﬁ
;
nnﬁ ﬂ
public
nn‡ Ê
string
nnÁ Ì
Name
nnÓ Ú
{
nnÛ Ù
get
nnı ¯
;
nn¯ ˘
set
nn˙ ˝
;
nn˝ ˛
}
nnˇ Ä
=
nnÅ Ç
string
nnÉ â
.
nnâ ä
Empty
nnä è
;
nnè ê
public
nnë ó
UserRole
nnò †
Role
nn° •
{
nn¶ ß
get
nn® ´
;
nn´ ¨
set
nn≠ ∞
;
nn∞ ±
}
nn≤ ≥
=
nn¥ µ
UserRole
nn∂ æ
.
nnæ ø
Cliente
nnø ∆
;
nn∆ «
public
nn» Œ
bool
nnœ ”
IsActive
nn‘ ‹
{
nn› ﬁ
get
nnﬂ ‚
;
nn‚ „
set
nn‰ Á
;
nnÁ Ë
}
nnÈ Í
=
nnÎ Ï
true
nnÌ Ò
;
nnÒ Ú
publicoo 

DateTimeoo 
?oo 
NotificationsSeenAtoo (
{oo) *
getoo+ .
;oo. /
setoo0 3
;oo3 4
}oo5 6
publicqq 

stringqq 
?qq 
Areaqq 
{qq 
getqq 
;qq 
setqq "
;qq" #
}qq$ %
publicss 

stringss 
?ss 
JobTitless 
{ss 
getss !
;ss! "
setss# &
;ss& '
}ss( )
publicuu 

Guiduu 
?uu 
	ManagerIduu 
{uu 
getuu  
;uu  !
setuu" %
;uu% &
}uu' (
}uu) *
publiczz 
sealedzz 
classzz 
	LoginLinkzz 
{zz 
publiczz  &
Guidzz' +
Idzz, .
{zz/ 0
getzz1 4
;zz4 5
setzz6 9
;zz9 :
}zz; <
=zz= >
Guidzz? C
.zzC D
NewGuidzzD K
(zzK L
)zzL M
;zzM N
publiczzO U
GuidzzV Z
UserAccountIdzz[ h
{zzi j
getzzk n
;zzn o
setzzp s
;zzs t
}zzu v
publiczzw }
string	zz~ Ñ
	TokenHash
zzÖ é
{
zzè ê
get
zzë î
;
zzî ï
set
zzñ ô
;
zzô ö
}
zzõ ú
=
zzù û
string
zzü •
.
zz• ¶
Empty
zz¶ ´
;
zz´ ¨
public
zz≠ ≥
DateTime
zz¥ º
	CreatedAt
zzΩ ∆
{
zz« »
get
zz… Ã
;
zzÃ Õ
set
zzŒ —
;
zz— “
}
zz” ‘
=
zz’ ÷
DateTime
zz◊ ﬂ
.
zzﬂ ‡
UtcNow
zz‡ Ê
;
zzÊ Á
public
zzË Ó
DateTime
zzÔ ˜
	ExpiresAt
zz¯ Å
{
zzÇ É
get
zzÑ á
;
zzá à
set
zzâ å
;
zzå ç
}
zzé è
public
zzê ñ
DateTime
zzó ü
?
zzü †
UsedAt
zz° ß
{
zz® ©
get
zz™ ≠
;
zz≠ Æ
set
zzØ ≤
;
zz≤ ≥
}
zz¥ µ
}
zz∂ ∑
public|| 
sealed|| 
class|| 
Project|| 
{|| 
public|| $
Guid||% )
Id||* ,
{||- .
get||/ 2
;||2 3
set||4 7
;||7 8
}||9 :
=||; <
Guid||= A
.||A B
NewGuid||B I
(||I J
)||J K
;||K L
public||M S
Guid||T X
ClientId||Y a
{||b c
get||d g
;||g h
set||i l
;||l m
}||n o
public||p v
string||w }
Name	||~ Ç
{
||É Ñ
get
||Ö à
;
||à â
set
||ä ç
;
||ç é
}
||è ê
=
||ë í
string
||ì ô
.
||ô ö
Empty
||ö ü
;
||ü †
public
||° ß
string
||® Æ
Slug
||Ø ≥
{
||¥ µ
get
||∂ π
;
||π ∫
set
||ª æ
;
||æ ø
}
||¿ ¡
=
||¬ √
string
||ƒ  
.
||  À
Empty
||À –
;
||– —
public
||“ ÿ
List
||Ÿ ›
<
||› ﬁ
ProjectRepository
||ﬁ Ô
>
||Ô 
Repositories
||Ò ˝
{
||˛ ˇ
get
||Ä É
;
||É Ñ
set
||Ö à
;
||à â
}
||ä ã
=
||å ç
[
||é è
]
||è ê
;
||ê ë
}
||í ì
public~~ 
sealed~~ 
class~~ 
ProjectRepository~~ %
{~~& '
public~~( .
Guid~~/ 3
Id~~4 6
{~~7 8
get~~9 <
;~~< =
set~~> A
;~~A B
}~~C D
=~~E F
Guid~~G K
.~~K L
NewGuid~~L S
(~~S T
)~~T U
;~~U V
public~~W ]
Guid~~^ b
	ProjectId~~c l
{~~m n
get~~o r
;~~r s
set~~t w
;~~w x
}~~y z
public	~~{ Å
string
~~Ç à
Owner
~~â é
{
~~è ê
get
~~ë î
;
~~î ï
set
~~ñ ô
;
~~ô ö
}
~~õ ú
=
~~ù û
string
~~ü •
.
~~• ¶
Empty
~~¶ ´
;
~~´ ¨
public
~~≠ ≥
string
~~¥ ∫
Name
~~ª ø
{
~~¿ ¡
get
~~¬ ≈
;
~~≈ ∆
set
~~«  
;
~~  À
}
~~Ã Õ
=
~~Œ œ
string
~~– ÷
.
~~÷ ◊
Empty
~~◊ ‹
;
~~‹ ›
public
~~ﬁ ‰
string
~~Â Î
?
~~Î Ï
Label
~~Ì Ú
{
~~Û Ù
get
~~ı ¯
;
~~¯ ˘
set
~~˙ ˝
;
~~˝ ˛
}
~~ˇ Ä
public
~~Å á
bool
~~à å
	IsDefault
~~ç ñ
{
~~ó ò
get
~~ô ú
;
~~ú ù
set
~~û °
;
~~° ¢
}
~~£ §
}
~~• ¶
public 
static 
class 
ProjectExtensions %
{ÄÄ 
public
ÇÇ 

static
ÇÇ 
ProjectRepository
ÇÇ #
?
ÇÇ# $
RepositoryFor
ÇÇ% 2
(
ÇÇ2 3
this
ÇÇ3 7!
IReadOnlyCollection
ÇÇ8 K
<
ÇÇK L
ProjectRepository
ÇÇL ]
>
ÇÇ] ^
repositories
ÇÇ_ k
,
ÇÇk l
Guid
ÇÇm q
?
ÇÇq r
repositoryId
ÇÇs 
)ÇÇ Ä
=>ÇÇÅ É
repositoryId
ÉÉ 
is
ÉÉ 
Guid
ÉÉ 
id
ÉÉ 
?
ÉÉ  !
repositories
ÉÉ" .
.
ÉÉ. /
FirstOrDefault
ÉÉ/ =
(
ÉÉ= >
x
ÉÉ> ?
=>
ÉÉ@ B
x
ÉÉC D
.
ÉÉD E
Id
ÉÉE G
==
ÉÉH J
id
ÉÉK M
)
ÉÉM N
:
ÉÉO P
repositories
ÉÉQ ]
.
ÉÉ] ^
OrderByDescending
ÉÉ^ o
(
ÉÉo p
x
ÉÉp q
=>
ÉÉr t
x
ÉÉu v
.
ÉÉv w
	IsDefaultÉÉw Ä
)ÉÉÄ Å
.ÉÉÅ Ç
FirstOrDefaultÉÉÇ ê
(ÉÉê ë
)ÉÉë í
;ÉÉí ì
}ÑÑ 
publicÖÖ 
sealed
ÖÖ 
class
ÖÖ 
Product
ÖÖ 
{
ÖÖ 
public
ÖÖ $
Guid
ÖÖ% )
Id
ÖÖ* ,
{
ÖÖ- .
get
ÖÖ/ 2
;
ÖÖ2 3
set
ÖÖ4 7
;
ÖÖ7 8
}
ÖÖ9 :
=
ÖÖ; <
Guid
ÖÖ= A
.
ÖÖA B
NewGuid
ÖÖB I
(
ÖÖI J
)
ÖÖJ K
;
ÖÖK L
public
ÖÖM S
ProductType
ÖÖT _
Type
ÖÖ` d
{
ÖÖe f
get
ÖÖg j
;
ÖÖj k
set
ÖÖl o
;
ÖÖo p
}
ÖÖq r
public
ÖÖs y
stringÖÖz Ä
NameÖÖÅ Ö
{ÖÖÜ á
getÖÖà ã
;ÖÖã å
setÖÖç ê
;ÖÖê ë
}ÖÖí ì
=ÖÖî ï
stringÖÖñ ú
.ÖÖú ù
EmptyÖÖù ¢
;ÖÖ¢ £
publicÖÖ§ ™
BillingCycleÖÖ´ ∑
BillingCycleÖÖ∏ ƒ
{ÖÖ≈ ∆
getÖÖ«  
;ÖÖ  À
setÖÖÃ œ
;ÖÖœ –
}ÖÖ— “
publicÖÖ” Ÿ
decimalÖÖ⁄ ·
?ÖÖ· ‚
	BasePriceÖÖ„ Ï
{ÖÖÌ Ó
getÖÖÔ Ú
;ÖÖÚ Û
setÖÖÙ ˜
;ÖÖ˜ ¯
}ÖÖ˘ ˙
publicÖÖ˚ Å
stringÖÖÇ à
CurrencyÖÖâ ë
{ÖÖí ì
getÖÖî ó
;ÖÖó ò
setÖÖô ú
;ÖÖú ù
}ÖÖû ü
=ÖÖ† °
$strÖÖ¢ ß
;ÖÖß ®
publicÖÖ© Ø
stringÖÖ∞ ∂
?ÖÖ∂ ∑
DescriptionÖÖ∏ √
{ÖÖƒ ≈
getÖÖ∆ …
;ÖÖ…  
setÖÖÀ Œ
;ÖÖŒ œ
}ÖÖ– —
publicÖÖ“ ÿ
boolÖÖŸ ›
IsActiveÖÖﬁ Ê
{ÖÖÁ Ë
getÖÖÈ Ï
;ÖÖÏ Ì
setÖÖÓ Ò
;ÖÖÒ Ú
}ÖÖÛ Ù
=ÖÖı ˆ
trueÖÖ˜ ˚
;ÖÖ˚ ¸
publicÖÖ˝ É
stringÖÖÑ ä
?ÖÖä ã
PayPalPlanIdÖÖå ò
{ÖÖô ö
getÖÖõ û
;ÖÖû ü
setÖÖ† £
;ÖÖ£ §
}ÖÖ• ¶
publicÖÖß ≠
decimalÖÖÆ µ
?ÖÖµ ∂
PayPalPlanPriceÖÖ∑ ∆
{ÖÖ« »
getÖÖ… Ã
;ÖÖÃ Õ
setÖÖŒ —
;ÖÖ— “
}ÖÖ” ‘
publicÖÖ’ €
TaxDocumentTypeÖÖ‹ Î
TaxDocumentTypeÖÖÏ ˚
{ÖÖ¸ ˝
getÖÖ˛ Å
;ÖÖÅ Ç
setÖÖÉ Ü
;ÖÖÜ á
}ÖÖà â
=ÖÖä ã
TaxDocumentTypeÖÖå õ
.ÖÖõ ú
FacturaÖÖú £
;ÖÖ£ §
public
áá 

string
áá 
?
áá 
Category
áá 
{
áá 
get
áá !
;
áá! "
set
áá# &
;
áá& '
}
áá( )
public
ââ 

string
ââ 
?
ââ 
Tags
ââ 
{
ââ 
get
ââ 
;
ââ 
set
ââ "
;
ââ" #
}
ââ$ %
public
ãã 

bool
ãã 
AllowsTickets
ãã 
{
ãã 
get
ãã  #
;
ãã# $
set
ãã% (
;
ãã( )
}
ãã* +
}
ãã, -
publicåå 
sealed
åå 
class
åå 
ClientProduct
åå !
{
åå" #
public
åå$ *
Guid
åå+ /
Id
åå0 2
{
åå3 4
get
åå5 8
;
åå8 9
set
åå: =
;
åå= >
}
åå? @
=
ååA B
Guid
ååC G
.
ååG H
NewGuid
ååH O
(
ååO P
)
ååP Q
;
ååQ R
public
ååS Y
Guid
ååZ ^
ClientId
åå_ g
{
ååh i
get
ååj m
;
ååm n
set
ååo r
;
åår s
}
ååt u
public
ååv |
Guidåå} Å
	ProjectIdååÇ ã
{ååå ç
getååé ë
;ååë í
setååì ñ
;ååñ ó
}ååò ô
publicååö †
Guidåå° •
	ProductIdåå¶ Ø
{åå∞ ±
getåå≤ µ
;ååµ ∂
setåå∑ ∫
;åå∫ ª
}ååº Ω
publicååæ ƒ#
ClientProductStatusåå≈ ÿ
StatusååŸ ﬂ
{åå‡ ·
getåå‚ Â
;ååÂ Ê
setååÁ Í
;ååÍ Î
}ååÏ Ì
publicååÓ Ù
BillingCycleååı Å
BillingCycleååÇ é
{ååè ê
getååë î
;ååî ï
setååñ ô
;ååô ö
}ååõ ú
publicååù £
boolåå§ ®
IsManualBillingåå© ∏
{ååπ ∫
getååª æ
;ååæ ø
setåå¿ √
;åå√ ƒ
}åå≈ ∆
publicåå« Õ
DateTimeååŒ ÷
?åå÷ ◊
RenewsAtååÿ ‡
{åå· ‚
getåå„ Ê
;ååÊ Á
setååË Î
;ååÎ Ï
}ååÌ Ó
publicååÔ ı
DateTimeååˆ ˛
?åå˛ ˇ
NextChargeAtååÄ å
{ååç é
getååè í
;ååí ì
setååî ó
;ååó ò
}ååô ö
publicååõ °
DateTimeåå¢ ™
?åå™ ´
LastBackupAtåå¨ ∏
{ååπ ∫
getååª æ
;ååæ ø
setåå¿ √
;åå√ ƒ
}åå≈ ∆
publicåå« Õ
decimalååŒ ’
?åå’ ÷
Priceåå◊ ‹
{åå› ﬁ
getååﬂ ‚
;åå‚ „
setåå‰ Á
;ååÁ Ë
}ååÈ Í
publicååÎ Ò
stringååÚ ¯
?åå¯ ˘"
PriceLabelOverrideåå˙ å
{ååç é
getååè í
;ååí ì
setååî ó
;ååó ò
}ååô ö
publicååõ °
stringåå¢ ®
?åå® ©
PayPalOrderIdåå™ ∑
{åå∏ π
getåå∫ Ω
;ååΩ æ
setååø ¬
;åå¬ √
}ååƒ ≈
publicåå∆ Ã
stringååÕ ”
?åå” ‘$
PayPalSubscriptionIdåå’ È
{ååÍ Î
getååÏ Ô
;ååÔ 
setååÒ Ù
;ååÙ ı
}ååˆ ˜
publicåå¯ ˛
stringååˇ Ö
?ååÖ Ü
PayPalPlanIdååá ì
{ååî ï
getååñ ô
;ååô ö
setååõ û
;ååû ü
}åå† °
publicåå¢ ®
stringåå© Ø
?ååØ ∞

DomainNameåå± ª
{ååº Ω
getååæ ¡
;åå¡ ¬
setåå√ ∆
;åå∆ «
}åå» …
public
çç 

decimal
çç 
?
çç 
Discount
çç 
{
çç 
get
çç "
;
çç" #
set
çç$ '
;
çç' (
}
çç) *
public
çç+ 1
DateTime
çç2 :
?
çç: ;
DiscountEndsAt
çç< J
{
ççK L
get
ççM P
;
ççP Q
set
ççR U
;
ççU V
}
ççW X
public
ççY _
Product
çç` g
?
ççg h
Product
ççi p
{
ççq r
get
ççs v
;
ççv w
set
ççx {
;
çç{ |
}
çç} ~
publicçç Ö
ProjectççÜ ç
?ççç é
Projectççè ñ
{ççó ò
getççô ú
;ççú ù
setççû °
;çç° ¢
}çç£ §
public
èè 

int
èè 
?
èè 
PayPalOrderYears
èè  
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
ëë 

decimal
ëë 
?
ëë 
AppliedIgvRate
ëë "
{
ëë# $
get
ëë% (
;
ëë( )
set
ëë* -
;
ëë- .
}
ëë/ 0
public
ìì 
#
TransferReportSummary
ìì  
?
ìì  !
TransferReport
ìì" 0
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
}
ìì? @
publicîî 
sealed
îî 
class
îî 
Ticket
îî 
{
îî 
public
îî #
Guid
îî$ (
Id
îî) +
{
îî, -
get
îî. 1
;
îî1 2
set
îî3 6
;
îî6 7
}
îî8 9
=
îî: ;
Guid
îî< @
.
îî@ A
NewGuid
îîA H
(
îîH I
)
îîI J
;
îîJ K
public
îîL R
string
îîS Y
Code
îîZ ^
{
îî_ `
get
îîa d
;
îîd e
set
îîf i
;
îîi j
}
îîk l
=
îîm n
string
îîo u
.
îîu v
Empty
îîv {
;
îî{ |
publicîî} É
GuidîîÑ à
ClientIdîîâ ë
{îîí ì
getîîî ó
;îîó ò
setîîô ú
;îîú ù
}îîû ü
publicîî† ¶
Guidîîß ´
	ProjectIdîî¨ µ
{îî∂ ∑
getîî∏ ª
;îîª º
setîîΩ ¿
;îî¿ ¡
}îî¬ √
publicîîƒ  
GuidîîÀ œ
CreatedByUserIdîî– ﬂ
{îî‡ ·
getîî‚ Â
;îîÂ Ê
setîîÁ Í
;îîÍ Î
}îîÏ Ì
publicîîÓ Ù

TicketTypeîîı ˇ
TypeîîÄ Ñ
{îîÖ Ü
getîîá ä
;îîä ã
setîîå è
;îîè ê
}îîë í
publicîîì ô
TicketStatusîîö ¶
Statusîîß ≠
{îîÆ Ø
getîî∞ ≥
;îî≥ ¥
setîîµ ∏
;îî∏ π
}îî∫ ª
=îîº Ω
TicketStatusîîæ  
.îî  À
AbiertoîîÀ “
;îî“ ”
publicîî‘ ⁄
stringîî€ ·
Titleîî‚ Á
{îîË È
getîîÍ Ì
;îîÌ Ó
setîîÔ Ú
;îîÚ Û
}îîÙ ı
=îîˆ ˜
stringîî¯ ˛
.îî˛ ˇ
Emptyîîˇ Ñ
;îîÑ Ö
publicîîÜ å
stringîîç ì
Descriptionîîî ü
{îî† °
getîî¢ •
;îî• ¶
setîîß ™
;îî™ ´
}îî¨ ≠
=îîÆ Ø
stringîî∞ ∂
.îî∂ ∑
Emptyîî∑ º
;îîº Ω
publicîîæ ƒ
stringîî≈ À
?îîÀ Ã
CurrentBehaviorîîÕ ‹
{îî› ﬁ
getîîﬂ ‚
;îî‚ „
setîî‰ Á
;îîÁ Ë
}îîÈ Í
publicîîÎ Ò
stringîîÚ ¯
?îî¯ ˘ 
ExpectedBehaviorîî˙ ä
{îîã å
getîîç ê
;îîê ë
setîîí ï
;îîï ñ
}îîó ò
publicîîô ü
stringîî† ¶
?îî¶ ß 
StepsToReproduceîî® ∏
{îîπ ∫
getîîª æ
;îîæ ø
setîî¿ √
;îî√ ƒ
}îî≈ ∆
publicîî« Õ
stringîîŒ ‘
?îî‘ ’
Environmentîî÷ ·
{îî‚ „
getîî‰ Á
;îîÁ Ë
setîîÈ Ï
;îîÏ Ì
}îîÓ Ô
publicîî ˆ
stringîî˜ ˝
?îî˝ ˛"
AcceptanceCriteriaîîˇ ë
{îîí ì
getîîî ó
;îîó ò
setîîô ú
;îîú ù
}îîû ü
publicîî† ¶
stringîîß ≠
?îî≠ Æ
EstimatedImpactîîØ æ
{îîø ¿
getîî¡ ƒ
;îîƒ ≈
setîî∆ …
;îî…  
}îîÀ Ã
public
ïï 

Guid
ïï 
?
ïï 
RepositoryId
ïï 
{
ïï 
get
ïï  #
;
ïï# $
set
ïï% (
;
ïï( )
}
ïï* +
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
ññ/ 5
int
ññ6 9
?
ññ9 :
GithubIssueNumber
ññ; L
{
ññM N
get
ññO R
;
ññR S
set
ññT W
;
ññW X
}
ññY Z
public
ññ[ a
string
ññb h
?
ññh i
GithubIssueUrl
ññj x
{
ññy z
get
ññ{ ~
;
ññ~ 
setññÄ É
;ññÉ Ñ
}ññÖ Ü
public
óó 
string
óó 
?
óó !
GithubProjectStatus
óó #
{
óó$ %
get
óó& )
;
óó) *
set
óó+ .
;
óó. /
}
óó0 1
public
óó2 8
DateTime
óó9 A
	CreatedAt
óóB K
{
óóL M
get
óóN Q
;
óóQ R
set
óóS V
;
óóV W
}
óóX Y
=
óóZ [
DateTime
óó\ d
.
óód e
UtcNow
óóe k
;
óók l
public
óóm s
DateTime
óót |
	UpdatedAtóó} Ü
{óóá à
getóóâ å
;óóå ç
setóóé ë
;óóë í
}óóì î
=óóï ñ
DateTimeóóó ü
.óóü †
UtcNowóó† ¶
;óó¶ ß
}óó® ©
publicôô 
sealed
ôô 
class
ôô 
TicketAttachment
ôô $
{
ôô% &
public
ôô' -
Guid
ôô. 2
Id
ôô3 5
{
ôô6 7
get
ôô8 ;
;
ôô; <
set
ôô= @
;
ôô@ A
}
ôôB C
=
ôôD E
Guid
ôôF J
.
ôôJ K
NewGuid
ôôK R
(
ôôR S
)
ôôS T
;
ôôT U
public
ôôV \
Guid
ôô] a
TicketId
ôôb j
{
ôôk l
get
ôôm p
;
ôôp q
set
ôôr u
;
ôôu v
}
ôôw x
public
ôôy 
stringôôÄ Ü
FileNameôôá è
{ôôê ë
getôôí ï
;ôôï ñ
setôôó ö
;ôôö õ
}ôôú ù
=ôôû ü
stringôô† ¶
.ôô¶ ß
Emptyôôß ¨
;ôô¨ ≠
publicôôÆ ¥
stringôôµ ª
Urlôôº ø
{ôô¿ ¡
getôô¬ ≈
;ôô≈ ∆
setôô«  
;ôô  À
}ôôÃ Õ
=ôôŒ œ
stringôô– ÷
.ôô÷ ◊
Emptyôô◊ ‹
;ôô‹ ›
publicôôﬁ ‰
longôôÂ È
	SizeBytesôôÍ Û
{ôôÙ ı
getôôˆ ˘
;ôô˘ ˙
setôô˚ ˛
;ôô˛ ˇ
}ôôÄ Å
publicôôÇ à
stringôôâ è
ContentTypeôôê õ
{ôôú ù
getôôû °
;ôô° ¢
setôô£ ¶
;ôô¶ ß
}ôô® ©
=ôô™ ´
$strôô¨ ∆
;ôô∆ «
publicôô» Œ
byteôôœ ”
[ôô” ‘
]ôô‘ ’
Contentôô÷ ›
{ôôﬁ ﬂ
getôô‡ „
;ôô„ ‰
setôôÂ Ë
;ôôË È
}ôôÍ Î
=ôôÏ Ì
[ôôÓ Ô
]ôôÔ 
;ôô Ò
publicôôÚ ¯
DateTimeôô˘ Å
	CreatedAtôôÇ ã
{ôôå ç
getôôé ë
;ôôë í
setôôì ñ
;ôôñ ó
}ôôò ô
=ôôö õ
DateTimeôôú §
.ôô§ •
UtcNowôô• ´
;ôô´ ¨
publicôô≠ ≥
boolôô¥ ∏
IsImageôôπ ¿
=>ôô¡ √
ContentTypeôôƒ œ
.ôôœ –

StartsWithôô– ⁄
(ôô⁄ €
$strôô€ „
,ôô„ ‰ 
StringComparisonôôÂ ı
.ôôı ˆ!
OrdinalIgnoreCaseôôˆ á
)ôôá à
;ôôà â
}ôôä ã
publicöö 
sealed
öö 
class
öö 
TicketComment
öö !
{
öö" #
public
öö$ *
Guid
öö+ /
Id
öö0 2
{
öö3 4
get
öö5 8
;
öö8 9
set
öö: =
;
öö= >
}
öö? @
=
ööA B
Guid
ööC G
.
ööG H
NewGuid
ööH O
(
ööO P
)
ööP Q
;
ööQ R
public
ööS Y
Guid
ööZ ^
TicketId
öö_ g
{
ööh i
get
ööj m
;
ööm n
set
ööo r
;
öör s
}
ööt u
public
ööv |
Guidöö} Å
?ööÅ Ç
AuthorUserIdööÉ è
{ööê ë
getööí ï
;ööï ñ
setööó ö
;ööö õ
}ööú ù
publicööû §
stringöö• ´
Bodyöö¨ ∞
{öö± ≤
getöö≥ ∂
;öö∂ ∑
setöö∏ ª
;ööª º
}ööΩ æ
=ööø ¿
stringöö¡ «
.öö« »
Emptyöö» Õ
;ööÕ Œ
publicööœ ’
boolöö÷ ⁄

FromGithuböö€ Â
{ööÊ Á
getööË Î
;ööÎ Ï
setööÌ 
;öö Ò
}ööÚ Û
publicööÙ ˙
longöö˚ ˇ
?ööˇ Ä
GithubCommentIdööÅ ê
{ööë í
getööì ñ
;ööñ ó
setööò õ
;ööõ ú
}ööù û
publicööü •
stringöö¶ ¨
?öö¨ ≠!
GithubAuthorLoginööÆ ø
{öö¿ ¡
getöö¬ ≈
;öö≈ ∆
setöö«  
;öö  À
}ööÃ Õ
publicööŒ ‘
DateTimeöö’ ›
	CreatedAtööﬁ Á
{ööË È
getööÍ Ì
;ööÌ Ó
setööÔ Ú
;ööÚ Û
}ööÙ ı
=ööˆ ˜
DateTimeöö¯ Ä
.ööÄ Å
UtcNowööÅ á
;ööá à
}ööâ ä
publicúú 
sealed
úú 
class
úú  
PaymentTransaction
úú &
{
úú' (
public
úú) /
Guid
úú0 4
Id
úú5 7
{
úú8 9
get
úú: =
;
úú= >
set
úú? B
;
úúB C
}
úúD E
=
úúF G
Guid
úúH L
.
úúL M
NewGuid
úúM T
(
úúT U
)
úúU V
;
úúV W
public
úúX ^
Guid
úú_ c
ClientId
úúd l
{
úúm n
get
úúo r
;
úúr s
set
úút w
;
úúw x
}
úúy z
public
ùù 

Guid
ùù 
?
ùù 
ClientProductId
ùù  
{
ùù! "
get
ùù# &
;
ùù& '
set
ùù( +
;
ùù+ ,
}
ùù- .
public
ùù/ 5
string
ùù6 <+
PayPalOrderIdOrSubscriptionId
ùù= Z
{
ùù[ \
get
ùù] `
;
ùù` a
set
ùùb e
;
ùùe f
}
ùùg h
=
ùùi j
string
ùùk q
.
ùùq r
Empty
ùùr w
;
ùùw x
public
ùùy 
decimalùùÄ á
Amountùùà é
{ùùè ê
getùùë î
;ùùî ï
setùùñ ô
;ùùô ö
}ùùõ ú
publicùùù £
stringùù§ ™
Currencyùù´ ≥
{ùù¥ µ
getùù∂ π
;ùùπ ∫
setùùª æ
;ùùæ ø
}ùù¿ ¡
=ùù¬ √
$strùùƒ …
;ùù…  
publicùùÀ —
stringùù“ ÿ
StatusùùŸ ﬂ
{ùù‡ ·
getùù‚ Â
;ùùÂ Ê
setùùÁ Í
;ùùÍ Î
}ùùÏ Ì
=ùùÓ Ô
stringùù ˆ
.ùùˆ ˜
Emptyùù˜ ¸
;ùù¸ ˝
public
ûû 

string
ûû 
Method
ûû 
{
ûû 
get
ûû 
;
ûû 
set
ûû  #
;
ûû# $
}
ûû% &
=
ûû' (
PaymentMethods
ûû) 7
.
ûû7 8
PayPal
ûû8 >
;
ûû> ?
public
üü 

int
üü 
Years
üü 
{
üü 
get
üü 
;
üü 
set
üü 
;
üü  
}
üü! "
=
üü# $
$num
üü% &
;
üü& '
public
üü( .
decimal
üü/ 6
	AmountPen
üü7 @
{
üüA B
get
üüC F
;
üüF G
set
üüH K
;
üüK L
}
üüM N
public
üüO U
string
üüV \
?
üü\ ]
InternalCode
üü^ j
{
üük l
get
üüm p
;
üüp q
set
üür u
;
üüu v
}
üüw x
public
üüy 
DateTimeüüÄ à
	CreatedAtüüâ í
{üüì î
getüüï ò
;üüò ô
setüüö ù
;üüù û
}üüü †
=üü° ¢
DateTimeüü£ ´
.üü´ ¨
UtcNowüü¨ ≤
;üü≤ ≥
publicüü¥ ∫
stringüüª ¡
?üü¡ ¬
Notesüü√ »
{üü…  
getüüÀ Œ
;üüŒ œ
setüü– ”
;üü” ‘
}üü’ ÷
}üü◊ ÿ
public†† 
sealed
†† 
class
†† 
NotificationLog
†† #
{
††$ %
public
††& ,
Guid
††- 1
Id
††2 4
{
††5 6
get
††7 :
;
††: ;
set
††< ?
;
††? @
}
††A B
=
††C D
Guid
††E I
.
††I J
NewGuid
††J Q
(
††Q R
)
††R S
;
††S T
public
††U [
Guid
††\ `
ClientId
††a i
{
††j k
get
††l o
;
††o p
set
††q t
;
††t u
}
††v w
public
††x ~
string†† Ö
Type††Ü ä
{††ã å
get††ç ê
;††ê ë
set††í ï
;††ï ñ
}††ó ò
=††ô ö
string††õ °
.††° ¢
Empty††¢ ß
;††ß ®
public††© Ø
string††∞ ∂
Channel††∑ æ
{††ø ¿
get††¡ ƒ
;††ƒ ≈
set††∆ …
;††…  
}††À Ã
=††Õ Œ
string††œ ’
.††’ ÷
Empty††÷ €
;††€ ‹
public††› „
DateTime††‰ Ï
SentAt††Ì Û
{††Ù ı
get††ˆ ˘
;††˘ ˙
set††˚ ˛
;††˛ ˇ
}††Ä Å
=††Ç É
DateTime††Ñ å
.††å ç
UtcNow††ç ì
;††ì î
public††ï õ
bool††ú †
Success††° ®
{††© ™
get††´ Æ
;††Æ Ø
set††∞ ≥
;††≥ ¥
}††µ ∂
public††∑ Ω
string††æ ƒ
?††ƒ ≈
	Recipient††∆ œ
{††– —
get††“ ’
;††’ ÷
set††◊ ⁄
;††⁄ €
}††‹ ›
public††ﬁ ‰
string††Â Î
?††Î Ï
	DedupeKey††Ì ˆ
{††˜ ¯
get††˘ ¸
;††¸ ˝
set††˛ Å
;††Å Ç
}††É Ñ
public††Ö ã
string††å í
?††í ì
Error††î ô
{††ö õ
get††ú ü
;††ü †
set††° §
;††§ •
}††¶ ß
}††® ©
public££ 
sealed
££ 
class
££ 
ExchangeRate
££  
{
££! "
public
££# )
Guid
££* .
Id
££/ 1
{
££2 3
get
££4 7
;
££7 8
set
££9 <
;
££< =
}
££> ?
=
££@ A
Guid
££B F
.
££F G
NewGuid
££G N
(
££N O
)
££O P
;
££P Q
public
££R X
DateOnly
££Y a
Date
££b f
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
££s t
public
££u {
string££| Ç
CurrencyCode££É è
{££ê ë
get££í ï
;££ï ñ
set££ó ö
;££ö õ
}££ú ù
=££û ü
string££† ¶
.££¶ ß
Empty££ß ¨
;££¨ ≠
public££Æ ¥
decimal££µ º
	RateToPen££Ω ∆
{££« »
get££… Ã
;££Ã Õ
set££Œ —
;££— “
}££” ‘
public££’ €
string££‹ ‚
Source££„ È
{££Í Î
get££Ï Ô
;££Ô 
set££Ò Ù
;££Ù ı
}££ˆ ˜
=££¯ ˘
string££˙ Ä
.££Ä Å
Empty££Å Ü
;££Ü á
}££à â
public¶¶ 
sealed
¶¶ 
class
¶¶ 
TaxDocument
¶¶ 
{
¶¶  !
public
¶¶" (
Guid
¶¶) -
Id
¶¶. 0
{
¶¶1 2
get
¶¶3 6
;
¶¶6 7
set
¶¶8 ;
;
¶¶; <
}
¶¶= >
=
¶¶? @
Guid
¶¶A E
.
¶¶E F
NewGuid
¶¶F M
(
¶¶M N
)
¶¶N O
;
¶¶O P
public
¶¶Q W
Guid
¶¶X \
?
¶¶\ ]"
PaymentTransactionId
¶¶^ r
{
¶¶s t
get
¶¶u x
;
¶¶x y
set
¶¶z }
;
¶¶} ~
}¶¶ Ä
public¶¶Å á
Guid¶¶à å
ClientId¶¶ç ï
{¶¶ñ ó
get¶¶ò õ
;¶¶õ ú
set¶¶ù †
;¶¶† °
}¶¶¢ £
public¶¶§ ™
TaxDocumentType¶¶´ ∫
Type¶¶ª ø
{¶¶¿ ¡
get¶¶¬ ≈
;¶¶≈ ∆
set¶¶«  
;¶¶  À
}¶¶Ã Õ
public¶¶Œ ‘
string¶¶’ €
Series¶¶‹ ‚
{¶¶„ ‰
get¶¶Â Ë
;¶¶Ë È
set¶¶Í Ì
;¶¶Ì Ó
}¶¶Ô 
=¶¶Ò Ú
string¶¶Û ˘
.¶¶˘ ˙
Empty¶¶˙ ˇ
;¶¶ˇ Ä
public¶¶Å á
int¶¶à ã
Number¶¶å í
{¶¶ì î
get¶¶ï ò
;¶¶ò ô
set¶¶ö ù
;¶¶ù û
}¶¶ü †
public¶¶° ß
DateOnly¶¶® ∞
	IssueDate¶¶± ∫
{¶¶ª º
get¶¶Ω ¿
;¶¶¿ ¡
set¶¶¬ ≈
;¶¶≈ ∆
}¶¶« »
public¶¶… œ
string¶¶– ÷
Currency¶¶◊ ﬂ
{¶¶‡ ·
get¶¶‚ Â
;¶¶Â Ê
set¶¶Á Í
;¶¶Í Î
}¶¶Ï Ì
=¶¶Ó Ô
$str¶¶ ı
;¶¶ı ˆ
public¶¶˜ ˝
decimal¶¶˛ Ö

BaseAmount¶¶Ü ê
{¶¶ë í
get¶¶ì ñ
;¶¶ñ ó
set¶¶ò õ
;¶¶õ ú
}¶¶ù û
public¶¶ü •
decimal¶¶¶ ≠
	IgvAmount¶¶Æ ∑
{¶¶∏ π
get¶¶∫ Ω
;¶¶Ω æ
set¶¶ø ¬
;¶¶¬ √
}¶¶ƒ ≈
public¶¶∆ Ã
decimal¶¶Õ ‘
TotalAmount¶¶’ ‡
{¶¶· ‚
get¶¶„ Ê
;¶¶Ê Á
set¶¶Ë Î
;¶¶Î Ï
}¶¶Ì Ó
public¶¶Ô ı
string¶¶ˆ ¸
?¶¶¸ ˝
Notes¶¶˛ É
{¶¶Ñ Ö
get¶¶Ü â
;¶¶â ä
set¶¶ã é
;¶¶é è
}¶¶ê ë
public
ßß 

decimal
ßß 
?
ßß 
RetentionAmount
ßß #
{
ßß$ %
get
ßß& )
;
ßß) *
set
ßß+ .
;
ßß. /
}
ßß0 1
}
ßß2 3
public≠≠ 
sealed
≠≠ 
class
≠≠ 
PaymentReversal
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
≠≠\ `
ClientId
≠≠a i
{
≠≠j k
get
≠≠l o
;
≠≠o p
set
≠≠q t
;
≠≠t u
}
≠≠v w
public
≠≠x ~
Guid≠≠ É
?≠≠É Ñ
ClientProductId≠≠Ö î
{≠≠ï ñ
get≠≠ó ö
;≠≠ö õ
set≠≠ú ü
;≠≠ü †
}≠≠° ¢
public
ÆÆ 

string
ÆÆ 
?
ÆÆ 

PaymentKey
ÆÆ 
{
ÆÆ 
get
ÆÆ  #
;
ÆÆ# $
set
ÆÆ% (
;
ÆÆ( )
}
ÆÆ* +
public
ÆÆ, 2
string
ÆÆ3 9
?
ÆÆ9 :
Method
ÆÆ; A
{
ÆÆB C
get
ÆÆD G
;
ÆÆG H
set
ÆÆI L
;
ÆÆL M
}
ÆÆN O
public
ÆÆP V
string
ÆÆW ]
?
ÆÆ] ^
InternalCode
ÆÆ_ k
{
ÆÆl m
get
ÆÆn q
;
ÆÆq r
set
ÆÆs v
;
ÆÆv w
}
ÆÆx y
publicÆÆz Ä
decimalÆÆÅ à
AmountÆÆâ è
{ÆÆê ë
getÆÆí ï
;ÆÆï ñ
setÆÆó ö
;ÆÆö õ
}ÆÆú ù
publicÆÆû §
stringÆÆ• ´
CurrencyÆÆ¨ ¥
{ÆÆµ ∂
getÆÆ∑ ∫
;ÆÆ∫ ª
setÆÆº ø
;ÆÆø ¿
}ÆÆ¡ ¬
=ÆÆ√ ƒ
$strÆÆ≈  
;ÆÆ  À
publicÆÆÃ “
decimalÆÆ” ⁄
?ÆÆ⁄ €
	AmountPenÆÆ‹ Â
{ÆÆÊ Á
getÆÆË Î
;ÆÆÎ Ï
setÆÆÌ 
;ÆÆ Ò
}ÆÆÚ Û
publicÆÆÙ ˙
DateTimeÆÆ˚ É
?ÆÆÉ Ñ
PaidAtÆÆÖ ã
{ÆÆå ç
getÆÆé ë
;ÆÆë í
setÆÆì ñ
;ÆÆñ ó
}ÆÆò ô
public
ØØ 

TaxDocumentType
ØØ 
DocumentType
ØØ '
{
ØØ( )
get
ØØ* -
;
ØØ- .
set
ØØ/ 2
;
ØØ2 3
}
ØØ4 5
public
ØØ6 <
string
ØØ= C
Series
ØØD J
{
ØØK L
get
ØØM P
;
ØØP Q
set
ØØR U
;
ØØU V
}
ØØW X
=
ØØY Z
string
ØØ[ a
.
ØØa b
Empty
ØØb g
;
ØØg h
public
ØØi o
int
ØØp s
Number
ØØt z
{
ØØ{ |
getØØ} Ä
;ØØÄ Å
setØØÇ Ö
;ØØÖ Ü
}ØØá à
publicØØâ è
DateOnlyØØê ò
	IssueDateØØô ¢
{ØØ£ §
getØØ• ®
;ØØ® ©
setØØ™ ≠
;ØØ≠ Æ
}ØØØ ∞
public
∞∞ 

string
∞∞ 
Reason
∞∞ 
{
∞∞ 
get
∞∞ 
;
∞∞ 
set
∞∞  #
;
∞∞# $
}
∞∞% &
=
∞∞' (
string
∞∞) /
.
∞∞/ 0
Empty
∞∞0 5
;
∞∞5 6
public
±± 

bool
±± 
	NotIssued
±± 
{
±± 
get
±± 
;
±±  
set
±±! $
;
±±$ %
}
±±& '
public
±±( .
bool
±±/ 3
NumberReleased
±±4 B
{
±±C D
get
±±E H
;
±±H I
set
±±J M
;
±±M N
}
±±O P
public
±±Q W
Guid
±±X \
?
±±\ ]
ReversedByUserId
±±^ n
{
±±o p
get
±±q t
;
±±t u
set
±±v y
;
±±y z
}
±±{ |
public±±} É
DateTime±±Ñ å

ReversedAt±±ç ó
{±±ò ô
get±±ö ù
;±±ù û
set±±ü ¢
;±±¢ £
}±±§ •
=±±¶ ß
DateTime±±® ∞
.±±∞ ±
UtcNow±±± ∑
;±±∑ ∏
}±±π ∫
public¥¥ 
sealed
¥¥ 
class
¥¥ 
TaxDocumentLine
¥¥ #
{
¥¥$ %
public
¥¥& ,
Guid
¥¥- 1
Id
¥¥2 4
{
¥¥5 6
get
¥¥7 :
;
¥¥: ;
set
¥¥< ?
;
¥¥? @
}
¥¥A B
=
¥¥C D
Guid
¥¥E I
.
¥¥I J
NewGuid
¥¥J Q
(
¥¥Q R
)
¥¥R S
;
¥¥S T
public
¥¥U [
Guid
¥¥\ `
TaxDocumentId
¥¥a n
{
¥¥o p
get
¥¥q t
;
¥¥t u
set
¥¥v y
;
¥¥y z
}
¥¥{ |
public¥¥} É
Guid¥¥Ñ à
?¥¥à â
ClientProductId¥¥ä ô
{¥¥ö õ
get¥¥ú ü
;¥¥ü †
set¥¥° §
;¥¥§ •
}¥¥¶ ß
public¥¥® Æ
string¥¥Ø µ
Description¥¥∂ ¡
{¥¥¬ √
get¥¥ƒ «
;¥¥« »
set¥¥… Ã
;¥¥Ã Õ
}¥¥Œ œ
=¥¥– —
string¥¥“ ÿ
.¥¥ÿ Ÿ
Empty¥¥Ÿ ﬁ
;¥¥ﬁ ﬂ
public¥¥‡ Ê
decimal¥¥Á Ó
Amount¥¥Ô ı
{¥¥ˆ ˜
get¥¥¯ ˚
;¥¥˚ ¸
set¥¥˝ Ä
;¥¥Ä Å
}¥¥Ç É
public¥¥Ñ ä
int¥¥ã é
Order¥¥è î
{¥¥ï ñ
get¥¥ó ö
;¥¥ö õ
set¥¥ú ü
;¥¥ü †
}¥¥° ¢
}¥¥£ §
public∂∂ 
sealed
∂∂ 
class
∂∂ 
Expense
∂∂ 
{
∂∂ 
public
∂∂ $
Guid
∂∂% )
Id
∂∂* ,
{
∂∂- .
get
∂∂/ 2
;
∂∂2 3
set
∂∂4 7
;
∂∂7 8
}
∂∂9 :
=
∂∂; <
Guid
∂∂= A
.
∂∂A B
NewGuid
∂∂B I
(
∂∂I J
)
∂∂J K
;
∂∂K L
public
∂∂M S
string
∂∂T Z
Description
∂∂[ f
{
∂∂g h
get
∂∂i l
;
∂∂l m
set
∂∂n q
;
∂∂q r
}
∂∂s t
=
∂∂u v
string
∂∂w }
.
∂∂} ~
Empty∂∂~ É
;∂∂É Ñ
public∂∂Ö ã
Guid∂∂å ê

CategoryId∂∂ë õ
{∂∂ú ù
get∂∂û °
;∂∂° ¢
set∂∂£ ¶
;∂∂¶ ß
}∂∂® ©
public∂∂™ ∞
ExpenseCategory∂∂± ¿
?∂∂¿ ¡
Category∂∂¬  
{∂∂À Ã
get∂∂Õ –
;∂∂– —
set∂∂“ ’
;∂∂’ ÷
}∂∂◊ ÿ
public∂∂Ÿ ﬂ
ExpenseType∂∂‡ Î
Type∂∂Ï 
{∂∂Ò Ú
get∂∂Û ˆ
;∂∂ˆ ˜
set∂∂¯ ˚
;∂∂˚ ¸
}∂∂˝ ˛
public∂∂ˇ Ö
decimal∂∂Ü ç
Amount∂∂é î
{∂∂ï ñ
get∂∂ó ö
;∂∂ö õ
set∂∂ú ü
;∂∂ü †
}∂∂° ¢
public∂∂£ ©
string∂∂™ ∞
Currency∂∂± π
{∂∂∫ ª
get∂∂º ø
;∂∂ø ¿
set∂∂¡ ƒ
;∂∂ƒ ≈
}∂∂∆ «
=∂∂» …
$str∂∂  œ
;∂∂œ –
public∂∂— ◊
decimal∂∂ÿ ﬂ
	AmountPen∂∂‡ È
{∂∂Í Î
get∂∂Ï Ô
;∂∂Ô 
set∂∂Ò Ù
;∂∂Ù ı
}∂∂ˆ ˜
public∂∂¯ ˛
DateOnly∂∂ˇ á
Date∂∂à å
{∂∂ç é
get∂∂è í
;∂∂í ì
set∂∂î ó
;∂∂ó ò
}∂∂ô ö
public∂∂õ °
bool∂∂¢ ¶
	Recurring∂∂ß ∞
{∂∂± ≤
get∂∂≥ ∂
;∂∂∂ ∑
set∂∂∏ ª
;∂∂ª º
}∂∂Ω æ
public∂∂ø ≈
BillingCycle∂∂∆ “
?∂∂“ ”
RecurrenceCycle∂∂‘ „
{∂∂‰ Â
get∂∂Ê È
;∂∂È Í
set∂∂Î Ó
;∂∂Ó Ô
}∂∂ Ò
public
∑∑ 
DateOnly
∑∑ 
?
∑∑ 
RecurrenceEndsAt
∑∑ "
{
∑∑# $
get
∑∑% (
;
∑∑( )
set
∑∑* -
;
∑∑- .
}
∑∑/ 0
public
ππ 

bool
ππ 
IsNonDeductible
ππ 
{
ππ  !
get
ππ" %
;
ππ% &
set
ππ' *
;
ππ* +
}
ππ, -
public
ªª 

bool
ªª #
IsNonDomiciledService
ªª %
{
ªª& '
get
ªª( +
;
ªª+ ,
set
ªª- 0
;
ªª0 1
}
ªª2 3
public
ªª4 :
string
ªª; A
?
ªªA B!
ForeignSupplierName
ªªC V
{
ªªW X
get
ªªY \
;
ªª\ ]
set
ªª^ a
;
ªªa b
}
ªªc d
public
ªªe k
string
ªªl r
?
ªªr s%
ForeignSupplierCountryªªt ä
{ªªã å
getªªç ê
;ªªê ë
setªªí ï
;ªªï ñ
}ªªó ò
public
ΩΩ 

DateOnly
ΩΩ 
?
ΩΩ 
Form1662PaidAt
ΩΩ #
{
ΩΩ$ %
get
ΩΩ& )
;
ΩΩ) *
set
ΩΩ+ .
;
ΩΩ. /
}
ΩΩ0 1
public
ΩΩ2 8
string
ΩΩ9 ?
?
ΩΩ? @
Form1662Number
ΩΩA O
{
ΩΩP Q
get
ΩΩR U
;
ΩΩU V
set
ΩΩW Z
;
ΩΩZ [
}
ΩΩ\ ]
}
ΩΩ^ _
public¿¿ 
sealed
¿¿ 
class
¿¿ 
TaxSettings
¿¿ 
{¡¡ 
public
¬¬ 

Guid
¬¬ 
Id
¬¬ 
{
¬¬ 
get
¬¬ 
;
¬¬ 
set
¬¬ 
;
¬¬ 
}
¬¬  
=
¬¬! "
Guid
¬¬# '
.
¬¬' (
NewGuid
¬¬( /
(
¬¬/ 0
)
¬¬0 1
;
¬¬1 2
public
¬¬3 9
decimal
¬¬: A
IgvRate
¬¬B I
{
¬¬J K
get
¬¬L O
;
¬¬O P
set
¬¬Q T
;
¬¬T U
}
¬¬V W
=
¬¬X Y
$num
¬¬Z _
;
¬¬_ `
public
¬¬a g
decimal
¬¬h o
	RentaRate
¬¬p y
{
¬¬z {
get
¬¬| 
;¬¬ Ä
set¬¬Å Ñ
;¬¬Ñ Ö
}¬¬Ü á
=¬¬à â
$num¬¬ä è
;¬¬è ê
public¬¬ë ó
DateTime¬¬ò †
	UpdatedAt¬¬° ™
{¬¬´ ¨
get¬¬≠ ∞
;¬¬∞ ±
set¬¬≤ µ
;¬¬µ ∂
}¬¬∑ ∏
=¬¬π ∫
DateTime¬¬ª √
.¬¬√ ƒ
UtcNow¬¬ƒ  
;¬¬  À
public
≈≈ 

string
≈≈ 
FacturaSeries
≈≈ 
{
≈≈  !
get
≈≈" %
;
≈≈% &
set
≈≈' *
;
≈≈* +
}
≈≈, -
=
≈≈. /
$str
≈≈0 6
;
≈≈6 7
public
≈≈8 >
int
≈≈? B
FacturaNextNumber
≈≈C T
{
≈≈U V
get
≈≈W Z
;
≈≈Z [
set
≈≈\ _
;
≈≈_ `
}
≈≈a b
=
≈≈c d
$num
≈≈e f
;
≈≈f g
public
∆∆ 

string
∆∆ 
ReciboSeries
∆∆ 
{
∆∆  
get
∆∆! $
;
∆∆$ %
set
∆∆& )
;
∆∆) *
}
∆∆+ ,
=
∆∆- .
$str
∆∆/ 5
;
∆∆5 6
public
∆∆7 =
int
∆∆> A
ReciboNextNumber
∆∆B R
{
∆∆S T
get
∆∆U X
;
∆∆X Y
set
∆∆Z ]
;
∆∆] ^
}
∆∆_ `
=
∆∆a b
$num
∆∆c d
;
∆∆d e
public
»» 

string
»» 
?
»» 
Ruc
»» 
{
»» 
get
»» 
;
»» 
set
»» !
;
»»! "
}
»»# $
public
»»% +
bool
»», 0
IsGoodTaxpayer
»»1 ?
{
»»@ A
get
»»B E
;
»»E F
set
»»G J
;
»»J K
}
»»L M
public
   

bool
   
Use1662AsCredit
   
{
    !
get
  " %
;
  % &
set
  ' *
;
  * +
}
  , -
}ÀÀ 
public—— 
sealed
—— 
class
—— 
AnnualTaxSettings
—— %
{““ 
public
”” 

Guid
”” 
Id
”” 
{
”” 
get
”” 
;
”” 
set
”” 
;
”” 
}
””  
=
””! "
Guid
””# '
.
””' (
NewGuid
””( /
(
””/ 0
)
””0 1
;
””1 2
public
””3 9
int
””: =
Year
””> B
{
””C D
get
””E H
;
””H I
set
””J M
;
””M N
}
””O P
public
””Q W
decimal
””X _
Uit
””` c
{
””d e
get
””f i
;
””i j
set
””k n
;
””n o
}
””p q
public
‘‘ 

decimal
‘‘ 
ThresholdUits
‘‘  
{
‘‘! "
get
‘‘# &
;
‘‘& '
set
‘‘( +
;
‘‘+ ,
}
‘‘- .
=
‘‘/ 0
$num
‘‘1 4
;
‘‘4 5
public
‘‘6 <
decimal
‘‘= D
LowRate
‘‘E L
{
‘‘M N
get
‘‘O R
;
‘‘R S
set
‘‘T W
;
‘‘W X
}
‘‘Y Z
=
‘‘[ \
$num
‘‘] b
;
‘‘b c
public
‘‘d j
decimal
‘‘k r
HighRate
‘‘s {
{
‘‘| }
get‘‘~ Å
;‘‘Å Ç
set‘‘É Ü
;‘‘Ü á
}‘‘à â
=‘‘ä ã
$num‘‘å í
;‘‘í ì
}’’ 
public‹‹ 
sealed
‹‹ 
class
‹‹ 

TaxDueDate
‹‹ 
{›› 
public
ﬁﬁ 

Guid
ﬁﬁ 
Id
ﬁﬁ 
{
ﬁﬁ 
get
ﬁﬁ 
;
ﬁﬁ 
set
ﬁﬁ 
;
ﬁﬁ 
}
ﬁﬁ  
=
ﬁﬁ! "
Guid
ﬁﬁ# '
.
ﬁﬁ' (
NewGuid
ﬁﬁ( /
(
ﬁﬁ/ 0
)
ﬁﬁ0 1
;
ﬁﬁ1 2
public
‡‡ 

DateOnly
‡‡ 
Period
‡‡ 
{
‡‡ 
get
‡‡  
;
‡‡  !
set
‡‡" %
;
‡‡% &
}
‡‡' (
public
·· 

DateOnly
·· 
Digit0
·· 
{
·· 
get
··  
;
··  !
set
··" %
;
··% &
}
··' (
public
··) /
DateOnly
··0 8
Digit1
··9 ?
{
··@ A
get
··B E
;
··E F
set
··G J
;
··J K
}
··L M
public
··N T
DateOnly
··U ]

Digit2And3
··^ h
{
··i j
get
··k n
;
··n o
set
··p s
;
··s t
}
··u v
public
··w }
DateOnly··~ Ü

Digit4And5··á ë
{··í ì
get··î ó
;··ó ò
set··ô ú
;··ú ù
}··û ü
public··† ¶
DateOnly··ß Ø

Digit6And7··∞ ∫
{··ª º
get··Ω ¿
;··¿ ¡
set··¬ ≈
;··≈ ∆
}··« »
public··… œ
DateOnly··– ÿ

Digit8And9··Ÿ „
{··‰ Â
get··Ê È
;··È Í
set··Î Ó
;··Ó Ô
}·· Ò
public
„„ 

DateOnly
„„ 
GoodTaxpayer
„„  
{
„„! "
get
„„# &
;
„„& '
set
„„( +
;
„„+ ,
}
„„- .
public
‰‰ 

DateTime
‰‰ 
?
‰‰ 
FiledAt
‰‰ 
{
‰‰ 
get
‰‰ "
;
‰‰" #
set
‰‰$ '
;
‰‰' (
}
‰‰) *
public
ÊÊ 

decimal
ÊÊ 
?
ÊÊ 
IgvPaid
ÊÊ 
{
ÊÊ 
get
ÊÊ !
;
ÊÊ! "
set
ÊÊ# &
;
ÊÊ& '
}
ÊÊ( )
public
ÊÊ* 0
decimal
ÊÊ1 8
?
ÊÊ8 9
	RentaPaid
ÊÊ: C
{
ÊÊD E
get
ÊÊF I
;
ÊÊI J
set
ÊÊK N
;
ÊÊN O
}
ÊÊP Q
public
ÈÈ 

DateOnly
ÈÈ 
?
ÈÈ 
DueFor
ÈÈ 
(
ÈÈ 
string
ÈÈ "
?
ÈÈ" #
ruc
ÈÈ$ '
,
ÈÈ' (
bool
ÈÈ) -
goodTaxpayer
ÈÈ. :
)
ÈÈ: ;
{
ÍÍ 
if
ÎÎ 

(
ÎÎ 
goodTaxpayer
ÎÎ 
)
ÎÎ 
return
ÎÎ  
GoodTaxpayer
ÎÎ! -
;
ÎÎ- .
if
ÏÏ 

(
ÏÏ 
string
ÏÏ 
.
ÏÏ  
IsNullOrWhiteSpace
ÏÏ %
(
ÏÏ% &
ruc
ÏÏ& )
)
ÏÏ) *
||
ÏÏ+ -
!
ÏÏ. /
char
ÏÏ/ 3
.
ÏÏ3 4
IsAsciiDigit
ÏÏ4 @
(
ÏÏ@ A
ruc
ÏÏA D
.
ÏÏD E
Trim
ÏÏE I
(
ÏÏI J
)
ÏÏJ K
[
ÏÏK L
^
ÏÏL M
$num
ÏÏM N
]
ÏÏN O
)
ÏÏO P
)
ÏÏP Q
return
ÏÏR X
null
ÏÏY ]
;
ÏÏ] ^
return
ÌÌ 
(
ÌÌ 
ruc
ÌÌ 
.
ÌÌ 
Trim
ÌÌ 
(
ÌÌ 
)
ÌÌ 
[
ÌÌ 
^
ÌÌ 
$num
ÌÌ 
]
ÌÌ 
-
ÌÌ  
$char
ÌÌ! $
)
ÌÌ$ %
switch
ÌÌ& ,
{
ÌÌ- .
$num
ÌÌ/ 0
=>
ÌÌ1 3
Digit0
ÌÌ4 :
,
ÌÌ: ;
$num
ÌÌ< =
=>
ÌÌ> @
Digit1
ÌÌA G
,
ÌÌG H
$num
ÌÌI J
or
ÌÌK M
$num
ÌÌN O
=>
ÌÌP R

Digit2And3
ÌÌS ]
,
ÌÌ] ^
$num
ÌÌ_ `
or
ÌÌa c
$num
ÌÌd e
=>
ÌÌf h

Digit4And5
ÌÌi s
,
ÌÌs t
$num
ÌÌu v
or
ÌÌw y
$num
ÌÌz {
=>
ÌÌ| ~

Digit6And7ÌÌ â
,ÌÌâ ä
_ÌÌã å
=>ÌÌç è

Digit8And9ÌÌê ö
}ÌÌõ ú
;ÌÌú ù
}
ÓÓ 
}ÔÔ 
publicıı 
static
ıı 
class
ıı 
TaxDueDateSeed
ıı "
{ˆˆ 
public
˜˜ 

static
˜˜ 

TaxDueDate
˜˜ 
[
˜˜ 
]
˜˜ 
Rows2026
˜˜ '
=>
˜˜( *
Rows
˜˜+ /
(
˜˜/ 0
$num
˜˜0 4
,
˜˜4 5
[
¯¯ 
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
(
˛˛ 	
$str
˛˛	 
,
˛˛ 
$str
˛˛ #
,
˛˛# $
$str
˛˛% 1
,
˛˛1 2
$str
˛˛3 ?
,
˛˛? @
$str
˛˛A M
,
˛˛M N
$str
˛˛O [
,
˛˛[ \
$str
˛˛] i
)
˛˛i j
,
˛˛j k
(
ˇˇ 	
$str
ˇˇ	 
,
ˇˇ 
$str
ˇˇ #
,
ˇˇ# $
$str
ˇˇ% 1
,
ˇˇ1 2
$str
ˇˇ3 ?
,
ˇˇ? @
$str
ˇˇA M
,
ˇˇM N
$str
ˇˇO [
,
ˇˇ[ \
$str
ˇˇ] i
)
ˇˇi j
,
ˇˇj k
(
ÄÄ 	
$str
ÄÄ	 
,
ÄÄ 
$str
ÄÄ #
,
ÄÄ# $
$str
ÄÄ% 1
,
ÄÄ1 2
$str
ÄÄ3 ?
,
ÄÄ? @
$str
ÄÄA M
,
ÄÄM N
$str
ÄÄO [
,
ÄÄ[ \
$str
ÄÄ] i
)
ÄÄi j
,
ÄÄj k
(
ÅÅ 	
$str
ÅÅ	 
,
ÅÅ 
$str
ÅÅ #
,
ÅÅ# $
$str
ÅÅ% 1
,
ÅÅ1 2
$str
ÅÅ3 ?
,
ÅÅ? @
$str
ÅÅA M
,
ÅÅM N
$str
ÅÅO [
,
ÅÅ[ \
$str
ÅÅ] i
)
ÅÅi j
,
ÅÅj k
(
ÇÇ 	
$str
ÇÇ	 
,
ÇÇ 
$str
ÇÇ #
,
ÇÇ# $
$str
ÇÇ% 1
,
ÇÇ1 2
$str
ÇÇ3 ?
,
ÇÇ? @
$str
ÇÇA M
,
ÇÇM N
$str
ÇÇO [
,
ÇÇ[ \
$str
ÇÇ] i
)
ÇÇi j
,
ÇÇj k
(
ÉÉ 	
$str
ÉÉ	 
,
ÉÉ 
$str
ÉÉ #
,
ÉÉ# $
$str
ÉÉ% 1
,
ÉÉ1 2
$str
ÉÉ3 ?
,
ÉÉ? @
$str
ÉÉA M
,
ÉÉM N
$str
ÉÉO [
,
ÉÉ[ \
$str
ÉÉ] i
)
ÉÉi j
,
ÉÉj k
(
ÑÑ 	
$str
ÑÑ	 
,
ÑÑ 
$str
ÑÑ #
,
ÑÑ# $
$str
ÑÑ% 1
,
ÑÑ1 2
$str
ÑÑ3 ?
,
ÑÑ? @
$str
ÑÑA M
,
ÑÑM N
$str
ÑÑO [
,
ÑÑ[ \
$str
ÑÑ] i
)
ÑÑi j
,
ÑÑj k
]
ÖÖ 
)
ÖÖ 
;
ÖÖ 
private
áá 
static
áá 

TaxDueDate
áá 
[
áá 
]
áá 
Rows
áá  $
(
áá$ %
int
áá% (
year
áá) -
,
áá- .
(
áá/ 0
string
áá0 6
,
áá6 7
string
áá8 >
,
áá> ?
string
áá@ F
,
ááF G
string
ááH N
,
ááN O
string
ááP V
,
ááV W
string
ááX ^
,
áá^ _
string
áá` f
)
ááf g
[
áág h
]
ááh i
months
ááj p
)
ááp q
=>
áár t
months
ááu {
.
áá{ |
Selectáá| Ç
(ááÇ É
(ááÉ Ñ
mááÑ Ö
,ááÖ Ü
iááá à
)ááà â
=>ááä å
newááç ê

TaxDueDateááë õ
{
àà 
Id
ää 

=
ää 
new
ää 
Guid
ää 
(
ää 
$"
ää 
$str
ää 0
{
ää0 1
year
ää1 5
:
ää5 6
$str
ää6 8
}
ää8 9
{
ää9 :
i
ää: ;
+
ää< =
$num
ää> ?
:
ää? @
$str
ää@ B
}
ääB C
"
ääC D
)
ääD E
,
ääE F
Period
ääG M
=
ääN O
new
ääP S
DateOnly
ääT \
(
ää\ ]
year
ää] a
,
ääa b
i
ääc d
+
ääe f
$num
ääg h
,
ääh i
$num
ääj k
)
ääk l
,
ääl m
Digit0
ãã 
=
ãã 
DateOnly
ãã 
.
ãã 
Parse
ãã 
(
ãã  
m
ãã  !
.
ãã! "
Item1
ãã" '
,
ãã' (
CultureInfo
ãã) 4
.
ãã4 5
InvariantCulture
ãã5 E
)
ããE F
,
ããF G
Digit1
ããH N
=
ããO P
DateOnly
ããQ Y
.
ããY Z
Parse
ããZ _
(
ãã_ `
m
ãã` a
.
ããa b
Item2
ããb g
,
ããg h
CultureInfo
ããi t
.
ããt u
InvariantCultureããu Ö
)ããÖ Ü
,ããÜ á

Digit2And3ããà í
=ããì î
DateOnlyããï ù
.ããù û
Parseããû £
(ãã£ §
mãã§ •
.ãã• ¶
Item3ãã¶ ´
,ãã´ ¨
CultureInfoãã≠ ∏
.ãã∏ π 
InvariantCultureããπ …
)ãã…  
,ãã  À

Digit4And5ããÃ ÷
=ãã◊ ÿ
DateOnlyããŸ ·
.ãã· ‚
Parseãã‚ Á
(ããÁ Ë
mããË È
.ããÈ Í
Item4ããÍ Ô
,ããÔ 
CultureInfoããÒ ¸
.ãã¸ ˝ 
InvariantCultureãã˝ ç
)ããç é
,ããé è

Digit6And7
åå 
=
åå 
DateOnly
åå 
.
åå 
Parse
åå #
(
åå# $
m
åå$ %
.
åå% &
Item5
åå& +
,
åå+ ,
CultureInfo
åå- 8
.
åå8 9
InvariantCulture
åå9 I
)
ååI J
,
ååJ K

Digit8And9
ååL V
=
ååW X
DateOnly
ååY a
.
ååa b
Parse
ååb g
(
ååg h
m
ååh i
.
ååi j
Item6
ååj o
,
ååo p
CultureInfo
ååq |
.
åå| }
InvariantCultureåå} ç
)ååç é
,ååé è
GoodTaxpayerååê ú
=ååù û
DateOnlyååü ß
.ååß ®
Parseåå® ≠
(åå≠ Æ
mååÆ Ø
.ååØ ∞
Item7åå∞ µ
,ååµ ∂
CultureInfoåå∑ ¬
.åå¬ √ 
InvariantCultureåå√ ”
)åå” ‘
,åå‘ ’
}
çç 
)
çç 
.
çç 
ToArray
çç 
(
çç 
)
çç 
;
çç 
}éé 
publicîî 
sealed
îî 
class
îî  
PortalNotification
îî &
{
îî' (
public
îî) /
Guid
îî0 4
Id
îî5 7
{
îî8 9
get
îî: =
;
îî= >
set
îî? B
;
îîB C
}
îîD E
=
îîF G
Guid
îîH L
.
îîL M
NewGuid
îîM T
(
îîT U
)
îîU V
;
îîV W
public
îîX ^
Guid
îî_ c
ClientId
îîd l
{
îîm n
get
îîo r
;
îîr s
set
îît w
;
îîw x
}
îîy z
publicîî{ Å
stringîîÇ à
Typeîîâ ç
{îîé è
getîîê ì
;îîì î
setîîï ò
;îîò ô
}îîö õ
=îîú ù
stringîîû §
.îî§ •
Emptyîî• ™
;îî™ ´
publicîî¨ ≤
boolîî≥ ∑
ForStaffîî∏ ¿
{îî¡ ¬
getîî√ ∆
;îî∆ «
setîî» À
;îîÀ Ã
}îîÕ Œ
publicîîœ ’
stringîî÷ ‹
DataJsonîî› Â
{îîÊ Á
getîîË Î
;îîÎ Ï
setîîÌ 
;îî Ò
}îîÚ Û
=îîÙ ı
$strîîˆ ˙
;îî˙ ˚
publicîî¸ Ç
stringîîÉ â
?îîâ ä
	DedupeKeyîîã î
{îîï ñ
getîîó ö
;îîö õ
setîîú ü
;îîü †
}îî° ¢
publicîî£ ©
DateTimeîî™ ≤
	CreatedAtîî≥ º
{îîΩ æ
getîîø ¬
;îî¬ √
setîîƒ «
;îî« »
}îî…  
=îîÀ Ã
DateTimeîîÕ ’
.îî’ ÷
UtcNowîî÷ ‹
;îî‹ ›
}îîﬁ ﬂÓ
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
} ëp
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
-7 8
PendingDiscount9 H
(H I
itemI M
)M N
:O P
nullQ U
;U V
private 
static 
decimal 
PendingDiscount *
(* +
ClientProduct+ 8
item9 =
)= >
=>? A
itemB F
.F G
DiscountPendingUseG Y
(Y Z
)Z [
?\ ]
item^ b
.b c
Discountc k
!k l
.l m
Valuem r
:s t
$numu w
;w x
public!! 

static!! 
decimal!! 

IgvRateFor!! $
(!!$ %
Client!!% +
client!!, 2
,!!2 3
Product!!4 ;
product!!< C
,!!C D
decimal!!E L
igvRate!!M T
)!!T U
=>!!V X
client"" 
."" 
RequiresTaxDocument"" "
&&""# %
product""& -
.""- .
TaxDocumentType"". =
==""> @
TaxDocumentType""A P
.""P Q
Factura""Q X
?""Y Z
igvRate""[ b
:""c d
$num""e g
;""g h
public$$ 

static$$ 
decimal$$ 
WithIgv$$ !
($$! "
decimal$$" )
net$$* -
,$$- .
decimal$$/ 6
igvRate$$7 >
)$$> ?
=>$$@ B
Math$$C G
.$$G H
Round$$H M
($$M N
net$$N Q
*$$R S
($$T U
$num$$U V
+$$W X
igvRate$$Y `
)$$` a
,$$a b
$num$$c d
)$$d e
;$$e f
public'' 

static'' 
decimal'' 
?'' 
NextChargeTotal'' *
(''* +
this''+ /
ClientProduct''0 =
item''> B
,''B C
decimal''D K
igvRate''L S
,''S T
Product''U \
?''\ ]
product''^ e
=''f g
null''h l
)''l m
=>''n p
item(( 
.(( 
NextChargePrice(( 
((( 
product(( $
)(($ %
is((& (
decimal(() 0
net((1 4
?((5 6
WithIgv((7 >
(((> ?
net((? B
,((B C
igvRate((D K
)((K L
:((M N
null((O S
;((S T
public** 

const** 
int** 
MaxPrepaidYears** $
=**% &
$num**' (
;**( )
public00 

static00 
decimal00 
?00 
ChargeTotal00 &
(00& '
this00' +
ClientProduct00, 9
item00: >
,00> ?
decimal00@ G
igvRate00H O
,00O P
int00Q T
years00U Z
,00Z [
Product00\ c
?00c d
product00e l
=00m n
null00o s
)00s t
=>00u w
item11 
.11 
NextChargePrice11 
(11 
product11 $
)11$ %
is11& (
decimal11) 0
first111 6
&&117 9
item11: >
.11> ?
	ListPrice11? H
(11H I
product11I P
)11P Q
is11R T
decimal11U \
list11] a
?11b c
WithIgv11d k
(11k l
first11l q
+11r s
(11t u
years11u z
-11{ |
$num11} ~
)11~ 
*
11Ä Å
list
11Ç Ü
,
11Ü á
igvRate
11à è
)
11è ê
:
11ë í
null
11ì ó
;
11ó ò
public44 

static44 
string44 
?44 
ValidateYears44 '
(44' (
this44( ,
ClientProduct44- :
item44; ?
,44? @
int44A D
years44E J
)44J K
{55 
if66 

(66 
years66 
<66 
$num66 
||66 
years66 
>66  
MaxPrepaidYears66! 0
)660 1
return662 8
$"669 ;
$str66; R
{66R S
MaxPrepaidYears66S b
}66b c
$str66c i
"66i j
;66j k
return77 
years77 
>77 
$num77 
&&77 
item77  
.77  !
BillingCycle77! -
!=77. 0
BillingCycle771 =
.77= >
Anual77> C
?77D E
$str	77F É
:
77Ñ Ö
null
77Ü ä
;
77ä ã
}88 
public;; 

static;; 
decimal;; 
?;; 
CurrentPrice;; '
(;;' (
this;;( ,
ClientProduct;;- :
item;;; ?
,;;? @
DateTime;;A I
now;;J M
,;;M N
Product;;O V
?;;V W
product;;X _
=;;` a
null;;b f
);;f g
=>;;h j
item<< 
.<< 
	ListPrice<< 
(<< 
product<< 
)<< 
is<<  "
decimal<<# *
list<<+ /
?<<0 1
list<<2 6
-<<7 8
CurrentDiscount<<9 H
(<<H I
item<<I M
,<<M N
now<<O R
)<<R S
:<<T U
null<<V Z
;<<Z [
private?? 
static?? 
decimal?? 
CurrentDiscount?? *
(??* +
ClientProduct??+ 8
item??9 =
,??= >
DateTime??? G
now??H K
)??K L
=>??M O
item@@ 
.@@ 
HasAdjustment@@ 
(@@ 
)@@ 
&&@@ 
(@@  !
item@@! %
.@@% &
DiscountEndsAt@@& 4
is@@5 7
null@@8 <
||@@= ?
now@@@ C
<@@D E
item@@F J
.@@J K
DiscountEndsAt@@K Y
)@@Y Z
?@@[ \
item@@] a
.@@a b
Discount@@b j
!@@j k
.@@k l
Value@@l q
:@@r s
$num@@t v
;@@v w
publicGG 

staticGG 
stringGG 
?GG 
SetDiscountGG %
(GG% &
thisGG& *
ClientProductGG+ 8
itemGG9 =
,GG= >
decimalGG? F
?GGF G
discountGGH P
,GGP Q
ProductGGR Y
?GGY Z
productGG[ b
=GGc d
nullGGe i
)GGi j
{HH 
ifII 

(II 
discountII 
isII 
nullII 
orII 
$numII  !
)II! "
{II# $
itemII% )
.II) *
DiscountII* 2
=II3 4
nullII5 9
;II9 :
itemII; ?
.II? @
DiscountEndsAtII@ N
=IIO P
nullIIQ U
;IIU V
returnIIW ]
nullII^ b
;IIb c
}IId e
ifJJ 

(JJ 
itemJJ 
.JJ 
	ListPriceJJ 
(JJ 
productJJ "
)JJ" #
isJJ$ &
notJJ' *
decimalJJ+ 2
listJJ3 7
)JJ7 8
returnJJ9 ?
$str	JJ@ ë
;
JJë í
ifKK 

(KK 
discountKK 
>KK 
listKK 
)KK 
returnKK #
$"KK$ &
$strKK& \
{KK\ ]
listKK] a
:KKa b
$strKKb f
}KKf g
$strKKg i
"KKi j
;KKj k
ifMM 

(MM 
discountMM 
<MM 
$numMM 
&&MM 
!MM 
stringMM #
.MM# $
IsNullOrWhiteSpaceMM$ 6
(MM6 7
itemMM7 ;
.MM; < 
PayPalSubscriptionIdMM< P
)MMP Q
&&MMR T
itemMMU Y
.MMY Z
StatusMMZ `
isMMa c
notMMd g
(MMh i
ClientProductStatusMMi |
.MM| }
	Pendiente	MM} Ü
or
MMá â!
ClientProductStatus
MMä ù
.
MMù û
	Cancelado
MMû ß
)
MMß ®
)
MM® ©
returnNN 
$strNN v
;NNv w
itemOO 
.OO 
DiscountOO 
=OO 
MathOO 
.OO 
RoundOO "
(OO" #
discountOO# +
.OO+ ,
ValueOO, 1
,OO1 2
$numOO3 4
)OO4 5
;OO5 6
itemPP 
.PP 
DiscountEndsAtPP 
=PP 
discountPP &
<PP' (
$numPP) *
||PP+ -
itemPP. 2
.PP2 3
StatusPP3 9
==PP: <
ClientProductStatusPP= P
.PPP Q
	PendientePPQ Z
?PP[ \
nullPP] a
:PPb c
itemPPd h
.PPh i
	PeriodEndPPi r
(PPr s
)PPs t
??PPu w
NoEndPPx }
;PP} ~
returnQQ 
nullQQ 
;QQ 
}RR 
publicXX 

staticXX 
voidXX 
OnPaymentAppliedXX '
(XX' (
thisXX( ,
ClientProductXX- :
itemXX; ?
)XX? @
{YY 
ifZZ 

(ZZ 
!ZZ 
itemZZ 
.ZZ 
HasAdjustmentZZ 
(ZZ  
)ZZ  !
)ZZ! "
returnZZ# )
;ZZ) *
if[[ 

([[ 
item[[ 
.[[ 
DiscountEndsAt[[ 
is[[  "
null[[# '
)[[' (
item[[) -
.[[- .
DiscountEndsAt[[. <
=[[= >
item[[? C
.[[C D
	PeriodEnd[[D M
([[M N
)[[N O
??[[P R
NoEnd[[S X
;[[X Y
else\\ 
{\\ 
item\\ 
.\\ 
Discount\\ 
=\\ 
null\\ #
;\\# $
item\\% )
.\\) *
DiscountEndsAt\\* 8
=\\9 :
null\\; ?
;\\? @
}\\A B
}]] 
publicdd 

staticdd 
voiddd 
OnPaymentReverseddd (
(dd( )
thisdd) -
ClientProductdd. ;
itemdd< @
,dd@ A
DateTimeddB J
?ddJ K
paidPeriodEndddL Y
)ddY Z
{ee 
ifff 

(ff 
itemff 
.ff 
HasAdjustmentff 
(ff 
)ff  
&&ff! #
(ff$ %
itemff% )
.ff) *
DiscountEndsAtff* 8
==ff9 ;
NoEndff< A
||ffB D
itemffE I
.ffI J
DiscountEndsAtffJ X
==ffY [
paidPeriodEndff\ i
)ffi j
)ffj k
itemffl p
.ffp q
DiscountEndsAtffq 
=
ffÄ Å
null
ffÇ Ü
;
ffÜ á
}gg 
publicjj 

staticjj 
voidjj 
OnDatesChangedjj %
(jj% &
thisjj& *
ClientProductjj+ 8
itemjj9 =
)jj= >
{kk 
ifll 

(ll 
itemll 
.ll 
DiscountEndsAtll 
==ll  "
NoEndll# (
&&ll) +
itemll, 0
.ll0 1
	PeriodEndll1 :
(ll: ;
)ll; <
isll= ?
DateTimell@ H
endllI L
)llL M
itemllN R
.llR S
DiscountEndsAtllS a
=llb c
endlld g
;llg h
}mm 
privateoo 
staticoo 
DateTimeoo 
?oo 
	PeriodEndoo &
(oo& '
thisoo' +
ClientProductoo, 9
itemoo: >
)oo> ?
=>oo@ B
itemooC G
.ooG H
BillingCycleooH T
.ooT U
IsSubscriptionooU c
(ooc d
)ood e
?oof g
itemooh l
.ool m
NextChargeAtoom y
:ooz {
item	oo| Ä
.
ooÄ Å
RenewsAt
ooÅ â
;
ooâ ä
}pp ‰:
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