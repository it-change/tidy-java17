#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

NAME=java-v17
VER=1.0.0
IMG=$(NAME):$(VER)
PREFIX=itchange
INVOKE=python3 ../../tools/invoke.py
MAIN_JAR=example/hello.jar

build:
	docker build  -t $(IMG) .

push: build
	docker login
	docker tag $(IMG) $(PREFIX)/$(IMG)
	docker push $(PREFIX)/$(IMG)

push-latest: build
	docker login
	docker tag $(IMG) $(PREFIX)/$(NAME):latest
	docker push $(PREFIX)/$(NAME):latest

clean:
	docker rmi -f $(IMG)

start: build
	docker run -p 8080:8080 -ti -v $(PWD):/proxy $(IMG)

debug: build
	docker run -p 8080:8080 -ti --entrypoint=/bin/bash -v $(PWD):/mnt -e OW_COMPILER=/mnt/bin/compile $(IMG)

.PHONY: build push clean start debug

$(MAIN_JAR):
	$(MAKE) $< -C example hello.jar

## You need to execute make start in another terminal

test-jar:
	$(INVOKE) init action.Hello $(MAIN_JAR)
	$(INVOKE) run '{}'
	$(INVOKE) run '{"name":"Mike"}'

