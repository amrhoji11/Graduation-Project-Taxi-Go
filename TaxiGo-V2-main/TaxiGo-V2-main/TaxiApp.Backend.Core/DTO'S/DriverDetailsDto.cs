using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class DriverVehicleSummaryDto
    {
        public string? Model { get; set; }
        public string? PlateNumber { get; set; }
    }

    public class DriverDetailsDto
    {
        public required string DriverId { get; set; }
        public required string Name { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? ProfilePhotoUrl { get; set; }

        public DriverStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }

        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }

        public DriverVehicleSummaryDto? Vehicle { get; set; }

        public int TotalTrips { get; set; }
        public int CompletedTrips { get; set; }
        public int CancelledTrips { get; set; }

        public double Rating { get; set; }
        public int RatingCount { get; set; }
    }
}
