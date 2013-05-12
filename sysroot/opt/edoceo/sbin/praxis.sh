#!/bin/bash
#
# Base Praxis Command
#  @see /usr/lib/portage/bin/etc-update

# @todo check for LANG and LC_COLLATE

set -o errexit
# set -o nounset

# Colors and reset Screen
# CLEAR=""
N="\033[0;39m" # Reset Terminal Defaults
R="\033[1;31m" # R: Failure or error message
G="\033[1;32m" # G: Commands
Y="\033[1;33m" # Y: Options
B="\033[1;34m" # B: Paths
# MAGENTA: Found devices or drivers
# MAGENTA=""
# CYAN: Questions
# CYAN=""
W="\033[1;37m" # white
# X="\033[1;38m" # white

export EMERGE_DEFAULT_OPTS="--alphabetical --nospinner --misspell-suggestions=n"
export NOCOLOR="true"
export PORTAGE_NICENESS=15

thiscmd=$( readlink -f $0 )
thisdir=$( dirname "$thiscmd" )
basedir=$( dirname "$thisdir" )

opt_action=
opt_force=0
opt_fetch=0

#
# Check the System Health
#
function praxis_check()
{
    echo "* Pending Updates:"
    ( emerge --update --deep --newuse --pretend @world | grep '\[' ) || true

    echo "* emaint checks"
    emaint --check all

    if [ -x /usr/bin/revdep-rebuild ]; then
        echo "* Reverse Dependency Check (revdep-rebuild):"
        revdep-rebuild --pretend --ignore --quiet | egrep '^  broken|^\[ebuild'
    fi

    if [ -x /usr/bin/python-updater ]; then
        echo "* Python Updates"
        python-updater -- --getbinpkg --oneshot --pretend --verbose
    fi

    if [ -x /usr/sbin/module-rebuild ]; then
        echo "* Modules to Rebuild"
        module-rebuild -- --getbinpkg --oneshot --pretend --verbose
    else
        echo "Missing: sys-kernel/module-rebuild"
    fi

    # Packages that can be removed old slots
    echo "* Packages to Clean [ --clean ]"
    (emerge --clean --pretend) || true

    # Prune
    echo "* Packages to Prune [ --prune ]"
    (emerge --prune --nodeps --pretend | egrep '^ \w+|^ +selected') || true

    # Cleans the system by removing packages that are not associated with explicitly merged packages
    echo "* Unused Packages [ --depclean ]"
    (emerge --depclean --pretend | egrep '^ \w+|^ +selected') || true

    # @todo do we want this in here?
    chk=$(eselect news count all)
    if [[ "x$chk" != "x0" ]]; then
        echo "News:"
        eselect news list
    fi

    # eclean distfiles --pretend 
    # eclean packages --pretend

    # Check GLSA
    echo "* Gentoo Linux Security Announcements:"
    for x in $( nice glsa-check --test affected 2>&1 |grep '^[0-9]' ); do
        nice glsa-check --print $x 2>/dev/null|awk '($0=="") && (p=="") {exit}{print;p=$0}'|sed '/^$/d'
        echo -n "Updates:           "
        nice glsa-check --pretend $x 2>/dev/null|awk '/^     /{print $1 $2}'|tr '\n' ','
        echo
    done

    # @todo grep /etc/locale.gen for entires
    x=$(grep -v -e '^#' -e '^$' -e '^[[:space:]]*$' /etc/locale.gen)
    if [[ -z "$x" ]]; then
        echo "!! /etc/locale.gen needs to be updated"
    fi

    # Remove nox11 from /etc/pam.d/system-login
    # session   optional   pam_ck_connector.so nox11 

}

# Dependency Check
function praxis_check_depend_on()
{
    atom=$1

    # Show Packages Depending on $atom
    echo "Packages Depending On: $atom"
    equery --quiet depends $atom
    qdepends --query $atom | tr '\n' ' '
    echo

    # What does $atom depend on?
    echo "$atom Depends On:"
    qdepends --all $atom

}

function praxis_clean()
{
    eselect news purge

    rm /var/log/emerge.log
    rm /var/log/emerge-fetch.log
    rm /var/log/portage/elog/summary.log

    eclean distfiles
    eclean packages

}

#
# Display Help
#
function praxis_help()
{
cat <<EOF
    -d|--debug)   Enable Debug Mode
    -h|--help)    This Help
    -V|--version) Display Version
    +fetch)       Force Fetching
    +force)       Force Command (like sync/update)
    check)        Check the System including GLSA
    clean)        Removes Cruft, Logs, &c
    depends)      praxis_check_depend_on XX
    size)         Determine Size of Installed Packages
    update)       Update this Host (sync, -pvuDN world)
    verify)       Verify is not Handled Yet, what should we do?
    verify=*)     Verify is not Handled Yet, what should we do?
EOF
}

#
# check for root or die
#
function praxis_need_root()
{
    if [[ "x$UID" != "x0" ]]; then
        echo -e "\n  You've got to be root to run this thing\n"
        exit 1;
    fi
}

# Package Size Output
function praxis_package_size()
{
    equery size '*' \
        | awk '{ print $4 " " $1 }' \
        | sed 's/size//' | sed 's/[()]//g' \
        | sort --numeric-sort --reverse
}

#
# Updates this system from the Portage Source
# Does a little house-keepting too
function praxis_update()
{
    # Get the Latest Portage Tree from Gentoo
    # if [ "x$opt_force" == "x1" ]; then
    #     # @todo use $PORT_DIR
    #     set
    #     exit
    #     rm -fr /usr/portage/metadata/timestamp.chk
    # fi
    emerge --sync > /dev/null

    # Print List of Updates
    emerge --deep --newuse --update @world

    echo "Gentoo News:"
    eselect news list

    # Clean up
    eclean distfiles > /dev/null
    eclean packages > /dev/null

    revdep-rebuild --ignore

    # @todo eselect stuff here
    echo "Removable Packages"
    (emerge --depclean --pretend | grep "All selected packages" | cut -d: -f2) || true

}

#
# main()
#
# Nothing or Help?
if [[ $# == 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help"  ]]; then
    praxis_help;
    exit;
fi

# Loop Options
while [[ $# > 0 ]] ; do
    case $1 in
        -d|--debug)   set -x ;;
        -h|--help)    praxis_help ;;
        -V|--version) echo 'Edoceo Praxis v1800'; exit 0 ;;
        +fetch)
            opt_fetch="x1"
            ;;
        +force)
            opt_force="x1"
            ;;
        binhost_build
            emerge --sync
            emerge -vuDN @world
            
            ;;
        binhost_publish)
            if [ -z "$praxis_binhost_publish" ]; then
                echo " ${R}*${N} Please set praxis_binhost_publish in make.conf"
                exit
            fi
            eclean disfiles
            eclean packages
            rsync \
                --archive \
                --delete-before \
                /usr/portage/packages/ \
                $praxis_binhost_publish
            ;;
        check)
            echo "Check is not Handled Yet, what should we do?"
            ;;
        depends)
            shift;
            praxis_check_depend_on $1
            ;;
        size)
            praxis_package_size
            ;;
        stage4-pack)
            praxis_need_root
            praxis_stage4_pack
            ;;
        update)
            praxis_need_root
            praxis_update
            ;;
        verify)
            echo "Verify is not Handled Yet, what should we do?"
            ;;
        verify=*)
            echo "Verify is not Handled Yet, what should we do?"
            ;;
        *)
            set +o xtrace
            set -o errtrace
            set -o functrace
            set -o monitor
            echo "The command or option '$1' was not recognized"
            praxis_help
            exit
            ;;
    esac
    shift
done
