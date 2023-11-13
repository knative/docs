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

FROM scratch

# Add a user so the server will run as a non-root user.
RUN addgroup -g 1000 appuser && \
    adduser -S -u 1000 -G appuser appuser

# To build it: cargo build --target x86_64-unknown-linux-musl --release
COPY target/x86_64-unknown-linux-musl/release/knative-cloudevents-example /app

USER appuser

CMD ["/app"]
