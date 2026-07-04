using System;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class MessageDto
    {
        public int MessageId { get; set; }
        public required string SenderUserId { get; set; }
        public required string SenderName { get; set; }
        public string? SenderProfilePhoto { get; set; }
        public required string ReceiverUserId { get; set; }
        public int? OrderId { get; set; }
        public int? TripId { get; set; }
        public required string Body { get; set; }
        public DateTime SentAt { get; set; }
        public bool IsRead { get; set; }
    }
}
