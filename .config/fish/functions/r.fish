# Open ranger and cd to location when quitting
function r
    ranger --choosedir ~/ranger_folder.tmp
    cd (cat ~/ranger_folder.tmp)
    rm ~/ranger_folder.tmp
end
