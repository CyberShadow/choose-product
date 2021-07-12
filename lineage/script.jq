[
  .[]
  | select(.maintainers|length > 0)
  | select(
        .release
        | if type == "array" then [.[][]] else [.] end
        | any(. > "2019")
      )
  | select(
        (.storage | contains("256"))
        or
        (.sdcard | (. != null and . != "none"))
      )
  | select(.type != "tablet")
  | . + { score : ( 0
                      + ((.screen_res | contains("1080") | not                      ) | if . then 1 else 0 end)
                      + ((.peripherals | any(contains("wireless charging"))         ) | if . then 1 else 0 end)
                      + ((.peripherals | any(contains("Dual SIM"))                  ) | if . then 1 else 0 end)
                      + ((.sdcard | (. != null and . != "none")                     ) | if . then 1 else 0 end)
                      + ((.ram | (contains("8") or contains("10") or contains("12"))) | if . then 1 else 0 end)
                      + ((.battery.removable)                                         | if . then 2 else 0 end)
                  )
      }
  | {
    score    : .score,
    codename : .codename,
    vendor   : .vendor,
    name     : .name,
    sdcard   : .sdcard,
    storage  : .storage
  }
]
| sort_by(.codename)
| sort_by(-.score)
| [ .[0] | keys_unsorted ] +
  [ .[0] | keys_unsorted | [ .[] | length | "-" * . ] ] +
  [ .[] | [ .[] ] ]
| .[] | @tsv
