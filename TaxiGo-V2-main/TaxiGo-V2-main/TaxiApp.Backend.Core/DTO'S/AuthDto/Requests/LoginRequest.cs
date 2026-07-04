using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S.AuthDto.Requests
{
    public class LoginRequest
    {
        [Required]
        public required string CountryCode { get; set; }

        [Required]
        [RegularExpression(@"^\d{9,10}$")]
        public required string PhoneNumber { get; set; }

    }
}
