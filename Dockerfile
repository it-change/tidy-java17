FROM ibm-semeru-runtimes:open-17-jdk-focal as build

ENV LANG="en_US.UTF-8" \
        LANGUAGE="en_US:en" \
        LC_ALL="en_US.UTF-8" \
        VERSION=17 \
        UPDATE=5 \
        BUILD=8

ADD proxy /javaAction

RUN cd /javaAction \
        && rm -rf .classpath .gitignore .gradle .project .settings Dockerfile build \
        && ./gradlew oneJar \
        && rm -rf /javaAction/src \
        && ./compileClassCache.sh


FROM  ibm-semeru-runtimes:open-17-jre-focal

COPY --from=build /javaAction /javaAction
COPY --from=build /root/.gradle /root/.gradle
COPY --from=build /javaSharedCache /javaSharedCache

RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get -y --no-install-recommends install locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/.gradle/wrapper \
    && rm -rf /root/.gradle/caches/7.6 \
    && locale-gen en_US.UTF-8

ENV LANG="en_US.UTF-8" \
        LANGUAGE="en_US:en" \
        LC_ALL="en_US.UTF-8" \
        VERSION=17 \
        UPDATE=5 \
        BUILD=8

CMD ["java", "-Dfile.encoding=UTF-8", "-Xshareclasses:cacheDir=/javaSharedCache,readonly", "-Xquickstart", "-jar", "/javaAction/build/libs/javaAction-all.jar"]
