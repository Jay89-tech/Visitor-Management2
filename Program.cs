using SkillsAuditSystem.Configuration;
using SkillsAuditSystem.Services.Interfaces;
using SkillsAuditSystem.Services.Implementation;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient();
builder.Services.AddScoped<IAuthService, FirebaseAuthService>();
builder.Services.AddScoped<IUserService, UserService>();

// --- Firebase setup ---
var projectId = builder.Configuration["Firebase:ProjectId"] ?? "testing-827ee";
var serviceAccountPath = Path.Combine(builder.Environment.ContentRootPath, "firebase-credentials.json");

GoogleCredential credential = null;

try
{
    if (File.Exists(serviceAccountPath))
    {
        credential = GoogleCredential.FromFile(serviceAccountPath);

        // Initialize Firebase Admin SDK
        FirebaseApp.Create(new AppOptions()
        {
            Credential = credential,
            ProjectId = projectId
        });

        Console.WriteLine("✅ Firebase initialized with service account file.");

        // --- FirestoreDb setup (new SDK style) ---
        var client = new FirestoreClientBuilder
        {
            Credential = credential
        }.Build();

        var firestoreDb = FirestoreDb.Create(projectId, client);

        // Register FirestoreDb in DI
        builder.Services.AddSingleton(firestoreDb);

        Console.WriteLine("✅ FirestoreDb initialized.");
    }
    else
    {
        Console.WriteLine("⚠️ Firebase Admin not initialized - service account file not found");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"⚠️ Firebase initialization warning: {ex.Message}");
}

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
