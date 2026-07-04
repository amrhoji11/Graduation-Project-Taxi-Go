using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class DriverPendingResponseDto
    {
        public required string UserId { get; set; }
        public required string FullName { get; set; }
        public required string PhoneNumber { get; set; }
    }
}
