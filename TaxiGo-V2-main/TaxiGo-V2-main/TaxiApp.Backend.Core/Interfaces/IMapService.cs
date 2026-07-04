using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.Interfaces
{
    public interface IMapService
    {
        Task<TimeSpan> GetETAAsync(
          decimal originLat,
          decimal originLng,
          decimal destLat,
          decimal destLng);

        Task<List<TimeSpan>> GetDistancesAsync(
            List<DriverLocationDto> drivers,
            double destLat,
            double destLng);

        Task<string> GetRoutePolylineAsync(List<(double lat, double lng)> points);

        /// One origin, many destinations - single Distance Matrix request.
        /// Used by TripRoutingService.BuildTripRoute to price all
        /// remaining candidate stops in one call per planning step instead
        /// of one call per candidate (was O(stops^2) raw API calls per
        /// route plan; this makes it O(stops)). Order of the returned list
        /// matches the order of `destinations`.
        Task<List<TimeSpan>> GetEtasFromOriginAsync(
            double originLat,
            double originLng,
            List<(double lat, double lng)> destinations);
    }
}
