using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class AdminCurrentTripOrderDto
    {
        public int OrderId { get; set; }
        public required string PassengerName { get; set; }
        public required string PickupLocation { get; set; }
        public decimal PickupLat { get; set; }
        public decimal PickupLng { get; set; }
        public string? DropoffLocation { get; set; }
        public decimal? DropoffLat { get; set; }
        public decimal? DropoffLng { get; set; }
        public TripOrderStatus StatusInTrip { get; set; }
    }

    /// Powers the admin "current trips" live map/list - one entry per active
    /// (Assigned/DriverArrived/InProgress) trip, with everything that screen
    /// needs: driver + live location, vehicle, the order in the trip, and a
    /// human-readable `DetailedStatus` derived from the trip/driver state.
    public class AdminCurrentTripDto
    {
        public int TripId { get; set; }
        public TripStatus Status { get; set; }
        public required string DetailedStatus { get; set; }

        public string? DriverId { get; set; }
        public required string DriverName { get; set; }
        public string? DriverPhone { get; set; }
        public string? DriverProfilePhotoUrl { get; set; }
        public decimal? DriverLastLat { get; set; }
        public decimal? DriverLastLng { get; set; }
        public DateTime? DriverLastSeenAt { get; set; }

        public string? VehiclePlateNumber { get; set; }
        public string? VehicleMake { get; set; }
        public string? VehicleModel { get; set; }

        public List<AdminCurrentTripOrderDto> Orders { get; set; } = new();

        // ---- Route / ETA / distance (added for the admin live-trips map) ----

        /// Driver -> [pickup ->] dropoff, real road geometry decoded from
        /// the routing service's polyline - plain lat/lng waypoints rather
        /// than the encoded polyline format itself, since the mobile app
        /// has no decoder for that format and these can be drawn directly
        /// as a `Polyline`. Empty (never a straight line) when the routing
        /// service call failed (see `AdminRepository.GetCurrentTripsAsync`).
        public List<RoutePointDto> RoutePoints { get; set; } = new();

        /// The routing service's encoded polyline string, only set when
        /// the call actually succeeded. Null/empty whenever `RoutePoints`
        /// is also empty.
        public string? Polyline { get; set; }

        public int? EtaMinutes { get; set; }
        public double? TotalDistanceMeters { get; set; }
        public double? CoveredDistanceMeters { get; set; }
        public double? RemainingDistanceMeters { get; set; }
    }
}
