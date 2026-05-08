using Microsoft.EntityFrameworkCore;
using students.Data;

var builder = WebApplication.CreateBuilder(args);

// --- רישום שירותים (Services) ---
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// הגדרת CORS עבור ה-Flutter
builder.Services.AddCors(options => {
    options.AddPolicy("AllowAll", policy => {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

// חיבור למסד הנתונים (SQL Server)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// הגדרת אימות מול גוגל
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

// --- הגדרת ה-Middleware (סדר הפעולות) ---

// הפעלת Swagger בכל מצב (גם ב-Production) כדי לוודא שזה עובד לך
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    // הגדרה זו גורמת ל-Swagger להיפתח ישר בכתובת הראשית (למשל http://localhost:5000)
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
    options.RoutePrefix = string.Empty;
});

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();