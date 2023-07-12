defmodule UtilTest do
  use ExUnit.Case
  require Intst.Utils
  doctest Intst

  test "generate strings dynimic length" do
    Enum.each(1..20, fn i ->
      value = Intst.Utils.generate_random(i)
      assert String.length(value) == i
      assert is_binary(value) && !is_number(value)
    end)
  end

  test "generate strings default" do
    value = Intst.Utils.generate_random()
    assert is_binary(value) && !is_number(value)
  end


  test "generate numbers dynimic length" do
    Enum.each(1..20, fn i ->
      value = Intst.Utils.generate_random_number(i)
      assert String.length(Integer.to_string(value)) == i
      assert is_number(value)
    end)
  end

  test "generate numbers default" do
    value = Intst.Utils.generate_random_number()
    assert is_number(value)
  end

end
