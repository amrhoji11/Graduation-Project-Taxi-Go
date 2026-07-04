using System;
using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class ViolationDto
    {
        public int Id { get; set; }
        public required string DriverId { get; set; }
        public required string DriverName { get; set; }
        public int? OrderId { get; set; }
        public int? TripId { get; set; }
        public ViolationType Type { get; set; }
        public ViolationStatus Status { get; set; }
        public required string Reason { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
