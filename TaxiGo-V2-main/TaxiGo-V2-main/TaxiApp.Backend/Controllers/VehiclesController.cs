using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Helper;
using TaxiApp.Backend.Infrastructure.Repositories;

namespace TaxiApp.Backend.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles ="Admin")]

    public class VehiclesController : BaseController
    {
        private readonly IVehicleRepository vehicleRepository;

        public VehiclesController(IVehicleRepository vehicleRepository,IUserBlockRepository userBlockRepository,IUserRepository userRepository) :base(userBlockRepository, userRepository)
        {
            this.vehicleRepository = vehicleRepository;
        }
        [HttpGet("GetAll")]
        public async Task<IActionResult> GetAll([FromQuery] int pageNumber, [FromQuery] int pageSize)
        {
            var vehicles = await vehicleRepository.GetAllVehiclesAsync(pageNumber, pageSize);
            foreach (var vehicle in vehicles)
            {
                vehicle.PlatePhotoUrl = ImageUrlHelper.BuildImageUrl(Request, vehicle.PlatePhotoUrl);
            }
            return Ok(vehicles);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] int id)
        {
            var vehicle = await vehicleRepository.Get(a => a.VehicleId == id);
            if (vehicle == null)
            {
                return NotFound();
            }
            var result = vehicle.Adapt<VehiclesResponseDto>();
            result.PlatePhotoUrl = ImageUrlHelper.BuildImageUrl(Request, result.PlatePhotoUrl);
            return Ok(result);

        }

        [HttpPost("AddVehicle")]
        public async Task<IActionResult> AddVehicle([FromForm] AddVehicleDto dto)
        {
            var (result, error) = await vehicleRepository.AddVehicel(dto);
            if (result == null)
            {
                return BadRequest(new { message = error });
            }
            result.PlatePhotoUrl = ImageUrlHelper.BuildImageUrl(Request, result.PlatePhotoUrl);
            return Ok(result);

        }

        [HttpPut("{id}/Edit")]
        public async Task<IActionResult> Edit([FromRoute] int id ,[FromForm] EditVehicleDto dto)
        {
            var result = await vehicleRepository.EditVehicle(id, dto);
            if (result==false)
            {
                return BadRequest();

            }
            return NoContent();

        }
        [HttpGet("GetUnassignedAsync")]
        public async Task<IActionResult> GetUnassignedAsync([FromQuery] int pageNumber, [FromQuery] int pageSize)
        {
            var vehicle = await vehicleRepository.GetUnassignedAsync(pageNumber, pageSize);
            var result = vehicle.Adapt<IEnumerable<VehiclesResponseDto>>();
            foreach (var item in result)
            {
                item.PlatePhotoUrl = ImageUrlHelper.BuildImageUrl(Request, item.PlatePhotoUrl);
            }
            return Ok(result);
        }

        [HttpPost("{vehicleId}/Unassign")]
        public async Task<IActionResult> Unassign([FromRoute] int vehicleId)
        {
            var vehicel = await vehicleRepository.Unassigned(vehicleId);
            if (!vehicel)
            {
                return BadRequest(new {message="المركبة غير موجودة"});
            }
            return NoContent();
        }

        [HttpPatch("{vehicleId}/status")]
        public async Task<IActionResult> UpdateVehicleStatus(int vehicleId) //يعني active ولا لا
        {
            var result = await vehicleRepository.ToggleActive(vehicleId);

            if (!result)
                return NotFound();

            return NoContent(); // 204
        }

        [HttpPatch("AssignVehicleToDriver/{vehicleId}")]
        public async Task<IActionResult> AssignVehicleToDriver([FromRoute] int vehicleId , [FromBody] AssignVehicleDto dto)
        {
            
            var accessCheck = await CheckUserAccessAsync(dto.DriverId);
            if (accessCheck != null) return accessCheck;

            var result = await vehicleRepository.AssignVehicleToDriver(vehicleId,dto.DriverId);
            if (!result)
            {
                return BadRequest(new {message = "فشل ربط المركبة بالسائق"});
            }
            return NoContent();

        }
    }
}
