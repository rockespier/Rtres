/*
  Carga masiva de ingresos y gastos (ej. todo 2026) para los reportes de Utilidad y Clientes.

  Requisitos previos:
    1. Clientes ya importados desde el portal.
    2. Migraciones aplicadas (arrancar el API una vez): incluye FinanceIncomeModel.

  Qué hace:
    - INGRESOS: cada fila es un cobro (PaymentTransaction). Si el Tipo es Factura o ReciboHonorarios, crea además su
      comprobante (TaxDocument) enlazado al cobro: el ingreso se cuenta una sola vez.
        · Factura: MontoTotal INCLUYE IGV; se desglosa base/IGV con la tasa de IGV de Configuración de tasas.
        · ReciboHonorarios: sin IGV. MontoTotal es el bruto del recibo; si el cliente retuvo el 8 %, ponlo en Retencion
          (cuenta como Renta ya pagada en el reporte de utilidad).
        · Remesa: transferencia del exterior, sin comprobante peruano.
        · SinComprobante: cobro local sin comprobante.
    - GASTOS: una fila por gasto (Expense). Categorías: Hosting, Dominios, SuscripcionesIA, ApisPorUso, Sueldos, Otros,
      ImpuestoRenta (pagos de Renta a SUNAT: se restan como impuesto, no como gasto), Comisiones (PayPal, bancos, remesadoras).
      El IGV pagado a SUNAT NO se registra: se cobra al cliente y no es costo.
    - Montos en PEN con el tipo de cambio del día de la operación: TipoCambio si lo indicas; si no, el de ExchangeRates más
      cercano a la fecha (máx. 7 días). Si no hay ninguno, la fila da error.
    - Los comprobantes cargados con su Serie/Numero reales hacen que el correlativo automático continúe desde el mayor
      número de cada tipo y serie (así lo calcula TaxDocumentService). Factura y recibo pueden compartir serie (E001 de
      SUNAT SOL): cada tipo lleva su propio correlativo.

  Seguridad:
    - Todo o nada: si una fila tiene un error, no se carga nada y se listan los errores.
    - Se puede volver a ejecutar: cobros (por Serie-Numero, Referencia o cliente+fecha+monto) y gastos (fecha+descripción+monto)
      que ya existen se omiten.

  Cómo usarlo: completa los INSERT de @Ingresos y @Gastos (puedes dejar uno vacío borrando sus filas) y ejecuta todo.
  Fechas en formato dd/mm/aaaa.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET DATEFORMAT dmy;

DECLARE @Ingresos TABLE (
    Fila         INT IDENTITY(1,1),
    ClienteEmail NVARCHAR(256)  NOT NULL, -- email del cliente, tal como se importó
    Fecha        DATE           NOT NULL, -- fecha del cobro (o de emisión del comprobante)
    Tipo         NVARCHAR(20)   NOT NULL, -- Factura / ReciboHonorarios / Remesa / SinComprobante
    Moneda       NVARCHAR(3)    NOT NULL, -- PEN / USD / EUR
    MontoTotal   DECIMAL(12,2)  NOT NULL, -- lo cobrado; en Factura incluye IGV; en Recibo, el bruto
    TipoCambio   DECIMAL(12,6)  NULL,     -- opcional: PEN por 1 unidad de la moneda
    Serie        NVARCHAR(10)   NULL,     -- obligatoria para Factura/ReciboHonorarios (ej. F001, E001)
    Numero       INT            NULL,     -- obligatorio para Factura/ReciboHonorarios
    Retencion    DECIMAL(12,2)  NULL,     -- opcional, solo ReciboHonorarios: retención de Renta del cliente
    Producto     NVARCHAR(200)  NULL,     -- opcional: nombre del producto del catálogo que tiene el cliente
    Proyecto     NVARCHAR(200)  NULL,     -- opcional: para desambiguar si el cliente tiene ese producto en varios proyectos
    Referencia   NVARCHAR(60)   NULL,     -- opcional: N° de operación bancaria
    Notas        NVARCHAR(400)  NULL      -- opcional: concepto (se muestra en Facturación si no hay producto)
);

DECLARE @Gastos TABLE (
    Fila         INT IDENTITY(1,1),
    Fecha        DATE           NOT NULL,
    Descripcion  NVARCHAR(400)  NOT NULL,
    Categoria    NVARCHAR(20)   NOT NULL, -- ver lista arriba
    Tipo         NVARCHAR(10)   NOT NULL, -- Fijo / Variable
    Moneda       NVARCHAR(3)    NOT NULL,
    Monto        DECIMAL(12,2)  NOT NULL,
    TipoCambio   DECIMAL(12,6)  NULL
);

-- ===================== COMPLETA AQUÍ =====================
-- Descomenta los INSERT y reemplaza las filas de ejemplo por las tuyas (una fila por cobro / por gasto).
INSERT INTO @Ingresos (ClienteEmail, Fecha, Tipo, Moneda, MontoTotal, TipoCambio, Serie, Numero, Retencion, Producto, Proyecto, Referencia, Notas) VALUES
 (N'eua@rtres.net', '30/01/2026', N'Factura', N'USD', 235.41, 3.345, N'E001', 382, NULL, N'Desarrollo personalizado', NULL, NULL, N'NUEVA WEB INNOVA DOCTORS'),
 (N'eua@rtres.net', '30/01/2026', N'Factura', N'USD', 118.00, 3.345, N'E001', 381, NULL, N'Soporte Uni Empresa', NULL, NULL, NULL),
 (N'industrial@rtres.net', '13/01/2026', N'Factura', N'USD', 734.36, 3.368, N'E001', 380, NULL, N'Hosting Wordpress Pro', NULL, NULL, N'HOSTING ANUAL; CERTIFICADO SSL SOLDIMIX; CERTIFICADO SSL TRIZ'),
 (N'bajaj@rtres.net', '13/01/2026', N'Factura', N'USD', 354.00, 3.368, N'E001', 378, NULL, N'Hosting Mensual', NULL, NULL, N'HOSTING 6 MESES (DMS)'),
 (N'pyramis@rtres.net', '10/03/2026', N'Factura', N'USD', 1091.50, 3.493, N'E001', 385, NULL, N'Desarrollo personalizado', NULL, NULL, N'VALIDACION DE USUARIOS (DNI, RUC, CUENTAS BANCARIAS)'),
 (N'pyramis@rtres.net', '10/03/2026', N'Factura', N'USD', 106.20, 3.493, N'E001', 384, NULL, N'API validacion DNI y RUC', NULL, NULL, N'API VERIFICACION CUENTA (PLAN MENSUAL); API VERIFICACION DNI Y RUC (PLAN MENSUAL)'),
 (N'bajaj@rtres.net', '03/03/2026', N'Factura', N'USD', 560.50, 3.368, N'E001', 383, NULL, N'Desarrollo personalizado', NULL, NULL, N'SERVICIO DE MEJORAS DEL DMS'),
 (N'eua@rtres.net', '28/04/2026', N'Factura', N'USD', 734.50, 3.510, N'E001', 389, NULL, N'Paquete Hosting + Dominio + SSL', NULL, NULL, NULL),
 (N'pyramis@rtres.net', '28/04/2026', N'Factura', N'USD', 106.20, 3.510, N'E001', 388, NULL, N'API validacion DNI y RUC', NULL, NULL, N'API VERIFICACION CUENTA (PLAN MENSUAL); API VERIFICACION DNI Y RUC (PLAN MENSUAL)'),
 (N'atiq@rtres.net', '20/04/2026', N'Factura', N'USD', 179.30, 3.442, N'E001', 387, NULL, N'Paquete Hosting + Dominio + SSL', NULL, NULL, N'HOSTING ATIQ; DOMINIO ATIQ CONSULTORIA; DOMINIO ATIQ EDUCACION'),
 (N'pasa@rtres.net', '11/04/2026', N'Factura', N'USD', 330.40, 3.385, N'E001', 386, NULL, N'Paquete Hosting + Dominio + SSL', NULL, NULL, N'HOSTING ANUAL WP; SOPORTE MENSUAL WP'),
 (N'kawasaki@rtres.net', '14/05/2026', N'Factura', N'USD', 330.57, 3.426, N'E001', 393, NULL, N'SSL Wilcard', NULL, NULL, N'CERTIF. DIGITAL SSL WILDCARD-PLAN ANUAL'),
 (N'pasa@rtres.net', '13/05/2026', N'Factura', N'USD', 118.00, 3.434, N'E001', 392, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE / RESPALDO / OPTIMIZACION MENSUAL DE WEB'),
 (N'eua@rtres.net', '30/06/2026', N'Factura', N'USD', 177.00, 3.415, N'E001', 399, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE DE SISTEMAS MENSUAL; ATENCION DE REQUERIMIENTOS JUNIO 26'),
 (N'pyramis@rtres.net', '30/06/2026', N'Factura', N'USD', 106.20, 3.415, N'E001', 398, NULL, N'API validacion DNI y RUC', NULL, NULL, N'VALIDACION DE DOCUMENTOS Y CUENTAS BANCARIAS APIS'),
 (N'pasa@rtres.net', '11/06/2026', N'Factura', N'USD', 118.00, 3.402, N'E001', 397, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE / RESPALDO / OPTIMIZACION MENSUAL DE WEB'),
 (N'alas@rtres.net', '09/06/2026', N'Factura', N'USD', 1916.38, 3.498, N'E001', 396, NULL, N'Desarrollo personalizado', NULL, NULL, N'WEB Y SISTEMA CMS ALAS 2026 - 30%'),
 (N'dertec@rtres.net', '08/06/2026', N'Factura', N'PEN', 7080.00, 1.000, N'E001', 395, NULL, N'Desarrollo personalizado', NULL, NULL, N'3 SEMANAS DE FORMACION. 1 SEMANA DE ACOMPAÑAMIENTO TÉCNICO EN DERTEC'),
 (N'pyramis@rtres.net', '01/06/2026', N'Factura', N'USD', 106.20, 3.417, N'E001', 394, NULL, N'API validacion DNI y RUC', NULL, NULL, N'SERVICIOS DE VALIDACION DE DOCUMENTOS Y CUENTAS BANCARIAS'),
 (N'eua@rtres.net', '23/07/2026', N'Factura', N'USD', 118.00, 3.404, N'E001', 408, NULL, N'Soporte Uni Empresa', NULL, NULL, N'MANTENIMIENTO MENSUAL Y RESPALDO DE BASE DE DATOS'),
 (N'tsa@rtres.net', '22/07/2026', N'Factura', N'USD', 350.01, 3.403, N'E001', 407, NULL, N'SSL Wilcard', NULL, NULL, N'CERTIFICADO ANUAL SSL TSA; CERTIFICADO ANUAL SSL SOS24'),
 (N'alas@rtres.net', '21/07/2026', N'Factura', N'USD', 1916.38, 3.408, N'E001', 406, NULL, N'Desarrollo personalizado', NULL, NULL, N'WEB Y SISTEMA CMS ALAS 2026 - PAGO 2 - 30%'),
 (N'bajaj@rtres.net', '16/07/2026', N'Factura', N'USD', 460.20, 3.391, N'E001', 405, NULL, N'Desarrollo personalizado', NULL, NULL, N'BOLSA DE HORAS (SISTEMA DE TALLER)'),
 (N'pasa@rtres.net', '13/07/2026', N'Factura', N'USD', 118.00, 3.397, N'E001', 403, NULL, N'Soporte Uni Empresa', NULL, NULL, N'MANTENIMIENTO MENSUAL DEL SITIO WEB'),
 (N'bajaj@rtres.net', '08/07/2026', N'Factura', N'USD', 354.00, 3.409, N'E001', 402, NULL, N'Hosting Mensual', NULL, NULL, N'HOSTING 6 MESES'),
 (N'alas@rtres.net', '06/07/2026', N'Factura', N'USD', 295.00, 3.403, N'E001', 401, NULL, N'Hosting Cloud Empresa', NULL, NULL, N'NUEVO HOSTING ALAS - ANUAL'),
 (N'atiq@rtres.net', '01/07/2026', N'Factura', N'USD', 47.20, 3.415, N'E001', 400, NULL, N'Dominio .pe', NULL, NULL, N'DOMINIO GROWAPP RENOVACION ANUAL'),
 (N'pyramis@rtres.net', '31/08/2026', N'Factura', N'USD', 106.20, 3.356, N'E001', 413, NULL, N'API validacion DNI y RUC', NULL, NULL, N'API VERIFICACION CUENTA (PLAN MENSUAL); API VERIFICACION DNI Y RUC (PLAN MENSUAL)'),
 (N'eua@rtres.net', '31/08/2026', N'Factura', N'USD', 236.00, 3.356, N'E001', 412, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE DE SISTEMAS MENSUAL; ATENCION DE REQUERIMIENTOS DENTRO DEL MES'),
 (N'pasa@rtres.net', '17/08/2026', N'Factura', N'USD', 118.00, 3.368, N'E001', 411, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE/RESPALDO/OPTMIZACION MENSUAL DE WEB'),
 (N'eua@rtres.net', '04/08/2026', N'Factura', N'USD', 448.40, 3.402, N'E001', 410, NULL, N'Desarrollo personalizado', NULL, NULL, N'MODIFICACIONES SISTEMA DE VENTAS 50%'),
 (N'pyramis@rtres.net', '03/08/2026', N'Factura', N'USD', 106.20, 3.400, N'E001', 409, NULL, N'API validacion DNI y RUC', NULL, NULL, N'VALIDACION DE DOCUMENTOS Y CUENTAS BANCARIAS APIS'),
 (N'alas@rtres.net', '22/09/2026', N'Factura', N'USD', 2555.17, 3.362, N'E001', 416, NULL, N'Desarrollo personalizado', NULL, NULL, N'WEB Y SISTEMA CMS ALAS 2026 - PAGO 3 - 40%'),
 (N'pasa@rtres.net', '14/09/2026', N'Factura', N'USD', 118.00, 3.371, N'E001', 415, NULL, N'Soporte Uni Empresa', NULL, NULL, N'SOPORTE/RESPALDO/OPTMIZACION MENSUAL DE WEB'),
 (N'eua@rtres.net', '07/09/2026', N'Factura', N'USD', 448.40, 3.369, N'E001', 414, NULL, N'Desarrollo personalizado', NULL, NULL, N'MODIFICACIONES SISTEMA DE VENTAS. (PAGO SALDO)'),
 (N'tsa@rtres.net', '15/01/2026', N'ReciboHonorarios', N'USD', 170.00, 3.367, N'E001', 174, 0.00, N'SSL WILCARD', NULL, NULL, NULL),
 (N'sos24@rtres.net', '05/02/2026', N'ReciboHonorarios', N'USD', 170.00, 3.364, N'E001', 175, 0.00, N'SSL WILCARD', NULL, NULL, N'Anulada'),
 (N'tsa@rtres.net', '06/02/2026', N'ReciboHonorarios', N'USD', 170.00, 3.368, N'E001', 176, 0.00, N'SSL WILCARD', NULL, NULL, NULL),
 (N'eua@rtres.net', '27/02/2026', N'ReciboHonorarios', N'USD', 100.00, 3.360, N'E001', 177, 0.00, N'Soporte Uni Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '27/02/2026', N'ReciboHonorarios', N'USD', 150.00, 3.360, N'E001', 178, 0.00, N'ATENCION DE REQUERIMIENTOS', NULL, NULL, NULL),
 (N'tsa@rtres.net', '11/03/2026', N'ReciboHonorarios', N'USD', 170.00, 3.451, N'E001', 179, 0.00, N'Soporte Multi Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '30/03/2026', N'ReciboHonorarios', N'USD', 100.00, 3.486, N'E001', 180, 0.00, N'Soporte Uni Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '30/03/2026', N'ReciboHonorarios', N'USD', 75.00, 3.486, N'E001', 181, 0.00, N'ATENCION DE REQUERIMIENTOS', NULL, NULL, NULL),
 (N'tsa@rtres.net', '15/04/2026', N'ReciboHonorarios', N'USD', 170.00, 3.390, N'E001', 182, 0.00, N'Soporte Multi Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '28/04/2026', N'ReciboHonorarios', N'USD', 200.00, 3.510, N'E001', 183, 0.00, N'ATENCION DE REQUERIMIENTOS', NULL, NULL, NULL),
 (N'tsa@rtres.net', '15/05/2026', N'ReciboHonorarios', N'USD', 170.00, 3.419, N'E001', 184, 0.00, N'Soporte Multi Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '01/06/2026', N'ReciboHonorarios', N'USD', 100.00, 3.417, N'E001', 185, 0.00, N'Soporte Uni Empresa', NULL, NULL, NULL),
 (N'eua@rtres.net', '01/06/2026', N'ReciboHonorarios', N'USD', 50.00, 3.417, N'E001', 186, 0.00, N'ATENCION DE REQUERIMIENTOS', NULL, NULL, NULL),
 (N'tsa@rtres.net', '15/06/2026', N'ReciboHonorarios', N'USD', 170.00, 3.389, N'E001', 187, 13.60, N'Soporte Multi Empresa', NULL, NULL, NULL),
 (N'tsa@rtres.net', '17/08/2026', N'ReciboHonorarios', N'USD', 170.00, 3.368, N'E001', 188, 0.00, N'Soporte Multi Empresa', NULL, NULL, NULL),
 (N'tsa@rtres.net', '14/09/2026', N'ReciboHonorarios', N'USD', 170.00, 3.371, N'E001', 189, 0.00, N'Soporte Multi Empresa', NULL, NULL, NULL);

INSERT INTO @Gastos (Fecha, Descripcion, Categoria, Tipo, Moneda, Monto, TipoCambio) VALUES
 ('04/02/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/03/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/04/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/05/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/06/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/07/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/08/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('04/09/2026', N'ValidaCuenta', N'ApisPorUso', N'Fijo', N'USD', 50.00, 3.360),
 ('03/03/2026', N'ValidaDNI', N'ApisPorUso', N'Fijo', N'PEN', 250.00, 3.360),
 ('07/01/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.360),
 ('13/01/2026', N'Dominio skilia.pe', N'Dominios', N'Fijo', N'PEN', 120.00, 1.000),
 ('13/01/2026', N'Prestamo Casa', N'Otros', N'Variable', N'PEN', 1820.00, 1.000),
 ('23/01/2026', N'Dominio ristorantemadeinperu.it', N'Dominios', N'Fijo', N'USD', 12.20, 4.010),
 ('23/01/2026', N'Prestamo SUNAT', N'Otros', N'Variable', N'PEN', 490.77, 1.000),
 ('07/02/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.370),
 ('18/02/2026', N'gestionaminegocio.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.370),
 ('18/02/2026', N'Prestamo Casa', N'Otros', N'Variable', N'PEN', 1820.00, 1.000),
 ('18/02/2026', N'Prestamo SUNAT', N'Otros', N'Variable', N'PEN', 490.55, 1.000),
 ('07/03/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.380),
 ('15/03/2026', N'Dominio soluzionipersitiweb.it', N'Dominios', N'Fijo', N'USD', 12.20, 4.000),
 ('15/03/2026', N'Prestamo Casa', N'Otros', N'Variable', N'PEN', 1820.00, 1.000),
 ('15/03/2026', N'Contadora', N'Otros', N'Variable', N'PEN', 175.00, 1.000),
 ('19/03/2026', N'joshuastailor.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.450),
 ('19/03/2026', N'Prestamo SUNAT', N'Otros', N'Variable', N'PEN', 490.00, 1.000),
 ('10/04/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 18.85, 3.740),
 ('16/04/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.740),
 ('07/04/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.370),
 ('02/04/2026', N'hosting webempresa', N'Hosting', N'Fijo', N'USD', 285.00, 3.390),
 ('02/04/2026', N'Prestamo Casa', N'Otros', N'Variable', N'PEN', 1820.00, 1.000),
 ('20/04/2026', N'atiqconsultoria.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.490),
 ('26/04/2026', N'Prestamo SUNAT', N'Otros', N'Variable', N'PEN', 496.94, 1.000),
 ('26/04/2026', N'atiqeducacion.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.490),
 ('26/04/2026', N'Contadora', N'Otros', N'Variable', N'PEN', 175.00, 1.000),
 ('16/05/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.760),
 ('23/05/2026', N'gabrieljuarezart.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.420),
 ('30/05/2026', N'Deuda Leslie Soles', N'Otros', N'Variable', N'PEN', 400.00, 1.000),
 ('07/05/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.360),
 ('24/05/2026', N'Dominio Embarcate', N'Dominios', N'Fijo', N'USD', 21.99, 3.970),
 ('30/05/2026', N'Deuda Leslie Dolares', N'Otros', N'Variable', N'USD', 100.00, 3.470),
 ('30/05/2026', N'Fracc SUNAT', N'Otros', N'Variable', N'PEN', 662.00, 1.000),
 ('30/05/2026', N'PDT', N'Otros', N'Variable', N'PEN', 1637.00, 1.000),
 ('04/06/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.800),
 ('25/06/2026', N'Deuda leslie Soles', N'Otros', N'Variable', N'PEN', 400.00, 1.000),
 ('16/06/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.800),
 ('25/06/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 658.00, 1.000),
 ('07/06/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 40.87, 3.370),
 ('25/06/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 390.00, 1.000),
 ('04/07/2026', N'ChatGPT', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.850),
 ('30/07/2026', N'Deuda leslie Soles', N'Otros', N'Variable', N'PEN', 400.00, 1.000),
 ('16/07/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.850),
 ('03/07/2026', N'rtres.net', N'Dominios', N'Fijo', N'USD', 20.99, 3.470),
 ('30/07/2026', N'Deuda Leslie Dolares', N'Otros', N'Variable', N'USD', 100.00, 3.470),
 ('07/07/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.380),
 ('24/07/2026', N'Dominio growapp.pe', N'Dominios', N'Fijo', N'PEN', 120.00, 1.000),
 ('25/07/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 658.00, 1.000),
 ('04/08/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.880),
 ('30/08/2026', N'Deuda leslie Soles', N'Otros', N'Variable', N'PEN', 400.00, 1.000),
 ('16/07/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.880),
 ('18/08/2026', N'r3solucionesweb.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.470),
 ('30/08/2026', N'Deuda Leslie Dolares', N'Otros', N'Variable', N'USD', 100.00, 3.470),
 ('07/07/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.360),
 ('31/08/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000),
 ('04/09/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.900),
 ('03/09/2026', N'Deuda leslie Soles', N'Otros', N'Variable', N'USD', 370.00, 1.081),
 ('16/09/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.900),
 ('30/09/2026', N'Deuda Leslie Dolares', N'Otros', N'Variable', N'USD', 100.00, 2.260),
 ('07/09/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.350),
 ('25/09/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000),
 ('30/09/2026', N'Deuda Leslie Dolares', N'Otros', N'Variable', N'USD', 59.62, 3.470),
 ('04/10/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.900),
 ('11/10/2026', N'jonnymotorsperu.com', N'Dominios', N'Fijo', N'USD', 20.99, 3.470),
 ('30/10/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000),
 ('07/10/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.370),
 ('16/10/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.900),
 ('24/10/2026', N'Dominio casobtempus.com.pe', N'Dominios', N'Fijo', N'PEN', 120.00, 1.000),
 ('04/11/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.900),
 ('30/11/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000),
 ('07/11/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.370),
 ('16/11/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.900),
 ('28/11/2026', N'tsassistance.net', N'Dominios', N'Fijo', N'USD', 20.99, 3.470),
 ('04/12/2026', N'ChatGpt', N'SuscripcionesIA', N'Fijo', N'USD', 23.00, 3.900),
 ('12/12/2026', N'Hosting Elastika', N'Hosting', N'Fijo', N'USD', 525.00, 3.470),
 ('23/12/2026', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000),
 ('07/11/2026', N'Github Copilot', N'SuscripcionesIA', N'Fijo', N'USD', 10.00, 3.370),
 ('16/12/2026', N'Claude', N'SuscripcionesIA', N'Fijo', N'USD', 21.96, 3.900),
 ('30/01/2027', N'Frac SUNAT', N'Otros', N'Variable', N'PEN', 389.00, 1.000);



-- =========================================================

DECLARE @IgvRate DECIMAL(9,6) = ISNULL((SELECT TOP 1 IgvRate FROM TaxSettings), 0.18);

-- 1. Resolver ingresos
DECLARE @I TABLE (
    Fila INT PRIMARY KEY, ClientId UNIQUEIDENTIFIER NULL, Tipo NVARCHAR(20), Fecha DATE, Moneda NVARCHAR(3), MontoTotal DECIMAL(12,2),
    Tc DECIMAL(12,6) NULL, Serie NVARCHAR(10) NULL, Numero INT NULL, Retencion DECIMAL(12,2) NULL, ClientProductId UNIQUEIDENTIFIER NULL,
    ProductosCoinciden INT, ProductoIndicado BIT, Clave NVARCHAR(100), Notas NVARCHAR(400) NULL,
    Cliente NVARCHAR(256) NULL, Producto NVARCHAR(200) NULL, Proyecto NVARCHAR(200) NULL
);
INSERT INTO @I
SELECT i.Fila, cl.Id, LTRIM(RTRIM(i.Tipo)), i.Fecha, UPPER(LTRIM(RTRIM(i.Moneda))), i.MontoTotal,
       CASE WHEN UPPER(i.Moneda) = 'PEN' THEN 1 ELSE COALESCE(i.TipoCambio,
           (SELECT TOP 1 r.RateToPen FROM ExchangeRates r WHERE r.CurrencyCode = UPPER(i.Moneda) AND ABS(DATEDIFF(DAY, r.[Date], i.Fecha)) <= 7 ORDER BY ABS(DATEDIFF(DAY, r.[Date], i.Fecha)))) END,
       NULLIF(UPPER(LTRIM(RTRIM(i.Serie))), N''), i.Numero, NULLIF(i.Retencion, 0),
       cp.Id, ISNULL(cp.Coinciden, 0), CASE WHEN NULLIF(LTRIM(RTRIM(i.Producto)), N'') IS NULL THEN 0 ELSE 1 END,
       LEFT(CASE WHEN NULLIF(LTRIM(RTRIM(i.Serie)), N'') IS NOT NULL AND i.Numero IS NOT NULL THEN CONCAT(N'CARGA-DOC-', UPPER(LTRIM(RTRIM(i.Serie))), N'-', i.Numero)
                 WHEN NULLIF(LTRIM(RTRIM(i.Referencia)), N'') IS NOT NULL THEN CONCAT(N'CARGA-REF-', LTRIM(RTRIM(i.Referencia)))
                 ELSE CONCAT(N'CARGA-', LTRIM(RTRIM(i.ClienteEmail)), N'-', CONVERT(CHAR(8), i.Fecha, 112), N'-', i.MontoTotal) END, 100),
       NULLIF(LTRIM(RTRIM(i.Notas)), N''),
       cl.CompanyName, NULLIF(LTRIM(RTRIM(i.Producto)), N''), NULLIF(LTRIM(RTRIM(i.Proyecto)), N'')
FROM @Ingresos i
LEFT JOIN Clients cl ON cl.Email = LTRIM(RTRIM(i.ClienteEmail))
OUTER APPLY (
    SELECT TOP 1 x.Id, COUNT(*) OVER () AS Coinciden
    FROM ClientProducts x JOIN Products p ON p.Id = x.ProductId JOIN Projects pr ON pr.Id = x.ProjectId
    WHERE x.ClientId = cl.Id AND p.Name = LTRIM(RTRIM(i.Producto))
      AND (NULLIF(LTRIM(RTRIM(i.Proyecto)), N'') IS NULL OR pr.Name = LTRIM(RTRIM(i.Proyecto)))
) cp;

-- 2. Resolver gastos
DECLARE @G TABLE (Fila INT PRIMARY KEY, Fecha DATE, Descripcion NVARCHAR(400), Categoria INT NULL, Tipo INT NULL, Moneda NVARCHAR(3), Monto DECIMAL(12,2), Tc DECIMAL(12,6) NULL);
INSERT INTO @G
SELECT g.Fila, g.Fecha, LTRIM(RTRIM(g.Descripcion)),
       CASE LTRIM(RTRIM(g.Categoria)) WHEN N'Hosting' THEN 0 WHEN N'Dominios' THEN 1 WHEN N'SuscripcionesIA' THEN 2 WHEN N'ApisPorUso' THEN 3
            WHEN N'Sueldos' THEN 4 WHEN N'Otros' THEN 5 WHEN N'ImpuestoRenta' THEN 6 WHEN N'Comisiones' THEN 7 END,
       CASE LTRIM(RTRIM(g.Tipo)) WHEN N'Fijo' THEN 0 WHEN N'Variable' THEN 1 END,
       UPPER(LTRIM(RTRIM(g.Moneda))), g.Monto,
       CASE WHEN UPPER(g.Moneda) = 'PEN' THEN 1 ELSE COALESCE(g.TipoCambio,
           (SELECT TOP 1 r.RateToPen FROM ExchangeRates r WHERE r.CurrencyCode = UPPER(g.Moneda) AND ABS(DATEDIFF(DAY, r.[Date], g.Fecha)) <= 7 ORDER BY ABS(DATEDIFF(DAY, r.[Date], g.Fecha)))) END
FROM @Gastos g;

-- 3. Validar: si hay errores no se carga nada
DECLARE @Errores TABLE (Bloque NVARCHAR(10), Fila INT, Error NVARCHAR(400));
INSERT INTO @Errores
SELECT N'Ingresos', r.Fila, e.Error
FROM @I r
CROSS APPLY (VALUES
    (CASE WHEN r.ClientId IS NULL THEN N'Cliente no encontrado (revisa el email).' END),
    (CASE WHEN r.Tipo NOT IN (N'Factura', N'ReciboHonorarios', N'Remesa', N'SinComprobante') THEN N'Tipo inválido: usa Factura, ReciboHonorarios, Remesa o SinComprobante.' END),
    (CASE WHEN r.Moneda NOT IN (N'PEN', N'USD', N'EUR') THEN N'Moneda inválida: usa PEN, USD o EUR.' END),
    (CASE WHEN r.MontoTotal <= 0 THEN N'MontoTotal debe ser mayor a 0.' END),
    (CASE WHEN r.Tc IS NULL AND r.Moneda IN (N'USD', N'EUR') THEN N'Sin tipo de cambio: indica TipoCambio (no hay uno a 7 días o menos en ExchangeRates).' END),
    (CASE WHEN r.Tipo IN (N'Factura', N'ReciboHonorarios') AND (r.Serie IS NULL OR r.Numero IS NULL) THEN N'Factura y ReciboHonorarios necesitan Serie y Numero.' END),
    (CASE WHEN r.Tipo NOT IN (N'Factura', N'ReciboHonorarios') AND (r.Serie IS NOT NULL OR r.Numero IS NOT NULL) THEN N'Serie/Numero solo aplican a Factura o ReciboHonorarios.' END),
    (CASE WHEN r.Retencion IS NOT NULL AND r.Tipo <> N'ReciboHonorarios' THEN N'La retención solo aplica a ReciboHonorarios.' END),
    (CASE WHEN r.Retencion < 0 OR r.Retencion > r.MontoTotal THEN N'La retención debe estar entre 0 y el MontoTotal.' END),
    (CASE WHEN r.ProductoIndicado = 1 AND r.ClientProductId IS NULL AND r.ClientId IS NOT NULL THEN LEFT(CONCAT(N'El cliente ', r.Cliente, N' no tiene el producto "', r.Producto, N'"', CASE WHEN r.Proyecto IS NOT NULL THEN CONCAT(N' en el proyecto "', r.Proyecto, N'"') END, N' (revisa Producto/Proyecto).'), 400) END),
    (CASE WHEN r.ProductosCoinciden > 1 THEN N'El cliente tiene ese producto en varios proyectos: indica Proyecto.' END),
    (CASE WHEN (SELECT COUNT(*) FROM @I o WHERE o.Clave = r.Clave) > 1 THEN N'Fila repetida en la carga (misma Serie-Numero, Referencia o cliente+fecha+monto).' END),
    (CASE WHEN r.Serie IS NOT NULL AND EXISTS (SELECT 1 FROM TaxDocuments d WHERE d.Type = CASE r.Tipo WHEN N'Factura' THEN 0 ELSE 1 END AND d.Series = r.Serie AND d.Number = r.Numero)
               AND NOT EXISTS (SELECT 1 FROM PaymentTransactions p WHERE p.PayPalOrderIdOrSubscriptionId = r.Clave)
          THEN N'Ya existe un comprobante con esa Serie-Numero que no vino de esta carga.' END)
) e(Error)
WHERE e.Error IS NOT NULL
UNION ALL
SELECT N'Gastos', g.Fila, e.Error
FROM @G g
CROSS APPLY (VALUES
    (CASE WHEN g.Descripcion = N'' THEN N'Falta la descripción.' END),
    (CASE WHEN g.Categoria IS NULL THEN N'Categoría inválida: Hosting, Dominios, SuscripcionesIA, ApisPorUso, Sueldos, Otros, ImpuestoRenta o Comisiones.' END),
    (CASE WHEN g.Tipo IS NULL THEN N'Tipo inválido: usa Fijo o Variable.' END),
    (CASE WHEN g.Moneda NOT IN (N'PEN', N'USD', N'EUR') THEN N'Moneda inválida: usa PEN, USD o EUR.' END),
    (CASE WHEN g.Monto <= 0 THEN N'Monto debe ser mayor a 0.' END),
    (CASE WHEN g.Tc IS NULL AND g.Moneda IN (N'USD', N'EUR') THEN N'Sin tipo de cambio: indica TipoCambio (no hay uno a 7 días o menos en ExchangeRates).' END)
) e(Error)
WHERE e.Error IS NOT NULL;

IF EXISTS (SELECT 1 FROM @Errores)
BEGIN
    SELECT e.Bloque, e.Fila, e.Error FROM @Errores e ORDER BY e.Bloque DESC, e.Fila;
    RAISERROR(N'Carga cancelada: corrige las filas listadas. No se insertó nada.', 16, 1);
    RETURN;
END

BEGIN TRAN;

-- 4. Cobros (los que ya existen por su clave se omiten)
DECLARE @Nuevos TABLE (Fila INT, PaymentId UNIQUEIDENTIFIER);
INSERT INTO @Nuevos (Fila, PaymentId)
SELECT r.Fila, NEWID() FROM @I r
WHERE NOT EXISTS (SELECT 1 FROM PaymentTransactions p WHERE p.PayPalOrderIdOrSubscriptionId = r.Clave);

INSERT INTO PaymentTransactions (Id, ClientId, ClientProductId, PayPalOrderIdOrSubscriptionId, Amount, Currency, Status, Method, Years, AmountPen, InternalCode, CreatedAt, Notes)
SELECT n.PaymentId, r.ClientId, r.ClientProductId, r.Clave, r.MontoTotal, r.Moneda, 'COMPLETED',
       CASE WHEN r.Tipo = N'Remesa' THEN 'Remesa' ELSE 'Transferencia' END, 1,
       ROUND(r.MontoTotal * r.Tc, 2), NULL,
       DATEADD(HOUR, 12, CAST(r.Fecha AS DATETIME2)),  -- 12:00 UTC: cae en el mismo día en Perú
       r.Notas
FROM @Nuevos n JOIN @I r ON r.Fila = n.Fila;
DECLARE @CobrosCreados INT = @@ROWCOUNT;

-- 5. Comprobantes de los cobros nuevos (Type: 0 = Factura, 1 = Recibo por honorarios)
INSERT INTO TaxDocuments (Id, PaymentTransactionId, ClientId, Type, Series, Number, IssueDate, Currency, BaseAmount, IgvAmount, TotalAmount, Notes, RetentionAmount)
SELECT NEWID(), n.PaymentId, r.ClientId, CASE r.Tipo WHEN N'Factura' THEN 0 ELSE 1 END, r.Serie, r.Numero, r.Fecha, r.Moneda,
       b.Base, r.MontoTotal - b.Base, r.MontoTotal, CONCAT(N'Carga inicial', N' · ' + r.Notas), r.Retencion
FROM @Nuevos n JOIN @I r ON r.Fila = n.Fila
CROSS APPLY (SELECT CASE WHEN r.Tipo = N'Factura' THEN ROUND(r.MontoTotal / (1 + @IgvRate), 2) ELSE r.MontoTotal END AS Base) b
WHERE r.Tipo IN (N'Factura', N'ReciboHonorarios');
DECLARE @ComprobantesCreados INT = @@ROWCOUNT;

-- 6. Gastos (los que ya existen con misma fecha, descripción, monto y moneda se omiten)
INSERT INTO Expenses (Id, Description, Category, Type, Amount, Currency, AmountPen, Date, Recurring, RecurrenceCycle)
SELECT NEWID(), g.Descripcion, g.Categoria, g.Tipo, g.Monto, g.Moneda, ROUND(g.Monto * g.Tc, 2), g.Fecha, 0, NULL
FROM @G g
WHERE NOT EXISTS (SELECT 1 FROM Expenses x WHERE x.[Date] = g.Fecha AND x.Description = g.Descripcion AND x.Amount = g.Monto AND x.Currency = g.Moneda);
DECLARE @GastosCreados INT = @@ROWCOUNT;

COMMIT;

-- 7. Resumen
SELECT (SELECT COUNT(*) FROM @I) AS IngresosEnCarga, @CobrosCreados AS CobrosCreados, @ComprobantesCreados AS ComprobantesCreados,
       (SELECT COUNT(*) FROM @I) - @CobrosCreados AS CobrosOmitidosPorYaExistir,
       (SELECT COUNT(*) FROM @G) AS GastosEnCarga, @GastosCreados AS GastosCreados, (SELECT COUNT(*) FROM @G) - @GastosCreados AS GastosOmitidosPorYaExistir;

SELECT YEAR(p.CreatedAt) AS Anio, MONTH(p.CreatedAt) AS Mes, COUNT(*) AS Cobros, SUM(p.AmountPen) AS CobradoPen
FROM PaymentTransactions p GROUP BY YEAR(p.CreatedAt), MONTH(p.CreatedAt) ORDER BY Anio, Mes;
