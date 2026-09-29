using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;
namespace Rtres.Api.Controllers;
[ApiController, Route("api/auth")]
public sealed class AuthController(RtresDbContext db, JwtSettings jwt, IMemoryCache cache) : ControllerBase
{
    public const string LoginRateLimitPolicy = "login";
    // Además del límite por IP (Program.cs), bloquea una cuenta tras varios fallos seguidos desde cualquier IP.
    const int MaxFailedAttempts = 5;
    static readonly TimeSpan LockoutWindow = TimeSpan.FromMinutes(15);
    sealed class FailedLogins { public int Count; }
 [HttpPost("login"), EnableRateLimiting(LoginRateLimitPolicy)] public async Task<ActionResult> Login(LoginRequest request, CancellationToken ct) { var failKey="login-fail:"+request.Email.Trim().ToLowerInvariant(); if(cache.TryGetValue(failKey,out FailedLogins? fails)&&fails!.Count>=MaxFailedAttempts)return StatusCode(429,new{message="Demasiados intentos fallidos para esta cuenta. Inténtalo de nuevo en 15 minutos."}); var u=await db.UserAccounts.SingleOrDefaultAsync(x=>x.Email==request.Email&&x.IsActive,ct); if(u is null||new PasswordHasher<UserAccount>().VerifyHashedPassword(u,u.PasswordHash,request.Password)==PasswordVerificationResult.Failed){ var f=cache.GetOrCreate(failKey,e=>{e.AbsoluteExpirationRelativeToNow=LockoutWindow;return new FailedLogins();})!; Interlocked.Increment(ref f.Count); return Unauthorized(new {message="Credenciales inválidas."}); } cache.Remove(failKey); var c=u.ClientId is Guid clientId?await db.Clients.FindAsync([clientId],ct):null; if(c is not null&&!c.IsActive)return StatusCode(403,new{message="Este cliente está dado de baja. Contacta a Rtres."}); var claims=new List<Claim>{new(JwtRegisteredClaimNames.Sub,u.Id.ToString()),new(ClaimTypes.NameIdentifier,u.Id.ToString()),new(ClaimTypes.Role,u.Role.ToString())}; if(u.ClientId is Guid id)claims.Add(new Claim("client_id",id.ToString())); var token=new JwtSecurityToken(jwt.Issuer,jwt.Audience,claims,expires:DateTime.UtcNow.AddHours(8),signingCredentials:new SigningCredentials(jwt.SigningKey,SecurityAlgorithms.HmacSha256)); var initials=string.Concat(u.Name.Split(' ',StringSplitOptions.RemoveEmptyEntries).Take(2).Select(x=>x[0])).ToUpperInvariant(); return Ok(new {token=new JwtSecurityTokenHandler().WriteToken(token),user=new{name=u.Name,initials,clientName=c?.CompanyName,role=u.Role.ToString()}}); }
}
