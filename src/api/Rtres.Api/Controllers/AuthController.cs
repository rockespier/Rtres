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
 [HttpPost("login")] public async Task<ActionResult> Login(LoginRequest request, CancellationToken ct) { var u=await db.UserAccounts.SingleOrDefaultAsync(x=>x.Email==request.Email&&x.IsActive,ct); if(u is null||new PasswordHasher<UserAccount>().VerifyHashedPassword(u,u.PasswordHash,request.Password)==PasswordVerificationResult.Failed)return Unauthorized(new {message="Credenciales inválidas."}); var c=await db.Clients.FindAsync([u.ClientId],ct); var claims=new[]{new Claim(JwtRegisteredClaimNames.Sub,u.Id.ToString()),new Claim(ClaimTypes.NameIdentifier,u.Id.ToString()),new Claim(ClaimTypes.Role,u.Role.ToString()),new Claim("client_id",u.ClientId.ToString())}; var key=config["Jwt:Key"]??"development-only-change-me-development-only-change-me"; var token=new JwtSecurityToken(config["Jwt:Issuer"]??"rtres",config["Jwt:Audience"]??"rtres-portal",claims,expires:DateTime.UtcNow.AddHours(8),signingCredentials:new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),SecurityAlgorithms.HmacSha256)); return Ok(new {token=new JwtSecurityTokenHandler().WriteToken(token),user=new{name=c?.ContactName,initials="RR",clientName=c?.CompanyName}}); }
}
