using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Infrastructure.Helper
{
    /// <see cref="IMapService"/> backed by the public OSRM demo server
    /// (no API key required). OSRM's `geometries=polyline` uses the same
    /// encoded-polyline format (precision 5) as Google Directions, so
    /// `GeoUtils.DecodePolyline` works unchanged against it. Note OSRM
    /// coordinates are ordered lng,lat (the opposite of Google/this app's
    /// own lat,lng convention) - every URL builder below converts carefully.
    public class OsrmMapService : IMapService
    {
        private readonly string _baseUrl;
        private readonly HttpClient _httpClient;

        public OsrmMapService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _baseUrl = (configuration["Osrm:BaseUrl"] ?? "https://router.project-osrm.org").TrimEnd('/');
        }

        public async Task<TimeSpan> GetETAAsync(
            decimal originLat,
            decimal originLng,
            decimal destLat,
            decimal destLng)
        {
            var durations = await GetTableDurationsAsync(
                new List<(double lat, double lng)> { ((double)originLat, (double)originLng) },
                new List<(double lat, double lng)> { ((double)destLat, (double)destLng) });

            return durations.Count > 0 && durations[0].Count > 0 ? durations[0][0] : TimeSpan.MaxValue;
        }

        public async Task<List<TimeSpan>> GetDistancesAsync(
            List<DriverLocationDto> drivers,
            double destLat,
            double destLng)
        {
            if (drivers == null || drivers.Count == 0)
                return new List<TimeSpan>();

            var sources = drivers.Select(d => (d.Lat, d.Lng)).ToList();
            var destinations = new List<(double lat, double lng)> { (destLat, destLng) };

            var durations = await GetTableDurationsAsync(sources, destinations);

            if (durations.Count == 0)
                return drivers.Select(_ => TimeSpan.MaxValue).ToList();

            return durations.Select(row => row.Count > 0 ? row[0] : TimeSpan.MaxValue).ToList();
        }

        public async Task<List<TimeSpan>> GetEtasFromOriginAsync(
            double originLat,
            double originLng,
            List<(double lat, double lng)> destinations)
        {
            if (destinations == null || destinations.Count == 0)
                return new List<TimeSpan>();

            var sources = new List<(double lat, double lng)> { (originLat, originLng) };

            var durations = await GetTableDurationsAsync(sources, destinations);

            return durations.Count > 0
                ? durations[0]
                : destinations.Select(_ => TimeSpan.MaxValue).ToList();
        }

        public async Task<string> GetRoutePolylineAsync(List<(double lat, double lng)> points)
        {
            if (points == null || points.Count < 2)
                return "";

            try
            {
                var coords = string.Join(";", points.Select(p => FormatCoord(p.lng, p.lat)));

                string url = $"{_baseUrl}/route/v1/driving/{coords}?overview=full&geometries=polyline";

                var response = await _httpClient.GetAsync(url);
                if (!response.IsSuccessStatusCode)
                    return "";

                var json = await response.Content.ReadAsStringAsync();

                using var doc = JsonDocument.Parse(json);

                if (doc.RootElement.GetProperty("code").GetString() != "Ok")
                    return "";

                var routes = doc.RootElement.GetProperty("routes");

                if (routes.GetArrayLength() == 0)
                    return "";

                return routes[0].GetProperty("geometry").GetString() ?? "";
            }
            catch
            {
                return "";
            }
        }

        // ===============================
        // OSRM Table API - many-to-many durations (seconds), mirrors
        // Google's Distance Matrix shape. Returns a [sources][destinations]
        // matrix of TimeSpans, TimeSpan.MaxValue for any unreachable pair.
        // ===============================
        private async Task<List<List<TimeSpan>>> GetTableDurationsAsync(
            List<(double lat, double lng)> sources,
            List<(double lat, double lng)> destinations)
        {
            try
            {
                var allCoords = sources.Concat(destinations).ToList();
                var coordsParam = string.Join(";", allCoords.Select(p => FormatCoord(p.lng, p.lat)));

                var sourceIndexes = string.Join(";", Enumerable.Range(0, sources.Count));
                var destIndexes = string.Join(";", Enumerable.Range(sources.Count, destinations.Count));

                string url = $"{_baseUrl}/table/v1/driving/{coordsParam}" +
                             $"?sources={sourceIndexes}&destinations={destIndexes}";

                var response = await _httpClient.GetAsync(url);

                if (!response.IsSuccessStatusCode)
                    return EmptyMatrix(sources.Count, destinations.Count);

                var json = await response.Content.ReadAsStringAsync();

                using var doc = JsonDocument.Parse(json);

                if (doc.RootElement.GetProperty("code").GetString() != "Ok")
                    return EmptyMatrix(sources.Count, destinations.Count);

                var durationsJson = doc.RootElement.GetProperty("durations");

                var result = new List<List<TimeSpan>>();

                foreach (var row in durationsJson.EnumerateArray())
                {
                    var rowResult = new List<TimeSpan>();

                    foreach (var cell in row.EnumerateArray())
                    {
                        rowResult.Add(cell.ValueKind == JsonValueKind.Null
                            ? TimeSpan.MaxValue
                            : TimeSpan.FromSeconds(cell.GetDouble()));
                    }

                    result.Add(rowResult);
                }

                return result;
            }
            catch
            {
                return EmptyMatrix(sources.Count, destinations.Count);
            }
        }

        private static List<List<TimeSpan>> EmptyMatrix(int sourceCount, int destCount)
        {
            return Enumerable.Range(0, sourceCount)
                .Select(_ => Enumerable.Repeat(TimeSpan.MaxValue, destCount).ToList())
                .ToList();
        }

        private static string FormatCoord(double lng, double lat) =>
            $"{lng.ToString(CultureInfo.InvariantCulture)},{lat.ToString(CultureInfo.InvariantCulture)}";
    }
}
