//קובץ הרשאות מערכת


using Microsoft.EntityFrameworkCore;
using students.Data;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSwaggerGen();

// הוספת שירות שמטפל בקונטרולרים (ה-API שלנו)
builder.Services.AddControllers();

// הגדרת פוליסה שמאפשרת ל-Chrome (פלאטר) "לדבר" עם השרת
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()   // מאפשר לכל אתר (הפלאטר שלך) לגשת לשרת
              .AllowAnyMethod()   // מאפשר להשתמש בכל סוגי הבקשות (POST, GET וכו')
              .AllowAnyHeader();  // מאפשר לשלוח את כל סוגי הכותרות (כמו JSON)
    });
});

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
var app = builder.Build();

// הפעלת ה-CORS - חייב להופיע לפני MapControllers!
app.UseCors("AllowAll");

// מאפשר לשרת לזהות את הנתיבים של ה-API
app.MapControllers();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.Run();