#!/bin/bash


N='\033[0m'
C='\033[0;36m'




print_banner() {
    echo "******************************************"
    echo "*                VigilProxy              *"
    echo "*           Proxy Testing Tool           *"
    echo "*                  v1.1.1                *"
    echo "*      ----------------------------      *"
    echo "*                        by @ImKKingshuk *"
    echo "* Github- https://github.com/ImKKingshuk *"
    echo "******************************************"
    echo
}


function get_test_url() {
    read -p "Enter a URL for testing proxy connectivity (default: https://www.google.com): " TEST_URL
    TEST_URL=${TEST_URL:-"https://www.google.com"}
}


function get_output_format() {
    PS3="Select the output format: "
    options=("Text" "JSON")
    select opt in "${options[@]}"; do
        case $opt in
            "Text") OUTPUT_FORMAT="text"; break;;
            "JSON") OUTPUT_FORMAT="json"; break;;
            *) echo "Invalid option";;
        esac
    done
}


function get_output_directory() {
    read -p "Enter the output directory (default: current directory): " OUTPUT_DIR
    OUTPUT_DIR=${OUTPUT_DIR:-"."}
}


function fetch_and_test_proxies() {
    local proxy_file="proxy.txt"
    local working_proxies_file="$OUTPUT_DIR/working_proxies.$OUTPUT_FORMAT"

   
    echo "Fetching proxies from Internet..."
    for source in "${sources[@]}"; do
        curl -s "$source" >> "$proxy_file"
    done

   
    function test_proxy() {
        local proxy=$1
        if curl --proxy $proxy --connect-timeout $TIMEOUT_CONNECT --max-time $TIMEOUT_TOTAL --silent --head "$TEST_URL" > /dev/null; then
            if [ "$OUTPUT_FORMAT" == "json" ]; then
                echo "{ \"proxy\": \"$proxy\", \"status\": \"working\" }," >> "$working_proxies_file"
            else
                echo "$proxy is working" >> "$working_proxies_file"
            fi
        fi
    }

   
    function display_progress() {
        local pid=$1
        local message=$2
        while kill -0 $pid 2> /dev/null; do
            printf "%s" "$message"
            sleep 1
        done
        printf "\n"
    }

   
    echo "Testing proxies ..."
    echo "It may take some time to test all proxies. Please wait..."
    mkdir -p "$OUTPUT_DIR"
    if [ "$OUTPUT_FORMAT" == "json" ]; then
        echo "[" >> "$working_proxies_file"
    fi
    while read -r line; do
        test_proxy "$line" &
        pid=$!
        display_progress $pid "Testing proxies ..."
    done < "$proxy_file"

   
    rm "$proxy_file"

   
    if [ "$OUTPUT_FORMAT" == "json" ]; then
        echo "{}]" >> "$working_proxies_file"
    fi

    
    echo "Script execution completed. Results are saved in $working_proxies_file"
    echo "Script log is available at $OUTPUT_DIR/proxy_research_tool.log" >> "$OUTPUT_DIR/proxy_research_tool.log"
}


print_banner


get_test_url
get_output_format
get_output_directory


declare -a sources=(
    "https://www.proxy-list.download/api/v1/get?type=http"
    "https://api.proxyscrape.com/v2/?request=getproxies&protocol=http&timeout=10000&country=all"
    "https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt"
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://www.proxy-list.download/api/v1/get?type=https"
    "https://api.proxyscrape.com/v2/?request=getproxies&protocol=https&timeout=10000&country=all"
    "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/http.txt"
    "https://raw.githubusercontent.com/hookzof/socks5_list/master/proxy.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/http.txt"
    "https://raw.githubusercontent.com/ShiftyTR/Proxy-List/master/https.txt"
)


fetch_and_test_proxies
