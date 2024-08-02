module kube {

    ### Aliases

    export alias k = kubectl;

    ### Helpers

    def cache [
        timeout: int  # Timeout in seconds after which the cache is invalidated
        key: string  # Cache key
        closure: closure  # Will only be run if timeout is exceeded to refresh the cache value
    ] {
        try {
            stor create -t kubecache -c {
                key: str,
                expirystamp: int,
                value: str
            };
        }

        let cache = (stor open).kubecache;

        # If key is in cache and has not timed out
        if (
            $cache
            | where key == $key and expirystamp > (date now | format date %s | into int)
            | length
            | into bool
        ) {
            return (
                $cache
                | where key == $key and expirystamp > (date now | format date %s | into int)
                | first
                | get value
                | from json
            );
        }

        # If key is not present or expired
        let value = do $closure;
        try {
            stor delete -t kubecache -w $"key == '($key)'";
        };
        stor insert -t kubecache -d {
            key: $key,
            expirystamp: ($"in ($timeout) seconds" | into datetime | format date %s | into int),
            value: ($value | to json)
        };
        return $value;
    }

    def cache-invalidate [] {
        try {
            stor delete -t kubecache;
        }
    }

    ### Completions
 
    def "nu-complete kubectl contexts" [] {
        cache 60 contexts {||
            kubectl config get-contexts
            | from ssv -a
            | get NAME
        };
    }

    def "nu-complete kubectl namespaces" [] {
        cache 60 namespaces {||
            kubectl get namespaces
            | from ssv
            | where NAME != "default"
            | get NAME
            | prepend NONE
        };
    }

    def "nu-complete kubectl pods" [] {
        kubectl get pods
        | from ssv
        | get NAME;
    }

    def "nu-complete kubectl shell" [] {
        cache 15 restartable {||
            kubectl get pods -o wide
            | from ssv -a
            | select NAME NODE
            | rename value description
            | append (
                kubectl get nodes -o wide
                | from ssv -a
                | select NAME INTERNAL-IP
                | rename value description
            );
        };
    }

    def "nu-complete kubectl kinds" [] {
        cache 60 kinds {||
            kubectl api-resources
            | from ssv
            | select SHORTNAMES NAME
            | insert len { $in.NAME | str length }
            | sort-by len
            | get NAME SHORTNAMES
            | flatten
            | uniq
        };
    }

    def "nu-complete kubectl kind instances" [
        context: string
    ] {
        let kind = (
            $context
            | split row ' '
            | get 1
        );
        cache 15 $"kind.($kind)" {||
            kubectl get $kind
            | from ssv
            | get NAME
        };
    }

    def "nu-complete kubectl restartable" [] {
        cache 15 restartable {||
            ["deployment" "statefulset" "daemonset"]
            | par-each {kubectl get $in e> (null-device) | from ssv -a}
            | flatten
            | get NAME
        };
    }

    ### Exported Functions
 
    # List and change context
    export def kcon [
        context: string@"nu-complete kubectl contexts"  # Context (fuzzy)
        namespace?: string@"nu-complete kubectl namespaces"  # Namespace
    ] {
        cache-invalidate

        let context_match = (
            kubectl config get-contexts
            | from ssv -a
            | where NAME =~ $context
        );

        if ($context_match | length) != 1 {
            return "No or multiple matching contexts";
        }

        kubectl config use-context ($context_match | get NAME | to text) o> (null-device);

        if ($namespace != null) {
            kubectl config set-context ($context_match | get NAME | to text) --namespace $namespace o> (null-device);
        }
    }

    # Change configured namespace in context
    export def kns [
        namespace: string@"nu-complete kubectl namespaces"  # Namespace
    ] {
        cache-invalidate

        if ($namespace == "NONE") {
            return (kubectl config set-context --current --namespace="" o> (null-device));
        }

        kubectl config set-context --current --namespace $namespace o> (null-device);
    }

    # List resources
    export def kl [
        kind = "pods": string@"nu-complete kubectl kinds"  # Resource
        search?: string@"nu-complete kubectl kind instances"  # Filter resource's name with this value
        --all (-a)  # Search in all namespaces
        --full_definitions (-f)  # Output full definitionss for resources
    ] {

        mut output = [[];[]];
        mut extra_arg = (
            if $all {["-A"]} else {[]}
        );

        # Custom columns defined here per-resource
        if (not $full_definitions) {
            # Custom columns for some resources
            if ($kind == "deploy") {
                $extra_arg = (
                    $extra_arg
                    | append ["-o" "custom-columns=NAME:metadata.name,READY:status.readyReplicas,CPU:spec.template.spec.containers[*].resources.requests.cpu,RAM:spec.template.spec.containers[*].resources.requests.memory,IMAGE:spec.template.spec.containers[*].image"]
                );
            }
            # Populate output with simple get
            $output = (
                kubectl get $kind ...$extra_arg e> (null-device)
                | from ssv
            );
            # Refine output by NAME
            if $search != null {
                $output = (
                    $output
                    | where NAME =~ $search
                );
            }
        }

        if ($full_definitions) {
            # Populate output with json
            $output = (
                kubectl get $kind -o json ...$extra_arg e> (null-device)
                | from json
                | get items
            );
            # Refine output by metadata.name
            if ($search != null) {
                $output = (
                    $output
                    | where metadata.name =~ $search
                );
            }
        }

        # If there's only one result in the output we return a record
        if (($output | length) == 1) {
            return ($output | into record);
        }
        return $output;

    }

    # With https://github.com/keisku/kubectl-explore renamed to kubectl-explain
    export alias kex = kubectl-explain;

    # View logs
    export def klogs [
        pod: string@"nu-complete kubectl pods"  # Filter resource's name with this value
    ] {
        kubectl logs $pod
        | bat;
    }

    # Completes the possible paths for kgp
    export def "nu-complete kg path" [
        context: string
    ] {
        let resource_info = (
            $context
            | split row ' '
            | first 3
        );
        let kind = $resource_info.1;
        let instance = $resource_info.2;

        let current_path = (
            $context
            | split row ' '
            | skip 3
            | drop 1
        );
        let cell_path = (
            $current_path
            | each {|in| let $i = $in; try {$i | into int} catch {$i} }
            | into cell-path
        );

        let resource = cache 30 $"($kind).($instance)" {||
            kubectl get $kind $instance -o yaml | from yaml
        };
        let yaml = (
            $resource
            | get $cell_path
        );

        if ($yaml | describe | str starts-with record) {
            return (
                $yaml
                | columns
                | each {|in| let i = $in; { value: $i, description: ($yaml | get $i | to text) } }
            );
        }
        if ($yaml | describe | str starts-with table) {
            return (
                0..(($yaml | length) - 1)
                | each {|in| let i = $in; {value: ($i | into string), description: ($yaml | get ($i | into cell-path) | to text)}}
            );
        }
    }


    # Get a specific resource and it's full specification
    export def kg [
        kind: string@"nu-complete kubectl kinds"  # Kind
        name: string@"nu-complete kubectl kind instances"  # Name
        ...property: any@"nu-complete kg path"  # Path to filter
        --decode (-d)  # Decode the property using base64
    ] {
        let yaml = (
            kubectl get $kind $name -o yaml
            | from yaml
        );

        try {
            let output = (
                $yaml
                | get ($property | into cell-path)
            );
            if ($decode) {
                return ($output | base64 -d);
            }
            return $output;
        } catch {
            return "Path was not valid for the resource";
        }
    }

    # Force a deployment to restart it's pods
    export def krestart [
        set: string@"nu-complete kubectl restartable"  # Restartable set to restart
    ] {
        ["deployment" "statefulset" "daemonset"]
        | par-each { |in|
            let i = $in;
            let instances = kubectl get $i e> (null-device) | from ssv -a | get NAME;
            if ($set in $instances) {
                kubectl rollout restart $i $set o> (null-device);
            }
        };
    }

    # Exec into a pod or a node
    export def ksh [
        name: string@"nu-complete kubectl shell"  # Name of node or pod to exec into
        --new (-n)  # Start a new pod with the specified name using an alpine image
    ] {
        if ($new) {
            kubectl run $name --rm -it --image=alpine -- sh;
            return;
        }

        let pods = (
            kubectl get pods
            | from ssv -a
            | get NAME
        );
        if ($name in $pods) {
            kubectl exec --stdin --tty $name -- /bin/bash;
            return;
        } 

        try {
            let nodes = (
                kubectl get nodes
                | from ssv -a
                | get NAME
            );
            if ($name in $nodes) {
                kubectl node_shell $name;
                return;
            }
        }
        return $"No resource called ($name). Specify '-n' to launch a new pod with that name"
    }

    # List vulnerabilities reported inside kubernetes
    export def ktrivy [
        --all (-a)  # Show non-critical vulnerabilities
    ] {
        let vulerabilities =  kubectl get policyreports -l trivy-operator.source=VulnerabilityReport -o yaml
            | from yaml
            | get items.results
            | flatten
            | select resources.0.name policy severity message
            | rename RESOURCE POLICY SEVERITY MESSAGE;
        if ($all) {
            return $vulerabilities;
        }
        return (
            $vulerabilities | where SEVERITY == critical
        );
    }
}
