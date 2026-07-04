using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class RoutePlanDto
    {
        public List<RouteStepDto> Steps { get; set; } = new();
        public string Polyline { get; set; } = string.Empty;

        /// Real road geometry decoded from `Polyline`. Empty (never a
        /// straight-line fallback) when the routing service call failed.
        public List<RoutePointDto> RoutePoints { get; set; } = new();
        public int TotalMinutes { get; set; }
    }
}
