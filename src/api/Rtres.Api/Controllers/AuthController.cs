using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;
namespace Rtres.Api.Controllers;
[ApiController, Route("api/auth")]
public sealed class AuthController(RtresDbContext db, IConfiguration config) : ControllerBase
{
 [HttpPost("login")] public async Task<ActionResult> Login(LoginRequest request, CancellationToken ct) { var u=await db.UserAccounts.SingleOrDefaultAsync(x=>x.Email==request.Email&&x.IsActive,ct); if(u is null||new PasswordHasher<UserAccount>().VerifyHashedPassword(u,u.PasswordHash,request.Password)==PasswordVerificationResult.Failed)return Unauthorized(new {message="Credenciales inválidas."}); var c=u.ClientId is Guid clientId?await db.Clients.FindAsync([clientId],ct):null; if(c is not null&&!c.IsActive)return StatusCode(403,new{message="Este cliente está dado de baja. Contacta a Rtres."}); var claims=new List<Claim>{new(JwtRegisteredClaimNames.Sub,u.Id.ToString()),new(ClaimTypes.NameIdentifier,u.Id.ToString()),new(ClaimTypes.Role,u.Role.ToString())}; if(u.ClientId is Guid id)claims.Add(new Claim("client_id",id.ToString())); var key=config["Jwt:Key"]??"development-only-change-me-development-only-change-me"; var token=new JwtSecurityToken(config["Jwt:Issuer"]??"rtres",config["Jwt:Audience"]??"rtres-portal",claims,expires:DateTime.UtcNow.AddHours(8),signingCredentials:new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),SecurityAlgorithms.HmacSha256)); var initials=string.Concat(u.Name.Split(' ',StringSplitOptions.RemoveEmptyEntries).Take(2).Select(x=>x[0])).ToUpperInvariant(); return Ok(new {token=new JwtSecurityTokenHandler().WriteToken(token),user=new{name=u.Name,initials,clientName=c?.CompanyName,role=u.Role.ToString()}}); }
}
