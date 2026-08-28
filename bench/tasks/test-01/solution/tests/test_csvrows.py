import unittest

from csvrows import parse_row, split_fields


class SplitFieldsTest(unittest.TestCase):
    def test_quoted_section_protects_commas(self):
        self.assertEqual(split_fields('a,"b,c",d'), ["a", "b,c", "d"])

    def test_doubled_quote_is_literal_quote(self):
        self.assertEqual(split_fields('"x""y",z'), ['x"y', "z"])

    def test_interior_empty_field_is_empty_string(self):
        self.assertEqual(split_fields("a,,c"), ["a", "", "c"])

    def test_trailing_comma_keeps_final_empty_field(self):
        self.assertEqual(split_fields("a,b,"), ["a", "b", ""])


class ParseRowTest(unittest.TestCase):
    def test_maps_columns_onto_header_keys(self):
        self.assertEqual(parse_row("name,age", "Ada,36"), {"name": "Ada", "age": "36"})

    def test_empty_value_is_mapped_as_empty_string(self):
        self.assertEqual(parse_row("name,age", "Ada,"), {"name": "Ada", "age": ""})


if __name__ == "__main__":
    unittest.main()
