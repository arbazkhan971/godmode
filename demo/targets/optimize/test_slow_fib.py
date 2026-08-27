import unittest

from slow_fib import work


class WorkTest(unittest.TestCase):
    def test_work_returns_fib_30(self):
        self.assertEqual(work(), 832040)


if __name__ == "__main__":
    unittest.main()
