module az {

  def "nu-complete azurecli subscriptions" [] {
    az account list | from json | get name | each {|x| "\"" + $x + "\""}
  }

  # Logs you into azure-cli after checking if your token is expired
  export def azl [
    --silent (-s)  # Silent version of the command
  ] {
    # FIX this currently does not properly check if I'm logged in or not
    let logged_in = (open ~/.azure/msal_token_cache.json | get AccessToken | rotate | filter {|$x| ($x.column0.expires_on | into int) > (date now | format date %s | into int) } | length) > 0
    if not $logged_in {
      az login out+err> /dev/null
    } else if not $silent {
      echo "Already logged in"
    }
  }

  # Changes your subscription for you
  export def azs [
    subscription?: string@"nu-complete azurecli subscriptions"  # Subscription to switch to
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
      let match = $matches | get name | input list -f
      print ("Switching to subscription " + $match)
      az account set -s $match
    }
  }

  # Lists all active PRs for a Azure DevOps project
  export def azpr [
    project: string  # Project to list active PRs for
  ] {
    az repos pr list --project $project --top 10000 | from json | select createdBy.displayName repository.name title creationDate | rename AUTHOR REPO TITLE DATE
  }

}
