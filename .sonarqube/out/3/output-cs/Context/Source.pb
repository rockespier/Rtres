�J
AC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\AnnualTaxTests.cs�Iusing Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

/// <summary>Renta anual MYPE y Formulario 1662 (Documentacion/Confirmacion_de_mi_contador.md).</summary>
public class AnnualTaxTests
{
    const int Year = 2025; // año cerrado: sin proyección ni meses futuros

    [Theory]
    [InlineData(50_000, 5_000)]       // caso 1 del contador: no supera 15 UIT
    [InlineData(100_000, 14_436.25)]  // caso 2: 77,250 × 10 % + 22,750 × 29.5 %
    [InlineData(-3_000, 0)]           // con pérdida no hay impuesto
    public void Mype_scale_matches_the_accountant_examples(decimal netIncome, decimal expected)
    {
        var tax = MypeIncomeTax.Compute(netIncome, new AnnualTaxSettings { Year = 2026, Uit = 5_150m });
        Assert.Equal(expected, tax.Total);
    }

    [Fact]
    public async Task Annual_renta_uses_mype_income_deductible_expenses_and_real_advances()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.01m });
        db.AnnualTaxSettings.Add(new AnnualTaxSettings { Year = Year, Uit = 5_000m });
        AddSale(db, seed.Client.Id, new DateOnly(Year, 3, 10), 100_000m, null);                                   // sin comprobante: MYPE
        AddSale(db, seed.Client.Id, new DateOnly(Year, 5, 10), 23_600m, TaxDocumentType.Factura, 20_000m);       // factura: MYPE (base sin IGV)
        AddSale(db, seed.Client.Id, new DateOnly(Year, 6, 10), 9_000m, TaxDocumentType.ReciboPorHonorarios, 9_000m, retention: 720m); // persona natural
        var other = db.ExpenseCategories.Add(new ExpenseCategory { Name = "Personal", IsDeductible = false }).Entity;
        db.Expenses.AddRange(
            new Expense { Description = "VPS", CategoryId = ExpenseCategoryIds.Hosting, AmountPen = 10_000m, Amount = 10_000m, Date = new DateOnly(Year, 4, 1) },
            new Expense { Description = "Fracc SUNAT 3/12", CategoryId = ExpenseCategoryIds.Otros, AmountPen = 2_000m, Amount = 2_000m, Date = new DateOnly(Year, 4, 2), IsNonDeductible = true },
            new Expense { Description = "Viaje", CategoryId = other.Id, AmountPen = 500m, Amount = 500m, Date = new DateOnly(Year, 4, 3) },
            new Expense { Description = "Pago a cuenta", CategoryId = ExpenseCategoryIds.ImpuestoRenta, AmountPen = 900m, Amount = 900m, Date = new DateOnly(Year, 4, 20) });
        // Marzo presentado con lo realmente pagado (no el 1 % estimado de 1,000).
        db.TaxDueDates.Add(new TaxDueDate { Period = new DateOnly(Year, 3, 1), FiledAt = DateTime.UtcNow, RentaPaid = 950m });
        db.SaveChanges();

        var report = Ok(await Admin(db).AnnualRentaAsync(Year, new DateTime(2026, 6, 1), CancellationToken.None));
        Assert.Equal(120_000m, Prop(report, "ventasMypePen"));      // sin el recibo por honorarios
        Assert.Equal(10_000m, Prop(report, "gastosDeduciblesPen"));  // sin la cuota SUNAT, la categoría no deducible ni el pago de Renta
        Assert.Equal(2_500m, Prop(report, "noDeduciblesPen"));
        Assert.Equal(110_000m, Prop(report, "rentaNetaPen"));
        var tax = Assert.IsType<MypeIncomeTax>(report.GetType().GetProperty("impuesto")!.GetValue(report));
        Assert.Equal(75_000m * 0.10m + 35_000m * 0.295m, tax.Total);  // 15 UIT = 75,000
        Assert.Equal(950m + 200m, Prop(report, "pagosACuentaPen"));    // marzo real + mayo estimado (1 % de 20,000)
        Assert.Equal(11, (int)report.GetType().GetProperty("pagosEstimados")!.GetValue(report)!);
        Assert.Equal(tax.Total - 1_150m, Prop(report, "saldoPen"));
        var natural = report.GetType().GetProperty("personaNatural")!.GetValue(report)!;
        Assert.Equal((9_000m, 720m), (Prop(natural, "ingresosPen"), Prop(natural, "retencionesPen")));
    }

    [Fact]
    public async Task Annual_renta_requires_the_uit_of_the_year()
    {
        using var db = TestData.Db(out _);
        Assert.IsType<NotFoundObjectResult>(await Admin(db).AnnualRentaAsync(2019, DateTime.UtcNow, CancellationToken.None));
    }

    [Fact]
    public async Task Monthly_renta_advance_excludes_fees_receipts()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.01m });
        AddSale(db, seed.Client.Id, new DateOnly(Year, 4, 10), 10_000m, null);
        AddSale(db, seed.Client.Id, new DateOnly(Year, 4, 11), 5_000m, TaxDocumentType.ReciboPorHonorarios, 5_000m);
        var summary = Ok(await Admin(db).TaxSummaryReport(4, Year, CancellationToken.None));
        Assert.Equal((100m, 5_000m), (Prop(summary, "rentaEstimada"), Prop(summary, "ventasPersonaNaturalPen")));
    }

    [Fact]
    public async Task Paid_form_1662_igv_is_tax_credit_only_when_enabled()
    {
        using var db = TestData.Db(out var seed);
        var settings = db.TaxSettings.Add(new TaxSettings()).Entity;
        db.ExchangeRates.Add(new ExchangeRate { Date = new DateOnly(Year, 5, 3), CurrencyCode = "USD", RateToPen = 3.5m, Source = "SUNAT" }); // TC venta del día del pago
        AddSale(db, seed.Client.Id, new DateOnly(Year, 5, 10), 1_180m, TaxDocumentType.Factura, 1_000m); // débito 180
        var claude = new Expense { Description = "Claude Team", CategoryId = ExpenseCategoryIds.SuscripcionesIA, Amount = 100m, Currency = "USD", AmountPen = 350m, Date = new DateOnly(Year, 5, 3) };
        db.Expenses.Add(claude); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.MarkForm1662Paid(claude.Id, new Form1662PaymentRequest(new DateOnly(Year, 5, 20), "123"), CancellationToken.None)); // no marcado como no domiciliado
        Assert.IsType<OkObjectResult>(await admin.UpdateExpense(claude.Id, new ExpensePatchRequest(null, null, null, null, null, null, null, null, IsNonDomiciledService: true, ForeignSupplierName: "Anthropic PBC", ForeignSupplierCountry: "Estados Unidos"), CancellationToken.None));
        var list = Ok(await admin.Form1662List(Year, 5, CancellationToken.None));
        Assert.Equal((63m, 1), (Prop(list, "totalIgvPen"), (int)list.GetType().GetProperty("pendientes")!.GetValue(list)!)); // 18 % de 350

        Assert.IsType<NoContentResult>(await admin.MarkForm1662Paid(claude.Id, new Form1662PaymentRequest(new DateOnly(Year, 5, 20), "123"), CancellationToken.None));
        Assert.Equal(180m, (await admin.IgvMonthsAsync(new DateOnly(Year, 5, 31), CancellationToken.None)).Last().APagar); // apagado: no resta

        settings.Use1662AsCredit = true; db.SaveChanges();
        Assert.Equal(117m, (await admin.IgvMonthsAsync(new DateOnly(Year, 5, 31), CancellationToken.None)).Last().APagar); // 180 − 63
    }

    [Fact]
    public async Task Recurring_expenses_keep_their_tax_flags()
    {
        using var db = TestData.Db(out _);
        db.Expenses.Add(new Expense { Description = "ChatGPT Team", CategoryId = ExpenseCategoryIds.SuscripcionesIA, Amount = 30m, Currency = "PEN", AmountPen = 30m, Date = DateOnly.FromDateTime(DateTime.UtcNow).AddMonths(-1), Recurring = true, RecurrenceCycle = BillingCycle.Mensual, IsNonDomiciledService = true, ForeignSupplierName = "OpenAI OpCo, LLC", ForeignSupplierCountry = "Estados Unidos", Form1662PaidAt = DateOnly.FromDateTime(DateTime.UtcNow) });
        db.SaveChanges();
        await new Rtres.Api.Jobs.RecurringExpenseJob(db, Microsoft.Extensions.Logging.Abstractions.NullLogger<Rtres.Api.Jobs.RecurringExpenseJob>.Instance).GenerateAsync(CancellationToken.None);
        var next = await db.Expenses.OrderByDescending(x => x.Date).FirstAsync();
        Assert.Equal((true, "OpenAI OpCo, LLC", (DateOnly?)null), (next.IsNonDomiciledService, next.ForeignSupplierName, next.Form1662PaidAt));
    }

    private static void AddSale(RtresDbContext db, Guid clientId, DateOnly date, decimal amountPen, TaxDocumentType? type, decimal? basePen = null, decimal? retention = null)
    {
        var payment = new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = amountPen, Currency = "PEN", AmountPen = amountPen, Status = "COMPLETED", CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) };
        db.PaymentTransactions.Add(payment);
        if (type is TaxDocumentType t)
            db.TaxDocuments.Add(new TaxDocument { ClientId = clientId, PaymentTransactionId = payment.Id, Type = t, Series = "E001", Number = db.TaxDocuments.Local.Count + 1, IssueDate = date, Currency = "PEN", BaseAmount = basePen ?? amountPen, IgvAmount = amountPen - (basePen ?? amountPen), TotalAmount = amountPen, RetentionAmount = retention });
        db.SaveChanges();
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static object Ok(ActionResult result) => Assert.IsType<OkObjectResult>(result).Value!;
    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
}
ParseOptions.0.json�A
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\BankTransferTests.cs�Ausing System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class BankTransferTests
{
    [Fact]
    public async Task Transfer_payment_confirmed_by_rtres_activates_the_product_like_paypal()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        var notifications = new FakeNotifications();
        var payments = new PayPalPaymentService(db, null!, notifications, PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        var admin = Admin(db);

        var ok = Assert.IsType<OkObjectResult>(await admin.RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, new DateOnly(2026, 9, 1), "OP-555"), payments, CancellationToken.None));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Equal(new DateTime(2027, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.RenewsAt); // un año desde la fecha de pago
        var tx = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((PaymentMethods.Transferencia, 141.60m /* cliente en Perú: 120 + IGV */, "TRF-OP-555", new DateTime(2026, 9, 1, 12, 0, 0, DateTimeKind.Utc)), (tx.Method, tx.Amount, tx.PayPalOrderIdOrSubscriptionId, tx.CreatedAt));
        Assert.Single(db.TaxDocuments); // cliente en Perú: comprobante emitido
        Assert.Equal(NotificationType.PaymentReceived, Assert.Single(notifications.Sent).Type);

        // La misma operación no se registra dos veces.
        Assert.IsType<ConflictObjectResult>(await admin.RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, null, "OP-555"), payments, CancellationToken.None));
    }

    [Theory]
    [InlineData(true, TaxDocumentType.Factura, 141.60, true)]               // Perú + Factura: catálogo 120 + IGV
    [InlineData(true, TaxDocumentType.ReciboPorHonorarios, 120, false)]     // recibo por honorarios: sin IGV
    [InlineData(false, TaxDocumentType.Factura, 120, false)]                // cliente del exterior: sin IGV
    public async Task Catalog_prices_are_without_igv_and_it_is_added_only_to_peruvian_invoices(bool peru, TaxDocumentType taxType, decimal expected, bool includesIgv)
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = peru; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        item.Product!.TaxDocumentType = taxType; db.SaveChanges();
        var controller = PayPalPaymentTests.PaymentsControllerFor(db);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var info = Assert.IsType<BankTransferInfoDto>(Assert.IsType<OkObjectResult>(await controller.BankTransfer(item.Id, null, CancellationToken.None)).Value);
        Assert.Equal((expected, includesIgv), (info.Amount, info.IncludesIgv));
    }

    [Fact]
    public async Task Registered_transfer_defaults_to_the_total_with_igv_and_the_invoice_splits_it_back()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges(); // paga 100 + IGV
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

        Assert.IsType<OkObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, null, null), payments, CancellationToken.None));
        Assert.Equal(118m, (await db.PaymentTransactions.SingleAsync()).Amount);
        var invoice = await db.TaxDocuments.SingleAsync();
        Assert.Equal((100m, 18m, 118m), (invoice.BaseAmount, invoice.IgvAmount, invoice.TotalAmount));
    }

    [Fact]
    public async Task Transfer_payment_is_rejected_for_paypal_products()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, DateTime.UtcNow.AddMonths(1));
        item.IsManualBilling = false; db.SaveChanges();
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(100m, null, null), payments, CancellationToken.None));
        Assert.Empty(db.PaymentTransactions);
    }

    [Fact]
    public async Task Client_can_request_a_product_paying_by_transfer()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var notifications = new FakeNotifications();
        var controller = PayPalPaymentTests.PaymentsControllerFor(db, notifications);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var ok = Assert.IsType<OkObjectResult>(await controller.Subscribe(new SubscribeRequest(product.Id, seed.Project.Id, BillingCycle.Anual, PaymentMethods.Transferencia), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync();
        Assert.Equal((ClientProductStatus.Pendiente, true, null), (item.Status, item.IsManualBilling, item.PayPalOrderId)); // sin PayPal
        var info = Assert.IsType<BankTransferInfoDto>(ok.Value!.GetType().GetProperty("bankTransfer")!.GetValue(ok.Value));
        Assert.Equal("BCP Soles 123-456", info.Instructions);
        Assert.Equal(120m, info.Amount);

        // Rtres recibe el aviso del pedido (al email del equipo, no al del cliente).
        var notice = Assert.Single(notifications.Sent);
        Assert.Equal((NotificationType.TransferRequested, "equipo@rtres.net", $"transfer-request:{item.Id}"), (notice.Type, notice.To, notice.DedupeKey));
        Assert.Equal((seed.Client.CompanyName, "Hosting", "120"), (notice.Data["company"], notice.Data["product"], notice.Data["amount"]));
    }

    [Fact]
    public void Transfer_request_notice_is_always_in_spanish_and_links_to_the_client()
    {
        var notice = EmailTemplatesTests.Sample(NotificationType.TransferRequested);
        var (subject, html, text) = Rtres.Infrastructure.Notifications.EmailTemplates.Render(notice, "it", "https://portal.rtres.net");
        Assert.Equal("Pedido por transferencia: Andes Tours — Hosting anual", subject);
        Assert.Contains("https://portal.rtres.net/admin/clients/c-1", text);
        Assert.Contains("Registrar pago", text);
        Assert.Contains("Aviso interno", html);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�<
<C:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\BlogTests.cs�;using System.Net;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure;

namespace Rtres.Api.Tests;

public class BlogTests
{
    private static string Post(string slug, string tag = "Software") => $$$"""
        {"slug":"{{{slug}}}","date_gmt":"2026-11-04T15:00:00","modified_gmt":"2026-11-05T16:30:00",
         "title":{"rendered":"Qu&eacute; revisar &#8211; hosting"},
         "excerpt":{"rendered":"<p>Copias y certificados [&hellip;]</p>\n"},
         "content":{"rendered":"<p>{{{string.Join(' ', Enumerable.Repeat("palabra", 450))}}}</p>","protected":false},
         "_embedded":{"wp:featuredmedia":[{"source_url":"https://web.rtres.net/a.jpg","alt_text":"Servidores"}],
           "wp:term":[[{"taxonomy":"category","name":"blog-es"}],[{"taxonomy":"post_tag","name":"{{{tag}}}"}]]}}
        """;

    [Fact]
    public void WordPress_post_is_mapped_to_a_blog_post()
    {
        using var json = JsonDocument.Parse(Post("revisar-hosting", "Hosting &amp; dominios"));
        var post = WordPressContentClient.ParseBlogPost(json.RootElement)!;
        Assert.Equal("revisar-hosting", post.Slug);
        Assert.Equal("Qué revisar – hosting", post.Title);
        Assert.Equal("Copias y certificados…", post.Excerpt);
        Assert.Equal("Hosting & dominios", post.Tag);
        Assert.Equal(new DateTimeOffset(2026, 11, 4, 15, 0, 0, TimeSpan.Zero), post.PublishedAt);
        Assert.Equal(3, post.ReadingMinutes);
        Assert.Equal("https://web.rtres.net/a.jpg", post.CoverUrl);
        Assert.Equal("Servidores", post.CoverAlt);
    }

    [Fact]
    public void Password_protected_posts_are_not_published()
    {
        using var json = JsonDocument.Parse("""{"content":{"rendered":"","protected":true}}""");
        Assert.Null(WordPressContentClient.ParseBlogPost(json.RootElement));
    }

    [Fact]
    public async Task Client_reads_every_page_of_the_category_of_the_language()
    {
        var client = Client(new FakeWordPress(request => request.RequestUri!.PathAndQuery switch
        {
            var q when q.Contains("categories?slug=blog-it") => Json("[{\"id\":40}]"),
            var q when q.Contains("categories=40") && q.Contains("&page=1&") => Json($"[{Post("uno")}]", totalPages: 2),
            var q when q.Contains("categories=40") && q.Contains("&page=2&") => Json($"[{Post("dos")}]", totalPages: 2),
            _ => new HttpResponseMessage(HttpStatusCode.NotFound),
        }));
        Assert.Equal(["uno", "dos"], (await client.GetBlogPostsAsync("it")).Select(x => x.Slug));
    }

    [Fact]
    public async Task Missing_category_is_an_empty_blog() =>
        Assert.Empty(await Client(new FakeWordPress(_ => Json("[]"))).GetBlogPostsAsync("es"));

    [Fact]
    public async Task WordPress_failure_is_an_error_when_there_is_no_previous_copy()
    {
        var client = Client(new FakeWordPress(_ => new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)));
        await Assert.ThrowsAsync<HttpRequestException>(() => client.GetBlogPostsAsync("es"));
    }

    [Fact]
    public async Task WordPress_failure_keeps_serving_the_last_copy()
    {
        var failing = false;
        using var cache = new MemoryCache(Options.Create(new MemoryCacheOptions()));
        var client = Client(new FakeWordPress(request =>
        {
            if (failing) return new HttpResponseMessage(HttpStatusCode.ServiceUnavailable);
            return request.RequestUri!.PathAndQuery.Contains("categories?slug") ? Json("[{\"id\":1}]") : Json($"[{Post("uno")}]");
        }), cache);
        await client.GetBlogPostsAsync("es");
        cache.Remove("wp:blog:es"); // vence el caché de 5 minutos
        failing = true;
        Assert.Equal("uno", Assert.Single(await client.GetBlogPostsAsync("es")).Slug);
    }

    [Fact]
    public async Task Post_brings_related_posts_of_the_same_topic_first()
    {
        var controller = Controller(Item("a", "Hosting"), Item("b", "Software"), Item("c", "Hosting"), Item("d", null));
        var post = Assert.IsType<BlogPostDto>(Assert.IsType<OkObjectResult>((await controller.GetBlogPost("es", "a", CancellationToken.None)).Result).Value);
        Assert.Equal("<p>a</p>", post.Html);
        Assert.Equal(["c", "b"], post.Related.Select(x => x.Slug));
    }

    [Fact]
    public async Task Unknown_post_or_language_is_not_found()
    {
        var controller = Controller(Item("a", null));
        Assert.IsType<NotFoundResult>((await controller.GetBlogPost("es", "otro", CancellationToken.None)).Result);
        Assert.IsType<NotFoundResult>((await controller.GetBlogPost("fr", "a", CancellationToken.None)).Result);
        Assert.IsType<NotFoundResult>((await controller.GetBlogPosts("fr", CancellationToken.None)).Result);
    }

    [Fact]
    public async Task WordPress_down_is_reported_as_unavailable()
    {
        var controller = new PublicContentController(new FakeContent(null), null!);
        Assert.Equal(503, Assert.IsType<StatusCodeResult>((await controller.GetBlogPosts("es", CancellationToken.None)).Result).StatusCode);
        Assert.Equal(503, Assert.IsType<StatusCodeResult>((await controller.GetBlogPost("es", "a", CancellationToken.None)).Result).StatusCode);
    }

    private static WordPressBlogPost Item(string slug, string? tag) =>
        new(slug, slug, slug, $"<p>{slug}</p>", tag, DateTimeOffset.UnixEpoch, DateTimeOffset.UnixEpoch, 1, null, null);

    private static PublicContentController Controller(params WordPressBlogPost[] posts) => new(new FakeContent(posts), null!);

    private static WordPressContentClient Client(HttpMessageHandler handler, IMemoryCache? cache = null) =>
        new(new HttpClient(handler) { BaseAddress = new Uri("https://wp.test/") }, cache ?? new MemoryCache(Options.Create(new MemoryCacheOptions())));

    private static HttpResponseMessage Json(string body, int totalPages = 1)
    {
        var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(body, Encoding.UTF8, "application/json") };
        response.Headers.Add("X-WP-TotalPages", totalPages.ToString());
        return response;
    }

    private sealed class FakeWordPress(Func<HttpRequestMessage, HttpResponseMessage> respond) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) => Task.FromResult(respond(request));
    }

    /// <summary>Con <c>posts</c> null simula a WordPress caído.</summary>
    private sealed class FakeContent(IReadOnlyList<WordPressBlogPost>? posts) : IWordPressContentClient
    {
        public Task<IReadOnlyList<WordPressBlogPost>> GetBlogPostsAsync(string locale, CancellationToken cancellationToken = default) =>
            posts is null ? throw new HttpRequestException("caído") : Task.FromResult(posts);
        public Task<WordPressPage?> GetPageAsync(string locale, string slug, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<IReadOnlyList<WordPressProject>> GetProjectsAsync(string locale, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<IReadOnlyList<WordPressReview>> GetReviewsAsync(string locale, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<string?> GetHeroPhotoUrlAsync(CancellationToken cancellationToken = default) => throw new NotSupportedException();
    }
}
ParseOptions.0.json�
BC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\CategoriesTests.cs�using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;

namespace Rtres.Api.Tests;

public class CategoriesTests
{
    [Fact]
    public async Task Expense_categories_are_managed_but_system_and_used_ones_are_protected()
    {
        using var db = TestData.Db(out _);
        var categories = new CategoriesController(db);

        var created = Assert.IsType<CreatedResult>(await categories.CreateExpenseCategory(new CategoryRequest("  Viajes "), CancellationToken.None));
        var viajes = Assert.IsType<CategoryDto>(created.Value);
        Assert.Equal("Viajes", viajes.Name);
        Assert.IsType<ConflictObjectResult>(await categories.CreateExpenseCategory(new CategoryRequest("viajés"), CancellationToken.None)); // mismo nombre sin tildes ni mayúsculas
        Assert.IsType<BadRequestObjectResult>(await categories.CreateExpenseCategory(new CategoryRequest(" "), CancellationToken.None));

        Assert.IsType<NoContentResult>(await categories.RenameExpenseCategory(ExpenseCategoryIds.SuscripcionesIA, new CategoryRequest("Herramientas IA"), CancellationToken.None));
        Assert.Equal("Herramientas IA", (await db.ExpenseCategories.FindAsync(ExpenseCategoryIds.SuscripcionesIA))!.Name);
        Assert.IsType<ConflictObjectResult>(await categories.DeleteExpenseCategory(ExpenseCategoryIds.Otros, CancellationToken.None)); // de sistema

        db.Expenses.Add(new Expense { Description = "Vuelo", CategoryId = viajes.Id, Amount = 1, AmountPen = 1, Currency = "PEN", Date = new DateOnly(2026, 10, 1) }); await db.SaveChangesAsync();
        Assert.IsType<ConflictObjectResult>(await categories.DeleteExpenseCategory(viajes.Id, CancellationToken.None)); // en uso
        db.Expenses.RemoveRange(db.Expenses); await db.SaveChangesAsync();
        Assert.IsType<NoContentResult>(await categories.DeleteExpenseCategory(viajes.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Renaming_a_product_category_updates_its_products()
    {
        using var db = TestData.Db(out _);
        var categories = new CategoriesController(db);
        var web = Assert.IsType<CategoryDto>(Assert.IsType<CreatedResult>(await categories.CreateProductCategory(new CategoryRequest("Sitios web"), CancellationToken.None)).Value);
        db.Products.Add(new Product { Name = "Landing", Category = "Sitios web", Currency = "USD" }); await db.SaveChangesAsync();

        Assert.IsType<NoContentResult>(await categories.RenameProductCategory(web.Id, new CategoryRequest("Web"), CancellationToken.None));
        Assert.Equal("Web", (await db.Products.SingleAsync()).Category);
        Assert.IsType<ConflictObjectResult>(await categories.DeleteProductCategory(web.Id, CancellationToken.None));
        var listed = Assert.IsType<OkObjectResult>(await categories.ProductCategories(CancellationToken.None));
        Assert.Equal(1, Assert.Single(Assert.IsAssignableFrom<IEnumerable<CategoryDto>>(listed.Value)).UsageCount);
    }
}
ParseOptions.0.json�i
HC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\ClientOnboardingTests.cs�husing System.Reflection;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using System.Security.Claims;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ClientOnboardingTests
{
    [Fact]
    public async Task New_client_gets_an_admin_user_that_can_log_in()
    {
        using var db = TestData.Db(out _);
        var result = Assert.IsType<CreatedResult>(await Admin(db).CreateClient(new ClientRequest("Andes Tours", "Ana Quispe", "ana@andes.pe", null, "es"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");
        Assert.Equal(("Andes Tours", "ana@andes.pe"), (access.ClientName, access.Email));

        var user = await db.UserAccounts.SingleAsync(x => x.Email == "ana@andes.pe");
        Assert.Equal((UserRole.Admin, "Ana Quispe"), (user.Role, user.Name));
        Assert.IsType<OkObjectResult>(await Login(db, "ana@andes.pe", access.TemporaryPassword));
    }

    [Fact]
    public async Task Client_email_already_used_by_a_user_is_rejected()
    {
        using var db = TestData.Db(out var seed); // roberto@example.com ya es usuario
        Assert.IsType<ConflictObjectResult>(await Admin(db).CreateClient(new ClientRequest("Otra", "X", seed.User.Email, null, "es"), CancellationToken.None));
        Assert.Single(db.Clients);
    }

    [Fact]
    public async Task Generate_access_creates_the_missing_user_or_resets_the_password()
    {
        using var db = TestData.Db(out var seed);
        var legacy = new Client { CompanyName = "Legacy", ContactName = "Luis", Email = "luis@legacy.pe" }; // creado antes de esta versión, sin usuario
        db.Clients.Add(legacy); db.SaveChanges();
        var admin = Admin(db);

        var first = Assert.IsType<OkObjectResult>(await admin.ClientAccess(legacy.Id, CancellationToken.None)).Value as ClientAccess;
        Assert.IsType<OkObjectResult>(await Login(db, "luis@legacy.pe", first!.TemporaryPassword));

        var second = Assert.IsType<OkObjectResult>(await admin.ClientAccess(legacy.Id, CancellationToken.None)).Value as ClientAccess;
        Assert.Single(db.UserAccounts.Where(x => x.Email == "luis@legacy.pe"));
        Assert.IsType<UnauthorizedObjectResult>(await Login(db, "luis@legacy.pe", first.TemporaryPassword)); // la anterior deja de servir
        Assert.IsType<OkObjectResult>(await Login(db, "luis@legacy.pe", second!.TemporaryPassword));
    }

    [Fact]
    public async Task Import_creates_users_and_returns_their_accesses()
    {
        using var db = TestData.Db(out var seed);
        using var book = new XLWorkbook();
        var sheet = book.AddWorksheet("Plantilla");
        string[][] rows = [["CompanyName", "ContactName", "Email", "Phone", "PreferredLanguage", "RequiresTaxDocument"], ["Uno", "Ana", "ana@uno.pe", "", "es", "SI"], ["Dos", "Bea", seed.User.Email, "", "es", ""], ["Tres", "Caro", "caro@tres.it", "", "it", ""], ["Cuatro", "Dani", "dani@cuatro.pe", "", "es", "quizás"]];
        for (var r = 0; r < rows.Length; r++) for (var c = 0; c < rows[r].Length; c++) sheet.Cell(r + 1, c + 1).Value = rows[r][c];
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await Admin(db).ImportClients(new FormFile(stream, 0, stream.Length, "file", "clientes.xlsx"), CancellationToken.None));
        Assert.Equal(2, Prop<int>(ok.Value!, "created"));
        Assert.Equal(["ana@uno.pe", "caro@tres.it"], Prop<List<ClientAccess>>(ok.Value!, "accesses").Select(x => x.Email));
        Assert.Equal(2, await db.UserAccounts.CountAsync(x => x.Email == "ana@uno.pe" || x.Email == "caro@tres.it"));
        // Solo el cliente peruano marcado emite comprobante; un valor que no es SI/NO rechaza la fila.
        Assert.Equal(["Uno"], await db.Clients.Where(x => x.RequiresTaxDocument).Select(x => x.CompanyName).ToListAsync());
        Assert.False(await db.Clients.AnyAsync(x => x.CompanyName == "Cuatro"));
    }

    [Fact]
    public async Task Projects_are_created_with_a_unique_slug_and_can_have_several_repos()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        var created = Assert.IsType<CreatedResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda Ñandú Online", null, "rockespier", "tienda"), CancellationToken.None));
        var project = await db.Projects.Include(x => x.Repositories).SingleAsync(x => x.Name == "Tienda Ñandú Online");
        var main = Assert.Single(project.Repositories);
        Assert.Equal(("tienda-nandu-online", "rockespier", "tienda", true), (project.Slug, main.Owner, main.Name, main.IsDefault));
        Assert.IsType<ConflictObjectResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda ñandú online", null, null, null), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await admin.CreateProject(Guid.NewGuid(), new ProjectRequest("X", null, null, null), CancellationToken.None));

        Assert.IsType<OkObjectResult>(await admin.AddRepository(project.Id, new RepositoryRequest("rockespier", "tienda-api", "API", IsDefault: true), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await admin.AddRepository(project.Id, new RepositoryRequest("rockespier", "tienda"), CancellationToken.None)); // un repo, un proyecto
        var api = await db.ProjectRepositories.SingleAsync(x => x.Name == "tienda-api");
        Assert.Equal(("API", true, false), (api.Label, api.IsDefault, main.IsDefault)); // solo un principal

        Assert.IsType<OkObjectResult>(await admin.UpdateRepository(main.Id, new RepositoryRequest(null, "tienda-v2", "Web", IsDefault: true), CancellationToken.None));
        Assert.Equal(("tienda-v2", "Web", true, false), (main.Name, main.Label, main.IsDefault, api.IsDefault));

        db.Tickets.Add(new Ticket { Code = "RT-900", ClientId = seed.Client.Id, ProjectId = project.Id, RepositoryId = api.Id, GithubIssueNumber = 3 }); await db.SaveChangesAsync();
        Assert.IsType<ConflictObjectResult>(await admin.UpdateRepository(api.Id, new RepositoryRequest(null, "otro"), CancellationToken.None)); // ya tiene issues
        Assert.IsType<ConflictObjectResult>(await admin.DeleteRepository(api.Id, CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.DeleteRepository(main.Id, CancellationToken.None));
        Assert.True((await db.ProjectRepositories.SingleAsync(x => x.ProjectId == project.Id)).IsDefault); // el que queda pasa a ser el principal
    }

    [Fact]
    public async Task Projects_are_deleted_only_without_products_or_tickets()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        await admin.CreateProject(seed.Client.Id, new ProjectRequest("Landing", null, "rockespier", "landing"), CancellationToken.None);
        var project = await db.Projects.SingleAsync(x => x.Name == "Landing");
        var ticket = new Ticket { Code = "RT-901", ClientId = seed.Client.Id, ProjectId = project.Id };
        db.Tickets.Add(ticket); await db.SaveChangesAsync();

        Assert.IsType<ConflictObjectResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
        db.Tickets.Remove(ticket); await db.SaveChangesAsync();
        Assert.IsType<NoContentResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
        Assert.False(await db.Projects.AnyAsync(x => x.Id == project.Id));
        Assert.False(await db.ProjectRepositories.AnyAsync(x => x.Name == "landing"));
        Assert.IsType<NotFoundResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
    }

    [Fact]
    public async Task New_client_receives_the_access_by_email_in_its_language()
    {
        using var db = TestData.Db(out _);
        var email = new FakeEmail();
        var result = Assert.IsType<CreatedResult>(await Admin(db, email).CreateClient(new ClientRequest("Andes Tours", "Ana Quispe", "ana@andes.pe", null, "it"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");

        Assert.True(access.EmailSent);
        var message = Assert.Single(email.Sent);
        Assert.Equal("ana@andes.pe", message.To);
        Assert.Equal("Il tuo accesso al portale clienti di Rtres (Andes Tours)", message.Subject);
        Assert.Contains(access.TemporaryPassword, message.Text);
        Assert.Contains("/login", message.Html);
        var log = await db.NotificationLogs.SingleAsync();
        Assert.Equal(("AccountAccess", "ana@andes.pe", true), (log.Type, log.Recipient, log.Success));
    }

    [Fact]
    public async Task If_the_email_fails_the_access_is_still_created_and_flagged_as_not_sent()
    {
        using var db = TestData.Db(out _);
        var result = Assert.IsType<CreatedResult>(await Admin(db, new FakeEmail { Fail = true }).CreateClient(new ClientRequest("Andes Tours", "Ana", "ana@andes.pe", null, "es"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");
        Assert.False(access.EmailSent);
        Assert.IsType<OkObjectResult>(await Login(db, "ana@andes.pe", access.TemporaryPassword));
    }

    [Fact]
    public async Task Team_invitation_is_emailed_to_the_invited_person_not_to_the_client_contact()
    {
        using var db = TestData.Db(out var seed);
        var email = new FakeEmail();
        var controller = new AccountController(db, AccessEmail(db, email))
        {
            ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Admin")], "test")) } },
        };
        var result = Assert.IsType<CreatedResult>(await controller.Invite(new InviteRequest("Pedro", "pedro@cabalgatas.pe"), CancellationToken.None));

        Assert.True(Prop<bool>(result.Value!, "emailSent"));
        var message = Assert.Single(email.Sent);
        Assert.Equal("pedro@cabalgatas.pe", message.To);
        Assert.Contains(Prop<string>(result.Value!, "temporaryPassword"), message.Text);
        Assert.Contains("Hola Pedro", message.Text);
    }

    [Fact]
    public async Task Admin_sets_the_dates_of_a_manual_product_and_its_status_follows()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var admin = Admin(db);
        var soon = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(10));

        var created = Assert.IsType<CreatedResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", null, null, null, soon), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync(x => x.ProductId == product.Id);
        Assert.Equal((new DateTime(soon, new TimeOnly(12, 0), DateTimeKind.Utc), ClientProductStatus.PorVencer), (item.RenewsAt!.Value, item.Status));

        var past = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-2));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProductDates(item.Id, new ClientProductDatesRequest(past, null), CancellationToken.None));
        Assert.Equal(ClientProductStatus.Vencido, item.Status);

        var renewed = DateOnly.FromDateTime(DateTime.UtcNow.AddYears(1));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProductDates(item.Id, new ClientProductDatesRequest(renewed, null), CancellationToken.None));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.IsType<NotFoundResult>(await admin.UpdateClientProductDates(Guid.NewGuid(), new ClientProductDatesRequest(null, null), CancellationToken.None));
    }

    private static AdminController Admin(RtresDbContext db, FakeEmail? email = null) =>
        new(db, null!, null!, AccessEmail(db, email ?? new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    internal static AccessEmailService AccessEmail(RtresDbContext db, IEmailSender email) =>
        new(NotificationJobTests.Job(db, email), new ConfigurationBuilder().Build(), NullLogger<AccessEmailService>.Instance);

    private static Task<ActionResult> Login(RtresDbContext db, string email, string password, IMemoryCache? cache = null) =>
        new AuthController(db, TestJwt, cache ?? new MemoryCache(new MemoryCacheOptions())).Login(new LoginRequest(email, password), CancellationToken.None);

    internal static readonly JwtSettings TestJwt = JwtSettings.FromConfiguration(
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = new string('k', 48) }).Build());

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name, BindingFlags.Public | BindingFlags.Instance)!.GetValue(value)!;
}
ParseOptions.0.json�
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\ClientProductAdminTests.cs�using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ClientProductAdminTests
{
    [Fact]
    public async Task Unpaid_product_can_be_deleted_and_then_its_project_too()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        db.TransferReports.Add(new TransferReport { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 10, Status = TransferReportStatus.Rechazado });
        seed.Ticket.ClientProductId = item.Id; db.Tickets.Remove(seed.Ticket); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteProject(seed.Project.Id, CancellationToken.None));
        Assert.IsType<NoContentResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        Assert.False(await db.ClientProducts.AnyAsync());
        Assert.False(await db.TransferReports.AnyAsync());
        Assert.IsType<NoContentResult>(await admin.DeleteProject(seed.Project.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Product_with_payments_is_not_deleted_but_can_move_to_another_project()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        db.PaymentTransactions.Add(new PaymentTransaction { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 120, Status = "COMPLETED", PayPalOrderIdOrSubscriptionId = "TRF-1" });
        var other = new Project { ClientId = seed.Client.Id, Name = "Web nueva", Slug = "web-nueva" };
        var foreign = new Project { ClientId = Guid.NewGuid(), Name = "Ajeno", Slug = "ajeno" };
        db.Projects.AddRange(other, foreign); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, ProjectId: foreign.Id), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, ProjectId: other.Id), CancellationToken.None));
        await db.Entry(item).ReloadAsync();
        Assert.Equal(other.Id, item.ProjectId);
    }

    [Fact]
    public async Task Active_paypal_subscription_must_be_cancelled_before_deleting()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        item.PayPalSubscriptionId = "I-123"; item.Status = ClientProductStatus.Activo; db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        item.Status = ClientProductStatus.Cancelado; db.SaveChanges();
        Assert.IsType<NoContentResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�
?C:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\ContactTests.cs�using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;

namespace Rtres.Api.Tests;

public class ContactTests
{
    [Fact]
    public async Task Valid_contact_is_saved_and_staff_is_notified_in_background()
    {
        using var db = TestData.Db(out _);
        var jobs = new FakeJobs();
        var result = await Controller(db, jobs).Submit(new ContactRequest(" Ana Pérez ", "ana@empresa.pe", "+51 999 111 222", "Empresa SAC", "software-a-medida", "Necesitamos un sistema de ventas con comisiones.", "es", "/es/servicios/software-a-medida"), CancellationToken.None);

        Assert.IsType<AcceptedResult>(result);
        var lead = await db.ContactLeads.SingleAsync();
        Assert.Equal(("Ana Pérez", "software-a-medida", "/es/servicios/software-a-medida", ContactLeadStatus.Nuevo), (lead.Name, lead.Service, lead.SourcePage, lead.Status));
        Assert.Single(jobs.Created); // el email al equipo va por Hangfire: un SMTP lento no frena el formulario
    }

    [Fact]
    public async Task Honeypot_is_accepted_silently_without_saving()
    {
        using var db = TestData.Db(out _);
        var jobs = new FakeJobs();
        Assert.IsType<AcceptedResult>(await Controller(db, jobs).Submit(new ContactRequest("Bot", "bot@spam.com", null, null, null, "Compre seguidores baratos ahora mismo", "es", null, Website: "http://spam.example"), CancellationToken.None));
        Assert.False(await db.ContactLeads.AnyAsync());
        Assert.Empty(jobs.Created);
    }

    [Theory]
    [InlineData("", "ana@empresa.pe", "Mensaje suficientemente largo", "name")]
    [InlineData("Ana", "no-es-un-email", "Mensaje suficientemente largo", "email")]
    [InlineData("Ana", "ana@empresa.pe", "Hola", "message")]
    public async Task Invalid_contact_is_rejected(string name, string email, string message, string field)
    {
        using var db = TestData.Db(out _);
        var bad = Assert.IsType<BadRequestObjectResult>(await Controller(db, new FakeJobs()).Submit(new ContactRequest(name, email, null, null, null, message, "it", null), CancellationToken.None));
        Assert.Equal(field, bad.Value!.GetType().GetProperty("field")!.GetValue(bad.Value));
    }

    [Fact]
    public void Lead_email_lists_who_and_what_for_the_team()
    {
        var (subject, _, text) = Rtres.Infrastructure.Notifications.EmailTemplates.Render(new Notification(NotificationType.ContactLead, new() { ["name"] = "Ana", ["email"] = "ana@empresa.pe", ["company"] = "Empresa SAC", ["service"] = "apis", ["message"] = "Hola, quiero la API de RUC", ["locale"] = "es", ["page"] = "/es/" }), "en", "https://portal.rtres.net");
        Assert.Equal("Nuevo contacto desde la web: Ana (Empresa SAC)", subject); // siempre en español: es para el equipo
        Assert.Contains("ana@empresa.pe", text);
        Assert.Contains("https://portal.rtres.net/admin/leads", text);
    }

    private static ContactController Controller(Rtres.Infrastructure.Persistence.RtresDbContext db, FakeJobs jobs) =>
        new(db, jobs) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�5
@C:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\DiscountTests.cs�4using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class DiscountTests
{
    [Fact]
    public async Task Discount_on_an_active_product_covers_the_current_period_and_renewal_is_at_catalog_price()
    {
        using var db = TestData.Db(out var seed);
        var renewsAt = DateTime.UtcNow.AddMonths(3);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, renewsAt);
        var admin = Admin(db);

        var ok = Assert.IsType<OkObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, Discount: 30), CancellationToken.None));
        Assert.Equal((120m, 90m, 120m), (Prop<decimal>(ok.Value!, "listPrice"), Prop<decimal>(ok.Value!, "currentPrice"), Prop<decimal>(ok.Value!, "nextChargePrice")));
        Assert.Equal(renewsAt, item.DiscountEndsAt);

        // Se paga la renovación: precio de catálogo y el descuento desaparece.
        await Payments(db).ApplyPaymentAsync(item, "ORD-REN", 120m, "USD", CancellationToken.None);
        Assert.Equal((null, null, 120m), (item.Discount, item.DiscountEndsAt, item.CurrentPrice(DateTime.UtcNow)));
    }

    [Fact]
    public async Task Discount_on_a_pending_product_is_used_by_the_first_payment_only()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(30));
        Assert.Equal(90m, item.NextChargePrice()); // el primer cobro va con descuento

        await Payments(db).ApplyPaymentAsync(item, "ORD-1", 90m, "USD", CancellationToken.None);
        Assert.Equal(item.RenewsAt, item.DiscountEndsAt); // cubre el año recién pagado
        Assert.Equal((90m, 120m), (item.CurrentPrice(DateTime.UtcNow), item.NextChargePrice()));
        Assert.Equal(120m, item.CurrentPrice(item.RenewsAt!.Value.AddDays(1))); // vencido el periodo, vuelve al catálogo
    }

    [Fact]
    public async Task Discount_can_be_given_when_assigning_and_is_validated()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", null, null, null, Discount: 150), CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", 80m, null, null, new DateOnly(2027, 1, 15), Discount: 20), CancellationToken.None));
        var dto = Prop<object>(created.Value!, "clientProduct");
        // El precio propio se ignora si el producto tiene precio de catálogo: el precio distinto se expresa como descuento.
        Assert.Equal((120m, 100m, 120m), (Prop<decimal>(dto, "listPrice"), Prop<decimal>(dto, "currentPrice"), Prop<decimal>(dto, "nextChargePrice")));
    }

    [Fact]
    public async Task Surcharge_on_an_active_product_goes_to_the_next_charge_only()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, DateTime.UtcNow.AddMonths(3));
        var admin = Admin(db);

        var ok = Assert.IsType<OkObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, Discount: -30), CancellationToken.None));
        Assert.Equal((120m, 150m), (Prop<decimal>(ok.Value!, "listPrice"), Prop<decimal>(ok.Value!, "nextChargePrice")));
        Assert.Null(item.DiscountEndsAt);
        Assert.Equal(177m, item.NextChargeTotal(0.18m));

        await Payments(db).ApplyPaymentAsync(item, "ORD-REC", 150m, "USD", CancellationToken.None);
        Assert.Equal(item.RenewsAt, item.DiscountEndsAt); // cubre el periodo recién pagado
        Assert.Equal((150m, 120m), (item.CurrentPrice(DateTime.UtcNow), item.NextChargePrice()));

        await Payments(db).ApplyPaymentAsync(item, "ORD-REN", 120m, "USD", CancellationToken.None);
        Assert.Equal((null, null, 120m), (item.Discount, item.DiscountEndsAt, item.NextChargePrice()));
    }

    [Fact]
    public void Surcharge_only_raises_the_first_of_the_prepaid_years_and_comes_back_when_the_payment_is_reversed()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(-30));
        Assert.Equal(390m, item.ChargeTotal(0m, 3)); // 150 + 2 × 120

        var paidEnd = new DateTime(2027, 9, 1, 0, 0, 0, DateTimeKind.Utc);
        item.DiscountEndsAt = paidEnd;
        item.OnPaymentReversed(paidEnd);
        Assert.Equal(150m, item.NextChargePrice());
    }

    [Fact]
    public void Surcharge_is_rejected_on_a_running_PayPal_subscription_but_a_discount_is_not()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, DateTime.UtcNow.AddMonths(3));
        item.PayPalSubscriptionId = "SUB-1";

        Assert.NotNull(item.SetDiscount(-30));
        Assert.Null(item.Discount);
        Assert.Null(item.SetDiscount(30));
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}
ParseOptions.0.json�>
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\ExpenseImportTests.cs�=using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ExpenseImportTests
{
    [Fact]
    public async Task Template_rows_are_imported_and_invalid_ones_reported()
    {
        using var db = TestData.Db(out _);
        db.ExchangeRates.Add(new ExchangeRate { Date = new DateOnly(2026, 9, 1), CurrencyCode = "USD", RateToPen = 3.75m, Source = "SUNAT" }); db.SaveChanges();
        var admin = Admin(db);

        // Se parte de la plantilla descargable: así el test también cubre que sus columnas coinciden con el importador.
        var template = Assert.IsType<FileContentResult>(await admin.ExpenseTemplate(CancellationToken.None));
        using var book = new XLWorkbook(new MemoryStream(template.FileContents));
        Assert.Equal(2, book.Worksheets.Count); // Plantilla + Valores válidos
        var sheet = book.Worksheet(1);
        // Fila 2: número y fecha con tipo de Excel; fila 3: todo como texto; filas 4-6: inválidas.
        sheet.Cell(2, 1).Value = "Servidor VPS"; sheet.Cell(2, 2).Value = "hosting"; sheet.Cell(2, 3).Value = "Fijo"; sheet.Cell(2, 4).Value = 20; sheet.Cell(2, 5).Value = "usd"; sheet.Cell(2, 6).Value = new DateTime(2026, 9, 1); sheet.Cell(2, 7).Value = "SI"; sheet.Cell(2, 8).Value = "Mensual";
        Row(sheet, 3, "Claude", "SuscripcionesIA", "Variable", "49.90", "PEN", "28/09/2026", "", "");
        Row(sheet, 4, "Sin monto", "Otros", "Variable", "0", "PEN", "2026-09-01", "", "");
        Row(sheet, 5, "Mala categoría", "Viajes", "Variable", "10", "PEN", "2026-09-01", "", "");
        Row(sheet, 6, "Recurrente sin ciclo", "Otros", "Fijo", "10", "PEN", "2026-09-01", "SI", "");
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await admin.ImportExpenses(new FormFile(stream, 0, stream.Length, "file", "gastos.xlsx"), CancellationToken.None));
        Assert.Equal((2, 3), (Prop<int>(ok.Value!, "created"), Prop<int>(ok.Value!, "skipped")));
        Assert.Equal([4, 5, 6], Prop<List<ImportError>>(ok.Value!, "errors").Select(x => x.Row));

        var vps = await db.Expenses.SingleAsync(x => x.Description == "Servidor VPS");
        Assert.Equal((ExpenseCategoryIds.Hosting, "USD", 75m, true, (BillingCycle?)BillingCycle.Mensual), (vps.CategoryId, vps.Currency, vps.AmountPen, vps.Recurring, vps.RecurrenceCycle));
        var claude = await db.Expenses.SingleAsync(x => x.Description == "Claude");
        Assert.Equal((49.90m, new DateOnly(2026, 9, 28), false), (claude.Amount, claude.Date, claude.Recurring));
    }

    [Fact]
    public async Task Unreadable_file_is_rejected()
    {
        using var db = TestData.Db(out _);
        using var stream = new MemoryStream("no es excel"u8.ToArray());
        Assert.IsType<BadRequestObjectResult>(await Admin(db).ImportExpenses(new FormFile(stream, 0, stream.Length, "file", "gastos.xlsx"), CancellationToken.None));
        Assert.Empty(db.Expenses);
    }

    private static void Row(IXLWorksheet sheet, int row, params string[] values) { for (var c = 0; c < values.Length; c++) sheet.Cell(row, c + 1).Value = values[c]; }

    [Fact]
    public async Task Ending_a_recurring_expense_removes_later_payments_of_the_series_only()
    {
        using var db = TestData.Db(out _);
        Expense Pay(string description, int month, string currency = "USD") => new() { Description = description, CategoryId = ExpenseCategoryIds.SuscripcionesIA, Type = ExpenseType.Fijo, Amount = 10, AmountPen = 37, Currency = currency, Date = new DateOnly(2026, month, 7), Recurring = true, RecurrenceCycle = BillingCycle.Mensual };
        var series = Enumerable.Range(1, 12).Select(m => Pay("Github Copilot", m)).ToList();
        db.Expenses.AddRange(series); db.Expenses.AddRange(Pay("Claude", 11), Pay("Github Copilot", 11, "PEN")); await db.SaveChangesAsync();
        var admin = Admin(db);

        var preview = Assert.IsType<OkObjectResult>(await admin.EndRecurrence(series[0].Id, new EndRecurrenceRequest(new DateOnly(2026, 9, 30)), dryRun: true, CancellationToken.None));
        Assert.Equal(3, Prop<int>(preview.Value!, "removed"));
        Assert.Equal(14, await db.Expenses.CountAsync()); // dryRun no borra

        Assert.IsType<OkObjectResult>(await admin.EndRecurrence(series[0].Id, new EndRecurrenceRequest(new DateOnly(2026, 9, 30)), dryRun: false, CancellationToken.None));
        Assert.Equal(11, await db.Expenses.CountAsync()); // octubre-diciembre fuera; Claude y la serie en soles intactos
        Assert.All(db.Expenses.Where(x => x.Description == "Github Copilot" && x.Currency == "USD"), x => Assert.Equal(new DateOnly(2026, 9, 30), x.RecurrenceEndsAt));
        Assert.Null((await db.Expenses.SingleAsync(x => x.Description == "Claude")).RecurrenceEndsAt);

        Assert.IsType<NoContentResult>(await admin.ResumeRecurrence(series[0].Id, CancellationToken.None));
        Assert.Null((await db.Expenses.FindAsync(series[0].Id))!.RecurrenceEndsAt);

        Assert.IsType<NoContentResult>(await admin.DeleteExpense(series[0].Id, CancellationToken.None));
        Assert.IsType<NotFoundResult>(await admin.DeleteExpense(series[0].Id, CancellationToken.None));
    }

    [Fact]
    public async Task Recurring_expenses_schedule_the_next_payments_within_30_days()
    {
        using var db = TestData.Db(out _);
        Expense Pay(string description, DateOnly date, BillingCycle cycle = BillingCycle.Mensual, DateOnly? endsAt = null) => new() { Description = description, CategoryId = ExpenseCategoryIds.SuscripcionesIA, Type = ExpenseType.Fijo, Amount = 20, AmountPen = 20, Currency = "PEN", Date = date, Recurring = true, RecurrenceCycle = cycle, RecurrenceEndsAt = endsAt };
        db.Expenses.AddRange(
            Pay("Claude", new(2026, 1, 31)), Pay("Claude", new(2026, 9, 30)),          // mensual, día 31
            Pay("Dominio", new(2025, 10, 20), BillingCycle.Anual),                     // anual: toca el 20/10/2026
            Pay("Copilot", new(2026, 3, 7), endsAt: new(2026, 3, 7)),                  // finalizado
            Pay("Viejo", new(2026, 1, 15)));                                           // sin pagos desde enero: no se rellena el pasado
        await db.SaveChangesAsync();
        var job = new RecurringExpenseJob(db, Microsoft.Extensions.Logging.Abstractions.NullLogger<RecurringExpenseJob>.Instance);

        var today = new DateOnly(2026, 10, 6);
        await job.GenerateAsync(today, CancellationToken.None);
        Assert.Equal([new DateOnly(2026, 10, 31)], db.Expenses.Where(x => x.Description == "Claude" && x.Date > today).Select(x => x.Date).ToList());
        Assert.True(await db.Expenses.AnyAsync(x => x.Description == "Dominio" && x.Date == new DateOnly(2026, 10, 20)));
        Assert.Equal(1, await db.Expenses.CountAsync(x => x.Description == "Copilot"));
        Assert.Equal([new DateOnly(2026, 10, 15)], db.Expenses.Where(x => x.Description == "Viejo" && x.Date > new DateOnly(2026, 1, 15)).Select(x => x.Date).ToList());

        Assert.All(db.Expenses.Where(x => x.Date > today), x => Assert.Equal(ExpenseCategoryIds.SuscripcionesIA, x.CategoryId));
        Assert.Equal(0, await job.GenerateAsync(today, CancellationToken.None)); // idempotente
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}
ParseOptions.0.json�5
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\FinanceReportTests.cs�4using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class FinanceReportTests
{
    const int Year = 2026;

    [Fact]
    public async Task Manual_tax_document_registers_its_payment_and_counts_once()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);

        Assert.IsType<CreatedResult>(await Admin(db).CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(Year, 3, 10), "PEN", 1000m, null, 80m), CancellationToken.None));

        var document = db.TaxDocuments.Single();
        var payment = db.PaymentTransactions.Single();
        Assert.Equal(payment.Id, document.PaymentTransactionId);
        Assert.Equal(seed.Client.Id, payment.ClientId);
        var sales = Ok(await Admin(db).SalesReport(3, Year, "PEN", CancellationToken.None));
        Assert.Equal(1000m, Prop(sales, "total"));
    }

    [Fact]
    public async Task Remittance_without_product_counts_in_the_client_ranking()
    {
        using var db = TestData.Db(out var seed);
        var other = new Client { CompanyName = "Roma Srl", Email = "info@roma.it" }; db.Add(other);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 2, 5), 300m);
        AddPayment(db, other.Id, new DateOnly(Year, 2, 20), 700m, method: PaymentMethods.Remesa);
        AddPayment(db, other.Id, new DateOnly(Year, 1, 20), 350m, method: PaymentMethods.Remesa);

        var report = Ok(await Admin(db).ClientsReport(2, Year, CancellationToken.None));
        var rows = ((IEnumerable<object>)report.GetType().GetProperty("clientes")!.GetValue(report)!).ToList();
        Assert.Equal(1000m, Prop(report, "totalPen"));
        Assert.Equal("Roma Srl", Str(rows[0], "ClientName"));
        Assert.Equal((700m, 70m, 70m, 100m), (Prop(rows[0], "IngresosPen"), Prop(rows[0], "Porcentaje"), Prop(rows[0], "PorcentajeAcumulado"), (decimal)rows[0].GetType().GetProperty("VariacionPorcentaje")!.GetValue(rows[0])!));
        Assert.Equal(100m, Prop(rows[1], "PorcentajeAcumulado"));
    }

    [Fact]
    public async Task Yearly_report_equals_the_sum_of_its_months()
    {
        using var db = TestData.Db(out var seed);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 1, 31), 100m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 6, 1), 250m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 12, 31), 50m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year + 1, 1, 1), 999m);
        db.Expenses.Add(new Expense { Description = "VPS", CategoryId = ExpenseCategoryIds.Hosting, Amount = 40m, AmountPen = 40m, Date = new DateOnly(Year, 6, 15) }); db.SaveChanges();

        var admin = Admin(db);
        var year = Ok(await admin.NetReport(null, Year, CancellationToken.None));
        decimal months = 0;
        for (var month = 1; month <= 12; month++) months += Prop(Ok(await admin.NetReport(month, Year, CancellationToken.None)), "ventasPen");
        Assert.Equal(400m, Prop(year, "ventasPen"));
        Assert.Equal(months, Prop(year, "ventasPen"));
        Assert.Equal(12, ((System.Collections.ICollection)year.GetType().GetProperty("serie")!.GetValue(year)!).Count);
    }

    [Fact]
    public async Task Net_profit_always_subtracts_the_renta_advance_on_sales_without_igv()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.10m });
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 4, 10), 1000m);
        db.Expenses.Add(new Expense { Description = "Sueldo", CategoryId = ExpenseCategoryIds.Sueldos, Amount = 300m, AmountPen = 300m, Date = new DateOnly(Year, 4, 30) }); db.SaveChanges();

        var net = Ok(await Admin(db).NetReport(4, Year, CancellationToken.None));
        Assert.Equal((0.10m, 100m, 600m), (Prop(net, "rentaRate"), Prop(net, "impuestosPen"), Prop(net, "utilidadNetaPen")));

        // Un pago de Renta registrado no reemplaza al pago a cuenta ni se cuenta como gasto operativo.
        db.Expenses.Add(new Expense { Description = "Pago a cuenta Renta", CategoryId = ExpenseCategoryIds.ImpuestoRenta, Amount = 15m, AmountPen = 15m, Date = new DateOnly(Year, 4, 20) }); db.SaveChanges();
        var withPayment = Ok(await Admin(db).NetReport(4, Year, CancellationToken.None));
        Assert.Equal((300m, 100m, 600m), (Prop(withPayment, "gastosPen"), Prop(withPayment, "impuestosPen"), Prop(withPayment, "utilidadNetaPen")));
    }

    [Fact]
    public async Task Export_returns_an_excel_file()
    {
        using var db = TestData.Db(out var seed);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 5, 5), 500m);
        var file = Assert.IsType<FileContentResult>(await Admin(db).ExportReport(null, Year, CancellationToken.None));
        Assert.Equal("reporte-2026.xlsx", file.FileDownloadName);
        Assert.NotEmpty(file.FileContents);
    }

    private static void AddPayment(RtresDbContext db, Guid clientId, DateOnly date, decimal amountPen, string method = PaymentMethods.Transferencia)
    {
        db.PaymentTransactions.Add(new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = amountPen, Currency = "PEN", AmountPen = amountPen, Status = "COMPLETED", Method = method, CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) });
        db.SaveChanges();
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, TaxDocumentType taxType)
    {
        var product = new Product { Name = "Soporte", Type = ProductType.Hosting, BillingCycle = BillingCycle.Mensual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, BillingCycle = BillingCycle.Mensual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static object Ok(ActionResult result) => Assert.IsType<OkObjectResult>(result).Value!;
    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
    private static string Str(object value, string name) => (string)value.GetType().GetProperty(name)!.GetValue(value)!;
}
ParseOptions.0.json��
BC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\GitHubSyncTests.cs��using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Hangfire;
using Hangfire.Common;
using Hangfire.States;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Api.GitHub;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class GitHubLabelsTests
{
    [Theory]
    [InlineData("open", null, new string[0], TicketStatus.Abierto)]
    [InlineData("open", null, new[] { "tipo:soporte", "estado:en-progreso" }, TicketStatus.EnProgreso)]
    [InlineData("open", null, new[] { "estado:en-progreso", "estado:resuelto" }, TicketStatus.Resuelto)]
    [InlineData("closed", "completed", new string[0], TicketStatus.Resuelto)]
    [InlineData("closed", "not_planned", new string[0], TicketStatus.Cerrado)]
    [InlineData("closed", "completed", new[] { "Estado:Publicado" }, TicketStatus.Publicado)]
    [InlineData("closed", "completed", new[] { "bug", "estado:abierto" }, TicketStatus.Resuelto)] // label con el que nace todo issue
    [InlineData("closed", "not_planned", new[] { "estado:en-progreso" }, TicketStatus.Cerrado)]
    [InlineData("closed", "completed", new[] { "estado:en-progreso", "estado:resuelto" }, TicketStatus.Resuelto)]
    public void ResolveStatus_maps_issue_state_and_labels(string state, string? reason, string[] labels, TicketStatus expected)
        => Assert.Equal(expected, GitHubLabels.ResolveStatus(state, reason, labels));

    [Fact]
    public void Status_labels_round_trip()
    {
        foreach (var status in Enum.GetValues<TicketStatus>())
            Assert.Equal(status, GitHubLabels.ResolveStatus("open", null, [GitHubLabels.ForStatus(status)]));
    }
}

public class GitHubWebhookSignatureTests
{
    [Fact]
    public void Accepts_valid_and_rejects_tampered_signatures()
    {
        var body = Encoding.UTF8.GetBytes("{\"a\":1}");
        var header = TestData.Sign("s3cret", body);
        Assert.True(GitHubWebhookSignature.IsValid("s3cret", body, header));
        Assert.False(GitHubWebhookSignature.IsValid("otro", body, header));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", Encoding.UTF8.GetBytes("{\"a\":2}"), header));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", body, null));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", body, "sha256=zz"));
        Assert.False(GitHubWebhookSignature.IsValid("", body, header));
    }
}

