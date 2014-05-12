#!/bin/bash

usage()
{
    echo "$NAME: usage: $NAME [ -f | --fromport port][ -v | --volume change in volume] -t | --toport port  -k | --key key ip."
    echo ""
    echo "It's rather rudimentary right now."
    echo "volume adjestment is done on the other persons side."
    echo "from port is where you are listening form."
    echo "Normally it would be the same as the toport value."
}

NAME=$1

while [[ -n $1 ]]; do
    case $1 in
        -f | --fromport)    shift
            fromport=$1
            ;;
        -k | --key)         shift
            key=$1
            ;;
        -t | --toport)      shift
            toport=$1
            ;;
        -v | --volume)      shift
            volume=$1
            ;;
            *)              ip=$1
                ;;
    esac
shift
done

if [[ -n $fromport ]]; then
    if [[ $fromport =~ [^0-9] ]]; then
        echo "Bad value for fromport $fromport."
        exit 1
    fi
fi

if [[ -n $toport ]]; then
    if [[ $toport =~ [^0-9] ]]; then
        echo "Bad value for toport $toport."
        exit 1
    fi
fi

if [[ -n $volume ]]; then
    if [[ $volume =~ [^-0-9] ]]; then
        echo "Bad value for volume $volume."
        exit 1
    fi
fi

if [[ -n $ip ]]; then
    if [[ $ip =~ [^.0-9] ]]; then
        echo "Bad value for ip $ip."
        exit 1
    fi
fi

if [[ ! -r $key ]]; then
{
    echo "Key file $key does not exist or is not writable."
    exit 1
}
fi

mkfifo in;

ret=$?;

if( [[ $ret > 0 ]] ) then
{
    echo "mkfifo returned $ret"
    exit 1
}
fi

gpg2 --decrypt --output - $key >> in &


if [[ $volume ]]; then
{
    ffmpeg -nostdin -f video4linux2 -framerate 20 \
    -s:v 640x480 -i /dev/video0 -ac 2 -f alsa -i hw:0 -ac 2 -c:a libvorbis \
    -s:v 640x480 -b:v 100KiB -c:v libvpx -f nut -b:a 9000B \
    -filter_complex volume=$volume - | aespipe -e AES256 -H SHA512 \
    -P in | nc -w 60 -n $ip $toport > server.log &
}
else
{
    ffmpeg -nostdin -loglevel fatal -f video4linux2 -framerate 20 \
    -s:v 640x480 -i /dev/video0 -ac 2 -f alsa -i hw:0 -ac 2 -c:a libvorbis \
    -s:v 640x480 -b:v 100KiB -c:v libvpx -f nut -b:a 9000B \
    - | aespipe -e AES256 -H SHA512 \
    -P in | nc -w 60 -n $ip $toport > server.log &
}
fi

gpg2 --decrypt --output - $key >> in &


if [[ $fromport ]];  then
{
    nc -l -p $fromport | aespipe -e AES256 -H SHA512 -d -P in | ffplay \
    -acodec libvorbis -x 640 -y 480 -vcodec libvpx \
    -b:a 9000B -ac 2 -b:v 100KiB -f nut -sync video -
}
else
{
    nc -l -p $toport | aespipe -e AES256 -H SHA512 -d -P in | ffplay \
    -acodec libvorbis -x 640 -y 480 -vcodec libvpx -loglevel fatal \
    -b:a 9000B -ac 2 -b:v 100KiB -f nut -sync video -
}
fi


exit 0


