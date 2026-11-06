from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import simpleSplit

pdfmetrics.registerFont(TTFont('Arial', 'C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBold', 'C:/Windows/Fonts/arialbd.ttf'))
p='output/pdf/ficha-diagnostico-web.pdf'
c=canvas.Canvas(p,pagesize=A4)
W,H=A4
def text(x,y,s,size=10,bold=False,color='#25313a'):
    c.setFillColor(HexColor(color)); c.setFont('ArialBold' if bold else 'Arial',size); c.drawString(x,y,s)
def para(s,y,size=10):
    for line in simpleSplit(s,'Arial',size,490): text(52,y,line,size); y-=15
    return y
def lines(y,n=2):
    c.setStrokeColor(HexColor('#b6c3c8'))
    for _ in range(n): c.line(52,y,543,y); y-=20
    return y
def head(k):
    text(52, H-46,'GUÍA PARA EMPRENDEDORES EN PERÚ',9,True,'#147a72')
    text(52,H-76,'¿Tu negocio necesita una página web?',20,True)
    text(52,H-96,'Ficha orientativa · No es una herramienta validada',10,False,'#52646c')
    c.setStrokeColor(HexColor('#147a72')); c.line(52,H-109,543,H-109)
    text(52,28,'Diagnóstico orientativo | Página '+str(k)+' de 2',9,False,'#66787e')

head(1); y=H-135
text(52,y,'1  Conoce tu situación',13,True); y-=25
text(52,y,'Negocio: ___________________________________    Fecha: ___________________',10); y-=27
qs=['¿Qué vendes y a quién?', '¿Qué acción quieres que haga un posible cliente?',
    '¿Qué preguntas recibes con frecuencia y dónde llegan?',
    '¿Cómo llegan hoy las personas a tu negocio?',
    '¿Quién responde, confirma precios, disponibilidad y condiciones?']
for i,q in enumerate(qs,1):
    text(52,y,str(i)+'. '+q,10,True); y-=17; y=lines(y,2); y-=3
text(52,y,'2  ¿Qué está frenando al negocio?',13,True); y-=22
for q in ['La información se repite o es difícil de encontrar.',
          'No están claros los precios, la oferta o las condiciones.',
          'Se pierden consultas o nadie tiene claro quién responde.',
          'Falta una forma de presentar la oferta o compartirla.']:
    text(52,y,'[   ]  '+q,10); y-=20
c.showPage(); head(2); y=H-135
text(52,y,'3  Elige un siguiente paso',13,True); y-=21
y=para('Página informativa: considera esta opción si la oferta y la atención están claras, pero necesitas explicar servicios, resolver dudas o facilitar el contacto.',y); y-=8
y=para('Ordena primero la venta: prioriza definir oferta, precios o cotización, disponibilidad y responsables si hoy no puedes atender una consulta de forma consistente.',y); y-=8
y=para('Ambas tareas pueden avanzar juntas: una página mínima puede recoger consultas mientras organizas la atención. No publiques condiciones que aún no puedes cumplir.',y); y-=13
text(52,y,'4  Situaciones ilustrativas',13,True); y-=22
for s in [
 'Servicio de fotografía: oferta, precios orientativos y respuesta definidos; cuesta explicar qué incluye. Recomendación: página de servicios con portafolio y solicitud de cotización.',
 'Tortas por encargo: se reciben pedidos, pero no hay responsable de confirmar fechas ni disponibilidad. Recomendación: ordenar agenda, precios y respuesta; luego mostrar condiciones en una página.',
 'Catálogo de accesorios: productos y atención definidos, pero se envían fotos una por una. Recomendación: catálogo sencillo con disponibilidad y enlace de contacto; evaluar tienda si la operación lo necesita.']:
    y=para(s,y,9.5); y-=8
text(52,y,'5  Mi decisión y próximos pasos',13,True); y-=22
text(52,y,'[   ] Página informativa    [   ] Ordenar ventas    [   ] Ambas    [   ] Revisar después',10); y-=22
text(52,y,'Primera acción / responsable / fecha:',10,True); y-=18; y=lines(y,2)
text(52,y,'¿Qué observaré para saber si el paso ayudó?',10,True); y-=18; y=lines(y,2)
c.save()
