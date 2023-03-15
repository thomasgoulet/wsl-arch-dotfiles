module kube {

  export alias k = kubectl

  def "nu-complete kubectl contexts" [] {
    kubectl config get-contexts | from ssv | get NAME
  }

  def "nu-complete kubectl namespaces" [] {
    kubectl get namespaces | from ssv | where NAME != "default" | get NAME | prepend NONE
  }

  def "nu-complete kubectl resources" [] {
    kubectl api-resources | from ssv | get SHORTNAMES NAME | flatten
  }

  export def "kubectl con" [
    context?: string@"nu-complete kubectl contexts"  # Context
  ] {
    if $context == null {
      return (kubectl config get-contexts | from ssv)
    }
    kubectl config use-context $context
  }

  export def "kubectl ns" [
    namespace?: string@"nu-complete kubectl namespaces" # Namespace
  ] {
    if $namespace == null {
      return (kubectl get ns | from ssv)
    }
    if $namespace == "NONE" {
      return (kubectl config set-context --current --namespace="")
    }
    kubectl config set-context --current --namespace $namespace
  }

  export def "kubectl s" [
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