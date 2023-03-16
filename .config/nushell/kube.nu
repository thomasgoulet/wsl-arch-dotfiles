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

  # Change context
  export alias kcon = kubectl context
  # Change context
  export def "kubectl context" [
    context?: string@"nu-complete kubectl contexts"  # Context
  ] {
    if $context == null {
      return (kubectl config get-contexts | from ssv)
    }
    kubectl config use-context $context
  }

  # Change configured namespace in context
  export alias kns = kubectl namespace
  # Change configured namespace in context
  export def "kubectl namespace" [
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

  # Explore resources
  export alias ke = kubectl explore
  # Explore resources
  export def "kubectl explore" [
    resource: string@"nu-complete kubectl resources"  # Resource
    search?: string  # Filter resources name with this value
    --all (-a)  # Search in all namespaces
    --definition (-d)  # Output full definitions for resources
  ] {

    mut output = [[];]
    let all_arg = (if $all {["-A"]} else {[]})

    if not $definition {
      $output = (kubectl get $resource $all_arg | from ssv)
      if $search != null {
        $output = ($output | where NAME =~ $search)
      }
    } else {
      $output = (kubectl get $resource -o json $all_arg | from json | get items)
      if $search != null {
        $output = ($output | where metadata.name =~ $search)
      }
      if ($output | length) == 1 {
        $output = ($output | into record)
      }
    }

    return $output
  }

}