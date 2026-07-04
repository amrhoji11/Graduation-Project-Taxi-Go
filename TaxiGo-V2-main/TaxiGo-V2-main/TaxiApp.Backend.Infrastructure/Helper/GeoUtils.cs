using System;
using System.Collections.Generic;

namespace TaxiApp.Backend.Infrastructure.Helper
{
    /// Straight-line (great-circle) distance helper - the fallback used
    /// wherever a real road-network distance/ETA from Google's Directions/
    /// Distance Matrix APIs isn't available (no/placeholder API key, request
    /// failure, etc). Deliberately simple: no road geometry, just a lower
    /// bound on real driving distance.
    public static class GeoUtils
    {
        private const double EarthRadiusMeters = 6371000;

        public static double HaversineMeters(double lat1, double lng1, double lat2, double lng2)
        {
            double dLat = ToRadians(lat2 - lat1);
            double dLng = ToRadians(lng2 - lng1);

            double a =
                Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLng / 2) * Math.Sin(dLng / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return EarthRadiusMeters * c;
        }

        private static double ToRadians(double degrees) => degrees * Math.PI / 180.0;

        /// Decodes Google's "encoded polyline algorithm format" (the string
        /// `GetRoutePolylineAsync` returns) into plain lat/lng points.
        /// Standard algorithm - see Google's polyline encoding spec.
        public static List<(double Lat, double Lng)> DecodePolyline(string encoded)
        {
            var points = new List<(double Lat, double Lng)>();

            if (string.IsNullOrEmpty(encoded))
                return points;

            int index = 0, lat = 0, lng = 0;

            while (index < encoded.Length)
            {
                int result = 1, shift = 0, b;

                do
                {
                    b = encoded[index++] - 63 - 1;
                    result += b << shift;
                    shift += 5;
                } while (b >= 0x1f);

                lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

                result = 1;
                shift = 0;

                do
                {
                    b = encoded[index++] - 63 - 1;
                    result += b << shift;
                    shift += 5;
                } while (b >= 0x1f);

                lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

                points.Add((lat * 1e-5, lng * 1e-5));
            }

            return points;
        }
    }
}
