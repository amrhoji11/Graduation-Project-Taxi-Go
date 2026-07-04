using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.Models
{
    public class FavoriteLocation
    {
        public int Id { get; set; }
        public required string UserId { get; set; }

        // اسم الموقع (منزل، عمل، نادي...)
        public required string Name { get; set; }

        // العنوان المكتوب نصيًا
        public required string Address { get; set; }

        // الإحداثيات من الخريطة
        public double Latitude { get; set; }
        public double Longitude { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ApplicationUser? User { get; set; }
    }
}
