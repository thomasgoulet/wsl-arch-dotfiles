module kube {

  export alias k = kubectl

  def "nu-complete kubectl contexts" [] {
    kubectl config get-contexts | from ssv -a | get NAME
  }

  def "nu-complete kubectl namespaces" [] {
    kubectl get namespaces | from ssv | where NAME != "default" | get NAME | prepend NONE
  }

  def "nu-complete kubectl deployments" [] {
    kubectl get deployment | from ssv | get NAME
  }

  def "nu-complete kubectl pods" [] {
    kubectl get pods | from ssv | get NAME
  }

  def "nu-complete kubectl es" [] {
    kubectl get es | from ssv | get NAME
  }

  def "nu-complete kubectl resources" [] {
    kubectl api-resources | from ssv | get SHORTNAMES NAME | flatten
  }

  def "nu-complete kubectl resource instances" [
    context: string
  ] {
    let resource = ($context | split words | last)
    kubectl get $resource | from ssv | get NAME
  }

  # List and change context
  export def kcon [
    context?: string@"nu-complete kubectl contexts"  # Context (fuzzy)
    namespace?: string@"nu-complete kubectl namespaces"  # Namespace (fuzzy)
  ] {
    if $context == null {
      return (kubectl config get-contexts | from ssv -a)
    }
    let context_match = (kubectl config get-contexts | from ssv -a | where NAME =~ $context)
    if ($context_match | length) != 1  {
      return "No or multiple matching contexts"
    }
    kubectl config use-context ($context_match | get NAME | to text)
    if $namespace == null {
      return
    }
    let namespace_match = (kubectl get namespace | from ssv -a | where NAME =~ $namespace)
    if ($namespace_match | length) != 1 {
      return "No or multiple matching namespaces"
    } else {
      kubectl config set-context ($context_match | get NAME | to text) --namespace ($namespace_match | get NAME | to text)
    }
  }

  # Change configured namespace in context
  export def kns [
    namespace?: string@"nu-complete kubectl namespaces" # Namespace
  ] {
    if $namespace == null {
      return (kubectl get ns | from ssv)
    }
    let match = (kubectl get namespaces | from ssv | where NAME != "default" | where NAME =~ $namespace)
    if $namespace == "NONE" {
      return (kubectl config set-context --current --namespace="")
    }
    kubectl config set-context --current --namespace ($match | get NAME | to text)
  }

  # Creates a diff of a kustomize folder with the live resources
  export def kdiff [
    path?: string  # Path of the kustomize folder
  ] {
    if $path == null {
      return (kubectl diff -k . | delta)
    }
    return (kubectl diff -k $path | delta)
  }

  # Explore resources
  export def ke [
    resource?: string@"nu-complete kubectl resources"  # Resource
    search?: string@"nu-complete kubectl resource instances"  # Filter resource's name with this value
    --all (-a)  # Search in all namespaces
    --full_definitions (-f)  # Output full definitionss for resources
  ] {

    mut output = [[];[]]
    mut extra_arg = (if $all {["-A"]} else {[]})
    let resource = (if $resource == null {"pods"} else {$resource})

    # Custom columns defined here per-resource
    if not $full_definitions {
      if $resource == "deploy" {
        $extra_arg = ($extra_arg | append ["-o" "custom-columns=NAME:metadata.name,READY:status.readyReplicas,CPU:spec.template.spec.containers[*].resources.requests.cpu,RAM:spec.template.spec.containers[*].resources.requests.memory,IMAGE:spec.template.spec.containers[*].image"])
      }
    }

    if $full_definitions {
      # Populate output with json
      $output = (kubectl get $resource -o json ...$extra_arg | from json | get items)
      # Refine output by metadata.name
      if $search != null {
        $output = ($output | where metadata.name =~ $search)
      }
    } else {
      # Populate output with simple get
      $output = (kubectl get $resource ...$extra_arg | from ssv)
      # Refine output by NAME
      if $search != null {
        $output = ($output | where NAME =~ $search)
      }
    }

    # If there's only one result in the output we return a record
    if ($output | length) == 1 {
      return ($output | into record)
    }
    # Otherwise it's a table
    return $output

  }

  # With https://github.com/keisku/kubectl-explore renamed to kubectl-explain
  export alias kex = kubectl-explain

  # View logs via fuzzy search
  export def kl [
    pod?: string@"nu-complete kubectl pods"  # Filter resource's name with this value
  ] {
    let possible_pods = (kubectl get pods | from ssv | where NAME =~ $pod | get NAME)

    if ($possible_pods | length) < 1 {
      return "No matching pods"
    }

    if ($possible_pods | length) == 1 {
      kubectl logs $possible_pods.0 | bat
    } else if ($possible_pods | length) > 1 {
      let pod_name = ($possible_pods | input list -f)
      kubectl logs $pod_name | bat
    }

  }

  # Get a specific YAML property from a resource
  export def kgp [
    property: cell-path # Cell-path to the property
    resource: string@"nu-complete kubectl resources"  # Resource
    search: string@"nu-complete kubectl resource instances"  # Filter resource's name with this value
    --decode (-d) # Decode the property using base64
  ] {
    mut resources = (kubectl get $resource -o json | from json | get items)
    mut output = ""
    $resources = ($resources | where metadata.name =~ $search)

    if ($resources | length) == 1 {
      $output = ($resources | into record | get $property)
    } else if ($resources| length) > 1 {
      let resource_name = ($resources | get metadata.name | input list -f)
      $output = ($resources | where metadata.name == $resource_name | into record | get $property)
    } else if ($resources | length) < 1 {
      return ("No resources matching the filter ; " + $search)
    }

    if $decode {
      return ($output | base64 -d)
    } else {
      return $output
    }

  }

  # Force a deployment to restart it's pods
  export def krestart [
    deployment: string@"nu-complete kubectl deployments"  # Deployment to restart
  ] {
    kubectl rollout restart deployment $deployment
  }
  
  # FIX this is broken at the moment
  # Refresh a ExternalSecret inside the cluster
  export def "kubectl sync-secret" [
    secret: string@"nu-complete kubectl es"  # Name of the secret
  ] {
    kubectl annotate es $secret ("force-sync=" + (date now | format date %s)) --overwrite
  }

}
