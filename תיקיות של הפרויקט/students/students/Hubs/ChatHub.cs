using Microsoft.AspNetCore.SignalR;
using students.Data;
using students.Models;

namespace students.Hubs
{
    public class ChatHub : Hub
    {
        private readonly ApplicationDbContext _context;

        public ChatHub(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task SendMessage(string senderId, string receiverId, string messageText)
        {
            var message = new Message
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                MessageText = messageText,
                Timestamp = DateTime.UtcNow
            };

            _context.Messages.Add(message);
            await _context.SaveChangesAsync();

            await Clients.All.SendAsync("ReceiveMessage", senderId, receiverId, messageText, message.Timestamp);
        }
    }
}
