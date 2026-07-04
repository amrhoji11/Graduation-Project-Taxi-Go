using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Data;
using TaxiApp.Backend.Infrastructure.Helper;

namespace TaxiApp.Backend.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles ="Driver")]
    public class DriverTripsController : BaseController
    {
        private readonly IDriverAssignmentRepository driverAssignment;
        private readonly IOrderRepository orderRepository;
        private readonly IMapService mapService;
        private readonly TripRoutingService tripRoutingService;

        public DriverTripsController(IDriverAssignmentRepository driverAssignment, IOrderRepository orderRepository, IMapService mapService, TripRoutingService tripRoutingService, IUserBlockRepository userBlockRepository,
                                IUserRepository userRepository): base(userBlockRepository, userRepository)
        {
            this.driverAssignment = driverAssignment;
            this.orderRepository = orderRepository;
            this.mapService = mapService;
            this.tripRoutingService = tripRoutingService;
        }
        [HttpGet("active")]
        public async Task<IActionResult> GetActiveState()
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var state = await driverAssignment.GetActiveStateAsync(driverId);
            return Ok(state);
        }

        /// Real road route + ETA for the driver's own active trip - the
        /// pull counterpart to the `RouteUpdated` SignalR push, for when
        /// this screen is opened/reopened after the last push already
        /// fired (e.g. app restart, reconnect).
        [HttpGet("route/{tripId}")]
        public async Task<IActionResult> GetRoute([FromRoute] int tripId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var state = await driverAssignment.GetActiveStateAsync(driverId);
            if (state.Trip == null || state.Trip.TripId != tripId)
                return NotFound(new { message = "No active trip with this id for this driver" });

            var route = await tripRoutingService.RecalculateTripAsync(tripId);
            return Ok(route);
        }

        [EnableRateLimiting("DriverActionsPolicy")]
        [HttpPost("accept-order/{orderId}")]
        public async Task<IActionResult> AcceptOrder([FromRoute] int orderId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.DriverAcceptOrderAsync(orderId, driverId);

            if (result != "Order added to existing trip" && result != "Trip created successfully")
                return BadRequest(new { message = result });



            return Ok(result);
        }

        [EnableRateLimiting("DriverActionsPolicy")]
        [HttpPost("reject-order/{orderId}")]
        public async Task<IActionResult> RejectOrder([FromRoute]int orderId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck; 

            var result = await driverAssignment.DriverRejectOrderAsync(orderId, driverId);

            if (!result.Contains("Driver"))
                return BadRequest(new { message = result });



            return Ok(result);
        }

        // Accept Full Trip (Emergency)
        [HttpPost("accept-trip/{tripId}")]
        public async Task<IActionResult> AcceptTrip([FromRoute]int tripId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.DriverAcceptTripAsync(tripId, driverId);

            if (result != "Trip accepted")
                return BadRequest(new { message = result });



            return Ok(new { message = result });
        }


        // Reject Full Trip
        [HttpPost("reject-trip/{tripId}")]
        public async Task<IActionResult> RejectTrip([FromRoute]int tripId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.DriverRejectTripAsync(tripId, driverId);

            if (!result.Contains("offer"))
                return BadRequest(new { message = result });


            return Ok(new { message = result });
        }


        [HttpPost("arrived/{orderId}")]
        public async Task<IActionResult> Arrived([FromRoute] int orderId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.DriverArrivedAsync(orderId, driverId);

            if (result != "Arrived notification sent")
                return BadRequest(new { message = result });

            return Ok(result);

        }


        [HttpPost("start-trip/{tripId}")]
        public async Task<IActionResult> StartTrip([FromRoute]int tripId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.StartTripAsync(tripId, driverId);

            if (result != "Trip started successfully")
                return BadRequest(new { message = result });



            return Ok(result);
        }


        [HttpPost("pickup/{orderId}")]
        public async Task<IActionResult> Pickup([FromRoute]int orderId)
        {
            var driverId =User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.PickupAsync(driverId, orderId);

            if (result != "Pickup successful")
                return BadRequest(new { message = result });

            return Ok(new { message = result });
        }


        [HttpPost("dropoff/{orderId}")]
        public async Task<IActionResult> Dropoff([FromRoute] int orderId)
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.DropoffAsync(driverId, orderId);

            if (result != "Success")
                return BadRequest(new { message = result });

            return Ok(new { message = "Passenger dropped off successfully" });
        }


        [HttpPost("cancel-trip/{tripId}")]
        public async Task<IActionResult> CancelTrip([FromRoute]int tripId,[FromBody] CancelTripDto dto )
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result= await driverAssignment.CancelTripByDriverAsync(tripId, driverId, dto.Reason);

            if (!result.Contains("success"))
                return BadRequest(new { message = result });

            return Ok(result);
        }

       


        [HttpPost("enter-queue")]
        public async Task<IActionResult> EnterQueue()
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result =  await driverAssignment.EnterQueueAsync(driverId);

            if (result != "Entered successfully")
                return BadRequest(new { message = result });

            return Ok(new { message = result });

        }

        [HttpPost("leave-queue")]
        public async Task<IActionResult> LeaveQueue()
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.LeaveQueueAsync(driverId);

            if (result != "Left successfully")
                return BadRequest(new { message = result });

            return Ok(new { message = result });
        }

        [HttpPost("return-to-office")]
        public async Task<IActionResult> ReturnToOffice()
        {
            var driverId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(driverId);
            if (accessCheck != null) return accessCheck;

            var result = await driverAssignment.ReturnToOfficeAsync(driverId);

            if (result != "Marked as returning to office")
                return BadRequest(new { message = result });

            return Ok(new { message = result });
        }
    }
}
