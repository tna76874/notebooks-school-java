#!/bin/bash
IMAGENAME="schoolnotebookjava"
REPO_URL="ghcr.io"
REPO_USER="tna76874"

# Überprüfen, ob ungecommitete Änderungen vorhanden sind
if [[ -n $(git status -s) ]]; then
  echo "Es gibt ungecommitete Änderungen im Repository. Bitte committen oder stashen Sie Ihre Änderungen, bevor Sie das Skript ausführen."
  exit 1
fi

# #docker login -u "$REPO_USER" "$REPO_URL"
# if grep -q "$REPO_URL" ~/.docker/config.json; then
# echo "Zeichenkette gefunden in ~/.docker/config.json"
# else
# docker login -u "$REPO_USER" "$REPO_URL"
# fi

# Git-Hash des HEAD abrufen
GIT_HASH=$(git rev-parse HEAD)
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

# Überprüfen, ob der Branch "master" ist
if [[ $current_branch == "master" ]]; then
  channel="stable"
else
  channel=$current_branch
fi

# Git-Tag abrufen
TAG=$(git describe --tags --exact-match HEAD 2>/dev/null)

if [[ -n "$TAG" ]]; then
  # Docker-Image mit dem Tag-Namen bauen
  docker build -t $REPO_URL/$REPO_USER/$IMAGENAME:$TAG .
  docker push ${REPO_URL}/${REPO_USER}/$IMAGENAME:$TAG
fi

docker build -t  $REPO_URL/$REPO_USER/$IMAGENAME:$channel .
docker build -t  $REPO_URL/$REPO_USER/$IMAGENAME:$GIT_HASH .

# docker push ${REPO_URL}/${REPO_USER}/$IMAGENAME:$channel
# docker push ${REPO_URL}/${REPO_USER}/$IMAGENAME:$GIT_HASH