using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class UserListDto
    {
        public required string UserId { get; set; }
        public required string FullName { get; set; }
        public string? Role { get; set; }
        public bool IsActive { get; set; }
        public bool IsBlocked { get; set; }
        public bool IsDeleted { get; set; }
    }

}
