ARG NODE_VERSION=18

FROM node:$NODE_VERSION

ARG TF_VERSION=1.5.0
ARG PROJECT=development

RUN apt-get update && \
    apt-get install -y sudo less vim jq

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2 && \
    aws/install && \
    rm -r awscliv2.zip aws && \
    aws --version

RUN TF_VERSION=${TF_VERSION} \
    curl "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_386.zip" -o "terraform.zip" && \
    unzip terraform.zip && \
    rm terraform.zip && \
    mv terraform /usr/local/bin && \
    terraform --version

RUN npm i -g vite

RUN npx playwright install-deps && npx playwright install

WORKDIR /home/${PROJECT}

# SvelteKit build preview and dev port numbers respectively
EXPOSE 4173 5173
