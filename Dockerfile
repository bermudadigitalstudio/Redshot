FROM lgaches/docker-swift:swift-4


WORKDIR /code

COPY Package@swift-4.0.swift /code/Package.swift
RUN swift build || true

COPY ./Sources /code/Sources
COPY ./Tests /code/Tests

CMD swift test