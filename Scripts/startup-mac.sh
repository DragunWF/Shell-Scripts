printf "\nWelcome back, great DragunWF of the Philippines...\n\n"
printf "Commands:\n- move-img\n- switch-dir <index>\n\n"
username="dragunwf"

function dir {
    ls -l
}

function move-img {
    echo "Running script..."
    python3 "/Users/$username/documents/devstuff/repositories/mini-scripts/personal/change_image_location.py"
}

function delete-img {
    echo "Running delete script..."
    python3 ""
}

function switch-dir () {
    user_dir="/Users/$username"
    repositories_dir="/$user_dir/documents/devstuff/repositories"
    unity_dir="/$user_dir/documents/devstuff/unity"
    dump_dir="/$user_dir/documents/devstuff/dump"
    case $1 in
        "1") cd $user_dir
        ;;
        "2") cd $repositories_dir
        ;;
        "3") cd $unity_dir
        ;;
        "4") cd $dump_dir
        ;;
        *) echo "Index is out of range!"
    esac
}