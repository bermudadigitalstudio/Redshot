FROM swift:4


WORKDIR /code

COPY Package.swift /code/.
COPY ./Sources /code/Sources
COPY ./Tests /code/Tests

CMD swift test