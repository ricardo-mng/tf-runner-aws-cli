FROM ghcr.io/weaveworks/tf-runner:v0.13.0-rc.1 as tf-runner

FROM alpine:3.16
LABEL maintainer="ICE"
LABEL description="Image to run terraform operations locally with aws cli support"
LABEL version="v1.0.0"

RUN apk add --no-cache ca-certificates tini git openssh-client gnupg && \
    apk add --no-cache libretls && \
    apk add --no-cache busybox && \
    apk add --no-cache aws-cli

COPY --from=tf-runner /usr/local/bin/tf-runner /usr/local/bin/
COPY --from=tf-runner /usr/local/bin/terraform /usr/local/bin/

RUN find / -xdev -perm +6000 -type f -exec chmod a-s {} \; || true

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

RUN addgroup --gid 65532 -S runner && adduser --uid 65532 -S runner -G runner && chmod +x /usr/bin/aws && chmod +x /usr/local/bin/terraform

RUN rm /usr/bin/wget && \
    rm /usr/sbin/chroot && \
    rm /bin/mount
RUN chmod 0 /sbin/apk

USER 65532:65532

ENV GNUPGHOME=/tmp

ENTRYPOINT [ "/sbin/tini", "--", "tf-runner" ]