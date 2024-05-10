module az {

  def "nu-complete azurecli subscriptions" [] {
    az account list | from json | get name | each {|x| "\"" + $x + "\""}
  }

  # Logs you into azure-cli after checking if your token is expired
  export def azl [
    --silent (-s)  # Silent version of the command
  ] {
    let logged_in = (open ~/.azure/msal_token_cache.json | get AccessToken | rotate | filter {|$x| ($x.column0.expires_on | into int) > (date now | format date %s | into int) } | length) > 0
    if not $logged_in {
      az login out+err> /dev/null
    } else if not $silent {
      echo "Already logged in"
    }
  }

  # Changes your subscription for you
  export def azs [
    subscription?: string@"nu-complete azurecli subscriptions"
  ] {
    if $subscription == null {
      return (az account list | from json | get name)
    }
    let matches = (az account list | from json | where name =~ $subscription)
    if ($matches | length) == 0 {
      print ("No matching subscription")
    } else if ($matches | length) == 1 {
      let match = $matches | get 0 | get name | to text
      print ("Switching to subscription " + $match)
      az account set -s $match
    } else {
      let match = $matches | get name | str join (char -i 0) | fzf --read0 --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up'
      print ("Switching to subscription " + $match)
      az account set -s $match
    }
  }

}
