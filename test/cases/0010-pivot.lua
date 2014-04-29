--------------------------------------------------------------------------------
-- 0010-pivot.lua: tests for pivot functions
-- This file is a part of le-tools project
-- Copyright (c) Alexander Gladysh <ag@logiceditor.com>
-- Copyright (c) Dmitry Potapov <dp@logiceditor.com>
-- See file `COPYRIGHT` for the license
--------------------------------------------------------------------------------

local create_pivot_processor,
      pivot_exports
      = import "le-tools/pivot/pivot.lua"
      {
        "create_pivot_processor"
      }

local format
      = import "le-tools/pivot/format.lua"
      {
        "format"
      }

local ensure,
      ensure_equals,
      ensure_fails_with_substring,
      ensure_is
      = import "lua-nucleo/ensure.lua"
      {
        "ensure",
        "ensure_equals",
        "ensure_fails_with_substring",
        "ensure_is"
      }

--------------------------------------------------------------------------------

local test = (...)("le-pivot", pivot_exports)

--------------------------------------------------------------------------------

test:tests_for "create_pivot_processor"

--------------------------------------------------------------------------------

test "create-pivot-processor" (function(env)

  ensure_is(
      "create_pivot_processor returns function",
      create_pivot_processor({"1=1%+"}),
      "function"
    )

  ensure_fails_with_substring(
      "create_pivot_processor should be given array of at least one element",
      function()
        create_pivot_processor({})
      end,
      "must specify at least one column rule"
    )

  ensure_fails_with_substring(
      "arguments to create_pivot_processor should be of form N1=N2[%][+]",
      function()
        create_pivot_processor({"a"})
      end,
      "a: bad rule format"
    )

  ensure_fails_with_substring(
      "arguments to create_pivot_processor should be of form N1=N2[%][+]",
      function()
        create_pivot_processor({"1=a"})
      end,
      "1=a: bad rule format"
    )

end)

local run = function(args, input)
  return format(create_pivot_processor(args)(input), "text")
end

test "pivot-processor-simple" (function(env)

  ensure_equals(
      "returns nothing on for empty dataset",
      run({"1=1"}, { }),
      ""
    )

  ensure_equals(
      "returns Others 0 on for empty dataset if others are requested",
      run({"1=1+"}, { }),
      "Others\t0\n"
    )

  ensure_equals(
      "honors others custom label",
      run({"1=1+Autres"}, { }),
      "Autres\t0\n"
    )

  ensure_equals(
      "honors selection by percentage",
      run({"1=1%+"}, { }),
      "Others\t100.0000%\n"
    )

  ensure_equals(
      "can select more than one column",
      run({"1=1%+", "2=1+Otros"}, { }),
      "Others\t100.0000%\tOtros\t0\n"
    )

end)

--
-- examples from description #4090
--
test "pivot-processor-yields-description" (function(env)

  local pivot1 = function(args)
    local dataset =
    {
      {4596994, "Chrome", "33.0.1750", "Windows 7", "", "Other", ""};
      {1439417, "Yandex Browser", "4.2.1700", "Windows 7", "", "Other", ""};
      {1323294, "Firefox", "28.0", "Windows 7", "", "Other", ""};
      {1267688, "Chrome", "33.0.1750", "Windows XP", "", "Other", ""};
      {1151396, "Opera", "12.16", "Windows 7", "", "Other", ""};
    }
    return run(args, dataset)
  end

  local pivot2 = function(args)
    local dataset =
    {
      {4596994, "Chrome", "33.0.1750", "Windows 7", "", "64-bit", ""};
      {1439417, "Yandex Browser", "14.2.1700", "Windows 7", "", "32-bit", ""};
      {1267688, "Chrome", "33.0.1750", "Windows XP", "", "32-bit", ""};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "yields description example 1",
      pivot1({"5=2+", "1=3+"}),
         "Other\t9778789\tChrome\t5864682\n"
      .. "Other\t9778789\tYandex Browser\t1439417\n"
      .. "Other\t9778789\tFirefox\t1323294\n"
      .. "Other\t9778789\tOthers\t1151396\n"
      .. "Others\t0\tOthers\t0\n"
    )

  ensure_equals(
      "yields description example 2",
      pivot2({"5=2+", "1=3+"}),
        "64-bit\t4596994\tChrome\t4596994\n"
      .. "64-bit\t4596994\tOthers\t0\n"
      .. "32-bit\t2707105\tYandex Browser\t1439417\n"
      .. "32-bit\t2707105\tChrome\t1267688\n"
      .. "32-bit\t2707105\tOthers\t0\n"
      .. "Others\t0\tOthers\t0\n"
    )

end)

--
-- example from #4090#note-27
--
test "pivot-processor-example-4090-27" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {4596994, "Chrome", "33.0.1750", "Windows 7", "", "Other", ""};
      {1439417, "Yandex Browser", "4.2.1700", "Windows 7", "", "Other", ""};
      {1323294, "Firefox", "28.0", "Windows 7", "", "Other", ""};
      {1267688, "Chrome", "33.0.1750", "Windows XP", "", "Other", ""};
      {1151396, "Opera", "12.16", "Windows 7", "", "Other", ""};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok 1=3+",
      pivot({"1=3+"}),
         "Chrome\t5864682\n"
      .. "Yandex Browser\t1439417\n"
      .. "Firefox\t1323294\n"
      .. "Others\t1151396\n"
    )

  ensure_equals(
      "works ok 1=3%+",
      pivot({"1=3%+"}),
         "Chrome\t59.9735%\n"
      .. "Others\t40.0265%\n"
    )

  ensure_equals(
      "works ok 1=60%+",
      pivot({"1=60%+"}),
         "Chrome\t59.9735%\n"
      .. "Yandex Browser\t14.7198%\n"
      .. "Others\t25.3067%\n"
    )

  ensure_equals(
      "works ok 1=80%+",
      pivot({"1=80%+"}),
         "Chrome\t59.9735%\n"
      .. "Yandex Browser\t14.7198%\n"
      .. "Firefox\t13.5323%\n"
      .. "Others\t11.7744%\n"
    )

