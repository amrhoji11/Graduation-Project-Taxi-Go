using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class TempRegisterData
    {
        public required string FirstName { get; set; }
        public required string LastName { get; set; }
        public required string FullPhone { get; set; }
        public required string Address { get; set; }
    }
}
