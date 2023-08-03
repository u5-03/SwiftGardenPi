FROM swift:latest
WORKDIR ../SwiftGardenPi
COPY . ./
CMD ["swift", "run"]
