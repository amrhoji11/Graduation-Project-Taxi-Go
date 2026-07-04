using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S
{
    /// <summary>
    /// `GET /api/Admin/GetAllDrivers` used to return the raw `Driver` entity
    /// without including `User`, so `name`/`phone` (which live on
    /// `ApplicationUser`, not `Driver`) were always null and the admin app
    /// showed "Unknown" for every driver. This DTO carries the joined name.
    /// </summary>
    public class DriverListItemDto
    {
        public required string UserId { get; set; }
        public required string Name { get; set; }
        public string? PhoneNumber { get; set; }
        public string? ProfilePhotoUrl { get; set; }
        public DriverStatus Status { get; set; }
        public decimal? LastLat { get; set; }
        public decimal? LastLng { get; set; }
        public DateTime? LastSeenAt { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }
        public double Rating { get; set; }
        public int RatingCount { get; set; }
    }
}
