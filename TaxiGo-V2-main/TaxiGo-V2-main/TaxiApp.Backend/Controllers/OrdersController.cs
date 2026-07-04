using Mapster;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Helper;
using TaxiApp.Backend.Infrastructure.Repositories;

namespace TaxiApp.Backend.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Passenger")]
    public class OrdersController : BaseController
    {
        private readonly IOrderRepository orderRepository;
        private readonly OrderService orderService;
        private readonly IMapService mapService;

        public OrdersController(IOrderRepository orderRepository, OrderService orderService , IUserBlockRepository userBlockRepository, IUserRepository userRepository, IMapService mapService): base(userBlockRepository, userRepository)
        {
            this.orderRepository = orderRepository;
            this.orderService = orderService;
            this.mapService = mapService;
        }

        

        

       

        [HttpPost("CreateOrder")]
        public async Task<IActionResult> CreateOrder(CreateOrderDto dto)
        {
            var PassengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(PassengerId);
            if (accessCheck != null) return accessCheck;

            if (dto.ScheduledAt.HasValue && dto.ScheduledAt.Value <= DateTime.UtcNow)
                return BadRequest(new { message = "لا يمكن جدولة رحلة في وقت قد مضى" });

            var result= await orderService.CreateAndAssign(PassengerId,dto);
            if (result==null)
            {
                return BadRequest(result);
            }

            var detail = await orderRepository.GetOrderDetailAsync(PassengerId, result.OrderId);
            return Ok(detail);


        }

        [HttpGet("GetAll")]
        public async Task<IActionResult> GetAllOrders([FromQuery] int pageNumber, [FromQuery] int pageSize, [FromQuery] DateTime? fromDate,
    [FromQuery] DateTime? toDate)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            if (fromDate.HasValue && toDate.HasValue && fromDate > toDate)
            {
                return BadRequest("fromDate must be less than or equal to toDate");
            }

            var result = await orderRepository.GetOrdersForPassengerAsync(passengerId, pageNumber, pageSize, fromDate, toDate);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderById([FromRoute] int id)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var result = await orderRepository.GetOrderDetailAsync(passengerId, id);
            if (result == null)
            {
                return NotFound();
            }
            return Ok(result);
        }

        [HttpPut("{id}")]

        public async Task<IActionResult> EditOrder([FromRoute] int id , [FromBody] EditOrderDto dto)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var result = await orderRepository.EditOrder(passengerId, id,dto);


            return Ok(result);

        }

        [HttpPut("{id}/Cancel")]

        public async Task<IActionResult> CancelOrder([FromRoute] int id)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;


            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var result = await orderRepository.CancelOrder(passengerId,id);
            return Ok(result);
        }

        /// Real road route between two arbitrary points, for the Create
        /// Order screen's map preview - no order/trip exists yet at this
        /// point, so this can't reuse TripRoutingService (which plans a
        /// trip's stops). Same response shape (`polyline`/`routePoints`/
        /// `totalMinutes`) as `PassengerTripsController.GetRoute` so the
        /// mobile app's existing `TripRouteModel.fromJson` parses both.
        [HttpGet("PreviewRoute")]
        public async Task<IActionResult> PreviewRoute(
            [FromQuery] double pickupLat,
            [FromQuery] double pickupLng,
            [FromQuery] double dropoffLat,
            [FromQuery] double dropoffLng)
        {
            var passengerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            var accessCheck = await CheckUserAccessAsync(passengerId);
            if (accessCheck != null) return accessCheck;

            var polyline = await mapService.GetRoutePolylineAsync(
                new List<(double lat, double lng)>
                {
                    (pickupLat, pickupLng),
                    (dropoffLat, dropoffLng),
                });

            var routePoints = GeoUtils.DecodePolyline(polyline)
                .Select(p => new RoutePointDto { Lat = p.Lat, Lng = p.Lng })
                .ToList();

            var eta = await mapService.GetETAAsync(
                (decimal)pickupLat, (decimal)pickupLng,
                (decimal)dropoffLat, (decimal)dropoffLng);

            var totalMinutes = eta == TimeSpan.MaxValue
                ? 0
                : (int)Math.Ceiling(eta.TotalMinutes);

            return Ok(new
            {
                polyline,
                routePoints,
                totalMinutes,
            });
        }

    }
}
