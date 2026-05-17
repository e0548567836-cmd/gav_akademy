using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;

namespace students.Services // מוודא שזה תואם לתיקייה
{
    public class CloudinaryService
    {
        private readonly Cloudinary _cloudinary;

        // כאן את צריכה להכניס את הפרטים מהחשבון שלך ב-Cloudinary
        public CloudinaryService()
        {
            var account = new Account(
                "dgodaqxr6",
                "947468821846887",
                "JomZjMClO3gkJIYkoqjpHhTnVtc"
            );
            _cloudinary = new Cloudinary(account);
        }


        /*גרסה 5 */

        public async Task<RawUploadResult> UploadImageAsync(IFormFile file)
        {
            if (file.Length == 0) return new RawUploadResult();

            using var stream = file.OpenReadStream();

            if (file.FileName.ToLower().EndsWith(".pdf"))
            {
                var rawParams = new RawUploadParams()
                {
                    File = new FileDescription(file.FileName, stream),
                    Folder = "CoLearn_Files",
                };
                return await _cloudinary.UploadAsync(rawParams, "auto");
            }
            else
            {
                var imageParams = new ImageUploadParams()
                {
                    File = new FileDescription(file.FileName, stream),
                    Folder = "CoLearn_Files",
                };
                var result = await _cloudinary.UploadAsync(imageParams);
                return new RawUploadResult
                {
                    SecureUrl = result.SecureUrl,
                    PublicId = result.PublicId
                };
            }
        }

        /*גרסה 4*/
        /* public async Task<RawUploadResult> UploadImageAsync(IFormFile file)
         {
             if (file.Length == 0) return new RawUploadResult();

             using var stream = file.OpenReadStream();

             if (file.FileName.ToLower().EndsWith(".pdf"))
             {
                 var rawParams = new RawUploadParams()
                 {
                     File = new FileDescription(file.FileName, stream),
                     Folder = "CoLearn_Files",
                 };
                 return await _cloudinary.UploadAsync(rawParams, "auto");
             }
             else
             {
                 var imageParams = new ImageUploadParams()
                 {
                     File = new FileDescription(file.FileName, stream),
                     Folder = "CoLearn_Files",
                 };
                 var result = await _cloudinary.UploadAsync(imageParams);
                 return new RawUploadResult
                 {
                     SecureUrl = result.SecureUrl,
                     PublicId = result.PublicId
                 };
             }
         }*/

        /*גרסה 3*/

        /*
        public async Task<RawUploadResult> UploadImageAsync(IFormFile file)
        {
            if (file.Length == 0) return new RawUploadResult();

            using var stream = file.OpenReadStream();

            // שולחים ישירות דרך HTTP עם resource_type=auto
            var account = new Account("dgodaqxr6", "947468821846887", "JomZjMClO3gkJIYkoqjpHhTnVtc");
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
            var signature = ComputeSignature(timestamp, "CoLearn_Files", account.ApiSecret);

            using var client = new HttpClient();
            using var content = new MultipartFormDataContent();

            var fileContent = new StreamContent(stream);
            content.Add(fileContent, "file", file.FileName);
            content.Add(new StringContent("CoLearn_Files"), "folder");
            content.Add(new StringContent(timestamp), "timestamp");
            content.Add(new StringContent(account.ApiKey), "api_key");
            content.Add(new StringContent(signature), "signature");

            var response = await client.PostAsync(
                $"https://api.cloudinary.com/v1_1/{account.Cloud}/auto/upload",
                content
            );

            var json = await response.Content.ReadAsStringAsync();
            var result = System.Text.Json.JsonSerializer.Deserialize<CloudinaryUploadResponse>(json);

            return new RawUploadResult
            {
                SecureUrl = new Uri(result.secure_url),
                PublicId = result.public_id
            };
        }

        private string ComputeSignature(string timestamp, string folder, string apiSecret)
        {
            var str = $"folder={folder}&timestamp={timestamp}{apiSecret}";
            using var sha1 = System.Security.Cryptography.SHA1.Create();
            var hash = sha1.ComputeHash(System.Text.Encoding.UTF8.GetBytes(str));
            return Convert.ToHexString(hash).ToLower();
        }*/



        /*גרסה 2*/

        /* public async Task<RawUploadResult> UploadImageAsync(IFormFile file)
           {
               if (file.Length == 0) return new RawUploadResult();

               using var stream = file.OpenReadStream();

               var uploadParams = new RawUploadParams()
               {
                   File = new FileDescription(file.FileName, stream),
                   Folder = "CoLearn_Files",
               };

               return await _cloudinary.UploadAsync(uploadParams, "auto");
           }*/


        /*גרסה 1*/

        /*  public async Task<ImageUploadResult> UploadImageAsync(IFormFile file)
          {
              var uploadResult = new ImageUploadResult();

              if (file.Length > 0)
              {
                  using var stream = file.OpenReadStream();
                  var uploadParams = new ImageUploadParams
                  {
                      File = new FileDescription(file.FileName, stream),
                      Folder = "CoLearn_Files",
                      // התיקון הקריטי: מאפשר ל-Cloudinary לזהות אוטומטית אם זה PDF או תמונה
                      ResourceType = "auto"
                  };
                  uploadResult = await _cloudinary.UploadAsync(uploadParams);
              }

              return uploadResult;
          }*/

        public async Task<DeletionResult> DeleteImageAsync(string publicId, string resourceType)
        {
            Console.WriteLine($"מנסה למחוק: {publicId}, סוג: {resourceType}");

            var deletionParams = new DeletionParams(publicId)
            {
                ResourceType = resourceType == "raw" ? ResourceType.Raw : ResourceType.Image
            };

            var result = await _cloudinary.DestroyAsync(deletionParams);
            Console.WriteLine($"תוצאה: {result.Result}, שגיאה: {result.Error?.Message}");

            return result;
        }
        /*גרסה 1
        public async Task<DeletionResult> DeleteImageAsync(string publicId)
        {
            var deletionParams = new DeletionParams(publicId);
            // כאן השירות משתמש באובייקט ה-Cloudinary האמיתי שלו
            return await _cloudinary.DestroyAsync(deletionParams);
        }*/
    }
}
/*public class CloudinaryUploadResponse
{
    public string secure_url { get; set; }
    public string public_id { get; set; }
}*/