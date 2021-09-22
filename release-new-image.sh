set -e

TAG_NAME=$(git describe --abbrev=0 --tags --exact-match);
export TAG=$TAG_NAME;

docker-compose build;
docker-compose push;
