using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S.AuthDto.Requests
{
    public class VerifyOtpRequest
    {
        public required string CountryCode { get; set; }
        public required string PhoneNumber { get; set; } // يتم ارساله برمجيا من الفلتر
        public required string OtpCode { get; set; }    // يدخله المستخدم يدوياً
    }
}
