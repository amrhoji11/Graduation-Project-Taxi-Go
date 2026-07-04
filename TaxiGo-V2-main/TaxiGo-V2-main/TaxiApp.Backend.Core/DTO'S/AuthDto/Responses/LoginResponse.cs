using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S.AuthDto.Responses
{
    public class LoginResponse
    {
        public required string Token { get; set; }
        public required string RefreshToken { get; set; }
        public required string UserId { get; set; }
        public required string Role { get; set; }
    }
}
