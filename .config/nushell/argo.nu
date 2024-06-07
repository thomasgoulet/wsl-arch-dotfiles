module argo {

  # List apps
  export def "argo apps" [] {
    let list = (argocd app list | from ssv -a)
    let kube_config = (open ~/.kube/config | from yaml)
    let kube_context = ($kube_config | get current-context)
    let kube_ns = ($kube_config | get contexts | where context.cluster == $kube_context | get context.namespace.0)
    return ($list | where NAMESPACE =~ $kube_ns | select NAME PROJECT STATUS HEALTH SYNCPOLICY PATH TARGET)
  }

  # List and change context
  export def "argo con" [
    context?: string  # Context (fuzzy)
  ] {
    if $context == null {
      return (argocd ctx | from ssv -a)
    }
    let match = (argocd ctx | from ssv -a | where NAME =~ $context)
    if ($match | length) != 1 {
      return "No matching context"
    }
    argocd ctx ($match | get NAME | to text)
  }

  # Login to a ArgoCD server
  export def "argo login" [
    url: string  # ArgoCD web url to login to
  ] {
    argocd login $url --sso
  }

}
