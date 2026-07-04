using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Helper;

namespace TaxiApp.Backend.Api.Controllers
{
    [Authorize(Roles ="Passenger")]
    [Route("api/[controller]")]
    [ApiController]
    public class PassengerTripsController : BaseController
    {
        private readonly IPassengerRepository passengerRepository;
        private readonly IOrderRepository orderRepository;
        private readonly TripRoutingService tripRoutingService;

        public PassengerTripsController(IPassengerRepository passengerRepository, IOrderRepository orderRepository, TripRoutingService tripRoutingService, IUserBlockRepository userBlockRepository, IUserRepository userRepository) : base(userBlockRepository, userRepository)
        {
            this.passengerRepository = passengerRepository;
            this.orderRepository = orderRepository;
            this.tripRoutingService = tripRoutingService;
        }

        [HttpPost("rate-driver")]
        public async Task<IActionResult> RateDriver([FromBody] RateDriverRequest request)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var result = await passengerRepository.RateDriverAsync(
                request.OrderId,
                passengerId,
                request.Stars,
                request.Comment
            );

            if (result != "Rating submitted successfully")
                return BadRequest(new { message = result });

            return Ok(new { message = result });
        }

        /// Real road route + ETA for this order's trip - the pull
        /// counterpart to the passenger-safe `RouteUpdated` SignalR push,
        /// for when this screen is opened/reopened after the last push
        /// already fired. Only the passenger-safe subset is returned
        /// (no per-stop passenger names, mirroring the SignalR payload).
        [HttpGet("route/{orderId}")]
        public async Task<IActionResult> GetRoute([FromRoute] int orderId)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var order = await orderRepository.GetOrderDetailAsync(passengerId, orderId);
            if (order == null || order.TripId == null)
                return NotFound(new { message = "No active trip for this order" });

            var route = await tripRoutingService.RecalculateTripAsync(order.TripId.Value);

            return Ok(new
            {
                polyline = route.Polyline,
                routePoints = route.RoutePoints,
                totalMinutes = route.TotalMinutes
            });
        }
    }
}
