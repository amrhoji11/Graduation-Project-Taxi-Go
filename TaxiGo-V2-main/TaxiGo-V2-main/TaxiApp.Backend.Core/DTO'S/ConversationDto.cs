using System;

namespace TaxiApp.Backend.Core.DTO_S
{
    public class ConversationDto
    {
        public int OrderId { get; set; }
        public int? TripId { get; set; }
        public required string OtherUserId { get; set; }
        public string OtherUserName { get; set; } = string.Empty;
        public string? OtherUserProfilePhoto { get; set; }
        public required string LastMessageBody { get; set; }
        public required string LastMessageSenderId { get; set; }
        public DateTime LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
    }
}