public class GitHubIssuesClientTests
{
    [Fact]
    public void Token_per_owner_falls_back_to_default()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["GitHub:Token"] = "personal",
            ["GitHub:Tokens:Mi-Org"] = "org",
        }).Build();

        Assert.Equal("org", GitHubIssuesClient.TokenFor(config, "mi-org"));
        Assert.Equal("personal", GitHubIssuesClient.TokenFor(config, "rockespier"));
        Assert.Throws<InvalidOperationException>(() => GitHubIssuesClient.TokenFor(new ConfigurationBuilder().Build(), "rockespier"));
    }

    [Fact]
    public void Body_skips_empty_sections_and_impact_only_for_changes()
    {
        var ticket = new Ticket { Code = "RT-110", Type = TicketType.Bug, Title = "Botón roto", Description = "No responde", Environment = "  ", EstimatedImpact = "Alto" };
        var body = GitHubIssuesClient.BuildBody(ticket);
        Assert.Contains("## Descripción\nNo responde", body.ReplaceLineEndings("\n"));
        Assert.DoesNotContain("## Entorno", body);
        Assert.DoesNotContain("Impacto", body);
        ticket.Type = TicketType.Requerimiento;
        Assert.Contains("## Impacto estimado", GitHubIssuesClient.BuildBody(ticket));
        Assert.Equal("[RT-110] Botón roto", GitHubIssuesClient.BuildTitle(ticket));
        Assert.Equal(["requirement", "estado:abierto", "proyecto:web"], GitHubIssuesClient.BuildLabels(new Project { Slug = "web" }, ticket));
    }

    [Theory]
    [InlineData(TicketType.Bug, "bug")]
    [InlineData(TicketType.Funcionalidad, "enhancement")]
    [InlineData(TicketType.Requerimiento, "requirement")]
    public void Type_labels_follow_github_conventions(TicketType type, string label) => Assert.Equal(label, GitHubLabels.ForType(type));

    [Fact]
    public void Portal_comment_body_carries_marker()
    {
        var comment = new TicketComment { Body = " Gracias " };
        var body = GitHubIssuesClient.BuildCommentBody(comment, "Roberto");
        Assert.StartsWith("**Roberto** (vía portal de clientes):", body);
        Assert.Contains(GitHubLabels.PortalCommentMarker + comment.Id, body);
    }
}

