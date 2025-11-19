FROM alpine:latest
RUN apk add -U --no-cache zsh bash git make shellcheck
# Change default shell from ash to bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
ENTRYPOINT ["bash", "-c"]
