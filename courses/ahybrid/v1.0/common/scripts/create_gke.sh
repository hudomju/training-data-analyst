#!/usr/bin/env bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gcloud config set compute/zone ${C1_ZONE}
gcloud beta container clusters create ${C1_NAME} \
    --machine-type=n1-standard-4 \
    --num-nodes=4 \
    --workload-pool=${WORKLOAD_POOL} \
    --enable-stackdriver-kubernetes \
    --subnetwork=default \
    --labels mesh_id=${MESH_ID}

# service account requires additional role bindings
kubectl create clusterrolebinding [BINDING_NAME] \
    --clusterrole cluster-admin --user [USER]

gcloud iam service-accounts create ${C1_NAME}-connect-sa

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
 --member="serviceAccount:${C1_NAME}-connect-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

gcloud iam service-accounts keys create ${C1_NAME}-connect-sa-key.json \
  --iam-account=${C1_NAME}-connect-sa@${PROJECT_ID}.iam.gserviceaccount.com

gcloud container hub memberships register ${C1_NAME}-connect \
   --gke-cluster=${C1_ZONE}/${C1_NAME}  \
   --service-account-key-file=./${C1_NAME}-connect-sa-key.json