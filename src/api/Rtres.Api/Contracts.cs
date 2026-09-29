using Rtres.Domain;

namespace Rtres.Api;

public record LoginRequest(string Email, string Password);
public record CreateTicketRequest(Guid ProjectId, TicketType Type, string Title, string Description, string? CurrentBehavior, string? ExpectedBehavior, string? StepsToReproduce, string? Environment, string? AcceptanceCriteria, string? EstimatedImpact);
public record CreateTicketCommentRequest(string Body);
public record UpdateTicketStatusRequest(TicketStatus Status);
public record TicketCommentDto(Guid Id, string Body, bool FromGithub, string? AuthorName, DateTime CreatedAt);