end)

--
-- example from #4090#note-28
--
test "pivot-processor-example-4090-28" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {1, "alpha", "red", "a"};
      {1, "alpha", "blue", "b"};
      {1, "alpha", "blue", "c"};
      {3, "alpha", "green", "d"};
      {6, "beta", "red", "e"};
      {5, "beta", "blue", "f"};
      {4, "beta", "green", "g"};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok for 1=2 2=2",
      pivot({"1=2", "2=2"}),
         "beta\t15\tred\t6\n"
      .. "beta\t15\tblue\t5\n"
      .. "alpha\t6\tgreen\t3\n"
      .. "alpha\t6\tblue\t2\n"
    )

end)

--
-- example from #4090#note-32
--
test "pivot-processor-example-4090-32" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {1, "alpha", "red", "a"};
      {1, "alpha", "blue", "b"};
      {1, "alpha", "blue", "c"};
      {3, "alpha", "green", "d"};
      {6, "beta", "red", "e"};
      {5, "beta", "blue", "f"};
      {4, "beta", "green", "g"};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok for 1=1 2=1",
      pivot({"1=1", "2=1"}),
         "beta\t15\tred\t6\n"
    )

end)

--
-- example from #4090#note-33
--
test "pivot-processor-example-4090-33" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {1, "alpha", "red", "a"};
      {1, "alpha", "blue", "b"};
      {1, "alpha", "blue", "c"};
      {3, "alpha", "green", "d"};
      {6, "beta", "red", "e"};
      {5, "beta", "blue", "f"};
      {4, "beta", "green", "g"};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok for 1=1 2=2",
      pivot({"1=1", "2=2"}),
         "beta\t15\tred\t6\n"
      .. "beta\t15\tblue\t5\n"
    )

end)

--
-- example from #4090#note-35
--
test "pivot-processor-example-4090-35" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {1, "alpha", "red", "a"};
      {1, "alpha", "blue", "b"};
      {1, "alpha", "blue", "c"};
      {3, "alpha", "green", "d"};
      {6, "beta", "red", "e"};
      {5, "beta", "blue", "f"};
      {4, "beta", "green", "g"};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok for 1=2 2=1",
      pivot({"1=2", "2=1"}),
         "beta\t15\tred\t6\n"
      .. "alpha\t6\tgreen\t3\n"
    )

end)

--
-- example from #4090#note-39
--
test "pivot-processor-example-4090-39" (function(env)

  local pivot = function(args)
    local dataset =
    {
      {1, "alpha", "red", "one", "a"};
      {1, "alpha", "blue", "one", "b"};
      {1, "alpha", "blue", "two", "c"};
      {3, "alpha", "green", "three", "d"};
      {6, "beta", "red", "four", "e"};
      {5, "beta", "blue", "four", "f"};
      {4, "beta", "green", "five", "g"};
    }
    return run(args, dataset)
  end

  ensure_equals(
      "works ok for 1 column",
      pivot({"1=1+"}),
         "beta\t15\n"
      .. "Others\t6\n"
    )

  ensure_equals(
      "works ok for 2 column",
      pivot({"1=1+", "2=1+"}),
         "beta\t15\tred\t6\n"
      .. "beta\t15\tOthers\t9\n"
      .. "Others\t6\tgreen\t3\n"
      .. "Others\t6\tOthers\t3\n"
    )

  ensure_equals(
      "works ok for 3 column",
      pivot({"1=1+", "2=1+", "3=1+"}),
         "beta\t15\tred\t6\tfour\t6\n"
      .. "beta\t15\tred\t6\tOthers\t0\n"
      .. "beta\t15\tOthers\t9\tfour\t5\n"
      .. "beta\t15\tOthers\t9\tOthers\t4\n"
      .. "Others\t6\tgreen\t3\tthree\t3\n"
      .. "Others\t6\tgreen\t3\tOthers\t0\n"
      .. "Others\t6\tOthers\t3\tone\t2\n"
      .. "Others\t6\tOthers\t3\tOthers\t1\n"
    )

  ensure_equals(
      "works ok for another 3 column",
      pivot({"1=1+", "2=1+", "4=1+"}),
         "beta\t15\tred\t6\te\t6\n"
      .. "beta\t15\tred\t6\tOthers\t0\n"
      .. "beta\t15\tOthers\t9\tf\t5\n"
      .. "beta\t15\tOthers\t9\tOthers\t4\n"
      .. "Others\t6\tgreen\t3\td\t3\n"
      .. "Others\t6\tgreen\t3\tOthers\t0\n"
      .. "Others\t6\tOthers\t3\ta\t1\n"
      .. "Others\t6\tOthers\t3\tOthers\t2\n"
    )

end)

--------------------------------------------------------------------------------
