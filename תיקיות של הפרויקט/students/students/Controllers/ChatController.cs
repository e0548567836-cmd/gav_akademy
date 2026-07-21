using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;

namespace students.Controllers
{
    /// <summary>
    /// Provides chat-related operations.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ChatController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Retrieves the list of users the given user has exchanged messages with.
        /// </summary>
        [HttpGet("Conversations")]
        public async Task<IActionResult> GetConversations([FromQuery] string userId)
        {
            var partnerIds = await _context.Messages
                .Where(m => m.SenderId == userId || m.ReceiverId == userId)
                .Select(m => m.SenderId == userId ? m.ReceiverId : m.SenderId)
                .Distinct()
                .ToListAsync();

            var partners = await _context.Students
                .Where(s => partnerIds.Contains(s.StudentId))
                .Select(s => new
                {
                    studentId = s.StudentId,
                    studentName = s.studentName,
                    studentEmail = s.studentEmail,
                    management = s.management
                })
                .ToListAsync();

            return Ok(partners);
        }

        /// <summary>
        /// Retrieves the chat history between two users.
        /// </summary>
        [HttpGet("History")]
        public async Task<IActionResult> GetHistory([FromQuery] string userId1, [FromQuery] string userId2)
        {
            var messages = await _context.Messages
                .Where(m =>
                    (m.SenderId == userId1 && m.ReceiverId == userId2) ||
                    (m.SenderId == userId2 && m.ReceiverId == userId1))
                .OrderBy(m => m.Timestamp)
                .Select(m => new
                {
                    senderId = m.SenderId,
                    messageText = m.MessageText,
                    timestamp = m.Timestamp
                })
                .ToListAsync();

            return Ok(messages);
        }
    }
}