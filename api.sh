DIRECTORY="${PWD}/data/"
FILE_PATH="${DIRECTORY}output.js"
if test -d ${DIRECTORY}
then
    mkdir ${DIRECTORY}
fi
if [ ! -f FILE_PATH ]
then
    touch ${FILE_PATH}
fi
printf "const API_URL = \"$2\";\n\nexport default API_URL;" > ${FILE_PATH}
aws s3 cp ${FILE_PATH} s3://$2 --recursive