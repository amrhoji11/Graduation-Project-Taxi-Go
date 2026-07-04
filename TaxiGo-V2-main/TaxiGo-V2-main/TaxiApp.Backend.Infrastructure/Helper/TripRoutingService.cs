using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Data;

namespace TaxiApp.Backend.Infrastructure.Helper
{
    public class TripRoutingService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapService _mapService;
        private readonly IHubContext<NotificationHub> _hub;

        public TripRoutingService(
            ApplicationDbContext context,
            IMapService mapService,
            IHubContext<NotificationHub> hub)
        {
            _context = context;
            _mapService = mapService;
            _hub = hub;
        }

        // =========================
        // 🔥 MAIN ENGINE
        // =========================
        public async Task<RoutePlanDto> RecalculateTripAsync(int tripId)
        {
            var trip = await _context.Trips
          .Include(t => t.TripOrders)
              .ThenInclude(o => o.Order)
                  .ThenInclude(o => o.Passenger)
                      .ThenInclude(p => p.User)
          .Include(t => t.Driver)
          .FirstOrDefaultAsync(t => t.TripId == tripId);

            if (trip == null || trip.DriverId == null)
                return new RoutePlanDto();

            var driver = trip.Driver;

            if (driver == null)
                return new RoutePlanDto();

            var steps = await BuildTripRoute(trip, driver);

            var points = steps
                .Select(s => (s.Lat, s.Lng))
                .ToList();

            var polyline = await _mapService.GetRoutePolylineAsync(points);

            // Real road geometry only - never a straight-line fallback.
            // Empty whenever the routing service call failed.
            var routePoints = string.IsNullOrEmpty(polyline)
                ? new List<RoutePointDto>()
                : GeoUtils.DecodePolyline(polyline)
                    .Select(p => new RoutePointDto { Lat = p.Lat, Lng = p.Lng })
                    .ToList();

            // `EstimatedMinutes` is sanitized at the source in `BuildTripRoute`
            // now, but `Sum` over `int` uses checked addition internally and
            // throws `OverflowException` on the first out-of-range value it
            // sees - this is the defense-in-depth backstop in case any future
            // caller ever puts an unsanitized `RouteStepDto` into `steps`.
            var safeTotalMinutes = steps
                .Where(x => x.EstimatedMinutes > 0 && x.EstimatedMinutes < 24 * 60)
                .Sum(x => (long)x.EstimatedMinutes);

            var totalMinutes = safeTotalMinutes > int.MaxValue
                ? int.MaxValue
                : (int)safeTotalMinutes;

            var result = new RoutePlanDto
            {
                Steps = steps,
                Polyline = polyline,
                RoutePoints = routePoints,
                TotalMinutes = totalMinutes
            };

            // =========================
            // 🔥 إرسال محسّن للفرونت
            // =========================
            await _hub.Clients
                .Group($"user-{driver.UserId}")
                .SendAsync("RouteUpdated", new RouteResponseDto
                {
                    Route = result.Steps,
                    Polyline = result.Polyline,
                    RoutePoints = routePoints,
                    TotalMinutes = result.TotalMinutes,

                    Pickups = result.Steps.Where(x => x.IsPickup),
                    Dropoffs = result.Steps.Where(x => !x.IsPickup)
                });

            // Passenger-safe subset only — Steps/Pickups/Dropoffs carry the
            // passenger's name, which the passenger doesn't need back. The
            // passenger side only ever needs the line itself and the ETA.
            await _hub.Clients
                .Group($"trip-{tripId}")
                .SendAsync("RouteUpdated", new
                {
                    polyline = result.Polyline,
                    routePoints,
                    totalMinutes = result.TotalMinutes
                });

            return result;
        }