public class GitHubIssueSyncJobTests
{
    [Fact]
    public async Task Creates_issue_once_and_stores_number()
    {
        using var db = TestData.Db(out var seed);
        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        Assert.Equal(1, github.Calls);
        var ticket = await db.Tickets.SingleAsync(x => x.Id == seed.Ticket.Id);
        Assert.Equal(42, ticket.GithubIssueNumber);
        Assert.Equal("https://github.com/rtres/cabalgatas-andinas-web/issues/42", ticket.GithubIssueUrl);
    }

    [Fact]
    public async Task Portal_comments_are_published_once_issue_exists()
    {
        using var db = TestData.Db(out var seed);
        var comment = new TicketComment { TicketId = seed.Ticket.Id, AuthorUserId = seed.User.Id, Body = "¿Novedades?" };
        db.TicketComments.Add(comment); await db.SaveChangesAsync();
        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);

        await job.PostCommentAsync(comment.Id, CancellationToken.None); // sin issue todavía: no publica
        Assert.Empty(github.Comments);

        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None); // publica los pendientes
        await job.PostCommentAsync(comment.Id, CancellationToken.None); // ya publicado: no duplica
        var (issue, body) = Assert.Single(github.Comments);
        Assert.Equal(42, issue);
        Assert.StartsWith("**Roberto Ramos**", body);
        Assert.Equal(5000, (await db.TicketComments.SingleAsync()).GithubCommentId);
    }

    [Fact]
    public async Task Skips_projects_without_repo()
    {
        using var db = TestData.Db(out var seed);
        TestData.RemoveRepos(db);
        var github = new FakeGitHub();
        await new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance).CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        Assert.Equal(0, github.Calls);
    }
}

public class MultiRepoProjectTests
{
    [Fact]
    public async Task Ticket_goes_to_the_chosen_repo_and_its_webhook_finds_it()
    {
        using var db = TestData.Db(out var seed);
        var api = new ProjectRepository { ProjectId = seed.Project.Id, Owner = "rtres", Name = "cabalgatas-andinas-api", Label = "API" };
        db.ProjectRepositories.Add(api); await db.SaveChangesAsync();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "X", "Y", null, null, null, null, null, null, Guid.NewGuid()), null, CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Falla el API", "500", null, null, null, null, null, null, api.Id), null, CancellationToken.None));
        var ticket = Assert.IsType<Ticket>(created.Value);

        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None); // sin repositorio indicado: va al principal
        Assert.Equal(["rtres/cabalgatas-andinas-api", "rtres/cabalgatas-andinas-web"], github.Repos);
        Assert.Equal(api.Id, (await db.Tickets.SingleAsync(x => x.Id == ticket.Id)).RepositoryId);

        // Mismo número de issue en ambos repos: el webhook distingue el ticket por repositorio.
        await new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance)
            .ProcessAsync("issues", TestData.IssueEvent("closed", 42, state: "closed", repo: "cabalgatas-andinas-api"), CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync(x => x.Id == ticket.Id)).Status);
        Assert.Equal(TicketStatus.Abierto, (await db.Tickets.SingleAsync(x => x.Id == seed.Ticket.Id)).Status);
    }
}

public class GitHubProjectStatusTests
{
    [Theory]
    [InlineData("Recibido", TicketStatus.Abierto)]
    [InlineData("En Progreso", TicketStatus.EnProgreso)]
    [InlineData("In progress", TicketStatus.EnProgreso)]
    [InlineData("Resuelto", TicketStatus.Resuelto)]
    [InlineData("Done", TicketStatus.Resuelto)]
    [InlineData("PUBLICADO", TicketStatus.Publicado)]
    [InlineData("En progresó", TicketStatus.EnProgreso)]
    [InlineData("Revisión", null)]
    [InlineData(null, null)]
    public void Columns_map_to_ticket_status(string? column, TicketStatus? expected) => Assert.Equal(expected, GitHubProjectStatus.Map(column));

    [Fact]
    public void Closed_issue_ignores_a_work_in_progress_column()
    {
        Assert.Null(GitHubProjectStatus.Resolve(new GitHubIssueState(true, "En Progreso")));
        Assert.Equal(TicketStatus.Publicado, GitHubProjectStatus.Resolve(new GitHubIssueState(true, "Publicado")));
    }

    [Fact]
    public void GraphQL_response_is_parsed_and_partial_errors_are_tolerated()
    {
        var json = JsonDocument.Parse("""
            {"data":{"repository":{
              "i1":{"state":"OPEN","projectItems":{"nodes":[{"fieldValueByName":null},{"fieldValueByName":{"name":"En Progreso"}}]}},
              "i2":{"state":"CLOSED","projectItems":null},
              "i3":null}},
             "errors":[{"message":"Could not resolve to an Issue with the number of 3."}]}
            """).RootElement;
        var states = GitHubIssuesClient.ParseStates(json).ToDictionary(x => x.Number, x => x.State);
        Assert.Equal(new GitHubIssueState(false, "En Progreso"), states[1]);
        Assert.Equal(new GitHubIssueState(true, null), states[2]);
        Assert.False(states.ContainsKey(3));
        Assert.Contains("i1:issue(number:1)", GitHubIssuesClient.BuildStatesQuery([1, 2]));
    }

    [Fact]
    public async Task Job_applies_the_column_only_when_it_changes()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        seed.Ticket.RepositoryId = (await db.ProjectRepositories.FirstAsync()).Id; await db.SaveChangesAsync();
        var github = new FakeGitHub(); var notifications = new FakeNotifications();
        var job = new GitHubProjectStatusSyncJob(db, github, notifications, NullLogger<GitHubProjectStatusSyncJob>.Instance);

        github.States[7] = new GitHubIssueState(false, "En Progreso");
        await job.SyncAsync(CancellationToken.None);
        var ticket = await db.Tickets.SingleAsync();
        Assert.Equal((TicketStatus.EnProgreso, "En Progreso"), (ticket.Status, ticket.GithubProjectStatus));
        Assert.Equal("EnProgreso", Assert.Single(notifications.Sent).Data["status"]);

