using System.Text.Json;
using System.Text.Json.Serialization;

namespace students.Helpers
{
    /// <summary>
    /// Converts JSON numbers and strings to C# string values.
    /// </summary>
    // Accepts both JSON string "123" and JSON number 123 and converts to C# string.
    // Needed because Flutter serializes int fields as JSON numbers.
    public class NumberToStringConverter : JsonConverter<string>
    {
        public override string? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return reader.TokenType switch
            {
                JsonTokenType.String => reader.GetString(),
                JsonTokenType.Number => reader.TryGetInt64(out var n) ? n.ToString() : reader.GetDouble().ToString(),
                JsonTokenType.Null => null,
                _ => null
            };
        }

        public override void Write(Utf8JsonWriter writer, string value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value);
        }
    }
}
