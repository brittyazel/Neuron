-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}

local Array; Array = {
  --- create an array
  -- int -> (int -> a ) -> a[]
  -- @param n number of elements in the array
  -- @param fn function takes index and returns array element
  -- @return an array of length n
  initialize = function (n, fn)
    local array = {}
    for i=1,n do
      array[i] = fn(i)
    end
    return array
  end,

  --- map from one array to another
  -- (a->b) -> a[] -> b[]
  -- @param fn function that takes an element from a and converts it to b
  -- @param a source array
  -- @return b finished array
  map = function (fn, a)
    return Array.initialize(#a, function (i) return fn(a[i]) end)
  end,
}

addonTable.utilities.Array = Array
