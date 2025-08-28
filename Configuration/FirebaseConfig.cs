using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

namespace SkillsAuditSystem.Configuration
{
    public class FirebaseConfig
    {
        public static void Initialize(IConfiguration configuration)
        {
            var credentialsPath = configuration["Firebase:CredentialsPath"];
            var projectId = configuration["Firebase:ProjectId"];

            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);

            FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromFile(credentialsPath),
                ProjectId = projectId
            });
        }
    }
}
