using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.Models;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class AddVehicleDto
    {
        [Required]
        public required string DriverId { get; set; }

        [Required]
        [MaxLength(20)]
        public required string PlateNumber { get; set; }

        public IFormFile? PlatePhotoImg { get; set; }

        public Enums VehicleSize { get; set; }//حجم السيارة
        public int Seats { get; set; }//عدد المقاعد المتوفرةللركاب

        public required string Make { get; set; }//الشركة المصنعة مثل Kia
        public required string Model { get; set; }
        public required string Color { get; set; }
        public int? Year { get; set; }
    }
}
