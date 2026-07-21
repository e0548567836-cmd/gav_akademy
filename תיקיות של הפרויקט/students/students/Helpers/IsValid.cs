namespace students.Helpers
{
    /// <summary>
    /// Provides methods for validating Israeli ID numbers and phone numbers.
    /// </summary>
    public class IsValid
    {
        // Validates an Israeli ID number using the Luhn-like checksum algorithm
        public static bool IsValidId(string id)
        {
            if (string.IsNullOrWhiteSpace(id) || id.Length > 9 || !long.TryParse(id, out _))
                return false;

            // Pad with leading zeros if shorter than 9 digits
            id = id.PadLeft(9, '0');

            int sum = 0;
            for (int i = 0; i < 9; i++)
            {
                int digit = int.Parse(id[i].ToString());
                int step = digit * ((i % 2) + 1); // multiply alternately by 1 and 2

                if (step > 9)
                    step = (step / 10) + (step % 10); // sum the two digits of a two-digit product

                sum += step;
            }

            return sum % 10 == 0;
        }

        // Validates an Israeli mobile phone number (must be 10 digits starting with 05)
        public static bool IsValidPhoneNumber(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone)) return false;

            phone = phone.Replace(" ", "").Replace("-", "");

            return phone.Length == 10 &&
                   phone.StartsWith("05") &&
                   phone.All(char.IsDigit);
        }
    }
}