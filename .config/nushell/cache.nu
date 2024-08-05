module cache {

    export def hit [
        key: string  # Cache key
        timeout: int  # Timeout in seconds after which the cache is invalidated
        closure: closure  # Will only be run if timeout is exceeded to refresh the cache value
    ] {
        try {
            stor create -t cache -c {
                key: str,
                expirystamp: int,
                value: str
            };
        }

        let cache = (stor open).cache;

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
            stor delete -t cache -w $"key == '($key)'";
        };
        stor insert -t cache -d {
            key: $key,
            expirystamp: ($"in ($timeout) seconds" | into datetime | format date %s | into int),
            value: ($value | to json)
        };
        return $value;
    }

    export def invalidate [] {
        try {
            stor delete -t cache;
        }
    }
  
}
