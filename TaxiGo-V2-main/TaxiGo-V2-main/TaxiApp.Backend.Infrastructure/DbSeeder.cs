using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.Models;
using TaxiApp.Backend.Infrastructure.Data;
using TaxiApp.Backend.Infrastructure.Helper;

namespace TaxiApp.Backend.Infrastructure
{
    public static class DbSeeder
    {
        public static async Task SeedAdminAsync(IServiceProvider serviceProvider)
        {
            var userManager = serviceProvider.GetRequiredService<UserManager<ApplicationUser>>();

            // Must match the same international format every login/registration
            // path builds via PhoneHelper.BuildInternationalPhone (countryCode +
            // local digits with any leading "0" stripped) - storing the raw
            // local-format string here meant LoginAsync's `PhoneNumber == fullPhone`
            // lookup could never match this seeded account, confirmed by a real
            // runtime login attempt returning "رقم الهاتف غير مسجل."
            var adminPhone = PhoneHelper.BuildInternationalPhone("+970", "0595541748");

            var adminUser = await userManager.FindByNameAsync("amrhoji");

            if (adminUser == null)
            {
                var officeAdmin = new ApplicationUser
                {
                    FirstName="Amr",
                    LastName="Hoji",
                    UserName = "amrhoji",
                    PhoneNumber = adminPhone,
                    Email = "admin@taxiapp.com",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true
                    // أضف أي حقول إضافية يحتاجها موديل الـ User عندك
                };

                var result = await userManager.CreateAsync(officeAdmin, "Admin@123"); // كلمة سر افتراضية
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(officeAdmin, "Admin");
                }
            }
        }
    }
}
