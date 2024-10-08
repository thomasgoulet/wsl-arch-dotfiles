module kube {

    ### Aliases

    export alias k = kubectl;

    ### Utility

    export def argparse [
        context: string  # Context string passed to completer function
    ] {
        mut args = (
            $context
            | split row ' '
        );

        mut flags = [];

        let namespace_position = (
            $args
            | iter find-index {|s|
                $s == "-n" or $s == "--namespace"
            }
        );

        if ($namespace_position != -1) {
            $flags = [
                "-n"
                ($args | get ($namespace_position + 1))
            ];
            $args = (
                $args
                | drop nth $namespace_position
                | drop nth $namespace_position
            );
        }

        let all_position = (
            $args
            | iter find-index {|s|
                $s == "-A" or $s == "-a" or $s == "--all"
            }
        );

        if ($all_position != -1) {
            $flags = ["-A"];
            $args = (
                $args
                | drop nth $all_position
            )
        }

        return {command: ($args.0), args: ($args | skip 1), flags: $flags, flag_id: ($flags | str join ".")}
    }

    ### Completions

    def "nu-complete kubectl contexts" [] {
        cache hit kube.contexts 60 {||
            kubectl config get-contexts
            | from ssv -a
            | iter filter-map {|c|
                {value: ($c.NAME), description: $"cluster: ($c.CLUSTER), namespace:  ($c.NAMESPACE)"}
            }
        };
    }

    def "nu-complete kubectl namespaces" [] {
        cache hit kube.namespaces 60 {||
            kubectl get namespaces
            | from ssv
            | where NAME != "default"
            | get NAME
            | prepend NONE
        };
    }

    def "nu-complete kubectl pods" [
        context: string
    ] {
        let ctx = argparse $context;
        cache hit $"kube.pods.($ctx.flag_id)" 15 {||
            kubectl get pods ...$ctx.flags
            | from ssv
            | get NAME
        };
    }

    def "nu-complete kubectl shell" [] {
        cache hit kube.restartable 15 {||
            kubectl get pods -o wide
            | from ssv -a
            | select NAME NODE
            | rename value description
            | append (
                kubectl get nodes -o wide
                | from ssv -a
                | select NAME INTERNAL-IP
                | rename value description
            )
        };
    }

    def "nu-complete kubectl kinds" [] {
        cache hit kube.kinds 60 {||
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
        let ctx = argparse $context
        cache hit $"kube.kind.($ctx.args.0).($ctx.flag_id)" 15 {||
            kubectl get $ctx.args.0 ...$ctx.flags
            | from ssv
            | get NAME
        };
    }

    def "nu-complete kubectl pod ports" [
        context: string
    ] {
        let ctx = argparse $context
        cache hit $"kube.ports.($ctx.args.0)" 15 {||
            kubectl get pods $ctx.args.0 -o yaml
            | from yaml
            | select spec.containers.ports
            | flatten
            | flatten
            | flatten
            | select containerPort name
            | rename value description
        };
    }

    def "nu-complete kubectl restartable" [] {
        cache hit kube.restartable 15 {||
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
        cache invalidate

        mut match = [];
        $match = (
            kubectl config get-contexts
            | from ssv -a
            | where NAME == $context
        );
        if ($match == []) {
            $match = (
                kubectl config get-contexts
                | from ssv -a
                | where NAME =~ $context
            );
        }

        if (($match | length) != 1) {
            return "No or multiple matching contexts";
        } else {
            $match = (
                $match
                | first
            );
        }

        kubectl config use-context ($match | get NAME | to text) o> (null-device);

        if ($namespace != null) {
            kubectl config set-context ($match | get NAME | to text) --namespace $namespace o> (null-device);
        }
    }

    # List resources
    export def kl [
        kind = "pods": string@"nu-complete kubectl kinds"  # Resource
        search?: string@"nu-complete kubectl kind instances"  # Filter resource's name with this value
        --namespace (-n): string@"nu-complete kubectl namespaces"  # Namespace to list resources in
        --all (-a)  # Search in all namespaces
        --full_definitions (-f)  # Output full definitionss for resources
    ] {

        mut output = [[];[]];
        mut flags = (
            if $all {
                ["-A"]
            } else if ($namespace != null) {
                ["-n" $namespace]
            } else {
                []
            }
        );

        # Custom columns defined here per-resource
        if (not $full_definitions) {
            # Custom columns for some resources
            if ($kind == "deploy") {
                $flags = (
                    $flags
                    | append ["-o" "custom-columns=NAME:metadata.name,READY:status.readyReplicas,CPU:spec.template.spec.containers[*].resources.requests.cpu,RAM:spec.template.spec.containers[*].resources.requests.memory,IMAGE:spec.template.spec.containers[*].image"]
                );
            }
            # Populate output with simple get
            $output = (
                kubectl get $kind ...$flags e> (null-device)
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
                kubectl get $kind -o json ...$flags e> (null-device)
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
        let ctx = argparse $context
        let kind = $ctx.args.0;
        let instance = $ctx.args.1;

        let current_path = (
            $ctx.args
            | skip 2
            | drop 1
        );
        let cell_path = (
            $current_path
            | each {|in| let $i = $in; try {$i | into int} catch {$i} }
            | into cell-path
        );

        let resource = cache hit $"kube.($kind).($instance)" 30 {||
            kubectl get $kind $instance ...$ctx.flags -o yaml | from yaml
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
        --namespace (-n): string@"nu-complete kubectl namespaces"  # Namespace to list resources in
        --all (-a)  # Search in all namespaces
        --decode (-d)  # Decode the property using base64
    ] {
        mut extra_arg = (
            if $all {["-A"]} else if ($namespace != null) {["-n" $namespace]} else {[]}
        );

        let yaml = (
            kubectl get $kind $name ...$extra_arg -o yaml
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

    export def kpf [
        pod: string@"nu-complete kubectl pods"
        port: string@"nu-complete kubectl pod ports"
    ] {
        kubectl port-forward $pod $"($port):($port)";
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
        shell="/bin/bash"  # Process to launch (when specifying a pod)
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
            kubectl exec --stdin --tty $name -- $shell;
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
