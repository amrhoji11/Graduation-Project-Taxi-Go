using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class RouteResponseDto
    {
        public required List<RouteStepDto> Route { get; set; }
        public required string Polyline { get; set; }
        public int TotalMinutes { get; set; }

        /// Real road geometry decoded from `Polyline` - plain lat/lng
        /// waypoints the mobile app can draw directly (it has no encoded-
        /// polyline decoder), same shape as `AdminCurrentTripDto.RoutePoints`.
        public List<RoutePointDto> RoutePoints { get; set; } = new();

        public required IEnumerable<RouteStepDto> Pickups { get; set; }
        public required IEnumerable<RouteStepDto> Dropoffs { get; set; }
    }
}
