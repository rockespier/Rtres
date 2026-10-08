namespace Rtres.Domain;

public enum BankAccountType { Ahorros, Corriente }

/// <summary>Cuenta de Rtres donde los clientes pagan por transferencia. Inactiva = no se muestra a los clientes.</summary>
public sealed class BankAccount
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string BankName { get; set; } = string.Empty;
    /// <summary>Titular que verá el cliente (razón social o nombre).</summary>
    public string Holder { get; set; } = string.Empty;
    /// <summary>PEN, USD o EUR.</summary>
    public string Currency { get; set; } = "PEN";
    public BankAccountType Type { get; set; }
    public string AccountNumber { get; set; } = string.Empty;
    /// <summary>Código de cuenta interbancario (CCI, 20 dígitos en Perú). Opcional: las cuentas del exterior no lo tienen.</summary>
    public string? Cci { get; set; }
    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }
}

/// <summary>Fila única (singleton): qué medios de pago puede usar el cliente en el portal.</summary>
public sealed class PaymentSettings
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public bool PayPalEnabled { get; set; } = true;
    public bool BankTransferEnabled { get; set; } = true;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public enum TransferReportStatus { Pendiente, Aprobado, Rechazado }

/// <summary>
/// Pago por transferencia que reporta el cliente (N° de operación y/o foto de la constancia). Rtres lo revisa: al aprobarlo
/// se registra el cobro (<see cref="PaymentTransaction"/>) y se activa o renueva el producto; al rechazarlo se avisa el motivo.
/// </summary>
public sealed class TransferReport
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ClientId { get; set; }
    public Guid ClientProductId { get; set; }
    public Guid? BankAccountId { get; set; }
    public decimal Amount { get; set; }
    /// <summary>Moneda de lo transferido (la de la cuenta de destino).</summary>
    public string Currency { get; set; } = "PEN";
    public DateOnly PaidAt { get; set; }
    public string? OperationNumber { get; set; }
    public int Years { get; set; } = 1;
    public string? ReceiptFileName { get; set; }
    public string? ReceiptContentType { get; set; }
    public byte[]? ReceiptContent { get; set; }
    public TransferReportStatus Status { get; set; }
    public string? RejectionReason { get; set; }
    public Guid? ReportedByUserId { get; set; }
    public Guid? ReviewedByUserId { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public Guid? PaymentTransactionId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>Último reporte de transferencia de un producto, para la tarjeta de "Mis servicios".</summary>
public sealed record TransferReportSummary(Guid Id, TransferReportStatus Status, DateTime CreatedAt, string? RejectionReason);
