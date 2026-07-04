using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class PassengerDto
    {
        public required string UserId { get; set; }
        public required string FullName { get; set; }
        public required string PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? ProfilePhotoUrl { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }
        public int CompletedOrdersCount { get; set; }
    }
}
