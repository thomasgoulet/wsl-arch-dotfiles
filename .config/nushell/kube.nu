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
  export def "kubectl con" [
    context?: string@"nu-complete kubectl contexts"  # Context
  ] {
    if $context == null {
      return (kubectl config get-contexts | from ssv)
    }
    kubectl config use-context $context
  }

  # Change configure namespace in context
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

  # Show resources
  export def "kubectl s" [
    resource: string@"nu-complete kubectl resources"  # Resource
    search?: string  # Filter resources name with this value
    --full (-f)  # Show full resources info. If only one resource is returned you can get data out of it
  ] {
    mut output = (kubectl get $resource | from ssv)

    if $search != null {
        $output = ($output | where NAME =~ $search)
    }

    if $full and ($output | length) > 1 {
      return ($output | each { |row|
        (kubectl get $resource $row.NAME -o json | from json)
      })
    } else if $full and ($output | length) == 1 {
      return (kubectl get $resource ($output | first | get NAME) -o json | from json)
    }

    return $output
  }

}