        // Un label estado:resuelto lo cambia por webhook; la columna no se movió, así que el job no lo pisa.
        ticket.Status = TicketStatus.Resuelto; await db.SaveChangesAsync();
        await job.SyncAsync(CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync()).Status);

        github.States[7] = new GitHubIssueState(false, "Publicado");
        await job.SyncAsync(CancellationToken.None);
        Assert.Equal(TicketStatus.Publicado, (await db.Tickets.SingleAsync()).Status);
        Assert.Equal(2, notifications.Sent.Count);
    }

    [Fact]
    public async Task Webhook_ignores_events_that_do_not_change_status()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        seed.Ticket.Status = TicketStatus.EnProgreso; await db.SaveChangesAsync(); // movido de columna; el issue aún tiene estado:abierto
        var processor = new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance);
        await processor.ProcessAsync("issues", TestData.IssueEvent("edited", 7, labels: ["estado:abierto"]), CancellationToken.None);
        var labeledBug = JsonSerializer.SerializeToElement(new { action = "labeled", label = new { name = "bug" }, issue = new { number = 7, state = "open", labels = new[] { new { name = "estado:abierto" }, new { name = "bug" } } }, repository = new { name = "cabalgatas-andinas-web", owner = new { login = "rtres" } } });
        await processor.ProcessAsync("issues", labeledBug, CancellationToken.None);
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
    }
}

public class TicketAttachmentTests
{
    [Fact]
    public async Task Attachments_are_uploaded_to_the_repo_once_and_linked_in_the_issue()
    {
        using var db = TestData.Db(out var seed);
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };
        static IFormFile File(string name, string type, int size) => new FormFile(new MemoryStream(new byte[size]), 0, size, "files", name) { Headers = new HeaderDictionary(), ContentType = type };
        var request = new CreateTicketRequest(seed.Project.Id, TicketType.Requerimiento, "Beneficios en el PDF", "Letras más pequeñas", null, "2 por fila", null, null, "Se ve como la imagen", null);

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(request, null, CancellationToken.None, [File("vacio.png", "image/png", 0)]));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(request, null, CancellationToken.None, [File("diseño final.png", "image/png", 10), File("log.txt", "text/plain", 5)]));
        var ticket = Assert.IsType<Ticket>(created.Value);

        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None); // reintento: no vuelve a subir
        Assert.Equal(2, github.Uploads.Count);
        Assert.All(github.Uploads, x => Assert.StartsWith($".rtres/attachments/{ticket.Code}/", x));
        Assert.EndsWith("-dise-o-final.png", github.Uploads[0]);
        Assert.Contains("![diseño final.png](https://github.com/", github.LastBody);
        Assert.Contains("- [log.txt](https://github.com/", github.LastBody);
    }

    [Fact]
    public void Attachments_are_committed_to_their_own_branch_not_the_protected_default()
    {
        var request = GitHubIssuesClient.BuildUploadRequest("Adjunto de RT-107: log.txt", [1, 2, 3]);

        Assert.Equal("rtres-attachments", request.Branch);
        Assert.Equal(Convert.ToBase64String([1, 2, 3]), request.Content);
    }
}

public class TicketFromProductTests
{
    [Fact]
    public async Task Ticket_can_come_from_a_product_only_if_the_product_allows_tickets()
    {
        using var db = TestData.Db(out var seed);
        var support = new Product { Name = "Soporte", AllowsTickets = true }; var hosting = new Product { Name = "Hosting" };
        var withTickets = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = support.Id };
        var withoutTickets = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = hosting.Id };
        db.AddRange(support, hosting, withTickets, withoutTickets); await db.SaveChangesAsync();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Caído", "No carga", null, null, null, null, null, null, ClientProductId: withoutTickets.Id), null, CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Caído", "No carga", null, null, null, null, null, null, ClientProductId: withTickets.Id), null, CancellationToken.None));
        Assert.Equal(withTickets.Id, Assert.IsType<Ticket>(created.Value).ClientProductId);
    }
}

public class GitHubWebhookProcessorTests
{
    [Fact]
    public async Task Status_change_updates_ticket_and_notifies()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var notifications = new FakeNotifications();
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("labeled", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
        var sent = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.TicketStatusChanged, sent.Type);
        Assert.Equal("EnProgreso", sent.Data["status"]); Assert.Equal("RT-108", sent.Data["code"]); Assert.Equal(seed.Ticket.Id.ToString(), sent.Data["ticketId"]);

        // Mismo estado otra vez: no se notifica de nuevo.
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("edited", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Single(notifications.Sent);

        // Cerrar el issue sin quitar los labels de trabajo en curso también cambia el estado y avisa.
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("closed", 7, state: "closed", labels: ["estado:abierto", "estado:en-progreso"]), CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync()).Status);
        Assert.Equal(2, notifications.Sent.Count);
    }

    [Fact]
    public async Task Issue_from_other_repo_is_ignored()
    {
        using var db = TestData.Db(out _, issueNumber: 7);
        await Processor(db, new FakeNotifications()).ProcessAsync("issues", TestData.IssueEvent("closed", 7, state: "closed", repo: "otro-repo"), CancellationToken.None);
        Assert.Equal(TicketStatus.Abierto, (await db.Tickets.SingleAsync()).Status);
    }

    [Fact]
    public async Task Comments_are_created_edited_deleted_and_bots_ignored()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var notifications = new FakeNotifications();
        var processor = Processor(db, notifications);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 901, "ci", userType: "Bot"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 902, "**Ana** (vía portal):\n\nHola\n\n" + GitHubLabels.PortalCommentMarker + Guid.NewGuid() + " -->"), CancellationToken.None);
        var comment = await db.TicketComments.SingleAsync();
        Assert.True(comment.FromGithub); Assert.Equal("dev", comment.GithubAuthorLogin);
        // Solo el comentario humano nuevo avisa al cliente (ni el duplicado, ni el bot, ni el eco del portal).
        var reply = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.TicketReply, reply.Type); Assert.Equal("ticket-reply:900", reply.DedupeKey); Assert.Equal("dev", reply.Data["author"]);

        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("edited", 7, 900, "Corregido"), CancellationToken.None);
        Assert.Equal("Corregido", (await db.TicketComments.SingleAsync()).Body);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("deleted", 7, 900, "Corregido"), CancellationToken.None);
        Assert.Empty(db.TicketComments);
    }

    private static GitHubWebhookProcessor Processor(RtresDbContext db, INotificationSender n) => new(db, n, NullLogger<GitHubWebhookProcessor>.Instance);
}

public class GitHubWebhookControllerTests
{
    [Theory]
    [InlineData("s3cret", true)]
    [InlineData("otro", false)]
    public async Task Verifies_signature_before_processing(string signingSecret, bool accepted)
    {
        using var db = TestData.Db(out _, issueNumber: 7);
        var body = Encoding.UTF8.GetBytes(TestData.IssueEvent("closed", 7, state: "closed").GetRawText());
        var context = new DefaultHttpContext();
        context.Request.Body = new MemoryStream(body);
        context.Request.Headers["X-GitHub-Event"] = "issues";
        context.Request.Headers["X-Hub-Signature-256"] = TestData.Sign(signingSecret, body);
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["GitHub:WebhookSecret"] = "s3cret" }).Build();
        var controller = new GitHubWebhookController(new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance), config, NullLogger<GitHubWebhookController>.Instance)
            { ControllerContext = new ControllerContext { HttpContext = context } };

        var result = await controller.Receive(CancellationToken.None);

        Assert.Equal(accepted ? typeof(OkResult) : typeof(UnauthorizedResult), result.GetType());
        Assert.Equal(accepted ? TicketStatus.Resuelto : TicketStatus.Abierto, (await db.Tickets.SingleAsync()).Status);
    }
}

public class TicketCommentsEndpointTests
{
    [Fact]
    public async Task Portal_comment_is_saved_with_author_and_queued_for_github()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var jobs = new FakeJobs();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var controller = new PortalController(db, jobs, new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest("  "), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await controller.AddComment(Guid.NewGuid(), new CreateTicketCommentRequest("Hola"), CancellationToken.None));

        var result = Assert.IsType<OkObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest(" Hola "), CancellationToken.None));
        var dto = Assert.IsType<TicketCommentDto>(result.Value);
        Assert.Equal("Hola", dto.Body); Assert.Equal("Roberto Ramos", dto.AuthorName); Assert.False(dto.FromGithub);
        var job = Assert.Single(jobs.Created);
        Assert.Equal(nameof(GitHubIssueSyncJob.PostCommentAsync), job.Method.Name);
    }
}

public class AdminTicketEndpointTests
{
    [Fact]
    public async Task Updates_portal_ticket_notifies_client_and_rejects_github_ticket()
    {
        using var db = TestData.Db(out var seed);
        var jobs = new FakeJobs(); var notifications = new FakeNotifications();
        var controller = Admin(db, seed.User, jobs, notifications);
        TestData.RemoveRepos(db);

        var ok = Assert.IsType<OkObjectResult>(await controller.UpdateTicket(seed.Ticket.Id, new UpdateTicketStatusRequest(TicketStatus.EnProgreso), CancellationToken.None));
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
        var notification = Assert.Single(notifications.Sent); Assert.Equal(NotificationType.TicketStatusChanged, notification.Type); Assert.NotNull(notification.DedupeKey);

        db.ProjectRepositories.Add(new ProjectRepository { ProjectId = seed.Project.Id, Owner = "rtres", Name = "repo", IsDefault = true }); await db.SaveChangesAsync();
        var conflict = Assert.IsType<ConflictObjectResult>(await controller.UpdateTicket(seed.Ticket.Id, new UpdateTicketStatusRequest(TicketStatus.Resuelto), CancellationToken.None));
        Assert.Equal("El estado de este ticket se gestiona en GitHub", ((dynamic)conflict.Value!).message);
    }

    [Fact]
    public async Task Admin_comment_on_github_ticket_is_queued_and_client_cannot_use_admin_controller()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var jobs = new FakeJobs(); var notifications = new FakeNotifications();
        var admin = Admin(db, seed.User, jobs, notifications);
        var result = Assert.IsType<OkObjectResult>(await admin.AddTicketComment(seed.Ticket.Id, new CreateTicketCommentRequest("Lo revisamos"), CancellationToken.None));
        var comment = Assert.IsType<TicketCommentDto>(result.Value); Assert.Equal("Lo revisamos", comment.Body); Assert.Equal("Rtres", comment.AuthorName);
        Assert.Equal(nameof(GitHubIssueSyncJob.PostCommentAsync), Assert.Single(jobs.Created).Method.Name);
        Assert.Equal(NotificationType.TicketReply, Assert.Single(notifications.Sent).Type);

        var authorization = Assert.Single(typeof(AdminController).GetCustomAttributes(typeof(AuthorizeAttribute), true).Cast<AuthorizeAttribute>());
        Assert.Equal(nameof(UserRole.SuperAdmin), authorization.Roles); // El pipeline devuelve 403 al cliente antes de ejecutar estos endpoints.
    }

    [Fact]
    public async Task New_ticket_without_repo_notifies_rtres()
    {
        using var db = TestData.Db(out var seed);
        TestData.RemoveRepos(db);
        var notifications = new FakeNotifications(); var jobs = new FakeJobs();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        var portal = new PortalController(db, jobs, notifications, config, NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Sin repo", "Necesito ayuda", null, null, null, null, null, null), null, CancellationToken.None);

        var notification = Assert.Single(notifications.Sent); Assert.Equal(NotificationType.TicketCreated, notification.Type); Assert.Equal("equipo@rtres.net", notification.To); Assert.NotNull(notification.DedupeKey);
    }

    private static AdminController Admin(RtresDbContext db, UserAccount user, IBackgroundJobClient jobs, INotificationSender notifications)
    {
        user.Role = UserRole.SuperAdmin; db.SaveChanges();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()), new Claim(ClaimTypes.Role, nameof(UserRole.SuperAdmin))], "test");
        return new AdminController(db, null!, null!, null!, null!, jobs, notifications) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };
    }
}

public class SqlServerTranslationTests
{
    // La base en memoria de los demás tests acepta consultas que SQL Server no puede traducir; esto valida la traducción real.
    [Fact]
    public void Comment_queries_translate_to_sql_server()
    {
        using var db = new RtresDbContext(new DbContextOptionsBuilder<RtresDbContext>().UseSqlServer("Server=none;Database=x;User Id=a;Password=b").Options);
        var id = Guid.NewGuid();
        Assert.Contains("SELECT", PortalController.ToCommentDtos(db, db.TicketComments.Where(x => x.TicketId == id).OrderBy(x => x.CreatedAt)).ToQueryString());
        Assert.Contains("SELECT", PortalController.ToCommentDtos(db, db.TicketComments.Where(x => x.Id == id)).ToQueryString());
    }
}

internal sealed class FakeJobs : IBackgroundJobClient
{
    public List<Job> Created { get; } = [];
    public string Create(Job job, IState state) { Created.Add(job); return Created.Count.ToString(); }
    public bool ChangeState(string jobId, IState state, string expectedState) => true;
}

internal sealed record Seed(Client Client, Project Project, Ticket Ticket, UserAccount User);

internal static class TestData
{
    public static RtresDbContext Db(out Seed seed, int? issueNumber = null)
    {
        var db = new RtresDbContext(new DbContextOptionsBuilder<RtresDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
        db.Database.EnsureCreated(); // siembra las categorías de gasto de sistema (HasData)
        var client = new Client { CompanyName = "Cabalgatas Andinas", Email = "c@example.com" };
        var project = new Project { ClientId = client.Id, Name = "Web", Slug = "cabalgatas-andinas-web" };
        var repository = new ProjectRepository { ProjectId = project.Id, Owner = "rtres", Name = "cabalgatas-andinas-web", IsDefault = true };
        project.Repositories.Add(repository);
        var user = new UserAccount { ClientId = client.Id, Email = "roberto@example.com", Name = "Roberto Ramos" };
        var ticket = new Ticket { Code = "RT-108", ClientId = client.Id, ProjectId = project.Id, Title = "Botón", Description = "No responde", GithubIssueNumber = issueNumber, RepositoryId = issueNumber is null ? null : repository.Id };
        db.AddRange(client, project, user, ticket); db.SaveChanges();
        seed = new Seed(client, project, ticket, user);
        return db;
    }

    public static void RemoveRepos(RtresDbContext db) { db.ProjectRepositories.RemoveRange(db.ProjectRepositories); db.SaveChanges(); }

    public static string Sign(string secret, byte[] body) => "sha256=" + Convert.ToHexStringLower(HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), body));

    public static JsonElement IssueEvent(string action, int number, string state = "open", string[]? labels = null, string repo = "cabalgatas-andinas-web")
        => Json(new { action, issue = new { number, state, state_reason = (string?)null, labels = (labels ?? []).Select(name => new { name }) }, repository = Repo(repo) });

    public static JsonElement CommentEvent(string action, int number, long commentId, string body, string userType = "User")
        => Json(new { action, issue = new { number, state = "open" }, comment = new { id = commentId, body, user = new { login = "dev", type = userType } }, repository = Repo("cabalgatas-andinas-web") });

    private static object Repo(string name) => new { name, owner = new { login = "rtres" } };
    private static JsonElement Json(object value) => JsonSerializer.SerializeToElement(value);
}

internal sealed class FakeGitHub : IGitHubIssuesClient
{
    public int Calls { get; private set; }
    public List<(int Issue, string Body)> Comments { get; } = [];
    public List<string> Repos { get; } = [];
    public Task<long> CreateCommentAsync(ProjectRepository repository, int issueNumber, string body, CancellationToken cancellationToken = default)
    {
        Comments.Add((issueNumber, body));
        return Task.FromResult(5000L);
    }
    public Dictionary<int, GitHubIssueState> States { get; } = [];
    public Task<IReadOnlyDictionary<int, GitHubIssueState>> GetIssueStatesAsync(ProjectRepository repository, IReadOnlyCollection<int> issueNumbers, CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyDictionary<int, GitHubIssueState>>(States.Where(x => issueNumbers.Contains(x.Key)).ToDictionary());
    public List<string> Uploads { get; } = [];
    public string? LastBody { get; private set; }
    public Task<string> UploadFileAsync(ProjectRepository repository, string path, byte[] content, string message, CancellationToken cancellationToken = default)
    {
        Uploads.Add(path);
        return Task.FromResult($"https://github.com/{repository.Owner}/{repository.Name}/blob/main/{path}?raw=true");
    }
    public Task<GitHubIssue> CreateIssueAsync(Project project, ProjectRepository repository, Ticket ticket, IReadOnlyList<TicketAttachment> attachments, CancellationToken cancellationToken = default)
    {
        Calls++; Repos.Add($"{repository.Owner}/{repository.Name}"); LastBody = GitHubIssuesClient.BuildBody(ticket, attachments);
        return Task.FromResult(new GitHubIssue(42, $"https://github.com/{repository.Owner}/{repository.Name}/issues/42"));
    }
}

internal sealed class FakeNotifications : INotificationSender
{
    public List<Notification> Sent { get; } = [];
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default) { Sent.Add(notification); return Task.CompletedTask; }
}
ParseOptions.0.json� 
FC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\ImportTemplateTests.cs�using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ImportTemplateTests
{
    [Fact]
    public void Templates_explain_accepted_values_and_offer_dropdowns()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);
        foreach (var (result, dropdownColumn, dropdownValues) in new[]
        {
            (admin.ClientTemplate(), 5, "\"es,en,it\""),
            (admin.ProductTemplate(), 1, $"\"{string.Join(",", Enum.GetNames<ProductType>())}\""),
            (admin.ExpenseTemplate(CancellationToken.None).Result, 2, $"\"{string.Join(",", ExpenseCategoryIds.Seed.Select(x => x.Name))}\""),
        })
        {
            using var book = Open(result);
            var sheet = book.Worksheet("Plantilla");
            Assert.True(sheet.Cell(1, 1).HasComment); // nota con lo que acepta la columna
            var validation = Assert.Single(sheet.DataValidations, v => v.Ranges.Any(r => r.FirstCell().Address.ColumnNumber == dropdownColumn));
            Assert.Equal(dropdownValues, validation.Value);
            var help = book.Worksheet("Valores válidos");
            Assert.Equal(sheet.Row(1).CellsUsed().Count(), help.Column(1).CellsUsed().Count() - 2); // encabezado + nota final
        }
    }

    [Fact]
    public async Task Product_import_uses_the_documented_values_and_reports_each_problem()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);
        using var book = Open(admin.ProductTemplate());
        var sheet = book.Worksheet("Plantilla");
        Row(sheet, 2, "hosting", "Hosting anual", "Anual", "120.50", "usd", "", "");  // IsActive vacío = SI, comprobante vacío = Factura
        Row(sheet, 3, "Dominio", "Dominio .pe", "Anual", "35", "PEN", "", "NO", "ReciboPorHonorarios");
        Row(sheet, 7, "Ssl", "SSL", "Anual", "10", "USD", "", "", "Boleta");
        Row(sheet, 4, "7", "Tipo numérico", "Anual", "10", "USD", "", "");          // número que no es un tipo
        Row(sheet, 5, "Ssl", "SSL", "Anual", "diez", "USD", "", "");
        Row(sheet, 6, "Ssl", "SSL", "Anual", "10", "GBP", "", "");
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await admin.ImportProducts(new FormFile(stream, 0, stream.Length, "file", "productos.xlsx"), CancellationToken.None));
        var errors = (List<ImportError>)ok.Value!.GetType().GetProperty("errors")!.GetValue(ok.Value)!;
        Assert.Equal([4, 5, 6, 7], errors.Select(x => x.Row));
        Assert.Contains("TaxDocumentType", errors[3].Reason);
        Assert.Contains("Type", errors[0].Reason); Assert.Contains("BasePrice", errors[1].Reason); Assert.Contains("Moneda", errors[2].Reason);

        var hosting = await db.Products.SingleAsync(x => x.Name == "Hosting anual");
        Assert.Equal((ProductType.Hosting, 120.50m, "USD", true, TaxDocumentType.Factura), (hosting.Type, hosting.BasePrice, hosting.Currency, hosting.IsActive, hosting.TaxDocumentType));
        var dominio = await db.Products.SingleAsync(x => x.Name == "Dominio .pe");
        Assert.Equal((false, TaxDocumentType.ReciboPorHonorarios), (dominio.IsActive, dominio.TaxDocumentType));
    }

    private static XLWorkbook Open(IActionResult result) => new(new MemoryStream(Assert.IsType<FileContentResult>(result).FileContents));
    private static void Row(IXLWorksheet sheet, int row, params string[] values) { for (var c = 0; c < values.Length; c++) sheet.Cell(row, c + 1).Value = values[c]; }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�
FC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\LearningVideosTests.cs�using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;

namespace Rtres.Api.Tests;

public class LearningVideosTests
{
    [Theory]
    [InlineData("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://youtube.com/watch?feature=share&v=dQw4w9WgXcQ&t=30", "dQw4w9WgXcQ")]
    [InlineData("https://youtu.be/dQw4w9WgXcQ?si=abc", "dQw4w9WgXcQ")]
    [InlineData("youtube.com/shorts/dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://www.youtube.com/embed/dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://vimeo.com/123456", null)]
    [InlineData("https://www.youtube.com/watch?v=corto", null)]
    [InlineData("", null)]
    public void Youtube_links_are_parsed(string input, string? expected) => Assert.Equal(expected, LearningVideosController.ParseYoutubeId(input));

