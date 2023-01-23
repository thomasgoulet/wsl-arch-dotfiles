# Profile fish shell startup time
function fish_profile_startup
    fish --profile-startup /tmp/fish.profile -i -c exit
    sort -k2n /tmp/fish.profile
    rm /tmp/fish.profile
end