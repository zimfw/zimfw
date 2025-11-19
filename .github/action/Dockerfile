FROM alpine:latest
RUN apk add -U --no-cache zsh bash git make shellcheck
# Change default shell from ash to zsh
RUN sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd
ENTRYPOINT ["zsh", "-c"]