    [Fact]
    public async Task Site_gets_only_published_videos_of_its_language_or_for_all()
    {
        using var db = TestData.Db(out _);
        var videos = new LearningVideosController(db);
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("https://youtu.be/aaaaaaaaaaa", "Marca personal", "Marca personal", "es", null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("bbbbbbbbbbb", "Habits", "Disciplina y hábitos", "en", null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("ccccccccccc", "Para todos", "Negocios", null, null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("ddddddddddd", "Borrador", "Negocios", "es", null, IsPublished: false), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await videos.Create(new LearningVideoRequest("https://www.youtube.com/watch?v=aaaaaaaaaaa", "Repetido", "X", null, null), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await videos.Create(new LearningVideoRequest("https://vimeo.com/1", "X", "X", null, null), CancellationToken.None));

        var es = Assert.IsAssignableFrom<IEnumerable<PublicVideoDto>>(Assert.IsType<OkObjectResult>(await videos.PublicVideos("es", CancellationToken.None)).Value);
        Assert.Equal(["aaaaaaaaaaa", "ccccccccccc"], es.Select(x => x.YoutubeId));
        Assert.IsType<NotFoundResult>(await videos.PublicVideos("fr", CancellationToken.None));

        var ids = await db.LearningVideos.OrderByDescending(x => x.YoutubeId).Select(x => x.Id).ToListAsync();
        Assert.IsType<NoContentResult>(await videos.Reorder(ids, CancellationToken.None));
        es = Assert.IsAssignableFrom<IEnumerable<PublicVideoDto>>(Assert.IsType<OkObjectResult>(await videos.PublicVideos("es", CancellationToken.None)).Value);
        Assert.Equal(["ccccccccccc", "aaaaaaaaaaa"], es.Select(x => x.YoutubeId));
    }
}
ParseOptions.0.json�
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\LoginSecurityTests.cs�using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class LoginSecurityTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("corta")]
    [InlineData("development-only-change-me-development-only-change-me")]
    public void Api_does_not_start_without_a_real_jwt_key(string? key)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = key }).Build();
        Assert.Throws<InvalidOperationException>(() => JwtSettings.FromConfiguration(config));
    }

    [Fact]
    public async Task Account_is_locked_after_repeated_failed_logins()
    {
        using var db = DbWithPassword(out var seed);
        var cache = new MemoryCache(new MemoryCacheOptions());
        for (var i = 0; i < 5; i++)
            Assert.IsType<UnauthorizedObjectResult>(await Login(db, cache, seed.User.Email, "incorrecta"));

        // Ya bloqueada: ni siquiera la contraseña correcta entra, y el correo en otro formato cuenta igual.
        var locked = Assert.IsType<ObjectResult>(await Login(db, cache, " " + seed.User.Email.ToUpperInvariant(), Password));
        Assert.Equal(429, locked.StatusCode);
    }

    [Fact]
    public async Task Successful_login_resets_the_failed_attempts()
    {
        using var db = DbWithPassword(out var seed);
        var cache = new MemoryCache(new MemoryCacheOptions());
        for (var i = 0; i < 4; i++) await Login(db, cache, seed.User.Email, "incorrecta");
        Assert.IsType<OkObjectResult>(await Login(db, cache, seed.User.Email, Password));
        for (var i = 0; i < 4; i++) await Login(db, cache, seed.User.Email, "incorrecta");
        Assert.IsType<OkObjectResult>(await Login(db, cache, seed.User.Email, Password));
    }

    const string Password = "Correcta-2026";

    private static RtresDbContext DbWithPassword(out Seed seed)
    {
        var db = TestData.Db(out seed);
        seed.User.PasswordHash = new PasswordHasher<UserAccount>().HashPassword(seed.User, Password);
        db.SaveChanges();
        return db;
    }

    private static Task<ActionResult> Login(RtresDbContext db, IMemoryCache cache, string email, string password) =>
        new AuthController(db, ClientOnboardingTests.TestJwt, cache).Login(new LoginRequest(email, password), CancellationToken.None);
}
ParseOptions.0.json�x
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\NotificationTests.cs�wusing System.Security.Claims;
using System.Text;
using Hangfire.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class EmailTemplatesTests
{
    public static TheoryData<NotificationType, string> AllTypesAndLanguages()
    {
        var data = new TheoryData<NotificationType, string>();
        foreach (var type in Enum.GetValues<NotificationType>())
            foreach (var lang in EmailTemplates.Languages) data.Add(type, lang);
        return data;
    }

    [Theory, MemberData(nameof(AllTypesAndLanguages))]
    public void Every_type_renders_in_every_language(NotificationType type, string lang)
    {
        var (subject, html, text) = EmailTemplates.Render(Sample(type), lang, "https://portal.rtres.net/");
        Assert.False(string.IsNullOrWhiteSpace(subject));
        Assert.DoesNotContain("{0}", subject + text);
        Assert.Contains("https://portal.rtres.net/", html);
        Assert.DoesNotContain("portal.rtres.net//", text);
    }

    [Fact]
    public void Renders_localized_values_and_encodes_html()
    {
        var reply = Sample(NotificationType.TicketReply);
        reply.Data["body"] = "<script>alert(1)</script>";
        var (_, html, _) = EmailTemplates.Render(reply, "es", "https://portal.rtres.net");
        Assert.DoesNotContain("<script>", html);
        Assert.Contains("&lt;script&gt;", html);
        Assert.Contains("/tickets/t-1", html);

        Assert.Equal("Ticket RT-108: En progreso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "es", "x").Subject);
        Assert.Equal("Ticket RT-108: In corso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "it", "x").Subject);
        Assert.Equal("Ticket RT-108: En progreso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "fr", "x").Subject); // idioma desconocido → es

        var (subject, _, text) = EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "en", "x");
        Assert.Equal("Hosting (cabalgatasandinas.com) expires in 7 days", subject);
        Assert.Contains("October 14, 2026", text);
        Assert.Contains("USD 120.00", text);
        Assert.Contains("14 de octubre de 2026", EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "es", "x").Text);
        Assert.Contains("14 ottobre 2026", EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "it", "x").Text);
    }

    internal static Notification Sample(NotificationType type) => new(type, type switch
    {
        NotificationType.RenewalReminder => new() { ["product"] = "Hosting", ["domain"] = "cabalgatasandinas.com", ["renewsAt"] = "2026-10-14T00:00:00.0000000Z", ["days"] = "7", ["autoRenew"] = "false", ["amount"] = "120", ["currency"] = "USD" },
        NotificationType.TicketStatusChanged => new() { ["ticketId"] = "t-1", ["code"] = "RT-108", ["title"] = "Botón", ["status"] = "EnProgreso" },
        NotificationType.TicketReply => new() { ["ticketId"] = "t-1", ["code"] = "RT-108", ["title"] = "Botón", ["author"] = "dev", ["body"] = "Listo" },
        NotificationType.PaymentReceived => new() { ["product"] = "Hosting", ["amount"] = "120", ["currency"] = "USD" },
        NotificationType.AccountAccess => new() { ["name"] = "Ana", ["company"] = "Andes Tours", ["email"] = "ana@andes.pe", ["password"] = "Xk3pQ9" },
        NotificationType.TransferRequested => new() { ["clientId"] = "c-1", ["company"] = "Andes Tours", ["product"] = "Hosting anual", ["project"] = "Web", ["amount"] = "120", ["currency"] = "USD" },
        _ => new() { ["product"] = "Hosting" },
    });
}

public class NotificationJobTests
{
    [Fact]
    public async Task Sends_logs_and_deduplicates()
    {
        using var db = TestData.Db(out var seed);
        var email = new FakeEmail();
        var job = Job(db, email);
        var notification = EmailTemplatesTests.Sample(NotificationType.PaymentReceived) with { DedupeKey = "payment:abc" };

        await job.SendAsync(seed.Client.Id, notification, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, notification, CancellationToken.None);

        var message = Assert.Single(email.Sent);
        Assert.Equal("c@example.com", message.To);
        var log = await db.NotificationLogs.SingleAsync();
        Assert.True(log.Success); Assert.Equal("PaymentReceived", log.Type); Assert.Equal("payment:abc", log.DedupeKey); Assert.Equal("c@example.com", log.Recipient);
    }

    [Fact]
    public async Task Bell_inbox_keeps_one_entry_per_notice_and_counts_unread_per_user()
    {
        using var db = TestData.Db(out var seed);
        var job = Job(db, new FakeEmail());
        var reply = EmailTemplatesTests.Sample(NotificationType.TicketReply) with { DedupeKey = "reply:1" };
        await job.SendAsync(seed.Client.Id, reply, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, reply, CancellationToken.None); // reintento: no duplica
        await job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.TicketCreated) with { DedupeKey = "created:1", To = "equipo@rtres.net" }, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.AccountAccess) with { DedupeKey = "access:1" }, CancellationToken.None);
        Assert.Equal(2, await db.PortalNotifications.CountAsync()); // el acceso (con contraseña) va solo por email

        var portal = Portal(db, seed, "Cliente", seed.Client.Id);
        var mine = Assert.IsType<OkObjectResult>(await portal.Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(1, (int)mine.GetType().GetProperty("unread")!.GetValue(mine)!); // el aviso interno de ticket nuevo no lo ve el cliente
        await portal.NotificationsSeen(CancellationToken.None);
        var seen = Assert.IsType<OkObjectResult>(await portal.Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(0, (int)seen.GetType().GetProperty("unread")!.GetValue(seen)!);

        var staff = Assert.IsType<OkObjectResult>(await Portal(db, seed, "SuperAdmin", null).Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(2, (int)staff.GetType().GetProperty("unread")!.GetValue(staff)!); // Rtres ve todo, con su propio "leído"
    }

    [Fact]
    public async Task SuperAdmin_opens_any_ticket_from_the_inbox_but_a_client_only_its_own()
    {
        using var db = TestData.Db(out var seed);
        var id = seed.Ticket.Id;

        Assert.IsType<OkObjectResult>(await Portal(db, seed, "SuperAdmin", null).Ticket(id, null, CancellationToken.None));
        Assert.IsType<NotFoundResult>(await Portal(db, seed, "SuperAdmin", null).Ticket(id, Guid.NewGuid(), CancellationToken.None)); // con cliente seleccionado, acotado a él
        Assert.IsType<OkObjectResult>(await Portal(db, seed, "Cliente", seed.Client.Id).Ticket(id, null, CancellationToken.None));
        Assert.IsType<NotFoundResult>(await Portal(db, seed, "Cliente", Guid.NewGuid()).Ticket(id, seed.Client.Id, CancellationToken.None));
    }

    private static PortalController Portal(RtresDbContext db, Seed seed, string role, Guid? clientId)
    {
        var user = role == "SuperAdmin" ? new UserAccount { Email = "admin@rtres.net", Role = UserRole.SuperAdmin } : seed.User;
        if (role == "SuperAdmin") { db.UserAccounts.Add(user); db.SaveChanges(); }
        Claim[] claims = clientId is Guid id ? [new(ClaimTypes.NameIdentifier, user.Id.ToString()), new("client_id", id.ToString()), new(ClaimTypes.Role, role)] : [new(ClaimTypes.NameIdentifier, user.Id.ToString()), new(ClaimTypes.Role, role)];
        return new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity(claims, "test")) } } };
    }

    [Fact]
    public async Task Failure_is_logged_and_rethrown_for_retry()
    {
        using var db = TestData.Db(out var seed);
        var job = Job(db, new FakeEmail { Fail = true });
        await Assert.ThrowsAsync<InvalidOperationException>(() => job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.PaymentFailed) with { DedupeKey = "k" }, CancellationToken.None));
        var log = await db.NotificationLogs.SingleAsync();
        Assert.False(log.Success); Assert.Equal("SMTP caído", log.Error);
        Assert.False(await NotificationJob.AlreadySentAsync(db, "k", CancellationToken.None)); // un fallo no bloquea el reintento
    }

    [Fact]
    public async Task Inactive_clients_are_skipped()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.IsActive = false; await db.SaveChangesAsync();
        var email = new FakeEmail();
        await Job(db, email).SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.PaymentFailed), CancellationToken.None);
        Assert.Empty(email.Sent);
    }

    [Fact]
    public void Notification_survives_hangfire_serialization()
    {
        var original = EmailTemplatesTests.Sample(NotificationType.RenewalReminder) with { DedupeKey = "renewal:x" };
        var copy = SerializationHelper.Deserialize<Notification>(SerializationHelper.Serialize(original, SerializationOption.User), SerializationOption.User);
        Assert.Equal(original.Type, copy.Type); Assert.Equal(original.DedupeKey, copy.DedupeKey); Assert.Equal(original.Data, copy.Data);
    }

    internal static NotificationJob Job(RtresDbContext db, IEmailSender email) =>
        new(db, email, new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Frontend:PortalUrl"] = "https://portal.rtres.net" }).Build(), NullLogger<NotificationJob>.Instance);
}

public class RenewalReminderJobTests
{
    private static readonly DateTime Now = new(2026, 9, 1, 13, 0, 0, DateTimeKind.Utc);

    [Theory]
    [InlineData(40, null)]
    [InlineData(30, 30)]
    [InlineData(20, 30)]
    [InlineData(7, 7)]
    [InlineData(5, 7)]
    [InlineData(1, 1)]
    [InlineData(0, 1)]
    [InlineData(-1, null)]
    public async Task Picks_the_right_threshold(int daysLeft, int? expectedThreshold)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, Now.Date.AddDays(daysLeft));
        var email = new FakeEmail();
        await new RenewalReminderJob(db, new InlineNotifications(db, email)).SendAsync(Now, CancellationToken.None);

        if (expectedThreshold is null) { Assert.Empty(email.Sent); return; }
        Assert.Single(email.Sent);
        Assert.Equal($"renewal:{item.Id}:{item.RenewsAt:yyyyMMdd}:{expectedThreshold}", (await db.NotificationLogs.SingleAsync()).DedupeKey);
        Assert.Equal(ClientProductStatus.PorVencer, item.Status);
    }

    [Fact]
    public async Task Each_threshold_is_sent_once()
    {
        using var db = TestData.Db(out var seed);
        AddProduct(db, seed, Now.Date.AddDays(10));
        var email = new FakeEmail();
        var job = new RenewalReminderJob(db, new InlineNotifications(db, email));
        await job.SendAsync(Now, CancellationToken.None);               // 10 días → aviso de 30
        await job.SendAsync(Now.AddHours(2), CancellationToken.None);   // mismo día → nada
        await job.SendAsync(Now.AddDays(1), CancellationToken.None);    // 9 días → sigue en la ventana de 30
        await job.SendAsync(Now.AddDays(3), CancellationToken.None);    // 7 días → aviso de 7
        await job.SendAsync(Now.AddDays(9), CancellationToken.None);    // 1 día → aviso de 1
        Assert.Equal(3, email.Sent.Count);
    }

    [Theory]
    [InlineData(ClientProductStatus.Activo, -1, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.PorVencer, -3, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.Activo, 0, ClientProductStatus.PorVencer)] // vence hoy: aún se puede renovar
    [InlineData(ClientProductStatus.Cancelado, -1, ClientProductStatus.Cancelado)]
    [InlineData(ClientProductStatus.Pendiente, -1, ClientProductStatus.Pendiente)]
    public async Task Marks_products_past_their_date_as_expired(ClientProductStatus status, int daysLeft, ClientProductStatus expected)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, Now.Date.AddDays(daysLeft));
        item.Status = status; db.SaveChanges();
        await new RenewalReminderJob(db, new InlineNotifications(db, new FakeEmail())).SendAsync(Now, CancellationToken.None);
        Assert.Equal(expected, (await db.ClientProducts.AsNoTracking().SingleAsync(x => x.Id == item.Id)).Status);
    }

    [Theory]
    [InlineData(ClientProductStatus.Vencido, 60, ClientProductStatus.Activo)]
    [InlineData(ClientProductStatus.Activo, 10, ClientProductStatus.PorVencer)]
    [InlineData(ClientProductStatus.Activo, -2, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.Pendiente, 10, ClientProductStatus.Pendiente)]
    [InlineData(ClientProductStatus.Cancelado, -2, ClientProductStatus.Cancelado)]
    public void Status_follows_the_renewal_date(ClientProductStatus current, int daysLeft, ClientProductStatus expected) =>
        Assert.Equal(expected, RenewalReminderJob.StatusFor(current, Now.Date.AddDays(daysLeft), Now));

    [Fact]
    public void Status_is_unchanged_without_a_renewal_date() =>
        Assert.Equal(ClientProductStatus.Vencido, RenewalReminderJob.StatusFor(ClientProductStatus.Vencido, null, Now));

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, DateTime renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Status = ClientProductStatus.Activo, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, DomainName = "cabalgatasandinas.com" };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}

internal sealed class FakeEmail : IEmailSender
{
    public bool Fail { get; init; }
    public List<EmailMessage> Sent { get; } = [];
    public Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        if (Fail) throw new InvalidOperationException("SMTP caído");
        Sent.Add(message); return Task.CompletedTask;
    }
}

