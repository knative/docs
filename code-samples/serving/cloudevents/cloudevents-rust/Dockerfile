# Copyright 2020 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build for the selected Docker target platform, rather than copying a host binary.
FROM rust:1.99.1-alpine AS build
RUN apk add --no-cache build-base ca-certificates \
    && rustup component add rustfmt clippy
WORKDIR /src
ENV CARGO_BUILD_JOBS=2
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo fmt --check \
    && cargo clippy --locked --release --all-targets -- -D warnings \
    && cargo build --locked --release

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /src/target/release/knative-cloudevents-example /app
USER 65532:65532
CMD ["/app"]
