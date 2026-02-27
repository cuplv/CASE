FROM eclipse-temurin:21-jdk

RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

ENV _JAVA_OPTIONS="-Xmx4g"

WORKDIR /app
COPY . .
RUN npm i @effekt-lang/effekt

CMD ["sh", "-c", "\
  ./node_modules/@effekt-lang/effekt/bin/effekt -b concrete.effekt && \
  ./node_modules/@effekt-lang/effekt/bin/effekt -b concmono.effekt && \
  ./node_modules/@effekt-lang/effekt/bin/effekt -b typecheck.effekt && \
  ./node_modules/@effekt-lang/effekt/bin/effekt -b symbolic/symsmtrunner.effekt"]