/// <summary>Ejecuta el <see cref="NotificationJob"/> en línea (sin Hangfire) para probar el flujo completo con log y dedupe.</summary>
internal sealed class InlineNotifications(RtresDbContext db, IEmailSender email) : INotificationSender
{
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default) =>
        NotificationJobTests.Job(db, email).SendAsync(client.Id, notification, cancellationToken);
}
ParseOptions.0.json��
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\PayPalPaymentTests.cs��using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PayPalPaymentTests
{
    [Fact]
    public async Task Captured_prepaid_order_extends_the_years_it_was_created_for()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-3Y");
        item.PayPalOrderYears = 3; db.SaveChanges();
        await Webhook(db, new FakePayPal(), new FakeNotifications(), Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-3Y"}""", item));
        Assert.InRange(item.RenewsAt!.Value, DateTime.UtcNow.AddYears(3).AddMinutes(-1), DateTime.UtcNow.AddYears(3).AddMinutes(1));
        Assert.Equal(3, (await db.PaymentTransactions.SingleAsync()).Years);
    }

    [Fact]
    public async Task Approved_order_is_captured_and_activated_once()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        var payPal = new FakePayPal();
        var notifications = new FakeNotifications();

        await Webhook(db, payPal, notifications, Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-1","purchase_units":[{"custom_id":"ITEM"}]}""", item));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        var renewsAt = item.RenewsAt!.Value;
        Assert.InRange(renewsAt, DateTime.UtcNow.AddYears(1).AddMinutes(-1), DateTime.UtcNow.AddYears(1).AddMinutes(1));

        // PayPal también avisa de la captura: el mismo cobro no se vuelve a aplicar (ni otro año, ni otra transacción).
        await Webhook(db, payPal, notifications, Event("WH-2", "PAYMENT.CAPTURE.COMPLETED", """{"id":"CAP-1","custom_id":"ITEM","amount":{"value":"120.00","currency_code":"USD"},"supplementary_data":{"related_ids":{"order_id":"ORD-1"}}}""", item));
        Assert.Equal(renewsAt, (await db.ClientProducts.SingleAsync()).RenewsAt);
        var transaction = await db.PaymentTransactions.SingleAsync();
        Assert.Equal(("ORD-1", 120m, "USD"), (transaction.PayPalOrderIdOrSubscriptionId, transaction.Amount, transaction.Currency));
        var paid = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.PaymentReceived, paid.Type); Assert.Equal("payment:ORD-1", paid.DedupeKey);
    }

    [Fact]
    public async Task Approval_alone_does_not_activate_when_capture_is_not_completed()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        await Webhook(db, new FakePayPal { CaptureStatus = "PENDING" }, new FakeNotifications(), Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-1"}""", item));
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
        Assert.Null(item.RenewsAt);
        Assert.Empty(db.PaymentTransactions);
    }

    [Fact]
    public async Task Return_page_capture_is_idempotent_and_one_time_products_get_no_expiry()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Unico, orderId: "ORD-9");
        var payPal = new FakePayPal();
        var controller = Controller(db, payPal, new FakeNotifications());
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        await controller.Capture(item.Id, null, CancellationToken.None);
        await controller.Capture(item.Id, null, CancellationToken.None);

        Assert.Equal(1, payPal.Captures);
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Null(item.RenewsAt);
        Assert.Single(db.PaymentTransactions);
    }

    [Fact]
    public async Task Denied_payment_notifies_failure()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        var notifications = new FakeNotifications();
        await Webhook(db, new FakePayPal(), notifications, Event("WH-3", "PAYMENT.CAPTURE.DENIED", """{"id":"CAP-2","custom_id":"ITEM"}""", item));
        var failed = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.PaymentFailed, failed.Type); Assert.Equal("payment-failed:WH-3", failed.DedupeKey);
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
    }

    [Theory]
    [InlineData(BillingCycle.Anual, 30, 365 + 30)]   // renovación anticipada: suma desde el vencimiento actual
    [InlineData(BillingCycle.Anual, -10, 365)]       // ya vencido: suma desde hoy
    [InlineData(BillingCycle.Anual, null, 365)]      // primera compra
    public void Annual_period_extends_from_the_right_date(BillingCycle cycle, int? renewsInDays, int expectedDays)
    {
        var now = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        var item = new ClientProduct { BillingCycle = cycle, RenewsAt = renewsInDays is int d ? now.AddDays(d) : null };
        PayPalPaymentService.ExtendPeriod(item, now);
        Assert.Equal(expectedDays, (item.RenewsAt!.Value - now).Days);
    }

    [Fact]
    public void Monthly_sets_next_charge_and_one_time_sets_nothing()
    {
        var now = new DateTime(2026, 1, 31, 0, 0, 0, DateTimeKind.Utc);
        var monthly = new ClientProduct { BillingCycle = BillingCycle.Mensual };
        PayPalPaymentService.ExtendPeriod(monthly, now);
        Assert.Equal(new DateTime(2026, 2, 28, 0, 0, 0, DateTimeKind.Utc), monthly.NextChargeAt);
        Assert.Null(monthly.RenewsAt);

        var once = new ClientProduct { BillingCycle = BillingCycle.Unico };
        PayPalPaymentService.ExtendPeriod(once, now);
        Assert.Null(once.RenewsAt); Assert.Null(once.NextChargeAt);
    }

    [Fact]
    public void Parses_paypal_capture_response()
    {
        const string json = """
        {"id":"ORD-1","status":"COMPLETED","purchase_units":[{"reference_id":"default","payments":{"captures":[
          {"id":"CAP-1","status":"COMPLETED","amount":{"currency_code":"EUR","value":"99.90"}}]}}]}
        """;
        Assert.Equal(new PayPalCapture("ORD-1", "COMPLETED", 99.90m, "EUR"), PayPalClient.ParseCapture("ORD-1", json));
        Assert.Equal(new PayPalCapture("ORD-2", "APPROVED", null, null), PayPalClient.ParseCapture("ORD-2", """{"id":"ORD-2","status":"APPROVED"}"""));
    }

    [Fact]
    public async Task Reconciliation_records_the_first_charge_that_arrives_after_activation()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        item.PayPalSubscriptionId = "SUB-7"; db.SaveChanges();
        var next = new DateTime(2026, 10, 28, 10, 0, 0, DateTimeKind.Utc);
        var payPal = new FakePayPal { Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, []) };
        var notifications = new FakeNotifications();
        var service = new PayPalPaymentService(db, payPal, notifications, TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

        await service.ConfirmAsync(item, CancellationToken.None); // vuelta de PayPal: activa pero el cobro aún no existe
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Empty(db.PaymentTransactions);

        payPal.Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, [new("SALE-1", 90m, "USD")]); // minutos después
        var job = new PayPalReconciliationJob(db, service, NullLogger<PayPalReconciliationJob>.Instance);
        await job.ReconcileAsync(CancellationToken.None);
        await job.ReconcileAsync(CancellationToken.None);
        Assert.Equal("SALE-1", (await db.PaymentTransactions.SingleAsync()).PayPalOrderIdOrSubscriptionId);
        Assert.Equal(next, item.NextChargeAt);
        Assert.Single(notifications.Sent);
    }

    [Fact]
    public async Task Reconciliation_cancels_subscriptions_cancelled_in_paypal_and_survives_errors()
    {
        using var db = TestData.Db(out var seed);
        var broken = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        var cancelled = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        broken.PayPalSubscriptionId = "SUB-X"; cancelled.PayPalSubscriptionId = "SUB-C";
        broken.Status = cancelled.Status = ClientProductStatus.Activo; db.SaveChanges();
        var payPal = new FakePayPal();
        payPal.Subscriptions["SUB-X"] = null; // PayPal falla para esta
        payPal.Subscriptions["SUB-C"] = new PayPalSubscriptionInfo("SUB-C", "CANCELLED", null, []);

        await new PayPalReconciliationJob(db, new PayPalPaymentService(db, payPal, new FakeNotifications(), TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance), NullLogger<PayPalReconciliationJob>.Instance).ReconcileAsync(CancellationToken.None);

        Assert.Equal(ClientProductStatus.Activo, broken.Status);
        Assert.Equal(ClientProductStatus.Cancelado, cancelled.Status);
    }

    [Theory]
    [InlineData(20, true)]    // vence dentro de 30 días: se puede pagar la renovación aunque siga "Activo"
    [InlineData(60, false)]   // aún falta mucho
    public async Task Renewal_can_be_paid_within_30_days_of_expiry(int daysLeft, bool allowed)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-OLD");
        item.Status = ClientProductStatus.Activo; item.RenewsAt = DateTime.UtcNow.AddDays(daysLeft); db.SaveChanges();
        var controller = Controller(db, new FakePayPal(), new FakeNotifications());
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var result = await controller.Renew(item.Id, null, CancellationToken.None);

        Assert.Equal(allowed, result is OkObjectResult);
        Assert.Equal(allowed ? "ORD-NEW" : "ORD-OLD", item.PayPalOrderId);
    }

    [Fact]
    public async Task One_time_products_are_never_renewed()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Unico, orderId: "ORD-OLD");
        item.Status = ClientProductStatus.Vencido; item.RenewsAt = DateTime.UtcNow.AddDays(-3); db.SaveChanges();
        var controller = Controller(db, new FakePayPal(), new FakeNotifications());
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));
        Assert.IsType<BadRequestObjectResult>(await controller.Renew(item.Id, null, CancellationToken.None));
    }

    [Fact]
    public async Task Billing_shows_own_payments_to_clients_and_all_or_selected_to_superadmin()
    {
        using var db = TestData.Db(out var seed);
        var mine = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-A");
        var otherClient = new Client { CompanyName = "Selva Viva", Email = "s@example.com" };
        var otherProject = new Project { ClientId = otherClient.Id, Name = "Selva", Slug = "selva" };
        db.AddRange(otherClient, otherProject); db.SaveChanges();
        var theirs = AddProduct(db, new Seed(otherClient, otherProject, seed.Ticket, seed.User), BillingCycle.Anual, orderId: "ORD-B");
        db.PaymentTransactions.AddRange(new PaymentTransaction { ClientId = seed.Client.Id, ClientProductId = mine.Id, PayPalOrderIdOrSubscriptionId = "ORD-A", Amount = 120, InternalCode = "RT-INT-000001" }, new PaymentTransaction { ClientId = otherClient.Id, ClientProductId = theirs.Id, PayPalOrderIdOrSubscriptionId = "ORD-B", Amount = 120, InternalCode = "RT-INT-000002" });
        db.SaveChanges();

        async Task<int> Count(ClaimsPrincipal user, Guid? clientId)
        {
            var controller = new AccountController(db, ClientOnboardingTests.AccessEmail(db, new FakeEmail())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = user } } };
            var ok = Assert.IsType<OkObjectResult>(await controller.Transactions(clientId, CancellationToken.None));
            return ((System.Collections.IEnumerable)ok.Value!).Cast<object>().Count();
        }
        var client = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));
        var superAdmin = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.Role, "SuperAdmin")], "test"));

        Assert.Equal(1, await Count(client, otherClient.Id));   // un cliente no puede ver pagos ajenos pasando clientId
        Assert.Equal(2, await Count(superAdmin, null));          // SuperAdmin sin selección: todos
        Assert.Equal(1, await Count(superAdmin, otherClient.Id)); // SuperAdmin con cliente seleccionado
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, BillingCycle cycle, string? orderId)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = cycle, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = cycle, Price = 120, PayPalOrderId = orderId };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static string Event(string id, string type, string resource, ClientProduct item) =>
        $$"""{"id":"{{id}}","event_type":"{{type}}","resource":{{resource.Replace("ITEM", item.Id.ToString())}}}""";

    internal static PaymentsController PaymentsControllerFor(RtresDbContext db, INotificationSender? notifications = null) => Controller(db, new FakePayPal(), notifications ?? new FakeNotifications());

    private static PaymentsController Controller(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["BankTransfer:Instructions"] = "BCP Soles 123-456", ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        return new(db, payPal, new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build()), new PayPalPaymentService(db, payPal, notifications, TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance), new BankTransferService(db, config), notifications, config, NullLogger<PaymentsController>.Instance)
        { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
    }

    private static async Task Webhook(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications, string json)
    {
        var controller = Controller(db, payPal, notifications);
        controller.ControllerContext.HttpContext.Request.Body = new MemoryStream(Encoding.UTF8.GetBytes(json));
        Assert.IsType<OkResult>(await controller.Webhook(CancellationToken.None));
    }

    [Fact]
    public async Task Checkout_returns_to_the_calling_portal_and_reuses_the_monthly_plan()
    {
        using var db = TestData.Db(out var seed);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var product = new Product { Name = "Soporte mensual", BillingCycle = BillingCycle.Mensual, BasePrice = 90 };
        var local = new DefaultHttpContext().Request; local.Headers.Origin = "http://localhost:4200";
        var evil = new DefaultHttpContext().Request; evil.Headers.Origin = "https://evil.example";

        var first = new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 90 };
        await checkout.StartAsync(first, product, local, CancellationToken.None);
        var second = new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 90 };
        await checkout.StartAsync(second, product, evil, CancellationToken.None);

        Assert.Equal(["http://localhost:4200/billing/return", "https://portal.rtres.net/billing/return"], payPal.ReturnUrls.Select(x => x.Split('?')[0]));
        Assert.Equal(1, payPal.PlansCreated); // mismo precio base → mismo plan
        Assert.Equal("PLAN-1", first.PayPalPlanId); Assert.Equal("PLAN-1", second.PayPalPlanId); Assert.Equal("SUB-1", first.PayPalSubscriptionId);

        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 20 }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-1", 2), (product.PayPalPlanId, payPal.PlansCreated)); // descuento → plan propio, el del producto no cambia
        Assert.Equal((90m, (decimal?)70m), payPal.Plans[^1]); // solo el primer mes rebajado, luego precio de catálogo
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = -20 }, product, local, CancellationToken.None);
        Assert.Equal((90m, (decimal?)110m), payPal.Plans[^1]); // recargo: solo el primer mes más caro
        product.BasePrice = 95;
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-4", 95m), (product.PayPalPlanId, product.PayPalPlanPrice)); // cambió el precio base → plan nuevo

        await Assert.ThrowsAsync<InvalidOperationException>(() => checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 95 }, product, local, CancellationToken.None));
    }

    [Fact]
    public async Task Bimonthly_quarterly_and_semiannual_cycles_are_subscriptions_every_2_3_and_6_months()
    {
        using var db = TestData.Db(out _);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var quarterly = new Product { Name = "Soporte", BillingCycle = BillingCycle.Trimestral, BasePrice = 250 };

        var item = new ClientProduct { BillingCycle = BillingCycle.Trimestral };
        await checkout.StartAsync(item, quarterly, null, CancellationToken.None);
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Trimestral }, quarterly, null, CancellationToken.None);
        Assert.Equal(("SUB-1", "PLAN-1", 1), (item.PayPalSubscriptionId, quarterly.PayPalPlanId, payPal.PlansCreated)); // suscripción, plan del catálogo reutilizado
        Assert.Empty(payPal.OrderAmounts);

        // Mismo producto asignado con otro ciclo: plan propio, el del catálogo (trimestral) no se toca.
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Semestral }, quarterly, null, CancellationToken.None);
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Bimestral }, quarterly, null, CancellationToken.None);
        Assert.Equal([3, 6, 2], payPal.PlanMonths); Assert.Equal("PLAN-1", quarterly.PayPalPlanId);

        var now = new DateTime(2026, 1, 31, 0, 0, 0, DateTimeKind.Utc);
        foreach (var (cycle, next) in new[] { (BillingCycle.Bimestral, new DateTime(2026, 3, 31)), (BillingCycle.Trimestral, new DateTime(2026, 4, 30)), (BillingCycle.Semestral, new DateTime(2026, 7, 31)) })
        {
            var paid = new ClientProduct { BillingCycle = cycle };
            PayPalPaymentService.ExtendPeriod(paid, now);
            Assert.Equal((next, (DateTime?)null), (paid.NextChargeAt!.Value.Date, paid.RenewsAt));
            Assert.NotNull(paid.ValidateYears(2)); // varios años por adelantado: solo Anual
        }
    }

    [Fact]
    public async Task Paypal_charges_add_igv_for_peruvian_invoices()
    {
        using var db = TestData.Db(out _);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var annual = new Product { Name = "Hosting", BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Anual }, annual, null, CancellationToken.None, 0.18m);
        Assert.Equal(141.60m, payPal.OrderAmounts.Single());

        // Tres años por adelantado: una sola orden por el total, y la orden recuerda los años para cuando se capture.
        var prepaid = new ClientProduct { BillingCycle = BillingCycle.Anual };
        await checkout.StartAsync(prepaid, annual, null, CancellationToken.None, 0.18m, years: 3);
        Assert.Equal((424.80m, (int?)3), (payPal.OrderAmounts[^1], prepaid.PayPalOrderYears));

        // Mensual con descuento de 20: primer mes (100 + IGV) = 118, luego catálogo (120 + IGV) = 141.60.
        var monthly = new Product { Name = "Soporte", BillingCycle = BillingCycle.Mensual, BasePrice = 120 };
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 20 }, monthly, null, CancellationToken.None, 0.18m);
        Assert.Equal((141.60m, (decimal?)118m), payPal.Plans[^1]);
    }

    [Fact]
    public async Task Active_subscription_is_confirmed_without_webhook_and_its_sales_are_not_duplicated()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        item.PayPalSubscriptionId = "SUB-7"; db.SaveChanges();
        var next = new DateTime(2026, 11, 1, 10, 0, 0, DateTimeKind.Utc);
        var payPal = new FakePayPal { Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, [new("SALE-1", 90m, "USD")]) };
        var notifications = new FakeNotifications();
        var controller = Controller(db, payPal, notifications);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        await controller.Capture(item.Id, null, CancellationToken.None);
        Assert.Equal((ClientProductStatus.Activo, next), (item.Status, item.NextChargeAt));
        Assert.Equal("SALE-1", (await db.PaymentTransactions.SingleAsync()).PayPalOrderIdOrSubscriptionId);

        // Llega después el webhook del mismo cobro: se encuentra el producto por billing_agreement_id y no se duplica.
        await Webhook(db, payPal, notifications, Event("WH-9", "PAYMENT.SALE.COMPLETED", """{"id":"SALE-1","billing_agreement_id":"SUB-7","amount":{"total":"90.00","currency":"USD"}}""", item));
        Assert.Single(db.PaymentTransactions);
        Assert.Single(notifications.Sent);

        // El cobro del mes siguiente solo llega por webhook y sí se registra.
        await Webhook(db, payPal, notifications, Event("WH-10", "PAYMENT.SALE.COMPLETED", """{"id":"SALE-2","billing_agreement_id":"SUB-7","amount":{"total":"90.00","currency":"USD"}}""", item));
        Assert.Equal(2, await db.PaymentTransactions.CountAsync());
    }

    [Fact]
    public void Parses_paypal_subscription_and_transactions()
    {
        var info = PayPalClient.ParseSubscription(
            """{"id":"SUB-7","status":"ACTIVE","billing_info":{"next_billing_time":"2026-11-01T10:00:00Z"}}""",
            """{"transactions":[{"id":"SALE-1","status":"COMPLETED","amount_with_breakdown":{"gross_amount":{"currency_code":"USD","value":"90.00"}},"time":"2026-10-01T10:00:00Z"},{"id":"SALE-0","status":"DECLINED","amount_with_breakdown":{"gross_amount":{"currency_code":"USD","value":"90.00"}}}]}""");
        Assert.Equal(("SUB-7", "ACTIVE", new DateTime(2026, 11, 1, 10, 0, 0, DateTimeKind.Utc)), (info.Id, info.Status, info.NextBillingTime));
        Assert.Equal([new PayPalSubscriptionPayment("SALE-1", 90m, "USD")], info.Payments);
    }

    private sealed class FakePayPal : IPayPalClient
    {
        public string CaptureStatus { get; init; } = "COMPLETED";
        public int Captures { get; private set; }
        public int PlansCreated { get; private set; }
        public List<int> PlanMonths { get; } = [];
        public List<string> ReturnUrls { get; } = [];
        public PayPalSubscriptionInfo? Subscription { get; set; }
        public Dictionary<string, PayPalSubscriptionInfo?> Subscriptions { get; } = [];
        public List<(decimal Price, decimal? FirstCycle)> Plans { get; } = [];
        public Task<string> CreatePlanAsync(string name, decimal price, string currency, int intervalMonths, decimal? firstCyclePrice = null, CancellationToken cancellationToken = default) { Plans.Add((price, firstCyclePrice)); PlanMonths.Add(intervalMonths); return Task.FromResult($"PLAN-{++PlansCreated}"); }
        public Task<PayPalSubscriptionInfo> GetSubscriptionAsync(string subscriptionId, CancellationToken cancellationToken = default) =>
            Subscriptions.TryGetValue(subscriptionId, out var info) ? (info is null ? throw new HttpRequestException("PayPal caído") : Task.FromResult(info)) : Task.FromResult(Subscription!);
        public Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default)
        {
            Captures++;
            return Task.FromResult(new PayPalCapture(orderId, CaptureStatus, CaptureStatus == "COMPLETED" ? 120m : null, "USD"));
        }
        public List<decimal> OrderAmounts { get; } = [];
        public Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); OrderAmounts.Add(amount); return Task.FromResult(new PayPalCheckout("ORD-NEW", "https://paypal/approve")); }
        public Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); return Task.FromResult(new PayPalCheckout($"SUB-{ReturnUrls.Count}", "https://paypal/approve")); }
        public Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default) => Task.FromResult(true);
    }

    internal static TaxDocumentService TaxDocuments(RtresDbContext db) => new(db, NullLogger<TaxDocumentService>.Instance);
}
ParseOptions.0.json�#
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\PrepaidYearsTests.cs�"using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PrepaidYearsTests
{
    [Fact]
    public async Task Three_years_paid_at_once_extend_three_years_with_one_payment_and_one_invoice()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var renewsAt = new DateTime(2026, 10, 15, 12, 0, 0, DateTimeKind.Utc);
        var item = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.PorVencer, renewsAt);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges(); // descuento del periodo actual: ya usado

        var ok = Assert.IsType<OkObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, new DateOnly(2026, 9, 20), "OP-1", Years: 3), Payments(db), CancellationToken.None));
        Assert.Equal(renewsAt.AddYears(3), item.RenewsAt); // desde el vencimiento actual, sin perder días
        var tx = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((3, 424.80m), (tx.Years, tx.Amount)); // 3 × 120 + IGV (el descuento ya se había usado)
        var invoice = await db.TaxDocuments.SingleAsync();
        Assert.Equal((360m, 64.80m), (invoice.BaseAmount, invoice.IgvAmount));
        Assert.Contains("3 años", invoice.Notes);
        Assert.Null(item.Discount); // la renovación quitó el descuento
    }

    [Fact]
    public async Task Pending_discount_only_lowers_the_first_of_the_prepaid_years()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges();
        Assert.Equal(340m, item.ChargeTotal(0m, 3)); // 100 + 120 + 120

        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 340m, "USD", CancellationToken.None, PaymentMethods.Transferencia, new DateTime(2026, 9, 1, 12, 0, 0, DateTimeKind.Utc), years: 3);
        Assert.Equal(new DateTime(2029, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.RenewsAt);
        Assert.Equal(new DateTime(2027, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.DiscountEndsAt); // el descuento cubre solo el primer año
        Assert.Equal(120m, item.CurrentPrice(new DateTime(2028, 1, 1, 0, 0, 0, DateTimeKind.Utc)));
    }

    [Fact]
    public async Task Only_annual_products_accept_several_years_and_at_most_five()
    {
        using var db = TestData.Db(out var seed);
        var monthly = AddProduct(db, seed, BillingCycle.Mensual, ClientProductStatus.Activo, null);
        var annual = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.Activo, DateTime.UtcNow.AddDays(10));
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(monthly.Id, new TransferPaymentRequest(null, null, null, Years: 2), Payments(db), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(annual.Id, new TransferPaymentRequest(null, null, null, Years: 6), Payments(db), CancellationToken.None));
        Assert.Empty(db.PaymentTransactions);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, BillingCycle cycle, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = cycle, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = cycle, RenewsAt = renewsAt, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�.
AC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\PurchasesTests.cs�-using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PurchasesTests
{
    const int Year = 2026;
    const string Ruc = "20100070970";

    static PurchaseRequest Factura(string number, decimal taxBase, decimal igv, int month = 1, PurchaseDocumentType type = PurchaseDocumentType.Factura, bool createExpense = false, string currency = "PEN") =>
        new(new DateOnly(Year, month, 10), null, type, "F001", number, Ruc, "Proveedor SAC", currency, taxBase, igv, CreateExpense: createExpense, ExpenseCategoryId: ExpenseCategoryIds.Hosting);

    [Fact]
    public async Task Purchase_is_validated_and_its_linked_expense_excludes_recoverable_igv()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18) with { SupplierTaxId = "123" }, CancellationToken.None)); // RUC inválido
        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18, type: PurchaseDocumentType.Boleta), CancellationToken.None)); // boleta sin IGV
        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18) with { Period = "2025-12" }, CancellationToken.None)); // antes de la emisión

        Assert.IsType<CreatedResult>(await admin.CreatePurchase(Factura("00001", 100, 18, createExpense: true), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18), CancellationToken.None)); // mismo comprobante (ceros a la izquierda)

        var purchase = await db.Purchases.SingleAsync();
        Assert.Equal((118m, true, new DateOnly(Year, 1, 1)), (purchase.Total, purchase.GivesTaxCredit, purchase.Period));
        var expense = await db.Expenses.SingleAsync();
        Assert.Equal((purchase.ExpenseId, 100m, ExpenseCategoryIds.Hosting), (expense.Id, expense.Amount, expense.CategoryId)); // el IGV recuperable no es gasto

        // Sin destino a operaciones gravadas no hay crédito fiscal: el gasto pasa a ser el total.
        Assert.IsType<OkObjectResult>(await admin.UpdatePurchase(purchase.Id, Factura("1", 100, 18) with { UsedForTaxedOperations = false }, CancellationToken.None));
        Assert.Equal((false, 118m), (purchase.GivesTaxCredit, (await db.Expenses.SingleAsync()).Amount));

        Assert.IsType<NoContentResult>(await admin.DeletePurchase(purchase.Id, deleteExpense: true, CancellationToken.None));
        Assert.False(await db.Purchases.AnyAsync() || await db.Expenses.AnyAsync());
    }

    [Fact]
    public async Task Igv_cascade_carries_the_credit_balance_to_the_next_month()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        AddFacturaSale(db, seed.Client.Id, new DateOnly(Year, 1, 15), 1000m, 180m, 1);
        AddFacturaSale(db, seed.Client.Id, new DateOnly(Year, 2, 15), 1000m, 180m, 2);
        await admin.CreatePurchase(Factura("10", 1666.67m, 300m), CancellationToken.None);                                        // enero: crédito 300
        await admin.CreatePurchase(Factura("11", 111.11m, 20m, month: 2, type: PurchaseDocumentType.NotaCredito), CancellationToken.None); // febrero: la nota de crédito resta 20

        var january = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(1, Year, CancellationToken.None)).Value!);
        Assert.Equal((180m, 300m, 0m, 0m, 120m), (P(january, "debitoFiscal"), P(january, "creditoFiscal"), P(january, "saldoAFavorAnterior"), P(january, "igvAPagar"), P(january, "saldoAFavorSiguiente")));

        var february = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(2, Year, CancellationToken.None)).Value!);
        Assert.Equal((180m, -20m, 120m, 80m, 0m), (P(february, "debitoFiscal"), P(february, "creditoFiscal"), P(february, "saldoAFavorAnterior"), P(february, "igvAPagar"), P(february, "saldoAFavorSiguiente")));

        var year = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(null, Year, CancellationToken.None)).Value!);
        Assert.Equal((360m, 280m, 80m), (P(year, "debitoFiscal"), P(year, "creditoFiscal"), P(year, "igvAPagar")));

        var list = Assert.IsType<OkObjectResult>(await admin.Purchases(Year, 2, CancellationToken.None)).Value!;
        Assert.Equal(-20m, P(list, "creditoFiscalPen"));
    }

    private static void AddFacturaSale(RtresDbContext db, Guid clientId, DateOnly date, decimal baseAmount, decimal igv, int number)
    {
        var payment = new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = baseAmount + igv, Currency = "PEN", AmountPen = baseAmount + igv, Status = "COMPLETED", Method = PaymentMethods.Transferencia, CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) };
        db.PaymentTransactions.Add(payment);
        db.TaxDocuments.Add(new TaxDocument { PaymentTransactionId = payment.Id, ClientId = clientId, Type = TaxDocumentType.Factura, Series = "E001", Number = number, IssueDate = date, Currency = "PEN", BaseAmount = baseAmount, IgvAmount = igv, TotalAmount = baseAmount + igv });
        db.SaveChanges();
    }

    private static object Igv(object report) => report.GetType().GetProperty("igv")!.GetValue(report)!;
    private static decimal P(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
ParseOptions.0.json�
CC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\SalesReportTests.cs�using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class SalesReportTests
{
    [Fact]
    public async Task Igv_comes_only_from_invoices_and_is_already_inside_what_was_charged()
    {
        using var db = TestData.Db(out var seed);
        var today = DateTime.UtcNow;
        db.ExchangeRates.Add(new ExchangeRate { Date = DateOnly.FromDateTime(today), CurrencyCode = "USD", RateToPen = 3.75m, Source = "SUNAT" });
        seed.Client.RequiresTaxDocument = true;
        var foreign = new Client { CompanyName = "Roma Srl", Email = "info@roma.it" };
        var foreignProject = new Project { ClientId = foreign.Id, Name = "Web", Slug = "roma-web" };
        db.AddRange(foreign, foreignProject); db.SaveChanges();
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

        // Cliente en Perú con Factura: 118 PEN cobrados = base 100 + IGV 18.
        await payments.ApplyPaymentAsync(AddProduct(db, seed.Client.Id, seed.Project.Id, TaxDocumentType.Factura), "ORD-PE", 118m, "PEN", CancellationToken.None);
        // Cliente del exterior: 100 USD = 375 PEN, sin IGV ni comprobante.
        await payments.ApplyPaymentAsync(AddProduct(db, foreign.Id, foreignProject.Id, TaxDocumentType.Factura), "ORD-IT", 100m, "USD", CancellationToken.None);
        // Recibo por honorarios emitido a mano (cobro fuera del portal): 200 PEN sin IGV.
        var rxh = AddProduct(db, seed.Client.Id, seed.Project.Id, TaxDocumentType.ReciboPorHonorarios);
        var admin = Admin(db);
        Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(rxh.Id, DateOnly.FromDateTime(today), "PEN", 200m, null), CancellationToken.None));

        var sales = Assert.IsType<OkObjectResult>(await admin.SalesReport(today.Month, today.Year, "PEN", CancellationToken.None)).Value!;
        Assert.Equal((675m, 18m, 693m), (Prop(sales, "baseImponible"), Prop(sales, "igv"), Prop(sales, "total")));

        var tax = Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(today.Month, today.Year, CancellationToken.None)).Value!;
        // Pago a cuenta de la MYPE: 10 % de 475 (factura + exterior); el recibo por honorarios (200) es del titular como persona natural.
        Assert.Equal((100m, 575m, 18m, 47.5m), (Prop(tax, "ventasGravadasPen"), Prop(tax, "ventasNoGravadasPen"), Prop(tax, "igvEstimado"), Prop(tax, "rentaEstimada")));

        var net = Assert.IsType<OkObjectResult>(await admin.NetReport(today.Month, today.Year, CancellationToken.None)).Value!;
        Assert.Equal((675m, 47.5m, 627.5m), (Prop(net, "ventasPen"), Prop(net, "impuestosPen"), Prop(net, "utilidadNetaPen")));
    }

    private static ClientProduct AddProduct(RtresDbContext db, Guid clientId, Guid projectId, TaxDocumentType taxType)
    {
        var product = new Product { Name = taxType.ToString(), Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = clientId, ProjectId = projectId, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
}
ParseOptions.0.json�:
CC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\TaxCalendarTests.cs�9using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxCalendarTests
{
    [Fact]
    public void Seeded_2026_schedule_falls_on_business_days_after_each_period()
    {
        var rows = TaxDueDateSeed.Rows2026;
        Assert.Equal(12, rows.Length);
        foreach (var row in rows)
        {
            DateOnly[] dates = [row.Digit0, row.Digit1, row.Digit2And3, row.Digit4And5, row.Digit6And7, row.Digit8And9, row.GoodTaxpayer];
            Assert.All(dates, d => Assert.True(d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday), $"{row.Period:yyyy-MM}: {d} cae en fin de semana"));
            Assert.All(dates, d => Assert.Equal(row.Period.AddMonths(1).Month, d.Month));
            Assert.Equal(dates.Order(), dates); // el orden de las columnas es el orden de los vencimientos
        }
    }

    [Theory]
    [InlineData("20612345670", false, "2026-10-16")]
    [InlineData("20612345671", false, "2026-10-19")]
    [InlineData("10456789013", false, "2026-10-20")]
    [InlineData("20612345674", false, "2026-10-21")]
    [InlineData("20612345677", false, "2026-10-22")]
    [InlineData("20612345679", false, "2026-10-23")]
    [InlineData("20612345679", true, "2026-10-26")]
    [InlineData(null, true, "2026-10-26")]
    public void Due_date_follows_last_digit_of_the_ruc(string? ruc, bool goodTaxpayer, string expected)
    {
        var september = TaxDueDateSeed.Rows2026[8];
        Assert.Equal(DateOnly.Parse(expected), september.DueFor(ruc, goodTaxpayer));
    }

    [Fact]
    public void Without_ruc_there_is_no_due_date() => Assert.Null(TaxDueDateSeed.Rows2026[0].DueFor(null, false));

    [Fact]
    public async Task Reminder_is_sent_once_per_threshold_and_not_after_filing()
    {
        using var db = Db("20612345670"); // dígito 0: setiembre vence el viernes 16-10-2026
        var email = new FakeEmail();
        var job = Job(db, email);

        await job.SendAsync(Lima(2026, 10, 8), CancellationToken.None); // faltan 8 días: todavía no
        Assert.Empty(email.Sent);
        await job.SendAsync(Lima(2026, 10, 9), CancellationToken.None); // 7 días
        await job.SendAsync(Lima(2026, 10, 10), CancellationToken.None); // 6 días: mismo umbral, no repite
        Assert.Single(email.Sent);
        Assert.Contains("setiembre 2026", email.Sent[0].Subject);
        Assert.Equal("equipo@rtres.net", email.Sent[0].To);
        var bell = Assert.Single(await db.PortalNotifications.ToListAsync());
        Assert.True(bell.ForStaff);
        Assert.Equal(nameof(NotificationType.TaxDueReminder), bell.Type);

        await job.SendAsync(Lima(2026, 10, 15), CancellationToken.None); // 1 día
        Assert.Equal(2, email.Sent.Count);
        Assert.Contains("mañana", email.Sent[1].Subject);

        (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2026, 9, 1))).FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        await job.SendAsync(Lima(2026, 10, 16), CancellationToken.None); // vence hoy, pero ya se presentó
        Assert.Equal(2, email.Sent.Count);
    }

    [Fact]
    public async Task Failed_email_is_retried_without_duplicating_the_bell()
    {
        using var db = Db("20612345670");
        await Assert.ThrowsAsync<InvalidOperationException>(() => Job(db, new FakeEmail { Fail = true }).SendAsync(Lima(2026, 10, 16), CancellationToken.None));
        var email = new FakeEmail();
        await Job(db, email).SendAsync(Lima(2026, 10, 16), CancellationToken.None);
        Assert.Contains("hoy", Assert.Single(email.Sent).Subject);
        Assert.Single(await db.PortalNotifications.ToListAsync());
    }

    [Fact]
    public async Task No_reminders_without_ruc()
    {
        using var db = Db(null);
        var email = new FakeEmail();
        await Job(db, email).SendAsync(Lima(2026, 10, 16), CancellationToken.None);
        Assert.Empty(email.Sent);
    }

    [Fact]
    public async Task Calendar_shows_next_due_date_and_overdue_periods()
    {
        using var db = Db("20612345674"); // dígito 4: setiembre vence el 21-10-2026
        var calendar = new TaxCalendarController(db);
        var dto = await calendar.GetAsync(null, Lima(2026, 10, 7), CancellationToken.None);
        Assert.Equal(2026, dto.Year);
        Assert.Equal(12, dto.Rows.Count);
        Assert.Equal("2026-09", dto.Next!.Period);
        Assert.Equal(new DateOnly(2026, 10, 21), dto.Next.DueDate);
        Assert.Equal(8, dto.Overdue.Count); // enero–agosto sin marcar

        (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2026, 9, 1))).FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        dto = await calendar.GetAsync(null, Lima(2026, 10, 7), CancellationToken.None);
        Assert.Equal("2026-10", dto.Next!.Period); // octubre ya empezó: vence en noviembre

        Assert.True((await calendar.GetAsync(null, Lima(2026, 12, 2), CancellationToken.None)).MissingNextYear);
    }

    [Fact]
    public async Task Upsert_rejects_weekends_and_dates_outside_the_window()
    {
        using var db = Db("20612345670");
        var calendar = new TaxCalendarController(db);
        var ok = new TaxDueDateRequest(new(2027, 2, 15), new(2027, 2, 16), new(2027, 2, 17), new(2027, 2, 18), new(2027, 2, 19), new(2027, 2, 22), new(2027, 2, 23));
        Assert.IsType<OkObjectResult>(await calendar.Upsert("2027-01", ok, CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 2, 13) }, CancellationToken.None)); // sábado
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 1, 15) }, CancellationToken.None)); // dentro del periodo
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-13", ok, CancellationToken.None));
        Assert.IsType<OkObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 2, 12) }, CancellationToken.None)); // corrige la fila
        Assert.Equal(new DateOnly(2027, 2, 12), (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2027, 1, 1))).Digit0);
    }

    private static DateTime Lima(int year, int month, int day) => new(year, month, day, 13, 30, 0, DateTimeKind.Utc); // 8:30 en Lima

    private static TaxDueReminderJob Job(RtresDbContext db, FakeEmail email) =>
        new(db, Staff(db, email), NullLogger<TaxDueReminderJob>.Instance);

    internal static StaffNotifier Staff(RtresDbContext db, FakeEmail email) => new(db, email,
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build(), NullLogger<StaffNotifier>.Instance);

    private static RtresDbContext Db(string? ruc)
    {
        var db = TestData.Db(out _); // EnsureCreated siembra el cronograma 2026 (HasData)
        db.TaxSettings.Add(new TaxSettings { Ruc = ruc }); db.SaveChanges();
        return db;
    }
}
ParseOptions.0.json�5
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\TaxDocumentReversalTests.cs�4using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxDocumentReversalTests
{
    static readonly CancellationToken Ct = CancellationToken.None;

    [Fact]
    public async Task Reversal_removes_document_and_payment_restores_the_period_and_leaves_a_record()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var renewsAt = DateTime.UtcNow.AddMonths(6);
        item.RenewsAt = renewsAt; item.Status = ClientProductStatus.Activo; item.IsManualBilling = true; db.SaveChanges();
        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 236m, "PEN", Ct, PaymentMethods.Transferencia, years: 2);
        Assert.Equal(renewsAt.AddYears(2), item.RenewsAt);

        var result = await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Monto equivocado", false, null, Ct);

        Assert.NotNull(result);
        Assert.Empty(db.TaxDocuments); Assert.Empty(db.TaxDocumentLines); Assert.Empty(db.PaymentTransactions);
        Assert.Equal(renewsAt, item.RenewsAt);
        var record = db.PaymentReversals.Single();
        Assert.Equal(("TRF-1", 236m, "F001", 1, "Monto equivocado"), (record.PaymentKey, record.Amount, record.Series, record.Number, record.Reason));
    }

    [Fact]
    public async Task A_reversed_transfer_can_be_registered_again_but_a_paypal_charge_is_not_recreated()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        await payments.ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia);
        await payments.ApplyPaymentAsync(item, "SALE-1", 118m, "PEN", Ct);
        foreach (var document in db.TaxDocuments.ToList()) await Service(db).ReverseAsync(document.Id, "Error", false, null, Ct);

        Assert.True(await payments.ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia));
        Assert.False(await payments.ApplyPaymentAsync(item, "SALE-1", 118m, "PEN", Ct));
    }

    [Fact]
    public async Task Correlative_is_released_only_when_not_issued_and_last_of_the_series()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        await payments.ApplyPaymentAsync(item, "ORD-1", 118m, "PEN", Ct);
        await payments.ApplyPaymentAsync(item, "ORD-2", 118m, "PEN", Ct);
        await payments.ApplyPaymentAsync(item, "ORD-3", 118m, "PEN", Ct);
        Guid Doc(int number) => db.TaxDocuments.Single(x => x.Number == number).Id;

        Assert.False((await Service(db).ReverseAsync(Doc(1), "No es el último", true, null, Ct))!.NumberReleased);
        Assert.False((await Service(db).ReverseAsync(Doc(3), "Sí se emitió", false, null, Ct))!.NumberReleased);
        Assert.Equal(4, db.TaxSettings.Single().FacturaNextNumber);

        await payments.ApplyPaymentAsync(item, "ORD-4", 118m, "PEN", Ct);
        Assert.True((await Service(db).ReverseAsync(Doc(4), "No se emitió", true, null, Ct))!.NumberReleased);
        await payments.ApplyPaymentAsync(item, "ORD-5", 118m, "PEN", Ct);
        Assert.Equal(4, db.TaxDocuments.Single(x => x.Number > 2).Number);
    }

    [Fact]
    public async Task Internal_codes_do_not_repeat_after_deleting_a_payment_in_the_middle()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        foreach (var key in new[] { "ORD-1", "ORD-2", "ORD-3" }) await payments.ApplyPaymentAsync(item, key, 118m, "PEN", Ct);
        await Service(db).ReverseAsync(db.TaxDocuments.Single(x => x.Number == 2).Id, "Error", false, null, Ct);

        await payments.ApplyPaymentAsync(item, "ORD-4", 118m, "PEN", Ct);

        Assert.Equal("RT-INT-000004", db.PaymentTransactions.Single(x => x.PayPalOrderIdOrSubscriptionId == "ORD-4").InternalCode);
    }

    [Fact]
    public async Task First_payment_of_a_client_contracted_product_goes_back_to_pending_with_its_discount_unused()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        item.Discount = 10m; db.SaveChanges();
        await Payments(db).ApplyPaymentAsync(item, "ORD-1", 118m, "PEN", Ct);
        Assert.NotNull(item.DiscountEndsAt);

        await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Error", false, null, Ct);

        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
        Assert.Null(item.RenewsAt); Assert.Null(item.DiscountEndsAt); Assert.Equal(10m, item.Discount);
    }

    [Fact]
    public async Task Approved_transfer_report_is_rejected_so_the_client_can_report_again()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia);
        var payment = db.PaymentTransactions.Single();
        var report = new TransferReport { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 118m, Status = TransferReportStatus.Aprobado, PaymentTransactionId = payment.Id };
        db.TransferReports.Add(report); db.SaveChanges();

        await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Voucher falso", false, null, Ct);

        Assert.Equal((TransferReportStatus.Rechazado, "Pago extornado: Voucher falso", (Guid?)null), (report.Status, report.RejectionReason, report.PaymentTransactionId));
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
    }

    [Fact]
    public async Task Unknown_document_returns_null()
    {
        using var db = TestData.Db(out _);
        Assert.Null(await Service(db).ReverseAsync(Guid.NewGuid(), "Error", false, null, Ct));
    }

    private static TaxDocumentService Service(RtresDbContext db) => PayPalPaymentTests.TaxDocuments(db);
    private static PayPalPaymentService Payments(RtresDbContext db) => new(db, null!, new FakeNotifications(), Service(db), NullLogger<PayPalPaymentService>.Instance);

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed)
    {
        seed.Client.RequiresTaxDocument = true;
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = TaxDocumentType.Factura };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
ParseOptions.0.json�O
CC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\TaxDocumentTests.cs�Nusing Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxDocumentTests
{
    [Fact]
    public async Task Paid_product_of_a_peruvian_client_gets_numbered_documents_by_product_type()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var hosting = AddProduct(db, seed, TaxDocumentType.Factura);
        var soporte = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);
        var payments = Payments(db);

        await payments.ApplyPaymentAsync(hosting, "ORD-1", 118m, "PEN", CancellationToken.None);
        await payments.ApplyPaymentAsync(hosting, "ORD-2", 236m, "PEN", CancellationToken.None);
        await payments.ApplyPaymentAsync(soporte, "ORD-3", 500m, "PEN", CancellationToken.None);

        var docs = await db.TaxDocuments.OrderBy(x => x.Series).ThenBy(x => x.Number).ToListAsync();
        Assert.Equal([("E001", 1), ("F001", 1), ("F001", 2)], docs.Select(x => (x.Series, x.Number)));
        // Factura: lo cobrado incluye IGV; Recibo por honorarios: sin IGV.
        Assert.Equal((100m, 18m, 118m), (docs[1].BaseAmount, docs[1].IgvAmount, docs[1].TotalAmount));
        Assert.Equal((500m, 0m, TaxDocumentType.ReciboPorHonorarios), (docs[0].BaseAmount, docs[0].IgvAmount, docs[0].Type));
        Assert.All(docs, x => Assert.NotNull(x.PaymentTransactionId));
    }

    [Fact]
    public async Task Foreign_client_payment_does_not_generate_a_document()
    {
        using var db = TestData.Db(out var seed); // RequiresTaxDocument = false por defecto
        await Payments(db).ApplyPaymentAsync(AddProduct(db, seed, TaxDocumentType.Factura), "ORD-1", 120m, "USD", CancellationToken.None);
        Assert.Single(db.PaymentTransactions);
        Assert.Empty(db.TaxDocuments);
    }

    [Fact]
    public async Task Correlative_starts_at_the_configured_number_and_cannot_go_back()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, TaxDocumentType.Factura);
        var admin = Admin(db);
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, "f002", 120), CancellationToken.None));

        var created = Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 1), "PEN", 59m, null), CancellationToken.None));
        Assert.Equal(("F002", 120, 50m), (Doc(created).Series, Doc(created).Number, Doc(created).BaseAmount));
        Assert.Equal(121, Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 2), "PEN", 59m, null), CancellationToken.None))).Number);

        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, FacturaNextNumber: 100), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, FacturaSeries: "B001"), CancellationToken.None));
    }

    [Fact]
    public async Task Factura_and_recibo_can_share_the_sol_series_with_independent_correlatives()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var factura = AddProduct(db, seed, TaxDocumentType.Factura);
        var recibo = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);
        var admin = Admin(db);
        // Emitidos en SUNAT SOL: última factura E001-418, último recibo E001-189.
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, "E001", 419, "E001", 190), CancellationToken.None));

        var f = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(factura.Id, new DateOnly(2026, 10, 1), "PEN", 118m, null), CancellationToken.None)));
        var r = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(recibo.Id, new DateOnly(2026, 10, 1), "PEN", 500m, null), CancellationToken.None)));
        Assert.Equal(("E001", 419), (f.Series, f.Number));
        Assert.Equal(("E001", 190), (r.Series, r.Number)); // no sigue desde la factura 419

        // El mismo número en la misma serie es válido si el tipo es distinto.
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, ReciboNextNumber: 419), CancellationToken.None));
        var r2 = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(recibo.Id, new DateOnly(2026, 10, 2), "PEN", 500m, null), CancellationToken.None)));
        Assert.Equal(("E001", 419, TaxDocumentType.ReciboPorHonorarios), (r2.Series, r2.Number, r2.Type));

        // Cada tipo solo avanza respecto de sus propios comprobantes.
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, ReciboNextNumber: 300), CancellationToken.None));
    }

    [Fact]
    public async Task Manual_document_is_rejected_for_clients_that_do_not_require_it()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, TaxDocumentType.Factura);
        Assert.IsType<BadRequestObjectResult>(await Admin(db).CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 1), "PEN", 100m, null), CancellationToken.None));
        Assert.Empty(db.TaxDocuments);
    }

    [Fact]
    public async Task One_document_can_include_several_products_of_the_client()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var hosting = AddProduct(db, seed, TaxDocumentType.Factura);
        var dominio = AddProduct(db, seed, TaxDocumentType.Factura);
        var request = new TaxDocumentRequest(null, new DateOnly(2026, 11, 1), "PEN", 0m, null, Items: [new(hosting.Id, 118m), new(dominio.Id, 59m)]);

        var doc = Doc(Assert.IsType<CreatedResult>(await Admin(db).CreateTaxDocument(request, CancellationToken.None)));
        Assert.Equal(("F001", 1, 150m), (doc.Series, doc.Number, doc.BaseAmount));
        Assert.Equal([118m, 59m], db.TaxDocumentLines.OrderBy(x => x.Order).Select(x => x.Amount));
        // Un solo cobro por el total: cuenta una vez en los reportes y no apunta a un producto concreto.
        var payment = Assert.Single(db.PaymentTransactions);
        Assert.Equal((177m, (Guid?)null), (payment.Amount, payment.ClientProductId));
    }

    [Fact]
    public async Task Products_with_different_document_types_cannot_be_mixed()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var factura = AddProduct(db, seed, TaxDocumentType.Factura);
        var recibo = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);
        var request = new TaxDocumentRequest(null, new DateOnly(2026, 11, 1), "PEN", 0m, null, Items: [new(factura.Id, 118m), new(recibo.Id, 500m)]);
        Assert.IsType<BadRequestObjectResult>(await Admin(db).CreateTaxDocument(request, CancellationToken.None));
        Assert.Empty(db.TaxDocuments); Assert.Empty(db.PaymentTransactions);
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    [Fact]
    public async Task List_shows_amounts_in_soles_with_the_exchange_rate_of_the_payment()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        db.ExchangeRates.Add(new ExchangeRate { Date = new DateOnly(2026, 9, 1), CurrencyCode = "USD", RateToPen = 3.75m, Source = "SUNAT" }); db.SaveChanges();
        var item = AddProduct(db, seed, TaxDocumentType.Factura);
        var admin = Admin(db);
        await admin.CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 1), "USD", 118m, null), CancellationToken.None);
        // Un cambio posterior del tipo de cambio no altera un comprobante ya emitido.
        db.ExchangeRates.Single().RateToPen = 4m; db.SaveChanges();

        var row = Assert.Single((IEnumerable<object>)Assert.IsType<OkObjectResult>(await admin.TaxDocuments(null, 9, 2026, CancellationToken.None)).Value!);
        Assert.Equal((3.75m, 375m, 67.5m, 442.5m), (Prop<decimal>(row, "exchangeRate"), Prop<decimal>(row, "basePen"), Prop<decimal>(row, "igvPen"), Prop<decimal>(row, "totalPen")));
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static TaxDocument Doc(CreatedResult result) => new() { Series = Prop<string>(result.Value!, "series"), Number = Prop<int>(result.Value!, "number"), BaseAmount = Prop<decimal>(result.Value!, "baseAmount"), Type = Enum.Parse<TaxDocumentType>(Prop<string>(result.Value!, "type")) };
    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, TaxDocumentType taxType)
    {
        var product = new Product { Name = taxType.ToString(), Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
ParseOptions.0.json�w
FC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\TransferReportTests.cs�wusing System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TransferReportTests
{
    [Fact]
    public async Task Reported_transfer_is_reviewed_and_approval_activates_the_product()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "USD");
        var notifications = new FakeNotifications();

        var created = await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-123"), CancellationToken.None);
        Assert.IsType<CreatedResult>(created);
        var report = await db.TransferReports.SingleAsync();
        Assert.Equal((TransferReportStatus.Pendiente, "USD", 120m), (report.Status, report.Currency, report.Amount));
        Assert.Equal(NotificationType.TransferReported, Assert.Single(notifications.Sent).Type);
        Assert.Equal("equipo@rtres.net", notifications.Sent[0].To);
        // Mientras se revisa, no se puede reportar otro pago del mismo producto.
        Assert.IsType<ConflictObjectResult>(await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-999"), CancellationToken.None));

        Assert.IsType<OkObjectResult>(await Admin(db, notifications).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None));
        await db.Entry(item).ReloadAsync();
        var payment = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((ClientProductStatus.Activo, "TRF-OP-123", PaymentMethods.Transferencia, 120m), (item.Status, payment.PayPalOrderIdOrSubscriptionId, payment.Method, payment.Amount));
        Assert.NotNull(item.RenewsAt);
        await db.Entry(report).ReloadAsync();
        Assert.Equal((TransferReportStatus.Aprobado, payment.Id), (report.Status, report.PaymentTransactionId));
        Assert.Contains(notifications.Sent, x => x.Type == NotificationType.PaymentReceived);
        // Ya revisado: no se aprueba ni rechaza dos veces.
        Assert.IsType<ConflictObjectResult>(await Admin(db, notifications).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None));
    }

    [Fact]
    public async Task Rejection_notifies_the_reason_and_the_client_can_report_again()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "USD");
        var notifications = new FakeNotifications();
        await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-1"), CancellationToken.None);
        var report = await db.TransferReports.SingleAsync();

        Assert.IsType<BadRequestObjectResult>(await Admin(db, notifications).Reject(report.Id, new RejectTransferRequest(" "), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await Admin(db, notifications).Reject(report.Id, new RejectTransferRequest("No encontramos el abono en la cuenta."), CancellationToken.None));
        var rejected = Assert.Single(notifications.Sent, x => x.Type == NotificationType.TransferRejected);
        Assert.Equal("No encontramos el abono en la cuenta.", rejected.Data["reason"]);
        Assert.Null(rejected.To); // va al cliente, no al equipo
        await db.Entry(item).ReloadAsync();
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);

        // El mismo N° de operación se puede volver a reportar tras un rechazo (p. ej. con la constancia correcta).
        Assert.IsType<CreatedResult>(await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-1"), CancellationToken.None));
    }

    [Fact]
    public async Task Report_needs_operation_number_or_a_valid_receipt()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "PEN");
        var client = Client(db, seed, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None, File("virus.exe", "application/x-msdownload")));
        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: "1", accountId: Guid.NewGuid()), CancellationToken.None));
        Assert.IsType<CreatedResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None, File("constancia.jpg", "image/jpeg")));

        var report = await db.TransferReports.SingleAsync();
        Assert.Equal(("constancia.jpg", "image/jpeg", "PEN"), (report.ReceiptFileName, report.ReceiptContentType, report.Currency));
        var receipt = Assert.IsType<FileContentResult>(await client.Receipt(report.Id, CancellationToken.None));
        Assert.Equal("image/jpeg", receipt.ContentType);
        // Otro cliente no ve la constancia.
        var other = new Client { CompanyName = "Otra" }; db.Clients.Add(other); db.SaveChanges();
        Assert.IsType<NotFoundResult>(await Controller(db, new FakeNotifications(), new Claim("client_id", other.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")).Receipt(report.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Only_products_due_for_payment_can_be_reported()
    {
        using var db = TestData.Db(out var seed);
        var active = AddProduct(db, seed, ClientProductStatus.Activo, manual: true, renewsAt: DateTime.UtcNow.AddMonths(6));
        var paypal = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: false);
        var account = AddAccount(db, "USD");
        var client = Client(db, seed, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await client.Report(active.Id, Request(account, "A"), CancellationToken.None)); // falta mucho para renovar
        Assert.IsType<BadRequestObjectResult>(await client.Report(paypal.Id, Request(account, "B"), CancellationToken.None)); // se paga por PayPal

        // Con PayPal deshabilitado, un producto contratado por PayPal (sin suscripción que cobre sola) se puede pagar por transferencia.
        db.PaymentSettings.Add(new PaymentSettings { PayPalEnabled = false }); db.SaveChanges();
        Assert.IsType<CreatedResult>(await client.Report(paypal.Id, Request(account, "B"), CancellationToken.None));
        var report = await db.TransferReports.SingleAsync();
        await Admin(db, new FakeNotifications()).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None);
        await db.Entry(paypal).ReloadAsync();
        Assert.True(paypal.IsManualBilling); // las próximas renovaciones van por transferencia
    }

    [Fact]
    public async Task Payment_methods_can_be_toggled_but_not_both_off()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(false, false), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(false, null), CancellationToken.None));

        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, IsActive = true };
        db.Products.Add(product); db.SaveChanges();
        var payments = PayPalPaymentTests.PaymentsControllerFor(db);
        payments.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));
        Assert.IsType<BadRequestObjectResult>(await payments.Subscribe(new SubscribeRequest(product.Id, seed.Project.Id, BillingCycle.Anual, PaymentMethods.PayPal), CancellationToken.None));

        // Sin cuentas activas no se puede habilitar la transferencia ni dejar a la última sin desactivar la transferencia.
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(true, false), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(null, true), CancellationToken.None));
        var account = AddAccount(db, "PEN");
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(null, true), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.DeleteAccount(account.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Client_without_projects_gets_one_named_after_the_product()
    {
        using var db = TestData.Db(out var seed);
        db.Projects.Add(new Project { ClientId = Guid.NewGuid(), Name = "Otro", Slug = "cabalgatas-andinas-hosting-web" }); // slug ya usado por otro cliente
        var product = new Product { Name = "Hosting Web", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, IsActive = true };
        db.Products.Add(product); db.SaveChanges();
        var payments = PayPalPaymentTests.PaymentsControllerFor(db);
        payments.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        Assert.IsType<OkObjectResult>(await payments.Subscribe(new SubscribeRequest(product.Id, null, BillingCycle.Anual, PaymentMethods.Transferencia), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync();
        var project = await db.Projects.SingleAsync(x => x.Id == item.ProjectId);
        Assert.Equal((seed.Client.Id, "Hosting Web", "cabalgatas-andinas-hosting-web-2"), (project.ClientId, project.Name, project.Slug));
    }

    [Theory]
    [InlineData("BCP", "Rtres SAC", "PEN", "191 2345678 0 12", "00219100234567801252", null)]
    [InlineData("BCP", "Rtres SAC", "USD", "1912345678112", null, null)]
    [InlineData("BCP", "Rtres SAC", "GBP", "1912345678112", null, "La moneda debe ser PEN, USD o EUR.")]
    [InlineData("BCP", "Rtres SAC", "PEN", "1912345678112", "123", "El CCI tiene 20 dígitos.")]
    [InlineData("", "Rtres SAC", "PEN", "1912345678112", null, "El banco y el titular son obligatorios.")]
    public void Bank_accounts_are_validated(string bank, string holder, string currency, string number, string? cci, string? error)
    {
        var account = new BankAccount();
        Assert.Equal(error, BankTransfersController.Apply(account, new BankAccountRequest(bank, holder, currency, BankAccountType.Ahorros, number, cci)));
        if (error is null) Assert.DoesNotContain(" ", account.AccountNumber); // se guardan sin espacios
    }

    [Fact]
    public async Task Transfer_info_lists_active_accounts_with_amount_in_their_currency()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        AddAccount(db, "PEN"); AddAccount(db, "USD"); AddAccount(db, "EUR", active: false);
        db.ExchangeRates.Add(new ExchangeRate { Date = DateOnly.FromDateTime(DateTime.UtcNow), CurrencyCode = "USD", RateToPen = 3.5m, Source = "test" }); db.SaveChanges();

        var info = await new BankTransferService(db, new ConfigurationBuilder().Build()).InfoAsync(item, 0m, 1, CancellationToken.None);
        Assert.Equal(["USD", "PEN"], info.Accounts.Select(x => x.Currency)); // primero la moneda del producto; la inactiva no aparece
        Assert.Equal((null, 420m), (info.Accounts[0].ApproxAmount, info.Accounts[1].ApproxAmount));
    }

    private static TransferReportRequest Request(BankAccount account, string? operation, Guid? accountId = null) =>
        new() { BankAccountId = accountId ?? account.Id, Amount = 120m, PaidAt = DateOnly.FromDateTime(DateTime.UtcNow), OperationNumber = operation };

    private static FormFile File(string name, string type)
    {
        var bytes = Encoding.UTF8.GetBytes("contenido");
        return new FormFile(new MemoryStream(bytes), 0, bytes.Length, "receipt", name) { Headers = new HeaderDictionary(), ContentType = type };
    }

    private static BankTransfersController Client(RtresDbContext db, Seed seed, FakeNotifications notifications) =>
        Controller(db, notifications, new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente"), new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()));

    private static BankTransfersController Admin(RtresDbContext db, FakeNotifications notifications) =>
        Controller(db, notifications, new Claim(ClaimTypes.Role, nameof(UserRole.SuperAdmin)), new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()));

    private static BankTransfersController Controller(RtresDbContext db, FakeNotifications notifications, params Claim[] claims)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        var payments = new PayPalPaymentService(db, null!, notifications, PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        return new BankTransfersController(db, new BankTransferService(db, config), payments, notifications, config, NullLogger<BankTransfersController>.Instance)
        { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity(claims, "test")) } } };
    }

    private static BankAccount AddAccount(RtresDbContext db, string currency, bool active = true)
    {
        var account = new BankAccount { BankName = "BCP", Holder = "Rtres SAC", Currency = currency, AccountNumber = $"191{currency}{Guid.NewGuid():N}"[..20], IsActive = active };
        db.BankAccounts.Add(account); db.SaveChanges();
        return account;
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, bool manual, DateTime? renewsAt = null)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, Currency = "USD" };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, IsManualBilling = manual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
ParseOptions.0.json�
mC:\Users\RRamos\.nuget\packages\microsoft.net.test.sdk\17.14.1\build\net8.0\Microsoft.NET.Test.Sdk.Program.cs�// <auto-generated> This file has been auto generated. </auto-generated>
using System;
[Microsoft.VisualStudio.TestPlatform.TestSDKAutoGeneratedCode]
class AutoGeneratedProgram {static void Main(string[] args){}}ParseOptions.0.json�
cC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\obj\Debug\net10.0\Rtres.Api.Tests.GlobalUsings.g.cs�// <auto-generated/>
global using System;
global using System.Collections.Generic;
global using System.IO;
global using System.Linq;
global using System.Net.Http;
global using System.Threading;
global using System.Threading.Tasks;
global using Xunit;
ParseOptions.0.json�
qC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\obj\Debug\net10.0\.NETCoreApp,Version=v10.0.AssemblyAttributes.cs�// <autogenerated />
using System;
using System.Reflection;
[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(".NETCoreApp,Version=v10.0", FrameworkDisplayName = ".NET 10.0")]
ParseOptions.0.json�
aC:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\obj\Debug\net10.0\Rtres.Api.Tests.AssemblyInfo.cs�//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute("Rtres.Api.Tests")]
[assembly: System.Reflection.AssemblyConfigurationAttribute("Debug")]
[assembly: System.Reflection.AssemblyFileVersionAttribute("1.0.0.0")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute("1.0.0+aaa6dd32d60330ac2233cef8fc8e5ea18d10aca9")]
[assembly: System.Reflection.AssemblyProductAttribute("Rtres.Api.Tests")]
[assembly: System.Reflection.AssemblyTitleAttribute("Rtres.Api.Tests")]
[assembly: System.Reflection.AssemblyVersionAttribute("1.0.0.0")]

