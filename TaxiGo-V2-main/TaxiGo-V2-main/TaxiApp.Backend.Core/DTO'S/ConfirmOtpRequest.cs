using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class ConfirmOtpRequest
    {
        public required string CountryCode { get; set; }
        public required string PhoneNumber { get; set; }
        public required string Otp { get; set; }
    }
}
