using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S.AuthDto.Requests
{
    public class ConfirmChangePhoneRequest
    {
        [Required]
        public required string CountryCode { get; set; }   // 🔥 مهم

        [Required]
        public required string PhoneNumber { get; set; }

        [Required]
        public required string Token { get; set; }
    }
}