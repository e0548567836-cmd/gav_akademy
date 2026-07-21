using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;

namespace students.Services
{
    public class CloudinaryService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryService()
        {
            var account = new Account(
                "dgodaqxr6",
                "947468821846887",
                "JomZjMClO3gkJIYkoqjpHhTnVtc"
            );
            _cloudinary = new Cloudinary(account);
        }

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

        public async Task<DeletionResult> DeleteImageAsync(string publicId, string resourceType)
        {
            Console.WriteLine($"Attempting to delete: {publicId}, type: {resourceType}");

            var deletionParams = new DeletionParams(publicId)
            {
                ResourceType = resourceType == "raw" ? ResourceType.Raw : ResourceType.Image
            };

            var result = await _cloudinary.DestroyAsync(deletionParams);
            Console.WriteLine($"Result: {result.Result}, error: {result.Error?.Message}");

            return result;
        }
    }
}
