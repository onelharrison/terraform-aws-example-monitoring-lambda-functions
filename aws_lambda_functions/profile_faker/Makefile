APP_NAME = profile-faker
APP_VERSION = 0.0.1

AWS_ECR_ACCOUNT_ID ?=
AWS_ECR_REGION ?=
AWS_ECR_REPO = $(APP_NAME)

TAG ?= $(APP_VERSION)


.PHONY : docker/build docker/push docker/run docker/test

docker/build :
	docker build -t $(APP_NAME):$(APP_VERSION) .


docker/push : docker/build
	aws ecr get-login-password --region $(AWS_ECR_REGION) | docker login --username AWS --password-stdin $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com
	docker tag $(APP_NAME):$(APP_VERSION) $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG)
	docker push $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO):$(TAG)

docker/run : docker/build
  docker run -p 9000:8080 $(APP_NAME):$(APP_VERSION)

docker/test : docker/run
  curl -XPOST 'http://localhost:9000/functions/function/invocations' -d '{}'