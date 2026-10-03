/*
  Series y correlativos de comprobantes (Configuración de tasas → Comprobantes).

  Ambos se emiten desde SUNAT SOL con la serie E001, cada tipo con su propio correlativo:
    · Última factura:               E001-418  → la próxima será E001-419
    · Último recibo por honorarios: E001-189  → el próximo será E001-190

  Requiere la migración TaxDocumentNumberPerType (arrancar el API una vez). Equivale a guardar estos valores
  desde el portal; si ya hay comprobantes registrados con números mayores, el sistema sigue desde el mayor.
*/
IF EXISTS (SELECT 1 FROM TaxSettings)
    UPDATE TaxSettings
    SET FacturaSeries = N'E001', FacturaNextNumber = 419,
        ReciboSeries  = N'E001', ReciboNextNumber  = 190,
        UpdatedAt = SYSUTCDATETIME();
ELSE
    INSERT INTO TaxSettings (Id, IgvRate, RentaRate, UpdatedAt, FacturaSeries, FacturaNextNumber, ReciboSeries, ReciboNextNumber)
    VALUES (NEWID(), 0.18, 0.10, SYSUTCDATETIME(), N'E001', 419, N'E001', 190);

SELECT FacturaSeries, FacturaNextNumber, ReciboSeries, ReciboNextNumber FROM TaxSettings;
