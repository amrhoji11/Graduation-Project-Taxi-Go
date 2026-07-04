using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S.AuthDto.Responses
{
    public class RegisterDriverResponse
    {
        public string UserId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? ProfilePhotoUrl { get; set; }
        public required string Message { get; set; }
    }
}
