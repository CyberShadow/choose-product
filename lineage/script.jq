def numbers: [match("[0-9]+"; "g") .string | tonumber];

def released_after(when):
   .release
   | if type == "array" then [.[][]] else [.] end
   | any(. > when);

[
  .[]
  | select(.maintainers|length > 0)
  | select(released_after("2018"))
  | select(
        (.storage | numbers | any(. >= 128))
        or
        (.sdcard | (. != null and . != "none"))
      )
  | select(.type != "tablet")
  | select(.battery != "None")
  | . + { score : ( 0
                      + ((released_after("2019-01")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2019-04")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2019-07")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2019-10")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2020-01")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2020-04")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2020-07")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2020-10")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2021-01")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2021-04")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2021-07")                                 ) | if . then 0.25  else 0 end)
                      + ((released_after("2021-10")                                 ) | if . then 0.25  else 0 end)
                      + ((.screen_res | contains("1080") | not                      ) | if . then 0.25  else 0 end)
                      + ((.peripherals | any(contains("wireless charging"))         ) | if . then 0.125 else 0 end)
                      + ((.peripherals | any(contains("Dual SIM"))                  ) | if . then 1     else 0 end)
                      + ((.sdcard | (. != null and . != "none")                     ) | if . then 1     else 0 end)
		      + ((.storage | numbers | any(. >= 128)                        ) | if . then 1     else 0 end)
		      + ((.storage | numbers | any(. >= 256)                        ) | if . then 1     else 0 end)
		      + ((.storage | numbers | any(. >= 512)                        ) | if . then 0.25  else 0 end)
                      + ((.ram | numbers | any(. >= 8)                              ) | if . then 1     else 0 end)
                      + ((.ram | numbers | any(. >= 12)                             ) | if . then 1     else 0 end)
                      + ((.battery.removable                                        ) | if . then 2     else 0 end)
                  )
      }
  | {
    score    : .score,
    codename : .codename,
    vendor   : .vendor,
    name     : .name,
    sdcard   : .sdcard,
    storage  : .storage,
    release  : (.release | if type == "array" then [.[][]] else [.] end | max),
  }
]
| sort_by(.codename)
| sort_by(-.score)
| [ .[0] | keys_unsorted ] +
  [ .[0] | keys_unsorted | [ .[] | length | "-" * . ] ] +
  [ .[] | [ .[] ] ]
| .[] | @tsv
