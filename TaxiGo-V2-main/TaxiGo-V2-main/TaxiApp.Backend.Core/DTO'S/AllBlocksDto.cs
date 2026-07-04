using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class AllBlocksDto
    {
        public required string UserId { get; set; }

        public required string FirstName { get; set; }
        public required string  LastName { get; set; }
        [MaxLength(10)]
        [MinLength(10)]
        public string? PhoneNumber { get; set; }

        [MaxLength(500)]
        public string? Reason { get; set; }
        public DateTime? StartsAt { get; set; }


        public DateTime? EndsAt { get; set; }
    }
}