// Generated by the MSBuild WriteCodeFragment class.

ParseOptions.0.json��
�C:\repo\rtres-net\Rtres\src\api\Rtres.Api.Tests\obj\Debug\net10.0\Microsoft.AspNetCore.OpenApi.SourceGenerators\Microsoft.AspNetCore.OpenApi.SourceGenerators.XmlCommentGenerator\OpenApiXmlCommentSupport.generated.cs��//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
#nullable enable
// Suppress warnings about obsolete types and members
// in generated code
#pragma warning disable CS0612, CS0618

namespace System.Runtime.CompilerServices
{
    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
    file sealed class InterceptsLocationAttribute : System.Attribute
    {
        public InterceptsLocationAttribute(int version, string data)
        {
        }
    }
}

namespace Microsoft.AspNetCore.OpenApi.Generated
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Linq;
    using System.Reflection;
    using System.Text;
    using System.Text.Json;
    using System.Text.Json.Nodes;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.OpenApi;
    using Microsoft.AspNetCore.Mvc.Controllers;
    using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.OpenApi;

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlComment(
        string? Summary,
        string? Description,
        string? Remarks,
        string? Returns,
        string? Value,
        bool Deprecated,
        List<string>? Examples,
        List<XmlParameterComment>? Parameters,
        List<XmlResponseComment>? Responses);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlParameterComment(string? Name, string? Description, string? Example, bool Deprecated);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlResponseComment(string Code, string? Description, string? Example);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class XmlCommentCache
    {
        private static Dictionary<string, XmlComment>? _cache;
        public static Dictionary<string, XmlComment> Cache => _cache ??= GenerateCacheEntries();

        private static Dictionary<string, XmlComment> GenerateCacheEntries()
        {
            var cache = new Dictionary<string, XmlComment>();



            return cache;
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class DocumentationCommentIdHelper
    {
        /// <summary>
        /// Generates a documentation comment ID for a type.
        /// Example: T:Namespace.Outer+Inner`1 becomes T:Namespace.Outer.Inner`1
        /// </summary>
        public static string CreateDocumentationId(this Type type)
        {
            if (type == null)
            {
                throw new ArgumentNullException(nameof(type));
            }

            return "T:" + GetTypeDocId(type, includeGenericArguments: false, omitGenericArity: false);
        }

        /// <summary>
        /// Generates a documentation comment ID for a property.
        /// Example: P:Namespace.ContainingType.PropertyName or for an indexer P:Namespace.ContainingType.Item(System.Int32)
        /// </summary>
        public static string CreateDocumentationId(this PropertyInfo property)
        {
            if (property == null)
            {
                throw new ArgumentNullException(nameof(property));
            }

            var sb = new StringBuilder();
            sb.Append("P:");

            if (property.DeclaringType != null)
            {
                sb.Append(GetTypeDocId(property.DeclaringType, includeGenericArguments: false, omitGenericArity: false));
            }

            sb.Append('.');
            sb.Append(property.Name);

            // For indexers, include the parameter list.
            var indexParams = property.GetIndexParameters();
            if (indexParams.Length > 0)
            {
                sb.Append('(');
                for (int i = 0; i < indexParams.Length; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    sb.Append(GetTypeDocId(indexParams[i].ParameterType, includeGenericArguments: true, omitGenericArity: false));
                }
                sb.Append(')');
            }

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation comment ID for a property given its container type and property name.
        /// Example: P:Namespace.ContainingType.PropertyName
        /// </summary>
        public static string CreateDocumentationId(Type containerType, string propertyName)
        {
            if (containerType == null)
            {
                throw new ArgumentNullException(nameof(containerType));
            }
            if (string.IsNullOrEmpty(propertyName))
            {
                throw new ArgumentException("Property name cannot be null or empty.", nameof(propertyName));
            }

            var sb = new StringBuilder();
            sb.Append("P:");
            sb.Append(GetTypeDocId(containerType, includeGenericArguments: false, omitGenericArity: false));
            sb.Append('.');
            sb.Append(propertyName);

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation comment ID for a method (or constructor).
        /// For example:
        ///   M:Namespace.ContainingType.MethodName(ParamType1,ParamType2)~ReturnType
        ///   M:Namespace.ContainingType.#ctor(ParamType)
        /// </summary>
        public static string CreateDocumentationId(this MethodInfo method)
        {
            if (method == null)
            {
                throw new ArgumentNullException(nameof(method));
            }

            var sb = new StringBuilder();
            sb.Append("M:");

            // Append the fully qualified name of the declaring type.
            if (method.DeclaringType != null)
            {
                sb.Append(GetTypeDocId(method.DeclaringType, includeGenericArguments: false, omitGenericArity: false));
            }

            sb.Append('.');

            // Append the method name, handling constructors specially.
            if (method.IsConstructor)
            {
                sb.Append(method.IsStatic ? "#cctor" : "#ctor");
            }
            else
            {
                sb.Append(method.Name);
                if (method.IsGenericMethod)
                {
                    sb.Append("``");
                    sb.AppendFormat(CultureInfo.InvariantCulture, "{0}", method.GetGenericArguments().Length);
                }
            }

            // Append the parameter list, if any.
            var parameters = method.GetParameters();
            if (parameters.Length > 0)
            {
                sb.Append('(');
                for (int i = 0; i < parameters.Length; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    // Omit the generic arity for the parameter type.
                    sb.Append(GetTypeDocId(parameters[i].ParameterType, includeGenericArguments: true, omitGenericArity: true));
                }
                sb.Append(')');
            }

            // Append the return type after a '~' (if the method returns a value).
            if (method.ReturnType != typeof(void))
            {
                sb.Append('~');
                // Omit the generic arity for the return type.
                sb.Append(GetTypeDocId(method.ReturnType, includeGenericArguments: true, omitGenericArity: true));
            }

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation ID string for a type.
        /// This method handles nested types (replacing '+' with '.'),
        /// generic types, arrays, pointers, by-ref types, and generic parameters.
        /// The <paramref name="includeGenericArguments"/> flag controls whether
        /// constructed generic type arguments are emitted, while <paramref name="omitGenericArity"/>
        /// controls whether the generic arity marker (e.g. "`1") is appended.
        /// </summary>
        private static string GetTypeDocId(Type type, bool includeGenericArguments, bool omitGenericArity)
        {
            if (type.IsGenericParameter)
            {
                // Use `` for method-level generic parameters and ` for type-level.
                if (type.DeclaringMethod != null)
                {
                    return "``" + type.GenericParameterPosition;
                }
                else if (type.DeclaringType != null)
                {
                    return "`" + type.GenericParameterPosition;
                }
                else
                {
                    return type.Name;
                }
            }

            if (type.IsGenericType)
            {
                Type genericDef = type.GetGenericTypeDefinition();
                string fullName = genericDef.FullName ?? genericDef.Name;

                var sb = new StringBuilder(fullName.Length);

                // Replace '+' with '.' for nested types
                for (var i = 0; i < fullName.Length; i++)
                {
                    char c = fullName[i];
                    if (c == '+')
                    {
                        sb.Append('.');
                    }
                    else if (c == '`')
                    {
                        break;
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }

                if (!omitGenericArity)
                {
                    int arity = genericDef.GetGenericArguments().Length;
                    sb.Append('`');
                    sb.AppendFormat(CultureInfo.InvariantCulture, "{0}", arity);
                }

                if (includeGenericArguments && !type.IsGenericTypeDefinition)
                {
                    var typeArgs = type.GetGenericArguments();
                    sb.Append('{');

                    for (int i = 0; i < typeArgs.Length; i++)
                    {
                        if (i > 0)
                        {
                            sb.Append(',');
                        }

                        sb.Append(GetTypeDocId(typeArgs[i], includeGenericArguments, omitGenericArity));
                    }

                    sb.Append('}');
                }

                return sb.ToString();
            }

            // For non-generic types, use FullName (if available) and replace nested type separators.
            return (type.FullName ?? type.Name).Replace('+', '.');
        }

        /// <summary>
        /// Normalizes a documentation comment ID to match the compiler-style format.
        /// Strips the return type suffix for ordinary methods but retains it for conversion operators.
        /// </summary>
        /// <param name="docId">The documentation comment ID to normalize.</param>
        /// <returns>The normalized documentation comment ID.</returns>
        public static string NormalizeDocId(string docId)
        {
            // Find the tilde character that indicates the return type suffix
            var tildeIndex = docId.IndexOf('~');
            if (tildeIndex == -1)
            {
                // No return type suffix, return as-is
                return docId;
            }

            // Check if this is a conversion operator (op_Implicit or op_Explicit)
            // For these operators, we need to keep the return type suffix
            if (docId.Contains("op_Implicit") || docId.Contains("op_Explicit"))
            {
                return docId;
            }

            // For ordinary methods, strip the return type suffix
            return docId.Substring(0, tildeIndex);
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file class XmlCommentOperationTransformer : IOpenApiOperationTransformer
    {
        public Task TransformAsync(OpenApiOperation operation, OpenApiOperationTransformerContext context, CancellationToken cancellationToken)
        {
            var methodInfo = context.Description.ActionDescriptor is ControllerActionDescriptor controllerActionDescriptor
                ? controllerActionDescriptor.MethodInfo
                : context.Description.ActionDescriptor.EndpointMetadata.OfType<MethodInfo>().SingleOrDefault();

            if (methodInfo is null)
            {
                return Task.CompletedTask;
            }
            if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(methodInfo.CreateDocumentationId()), out var methodComment))
            {
                if (methodComment.Summary is { } summary)
                {
                    operation.Summary = summary;
                }
                if (methodComment.Description is { } description)
                {
                    operation.Description = description;
                }
                if (methodComment.Remarks is { } remarks)
                {
                    operation.Description = remarks;
                }
                if (methodComment.Parameters is { Count: > 0})
                {
                    foreach (var parameterComment in methodComment.Parameters)
                    {
                        var parameterInfo = methodInfo.GetParameters().SingleOrDefault(info => info.Name == parameterComment.Name);
                        var operationParameter = operation.Parameters?.SingleOrDefault(parameter => parameter.Name == parameterComment.Name);
                        if (operationParameter is not null)
                        {
                            var targetOperationParameter = UnwrapOpenApiParameter(operationParameter);
                            targetOperationParameter.Description = parameterComment.Description;
                            if (parameterComment.Example is { } jsonString)
                            {
                                targetOperationParameter.Example = jsonString.Parse();
                            }
                            targetOperationParameter.Deprecated = parameterComment.Deprecated;
                        }
                        else
                        {
                            var requestBody = operation.RequestBody;
                            if (requestBody is not null)
                            {
                                requestBody.Description = parameterComment.Description;
                                if (parameterComment.Example is { } jsonString)
                                {
                                    var content = requestBody?.Content?.Values;
                                    if (content is null)
                                    {
                                        continue;
                                    }
                                    foreach (var mediaType in content)
                                    {
                                        mediaType.Example = jsonString.Parse();
                                    }
                                }
                            }
                        }
                    }
                }
                // Applies `<returns>` on XML comments for operation with single response value.
                if (methodComment.Returns is { } returns && operation.Responses is { Count: 1 })
                {
                    var response = operation.Responses.First();
                    response.Value.Description = returns;
                }
                // Applies `<response>` on XML comments for operation with multiple response values.
                if (methodComment.Responses is { Count: > 0} && operation.Responses is { Count: > 0 })
                {
                    foreach (var response in operation.Responses)
                    {
                        var responseComment = methodComment.Responses.SingleOrDefault(xmlResponse => xmlResponse.Code == response.Key);
                        if (responseComment is not null)
                        {
                            response.Value.Description = responseComment.Description;
                        }
                    }
                }
            }
            foreach (var parameterDescription in context.Description.ParameterDescriptions)
            {
                var metadata = parameterDescription.ModelMetadata;
                if (metadata is not null
                    && metadata.MetadataKind == ModelMetadataKind.Property
                    && metadata.ContainerType is { } containerType
                    && metadata.PropertyName is { } propertyName)
                {
                    var propertyDocId = DocumentationCommentIdHelper.CreateDocumentationId(containerType, propertyName);
                    if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(propertyDocId), out var propertyComment))
                    {
                        var parameter = operation.Parameters?.SingleOrDefault(p => p.Name == metadata.Name);
                        var description = propertyComment.Summary;
                        if (!string.IsNullOrEmpty(description) && !string.IsNullOrEmpty(propertyComment.Value))
                        {
                            description = $"{description}\n{propertyComment.Value}";
                        }
                        else if (string.IsNullOrEmpty(description))
                        {
                            description = propertyComment.Value;
                        }
                        if (parameter is null)
                        {
                            if (operation.RequestBody is not null)
                            {
                                operation.RequestBody.Description = description;
                                if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                                {
                                    var content = operation.RequestBody.Content?.Values;
                                    if (content is null)
                                    {
                                        continue;
                                    }
                                    var parsedExample = jsonString.Parse();
                                    foreach (var mediaType in content)
                                    {
                                        mediaType.Example = parsedExample;
                                    }
                                }
                            }
                            continue;
                        }
                        var targetOperationParameter = UnwrapOpenApiParameter(parameter);
                        if (targetOperationParameter is not null)
                        {
                            targetOperationParameter.Description = description;
                            if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                            {
                                targetOperationParameter.Example = jsonString.Parse();
                            }
                        }
                    }
                }
            }

            return Task.CompletedTask;
        }

        private static OpenApiParameter UnwrapOpenApiParameter(IOpenApiParameter sourceParameter)
        {
            if (sourceParameter is OpenApiParameterReference parameterReference)
            {
                if (parameterReference.Target is OpenApiParameter target)
                {
                    return target;
                }
                else
                {
                    throw new InvalidOperationException($"The input schema must be an {nameof(OpenApiParameter)} or {nameof(OpenApiParameterReference)}.");
                }
            }
            else if (sourceParameter is OpenApiParameter directParameter)
            {
                return directParameter;
            }
            else
            {
                throw new InvalidOperationException($"The input schema must be an {nameof(OpenApiParameter)} or {nameof(OpenApiParameterReference)}.");
            }
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file class XmlCommentSchemaTransformer : IOpenApiSchemaTransformer
    {
        public Task TransformAsync(OpenApiSchema schema, OpenApiSchemaTransformerContext context, CancellationToken cancellationToken)
        {
            // Apply comments from the type
            if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(context.JsonTypeInfo.Type.CreateDocumentationId()), out var typeComment))
            {
                schema.Description = typeComment.Summary;
                if (typeComment.Examples?.FirstOrDefault() is { } jsonString)
                {
                    schema.Example = jsonString.Parse();
                }
            }

            if (context.JsonPropertyInfo is { AttributeProvider: PropertyInfo propertyInfo })
            {
                // Apply comments from the property
                if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(propertyInfo.CreateDocumentationId()), out var propertyComment))
                {
                    var description = propertyComment.Summary;
                    if (!string.IsNullOrEmpty(description) && !string.IsNullOrEmpty(propertyComment.Value))
                    {
                        description = $"{description}\n{propertyComment.Value}";
                    }
                    else if (string.IsNullOrEmpty(description))
                    {
                        description = propertyComment.Value;
                    }
                    if (schema.Metadata is null
                        || !schema.Metadata.TryGetValue("x-schema-id", out var schemaId)
                        || string.IsNullOrEmpty(schemaId as string))
                    {
                        // Inlined schema
                        schema.Description = description;
                        if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                        {
                            schema.Example = jsonString.Parse();
                        }
                    }
                    else
                    {
                        // Schema Reference
                        if (!string.IsNullOrEmpty(description))
                        {
                            schema.Metadata["x-ref-description"] = description;
                        }
                        if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                        {
                            schema.Metadata["x-ref-example"] = jsonString.Parse()!;
                        }
                    }
                }
            }
            return Task.CompletedTask;
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class JsonNodeExtensions
    {
        public static JsonNode? Parse(this string? json)
        {
            if (json is null)
            {
                return null;
            }

            try
            {
                return JsonNode.Parse(json);
            }
            catch (JsonException)
            {
                try
                {
                    // If parsing fails, try wrapping in quotes to make it a valid JSON string
                    return JsonNode.Parse($"\"{json.Replace("\"", "\\\"")}\"");
                }
                catch (JsonException)
                {
                    return null;
                }
            }
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class GeneratedServiceCollectionExtensions
    {

    }
}
ParseOptions.0.json