module search {

  export alias s = websearch

  export def websearch [
    ...query:string  # Search query
    --google (-g)  # Search on google
    --duckduck (-d)  # Search on duckduckgo
  ] {
    let formatted_query = ($query | reduce { |it, acc| $acc + "+" + $it })
    if $duckduck {
      wslview $"https://duckduckgo.com/?q=($formatted_query)"
    } else if $google {
      wslview $"https://google.com/search?q=($formatted_query)"
    } else {
      wslview $"https://phind.com/search?q=($formatted_query)"
    }
  }
}