## Prerequisites to Velero Instalation

In order to get Velero working on EKS we need to configure credentials and the Object Storage.

Env Variables that we will be using along the installation:
```sh
export VELERO_FOLDER=/opt/velero
export BUCKET_NAME=k8s-cluster-velero
export VELERO_USER_NAME=velero
export CLOUD_REGION=us-east-1 # AWS
```

### Making an Object Storage
#### AWS

```sh
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $CLOUD_REGION
```

### User Creation

After execute the cloud provider's commands, you must write Velero credentials into a file.

#### AWS

```sh
# Create Velero User
aws iam create-user --user-name $VELERO_USER_NAME

# Create a JSON with the Velero user policies.
cat > $VELERO_FOLDER/velero-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET_NAME}"
            ]
        }
    ]
}
EOF

# Attach the user policies to Velero user
aws iam put-user-policy \
  --user-name $VELERO_USER_NAME \
  --policy-name $VELERO_USER_NAME \
  --policy-document file://${VELERO_FOLDER}/velero-policy.json

# Obtain the Velero user credentials
export VELERO_CREDENTIALS_OUTPUT=$(aws iam create-access-key --user-name $VELERO_USER_NAME)
export VELERO_AWS_ACCESS=$(echo -n "$VELERO_CREDENTIALS_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
export VELERO_AWS_SECRET=$(echo -n "$VELERO_CREDENTIALS_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')

# And write these credentials to a file (credentials-velero)
cat > $VELERO_FOLDER/credentials-velero <<EOF
[default]
aws_access_key_id=${VELERO_AWS_ACCESS}
aws_secret_access_key=${VELERO_AWS_SECRET}
EOF
```

