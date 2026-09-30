/*
  Carga inicial de suscripciones (productos de clientes) ya facturadas y pagadas.

  Requisitos previos:
    1. Clientes y productos ya importados desde el portal (plantillas Excel).
    2. Migraciones aplicadas (arrancar el API una vez).

  Qué hace:
    - Crea el proyecto del cliente si no existe (por nombre).
    - Crea cada producto del cliente como pagado por transferencia (IsManualBilling = 1), con su fecha de
      vencimiento (Anual/Único) o de próximo cobro (Mensual). El estado se calcula igual que el API:
      Vencido si la fecha ya pasó, Por vencer si faltan 30 días o menos, Activo en otro caso.
    - Si PrecioFinal es menor que el precio del catálogo, lo registra como descuento del periodo actual
      (la renovación se cobra a precio de catálogo).
    - Precios SIN IGV, igual que el catálogo: a los clientes en Perú con Factura el sistema suma el IGV al cobrar.
      Ej.: si un cliente peruano paga hoy 118 con IGV incluido, PrecioFinal = 100.00.
    - NO crea pagos ni comprobantes: el periodo actual ya se facturó fuera del sistema.

  Seguridad:
    - Todo o nada: si una fila tiene un error (cliente o producto inexistente, fecha faltante...), no se
      carga ninguna y se listan los errores.
    - Se puede volver a ejecutar: las filas que ya existen (mismo cliente, proyecto, producto y dominio) se omiten.

  Cómo usarlo: completa el INSERT de @Carga (una fila por producto) y ejecuta todo el script.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET DATEFORMAT dmy;

DECLARE @Carga TABLE (
    Fila          INT IDENTITY(1,1),
    ClienteEmail  NVARCHAR(256)  NOT NULL, -- email del cliente, tal como se importó
    Proyecto      NVARCHAR(200)  NOT NULL, -- se crea si el cliente no tiene un proyecto con ese nombre
    Producto      NVARCHAR(200)  NOT NULL, -- nombre exacto del producto en el catálogo
    Ciclo         NVARCHAR(10)   NULL,     -- Unico / Mensual / Bimestral / Trimestral / Semestral / Anual (vacío = el del producto)
    Fecha         DATE           NULL,     -- Anual/Único: vence el · Mensual: próximo cobro (obligatoria salvo Único)
    Dominio       NVARCHAR(200)  NULL,     -- opcional (dominios, hosting…)
    PrecioFinal   DECIMAL(12,2)  NULL      -- opcional, SIN IGV: lo que paga hoy el cliente si es menor al catálogo
);

-- ===================== COMPLETA AQUÍ =====================
INSERT INTO @Carga (ClienteEmail, Proyecto, Producto, Ciclo, Fecha, Dominio, PrecioFinal) VALUES
(N'casob@rtres.net', N'Hosting Casob', N'Hosting Cloud Medium', N'Anual', '24/10/2026', N'casobtempus.com.pe', 110),
(N'casob@rtres.net', N'Dominio Casob', N'Dominio .pe', N'Anual', '24/10/2026', N'casobtempus.com.pe', 40),
(N'casob@rtres.net', N'SSL Casob', N'SSL Estandar', N'Anual', '24/10/2025', N'casobtempus.com.pe', 90), -- 3 años pagados: vence al final del último
(N'kawasaki@rtres.net', N'SSL WILCARD Taller', N'SSL WILCARD', N'Anual', '03/05/2026', N'tiendacrosland.pe', 231),
(N'kawasaki@rtres.net', N'Hosting Sistema Taller', N'Hosting Cloud Empresa', N'Anual', '05/12/2025', N'tiendacrosland.pe', 594.96),
(N'embarcate@rtres.net', N'Hosting Embarcate', N'Hosting Cloud Medium', N'Anual', '15/04/2026', N'embarcateseguro.com', 70),
(N'embarcate@rtres.net', N'Dominio Embarcate', N'Dominio .pe', N'Anual', '15/04/2026', N'embarcateseguro.com', 40),
(N'embarcate@rtres.net', N'SSL Embarcate', N'SSL Estandar', N'Anual', '15/04/2026', N'embarcateseguro.com', 70),
(N'eua@rtres.net', N'Hosting EUA', N'Hosting Cloud Empresa', N'Anual', '07/05/2026', N'euroamericanassistance.com', 512.46),
(N'eua@rtres.net', N'SSL EUA', N'SSL WILCARD', N'Anual', '07/05/2026', N'euroamericanassistance.com', 110),
(N'eua@rtres.net', N'Soporte Mensual', N'Soporte Uni Empresa', N'Anual', '01/10/2026', N'euroamericanassistance.com', 100),
(N'atiq@rtres.net', N'Hosting Atiq', N'Hosting Cloud Medium', N'Anual', '20/04/2026', N'atiqconsultoria.com', 85),
(N'atiq@rtres.net', N'Dominio Atiq Consultoria', N'Dominio .com', N'Anual', '20/04/2026', N'atiqconsultoria.com', 25),
(N'atiq@rtres.net', N'Dominio Atiq Educacion', N'Dominio .com', N'Anual', '20/04/2026', N'atiqconsultoria.com', 25),
(N'atiq@rtres.net', N'Dominio growapp', N'Dominio .pe', N'Anual', '20/07/2026', N'growapp.pe', 40),
(N'industrial@rtres.net', N'Hosting Industrial', N'Hosting Wordpress Pro', N'Anual', '07/01/2026', N'triz.pe', 622.34),
(N'jonny@rtres.net', N'Hosting JonnyMotors', N'Hosting Cloud Medium', N'Anual', '11/10/2025', N'jonnymotorsperu.com', 100),
(N'jonny@rtres.net', N'Dominio JonnyMotors', N'Dominio .com', N'Anual', '11/10/2025', N'jonnymotorsperu.com', 20),
(N'joshua@rtres.net', N'Hosting Joshua', N'Hosting Cloud Medium', N'Anual', '03/03/2026', N'joshuastailor.com', 110),
(N'joshua@rtres.net', N'SSL Joshua', N'SSL Estandar', N'Anual', '03/03/2026', N'joshuastailor.com', 90),
(N'pasa@rtres.net', N'Hosting Pasa', N'Hosting Wordpress Medium', N'Anual', '13/04/2026', N'pasasurf.org', 180),
(N'pasa@rtres.net', N'Soporte Mensual', N'Soporte Uni Empresa', N'Anual', '13/04/2026', N'pasasurf.org', 100),
(N'pyramis@rtres.net', N'Hosting Pyramis', N'Hosting Cloud Pro', N'Anual', '12/12/2025', N'pyramis.pe', 156),
(N'pyramis@rtres.net', N'API validacion DNI y RUC', N'API validacion DNI y RUC', N'Mensual', '04/09/2026', N'pyramis.pe', 40),
(N'pyramis@rtres.net', N'API validacion Cuentas Bancarias', N'API validacion Cuentas Bancarias', N'Mensual', '04/09/2026', N'pyramis.pe', 50),
(N'madeinperu@rtres.net', N'Hosting madeinperu', N'Hosting Zona EUR', N'Anual', '23/01/2026', N'ristorantemadeinperu.it', 100.68),
(N'madeinperu@rtres.net', N'Dominio madeinperu', N'Dominio .it', N'Anual', '23/01/2026', N'ristorantemadeinperu.it', 7.32),
(N'sos24@rtres.net', N'SSL SOS24', N'SSL WILCARD', N'Anual', '02/08/2026', N'sos24.com.co', 148.31),
(N'gabriel@rtres.net', N'Hosting Gabriel', N'Hosting Cloud Medium', N'Anual', '23/05/2026', N'gabrieljuarezart.com', 60),
(N'gabriel@rtres.net', N'Dominio Gabriel', N'Dominio .com', N'Anual', '23/05/2026', N'gabrieljuarezart.com', 20),
(N'tsa@rtres.net', N'Hosting TSA y SOS24', N'Hosting Cloud Medium', N'Anual', '28/11/2025', N'tsa.pe', 85),
(N'tsa@rtres.net', N'SSL TSA', N'SSL WILCARD', N'Anual', '02/08/2026', N'tsa.pe', 148.31),
(N'universal@rtres.net', N'Hosting UMED', N'Hosting Cloud Pro', N'Anual', '30/10/2026', N'', 150),
(N'bajaj@rtres.net', N'Hosting Bajaj', N'Hosting Mensual', N'Mensual', '15/12/2026', N'postventabajajperu.com.pe', 50); -- 6 meses pagados: próximo cobro tras el último

-- =========================================================

-- 1. Resolver cliente, producto y ciclo
DECLARE @Resuelto TABLE (
    Fila INT PRIMARY KEY, ClientId UNIQUEIDENTIFIER NULL, ProductId UNIQUEIDENTIFIER NULL, ProductosConEseNombre INT,
    BasePrice DECIMAL(12,2) NULL, Ciclo INT NULL, Proyecto NVARCHAR(200), Fecha DATE NULL, Dominio NVARCHAR(200) NULL, PrecioFinal DECIMAL(12,2) NULL
);
INSERT INTO @Resuelto
SELECT c.Fila,
       cl.Id,
       p.Id,
       (SELECT COUNT(*) FROM Products x WHERE x.Name = LTRIM(RTRIM(c.Producto))),
       p.BasePrice,
       CASE LTRIM(RTRIM(ISNULL(c.Ciclo, N''))) WHEN N'' THEN p.BillingCycle WHEN N'Unico' THEN 0 WHEN N'Único' THEN 0 WHEN N'Mensual' THEN 1 WHEN N'Anual' THEN 2 WHEN N'Bimestral' THEN 3 WHEN N'Trimestral' THEN 4 WHEN N'Semestral' THEN 5 END,
       LTRIM(RTRIM(c.Proyecto)), c.Fecha, NULLIF(LTRIM(RTRIM(c.Dominio)), N''), c.PrecioFinal
FROM @Carga c
LEFT JOIN Clients cl ON cl.Email = LTRIM(RTRIM(c.ClienteEmail))
OUTER APPLY (SELECT TOP 1 * FROM Products x WHERE x.Name = LTRIM(RTRIM(c.Producto))) p;

-- 2. Validar: si hay errores no se carga nada
DECLARE @Errores TABLE (Fila INT, Error NVARCHAR(400));
INSERT INTO @Errores
SELECT r.Fila, e.Error
FROM @Resuelto r
CROSS APPLY (VALUES
    (CASE WHEN r.ClientId IS NULL THEN N'Cliente no encontrado (revisa el email).' END),
    (CASE WHEN r.ProductId IS NULL THEN N'Producto no encontrado (revisa el nombre exacto del catálogo).' END),
    (CASE WHEN r.ProductosConEseNombre > 1 THEN N'Hay varios productos con ese nombre: renómbralos para que sean únicos.' END),
    (CASE WHEN r.ProductId IS NOT NULL AND r.Ciclo IS NULL THEN N'Ciclo inválido: usa Unico, Mensual, Bimestral, Trimestral, Semestral o Anual.' END),
    (CASE WHEN r.Ciclo IN (1, 2) AND r.Fecha IS NULL THEN N'Falta la fecha (vencimiento o próximo cobro).' END),
    (CASE WHEN r.Proyecto = N'' THEN N'Falta el proyecto.' END),
    (CASE WHEN r.PrecioFinal < 0 THEN N'PrecioFinal no puede ser negativo.' END),
    (CASE WHEN r.BasePrice IS NULL AND r.ProductId IS NOT NULL AND r.PrecioFinal IS NULL THEN N'El producto no tiene precio de catálogo: indica PrecioFinal.' END),
    (CASE WHEN r.PrecioFinal > r.BasePrice THEN N'PrecioFinal es mayor al precio del catálogo: sube el precio del producto o deja PrecioFinal vacío.' END)
) e(Error)
WHERE e.Error IS NOT NULL;

IF EXISTS (SELECT 1 FROM @Errores)
BEGIN
    SELECT e.Fila, c.ClienteEmail, c.Producto, e.Error FROM @Errores e JOIN @Carga c ON c.Fila = e.Fila ORDER BY e.Fila;
    RAISERROR(N'Carga cancelada: corrige las filas listadas. No se insertó nada.', 16, 1);
    RETURN;
END

BEGIN TRAN;

-- 3. Proyectos que faltan (slug: minúsculas, sin tildes, guiones; si ya existe se le agrega parte del id del cliente)
DECLARE @NuevosProyectos TABLE (ClientId UNIQUEIDENTIFIER, Nombre NVARCHAR(200), Slug NVARCHAR(450));
INSERT INTO @NuevosProyectos (ClientId, Nombre, Slug)
SELECT DISTINCT r.ClientId, r.Proyecto,
       -- La conversión a VARCHAR con la intercalación griega (CP1253) cambia á→a, ñ→n; lo que no tiene equivalente queda como '?' y pasa a '-'.
       LOWER(REPLACE(REPLACE(REPLACE(TRANSLATE(
           CAST(r.Proyecto COLLATE SQL_Latin1_General_CP1253_CI_AI AS VARCHAR(200)),
           ' .,;:/\_&''"()!?#+', '-----------------'), '---', '-'), '--', '-'), '--', '-'))
FROM @Resuelto r
WHERE NOT EXISTS (SELECT 1 FROM Projects pr WHERE pr.ClientId = r.ClientId AND pr.Name = r.Proyecto);

-- Quitar guiones al inicio y al final (sin TRIM(... FROM), que requiere SQL Server 2022)
UPDATE @NuevosProyectos SET Slug = CASE WHEN LEFT(Slug, 1) = '-' THEN STUFF(Slug, 1, 1, '') ELSE Slug END;
UPDATE @NuevosProyectos SET Slug = CASE WHEN RIGHT(Slug, 1) = '-' THEN LEFT(Slug, LEN(Slug) - 1) ELSE Slug END;
UPDATE n SET Slug = n.Slug + '-' + LOWER(LEFT(CONVERT(VARCHAR(36), n.ClientId), 6))
FROM @NuevosProyectos n
WHERE EXISTS (SELECT 1 FROM Projects pr WHERE pr.Slug = n.Slug)
   OR (SELECT COUNT(*) FROM @NuevosProyectos o WHERE o.Slug = n.Slug) > 1;

-- Sin repositorios de GitHub: se agregan después desde el portal (un proyecto puede tener varios).
INSERT INTO Projects (Id, ClientId, Name, Slug)
SELECT NEWID(), ClientId, Nombre, Slug FROM @NuevosProyectos;

-- 4. Productos de los clientes
DECLARE @Hoy DATE = CAST(SYSUTCDATETIME() AS DATE);

;WITH Filas AS (
    SELECT r.*, pr.Id AS ProjectId,
           -- 12:00 UTC: se ve el mismo día en cualquier zona horaria (igual que el portal)
           DATEADD(HOUR, 12, CAST(r.Fecha AS DATETIME2)) AS FechaUtc,
           CASE WHEN r.BasePrice IS NOT NULL AND r.PrecioFinal < r.BasePrice THEN r.BasePrice - r.PrecioFinal END AS Descuento
    FROM @Resuelto r
    JOIN Projects pr ON pr.ClientId = r.ClientId AND pr.Name = r.Proyecto
)
INSERT INTO ClientProducts (Id, ClientId, ProjectId, ProductId, Status, BillingCycle, IsManualBilling, RenewsAt, NextChargeAt, LastBackupAt,
                            Price, PriceLabelOverride, PayPalOrderId, PayPalSubscriptionId, PayPalPlanId, DomainName, Discount, DiscountEndsAt)
SELECT NEWID(), f.ClientId, f.ProjectId, f.ProductId,
       CASE WHEN f.Ciclo IN (1, 3, 4, 5) OR f.Fecha IS NULL THEN 0 -- Activo (suscripciones: la fecha es el próximo cobro)
            WHEN f.Fecha < @Hoy THEN 2                             -- Vencido
            WHEN f.Fecha <= DATEADD(DAY, 30, @Hoy) THEN 1          -- Por vencer
            ELSE 0 END,
       f.Ciclo, 1,
       CASE WHEN f.Ciclo IN (0, 2) THEN f.FechaUtc END,            -- Anual/Único: vencimiento
       CASE WHEN f.Ciclo IN (1, 3, 4, 5) THEN f.FechaUtc END,      -- Mensual/Bimestral/Trimestral/Semestral: próximo cobro
       NULL,
       CASE WHEN f.BasePrice IS NULL THEN f.PrecioFinal END,       -- precio propio solo si el producto no tiene precio de catálogo
       NULL, NULL, NULL, NULL, f.Dominio,
       f.Descuento,
       CASE WHEN f.Descuento IS NOT NULL THEN ISNULL(f.FechaUtc, '9999-12-31') END  -- el descuento cubre el periodo ya pagado
FROM Filas f
WHERE NOT EXISTS (
    SELECT 1 FROM ClientProducts cp
    WHERE cp.ClientId = f.ClientId AND cp.ProjectId = f.ProjectId AND cp.ProductId = f.ProductId
      AND ISNULL(cp.DomainName, N'') = ISNULL(f.Dominio, N''));

DECLARE @Insertados INT = @@ROWCOUNT;

COMMIT;

-- 5. Resumen
SELECT (SELECT COUNT(*) FROM @Carga) AS FilasEnCarga,
       (SELECT COUNT(*) FROM @NuevosProyectos) AS ProyectosCreados,
       @Insertados AS ProductosCreados,
       (SELECT COUNT(*) FROM @Carga) - @Insertados AS OmitidosPorYaExistir;

SELECT cl.CompanyName AS Cliente, pr.Name AS Proyecto, p.Name AS Producto, cp.DomainName AS Dominio,
       CASE cp.BillingCycle WHEN 0 THEN 'Unico' WHEN 1 THEN 'Mensual' WHEN 2 THEN 'Anual' WHEN 3 THEN 'Bimestral' WHEN 4 THEN 'Trimestral' WHEN 5 THEN 'Semestral' END AS Ciclo,
       CASE cp.Status WHEN 0 THEN 'Activo' WHEN 1 THEN 'PorVencer' WHEN 2 THEN 'Vencido' ELSE CAST(cp.Status AS VARCHAR) END AS Estado,
       CAST(COALESCE(cp.RenewsAt, cp.NextChargeAt) AS DATE) AS Fecha,
       COALESCE(p.BasePrice, cp.Price) AS PrecioCatalogo, cp.Discount AS Descuento,
       COALESCE(p.BasePrice, cp.Price) - ISNULL(cp.Discount, 0) AS PrecioActual
FROM ClientProducts cp
JOIN Clients cl ON cl.Id = cp.ClientId
JOIN Projects pr ON pr.Id = cp.ProjectId
JOIN Products p ON p.Id = cp.ProductId
ORDER BY cl.CompanyName, pr.Name, p.Name;


SELECT cl.Email, COUNT(cp.Id) AS Productos
  FROM Clients cl LEFT JOIN ClientProducts cp ON cp.ClientId = cl.Id
  GROUP BY cl.Email ORDER BY cl.Email;



 BEGIN TRAN;

  WITH d AS (
      SELECT cp.Id,
             ROW_NUMBER() OVER (PARTITION BY cp.ClientId, cp.ProjectId, cp.ProductId, ISNULL(cp.DomainName, N'')
                                ORDER BY COALESCE(cp.RenewsAt, cp.NextChargeAt) DESC) AS rn
      FROM ClientProducts cp
      WHERE cp.ClientId IN (SELECT Id FROM Clients WHERE Email IN (N'casob@rtres.net', N'bajaj@rtres.net'))
  )
  DELETE cp
  OUTPUT deleted.ClientId, COALESCE(deleted.RenewsAt, deleted.NextChargeAt) AS Fecha
  FROM ClientProducts cp
  JOIN d ON d.Id = cp.Id
  WHERE d.rn > 1
    AND NOT EXISTS (SELECT 1 FROM PaymentTransactions pt WHERE pt.ClientProductId = cp.Id);

  commit; -- cambia a COMMIT si lo borrado es correcto