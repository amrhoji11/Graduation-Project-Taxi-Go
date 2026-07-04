using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Data;

namespace TaxiApp.Backend.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DevSeedController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IWebHostEnvironment _env;

        public DevSeedController(
            ApplicationDbContext context,
            UserManager<ApplicationUser> userManager,
            IWebHostEnvironment env)
        {
            _context = context;
            _userManager = userManager;
            _env = env;
        }

        /// Development-only demo data seeder: approved + pending drivers with
        /// Palestinian-style plates, passengers, completed trips with ratings
        /// (so the top-drivers leaderboard has real numbers), and one live
        /// Nablus -> Ramallah trip - gives the admin screens realistic data to
        /// demo against. Re-running is a no-op once the marker plate exists.
        [HttpPost("RunDemoSeed")]
        public async Task<IActionResult> RunDemoSeed()
        {
            if (!_env.IsDevelopment())
                return NotFound();

            if (await _context.Vehicles.AnyAsync(v => v.PlateNumber == "5-3333-H"))
                return Ok(new { message = "Demo data already seeded." });

            var now = DateTime.UtcNow;
            var rnd = new Random();

            var driversData = new[]
            {
                new { First = "محمد", Last = "العمري", Phone = "+970599100001", Approved = true,  Plate = "5-3333-H",  Make = "Hyundai", Model = "Elantra",  Color = "أبيض",  Size = Enums.Medium, Seats = 4 },
                new { First = "سامر", Last = "خليل",   Phone = "+970599100002", Approved = true,  Plate = "12-4521-A", Make = "Kia",      Model = "Sportage", Color = "أسود",  Size = Enums.Large,  Seats = 6 },
                new { First = "إياد",  Last = "منصور",  Phone = "+970599100003", Approved = true,  Plate = "3-7890-J",  Make = "Toyota",   Model = "Corolla",  Color = "فضي",   Size = Enums.Small,  Seats = 4 },
                new { First = "يوسف", Last = "الشريف", Phone = "+970599100004", Approved = false, Plate = "",          Make = "",         Model = "",         Color = "",      Size = Enums.Small,  Seats = 4 },
                new { First = "خالد", Last = "بدر",    Phone = "+970599100005", Approved = false, Plate = "",          Make = "",         Model = "",         Color = "",      Size = Enums.Small,  Seats = 4 },
            };

            var approvedDrivers = new List<Driver>();
            var pendingCount = 0;

            foreach (var d in driversData)
            {
                if (await _userManager.Users.AnyAsync(u => u.PhoneNumber == d.Phone))
                    continue;

                var user = new ApplicationUser
                {
                    UserName = d.Phone,
                    PhoneNumber = d.Phone,
                    FirstName = d.First,
                    LastName = d.Last,
                    CreatedAt = now,
                    IsPhoneVerified = true,
                };

                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded) continue;

                await _userManager.AddToRoleAsync(user, "Driver");

                var driver = new Driver
                {
                    UserId = user.Id,
                    Status = d.Approved ? DriverStatus.available : DriverStatus.offline,
                };
                _context.Drivers.Add(driver);

                _context.DriverApprovals.Add(new DriverApproval
                {
                    DriverId = user.Id,
                    Status = d.Approved ? ApprovalStatus.approved : ApprovalStatus.pending,
                    ReviewedAt = d.Approved ? now : null,
                    CreatedAt = now,
                });

                if (d.Approved)
                {
                    _context.Vehicles.Add(new Vehicle
                    {
                        DriverId = user.Id,
                        PlateNumber = d.Plate,
                        Make = d.Make,
                        Model = d.Model,
                        Color = d.Color,
                        VehicleSize = d.Size,
                        Seats = d.Seats,
                        IsActive = true,
                        IsCurrent = true,
                        CreatedAt = now,
                    });

                    approvedDrivers.Add(driver);
                }
                else
                {
                    pendingCount++;
                }
            }

            await _context.SaveChangesAsync();

            var passengersData = new[]
            {
                new { First = "ليان", Last = "حمدان", Phone = "+970599200001" },
                new { First = "نور",  Last = "فارس",  Phone = "+970599200002" },
                new { First = "هديل", Last = "عساف",  Phone = "+970599200003" },
            };

            var passengers = new List<Passenger>();

            foreach (var p in passengersData)
            {
                if (await _userManager.Users.AnyAsync(u => u.PhoneNumber == p.Phone))
                    continue;

                var user = new ApplicationUser
                {
                    UserName = p.Phone,
                    PhoneNumber = p.Phone,
                    FirstName = p.First,
                    LastName = p.Last,
                    CreatedAt = now,
                    IsPhoneVerified = true,
                };

                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded) continue;

                await _userManager.AddToRoleAsync(user, "Passenger");

                var passenger = new Passenger { UserId = user.Id };
                _context.Passengers.Add(passenger);
                passengers.Add(passenger);
            }

            await _context.SaveChangesAsync();

            var completedTrips = 0;

            if (passengers.Count > 0)
            {
                foreach (var driver in approvedDrivers)
                {
                    var tripsForDriver = rnd.Next(3, 6);

                    for (var i = 0; i < tripsForDriver; i++)
                    {
                        var passenger = passengers[rnd.Next(passengers.Count)];
                        var startedAt = now.AddDays(-rnd.Next(1, 20)).AddHours(-rnd.Next(0, 12));

                        var order = new Order
                        {
                            PassengerId = passenger.UserId,
                            PickupLat = 32.22m + (decimal)(rnd.NextDouble() * 0.05),
                            PickupLng = 35.25m + (decimal)(rnd.NextDouble() * 0.05),
                            DropoffLat = 31.90m + (decimal)(rnd.NextDouble() * 0.05),
                            DropoffLng = 35.20m + (decimal)(rnd.NextDouble() * 0.05),
                            PickupLocation = "نابلس - وسط البلد",
                            DropoffLocation = "رام الله - المنارة",
                            Priority = OrderPriority.Normal,
                            PassengerCount = rnd.Next(1, 3),
                            OrderTime = startedAt,
                            Status = OrderStatus.Completed,
                            CreatedAt = startedAt,
                        };
                        _context.Orders.Add(order);
                        await _context.SaveChangesAsync();

                        var trip = new Trip
                        {
                            DriverId = driver.UserId,
                            Status = TripStatus.Completed,
                            AssignedAt = startedAt,
                            StartTime = startedAt.AddMinutes(5),
                            EndTime = startedAt.AddMinutes(30),
                            CompletedAt = startedAt.AddMinutes(30),
                            CreatedAt = startedAt,
                        };
                        _context.Trips.Add(trip);
                        await _context.SaveChangesAsync();

                        _context.TripOrders.Add(new TripOrder
                        {
                            TripId = trip.TripId,
                            OrderId = order.OrderId,
                            AssignedAt = startedAt,
                            StatusInTrip = TripOrderStatus.DroppedOff,
                        });

                        _context.Ratings.Add(new Rating
                        {
                            TripId = trip.TripId,
                            OrderId = order.OrderId,
                            RaterUserId = passenger.UserId,
                            TargetUserId = driver.UserId,
                            Stars = rnd.Next(4, 6),
                            RatedAt = trip.CompletedAt!.Value,
                        });

                        completedTrips++;
                    }
                }

                await _context.SaveChangesAsync();
            }

            string? activeTripSummary = null;

            if (approvedDrivers.Count > 0 && passengers.Count > 0)
            {
                var activeDriver = approvedDrivers[0];
                activeDriver.Status = DriverStatus.busy;
                activeDriver.LastLat = 31.98m;
                activeDriver.LastLng = 35.20m;
                activeDriver.LastSeenAt = now;

                var activePassenger = passengers[0];

                var activeOrder = new Order
                {
                    PassengerId = activePassenger.UserId,
                    PickupLat = 32.2211m,
                    PickupLng = 35.2544m,
                    DropoffLat = 31.9038m,
                    DropoffLng = 35.2034m,
                    PickupLocation = "نابلس",
                    DropoffLocation = "رام الله",
                    Priority = OrderPriority.Normal,
                    PassengerCount = 2,
                    OrderTime = now.AddMinutes(-25),
                    Status = OrderStatus.AssignedToTrip,
                    CreatedAt = now.AddMinutes(-25),
                };
                _context.Orders.Add(activeOrder);
                await _context.SaveChangesAsync();

                var activeTrip = new Trip
                {
                    DriverId = activeDriver.UserId,
                    Status = TripStatus.InProgress,
                    AssignedAt = now.AddMinutes(-20),
                    StartTime = now.AddMinutes(-10),
                    CreatedAt = now.AddMinutes(-20),
                };
                _context.Trips.Add(activeTrip);
                await _context.SaveChangesAsync();

                _context.TripOrders.Add(new TripOrder
                {
                    TripId = activeTrip.TripId,
                    OrderId = activeOrder.OrderId,
                    AssignedAt = now.AddMinutes(-20),
                    StatusInTrip = TripOrderStatus.PickedUp,
                });

                await _context.SaveChangesAsync();

                activeTripSummary = $"Trip #{activeTrip.TripId}: نابلس -> رام الله (InProgress, driver {activeDriver.UserId})";
            }

            return Ok(new
            {
                message = "Demo data seeded successfully.",
                approvedDrivers = approvedDrivers.Count,
                pendingDrivers = pendingCount,
                passengersCreated = passengers.Count,
                completedTrips,
                activeTrip = activeTripSummary,
            });
        }
    }
}
