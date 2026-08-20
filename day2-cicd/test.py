import pytest
from app import add, subtract, multiply


def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0



def test_subtract():
    assert subtract(10, 4) == 6


def test_multiply():
    assert multiply(6, 7) == 42
