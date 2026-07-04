using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.DTO_S;
using TaxiApp.Backend.Core.Interfaces;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Data;

namespace TaxiApp.Backend.Infrastructure.Repositories
{
    public class VehicleRepository : Repository<Vehicle>, IVehicleRepository
    {
        private readonly ApplicationDbContext context;
        public VehicleRepository(ApplicationDbContext context) : base(context)
        {
            this.context = context;
        }

        public async Task<(VehiclesResponseDto? Result, string? Error)> AddVehicel(AddVehicleDto dto)
        {
            var driver = await context.Drivers
                .Include(d => d.User)
                .FirstOrDefaultAsync(d => d.UserId == dto.DriverId && !d.IsDeleted);

            if (driver == null)
                return (null, "السائق غير موجود");

            var approval = await context.DriverApprovals
                .FirstOrDefaultAsync(a => a.DriverId == dto.DriverId);

            if (approval == null || approval.Status != ApprovalStatus.approved)
                return (null, "لا يمكن تسجيل مركبة إلا لسائق تمت الموافقة عليه");

            // إلغاء أي سيارة حالية لهذا السائق قبل ربط الجديدة (نفس منطق AssignVehicleToDriver)
            var currentVehicle = await context.Vehicles
                .FirstOrDefaultAsync(v => v.DriverId == dto.DriverId && v.IsCurrent);

            if (currentVehicle != null)
            {
                currentVehicle.IsCurrent = false;
                currentVehicle.DriverId = null;
            }

            var vehicle = new Vehicle
            {
                DriverId = dto.DriverId,
                PlateNumber = dto.PlateNumber,
                VehicleSize = dto.VehicleSize,
                Seats = dto.Seats,
                Make = dto.Make,
                Model = dto.Model,
                Color = dto.Color,
                Year = dto.Year,
                IsActive = true,
                IsCurrent = true
            };
            var platePhoto = dto.PlatePhotoImg;
            // حفظ الصورة إذا وجدت
            if (platePhoto != null && platePhoto.Length > 0)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(platePhoto.FileName);
                var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "Images");

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                var filePath = Path.Combine(folderPath, fileName);

                using (var stream = System.IO.File.Create(filePath))
                {
                    await platePhoto.CopyToAsync(stream);
                }

                vehicle.PlatePhotoUrl = fileName; // تخزين اسم الملف في DB
            }

            // إضافة المركبة لقاعدة البيانات
            context.Vehicles.Add(vehicle);
            await context.SaveChangesAsync();

