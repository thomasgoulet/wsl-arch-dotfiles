module kube {

  export alias k = kubectl

  def "nu-complete kubectl resources" [] {
    kubectl api-resources | from ssv | get SHORTNAMES NAME | flatten
  }

  export def kc [
    --list (-l)  # List context instead of switching
  ] {
    if $list {
      kubectl config get-contexts | from ssv
      return
    }
    let context = (
      kubectl config get-contexts |
      fzf --height 10% --reverse --inline-info --bind 'tab:down' --bind 'shift-tab:up' --delimiter=' ' --nth=2.. --header-lines=1
    )
    if $context != "" {
      kubectl config use-context ($context | split row " " | filter {|s| $s != "" and $s != "*"} | first)
    }
  }

  export def ks [
    resource: string@"nu-complete kubectl resources"  # Resource
    --namespace (-n): string  # Namespace
    --all (-A)  # Show resource for all namespaces
    --full (-f)  # Show full resource info
  ] {

    if $full {

      mut output = ""

      if $all {
        $output = (kubectl get $resource -o json -A)
      } else if $namespace != "" {
        $output = (kubectl get $resource -o json -n $namespace)
      } else {
        $output = (kubectl get $resource -o json)
      }

      return ($output | from json | get items | get metadata | move namespace name --before creationTimestamp)

    }

    if $all {
      return (kubectl get $resource -A | from ssv)
    }

    if $namespace != null {
      return (kubectl get $resource -n $namespace | from ssv)
    }

    return (kubectl get $resource | from ssv)
  }

}