namespace TaxiApp.Backend.Core.DTO_S
{
    /// One waypoint on a drawable route line. Used as a plain-coordinates
    /// fallback (and Flutter-side primary format, since the mobile app has
    /// no Google encoded-polyline decoder) alongside the optional encoded
    /// `Polyline` string on `AdminCurrentTripDto`.
    public class RoutePointDto
    {
        public double Lat { get; set; }
        public double Lng { get; set; }
    }
}
