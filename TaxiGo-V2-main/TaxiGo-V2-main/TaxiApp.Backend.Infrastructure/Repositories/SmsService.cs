using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TaxiApp.Backend.Core.Interfaces;

namespace TaxiApp.Backend.Infrastructure.Repositories
{
    public class SmsService : ISmsService
    {
        private readonly IConfiguration _config;
        private readonly IHostEnvironment _environment;
        private readonly ILogger<SmsService> _logger;

        public SmsService(IConfiguration config, IHostEnvironment environment, ILogger<SmsService> logger)
        {
            _config = config;
            _environment = environment;
            _logger = logger;
        }

        public async Task<bool> SendSms(string to, string message)
        {
            // Development-only bypass: lets the OTP flow be tested end-to-end without
            // real Twilio credentials by printing the OTP instead of sending it.
            // Never runs outside IHostEnvironment.IsDevelopment(), so Production always
            // requires a real Twilio send.
            if (_environment.IsDevelopment())
            {
                Console.WriteLine($"[DEV OTP MODE] SMS to {to}: {message}");
                _logger.LogWarning("[DEV OTP MODE] SMS to {To}: {Message}", to, message);
                return true;
            }

            try
            {
                var sid = _config["Twilio:AccountSid"];
                var token = _config["Twilio:AuthToken"];
                var from = _config["Twilio:FromPhone"];

                TwilioClient.Init(sid, token);

           var result = await  MessageResource.CreateAsync(
                    body: message,
                    from: new Twilio.Types.PhoneNumber(from),
                    to: new Twilio.Types.PhoneNumber(to)
                );

                return result.ErrorCode == null;
            }
            catch
            {
                return false;
            }
        }
    }
}