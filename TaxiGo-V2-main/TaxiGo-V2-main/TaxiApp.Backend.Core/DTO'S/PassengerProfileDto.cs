using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class PassengerProfileDto
    {
        public required string Id { get; set; }
        public required string FirstName { get; set; }
        public required string LastName { get; set; }
        public required string FullName { get; set; }
        public string? Address { get; set; }
        public string? PhoneNumber { get; set; }
        public string? ProfileImageUrl { get; set; }
        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }
        public int CompletedOrdersCount { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
