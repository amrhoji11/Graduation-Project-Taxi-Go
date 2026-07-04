using Microsoft.AspNetCore.Http;

namespace TaxiApp.Backend.Infrastructure.Helper
{
    /// <summary>
    /// Repositories only persist the uploaded file's name (see
    /// PassengerRepository/DriverRepository/AdminRepository), so controllers
    /// must turn it into a URL the static-files middleware ("/images/...",
    /// see Program.cs) actually serves before returning it to clients.
    /// </summary>
    public static class ImageUrlHelper
    {
        public static string? BuildImageUrl(HttpRequest request, string? fileName)
        {
            if (string.IsNullOrWhiteSpace(fileName))
                return null;

            if (fileName.StartsWith("http://") || fileName.StartsWith("https://"))
                return fileName;

            return $"{request.Scheme}://{request.Host}/images/{fileName}";
        }
    }
}