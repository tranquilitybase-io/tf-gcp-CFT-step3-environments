echo looking for past deployments to delete:
ENV_FOLDER=./env
[ -d $ENV_FOLDER ] && { echo "Removing past deployment file $ENV_FOLDER"; rm -rf $ENV_FOLDER; } || echo "No past deployments found"

ENV_VARIABLES=./scripts/2-environments/env-variables.sh
[ -f $ENV_VARIABLES ] && { echo Sourcing required variables; source $ENV_VARIABLES; } || echo "Can't find $ENV_VARIABLES file, assuming Jenkins deployment"

echo Creating root env folder
mkdir env
cd ./env

echo Cloning CFT
CFT_FOLDER=./terraform-example-foundation
[ -d $CFT_FOLDER ] && { echo "Removing past deployment file: $CFT_FOLDER"; rm -rf $CFT_FOLDER; } || echo "No past deployments found"
git clone https://github.com/terraform-google-modules/terraform-example-foundation.git

echo Checkout latest release
cd ./terraform-example-foundation/
git checkout ed164ba
cd ..

echo looking for past env folder:
GCP_ENV_FOLDER=./gcp-environments
[ -d $GCP_ENV_FOLDER ] && { echo "Removing past deployment file: $GCP_ENV_FOLDER"; rm -rf $GCP_ENV_FOLDER; } || echo "No past deployments found"

echo Cloning gcp environments GSR
gcloud source repos clone gcp-environments --project=$CLOUD_BUILD_PROJECT_ID
cd gcp-environments

echo Checking out plan
git checkout -b plan

echo Copying needed build files
cp -R ../terraform-example-foundation/2-environments/. .
cp ../terraform-example-foundation/build/cloudbuild-tf-* .
cp ../terraform-example-foundation/build/tf-wrapper.sh .
chmod 755 ./tf-wrapper.sh

echo Removing unneeded variable file from current dir
TF_EXAMPLE_VARS=./terraform.example.tfvars
[ -f $TF_EXAMPLE_VARS ] && { echo "Removing unneeded terraform.example.tfvars file: $TF_EXAMPLE_VARS"; rm $TF_EXAMPLE_VARS; } || { echo "No terraform.example.tfvars file found"; }

echo Copying in needed variables for dev jenkins deployment 
TF_VARS=../../scripts/2-environments/terraform.auto.tfvars.json
COPY_LOCATION=./envs/development/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming bash deployment"; }

echo Copying in needed variables for dev for bash deployment
TF_VARS=../../scripts/2-environments/terraform.tfvars
COPY_LOCATION=./envs/development/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming jenkins deployment"; }

echo Copying in needed variables for non-prod jenkins deployment 
TF_VARS=../../scripts/2-environments/terraform.auto.tfvars.json
COPY_LOCATION=./envs/non-production/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming bash deployment"; }

echo Copying in needed variables for non-prod for bash deployment
TF_VARS=../../scripts/2-environments/terraform.tfvars
COPY_LOCATION=./envs/non-production/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming jenkins deployment"; }

echo Copying in needed variables for prod jenkins deployment 
TF_VARS=../../scripts/2-environments/terraform.auto.tfvars.json
COPY_LOCATION=./envs/production/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming bash deployment"; }

echo Copying in needed variables for prod for bash deployment
TF_VARS=../../scripts/2-environments/terraform.tfvars
COPY_LOCATION=./envs/production/.
[ -f $TF_VARS ] && { echo "Copying $TF_VARS to $COPY_LOCATION"; cp --remove-destination $TF_VARS $COPY_LOCATION; } || { echo "No $TF_VARS file found"; echo "assuming jenkins deployment"; }

echo pushing plan
git add .
git commit -m 'Your message'
git push --set-upstream origin plan --force

sleep 300

git checkout -b development
git push origin development --force

sleep 300

git checkout -b non-production
git push origin non-production --force

sleep 300

git checkout -b production
git push origin production --force
