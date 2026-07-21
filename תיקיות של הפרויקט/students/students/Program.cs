using students.Services;
using students.Helpers;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Hubs;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// --- Register Services ---
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Allow Flutter to send string-type IDs as JSON numbers (e.g., CourseId: 101 instead of "101")
        options.JsonSerializerOptions.Converters.Add(new NumberToStringConverter());
    });
builder.Services.AddScoped<CloudinaryService>();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();

// CORS policy for Flutter + SignalR (credentials required for SignalR WebSockets)
builder.Services.AddCors(options => {
    options.AddPolicy("AllowAll", policy => {
        policy.SetIsOriginAllowed(origin => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// Database connection (SQLite)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// Google authentication
builder.Services.AddAuthentication(options => {
    options.DefaultScheme = "Cookies";
    options.DefaultChallengeScheme = "Google";
})
.AddCookie("Cookies")
.AddGoogle("Google", options => {
    options.ClientId = "383056809218-4d17occc5eo7bss6chg1are9vad507sn.apps.googleusercontent.com";
    options.ClientSecret = "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";
    options.CallbackPath = "/signin-google";
});

var app = builder.Build();

// Apply any pending migrations automatically on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.Migrate();
}

// 1. CORS must be first to prevent browser blocking
app.UseCors("AllowAll");

// 2. Enable Swagger
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
    options.RoutePrefix = string.Empty; // Opens Swagger at root URL
});

app.UseAuthentication();
app.UseAuthorization();

// 3. Map endpoints
app.MapControllers();
app.MapHub<ChatHub>("/chathub");

app.Run();