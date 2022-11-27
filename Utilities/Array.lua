-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

local _, addonTable = ...
addonTable.utilities = addonTable.utilities or {}


local Array; Array = {
	---create an array
	---number -> (number -> A ) -> A[]
	---@generic A
	---@param n number @length of array
	---@param fn fun(i:number):A @function takes index and returns array element
	---@return A[] @an array of length n
	initialize = function (n, fn)
		local array = {}
		for i=1,n do
			array[i] = fn(i)
		end
		return array
	end,

	---returns a new array, different from the components
	---@param ... any[]
	---@return any[]
	concatenate = function (...)
		local result = {}
		for _,array in ipairs({...}) do
			for _,element in ipairs(array) do
				table.insert(result, element)
			end
		end

		return result
	end,

	---remove items from an array if a test function returns falsey
	---@generic A
	---@param fn fun(a:`A`):boolean @test function
	---@param array A[] @input array
	---@return A[] @filtered array
	filter = function (fn, array)
		local newArray = {}

		for _,v in ipairs(array) do
			if fn(v) then
				table.insert(newArray, v)
			end
		end

		return newArray
	end,

	---remove items from an array if a test function returns falsey
	---@generic A
	---@param fn fun(a:`A`):boolean @test function
	---@param array A[] @input array
	---@return number|nil, A|nil @position of element
	find = function (fn, array)
		for i,v in ipairs(array) do
			if fn(v) then
				return i, v
			end
		end

		return nil
	end,

	---aka reduce
	---@generic A, B
	---@param fn fun(a: `A`, b: `B`):A
	---@param initial A @initial value
	---@param array B[] @input array
	---@return A @folded value
	foldl = function (fn, initial, array)
		for _,v in ipairs(array) do
			initial = fn(initial, v)
		end
		return initial
	end,

	---converts an iterator to an array
	---this exists because iterators are thruples, but lua has no real support
	---for tuples outside of return/parameter values. this results in way to much
	---boilerplate when packing/unpacking iterators<->arrays in order to
	---pass them around as first class objects. not to mention that iterators
	---themselves can return tuples, besides _being_ tuples
	---@generic I, C, D
	---@param iter fun(invariant: I, control: C):D|...
	---@param invariant I
	---@param control C
	---@return D[]|...[]
	fromIterator = function(iter, invariant, control)
		local result = {}
		local index = 1
		repeat
			local nextValue = {iter(invariant, control)}
			-- if the iterator returned a single value, then insert that
			-- if the iterator returned a tuple, then insert that tuple as an array
			if #nextValue < 2 then
				table.insert(result, index, nextValue[1])
			else
				table.insert(result, index, nextValue)
			end

			control = unpack(nextValue)
			index = index + 1
		until control == nil

		return result
	end,

	---map from one array to another
	---(A->B) -> A[] -> B[]
	---@generic A
	---@generic B
	---@param fn fun(a:A):B
	---@param array A[] @source array
	---@return B[] @remapped array
	map = function (fn, array)
		return Array.initialize(#array, function (i) return fn(array[i]) end)
	end,
}

addonTable.utilities.Array = Array