        // =========================
        // 🧠 SMART ROUTING (your improved logic)
        // =========================
        private async Task<List<RouteStepDto>> BuildTripRoute(Trip trip, Driver driver)
        {
            var tripOrders = trip.TripOrders
           .Where(x => x.StatusInTrip != TripOrderStatus.DroppedOff &&
                       x.StatusInTrip != TripOrderStatus.Cancelled)
           .ToList();

            if (!tripOrders.Any())
                return new List<RouteStepDto>();

            // A driver who just went online (or whose GPS hasn't reported
            // yet) has no `LastLat`/`LastLng` - this used to force-unwrap
            // both with `!` and crash the entire accept-order flow with an
            // unhandled exception the moment such a driver accepted their
            // first order (the trip itself was already created and saved
            // by then, so the driver/passenger just never got the route or
            // the "accepted" notification, and the API call surfaced as a
            // 500 even though the trip had, confusingly, actually been
            // created). Returning no route is the same graceful no-op
            // already used above when there are no orders to plan for.
            if (driver.LastLat == null || driver.LastLng == null)
                return new List<RouteStepDto>();

            double currentLat = (double)driver.LastLat.Value;
            double currentLng = (double)driver.LastLng.Value;

            var steps = new List<RouteStepDto>();
            var ordersById = tripOrders.ToDictionary(x => x.OrderId);

            // Each order contributes its remaining legs *in order*: pickup
            // (only if not already picked up) then dropoff. Tracked as two
            // separate sets rather than deriving "is this a pickup or
            // dropoff candidate" from the order's real `StatusInTrip` —
            // that field never changes mid-loop (this method only plans,
            // it doesn't persist), so a single pass could never place both
            // legs for the same not-yet-picked-up order; it would visit
            // the pickup, immediately drop the order from consideration,
            // and never plan the dropoff leg at all.
            var pendingPickups = tripOrders
                .Where(x => x.StatusInTrip != TripOrderStatus.PickedUp)
                .Select(x => x.OrderId)
                .ToHashSet();
            var pendingDropoffs = tripOrders.Select(x => x.OrderId).ToHashSet();

            int seq = 0;

            while (pendingPickups.Count > 0 || pendingDropoffs.Count > 0)
            {
                // An order's dropoff can never be visited before its own
                // pickup within this same planning pass - membership in
                // pendingPickups (vs. falling through to pendingDropoffs)
                // already encodes that, since Union only contains ids from
                // one or both sets.
                var candidateOrderIds = pendingPickups.Union(pendingDropoffs).ToList();

                var candidatePoints = new List<(double lat, double lng)>(candidateOrderIds.Count);
                var candidateMeta = new List<(int orderId, bool isPickup)>(candidateOrderIds.Count);

                foreach (var orderId in candidateOrderIds)
                {
                    var isPickup = pendingPickups.Contains(orderId);
                    var o = ordersById[orderId];

                    var lat = isPickup ? o.Order.PickupLat : o.Order.DropoffLat;
                    var lng = isPickup ? o.Order.PickupLng : o.Order.DropoffLng;

                    candidatePoints.Add(((double)lat!, (double)lng!));
                    candidateMeta.Add((orderId, isPickup));
                }

                // 🔥 One batched Distance Matrix call prices every
                // remaining candidate stop at once (1 origin x N
                // destinations), instead of one call per candidate per
                // step - was O(stops^2) raw API calls per route plan.
                var etas = await _mapService.GetEtasFromOriginAsync(
                    currentLat,
                    currentLng,
                    candidatePoints);

                RouteStepDto? best = null;
                double bestTime = double.MaxValue;

                for (int i = 0; i < candidateMeta.Count; i++)
                {
                    if (etas[i].TotalSeconds >= bestTime)
                        continue;

                    var (orderId, isPickup) = candidateMeta[i];
                    var o = ordersById[orderId];
                    var (lat, lng) = candidatePoints[i];

                    bestTime = etas[i].TotalSeconds;

                    best = new RouteStepDto
                    {
                        OrderId = o.OrderId,
                        Lat = lat,
                        Lng = lng,
                        IsPickup = isPickup,
                        Label = isPickup ? o.Order.PickupLocation : o.Order.DropoffLocation,
                        PassengerName = o.Order.Passenger?.User.FirstName + " " + o.Order.Passenger?.User.LastName,
                        PassengerId = o.Order.PassengerId
                    };
                }

                if (best == null)
                    break;

                seq++;
                best.Sequence = seq;
                best.EstimatedMinutes = EstimateMinutes(bestTime, currentLat, currentLng, best.Lat, best.Lng);

                steps.Add(best);

                currentLat = best.Lat;
                currentLng = best.Lng;

                if (best.IsPickup)
                    pendingPickups.Remove(best.OrderId);
                else
                    pendingDropoffs.Remove(best.OrderId);
            }

            return steps;
        }

        // Assumed average urban driving speed, used only as a fallback when
        // the routing service couldn't price a leg at all (see below).
        private const double FallbackMetersPerSecond = 500.0 / 60.0; // ~30 km/h

        // `bestTimeSeconds` comes straight from `IMapService.GetEtasFromOriginAsync`
        // (an OSRM Distance Matrix call). When every candidate for a step is
        // unreachable/the call fails, that service reports it via the
        // `TimeSpan.MaxValue` sentinel (~9.2e11 seconds) rather than throwing -
        // casting that directly to minutes-as-int overflowed `int` on the
        // `(int)(bestTime / 60)` cast (undefined/garbage value, typically
        // `int.MinValue` on this runtime), which then blew up `Enumerable.Sum`'s
        // checked accumulation in `RecalculateTripAsync`. Detect the sentinel (or
        // any other non-finite/unrealistic value) up front and substitute a
        // straight-line-distance estimate instead, then clamp to a sane range so
        // no value handed to callers can ever be invalid, negative, or huge.
        private static int EstimateMinutes(double bestTimeSeconds, double fromLat, double fromLng, double toLat, double toLng)
        {
            var isUnreliable = double.IsNaN(bestTimeSeconds) ||
                double.IsInfinity(bestTimeSeconds) ||
                bestTimeSeconds >= TimeSpan.MaxValue.TotalSeconds / 2;

            if (isUnreliable)
            {
                var meters = GeoUtils.HaversineMeters(fromLat, fromLng, toLat, toLng);
                bestTimeSeconds = meters / FallbackMetersPerSecond;
            }

            var minutes = bestTimeSeconds / 60.0;
            return (int)Math.Clamp(minutes, 1.0, 24.0 * 60.0);
        }
    }
}
