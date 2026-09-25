using Rtres.Domain;

namespace Rtres.Api;

public record LoginRequest(string Email, string Password);
public record CreateTicketRequest(Guid ProjectId, TicketType Type, string Title, string Description, string? CurrentBehavior, string? ExpectedBehavior, string? StepsToReproduce, string? Environment, string? AcceptanceCriteria, string? EstimatedImpact);
public record CheckoutRequest(Guid ClientProductId, string ReturnUrl, string CancelUrl);
