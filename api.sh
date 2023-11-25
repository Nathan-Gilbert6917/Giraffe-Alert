DIRECTORY="${PWD}/data/"
FILE_PATH="${DIRECTORY}output.js"
if ! test -d ${DIRECTORY}
then
    mkdir ${DIRECTORY}
fi
if [ ! -f FILE_PATH ]
then
    touch ${FILE_PATH}
fi
printf "const API_URL = \"$1\";\n\nexport default API_URL;" > ${FILE_PATH}
aws s3 cp "${DIRECTORY}" s3://$2 --recursive