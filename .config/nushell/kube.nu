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

  def "nu-complete kubectl resource instances" [
    context: string
  ] {
    let resource = ($context | split words | last)
    (kubectl get $resource | from ssv | get NAME)
  }

  # Change context
  export alias kcon = kubectl context
  # Change context
  export def "kubectl context" [
    context?: string@"nu-complete kubectl contexts"  # Context
  ] {
    if $context == null {
      return (kubectl config get-contexts | from ssv -a)
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
    search?: string@"nu-complete kubectl resource instances"  # Filter resource's name with this value
    ...properties: cell-path  # Output only selected properties
    --all (-a)  # Search in all namespaces
    --full_definitions (-f)  # Output full definitionss for resources
  ] {

    mut output = [[];]
    let all_arg = (if $all {["-A"]} else {[]})

    if not $full_definitions {
      # Populate output with simple get
      $output = (kubectl get $resource $all_arg | from ssv)
      # Refine output by NAME
      if $search != null {
        $output = ($output | where NAME =~ $search)
      }
    } else {
      # Populate output with json
      $output = (kubectl get $resource -o json $all_arg | from json | get items)
      # Refine output by metadata.name
      if $search != null {
        $output = ($output | where metadata.name =~ $search)
      }
    }

    # If there's only one result and we selected one property
    if ($output | length) == 1 and ($properties | length) == 1 {
      # We get the property and return it because chances are we want to manipulate it
      return ($output | into record | get $properties.0)
    }

    # This selects the specifid properties for each result in the output
    if not ($properties | is-empty) {
      # Output will become a table with all the records once flattened
      $output = ($output | each { |result|
        # This outputs a table where the columns are the properties and each row has 1 value and multiple nulls
        let $new_result = ($properties | each { |p|
          $result | select -i $p
        })
        # We get the names so the properties can be mapped to their corresponding results easily then we turn it into a record to remove the nulls
        if not $full_definitions {
          $new_result | prepend ($result | select NAME) | into record
        } else {
          $new_result | prepend ($result | select metadata.name) | into record
        }
      } | flatten | rename NAME)
    }

    # If there's only one result in the output we return a record
    if ($output | length) == 1 {
      $output = ($output | into record)
    }
    # Otherwise it's a table
    return $output

  }

}