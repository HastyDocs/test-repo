"""
Register Hypothesis strategies for Pydantic custom types.

This enables fully-automatic generation of test data for most Pydantic classes.

Note that this module has *no* runtime impact on Pydantic itself; instead it
is registered as a setuptools entry point and Hypothesis will import it if
Pydantic is installed.  See also:

https://hypothesis.readthedocs.io/en/latest/strategies.html#registering-strategies-via-setuptools-entry-points
https://hypothesis.readthedocs.io/en/latest/data.html#hypothesis.strategies.register_type_strategy
https://hypothesis.readthedocs.io/en/latest/strategies.html#interaction-with-pytest-cov
https://pydantic-docs.helpmanual.io/usage/types/#pydantic-types

Note that because our motivation is to *improve user experience*, the strategies
are always sound (never generate invalid data) but sacrifice completeness for
maintainability (ie may be unable to generate some tricky but valid data).

Finally, this module makes liberal use of `# type: ignore[<code>]` pragmas.
This is because Hypothesis annotates `register_type_strategy()` with
`(T, SearchStrategy[T])`, but in most cases we register e.g. `ConstrainedInt`
to generate instances of the builtin `int` type which match the constraints.
"""

import contextlib
import ipaddress
import json
import math
from fractions import Fraction
from typing import Callable, Dict, Type, Union, cast, overload

import hypothesis.strategies as st

import pydantic
import pydantic.color
import pydantic.types

# FilePath and DirectoryPath are explicitly unsupported, as we'd have to create
# them on-disk, and that's unsafe in general without being told *where* to do so.
#
# URLs are unsupported because it's easy for users to define their own strategy for
# "normal" URLs, and hard for us to define a general strategy which includes "weird"
# URLs but doesn't also have unpredictable performance problems.
#
# conlist() and conset() are unsupported for now, because the workarounds for
# Cython and Hypothesis to handle parametrized generic types are incompatible.
# Once Cython can support 'normal' generics we'll revisit this.

# Emails
try:
    import email_validator
except ImportError:  # pragma: no cover
    pass
else:

    def is_valid_email(s: str) -> bool:
        # Hypothesis' st.emails() occasionally generates emails like 0@A0--0.ac
        # that are invalid according to email-validator, so we filter those out.
        try:
            email_validator.validate_email(s, check_deliverability=False)
            return True
        except email_validator.EmailNotValidError:  # pragma: no cover
            return False

    # Note that these strategies deliberately stay away from any tricky Unicode
    # or other encoding issues; we're just trying to generate *something* valid.
    st.register_type_strategy(pydantic.EmailStr, st.emails().filter(is_valid_email))  # type: ignore[arg-type]
    st.register_type_strategy(
        pydantic.NameEmail,
        st.builds(
            '{} <{}>'.format,  # type: ignore[arg-type]
            st.from_regex('[A-Za-z0-9_]+( [A-Za-z0-9_]+){0,5}', fullmatch=True),
            st.emails().filter(is_valid_email),
        ),
    )

# PyObject - dotted names, in this case taken from the math module.
st.register_type_strategy(
    pydantic.PyObject,  # type: ignore[arg-type]
    st.sampled_from(
        [cast(pydantic.PyObject, f'math.{name}') for name in sorted(vars(math)) if not name.startswith('_')]
    ),
)

# CSS3 Colors; as name, hex, rgb(a) tuples or strings, or hsl strings
_color_regexes = (
    '|'.join(
        (
            pydantic.color.r_hex_short,
            pydantic.color.r_hex_long,
            pydantic.color.r_rgb,
            pydantic.color.r_rgba,
            pydantic.color.r_hsl,
            pydantic.color.r_hsla,
        )
    )
    # Use more precise regex patterns to avoid value-out-of-range errors
    .replace(pydantic.color._r_sl, r'(?:(\d\d?(?:\.\d+)?|100(?:\.0+)?)%)')
    .replace(pydantic.color._r_alpha, r'(?:(0(?:\.\d+)?|1(?:\.0+)?|\.\d+|\d{1,2}%))')
    .replace(pydantic.color._r_255, r'(?:((?:\d|\d\d|[01]\d\d|2[0-4]\d|25[0-4])(?:\.\d+)?|255(?:\.0+)?))')
)
st.register_type_strategy(
    pydantic.color.Color,
    st.one_of(
        st.sampled_from(sorted(pydantic.color.COLORS_BY_NAME)),
        st.tuples(
            st.integers(0, 255),
            st.integers(0, 255),
            st.integers(0, 255),
            st.none() | st.floats(0, 1) | st.floats(0, 100).map('{}%'.format),
        ),
        st.from_regex(_color_regexes, fullmatch=True),
    ),
)


# Card numbers, valid according to the Luhn algorithm


def add_luhn_digit(card_number: str) -> str:
    # See https://en.wikipedia.org/wiki/Luhn_algorithm
    for digit in '0123456789':
        with contextlib.suppress(Exception):
            pydantic.PaymentCardNumber.validate_luhn_check_digit(card_number + digit)
            return card_number + digit
    raise AssertionError('Unreachable')  # pragma: no cover


card_patterns_change = (
    # Note that these patterns omit the Luhn check digit; that's added by the function above
    '4[0-9]{14}',  # Visa
    '5[12345][0-9]{13}',  # Mastercard
    '3[47][0-9]{12}',  # American Express
    '[0-26-9][0-9]{10,17}',  # other (incomplete to avoid overlap)
)
st.register_type_strategy(
    pydantic.PaymentCardNumber,
    st.from_regex('|'.join(card_patterns), fullmatch=True).map(add_luhn_digit),  # type: ignore[arg-type]
)
