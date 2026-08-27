import unittest

from counter import total


class TestTotal(unittest.TestCase):
    def test_empty_list_is_zero(self):
        self.assertEqual(total([]), 0)

    def test_sum_of_items(self):
        self.assertEqual(total([1, 2, 3]), 6)


if __name__ == "__main__":
    unittest.main()
