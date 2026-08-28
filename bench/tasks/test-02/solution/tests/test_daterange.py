import unittest

from daterange import days_between, month_end, range_days


class DaysBetweenTest(unittest.TestCase):
    def test_inclusive_count(self):
        self.assertEqual(days_between("2024-03-01", "2024-03-05"), 5)

    def test_single_day_range_counts_as_one(self):
        self.assertEqual(days_between("2024-05-01", "2024-05-01"), 1)

    def test_returns_an_int(self):
        self.assertIsInstance(days_between("2024-03-01", "2024-03-02"), int)


class RangeDaysTest(unittest.TestCase):
    def test_crosses_leap_february(self):
        self.assertEqual(
            range_days("2024-02-27", "2024-03-01"),
            ["2024-02-27", "2024-02-28", "2024-02-29", "2024-03-01"],
        )


class MonthEndTest(unittest.TestCase):
    def test_leap_february(self):
        self.assertEqual(month_end("2024-02"), "2024-02-29")

    def test_non_leap_february(self):
        self.assertEqual(month_end("2023-02"), "2023-02-28")

    def test_december(self):
        self.assertEqual(month_end("2023-12"), "2023-12-31")


if __name__ == "__main__":
    unittest.main()
