# Save script code section - BEGIN ===============================
if [ "${save_as_script}" = "true" ]; then
    # load EnginFrame script tools libraries
    . "${EF_ROOT}/plugins/ef/lib/utils"
    
    # get service info
    service_script=$0
    service_bin=$(dirname $0)
    service_folder=$(readlink -f "${service_bin}/..")
    service_options_ids=$(cat "${service_folder}"/WEBAPP/service.xml | \
        sed '/^[ \t]*<ef:option .*/!d;s/^.* id="\([^"]*\)"[ >].*$/\1/g;\
        /^[ \t]*<ef:option/d;/save_as_script/d')
    service_name=$(cat "${service_folder}"/WEBAPP/service.xml | \
        sed '/^[ \t]*<ef:name/!d;s/.*<ef:name>\([^ \t<]*\).*/\1/')
    
    # start building script
    echo '#!/bin/bash' > ./${service_name}-script.sh
    echo '' >> ./${service_name}-script.sh
    echo '# set submission folder as EF_SPOOLER here, default: ${HOME}' >> \
        ./${service_name}-script.sh
    echo 'declare -x EF_SPOOLER="${HOME}"' >> ./${service_name}-script.sh
    echo '' >> ./${service_name}-script.sh
    
    # dump script environment variables
    echo '# set service options here' >> ./${service_name}-script.sh
    for env_variable in ${service_options_ids}; do 
        declare -p ${env_variable} >> ./${service_name}-script.sh
    done
    
    # dump portal main variables
    echo '' >> ./${service_name}-script.sh
    echo '# portal environment variables, do not modify' >> \
        ./${service_name}-script.sh
    declare -p | sed '/^declare -x EF_SPOOLER/d' | sed '/^declare -x EF_/!d' >> \
        ./${service_name}-script.sh

    # dump submission arguments
    echo '' >> ./${service_name}-script.sh
    echo '# submission parameters' >> ./${service_name}-script.sh

    # get and port other submission options
    set --
    set -- "${args[@]}"
    submission_args=()
    while [ $# -gt 0 ]
    do
        case "$1" in
            --queue|-q)
                shift
                submission_args+=(-q "$1")
            ;;
            --host)
                shift
                submission_args+=(-l "host=$1")
            ;;
            --processors)
                shift
                submission_args+=(-l "ncpus=$1")
            ;;
            --jobname)
                shift
                submission_args+=(-N "$1")
            ;;
            --project)
                shift
                submission_args+=(-A "$1")
            ;;
            --submitopts)
                shift
                submission_args+=($1)
            ;;
            --stdout)
                shift
                submission_args+=(-o "$1")
            ;;
            --stdin)
                shift
                submission_args+=(-i "$1")
            ;;
            --stderr)
                shift
                submission_args+=(-e "$1")
            ;;
            --resource)
                shift
                submission_args+=(-l "$1")
            ;;
            --command)
                shift
                job_script=$1
            ;;
            -*)
                echo "$0: error - unrecognized option $1" 1>&2;
                exit 1
            ;;
            *)  break
            ;;
        esac
        shift
    done

    echo "submission_args=(${submission_args[@]})" >> ./${service_name}-script.sh
    echo '' >> ./${service_name}-script.sh
    
    # if using MyHPC professional services solution, uncomment the following 8 lines
    ## extract BASH arrays myhpc_cunit, myhpc_tags, myhpc_files and myhpc_rspoolers
    ## transform the list of command-line arguments adding/modifying --submitopts
    #set --
    #set -- --myhpc-cunit "${myhpc[@]}" --myhpc-tags "${tags[@]}"
    #myhpc_args=$(source "${EF_ROOT}/plugins/rgrid-agent/bin/grid.submit.parser.sh" \
    #    2>&1 | sed '$!d' | sed "s/^.* --submitopts '//" | sed "s/'$//")
    #echo "myhpc_args=\"${myhpc_args}\"" >> ./${service_name}-script.sh
    #echo '' >> ./${service_name}-script.sh
    
    # identify the target job script
    if [ -z "${job_script}" ]; then
        job_script="${service_bin}/job-script.sh"
    fi
    echo "job_script=\"${job_script}\"" >> ./${service_name}-script.sh
    echo '' >> ./${service_name}-script.sh
    echo "qsub \${submission_args[@]} \${myhpc_args} \${job_script}" >> \
        ./${service_name}-script.sh
    chmod 755 ./${service_name}-script.sh

    # place a copy of the saved script under ${HOME}/enginframe/saved.scripts
    mkdir -p "${HOME}/enginframe/saved.scripts"
    cp -a ./${service_name}-script.sh "${HOME}/enginframe/saved.scripts"
    
    # finally, redirect to spooler view and script download
    "${EF_ROOT}/plugins/ef/bin/ef.spooler.info" "${EF_SPOOLER_URI}" \
        "${service_name}-script"
    echo "  <ef:redirect>$(ef_xml_escape_content -i \
        "${REQUEST_URL_FIXED}?_uri=//com.enginframe.system/show.spooler&_spooler=\
         $(ef_escape_uri_component "${EF_SPOOLER_URI}")")</ef:redirect>"
    exit
fi

# Save script code section - END =================================