            return (new VehiclesResponseDto
            {
                VehicleId = vehicle.VehicleId,
                DriverId = vehicle.DriverId,
                DriverName = driver.User.FirstName + " " + driver.User.LastName,
                PlatePhotoUrl = vehicle.PlatePhotoUrl,
                PlateNumber = vehicle.PlateNumber,
                VehicleSize = vehicle.VehicleSize,
                Seats = vehicle.Seats,
                Make = vehicle.Make,
                Model = vehicle.Model,
                Color = vehicle.Color,
                Year = vehicle.Year,
                IsActive = vehicle.IsActive,
                IsCurrent = vehicle.IsCurrent,
                CreatedAt = vehicle.CreatedAt,
                UpdatedAt = vehicle.UpdatedAt
            }, null);
        }

        public async Task<List<VehiclesResponseDto>> GetAllVehiclesAsync(int pageNumber, int pageSize)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;

            return await context.Vehicles
                .Include(v => v.Driver)
                    .ThenInclude(d => d!.User)
                .OrderBy(v => v.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(v => new VehiclesResponseDto
                {
                    VehicleId = v.VehicleId,
                    DriverId = v.DriverId,
                    DriverName = v.Driver != null ? v.Driver.User.FirstName + " " + v.Driver.User.LastName : null,
                    PlatePhotoUrl = v.PlatePhotoUrl,
                    PlateNumber = v.PlateNumber,
                    VehicleSize = v.VehicleSize,
                    Seats = v.Seats,
                    Make = v.Make,
                    Model = v.Model,
                    Color = v.Color,
                    Year = v.Year,
                    IsActive = v.IsActive,
                    IsCurrent = v.IsCurrent,
                    CreatedAt = v.CreatedAt,
                    UpdatedAt = v.UpdatedAt
                })
                .ToListAsync();
        }

        public async Task<bool> AssignVehicleToDriver(int vehicleId, string driverId)
        {
            var driver  = await context.Drivers.FindAsync(driverId);
            if (driver == null)
            {
                return false;
            }

            var approval = await context.DriverApprovals
                .FirstOrDefaultAsync(a => a.DriverId == driverId);

            if (approval == null || approval.Status != ApprovalStatus.approved)
                return false;

            var vehicle = await context.Vehicles
                    .FirstOrDefaultAsync(v => v.VehicleId == vehicleId);

            if (vehicle == null || !vehicle.IsActive)
                return false;

            // 1️⃣ إلغاء أي سيارة حالية للسائق
            var currentVehicle = await context.Vehicles
                .FirstOrDefaultAsync(v => v.DriverId == driverId && v.IsCurrent);

            if (currentVehicle != null)
            {
                currentVehicle.IsCurrent = false;
                currentVehicle.DriverId = null;
            }

            // 2️⃣ ربط السيارة الجديدة
            vehicle.DriverId = driverId;
            vehicle.IsCurrent = true;

            await context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> EditVehicle(int id,EditVehicleDto dto)
        {
            var vehicle = await context.Vehicles
        .FirstOrDefaultAsync(a => a.VehicleId == id);

            if (vehicle == null)
                return false;

            // تحديث فقط القيم التي تم إرسالها
            if (dto.PlateNumber != null)
                vehicle.PlateNumber = dto.PlateNumber;

            if (dto.VehicleSize.HasValue)
                vehicle.VehicleSize = dto.VehicleSize.Value;

            if (dto.Seats.HasValue)
                vehicle.Seats = dto.Seats.Value;

            if (dto.Make != null)
                vehicle.Make = dto.Make;

            if (dto.Model != null)
                vehicle.Model = dto.Model;

            if (dto.Color != null)
                vehicle.Color = dto.Color;

            if (dto.Year.HasValue)
                vehicle.Year = dto.Year;

            // ❌ لا تعدل DriverId من هنا (يفضل)
            // ❌ لا تعدل IsActive
            // ❌ لا تعدل IsCurrent

            var file = dto.PlatePhotoImg;

            if (file != null && file.Length > 0)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "Images");

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                var filePath = Path.Combine(folderPath, fileName);

                using (var stream = System.IO.File.Create(filePath))
                {
                    await file.CopyToAsync(stream);
                }

                // حذف القديمة إذا موجودة
                if (!string.IsNullOrEmpty(vehicle.PlatePhotoUrl))
                {
                    var oldFilePath = Path.Combine(folderPath, vehicle.PlatePhotoUrl);
                    if (System.IO.File.Exists(oldFilePath))
                        System.IO.File.Delete(oldFilePath);
                }

                vehicle.PlatePhotoUrl = fileName;
            }

            vehicle.UpdatedAt = DateTime.UtcNow;

            await context.SaveChangesAsync();
            return true;
        }
        

        public async Task<IEnumerable<Vehicle>> GetUnassignedAsync(int pageNumber = 1, int pageSize = 10)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 10;

            return await context.Vehicles
                                .Include(a => a.Driver)
                                .Where(a => a.DriverId == null).OrderBy(a => a.CreatedAt) 
                                .Skip((pageNumber - 1) * pageSize)
                                .Take(pageSize).ToListAsync();
            
        }

        public async Task<bool> ToggleActive(int vehicleId)
        {
            var vehicle = await Get(a => a.VehicleId == vehicleId);
            if (vehicle == null)
            { 
                return false;
            }
            vehicle.IsActive= !vehicle.IsActive;

            if (!vehicle.IsActive)
            {
                vehicle.IsCurrent=false ;
                vehicle.DriverId = null;
            }

            await context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> Unassigned(int vehicleId)
        {
            var vehicle = await Get(a => a.VehicleId == vehicleId);
            if (vehicle ==  null)
            {
                return false;
            }

            vehicle.DriverId = null;
            vehicle.IsCurrent = false;

            await context.SaveChangesAsync();
            return true;
        }
    }
}
