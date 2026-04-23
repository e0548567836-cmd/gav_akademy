namespace students.Helpers
{
    public class IsValid
    {
        //checking if the id is valid
        public static bool IsValidId(string id)
        {
            if (string.IsNullOrWhiteSpace(id) || id.Length > 9 || !long.TryParse(id, out _))
                return false;

            // הוספת אפסים מובילים אם המספר קצר מ-9 ספרות
            id = id.PadLeft(9, '0');

            int sum = 0;
            for (int i = 0; i < 9; i++)
            {
                int digit = int.Parse(id[i].ToString());
                int step = digit * ((i % 2) + 1); // מכפילים ב-1 או 2 לסירוגין

                if (step > 9)
                    step = (step / 10) + (step % 10); // חיבור ספרות המכפלה

                sum += step;
            }

            return sum % 10 == 0; // אם השארית היא 0, תעודת הזהות תקינה
        }

        //is valid phon number
        public static bool IsValidPhoneNumber(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone)) return false;

            phone = phone.Replace(" ", "").Replace("-", "");

            // בדיקה: האם זה מכיל רק ספרות, מתחיל ב-05 ובאורך 10 ספרות
            return phone.Length == 10 &&
                   phone.StartsWith("05") &&
                   phone.All(char.IsDigit);
        }
    }
}
